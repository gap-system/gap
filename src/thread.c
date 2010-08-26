#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <pthread.h>
#include <errno.h>
#ifndef DISABLE_GC
#include <gc/gc.h>
#endif

#include        "system.h"
#include        "objects.h"
#include	"scanner.h"
#include	"code.h"
#include        "tls.h"
#include        "thread.h"

#define LOG2_NUM_LOCKS 11
#define NUM_LOCKS (1 << LOG2_NUM_LOCKS)

typedef struct {
  pthread_t pthread_id;
  int joined;
  void *tls;
  void (*start)(void *);
  void *arg;
  int next;
} ThreadData;

static ThreadData thread_data[MAX_THREADS];
static int thread_free_list;

static pthread_mutex_t master_lock;

static pthread_rwlock_t ObjLock[NUM_LOCKS];

int PreThreadCreation = 1;

#ifndef MAP_ANONYMOUS
#define MAP_ANONYMOUS MAP_ANON
#endif

#ifndef HAVE_NATIVE_TLS

void *AllocateTLS()
{
  void *addr;
  void *result;
  size_t pagesize = getpagesize();
  size_t tlssize = (sizeof(ThreadLocalStorage)+pagesize-1) & ~ (pagesize-1);
  addr = mmap(0, 2 * TLS_SIZE, PROT_READ|PROT_WRITE,
    MAP_PRIVATE|MAP_ANONYMOUS, -1 , 0);
  result = (void *)((((uintptr_t) addr) + (TLS_SIZE-1)) & TLS_MASK);
  munmap(addr, (char *)result-(char *)addr);
  munmap((char *)result+TLS_SIZE, (char *)addr-(char *)result+TLS_SIZE);
  /* generate a stack overflow protection area */
#ifdef STACK_GROWS_UP
  mprotect((char *) result + TLS_SIZE - tlssize - pagesize, pagesize, PROT_NONE);
#else
  mprotect((char *) result + tlssize, pagesize, PROT_NONE);
#endif
  return result;
}

void FreeTLS(void *address)
{
  /* We currently cannot free this memory because of garbage collector
   * issues. Instead, it will be reused */
#if 0
  munmap(address, TLS_STACK_SIZE);
#endif
}

#endif /* HAVE_NATIVE_TLS */

#ifndef DISABLE_GC
void AddGCRoots()
{
  void *p = TLS;
  GC_add_roots(p, (char *)p + sizeof(ThreadLocalStorage));
}

void RemoveGCRoots()
{
  void *p = TLS;
  GC_remove_roots(p, (char *)p + sizeof(ThreadLocalStorage));
}
#endif /* DISABLE_GC */

#ifdef __GNUC__
static void SetupTLS() __attribute__((noinline));
static void GrowStack() __attribute__((noinline));
#endif

#ifndef HAVE_NATIVE_TLS
static void GrowStack()
{
  char *tls = (char *) TLS;
  size_t pagesize = getpagesize();
  char *p = alloca(pagesize);
  while (p > tls)
  {
    *p = '\0'; /* touch memory */
    p = alloca(pagesize);
  }
}
#endif

static void SetupTLS()
{
#ifndef HAVE_NATIVE_TLS
  GrowStack();
#endif
  InitializeTLS();
  MainThreadTLS = TLS;
  TLS->threadID = -1;
}

void RunThreadedMain(
  int (*mainFunction)(int, char **, char **),
  int argc,
  char **argv,
  char **environ )
{
  int i;
#ifdef STACK_GROWS_UP
#error Upward growing stack not yet supported
#else
#ifndef HAVE_NATIVE_TLS
  int dummy[0];
  alloca(((uintptr_t) dummy) &~TLS_MASK);
#endif
  SetupTLS();
#endif
  for (i=0; i<MAX_THREADS-1; i++)
    thread_data[i].next = i+1;
  for (i=0; i<NUM_LOCKS; i++)
    pthread_rwlock_init(&ObjLock[i], 0);
  thread_data[MAX_THREADS-1].next = -1;
  for (i=0; i<MAX_THREADS; i++)
    thread_data[i].tls = 0;
  thread_free_list = 0;
  pthread_mutex_init(&master_lock, 0);
  exit((*mainFunction)(argc, argv, environ));
}

void *DispatchThread(void *arg)
{
  ThreadData *this_thread = arg;
  InitializeTLS();
  TLS->threadID = this_thread - thread_data;
#ifndef DISABLE_GC
  AddGCRoots();
#endif
  InitTLS();
  this_thread->start(this_thread->arg);
  DestroyTLS();
#ifndef DISABLE_GC
  RemoveGCRoots();
#endif
  return 0;
}

int RunThread(void (*start)(void *), void *arg)
{
  int result;
#ifndef HAVE_NATIVE_TLS
  void *tls;
#endif
  pthread_attr_t thread_attr;
  size_t pagesize = getpagesize();
  pthread_mutex_lock(&master_lock);
  PreThreadCreation = 0;
  /* allocate a new thread id */
  if (thread_free_list < 0)
  {
    pthread_mutex_unlock(&master_lock);
    errno = ENOMEM;
    return -1;
  }
  result = thread_free_list;
  thread_free_list = thread_data[thread_free_list].next;
#ifndef HAVE_NATIVE_TLS
  tls = thread_data[result].tls = AllocateTLS();
#endif
  thread_data[result].arg = arg;
  thread_data[result].start = start;
  thread_data[result].joined = 0;
  /* set up the thread attribute to support a custom stack in our TLS */
  pthread_attr_init(&thread_attr);
#ifndef HAVE_NATIVE_TLS
  pthread_attr_setstack(&thread_attr, (char *)tls + pagesize * 2,
      TLS_SIZE-pagesize*2);
#endif
  pthread_mutex_unlock(&master_lock);
  /* fork the thread */
  if (pthread_create(&thread_data[result].pthread_id, &thread_attr,
                     DispatchThread, thread_data+result) < 0) {
    pthread_mutex_lock(&master_lock);
    thread_data[result].next = thread_free_list;
    thread_free_list = result;
    pthread_mutex_unlock(&master_lock);
    pthread_attr_destroy(&thread_attr);
#ifndef HAVE_NATIVE_TLS
    FreeTLS(tls);
  #endif
    return -1;
  }
  pthread_attr_destroy(&thread_attr);
  return result;
}

int JoinThread(int id)
{
  pthread_t pthread_id;
  void (*start)(void *);
#ifndef HAVE_NATIVE_TLS
  void *tls;
#endif
  if (id < 0 || id >= MAX_THREADS)
    return 0;
  pthread_mutex_lock(&master_lock);
  pthread_id = thread_data[id].pthread_id;
  start = thread_data[id].start;
#ifndef HAVE_NATIVE_TLS
  tls = thread_data[id].tls;
#endif
  if (thread_data[id].joined || start == NULL)
  {
    pthread_mutex_unlock(&master_lock);
    return 0;
  }
  thread_data[id].joined = 1;
  pthread_mutex_unlock(&master_lock);
  pthread_join(pthread_id, NULL);
  pthread_mutex_lock(&master_lock);
  thread_data[id].next = thread_free_list;
  thread_free_list = id;
  thread_data[id].tls = NULL;
  thread_data[id].start = NULL;
  pthread_mutex_unlock(&master_lock);
#ifndef HAVE_NATIVE_TLS
  FreeTLS(tls);
#endif
  return 1;
}

unsigned LockID(void *object) {
  unsigned p = (unsigned) object;
  if (sizeof(void *) == 4)
    return ((p >> 2)
      ^ (p >> (2 + LOG2_NUM_LOCKS))
      ^ (p << (LOG2_NUM_LOCKS - 2))) % NUM_LOCKS;
  else
    return ((p >> 3)
      ^ (p >> (3 + LOG2_NUM_LOCKS))
      ^ (p << (LOG2_NUM_LOCKS - 3))) % NUM_LOCKS;
}

void Lock(void *object) {
  pthread_rwlock_wrlock(&ObjLock[LockID(object)]);
}

void LockShared(void *object) {
  pthread_rwlock_rdlock(&ObjLock[LockID(object)]);
}

void Unlock(void *object) {
  pthread_rwlock_unlock(&ObjLock[LockID(object)]);
}

void UnlockShared(void *object) {
  pthread_rwlock_unlock(&ObjLock[LockID(object)]);
}

