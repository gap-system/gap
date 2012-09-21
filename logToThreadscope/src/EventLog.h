/* -----------------------------------------------------------------------------
 *
 * (c) The GHC Team, 2008-2009
 *
 * Support for fast binary event logging.
 *
 * ---------------------------------------------------------------------------*/

#ifndef EVENTLOG_H
#define EVENTLOG_H

/*
 * Descriptions of EventTags for events.
 */
extern char *EventDesc[];

void initEventLogging(StgWord64 time,unsigned int n_caps);
void endEventLogging(StgWord64 time);
void freeEventLogging(void);
void abortEventLogging(void); // #4512 - after fork child needs to abort
void flushEventLog(void);     // event log inherited from parent

void   initEventLoggingRead(void);
void   endEventLoggingRead(void);
void   freeEventLoggingRead(void);
void   abortEventLoggingRead(void);
void   getEvent(Event *);

Event *createEvent(StgWord64 time, EventTypeNum tag, unsigned int cap,
                   void *tso, StgWord info1, StgWord info2, StgWord64 info3);

/* 
 * Post a scheduler event to the capability's event buffer (an event
 * that has an associated thread).
 */
void postSchedEvent(StgWord64 time,EventTypeNum tag, 
                    StgThreadID id, StgWord info1, StgWord info2, StgWord64 info3);

/*
 * Post a nullary event.
 */
void postEvent(StgWord64 time, EventTypeNum tag);

void postEventStartup(StgWord64 time, EventCapNo n_caps);

/*
 * Post a capability set modification event
 */
void postCapsetModifyEvent (StgWord64 time,
			    EventTypeNum tag,
                            EventCapsetID capset,
                            StgWord32 other);

/*
 * Post a capability set event with a string payload
 */
void postCapsetStrEvent (StgWord64 time,
			 EventTypeNum tag,
                         EventCapsetID capset,
                         char *msg);

/*
 * Post a capability set event with several strings payload
 */
void postCapsetVecEvent (StgWord64 time,
			 EventTypeNum tag,
                         EventCapsetID capset,
                         int argc,
                         char *msg[]);


typedef struct _EventsBuf {
  StgInt8 *begin;
  StgInt8 *pos;
  StgInt8 *marker;
  StgWord64 size;
  EventCapNo capno; // which capability this buffer belongs to, or -1
} EventsBuf;

#endif
