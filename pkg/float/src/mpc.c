/****************************************************************************
**
*W  mpc.c                       GAP source                  Laurent Bartholdi
**
*H  @(#)$Id: mpc.c,v 1.1 2008/06/14 15:45:40 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file contains the functions for the float package.
**  complex floats are implemented using the MPC package.
*/
const char * Revision_mpc_c =
   "@(#)$Id: mpc.c,v 1.1 2008/06/14 15:45:40 gap Exp $";

#define USE_GMP

#include <string.h>
#include <malloc.h>
#include <stdio.h>

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
 * mpc's are stored as follows:
 * +----------+-----------------------------------------+---------------------+
 * | TYPE_MPC |               __mpc_struct              |    __mp_limb_t[]    |
 * |          | __mpfr_struct real          imag        | limbr ... limbi ... |
 * |          | prec exp sign mant   prec exp sign mant |                     |
 * +----------+-----------------------------------------+---------------------+
 *                               \___________________\____^         ^
 *                                                    \____________/
 * it is assumed that the real and imaginary mpfr's are allocated with the
 * same precision
 ****************************************************************/
#define MPC_OBJ(obj) ((mpc_ptr) (ADDR_OBJ(obj)+1))
#define REMANTISSA_MPC(p) ((mp_limb_t *) (p+1))
#define IMMANTISSA_MPC(p) (REMANTISSA_MPC(p)+(mpc_get_prec(p)+GMP_NUMB_BITS-1)/GMP_NUMB_BITS)

static inline mpc_ptr GET_MPC(Obj obj) {
  mpc_ptr p = MPC_OBJ(obj);
  mpfr_custom_move (p->re, REMANTISSA_MPC(p));
  mpfr_custom_move (p->im, IMMANTISSA_MPC(p));
  return p;
}

/****************************************************************************
**
*F  allocate new object, initialize to NaN
**
*/
Obj TYPE_MPC;

static inline Obj NEW_MPC( mp_prec_t prec )
{
  Obj f;
  f = NewBag(T_DATOBJ,sizeof(Obj)+sizeof(__mpc_struct)+2*mpfr_custom_get_size(prec));
  SET_TYPE_DATOBJ(f,TYPE_MPC);
  mpc_ptr p = MPC_OBJ(f);
  mpfr_custom_init_set(p->re, MPFR_NAN_KIND, 0, prec, REMANTISSA_MPC(p));
  mpfr_custom_init_set(p->im, MPFR_NAN_KIND, 0, prec, IMMANTISSA_MPC(p));
  return f;
}

/****************************************************************************
**
*F Func1_MPC( <float> ) . . . . . . . . . . . . . . . .1-argument functions
**
*/
#define Func1_MPC(name,mpc_name)			\
  static Obj name(Obj self, Obj f)			\
  {						        \
    mp_prec_t prec = mpc_get_prec(MPC_OBJ(f));	        \
    Obj g = NEW_MPC(prec);				\
    mpc_name (MPC_OBJ(g), GET_MPC(f), MPC_RNDNN);	\
    return g;						\
  }
#define Func1_MPFRMPC(name,mpc_name)			\
  static Obj name(Obj self, Obj f)			\
  {						        \
    mp_prec_t prec = mpc_get_prec(MPC_OBJ(f));	        \
    Obj g = NEW_MPFR(prec);				\
    mpc_name (MPFR_OBJ(g), GET_MPC(f), MPC_RNDNN);	\
    return g;						\
  }
#define Inc1_MPC_arg(name,arg)		\
  { #name, 1, arg, name, "src/mpc.c:" #name }
#define Inc1_MPC(name) Inc1_MPC_arg(name,"complex")

Func1_MPC(SIN_MPC,mpc_sin);
Func1_MPC(EXP_MPC,mpc_exp);
Func1_MPC(CONJ_MPC,mpc_conj);
Func1_MPC(AINV_MPC,mpc_neg);
Func1_MPC(SQRT_MPC,mpc_sqrt);
Func1_MPC(SQR_MPC,mpc_sqr);

Func1_MPFRMPC(ABS_MPC,mpc_abs);
Func1_MPFRMPC(NORM_MPC,mpc_norm);

static Obj ZERO_MPC(Obj self, Obj f)
{
  mp_prec_t prec = mpc_get_prec(GET_MPC(f));
  Obj g = NEW_MPC(prec);
  mpc_set_ui(MPC_OBJ(g), 0, MPC_RNDNN);
  return g;
}

static Obj ONE_MPC(Obj self, Obj f)
{
  mp_prec_t prec = mpc_get_prec(GET_MPC(f));
  Obj g = NEW_MPC(prec);
  mpc_set_ui (MPC_OBJ(g), 1, MPC_RNDNN);
  return g;
}

static Obj MPC_MAKENAN(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPC_MAKENAN",prec);

  Obj g = NEW_MPC(INT_INTOBJ(prec));
  mpfr_set_nan (MPC_OBJ(g)->re);
  mpfr_set_nan (MPC_OBJ(g)->im);
  return g;
}

static Obj MPC_MAKEINFINITY(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPC_MAKEINFINITY",prec);

  int p = INT_INTOBJ(prec);
  Obj g = NEW_MPC(p < 0 ? -p : p);
  mpfr_set_inf (MPC_OBJ(g)->re, p);
  mpfr_set_inf (MPC_OBJ(g)->im, p);
  return g;
}

static Obj INV_MPC(Obj self, Obj f)
{
  Obj g = NEW_MPC(mpc_get_prec(GET_MPC(f)));
  mpc_ui_div (MPC_OBJ(g), 1, GET_MPC(f), MPC_RNDNN);
  return g;
}

static Obj REAL_MPC(Obj self, Obj f)
{
  mp_prec_t prec = mpc_get_prec(MPC_OBJ(f));
  Obj g = NEW_MPFR(prec);
  mpfr_set (MPFR_OBJ(g), GET_MPC(f)->re, GMP_RNDN);
  return g;
}

static Obj IMAG_MPC(Obj self, Obj f)
{
  mp_prec_t prec = mpc_get_prec(MPC_OBJ(f));
  Obj g = NEW_MPFR(prec);
  mpfr_set (MPFR_OBJ(g), GET_MPC(f)->im, GMP_RNDN);
  return g;
}

static Obj MPC_INT(Obj self, Obj i)
{
  Obj g;
  if (IS_INTOBJ(i)) {
    g = NEW_MPC(8*sizeof(long));
    mpc_set_si(MPC_OBJ(g), INT_INTOBJ(i), MPC_RNDNN);
  } else {
    Obj f = MPZ_LONGINT(i);
    g = NEW_MPC(8*sizeof(mp_limb_t)*SIZE_INT(i));
    
    mpfr_set_z(MPC_OBJ(g)->re, mpz_MPZ(f), GMP_RNDN);
    mpfr_set_ui(MPC_OBJ(g)->im, 0, GMP_RNDN);
  }
  return g;
}

static Obj MPC_INTPREC(Obj self, Obj i, Obj prec)
{
  Obj g;
  TEST_IS_INTOBJ("MPC_INTPREC",prec);

  if (IS_INTOBJ(i)) {
    g = NEW_MPC(INT_INTOBJ(prec));
    mpc_set_si(MPC_OBJ(g), INT_INTOBJ(i), MPC_RNDNN);
  } else {
    Obj f = MPZ_LONGINT(i);
    g = NEW_MPC(INT_INTOBJ(prec));
    
    mpfr_set_z(MPC_OBJ(g)->re, mpz_MPZ(f), GMP_RNDN);
    mpfr_set_ui(MPC_OBJ(g)->im, 0, GMP_RNDN);
  }
  return g;
}

static Obj PREC_MPC(Obj self, Obj f)
{
  return INTOBJ_INT(mpc_get_prec(GET_MPC(f)));
}

static Obj MPC_MPCPREC(Obj self, Obj f, Obj prec)
{
  TEST_IS_INTOBJ("MPC_MPCPREC",prec);

  Obj g = NEW_MPC(INT_INTOBJ(prec));
  mpc_set (MPC_OBJ(g), GET_MPC(f), MPC_RNDNN);
  return g;
}

static Obj STRING_MPC(Obj self, Obj f, Obj digits)
{
  mp_prec_t prec = mpc_get_prec(GET_MPC(f));
  Obj str = NEW_STRING(2*(prec*302/1000+10)+3);
  int slen = 0, n;

  TEST_IS_INTOBJ("STRING_MPC",digits);
  n = INT_INTOBJ(digits);
  if (n == 1) n = 2;

  char *c = CSTR_STRING(str);
  slen += PRINT_MPFR(c+slen, 0, n, GET_MPC(f)->re, GMP_RNDN);
  c[slen++] = '+';
  c[slen++] = 'I';
  c[slen++] = '*';
  slen += PRINT_MPFR(c+slen, 0, n, MPC_OBJ(f)->im, GMP_RNDN);
  SET_LEN_STRING(str, slen);
  SHRINK_STRING(str);

  return str;
}

static Obj VIEWSTRING_MPC(Obj self, Obj f, Obj digits)
{
  mp_prec_t prec = mpc_get_prec(GET_MPC(f));
  Obj str = NEW_STRING(2*(prec*302/1000+10)+3);
  int slen = 0, n;

  TEST_IS_INTOBJ("STRING_MPC",digits);
  n = INT_INTOBJ(digits);
  if (n == 1) n = 2;

  char *c = CSTR_STRING(str);
  slen += PRINT_MPFR(c+slen, 0, n, GET_MPC(f)->re, GMP_RNDN);
  Obj im = NEW_MPFR(prec);
  mpfr_add(MPFR_OBJ(im), GET_MPC(f)->re, GET_MPC(f)->im, GMP_RNDN);
  mpfr_sub(MPFR_OBJ(im), MPFR_OBJ(im), MPC_OBJ(f)->re, GMP_RNDN); /* round off small im */
  if (!mpfr_zero_p(MPFR_OBJ(im))) {
    if (mpfr_sgn(MPFR_OBJ(im)) < 0)
      c[slen++] = '-';
    else
      c[slen++] = '+';
    mpfr_abs (MPFR_OBJ(im), MPC_OBJ(f)->im, GMP_RNDN);
    c[slen++] = 'I';
    c[slen++] = '*';
    slen += PRINT_MPFR(c+slen, 0, n, MPFR_OBJ(im), GMP_RNDN);
  }
  SET_LEN_STRING(str, slen);
  SHRINK_STRING(str);

  return str;
}

static Obj MPC_STRING(Obj self, Obj s, Obj prec)
{
  while (!IsStringConv(s))
    {
      s = ErrorReturnObj("MPC_STRING: object to be converted must be a string, not a %s",
			 (Int)(InfoBags[TNUM_OBJ(s)].name),0,
			 "You can return a string to continue" );
    }
  TEST_IS_INTOBJ("MPC_STRING",prec);
  int n = INT_INTOBJ(prec);
  if (n == 0)
    n = GET_LEN_STRING(s)*1000 / 301;

  Obj g = NEW_MPC(INT_INTOBJ(prec));
  char *p = (char *) CHARS_STRING(s), *newp;
  int sign = 1;
  mpc_set_ui(MPC_OBJ(g), 0, MPC_RNDNN);
  mpfr_ptr f = MPC_OBJ(g)->re;
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
	f = MPC_OBJ(g)->re;
	sign = 1;
      }
      if (!*p)
	return g;
      if (*p == '-')
	sign = -sign;
    case '*': p++; break;
    case 'i':
    case 'I': if (f == GET_MPC(g)->re) {
	f = MPC_OBJ(g)->im;
	if (mpfr_nan_p(MPFR_OBJ(newg)))
	  mpfr_set_si (MPFR_OBJ(newg), sign, GMP_RNDN); /* accept 'i' as '1*i' */
      } else return Fail;
      p++; break;
    default:
      mpfr_strtofr(MPFR_OBJ(newg), p, &newp, 10, GMP_RNDN);
      if (newp == p && f != GET_MPC(g)->im)
	return Fail; /* no valid characters read */
      if (sign == -1)
	mpfr_neg(MPFR_OBJ(newg), MPFR_OBJ(newg), GMP_RNDN);
      p = newp;
    }
  }
  return g;
}

static Obj MPC_MPFR(Obj self, Obj f)
{
  Obj g = NEW_MPC (mpfr_get_prec(GET_MPFR(f)));
  mpfr_set (MPC_OBJ(g)->re, GET_MPFR(f), GMP_RNDN);
  mpfr_set_ui (MPC_OBJ(g)->im, 0, GMP_RNDN);

  return g;
}

/****************************************************************************
**
*F Func2_MPC( <float>, <float> ) . . . . . . . . . . . 2-argument functions
**
*/
#define Func2_MPC(name,mpc_name)					\
  static Obj name(Obj self, Obj fl, Obj fr)				\
  {									\
    mp_prec_t precl = mpc_get_prec(GET_MPC(fl)),			\
      precr = mpc_get_prec(GET_MPC(fr));				\
									\
    Obj g = NEW_MPC(precl > precr ? precl : precr);			\
    mpc_name (MPC_OBJ(g), GET_MPC(fl), GET_MPC(fr), MPC_RNDNN);		\
    return g;								\
  }
#define Inc2_MPC_arg(name,arg)			\
  { #name, 2, arg, name, "src/mpc.c:" #name }
#define Inc2_MPC(name) Inc2_MPC_arg(name,"complex, complex")

Func2_MPC(SUM_MPC,mpc_add);
Func2_MPC(DIFF_MPC,mpc_sub);
Func2_MPC(PROD_MPC,mpc_mul);
Func2_MPC(QUO_MPC,mpc_div);

static Obj LQUO_MPC(Obj self, Obj fl, Obj fr)
{
  mp_prec_t precl = mpc_get_prec(GET_MPC(fl)),
    precr = mpc_get_prec(GET_MPC(fr));
  
  Obj g = NEW_MPC(precl > precr ? precl : precr);
  mpc_div (MPC_OBJ(g), GET_MPC(fr), GET_MPC(fl), MPC_RNDNN);
  return g;
}

static Obj EQ_MPC (Obj self, Obj fl, Obj fr)
{
  return mpc_cmp(GET_MPC(fr),GET_MPC(fl)) == 0 ? True : False;
}

static Obj LT_MPC (Obj self, Obj fl, Obj fr)
{
  return mpc_cmp(GET_MPC(fl),GET_MPC(fr)) < 0 ? True : False;
}

static Obj MPC_2MPFR (Obj self, Obj fl, Obj fr)
{
  mp_prec_t precl = mpfr_get_prec(GET_MPFR(fl)),
    precr = mpfr_get_prec(GET_MPFR(fr));
  
  Obj g = NEW_MPC(precl > precr ? precl : precr);
  mpfr_set (MPC_OBJ(g)->re, GET_MPFR(fl), GMP_RNDN);
  mpfr_set (MPC_OBJ(g)->im, GET_MPFR(fr), GMP_RNDN);

  return g;
}

/****************************************************************
 * export functions
 ****************************************************************/
static StructGVarFunc GVarFuncs [] = {  
  Inc1_MPC(AINV_MPC),
  Inc1_MPC(ABS_MPC),
  Inc1_MPC(INV_MPC),
  Inc1_MPC(SIN_MPC),
  Inc1_MPC(EXP_MPC),
  Inc1_MPC(SQRT_MPC),
  Inc1_MPC(SQR_MPC),
  Inc1_MPC(CONJ_MPC),

  Inc1_MPC(ZERO_MPC),
  Inc1_MPC(ONE_MPC),
  Inc1_MPC_arg(MPC_MAKENAN,"int"),
  Inc1_MPC_arg(MPC_MAKEINFINITY,"int"),
  Inc1_MPC_arg(MPC_INT,"int"),
  Inc1_MPC(PREC_MPC),
  Inc1_MPC(REAL_MPC),
  Inc1_MPC(IMAG_MPC),
  Inc1_MPC(MPC_MPFR),
  Inc1_MPC(NORM_MPC),
  
  Inc2_MPC(SUM_MPC),
  Inc2_MPC(DIFF_MPC),
  Inc2_MPC(PROD_MPC),
  Inc2_MPC(QUO_MPC),
  Inc2_MPC(LQUO_MPC),
  Inc2_MPC(EQ_MPC),
  Inc2_MPC(LT_MPC),
  Inc2_MPC_arg(MPC_STRING,"string, int"),
  Inc2_MPC_arg(STRING_MPC,"complex, int"),
  Inc2_MPC_arg(VIEWSTRING_MPC,"complex, int"),
  Inc2_MPC_arg(MPC_INTPREC,"int, int"),
  Inc2_MPC_arg(MPC_MPCPREC,"complex, int"),
  Inc2_MPC(MPC_2MPFR),

  {0}
};

int InitMPCKernel (void)
{
  ImportGVarFromLibrary ("TYPE_MPC", &TYPE_MPC);
  return 0;
}

int InitMPCLibrary (void)
{
  InitGVarFuncsFromTable (GVarFuncs);
  return 0;
}

/****************************************************************************
**
*E  mpc.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . .ends here
*/
