/****************************************************************************
**
*W  ariths.h                    GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions of the  arithmetic  operations  package.
*/
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_ariths_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*T  CompaMethod . . . . . . . . . . type of methods for comparison operations
**
**  'CompaMethod'  is the type of methods  for comparison operations, i.e., a
**  function accepting two arguments of type 'Obj' and returning an 'Int'.
*/
typedef Int     (* CompaMethod) ( Obj opL, Obj opR );


/****************************************************************************
**
*T  ArithMethod1  . . . . . . . . . type of methods for arithmetic operations
**
**  'ArithMethod1'  is the type of  methods  for unary arithmetic operations,
**  i.e.,  a function accepting  one argument of type  'Obj' and returning an
**  'Obj'.
*/
typedef Obj     (* ArithMethod1) ( Obj op );


/****************************************************************************
**
*T  ArithMethod2  . . . . . . . . . type of methods for arithmetic operations
**
**  'ArithMethod2' is the type  of methods for binary arithmetic  operations,
**  i.e., a function  accepting two arguments  of type 'Obj' and returning an
**  'Obj'.
*/
typedef Obj     (* ArithMethod2) ( Obj opL, Obj opR );


/****************************************************************************
**

*F  EQ( <opL>, <opR> )  . . . . . . . . . . . . . . comparison of two objects
**
**  'EQ' returns a nonzero value  if the object <opL>  is equal to the object
**  <opR>, and zero otherwise.
*/
#define EQ(opL,opR)     ((opL) == (opR) || \
                         (!ARE_INTOBJS(opL,opR) && \
                          (*EqFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR)))

#define EQ2(opL,opR)    ((opL) == (opR) || \
                          (*EqFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj EqOper;


/****************************************************************************
**
*V  EqFuncs[<typeL>][<typeR>] . . . . . . . . . . table of comparison methods
*/
extern CompaMethod EqFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


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
                          (*LtFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR)))

#define LT2(opL,opR)    ((opL) == (opR) ? 0 : \
                          (*LtFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj LtOper;


/****************************************************************************
**
*V  LtFuncs[<typeL>][<typeR>] . . . . . . . . . . table of comparison methods
*/
extern CompaMethod LtFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


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
#define IN(opL,opR)     ((*InFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj InOper;


/****************************************************************************
**
*V  InFuncs[<typeL>][<typeR>] . . . . . . . . . . table of membership methods
*/
extern CompaMethod InFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallInObject( <verb> )
*/
extern void InstallInObject ( Int );


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
#define SUM(opL,opR)    ((*SumFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj SumOper;


/****************************************************************************
**
*V  SumFuncs[<typeL>][<typeR>]  . . . . . . . . . . . .  table of sum methods
*/
extern ArithMethod2 SumFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallSumObject( <verb> )
*/
extern void InstallSumObject ( Int );


/****************************************************************************
**

*F  ZERO( <op> )  . . . . . . . . . . . . . . . . . . . . . zero of an object
**
**  'ZERO' returns the zero of the object <op>.
*/
#define ZERO(op)        ((*ZeroFuncs[TYPE_OBJ(op)])(op))

extern Obj ZeroAttr;


/****************************************************************************
**
*V  ZeroFuncs[<type>] . . . . . . . . . . . . . . . . . table of zero methods
*/
extern ArithMethod1 ZeroFuncs [LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallZeroObject( <verb> )
*/
extern void InstallZeroObject ( Int );


/****************************************************************************
**

*F  AINV( <op> )  . . . . . . . . . . . . . . . additive inverse of an object
**
**  'AINV' returns the additive inverse of the object <op>.
*/
#define AINV(op)        ((*AInvFuncs[TYPE_OBJ(op)])(op))

extern Obj AInvAttr;


/****************************************************************************
**
*V  AInvFuncs[<type>] . . . . . . . . . . . table of additive inverse methods
*/
extern ArithMethod1 AInvFuncs [LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallAinvObject( <verb> )
*/
extern void InstallAinvObject ( Int );


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
#define DIFF(opL,opR)   ((*DiffFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj DiffOper;


/****************************************************************************
**
*V  DiffFuncs[<typeL>][<typeR>] . . . . . . . . . table of difference methods
*/
extern ArithMethod2 DiffFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallDiffObject( <verb> )
*/
extern void InstallDiffObject ( Int );


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
#define PROD(opL,opR)   ((*ProdFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj ProdOper;


/****************************************************************************
**
*V  ProdFuncs[<typeL>][<typeR>] . . . . . . . . . .  table of product methods
*/
extern  ArithMethod2    ProdFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallProdObject( <verb> )
*/
extern void InstallProdObject ( Int );


/****************************************************************************
**

*F  ONE( <op> ) . . . . . . . . . . . . . . . . . . . . . .  one of an object
**
**  'ONE' returns the one of the object <op>.
*/
#define ONE(op)         ((*OneFuncs[TYPE_OBJ(op)])(op))

extern Obj OneAttr;


/****************************************************************************
**
*V  OneFuncs[<type>]  . . . . . . . . . . . . . . . . .  table of one methods
*/
extern ArithMethod1 OneFuncs [LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallOneObject( <verb> )
*/
extern void InstallOneObject ( Int );


/****************************************************************************
**

*F  INV( <op> ) . . . . . . . . . . . . . . . . . . . .  inverse of an object
**
**  'INV' returns the multiplicative inverse of the object <op>.
*/
#define INV(op)         ((*InvFuncs[TYPE_OBJ(op)])(op))

extern Obj InvAttr;


/****************************************************************************
**
*V  InvFuncs[<type>]  . . . . . . . . . . . . . .  table of inverse functions
*/
extern ArithMethod1 InvFuncs [LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallInvObject( <verb> )
*/
extern void InstallInvObject ( Int );


/****************************************************************************
**

*F  QUO( <opL>, <opR> ) . . . . . . . . . . . . . . . quotient of two objects
**
**  'QUO' returns the quotient of the object <opL> by the object <opR>.
*/
#define QUO(opL,opR)    ((*QuoFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj QuoOper;


/****************************************************************************
**
*V  QuoFuncs[<typeL>][<typeR>]  . . . . . . . . . . table of quotient methods
*/
extern ArithMethod2 QuoFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


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
#define LQUO(opL,opR)   ((*LQuoFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj LQuoOper;


/****************************************************************************
**
*V  LQuoFuncs[<typeL>][<typeR>] . . . . . . .  table of left quotient methods
*/
extern ArithMethod2 LQuoFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


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
#define POW(opL,opR)    ((*PowFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj PowOper;

extern Obj PowDefault ( Obj opL, Obj opR );


/****************************************************************************
**
*V  PowFuncs[<typeL>][<typeR>]  . . . . . . . . . . .  table of power methods
*/
extern ArithMethod2 PowFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


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
#define COMM(opL,opR)   ((*CommFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj CommOper;


/****************************************************************************
**
*V  CommFuncs[<typeL>][<typeR>] . . . . . . . . . table of commutator methods
*/
extern ArithMethod2 CommFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


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
#define MOD(opL,opR)    ((*ModFuncs[TYPE_OBJ(opL)][TYPE_OBJ(opR)])(opL,opR))

extern Obj ModOper;


/****************************************************************************
**
*V  ModFuncs[<typeL>][<typeR>]  . . . . . . . . .  table of remainder methods
*/
extern ArithMethod2 ModFuncs [LAST_VIRTUAL_TYPE+1][LAST_VIRTUAL_TYPE+1];


/****************************************************************************
**
*F  InstallModObject( <verb> )
*/
extern void InstallModObject ( Int );


/****************************************************************************
**

*F  InitAriths()  . . . . . . .  initialize the arithmetic operations package
**
**  'InitAriths' initializes the arithmetic operations package.
*/
extern  void            InitAriths ( void );


/****************************************************************************
**

*E  ariths.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
