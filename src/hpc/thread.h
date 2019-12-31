/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_THREAD_H
#define GAP_THREAD_H

#include "common.h"

#if !defined(HPCGAP)

/*
 * HPC-GAP stubs.
 */

#define HashLock(obj)         do { } while(0)
#define HashLockShared(obj)   do { } while(0)
#define HashUnlock(obj)       do { } while(0)
#define HashUnlockShared(obj) do { } while(0)

#else

#include "hpc/tlsconfig.h"
#include "hpc/region.h"

/* Maximum number of threads excluding the main thread */
#define MAX_THREADS 1023

extern int PreThreadCreation;

#ifndef USE_NATIVE_TLS
void *AllocateTLS(void);
void FreeTLS(void *address);
#endif


void AddGCRoots(void);
void RemoveGCroots(void);

void RunThreadedMain(
        int (*mainFunction)(int, char **),
        int argc,
        char **argv );

void CreateMainRegion(void);
Obj RunThread(void (*start)(void *), void *arg);
int JoinThread(int id);

void RegionWriteLock(Region *region);
int RegionTryWriteLock(Region *region);
void RegionWriteUnlock(Region *region);
void RegionReadLock(Region *region);
int RegionTryReadLock(Region *region);
void RegionReadUnlock(Region *region);
void RegionUnlock(Region *region);
Region *CurrentRegion(void);
Region *GetRegionOf(Obj obj);
extern Region *LimboRegion, *ReadOnlyRegion;
extern Obj PublicRegionName;

void SetRegionName(Region *region, Obj name);
Obj GetRegionName(Region *region);
Obj GetRegionLockCounters(Region *region);
void ResetRegionLockCounters(Region *region);

void LockThreadControl(int modify);
void UnlockThreadControl(void);

void GCThreadHandler(void);

void InitMainThread(void);

typedef enum LockQual {
    LOCK_QUAL_NONE = 0,
    LOCK_QUAL_READONLY = 1,
    LOCK_QUAL_READWRITE = 2,
} LockQual;

typedef enum LockStatus {
    LOCK_STATUS_UNLOCKED = 0,
    LOCK_STATUS_READWRITE_LOCKED = 1,
    LOCK_STATUS_READONLY_LOCKED = 2,
} LockStatus;

LockStatus IsLocked(Region *region);
void GetLockStatus(int count, Obj *objects, LockStatus *status);


typedef enum LockMode {
    LOCK_MODE_READONLY = 0,
    LOCK_MODE_READWRITE = 1,
    LOCK_MODE_DEFAULT = LOCK_MODE_READWRITE,
} LockMode;

int LockObject(Obj obj, LockMode mode);
int LockObjects(int count, Obj * objects, const LockMode * mode);
int TryLockObjects(int count, Obj * objects, const LockMode * mode);

void PushRegionLock(Region *region);
void PopRegionLocks(int newSP);
int RegionLockSP(void);

void HashLock(void *obj);
void HashLockShared(void *obj);
void HashUnlock(void *obj);
void HashUnlockShared(void *obj);

/* Thread state constants and functions */

#define TSTATE_SHIFT 3
#define TSTATE_MASK ((1 << TSTATE_SHIFT) - 1)
#define TSTATE_RUNNING 0
#define TSTATE_TERMINATED 1
#define TSTATE_BLOCKED 2
#define TSTATE_SYSCALL 3

#define TSTATE_INTERRUPT 4

#define TSTATE_PAUSED 4
#define TSTATE_INTERRUPTED 5
#define TSTATE_KILLED 6


int GetThreadState(int threadID);
int UpdateThreadState(int threadID, int oldState, int newState);
void KillThread(int threadID);
void PauseThread(int threadID);
void InterruptThread(int threadID, int handler);
void ResumeThread(int threadID);
void HandleInterrupts(int locked, Stat stat);
int PauseAllThreads(void);
void ResumeAllThreads(void);
void SetInterruptHandler(int handler, Obj func);

#define MAX_INTERRUPT 100

#endif // HPCGAP

#endif // GAP_THREAD_H
