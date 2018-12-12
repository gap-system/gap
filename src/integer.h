/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions handling integers.
*/

#ifndef GAP_INTEGER_H
#define GAP_INTEGER_H

#include "objects.h"


#ifdef SYS_IS_64_BIT
#define INTEGER_UNIT_SIZE 8
#else
#define INTEGER_UNIT_SIZE 4
#endif


/****************************************************************************
**
**  'IS_LARGEINT' returns 1 if 'obj' is large positive or negative integer
**  object, and 0 for all other kinds of objects.
*/
static inline Int IS_LARGEINT(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return tnum == T_INTPOS || tnum == T_INTNEG;
}


/****************************************************************************
**
**  'IS_INT' returns 1 if 'obj' is either a large or an immediate integer
**  object, and 0 for all other kinds of objects.
*/
static inline Int IS_INT(Obj obj)
{
    return IS_INTOBJ(obj) || IS_LARGEINT(obj);
}


/****************************************************************************
**
**  'ADDR_INT' returns a pointer to the limbs of the large integer 'obj'.
**  'CONST_ADDR_INT' does the same, but returns a const pointer.
*/
static inline UInt * ADDR_INT(Obj obj)
{
    GAP_ASSERT(IS_LARGEINT(obj));
    return (UInt *)ADDR_OBJ(obj);
}

static inline const UInt * CONST_ADDR_INT(Obj obj)
{
    GAP_ASSERT(IS_LARGEINT(obj));
    return (const UInt *)CONST_ADDR_OBJ(obj);
}


/****************************************************************************
**
**  'SIZE_INT' returns the number of limbs in a large integer object.
*/
static inline UInt SIZE_INT(Obj obj)
{
    GAP_ASSERT(IS_LARGEINT(obj));
    return SIZE_OBJ(obj) / sizeof(UInt);
}


/****************************************************************************
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

/****************************************************************************
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

/****************************************************************************
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


/****************************************************************************
**
**  'IS_EVEN_INT' returns 1 if 'obj' is an even large or immediate integer
**  object, and 0 for all other kinds of objects.
*/
static inline Int IS_EVEN_INT(Obj obj)
{
    return !IS_ODD_INT(obj);
}


/****************************************************************************
**
**  The following functions convert Int, UInt or Int8 respectively into
**  a GAP integer, either an immediate, small integer if possible or
**  otherwise a new GAP bag with TNUM T_INTPOS or T_INTNEG.
*/
extern Obj ObjInt_Int(Int i);
extern Obj ObjInt_UInt(UInt i);
extern Obj ObjInt_Int8(Int8 i);
extern Obj ObjInt_UInt8(UInt8 i);


/****************************************************************************
**
**  The following functions convert a GAP integer into an Int, UInt,
**  Int8 or UInt8 if it is in range. Otherwise it gives an error.
*/
extern Int   Int_ObjInt(Obj i);
extern UInt  UInt_ObjInt(Obj i);
extern Int8  Int8_ObjInt(Obj i);
extern UInt8 UInt8_ObjInt(Obj i);


/****************************************************************************
**
*F  MakeObjInt(<limbs>, <size>) . . . . . . . . . create a new integer object
**
**  Construct an integer object from the limbs at which <limbs> points. The
**  absolute value of <size> determines the number of limbs. If <size> is
**  zero, then `INTOBJ_INT(0)` is returned. Otherwise, the sign of the
**  returned integer object is determined by the sign of <size>.
**
**  Note that GAP automatically reduces and normalized the integer object,
**  i.e., it will discard any leading zeros; and if the integer fits into a
**  small integer, it will be returned as such.
*/
extern Obj MakeObjInt(const UInt * limbs, int size);


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


/****************************************************************************
**
*F  BinomialInt(<n>, <k>) . . . .  return the binomial coefficient of n and k
**
*/
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
