#include <stdlib.h>
#include <src/compiled.h>

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

static inline void postBuf(EventsBuf *eb, StgWord8 *buf, nat size)
{
  memcpy(eb->pos, buf, size);
  eb->pos += size;
}

static inline int getBuf (StgWord8 *p,nat size)
{
	return (fread(p,1,size,event_log_file));
}

static inline void postEventTypeNum(EventsBuf *eb, EventTypeNum etNum)
{ postWord16(eb, etNum); }

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

static inline void postEventHeader(EventsBuf *eb, EventTypeNum type)
{
    postEventTypeNum(eb, type);
    postTimestamp(eb);
}    

static inline void postInt8(EventsBuf *eb, StgInt8 i)
{ postWord8(eb, (StgWord8)i); }

static inline void postInt16(EventsBuf *eb, StgInt16 i)
{ postWord16(eb, (StgWord16)i); }

static inline void postInt32(EventsBuf *eb, StgInt32 i)
{ postWord32(eb, (StgWord32)i); }

static inline void postInt64(EventsBuf *eb, StgInt64 i)
{ postWord64(eb, (StgWord64)i); }
