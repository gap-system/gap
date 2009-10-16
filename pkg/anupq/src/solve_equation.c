/****************************************************************************
**
*A  solve_equation.c            ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: solve_equation.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "word_types.h"

/* calculate a solution, x, to the equation a * x = b, 
   where a and b are supplied as exponent vectors with 
   addresses cp1 and cp2; the result is stored as an 
   exponent vector with address result */

void solve_equation (cp1, cp2, result, pcp)
int cp1;
int cp2;
int result;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i, r;
   register int p = pcp->p;
   register int str = pcp->lused + 1;
   register int lastg = pcp->lastg;
#include "access.h"

   y[str] = 1;

   for (i = 1; i <= lastg; ++i) {

      r = y[cp2 + i] - y[cp1 + i];

      if (r < 0) {
	 r += p;
	 y[cp1 + i] = p - r;
      }

      y[result + i] = r;

      if (r != 0) {
	 y[str + 1] = PACK2 (r, i);
	 collect (-str + 1, cp1, pcp);
      }

      y[cp1 + i] = 0;
   }
} 

/* set up input for solve_equation procedure */

void setup_to_solve_equation (format, pcp)
int format;
struct pcp_vars *pcp;
{
   register int lastg = pcp->lastg;
   register int cp1, cp2, result;
   register int total;
   int type;

   total = 5 * lastg + 5;
   if (is_space_exhausted (total, pcp))
      return;

   cp1 = pcp->submlg - lastg - 2;
   cp2 = cp1 - lastg;
   result = cp2 - lastg;

   /* fudge the value of submlg to deal with possible call to power */
   pcp->submlg -= total;

   /* read in a */
   type = VALUE_A;
   setup_word_to_collect (stdin, format, type, cp1, pcp);

   /* read in b */
   type = VALUE_B;
   setup_word_to_collect (stdin, format, type, cp2, pcp);

   /* solve a * x = b and print result */
   solve_equation (cp1, cp2, result, pcp);

   setup_word_to_print ("value of x", result, pcp->lused, pcp);

   /* reset the value of submlg */
   pcp->submlg += total;
}
