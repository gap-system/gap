/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/*
 */
static OMstatus OMUKdetectEncoding(OMdev dev);
static OMstatus OMUKput(OMdev dev);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */

#define LOOKAHEAD(Dev)     (*(Dev->io->lookAhead))(Dev)

/*
 */
Module OMstatus
OMUKdetectEncoding(OMdev dev)
{
  int c;

  OMassert(dev);

  c = LOOKAHEAD(dev);
  if (c == EOF)
    return OMnoMoreToken;

  /* check this char (remove the 2 flag bits) against known headers */
  switch (c & 0x3F) {
  case '<':
  case ' ':
  case '\t':
  case '\n':
  case '\r':
    OMUKFreeTranslation(dev->translation);
    dev->encoding = OMencodingXML;
    dev->translation = OMXMLEncoding();
    return OMsuccess;
  case OMtokenInt32:
  case OMtokenBigInt:
  case OMtokenFloat64:
  case OMtokenByteArray:
  case OMtokenSymbol:
  case OMtokenVar:
  case OMtokenString:
  case OMtokenWCString:
  case OMtokenApp:
  case OMtokenEndApp:
  case OMtokenAttr:
  case OMtokenEndAttr:
  case OMtokenAtp:
  case OMtokenEndAtp:
  case OMtokenError:
  case OMtokenEndError:
  case OMtokenObject:
  case OMtokenEndObject:
  case OMtokenComment:
  case OMtokenBind:
  case OMtokenEndBind:
  case OMtokenBVar:
  case OMtokenEndBVar:
    OMUKFreeTranslation(dev->translation);
    dev->encoding = OMencodingBinary;
    dev->translation = OMbinEncoding();
    return OMsuccess;
  default:
#if OM_DEBUG
    OMprintf(OMwarnLevel, "Given device was of an unknown encoding type, but autodetection failed! Are you sure it is a valid OpenMath stream? (first char is '%c'(%d) %d and this matches with no known encoding.)\n", c, c, c & 0x3F);
#endif
    return OMmalformedInput;
  }
}

Module OMstatus
OMUKput(OMdev dev)
{
#if OM_DEBUG
  OMprintf(OMwarnLevel, "Can't put on an undefined device (set to OMencodingUnknown).\n");
#endif
  return OMfailed;
}

Lib OMstatus
OMUKputInt32(OMdev dev, int i)
{
  OMassert(dev);

  return OMUKput(dev);
}

Lib OMstatus
OMUKputFloat64(OMdev dev, double *d)
{
  OMassert(dev);

  return OMUKput(dev);
}

Lib OMstatus
OMUKputBigInt(OMdev dev, char *data, int len, int sign, OMbigIntType format)
{
  OMassert(dev);
  OMassert(data);
  OMassert(len >= 0);

  return OMUKput(dev);
}

Lib OMstatus
OMUKputByteArray(OMdev dev, char *data, int len)
{
  OMassert(dev);
  OMassert(data);
  OMassert(len >= 0);

  return OMUKput(dev);
}


Lib OMstatus
OMUKputString(OMdev dev, char *str, int len)
{
  OMassert(dev);
  OMassert(str);
  OMassert(len > 0);

  return OMUKput(dev);
}

Lib OMstatus
OMUKputWCString(OMdev dev, OMUCS2 * wcstr, int len)
{
  OMassert(dev);
  OMassert(wcstr);
  OMassert(len > 0);

  return OMUKput(dev);
}

Lib OMstatus
OMUKputVar(OMdev dev, char *var, int len)
{
  OMassert(dev);
  OMassert(var);
  OMassert(len > 0);

  return OMUKput(dev);
}

Lib OMstatus
OMUKputSymbol(OMdev dev, char *cd, int clen, char *name, int nlen)
{
  OMassert(dev);
  OMassert(cd);
  OMassert(name);
  OMassert(clen > 0);
  OMassert(nlen > 0);

  return OMUKput(dev);
}

Lib OMstatus
OMUKputTokenTag(OMdev dev, OMtokenType ttype)
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
	   (ttype == OMtokenObject) ||
	   (ttype == OMtokenEndObject) ||
	   (ttype == OMtokenBind) ||
	   (ttype == OMtokenEndBind) ||
	   (ttype == OMtokenBVar) ||
	   (ttype == OMtokenEndBVar));
  return OMUKput(dev);
}

Lib OMstatus
OMUKputComment(OMdev dev, char *comment, int len)
{
  OMassert(dev);
  OMassert(comment);
  OMassert(len > 0);

  return OMUKput(dev);
}










Lib OMstatus
OMUKgetType(OMdev dev, OMtokenType * type)
{
  OMassert(dev);
  OMassert(type);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetType(dev, type));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetType(dev, type));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetLength(OMdev dev, int *len)
{
  OMassert(dev);
  OMassert(len);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetLength(dev, len));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetLength(dev, len));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetSymbolLength(OMdev dev, int *clen, int *nlen)
{
  OMassert(dev);
  OMassert(clen);
  OMassert(nlen);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetSymbolLength(dev, clen, nlen));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetSymbolLength(dev, clen, nlen));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetTokenTag(OMdev dev, OMtokenType ttype)
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

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetTokenTag(dev, ttype));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetTokenTag(dev, ttype));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetInt32(OMdev dev, int *i)
{
  OMassert(dev);
  OMassert(i);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetInt32(dev, i));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetInt32(dev, i));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetFloat64(OMdev dev, double *d)
{
  OMassert(dev);
  OMassert(d);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetFloat64(dev, d));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetFloat64(dev, d));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetBigInt(OMdev dev, char **data, int *len, int *sign, OMbigIntType * format)
{
  OMassert(dev);
  OMassert(data);
  OMassert(sign);
  OMassert(format);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetBigInt(dev, data, len, sign, format));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetBigInt(dev, data, len, sign, format));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetByteArray(OMdev dev, char **data, int *len)
{
  OMassert(dev);
  OMassert(data);
  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetByteArray(dev, data, len));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetByteArray(dev, data, len));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetSymbol(OMdev dev, char **cd, int *clen, char **name, int *nlen)
{
  OMassert(dev);
  OMassert(cd);
  OMassert(name);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetSymbol(dev, cd, clen, name, nlen));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetSymbol(dev, cd, clen, name, nlen));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetVar(OMdev dev, char **name, int *len)
{
  OMassert(dev);
  OMassert(name);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetVar(dev, name, len));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetVar(dev, name, len));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetString(OMdev dev, char **data, int *len)
{
  OMassert(dev);
  OMassert(data);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetString(dev, data, len));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetString(dev, data, len));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetWCString(OMdev dev, OMUCS2 ** data, int *len)
{
  OMassert(dev);
  OMassert(data);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetWCString(dev, data, len));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetWCString(dev, data, len));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}

Lib OMstatus
OMUKgetComment(OMdev dev, char **comment, int *len)
{
  OMassert(dev);

  OMcheckStatus(OMUKdetectEncoding(dev));
  switch (dev->encoding) {
  case OMencodingBinary:
    OMcheckStatus(OMBEgetComment(dev, comment, len));
    return OMsuccess;
  case OMencodingXML:
    OMcheckStatus(OMSEgetComment(dev, comment, len));
    return OMsuccess;
  default:
    OMIE;
    return OMinternalError;
  }
}




Lib void
OMUKFreeTranslation(OMtranslationStruct * tr)
{
  OMassert(tr);

  OMfreeInternal(tr);
}

Lib OMtranslation
OMunknownEncoding(void)
{
  OMtranslationStruct *res;

  res = OMmallocWarn(sizeof(OMtranslationStruct), "Cannot allocate encoding structure.");

  res->encoding = OMencodingUnknown;

  /* encoding part */
  res->putInt32 = (OMputInt32Func) OMUKputInt32;
  res->putFloat64 = (OMputFloat64Func) OMUKputFloat64;
  res->putBigInt = (OMputBigIntFunc) OMUKputBigInt;
  res->putByteArray = (OMputByteArrayFunc) OMUKputByteArray;
  res->putString = (OMputStringFunc) OMUKputString;
  res->putWCString = (OMputWCStringFunc) OMUKputWCString;
  res->putVar = (OMputVarFunc) OMUKputVar;
  res->putSymbol = (OMputSymbolFunc) OMUKputSymbol;
  res->putTokenTag = (OMputTokenTagFunc) OMUKputTokenTag;
  res->putComment = (OMputCommentFunc) OMUKputComment;

  /* decoding part */
  res->getInt32 = (OMgetInt32Func) OMUKgetInt32;
  res->getFloat64 = (OMgetFloat64Func) OMUKgetFloat64;
  res->getBigInt = (OMgetBigIntFunc) OMUKgetBigInt;
  res->getByteArray = (OMgetByteArrayFunc) OMUKgetByteArray;
  res->getString = (OMgetStringFunc) OMUKgetString;
  res->getWCString = (OMgetWCStringFunc) OMUKgetWCString;
  res->getVar = (OMgetVarFunc) OMUKgetVar;
  res->getSymbol = (OMgetSymbolFunc) OMUKgetSymbol;
  res->getTokenTag = (OMgetTokenTagFunc) OMUKgetTokenTag;
  res->getComment = (OMgetCommentFunc) OMUKgetComment;
  res->getType = (OMgetTypeFunc) OMUKgetType;
  res->getLength = (OMgetLengthFunc) OMUKgetLength;
  res->getSymbolLength = (OMgetSymbolLengthFunc) OMUKgetSymbolLength;


  return res;
}
