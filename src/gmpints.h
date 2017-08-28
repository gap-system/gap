/****************************************************************************
**
*W  gmpints.h                   GAP source                     John McDermott
**                                                           
**                                                           
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions handling gmp integers.
*/

#ifndef GAP_GMPINTS_H
#define GAP_GMPINTS_H

// GMP must be included outside of 'extern C'
#ifdef GAP_IN_EXTERN_C
}
#endif
#include <gmp.h>
#ifdef GAP_IN_EXTERN_C
extern "C" {
#endif

// TODO: Instead of hardcoding the values below, use
//   GMP_LIMB_BITS etc. directly.
//
// To safeguard against bugs like compiling GAP against one version of
// GMP and a plugin against another, we may want to add some safeguards.
// E.g. add to config.h another #define GAP_GMP_LIMB_BITS and compare
// that during compile time with GMP_LIMB_BITS.


#ifdef SYS_IS_64_BIT
#define INTEGER_UNIT_SIZE 8
#define NR_SMALL_INT_BITS  (64 - 4)
#else
#define INTEGER_UNIT_SIZE 4
#define NR_SMALL_INT_BITS  (32 - 4)
#endif

#if (GMP_LIMB_BITS != INTEGER_UNIT_SIZE * 8)
#error Aborting compile: unexpected GMP limb size
#endif
#if GMP_NAIL_BITS != 0
#error Aborting compile: GAP does not support non-zero GMP nail size
#endif
#if !defined(__GNU_MP_RELEASE)
 #if __GMP_MP_RELEASE < 50002
 #error Aborting compile: GAP requires GMP 5.0.2 or newer
 #endif
#endif


#define ADDR_INT(obj)          ((mp_limb_t *)ADDR_OBJ(obj))
#define SIZE_INT(obj)          ((mp_size_t)SIZE_OBJ(obj)/sizeof(mp_limb_t))
/* SIZE_INT gives a result in limbs                                        */


/**************************************************************************
**
** The following functions convert Int, UInt or Int8 respectively into
** a GAP integer, either an immediate, small integer if possible or 
** otherwise a new GAP bag with TNUM T_INTPOS or T_INTNEG.
*/
extern Obj ObjInt_Int(Int i);
extern Obj ObjInt_UInt(UInt i);
extern Obj ObjInt_Int8(Int8 i);

/****************************************************************************
**
** Reduce and normalize the given large integer object if necessary.
**
** TODO: This is an internal implementation detail and ideally should not
** be exported; unfortunately, FuncNUMBER_GF2VEC currently needs this.
*/
extern Obj GMP_REDUCE( Obj gmp );
extern Obj GMP_NORMALIZE( Obj gmp );


/****************************************************************************
**
*F  PrintInt( <int> ) . . . . . . . . . . . . . . . print an integer constant
**
**  'PrintInt'  prints  the integer  <int>   in the  usual  decimal notation.
**  'PrintInt' handles objects of type 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
*/
extern void PrintInt( Obj op );


/****************************************************************************
**
*F  EqInt( <gmpL>, <gmpR> ) . . . . . test if two integers are equal
**
**  'EqInt' returns 1  if  the two GMP integer arguments <gmpL> and  
**  <gmpR> are equal and 0 otherwise.
*/
extern Int EqInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  LtInt( <gmpL>, <gmpR> )  test if an integer is less than another
**
**  'LtInt' returns 1 if the integer <gmpL> is strictly less than the 
**  integer <gmpR> and 0 otherwise.
*/
extern Int LtInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  SumInt( <gmpL>, <gmpR> )  . . . . . . . . .  sum of two integers
**
**  'SumInt' returns the sum of the two integer arguments <gmpL> and
**  <gmpR>.
**
*/
extern Obj SumInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  DiffInt( <gmpL>, <gmpR> ) . . . . difference of two GMP integers
**
**  'DiffInt' returns the difference of the two integer arguments <gmpL>
**  and <gmpR>.
**
*/
extern Obj DiffInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  AbsInt( <op> ) . . . . . . . . . . . . . . . absolute value of an integer
*/
extern Obj AbsInt( Obj op );


/****************************************************************************
**
*F  SignInt( <op> ) . . . . . . . . . . . . . . . . . . .  sign of an integer
*/
extern Obj SignInt( Obj op );


/****************************************************************************
**
*F  ProdInt( <gmpL>, <gmpR> ) . . . . .  product of two GMP integers
**
**  'ProdInt' returns the product of the two integer arguments <gmpL>
**  and <gmpR>.
**
*/
extern Obj ProdInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  ModInt( <gmpL>, <gmpR> ) representative of res cl of a GMP integer
**
**  'ModInt' returns the smallest positive representative of the residue
**  class of the  integer  <gmpL>  modulo  the  integer  <gmpR>.
**
*/
extern Obj ModInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  PowInt( <gmpL>, <gmpR> )  . . . . . . . . power of a GMP integer
**
**  'PowInt' returns the <gmpR>-th(a GMP int) power of the GMP integer
**  <gmpL>.
**
*/
extern Obj PowInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  QuoInt( <gmpL>, <gmpR> )  . . . . . quotient of two GMP integers
**
**  'QuoInt' returns the integer part of the two integers <gmpL> and
**  <gmpR>.
**
*/
extern Obj QuoInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  RemInt( <gmpL>, <gmpR> )  . . . .  remainder of two GMP integers
**
**  'RemInt' returns the remainder of the quotient of the GMP ints
**  <gmpL> and <gmpR>.
**
*/
extern Obj RemInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  GcdInt( <gmpL>, <gmpR> )  . . . . . . .  gcd of two GMP integers
**
**  'GcdInt' returns the gcd of the two integers <gmpL> and <gmpR>.
*/
extern Obj GcdInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  AInvInt( <op> ) . . . . . . . . . . . . .  additive inverse of an integer
**
*/
extern Obj AInvInt( Obj op );


/****************************************************************************
**
** Compute log2 of the absolute value of an Int, i.e. the index of the highest
** set bit. For input 0, return -1.
*/
extern Int CLog2Int( Int intnum );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoInt() . . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoInt( void );

#endif // GAP_GMPINTS_H
