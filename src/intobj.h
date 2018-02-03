/****************************************************************************
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file implements helper for dealing with GAP immediate integers.
**
**  Small integers are represented by an immediate integer handle, containing
**  the value instead of pointing to it, which has the following form:
**
**      +-------+-------+-------+-------+- - - -+-------+-------+-------+
**      | guard | sign  | bit   | bit   |       | bit   | tag   | tag   |
**      | bit   | bit   | N-5   | N-6   |       | 0     |  = 0  |  = 1  |
**      +-------+-------+-------+-------+- - - -+-------+-------+-------+
**
**  Immediate integers handles carry the tag 'T_INT', i.e. the last bit is 1.
**  This distinguishes immediate integers from other handles which point to
**  structures aligned on even boundaries and therefore have last bit zero.
**  (The second bit is reserved as tag to allow extensions of this scheme.)
**  Using immediates as pointers and dereferencing them gives address errors.
**
**  To aid overflow check the most significant two bits must always be equal,
**  that is to say that the sign bit of immediate integers has a guard bit.
**
**  The macros 'INTOBJ_INT' and 'INT_INTOBJ' should be used to convert between
a
**  small integer value and its representation as immediate integer handle.

*/

#ifndef GAP_INTOBJ_H
#define GAP_INTOBJ_H

#include <src/system.h>
#include <src/debug.h>

#ifdef SYS_IS_64_BIT
#define NR_SMALL_INT_BITS  (64 - 4)
#else
#define NR_SMALL_INT_BITS  (32 - 4)
#endif

// the minimal / maximal possible values of an immediate integer object:
#define INT_INTOBJ_MIN  (-(1L << NR_SMALL_INT_BITS))
#define INT_INTOBJ_MAX  ((1L << NR_SMALL_INT_BITS) - 1)

// the minimal / maximal possible immediate integer objects:
#define INTOBJ_MIN  INTOBJ_INT(INT_INTOBJ_MIN)
#define INTOBJ_MAX  INTOBJ_INT(INT_INTOBJ_MAX)


/****************************************************************************
**
*F  IS_INTOBJ( <o> )  . . . . . . . .  test if an object is an integer object
**
**  'IS_INTOBJ' returns 1 if the object <o> is an (immediate) integer object,
**  and 0 otherwise.
*/
static inline BOOL IS_INTOBJ(Obj o)
{
    return (Int)o & 0x01;
}


/****************************************************************************
**
*F  IS_POS_INTOBJ( <o> )  . .  test if an object is a positive integer object
**
**  'IS_POS_INTOBJ' returns 1 if the object <o> is an (immediate) integer
**  object encoding a positive integer, and 0 otherwise.
*/
static inline BOOL IS_POS_INTOBJ(Obj o)
{
    return ((Int)o & 0x01) && ((Int)o > 0x01);
}

/****************************************************************************
**
*F  IS_NONNEG_INTOBJ( <o> )  . .  test if an object is a non-negative integer object
**
**  'IS_NONNEG_INTOBJ' returns 1 if the object <o> is an (immediate) integer
**  object encoding a non-negative integer, and 0 otherwise.
*/
static inline BOOL IS_NONNEG_INTOBJ(Obj o)
{
    return ((Int)o & 0x01) && ((Int)o > 0);
}


/****************************************************************************
**
*F  ARE_INTOBJS( <o1>, <o2> ) . . . . test if two objects are integer objects
**
**  'ARE_INTOBJS' returns 1 if the objects <o1> and <o2> are both (immediate)
**  integer objects.
*/
static inline Int ARE_INTOBJS(Obj o1, Obj o2)
{
    return (Int)o1 & (Int)o2 & 0x01;
}


/****************************************************************************
**
*F  INT_INTOBJ( <o> ) . . . . . . .  convert an integer object to a C integer
**
**  'INT_INTOBJ' converts the (immediate) integer object <o> to a C integer.
*/
/* Note that the C standard does not define what >> does here if the
 * value is negative. So we have to be careful if the C compiler
 * chooses to do a logical right shift. */
static inline Int INT_INTOBJ(Obj o)
{
    GAP_ASSERT(IS_INTOBJ(o));
#ifdef HAVE_ARITHRIGHTSHIFT
    return (Int)o >> 2;
#else
    return ((Int)o - 1) / 4;
#endif
}


/****************************************************************************
**
*F  INTOBJ_INT( <i> ) . . . . . . .  convert a C integer to an integer object
**
**  'INTOBJ_INT' converts the C integer <i> to an (immediate) integer object.
*/
static inline Obj INTOBJ_INT(Int i)
{
    Obj o;
    GAP_ASSERT(INT_INTOBJ_MIN <= i && i <= INT_INTOBJ_MAX);
    o = (Obj)(((UInt)i << 2) + 0x01);
    GAP_ASSERT(INT_INTOBJ(o) == i);
    return o;
}

/****************************************************************************
**
*F  EQ_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'EQ_INTOBJS' returns 'True' if the  (immediate)  integer  object  <l>  is
**  equal to the (immediate) integer object <r> and  'False'  otherwise.  The
**  result is also stored in <o>.
*/
#define EQ_INTOBJS(o, l, r) ((o) = (((Int)(l)) == ((Int)(r)) ? True : False))


/****************************************************************************
**
*F  LT_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'LT_INTOBJS' returns 'True' if the  (immediate)  integer  object  <l>  is
**  less than the (immediate) integer object <r> and  'False' otherwise.  The
**  result is also stored in <o>.
*/
#define LT_INTOBJS(o, l, r) ((o) = (((Int)(l)) < ((Int)(r)) ? True : False))


//
// Check whether the sign and guard bit of the given word match.
//
static inline int DETECT_INTOBJ_OVERFLOW(UInt o)
{
    const UInt BITS_IN_UINT = sizeof(UInt) * 8;
    // extract sign bit + guard bit
    const UInt top_bits = ((UInt)o) >> (BITS_IN_UINT - 2);
    // the integer object is valid if the two top bits are equal, i.e. if
    // top_bits is 0 or 3. If we subtract 1 from this, the valid values are 2
    // and (UInt)-1, which both are larger than 1; the invalid values are 0
    // and 1.
    return (top_bits - 1) <= 1;
}


/****************************************************************************
**
*F  SUM_INTOBJS( <o>, <l>, <r> )  . . . . . . . .  sum of two integer objects
**
**  'SUM_INTOBJS' returns  1  if  the  sum  of  the  (imm.)  integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The sum itself is stored in <o>.
*/
static inline int sum_intobjs(Obj * o, Obj l, Obj r)
{
    const Int tmp = (Int)l + (Int)r - 1;
    if (DETECT_INTOBJ_OVERFLOW(tmp))
        return 0;
    *o = (Obj)tmp;
    return 1;
}
#define SUM_INTOBJS(o, l, r) sum_intobjs(&(o), (l), (r))


/****************************************************************************
**
*F  DIFF_INTOBJS( <o>, <l>, <r> ) . . . . . difference of two integer objects
**
**  'DIFF_INTOBJS' returns 1 if the difference of the (imm.) integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The difference itself is stored in <o>.
*/
static inline int diff_intobjs(Obj * o, Obj l, Obj r)
{
    const Int tmp = (Int)l - (Int)r + 1;
    if (DETECT_INTOBJ_OVERFLOW(tmp))
        return 0;
    *o = (Obj)tmp;
    return 1;
}
#define DIFF_INTOBJS(o, l, r) diff_intobjs(&(o), (l), (r))


/****************************************************************************
**
*F  PROD_INTOBJS( <o>, <l>, <r> ) . . . . . .  product of two integer objects
**
**  'PROD_INTOBJS' returns 1 if the product of  the  (imm.)  integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The product itself is stored in <o>.
*/


#if SIZEOF_VOID_P == SIZEOF_INT && defined(HAVE_ARITHRIGHTSHIFT) &&          \
    defined(HAVE___BUILTIN_SMUL_OVERFLOW)
static inline Obj prod_intobjs(int l, int r)
{
    int prod;
    if (__builtin_smul_overflow(l >> 1, r ^ 1, &prod))
        return (Obj)0;
    return (Obj)((prod >> 1) ^ 1);
}
#elif SIZEOF_VOID_P == SIZEOF_LONG && defined(HAVE_ARITHRIGHTSHIFT) &&       \
    defined(HAVE___BUILTIN_SMULL_OVERFLOW)
static inline Obj prod_intobjs(long l, long r)
{
    long prod;
    if (__builtin_smull_overflow(l >> 1, r ^ 1, &prod))
        return (Obj)0;
    return (Obj)((prod >> 1) ^ 1);
}
#elif SIZEOF_VOID_P == SIZEOF_LONG_LONG && defined(HAVE_ARITHRIGHTSHIFT) &&  \
    defined(HAVE___BUILTIN_SMULLL_OVERFLOW)
static inline Obj prod_intobjs(long long l, long long r)
{
    long long prod;
    if (__builtin_smulll_overflow(l >> 1, r ^ 1, &prod))
        return (Obj)0;
    return (Obj)((prod >> 1) ^ 1);
}
#else

#ifdef SYS_IS_64_BIT
typedef Int4 HalfInt;
#else
typedef Int2 HalfInt;
#endif

static inline Obj prod_intobjs(Int l, Int r)
{
    if (l == (Int)INTOBJ_INT(0) || r == (Int)INTOBJ_INT(0))
        return INTOBJ_INT(0);
    if (l == (Int)INTOBJ_INT(1))
        return (Obj)r;
    if (r == (Int)INTOBJ_INT(1))
        return (Obj)l;

    const Int prod = ((Int)((UInt)l >> 2) * ((UInt)r - 1) + 1);

    if (DETECT_INTOBJ_OVERFLOW(prod))
        return (Obj)0;

    // if both factors fit into half a word, their product fits in a word
    if ((HalfInt)l == (Int)l && (HalfInt)r == (Int)r)
        return (Obj)prod;

// last resort: perform trial division
#ifdef HAVE_ARITHRIGHTSHIFT
    if ((prod - 1) / (l >> 2) == r - 1)
        return (Obj)prod;
#else
    if ((prod - 1) / ((l - 1) / 4) == r - 1)
        return (Obj)prod;
#endif

    return (Obj)0;
}
#endif

#define PROD_INTOBJS(o, l, r) ((o) = prod_intobjs((Int)(l), (Int)(r)))

#endif    // GAP_INTOBJ_H
