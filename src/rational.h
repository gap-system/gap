/****************************************************************************
**
*W  rational.h                  GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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


/****************************************************************************
**
*F  NUM_RAT(<rat>)  . . . . . . . . . . . . . . . . . numerator of a rational
*F  DEN_RAT(<rat>)  . . . . . . . . . . . . . . . . denominator of a rational
*/
static inline Obj NUM_RAT(Obj rat)
{
    return CONST_ADDR_OBJ(rat)[0];
}

static inline Obj DEN_RAT(Obj rat)
{
    return CONST_ADDR_OBJ(rat)[1];
}

static inline void SET_NUM_RAT(Obj rat, Obj val)
{
    ADDR_OBJ(rat)[0] = val;
}

static inline void SET_DEN_RAT(Obj rat, Obj val)
{
    ADDR_OBJ(rat)[1] = val;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoRat() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoRat ( void );


#endif // GAP_RATIONAL_H
