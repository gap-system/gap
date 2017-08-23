/****************************************************************************
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
*/

#ifndef GAP_INTOBJ_H
#define GAP_INTOBJ_H

#include <src/system.h>


/****************************************************************************
**
*F  IS_INTOBJ( <o> )  . . . . . . . .  test if an object is an integer object
**
**  'IS_INTOBJ' returns 1 if the object <o> is an (immediate) integer object,
**  and 0 otherwise.
*/
static inline Int IS_INTOBJ(Obj o)
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
static inline Int IS_POS_INTOBJ(Obj o)
{
    return ((Int)o & 0x01) && ((Int)o > 0x01);
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
#define EQ_INTOBJS(o,l,r) \
    ((o) = (((Int)(l)) == ((Int)(r)) ? True : False))


/****************************************************************************
**
*F  LT_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'LT_INTOBJS' returns 'True' if the  (immediate)  integer  object  <l>  is
**  less than the (immediate) integer object <r> and  'False' otherwise.  The
**  result is also stored in <o>.
*/
#define LT_INTOBJS(o,l,r) \
    ((o) = (((Int)(l)) <  ((Int)(r)) ? True : False))


/****************************************************************************
**
*F  SUM_INTOBJS( <o>, <l>, <r> )  . . . . . . . .  sum of two integer objects
**
**  'SUM_INTOBJS' returns  1  if  the  sum  of  the  (imm.)  integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The sum itself is stored in <o>.
*/
#define SUM_INTOBJS(o,l,r)             \
    ((o) = (Obj)((Int)(l)+(Int)(r)-1), \
     ((((UInt) (o)) >> (sizeof(UInt)*8-2))-1) > 1)


/****************************************************************************
**
*F  DIFF_INTOBJS( <o>, <l>, <r> ) . . . . . difference of two integer objects
**
**  'DIFF_INTOBJS' returns 1 if the difference of the (imm.) integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The difference itself is stored in <o>.
*/
#define DIFF_INTOBJS(o,l,r)            \
    ((o) = (Obj)((Int)(l)-(Int)(r)+1), \
     ((((UInt) (o)) >> (sizeof(UInt)*8-2))-1) > 1)


/****************************************************************************
**
*F  PROD_INTOBJS( <o>, <l>, <r> ) . . . . . .  product of two integer objects
**
**  'PROD_INTOBJS' returns 1 if the product of  the  (imm.)  integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The product itself is stored in <o>.
*/


#if SIZEOF_VOID_P == SIZEOF_INT && defined(HAVE___BUILTIN_SMUL_OVERFLOW) && defined(HAVE_ARITHRIGHTSHIFT)
static inline Obj prod_intobjs(int l, int r)
{
  int prod;
  if (__builtin_smul_overflow(l >> 1, r ^ 1, &prod))
    return (Obj) 0;
  return (Obj) ((prod >> 1) ^ 1);
}
#elif SIZEOF_VOID_P == SIZEOF_LONG && defined(HAVE___BUILTIN_SMULL_OVERFLOW) && defined(HAVE_ARITHRIGHTSHIFT)
static inline Obj prod_intobjs(long l, long r)
{
  long prod;
  if (__builtin_smull_overflow(l >> 1, r ^ 1, &prod))
    return (Obj) 0;
  return (Obj) ((prod >> 1) ^ 1);
}
#elif SIZEOF_VOID_P == SIZEOF_LONG_LONG && defined(HAVE___BUILTIN_SMULLL_OVERFLOW) && defined(HAVE_ARITHRIGHTSHIFT)
static inline Obj prod_intobjs(long long l, long long r)
{
  long long prod;
  if (__builtin_smulll_overflow(l >> 1, r ^ 1, &prod))
    return (Obj) 0;
  return (Obj) ((prod >> 1) ^ 1);
}
#else

#ifdef SYS_IS_64_BIT
#define HALF_A_WORD 32
#else
#define HALF_A_WORD 16
#endif

static inline Obj prod_intobjs(Int l, Int r)
{
  Int prod;
  if (l == (Int)INTOBJ_INT(0) || r == (Int)INTOBJ_INT(0))
    return INTOBJ_INT(0);
  if (l == (Int)INTOBJ_INT(1))
    return (Obj)r;
  if (r == (Int)INTOBJ_INT(1))
    return (Obj)l;
  prod = ((Int)((UInt)l >> 2) * ((UInt)r-1)+1);

  if (((((UInt) (prod)) >> (sizeof(UInt)*8-2))-1) <= 1)
    return (Obj) 0;

  if ((Int)(((UInt)l)<<HALF_A_WORD)>>HALF_A_WORD == (Int) l &&
      (Int)(((UInt)r)<<HALF_A_WORD)>>HALF_A_WORD == (Int) r)
    return (Obj) prod;

#ifdef HAVE_ARITHRIGHTSHIFT
  if ((prod -1) / (l >> 2) == r-1)
    return (Obj) prod;
#else
  if ((prod-1) / ((l-1)/4) == r-1)
    return (Obj) prod;
#endif

  return (Obj) 0;
}
#endif

#define PROD_INTOBJS( o, l, r) ((o) = prod_intobjs((Int)(l),(Int)(r)), \
                                  (o) != (Obj) 0)

#endif // GAP_INTOBJ_H
