/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/************************************************************ End Prototypes */
/* end of automaticaly updated part */

#define ENCODING(Dev, Op) ((Dev)->translation->Op)



/* OMPut* functions. 
 *    They all take a device <dev> to put token to.
 *    Some of them need more parameters to define the token content.
 *    They are thoroughly documented in OpenMath Specification shiped with the library.
 * return: a status that reflect the operation success. 
 */
World OMstatus
OMputInt32(OMdev dev, int n)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putInt32)) (dev, n);
}

World OMstatus
OMputFloat64(OMdev dev, double *d)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putFloat64)) (dev, d);
}

World OMstatus
OMputBigInt(OMdev dev, const char *data, int len, int sign, OMbigIntType format)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putBigInt)) (dev, data, len, sign, format);
}

World OMstatus
OMputByteArray(OMdev dev, const char *data, int len)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putByteArray)) (dev, data, len);
}

/* OMputString*
 *   If you want to output plain 8bits C like strings there is no need
 *   to use the OMputWCString* functions. This one is more efficient
 *   (faster and more compact output for some encodings)
 */
World OMstatus
OMputString(OMdev dev, const char *str)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putString)) (dev, str, strlen(str));
}


World OMstatus
OMputStringN(OMdev dev, const char *str, int len)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putString)) (dev, str, len);
}


Lib int
OMWCStrLen(const OMUCS2 * wcstr)
{
  int l = 0;

  while (*wcstr++) {
    l++;
  }
  return l;
}

/* OMputWCString
 *   If you are using wide char strings you need to output them 
 *   with that function rather than with OMputString.
 *   (It takes endianess into account) 
 */
World OMstatus
OMputWCString(OMdev dev, const OMUCS2 * wcstr)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putWCString)) (dev, wcstr, OMWCStrLen(wcstr));
}

Lib OMstatus
OMputWCStringN(OMdev dev, const OMUCS2 * wcstr, int len)
{
  OMassert(dev);

  OMNYI;
  dev->outTokenNb++;
  return (*ENCODING(dev, putWCString)) (dev, wcstr, len);
  return OMnotImplemented;
}

World OMstatus
OMputVar(OMdev dev, const char *var)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putVar)) (dev, var, strlen(var));
}

World OMstatus
OMputVarN(OMdev dev, const char *var, int len)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putVar)) (dev, var, len);
}

World OMstatus
OMputSymbol(OMdev dev, const char *cd, const char *name)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putSymbol)) (dev, cd, strlen(cd), name, strlen(name));
}

World OMstatus
OMputSymbolN(OMdev dev, const char *cd, int clen, const char *name, int nlen)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putSymbol)) (dev, cd, clen, name, nlen);
}

World OMstatus
OMputApp(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenApp);
}

World OMstatus
OMputEndApp(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenEndApp);
}

World OMstatus
OMputAttr(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenAttr);
}

World OMstatus
OMputEndAttr(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenEndAttr);
}

World OMstatus
OMputAtp(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenAtp);
}

World OMstatus
OMputEndAtp(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenEndAtp);
}

World OMstatus
OMputBind(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenBind);
}

World OMstatus
OMputEndBind(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenEndBind);
}

World OMstatus
OMputBVar(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenBVar);
}

World OMstatus
OMputEndBVar(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenEndBVar);
}

World OMstatus
OMputObject(OMdev dev)
{
  OMassert(dev);

  OMbeginObject(dev);
  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenObject);
}

World OMstatus
OMputEndObject(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  OMcheckStatus((*ENCODING(dev, putTokenTag)) (dev, OMtokenEndObject));
  OMendObject(dev);
  return OMsuccess;;
}

World OMstatus
OMputError(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenError);
}

World OMstatus
OMputEndError(OMdev dev)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putTokenTag)) (dev, OMtokenEndError);
}

World OMstatus
OMputComment(OMdev dev, const char *comment)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putComment)) (dev, comment, strlen(comment));
}

World OMstatus
OMputCommentN(OMdev dev, const char *comment, int len)
{
  OMassert(dev);

  dev->outTokenNb++;
  return (*ENCODING(dev, putComment)) (dev, comment, len);
}




/* OMgetType
 *   Get the type of the current token on device <dev>/
 * dev: device to look at.
 * type: where to store returned type.
 * return: 0 or some error code
 */
World OMstatus
OMgetType(OMdev dev, OMtokenType * type)
{
  OMassert(dev);

  return (*ENCODING(dev, getType)) (dev, type);
}


/* OMgetLength
 *   Get the current token length.
 * dev: device to read from
 * len: where to put the token length 
 *      the last '\0' for string like tokens is not counted
 *      (rem: for WCString it is the number of bytes not the number of wide chars)
 * return: 0 or some error code
 */
World OMstatus
OMgetLength(OMdev dev, int *len)
{
  OMassert(dev);

  return (*ENCODING(dev, getLength)) (dev, len);
}


/* OMgetSymbolLength
 *   Get the current token (wich is assumed to be a symbol) lengths.
 * dev: device to read from
 * clen: where to put the cd length (not counting the last '\0')
 * nlen: where to put the name length (not counting the last '\0')
 * return: 0 or some error code
 */
World OMstatus
OMgetSymbolLength(OMdev dev, int *clen, int *nlen)
{
  OMassert(dev);

  return (*ENCODING(dev, getSymbolLength)) (dev, clen, nlen);
}



/* OMGet* functions. 
 *    They all take a device <dev> to get token from.
 *    Some of them need more parameters to fill with the token content.
 *    They are thoroughly documented in OpenMath Specification shiped with the library.
 * return: a status that reflect the operation success. 
 */

World OMstatus
OMgetInt32(OMdev dev, int *i)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getInt32)) (dev, i);
}

World OMstatus
OMgetFloat64(OMdev dev, double *d)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getFloat64)) (dev, d);
}

World OMstatus
OMgetBigInt(OMdev dev, char **data, int *len, int *sign, OMbigIntType * format)
{
  OMtokenType type;

  OMassert(data);

  *data = NULL;
  dev->inTokenNb++;
  OMcheckStatus(OMgetType(dev, &type));
  if (type == OMtokenInt32) {
    // allow user to get a bigint (if it was a 32 bit int)
    // OPTIM build a special low level call to get the string?
    int i;
    char tmp[12];		// a 32 bit int has at most 10 chars

    OMcheckStatus((*ENCODING(dev, getInt32)) (dev, &i));
    if (i < 0) {
      *sign = -1;
      i = -i;
    }
    sprintf(tmp, "%d", i);
    *data = strdup(tmp);
    *len = strlen(tmp);
    return OMsuccess;
  }
  else {
    return (*ENCODING(dev, getBigInt)) (dev, data, len, sign, format);
  }
}

World OMstatus
OMgetBigIntN(OMdev dev, char *data, int len, int *sign, OMbigIntType * format)
{
  OMtokenType type;
  OMassert(dev);

  dev->inTokenNb++;
  OMcheckStatus(OMgetType(dev, &type));
  if (type == OMtokenInt32) {
    // allow user to get a bigint (if it was a 32 bit int)
    // OPTIM build a special low level call to get the string?
    int i;
    OMcheckStatus((*ENCODING(dev, getInt32)) (dev, &i));
    if (i < 0) {
      *sign = -1;
      i = -i;
    }
    sprintf(data, "%d", i);
    return OMsuccess;
  }
  else {
    return (*ENCODING(dev, getBigInt)) (dev, &data, &len, sign, format);
  }
}

World OMstatus
OMgetByteArray(OMdev dev, char **data, int *len)
{
  OMassert(data);

  *data = NULL;
  dev->inTokenNb++;
  return (*ENCODING(dev, getByteArray)) (dev, data, len);
}

World OMstatus
OMgetByteArrayN(OMdev dev, char *data, int len)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getByteArray)) (dev, &data, &len);
}



/* OMgetString*
 *   Beware! You are not suposed to use these functions unless you know
 *   for sure you are reading plain 8bits strings.
 *   Thus it is here only for speed/space consideration in very 
 *   specific applications.
 *   If input is a 16 bit char string and you read it with these 
 *   functions you will lose the 8 most significant bits of each char.
 *   You should rather refer to OMgetWCString* functions.
 */
World OMstatus
OMgetString(OMdev dev, char **str)
{
  int len;
  OMassert(str);

  *str = NULL;
  dev->inTokenNb++;
  return (*ENCODING(dev, getString)) (dev, str, &len);
}

World OMstatus
OMgetStringN(OMdev dev, char *str, int len)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getString)) (dev, &str, &len);
}


/* OMgetWCString*
 *   These functions return 16 bits wide strings. (regardless input 
 *   was done in 8 or 16 bits mode).
 *   Thus, most if not all applications should use these functions 
 *   preferably to OMgetString*.
 */
World OMstatus
OMgetWCString(OMdev dev, OMUCS2 ** wcstr)
{
  int len;
  OMassert(wcstr);

  *wcstr = NULL;
  dev->inTokenNb++;
  return (*ENCODING(dev, getWCString)) (dev, wcstr, &len);
}



/* BEWARE: the <len> is suposed to be the length in bytes for the preallocated buffer <wcstr> (not the length in number of wide chars)
 */
World OMstatus
OMgetWCStringN(OMdev dev, OMUCS2 * wcstr, int len)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getWCString)) (dev, &wcstr, &len);
}

World OMstatus
OMgetVar(OMdev dev, char **var)
{
  int len;

  OMassert(dev);
  OMassert(var);

  *var = NULL;
  dev->inTokenNb++;
  return (*ENCODING(dev, getVar)) (dev, var, &len);
}

World OMstatus
OMgetVarN(OMdev dev, char *var, int len)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getVar)) (dev, &var, &len);
}

World OMstatus
OMgetSymbol(OMdev dev, char **cd, char **name)
{
  int clen, slen;

  OMassert(dev);
  OMassert(cd);
  OMassert(name);

  *cd = NULL;
  *name = NULL;
  dev->inTokenNb++;
  return (*ENCODING(dev, getSymbol)) (dev, cd, &clen, name, &slen);
}

World OMstatus
OMgetSymbolN(OMdev dev, char *cd, int clen, char *name, int nlen)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getSymbol)) (dev, &cd, &clen, &name, &nlen);
}

World OMstatus
OMgetApp(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenApp);
}

World OMstatus
OMgetEndApp(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenEndApp);
}

World OMstatus
OMgetAttr(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenAttr);
}

World OMstatus
OMgetEndAttr(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenEndAttr);
}

World OMstatus
OMgetAtp(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenAtp);
}

World OMstatus
OMgetEndAtp(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenEndAtp);
}

World OMstatus
OMgetBind(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenBind);
}

World OMstatus
OMgetEndBind(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenEndBind);
}

World OMstatus
OMgetBVar(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenBVar);
}

World OMstatus
OMgetEndBVar(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenEndBVar);
}

World OMstatus
OMgetObject(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenObject);
}

World OMstatus
OMgetEndObject(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenEndObject);
}

World OMstatus
OMgetError(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenError);
}

World OMstatus
OMgetEndError(OMdev dev)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getTokenTag)) (dev, OMtokenEndError);
}


World OMstatus
OMgetComment(OMdev dev, char **comment)
{
  OMassert(dev);

  OMassert(comment);

  *comment = NULL;
  dev->inTokenNb++;
  return (*ENCODING(dev, getComment)) (dev, comment, NULL);
}

World OMstatus
OMgetCommentN(OMdev dev, char *comment, int len)
{
  OMassert(dev);

  dev->inTokenNb++;
  return (*ENCODING(dev, getComment)) (dev, &comment, &len);
}







/* OMbeginObject
 *   Must be called before every new OpenMath object put.
 *   (Not before every token!)
 * dev: device where new object is to be put.
 * return: status describing operation success
 */
World OMstatus
OMbeginObject(OMdev dev)
{
  OMbeginObjectFunc bobf;

  OMassert(dev);

  if ((bobf = ENCODING(dev, beginObject)))
    return bobf(dev);
  return OMsuccess;
}


/* OMendObject
 *   Must be called after every OpenMath object put.
 *   (Not after every token!)
 * dev: device where object has been put.
 * return: status describing operation success
 */
World OMstatus
OMendObject(OMdev dev)
{
  OMendObjectFunc eobf;

  OMassert(dev);

  if ((eobf = ENCODING(dev, endObject)))
    return eobf(dev);
  return OMsuccess;
}



/*
 *             Very basic operations on OpenMath "devices".
 */

/* OMignoreComment
 *   Set behavior of a device concerning comments.
 *   (Comments on an input device may safely be ignored.)
 * dev: device to modify
 * set: If set == OMtrue then device will ignore incoming comments
 *      If set == OMfalse then device will process incoming comments like other tokens.
 *      By default comments are ignored.
 *      Whatever is <set> value, output of comments is always done.
 * return: previous value
 */
World OMbool
OMignoreComment(OMdev dev, OMbool set)
{
  OMbool old;

  OMassert(dev);

  old = dev->ignoreComments;
  dev->ignoreComments = set;
  return old;
}


/* OMtokenCount
 *   Reports the numbe rof tokens that have been in/output on a device
 * dev: devive to examine
 * inTokenNb: where to store number of input tokens (if not NULL)
 * outTokenNb: where to store number of output tokens (if not NULL)
 */
World void
OMtokenCount(OMdev dev, int *inTokenNb, int *outTokenNb)
{
  OMassert(dev);

  if (inTokenNb)
    *inTokenNb = dev->inTokenNb;
  if (outTokenNb)
    *outTokenNb = dev->outTokenNb;
}


/* OMgetDeviceEncoding
 *   Get the currnet encoding used by a device
 * dev: device to examine
 * return: current encoding
 */
World OMencodingType
OMgetDeviceEncoding(OMdev dev)
{
  OMassert(dev);

  return dev->encoding;
}


/* OMsetDeviceEncoding
 *   Set the encoding that will be used on a device
 *   BEWARE: changing encoding on a device that has alreadybeen used for IO is unsafe.
 *   but seting encoding on a new device is safe. 
 *   (in some occasions, it is not easy to know which encoding to use at device creation)  
 * dev: device to modify
 * encoding: encoding to use
 */
World void
OMsetDeviceEncoding(OMdev dev, OMencodingType encoding)
{
  OMassert(dev);

  dev->encoding = encoding;
  switch (encoding) {
  case OMencodingBinary:
    dev->translation = OMbinEncoding();
    break;
  case OMencodingXML:
    dev->translation = OMXMLEncoding();
    break;
  case OMencodingUnknown:
    dev->translation = OMunknownEncoding();
    break;
  default:
    OMfatalInternal(OMnotImplemented, "Unknown (or unimplemented) encoding.\n");
  }
}



/* OMmakeDevice
 *   Create a device from a low level IO 
 *   Warning: "IO" should be a "generated" (new) structure as it contains some 
 *   state that is private to the device. It is very dangerous for two devices 
 *   to share the same "IO" structure.
 * encoding: encoding scheme used by device
 * IO: low level I/O suport for device
 * return: a newly allocated device
 */
World OMdev
OMmakeDevice(OMencodingType encoding, OMIO IO)
{
  OMdev dev;

  OMassert(IO);

  /* init little/big endian mode */
  OMlittleEndianMode = OMlittleEndianess();

  /* init double special constants */
  OMinitMathCst();

  /* just set the default log/err file descriptors */
  OMinitFd();

  dev = OMmallocWarn(sizeof(OMdevStruct), "Cannot allocate new device.");
  OMsetDeviceEncoding(dev, encoding);

  dev->io = IO;
  dev->ignoreComments = OMtrue;
  dev->error = OMsuccess;
  dev->omErrno = 0;
  dev->inTokenNb = 0;
  dev->outTokenNb = 0;

  return dev;
}

Lib void
OMfreeTranslation(OMtranslationStruct * tr)
{
  OMassert(tr);

  switch (tr->encoding) {
  case OMencodingBinary:
    OMBEFreeTranslation(tr);
    break;
  case OMencodingXML:
    OMSEFreeTranslation(tr);
    break;
  case OMencodingUnknown:
    OMUKFreeTranslation(tr);
    break;
  default:
    OMfatalInternal(OMnotImplemented, "Unknown (or unimplemented) encoding.\n");
  }
}

Lib void
OMfreeIO(OMIOStruct * io)
{
  OMassert(io);

  switch (io->type) {
  case OMIOFd:
    OMfreeIOFd(io);
    break;
  case OMIOFile:
    OMfreeIOFile(io);
    break;
  case OMIOString:
    OMfreeIOString(io);
    break;
#ifdef WIN32
  case OMIOHandle:
    OMfreeIOHandle(io);
    break;
#endif
  default:
    OMfatalInternal(OMnotImplemented, "Unknown (or unimplemented) IO type.\n");
  }
}


/* OMcloseDevice
 *   Close a device previously created with OMmakeDevice
 *   (embedded IO is closed too)
 * dev: device to close
 */
World void
OMcloseDevice(OMdev dev)
{
  OMassert(dev);

  OMfreeTranslation(dev->translation);
  OMfreeIO(dev->io);
  OMfreeInternal(dev);
}
