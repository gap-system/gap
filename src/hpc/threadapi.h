/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_THREADAPI_H
#define GAP_THREADAPI_H

#include "objects.h"

#include <pthread.h>

#if !defined(HPCGAP)
#error This header is only meant to be used with HPC-GAP
#endif


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
