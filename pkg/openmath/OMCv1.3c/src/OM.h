#ifndef __OM_h__
#define __OM_h__


/*
 *                      All types used through API.
 */

/* These types are anonymized by the mean of a generic pointer.
 * You should not allocate or dereference objects of these types.
 * API (hopefully) provides you with all needed methods.
 * If you find any that are not included, please refer to 
 * us rather than using private structures.
 * ie: If you need to do something like 
 *   malloc(sizeof(OMdevStruct));
 * or
 *   OMdevStruct * pDev;
 *   pDev->anyField = something;
 * this probably means we need to discuss your problem.
 */

/* A device is an abstraction for put/get of OpenMath tokens */
typedef struct OMdevStruct *OMdev;

/* IO is a device field, (the physical IO channel) */
typedef struct OMIOStruct *OMIO;


/* Error status that may be returned 
 */
typedef enum OMstatus {
  /* Last call was successful. */
  OMsuccess = 0,
  /* Last call failed for some undetermined reason. */
  OMfailed = 1,
  /* Last call failed for memory reasons. */
  OMnoMem,
  /* Last call failed during some system call. */
  OMerrorSys,
  /* Last call to some OMget* function failed due to an unexpected EOF on input IO. */
  OMemptyIO,
  /* Last call to some OMget* function failed because there is no more token on device. */
  OMnoMoreToken,
  /* Last call to some OMget* function timeouted. */
  OMtimeoutedRead,
  /* Last call to some OMget* function failed due to malformed input. (this error covers all low level lexi 2*x*y^4 
cal or syntactic problems). */
  OMmalformedInput,
  /* Last call to OMbindTCP failed because address is already in use (EADDRINUSE). */
  OMaddrInUse,
  /* Last call to OMconnTCP failed to set connection. */
  OMconnectFailed,
  /* Last call trigered some not (yet) implemented code in this lib. */
  OMnotImplemented,
  /* Last call caused some internal trouble. */
  OMinternalError
} OMstatus;

/* All OpenMath token kinds are identified by one of these types.
 * Values given in this enum have been chosen to:
 * - avoid  conflicts whith specific XML characters 
 *   to help automatic detection of encoding type.
 *   (no: '\t'(9) '\r'(13) '\n'(10) '<'(60) or ' '(32))
 * - keep some bits (3) available for special encodings purpose
 *   (eg: sharing or big len flags in binary encoding)
 */
typedef enum OMtokenType {
  OMtokenUnknown = 0, /* error catching trick */
  OMtokenInt32 = 1,
  OMtokenBigInt = 2,
  OMtokenFloat64 = 3,
  OMtokenByteArray = 4,
  OMtokenVar = 5,
  OMtokenString = 6,
  OMtokenWCString = 7,
  OMtokenSymbol = 8,
  OMtokenComment = 15,
  OMtokenApp = 16, OMtokenEndApp = 17,
  OMtokenAttr = 18, OMtokenEndAttr = 19,
  OMtokenAtp = 20, OMtokenEndAtp = 21,
  OMtokenError = 22, OMtokenEndError = 23,
  OMtokenObject = 24, OMtokenEndObject = 25,
  OMtokenBind = 26,   OMtokenEndBind = 27, 
  OMtokenBVar = 28,   OMtokenEndBVar = 29
} OMtokenType;

typedef enum OMbigIntType {
  OMbigIntUnknown = 0,
  /* this is base 10, digits in normal order (MSB) */
  OMbigIntBase10,
  /* this is base 16, digits in normal order (MSB) */
  OMbigIntBase16
} OMbigIntType;

/* Encodings should not be "user visible"
 * We thus refer to encoding as "symbolic constants" from this enum type. */
typedef enum OMencodingType {
  /* You may set an input stream to "unknown encoding".
   * By doing this, you let library auto detect the
   * encoding type of the device during first token input.*/
  OMencodingUnknown = 0,
  /* Binary encoding, more compact than XML one. */
  OMencodingBinary,
  /* XML-like encoding, human readable. */
  OMencodingXML,
} OMencodingType;

/* This is a portable equivalent to wchar_t for unicode strings */
typedef unsigned short OMUCS2;

/* Replacment for lacking C bools */
typedef unsigned char OMbool;
#define OMfalse (0)
#define OMtrue  (1)


/*
 *                        Some global variables
 */

/* Version of this lib (eg: "1.0") */
extern const char *OMlibVersion;

/* Some textual information about this lib (eg: "debug is on" */
extern const char *OMlibInfo;

/* These pointers allow you to redefine memory managment functions used in lib. */
extern void *(*OMmalloc) (size_t size);
extern void *(*OMrealloc) (void *ptr, size_t size);
extern void (*OMfree) (void *ptr);

/* If set, this function will be called by OMfatal, thus you may use it for error handling (by default it is set to exit()) */
extern void (*OMfatal) (OMstatus status);



/* for C++ includes */
#ifdef  __cplusplus
#define OMbeginPrototypes   extern "C" {
#define OMendPrototypes     }
#else /*__cplusplus */
#define OMbeginPrototypes   
#define OMendPrototypes     
#endif /*__cplusplus */


/*
 *                       Prototypes of OpenMath API
 */


/* Prototypes that are spread along all headers are repeated here.
 * - This should ease the API users.
 *   (docs are fine but source is always the ultimate help)
 * - This allow a cleaner embeding of library 
 *   (no need to install all .h! just take this one and the .a)
 */
OMbeginPrototypes
#ifndef OM_DEV
/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */
/* OMPut* functions. 
 *    They all take a device <dev> to put token to.
 *    Some of them need more parameters to define the token content.
 *    They are thoroughly documented in OpenMath Specification shiped with the library.
 * return: a status that reflect the operation success. 
 */
extern OMstatus OMputInt32(OMdev dev, int n);
extern OMstatus OMputFloat64(OMdev dev, double *d);
extern OMstatus OMputBigInt(OMdev dev, const char *data, int len, int sign, OMbigIntType format);
extern OMstatus OMputByteArray(OMdev dev, const char *data, int len);
/* OMputString*
 *   If you want to output plain 8bits C like strings there is no need
 *   to use the OMputWCString* functions. This one is more efficient
 *   (faster and more compact output for some encodings)
 */
extern OMstatus OMputString(OMdev dev, const char *str);
extern OMstatus OMputStringN(OMdev dev, const char *str, int len);
/* OMputWCString
 *   If you are using wide char strings you need to output them 
 *   with that function rather than with OMputString.
 *   (It takes endianess into account) 
 */
extern OMstatus OMputWCString(OMdev dev, const OMUCS2 * wcstr);
extern OMstatus OMputVar(OMdev dev, const char *var);
extern OMstatus OMputVarN(OMdev dev, const char *var, int len);
extern OMstatus OMputSymbol(OMdev dev, const char *cd, const char *name);
extern OMstatus OMputSymbolN(OMdev dev, const char *cd, int clen, const char *name, int nlen);
extern OMstatus OMputApp(OMdev dev);
extern OMstatus OMputEndApp(OMdev dev);
extern OMstatus OMputAttr(OMdev dev);
extern OMstatus OMputEndAttr(OMdev dev);
extern OMstatus OMputAtp(OMdev dev);
extern OMstatus OMputEndAtp(OMdev dev);
extern OMstatus OMputBind(OMdev dev);
extern OMstatus OMputEndBind(OMdev dev);
extern OMstatus OMputBVar(OMdev dev);
extern OMstatus OMputEndBVar(OMdev dev);
extern OMstatus OMputObject(OMdev dev);
extern OMstatus OMputEndObject(OMdev dev);
extern OMstatus OMputError(OMdev dev);
extern OMstatus OMputEndError(OMdev dev);
extern OMstatus OMputComment(OMdev dev, const char *comment);
extern OMstatus OMputCommentN(OMdev dev, const char *comment, int len);
/* OMgetType
 *   Get the type of the current token on device <dev>/
 * dev: device to look at.
 * type: where to store returned type.
 * return: 0 or some error code
 */
extern OMstatus OMgetType(OMdev dev, OMtokenType * type);
/* OMgetLength
 *   Get the current token length.
 * dev: device to read from
 * len: where to put the token length 
 *      the last '\0' for string like tokens is not counted
 *      (rem: for WCString it is the number of bytes not the number of wide chars)
 * return: 0 or some error code
 */
extern OMstatus OMgetLength(OMdev dev, int *len);
/* OMgetSymbolLength
 *   Get the current token (wich is assumed to be a symbol) lengths.
 * dev: device to read from
 * clen: where to put the cd length (not counting the last '\0')
 * nlen: where to put the name length (not counting the last '\0')
 * return: 0 or some error code
 */
extern OMstatus OMgetSymbolLength(OMdev dev, int *clen, int *nlen);
/* OMGet* functions. 
 *    They all take a device <dev> to get token from.
 *    Some of them need more parameters to fill with the token content.
 *    They are thoroughly documented in OpenMath Specification shiped with the library.
 * return: a status that reflect the operation success. 
 */
extern OMstatus OMgetInt32(OMdev dev, int *i);
extern OMstatus OMgetFloat64(OMdev dev, double *d);
extern OMstatus OMgetBigInt(OMdev dev, char **data, int *len, int *sign, OMbigIntType * format);
extern OMstatus OMgetBigIntN(OMdev dev, char *data, int len, int *sign, OMbigIntType * format);
extern OMstatus OMgetByteArray(OMdev dev, char **data, int *len);
extern OMstatus OMgetByteArrayN(OMdev dev, char *data, int len);
/* OMgetString*
 *   Beware! You are not suposed to use these functions unless you know
 *   for sure you are reading plain 8bits strings.
 *   Thus it is here only for speed/space consideration in very 
 *   specific applications.
 *   If input is a 16 bit char string and you read it with these 
 *   functions you will lose the 8 most significant bits of each char.
 *   You should rather refer to OMgetWCString* functions.
 */
extern OMstatus OMgetString(OMdev dev, char **str);
extern OMstatus OMgetStringN(OMdev dev, char *str, int len);
/* OMgetWCString*
 *   These functions return 16 bits wide strings. (regardless input 
 *   was done in 8 or 16 bits mode).
 *   Thus, most if not all applications should use these functions 
 *   preferably to OMgetString*.
 */
extern OMstatus OMgetWCString(OMdev dev, OMUCS2 ** wcstr);
/* BEWARE: the <len> is suposed to be the length in bytes for the preallocated buffer <wcstr> (not the length in number of wide chars)
 */
extern OMstatus OMgetWCStringN(OMdev dev, OMUCS2 * wcstr, int len);
extern OMstatus OMgetVar(OMdev dev, char **var);
extern OMstatus OMgetVarN(OMdev dev, char *var, int len);
extern OMstatus OMgetSymbol(OMdev dev, char **cd, char **name);
extern OMstatus OMgetSymbolN(OMdev dev, char *cd, int clen, char *name, int nlen);
extern OMstatus OMgetApp(OMdev dev);
extern OMstatus OMgetEndApp(OMdev dev);
extern OMstatus OMgetAttr(OMdev dev);
extern OMstatus OMgetEndAttr(OMdev dev);
extern OMstatus OMgetAtp(OMdev dev);
extern OMstatus OMgetEndAtp(OMdev dev);
extern OMstatus OMgetBind(OMdev dev);
extern OMstatus OMgetEndBind(OMdev dev);
extern OMstatus OMgetBVar(OMdev dev);
extern OMstatus OMgetEndBVar(OMdev dev);
extern OMstatus OMgetObject(OMdev dev);
extern OMstatus OMgetEndObject(OMdev dev);
extern OMstatus OMgetError(OMdev dev);
extern OMstatus OMgetEndError(OMdev dev);
extern OMstatus OMgetComment(OMdev dev, char **comment);
extern OMstatus OMgetCommentN(OMdev dev, char *comment, int len);
/* OMbeginObject
 *   Must be called before every new OpenMath object put.
 *   (Not before every token!)
 * dev: device where new object is to be put.
 * return: status describing operation success
 */
extern OMstatus OMbeginObject(OMdev dev);
/* OMendObject
 *   Must be called after every OpenMath object put.
 *   (Not after every token!)
 * dev: device where object has been put.
 * return: status describing operation success
 */
extern OMstatus OMendObject(OMdev dev);
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
extern OMbool OMignoreComment(OMdev dev, OMbool set);
/* OMtokenCount
 *   Reports the numbe rof tokens that have been in/output on a device
 * dev: devive to examine
 * inTokenNb: where to store number of input tokens (if not NULL)
 * outTokenNb: where to store number of output tokens (if not NULL)
 */
extern void OMtokenCount(OMdev dev, int *inTokenNb, int *outTokenNb);
/* OMgetDeviceEncoding
 *   Get the currnet encoding used by a device
 * dev: device to examine
 * return: current encoding
 */
extern OMencodingType OMgetDeviceEncoding(OMdev dev);
/* OMsetDeviceEncoding
 *   Set the encoding that will be used on a device
 *   BEWARE: changing encoding on a device that has alreadybeen used for IO is unsafe.
 *   but seting encoding on a new device is safe. 
 *   (in some occasions, it is not easy to know which encoding to use at device creation)  
 * dev: device to modify
 * encoding: encoding to use
 */
extern void OMsetDeviceEncoding(OMdev dev, OMencodingType encoding);
/* OMmakeDevice
 *   Create a device from a low level IO 
 *   Warning: "IO" should be a "generated" (new) structure as it contains some 
 *   state that is private to the device. It is very dangerous for two devices 
 *   to share the same "IO" structure.
 * encoding: encoding scheme used by device
 * IO: low level I/O suport for device
 * return: a newly allocated device
 */
extern OMdev OMmakeDevice(OMencodingType encoding, OMIO IO);
/* OMcloseDevice
 *   Close a device previously created with OMmakeDevice
 *   (embedded IO is closed too)
 * dev: device to close
 */
extern void OMcloseDevice(OMdev dev);
/* OMmakeIOFd
 *   Create a low level IO object from a file descriptor.
 *   (May be used on socket for instance.)
 * fd: file descriptor to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
extern OMIO OMmakeIOFd(int fd);
/* OMmakeIOFile
 *   Create a low level IO object from a FILE*.
 *   (May be used on stdin for instance.)
 * fd: FILE* to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
extern OMIO OMmakeIOFile(FILE * f);
/* OMmakeIOString
 *   Create a low level IO object from a string (NUL terminator is not needed).
 *   (May be used for copy/paste for instance.)
 * s: pointer to string to use into the OpenMath IO object.
 *    - In case of input device the string must be NUL terminated.
 *    - In case of output device string may be reallocated
 *      to fit size of outcoming objects.
 * return: a newly allocated IO object.
 */
extern OMIO OMmakeIOString(char **s);
/* OMstatusToString
 *   Convert a status to a human readable string that explain its meaning
 * status: status to explain
 * return: corresponding string
 */
extern char *OMstatusToString(OMstatus status);
/* OMtokenTypeToString
 *   Convert a tokenType to a human readable string
 * ttype: type to convert
 * return: corresponding string
 */
extern char *OMtokenTypeToString(OMtokenType ttype);
/* OMsetVerbosityLevel
 *   When using API some infos may be loged.
 *   This set the required verbosity level.
 * level: level of verbosity.
 *        0 means nothing is nether printed
 *        1 everything is printed (default)
 *        2,... less verbose
 * return: last verbosity level
 */
extern int OMsetVerbosityLevel(int level);
/* OMsetVerbosityOutput
 *   When using API some infos may be loged.
 *   This set the destination for logs.
 * logFile: where to output logs (default is stderr)
 * return: last output
 */
extern FILE *OMsetVerbosityOutput(FILE * logFile);
/* OMlibDynamicInfo
 *   Gather some informations about lib that can't be statically determined.
 *   Complete them with some relevant static infornation too.
 * return: a newly allocated string
 */
extern char *OMlibDynamicInfo(void);
/************************************************************ End Prototypes */
/* end of automaticaly updated part */

#ifdef WIN32
#include "windows.h"

/* OMmakeIOHandle
 *   Create a low level IO object from a widows handle.
 * handle: windows handle to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
extern OMIO OMmakeIOHandle(HANDLE handle);
extern void OMfreeIOHandle(OMIO io);
#endif

#else /* OM_DEV */
/* The prototypes above are in fact collected from all these .h files */
#include "OMbase.h"
#include "OMdev.h"
#include "OMdevFd.h"
#include "OMdevFile.h"
#include "OMdevString.h"
#include "OMdevHandle.h"
#include "OMencBin.h"
#include "OMencXml.h"
#include "OMmisc.h"
#include "OMutf7.h"
#endif /* OM_DEV */

OMendPrototypes

#endif /* __OM_h__ */
