/****************************************************************************
**
*W  macfloat.c                   GAP source                      Steve Linton
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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



#include <src/system.h>                 /* system dependent part */


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */

#include <src/gap.h>                    /* error handling, initialisation */


#include <src/plist.h>                  /* lists */
#include <src/ariths.h>                 /* basic arithmetic */
#include <src/integer.h>                /* basic arithmetic */

#include <src/macfloat.h>               /* macfloateans */

#include <src/bool.h>
#include <src/io.h>
#include <src/stringobj.h>
#include <assert.h>


/* the following two declarations would belong in `saveload.h', but then all
 * files get macfloat dependencies */
extern Double LoadDouble( void);
extern void SaveDouble( Double d);

#include <stdio.h>
#include <stdlib.h>

#define SIZE_MACFLOAT   sizeof(Double)

/****************************************************************************
**
*F  TypeMacfloat( <macfloat> )  . . . . . . . . . .  type of a macfloat value
**
**  'TypeMacfloat' returns the type of macfloatean values.
**
**  'TypeMacfloat' is the function in 'TypeObjFuncs' for macfloatean values.
*/
Obj TYPE_MACFLOAT;

Obj TypeMacfloat (
    Obj                 val )
{  
    return TYPE_MACFLOAT;
}


/****************************************************************************
**
*F  PrintMacfloat( <macfloat> ) . . . . . . . . . . . . . . . . print a macfloat value
**
**  'PrintMacfloat' prints the macfloating value <macfloat>.
*/
void PrintMacfloat (
    Obj                 x )
{
  Char buf[32];
  snprintf(buf, sizeof(buf), "%.16" PRINTFFORMAT, (TOPRINTFFORMAT) VAL_MACFLOAT(x));
  Pr("%s",(Int)buf, 0);
}


/****************************************************************************
**
*F  EqMacfloat( <macfloatL>, <macfloatR> )  . . . . . . . . .  test if <macfloatL> =  <macfloatR>
**
**  'EqMacfloat' returns 'True' if the two macfloatean values <macfloatL> and <macfloatR> are
**  equal, and 'False' otherwise.
*/
Int EqMacfloat (
    Obj                 macfloatL,
    Obj                 macfloatR )
{
  return VAL_MACFLOAT(macfloatL) == VAL_MACFLOAT(macfloatR);
}

Obj FuncEQ_MACFLOAT (
    Obj                 self,
    Obj                 macfloatL,
    Obj                 macfloatR )
{
  return EqMacfloat(macfloatL,macfloatR) ? True : False;
}


/****************************************************************************
**
*F  LtMacfloat( <macfloatL>, <macfloatR> )  . . . . . . . . .  test if <macfloatL> <  <macfloatR>
**
*/
Int LtMacfloat (
    Obj                 macfloatL,
    Obj                 macfloatR )
{
  return VAL_MACFLOAT(macfloatL) < VAL_MACFLOAT(macfloatR);
}


/****************************************************************************
**
*F  SaveMacfloat( <macfloat> ) . . . . . . . . . . . . . . . . . . . . save a Macfloatean 
**
*/

void SaveMacfloat( Obj obj )
{
  SaveDouble(VAL_MACFLOAT(obj));
}

/****************************************************************************
**
*F  LoadMacfloat( <macfloat> ) . . . . . . . . . . . . . . . . . . . . save a Macfloatean 
**
*/

void LoadMacfloat( Obj obj )
{
  SET_VAL_MACFLOAT(obj, LoadDouble());
}

Obj NEW_MACFLOAT( Double val )
{
  Obj f;
  f = NewBag(T_MACFLOAT,SIZE_MACFLOAT);
  SET_VAL_MACFLOAT(f,val);
  return f;
}

/****************************************************************************
**
*F  ZeroMacfloat(<macfloat> ) . . . . . . . . . . . . . . . . . . . return the zero 
**
*/


Obj ZeroMacfloat( Obj f )
{
  return NEW_MACFLOAT((Double)0.0);
}

/****************************************************************************
**
*F  AinvMacfloat(<macfloat> ) . . . . . . . . . . . . . . . . . . . unary minus 
**
*/


Obj AInvMacfloat( Obj f )
{
  return NEW_MACFLOAT(-VAL_MACFLOAT(f));
}

/****************************************************************************
**
*F  OneMacfloat(<macfloat> ) . . . . . . . . . . . . . . . . . . . return the one 
**
*/


Obj OneMacfloat( Obj f )
{
  return NEW_MACFLOAT((Double)1.0);
}

/****************************************************************************
**
*F  InvMacfloat(<macfloat> ) . . . . . . . . . . . . . . . . . . . reciprocal
**
*/


Obj InvMacfloat( Obj f )
{
  return NEW_MACFLOAT((Double)1.0/VAL_MACFLOAT(f));
}

/****************************************************************************
**
*F  ProdMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . . product
**
*/


Obj ProdMacfloat( Obj fl, Obj fr )
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fl)*VAL_MACFLOAT(fr));
}

/****************************************************************************
**
*F  PowMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . exponentiation
**
*/


Obj PowMacfloat( Obj fl, Obj fr )
{
  return NEW_MACFLOAT(MATH(pow)(VAL_MACFLOAT(fl),VAL_MACFLOAT(fr)));
}

/****************************************************************************
**
*F  SumMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . .  sum
**
*/


Obj SumMacfloat( Obj fl, Obj fr )
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fl)+VAL_MACFLOAT(fr));
}

/****************************************************************************
**
*F  DiffMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . difference
**
*/


Obj DiffMacfloat( Obj fl, Obj fr )
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fl)-VAL_MACFLOAT(fr));
}

/****************************************************************************
**
*F  QuoMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . quotient
**
*/


Obj QuoMacfloat( Obj fl, Obj fr )
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fl)/VAL_MACFLOAT(fr));
}

/****************************************************************************
**
*F  LQuoMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . .left quotient
**
*/


Obj LQuoMacfloat( Obj fl, Obj fr )
{
  return NEW_MACFLOAT(VAL_MACFLOAT(fr)/VAL_MACFLOAT(fl));
}

/****************************************************************************
**
*F  ModMacfloat(<macfloatl>, <macfloatr> ) . . . . . . . . . . . . . . .mod
**
*/


Obj ModMacfloat( Obj fl, Obj fr )
{
  return NEW_MACFLOAT(MATH(fmod)(VAL_MACFLOAT(fl),VAL_MACFLOAT(fr)));
}


/****************************************************************************
**
*F  FuncMACFLOAT_INT(<int>) . . . . . . . . . . . . . . . conversion
**
*/

Obj FuncMACFLOAT_INT( Obj self, Obj i )
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

Obj FuncMACFLOAT_STRING( Obj self, Obj s )
{

  while (!IsStringConv(s))
    {
      s = ErrorReturnObj("MACFLOAT_STRING: object to be converted must be a string not a %s",
			 (Int)(InfoBags[TNUM_OBJ(s)].name),0,"You can return a string to continue" );
    }
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

Obj SumIntMacfloat( Obj i, Obj f )
{
  return NEW_MACFLOAT( (Double)(INT_INTOBJ(i)) + VAL_MACFLOAT(f));
}


/****************************************************************************
**
*F FuncSIN_MACFLOAT( <self>, <macfloat> ) . .The sin function from the math library
**
*/

#define MAKEMATHPRIMITIVE(NAME,name)			\
  Obj Func##NAME##_MACFLOAT( Obj self, Obj f )		\
  {							\
    return NEW_MACFLOAT(MATH(name)(VAL_MACFLOAT(f)));	\
  }

#define MAKEMATHPRIMITIVE2(NAME,name)					\
  Obj Func##NAME##_MACFLOAT( Obj self, Obj f, Obj g)			\
  {									\
    return NEW_MACFLOAT(MATH(name)(VAL_MACFLOAT(f),VAL_MACFLOAT(g)));	\
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

extern Obj FuncIntHexString(Obj,Obj);

Obj FuncINTFLOOR_MACFLOAT( Obj self, Obj obj )
{
#ifdef HAVE_TRUNC
  Double f = trunc(VAL_MACFLOAT(obj));
#else
  Double f = VAL_MACFLOAT(obj);
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
  if (f < 0.0)
    f = -f, s[0] = '-';
  while (p > s || (p == s && s[0] != '-')) {
    int d = (int) fmod(f,16.0);
    *p-- = d < 10 ? '0'+d : 'a'+d-10;
    f /= 16.0;
  }
  return FuncIntHexString(self,str);
}

Obj FuncSTRING_DIGITS_MACFLOAT( Obj self, Obj gapprec, Obj f)
{
  Char buf[50];
  Obj str;
  int prec = INT_INTOBJ(gapprec);
  if (prec > 40) /* too much anyways, and would risk buffer overrun */
    prec = 40;
  snprintf(buf, sizeof(buf), "%.*" PRINTFFORMAT, prec, (TOPRINTFFORMAT)VAL_MACFLOAT(f));
  str = MakeString(buf);
  return str;
}

Obj FuncSTRING_MACFLOAT( Obj self, Obj f) /* backwards compatibility */
{
  return FuncSTRING_DIGITS_MACFLOAT(self,INTOBJ_INT(PRINTFDIGITS),f);
}

Obj FuncLDEXP_MACFLOAT( Obj self, Obj f, Obj i)
{
  return NEW_MACFLOAT(ldexp(VAL_MACFLOAT(f),INT_INTOBJ(i)));
}

Obj FuncFREXP_MACFLOAT( Obj self, Obj f)
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
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


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
  GVAR_FUNC(STRING_MACFLOAT, 1, "macfloat"),

  GVAR_FUNC(STRING_DIGITS_MACFLOAT, 2, "digits, macfloat"),
  GVAR_FUNC(EQ_MACFLOAT, 2, "x, y"),
  { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
extern Int EqObject (Obj,Obj);

static Int InitKernel (
    StructInitInfo *    module )
{
    /* install the marking functions for macfloatean values                    */
    InfoBags[ T_MACFLOAT ].name = "macfloat";
    InitMarkFuncBags( T_MACFLOAT, MarkNoSubBags );
    MakeBagTypePublic( T_MACFLOAT );

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
    {
      int t;
      for (t = T_INT; t <= T_CYC; t++)
	EqFuncs[T_MACFLOAT][t] = EqFuncs[t][T_MACFLOAT] = EqObject;
    }

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
