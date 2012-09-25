#ifndef GAPEVENT_H
#define GAPEVENT_H

#define TASK_STARTED 1
#define TASK_BLOCKED 2
#define TASK_FINISHED 3
#define TASK_CREATED 4
#define WORKER_CREATED 5
#define TASK_OBTAINED 6

typedef int GAPEventType;

#define MAX_PES 256
#define MAX_WORKERS 100000

#endif

