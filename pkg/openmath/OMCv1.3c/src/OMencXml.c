/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/


/* 
 *        An XML-inspired "text" encoding for OpenMath
 *
 *
 * - OMtokenInt32: 
 *     <OMI>an int in base 10 or 16 (that may be stored on 32 bits)</OMI>
 * - OMtokenBigInt: 
 *     <OMI>an int in base 10 or 16 (too big to be stored on 32 bits)</OMI>
 * - OMtokenFloat64:  (64 bits floats)
 *     <OMF dec = f> where "f" is a decimal
 *     <OMF hex = f> where "f" is an hexadecimal 
 * - OMtokenSymbol:
 *     <OMS cd = "some string" name = "some string"> or
 *     <OMS name = "some string" cd = "some string">
 * - OMtokenByteArray:
 *     <OMB>byteArray</OMB>
 *     where byteArray is a base 64 encoded string of bytes
 * - OMtokenString:
 *     <OMSTR>some string encoded in utf7</OMSTR>
 * - OMtokenVar:
 *     <OMV name = "some string">
 * - OMtokenApp: ie application t0(t1, ... tn) 
 *     <OMAPP> t0 t1 ... tn </OMAPP> 
 *     where ti are OpenMath object
 * - OMtokenBind:
 * - OMtokenBVar: ie bind(o_binder, v0, v1...vn, o_bound) 
 *     <OMBIND> o_binder <OMBVAR> v0 v1 ... vn </OMNVAR> o_bound </OMAPP> 
 *     where vi are OpenMath variables
 *     and o_binder and o_bound are generic objects
 * - OMtokenAttr: 
 * - OMtokenAtp: 
 *     <OMATTR> <OMATP> s1 t1 ... sn tn </OMATP> e </OMATTR>
 *     where si ti are pairs of attributes (symbol object)
 *     and e the attributed object
 * - OMtokenError: 
 *     <OME> s t1... tn </OME>
 * - OMtokenCOmment:
 *     <!-- some comment -->
 *     comment must not contain the 2 char string "--"
 *
 */

#include "OMP.h"
#ifndef __CEXTRACT__
#include <math.h>		/* for strtod prototype on SUN */
#endif


/* prefered length for lines during byte Array output */
#define OMSE_BA_LINE_LEN 64
/* the maximum length of a 32-bit integer written in base 10 with the sign */
#define OMSE_MAX_INT32_LEN (1 + 10)
/* maximum size of a tag (eg <OMATTR>) */
#define OMSE_MAX_TAG_LEN 16
#define OMSE_MAX_SYMBOL_NAME_LEN 1024
#define OMSE_MAX_CD_NAME_LEN 1024


/* minimu size for internal buffers */
#define OMSE_MIN_BUF_LEN Max(Max(Max(OMSE_MAX_INT32_LEN, OMSE_MAX_TAG_LEN), OMSE_MAX_SYMBOL_NAME_LEN), OMSE_MAX_CD_NAME_LEN)

#define OMSE_MAX_INDENT (sizeof(OMspaceStr)-1)


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/*
 */
static OMstatus OMSEprintIndented(OMdev dev, char *str, int incr);
static void OMSEswitchBuf(OMXmlState state);
static int OMSEbufNewSize(int size);
static OMbool OMSEbufNeedWC(OMdev dev);
static OMstatus OMSEcopyBuf(OMdev dev, char **data, int *len, int step, int shift, OMbool wc);
static OMbool OMSEisTagChar(char c);
static OMbool OMSEisSeparator(char c);
static OMstatus OMSEparseSeparator(OMdev dev);
/* if the current character is '>' we skip it
 * else we leave it and return */
static OMstatus OMSEparseClosing(OMdev dev);
static OMstatus OMSEparseQuote(OMdev dev);
static OMstatus OMSEparseEqual(OMdev dev);
static OMstatus OMSEparseKnownString(OMdev dev, char *str);
static OMstatus OMSEparseQuotedString(OMdev dev);
static OMstatus OMSEparseOneLine(OMdev dev, OMbool * end);
static OMstatus OMSEparseInt32Base10(OMdev dev);
static OMstatus OMSEparseInt32Base16(OMdev dev);
static OMstatus OMSEparseFloat64Hex(OMdev dev);
static OMstatus OMSEparseFloat64Dec(OMdev dev);
static OMstatus OMSEparseFloat64(OMdev dev);
static OMstatus OMSEparseBigInt(OMdev dev);
static OMstatus OMSEparseByteArray(OMdev dev);
static OMstatus OMSEparseIntBase10(OMdev dev, OMtokenType * type);
static OMstatus OMSEparseIntBase16(OMdev dev, OMtokenType * type);
static OMstatus OMSEparseInt(OMdev dev, OMtokenType * type);
static OMstatus OMSEparseVar(OMdev dev);
static OMstatus OMSEparseSymbol(OMdev dev);
static OMstatus OMSEparseComment(OMdev dev);
static OMstatus OMSEparseTagAux(OMdev dev, OMtokenType * type);
static OMstatus OMSEparseTag(OMdev dev, OMtokenType * type);
static OMstatus OMSEparseToken(OMdev dev, OMtokenType * type);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */

/* used for fast indentation */
static char OMspaceStr[] = "                                                                                                                                ";

#define PRINT(Dev, S)      (*(Dev->io->print))(Dev, S)
#define WRITE(Dev, S, N)   (*(Dev->io->write))(Dev, S, N)
#define READ(Dev, Buff, N) (*(Dev->io->read))(Dev, Buff, N)
#define LOOKAHEAD(Dev)     (*(Dev->io->lookAhead))(Dev)
#define GETCHAR(Dev)       (*(Dev->io->getChar))(Dev)
#define PUTCHAR(Dev, C)    (*(Dev->io->putChar))(Dev, C)
#define STATE(Dev)         ((OMXmlState)Dev->translation->state)
#define CURRENTTYPE(Dev)   (STATE(Dev)->currentType)
#define BUF(Dev)           (STATE(Dev)->buf)
#define BUFUSED(Dev)       (STATE(Dev)->bufUsed)
#define BUFSIZE(Dev)       (STATE(Dev)->bufSize)
#define BUFAUX(Dev)        (STATE(Dev)->bufAux)
#define BUFAUXUSED(Dev)    (STATE(Dev)->bufAuxUsed)
#define BUFAUXSIZE(Dev)    (STATE(Dev)->bufAuxSize)
#if OM_DEBUG
#define LINE(Dev)          (STATE(Dev)->line)
#endif

#if OM_DEBUG
#define OMSEcheckType(Dev,Type) \
{ \
  OMtokenType _ftype; \
  OMcheckStatus(OMSEgetType(Dev, &_ftype)); \
  if (_ftype != (Type)) { \
    OMprintf(OMwarnLevel, "line %d: looking for '%s' token but found '%s'.\n", LINE(Dev), OMtokenTypeToString(Type),OMtokenTypeToString(_ftype)); \
  return OMmalformedInput; \
  } \
}
#else
#define OMSEcheckType(Dev,Type) \
{ \
  OMtokenType _ftype; \
  OMcheckStatus(OMSEgetType(Dev, &_ftype)); \
  if (_ftype != (Type)) { \
    return OMfailed; \
  } \
}
#endif

#if OM_DEBUG
#define OMSEcheckStringType(Dev) \
{ \
  OMtokenType _ftype; \
  OMcheckStatus(OMSEgetType(Dev, &_ftype)); \
  if ((_ftype != OMtokenString) && (_ftype != OMtokenWCString)) { \
    OMprintf(OMwarnLevel, "line %d: looking for '%s' or '%s' token but found '%s'.\n", LINE(Dev), OMtokenTypeToString(OMtokenString), OMtokenTypeToString(OMtokenWCString), OMtokenTypeToString(_ftype)); \
  return OMmalformedInput; \
  } \
}
#else
#define OMSEcheckStringType(Dev) \
{ \
  OMtokenType _ftype; \
  OMcheckStatus(OMSEgetType(Dev, &_ftype)); \
  if ((_ftype != OMtokenString) && (_ftype != OMtokenWCString)) { \
    return OMfailed; \
  } \
}
#endif


/*
 */
Module OMstatus
OMSEprintIndented(OMdev dev, char *str, int incr)
{
  int l;

  OMassert(dev);
  OMassert(str);

  if (STATE(dev)->indentMode == OMindentNone) {
    OMcheckStatus(PRINT(dev, str));
  }
  else {
    if (incr < 0) {
      STATE(dev)->indentLevel += incr;
    }
    if ((l = Min(OMSE_MAX_INDENT, STATE(dev)->indentTab * STATE(dev)->indentLevel))) {
      OMcheckStatus(PRINT(dev, OMspaceStr + OMSE_MAX_INDENT - l));
    }
    if (str[0]) {
      OMcheckStatus(PRINT(dev, str));
    }
    if (incr > 0) {
      STATE(dev)->indentLevel += incr;
    }
  }
  return OMsuccess;
}

 /* These functions are to be used inside the "put" structure in the device */
Lib OMstatus
OMSEputInt32(OMdev dev, int i)
{
  /* +11 for <OMI> </OMI>, + 3 is for -,\n,\0 */
  char str[OMSE_MAX_INT32_LEN + 11 + 3];

  OMassert(dev);

  sprintf(str, "<OMI>%d</OMI>\n", i);
  OMcheckStatus(OMSEprintIndented(dev, str, 0));
  return OMsuccess;
}

Lib OMstatus
OMSEputFloat64(OMdev dev, double *d)
{
  char str[sizeof(double) * 2 + 2];
  double dc;

  OMassert(dev);

  OMcheckStatus(OMSEprintIndented(dev, "<OMF hex=\"", 0));

  if (!OMlittleEndianMode) {
    dc = OMdoubleBE2LE(*d);
  }
  else {
    dc = *d;
  }
  OMto16((char *) &dc, sizeof(double), str);
  str[sizeof(double) * 2] = '"';
  str[sizeof(double) * 2 + 1] = '\0';
  OMcheckStatus(PRINT(dev, str));
  OMcheckStatus(PRINT(dev, "/>\n"));
  return OMsuccess;
}

Lib OMstatus
OMSEputBigInt(OMdev dev, char *data, int len, int sign, OMbigIntType format)
{
  OMassert(dev);
  OMassert(data);
  OMassert(len >= 0);

#if OM_DEBUG
  if ((format != OMbigIntBase10) && (format != OMbigIntBase16)) {
    OMfatalInternal(OMnotImplemented, "Can only output integers in base 10 or 16.\n");
  }
  if ((*data == '+') || (*data == '-')) {
    OMprintf(OMwarnLevel, "Warning: You left the sign character '%c' in the body of this bigInt. This is not legal!\n", *data);
  }
#endif /* OM_DEBUG */

  if ((sign) < 0) {
    OMcheckStatus(OMSEprintIndented(dev, "<OMI>-", 0));
  }
  else {
    OMcheckStatus(OMSEprintIndented(dev, "<OMI>", 0));
  }
  if (format == OMbigIntBase16) {
    OMcheckStatus(PUTCHAR(dev, 'x'));
  }
  WRITE(dev, data, len);
  OMcheckStatus(PRINT(dev, "</OMI>\n"));
  return OMsuccess;
}

Lib OMstatus
OMSEputByteArray(OMdev dev, char *data, int len)
{
  char buffer[10 * OMSE_BA_LINE_LEN + 5];
  int chunckSize;

  OMassert(dev);
  OMassert(data);
  OMassert(len >= 0);

  chunckSize = (OMSE_BA_LINE_LEN * 3) / 4;
  OMcheckStatus(OMSEprintIndented(dev, "<OMB>", 0));
  while (len > 0) {
    OMto64(data, Min(chunckSize, len), buffer);
#if OM_DEBUG
    {
      char *pb;
      pb = buffer;
      while (*pb) {
	if (!OMIsB64Char(*pb)) {
	  OMprintf(OMwarnLevel, "Internal error: Found illegal character '%c' in base 64 encoding.\n", *pb);
	  OMto64(data, Min(chunckSize, len), buffer);
	}
	pb++;
      }
    }
#endif
    data += chunckSize;
    len -= chunckSize;
    OMcheckStatus(PRINT(dev, buffer));
    OMcheckStatus(PRINT(dev, "\n"));
  }
  OMcheckStatus(OMSEprintIndented(dev, "</OMB>\n", 0));
  return OMsuccess;
}


Lib OMstatus
OMSEputString(OMdev dev, char *str, int len)
{
  OMassert(dev);
  OMassert(str);
  OMassert(len > 0);

  OMcheckStatus(OMSEprintIndented(dev, "<OMSTR>", 0));
  OMcheckStatus(OMputCharAsUTF7(dev, str, len));
  OMcheckStatus(PRINT(dev, "</OMSTR>\n"));
  return OMsuccess;
}

Lib OMstatus
OMSEputWCString(OMdev dev, OMUCS2 * wcstr, int len)
{
  OMassert(dev);
  OMassert(wcstr);
  OMassert(len > 0);

  OMcheckStatus(OMSEprintIndented(dev, "<OMSTR>", 0));
  OMcheckStatus(OMputUCS2AsUTF7(dev, wcstr, len));
  OMcheckStatus(PRINT(dev, "</OMSTR>\n"));
  return OMsuccess;
}

Lib OMstatus
OMSEputVar(OMdev dev, char *var, int len)
{
  OMassert(dev);
  OMassert(var);
  OMassert(len > 0);

  OMcheckStatus(OMSEprintIndented(dev, "<OMV name=\"", 0));
  OMcheckStatus(WRITE(dev, var, len));
  OMcheckStatus(PRINT(dev, "\""));
  OMcheckStatus(PRINT(dev, "/>\n"));
  return OMsuccess;
}

Lib OMstatus
OMSEputSymbol(OMdev dev, char *cd, int clen, char *name, int nlen)
{
  OMassert(dev);
  OMassert(cd);
  OMassert(name);
  OMassert(clen > 0);
  OMassert(nlen > 0);

  OMcheckStatus(OMSEprintIndented(dev, "<OMS cd=\"", 0));
  OMcheckStatus(WRITE(dev, cd, clen));
  OMcheckStatus(PRINT(dev, "\" name=\""));
  OMcheckStatus(WRITE(dev, name, nlen));
  OMcheckStatus(PRINT(dev, "\""));
  OMcheckStatus(PRINT(dev, "/>\n"));
  return OMsuccess;
}

Lib OMstatus
OMSEputTokenTag(OMdev dev, OMtokenType ttype)
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

  switch (ttype) {
  case OMtokenApp:
    return OMSEprintIndented(dev, "<OMA>\n", 1);
    break;
  case OMtokenEndApp:
    return OMSEprintIndented(dev, "</OMA>\n", -1);
    break;
  case OMtokenAttr:
    return OMSEprintIndented(dev, "<OMATTR>\n", 1);
    break;
  case OMtokenEndAttr:
    return OMSEprintIndented(dev, "</OMATTR>\n", -1);
    break;
  case OMtokenAtp:
    return OMSEprintIndented(dev, "<OMATP>\n", 1);
    break;
  case OMtokenEndAtp:
    return OMSEprintIndented(dev, "</OMATP>\n", -1);
    break;
  case OMtokenBind:
    return OMSEprintIndented(dev, "<OMBIND>\n", 1);
    break;
  case OMtokenEndBind:
    return OMSEprintIndented(dev, "</OMBIND>\n", -1);
    break;
  case OMtokenBVar:
    return OMSEprintIndented(dev, "<OMBVAR>\n", 1);
    break;
  case OMtokenEndBVar:
    return OMSEprintIndented(dev, "</OMBVAR>\n", -1);
    break;
  case OMtokenError:
    return OMSEprintIndented(dev, "<OME>\n", 1);
    break;
  case OMtokenEndError:
    return OMSEprintIndented(dev, "</OME>\n", -1);
    break;
  case OMtokenObject:
    return OMSEprintIndented(dev, "<OMOBJ>\n", 1);
    break;
  case OMtokenEndObject:
    return OMSEprintIndented(dev, "</OMOBJ>\n", -1);
    break;
  default:
    OMIE;
    return OMfailed;
  }
}

Lib OMstatus
OMSEputComment(OMdev dev, char *comment, int len)
{
  OMassert(dev);
  OMassert(comment);
  OMassert(len > 0);

  OMcheckStatus(OMSEprintIndented(dev, "<!--", 0));
  OMcheckStatus(WRITE(dev, comment, len));
  OMcheckStatus(PRINT(dev, "-->\n"));

  return OMsuccess;
}


Lib OMstatus
OMSEbeginObject(OMdev dev)
{
  OMassert(dev);
  return OMsuccess;
}

Lib OMstatus
OMSEendObject(OMdev dev)
{
  OMassert(dev);
  return (*(dev->io->flush)) (dev);
}






Module void
OMSEswitchBuf(OMXmlState state)
{
  OMassert(state);

  OMswap(state->buf, state->bufAux, char *);
  OMswap(state->bufSize, state->bufAuxSize, int);
  OMswap(state->bufUsed, state->bufAuxUsed, int);
}

Module int
OMSEbufNewSize(int size)
{
  OMassert(size >= 0);

  if (size) {
    return 2 * size;
  }
  else {
    return OMSE_MIN_BUF_LEN;
  }
}

Lib OMstatus
OMSEreallocBuf(OMXmlState state)
{
  int newSize;
  char *new;

  OMassert(state);

  newSize = OMSEbufNewSize(state->bufSize);
  new = OMreallocWarn(state->buf, newSize, "Cannot realloc xml encoding internal buffer.");
  if (!new)
    return OMnoMem;
  /* we don't change state->bufUsed, of course */
  state->buf = new;
  state->bufSize = newSize;
  return OMsuccess;
}

Module OMbool
OMSEbufNeedWC(OMdev dev)
{
  OMUCS2 *ptr;

  OMassert(dev);
  ptr = (OMUCS2 *) BUF(dev);
  while (*ptr) {
    if ((*ptr) & 0xff00)
      return OMtrue;
    ptr++;
  }
  return OMfalse;
}

Module OMstatus
OMSEcopyBuf(OMdev dev, char **data, int *len, int step, int shift, OMbool wc)
{
  OMbool copyZero;
  int i, l;
  char *ptr;

  OMassert(dev);
  OMassert(data);
  OMassert(step > 0);

  l = (BUFUSED(dev) / step);

  if (!(*data)) {
    *data = OMmallocWarn(l + ((wc) ? 2 : 1), "Cannot allocate new buffer.");
    copyZero = OMtrue;
  }
  else {
    OMassert(len);

    if (*len < l) {
#if OM_DEBUG
      memset(*data, '?', (Min(*len, OM_WARN_DATA_LEN)));
      OMprintf(OMwarnLevel, "Given buffer is too small (given %d byte%s, needed %d).\n", *len, (*len > 1) ? "s" : "", l);
#endif /* OM_DEBUG */
      *len = l;
      return OMnoMem;
    }
    else {
      copyZero = ((*len >= l + ((wc) ? 2 : 1))) ? OMtrue : OMfalse;
    }
  }
  if (step == 1) {
    OMassert(shift == 0);	/* no shift if all bytes have to be copied */
    memcpy(*data, BUF(dev), l);
    if (copyZero) {
      ptr = (*data) + l;
      *ptr = 0;
      if (wc) {
	*(ptr + 1) = 0;
      }
    }
  }
  else {
    ptr = *data;
    for (i = shift; i < BUFUSED(dev); i += step) {
      *ptr = BUF(dev)[i];
      ptr++;
    }
    if (copyZero) {
      *ptr = '\0';
      if (wc)
	*(ptr + 1) = '\0';
    }
  }
  if (len) {
    if (wc) {
      *len = l / 2;
    }
    else {
      *len = l;
    }
  }
  return OMsuccess;
}

Module OMbool
OMSEisTagChar(char c)
{
  return (isalnum(c) || (c == '/') || (c == '!') || (c == '-'));
}

Module OMbool
OMSEisSeparator(char c)
{
  if ((c == ' ') || (c == '\t') || (c == '\n') || (c == '\r')) {
    return OMtrue;
  }
  return OMfalse;
}

Module OMstatus
OMSEparseSeparator(OMdev dev)
{
  char c;

  OMassert(dev);

  while (1) {
    c = LOOKAHEAD(dev);
    if ((c == ' ') || (c == '\t')) {
    }
    else if ((c == '\n') || (c == '\r')) {
#if OM_DEBUG
      LINE(dev)++;
#endif /* OM_DEBUG */
    }
    else {
      break;
    }
    GETCHAR(dev);
  }
  return OMsuccess;
}

/* if the current character is '>' we skip it
 * else we leave it and return */
Module OMstatus
OMSEparseClosing(OMdev dev)
{
  char c;

  OMassert(dev);

  OMcheckStatus(OMSEparseSeparator(dev));
  if ((c = LOOKAHEAD(dev)) == '>') {
    GETCHAR(dev);
    return OMsuccess;
  }
  else if ((c == '/') && (GETCHAR(dev)) && (c = LOOKAHEAD(dev)) == '>') {
    GETCHAR(dev);
    return OMsuccess;
  }
  else {
#if OM_DEBUG
    OMprintf(OMwarnLevel, "line %d: Missing closing '>' for token %s.\n", LINE(dev), OMtokenTypeToString(CURRENTTYPE(dev)));
#endif /* OM_DEBUG */
    return OMmalformedInput;
  }
}


Module OMstatus
OMSEparseQuote(OMdev dev)
{
  char c;
  OMassert(dev);

  OMcheckStatus(OMSEparseSeparator(dev));
  c = LOOKAHEAD(dev);
  if (c == '"') {
    GETCHAR(dev);
    return OMsuccess;
  }
  else {
#if OM_DEBUG
    OMprintf(OMwarnLevel, "line %d: Missing '\"' for token %s. (found '%c'(%d) instead.)\n", LINE(dev), OMtokenTypeToString(CURRENTTYPE(dev)), c, c);
#endif /* OM_DEBUG */
    return OMmalformedInput;
  }
}

Module OMstatus
OMSEparseEqual(OMdev dev)
{
  char c;

  OMassert(dev);

  OMcheckStatus(OMSEparseSeparator(dev));
  c = GETCHAR(dev);
  if (c != '=') {
#if OM_DEBUG
    OMprintf(OMwarnLevel, "line %d: While looking for '=' found '%c'(%d).\n", LINE(dev), c, c);
#endif /* OM_DEBUG */
    return OMmalformedInput;
  }
  OMcheckStatus(OMSEparseSeparator(dev));
  return OMsuccess;
}

Module OMstatus
OMSEparseKnownString(OMdev dev, char *str)
{
  char c, *p;

  OMassert(dev);
  OMassert(str);

  p = str;
  while (*p) {
    c = GETCHAR(dev);
    if (c != *p) {
#if OM_DEBUG
      OMprintf(OMwarnLevel, "line %d: While looking for \"%s\", found '%c'(%d) instead of '%c'.\n", LINE(dev), str, c, c, *p);
#endif /* OM_DEBUG */
      return OMmalformedInput;
    }
    p++;
  }
  return OMsuccess;
}

Module OMstatus
OMSEparseQuotedString(OMdev dev)
{
  int l, i = 0;
  char *buf, c;

  OMassert(dev);

  OMcheckStatus(OMSEparseSeparator(dev));

  if ((c = LOOKAHEAD(dev)) == '"') {
    GETCHAR(dev);
  }
  else {
#if OM_DEBUG
    OMprintf(OMwarnLevel, "line %d: Reading a quoted string but can't find a '\"' (found '%c'(%d) instead).\n", LINE(dev), c, c);
#endif /* OM_DEBUG */
    return OMmalformedInput;
  }

  /* while we don't see a " */
  buf = BUF(dev);
  l = BUFSIZE(dev) - 1;		/* -1 to reserve room for last ]\0] */
  while (LOOKAHEAD(dev) != '"') {
    if (i == l) {
      OMcheckStatus(OMSEreallocBuf(STATE(dev)));
      buf = BUF(dev);
      l = BUFSIZE(dev) - 1;
    }
    buf[i] = GETCHAR(dev);
    i++;
  }

  buf[i] = '\0';
  BUFUSED(dev) = i;

  /* eat '"' */
  GETCHAR(dev);

  return OMsuccess;
}

Module OMstatus
OMSEparseOneLine(OMdev dev, OMbool * end)
{
  int l, i = 0;
  char *buf, c;

  OMassert(dev);
  OMassert(end);

  OMcheckStatus(OMSEparseSeparator(dev));

  buf = BUF(dev);
  l = BUFSIZE(dev) - 1;
  while (OMtrue) {
    c = LOOKAHEAD(dev);
    if (c == '<') {
      *end = OMtrue;
      break;
    }
    else if ((c == '\n') || (c == '\r')) {
      *end = OMfalse;
#if OM_DEBUG
      LINE(dev)++;
#endif /* OM_DEBUG */
      break;
    }
    else if (c == ' ') {
      *end = OMfalse;
      break;
    }

    if (i == l) {
      OMcheckStatus(OMSEreallocBuf(STATE(dev)));
      buf = BUF(dev);
      l = BUFSIZE(dev) - 1;
    }
    buf[i] = GETCHAR(dev);
    i++;
  }
  buf[i] = '\0';
  BUFUSED(dev) = i;

  return OMsuccess;
}

Module OMstatus
OMSEparseInt32Base10(OMdev dev)
{
  int i;

  OMassert(dev);

  i = atoi(BUF(dev));
  if (STATE(dev)->sign < 0)
    i = -i;
  STATE(dev)->i = i;
  OMcheckStatus(OMSEparseSeparator(dev));
  OMcheckStatus(OMSEparseKnownString(dev, "</OMI>"));
  return OMsuccess;
}

Module OMstatus
OMSEparseInt32Base16(OMdev dev)
{
  unsigned int i;

  OMassert(dev);

  if (!sscanf(BUF(dev), "%x", &i)) {
    return OMmalformedInput;
  }
  if (STATE(dev)->sign < 0)
    STATE(dev)->i = -((int) i);
  else
    STATE(dev)->i = (int) i;
  OMcheckStatus(OMSEparseSeparator(dev));
  OMcheckStatus(OMSEparseKnownString(dev, "</OMI>"));
  return OMsuccess;
}

Module OMstatus
OMSEparseFloat64Hex(OMdev dev)
{
  char buffer[sizeof(double) * 2];
  double d;
  OMassert(dev);

  OMcheckStatus(READ(dev, buffer, sizeof(double) * 2));
  OMcheckStatus(OMfrom16(buffer, sizeof(double) * 2, (char *) &d));
  if (!OMlittleEndianMode) {
    d = OMdoubleLE2BE(d);
  }
  STATE(dev)->d = d;
  return OMsuccess;
}

Module OMstatus
OMSEparseFloat64Dec(OMdev dev)
{
  int i, l;
  char *buf, *endPtr, c;

  OMassert(dev);
  buf = BUF(dev);
  l = BUFSIZE(dev) - 1;		/* -1 to reserve room for last '\0' */
  i = 0;
  while (!OMSEisSeparator(c = LOOKAHEAD(dev)) && (c != '"')) {
    if (i == l) {
      OMcheckStatus(OMSEreallocBuf(STATE(dev)));
      buf = BUF(dev);
      l = BUFSIZE(dev) - 1;
    }
    buf[i] = GETCHAR(dev);
    i++;
  }
  buf[i] = '\0';
  if ((*buf == 'I') && (EQSTRING(buf, "Infinity"))) {
    STATE(dev)->d = OMdoubleInf;
  }
  else if ((*buf == 'N') && (EQSTRING(buf, "NaN"))) {
    STATE(dev)->d = OMdoubleLocalNaN;
  }
  else if ((*buf == '-') && (EQSTRING(buf, "-Infinity"))) {
    STATE(dev)->d = OMdoubleNegInf;
  }
  else {
    STATE(dev)->d = strtod(buf, &endPtr);
    if (endPtr == buf) {
#if OM_DEBUG
      OMprintf(OMwarnLevel, "line %d: Reading a float in decimal form but can't parse it (%s).\n", LINE(dev), buf);
#endif /* OM_DEBUG */
      return OMmalformedInput;
    }
  }
  return OMsuccess;
}

Module OMstatus
OMSEparseFloat64(OMdev dev)
{
  char c;

  OMassert(dev);

  OMcheckStatus(OMSEparseSeparator(dev));
  c = LOOKAHEAD(dev);
  switch (c) {
  case 'h':
    OMcheckStatus(OMSEparseKnownString(dev, "hex"));
    OMcheckStatus(OMSEparseEqual(dev));
    OMcheckStatus(OMSEparseQuote(dev));
    OMcheckStatus(OMSEparseSeparator(dev));
    OMcheckStatus(OMSEparseFloat64Hex(dev));
    OMcheckStatus(OMSEparseQuote(dev));
    break;
  case 'd':
    OMcheckStatus(OMSEparseKnownString(dev, "dec"));
    OMcheckStatus(OMSEparseEqual(dev));
    OMcheckStatus(OMSEparseQuote(dev));
    OMcheckStatus(OMSEparseSeparator(dev));
    OMcheckStatus(OMSEparseFloat64Dec(dev));
    OMcheckStatus(OMSEparseQuote(dev));
    break;
  default:
#if OM_DEBUG
    OMprintf(OMwarnLevel, "line %d: Reading a float but can't find either \"hex\" or \"dec\".\n", LINE(dev));
#endif /* OM_DEBUG */
    return OMmalformedInput;
  }
  OMcheckStatus(OMSEparseClosing(dev));
  return OMsuccess;
}


Module OMstatus
OMSEparseBigInt(OMdev dev)
{
  int l, i = 0;
  char *buf, c;

  OMassert(dev);

  i = BUFUSED(dev);
  buf = BUF(dev);
  l = BUFSIZE(dev) - 1;		/* -1 to reserve room for trailing \0 */
  while (1) {
    c = LOOKAHEAD(dev);
    if (OMSEisSeparator(c) || (c == '<')) {
      break;
    }
#if OM_DEBUG
    if (STATE(dev)->format == OMbigIntBase16) {
      if (!isxdigit(c)) {
	OMprintf(OMwarnLevel, "line %d: Reading a base 16 big int but found non hexadecimal digit character '%c'(%d).\n", LINE(dev), c, c);
	return OMmalformedInput;
      }
    }
    else if (STATE(dev)->format == OMbigIntBase10) {
      if (!isdigit(c)) {
	OMprintf(OMwarnLevel, "line %d: Reading a base 10 big int but found non decimal digit character '%c'(%d).\n", LINE(dev), c, c);
	return OMmalformedInput;
      }
    }
#endif /* OM_DEBUG */

    if (i == l) {
      OMcheckStatus(OMSEreallocBuf(STATE(dev)));
      buf = BUF(dev);
      l = BUFSIZE(dev) - 1;
    }
    buf[i] = GETCHAR(dev);
    i++;
  }

  buf[i] = '\0';
  BUFUSED(dev) = i;
  OMcheckStatus(OMSEparseSeparator(dev));
  OMcheckStatus(OMSEparseKnownString(dev, "</OMI>"));
  return OMsuccess;
}

Module OMstatus
OMSEparseByteArray(OMdev dev)
{
  OMbool end = OMfalse;
  int len = 0, chunckLen;
  char *decoded;

  OMassert(dev);

  while (!end) {
    decoded = BUFAUX(dev) + len;
    OMcheckStatus(OMSEparseOneLine(dev, &end));
    if (len + ((BUFUSED(dev) * 3) / 4) >= BUFAUXSIZE(dev)) {
      OMSEswitchBuf(STATE(dev));
      OMcheckStatus(OMSEreallocBuf(STATE(dev)));
      OMSEswitchBuf(STATE(dev));
      decoded = BUFAUX(dev) + len;
    }
    OMcheckStatus(OMfrom64(BUF(dev), BUFUSED(dev), decoded, &chunckLen));
    len += chunckLen;
    BUFAUXUSED(dev) = len;
  }
  OMSEswitchBuf(STATE(dev));
  return OMsuccess;
}


Module OMstatus
OMSEparseIntBase10(OMdev dev, OMtokenType * type)
{
  OMtokenType ftype;
  OMXmlState state = STATE(dev);
  char *b = BUF(dev);
  int i, nbdigits, v;

  /* "INT32_ENCOD_LEN - 1" because OMSE_MAX_INT32_LEN includes the sign */
  for (i = 0; isdigit(LOOKAHEAD(dev)) && i < OMSE_MAX_INT32_LEN - 1; i++) {
    b[i] = GETCHAR(dev);
  }
  BUFUSED(dev) = i;

  /* is it a big or a 32bit int? */
  if (i == OMSE_MAX_INT32_LEN - 1) {
    /* we stop because too big for a 32 bit int */
    ftype = OMtokenBigInt;
  }
  else {
    b[i] = '\0';
    nbdigits = i + 1;
    /* check if not too big to be stored in a 32bits int */
    if (nbdigits < OMSE_MAX_INT32_LEN - 1) {
      /* the simple case */
      ftype = OMtokenInt32;
    }
    else {
      /* must check more thoroughly if in range
       * [ -2147483648 .. 2147483647 ] */
      v = strncmp("214748364", b, 9);
      if (v < 0) {
	ftype = OMtokenInt32;
      }
      else if (v > 0) {
	ftype = OMtokenBigInt;
      }
      else {
	/* check last digit */
	if (b[9] <= '7') {
	  ftype = OMtokenInt32;
	}
	else {
	  if ((state->sign == -1) && (b[9] == '8')) {
	    ftype = OMtokenInt32;
	  }
	  else {
	    ftype = OMtokenBigInt;
	  }
	}
      }
    }
  }

  /* du the real parsing of int32 or bigInt */
  *type = ftype;
  if (ftype == OMtokenBigInt) {
    OMcheckStatus(OMSEparseBigInt(dev));
  }
  else {
    OMcheckStatus(OMSEparseInt32Base10(dev));
  }
  return OMsuccess;
}


Module OMstatus
OMSEparseIntBase16(OMdev dev, OMtokenType * type)
{
  OMXmlState state = STATE(dev);
  char c, *b = BUF(dev);
  int i;

  i = 0;
  while ((i <= 8) && isxdigit(c = LOOKAHEAD(dev))) {
    b[i] = GETCHAR(dev);
    i++;
  }
  BUFUSED(dev) = i;

#if OM_DEBUG
  if (!isxdigit(c) && !(OMSEisSeparator(c) || (c == '<'))) {
    OMprintf(OMwarnLevel, "line %d: Reading a base 16 int but found non hexadecimal digit character '%c'(%d).\n", LINE(dev), c, c);
    return OMmalformedInput;
  }
#endif /* OM_DEBUG */

  /* is it a big or a 32bit int? 
   * ie: more than 8 nibbles or 
   * 8 nibbles but with first bit set (sign used so this is in fact a 33 bit int) */
  if ((i > 8) || ((i == 8) && (b[0] >= '8'))) {
    /* too big for a 32 bit int */
    *type = OMtokenBigInt;
    OMcheckStatus(OMSEparseBigInt(dev));
  }
  else {
    b[i] = '\0';
    *type = OMtokenInt32;
    OMcheckStatus(OMSEparseInt32Base16(dev));
  }
  return OMsuccess;
}


Module OMstatus
OMSEparseInt(OMdev dev, OMtokenType * type)
{
  OMXmlState state = STATE(dev);
  int c;

  OMassert(dev);
  OMassert(type);

  OMcheckStatus(OMSEparseClosing(dev));
  OMcheckStatus(OMSEparseSeparator(dev));
  c = LOOKAHEAD(dev);
  if (c == '-') {
    state->sign = -1;
    GETCHAR(dev);
  }
  else {
    state->sign = 1;
  }

  c = LOOKAHEAD(dev);
  if (c == 'x') {
    state->format = OMbigIntBase16;
    GETCHAR(dev);
    return OMSEparseIntBase16(dev, type);
  }
  else if (isdigit(c)) {
    state->format = OMbigIntBase10;
    return OMSEparseIntBase10(dev, type);
  }
  else {
#if OM_DEBUG
    OMprintf(OMwarnLevel, "line %d: Trying to parse an int but found a strange character '%c'(%d)!\n", LINE(dev), c, c);
#endif /* OM_DEBUG */
    return OMmalformedInput;
  }
}


Module OMstatus
OMSEparseVar(OMdev dev)
{
  OMassert(dev);

  OMcheckStatus(OMSEparseSeparator(dev));
  OMcheckStatus(OMSEparseKnownString(dev, "name"));
  OMcheckStatus(OMSEparseEqual(dev));
  OMcheckStatus(OMSEparseQuotedString(dev));
  OMcheckStatus(OMSEparseClosing(dev));
  return OMsuccess;
}

Module OMstatus
OMSEparseSymbol(OMdev dev)
{
  char c;

  OMassert(dev);

  OMcheckStatus(OMSEparseSeparator(dev));
  c = LOOKAHEAD(dev);
  switch (c) {
  case 'n':
    OMcheckStatus(OMSEparseKnownString(dev, "name"));
    OMcheckStatus(OMSEparseEqual(dev));
    OMcheckStatus(OMSEparseQuotedString(dev));
    OMSEswitchBuf(STATE(dev));
    OMcheckStatus(OMSEparseSeparator(dev));
    OMcheckStatus(OMSEparseKnownString(dev, "cd"));
    OMcheckStatus(OMSEparseEqual(dev));
    OMcheckStatus(OMSEparseQuotedString(dev));
    break;
  case 'c':
    OMcheckStatus(OMSEparseKnownString(dev, "cd"));
    OMcheckStatus(OMSEparseEqual(dev));
    OMcheckStatus(OMSEparseQuotedString(dev));
    OMSEswitchBuf(STATE(dev));
    OMcheckStatus(OMSEparseSeparator(dev));
    OMcheckStatus(OMSEparseKnownString(dev, "name"));
    OMcheckStatus(OMSEparseEqual(dev));
    OMcheckStatus(OMSEparseQuotedString(dev));
    OMSEswitchBuf(STATE(dev));
    break;
  default:
#if OM_DEBUG
    OMprintf(OMwarnLevel, "line %d: Reading a symbol but can't find either \"cd\" or \"name\".\n", LINE(dev));
#endif /* OM_DEBUG */
    return OMmalformedInput;
  }
  OMcheckStatus(OMSEparseClosing(dev));
  return OMsuccess;
}

Module OMstatus
OMSEparseComment(OMdev dev)
{
  OMbool inDash = OMfalse;
  int l, i = 0;
  char *buf, c;

  OMassert(dev);

  buf = BUF(dev);
  l = BUFSIZE(dev) - 1;		/* -1 to reserve room for last \0 */
  while (1) {
    c = LOOKAHEAD(dev);
    if (c == '-') {
      if (inDash) {
	GETCHAR(dev);
	break;
      }
      inDash = OMtrue;
    }
    else {
      inDash = OMfalse;
    }

    if (i == l) {
      OMcheckStatus(OMSEreallocBuf(STATE(dev)));
      buf = BUF(dev);
      l = BUFSIZE(dev) - 1;
    }
    buf[i] = GETCHAR(dev);
    i++;
  }

  /* last char is a '-' skip it */
  i--;
  buf[i] = '\0';
  BUFUSED(dev) = i + 1;
  OMcheckStatus(OMSEparseClosing(dev));
  return OMsuccess;
}

Module OMstatus
OMSEparseTagAux(OMdev dev, OMtokenType * type)
{
  char tag[OMSE_MAX_TAG_LEN + 1];
  int l, c;

  OMassert(dev);
  OMassert(type);

  *type = OMtokenUnknown;

  for (l = 0; OMSEisTagChar(LOOKAHEAD(dev)) && (l < OMSE_MAX_TAG_LEN); l++) {
    c = GETCHAR(dev);
    if (c == EOF) {
#if OM_DEBUG
      OMprintf(OMwarnLevel, "line %d: Reading a tag <?> but it seems to be truncated. Device is empty?...\n", LINE(dev));
#endif /* OM_DEBUG */
      return OMemptyIO;
    }
    tag[l] = c;
  }
  if (l >= OMSE_MAX_TAG_LEN) {
#if OM_DEBUG
    tag[OMSE_MAX_TAG_LEN] = '\0';
    OMprintf(OMwarnLevel, "line %d: Reading a tag <?> but it seems to be too long to be legal. Head of erroneous tag is \"%s\"...\n", LINE(dev), tag);
#endif /* OM_DEBUG */
    return OMmalformedInput;
  }

  tag[l] = '\0';

  switch (tag[0]) {
  case 'O':
    if (tag[1] != 'M') {
      return OMmalformedInput;
    }
    switch (tag[2]) {
    case 'A':
      if (l == 3) {		/* OMA */
	*type = OMtokenApp;
	return OMSEparseClosing(dev);
      }
      else if ((l == 6) && (EQSTRING(tag, "OMATTR"))) {
	*type = OMtokenAttr;
	return OMSEparseClosing(dev);
      }
      else if ((l == 5) && (EQSTRING(tag, "OMATP"))) {
	*type = OMtokenAtp;
	return OMSEparseClosing(dev);
      }
      break;
    case 'I':
      if (l == 3) {		/* OMI */
	return OMSEparseInt(dev, type);
      }
      break;
    case 'B':
      if (l == 3) {		/* OMB */
	*type = OMtokenByteArray;
	OMcheckStatus(OMSEparseClosing(dev));
	OMcheckStatus(OMSEparseByteArray(dev));
	return OMSEparseKnownString(dev, "</OMB>");
      }
      else if (l == 6 && (EQSTRING(tag, "OMBIND"))) {	/* OMBIND */
	*type = OMtokenBind;
	return OMSEparseClosing(dev);
      }
      else if (l == 6 && (EQSTRING(tag, "OMBVAR"))) {	/* OMBVAR */
	*type = OMtokenBVar;
	return OMSEparseClosing(dev);
      }
      break;
    case 'E':
      if (l == 3) {		/* OME */
	*type = OMtokenError;
	return OMSEparseClosing(dev);
      }
      break;
    case 'F':
      if (l == 3) {		/* OMF */
	*type = OMtokenFloat64;
	return OMSEparseFloat64(dev);
      }
      break;
    case 'O':
      if ((l == 5) && (EQSTRING(tag, "OMOBJ"))) {
	*type = OMtokenObject;
	return OMSEparseClosing(dev);
      }
      break;
    case 'S':
      if (l == 3) {		/* OMS */
	*type = OMtokenSymbol;
	return OMSEparseSymbol(dev);
      }
      else if ((l == 5) && (EQSTRING(tag, "OMSTR"))) {
	*type = OMtokenString;
	OMcheckStatus(OMSEparseClosing(dev));
	OMcheckStatus(OMparseUCS2FromUTF7(dev));
	if (OMSEbufNeedWC(dev)) {
	  *type = OMtokenWCString;
	}
	return OMSEparseKnownString(dev, "</OMSTR>");
      }
      break;
    case 'V':
      if (l == 3) {		/* OMV */
	*type = OMtokenVar;
	return OMSEparseVar(dev);
      }
      break;
    default:
      return OMmalformedInput;
    }
    break;
  case '/':
    /* a closing tag */
    if ((tag[1] != 'O') || (tag[2] != 'M')) {
      return OMmalformedInput;
    }
    switch (tag[3]) {
    case 'A':
      if (l == 4) {		/* /OMA */
	*type = OMtokenEndApp;
	return OMSEparseClosing(dev);
      }
      else if ((l == 7) && EQSTRING(tag, "/OMATTR")) {
	*type = OMtokenEndAttr;
	return OMSEparseClosing(dev);
      }
      else if ((l == 6) && EQSTRING(tag, "/OMATP")) {
	*type = OMtokenEndAtp;
	return OMSEparseClosing(dev);
      }
      break;
    case 'B':
      if (l == 7 && (EQSTRING(tag, "/OMBVAR"))) {	/* /OMBVAR */
	*type = OMtokenEndBVar;
	return OMSEparseClosing(dev);
      }
      else if (l == 7 && (EQSTRING(tag, "/OMBIND"))) {	/* /OMBIND */
	*type = OMtokenEndBind;
	return OMSEparseClosing(dev);
      }
      break;
    case 'E':			/* /OME */
      if (l == 4) {
	*type = OMtokenEndError;
	return OMSEparseClosing(dev);
      }
      break;
    case 'O':
      if ((l == 6) && (EQSTRING(tag, "/OMOBJ"))) {
	*type = OMtokenEndObject;
	return OMSEparseClosing(dev);
      }
      break;
    default:
      return OMmalformedInput;
    }
    break;
  case '!':
    if ((l == 3) && (EQSTRING(tag, "!--"))) {
      *type = OMtokenComment;
      return OMSEparseComment(dev);
    }
    break;
  default:
    return OMmalformedInput;
  }
  return OMmalformedInput;
}

Module OMstatus
OMSEparseTag(OMdev dev, OMtokenType * type)
{
  OMstatus status;

  OMassert(dev);
  OMassert(type);

  status = OMSEparseTagAux(dev, type);
#if OM_DEBUG
  if (status) {
    OMprintf(OMwarnLevel, "line %d: %s\n", LINE(dev), OMstatusToString(status));
  }
#endif /* OM_DEBUG */
  return status;
}

Module OMstatus
OMSEparseToken(OMdev dev, OMtokenType * type)
{
  int c;

  OMassert(dev);
  OMassert(type);

  /* the 'do' skips comments if ignoreComments is ON */
  do {
    OMcheckStatus(OMSEparseSeparator(dev));
    c = LOOKAHEAD(dev);
    if (c == '<') {
      c = GETCHAR(dev);
      OMcheckStatus(OMSEparseTag(dev, type));
    }
    else if (c == EOF) {
      *type = OMtokenUnknown;
      return OMnoMoreToken;
    }
    else {
      *type = OMtokenUnknown;
      return OMmalformedInput;
    }
  } while (((*type) == OMtokenComment) && dev->ignoreComments);
  return OMsuccess;
}

Lib OMstatus
OMSEgetType(OMdev dev, OMtokenType * type)
{
  OMassert(dev);
  OMassert(type);

  if (CURRENTTYPE(dev) != OMtokenUnknown) {
    *type = CURRENTTYPE(dev);
    return OMsuccess;
  }

  *type = OMtokenUnknown;
  OMcheckStatus(OMSEparseToken(dev, &CURRENTTYPE(dev)));
  *type = CURRENTTYPE(dev);
  return OMsuccess;
}

Lib OMstatus
OMSEgetSymbolLength(OMdev dev, int *clen, int *nlen)
{
  OMtokenType type;

  OMassert(dev);
  OMassert(clen);
  OMassert(nlen);

  if ((type = CURRENTTYPE(dev)) == OMtokenUnknown) {
    *clen = -1;
    *nlen = -1;
    OMcheckStatus(OMgetType(dev, &type));
  }
  switch (type) {
  case OMtokenSymbol:
    *clen = BUFUSED(dev);
    *nlen = BUFAUXUSED(dev);
    break;
  default:
    *clen = -1;
    *nlen = -1;
  }
  return OMsuccess;
}


Lib OMstatus
OMSEgetLength(OMdev dev, int *len)
{
  OMtokenType type;

  OMassert(dev);
  OMassert(len);

  if ((type = CURRENTTYPE(dev)) == OMtokenUnknown) {
    *len = -1;
    OMcheckStatus(OMgetType(dev, &type));
  }
  switch (type) {
  case OMtokenBigInt:
  case OMtokenByteArray:
  case OMtokenVar:
  case OMtokenString:
  case OMtokenWCString:
  case OMtokenComment:
    *len = BUFUSED(dev);
    break;
  default:
    *len = -1;
  }
  return OMsuccess;
}

Lib OMstatus
OMSEgetTokenTag(OMdev dev, OMtokenType ttype)
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

  OMSEcheckType(dev, ttype);

  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetInt32(OMdev dev, int *i)
{
  OMassert(dev);
  OMassert(i);

  OMSEcheckType(dev, OMtokenInt32);

  *i = STATE(dev)->i;
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetFloat64(OMdev dev, double *d)
{
  OMassert(dev);
  OMassert(d);

  OMSEcheckType(dev, OMtokenFloat64);

  *d = STATE(dev)->d;
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetBigInt(OMdev dev, char **data, int *len, int *sign, OMbigIntType * format)
{
  OMassert(dev);
  OMassert(data);
  OMassert(sign);
  OMassert(format);

  OMSEcheckType(dev, OMtokenBigInt);

  *sign = STATE(dev)->sign;
  *format = STATE(dev)->format;
  OMcheckStatus(OMSEcopyBuf(dev, data, len, 1, 0, OMfalse));
#if OM_DEBUG
  if ((**data == '+') || (**data == '-')) {
    OMprintf(OMwarnLevel, "line %d: Warning: There is a sign character '%c' in the body of this bigInt. This is not legal!\n", LINE(dev), **data);
  }
#endif /* OM_DEBUG */
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetByteArray(OMdev dev, char **data, int *len)
{
  OMassert(dev);
  OMassert(data);

  OMSEcheckType(dev, OMtokenByteArray);

  OMcheckStatus(OMSEcopyBuf(dev, data, len, 1, 0, OMfalse));
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetSymbol(OMdev dev, char **cd, int *clen, char **name, int *nlen)
{
  OMassert(dev);
  OMassert(cd);
  OMassert(name);

  OMSEcheckType(dev, OMtokenSymbol);

  OMcheckStatus(OMSEcopyBuf(dev, cd, clen, 1, 0, OMfalse));
  OMSEswitchBuf(STATE(dev));
  OMcheckStatus(OMSEcopyBuf(dev, name, nlen, 1, 0, OMfalse));
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetVar(OMdev dev, char **name, int *len)
{
  OMassert(dev);
  OMassert(name);

  OMSEcheckType(dev, OMtokenVar);

  OMcheckStatus(OMSEcopyBuf(dev, name, len, 1, 0, OMfalse));
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetString(OMdev dev, char **data, int *len)
{
  OMassert(dev);
  OMassert(data);

  OMSEcheckStringType(dev);

  OMcheckStatus(OMSEcopyBuf(dev, data, len, 2, (OMlittleEndianMode ? 0 : 1), OMfalse));
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetWCString(OMdev dev, OMUCS2 ** data, int *len)
{
  OMassert(dev);
  OMassert(data);

  OMSEcheckStringType(dev);

  OMcheckStatus(OMSEcopyBuf(dev, (char **) data, len, 1, 0, OMtrue));
  CURRENTTYPE(dev) = OMtokenUnknown;
  return OMsuccess;
}

Lib OMstatus
OMSEgetComment(OMdev dev, char **comment, int *len)
{
  OMassert(dev);

  if (!dev->ignoreComments) {
    OMSEcheckType(dev, OMtokenComment);
    OMcheckStatus(OMSEcopyBuf(dev, comment, len, 1, 0, OMfalse));
    CURRENTTYPE(dev) = OMtokenUnknown;
  }
  return OMsuccess;
}

Lib void
OMSEFreeTranslation(OMtranslationStruct * tr)
{
  OMXmlState state;

  OMassert(tr);
  OMassert(tr->encoding == OMencodingXML);
  state = tr->state;
  OMassert(state->encoding == OMencodingXML);

  OMfreeInternal(state->buf);
  OMfreeInternal(state->bufAux);
  OMfreeInternal(state);
  OMfreeInternal(tr);
}



Lib OMtranslation
OMXMLEncoding(void)
{
  OMtranslationStruct *res;
  OMXmlState state;

  res = OMmallocWarn(sizeof(OMtranslationStruct), "Cannot allocate encoding structure.");
  memset(res, 0, sizeof(OMtranslationStruct));
  state = OMmallocWarn(sizeof(OMXmlStateStruct), "Cannot allocate encoding structure.");
  memset(state, 0, sizeof(OMXmlStateStruct));

  res->encoding = OMencodingXML;
  state->encoding = OMencodingXML;

  /* encoding part */
  res->putInt32 = (OMputInt32Func) OMSEputInt32;
  res->putFloat64 = (OMputFloat64Func) OMSEputFloat64;
  res->putBigInt = (OMputBigIntFunc) OMSEputBigInt;
  res->putByteArray = (OMputByteArrayFunc) OMSEputByteArray;
  res->putString = (OMputStringFunc) OMSEputString;
  res->putWCString = (OMputWCStringFunc) OMSEputWCString;
  res->putVar = (OMputVarFunc) OMSEputVar;
  res->putSymbol = (OMputSymbolFunc) OMSEputSymbol;
  res->putTokenTag = (OMputTokenTagFunc) OMSEputTokenTag;
  res->putComment = (OMputCommentFunc) OMSEputComment;

  /* decoding part */
  res->getInt32 = (OMgetInt32Func) OMSEgetInt32;
  res->getFloat64 = (OMgetFloat64Func) OMSEgetFloat64;
  res->getBigInt = (OMgetBigIntFunc) OMSEgetBigInt;
  res->getByteArray = (OMgetByteArrayFunc) OMSEgetByteArray;
  res->getString = (OMgetStringFunc) OMSEgetString;
  res->getWCString = (OMgetWCStringFunc) OMSEgetWCString;
  res->getVar = (OMgetVarFunc) OMSEgetVar;
  res->getSymbol = (OMgetSymbolFunc) OMSEgetSymbol;
  res->getTokenTag = (OMgetTokenTagFunc) OMSEgetTokenTag;
  res->getComment = (OMgetCommentFunc) OMSEgetComment;
  res->getType = (OMgetTypeFunc) OMSEgetType;
  res->getLength = (OMgetLengthFunc) OMSEgetLength;
  res->getSymbolLength = (OMgetSymbolLengthFunc) OMSEgetSymbolLength;
  res->beginObject = (OMbeginObjectFunc) OMSEbeginObject;
  res->endObject = (OMendObjectFunc) OMSEendObject;

  res->state = state;

  state->currentType = OMtokenUnknown;
  state->indentLevel = 0;
  state->indentTab = 2;
  state->indentMode = OMindentNormal;
  state->bufSize = 0;
  state->bufUsed = 0;
  state->buf = NULL;
  state->bufAuxSize = 0;
  state->bufAuxUsed = 0;
  state->bufAux = NULL;
  /* prepare buffers (alloc with a minimum size) */
  OMSEreallocBuf(state);
  OMSEswitchBuf(state);
  OMSEreallocBuf(state);

#if OM_DEBUG
  state->line = 1;
#endif

  return res;
}
