/* private counterpart for OMdev.h */
#ifndef __OMdevP_h__
#define __OMdevP_h__

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


extern int OMWCStrLen(const OMUCS2 * wcstr);

extern OMstatus OMputWCStringN(OMdev dev, const OMUCS2 * wcstr, int len);

extern void OMfreeTranslation(OMtranslationStruct * tr);

extern void OMfreeIO(OMIOStruct * io);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#include "OMdev.h"


#endif /* __OMdevP_h__ */
