/****************************************************************************
**
*W  csxc_float.h                  GAP source                Laurent Bartholdi
**
*H  @(#)$Id: cxsc_float.h,v 1.2 2010/02/22 19:25:24 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file declares the functions for the floating point package
*/
#ifdef BANNER_CXSC_FLOAT_H
static const char *Revision_cxsc_float_h =
   "@(#)$Id: cxsc_float.h,v 1.2 2010/02/22 19:25:24 gap Exp $";
#endif

#define ERROR_CXSC(gap_name,obj)				      \
  ErrorQuit(#gap_name ": argument must be a CXSC float, not a %s",    \
	    (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define TEST_IS_INTOBJ(gap_name,obj)				\
  if (!IS_INTOBJ(obj))						\
    ErrorQuit(#gap_name ": expected a small integer, not a %s",	\
	      (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define TEST_IS_STRING(gap_name,obj)				\
  if (!IsStringConv(obj))					\
    ErrorQuit(#gap_name ": expected a string, not a %s",	\
	      (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

inline bool HAS_TYPE(Obj obj, Obj type, Obj family)
{
  if (!IS_DATOBJ(obj)) return false;
  if (TYPE_DATOBJ(obj) == type) return true;
  if (FAMILY_TYPE(TYPE_DATOBJ(obj)) == family) {
    SET_TYPE_DATOBJ(obj, type);
    return true;
  }
  return false;
}
#define IS_RP(obj) HAS_TYPE(obj,TYPE_CXSC_RP,FAMILY_CXSC_RP)
#define TEST_IS_RP(gap_name,obj)				\
  if (!IS_RP(obj))						\
    ErrorQuit(#gap_name ": expected a real, not a %s",		\
	       (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define IS_CP(obj) HAS_TYPE(obj,TYPE_CXSC_CP,FAMILY_CXSC_CP)
#define TEST_IS_CP(gap_name,obj)				\
  if (!IS_CP(obj))						\
    ErrorQuit(#gap_name ": expected a complex, not a %s",	\
	       (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define IS_RI(obj) HAS_TYPE(obj,TYPE_CXSC_RI,FAMILY_CXSC_RI)
#define TEST_IS_RI(gap_name,obj)			       	\
  if (!IS_RI(obj))						\
    ErrorQuit(#gap_name ": expected an interval, not a %s",	\
	       (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define IS_CI(obj) HAS_TYPE(obj,TYPE_CXSC_CI,FAMILY_CXSC_CI)
#define TEST_IS_CI(gap_name,obj)			       	\
  if (!IS_CI(obj))					       	\
    ErrorQuit(#gap_name ": expected a complex interval, not a %s",\
	       (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#include "except.hpp"
#include "real.hpp"
#include "complex.hpp"
#include "interval.hpp"
#include "cinterval.hpp"

/****************************************************************
 * cxsc data are stored as follows:
 * +--------------------+----------+
 * | TYPE_CXSC_RI       | interval |
 * +--------------------+----------+
 ****************************************************************/
#define RP_OBJ(obj) (*(cxsc::real *) (ADDR_OBJ(obj)+1))
#define RI_OBJ(obj) (*(cxsc::interval *) (ADDR_OBJ(obj)+1))
#define CP_OBJ(obj) (*(cxsc::complex *) (ADDR_OBJ(obj)+1))
#define CI_OBJ(obj) (*(cxsc::cinterval *) (ADDR_OBJ(obj)+1))

int cpoly(const double *opr, const double *opi, int degree, double *zeror, double *zeroi, double *heap);

/****************************************************************************
**
*E  csxc_float.h  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
