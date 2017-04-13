#ifndef GAP_THREADAPI_H
#define GAP_THREADAPI_H

#include <pthread.h>

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
Obj NewMonitor();
void LockMonitor(Monitor *monitor);
int TryLockMonitor(Monitor *monitor);
void UnlockMonitor(Monitor *monitor);
void WaitForMonitor(Monitor *monitor);
UInt WaitForAnyMonitor(UInt count, Monitor **monitors);
void SignalMonitor(Monitor *monitor);
void SortMonitors(UInt count, Monitor **monitors);
void LockMonitors(UInt count, Monitor **monitors);
void UnlockMonitors(UInt count, Monitor **monitors);

void InitSignals();

void InitThreadAPIState();
void DestroyThreadAPIState();

/****************************************************************************
**
*F  MergeSort() . . . . . . . . . . . . . . . sort an array using mergesort.
**
**  MergeSort() sorts an array of 'count' elements of individual size 'width'
**  with ordering determined by the parameter 'lessThan'. The 'lessThan'
**  function is to return a non-zero value if the first argument is less
**  than the second argument, zero otherwise.
**
**  FIXME: move this to a better place
*/

extern void MergeSort(void *data, UInt count, UInt width,
  int (*lessThan)(const void *a, const void *));

#endif // GAP_THREADAPI_H
