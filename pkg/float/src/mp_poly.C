/****************************************************************************
 *
 * cpoly_mpc.C                                              Laurent Bartholdi
 *
 *   @(#)$id: fr_dll.c,v 1.18 2010/10/26 05:19:40 gap exp $
 *
 * Copyright (c) 2011, Laurent Bartholdi
 *
 ****************************************************************************
 *
 * driver for cpoly.C, using mpc_t complex numbers
 *
 ****************************************************************************/
#include <mpc.h>
#include <limits.h>
#include <math.h>

#define cpoly cpoly_MPC

static mp_prec_t default_prec = 128; // ugly, non-reentrant

typedef double xreal;

struct xcomplex {
  mpc_t z;

  static const mp_rnd_t default_rnd;

  // constructor
  xcomplex(){ mpc_init2(z,default_prec); }
  xcomplex(const int i){ mpc_init2(z,default_prec); mpc_set_si(z,i,default_rnd); }
  xcomplex(const xcomplex &x){ mpc_init2(z,default_prec); mpc_set(z,x.z,default_rnd); }
#ifdef MPFR_REALS
  xcomplex(const double a){ mpc_init2(z,default_prec); mpc_set_d(z,a,default_rnd); }
  xcomplex(const xreal r){ mpc_init2(z,default_prec); mpc_set_f(z,r.get_mpf_t(),default_rnd); };
  xcomplex(const xreal a,const xreal b){ mpc_init2(z,default_prec); mpc_set_f_f(z,a.get_mpf_t(),b.get_mpf_t(),default_rnd); };
#else
  xcomplex(const xreal r){ mpc_init2(z,default_prec); mpc_set_d(z,r,default_rnd); }
  xcomplex(const xreal a,const xreal b){ mpc_init2(z,default_prec); mpc_set_d_d(z,a,b,default_rnd); }
#endif
  ~xcomplex() { mpc_clear(z); }

  // operations
  xcomplex operator - () const { xcomplex newz; mpc_neg(newz.z,z,default_rnd); return(newz); };

  void operator += (const xcomplex &a){ mpc_add(z,z,a.z,default_rnd); };
  void operator -= (const xcomplex &a){ mpc_sub(z,z,a.z,default_rnd); };
  void operator *= (const xcomplex &a){ mpc_mul(z,z,a.z,default_rnd); };
  void operator /= (const xcomplex &a){ mpc_div(z,z,a.z,default_rnd); };
  
  void operator = (const mpc_t &newz){ mpc_set_prec(z,mpc_get_prec(newz)); mpc_set(z,newz,default_rnd) ;
  };
  void operator = (const xcomplex &newz){ mpc_set_prec(z,mpc_get_prec(newz.z)); mpc_set(z,newz.z,default_rnd); };
};

const mp_rnd_t xcomplex::default_rnd = mpfr_get_default_rounding_mode();
const long int xMAX_EXP = mpfr_get_emax();
const long int xMIN_EXP = mpfr_get_emin();
const xreal xINFIN = pow(2,xMAX_EXP);

bool const operator == (const xcomplex &a, const xcomplex &b) {
  return(mpc_cmp(a.z,b.z) == 0);
}
bool const operator != (const xcomplex &a, const xcomplex &b) {
  return(mpc_cmp(a.z,b.z) != 0);
}
xcomplex const operator + (const xcomplex &a, const xcomplex &b) {
  xcomplex newz; mpc_add(newz.z,a.z,b.z,xcomplex::default_rnd); return(newz);
}
xcomplex const operator - (const xcomplex &a, const xcomplex &b) {
  xcomplex newz; mpc_sub(newz.z,a.z,b.z,xcomplex::default_rnd); return(newz);
}
xcomplex const operator * (const xcomplex &a, const xcomplex &b) {
  xcomplex newz; mpc_mul(newz.z,a.z,b.z,xcomplex::default_rnd); return(newz);
}
xcomplex const operator / (const xcomplex &a, const xcomplex &b) {
  xcomplex newz; mpc_div(newz.z,a.z,b.z,xcomplex::default_rnd); return(newz);
}

static const xreal xabs(const xcomplex &newz){ 
  xreal tmp;
  mpfr_t tmpfr;
  mpfr_init2(tmpfr,default_prec);
  mpc_abs(tmpfr,newz.z,xcomplex::default_rnd);
#ifdef MPFR_REALS
  mpfr_get_f(tmp.get_mpf_t(),tmpfr,xcomplex::default_rnd);
#else
  tmp = mpfr_get_d(tmpfr,xcomplex::default_rnd);
#endif
  mpfr_clear(tmpfr);
  return tmp;
}

static const xreal xnorm(const xcomplex &newz){
  xreal tmp;
  mpfr_t tmpfr;
  mpfr_init2(tmpfr,default_prec);
  mpc_norm(tmpfr,newz.z,xcomplex::default_rnd);
#ifdef MPFR_REALS
  mpfr_get_f(tmp.get_mpf_t(),tmpfr,xcomplex::default_rnd);
#else
  tmp = mpfr_get_d(tmpfr,xcomplex::default_rnd);
#endif
  mpfr_clear(tmpfr);
  return tmp;
}

static const long int xlogb(const xcomplex &newz){
  long e = INT_MIN;
  if (mpfr_cmp_si(mpc_realref(newz.z),0) != 0)
    e = mpfr_get_exp(mpc_realref(newz.z));
  if (mpfr_cmp_si(mpc_imagref(newz.z),0) != 0) {
    long ee = mpfr_get_exp(mpc_imagref(newz.z));
    if (ee > e) e = ee;
  }
  return e;
}

static void xscalbln(xcomplex *z, long int a){
  mpfr_mul_2si(mpc_realref(z->z),mpc_realref(z->z),a,xcomplex::default_rnd);
  mpfr_mul_2si(mpc_imagref(z->z),mpc_imagref(z->z),a,xcomplex::default_rnd);
}

static const xreal xroot(xreal x, int n)
{
  return pow(x,1.0/n);
}

static const int xbits(const xcomplex &z)
{
  return default_prec;
  return mpc_get_prec(z.z);
}

static const xreal xeta(const xcomplex &z)
{
  return scalbln(1.0,1-default_prec);
  return scalbln(1.0,1-mpc_get_prec(z.z));
}

#include "cpoly.C"
