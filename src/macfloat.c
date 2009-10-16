/****************************************************************************
**
*W  macfloat.c                      GAP source                      Steve Linton
**
*H  @(#)$Id: macfloat.c,v 4.1 2008/04/20 19:47:01 gap Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions for the macfloat package.
**
** macfloats are stored as bags containing a 64 bit value
*/
#include        "system.h"              /* system dependent part           */

const char * Revision_macfloat_c =
   "@(#)$Id: macfloat.c,v 4.1 2008/04/20 19:47:01 gap Exp $";

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */

#include        "gap.h"                 /* error handling, initialisation  */


#include        "ariths.h"              /* basic arithmetic                */

#define INCLUDE_DECLARATION_PART
#include        "macfloat.h"                /* macfloateans                        */
#undef  INCLUDE_DECLARATION_PART

#include        "bool.h"
#include        "scanner.h"
#include        "string.h"

/* the following two declarations would belong in `saveload.h', but then all
 * files get macfloat dependencies */
extern Double LoadDouble( void);
extern void SaveDouble( Double d);

#ifdef HAVE_STDIO_H
#include <stdio.h>
#endif

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#include <stdlib.h>

#define VAL_MACFLOAT(obj) (*(Double *)ADDR_OBJ(obj))
#define SET_VAL_MACFLOAT(obj, val) (*(Double *)ADDR_OBJ(obj) = val)
#define IS_MACFLOAT(obj) (TNUM_OBJ(obj) == T_MACFLOAT)
#define SIZE_MACFLOAT   sizeof(Double)

/****************************************************************************
**
*F  TypeMacfloat( <macfloat> )  . . . . . . . . . . . . . . . kind of a macfloat value
**
**  'TypeMacfloat' returns the kind of macfloatean values.
**
**  'TypeMacfloat' is the function in 'TypeObjFuncs' for macfloatean values.
*/
Obj TYPE_MACFLOAT;
Obj TYPE_MACFLOAT0;

Obj TypeMacfloat (
    Obj                 val )
{
  
    return VAL_MACFLOAT(val) == 0.0L ? TYPE_MACFLOAT0 : TYPE_MACFLOAT;
}


/****************************************************************************
**
*F  PrintMacfloat( <macfloat> ) . . . . . . . . . . . . . . . . print a macfloat value
**
**  'PrintMacfloat' prints the macfloating value <macfloat>.
*/
#if SYS_MAC_MWC
#include <fp.h>
void PrintMacfloat (
    Obj                 x )
{
  Char buf[40];
  decimal dec;
  decform decf;
  	
  decf.style  = MACFLOATDECIMAL;
  decf.digits = 32;
  num2dec (&decf, VAL_MACFLOAT(x), &dec);
  dec2str (&decf, &dec, buf);
  Pr("%s",(Int)buf, 0);
}

#else

void PrintMacfloat (
    Obj                 x )
{
  Char buf[32];
  sprintf(buf, "%g",VAL_MACFLOAT(x));
  Pr("%s",(Int)buf, 0);
}
#endif



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
*F  IsMacfloatFilt( <self>, <obj> ) . . . . . . . . . .  test for a macfloatean value
**
**  'IsMacfloatFilt' implements the internal filter 'IsMacfloat'.
**
**  'IsMacfloat( <obj> )'
**
**  'IsMacfloat'  returns  'true'  if  <obj>  is   a macfloatean  value  and  'false'
**  otherwise.
*/
Obj IsMacfloatFilt;

Obj IsMacfloatHandler (
    Obj                 self,
    Obj                 obj )
{
  return IS_MACFLOAT(obj) ? True : False;
}



/****************************************************************************
**
*F  SaveMacfloat( <macfloat> ) . . . . . . . . . . . . . . . . . . . . save a Macfloatean 
**
*/

void SaveMacfloat( Obj obj )
{
  SaveDouble(VAL_MACFLOAT(obj));
  return;
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

static inline Obj NEW_MACFLOAT( Double val )
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
  return NEW_MACFLOAT(pow(VAL_MACFLOAT(fl),VAL_MACFLOAT(fr)));
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
  return NEW_MACFLOAT(fmod(VAL_MACFLOAT(fl),VAL_MACFLOAT(fr)));
}


/****************************************************************************
**
*F  FuncMACFLOAT_INT(<int>) . . . . . . . . . . . . . . . conversion
**
*/

Obj FuncMACFLOAT_INT( Obj self, Obj i)
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

Obj FuncMACFLOAT_STRING( Obj self, Obj s)
{

  while (!IsStringConv(s))
    {
      s = ErrorReturnObj("MACFLOAT_STRING: object to be converted must be a string not a %s",
			 (Int)(InfoBags[TNUM_OBJ(s)].name),0,"You can return a string to continue" );
    }
  return NEW_MACFLOAT((Double) atof((char*)CHARS_STRING(s)));
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

Obj FuncSIN_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(sin(VAL_MACFLOAT(f)));
}

Obj FuncCOS_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(cos(VAL_MACFLOAT(f)));
}

Obj FuncTAN_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(tan(VAL_MACFLOAT(f)));
}

Obj FuncASIN_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(asin(VAL_MACFLOAT(f)));
}

Obj FuncACOS_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(acos(VAL_MACFLOAT(f)));
}

Obj FuncATAN_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(atan(VAL_MACFLOAT(f)));
}

Obj FuncATAN2_MACFLOAT( Obj self, Obj f, Obj g)
{
  return NEW_MACFLOAT(atan2(VAL_MACFLOAT(f),VAL_MACFLOAT(g)));
}

Obj FuncLOG_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(log(VAL_MACFLOAT(f)));
}

Obj FuncEXP_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(exp(VAL_MACFLOAT(f)));
}

Obj FuncSQRT_MACFLOAT( Obj self, Obj f )
{
  return NEW_MACFLOAT(sqrt(VAL_MACFLOAT(f)));
}

Obj FuncRINT_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(rint(VAL_MACFLOAT(f)));
}

Obj FuncINTFLOOR_MACFLOAT( Obj self, Obj f )
{
  return INTOBJ_INT((Int)floor(VAL_MACFLOAT(f)));
}

Obj FuncFLOOR_MACFLOAT( Obj self, Obj f)
{
  return NEW_MACFLOAT(floor(VAL_MACFLOAT(f)));
}

Obj FuncSTRING_MACFLOAT( Obj self, Obj f)
{
  Char buf[32];
  Obj str;
  UInt len;
  sprintf(buf, "%g",VAL_MACFLOAT(f));
  len = SyStrlen(buf);
  str = NEW_STRING(len);
  SyStrncat(CSTR_STRING(str),buf,len);
  return str;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    { "IS_MACFLOAT", "obj", &IsMacfloatFilt,
      IsMacfloatHandler, "src/macfloat.c:IS_MACFLOAT" },

    { 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {
  { "MACFLOAT_INT", 1, "int",
    FuncMACFLOAT_INT, "src/macfloat.c:MACFLOAT_INT" },

  { "MACFLOAT_STRING", 1, "string",
    FuncMACFLOAT_STRING, "src/macfloat.c:MACFLOAT_STRING" },

  { "SIN_MACFLOAT", 1, "macfloat",
    FuncSIN_MACFLOAT, "src/macfloat.c:SIN_MACFLOAT" },

  { "COS_MACFLOAT", 1, "macfloat",
    FuncCOS_MACFLOAT, "src/macfloat.c:COS_MACFLOAT" },

  { "TAN_MACFLOAT", 1, "macfloat",
    FuncTAN_MACFLOAT, "src/macfloat.c:TAN_MACFLOAT" },

  { "ASIN_MACFLOAT", 1, "macfloat",
    FuncASIN_MACFLOAT, "src/macfloat.c:ASIN_MACFLOAT" },

  { "ACOS_MACFLOAT", 1, "macfloat",
    FuncACOS_MACFLOAT, "src/macfloat.c:ACOS_MACFLOAT" },

  { "ATAN_MACFLOAT", 1, "macfloat",
    FuncATAN_MACFLOAT, "src/macfloat.c:ATAN_MACFLOAT" },

  { "ATAN2_MACFLOAT", 2, "real, imag",
    FuncATAN2_MACFLOAT, "src/macfloat.c:ATAN2_MACFLOAT" },

  { "LOG_MACFLOAT", 1, "macfloat",
    FuncLOG_MACFLOAT, "src/macfloat.c:LOG_MACFLOAT" },

  { "EXP_MACFLOAT", 1, "macfloat",
    FuncEXP_MACFLOAT, "src/macfloat.c:EXP_MACFLOAT" },

  { "SQRT_MACFLOAT", 1, "macfloat",
    FuncSQRT_MACFLOAT, "src/macfloat.c:SQRT_MACFLOAT" },

  { "RINT_MACFLOAT", 1, "macfloat",
    FuncRINT_MACFLOAT, "src/macfloat.c:RINT_MACFLOAT" },

  { "INTFLOOR_MACFLOAT", 1, "macfloat",
    FuncINTFLOOR_MACFLOAT, "src/macfloat.c:INTFLOOR_MACFLOAT" },

  { "FLOOR_MACFLOAT", 1, "macfloat",
    FuncFLOOR_MACFLOAT, "src/macfloat.c:FLOOR_MACFLOAT" },

  { "STRING_MACFLOAT", 1, "macfloat",
    FuncSTRING_MACFLOAT, "src/macfloat.c:STRING_MACFLOAT" },

  {0}
};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* install the marking functions for macfloatean values                    */
    InfoBags[ T_MACFLOAT ].name = "macfloat";
    InitMarkFuncBags( T_MACFLOAT, MarkNoSubBags );

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* install the kind function                                           */
    ImportGVarFromLibrary( "TYPE_MACFLOAT", &TYPE_MACFLOAT );
    ImportGVarFromLibrary( "TYPE_MACFLOAT0", &TYPE_MACFLOAT0 );
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
/*  UInt            gvar; */
/*  Obj             tmp;  */

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoMacfloat()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "macfloat",                             /* name                           */
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

StructInitInfo * InitInfoMacfloat ( void )
{
    module.revision_c = Revision_macfloat_c;
    module.revision_h = Revision_macfloat_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  macfloat.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
