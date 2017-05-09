#ifndef GAP_THREAD_H
#define GAP_THREAD_H

#if !defined(HPCGAP)

/*
 * HPC-GAP stubs.
 */

#define HashLock(obj)         do { } while(0)
#define HashLockShared(obj)   do { } while(0)
#define HashUnlock(obj)       do { } while(0)
#define HashUnlockShared(obj) do { } while(0)

#else

/* Maximum number of threads excluding the main thread */
#define MAX_THREADS 1023

#define THREAD_TERMINATED 1
#define THREAD_JOINED 2

extern int PreThreadCreation;

#ifndef HAVE_NATIVE_TLS
void *AllocateTLS();
void FreeTLS(void *address);
#endif


void AddGCRoots();
void RemoveGCroots();

void RunThreadedMain(
	int (*mainFunction)(int, char **, char **),
	int argc,
	char **argv,
	char **environ );

void CreateMainRegion();
Obj RunThread(void (*start)(void *), void *arg);
int JoinThread(int id);
Int ThreadID(Obj thread);
void *ThreadTLS(Obj thread);

void RegionWriteLock(Region *region);
int RegionTryWriteLock(Region *region);
void RegionWriteUnlock(Region *region);
void RegionReadLock(Region *region);
int RegionTryReadLock(Region *region);
void RegionReadUnlock(Region *region);
void RegionUnlock(Region *region);
Region *CurrentRegion();
Region *GetRegionOf(Obj obj);
extern Region *LimboRegion, *ReadOnlyRegion, *ProtectedRegion;
extern Obj PublicRegion;
extern Obj PublicRegionName;

void SetRegionName(Region *region, Obj name);
Obj GetRegionName(Region *region);
Obj GetRegionLockCounters(Region *region);
void ResetRegionLockCounters(Region *region);

void LockThreadControl(int modify);
void UnlockThreadControl(void);

void GCThreadHandler();

void InitMainThread();

int IsSingleThreaded();
void BeginSingleThreaded();
void EndSingleThreaded();

int IsLocked(Region *region);
void GetLockStatus(int count, Obj *objects, int *status);
int LockObject(Obj obj, int mode);
int LockObjects(int count, Obj *objects, int *mode);
int TryLockObjects(int count, Obj *objects, int *mode);
void PushRegionLock(Region *region);
void PopRegionLocks(int newSP);
int RegionLockSP();

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
int PauseAllThreads();
void ResumeAllThreads();
void SetInterruptHandler(int handler, Obj func);

#define MAX_INTERRUPT 100

#endif // HPCGAP

#endif // GAP_THREAD_H

