/****************************************************************************
**
*A  extend_automorphisms.c      ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: extend_automorphisms.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

int nmr_of_bytes;

/* for each automorphism, compute its action on each of the generators */

void extend_automorphisms (auts, nmr_of_auts, pcp)
int ***auts;
int nmr_of_auts;
struct pcp_vars *pcp;
{
   register int alpha;
   nmr_of_bytes = pcp->lastg * sizeof (int);

   if (is_space_exhausted (7 * pcp->lastg + 4, pcp))
      return;

   for (alpha = 1; alpha <= nmr_of_auts; ++alpha)  
      extend_automorphism (auts[alpha], pcp);
}

/* extend the automorphism whose action on the defining generators 
   of the group is described by the supplied 2-dimensional matrix, 
   auts, to act on all of the generators of the group */

void extend_automorphism (auts, pcp)
int **auts;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int generator;
   register int lastg = pcp->lastg;
   register int structure = pcp->structure; 

   int cp1 = pcp->submlg - lastg - 2;
   int cp2 = cp1 - lastg;
   int result = cp2 - lastg;
   int start = y[pcp->clend + 1] + 1;
   register int value;
   int u, v;

#include "access.h"

   /* update submlg because of possible call to power */
   pcp->submlg -= (3 * lastg + 2);

   /* for each generator, compute its image under the action of auts */
   for (generator = start; generator <= lastg; ++generator) {

      /* examine the definition of generator */
      value = y[structure + generator];
      u = PART2 (value);
      v = PART3 (value);

      if (v == 0)  
	 extend_power (cp1, cp2, u, auts, pcp);
      else  
	 extend_commutator (cp1, cp2, u, v, auts, pcp);

      /* solve the appropriate equation, storing the image 
	 of generator under the action of alpha at result */
      solve_equation (cp1, cp2, result, pcp);

      /* now copy the result to auts */
      memcpy (auts[generator] + 1, y + result + 1, nmr_of_bytes);
   }

   /* reset value of submlg */
   pcp->submlg += (3 * lastg + 2);
}

/* given generator t of the p-multiplicator, whose definition is 
   u^p; hence, we have the equation
   
                      u^p = W * t

   where W is a word (possibly trivial) in the generators of the group;
   find the image of t under alpha by setting up (W)alpha at cp1, 
   ((u)alpha)^p at cp2, and then call solve_equation */

void extend_power (cp1, cp2, u, auts, pcp)
int cp1, cp2;
int u; 
int **auts;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int lastg = pcp->lastg;

   /* set up the image of u under alpha at cp2 and zero vector at cp1 */
   for (i = 1; i <= lastg; ++i) { 
      y[cp2 + i] = auts[u][i];
      y[cp1 + i] = 0;
   }

   /* raise the image of u under alpha to its pth power */
   power (pcp->p, cp2, pcp);

   /* set up image of W under alpha at cp1 */
   if (y[pcp->ppower + u] < 0)  
      collect_image_of_string (-y[pcp->ppower + u], cp1, auts, pcp);
}

/* given generator t of the p-multiplicator, whose definition is 
   [u, v]; hence, we have the equation  
    
   [u, v] = W * t, or equivalently, u * v = v * u * W * t 

   where W is a word (possibly trivial) in the generators of the group;
   find the image of t under alpha by setting up 
   (v)alpha * (u)alpha * (W)alpha at cp1, (u)alpha * (v)alpha at cp2 
   and then call solve_equation */

void extend_commutator (cp1, cp2, u, v, auts, pcp)
int cp1, cp2;
int u;
int v;
int **auts;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int pointer;

   /* set up image under alpha of u at cp2 and image of v at cp1 */
   memcpy (y + cp2 + 1, auts[u] + 1, nmr_of_bytes);
   memcpy (y + cp1 + 1, auts[v] + 1, nmr_of_bytes);

   /* collect image of v under alpha at cp2 */
   collect_image_of_generator (cp2, auts[v], pcp);

   /* collect image of u under alpha at cp1 */
   collect_image_of_generator (cp1, auts[u], pcp);

   /* collect image of W under alpha at cp1 */
   pointer = y[pcp->ppcomm + u];
   if (y[pointer + v] < 0)
      collect_image_of_string (-y[pointer + v], cp1, auts, pcp);
}

/* collect the image of a generator under the action of 
   an automorphism and store the result at cp */

void collect_image_of_generator (cp, auts, pcp)
int cp;
int *auts;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lused = pcp->lused;
   register int lastg = pcp->lastg;
   register int length = 0;
   register int i;
   int exp;

#include "access.h"

   for (i = 1; i <= lastg; ++i) { 
      if ((exp = auts[i]) != 0) 
	 y[lused + 1 + (++length)] = PACK2 (exp, i);
   }

   y[lused + 1] = length;
   collect (-lused, cp, pcp);
}

/* collect image of supplied string under the action of 
   supplied automorphism, auts, and store the result at cp */

void collect_image_of_string (string, cp, auts, pcp)
int string;
int cp;
int **auts;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   int generator, exp;
   int length = y[string + 1] - 1; /* last element of string 
				      is in p-multiplicator */
#include "access.h"

   /* collect the string generator by generator */
   for (i = 1; i <= length; ++i) {
      generator = FIELD2 (y[string + 1 + i]);
      exp = FIELD1 (y[string + 1 + i]);
      while (exp > 0) {
	 collect_image_of_generator (cp, auts[generator], pcp);
	 --exp;
      }
   } 
}
