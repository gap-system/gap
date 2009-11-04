#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <pthread.h>
#include <errno.h>
#include <gc/gc.h>

#include        "system.h"
#include        "objects.h"
#include	"scanner.h"
#include        "tls.h"
#include        "thread.h"

typedef struct {
  pthread_t pthread_id;
  void *tls;
  void (*start)();
  int next;
} ThreadData;

static ThreadData thread_data[MAX_THREADS];
static int thread_free_list;

static pthread_mutex_t master_lock;

#ifndef MAP_ANONYMOUS
#define MAP_ANONYMOUS MAP_ANON
#endif

#ifndef HAVE_NATIVE_TLS

void *AllocateTLS()
{
  void *addr;
  void *result;
  size_t pagesize = getpagesize();
  addr = mmap(0, 2 * TLS_SIZE, PROT_READ|PROT_WRITE,
    MAP_PRIVATE|MAP_ANONYMOUS, -1 , 0);
  result = (void *)((((uintptr_t) addr) + (TLS_SIZE-1)) & TLS_MASK);
  munmap(addr, (char *)result-(char *)addr);
  munmap((char *)result+TLS_SIZE, (char *)addr-(char *)result+TLS_SIZE);
  /* generate a stack overflow protection area */
#ifdef STACK_GROWS_UP
  mprotect((char *) result + TLS_SIZE - pagesize, pagesize, PROT_NONE);
#else
  mprotect((char *) result + pagesize, pagesize, PROT_NONE);
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
  InitializeTLS();
#endif
#endif
  for (i=0; i<MAX_THREADS-1; i++)
    thread_data[i].next = i+1;
  thread_data[MAX_THREADS-1].next = -1;
  for (i=0; i<MAX_THREADS; i++)
    thread_data[i].tls = 0;
  thread_free_list = 0;
  pthread_mutex_init(&master_lock, 0);
  TLS->threadID = -1;
  exit((*mainFunction)(argc, argv, environ));
}

static void AddGCRoots()
{
  void *p = TLS;
  GC_add_roots(p, (char *)p + sizeof(ThreadLocalStorage));
}

static void RemoveGCRoots()
{
  void *p = TLS;
  GC_remove_roots(p, (char *)p + sizeof(ThreadLocalStorage));
}

void *DispatchThread(void *arg)
{
  ThreadData *this_thread = arg;
  struct GC_stack_base stack_base;
  stack_base.mem_base = &stack_base;
  GC_register_my_thread(&stack_base);
  InitializeTLS();
  TLS->threadID = this_thread - thread_data;
  AddGCRoots();
  this_thread->start();
  RemoveGCRoots();
  GC_unregister_my_thread();
  return 0;
}

int RunThread(void (*start)())
{
  int result;
#ifndef HAVE_NATIVE_TLS
  void *tls;
#endif
  pthread_attr_t thread_attr;
  pthread_mutex_lock(&master_lock);
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
  thread_data[result].start = start;
  /* set up the thread attribute to support a custom stack in our TLS */
  pthread_attr_init(&thread_attr);
#ifndef HAVE_NATIVE_TLS
  pthread_attr_setstackaddr(&thread_attr, (char *)tls + TLS_SIZE);
  pthread_attr_setstacksize(&thread_attr, TLS_SIZE-getpagesize()*2);
#endif
  pthread_mutex_unlock(&master_lock);
  /* fork the thread */
  if (pthread_create(&thread_data[result].pthread_id, &thread_attr,
                     DispatchThread, thread_data+result) < 0) {
    pthread_mutex_lock(&master_lock);
    thread_data[result].next = thread_free_list;
    thread_free_list = result;
    pthread_mutex_unlock(&master_lock);
#ifndef HAVE_NATIVE_TLS
    FreeTLS(tls);
  #endif
    return -1;
  }
  return result;
}

void JoinThread(int id)
{
  pthread_t pthread_id;
#ifndef HAVE_NATIVE_TLS
  void *tls;
#endif
  pthread_mutex_lock(&master_lock);
  pthread_id = thread_data[id].pthread_id;
#ifndef HAVE_NATIVE_TLS
  tls = thread_data[id].tls;
#endif
  thread_data[id].next = thread_free_list;
  thread_free_list = id;
  pthread_mutex_unlock(&master_lock);
  pthread_join(pthread_id, 0);
#ifndef HAVE_NATIVE_TLS
  FreeTLS(tls);
#endif
}
