/****************************************************************************
**
*W  integer.h                   GAP source                     John McDermott
**                                                           
**                                                           
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions handling integers.
*/

#ifndef GAP_INTEGER_H
#define GAP_INTEGER_H

#include <src/objects.h>

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
// GMP and a plugin against another, we may want to add some checks.
// E.g. add to config.h another #define GAP_GMP_LIMB_BITS and compare
// that during compile time with GMP_LIMB_BITS.


#ifdef SYS_IS_64_BIT
#define INTEGER_UNIT_SIZE 8
#else
#define INTEGER_UNIT_SIZE 4
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


/**************************************************************************
**
**  'IS_LARGEINT' returns 1 if 'obj' is large positive or negative integer
**  object, and 0 for all other kinds of objects.
*/
static inline Int IS_LARGEINT(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return tnum == T_INTPOS || tnum == T_INTNEG;
}


/**************************************************************************
**
**  'IS_INT' returns 1 if 'obj' is either a large or an immediate integer
**  object, and 0 for all other kinds of objects.
*/
static inline Int IS_INT(Obj obj)
{
    return IS_INTOBJ(obj) || IS_LARGEINT(obj);
}


/**************************************************************************
**
**  'ADDR_INT' returns a pointer to the limbs of the large integer 'obj'.
**  'CONST_ADDR_INT' does the same, but returns a const pointer.
*/
static inline mp_limb_t * ADDR_INT(Obj obj)
{
    GAP_ASSERT(IS_LARGEINT(obj));
    return (mp_limb_t *)ADDR_OBJ(obj);
}

static inline const mp_limb_t * CONST_ADDR_INT(Obj obj)
{
    GAP_ASSERT(IS_LARGEINT(obj));
    return (const mp_limb_t *)CONST_ADDR_OBJ(obj);
}


/**************************************************************************
**
**  'SIZE_INT' returns the number of limbs in a large integer object.
*/
static inline UInt SIZE_INT(Obj obj)
{
    GAP_ASSERT(IS_LARGEINT(obj));
    return SIZE_OBJ(obj) / sizeof(mp_limb_t);
}


/**************************************************************************
**
**  'IS_NEG_INT' returns 1 if 'obj' is a negative large or immediate
**  integer object, and 0 for all other kinds of objects.
*/
static inline Int IS_NEG_INT(Obj obj)
{
    if (IS_INTOBJ(obj))
        return (Int)obj < (Int)INTOBJ_INT(0);
    return TNUM_OBJ(obj) == T_INTNEG;
}

/**************************************************************************
**
**  'IS_POS_INT' returns 1 if 'obj' is a positive large or immediate
**  integer object, and 0 for all other kinds of objects.
*/
static inline Int IS_POS_INT(Obj obj)
{
    if (IS_INTOBJ(obj))
        return (Int)obj > (Int)INTOBJ_INT(0);
    return TNUM_OBJ(obj) == T_INTPOS;
}

/**************************************************************************
**
**  'IS_ODD_INT' returns 1 if 'obj' is an odd large or immediate integer
**  object, and 0 for all other kinds of objects.
*/
static inline Int IS_ODD_INT(Obj obj)
{
    if (IS_INTOBJ(obj))
        return ((Int)obj & 4) != 0;
    return (*CONST_ADDR_INT(obj)) & 1;
}


/**************************************************************************
**
**  'IS_EVEN_INT' returns 1 if 'obj' is an even large or immediate integer
**  object, and 0 for all other kinds of objects.
*/
static inline Int IS_EVEN_INT(Obj obj)
{
    return !IS_ODD_INT(obj);
}


/**************************************************************************
**
**  The following functions convert Int, UInt or Int8 respectively into
**  a GAP integer, either an immediate, small integer if possible or 
**  otherwise a new GAP bag with TNUM T_INTPOS or T_INTNEG.
*/
extern Obj ObjInt_Int(Int i);
extern Obj ObjInt_UInt(UInt i);
extern Obj ObjInt_Int8(Int8 i);
extern Obj ObjInt_UInt8(UInt8 i);

/**************************************************************************
**
**  The following functions convert a GAP integer into an Int, UInt,
**  Int8 or UInt8 if it is in range. Otherwise it gives an error.
*/
extern Int Int_ObjInt(Obj i);    
extern UInt UInt_ObjInt(Obj i);    
extern Int8 Int8_ObjInt(Obj i);    
extern UInt8 UInt8_ObjInt(Obj i);    

    
/****************************************************************************
**
**  Reduce and normalize the given large integer object if necessary.
**
**  TODO: This is an internal implementation detail and ideally should not
**  be exported; unfortunately, FuncNUMBER_GF2VEC currently needs this.
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


// Parse a string containing a decimal integer into a GAP integer
// object. Returns 'fail' if the input is not a valid decimal.
// This function handles signs.
//
// If <string> is non-NULL, then <str> is ignored, and <string>
// must reference a GAP string object. If <string> is NULL, then
// <str> must point to a C string.
Obj IntStringInternal(Obj string, const Char *str);


/****************************************************************************
**
*F  EqInt( <opL>, <opR> ) . . . . . test if two integers are equal
**
**  'EqInt' returns 1  if  the two GMP integer arguments <opL> and  
**  <opR> are equal and 0 otherwise.
*/
extern Int EqInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  LtInt( <opL>, <opR> )  test if an integer is less than another
**
**  'LtInt' returns 1 if the integer <opL> is strictly less than the 
**  integer <opR> and 0 otherwise.
*/
extern Int LtInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  SumInt( <opL>, <opR> )  . . . . . . . . .  sum of two integers
**
**  'SumInt' returns the sum of the two integer arguments <opL> and
**  <opR>.
**
*/
extern Obj SumInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  DiffInt( <opL>, <opR> ) . . . . difference of two integers
**
**  'DiffInt' returns the difference of the two integer arguments <opL>
**  and <opR>.
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
*F  ProdInt( <opL>, <opR> ) . . . . .  product of two integers
**
**  'ProdInt' returns the product of the two integer arguments <opL>
**  and <opR>.
**
*/
extern Obj ProdInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  ModInt( <opL>, <opR> ) representative of res class of an integer
**
**  'ModInt' returns the smallest positive representative of the residue
**  class of the  integer  <opL>  modulo  the  integer  <opR>.
**
*/
extern Obj ModInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  PowInt( <opL>, <opR> )  . . . . . . . . power of an integer
**
**  'PowInt' returns the <opR>-th power of the integer <opL>.
**
*/
extern Obj PowInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  QuoInt( <opL>, <opR> )  . . . . . quotient of two integers
**
**  'QuoInt' returns the integer part of the two integers <opL> and
**  <opR>.
**
*/
extern Obj QuoInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  RemInt( <opL>, <opR> )  . . . .  remainder of two integers
**
**  'RemInt' returns the remainder of the quotient of the integers
**  <opL> and <opR>.
**
*/
extern Obj RemInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  GcdInt( <opL>, <opR> )  . . . . . . .  gcd of two integers
**
**  'GcdInt' returns the gcd of the two integers <opL> and <opR>.
*/
extern Obj GcdInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  LcmInt( <opL>, <opR> )  . . . . . . .  lcm of two integers
**
**  'LcmInt' returns the lcm of the two integers <opL> and <opR>.
*/
extern Obj LcmInt( Obj opL, Obj opR );


/****************************************************************************
**
*F  AInvInt( <op> ) . . . . . . . . . . . . .  additive inverse of an integer
**
*/
extern Obj AInvInt( Obj op );


/****************************************************************************
**
*F  InverseModInt( <op> ) . . . .  mult. inverse of an integer modulo another
**
*/
extern Obj InverseModInt(Obj base, Obj mod);


/****************************************************************************
**
**  Compute log2 of the absolute value of an Int, i.e. the index of the highest
**  set bit. For input 0, return -1.
*/
extern Int CLog2Int( Int intnum );

// Compute the binomial coefficient of n and k
extern Obj BinomialInt(Obj n, Obj k);

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoInt() . . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoInt( void );

#endif // GAP_INTEGER_H
