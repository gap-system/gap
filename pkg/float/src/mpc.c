/****************************************************************************
**
*W  mpc.c                       GAP source                  Laurent Bartholdi
**
*H  @(#)$Id: mpc.c,v 1.12 2011/12/05 08:41:49 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file contains the functions for the float package.
**  complex floats are implemented using the MPC package.
*/
const char * Revision_mpc_c =
   "@(#)$Id: mpc.c,v 1.12 2011/12/05 08:41:49 gap Exp $";

#include <string.h>
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

Func1_MPC(PROJ_MPC,mpc_proj);
Func1_MPC(EXP_MPC,mpc_exp);
Func1_MPC(LOG_MPC,mpc_log);
Func1_MPC(CONJ_MPC,mpc_conj);
Func1_MPC(AINV_MPC,mpc_neg);
Func1_MPC(SQRT_MPC,mpc_sqrt);
Func1_MPC(SQR_MPC,mpc_sqr);

Func1_MPC(SIN_MPC,mpc_sin);
Func1_MPC(COS_MPC,mpc_cos);
Func1_MPC(TAN_MPC,mpc_tan);
Func1_MPC(SINH_MPC,mpc_sinh);
Func1_MPC(COSH_MPC,mpc_cosh);
Func1_MPC(TANH_MPC,mpc_tanh);
Func1_MPC(ASIN_MPC,mpc_asin);
Func1_MPC(ACOS_MPC,mpc_acos);
Func1_MPC(ATAN_MPC,mpc_atan);
Func1_MPC(ASINH_MPC,mpc_asinh);
Func1_MPC(ACOSH_MPC,mpc_acosh);
Func1_MPC(ATANH_MPC,mpc_atanh);

Func1_MPFRMPC(ABS_MPC,mpc_abs);
Func1_MPFRMPC(NORM_MPC,mpc_norm);
Func1_MPFRMPC(REAL_MPC,mpc_real);
Func1_MPFRMPC(IMAG_MPC,mpc_imag);
Func1_MPFRMPC(ARG_MPC,mpc_arg);

int mpc_nan_p(mpc_ptr c) { return mpfr_nan_p(c->re) || mpfr_nan_p(c->im); }
int mpc_inf_p(mpc_ptr c) { return mpfr_inf_p(c->re) || mpfr_inf_p(c->im); }
int mpc_zero_p(mpc_ptr c) { return mpfr_zero_p(c->re) && mpfr_zero_p(c->im); }
int mpc_number_p(mpc_ptr c) { return mpfr_number_p(c->re) && mpfr_number_p(c->im); }

static Obj ISNAN_MPC(Obj self, Obj f)
{
  return mpc_nan_p(GET_MPC(f)) ? True : False;
}

static Obj ISINF_MPC(Obj self, Obj f)
{
  return mpc_inf_p(GET_MPC(f)) ? True : False;
}

static Obj ISZERO_MPC(Obj self, Obj f)
{
  return mpc_zero_p(GET_MPC(f)) ? True : False;
}

static Obj ISNUMBER_MPC(Obj self, Obj f)
{
  return mpc_number_p(GET_MPC(f)) ? True : False;
}

static Obj FREXP_MPC(Obj self, Obj f)
{
  mp_prec_t prec = mpc_get_prec(GET_MPC(f));
  Obj g = NEW_MPC(prec);
  mpc_set (MPC_OBJ(g), GET_MPC(f), MPC_RNDNN);
  mp_exp_t ere = mpfr_get_exp(MPC_OBJ(f)->re),
    eim = mpfr_get_exp(MPC_OBJ(f)->im);
  mp_exp_t e = ere > eim ? ere : eim;
  mpfr_set_exp(MPC_OBJ(g)->re, ere-e);
  mpfr_set_exp(MPC_OBJ(g)->im, eim-e);
  Obj l = NEW_PLIST(T_PLIST,2);
  SET_ELM_PLIST(l,1,g);
  SET_ELM_PLIST(l,2, ObjInt_Int(e));
  SET_LEN_PLIST(l,2);
  return l;
}

static Obj LDEXP_MPC(Obj self, Obj f, Obj exp)
{
  mp_exp_t e;
  if (IS_INTOBJ(exp))
    e = INT_INTOBJ(exp);
  else {
    Obj f = MPZ_LONGINT(exp);
    e = mpz_get_si(mpz_MPZ(f));
  }
  mp_prec_t prec = mpc_get_prec(GET_MPC(f));
  Obj g = NEW_MPC(prec);
  mpfr_mul_2si (MPC_OBJ(g)->re, MPC_OBJ(f)->re, e, GMP_RNDN);
  mpfr_mul_2si (MPC_OBJ(g)->im, MPC_OBJ(f)->im, e, GMP_RNDN);
  return g;
}

static Obj EXTREPOFOBJ_MPC(Obj self, Obj f)
{
  mp_prec_t prec = mpc_get_prec(GET_MPC(f));
  int i;
  Obj l = NEW_PLIST(T_PLIST,4);
  SET_LEN_PLIST(l,4);
  Obj g = NEW_MPFR(prec);

  if (mpc_zero_p(GET_MPC(f))) {
    SET_ELM_PLIST(l,1, INTOBJ_INT(0));
    SET_ELM_PLIST(l,2, INTOBJ_INT(0));
    return l;
  }
  if (!mpc_number_p(MPC_OBJ(f))) {
    SET_ELM_PLIST(l,1, INTOBJ_INT(0));
    if (mpc_nan_p(MPC_OBJ(f)))
      SET_ELM_PLIST(l,2, INTOBJ_INT(4));
    else if (mpc_inf_p(MPC_OBJ(f)))
      SET_ELM_PLIST(l,2, INTOBJ_INT(2));
    return l;
  }

  mpz_t z;
  mpz_init2 (z, prec);

  for (i = 0; i < 2; i++) {
    if (i == 0)
      mpfr_set (MPFR_OBJ(g), GET_MPC(f)->re, GMP_RNDN);
    else
      mpfr_set (MPFR_OBJ(g), GET_MPC(f)->im, GMP_RNDN);

    mp_exp_t e = mpfr_get_exp(MPFR_OBJ(g));
    mpfr_set_exp(MPFR_OBJ(g), prec);
    mpfr_get_z (z, MPFR_OBJ(g), GMP_RNDZ);
    Obj ig = INT_mpz(z);

    SET_ELM_PLIST(l,2*i+1, ig);
    SET_ELM_PLIST(l,2*i+2, ObjInt_Int(e));
  }
  mpz_clear(z);

  return l;
}

#pragma GCC diagnostic ignored "-Wuninitialized"
static Obj OBJBYEXTREP_MPC(Obj self, Obj list)
{
  int i;
  mp_prec_t prec = 0;

  for (i = 0; i < 4; i += 2) {
    Obj m = ELM_PLIST(list,i+1);
    mp_prec_t newprec;
    if (IS_INTOBJ(m))
      newprec = 8*sizeof(long);
    else
      newprec = 8*sizeof(mp_limb_t)*SIZE_INT(m);
    if (newprec > prec)
      prec = newprec;
  }
  Obj f = NEW_MPC(prec);

  for (i = 0; i < 4; i++) {
    Obj m = ELM_PLIST(list,i+1);
    Int iarg;
    mpz_ptr zarg;
    int argtype;

    if (IS_INTOBJ(m))
      iarg = INT_INTOBJ(m), argtype = 0;
    else
      zarg = mpz_MPZ(MPZ_LONGINT(m)), argtype = 1;

    if (i & 1 && argtype) /* exponent, must be small int */
      iarg = mpz_get_si(zarg), argtype = 0;

    mpfr_ptr reim;
    if (i < 2)
      reim = GET_MPC(f)->re;
    else
      reim = GET_MPC(f)->im;

    if (i & 1)
      mpfr_set_exp(reim, iarg);
    else if (argtype)
      mpfr_set_z(reim, zarg, GMP_RNDN);
    else {
      if (iarg == 0) { /* special case */
	switch (INT_INTOBJ(ELM_PLIST(list,i+2))) {
	case 0: /* 0 */
	case 1: /* -0 */
	  mpfr_set_si(reim, 0, GMP_RNDN); break;
	case 2: /* inf */
	case 3: /* -inf */
	  mpfr_set_inf (reim, 1); break;
	case 4: /* nan */
	case 5: /* -nan */
	  mpfr_set_nan (reim); break;
	default:
	  while(1)
	    ErrorReturnObj("OBJBYEXTREP_MPC: invalid argument [%d,%d]",
			   iarg, INT_INTOBJ(ELM_PLIST(list,i+2)),"");
	}
	i++; /* skip "exponent" */
	continue;
      }
      mpfr_set_si(reim, iarg, GMP_RNDN);
    }
  }
  return f;
}

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
  if (mpc_inf_p(GET_MPC(f))) {
    strcat(c+slen, CSTR_STRING(FLOAT_INFINITY_STRING));
    slen += GET_LEN_STRING(FLOAT_INFINITY_STRING);
  } else if (mpc_nan_p(MPC_OBJ(f))) {
    c[slen++] = 'n';
    c[slen++] = 'a';
    c[slen++] = 'n';
  } else {
    slen += PRINT_MPFR(c+slen, 0, n, MPC_OBJ(f)->re, GMP_RNDN);
    Obj im = NEW_MPFR(prec);
    mpfr_add(MPFR_OBJ(im), GET_MPC(f)->re, GET_MPC(f)->im, GMP_RNDN);
    mpfr_sub(MPFR_OBJ(im), MPFR_OBJ(im), MPC_OBJ(f)->re, GMP_RNDN); /* round off small im */
    if (!mpfr_zero_p(MPFR_OBJ(im))) {
      if (mpfr_sgn(MPFR_OBJ(im)) < 0)
	c[slen++] = '-';
      else
	c[slen++] = '+';
      mpfr_abs (MPFR_OBJ(im), MPC_OBJ(f)->im, GMP_RNDN);
      slen += PRINT_MPFR(c+slen, 0, n, MPFR_OBJ(im), GMP_RNDN);
      strcat(c+slen, CSTR_STRING(FLOAT_I_STRING));
      slen += GET_LEN_STRING(FLOAT_I_STRING);
    }
  }
  c[slen] = 0;
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
  static Obj name##_MPC(Obj self, Obj fl, Obj fr)			\
  {									\
    mp_prec_t precl = mpc_get_prec(GET_MPC(fl)),			\
      precr = mpc_get_prec(GET_MPC(fr));				\
									\
    Obj g = NEW_MPC(precl > precr ? precl : precr);			\
    mpc_name (MPC_OBJ(g), GET_MPC(fl), GET_MPC(fr), MPC_RNDNN);		\
    return g;								\
  }
#define Func2_MPC_MPFR(name,mpc_name)					\
  static Obj name##_MPC_MPFR(Obj self, Obj fl, Obj fr)			\
  {									\
    mp_prec_t precl = mpc_get_prec(GET_MPC(fl)),			\
      precr = mpfr_get_prec(GET_MPFR(fr));				\
									\
    Obj g = NEW_MPC(precl > precr ? precl : precr);			\
    mpc_name (MPC_OBJ(g), GET_MPC(fl), MPFR_OBJ(fr), MPC_RNDNN);	\
    return g;								\
  }
#define Func2_MPFR_MPC(name,mpc_name)					\
  static Obj name##_MPFR_MPC(Obj self, Obj fl, Obj fr)			\
  {									\
    mp_prec_t precl = mpfr_get_prec(GET_MPFR(fl)),			\
      precr = mpc_get_prec(GET_MPC(fr));				\
									\
    Obj g = NEW_MPC(precl > precr ? precl : precr);			\
    mpc_name (MPC_OBJ(g), MPFR_OBJ(fl), GET_MPC(fr), MPC_RNDNN);	\
    return g;								\
  }
#define Inc2_MPC_arg(name,arg)			\
  { #name, 2, arg, name, "src/mpc.c:" #name }
#define Inc2_MPC(name) Inc2_MPC_arg(name##_MPC,"complex, complex"),	\
    Inc2_MPC_arg(name##_MPC_MPFR,"complex, real"),			\
    Inc2_MPC_arg(name##_MPFR_MPC,"real, complex")			\

Func2_MPC(SUM,mpc_add);
Func2_MPC(DIFF,mpc_sub);
Func2_MPC(PROD,mpc_mul);
Func2_MPC(QUO,mpc_div);
Func2_MPC(POW,mpc_pow);
Func2_MPC_MPFR(SUM,mpc_add_fr);
Func2_MPC_MPFR(DIFF,mpc_sub_fr);
Func2_MPC_MPFR(PROD,mpc_mul_fr);
Func2_MPC_MPFR(QUO,mpc_div_fr);
Func2_MPC_MPFR(POW,mpc_pow_fr);
#define mpc_fr_add(a,b,c,d) mpc_add_fr(a,c,b,d)
Func2_MPFR_MPC(SUM,mpc_fr_add);
Func2_MPFR_MPC(DIFF,mpc_fr_sub);
#define mpc_fr_mul(a,b,c,d) mpc_mul_fr(a,c,b,d)
Func2_MPFR_MPC(PROD,mpc_fr_mul);
Func2_MPFR_MPC(QUO,mpc_fr_div);

static Obj POW_MPFR_MPC(Obj self, Obj fl, Obj fr)			
{									
  mp_prec_t precl = mpfr_get_prec(GET_MPFR(fl)),			
    precr = mpc_get_prec(GET_MPC(fr));				
  
  Obj h = NEW_MPC (precl);
  mpfr_set (MPC_OBJ(h)->re, GET_MPFR(fl), GMP_RNDN);
  mpfr_set_ui (MPC_OBJ(h)->im, 0, GMP_RNDN);

  Obj g = NEW_MPC(precl > precr ? precl : precr);			
  mpc_pow (MPC_OBJ(g), GET_MPC(h), GET_MPC(fr), MPC_RNDNN);	
  return g;								
}

static Obj LQUO_MPC(Obj self, Obj fl, Obj fr)
{
  return QUO_MPC(self, fr, fl);
}

static Obj LQUO_MPC_MPFR(Obj self, Obj fl, Obj fr)
{
  return QUO_MPFR_MPC(self, fr, fl);
}

static Obj LQUO_MPFR_MPC(Obj self, Obj fl, Obj fr)
{
  return QUO_MPC_MPFR(self, fr, fl);
}

static Obj EQ_MPC (Obj self, Obj fl, Obj fr)
{
  return mpc_cmp(GET_MPC(fl),GET_MPC(fr)) == 0 ? True : False;
}

static Obj EQ_MPC_MPFR (Obj self, Obj fl, Obj fr)
{
  return mpfr_cmp(GET_MPC(fl)->re,GET_MPFR(fr)) == 0 && mpfr_zero_p(MPC_OBJ(fl)->im) ? True : False;
}

static Obj EQ_MPFR_MPC (Obj self, Obj fl, Obj fr)
{
  return mpfr_cmp(GET_MPFR(fl),GET_MPC(fr)->re) == 0 && mpfr_zero_p(MPC_OBJ(fr)->im) ? True : False;
}

static Obj LT_MPC (Obj self, Obj fl, Obj fr)
{
  int c = mpc_cmp(GET_MPC(fl),GET_MPC(fr)), cre = MPC_INEX_RE(c);
  return (cre < 0 || (cre == 0 && MPC_INEX_IM(c) < 0)) ? True : False;
}

static Obj LT_MPC_MPFR (Obj self, Obj fl, Obj fr)
{
  int c = mpfr_cmp(GET_MPC(fl)->re, GET_MPFR(fr));
  if (!c) c = mpfr_cmp_si(GET_MPC(fl)->im, 0);
  return c < 0 ? True : False;
}

static Obj LT_MPFR_MPC (Obj self, Obj fl, Obj fr)
{
  int c = mpfr_cmp(GET_MPFR(fl), GET_MPC(fr)->re);
  if (!c) c = -mpfr_cmp_si(GET_MPC(fr)->im, 0);
  return c < 0 ? True : False;
}

static Obj MPC_2MPFR (Obj self, Obj fl, Obj fr)
{
  mp_prec_t precl = mpfr_get_prec(GET_MPFR(fl)),
    precr = mpfr_get_prec(GET_MPFR(fr));
  
  Obj g = NEW_MPC(precl > precr ? precl : precr);
  mpfr_set (MPC_OBJ(g)->re, MPFR_OBJ(fl), GMP_RNDN);
  mpfr_set (MPC_OBJ(g)->im, MPFR_OBJ(fr), GMP_RNDN);

  return g;
}


static Obj COMPLEXROOTS_MPC (Obj self, Obj coeffs, Obj precision)
{
  int cpoly_MPC(int, mpc_t *, mpc_t *, mp_prec_t);
  Obj result;
  Int i, numroots, degree = LEN_PLIST(coeffs)-1;
  mpc_t op[degree+1], zero[degree];
  mp_prec_t prec = INT_INTOBJ(precision);

  if (degree < 1)
    return Fail;

  for (i = 0; i <= degree; i++)
    if (!mpc_number_p(op[degree-i]))
      return Fail;

  for (i = 0; i <= degree; i++) {
    mpc_init2(op[degree-i],mpc_get_prec(GET_MPC(ELM_PLIST(coeffs,i+1))));
    mpc_set(op[degree-i],MPC_OBJ(ELM_PLIST(coeffs,i+1)),MPC_RNDNN);
  }

  for (i = 0; i < degree; i++)
    mpc_init2(zero[i],prec);

  numroots = cpoly_MPC (degree, op, zero, prec);

  for (i = 0; i <= degree; i++)
    mpc_clear(op[degree-i]);

  if (numroots == -1)
    result = Fail;
  else {
    result = NEW_PLIST(T_PLIST,numroots);
    SET_LEN_PLIST(result,numroots);
    for (i = 1; i <= numroots; i++) {
      Obj t = NEW_MPC(mpc_get_prec(zero[i-1]));
      mpc_set (MPC_OBJ(t), zero[i-1], MPC_RNDNN);
      SET_ELM_PLIST(result,i, t);
    }
  }

  for (i = 0; i < degree; i++)
    mpc_clear(zero[i]);

  return result;
}

/****************************************************************
 * export functions
 ****************************************************************/
static StructGVarFunc GVarFuncs [] = {  
  Inc1_MPC(AINV_MPC),
  Inc1_MPC(ABS_MPC),
  Inc1_MPC(INV_MPC),
  Inc1_MPC(EXP_MPC),
  Inc1_MPC(LOG_MPC),
  Inc1_MPC(SQRT_MPC),
  Inc1_MPC(SQR_MPC),
  Inc1_MPC(CONJ_MPC),
  Inc1_MPC(PROJ_MPC),
  Inc1_MPC(SIN_MPC),
  Inc1_MPC(COS_MPC),
  Inc1_MPC(TAN_MPC),
  Inc1_MPC(ASIN_MPC),
  Inc1_MPC(ACOS_MPC),
  Inc1_MPC(ATAN_MPC),
  Inc1_MPC(SINH_MPC),
  Inc1_MPC(COSH_MPC),
  Inc1_MPC(TANH_MPC),
  Inc1_MPC(ASINH_MPC),
  Inc1_MPC(ACOSH_MPC),
  Inc1_MPC(ATANH_MPC),

  Inc1_MPC(ZERO_MPC),
  Inc1_MPC(ONE_MPC),
  Inc1_MPC(ISZERO_MPC),
  Inc1_MPC(ISNUMBER_MPC),
  Inc1_MPC(ISNAN_MPC),
  Inc1_MPC(ISINF_MPC),
  Inc1_MPC_arg(MPC_MAKENAN,"int"),
  Inc1_MPC_arg(MPC_MAKEINFINITY,"int"),
  Inc1_MPC_arg(MPC_INT,"int"),
  Inc1_MPC(PREC_MPC),
  Inc1_MPC(REAL_MPC),
  Inc1_MPC(IMAG_MPC),
  Inc1_MPC(NORM_MPC),
  Inc1_MPC(ARG_MPC),
  Inc1_MPC(MPC_MPFR),

  Inc1_MPC(FREXP_MPC),
  Inc2_MPC_arg(LDEXP_MPC,"complex, int"),
  Inc1_MPC(EXTREPOFOBJ_MPC),
  Inc1_MPC_arg(OBJBYEXTREP_MPC,"list"),

  Inc2_MPC(SUM),
  Inc2_MPC(DIFF),
  Inc2_MPC(PROD),
  Inc2_MPC(QUO),
  Inc2_MPC(LQUO),
  Inc2_MPC(POW),
  Inc2_MPC(EQ),
  Inc2_MPC(LT),
  Inc2_MPC_arg(MPC_STRING,"string, int"),
  Inc2_MPC_arg(STRING_MPC,"complex, int"),
  Inc2_MPC_arg(VIEWSTRING_MPC,"complex, int"),
  Inc2_MPC_arg(MPC_INTPREC,"int, int"),
  Inc2_MPC_arg(MPC_MPCPREC,"complex, int"),
  Inc2_MPC_arg(MPC_2MPFR,"complex, complex"),

  Inc2_MPC_arg(COMPLEXROOTS_MPC,"coeffs, prec"),

  {0}
};

int InitMPCKernel (void)
{
  InitHdlrFuncsFromTable (GVarFuncs);

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
