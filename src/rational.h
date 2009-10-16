/****************************************************************************
**
*W  rational.h                  GAP source                   Martin Schoenert
**
*H  @(#)$Id: rational.h,v 4.7 2002/04/15 10:03:55 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_rational_h =
   "@(#)$Id: rational.h,v 4.7 2002/04/15 10:03:55 sal Exp $";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoRat() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoRat ( void );


/****************************************************************************
**

*E  rational.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/

