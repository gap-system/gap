/****************************************************************************
**
*W  ariths.h                    GAP source                       Frank Celler
*W                                                         & Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the  arithmetic  operations  package.
*/

#ifndef GAP_ARITHS_H
#define GAP_ARITHS_H

#include <src/objects.h>

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
*F  ZERO( <op> )  . . . . . . . . . . . . . . . . . . . . . zero of an object
**
**  'ZERO' returns the zero of the object <op>.
*/
#define ZERO(op)        ((*ZeroFuncs[TNUM_OBJ(op)])(op))

extern Obj ZEROOp;


/****************************************************************************
**
*V  ZeroFuncs[<type>] . . . . . . . . . . . . . . . . . table of zero methods
*/
extern ArithMethod1 ZeroFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallZeroObject( <verb> )
*/
extern void InstallZeroObject ( Int );

/****************************************************************************
**
*F  ZERO_MUT( <op> )  . . . . . . . . . . . . . . . . . . . . . zero of an object
**
**  'ZERO_MUT' returns the mutable zero of the object <op>.
*/
#define ZERO_MUT(op)        ((*ZeroMutFuncs[TNUM_OBJ(op)])(op))

extern Obj ZeroOp;


/****************************************************************************
**
*V  ZeroMutFuncs[<type>] . . . . . . . . . . . . . . . . . table of zero methods
*/
extern ArithMethod1 ZeroMutFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallZeroMutObject( <verb> )
*/
extern void InstallZeroMutObject ( Int );


/****************************************************************************
**
*F  AINV( <op> )  . . . . . . . . . . . . . . . additive inverse of an object
**
**  'AINV' returns the additive inverse of the object <op>.
*/
#define AINV(op) ((*AInvFuncs[TNUM_OBJ(op)])(op))

extern Obj AInvOp;


/****************************************************************************
**
*V  AInvFuncs[<type>] . . . . . . . . . . . table of additive inverse methods
*/
extern ArithMethod1 AInvFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallAinvObject( <verb> )
*/
extern void InstallAinvObject ( Int );

/****************************************************************************
**
*F  AINV_MUT( <op> )  . . . . . . . . . . . . . additive inverse of an object
**
**  'AINV_MUT' returns the mutable additive inverse of the object <op>.
*/
#define AINV_MUT(op) ((*AInvMutFuncs[TNUM_OBJ(op)])(op))

extern Obj AdditiveInverseOp;


/****************************************************************************
**
*V  AInvMutFuncs[<type>] . . . . . . . . . . . table of additive inverse methods
*/
extern ArithMethod1 AInvMutFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallAinvMutObject( <verb> )
*/
extern void InstallAinvMutObject ( Int );


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
*F  ONE( <op> ) . . . . . . . . . . . . . . . . . . . . . .  one of an object
**
**  'ONE' returns the one of the object <op>.
*/
#define ONE(op)         ((*OneFuncs[TNUM_OBJ(op)])(op))

extern Obj OneOp;


/****************************************************************************
**
*V  OneFuncs[<type>]  . . . . . . . . . . . . . . . . .  table of one methods
*/
extern ArithMethod1 OneFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallOneObject( <verb> )
*/
extern void InstallOneObject ( Int );

/****************************************************************************
**
*F  ONE_MUT( <op> )    . . . . . . . .  one of an object retaining mutability
**
**  'ONE_MUT' returns the one of the object <op> with the same
**  mutability level as <op>.
*/
#define ONE_MUT(op)         ((*OneMutFuncs[TNUM_OBJ(op)])(op))

extern Obj OneMutOp;


/****************************************************************************
**
*V  OneMutFuncs[<type>]  . . . . . .table of mutability preservingone methods
*/
extern ArithMethod1 OneMutFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallOneMutObject( <verb> )
*/
extern void InstallOneMutObject ( Int );


/****************************************************************************
**
*F  INV( <op> ) . . . . . . . . . . . . . . . . . . . .  inverse of an object
**
**  'INV' returns the multiplicative inverse of the object <op>.
*/
#define INV(op)         ((*InvFuncs[TNUM_OBJ(op)])(op))

extern Obj InvOp;


/****************************************************************************
**
*V  InvFuncs[<type>]  . . . . . . . . . . . . . .  table of inverse functions
*/
extern ArithMethod1 InvFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallInvObject( <verb> )
*/
extern void InstallInvObject ( Int );


/****************************************************************************
**
*F  INV_MUT( <op> ) . . . . . . . . inverse of an object retaining mutability
**
**  'INV_MUT' returns the multiplicative inverse of the object <op>.
*/
#define INV_MUT(op)         ((*InvMutFuncs[TNUM_OBJ(op)])(op))

extern Obj InvMutOp;


/****************************************************************************
**
*V  InvMutFuncs[<type>]  .. .table of mutability preserving inverse functions
*/
extern ArithMethod1 InvMutFuncs [LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallInvMutObject( <verb> )
*/
extern void InstallInvMutObject ( Int );


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
*/
#define EQ(opL,opR)     ((opL) == (opR) || \
                         (!ARE_INTOBJS(opL,opR) && \
                          (*EqFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR)))

extern Obj EqOper;


/****************************************************************************
**
*V  EqFuncs[<typeL>][<typeR>] . . . . . . . . . . table of comparison methods
*/
extern CompaMethod EqFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallEqObject( <verb> )
*/
extern void InstallEqObject ( Int );


/****************************************************************************
**
*F  LT( <opL>, <opR> )  . . . . . . . . . . . . . . comparison of two objects
**
**  'LT' returns a nonzero value if the object <opL> is  less than the object
**  <opR>, and zero otherwise.
*/
#define LT(opL,opR)     ((opL) == (opR) ? 0 : \
                         (ARE_INTOBJS(opL,opR) ? (Int)(opL) < (Int)(opR) : \
                          (*LtFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR)))

extern Obj LtOper;


/****************************************************************************
**
*V  LtFuncs[<typeL>][<typeR>] . . . . . . . . . . table of comparison methods
*/
extern CompaMethod LtFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallLtObject( <verb> )
*/
extern void InstallLtObject ( Int );


/****************************************************************************
**
*F  IN( <opL>, <opR> )  . . . . . . . . . . .  membership test of two objects
**
**  'IN' returns a nonzero   value if the object  <opL>  is a member  of  the
**  object <opR>, and zero otherwise.
*/
#define IN(opL,opR)     ((*InFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj InOper;


/****************************************************************************
**
*V  InFuncs[<typeL>][<typeR>] . . . . . . . . . . table of membership methods
*/
extern CompaMethod InFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallInObject( <verb> )
*/
extern void InstallInObject ( Int );


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
**  At places where performance matters one should use the following code
**
**      if ( ! ARE_INTOBJS( <opL>, <opR> )
**        || ! SUM_INTOBJS( <res>, <opL>, <opR> ) )
**          <res> = SUM( <opL>, <opR> );
*/
#define SUM(opL,opR)    ((*SumFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj SumOper;


/****************************************************************************
**
*V  SumFuncs[<typeL>][<typeR>]  . . . . . . . . . . . .  table of sum methods
*/
extern ArithMethod2 SumFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallSumObject( <verb> )
*/
extern void InstallSumObject ( Int );


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
#define DIFF(opL,opR)   ((*DiffFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj DiffOper;


/****************************************************************************
**
*V  DiffFuncs[<typeL>][<typeR>] . . . . . . . . . table of difference methods
*/
extern ArithMethod2 DiffFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallDiffObject( <verb> )
*/
extern void InstallDiffObject ( Int );


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
#define PROD(opL,opR)   ((*ProdFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj ProdOper;


/****************************************************************************
**
*V  ProdFuncs[<typeL>][<typeR>] . . . . . . . . . .  table of product methods
*/
extern  ArithMethod2    ProdFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallProdObject( <verb> )
*/
extern void InstallProdObject ( Int );


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
*F  QUO( <opL>, <opR> ) . . . . . . . . . . . . . . . quotient of two objects
**
**  'QUO' returns the quotient of the object <opL> by the object <opR>.
*/
#define QUO(opL,opR)    ((*QuoFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj QuoOper;


/****************************************************************************
**
*V  QuoFuncs[<typeL>][<typeR>]  . . . . . . . . . . table of quotient methods
*/
extern ArithMethod2 QuoFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallQuoObject( <verb> )
*/
extern void InstallQuoObject ( Int );


/****************************************************************************
**
*F  LQUO( <opL>, <opR> )  . . . . . . . . . . .  left quotient of two operand
**
**  'LQUO' returns the left quotient of the object <opL> by the object <opR>.
*/
#define LQUO(opL,opR)   ((*LQuoFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj LQuoOper;


/****************************************************************************
**
*V  LQuoFuncs[<typeL>][<typeR>] . . . . . . .  table of left quotient methods
*/
extern ArithMethod2 LQuoFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallLQuoObject( <verb> )
*/
extern void InstallLQuoObject ( Int );


/****************************************************************************
**
*F  POW( <opL>, <opR> ) . . . . . . . . . . . . . . . .  power of two objects
**
**  'POW' returns the power of the object <opL> by the object <opL>.
*/
#define POW(opL,opR)    ((*PowFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj PowOper;

extern Obj PowDefault ( Obj opL, Obj opR );


/****************************************************************************
**
*V  PowFuncs[<typeL>][<typeR>]  . . . . . . . . . . .  table of power methods
*/
extern ArithMethod2 PowFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallPowObject( <verb> )
*/
extern void InstallPowObject ( Int );


/****************************************************************************
**
*F  COMM( <opL>, <opR> )  . . . . . . . . . . . . . commutator of two objects
**
**  'COMM' returns the commutator of the two objects <opL> and <opR>.
*/
#define COMM(opL,opR)   ((*CommFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj CommOper;


/****************************************************************************
**
*V  CommFuncs[<typeL>][<typeR>] . . . . . . . . . table of commutator methods
*/
extern ArithMethod2 CommFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallCommObject( <verb> )
*/
extern void InstallCommObject ( Int );


/****************************************************************************
**
*F  MOD( <opL>, <opR> ) . . . . . . . . . . . . . .  remainder of two objects
**
**  'MOD' returns the remainder of the object <opL> by the object <opR>.
*/
#define MOD(opL,opR)    ((*ModFuncs[TNUM_OBJ(opL)][TNUM_OBJ(opR)])(opL,opR))

extern Obj ModOper;


/****************************************************************************
**
*V  ModFuncs[<typeL>][<typeR>]  . . . . . . . . .  table of remainder methods
*/
extern ArithMethod2 ModFuncs [LAST_REAL_TNUM+1][LAST_REAL_TNUM+1];


/****************************************************************************
**
*F  InstallModObject( <verb> )
*/
extern void InstallModObject ( Int );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoAriths()  . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoAriths ( void );


#endif // GAP_ARITHS_H
