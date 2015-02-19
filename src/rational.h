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
#define NUM_RAT(rat)    ADDR_OBJ(rat)[0]
#define DEN_RAT(rat)    ADDR_OBJ(rat)[1]

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

/****************************************************************************
**

*E  rational.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
