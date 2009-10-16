/* private counterpart for OM.h */
#ifndef __OMP_h__
#define __OMP_h__

#include <stdio.h>
#ifndef __CEXTRACT__
/* some protos here are misleading for cextract */
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>

#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif
#endif

#include "OMconfig.h"
#include "OM.h"

#ifndef OM_DEBUG
#define OM_DEBUG 0
#endif

#define OM_LIB_VERSION "1.3b"
#if OM_DEBUG
#define OM_LIB_INFO "debug is on"
#else
#define OM_LIB_INFO "debug is off"
#endif


#ifndef World
#define World
#endif
#ifndef Lib
#define Lib
#endif
#ifndef Module
#define Module static
#endif

/* In binary encoding when len of token is > 255 
 * this bit mask is ored to token type 
 * following len field is encoded on 4 bytes rather
 * than on only one
 */
#define OM_BE_BIG_LEN_MASK      (0x80)	/* 1000 0000 */
/* In binary encoding if an object is in fact a reference
 * to a previously seen one, this bit mask is ored to 
 * token type
 */
#define OM_BE_SHARED_MASK       (0x40)	/* 0100 0000 */


/* When a get fail in debug mode the data buffers provided
 * by caller are filled with '?' (helps tracking problems.)
 * This is the max number of '?' outputed */
#define OM_WARN_DATA_LEN 20

/* A device is an abstraction for a communication channel.
 * It uses and encoding that specify the kind of 
 * translation that must be done during Input/Output
 */
typedef struct OMdevStruct {
  /* current encoding */
  OMencodingType encoding;
  /* comments may be completly ignored */
  OMbool ignoreComments;
  /* all translation functions used for this encoding */
  struct OMtranslationStruct *translation;
  /* used for real I/O */
  struct OMIOStruct *io;
  /* last error occured on this device (FIXME) */
  OMstatus error;
  /* last errno on this device (FIXME) */
  int omErrno;
  /* some stats */
  int inTokenNb;
  int outTokenNb;
} OMdevStruct;


/* these typedefs are mostly used to fool compiler 'const' warnings */
typedef OMstatus(*OMputInt32Func) (OMdev dev, int i);
typedef OMstatus(*OMputFloat64Func) (OMdev dev, double *d);
typedef OMstatus(*OMputBigIntFunc) (OMdev dev, const char *data, int len, int sign, OMbigIntType format);
typedef OMstatus(*OMputByteArrayFunc) (OMdev dev, const char *data, int len);
typedef OMstatus(*OMputStringFunc) (OMdev dev, const char *str, int len);
typedef OMstatus(*OMputWCStringFunc) (OMdev dev, const OMUCS2 * str, int len);
typedef OMstatus(*OMputVarFunc) (OMdev dev, const char *var, int len);
typedef OMstatus(*OMputSymbolFunc) (OMdev dev, const char *cd, int clen, const char *name, int nlen);
typedef OMstatus(*OMputTokenTagFunc) (OMdev dev, OMtokenType type);
typedef OMstatus(*OMputCommentFunc) (OMdev dev, const char *comment, int len);
typedef OMstatus(*OMbeginObjectFunc) (OMdev dev);
typedef OMstatus(*OMendObjectFunc) (OMdev dev);


typedef OMstatus(*OMgetInt32Func) (OMdev dev, int *i);
typedef OMstatus(*OMgetFloat64Func) (OMdev dev, double *d);
typedef OMstatus(*OMgetBigIntFunc) (OMdev dev, char **data, int *len, int *sign, OMbigIntType * format);
typedef OMstatus(*OMgetByteArrayFunc) (OMdev dev, char **data, int *len);
typedef OMstatus(*OMgetStringFunc) (OMdev dev, char **str, int *len);
typedef OMstatus(*OMgetWCStringFunc) (OMdev dev, OMUCS2 ** str, int *len);
typedef OMstatus(*OMgetVarFunc) (OMdev dev, char **var, int *len);
typedef OMstatus(*OMgetSymbolFunc) (OMdev dev, char **cd, int *clen, char **name, int *nlen);
typedef OMstatus(*OMgetTokenTagFunc) (OMdev dev, OMtokenType type);
typedef OMstatus(*OMgetCommentFunc) (OMdev dev, char **comment, int *len);
typedef OMstatus(*OMgetTypeFunc) (OMdev dev, OMtokenType * type);
typedef OMstatus(*OMgetLengthFunc) (OMdev dev, int *len);
typedef OMstatus(*OMgetSymbolLengthFunc) (OMdev dev, int *clen, int *nlen);


/* The actual structure used to perform encoding and decoding.
 * There is one function in this structure for every basic operation.
 * Note that all these functions take the device as a first
 * parameter to access the "state" part that contains encoding dependent
 * data.
 */
typedef struct OMtranslationStruct {
  OMencodingType encoding;

  /* encoding part */
  OMputInt32Func putInt32;
  OMputFloat64Func putFloat64;
  OMputBigIntFunc putBigInt;
  OMputByteArrayFunc putByteArray;
  OMputStringFunc putString;
  OMputWCStringFunc putWCString;
  OMputVarFunc putVar;
  OMputSymbolFunc putSymbol;
  OMputTokenTagFunc putTokenTag;
  OMputCommentFunc putComment;
  OMbeginObjectFunc beginObject;
  OMendObjectFunc endObject;

  /* decoding part */
  OMgetInt32Func getInt32;
  OMgetFloat64Func getFloat64;
  OMgetBigIntFunc getBigInt;
  OMgetByteArrayFunc getByteArray;
  OMgetStringFunc getString;
  OMgetWCStringFunc getWCString;
  OMgetVarFunc getVar;
  OMgetSymbolFunc getSymbol;
  OMgetTokenTagFunc getTokenTag;
  OMgetCommentFunc getComment;
  OMgetTypeFunc getType;
  OMgetLengthFunc getLength;
  OMgetSymbolLengthFunc getSymbolLength;

  /* encoding dependent state */
  void *state;
} OMtranslationStruct;

typedef struct OMtranslationStruct *OMtranslation;

typedef enum OMIOType {
  OMIOunknown = 0, OMIOFd, OMIOFile, OMIOString
#ifdef WIN32
, OMIOHandle
#endif 
} OMIOType;

/* This structure abstracts what we need for the actual I/O operations.
 * Used in device structures. */
typedef struct OMIOStruct {
  OMIOType type;
  OMstatus(*init) (OMdev dev, void *arg);
  OMstatus(*flush) (OMdev dev);
  OMstatus(*putChar) (OMdev dev, char s);
  OMstatus(*write) (OMdev dev, char *s, int n);
  OMstatus(*print) (OMdev dev, char *s);
  OMstatus(*read) (OMdev dev, char *s, int n);
  int (*getChar) (OMdev dev);
  int (*lookAhead) (OMdev dev);
  void *private;		/* depends on I/O */
} OMIOStruct;


extern double OMdoubleInf, OMdoubleNegInf,  OMdoubleNaN, OMdoubleLocalNaN;

#include "OMbaseP.h"
#include "OMdevP.h"
#include "OMdevFdP.h"
#include "OMdevFileP.h"
#include "OMdevStringP.h"
#include "OMencBinP.h"
#include "OMencXmlP.h"
#include "OMencUnknP.h"
#include "OMmiscP.h"
#include "OMutf7P.h"


#endif /* __OMP_h__ */
