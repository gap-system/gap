/****************************************************************************
**
*W  threadapi.c                 GAP source                    Reimer Behrends
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the GAP interface for thread primitives.
*/
#include        <stdio.h>
#include        <assert.h>
#include        <setjmp.h>              /* jmp_buf, setjmp, longjmp        */
#include        <string.h>              /* memcpy */
#include        <stdlib.h>
#include        <signal.h>
#include        <sys/time.h>

#include        "systhread.h"           /* system thread primitives        */

#include        "system.h"              /* system dependent part           */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "read.h"                /* reader                          */
#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */
#include        "ariths.h"              /* basic arithmetic                */

#include        "integer.h"             /* integers                        */
#include        "bool.h"                /* booleans                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "listoper.h"            /* operations for generic lists    */
#include        "listfunc.h"            /* functions for generic lists     */
#include        "plist.h"               /* plain lists                     */
#include        "set.h"                 /* set                             */
#include        "stringobj.h"              /* strings                         */

#include        "code.h"                /* coder                           */

#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */
#include        "funcs.h"               /* functions                       */

#include        "hpc/thread.h"
#include        "traverse.h"
#include        "hpc/tls.h"
#include        "threadapi.h"

#include        "vars.h"                /* variables                       */

#include        "intrprtr.h"            /* interpreter                     */

#include        "compiler.h"            /* compiler                        */

struct WaitList {
  struct WaitList *prev;
  struct WaitList *next;
  ThreadLocalStorage *thread;
};

typedef struct Channel
{
  Obj monitor;
  Obj queue;
  int waiting;
  int dynamic;
  UInt head, tail;
  UInt size, capacity;
} Channel;

typedef struct Semaphore
{
  Obj monitor;
  UInt count;
  int waiting;
} Semaphore;

typedef struct Barrier
{
  Obj monitor;
  UInt count;
  UInt phase;
  int waiting;
} Barrier;

typedef struct SyncVar
{
  Obj monitor;
  Obj value;
  int written;
} SyncVar;


static void AddWaitList(Monitor *monitor, struct WaitList *node)
{
  if (monitor->tail)
  {
    monitor->tail->next = node;
    node->prev = monitor->tail;
    node->next = NULL;
    monitor->tail = node;
  }
  else
  {
    monitor->head = monitor->tail = node;
    node->next = node->prev = NULL;
  }
}

static void RemoveWaitList(Monitor *monitor, struct WaitList *node)
{
  if (monitor->head)
  {
    if (node->prev)
      node->prev->next = node->next;
    else
      monitor->head = node->next;
    if (node->next)
      node->next->prev = node->prev;
    else
      monitor->tail = node->prev;
  }
}

static inline void *ObjPtr(Obj obj)
{
  return PTR_BAG(obj);
}

Obj NewMonitor()
{
  Bag monitorBag;
  Monitor *monitor;
  monitorBag = NewBag(T_MONITOR, sizeof(Monitor));
  monitor = ObjPtr(monitorBag);
  pthread_mutex_init(&monitor->lock, 0);
  monitor->head = monitor->tail = NULL;
  return monitorBag;
}

void LockThread(ThreadLocalStorage *thread)
{
  pthread_mutex_lock(thread->threadLock);
}

void UnlockThread(ThreadLocalStorage *thread)
{
  pthread_mutex_unlock(thread->threadLock);
}

void SignalThread(ThreadLocalStorage *thread)
{
  pthread_cond_signal(thread->threadSignal);
}

void WaitThreadSignal()
{
  int id = TLS(threadID);
  if (!UpdateThreadState(id, TSTATE_RUNNING, TSTATE_BLOCKED))
    HandleInterrupts(1, T_NO_STAT);
  pthread_cond_wait(TLS(threadSignal), TLS(threadLock));
  if (!UpdateThreadState(id, TSTATE_BLOCKED, TSTATE_RUNNING) &&
    GetThreadState(id) != TSTATE_RUNNING)
    HandleInterrupts(1, T_NO_STAT);
}

void LockMonitor(Monitor *monitor)
{
   pthread_mutex_lock(&monitor->lock);
}

int TryLockMonitor(Monitor *monitor)
{
   return !pthread_mutex_trylock(&monitor->lock);
}

void UnlockMonitor(Monitor *monitor)
{
   pthread_mutex_unlock(&monitor->lock);
}

/****************************************************************************
 **
 *F WaitForMonitor(monitor) . . . . . .. . wait for a monitor to be ready
 **
 ** 'WaitForMonitor' waits for the monitor to be signaled by another
 ** thread. The monitor must be locked upon entry and will be locked
 ** again upon exit.
 */

void WaitForMonitor(Monitor *monitor)
{
  struct WaitList node;
  node.thread = realTLS;
  AddWaitList(monitor, &node);
  UnlockMonitor(monitor);
  LockThread(realTLS);
  while (!TLS(acquiredMonitor))
    WaitThreadSignal();
  if (!TryLockMonitor(monitor))
  {
    UnlockThread(realTLS);
    LockMonitor(monitor);
    LockThread(realTLS);
  }
  TLS(acquiredMonitor) = NULL;
  RemoveWaitList(monitor, &node);
  UnlockThread(realTLS);
}

static int MonitorOrder(const void *r1, const void *r2)
{
  const char *p1 = *(const char **)r1;
  const char *p2 = *(const char **)r2;
  return p1 < p2;
}

void SortMonitors(UInt count, Monitor **monitors)
{
  MergeSort(monitors, count, sizeof(Monitor *), MonitorOrder);
}

static int ChannelOrder(const void *c1, const void *c2)
{
  const char *p1 = (const char *)ObjPtr((*(Channel **) c1)->monitor);
  const char *p2 = (const char *)ObjPtr((*(Channel **) c2)->monitor);
  return p1 < p2;
}

static void SortChannels(UInt count, Channel **channels)
{
  MergeSort(channels, count, sizeof(Channel *), ChannelOrder);
}

static int MonitorsAreSorted(UInt count, Monitor **monitors)
{
  UInt i;
  for (i=1; i<count; i++)
    if ((char *)(monitors[i-1]) > (char *)(monitors[i]))
      return 0;
  return 1;
}

void LockMonitors(UInt count, Monitor **monitors)
{
  UInt i;
  assert(MonitorsAreSorted(count, monitors));
  for (i=0; i<count; i++)
    LockMonitor(monitors[i]);
}

void UnlockMonitors(UInt count, Monitor **monitors)
{
  UInt i;
  for (i=0; i<count; i++)
    UnlockMonitor(monitors[i]);
}


/****************************************************************************
 **
 *F WaitForAnyMonitor(count, monitors) . . wait for a monitor to be ready
 **
 ** 'WaitForAnyMonitor' waits for any one of the monitors in the list to
 ** be signaled. The function returns when any of them is signaled via
 ** 'SignalMonitor'. The first argument is the number of monitors in the
 ** list, the second argument is an array of monitor pointers.
 **
 ** The list must be sorted by 'MonitorOrder' before passing it to the
 ** function; all monitors must also be locked before calling the function
 ** by calling 'LockMonitors'.
 **
 ** Upon return, all monitors but the one that was signaled will be
 ** unlocked.
 */

UInt WaitForAnyMonitor(UInt count, Monitor **monitors)
{
  struct WaitList *nodes;
  Monitor *monitor;
  UInt i;
  Int result;
  assert(MonitorsAreSorted(count, monitors));
  nodes = alloca(sizeof(struct WaitList) * count);
  for (i=0; i<count; i++)
    nodes[i].thread = realTLS;
  for (i=0; i<count; i++)
    AddWaitList(monitors[i], &nodes[i]);
  for (i=0; i<count; i++)
    UnlockMonitor(monitors[i]);
  LockThread(realTLS);
  while (!TLS(acquiredMonitor))
    WaitThreadSignal();
  monitor = TLS(acquiredMonitor);
  UnlockThread(realTLS);
  for (i=0; i<count; i++)
  {
    LockMonitor(monitors[i]);
    if (monitors[i] == monitor)
    {
      RemoveWaitList(monitors[i], &nodes[i]);
      result = i;
      /* keep it locked for further processing by caller */
    }
    else
    {
      RemoveWaitList(monitors[i], &nodes[i]);
      UnlockMonitor(monitors[i]);
    }
  }
  LockThread(realTLS);
  TLS(acquiredMonitor) = NULL;
  UnlockThread(realTLS);
  return result;
}

/****************************************************************************
 **
 *F SignalMonitor(monitor) . . . . . . . . . . send a signal to a monitor
 **
 ** Sends a signal to a monitor that is being waited for by another thread.
 ** The monitor must be locked upon entry and will be locked again upon
 ** exit. If no thread is waiting for the monitor, no operation will occur.
 */

void SignalMonitor(Monitor *monitor)
{
  struct WaitList *queue;
  ThreadLocalStorage *thread = NULL;
  queue = monitor->head;
  if (queue != NULL)
  {
    do {
      thread = queue->thread;
      LockThread(thread);
      if (!thread->acquiredMonitor)
      {
        thread->acquiredMonitor = monitor;
	SignalThread(thread);
	UnlockThread(thread);
	break;
      }
      UnlockThread(thread);
      queue = queue->next;
    } while (queue != NULL);
  }
}

static void ArgumentError(char *message)
{
  ErrorQuit(message, 0, 0);
}

/* TODO: register globals */
Obj FirstKeepAlive;
Obj LastKeepAlive;
pthread_mutex_t KeepAliveLock;

#define PREV_KEPT(obj) (ADDR_OBJ(obj)[2])
#define NEXT_KEPT(obj) (ADDR_OBJ(obj)[3])

Obj KeepAlive(Obj obj)
{
  Obj newKeepAlive = NewBag( T_PLIST, 4*sizeof(Obj) );
  pthread_mutex_lock(&KeepAliveLock);
  ADDR_OBJ(newKeepAlive)[0] = (Obj) 3; /* Length 3 */
  KEPTALIVE(newKeepAlive) = obj;
  PREV_KEPT(newKeepAlive) = LastKeepAlive;
  NEXT_KEPT(newKeepAlive) = (Obj) 0;
  if (LastKeepAlive)
    NEXT_KEPT(LastKeepAlive) = newKeepAlive;
  else
    FirstKeepAlive = LastKeepAlive = newKeepAlive;
  pthread_mutex_unlock(&KeepAliveLock);
  return newKeepAlive;
}

void StopKeepAlive(Obj node)
{
#ifndef WARD_ENABLED
  Obj pred, succ;
  pthread_mutex_lock(&KeepAliveLock);
  pred = PREV_KEPT(node);
  succ = NEXT_KEPT(node);
  if (pred)
    NEXT_KEPT(pred) = succ;
  else
    FirstKeepAlive = succ;
  if (succ)
    PREV_KEPT(succ) = pred;
  else
    LastKeepAlive = pred;
  pthread_mutex_unlock(&KeepAliveLock);
#endif
}

/****************************************************************************
**
*F FuncCreateThread  ... create a new thread
**
** The function creates a new thread with a new interpreter and executes
** the function passed as an argument in it. It returns an integer that
** is a unique identifier for the thread.
*/

Obj FuncCreateThread(Obj self, Obj funcargs) {
  Int i, n;
  Obj thread;
  void ThreadedInterpreter(void *);
  Obj templist;
  n = LEN_PLIST(funcargs);
  if (n == 0 || !IS_FUNC(ELM_PLIST(funcargs, 1)))
  {
    ArgumentError("CreateThread: Needs at least one function argument");
    return (Obj) 0; /* flow control hint */
  }
  templist = NEW_PLIST(T_PLIST, n);
  SET_LEN_PLIST(templist, n);
  REGION(templist) = NULL; /* make it public */
  for (i=1; i<=n; i++)
    SET_ELM_PLIST(templist, i, ELM_PLIST(funcargs, i));
  thread = RunThread(ThreadedInterpreter, KeepAlive(templist));
  if (!thread)
    return Fail;
  return thread;
}

/****************************************************************************
**
*F FuncWaitThread  ... wait for a created thread to finish.
**
** The function waits for an existing thread to finish.
*/

Obj FuncWaitThread(Obj self, Obj thread) {
  UInt thread_num;
  UInt thread_status;
  char *error = NULL;
  if (TNUM_OBJ(thread) != T_THREAD)
    ArgumentError("WaitThread: Argument must be a thread object");
  LockThreadControl(1);
  thread_num = *(UInt *)(ADDR_OBJ(thread)+1);
  thread_status = *(UInt *)(ADDR_OBJ(thread)+2);
  if (thread_status & THREAD_JOINED)
    error = "Thread is already being waited for";
  *(UInt *)(ADDR_OBJ(thread)+2) |= THREAD_JOINED;
  UnlockThreadControl();
  if (error)
    ErrorQuit("WaitThread: %s", (UInt) error, 0L);
  if (!JoinThread(thread_num))
    ErrorQuit("WaitThread: Invalid thread id", 0L, 0L);
  return (Obj) 0;
}

/****************************************************************************
**
*F FuncCurrentThread ... return thread object of current thread.
**
*/

Obj FuncCurrentThread(Obj self) {
  return TLS(threadObject);
}

/****************************************************************************
**
*F FuncThreadID ... return numerical thread id of thread.
**
*/

Obj FuncThreadID(Obj self, Obj thread) {
  if (TNUM_OBJ(thread) != T_THREAD)
    ArgumentError("ThreadID: Argument must be a thread object");
  return INTOBJ_INT(ThreadID(thread));
}

/****************************************************************************
**
*F FuncKillThread ... kill a given thread
**
*/


Obj FuncKillThread(Obj self, Obj thread) {
  int id;
  if (IS_INTOBJ(thread)) {
    id = INT_INTOBJ(thread);
    if (id < 0 || id >= MAX_THREADS)
      ArgumentError("KillThread: Thread ID out of range");
  } else if (TNUM_OBJ(thread) == T_THREAD) {
    id = ThreadID(thread);
  } else
    ArgumentError("KillThread: Argument must be a thread object");
  KillThread(id);
  return (Obj) 0;
}


/****************************************************************************
**
*F FuncInterruptThread ... interrupt a given thread
**
*/

#define AS_STRING(s) #s


Obj FuncInterruptThread(Obj self, Obj thread, Obj handler) {
  int id;
  if (IS_INTOBJ(thread)) {
    id = INT_INTOBJ(thread);
    if (id < 0 || id >= MAX_THREADS)
      ArgumentError("InterruptThread: Thread ID out of range");
  } else if (TNUM_OBJ(thread) == T_THREAD) {
    id = ThreadID(thread);
  } else
    ArgumentError("InterruptThread: First argument must identify a thread");
  if (!IS_INTOBJ(handler) || INT_INTOBJ(handler) < 0 ||
      INT_INTOBJ(handler) > MAX_INTERRUPT)
    ArgumentError("InterruptThread: Second argument must be an integer "
      "between 0 and " AS_STRING(MAX_INTERRUPT));
  InterruptThread(id, (int)(INT_INTOBJ(handler)));
  return (Obj) 0;
}

/****************************************************************************
**
*F FuncSetInterruptHandler ... set interrupt handler for current thread
**
*/

Obj FuncSetInterruptHandler(Obj self, Obj handler, Obj func) {
  int id;
  if (!IS_INTOBJ(handler) || INT_INTOBJ(handler) < 1 ||
      INT_INTOBJ(handler) > MAX_INTERRUPT)
    ArgumentError("SetInterruptHandler: First argument must be an integer "
      "between 1 and " AS_STRING(MAX_INTERRUPT));
  if (func == Fail) {
    SetInterruptHandler((int)(INT_INTOBJ(handler)), (Obj) 0);
    return (Obj) 0;
  }
  if (TNUM_OBJ(func) != T_FUNCTION || NARG_FUNC(func) != 0 || !BODY_FUNC(func))
    ArgumentError("SetInterruptHandler: Second argument must be a parameterless function or 'fail'");
  SetInterruptHandler((int)(INT_INTOBJ(handler)), func);
  return (Obj) 0;
}

#undef AS_STRING


/****************************************************************************
**
*F FuncPauseThread ... pause a given thread
**
*/


Obj FuncPauseThread(Obj self, Obj thread) {
  int id;
  if (IS_INTOBJ(thread)) {
    id = INT_INTOBJ(thread);
    if (id < 0 || id >= MAX_THREADS)
      ArgumentError("PauseThread: Thread ID out of range");
  } else if (TNUM_OBJ(thread) == T_THREAD) {
    id = ThreadID(thread);
  } else
    ArgumentError("PauseThread: Argument must be a thread object");
  PauseThread(id);
  return (Obj) 0;
}


/****************************************************************************
**
*F FuncResumeThread ... resume a given thread
**
*/


Obj FuncResumeThread(Obj self, Obj thread) {
  int id;
  if (IS_INTOBJ(thread)) {
    id = INT_INTOBJ(thread);
    if (id < 0 || id >= MAX_THREADS)
      ArgumentError("ResumeThread: Thread ID out of range");
  } else if (TNUM_OBJ(thread) == T_THREAD) {
    id = ThreadID(thread);
  } else
    ArgumentError("ResumeThread: Argument must be a thread object");
  ResumeThread(id);
  return (Obj) 0;
}





/****************************************************************************
**
*F FuncRegionOf ... return region of an object
**
*/


Obj FuncRegionOf(Obj self, Obj obj) {
  Region *region = GetRegionOf(obj);
  return region == NULL ? PublicRegion : region->obj;
}

/****************************************************************************
**
*F FuncSetAutoLockRegion ... change the autolock status of a region
*F FuncIsAutoLockRegion ... query the autolock status of a region
**
*/

Obj FuncSetAutoLockRegion(Obj self, Obj obj, Obj flag) {
  Region *region = GetRegionOf(obj);
  if (!region || region->fixed_owner) {
    ArgumentError("SetAutoLockRegion: cannot change autolock status of this region");
  }
  if (flag == True) {
    region->autolock = 1;
    return (Obj) 0;
  } else if (flag == False || flag == Fail) {
    region->autolock = 0;
    return (Obj) 0;
  } else {
    ArgumentError("SetAutoLockRegion: Second argument must be boolean");
    return (Obj) 0; /* flow control hint */
  }
}

Obj FuncIsAutoLockRegion(Obj self, Obj obj) {
  Region *region = GetRegionOf(obj);
  if (!region)
    return False;
  return region->autolock ? True : False;
}



/****************************************************************************
**
*F FuncSetRegionName ... set the name of an object's region
*F FuncClearRegionName ... clear the name of an object's region
*F FuncRegionName ... get the name of an object's region
**
*/


Obj FuncSetRegionName(Obj self, Obj obj, Obj name) {
  Region *region = GetRegionOf(obj);
  if (!region)
    ArgumentError("SetRegionName: Cannot change name of the public region");
  if (!IsStringConv(name))
    ArgumentError("SetRegionName: Region name must be a string");
  SetRegionName(region, name);
  return (Obj) 0;
}

Obj FuncClearRegionName(Obj self, Obj obj) {
  Region *region = GetRegionOf(obj);
  if (!region)
    ArgumentError("ClearRegionName: Cannot change name of the public region");
  SetRegionName(region, (Obj) 0);
  return (Obj) 0;
}

Obj FuncRegionName(Obj self, Obj obj) {
  Obj result;
  Region *region = GetRegionOf(obj);
  result = GetRegionName(region);
  if (!result)
    result = Fail;
  return result;
}


/****************************************************************************
**
*F FuncIsShared ... return whether a region is shared
**
*/

Obj FuncIsShared(Obj self, Obj obj) {
  Region *region = GetRegionOf(obj);
  return (region && !region->fixed_owner) ? True : False;
}

/****************************************************************************
**
*F FuncIsPublic ... return whether a region is public
**
*/

Obj FuncIsPublic(Obj self, Obj obj) {
  Region *region = GetRegionOf(obj);
  return region == NULL ? True : False;
}

/****************************************************************************
**
*F FuncIsThreadLocal ... return whether a region is thread-local
**
*/

Obj FuncIsThreadLocal(Obj self, Obj obj) {
  Region *region = GetRegionOf(obj);
  return (region && region->fixed_owner && region->owner == realTLS) ? True : False;
}

/****************************************************************************
**
*F FuncHaveWriteAccess ... return if we have a write lock on the region
**
*/

Obj FuncHaveWriteAccess(Obj self, Obj obj)
{
  Region* region = GetRegionOf(obj);
  if (region != NULL && (region->owner == realTLS || region->alt_owner == realTLS))
    return True;
  else
    return False;
}

/****************************************************************************
**
*F FuncHaveReadAccess ... return if we have a read lock on the region
**
*/

Obj FuncHaveReadAccess(Obj self, Obj obj)
{
  Region* region = GetRegionOf(obj);
  if (region != NULL && CheckReadAccess(obj))
    return True;
  else
    return False;
}


/****************************************************************************
**
*F FuncHASH_LOCK ........... acquire write lock on an object.
*F FuncHASH_UNLOCK ......... release write lock on an object.
*F FuncHASH_LOCK_SHARED ..... acquire read lock on an object.
*F FuncHASH_UNLOCK_SHARED ... release read lock on an object.
**
*/


Obj FuncHASH_LOCK(Obj self, Obj target) {
  HashLock(target);
  return (Obj) 0;
}

Obj FuncHASH_UNLOCK(Obj self, Obj target) {
  HashUnlock(target);
  return (Obj) 0;
}

Obj FuncHASH_LOCK_SHARED(Obj self, Obj target) {
  HashLockShared(target);
  return (Obj) 0;
}
Obj FuncHASH_UNLOCK_SHARED(Obj self, Obj target) {
  HashUnlockShared(target);
  return (Obj) 0;
}

/****************************************************************************
**
*F FuncHASH_SYNCHRONIZED ......... execute a function while holding a write lock.
*F FuncHASH_SYNCHRONIZED_SHARED ... execute a function while holding a read lock.
**
*/

Obj FuncHASH_SYNCHRONIZED(Obj self, Obj target, Obj function) {
  volatile int locked = 0;
  jmp_buf readJmpError;
  memcpy( readJmpError, TLS(ReadJmpError), sizeof(jmp_buf) );
  TRY_READ {
    HashLock(target);
    locked = 1;
    CALL_0ARGS(function);
    locked = 0;
    HashUnlock(target);
  }
  if (locked)
    HashUnlock(target);
  memcpy( TLS(ReadJmpError), readJmpError, sizeof(jmp_buf) );
  return (Obj) 0;
}

Obj FuncHASH_SYNCHRONIZED_SHARED(Obj self, Obj target, Obj function) {
  volatile int locked = 0;
  jmp_buf readJmpError;
  memcpy( readJmpError, TLS(ReadJmpError), sizeof(jmp_buf) );
  TRY_READ {
    HashLockShared(target);
    locked = 1;
    CALL_0ARGS(function);
    locked = 0;
    HashUnlockShared(target);
  }
  if (locked)
    HashUnlockShared(target);
  memcpy( TLS(ReadJmpError), readJmpError, sizeof(jmp_buf) );
  return (Obj) 0;
}

/****************************************************************************
**
*F FuncCREATOR_OF ... return function that created an object
**
*/

Obj FuncCREATOR_OF(Obj self, Obj obj) {
#ifdef TRACK_CREATOR
  Obj result = NEW_PLIST(T_PLIST+IMMUTABLE, 2);
  SET_LEN_PLIST(result, 2);
  if (!IS_BAG_REF(obj)) {
    SET_ELM_PLIST(result, 1, Fail);
    SET_ELM_PLIST(result, 2, Fail);
    return result;
  }
  if (obj[2])
    SET_ELM_PLIST(result, 1, (Obj)(obj[2]));
  else
    SET_ELM_PLIST(result, 1, Fail);
  if (obj[3])
    SET_ELM_PLIST(result, 2, (Obj)(obj[3]));
  else
    SET_ELM_PLIST(result, 2, Fail);
  return result;
#else
  return Fail;
#endif
}

Obj FuncDISABLE_GUARDS(Obj self, Obj flag) {
  if (flag == False)
    TLS(DisableGuards) = 0;
  else if (flag == True)
    TLS(DisableGuards) = 1;
  else if (IS_INTOBJ(flag))
    TLS(DisableGuards) = (int) (INT_INTOBJ(flag));
  else
    ErrorQuit("DISABLE_GUARDS: Argument must be boolean or integer", 0L, 0L);
  return (Obj) 0;
}

Obj FuncWITH_TARGET_REGION(Obj self, Obj obj, Obj func) {
  Region * volatile oldRegion = TLS(currentRegion);
  Region * volatile region = GetRegionOf(obj);
  syJmp_buf readJmpError;

  if (TNUM_OBJ(func) != T_FUNCTION)
    ArgumentError("WITH_TARGET_REGION: Second argument must be a function");
  if (!region || !CheckExclusiveWriteAccess(obj))
    ArgumentError("WITH_TARGET_REGION: Requires write access to target region");
  memcpy(readJmpError, TLS(ReadJmpError), sizeof(syJmp_buf));
  if (sySetjmp(TLS(ReadJmpError))) {
    memcpy(TLS(ReadJmpError), readJmpError, sizeof(syJmp_buf));
    TLS(currentRegion) = oldRegion;
    syLongjmp(TLS(ReadJmpError), 1);
  }
  TLS(currentRegion) = region;
  CALL_0ARGS(func);
  memcpy(TLS(ReadJmpError), readJmpError, sizeof(syJmp_buf));
  TLS(currentRegion) = oldRegion;
  return (Obj) 0;
}


Obj FuncCreateChannel(Obj self, Obj args);
Obj FuncDestroyChannel(Obj self, Obj channel);
Obj FuncTallyChannel(Obj self, Obj channel);
Obj FuncSendChannel(Obj self, Obj channel, Obj obj);
Obj FuncTransmitChannel(Obj self, Obj channel, Obj obj);
Obj FuncReceiveChannel(Obj self, Obj channel);
Obj FuncReceiveAnyChannel(Obj self, Obj args);
Obj FuncReceiveAnyChannelWithIndex(Obj self, Obj args);
Obj FuncMultiReceiveChannel(Obj self, Obj channel, Obj count);
Obj FuncInspectChannel(Obj self, Obj channel);
Obj FuncMultiSendChannel(Obj self, Obj channel, Obj list);
Obj FuncTryMultiSendChannel(Obj self, Obj channel, Obj list);
Obj FuncTrySendChannel(Obj self, Obj channel, Obj obj);
Obj FuncMultiTransmitChannel(Obj self, Obj channel, Obj list);
Obj FuncTryMultiTransmitChannel(Obj self, Obj channel, Obj list);
Obj FuncTryTransmitChannel(Obj self, Obj channel, Obj obj);
Obj FuncTryReceiveChannel(Obj self, Obj channel, Obj defaultobj);
Obj FuncCreateSemaphore(Obj self, Obj args);
Obj FuncSignalSemaphore(Obj self, Obj sem);
Obj FuncWaitSemaphore(Obj self, Obj sem);
Obj FuncTryWaitSemaphore(Obj self, Obj sem);
Obj FuncCreateThread(Obj self, Obj funcargs);
Obj FuncCurrentThread(Obj self);
Obj FuncThreadID(Obj self, Obj thread);
Obj FuncKillThread(Obj self, Obj thread);
Obj FuncInterruptThread(Obj self, Obj thread, Obj handler);
Obj FuncPauseThread(Obj self, Obj thread);
Obj FuncResumeThread(Obj self, Obj thread);
Obj FuncWaitThread(Obj self, Obj id);
Obj FuncCreateBarrier(Obj self);
Obj FuncStartBarrier(Obj self, Obj barrier, Obj count);
Obj FuncWaitBarrier(Obj self, Obj barrier);
Obj FuncCreateSyncVar(Obj self);
Obj FuncSyncWrite(Obj self, Obj var, Obj value);
Obj FuncSyncTryWrite(Obj self, Obj var, Obj value);
Obj FuncSyncRead(Obj self, Obj var);
Obj FuncSyncIsBound(Obj self, Obj var);
Obj FuncWriteLock(Obj self, Obj args);
Obj FuncReadLock(Obj self, Obj args);
Obj FuncIS_LOCKED(Obj self, Obj obj);
Obj FuncLOCK(Obj self, Obj args);
Obj FuncDO_LOCK(Obj self, Obj args);
Obj FuncWRITE_LOCK(Obj self, Obj args);
Obj FuncREAD_LOCK(Obj self, Obj args);
Obj FuncTRYLOCK(Obj self, Obj args);
Obj FuncUNLOCK(Obj self, Obj args);
Obj FuncCURRENT_LOCKS(Obj self);
Obj FuncREFINE_TYPE(Obj self, Obj obj);
Obj FuncFIX_OBJ_REGION(Obj self, Obj obj);
Obj FuncSHARE_NORECURSE(Obj self, Obj obj, Obj name, Obj prec);
Obj FuncNEW_REGION(Obj self, Obj name, Obj prec);
Obj FuncREGION_PRECEDENCE(Obj self, Obj regobj);
Obj FuncMAKE_PUBLIC_NORECURSE(Obj self, Obj obj);
Obj FuncFORCE_MAKE_PUBLIC(Obj self, Obj obj);
Obj FuncADOPT_NORECURSE(Obj self, Obj obj);
Obj FuncMIGRATE_NORECURSE(Obj self, Obj obj, Obj target);
Obj FuncSHARE(Obj self, Obj obj, Obj name, Obj prec);
Obj FuncSHARE_RAW(Obj self, Obj obj, Obj name, Obj prec);
Obj FuncMAKE_PUBLIC(Obj self, Obj obj);
Obj FuncADOPT(Obj self, Obj obj);
Obj FuncMIGRATE(Obj self, Obj obj, Obj target);
Obj FuncMIGRATE_RAW(Obj self, Obj obj, Obj target);
Obj FuncREACHABLE(Obj self, Obj obj);
Obj FuncCLONE_REACHABLE(Obj self, Obj obj);
Obj FuncCLONE_DELIMITED(Obj self, Obj obj);
Obj FuncMakeThreadLocal(Obj self, Obj var);
Obj FuncMakeReadOnly(Obj self, Obj obj);
Obj FuncMakeReadOnlyRaw(Obj self, Obj obj);
Obj FuncMakeReadOnlyObj(Obj self, Obj obj);
Obj FuncMakeProtected(Obj self, Obj obj);
Obj FuncMakeProtectedObj(Obj self, Obj obj);
Obj FuncIsReadOnly(Obj self, Obj obj);
Obj FuncIsProtected(Obj self, Obj obj);
Obj FuncENABLE_AUTO_RETYPING(Obj self);
Obj FuncBEGIN_SINGLE_THREADED(Obj self);
Obj FuncEND_SINGLE_THREADED(Obj self);
Obj FuncORDERED_WRITE(Obj self, Obj obj);
Obj FuncORDERED_READ(Obj self, Obj obj);
Obj FuncCREATOR_OF(Obj self, Obj obj);
Obj FuncDISABLE_GUARDS(Obj self, Obj flag);
Obj FuncSIGWAIT(Obj self, Obj handlers);
Obj FuncDEFAULT_SIGINT_HANDLER(Obj self);
Obj FuncDEFAULT_SIGCHLD_HANDLER(Obj self);
Obj FuncDEFAULT_SIGVTALRM_HANDLER(Obj self);
Obj FuncDEFAULT_SIGWINCH_HANDLER(Obj self);
Obj FuncPERIODIC_CHECK(Obj self, Obj count, Obj func);
Obj FuncREGION_COUNTERS_ENABLE(Obj self, Obj obj);
Obj FuncREGION_COUNTERS_DISABLE(Obj self, Obj obj);
Obj FuncREGION_COUNTERS_GET_STATE(Obj self, Obj obj);
Obj FuncREGION_COUNTERS_GET(Obj self, Obj regobj);
Obj FuncREGION_COUNTERS_RESET(Obj self, Obj regobj);
Obj FuncTHREAD_COUNTERS_ENABLE(Obj self);
Obj FuncTHREAD_COUNTERS_DISABLE(Obj self);
Obj FuncTHREAD_COUNTERS_GET_STATE(Obj self);
Obj FuncTHREAD_COUNTERS_GET(Obj self);
Obj FuncTHREAD_COUNTERS_RESET(Obj self);



/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "CreateThread", -1, "function",
      FuncCreateThread, "src/threadapi.c:CreateThread" },

    { "CurrentThread", 0, "",
      FuncCurrentThread, "src/threadapi.c:CurrentThread" },

    { "ThreadID", 1, "thread",
      FuncThreadID, "src/threadapi.c:ThreadID" },

    { "WaitThread", 1, "thread",
      FuncWaitThread, "src/threadapi.c:WaitThread" },

    { "KillThread", 1, "thread",
      FuncKillThread, "src/threadapi.c:KillThread" },

    { "InterruptThread", 2, "thread, handler",
      FuncInterruptThread, "src/threadapi.c:InterruptThread" },

    { "SetInterruptHandler", 2, "handler, function",
      FuncSetInterruptHandler, "src/threadapi.c:SetInterruptHandler" },

    { "PauseThread", 1, "thread",
      FuncPauseThread, "src/threadapi.c:PauseThread" },

    { "ResumeThread", 1, "thread",
      FuncResumeThread, "src/threadapi.c:ResumeThread" },

    { "HASH_LOCK", 1, "object",
      FuncHASH_LOCK, "src/threadapi.c:HASH_LOCK" },

    { "HASH_LOCK_SHARED", 1, "object",
      FuncHASH_LOCK_SHARED, "src/threadapi.c:HASH_LOCK_SHARED" },

    { "HASH_UNLOCK", 1, "object",
      FuncHASH_UNLOCK, "src/threadapi.c:HASH_UNLOCK" },

    { "HASH_UNLOCK_SHARED", 1, "object",
      FuncHASH_UNLOCK_SHARED, "src/threadapi.c:HASH_UNLOCK_SHARED" },

    { "HASH_SYNCHRONIZED", 2, "object, function",
      FuncHASH_SYNCHRONIZED, "src/threadapi.c:HASH_SYNCHRONIZED" },

    { "SynchronizedShared", 2, "object, function",
      FuncHASH_SYNCHRONIZED_SHARED, "src/threadapi.c:SynchronizedShared" },

    { "RegionOf", 1, "object",
      FuncRegionOf, "src/threadapi.c:RegionOf" },

    { "SetAutoLockRegion", 2, "object, boolean",
      FuncSetAutoLockRegion, "src/threadapi.c:SetAutoLockRegion" },

    { "IsAutoLockRegion", 1, "object",
      FuncIsAutoLockRegion, "src/threadapi.c:IsAutoLockRegion" },

    { "SetRegionName", 2, "obj, name",
      FuncSetRegionName, "src/threadapi.c:SetRegionName" },

    { "ClearRegionName", 1, "obj",
      FuncClearRegionName, "src/threadapi.c:ClearRegionName" },

    { "RegionName", 1, "obj",
      FuncRegionName, "src/threadapi.c:RegionName" },

    { "WITH_TARGET_REGION", 2, "region, function",
      FuncWITH_TARGET_REGION, "src/threadapi.c:WITH_TARGET_REGION" },

    { "IsShared", 1, "object",
      FuncIsShared, "src/threadapi.c:IsShared" },

    { "IsPublic", 1, "object",
      FuncIsPublic, "src/threadapi.c:IsPublic" },

    { "IsThreadLocal", 1, "object",
      FuncIsThreadLocal, "src/threadapi.c:IsThreadLocal" },

    { "HaveWriteAccess", 1, "object",
      FuncHaveWriteAccess, "src/threadapi.c:HaveWriteAccess" },

    { "HaveReadAccess", 1, "object",
      FuncHaveReadAccess, "src/threadapi.c:HaveReadAccess" },

    { "CreateSemaphore", -1, "[count]",
      FuncCreateSemaphore, "src/threadapi.c:CreateSemaphore" },

    { "SignalSemaphore", 1, "semaphore",
      FuncSignalSemaphore, "src/threadapi.c:SignalSemaphore" },

    { "WaitSemaphore", 1, "semaphore",
      FuncWaitSemaphore, "src/threadapi.c:WaitSemaphore" },

    { "TryWaitSemaphore", 1, "semaphore",
      FuncTryWaitSemaphore, "src/threadapi.c:TryWaitSemaphore" },

    { "CreateChannel", -1, "[size]",
      FuncCreateChannel, "src/threadapi.c:CreateChannel" },

    { "DestroyChannel", 1, "channel",
      FuncDestroyChannel, "src/threadapi.c:DestroyChannel" },

    { "TallyChannel", 1, "channel",
      FuncTallyChannel, "src/threadapi.c:TallyChannel" },

    { "SendChannel", 2, "channel, obj",
      FuncSendChannel, "src/threadapi.c:SendChannel" },

    { "TransmitChannel", 2, "channel, obj",
      FuncTransmitChannel, "src/threadapi.c:TransmitChannel" },

    { "ReceiveChannel", 1, "channel",
      FuncReceiveChannel, "src/threadapi:ReceiveChannel" },

    { "ReceiveAnyChannel", -1, "channel list",
      FuncReceiveAnyChannel, "src/threadapi:ReceiveAnyChannel" },

    { "ReceiveAnyChannelWithIndex", -1, "channel list",
      FuncReceiveAnyChannelWithIndex, "src/threadapi:ReceiveAnyChannelWithIndex" },

    { "MultiReceiveChannel", 2, "channel, count",
      FuncMultiReceiveChannel, "src/threadapi:MultiReceiveChannel" },

    { "TryReceiveChannel", 2, "channel, obj",
      FuncTryReceiveChannel, "src/threadapi.c:TryReceiveChannel" },

    { "MultiSendChannel", 2, "channel, list",
      FuncMultiSendChannel, "src/threadapi:MultiSendChannel" },

    { "TryMultiSendChannel", 2, "channel, list",
      FuncTryMultiSendChannel, "src/threadapi:TryMultiSendChannel" },

    { "TrySendChannel", 2, "channel, obj",
      FuncTrySendChannel, "src/threadapi.c:TrySendChannel" },

    { "MultiTransmitChannel", 2, "channel, list",
      FuncMultiTransmitChannel, "src/threadapi:MultiTransmitChannel" },

    { "TryMultiTransmitChannel", 2, "channel, list",
      FuncTryMultiTransmitChannel, "src/threadapi:TryMultiTransmitChannel" },

    { "TryTransmitChannel", 2, "channel, obj",
      FuncTryTransmitChannel, "src/threadapi.c:TryTransmitChannel" },

    { "InspectChannel", 1, "channel, obj",
      FuncInspectChannel, "src/threadapi.c:InspectChannel" },

    { "CreateBarrier", 0, "",
      FuncCreateBarrier, "src/threadapi.c:CreateBarrier" },

    { "StartBarrier", 2, "barrier, count",
      FuncStartBarrier, "src/threadapi.c:StartBarrier" },

    { "WaitBarrier", 1, "barrier",
      FuncWaitBarrier, "src/threadapi.c:WaitBarrier" },

    { "CreateSyncVar", 0, "",
      FuncCreateSyncVar, "src/threadapi.c:CreateSyncVar" },

    { "SyncWrite", 2, "syncvar, obj",
      FuncSyncWrite, "src/threadapi.c:SyncWrite" },

    { "SyncTryWrite", 2, "syncvar, obj",
      FuncSyncTryWrite, "src/threadapi.c:SyncTryWrite" },

    { "SyncRead", 1, "syncvar",
      FuncSyncRead, "src/threadapi.c:SyncRead" },

    { "SyncIsBound", 1, "syncvar",
      FuncSyncIsBound, "src/threadapi.c:SyncIsBound" },

    { "IS_LOCKED", 1, "obj",
      FuncIS_LOCKED, "src/threadapi.c:IS_LOCKED" },

    { "WriteLock", -1, "obj, ...",
      FuncWriteLock, "src/threadapi.c:WriteLock" },

    { "ReadLock", -1, "obj, ...",
      FuncReadLock, "src/threadapi.c:ReadLock" },

    { "LOCK", -1, "obj, ...",
      FuncLOCK, "src/threadapi.c:LOCK" },

    { "DO_LOCK", -1, "obj, ...",
      FuncDO_LOCK, "src/threadapi.c:DO_LOCK" },

    { "WRITE_LOCK", 1, "obj",
      FuncWRITE_LOCK, "src/threadapi.c:WRITE_LOCK" },

    { "READ_LOCK", 1, "obj",
      FuncREAD_LOCK, "src/threadapi.c:READ_LOCK" },

    { "TRYLOCK", -1, "obj, ...",
      FuncTRYLOCK, "src/threadapi.c:TRYLOCK" },

    { "UNLOCK", 1, "obj, newsp",
      FuncUNLOCK, "src/threadapi.c:LOCK" },

    { "CURRENT_LOCKS", 0, "",
      FuncCURRENT_LOCKS, "src/threadapi.c:FuncCURRENT_LOCKS" },

    { "REFINE_TYPE", 1, "obj",
      FuncREFINE_TYPE, "src/threadapi.c:REFINE_TYPE" },

    { "FIX_OBJ_REGION", 1, "obj",
      FuncFIX_OBJ_REGION, "src/threadapi.c:FIX_OBJ_REGION" },

    { "SHARE_NORECURSE", 3, "obj, string, integer",
      FuncSHARE_NORECURSE, "src/threadapi.c:SHARE_NORECURSE" },

    { "ADOPT_NORECURSE", 1, "obj",
      FuncADOPT_NORECURSE, "src/threadapi.c:ADOPT_NORECURSE" },

    { "MIGRATE_NORECURSE", 2, "obj, target",
      FuncMIGRATE_NORECURSE, "src/threadapi.c:MIGRATE_NORECURSE" },

    { "NEW_REGION", 2, "string, integer",
      FuncNEW_REGION, "src/threadapi.c:NEW_REGION" },

    { "REGION_PRECEDENCE", 1, "obj",
      FuncREGION_PRECEDENCE, "src/threadapi.c:REGION_PRECEDENCE" },

    { "SHARE", 3, "obj, string, integer",
      FuncSHARE, "src/threadapi.c:SHARE" },

    { "SHARE_RAW", 3, "obj, string, integer",
      FuncSHARE_RAW, "src/threadapi.c:SHARE_RAW" },

    { "ADOPT", 1, "obj",
      FuncADOPT, "src/threadapi.c:ADOPT" },

    { "MIGRATE", 2, "obj, target",
      FuncMIGRATE, "src/threadapi.c:MIGRATE" },

    { "MIGRATE_RAW", 2, "obj, target",
      FuncMIGRATE_RAW, "src/threadapi.c:MIGRATE_RAW" },

    { "MAKE_PUBLIC_NORECURSE", 1, "obj",
      FuncMAKE_PUBLIC_NORECURSE, "src/threadapi.c:MAKE_PUBLIC_NORECURSE" },

    { "MAKE_PUBLIC", 1, "obj",
      FuncMAKE_PUBLIC, "src/threadapi.c:MAKE_PUBLIC" },

    { "FORCE_MAKE_PUBLIC", 1, "obj",
      FuncFORCE_MAKE_PUBLIC, "src/threadapi.c:FORCE_MAKE_PUBLIC" },

    { "REACHABLE", 1, "obj",
      FuncREACHABLE, "src/threadapi.c:REACHABLE" },

    { "CLONE_REACHABLE", 1, "obj",
      FuncCLONE_REACHABLE, "src/threadapi.c:CLONE_REACHABLE" },

    { "CLONE_DELIMITED", 1, "obj",
      FuncCLONE_DELIMITED, "src/threadapi.c:CLONE_DELIMITED" },

    { "MakeThreadLocal", 1, "variable name",
      FuncMakeThreadLocal, "src/threadapi.c:MakeThreadLocal" },

    { "MakeReadOnly", 1, "obj",
      FuncMakeReadOnly, "src/threadapi.c:MakeReadOnly" },

    { "MakeReadOnlyRaw", 1, "obj",
      FuncMakeReadOnlyRaw, "src/threadapi.c:MakeReadOnlyRaw" },

    { "MakeReadOnlyObj", 1, "obj",
      FuncMakeReadOnlyObj, "src/threadapi.c:MakeReadOnlyObj" },

    { "MakeProtected", 1, "obj",
      FuncMakeProtected, "src/threadapi.c:MakeProtected" },

    { "MakeProtectedObj", 1, "obj",
      FuncMakeProtectedObj, "src/threadapi.c:MakeProtectedObj" },

    { "IsReadOnly", 1, "obj",
      FuncIsReadOnly, "src/threadapi.c:IsReadOnly" },

    { "IsProtected", 1, "obj",
      FuncIsProtected, "src/threadapi.c:IsProtected" },

    { "ENABLE_AUTO_RETYPING", 0, "",
      FuncENABLE_AUTO_RETYPING, "src/threadapi.c:ENABLE_AUTO_RETYPING" },

    { "BEGIN_SINGLE_THREADED", 0, "",
      FuncBEGIN_SINGLE_THREADED, "src/threadapi.c:BEGIN_SINGLE_THREADED" },

    { "END_SINGLE_THREADED", 0, "",
      FuncEND_SINGLE_THREADED, "src/threadapi.c:END_SINGLE_THREADED" },

    { "ORDERED_READ", 1, "obj",
      FuncORDERED_READ, "src/threadapi.c:ORDERED_READ" },

    { "ORDERED_WRITE", 1, "obj",
      FuncORDERED_WRITE, "src/threadapi.c:ORDERED_WRITE" },

    { "CREATOR_OF", 1, "obj",
      FuncCREATOR_OF, "src/threadapi.c:CREATOR_OF" },

    { "DISABLE_GUARDS", 1, "flag",
      FuncDISABLE_GUARDS, "src/threadapi.c:DISABLE_GUARDS" },

    { "DEFAULT_SIGINT_HANDLER", 0, "",
      FuncDEFAULT_SIGINT_HANDLER, "src/threadapi.c:DEFAULT_SIGINT_HANDLER" },

    { "DEFAULT_SIGCHLD_HANDLER", 0, "",
      FuncDEFAULT_SIGCHLD_HANDLER, "src/threadapi.c:DEFAULT_SIGCHLD_HANDLER" },

    { "DEFAULT_SIGVTALRM_HANDLER", 0, "",
      FuncDEFAULT_SIGVTALRM_HANDLER, "src/threadapi.c:DEFAULT_SIGVTALRM_HANDLER" },

    { "DEFAULT_SIGWINCH_HANDLER", 0, "",
      FuncDEFAULT_SIGWINCH_HANDLER, "src/threadapi.c:DEFAULT_SIGWINCH_HANDLER" },

    { "SIGWAIT", 1, "record",
      FuncSIGWAIT, "src/threadapi.c:SIGWAIT" },

    { "PERIODIC_CHECK", 2, "count, function",
      FuncPERIODIC_CHECK, "src/threadapi.c:PERIODIC_CHECK" },

    { "REGION_COUNTERS_ENABLE", 1, "region",
      FuncREGION_COUNTERS_ENABLE, "src/threadapi.c:REGION_COUNTERS_ENABLE" },

    { "REGION_COUNTERS_DISABLE", 1, "region",
      FuncREGION_COUNTERS_DISABLE, "src/threadapi.c:REGION_COUNTERS_DISABLE" },

    { "REGION_COUNTERS_GET_STATE", 1, "region",
      FuncREGION_COUNTERS_GET_STATE, "src/threadapi.c:REGION_COUNTERS_GET_STATE" },

    { "REGION_COUNTERS_GET", 1, "region",
      FuncREGION_COUNTERS_GET, "src/threadapi.c:REGION_COUNTERS_GET" },

    { "REGION_COUNTERS_RESET", 1, "region",
      FuncREGION_COUNTERS_RESET, "src/threadapi.c:REGION_COUNTERS_RESET" },

    { "THREAD_COUNTERS_ENABLE", 0, "",
      FuncTHREAD_COUNTERS_ENABLE, "src/threadapi.c:THREAD_COUNTERS_ENABLE" },

    { "THREAD_COUNTERS_DISABLE", 0, "",
      FuncTHREAD_COUNTERS_DISABLE, "src/threadapi.c:THREAD_COUNTERS_DISABLE" },

    { "THREAD_COUNTERS_GET_STATE", 0, "",
      FuncTHREAD_COUNTERS_GET_STATE, "src/threadapi.c:THREAD_COUNTERS_GET_STATE" },

    { "THREAD_COUNTERS_GET", 0, "",
      FuncTHREAD_COUNTERS_GET, "src/threadapi.c:THREAD_COUNTERS_GET" },

    { "THREAD_COUNTERS_RESET", 0, "",
      FuncTHREAD_COUNTERS_RESET, "src/threadapi.c:THREAD_COUNTERS_RESET" },

    { 0 }

};

Obj TYPE_THREAD;
Obj TYPE_SEMAPHORE;
Obj TYPE_CHANNEL;
Obj TYPE_BARRIER;
Obj TYPE_SYNCVAR;
Obj TYPE_REGION;

Obj TypeThread(Obj obj)
{
  return TYPE_THREAD;
}

Obj TypeSemaphore(Obj obj)
{
  return TYPE_SEMAPHORE;
}

Obj TypeChannel(Obj obj)
{
  return TYPE_CHANNEL;
}

Obj TypeBarrier(Obj obj)
{
  return TYPE_BARRIER;
}

Obj TypeSyncVar(Obj obj)
{
  return TYPE_SYNCVAR;
}

Obj TypeRegion(Obj obj)
{
  return TYPE_REGION;
}

static Int AlwaysMutable( Obj obj)
{
  return 1;
}

static Int NeverMutable(Obj obj)
{
  return 0;
}

static void MarkSemaphoreBag(Bag);
static void MarkChannelBag(Bag);
static void MarkBarrierBag(Bag);
static void MarkSyncVarBag(Bag);
static void FinalizeMonitor(Bag);
static void PrintThread(Obj);
static void PrintSemaphore(Obj);
static void PrintChannel(Obj);
static void PrintBarrier(Obj);
static void PrintSyncVar(Obj);
static void PrintRegion(Obj);

GVarDescriptor LastInaccessibleGVar;
GVarDescriptor MAX_INTERRUPTGVar;

static UInt RNAM_SIGINT;
static UInt RNAM_SIGCHLD;
static UInt RNAM_SIGVTALRM;
#ifdef SIGWINCH
static UInt RNAM_SIGWINCH;
#endif


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  /* install info string */
  InfoBags[T_THREAD].name = "thread";
  InfoBags[T_SEMAPHORE].name = "channel";
  InfoBags[T_CHANNEL].name = "channel";
  InfoBags[T_BARRIER].name = "barrier";
  InfoBags[T_SYNCVAR].name = "syncvar";
  InfoBags[T_REGION].name = "region";

    /* install the kind methods */
    TypeObjFuncs[ T_THREAD ] = TypeThread;
    TypeObjFuncs[ T_SEMAPHORE ] = TypeSemaphore;
    TypeObjFuncs[ T_CHANNEL ] = TypeChannel;
    TypeObjFuncs[ T_BARRIER ] = TypeBarrier;
    TypeObjFuncs[ T_SYNCVAR ] = TypeSyncVar;
    TypeObjFuncs[ T_REGION ] = TypeRegion;
    /* install global variables */
    InitCopyGVar("TYPE_THREAD", &TYPE_THREAD);
    InitCopyGVar("TYPE_SEMAPHORE", &TYPE_SEMAPHORE);
    InitCopyGVar("TYPE_CHANNEL", &TYPE_CHANNEL);
    InitCopyGVar("TYPE_BARRIER", &TYPE_BARRIER);
    InitCopyGVar("TYPE_SYNCVAR", &TYPE_SYNCVAR);
    InitCopyGVar("TYPE_REGION", &TYPE_REGION);
    DeclareGVar(&LastInaccessibleGVar,"LastInaccessible");
    DeclareGVar(&MAX_INTERRUPTGVar,"MAX_INTERRUPT");
    /* install mark functions */
    InitMarkFuncBags(T_THREAD, MarkNoSubBags);
    InitMarkFuncBags(T_SEMAPHORE, MarkSemaphoreBag);
    InitMarkFuncBags(T_CHANNEL, MarkChannelBag);
    InitMarkFuncBags(T_BARRIER, MarkBarrierBag);
    InitMarkFuncBags(T_SYNCVAR, MarkSyncVarBag);
    InitMarkFuncBags(T_MONITOR, MarkNoSubBags);
    InitMarkFuncBags(T_REGION, MarkAllSubBags);
    InitFinalizerFuncBags(T_MONITOR, FinalizeMonitor);
    /* install print functions */
    PrintObjFuncs[ T_THREAD ] = PrintThread;
    PrintObjFuncs[ T_SEMAPHORE ] = PrintSemaphore;
    PrintObjFuncs[ T_CHANNEL ] = PrintChannel;
    PrintObjFuncs[ T_BARRIER ] = PrintBarrier;
    PrintObjFuncs[ T_SYNCVAR ] = PrintSyncVar;
    PrintObjFuncs[ T_REGION ] = PrintRegion;
    /* install mutability functions */
    IsMutableObjFuncs [ T_THREAD ] = NeverMutable;
    IsMutableObjFuncs [ T_SEMAPHORE ] = AlwaysMutable;
    IsMutableObjFuncs [ T_CHANNEL ] = AlwaysMutable;
    IsMutableObjFuncs [ T_BARRIER ] = AlwaysMutable;
    IsMutableObjFuncs [ T_SYNCVAR ] = AlwaysMutable;
    IsMutableObjFuncs [ T_REGION ] = AlwaysMutable;
    MakeBagTypePublic(T_THREAD);
    MakeBagTypePublic(T_SEMAPHORE);
    MakeBagTypePublic(T_CHANNEL);
    MakeBagTypePublic(T_REGION);
    MakeBagTypePublic(T_SYNCVAR);
    MakeBagTypePublic(T_BARRIER);
    PublicRegion = NewBag(T_REGION, sizeof(Region *));
    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    extern pthread_mutex_t KeepAliveLock;

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );
    SetGVar(&MAX_INTERRUPTGVar, INTOBJ_INT(MAX_INTERRUPT));
    MakeReadOnlyGVar(GVarName("MAX_INTERRUPT"));
    /* define signal handler values */
    RNAM_SIGINT = RNamName("SIGINT");
    RNAM_SIGCHLD = RNamName("SIGCHLD");
    RNAM_SIGVTALRM = RNamName("SIGVTALRM");
#ifdef SIGWINCH
    RNAM_SIGWINCH = RNamName("SIGWINCH");
#endif

    /* synchronization */
    pthread_mutex_init(&KeepAliveLock, NULL);

    /* return success                                                      */
    return 0;
}

void InitThreadAPITLS()
{
}

void DestroyThreadAPITLS()
{
}


/****************************************************************************
**
*F  InitInfoThreadAPI() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "threadapi",                        /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                         		/* postRestore                    */
};

StructInitInfo * InitInfoThreadAPI ( void )
{
    return &module;
}

static void MarkSemaphoreBag(Bag bag)
{
  Semaphore *sem = (Semaphore *)(PTR_BAG(bag));
  MARK_BAG(sem->monitor);
}

static void MarkChannelBag(Bag bag)
{
  Channel *channel = (Channel *)(PTR_BAG(bag));
  MARK_BAG(channel->queue);
  MARK_BAG(channel->monitor);
}

static void MarkBarrierBag(Bag bag)
{
  Barrier *barrier = (Barrier *)(PTR_BAG(bag));
  MARK_BAG(barrier->monitor);
}

static void MarkSyncVarBag(Bag bag)
{
  SyncVar *syncvar = (SyncVar *)(PTR_BAG(bag));
  MARK_BAG(syncvar->queue);
  MARK_BAG(syncvar->monitor);
}

static void FinalizeMonitor(Bag bag)
{
  Monitor *monitor = (Monitor *)(PTR_BAG(bag));
  pthread_mutex_destroy(&monitor->lock);
}

static void LockChannel(Channel *channel)
{
  LockMonitor(ObjPtr(channel->monitor));
}

static void UnlockChannel(Channel *channel)
{
  UnlockMonitor(ObjPtr(channel->monitor));
}

static void SignalChannel(Channel *channel)
{
  if (channel->waiting)
    SignalMonitor(ObjPtr(channel->monitor));
}

static void WaitChannel(Channel *channel)
{
  channel->waiting++;
  WaitForMonitor(ObjPtr(channel->monitor));
  channel->waiting--;
}

#ifndef WARD_ENABLED
static void ExpandChannel(Channel *channel)
{
  /* Growth ratio should be less than the golden ratio */
  UInt oldCapacity = channel->capacity;
  UInt newCapacity = ((oldCapacity * 25 / 16) | 1) + 1;
  UInt i, tail;
  Obj newqueue;
  if (newCapacity == oldCapacity)
    newCapacity+=2;
  newqueue = NEW_PLIST(T_PLIST, newCapacity);
  SET_LEN_PLIST(newqueue, newCapacity);
  REGION(newqueue) = REGION(channel->queue);
  channel->capacity = newCapacity;
  /* assert(channel->head == channel->tail); */
  for (i = channel->head; i < oldCapacity; i++)
    ADDR_OBJ(newqueue)[i+1] = ADDR_OBJ(channel->queue)[i+1];
  for (i = 0; i < channel->tail; i++)
  {
    UInt d = oldCapacity+i;
    if (d >= newCapacity)
      d -= newCapacity;
    ADDR_OBJ(newqueue)[d+1] = ADDR_OBJ(channel->queue)[i+1];
  }
  tail = channel->head + oldCapacity;
  if (tail >= newCapacity)
    tail -= newCapacity;
  channel->tail = tail;
  channel->queue = newqueue;
}

static void AddToChannel(Channel *channel, Obj obj, int migrate)
{
  Obj children;
  Region *region = REGION(channel->queue);
  UInt i, len;
  if (migrate && IS_BAG_REF(obj) &&
      REGION(obj) && REGION(obj)->owner == realTLS && REGION(obj)->fixed_owner) {
    children = ReachableObjectsFrom(obj);
    len = children ? LEN_PLIST(children) : 0;
  } else {
    children = 0;
    len = 0;
  }
  for (i=1; i<= len; i++) {
    Obj item = ELM_PLIST(children, i);
    REGION(item) = region;
  }
  ADDR_OBJ(channel->queue)[++channel->tail] = obj;
  ADDR_OBJ(channel->queue)[++channel->tail] = children;
  if (channel->tail == channel->capacity)
    channel->tail = 0;
  channel->size += 2;
}

static Obj RetrieveFromChannel(Channel *channel)
{
  Obj obj = ADDR_OBJ(channel->queue)[++channel->head];
  Obj children = ADDR_OBJ(channel->queue)[++channel->head];
  Region *region = TLS(currentRegion);
  UInt i, len = children ? LEN_PLIST(children) : 0;
  ADDR_OBJ(channel->queue)[channel->head-1] = 0;
  ADDR_OBJ(channel->queue)[channel->head] = 0;
  if (channel->head == channel->capacity)
    channel->head = 0;
  for (i=1; i<= len; i++) {
    Obj item = ELM_PLIST(children, i);
    REGION(item) = region;
  }
  channel->size -= 2;
  return obj;
}
#endif

static void ContractChannel(Channel *channel)
{
  /* Not yet implemented */
}

static Int TallyChannel(Channel *channel)
{
  Int result;
  LockChannel(channel);
  result = channel->size/2;
  UnlockChannel(channel);
  return result;
}

static void SendChannel(Channel *channel, Obj obj)
{
  LockChannel(channel);
  if (channel->size == channel->capacity && channel->dynamic)
    ExpandChannel(channel);
  while (channel->size == channel->capacity)
    WaitChannel(channel);
  AddToChannel(channel, obj, 1);
  SignalChannel(channel);
  UnlockChannel(channel);
}

static void TransmitChannel(Channel *channel, Obj obj)
{
  LockChannel(channel);
  if (channel->size == channel->capacity && channel->dynamic)
    ExpandChannel(channel);
  while (channel->size == channel->capacity)
    WaitChannel(channel);
  AddToChannel(channel, obj, 0);
  SignalChannel(channel);
  UnlockChannel(channel);
}


static void MultiSendChannel(Channel *channel, Obj list)
{
  int listsize = LEN_LIST(list);
  int i;
  Obj obj;
  LockChannel(channel);
  for (i = 1; i <= listsize; i++)
  {
    if (channel->size == channel->capacity && channel->dynamic)
      ExpandChannel(channel);
    while (channel->size == channel->capacity)
      WaitChannel(channel);
    obj = ELM_LIST(list, i);
    AddToChannel(channel, obj, 1);
  }
  SignalChannel(channel);
  UnlockChannel(channel);
}

static void MultiTransmitChannel(Channel *channel, Obj list)
{
  int listsize = LEN_LIST(list);
  int i;
  Obj obj;
  LockChannel(channel);
  for (i = 1; i <= listsize; i++)
  {
    if (channel->size == channel->capacity && channel->dynamic)
      ExpandChannel(channel);
    while (channel->size == channel->capacity)
      WaitChannel(channel);
    obj = ELM_LIST(list, i);
    AddToChannel(channel, obj, 0);
  }
  SignalChannel(channel);
  UnlockChannel(channel);
}

static int TryMultiSendChannel(Channel *channel, Obj list)
{
  int result = 0;
  int listsize = LEN_LIST(list);
  int i;
  Obj obj;
  LockChannel(channel);
  for (i = 1; i <= listsize; i++)
  {
    if (channel->size == channel->capacity && channel->dynamic)
      ExpandChannel(channel);
    if (channel->size == channel->capacity)
      break;
    obj = ELM_LIST(list, i);
    AddToChannel(channel, obj, 1);
    result++;
  }
  SignalChannel(channel);
  UnlockChannel(channel);
  return result;
}

static int TryMultiTransmitChannel(Channel *channel, Obj list)
{
  int result = 0;
  int listsize = LEN_LIST(list);
  int i;
  Obj obj;
  LockChannel(channel);
  for (i = 1; i <= listsize; i++)
  {
    if (channel->size == channel->capacity && channel->dynamic)
      ExpandChannel(channel);
    if (channel->size == channel->capacity)
      break;
    obj = ELM_LIST(list, i);
    AddToChannel(channel, obj, 0);
    result++;
  }
  SignalChannel(channel);
  UnlockChannel(channel);
  return result;
}

static int TrySendChannel(Channel *channel, Obj obj)
{
  LockChannel(channel);
  if (channel->size == channel->capacity && channel->dynamic)
    ExpandChannel(channel);
  if (channel->size == channel->capacity)
  {
    UnlockChannel(channel);
    return 0;
  }
  AddToChannel(channel, obj, 1);
  SignalChannel(channel);
  UnlockChannel(channel);
  return 1;
}

static int TryTransmitChannel(Channel *channel, Obj obj)
{
  LockChannel(channel);
  if (channel->size == channel->capacity && channel->dynamic)
    ExpandChannel(channel);
  if (channel->size == channel->capacity)
  {
    UnlockChannel(channel);
    return 0;
  }
  AddToChannel(channel, obj, 0);
  SignalChannel(channel);
  UnlockChannel(channel);
  return 1;
}

static Obj ReceiveChannel(Channel *channel)
{
  Obj result;
  LockChannel(channel);
  while (channel->size == 0)
    WaitChannel(channel);
  result = RetrieveFromChannel(channel);
  SignalChannel(channel);
  UnlockChannel(channel);
  return result;
}

static Obj ReceiveAnyChannel(Obj channelList, int with_index)
{
  UInt count = LEN_PLIST(channelList);
  UInt i, p;
  Monitor **monitors = alloca(count * sizeof(Monitor *));
  Channel **channels = alloca(count * sizeof(Channel *));
  Obj result;
  Channel *channel;
  for (i = 0; i<count; i++)
    channels[i] = ObjPtr(ELM_PLIST(channelList, i+1));
  SortChannels(count, channels);
  for (i = 0; i<count; i++)
    monitors[i] = ObjPtr(channels[i]->monitor);
  LockMonitors(count, monitors);
  p = TLS(multiplexRandomSeed);
  p = (p * 5 + 1);
  TLS(multiplexRandomSeed) = p;
  p %= count;
  for (i=0; i<count; i++)
  {
    channel = channels[p];
    if (channel->size > 0)
      break;
    p++;
    if (p >= count)
      p = 0;
  }
  if (i < count) /* found a channel with data */
  {
    p = i;
    for (i=0; i<count; i++)
      if (i != p)
        UnlockMonitor(monitors[i]);
  }
  else /* all channels are empty */
    for (;;)
    {
      for (i=0; i<count; i++)
        channels[i]->waiting++;
      p = WaitForAnyMonitor(count, monitors);
      for (i=0; i<count; i++)
        channels[i]->waiting--;
      channel = channels[p];
      if (channel->size > 0)
	break;
      UnlockMonitor(monitors[p]);
      LockMonitors(count, monitors);
    }
  result = RetrieveFromChannel(channel);
  SignalChannel(channel);
  UnlockMonitor(monitors[p]);
  if (with_index)
  {
    Obj list = NEW_PLIST(T_PLIST, 2);
    SET_LEN_PLIST(list, 2);
    SET_ELM_PLIST(list, 1, result);
    for (i=1; i<=count; i++)
      if (ObjPtr(ELM_PLIST(channelList, i)) == channel) {
        SET_ELM_PLIST(list, 2, INTOBJ_INT(i));
	break;
      }
    return list;
  }
  else
    return result;
}

static Obj MultiReceiveChannel(Channel *channel, UInt max)
{
  Obj result;
  UInt count;
  UInt i;
  LockChannel(channel);
  if (max > channel->size/2)
    count = channel->size/2;
  else
    count = max;
  result = NEW_PLIST(T_PLIST, count);
  SET_LEN_PLIST(result, count);
  for (i=0; i<count; i++)
  {
    Obj item = RetrieveFromChannel(channel);
    SET_ELM_PLIST(result, i+1, item);
  }
  SignalChannel(channel);
  UnlockChannel(channel);
  return result;
}

static Obj InspectChannel(Channel *channel)
{
  Obj result;
  int i, p;
  LockChannel(channel);
  result = NEW_PLIST(T_PLIST, channel->size/2);
  SET_LEN_PLIST(result, channel->size/2);
  for (i = 0, p = channel->head; i < channel->size; i++) {
    SET_ELM_PLIST(result, i+1, ELM_PLIST(channel->queue, p+1));
    p+=2;
    if (p == channel->capacity)
      p = 0;
  }
  UnlockChannel(channel);
  return result;
}

static Obj TryReceiveChannel(Channel *channel, Obj defaultobj)
{
  Obj result;
  LockChannel(channel);
  if (channel->size == 0)
  {
    UnlockChannel(channel);
    return defaultobj;
  }
  result = RetrieveFromChannel(channel);
  SignalChannel(channel);
  UnlockChannel(channel);
  return result;
}

static Obj CreateChannel(int capacity)
{
  Channel *channel;
  Bag channelBag;
  channelBag = NewBag(T_CHANNEL, sizeof(Channel));
  channel = ObjPtr(channelBag);
  channel->monitor = NewMonitor();
  channel->size = channel->head = channel->tail = 0;
  channel->capacity = (capacity < 0) ? 20 : capacity * 2;
  channel->dynamic = (capacity < 0);
  channel->waiting = 0;
  channel->queue = NEW_PLIST( T_PLIST, channel->capacity);
  REGION(channel->queue) = LimboRegion;
  SET_LEN_PLIST(channel->queue, channel->capacity);
  return channelBag;
}

static int DestroyChannel(Channel *channel)
{
  return 1;
}

Obj FuncCreateChannel(Obj self, Obj args)
{
  int capacity;
  switch (LEN_PLIST(args))
  {
    case 0:
      capacity = -1;
      break;
    case 1:
      if (IS_INTOBJ(ELM_PLIST(args, 1)))
      {
	capacity = INT_INTOBJ(ELM_PLIST(args, 1));
	if (capacity <= 0)
	  ArgumentError("CreateChannel: Capacity must be positive");
	break;
      }
      ArgumentError("CreateChannel: Argument must be capacity of the channel");
    default:
      ArgumentError("CreateChannel: Function takes up to two arguments");
      return (Obj) 0; /* control flow hint */
  }
  return CreateChannel(capacity);
}

static int IsChannel(Obj obj)
{
  return obj && TNUM_OBJ(obj) == T_CHANNEL;
}

Obj FuncDestroyChannel(Obj self, Obj channel)
{
  if (!IsChannel(channel))
  {
    ArgumentError("DestroyChannel: Argument is not a channel");
    return (Obj) 0;
  }
  if (!DestroyChannel(ObjPtr(channel)))
    ArgumentError("DestroyChannel: Channel is in use");
  return (Obj) 0;
}

Obj FuncTallyChannel(Obj self, Obj channel)
{
  if (!IsChannel(channel))
    ArgumentError("TallyChannel: First argument must be a channel");
  return INTOBJ_INT(TallyChannel(ObjPtr(channel)));
}

Obj FuncSendChannel(Obj self, Obj channel, Obj obj)
{
  if (!IsChannel(channel))
    ArgumentError("SendChannel: First argument must be a channel");
  SendChannel(ObjPtr(channel), obj);
  return (Obj) 0;
}

Obj FuncTransmitChannel(Obj self, Obj channel, Obj obj)
{
  if (!IsChannel(channel))
    ArgumentError("TransmitChannel: First argument must be a channel");
  TransmitChannel(ObjPtr(channel), obj);
  return (Obj) 0;
}

Obj FuncMultiSendChannel(Obj self, Obj channel, Obj list)
{
  if (!IsChannel(channel))
    ArgumentError("MultiSendChannel: First argument must be a channel");
  if (!IS_DENSE_LIST(list))
    ArgumentError("MultiSendChannel: Second argument must be a dense list");
  MultiSendChannel(ObjPtr(channel), list);
  return (Obj) 0;
}

Obj FuncMultiTransmitChannel(Obj self, Obj channel, Obj list)
{
  if (!IsChannel(channel))
    ArgumentError("MultiTransmitChannel: First argument must be a channel");
  if (!IS_DENSE_LIST(list))
    ArgumentError("MultiTransmitChannel: Second argument must be a dense list");
  MultiTransmitChannel(ObjPtr(channel), list);
  return (Obj) 0;
}

Obj FuncTryMultiSendChannel(Obj self, Obj channel, Obj list)
{
  if (!IsChannel(channel))
    ArgumentError("TryMultiSendChannel: First argument must be a channel");
  if (!IS_DENSE_LIST(list))
    ArgumentError("TryMultiSendChannel: Second argument must be a dense list");
  return INTOBJ_INT(TryMultiSendChannel(ObjPtr(channel), list));
}


Obj FuncTryMultiTransmitChannel(Obj self, Obj channel, Obj list)
{
  if (!IsChannel(channel))
    ArgumentError("TryMultiTransmitChannel: First argument must be a channel");
  if (!IS_DENSE_LIST(list))
    ArgumentError("TryMultiTransmitChannel: Second argument must be a dense list");
  return INTOBJ_INT(TryMultiTransmitChannel(ObjPtr(channel), list));
}


Obj FuncTrySendChannel(Obj self, Obj channel, Obj obj)
{
  if (!IsChannel(channel))
    ArgumentError("TrySendChannel: Argument is not a channel");
  return TrySendChannel(ObjPtr(channel), obj) ? True : False;
}

Obj FuncTryTransmitChannel(Obj self, Obj channel, Obj obj)
{
  if (!IsChannel(channel))
    ArgumentError("TryTransmitChannel: Argument is not a channel");
  return TryTransmitChannel(ObjPtr(channel), obj) ? True : False;
}

Obj FuncReceiveChannel(Obj self, Obj channel)
{
  if (!IsChannel(channel))
    ArgumentError("ReceiveChannel: Argument is not a channel");
  return ReceiveChannel(ObjPtr(channel));
}

int IsChannelList(Obj list)
{
  int len = LEN_PLIST(list);
  int i;
  for (i=1; i<=len; i++)
    if (!IsChannel(ELM_PLIST(list, i)))
      return 0;
  return 1;
}

Obj FuncReceiveAnyChannel(Obj self, Obj args)
{
  if (IsChannelList(args))
    return ReceiveAnyChannel(args, 0);
  else
  {
    if (LEN_PLIST(args) == 1 && IS_PLIST(ELM_PLIST(args, 1))
        && IsChannelList(ELM_PLIST(args, 1)))
      return ReceiveAnyChannel(ELM_PLIST(args, 1), 0);
    else
    {
      ArgumentError("ReceiveAnyChannel: Argument list must be channels");
      return (Obj) 0;
    }
  }
}

Obj FuncReceiveAnyChannelWithIndex(Obj self, Obj args)
{
  if (IsChannelList(args))
    return ReceiveAnyChannel(args, 1);
  else
  {
    if (LEN_PLIST(args) == 1 && IS_PLIST(ELM_PLIST(args, 1))
        && IsChannelList(ELM_PLIST(args, 1)))
      return ReceiveAnyChannel(ELM_PLIST(args, 1), 1);
    else
    {
      ArgumentError("ReceiveAnyChannel: Argument list must be channels");
      return (Obj) 0;
    }
  }
}

Obj FuncMultiReceiveChannel(Obj self, Obj channel, Obj countobj)
{
  int count;
  if (!IsChannel(channel))
    ArgumentError("MultiReceiveChannel: Argument is not a channel");
  if (!IS_INTOBJ(countobj))
    ArgumentError("MultiReceiveChannel: Size must be a number");
  count = INT_INTOBJ(countobj);
  if (count < 0)
    ArgumentError("MultiReceiveChannel: Size must be non-negative");
  return MultiReceiveChannel(ObjPtr(channel), count);
}

Obj FuncInspectChannel(Obj self, Obj channel)
{
  if (!IsChannel(channel))
    ArgumentError("InspectChannel: Argument is not a channel");
  return InspectChannel(ObjPtr(channel));
}

Obj FuncTryReceiveChannel(Obj self, Obj channel, Obj obj)
{
  if (!IsChannel(channel))
    ArgumentError("TryReceiveChannel: Argument must be a channel");
  return TryReceiveChannel(ObjPtr(channel), obj);
}

static Obj CreateSemaphore(UInt count)
{
  Semaphore *sem;
  Bag semBag;
  semBag = NewBag(T_SEMAPHORE, sizeof(Semaphore));
  sem = ObjPtr(semBag);
  sem->monitor = NewMonitor();
  sem->count = count;
  sem->waiting = 0;
  return semBag;
}

Obj FuncCreateSemaphore(Obj self, Obj args)
{
  Int count;
  switch (LEN_PLIST(args))
  {
    case 0:
      count = 0;
      break;
    case 1:
      if (IS_INTOBJ(ELM_PLIST(args, 1)))
      {
	count = INT_INTOBJ(ELM_PLIST(args, 1));
	if (count < 0)
	  ArgumentError("CreateSemaphore: Initial count must be non-negative");
	break;
      }
      ArgumentError("CreateSemaphore: Argument must be initial count");
    default:
      ArgumentError("CreateSemaphore: Function takes up to two arguments");
      return (Obj) 0; /* control flow hint */
  }
  return CreateSemaphore(count);
}

Obj FuncSignalSemaphore(Obj self, Obj semaphore)
{
  Semaphore *sem;
  if (TNUM_OBJ(semaphore) != T_SEMAPHORE)
    ArgumentError("SignalSemaphore: Argument must be a semaphore");
  sem = ObjPtr(semaphore);
  LockMonitor(ObjPtr(sem->monitor));
  sem->count++;
  if (sem->waiting)
    SignalMonitor(ObjPtr(sem->monitor));
  UnlockMonitor(ObjPtr(sem->monitor));
  return (Obj) 0;
}

Obj FuncWaitSemaphore(Obj self, Obj semaphore)
{
  Semaphore *sem;
  if (TNUM_OBJ(semaphore) != T_SEMAPHORE)
    ArgumentError("WaitSemaphore: Argument must be a semaphore");
  sem = ObjPtr(semaphore);
  LockMonitor(ObjPtr(sem->monitor));
  sem->waiting++;
  while (sem->count == 0)
    WaitForMonitor(ObjPtr(sem->monitor));
  sem->count--;
  sem->waiting--;
  if (sem->waiting && sem->count > 0)
    SignalMonitor(ObjPtr(sem->monitor));
  UnlockMonitor(ObjPtr(sem->monitor));
  return (Obj) 0;
}

Obj FuncTryWaitSemaphore(Obj self, Obj semaphore)
{
  Semaphore *sem;
  int success;
  if (TNUM_OBJ(semaphore) != T_SEMAPHORE)
    ArgumentError("WaitSemaphore: Argument must be a semaphore");
  sem = ObjPtr(semaphore);
  LockMonitor(ObjPtr(sem->monitor));
  success = (sem->count > 0);
  if (success)
    sem->count--;
  sem->waiting--;
  if (sem->waiting && sem->count > 0)
    SignalMonitor(ObjPtr(sem->monitor));
  UnlockMonitor(ObjPtr(sem->monitor));
  return success ? True: False;
}

void LockBarrier(Barrier *barrier)
{
  LockMonitor(ObjPtr(barrier->monitor));
}

void UnlockBarrier(Barrier *barrier)
{
  UnlockMonitor(ObjPtr(barrier->monitor));
}

void JoinBarrier(Barrier *barrier)
{
  barrier->waiting++;
  WaitForMonitor(ObjPtr(barrier->monitor));
  barrier->waiting--;
}

void SignalBarrier(Barrier *barrier)
{
  if (barrier->waiting)
    SignalMonitor(ObjPtr(barrier->monitor));
}

Obj CreateBarrier()
{
  Bag barrierBag;
  Barrier *barrier;
  barrierBag = NewBag(T_BARRIER, sizeof(Barrier));
  barrier = ObjPtr(barrierBag);
  barrier->monitor = NewMonitor();
  barrier->count = 0;
  barrier->phase = 0;
  barrier->waiting = 0;
  return barrierBag;
}

void StartBarrier(Barrier *barrier, UInt count)
{
  LockBarrier(barrier);
  barrier->count = count;
  barrier->phase++;
  UnlockBarrier(barrier);
}

void WaitBarrier(Barrier *barrier)
{
  UInt phaseDelta;
  LockBarrier(barrier);
  phaseDelta = barrier->phase;
  if (--barrier->count > 0)
    JoinBarrier(barrier);
  SignalBarrier(barrier);
  phaseDelta -= barrier->phase;
  UnlockBarrier(barrier);
  if (phaseDelta != 0)
    ArgumentError("WaitBarrier: Barrier was reset");
}

Obj FuncCreateBarrier(Obj self)
{
  return CreateBarrier();
}

Obj FuncDestroyBarrier(Obj self, Obj barrier)
{
  return (Obj) 0;
}

int IsBarrier(Obj obj)
{
  return obj && TNUM_OBJ(obj) == T_BARRIER;
}

Obj FuncStartBarrier(Obj self, Obj barrier, Obj count)
{
  if (!IsBarrier(barrier))
    ArgumentError("StartBarrier: First argument must be a barrier");
  if (!IS_INTOBJ(count))
    ArgumentError("StartBarrier: Second argument must be the number of threads to synchronize");
  StartBarrier(ObjPtr(barrier), INT_INTOBJ(count));
  return (Obj) 0;
}

Obj FuncWaitBarrier(Obj self, Obj barrier)
{
  if (!IsBarrier(barrier))
    ArgumentError("StartBarrier: Argument must be a barrier");
  WaitBarrier(ObjPtr(barrier));
  return (Obj) 0;
}

void SyncWrite(SyncVar *var, Obj value)
{
  Monitor *monitor = ObjPtr(var->monitor);
  LockMonitor(monitor);
  if (var->written)
  {
    UnlockMonitor(monitor);
    ArgumentError("SyncWrite: Variable already has a value");
    return;
  }
  var->written = 1;
  var->value = value;
  SignalMonitor(monitor);
  UnlockMonitor(monitor);
}

int SyncTryWrite(SyncVar *var, Obj value)
{
  Monitor *monitor = ObjPtr(var->monitor);
  LockMonitor(monitor);
  if (var->written)
  {
    UnlockMonitor(monitor);
    return 0;
  }
  var->written = 1;
  var->value = value;
  SignalMonitor(monitor);
  UnlockMonitor(monitor);
  return 1;
}

Obj CreateSyncVar()
{
  Bag syncvarBag;
  SyncVar *syncvar;
  syncvarBag = NewBag(T_SYNCVAR, sizeof(SyncVar));
  syncvar = ObjPtr(syncvarBag);
  syncvar->monitor = NewMonitor();
  syncvar->written = 0;
  syncvar->value = (Obj) 0;
  return syncvarBag;
}


Obj SyncRead(SyncVar *var)
{
  Monitor *monitor = ObjPtr(var->monitor);
  LockMonitor(monitor);
  while (!var->written)
    WaitForMonitor(monitor);
  if (monitor->head != NULL)
    SignalMonitor(monitor);
  UnlockMonitor(monitor);
  return var->value;
}

Obj SyncIsBound(SyncVar *var)
{
  return var->value ? True : False;
}

int IsSyncVar(Obj var)
{
  return var && TNUM_OBJ(var) == T_SYNCVAR;
}

Obj FuncCreateSyncVar(Obj self)
{
  return CreateSyncVar();
}

Obj FuncSyncWrite(Obj self, Obj var, Obj value)
{
  if (!IsSyncVar(var))
    ArgumentError("SyncWrite: First argument must be a synchronization variable");
  SyncWrite(ObjPtr(var), value);
  return (Obj) 0;
}

Obj FuncSyncTryWrite(Obj self, Obj var, Obj value)
{
  if (!IsSyncVar(var))
    ArgumentError("SyncTryWrite: First argument must be a synchronization variable");
  return SyncTryWrite(ObjPtr(var), value) ? True : False;
}

Obj FuncSyncRead(Obj self, Obj var)
{
  if (!IsSyncVar(var))
    ArgumentError("SyncRead: Argument must be a synchronization variable");
  return SyncRead(ObjPtr(var));
}

Obj FuncSyncIsBound(Obj self, Obj var)
{
  if (!IsSyncVar(var))
    ArgumentError("SyncRead: Argument must be a synchronization variable");
  return SyncIsBound(ObjPtr(var));
}


static void PrintThread(Obj obj)
{
  char buf[100];
  char *status_message;
  Int status;
  Int id;
  LockThreadControl(0);
  id = *(UInt *)(ADDR_OBJ(obj)+1);
  status = *(UInt *)(ADDR_OBJ(obj)+2);
  switch (status)
  {
    case 0:
      status_message = "running";
      break;
    case THREAD_TERMINATED:
      status_message = "terminated";
      break;
    case THREAD_JOINED:
      status_message = "running, waited for";
      break;
    case THREAD_TERMINATED | THREAD_JOINED:
      status_message = "terminated, waited for";
      break;
    default:
      status_message = "unknown status";
      break;
  }
  sprintf(buf, "<thread #%ld: %s>", (long) id, status_message);
  UnlockThreadControl();
  Pr("%s", (Int) buf, 0L);
}

static void PrintSemaphore(Obj obj)
{
  Semaphore *sem = ObjPtr(obj);
  Int count;
  char buffer[100];
  LockMonitor(ObjPtr(sem->monitor));
  count = sem->count;
  UnlockMonitor(ObjPtr(sem->monitor));
  sprintf(buffer, "<semaphore %p: count = %ld>", sem, (long) count);
  Pr("%s", (Int) buffer, 0L);
}

static void PrintChannel(Obj obj)
{
  Channel *channel = ObjPtr(obj);
  Int size, waiting, capacity;
  int dynamic;
  char buffer[20];
  Pr("<channel ", 0L, 0L);
  sprintf(buffer, "%p: ", channel);
  Pr(buffer, 0L, 0L);
  LockChannel(channel);
  size = channel->size;
  waiting = channel->waiting;
  if (channel->dynamic)
    capacity = -1;
  else
    capacity = channel->capacity;
  UnlockChannel(channel);
  if (capacity < 0)
    Pr("%d elements, %d waiting>", size/2, waiting);
  else
  {
    Pr("%d/%d elements, ", size/2, capacity/2);
    Pr("%d waiting>", waiting, 0L);
  }
}

static void PrintBarrier(Obj obj)
{
  Barrier *barrier = ObjPtr(obj);
  Int count, waiting;
  char buffer[20];
  Pr("<barrier ", 0L, 0L);
  sprintf(buffer, "%p: ", barrier);
  Pr(buffer, 0L, 0L);
  LockBarrier(barrier);
  count = barrier->count;
  waiting = barrier->waiting;
  UnlockBarrier(barrier);
  Pr("%d of %d threads arrived>", waiting, count);
}

static void PrintSyncVar(Obj obj)
{
  SyncVar *syncvar = ObjPtr(obj);
  char buffer[20];
  int written;
  LockMonitor(ObjPtr(syncvar->monitor));
  written = syncvar->written;
  UnlockMonitor(ObjPtr(syncvar->monitor));
  if (written)
    Pr("<initialized syncvar ", 0L, 0L);
  else
    Pr("<uninitialized syncvar ", 0L, 0L);
  sprintf(buffer, "%p>", syncvar);
  Pr(buffer, 0L, 0L);
}

static void PrintRegion(Obj obj)
{
  char buffer[32];
  Region *region = GetRegionOf(obj);
  Obj name = GetRegionName(region);

  if (name) {
    Pr("<region: %s", (Int)(CSTR_STRING(name)), 0L);
  } else {
    snprintf(buffer, 32, "<region %p", GetRegionOf(obj));
    Pr(buffer, 0L, 0L);
  }
  if (region && region->count_active) {
    snprintf(buffer, 32, " (locked %zu/contended %zu)"
	     , region->locks_acquired, region->locks_contended);
    Pr(buffer, 0L, 0L);
  }
  Pr(">", 0L, 0L);
}

Obj FuncIS_LOCKED(Obj self, Obj obj)
{
  Region *region = IS_BAG_REF(obj) ? REGION(obj) : NULL;
  if (!region)
    return INTOBJ_INT(0);
  return INTOBJ_INT(IsLocked(region));
}

void DoLockFunc(Obj args, int mode)
{
  Int numargs = LEN_PLIST(args);
  int *modes;
  Int i;
  if (numargs > 1024) {
    ErrorQuit("%s: Too many arguments",
      mode ? (UInt) "WriteLock" : (UInt) "ReadLock", 0L);
  }
  if (TLS(lockStackPointer) == 0) {
    ErrorQuit("%s: Not inside an atomic region or function",
      mode ? (UInt) "WriteLock" : (UInt) "ReadLock", 0L);
  }
  modes = alloca(sizeof(int) * numargs);
  for (i=0; i<numargs; i++) {
    modes[i] = mode;
  }
  if (LockObjects((int) numargs, ADDR_OBJ(args)+1, modes) < 0) {
    ErrorQuit("%s: Could not lock objects",
      mode ? (UInt) "WriteLock" : (UInt) "ReadLock", 0L);
  }
}


Obj FuncWriteLock(Obj self, Obj args)
{
  DoLockFunc(args, 1);
  return (Obj) 0;
}

Obj FuncReadLock(Obj self, Obj args)
{
  DoLockFunc(args, 0);
  return (Obj) 0;
}

Obj FuncLOCK(Obj self, Obj args)
{
  int numargs = LEN_PLIST(args);
  int count = 0;
  Obj *objects;
  int *modes;
  int mode = 1;
  int i;
  int result;

  if (numargs > 1024)
    ArgumentError("LOCK: Too many arguments");
  objects = alloca(sizeof(Obj) * numargs);
  modes = alloca(sizeof(int) * numargs);
  for (i=1; i<=numargs; i++)
  {
    Obj obj;
    obj = ELM_PLIST(args, i);
    if (obj == True)
      mode = 1;
    else if (obj == False)
      mode = 0;
    else if (IS_INTOBJ(obj))
      mode = (INT_INTOBJ(obj) && 1);
    else {
      objects[count] = obj;
      modes[count] = mode;
      count++;
    }
  }
  result = LockObjects(count, objects, modes);
  if (result >= 0)
    return INTOBJ_INT(result);
  return Fail;
}

Obj FuncDO_LOCK(Obj self, Obj args)
{
  Obj result = FuncLOCK(self, args);
  if (result == Fail)
    ErrorMayQuit("Cannot lock required regions", 0L, 0L);
  return result;
}

Obj FuncWRITE_LOCK(Obj self, Obj obj)
{
  int result;
  static int modes[] = { 1 };
  result = LockObjects(1, &obj, modes);
  if (result >= 0)
    return INTOBJ_INT(result);
  ErrorMayQuit("Cannot lock required regions", 0L, 0L);
  return (Obj) 0; /* flow control hint */
}

Obj FuncREAD_LOCK(Obj self, Obj obj)
{
  int result;
  static int modes[] = { 0 };
  result = LockObjects(1, &obj, modes);
  if (result >= 0)
    return INTOBJ_INT(result);
  ErrorMayQuit("Cannot lock required regions", 0L, 0L);
  return (Obj) 0; /* flow control hint */
}

Obj FuncTRYLOCK(Obj self, Obj args)
{
  int numargs = LEN_PLIST(args);
  int count = 0;
  Obj *objects;
  int *modes;
  int mode = 1;
  int i;
  int result;

  if (numargs > 1024)
    ArgumentError("TRYLOCK: Too many arguments");
  objects = alloca(sizeof(Obj) * numargs);
  modes = alloca(sizeof(int) * numargs);
  for (i=1; i<=numargs; i++)
  {
    Obj obj;
    obj = ELM_PLIST(args, i);
    if (obj == True)
      mode = 1;
    else if (obj == False)
      mode = 0;
    else if (IS_INTOBJ(obj))
      mode = (INT_INTOBJ(obj) && 1);
    else {
      objects[count] = obj;
      modes[count] = mode;
      count++;
    }
  }
  result = TryLockObjects(count, objects, modes);
  if (result >= 0)
    return INTOBJ_INT(result);
  return Fail;
}

Obj FuncUNLOCK(Obj self, Obj sp)
{
  if (!IS_INTOBJ(sp) || INT_INTOBJ(sp) < 0)
    ArgumentError("UNLOCK: argument must be a non-negative integer");
  PopRegionLocks(INT_INTOBJ(sp));
  return (Obj) 0;
}

Obj FuncCURRENT_LOCKS(Obj self)
{
  UInt i, len = TLS(lockStackPointer);
  Obj result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=1; i<=len; i++)
    SET_ELM_PLIST(result, i, ELM_PLIST(TLS(lockStack), i));
  return result;
}

static int AutoRetyping = 0;

static int MigrateObjects(int count, Obj *objects, Region *target, int retype)
{
  int i;
  if (retype && IS_BAG_REF(objects[0]) && REGION(objects[0])->owner == realTLS
      && AutoRetyping) {
    for (i=0; i<count; i++)
      if (REGION(objects[i])->owner == realTLS)
	CLEAR_OBJ_FLAG(objects[i], TESTED);
    for (i=0; i<count; i++) {
      if (REGION(objects[i])->owner == realTLS && IS_PLIST(objects[i])) {
        if (!TEST_OBJ_FLAG(objects[i], TESTED))
	  TYPE_OBJ(objects[i]);
	if (retype >= 2)
	  IsSet(objects[i]);
      }
    }
  }
  for (i=0; i<count; i++) {
    Region *region;
    if (IS_BAG_REF(objects[i])) {
      region = (Region *)(REGION(objects[i]));
      if (TEST_OBJ_FLAG(objects[i], FIXED_REGION))
        return 0;
      if (!region || region->owner != realTLS || region == ProtectedRegion)
        return 0;
    }
  }
  for (i=0; i<count; i++)
    REGION(objects[i]) = target;
  return 1;
}

Obj FuncREFINE_TYPE(Obj self, Obj obj) {
  if (IS_BAG_REF(obj) && CheckExclusiveWriteAccess(obj)) {
    TYPE_OBJ(obj);
  }
  return obj;
}

Obj FuncMAKE_PUBLIC_NORECURSE(Obj self, Obj obj)
{
  if (!MigrateObjects(1, &obj, NULL, 0))
    ArgumentError("MAKE_PUBLIC_NORECURSE: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncFORCE_MAKE_PUBLIC(Obj self, Obj obj)
{
  if (!IS_BAG_REF(obj))
    ArgumentError("FORCE_MAKE_PUBLIC: Argument is a short integer or finite-field element");
  MakeBagPublic(obj);
  return obj;
}


Obj FuncFIX_OBJ_REGION(Obj self, Obj obj)
{
  if (!IS_BAG_REF(obj))
    ArgumentError("FIX_OBJ_REGION: Argument must not be a short integer or finite field element");
  if (!CheckExclusiveWriteAccess(obj))
    ArgumentError("FIX_OBJ_REGION: Thread does not have exclusive access to object");
  SET_OBJ_FLAG(obj, FIXED_REGION);
  return obj;
}

Obj FuncSHARE_NORECURSE(Obj self, Obj obj, Obj name, Obj prec)
{
  Region *region = NewRegion();
  Obj reachable;
  if (name != Fail && !IsStringConv(name))
    ArgumentError("SHARE_NORECURSE: Second argument must be a string or fail");
  if (!IS_INTOBJ(prec))
    ArgumentError("SHARE_NORECURSE: Third argument must be an integer");
  region->prec = INT_INTOBJ(prec);
  if (!MigrateObjects(1, &obj, region, 0))
    ArgumentError("SHARE_NORECURSE: Thread does not have exclusive access to objects");
  if (name != Fail)
    SetRegionName(region, name);
  return obj;
}

Obj FuncMIGRATE_NORECURSE(Obj self, Obj obj, Obj target)
{
  Region *target_region = GetRegionOf(target);
  if (!target_region || IsLocked(target_region) != 1)
    ArgumentError("MIGRATE_NORECURSE: Thread does not have exclusive access to target region");
  if (!MigrateObjects(1, &obj, target_region, 0))
    ArgumentError("MIGRATE_NORECURSE: Thread does not have exclusive access to object");
  return obj;
}

Obj FuncADOPT_NORECURSE(Obj self, Obj obj)
{
  if (!MigrateObjects(1, &obj, TLS(threadRegion), 0))
    ArgumentError("ADOPT_NORECURSE: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncREACHABLE(Obj self, Obj obj)
{
  Obj result = ReachableObjectsFrom(obj);
  if (result == NULL) {
    result = NEW_PLIST(T_PLIST, 1);
    SET_LEN_PLIST(result, 1);
    SET_ELM_PLIST(result, 1, obj);
  }
  return result;
}

Obj FuncCLONE_REACHABLE(Obj self, Obj obj)
{
  return CopyReachableObjectsFrom(obj, 0, 0, 0);
}

Obj FuncCLONE_DELIMITED(Obj self, Obj obj)
{
  return CopyReachableObjectsFrom(obj, 1, 0, 0);
}

Obj FuncNEW_REGION(Obj self, Obj name, Obj prec)
{
  Region *region = NewRegion();
  if (name != Fail && !IsStringConv(name))
    ArgumentError("NEW_REGION: Second argument must be a string or fail");
  if (!IS_INTOBJ(prec))
    ArgumentError("NEW_REGION: Third argument must be an integer");
  region->prec = INT_INTOBJ(prec);
  if (name != Fail)
    SetRegionName(region, name);
  return region->obj;
}

Obj FuncREGION_PRECEDENCE(Obj self, Obj regobj)
{
  Region *region = GetRegionOf(regobj);
  return region == NULL ? INTOBJ_INT(0) : INTOBJ_INT(region->prec);
}

Obj FuncSHARE(Obj self, Obj obj, Obj name, Obj prec)
{
  Region *region = NewRegion();
  Obj reachable;
  if (name != Fail && !IsStringConv(name))
    ArgumentError("SHARE: Second argument must be a string or fail");
  if (!IS_INTOBJ(prec))
    ArgumentError("SHARE: Third argument must be an integer");
  region->prec = INT_INTOBJ(prec);
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, region, 1))
    ArgumentError("SHARE: Thread does not have exclusive access to objects");
  if (name != Fail)
    SetRegionName(region, name);
  return obj;
}

Obj FuncSHARE_RAW(Obj self, Obj obj, Obj name, Obj prec)
{
  Region *region = NewRegion();
  Obj reachable;
  if (name != Fail && !IsStringConv(name))
    ArgumentError("SHARE_RAW: Second argument must be a string or fail");
  if (!IS_INTOBJ(prec))
    ArgumentError("SHARE_RAW: Third argument must be an integer");
  region->prec = INT_INTOBJ(prec);
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, region, 0))
    ArgumentError("SHARE_RAW: Thread does not have exclusive access to objects");
  if (name != Fail)
    SetRegionName(region, name);
  return obj;
}

Obj FuncADOPT(Obj self, Obj obj)
{
  Obj reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, TLS(threadRegion), 0))
    ArgumentError("ADOPT: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMAKE_PUBLIC(Obj self, Obj obj)
{
  Obj reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, NULL, 0))
    ArgumentError("MAKE_PUBLIC: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMIGRATE(Obj self, Obj obj, Obj target)
{
  Region *target_region = GetRegionOf(target);
  Obj reachable;
  if (!target_region || IsLocked(target_region) != 1)
    ArgumentError("MIGRATE: Thread does not have exclusive access to target region");
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, target_region, 1))
    ArgumentError("MIGRATE: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMIGRATE_RAW(Obj self, Obj obj, Obj target)
{
  Region *target_region = GetRegionOf(target);
  Obj reachable;
  if (!target_region || IsLocked(target_region) != 1)
    ArgumentError("MIGRATE: Thread does not have exclusive access to target region");
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, target_region, 0))
    ArgumentError("MIGRATE: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMakeThreadLocal(Obj self, Obj var)
{
  char *name;
  UInt gvar;
  if (!IsStringConv(var) || GET_LEN_STRING(var) == 0)
    ArgumentError("MakeThreadLocal: Argument must be a variable name");
  name = CSTR_STRING(var);
  gvar = GVarName(name);
  name = NameGVar(gvar); /* to apply namespace scopes where needed. */
  MakeThreadLocalVar(gvar, RNamName(name));
  return (Obj) 0;
}

Obj FuncMakeReadOnly(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);
  Obj reachable;
  if (!region || region == ReadOnlyRegion)
    return obj;
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, ReadOnlyRegion, 1))
    ArgumentError("MakeReadOnly: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMakeReadOnlyRaw(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);
  Obj reachable;
  if (!region || region == ReadOnlyRegion)
    return obj;
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, ReadOnlyRegion, 0))
    ArgumentError("MakeReadOnly: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMakeReadOnlyObj(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);
  Obj reachable;
  if (!region || region == ReadOnlyRegion)
    return obj;
  if (!MigrateObjects(1, &obj, ReadOnlyRegion, 0))
    ArgumentError("MakeReadOnlyObj: Thread does not have exclusive access to object");
  return obj;
}

Obj FuncMakeProtected(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);
  Obj reachable;
  if (region == ProtectedRegion)
    return obj;
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, ProtectedRegion, 1))
    ArgumentError("MakeProtected: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMakeProtectedObj(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);
  if (region == ProtectedRegion)
    return obj;
  if (!MigrateObjects(1, &obj, ProtectedRegion, 0))
    ArgumentError("MakeProtectedObj: Thread does not have exclusive access to object");
  return obj;
}

Obj FuncIsReadOnly(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);
  return (region == ReadOnlyRegion) ? True : False;
}

Obj FuncIsProtected(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);
  return (region == ProtectedRegion) ? True : False;
}

Obj FuncENABLE_AUTO_RETYPING(Obj self)
{
  AutoRetyping = 1;
  return (Obj) 0;
}

Obj FuncBEGIN_SINGLE_THREADED(Obj self)
{
  if (!IsSingleThreaded())
    ErrorQuit("BEGIN_SINGLE_THREADED: Multiple threads are running", 0L, 0L);
  BeginSingleThreaded();
  return (Obj) 0;
}

Obj FuncEND_SINGLE_THREADED(Obj self)
{
  if (!IsSingleThreaded())
    ErrorQuit("BEGIN_SINGLE_THREADED: Multiple threads are running", 0L, 0L);
  EndSingleThreaded();
  return (Obj) 0;
}

Obj FuncORDERED_READ(Obj self, Obj obj)
{
  MEMBAR_READ();
  return obj;
}

Obj FuncORDERED_WRITE(Obj self, Obj obj)
{
  MEMBAR_WRITE();
  return obj;
}

Obj FuncDEFAULT_SIGINT_HANDLER(Obj self) {
  /* do nothing */
  return (Obj) 0;
}

UInt SigVTALRMCounter = 0;

Obj FuncDEFAULT_SIGVTALRM_HANDLER(Obj self) {
  SigVTALRMCounter++;
  return (Obj) 0;
}

Obj FuncDEFAULT_SIGCHLD_HANDLER(Obj self) {
  extern void ChildStatusChanged(int signr);
  ChildStatusChanged(SIGCHLD);
  return (Obj) 0;
}

Obj FuncDEFAULT_SIGWINCH_HANDLER(Obj self) {
#ifdef SIGWINCH
  extern void syWindowChangeIntr(int signr);
  syWindowChangeIntr(SIGWINCH);
#endif
  return (Obj) 0;
}

static void HandleSignal(Obj handlers, UInt rnam)
{
  Obj func = ELM_REC(handlers, rnam);
  if (!func || TNUM_OBJ(func) != T_FUNCTION || NARG_FUNC(func) > 0)
    return;
  CALL_0ARGS(func);
}

static sigset_t GAPSignals;

Obj FuncSIGWAIT(Obj self, Obj handlers)
{
  int sig;
  if (!IS_REC(handlers))
    ArgumentError("SIGWAIT: Argument must be a record");
  if (sigwait(&GAPSignals, &sig) >= 0) {
    switch (sig) {
      case SIGINT:
        HandleSignal(handlers, RNAM_SIGINT);
	break;
      case SIGCHLD:
        HandleSignal(handlers, RNAM_SIGCHLD);
	break;
      case SIGVTALRM:
        HandleSignal(handlers, RNAM_SIGVTALRM);
	break;
#ifdef SIGWINCH
      case SIGWINCH:
        HandleSignal(handlers, RNAM_SIGWINCH);
	break;
#endif
    }
  }
  return (Obj) 0;
}

void InitSignals() {
  struct itimerval timer;
  sigemptyset(&GAPSignals);
  sigaddset(&GAPSignals, SIGINT);
  sigaddset(&GAPSignals, SIGCHLD);
  sigaddset(&GAPSignals, SIGVTALRM);
#ifdef SIGWINCH
  sigaddset(&GAPSignals, SIGWINCH);
#endif
  pthread_sigmask(SIG_BLOCK, &GAPSignals, NULL);
  /* Run a timer signal every 10 ms, i.e. 100 times per second */
  timer.it_interval.tv_sec = 0;
  timer.it_interval.tv_usec = 10000;
  timer.it_value.tv_sec = 0;
  timer.it_value.tv_usec = 10000;
  setitimer(ITIMER_VIRTUAL, &timer, NULL);
}

Obj FuncPERIODIC_CHECK(Obj self, Obj count, Obj func)
{
  UInt n;
  if (!IS_INTOBJ(count) || INT_INTOBJ(count) < 0)
    ArgumentError("PERIODIC_CHECK: First argument must be a non-negative small integer");
  if (TNUM_OBJ(func) != T_FUNCTION)
    ArgumentError("PERIODIC_CHECK: Second argument must be a function");
  /*
   * The following read of SigVTALRMCounter is a dirty read. We don't
   * need to synchronize access to it because it's a monotonically
   * increasing value and we only need it to succeed eventually.
   */
  n = INT_INTOBJ(count)/10;
  if (TLS(PeriodicCheckCount) + n < SigVTALRMCounter) {
    TLS(PeriodicCheckCount) = SigVTALRMCounter;
    CALL_0ARGS(func);
  }
  return (Obj) 0;
}


/*
 * Region lock performance counters
 */
Obj FuncREGION_COUNTERS_ENABLE(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);

  if(!region)
    ArgumentError("REGION_COUNTERS_ENABLE: Cannot enable counters for this region");

  region->count_active = 1;
  return (Obj) 0;
}

Obj FuncREGION_COUNTERS_DISABLE(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);

  if(!region)
    ArgumentError("REGION_COUNTERS_DISABLE: Cannot disable counters for this region");

  region->count_active = 0;
  return (Obj) 0;
}

Obj FuncREGION_COUNTERS_GET_STATE(Obj self, Obj obj)
{
  Obj result;
  Region *region = GetRegionOf(obj);

  if(!region)
    ArgumentError("REGION_COUNTERS_GET_STATE: Cannot get counters for this region");

  result = INTOBJ_INT(region->count_active);

  return result;
}

Obj FuncREGION_COUNTERS_GET(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);

  if(!region)
    ArgumentError("REGION_COUNTERS_GET: Cannot get counters for this region");

  return GetRegionLockCounters(region);
}

Obj FuncREGION_COUNTERS_RESET(Obj self, Obj obj)
{
  Region *region = GetRegionOf(obj);

  if(!region)
    ArgumentError("REGION_COUNTERS_RESET: Cannot reset counters for this region");

  ResetRegionLockCounters(region);

  return (Obj) 0;
}

Obj FuncTHREAD_COUNTERS_ENABLE(Obj self)
{
  TLS(CountActive) = 1;

  return (Obj) 0;
}

Obj FuncTHREAD_COUNTERS_DISABLE(Obj self)
{
  TLS(CountActive) = 0;

  return (Obj) 0;
}

Obj FuncTHREAD_COUNTERS_GET_STATE(Obj self)
{
  Obj result;

  result = INTOBJ_INT(TLS(CountActive));

  return result;
}

Obj FuncTHREAD_COUNTERS_RESET(Obj self)
{
  TLS(LocksAcquired) = TLS(LocksContended) = 0;

  return (Obj) 0;
}

Obj FuncTHREAD_COUNTERS_GET(Obj self)
{
  Obj result;

  result = NEW_PLIST(T_PLIST, 2);
  SET_LEN_PLIST(result, 2);
  SET_ELM_PLIST(result, 1, INTOBJ_INT(TLS(LocksAcquired)));
  SET_ELM_PLIST(result, 2, INTOBJ_INT(TLS(LocksContended)));

  return result;
}
