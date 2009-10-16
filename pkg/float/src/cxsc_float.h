/****************************************************************************
**
*W  csxc_float.h                  GAP source                Laurent Bartholdi
**
*H  @(#)$Id: cxsc_float.h,v 1.1 2008/06/14 15:45:40 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file declares the functions for the floating point package
*/
#ifdef BANNER_CXSC_FLOAT_H
static const char *Revision_cxsc_float_h =
   "@(#)$Id: cxsc_float.h,v 1.1 2008/06/14 15:45:40 gap Exp $";
#endif

#define ERROR_CXSC(gap_name,obj)				      \
  ErrorQuit(#gap_name ": argument must be a CXSC float, not a %s",    \
	    (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define RETURNERROR_CXSC(gap_name,obj)				      \
  ErrorQuit(#gap_name ": argument must be a CXSC float, not a %s",    \
	    (Int)(InfoBags[TNUM_OBJ(obj)].name),0); return Fail;

#define TEST_IS_INTOBJ(mp_name,obj)				\
  if (!IS_INTOBJ(obj))						\
    ErrorQuit(mp_name ": expected a small integer, not a %s",	\
	      (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define TEST_IS_STRING(mp_name,obj)				\
  if (!IsStringConv(obj))					\
    ErrorQuit(mp_name ": expected a string, not a %s",		\
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
#define IS_REAL(obj) HAS_TYPE(obj,TYPE_CXSC_REAL,FAMILY_CXSC_REAL)
#define TEST_IS_REAL(mp_name,obj)				\
  if (!IS_REAL(obj))						\
    ErrorQuit(mp_name ": expected a real, not a %s",		\
	       (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define IS_COMPLEX(obj) HAS_TYPE(obj,TYPE_CXSC_COMPLEX,FAMILY_CXSC_COMPLEX)
#define TEST_IS_COMPLEX(mp_name,obj)		       		\
  if (!IS_COMPLEX(obj))						\
    ErrorQuit(mp_name ": expected a complex, not a %s",		\
	       (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define IS_INTERVAL(obj) HAS_TYPE(obj,TYPE_CXSC_INTERVAL,FAMILY_CXSC_INTERVAL)
#define TEST_IS_INTERVAL(mp_name,obj)		       		\
  if (!IS_INTERVAL(obj))			       		\
    ErrorQuit(mp_name ": expected an interval, not a %s",	\
	       (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#define IS_CINTERVAL(obj) HAS_TYPE(obj,TYPE_CXSC_CINTERVAL,FAMILY_CXSC_CINTERVAL)
#define TEST_IS_CINTERVAL(mp_name,obj)				\
  if (!IS_CINTERVAL(obj))					\
    ErrorQuit(mp_name ": expected a complex interval, not a %s",\
	       (Int)(InfoBags[TNUM_OBJ(obj)].name),0)

#include "except.hpp"
#include "real.hpp"
#include "complex.hpp"
#include "interval.hpp"
#include "cinterval.hpp"

/****************************************************************
 * cxsc data are stored as follows:
 * +--------------------+----------+
 * | TYPE_CXSC_INTERVAL | interval |
 * +--------------------+----------+
 ****************************************************************/
#define REAL_OBJ(obj) (*(cxsc::real *) (ADDR_OBJ(obj)+1))
#define INTERVAL_OBJ(obj) (*(cxsc::interval *) (ADDR_OBJ(obj)+1))
#define COMPLEX_OBJ(obj) (*(cxsc::complex *) (ADDR_OBJ(obj)+1))
#define CINTERVAL_OBJ(obj) (*(cxsc::cinterval *) (ADDR_OBJ(obj)+1))

int cpoly(const double *opr, const double *opi, int degree, double *zeror, double *zeroi, double *heap);

/****************************************************************************
**
*E  csxc_float.h  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
