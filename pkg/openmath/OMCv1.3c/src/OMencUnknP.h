/* private counterpart for OMencXml.h */
#ifndef __OMencUnknP_h__
#define __OMencUnknP_h__

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


extern OMstatus OMUKputInt32(OMdev dev, int i);

extern OMstatus OMUKputFloat64(OMdev dev, double *d);

extern OMstatus OMUKputBigInt(OMdev dev, char *data, int len, int sign, OMbigIntType format);

extern OMstatus OMUKputByteArray(OMdev dev, char *data, int len);

extern OMstatus OMUKputString(OMdev dev, char *str, int len);

extern OMstatus OMUKputWCString(OMdev dev, OMUCS2 * wcstr, int len);

extern OMstatus OMUKputVar(OMdev dev, char *var, int len);

extern OMstatus OMUKputSymbol(OMdev dev, char *cd, int clen, char *name, int nlen);

extern OMstatus OMUKputTokenTag(OMdev dev, OMtokenType ttype);

extern OMstatus OMUKputComment(OMdev dev, char *comment, int len);

extern OMstatus OMUKgetType(OMdev dev, OMtokenType * type);

extern OMstatus OMUKgetLength(OMdev dev, int *len);

extern OMstatus OMUKgetSymbolLength(OMdev dev, int *clen, int *nlen);

extern OMstatus OMUKgetTokenTag(OMdev dev, OMtokenType ttype);

extern OMstatus OMUKgetInt32(OMdev dev, int *i);

extern OMstatus OMUKgetFloat64(OMdev dev, double *d);

extern OMstatus OMUKgetBigInt(OMdev dev, char **data, int *len, int *sign, OMbigIntType * format);

extern OMstatus OMUKgetByteArray(OMdev dev, char **data, int *len);

extern OMstatus OMUKgetSymbol(OMdev dev, char **cd, int *clen, char **name, int *nlen);

extern OMstatus OMUKgetVar(OMdev dev, char **name, int *len);

extern OMstatus OMUKgetString(OMdev dev, char **data, int *len);

extern OMstatus OMUKgetWCString(OMdev dev, OMUCS2 ** data, int *len);

extern OMstatus OMUKgetComment(OMdev dev, char **comment, int *len);

extern void OMUKFreeTranslation(OMtranslationStruct * tr);

extern OMtranslation OMunknownEncoding(void);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#include "OMencUnkn.h"


#endif /* __OMencUnknP_h__ */
