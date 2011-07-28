/****************************************************************************
 *
 * fr_dll.h                                                 Laurent Bartholdi
 *
 *   @(#)$Id: fr_dll.h,v 1.12 2011/05/09 11:12:04 gap Exp $
 *
 * Copyright (C) 2010, Laurent Bartholdi
 *
 ****************************************************************************
 *
 * header / type declarations for FR DLL add-on
 *
 ****************************************************************************/

#undef VERY_LONG_DOUBLES

#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_complex_math.h>
#include <gsl/gsl_multiroots.h>
#include "src/compiled.h"
#include "src/macfloat.h"
#include "poly.h"

#ifdef MALLOC_HACK
#include <malloc.h>
#endif

void InitP1Kernel(void);
void InitP1Library(void);

/****************************************************************
 * complex polynomials
 ****************************************************************/
typedef struct {
  size_t degree;
  gsl_complex *data;
} polynomial;

/****************************************************************************
 * externals
 ****************************************************************************/
int solve_hurwitz (const size_t degree, const size_t s, const size_t d[], const gsl_complex v[],
		   gsl_complex c[], polynomial *num, polynomial *den,
		   size_t max_iter, double eps1, double eps2);

/****************************************************************************
 * stolen from src/float.c
 ****************************************************************************/
#define VAL_FLOAT(obj) (*(Double *)ADDR_OBJ(obj))
#define SIZE_FLOAT   sizeof(Double)
#ifndef T_FLOAT
#define T_FLOAT T_MACFLOAT
#endif
static inline Obj NEW_FLOAT (Double val)
{
  Obj f = NewBag(T_FLOAT, SIZE_FLOAT);
  *(Double *)ADDR_OBJ(f) = val;
  return f;
}

static inline Obj ALLOC_PLIST (UInt len)
{
  Obj f = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(f, len);
  return f;
}

static inline gsl_complex VAL_GSL_COMPLEX (Obj f)
{
  gsl_complex v;
  GSL_SET_COMPLEX(&v, VAL_FLOAT(ELM_PLIST(f,1)), VAL_FLOAT(ELM_PLIST(f,2)));
  return v;
}

static void set_elm_plist(Obj list, UInt pos, Obj obj) /* safe to nest */
{
  SET_ELM_PLIST(list,pos,obj);
  CHANGED_BAG(list);
}

static inline Obj NEW_COMPLEX_GSL (gsl_complex *c)
{
  Obj t = ALLOC_PLIST(2);
  set_elm_plist(t,1, NEW_FLOAT(GSL_REAL(*c)));
  set_elm_plist(t,2, NEW_FLOAT(GSL_IMAG(*c)));
  return t;
}

/* fr_dll.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here */
