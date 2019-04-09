/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions for the macfloat package.
**
**  Machine floating point values, aka macfloats, are stored as bags
**  containing a 64 bit value.
*/

// glibc only declares exp10 in its headers if we define _GNU_SOURCE
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <math.h>

#include "macfloat.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "io.h"
#include "integer.h"
#include "modules.h"
#include "plist.h"
#include "saveload.h"
#include "stringobj.h"

#define RequireMacFloat(funcname, op) \
    RequireArgumentCondition(funcname, op, IS_MACFLOAT(op), \
        "must be a macfloat")


/****************************************************************************
**
*F  TypeMacfloat( <macfloat> )  . . . . . . . . . .  type of a macfloat value
**
**  'TypeMacfloat' returns the type of macfloatean values.
**
**  'TypeMacfloat' is the function in 'TypeObjFuncs' for macfloatean values.
*/
static Obj TYPE_MACFLOAT;

static Obj TypeMacfloat(Obj val)
{  
    return TYPE_MACFLOAT;
}


// helper function for printing a "decimal" representation of a macfloat
// into a buffer.
static void
PrintMacfloatToBuf(char * buf, size_t bufsize, Double val, int precision)
{
    // handle printing of NaN and infinities ourselves, to ensure
    // they are printed uniformly across all platforms
    if (isnan(val)) {
        strcpy(buf, "nan");
    }
    else if (isinf(val)) {
        if (val > 0)
            strcpy(buf, "inf");
        else
            strcpy(buf, "-inf");
    }
    else {
        snprintf(buf, bufsize, "%.*" PRINTFFORMAT, precision, val);
        // check if a period is in the output; this is not always the case,
        // e.g. if the value is an integer
        if (strchr(buf, '.'))
            return;    // everything is fine
        // we need to insert a '.'; either at the end, or before an exponent
        // (e.g. "7e10" -> "7.e10"). For this we need 1 extra byte of storage,
        // plus of course 1 byte for the string terminator; check if the
        // buffer is big enough
        if (strlen(buf) + 2 <= bufsize) {
            char * loc = strchr(buf, 'e');
            if (loc) {
                memmove(loc + 1, loc, strlen(loc) + 1);
                loc[0] = '.';
            }
            else {
                strxcat(buf, ".", bufsize);
            }
        }
    }
}


/****************************************************************************
**
*F  PrintMacfloat( <macfloat> ) . . . . . . . . . . .  print a macfloat value
**
**  'PrintMacfloat' prints the macfloating value <macfloat>.
*/
static void PrintMacfloat(Obj x)
{
    Char buf[1024];
    // TODO: should we use PRINTFDIGITS instead of 16?
    PrintMacfloatToBuf(buf, sizeof(buf), VAL_MACFLOAT(x), 16);
    Pr("%s", (Int)buf, 0);
}


/****************************************************************************
**
*F  EqMacfloat( <macfloatL>, <macfloatR> )  . . . . . . . . .  test if <macfloatL> =  <macfloatR>
**
**  'EqMacfloat' returns 'True' if the two macfloatean values <macfloatL> and <macfloatR> are
**  equal, and 'False' otherwise.
*/
static Int EqMacfloat(Obj macfloatL, Obj macfloatR)
{
  return VAL_MACFLOAT(macfloatL) == VAL_MACFLOAT(macfloatR);
}

static Obj FuncEQ_MACFLOAT(Obj self, Obj macfloatL, Obj macfloatR)
{
  return EqMacfloat(macfloatL,macfloatR) ? True : False;
}


/****************************************************************************
**
*F  LtMacfloat( <macfloatL>, <macfloatR> )  . . . . . . . . .  test if <macfloatL> <  <macfloatR>
**
*/
static Int LtMacfloat(Obj macfloatL, Obj macfloatR)
{
  return VAL_MACFLOAT(macfloatL) < VAL_MACFLOAT(macfloatR);
}


/****************************************************************************
**
*F  SaveMacfloat( <macfloat> ) . . . . . . . . . . . . . . . . . . . . save a Macfloatean 
**
*/
static void SaveMacfloat(Obj obj)
{
    const UInt1 *data = (const UInt1 *)CONST_ADDR_OBJ(obj);
    for (UInt i = 0; i < sizeof(Double); i++)
        SaveUInt1(data[i]);
}

/****************************************************************************
**
*F  LoadMacfloat( <macfloat> ) . . . . . . . . . . . . . . . . . . . . save a Macfloatean 
**
*/
static void LoadMacfloat(Obj obj)
{
    UInt1 *data = (UInt1 *)ADDR_OBJ(obj);
    for (UInt i = 0; i < sizeof(Double); i++)
        data[i] = LoadUInt1();
}


Obj NEW_MACFLOAT( Double val )
{
    Obj f = NewBag(T_MACFLOAT, sizeof(Double));
    SET_VAL_MACFLOAT(f, val);
    return f;
}

/****************************************************************************
**
*F  ZeroMacfloat(<macfloat> ) . . . . . . . . . . . . . . . . . . . return the zero 
**
*/


static Obj ZeroMacfloat(Obj f)
{
  return NEW_MACFLOAT((Double)0.0);
}

/****************************************************************************
**
*F  AInvMacfloat( <macfloat> ) . . . . . . . . . . . . . . . . .  unary minus
**
*/


static Obj AInvMacfloat(Obj f)
{
  return NEW_MACFLOAT(-VAL_MACFLOAT(f));
}

/****************************************************************************
**
*F  OneMacfloat(<macfloat> ) . . . . . . . . . . . . . . . . . . . return the one 
**
*/


static Obj OneMacfloat(Obj f)
{
  return NEW_MACFLOAT((Double)1.0);
}

/****************************************************************************
**
*F  InvMacfloat(<macfloat> ) . . . . . . . . . . . . . . . . . . . reciprocal
**
*/


static Obj InvMacfloat(Obj f)
{
  return NEW_MACFLOAT((Double)1.0/VAL_MACFLOAT(f));
}

/****************************************************************************
**
*F  ProdMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . . product
**
*/


static Obj ProdMacfloat(Obj fl, Obj fr)
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fl)*VAL_MACFLOAT(fr));
}

/****************************************************************************
**
*F  PowMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . exponentiation
**
*/


static Obj PowMacfloat(Obj fl, Obj fr)
{
  return NEW_MACFLOAT(MATH(pow)(VAL_MACFLOAT(fl),VAL_MACFLOAT(fr)));
}

/****************************************************************************
**
*F  SumMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . .  sum
**
*/


static Obj SumMacfloat(Obj fl, Obj fr)
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fl)+VAL_MACFLOAT(fr));
}

/****************************************************************************
**
*F  DiffMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . difference
**
*/


static Obj DiffMacfloat(Obj fl, Obj fr)
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fl)-VAL_MACFLOAT(fr));
}

/****************************************************************************
**
*F  QuoMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . quotient
**
*/


static Obj QuoMacfloat(Obj fl, Obj fr)
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fl)/VAL_MACFLOAT(fr));
}

/****************************************************************************
**
*F  LQuoMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . .left quotient
**
*/


static Obj LQuoMacfloat(Obj fl, Obj fr)
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fr)/VAL_MACFLOAT(fl));
}

/****************************************************************************
**
*F  ModMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . .mod
**
*/


static Obj ModMacfloat(Obj fl, Obj fr)
{
  return NEW_MACFLOAT(MATH(fmod)(VAL_MACFLOAT(fl),VAL_MACFLOAT(fr)));
}


/****************************************************************************
**
*F  FuncMACFLOAT_INT(<int>) . . . . . . . . . . . . . . . conversion
**
*/

static Obj FuncMACFLOAT_INT(Obj self, Obj i)
{
  if (!IS_INTOBJ(i))
    return Fail;
  else
    return NEW_MACFLOAT((Double)INT_INTOBJ(i));
}

/****************************************************************************
**
*F  FuncMACFLOAT_STRING(<string>) . . . . . . . . . . . . . . . conversion
**
*/

static Obj FuncMACFLOAT_STRING(Obj self, Obj s)
{
    RequireStringRep("MACFLOAT_STRING", s);

  char * endptr;
  UChar *sp = CHARS_STRING(s);
  Obj res= NEW_MACFLOAT((Double) STRTOD((char *)sp,&endptr));
  if ((UChar *)endptr != sp + GET_LEN_STRING(s)) 
    return Fail;
  return res;
}

/****************************************************************************
**
*F SumIntMacfloat( <int>, <macfloat> )
**
*/

static Obj SumIntMacfloat(Obj i, Obj f)
{
  return NEW_MACFLOAT( (Double)(INT_INTOBJ(i)) + VAL_MACFLOAT(f));
}


/****************************************************************************
**
*F FuncSIN_MACFLOAT( <self>, <macfloat> ) . .The sin function from the math library
**
*/

#define MAKEMATHPRIMITIVE(NAME, name)                                        \
    static Obj Func##NAME##_MACFLOAT(Obj self, Obj f)                        \
    {                                                                        \
        return NEW_MACFLOAT(MATH(name)(VAL_MACFLOAT(f)));                    \
    }

#define MAKEMATHPRIMITIVE2(NAME, name)                                       \
    static Obj Func##NAME##_MACFLOAT(Obj self, Obj f, Obj g)                 \
    {                                                                        \
        return NEW_MACFLOAT(MATH(name)(VAL_MACFLOAT(f), VAL_MACFLOAT(g)));   \
    }

MAKEMATHPRIMITIVE(COS,cos)
MAKEMATHPRIMITIVE(SIN,sin)
MAKEMATHPRIMITIVE(TAN,tan)
MAKEMATHPRIMITIVE(ACOS,acos)
MAKEMATHPRIMITIVE(ASIN,asin)
MAKEMATHPRIMITIVE(ATAN,atan)
MAKEMATHPRIMITIVE(LOG,log)
MAKEMATHPRIMITIVE(EXP,exp)
#ifdef HAVE_LOG2
MAKEMATHPRIMITIVE(LOG2,log2)
#endif
#ifdef HAVE_LOG10
MAKEMATHPRIMITIVE(LOG10,log10)
#endif
#ifdef HAVE_LOG1P
MAKEMATHPRIMITIVE(LOG1P,log1p)
#endif
#ifdef HAVE_EXP2
MAKEMATHPRIMITIVE(EXP2,exp2)
#endif
#ifdef HAVE_EXPM1
MAKEMATHPRIMITIVE(EXPM1,expm1)
#endif
#ifdef HAVE_EXP10
MAKEMATHPRIMITIVE(EXP10,exp10)
#endif
MAKEMATHPRIMITIVE(SQRT,sqrt)
MAKEMATHPRIMITIVE(RINT,rint)
MAKEMATHPRIMITIVE(FLOOR,floor)
MAKEMATHPRIMITIVE(CEIL,ceil)
MAKEMATHPRIMITIVE(ABS,fabs)
MAKEMATHPRIMITIVE2(ATAN2,atan2)
MAKEMATHPRIMITIVE2(HYPOT,hypot)

static Obj FuncSIGN_MACFLOAT(Obj self, Obj f)
{
  Double vf = VAL_MACFLOAT(f);
  
  return vf == 0. ? INTOBJ_INT(0) : signbit(vf) ? INTOBJ_INT(-1) : INTOBJ_INT(1);
}

static Obj FuncSIGNBIT_MACFLOAT(Obj self, Obj f)
{
  return signbit(VAL_MACFLOAT(f)) ? True : False;
}


static Obj FuncINTFLOOR_MACFLOAT(Obj self, Obj macfloat)
{
    RequireMacFloat("INTFLOOR_MACFLOAT", macfloat);

    Double f = VAL_MACFLOAT(macfloat);
    if (isnan(f))
        ErrorQuit("cannot convert float nan to integer", 0, 0);
    if (isinf(f))
        ErrorQuit("cannot convert float %s to integer", (Int)(f > 0 ? "inf" : "-inf"), 0);

#ifdef HAVE_TRUNC
  f = trunc(f);
#else
  if (f >= 0.0)
    f = floor(f);
  else
    f = -floor(-f);
#endif


  if (fabs(f) < (Double) (1L<<NR_SMALL_INT_BITS))
    return INTOBJ_INT((Int)f);

  int str_len = (int) (log(fabs(f)) / log(16.0)) + 3;

  Obj str = NEW_STRING(str_len);
  char *s = CSTR_STRING(str), *p = s+str_len-1;
  if (f < 0.0) {
    f = -f;
    s[0] = '-';
  }
  while (p > s || (p == s && s[0] != '-')) {
    int d = (int) fmod(f,16.0);
    *p-- = d < 10 ? '0'+d : 'a'+d-10;
    f /= 16.0;
  }
  return IntHexString(str);
}

static Obj FuncSTRING_DIGITS_MACFLOAT(Obj self, Obj gapprec, Obj f)
{
  Char buf[1024];
  Obj str;
  int prec = INT_INTOBJ(gapprec);
  if (prec > 40) /* too much anyways, and would risk buffer overrun */
    prec = 40;
  PrintMacfloatToBuf(buf, sizeof(buf), VAL_MACFLOAT(f), prec);
  str = MakeString(buf);
  return str;
}

static Obj FuncLDEXP_MACFLOAT(Obj self, Obj f, Obj i)
{
  return NEW_MACFLOAT(ldexp(VAL_MACFLOAT(f),INT_INTOBJ(i)));
}

static Obj FuncFREXP_MACFLOAT(Obj self, Obj f)
{
  int i;
  Obj d = NEW_MACFLOAT(frexp (VAL_MACFLOAT(f), &i));
  Obj l = NEW_PLIST(T_PLIST,2);
  SET_ELM_PLIST(l,1,d);
  SET_ELM_PLIST(l,2,INTOBJ_INT(i));
  SET_LEN_PLIST(l,2);
  return l;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_MACFLOAT, "macfloat" },
  { -1,    "" }
};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {
  GVAR_FUNC(MACFLOAT_INT, 1, "int"),
  GVAR_FUNC(MACFLOAT_STRING, 1, "string"),
  GVAR_FUNC(SIN_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(COS_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(TAN_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(ASIN_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(ACOS_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(ATAN_MACFLOAT, 1, "macfloat"),

  GVAR_FUNC(ATAN2_MACFLOAT, 2, "real, imag"),
  GVAR_FUNC(HYPOT_MACFLOAT, 2, "real, imag"),
  GVAR_FUNC(LOG_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(EXP_MACFLOAT, 1, "macfloat"),
#ifdef HAVE_LOG2
  GVAR_FUNC(LOG2_MACFLOAT, 1, "macfloat"),
#endif
#ifdef HAVE_LOG10
  GVAR_FUNC(LOG10_MACFLOAT, 1, "macfloat"),
#endif  
#ifdef HAVE_LOG1P
  GVAR_FUNC(LOG1P_MACFLOAT, 1, "macfloat"),
#endif  
#ifdef HAVE_EXP2
  GVAR_FUNC(EXP2_MACFLOAT, 1, "macfloat"),
#endif  
#ifdef HAVE_EXPM1
  GVAR_FUNC(EXPM1_MACFLOAT, 1, "macfloat"),
#endif
#ifdef HAVE_EXP10
  GVAR_FUNC(EXP10_MACFLOAT, 1, "macfloat"),
#endif

  GVAR_FUNC(LDEXP_MACFLOAT, 2, "macfloat, int"),
  GVAR_FUNC(FREXP_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(SQRT_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(RINT_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(INTFLOOR_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(FLOOR_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(CEIL_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(ABS_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(SIGN_MACFLOAT, 1, "macfloat"),
  GVAR_FUNC(SIGNBIT_MACFLOAT, 1, "macfloat"),

  GVAR_FUNC(STRING_DIGITS_MACFLOAT, 2, "digits, macfloat"),
  GVAR_FUNC(EQ_MACFLOAT, 2, "x, y"),
  { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking functions for macfloatean values                    */
    InitMarkFuncBags( T_MACFLOAT, MarkNoSubBags );
#ifdef HPCGAP
    MakeBagTypePublic( T_MACFLOAT );
#endif

    /* init functions */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* install the type function                                           */
    ImportGVarFromLibrary( "TYPE_MACFLOAT", &TYPE_MACFLOAT );
    TypeObjFuncs[ T_MACFLOAT ] = TypeMacfloat;

    /* install the saving functions                                       */
    SaveObjFuncs[ T_MACFLOAT ] = SaveMacfloat;

    /* install the loading functions                                       */
    LoadObjFuncs[ T_MACFLOAT ] = LoadMacfloat;

    /* install the printer for macfloatean values                              */
    PrintObjFuncs[ T_MACFLOAT ] = PrintMacfloat;

    /* install the comparison functions                                    */
    EqFuncs[ T_MACFLOAT ][ T_MACFLOAT ] = EqMacfloat;
    LtFuncs[ T_MACFLOAT ][ T_MACFLOAT ] = LtMacfloat;

    /* allow method selection to protest against comparisons of float and int */
    for (int t = T_INT; t <= T_CYC; t++)
        EqFuncs[T_MACFLOAT][t] = EqFuncs[t][T_MACFLOAT] = EqObject;

    /* install the unary arithmetic methods                                */
    ZeroFuncs[ T_MACFLOAT ] = ZeroMacfloat;
    ZeroMutFuncs[ T_MACFLOAT ] = ZeroMacfloat;
    AInvMutFuncs[ T_MACFLOAT ] = AInvMacfloat;
    OneFuncs [ T_MACFLOAT ] = OneMacfloat;
    OneMutFuncs [ T_MACFLOAT ] = OneMacfloat;
    InvFuncs [ T_MACFLOAT ] = InvMacfloat;

    /* install binary arithmetic methods */
    ProdFuncs[ T_MACFLOAT ][ T_MACFLOAT ] = ProdMacfloat;
    PowFuncs [ T_MACFLOAT ][ T_MACFLOAT ] = PowMacfloat;
    SumFuncs[ T_MACFLOAT ][ T_MACFLOAT ] = SumMacfloat;
    DiffFuncs [ T_MACFLOAT ][ T_MACFLOAT ] = DiffMacfloat;
    QuoFuncs [ T_MACFLOAT ][ T_MACFLOAT ] = QuoMacfloat;
    LQuoFuncs [ T_MACFLOAT ][ T_MACFLOAT ] = LQuoMacfloat;
    ModFuncs [ T_MACFLOAT ][ T_MACFLOAT ] = ModMacfloat;
    SumFuncs [ T_INT ][ T_MACFLOAT ] = SumIntMacfloat;
    
    /* Probably support mixed ops with small ints in the kernel as well
       on any reasonable system, all small ints should have macfloat equivalents

       Anything else, like mixed ops with rationals, we can leave to the library
       at least for a while */
     
    
    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init functions */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoMacfloat()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "macfloat",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoMacfloat ( void )
{
    return &module;
}
