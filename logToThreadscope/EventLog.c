#include "EventLogFormat.h"
#include "EventLog.h"
#include <stdlib.h>
#include <stdio.h>

static char *event_log_filename = NULL;

// File for logging events
FILE *event_log_file = NULL;

#define EVENT_LOG_SIZE 2 * (1024 * 1024) // 2MB

static int flushCount;

// Struct for record keeping of buffer to store event types and events.
typedef struct _EventsBuf {
  StgInt8 *begin;
  StgInt8 *pos;
  StgInt8 *marker;
  StgWord64 size;
  EventCapNo capno; // which capability this buffer belongs to, or -1
} EventsBuf;

EventsBuf *capEventBuf; // one EventsBuf for each Capability

EventsBuf eventBuf; // an EventsBuf not associated with any Capability
#ifdef THREADED_RTS
Mutex eventBufMutex; // protected by this mutex
#endif

char *EventDesc[] = {
  [EVENT_CREATE_THREAD]       = "Create thread",
  [EVENT_RUN_THREAD]          = "Run thread",
  [EVENT_STOP_THREAD]         = "Stop thread",
  [EVENT_THREAD_RUNNABLE]     = "Thread runnable",
  [EVENT_MIGRATE_THREAD]      = "Migrate thread",
  [EVENT_RUN_SPARK]           = "Run spark",
  [EVENT_STEAL_SPARK]         = "Steal spark",
  [EVENT_SHUTDOWN]            = "Shutdown",
  [EVENT_THREAD_WAKEUP]       = "Wakeup thread",
  [EVENT_GC_START]            = "Starting GC",
  [EVENT_GC_END]              = "Finished GC",
  [EVENT_REQUEST_SEQ_GC]      = "Request sequential GC",
  [EVENT_REQUEST_PAR_GC]      = "Request parallel GC",
  [EVENT_CREATE_SPARK_THREAD] = "Create spark thread",
  [EVENT_LOG_MSG]             = "Log message",
  [EVENT_USER_MSG]            = "User message",
  [EVENT_STARTUP]             = "Startup",
  [EVENT_GC_IDLE]             = "GC idle",
  [EVENT_GC_WORK]             = "GC working",
  [EVENT_GC_DONE]             = "GC done",
  [EVENT_BLOCK_MARKER]        = "Block marker",
  [EVENT_CAPSET_CREATE]       = "Create capability set",
  [EVENT_CAPSET_DELETE]       = "Delete capability set",
  [EVENT_CAPSET_ASSIGN_CAP]   = "Add capability to capability set",
  [EVENT_CAPSET_REMOVE_CAP]   = "Remove capability from capability set",
  [EVENT_RTS_IDENTIFIER]      = "RTS name and version",
  [EVENT_PROGRAM_ARGS]        = "Program arguments",
  [EVENT_PROGRAM_ENV]         = "Program environment variables",
  [EVENT_OSPROCESS_PID]       = "Process ID",
  [EVENT_OSPROCESS_PPID]      = "Parent process ID",
  [EVENT_CAP_ON_TASK]         = "Capability on task"
};

// Event type. 

typedef struct _EventType {
  EventTypeNum etNum;  // Event Type number.
  unsigned long long   size;     // size of the payload in bytes
  unsigned long long   struct_size;
  char *desc;     // Description
} EventType;

EventType eventTypes[NUM_EVENT_TAGS];

static StgBool initEventType(StgWord8 t);

static void initEventsBuf(EventsBuf* eb, StgWord64 size, EventCapNo capno);
static void resetEventsBuf(EventsBuf* eb);
static void printAndClearEventBuf (EventsBuf *eventsBuf);

static void postEventType(EventsBuf *eb, EventType *et);

static void postLogMsg(EventsBuf *eb, EventTypeNum type, char *msg, va_list ap);

static void postBlockMarker(EventsBuf *eb);
static void closeBlockMarker(EventsBuf *ebuf);

static StgBool hasRoomForEvent(EventsBuf *eb, EventTypeNum eNum);
static StgBool hasRoomForVariableEvent(EventsBuf *eb, unsigned long long payload_bytes);

static void getWithSize(void *p, size_t bytes);

static void getEventType(void);
static void getEvSpecInfo(Event *ev);
static void getEventBlock(EventBlock *eb, int size);

static inline void postWord8(EventsBuf *eb, StgWord8 i)
{
  *(eb->pos++) = i; 
}

static inline int getWord8(StgWord8 *i)
{
	return (fread (i, 1, 1, event_log_file));
}

static inline void postWord16(EventsBuf *eb, StgWord16 i)
{
  postWord8(eb, (StgWord8)(i >> 8));
  postWord8(eb, (StgWord8)i);
}

static inline int getWord16(StgWord16 *i)
{
	int readCnt;
	readCnt = getWord8 ((StgWord8 *)i);
	*i = *i << 8;
	readCnt += getWord8 ((StgWord8 *)i);
	return readCnt;
}

static inline void postWord32(EventsBuf *eb, StgWord32 i)
{
  postWord16(eb, (StgWord16)(i >> 16));
  postWord16(eb, (StgWord16)i);
}

static inline int getWord32(StgWord32 *i)
{
	int readCnt;
	readCnt = getWord16((StgWord16 *)i);
	*i = *i << 16;
	readCnt += getWord16((StgWord16 *)i);
	return readCnt;
}

static inline void postWord64(EventsBuf *eb, StgWord64 i)
{
  postWord32(eb, (StgWord32)(i >> 32));
  postWord32(eb, (StgWord32)i);
}

static inline int getWord64(StgWord64 *i)
{
	int readCnt;
	readCnt = getWord32((StgWord32 *)i);
	*i = *i << 32;
	readCnt += getWord32((StgWord32 *)i);
	return readCnt;
}

static inline void postBuf(EventsBuf *eb, StgWord8 *buf, unsigned long long size)
{
  memcpy(eb->pos, buf, size);
  eb->pos += size;
}

static inline int getBuf (StgWord8 *p,unsigned long long size)
{
	return (fread(p,1,size,event_log_file));
}

static inline void postEventTypeNum(EventsBuf *eb, EventTypeNum etNum)
{ postWord16(eb, etNum); }

static inline void postTimestamp(EventsBuf *eb, StgWord64 time)
{ postWord64(eb, time); }

static inline void postThreadID(EventsBuf *eb, EventThreadID id)
{ postWord32(eb,id); }

static inline void postTaskID(EventsBuf *eb, EventTaskID id)
{ postWord16(eb,id); }

static inline void postCapNo(EventsBuf *eb, EventCapNo no)
{ postWord16(eb,no); }

static inline void postCapsetID(EventsBuf *eb, EventCapsetID id)
{ postWord32(eb,id); }

static inline void postCapsetType(EventsBuf *eb, EventCapsetType type)
{ postWord16(eb,type); }

static inline void postPayloadSize(EventsBuf *eb, EventPayloadSize size)
{ postWord16(eb,size); }

static inline void postEventHeader(EventsBuf *eb, EventTypeNum type, StgWord64 time)
{
  postEventTypeNum(eb, type);
  postTimestamp(eb, time);
}    

static inline void postInt8(EventsBuf *eb, StgInt8 i)
{ postWord8(eb, (StgWord8)i); }

static inline void postInt16(EventsBuf *eb, StgInt16 i)
{ postWord16(eb, (StgWord16)i); }

static inline void postInt32(EventsBuf *eb, StgInt32 i)
{ postWord32(eb, (StgWord32)i); }

static inline void postInt64(EventsBuf *eb, StgInt64 i)
{ postWord64(eb, (StgWord64)i); }

static StgBool
initEventType(StgWord8 t)
{
  eventTypes[t].etNum = t;
  eventTypes[t].desc = EventDesc[t];

  switch (t) {
  case EVENT_CREATE_THREAD:   // (cap, thread)
  case EVENT_RUN_THREAD:      // (cap, thread)
  case EVENT_THREAD_RUNNABLE: // (cap, thread)
  case EVENT_RUN_SPARK:       // (cap, thread)
  case EVENT_CREATE_SPARK_THREAD: // (cap, spark_thread)
    eventTypes[t].size = sizeof(EventThreadID);
		eventTypes[t].struct_size = sizeof(EventThread);
    break;
  case EVENT_MIGRATE_THREAD:  // (cap, thread, new_cap)
  case EVENT_STEAL_SPARK:     // (cap, thread, victim_cap)
  case EVENT_THREAD_WAKEUP:   // (cap, thread, other_cap)
    eventTypes[t].size = sizeof(EventThreadID) + sizeof(EventCapNo);
    eventTypes[t].struct_size = sizeof(EventThreadCap);
    break;
  case EVENT_STOP_THREAD:     // (cap, thread, status)
    eventTypes[t].size =
      sizeof(EventThreadID) + sizeof(StgWord16) + sizeof(EventThreadID) + sizeof(StgWord64);
		eventTypes[t].struct_size = sizeof(EventStopThread);
    break;
  case EVENT_STARTUP:         // (cap count)
    eventTypes[t].size = sizeof(EventCapNo);
    eventTypes[t].struct_size = sizeof(EventStartup);
    break;
  case EVENT_CAPSET_CREATE:   // (capset, capset_type)
    eventTypes[t].size =
      sizeof(EventCapsetID) + sizeof(EventCapsetType);
    break;
  case EVENT_CAPSET_DELETE:   // (capset)
    eventTypes[t].size = sizeof(EventCapsetID);
    break;
  case EVENT_CAPSET_ASSIGN_CAP:  // (capset, cap)
  case EVENT_CAPSET_REMOVE_CAP:
    eventTypes[t].size =
      sizeof(EventCapsetID) + sizeof(EventCapNo);
    break;
  case EVENT_OSPROCESS_PID:   // (cap, pid)
  case EVENT_OSPROCESS_PPID:
    eventTypes[t].size =
      sizeof(EventCapsetID) + sizeof(StgWord32);
    break;
  case EVENT_SHUTDOWN:        // (cap)
  case EVENT_REQUEST_SEQ_GC:  // (cap)
  case EVENT_REQUEST_PAR_GC:  // (cap)
  case EVENT_GC_START:        // (cap)
  case EVENT_GC_END:          // (cap)
  case EVENT_GC_IDLE:
  case EVENT_GC_WORK:
  case EVENT_GC_DONE:
    eventTypes[t].size = 0;
    eventTypes[t].struct_size = sizeof(Event);
    break;
  case EVENT_CAP_ON_TASK: // (cap, task)
    eventTypes[t].size = sizeof(EventTaskID);
    eventTypes[t].struct_size = sizeof(EventTask);
    break;
  case EVENT_LOG_MSG:          // (msg)
  case EVENT_USER_MSG:         // (msg)
  case EVENT_RTS_IDENTIFIER:   // (capset, str)
  case EVENT_PROGRAM_ARGS:     // (capset, strvec)
  case EVENT_PROGRAM_ENV:      // (capset, strvec)
    eventTypes[t].size = 0xffff;
    eventTypes[t].struct_size = 0xffff;
    break;
  case EVENT_BLOCK_MARKER:
    eventTypes[t].size = sizeof(StgWord32) + sizeof(EventTimestamp) +
      sizeof(EventCapNo);
    break;
  default:
    return 0; /* ignore deprecated events */
  }
  return 1;
}

Event *
createEvent(StgWord64 time, EventTypeNum tag, unsigned int cap,
            void *tso, StgWord info1, StgWord info2, StgWord64 info3)
{
  static Event *ev;
  
  if (ev == NULL) {
    ev = (Event *) malloc(eventTypes[tag].struct_size);
  }
  ev->header.tag = tag;
  ev->header.time = time;

  switch (tag) {
  case EVENT_CREATE_THREAD:
  case EVENT_RUN_THREAD:
  case EVENT_THREAD_RUNNABLE:
  case EVENT_RUN_SPARK:
    {
      EventThread *et;
      et = (EventThread *)ev;
      et->thread = 0; // ToDo : Insert the proper thread number
      break;
    }
  case EVENT_CREATE_SPARK_THREAD:
    {
      EventThread *et;
      et = (EventThread *)ev;
      et->thread = info1;
      break;
    }
  case EVENT_MIGRATE_THREAD:
  case EVENT_STEAL_SPARK:
  case EVENT_THREAD_WAKEUP:
    {
      EventThreadCap *etc;
      etc = (EventThreadCap *)ev;
      etc->thread = 0; // ToDo : Insert the proper thread number
      etc->cap = info1;
      break;
    }
  case EVENT_STOP_THREAD:
    {
      EventStopThread *est;
      est = (EventStopThread *)ev;
      est->thread = 0; // ToDo : Insert the proper thread number
      est->status = info1;
      est->blocked_on = info2;
      est->alloc  = info3;
      break;
    }
  case EVENT_CAP_ON_TASK:
    {
      EventTask *et;
      et = (EventTask *)ev;
      et->task = info1;
      break;
    }
  case EVENT_GC_START:
  case EVENT_GC_END:
  case EVENT_GC_IDLE:
  case EVENT_GC_WORK:
  case EVENT_GC_DONE:
    /* Empty events */
    break;
  case EVENT_BLOCK_MARKER:
  case EVENT_SHUTDOWN:
  case EVENT_REQUEST_SEQ_GC:
  case EVENT_REQUEST_PAR_GC:
  case EVENT_STARTUP:
  case EVENT_CAPSET_CREATE:
  case EVENT_CAPSET_DELETE:
  case EVENT_CAPSET_ASSIGN_CAP:
  case EVENT_CAPSET_REMOVE_CAP:
  case EVENT_OSPROCESS_PID:
  case EVENT_OSPROCESS_PPID:
    /* Ignored events */
    break;
  default:
    barf ("Unknown event with tag %d\n", tag);
  }
  
  return ev;
}

void
initEventLogging(unsigned int n_caps)
{
  StgWord8 t, c;

  if (sizeof(EventDesc) / sizeof(char*) != NUM_EVENT_TAGS) {
    fprintf(stderr, "EventDesc array has the wrong number of elements\n");
    exit(1);
  }

  initEventsBuf(&eventBuf, EVENT_LOG_SIZE, (EventCapNo)(-1));

  // Write in buffer: the header begin marker.
  postInt32(&eventBuf, EVENT_HEADER_BEGIN);

  // Mark beginning of event types in the header.
  postInt32(&eventBuf, EVENT_HET_BEGIN);
  for (t = 0; t < NUM_EVENT_TAGS; ++t) {
    if (initEventType(t) == 0)
      continue;;
    // Write in buffer: the start event type.
    postEventType(&eventBuf, &eventTypes[t]);
  }

  // Mark end of event types in the header.
  postInt32(&eventBuf, EVENT_HET_END);
    
  // Write in buffer: the header end marker.
  postInt32(&eventBuf, EVENT_HEADER_END);
    
  // Prepare event buffer for events (data).
  postInt32(&eventBuf, EVENT_DATA_BEGIN);

  // Flush capEventBuf with header.
  /*
   * Flush header and data begin marker to the file, thus preparing the
   * file to have events written to it.
   */
  printAndClearEventBuf(&eventBuf);
}

void
endEventLogging(void)
{
  StgWord64 c;
  // Flush all events remaining in the buffers.
  printAndClearEventBuf(&eventBuf);
  resetEventsBuf(&eventBuf); // we don't want the block marker

  // Mark end of events (data).
  postEventTypeNum(&eventBuf, EVENT_DATA_END);

  // Flush the end of data marker.
  printAndClearEventBuf(&eventBuf);
  
  if (event_log_file != NULL) {
    fclose(event_log_file);
  }
}

void 
freeEventLogging(void)
{
  StgWord8 c;
  
  // Free events buffer.
  //if (eventBuf != NULL)  {
    free(capEventBuf);
    //}
  if (event_log_filename != NULL) {
    free(event_log_filename);
  }
}

void 
flushEventLog(void)
{
  if (event_log_file != NULL) {
    fflush(event_log_file);
  }
}

void 
abortEventLogging(void)
{
  freeEventLogging();
  if (event_log_file != NULL) {
    fclose(event_log_file);
  }
}

/*
 * Post an event message to the capability's eventlog buffer.
 * If the buffer is full, prints out the buffer and clears it.
 */
void
postSchedEvent (StgWord64 time,
                EventTypeNum tag, 
                StgThreadID thread, 
                StgWord info1,
                StgWord info2,
                StgWord64 info3)
{
  EventsBuf *eb;
  
  eb = &eventBuf;
  
  if (!hasRoomForEvent(eb, tag)) {
    // Flush event buffer to make room for new event.
    printAndClearEventBuf(eb);
  }
    
  postEventHeader(eb, tag, time);

  switch (tag) {
  case EVENT_CREATE_THREAD:   // (cap, thread)
  case EVENT_RUN_THREAD:      // (cap, thread)
  case EVENT_THREAD_RUNNABLE: // (cap, thread)
  case EVENT_RUN_SPARK:       // (cap, thread)
    {
      postThreadID(eb,thread);
      break;
    }
    
  case EVENT_CREATE_SPARK_THREAD: // (cap, spark_thread)
    {
      postThreadID(eb,info1 /* spark_thread */);
      break;
    }

  case EVENT_MIGRATE_THREAD:  // (cap, thread, new_cap)
  case EVENT_STEAL_SPARK:     // (cap, thread, victim_cap)
  case EVENT_THREAD_WAKEUP:   // (cap, thread, other_cap)
    {
      postThreadID(eb,thread);
      postCapNo(eb,info1 /* new_cap | victim_cap | other_cap */);
      break;
    }
    
  case EVENT_STOP_THREAD:     // (cap, thread, status)
    {
      postThreadID(eb,thread);
      postWord16(eb,info1 /* status */);
      postThreadID(eb,info2 /* blocked on thread */);
      postWord64(eb,info3 /* alloc */);
      break;
    }

  case EVENT_SHUTDOWN:        // (cap)
  case EVENT_REQUEST_SEQ_GC:  // (cap)
  case EVENT_REQUEST_PAR_GC:  // (cap)
  case EVENT_GC_START:        // (cap)
  case EVENT_GC_END:          // (cap)
    {
      break;
    }
    
  case EVENT_CAP_ON_TASK: // (cap, task)
    {
      postTaskID(eb,info1);
      break;
    }
    
  default:
    fprintf(stderr, "postEvent: unknown event tag %d\n", tag);
    exit(1);
  }
}

void postCapsetModifyEvent (StgWord64 time,
                            EventTypeNum tag,
                            EventCapsetID capset,
                            StgWord32 other)
{

  if (!hasRoomForEvent(&eventBuf, tag)) {
    // Flush event buffer to make room for new event.
    printAndClearEventBuf(&eventBuf);
  }
  
  postEventHeader(&eventBuf, tag, time);
  postCapsetID(&eventBuf, capset);
  
  switch (tag) {
  case EVENT_CAPSET_CREATE:   // (capset, capset_type)
    {
      postCapsetType(&eventBuf, other /* capset_type */);
      break;
    }

  case EVENT_CAPSET_DELETE:   // (capset)
    {
      break;
    }

  case EVENT_CAPSET_ASSIGN_CAP:  // (capset, capno)
  case EVENT_CAPSET_REMOVE_CAP:  // (capset, capno)
    {
      postCapNo(&eventBuf, other /* capno */);
      break;
    }
  case EVENT_OSPROCESS_PID:   // (capset, pid)
  case EVENT_OSPROCESS_PPID:  // (capset, parent_pid)
    {
      postWord32(&eventBuf, other);
      break;
    }
  default:
    fprintf(stderr, "postCapsetModifyEvent: unknown event tag %d\n", tag);
    exit(1);
  }

}

void postCapsetStrEvent (StgWord64 time,
                         EventTypeNum tag,
                         EventCapsetID capset,
                         char *msg)
{
  int strsize = strlen(msg);
  int size = strsize + sizeof(EventCapsetID);
  
  if (!hasRoomForVariableEvent(&eventBuf, size)){
    printAndClearEventBuf(&eventBuf);
    
    if (!hasRoomForVariableEvent(&eventBuf, size)){
      // Event size exceeds buffer size, bail out:
      return;
    }
  }

  postEventHeader(&eventBuf, tag, time);
  postPayloadSize(&eventBuf, size);
  postCapsetID(&eventBuf, capset);

  postBuf(&eventBuf, (StgWord8*) msg, strsize);

}

void postCapsetVecEvent (EventTypeNum tag,
                         EventCapsetID capset,
                         int argc,
                         char *argv[])
{
  int i, size = sizeof(EventCapsetID);
  
  for (i = 0; i < argc; i++) {
    // 1 + strlen to account for the trailing \0, used as separator
    size += 1 + strlen(argv[i]);
  }

  if (!hasRoomForVariableEvent(&eventBuf, size)){
    printAndClearEventBuf(&eventBuf);
    
    if(!hasRoomForVariableEvent(&eventBuf, size)){
      // Event size exceeds buffer size, bail out:
      return;
    }
  }

  postEventHeader(&eventBuf, tag);
  postPayloadSize(&eventBuf, size);
  postCapsetID(&eventBuf, capset);
  
  for( i = 0; i < argc; i++ ) {
    // again, 1 + to account for \0
    postBuf(&eventBuf, (StgWord8*) argv[i], 1 + strlen(argv[i]));
  }

}

void
postEvent (Capability *cap, EventTypeNum tag)
{
  EventsBuf *eb;
  
  eb = &eventBuf;

  if (!hasRoomForEvent(eb, tag)) {
    // Flush event buffer to make room for new event.
    printAndClearEventBuf(eb);
  }

  postEventHeader(eb, tag);
}

#define BUF 512

void postLogMsg(EventsBuf *eb, EventTypeNum type, char *msg, va_list ap)
{
  char buf[BUF];
  nat size;
  
  size = vsnprintf(buf,BUF,msg,ap);
  if (size > BUF) {
    buf[BUF-1] = '\0';
    size = BUF;
  }
  
  if (!hasRoomForVariableEvent(eb, size)) {
    // Flush event buffer to make room for new event.
    printAndClearEventBuf(eb);
  }
  
  postEventHeader(eb, type);
  postPayloadSize(eb, size);
  postBuf(eb,(StgWord8*)buf,size);
}

void postMsg(char *msg, va_list ap)
{
  postLogMsg(&eventBuf, EVENT_LOG_MSG, msg, ap);
}

void postCapMsg(Capability *cap, char *msg, va_list ap)
{
  postLogMsg(&capEventBuf[cap->no], EVENT_LOG_MSG, msg, ap);
}

void postUserMsg(Capability *cap, char *msg, va_list ap)
{
  postLogMsg(&capEventBuf[cap->no], EVENT_USER_MSG, msg, ap);
}    

void postEventStartup(EventCapNo n_caps)
{
  if (!hasRoomForEvent(&eventBuf, EVENT_STARTUP)) {
    // Flush event buffer to make room for new event.
    printAndClearEventBuf(&eventBuf);
  }
  
  // Post a STARTUP event with the number of capabilities
  postEventHeader(&eventBuf, EVENT_STARTUP);
  postCapNo(&eventBuf, n_caps);
}

void closeBlockMarker (EventsBuf *ebuf, unsigned long long time)
{
  StgInt8* save_pos;
  if (ebuf->marker) {
    // (type:16, time:64, size:32, end_time:64)
    save_pos = ebuf->pos;
    ebuf->pos = ebuf->marker + sizeof(EventTypeNum) +
      sizeof(EventTimestamp);
    postWord32(ebuf, save_pos - ebuf->marker);
    postTimestamp(ebuf, time);
    ebuf->pos = save_pos;
    ebuf->marker = NULL;
  }
}


void postBlockMarker (EventsBuf *eb)
{
  if (!hasRoomForEvent(eb, EVENT_BLOCK_MARKER)) {
    printAndClearEventBuf(eb);
  }
  closeBlockMarker(eb);
  eb->marker = eb->pos;
  postEventHeader(eb, EVENT_BLOCK_MARKER);
  postWord32(eb,0); // these get filled in later by closeBlockMarker();
  postWord64(eb,0);
  postCapNo(eb, eb->capno);
}

void printAndClearEventBuf (EventsBuf *ebuf)
{
  StgWord64 numBytes = 0, written = 0;
  closeBlockMarker(ebuf);
  if (ebuf->begin != NULL && ebuf->pos != ebuf->begin) {
    numBytes = ebuf->pos - ebuf->begin;
    written = fwrite(ebuf->begin, 1, numBytes, event_log_file);
    if (written != numBytes) {
      fprintf (stderr, "fwrite() failed, written=%d doesn't match numBytes=%d\n",
               written, numBytes);
      return;
    }
    resetEventsBuf(ebuf);
    flushCount++;
    postBlockMarker(ebuf);
  }
}

void initEventsBuf(EventsBuf* eb, StgWord64 size, EventCapNo capno)
{
  eb->begin = eb->pos = stgMallocBytes(size, "initEventsBuf");
  eb->size = size;
  eb->marker = NULL;
  eb->capno = capno;
}

void resetEventsBuf(EventsBuf* eb)
{
  eb->pos = eb->begin;
  eb->marker = NULL;
}

StgBool hasRoomForEvent(EventsBuf *eb, EventTypeNum eNum)
{
  nat size;

  size = sizeof(EventTypeNum) + sizeof(EventTimestamp) + eventTypes[eNum].size;

  if (eb->pos + size > eb->begin + eb->size) {
      return 0; // Not enough space.
  } else  {
      return 1; // Buf has enough space for the event.
  }
}

StgBool hasRoomForVariableEvent(EventsBuf *eb, unsigned long long payload_bytes)
{
  nat size;

  size = sizeof(EventTypeNum) + sizeof(EventTimestamp) +
    sizeof(EventPayloadSize) + payload_bytes;
  
  if (eb->pos + size > eb->begin + eb->size) {
    return 0; // Not enough space.
  } else  {
    return 1; // Buf has enough space for the event.
  }
}    

void postEventType(EventsBuf *eb, EventType *et)
{
  StgWord8 d;
  nat desclen;
  
  postInt32(eb, EVENT_ET_BEGIN);
  postEventTypeNum(eb, et->etNum);
  postWord16(eb, (StgWord16)et->size);
  desclen = strlen(et->desc);
  postWord32(eb, desclen);
  for (d = 0; d < desclen; ++d) {
    postInt8(eb, (StgInt8)et->desc[d]);
  }
  postWord32(eb, 0); // no extensions yet
  postInt32(eb, EVENT_ET_END);
}

int main (int *argc, char **argv) {
  return 0;
}
