/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the  arithmetic  operations  package.
*/

#ifndef GAP_ARITHS_H
#define GAP_ARITHS_H

#include "objects.h"

/****************************************************************************
**
*T  CompaMethod . . . . . . . . . . type of methods for comparison operations
**
**  'CompaMethod'  is the type of methods  for comparison operations, i.e., a
**  function accepting two arguments of type 'Obj' and returning an 'Int'.
*/
typedef Int (* CompaMethod) ( Obj opL, Obj opR );


/****************************************************************************
**
*T  ArithMethod1  . . . . . . . . . type of methods for arithmetic operations
**
**  'ArithMethod1'  is the type of  methods  for unary arithmetic operations,
**  i.e.,  a function accepting  one argument of type  'Obj' and returning an
**  'Obj'.
*/
typedef Obj (* ArithMethod1) ( Obj op );


/****************************************************************************
**
*T  ArithMethod2  . . . . . . . . . type of methods for arithmetic operations
**
**  'ArithMethod2' is the type  of methods for binary arithmetic  operations,
**  i.e., a function  accepting two arguments  of type 'Obj' and returning an
**  'Obj'.
*/
typedef Obj (* ArithMethod2) ( Obj opL, Obj opR );


/****************************************************************************
**
*F * * * * * * * * * * *  unary arithmetic operations * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  ZeroFuncs[<type>] . . . . . . . . . . . . . . . . . table of zero methods
*/
extern ArithMethod1 ZeroFuncs[LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  ZERO( <op> )  . . . . . . . . . . . . . . . . . . . . . zero of an object
**
**  'ZERO' returns the zero of the object <op>.
*/
EXPORT_INLINE Obj ZERO(Obj op)
{
    UInt tnum = TNUM_OBJ(op);
    return (*ZeroFuncs[tnum])(op);
}


/****************************************************************************
**
*V  ZeroMutFuncs[<type>] . . . . . . . . . . . . . . .  table of zero methods
*/
extern ArithMethod1 ZeroMutFuncs[LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  ZERO_MUT( <op> )  . . . . . . . . . . . . . . . . . . . zero of an object
**
**  'ZERO_MUT' returns the mutable zero of the object <op>.
*/
EXPORT_INLINE Obj ZERO_MUT(Obj op)
{
    UInt tnum = TNUM_OBJ(op);
    return (*ZeroMutFuncs[tnum])(op);
}


/****************************************************************************
**
*V  AInvFuncs[<type>] . . . . . . . . . . . table of additive inverse methods
*/
extern ArithMethod1 AInvFuncs[LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  AINV( <op> )  . . . . . . . . . . . . . . . additive inverse of an object
**
**  'AINV' returns the additive inverse of the object <op>.
*/
EXPORT_INLINE Obj AINV(Obj op)
{
    UInt tnum = TNUM_OBJ(op);
    return (*AInvFuncs[tnum])(op);
}


/****************************************************************************
**
*V  AInvMutFuncs[<type>] . . . . . . . . .  table of additive inverse methods
*/
extern ArithMethod1 AInvMutFuncs[LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  AINV_MUT( <op> )  . . . . . . . . . . . . . additive inverse of an object
**
**  'AINV_MUT' returns the mutable additive inverse of the object <op>.
*/
EXPORT_INLINE Obj AINV_MUT(Obj op)
{
    UInt tnum = TNUM_OBJ(op);
    return (*AInvMutFuncs[tnum])(op);
}


/****************************************************************************
**
*F  C_AINV( <val>, <left> ) . . . . . . . . . . . . . . . . . .  compute ainv
*/
#define C_AINV(val,left) \
 val = AINV_MUT( left );


/****************************************************************************
**
*F  C_AINV_FIA( <val>, <left> ) . . . . . . . . .  compute ainv, fast integer
*/
#define C_AINV_FIA(val,left) \
 val = AINV_MUT( left );


/****************************************************************************
**
*F  C_AINV_INTOBJS( <val>, <left> ) . . . . . . .  compute ainv of an integer
*/
#define C_AINV_INTOBJS(val,left) \
 val = AINV_MUT( left );


/****************************************************************************
**
*V  OneFuncs[<type>]  . . . . . . . . . . . . . . . . .  table of one methods
*/
extern ArithMethod1 OneFuncs[LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  ONE( <op> ) . . . . . . . . . . . . . . . . . . . . . .  one of an object
**
**  'ONE' returns the one of the object <op>.
*/
EXPORT_INLINE Obj ONE(Obj op)
{
    UInt tnum = TNUM_OBJ(op);

    return (*OneFuncs[tnum])(op);
}


/****************************************************************************
**
*V  OneMutFuncs[<type>]  . . . . . .table of mutability preservingone methods
*/
extern ArithMethod1 OneMutFuncs[LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  ONE_MUT( <op> )    . . . . . . . .  one of an object retaining mutability
**
**  'ONE_MUT' returns the one of the object <op> with the same
**  mutability level as <op>.
*/
EXPORT_INLINE Obj ONE_MUT(Obj op)
{
    UInt tnum = TNUM_OBJ(op);
    return (*OneMutFuncs[tnum])(op);
}


/****************************************************************************
**
*V  InvFuncs[<type>]  . . . . . . . . . . . . . .  table of inverse functions
*/
extern ArithMethod1 InvFuncs[LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  INV( <op> ) . . . . . . . . . . . . . . . . . . . .  inverse of an object
**
**  'INV' returns the multiplicative inverse of the object <op>.
*/
EXPORT_INLINE Obj INV(Obj op)
{
    UInt tnum = TNUM_OBJ(op);
    return (*InvFuncs[tnum])(op);
}


/****************************************************************************
**
*V  InvMutFuncs[<type>]  .. .table of mutability preserving inverse functions
*/
extern ArithMethod1 InvMutFuncs[LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  INV_MUT( <op> ) . . . . . . . . inverse of an object retaining mutability
**
**  'INV_MUT' returns the multiplicative inverse of the object <op>.
*/
EXPORT_INLINE Obj INV_MUT(Obj op)
{
    UInt tnum = TNUM_OBJ(op);
    return (*InvMutFuncs[tnum])(op);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * comparison operations  * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  EqFuncs[<typeL>][<typeR>] . . . . . . . . . . table of comparison methods
*/
extern CompaMethod EqFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  EQ( <opL>, <opR> )  . . . . . . . . . . . . . . comparison of two objects
**
**  'EQ' returns a nonzero value  if the object <opL>  is equal to the object
**  <opR>, and zero otherwise.
*/
EXPORT_INLINE Int EQ(Obj opL, Obj opR)
{
    if (opL == opR)
        return 1;
    if (ARE_INTOBJS(opL, opR))
        return 0;
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*EqFuncs[tnumL][tnumR])(opL, opR);
}

extern Obj EqOper;

Int EqObject(Obj opL, Obj opR);


/****************************************************************************
**
*V  LtFuncs[<typeL>][<typeR>] . . . . . . . . . . table of comparison methods
*/
extern CompaMethod LtFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  LT( <opL>, <opR> )  . . . . . . . . . . . . . . comparison of two objects
**
**  'LT' returns a nonzero value if the object <opL> is  less than the object
**  <opR>, and zero otherwise.
*/
EXPORT_INLINE Int LT(Obj opL, Obj opR)
{
    if (opL == opR)
        return 0;
    if (ARE_INTOBJS(opL, opR))
        return (Int)(opL) < (Int)(opR);
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*LtFuncs[tnumL][tnumR])(opL, opR);
}

extern Obj LtOper;


/****************************************************************************
**
*V  InFuncs[<typeL>][<typeR>] . . . . . . . . . . table of membership methods
*/
extern CompaMethod InFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  IN( <opL>, <opR> )  . . . . . . . . . . .  membership test of two objects
**
**  'IN' returns a nonzero   value if the object  <opL>  is a member  of  the
**  object <opR>, and zero otherwise.
*/
EXPORT_INLINE Int IN(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*InFuncs[tnumL][tnumR])(opL, opR);
}


/****************************************************************************
**
*F * * * * * * * * * * * binary arithmetic operations * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  SumFuncs[<typeL>][<typeR>]  . . . . . . . . . . . .  table of sum methods
*/
extern ArithMethod2 SumFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  SUM( <opL>, <opR> ) . . . . . . . . . . . . . . . . .  sum of two objects
**
**  'SUM' returns the sum of the two objects <opL> and <opR>.
**
**  At places where performance matters one should use the following code
**
**      if ( ! ARE_INTOBJS( <opL>, <opR> )
**        || ! SUM_INTOBJS( <res>, <opL>, <opR> ) )
**          <res> = SUM( <opL>, <opR> );
*/
EXPORT_INLINE Obj SUM(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*SumFuncs[tnumL][tnumR])(opL, opR);
}


extern Obj SumOper;


/****************************************************************************
**
*F  C_SUM( <val>, <left>, <right> ) . . . . . . . . . . . . . . . compute sum
*/
#define C_SUM(val,left,right) \
 val = SUM( left, right );


/****************************************************************************
**
*F  C_SUM_FIA( <val>, <left>, <right> ) . . . . .  compute sum, fast integers
*/
#define C_SUM_FIA(val,left,right) \
 if ( ! ARE_INTOBJS(left,right) || ! SUM_INTOBJS(val,left,right) ) { \
  val = SUM( left, right ); \
 }


/****************************************************************************
**
*F  C_SUM_INTOBJS( <val>, <left>, <right> ) . . . compute sum of two integers
*/
#define C_SUM_INTOBJS(val,left,right) \
 if ( ! SUM_INTOBJS(val,left,right) ) { \
  val = SUM( left, right ); \
 }


/****************************************************************************
**
*V  DiffFuncs[<typeL>][<typeR>] . . . . . . . . . table of difference methods
*/
extern ArithMethod2 DiffFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  DIFF( <opL>, <opR> )  . . . . . . . . . . . . . difference of two objects
**
**  'DIFF' returns the difference of the two objects <opL> and <opR>.
**
**  At places where performance matters one should use the following code
**
**      if ( ! ARE_INTOBJS( <opL>, <opR> )
**        || ! DIFF_INTOBJS( <res>, <opL>, <opR> ) )
**          <res> = DIFF( <opL>, <opR> );
*/
EXPORT_INLINE Obj DIFF(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*DiffFuncs[tnumL][tnumR])(opL, opR);
}


/****************************************************************************
**
*F  C_DIFF( <val>, <left>, <right> )  . . . . . . . . . . . . .  compute diff
*/
#define C_DIFF(val,left,right) \
 val = DIFF( left, right );


/****************************************************************************
**
*F  C_DIFF_FIA( <val>, <left>, <right> )  . . . . compute diff, fast integers
*/
#define C_DIFF_FIA(val,left,right) \
 if ( ! ARE_INTOBJS(left,right) || ! DIFF_INTOBJS(val,left,right) ) { \
  val = DIFF( left, right ); \
 }


/****************************************************************************
**
*F  C_DIFF_INTOBJS( <val>, <left>, <right> )  .  compute diff of two integers
*/
#define C_DIFF_INTOBJS(val,left,right) \
 if ( ! DIFF_INTOBJS(val,left,right) ) { \
  val = DIFF( left, right ); \
 }


/****************************************************************************
**
*V  ProdFuncs[<typeL>][<typeR>] . . . . . . . . . .  table of product methods
*/
extern ArithMethod2 ProdFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  PROD( <opL>, <opR> )  . . . . . . . . . . . . . .  product of two objects
**
**  'PROD' returns the product of the two objects <opL> and <opR>.
**
**  At places where performance matters one should use the following code
**
**      if ( ! ARE_INTOBJS( <opL>, <opR> )
**        || ! PROD_INTOBJS( <res>, <opL>, <opR> ) )
**          <res> = PROD( <opL>, <opR> );
*/
EXPORT_INLINE Obj PROD(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*ProdFuncs[tnumL][tnumR])(opL, opR);
}


/****************************************************************************
**
*F  C_PROD( <val>, <left>, <right> )  . . . . . . . . . . . . compute product
*/
#define C_PROD(val,left,right) \
 val = PROD( left, right );


/****************************************************************************
**
*F  C_PROD_FIA( <val>, <left>, <right> )  . .  compute product, fast integers
*/
#define C_PROD_FIA(val,left,right) \
 if ( ! ARE_INTOBJS(left,right) || ! PROD_INTOBJS(val,left,right) ) { \
  val = PROD( left, right ); \
 }


/****************************************************************************
**
*F  C_PROD_INTOBJS( <val>, <left>, <right> )  compute product of two integers
*/
#define C_PROD_INTOBJS(val,left,right) \
 if ( ! PROD_INTOBJS(val,left,right) ) { \
  val = PROD( left, right ); \
 }


/****************************************************************************
**
*V  QuoFuncs[<typeL>][<typeR>]  . . . . . . . . . . table of quotient methods
*/
extern ArithMethod2 QuoFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  QUO( <opL>, <opR> ) . . . . . . . . . . . . . . . quotient of two objects
**
**  'QUO' returns the quotient of the object <opL> by the object <opR>.
*/
EXPORT_INLINE Obj QUO(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*QuoFuncs[tnumL][tnumR])(opL, opR);
}


/****************************************************************************
**
*V  LQuoFuncs[<typeL>][<typeR>] . . . . . . .  table of left quotient methods
*/
extern ArithMethod2 LQuoFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  LQUO( <opL>, <opR> )  . . . . . . . . . . .  left quotient of two operand
**
**  'LQUO' returns the left quotient of the object <opL> by the object <opR>.
*/
EXPORT_INLINE Obj LQUO(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*LQuoFuncs[tnumL][tnumR])(opL, opR);
}


/****************************************************************************
**
*V  PowFuncs[<typeL>][<typeR>]  . . . . . . . . . . .  table of power methods
*/
extern ArithMethod2 PowFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  POW( <opL>, <opR> ) . . . . . . . . . . . . . . . .  power of two objects
**
**  'POW' returns the power of the object <opL> by the object <opL>.
*/
EXPORT_INLINE Obj POW(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*PowFuncs[tnumL][tnumR])(opL, opR);
}


/****************************************************************************
**
*V  CommFuncs[<typeL>][<typeR>] . . . . . . . . . table of commutator methods
*/
extern ArithMethod2 CommFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  COMM( <opL>, <opR> )  . . . . . . . . . . . . . commutator of two objects
**
**  'COMM' returns the commutator of the two objects <opL> and <opR>.
*/
EXPORT_INLINE Obj COMM(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*CommFuncs[tnumL][tnumR])(opL, opR);
}


/****************************************************************************
**
*V  ModFuncs[<typeL>][<typeR>]  . . . . . . . . .  table of remainder methods
*/
extern ArithMethod2 ModFuncs[LAST_REAL_TNUM + 1][LAST_REAL_TNUM + 1];


/****************************************************************************
**
*F  MOD( <opL>, <opR> ) . . . . . . . . . . . . . .  remainder of two objects
**
**  'MOD' returns the remainder of the object <opL> by the object <opR>.
*/
EXPORT_INLINE Obj MOD(Obj opL, Obj opR)
{
    UInt tnumL = TNUM_OBJ(opL);
    UInt tnumR = TNUM_OBJ(opR);
    return (*ModFuncs[tnumL][tnumR])(opL, opR);
}


/****************************************************************************
**
*F  ChangeArithDoOperations( <oper>, <verb> )
*/
void ChangeArithDoOperations(Obj oper, Int verb);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoAriths()  . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoAriths ( void );


#endif // GAP_ARITHS_H
