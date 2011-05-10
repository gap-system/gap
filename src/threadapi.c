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
#include	<pthread.h>
#include	<atomic_ops.h>

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

#include        "code.h"                /* coder                           */

#include        "vars.h"                /* variables                       */
#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */
#include        "funcs.h"               /* functions                       */

#include        "thread.h"
#include        "tls.h"
#include        "threadapi.h"


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
  int head, tail;
  int size, capacity;
  int dynamic;
} Channel;

typedef struct Barrier
{
  Obj monitor;
  int count;
  unsigned phase;
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
  pthread_cond_wait(TLS->threadSignal, TLS->threadLock);
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
  node.thread = TLS;
  AddWaitList(monitor, &node);
  UnlockMonitor(monitor);
  LockThread(TLS);
  while (!TLS->acquiredMonitor)
    WaitThreadSignal();
  if (!TryLockMonitor(monitor))
  {
    UnlockThread(TLS);
    LockMonitor(monitor);
    LockThread(TLS);
  }
  TLS->acquiredMonitor = NULL;
  RemoveWaitList(monitor, &node);
  UnlockThread(TLS);
}

static int MonitorOrder(const void *r1, const void *r2)
{
  const char *p1 = *(const char **)r1;
  const char *p2 = *(const char **)r2;
  return p1 < p2;
}

void SortMonitors(unsigned count, Monitor **monitors)
{
  MergeSort(monitors, count, sizeof(Monitor *), MonitorOrder);
}

static int ChannelOrder(const void *c1, const void *c2)
{
  const char *p1 = (const char *)ObjPtr((*(Channel **) c1)->monitor);
  const char *p2 = (const char *)ObjPtr((*(Channel **) c2)->monitor);
  return p1 < p2;
}

static void SortChannels(unsigned count, Channel **channels)
{
  MergeSort(channels, count, sizeof(Channel *), ChannelOrder);
}

static int MonitorsAreSorted(unsigned count, Monitor **monitors)
{
  unsigned i;
  for (i=1; i<count; i++)
    if ((char *)(monitors[i-1]) > (char *)(monitors[i]))
      return 0;
  return 1;
}

void LockMonitors(unsigned count, Monitor **monitors)
{
  unsigned i;
  assert(MonitorsAreSorted(count, monitors));
  for (i=0; i<count; i++)
    LockMonitor(monitors[i]);
}

void UnlockMonitors(unsigned count, Monitor **monitors)
{
  unsigned i;
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

int WaitForAnyMonitor(unsigned count, Monitor **monitors)
{
  struct WaitList *nodes;
  Monitor *monitor;
  unsigned i;
  int result;
  assert(MonitorsAreSorted(count, monitors));
  nodes = alloca(sizeof(struct WaitList) * count);
  for (i=0; i<count; i++)
    nodes[i].thread = TLS;
  for (i=0; i<count; i++)
    AddWaitList(monitors[i], &nodes[i]);
  for (i=0; i<count; i++)
    UnlockMonitor(monitors[i]);
  LockThread(TLS);
  while (!TLS->acquiredMonitor)
    WaitThreadSignal();
  monitor = TLS->acquiredMonitor;
  UnlockThread(TLS);
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
  LockThread(TLS);
  TLS->acquiredMonitor = NULL;
  UnlockThread(TLS);
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

void ArgumentError(char *message)
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
  Int id, i, n;
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
  DS_BAG(templist) = NULL; /* make it public */
  for (i=1; i<=n; i++)
    SET_ELM_PLIST(templist, i, ELM_PLIST(funcargs, i));
  id = RunThread(ThreadedInterpreter, KeepAlive(templist));
  return INTOBJ_INT(id);
}

/****************************************************************************
**
*F FuncWaitThread  ... wait for a created thread to finish.
**
** The function waits for an existing thread to finish.
*/

Obj FuncWaitThread(Obj self, Obj id) {
  int thread_num;
  if (!IS_INTOBJ(id))
    ArgumentError("WaitThread: Argument must be a thread id");
  thread_num = INT_INTOBJ(id);
  if (!JoinThread(thread_num))
    ErrorQuit("WaitThread: Invalid thread id", 0L, 0L);
  return (Obj) 0;
}

/****************************************************************************
**
*F FuncCurrentThread ... return id of current thread.
**
*/

Obj FuncCurrentThread(Obj self) {
  return INTOBJ_INT(TLS->threadID);
}

/****************************************************************************
**
*F FuncDataSpace ... return data space of an object
**
*/


Obj FuncDataSpace(Obj self, Obj obj) {
  DataSpace *ds = GetDataSpaceOf(obj);
  return ds == NULL ? PublicDataSpace : ds->obj;
}

/****************************************************************************
**
*F FuncIsShared ... return whether a dataspace is shared
**
*/

Obj FuncIsShared(Obj self, Obj obj) {
  DataSpace *ds = GetDataSpaceOf(obj);
  return (ds && !ds->fixed_owner) ? True : False;
}

/****************************************************************************
**
*F FuncIsPublic ... return whether a dataspace is public
**
*/

Obj FuncIsPublic(Obj self, Obj obj) {
  DataSpace *ds = GetDataSpaceOf(obj);
  return ds == NULL ? True : False;
}

/****************************************************************************
**
*F FuncIsThreadLocal ... return whether a dataspace is thread-local
**
*/

Obj FuncIsThreadLocal(Obj self, Obj obj) {
  DataSpace *ds = GetDataSpaceOf(obj);
  return (ds && ds->fixed_owner && ds->owner == TLS) ? True : False;
}

/****************************************************************************
**
*F FuncHaveWriteAccess ... return if we have a write lock on the data space
**
*/

Obj FuncHaveWriteAccess(Obj self, Obj obj)
{
  DataSpace* ds = GetDataSpaceOf(obj);
  if (ds != NULL && ds->owner == TLS)
    return True;
  else
    return False;
}

/****************************************************************************
**
*F FuncHaveReadAccess ... return if we have a read lock on the data space
**
*/

Obj FuncHaveReadAccess(Obj self, Obj obj)
{
  DataSpace* ds = GetDataSpaceOf(obj);
  if (ds != NULL && (ds->owner == TLS || ds->readers[TLS->threadID+1]))
    return True;
  else
    return False;
}


/****************************************************************************
**
*F FuncLock ........... acquire write lock on an object.
*F FuncUnlock ......... release write lock on an object.
*F FuncLockShared ..... acquire read lock on an object.
*F FuncUnlockShared ... release read lock on an object.
**
*/


Obj FuncLock(Obj self, Obj target) {
  Lock(target);
  return (Obj) 0;
}

Obj FuncUnlock(Obj self, Obj target) {
  Unlock(target);
  return (Obj) 0;
}

Obj FuncLockShared(Obj self, Obj target) {
  LockShared(target);
  return (Obj) 0;
} 
Obj FuncUnlockShared(Obj self, Obj target) {
  UnlockShared(target);
  return (Obj) 0;
}

/****************************************************************************
**
*F FuncSynchronized ......... execute a function while holding a write lock.
*F FuncSynchronizedShared ... execute a function while holding a read lock.
**
*/

Obj FuncSynchronized(Obj self, Obj target, Obj function) {
  volatile int locked = 0;
  jmp_buf readJmpError;
  memcpy( readJmpError, TLS->readJmpError, sizeof(jmp_buf) );
  if (!READ_ERROR()) {
    Lock(target);
    locked = 1;
    CALL_0ARGS(function);
    locked = 0;
    Unlock(target);
  }
  if (locked)
    Unlock(target);
  memcpy( TLS->readJmpError, readJmpError, sizeof(jmp_buf) );
  return (Obj) 0;
}

Obj FuncSynchronizedShared(Obj self, Obj target, Obj function) {
  volatile int locked = 0;
  jmp_buf readJmpError;
  memcpy( readJmpError, TLS->readJmpError, sizeof(jmp_buf) );
  if (!READ_ERROR()) {
    LockShared(target);
    locked = 1;
    CALL_0ARGS(function);
    locked = 0;
    UnlockShared(target);
  }
  if (locked)
    UnlockShared(target);
  memcpy( TLS->readJmpError, readJmpError, sizeof(jmp_buf) );
  return (Obj) 0;
}

Obj FuncCreateChannel(Obj self, Obj args);
Obj FuncDestroyChannel(Obj self, Obj channel);
Obj FuncSendChannel(Obj self, Obj channel, Obj obj);
Obj FuncTransmitChannel(Obj self, Obj channel, Obj obj);
Obj FuncReceiveChannel(Obj self, Obj channel);
Obj FuncReceiveAnyChannel(Obj self, Obj args);
Obj FuncMultiReceiveChannel(Obj self, Obj channel, Obj count);
Obj FuncInspectChannel(Obj self, Obj channel);
Obj FuncMultiSendChannel(Obj self, Obj channel, Obj list);
Obj FuncTryMultiSendChannel(Obj self, Obj channel, Obj list);
Obj FuncTrySendChannel(Obj self, Obj channel, Obj obj);
Obj FuncMultiTransmitChannel(Obj self, Obj channel, Obj list);
Obj FuncTryMultiTransmitChannel(Obj self, Obj channel, Obj list);
Obj FuncTryTransmitChannel(Obj self, Obj channel, Obj obj);
Obj FuncTryReceiveChannel(Obj self, Obj channel, Obj defaultobj);
Obj FuncCreateThread(Obj self, Obj funcargs);
Obj FuncCurrentThread(Obj self);
Obj FuncWaitThread(Obj self, Obj id);
Obj FuncCreateBarrier(Obj self);
Obj FuncStartBarrier(Obj self, Obj barrier, Obj count);
Obj FuncWaitBarrier(Obj self, Obj barrier);
Obj FuncCreateSyncVar(Obj self);
Obj FuncWriteSyncVar(Obj self, Obj var, Obj value);
Obj FuncReadSyncVar(Obj self, Obj var);
Obj FuncIS_LOCKED(Obj self, Obj obj);
Obj FuncLOCK(Obj self, Obj args);
Obj FuncUNLOCK(Obj self, Obj args);
Obj FuncCURRENT_LOCKS(Obj self);
Obj FuncSHARE_NORECURSE(Obj self, Obj obj);
Obj FuncMAKE_PUBLIC_NORECURSE(Obj self, Obj obj);
Obj FuncADOPT_NORECURSE(Obj self, Obj obj);
Obj FuncMIGRATE_NORECURSE(Obj self, Obj obj, Obj target);
Obj FuncSHARE(Obj self, Obj obj);
Obj FuncMAKE_PUBLIC(Obj self, Obj obj);
Obj FuncADOPT(Obj self, Obj obj);
Obj FuncMIGRATE(Obj self, Obj obj, Obj target);
Obj FuncREACHABLE(Obj self, Obj obj);
Obj FuncCLONE_REACHABLE(Obj self, Obj obj);
Obj FuncCLONE_DELIMITED(Obj self, Obj obj);
Obj FuncMakeReadOnly(Obj self, Obj obj);
Obj FuncMakeReadOnlyObj(Obj self, Obj obj);
Obj FuncMakeProtected(Obj self, Obj obj);
Obj FuncMakeProtectedObj(Obj self, Obj obj);
Obj FuncIsReadOnly(Obj self, Obj obj);
Obj FuncIsProtected(Obj self, Obj obj);
Obj FuncBEGIN_SINGLE_THREADED(Obj self);
Obj FuncEND_SINGLE_THREADED(Obj self);
Obj FuncORDERED_WRITE(Obj self, Obj obj);
Obj FuncORDERED_READ(Obj self, Obj obj);

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "CreateThread", -1, "function",
      FuncCreateThread, "src/threadapi.c:CreateThread" },

    { "CurrentThread", 0, "",
      FuncCurrentThread, "src/threadapi.c:CurrentThread" },

    { "WaitThread", 1, "threadID",
      FuncWaitThread, "src/threadapi.c:WaitThread" },

    { "Lock", 1, "object",
      FuncLock, "src/threadapi.c:Lock" },
    
    { "LockShared", 1, "object",
      FuncLockShared, "src/threadapi.c:LockShared" },
    
    { "Unlock", 1, "object",
      FuncUnlock, "src/threadapi.c:Unlock" },
    
    { "UnlockShared", 1, "object",
      FuncUnlockShared, "src/threadapi.c:UnlockShared" },

    { "Synchronized", 2, "object, function",
      FuncSynchronized, "src/threadapi.c:Synchronized" },

    { "SynchronizedShared", 2, "object, function",
      FuncSynchronizedShared, "src/threadapi.c:SynchronizedShared" },

    { "DataSpace", 1, "object",
      FuncDataSpace, "src/threadapi.c:DataSpace" },

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

    { "CreateChannel", -1, "[size]",
      FuncCreateChannel, "src/threadapi.c:CreateChannel" },

    { "DestroyChannel", 1, "channel",
      FuncDestroyChannel, "src/threadapi.c:DestroyChannel" },

    { "SendChannel", 2, "channel, obj",
      FuncSendChannel, "src/threadapi.c:SendChannel" },

    { "TransmitChannel", 2, "channel, obj",
      FuncTransmitChannel, "src/threadapi.c:TransmitChannel" },

    { "ReceiveChannel", 1, "channel",
      FuncReceiveChannel, "src/threadapi:ReceiveChannel" },

    { "ReceiveAnyChannel", -1, "channel list",
      FuncReceiveAnyChannel, "src/threadapi:ReceiveAnyChannel" },

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

    { "WriteSyncVar", 2, "syncvar, obj",
      FuncWriteSyncVar, "src/threadapi.c:WriteSyncVar" },

    { "ReadSyncVar", 1, "syncvar",
      FuncReadSyncVar, "src/threadapi.c:ReadSyncVar" },

    { "IS_LOCKED", 1, "obj",
      FuncIS_LOCKED, "src/threadapi.c:IS_LOCKED" },

    { "LOCK", -1, "obj, ...",
      FuncLOCK, "src/threadapi.c:LOCK" },

    { "UNLOCK", 1, "obj, newsp",
      FuncUNLOCK, "src/threadapi.c:LOCK" },

    { "CURRENT_LOCKS", 0, "",
      FuncCURRENT_LOCKS, "src/threadapi.c:FuncCURRENT_LOCKS" },

    { "SHARE_NORECURSE", 1, "obj",
      FuncSHARE_NORECURSE, "src/threadapi.c:SHARE_NORECURSE" },

    { "ADOPT_NORECURSE", 1, "obj",
      FuncADOPT_NORECURSE, "src/threadapi.c:ADOPT_NORECURSE" },

    { "MIGRATE_NORECURSE", 2, "obj, target",
      FuncMIGRATE_NORECURSE, "src/threadapi.c:MIGRATE_NORECURSE" },

    { "SHARE", 1, "obj",
      FuncSHARE, "src/threadapi.c:SHARE" },

    { "ADOPT", 1, "obj",
      FuncADOPT, "src/threadapi.c:ADOPT" },

    { "MIGRATE", 2, "obj, target",
      FuncMIGRATE, "src/threadapi.c:MIGRATE" },

    { "MAKE_PUBLIC_NORECURSE", 1, "obj",
      FuncMAKE_PUBLIC_NORECURSE, "src/threadapi.c:MAKE_PUBLIC_NORECURSE" },
    { "MAKE_PUBLIC", 1, "obj",
      FuncMAKE_PUBLIC, "src/threadapi.c:MAKE_PUBLIC" },

    { "REACHABLE", 1, "obj",
      FuncREACHABLE, "src/threadapi.c:REACHABLE" },

    { "CLONE_REACHABLE", 1, "obj",
      FuncCLONE_REACHABLE, "src/threadapi.c:CLONE_REACHABLE" },

    { "CLONE_DELIMITED", 1, "obj",
      FuncCLONE_DELIMITED, "src/threadapi.c:CLONE_DELIMITED" },

    { "MakeReadOnly", 1, "obj",
      FuncMakeReadOnly, "src/threadapi.c:MakeReadOnly" },

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

    { "BEGIN_SINGLE_THREADED", 0, "",
      FuncBEGIN_SINGLE_THREADED, "src/threadapi.c:BEGIN_SINGLE_THREADED" },

    { "END_SINGLE_THREADED", 0, "",
      FuncEND_SINGLE_THREADED, "src/threadapi.c:END_SINGLE_THREADED" },

    { "ORDERED_READ", 1, "obj",
      FuncORDERED_READ, "src/threadapi.c:ORDERED_READ" },

    { "ORDERED_WRITE", 1, "obj",
      FuncORDERED_WRITE, "src/threadapi.c:ORDERED_WRITE" },

    { 0 }

};

Obj TYPE_CHANNEL;
Obj TYPE_BARRIER;
Obj TYPE_SYNCVAR;
Obj TYPE_DATASPACE;

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

Obj TypeDataSpace(Obj obj)
{
  return TYPE_DATASPACE;
}

static Int AlwaysMutable( Obj obj)
{
  return 1;
}

static void MarkChannelBag(Bag);
static void MarkBarrierBag(Bag);
static void MarkSyncVarBag(Bag);
static void FinalizeMonitor(Bag);
static void PrintChannel(Obj);
static void PrintBarrier(Obj);
static void PrintSyncVar(Obj);
static void PrintDataSpace(Obj);

/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  /* install info string */
  InfoBags[T_CHANNEL].name = "channel";
  InfoBags[T_BARRIER].name = "barrier";
  InfoBags[T_SYNCVAR].name = "syncvar";
  InfoBags[T_DATASPACE].name = "dataspace";
  
    /* install the kind methods */
    TypeObjFuncs[ T_CHANNEL ] = TypeChannel;
    TypeObjFuncs[ T_BARRIER ] = TypeBarrier;
    TypeObjFuncs[ T_SYNCVAR ] = TypeSyncVar;
    TypeObjFuncs[ T_DATASPACE ] = TypeDataSpace;
    /* install global variables */
    InitCopyGVar("TYPE_CHANNEL", &TYPE_CHANNEL);
    InitCopyGVar("TYPE_BARRIER", &TYPE_BARRIER);
    InitCopyGVar("TYPE_SYNCVAR", &TYPE_SYNCVAR);
    InitCopyGVar("TYPE_DATASPACE", &TYPE_DATASPACE);
    /* install mark functions */
    InitMarkFuncBags(T_CHANNEL, MarkChannelBag);
    InitMarkFuncBags(T_BARRIER, MarkBarrierBag);
    InitMarkFuncBags(T_SYNCVAR, MarkSyncVarBag);
    InitMarkFuncBags(T_MONITOR, MarkNoSubBags);
    InitMarkFuncBags(T_DATASPACE, MarkNoSubBags);
    InitFinalizerFuncBags(T_MONITOR, FinalizeMonitor);
    /* install print functions */
    PrintObjFuncs[ T_CHANNEL ] = PrintChannel;
    PrintObjFuncs[ T_BARRIER ] = PrintBarrier;
    PrintObjFuncs[ T_SYNCVAR ] = PrintSyncVar;
    PrintObjFuncs[ T_DATASPACE ] = PrintDataSpace;
    /* install mutability functions */
    IsMutableObjFuncs [ T_CHANNEL ] = AlwaysMutable;
    IsMutableObjFuncs [ T_BARRIER ] = AlwaysMutable;
    IsMutableObjFuncs [ T_SYNCVAR ] = AlwaysMutable;
    IsMutableObjFuncs [ T_DATASPACE ] = AlwaysMutable;
    MakeBagTypePublic(T_CHANNEL);
    MakeBagTypePublic(T_DATASPACE);
    MakeBagTypePublic(T_SYNCVAR);
    MakeBagTypePublic(T_BARRIER);
    PublicDataSpace = NewBag(T_DATASPACE, sizeof(DataSpace *));
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
    /* TODO: Insert proper revision numbers. */
    module.revision_c = "@(#)$Id: threadapi.c,v 1.0 ";
    module.revision_h = "@(#)$Id: threadapi.h,v 1.0 ";
    FillInVersion( &module );
    return &module;
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
  unsigned oldCapacity = channel->capacity;
  unsigned newCapacity = ((oldCapacity * 25 / 16) | 1) + 1;
  unsigned i, tail;
  Obj newqueue;
  if (newCapacity == oldCapacity)
    newCapacity+=2;
  newqueue = NEW_PLIST(T_PLIST, newCapacity);
  SET_LEN_PLIST(newqueue, newCapacity);
  DS_BAG(newqueue) = DS_BAG(channel->queue);
  channel->capacity = newCapacity;
  /* assert(channel->head == channel->tail); */
  for (i = channel->head; i < oldCapacity; i++)
    ADDR_OBJ(newqueue)[i+1] = ADDR_OBJ(channel->queue)[i+1];
  for (i = 0; i < channel->tail; i++)
  {
    unsigned d = oldCapacity+i;
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
  DataSpace *ds = DS_BAG(channel->queue);
  UInt i, len;
  if (migrate && IS_BAG_REF(obj) && DS_BAG(obj) && DS_BAG(obj)->owner == TLS) {
    children = ReachableObjectsFrom(obj);
    len = children ? LEN_PLIST(children) : 0;
  } else {
    children = 0;
    len = 0;
  }
  for (i=1; i<= len; i++) {
    Obj item = ELM_PLIST(children, i);
    DS_BAG(item) = ds;
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
  DataSpace *ds = TLS->currentDataSpace;
  UInt i, len = children ? LEN_PLIST(children) : 0;
  ADDR_OBJ(channel->queue)[channel->head-2] = 0;
  ADDR_OBJ(channel->queue)[channel->head-1] = 0;
  if (channel->head == channel->capacity)
    channel->head = 0;
  for (i=1; i<= len; i++) {
    Obj item = ELM_PLIST(children, i);
    DS_BAG(item) = ds;
  }
  channel->size -= 2;
  return obj;
}
#endif

static void ContractChannel(Channel *channel)
{
  /* Not yet implemented */
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

static Obj ReceiveAnyChannel(Obj channelList)
{
  unsigned count = LEN_PLIST(channelList);
  unsigned i, p;
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
  p = TLS->multiplexRandomSeed;
  p = (p * 5 + 1);
  TLS->multiplexRandomSeed = p;
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
  return result;
}

static Obj MultiReceiveChannel(Channel *channel, unsigned max)
{
  Obj result;
  unsigned count;
  unsigned i;
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
  for (i = 0, p = channel->head; i < channel->size; i+=2) {
    SET_ELM_PLIST(result, i+1, ELM_PLIST(channel->queue, p+1));
    p++;
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
  DS_BAG(channel->queue) = LimboDataSpace;
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

Obj FuncSendChannel(Obj self, Obj channel, Obj obj)
{
  if (!IsChannel(channel))
    ArgumentError("SendChannel: Channel identifier must be a number");
  SendChannel(ObjPtr(channel), obj);
  return (Obj) 0;
}

Obj FuncTransmitChannel(Obj self, Obj channel, Obj obj)
{
  if (!IsChannel(channel))
    ArgumentError("TransmitChannel: Channel identifier must be a number");
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
    return ReceiveAnyChannel(args);
  else
  {
    if (LEN_PLIST(args) == 1 && IS_PLIST(ELM_PLIST(args, 1))
        && IsChannelList(ELM_PLIST(args, 1)))
      return ReceiveAnyChannel(ELM_PLIST(args, 1));
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
    ArgumentError("MultiReceiveChannel: Channel identifier must be a number");
  count = INT_INTOBJ(countobj);
  if (count < 0)
    ArgumentError("MultiReceiveChannel: Channel size must be non-negative");
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

void StartBarrier(Barrier *barrier, unsigned count)
{
  LockBarrier(barrier);
  barrier->count = count;
  barrier->phase++;
  UnlockBarrier(barrier);
}

void WaitBarrier(Barrier *barrier)
{
  unsigned phaseDelta;
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

void WriteSyncVar(SyncVar *var, Obj value)
{
  Monitor *monitor = ObjPtr(var->monitor);
  LockMonitor(monitor);
  if (var->written)
  {
    UnlockMonitor(monitor);
    ArgumentError("WriteSyncVar: Variable already has a value");
    return;
  }
  var->written = 1;
  var->value = value;
  SignalMonitor(monitor);
  UnlockMonitor(monitor);
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


Obj ReadSyncVar(SyncVar *var)
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

int IsSyncVar(Obj var)
{
  return var && TNUM_OBJ(var) == T_SYNCVAR;
}

Obj FuncCreateSyncVar(Obj self)
{
  return CreateSyncVar();
}

Obj FuncWriteSyncVar(Obj self, Obj var, Obj value)
{
  if (!IsSyncVar(var))
    ArgumentError("WriteSyncVar: First argument must be a synchronization variable");
  WriteSyncVar(ObjPtr(var), value);
  return (Obj) 0;
}

Obj FuncReadSyncVar(Obj self, Obj var)
{
  if (!IsSyncVar(var))
    ArgumentError("ReadSyncVar: Argument must be a synchronization variable");
  return ReadSyncVar(ObjPtr(var));
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

static void PrintDataSpace(Obj obj)
{
  char buffer[32];
  DataSpace *ds = GetDataSpaceOf(obj);
  if (ds) {
    if (ds == LimboDataSpace) {
      Pr("<limbo data space>", 0L, 0L);
      return;
    } else if (ds == ReadOnlyDataSpace) {
      Pr("<read-only data space>", 0L, 0L);
      return;
    } else if (ds == ProtectedDataSpace) {
      Pr("<protected data space>", 0L, 0L);
      return;
    }
    sprintf(buffer, "<data space %p>", GetDataSpaceOf(obj));
    Pr(buffer, 0L, 0L);
  } else
    Pr("<public data space>", 0L, 0L);
}

Obj FuncIS_LOCKED(Obj self, Obj obj)
{
  DataSpace *ds = IS_BAG_REF(obj) ? DS_BAG(obj) : NULL;
  if (!ds)
    return INTOBJ_INT(0);
  return INTOBJ_INT(IsLocked(ds));
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

Obj FuncUNLOCK(Obj self, Obj sp)
{
  if (!IS_INTOBJ(sp) || INT_INTOBJ(sp) < 0)
    ArgumentError("UNLOCK: argument must be a non-negative integer");
  PopDataSpaceLocks(INT_INTOBJ(sp));
  return (Obj) 0;
}

Obj FuncCURRENT_LOCKS(Obj self)
{
  UInt i, len = TLS->lockStackPointer;
  Obj result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=1; i<=len; i++)
    SET_ELM_PLIST(result, i, ELM_PLIST(TLS->lockStack, i));
  return result;
}

static int MigrateObjects(int count, Obj *objects, DataSpace *target)
{
  int i;
  for (i=0; i<count; i++) {
    DataSpace *ds;
    if (IS_BAG_REF(objects[i])) {
      ds = (DataSpace *)(DS_BAG(objects[i]));
      if (!ds || ds->owner != TLS || ds == ProtectedDataSpace)
        return 0;
    }
  }
  for (i=0; i<count; i++)
    DS_BAG(objects[i]) = target;
  return 1;
}

Obj FuncMAKE_PUBLIC_NORECURSE(Obj self, Obj obj)
{
  if (!MigrateObjects(1, &obj, NULL))
    ArgumentError("MAKE_PUBLIC_NORECURSE: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncSHARE_NORECURSE(Obj self, Obj obj)
{
  if (!MigrateObjects(1, &obj, NewDataSpace()))
    ArgumentError("SHARE_NORECURSE: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMIGRATE_NORECURSE(Obj self, Obj obj, Obj target)
{
  DataSpace *targetDS = GetDataSpaceOf(target);
  if (!targetDS || IsLocked(targetDS) != 1)
    ArgumentError("MIGRATE_NORECURSE: Thread does not have exclusive access to target data space");
  if (!MigrateObjects(1, &obj, targetDS))
    ArgumentError("MIGRATE_NORECURSE: Thread does not have exclusive access to object");
  return obj;
}

Obj FuncADOPT_NORECURSE(Obj self, Obj obj)
{
  if (!MigrateObjects(1, &obj, TLS->currentDataSpace))
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
  return CopyReachableObjectsFrom(obj, 0, 0);
}

Obj FuncCLONE_DELIMITED(Obj self, Obj obj)
{
  return CopyReachableObjectsFrom(obj, 1, 0);
}


Obj FuncSHARE(Obj self, Obj obj)
{
  Obj reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, NewDataSpace()))
    ArgumentError("SHARE: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncADOPT(Obj self, Obj obj)
{
  Obj reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, TLS->currentDataSpace))
    ArgumentError("ADOPT: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMAKE_PUBLIC(Obj self, Obj obj)
{
  Obj reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, 0))
    ArgumentError("MAKE_PUBLIC: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMIGRATE(Obj self, Obj obj, Obj target)
{
  DataSpace *targetDS = GetDataSpaceOf(target);
  Obj reachable;
  if (!targetDS || IsLocked(targetDS) != 1)
    ArgumentError("MIGRATE: Thread does not have exclusive access to target data space");
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, targetDS))
    ArgumentError("MIGRATE: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMakeReadOnly(Obj self, Obj obj)
{
  DataSpace *ds = GetDataSpaceOf(obj);
  Obj reachable;
  if (!ds || ds == ReadOnlyDataSpace)
    return obj;
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, ReadOnlyDataSpace))
    ArgumentError("MakeReadOnly: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMakeReadOnlyObj(Obj self, Obj obj)
{
  DataSpace *ds = GetDataSpaceOf(obj);
  Obj reachable;
  if (!ds || ds == ReadOnlyDataSpace)
    return obj;
  if (!MigrateObjects(1, &obj, ReadOnlyDataSpace))
    ArgumentError("MakeReadOnlyObj: Thread does not have exclusive access to object");
  return obj;
}

Obj FuncMakeProtected(Obj self, Obj obj)
{
  DataSpace *ds = GetDataSpaceOf(obj);
  Obj reachable;
  if (ds == ProtectedDataSpace)
    return obj;
  reachable = ReachableObjectsFrom(obj);
  if (!MigrateObjects(LEN_PLIST(reachable),
       ADDR_OBJ(reachable)+1, ProtectedDataSpace))
    ArgumentError("MakeProtected: Thread does not have exclusive access to objects");
  return obj;
}

Obj FuncMakeProtectedObj(Obj self, Obj obj)
{
  DataSpace *ds = GetDataSpaceOf(obj);
  if (ds == ProtectedDataSpace)
    return obj;
  if (!MigrateObjects(1, &obj, ProtectedDataSpace))
    ArgumentError("MakeProtectedObj: Thread does not have exclusive access to object");
  return obj;
}

Obj FuncIsReadOnly(Obj self, Obj obj)
{
  DataSpace *ds = GetDataSpaceOf(obj);
  return (ds == ReadOnlyDataSpace) ? True : False;
}

Obj FuncIsProtected(Obj self, Obj obj)
{
  DataSpace *ds = GetDataSpaceOf(obj);
  return (ds == ProtectedDataSpace) ? True : False;
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
  AO_nop_read();
  return obj;
}

Obj FuncORDERED_WRITE(Obj self, Obj obj)
{
  AO_nop_write();
  return obj;
}
