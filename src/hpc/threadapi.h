#ifndef GAP_THREADAPI_H
#define GAP_THREADAPI_H

#include <src/objects.h>

#include <pthread.h>


enum ThreadObjectStatus {
    THREAD_TERMINATED   = 1,
    THREAD_JOINED       = 2,
};

// Memory layout of T_THREAD bags.
typedef struct ThreadObject {
    void *tls;
    UInt id;
    UInt status;
} ThreadObject;

Obj NewThreadObject(UInt id);


typedef struct {
  pthread_mutex_t lock;
  struct WaitList *head, *tail;
} Monitor;

Obj KeepAlive(Obj);
void StopKeepAlive(Obj);
#define KEPTALIVE(obj) (ADDR_OBJ(obj)[1])
StructInitInfo *InitInfoThreadAPI(void);

static inline Monitor *MonitorPtr(Obj obj)
{
  assert(TNUM_OBJ(obj) == T_MONITOR);
  return (Monitor *)(PTR_BAG(obj));
}
Obj NewMonitor(void);
void LockMonitor(Monitor *monitor);
int TryLockMonitor(Monitor *monitor);
void UnlockMonitor(Monitor *monitor);
void WaitForMonitor(Monitor *monitor);
UInt WaitForAnyMonitor(UInt count, Monitor **monitors);
void SignalMonitor(Monitor *monitor);
void SortMonitors(UInt count, Monitor **monitors);
void LockMonitors(UInt count, Monitor **monitors);
void UnlockMonitors(UInt count, Monitor **monitors);

void InitSignals(void);

#endif // GAP_THREADAPI_H
