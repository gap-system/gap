/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

/*
 *   The binary encoding is designed to be more compact than the verbose
 * SG/XML encodings. We tried also to keep it simple enough to allow new
 * implementations of this lib to be done.
 * 
 *   You may find the detailled description of binary encoding in the
 * OpenMath specification document. (shiped with this lib)
 */


#include "OMP.h"

#if defined(__sun) && defined(__SVR4)
/* For sunOS 5.x */
#include <sys/byteorder.h>
#elif defined(__linux)
#include <netinet/in.h>
#elif defined(__alpha)
#include <netinet/in.h>
#elif defined(RS6000)
#include <net/nh.h>
#endif



/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/*
 *                           Sharing functions
 */
static int OMBEhashString(char *data, int len);
static OMbool OMBEoutCheckSharing(OMdev dev, char *data, int len, char *auxData, int auxLen, int *id, OMBEoutShareContextStruct * osc);
static OMstatus OMBEinStoreForSharing(OMdev dev, char *data, int len, char *auxData, int auxLen, OMBEinShareContextStruct * isc, OMbool dupData);
static OMstatus OMBEputWithSharing(OMdev dev, OMtokenType tokType, char *data, int len, char *auxData, int auxLen, OMBEoutShareContextStruct * osc, OMbool wide);
static OMstatus OMBEgetShareId(OMdev dev);
static void OMBEsetSharedLen(OMdev dev, OMtokenType type);
static OMstatus OMBEgetShared(OMdev dev, int aux, char **data, int *dataLen, int tail, char *message, OMBEinShareContextStruct * isc, OMbool wantWC);
static void OMfreeInShareTable(OMBEinShareContextStruct * isc);
static void OMfreeInShareTables(OMbinState state);
static void OMfreeOutShareTable(OMBEoutShareContextStruct * osc);
static void OMfreeOutShareTables(OMbinState state);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#define MAX_SYMBOL_NAME_SIZE 1024
#define MAX_CD_NAME_SIZE 1024
#define MAX_SHARABLE_STRING_LEN 256

/* for big integer formats */
#define POSBASE10 '+'		/* 2B */
#define NEGBASE10 '-'		/* 2C */
#define POSBASE16 (POSBASE10 + (1<<6))	/* 0x40 + '+' */
#define NEGBASE16 (NEGBASE10 + (1<<6))	/* 0x40 + '-' */


/* some useful macros */
/* io shortcuts */
#define WRITE(Dev, P, L)    (*(Dev->io->write))(Dev, P, L)
#define PRINT(Dev, P)       (*(Dev->io->print))(Dev, P)
#define PUTCHAR(Dev, C)     (*(Dev->io->putChar))(Dev, C)
#define LOOKAHEAD(Dev)      (*(Dev->io->lookAhead))(Dev)
#define GETCHAR(Dev)        (*(Dev->io->getChar))(Dev)
#define READ(Dev, Buff, N)  (*(Dev->io->read))(Dev, Buff, N)
/* private state accessors shortcuts */
#define STATE(Dev)          ((OMbinState) ((Dev)->translation->state))

#define CURRENTTYPE(Dev)    (STATE(Dev)->currentType)
#define LENGTH(Dev)         (STATE(Dev)->length)
#define NLENGTH(Dev)        (STATE(Dev)->nlength)
#define BIGLEN(Dev)         (STATE(Dev)->bigLen)
#define SHARED(Dev)         (STATE(Dev)->shared)
#define WC(Dev)             (STATE(Dev)->wc)
#define ID(Dev)             (STATE(Dev)->currentId)
#define OUTSCVAR(Dev)       &(STATE(Dev)->outShareContextVar)
#define OUTSCSTR(Dev)       &(STATE(Dev)->outShareContextStr)
#define OUTSCSYMB(Dev)      &(STATE(Dev)->outShareContextSymb)
#define INSCVAR(Dev)        &(STATE(Dev)->inShareContextVar)
#define INSCSTR(Dev)        &(STATE(Dev)->inShareContextStr)
#define INSCSYMB(Dev)       &(STATE(Dev)->inShareContextSymb)
#if OM_DEBUG
#define BYTE(Dev)           (STATE(Dev)->byte)
#define NOUNSHAREDWARN(Dev) (STATE(Dev)->noUnsharedWarn)
#endif

/* put a token type on dev with corresponding len mask */
#define PUTOKTYPE(Dev, TType, Len) \
          OMcheckStatus(PUTCHAR(Dev, \
              TType | (((Len) < 256) ? 0 : OM_BE_BIG_LEN_MASK)))
/* convenience (put token type on dev with shared flag) */
#define PUTOKTYPESHARED(Dev, TType) \
           OMcheckStatus(PUTCHAR(Dev, TType | OM_BE_SHARED_MASK))


#if OM_DEBUG
#define OMBEcheckType(Dev, Type) \
{ \
  OMtokenType _ftype; \
  OMcheckStatus(OMBEgetType(Dev, &_ftype)); \
  if (_ftype != (Type)) { \
    OMprintf(OMwarnLevel, "byte %d: Looking for '%s' token but found '%s'.\n", BYTE(Dev), OMtokenTypeToString(Type), OMtokenTypeToString(_ftype)); \
    dbgStopHere(); \
    return OMmalformedInput; \
  } \
}
#else
#define OMBEcheckType(Dev, Type) \
{ \
  OMtokenType _ftype; \
  OMcheckStatus(OMBEgetType(Dev, &_ftype)); \
  if (_ftype != (Type)) { \
    return OMmalformedInput; \
  } \
}
#endif

#if OM_DEBUG
#define OMBEcheckStringType(Dev) \
{ \
  OMtokenType _ftype; \
  OMcheckStatus(OMBEgetType(Dev, &_ftype)); \
  if ((_ftype != OMtokenString) && (_ftype != OMtokenWCString)) { \
    OMprintf(OMwarnLevel, "byte %d: Looking for '%s' or '%s' token but found '%s'.\n", BYTE(Dev), OMtokenTypeToString(OMtokenString),OMtokenTypeToString(OMtokenWCString), OMtokenTypeToString(_ftype)); \
    dbgStopHere(); \
    return OMmalformedInput; \
  } \
}
#else
#define OMBEcheckStringType(Dev) \
{ \
  OMtokenType _ftype; \
  OMcheckStatus(OMBEgetType(Dev, &_ftype)); \
  if ((_ftype != OMtokenString) && (_ftype != OMtokenWCString)) { \
    return OMmalformedInput; \
  } \
}
#endif


/*
 *                           Sharing functions
 */


Module int
OMBEhashString(char *data, int len)
{
  int l, i, k = 0;

  /* TODO use a better hash function */
  l = Min(len, OM_BE_HASHLEN);
  for (i = 0; i < l; i++) {
    k += data[i];
  }
  return Abs(k * len);
}


Module OMbool
OMBEoutCheckSharing(OMdev dev, char *data, int len, char *auxData, int auxLen, int *id, OMBEoutShareContextStruct * osc)
{
  OMBEshareStruct *table;
  int hashKey, i;

  OMassert(dev);
  OMassert(data);
  OMassert(osc);

  /* sharing is done only on the 255 first different sharable tokens */
  if (osc->nextId > 255)
    return 0;
  hashKey = OMBEhashString(data, len);
  if (auxData)
    hashKey += OMBEhashString(auxData, auxLen);
  i = hashKey % (OM_BE_SHARETABLE_SZ);
  table = osc->shareTable;
  while (table[i].data) {
    if ((hashKey == table[i].hashKey)
	&& (len == table[i].len)
	&& (auxLen == table[i].auxLen)
	&& (!memcmp(data, table[i].data, len))
	&& ((!auxData) || (!memcmp(auxData, table[i].auxData, auxLen)))) {
      *id = table[i].id;
      return OMtrue;
    }
    i--;
    if (i < 0)
      i = OM_BE_SHARETABLE_SZ - 1;
  }
  OMassert(!table[i].data && !table[i].auxData);
  table[i].id = osc->nextId++;
  table[i].hashKey = hashKey;
  table[i].data = OMdup(data, len);
  table[i].len = len;
  if (auxLen) {
    table[i].auxData = OMdup(auxData, auxLen);
    table[i].auxLen = auxLen;
  }
  return OMfalse;
}


Module OMstatus
OMBEinStoreForSharing(OMdev dev, char *data, int len, char *auxData, int auxLen, OMBEinShareContextStruct * isc, OMbool dupData)
{
  OMBEshareStruct *table;
  int hashKey, i, id;

  OMassert(data);
  /* sharing is done only on the 255 first different sharable tokens */
  if ((id = isc->nextId) > 255)
    return OMsuccess;
  hashKey = OMBEhashString(data, len);
  if (auxData)
    hashKey += OMBEhashString(auxData, auxLen);
  i = hashKey % (OM_BE_SHARETABLE_SZ);
  table = isc->shareTable;
  while (table[i].data) {
#if OM_DEBUG
    if (!NOUNSHAREDWARN(dev)) {
      if ((hashKey == table[i].hashKey)
	  && (len == table[i].len)
	  && (auxLen == table[i].auxLen)
	  && (!memcmp(data, table[i].data, len))
	  && ((!auxData) || (!memcmp(auxData, table[i].auxData, auxLen)))) {
	OMprintf(OMwarnLevel, "Sender seem's to emit tokens without sharing.\n(token \"%s%s%s\" has already been received (id %d)\n and this instance has not been shared. This message won't be repeated.)\n",
		 data,
		 (auxData) ? ":" : "",
		 (auxData) ? auxData : "",
		 table[i].id);
	NOUNSHAREDWARN(dev) = OMtrue;
      }
    }
#endif /* OM_DEBUG */
    i--;
    if (i < 0)
      i = OM_BE_SHARETABLE_SZ - 1;
  }
  table[i].id = id;
  isc->idToKey[id] = i;
  isc->nextId++;
  table[i].hashKey = hashKey;
  if (!dupData) {
    table[i].data = data;
  }
  else {
    if (!(table[i].data = OMdup(data, len)))
      return OMnoMem;
  }
  table[i].len = len;

  if (auxLen) {
    if (!dupData) {
      table[i].auxData = auxData;
    }
    else {
      if (!(table[i].auxData = OMdup(auxData, auxLen)))
	return OMnoMem;
    }
    table[i].auxLen = auxLen;
  }
  return OMsuccess;
}



/*
 *                              IO functions
 */

Lib OMstatus
OMBEputInt32(OMdev dev, int i)
{
  unsigned int nh;
  char c;

  OMassert(dev);

  /* check if this signed int fits in a signed byte */ 
  /* more optimized tests like (int)((char)(i))==i fail on some systeme (like AIX) */ 
  if (i<128 && i>-129) { 
    c = (char) i; 
    OMcheckStatus(PUTCHAR(dev, OMtokenInt32)); 
    return WRITE(dev, (char *) &c, 1); 
  } 
  else {
    OMcheckStatus(PUTCHAR(dev, OMtokenInt32 | OM_BE_BIG_LEN_MASK));
    nh = htonl(i);
    return WRITE(dev, (char *) &nh, 4);
  }
}


Lib OMstatus
OMBEputFloat64(OMdev dev, double *d)
{
  OMassert(sizeof(double) == 8);
  OMassert(dev);

  PUTCHAR(dev, OMtokenFloat64);
  if (OMlittleEndianMode) {
    return WRITE(dev, (char *) d, sizeof(double));
  }
  else {
    double dc;
    dc = OMdoubleBE2LE(*d);
    return WRITE(dev, (char *) &dc, sizeof(double));
  }
}


Lib OMstatus
OMBEputSLength(OMdev dev, int len)
{
  unsigned int nh;
  unsigned char b;

  OMassert(dev);
  OMassert(len >= 0);

  if (len < 256) {
    b = len;
    return WRITE(dev, (char *) &b, 1);
  }
  else {
    nh = htonl(len);
    return WRITE(dev, (char *) &nh, 4);
  }

}


Lib OMstatus
OMBEputBigInt(OMdev dev, char *data, int len, int sign, OMbigIntType format)
{
  OMassert(dev);
  OMassert(data);
  OMassert(len >= 0);

#if OM_DEBUG
  if ((*data == '+') || (*data == '-')) {
    OMprintf(OMwarnLevel, "Warning: You left the sign character '%c' in the body of this bigInt. This is not legal!\n", *data);
  }
#endif /* OM_DEBUG */

  switch (format) {
  case OMbigIntBase10:
    PUTOKTYPE(dev, OMtokenBigInt, len);
    OMcheckStatus(OMBEputSLength(dev, len));
    if (sign < 0)
      PUTCHAR(dev, NEGBASE10);
    else
      PUTCHAR(dev, POSBASE10);
    return WRITE(dev, data, len);
    break;
  case OMbigIntBase16:
    PUTOKTYPE(dev, OMtokenBigInt, len);
    OMcheckStatus(OMBEputSLength(dev, len));
    if (sign < 0)
      PUTCHAR(dev, NEGBASE16);
    else
      PUTCHAR(dev, POSBASE16);
    return WRITE(dev, data, len);
    break;
  default:
    OMfatalInternal(OMnotImplemented, "Unsupported big integer format.\n");
    return OMfailed;
  }
}


Lib OMstatus
OMBEputByteArray(OMdev dev, char *data, int len)
{
  OMassert(dev);
  OMassert(data);
  OMassert(len >= 0);

  PUTOKTYPE(dev, OMtokenByteArray, len);
  OMcheckStatus(OMBEputSLength(dev, len));
  return WRITE(dev, data, (int) len);
}


Module OMstatus
OMBEputWithSharing(OMdev dev, OMtokenType tokType, char *data, int len, char *auxData, int auxLen, OMBEoutShareContextStruct * osc, OMbool wide)
{
  int id;
  int mlen;

  OMassert(dev);

  mlen = Max(len, auxLen);
  if (OMBEoutCheckSharing(dev, data, len, auxData, auxLen, &id, osc)) {
    /* sharing ok put a reference to original token */
    PUTOKTYPESHARED(dev, tokType);
    return PUTCHAR(dev, id);
  }
  else {
    /* a non shared token, put it in extended form */
    PUTOKTYPE(dev, tokType, mlen);
    OMcheckStatus(OMBEputSLength(dev, len));
    if (auxData)
      OMcheckStatus(OMBEputSLength(dev, auxLen));
    if (wide && OMlittleEndianMode) {
      /* need to reorder bytes :( */
      OMcheckStatus(OMwriteHtoNUCS2Array(dev, (OMUCS2 *) data, len / 2));
      if (auxData)
	OMcheckStatus(OMwriteHtoNUCS2Array(dev, (OMUCS2 *) auxData, auxLen / 2));
    }
    else {
      OMcheckStatus(WRITE(dev, data, len));
      if (auxData)
	OMcheckStatus(WRITE(dev, auxData, auxLen));

    }
    return OMsuccess;
  }
}


Lib OMstatus
OMBEputString(OMdev dev, char *str, int len)
{
  OMassert(dev);
  OMassert(str);
  OMassert(len > 0);

  if (len < MAX_SHARABLE_STRING_LEN)
    return OMBEputWithSharing(dev, OMtokenString, str, len, NULL, 0, OUTSCSTR(dev), OMfalse);
  else {
    PUTOKTYPE(dev, OMtokenString, len);
    OMcheckStatus(OMBEputSLength(dev, len));
    return WRITE(dev, str, (int) len);
  }
}

Lib OMstatus
OMwriteHtoNUCS2Array(OMdev dev, OMUCS2 * wcstr, int len)
{
  OMstatus status;
  short s;
  int i;

  for (i = 0; i < len; i++) {
    s = ((wcstr[i] & 0xff) << 8) | ((wcstr[i] & 0xff00) >> 8);
    if (status = WRITE(dev, (char *) &s, 2)) {
      return status;
    }
  }
  return OMsuccess;
}

Lib void
OMswapUCS2Array(OMUCS2 * array, int len)
{
  short s;
  int i;

  for (i = 0; i < len; i++) {
    s = ((array[i] & 0xff) << 8) | ((array[i] & 0xff00) >> 8);
    array[i] = s;
  }
}

Lib OMstatus
OMBEputWCString(OMdev dev, OMUCS2 * wcstr, int len)
{
  OMassert(dev);
  OMassert(wcstr);
  OMassert(len > 0);

  /* real data len is twice the number of wide chars. */
  len *= 2;
  if (len < MAX_SHARABLE_STRING_LEN)
    return OMBEputWithSharing(dev, OMtokenWCString, (char *) wcstr, len, NULL, 0, OUTSCSTR(dev), OMtrue);
  else {
    PUTOKTYPE(dev, OMtokenWCString, len);
    OMcheckStatus(OMBEputSLength(dev, len));
    if (OMlittleEndianMode) {
      return OMwriteHtoNUCS2Array(dev, wcstr, len / 2);
    }
    else {
      return WRITE(dev, (char *) wcstr, len);
    }
  }
}


Lib OMstatus
OMBEputVar(OMdev dev, char *var, int len)
{
  OMassert(dev);
  OMassert(var);
  OMassert(len > 0);

  return OMBEputWithSharing(dev, OMtokenVar, var, len, NULL, 0, OUTSCVAR(dev), OMfalse);
}


Lib OMstatus
OMBEputSymbol(OMdev dev, char *cd, int clen, char *name, int nlen)
{
  OMassert(dev);
  OMassert(cd);
  OMassert(clen > 0);
  OMassert(name);
  OMassert(nlen > 0);

  return OMBEputWithSharing(dev, OMtokenSymbol, cd, clen, name, nlen, OUTSCSYMB(dev), OMfalse);
}


Lib OMstatus
OMBEputTokenTag(OMdev dev, OMtokenType ttype)
{
  OMassert(dev);

  OMassert((ttype == OMtokenApp) ||
	   (ttype == OMtokenEndApp) ||
	   (ttype == OMtokenAttr) ||
	   (ttype == OMtokenEndAttr) ||
	   (ttype == OMtokenAtp) ||
	   (ttype == OMtokenEndAtp) ||
	   (ttype == OMtokenError) ||
	   (ttype == OMtokenEndError) ||
	   (ttype == OMtokenBind) ||
	   (ttype == OMtokenEndBind) ||
	   (ttype == OMtokenBVar) ||
	   (ttype == OMtokenEndBVar) ||
	   (ttype == OMtokenObject) ||
	   (ttype == OMtokenEndObject));

  return PUTCHAR(dev, (char) ttype);
}


Lib OMstatus
OMBEputComment(OMdev dev, char *comment, int len)
{
  PUTOKTYPE(dev, OMtokenComment, len);
  OMcheckStatus(OMBEputSLength(dev, len));
  return WRITE(dev, comment, (int) len);
}


Lib OMstatus
OMBEbeginObject(OMdev dev)
{
  OMassert(dev);

  return OMsuccess;
}


Lib OMstatus
OMBEendObject(OMdev dev)
{
  OMassert(dev);

  OMfreeOutShareTables(STATE(dev));
  return (*(dev->io->flush)) (dev);
}






Lib OMstatus
OMBEgetSLength(OMdev dev, int *res)
{
  int n;
  unsigned char b;

  OMassert(dev);

  if (BIGLEN(dev)) {
    OMcheckStatus(READ(dev, (char *) &n, 4));
    n = ntohl(n);
    LENGTH(dev) = n;
    if (res)
      *res = n;
#if OM_DEBUG
    BYTE(dev) += n + 4;
#endif
  }
  else {
    OMcheckStatus(READ(dev, (char *) &b, 1));
    LENGTH(dev) = (int) b;
    if (res)
      *res = (int) b;
#if OM_DEBUG
    BYTE(dev) += b + 1;
#endif
  }
  return OMsuccess;
}


Module OMstatus
OMBEgetShareId(OMdev dev)
{
  unsigned char id;
  OMassert(dev);
  OMassert(SHARED(dev));

  OMcheckStatus(READ(dev, (char *) &id, 1));
  ID(dev) = id;
  return OMsuccess;
}


Module void
OMBEsetSharedLen(OMdev dev, OMtokenType type)
{
  OMBEinShareContextStruct *isc;
  OMBEshareStruct *table;

  OMassert(dev);
  OMassert(SHARED(dev));
  switch (type) {
  case OMtokenVar:
    isc = INSCVAR(dev);
    break;
  case OMtokenSymbol:
    isc = INSCSYMB(dev);
    break;
  case OMtokenString:
  case OMtokenWCString:
    isc = INSCSTR(dev);
    break;
  default:
    OMIE;
  }
  table = isc->shareTable;
  LENGTH(dev) = table[isc->idToKey[ID(dev)]].len;
  NLENGTH(dev) = table[isc->idToKey[ID(dev)]].auxLen;
}

Module OMstatus
OMBEskipComments(OMdev dev, OMtokenType * header)
{
  char buf[1024];
  int clen,len;

  OMassert(dev);
  OMassert(header);
  
  CURRENTTYPE(dev) = OMtokenUnknown;
  
  while(((*header)&(~(OM_BE_BIG_LEN_MASK|OM_BE_SHARED_MASK)))==OMtokenComment){
      if ((*header) & OM_BE_BIG_LEN_MASK) {
          BIGLEN(dev) = OMtrue;
      }
      else {
          BIGLEN(dev) = OMfalse;
      }
      /* get length and skip comment text */
      OMcheckStatus(OMBEgetSLength(dev,&clen));
      /* OPIM: add a seek to low level device? */
      while(clen >0){
          len = Min(sizeof(buf),clen);
          OMcheckStatus(READ(dev, buf, len));
          clen-=len;
      }
      /* reget a new header */
      *header = GETCHAR(dev);
  }
  return OMsuccess;
}


/* we also read the length and store it */
Lib OMstatus
OMBEgetType(OMdev dev, OMtokenType * type)
{
  OMtokenType header;
  int clen;

  OMassert(dev);
  OMassert(type);

  /* type already known */
  if (CURRENTTYPE(dev) != OMtokenUnknown) {
    *type = CURRENTTYPE(dev);
    return OMsuccess;
  }

  header = GETCHAR(dev);
  /* in skip comment mode use an optimised version of th eget loop */
  if(dev->ignoreComments && 
     ((header&(~(OM_BE_BIG_LEN_MASK|OM_BE_SHARED_MASK)))==OMtokenComment)){
      OMcheckStatus(OMBEskipComments(dev,&header));
  }

  if (header == EOF) {
    return OMnoMoreToken;
  }
  if (header & OM_BE_BIG_LEN_MASK) {
    header = (OMtokenType) (((unsigned char) header) & ~OM_BE_BIG_LEN_MASK);
    BIGLEN(dev) = OMtrue;
  }
  else {
    BIGLEN(dev) = OMfalse;
  }

  if (header & OM_BE_SHARED_MASK) {
    header = (OMtokenType) (((unsigned char) header) & ~OM_BE_SHARED_MASK);
    SHARED(dev) = OMtrue;
    OMcheckStatus(OMBEgetShareId(dev));
  }
  else {
    SHARED(dev) = OMfalse;
  }

  if (header == OMtokenWCString) {
    WC(dev) = OMtrue;
  }
  else {
    WC(dev) = OMfalse;
  }

  CURRENTTYPE(dev) = header;
  *type = header;
#if OM_DEBUG
  BYTE(dev)++;
  if (!SHARED(dev)) {
    if ((header == '<') ||
	(header == ' ') ||
	(header == '\t') ||
	(header == '\r') ||
	(header == '\n')) {
      OMprintf(OMwarnLevel, "Are you sure this device is filled with binary encoded OpenMath objects? It looks like XML text!\n");
    }
  }
#endif

  if (!SHARED(dev)) {
    if (header == OMtokenString) {
      OMcheckStatus(OMBEgetSLength(dev, NULL));
    }
    if (header == OMtokenWCString) {
      OMcheckStatus(OMBEgetSLength(dev, NULL));
    }
    else if (header == OMtokenVar) {
      OMcheckStatus(OMBEgetSLength(dev, NULL));
    }
    else if (header == OMtokenBigInt) {
      OMcheckStatus(OMBEgetSLength(dev, NULL));
    }
    else if (header == OMtokenByteArray) {
      OMcheckStatus(OMBEgetSLength(dev, NULL));
    }
    else if (header == OMtokenComment) {
      OMcheckStatus(OMBEgetSLength(dev, NULL));
    }
    else if (header == OMtokenSymbol) {
      OMcheckStatus(OMBEgetSLength(dev, NULL));
      clen = LENGTH(dev);
      OMcheckStatus(OMBEgetSLength(dev, NULL));
      NLENGTH(dev) = LENGTH(dev);
      LENGTH(dev) = clen;
    }
    else if (header == EOF) {
      return OMnoMoreToken;
    }
  }
  else {
    OMBEsetSharedLen(dev, header);
  }

  return OMsuccess;
}


Lib OMstatus
OMBEgetLength(OMdev dev, int *len)
{
  OMtokenType type;
  int l;

  OMassert(dev);
  OMassert(len);

  if ((type = CURRENTTYPE(dev)) == OMtokenUnknown) {
    *len = -1;
    OMcheckStatus(OMBEgetType(dev, &type));
  }
  switch (type) {
  case OMtokenBigInt:
  case OMtokenByteArray:
  case OMtokenString:
  case OMtokenWCString:
  case OMtokenVar:
  case OMtokenComment:
    l = LENGTH(dev);
    break;
  default:
    l = -1;
  }
  *len = l;
  return OMsuccess;
}


Lib OMstatus
OMBEgetSymbolLength(OMdev dev, int *clen, int *nlen)
{
  OMtokenType type;

  OMassert(dev);
  OMassert(clen);
  OMassert(nlen);

  if ((type = CURRENTTYPE(dev)) == OMtokenUnknown) {
    *clen = -1;
    *nlen = -1;
    OMcheckStatus(OMBEgetType(dev, &type));
  }
  switch (type) {
  case OMtokenSymbol:
    *clen = LENGTH(dev);
    *nlen = NLENGTH(dev);
    break;
  default:
    *clen = -1;
    *nlen = -1;
  }
  return OMsuccess;
}


Lib OMstatus
OMBEgetInt32(OMdev dev, int *res)
{
  int n;
  char c;

  OMassert(dev);
  OMassert(res);

  OMBEcheckType(dev, OMtokenInt32);
  if (BIGLEN(dev)) {
    OMcheckStatus(READ(dev, (char *) &n, 4));
    *res = ntohl(n);
  }
  else {
    OMcheckStatus(READ(dev, &c, 1));
#ifdef _AIX
    /* ugly kludge for AIX where: */  
    /* char c=-1; int i=c; i==255! */ 
    if(((int)c)<((int)128)){ 
      *res = (int) c; 
    }else{ 
      *res = ((int) c)-256; 
    } 
#else
    *res = (int) c;
#endif
  }
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}


Lib OMstatus
OMBEgetFloat64(OMdev dev, double *d)
{
  OMassert(dev);
  OMassert(d);

  OMBEcheckType(dev, OMtokenFloat64);

  if (OMlittleEndianMode) {
    OMcheckStatus(READ(dev, (char *) d, 8));
  }
  else {
    double dc;
    OMcheckStatus(READ(dev, (char *) &dc, 8));
    *d = OMdoubleLE2BE(dc);
  }
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}


Lib OMstatus
OMBEgetBigInt(OMdev dev, char **data, int *len, int *sign, OMbigIntType * format)
{
  int l;

  OMassert(dev);
  OMassert(data);
  OMassert(len);
  OMassert(sign);
  OMassert(format);

  OMBEcheckType(dev, OMtokenBigInt);

  switch (GETCHAR(dev)) {
  case NEGBASE10:
    *sign = -1;
    *format = OMbigIntBase10;
    break;
  case POSBASE10:
    *sign = 1;
    *format = OMbigIntBase10;
    break;
  case NEGBASE16:
    *sign = -1;
    *format = OMbigIntBase16;
    break;
  case POSBASE16:
    *sign = 1;
    *format = OMbigIntBase16;
    break;
  default:
    OMNYI;
    return OMfailed;
  }

  l = STATE(dev)->length;
  if (!*data) {
    *data = OMmallocInternal(l + 1);
    (*data)[l] = '\0';
  }
  else {
    if (*len < l) {
#if OM_DEBUG
      memset(*data, '?', (Min(*len, OM_WARN_DATA_LEN)));
      OMprintf(OMwarnLevel, "Given buffer is too small (given %d byte%s, needed %d).\n", *len, (*len > 1) ? "s" : "", l);
#endif
      *len = l;
      return OMnoMem;
    }
  }
  *len = l;
  OMcheckStatus(READ(dev, *data, l));

#if OM_DEBUG
  if ((**data == '+') || (**data == '-')) {
    OMprintf(OMwarnLevel, "byte %d: Warning: There is a sign character '%c' in the body of this bigInt. This is not legal!\n", BYTE(dev), **data);
  }
#endif /* OM_DEBUG */

  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}


Lib OMstatus
OMBEcheckData(OMdev dev, int len, char **data, int *dataLen, int tail, char *message, OMbool wantWC)
{
  OMassert(data);

  /* adjust real data buffer length depending on kind of
   * string.
   * caller need room for normal or wide char string. */
  if (wantWC) {
    tail *= 2;			/* wide strings are ended with 0x0000 */
    if (!WC(dev)) {
      /* input is a 8bits char string */
      len = len * 2;
    }
  }
  else {
    if (WC(dev)) {
      /* input is a 16bits char string */
      len = len / 2;
    }
  }

  if (!(*data)) {
    *data = OMmallocWarn(len + tail, message);
    if (tail) {
      /* put the trailing null */
      if (wantWC) {
	(*data)[len + 1] = 0;
      }
      (*data)[len] = 0;
    }
    if (dataLen)
      *dataLen = len;
  }
  else {
    OMassert(dataLen);
    if (*dataLen >= len) {
      /* enough room for input data */
      if (tail && (*dataLen >= (len + tail))) {
	/* room for it thus put the trailing null */
	if (wantWC) {
	  (*data)[len + 1] = 0;
	}
	(*data)[len] = 0;
      }
    }
    else {
      /* not enough room for input data */
#if OM_DEBUG
      int l;
      /* warn caller by filling his buffer with '?' */
      l = Min(*dataLen, OM_WARN_DATA_LEN);
      memset(*data, '?', l);
      /* put trailing null */
      (*data)[l] = '\0';
      if (l)
	(*data)[l - 1] = '\0';
      OMprintf(OMwarnLevel, "Given buffer is too small (given %d byte%s, needed %d.\n)", *dataLen, (*dataLen > 1) ? "s" : "", len);
#endif
      /* return len that was needed thus caller may trace the problem */
      *dataLen = len;
      return OMnoMem;
    }
  }

  return OMsuccess;
}

Lib void
OMconvertStrings(char *src, char *dest, OMbool srcWC, OMbool destWC, int len)
{
  OMUCS2 *wcptr;
  char *ptr;

  OMassert(destWC != srcWC);	/* or else it should not have been called */

  if (destWC) {
    /* src is made of chars and dest wants wide chars */
    ptr = src;
    wcptr = (OMUCS2 *) dest;
    while (len--) {
      *wcptr = (OMUCS2) * ptr;
      ptr++;
      wcptr++;
    }
  }
  else {
    /* src is made of wide chars and dest wants chars */
    len = len / 2;
    wcptr = (OMUCS2 *) src;
    ptr = dest;
    while (len--) {
      *ptr = (char) *wcptr;
      ptr++;
      wcptr++;
    }
  }
}

/* OMBEgetRaw
 *   Get a raw chumck of bytes (aka: a string) 
 *   from input device.
 *   Insert it in share context.
 *   Return (in <data>) a 8<->16 converted copy.
 * dev:     device to read bytes from
 * len:     length of byte string to read
 * data:    where to store returned string
 * dataLen: if data is already allocated 
 *             then its length (in bytes)
 *             else will be filled with its length 
 *                  (in bytes)
 * tail:    must we add a tail (for C strings)
 * message: allocation error message
 * isc:     input sharing context where to insert string 
 *          (or null if no share is wanted)
 * wantWC:  does caller want a resulting <data> in wide
 *          char (16 bits) ot normal chars (8 bits)
 * 
 * return: OMsuccess or some error code
 */
Lib OMstatus
OMBEgetRaw(OMdev dev, int len, char **data, int *dataLen, int tail, char *message, OMBEinShareContextStruct * isc, OMbool wantWC)
{
  OMassert(dev);
  OMassert(data);

  OMcheckStatus(OMBEcheckData(dev, len, data, dataLen, tail, message, wantWC));

  if (WC(dev) == wantWC) {
    /* here we can avoid an useless buffer copy */
    OMcheckStatus(READ(dev, *data, len));
    if (WC(dev) && OMlittleEndianMode) {
      /* need to revert byte order */
      OMswapUCS2Array((OMUCS2 *) * data, len / 2);
    }
    if (isc) {
      OMcheckStatus(OMBEinStoreForSharing(dev, *data, len, NULL, 0, isc, OMtrue));
    }
  }
  else {
    /* can't take user's buffer for primary storage */
    char *buf;
    buf = OMmallocWarn(len, message);
    OMcheckStatus(READ(dev, buf, len));
    if (WC(dev) && OMlittleEndianMode) {
      /* need to revert byte order */
      OMswapUCS2Array((OMUCS2 *) buf, len / 2);
    }
    /* now must convert raw buffer to user's format */
    OMconvertStrings(buf, *data, WC(dev), wantWC, len);

    if (isc) {
      OMcheckStatus(OMBEinStoreForSharing(dev, buf, len, NULL, 0, isc, OMfalse));
    }
    else {
      free(buf);
    }
  }
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}


/* OMBEgetRawDbl
 *   Like OMBEgetRaw but it gets two byte strings in a row.
 */
Lib OMstatus
OMBEgetRawDbl(OMdev dev, int len, char **data, int *dataLen, int len2, char **data2, int *dataLen2, int tail, char *message, OMBEinShareContextStruct * isc, OMbool wantWC)
{
  OMassert(dev);
  OMassert(data);

  OMcheckStatus(OMBEcheckData(dev, len, data, dataLen, tail, message, wantWC));
  OMcheckStatus(OMBEcheckData(dev, len2, data2, dataLen2, tail, message, wantWC));

  if (WC(dev) == wantWC) {
    /* here we can avoid an useless buffer copy */
    OMcheckStatus(READ(dev, *data, len));
    OMcheckStatus(READ(dev, *data2, len2));

    CURRENTTYPE(dev) = OMtokenUnknown;
    if (isc) {
      return OMBEinStoreForSharing(dev, *data, len, *data2, len2, isc, OMtrue);
    }
  }
  else {
    /* damn' can't take user's buffer for primary storage */
    char *buf, *buf2;
    buf = OMmallocWarn(len + tail, message);
    buf2 = OMmallocWarn(len + tail, message);
    OMcheckStatus(READ(dev, buf, len));
    OMcheckStatus(READ(dev, buf2, len2));
    /* now must convert raw buffer to user's format */
    OMconvertStrings(buf, *data, WC(dev), wantWC, len);
    OMconvertStrings(buf2, *data2, WC(dev), wantWC, len2);

    if (isc) {
      OMcheckStatus(OMBEinStoreForSharing(dev, buf, len, buf2, len2, isc, OMfalse));
    }
    else {
      free(buf);
      free(buf2);
    }
  }
  return OMsuccess;
}


Module OMstatus
OMBEgetShared(OMdev dev, int aux, char **data, int *dataLen, int tail, char *message, OMBEinShareContextStruct * isc, OMbool wantWC)
{
  OMBEshareStruct *table;
  int len, id, i;

  OMassert(dev);
  OMassert(data);
  OMassert(isc);

  table = isc->shareTable;
  id = ID(dev);
  i = isc->idToKey[id];
  if (aux)
    len = table[i].auxLen;
  else
    len = table[i].len;

  OMcheckStatus(OMBEcheckData(dev, len, data, dataLen, tail, message, wantWC));

  if (aux)
    memcpy(*data, table[i].auxData, len);
  else
    memcpy(*data, table[i].data, len);

  if (dataLen)
    *dataLen = len;

  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}


Lib OMstatus
OMBEgetByteArray(OMdev dev, char **data, int *len)
{
  OMBEcheckType(dev, OMtokenByteArray);
  return OMBEgetRaw(dev, LENGTH(dev), data, len, 0, "Cannot allocate new byte array.", NULL, OMfalse);
}


Lib OMstatus
OMBEgetString(OMdev dev, char **str, int *len)
{
  OMBEcheckStringType(dev);
  if (SHARED(dev)) {
    /* shared thus get first instance of this string */
    return OMBEgetShared(dev, OMfalse, str, len, 1, "Cannot allocate new string.", INSCSTR(dev), OMfalse);
  }
  else if (LENGTH(dev) < MAX_SHARABLE_STRING_LEN) {
    /* non shared but may become */
    return OMBEgetRaw(dev, LENGTH(dev), str, len, 1, "Cannot allocate new string.", INSCSTR(dev), OMfalse);
  }
  else {
    /* too big to become shared */
    return OMBEgetRaw(dev, LENGTH(dev), str, len, 1, "Cannot allocate new string.", NULL, OMfalse);
  }
}

Lib OMstatus
OMBEgetWCString(OMdev dev, OMUCS2 ** wcstr, int *len)
{
  OMBEcheckStringType(dev);
  if (SHARED(dev)) {
    /* shared thus get first instance of this string */
    OMcheckStatus(OMBEgetShared(dev, OMfalse, (char **) wcstr, len, 1, "Cannot allocate new wide char string.", INSCSTR(dev), OMtrue));
  }
  else if (LENGTH(dev) < MAX_SHARABLE_STRING_LEN) {
    /* non shared but may become */
    OMcheckStatus(OMBEgetRaw(dev, LENGTH(dev), (char **) wcstr, len, 1, "Cannot allocate new wide char string.", INSCSTR(dev), OMtrue));
  }
  else {
    /* too big to become shared */
    OMcheckStatus(OMBEgetRaw(dev, LENGTH(dev), (char **) wcstr, len, 1, "Cannot allocate new wide char string.", NULL, OMtrue));
  }
  /* adjust byte len to wide char len */
  if (len)
    *len = *len / 2;

  return OMsuccess;
}


Lib OMstatus
OMBEgetVar(OMdev dev, char **var, int *len)
{
  OMBEcheckType(dev, OMtokenVar);
  if (SHARED(dev))
    return OMBEgetShared(dev, OMfalse, var, len, 1, "Cannot allocate new variable.", INSCVAR(dev), OMfalse);
  else {
    return OMBEgetRaw(dev, LENGTH(dev), var, len, 1, "Cannot allocate new variable.", INSCVAR(dev), OMfalse);
  }
}


Lib OMstatus
OMBEgetSymbol(OMdev dev, char **cd, int *clen, char **symb, int *slen)
{
  OMassert(dev);
  OMassert(cd);
  OMassert(symb);

  OMBEcheckType(dev, OMtokenSymbol);

  if (SHARED(dev)) {
    OMcheckStatus(OMBEgetShared(dev, OMfalse, cd, clen, 1, "Cannot allocate new CD.", INSCSYMB(dev), OMfalse));
    /* here we need to reset current token because getRaw just cleared it */
    CURRENTTYPE(dev) = OMtokenSymbol;
    OMcheckStatus(OMBEgetShared(dev, OMtrue, symb, slen, 1, "Cannot allocate new symbol.", INSCSYMB(dev), OMfalse));
  }
  else {
    OMcheckStatus(OMBEgetRawDbl(dev, LENGTH(dev), cd, clen, NLENGTH(dev), symb, slen, 1, "Cannot allocate new symbol.", INSCSYMB(dev), OMfalse));
  }
  return OMsuccess;
}


Lib OMstatus
OMBEgetTokenTag(OMdev dev, OMtokenType ttype)
{
  OMtokenType foundTType;

  OMassert(dev);
  OMassert((ttype == OMtokenApp) ||
	   (ttype == OMtokenEndApp) ||
	   (ttype == OMtokenAttr) ||
	   (ttype == OMtokenEndAttr) ||
	   (ttype == OMtokenAtp) ||
	   (ttype == OMtokenEndAtp) ||
	   (ttype == OMtokenError) ||
	   (ttype == OMtokenEndError) || (ttype == OMtokenBind) ||
	   (ttype == OMtokenEndBind) ||
	   (ttype == OMtokenBVar) ||
	   (ttype == OMtokenEndBVar) ||
	   (ttype == OMtokenObject) ||
	   (ttype == OMtokenEndObject));

  OMcheckStatus(OMBEgetType(dev, &foundTType));

  /* End of sharing scope (reset tables for get) */
  if (foundTType == OMtokenEndObject) {
    OMfreeInShareTables(STATE(dev));
  }

  if (foundTType == ttype) {
    CURRENTTYPE(dev) = OMtokenUnknown;
    return OMsuccess;
  }
  return OMfailed;
}


Lib OMstatus
OMBEgetComment(OMdev dev, char **comment, int *len)
{
    if (!dev->ignoreComments) {
        OMBEcheckType(dev, OMtokenComment);

        return OMBEgetRaw(dev, LENGTH(dev), comment, len, 1, "Cannot allocate new comment.", NULL, OMfalse);
    }
    return OMsuccess;
}


Module void
OMfreeInShareTable(OMBEinShareContextStruct * isc)
{
  OMBEshareStruct *table;

  int i, id;

  table = isc->shareTable;
  id = isc->nextId;
  for (i = 0; i < OM_BE_SHARETABLE_SZ && id; i++) {
    if (table[i].data) {
      OMfreeInternal(table[i].data);
      table[i].data = 0;
      id--;
      if (table[i].auxData) {
	OMfreeInternal(table[i].auxData);
	table[i].auxData = 0;
      }
    }
  }
  memset(isc->idToKey, 0, sizeof(isc->idToKey));
  isc->nextId = 0;
}

Module void
OMfreeInShareTables(OMbinState state)
{
  OMassert(state->encoding == OMencodingBinary);
  OMfreeInShareTable(&state->inShareContextVar);
  OMfreeInShareTable(&state->inShareContextStr);
  OMfreeInShareTable(&state->inShareContextSymb);
}

Module void
OMfreeOutShareTable(OMBEoutShareContextStruct * osc)
{
  OMBEshareStruct *table;
  int i, id;

  OMassert(osc);

  table = osc->shareTable;
  id = osc->nextId;
  for (i = 0; i < OM_BE_SHARETABLE_SZ && id; i++) {
    if (table[i].data) {
      OMfreeInternal(table[i].data);
      table[i].data = 0;
      id--;
      if (table[i].auxData) {
	OMfreeInternal(table[i].auxData);
	table[i].auxData = 0;
      }
    }
  }
  osc->nextId = 0;
}

Module void
OMfreeOutShareTables(OMbinState state)
{
  OMassert(state->encoding == OMencodingBinary);
  OMfreeOutShareTable(&state->outShareContextVar);
  OMfreeOutShareTable(&state->outShareContextStr);
  OMfreeOutShareTable(&state->outShareContextSymb);
}

Lib void
OMBEFreeTranslation(OMtranslationStruct * tr)
{
  OMfreeOutShareTables(tr->state);
  OMfreeInShareTables(tr->state);
  OMfreeInternal(tr->state);
  OMfreeInternal(tr);
}


Lib OMtranslation
OMbinEncoding(void)
{
  OMtranslation res;
  OMbinState state;

  res = OMmallocWarn(sizeof(OMtranslationStruct), "Cannot allocate new encoding structure.");
  memset(res, 0, sizeof(OMtranslationStruct));
  state = OMmallocWarn(sizeof(OMbinStateStruct), "Cannot allocate new encoding structure.");
  memset(state, 0, sizeof(OMbinStateStruct));

  res->encoding = OMencodingBinary;
  state->encoding = OMencodingBinary;

  /* encoding part */
  res->putInt32 = (OMputInt32Func) OMBEputInt32;
  res->putFloat64 = (OMputFloat64Func) OMBEputFloat64;
  res->putBigInt = (OMputBigIntFunc) OMBEputBigInt;
  res->putByteArray = (OMputByteArrayFunc) OMBEputByteArray;
  res->putString = (OMputStringFunc) OMBEputString;
  res->putWCString = (OMputWCStringFunc) OMBEputWCString;
  res->putVar = (OMputVarFunc) OMBEputVar;
  res->putSymbol = (OMputSymbolFunc) OMBEputSymbol;
  res->putTokenTag = (OMputTokenTagFunc) OMBEputTokenTag;
  res->putComment = (OMputCommentFunc) OMBEputComment;
  res->beginObject = (OMbeginObjectFunc) OMBEbeginObject;
  res->endObject = (OMendObjectFunc) OMBEendObject;

  /* decoding part */
  res->getInt32 = (OMgetInt32Func) OMBEgetInt32;
  res->getFloat64 = (OMgetFloat64Func) OMBEgetFloat64;
  res->getBigInt = (OMgetBigIntFunc) OMBEgetBigInt;
  res->getByteArray = (OMgetByteArrayFunc) OMBEgetByteArray;
  res->getString = (OMgetStringFunc) OMBEgetString;
  res->getWCString = (OMgetWCStringFunc) OMBEgetWCString;
  res->getVar = (OMgetVarFunc) OMBEgetVar;
  res->getSymbol = (OMgetSymbolFunc) OMBEgetSymbol;
  res->getTokenTag = (OMgetTokenTagFunc) OMBEgetTokenTag;
  res->getComment = (OMgetCommentFunc) OMBEgetComment;
  res->getType = (OMgetTypeFunc) OMBEgetType;
  res->getLength = (OMgetLengthFunc) OMBEgetLength;
  res->getSymbolLength = (OMgetSymbolLengthFunc) OMBEgetSymbolLength;

  state->currentType = OMtokenUnknown;
  res->state = state;

#if OM_DEBUG
  state->byte = 0;
#endif

  return res;
}
