
/* public header for OMdev.c */
#ifndef __OMdev_h__
#define __OMdev_h__

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


/************************************************************ End Prototypes */
/* end of automaticaly updated part */






#endif /* __OMdev_h__ */
