/****************************************************************************
**
*W  bool.c                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions for the boolean package.
*/
#include        "system.h"              /* system dependent part           */

SYS_CONST char * Revision_bool_c =
   "@(#)$Id$";

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling                  */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations package      */

#include        "ariths.h"              /* basic arithmetic                */

#define INCLUDE_DECLARATION_PART
#include        "bool.h"                /* booleans                        */
#undef  INCLUDE_DECLARATION_PART


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

*F  TypeBool( <bool> )  . . . . . . . . . . . . . . . kind of a boolean value
**
**  'TypeBool' returns the kind of boolean values.
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
**  'LtBool' return  'True'  if the boolean   value <boolL> is less  than the
**  boolean value <boolR> and 'False' otherwise.
*/
Int LtBool (
    Obj                 boolL,
    Obj                 boolR )
{
    if ( boolL == True && boolR == False ) {
        return 1L;
    }
    else {
        return 0L;
    }
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

*F  ReturnTrueFunc  . . . . . . . . . . . . . .  function that returns 'True'
*/
Obj ReturnTrueFunc;


/****************************************************************************
**
*f  ReturnTrue1( <val1> ) . . . . . . . . . . . . . . . . . .  return  'True'
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
*f  ReturnTrue2( <val1>, <val2> ) . . . . . . . . . . . . . .  return  'True'
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
*f  ReturnTrue3( <val1>, <val2>, <val3> ) . . . . . . . . . .  return  'True'
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
*F  ReturnFalseFunc . . . . . . . . . . . . . . function that returns 'False'
*/
Obj ReturnFalseFunc;


/****************************************************************************
**
*f  ReturnFalse1( <val1> )  . . . . . . . . . . . . . . . . .  return 'False'
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
*f  ReturnFalse2( <val1>, <val2> )  . . . . . . . . . . . . .  return 'False'
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
*f  ReturnFalse3( <val1>, <val2>, <val3> )  . . . . . . . . .  return 'False'
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
*F  ReturnFailFunc  . . . . . . . . . . . . . .  function that returns 'Fail'
*/
Obj ReturnFailFunc;


/****************************************************************************
**
*f  ReturnFail1( <val1> ) . . . . . . . . . . . . . . . . . .  return  'Fail'
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
*f  ReturnFail2( <val1>, <val2> ) . . . . . . . . . . . . . .  return  'Fail'
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
*f  ReturnFail3( <val1>, <val2>, <val3> ) . . . . . . . . . .  return  'Fail'
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

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*E  InitBool()  . . . . . . . . . . . . . . . initialize the booleans package
**
**  'InitBool' initializes the boolean package.
*/
void InitBool ( void )
{
    UInt            gvar;

    /* install the marking functions for boolean values                    */
    InfoBags[         T_BOOL ].name = "boolean";
    InitMarkFuncBags( T_BOOL, MarkNoSubBags );


    /* install the kind function                                           */
    ImportGVarFromLibrary( "TYPE_BOOL", &TYPE_BOOL );
    TypeObjFuncs[ T_BOOL ] = TypeBool;


    /* install the printer for boolean values                              */
    PrintObjFuncs[ T_BOOL ] = PrintBool;


    /* install the comparison functions                                    */
    EqFuncs[ T_BOOL ][ T_BOOL ] = EqBool;
    LtFuncs[ T_BOOL ][ T_BOOL ] = LtBool;


    /* make the three boolean bags                                         */
    InitGlobalBag( &True,  "TRUE"  ); True  = NewBag( T_BOOL, 0L );
    InitGlobalBag( &False, "FALSE" ); False = NewBag( T_BOOL, 0L );
    InitGlobalBag( &Fail,  "FAIL"  ); Fail  = NewBag( T_BOOL, 0L );

    gvar = GVarName( "fail" );
    AssGVar( gvar, Fail );
    MakeReadOnlyGVar(gvar);


    /* make and install the 'IS_BOOL' filter*/
    C_NEW_GVAR_FILT( "IS_BOOL", "obj", IsBoolFilt, IsBoolHandler,
          "src/bool.c:IS_BOOL" );


    /* make and install the 'RETURN_TRUE' function                         */
    InitHandlerFunc( ReturnTrue1, "src/bool.c:ReturnTrue1");
    InitHandlerFunc( ReturnTrue2, "src/bool.c:ReturnTrue2");
    InitHandlerFunc( ReturnTrue3, "src/bool.c:ReturnTrue");

    ReturnTrueFunc = NewFunctionC( "RETURN_TRUE", -1L, "args", ReturnTrue1 );
    HDLR_FUNC( ReturnTrueFunc, 1 ) = ReturnTrue1;
    HDLR_FUNC( ReturnTrueFunc, 2 ) = ReturnTrue2;
    HDLR_FUNC( ReturnTrueFunc, 3 ) = ReturnTrue3;
    AssGVar( GVarName( "RETURN_TRUE" ), ReturnTrueFunc );


    /* make and install the 'RETURN_FALSE' function                        */
    InitHandlerFunc( ReturnFalse1, "src/bool.c:ReturnFalse1");
    InitHandlerFunc( ReturnFalse2, "src/bool.c:ReturnFalse2");
    InitHandlerFunc( ReturnFalse3, "src/bool.c:ReturnFalse3");

    ReturnFalseFunc = NewFunctionC("RETURN_FALSE",-1L,"args",ReturnFalse1);
    HDLR_FUNC( ReturnFalseFunc, 1 ) = ReturnFalse1;
    HDLR_FUNC( ReturnFalseFunc, 2 ) = ReturnFalse2;
    HDLR_FUNC( ReturnFalseFunc, 3 ) = ReturnFalse3;
    AssGVar( GVarName( "RETURN_FALSE" ), ReturnFalseFunc );


    /* make and install the 'RETURN_FAIL' function                        */
    InitHandlerFunc( ReturnFail1, "src/bool.c:ReturnFail1");
    InitHandlerFunc( ReturnFail2, "src/bool.c:ReturnFail2");
    InitHandlerFunc( ReturnFail3, "src/bool.c:ReturnFail3");

    ReturnFailFunc = NewFunctionC("RETURN_FAIL", -1L, "args", ReturnFail1);
    HDLR_FUNC( ReturnFailFunc, 1 ) = ReturnFail1;
    HDLR_FUNC( ReturnFailFunc, 2 ) = ReturnFail2;
    HDLR_FUNC( ReturnFailFunc, 3 ) = ReturnFail3;
    AssGVar( GVarName( "RETURN_FAIL" ), ReturnFailFunc );
}

/****************************************************************************
**

*E  bool.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
