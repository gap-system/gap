/****************************************************************************
**
*W  ariths.c                    GAP source                       Frank Celler
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of the  arithmetic  operations  package.
*/
#include        "system.h"              /* system dependent part           */

SYS_CONST char * Revision_ariths_c =
   "@(#)$Id$";

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling                  */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* operation, property, attribute  */

#define INCLUDE_DECLARATION_PART
#include        "ariths.h"              /* basic arithmetic                */
#undef  INCLUDE_DECLARATION_PART

#include        "bool.h"                /* booleans                        */


/****************************************************************************
**

*T  CompaMethod . . . . . . . . . . type of methods for comparison operations
**
**  'CompaMethod'  is the type of methods  for comparison operations, i.e., a
**  function accepting two arguments of type 'Obj' and returning an 'Int'.
**
**  'CompaMethod' is  defined  in the  declaration  part of  this package  as
**  follows
**
typedef Int (* CompaMethod) ( Obj opL, Obj opR );
*/


/****************************************************************************
**
*T  ArithMethod1  . . . . . . . . . type of methods for arithmetic operations
**
**  'ArithMethod1'  is the type of  methods  for unary arithmetic operations,
**  i.e.,  a function accepting  one argument of type  'Obj' and returning an
**  'Obj'.
**
**  'ArithMethod1'  is  defined in the   declaration part of  this package as
**  follows
**
typedef Obj (* ArithMethod1) ( Obj op );
*/


/****************************************************************************
**
*T  ArithMethod2  . . . . . . . . . type of methods for arithmetic operations
**
**  'ArithMethod2' is the type  of methods for binary arithmetic  operations,
**  i.e., a function  accepting two arguments  of type 'Obj' and returning an
**  'Obj'.
**
**  'ArithMethod2'  is  defined in the   declaration part of  this package as
**  follows
**
typedef Obj (* ArithMethod2) ( Obj opL, Obj opR );
*/


/****************************************************************************
**

*F * * * * * * * * * * *  unary arithmetic operations * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  ZeroFuncs[ <type> ] . . . . . . . . . . . . . . . . table of zero methods
*/
ArithMethod1 ZeroFuncs [LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  ZeroObject( <obj> ) . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj ZeroAttr;

Obj ZeroObject (
    Obj                 obj )

{
    return DoAttribute( ZeroAttr, obj );
}


/****************************************************************************
**
*F  VerboseZeroObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
Obj VerboseZeroObject (
    Obj                 obj )

{
    return DoVerboseAttribute( ZeroAttr, obj );
}


/****************************************************************************
**
*F  ZeroHandler( <self>, <obj> )  . . . . . . . . . . . . . . . . call 'ZERO'
*/
Obj ZeroHandler (
    Obj                 self,
    Obj                 obj )
{
    return ZERO(obj);
}


/****************************************************************************
**
*F  InstallZeroObject( <verb> ) . . . . . . . . . . . .  install zero methods
*/
void InstallZeroObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* zero function                   */

    func = ( verb ? VerboseZeroObject : ZeroObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        ZeroFuncs[t1] = func;
    }
    ZeroFuncs[ T_OBJECT          ] = func;
    ZeroFuncs[ T_PREC            ] = func;
    ZeroFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**

*V  AInvFuncs[ <type> ] . . . . . . . . . . table of additive inverse methods
*/
ArithMethod1 AInvFuncs [LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  AInvObj( <obj> )  . . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj AInvAttr;

Obj AInvObject (
    Obj                 obj )
{
    return DoAttribute( AInvAttr, obj );
}


/****************************************************************************
**
*F  VerboseAInvObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
Obj VerboseAInvObject (
    Obj                 obj )
{
    return DoVerboseAttribute( AInvAttr, obj );
}


/****************************************************************************
**
*F  AInvHandler( <self>, <obj> )  . . . . . . . . . . . . . . . . call 'AINV'
*/
Obj AInvHandler (
    Obj                 self,
    Obj                 obj )
{
    return AINV(obj);
}


/****************************************************************************
**
*F  InstallAinvObject( <verb> ) . . . . . .  install additive inverse methods
*/
void InstallAinvObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* ainv function                   */

    func = ( verb ? VerboseAInvObject : AInvObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        AInvFuncs[t1] = func;
    }
    AInvFuncs[ T_OBJECT          ] = func;
    AInvFuncs[ T_PREC            ] = func;
    AInvFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**

*V  OneFuncs[ <type> ]  . . . . . . . . . . . . . . . .  table of one methods
*/
ArithMethod1 OneFuncs [LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  OneObject( <obj> )  . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj OneAttr;

Obj OneObject (
    Obj                 obj )
{
    return DoAttribute( OneAttr, obj );
}


/****************************************************************************
**
*F  VerboseOneObject( <obj> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj VerboseOneObject (
    Obj                 obj )
{
    return DoVerboseAttribute( OneAttr, obj );
}


/****************************************************************************
**
*F  OneHandler( <self>, <obj> ) . . . . . . . . . . . . . . . . .  call 'ONE'
*/
Obj OneHandler (
    Obj                 self,
    Obj                 obj )
{
    return ONE(obj);
}


/****************************************************************************
**
*F  InstallOneObject( <verb> )  . . . . . . . . . . . . . install one methods
*/
void InstallOneObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* one function                    */

    func = ( verb ? VerboseOneObject : OneObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        OneFuncs[t1] = func;
    }
    OneFuncs[ T_OBJECT          ] = func;
    OneFuncs[ T_PREC            ] = func;
    OneFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**

*V  InvFuncs[ <type> ]  . . . . . . . . . . . . .  table of inverse functions
*/
ArithMethod1 InvFuncs [LAST_VIRTUAL_TNUM+1];

    
/****************************************************************************
**
*F  InvObject( <obj> )  . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj InvAttr;

Obj InvObject (
    Obj                 obj )
{
    return DoAttribute( InvAttr, obj );
}


/****************************************************************************
**
*F  VerboseInvObject( <obj> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj VerboseInvObject (
    Obj                 obj )
{
    return DoVerboseAttribute( InvAttr, obj );
}


/****************************************************************************
**
*F  InvHandler( <self>, <obj> ) . . . . . . . . . . . . . . . . .  call 'INV'
*/
Obj InvHandler (
    Obj                 self,
    Obj                 obj )
{
    return INV( obj );
}


/****************************************************************************
**
*F  InstallInvObject( <verb> )  . . . . . . . . . . . install inverse methods
*/
void InstallInvObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* inv function                    */

    func = ( verb ? VerboseInvObject : InvObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        InvFuncs[t1] = func;
    }
    InvFuncs[ T_OBJECT          ] = func;
    InvFuncs[ T_PREC            ] = func;
    InvFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * comparison operations  * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  EqFuncs[ <typeL> ][ <typeR> ] . . . . . . . . table of comparison methods
*/
CompaMethod EqFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  EqNot( <opL>, <opR> ) . . . . . . . . . . . . . . . . . . . . . not equal
*/
Int EqNot (
    Obj                 opL,
    Obj                 opR )
{
    return 0L;
}


/****************************************************************************
**
*F  EqObject( <opL>, <opR> )  . . . . . . . . . . . . . . . . .  call methsel
*/
Obj EqOper;

Int EqObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoOperation2Args( EqOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  VerboseEqObject( <opL>, <opR> ) . . . . . . . . . . . . . .  call methsel
*/
Int VerboseEqObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoVerboseOperation2Args( EqOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  EqHandler( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . . call 'EQ'
*/
Obj EqHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return (EQ( opL, opR ) ? True : False);
}


/****************************************************************************
**
*F  InstallEqObject( <verb> ) . . . . . . . . . .  install comparison methods
*/
void InstallEqObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    CompaMethod         func;           /* equal function                  */

    func = ( verb ? VerboseEqObject : EqObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            EqFuncs[t1][t2] = func;
            EqFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
        EqFuncs[ t2 ][ T_OBJECT ] = func;
        EqFuncs[ T_OBJECT ][ t2 ] = func;

        EqFuncs[ t2 ][ T_PREC            ] = func;
        EqFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        EqFuncs[ T_PREC            ][ t2 ] = func;
        EqFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  LtFuncs[ <typeL> ][ <typeR> ] . . . . . . . . table of comparison methods
*/
CompaMethod LtFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  LtObject( <opL>, <opR> )  . . . . . . . . . . . . . . . . .  call methsel
*/
Obj LtOper;

Int LtObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoOperation2Args( LtOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  VerboseLtObject( <opL>, <opR> ) . . . . . . . . . . . . . .  call methsel
*/
Int VerboseLtObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoVerboseOperation2Args( LtOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  LtHandler( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . . call 'LT'
*/
Obj LtHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return (LT( opL, opR ) ? True : False);
}


/****************************************************************************
**
*F  InstallLtObject( <verb> ) . . . . . . . . . . . install less than methods
*/
void InstallLtObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    CompaMethod         func;           /* less than function              */

    func = ( verb ? VerboseLtObject : LtObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            LtFuncs[t1][t2] = func;
            LtFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
        LtFuncs[ t2 ][ T_OBJECT ] = func;
        LtFuncs[ T_OBJECT ][ t2 ] = func;

        LtFuncs[ t2 ][ T_PREC            ] = func;
        LtFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        LtFuncs[ T_PREC            ][ t2 ] = func;
        LtFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  InFuncs[ <typeL> ][ <typeR> ] . . . . . . . . table of membership methods
*/
CompaMethod InFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  InUndefined( <self>, <opL>, <opR> ) . . . . . . . . . . . . . cannot 'in'
*/
Int InUndefined (
    Obj                 opL,
    Obj                 opR )
{
    return (ErrorReturnObj(
        "operations: IN of %s and %s is not defined",
        (Int)(InfoBags[TNUM_OBJ(opL)].name),
        (Int)(InfoBags[TNUM_OBJ(opR)].name),
        "you can return a value for the result" ) == True);
}


/****************************************************************************
**
*F  InObject( <opL>, <opR> )  . . . . . . . . . . . . . . . . .  call methsel
*/
Obj InOper;

Int InObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoOperation2Args( InOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  VerboseInObject( <opL>, <opR> ) . . . . . . . . . . . . . .  call methsel
*/
Int VerboseInObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoVerboseOperation2Args( InOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  InHandler( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . . call 'IN'
*/
Obj InHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return (IN( opL, opR ) ? True : False);
}


/****************************************************************************
**
*F  InstallInObject( <verb> ) . . . . . . . . . . . . . .  install in methods
*/
void InstallInObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    CompaMethod         func;           /* in function                     */

    func = ( verb ? VerboseInObject : InObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            InFuncs[t1][t2] = func;
            InFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
        InFuncs[ t2 ][ T_OBJECT ] = func;
        InFuncs[ T_OBJECT ][ t2 ] = func;

        InFuncs[ t2 ][ T_PREC            ] = func;
        InFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
    }
}


/****************************************************************************
**

*F * * * * * * * * * * * binary arithmetic operations * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  SumFuncs[ <typeL> ][ <typeR> ]  . . . . . . . . . .  table of sum methods
*/
ArithMethod2    SumFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  SumObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj SumOper;

Obj SumObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( SumOper, opL, opR );
}


/****************************************************************************
**
*F  VerboseSumObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
Obj VerboseSumObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( SumOper, opL, opR );
}


/****************************************************************************
**
*F  SumHandler( <self>, <opL>, <opR> )  . . . . . . . . . . . . .  call 'SUM'
*/
Obj SumHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return SUM( opL, opR );
}


/****************************************************************************
**
*F  InstallSumObject( <verb> )  . . . . . . . . . . . . . install sum methods
*/
void InstallSumObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    ArithMethod2        func;           /* sum function                    */

    func = ( verb ? VerboseSumObject : SumObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
            SumFuncs[t1][t2] = func;
            SumFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
        SumFuncs[ t2 ][ T_OBJECT ] = func;
        SumFuncs[ T_OBJECT ][ t2 ] = func;

        SumFuncs[ t2 ][ T_PREC            ] = func;
        SumFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        SumFuncs[ T_PREC            ][ t2 ] = func;
        SumFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  DiffFuncs[ <typeL> ][ <typeR> ] . . . . . . . table of difference methods
*/
ArithMethod2 DiffFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  DiffDefault( <opL>, <opR> ) . . . . . . . . . . . . call 'SUM' and 'AINV'
*/
Obj DiffDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;

    tmp = AINV( opR );
    return SUM( opL, tmp );
}    


/****************************************************************************
**
*F  DiffDefaultHandler( <self>, <opL>, <opR> )  . . . . .  call 'DiffDefault'
*/
Obj DiffDefaultFunc;

Obj DiffDefaultHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return DiffDefault( opL, opR );
}


/****************************************************************************
**
*F  DiffObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
Obj DiffOper;

Obj DiffObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( DiffOper, opL, opR );
}


/****************************************************************************
**
*F  VerboseDiffObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
Obj VerboseDiffObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( DiffOper, opL, opR );
}


/****************************************************************************
**
*F  DiffHandler( <self>, <opL>, <opR> ) . . . . . . . . . . . . . call 'DIFF'
*/
Obj DiffHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return DIFF( opL, opR );
}


/****************************************************************************
**
*F  InstallDiffObject( <verb> ) . . . . . . . . .  install difference methods
*/
void InstallDiffObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    ArithMethod2        func;           /* difference function             */

    func = ( verb ? VerboseDiffObject : DiffObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            DiffFuncs[t1][t2] = func;
            DiffFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
        DiffFuncs[ t2 ][ T_OBJECT ] = func;
        DiffFuncs[ T_OBJECT ][ t2 ] = func;

        DiffFuncs[ t2 ][ T_PREC            ] = func;
        DiffFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        DiffFuncs[ T_PREC            ][ t2 ] = func;
        DiffFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  ProdFuncs[ <typeL> ][ <typeR> ] . . . . . . . .  table of product methods
*/
ArithMethod2    ProdFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  ProdObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
Obj ProdOper;

Obj ProdObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( ProdOper, opL, opR );
}


/****************************************************************************
**
*F  VerboseProdObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
Obj VerboseProdObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( ProdOper, opL, opR );
}


/****************************************************************************
**
*F  ProdHandler( <self>, <opL>, <opR> ) . . . . . . . . . . . . . call 'PROD'
*/
Obj ProdHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return PROD( opL, opR );
}


/****************************************************************************
**
*F  InstallProdObject( <verb> ) . . . . . . . . . . . install product methods
*/
void InstallProdObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    ArithMethod2        func;           /* product function                */

    func = ( verb ? VerboseProdObject : ProdObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            ProdFuncs[t1][t2] = func;
            ProdFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
        ProdFuncs[ t2 ][ T_OBJECT ] = func;
        ProdFuncs[ T_OBJECT ][ t2 ] = func;

        ProdFuncs[ t2 ][ T_PREC            ] = func;
        ProdFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        ProdFuncs[ T_PREC            ][ t2 ] = func;
        ProdFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  QuoFuncs[ <typeL> ][ <typeR> ]  . . . . . . . . table of quotient methods
*/
ArithMethod2 QuoFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  QuoDefault( <opL>, <opR> )  . . . . . . . . . . . . call 'INV' and 'PROD'
*/
Obj QuoDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = INV( opR );
    return PROD( opL, tmp );
}


/****************************************************************************
**
*F  QuoDefaultHandler( <self>, <opL>, <opR> ) . . . . . . . call 'QuoDefault'
*/
Obj QuoDefaultFunc;

Obj QuoDefaultHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return QuoDefault( opL, opR );
}


/****************************************************************************
**
*F  QuoObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj QuoOper;

Obj QuoObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( QuoOper, opL, opR );
}


/****************************************************************************
**
*F  VerboseQuoObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
Obj VerboseQuoObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( QuoOper, opL, opR );
}


/****************************************************************************
**
*F  QuoHandler( <self>, <opL>, <opR> )  . . . . . . . . . . . . .  call 'QUO'
*/
Obj QuoHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return QUO( opL, opR );
}


/****************************************************************************
**
*F  InstallQuoObject( <verb> )  . . . . . . . . . .  install quotient methods
*/
void InstallQuoObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    ArithMethod2        func;           /* quotient function               */

    func = ( verb ? VerboseQuoObject : QuoObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            QuoFuncs[t1][t2] = func;
            QuoFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
        QuoFuncs[ t2 ][ T_OBJECT ] = func;
        QuoFuncs[ T_OBJECT ][ t2 ] = func;

        QuoFuncs[ t2 ][ T_PREC            ] = func;
        QuoFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        QuoFuncs[ T_PREC            ][ t2 ] = func;
        QuoFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  LQuoFuncs[ <typeL> ][ <typeR> ] . . . . .  table of left quotient methods
*/
ArithMethod2 LQuoFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  LQuoDefault( <opL>, <opR> ) . . . . . . . . . . . . call 'INV' and 'PROD'
*/
Obj LQuoDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = INV( opL );
    return PROD( tmp, opR );
}


/****************************************************************************
**
*F  LQuoDefaultHandler( <self>, <opL>, <opR> )  . . . . .  call 'LQuoDefault'
*/
Obj LQuoDefaultFunc;

Obj LQuoDefaultHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return LQuoDefault( opL, opR );
}


/****************************************************************************
**
*F  LQuoObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
Obj LQuoOper;

Obj LQuoObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( LQuoOper, opL, opR );
}


/****************************************************************************
**
*F  VerboseLQuoObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
Obj VerboseLQuoObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( LQuoOper, opL, opR );
}


/****************************************************************************
**
*F  LQuoHandler( <self>, <opL>, <opR> ) . . . . . . . . . . . . . call 'LQUO'
*/
Obj LQuoHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return LQUO( opL, opR );
}


/****************************************************************************
**
*F  InstallLQuoObject( <verb> ) . . . . . . . . install left quotient methods
*/
void InstallLQuoObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    ArithMethod2        func;           /* left quotient function          */

    func = ( verb ? VerboseLQuoObject : LQuoObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
            LQuoFuncs[t1][t2] = func;
            LQuoFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
        LQuoFuncs[ t2 ][ T_OBJECT ] = func;
        LQuoFuncs[ T_OBJECT ][ t2 ] = func;

        LQuoFuncs[ t2 ][ T_PREC            ] = func;
        LQuoFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        LQuoFuncs[ T_PREC            ][ t2 ] = func;
        LQuoFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  PowFuncs[ <typeL> ][ <typeR> ]  . . . . . . . . .  table of power methods
*/
ArithMethod2 PowFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  PowDefault( <opL>, <opR> )  . . . . . . . . . . .  call 'LQUO' and 'PROD'
*/
Obj PowDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = LQUO( opR, opL );
    return PROD( tmp, opR );
}


/****************************************************************************
**
*F  PowDefaultHandler( <self>, <opL>, <opR> ) . . . . . . . call 'PowDefault'
*/
Obj PowDefaultFunc;

Obj PowDefaultHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return PowDefault( opL, opR );
}


/****************************************************************************
**
*F  PowObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj PowOper;

Obj PowObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( PowOper, opL, opR );
}


/****************************************************************************
**
*F  VerbosePowObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
Obj VerbosePowObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( PowOper, opL, opR );
}


/****************************************************************************
**
*F  PowHandler( <self>, <opL>, <opR> )  . . . . . . . . . . . . .  call 'POW'
*/
Obj PowHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return POW( opL, opR );
}


/****************************************************************************
**
*F  InstallPowObject( <verb> )  . . . . . . . . . . install the power methods
*/
void InstallPowObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    ArithMethod2        func;           /* power function                  */

    func = ( verb ? VerbosePowObject : PowObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            PowFuncs[t1][t2] = func;
            PowFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
        PowFuncs[ t2 ][ T_OBJECT ] = func;
        PowFuncs[ T_OBJECT ][ t2 ] = func;

        PowFuncs[ t2 ][ T_PREC            ] = func;
        PowFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        PowFuncs[ T_PREC            ][ t2 ] = func;
        PowFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  CommFuncs[ <typeL> ][ <typeR> ] . . . . . . . table of commutator methods
*/
ArithMethod2 CommFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  CommDefault( <opL>, <opR> ) . . . . . . . . . . .  call 'LQUO' and 'PROD'
*/
Obj CommDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp1;
    Obj                 tmp2;
    tmp1 = PROD( opR, opL );
    tmp2 = PROD( opL, opR );
    return LQUO( tmp1, tmp2 );
}


/****************************************************************************
**
*F  CommDefaultHandler( <self>, <opL>, <opR> )  . . . . .  call 'CommDefault'
*/
Obj CommDefaultFunc;

Obj CommDefaultHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return CommDefault( opL, opR );
}


/****************************************************************************
**
*F  CommObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
Obj CommOper;

Obj CommObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( CommOper, opL, opR );
}


/****************************************************************************
**
*F  VerboseCommObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
Obj VerboseCommObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( CommOper, opL, opR );
}


/****************************************************************************
**
*F  CommHandler( <self>, <opL>, <opR> ) . . . . . . . . . . . . . call 'COMM'
*/
Obj CommHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return COMM( opL, opR );
}


/****************************************************************************
**
*F  InstallCommObject( <verb> ) . . . . . . . . .  install commutator methods
*/
void InstallCommObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    ArithMethod2        func;           /* commutator function             */

    func = ( verb ? VerboseCommObject : CommObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            CommFuncs[t1][t2] = func;
            CommFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
        CommFuncs[ t2 ][ T_OBJECT ] = func;
        CommFuncs[ T_OBJECT ][ t2 ] = func;

        CommFuncs[ t2 ][ T_PREC            ] = func;
        CommFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        CommFuncs[ T_PREC            ][ t2 ] = func;
        CommFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*V  ModFuncs[ <typeL> ][ <typeR> ]  . . . . . . .  table of remainder methods
*/
ArithMethod2 ModFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];



/****************************************************************************
**
*F  ModObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj ModOper;

Obj ModObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( ModOper, opL, opR );
}


/****************************************************************************
**
*F  VerboseModObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
Obj VerboseModObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( ModOper, opL, opR );
}


/****************************************************************************
**
*F  ModHandler( <self>, <opL>, <opR> )  . . . . . . . . . . . . .  call 'MOD'
*/
Obj ModHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return MOD( opL, opR );
}


/****************************************************************************
**
*F  InstallModObject( <verb> )  . . . . . . . . . . . install the mod methods
*/
void InstallModObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    ArithMethod2        func;           /* mod function                    */

    func = ( verb ? VerboseModObject : ModObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            ModFuncs[t1][t2] = func;
            ModFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
        ModFuncs[ t2 ][ T_OBJECT ] = func;
        ModFuncs[ T_OBJECT ][ t2 ] = func;

        ModFuncs[ t2 ][ T_PREC            ] = func;
        ModFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        ModFuncs[ T_PREC            ][ t2 ] = func;
        ModFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitAriths()  . . . . . . .  initialize the arithmetic operations package
**
**  'InitAriths' initializes the arithmetic operations package.
*/
void InitAriths ( void )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */


    /* make and install the 'ZERO' arithmetic operation                    */
    C_NEW_GVAR_ATTR( "ZERO", "op", ZeroAttr, ZeroHandler,
        "src/ariths.c:ZERO" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        ZeroFuncs[t1] = ZeroObject;
    }
    InstallZeroObject(0);


    /* make and install the 'AINV' arithmetic operation                    */
    C_NEW_GVAR_ATTR( "AINV", "op", AInvAttr, AInvHandler,
        "src/ariths.c:AINV" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        AInvFuncs[t1] = AInvObject;
    }
    InstallAinvObject(0);


    /* make and install the 'ONE' arithmetic operation                     */
    C_NEW_GVAR_ATTR( "ONE", "op", OneAttr, OneHandler,
        "src/ariths.c:ONE" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        OneFuncs[t1] = OneObject;
    }
    InstallOneObject(0);


    /* make and install the 'INV' arithmetic operation                     */
    C_NEW_GVAR_ATTR( "INV", "op", InvAttr, InvHandler,
        "src/ariths.c:INV" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        InvFuncs[t1] = InvObject;
    }
    InstallInvObject(0);


    /* make and install the 'EQ' comparison operation                      */
    C_NEW_GVAR_OPER( "EQ", 2L, "opL, opR", EqOper, EqHandler,
        "src/ariths.c:EQ" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            EqFuncs[t1][t2] = EqNot;
        }
    }
    InstallEqObject(0);


    /* make and install the 'LT' comparison operation                      */
    C_NEW_GVAR_OPER( "LT", 2L, "opL, opR", LtOper, LtHandler,
        "src/ariths.c:LT" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            LtFuncs[t1][t2] = LtObject;
        }
    }
    InstallLtObject(0);


    /* make and install the 'IN' comparison operation                      */
    C_NEW_GVAR_OPER( "IN", 2L, "opL, opR", InOper, InHandler,
        "src/ariths.c:IN" );

    for ( t1 = FIRST_REAL_TNUM; t1 <= LAST_VIRTUAL_TNUM; t1++ ) {
        for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
            InFuncs[t1][t2] = InUndefined;
        }
    }
    InstallInObject(0);


    /* make and install the 'SUM' arithmetic operation                     */
    C_NEW_GVAR_OPER( "SUM", 2L, "opL, opR", SumOper, SumHandler,
        "src/ariths.c:SUM" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            SumFuncs[t1][t2] = SumObject;
        }
    }
    InstallSumObject(0);


    /* make and install the 'DIFF' arithmetic operation                    */
    C_NEW_GVAR_OPER( "DIFF", 2L, "opL, opR", DiffOper, DiffHandler,
        "src/ariths.c:DIFF" );
    C_NEW_GVAR_FUNC( "DIFF_DEFAULT", 2L, "opL, opR", DiffDefaultHandler,
        "src/ariths.c:DIFF_DEFAULT" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            DiffFuncs[t1][t2] = DiffDefault;
        }
    }
    InstallDiffObject(0);


    /* make and install the 'PROD' arithmetic operation                    */
    C_NEW_GVAR_OPER( "PROD", 2L, "opL, opR", ProdOper, ProdHandler,
        "src/ariths.c:PROD" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            ProdFuncs[t1][t2] = ProdObject;
        }
    }
    InstallProdObject(0);


    /* make and install the 'QUO' arithmetic operation                     */
    C_NEW_GVAR_OPER( "QUO", 2L, "opL, opR", QuoOper, QuoHandler,
        "src/ariths.c:QUO" );
    C_NEW_GVAR_FUNC( "QUO_DEFAULT", 2L, "opL, opR", QuoDefaultHandler,
        "src/ariths.c:QUO_DEFAULT" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            QuoFuncs[t1][t2] = QuoDefault;
        }
    }
    InstallQuoObject(0);


    /* make and install the 'LQUO' arithmetic operation                    */
    C_NEW_GVAR_OPER( "LQUO", 2L, "opL, opR", LQuoOper, LQuoHandler,
        "src/ariths.c:LQUO" );
    C_NEW_GVAR_FUNC( "LQUO_DEFAULT", 2L, "opL, opR", LQuoDefaultHandler,
        "src/ariths.c:LQUO_DEFAULT" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            LQuoFuncs[t1][t2] = LQuoDefault;
        }
    }
    InstallLQuoObject(0);


    /* make and install the 'POW' arithmetic operation                     */
    C_NEW_GVAR_OPER( "POW", 2L, "opL, opR", PowOper, PowHandler,
        "src/ariths.c:POW" );
    C_NEW_GVAR_FUNC( "POW_DEFAULT", 2L, "opL, opR", PowDefaultHandler,
        "src/ariths.c:POW_DEFAULT" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            PowFuncs[t1][t2] = PowObject;
        }
    }
    InstallPowObject(0);


    /* make and install the 'COMM' arithmetic operation                    */
    C_NEW_GVAR_OPER( "COMM", 2L, "opL, opR", CommOper, CommHandler,
        "src/ariths.c:COMM" );
    C_NEW_GVAR_FUNC( "COMM_DEFAULT", 2L, "opL, opR", CommDefaultHandler,
        "src/ariths.c:COMM_DEFAULT" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            CommFuncs[t1][t2] = CommDefault;
        }
    }
    InstallCommObject(0);


    /* make and install the 'MOD' arithmetic operation                     */
    C_NEW_GVAR_OPER( "MOD", 2L, "opL, opR", ModOper, ModHandler,
        "src/ariths.c:MOD" );

    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_VIRTUAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_VIRTUAL_TNUM;  t2++ ) {
            ModFuncs[t1][t2] = ModObject;
        }
    }
    InstallModObject(0);
}


/****************************************************************************
**

*E  ariths.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
