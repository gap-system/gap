/****************************************************************************
**
*W  integer.h                   GAP source                   Martin Schönert
**                                                           & Alice Niemeyer
**                                                           & Werner  Nickel
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions handling arbitrary size integers.
*/

#ifndef GAP_INTEGER_H
#define GAP_INTEGER_H

#ifdef USE_GMP /* then use the gmp version of the header file */
 #include "gmpints.h"
#else /* read the rest of this file */


/****************************************************************************
**

*T  TypDigit  . . . . . . . . . . . . . . . . . . . .  type of a single digit
**
**  'TypDigit' is the type of a single digit of an  arbitrary  size  integer.
**  This is of course unsigned short int, which gives us the 16 bits we want.
*/
#ifdef SYS_IS_64_BIT
typedef UInt4           TypDigit;
#define INTEGER_UNIT_SIZE 4
#define INTEGER_ALLOCATION_SIZE 16
#else
typedef UInt2           TypDigit;
#define INTEGER_UNIT_SIZE 2
#define INTEGER_ALLOCATION_SIZE 8
#endif

#define NR_DIGIT_BITS      (8 * sizeof(TypDigit))
#define INTBASE            (1UL << NR_DIGIT_BITS)
#define NR_SMALL_INT_BITS  (2*NR_DIGIT_BITS - 4)
#define SIZE_INT(op)    (SIZE_OBJ(op) / sizeof(TypDigit))
#define ADDR_INT(op)    ((TypDigit*)ADDR_OBJ(op))


/**************************************************************************
** The following two functions convert a C Int or UInt respectively into
** a GAP integer, either an immediate, small integer if possible or 
** otherwise a new GAP bag with TNUM T_INTPOS or T_INTNEG.
**
*F ObjInt_Int(Int i)
*F ObjInt_UInt(UInt i)
**
****************************************************************************/

Obj ObjInt_Int(Int i);
Obj ObjInt_UInt(UInt i);


/****************************************************************************
**
*F  PrintInt( <int> ) . . . . . . . . . . . . . . . print an integer constant
**
**  'PrintInt'  prints  the integer  <int>   in the  usual  decimal notation.
**  'PrintInt' handles objects of type 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
*/
extern  void            PrintInt (
            Obj                 op );


/****************************************************************************
**
*F  EqInt( <intL>, <intR> ) . . . . . . . . .  test if two integers are equal
**
**  'EqInt' returns 1  if  the two integer   arguments <intL> and  <intR> are
**  equal and 0 otherwise.
*/
extern  Int             EqInt ( 
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  LtInt( <intL>, <intR> ) . . . . . test if an integer is less than another
**
**  'LtInt' returns 1 if the integer <intL> is strictly less than the integer
**  <intR> and 0 otherwise.
*/
extern  Int             LtInt (
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  SumInt( <intL>, <intR> )  . . . . . . . . . . . . . . sum of two integers
**
**  'SumInt' returns the sum of the two integer arguments <intL> and  <intR>.
**  'SumInt' handles operands of type 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvalSum' for a better  efficiency.
*/
extern  Obj             SumInt (
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  DiffInt( <intL>, <intR> ) . . . . . . . . . .  difference of two integers
**
**  'DiffInt' returns the difference of the two integer arguments <intL>  and
**  <intR>.  'DiffInt' handles  operands  of  type  'T_INT',  'T_INTPOS'  and
**  'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvalDiff' for a better efficiency.
*/
extern  Obj             DiffInt (
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  ProdInt( <intL>, <intR> ) . . . . . . . . . . . . product of two integers
**
**  'ProdInt' returns the product of the two  integer  arguments  <intL>  and
**  <intR>.  'ProdInt' handles  operands  of  type  'T_INT',  'T_INTPOS'  and
**  'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvalProd' for a better efficiency.
*/
extern  Obj             ProdInt (
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  ModInt( <intL>, <intR> )  . . representant of residue class of an integer
**
**  'ModInt' returns the smallest positive representant of the residue  class
**  of the  integer  <intL>  modulo  the  integer  <intR>.  'ModInt'  handles
**  operands of type 'T_INT', 'T_INTPOS', 'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvalMod' for a better efficiency.
*/
extern  Obj             ModInt (
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  PowInt( <intL>, <intR> )  . . . . . . . . . . . . . . power of an integer
**
**  'PowInt' returns the <intR>-th (an integer) power of the integer  <intL>.
**  'PowInt' is handles operands of type 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvalPow' for a better  efficiency.
*/
extern  Obj             PowInt (
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  QuoInt( <intL>, <intR> )  . . . . . . . . . . . quotient of two integers
**
**  'QuoInt' returns the integer part of the two integers <intL> and  <intR>.
**  'QuoInt' handles operands of type  'T_INT',  'T_INTPOS'  and  'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**
**  Note that this routine is not called from 'EvalQuo', the  division  of  two
**  integers yields  a  rational  and  is  therefor  performed  in  'QuoRat'.
**  This operation is however available through the internal function 'Quo'.
*/
extern  Obj             QuoInt (
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  RemInt( <intL>, <intR> )  . . . . . . . . . . . remainder of two integers
**
**  'RemInt' returns the remainder of the quotient  of  the  integers  <intL>
**  and <intR>.  'RemInt' handles operands of type  'T_INT',  'T_INTPOS'  and
**  'T_INTNEG'.
**
**  Note that the remainder is different from the value returned by the 'mod'
**  operator which is always positive.
*/
extern  Obj             RemInt (
            Obj                 opL,
            Obj                 opR );


/****************************************************************************
**
*F  GcdInt( <opL>, <opR> )  . . . . . . . . . . . . . . . gcd of two integers
**
**  'GcdInt' returns the gcd of the two integers <opL> and <opR>.
*/
extern  Obj             GcdInt (
            Obj                 opL,
            Obj                 opR );


extern Obj FuncLog2Int( Obj self, Obj intnum);

/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**                                              \
                                                \

*F  InitInfoInt() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoInt ( void );


#endif // USE_GMP

#endif // GAP_INTEGER_H

/****************************************************************************
**
*E  integer.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
