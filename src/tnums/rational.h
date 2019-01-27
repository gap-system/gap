/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares  the  functions  for  the  artithmetic  of  rationals.
**
**  Rationals  are  the union of  integers  and fractions.   A fraction  is a
**  quotient of two integers where the denominator is relatively prime to the
**  numerator.  If in the description of a function we  use the term rational
**  this  implies  that the  function is also   capable of handling integers,
**  though its  function would usually  be performed   by  a routine  in  the
**  integer package.  We will use the  term fraction to  stress the fact that
**  something must not be an integer.
*/

#ifndef GAP_RATIONAL_H
#define GAP_RATIONAL_H

#include "objects.h"

/****************************************************************************
**
*F  NUM_RAT(<rat>)  . . . . . . . . . . . . . . . . . numerator of a rational
*F  DEN_RAT(<rat>)  . . . . . . . . . . . . . . . . denominator of a rational
*/
EXPORT_INLINE Obj NUM_RAT(Obj rat)
{
    GAP_ASSERT(TNUM_OBJ(rat) == T_RAT);
    return CONST_ADDR_OBJ(rat)[0];
}

EXPORT_INLINE Obj DEN_RAT(Obj rat)
{
    GAP_ASSERT(TNUM_OBJ(rat) == T_RAT);
    return CONST_ADDR_OBJ(rat)[1];
}

EXPORT_INLINE void SET_NUM_RAT(Obj rat, Obj val)
{
    GAP_ASSERT(TNUM_OBJ(rat) == T_RAT);
    ADDR_OBJ(rat)[0] = val;
}

EXPORT_INLINE void SET_DEN_RAT(Obj rat, Obj val)
{
    GAP_ASSERT(TNUM_OBJ(rat) == T_RAT);
    ADDR_OBJ(rat)[1] = val;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoRat() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoRat ( void );


#endif // GAP_RATIONAL_H
