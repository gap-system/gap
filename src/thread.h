#ifndef _THREAD_H
#define _THREAD_H

/* Maximum number of threads excluding the main thread */
#define MAX_THREADS 1023

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

void CreateMainDataSpace();
int RunThread(void (*start)(void *), void *arg);
int JoinThread(int id);

void DataSpaceWriteLock(DataSpace *dataspace);
int DataSpaceTryWriteLock(DataSpace *dataspace);
void DataSpaceWriteUnlock(DataSpace *dataspace);
void DataSpaceReadLock(DataSpace *dataspace);
int DataSpaceTryReadLock(DataSpace *dataspace);
void DataSpaceReadUnlock(DataSpace *dataspace);
void DataSpaceUnlock(DataSpace *dataspace);
DataSpace *CurrentDataSpace();
DataSpace *GetDataSpaceOf(Obj obj);
extern DataSpace *LimboDataSpace, *ReadOnlyDataSpace, *ProtectedDataSpace;
extern Obj PublicDataSpace;

int IsSingleThreaded();
void BeginSingleThreaded();
void EndSingleThreaded();

int IsLocked(DataSpace *dataspace);
void GetLockStatus(int count, Obj *objects, int *status);
int LockObjects(int count, Obj *objects, int *mode);
void PushDataSpaceLock(DataSpace *dataspace);
void PopDataSpaceLocks(int newSP);
int DataSpaceLockSP();

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
