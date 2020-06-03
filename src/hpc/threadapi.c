/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the GAP interface for thread primitives.
*/

#include "hpc/threadapi.h"

#include "bool.h"
#include "calls.h"
#include "code.h"
#include "error.h"
#include "funcs.h"
#include "gvars.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "objects.h"
#include "plist.h"
#include "precord.h"
#include "read.h"
#include "records.h"
#include "set.h"
#include "stats.h"
#include "stringobj.h"
#include "trycatch.h"
#include "vars.h"

#include "hpc/guards.h"
#include "hpc/misc.h"
#include "hpc/region.h"
#include "hpc/thread.h"
#include "hpc/tls.h"
#include "hpc/traverse.h"

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include <pthread.h>


#define RequireThread(funcname, op, argname)                                 \
    RequireArgumentConditionEx(funcname, op, "<" argname ">",                \
                               TNUM_OBJ(op) == T_THREAD,                     \
                               "must be a thread object")

#define RequireChannel(funcname, op)                                         \
    RequireArgumentCondition(funcname, op, IsChannel(op), "must be a channel")

#define RequireSemaphore(funcname, op)                                       \
    RequireArgumentCondition(funcname, op, TNUM_OBJ(op) == T_SEMAPHORE,      \
                             "must be a semaphore")

#define RequireBarrier(funcname, op)                                         \
    RequireArgumentCondition(funcname, op, IsBarrier(op), "must be a barrier")

#define RequireSyncVar(funcname, op)                                         \
    RequireArgumentCondition(funcname, op, IsSyncVar(op),                    \
                             "must be a synchronization variable")


struct WaitList {
    struct WaitList *    prev;
    struct WaitList *    next;
    ThreadLocalStorage * thread;
};

typedef struct {
  pthread_mutex_t lock;
  struct WaitList *head, *tail;
} Monitor;

typedef struct Channel {
    Obj  monitor;
    Obj  queue;
    int  waiting;
    int  dynamic;
    UInt head, tail;
    UInt size, capacity;
} Channel;

typedef struct Semaphore {
    Obj  monitor;
    UInt count;
    int  waiting;
} Semaphore;

typedef struct Barrier {
    Obj  monitor;
    UInt count;
    UInt phase;
    int  waiting;
} Barrier;

typedef struct SyncVar {
    Obj monitor;
    Obj value;
    int written;
} SyncVar;


static void AddWaitList(Monitor * monitor, struct WaitList * node)
{
    if (monitor->tail) {
        monitor->tail->next = node;
        node->prev = monitor->tail;
        node->next = NULL;
        monitor->tail = node;
    }
    else {
        monitor->head = monitor->tail = node;
        node->next = node->prev = NULL;
    }
}

static void RemoveWaitList(Monitor * monitor, struct WaitList * node)
{
    if (monitor->head) {
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

#ifndef WARD_ENABLED
static inline void * ObjPtr(Obj obj)
{
    return PTR_BAG(obj);
}
#endif

Obj NewThreadObject(UInt id)
{
    Obj result = NewBag(T_THREAD, sizeof(ThreadObject));
    ThreadObject *thread = (ThreadObject *)ADDR_OBJ(result);
    thread->id = id;
    return result;
}

static inline Int ThreadID(Obj obj)
{
    GAP_ASSERT(TNUM_OBJ(obj) == T_THREAD);
    const ThreadObject *thread = (const ThreadObject *)CONST_ADDR_OBJ(obj);
    return thread->id;
}

Obj NewMonitor(void)
{
    Bag       monitorBag;
    Monitor * monitor;
    monitorBag = NewBag(T_MONITOR, sizeof(Monitor));
    monitor = ObjPtr(monitorBag);
    pthread_mutex_init(&monitor->lock, 0);
    monitor->head = monitor->tail = NULL;
    return monitorBag;
}

static void LockThread(ThreadLocalStorage * thread)
{
    pthread_mutex_lock(thread->threadLock);
}

static void UnlockThread(ThreadLocalStorage * thread)
{
    pthread_mutex_unlock(thread->threadLock);
}

static void SignalThread(ThreadLocalStorage * thread)
{
    pthread_cond_signal(thread->threadSignal);
}

static void WaitThreadSignal(void)
{
    int id = TLS(threadID);
    if (!UpdateThreadState(id, TSTATE_RUNNING, TSTATE_BLOCKED))
        HandleInterrupts(1, 0);
    pthread_cond_wait(TLS(threadSignal), TLS(threadLock));
    if (!UpdateThreadState(id, TSTATE_BLOCKED, TSTATE_RUNNING) &&
        GetThreadState(id) != TSTATE_RUNNING)
        HandleInterrupts(1, 0);
}

void LockMonitor(Monitor * monitor)
{
    pthread_mutex_lock(&monitor->lock);
}

int TryLockMonitor(Monitor * monitor)
{
    return !pthread_mutex_trylock(&monitor->lock);
}

static void UnlockMonitor(Monitor * monitor)
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

static void WaitForMonitor(Monitor * monitor)
{
    struct WaitList node;
    node.thread = GetTLS();
    AddWaitList(monitor, &node);
    UnlockMonitor(monitor);
    LockThread(GetTLS());
    while (!TLS(acquiredMonitor))
        WaitThreadSignal();
    if (!TryLockMonitor(monitor)) {
        UnlockThread(GetTLS());
        LockMonitor(monitor);
        LockThread(GetTLS());
    }
    TLS(acquiredMonitor) = NULL;
    RemoveWaitList(monitor, &node);
    UnlockThread(GetTLS());
}

static int ChannelOrder(const void * c1, const void * c2)
{
    const char * p1 = (const char *)ObjPtr((*(Channel **)c1)->monitor);
    const char * p2 = (const char *)ObjPtr((*(Channel **)c2)->monitor);
    return p1 < p2;
}

static void SortChannels(UInt count, Channel ** channels)
{
    MergeSort(channels, count, sizeof(Channel *), ChannelOrder);
}

static int MonitorsAreSorted(UInt count, Monitor ** monitors)
{
    UInt i;
    for (i = 1; i < count; i++)
        if ((char *)(monitors[i - 1]) > (char *)(monitors[i]))
            return 0;
    return 1;
}

void LockMonitors(UInt count, Monitor ** monitors)
{
    UInt i;
    assert(MonitorsAreSorted(count, monitors));
    for (i = 0; i < count; i++)
        LockMonitor(monitors[i]);
}

void UnlockMonitors(UInt count, Monitor ** monitors)
{
    UInt i;
    for (i = 0; i < count; i++)
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

UInt WaitForAnyMonitor(UInt count, Monitor ** monitors)
{
    struct WaitList * nodes;
    Monitor *         monitor;
    UInt              i;
    Int               result;
    assert(MonitorsAreSorted(count, monitors));
    nodes = alloca(sizeof(struct WaitList) * count);
    for (i = 0; i < count; i++)
        nodes[i].thread = GetTLS();
    for (i = 0; i < count; i++)
        AddWaitList(monitors[i], &nodes[i]);
    for (i = 0; i < count; i++)
        UnlockMonitor(monitors[i]);
    LockThread(GetTLS());
    while (!TLS(acquiredMonitor))
        WaitThreadSignal();
    monitor = TLS(acquiredMonitor);
    UnlockThread(GetTLS());

    // The following loops will initialize <result>, but the compiler
    // cannot know this; to avoid warnings, we set result to an
    // initial nonsense value.
    result = -1;
    for (i = 0; i < count; i++) {
        LockMonitor(monitors[i]);
        if (monitors[i] == monitor) {
            RemoveWaitList(monitors[i], &nodes[i]);
            result = i;
            /* keep it locked for further processing by caller */
        }
        else {
            RemoveWaitList(monitors[i], &nodes[i]);
            UnlockMonitor(monitors[i]);
        }
    }
    LockThread(GetTLS());
    TLS(acquiredMonitor) = NULL;
    UnlockThread(GetTLS());
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

void SignalMonitor(Monitor * monitor)
{
    struct WaitList * queue = monitor->head;
    while (queue != NULL) {
        ThreadLocalStorage * thread = queue->thread;
        LockThread(thread);
        if (!thread->acquiredMonitor) {
            thread->acquiredMonitor = monitor;
            SignalThread(thread);
            UnlockThread(thread);
            break;
        }
        UnlockThread(thread);
        queue = queue->next;
    }
}

static Obj ArgumentError(const char * message)
{
    ErrorQuit(message, 0, 0);
    return 0;
}


static int GetThreadID(const char * funcname, Obj thread)
{
    if (IS_INTOBJ(thread)) {
        Int id = INT_INTOBJ(thread);
        if (0 <= id && id < MAX_THREADS)
            return id;
    }
    else if (TNUM_OBJ(thread) == T_THREAD) {
        return ThreadID(thread);
    }
    RequireArgumentEx(funcname, thread, NICE_ARGNAME(thread),
                      "must be a thread object or an integer between 0 and "
                      "MAX_THREADS - 1");
}



/* TODO: register globals */
static Obj             FirstKeepAlive;
static Obj             LastKeepAlive;
static pthread_mutex_t KeepAliveLock;

#define KEPTALIVE(obj) (ADDR_OBJ(obj)[1])
#define PREV_KEPT(obj) (ADDR_OBJ(obj)[2])
#define NEXT_KEPT(obj) (ADDR_OBJ(obj)[3])

Obj KeepAlive(Obj obj)
{
    Obj newKeepAlive = NEW_PLIST(T_PLIST, 4);
    SET_REGION(newKeepAlive, NULL);    // public region
    pthread_mutex_lock(&KeepAliveLock);
    SET_LEN_PLIST(newKeepAlive, 3);
    KEPTALIVE(newKeepAlive) = obj;
    PREV_KEPT(newKeepAlive) = LastKeepAlive;
    NEXT_KEPT(newKeepAlive) = (Obj)0;
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

static GVarDescriptor GVarTHREAD_INIT;
static GVarDescriptor GVarTHREAD_EXIT;

static void ThreadedInterpreter(void * funcargs)
{
    Obj tmp, func;
    int i;

    // initialize everything and begin a fresh execution context
    tmp = KEPTALIVE(funcargs);
    StopKeepAlive(funcargs);
    func = ELM_PLIST(tmp, 1);
    for (i = 2; i <= LEN_PLIST(tmp); i++) {
        Obj item = ELM_PLIST(tmp, i);
        SET_ELM_PLIST(tmp, i - 1, item);
    }
    SET_LEN_PLIST(tmp, LEN_PLIST(tmp) - 1);

    GAP_TRY
    {
        Obj init, exit;
        if (setjmp(TLS(threadExit)))
            return;
        init = GVarOptFunction(&GVarTHREAD_INIT);
        if (init)
            CALL_0ARGS(init);
        CallFuncList(func, tmp);
        exit = GVarOptFunction(&GVarTHREAD_EXIT);
        if (exit)
            CALL_0ARGS(exit);
    }
    GAP_CATCH
    {
    }
}


/****************************************************************************
**
*F FuncCreateThread  ... create a new thread
**
** The function creates a new thread with a new interpreter and executes
** the function passed as an argument in it. It returns an integer that
** is a unique identifier for the thread.
*/

static Obj FuncCreateThread(Obj self, Obj funcargs)
{
    Int  i, n;
    Obj  thread;
    Obj  templist;
    n = LEN_PLIST(funcargs);
    if (n == 0 || !IS_FUNC(ELM_PLIST(funcargs, 1)))
        return ArgumentError(
            "CreateThread: Needs at least one function argument");
    Obj func = ELM_PLIST(funcargs, 1);
    if (NARG_FUNC(func) != n - 1)
        ErrorMayQuit("CreateThread: <func> expects %d arguments, but got %d", NARG_FUNC(func), n-1);
    templist = NEW_PLIST(T_PLIST, n);
    SET_LEN_PLIST(templist, n);
    SET_REGION(templist, NULL); /* make it public */
    for (i = 1; i <= n; i++)
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

static Obj FuncWaitThread(Obj self, Obj obj)
{
    const char * error = NULL;
    RequireThread(SELF_NAME, obj, "thread");
    LockThreadControl(1);
    ThreadObject *thread = (ThreadObject *)ADDR_OBJ(obj);
    if (thread->status & THREAD_JOINED)
        error = "ThreadObject is already being waited for";
    thread->status |= THREAD_JOINED;
    UnlockThreadControl();
    if (error)
        ErrorQuit("WaitThread: %s", (UInt)error, 0);
    if (!JoinThread(thread->id))
        ErrorQuit("WaitThread: Invalid thread id", 0, 0);
    return (Obj)0;
}

/****************************************************************************
**
*F FuncCurrentThread ... return thread object of current thread.
**
*/

static Obj FuncCurrentThread(Obj self)
{
    return TLS(threadObject);
}

/****************************************************************************
**
*F FuncThreadID ... return numerical thread id of thread.
**
*/

static Obj FuncThreadID(Obj self, Obj thread)
{
    RequireThread(SELF_NAME, thread, "thread");
    return INTOBJ_INT(ThreadID(thread));
}

/****************************************************************************
**
*F FuncKillThread ... kill a given thread
**
*/

static Obj FuncKillThread(Obj self, Obj thread)
{
    int id = GetThreadID("KillThread", thread);
    KillThread(id);
    return (Obj)0;
}


/****************************************************************************
**
*F FuncInterruptThread ... interrupt a given thread
**
*/

static Obj FuncInterruptThread(Obj self, Obj thread, Obj handler)
{
    int id = GetThreadID("InterruptThread", thread);
    RequireBoundedInt(SELF_NAME, handler, 0, MAX_INTERRUPT);
    InterruptThread(id, (int)(INT_INTOBJ(handler)));
    return (Obj)0;
}

/****************************************************************************
**
*F FuncSetInterruptHandler ... set interrupt handler for current thread
**
*/

static Obj FuncSetInterruptHandler(Obj self, Obj handler, Obj func)
{
    RequireBoundedInt(SELF_NAME, handler, 0, MAX_INTERRUPT);
    if (func == Fail) {
        SetInterruptHandler((int)(INT_INTOBJ(handler)), (Obj)0);
        return (Obj)0;
    }
    if (TNUM_OBJ(func) != T_FUNCTION || NARG_FUNC(func) != 0 ||
        !BODY_FUNC(func))
        RequireArgument(SELF_NAME, func,
                        "must be a parameterless function or 'fail'");
    SetInterruptHandler((int)(INT_INTOBJ(handler)), func);
    return (Obj)0;
}


/****************************************************************************
**
*F FuncPauseThread ... pause a given thread
**
*/


static Obj FuncPauseThread(Obj self, Obj thread)
{
    int id = GetThreadID("PauseThread", thread);
    PauseThread(id);
    return (Obj)0;
}


/****************************************************************************
**
*F FuncResumeThread ... resume a given thread
**
*/


static Obj FuncResumeThread(Obj self, Obj thread)
{
    int id = GetThreadID("ResumeThread", thread);
    ResumeThread(id);
    return (Obj)0;
}


/****************************************************************************
**
*F FuncRegionOf ... return region of an object
**
*/
static Obj PublicRegion;

static Obj FuncRegionOf(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    return region == NULL ? PublicRegion : region->obj;
}


/****************************************************************************
**
*F FuncSetRegionName ... set the name of an object's region
*F FuncClearRegionName ... clear the name of an object's region
*F FuncRegionName ... get the name of an object's region
**
*/


static Obj FuncSetRegionName(Obj self, Obj obj, Obj name)
{
    Region * region = GetRegionOf(obj);
    if (!region)
        ArgumentError(
            "SetRegionName: Cannot change name of the public region");
    RequireStringRep(SELF_NAME, name);
    SetRegionName(region, name);
    return (Obj)0;
}

static Obj FuncClearRegionName(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    if (!region)
        ArgumentError(
            "ClearRegionName: Cannot change name of the public region");
    SetRegionName(region, (Obj)0);
    return (Obj)0;
}

static Obj FuncRegionName(Obj self, Obj obj)
{
    Obj      result;
    Region * region = GetRegionOf(obj);
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

static Obj FuncIsShared(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    return (region && !region->fixed_owner) ? True : False;
}

/****************************************************************************
**
*F FuncIsPublic ... return whether a region is public
**
*/

static Obj FuncIsPublic(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    return region == NULL ? True : False;
}

/****************************************************************************
**
*F FuncIsThreadLocal ... return whether a region is thread-local
**
*/

static Obj FuncIsThreadLocal(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    return (region && region->fixed_owner && region->owner == GetTLS())
               ? True
               : False;
}

/****************************************************************************
**
*F FuncHaveWriteAccess ... return if we have a write lock on the region
**
*/

static Obj FuncHaveWriteAccess(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    if (region != NULL &&
        (region->owner == GetTLS() || region->alt_owner == GetTLS()))
        return True;
    else
        return False;
}

/****************************************************************************
**
*F FuncHaveReadAccess ... return if we have a read lock on the region
**
*/

static Obj FuncHaveReadAccess(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
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


static Obj FuncHASH_LOCK(Obj self, Obj target)
{
    HashLock(target);
    return (Obj)0;
}

static Obj FuncHASH_UNLOCK(Obj self, Obj target)
{
    HashUnlock(target);
    return (Obj)0;
}

static Obj FuncHASH_LOCK_SHARED(Obj self, Obj target)
{
    HashLockShared(target);
    return (Obj)0;
}
static Obj FuncHASH_UNLOCK_SHARED(Obj self, Obj target)
{
    HashUnlockShared(target);
    return (Obj)0;
}

/****************************************************************************
**
*F FuncHASH_SYNCHRONIZED ......... execute a function while holding a write
*lock.
*F FuncHASH_SYNCHRONIZED_SHARED ... execute a function while holding a read
*lock.
**
*/

static Obj FuncHASH_SYNCHRONIZED(Obj self, Obj target, Obj function)
{
    HashLock(target);
    Call0ArgsInNewReader(function);
    HashUnlock(target);
    return (Obj)0;
}

static Obj FuncHASH_SYNCHRONIZED_SHARED(Obj self, Obj target, Obj function)
{
    HashLockShared(target);
    Call0ArgsInNewReader(function);
    HashUnlockShared(target);
    return (Obj)0;
}

/****************************************************************************
**
*F FuncCREATOR_OF ... return function that created an object
**
*/

static Obj FuncCREATOR_OF(Obj self, Obj obj)
{
#ifdef TRACK_CREATOR
    Obj result = NEW_PLIST_IMM(T_PLIST, 2);
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

static Obj FuncDISABLE_GUARDS(Obj self, Obj flag)
{
    if (flag == False)
        TLS(DisableGuards) = 0;
    else if (flag == True)
        TLS(DisableGuards) = 1;
    else if (IS_INTOBJ(flag))
        TLS(DisableGuards) = (int)(INT_INTOBJ(flag));
    else
        RequireArgument(SELF_NAME, flag,
                        "must be a boolean or a small integer");
    return (Obj)0;
}

static Obj FuncWITH_TARGET_REGION(Obj self, Obj obj, Obj func)
{
    Region * volatile oldRegion = TLS(currentRegion);
    Region * volatile region = GetRegionOf(obj);

    RequireFunction(SELF_NAME, func);
    if (!region || !CheckExclusiveWriteAccess(obj))
        return ArgumentError(
            "WITH_TARGET_REGION: Requires write access to target region");

    GAP_TRY
    {
        TLS(currentRegion) = region;
        CALL_0ARGS(func);
        TLS(currentRegion) = oldRegion;
    }
    GAP_CATCH
    {
        TLS(currentRegion) = oldRegion;
        GAP_THROW();
    }
    return (Obj)0;
}


static Obj TYPE_THREAD;
static Obj TYPE_SEMAPHORE;
static Obj TYPE_CHANNEL;
static Obj TYPE_BARRIER;
static Obj TYPE_SYNCVAR;
static Obj TYPE_REGION;

static Obj TypeThread(Obj obj)
{
    return TYPE_THREAD;
}

static Obj TypeSemaphore(Obj obj)
{
    return TYPE_SEMAPHORE;
}

static Obj TypeChannel(Obj obj)
{
    return TYPE_CHANNEL;
}

static Obj TypeBarrier(Obj obj)
{
    return TYPE_BARRIER;
}

static Obj TypeSyncVar(Obj obj)
{
    return TYPE_SYNCVAR;
}

static Obj TypeRegion(Obj obj)
{
    return TYPE_REGION;
}

#ifdef USE_GASMAN
static void MarkSemaphoreBag(Bag);
static void MarkChannelBag(Bag);
static void MarkBarrierBag(Bag);
static void MarkSyncVarBag(Bag);
#endif
static void FinalizeMonitor(Bag);
static void PrintThread(Obj);
static void PrintSemaphore(Obj);
static void PrintChannel(Obj);
static void PrintBarrier(Obj);
static void PrintSyncVar(Obj);
static void PrintRegion(Obj);

GVarDescriptor LastInaccessibleGVar;
static GVarDescriptor MAX_INTERRUPTGVar;

static UInt RNAM_SIGINT;
static UInt RNAM_SIGCHLD;
static UInt RNAM_SIGVTALRM;
#ifdef SIGWINCH
static UInt RNAM_SIGWINCH;
#endif

#ifndef WARD_ENABLED
#ifdef USE_GASMAN
static void MarkSemaphoreBag(Bag bag)
{
    Semaphore * sem = (Semaphore *)(PTR_BAG(bag));
    MarkBag(sem->monitor);
}

static void MarkChannelBag(Bag bag)
{
    Channel * channel = (Channel *)(PTR_BAG(bag));
    MarkBag(channel->queue);
    MarkBag(channel->monitor);
}

static void MarkBarrierBag(Bag bag)
{
    Barrier * barrier = (Barrier *)(PTR_BAG(bag));
    MarkBag(barrier->monitor);
}

static void MarkSyncVarBag(Bag bag)
{
    SyncVar * syncvar = (SyncVar *)(PTR_BAG(bag));
    MarkBag(syncvar->queue);
    MarkBag(syncvar->monitor);
}
#endif

static void FinalizeMonitor(Bag bag)
{
    Monitor * monitor = (Monitor *)(PTR_BAG(bag));
    pthread_mutex_destroy(&monitor->lock);
}

static void LockChannel(Channel * channel)
{
    LockMonitor(ObjPtr(channel->monitor));
}

static void UnlockChannel(Channel * channel)
{
    UnlockMonitor(ObjPtr(channel->monitor));
}

static void SignalChannel(Channel * channel)
{
    if (channel->waiting)
        SignalMonitor(ObjPtr(channel->monitor));
}

static void WaitChannel(Channel * channel)
{
    channel->waiting++;
    WaitForMonitor(ObjPtr(channel->monitor));
    channel->waiting--;
}

static void ExpandChannel(Channel * channel)
{
    /* Growth ratio should be less than the golden ratio */
    const UInt oldCapacity = channel->capacity;
    const UInt newCapacity = ((oldCapacity * 25 / 16) | 1) + 1;
    GAP_ASSERT(newCapacity > oldCapacity);

    UInt i, tail;
    Obj  newqueue;
    newqueue = NEW_PLIST(T_PLIST, newCapacity);
    SET_LEN_PLIST(newqueue, newCapacity);
    SET_REGION(newqueue, REGION(channel->queue));
    channel->capacity = newCapacity;
    for (i = channel->head; i < oldCapacity; i++)
        ADDR_OBJ(newqueue)[i + 1] = ADDR_OBJ(channel->queue)[i + 1];
    for (i = 0; i < channel->tail; i++) {
        UInt d = oldCapacity + i;
        if (d >= newCapacity)
            d -= newCapacity;
        ADDR_OBJ(newqueue)[d + 1] = ADDR_OBJ(channel->queue)[i + 1];
    }
    tail = channel->head + oldCapacity;
    if (tail >= newCapacity)
        tail -= newCapacity;
    channel->tail = tail;
    channel->queue = newqueue;
}

static void AddToChannel(Channel * channel, Obj obj, int migrate)
{
    Obj      children;
    Region * region = REGION(channel->queue);
    UInt     i, len;
    if (migrate && IS_BAG_REF(obj) && REGION(obj) &&
        REGION(obj)->owner == GetTLS() && REGION(obj)->fixed_owner) {
        children = ReachableObjectsFrom(obj);
        len = children ? LEN_PLIST(children) : 0;
    }
    else {
        children = 0;
        len = 0;
    }
    for (i = 1; i <= len; i++) {
        Obj item = ELM_PLIST(children, i);
        SET_REGION(item, region);
    }
    ADDR_OBJ(channel->queue)[++channel->tail] = obj;
    ADDR_OBJ(channel->queue)[++channel->tail] = children;
    if (channel->tail == channel->capacity)
        channel->tail = 0;
    channel->size += 2;
}

static Obj RetrieveFromChannel(Channel * channel)
{
    Obj      obj = ADDR_OBJ(channel->queue)[++channel->head];
    Obj      children = ADDR_OBJ(channel->queue)[++channel->head];
    Region * region = TLS(currentRegion);
    UInt     i, len = children ? LEN_PLIST(children) : 0;
    ADDR_OBJ(channel->queue)[channel->head - 1] = 0;
    ADDR_OBJ(channel->queue)[channel->head] = 0;
    if (channel->head == channel->capacity)
        channel->head = 0;
    for (i = 1; i <= len; i++) {
        Obj item = ELM_PLIST(children, i);
        SET_REGION(item, region);
    }
    channel->size -= 2;
    return obj;
}

static Int TallyChannel(Channel * channel)
{
    Int result;
    LockChannel(channel);
    result = channel->size / 2;
    UnlockChannel(channel);
    return result;
}

static void SendChannel(Channel * channel, Obj obj, int migrate)
{
    LockChannel(channel);
    if (channel->size == channel->capacity && channel->dynamic)
        ExpandChannel(channel);
    while (channel->size == channel->capacity)
        WaitChannel(channel);
    AddToChannel(channel, obj, migrate);
    SignalChannel(channel);
    UnlockChannel(channel);
}

static void MultiSendChannel(Channel * channel, Obj list, int migrate)
{
    int listsize = LEN_LIST(list);
    int i;
    Obj obj;
    LockChannel(channel);
    for (i = 1; i <= listsize; i++) {
        if (channel->size == channel->capacity && channel->dynamic)
            ExpandChannel(channel);
        while (channel->size == channel->capacity)
            WaitChannel(channel);
        obj = ELM_LIST(list, i);
        AddToChannel(channel, obj, migrate);
    }
    SignalChannel(channel);
    UnlockChannel(channel);
}

static int TryMultiSendChannel(Channel * channel, Obj list, int migrate)
{
    int result = 0;
    int listsize = LEN_LIST(list);
    int i;
    Obj obj;
    LockChannel(channel);
    for (i = 1; i <= listsize; i++) {
        if (channel->size == channel->capacity && channel->dynamic)
            ExpandChannel(channel);
        if (channel->size == channel->capacity)
            break;
        obj = ELM_LIST(list, i);
        AddToChannel(channel, obj, migrate);
        result++;
    }
    SignalChannel(channel);
    UnlockChannel(channel);
    return result;
}

static int TrySendChannel(Channel * channel, Obj obj, int migrate)
{
    LockChannel(channel);
    if (channel->size == channel->capacity && channel->dynamic)
        ExpandChannel(channel);
    if (channel->size == channel->capacity) {
        UnlockChannel(channel);
        return 0;
    }
    AddToChannel(channel, obj, migrate);
    SignalChannel(channel);
    UnlockChannel(channel);
    return 1;
}

static Obj ReceiveChannel(Channel * channel)
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
    UInt       count = LEN_PLIST(channelList);
    UInt       i, p;
    Monitor ** monitors = alloca(count * sizeof(Monitor *));
    Channel ** channels = alloca(count * sizeof(Channel *));
    Obj        result;
    Channel *  channel;
    for (i = 0; i < count; i++)
        channels[i] = ObjPtr(ELM_PLIST(channelList, i + 1));
    SortChannels(count, channels);
    for (i = 0; i < count; i++)
        monitors[i] = ObjPtr(channels[i]->monitor);
    LockMonitors(count, monitors);
    p = TLS(multiplexRandomSeed);
    p = (p * 5 + 1);
    TLS(multiplexRandomSeed) = p;
    p %= count;
    for (i = 0; i < count; i++) {
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
        for (i = 0; i < count; i++)
            if (i != p)
                UnlockMonitor(monitors[i]);
    }
    else /* all channels are empty */
        for (;;) {
            for (i = 0; i < count; i++)
                channels[i]->waiting++;
            p = WaitForAnyMonitor(count, monitors);
            for (i = 0; i < count; i++)
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
    if (with_index) {
        Obj list = NEW_PLIST(T_PLIST, 2);
        SET_LEN_PLIST(list, 2);
        SET_ELM_PLIST(list, 1, result);
        for (i = 1; i <= count; i++)
            if (ObjPtr(ELM_PLIST(channelList, i)) == channel) {
                SET_ELM_PLIST(list, 2, INTOBJ_INT(i));
                break;
            }
        return list;
    }
    else
        return result;
}

static Obj MultiReceiveChannel(Channel * channel, UInt max)
{
    Obj  result;
    UInt count;
    UInt i;
    LockChannel(channel);
    if (max > channel->size / 2)
        count = channel->size / 2;
    else
        count = max;
    result = NEW_PLIST(T_PLIST, count);
    SET_LEN_PLIST(result, count);
    for (i = 0; i < count; i++) {
        Obj item = RetrieveFromChannel(channel);
        SET_ELM_PLIST(result, i + 1, item);
    }
    SignalChannel(channel);
    UnlockChannel(channel);
    return result;
}

static Obj InspectChannel(Channel * channel)
{
    LockChannel(channel);
    const UInt count = channel->size / 2;
    Obj result = NEW_PLIST(T_PLIST, count);
    SET_LEN_PLIST(result, count);
    for (UInt i = 0, p = channel->head; i < count; i++) {
        SET_ELM_PLIST(result, i + 1, ELM_PLIST(channel->queue, p + 1));
        p += 2;
        if (p == channel->capacity)
            p = 0;
    }
    UnlockChannel(channel);
    return result;
}

static Obj TryReceiveChannel(Channel * channel, Obj defaultobj)
{
    Obj result;
    LockChannel(channel);
    if (channel->size == 0) {
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
    Channel * channel;
    Bag       channelBag;
    channelBag = NewBag(T_CHANNEL, sizeof(Channel));
    channel = ObjPtr(channelBag);
    channel->monitor = NewMonitor();
    channel->size = channel->head = channel->tail = 0;
    channel->capacity = (capacity < 0) ? 20 : capacity * 2;
    channel->dynamic = (capacity < 0);
    channel->waiting = 0;
    channel->queue = NEW_PLIST(T_PLIST, channel->capacity);
    SET_REGION(channel->queue, LimboRegion);
    SET_LEN_PLIST(channel->queue, channel->capacity);
    return channelBag;
}

static int DestroyChannel(Channel * channel)
{
    return 1;
}
#endif

static Obj FuncCreateChannel(Obj self, Obj args)
{
    int capacity;
    switch (LEN_PLIST(args)) {
    case 0:
        capacity = -1;
        break;
    case 1:
        if (IS_INTOBJ(ELM_PLIST(args, 1))) {
            capacity = INT_INTOBJ(ELM_PLIST(args, 1));
            if (capacity <= 0)
                return ArgumentError(
                    "CreateChannel: Capacity must be positive");
            break;
        }
        return ArgumentError(
            "CreateChannel: Argument must be capacity of the channel");
    default:
        return ArgumentError(
            "CreateChannel: Function takes up to one argument");
    }
    return CreateChannel(capacity);
}

static BOOL IsChannel(Obj obj)
{
    return obj && TNUM_OBJ(obj) == T_CHANNEL;
}

static Obj FuncDestroyChannel(Obj self, Obj channel)
{
    RequireChannel(SELF_NAME, channel);
    if (!DestroyChannel(ObjPtr(channel)))
        ErrorQuit("DestroyChannel: Channel is in use", 0, 0);
    return (Obj)0;
}

static Obj FuncTallyChannel(Obj self, Obj channel)
{
    RequireChannel(SELF_NAME, channel);
    return INTOBJ_INT(TallyChannel(ObjPtr(channel)));
}

static Obj FuncSendChannel(Obj self, Obj channel, Obj obj)
{
    RequireChannel(SELF_NAME, channel);
    SendChannel(ObjPtr(channel), obj, 1);
    return (Obj)0;
}

static Obj FuncTransmitChannel(Obj self, Obj channel, Obj obj)
{
    RequireChannel(SELF_NAME, channel);
    SendChannel(ObjPtr(channel), obj, 0);
    return (Obj)0;
}

static Obj FuncMultiSendChannel(Obj self, Obj channel, Obj list)
{
    RequireChannel(SELF_NAME, channel);
    RequireDenseList(SELF_NAME, list);
    MultiSendChannel(ObjPtr(channel), list, 1);
    return (Obj)0;
}

static Obj FuncMultiTransmitChannel(Obj self, Obj channel, Obj list)
{
    RequireChannel(SELF_NAME, channel);
    RequireDenseList(SELF_NAME, list);
    MultiSendChannel(ObjPtr(channel), list, 0);
    return (Obj)0;
}

static Obj FuncTryMultiSendChannel(Obj self, Obj channel, Obj list)
{
    RequireChannel(SELF_NAME, channel);
    RequireDenseList(SELF_NAME, list);
    return INTOBJ_INT(TryMultiSendChannel(ObjPtr(channel), list, 1));
}


static Obj FuncTryMultiTransmitChannel(Obj self, Obj channel, Obj list)
{
    RequireChannel(SELF_NAME, channel);
    RequireDenseList(SELF_NAME, list);
    return INTOBJ_INT(TryMultiSendChannel(ObjPtr(channel), list, 0));
}


static Obj FuncTrySendChannel(Obj self, Obj channel, Obj obj)
{
    RequireChannel(SELF_NAME, channel);
    return TrySendChannel(ObjPtr(channel), obj, 1) ? True : False;
}

static Obj FuncTryTransmitChannel(Obj self, Obj channel, Obj obj)
{
    RequireChannel(SELF_NAME, channel);
    return TrySendChannel(ObjPtr(channel), obj, 0) ? True : False;
}

static Obj FuncReceiveChannel(Obj self, Obj channel)
{
    RequireChannel(SELF_NAME, channel);
    return ReceiveChannel(ObjPtr(channel));
}

static BOOL IsChannelList(Obj list)
{
    int len = LEN_PLIST(list);
    int i;
    if (len == 0)
        return 0;
    for (i = 1; i <= len; i++)
        if (!IsChannel(ELM_PLIST(list, i)))
            return 0;
    return 1;
}

static Obj FuncReceiveAnyChannel(Obj self, Obj args)
{
    if (IsChannelList(args))
        return ReceiveAnyChannel(args, 0);
    else {
        if (LEN_PLIST(args) == 1 && IS_PLIST(ELM_PLIST(args, 1)) &&
            IsChannelList(ELM_PLIST(args, 1)))
            return ReceiveAnyChannel(ELM_PLIST(args, 1), 0);
        else
            return ArgumentError(
                "ReceiveAnyChannel: Argument list must be channels");
    }
}

static Obj FuncReceiveAnyChannelWithIndex(Obj self, Obj args)
{
    if (IsChannelList(args))
        return ReceiveAnyChannel(args, 1);
    else {
        if (LEN_PLIST(args) == 1 && IS_PLIST(ELM_PLIST(args, 1)) &&
            IsChannelList(ELM_PLIST(args, 1)))
            return ReceiveAnyChannel(ELM_PLIST(args, 1), 1);
        else
            return ArgumentError(
                "ReceiveAnyChannelWithIndex: Argument list must be channels");
    }
}

static Obj FuncMultiReceiveChannel(Obj self, Obj channel, Obj count)
{
    RequireChannel(SELF_NAME, channel);
    RequireNonnegativeSmallInt(SELF_NAME, count);
    return MultiReceiveChannel(ObjPtr(channel), INT_INTOBJ(count));
}

static Obj FuncInspectChannel(Obj self, Obj channel)
{
    RequireChannel(SELF_NAME, channel);
    return InspectChannel(ObjPtr(channel));
}

static Obj FuncTryReceiveChannel(Obj self, Obj channel, Obj obj)
{
    RequireChannel(SELF_NAME, channel);
    return TryReceiveChannel(ObjPtr(channel), obj);
}

static Obj CreateSemaphore(UInt count)
{
    Semaphore * sem;
    Bag         semBag;
    semBag = NewBag(T_SEMAPHORE, sizeof(Semaphore));
    sem = ObjPtr(semBag);
    sem->monitor = NewMonitor();
    sem->count = count;
    sem->waiting = 0;
    return semBag;
}

static Obj FuncCreateSemaphore(Obj self, Obj args)
{
    Int count;
    switch (LEN_PLIST(args)) {
    case 0:
        count = 0;
        break;
    case 1:
        if (IS_INTOBJ(ELM_PLIST(args, 1))) {
            count = INT_INTOBJ(ELM_PLIST(args, 1));
            if (count < 0)
                return ArgumentError(
                    "CreateSemaphore: Initial count must be non-negative");
            break;
        }
        return ArgumentError(
            "CreateSemaphore: Argument must be initial count");
    default:
        return ArgumentError(
            "CreateSemaphore: Function takes up to two arguments");
    }
    return CreateSemaphore(count);
}

static Obj FuncSignalSemaphore(Obj self, Obj semaphore)
{
    Semaphore * sem;
    RequireSemaphore(SELF_NAME, semaphore);
    sem = ObjPtr(semaphore);
    LockMonitor(ObjPtr(sem->monitor));
    sem->count++;
    if (sem->waiting)
        SignalMonitor(ObjPtr(sem->monitor));
    UnlockMonitor(ObjPtr(sem->monitor));
    return (Obj)0;
}

static Obj FuncWaitSemaphore(Obj self, Obj semaphore)
{
    Semaphore * sem;
    RequireSemaphore(SELF_NAME, semaphore);
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
    return (Obj)0;
}

static Obj FuncTryWaitSemaphore(Obj self, Obj semaphore)
{
    Semaphore * sem;
    int         success;
    RequireSemaphore(SELF_NAME, semaphore);
    sem = ObjPtr(semaphore);
    LockMonitor(ObjPtr(sem->monitor));
    success = (sem->count > 0);
    if (success)
        sem->count--;
    sem->waiting--;
    if (sem->waiting && sem->count > 0)
        SignalMonitor(ObjPtr(sem->monitor));
    UnlockMonitor(ObjPtr(sem->monitor));
    return success ? True : False;
}

static void LockBarrier(Barrier * barrier)
{
    LockMonitor(ObjPtr(barrier->monitor));
}

static void UnlockBarrier(Barrier * barrier)
{
    UnlockMonitor(ObjPtr(barrier->monitor));
}

static void JoinBarrier(Barrier * barrier)
{
    barrier->waiting++;
    WaitForMonitor(ObjPtr(barrier->monitor));
    barrier->waiting--;
}

static void SignalBarrier(Barrier * barrier)
{
    if (barrier->waiting)
        SignalMonitor(ObjPtr(barrier->monitor));
}

static Obj CreateBarrier(void)
{
    Bag       barrierBag;
    Barrier * barrier;
    barrierBag = NewBag(T_BARRIER, sizeof(Barrier));
    barrier = ObjPtr(barrierBag);
    barrier->monitor = NewMonitor();
    barrier->count = 0;
    barrier->phase = 0;
    barrier->waiting = 0;
    return barrierBag;
}

static void StartBarrier(Barrier * barrier, UInt count)
{
    LockBarrier(barrier);
    barrier->count = count;
    barrier->phase++;
    UnlockBarrier(barrier);
}

static void WaitBarrier(Barrier * barrier)
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

static Obj FuncCreateBarrier(Obj self)
{
    return CreateBarrier();
}

static BOOL IsBarrier(Obj obj)
{
    return obj && TNUM_OBJ(obj) == T_BARRIER;
}

static Obj FuncStartBarrier(Obj self, Obj barrier, Obj count)
{
    RequireBarrier(SELF_NAME, barrier);
    Int c = GetSmallInt("StartBarrier", count);
    StartBarrier(ObjPtr(barrier), c);
    return (Obj)0;
}

static Obj FuncWaitBarrier(Obj self, Obj barrier)
{
    RequireBarrier(SELF_NAME, barrier);
    WaitBarrier(ObjPtr(barrier));
    return (Obj)0;
}

static void SyncWrite(SyncVar * var, Obj value)
{
    Monitor * monitor = ObjPtr(var->monitor);
    LockMonitor(monitor);
    if (var->written) {
        UnlockMonitor(monitor);
        ArgumentError("SyncWrite: Variable already has a value");
        return;
    }
    var->written = 1;
    var->value = value;
    SignalMonitor(monitor);
    UnlockMonitor(monitor);
}

static int SyncTryWrite(SyncVar * var, Obj value)
{
    Monitor * monitor = ObjPtr(var->monitor);
    LockMonitor(monitor);
    if (var->written) {
        UnlockMonitor(monitor);
        return 0;
    }
    var->written = 1;
    var->value = value;
    SignalMonitor(monitor);
    UnlockMonitor(monitor);
    return 1;
}

static Obj CreateSyncVar(void)
{
    Bag       syncvarBag;
    SyncVar * syncvar;
    syncvarBag = NewBag(T_SYNCVAR, sizeof(SyncVar));
    syncvar = ObjPtr(syncvarBag);
    syncvar->monitor = NewMonitor();
    syncvar->written = 0;
    syncvar->value = (Obj)0;
    return syncvarBag;
}


static Obj SyncRead(SyncVar * var)
{
    Monitor * monitor = ObjPtr(var->monitor);
    LockMonitor(monitor);
    while (!var->written)
        WaitForMonitor(monitor);
    if (monitor->head != NULL)
        SignalMonitor(monitor);
    UnlockMonitor(monitor);
    return var->value;
}

static Obj SyncIsBound(SyncVar * var)
{
    return var->value ? True : False;
}

static BOOL IsSyncVar(Obj var)
{
    return var && TNUM_OBJ(var) == T_SYNCVAR;
}

static Obj FuncCreateSyncVar(Obj self)
{
    return CreateSyncVar();
}

static Obj FuncSyncWrite(Obj self, Obj syncvar, Obj value)
{
    RequireSyncVar(SELF_NAME, syncvar);
    SyncWrite(ObjPtr(syncvar), value);
    return (Obj)0;
}

static Obj FuncSyncTryWrite(Obj self, Obj syncvar, Obj value)
{
    RequireSyncVar(SELF_NAME, syncvar);
    return SyncTryWrite(ObjPtr(syncvar), value) ? True : False;
}

static Obj FuncSyncRead(Obj self, Obj syncvar)
{
    RequireSyncVar(SELF_NAME, syncvar);
    return SyncRead(ObjPtr(syncvar));
}

static Obj FuncSyncIsBound(Obj self, Obj syncvar)
{
    RequireSyncVar(SELF_NAME, syncvar);
    return SyncIsBound(ObjPtr(syncvar));
}


static void PrintThread(Obj obj)
{
    char         buf[100];
    const char * status_message;
    LockThreadControl(0);
    const ThreadObject *thread = (const ThreadObject *)CONST_ADDR_OBJ(obj);
    switch (thread->status) {
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
    sprintf(buf, "<thread #%ld: %s>", (long)thread->id, status_message);
    UnlockThreadControl();
    Pr("%s", (Int)buf, 0);
}

static void PrintSemaphore(Obj obj)
{
    Semaphore * sem = ObjPtr(obj);
    Int         count;
    LockMonitor(ObjPtr(sem->monitor));
    count = sem->count;
    UnlockMonitor(ObjPtr(sem->monitor));
    Pr("<semaphore with count = %d>", (Int)count, 0);
}

static void PrintChannel(Obj obj)
{
    Channel * channel = ObjPtr(obj);
    Int       size, waiting, capacity;
    Pr("<channel with ", 0, 0);
    LockChannel(channel);
    size = channel->size;
    waiting = channel->waiting;
    if (channel->dynamic)
        capacity = -1;
    else
        capacity = channel->capacity;
    UnlockChannel(channel);
    if (capacity < 0)
        Pr("%d elements, %d waiting>", size / 2, waiting);
    else {
        Pr("%d/%d elements, ", size / 2, capacity / 2);
        Pr("%d waiting>", waiting, 0);
    }
}

static void PrintBarrier(Obj obj)
{
    Barrier * barrier = ObjPtr(obj);
    Int       count, waiting;
    LockBarrier(barrier);
    count = barrier->count;
    waiting = barrier->waiting;
    UnlockBarrier(barrier);
    Pr("<barrier with %d of %d threads arrived>", waiting, waiting+count);
}

static void PrintSyncVar(Obj obj)
{
    SyncVar * syncvar = ObjPtr(obj);
    int       written;
    LockMonitor(ObjPtr(syncvar->monitor));
    written = syncvar->written;
    UnlockMonitor(ObjPtr(syncvar->monitor));
    if (written)
        Pr("<initialized syncvar>", 0, 0);
    else
        Pr("<uninitialized syncvar>", 0, 0);
}

static void PrintRegion(Obj obj)
{
    char     buffer[32];
    Region * region = GetRegionOf(obj);
    Obj      name = GetRegionName(region);

    if (name) {
        Pr("<region: %g", (Int)name, 0);
    }
    else {
        snprintf(buffer, 32, "<region %p", (void *)GetRegionOf(obj));
        Pr(buffer, 0, 0);
    }
    if (region && region->count_active) {
        snprintf(buffer, 32, " (locked %zu/contended %zu)",
                 region->locks_acquired, region->locks_contended);
        Pr(buffer, 0, 0);
    }
    Pr(">", 0, 0);
}

static Obj FuncIS_LOCKED(Obj self, Obj obj)
{
    Region * region = IS_BAG_REF(obj) ? REGION(obj) : NULL;
    if (!region)
        return INTOBJ_INT(0);
    return INTOBJ_INT(IsLocked(region));
}

static Obj FuncLOCK(Obj self, Obj args)
{
    int   numargs = LEN_PLIST(args);
    int   count = 0;
    Obj * objects;
    LockMode * modes;
    LockMode   mode = LOCK_MODE_DEFAULT;
    int   i;
    int   result;

    if (numargs > 1024)
        return ArgumentError("LOCK: Too many arguments");
    objects = alloca(sizeof(Obj) * numargs);
    modes = alloca(sizeof(LockMode) * numargs);
    for (i = 1; i <= numargs; i++) {
        Obj obj;
        obj = ELM_PLIST(args, i);
        if (obj == True)
            mode = LOCK_MODE_READWRITE;
        else if (obj == False)
            mode = LOCK_MODE_READONLY;
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

static Obj FuncDO_LOCK(Obj self, Obj args)
{
    Obj result = FuncLOCK(self, args);
    if (result == Fail)
        ErrorMayQuit("Cannot lock required regions", 0, 0);
    return result;
}

static Obj FuncWRITE_LOCK(Obj self, Obj obj)
{
    const LockMode modes[] = { LOCK_MODE_READWRITE };
    int result = LockObjects(1, &obj, modes);
    if (result < 0)
      ErrorMayQuit("Cannot lock required regions", 0, 0);
    return INTOBJ_INT(result);
}

static Obj FuncREAD_LOCK(Obj self, Obj obj)
{
    const LockMode modes[] = { LOCK_MODE_READONLY };
    int result = LockObjects(1, &obj, modes);
    if (result < 0)
      ErrorMayQuit("Cannot lock required regions", 0, 0);
    return INTOBJ_INT(result);
}

static Obj FuncTRYLOCK(Obj self, Obj args)
{
    int   numargs = LEN_PLIST(args);
    int   count = 0;
    Obj * objects;
    LockMode * modes;
    LockMode   mode = LOCK_MODE_DEFAULT;
    int   i;
    int   result;

    if (numargs > 1024)
        return ArgumentError("TRYLOCK: Too many arguments");
    objects = alloca(sizeof(Obj) * numargs);
    modes = alloca(sizeof(int) * numargs);
    for (i = 1; i <= numargs; i++) {
        Obj obj;
        obj = ELM_PLIST(args, i);
        if (obj == True)
            mode = LOCK_MODE_READWRITE;
        else if (obj == False)
            mode = LOCK_MODE_READONLY;
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

static Obj FuncUNLOCK(Obj self, Obj sp)
{
    RequireNonnegativeSmallInt(SELF_NAME, sp);
    PopRegionLocks(INT_INTOBJ(sp));
    return (Obj)0;
}

static Obj FuncCURRENT_LOCKS(Obj self)
{
    UInt i, len = TLS(lockStackPointer);
    Obj  result = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(result, len);
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(result, i, ELM_PLIST(TLS(lockStack), i));
    return result;
}

static Obj FuncREFINE_TYPE(Obj self, Obj obj)
{
    if (IS_BAG_REF(obj) && CheckExclusiveWriteAccess(obj)) {
        TYPE_OBJ(obj);
    }
    return obj;
}

static Obj FuncREACHABLE(Obj self, Obj obj)
{
    Obj result = ReachableObjectsFrom(obj);
    if (result == NULL) {
        result = NewPlistFromArgs(obj);
    }
    return result;
}

static Obj FuncCLONE_REACHABLE(Obj self, Obj obj)
{
    return CopyReachableObjectsFrom(obj, 0, 0, 0);
}

static Obj FuncCLONE_DELIMITED(Obj self, Obj obj)
{
    return CopyReachableObjectsFrom(obj, 1, 0, 0);
}

static Obj FuncNEW_REGION(Obj self, Obj name, Obj prec)
{
    if (name != Fail && !IsStringConv(name))
        RequireArgument(SELF_NAME, name, "must be a string or fail");
    Int p = GetSmallInt("NEW_REGION", prec);
    Region * region = NewRegion();
    region->prec = p;
    if (name != Fail)
        SetRegionName(region, name);
    return region->obj;
}

static Obj FuncREGION_PRECEDENCE(Obj self, Obj regobj)
{
    Region * region = GetRegionOf(regobj);
    return region == NULL ? INTOBJ_INT(0) : INTOBJ_INT(region->prec);
}

static int AutoRetyping = 0;

static int
MigrateObjects(int count, Obj * objects, Region * target, int retype)
{
    int i;
    if (count && retype && IS_BAG_REF(objects[0]) &&
        REGION(objects[0])->owner == GetTLS() && AutoRetyping) {
        for (i = 0; i < count; i++)
            if (REGION(objects[i])->owner == GetTLS())
                CLEAR_OBJ_FLAG(objects[i], OBJ_FLAG_TESTED);
        for (i = 0; i < count; i++) {
            if (REGION(objects[i])->owner == GetTLS() &&
                IS_PLIST(objects[i])) {
                if (!TEST_OBJ_FLAG(objects[i], OBJ_FLAG_TESTED))
                    TYPE_OBJ(objects[i]);
                if (retype >= 2)
                    IS_SSORT_LIST(objects[i]); // record if the list a set in the tnum
            }
        }
    }
    for (i = 0; i < count; i++) {
        Region * region;
        if (IS_BAG_REF(objects[i])) {
            region = REGION(objects[i]);
            if (!region || region->owner != GetTLS())
                return 0;
        }
    }
    // If we are migrating records to a region where they become immutable,
    // they need to be sorted, as sorting upon access may prove impossible.
    for (i = 0; i < count; i++) {
        Obj obj = objects[i];
        if (TNUM_OBJ(obj) == T_PREC) {
            SortPRecRNam(obj, 0);
        }
        SET_REGION(obj, target);
    }
    return 1;
}

static Obj FuncSHARE(Obj self, Obj obj, Obj name, Obj prec)
{
    if (name != Fail && !IsStringConv(name))
        RequireArgument(SELF_NAME, name, "must be a string or fail");
    Int p = GetSmallInt("SHARE", prec);
    Region * region = NewRegion();
    region->prec = p;

    Obj reachable = ReachableObjectsFrom(obj);
    if (!MigrateObjects(LEN_PLIST(reachable), ADDR_OBJ(reachable) + 1, region,
                        1))
        return ArgumentError(
            "SHARE: Thread does not have exclusive access to objects");
    if (name != Fail)
        SetRegionName(region, name);
    return obj;
}

static Obj FuncSHARE_RAW(Obj self, Obj obj, Obj name, Obj prec)
{
    if (name != Fail && !IsStringConv(name))
        RequireArgument(SELF_NAME, name, "must be a string or fail");
    Int p = GetSmallInt("SHARE_RAW", prec);
    Region * region = NewRegion();
    region->prec = p;

    Obj reachable = ReachableObjectsFrom(obj);
    if (!MigrateObjects(LEN_PLIST(reachable), ADDR_OBJ(reachable) + 1, region,
                        0))
        return ArgumentError(
            "SHARE_RAW: Thread does not have exclusive access to objects");
    if (name != Fail)
        SetRegionName(region, name);
    return obj;
}

static Obj FuncSHARE_NORECURSE(Obj self, Obj obj, Obj name, Obj prec)
{
    if (name != Fail && !IsStringConv(name))
        RequireArgument(SELF_NAME, name, "must be a string or fail");
    Int p = GetSmallInt("SHARE_NORECURSE", prec);
    Region * region = NewRegion();
    region->prec = p;
    if (!MigrateObjects(1, &obj, region, 0))
        return ArgumentError("SHARE_NORECURSE: Thread does not have "
                             "exclusive access to objects");
    if (name != Fail)
        SetRegionName(region, name);
    return obj;
}

static Obj FuncADOPT(Obj self, Obj obj)
{
    Obj reachable = ReachableObjectsFrom(obj);
    if (!MigrateObjects(LEN_PLIST(reachable), ADDR_OBJ(reachable) + 1,
                        TLS(threadRegion), 0))
        return ArgumentError(
            "ADOPT: Thread does not have exclusive access to objects");
    return obj;
}

static Obj FuncADOPT_NORECURSE(Obj self, Obj obj)
{
    if (!MigrateObjects(1, &obj, TLS(threadRegion), 0))
        return ArgumentError("ADOPT_NORECURSE: Thread does not have "
                             "exclusive access to objects");
    return obj;
}

static Obj FuncMIGRATE(Obj self, Obj obj, Obj target)
{
    Region * target_region = GetRegionOf(target);
    Obj      reachable;
    if (!target_region ||
        IsLocked(target_region) != LOCK_STATUS_READWRITE_LOCKED)
        return ArgumentError("MIGRATE: Thread does not have exclusive access "
                             "to target region");
    reachable = ReachableObjectsFrom(obj);
    if (!MigrateObjects(LEN_PLIST(reachable), ADDR_OBJ(reachable) + 1,
                        target_region, 1))
        return ArgumentError(
            "MIGRATE: Thread does not have exclusive access to objects");
    return obj;
}

static Obj FuncMIGRATE_RAW(Obj self, Obj obj, Obj target)
{
    Region * target_region = GetRegionOf(target);
    Obj      reachable;
    if (!target_region ||
        IsLocked(target_region) != LOCK_STATUS_READWRITE_LOCKED)
        return ArgumentError("MIGRATE_RAW: Thread does not have exclusive access "
                             "to target region");
    reachable = ReachableObjectsFrom(obj);
    if (!MigrateObjects(LEN_PLIST(reachable), ADDR_OBJ(reachable) + 1,
                        target_region, 0))
        return ArgumentError(
            "MIGRATE_RAW: Thread does not have exclusive access to objects");
    return obj;
}

static Obj FuncMIGRATE_NORECURSE(Obj self, Obj obj, Obj target)
{
    Region * target_region = GetRegionOf(target);
    if (!target_region ||
        IsLocked(target_region) != LOCK_STATUS_READWRITE_LOCKED)
        return ArgumentError("MIGRATE_NORECURSE: Thread does not have "
                             "exclusive access to target region");
    if (!MigrateObjects(1, &obj, target_region, 0))
        return ArgumentError("MIGRATE_NORECURSE: Thread does not have "
                             "exclusive access to object");
    return obj;
}

static Obj FuncMAKE_PUBLIC(Obj self, Obj obj)
{
    Obj reachable = ReachableObjectsFrom(obj);
    if (!MigrateObjects(LEN_PLIST(reachable), ADDR_OBJ(reachable) + 1, NULL,
                        0))
        return ArgumentError(
            "MAKE_PUBLIC: Thread does not have exclusive access to objects");
    return obj;
}

static Obj FuncMAKE_PUBLIC_NORECURSE(Obj self, Obj obj)
{
    if (!MigrateObjects(1, &obj, NULL, 0))
        return ArgumentError("MAKE_PUBLIC_NORECURSE: Thread does not have "
                             "exclusive access to objects");
    return obj;
}

static Obj FuncFORCE_MAKE_PUBLIC(Obj self, Obj obj)
{
    if (!IS_BAG_REF(obj))
        return ArgumentError("FORCE_MAKE_PUBLIC: Argument is a small integer "
                             "or finite-field element");
    MakeBagPublic(obj);
    return obj;
}

static Obj FuncMakeThreadLocal(Obj self, Obj var)
{
    char * name;
    UInt   gvar;
    if (!IsStringConv(var) || GET_LEN_STRING(var) == 0)
        RequireArgument(SELF_NAME, var, "must be a variable name");
    name = CSTR_STRING(var);
    gvar = GVarName(name);
    name = CSTR_STRING(NameGVar(gvar)); /* to apply namespace scopes where needed. */
    MakeThreadLocalVar(gvar, RNamName(name));
    return (Obj)0;
}

static Obj FuncMakeReadOnlyObj(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    Obj      reachable;
    if (!region || region == ReadOnlyRegion)
        return obj;
    reachable = ReachableObjectsFrom(obj);
    if (!MigrateObjects(LEN_PLIST(reachable), ADDR_OBJ(reachable) + 1,
                        ReadOnlyRegion, 1))
        return ArgumentError(
            "MakeReadOnlyObj: Thread does not have exclusive access to objects");
    return obj;
}

static Obj FuncMakeReadOnlyRaw(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    Obj      reachable;
    if (!region || region == ReadOnlyRegion)
        return obj;
    reachable = ReachableObjectsFrom(obj);
    if (!MigrateObjects(LEN_PLIST(reachable), ADDR_OBJ(reachable) + 1,
                        ReadOnlyRegion, 0))
        return ArgumentError(
            "MakeReadOnlyObj: Thread does not have exclusive access to objects");
    return obj;
}

static Obj FuncMakeReadOnlySingleObj(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    if (!region || region == ReadOnlyRegion)
        return obj;
    if (!MigrateObjects(1, &obj, ReadOnlyRegion, 0))
        return ArgumentError("MakeReadOnlySingleObj: Thread does not have "
                             "exclusive access to object");
    return obj;
}

static Obj FuncIsReadOnlyObj(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);
    return (region == ReadOnlyRegion) ? True : False;
}

static Obj FuncENABLE_AUTO_RETYPING(Obj self)
{
    // FIXME: but how does one turn off AutoRetyping again???
    AutoRetyping = 1;
    return (Obj)0;
}

static Obj FuncORDERED_READ(Obj self, Obj obj)
{
    MEMBAR_READ();
    return obj;
}

static Obj FuncORDERED_WRITE(Obj self, Obj obj)
{
    MEMBAR_WRITE();
    return obj;
}

static Obj FuncDEFAULT_SIGINT_HANDLER(Obj self)
{
    /* do nothing */
    return (Obj)0;
}

static UInt SigVTALRMCounter = 0;

static Obj FuncDEFAULT_SIGVTALRM_HANDLER(Obj self)
{
    SigVTALRMCounter++;
    return (Obj)0;
}

#ifdef SIGWINCH
    extern void syWindowChangeIntr(int signr);
#endif

static Obj FuncDEFAULT_SIGWINCH_HANDLER(Obj self)
{
#ifdef SIGWINCH
    syWindowChangeIntr(SIGWINCH);
#endif
    return (Obj)0;
}

static void HandleSignal(Obj handlers, UInt rnam)
{
    Obj func = ELM_REC(handlers, rnam);
    if (!func || TNUM_OBJ(func) != T_FUNCTION || NARG_FUNC(func) > 0)
        return;
    CALL_0ARGS(func);
}

static sigset_t GAPSignals;

static Obj FuncSIGWAIT(Obj self, Obj handlers)
{
    int sig;
    if (!IS_REC(handlers))
        return ArgumentError("SIGWAIT: Argument must be a record");
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
    return (Obj)0;
}

void InitSignals(void)
{
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

static Obj FuncPERIODIC_CHECK(Obj self, Obj count, Obj func)
{
    UInt n;
    RequireNonnegativeSmallInt(SELF_NAME, count);
    RequireFunction(SELF_NAME, func);
    /*
     * The following read of SigVTALRMCounter is a dirty read. We don't
     * need to synchronize access to it because it's a monotonically
     * increasing value and we only need it to succeed eventually.
     */
    n = INT_INTOBJ(count) / 10;
    if (TLS(PeriodicCheckCount) + n < SigVTALRMCounter) {
        TLS(PeriodicCheckCount) = SigVTALRMCounter;
        CALL_0ARGS(func);
    }
    return (Obj)0;
}


/*
 * Region lock performance counters
 */
static Obj FuncREGION_COUNTERS_ENABLE(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);

    if (!region)
        return ArgumentError(
            "REGION_COUNTERS_ENABLE: Cannot enable counters for this region");

    region->count_active = 1;
    return (Obj)0;
}

static Obj FuncREGION_COUNTERS_DISABLE(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);

    if (!region)
        return ArgumentError("REGION_COUNTERS_DISABLE: Cannot disable "
                             "counters for this region");

    region->count_active = 0;
    return (Obj)0;
}

static Obj FuncREGION_COUNTERS_GET_STATE(Obj self, Obj obj)
{
    Obj      result;
    Region * region = GetRegionOf(obj);

    if (!region)
        return ArgumentError(
            "REGION_COUNTERS_GET_STATE: Cannot get counters for this region");

    result = INTOBJ_INT(region->count_active);

    return result;
}

static Obj FuncREGION_COUNTERS_GET(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);

    if (!region)
        return ArgumentError(
            "REGION_COUNTERS_GET: Cannot get counters for this region");

    return GetRegionLockCounters(region);
}

static Obj FuncREGION_COUNTERS_RESET(Obj self, Obj obj)
{
    Region * region = GetRegionOf(obj);

    if (!region)
        return ArgumentError(
            "REGION_COUNTERS_RESET: Cannot reset counters for this region");

    ResetRegionLockCounters(region);

    return (Obj)0;
}

static Obj FuncTHREAD_COUNTERS_ENABLE(Obj self)
{
    TLS(CountActive) = 1;

    return (Obj)0;
}

static Obj FuncTHREAD_COUNTERS_DISABLE(Obj self)
{
    TLS(CountActive) = 0;

    return (Obj)0;
}

static Obj FuncTHREAD_COUNTERS_GET_STATE(Obj self)
{
    Obj result;

    result = INTOBJ_INT(TLS(CountActive));

    return result;
}

static Obj FuncTHREAD_COUNTERS_RESET(Obj self)
{
    TLS(LocksAcquired) = TLS(LocksContended) = 0;

    return (Obj)0;
}

static Obj FuncTHREAD_COUNTERS_GET(Obj self)
{
    Obj result;

    result = NEW_PLIST(T_PLIST, 2);
    SET_LEN_PLIST(result, 2);
    SET_ELM_PLIST(result, 1, INTOBJ_INT(TLS(LocksAcquired)));
    SET_ELM_PLIST(result, 2, INTOBJ_INT(TLS(LocksContended)));

    return result;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
    // install info string
    { T_THREAD, "thread" },
    { T_MONITOR, "monitor" },
    { T_REGION, "region" },
    { T_SEMAPHORE, "semaphore" },
    { T_CHANNEL, "channel" },
    { T_BARRIER, "barrier" },
    { T_SYNCVAR, "syncvar" },
    { -1,    "" }
};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(CreateThread, -1, "function"),
    GVAR_FUNC_0ARGS(CurrentThread),
    GVAR_FUNC_1ARGS(ThreadID, thread),
    GVAR_FUNC_1ARGS(WaitThread, thread),
    GVAR_FUNC_1ARGS(KillThread, thread),
    GVAR_FUNC_2ARGS(InterruptThread, thread, handler),
    GVAR_FUNC_2ARGS(SetInterruptHandler, handler, function),
    GVAR_FUNC_1ARGS(PauseThread, thread),
    GVAR_FUNC_1ARGS(ResumeThread, thread),
    GVAR_FUNC_1ARGS(HASH_LOCK, object),
    GVAR_FUNC_1ARGS(HASH_LOCK_SHARED, object),
    GVAR_FUNC_1ARGS(HASH_UNLOCK, object),
    GVAR_FUNC_1ARGS(HASH_UNLOCK_SHARED, object),
    GVAR_FUNC_2ARGS(HASH_SYNCHRONIZED, object, function),
    GVAR_FUNC_2ARGS(HASH_SYNCHRONIZED_SHARED, object, function),
    GVAR_FUNC_1ARGS(RegionOf, object),
    GVAR_FUNC_2ARGS(SetRegionName, obj, name),
    GVAR_FUNC_1ARGS(ClearRegionName, obj),
    GVAR_FUNC_1ARGS(RegionName, obj),
    GVAR_FUNC_2ARGS(WITH_TARGET_REGION, region, function),
    GVAR_FUNC_1ARGS(IsShared, object),
    GVAR_FUNC_1ARGS(IsPublic, object),
    GVAR_FUNC_1ARGS(IsThreadLocal, object),
    GVAR_FUNC_1ARGS(HaveWriteAccess, object),
    GVAR_FUNC_1ARGS(HaveReadAccess, object),
    GVAR_FUNC(CreateSemaphore, -1, "[count]"),
    GVAR_FUNC_1ARGS(SignalSemaphore, semaphore),
    GVAR_FUNC_1ARGS(WaitSemaphore, semaphore),
    GVAR_FUNC_1ARGS(TryWaitSemaphore, semaphore),
    GVAR_FUNC(CreateChannel, -1, "[size]"),
    GVAR_FUNC_1ARGS(DestroyChannel, channel),
    GVAR_FUNC_1ARGS(TallyChannel, channel),
    GVAR_FUNC_2ARGS(SendChannel, channel, obj),
    GVAR_FUNC_2ARGS(TransmitChannel, channel, obj),
    GVAR_FUNC_1ARGS(ReceiveChannel, channel),
    GVAR_FUNC(ReceiveAnyChannel, -1, "channel list"),
    GVAR_FUNC(ReceiveAnyChannelWithIndex, -1, "channel list"),
    GVAR_FUNC_2ARGS(MultiReceiveChannel, channel, count),
    GVAR_FUNC_2ARGS(TryReceiveChannel, channel, obj),
    GVAR_FUNC_2ARGS(MultiSendChannel, channel, list),
    GVAR_FUNC_2ARGS(TryMultiSendChannel, channel, list),
    GVAR_FUNC_2ARGS(TrySendChannel, channel, obj),
    GVAR_FUNC_2ARGS(MultiTransmitChannel, channel, list),
    GVAR_FUNC_2ARGS(TryMultiTransmitChannel, channel, list),
    GVAR_FUNC_2ARGS(TryTransmitChannel, channel, obj),
    GVAR_FUNC_1ARGS(InspectChannel, channel),
    GVAR_FUNC_0ARGS(CreateBarrier),
    GVAR_FUNC_2ARGS(StartBarrier, barrier, count),
    GVAR_FUNC_1ARGS(WaitBarrier, barrier),
    GVAR_FUNC_0ARGS(CreateSyncVar),
    GVAR_FUNC_2ARGS(SyncWrite, syncvar, obj),
    GVAR_FUNC_2ARGS(SyncTryWrite, syncvar, obj),
    GVAR_FUNC_1ARGS(SyncRead, syncvar),
    GVAR_FUNC_1ARGS(SyncIsBound, syncvar),
    GVAR_FUNC_1ARGS(IS_LOCKED, obj),
    GVAR_FUNC(LOCK, -1, "obj, ..."),
    GVAR_FUNC(DO_LOCK, -1, "obj, ..."),
    GVAR_FUNC_1ARGS(WRITE_LOCK, obj),
    GVAR_FUNC_1ARGS(READ_LOCK, obj),
    GVAR_FUNC(TRYLOCK, -1, "obj, ..."),
    GVAR_FUNC_1ARGS(UNLOCK, sp),
    GVAR_FUNC_0ARGS(CURRENT_LOCKS),
    GVAR_FUNC_1ARGS(REFINE_TYPE, obj),
    GVAR_FUNC_2ARGS(NEW_REGION, string, integer),
    GVAR_FUNC_1ARGS(REGION_PRECEDENCE, obj),
    GVAR_FUNC_3ARGS(SHARE, obj, string, integer),
    GVAR_FUNC_3ARGS(SHARE_RAW, obj, string, integer),
    GVAR_FUNC_3ARGS(SHARE_NORECURSE, obj, string, integer),
    GVAR_FUNC_1ARGS(ADOPT, obj),
    GVAR_FUNC_1ARGS(ADOPT_NORECURSE, obj),
    GVAR_FUNC_2ARGS(MIGRATE, obj, target),
    GVAR_FUNC_2ARGS(MIGRATE_RAW, obj, target),
    GVAR_FUNC_2ARGS(MIGRATE_NORECURSE, obj, target),
    GVAR_FUNC_1ARGS(MAKE_PUBLIC, obj),
    GVAR_FUNC_1ARGS(MAKE_PUBLIC_NORECURSE, obj),
    GVAR_FUNC_1ARGS(FORCE_MAKE_PUBLIC, obj),
    GVAR_FUNC_1ARGS(REACHABLE, obj),
    GVAR_FUNC_1ARGS(CLONE_REACHABLE, obj),
    GVAR_FUNC_1ARGS(CLONE_DELIMITED, obj),
    GVAR_FUNC_1ARGS(MakeThreadLocal, var),
    GVAR_FUNC_1ARGS(MakeReadOnlyObj, obj),
    GVAR_FUNC_1ARGS(MakeReadOnlyRaw, obj),
    GVAR_FUNC_1ARGS(MakeReadOnlySingleObj, obj),
    GVAR_FUNC_1ARGS(IsReadOnlyObj, obj),
    GVAR_FUNC_0ARGS(ENABLE_AUTO_RETYPING),
    GVAR_FUNC_1ARGS(ORDERED_READ, obj),
    GVAR_FUNC_1ARGS(ORDERED_WRITE, obj),
    GVAR_FUNC_1ARGS(CREATOR_OF, obj),
    GVAR_FUNC_1ARGS(DISABLE_GUARDS, flag),
    GVAR_FUNC_0ARGS(DEFAULT_SIGINT_HANDLER),
    GVAR_FUNC_0ARGS(DEFAULT_SIGVTALRM_HANDLER),
    GVAR_FUNC_0ARGS(DEFAULT_SIGWINCH_HANDLER),
    GVAR_FUNC_1ARGS(SIGWAIT, record),
    GVAR_FUNC_2ARGS(PERIODIC_CHECK, count, function),
    GVAR_FUNC_1ARGS(REGION_COUNTERS_ENABLE, region),
    GVAR_FUNC_1ARGS(REGION_COUNTERS_DISABLE, region),
    GVAR_FUNC_1ARGS(REGION_COUNTERS_GET_STATE, region),
    GVAR_FUNC_1ARGS(REGION_COUNTERS_GET, region),
    GVAR_FUNC_1ARGS(REGION_COUNTERS_RESET, region),
    GVAR_FUNC_0ARGS(THREAD_COUNTERS_ENABLE),
    GVAR_FUNC_0ARGS(THREAD_COUNTERS_DISABLE),
    GVAR_FUNC_0ARGS(THREAD_COUNTERS_GET_STATE),
    GVAR_FUNC_0ARGS(THREAD_COUNTERS_GET),
    GVAR_FUNC_0ARGS(THREAD_COUNTERS_RESET),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable(BagNames);

    // install the type methods
    TypeObjFuncs[T_THREAD] = TypeThread;
    TypeObjFuncs[T_REGION] = TypeRegion;
    TypeObjFuncs[T_SEMAPHORE] = TypeSemaphore;
    TypeObjFuncs[T_CHANNEL] = TypeChannel;
    TypeObjFuncs[T_BARRIER] = TypeBarrier;
    TypeObjFuncs[T_SYNCVAR] = TypeSyncVar;

    // install global variables
    InitCopyGVar("TYPE_THREAD", &TYPE_THREAD);
    InitCopyGVar("TYPE_REGION", &TYPE_REGION);
    InitCopyGVar("TYPE_SEMAPHORE", &TYPE_SEMAPHORE);
    InitCopyGVar("TYPE_CHANNEL", &TYPE_CHANNEL);
    InitCopyGVar("TYPE_BARRIER", &TYPE_BARRIER);
    InitCopyGVar("TYPE_SYNCVAR", &TYPE_SYNCVAR);

    DeclareGVar(&LastInaccessibleGVar, "LastInaccessible");
    DeclareGVar(&MAX_INTERRUPTGVar, "MAX_INTERRUPT");

    // install mark functions
    InitMarkFuncBags(T_THREAD, MarkNoSubBags);
    InitMarkFuncBags(T_MONITOR, MarkNoSubBags);
    InitMarkFuncBags(T_REGION, MarkAllSubBags);
#ifdef USE_GASMAN
    InitMarkFuncBags(T_SEMAPHORE, MarkSemaphoreBag);
    InitMarkFuncBags(T_CHANNEL, MarkChannelBag);
    InitMarkFuncBags(T_BARRIER, MarkBarrierBag);
    InitMarkFuncBags(T_SYNCVAR, MarkSyncVarBag);
#endif

    // install finalizer functions
    InitFreeFuncBag(T_MONITOR, FinalizeMonitor);

    // install print functions
    PrintObjFuncs[T_THREAD] = PrintThread;
    PrintObjFuncs[T_REGION] = PrintRegion;
    PrintObjFuncs[T_SEMAPHORE] = PrintSemaphore;
    PrintObjFuncs[T_CHANNEL] = PrintChannel;
    PrintObjFuncs[T_BARRIER] = PrintBarrier;
    PrintObjFuncs[T_SYNCVAR] = PrintSyncVar;

    // install mutability functions
    IsMutableObjFuncs[T_THREAD] = AlwaysNo;
    IsMutableObjFuncs[T_REGION] = AlwaysYes;
    IsMutableObjFuncs[T_SEMAPHORE] = AlwaysYes;
    IsMutableObjFuncs[T_CHANNEL] = AlwaysYes;
    IsMutableObjFuncs[T_BARRIER] = AlwaysYes;
    IsMutableObjFuncs[T_SYNCVAR] = AlwaysYes;

    // make bag types public
    MakeBagTypePublic(T_THREAD);
    MakeBagTypePublic(T_REGION);
    MakeBagTypePublic(T_SEMAPHORE);
    MakeBagTypePublic(T_CHANNEL);
    MakeBagTypePublic(T_SYNCVAR);
    MakeBagTypePublic(T_BARRIER);

    PublicRegion = NewBag(T_REGION, sizeof(Region *));

#ifdef HPCGAP
    DeclareGVar(&GVarTHREAD_INIT, "THREAD_INIT");
    DeclareGVar(&GVarTHREAD_EXIT, "THREAD_EXIT");
#endif

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable(GVarFuncs);
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

    ExportAsConstantGVar(MAX_THREADS);

    return 0;
}


/****************************************************************************
**
*F  InitInfoThreadAPI() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "threadapi",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoThreadAPI(void)
{
    return &module;
}
