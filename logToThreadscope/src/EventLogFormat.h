/* -----------------------------------------------------------------------------
 *
 * (c) The GHC Team, 2008-2011
 *
 * Event log format
 * 
 * The log format is designed to be extensible: old tools should be
 * able to parse (but not necessarily understand all of) new versions
 * of the format, and new tools will be able to understand old log
 * files.
 * 
 * Each event has a specific format.  If you add new events, give them
 * new numbers: we never re-use old event numbers.
 *
 * - The format is endian-independent: all values are represented in 
 *    bigendian order.
 *
 * - The format is extensible:
 *
 *    - The header describes each event type and its length.  Tools
 *      that don't recognise a particular event type can skip those events.
 *
 *    - There is room for extra information in the event type
 *      specification, which can be ignored by older tools.
 *
 *    - Events can have extra information added, but existing fields
 *      cannot be changed.  Tools should ignore extra fields at the
 *      end of the event record.
 *
 *    - Old event type ids are never re-used; just take a new identifier.
 *
 *
 * The format
 * ----------
 *
 * log : EVENT_HEADER_BEGIN
 *       EventType*
 *       EVENT_HEADER_END
 *       EVENT_DATA_BEGIN
 *       Event*
 *       EVENT_DATA_END
 *
 * EventType :
 *       EVENT_ET_BEGIN
 *       Word16         -- unique identifier for this event
 *       Int16          -- >=0  size of the event in bytes (minus the header)
 *                      -- -1   variable size
 *       Word32         -- length of the next field in bytes
 *       Word8*         -- string describing the event
 *       Word32         -- length of the next field in bytes
 *       Word8*         -- extra info (for future extensions)
 *       EVENT_ET_END
 *
 * Event : 
 *       Word16         -- event_type
 *       Word64         -- time (nanosecs)
 *       [Word16]       -- length of the rest (for variable-sized events only)
 *       ... extra event-specific info ...
 *
 *
 * To add a new event
 * ------------------
 *
 *  - In this file:
 *    - give it a new number, add a new #define EVENT_XXX below
 *  - In EventLog.c
 *    - add it to the EventDesc array
 *    - emit the event type in initEventLogging()
 *    - emit the new event in postEvent_()
 *    - generate the event itself by calling postEvent() somewhere
 *  - In the Haskell code to parse the event log file:
 *    - add types and code to read the new event
 *
 * -------------------------------------------------------------------------- */

#ifndef RTS_EVENTLOGFORMAT_H
#define RTS_EVENTLOGFORMAT_H

#include <config.h>

/*
 * We need to hardcode the size of EventHeader structure, because
 * we cannot rely on use of sizeof on struct, as it takes into account alignment of
 * members. So, sizeof(EventHeader) returns 16, whereas the size it
 * takes in binary file is 10
 */
#define EVENT_HEADER_SIZE 10

#define MAX_EVENT_SIZE (sizeof(EventBlock) * 2)

/*
 * Markers for begin/end of the Header.
 */
#define EVENT_HEADER_BEGIN    0x68647262 /* 'h' 'd' 'r' 'b' */
#define EVENT_HEADER_END      0x68647265 /* 'h' 'd' 'r' 'e' */

#define EVENT_DATA_BEGIN      0x64617462 /* 'd' 'a' 't' 'b' */
#define EVENT_DATA_END        0xffff

/*
 * Markers for begin/end of the list of Event Types in the Header.
 * Header, Event Type, Begin = hetb
 * Header, Event Type, End = hete
 */
#define EVENT_HET_BEGIN       0x68657462 /* 'h' 'e' 't' 'b' */
#define EVENT_HET_END         0x68657465 /* 'h' 'e' 't' 'e' */

#define EVENT_ET_BEGIN        0x65746200 /* 'e' 't' 'b' 0 */
#define EVENT_ET_END          0x65746500 /* 'e' 't' 'e' 0 */

/*
 * Types of event
 */
#define EVENT_CREATE_THREAD        0 /* (thread)               */
#define EVENT_RUN_THREAD           1 /* (thread)               */
#define EVENT_STOP_THREAD          2 /* (thread, status, blockinfo) */
#define EVENT_THREAD_RUNNABLE      3 /* (thread)               */
#define EVENT_MIGRATE_THREAD       4 /* (thread, new_cap)      */
#define EVENT_RUN_SPARK            5 /* (thread)               */
#define EVENT_STEAL_SPARK          6 /* (thread, victim_cap)   */
#define EVENT_SHUTDOWN             7 /* ()                     */
#define EVENT_THREAD_WAKEUP        8 /* (thread, other_cap)    */
#define EVENT_GC_START             9 /* ()                     */
#define EVENT_GC_END              10 /* ()                     */
#define EVENT_REQUEST_SEQ_GC      11 /* ()                     */
#define EVENT_REQUEST_PAR_GC      12 /* ()                     */
/* 13, 14 deprecated */
#define EVENT_CREATE_SPARK_THREAD 15 /* (spark_thread)         */
#define EVENT_LOG_MSG             16 /* (message ...)          */
#define EVENT_STARTUP             17 /* (num_capabilities)     */
#define EVENT_BLOCK_MARKER        18 /* (size, end_time, capability) */
#define EVENT_USER_MSG            19 /* (message ...)          */
#define EVENT_GC_IDLE             20 /* () */
#define EVENT_GC_WORK             21 /* () */
#define EVENT_GC_DONE             22 /* () */
/* 23, 24 used by eden */
#define EVENT_CAPSET_CREATE       25 /* (capset, capset_type)  */
#define EVENT_CAPSET_DELETE       26 /* (capset)               */
#define EVENT_CAPSET_ASSIGN_CAP   27 /* (capset, cap)          */
#define EVENT_CAPSET_REMOVE_CAP   28 /* (capset, cap)          */
/* the RTS identifier is in the form of "GHC-version rts_way"  */
#define EVENT_RTS_IDENTIFIER      29 /* (capset, name_version_string) */
/* the vectors in these events are null separated strings             */
#define EVENT_PROGRAM_ARGS        30 /* (capset, commandline_vector)  */
#define EVENT_PROGRAM_ENV         31 /* (capset, environment_vector)  */
#define EVENT_OSPROCESS_PID       32 /* (capset, pid)          */
#define EVENT_OSPROCESS_PPID      33 /* (capset, parent_pid)   */

#define EVENT_CAP_ON_TASK         34 /* (task) */


/* Range 34 - 59 is available for new events */

/* Range 60 - 80 is used by eden for parallel tracing
 * see http://www.mathematik.uni-marburg.de/~eden/
 */

/*
 * The highest event code +1 that ghc itself emits. Note that some event
 * ranges higher than this are reserved but not currently emitted by ghc.
 * This must match the size of the EventDesc[] array in EventLog.c
 */
#define NUM_EVENT_TAGS            35

#if 0  /* DEPRECATED EVENTS: */
/* ghc changed how it handles sparks so these are no longer applicable */
#define EVENT_CREATE_SPARK        13 /* (cap, thread) */
#define EVENT_SPARK_TO_THREAD     14 /* (cap, thread, spark_thread) */
/* these are used by eden but are replaced by new alternatives for ghc */
#define EVENT_VERSION             23 /* (version_string) */
#define EVENT_PROGRAM_INVOCATION  24 /* (commandline_string) */
#endif

/*
 * Status values for EVENT_STOP_THREAD
 *
 * 1-5 are the StgRun return values (from includes/Constants.h):
 *
 * #define HeapOverflow   1
 * #define StackOverflow  2
 * #define ThreadYielding 3
 * #define ThreadBlocked  4
 * #define ThreadFinished 5
 * #define ForeignCall                  6
 * #define BlockedOnMVar                7
 * #define BlockedOnBlackHole           8
 * #define BlockedOnRead                9
 * #define BlockedOnWrite               10
 * #define BlockedOnDelay               11
 * #define BlockedOnSTM                 12
 * #define BlockedOnDoProc              13
 * #define BlockedOnCCall               -- not used (see ForeignCall)
 * #define BlockedOnCCall_NoUnblockExc  -- not used (see ForeignCall)
 * #define BlockedOnMsgThrowTo          16
 */
#define THREAD_SUSPENDED_FOREIGN_CALL 6

/*
 * Capset type values for EVENT_CAPSET_CREATE
 */
#define CAPSET_TYPE_CUSTOM      1  /* reserved for end-user applications */
#define CAPSET_TYPE_OSPROCESS   2  /* caps belong to the same OS process */
#define CAPSET_TYPE_CLOCKDOMAIN 3  /* caps share a local clock/time      */

typedef signed   char            StgInt8;
typedef unsigned char            StgWord8;

typedef signed   short           StgInt16;
typedef unsigned short           StgWord16;

#if SIZEOF_VOIDP == 4
typedef signed   long            StgInt32;
typedef unsigned long            StgWord32;
#elif SIZEOF_VOIDP == 8
typedef signed   int             StgInt32;
typedef unsigned int             StgWord32;
#else
#error logToThreadscopes untested on this architecture: sizeof(int) != 4
#endif

#if SIZEOF_LONG == 8
typedef signed   long          StgInt64;
typedef unsigned long          StgWord64;
#elif defined(__MSVC__)
typedef __int64                StgInt64;
typedef unsigned __int64       StgWord64;
#elif SIZEOF_LONG_LONG == 8
typedef signed long long int   StgInt64;
typedef unsigned long long int StgWord64;
#else
#error cannot find a way to define StgInt64
#endif

/*
 * Define the standard word size we'll use on this machine: make it
 * big enough to hold a pointer.
 *
 * It's useful if StgInt/StgWord are always the same as long, so that
 * we can use a consistent printf format specifier without warnings on
 * any platform.  Fortunately this works at the moement; if it breaks
 * in the future we'll have to start using macros for format
 * specifiers (c.f. FMT_StgWord64 in Rts.h).
 */

#if SIZEOF_VOIDP == 8
typedef StgInt64           StgInt;
typedef StgWord64          StgWord;
typedef StgInt32           StgHalfInt;
typedef StgWord32          StgHalfWord;
#else
#if SIZEOF_VOIDP == 4
typedef StgInt32           StgInt; 
typedef StgWord32          StgWord;
typedef StgInt16           StgHalfInt;
typedef StgWord16          StgHalfWord;
#else
#error logToThreadscope untested on this architecture: sizeof(void *) != 4 or 8
#endif
#endif

typedef StgWord32 StgThreadID;
typedef int                StgBool;
#ifndef EVENTLOG_CONSTANTS_ONLY

typedef StgWord16 EventTypeNum;
typedef StgWord64 EventTimestamp; /* in nanoseconds */
typedef StgWord32 EventThreadID;
typedef StgWord16 EventTaskID;
typedef StgWord16 EventCapNo;
typedef StgWord16 EventPayloadSize; /* variable-size events */
typedef StgWord32 EventThreadStatus; /* status for EVENT_STOP_THREAD */
typedef StgWord32 EventCapsetID;
typedef StgWord16 EventCapsetType;   /* types for EVENT_CAPSET_CREATE */

typedef struct _EventHeader {
    EventTypeNum   tag;
    EventTimestamp time;
} EventHeader;

typedef struct _Event {
  EventHeader header;
  void       *payload;
} Event;

typedef struct _EventStartup {
  EventHeader header;
  EventCapNo  n_caps;
} EventStartup;

typedef struct _EventBlock {
  EventHeader    header;
  EventTimestamp end_time;
  EventCapNo     cap;
  StgWord8      *block_events;
} EventBlock;

typedef struct _EventThread {
  EventHeader   header;
  EventThreadID thread;
}  EventThread;

typedef struct _EventThread EventCreateThread;      // (cap, thread)
typedef struct _EventThread EventRunThread;
typedef struct _EventThread EventThreadRunnable;
typedef struct _EventThread EventRunSpark;
typedef struct _EventThread EventCreateSparkThread;

typedef struct _EventThreadCap {
  EventHeader   header;
  EventThreadID thread;
  EventCapNo    cap;
} EventThreadCap;

typedef struct _EventThreadCap EventMigrateThread;  // (cap, thread, new_cap)
typedef struct _EventThreadCap EventStealSpark;
typedef struct _EventThreadCap EventThreadWakeup;

typedef struct _EventTask { // (cap, task)
  EventHeader header;
  EventTaskID task;
} EventTask;

typedef struct _EventStopThread {
  EventHeader   header;
  EventThreadID thread;
  StgWord16     status;
  EventThreadID blocked_on;
  StgWord64     alloc;
} EventStopThread;

typedef struct _Event EventShutdown;
typedef struct _Event EventRequestSeqGC;
typedef struct _Event EventRequestParGC;
typedef struct _Event EventGCStart;
typedef struct _Event EventGCEnd;

#endif

#endif /* RTS_EVENTLOGFORMAT_H */
