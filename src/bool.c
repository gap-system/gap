/****************************************************************************
**
*W  bool.c                      GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions for the boolean package.
**
**  Note that boolean objects actually contain no data. The three of them
**  are distinguished by their addresses, kept in the C globals False, 
**  True and Fail.
*/
#include <src/system.h>                 /* system dependent part */


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */
#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/bool.h>                   /* booleans */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/stringobj.h>              /* strings */

#include <src/code.h>                   /* coder */


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
*V  SuPeRfail  . . . . . . . . . . . . . . . . . . . . . . .  superfail value
**
**  'SuPeRfail' is an ``superfail'' object which is used to indicate failure if
**  `fail' itself is a sensible response. This is used when having GAP read
**  a file line-by-line via a library function (demo.g)
*/
Obj SuPeRfail;

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
Obj TYPE_BOOL;

Obj TypeBool (
    Obj                 val )
{
    return TYPE_BOOL;
}


/****************************************************************************
**
*F  PrintBool( <bool> ) . . . . . . . . . . . . . . . . print a boolean value
**
**  'PrintBool' prints the boolean value <bool>.
*/
void PrintBool (
    Obj                 bool )
{
    if ( bool == True ) {
        Pr( "true", 0L, 0L );
    }
    else if ( bool == False ) {
        Pr( "false", 0L, 0L );
    }
    else if ( bool == Fail ) {
        Pr( "fail", 0L, 0L );
    }
    else if ( bool == SuPeRfail ) {
        Pr( "SuPeRfail", 0L, 0L );
    }
    else if ( bool == Undefined ) {
        Pr( "Undefined", 0L, 0L );
    }
    else {
        Pr( "<<very strange boolean value>>", 0L, 0L );
    }
}


/****************************************************************************
**
*F  EqBool( <boolL>, <boolR> )  . . . . . . . . .  test if <boolL> =  <boolR>
**
**  'EqBool' returns 'True' if the two boolean values <boolL> and <boolR> are
**  equal, and 'False' otherwise.
*/
Int EqBool (
    Obj                 boolL,
    Obj                 boolR )
{
    if ( boolL == boolR ) {
        return 1L;
    }
    else {
        return 0L;
    }
}


/****************************************************************************
**
*F  LtBool( <boolL>, <boolR> )  . . . . . . . . .  test if <boolL> <  <boolR>
**
**  The ordering of Booleans is true < false <= fail (the <= comes from
**  the fact that Fail may be equal to False in some compatibility modes
*/
Int LtBool (
    Obj                 boolL,
    Obj                 boolR )
{
  return  ( boolL == True && boolR != True) ||
    ( boolL == False && boolR == Fail && boolL != boolR);
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
Obj IsBoolFilt;

Obj IsBoolHandler (
    Obj                 self,
    Obj                 obj )
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
Obj ReturnTrue1 (
    Obj                 self,
    Obj                 val1 )
{
    return True;
}


/****************************************************************************
**
*F  ReturnTrue2( <val1>, <val2> ) . . . . . . . . . . . . . .  return  'True'
*/
Obj ReturnTrue2 (
    Obj                 self,
    Obj                 val1,
    Obj                 val2 )
{
    return True;
}


/****************************************************************************
**
*F  ReturnTrue3( <val1>, <val2>, <val3> ) . . . . . . . . . .  return  'True'
*/
Obj ReturnTrue3 (
    Obj                 self,
    Obj                 val1,
    Obj                 val2,
    Obj                 val3 )
{
    return True;
}


/****************************************************************************
**
*F  ReturnFalse1( <val1> )  . . . . . . . . . . . . . . . . .  return 'False'
**
**  'ReturnFalse?' likewise return 'False'.
*/
Obj ReturnFalse1 (
    Obj                 self,
    Obj                 val1 )
{
    return False;
}


/****************************************************************************
**
*F  ReturnFalse2( <val1>, <val2> )  . . . . . . . . . . . . .  return 'False'
*/
Obj ReturnFalse2 (
    Obj                 self,
    Obj                 val1,
    Obj                 val2 )
{
    return False;
}


/****************************************************************************
**
*F  ReturnFalse3( <val1>, <val2>, <val3> )  . . . . . . . . .  return 'False'
*/
Obj ReturnFalse3 (
    Obj                 self,
    Obj                 val1,
    Obj                 val2,
    Obj                 val3 )
{
    return False;
}


/****************************************************************************
**
*F  ReturnFail1( <val1> ) . . . . . . . . . . . . . . . . . .  return  'Fail'
**
**  'ReturnFail?' likewise return 'Fail'.
*/
Obj ReturnFail1 (
    Obj                 self,
    Obj                 val1 )
{
    return Fail;
}


/****************************************************************************
**
*F  ReturnFail2( <val1>, <val2> ) . . . . . . . . . . . . . .  return  'Fail'
*/
Obj ReturnFail2 (
    Obj                 self,
    Obj                 val1,
    Obj                 val2 )
{
    return Fail;
}


/****************************************************************************
**
*F  ReturnFail3( <val1>, <val2>, <val3> ) . . . . . . . . . .  return  'Fail'
*/
Obj ReturnFail3 (
    Obj                 self,
    Obj                 val1,
    Obj                 val2,
    Obj                 val3 )
{
    return Fail;
}


/****************************************************************************
**
*F  SaveBool( <bool> ) . . . . . . . . . . . . . . . . . . . . save a Boolean 
**
**  Actually, there is nothing to do
*/

void SaveBool( Obj obj )
{
}

/****************************************************************************
**
*F  LoadBool( <bool> ) . . . . . . . . . . . . . . . . . . . . save a Boolean 
**
**  Actually, there is nothing to do
*/

void LoadBool( Obj obj )
{
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

    { "IS_BOOL", "obj", &IsBoolFilt,
      IsBoolHandler, "src/bool.c:IS_BOOL" },

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* install the marking functions for boolean values                    */
    InfoBags[ T_BOOL ].name = "boolean or fail";
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
    InitGlobalBag( &SuPeRfail,  "src/bool.c:SUPERFAIL"  );
    InitGlobalBag( &Undefined,  "src/bool.c:UNDEFINED"  );

    /* install the saving functions                                       */
    SaveObjFuncs[ T_BOOL ] = SaveBool;

    /* install the loading functions                                       */
    LoadObjFuncs[ T_BOOL ] = LoadBool;

    /* install the printer for boolean values                              */
    PrintObjFuncs[ T_BOOL ] = PrintBool;

    /* install the comparison functions                                    */
    EqFuncs[ T_BOOL ][ T_BOOL ] = EqBool;
    LtFuncs[ T_BOOL ][ T_BOOL ] = LtBool;

    MakeBagTypePublic(T_BOOL);
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

    /* bags are registered in 'InitKernel'                                 */
    True  = NewBag( T_BOOL, 0L );
    False = NewBag( T_BOOL, 0L );
    Fail  = NewBag( T_BOOL, 0L );

    /* `fail' is a variable not a language construct                       */
    gvar = GVarName( "fail" );
    AssGVar( gvar, Fail );
    MakeReadOnlyGVar(gvar);

    /* `SuPeRfail' ditto                       */
    SuPeRfail  = NewBag( T_BOOL, 0L );
    gvar = GVarName( "SuPeRfail" );
    AssGVar( gvar, SuPeRfail );
    MakeReadOnlyGVar(gvar);

    /* Undefined is an internal value */
    Undefined = NewBag( T_BOOL, 0 );

    /* make and install the 'RETURN_TRUE' function                         */
    tmp = NewFunctionC( "RETURN_TRUE", -1L, "arg", ReturnTrue1 );
    SET_HDLR_FUNC( tmp, 1, ReturnTrue1);
    SET_HDLR_FUNC( tmp, 2, ReturnTrue2);
    SET_HDLR_FUNC( tmp, 3, ReturnTrue3);
    AssGVar( GVarName("RETURN_TRUE"), tmp );

    /* make and install the 'RETURN_FALSE' function                        */
    tmp = NewFunctionC("RETURN_FALSE",-1L,"arg",ReturnFalse1);
    SET_HDLR_FUNC( tmp, 1, ReturnFalse1);
    SET_HDLR_FUNC( tmp, 2, ReturnFalse2);
    SET_HDLR_FUNC( tmp, 3, ReturnFalse3);
    AssGVar( GVarName( "RETURN_FALSE" ), tmp );

    /* make and install the 'RETURN_FAIL' function                        */
    tmp = NewFunctionC("RETURN_FAIL", -1L, "arg", ReturnFail1);
    SET_HDLR_FUNC( tmp, 1, ReturnFail1);
    SET_HDLR_FUNC( tmp, 2, ReturnFail2);
    SET_HDLR_FUNC( tmp, 3, ReturnFail3);
    AssGVar( GVarName( "RETURN_FAIL" ), tmp );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoBool()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "bool",                             /* name                           */
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

StructInitInfo * InitInfoBool ( void )
{
    return &module;
}
