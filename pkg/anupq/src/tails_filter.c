/****************************************************************************
**
*A  tails_filter.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: tails_filter.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (TAILS_FILTER) && defined (GROUP) 
#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"

/* look up the definitions of two pcp generator */

int lookup_structure (generator, weight_vector, pcp)
int generator;
int *weight_vector;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int structure = pcp->structure;
   int pointer = pcp->lused + 1;
   int weight;
   int index;
   int i;

#include "access.h"

   weight = WT (y[structure + generator]);
   for (i = 1; i <= weight; ++i)
      y[pointer + i] = 0;

   find_definition (generator, pointer, weight, pcp);

   for (i = 1; i <= weight; ++i) {
      index = y[pointer + i];
      ++weight_vector[index]; 
   }
}

/* add vec1 to vec2 component wise and return sum */

int *add_weights (vec1, vec2, length)
int *vec1;
int *vec2;
{
   int i;
   int *sum;

   sum = allocate_vector (length, 1, TRUE);
   for (i = 1; i <= length; ++i)
      sum[i] = vec1[i] + vec2[i];
   
   return sum; 
}

/* where maximal occurrence for each generator is set to 1,
   does any generator occur in definition with weight at least 2?
   if so, we do not need to compute tail */

Logical mo_filter (weight_vector, pcp)
int *weight_vector;
struct pcp_vars *pcp;
{
#include "define_y.h"

   Logical filter; 
   int frattini_rank = y[pcp->clend + 1]; 
   int moccur = pcp->ndgen + pcp->dgen;

   int i;

#ifdef DEBUG 
   printf ("Definition array total is ");
   print_array (weight_vector, 1, y[pcp->clend + 1] + 1);
#endif

   /* is maximal occurrences option set to one for each generator? */
   for (i = moccur + 1; i <= moccur + frattini_rank; ++i)
      if (y[i] != 1) return FALSE;

   filter = FALSE;
   /* does any defining generator occur at least 2 times? */
   for (i = 1; i <= frattini_rank && !filter; ++i)
      filter = (weight_vector[i] >= 2);

   return filter;
}

Logical exp4_filter (left, right, weight_vector, pcp)
int left;
int right;
int *weight_vector;
struct pcp_vars *pcp;
{
#include "define_y.h"

   Logical filter; 
   int frattini_rank = y[pcp->clend + 1]; 
   int structure = pcp->structure;
   int i;

#include "access.h"

#ifdef DEBUG 
   printf ("Definition array total is ");
   print_array (weight_vector, 1, y[pcp->clend + 1] + 1);
#endif

   filter = (WT (y[structure + left]) + WT (y[structure + right]) != 5);
   if (filter == FALSE) return FALSE;

   filter = FALSE;
   /* does any defining generator occur at least 4 times? */
   for (i = 1; i <= frattini_rank && !filter; ++i)
      filter = (weight_vector[i] >= 4);

   return filter;
}

Logical exp5_filter (weight_vector, pcp)
int *weight_vector;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int frattini_rank = y[pcp->clend + 1]; 
   Logical filter; 
   int i;

#ifdef DEBUG
   printf ("Definition array total is ");
   print_array (weight_vector, 1, y[pcp->clend + 1] + 1);
#endif

   filter = FALSE;
   /* does any defining generator occur at least 7 times? */
   for (i = 1; i <= frattini_rank && !filter; ++i)
      filter = (weight_vector[i] >= 7);

   return filter;
}

/* calculate pth powers of class final_class generators which
   are commutators by doing the appropriate collections */

void calculate_tails (final_class, start_weight, end_weight, pcp)
int final_class;
int start_weight;
int end_weight;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int structure = pcp->structure;
   register int class_end = pcp->clend;

   register int f;
   register int start = y[class_end + final_class - 1] + 1;
   register int end   = y[class_end + final_class];

   register int s, s1, s2;
   register int start_class = 1;

   register int a, b;
   register int value;
   register int p1;
   int **definition;

   int exponent = pcp->extra_relations;
   Logical filter = (pcp->nocset || exponent == 4 || exponent == 5); 
   Logical compute;
   int *weight_vector;
   int frattini_rank = y[pcp->clend + 1];
   int processed, filtered;

#include "access.h"

   if (filter) 
      definition = allocate_matrix (pcp->lastg, frattini_rank + 1, 0, TRUE);

   if (filter || pcp->fullop || pcp->diagn)  
      printf ("Processing tails for generators of weight %d and %d\n", 
	      final_class, 1);

   for (f = start; f <= end; f++) {
#ifdef DEBUG
      printf ("Processing generator f = %d, Lused = %d\n", f, pcp->lused);
#endif
      value = y[structure + f];
      a = PART3 (value);
      if (a == 0)
	 break;
      b = PART2 (value);
      
      /* f is the commutator (b, a);
	 calculate the class current_class part of f^p by collecting 
	 (b^p) a = b^(p-1) (ba); by formal collection, we see that 
	 the class current_class part of f^p is obtained by subtracting 
	 (modulo p) the rhs of the above equation from the lhs */

      jacobi (b, b, a, pcp->ppower + f, pcp);
      if (pcp->overflow)
	 return;
   }


   /* calculate the non left-normed commutators of class work_class 
      in the order (work_class - 2, 2), (work_class - 3, 3) .. */

   class_end = pcp->clend;
   while (--final_class >= ++start_class) {

      processed = 0; filtered = 0;

      if (filter || pcp->fullop || pcp->diagn)  
	 printf ("Processing tails for generators of weight %d and %d\n", 
		 final_class, start_class);

      start = y[class_end + final_class - 1] + 1;
      end = y[class_end + final_class];
      s1 = y[class_end + start_class - 1] + 1;

      for (f = start; f <= end; f++) {
#ifdef DEBUG
	 printf ("Processing generator f = %d, Lused = %d\n", f, pcp->lused);
#endif

	 if (filter) {
	    if (definition[f][0] == FALSE) {
	       lookup_structure (f, definition[f], pcp);
	       definition[f][0] = TRUE;
	    }
	 }

	 s2 = MIN(f - 1, y[class_end + start_class]);
	 if (s2 - s1 < 0)
	    continue;
	 p1 = y[pcp->ppcomm + f];
	 for (s = s1; s <= s2; s++) {
	    /* insert the class current_class part on (f, s) */
	    value = y[structure + s];
	    b = PART2 (value);
	    a = PART3 (value);
	    if (a == 0)  
	       a = b;
	    else if (pcp->metabelian && PART3 (y[structure + f]) != 0)
	       continue;
               
	    /* s = (b, a); calculate the class current_class part 
	       of (f, (b, a)) by collecting (fb) a = f (ba) or the 
	       class current_class part of (f, (b^p)) by collecting 
	       (fb) b^(p - 1) = f (b^p);
	       since we require only the class current_class part - 
	       the rest has been computed earlier -  we calculate it 
	       by subtracting (modulo p) the rhs of the above equation 
	       from the lhs (proof by formal collection) */
	    if (filter) {
	       if (definition[s][0] == FALSE) {
		  lookup_structure (s, definition[s], pcp);
		  definition[s][0] = TRUE;
	       }
	       weight_vector = add_weights (definition[f], definition[s], 
					    y[pcp->clend + 1]);
	       free_vector (weight_vector, 1);
	       if (pcp->nocset) 
		  compute = (mo_filter (weight_vector, pcp) == FALSE); 
	       else if (exponent == 4) 
		  compute = (exp4_filter (f, s, weight_vector, pcp) == FALSE); 
	       else if (exponent == 5) 
		  compute = (exp5_filter (weight_vector, pcp) == FALSE); 
	       else
		  compute = TRUE;

	       if (compute) {
		  jacobi (f, b, a, p1 + s, pcp);
		  ++processed; 
	       }
	       else 
		  ++filtered;
	    }
	    else 
	       jacobi (f, b, a, p1 + s, pcp);
	    if (pcp->overflow)
	       return;
	 }
      }
      if (filter) {
	 printf ("Number evaluated = %d, Number filtered = %d\n", 
		 processed, filtered);
      }
   }

   if (filter) free_matrix (definition, pcp->lastg, 0);
}

#endif
