#include <src/hpc/systhread.h>          /* system thread primitives */
#include <src/system.h>
#include <src/gapstate.h>
#include <src/gasman.h>
#include <src/objects.h>
#include <src/bool.h>
#include <src/gvars.h>
#include <src/scanner.h>
#include <src/code.h>
#include <src/plist.h>
#include <src/stringobj.h>
#include <src/precord.h>
#include <src/stats.h>
#include <src/gap.h>
#include <src/hpc/misc.h>
#include <src/hpc/tls.h>
#include <src/hpc/thread.h>
#include <src/hpc/threadapi.h>
#include <src/fibhash.h>

#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>

#ifdef BOEHM_GC
# ifdef HPCGAP
#  define GC_THREADS
# endif
# include <gc/gc.h>
#endif


#define LOG2_NUM_LOCKS 11
#define NUM_LOCKS (1 << LOG2_NUM_LOCKS)

#ifndef WARD_ENABLED

typedef struct ThreadData {
  pthread_t pthread_id;
  pthread_mutex_t *lock;
  pthread_cond_t *cond;
  int joined;
  int system;
  AtomicUInt state;
  void *tls;
  void (*start)(void *);
  void *arg;
  Obj thread_object;
  Obj region_name;
  struct ThreadData *next;
} ThreadData;

Region *LimboRegion, *ReadOnlyRegion;
Obj PublicRegion;
Obj PublicRegionName;

static int GlobalPauseInProgress;
static AtomicUInt ThreadCounter = 1;

static inline void IncThreadCounter() {
  ATOMIC_INC(&ThreadCounter);
}

static inline void DecThreadCounter() {
  ATOMIC_DEC(&ThreadCounter);
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
  void *p = realTLS;
  GC_add_roots(p, (char *)p + sizeof(ThreadLocalStorage));
}

void RemoveGCRoots()
{
  void *p = realTLS;
#if defined(__CYGWIN__) || defined(__CYGWIN32__)
  memset(p, '\0', sizeof(ThreadLocalStorage));
#else
  GC_remove_roots(p, (char *)p + sizeof(ThreadLocalStorage));
#endif
}
#endif /* DISABLE_GC */

#ifdef __GNUC__
static void SetupTLS() __attribute__((noinline));
static void GrowStack() __attribute__((noinline));
#endif

#ifndef HAVE_NATIVE_TLS

/* In order to safely use thread-local memory on the main stack, we have
 * to work around an idiosyncracy in some virtual memory systems. These
 * VM implementations do not allow fully random access within the stack
 * segment, but only quasi-linear access: a page can only be accessed if
 * a nearby page was accessed before. If this pattern is not observed,
 * but if we access memory within the stack segment randomly -- as in
 * our TLS implementation, but also with very large stack frames -- a
 * segmentation fault can arise. To avoid such segmentation faults, we
 * traverse the stack segment of the main stack, touching each page in
 * turn.
 *
 * Note that this is not necessary for thread stacks, which are
 * allocated in private memory-mapped storage.
 */

static void GrowStack()
{
  char *tls = (char *) realTLS;
  size_t pagesize = getpagesize();
  /* p needs to be a volatile pointer so that the memory writes are not
   * removed by the optimizer */
  volatile char *p = alloca(pagesize);
  while (p > tls)
  {
    /* touch memory */
    *p = '\0';
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
  MainThreadTLS = realTLS;
  TLS(threadID) = 0;
}

Obj NewThreadObject(UInt id) {
  Obj result = NewBag(T_THREAD, 3*sizeof(UInt));
  ADDR_OBJ(result)[0] = (Bag) 0;
  ADDR_OBJ(result)[1] = (Bag) id;
  ADDR_OBJ(result)[2] = (Bag) 0;
  return result;
}

void InitMainThread()
{
  TLS(threadObject) = NewThreadObject(0);
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
  /* We need to ensure that the stack pointer and frame pointer
   * of the called function begin at the top end of a memory
   * segment whose beginning and end address are a multiple of
   * TLS_SIZE (which is a power of 2). To that end, we look at
   * an approximation of the current stack pointer by taking
   * the address of a local variable, then mask out the lowest
   * bits and use alloca() to allocate at least that many bytes
   * on the stack. We also need to touch the pages in that area;
   * see the comments on GrowStack() for the reason why.
   */
  volatile int dummy[1];
  size_t amount;
  amount = ((uintptr_t) dummy) & ~TLS_MASK;
  volatile char *p = alloca(((uintptr_t) dummy) &~TLS_MASK);
  volatile char *q;
  for (q = p + amount - 1; (void *)q >= (void *)p; q -= 1024) {
    /* touch memory */
    *q = '\0';
  }
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
  void InitTraversal();
  int i;
  static pthread_mutex_t main_thread_mutex;
  static pthread_cond_t main_thread_cond;
  void InitTraversalModule();
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
  TLS(threadLock) = &main_thread_mutex;
  TLS(threadSignal) = &main_thread_cond;
  thread_data[0].lock = TLS(threadLock);
  thread_data[0].cond = TLS(threadSignal);
  thread_data[0].state = TSTATE_RUNNING;
  thread_data[0].tls = realTLS;
  InitSignals();
  if (sySetjmp(TLS(threadExit)))
    exit(0);
  /* Traversal functionality may be needed during the initialization
   * of some modules, so we set it up now. */
  InitTraversalModule();
  exit((*mainFunction)(argc, argv, environ));
}

void CreateMainRegion()
{
  int i;
  TLS(currentRegion) = NewRegion();
  TLS(threadRegion) = TLS(currentRegion);
  ((Region *)TLS(currentRegion))->fixed_owner = 1;
  RegionWriteLock(TLS(currentRegion));
  ((Region *)TLS(currentRegion))->name = MakeImmString("thread region #0");
  PublicRegionName = MakeImmString("public region");
  LimboRegion = NewRegion();
  LimboRegion->fixed_owner = 1;
  LimboRegion->name = MakeImmString("limbo region");
  ReadOnlyRegion = NewRegion();
  ReadOnlyRegion->name = MakeImmString("read-only region");
  ReadOnlyRegion->fixed_owner = 1;
  for (i=0; i<=MAX_THREADS; i++) {
    ReadOnlyRegion->readers[i] = 1;
  }
}

void *DispatchThread(void *arg)
{
  ThreadData *this_thread = arg;
  Region *region;
  InitializeTLS();
  TLS(threadID) = this_thread - thread_data;
#ifndef DISABLE_GC
  AddGCRoots();
#endif
  InitTLS();
  TLS(currentRegion) = region = NewRegion();
  TLS(threadRegion) = TLS(currentRegion);
  TLS(threadLock) = this_thread->lock;
  TLS(threadSignal) = this_thread->cond;
  region->fixed_owner = 1;
  region->name = this_thread->region_name;
  RegionWriteLock(region);
  if (!this_thread->region_name) {
    char buf[8];
    sprintf(buf, "%d", TLS(threadID));
    this_thread->region_name = MakeImmString2("thread #", buf);
  }
  SetRegionName(region, this_thread->region_name);
  TLS(threadObject) = this_thread->thread_object;
  pthread_mutex_lock(this_thread->lock);
  *(ThreadLocalStorage **)(ADDR_OBJ(TLS(threadObject))) = realTLS;
  pthread_cond_broadcast(this_thread->cond);
  pthread_mutex_unlock(this_thread->lock);
  this_thread->start(this_thread->arg);
  *(UInt *)(ADDR_OBJ(TLS(threadObject))+2) |= THREAD_TERMINATED;
  region->fixed_owner = 0;
  RegionWriteUnlock(region);
  DestroyTLS();
  memset(realTLS, 0, sizeof(ThreadLocalStorage));
#ifndef DISABLE_GC
  RemoveGCRoots();
#endif
  this_thread->state = TSTATE_TERMINATED;
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
#if CUSTOM_OBJECT_HASH
  UInt p = (UInt) object;
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
  if (TLS(CurrentHashLock))
    ErrorQuit("Nested hash locks", 0L, 0L);
  TLS(CurrentHashLock) = object;
  pthread_rwlock_wrlock(&ObjLock[LockID(object)]);
}

void HashLockShared(void *object) {
  if (TLS(CurrentHashLock))
    ErrorQuit("Nested hash locks", 0L, 0L);
  TLS(CurrentHashLock) = object;
  pthread_rwlock_rdlock(&ObjLock[LockID(object)]);
}

void HashUnlock(void *object) {
  if (TLS(CurrentHashLock) != object)
    ErrorQuit("Improperly matched hash lock/unlock calls", 0L, 0L);
  TLS(CurrentHashLock) = 0;
  pthread_rwlock_unlock(&ObjLock[LockID(object)]);
}

void HashUnlockShared(void *object) {
  if (TLS(CurrentHashLock) != object)
    ErrorQuit("Improperly matched hash lock/unlock calls", 0L, 0L);
  TLS(CurrentHashLock) = 0;
  pthread_rwlock_unlock(&ObjLock[LockID(object)]);
}

void RegionWriteLock(Region *region)
{
  int result = 0;
  assert(region->owner != realTLS);

  if (region->count_active || TLS(CountActive)) {
    result = !pthread_rwlock_trywrlock(region->lock);

    if(result) {
      if(region->count_active)
	region->locks_acquired++;
      if(TLS(CountActive))
	TLS(LocksAcquired)++;
    } else {
      if(region->count_active)
	region->locks_contended++;
      if(TLS(CountActive))
	TLS(LocksContended)++;
      pthread_rwlock_wrlock(region->lock);
    }
  } else {
    pthread_rwlock_wrlock(region->lock);
  }

  region->owner = realTLS;
}

int RegionTryWriteLock(Region *region)
{
  int result;
  assert(region->owner != realTLS);
  result = !pthread_rwlock_trywrlock(region->lock);

  if (result) {
    if(region->count_active)
      region->locks_acquired++;
    if(TLS(CountActive))
      TLS(LocksAcquired)++;
    region->owner = realTLS;
  } else {
    if(region->count_active)
      region->locks_contended++;
    if(TLS(CountActive))
      TLS(LocksContended)++;
  }
  return result;
}

void RegionWriteUnlock(Region *region)
{
  assert(region->owner == realTLS);
  region->owner = NULL;
  pthread_rwlock_unlock(region->lock);
}

void RegionReadLock(Region *region)
{
  int result = 0;
  assert(region->owner != realTLS);
  assert(region->readers[TLS(threadID)] == 0);

  if(region->count_active || TLS(CountActive)) {
    result = !pthread_rwlock_rdlock(region->lock);

    if(result) {
      if(region->count_active)
	ATOMIC_INC(&region->locks_acquired);
      if(TLS(CountActive))
	TLS(LocksAcquired)++;
    } else {
      if(region->count_active)
	ATOMIC_INC(&region->locks_contended);
      if(TLS(CountActive))
	TLS(LocksAcquired)++;
      pthread_rwlock_rdlock(region->lock);
    }
  } else {
      pthread_rwlock_rdlock(region->lock);
  }
  region->readers[TLS(threadID)] = 1;
}

int RegionTryReadLock(Region *region)
{
  int result = !pthread_rwlock_rdlock(region->lock);
  assert(region->owner != realTLS);
  assert(region->readers[TLS(threadID)] == 0);

  if (result) {
    if(region->count_active)
      ATOMIC_INC(&region->locks_acquired);
    if(TLS(CountActive))
      TLS(LocksAcquired)++;
    region->readers[TLS(threadID)] = 1;
  } else {
    if(region->count_active)
      ATOMIC_INC(&region->locks_contended);
    if(TLS(CountActive))
      TLS(LocksContended)++;
  }
  return result;
}

void RegionReadUnlock(Region *region)
{
  assert(region->readers[TLS(threadID)]);
  region->readers[TLS(threadID)] = 0;
  pthread_rwlock_unlock(region->lock);
}

void RegionUnlock(Region *region)
{
  assert(region->owner == realTLS || region->readers[TLS(threadID)]);
  if (region->owner == realTLS)
    region->owner = NULL;
  region->readers[TLS(threadID)] = 0;
  pthread_rwlock_unlock(region->lock);
}

int IsLocked(Region *region)
{
  if (!region)
    return 0; /* public region */
  if (region->owner == realTLS)
    return 1;
  if (region->readers[TLS(threadID)])
    return 2;
  return 0;
}

Region *GetRegionOf(Obj obj)
{
  if (!IS_BAG_REF(obj))
    return NULL;
  if (TNUM_OBJ(obj) == T_REGION)
    return *(Region **)(ADDR_OBJ(obj));
  return REGION(obj);
}

void SetRegionName(Region *region, Obj name)
{
  if (name) {
    if (!IS_STRING(name))
      return;
    if (IS_MUTABLE_OBJ(name))
      name = CopyObj(name, 0);
  }
  MEMBAR_WRITE();
  region->name = name;
}

Obj GetRegionName(Region *region)
{
  Obj result;
  if (region)
    result = region->name;
  else
    result = PublicRegionName;
  MEMBAR_READ();
  return result;
}

void GetLockStatus(int count, Obj *objects, int *status)
{
  int i;
  for (i=0; i<count; i++)
    status[i] = IsLocked(REGION(objects[i]));
}

static Obj NewList(UInt size)
{
  Obj list;
  list = NEW_PLIST(size == 0 ? T_PLIST_EMPTY : T_PLIST, size);
  SET_LEN_PLIST(list, size);
  return list;
}

Obj GetRegionLockCounters(Region *region)
{
  Obj result = NewList(2);

  if (region) {
    SET_ELM_PLIST(result,1,INTOBJ_INT(region->locks_acquired));
    SET_ELM_PLIST(result,2,INTOBJ_INT(region->locks_contended));
  }
  MEMBAR_READ();
  return result;
}

void ResetRegionLockCounters(Region *region)
{
  if (region) {
      region->locks_acquired
      = region->locks_contended
      = 0;
  }
  MEMBAR_WRITE();
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
  Region *region_a = ((LockRequest *)a)->region;
  Region *region_b = ((LockRequest *)b)->region;
  Int prec_diff;
  if (region_a == region_b) /* prioritize writes */
    return ((LockRequest *)a)->mode>((LockRequest *)b)->mode;
  prec_diff = region_a->prec - region_b->prec;
  return prec_diff > 0 || (prec_diff == 0 && (char *)region_a < (char *)region_b);
}

void PushRegionLock(Region *region) {
  if (!TLS(lockStack)) {
    TLS(lockStack) = NewList(16);
    TLS(lockStackPointer) = 0;
  } else if (LEN_PLIST(TLS(lockStack)) == TLS(lockStackPointer)) {
    int newlen = TLS(lockStackPointer) * 3 / 2;
    GROW_PLIST(TLS(lockStack), newlen);
  }
  TLS(lockStackPointer)++;
  SET_ELM_PLIST(TLS(lockStack), TLS(lockStackPointer),
    region ? region->obj : (Obj) 0);
}

void PopRegionLocks(int newSP) {
  while (newSP < TLS(lockStackPointer))
  {
    int p = TLS(lockStackPointer)--;
    Obj region_obj = ELM_PLIST(TLS(lockStack), p);
    if (!region_obj)
      continue;
    Region *region = *(Region **)(ADDR_OBJ(region_obj));
    RegionUnlock(region);
    SET_ELM_PLIST(TLS(lockStack), p, (Obj) 0);
  }
}

int RegionLockSP() {
  return TLS(lockStackPointer);
}

int GetThreadState(int threadID) {
  return (int)(thread_data[threadID].state);
}

int UpdateThreadState(int threadID, int oldState, int newState) {
  return COMPARE_AND_SWAP(&thread_data[threadID].state,
    (AtomicUInt) oldState, (AtomicUInt) newState);
}

static void SetInterrupt(int threadID) {
  ThreadLocalStorage *tls = thread_data[threadID].tls;
  MEMBAR_FULL();
  tls->state.CurrExecStatFuncs = IntrExecStatFuncs;
}

static int LockAndUpdateThreadState(int threadID, int oldState, int newState) {
  if (pthread_mutex_trylock(thread_data[threadID].lock) < 0) {
    return 0;
  }
  if (!UpdateThreadState(threadID, oldState, newState)) {
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
          TSTATE_RUNNING, TSTATE_PAUSED|(TLS(threadID) << TSTATE_SHIFT))) {
	SetInterrupt(threadID);
        return;
      }
      break;
    case TSTATE_BLOCKED:
    case TSTATE_SYSCALL:
      if (LockAndUpdateThreadState(threadID,
          state, TSTATE_PAUSED|(TLS(threadID) << TSTATE_SHIFT)))
	return;
      break;
    case TSTATE_PAUSED:
    case TSTATE_TERMINATED:
    case TSTATE_KILLED:
    case TSTATE_INTERRUPTED:
      return;
    }
  }
}

static void TerminateCurrentThread(int locked) {
  ThreadData *thread = thread_data + TLS(threadID);
  if (locked)
    pthread_mutex_unlock(thread->lock);
  PopRegionLocks(0);
  if (TLS(CurrentHashLock))
    HashUnlock(TLS(CurrentHashLock));
  syLongjmp(&(TLS(threadExit)), 1);
}

static void PauseCurrentThread(int locked) {
  ThreadData *thread = thread_data + TLS(threadID);
  if (!locked)
    pthread_mutex_lock(thread->lock);
  for (;;) {
    int state = GetThreadState(TLS(threadID));
    if ((state & TSTATE_MASK) == TSTATE_KILLED)
      TerminateCurrentThread(1);
    if ((state & TSTATE_MASK) != TSTATE_PAUSED)
      break;
    ((Region *)(TLS(currentRegion)))->alt_owner =
      thread_data[state >> TSTATE_SHIFT].tls;
    pthread_cond_wait(thread->cond, thread->lock);
    // TODO: This really should go in ResumeThread()
    ((Region *)(TLS(currentRegion)))->alt_owner = NULL;
  }
  if (!locked)
    pthread_mutex_unlock(thread->lock);
}

static void InterruptCurrentThread(int locked, Stat stat) {
  ThreadData *thread = thread_data + TLS(threadID);
  int state;
  Obj FuncCALL_WITH_CATCH(Obj self, Obj func, Obj args);
  Obj handler = (Obj) 0;
  if (stat == T_NO_STAT)
    return;
  if (!locked)
    pthread_mutex_lock(thread->lock);
  STATE(CurrExecStatFuncs) = ExecStatFuncs;
  SET_BRK_CURR_STAT(stat);
  state = GetThreadState(TLS(threadID));
  if ((state & TSTATE_MASK) == TSTATE_INTERRUPTED)
    UpdateThreadState(TLS(threadID), state, TSTATE_RUNNING);
  if (state >> TSTATE_SHIFT) {
    Int n = state >> TSTATE_SHIFT;
    if (TLS(interruptHandlers)) {
      if (n >= 1 && n <= LEN_PLIST(TLS(interruptHandlers)))
        handler = ELM_PLIST(TLS(interruptHandlers), n);
    }
  }
  if (handler)
    FuncCALL_WITH_CATCH((Obj) 0, handler, NEW_PLIST(T_PLIST, 0));
  else
    ErrorReturnVoid("system interrupt", 0L, 0L, "you can 'return;'");
  if (!locked)
    pthread_mutex_unlock(thread->lock);
}

void SetInterruptHandler(int handler, Obj func) {
  if (!TLS(interruptHandlers)) {
    TLS(interruptHandlers) = NEW_PLIST(T_PLIST, MAX_INTERRUPT);
    SET_LEN_PLIST(TLS(interruptHandlers), MAX_INTERRUPT);
  }
  SET_ELM_PLIST(TLS(interruptHandlers), handler, func);
}

void HandleInterrupts(int locked, Stat stat) {
   switch (GetThreadState(TLS(threadID)) & TSTATE_MASK) {
     case TSTATE_PAUSED:
       PauseCurrentThread(locked);
       break;
     case TSTATE_INTERRUPTED:
       InterruptCurrentThread(locked, stat);
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
    case TSTATE_INTERRUPTED:
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

void InterruptThread(int threadID, int handler) {
  for (;;) {
    int state = GetThreadState(threadID);
    switch (state & TSTATE_MASK) {
    case TSTATE_RUNNING:
      if (UpdateThreadState(threadID, TSTATE_RUNNING,
        TSTATE_INTERRUPTED | (handler << TSTATE_SHIFT))) {
	SetInterrupt(threadID);
        return;
      }
      break;
    case TSTATE_BLOCKED:
      if (LockAndUpdateThreadState(threadID, state,
        TSTATE_INTERRUPTED | (handler << TSTATE_SHIFT)))
        return;
      break;
    case TSTATE_SYSCALL:
      if (UpdateThreadState(threadID, state,
        TSTATE_INTERRUPTED | (handler << TSTATE_SHIFT)))
        return;
      break;
    case TSTATE_PAUSED:
    case TSTATE_TERMINATED:
    case TSTATE_KILLED:
    case TSTATE_INTERRUPTED:
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

/**
 *  Deadlock checks
 *  ---------------
 *
 *  We use a scheme of numerical tiers to implement deadlock checking.
 *  Each region is assigned a numerical precedence, and regions must
 *  be locked in strictly descending numerical order. If this order
 *  is inverted, or if two regions of the same precedence are locked
 *  through separate actions, then this is an error.
 *
 *  Regions with negative precedence are ignored for these tests. This
 *  is to facilitate more complex precedence schemes that cannot be
 *  embedded in a total ordering.
 */

static Int CurrentRegionPrecedence() {
  Int sp;
  if (!DeadlockCheck || !TLS(lockStack))
    return -1;
  sp = TLS(lockStackPointer);
  while (sp > 0) {
    Obj region_obj = ELM_PLIST(TLS(lockStack), sp);
    if (region_obj) {
      Int prec = ((Region *)(*ADDR_OBJ(region_obj)))->prec;
      if (prec >= 0)
        return prec;
    }
    sp--;
  }
  return -1;
}

int LockObject(Obj obj, int mode) {
  Region *region = GetRegionOf(obj);
  int locked;
  int result = TLS(lockStackPointer);
  if (!region)
    return result;
  locked = IsLocked(region);
  if (locked == 2 && mode)
    return -1;
  if (!locked) {
    Int prec = CurrentRegionPrecedence();
    if (prec >= 0 && region->prec >= prec && region->prec >= 0)
      return -1;
    if (region->fixed_owner)
      return -1;
    if (mode)
      RegionWriteLock(region);
    else
      RegionReadLock(region);
    PushRegionLock(region);
  }
  return result;
}

int LockObjects(int count, Obj *objects, int *mode)
{
  int result;
  int i, p;
  int locked;
  Int curr_prec;
  LockRequest *order;
  if (count == 1) /* fast path */
    return LockObject(objects[0], mode[0]);
  if (count > MAX_LOCKS)
    return -1;
  order = alloca(sizeof(LockRequest)*count);
  for (i=0, p=0; i<count; i++)
  {
    Region *r = GetRegionOf(objects[i]);
    if (r) {
      order[p].obj = objects[i];
      order[p].region = GetRegionOf(objects[i]);
      order[p].mode = mode[i];
      p++;
    }
  }
  count = p;
  if (p > 1)
    MergeSort(order, count, sizeof(LockRequest), LessThanLockRequest);
  result = TLS(lockStackPointer);
  curr_prec = CurrentRegionPrecedence();
  for (i=0; i<count; i++)
  {
    Region *region = order[i].region;
    /* If there are multiple lock requests with different modes,
     * they have been sorted for writes to occur first, so deadlock
     * cannot occur from doing readlocks before writelocks.
     */
    if (i > 0 && region == order[i-1].region)
      continue; /* skip duplicates */
    if (!region)
      continue;
    locked = IsLocked(region);
    if (locked == 2 && order[i].mode) {
      /* trying to upgrade read lock to write lock */
      PopRegionLocks(result);
      return -1;
    }
    if (!locked) {
      if (curr_prec >= 0 && region->prec >= curr_prec && region->prec >= 0) {
	PopRegionLocks(result);
	return -1;
      }
      if (region->fixed_owner) {
	PopRegionLocks(result);
	return -1;
      }
      if (order[i].mode)
	RegionWriteLock(region);
      else
	RegionReadLock(region);
      PushRegionLock(region);
    }
    if (GetRegionOf(order[i].obj) != region)
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
  result = TLS(lockStackPointer);
  for (i=0; i<count; i++)
  {
    Region *region = order[i].region;
    /* If there are multiple lock requests with different modes,
     * they have been sorted for writes to occur first, so deadlock
     * cannot occur from doing readlocks before writelocks.
     */
    if (i > 0 && region == order[i-1].region)
      continue; /* skip duplicates */
    if (!region || region->fixed_owner) { /* public or thread-local region */
      PopRegionLocks(result);
      return -1;
    }
    locked = IsLocked(region);
    if (locked == 2 && order[i].mode) {
      /* trying to upgrade read lock to write lock */
      PopRegionLocks(result);
      return -1;
    }
    if (!locked) {
      if (order[i].mode) {
	if (!RegionTryWriteLock(region)) {
	  PopRegionLocks(result);
	  return -1;
	}
      } else {
	if (!RegionTryReadLock(region)) {
	  PopRegionLocks(result);
	  return -1;
	}
      }
      PushRegionLock(region);
    }
    if (GetRegionOf(order[i].obj) != region)
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
  return TLS(currentRegion);
}

extern GVarDescriptor LastInaccessibleGVar;

#ifdef VERBOSE_GUARDS

static void PrintGuardError(char *buffer, char *mode,
  Obj obj, const char *file, unsigned line, const char *func, const char *expr)
{
  sprintf(buffer, "No %s access to object %llu of type %s\n"
    "in %s, line %u, function %s(), accessing %s",
      mode, (unsigned long long) (UInt) obj, TNAM_OBJ(obj),
      file, line, func, expr);
}
void WriteGuardError(Obj o, const char *file, unsigned line,
                     const char *func, const char *expr)
{
  char * buffer =
    alloca(strlen(file) + strlen(func) + strlen(expr) + 200);
  ImpliedReadGuard(o);
  if (TLS(DisableGuards))
    return;
  SetGVar(&LastInaccessibleGVar, o);
  PrintGuardError(buffer, "write", o, file, line, func, expr);
  ErrorMayQuit("%s", (UInt) buffer, 0L);
}

void ReadGuardError(Obj o, const char *file, unsigned line,
                    const char *func, const char *expr)
{
  char * buffer =
    alloca(strlen(file) + strlen(func) + strlen(expr) + 200);
  ImpliedReadGuard(o);
  if (TLS(DisableGuards))
    return;
  SetGVar(&LastInaccessibleGVar, o);
  PrintGuardError(buffer, "read", o, file, line, func, expr);
  ErrorMayQuit("%s", (UInt) buffer, 0L);
}

#else
void WriteGuardError(Obj o)
{
  ImpliedReadGuard(o);
  if (TLS(DisableGuards))
    return;
  SetGVar(&LastInaccessibleGVar, o);
  ErrorMayQuit("Attempt to write object %i of type %s without having write access", (Int)o, (Int)TNAM_OBJ(o));
}

void ReadGuardError(Obj o)
{
  ImpliedReadGuard(o);
  if (TLS(DisableGuards))
    return;
  SetGVar(&LastInaccessibleGVar, o);
  ErrorMayQuit("Attempt to read object %i of type %s without having read access", (Int)o, (Int)TNAM_OBJ(o));
}
#endif

#endif
