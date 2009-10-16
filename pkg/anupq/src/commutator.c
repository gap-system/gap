/****************************************************************************
**
*A  commutator.c                ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: commutator.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pretty_filterfns.h"
#include "word_types.h"
#include "constants.h"

/* calculate a solution, x, to the equation 
          
          u_1 * v_1 * x = u_2 * v_2  

   where u_1, v_1, u_2, v_2 are exponent vectors with 
   base addresses cp1, cp2, cp3, cp4, respectively;

   the result is stored as an exponent vector with address result;
   
   with appropriate initial values, this procedure may be
   used to calculate a commutator; the algorithm finds a 
   solution generator by generator */

void find_commutator (cp1, cp2, cp3, cp4, result, pcp)
int cp1;
int cp2;
int cp3;
int cp4;
int result;
struct pcp_vars *pcp;
{
#include "define_y.h"
   int r;     
   int exp;
   register int i;
   int str = pcp->lused + 1;
   register int p = pcp->p;
   register int lastg = pcp->lastg;

#include "access.h"

   y[str] = 1;
    
   for (i = 1; i <= lastg; ++i) {

      /* compute r and adjust its value mod p */
      r = (y[cp3 + i] + y[cp4 + i]) - (y[cp1 + i] + y[cp2 + i]);
      while (r < 0) r += p;
      while (r >= p) r -= p;

      /* store the exponent of generator i in x */
      y[result + i] = r;

      /* now compute the new u_2 */
      if (y[cp4 + i] != 0) {
	 y[str + 1] = PACK2 (y[cp4 + i], i);
	 collect (-str + 1, cp3, pcp);
	 y[cp3 + i] = 0;
      }

      /* compute the residue mod p */
      exp = y[cp2 + i] + r;
      while (exp < 0) exp += p;
      exp %= p;

      /* now compute the new v_1 */
      if (y[cp2 + i] + r >= p)
	 y[cp2 + i] = p - r;
      if (r != 0) {
	 y[str + 1] = PACK2 (r, i);
	 collect (-str + 1, cp2, pcp);
      }

      /* now compute the new u_1 */
      if (y[cp1 + i] + exp >= p)
	 y[cp2 + i] = p - exp;
      if (exp != 0) {
	 y[str + 1] = PACK2 (exp, i);
	 collect (-str + 1, cp1, pcp);
      }
   }
}

/* copy a section of the array, y, to another part of y */

void copy (old, length, new, pcp)
int old;
int length;
int new;
struct pcp_vars *pcp;
{
#include "define_y.h"

   for (; length > 0; --length)
      y[new + length] = y[old + length];
}

/* calculate a power of a left-normed commutator of supplied depth 
   by repeated calls to find_commutator; set up the result as an 
   exponent vector with base address pcp->lused in order to permit 
   the result to be handed to echelon easily */

void calculate_commutator (format, pcp)
int format;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int ptr, cp1, cp2, cp3, cp4, result;
   register int lastg = pcp->lastg;
   register int total;
   int disp = 0;
   int type;
   int depth;
   int exp;

   total = 6 * lastg + 6;
   if (is_space_exhausted (total, pcp))
      return;

   cp1 = pcp->submlg - lastg - 2;
   cp2 = cp1 - lastg;
   cp3 = cp2 - lastg;
   cp4 = cp3 - lastg;
   result = cp4 - lastg;
   ptr = pcp->lused + 1;

   /* fudge the value of submlg because of possible call to power */
   pcp->submlg -= total;

   read_value (TRUE, "Input number of components of commutator: ", &depth, 2);

   /* read in a and set it up at cp2 and cp3 */
   type = FIRST_ENTRY;

   if (format == BASIC)
      read_word (stdin, disp, type, pcp);
   else 
      pretty_read_word (stdin, disp, type, pcp);

   collect_word (ptr, cp2, pcp);
   copy (cp2, lastg, cp3, pcp);

   type = NEXT_ENTRY;
   disp = y[ptr] + 1;

   while (--depth > 0) {

      /* read in next component, b, and set it up at cp1 and cp4 */
      if (format == BASIC)
	 read_word (stdin, disp, type, pcp);
      else 
	 pretty_read_word (stdin, disp, type, pcp);

      collect_word (ptr + disp, cp1, pcp);
      copy (cp1, lastg, cp4, pcp);

      /* solve the equation (ba) * x = ab to obtain [a, b] */
      find_commutator (cp1, cp2, cp3, cp4, result, pcp);

      copy (result, lastg, cp2, pcp);
      copy (result, lastg, cp3, pcp);
   }

   read_value (TRUE, "Input required power of this commutator: ", &exp, 1);
   power (exp, result, pcp);

   /* print the commutator */
   setup_word_to_print ("commutator", result, ptr, pcp);

   /* copy result to pcp->lused */
   copy (result, lastg, pcp->lused, pcp);

   /* reset the value of submlg */
   pcp->submlg += total;
}
