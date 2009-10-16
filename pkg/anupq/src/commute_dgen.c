/****************************************************************************
**
*A  commute_dgen.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: commute_dgen.c,v 1.3 2001/06/15 14:31:51 werner Exp $
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

/* calculate a power of a left-normed commutator of supplied depth 
   by repeated calls to find_commutator; set up the result as an 
   exponent vector with base address pcp->lused in order to permit 
   the result to be handed to echelon easily; each component
   is a defining generator */

void commute_defining_generators (format, pcp)
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

   collect_defining_generator_word (ptr, cp2, pcp);
   copy (cp2, lastg, cp3, pcp);

   type = NEXT_ENTRY;
   disp = y[ptr] + 1;

   while (--depth > 0) {

      /* read in next component, b, and set it up at cp1 and cp4 */
      if (format == BASIC)
	 read_word (stdin, disp, type, pcp);
      else 
	 pretty_read_word (stdin, disp, type, pcp);

      collect_defining_generator_word (ptr + disp, cp1, pcp);
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

/* collect word in defining generators stored as string at 
   y[ptr] and place the result as exponent vector at cp */

int collect_defining_generator_word (ptr, cp, pcp) 
int ptr;
int cp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int i, generator, genval;
   int j, word_len;
   int length, exp;
   register int lastg = pcp->lastg;

   /* zero out lastg entries in array in order to store result */
   for (i = 1; i <= lastg; ++i)  
      y[cp + i] = 0;
   
   length = y[ptr];
   for (i = 1; i < length; ++i) {
      generator = y[ptr + 1 + i];
      genval = y[pcp->dgen + generator];

#if defined (DEBUG)
      if (genval > 0) 
	 printf ("%d %d\n", generator, genval);
      else if (genval < 0) {
	 printf ("%d %d ", generator, y[-genval]);
	 word_len = y[-genval + 1];
	 for (j = 1; j <= word_len; ++j) 
	    printf (" %d", y[-genval + 1 + j]);
      };
      if (genval == 0)
	 printf ("No defining generator %d -- taken to be the identity\n", 
		 generator);
#endif 

      collect (genval, cp, pcp);
   }

   /* calculate power of this word */
   exp = y[ptr + 1];
   power (exp, cp, pcp);

#if defined (DEBUG)
   print_array (y, cp, cp + pcp->lastg + 1);
#endif 
}

/* prepare to collect word in defining generators */

void setup_defgen_word_to_collect (file, format, type, cp, pcp)
FILE_TYPE file;
int format;
int type;
int cp;
struct pcp_vars *pcp;
{
   int disp = pcp->lastg + 2;
   register int ptr;

   ptr = pcp->lused + 1 + disp;

   if (format == BASIC)
      read_word (file, disp, type, pcp);
   else
      pretty_read_word (file, disp, type, pcp);

   collect_defining_generator_word (ptr, cp, pcp);

   if (type == ACTION || file != stdin) return;

   setup_word_to_print ("result of collection", cp, ptr, pcp);
}
