/****************************************************************************
**
*A  list_commutators.c          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: list_commutators.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* evaluate the Engel (p - 1)-identity 

          [a, (p - 1) b] = 1

   where each of a and b range over all of the generators of 
   supplied weights; echelonise the results and add to the 
   queue for possible closure under action of automorphisms  */

void list_commutators (queue, queue_length, pcp)
int *queue;
int *queue_length;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lastg = pcp->lastg;
   register int cp, cp1, cp2, cp3, cp4, result; 
   register int first, last;
   register int total;
   register int depth;
   register int i, gen;
   int weight, second_weight;
   register int start, end, second;
   register int p = pcp->p;
 
   total = 6 * lastg + 6;

   cp1 = pcp->submlg - lastg - 2;
   cp2 = cp1 - lastg;
   cp3 = cp2 - lastg;
   cp4 = cp3 - lastg;
   result = cp4 - lastg; 

   /* fudge the value of submlg because of possible call to power */
   pcp->submlg -= total;

   read_value (TRUE, "Input weight of first component of commutator: ", 
	       &weight, 1);
 
   first = y[pcp->clend + weight - 1] + 1;
   last = y[pcp->clend + weight];

   read_value (TRUE, "Input weight of other components of commutator: ", 
	       &second_weight, 1);

   start = y[pcp->clend + second_weight - 1] + 1;
   end = y[pcp->clend + second_weight];

   for (gen = first; gen <= last; ++gen) {
      for (second = start; second <= end; ++second) {

	 if (is_space_exhausted (total, pcp))
	    return;

	 /* set up first component at cp2 and cp3 */
	 for (i = 1; i <= lastg; ++i)
	    y[cp2 + i] = y[cp3 + i] = 0;
	 y[cp2 + gen] = y[cp3 + gen] = 1;

	 depth = p;

	 while (--depth > 0) {

	    /* set up next component, b, at cp1 and cp4 -- b has value second */
	    for (i = 1; i <= lastg; ++i)
	       y[cp1 + i] = y[cp4 + i] = 0;
	    y[cp1 + second] = y[cp4 + second] = 1;

	    /* solve the equation (ba) * x = ab to obtain [a, b] */
	    find_commutator (cp1, cp2, cp3, cp4, result, pcp);

	    /* replace value of a by x */
	    copy (result, lastg, cp2, pcp);
	    copy (result, lastg, cp3, pcp);
	 }

	 cp = pcp->lused;

	 /* print the commutator */
	 if (pcp->diagn) 
	    setup_word_to_print ("commutator", result, cp, pcp);

	 /* now echelonise the result */
	 copy (result, lastg, cp, pcp);
	 setup_echelon (queue, queue_length, cp, pcp);

	 if (pcp->redgen != 0 && pcp->diagn) 
	    printf ("The commutator evaluated is [%d, %d]\n", gen, second);

      }
   }

   /* reset the value of submlg */
   pcp->submlg += total;
}

#if defined (DEBUG)
#if defined (UNIX) 

void List_Comms123 (queue, queue_length, pcp)
int *queue;
int *queue_length;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lastg = pcp->lastg;
   register int total;
   int cp1 = pcp->submlg - lastg - 2;
   int cp2 = cp1 - lastg;
   int cp3 = cp2 - lastg;
   int cp4 = cp3 - lastg;
   int result = cp4 - lastg; 
   register int cp; 
   register int first, last;
   register int depth;
   register int i, gen;
   int weight, second_weight;
   register int start, end, second;
 
   read_value (TRUE, "Input weight of first component of commutator: ", 
	       &weight, 1);
 
   first = y[pcp->clend + weight - 1] + 1;
   last = y[pcp->clend + weight];

   read_value (TRUE, "Input weight of other components of commutator: ", 
	       &second_weight, 1);

   start = y[pcp->clend + second_weight - 1] + 1;
   end = y[pcp->clend + second_weight];

   total = 6 * lastg + 6;
   if (is_space_exhausted (total, pcp))
      return;

   /* fudge the value of submlg because of possible call to power */
   pcp->submlg -= total;

   for (gen = first; gen <= last; ++gen) {

      /* set up first component at cp2 and cp3 */
      for (i = 1; i <= lastg; ++i)
	 y[cp2 + i] = y[cp3 + i] = 0;
      y[cp2 + gen] = y[cp3 + gen] = 1;

      depth = 5;

      while (--depth > 0) {

	 /* set up next component, b, at cp1 and cp4 -- b has value second */
	 for (i = 1; i <= lastg; ++i)
	    y[cp1 + i] = y[cp4 + i] = 0;
	 /*
	   y[cp1 + 1] = y[cp4 + 1] = 1;
	   y[cp1 + 2] = y[cp4 + 2] = 1;
	   y[cp1 + 3] = y[cp4 + 3] = 1;
	   */
	 y[cp1 + 4] = y[cp4 + 4] = 1;
	 y[cp1 + 5] = y[cp4 + 5] = 1;
	 y[cp1 + 6] = y[cp4 + 6] = 1;

	 /* solve the equation (ba) * x = ab to obtain [a, b] */
	 find_commutator (cp1, cp2, cp3, cp4, result, pcp);

	 /* replace value of a by x */
	 copy (result, lastg, cp2, pcp);
	 copy (result, lastg, cp3, pcp);
      }

      /* now echelonise the result */
      cp = pcp->lused;
      copy (result, lastg, cp, pcp);
      for (i = 1; i <= lastg; ++i)
	 y[cp + lastg + i] = 0;
      echelon (pcp);
      if (pcp->redgen != 0) {
	 printf ("first gen is %d\n", gen);
	 queue[++*queue_length] = pcp->redgen;
      }

      /* print the commutator */
      cp = pcp->lused;
      setup_word_to_print ("commutator", result, cp, pcp);
   }

   /* reset the value of submlg */
   pcp->submlg += total;
}

void List_Comms13 (queue, queue_length, pcp)
int *queue;
int *queue_length;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lastg = pcp->lastg;
   register int total;
   int cp1 = pcp->submlg - lastg - 2;
   int cp2 = cp1 - lastg;
   int cp3 = cp2 - lastg;
   int cp4 = cp3 - lastg;
   int result = cp4 - lastg; 
   register int cp; 
   register int first, last;
   register int depth;
   register int i, gen;
   int weight, second_weight;
   register int start, end, second;
 
   read_value (TRUE, "Input weight of first component of commutator: ", 
	       &weight, 1);
 
   first = y[pcp->clend + weight - 1] + 1;
   last = y[pcp->clend + weight];

   read_value (TRUE, "Input weight of other components of commutator: ", 
	       &second_weight, 1);

   start = y[pcp->clend + second_weight - 1] + 1;
   end = y[pcp->clend + second_weight];

   total = 6 * lastg + 6;
   if (is_space_exhausted (total, pcp))
      return;

   /* fudge the value of submlg because of possible call to power */
   pcp->submlg -= total;

   for (gen = first; gen <= last; ++gen) {


      /* set up first component at cp2 and cp3 */
      for (i = 1; i <= lastg; ++i)
	 y[cp2 + i] = y[cp3 + i] = 0;
      y[cp2 + gen] = y[cp3 + gen] = 1;

      depth = 5;

      while (--depth > 0) {

	 /* set up next component, b, at cp1 and cp4 -- b has value second */
	 for (i = 1; i <= lastg; ++i)
	    y[cp1 + i] = y[cp4 + i] = 0;
	 y[cp1 + 1] = y[cp4 + 1] = 1;
	 y[cp1 + 3] = y[cp4 + 3] = 1;

	 /* solve the equation (ba) * x = ab to obtain [a, b] */
	 find_commutator (cp1, cp2, cp3, cp4, result, pcp);

	 /* replace value of a by x */
	 copy (result, lastg, cp2, pcp);
	 copy (result, lastg, cp3, pcp);
      }

      /* now echelonise the result */
      cp = pcp->lused;
      copy (result, lastg, cp, pcp);
      for (i = 1; i <= lastg; ++i)
	 y[cp + lastg + i] = 0;
      echelon (pcp);
      if (pcp->redgen != 0) {
	 printf ("first gen is %d\n", gen);
	 queue[++*queue_length] = pcp->redgen;
      }

      /* print the commutator */
      cp = pcp->lused;
      setup_word_to_print ("commutator", result, cp, pcp);

   }

   /* reset the value of submlg */
   pcp->submlg += total;
}

void List_Comms23 (queue, queue_length, pcp)
int *queue;
int *queue_length;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lastg = pcp->lastg;
   register int total;
   int cp1 = pcp->submlg - lastg - 2;
   int cp2 = cp1 - lastg;
   int cp3 = cp2 - lastg;
   int cp4 = cp3 - lastg;
   int result = cp4 - lastg; 
   register int cp; 
   register int first, last;
   register int depth;
   register int i, gen;
   int weight, second_weight;
   register int start, end, second;
 
   read_value (TRUE, "Input weight of first component of commutator: ", 
	       &weight, 1);
 
   first = y[pcp->clend + weight - 1] + 1;
   last = y[pcp->clend + weight];

   read_value (TRUE, "Input weight of other components of commutator: ", 
	       &second_weight, 1);

   start = y[pcp->clend + second_weight - 1] + 1;
   end = y[pcp->clend + second_weight];

   total = 6 * lastg + 6;
   if (is_space_exhausted (total, pcp))
      return;

   /* fudge the value of submlg because of possible call to power */
   pcp->submlg -= total;

   for (gen = first; gen <= last; ++gen) {


      /* set up first component at cp2 and cp3 */
      for (i = 1; i <= lastg; ++i)
	 y[cp2 + i] = y[cp3 + i] = 0;
      y[cp2 + gen] = y[cp3 + gen] = 1;

      depth = 5;

      while (--depth > 0) {

	 /* set up next component, b, at cp1 and cp4 -- b has value second */
	 for (i = 1; i <= lastg; ++i)
	    y[cp1 + i] = y[cp4 + i] = 0;
	 y[cp1 + 2] = y[cp4 + 2] = 1;
	 y[cp1 + 3] = y[cp4 + 3] = 1;

	 /* solve the equation (ba) * x = ab to obtain [a, b] */
	 find_commutator (cp1, cp2, cp3, cp4, result, pcp);

	 /* replace value of a by x */
	 copy (result, lastg, cp2, pcp);
	 copy (result, lastg, cp3, pcp);
      }

      /* now echelonise the result */
      cp = pcp->lused;
      copy (result, lastg, cp, pcp);
      for (i = 1; i <= lastg; ++i)
	 y[cp + lastg + i] = 0;
      echelon (pcp);
      if (pcp->redgen != 0) {
	 printf ("first gen is %d\n", gen);
	 queue[++*queue_length] = pcp->redgen;
      }

      /* print the commutator */
      cp = pcp->lused;
      setup_word_to_print ("commutator", result, cp, pcp);

   }

   /* reset the value of submlg */
   pcp->submlg += total;
}

/* set up list of commutators of the form [a, 1, 1, 1, 1] 
   where a ranges over a supplied weight, to close under 
   action of automorphisms */

void List_Commutators (queue, queue_length, pcp)
int *queue;
int *queue_length;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lastg = pcp->lastg;
   register int total;
   int cp1 = pcp->submlg - lastg - 2;
   int cp2 = cp1 - lastg;
   int cp3 = cp2 - lastg;
   int cp4 = cp3 - lastg;
   int result = cp4 - lastg; 
   register int cp; 
   register int first, last;
   register int depth;
   register int i, gen;
   int weight;
 
   read_value (TRUE, "Input weight of first component of commutator: ", 
	       &weight, 1);
 
   first = y[pcp->clend + weight - 1] + 1;
   last = y[pcp->clend + weight];

   total = 6 * lastg + 6;
   if (is_space_exhausted (total, pcp))
      return;

   /* fudge the value of submlg because of possible call to power */
   pcp->submlg -= total;

   for (gen = first; gen <= last; ++gen) {

      /* set up first component at cp2 and cp3 */
      for (i = 1; i <= lastg; ++i)
	 y[cp2 + i] = y[cp3 + i] = 0;
      y[cp2 + gen] = y[cp3 + gen] = 1;

      depth = 5;

      while (--depth > 0) {

	 /* set up next component, b, at cp1 and cp4 -- b is 1 in all cases */
	 for (i = 1; i <= lastg; ++i)
	    y[cp1 + i] = y[cp4 + i] = 0;
	 y[cp1 + 1] = y[cp4 + 1] = 1;

	 /* solve the equation (ba) * x = ab to obtain [a, b] */
	 find_commutator (cp1, cp2, cp3, cp4, result, pcp);

	 /* replace value of a by x */
	 copy (result, lastg, cp2, pcp);
	 copy (result, lastg, cp3, pcp);
      }

      /* now echelonise the result */
      cp = pcp->lused;
      copy (result, lastg, cp, pcp);
      for (i = 1; i <= lastg; ++i)
	 y[cp + lastg + i] = 0;
      echelon (pcp);
      if (pcp->redgen != 0)
	 queue[++*queue_length] = pcp->redgen;

      /* print the commutator */
      /*
	cp = pcp->lused;
	setup_word_to_print ("commutator", result, cp, pcp);
	*/
   }

   /* reset the value of submlg */
   pcp->submlg += total;
}

#endif
#endif

