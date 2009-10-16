

/* private counterpart for OMconn.h */
#ifndef __OMconnP_h__
#define __OMconnP_h__

#include "OMP.h"
#include "OMconn.h"



/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */



/************************************************************ End Prototypes */
/* end of automaticaly updated part */



typedef struct OMconnStruct {
  OMdev in;
  OMdev out;
  OMstatus error;
  int timeout;
} OMconnStruct;


#endif /* __OMconnP_h__ */
