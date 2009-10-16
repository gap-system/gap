/****************************************************************************
**
*W  mpfi.c                       GAP source                 Laurent Bartholdi
**
*H  @(#)$Id: mpfi.c,v 1.1 2008/06/14 15:45:40 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file contains the functions for the float package.
**  interval floats are implemented using the MPFI package.
*/
const char * Revision_mpfi_c =
   "@(#)$Id: mpfi.c,v 1.1 2008/06/14 15:45:40 gap Exp $";

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

Func1_MPFI(COSH_MPFI,mpfi_cosh);
Func1_MPFI(SINH_MPFI,mpfi_sinh);
Func1_MPFI(TANH_MPFI,mpfi_tanh);
Func1_MPFI(ACOSH_MPFI,mpfi_acosh);
Func1_MPFI(ASINH_MPFI,mpfi_asinh);
Func1_MPFI(ATANH_MPFI,mpfi_atanh);

Func1_MPFI(LOG_MPFI,mpfi_log);
Func1_MPFI(LOG2_MPFI,mpfi_log2);
Func1_MPFI(LOG10_MPFI,mpfi_log10);
Func1_MPFI(EXP_MPFI,mpfi_exp);
Func1_MPFI(EXP2_MPFI,mpfi_exp2);

Func1_MPFI(INV_MPFI,mpfi_inv);
Func1_MPFI(AINV_MPFI,mpfi_neg);
Func1_MPFI(SQRT_MPFI,mpfi_sqrt);
Func1_MPFI(SQR_MPFI,mpfi_sqr);
Func1_MPFI(ABS_MPFI,mpfi_abs);
Func1_MPFI(LOG1P_MPFI,mpfi_log1p);
Func1_MPFI(EXPM1_MPFI,mpfi_expm1);

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
{
  mpz_t y, z;
  Obj res;

  mpz_init2 (y, mpfr_get_exp(&GET_MPFI(f)->left)+1);
  mpz_init2 (z, mpfr_get_exp(&GET_MPFI(f)->right)+1);

  mpfr_get_z (y, &GET_MPFI(f)->left, GMP_RNDZ);
  mpfr_get_z (z, &MPFI_OBJ(f)->right, GMP_RND_MAX);

  if (mpz_cmp(y, z) == 0)
    res = INT_mpz(y);
  else
    res = Fail;

  mpz_clear(y);
  mpz_clear(z);

  return res;
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

Func1_BOOLMPFI(IS_POS_MPFI,mpfi_is_pos);
Func1_BOOLMPFI(IS_STRICTLY_POS_MPFI,mpfi_is_strictly_pos);
Func1_BOOLMPFI(IS_NONNEG_MPFI,mpfi_is_nonneg);
Func1_BOOLMPFI(IS_NEG_MPFI,mpfi_is_neg);
Func1_BOOLMPFI(IS_STRICTLY_NEG_MPFI,mpfi_is_strictly_neg);
Func1_BOOLMPFI(IS_NONPOS_MPFI,mpfi_is_nonpos);
Func1_BOOLMPFI(IS_ZERO_MPFI,mpfi_is_zero);
Func1_BOOLMPFI(HAS_ZERO_MPFI,mpfi_has_zero);
Func1_BOOLMPFI(IS_NAN_MPFI,mpfi_nan_p);
Func1_BOOLMPFI(IS_INF_MPFI,mpfi_inf_p);
Func1_BOOLMPFI(IS_BOUNDED_MPFI,mpfi_bounded_p);
Func1_BOOLMPFI(IS_EMPTY_MPFI,mpfi_is_empty);

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
  Obj str1 = NEW_STRING(prec*302/1000+20),
    str2 = NEW_STRING(prec*302/1000+20);
  mp_exp_t exp1, exp2;

  TEST_IS_INTOBJ("VIEWSTRING_MPFI",digits);

  int n = INT_INTOBJ(digits);
  if (n == 1) n = 2;

  char *c1 = CSTR_STRING(str1);
  char *c2 = CSTR_STRING(str2);
  int slen1 = PRINT_MPFR(c1, &exp1, n, &GET_MPFI(f)->left, GMP_RNDD);
  int slen2 = PRINT_MPFR(c2, &exp2, n, &MPFI_OBJ(f)->right, GMP_RNDU);
  
  int match = 0;
  if (exp1 == exp2) {
    while (c1[match] == c2[match] && c1[match])
      match++;
  } else if (exp1 == exp2-1) {
    if (c1[match] == '-' && c1[match] == '-')
      match++;
    if (c1[match] != '.' || c2[match++] != '.')
      goto skip;
    if (c1[match] != '9' || c2[match++] != '1')
      goto skip;
    while (c1[match] == '9' && c2[match] == '0')
      match++;
  }
 skip:
  if (match <= 3) {
    Obj str = NEW_STRING(slen1+slen2+3);
    char *c = CSTR_STRING(str);
    *c++ = '(';
    strcpy(c,c1);
    *(c += slen1) = ':';
    strcpy(++c,c2);
    c[slen2] = ')';
    return str;
  }

  if (c1[match] || c2[match]) /* didn't match everything */
    n = match - (c1[0] == '-');

  for (c1 = c2+match; *c1 && *c1 != 'e'; c1++, slen2--); /* part to skip */

  while (c2[match-1] == '0' && c2[match-2] != '.') /* remove trailing 0s */
    match--, slen2--;
  while (*c1) /* copy exponent */
    c2[match++] = *c1++;
  sprintf(c2+slen2, "(%d)", n);
  SET_LEN_STRING(str2, strlen(c2));
  SHRINK_STRING(str2);
  return str2;
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
  static Obj name(Obj self, Obj fl, Obj fr)				\
  {									\
    mp_prec_t precl = mpfi_get_prec(GET_MPFI(fl)),			\
      precr = mpfi_get_prec(GET_MPFI(fr));				\
									\
    Obj g = NEW_MPFI(precl > precr ? precl : precr);			\
    mpfi_name (MPFI_OBJ(g), GET_MPFI(fl), GET_MPFI(fr));		\
    return g;								\
  }
#define Inc2_MPFI_arg(name,arg)			\
  { #name, 2, arg, name, "src/mpfi.c:" #name }
#define Inc2_MPFI(name) Inc2_MPFI_arg(name,"interval, interval")

Func2_MPFI(SUM_MPFI,mpfi_add);
Func2_MPFI(DIFF_MPFI,mpfi_sub);
Func2_MPFI(PROD_MPFI,mpfi_mul);
Func2_MPFI(QUO_MPFI,mpfi_div);
Func2_MPFI(INTERSECT_MPFI,mpfi_intersect);
Func2_MPFI(UNION_MPFI,mpfi_union);
/*
Func2_MPFI(POW_MPFI,mpfi_pow);
Func2_MPFI(MOD_MPFI,mpfi_remainder);
Func2_MPFI(ATAN2_MPFI,mpfi_atan2);
*/

static Obj LQUO_MPFI(Obj self, Obj fl, Obj fr)
{
  mp_prec_t precl = mpfi_get_prec(GET_MPFI(fl)),
    precr = mpfi_get_prec(GET_MPFI(fr));
  
  Obj g = NEW_MPFI(precl > precr ? precl : precr);
  mpfi_div (MPFI_OBJ(g), GET_MPFI(fr), GET_MPFI(fl));
  return g;
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
  return mpfi_cmp(GET_MPFI(fr),GET_MPFI(fl)) == 0 ? True : False;
}

static Obj LT_MPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_cmp(GET_MPFI(fl),GET_MPFI(fr)) < 0 ? True : False;
}

static Obj IS_INSIDE_MPFI (Obj self, Obj fl, Obj fr)
{
  return mpfi_is_inside(GET_MPFI(fl),GET_MPFI(fr)) ? True : False;
}

static Obj IS_INSIDE_ZMPFI (Obj self, Obj fl, Obj fr)
{
  if (IS_INTOBJ(fr)) {
    return mpfi_is_inside_si (INT_INTOBJ(fl), GET_MPFI(fr)) ? True : False;
  } else {
    Obj f = MPZ_LONGINT(fl);
    return mpfi_is_inside_z (mpz_MPZ(f), GET_MPFI(fr)) ? True : False;
  }
}

static Obj IS_INSIDE_MPFRMPFI (Obj self, Obj fl, Obj fr)
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
  Inc1_MPFI(ASIN_MPFI),
  Inc1_MPFI(ACOS_MPFI),
  Inc1_MPFI(ATAN_MPFI)
,
  Inc1_MPFI(COSH_MPFI),
  Inc1_MPFI(SINH_MPFI),
  Inc1_MPFI(TANH_MPFI),
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
  Inc1_MPFI(IS_POS_MPFI),
  Inc1_MPFI(IS_NEG_MPFI),
  Inc1_MPFI(IS_STRICTLY_POS_MPFI),
  Inc1_MPFI(IS_STRICTLY_NEG_MPFI),
  Inc1_MPFI(IS_NONPOS_MPFI),
  Inc1_MPFI(IS_NONNEG_MPFI),
  Inc1_MPFI(IS_ZERO_MPFI),
  Inc1_MPFI(HAS_ZERO_MPFI),
  Inc1_MPFI(IS_NAN_MPFI),
  Inc1_MPFI(IS_INF_MPFI),
  Inc1_MPFI(IS_BOUNDED_MPFI),
  Inc1_MPFI(IS_EMPTY_MPFI),
  
  Inc2_MPFI(SUM_MPFI),
  Inc2_MPFI(DIFF_MPFI),
  Inc2_MPFI(PROD_MPFI),
  Inc2_MPFI(QUO_MPFI),
  Inc2_MPFI(LQUO_MPFI),
  /*
  Inc2_MPFI(POW_MPFI),
  Inc2_MPFI(MOD_MPFI),
  Inc2_MPFI(ATAN2_MPFI),
  */
  Inc2_MPFI(EQ_MPFI),
  Inc2_MPFI(LT_MPFI),
  Inc2_MPFI(INTERSECT_MPFI),
  Inc2_MPFI(UNION_MPFI),
  Inc2_MPFI(IS_INSIDE_MPFI),
  Inc2_MPFI_arg(IS_INSIDE_ZMPFI,"int, interval"),
  Inc2_MPFI_arg(IS_INSIDE_MPFRMPFI,"float, interval"),
  Inc2_MPFI_arg(MPFI_STRING,"string, int"),
  Inc2_MPFI_arg(STRING_MPFI,"interval, int"),
  Inc2_MPFI_arg(VIEWSTRING_MPFI,"interval, int"),
  Inc2_MPFI_arg(ROOT_MPFI,"interval, int"),
  Inc2_MPFI_arg(MPFI_INTPREC,"int, int"),
  Inc2_MPFI_arg(MPFI_MPFIPREC,"interval, int"),
  Inc2_MPFI(MPFI_2MPFR),

  {0}
};

int InitMPFIKernel (void)
{
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
