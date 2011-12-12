#ifndef _THREAD_H
#define _THREAD_H

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

void LockThreadControl(int modify);
void UnlockThreadControl(void);

void InitMainThread();

int IsSingleThreaded();
void BeginSingleThreaded();
void EndSingleThreaded();

int IsLocked(Region *region);
void GetLockStatus(int count, Obj *objects, int *status);
int LockObjects(int count, Obj *objects, int *mode);
int TryLockObjects(int count, Obj *objects, int *mode);
void PushRegionLock(Region *region);
void PopRegionLocks(int newSP);
int RegionLockSP();

typedef void (*TraversalFunction)(Obj);

extern TraversalFunction TraversalFunc[];

Obj ReachableObjectsFrom(Obj obj);
Obj CopyReachableObjectsFrom(Obj obj, int delimited, int asList);
Obj CopyTraversed(Obj traversed);

void HashLock(void *obj);
void HashLockShared(void *obj);
void HashUnlock(void *obj);
void HashUnlockShared(void *obj);

#endif /* _THREAD_H */
