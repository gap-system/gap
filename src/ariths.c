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
char *          Revision_ariths_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* InfoBags                        */
#include        "objects.h"             /* TYPE_OBJ, FIRST_VIRTUAL_TYPE,...*/
#include        "scanner.h"             /* Pr                              */

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
typedef Int     (* CompaMethod) ( Obj opL, Obj opR );
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
typedef Obj     (* ArithMethod1) ( Obj opL, Obj opR );
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
typedef Obj     (* ArithMethod2) ( Obj opL, Obj opR );
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
                          (*EqFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR)))

#define EQ2(opL,opR)    ((opL) == (opR) || \
                          (*EqFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj EqOper;

Obj EqHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return (EQ( opL, opR ) ? True : False);
}

Int EqNot (
    Obj                 opL,
    Obj                 opR )
{
    return 0L;
}

Int EqObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoOperation2Args( EqOper, opL, opR ) == True);
}

Int VerboseEqObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoVerboseOperation2Args( EqOper, opL, opR ) == True);
}


/****************************************************************************
**
*V  EqFuncs[<typeL>][<typeR>] . . . . . . . . . . table of comparison methods
*/
CompaMethod EqFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallEqObject( <verb> )
*/
void InstallEqObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		EqFuncs[ t1 ][ t2 ] = VerboseEqObject;
		EqFuncs[ t2 ][ t1 ] = VerboseEqObject;
	    }
	    else {
		EqFuncs[ t1 ][ t2 ] = EqObject;
		EqFuncs[ t2 ][ t1 ] = EqObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    EqFuncs[ t2 ][ T_OBJECT ] = VerboseEqObject;
	    EqFuncs[ T_OBJECT ][ t2 ] = VerboseEqObject;
	}
	else {
	    EqFuncs[ t2 ][ T_OBJECT ] = EqObject;
	    EqFuncs[ T_OBJECT ][ t2 ] = EqObject;
	}
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
                          (*LtFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR)))

#define LT2(opL,opR)    ((opL) == (opR) ? 0 : \
                          (*LtFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj LtOper;

Obj LtHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return (LT( opL, opR ) ? True : False);
}

Int LtUndefined (
    Obj                 opL,
    Obj                 opR )
{
    return (ErrorReturnObj(
        "operations: LT of %s and %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(opL)].name),
        (Int)(InfoBags[TYPE_OBJ(opR)].name),
        "you can return a value for the result" ) == True);
}

Int LtObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoOperation2Args( LtOper, opL, opR ) == True);
}

Int VerboseLtObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoVerboseOperation2Args( LtOper, opL, opR ) == True);
}


/****************************************************************************
**
*V  LtFuncs[<typeL>][<typeR>] . . . . . . . . . . table of comparison methods
*/
CompaMethod LtFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallLtObject( <verb> )
*/
void InstallLtObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		LtFuncs[ t1 ][ t2 ] = VerboseLtObject;
		LtFuncs[ t2 ][ t1 ] = VerboseLtObject;
	    }
	    else {
		LtFuncs[ t1 ][ t2 ] = LtObject;
		LtFuncs[ t2 ][ t1 ] = LtObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    LtFuncs[ t2 ][ T_OBJECT ] = VerboseLtObject;
	    LtFuncs[ T_OBJECT ][ t2 ] = VerboseLtObject;
	}
	else {
	    LtFuncs[ t2 ][ T_OBJECT ] = LtObject;
	    LtFuncs[ T_OBJECT ][ t2 ] = LtObject;
	}
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
#define IN(opL,opR)     ((*InFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj InOper;

Obj InHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return (IN( opL, opR ) ? True : False);
}

Int InUndefined (
    Obj                 opL,
    Obj                 opR )
{
    return (ErrorReturnObj(
        "operations: IN of %s and %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(opL)].name),
        (Int)(InfoBags[TYPE_OBJ(opR)].name),
        "you can return a value for the result" ) == True);
}

Int InObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoOperation2Args( InOper, opL, opR ) == True);
}

Int VerboseInObject (
    Obj                 opL,
    Obj                 opR )
{
    return (DoVerboseOperation2Args( InOper, opL, opR ) == True);
}


/****************************************************************************
**
*V  InFuncs[<typeL>][<typeR>] . . . . . . . . . . table of membership methods
*/
CompaMethod InFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallInObject( <verb> )
*/
void InstallInObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		InFuncs[ t1 ][ t2 ] = VerboseInObject;
		InFuncs[ t2 ][ t1 ] = VerboseInObject;
	    }
	    else {
		InFuncs[ t1 ][ t2 ] = InObject;
		InFuncs[ t2 ][ t1 ] = InObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    InFuncs[ t2 ][ T_OBJECT ] = VerboseInObject;
	    InFuncs[ T_OBJECT ][ t2 ] = VerboseInObject;
	}
	else {
	    InFuncs[ t2 ][ T_OBJECT ] = InObject;
	    InFuncs[ T_OBJECT ][ t2 ] = InObject;
	}
    }
}


/****************************************************************************
**

*F  SUM( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  sum of two objects
**
**  'SUM' returns the sum of the two objects <opL> and <opR>.
**
**  'SUM' is defined in the declaration part of this package as follows
**
#define SUM(opL,opR)    ((*SumFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj SumOper;

Obj SumHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return SUM( opL, opR );
}

Obj SumUndefined (
    Obj                 opL,
    Obj                 opR )
{
    return ErrorReturnObj(
        "operations: SUM of %s and %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(opL)].name),
        (Int)(InfoBags[TYPE_OBJ(opR)].name),
        "you can return a value for the result" );
}

Obj SumObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( SumOper, opL, opR );
}

Obj VerboseSumObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( SumOper, opL, opR );
}


/****************************************************************************
**
*V  SumFuncs[<typeL>][<typeR>]  . . . . . . . . . . . .  table of sum methods
*/
ArithMethod2    SumFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallSumObject( <verb> )
*/
void InstallSumObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		SumFuncs[ t1 ][ t2 ] = VerboseSumObject;
		SumFuncs[ t2 ][ t1 ] = VerboseSumObject;
	    }
	    else {
		SumFuncs[ t1 ][ t2 ] = SumObject;
		SumFuncs[ t2 ][ t1 ] = SumObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    SumFuncs[ t2 ][ T_OBJECT ] = VerboseSumObject;
	    SumFuncs[ T_OBJECT ][ t2 ] = VerboseSumObject;
	}
	else {
	    SumFuncs[ t2 ][ T_OBJECT ] = SumObject;
	    SumFuncs[ T_OBJECT ][ t2 ] = SumObject;
	}
    }
}


/****************************************************************************
**

*F  ZERO( <op> )  . . . . . . . . . . . . . . . . . . . . . zero of an object
**
**  'ZERO' returns the zero of the object <op>.
**
**  'ZERO' is defined in the declaration part of this package as follows
**
#define ZERO(op)        ((*ZeroFuncs[TYPE_OBJ(op)])(op))
*/
Obj ZeroAttr;

Obj ZeroHandler (
    Obj                 self,
    Obj                 op )
{
    return ZERO( op );
}

Obj ZeroUndefined (
    Obj                 op )
{
    return ErrorReturnObj(
        "operations: ZERO of %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(op)].name),
        0L,
        "you can return a value for the result" );
}

Obj ZeroObject (
    Obj                 op )

{
    return DoAttribute( ZeroAttr, op );
}

Obj VerboseZeroObject (
    Obj                 op )

{
    return DoVerboseAttribute( ZeroAttr, op );
}


/****************************************************************************
**
*V  ZeroFuncs[<type>] . . . . . . . . . . . . . . . . . table of zero methods
*/
ArithMethod1 ZeroFuncs [LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallZeroObject( <verb> )
*/
void InstallZeroObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
	if ( verb ) {
	    ZeroFuncs[ t1 ] = VerboseZeroObject;
	}
	else {
	    ZeroFuncs[ t1 ] = ZeroObject;
	}
    }
    if ( verb ) {
	ZeroFuncs[ t1 ] = VerboseZeroObject;
    }
    else {
	ZeroFuncs[ T_OBJECT ] = ZeroObject;
    }
}


/****************************************************************************
**

*F  AINV( <op> )  . . . . . . . . . . . . . . . additive inverse of an object
**
**  'AINV' returns the additive inverse of the object <op>.
**
**  'AINV' is defined in the declaration part of this package as follows
**
#define AINV(op)        ((*AInvFuncs[TYPE_OBJ(op)])(op))
*/
Obj AInvAttr;

Obj AInvHandler (
    Obj                 self,
    Obj                 op )
{
    return AINV( op );
}

Obj AInvUndefined (
    Obj                 op )
{
    return ErrorReturnObj(
        "operations: AINV of %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(op)].name),
        0L,
        "you can return a value for the result" );
}

Obj AInvObject (
    Obj                 op )
{
    return DoAttribute( AInvAttr, op );
}

Obj VerboseAInvObject (
    Obj                 op )
{
    return DoVerboseAttribute( AInvAttr, op );
}


/****************************************************************************
**
*V  AInvFuncs[<type>] . . . . . . . . . . . table of additive inverse methods
*/
ArithMethod1 AInvFuncs [LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallAinvObject( <verb> )
*/
void InstallAinvObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
	if ( verb ) {
	    AInvFuncs[ t1 ] = VerboseAInvObject;
	}
	else {
	    AInvFuncs[ t1 ] = AInvObject;
	}
    }
    if ( verb ) {
	AInvFuncs[ T_OBJECT ] = VerboseAInvObject;
    }
    else {
	AInvFuncs[ T_OBJECT ] = AInvObject;
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
#define DIFF(opL,opR)   ((*DiffFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj DiffOper;

Obj DiffHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return DIFF( opL, opR );
}

Obj DiffDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = AINV( opR );
    return SUM( opL, tmp );
}    

Obj DiffObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( DiffOper, opL, opR );
}

Obj VerboseDiffObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( DiffOper, opL, opR );
}

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
*V  DiffFuncs[<typeL>][<typeR>] . . . . . . . . . table of difference methods
*/
ArithMethod2    DiffFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallDiffObject( <verb> )
*/
void InstallDiffObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		DiffFuncs[ t1 ][ t2 ] = VerboseDiffObject;
		DiffFuncs[ t2 ][ t1 ] = VerboseDiffObject;
	    }
	    else {
		DiffFuncs[ t1 ][ t2 ] = DiffObject;
		DiffFuncs[ t2 ][ t1 ] = DiffObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    DiffFuncs[ t2 ][ T_OBJECT ] = VerboseDiffObject;
	    DiffFuncs[ T_OBJECT ][ t2 ] = VerboseDiffObject;
	}
	else {
	    DiffFuncs[ t2 ][ T_OBJECT ] = DiffObject;
	    DiffFuncs[ T_OBJECT ][ t2 ] = DiffObject;
	}
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
#define PROD(opL,opR)   ((*ProdFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj ProdOper;

Obj ProdHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return PROD( opL, opR );
}

Obj ProdUndefined (
    Obj                 opL,
    Obj                 opR )
{
    return ErrorReturnObj(
        "operations: PROD of %s and %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(opL)].name),
        (Int)(InfoBags[TYPE_OBJ(opR)].name),
        "you can return a value for the result" );
}

Obj ProdObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( ProdOper, opL, opR );
}


Obj VerboseProdObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( ProdOper, opL, opR );
}


/****************************************************************************
**
*V  ProdFuncs[<typeL>][<typeR>] . . . . . . . . . .  table of product methods
*/
ArithMethod2    ProdFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallProdObject( <verb> )
*/
void InstallProdObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		ProdFuncs[ t1 ][ t2 ] = VerboseProdObject;
		ProdFuncs[ t2 ][ t1 ] = VerboseProdObject;
	    }
	    else {
		ProdFuncs[ t1 ][ t2 ] = ProdObject;
		ProdFuncs[ t2 ][ t1 ] = ProdObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    ProdFuncs[ t2 ][ T_OBJECT ] = VerboseProdObject;
	    ProdFuncs[ T_OBJECT ][ t2 ] = VerboseProdObject;
	}
	else {
	    ProdFuncs[ t2 ][ T_OBJECT ] = ProdObject;
	    ProdFuncs[ T_OBJECT ][ t2 ] = ProdObject;
	}
    }
}


/****************************************************************************
**

*F  ONE( <op> ) . . . . . . . . . . . . . . . . . . . . . .  one of an object
**
**  'ONE' returns the one of the object <op>.
**
**  'ONE' is defined in the declaration part of this package as follows
**
#define ONE(op)         ((*OneFuncs[TYPE_OBJ(op)])(op))
*/
Obj OneAttr;

Obj OneHandler (
    Obj                 self,
    Obj                 op )
{
    return ONE( op );
}

Obj OneUndefined (
    Obj                 op )
{
    return ErrorReturnObj(
        "operations: ONE of %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(op)].name),
        0L,
        "you can return a value for the result" );
}

Obj OneObject (
    Obj                 op )
{
    return DoAttribute( OneAttr, op );
}

Obj VerboseOneObject (
    Obj                 op )
{
    return DoVerboseAttribute( OneAttr, op );
}


/****************************************************************************
**
*V  OneFuncs[<type>]  . . . . . . . . . . . . . . . . .  table of one methods
*/
ArithMethod1 OneFuncs [LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallOneObject( <verb> )
*/
void InstallOneObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
	if ( verb ) {
	    OneFuncs[ t1 ] = VerboseOneObject;
	}
	else {
	    OneFuncs[ t1 ] = OneObject;
	}
    }
    if ( verb ) {
	OneFuncs[ T_OBJECT ] = VerboseOneObject;
    }
    else {
	OneFuncs[ T_OBJECT ] = OneObject;
    }
}


/****************************************************************************
**

*F  INV( <op> ) . . . . . . . . . . . . . . . . . . . .  inverse of an object
**
**  'INV' returns the multiplicative inverse of the object <op>.
**
**  'INV' is defined in the declaration of this package as follows
**
#define INV(op)         ((*InvFuncs[TYPE_OBJ(op)])(op))
*/
Obj InvAttr;

Obj InvHandler (
    Obj                 self,
    Obj                 op )
{
    return INV( op );
}

Obj InvUndefined (
    Obj                 op )
{
    return ErrorReturnObj(
        "operations: INV of %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(op)].name),
        0L,
        "you can return a value for the result" );
}

Obj InvObject (
    Obj                 op )
{
    return DoAttribute( InvAttr, op );
}

Obj VerboseInvObject (
    Obj                 op )
{
    return DoVerboseAttribute( InvAttr, op );
}


/****************************************************************************
**
*V  InvFuncs[<type>]  . . . . . . . . . . . . . .  table of inverse functions
*/
ArithMethod1 InvFuncs [LAST_VIRTUAL_TYPE+1];

    
/****************************************************************************
**
*F  InstallInvObject( <verb> )
*/
void InstallInvObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
	if ( verb ) {
	    InvFuncs[ t1 ] = VerboseInvObject;
	}
	else {
	    InvFuncs[ t1 ] = InvObject;
	}
    }
    if ( verb ) {
	InvFuncs[ T_OBJECT ] = VerboseInvObject;
    }
    else {
	InvFuncs[ T_OBJECT ] = InvObject;
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
#define QUO(opL,opR)    ((*QuoFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj QuoOper;

Obj QuoHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return QUO( opL, opR );
}

Obj QuoDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = INV( opR );
    return PROD( opL, tmp );
}

Obj QuoObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( QuoOper, opL, opR );
}

Obj VerboseQuoObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( QuoOper, opL, opR );
}

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
*V  QuoFuncs[<typeL>][<typeR>]  . . . . . . . . . . table of quotient methods
*/
ArithMethod2 QuoFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallQuoObject( <verb> )
*/
void InstallQuoObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		QuoFuncs[ t1 ][ t2 ] = VerboseQuoObject;
		QuoFuncs[ t2 ][ t1 ] = VerboseQuoObject;
	    }
	    else {
		QuoFuncs[ t1 ][ t2 ] = QuoObject;
		QuoFuncs[ t2 ][ t1 ] = QuoObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    QuoFuncs[ t2 ][ T_OBJECT ] = VerboseQuoObject;
	    QuoFuncs[ T_OBJECT ][ t2 ] = VerboseQuoObject;
	}
	else {
	    QuoFuncs[ t2 ][ T_OBJECT ] = QuoObject;
	    QuoFuncs[ T_OBJECT ][ t2 ] = QuoObject;
	}
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
#define LQUO(opL,opR)   ((*LQuoFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj LQuoOper;

Obj LQuoHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return LQUO( opL, opR );
}

Obj LQuoDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = INV( opL );
    return PROD( tmp, opR );
}

Obj LQuoObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( LQuoOper, opL, opR );
}

Obj VerboseLQuoObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( LQuoOper, opL, opR );
}

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
*V  LQuoFuncs[<typeL>][<typeR>] . . . . . . .  table of left quotient methods
*/
ArithMethod2 LQuoFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallLQuoObject( <verb> )
*/
void InstallLQuoObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		LQuoFuncs[ t1 ][ t2 ] = VerboseLQuoObject;
		LQuoFuncs[ t2 ][ t1 ] = VerboseLQuoObject;
	    }
	    else {
		LQuoFuncs[ t1 ][ t2 ] = LQuoObject;
		LQuoFuncs[ t2 ][ t1 ] = LQuoObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    LQuoFuncs[ t2 ][ T_OBJECT ] = VerboseLQuoObject;
	    LQuoFuncs[ T_OBJECT ][ t2 ] = VerboseLQuoObject;
	}
	else {
	    LQuoFuncs[ t2 ][ T_OBJECT ] = LQuoObject;
	    LQuoFuncs[ T_OBJECT ][ t2 ] = LQuoObject;
	}
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
#define POW(opL,opR)    ((*PowFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj PowOper;

Obj PowHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return POW( opL, opR );
}

Obj PowUndefined (
    Obj                 opL,
    Obj                 opR )
{
    return ErrorReturnObj(
        "operations: POW of %s and %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(opL)].name),
        (Int)(InfoBags[TYPE_OBJ(opR)].name),
        "you can return a value for the result" );
}

Obj PowDefault (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 tmp;
    tmp = LQUO( opR, opL );
    return PROD( tmp, opR );
}

Obj PowObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( PowOper, opL, opR );
}

Obj VerbosePowObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( PowOper, opL, opR );
}

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
*V  PowFuncs[<typeL>][<typeR>]  . . . . . . . . . . .  table of power methods
*/
ArithMethod2 PowFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallPowObject( <verb> )
*/
void InstallPowObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		PowFuncs[ t1 ][ t2 ] = VerbosePowObject;
		PowFuncs[ t2 ][ t1 ] = VerbosePowObject;
	    }
	    else {
		PowFuncs[ t1 ][ t2 ] = PowObject;
		PowFuncs[ t2 ][ t1 ] = PowObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    PowFuncs[ t2 ][ T_OBJECT ] = VerbosePowObject;
	    PowFuncs[ T_OBJECT ][ t2 ] = VerbosePowObject;
	}
	else {
	    PowFuncs[ t2 ][ T_OBJECT ] = PowObject;
	    PowFuncs[ T_OBJECT ][ t2 ] = PowObject;
	}
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
#define COMM(opL,opR)   ((*CommFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj CommOper;

Obj CommHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return COMM( opL, opR );
}

Obj CommUndefined (
    Obj                 opL,
    Obj                 opR )
{
    return ErrorReturnObj(
        "operations: COMM of %s and %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(opL)].name),
        (Int)(InfoBags[TYPE_OBJ(opR)].name),
        "you can return a value for the result" );
}

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

Obj CommObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( CommOper, opL, opR );
}

Obj VerboseCommObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( CommOper, opL, opR );
}

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
*V  CommFuncs[<typeL>][<typeR>] . . . . . . . . . table of commutator methods
*/
ArithMethod2 CommFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallCommObject( <verb> )
*/
void InstallCommObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		CommFuncs[ t1 ][ t2 ] = VerboseCommObject;
		CommFuncs[ t2 ][ t1 ] = VerboseCommObject;
	    }
	    else {
		CommFuncs[ t1 ][ t2 ] = CommObject;
		CommFuncs[ t2 ][ t1 ] = CommObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    CommFuncs[ t2 ][ T_OBJECT ] = VerboseCommObject;
	    CommFuncs[ T_OBJECT ][ t2 ] = VerboseCommObject;
	}
	else {
	    CommFuncs[ t2 ][ T_OBJECT ] = CommObject;
	    CommFuncs[ T_OBJECT ][ t2 ] = CommObject;
	}
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
#define MOD(opL,opR)    ((*ModFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))
*/
Obj ModOper;

Obj ModHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return MOD( opL, opR );
}

Obj ModUndefined (
    Obj                 opL,
    Obj                 opR )
{
    return ErrorReturnObj(
        "operations: MOD of %s and %s is not defined",
        (Int)(InfoBags[TYPE_OBJ(opL)].name),
        (Int)(InfoBags[TYPE_OBJ(opR)].name),
        "you can return a value for the result" );
}

Obj ModObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoOperation2Args( ModOper, opL, opR );
}

Obj VerboseModObject (
    Obj                 opL,
    Obj                 opR )
{
    return DoVerboseOperation2Args( ModOper, opL, opR );
}


/****************************************************************************
**
*V  ModFuncs[<typeL>][<typeR>]  . . . . . . . . .  table of remainder methods
*/
ArithMethod2 ModFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];



/****************************************************************************
**
*F  InstallModObject( <verb> )
*/
void InstallModObject ( Int verb )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    for ( t1 = FIRST_EXTERNAL_TYPE; t1 <= LAST_EXTERNAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	    if ( verb ) {
		ModFuncs[ t1 ][ t2 ] = VerboseModObject;
		ModFuncs[ t2 ][ t1 ] = VerboseModObject;
	    }
	    else {
		ModFuncs[ t1 ][ t2 ] = ModObject;
		ModFuncs[ t2 ][ t1 ] = ModObject;
	    }
        }
    }
    for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
	if ( verb ) {
	    ModFuncs[ t2 ][ T_OBJECT ] = VerboseModObject;
	    ModFuncs[ T_OBJECT ][ t2 ] = VerboseModObject;
	}
	else {
	    ModFuncs[ t2 ][ T_OBJECT ] = ModObject;
	    ModFuncs[ T_OBJECT ][ t2 ] = ModObject;
	}
    }
}


/****************************************************************************
**

*F  InitAriths()  . . . . . . .  initialize the arithmetic operations package
**
**  'InitAriths' initializes the arithmetic operations package.
*/
void            InitAriths ( void )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    /* make and install the 'EQ' comparison operation                      */
    EqOper = NewOperationC( "EQ", 2L, "opL, opR", EqHandler );
    AssGVar( GVarName( "EQ" ), EqOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            EqFuncs[ t1 ][ t2 ] = EqNot;
        }
    }
    InstallEqObject(0);

    /* make and install the 'LT' comparison operation                      */
    LtOper = NewOperationC( "LT", 2L, "opL, opR", LtHandler );
    AssGVar( GVarName( "LT" ), LtOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            LtFuncs[ t1 ][ t2 ] = LtUndefined;
        }
    }
    InstallLtObject(0);

    /* make and install the 'IN' comparison operation                      */
    InOper = NewOperationC( "IN", 2L, "opL, opR", InHandler );
    AssGVar( GVarName( "IN" ), InOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            InFuncs[ t1 ][ t2 ] = InUndefined;
        }
    }
    InstallInObject(0);

    /* make and install the 'SUM' arithmetic operation                     */
    SumOper = NewOperationC( "SUM", 2L, "opL, opR", SumHandler );
    AssGVar( GVarName( "SUM" ), SumOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            SumFuncs[ t1 ][ t2 ] = SumUndefined;
        }
    }
    InstallSumObject(0);

    /* make and install the 'ZERO' arithmetic operation                    */
    ZeroAttr = NewAttributeC( "ZERO", 1L, "op", ZeroHandler );
    AssGVar( GVarName( "ZERO" ), ZeroAttr );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        ZeroFuncs[ t1 ] = ZeroUndefined;
    }
    InstallZeroObject(0);

    /* make and install the 'AINV' arithmetic operation                    */
    AInvAttr = NewAttributeC( "AINV", 1L, "op", AInvHandler );
    AssGVar( GVarName( "AINV" ), AInvAttr );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        AInvFuncs[ t1 ] = AInvUndefined;
    }
    InstallAinvObject(0);

    /* make and install the 'DIFF' arithmetic operation                    */
    DiffOper = NewOperationC( "DIFF", 2L, "opL, opR", DiffHandler );
    AssGVar( GVarName( "DIFF" ), DiffOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            DiffFuncs[ t1 ][ t2 ] = DiffDefault;
        }
    }
    InstallDiffObject(0);
    DiffDefaultFunc = NewFunctionC(
        "DIFF_DEFAULT", 2L, "opL, opR", DiffDefaultHandler );
    AssGVar( GVarName( "DIFF_DEFAULT" ), DiffDefaultFunc );

    /* make and install the 'PROD' arithmetic operation                    */
    ProdOper = NewOperationC( "PROD", 2L, "opL, opR", ProdHandler );
    AssGVar( GVarName( "PROD" ), ProdOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            ProdFuncs[ t1 ][ t2 ] = ProdUndefined;
        }
    }
    InstallProdObject(0);

    /* make and install the 'ONE' arithmetic operation                     */
    OneAttr = NewAttributeC( "ONE", 1L, "op", OneHandler );
    AssGVar( GVarName( "ONE" ), OneAttr );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        OneFuncs[ t1 ] = OneUndefined;
    }
    InstallOneObject(0);

    /* make and install the 'INV' arithmetic operation                     */
    InvAttr = NewAttributeC( "INV", 1L, "op", InvHandler );
    AssGVar( GVarName( "INV" ), InvAttr );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        InvFuncs[ t1 ] = InvUndefined;
    }
    InstallInvObject(0);

    /* make and install the 'QUO' arithmetic operation                     */
    QuoOper = NewOperationC( "QUO", 2L, "opL, opR", QuoHandler );
    AssGVar( GVarName( "QUO" ), QuoOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            QuoFuncs[ t1 ][ t2 ] = QuoDefault;
        }
    }
    InstallQuoObject(0);
    QuoDefaultFunc = NewFunctionC(
        "QUO_DEFAULT", 2L, "opL, opR", QuoDefaultHandler );
    AssGVar( GVarName( "QUO_DEFAULT" ), QuoDefaultFunc );

    /* make and install the 'LQUO' arithmetic operation                    */
    LQuoOper = NewOperationC( "LQUO", 2L, "opL, opR", LQuoHandler );
    AssGVar( GVarName( "LQUO" ), LQuoOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            LQuoFuncs[ t1 ][ t2 ] = LQuoDefault;
        }
    }
    InstallLQuoObject(0);
    LQuoDefaultFunc = NewFunctionC(
        "LQUO_DEFAULT", 2L, "opL, opR", LQuoDefaultHandler );
    AssGVar( GVarName( "LQUO_DEFAULT" ), LQuoDefaultFunc );

    /* make and install the 'POW' arithmetic operation                     */
    PowOper = NewOperationC( "POW", 2L, "opL, opR", PowHandler );
    AssGVar( GVarName( "POW" ), PowOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            PowFuncs[ t1 ][ t2 ] = PowUndefined;
        }
    }
    InstallPowObject(0);
    PowDefaultFunc = NewFunctionC(
        "POW_DEFAULT", 2L, "opL, opR", PowDefaultHandler );
    AssGVar( GVarName( "POW_DEFAULT" ), PowDefaultFunc );

    /* make and install the 'COMM' arithmetic operation                    */
    CommOper = NewOperationC( "COMM", 2L, "opL, opR", CommHandler );
    AssGVar( GVarName( "COMM" ), CommOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            CommFuncs[ t1 ][ t2 ] = CommDefault;
        }
    }
    InstallCommObject(0);
    CommDefaultFunc = NewFunctionC(
        "COMM_DEFAULT", 2L, "opL, opR", CommDefaultHandler );
    AssGVar( GVarName( "COMM_DEFAULT" ), CommDefaultFunc );

    /* make and install the 'MOD' arithmetic operation                     */
    ModOper = NewOperationC( "MOD", 2L, "opL, opR", ModHandler );
    AssGVar( GVarName( "MOD" ), ModOper );
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {
        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ) {
            ModFuncs[ t1 ][ t2 ] = ModUndefined;
        }
    }
    InstallModObject(0);
}


/****************************************************************************
**

*E  ariths.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
