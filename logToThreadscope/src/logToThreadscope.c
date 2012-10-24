#include "EventLogFormat.h"
#include "EventLog.h"
#include "GAPEvent.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern char *event_log_filename;
extern FILE *event_log_file;
extern EventsBuf eventBuf;
extern void printAndClearEventBuf (StgWord64 time, EventsBuf *buf);

struct {
  int WorkerView;
  int CoreView;
} Flags;

char *gap_event_log_filename;
FILE *gap_event_log_file;
StgWord64 currentLine=1;
StgThreadID capToWorker[MAX_PES];
int workerToCap[MAX_WORKERS];
StgThreadID nextTaskId=1;
StgThreadID workerToTask[MAX_WORKERS];
int nextCap=1;

typedef struct {
  GAPEventType type;
  StgWord64 time;
  StgThreadID workerId;
} GAPEvent;

struct {
  int pos;
  StgWord64 task[100000];
} TaskQueue;

static inline StgWord64 popFromRunQueue() {
  TaskQueue.pos--;
  if (TaskQueue.pos<0) {
    fprintf (stderr, "ERROR processing gap log! Stealing task from an empty queue\n");
    exit(1);
  } else {
    return TaskQueue.task[TaskQueue.pos];
  }
}

static inline void pushToRunQueue(StgWord64 taskId) {
  TaskQueue.task[TaskQueue.pos++] = taskId;
}


static inline int initialiseCaps () {
  int i;
  for (i=0;i<MAX_PES;i++) {
    capToWorker[i] = -1;
  }
  TaskQueue.pos = 0;
  capToWorker[0] = 0;
  workerToCap[0] = 0;
  workerToTask[0] = 0;
}

static inline int getWorkerCap (StgThreadID workerId) {
  return workerToCap[workerId];
}

void processArgs (int argc, char **argv) {
  
  const char *options = "i:o:t:h?";
  int opt;

  gap_event_log_filename = "gap.gaplog";
  event_log_filename = "gap.eventlog";
  Flags.CoreView = 1;

  do {
    opt = getopt (argc, argv, options);
    switch (opt) {
    case 'h':
    case '?':
      printf ("Usage:\n");
      printf  ("logToThreadscope [-i <gap_log_file> -o <threadscope_log_file> -t <view_type>]\n");
      printf ("\t Options are the following:\n");
      printf ("\t\t -i accepts the input GAP log file <gap_log_file> (defaults to gap.gaplog)\n");
      printf ("\t\t -o accepts the name of the output ThreadScope eventlog file that will be generated (defaults to gap.eventlog)\n");
      printf ("\t\t -t accepts the type of view that is generated. Possible options are (default is 'c'):\n");
      printf ("\t\t\t w -- worker view, with one logical core (HEC) in the ThreadScope profile per worker thread\n");
      printf ("\t\t\t c -- core view, where HECs are actual cores of the machine (approximated)\n");
      exit(1);
      break;
    case 'i':
      gap_event_log_filename = optarg;
      break;
    case 'o':
      event_log_filename = optarg;
      break;
    case 't':
      if (!strcmp(optarg, "w")) { 
	Flags.WorkerView = 1;
	Flags.CoreView = 0;
      } else if (!strcmp (optarg, "c")) {
	Flags.WorkerView = 0;
	Flags.CoreView = 1;
      } else {
	printf ("Error processing -w command line option (Unknown view type)\n");
	exit(1);
      }
      break;
    default:
      break;
    } 
  } while (opt != -1);

}

void flushEventBuffer (StgWord64 time, int cap) {
  if (cap != eventBuf.capno) {
    eventBuf.capno = cap;
    printAndClearEventBuf(time, &eventBuf);
  }
  return;
}

int assignCapToWorker (StgWord64 time, StgThreadID workerId) {
  int i, lastCap;

  if (Flags.WorkerView) {
    if (workerToCap[workerId] == -1) {
      capToWorker[nextCap] = workerId;
      workerToCap[workerId] = nextCap;
      nextCap++;
    }
    return workerToCap[workerId];
  } else {
    for (i=0; i<MAX_PES; i++) 
      if (capToWorker[i]==-1) {
	capToWorker[i] = workerId;
	workerToCap[workerId] = i;
	return i;
      }

  }
  
  return -1;

}

int removeCapFromWorker (StgWord64 time, StgThreadID workerId) {
  int i;
  if (Flags.CoreView) {
    for (i=0; i<MAX_PES; i++) 
      if (capToWorker[i]==workerId) {
	capToWorker[i] = -1;
	workerToCap[workerId] = -1;
	return i;
      }
  } else if (Flags.WorkerView) {
    capToWorker[workerToCap[workerId]] = -1;
    workerToCap[workerId] = -1;
    return 1;
  }

  return -1;
    
}

int getNextGAPEvent (GAPEvent *ev) {

  StgWord64 time;
  StgThreadID workerId;
  char stringEvent[255];
  int succ;

#if SIZEOF_LONG == 8 
  succ = fscanf (gap_event_log_file, "%lu %u %s", &time, &workerId, stringEvent);
#elif SIZEOF_LONG_LONG == 8
  succ = fscanf (gap_event_log_file, "%llu %lu %s", &time, &workerId, stringEvent);
#endif

  if (succ<3) {
    return 0;
  }

  ev->time = time;
  ev->workerId = workerId;
  
  if (!strcmp (stringEvent, "WORKER_TASK_STARTED")) {
    ev->type = TASK_STARTED;
  } else if (!strcmp (stringEvent, "WORKER_BLOCKED")) {
    ev->type = TASK_BLOCKED;
  } else if (!strcmp (stringEvent, "WORKER_RESUMED")) {
    ev->type = TASK_RESUMED;
  } else if (!strcmp (stringEvent, "WORKER_TASK_FINISHED")) {
    ev->type = TASK_FINISHED;
  } else if (!strcmp (stringEvent, "WORKER_GOT_TASK")) {
    ev->type = TASK_OBTAINED;
  } else if (!strcmp (stringEvent, "WORKER_TASK_CREATED")) {
    ev->type = TASK_CREATED;
  } else if (!strcmp (stringEvent, "WORKER_CREATED")) {
    ev->type = WORKER_CREATED;
  }

  return 1;

}


int main (int argc, char **argv) {
  
  char gap_log_name[255], ts_log_name[255];
  GAPEvent nextEvent;
  StgWord64 time, taskId;
  int hasNextEvent, cap=-1, x;

  processArgs(argc, argv);

  gap_event_log_file = fopen (gap_event_log_filename, "r");
  event_log_file = fopen (event_log_filename, "w");

  eventBuf.capno = -1;
  initEventLogging (0,MAX_PES);
  postEventStartup (0,MAX_PES);

  initialiseCaps();

  while (hasNextEvent = getNextGAPEvent(&nextEvent)) {
    time = nextEvent.time*1000;
    switch (nextEvent.type) {
    case WORKER_CREATED:
      if (nextEvent.workerId != 0) {
	workerToCap[nextEvent.workerId] = -1;
      }
      break;
    case TASK_OBTAINED:
      cap = getWorkerCap (nextEvent.workerId);
      if (cap == -1) {
        cap = assignCapToWorker (time, nextEvent.workerId);
      }
      flushEventBuffer(time, cap);
      taskId = popFromRunQueue ();
      workerToTask[nextEvent.workerId] = taskId;
      postSchedEvent (time, EVENT_MIGRATE_THREAD, taskId, cap, 0, 0);
      break;
    case TASK_CREATED:
      cap = getWorkerCap (nextEvent.workerId);
      if (cap == -1) {
        cap = assignCapToWorker (time, nextEvent.workerId);
      }
      flushEventBuffer(time, cap);
      pushToRunQueue (nextTaskId);
      postSchedEvent (time, EVENT_CREATE_THREAD, nextTaskId++, 0, 0, 0);
      break;
    case TASK_STARTED:
      cap = getWorkerCap (nextEvent.workerId);
      if (cap == -1) {
	fprintf (stderr, "ERROR! No capability assigned to active worker %u (time %lu)\n", nextEvent.workerId, time);
	exit(1);
      }
      flushEventBuffer(time, cap);
      postSchedEvent (time, EVENT_RUN_THREAD, workerToTask[nextEvent.workerId], 0, 0, 0);
      break;
    case TASK_RESUMED:
      cap = getWorkerCap (nextEvent.workerId);
      if (cap == -1) {
	cap = assignCapToWorker (time, nextEvent.workerId);
      }
      flushEventBuffer (time, cap);
      postSchedEvent (time, EVENT_RUN_THREAD, workerToTask[nextEvent.workerId], 0, 0, 0);
      break;
    case TASK_BLOCKED:
      cap = getWorkerCap (nextEvent.workerId);
      if (cap == -1) {
#if SIZEOF_LONG == 8
        fprintf (stderr, "ERROR! No capability assigned to active worker %u (time %lu)\n", nextEvent.workerId, time);
#elif SIZEOF_LONG_LONG == 8
        fprintf (stderr, "ERROR! No capability assigned to active worker %lu (time %llu)\n", nextEvent.workerId, time);
#endif
        exit(1);
      }
      flushEventBuffer(time, cap);
      postSchedEvent (time, EVENT_STOP_THREAD, workerToTask[nextEvent.workerId], 4, 0, 0);
      if (Flags.CoreView)
	removeCapFromWorker (time, nextEvent.workerId);
      break;
    case TASK_FINISHED:
      cap = getWorkerCap (nextEvent.workerId);
      if (cap == -1) {
#if SIZEOF_LONG == 8
        fprintf (stderr, "ERROR! No capability assigned to active worker %u (time %lu)\n", nextEvent.workerId, time);
#elif SIZEOF_LONG_LONG == 8
        fprintf (stderr, "ERROR! No capability assigned to active worker %lu (time %llu)\n", nextEvent.workerId, time);
#endif
        exit(1);
      }
      flushEventBuffer(time, cap);
      postSchedEvent (time, EVENT_STOP_THREAD, workerToTask[nextEvent.workerId] , 5, 0, 0);
      if (Flags.CoreView) 
	removeCapFromWorker (time, nextEvent.workerId);
      break;
    default:
      break;
    }
    nextEvent.type = -1;
  }

  eventBuf.capno = -1;
  printAndClearEventBuf (time, &eventBuf);
  postSchedEvent (time+1, EVENT_SHUTDOWN, 0, 0, 0, 0);
  endEventLogging (time+1);
  
  return 0;
}
