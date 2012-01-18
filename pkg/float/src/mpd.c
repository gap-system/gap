/****************************************************************************
**
*W  mpd.c                       GAP source                  Laurent Bartholdi
**
*H  @(#)$Id: mpd.c,v 1.2 2011/12/05 08:41:49 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file contains the functions for the float package.
**  complex floats are implemented using the MPD package.
*/
const char * Revision_mpd_c =
   "@(#)$Id: mpd.c,v 1.2 2011/12/05 08:41:49 gap Exp $";

#define BANNER_FLOAT_H

#include <string.h>
#include <malloc.h>
#include <stdio.h>
#include <gmp.h>

#include "src/system.h"
#include "src/gasman.h"
#include "src/objects.h"
#include "src/gap.h"
#include "src/gmpints.h"
#include "src/bool.h"
#include "src/string.h"
#include "src/plist.h"
#include "mp_float.h"

/****************************************************************
 * mpd's are stored as follows:
 * +----------+-----------------------------------------+---------------------+
 * | TYPE_MPD |               __mpd_struct              |    __mp_limb_t[]    |
 * |          | __mpfr_struct real          imag        | limbr ... limbi ... |
 * |          | prec exp sign mant   prec exp sign mant |                     |
 * +----------+-----------------------------------------+---------------------+
 *                               \___________________\____^         ^
 *                                                    \____________/
 * it is assumed that the real and imaginary mpfr's are allocated with the
 * same precision
 ****************************************************************/
#define MPD_OBJ(obj) ((mpd_ptr) (ADDR_OBJ(obj)+1))
#define REMANTISSA_MPD(p) ((mp_limb_t *) (p+1))
#define IMMANTISSA_MPD(p) (REMANTISSA_MPD(p)+(mpd_get_prec(p)+GMP_NUMB_BITS-1)/GMP_NUMB_BITS)

static inline mpd_ptr GET_MPD(Obj obj) {
  mpd_ptr p = MPD_OBJ(obj);
  mpfr_custom_move (p->re, REMANTISSA_MPD(p));
  mpfr_custom_move (p->im, IMMANTISSA_MPD(p));
  return p;
}

/****************************************************************************
**
*F  allocate new object, initialize to NaN
**
*/
Obj TYPE_MPD;

static inline Obj NEW_MPD( mp_prec_t prec )
{
  Obj f;
  f = NewBag(T_DATOBJ,sizeof(Obj)+sizeof(__mpd_struct)+2*mpfr_custom_get_size(prec));
  SET_TYPE_DATOBJ(f,TYPE_MPD);
  mpd_ptr p = MPD_OBJ(f);
  mpfr_custom_init_set(p->re, MPFR_NAN_KIND, 0, prec, REMANTISSA_MPD(p));
  mpfr_custom_init_set(p->im, MPFR_NAN_KIND, 0, prec, IMMANTISSA_MPD(p));
  return f;
}

/****************************************************************************
**
*F Func1_MPD( <float> ) . . . . . . . . . . . . . . . .1-argument functions
**
*/
#define Func1_MPD(name,mpd_name)			\
  static Obj name(Obj self, Obj f)			\
  {						        \
    mp_prec_t prec = mpd_get_prec(MPD_OBJ(f));	        \
    Obj g = NEW_MPD(prec);				\
    mpd_name (MPD_OBJ(g), GET_MPD(f), MPD_RNDNN);	\
    return g;						\
  }
#define Func1_MPFRMPD(name,mpd_name)			\
  static Obj name(Obj self, Obj f)			\
  {						        \
    mp_prec_t prec = mpd_get_prec(MPD_OBJ(f));	        \
    Obj g = NEW_MPFR(prec);				\
    mpd_name (MPFR_OBJ(g), GET_MPD(f), MPD_RNDNN);	\
    return g;						\
  }
#define Inc1_MPD_arg(name,arg)		\
  { #name, 1, arg, name, "src/mpd.c:" #name }
#define Inc1_MPD(name) Inc1_MPD_arg(name,"complex")

Func1_MPD(SIN_MPD,mpd_sin);
Func1_MPD(EXP_MPD,mpd_exp);
Func1_MPD(CONJ_MPD,mpd_conj);
Func1_MPD(AINV_MPD,mpd_neg);
Func1_MPD(SQRT_MPD,mpd_sqrt);
Func1_MPD(SQR_MPD,mpd_sqr);

Func1_MPFRMPD(ABS_MPD,mpd_abs);
Func1_MPFRMPD(NORM_MPD,mpd_norm);

static Obj ZERO_MPD(Obj self, Obj f)
{
  mp_prec_t prec = mpd_get_prec(GET_MPD(f));
  Obj g = NEW_MPD(prec);
  mpd_set_ui(MPD_OBJ(g), 0, MPD_RNDNN);
  return g;
}

static Obj ONE_MPD(Obj self, Obj f)
{
  mp_prec_t prec = mpd_get_prec(GET_MPD(f));
  Obj g = NEW_MPD(prec);
  mpd_set_ui (MPD_OBJ(g), 1, MPD_RNDNN);
  return g;
}

static Obj MPD_MAKENAN(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPD_MAKENAN",prec);

  Obj g = NEW_MPD(INT_INTOBJ(prec));
  mpfr_set_nan (MPD_OBJ(g)->re);
  mpfr_set_nan (MPD_OBJ(g)->im);
  return g;
}

static Obj MPD_MAKEINFINITY(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPD_MAKEINFINITY",prec);

  int p = INT_INTOBJ(prec);
  Obj g = NEW_MPD(p < 0 ? -p : p);
  mpfr_set_inf (MPD_OBJ(g)->re, p);
  mpfr_set_inf (MPD_OBJ(g)->im, p);
  return g;
}

static Obj INV_MPD(Obj self, Obj f)
{
  Obj g = NEW_MPD(mpd_get_prec(GET_MPD(f)));
  mpd_ui_div (MPD_OBJ(g), 1, GET_MPD(f), MPD_RNDNN);
  return g;
}

static Obj REAL_MPD(Obj self, Obj f)
{
  mp_prec_t prec = mpd_get_prec(MPD_OBJ(f));
  Obj g = NEW_MPFR(prec);
  mpfr_set (MPFR_OBJ(g), GET_MPD(f)->re, GMP_RNDN);
  return g;
}

static Obj IMAG_MPD(Obj self, Obj f)
{
  mp_prec_t prec = mpd_get_prec(MPD_OBJ(f));
  Obj g = NEW_MPFR(prec);
  mpfr_set (MPFR_OBJ(g), GET_MPD(f)->im, GMP_RNDN);
  return g;
}

static Obj MPD_INT(Obj self, Obj i)
{
  Obj g;
  if (IS_INTOBJ(i)) {
    g = NEW_MPD(8*sizeof(long));
    mpd_set_si(MPD_OBJ(g), INT_INTOBJ(i), MPD_RNDNN);
  } else {
    Obj f = MPZ_LONGINT(i);
    g = NEW_MPD(8*sizeof(mp_limb_t)*SIZE_INT(i));
    
    mpfr_set_z(MPD_OBJ(g)->re, mpz_MPZ(f), GMP_RNDN);
    mpfr_set_ui(MPD_OBJ(g)->im, 0, GMP_RNDN);
  }
  return g;
}

static Obj MPD_INTPREC(Obj self, Obj i, Obj prec)
{
  Obj g;
  TEST_IS_INTOBJ("MPD_INTPREC",prec);

  if (IS_INTOBJ(i)) {
    g = NEW_MPD(INT_INTOBJ(prec));
    mpd_set_si(MPD_OBJ(g), INT_INTOBJ(i), MPD_RNDNN);
  } else {
    Obj f = MPZ_LONGINT(i);
    g = NEW_MPD(INT_INTOBJ(prec));
    
    mpfr_set_z(MPD_OBJ(g)->re, mpz_MPZ(f), GMP_RNDN);
    mpfr_set_ui(MPD_OBJ(g)->im, 0, GMP_RNDN);
  }
  return g;
}

static Obj PREC_MPD(Obj self, Obj f)
{
  return INTOBJ_INT(mpd_get_prec(GET_MPD(f)));
}

static Obj MPD_MPDPREC(Obj self, Obj f, Obj prec)
{
  TEST_IS_INTOBJ("MPD_MPDPREC",prec);

  Obj g = NEW_MPD(INT_INTOBJ(prec));
  mpd_set (MPD_OBJ(g), GET_MPD(f), MPD_RNDNN);
  return g;
}

static Obj STRING_MPD(Obj self, Obj f, Obj digits)
{
  mp_prec_t prec = mpd_get_prec(GET_MPD(f));
  Obj str = NEW_STRING(2*(prec*302/1000+10)+3);
  int slen = 0, n;

  TEST_IS_INTOBJ("STRING_MPD",digits);
  n = INT_INTOBJ(digits);
  if (n == 1) n = 2;

  char *c = CSTR_STRING(str);
  slen += PRINT_MPFR(c+slen, 0, n, GET_MPD(f)->re, GMP_RNDN);
  c[slen++] = '+';
  c[slen++] = 'I';
  c[slen++] = '*';
  slen += PRINT_MPFR(c+slen, 0, n, MPD_OBJ(f)->im, GMP_RNDN);
  SET_LEN_STRING(str, slen);
  SHRINK_STRING(str);

  return str;
}

static Obj VIEWSTRING_MPD(Obj self, Obj f, Obj digits)
{
  mp_prec_t prec = mpd_get_prec(GET_MPD(f));
  Obj str = NEW_STRING(2*(prec*302/1000+10)+3);
  int slen = 0, n;

  TEST_IS_INTOBJ("STRING_MPD",digits);
  n = INT_INTOBJ(digits);
  if (n == 1) n = 2;

  char *c = CSTR_STRING(str);
  slen += PRINT_MPFR(c+slen, 0, n, GET_MPD(f)->re, GMP_RNDN);
  Obj im = NEW_MPFR(prec);
  mpfr_add(MPFR_OBJ(im), GET_MPD(f)->re, GET_MPD(f)->im, GMP_RNDN);
  mpfr_sub(MPFR_OBJ(im), MPFR_OBJ(im), MPD_OBJ(f)->re, GMP_RNDN); /* round off small im */
  if (!mpfr_zero_p(MPFR_OBJ(im))) {
    if (mpfr_sgn(MPFR_OBJ(im)) < 0)
      c[slen++] = '-';
    else
      c[slen++] = '+';
    mpfr_abs (MPFR_OBJ(im), MPD_OBJ(f)->im, GMP_RNDN);
    c[slen++] = 'I';
    c[slen++] = '*';
    slen += PRINT_MPFR(c+slen, 0, n, MPFR_OBJ(im), GMP_RNDN);
  }
  SET_LEN_STRING(str, slen);
  SHRINK_STRING(str);

  return str;
}

static Obj MPD_STRING(Obj self, Obj s, Obj prec)
{
  while (!IsStringConv(s))
    {
      s = ErrorReturnObj("MPD_STRING: object to be converted must be a string, not a %s",
			 (Int)(InfoBags[TNUM_OBJ(s)].name),0,
			 "You can return a string to continue" );
    }
  TEST_IS_INTOBJ("MPD_STRING",prec);
  int n = INT_INTOBJ(prec);
  if (n == 0)
    n = GET_LEN_STRING(s)*1000 / 301;

  Obj g = NEW_MPD(INT_INTOBJ(prec));
  char *p = (char *) CHARS_STRING(s), *newp;
  int sign = 1;
  mpd_set_ui(MPD_OBJ(g), 0, MPD_RNDNN);
  mpfr_ptr f = MPD_OBJ(g)->re;
  Obj newg = NEW_MPFR(INT_INTOBJ(prec));

  for (;;) {
    printf("<%c>",*p);
    switch (*p) {
    case '-':
    case '+':
    case 0:
      if (!mpfr_nan_p(MPFR_OBJ(newg))) { /* drop the last read float */
	mpfr_add (f, f, MPFR_OBJ(newg), GMP_RNDN);
	mpfr_set_nan (MPFR_OBJ(newg));
	f = MPD_OBJ(g)->re;
	sign = 1;
      }
      if (!*p)
	return g;
      if (*p == '-')
	sign = -sign;
    case '*': p++; break;
    case 'i':
    case 'I': if (f == GET_MPD(g)->re) {
	f = MPD_OBJ(g)->im;
	if (mpfr_nan_p(MPFR_OBJ(newg)))
	  mpfr_set_si (MPFR_OBJ(newg), sign, GMP_RNDN); /* accept 'i' as '1*i' */
      } else return Fail;
      p++; break;
    default:
      mpfr_strtofr(MPFR_OBJ(newg), p, &newp, 10, GMP_RNDN);
      if (newp == p && f != GET_MPD(g)->im)
	return Fail; /* no valid characters read */
      if (sign == -1)
	mpfr_neg(MPFR_OBJ(newg), MPFR_OBJ(newg), GMP_RNDN);
      p = newp;
    }
  }
  return g;
}

static Obj MPD_MPFR(Obj self, Obj f)
{
  Obj g = NEW_MPD (mpfr_get_prec(GET_MPFR(f)));
  mpfr_set (MPD_OBJ(g)->re, GET_MPFR(f), GMP_RNDN);
  mpfr_set_ui (MPD_OBJ(g)->im, 0, GMP_RNDN);

  return g;
}

/****************************************************************************
**
*F Func2_MPD( <float>, <float> ) . . . . . . . . . . . 2-argument functions
**
*/
#define Func2_MPD(name,mpd_name)					\
  static Obj name(Obj self, Obj fl, Obj fr)				\
  {									\
    mp_prec_t precl = mpd_get_prec(GET_MPD(fl)),			\
      precr = mpd_get_prec(GET_MPD(fr));				\
									\
    Obj g = NEW_MPD(precl > precr ? precl : precr);			\
    mpd_name (MPD_OBJ(g), GET_MPD(fl), GET_MPD(fr), MPD_RNDNN);		\
    return g;								\
  }
#define Inc2_MPD_arg(name,arg)			\
  { #name, 2, arg, name, "src/mpd.c:" #name }
#define Inc2_MPD(name) Inc2_MPD_arg(name,"complex, complex")

Func2_MPD(SUM_MPD,mpd_add);
Func2_MPD(DIFF_MPD,mpd_sub);
Func2_MPD(PROD_MPD,mpd_mul);
Func2_MPD(QUO_MPD,mpd_div);

static Obj LQUO_MPD(Obj self, Obj fl, Obj fr)
{
  mp_prec_t precl = mpd_get_prec(GET_MPD(fl)),
    precr = mpd_get_prec(GET_MPD(fr));
  
  Obj g = NEW_MPD(precl > precr ? precl : precr);
  mpd_div (MPD_OBJ(g), GET_MPD(fr), GET_MPD(fl), MPD_RNDNN);
  return g;
}

static Obj EQ_MPD (Obj self, Obj fl, Obj fr)
{
  return mpd_cmp(GET_MPD(fr),GET_MPD(fl)) == 0 ? True : False;
}

static Obj LT_MPD (Obj self, Obj fl, Obj fr)
{
  return mpd_cmp(GET_MPD(fl),GET_MPD(fr)) < 0 ? True : False;
}

static Obj MPD_2MPFR (Obj self, Obj fl, Obj fr)
{
  mp_prec_t precl = mpfr_get_prec(GET_MPFR(fl)),
    precr = mpfr_get_prec(GET_MPFR(fr));
  
  Obj g = NEW_MPD(precl > precr ? precl : precr);
  mpfr_set (MPD_OBJ(g)->re, GET_MPFR(fl), GMP_RNDN);
  mpfr_set (MPD_OBJ(g)->im, GET_MPFR(fr), GMP_RNDN);

  return g;
}

/****************************************************************
 * export functions
 ****************************************************************/
static StructGVarFunc GVarFuncs [] = {  
  Inc1_MPD(AINV_MPD),
  Inc1_MPD(ABS_MPD),
  Inc1_MPD(INV_MPD),
  Inc1_MPD(SIN_MPD),
  Inc1_MPD(EXP_MPD),
  Inc1_MPD(SQRT_MPD),
  Inc1_MPD(SQR_MPD),
  Inc1_MPD(CONJ_MPD),

  Inc1_MPD(ZERO_MPD),
  Inc1_MPD(ONE_MPD),
  Inc1_MPD_arg(MPD_MAKENAN,"int"),
  Inc1_MPD_arg(MPD_MAKEINFINITY,"int"),
  Inc1_MPD_arg(MPD_INT,"int"),
  Inc1_MPD(PREC_MPD),
  Inc1_MPD(REAL_MPD),
  Inc1_MPD(IMAG_MPD),
  Inc1_MPD(MPD_MPFR),
  Inc1_MPD(NORM_MPD),
  
  Inc2_MPD(SUM_MPD),
  Inc2_MPD(DIFF_MPD),
  Inc2_MPD(PROD_MPD),
  Inc2_MPD(QUO_MPD),
  Inc2_MPD(LQUO_MPD),
  Inc2_MPD(EQ_MPD),
  Inc2_MPD(LT_MPD),
  Inc2_MPD_arg(MPD_STRING,"string, int"),
  Inc2_MPD_arg(STRING_MPD,"complex, int"),
  Inc2_MPD_arg(VIEWSTRING_MPD,"complex, int"),
  Inc2_MPD_arg(MPD_INTPREC,"int, int"),
  Inc2_MPD_arg(MPD_MPDPREC,"complex, int"),
  Inc2_MPD(MPD_2MPFR),

  {0}
};

int InitMPDKernel (void)
{
  ImportGVarFromLibrary ("TYPE_MPD", &TYPE_MPD);
  return 0;
}

int InitMPDLibrary (void)
{
  InitGVarFuncsFromTable (GVarFuncs);
  return 0;
}

/****************************************************************************
**
*E  mpd.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . .ends here
*/
