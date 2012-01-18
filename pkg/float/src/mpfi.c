/****************************************************************************
**
*W  mpfi.c                       GAP source                 Laurent Bartholdi
**
*H  @(#)$Id: mpfi.c,v 1.8 2011/12/05 08:41:49 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file contains the functions for the float package.
**  interval floats are implemented using the MPFI package.
*/
const char * Revision_mpfi_c =
   "@(#)$Id: mpfi.c,v 1.8 2011/12/05 08:41:49 gap Exp $";

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

#define LMANTISSA_MPFI(p) ((mp_limb_t *) (p+1))
#define RMANTISSA_MPFI(p) (LMANTISSA_MPFI(p)+(mpfi_get_prec(p)+GMP_NUMB_BITS-1)/GMP_NUMB_BITS)

static inline mpfi_ptr GET_MPFI(Obj obj) {
  mpfi_ptr p = MPFI_OBJ(obj);
  mpfr_custom_move (&p->left, LMANTISSA_MPFI(p));
  mpfr_custom_move (&p->right, RMANTISSA_MPFI(p));
  return p;
}

/****************************************************************************
**
*F  allocate new object, initialize to NaN
**
*/
Obj TYPE_MPFI;

static inline Obj NEW_MPFI( mp_prec_t prec )
{
  Obj f;
  f = NewBag(T_DATOBJ,sizeof(Obj)+sizeof(__mpfi_struct)+2*mpfr_custom_get_size(prec));
  SET_TYPE_DATOBJ(f,TYPE_MPFI);
  mpfi_ptr p = MPFI_OBJ(f);
  mpfr_custom_init_set(&p->left, MPFR_NAN_KIND, 0, prec, LMANTISSA_MPFI(p));
  mpfr_custom_init_set(&p->right, MPFR_NAN_KIND, 0, prec, RMANTISSA_MPFI(p));
  return f;
}

/****************************************************************************
**
*F Func1_MPFI( <float> ) . . . . . . . . . . . . . . . .1-argument functions
**
*/
#define Func1_MPFI(name,mpfi_name)				\
  static Obj name(Obj self, Obj f)				\
  {								\
    mp_prec_t prec = mpfi_get_prec(MPFI_OBJ(f));		\
    Obj g = NEW_MPFI(prec);					\
    mpfi_name (MPFI_OBJ(g), GET_MPFI(f));			\
    return g;							\
  }
#define Func1_MPFRMPFI(name,mpfi_name)				\
  static Obj name(Obj self, Obj f)				\
  {								\
    mp_prec_t prec = mpfi_get_prec(MPFI_OBJ(f));		\
    Obj g = NEW_MPFR(prec);					\
    mpfi_name (MPFR_OBJ(g), GET_MPFI(f));			\
    return g;							\
  }
#define Func1_BOOLMPFI(name,mpfi_name)				\
  static Obj name(Obj self, Obj f)				\
  {								\
    return mpfi_name(GET_MPFI(f)) > 0 ? True : False;		\
  }
#define Inc1_MPFI_arg(name,arg)		\
  { #name, 1, arg, name, "src/mpfi.c:" #name }
#define Inc1_MPFI(name) Inc1_MPFI_arg(name,"interval")

Func1_MPFI(COS_MPFI,mpfi_cos);
Func1_MPFI(SIN_MPFI,mpfi_sin);
Func1_MPFI(TAN_MPFI,mpfi_tan);
Func1_MPFI(ACOS_MPFI,mpfi_acos);
Func1_MPFI(ASIN_MPFI,mpfi_asin);
Func1_MPFI(ATAN_MPFI,mpfi_atan);
Func1_MPFI(SEC_MPFI,mpfi_sec);
Func1_MPFI(CSC_MPFI,mpfi_csc);
Func1_MPFI(COT_MPFI,mpfi_cot);

Func1_MPFI(COSH_MPFI,mpfi_cosh);
Func1_MPFI(SINH_MPFI,mpfi_sinh);
Func1_MPFI(TANH_MPFI,mpfi_tanh);
Func1_MPFI(SECH_MPFI,mpfi_sech);
Func1_MPFI(CSCH_MPFI,mpfi_csch);
Func1_MPFI(COTH_MPFI,mpfi_coth);
Func1_MPFI(ACOSH_MPFI,mpfi_acosh);
Func1_MPFI(ASINH_MPFI,mpfi_asinh);
Func1_MPFI(ATANH_MPFI,mpfi_atanh);

Func1_MPFI(LOG_MPFI,mpfi_log);
Func1_MPFI(LOG2_MPFI,mpfi_log2);
Func1_MPFI(LOG10_MPFI,mpfi_log10);
Func1_MPFI(LOG1P_MPFI,mpfi_log1p);
Func1_MPFI(EXP_MPFI,mpfi_exp);
Func1_MPFI(EXP2_MPFI,mpfi_exp2);
Func1_MPFI(EXPM1_MPFI,mpfi_expm1);

Func1_MPFI(INV_MPFI,mpfi_inv);
Func1_MPFI(AINV_MPFI,mpfi_neg);
Func1_MPFI(SQRT_MPFI,mpfi_sqrt);
Func1_MPFI(CBRT_MPFI,mpfi_cbrt);
Func1_MPFI(SQR_MPFI,mpfi_sqr);
Func1_MPFI(ABS_MPFI,mpfi_abs);

static Obj EXTREPOFOBJ_MPFI(Obj self, Obj f)
{
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(f));
  int i;
  Obj l = NEW_PLIST(T_PLIST,4);
  SET_LEN_PLIST(l,4);
  Obj g = NEW_MPFR(prec);

  mpz_t z;
  mpz_init2 (z, prec);

  for (i = 0; i < 1; i++) {
    Obj ig;
    mp_exp_t e;

    if (i == 0)
      mpfr_set (MPFR_OBJ(g), &GET_MPFI(f)->left, GMP_RNDN);
    else
      mpfr_set (MPFR_OBJ(g), &GET_MPFI(f)->right, GMP_RNDN);

    if (mpfr_zero_p(MPFR_OBJ(g))) {
      ig = INTOBJ_INT(0);
      mpfr_ui_div(MPFR_OBJ(g), 1, MPFR_OBJ(g), GMP_RNDN);
      e = (mpfr_sgn(MPFR_OBJ(g))<0);
    } else if (!mpfr_number_p(MPFR_OBJ(g))) {
      ig = INTOBJ_INT(0);
      if (mpfr_inf_p(MPFR_OBJ(g)))
	e = 2 + (mpfr_sgn(MPFR_OBJ(f))<0);
      else if (mpfr_nan_p(MPFR_OBJ(g)))
	e = 4;
    } else {
      e = mpfr_get_exp(MPFR_OBJ(g));
      mpfr_set_exp(MPFR_OBJ(g), prec);
      mpfr_get_z (z, MPFR_OBJ(g), GMP_RNDZ);
      ig = INT_mpz(z);
    }
    SET_ELM_PLIST(l,2*i+1, ig);
    SET_ELM_PLIST(l,2*i+2, ObjInt_Int(e));
  }
  mpz_clear(z);

  return l;
}

#pragma GCC diagnostic ignored "-Wuninitialized"
static Obj OBJBYEXTREP_MPFI(Obj self, Obj list)
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
  Obj f = NEW_MPFI(prec);

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

    mpfr_ptr leftright;
    if (i < 2)
      leftright = &GET_MPFI(f)->left;
    else
      leftright = &GET_MPFI(f)->right;

    if (i & 1)
      mpfr_set_exp(leftright, iarg);
    else if (argtype)
      mpfr_set_z(leftright, zarg, GMP_RNDN);
    else {
      if (iarg == 0) { /* special case */
	switch (INT_INTOBJ(ELM_PLIST(list,i+2))) {
	case 0: /* 0 */
	case 1: /* -0 */
	  mpfr_set_si(leftright, 0, GMP_RNDN); break;
	case 2: /* inf */
	case 3: /* -inf */
	  mpfr_set_inf (leftright, 1); break;
	case 4: /* nan */
	case 5: /* -nan */
	  mpfr_set_nan (leftright); break;
	default:
	  while(1)
	    ErrorReturnObj("OBJBYEXTREP_MPFI: invalid argument [%d,%d]",
			   iarg, INT_INTOBJ(ELM_PLIST(list,i+2)),"");
	}
	i++; /* skip "exponent" */
	continue;
      }
      mpfr_set_si(leftright, iarg, GMP_RNDN);
    }
  }
  return f;
}

static Obj ZERO_MPFI(Obj self, Obj f)
{
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(f));
  Obj g = NEW_MPFI(prec);
  mpfi_set_ui(MPFI_OBJ(g), 0);
  return g;
}

static Obj ONE_MPFI(Obj self, Obj f)
{
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(f));
  Obj g = NEW_MPFI(prec);
  mpfi_set_ui (MPFI_OBJ(g), 1);
  return g;
}

static Obj MPFI_MAKENAN(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPFI_MAKENAN",prec);

  Obj g = NEW_MPFI(INT_INTOBJ(prec));
  mpfr_set_nan (&MPFI_OBJ(g)->left);
  mpfr_set_nan (&MPFI_OBJ(g)->right);
  return g;
}

static Obj MPFI_MAKEINFINITY(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPFI_MAKEINFINITY",prec);

  int p = INT_INTOBJ(prec);
  Obj g = NEW_MPFI(p < 0 ? -p : p);
  mpfr_set_inf (&MPFI_OBJ(g)->left, p);
  mpfr_set_inf (&MPFI_OBJ(g)->right, p);
  return g;
}

static Obj MPFI_LOG2(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPFI_LOG2",prec);

  Obj g = NEW_MPFI(INT_INTOBJ(prec));
  mpfi_const_log2 (MPFI_OBJ(g));
  return g;
}

static Obj MPFI_PI(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPFI_PI",prec);

  Obj g = NEW_MPFI(INT_INTOBJ(prec));
  mpfi_const_pi (MPFI_OBJ(g));
  return g;
}

static Obj MPFI_EULER(Obj self, Obj prec)
{
  TEST_IS_INTOBJ("MPFI_EULER",prec);

  Obj g = NEW_MPFI(INT_INTOBJ(prec));
  mpfi_const_euler (MPFI_OBJ(g));
  return g;
}

static Obj MPFI_CATALAN(Obj self, Obj prec) /* strangely not in mpfi */
{
  TEST_IS_INTOBJ("MPFI_CATALAN",prec);

  Obj g = NEW_MPFI(INT_INTOBJ(prec));
  mpfr_const_catalan (&MPFI_OBJ(g)->left, GMP_RNDD);
  mpfr_const_catalan (&MPFI_OBJ(g)->right, GMP_RNDU);
  return g;
}

static Obj EXP10_MPFI(Obj self, Obj f) /* strangely not in mpfi */
{
  Obj g = NEW_MPFI(mpfi_get_prec(GET_MPFI(f)));
  mpfr_exp10 (&MPFI_OBJ(g)->left, &GET_MPFI(f)->left, GMP_RNDD);
  mpfr_exp10 (&MPFI_OBJ(g)->right, &GET_MPFI(f)->right, GMP_RNDU);
  return g;
}

static Obj MPFI_INT(Obj self, Obj i)
{
  Obj g;
  if (IS_INTOBJ(i)) {
    g = NEW_MPFI(8*sizeof(long));
    mpfi_set_si(MPFI_OBJ(g), INT_INTOBJ(i));
  } else {
    Obj f = MPZ_LONGINT(i);
    g = NEW_MPFI(8*sizeof(mp_limb_t)*SIZE_INT(i));
    
    mpfi_set_z(MPFI_OBJ(g), mpz_MPZ(f));
  }
  return g;
}

static Obj MPFI_INTPREC(Obj self, Obj i, Obj prec)
{
  Obj g;
  TEST_IS_INTOBJ("MPFI_INTPREC",prec);

  if (IS_INTOBJ(i)) {
    g = NEW_MPFI(INT_INTOBJ(prec));
    mpfi_set_si(MPFI_OBJ(g), INT_INTOBJ(i));
  } else {
    Obj f = MPZ_LONGINT(i);
    g = NEW_MPFI(INT_INTOBJ(prec));
    
    mpfi_set_z(MPFI_OBJ(g), mpz_MPZ(f));
  }
  return g;
}

static Obj INT_MPFI(Obj self, Obj f)
/* if there's an integer in the interval, return the one of smallest absolute
   value.
   else, if the interval is positive, return the largest integer not in it
   else, if the interval is negative, the smallest integer not in it
   else, if the interval is empty, return fail. */
{
  mpz_t y, z;
  Obj res;

  if (mpfi_is_empty(GET_MPFI(f)))
    return Fail;

  mpz_init2 (y, mpfr_get_exp(&GET_MPFI(f)->left)+1);
  mpz_init2 (z, mpfr_get_exp(&GET_MPFI(f)->right)+1);

  mpfr_get_z (y, &GET_MPFI(f)->left, GMP_RNDU);
  mpfr_get_z (z, &MPFI_OBJ(f)->right, GMP_RNDD);

  if (mpz_cmp(y, z) <= 0) { /* Ceil(Inf(f)) <= Floor(Sup(f)) */
    if (mpz_cmp_si(y, 0) >= 0)
      res = INT_mpz(y);
    else if (mpz_cmp_si(z, 0) <= 0)
      res = INT_mpz(z);
    else res = INTOBJ_INT(0);
  } else { /* y = z+1 */
    if (mpz_cmp_si(y, 0) >= 0)
      res = INT_mpz(z);
    else
      res = INT_mpz(y);
  }

  mpz_clear(y);
  mpz_clear(z);

  return res;
}

static Obj SIGN_MPFI(Obj self, Obj f)
{
  if (mpfr_sgn(&GET_MPFI(f)->left) > 0)
    return INTOBJ_INT(1);
  if (mpfr_sgn(&GET_MPFI(f)->right) < 0)
    return INTOBJ_INT(-1);
  return INTOBJ_INT(0);
}

static Obj ISPINF_MPFI(Obj self, Obj f)
{
  if (!mpfi_inf_p(GET_MPFI(f)))
    return False;
  if (mpfr_sgn(&MPFI_OBJ(f)->left) > 0)
    return True;
  return False;
}

static Obj ISNINF_MPFI(Obj self, Obj f)
{
  if (!mpfi_inf_p(GET_MPFI(f)))
    return False;
  if (mpfr_sgn(&MPFI_OBJ(f)->right) < 0)
    return True;
  return False;
}

static Obj PREC_MPFI(Obj self, Obj f)
{
  return INTOBJ_INT(mpfi_get_prec(GET_MPFI(f)));
}

Func1_MPFRMPFI(DIAM_ABS_MPFI,mpfi_diam_abs);
Func1_MPFRMPFI(DIAM_REL_MPFI,mpfi_diam_rel);
Func1_MPFRMPFI(DIAM_MPFI,mpfi_diam);
Func1_MPFRMPFI(MAG_MPFI,mpfi_mag);
Func1_MPFRMPFI(MIG_MPFI,mpfi_mig);
Func1_MPFRMPFI(MID_MPFI,mpfi_mid);
Func1_MPFRMPFI(ALEA_MPFI,mpfi_alea);
Func1_MPFRMPFI(LEFT_MPFI,mpfi_get_left);
Func1_MPFRMPFI(RIGHT_MPFI,mpfi_get_right);

Func1_BOOLMPFI(ISPOS_MPFI,mpfi_is_pos);
Func1_BOOLMPFI(ISSTRICTLY_POS_MPFI,mpfi_is_strictly_pos);
Func1_BOOLMPFI(ISNONNEG_MPFI,mpfi_is_nonneg);
Func1_BOOLMPFI(ISNEG_MPFI,mpfi_is_neg);
Func1_BOOLMPFI(ISSTRICTLY_NEG_MPFI,mpfi_is_strictly_neg);
Func1_BOOLMPFI(ISNONPOS_MPFI,mpfi_is_nonpos);
Func1_BOOLMPFI(ISZERO_MPFI,mpfi_is_zero);
Func1_BOOLMPFI(HASZERO_MPFI,mpfi_has_zero);
Func1_BOOLMPFI(ISNAN_MPFI,mpfi_nan_p);
Func1_BOOLMPFI(ISXINF_MPFI,mpfi_inf_p);
Func1_BOOLMPFI(ISNUMBER_MPFI,mpfi_bounded_p);
Func1_BOOLMPFI(ISEMPTY_MPFI,mpfi_is_empty);

static Obj FREXP_MPFI(Obj self, Obj f)
{
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(f));
  Obj g = NEW_MPFI(prec);
  mpfi_set (MPFI_OBJ(g), GET_MPFI(f));
  mp_exp_t eleft = mpfr_get_exp(&MPFI_OBJ(f)->left),
    eright = mpfr_get_exp(&MPFI_OBJ(f)->right);
  mp_exp_t e = eleft > eright ? eleft : eright;
  mpfr_set_exp(&MPFI_OBJ(g)->left, eleft-e);
  mpfr_set_exp(&MPFI_OBJ(g)->right, eright-e);
  Obj l = NEW_PLIST(T_PLIST,2);
  SET_ELM_PLIST(l,1,g);
  SET_ELM_PLIST(l,2, ObjInt_Int(e));
  SET_LEN_PLIST(l,2);
  return l;
}

static Obj LDEXP_MPFI(Obj self, Obj f, Obj exp)
{
  mp_exp_t e;
  if (IS_INTOBJ(exp))
    e = INT_INTOBJ(exp);
  else {
    Obj f = MPZ_LONGINT(exp);
    e = mpz_get_si(mpz_MPZ(f));
  }
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(f));
  Obj g = NEW_MPFI(prec);
  mpfi_mul_2si (MPFI_OBJ(g), GET_MPFI(f), e);
  return g;
}

static Obj MPFI_MPFIPREC(Obj self, Obj f, Obj prec)
{
  TEST_IS_INTOBJ("MPFI_MPFIPREC",prec);

  Obj g = NEW_MPFI(INT_INTOBJ(prec));
  mpfi_set (MPFI_OBJ(g), GET_MPFI(f));
  return g;
}

static Obj STRING_MPFI(Obj self, Obj f, Obj digits)
{
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(f));
  Obj str = NEW_STRING(2*(prec*302/1000+10)+3);
  int slen = 0, n;

  TEST_IS_INTOBJ("STRING_MPFI",digits);
  n = INT_INTOBJ(digits);
  if (n == 1) n = 2;

  char *c = CSTR_STRING(str);
  c[slen++] = '[';
  slen += PRINT_MPFR(c+slen, 0, n, &GET_MPFI(f)->left, GMP_RNDD);
  c[slen++] = ',';
  slen += PRINT_MPFR(c+slen, 0, n, &MPFI_OBJ(f)->right, GMP_RNDU);
  c[slen++] = ']';
  SET_LEN_STRING(str, slen);
  SHRINK_STRING(str);

  return str;
}

static Obj VIEWSTRING_MPFI(Obj self, Obj f, Obj digits)
{
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(f));
  Obj str = NEW_STRING(prec*302/1000+20);
  mp_exp_t exp;

  TEST_IS_INTOBJ("VIEWSTRING_MPFI",digits);

  int n = INT_INTOBJ(digits);
  if (n == 1) n = 2;

  if (mpfi_is_empty(GET_MPFI(f)))
    return FLOAT_EMPTYSET_STRING;

  Obj g = NEW_MPFR(prec);
  mpfi_mid (MPFR_OBJ(g), GET_MPFI(f));

  char *c = CSTR_STRING(str);
  int slen = PRINT_MPFR(c, &exp, n, MPFR_OBJ(g), GMP_RNDN);

  mpfi_diam (MPFR_OBJ(g), GET_MPFI(f));

  if (mpfr_zero_p (MPFR_OBJ(g)))
    sprintf(c+slen, "(%s)", CSTR_STRING(FLOAT_INFINITY_STRING));
  else {
    exp = mpfr_get_exp(MPFR_OBJ(g));
    if (exp < -1) /* at least 2 bits */
      sprintf(c+slen, "(%ld)", -exp);
    else /* restart, print interval */
      return STRING_MPFI(self,f,digits);
  }

  SET_LEN_STRING(str, strlen(c));
  SHRINK_STRING(str);
  return str;
}

static Obj MPFI_STRING(Obj self, Obj s, Obj prec)
{
  while (!IsStringConv(s))
    {
      s = ErrorReturnObj("MPFI_STRING: object to be converted must be a string, not a %s",
			 (Int)(InfoBags[TNUM_OBJ(s)].name),0,
			 "You can return a string to continue" );
    }
  TEST_IS_INTOBJ("MPFI_STRING",prec);
  int n = INT_INTOBJ(prec);
  if (n == 0)
    n = GET_LEN_STRING(s)*1000 / 301;

  Obj g = NEW_MPFI(INT_INTOBJ(prec));
  mpfi_set_str(MPFI_OBJ(g), (char *)CHARS_STRING(s), 10);
  return g;
}

static Obj MPFI_MPFR(Obj self, Obj f)
{
  Obj g = NEW_MPFI (mpfr_get_prec(GET_MPFR(f)));
  mpfi_set_fr (MPFI_OBJ(g), GET_MPFR(f));

  return g;
}

static Obj BISECT_MPFI(Obj self, Obj f)
{
  mp_prec_t prec = mpfr_get_prec(GET_MPFR(f));
  Obj g1 = NEW_MPFI (prec), g2 = NEW_MPFI (prec);
  mpfi_bisect (MPFI_OBJ(g1), MPFI_OBJ(g2), GET_MPFI(f));

  Obj g = NEW_PLIST(T_PLIST, 2);
  SET_LEN_PLIST(g,2);
  SET_ELM_PLIST(g,1,g1);
  SET_ELM_PLIST(g,2,g2);

  return g;
}

/****************************************************************************
**
*F Func2_MPFI( <float>, <float> ) . . . . . . . . . . . 2-argument functions
**
*/
#define Func2_MPFI(name,mpfi_name)					\
  static Obj name##_MPFI(Obj self, Obj fl, Obj fr)			\
  {									\
    mp_prec_t precl = mpfi_get_prec(GET_MPFI(fl)),			\
      precr = mpfi_get_prec(GET_MPFI(fr));				\
									\
    Obj g = NEW_MPFI(precl > precr ? precl : precr);			\
    mpfi_name (MPFI_OBJ(g), GET_MPFI(fl), GET_MPFI(fr));		\
    return g;								\
  }
#define Func2_MPFI_MPFR(name,mpfi_name)					\
  static Obj name##_MPFI_MPFR(Obj self, Obj fl, Obj fr)			\
  {									\
    mp_prec_t precl = mpfi_get_prec(GET_MPFI(fl)),			\
      precr = mpfr_get_prec(GET_MPFR(fr));				\
									\
    Obj g = NEW_MPFI(precl > precr ? precl : precr);			\
    mpfi_name (MPFI_OBJ(g), GET_MPFI(fl), MPFR_OBJ(fr));		\
    return g;								\
  }
#define Func2_MPFR_MPFI(name,mpfi_name)					\
  static Obj name##_MPFR_MPFI(Obj self, Obj fl, Obj fr)			\
  {									\
    mp_prec_t precl = mpfr_get_prec(GET_MPFR(fl)),			\
      precr = mpfi_get_prec(GET_MPFI(fr));				\
									\
    Obj g = NEW_MPFI(precl > precr ? precl : precr);			\
    mpfi_name (MPFI_OBJ(g), MPFR_OBJ(fl), GET_MPFI(fr));		\
    return g;								\
  }
#define Inc2_MPFI_arg(name,arg)			\
  { #name, 2, arg, name, "src/mpfi.c:" #name }
#define Inc2_MPFI(name) Inc2_MPFI_arg(name,"interval, interval")
#define Inc2_MPFIX(name) Inc2_MPFI_arg(name##_MPFI,"interval, interval"), \
    Inc2_MPFI_arg(name##_MPFI_MPFR,"interval, real"),			\
    Inc2_MPFI_arg(name##_MPFR_MPFI,"real, interval")			\
    
Func2_MPFI(SUM,mpfi_add);
Func2_MPFI(DIFF,mpfi_sub);
Func2_MPFI(PROD,mpfi_mul);
Func2_MPFI(QUO,mpfi_div);
#define mpfi_pow(a,b,c) mpfi_log(a,b), mpfi_mul(a,a,c), mpfi_exp(a,a)
Func2_MPFI(POW,mpfi_pow);

Func2_MPFI_MPFR(SUM,mpfi_add_fr);
Func2_MPFI_MPFR(DIFF,mpfi_sub_fr);
Func2_MPFI_MPFR(PROD,mpfi_mul_fr);
Func2_MPFI_MPFR(QUO,mpfi_div_fr);
#define mpfi_pow_fr(a,b,c) mpfi_log(a,b), mpfi_mul_fr(a,a,c), mpfi_exp(a,a)
Func2_MPFI_MPFR(POW,mpfi_pow_fr);

#define mpfi_fr_add(a,b,c) mpfi_add_fr(a,c,b)
Func2_MPFR_MPFI(SUM,mpfi_fr_add);
Func2_MPFR_MPFI(DIFF,mpfi_fr_sub);
#define mpfi_fr_mul(a,b,c) mpfi_mul_fr(a,c,b)
Func2_MPFR_MPFI(PROD,mpfi_fr_mul);
Func2_MPFR_MPFI(QUO,mpfi_fr_div);
#define mpfi_fr_pow(a,b,c) mpfi_set_fr(a,b), mpfi_log(a,a), mpfi_mul(a,a,c), mpfi_exp(a,a)
Func2_MPFR_MPFI(POW,mpfi_fr_pow);

Func2_MPFI(INTERSECT,mpfi_intersect);
Func2_MPFI(UNION,mpfi_union);
Func2_MPFI(ATAN2,mpfi_atan2);
Func2_MPFI(HYPOT,mpfi_hypot);

/*Func2_MPFI(MOD,mpfi_remainder);*/

static Obj LQUO_MPFI(Obj self, Obj fl, Obj fr)
{
  return QUO_MPFI(self, fr, fl);
}

static Obj LQUO_MPFI_MPFR(Obj self, Obj fl, Obj fr)
{
  return QUO_MPFR_MPFI(self, fr, fl);
}

static Obj LQUO_MPFR_MPFI(Obj self, Obj fl, Obj fr)
{
  return QUO_MPFI_MPFR(self, fr, fl);
}

static Obj ROOT_MPFI(Obj self, Obj fl, Obj fr) /* strangely not in mpfi */
{
  TEST_IS_INTOBJ("ROOT_MPFI",fr);

  Obj g = NEW_MPFI(mpfi_get_prec(GET_MPFI(fl)));
  
  mpfr_root (&MPFI_OBJ(g)->left, &GET_MPFI(fl)->left, INT_INTOBJ(fr), GMP_RNDD);
  mpfr_root (&MPFI_OBJ(g)->right, &MPFI_OBJ(fl)->right, INT_INTOBJ(fr), GMP_RNDU);
  return g;
}

static Obj EQ_MPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_cmp(GET_MPFI(fl),GET_MPFI(fr)) == 0 ? True : False;
}

static Obj EQ_MPFI_MPFR (Obj self, Obj fl, Obj fr)
{
  return mpfi_cmp_fr(GET_MPFI(fl),GET_MPFR(fr)) == 0 ? True : False;
}

static Obj EQ_MPFR_MPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_cmp_fr(GET_MPFI(fr),GET_MPFR(fl)) == 0 ? True : False;
}

static Obj LT_MPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_cmp(GET_MPFI(fl),GET_MPFI(fr)) < 0 ? True : False;
}

static Obj LT_MPFI_MPFR (Obj self, Obj fl, Obj fr)
{
  return mpfi_cmp_fr(GET_MPFI(fl),GET_MPFR(fr)) < 0 ? True : False;
}

static Obj LT_MPFR_MPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_cmp_fr(GET_MPFI(fr),GET_MPFR(fl)) > 0 ? True : False;
}

static Obj ISINSIDE_MPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_is_inside(GET_MPFI(fl),GET_MPFI(fr)) ? True : False;
}

static Obj ISSTRICTLY_INSIDE_MPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_is_strictly_inside(GET_MPFI(fl),GET_MPFI(fr)) ? True : False;
}

static Obj ISINSIDE_ZMPFI (Obj self, Obj fl, Obj fr)
{
  if (IS_INTOBJ(fr)) {
    return mpfi_is_inside_si (INT_INTOBJ(fl), GET_MPFI(fr)) ? True : False;
  } else {
    Obj f = MPZ_LONGINT(fl);
    return mpfi_is_inside_z (mpz_MPZ(f), GET_MPFI(fr)) ? True : False;
  }
}

static Obj ISINSIDE_MPFRMPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_is_inside_fr(GET_MPFR(fl),GET_MPFI(fr)) ? True : False;
}

static Obj MPFI_2MPFR (Obj self, Obj fl, Obj fr)
{
  mp_prec_t precl = mpfr_get_prec(GET_MPFR(fl)),
    precr = mpfr_get_prec(GET_MPFR(fr));
  
  Obj g = NEW_MPFI(precl > precr ? precl : precr);
  mpfi_interv_fr(MPFI_OBJ(g), GET_MPFR(fl), GET_MPFR(fr));

  return g;
}

static Obj INCREASE_MPFI (Obj self, Obj fl, Obj fr)
{
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(fl));
  
  Obj g = NEW_MPFI(prec);
  mpfi_set(MPFI_OBJ(g), GET_MPFI(fl));
  mpfi_increase(MPFI_OBJ(g), GET_MPFR(fr));

  return g;
}

static Obj BLOWUP_MPFI (Obj self, Obj fl, Obj fr)
{
  mp_prec_t prec = mpfi_get_prec(GET_MPFI(fl));
  
  Obj g = NEW_MPFI(prec);
  mpfi_blow(MPFI_OBJ(g), MPFI_OBJ(fl), mpfr_get_d(GET_MPFR(fr), GMP_RNDN));

  return g;
}

/****************************************************************
 * export functions
 ****************************************************************/
static StructGVarFunc GVarFuncs [] = {  
  Inc1_MPFI(AINV_MPFI),
  Inc1_MPFI(ABS_MPFI),
  Inc1_MPFI(INV_MPFI),

  Inc1_MPFI(COS_MPFI),
  Inc1_MPFI(SIN_MPFI),
  Inc1_MPFI(TAN_MPFI),
  Inc1_MPFI(SEC_MPFI),
  Inc1_MPFI(CSC_MPFI),
  Inc1_MPFI(COT_MPFI),
  Inc1_MPFI(ASIN_MPFI),
  Inc1_MPFI(ACOS_MPFI),
  Inc1_MPFI(ATAN_MPFI)
,
  Inc1_MPFI(COSH_MPFI),
  Inc1_MPFI(SINH_MPFI),
  Inc1_MPFI(TANH_MPFI),
  Inc1_MPFI(SECH_MPFI),
  Inc1_MPFI(CSCH_MPFI),
  Inc1_MPFI(COTH_MPFI),
  Inc1_MPFI(ASINH_MPFI),
  Inc1_MPFI(ACOSH_MPFI),
  Inc1_MPFI(ATANH_MPFI),

  Inc1_MPFI(LOG_MPFI),
  Inc1_MPFI(LOG2_MPFI),
  Inc1_MPFI(LOG10_MPFI),
  Inc1_MPFI(EXP_MPFI),
  Inc1_MPFI(EXP2_MPFI),
  Inc1_MPFI(EXP10_MPFI),
  Inc1_MPFI(LOG1P_MPFI),
  Inc1_MPFI(EXPM1_MPFI),

  Inc1_MPFI(SQRT_MPFI),
  Inc1_MPFI(CBRT_MPFI),
  Inc1_MPFI(SQR_MPFI),

  Inc1_MPFI(ZERO_MPFI),
  Inc1_MPFI(ONE_MPFI),
  Inc1_MPFI_arg(MPFI_MAKENAN,"int"),
  Inc1_MPFI_arg(MPFI_MAKEINFINITY,"int"),
  Inc1_MPFI_arg(MPFI_LOG2,"int"),
  Inc1_MPFI_arg(MPFI_PI,"int"),
  Inc1_MPFI_arg(MPFI_EULER,"int"),
  Inc1_MPFI_arg(MPFI_CATALAN,"int"),
  Inc1_MPFI_arg(MPFI_INT,"int"),
  Inc1_MPFI(INT_MPFI),
  Inc1_MPFI(PREC_MPFI),
  Inc1_MPFI(LEFT_MPFI),
  Inc1_MPFI(RIGHT_MPFI),
  Inc1_MPFI(MPFI_MPFR),
  Inc1_MPFI(DIAM_ABS_MPFI),
  Inc1_MPFI(DIAM_REL_MPFI),
  Inc1_MPFI(DIAM_MPFI),
  Inc1_MPFI(MAG_MPFI),
  Inc1_MPFI(MIG_MPFI),
  Inc1_MPFI(MID_MPFI),
  Inc1_MPFI(BISECT_MPFI),
  Inc1_MPFI(ALEA_MPFI),
  Inc1_MPFI(SIGN_MPFI),
  Inc1_MPFI(ISPOS_MPFI),
  Inc1_MPFI(ISNEG_MPFI),
  Inc1_MPFI(ISSTRICTLY_POS_MPFI),
  Inc1_MPFI(ISSTRICTLY_NEG_MPFI),
  Inc1_MPFI(ISNONPOS_MPFI),
  Inc1_MPFI(ISNONNEG_MPFI),
  Inc1_MPFI(ISZERO_MPFI),
  Inc1_MPFI(HASZERO_MPFI),
  Inc1_MPFI(ISNAN_MPFI),
  Inc1_MPFI(ISXINF_MPFI),
  Inc1_MPFI(ISNINF_MPFI),
  Inc1_MPFI(ISPINF_MPFI),
  Inc1_MPFI(ISNUMBER_MPFI),
  Inc1_MPFI(ISEMPTY_MPFI),
  
  Inc2_MPFIX(SUM),
  Inc2_MPFIX(DIFF),
  Inc2_MPFIX(PROD),
  Inc2_MPFIX(QUO),
  Inc2_MPFIX(POW),
  Inc2_MPFIX(LQUO),
  Inc2_MPFIX(EQ),
  Inc2_MPFIX(LT),
  /*Inc2_MPFI(MOD_MPFI),*/
  Inc2_MPFI(ATAN2_MPFI),
  Inc2_MPFI(HYPOT_MPFI),
  Inc2_MPFI(INTERSECT_MPFI),
  Inc2_MPFI(UNION_MPFI),
  Inc2_MPFI(ISINSIDE_MPFI),
  Inc2_MPFI(ISSTRICTLY_INSIDE_MPFI),
  Inc2_MPFI_arg(ISINSIDE_ZMPFI,"int, interval"),
  Inc2_MPFI_arg(ISINSIDE_MPFRMPFI,"float, interval"),
  Inc2_MPFI_arg(MPFI_STRING,"string, int"),
  Inc2_MPFI_arg(STRING_MPFI,"interval, int"),
  Inc2_MPFI_arg(VIEWSTRING_MPFI,"interval, int"),
  Inc2_MPFI_arg(ROOT_MPFI,"interval, int"),
  Inc2_MPFI_arg(MPFI_INTPREC,"int, int"),
  Inc2_MPFI_arg(MPFI_MPFIPREC,"interval, int"),
  Inc2_MPFI_arg(LDEXP_MPFI,"interval, int"),
  Inc1_MPFI(EXTREPOFOBJ_MPFI),
  Inc1_MPFI(FREXP_MPFI),
  Inc1_MPFI(OBJBYEXTREP_MPFI),
  Inc2_MPFI(MPFI_2MPFR),
  Inc2_MPFI_arg(INCREASE_MPFI,"interval, MPFR real"),
  Inc2_MPFI_arg(BLOWUP_MPFI,"interval, MPFR real"),

  {0}
};

int InitMPFIKernel (void)
{
  InitHdlrFuncsFromTable (GVarFuncs);

  ImportGVarFromLibrary ("TYPE_MPFI", &TYPE_MPFI);
  return 0;
}

int InitMPFILibrary (void)
{
  InitGVarFuncsFromTable (GVarFuncs);
  return 0;
}

/****************************************************************************
**
*E  mpfi.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
