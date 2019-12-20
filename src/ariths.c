/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the  arithmetic  operations  package.
*/

#include "ariths.h"

#include "bool.h"
#include "error.h"
#include "modules.h"
#include "opers.h"
#include "tracing.h"

#define RequireValue(funcname, val)                                          \
    do {                                                                     \
        if (!val)                                                            \
            ErrorMayQuit(funcname ": method should have returned a value",   \
                         0, 0);                                              \
    } while (0);


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
static Obj ZEROOp;

static Obj ZeroObject(Obj obj)

{
  Obj val;
  val = DoOperation1Args( ZEROOp, obj );
  RequireValue("ZEROOp", val);
  return val;
}


/****************************************************************************
**
*F  VerboseZeroObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
static Obj VerboseZeroObject(Obj obj)

{
  Obj val;
  val = DoVerboseOperation1Args( ZEROOp, obj );
  RequireValue("ZEROOp", val);
  return val;
}


/****************************************************************************
**
*F  InstallZeroObject( <verb> ) . . . . . . . . . . . .  install zero methods
*/
static void InstallZeroObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* zero function                   */

    func = ( verb ? VerboseZeroObject : ZeroObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        ZeroFuncs[t1] = func;
    }
}


/****************************************************************************
**
*F  FuncZERO( <self>, <obj> ) . . . . . . . . . . . . . . . . . . call 'ZERO'
*/
static Obj FuncZERO(Obj self, Obj obj)
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
static Obj ZeroOp;

static Obj ZeroMutObject(Obj obj)

{
  Obj val;
  val = DoOperation1Args( ZeroOp, obj );
  RequireValue("ZeroOp", val);
  return val;
}


/****************************************************************************
**
*F  VerboseZeroMutObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
static Obj VerboseZeroMutObject(Obj obj)

{
  Obj val;
  val = DoVerboseOperation1Args( ZeroOp, obj );
  RequireValue("ZeroOp", val);
  return val;
}


/****************************************************************************
**
*F  InstallZeroMutObject( <verb> ) . . . . . . . . . . . .  install zero methods
*/
static void InstallZeroMutObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* zero function                   */

    func = ( verb ? VerboseZeroMutObject : ZeroMutObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        ZeroMutFuncs[t1] = func;
    }
}


/****************************************************************************
**
*F  FuncZERO_MUT( <self>, <obj> ) . . . . . . . . . . . . . . call 'ZERO_MUT'
*/
static Obj FuncZERO_MUT(Obj self, Obj obj)
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
static Obj AInvOp;

static Obj AInvObject(Obj obj)
{
  Obj val;
  val = DoOperation1Args( AInvOp, obj );
  RequireValue("AInvOp", val);
  return val;
}


/****************************************************************************
**
*F  VerboseAInvObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
static Obj VerboseAInvObject(Obj obj)
{
  Obj val;
  val = DoVerboseOperation1Args( AInvOp, obj );
  RequireValue("AInvOp", val);
  return val;
}


/****************************************************************************
**
*F  InstallAInvObject( <verb> ) . . . . . .  install additive inverse methods
*/
static void InstallAInvObject(Int verb)
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* ainv function                   */

    func = ( verb ? VerboseAInvObject : AInvObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        AInvFuncs[t1] = func;
    }
}


/****************************************************************************
**
*F  FuncAINV( <self>, <obj> ) . . . . . . . . . . . . . . . . . . call 'AINV'
*/
static Obj FuncAINV(Obj self, Obj obj)
{
    return AINV(obj);
}

/****************************************************************************
**
*F  AInvMutObject( <obj> )  . .. . . . . . . . . . . . . . . . .  call methsel
*/
static Obj AdditiveInverseOp;

static Obj AInvMutObject(Obj obj)
{
  Obj val;
  val = DoOperation1Args( AdditiveInverseOp, obj );
  RequireValue("AdditiveInverseOp", val);
  return val;
}


/****************************************************************************
**
*F  VerboseAInvMutObject( <obj> )  . . . . . . . . . . . .  call verbose methsel
*/
static Obj VerboseAInvMutObject(Obj obj)
{
  Obj val;
  val = DoVerboseOperation1Args( AdditiveInverseOp, obj );
  RequireValue("AdditiveInverseOp", val);
  return val;
}


/****************************************************************************
**
*F  InstallAInvMutObject( <verb> ) . . . . . install additive inverse methods
*/
static void InstallAInvMutObject(Int verb)
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* ainv function                   */

    func = ( verb ? VerboseAInvMutObject : AInvMutObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        AInvMutFuncs[t1] = func;
    }
}


/****************************************************************************
**
*F  FuncAINV_MUT( <self>, <obj> ) . . . . . . . . . . . . . . . . . . call 'AINV'
*/
static Obj FuncAINV_MUT(Obj self, Obj obj)
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
static Obj OneOp;

static Obj OneObject(Obj obj)
{
  Obj val;
  val = DoOperation1Args( OneOp, obj );
  RequireValue("OneOp", val);
  return val;
}


/****************************************************************************
**
*F  VerboseOneObject( <obj> ) . . . . . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseOneObject(Obj obj)
{
  Obj val;
  val = DoVerboseOperation1Args( OneOp, obj );
  RequireValue("OneOp", val);
  return val;
}


/****************************************************************************
**
*F  InstallOneObject( <verb> )  . . . . . . . . . . . . . install one methods
*/
static void InstallOneObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* one function                    */

    func = ( verb ? VerboseOneObject : OneObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        OneFuncs[t1] = func;
    }
}


/****************************************************************************
**
*F  FuncONE( <self>, <obj> ) . . . . . . . . . . . . . . . . .  call 'ONE'
*/
static Obj FuncONE(Obj self, Obj obj)
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
static Obj OneMutOp;

static Obj OneMutObject(Obj obj)
{
  Obj val;
  val = DoOperation1Args( OneMutOp, obj );
  RequireValue("ONEOp", val);
  return val;
}


/****************************************************************************
**
*F  VerboseOneMutObject( <obj> ) . . .  . . . . . . . . . . . .  call methsel
*/
static Obj VerboseOneMutObject(Obj obj)
{
  Obj val;
  val = DoVerboseOperation1Args( OneMutOp, obj );
  RequireValue("ONEOp", val);
  return val;
}


/****************************************************************************
**
*F  InstallOneMutObject( <verb> )  . . . . . . . . . . . . . install one methods
*/
static void InstallOneMutObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* one function                    */

    func = ( verb ? VerboseOneMutObject : OneMutObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        OneMutFuncs[t1] = func;
    }
}


/****************************************************************************
**
*F  FuncONE_MUT( <self>, <obj> ) . . . . . . . . . . . . . . . .call 'ONE_MUT'
*/
static Obj FuncONE_MUT(Obj self, Obj obj)
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
static Obj InvOp;

static Obj InvObject(Obj obj)
{
  Obj val;
  val = DoOperation1Args( InvOp, obj );
  RequireValue("InvOp", val);
  return val;
}


/****************************************************************************
**
*F  VerboseInvObject( <obj> ) . . . . . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseInvObject(Obj obj)
{
  Obj val;
  val = DoVerboseOperation1Args( InvOp, obj );
  RequireValue("InvOp", val);
  return val;
}


/****************************************************************************
**
*F  InstallInvObject( <verb> )  . . . . . . . . . . . install inverse methods
*/
static void InstallInvObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* inv function                    */

    func = ( verb ? VerboseInvObject : InvObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        InvFuncs[t1] = func;
    }
}


/****************************************************************************
**
*F  FuncINV( <self>, <obj> )  . . . . . . . . . . . . . . . . . .  call 'INV'
*/
static Obj FuncINV(Obj self, Obj obj)
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
static Obj InvMutOp;

static Obj InvMutObject(Obj obj)
{
  Obj val;
  val = DoOperation1Args( InvMutOp, obj );
  RequireValue("INVOp", val);
  return val;
}


/****************************************************************************
**
*F  VerboseInvMutObject( <obj> ) . . .  . . . . . . . . . . . .  call methsel
*/
static Obj VerboseInvMutObject(Obj obj)
{
  Obj val;
  val = DoVerboseOperation1Args( InvMutOp, obj );
  RequireValue("INVOp", val);
  return val;
}


/****************************************************************************
**
*F  InstallInvMutObject( <verb> ) install mutability preserving inverse methods
*/
static void InstallInvMutObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    ArithMethod1        func;           /* inv function                    */

    func = ( verb ? VerboseInvMutObject : InvMutObject );
    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        InvMutFuncs[t1] = func;
    }
}


/****************************************************************************
**
*F  FuncINV_MUT( <self>, <obj> )  . . .  . . . . . . . . . .  call 'INV_MUT'
*/
static Obj FuncINV_MUT(Obj self, Obj obj)
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
static Int EqNot(Obj opL, Obj opR)
{
    return 0;
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
static Int VerboseEqObject(Obj opL, Obj opR)
{
    return (DoVerboseOperation2Args( EqOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  InstallEqObject( <verb> ) . . . . . . . . . .  install comparison methods
*/
static void InstallEqObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncEQ( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . . . call 'EQ'
*/
static Obj FuncEQ(Obj self, Obj opL, Obj opR)
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

static Int LtObject(Obj opL, Obj opR)
{
    return (DoOperation2Args( LtOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  VerboseLtObject( <opL>, <opR> ) . . . . . . . . . . . . . .  call methsel
*/
static Int VerboseLtObject(Obj opL, Obj opR)
{
    return (DoVerboseOperation2Args( LtOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  InstallLtObject( <verb> ) . . . . . . . . . . . install less than methods
*/
static void InstallLtObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncLT( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . . . call 'LT'
*/
static Obj FuncLT(Obj self, Obj opL, Obj opR)
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
static Int InUndefined(Obj opL, Obj opR)
{
    ErrorMayQuit("operations: IN of %s and %s is not defined",
                 (Int)TNAM_OBJ(opL), (Int)TNAM_OBJ(opR));
}


/****************************************************************************
**
*F  InObject( <opL>, <opR> )  . . . . . . . . . . . . . . . . .  call methsel
*/
static Obj InOper;

static Int InObject(Obj opL, Obj opR)
{
    return (DoOperation2Args( InOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  VerboseInObject( <opL>, <opR> ) . . . . . . . . . . . . . .  call methsel
*/
static Int VerboseInObject(Obj opL, Obj opR)
{
    return (DoVerboseOperation2Args( InOper, opL, opR ) == True);
}


/****************************************************************************
**
*F  InstallInObject( <verb> ) . . . . . . . . . . . . . .  install in methods
*/
static void InstallInObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncIN( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . . . call 'IN'
*/
static Obj FuncIN(Obj self, Obj opL, Obj opR)
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

static Obj SumObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( SumOper, opL, opR );
  RequireValue("SUM", val);
  return val;
}


/****************************************************************************
**
*F  VerboseSumObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseSumObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoVerboseOperation2Args( SumOper, opL, opR );
  RequireValue("SUM", val);
  return val;
}


/****************************************************************************
**
*F  InstallSumObject( <verb> )  . . . . . . . . . . . . . install sum methods
*/
static void InstallSumObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncSUM( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . .  call 'SUM'
*/
static Obj FuncSUM(Obj self, Obj opL, Obj opR)
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
static Obj DiffDefault(Obj opL, Obj opR)
{
    Obj                 tmp;

    tmp = AINV( opR );
    return SUM( opL, tmp );
}


/****************************************************************************
**
*F  DiffObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
static Obj DiffOper;

static Obj DiffObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( DiffOper, opL, opR );
  RequireValue("DIFF", val);
  return val;
}


/****************************************************************************
**
*F  VerboseDiffObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseDiffObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoVerboseOperation2Args( DiffOper, opL, opR );
  RequireValue("DIFF", val);
  return val;
}


/****************************************************************************
**
*F  InstallDiffObject( <verb> ) . . . . . . . . .  install difference methods
*/
static void InstallDiffObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncDIFF_DEFAULT( <self>, <opL>, <opR> )  . . . . . .  call 'DiffDefault'
*/
static Obj FuncDIFF_DEFAULT(Obj self, Obj opL, Obj opR)
{
    return DiffDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncDIFF( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . call 'DIFF'
*/
static Obj FuncDIFF(Obj self, Obj opL, Obj opR)
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
static Obj ProdOper;

static Obj ProdObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( ProdOper, opL, opR );
  RequireValue("PROD", val);
  return val;
}


/****************************************************************************
**
*F  VerboseProdObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseProdObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoVerboseOperation2Args( ProdOper, opL, opR );
  RequireValue("PROD", val);
  return val;
}


/****************************************************************************
**
*F  InstallProdObject( <verb> ) . . . . . . . . . . . install product methods
*/
static void InstallProdObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncPROD( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . call 'PROD'
*/
static Obj FuncPROD(Obj self, Obj opL, Obj opR)
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
static Obj QuoDefault(Obj opL, Obj opR)
{
    Obj                 tmp;
    tmp = INV_MUT( opR );
    return PROD( opL, tmp );
}


/****************************************************************************
**
*F  QuoObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
static Obj QuoOper;

static Obj QuoObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( QuoOper, opL, opR );
  RequireValue("QUO", val);
  return val;
}


/****************************************************************************
**
*F  VerboseQuoObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseQuoObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoVerboseOperation2Args( QuoOper, opL, opR );
  RequireValue("QUO", val);
  return val;
}


/****************************************************************************
**
*F  InstallQuoObject( <verb> )  . . . . . . . . . .  install quotient methods
*/
static void InstallQuoObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncQUO_DEFAULT( <self>, <opL>, <opR> ) . . . . . . . . call 'QuoDefault'
*/
static Obj FuncQUO_DEFAULT(Obj self, Obj opL, Obj opR)
{
    return QuoDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncQUO( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . .  call 'QUO'
*/
static Obj FuncQUO(Obj self, Obj opL, Obj opR)
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
static Obj LQuoDefault(Obj opL, Obj opR)
{
    Obj                 tmp;
    tmp = INV_MUT( opL );
    return PROD( tmp, opR );
}


/****************************************************************************
**
*F  LQuoObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
static Obj LQuoOper;

static Obj LQuoObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( LQuoOper, opL, opR );
  RequireValue("LeftQuotient", val);
  return val;
}


/****************************************************************************
**
*F  VerboseLQuoObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseLQuoObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( LQuoOper, opL, opR );
  RequireValue("LeftQuotient", val);
  return val;
}


/****************************************************************************
**
*F  InstallLQuoObject( <verb> ) . . . . . . . . install left quotient methods
*/
static void InstallLQuoObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncLQUO_DEFAULT( <self>, <opL>, <opR> )  . . . . . .  call 'LQuoDefault'
*/
static Obj FuncLQUO_DEFAULT(Obj self, Obj opL, Obj opR)
{
    return LQuoDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncLQUO( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . call 'LQUO'
*/
static Obj FuncLQUO(Obj self, Obj opL, Obj opR)
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
static Obj PowDefault(Obj opL, Obj opR)
{
    Obj                 tmp;
    tmp = LQUO( opR, opL );
    return PROD( tmp, opR );
}


/****************************************************************************
**
*F  PowObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
static Obj PowOper;

static Obj PowObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( PowOper, opL, opR );
  RequireValue("POW", val);
  return val;
}


/****************************************************************************
**
*F  VerbosePowObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
static Obj VerbosePowObject(Obj opL, Obj opR)
{
   
  Obj val;
  val = DoVerboseOperation2Args( PowOper, opL, opR );
  RequireValue("POW", val);
  return val;
}


/****************************************************************************
**
*F  InstallPowObject( <verb> )  . . . . . . . . . . install the power methods
*/
static void InstallPowObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncPOW_DEFAULT( <self>, <opL>, <opR> ) . . . . . . . . call 'PowDefault'
*/
static Obj FuncPOW_DEFAULT(Obj self, Obj opL, Obj opR)
{
    return PowDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncPOW( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . .  call 'POW'
*/
static Obj FuncPOW(Obj self, Obj opL, Obj opR)
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
static Obj CommDefault(Obj opL, Obj opR)
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
static Obj CommOper;

static Obj CommObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( CommOper, opL, opR );
  RequireValue("Comm", val);
  return val;
}


/****************************************************************************
**
*F  VerboseCommObject( <opL>, <opR> ) . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseCommObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoVerboseOperation2Args( CommOper, opL, opR );
  RequireValue("Comm", val);
  return val;
}


/****************************************************************************
**
*F  InstallCommObject( <verb> ) . . . . . . . . .  install commutator methods
*/
static void InstallCommObject ( Int verb )
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
}


/****************************************************************************
**
*F  FuncCOMM_DEFAULT( <self>, <opL>, <opR> )  . . . . . .  call 'CommDefault'
*/
static Obj FuncCOMM_DEFAULT(Obj self, Obj opL, Obj opR)
{
    return CommDefault( opL, opR );
}


/****************************************************************************
**
*F  FuncCOMM( <self>, <opL>, <opR> )  . . . . . . . . . . . . . . call 'COMM'
*/
static Obj FuncCOMM(Obj self, Obj opL, Obj opR)
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
static Obj ModOper;

static Obj ModObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoOperation2Args( ModOper, opL, opR );
  RequireValue("mod", val);
  return val;
}


/****************************************************************************
**
*F  VerboseModObject( <opL>, <opR> )  . . . . . . . . . . . . .  call methsel
*/
static Obj VerboseModObject(Obj opL, Obj opR)
{
  Obj val;
  val = DoVerboseOperation2Args( ModOper, opL, opR );
  RequireValue("mod", val);
  return val;
}


/****************************************************************************
**
*F  InstallModObject( <verb> )  . . . . . . . . . . . install the mod methods
*/
static void InstallModObject ( Int verb )
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
}

DEFINE_OP_WRAPPER1(ZeroFuncs);
DEFINE_OP_WRAPPER1(ZeroMutFuncs);
DEFINE_OP_WRAPPER1(AInvFuncs);
DEFINE_OP_WRAPPER1(AInvMutFuncs);
DEFINE_OP_WRAPPER1(OneFuncs);
DEFINE_OP_WRAPPER1(OneMutFuncs);
DEFINE_OP_WRAPPER1(InvFuncs);
DEFINE_OP_WRAPPER1(InvMutFuncs);

DEFINE_OP_WRAPPER2(SumFuncs);
DEFINE_OP_WRAPPER2(DiffFuncs);
DEFINE_OP_WRAPPER2(ProdFuncs);
DEFINE_OP_WRAPPER2(QuoFuncs);
DEFINE_OP_WRAPPER2(LQuoFuncs);
DEFINE_OP_WRAPPER2(PowFuncs);
DEFINE_OP_WRAPPER2(CommFuncs);
DEFINE_OP_WRAPPER2(ModFuncs);

static void InstallArithWrappers(void)
{
    INSTALL_OP_WRAPPER(ZeroFuncs);
    INSTALL_OP_WRAPPER(ZeroMutFuncs);
    INSTALL_OP_WRAPPER(AInvFuncs);
    INSTALL_OP_WRAPPER(AInvMutFuncs);
    INSTALL_OP_WRAPPER(OneFuncs);
    INSTALL_OP_WRAPPER(InvFuncs);
    INSTALL_OP_WRAPPER(OneMutFuncs);
    INSTALL_OP_WRAPPER(InvMutFuncs);

    INSTALL_OP_WRAPPER(SumFuncs);
    INSTALL_OP_WRAPPER(DiffFuncs);
    INSTALL_OP_WRAPPER(ProdFuncs);
    INSTALL_OP_WRAPPER(QuoFuncs);
    INSTALL_OP_WRAPPER(LQuoFuncs);
    INSTALL_OP_WRAPPER(PowFuncs);
    INSTALL_OP_WRAPPER(CommFuncs);
    INSTALL_OP_WRAPPER(ModFuncs);
}

/****************************************************************************
**
*F  FuncMOD( <self>, <opL>, <opR> ) . . . . . . . . . . . . . . .  call 'MOD'
*/
static Obj FuncMOD(Obj self, Obj opL, Obj opR)
{
    return MOD( opL, opR );
}


/****************************************************************************
**
*F  ChangeArithDoOperations( <oper>, <verb> )
*/
void ChangeArithDoOperations(Obj oper, Int verb)
{
    /* catch infix operations                                          */
    if ( oper == EqOper   )  { InstallEqObject(verb);   }
    if ( oper == LtOper   )  { InstallLtObject(verb);   }
    if ( oper == InOper   )  { InstallInObject(verb);   }
    if ( oper == SumOper  )  { InstallSumObject(verb);  }
    if ( oper == DiffOper )  { InstallDiffObject(verb); }
    if ( oper == ProdOper )  { InstallProdObject(verb); }
    if ( oper == QuoOper  )  { InstallQuoObject(verb);  }
    if ( oper == LQuoOper )  { InstallLQuoObject(verb); }
    if ( oper == PowOper  )  { InstallPowObject(verb);  }
    if ( oper == CommOper )  { InstallCommObject(verb); }
    if ( oper == ModOper  )  { InstallModObject(verb);  }

    if ( oper == InvOp  )  { InstallInvObject(verb);  }
    if ( oper == OneOp  )  { InstallOneObject(verb);  }
    if ( oper == AInvOp )  { InstallAInvObject(verb); }
    if ( oper == ZEROOp )  { InstallZeroObject(verb); }

    if ( oper == InvMutOp  )  { InstallInvMutObject(verb);  }
    if ( oper == OneMutOp  )  { InstallOneMutObject(verb);  }
    if ( oper == AdditiveInverseOp )  { InstallAInvMutObject(verb); }
    if ( oper == ZeroOp )  { InstallZeroMutObject(verb); }
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    GVAR_OPER_2ARGS(EQ, opL, opR, &EqOper),
    GVAR_OPER_2ARGS(LT, opL, opR, &LtOper),
    GVAR_OPER_2ARGS(IN, opL, opR, &InOper),
    GVAR_OPER_2ARGS(SUM, opL, opR, &SumOper),
    GVAR_OPER_2ARGS(DIFF, opL, opR, &DiffOper),
    GVAR_OPER_2ARGS(PROD, opL, opR, &ProdOper),
    GVAR_OPER_2ARGS(QUO, opL, opR, &QuoOper),
    GVAR_OPER_2ARGS(LQUO, opL, opR, &LQuoOper),
    GVAR_OPER_2ARGS(POW, opL, opR, &PowOper),
    GVAR_OPER_2ARGS(COMM, opL, opR, &CommOper),
    GVAR_OPER_2ARGS(MOD, opL, opR, &ModOper),
    GVAR_OPER_1ARGS(ZERO, op, &ZEROOp),
    GVAR_OPER_1ARGS(ZERO_MUT, op, &ZeroOp),
    GVAR_OPER_1ARGS(AINV, op, &AInvOp),
    GVAR_OPER_1ARGS(AINV_MUT, op, &AdditiveInverseOp),
    GVAR_OPER_1ARGS(ONE, op, &OneOp),
    GVAR_OPER_1ARGS(ONE_MUT, op, &OneMutOp),
    GVAR_OPER_1ARGS(INV, op, &InvOp),
    GVAR_OPER_1ARGS(INV_MUT, op, &InvMutOp),
    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_2ARGS(COMM_DEFAULT, opL, opR),
    GVAR_FUNC_2ARGS(POW_DEFAULT, opL, opR),
    GVAR_FUNC_2ARGS(LQUO_DEFAULT, opL, opR),
    GVAR_FUNC_2ARGS(QUO_DEFAULT, opL, opR),
    GVAR_FUNC_2ARGS(DIFF_DEFAULT, opL, opR),
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

    InstallArithWrappers();

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
    InstallZeroMutObject(0);

    /* make and install the 'AINV' arithmetic operation                    */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(AInvFuncs[t1] == 0);
        AInvFuncs[t1] = AInvObject;
    }
    InstallAInvObject(0);

    /* make and install the 'AINV_MUT' arithmetic operation                */
    for ( t1 = FIRST_REAL_TNUM;  t1 <= LAST_REAL_TNUM;  t1++ ) {
        assert(AInvMutFuncs[t1] == 0);
        AInvMutFuncs[t1] = AInvMutObject;
    }
    InstallAInvMutObject(0);

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

    return 0;
}


/****************************************************************************
**
*F  InitInfoAriths()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "ariths",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoAriths ( void )
{
    return &module;
}
