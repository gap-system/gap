#ifndef _THREAD_H
#define _THREAD_H

#include <pthread.h>

#define MAX_THREADS 1024

typedef pthread_t ThreadID;
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
void DataSpaceWriteUnlock(DataSpace *dataspace);
void DataSpaceReadLock(DataSpace *dataspace);
void DataSpaceReadUnlock(DataSpace *dataspace);
void DataSpaceUnlock(DataSpace *dataspace);
DataSpace *CurrentDataSpace();

int IsLocked(DataSpace *dataspace);
void GetLockStatus(int count, Obj *objects, int *status);
int LockObjects(int count, Obj *objects, int *mode, DataSpace **locked);
void UnlockObjects(int count, Obj *objects);
void UnlockDataSpaces(int count, DataSpace **dataspaces);

typedef void (*TraversalFunction)(Obj);

extern TraversalFunction TraversalFunc[];

void Lock(void *obj);
void LockShared(void *obj);
void Unlock(void *obj);
void UnlockShared(void *obj);

#endif /* _THREAD_H */
