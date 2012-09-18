#include "EventLogFormat.h"
#include "EventLog.h"
#include "GAPEvent.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


extern char *event_log_filename;
extern FILE *event_log_file;
extern EventsBuf eventBuf;
extern void printAndClearEventBuf (StgWord64 time, EventsBuf *buf);

char *gap_event_log_filename;
FILE *gap_event_log_file;
StgWord64 currentLine=1;
StgThreadID capToWorker[MAX_PES];

typedef struct {
  GAPEventType type;
  StgWord64 time;
  StgThreadID workerId;
} GAPEvent;

void assignCapToWorker (StgWord64 time, StgThreadID workerId) {
  int i;
  for (i=0; i<MAX_PES; i++) 
    if (!capToWorker[i]) {
      capToWorker[i] = workerId;
      break;
    }
  if (i!=eventBuf.capno) {
    eventBuf.capno = i;
    printAndClearEventBuf(time, &eventBuf);
  }
  return;
}

int removeCapFromWorker (StgWord64 time, StgThreadID workerId) {
  int i;
  for (i=0; i<MAX_PES; i++) 
    if (capToWorker[i]==workerId) {
      capToWorker[i] = 0;
      break;
    }
  if (i!=eventBuf.capno) {
    eventBuf.capno = 1;
    printAndClearEventBuf(time, &eventBuf);
  }
  return;
}

int getNextGAPEvent (GAPEvent *ev) {

  StgWord64 time;
  StgThreadID workerId;
  char stringEvent[255];
  int succ;

  succ = fscanf (gap_event_log_file, "%lu %d %s", &time, &workerId, stringEvent);
  //printf ("succ is %d\n", succ);
  if (succ<3) 
    return 0;
  
  ev->time = time;
  ev->workerId = workerId;
  
  if (!strcmp (stringEvent, "WORKER_TASK_STARTED")) {
    ev->type = TASK_STARTED;
  } else if (!strcmp (stringEvent, "WORKER_BLOCKED")) {
    ev->type = TASK_BLOCKED;
  } else if (!strcmp (stringEvent, "WORKER_TASK_FINISHED")) {
    ev->type = TASK_FINISHED;
  }

  return 1;

}


int main (int argc, char **argv) {
  
  char gap_log_name[255], ts_log_name[255];
  GAPEvent nextEvent;
  StgWord64 baseTime=0, time;
  int hasNextEvent, lastCap=-1; 
  
  if (argc<2) {
    fprintf (stderr, "Usage:\n");
    fprintf (stderr, "logToThreadscope <gap_log_file> [<threadscope_log_file>]\n");
    fprintf (stderr, "\t where <gap_log_file> is an input log file from GAP, and <threadscope_log_file> is an output ThreadScope log file ( gap.eventlog by default)\n");
    exit(1);
  }
  gap_event_log_filename = argv[1];
  if (argc>2) {
    event_log_filename = argv[2];
  } else {
    event_log_filename = "gap.eventlog";
  }

  gap_event_log_file = fopen (gap_event_log_filename, "r");
  event_log_file = fopen (event_log_filename, "w");

  eventBuf.capno = -1;
  initEventLogging (0,MAX_PES);
  postEventStartup (0,MAX_PES);

  while (hasNextEvent = getNextGAPEvent(&nextEvent)) {
    if (!baseTime)
      baseTime = nextEvent.time;
    time = nextEvent.time-baseTime+1;
    switch (nextEvent.type) {
    case TASK_STARTED:
      assignCapToWorker (time, nextEvent.workerId);
      postSchedEvent (time, EVENT_RUN_THREAD, nextEvent.workerId, 0, 0, 0);
      break;
    case TASK_BLOCKED:
      removeCapFromWorker (time, nextEvent.workerId);
      postSchedEvent (time, EVENT_STOP_THREAD, nextEvent.workerId, 4, 0, 0);
      break;
    case TASK_FINISHED:
      removeCapFromWorker (time, nextEvent.workerId);
      postSchedEvent (time, EVENT_STOP_THREAD, nextEvent.workerId, 5, 0, 0);
      break;
    default:
      break;
    }
  }

  eventBuf.capno = -1;
  printAndClearEventBuf (time, &eventBuf);
  postSchedEvent (time, 0, 0, 0, 0);
  endEventLogging (time);
  

  //eventBuf.capno = -1;
  //initEventLogging (1,2);
  //postEventStartup (1,2);
  //eventBuf.capno = 0; 
  //printAndClearEventBuf (100000, &eventBuf);
  //postSchedEvent (1,EVENT_CREATE_THREAD,1,0,0,0);
  //postSchedEvent (2,EVENT_RUN_THREAD,1,0,0,0);
  //postSchedEvent (1000000, EVENT_STOP_THREAD,1,5,0,0);
  //eventBuf.capno = 1;
  //printAndClearEventBuf (1000000, &eventBuf);
  //postSchedEvent (1000,EVENT_CREATE_THREAD,1,0,0,0);
  //postSchedEvent (1002,EVENT_RUN_THREAD,1,0,0,0);
  //postSchedEvent (100000, EVENT_STOP_THREAD,1,5,0,0);
  //eventBuf.capno = -1;
  //printAndClearEventBuf (1000000, &eventBuf);
  //postSchedEvent (1000001, EVENT_SHUTDOWN,0,0,0,0);
  //endEventLogging (1000001);
  return 0;
}
