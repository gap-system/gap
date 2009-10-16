/****************************************************************************
**
*A  print_multiweight.c         ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: print_multiweight.c,v 1.6 2002/12/17 02:17:05 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"

/* print the structure of each of the pcp generators, 
   numbered from first to last inclusive */

void print_multiweight (first, last, pcp)
int first, last;
struct pcp_vars *pcp;
{
#include "define_y.h"

   char start;
   register int structure = pcp->structure;
   register int u, v;
   register int gen, i, k;
   register int previous = 0;
   register int current;
   int print_mwt;
   int print_pattern = TRUE;
   int counter = 0;
   int value;
   int wt = 0;
   int length;
   int weight;
   int pointer;
   int address;
   int *pattern;
   int *gens;

#include "access.h"
   
   printf ("Print number of occurrences of multiweights: ");
   scanf ("%d", &print_mwt);
   
   if (print_mwt) {
      printf ("Enter weight pattern on %d gens (0 for all): ", pcp->ndgen);
      scanf ("%c", &start);
      scanf ("%c", &start);
      if (start == '0') {
	 length = int_power (pcp->cc + 1, pcp->ndgen);
	 pattern = allocate_vector (length + pcp->ndgen + 1, 1, TRUE);

	 for (i = 1; i <= pcp->ndgen; ++i)
	    pattern[i] = int_power (pcp->cc + 1, i - 1);
      }
      else {
	 pattern = allocate_vector (pcp->ndgen + 1, 1, TRUE);
	 for (i = 1; i <= pcp->ndgen; ++i) {
	    scanf ("%d", &pattern[i]);
	    wt += pattern[i];
	 }      
	 scanf ("%c", &start);
      }
   }

   gens = allocate_vector (pcp->ndgen + 1, 1, TRUE);
  
   for (gen = first; gen <= last; ++gen) {
      pointer = y[structure + gen];
      weight = WT(pointer);
     
      if (((current = layer (gen, pcp)) != previous) && ((wt == 0) || (wt == current))) {
	 printf ("Class %d\n", current);
	 previous = current;
      }


      if (pointer <= 0 && !print_mwt) {
	 printf ("%d = ", gen);
	 print_word (pointer, pcp);
      }
      else {
	 u = PART2 (pointer);
	 v = PART3 (pointer);
       
	 if (u == 0) {
	    if (print_mwt) { 
	       if (start == '0')
		  for (i = 1; i <= pcp->ndgen; ++i)
		     gens[i] = 0;
	       gens[v] = 1;
	    }
	 }
	 else {
	    if (gen >= pcp->ccbeg) {
	       for (i = 1; i <= weight; ++i)
		  y[pcp->lused + i] = 0;
	    }
         
	    find_definition (gen, pcp->lused, weight, pcp);
         
	    for (i = 1; i <= pcp->ndgen; ++i)
	       gens[i] = 0;
         
	    for (i = 1; i <= weight; ++i)
	       ++gens[y[pcp->lused + i]];
	 }

	 if (print_mwt) {
	    if (start == '0') {
	       k = pcp->ndgen; 
	       for (i = 1; i <= pcp->ndgen; ++i)
		  k += gens[i]*pattern[i];
	       ++pattern[k];
	    }
	    else {
	       print_pattern = TRUE;
	       for (i = 1; i <= pcp->ndgen; ++i) {
		  if (gens[i] != pattern[i]) {
		     print_pattern = FALSE;
		     break;
		  }
	       }
	    }
	 }
       
	 if (print_pattern) {
	    if (u == 0)
	       printf ("%d is defined on image of defining generator %d\n", gen, v);
	    if (v == 0)  
	       printf ("%d is defined on %d^%d = ", gen, u, pcp->p);
	    else if (u != 0)   
	       printf ("%d is defined on [%d, %d] = ", gen, u, v);
           
	    if (gen > pcp->ndgen) {
	       for (i = 1; i <= weight; ++i)  
		  if ((value = y[pcp->lused + i]) != 0)
		     printf ("%d ", value);
	    }

	    if (print_mwt) {
	       printf ("\t");
	       printf ("(");
	       for (i = 1; i <= pcp->ndgen; ++i) {
		  printf ("%d", gens[i]);
		  if (i != pcp->ndgen)
		     printf (" ");
	       }
	       printf (")");
	       printf ("\n"); 
	       if (start != '0')
		  ++counter;
	    }
	    else
	       printf ("\n");
	 }
      }
   }  
   
   if (print_mwt) {
      if (start == '0')
	 for (k = 1; k <= weight; ++k) {
	    wt = 0;
	    address = pcp->ndgen;
	    for (i = 1; i <= pcp->ndgen; ++i)
	       gens[i] = 0;
	    while (gens[1] < k) {
	       ++gens[pcp->ndgen];
	       ++wt;
	       address += pattern[pcp->ndgen];
	       if (gens[pcp->ndgen] > k)
		  for (i = pcp->ndgen; i > 1; --i)
		     if (gens[i] > k) {
			gens[i] = 0;
			++gens[i - 1];
			address += pattern[i - 1]*(1 - (k + 1)*(pcp->cc + 1));
			wt -= k;
		     }
	       if (pattern[address] > 0 && wt == k) {
		  if (pattern[address]== 1)
		     printf ("1 occurrence of pattern (");
		  else
		     printf ("%d occurences of pattern (", pattern[address]);
		  for (i = 1; i < pcp->ndgen; ++i)
		     printf ("%d ", gens[i]);
		  printf ("%d)\n", gens[pcp->ndgen]);
	       }
	    }
	 }
      else {
	 if (counter > 0) {
	    if (counter == 1)    
	       printf ("1 occurrence of pattern (");
	    else
	       printf ("%d occurences of pattern (", counter);
	    for (i = 1; i < pcp->ndgen; ++i)
	       printf ("%d ", pattern[i]);
	    printf ("%d)\n", pattern[pcp->ndgen]);
	 }
      }

      free (++gens);
      free (++pattern);  
   }
}
