/****************************************************************************
**
*W  ariths.c                    GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of the  arithmetic  operations  package.
*/
char * Revision_ariths_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* InfoBags                        */
#include        "objects.h"             /* TNUM_OBJ, FIRST_VIRTUAL_TNUM,...*/

#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* ObjFunc                         */
#include        "opers.h"               /* NewOperation, DoOperation2Args  */

#define INCLUDE_DECLARATION_PART
#include        "ariths.h"              /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "bool.h"                /* True, False                     */

#include        "gap.h"                 /* Error                           */


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

*F  ZERO( <op> )  . . . . . . . . . . . . . . . . . . . . . zero of an object
**
**  'ZERO' returns the zero of the object <op>.
**
**  'ZERO' is defined in the declaration part of this package as follows
**
#define ZERO(op)        ((*ZeroFuncs[TNUM_OBJ(op)])(op))
*/
Obj ZeroAttr;


/****************************************************************************
**
*V  ZeroFuncs[ <type> ] . . . . . . . . . . . . . . . . table of zero methods
*/
ArithMethod1 ZeroFuncs [LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  ZeroObject( <obj> ) . . . . . . . . . . . . . . . . . . . .  call methsel
*/
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
    ZeroFuncs[T_OBJECT] = func;
}


/****************************************************************************
**

*F  AINV( <obj> ) . . . . . . . . . . . . . . . additive inverse of an object
**
**  'AINV' returns the additive inverse of the object <obj>.
**
**  'AINV' is defined in the declaration part of this package as follows
**
#define AINV(obj)        ((*AInvFuncs[TNUM_OBJ(obj)])(obj))
*/
Obj AInvAttr;


/****************************************************************************
**
*V  AInvFuncs[ <type> ] . . . . . . . . . . table of additive inverse methods
*/
ArithMethod1 AInvFuncs [LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  AInvObj( <obj> )  . . . . . . . . . . . . . . . . . . . . .  call methsel
*/
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
    AInvFuncs[T_OBJECT] = func;
}


/****************************************************************************
**

*F  ONE( <obj> )  . . . . . . . . . . . . . . . . . . . . .  one of an object
**
**  'ONE' returns the one of the object <op>.
**
**  'ONE' is defined in the declaration part of this package as follows
**
#define ONE(obj)         ((*OneFuncs[TNUM_OBJ(obj)])(obj))
*/
Obj OneAttr;


/****************************************************************************
**
*V  OneFuncs[ <type> ]  . . . . . . . . . . . . . . . .  table of one methods
*/
ArithMethod1 OneFuncs [LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  OneObject( <obj> )  . . . . . . . . . . . . . . . . . . . .  call methsel
*/
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
    OneFuncs[T_OBJECT] = func;
}


/****************************************************************************
**

*F  INV( <obj> )  . . . . . . . . . . . . . . . . . . .  inverse of an object
**
**  'INV' returns the multiplicative inverse of the object <obj>.
**
**  'INV' is defined in the declaration of this package as follows
**
#define INV(obj)         ((*InvFuncs[TNUM_OBJ(obj)])(obj))
*/
Obj InvAttr;


/****************************************************************************
**
*V  InvFuncs[ <type> ]  . . . . . . . . . . . . .  table of inverse functions
*/
ArithMethod1 InvFuncs [LAST_VIRTUAL_TNUM+1];

    
/****************************************************************************
**
*F  InvObject( <obj> )  . . . . . . . . . . . . . . . . . . . .  call methsel
*/
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
    InvFuncs[T_OBJECT] = func;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * comparison operations  * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  EQ( <opL>, <opR> )  . . . . . . . . . . . . . . comparison of two objects
**
**  'EQ' returns a nonzero value  if the object <opL>  is equal to the object
**  <opR>, and zero otherwise.
**
**  'EQ' is defined in the declaration part of this package as follows
**
#define EQ(opL,opR)     ((opL) == (opR) || \
                         (!ARE_INTOBJS(opL,opR) && \
                          (*EqFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR)))

#define EQ2(opL,opR)    ((opL) == (opR) || \
                          (*EqFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj EqOper;


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
        EqFuncs[t2][T_OBJECT] = func;
        EqFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  LT( <opL>, <opR> )  . . . . . . . . . . . . . . comparison of two objects
**
**  'LT' returns a nonzero value if the object <opL> is  less than the object
**  <opR>, and zero otherwise.
**
**  'LT' is defined in the declaration part of this package as follows
**
#define LT(opL,opR)     ((opL) == (opR) ? 0 : \
                         (ARE_INTOBJS(opL,opR) ? (Int)(opL) < (Int)(opR) : \
                          (*LtFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR)))

#define LT2(opL,opR)    ((opL) == (opR) ? 0 : \
                          (*LtFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj LtOper;


/****************************************************************************
**
*V  LtFuncs[ <typeL> ][ <typeR> ] . . . . . . . . table of comparison methods
*/
CompaMethod LtFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  LtObject( <opL>, <opR> )  . . . . . . . . . . . . . . . . .  call methsel
*/
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
        LtFuncs[t2][T_OBJECT] = func;
        LtFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  IN( <opL>, <opR> )  . . . . . . . . . . .  membership test of two objects
**
**  'IN' returns a nonzero   value if the object  <opL>  is a member  of  the
**  object <opR>, and zero otherwise.
**
**  'IN' is defined in the declaration part of this package as follows
**
#define IN(opL,opR)     ((*InFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj InOper;


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
        InFuncs[t2][T_OBJECT] = func;
        InFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F * * * * * * * * * * * binary arithmetic operations * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  SUM( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  sum of two objects
**
**  'SUM' returns the sum of the two objects <opL> and <opR>.
**
**  'SUM' is defined in the declaration part of this package as follows
**
#define SUM(opL,opR)    ((*SumFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj SumOper;


/****************************************************************************
**
*V  SumFuncs[ <typeL> ][ <typeR> ]  . . . . . . . . . .  table of sum methods
*/
ArithMethod2    SumFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  SumObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
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
    for ( t2 = FIRST_REAL_TNUM; t2 <= LAST_VIRTUAL_TNUM; t2++ ) {
        SumFuncs[t2][T_OBJECT] = func;
        SumFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  DIFF( <opL>, <opR> )  . . . . . . . . . . . . . difference of two objects
**
**  'DIFF' returns the difference of the two objects <opL> and <opR>.
**
**  'DIFF' is defined in the declaration part of this package as follows
**
#define DIFF(opL,opR)   ((*DiffFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj DiffOper;


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
        DiffFuncs[t2][T_OBJECT] = func;
        DiffFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  PROD( <opL>, <opR> )  . . . . . . . . . . . . . .  product of two objects
**
**  'PROD' returns the product of the two objects <opL> and <opR>.
**
**  'PROD' is defined in the declaration part of this package as follows
**
#define PROD(opL,opR)   ((*ProdFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj ProdOper;


/****************************************************************************
**
*V  ProdFuncs[ <typeL> ][ <typeR> ] . . . . . . . .  table of product methods
*/
ArithMethod2    ProdFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];


/****************************************************************************
**
*F  ProdObject( <opL>, <opR> )  . . . . . . . . . . . . . . . .  call methsel
*/
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
        ProdFuncs[t2][T_OBJECT] = func;
        ProdFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  QUO( <opL>, <opR> ) . . . . . . . . . . . . . . . quotient of two objects
**
**  'QUO' returns the quotient of the object <opL> by the object <opR>.
**
**  'QUO' is defined in the declaration part of this package as follows
**
#define QUO(opL,opR)    ((*QuoFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj QuoOper;


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
        QuoFuncs[t2][T_OBJECT] = func;
        QuoFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  LQUO( <opL>, <opR> )  . . . . . . . . . . .  left quotient of two operand
**
**  'LQUO' returns the left quotient of the object <opL> by the object <opR>.
**
**  'LQUO' is defined in the declaration part of this package as follows
**
#define LQUO(opL,opR)   ((*LQuoFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj LQuoOper;


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
        LQuoFuncs[t2][T_OBJECT] = func;
        LQuoFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  POW( <opL>, <opR> ) . . . . . . . . . . . . . . . .  power of two objects
**
**  'POW' returns the power of the object <opL> by the object <opL>.
**
**  'POW' is defined in the declaration part of this package as follows
**
#define POW(opL,opR)    ((*PowFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj PowOper;


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
        PowFuncs[t2][T_OBJECT] = func;
        PowFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  COMM( <opL>, <opR> )  . . . . . . . . . . . . . commutator of two objects
**
**  'COMM' returns the commutator of the two objects <opL> and <opR>.
**
**  'COMM' is defined in the declaration part of this package as follows
**
#define COMM(opL,opR)   ((*CommFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj CommOper;


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
        CommFuncs[t2][T_OBJECT] = func;
        CommFuncs[T_OBJECT][t2] = func;
    }
}


/****************************************************************************
**

*F  MOD( <opL>, <opR> ) . . . . . . . . . . . . . .  remainder of two objects
**
**  'MOD' returns the remainder of the object <opL> by the object <opR>.
**
**  'MOD' is defined in the declaration part of this package as follows
**
#define MOD(opL,opR)    ((*ModFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))
*/
Obj ModOper;


/****************************************************************************
**
*V  ModFuncs[ <typeL> ][ <typeR> ]  . . . . . . .  table of remainder methods
*/
ArithMethod2 ModFuncs [LAST_VIRTUAL_TNUM+1][LAST_VIRTUAL_TNUM+1];



/****************************************************************************
**
*F  ModObject( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  call methsel
*/
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
        ModFuncs[t2][T_OBJECT] = func;
        ModFuncs[T_OBJECT][t2] = func;
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
