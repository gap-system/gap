/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions for the boolean package.
**
**  Note that boolean objects actually contain no data. The three of them
**  are distinguished by their addresses, kept in the C globals False, 
**  True and Fail.
*/

#include "bool.h"

#include "ariths.h"
#include "calls.h"
#include "gvars.h"
#include "io.h"
#include "modules.h"
#include "opers.h"


/****************************************************************************
**
*V  True  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  true value
**
**   'True' is the value 'true'.
*/
Obj True;


/****************************************************************************
**
*V  False . . . . . . . . . . . . . . . . . . . . . . . . . . . . false value
**
**  'False' is the value 'false'.
*/
Obj False;


/****************************************************************************
**
*V  Fail  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  fail value
**
**  'Fail' is the value 'fail'.
*/
Obj Fail;

/****************************************************************************
**
*V  Undefined  . . . . . . . . . . . . . . . . . . . . . . . undefined value
**
**  'Undefined' is a special object that is used in lieu of (Obj) 0 in places
**  where the kernel cannot handle a null reference easily. This object is
**  never exposed to GAP code and only used within the kernel.
*/
Obj Undefined;




/****************************************************************************
**
*F  TypeBool( <bool> )  . . . . . . . . . . . . . . . type of a boolean value
**
**  'TypeBool' returns the type of boolean values.
**
**  'TypeBool' is the function in 'TypeObjFuncs' for boolean values.
*/
static Obj TYPE_BOOL;

static Obj TypeBool(Obj val)
{
    return TYPE_BOOL;
}


/****************************************************************************
**
*F  PrintBool( <val> ) . . . . . . . . . . . . . . . .  print a boolean value
**
**  'PrintBool' prints the boolean value <val>.
*/
static void PrintBool(Obj val)
{
    if (val == True) {
        Pr("true", 0, 0);
    }
    else if (val == False) {
        Pr("false", 0, 0);
    }
    else if (val == Fail) {
        Pr("fail", 0, 0);
    }
    else {
        Pr("<<very strange boolean value>>", 0, 0);
    }
}


/****************************************************************************
**
*F  EqBool( <boolL>, <boolR> )  . . . . . . . . .  test if <boolL> =  <boolR>
**
**  'EqBool' returns '1' if the two boolean values <boolL> and <boolR> are
**  equal, and '0' otherwise.
*/
static Int EqBool(Obj boolL, Obj boolR)
{
    return boolL == boolR;
}


/****************************************************************************
**
*F  LtBool( <boolL>, <boolR> )  . . . . . . . . .  test if <boolL> <  <boolR>
**
**  The ordering of Booleans is true < false < fail.
*/
static Int LtBool(Obj boolL, Obj boolR)
{
    if (boolL == True)
        return boolR != True;
    if (boolL == False)
        return boolR == Fail;
    return 0;
}


/****************************************************************************
**
*F  IsBoolFilt( <self>, <obj> ) . . . . . . . . . .  test for a boolean value
**
**  'IsBoolFilt' implements the internal filter 'IsBool'.
**
**  'IsBool( <obj> )'
**
**  'IsBool'  returns  'true'  if  <obj>  is   a boolean  value  and  'false'
**  otherwise.
*/
static Obj IsBoolFilt;

static Obj FiltIS_BOOL(Obj self, Obj obj)
{
    /* return 'true' if <obj> is a boolean and 'false' otherwise           */
    if ( TNUM_OBJ(obj) == T_BOOL ) {
        return True;
    }
    else if ( TNUM_OBJ(obj) < FIRST_EXTERNAL_TNUM ) {
        return False;
    }
    else {
        return DoFilter( self, obj );
    }
}


/****************************************************************************
**
*F  ReturnTrue1( <val1> ) . . . . . . . . . . . . . . . . . .  return  'True'
**
**  'ReturnTrue?'  simply return  'True'  independent of  the values of   the
**  arguments.
**
**  Those  functions are  useful for  dispatcher  tables if the types already
**  determine the outcome.
*/
static Obj ReturnTrue1(Obj self, Obj val1)
{
    return True;
}


/****************************************************************************
**
*F  ReturnTrue2( <val1>, <val2> ) . . . . . . . . . . . . . .  return  'True'
*/
static Obj ReturnTrue2(Obj self, Obj val1, Obj val2)
{
    return True;
}


/****************************************************************************
**
*F  ReturnTrue3( <val1>, <val2>, <val3> ) . . . . . . . . . .  return  'True'
*/
static Obj ReturnTrue3(Obj self, Obj val1, Obj val2, Obj val3)
{
    return True;
}


/****************************************************************************
**
*F  ReturnFalse1( <val1> )  . . . . . . . . . . . . . . . . .  return 'False'
**
**  'ReturnFalse?' likewise return 'False'.
*/
static Obj ReturnFalse1(Obj self, Obj val1)
{
    return False;
}


/****************************************************************************
**
*F  ReturnFalse2( <val1>, <val2> )  . . . . . . . . . . . . .  return 'False'
*/
static Obj ReturnFalse2(Obj self, Obj val1, Obj val2)
{
    return False;
}


/****************************************************************************
**
*F  ReturnFalse3( <val1>, <val2>, <val3> )  . . . . . . . . .  return 'False'
*/
static Obj ReturnFalse3(Obj self, Obj val1, Obj val2, Obj val3)
{
    return False;
}


/****************************************************************************
**
*F  ReturnFail1( <val1> ) . . . . . . . . . . . . . . . . . .  return  'Fail'
**
**  'ReturnFail?' likewise return 'Fail'.
*/
static Obj ReturnFail1(Obj self, Obj val1)
{
    return Fail;
}


/****************************************************************************
**
*F  ReturnFail2( <val1>, <val2> ) . . . . . . . . . . . . . .  return  'Fail'
*/
static Obj ReturnFail2(Obj self, Obj val1, Obj val2)
{
    return Fail;
}


/****************************************************************************
**
*F  ReturnFail3( <val1>, <val2>, <val3> ) . . . . . . . . . .  return  'Fail'
*/
static Obj ReturnFail3(Obj self, Obj val1, Obj val2, Obj val3)
{
    return Fail;
}


/****************************************************************************
**
*F  SaveBool( <bool> ) . . . . . . . . . . . . . . . . . . . . save a Boolean 
**
**  Actually, there is nothing to do
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveBool(Obj obj)
{
}
#endif


/****************************************************************************
**
*F  LoadBool( <bool> ) . . . . . . . . . . . . . . . . . . . . save a Boolean 
**
**  Actually, there is nothing to do
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadBool(Obj obj)
{
}
#endif


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_BOOL, "boolean or fail" },
  { -1,     "" }
};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_BOOL, "obj", &IsBoolFilt),
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

    /* install the marking functions for boolean values                    */
    InitMarkFuncBags( T_BOOL, MarkNoSubBags );

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );

    /* make and install the 'RETURN_TRUE' function                         */
    InitHandlerFunc( ReturnTrue1, "src/bool.c:ReturnTrue1" );
    InitHandlerFunc( ReturnTrue2, "src/bool.c:ReturnTrue2" );
    InitHandlerFunc( ReturnTrue3, "src/bool.c:ReturnTrue3" );

    /* make and install the 'RETURN_FALSE' function                        */
    InitHandlerFunc( ReturnFalse1, "src/bool.c:ReturnFalse1" );
    InitHandlerFunc( ReturnFalse2, "src/bool.c:ReturnFalse2" );
    InitHandlerFunc( ReturnFalse3, "src/bool.c:ReturnFalse3" );

    /* make and install the 'RETURN_FAIL' function                        */
    InitHandlerFunc( ReturnFail1, "src/bool.c:ReturnFail1" );
    InitHandlerFunc( ReturnFail2, "src/bool.c:ReturnFail2" );
    InitHandlerFunc( ReturnFail3, "src/bool.c:ReturnFail3" );

    /* install the type function                                           */
    ImportGVarFromLibrary( "TYPE_BOOL", &TYPE_BOOL );
    TypeObjFuncs[ T_BOOL ] = TypeBool;

    /* make the boolean bags                                         */
    InitGlobalBag( &True,  "src/bool.c:TRUE"  );
    InitGlobalBag( &False, "src/bool.c:FALSE" );
    InitGlobalBag( &Fail,  "src/bool.c:FAIL"  );
    InitGlobalBag( &Undefined,  "src/bool.c:UNDEFINED"  );

#ifdef GAP_ENABLE_SAVELOAD
    /* install the saving functions                                       */
    SaveObjFuncs[ T_BOOL ] = SaveBool;

    /* install the loading functions                                       */
    LoadObjFuncs[ T_BOOL ] = LoadBool;
#endif

    /* install the printer for boolean values                              */
    PrintObjFuncs[ T_BOOL ] = PrintBool;

    /* install the comparison functions                                    */
    EqFuncs[ T_BOOL ][ T_BOOL ] = EqBool;
    LtFuncs[ T_BOOL ][ T_BOOL ] = LtBool;

#ifdef HPCGAP
    MakeBagTypePublic(T_BOOL);
#endif
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    Obj             tmp;

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );

    /* bags are registered in 'InitKernel'                                 */
    True  = NewBag(T_BOOL, 0);
    False = NewBag(T_BOOL, 0);
    Fail  = NewBag(T_BOOL, 0);

    /* `fail' is a variable not a language construct                       */
    AssReadOnlyGVar( GVarName( "fail" ), Fail );

    /* Undefined is an internal value */
    Undefined = NewBag(T_BOOL, 0);

    /* make and install the 'RETURN_TRUE' function                         */
    tmp = NewFunctionC("RETURN_TRUE", -1, "arg", ReturnTrue1);
    SET_HDLR_FUNC( tmp, 1, ReturnTrue1);
    SET_HDLR_FUNC( tmp, 2, ReturnTrue2);
    SET_HDLR_FUNC( tmp, 3, ReturnTrue3);
    AssReadOnlyGVar( GVarName("RETURN_TRUE"), tmp );

    /* make and install the 'RETURN_FALSE' function                        */
    tmp = NewFunctionC("RETURN_FALSE", -1, "arg", ReturnFalse1);
    SET_HDLR_FUNC( tmp, 1, ReturnFalse1);
    SET_HDLR_FUNC( tmp, 2, ReturnFalse2);
    SET_HDLR_FUNC( tmp, 3, ReturnFalse3);
    AssReadOnlyGVar( GVarName( "RETURN_FALSE" ), tmp );

    /* make and install the 'RETURN_FAIL' function                        */
    tmp = NewFunctionC("RETURN_FAIL", -1, "arg", ReturnFail1);
    SET_HDLR_FUNC( tmp, 1, ReturnFail1);
    SET_HDLR_FUNC( tmp, 2, ReturnFail2);
    SET_HDLR_FUNC( tmp, 3, ReturnFail3);
    AssReadOnlyGVar( GVarName( "RETURN_FAIL" ), tmp );

    return 0;
}


/****************************************************************************
**
*F  InitInfoBool()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "bool",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoBool ( void )
{
    return &module;
}
