#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <pthread.h>
#include <errno.h>
#ifndef DISABLE_GC
#include <gc/gc.h>
#endif
#include "global.h"

#include        "system.h"
#include        "gasman.h"
#include        "objects.h"
#include        "bool.h"
#include        "gvars.h"
#include	"scanner.h"
#include	"code.h"
#include	"plist.h"
#include	"string.h"
#include	"precord.h"
#include	"stats.h"
#include        "tls.h"
#include        "thread.h"
#include	"fibhash.h"

#define LOG2_NUM_LOCKS 11
#define NUM_LOCKS (1 << LOG2_NUM_LOCKS)

#ifndef WARD_ENABLED

typedef struct ThreadData {
  pthread_t pthread_id;
  pthread_mutex_t *lock;
  pthread_cond_t *cond;
  int joined;
  int system;
  AO_t state;
  void *tls;
  void (*start)(void *);
  void *arg;
  Obj thread_object;
  Obj region_name;
  struct ThreadData *next;
} ThreadData;

typedef struct TraversalState {
  struct TraversalState *previousTraversal;
  Obj list;
  UInt listSize;
  UInt listCurrent;
  UInt listCapacity;
  Obj hashTable;
  Obj copyMap;
  UInt hashSize;
  UInt hashCapacity;
  UInt hashBits;
  Region *dataSpace;
  int delimitedCopy;
} TraversalState;

Region *LimboRegion, *ReadOnlyRegion, *ProtectedRegion;
Obj PublicRegion;
Obj PublicRegionName;

static int GlobalPauseInProgress;
static AO_t ThreadCounter = 1;

static inline TraversalState *currentTraversal() {
  return TLS->traversalState;
}

static inline void IncThreadCounter() {
  AO_fetch_and_add1(&ThreadCounter);
}

static inline void DecThreadCounter() {
  AO_fetch_and_sub1(&ThreadCounter);
}

int IsSingleThreaded() {
  return ThreadCounter == 1;
}

void BeginSingleThreaded() {
  if (ThreadCounter == 1)
    ProtectedRegion->owner = TLS;
}

void EndSingleThreaded() {
  ProtectedRegion->owner = NULL;
}

static ThreadData thread_data[MAX_THREADS];
static ThreadData *paused_threads[MAX_THREADS];
static ThreadData *thread_free_list;
static int num_paused_threads;

static pthread_rwlock_t master_lock;

static pthread_rwlock_t ObjLock[NUM_LOCKS];

int PreThreadCreation = 1;

void LockThreadControl(int modify) {
  if (modify)
    pthread_rwlock_wrlock(&master_lock);
  else
    pthread_rwlock_rdlock(&master_lock);
}

void UnlockThreadControl(void) {
  pthread_rwlock_unlock(&master_lock);
}

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
  TLS->threadID = 0;
}

static void InitTraversal();

Obj NewThreadObject(UInt id) {
  Obj result = NewBag(T_THREAD, 3*sizeof(UInt));
  ADDR_OBJ(result)[0] = (Bag) 0;
  ADDR_OBJ(result)[1] = (Bag) id;
  ADDR_OBJ(result)[2] = (Bag) 0;
  return result;
}

void InitMainThread()
{
  TLS->threadObject = NewThreadObject(0);
}

static void RunThreadedMain2(
  int (*mainFunction)(int, char **, char **),
  int argc,
  char **argv,
  char **environ )
#ifdef __GNUC__
  __attribute__((noinline))
#endif
;

void RunThreadedMain(
  int (*mainFunction)(int, char **, char **),
  int argc,
  char **argv,
  char **environ )
{
#ifndef HAVE_NATIVE_TLS
#ifdef STACK_GROWS_UP
#error Upward growing stack not yet supported
#else
  int dummy[0];
  alloca(((uintptr_t) dummy) &~TLS_MASK);
#endif
#endif
  RunThreadedMain2(mainFunction, argc, argv, environ);
}

static void RunThreadedMain2(
  int (*mainFunction)(int, char **, char **),
  int argc,
  char **argv,
  char **environ )
{
  int i;
  static pthread_mutex_t main_thread_mutex;
  static pthread_cond_t main_thread_cond;
  SetupTLS();
  for (i=1; i<MAX_THREADS-1; i++)
    thread_data[i].next = thread_data+i+1;
  thread_data[0].next = NULL;
  for (i=0; i<NUM_LOCKS; i++)
    pthread_rwlock_init(&ObjLock[i], 0);
  thread_data[MAX_THREADS-1].next = NULL;
  for (i=0; i<MAX_THREADS; i++) {
    thread_data[i].tls = 0;
    thread_data[i].state = TSTATE_TERMINATED;
    thread_data[i].system = 0;
  }
  thread_free_list = thread_data+1;
  pthread_rwlock_init(&master_lock, 0);
  pthread_mutex_init(&main_thread_mutex, 0);
  pthread_cond_init(&main_thread_cond, 0);
  TLS->threadLock = &main_thread_mutex;
  TLS->threadSignal = &main_thread_cond;
  thread_data[0].lock = TLS->threadLock;
  thread_data[0].cond = TLS->threadSignal;
  thread_data[0].state = TSTATE_RUNNING;
  thread_data[0].tls = TLS;
  InitTraversal();
  if (sySetjmp(TLS->threadExit))
    exit(0);
  exit((*mainFunction)(argc, argv, environ));
}

void CreateMainRegion()
{
  int i;
  TLS->currentRegion = NewRegion();
  ((Region *)TLS->currentRegion)->fixed_owner = 1;
  RegionWriteLock(TLS->currentRegion);
  ((Region *)TLS->currentRegion)->name = MakeImmString("thread region #0");
  PublicRegionName = MakeImmString("public region");
  LimboRegion = NewRegion();
  LimboRegion->fixed_owner = 1;
  LimboRegion->name = MakeImmString("limbo region");
  ReadOnlyRegion = NewRegion();
  ReadOnlyRegion->name = MakeImmString("read-only region");
  ProtectedRegion = NewRegion();
  ProtectedRegion->name = MakeImmString("protected region");
  ReadOnlyRegion->fixed_owner = 1;
  ProtectedRegion->fixed_owner = 1;
  for (i=0; i<=MAX_THREADS; i++) {
    ReadOnlyRegion->readers[i] = 1;
    ProtectedRegion->readers[i] = 1;
  }
  BeginSingleThreaded();
}

void *DispatchThread(void *arg)
{
  ThreadData *this_thread = arg;
  Region *region;
  InitializeTLS();
  TLS->threadID = this_thread - thread_data;
#ifndef DISABLE_GC
  AddGCRoots();
#endif
  InitTLS();
  TLS->currentRegion = region = NewRegion();
  TLS->threadLock = this_thread->lock;
  TLS->threadSignal = this_thread->cond;
  region->fixed_owner = 1;
  region->name = this_thread->region_name;
  RegionWriteLock(region);
  if (!this_thread->region_name) {
    char buf[8];
    sprintf(buf, "%d", TLS->threadID);
    this_thread->region_name = MakeImmString2("thread #", buf);
  }
  SetRegionName(region, this_thread->region_name);
  TLS->threadObject = this_thread->thread_object;
  pthread_mutex_lock(this_thread->lock);
  *(ThreadLocalStorage **)(ADDR_OBJ(TLS->threadObject)) = TLS;
  pthread_cond_broadcast(this_thread->cond);
  pthread_mutex_unlock(this_thread->lock);
  this_thread->start(this_thread->arg);
  *(UInt *)(ADDR_OBJ(TLS->threadObject)+2) |= THREAD_TERMINATED;
  region->fixed_owner = 0;
  RegionWriteUnlock(region);
  DestroyTLS();
#ifndef DISABLE_GC
  RemoveGCRoots();
#endif
  DecThreadCounter();
  return 0;
}

Obj RunThread(void (*start)(void *), void *arg)
{
  ThreadData *result;
#ifndef HAVE_NATIVE_TLS
  void *tls;
#endif
  pthread_attr_t thread_attr;
  size_t pagesize = getpagesize();
  LockThreadControl(1);
  PreThreadCreation = 0;
  /* allocate a new thread id */
  if (thread_free_list == NULL)
  {
    UnlockThreadControl();
    errno = ENOMEM;
    return (Obj) 0;
  }
  result = thread_free_list;
  thread_free_list = thread_free_list->next;
#ifndef HAVE_NATIVE_TLS
  if (!result->tls)
    result->tls = AllocateTLS();
  tls = result->tls;
#endif
  if (!result->lock) {
    result->lock = AllocateMemoryBlock(sizeof(pthread_mutex_t));
    result->cond = AllocateMemoryBlock(sizeof(pthread_cond_t));
    pthread_mutex_init(result->lock, 0);
    pthread_cond_init(result->cond, 0);
  }
  result->arg = arg;
  result->start = start;
  result->joined = 0;
  if (GlobalPauseInProgress) {
    /* New threads will be automatically paused */
    result->state = TSTATE_PAUSED;
    HandleInterrupts(0, T_NO_STAT);
  } else {
    result->state = TSTATE_RUNNING;
  }
  result->thread_object = NewThreadObject(result-thread_data);
  /* set up the thread attribute to support a custom stack in our TLS */
  pthread_attr_init(&thread_attr);
#ifndef HAVE_NATIVE_TLS
  pthread_attr_setstack(&thread_attr, (char *)tls + pagesize * 2,
      TLS_SIZE-pagesize*2);
#endif
  UnlockThreadControl();
  /* fork the thread */
  EndSingleThreaded();
  IncThreadCounter();
  if (pthread_create(&result->pthread_id, &thread_attr,
                     DispatchThread, result) < 0) {
    /* No more threads available */
    DecThreadCounter();
    LockThreadControl(1);
    result->next = thread_free_list;
    thread_free_list = result;
    UnlockThreadControl();
    pthread_attr_destroy(&thread_attr);
#ifndef HAVE_NATIVE_TLS
    FreeTLS(tls);
  #endif
    return (Obj)0;
  }
  pthread_attr_destroy(&thread_attr);
  return result->thread_object;
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
  LockThreadControl(1);
  pthread_id = thread_data[id].pthread_id;
  start = thread_data[id].start;
#ifndef HAVE_NATIVE_TLS
  tls = thread_data[id].tls;
#endif
  if (thread_data[id].joined || start == NULL)
  {
    UnlockThreadControl();
    return 0;
  }
  thread_data[id].joined = 1;
  UnlockThreadControl();
  pthread_join(pthread_id, NULL);
  LockThreadControl(1);
  thread_data[id].next = thread_free_list;
  thread_free_list = thread_data+id;
  /*
  FreeTLS(thread_data[id].tls);
  thread_data[id].tls = NULL;
  */
  thread_data[id].start = NULL;
  UnlockThreadControl();
#ifndef HAVE_NATIVE_TLS
  FreeTLS(tls);
#endif
  return 1;
}

Int ThreadID(Obj thread)
{
  return *(UInt *)(ADDR_OBJ(thread)+1);
}

void *ThreadTLS(Obj thread)
{
  return *(ThreadLocalStorage **)(ADDR_OBJ(thread)+1);
}


static UInt LockID(void *object) {
  UInt p = (UInt) object;
#if CUSTOM_OBJECT_HASH
  if (sizeof(void *) == 4)
    return ((p >> 2)
      ^ (p >> (2 + LOG2_NUM_LOCKS))
      ^ (p << (LOG2_NUM_LOCKS - 2))) % NUM_LOCKS;
  else
    return ((p >> 3)
      ^ (p >> (3 + LOG2_NUM_LOCKS))
      ^ (p << (LOG2_NUM_LOCKS - 3))) % NUM_LOCKS;
#else
  return FibHash((UInt) object, LOG2_NUM_LOCKS);
#endif
}

void HashLock(void *object) {
  pthread_rwlock_wrlock(&ObjLock[LockID(object)]);
}

void HashLockShared(void *object) {
  pthread_rwlock_rdlock(&ObjLock[LockID(object)]);
}

void HashUnlock(void *object) {
  pthread_rwlock_unlock(&ObjLock[LockID(object)]);
}

void HashUnlockShared(void *object) {
  pthread_rwlock_unlock(&ObjLock[LockID(object)]);
}

void RegionWriteLock(Region *region)
{
  pthread_rwlock_wrlock(region->lock);
  region->owner = TLS;
}

int RegionTryWriteLock(Region *region)
{
  int result = !pthread_rwlock_trywrlock(region->lock);
  if (result)
    region->owner = TLS;
  return result;
}

void RegionWriteUnlock(Region *region)
{
  region->owner = NULL;
  pthread_rwlock_unlock(region->lock);
}

void RegionReadLock(Region *region)
{
  pthread_rwlock_rdlock(region->lock);
  region->readers[TLS->threadID] = 1;
}

int RegionTryReadLock(Region *region)
{
  int result = !pthread_rwlock_rdlock(region->lock);
  if (result)
    region->readers[TLS->threadID] = 1;
  return result;
}

void RegionReadUnlock(Region *region)
{
  region->readers[TLS->threadID] = 0;
  pthread_rwlock_unlock(region->lock);
}

void RegionUnlock(Region *region)
{
  if (region->owner == TLS)
    region->owner = NULL;
  region->readers[TLS->threadID] = 0;
  pthread_rwlock_unlock(region->lock);
}

int IsLocked(Region *region)
{
  if (!region)
    return 0; /* public region */
  if (region->owner == TLS)
    return 1;
  if (region->readers[TLS->threadID])
    return 2;
  return 0;
}

Region *GetRegionOf(Obj obj)
{
  if (!IS_BAG_REF(obj))
    return NULL;
  if (TNUM_OBJ(obj) == T_REGION)
    return *(Region **)(ADDR_OBJ(obj));
  return DS_BAG(obj);
}

void SetRegionName(Region *region, Obj name)
{
  if (name) {
    if (!IS_STRING(name))
      return;
    if (IS_MUTABLE_OBJ(name))
      name = CopyObj(name, 0);
  }
  AO_nop_write();
  region->name = name;
}

Obj GetRegionName(Region *region)
{
  Obj result;
  if (region)
    result = region->name;
  else
    result = PublicRegionName;
  AO_nop_read();
  return result;
}

void GetLockStatus(int count, Obj *objects, int *status)
{
  int i;
  for (i=0; i<count; i++)
    status[i] = IsLocked(DS_BAG(objects[i]));
}

static Obj NewList(UInt size)
{
  Obj list;
  list = NEW_PLIST(size == 0 ? T_PLIST_EMPTY : T_PLIST, size);
  SET_LEN_PLIST(list, size);
  return list;
}


#define MAX_LOCKS 1024

typedef struct
{
  Obj obj;
  Region *region;
  int mode;
} LockRequest;

static int LessThanLockRequest(const void *a, const void *b)
{
  Region *ds_a = ((LockRequest *)a)->region;
  Region *ds_b = ((LockRequest *)b)->region;
  if (ds_a == ds_b) /* prioritize writes */
    return ((LockRequest *)a)->mode>((LockRequest *)b)->mode;
  return (char *)ds_a < (char *)ds_b;
}

void PushRegionLock(Region *region) {
  if (!TLS->lockStack) {
    TLS->lockStack = NewList(16);
    TLS->lockStackPointer = 0;
  } else if (LEN_PLIST(TLS->lockStack) == TLS->lockStackPointer) {
    int newlen = TLS->lockStackPointer * 3 / 2;
    GROW_PLIST(TLS->lockStack, newlen);
  }
  TLS->lockStackPointer++;
  SET_ELM_PLIST(TLS->lockStack, TLS->lockStackPointer, region->obj);
}

void PopRegionLocks(int newSP) {
  while (newSP < TLS->lockStackPointer)
  {
    int p = TLS->lockStackPointer--;
    RegionUnlock(*(Region **)(ADDR_OBJ(ELM_PLIST(TLS->lockStack, p))));
    SET_ELM_PLIST(TLS->lockStack, p, (Obj) 0);
  }
}

int RegionLockSP() {
  return TLS->lockStackPointer;
}

int GetThreadState(int threadID) {
  return (int)(thread_data[threadID].state);
}

int UpdateThreadState(int threadID, int oldState, int newState) {
  return AO_compare_and_swap_full(&thread_data[threadID].state,
    (AO_t) oldState, (AO_t) newState);
}

static int SetInterrupt(int threadID) {
  ThreadLocalStorage *tls = thread_data[threadID].tls;
  tls->CurrExecStatFuncs = IntrExecStatFuncs;
}

static int LockAndUpdateThreadState(int threadID, int oldState, int newState) {
  if (pthread_mutex_trylock(thread_data[threadID].lock) < 0) {
    printf("locked\n");
    return 0;
  }
  if (!UpdateThreadState(threadID, oldState, newState)) {
    printf("update failed\n");
    pthread_mutex_unlock(thread_data[threadID].lock);
    return 0;
  }
  SetInterrupt(threadID);
  pthread_cond_signal(thread_data[threadID].cond);
  pthread_mutex_unlock(thread_data[threadID].lock);
  return 1;
}

void PauseThread(int threadID) {
  for (;;) {
    int state = GetThreadState(threadID);
    switch (state & TSTATE_MASK) {
    case TSTATE_RUNNING:
      if (UpdateThreadState(threadID,
          TSTATE_RUNNING, TSTATE_PAUSED|(TLS->threadID << TSTATE_SHIFT))) {
	SetInterrupt(threadID);
        return;
      }
      break;
    case TSTATE_BLOCKED:
    case TSTATE_SYSCALL:
      if (LockAndUpdateThreadState(threadID, 
          state, TSTATE_PAUSED|(TLS->threadID << TSTATE_SHIFT))) {
	return;
      }
    case TSTATE_PAUSED:
    case TSTATE_TERMINATED:
    case TSTATE_KILLED:
    case TSTATE_BREAK:
      return;
    }
  }
}

static void TerminateCurrentThread(int locked) {
  ThreadData *thread = thread_data + TLS->threadID;
  if (locked)
    pthread_mutex_unlock(thread->lock);
  syLongjmp(TLS->threadExit, 1);
}

static void PauseCurrentThread(int locked) {
  ThreadData *thread = thread_data + TLS->threadID;
  if (!locked)
    pthread_mutex_lock(thread->lock);
  for (;;) {
    int state = GetThreadState(TLS->threadID);
    if ((state & TSTATE_MASK) == TSTATE_KILLED)
      TerminateCurrentThread(1);
    if ((state & TSTATE_MASK) != TSTATE_PAUSED)
      break;
    ((Region *)(TLS->currentRegion))->alt_owner =
      thread_data[state >> TSTATE_SHIFT].tls;
    pthread_cond_wait(thread->cond, thread->lock);
    // TODO: This really should go in ResumeThread()
    ((Region *)(TLS->currentRegion))->alt_owner = NULL;
  }
  if (!locked)
    pthread_mutex_unlock(thread->lock);
}

static void EnterBreakCurrentThread(int locked, Stat stat) {
  ThreadData *thread = thread_data + TLS->threadID;
  if (stat == T_NO_STAT)
    return;
  if (!locked)
    pthread_mutex_lock(thread->lock);
  TLS->CurrExecStatFuncs = ExecStatFuncs;
  SET_BRK_CURR_STAT(stat);
  UpdateThreadState(TLS->threadID, TSTATE_BREAK, TSTATE_RUNNING);
  ErrorReturnVoid("system interrupt", 0L, 0L, "you can 'return;'");
  if (!locked)
    pthread_mutex_unlock(thread->lock);
}

void HandleInterrupts(int locked, Stat stat) {
   switch (GetThreadState(TLS->threadID) & TSTATE_MASK) {
     case TSTATE_PAUSED:
       PauseCurrentThread(locked);
       break;
     case TSTATE_BREAK:
       EnterBreakCurrentThread(locked, stat);
       break;
     case TSTATE_KILLED:
       TerminateCurrentThread(locked);
       break;
   }
}

void KillThread(int threadID) {
  for (;;) {
    int state = GetThreadState(threadID);
    switch (state & TSTATE_MASK) {
    case TSTATE_RUNNING:
      if (UpdateThreadState(threadID, TSTATE_RUNNING, TSTATE_KILLED)) {
	SetInterrupt(threadID);
        return;
      }
      break;
    case TSTATE_BLOCKED:
      if (LockAndUpdateThreadState(threadID, state, TSTATE_KILLED))
        return;
      break;
    case TSTATE_SYSCALL:
      if (UpdateThreadState(threadID, state, TSTATE_KILLED)) {
	  return;
      }
      break;
    case TSTATE_BREAK:
      if (UpdateThreadState(threadID, state, TSTATE_KILLED)) {
          SetInterrupt(threadID);
	  return;
      }
      break;
    case TSTATE_PAUSED:
      if (LockAndUpdateThreadState(threadID, state, TSTATE_KILLED)) {
        return;
      }
      break;
    case TSTATE_TERMINATED:
    case TSTATE_KILLED:
      return;
    }
  }
}

void InterruptThread(int threadID) {
  for (;;) {
    int state = GetThreadState(threadID);
    switch (state & TSTATE_MASK) {
    case TSTATE_RUNNING:
      if (UpdateThreadState(threadID,
          TSTATE_RUNNING, TSTATE_PAUSED|(threadID << TSTATE_SHIFT))) {
	SetInterrupt(threadID);
        return;
      }
      break;
    case TSTATE_BLOCKED:
      if (LockAndUpdateThreadState(threadID, state, TSTATE_BREAK))
        return;
    case TSTATE_SYSCALL:
      if (UpdateThreadState(threadID, state, TSTATE_BREAK)) {
        return;
      }
    case TSTATE_PAUSED:
    case TSTATE_TERMINATED:
    case TSTATE_KILLED:
    case TSTATE_BREAK:
      /* We do not interrupt threads that are interrupted */
      return;
    }
  }
}

void ResumeThread(int threadID) {
  int state = GetThreadState(threadID);
  if ((state & TSTATE_MASK) == TSTATE_PAUSED) {
    LockAndUpdateThreadState(threadID, state, TSTATE_RUNNING);
  }
}

int PauseAllThreads() {
  int i, n;
  LockThreadControl(1);
  if (GlobalPauseInProgress) {
    UnlockThreadControl();
    return 0;
  }
  GlobalPauseInProgress = 1;
  for (i=0, n=0; i<MAX_THREADS; i++) {
    switch (GetThreadState(i) & TSTATE_MASK) {
      case TSTATE_TERMINATED:
      case TSTATE_KILLED:
        break;
      default:
	if (!thread_data[i].system)
          paused_threads[n++] = thread_data + i;
	break;
    }
  }
  num_paused_threads = n;
  UnlockThreadControl();
  for (i=0; i<n; i++)
    PauseThread(i);
  return 1;
}

void ResumeAllThreads() {
  int i, n;
  n = num_paused_threads;
  for (i=0; i<n; i++) {
    ResumeThread(i);
  }
}

int LockObjects(int count, Obj *objects, int *mode)
{
  int result;
  int i;
  int locked;
  LockRequest *order;
  if (count > MAX_LOCKS)
    return -1;
  order = alloca(sizeof(LockRequest)*count);
  for (i=0; i<count; i++)
  {
    order[i].obj = objects[i];
    order[i].region = GetRegionOf(objects[i]);
    order[i].mode = mode[i];
  }
  MergeSort(order, count, sizeof(LockRequest), LessThanLockRequest);
  result = TLS->lockStackPointer;
  for (i=0; i<count; i++)
  {
    Region *ds = order[i].region;
    /* If there are multiple lock requests with different modes,
     * they have been sorted for writes to occur first, so deadlock
     * cannot occur from doing readlocks before writelocks.
     */
    if (i > 0 && ds == order[i-1].region)
      continue; /* skip duplicates */
    if (!ds || ds->fixed_owner) { /* public or thread-local region */
      PopRegionLocks(result);
      return -1;
    }
    locked = IsLocked(ds);
    if (locked == 2 && order[i].mode) {
      /* trying to upgrade read lock to write lock */
      PopRegionLocks(result);
      return -1;
    }
    if (!locked) {
      if (order[i].mode)
	RegionWriteLock(ds);
      else
	RegionReadLock(ds);
      PushRegionLock(ds);
    }
    if (GetRegionOf(order[i].obj) != ds)
    {
      /* Race condition, revert locks and fail */
      PopRegionLocks(result);
      return -1;
    }
  }
  return result;
}

int TryLockObjects(int count, Obj *objects, int *mode)
{
  int result;
  int i;
  int locked;
  LockRequest *order;
  if (count > MAX_LOCKS)
    return -1;
  order = alloca(sizeof(LockRequest)*count);
  for (i=0; i<count; i++)
  {
    order[i].obj = objects[i];
    order[i].region = GetRegionOf(objects[i]);
    order[i].mode = mode[i];
  }
  MergeSort(order, count, sizeof(LockRequest), LessThanLockRequest);
  result = TLS->lockStackPointer;
  for (i=0; i<count; i++)
  {
    Region *ds = order[i].region;
    /* If there are multiple lock requests with different modes,
     * they have been sorted for writes to occur first, so deadlock
     * cannot occur from doing readlocks before writelocks.
     */
    if (i > 0 && ds == order[i-1].region)
      continue; /* skip duplicates */
    if (!ds || ds->fixed_owner) { /* public or thread-local region */
      PopRegionLocks(result);
      return -1;
    }
    locked = IsLocked(ds);
    if (locked == 2 && order[i].mode) {
      /* trying to upgrade read lock to write lock */
      PopRegionLocks(result);
      return -1;
    }
    if (!locked) {
      if (order[i].mode) {
	if (!RegionTryWriteLock(ds)) {
	  PopRegionLocks(result);
	  return -1;
	}
      } else {
	if (!RegionTryReadLock(ds)) {
	  PopRegionLocks(result);
	  return -1;
	}
      }
      PushRegionLock(ds);
    }
    if (GetRegionOf(order[i].obj) != ds)
    {
      /* Race condition, revert locks and fail */
      PopRegionLocks(result);
      return -1;
    }
  }
  return result;
}

Region *CurrentRegion()
{
  return TLS->currentRegion;
}

void QueueForTraversal(Obj obj);

#define TRAVERSE_NONE (1)
#define TRAVERSE_ALL (-1)
#define TRAVERSE_ALL_BUT(n) (1 | ((-1) << (1+(n))))
#define TRAVERSE_BY_FUNCTION (0)

typedef void (*TraversalCopyFunction)(Obj copy, Obj original);

TraversalFunction TraversalFunc[LAST_REAL_TNUM+1];
TraversalCopyFunction TraversalCopyFunc[LAST_REAL_TNUM+1];
int TraversalMask[LAST_REAL_TNUM+1];

void TraversePList(Obj obj)
{
  UInt len = LEN_PLIST(obj);
  Obj *ptr = ADDR_OBJ(obj)+1;
  while (len)
  {
    QueueForTraversal(*ptr++);
    len--;
  }
}

static UInt FindTraversedObj(Obj);

static inline Obj ReplaceByCopy(Obj obj)
{
  Obj result;
  TraversalState *traversal = currentTraversal();
  UInt found = FindTraversedObj(obj);
  if (found)
    return ELM_PLIST(traversal->copyMap, found);
  else if (traversal->delimitedCopy) {
    if (!IS_BAG_REF(obj) || !DS_BAG(obj) || DS_BAG(obj) == traversal->dataSpace)
      return obj;
    else
      return GetRegionOf(obj)->obj;
  }
  else
    return obj;
}

void CopyPList(Obj copy, Obj original)
{
  UInt len = LEN_PLIST(original);
  Obj *ptr = ADDR_OBJ(original)+1;
  Obj *copyptr = ADDR_OBJ(copy)+1;
  while (len)
  {
    *copyptr++ = ReplaceByCopy(*ptr++);
    len--;
  }
}

void TraversePRecord(Obj obj)
{
  UInt i, len = LEN_PREC(obj);
  for (i=1; i<=len; i++)
    QueueForTraversal((Obj)GET_ELM_PREC(obj, i));
}

void CopyPRecord(Obj copy, Obj original)
{
  UInt i,len = LEN_PREC(original);
  for (i=1; i<=len; i++)
    SET_ELM_PREC(copy, i, ReplaceByCopy(GET_ELM_PREC(original, i)));
}

static void InitTraversal()
{
  int i;
  for (i=FIRST_CONSTANT_TNUM; i<=LAST_CONSTANT_TNUM; i++)
    TraversalMask[i] = TRAVERSE_NONE;
  TraversalMask[T_LVARS] = TRAVERSE_NONE;
  TraversalMask[T_PREC] = TRAVERSE_BY_FUNCTION;
  TraversalMask[T_PREC+IMMUTABLE] = TRAVERSE_BY_FUNCTION;
  TraversalFunc[T_PREC] = TraversePRecord;
  TraversalCopyFunc[T_PREC] = CopyPRecord;
  TraversalFunc[T_PREC+IMMUTABLE] = TraversePRecord;
  TraversalCopyFunc[T_PREC+IMMUTABLE] = CopyPRecord;
  for (i=FIRST_PLIST_TNUM; i<=LAST_PLIST_TNUM; i++)
  {
    TraversalMask[i] = TRAVERSE_BY_FUNCTION;
    TraversalFunc[i] = TraversePList;
    TraversalCopyFunc[i] = CopyPList;
  }
  TraversalMask[T_PLIST_CYC] = TRAVERSE_NONE;
  TraversalMask[T_PLIST_CYC_NSORT] = TRAVERSE_NONE;
  TraversalMask[T_PLIST_CYC_SSORT] = TRAVERSE_NONE;
  TraversalMask[T_PLIST_FFE] = TRAVERSE_NONE;
  for (i=LAST_PLIST_TNUM+1; i<=LAST_LIST_TNUM; i++)
    TraversalMask[i] = TRAVERSE_NONE;
  for (i=FIRST_EXTERNAL_TNUM; i<=LAST_EXTERNAL_TNUM; i++)
    TraversalMask[i] = TRAVERSE_NONE;
  TraversalMask[T_POSOBJ] = TRAVERSE_ALL_BUT(1);
  TraversalMask[T_COMOBJ] = TRAVERSE_BY_FUNCTION;
  TraversalFunc[T_COMOBJ] = TraversePRecord;
  TraversalCopyFunc[T_COMOBJ] = CopyPRecord;
  TraversalMask[T_DATOBJ] = TRAVERSE_NONE;
  for (i=FIRST_SHARED_TNUM; i<=LAST_SHARED_TNUM; i++)
    TraversalMask[i] = TRAVERSE_NONE;
}

static void BeginTraversal(TraversalState *traversal)
{
  traversal->hashTable = NewList(16);
  traversal->hashSize = 0;
  traversal->hashCapacity = 16;
  traversal->hashBits = 4;
  traversal->list = NewList(10);
  traversal->listSize = 0;
  traversal->listCapacity = 10;
  traversal->listCurrent = 0;
  traversal->previousTraversal = currentTraversal();
  TLS->traversalState = traversal;
}

static void EndTraversal()
{
  TLS->traversalState = currentTraversal()->previousTraversal;
}

#if SIZEOF_VOID_P == 4
#define TRAV_HASH_MULT 0x9e3779b9UL
#else
#define TRAV_HASH_MULT 0x9e3779b97f4a7c13UL
#endif
#define TRAV_HASH_BITS (SIZEOF_VOID_P * 8)

static void TraversalRehash();

static int SeenDuringTraversal(Obj obj)
{
  Int type;
  TraversalState *traversal = currentTraversal();
  Obj *hashTable;
  unsigned long hash;
  if (!IS_BAG_REF(obj))
    return 0;
  if (traversal->hashSize * 3 / 2 >= traversal->hashCapacity)
    TraversalRehash(traversal);
  hash = ((unsigned long) obj) * TRAV_HASH_MULT;
  hash >>= TRAV_HASH_BITS - traversal->hashBits;
  hashTable = ADDR_OBJ(traversal->hashTable)+1;
  for (;;)
  {
    if (hashTable[hash] == NULL)
    {
      hashTable[hash] = obj;
      traversal->hashSize++;
      return 1;
    }
    if (hashTable[hash] == obj)
      return 0;
    hash = (hash + 1) & (traversal->hashCapacity-1);
  }
}

static UInt FindTraversedObj(Obj obj)
{
  Int type;
  TraversalState *traversal = currentTraversal();
  Obj *hashTable = ADDR_OBJ(traversal->hashTable)+1;
  UInt hash;
  if (!IS_BAG_REF(obj))
    return 0;
  hash = ((UInt) obj) * TRAV_HASH_MULT;
  hash >>= TRAV_HASH_BITS - traversal->hashBits;
  for (;;)
  {
    if (hashTable[hash] == obj)
      return (int) hash+1;
    if (hashTable[hash] == NULL)
      return 0;
    hash = (hash + 1) & (traversal->hashCapacity-1);
  }
}

static void TraversalRehash(TraversalState *traversal)
{
  Obj list = NewList(traversal->hashCapacity * 2);
  int oldsize = traversal->hashCapacity;
  int i;
  Obj oldlist = traversal->hashTable;
  traversal->hashCapacity *= 2;
  traversal->hashTable = list;
  traversal->hashSize = 0;
  traversal->hashBits++;
  for (i = 1; i <= oldsize; i++)
  {
    Obj obj = ADDR_OBJ(oldlist)[i];
    if (obj != NULL)
      SeenDuringTraversal(obj);
  }
}

void QueueForTraversal(Obj obj)
{
  int i;
  TraversalState *traversal;
  if (!IS_BAG_REF(obj))
    return; /* skip ojects that aren't bags */
  traversal = currentTraversal();
  if (DS_BAG(obj) != traversal->dataSpace)
    return; /* stop traversal at the border of a region */
  if (!SeenDuringTraversal(obj))
    return; /* don't revisit objects that we've already seen */
  if (traversal->listSize == traversal->listCapacity)
  {
    unsigned oldcapacity = traversal->listCapacity;
    unsigned newcapacity = oldcapacity * 25/16; /* 25/16 < golden ratio */
    Obj oldlist = traversal->list;
    Obj list = NewList(newcapacity);
    for (i=1; i<=oldcapacity; i++)
      ADDR_OBJ(list)[i] = ADDR_OBJ(oldlist)[i];
    traversal->list = list;
    traversal->listCapacity = newcapacity;
  }
  ADDR_OBJ(traversal->list)[++traversal->listSize] = obj;
}

void TraverseRegionFrom(TraversalState *traversal, Obj obj)
{
  if (!IS_BAG_REF(obj) || !CheckRead(obj)) {
    traversal->list = NewList(0);
    return;
  }
  traversal->dataSpace = DS_BAG(obj);
  QueueForTraversal(obj);
  while (traversal->listCurrent < traversal->listSize)
  {
    Obj current = ADDR_OBJ(traversal->list)[++traversal->listCurrent];
    int tnum = TNUM_BAG(current);
    int mask = TraversalMask[TNUM_BAG(current)];
    if (!mask)
      TraversalFunc[tnum](current);
    else
    {
      int size = SIZE_BAG(current)/sizeof(Obj);
      Obj *ptr = PTR_BAG(current);
      mask >>= 1;
      while (mask && size)
      {
        if (mask & 1)
	  QueueForTraversal(*ptr);
	ptr++;
	size--;
	mask >>= 1;
      }
    }
  }
  SET_LEN_PLIST(traversal->list, traversal->listSize);
}

Obj ReachableObjectsFrom(Obj obj)
{
  TraversalState traversal;
  if (!IS_BAG_REF(obj) || DS_BAG(obj) == NULL)
    return NewList(0);
  BeginTraversal(&traversal);
  TraverseRegionFrom(&traversal, obj);
  EndTraversal();
  return traversal.list;
}

static Obj CopyBag(Obj copy, Obj original)
{
  UInt size = SIZE_BAG(original);
  UInt type = TNUM_BAG(original);
  int mask = TraversalMask[type];
  memcpy(ADDR_OBJ(copy), ADDR_OBJ(original), size);
  if (mask)
  {
    Obj *ptr = ADDR_OBJ(copy);
    size = size / sizeof(Obj);
    mask >>= 1;
    while (size && mask)
    {
      if (mask & 1)
        *ptr = ReplaceByCopy(*ptr);
      ptr++;
      size -= 1;
      mask >>= 1;
    }
  } else {
    TraversalCopyFunc[type](copy, original);
  }
  return copy;
}

Obj CopyReachableObjectsFrom(Obj obj, int delimited, int asList)
{
  Obj *traversed, *copies, copyList;
  TraversalState traversal;
  UInt len, i;
  if (!IS_BAG_REF(obj) || DS_BAG(obj) == NULL)
  {
    if (asList) {
      copyList = NewList(1);
      SET_ELM_PLIST(copyList, 1, obj);
      return copyList;
    } else
      return obj;
  }
  BeginTraversal(&traversal);
  TraverseRegionFrom(&traversal, obj);
  traversed = ADDR_OBJ(traversal.list);
  len = LEN_PLIST(traversal.list);
  copyList = NewList(len);
  copies = ADDR_OBJ(copyList);
  traversal.delimitedCopy = delimited;
  if (len == 0) {
    EndTraversal();
    if (delimited)
      return GetRegionOf(obj)->obj;
    ErrorQuit("Object not in a readable region", 0L, 0L);
  }
  traversal.copyMap = NewList(LEN_PLIST(traversal.hashTable));
  for (i = 1; i<=len; i++) {
    UInt loc = FindTraversedObj(traversed[i]);
    if (loc) {
      Obj original = traversed[i];
      Obj copy;
      copy = NewBag(TNUM_BAG(original), SIZE_BAG(original));
      SET_ELM_PLIST(traversal.copyMap, loc, copy);
      copies[i] = copy;
    }
  }
  for (i=1; i<=len; i++)
    if (copies[i])
      CopyBag(copies[i], traversed[i]);
  EndTraversal();
  if (asList)
    return copyList;
  else
    return copies[1];
}

Obj CopyTraversed(Obj traversedList)
{
  Obj copyList, *copies, *traversed;
  TraversalState traversal;
  UInt len, i;
  traversed = ADDR_OBJ(traversedList);
  BeginTraversal(&traversal);
  len = LEN_PLIST(traversedList);
  if (len == 1) {
    Obj obj = traversed[1];
    if (!IS_BAG_REF(obj) || DS_BAG(obj) == NULL)
      return obj;
  }
  for (i=1; i<=len; i++)
    SeenDuringTraversal(traversed[i]);
  copyList = NewList(len);
  copies = ADDR_OBJ(copyList);
  traversal.copyMap = NewList(LEN_PLIST(traversal.hashTable));
  for (i=1; i<=len; i++) {
    Obj original = traversed[i];
    UInt loc = FindTraversedObj(original);
    Obj copy;
    copy = NewBag(TNUM_BAG(original), SIZE_BAG(original));
    SET_ELM_PLIST(traversal.copyMap, loc, copy);
    copies[i] = copy;
  }
  for (i=1; i<=len; i++)
    CopyBag(copies[i], traversed[i]);
  EndTraversal();
  return copies[1];
}

extern GVarDescriptor LastInaccessibleGVar, DisableGuardsGVar;

#ifdef VERBOSE_GUARDS

static void PrintGuardError(char *buffer, char *mode,
  Obj obj, char *file, unsigned line, char *func, char *expr)
{
  sprintf(buffer, "No %s access to object %lu of type %s\n"
    "in %s, line %u, function %s(), accessing %s",
      mode, (UInt) obj, TNAM_OBJ(obj),
      file, line, func, expr);
}
void WriteGuardError(Obj o, char *file, unsigned line, char *func, char *expr)
{
  char * buffer =
    alloca(strlen(file) + strlen(func) + strlen(expr) + 200);
  ImpliedReadGuard(o);
  if (GVarValue(&DisableGuardsGVar) == True)
    return;
  SetGVar(&LastInaccessibleGVar, o);
  PrintGuardError(buffer, "write", o, file, line, func, expr);
  ErrorMayQuit("%s", (UInt) buffer, 0L);
}

void ReadGuardError(Obj o, char *file, unsigned line, char *func, char *expr)
{
  char * buffer =
    alloca(strlen(file) + strlen(func) + strlen(expr) + 200);
  ImpliedReadGuard(o);
  if (GVarValue(&DisableGuardsGVar) == True)
    return;
  SetGVar(&LastInaccessibleGVar, o);
  PrintGuardError(buffer, "read", o, file, line, func, expr);
  ErrorMayQuit("%s", (UInt) buffer, 0L);
}

#else
void WriteGuardError(Obj o)
{
  ImpliedReadGuard(o);
  if (GVarValue(&DisableGuardsGVar) == True)
    return;
  SetGVar(&LastInaccessibleGVar, o);
  ErrorMayQuit("Attempt to write object %i of type %s without having write access", (Int)o, (Int)TNAM_OBJ(o));
}

void ReadGuardError(Obj o)
{
  ImpliedReadGuard(o);
  if (GVarValue(&DisableGuardsGVar) == True)
    return;
  SetGVar(&LastInaccessibleGVar, o);
  ErrorMayQuit("Attempt to read object %i of type %s without having read access", (Int)o, (Int)TNAM_OBJ(o));
}
#endif

#endif
