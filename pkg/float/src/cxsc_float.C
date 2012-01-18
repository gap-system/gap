/****************************************************************************
**
*W  cxsc_float.C                    GAP source              Laurent Bartholdi
**
*H  @(#)$Id: cxsc_float.C,v 1.11 2011/12/05 08:41:48 gap Exp $
**
*Y  Copyright (C) 2008 Laurent Bartholdi
**
**  This file contains the main dll of the CXSC float package.
*/
static const char *Revision_cxsc_float_c =
   "@(#)$Id: cxsc_float.C,v 1.11 2011/12/05 08:41:48 gap Exp $";

#define BANNER_CXSC_FLOAT_H

#include <gmp.h>

extern "C" {
#include "src/compiled.h"
#include "src/macfloat.h"
}
#undef ZERO // clashes with ZERO in cxsc
#include "cxsc_float.h"
#undef ZERO // make sure we use neither

#include "cpoly.hpp"
#include "cipoly.hpp"
#include "cpzero.hpp"
#include "rpoly.hpp"
#include "rpeval.hpp"

// this function is missing from CXSC 2.5.1
cxsc::complex cxsc::sqr(const cxsc::complex&z) throw() { return z*z; }

// this function is missing from CXSC 2.5.1
bool Disjoint(cxsc::cinterval &a, cxsc::cinterval &b) {
  return Disjoint(Re(a),Re(b)) || Disjoint(Im(a),Im(b)); }

Obj TYPE_CXSC_RP, TYPE_CXSC_CP, TYPE_CXSC_RI, TYPE_CXSC_CI;
Obj IS_CXSC_RP, IS_CXSC_CP, IS_CXSC_RI, IS_CXSC_CI;
Obj FAMILY_CXSC;

/****************************************************************
 * creators
 ****************************************************************/
static inline Obj NEW_RP (void)
{
  Obj o = NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::real));
  SET_TYPE_DATOBJ(o, TYPE_CXSC_RP);
  return o;
}
static inline Obj NEW_CP (void)
{
  Obj o = NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::complex));
  SET_TYPE_DATOBJ(o, TYPE_CXSC_CP);
  return o;
}
static inline Obj NEW_RI (void)
{
  Obj o = NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::interval));
  SET_TYPE_DATOBJ(o, TYPE_CXSC_RI);
  return o;
}
static inline Obj NEW_CI (void)
{
  Obj o = NewBag(T_DATOBJ,sizeof(Obj)+sizeof(cxsc::cinterval));
  SET_TYPE_DATOBJ(o, TYPE_CXSC_CI);
  return o;
}

static inline Obj OBJ_RP (cxsc::real i)
{
  Obj f = NEW_RP();
  RP_OBJ(f) = i;
  return f;
}
static inline Obj OBJ_CP (cxsc::complex i)
{
  Obj f = NEW_CP();
  CP_OBJ(f) = i;
  return f;
}
static inline Obj OBJ_RI (cxsc::interval i)
{
  Obj f = NEW_RI();
  RI_OBJ(f) = i;
  return f;
}
static inline Obj OBJ_CI (cxsc::cinterval i)
{
  Obj f = NEW_CI();
  CI_OBJ(f) = i;
  return f;
}
  
static inline cxsc::real RP_GET(cxsc::real x) { return x; }
static inline cxsc::complex CP_GET(cxsc::real x) { return _complex(x); }
static inline cxsc::interval RI_GET(cxsc::real x) { return _interval(x); }
static inline cxsc::cinterval CI_GET(cxsc::real x) { return _cinterval(x); }

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

#define VAL_MACFLOAT(obj) (*(Double *)ADDR_OBJ(obj))
#define IS_MACFLOAT(obj) (TNUM_OBJ(obj) == T_MACFLOAT)

static Obj CXSC_IEEE754 (Obj self, Obj f)
{
  while (!IS_MACFLOAT(f)) {
    f = ErrorReturnObj("CXSC_IEEE754: object must be a float, not a %s",
                       (Int)(InfoBags[TNUM_OBJ(f)].name),0,
                       "You can return a float to continue");
  }
  return OBJ_RP(VAL_MACFLOAT(f));
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

static Obj SIGN_CXSC_RP (Obj self, Obj f)
{
  TEST_IS_RP(SIGN_CXSC_RP,f);
  return INTOBJ_INT(sign(RP_OBJ(f)));
}

static Obj SIGN_CXSC_RI (Obj self, Obj f)
{
  TEST_IS_RI(SIGN_CXSC_RI,f);
  if (Inf(RI_OBJ(f))>0.0)
    return INTOBJ_INT(1);
  if (Sup(RI_OBJ(f))<0.0)
    return INTOBJ_INT(-1);
  if (RI_OBJ(f)==0.0)
    return INTOBJ_INT(0);
  return Fail;
}

#define Func1c_CXSC(gap_name,cxsc_name)				\
  static Obj gap_name##_RP(Obj self, Obj f)			\
  {								\
    TEST_IS_RP(gap_name##_RP,f);				\
    return cxsc_name(RP_OBJ(f)) ? True : False;			\
  }								\
  static Obj gap_name##_CP(Obj self, Obj f)			\
  {								\
    TEST_IS_CP(gap_name##_CP,f);				\
    return cxsc_name(CP_OBJ(f)) ? True : False;			\
  }								\
  static Obj gap_name##_RI(Obj self, Obj f)			\
  {								\
    TEST_IS_RI(gap_name##_RI,f);				\
    return cxsc_name(RI_OBJ(f)) ? True : False;			\
  }								\
  static Obj gap_name##_CI(Obj self, Obj f)			\
  {								\
    TEST_IS_CI(gap_name##_CI,f);				\
    return cxsc_name(CI_OBJ(f)) ? True : False;			\
  }

bool IsQuietNaN(cxsc::complex &x) {
  return IsQuietNaN(Re(x)) || IsQuietNaN(Im(x)); }
bool IsQuietNaN(cxsc::interval &x) {
  return IsQuietNaN(Inf(x)) || IsQuietNaN(Sup(x)); }
bool IsQuietNaN(cxsc::cinterval &x) {
  return IsQuietNaN(Re(x)) || IsQuietNaN(Im(x)); }
Func1c_CXSC(ISNAN_CXSC,IsQuietNaN)
bool IsInfinity(cxsc::complex &x) {
  return IsInfinity(Re(x)) || IsInfinity(Im(x)); }
bool IsInfinity(cxsc::interval &x) {
  return IsInfinity(Inf(x)) || IsInfinity(Sup(x)); }
bool IsInfinity(cxsc::cinterval &x) {
  return IsInfinity(Re(x)) || IsInfinity(Im(x)); }
Func1c_CXSC(ISXINF_CXSC,IsInfinity)
bool IsPInfinity(cxsc::real &x) { return IsInfinity(x) && x > 0.0; }
bool IsPInfinity(cxsc::interval &x) { return IsInfinity(x) && x > 0.0; }
bool IsPInfinity(cxsc::complex &x) { return IsInfinity(x); }
bool IsPInfinity(cxsc::cinterval &x) { return IsInfinity(x); }
Func1c_CXSC(ISPINF_CXSC,IsPInfinity)
bool IsNInfinity(cxsc::real &x) { return IsInfinity(x) && x < 0.0; }
bool IsNInfinity(cxsc::interval &x) { return IsInfinity(x) && x < 0.0; }
bool IsNInfinity(cxsc::complex &x) { return IsInfinity(x); }
bool IsNInfinity(cxsc::cinterval &x) { return IsInfinity(x); }
Func1c_CXSC(ISNINF_CXSC,IsNInfinity)
bool IsZero(cxsc::real &x) { return x == 0.0; }
bool IsZero(cxsc::interval &x) { return x == 0.0; }
bool IsZero(cxsc::complex &x) { return x == 0.0; }
bool IsZero(cxsc::cinterval &x) { return x == 0.0; }
Func1c_CXSC(ISZERO_CXSC,IsZero)
bool IsOne(cxsc::real &x) { return x == 1.0; }
bool IsOne(cxsc::interval &x) { return x == 1.0; }
bool IsOne(cxsc::complex &x) { return x == 1.0; }
bool IsOne(cxsc::cinterval &x) { return x == 1.0; }
Func1c_CXSC(ISONE_CXSC,IsOne)
bool IsNumber(cxsc::real &x) { return !IsInfinity(x) && !IsQuietNaN(x); }
bool IsNumber(cxsc::interval &x) { return !IsInfinity(x) && !IsQuietNaN(x); }
bool IsNumber(cxsc::complex &x) { return !IsInfinity(x) && !IsQuietNaN(x); }
bool IsNumber(cxsc::cinterval &x) { return !IsInfinity(x) && !IsQuietNaN(x); }
Func1c_CXSC(ISNUMBER_CXSC,IsNumber)

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

cxsc::complex RelDiam(cxsc::cinterval z)
{
  if (z == 0.0)
    return cxsc::complex(0.0);
  return diam(z) / Sup(abs(z));
}

Func1b_CXSC(INF_CXSC,Inf);
Func1b_CXSC(SUP_CXSC,Sup);
Func1b_CXSC(MID_CXSC,mid);
Func1b_CXSC(DIAM_CXSC,diam);
Func1b_CXSC(DIAM_REL_CXSC,RelDiam);

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
  if (s[0] == '(')
    s >> CP_OBJ(f);
  else {
    real r;
    char last = s[s.length()-1];
    s >> r;
    if (last == 'i' || last == 'I')
      CP_OBJ(f) = complex(0.0,r);
    else
      CP_OBJ(f) = r;
  } 
  return f;
}

static Obj RI_CXSC_STRING (Obj self, Obj str)
{
  TEST_IS_STRING(RI_CXSC_STRING,str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_RI();
  if (s[0] == '[')
    s >> RI_OBJ(f);
  else {
    real l, r;
    std::string t = CSTR_STRING(str);
    s >> RndDown >> l;
    t >> RndUp >> r;
    RI_OBJ(f) = interval(l,r);
  }
  return f;
}

static Obj CI_CXSC_STRING (Obj self, Obj str)
{
  TEST_IS_STRING(CI_CXSC_STRING,str);

  std::string s = CSTR_STRING(str);
  Obj f = NEW_CI();
  if (s[0] == '[')
    s >> CI_OBJ(f);
  else if (s[0] == '(') {
    complex l, r;
    std::string t = CSTR_STRING(str);
    s >> RndDown >> l;
    t >> RndUp >> r;
    CI_OBJ(f) = cinterval(l,r);
  } else {
    real l, r;
    std::string t = CSTR_STRING(str);
    char last = s[s.length()-1];
    s >> RndDown >> l;
    t >> RndUp >> r;
    if (last == 'i' || last == 'I')
      CI_OBJ(f) = cinterval(complex(0.0,l),complex(0.0,r));
    else
      CI_OBJ(f) = cinterval(complex(l),complex(r));
  } 
    
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
Func1_CXSC(EXPM1_CXSC,cxsc::expm1);
Func1_CXSC(LOG_CXSC,cxsc::ln);
Func1_CXSC(LOG1P_CXSC,cxsc::lnp1);
Func1_CXSC(LOG2_CXSC,cxsc::log2);
Func1_CXSC(LOG10_CXSC,cxsc::log10);

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

#pragma GCC diagnostic ignored "-Wuninitialized"
static Obj ROOTPOLY_CXSC(Obj self, Obj gapcoeffs, Obj gapintervals)
{
  int degree = LEN_PLIST(gapcoeffs)-1, numroots;
  bool intervals = false, real = true, complex = false;

  CPolynomial poly(degree);
  cxsc::complex coeffs[degree+1], roots[degree];

  for (int i = 0; i <= degree; i++) {
    Obj c = ELM_PLIST(gapcoeffs,i+1);
    cxsc::complex z;
    if (IS_RP(c))
      z = RP_OBJ(c);
    else if (IS_CP(c)) 
      z = CP_OBJ(c), complex = true, real &= (Im(z) == 0.0);
    else if (IS_RI(c))
      z = cxsc::mid(RI_OBJ(c)), intervals = true;
    else if (IS_CI(c))
      z = cxsc::mid(CI_OBJ(c)), complex = intervals = true,
	real &= (Im(CI_OBJ(c)) == 0.0);
    else ERROR_CXSC(ROOTPOLY_CXSC,c);
    poly[i] = coeffs[degree-i] = z;
  }
  
  numroots = cpoly_CXSC (degree, coeffs, roots, 53);

  if (numroots == -1)
    return Fail;

  Obj result = NEW_PLIST(T_PLIST, degree);
  SET_LEN_PLIST(result, degree);
  if (intervals) {
    cxsc::cinterval iroots[numroots];

    for (int i = 0; i < numroots; i++) {
      CIPolynomial rp(degree);
      int error;
      CPolyZero(poly,roots[i],rp,iroots[i],error);
      if (error) {
	iroots[i] = roots[i];
	Pr("#W CPOLYZERO failed to find enclosure for root %d; returning approximate root\n",i+1,0);
      }
    }

    // now, if the polynomial was real, force all isolated roots to be real
    if (real)
      for (int i = 0; i < numroots; i++)
	if (in(0.0,Im(iroots[i]))) { 
	  bool lone = true;
	  for (int j = 0; j < numroots; j++)
	    if (j != i && !Disjoint(iroots[i],iroots[j])) {
	      lone = false; break;
	    }
	  if (lone)
	    iroots[i] = cinterval(Re(iroots[i]));
	}

    for (int i = 1; i <= numroots; i++) {
      Obj gapz;
      if (!complex && Im(iroots[i-i]) == 0.0)
	gapz = OBJ_RI(Re(iroots[i-1]));
      else
	gapz = OBJ_CI(iroots[i-1]);
      SET_ELM_PLIST(result,i,gapz);
    }
  } else {
    // if the polynomial is real, and there doesn't exist a root at distance
    // <= 3*imaginarypart, force the imaginary part to be 0.
    if (real) 
      for (int i = 0; i < numroots; i++) {
	cxsc::real r = 10.0*sqr(Im(roots[i]));
	bool lone = true;
	for (int j = 0; j < numroots; j++)
	  if (j != i && abs2(roots[i]-roots[j]) <= r) {
	    lone = false; break;
	  }
	if (lone)
	  roots[i] = cxsc::complex(Re(roots[i]));
      }

    for (int i = 1; i <= numroots; i++) {
      Obj gapz;
      if (!complex && Im(roots[i-1])==0.0)
	gapz = OBJ_RP(Re(roots[i-1]));
      else
	gapz = OBJ_CP(roots[i-1]);
      SET_ELM_PLIST(result,i,gapz);
    }
  }
  // some roots we missed
  for (int i = numroots+1; i <= degree; i++)
    SET_ELM_PLIST(result,i,Fail);

  return result;
}

static Obj EVALPOLY_CXSC(Obj self, Obj gapcoeffs, Obj gapt)
{
  TEST_IS_RP(EVALPOLY_CXSC,gapt);

  int degree = LEN_PLIST(gapcoeffs)-1, k, err;
  RPolynomial polyr(degree), polyi(degree);
  bool complex = false;

  for (int i = 0; i <= degree; i++) {
    Obj c = ELM_PLIST(gapcoeffs,i+1);
    if (IS_RP(c))
      polyr[i] = RP_OBJ(c);
    else if (IS_CP(c))
      polyr[i] = Re(CP_OBJ(c)), polyi[i] = Im(CP_OBJ(c)), complex = true;
    else
      ERROR_CXSC(EVALPOLY_CXSC,c);
  }

  interval intz[2];
  real z[2];

  RPolyEval (polyr, RP_OBJ(gapt), z[0], intz[0], k, err);
  if (err)
    return Fail;

  if (complex) {
    RPolyEval (polyi, RP_OBJ(gapt), z[1], intz[1], k, err);
    if (err)
      return Fail;
  }
    
  Obj list = NEW_PLIST(T_PLIST,2);
  SET_LEN_PLIST(list,2);
  Obj gapz, gapintz;
  if (complex)
    gapz = OBJ_CP(cxsc::complex(z[0],z[1])), gapintz = OBJ_CI(cxsc::cinterval(intz[0],intz[1]));
  else
    gapz = OBJ_RP(z[0]), gapintz = OBJ_RI(intz[0]);

  SET_ELM_PLIST(list,1,gapz);
  SET_ELM_PLIST(list,2,gapintz);

  return list;
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

static inline real ldexp (real f, int s)
{
  real g = f; times2pown(g, s); return g;
}

static inline complex ldexp (complex f, int s)
{
  return complex(ldexp(Re(f),s),ldexp(Im(f),s));
}
static inline interval ldexp (interval f, int s)
{
  return interval(ldexp(Inf(f),s),ldexp(Sup(f),s));
}
static inline cinterval ldexp (cinterval f, int s)
{
  return cinterval(ldexp(Re(f),s),ldexp(Re(f),s));
}

static Obj LDEXP_CXSC_RP (Obj self, Obj f, Obj i)
{
  TEST_IS_INTOBJ(LDEXP_CXSC_RP,i);
  TEST_IS_RP(LDEXP_CXSC_RP,f);
  return OBJ_RP(ldexp(RP_OBJ(f), INT_INTOBJ(i)));
}

static Obj LDEXP_CXSC_CP (Obj self, Obj f, Obj i)
{
  TEST_IS_INTOBJ(LDEXP_CXSC_CP,i);
  TEST_IS_CP(LDEXP_CXSC_CP,f);
  return OBJ_CP(ldexp(CP_OBJ(f),INT_INTOBJ(i)));
}

static Obj LDEXP_CXSC_RI (Obj self, Obj f, Obj i)
{
  TEST_IS_INTOBJ(LDEXP_CXSC_RI,i);
  TEST_IS_RI(LDEXP_CXSC_RI,f);
  return OBJ_RI(ldexp(RI_OBJ(f),INT_INTOBJ(i)));
}

static Obj LDEXP_CXSC_CI (Obj self, Obj f, Obj i)
{
  TEST_IS_INTOBJ(LDEXP_CXSC_CI,i);
  TEST_IS_CI(LDEXP_CXSC_CI,f);
  return OBJ_CI(ldexp(CI_OBJ(f),INT_INTOBJ(i)));
}

static Obj FREXP_CXSC_RP (Obj self, Obj f)
{
  TEST_IS_RP(FREXP_CXSC_RP,f);
  Obj l = NEW_PLIST(T_PLIST,2);
  SET_ELM_PLIST(l,1,OBJ_RP(mant(RP_OBJ(f))));
  SET_ELM_PLIST(l,2,INTOBJ_INT(expo(RP_OBJ(f))));
  SET_LEN_PLIST(l,2);
  return l;
}

static Obj FREXP_CXSC_CP (Obj self, Obj f)
{
  TEST_IS_CP(FREXP_CXSC_CP,f);
  Obj l = NEW_PLIST(T_PLIST,2);
  int e0 = expo(Re(CP_OBJ(f))), e1 = expo(Im(CP_OBJ(f))), e = (e0 > e1 ? e0 : e1);
  SET_ELM_PLIST(l,1,OBJ_CP(ldexp(CP_OBJ(f),-e)));
  SET_ELM_PLIST(l,2,INTOBJ_INT(e));
  SET_LEN_PLIST(l,2);
  return l;
}

static Obj FREXP_CXSC_RI (Obj self, Obj f)
{
  TEST_IS_RI(FREXP_CXSC_RI,f);
  Obj l = NEW_PLIST(T_PLIST,2);
  int e0 = expo(Inf(RI_OBJ(f))), e1 = expo(Sup(RI_OBJ(f))), e = (e0 > e1 ? e0 : e1);
  SET_ELM_PLIST(l,1,OBJ_RI(ldexp(RI_OBJ(f),-e)));
  SET_ELM_PLIST(l,2,INTOBJ_INT(e));
  SET_LEN_PLIST(l,2);
  return l;
}

static Obj FREXP_CXSC_CI (Obj self, Obj f)
{
  TEST_IS_CI(FREXP_CXSC_CI,f);
  Obj l = NEW_PLIST(T_PLIST,2);
  int e00 = expo(Inf(Re(CI_OBJ(f)))), e01 = expo(Sup(Re(CI_OBJ(f)))), e0 = (e00 > e01 ? e00 : e01);
  int e10 = expo(Inf(Im(CI_OBJ(f)))), e11 = expo(Sup(Im(CI_OBJ(f)))), e1 = (e10 > e11 ? e10 : e11);
  int e = (e0 > e1 ? e0 : e1);
  SET_ELM_PLIST(l,1,OBJ_CI(ldexp(CI_OBJ(f),-e)));
  SET_ELM_PLIST(l,2,INTOBJ_INT(e));
  SET_LEN_PLIST(l,2);
  return l;
}

static void put_real (Obj list, int pos, cxsc::real f)
{
  SET_ELM_PLIST(list,pos,INTOBJ_INT(0));
  if (f == 0.0) {
    if (1.0/f > 0.0)
      SET_ELM_PLIST(list,pos+1,INTOBJ_INT(0));
    else
      SET_ELM_PLIST(list,pos+1,INTOBJ_INT(1));
    return;
  }
  if (IsInfinity(f)) {
    if (f > 0.0)
      SET_ELM_PLIST(list,pos+1,INTOBJ_INT(2));
    else
      SET_ELM_PLIST(list,pos+1,INTOBJ_INT(3));
    return;
  }
  if (IsQuietNaN(f)) {
    SET_ELM_PLIST(list,pos+1,INTOBJ_INT(4));
    return;
  }

  cxsc::real m = mant(f);
  cxsc::times2pown(m,26);
  int m0 = _double(m);
  Obj gapm = INTOBJ_INT(m0);
  m -= m0;
  cxsc::times2pown(m,27);
  gapm = SumInt(ProdInt(gapm,INTOBJ_INT(1 << 27)),INTOBJ_INT(_double(m)));

  while (!INT_INTOBJ(RemInt(gapm,INTOBJ_INT(2))))
    gapm = QuoInt(gapm,INTOBJ_INT(2));

  SET_ELM_PLIST(list,pos,gapm);
  SET_ELM_PLIST(list,pos+1,INTOBJ_INT(expo(f)));
}

static Obj EXTREPOFOBJ_CXSC_RP(Obj self, Obj f)
{
  TEST_IS_RP(EXTREPOBJOBJ_CXSC_RP,f);
  Obj l = NEW_PLIST(T_PLIST,2);
  SET_LEN_PLIST(l,2);
  put_real (l,1,RP_OBJ(f));
  return l;
}

static Obj EXTREPOFOBJ_CXSC_RI(Obj self, Obj f)
{
  TEST_IS_RI(EXTREPOBJOBJ_CXSC_RI,f);
  Obj l = NEW_PLIST(T_PLIST,4);
  SET_LEN_PLIST(l,4);
  put_real (l,1,Inf(RI_OBJ(f)));
  put_real (l,3,Sup(RI_OBJ(f)));
  return l;
}

static Obj EXTREPOFOBJ_CXSC_CP(Obj self, Obj f)
{
  TEST_IS_CP(EXTREPOBJOBJ_CXSC_CP,f);
  Obj l = NEW_PLIST(T_PLIST,4);
  SET_LEN_PLIST(l,4);
  put_real (l,1,Re(CP_OBJ(f)));
  put_real (l,3,Im(CP_OBJ(f)));
  return l;
}

static Obj EXTREPOFOBJ_CXSC_CI(Obj self, Obj f)
{
  TEST_IS_CI(EXTREPOBJOBJ_CXSC_CI,f);
  Obj l = NEW_PLIST(T_PLIST,8);
  SET_LEN_PLIST(l,8);
  put_real (l,1,InfRe(CI_OBJ(f)));
  put_real (l,3,SupRe(CI_OBJ(f)));
  put_real (l,5,InfIm(CI_OBJ(f)));
  put_real (l,7,SupIm(CI_OBJ(f)));
  return l;
}

static cxsc::real get_real (Obj l, int pos)
{
  Obj mant = ELM_PLIST(l,pos);
  int exp = INT_INTOBJ(ELM_PLIST(l,pos+1));

  if (EqInt(mant,INTOBJ_INT(0)))
    switch (exp) {
    case 0: return 0.0;
    case 1: return 1.0 / (-1.0 / 0.0);
    case 2: return 1.0 / 0.0;
    case 3: return -1.0 / 0.0;
    case 4: return cxsc::QuietNaN;
    }

  cxsc::real m = INT_INTOBJ(RemInt(mant,INTOBJ_INT(1 << 27)));
  cxsc::times2pown(m,-27);
  m += INT_INTOBJ(QuoInt(mant,INTOBJ_INT(1 << 27)));
  cxsc::times2pown(m,exp+27-INT_INTOBJ(FuncLog2Int(Fail,mant)));
  return m;
}

static Obj OBJBYEXTREP_CXSC_RP(Obj self, Obj l)
{
  return OBJ_RP(get_real(l,1));
}

static cxsc::interval get_interval(Obj l, int pos)
{
  return interval(get_real(l,pos),get_real(l,pos+2));
}

static Obj OBJBYEXTREP_CXSC_RI(Obj self, Obj l)
{
  return OBJ_RI(get_interval(l,1));
}

static Obj OBJBYEXTREP_CXSC_CP(Obj self, Obj l)
{
  return OBJ_CP(cxsc::complex(get_real(l,1),get_real(l,3)));
}

static Obj OBJBYEXTREP_CXSC_CI(Obj self, Obj l)
{
  return OBJ_CI(cxsc::cinterval(get_interval(l,1),get_interval(l,5)));
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

static Obj HYPOT_CXSC_RP2 (Obj self, Obj f, Obj g)
{
  TEST_IS_RP(HYPOT_CXSC_RP2,f);
  TEST_IS_RP(HYPOT_CXSC_RP2,g);
  return OBJ_RP(cxsc::sqrtx2y2(RP_OBJ(f),RP_OBJ(g)));
}

/****************************************************************
 * export functions
 ****************************************************************/
static StructGVarFunc GVarFuncs [] = {  
  Inc1_CXSC_arg(CXSC_INT,"int"),
  Inc1_CXSC_arg(CXSC_IEEE754,"float"),
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
  Inc1b_CXSC(DIAM_REL_CXSC),
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
  Inc1_CXSC(EXPM1_CXSC),
  Inc1_CXSC(FREXP_CXSC),
  Inc1_CXSC(EXTREPOFOBJ_CXSC),
  Inc1_CXSC(OBJBYEXTREP_CXSC),
  Inc1_CXSC(LOG_CXSC),
  Inc1_CXSC(LOG1P_CXSC),
  Inc1_CXSC(LOG2_CXSC),
  Inc1_CXSC(LOG10_CXSC),
  Inc1_CXSC(ABS_CXSC),
  Inc1_CXSC(ISNAN_CXSC),
  Inc1_CXSC(ISXINF_CXSC),
  Inc1_CXSC(ISPINF_CXSC),
  Inc1_CXSC(ISNINF_CXSC),
  Inc1_CXSC(ISZERO_CXSC),
  Inc1_CXSC(ISONE_CXSC),
  Inc1_CXSC(ISNUMBER_CXSC),
  Inc1_CXSC_arg(ATAN2_CXSC_CP,"cxsc::cp"),
  Inc1_CXSC_arg(ATAN2_CXSC_CI,"cxsc::ci"),

  Inc2_CXSC_arg(HYPOT_CXSC_RP2,"x, y"),
  Inc1_CXSC_arg(SIGN_CXSC_RP,"cxsc::rp"),
  Inc1_CXSC_arg(SIGN_CXSC_RI,"cxsc::ri"),
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
  Inc2_CXSC_arg(LDEXP_CXSC_RP,"cxsc::rp,int"),
  Inc2_CXSC_arg(LDEXP_CXSC_CP,"cxsc::cp,int"),
  Inc2_CXSC_arg(LDEXP_CXSC_RI,"cxsc::ri,int"),
  Inc2_CXSC_arg(LDEXP_CXSC_CI,"cxsc::ci,int"),
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
  Inc2_CXSC_arg(EVALPOLY_CXSC,"cxsc::rp[],cxsc::rp"),
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
  InitHdlrFuncsFromTable (GVarFuncs);

  ImportGVarFromLibrary ("TYPE_CXSC_RP", &TYPE_CXSC_RP);
  ImportGVarFromLibrary ("TYPE_CXSC_CP", &TYPE_CXSC_CP);
  ImportGVarFromLibrary ("TYPE_CXSC_RI", &TYPE_CXSC_RI);
  ImportGVarFromLibrary ("TYPE_CXSC_CI", &TYPE_CXSC_CI);

  ImportGVarFromLibrary ("IsCXSCReal", &IS_CXSC_RP);
  ImportGVarFromLibrary ("IsCXSCComplex", &IS_CXSC_CP);
  ImportGVarFromLibrary ("IsCXSCInterval", &IS_CXSC_RI);
  ImportGVarFromLibrary ("IsCXSCBox", &IS_CXSC_CI);

  ImportGVarFromLibrary ("CXSCFloatsFamily", &FAMILY_CXSC);

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
