/****************************************************************************
**
*W  float.c                      GAP source                      Steve Linton
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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

#define VAL_FLOAT(obj) (*(Double *)ADDR_OBJ(obj))
#define SET_VAL_FLOAT(obj, val) (*(Double *)ADDR_OBJ(obj) = val)
#define IS_FLOAT(obj) (TNUM_OBJ(obj) == T_FLOAT)

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
  return VAL_FLOAT(floatL) = VAL_FLOAT(floatR);
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
    UInt            gvar;
    Obj             tmp;

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );

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
