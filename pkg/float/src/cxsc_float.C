/****************************************************************************
**
*W  cxsc_float.C                    GAP source              Laurent Bartholdi
**
*H  @(#)$Id: cxsc_float.C,v 1.1 2008/06/14 15:45:40 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file contains the main dll of the CXSC float package.
*/
static const char *Revision_cxsc_float_c =
   "@(#)$Id: cxsc_float.C,v 1.1 2008/06/14 15:45:40 gap Exp $";

#define TRACE_ALLOC
#define BANNER_CXSC_FLOAT_H
#define USE_GMP

#include <string.h>
#include <malloc.h>
#include <stdio.h>

extern "C" {
#include "src/system.h"
#include "src/gap.h"
#include "src/objects.h"
#include "src/gasman.h"
#include "src/string.h"
#include "src/bool.h"
#include "src/plist.h"
#define NR_SMALL_INT_BITS (8*sizeof(long)-4)
}
#include "cxsc_float.h"

#include "cpoly.hpp"
#include "cipoly.hpp"
#include "cpzero.hpp"

Obj TYPE_CXSC_REAL, TYPE_CXSC_COMPLEX, TYPE_CXSC_INTERVAL, TYPE_CXSC_CINTERVAL;
Obj FAMILY_CXSC_REAL, FAMILY_CXSC_COMPLEX, FAMILY_CXSC_INTERVAL, FAMILY_CXSC_CINTERVAL;

/****************************************************************
 * creators
 ****************************************************************/
inline Obj NEW_REAL (void)
{
  return NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::real));
}
inline Obj NEW_COMPLEX (void)
{
  return NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::complex));
}
inline Obj NEW_INTERVAL (void)
{
  return NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::interval));
}
inline Obj NEW_CINTERVAL (void)
{
  return NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::cinterval));
}

inline Obj OBJ_REAL (cxsc::real i)
{
  Obj f = NEW_REAL();
  REAL_OBJ(f) = i;
  SET_TYPE_DATOBJ(f, TYPE_CXSC_REAL);
  return f;
}
inline Obj OBJ_COMPLEX (cxsc::complex i)
{
  Obj f = NEW_COMPLEX();
  COMPLEX_OBJ(f) = i;
  SET_TYPE_DATOBJ(f, TYPE_CXSC_COMPLEX);
  return f;
}
inline Obj OBJ_INTERVAL (cxsc::interval i)
{
  Obj f = NEW_INTERVAL();
  INTERVAL_OBJ(f) = i;
  SET_TYPE_DATOBJ(f, TYPE_CXSC_INTERVAL);
  return f;
}
inline Obj OBJ_CINTERVAL (cxsc::cinterval i)
{
  Obj f = NEW_CINTERVAL();
  CINTERVAL_OBJ(f) = i;
  SET_TYPE_DATOBJ(f, TYPE_CXSC_CINTERVAL);
  return f;
}
  
inline Obj OBJ_RP(cxsc::real x) { return OBJ_REAL(x); }
inline Obj OBJ_CP(cxsc::complex x) { return OBJ_COMPLEX(x); }
inline Obj OBJ_RI(cxsc::interval x) { return OBJ_INTERVAL(x); }
inline Obj OBJ_CI(cxsc::cinterval x) { return OBJ_CINTERVAL(x); }
inline cxsc::real RP_GET(cxsc::real x) { return x; }
inline cxsc::complex CP_GET(cxsc::real x) { return _complex(x); }
inline cxsc::interval RI_GET(cxsc::real x) { return _interval(x); }
inline cxsc::cinterval CI_GET(cxsc::real x) { return _cinterval(x); }

/****************************************************************
 * 1-argument functions
 ****************************************************************/
#define Func1_CXSC(gap_name,cxsc_name)				\
  static Obj gap_name##_R(Obj self, Obj f)			\
  {								\
    TEST_IS_REAL(#gap_name "_R",f);				\
    if (IsQuietNaN(REAL_OBJ(f))) { return f; }			\
    return OBJ_REAL(cxsc_name(REAL_OBJ(f)));			\
  }								\
  static Obj gap_name##_C(Obj self, Obj f)			\
  {								\
    TEST_IS_COMPLEX(#gap_name "_C",f);				\
    if (IsQuietNaN(Re(COMPLEX_OBJ(f)))) { return f; }		\
    return OBJ_COMPLEX(cxsc_name(COMPLEX_OBJ(f)));		\
  }								\
  static Obj gap_name##_I(Obj self, Obj f)			\
  {								\
    TEST_IS_INTERVAL(#gap_name "_I",f);				\
    if (IsQuietNaN(Inf(INTERVAL_OBJ(f)))) { return f; }		\
    return OBJ_INTERVAL(cxsc_name(INTERVAL_OBJ(f)));		\
  }								\
  static Obj gap_name##_D(Obj self, Obj f)			\
  {								\
    TEST_IS_CINTERVAL(#gap_name "_D",f);			\
    if (IsQuietNaN(Inf(Re(CINTERVAL_OBJ(f))))) { return f; }	\
    return OBJ_CINTERVAL(cxsc_name(CINTERVAL_OBJ(f)));		\
  }

typedef Obj (*ObjFunc)(); // I never could get the () and * right

#define Inc1_CXSC_arg(name,arg)		\
  { #name, 1, arg, (ObjFunc) name, "src/cxsc_float.c:" #name }
#define Inc1_CXSC(name)	\
  Inc1_CXSC_arg(name##_R,"real"),			\
    Inc1_CXSC_arg(name##_C,"complex"),		\
    Inc1_CXSC_arg(name##_I,"interval"),		\
    Inc1_CXSC_arg(name##_D,"cinterval")

static Obj CXSC_INT (Obj self, Obj f)
{
  TEST_IS_INTOBJ("CXSC_INT",f);
  return OBJ_REAL(INT_INTOBJ(f));
}

static Obj CXSC_C_RR (Obj self, Obj f, Obj g)
{
  TEST_IS_REAL("CXSC_C_RR",f);
  TEST_IS_REAL("CXSC_C_RR",g);
  return OBJ_COMPLEX(cxsc::complex(REAL_OBJ(f),REAL_OBJ(g)));
}
static Obj CXSC_I_R (Obj self, Obj f)
{
  TEST_IS_REAL("CXSC_I_R",f);
  return OBJ_INTERVAL(cxsc::interval(REAL_OBJ(f)));
}
static Obj CXSC_I_RR (Obj self, Obj f, Obj g)
{
  TEST_IS_REAL("CXSC_I_RR",f);
  TEST_IS_REAL("CXSC_I_RR",g);
  return OBJ_INTERVAL(cxsc::interval(REAL_OBJ(f),REAL_OBJ(g)));
}
static Obj CXSC_D_C (Obj self, Obj f)
{
  TEST_IS_COMPLEX("CXSC_D_C",f);
  return OBJ_CINTERVAL(cxsc::cinterval(COMPLEX_OBJ(f)));
}
static Obj CXSC_D_II (Obj self, Obj f, Obj g)
{
  TEST_IS_INTERVAL("CXSC_D_II",f);
  TEST_IS_INTERVAL("CXSC_D_II",g);
  return OBJ_CINTERVAL(cxsc::cinterval(INTERVAL_OBJ(f),INTERVAL_OBJ(g)));
}
static Obj CXSC_NEWCONSTANT (Obj self, Obj f)
{
  TEST_IS_INTOBJ("CXSC_NEWCONSTANT",f);
  switch (INT_INTOBJ(f)) {
  case 0: return OBJ_REAL(cxsc::MinReal);
  case 1: return OBJ_REAL(cxsc::minreal);
  case 2: return OBJ_REAL(cxsc::MaxReal);
  case 3: return OBJ_REAL(cxsc::Infinity);
  case 4: return OBJ_REAL(cxsc::SignalingNaN);
  case 5: return OBJ_REAL(cxsc::QuietNaN);
  case 6: return OBJ_REAL(cxsc::Pi_real);        // Pi
  case 7: return OBJ_REAL(cxsc::Pi2_real);       // 2*Pi
  case 8: return OBJ_REAL(cxsc::Pi3_real);       // 3*Pi
  case 9: return OBJ_REAL(cxsc::Pid2_real);      // Pi/2
  case 10: return OBJ_REAL(cxsc::Pid3_real);      // Pi/3
  case 11: return OBJ_REAL(cxsc::Pid4_real);      // Pi/4
  case 12: return OBJ_REAL(cxsc::Pir_real);       // 1/Pi
  case 13: return OBJ_REAL(cxsc::Pi2r_real);      // 1/(2*Pi)
  case 14: return OBJ_REAL(cxsc::Pip2_real);      // Pi^2
  case 15: return OBJ_REAL(cxsc::SqrtPi_real);    // sqrt(Pi)
  case 16: return OBJ_REAL(cxsc::Sqrt2Pi_real);   // sqrt(2Pi)
  case 17: return OBJ_REAL(cxsc::SqrtPir_real);   // 1/sqrt(Pi)
  case 18: return OBJ_REAL(cxsc::Sqrt2Pir_real);  // 1/sqrt(2Pi)
  case 19: return OBJ_REAL(cxsc::Sqrt2_real);     // sqrt(2)
  case 20: return OBJ_REAL(cxsc::Sqrt2r_real);    // 1/sqrt(2)
  case 21: return OBJ_REAL(cxsc::Sqrt3_real);     // sqrt(3)
  case 22: return OBJ_REAL(cxsc::Sqrt3d2_real);   // sqrt(3)/2
  case 23: return OBJ_REAL(cxsc::Sqrt3r_real);    // 1/sqrt(3)
  case 24: return OBJ_REAL(cxsc::Ln2_real);       // ln(2)
  case 25: return OBJ_REAL(cxsc::Ln2r_real);      // 1/ln(2)
  case 26: return OBJ_REAL(cxsc::Ln10_real);      // ln(10)
  case 27: return OBJ_REAL(cxsc::Ln10r_real);     // 1/ln(10)
  case 28: return OBJ_REAL(cxsc::LnPi_real);      // ln(Pi)
  case 29: return OBJ_REAL(cxsc::Ln2Pi_real);     // ln(2Pi)
  case 30: return OBJ_REAL(cxsc::E_real);         // e
  case 31: return OBJ_REAL(cxsc::Er_real);        // 1/e
  case 32: return OBJ_REAL(cxsc::Ep2_real);       // e^2
  case 33: return OBJ_REAL(cxsc::Ep2r_real);      // 1/e^2
  case 34: return OBJ_REAL(cxsc::EpPi_real);      // e^(Pi)
  case 35: return OBJ_REAL(cxsc::Ep2Pi_real);     // e^(2Pi)
  case 36: return OBJ_REAL(cxsc::EpPid2_real);    // e^(Pi/2)
  case 37: return OBJ_REAL(cxsc::EpPid4_real);    // e^(Pi/4)
  case 100: return OBJ_INTERVAL(cxsc::Pi_interval);        // Pi
  case 101: return OBJ_INTERVAL(cxsc::Pi2_interval);       // 2*Pi
  case 102: return OBJ_INTERVAL(cxsc::Pi3_interval);       // 3*Pi
  case 103: return OBJ_INTERVAL(cxsc::Pid2_interval);      // Pi/2
  case 104: return OBJ_INTERVAL(cxsc::Pid3_interval);      // Pi/3
  case 105: return OBJ_INTERVAL(cxsc::Pid4_interval);      // Pi/4
  case 106: return OBJ_INTERVAL(cxsc::Pir_interval);       // 1/Pi
  case 107: return OBJ_INTERVAL(cxsc::Pi2r_interval);      // 1/(2*Pi)
  case 108: return OBJ_INTERVAL(cxsc::Pip2_interval);      // Pi^2
  case 109: return OBJ_INTERVAL(cxsc::SqrtPi_interval);    // sqrt(Pi)
  case 110: return OBJ_INTERVAL(cxsc::Sqrt2Pi_interval);   // sqrt(2Pi)
  case 111: return OBJ_INTERVAL(cxsc::SqrtPir_interval);   // 1/sqrt(Pi)
  case 112: return OBJ_INTERVAL(cxsc::Sqrt2Pir_interval);  // 1/sqrt(2Pi)
  case 113: return OBJ_INTERVAL(cxsc::Sqrt2_interval);     // sqrt(2)
  case 114: return OBJ_INTERVAL(cxsc::Sqrt2r_interval);    // 1/sqrt(2)
  case 115: return OBJ_INTERVAL(cxsc::Sqrt3_interval);     // sqrt(3)
  case 116: return OBJ_INTERVAL(cxsc::Sqrt3d2_interval);   // sqrt(3)/2
  case 117: return OBJ_INTERVAL(cxsc::Sqrt3r_interval);    // 1/sqrt(3)
  case 118: return OBJ_INTERVAL(cxsc::Ln2_interval);       // ln(2)
  case 119: return OBJ_INTERVAL(cxsc::Ln2r_interval);      // 1/ln(2)
  case 120: return OBJ_INTERVAL(cxsc::Ln10_interval);      // ln(10)
  case 121: return OBJ_INTERVAL(cxsc::Ln10r_interval);     // 1/ln(10)
  case 122: return OBJ_INTERVAL(cxsc::LnPi_interval);      // ln(Pi)
  case 123: return OBJ_INTERVAL(cxsc::Ln2Pi_interval);     // ln(2Pi)
  case 124: return OBJ_INTERVAL(cxsc::E_interval);         // e
  case 125: return OBJ_INTERVAL(cxsc::Er_interval);        // 1/e
  case 126: return OBJ_INTERVAL(cxsc::Ep2_interval);       // e^2
  case 127: return OBJ_INTERVAL(cxsc::Ep2r_interval);      // 1/e^2
  case 128: return OBJ_INTERVAL(cxsc::EpPi_interval);      // e^(Pi)
  case 129: return OBJ_INTERVAL(cxsc::Ep2Pi_interval);     // e^(2Pi)
  case 130: return OBJ_INTERVAL(cxsc::EpPid2_interval);    // e^(Pi/2)
  case 131: return OBJ_INTERVAL(cxsc::EpPid4_interval);    // e^(Pi/4)
  }
  return Fail;
}

static Obj INT_CXSC (Obj self, Obj f)
{
  TEST_IS_REAL("INT_CXSC",f);
  int n = 0;
  bool sign = false;
  cxsc::real r = REAL_OBJ(f);
  if (r < 0.0)
    r = -r, sign = true;
  for (int i = 1 << NR_SMALL_INT_BITS; i; i >>= 1)
    if (r >= i)
      r = r-i, n = n+i;
  if (r >= 1.0)
    return Fail;
  else
    return INTOBJ_INT(n);
}

static Obj STRING_CXSC (Obj self, Obj f, Obj precision, Obj digits)
{
  std::string s;
  TEST_IS_INTOBJ("STRING_CXSC",precision);
  TEST_IS_INTOBJ("STRING_CXSC",digits);
  s << SetPrecision(INT_INTOBJ(precision),INT_INTOBJ(digits)) << Variable;

  if (IS_REAL(f))
    s << REAL_OBJ(f);
  else if (IS_COMPLEX(f))
    s << COMPLEX_OBJ(f);
  else if (IS_INTERVAL(f))
    s << INTERVAL_OBJ(f);
  else if (IS_CINTERVAL(f))
    s << CINTERVAL_OBJ(f);
  else ERROR_CXSC(STRING_CXSC,f);

  Obj str = NEW_STRING(s.length());
  s.copy (CSTR_STRING(str), s.length());

  return str;
}

static Obj REAL_CXSC (Obj self, Obj f)
{
  if (IS_COMPLEX(f))
    return OBJ_REAL(Re(COMPLEX_OBJ(f)));
  else if (IS_CINTERVAL(f))
    return OBJ_INTERVAL(Im(CINTERVAL_OBJ(f)));
  else RETURNERROR_CXSC(REAL_CXSC,f);
}

static Obj IMAG_CXSC (Obj self, Obj f)
{
  if (IS_COMPLEX(f))
    return OBJ_REAL(Im(COMPLEX_OBJ(f)));
  else if (IS_CINTERVAL(f))
    return OBJ_INTERVAL(Im(CINTERVAL_OBJ(f)));
  else RETURNERROR_CXSC(IMAG_CXSC,f);
}

cxsc::interval abs2(const cinterval& x)
{
  interval a=cxsc::abs(Re(x)), b=cxsc::abs(Im(x)), r;
  int exa=cxsc::expo(Sup(a)), exb=cxsc::expo(Sup(b)), ex;
    if (exb > exa)
    {  // Permutation of a,b:
        r = a;  a = b;  b = r;
        ex = exa;  exa = exb;  exb = ex;
    }
    ex = 511 - exa;
    cxsc::times2pown(a,ex);
    cxsc::times2pown(b,ex);
    r = a*a + b*b;
    times2pown(r,-ex);
    return r;
}

static Obj NORM_CXSC (Obj self, Obj f)
{
  if (IS_COMPLEX(f))
    return OBJ_REAL(abs2(COMPLEX_OBJ(f)));
  else if (IS_CINTERVAL(f))
    return OBJ_INTERVAL(abs2(CINTERVAL_OBJ(f)));
  else RETURNERROR_CXSC(IMAG_CXSC,f);
}

static Obj CONJ_CXSC (Obj self, Obj f)
{
  if (IS_COMPLEX(f))
    return OBJ_COMPLEX(conj(COMPLEX_OBJ(f)));
  else if (IS_CINTERVAL(f))
    return OBJ_CINTERVAL(conj(CINTERVAL_OBJ(f)));
  else RETURNERROR_CXSC(CONJ_CXSC,f);
}

static Obj INF_CXSC (Obj self, Obj f)
{
  if (IS_INTERVAL(f))
    return OBJ_REAL(Inf(INTERVAL_OBJ(f)));
  else if (IS_CINTERVAL(f))
    return OBJ_COMPLEX(Inf(CINTERVAL_OBJ(f)));
  else RETURNERROR_CXSC(INF_CXSC,f);
}

static Obj SUP_CXSC (Obj self, Obj f)
{
  if (IS_INTERVAL(f))
    return OBJ_REAL(Sup(INTERVAL_OBJ(f)));
  else if (IS_CINTERVAL(f))
    return OBJ_COMPLEX(Sup(CINTERVAL_OBJ(f)));
  else RETURNERROR_CXSC(SUP_CXSC,f);
}

static Obj ISEMPTY_CXSC (Obj self, Obj f)
{
  if (IS_INTERVAL(f))
    return IsEmpty(INTERVAL_OBJ(f)) ? True : False;
  else if (IS_CINTERVAL(f))
    return IsEmpty(Re(CINTERVAL_OBJ(f))) || IsEmpty(Im(CINTERVAL_OBJ(f))) ? True : False;
  else RETURNERROR_CXSC(ISEMPTY_CXSC,f);
}

static Obj MID_CXSC (Obj self, Obj f)
{
  if (IS_INTERVAL(f))
    return OBJ_REAL(mid(INTERVAL_OBJ(f)));
  else if (IS_CINTERVAL(f))
    return OBJ_COMPLEX(mid(CINTERVAL_OBJ(f)));
  else RETURNERROR_CXSC(MID_CXSC,f);
}

static Obj DIAM_CXSC (Obj self, Obj f)
{
  if (IS_INTERVAL(f))
    return OBJ_REAL(diam(INTERVAL_OBJ(f)));
  else if (IS_CINTERVAL(f))
    return OBJ_COMPLEX(diam(CINTERVAL_OBJ(f)));
  else RETURNERROR_CXSC(DIAM_CXSC,f);
}

static Obj CXSC_R_STRING (Obj self, Obj str)
{
  TEST_IS_STRING("CXSC_R_STRING",str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_REAL();
  s >> REAL_OBJ(f);
  return f;
}

static Obj CXSC_C_STRING (Obj self, Obj str)
{
  TEST_IS_STRING("CXSC_C_STRING",str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_COMPLEX();
  s >> COMPLEX_OBJ(f);
  return f;
}

static Obj CXSC_I_STRING (Obj self, Obj str)
{
  TEST_IS_STRING("CXSC_I_STRING",str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_INTERVAL();
  s >> INTERVAL_OBJ(f);
  return f;
}

static Obj CXSC_D_STRING (Obj self, Obj str)
{
  TEST_IS_STRING("CXSC_D_STRING",str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_CINTERVAL();
  s >> CINTERVAL_OBJ(f);
  return f;
}

Func1_CXSC(INV_CXSC,1.0 /);
Func1_CXSC(AINV_CXSC,-);
Func1_CXSC(COS_CXSC,cxsc::cos);
Func1_CXSC(SIN_CXSC,cxsc::sin);
Func1_CXSC(TAN_CXSC,cxsc::tan);
Func1_CXSC(COT_CXSC,cxsc::cot);
Func1_CXSC(COSH_CXSC,cxsc::cosh);
Func1_CXSC(SINH_CXSC,cxsc::sinh);
Func1_CXSC(TANH_CXSC,cxsc::tanh);
Func1_CXSC(COTH_CXSC,cxsc::coth);
Func1_CXSC(ACOS_CXSC,cxsc::acos);
Func1_CXSC(ASIN_CXSC,cxsc::asin);
Func1_CXSC(ATAN_CXSC,cxsc::atan);
Func1_CXSC(ACOT_CXSC,cxsc::acot);
Func1_CXSC(ACOSH_CXSC,cxsc::acosh);
Func1_CXSC(ASINH_CXSC,cxsc::asinh);
Func1_CXSC(ATANH_CXSC,cxsc::atanh);
Func1_CXSC(ACOTH_CXSC,cxsc::acoth);
Func1_CXSC(SQR_CXSC,cxsc::sqr);
Func1_CXSC(SQRT_CXSC,cxsc::sqrt);
Func1_CXSC(EXP_CXSC,cxsc::exp);
Func1_CXSC(LOG_CXSC,cxsc::ln);

cxsc::real abs(const complex& x) // why the %^(&^*( does the library not contain it?
{
  return sqrtx2y2(Re(x),Im(x));
}

static Obj ABS_CXSC_R (Obj self, Obj f)
{
  TEST_IS_REAL("ABS_CXSC",f);
  return OBJ_REAL(cxsc::abs(REAL_OBJ(f)));
}
static Obj ABS_CXSC_C (Obj self, Obj f)
{
  TEST_IS_COMPLEX("ABS_CXSC",f);
  return OBJ_REAL(::abs(COMPLEX_OBJ(f)));
}
static Obj ABS_CXSC_I (Obj self, Obj f)
{
  TEST_IS_INTERVAL("ABS_CXSC",f);
  return OBJ_INTERVAL(cxsc::abs(INTERVAL_OBJ(f)));
}
static Obj ABS_CXSC_D (Obj self, Obj f)
{
  TEST_IS_CINTERVAL("ABS_CXSC",f);
  return OBJ_INTERVAL(cxsc::abs(CINTERVAL_OBJ(f)));
}

static Obj ROOTPOLY_CXSC(Obj self, Obj coeffs, Obj intervals)
{
  Obj result, heap;
  int degree, numroots;
#define opr ((double *)ADDR_OBJ(heap))
#define opi (opr+degree+1)
#define zeror (opr+2*degree+2)
#define zeroi (opr+3*degree+2)
#define cpolyheap (opr+4*degree+2)

  degree = LEN_PLIST(coeffs)-1;

  heap = NewBag(T_DATOBJ, (14*degree+12)*sizeof(double));

  for (int i = 0; i <= degree; i++) {
    Obj c = ELM_PLIST(coeffs,i+1);
    cxsc::complex z;
    if (IS_REAL(c))
      z = REAL_OBJ(c);
    else if (IS_COMPLEX(c))
      z = COMPLEX_OBJ(c);
    else if (IS_INTERVAL(c))
      z = cxsc::mid(INTERVAL_OBJ(c));
    else if (IS_CINTERVAL(c))
      z = cxsc::mid(CINTERVAL_OBJ(c));
    else ERROR_CXSC(ROOTPOLY_CXSC,c);

    opr[degree-i] = _double(Re(z));
    opi[degree-i] = _double(Im(z));
  }
  
  numroots = cpoly (opr, opi, degree, zeror, zeroi, cpolyheap);

  if (numroots == -1)
    return Fail;

  result = NEW_PLIST(T_PLIST, numroots);
  SET_LEN_PLIST(result, numroots);
  if (intervals != True) {
    for (int i = 1; i <= numroots; i++)
      SET_ELM_PLIST(result,i,OBJ_COMPLEX(cxsc::complex(zeror[i-1],zeroi[i-1])));
  } else {
    CPolynomial op(degree);
    for (int i = 0; i <= degree; i++)
      op[degree-i] = cxsc::complex(opr[i],opi[i]);
    for (int i = 1; i <= numroots; i++) {
      cxsc::cinterval z;
      CIPolynomial rp(degree);
      int error;
      CPolyZero(op,cxsc::complex(zeror[i-1],zeroi[i-1]),rp,z,error);
      SET_ELM_PLIST(result,i,OBJ_CINTERVAL(z));
    }
  }
  return result;
}

/****************************************************************
 * 2-argument functions
 ****************************************************************/
#define Inc2_CXSC_arg(name,arg)					\
  { #name, 2, arg, (ObjFunc) name, "src/cxsc_float.c:" #name }

#define Inc2_CXSC_X(name,argf)			\
  Inc2_CXSC_arg(name##_R,argf ", real"),	\
    Inc2_CXSC_arg(name##_C,argf ", complex"),	\
    Inc2_CXSC_arg(name##_I,argf ", interval"),	\
    Inc2_CXSC_arg(name##_D,argf ", cinterval")

#define Inc2_CXSC(name)					\
  Inc2_CXSC_X(name##_R,"real"),				\
    Inc2_CXSC_X(name##_C,"complex"),			\
    Inc2_CXSC_X(name##_I,"interval"),			\
    Inc2_CXSC_X(name##_D,"cinterval")

#define Func2_CXSC_X_X(gap_name,c,i,getf,getg,oper)	\
  static Obj gap_name(Obj self, Obj f, Obj g)		\
  {							\
    return OBJ_##c##i(oper(getf(f),getg(g)));		\
  }

#define Func2_CXSC_X(gap_name,c,i,get,oper)			\
  Func2_CXSC_X_X(gap_name##_R,c,i,get,REAL_OBJ,oper);		\
  Func2_CXSC_X_X(gap_name##_C,C,i,get,COMPLEX_OBJ,oper);	\
  Func2_CXSC_X_X(gap_name##_I,c,I,get,INTERVAL_OBJ,oper);	\
  Func2_CXSC_X_X(gap_name##_D,C,I,get,CINTERVAL_OBJ,oper);	\

#define Func2_CXSC(gap_name,oper)			\
  Func2_CXSC_X(gap_name##_R,R,P,REAL_OBJ,oper);		\
  Func2_CXSC_X(gap_name##_C,C,P,COMPLEX_OBJ,oper);	\
  Func2_CXSC_X(gap_name##_I,R,I,INTERVAL_OBJ,oper);	\
  Func2_CXSC_X(gap_name##_D,C,I,CINTERVAL_OBJ,oper);

cxsc::complex pow(cxsc::real &a, cxsc::complex &b) { return pow(a,b); }
cxsc::interval pow(cxsc::real &a, cxsc::interval &b) { return pow(a,b); }
cxsc::cinterval pow(cxsc::real &a, cxsc::cinterval &b) { return pow(a,b); }
cxsc::cinterval pow(cxsc::complex &a, cxsc::interval &b) { return pow(a,b); }
cxsc::cinterval pow(cxsc::complex &a, cxsc::cinterval &b) { return pow(a,b); }
cxsc::interval pow(cxsc::interval &a, cxsc::real &b) { return pow(a,b); }
cxsc::cinterval pow(cxsc::interval &a, cxsc::complex &b) { return pow(a,b); }
cxsc::cinterval pow(cxsc::interval &a, cxsc::cinterval &b) { return pow(a,b); }
cxsc::cinterval pow(cxsc::cinterval &a, cxsc::real &b) { return pow(a,b); }
cxsc::cinterval pow(cxsc::cinterval &a, cxsc::complex &b) { return pow(a,b); }

Func2_CXSC(SUM_CXSC,operator +);
Func2_CXSC(DIFF_CXSC,operator -);
Func2_CXSC(PROD_CXSC,operator *);
Func2_CXSC(QUO_CXSC,operator /);
Func2_CXSC(POW_CXSC,pow);

#define Func2a_CXSC_X_X(gap_name,c,i,getf,getg,oper)		\
  static Obj gap_name(Obj self, Obj f, Obj g)			\
  {								\
    return OBJ_##c##I(oper(getf(f),getg(g)));			\
  }

#define Func2a_CXSC_X(gap_name,c,i,get,oper)			\
  Func2a_CXSC_X_X(gap_name##_R,c,i,get,REAL_OBJ,oper);		\
  Func2a_CXSC_X_X(gap_name##_C,C,i,get,COMPLEX_OBJ,oper);	\
  Func2a_CXSC_X_X(gap_name##_I,c,I,get,INTERVAL_OBJ,oper);	\
  Func2a_CXSC_X_X(gap_name##_D,C,I,get,CINTERVAL_OBJ,oper);	\

#define Func2a_CXSC(gap_name,oper)			\
  Func2a_CXSC_X(gap_name##_R,R,P,REAL_OBJ,oper);		\
  Func2a_CXSC_X(gap_name##_C,C,P,COMPLEX_OBJ,oper);	\
  Func2a_CXSC_X(gap_name##_I,R,I,INTERVAL_OBJ,oper);	\
  Func2a_CXSC_X(gap_name##_D,C,I,CINTERVAL_OBJ,oper);

cxsc::interval operator &(cxsc::real &a, cxsc::real &b) {
  return cxsc::interval(cxsc::QuietNaN); }
cxsc::cinterval operator &(cxsc::real &a, cxsc::complex &b) {
  return cxsc::cinterval(cxsc::QuietNaN); }
cxsc::cinterval operator &(cxsc::complex &a, cxsc::real &b) {
  return cxsc::cinterval(cxsc::QuietNaN); }
cxsc::cinterval operator &(cxsc::complex &a, cxsc::complex &b) {
  return cxsc::cinterval(cxsc::QuietNaN); }

Func2a_CXSC(OR_CXSC,operator |);
Func2a_CXSC(AND_CXSC,operator &);

#define Func2b_CXSC_X_X(gap_name,c,i,getf,getg,oper)		\
  static Obj gap_name(Obj self, Obj f, Obj g)			\
  {								\
    return getf(f) oper getg(g) ? True : False;			\
  }

#define Func2b_CXSC_X(gap_name,c,i,get,oper)			\
  Func2b_CXSC_X_X(gap_name##_R,c,i,get,REAL_OBJ,oper);		\
  Func2b_CXSC_X_X(gap_name##_C,C,i,get,COMPLEX_OBJ,oper);	\
  Func2b_CXSC_X_X(gap_name##_I,c,I,get,INTERVAL_OBJ,oper);	\
  Func2b_CXSC_X_X(gap_name##_D,C,I,get,CINTERVAL_OBJ,oper);	\

#define Func2b_CXSC(gap_name,oper)			\
  Func2b_CXSC_X(gap_name##_R,R,P,REAL_OBJ,oper);		\
  Func2b_CXSC_X(gap_name##_C,C,P,COMPLEX_OBJ,oper);	\
  Func2b_CXSC_X(gap_name##_I,R,I,INTERVAL_OBJ,oper);	\
  Func2b_CXSC_X(gap_name##_D,C,I,CINTERVAL_OBJ,oper);

bool operator == (cxsc::complex &a, cxsc::interval &b) {
  return cxsc::cinterval(a) == cxsc::cinterval(b); }
bool operator == (cxsc::interval &a, cxsc::complex &b) {
  return cxsc::cinterval(a) == cxsc::cinterval(b); }
bool operator < (cxsc::complex &a, cxsc::real &b) { return false; }
bool operator < (cxsc::complex &a, cxsc::complex &b) { return false; }
bool operator < (cxsc::real &a, cxsc::complex &b) { return false; }
bool operator < (cxsc::interval &a, cxsc::complex &b) { return false; }
bool operator < (cxsc::complex &a, cxsc::interval &b) { return false; }

Func2b_CXSC(EQ_CXSC,==);
Func2b_CXSC(LT_CXSC,<);

static Obj POWER_CXSC_R (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ("POWER_CXSC_R",g);
  TEST_IS_REAL("POWER_CXSC_R",f);
  return OBJ_REAL(power(REAL_OBJ(f), INT_INTOBJ(g)));
}

static Obj POWER_CXSC_C (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ("POWER_CXSC_C",g);
  TEST_IS_COMPLEX("POWER_CXSC_C",f);
  return OBJ_COMPLEX(power(COMPLEX_OBJ(f), INT_INTOBJ(g)));
}

static Obj POWER_CXSC_I (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ("POWER_CXSC_I",g);
  TEST_IS_INTERVAL("POWER_CXSC_I",f);
  return OBJ_INTERVAL(power(INTERVAL_OBJ(f), INT_INTOBJ(g)));
}

static Obj POWER_CXSC_D (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ("POWER_CXSC_D",g);
  TEST_IS_CINTERVAL("POWER_CXSC_D",f);
  return OBJ_CINTERVAL(power(CINTERVAL_OBJ(f), INT_INTOBJ(g)));
}

static Obj ROOT_CXSC_R (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ("ROOT_CXSC_R",g);
  TEST_IS_REAL("ROOT_CXSC_R",f);
  return OBJ_REAL(sqrt(REAL_OBJ(f), INT_INTOBJ(g)));
}

static Obj ROOT_CXSC_C (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ("ROOT_CXSC_C",g);
  TEST_IS_COMPLEX("ROOT_CXSC_C",f);
  return OBJ_COMPLEX(sqrt(COMPLEX_OBJ(f), INT_INTOBJ(g)));
}

static Obj ROOT_CXSC_I (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ("ROOT_CXSC_I",g);
  TEST_IS_INTERVAL("ROOT_CXSC_I",f);
  return OBJ_INTERVAL(sqrt(INTERVAL_OBJ(f), INT_INTOBJ(g)));
}

static Obj ROOT_CXSC_D (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ("ROOT_CXSC_D",g);
  TEST_IS_CINTERVAL("ROOT_CXSC_D",f);
  return OBJ_CINTERVAL(sqrt(CINTERVAL_OBJ(f), INT_INTOBJ(g)));
}

static Obj BLOW_CXSC_I (Obj self, Obj f, Obj g)
{
  TEST_IS_REAL("BLOW_CXSC_I",g);
  TEST_IS_INTERVAL("BLOW_CXSC_I",f);
  return OBJ_INTERVAL(Blow(INTERVAL_OBJ(f), REAL_OBJ(g)));
}

static Obj BLOW_CXSC_D (Obj self, Obj f, Obj g)
{
  TEST_IS_REAL("BLOW_CXSC_D",g);
  TEST_IS_CINTERVAL("BLOW_CXSC_D",f);
  return OBJ_CINTERVAL(Blow(CINTERVAL_OBJ(f), REAL_OBJ(g)));
}

static Obj DISJOINT_CXSC_II (Obj self, Obj f, Obj g)
{
  TEST_IS_INTERVAL("DISJOINT_CXSC",f);
  TEST_IS_INTERVAL("DISJOINT_CXSC",g);
  return Disjoint(INTERVAL_OBJ(f),INTERVAL_OBJ(g)) ? True : False;
}

bool Disjoint(cxsc::cinterval &a, cxsc::cinterval &b) {
  return Disjoint(Re(a),Re(b)) || Disjoint(Im(a),Im(b)); }

static Obj DISJOINT_CXSC_DD (Obj self, Obj f, Obj g)
{
  TEST_IS_CINTERVAL("DISJOINT_CXSC",f);
  TEST_IS_CINTERVAL("DISJOINT_CXSC",g);
  return Disjoint(CINTERVAL_OBJ(f),CINTERVAL_OBJ(g)) ? True : False;
}

static Obj IN_CXSC_R_I (Obj self, Obj f, Obj g)
{
  TEST_IS_REAL("IN_CXSC_R_I",f);
  TEST_IS_INTERVAL("IN_CXSC_R_I",g);
  return in(REAL_OBJ(f),INTERVAL_OBJ(g)) ? True : False;
}

static Obj IN_CXSC_I_I (Obj self, Obj f, Obj g)
{
  TEST_IS_INTERVAL("IN_CXSC_I_I",f);
  TEST_IS_INTERVAL("IN_CXSC_I_I",g);
  return in(INTERVAL_OBJ(f),INTERVAL_OBJ(g)) ? True : False;
}

bool in (cxsc::complex &a, cxsc::cinterval &b) {
  return in(Re(a),Re(b)) && in(Im(a),Im(b));
}

static Obj IN_CXSC_C_D (Obj self, Obj f, Obj g)
{
  TEST_IS_COMPLEX("IN_CXSC_C_D",f);
  TEST_IS_CINTERVAL("IN_CXSC_C_D",g);
  return in(COMPLEX_OBJ(f),CINTERVAL_OBJ(g)) ? True : False;
}

static Obj IN_CXSC_D_D (Obj self, Obj f, Obj g)
{
  TEST_IS_CINTERVAL("IN_CXSC_D_D",f);
  TEST_IS_CINTERVAL("IN_CXSC_D_D",g);
  return in(CINTERVAL_OBJ(f),CINTERVAL_OBJ(g)) ? True : False;
}

static Obj ATAN2_CXSC (Obj self, Obj f, Obj g)
{
  TEST_IS_REAL("ATAN2_CXSC",f);
  TEST_IS_REAL("ATAN2_CXSC",g);
  return OBJ_REAL(std::atan2(_double(REAL_OBJ(f)),_double(REAL_OBJ(g))));
}

/****************************************************************
 * export functions
 ****************************************************************/
static StructGVarFunc GVarFuncs [] = {  
  Inc1_CXSC_arg(CXSC_INT,"int"),
  Inc1_CXSC_arg(CXSC_NEWCONSTANT,"int"),
  Inc1_CXSC_arg(CXSC_R_STRING,"string"),
  Inc1_CXSC_arg(REAL_CXSC,"complex"),
  Inc1_CXSC_arg(IMAG_CXSC,"complex"),
  Inc1_CXSC_arg(NORM_CXSC,"complex"),
  Inc1_CXSC_arg(CONJ_CXSC,"complex"),
  Inc1_CXSC_arg(INF_CXSC,"interval"),
  Inc1_CXSC_arg(SUP_CXSC,"interval"),
  Inc1_CXSC_arg(CXSC_I_STRING,"string"),
  Inc1_CXSC_arg(CXSC_I_R,"real"),
  Inc2_CXSC_arg(CXSC_I_RR,"real, real"),
  Inc1_CXSC_arg(CXSC_C_STRING,"string"),
  Inc2_CXSC_arg(CXSC_C_RR,"real, real"),
  Inc1_CXSC_arg(CXSC_D_STRING,"string"),
  Inc2_CXSC_arg(CXSC_D_II,"interval, interval"),
  Inc1_CXSC_arg(CXSC_D_C,"complex"),
  Inc1_CXSC_arg(INT_CXSC,"real"),
  Inc1_CXSC_arg(DIAM_CXSC,"interval"),
  Inc1_CXSC_arg(ISEMPTY_CXSC,"interval"),
  Inc1_CXSC_arg(MID_CXSC,"interval"),

  Inc1_CXSC(AINV_CXSC),
  Inc1_CXSC(INV_CXSC),
  Inc1_CXSC(SIN_CXSC),
  Inc1_CXSC(COS_CXSC),
  Inc1_CXSC(TAN_CXSC),
  Inc1_CXSC(COT_CXSC),
  Inc1_CXSC(SINH_CXSC),
  Inc1_CXSC(COSH_CXSC),
  Inc1_CXSC(TANH_CXSC),
  Inc1_CXSC(COTH_CXSC),
  Inc1_CXSC(ASIN_CXSC),
  Inc1_CXSC(ACOS_CXSC),
  Inc1_CXSC(ATAN_CXSC),
  Inc1_CXSC(ACOT_CXSC),
  Inc1_CXSC(ASINH_CXSC),
  Inc1_CXSC(ACOSH_CXSC),
  Inc1_CXSC(ATANH_CXSC),
  Inc1_CXSC(ACOTH_CXSC),
  Inc1_CXSC(SQR_CXSC),
  Inc1_CXSC(SQRT_CXSC),
  Inc1_CXSC(EXP_CXSC),
  Inc1_CXSC(LOG_CXSC),
  Inc1_CXSC(ABS_CXSC),

  Inc2_CXSC(SUM_CXSC),
  Inc2_CXSC(DIFF_CXSC),
  Inc2_CXSC(PROD_CXSC),
  Inc2_CXSC(QUO_CXSC),
  Inc2_CXSC(POW_CXSC),
  Inc2_CXSC(OR_CXSC),
  Inc2_CXSC(AND_CXSC),
  Inc2_CXSC(EQ_CXSC),
  Inc2_CXSC(LT_CXSC),
  Inc2_CXSC_arg(ATAN2_CXSC,"real,real"),
  Inc2_CXSC_arg(POWER_CXSC_R,"cxsc,int"),
  Inc2_CXSC_arg(POWER_CXSC_C,"cxsc,int"),
  Inc2_CXSC_arg(POWER_CXSC_I,"cxsc,int"),
  Inc2_CXSC_arg(POWER_CXSC_D,"cxsc,int"),
  Inc2_CXSC_arg(ROOT_CXSC_R,"cxsc,int"),
  Inc2_CXSC_arg(ROOT_CXSC_C,"cxsc,int"),
  Inc2_CXSC_arg(ROOT_CXSC_I,"cxsc,int"),
  Inc2_CXSC_arg(ROOT_CXSC_D,"cxsc,int"),
  Inc2_CXSC_arg(BLOW_CXSC_I,"cxsc,real"),
  Inc2_CXSC_arg(BLOW_CXSC_D,"cxsc,real"),
  Inc2_CXSC_arg(DISJOINT_CXSC_II,"interval,interval"),
  Inc2_CXSC_arg(DISJOINT_CXSC_DD,"cinterval,cinterval"),
  Inc2_CXSC_arg(IN_CXSC_R_I,"real,interval"),
  Inc2_CXSC_arg(IN_CXSC_I_I,"interval,interval"),
  Inc2_CXSC_arg(IN_CXSC_C_D,"complex,cinterval"),
  Inc2_CXSC_arg(IN_CXSC_D_D,"cinterval,cinterval"),
  Inc2_CXSC_arg(ROOTPOLY_CXSC,"cxsc_list,bool"),
  { "STRING_CXSC", 3, "cxsc,int,int", (ObjFunc) STRING_CXSC, "src/cxsc_float.c:STRING_CXSC" },
  {0}
};

void cxsc_unexpected (void)
{
  ErrorQuit("cxsc::unexpected: Nobody expects the Spanish Inquisition!", 0,0);
}

void cxsc_terminate (void)
{
  ErrorQuit("cxsc::terminate: I'll be back!", 0,0);
}

/****************************************************************
 * initialize package
 ****************************************************************/
static Int InitKernel (StructInitInfo *module)
{
  ImportGVarFromLibrary ("TYPE_CXSC_REAL", &TYPE_CXSC_REAL);
  ImportGVarFromLibrary ("TYPE_CXSC_COMPLEX", &TYPE_CXSC_COMPLEX);
  ImportGVarFromLibrary ("TYPE_CXSC_INTERVAL", &TYPE_CXSC_INTERVAL);
  ImportGVarFromLibrary ("TYPE_CXSC_CINTERVAL", &TYPE_CXSC_CINTERVAL);

  ImportGVarFromLibrary ("CXSCRealFamily", &FAMILY_CXSC_REAL);
  ImportGVarFromLibrary ("CXSCComplexFamily", &FAMILY_CXSC_COMPLEX);
  ImportGVarFromLibrary ("CXSCIntervalFamily", &FAMILY_CXSC_INTERVAL);
  ImportGVarFromLibrary ("CXSCCIntervalFamily", &FAMILY_CXSC_CINTERVAL);

  set_unexpected (cxsc_unexpected);
  set_terminate (cxsc_terminate);
  return 0;
}

static Int InitLibrary (StructInitInfo *module)
{
  InitGVarFuncsFromTable (GVarFuncs);
  return 0;
}

static StructInitInfo module = {
#ifdef FLOATSTATIC
  MODULE_STATIC,                        /* type                           */
#else
  MODULE_DYNAMIC,                       /* type                           */
#endif
    "cxsc_float",                       /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

extern "C" {
#ifdef FLOAT_STATIC
  StructInitInfo *Init__cxsc_float (void)
#else
  StructInitInfo *Init__Dynamic (void)
#endif
  {
    module.revision_c = Revision_cxsc_float_c;
    module.revision_h = Revision_cxsc_float_h;
    FillInVersion( &module );
    return &module;
  }
}

/****************************************************************************
**
*E  cxsc_float.c  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
