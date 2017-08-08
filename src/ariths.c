/****************************************************************************
**
*W  ariths.c                    GAP source                       Frank Celler
*W                                                         & Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the  arithmetic  operations  package.
*/
#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>


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
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */



/****************************************************************************
**
*F * * * * * * * * * * *  unary arithmetic operations * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  ZeroFuncs[ <type> ] . . . . . . . . . . . . . . . . table of zero methods
*/
ArithMethod1 ZeroFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  ZeroObject( <obj> ) . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj ZEROOp;

Obj ZeroObject (
    Obj                 obj )

{
  Obj val;
  val = DoOperation1Args( ZEROOp, obj );
  while (val == 0)
    val = ErrorReturnObj("ZEROOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseZeroObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
Obj VerboseZeroObject (
    Obj                 obj )

{
  Obj val;
  val = DoVerboseOperation1Args( ZEROOp, obj );
  while (val == 0)
    val = ErrorReturnObj("ZEROOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
    ZeroFuncs[ T_PREC            ] = func;
    ZeroFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**
*F  FuncZERO( <self>, <obj> ) . . . . . . . . . . . . . . . . . . call 'ZERO'
*/
Obj FuncZERO (
    Obj                 self,
    Obj                 obj )
{
    return ZERO(obj);
}

/****************************************************************************
**
*V  ZeroMutFuncs[ <type> ] . . . . . . . . . . . . . . . . table of zero methods
*/
ArithMethod1 ZeroMutFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  ZeroMutObject( <obj> ) . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj ZeroOp;

Obj ZeroMutObject (
    Obj                 obj )

{
  Obj val;
  val = DoOperation1Args( ZeroOp, obj );
  while (val == 0)
    val = ErrorReturnObj("ZeroOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseZeroMutObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
Obj VerboseZeroMutObject (
    Obj                 obj )

{
  Obj val;
  val = DoVerboseOperation1Args( ZeroOp, obj );
  while (val == 0)
    val = ErrorReturnObj("ZeroOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  InstallZeroMutObject( <verb> ) . . . . . . . . . . . .  install zero methods
*/
void InstallZeroMutObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* zero function                   */

    func = ( verb ? VerboseZeroMutObject : ZeroMutObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        ZeroMutFuncs[t1] = func;
    }
    ZeroMutFuncs[ T_PREC            ] = func;
    ZeroMutFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**
*F  FuncZERO_MUT( <self>, <obj> ) . . . . . . . . . . . . . . call 'ZERO_MUT'
*/
Obj FuncZERO_MUT (
    Obj                 self,
    Obj                 obj )
{
    return ZERO_MUT(obj);
}


/****************************************************************************
**
*V  AInvFuncs[ <type> ] . . . . . . . . . . table of additive inverse methods
*V  AInvMutFuncs[ <type> ] . .  . . . . . . table of additive inverse methods
**                                          which return mutable results
*/
ArithMethod1 AInvFuncs [LAST_REAL_TNUM+1];
ArithMethod1 AInvMutFuncs[ LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  AInvObj( <obj> )  . . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj AInvOp;

Obj AInvObject (
    Obj                 obj )
{
  Obj val;
  val = DoOperation1Args( AInvOp, obj );
  while (val == 0)
    val = ErrorReturnObj("AInvOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseAInvObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
Obj VerboseAInvObject (
    Obj                 obj )
{
  Obj val;
  val = DoVerboseOperation1Args( AInvOp, obj );
  while (val == 0)
    val = ErrorReturnObj("AInvOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
    AInvFuncs[ T_PREC            ] = func;
    AInvFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**
*F  FuncAINV( <self>, <obj> ) . . . . . . . . . . . . . . . . . . call 'AINV'
*/
Obj FuncAINV (
    Obj                 self,
    Obj                 obj )
{
    return AINV(obj);
}

/****************************************************************************
**
*F  AInvMutObject( <obj> )  . .. . . . . . . . . . . . . . . . .  call methsel
*/
Obj AdditiveInverseOp;

Obj AInvMutObject (
    Obj                 obj )
{
  Obj val;
  val = DoOperation1Args( AdditiveInverseOp, obj );
  while (val == 0)
    val = ErrorReturnObj("AdditiveInverseOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseAInvMutObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
Obj VerboseAInvMutObject (
    Obj                 obj )
{
  Obj val;
  val = DoVerboseOperation1Args( AdditiveInverseOp, obj );
  while (val == 0)
    val = ErrorReturnObj("AdditiveInverseOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  InstallAinvMutObject( <verb> ) . . . . . .  install additive inverse methods
*/
void InstallAinvMutObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* ainv function                   */

    func = ( verb ? VerboseAInvMutObject : AInvMutObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        AInvMutFuncs[t1] = func;
    }
    AInvMutFuncs[ T_PREC            ] = func;
    AInvMutFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**
*F  FuncAINV_MUT( <self>, <obj> ) . . . . . . . . . . . . . . . . . . call 'AINV'
*/
Obj FuncAINV_MUT (
    Obj                 self,
    Obj                 obj )
{
    return AINV_MUT(obj);
}


/****************************************************************************
**
*V  OneFuncs[ <type> ]  . . . . . . . . . . . . . . . .  table of one methods
*/
ArithMethod1 OneFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  OneObject( <obj> )  . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj OneOp;

Obj OneObject (
    Obj                 obj )
{
  Obj val;
  val = DoOperation1Args( OneOp, obj );
  while (val == 0)
    val = ErrorReturnObj("OneOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseOneObject( <obj> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj VerboseOneObject (
    Obj                 obj )
{
  Obj val;
  val = DoVerboseOperation1Args( OneOp, obj );
  while (val == 0)
    val = ErrorReturnObj("OneOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
    OneFuncs[ T_PREC            ] = func;
    OneFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**
*F  FuncONE( <self>, <obj> ) . . . . . . . . . . . . . . . . .  call 'ONE'
*/
Obj FuncONE (
    Obj                 self,
    Obj                 obj )
{
    return ONE(obj);
}

/****************************************************************************
**
*V  OneMutFuncs[ <type> ]  . . . . .table of mutability retaining one methods
*/
ArithMethod1 OneMutFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  OneMutObject( <obj> )  . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj OneMutOp;

Obj OneMutObject (
    Obj                 obj )
{
  Obj val;
  val = DoOperation1Args( OneMutOp, obj );
  while (val == 0)
    val = ErrorReturnObj("ONEOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseOneMutObject( <obj> ) . . .  . . . . . . . . . . . .  call methsel
*/
Obj VerboseOneMutObject (
    Obj                 obj )
{
  Obj val;
  val = DoVerboseOperation1Args( OneMutOp, obj );
  while (val == 0)
    val = ErrorReturnObj("ONEOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  InstallOneMutObject( <verb> )  . . . . . . . . . . . . . install one methods
*/
void InstallOneMutObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* one function                    */

    func = ( verb ? VerboseOneMutObject : OneMutObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        OneMutFuncs[t1] = func;
    }
    OneMutFuncs[ T_PREC            ] = func;
    OneMutFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**
*F  FuncONE_MUT( <self>, <obj> ) . . . . . . . . . . . . . . . .call 'ONE_MUT'
*/
Obj FuncONE_MUT (
    Obj                 self,
    Obj                 obj )
{
    return ONE_MUT(obj);
}


/****************************************************************************
**
*V  InvFuncs[ <type> ]  . . . . . . . . . . . . .  table of inverse functions
*/
ArithMethod1 InvFuncs [LAST_REAL_TNUM+1];

    
/****************************************************************************
**
*F  InvObject( <obj> )  . . . . . . . . . . . . . . . . . . . .  call methsel
*/
Obj InvOp;

Obj InvObject (
    Obj                 obj )
{
  Obj val;
  val = DoOperation1Args( InvOp, obj );
  while (val == 0)
    val = ErrorReturnObj("InvOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseInvObject( <obj> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj VerboseInvObject (
    Obj                 obj )
{
  Obj val;
  val = DoVerboseOperation1Args( InvOp, obj );
  while (val == 0)
    val = ErrorReturnObj("InvOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
    InvFuncs[ T_PREC            ] = func;
    InvFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**
*F  FuncINV( <self>, <obj> )  . . . . . . . . . . . . . . . . . .  call 'INV'
*/
Obj FuncINV (
    Obj                 self,
    Obj                 obj )
{
    return INV( obj );
}


/****************************************************************************
**
*V  InvMutFuncs[ <type> ]  . table of mutability-preserving inverse functions
*/
ArithMethod1 InvMutFuncs [LAST_REAL_TNUM+1];

    
/****************************************************************************
**
*F  InvMutObject( <obj> )  . . . . . . . . . . . . . . .. . . . .  call methsel
*/
Obj InvMutOp;

Obj InvMutObject (
    Obj                 obj )
{
  Obj val;
  val = DoOperation1Args( InvMutOp, obj );
  while (val == 0)
    val = ErrorReturnObj("INVOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseInvMutObject( <obj> ) . . .  . . . . . . . . . . . .  call methsel
*/
Obj VerboseInvMutObject (
    Obj                 obj )
{
  Obj val;
  val = DoVerboseOperation1Args( InvMutOp, obj );
  while (val == 0)
    val = ErrorReturnObj("INVOp: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  InstallInvMutObject( <verb> ) install mutability preserving inverse methods
*/
void InstallInvMutObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* inv function                    */

    func = ( verb ? VerboseInvMutObject : InvMutObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        InvMutFuncs[t1] = func;
    }
    InvMutFuncs[ T_PREC            ] = func;
    InvMutFuncs[ T_PREC +IMMUTABLE ] = func;
}


/****************************************************************************
**
*F  FuncINV_MUT( <self>, <obj> )  . . .  . . . . . . . . . .  call 'INV_MUT'
*/
Obj FuncINV_MUT (
    Obj                 self,
    Obj                 obj )
{
    return INV_MUT( obj );
}


/****************************************************************************
**
*F * * * * * * * * * * * * * comparison operations  * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  EqFuncs[ <typeL> ][ <typeR> ] . . . . . . . . table of comparison methods
*/
CompaMethod EqFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


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
*F  InstallEqObject( <verb> ) . . . . . . . . . .  install comparison methods
*/
void InstallEqObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    CompaMethod         func;           /* equal function                  */

    func = ( verb ? VerboseEqObject : EqObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            EqFuncs[t1][t2] = func;
            EqFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {

        EqFuncs[ t2 ][ T_PREC            ] = func;
        EqFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        EqFuncs[ T_PREC            ][ t2 ] = func;
        EqFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncEQ( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . . . call 'EQ'
*/
Obj FuncEQ (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
  /* if both operands are T_MACFLOAT, we use the comparison method in all cases,
     even if the objects are identical. In this manner, we can have 0./0. != 0./0. as
     the IEEE754 standard requires.
    if (TNUM_OBJ(opL) == T_MACFLOAT && TNUM_OBJ(opR) == T_MACFLOAT)
      return (*EqFuncs[T_MACFLOAT][T_MACFLOAT])(opL,opR) ? True : False;
  */

    return (EQ( opL, opR ) ? True : False);
}


/****************************************************************************
**
*V  LtFuncs[ <typeL> ][ <typeR> ] . . . . . . . . table of comparison methods
*/
CompaMethod LtFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


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
*F  InstallLtObject( <verb> ) . . . . . . . . . . . install less than methods
*/
void InstallLtObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    CompaMethod         func;           /* less than function              */

    func = ( verb ? VerboseLtObject : LtObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            LtFuncs[t1][t2] = func;
            LtFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {

        LtFuncs[ t2 ][ T_PREC            ] = func;
        LtFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        LtFuncs[ T_PREC            ][ t2 ] = func;
        LtFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncLT( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . . . call 'LT'
*/
Obj FuncLT (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return (LT( opL, opR ) ? True : False);
}


/****************************************************************************
**
*V  InFuncs[ <typeL> ][ <typeR> ] . . . . . . . . table of membership methods
*/
CompaMethod InFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


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
        (Int)TNAM_OBJ(opL),
        (Int)TNAM_OBJ(opR),
        "you can 'return <boolean>;' to give a value for the result" ) == True);
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
*F  InstallInObject( <verb> ) . . . . . . . . . . . . . .  install in methods
*/
void InstallInObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */
    CompaMethod         func;           /* in function                     */

    func = ( verb ? VerboseInObject : InObject );
    for ( t1 = FIRST_EXTERNAL_TNUM;  t1 <= LAST_EXTERNAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            InFuncs[t1][t2] = func;
            InFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {

        InFuncs[ t2 ][ T_PREC            ] = func;
        InFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
    }
}


/****************************************************************************
**
*F  FuncIN( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . . . call 'IN'
*/
Obj FuncIN (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return (IN( opL, opR ) ? True : False);
}


/****************************************************************************
**
*F * * * * * * * * * * * binary arithmetic operations * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  SumFuncs[ <typeL> ][ <typeR> ]  . . . . . . . . . .  table of sum methods
*/
ArithMethod2    SumFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  SumObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj SumOper;

Obj SumObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoOperation2Args( SumOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("SUM: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseSumObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
Obj VerboseSumObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoVerboseOperation2Args( SumOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("SUM: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
        for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_REAL_TNUM; t2++ ) {
            SumFuncs[t1][t2] = func;
            SumFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM; t2++ ) {

        SumFuncs[ t2 ][ T_PREC            ] = func;
        SumFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        SumFuncs[ T_PREC            ][ t2 ] = func;
        SumFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncSUM( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . .  call 'SUM'
*/
Obj FuncSUM (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return SUM( opL, opR );
}


/****************************************************************************
**
*V  DiffFuncs[ <typeL> ][ <typeR> ] . . . . . . . table of difference methods
*/
ArithMethod2 DiffFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


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
*F  DiffObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
Obj DiffOper;

Obj DiffObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoOperation2Args( DiffOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("DIFF: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseDiffObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
Obj VerboseDiffObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoVerboseOperation2Args( DiffOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("DIFF: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            DiffFuncs[t1][t2] = func;
            DiffFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_REAL_TNUM; t2++ ) {

        DiffFuncs[ t2 ][ T_PREC            ] = func;
        DiffFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        DiffFuncs[ T_PREC            ][ t2 ] = func;
        DiffFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncDIFF_DEFAULT( <self>, <opL>, <opR> )  . . . . . .  call 'DiffDefault'
*/
Obj DiffDefaultFunc;

Obj FuncDIFF_DEFAULT (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return DiffDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncDIFF( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . call 'DIFF'
*/
Obj FuncDIFF (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return DIFF( opL, opR );
}


/****************************************************************************
**
*V  ProdFuncs[ <typeL> ][ <typeR> ] . . . . . . . .  table of product methods
*/
ArithMethod2    ProdFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  ProdObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
Obj ProdOper;

Obj ProdObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoOperation2Args( ProdOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("PROD: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseProdObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
Obj VerboseProdObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoVerboseOperation2Args( ProdOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("PROD: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            ProdFuncs[t1][t2] = func;
            ProdFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_REAL_TNUM; t2++ ) {

        ProdFuncs[ t2 ][ T_PREC            ] = func;
        ProdFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        ProdFuncs[ T_PREC            ][ t2 ] = func;
        ProdFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncPROD( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . call 'PROD'
*/
Obj FuncPROD (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return PROD( opL, opR );
}


/****************************************************************************
**
*V  QuoFuncs[ <typeL> ][ <typeR> ]  . . . . . . . . table of quotient methods
*/
ArithMethod2 QuoFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  QuoDefault( <opL>, <opR> )  . . . . . . . . . . . . call 'INV' and 'PROD'
*/
Obj QuoDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = INV_MUT( opR );
    return PROD( opL, tmp );
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
  Obj val;
  val = DoOperation2Args( QuoOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("QUO: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseQuoObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
Obj VerboseQuoObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoVerboseOperation2Args( QuoOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("QUO: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            QuoFuncs[t1][t2] = func;
            QuoFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {

        QuoFuncs[ t2 ][ T_PREC            ] = func;
        QuoFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        QuoFuncs[ T_PREC            ][ t2 ] = func;
        QuoFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncQUO_DEFAULT( <self>, <opL>, <opR> ) . . . . . . . . call 'QuoDefault'
*/
Obj QuoDefaultFunc;

Obj FuncQUO_DEFAULT (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return QuoDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncQUO( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . .  call 'QUO'
*/
Obj FuncQUO (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return QUO( opL, opR );
}


/****************************************************************************
**
*V  LQuoFuncs[ <typeL> ][ <typeR> ] . . . . .  table of left quotient methods
*/
ArithMethod2 LQuoFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  LQuoDefault( <opL>, <opR> ) . . . . . . . . . . . . call 'INV' and 'PROD'
*/
Obj LQuoDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = INV_MUT( opL );
    return PROD( tmp, opR );
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
  Obj val;
  val = DoOperation2Args( LQuoOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("LeftQuotient: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseLQuoObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
Obj VerboseLQuoObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoOperation2Args( LQuoOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("LeftQuotient: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
        for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_REAL_TNUM; t2++ ) {
            LQuoFuncs[t1][t2] = func;
            LQuoFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_REAL_TNUM; t2++ ) {
        LQuoFuncs[ t2 ][ T_PREC            ] = func;
        LQuoFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        LQuoFuncs[ T_PREC            ][ t2 ] = func;
        LQuoFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncLQUO_DEFAULT( <self>, <opL>, <opR> )  . . . . . .  call 'LQuoDefault'
*/
Obj LQuoDefaultFunc;

Obj FuncLQUO_DEFAULT (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return LQuoDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncLQUO( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . call 'LQUO'
*/
Obj FuncLQUO (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return LQUO( opL, opR );
}


/****************************************************************************
**
*V  PowFuncs[ <typeL> ][ <typeR> ]  . . . . . . . . .  table of power methods
*/
ArithMethod2 PowFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


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
*F  PowObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj PowOper;

Obj PowObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoOperation2Args( PowOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("POW: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerbosePowObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
Obj VerbosePowObject (
    Obj                 opL,
    Obj                 opR )
{
   
  Obj val;
  val = DoVerboseOperation2Args( PowOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("POW: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            PowFuncs[t1][t2] = func;
            PowFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_REAL_TNUM; t2++ ) {

        PowFuncs[ t2 ][ T_PREC            ] = func;
        PowFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        PowFuncs[ T_PREC            ][ t2 ] = func;
        PowFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncPOW_DEFAULT( <self>, <opL>, <opR> ) . . . . . . . . call 'PowDefault'
*/
Obj PowDefaultFunc;

Obj FuncPOW_DEFAULT (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return PowDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncPOW( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . .  call 'POW'
*/
Obj FuncPOW (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return POW( opL, opR );
}


/****************************************************************************
**
*V  CommFuncs[ <typeL> ][ <typeR> ] . . . . . . . table of commutator methods
*/
ArithMethod2 CommFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


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
*F  CommObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
Obj CommOper;

Obj CommObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoOperation2Args( CommOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("Comm: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseCommObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
Obj VerboseCommObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoVerboseOperation2Args( CommOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("Comm: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            CommFuncs[t1][t2] = func;
            CommFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {

        CommFuncs[ t2 ][ T_PREC            ] = func;
        CommFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        CommFuncs[ T_PREC            ][ t2 ] = func;
        CommFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncCOMM_DEFAULT( <self>, <opL>, <opR> )  . . . . . .  call 'CommDefault'
*/
Obj CommDefaultFunc;

Obj FuncCOMM_DEFAULT (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return CommDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncCOMM( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . call 'COMM'
*/
Obj FuncCOMM (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return COMM( opL, opR );
}


/****************************************************************************
**
*V  ModFuncs[ <typeL> ][ <typeR> ]  . . . . . . .  table of remainder methods
*/
ArithMethod2 ModFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];



/****************************************************************************
**
*F  ModObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
Obj ModOper;

Obj ModObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoOperation2Args( ModOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("mod: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
}


/****************************************************************************
**
*F  VerboseModObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
Obj VerboseModObject (
    Obj                 opL,
    Obj                 opR )
{
  Obj val;
  val = DoVerboseOperation2Args( ModOper, opL, opR );
  while (val == 0)
    val = ErrorReturnObj("mod: method should have returned a value", 0L, 0L,
                         "you can supply one by 'return <value>;'");
  return val;
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
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            ModFuncs[t1][t2] = func;
            ModFuncs[t2][t1] = func;
        }
    }
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_REAL_TNUM; t2++ ) {

        ModFuncs[ t2 ][ T_PREC            ] = func;
        ModFuncs[ t2 ][ T_PREC +IMMUTABLE ] = func;
        ModFuncs[ T_PREC            ][ t2 ] = func;
        ModFuncs[ T_PREC +IMMUTABLE ][ t2 ] = func;
    }
}


/****************************************************************************
**
*F  FuncMOD( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . .  call 'MOD'
*/
Obj FuncMOD (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return MOD( opL, opR );
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    { "EQ", 2, "opL, opR", &EqOper,
      FuncEQ, "src/ariths.c:EQ" },

    { "LT", 2, "opL, opR", &LtOper,
      FuncLT, "src/ariths.c:LT" },

    { "IN", 2, "opL, opR", &InOper,
      FuncIN, "src/ariths.c:IN" },

    { "SUM", 2, "opL, opR", &SumOper,
      FuncSUM, "src/ariths.c:SUM" },

    { "DIFF", 2, "opL, opR", &DiffOper,
      FuncDIFF, "src/ariths.c:DIFF" },

    { "PROD", 2, "opL, opR", &ProdOper,
      FuncPROD, "src/ariths.c:PROD" },

    { "QUO", 2, "opL, opR", &QuoOper,
      FuncQUO, "src/ariths.c:QUO" },

    { "LQUO", 2, "opL, opR", &LQuoOper,
      FuncLQUO, "src/ariths.c:LQUO" },

    { "POW", 2, "opL, opR", &PowOper,
      FuncPOW, "src/ariths.c:POW" },

    { "COMM", 2, "opL, opR", &CommOper,
      FuncCOMM, "src/ariths.c:COMM" },

    { "MOD", 2, "opL, opR", &ModOper,
      FuncMOD, "src/ariths.c:MOD" },

    { "ZERO", 1, "op", &ZEROOp,
      FuncZERO, "src/ariths.c:ZERO" },

    { "ZERO_MUT", 1, "op", &ZeroOp,
      FuncZERO_MUT, "src/ariths.c:ZERO_MUT" },

    { "AINV", 1, "op", &AInvOp,
      FuncAINV, "src/ariths.c:AINV" },

    { "AINV_MUT", 1, "op", &AdditiveInverseOp,
      FuncAINV_MUT, "src/ariths.c:AINV_MUT" },

    { "ONE", 1, "op", &OneOp,
      FuncONE, "src/ariths.c:ONE" },

    { "ONE_MUT", 1, "op", &OneMutOp,
      FuncONE_MUT, "src/ariths.c:ONE_MUT" },

    { "INV", 1, "op", &InvOp,
      FuncINV, "src/ariths.c:INV" },

    { "INV_MUT", 1, "op", &InvMutOp,
      FuncINV_MUT, "src/ariths.c:INV_MUT" },

    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(COMM_DEFAULT, 2, "opL, opR"),
    GVAR_FUNC(POW_DEFAULT, 2, "opL, opR"),
    GVAR_FUNC(LQUO_DEFAULT, 2, "opL, opR"),
    GVAR_FUNC(QUO_DEFAULT, 2, "opL, opR"),
    GVAR_FUNC(DIFF_DEFAULT, 2, "opL, opR"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    /* init filters and functions                                          */
    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* make and install the 'ZERO' arithmetic operation                    */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(ZeroFuncs[t1] == 0);
        ZeroFuncs[t1] = ZeroObject;
    }
    InstallZeroObject(0);

    /* make and install the 'ZERO_MUT' arithmetic operation                */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(ZeroMutFuncs[t1] == 0);
        ZeroMutFuncs[t1] = ZeroMutObject;
    }
    InstallZeroObject(0);

    /* make and install the 'AINV' arithmetic operation                    */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(AInvFuncs[t1] == 0);
        AInvFuncs[t1] = AInvObject;
    }
    InstallAinvObject(0);

    /* make and install the 'AINV_MUT' arithmetic operation                */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(AInvMutFuncs[t1] == 0);
        AInvMutFuncs[t1] = AInvMutObject;
    }
    InstallAinvMutObject(0);

    /* make and install the 'ONE' arithmetic operation                     */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(OneFuncs[t1] == 0);
        OneFuncs[t1] = OneObject;
    }
    InstallOneObject(0);

    /* make and install the 'ONE' arithmetic operation                     */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(OneMutFuncs[t1] == 0);
        OneMutFuncs[t1] = OneMutObject;
    }
    InstallOneMutObject(0);

    /* make and install the 'INV' arithmetic operation                     */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(InvFuncs[t1] == 0);
        InvFuncs[t1] = InvObject;
    }
    InstallInvObject(0);

    /* make and install the 'INV' arithmetic operation                     */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(InvMutFuncs[t1] == 0);
        InvMutFuncs[t1] = InvMutObject;
    }
    InstallInvMutObject(0);

    /* make and install the 'EQ' comparison operation                      */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(EqFuncs[t1][t2] == 0);
            EqFuncs[t1][t2] = EqNot;
        }
    }
    InstallEqObject(0);

    /* make and install the 'LT' comparison operation                      */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(LtFuncs[t1][t2] == 0);
            LtFuncs[t1][t2] = LtObject;
        }
    }
    InstallLtObject(0);

    /* make and install the 'IN' comparison operation                      */
    for ( t1 = FIRST_REAL_TNUM; t1 <= LAST_REAL_TNUM; t1++ ) {
        for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_REAL_TNUM; t2++ ) {
            assert(InFuncs[t1][t2] == 0);
            InFuncs[t1][t2] = InUndefined;
        }
    }
    InstallInObject(0);

    /* make and install the 'SUM' arithmetic operation                     */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(SumFuncs[t1][t2] == 0);
            SumFuncs[t1][t2] = SumObject;
        }
    }
    InstallSumObject(0);

    /* make and install the 'DIFF' arithmetic operation                    */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(DiffFuncs[t1][t2] == 0);
            DiffFuncs[t1][t2] = DiffDefault;
        }
    }
    InstallDiffObject(0);

    /* make and install the 'PROD' arithmetic operation                    */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(ProdFuncs[t1][t2] == 0);
            ProdFuncs[t1][t2] = ProdObject;
        }
    }
    InstallProdObject(0);

    /* make and install the 'QUO' arithmetic operation                     */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(QuoFuncs[t1][t2] == 0);
            QuoFuncs[t1][t2] = QuoDefault;
        }
    }
    InstallQuoObject(0);

    /* make and install the 'LQUO' arithmetic operation                    */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(LQuoFuncs[t1][t2] == 0);
            LQuoFuncs[t1][t2] = LQuoDefault;
        }
    }
    InstallLQuoObject(0);

    /* make and install the 'POW' arithmetic operation                     */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(PowFuncs[t1][t2] == 0);
            PowFuncs[t1][t2] = PowObject;
        }
    }
    InstallPowObject(0);

    /* make and install the 'COMM' arithmetic operation                    */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(CommFuncs[t1][t2] == 0);
            CommFuncs[t1][t2] = CommDefault;
        }
    }
    InstallCommObject(0);

    /* make and install the 'MOD' arithmetic operation                     */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        for ( t2 = FIRST_REAL_TNUM;  t2 <= LAST_REAL_TNUM;  t2++ ) {
            assert(ModFuncs[t1][t2] == 0);
            ModFuncs[t1][t2] = ModObject;
        }
    }
    InstallModObject(0);

    
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
    /* init filters and functions                                          */
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoAriths()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "ariths",                           /* name                           */
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

StructInitInfo * InitInfoAriths ( void )
{
    return &module;
}
