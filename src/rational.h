/****************************************************************************
**
*W  rational.h                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_rational_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  SetupRat()  . . . . . . . . . . . . . . . initialize the rational package
*/
extern void SetupRat ( void );


/****************************************************************************
**
*F  InitRat() . . . . . . . . . . . . . . . . initialize the rational package
**
**  'InitRat' initializes the rational package.
*/
extern void InitRat ( void );


/****************************************************************************
**
*F  CheckRat()  . . . . . .  check the initialisation of the rational package
*/
extern void CheckRat ( void );


/****************************************************************************
**

*E  rational.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/

