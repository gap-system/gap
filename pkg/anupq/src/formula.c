/****************************************************************************
**
*A  formula.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: formula.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"
#include "pq_functions.h"

int *list;
int *first;
int *last;
int power_of_entry;
int exponent;

/* echelonise the relation and add any redundant generator to the queue */

void setup_echelon (queue, queue_length, cp, pcp)
int *queue;
int *queue_length;
int cp;
struct pcp_vars *pcp;
{ 
#include "define_y.h"

   register int lastg = pcp->lastg;
   int i;

   /* now echelonise the result */
   for (i = 1; i <= lastg; ++i)
      y[cp + lastg + i] = 0;
   echelon (pcp);
   if (pcp->redgen != 0 && pcp->m != 0)
      queue[++*queue_length] = pcp->redgen;
}

/* evaluate the word whose variables are stored in the list */

void evaluate_list (queue, queue_length, list, depth, pcp)
int *queue;
int *queue_length;
int *list;
int depth;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lastg = pcp->lastg;
   register int cp = pcp->lused;
   register int cp1 = cp + lastg;
   register int cp2 = cp1 + lastg;
   register int i, a;

   for (i = 1; i <= lastg; ++i)
      y[cp + i] = 0;

   while (depth > 0) {
      a = list[depth];
      for (i = 1; i <= lastg; ++i)
	 y[cp1 + i] = 0;
      y[cp1 + a] = 1;
      /* compute a^power_of_entry */
      power (power_of_entry, cp1, pcp);
      vector_to_string (cp1, cp2, pcp);
      if (y[cp2 + 1] != 0)
	 collect (-cp2, cp, pcp);
      --depth;
   }

#ifdef DEBUG
   print_array (y, cp + 1, cp + lastg + 1);
   printf ("The result is ");
   print_array (y, cp + 1, cp + lastg + 1);
#endif

   /* now compute word^exponent */
   power (exponent, cp, pcp);
   setup_word_to_print ("result of collection", cp, cp + lastg + 1, pcp);

   /*
     if (pcp->m != 0)
     */
   setup_echelon (queue, queue_length, cp, pcp);
}

/* check that word is a normal word -- if not, discard */
   
Logical valid_word (list, depth)
int *list;
int depth;
{
   Logical normal_word = TRUE;

   while (depth > 1 && (normal_word = (list[depth] < list[depth - 1]))) 
      --depth;

   return normal_word;
}
   
/* build up a list whose entries are the letters of the word to be evaluated */

void loop (queue, queue_length, depth, list, nmr, begin, end, pcp)
int *queue;
int *queue_length;
int depth;
int *list;
int *nmr;
int begin, end;
struct pcp_vars *pcp;
{
   int i, k;
   char *s;
  
   for (i = begin; i <= end; ++i) {
      ++*nmr;
      list[*nmr] = i;
      if (*nmr == depth) {
	 if (valid_word (list, depth)) {
	    s = (depth == 1) ? " is" : "s are";
	    printf ("The component%s ", s);
	    /* one has a complete list of entries to generate a normal word */
	    for (k = *nmr; k >= 1; --k)
	       printf ("%d ", list[k]);
	    printf ("\n");
	    evaluate_list (queue, queue_length, list, depth, pcp);
	 }
	 --*nmr;
      }
      else {
	 loop (queue, queue_length, depth, list, nmr, 
	       first[depth - *nmr], last[depth - *nmr], pcp);
      }
   }
   --*nmr;
}

/* evaluate formulae of the form

       (x1^n * x2^n * ... * x<k>^n)^m

   where each of the x<i> run over all of the generators of a 
   supplied weight in the group; n and m are positive integers;
   echelonise the result and add any redundancies to the queue */ 

void evaluate_formula (queue, queue_length, pcp)
int *queue;
int *queue_length;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lastg = pcp->lastg;
   register int i;
   int nmr_entries;
   int *weight;
   int total;
   int nmr;

   total = 6 * lastg + 6;
   if (is_space_exhausted (total, pcp))
      return;

   /* fudge the value of submlg because of possible call to power */
   pcp->submlg -= total;

   read_value (TRUE, "Input number of components of formula: ",
	       &nmr_entries, 1);

   weight = allocate_vector (nmr_entries, 1, FALSE);
   first = allocate_vector (nmr_entries + 1, 0, FALSE);
   last = allocate_vector (nmr_entries + 1, 0, FALSE);
   list = allocate_vector (nmr_entries + 1, 0, FALSE);

   printf ("Input weight of each component of formula: ");
   for (i = 1; i < nmr_entries; ++i) {
      read_value (FALSE, "", &weight[i], 1);
   }
   read_value (TRUE, "", &weight[i], 1);

   read_value (TRUE, "Input power of individual component: ",
	       &power_of_entry, 1);
   
   read_value (TRUE, "Input power of word: ", &exponent, 1);
   
   for (i = 1; i <= nmr_entries; ++i) {
      first[i] = y[pcp->clend + weight[i] - 1] + 1;
      last[i] = y[pcp->clend + weight[i]];
   }
      
   /* generate the list of words; evaluate each, echelonise it 
      and build up the queue of redundant generators */
   nmr = 0;
   loop (queue, queue_length, nmr_entries, list, &nmr, 
	 first[nmr_entries], last[nmr_entries], pcp);

   /* reset value of submlg */
   pcp->submlg += total;
 
   free_vector (weight, 1);
   free_vector (first, 0);
   free_vector (last, 0);
   free_vector (list, 0);
}
