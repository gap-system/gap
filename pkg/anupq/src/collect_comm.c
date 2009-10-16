/****************************************************************************
**
*A  collect_comm.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: collect_comm.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"
#include "pretty_filterfns.h"
#include "word_types.h"

/* collect a commutator relation in the defining generators of the group */

void collect_def_comm (ptr, cp, pcp)
int ptr;
int cp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int cp1, cp2, cp3, cp4, result;
   register int lastg = pcp->lastg;
   register int total;
   int disp = 0;
   int depth;
   int exp;

   cp1 = pcp->submlg - lastg - 2;
   cp2 = cp1 - lastg;
   cp3 = cp2 - lastg;
   cp4 = cp3 - lastg;
   result = cp4 - lastg;

   /* fudge the value of submlg because of possible call to power */
   total = 6 * lastg + 6;
   pcp->submlg -= total;

   depth = -y[ptr] - 1;
   exp = y[ptr + 1];

   collect_defining_generator (ptr + 2, cp2, pcp);
   copy (cp2, lastg, cp3, pcp);

   disp = 0;
   while (--depth > 0) {

      ++disp;
      collect_defining_generator (ptr + 2 + disp, cp1, pcp);
      copy (cp1, lastg, cp4, pcp);

      /* solve the equation (ba) * x = ab to obtain [a, b] */
      find_commutator (cp1, cp2, cp3, cp4, result, pcp);

      copy (result, lastg, cp2, pcp);
      copy (result, lastg, cp3, pcp);
   }

   power (exp, result, pcp);

#ifdef DEBUG
   /* print the commutator */
   setup_word_to_print ("commutator", result, pcp->lused, pcp);
#endif

   /* copy result to cp */
   copy (result, lastg, cp, pcp);

   /* reset the value of submlg */
   pcp->submlg += total;
}

/* collect value of defining generator stored at y[ptr] to 
   storage location cp */

void collect_defining_generator (ptr, cp, pcp) 
int ptr;
int cp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lastg = pcp->lastg;
   int i, generator, genval;

#ifdef DEBUG
   int j, word_len; 
#endif

   /* zero out lastg entries in array in order to store result */
   for (i = 1; i <= lastg; ++i)  
      y[cp + i] = 0;
   
   generator = y[ptr];
   genval = y[pcp->dgen + generator];

   /* check for illegal defining generators */
   if (abs (generator) > pcp->ndgen || generator == 0)
      report_error (0, generator, 0);

#ifdef DEBUG
   if (genval > 0) 
      printf ("%d %d\n", generator, genval);
   else if (genval < 0) {
      printf ("%d %d ", generator, y[-genval]);
      word_len = y[-genval + 1];
      for (j = 1; j <= word_len; ++j) 
	 printf (" %d", y[-genval + 1 + j]);
   }
   else 
      printf ("generator %d is trivial\n", generator);
#endif

   collect (genval, cp, pcp);

#ifdef DEBUG
   print_array (y, cp, cp + pcp->lastg + 1);
#endif
}
