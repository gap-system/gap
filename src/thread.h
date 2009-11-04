#ifndef _THREAD_H
#define _THREAD_H

#include <pthread.h>

#define MAX_THREADS 1024

typedef pthread_t ThreadID;

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

int RunThread(void (*start)());
void JoinThread(int id);

#endif /* _THREAD_H */
