/****************************************************************************
**
*W  float.c                      GAP source                      Steve Linton
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions for the float package.
**
** floats are stored as bags containing a 64 bit value
*/
#include        "system.h"              /* system dependent part           */

const char * Revision_float_c =
   "@(#)$Id$";

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */

#include        "gap.h"                 /* error handling, initialisation  */


#include        "ariths.h"              /* basic arithmetic                */

#define INCLUDE_DECLARATION_PART
#include        "float.h"                /* floateans                        */
#undef  INCLUDE_DECLARATION_PART

#include        "bool.h"
#include        "scanner.h"
#include        "string.h"

/* the following two declarations would belong in `saveload.h', but then all
 * files get float dependencies */
extern Double LoadDouble( void);
extern void SaveDouble( Double d);

#ifdef HAVE_STDIO_H
#include <stdio.h>
#endif

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#include <stdlib.h>

#define VAL_FLOAT(obj) (*(Double *)ADDR_OBJ(obj))
#define SET_VAL_FLOAT(obj, val) (*(Double *)ADDR_OBJ(obj) = val)
#define IS_FLOAT(obj) (TNUM_OBJ(obj) == T_FLOAT)
#define SIZE_FLOAT   sizeof(Double)

/****************************************************************************
**
*F  TypeFloat( <float> )  . . . . . . . . . . . . . . . kind of a float value
**
**  'TypeFloat' returns the kind of floatean values.
**
**  'TypeFloat' is the function in 'TypeObjFuncs' for floatean values.
*/
Obj TYPE_FLOAT;
Obj TYPE_FLOAT0;

Obj TypeFloat (
    Obj                 val )
{
  
    return VAL_FLOAT(val) == 0.0L ? TYPE_FLOAT0 : TYPE_FLOAT;
}


/****************************************************************************
**
*F  PrintFloat( <float> ) . . . . . . . . . . . . . . . . print a float value
**
**  'PrintFloat' prints the floating value <float>.
*/
#if SYS_MAC_MWC
#include <fp.h>
void PrintFloat (
    Obj                 x )
{
  Char buf[40];
  decimal dec;
  decform decf;
  	
  decf.style  = FLOATDECIMAL;
  decf.digits = 32;
  num2dec (&decf, VAL_FLOAT(x), &dec);
  dec2str (&decf, &dec, buf);
  Pr("%s",(Int)buf, 0);
}

#else

void PrintFloat (
    Obj                 x )
{
  Char buf[32];
  sprintf(buf, "%g",VAL_FLOAT(x));
  Pr("%s",(Int)buf, 0);
}
#endif



/****************************************************************************
**
*F  EqFloat( <floatL>, <floatR> )  . . . . . . . . .  test if <floatL> =  <floatR>
**
**  'EqFloat' returns 'True' if the two floatean values <floatL> and <floatR> are
**  equal, and 'False' otherwise.
*/
Int EqFloat (
    Obj                 floatL,
    Obj                 floatR )
{
  return VAL_FLOAT(floatL) == VAL_FLOAT(floatR);
}


/****************************************************************************
**
*F  LtFloat( <floatL>, <floatR> )  . . . . . . . . .  test if <floatL> <  <floatR>
**
*/
Int LtFloat (
    Obj                 floatL,
    Obj                 floatR )
{
  return VAL_FLOAT(floatL) < VAL_FLOAT(floatR);
}


/****************************************************************************
**
*F  IsFloatFilt( <self>, <obj> ) . . . . . . . . . .  test for a floatean value
**
**  'IsFloatFilt' implements the internal filter 'IsFloat'.
**
**  'IsFloat( <obj> )'
**
**  'IsFloat'  returns  'true'  if  <obj>  is   a floatean  value  and  'false'
**  otherwise.
*/
Obj IsFloatFilt;

Obj IsFloatHandler (
    Obj                 self,
    Obj                 obj )
{
  return IS_FLOAT(obj) ? True : False;
}



/****************************************************************************
**
*F  SaveFloat( <float> ) . . . . . . . . . . . . . . . . . . . . save a Floatean 
**
*/

void SaveFloat( Obj obj )
{
  SaveDouble(VAL_FLOAT(obj));
  return;
}

/****************************************************************************
**
*F  LoadFloat( <float> ) . . . . . . . . . . . . . . . . . . . . save a Floatean 
**
*/

void LoadFloat( Obj obj )
{
  SET_VAL_FLOAT(obj, LoadDouble());
}

static inline Obj NEW_FLOAT( Double val )
{
  Obj f;
  f = NewBag(T_FLOAT,SIZE_FLOAT);
  SET_VAL_FLOAT(f,val);
  return f;
}

/****************************************************************************
**
*F  ZeroFloat(<float> ) . . . . . . . . . . . . . . . . . . . return the zero 
**
*/


Obj ZeroFloat( Obj f )
{
  return NEW_FLOAT((Double)0.0);
}

/****************************************************************************
**
*F  AinvFloat(<float> ) . . . . . . . . . . . . . . . . . . . unary minus 
**
*/


Obj AInvFloat( Obj f )
{
  return NEW_FLOAT(-VAL_FLOAT(f));
}

/****************************************************************************
**
*F  OneFloat(<float> ) . . . . . . . . . . . . . . . . . . . return the one 
**
*/


Obj OneFloat( Obj f )
{
  return NEW_FLOAT((Double)1.0);
}

/****************************************************************************
**
*F  InvFloat(<float> ) . . . . . . . . . . . . . . . . . . . reciprocal
**
*/


Obj InvFloat( Obj f )
{
  return NEW_FLOAT((Double)1.0/VAL_FLOAT(f));
}

/****************************************************************************
**
*F  ProdFloat(<floatl>, <floatr> ) . . . . . . . . . . . . . . . product
**
*/


Obj ProdFloat( Obj fl, Obj fr )
{
  return NEW_FLOAT(VAL_FLOAT(fl)*VAL_FLOAT(fr));
}

/****************************************************************************
**
*F  PowFloat(<floatl>, <floatr> ) . . . . . . . . . . . . . . exponentiation
**
*/


Obj PowFloat( Obj fl, Obj fr )
{
  return NEW_FLOAT(pow(VAL_FLOAT(fl),VAL_FLOAT(fr)));
}

/****************************************************************************
**
*F  SumFloat(<floatl>, <floatr> ) . . . . . . . . . . . . . .  sum
**
*/


Obj SumFloat( Obj fl, Obj fr )
{
  return NEW_FLOAT(VAL_FLOAT(fl)+VAL_FLOAT(fr));
}

/****************************************************************************
**
*F  DiffFloat(<floatl>, <floatr> ) . . . . . . . . . . . . . . difference
**
*/


Obj DiffFloat( Obj fl, Obj fr )
{
  return NEW_FLOAT(VAL_FLOAT(fl)-VAL_FLOAT(fr));
}

/****************************************************************************
**
*F  QuoFloat(<floatl>, <floatr> ) . . . . . . . . . . . . . . quotient
**
*/


Obj QuoFloat( Obj fl, Obj fr )
{
  return NEW_FLOAT(VAL_FLOAT(fl)/VAL_FLOAT(fr));
}

/****************************************************************************
**
*F  LQuoFloat(<floatl>, <floatr> ) . . . . . . . . . . . . . .left quotient
**
*/


Obj LQuoFloat( Obj fl, Obj fr )
{
  return NEW_FLOAT(VAL_FLOAT(fr)/VAL_FLOAT(fl));
}

/****************************************************************************
**
*F  ModFloat(<floatl>, <floatr> ) . . . . . . . . . . . . . . .mod
**
*/


Obj ModFloat( Obj fl, Obj fr )
{
  return NEW_FLOAT(fmod(VAL_FLOAT(fl),VAL_FLOAT(fr)));
}


/****************************************************************************
**
*F  FuncFLOAT_INT(<int>) . . . . . . . . . . . . . . . conversion
**
*/

Obj FuncFLOAT_INT( Obj self, Obj i)
{
  if (!IS_INTOBJ(i))
    return Fail;
  else
    return NEW_FLOAT((Double)INT_INTOBJ(i));
}

/****************************************************************************
**
*F  FuncFLOAT_STRING(<string>) . . . . . . . . . . . . . . . conversion
**
*/

Obj FuncFLOAT_STRING( Obj self, Obj s)
{

  while (!IsStringConv(s))
    {
      s = ErrorReturnObj("FLOAT_STRING: object to be converted must be a string not a %s",
			 (Int)(InfoBags[TNUM_OBJ(s)].name),0,"You can return a string to continue" );
    }
  return NEW_FLOAT((Double) atof((char*)CHARS_STRING(s)));
}

/****************************************************************************
**
*F SumIntFloat( <int>, <float> )
**
*/

Obj SumIntFloat( Obj i, Obj f )
{
  return NEW_FLOAT( (Double)(INT_INTOBJ(i)) + VAL_FLOAT(f));
}


/****************************************************************************
**
*F FuncSIN_FLOAT( <self>, <float> ) . .The sin function from the math library
**
*/

Obj FuncSIN_FLOAT( Obj self, Obj f)
{
  return NEW_FLOAT(sin(VAL_FLOAT(f)));
}

Obj FuncLOG_FLOAT( Obj self, Obj f)
{
  return NEW_FLOAT(log(VAL_FLOAT(f)));
}

Obj FuncEXP_FLOAT( Obj self, Obj f)
{
  return NEW_FLOAT(exp(VAL_FLOAT(f)));
}

Obj FuncRINT_FLOAT( Obj self, Obj f)
{
  return NEW_FLOAT(rint(VAL_FLOAT(f)));
}

Obj FuncFLOOR_FLOAT( Obj self, Obj f)
{
  return NEW_FLOAT(floor(VAL_FLOAT(f)));
}

Obj FuncSTRING_FLOAT( Obj self, Obj f)
{
  Char buf[32];
  Obj str;
  UInt len;
  sprintf(buf, "%g",VAL_FLOAT(f));
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

    { "IS_FLOAT", "obj", &IsFloatFilt,
      IsFloatHandler, "src/float.c:IS_FLOAT" },

    { 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {
  { "FLOAT_INT", 1, "int",
    FuncFLOAT_INT, "src/float.c:FLOAT_INT" },

  { "FLOAT_STRING", 1, "int",
    FuncFLOAT_STRING, "src/float.c:FLOAT_STRING" },

  { "SIN_FLOAT", 1, "float",
    FuncSIN_FLOAT, "src/float.c:SIN_FLOAT" },

  { "LOG_FLOAT", 1, "float",
    FuncLOG_FLOAT, "src/float.c:LOG_FLOAT" },

  { "EXP_FLOAT", 1, "float",
    FuncEXP_FLOAT, "src/float.c:EXP_FLOAT" },

  { "RINT_FLOAT", 1, "float",
    FuncRINT_FLOAT, "src/float.c:RINT_FLOAT" },

  { "FLOOR_FLOAT", 1, "float",
    FuncFLOOR_FLOAT, "src/float.c:FLOOR_FLOAT" },

  { "STRING_FLOAT", 1, "float",
    FuncSTRING_FLOAT, "src/float.c:STRING_FLOAT" },



  {0}
};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* install the marking functions for floatean values                    */
    InfoBags[ T_FLOAT ].name = "float";
    InitMarkFuncBags( T_FLOAT, MarkNoSubBags );

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* install the kind function                                           */
    ImportGVarFromLibrary( "TYPE_FLOAT", &TYPE_FLOAT );
    ImportGVarFromLibrary( "TYPE_FLOAT0", &TYPE_FLOAT0 );
    TypeObjFuncs[ T_FLOAT ] = TypeFloat;

    /* install the saving functions                                       */
    SaveObjFuncs[ T_FLOAT ] = SaveFloat;

    /* install the loading functions                                       */
    LoadObjFuncs[ T_FLOAT ] = LoadFloat;

    /* install the printer for floatean values                              */
    PrintObjFuncs[ T_FLOAT ] = PrintFloat;

    /* install the comparison functions                                    */
    EqFuncs[ T_FLOAT ][ T_FLOAT ] = EqFloat;
    LtFuncs[ T_FLOAT ][ T_FLOAT ] = LtFloat;
    
    /* install the unary arithmetic methods                                */
    ZeroFuncs[ T_FLOAT ] = ZeroFloat;
    ZeroMutFuncs[ T_FLOAT ] = ZeroFloat;
    AInvMutFuncs[ T_FLOAT ] = AInvFloat;
    OneFuncs [ T_FLOAT ] = OneFloat;
    OneMutFuncs [ T_FLOAT ] = OneFloat;
    InvFuncs [ T_FLOAT ] = InvFloat;

    /* install binary arithmetic methods */
    ProdFuncs[ T_FLOAT ][ T_FLOAT ] = ProdFloat;
    PowFuncs [ T_FLOAT ][ T_FLOAT ] = PowFloat;
    SumFuncs[ T_FLOAT ][ T_FLOAT ] = SumFloat;
    DiffFuncs [ T_FLOAT ][ T_FLOAT ] = DiffFloat;
    QuoFuncs [ T_FLOAT ][ T_FLOAT ] = QuoFloat;
    LQuoFuncs [ T_FLOAT ][ T_FLOAT ] = LQuoFloat;
    ModFuncs [ T_FLOAT ][ T_FLOAT ] = ModFloat;
    SumFuncs [ T_INT ][ T_FLOAT ] = SumIntFloat;
    
    /* Probably support mixed ops with small ints in the kernel as well
       on any reasonable system, all small ints should have float equivalents

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
*F  InitInfoFloat()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "float",                             /* name                           */
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

StructInitInfo * InitInfoFloat ( void )
{
    module.revision_c = Revision_float_c;
    module.revision_h = Revision_float_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  float.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
