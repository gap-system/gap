/* private counterpart for OMencXml.h */
#ifndef __OMencXmlP_h__
#define __OMencXmlP_h__

typedef enum OMindentType {
  OMindentNone = 0,
  OMindentNormal
} OMindentType;



/* This is complicated because we choose not to have a length in front of
 * "vars", "strings" or "bytearrays".
 * Thus, we have to "buffer" the data.
 */
typedef struct OMXmlStateStruct {
  OMencodingType encoding;
  /* current token, "OMtokenUnknown" if we don't know */
  OMtokenType currentType;
  /* indentation */
  OMindentType indentMode;
  int indentLevel;
  int indentTab;
  /* length of the token in "buf" (resp bufAux) */
  int bufUsed;
  int bufAuxUsed;
  /* length of buf (resp bufAux) */
  int bufSize;
  int bufAuxSize;
  /* used as token tmp storage */
  char *buf;
  char *bufAux;
  /* used for int32 and Bigint */
  int sign;
  int i;
  OMbigIntType format;
  /* used for float64 */
  double d;

#if OM_DEBUG
  /* line counter used for more informative warnings */
  int line;
#endif
} OMXmlStateStruct;

typedef struct OMXmlStateStruct *OMXmlState;


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/* These functions are to be used inside the "put" structure in the device */
extern OMstatus OMSEputInt32(OMdev dev, int i);

extern OMstatus OMSEputFloat64(OMdev dev, double *d);

extern OMstatus OMSEputBigInt(OMdev dev, char *data, int len, int sign, OMbigIntType format);

extern OMstatus OMSEputByteArray(OMdev dev, char *data, int len);

extern OMstatus OMSEputString(OMdev dev, char *str, int len);

extern OMstatus OMSEputWCString(OMdev dev, OMUCS2 * wcstr, int len);

extern OMstatus OMSEputVar(OMdev dev, char *var, int len);

extern OMstatus OMSEputSymbol(OMdev dev, char *cd, int clen, char *name, int nlen);

extern OMstatus OMSEputTokenTag(OMdev dev, OMtokenType ttype);

extern OMstatus OMSEputComment(OMdev dev, char *comment, int len);

extern OMstatus OMSEbeginObject(OMdev dev);

extern OMstatus OMSEendObject(OMdev dev);

extern OMstatus OMSEreallocBuf(OMXmlState state);

extern OMstatus OMSEgetType(OMdev dev, OMtokenType * type);

extern OMstatus OMSEgetSymbolLength(OMdev dev, int *clen, int *nlen);

extern OMstatus OMSEgetLength(OMdev dev, int *len);

extern OMstatus OMSEgetTokenTag(OMdev dev, OMtokenType ttype);

extern OMstatus OMSEgetInt32(OMdev dev, int *i);

extern OMstatus OMSEgetFloat64(OMdev dev, double *d);

extern OMstatus OMSEgetBigInt(OMdev dev, char **data, int *len, int *sign, OMbigIntType * format);

extern OMstatus OMSEgetByteArray(OMdev dev, char **data, int *len);

extern OMstatus OMSEgetSymbol(OMdev dev, char **cd, int *clen, char **name, int *nlen);

extern OMstatus OMSEgetVar(OMdev dev, char **name, int *len);

extern OMstatus OMSEgetString(OMdev dev, char **data, int *len);

extern OMstatus OMSEgetWCString(OMdev dev, OMUCS2 ** data, int *len);

extern OMstatus OMSEgetComment(OMdev dev, char **comment, int *len);

extern void OMSEFreeTranslation(OMtranslationStruct * tr);

extern OMtranslation OMXMLEncoding(void);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#include "OMencXml.h"


#endif /* __OMencXmlP_h__ */
