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

#include <real.hpp>
#include <complex.hpp>

#define cpoly cpoly_CXSC

#define xMAX_EXP DBL_MAX_EXP
#define xMIN_EXP DBL_MIN_EXP
#define xINFIN DBL_MAX
  
typedef double xreal;
typedef cxsc::complex xcomplex;

static const xreal xabs(const xcomplex &newz)
{
  return _double(abs(newz));
}

static const xreal xnorm(const xcomplex &newz)
{
  return _double(abs2(newz));
}

static const xreal xroot(xreal x, int n)
{
  return pow(x,1.0/n);
}

static const int xbits(const xcomplex &z)
{
  return 53;
}

static const xreal xeta(const xcomplex &z)
{
  return _double(cxsc::Epsilon);
}

static const long int xlogb(const xcomplex &newz)
{
  long e0 = expo(Re(newz)), e1 = expo(Im(newz));
  return e0 > e1 ? e0 : e1;
}

static void xscalbln(xcomplex *z, long int a)
{
  cxsc::real re = Re(*z), im = Im(*z);
  
  times2pown(re,a);
  times2pown(im,a);
  *z = cxsc::complex(re,im);
}

int default_prec;

#include "cpoly.C"
