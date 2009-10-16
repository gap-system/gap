/* private counterpart for OMencBin.h */
#ifndef __OMencBinP_h__
#define __OMencBinP_h__

/* hash table size */
#define OM_BE_SHARETABLE_SZ 512
/* lenght of string that is used for hash */
#define OM_BE_HASHLEN 10

/* cell of share tables */
typedef struct OMBEshareStruct {
  int hashKey;			/* double collision key */
  int id;			/* the id that will be emitted instead of whole token */
  char *data;			/* data fields of token */
  int len;			/* ... */
  char *auxData;		/* ... */
  int auxLen;			/* ... */
} OMBEshareStruct;

typedef struct OMBEshareStruct *OMBEshare;

typedef struct OMBEinShareContextStruct {
  OMBEshareStruct shareTable[OM_BE_SHARETABLE_SZ];
  int nextId;			/* next new input sharable token will get this id */
  int idToKey[255];		/* for the 255 possible ids, index of corresponding token in inShareTable */
} OMBEinShareContextStruct;

typedef struct OMBEoutShareContextStruct {
  OMBEshareStruct shareTable[OM_BE_SHARETABLE_SZ];
  int nextId;			/* next new output sharable token will get this id */
} OMBEoutShareContextStruct;


typedef struct OMbinStateStruct {
  OMencodingType encoding;	/* consistency check */
  /* 
   * input
   */
  OMtokenType currentType;	/* last received token type */
  int length;			/* length of current token */
  int nlength;			/* second lenght (used for name lenght in symbols) */
  OMbool bigLen;		/* is the current token len > 255? */
  OMbool shared;		/* is the current token a reference to an old one? */
  OMbool wc;			/* is the current token a wide char string */
  int currentId;		/* if current token is shared then this is the original token id */
  OMBEinShareContextStruct inShareContextVar;
  OMBEinShareContextStruct inShareContextStr;
  OMBEinShareContextStruct inShareContextSymb;
  /* 
   * output 
   */
  OMBEoutShareContextStruct outShareContextVar;
  OMBEoutShareContextStruct outShareContextStr;
  OMBEoutShareContextStruct outShareContextSymb;
  /* 
   * debug/bench specofoc part
   */
#if OM_DEBUG
/* number of read bytes on this stream */
  int byte;
  OMbool noUnsharedWarn;
#endif
} OMbinStateStruct;

typedef struct OMbinStateStruct *OMbinState;


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/*
 *                              IO functions
 */
extern OMstatus OMBEputInt32(OMdev dev, int i);

extern OMstatus OMBEputFloat64(OMdev dev, double *d);

extern OMstatus OMBEputSLength(OMdev dev, int len);

extern OMstatus OMBEputBigInt(OMdev dev, char *data, int len, int sign, OMbigIntType format);

extern OMstatus OMBEputByteArray(OMdev dev, char *data, int len);

extern OMstatus OMBEputString(OMdev dev, char *str, int len);

extern OMstatus OMwriteHtoNUCS2Array(OMdev dev, OMUCS2 * wcstr, int len);

extern void OMswapUCS2Array(OMUCS2 * array, int len);

extern OMstatus OMBEputWCString(OMdev dev, OMUCS2 * wcstr, int len);

extern OMstatus OMBEputVar(OMdev dev, char *var, int len);

extern OMstatus OMBEputSymbol(OMdev dev, char *cd, int clen, char *name, int nlen);

extern OMstatus OMBEputTokenTag(OMdev dev, OMtokenType ttype);

extern OMstatus OMBEputComment(OMdev dev, char *comment, int len);

extern OMstatus OMBEbeginObject(OMdev dev);

extern OMstatus OMBEendObject(OMdev dev);

extern OMstatus OMBEgetSLength(OMdev dev, int *res);

/* we also read the length and store it */
extern OMstatus OMBEgetType(OMdev dev, OMtokenType * type);

extern OMstatus OMBEgetLength(OMdev dev, int *len);

extern OMstatus OMBEgetSymbolLength(OMdev dev, int *clen, int *nlen);

extern OMstatus OMBEgetInt32(OMdev dev, int *res);

extern OMstatus OMBEgetFloat64(OMdev dev, double *d);

extern OMstatus OMBEgetBigInt(OMdev dev, char **data, int *len, int *sign, OMbigIntType * format);

extern OMstatus OMBEcheckData(OMdev dev, int len, char **data, int *dataLen, int tail, char *message, OMbool wantWC);

extern void OMconvertStrings(char *src, char *dest, OMbool srcWC, OMbool destWC, int len);

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
extern OMstatus OMBEgetRaw(OMdev dev, int len, char **data, int *dataLen, int tail, char *message, OMBEinShareContextStruct * isc, OMbool wantWC);

/* OMBEgetRawDbl
 *   Like OMBEgetRaw but it gets two byte strings in a row.
 */
extern OMstatus OMBEgetRawDbl(OMdev dev, int len, char **data, int *dataLen, int len2, char **data2, int *dataLen2, int tail, char *message, OMBEinShareContextStruct * isc, OMbool wantWC);

extern OMstatus OMBEgetByteArray(OMdev dev, char **data, int *len);

extern OMstatus OMBEgetString(OMdev dev, char **str, int *len);

extern OMstatus OMBEgetWCString(OMdev dev, OMUCS2 ** wcstr, int *len);

extern OMstatus OMBEgetVar(OMdev dev, char **var, int *len);

extern OMstatus OMBEgetSymbol(OMdev dev, char **cd, int *clen, char **symb, int *slen);

extern OMstatus OMBEgetTokenTag(OMdev dev, OMtokenType ttype);

extern OMstatus OMBEgetComment(OMdev dev, char **comment, int *len);

extern void OMBEFreeTranslation(OMtranslationStruct * tr);

extern OMtranslation OMbinEncoding(void);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#include "OMencBin.h"


#endif /* __OMencBinP_h__ */
