/* private counterpart for OMutf7.h */
#ifndef __OMutf7P_h__
#define __OMutf7P_h__

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


extern OMstatus OMputUCS2AsUTF7(OMdev dev, OMUCS2 * source, int len);

extern OMstatus OMputCharAsUTF7(OMdev dev, char *source, int len);

extern OMstatus OMparseUCS2FromUTF7(OMdev dev);


/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#include "OMutf7.h"


#endif /* __OMutf7P_h__ */
