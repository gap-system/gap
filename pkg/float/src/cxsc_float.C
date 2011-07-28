/****************************************************************************
**
*W  cxsc_float.C                    GAP source              Laurent Bartholdi
**
*H  @(#)$Id: cxsc_float.C,v 1.2 2010/02/22 19:25:24 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file contains the main dll of the CXSC float package.
*/
static const char *Revision_cxsc_float_c =
   "@(#)$Id: cxsc_float.C,v 1.2 2010/02/22 19:25:24 gap Exp $";

#define BANNER_CXSC_FLOAT_H

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

Obj TYPE_CXSC_RP, TYPE_CXSC_CP, TYPE_CXSC_RI, TYPE_CXSC_CI;
Obj FAMILY_CXSC_RP, FAMILY_CXSC_CP, FAMILY_CXSC_RI, FAMILY_CXSC_CI;

/****************************************************************
 * creators
 ****************************************************************/
inline Obj NEW_RP (void)
{
  return NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::real));
}
inline Obj NEW_CP (void)
{
  return NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::complex));
}
inline Obj NEW_RI (void)
{
  return NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::interval));
}
inline Obj NEW_CI (void)
{
  return NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::cinterval));
}

inline Obj OBJ_RP (cxsc::real i)
{
  Obj f = NEW_RP();
  RP_OBJ(f) = i;
  SET_TYPE_DATOBJ(f, TYPE_CXSC_RP);
  return f;
}
inline Obj OBJ_CP (cxsc::complex i)
{
  Obj f = NEW_CP();
  CP_OBJ(f) = i;
  SET_TYPE_DATOBJ(f, TYPE_CXSC_CP);
  return f;
}
inline Obj OBJ_RI (cxsc::interval i)
{
  Obj f = NEW_RI();
  RI_OBJ(f) = i;
  SET_TYPE_DATOBJ(f, TYPE_CXSC_RI);
  return f;
}
inline Obj OBJ_CI (cxsc::cinterval i)
{
  Obj f = NEW_CI();
  CI_OBJ(f) = i;
  SET_TYPE_DATOBJ(f, TYPE_CXSC_CI);
  return f;
}
  
inline cxsc::real RP_GET(cxsc::real x) { return x; }
inline cxsc::complex CP_GET(cxsc::real x) { return _complex(x); }
inline cxsc::interval RI_GET(cxsc::real x) { return _interval(x); }
inline cxsc::cinterval CI_GET(cxsc::real x) { return _cinterval(x); }

/****************************************************************
 * 1-argument functions
 ****************************************************************/
#define Func1_CXSC(gap_name,cxsc_name)				\
  static Obj gap_name##_RP(Obj self, Obj f)			\
  {								\
    TEST_IS_RP(gap_name##_RP,f);				\
    if (IsQuietNaN(RP_OBJ(f))) { return f; }			\
    return OBJ_RP(cxsc_name(RP_OBJ(f)));			\
  }								\
  static Obj gap_name##_CP(Obj self, Obj f)			\
  {								\
    TEST_IS_CP(gap_name##_CP,f);				\
    if (IsQuietNaN(Re(CP_OBJ(f)))) { return f; }		\
    return OBJ_CP(cxsc_name(CP_OBJ(f)));			\
  }								\
  static Obj gap_name##_RI(Obj self, Obj f)			\
  {								\
    TEST_IS_RI(gap_name##_RI,f);				\
    if (IsQuietNaN(Inf(RI_OBJ(f)))) { return f; }		\
    return OBJ_RI(cxsc_name(RI_OBJ(f)));			\
  }								\
  static Obj gap_name##_CI(Obj self, Obj f)			\
  {								\
    TEST_IS_CI(gap_name##_CI,f);				\
    if (IsQuietNaN(Inf(Re(CI_OBJ(f))))) { return f; }		\
    return OBJ_CI(cxsc_name(CI_OBJ(f)));			\
  }

#define Func1a_CXSC(gap_name,result,cxsc_name)			\
  static Obj gap_name##_CP(Obj self, Obj f)			\
  {								\
    TEST_IS_CP(gap_name##_CP,f);				\
    if (IsQuietNaN(Re(CP_OBJ(f)))) { return f; }		\
    return OBJ_##result##P(cxsc_name(CP_OBJ(f)));		\
  }								\
  static Obj gap_name##_CI(Obj self, Obj f)			\
  {								\
    TEST_IS_CI(gap_name##_CI,f);				\
    if (IsQuietNaN(Inf(Re(CI_OBJ(f))))) { return f; }		\
    return OBJ_##result##I(cxsc_name(CI_OBJ(f)));		\
  }

#define Func1b_CXSC(gap_name,cxsc_name)				\
  static Obj gap_name##_RI(Obj self, Obj f)			\
  {								\
    TEST_IS_RI(gap_name##_RI,f);				\
    if (IsQuietNaN(Inf(RI_OBJ(f)))) { return f; }		\
    return OBJ_RP(cxsc_name(RI_OBJ(f)));			\
  }								\
  static Obj gap_name##_CI(Obj self, Obj f)			\
  {								\
    TEST_IS_CI(gap_name##_CI,f);				\
    if (IsQuietNaN(Inf(Re(CI_OBJ(f))))) { return f; }		\
    return OBJ_CP(cxsc_name(CI_OBJ(f)));			\
  }

typedef Obj (*ObjFunc)(); // I never could get the () and * right

#define Inc1_CXSC_arg(name,arg)					\
  { #name, 1, arg, (ObjFunc) name, "src/cxsc_float.c:" #name }
#define Inc1_CXSC(name)					\
  Inc1_CXSC_arg(name##_RP,"cxsc::rp"),			\
    Inc1_CXSC_arg(name##_CP,"cxsc::cp"),		\
    Inc1_CXSC_arg(name##_RI,"cxsc::ri"),		\
    Inc1_CXSC_arg(name##_CI,"cxsc::ci")
#define Inc1a_CXSC(name)				\
  Inc1_CXSC_arg(name##_CP,"cxsc::cp"),			\
    Inc1_CXSC_arg(name##_CI,"cxsc::ci")
#define Inc1b_CXSC(name)				\
    Inc1_CXSC_arg(name##_RI,"cxsc::ri"),		\
    Inc1_CXSC_arg(name##_CI,"cxsc::ci")

static Obj CXSC_INT (Obj self, Obj f)
{
  TEST_IS_INTOBJ(CXSC_INT,f);
  return OBJ_RP(INT_INTOBJ(f));
}

static Obj CP_CXSC_RP_RP (Obj self, Obj f, Obj g)
{
  TEST_IS_RP(CP_CXSC_RP_RP,f);
  TEST_IS_RP(CP_CXSC_RP_RP,g);
  return OBJ_CP(cxsc::complex(RP_OBJ(f),RP_OBJ(g)));
}
static Obj CP_CXSC_RP (Obj self, Obj f)
{
  TEST_IS_RP(CP_CXSC_RP,f);
  return OBJ_CP(cxsc::complex(RP_OBJ(f)));
}
static Obj RI_CXSC_RP (Obj self, Obj f)
{
  TEST_IS_RP(RI_CXSC_RP,f);
  return OBJ_RI(cxsc::interval(RP_OBJ(f)));
}
static Obj RI_CXSC_RP_RP (Obj self, Obj f, Obj g)
{
  TEST_IS_RP(RI_CXSC_RP_RP,f);
  TEST_IS_RP(RI_CXSC_RP_RP,g);
  return OBJ_RI(cxsc::interval(RP_OBJ(f),RP_OBJ(g)));
}
static Obj CI_CXSC_CP (Obj self, Obj f)
{
  TEST_IS_CP(CI_CXSC_CP,f);
  return OBJ_CI(cxsc::cinterval(CP_OBJ(f)));
}
static Obj CI_CXSC_RI_RI (Obj self, Obj f, Obj g)
{
  TEST_IS_RI(CI_CXSC_RI_RI,f);
  TEST_IS_RI(CI_CXSC_RI_RI,g);
  return OBJ_CI(cxsc::cinterval(RI_OBJ(f),RI_OBJ(g)));
}
static Obj CI_CXSC_CP_CP (Obj self, Obj f, Obj g)
{
  TEST_IS_CP(CI_CXSC_CP_CP,f);
  TEST_IS_CP(CI_CXSC_CP_CP,g);
  return OBJ_CI(cxsc::cinterval(CP_OBJ(f),CP_OBJ(g)));
}

static Obj CXSC_NEWCONSTANT (Obj self, Obj f)
{
  TEST_IS_INTOBJ(CXSC_NEWCONSTANT,f);
  switch (INT_INTOBJ(f)) {
  case 0: return OBJ_RP(cxsc::MinReal);
  case 1: return OBJ_RP(cxsc::minreal);
  case 2: return OBJ_RP(cxsc::MaxReal);
  case 3: return OBJ_RP(cxsc::Infinity);
  case 4: return OBJ_RP(cxsc::SignalingNaN);
  case 5: return OBJ_RP(cxsc::QuietNaN);
  case 6: return OBJ_RP(cxsc::Pi_real);        // Pi
  case 7: return OBJ_RP(cxsc::Pi2_real);       // 2*Pi
  case 8: return OBJ_RP(cxsc::Pi3_real);       // 3*Pi
  case 9: return OBJ_RP(cxsc::Pid2_real);      // Pi/2
  case 10: return OBJ_RP(cxsc::Pid3_real);      // Pi/3
  case 11: return OBJ_RP(cxsc::Pid4_real);      // Pi/4
  case 12: return OBJ_RP(cxsc::Pir_real);       // 1/Pi
  case 13: return OBJ_RP(cxsc::Pi2r_real);      // 1/(2*Pi)
  case 14: return OBJ_RP(cxsc::Pip2_real);      // Pi^2
  case 15: return OBJ_RP(cxsc::SqrtPi_real);    // sqrt(Pi)
  case 16: return OBJ_RP(cxsc::Sqrt2Pi_real);   // sqrt(2Pi)
  case 17: return OBJ_RP(cxsc::SqrtPir_real);   // 1/sqrt(Pi)
  case 18: return OBJ_RP(cxsc::Sqrt2Pir_real);  // 1/sqrt(2Pi)
  case 19: return OBJ_RP(cxsc::Sqrt2_real);     // sqrt(2)
  case 20: return OBJ_RP(cxsc::Sqrt2r_real);    // 1/sqrt(2)
  case 21: return OBJ_RP(cxsc::Sqrt3_real);     // sqrt(3)
  case 22: return OBJ_RP(cxsc::Sqrt3d2_real);   // sqrt(3)/2
  case 23: return OBJ_RP(cxsc::Sqrt3r_real);    // 1/sqrt(3)
  case 24: return OBJ_RP(cxsc::Ln2_real);       // ln(2)
  case 25: return OBJ_RP(cxsc::Ln2r_real);      // 1/ln(2)
  case 26: return OBJ_RP(cxsc::Ln10_real);      // ln(10)
  case 27: return OBJ_RP(cxsc::Ln10r_real);     // 1/ln(10)
  case 28: return OBJ_RP(cxsc::LnPi_real);      // ln(Pi)
  case 29: return OBJ_RP(cxsc::Ln2Pi_real);     // ln(2Pi)
  case 30: return OBJ_RP(cxsc::E_real);         // e
  case 31: return OBJ_RP(cxsc::Er_real);        // 1/e
  case 32: return OBJ_RP(cxsc::Ep2_real);       // e^2
  case 33: return OBJ_RP(cxsc::Ep2r_real);      // 1/e^2
  case 34: return OBJ_RP(cxsc::EpPi_real);      // e^(Pi)
  case 35: return OBJ_RP(cxsc::Ep2Pi_real);     // e^(2Pi)
  case 36: return OBJ_RP(cxsc::EpPid2_real);    // e^(Pi/2)
  case 37: return OBJ_RP(cxsc::EpPid4_real);    // e^(Pi/4)

  case 100: return OBJ_RI(cxsc::Pi_interval);        // Pi
  case 101: return OBJ_RI(cxsc::Pi2_interval);       // 2*Pi
  case 102: return OBJ_RI(cxsc::Pi3_interval);       // 3*Pi
  case 103: return OBJ_RI(cxsc::Pid2_interval);      // Pi/2
  case 104: return OBJ_RI(cxsc::Pid3_interval);      // Pi/3
  case 105: return OBJ_RI(cxsc::Pid4_interval);      // Pi/4
  case 106: return OBJ_RI(cxsc::Pir_interval);       // 1/Pi
  case 107: return OBJ_RI(cxsc::Pi2r_interval);      // 1/(2*Pi)
  case 108: return OBJ_RI(cxsc::Pip2_interval);      // Pi^2
  case 109: return OBJ_RI(cxsc::SqrtPi_interval);    // sqrt(Pi)
  case 110: return OBJ_RI(cxsc::Sqrt2Pi_interval);   // sqrt(2Pi)
  case 111: return OBJ_RI(cxsc::SqrtPir_interval);   // 1/sqrt(Pi)
  case 112: return OBJ_RI(cxsc::Sqrt2Pir_interval);  // 1/sqrt(2Pi)
  case 113: return OBJ_RI(cxsc::Sqrt2_interval);     // sqrt(2)
  case 114: return OBJ_RI(cxsc::Sqrt2r_interval);    // 1/sqrt(2)
  case 115: return OBJ_RI(cxsc::Sqrt3_interval);     // sqrt(3)
  case 116: return OBJ_RI(cxsc::Sqrt3d2_interval);   // sqrt(3)/2
  case 117: return OBJ_RI(cxsc::Sqrt3r_interval);    // 1/sqrt(3)
  case 118: return OBJ_RI(cxsc::Ln2_interval);       // ln(2)
  case 119: return OBJ_RI(cxsc::Ln2r_interval);      // 1/ln(2)
  case 120: return OBJ_RI(cxsc::Ln10_interval);      // ln(10)
  case 121: return OBJ_RI(cxsc::Ln10r_interval);     // 1/ln(10)
  case 122: return OBJ_RI(cxsc::LnPi_interval);      // ln(Pi)
  case 123: return OBJ_RI(cxsc::Ln2Pi_interval);     // ln(2Pi)
  case 124: return OBJ_RI(cxsc::E_interval);         // e
  case 125: return OBJ_RI(cxsc::Er_interval);        // 1/e
  case 126: return OBJ_RI(cxsc::Ep2_interval);       // e^2
  case 127: return OBJ_RI(cxsc::Ep2r_interval);      // 1/e^2
  case 128: return OBJ_RI(cxsc::EpPi_interval);      // e^(Pi)
  case 129: return OBJ_RI(cxsc::Ep2Pi_interval);     // e^(2Pi)
  case 130: return OBJ_RI(cxsc::EpPid2_interval);    // e^(Pi/2)
  case 131: return OBJ_RI(cxsc::EpPid4_interval);    // e^(Pi/4)
  }
  return Fail;
}

static Obj INT_CXSC (Obj self, Obj f)
{
  TEST_IS_RP(INT_CXSC,f);
  int n = 0;
  int sign = 1;
  cxsc::real r = RP_OBJ(f);
  if (r < 0.0)
    r = -r, sign = -1;
  for (int i = 1 << NR_SMALL_INT_BITS; i; i >>= 1)
    if (r >= i)
      r = r-i, n = n+i;
  if (r >= 1.0)
    return Fail;
  else
    return INTOBJ_INT(sign*n);
}

static Obj STRING_CXSC (Obj self, Obj f, Obj precision, Obj digits)
{
  std::string s;
  TEST_IS_INTOBJ(STRING_CXSC,precision);
  TEST_IS_INTOBJ(STRING_CXSC,digits);
  s << SetPrecision(INT_INTOBJ(precision),INT_INTOBJ(digits)) << Variable;

  if (IS_RP(f))
    s << RP_OBJ(f);
  else if (IS_CP(f))
    s << CP_OBJ(f);
  else if (IS_RI(f))
    s << RI_OBJ(f);
  else if (IS_CI(f))
    s << CI_OBJ(f);
  else ERROR_CXSC(STRING_CXSC,f);

  Obj str = NEW_STRING(s.length());
  s.copy (CSTR_STRING(str), s.length());

  return str;
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

//cxsc::real abs(const complex& x) // why the %^(&^*( does the library not contain it?
//{
//  return sqrtx2y2(Re(x),Im(x));
//}

Func1a_CXSC(REAL_CXSC,R,Re);
Func1a_CXSC(IMAG_CXSC,R,Im);
Func1a_CXSC(ABS_CXSC,R,abs);
Func1a_CXSC(NORM_CXSC,R,abs2);
Func1a_CXSC(CONJ_CXSC,C,conj);

static Obj ISEMPTY_CXSC_RI (Obj self, Obj f)
{
  TEST_IS_RI(ISEMPTY_CXSC_RI,f);
  return IsEmpty(RI_OBJ(f)) ? True : False;
}

static Obj ISEMPTY_CXSC_CI (Obj self, Obj f)
{
  TEST_IS_CI(ISEMPTY_CXSC_RI,f);
  return IsEmpty(Re(CI_OBJ(f))) || IsEmpty(Im(CI_OBJ(f))) ? True : False;
}

Func1b_CXSC(INF_CXSC,Inf);
Func1b_CXSC(SUP_CXSC,Sup);
Func1b_CXSC(MID_CXSC,mid);
Func1b_CXSC(DIAM_CXSC,diam);

static Obj RP_CXSC_STRING (Obj self, Obj str)
{
  TEST_IS_STRING(RP_CXSC_STRING,str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_RP();
  s >> RP_OBJ(f);
  return f;
}

static Obj CP_CXSC_STRING (Obj self, Obj str)
{
  TEST_IS_STRING(CP_CXSC_STRING,str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_CP();
  s >> CP_OBJ(f);
  return f;
}

static Obj RI_CXSC_STRING (Obj self, Obj str)
{
  TEST_IS_STRING(RI_CXSC_STRING,str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_RI();
  s >> RI_OBJ(f);
  return f;
}

static Obj CI_CXSC_STRING (Obj self, Obj str)
{
  TEST_IS_STRING(CI_CXSC_STRING,str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_CI();
  s >> CI_OBJ(f);
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

static Obj ABS_CXSC_RP (Obj self, Obj f)
{
  TEST_IS_RP(ABS_CXSC_RP,f);
  return OBJ_RP(cxsc::abs(RP_OBJ(f)));
}
static Obj ABS_CXSC_RI (Obj self, Obj f)
{
  TEST_IS_RI(ABS_CXSC_RI,f);
  return OBJ_RI(cxsc::abs(RI_OBJ(f)));
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
    if (IS_RP(c))
      z = RP_OBJ(c);
    else if (IS_CP(c))
      z = CP_OBJ(c);
    else if (IS_RI(c))
      z = cxsc::mid(RI_OBJ(c));
    else if (IS_CI(c))
      z = cxsc::mid(CI_OBJ(c));
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
      SET_ELM_PLIST(result,i,OBJ_CP(cxsc::complex(zeror[i-1],zeroi[i-1])));
  } else {
    CPolynomial op(degree);
    for (int i = 0; i <= degree; i++)
      op[degree-i] = cxsc::complex(opr[i],opi[i]);
    for (int i = 1; i <= numroots; i++) {
      cxsc::cinterval z;
      CIPolynomial rp(degree);
      int error;
      CPolyZero(op,cxsc::complex(zeror[i-1],zeroi[i-1]),rp,z,error);
      SET_ELM_PLIST(result,i,OBJ_CI(z));
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
  Inc2_CXSC_arg(name##_RP,argf ",csxc::rp"),	\
    Inc2_CXSC_arg(name##_CP,argf ",cxsc::cp"),	\
    Inc2_CXSC_arg(name##_RI,argf ",cxsc::ri"),	\
    Inc2_CXSC_arg(name##_CI,argf ",cxsc::ci")

#define Inc2_CXSC(name)				\
  Inc2_CXSC_X(name##_RP,"cxsc::rp"),		\
    Inc2_CXSC_X(name##_CP,"cxsc::cp"),		\
    Inc2_CXSC_X(name##_RI,"cxsc::ri"),		\
    Inc2_CXSC_X(name##_CI,"cxsc::ci")

#define Func2_CXSC_X_X(gap_name,c,i,getf,getg,oper)	\
  static Obj gap_name(Obj self, Obj f, Obj g)		\
  {							\
    return OBJ_##c##i(oper(getf(f),getg(g)));		\
  }

#define Func2_CXSC_X(gap_name,c,i,get,oper)		\
  Func2_CXSC_X_X(gap_name##_RP,c,i,get,RP_OBJ,oper);	\
  Func2_CXSC_X_X(gap_name##_CP,C,i,get,CP_OBJ,oper);	\
  Func2_CXSC_X_X(gap_name##_RI,c,I,get,RI_OBJ,oper);	\
  Func2_CXSC_X_X(gap_name##_CI,C,I,get,CI_OBJ,oper);	\

#define Func2_CXSC(gap_name,oper)			\
  Func2_CXSC_X(gap_name##_RP,R,P,RP_OBJ,oper);		\
  Func2_CXSC_X(gap_name##_CP,C,P,CP_OBJ,oper);		\
  Func2_CXSC_X(gap_name##_RI,R,I,RI_OBJ,oper);		\
  Func2_CXSC_X(gap_name##_CI,C,I,CI_OBJ,oper);

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

#define Func2a_CXSC_X_X(gap_name,c,i,getf,getg,oper)	\
  static Obj gap_name(Obj self, Obj f, Obj g)		\
  {							\
    return OBJ_##c##I(oper(getf(f),getg(g)));		\
  }

#define Func2a_CXSC_X(gap_name,c,i,get,oper)		\
  Func2a_CXSC_X_X(gap_name##_RP,c,i,get,RP_OBJ,oper);	\
  Func2a_CXSC_X_X(gap_name##_CP,C,i,get,CP_OBJ,oper);	\
  Func2a_CXSC_X_X(gap_name##_RI,c,I,get,RI_OBJ,oper);	\
  Func2a_CXSC_X_X(gap_name##_CI,C,I,get,CI_OBJ,oper);	\

#define Func2a_CXSC(gap_name,oper)			\
  Func2a_CXSC_X(gap_name##_RP,R,P,RP_OBJ,oper);		\
  Func2a_CXSC_X(gap_name##_CP,C,P,CP_OBJ,oper);		\
  Func2a_CXSC_X(gap_name##_RI,R,I,RI_OBJ,oper);		\
  Func2a_CXSC_X(gap_name##_CI,C,I,CI_OBJ,oper);

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

#define Func2b_CXSC_X_X(gap_name,c,i,getf,getg,oper)	\
  static Obj gap_name(Obj self, Obj f, Obj g)		\
  {							\
    return getf(f) oper getg(g) ? True : False;		\
  }

#define Func2b_CXSC_X(gap_name,c,i,get,oper)		\
  Func2b_CXSC_X_X(gap_name##_RP,c,i,get,RP_OBJ,oper);	\
  Func2b_CXSC_X_X(gap_name##_CP,C,i,get,CP_OBJ,oper);	\
  Func2b_CXSC_X_X(gap_name##_RI,c,I,get,RI_OBJ,oper);	\
  Func2b_CXSC_X_X(gap_name##_CI,C,I,get,CI_OBJ,oper);	\

#define Func2b_CXSC(gap_name,oper)			\
  Func2b_CXSC_X(gap_name##_RP,R,P,RP_OBJ,oper);		\
  Func2b_CXSC_X(gap_name##_CP,C,P,CP_OBJ,oper);		\
  Func2b_CXSC_X(gap_name##_RI,R,I,RI_OBJ,oper);		\
  Func2b_CXSC_X(gap_name##_CI,C,I,CI_OBJ,oper);

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

static Obj POWER_CXSC_RP (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ(POWER_CXSC_RP,g);
  TEST_IS_RP(POWER_CXSC_RP,f);
  return OBJ_RP(power(RP_OBJ(f), INT_INTOBJ(g)));
}

static Obj POWER_CXSC_CP (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ(POWER_CXSC_CP,g);
  TEST_IS_CP(POWER_CXSC_CP,f);
  return OBJ_CP(power(CP_OBJ(f), INT_INTOBJ(g)));
}

static Obj POWER_CXSC_RI (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ(POWER_CXSC_RI,g);
  TEST_IS_RI(POWER_CXSC_RI,f);
  return OBJ_RI(power(RI_OBJ(f), INT_INTOBJ(g)));
}

static Obj POWER_CXSC_CI (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ(POWER_CXSC_CI,g);
  TEST_IS_CI(POWER_CXSC_CI,f);
  return OBJ_CI(power(CI_OBJ(f), INT_INTOBJ(g)));
}

static Obj ROOT_CXSC_RP (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ(ROOT_CXSC_RP,g);
  TEST_IS_RP(ROOT_CXSC_RP,f);
  return OBJ_RP(sqrt(RP_OBJ(f), INT_INTOBJ(g)));
}

static Obj ROOT_CXSC_CP (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ(ROOT_CXSC_CP,g);
  TEST_IS_CP(ROOT_CXSC_CP,f);
  return OBJ_CP(sqrt(CP_OBJ(f), INT_INTOBJ(g)));
}

static Obj ROOT_CXSC_RI (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ(ROOT_CXSC_RI,g);
  TEST_IS_RI(ROOT_CXSC_RI,f);
  return OBJ_RI(sqrt(RI_OBJ(f), INT_INTOBJ(g)));
}

static Obj ROOT_CXSC_CI (Obj self, Obj f, Obj g)
{
  TEST_IS_INTOBJ(ROOT_CXSC_CI,g);
  TEST_IS_CI(ROOT_CXSC_CI,f);
  return OBJ_CI(sqrt(CI_OBJ(f), INT_INTOBJ(g)));
}

static Obj BLOW_CXSC_RI (Obj self, Obj f, Obj g)
{
  TEST_IS_RP(BLOW_CXSC_RI,g);
  TEST_IS_RI(BLOW_CXSC_RI,f);
  return OBJ_RI(Blow(RI_OBJ(f), RP_OBJ(g)));
}

static Obj BLOW_CXSC_CI (Obj self, Obj f, Obj g)
{
  TEST_IS_RP(BLOW_CXSC_CI,g);
  TEST_IS_CI(BLOW_CXSC_CI,f);
  return OBJ_CI(Blow(CI_OBJ(f), RP_OBJ(g)));
}

static Obj DISJOINT_CXSC_RI_RI (Obj self, Obj f, Obj g)
{
  TEST_IS_RI(DISJOINT_CXSC_RI_RI,f);
  TEST_IS_RI(DISJOINT_CXSC_RI_RI,g);
  return Disjoint(RI_OBJ(f),RI_OBJ(g)) ? True : False;
}

bool Disjoint(cxsc::cinterval &a, cxsc::cinterval &b) {
  return Disjoint(Re(a),Re(b)) || Disjoint(Im(a),Im(b)); }

static Obj DISJOINT_CXSC_CI_CI (Obj self, Obj f, Obj g)
{
  TEST_IS_CI(DISJOINT_CXSC_CI_CI,f);
  TEST_IS_CI(DISJOINT_CXSC_CI_CI,g);
  return Disjoint(CI_OBJ(f),CI_OBJ(g)) ? True : False;
}

static Obj IN_CXSC_RP_RI (Obj self, Obj f, Obj g)
{
  TEST_IS_RP(IN_CXSC_RP_RI,f);
  TEST_IS_RI(IN_CXSC_RP_RI,g);
  return in(RP_OBJ(f),RI_OBJ(g)) ? True : False;
}

static Obj IN_CXSC_RI_RI (Obj self, Obj f, Obj g)
{
  TEST_IS_RI(IN_CXSC_RI_RI,f);
  TEST_IS_RI(IN_CXSC_RI_RI,g);
  return in(RI_OBJ(f),RI_OBJ(g)) ? True : False;
}

bool in (cxsc::complex &a, cxsc::cinterval &b) {
  return in(Re(a),Re(b)) && in(Im(a),Im(b));
}

static Obj IN_CXSC_RP_CI (Obj self, Obj f, Obj g)
{
  TEST_IS_RP(IN_CXSC_RP_CI,f);
  TEST_IS_CI(IN_CXSC_RP_CI,g);
  return in(_cinterval(RP_OBJ(f)),CI_OBJ(g)) ? True : False;
}

static Obj IN_CXSC_CP_CI (Obj self, Obj f, Obj g)
{
  TEST_IS_CP(IN_CXSC_CP_CI,f);
  TEST_IS_CI(IN_CXSC_CP_CI,g);
  return in(_cinterval(CP_OBJ(f)),CI_OBJ(g)) ? True : False;
}

static Obj IN_CXSC_RI_CI (Obj self, Obj f, Obj g)
{
  TEST_IS_RI(IN_CXSC_RI_CI,f);
  TEST_IS_CI(IN_CXSC_RI_CI,g);
  return in(_cinterval(RI_OBJ(f)),CI_OBJ(g)) ? True : False;
}

static Obj IN_CXSC_CI_CI (Obj self, Obj f, Obj g)
{
  TEST_IS_CI(IN_CXSC_CI_CI,f);
  TEST_IS_CI(IN_CXSC_CI_CI,g);
  return in(CI_OBJ(f),CI_OBJ(g)) ? True : False;
}

static Obj ATAN2_CXSC_RP_RP (Obj self, Obj f, Obj g)
{
  TEST_IS_RP(ATAN2_CXSC_RP_RP,f);
  TEST_IS_RP(ATAN2_CXSC_RP_RP,g);
  return OBJ_RP(std::atan2(_double(RP_OBJ(f)),_double(RP_OBJ(g))));
}

static Obj ATAN2_CXSC_CP (Obj self, Obj f)
{
  TEST_IS_CP(ATAN2_CXSC_CP,f);
  cxsc::complex z = CP_OBJ(f);
  return OBJ_RP(std::atan2(_double(Im(z)),_double(Re(z))));
}

static Obj ATAN2_CXSC_CI (Obj self, Obj f)
{
  TEST_IS_CI(ATAN2_CXSC_CI,f);
  return OBJ_RI(Im(cxsc::ln(CI_OBJ(f))));
}

/****************************************************************
 * export functions
 ****************************************************************/
static StructGVarFunc GVarFuncs [] = {  
  Inc1_CXSC_arg(CXSC_INT,"int"),
  Inc1_CXSC_arg(CXSC_NEWCONSTANT,"int"),
  Inc1_CXSC_arg(RP_CXSC_STRING,"string"),
  Inc1_CXSC_arg(RI_CXSC_STRING,"string"),
  Inc1_CXSC_arg(RI_CXSC_RP,"cxsc::rp"),
  Inc2_CXSC_arg(RI_CXSC_RP_RP,"cxsc::rp,cxsc::rp"),
  Inc1_CXSC_arg(CP_CXSC_STRING,"string"),
  Inc2_CXSC_arg(CP_CXSC_RP_RP,"cxsc::rp,cxsc::rp"),
  Inc1_CXSC_arg(CP_CXSC_RP,"cxsc::rp"),
  Inc1_CXSC_arg(CI_CXSC_STRING,"string"),
  Inc2_CXSC_arg(CI_CXSC_RI_RI,"cxsc::ri,cxsc::ri"),
  Inc1_CXSC_arg(CI_CXSC_CP,"cxsc::cp"),
  Inc2_CXSC_arg(CI_CXSC_CP_CP,"cxsc::cp,cxsc::cp"),
  Inc1_CXSC_arg(INT_CXSC,"cxsc::rp"),

  Inc1a_CXSC(REAL_CXSC),
  Inc1a_CXSC(IMAG_CXSC),
  Inc1a_CXSC(NORM_CXSC),
  Inc1a_CXSC(CONJ_CXSC),

  Inc1b_CXSC(DIAM_CXSC),
  Inc1b_CXSC(ISEMPTY_CXSC),
  Inc1b_CXSC(MID_CXSC),
  Inc1b_CXSC(INF_CXSC),
  Inc1b_CXSC(SUP_CXSC),

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
  Inc1_CXSC_arg(ATAN2_CXSC_CP,"cxsc::cp"),
  Inc1_CXSC_arg(ATAN2_CXSC_CI,"cxsc::ci"),

  Inc2_CXSC(SUM_CXSC),
  Inc2_CXSC(DIFF_CXSC),
  Inc2_CXSC(PROD_CXSC),
  Inc2_CXSC(QUO_CXSC),
  Inc2_CXSC(POW_CXSC),
  Inc2_CXSC(OR_CXSC),
  Inc2_CXSC(AND_CXSC),
  Inc2_CXSC(EQ_CXSC),
  Inc2_CXSC(LT_CXSC),
  Inc2_CXSC_arg(ATAN2_CXSC_RP_RP,"cxsc::rp,cxsc::rp"),
  Inc2_CXSC_arg(POWER_CXSC_RP,"cxsc::rp,int"),
  Inc2_CXSC_arg(POWER_CXSC_CP,"cxsc::cp,int"),
  Inc2_CXSC_arg(POWER_CXSC_RI,"cxsc::ri,int"),
  Inc2_CXSC_arg(POWER_CXSC_CI,"cxsc::ci,int"),
  Inc2_CXSC_arg(ROOT_CXSC_RP,"cxsc::rp,int"),
  Inc2_CXSC_arg(ROOT_CXSC_CP,"cxsc::cp,int"),
  Inc2_CXSC_arg(ROOT_CXSC_RI,"cxsc::ri,int"),
  Inc2_CXSC_arg(ROOT_CXSC_CI,"cxsc::ci,int"),
  Inc2_CXSC_arg(BLOW_CXSC_RI,"cxsc::ri,cxsc::rp"),
  Inc2_CXSC_arg(BLOW_CXSC_CI,"cxsc::ci,cxsc::rp"),
  Inc2_CXSC_arg(DISJOINT_CXSC_RI_RI,"cxsc::ri,cxsc::ri"),
  Inc2_CXSC_arg(DISJOINT_CXSC_CI_CI,"ccxsc::ri,ccxsc::ri"),
  Inc2_CXSC_arg(IN_CXSC_RP_RI,"cxsc::rp,cxsc::ri"),
  Inc2_CXSC_arg(IN_CXSC_RI_RI,"cxsc::ri,cxsc::ri"),
  Inc2_CXSC_arg(IN_CXSC_RP_CI,"cxsc::rp,ccxsc::ci"),
  Inc2_CXSC_arg(IN_CXSC_CP_CI,"cxsc::cp,ccxsc::ci"),
  Inc2_CXSC_arg(IN_CXSC_RI_CI,"ccxsc::ri,ccxsc::ci"),
  Inc2_CXSC_arg(IN_CXSC_CI_CI,"ccxsc::ci,ccxsc::ci"),
  Inc2_CXSC_arg(ROOTPOLY_CXSC,"cxsc::c*[],bool"),
  { "STRING_CXSC", 3, "cxsc:**,int,int", (ObjFunc) STRING_CXSC, "src/cxsc_float.c:STRING_CXSC" },
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
  ImportGVarFromLibrary ("TYPE_CXSC_RP", &TYPE_CXSC_RP);
  ImportGVarFromLibrary ("TYPE_CXSC_CP", &TYPE_CXSC_CP);
  ImportGVarFromLibrary ("TYPE_CXSC_RI", &TYPE_CXSC_RI);
  ImportGVarFromLibrary ("TYPE_CXSC_CI", &TYPE_CXSC_CI);

  ImportGVarFromLibrary ("CXSCRealFamily", &FAMILY_CXSC_RP);
  ImportGVarFromLibrary ("CXSCComplexFamily", &FAMILY_CXSC_CP);
  ImportGVarFromLibrary ("CXSCIntervalFamily", &FAMILY_CXSC_RI);
  ImportGVarFromLibrary ("CXSCBoxFamily", &FAMILY_CXSC_CI);

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
