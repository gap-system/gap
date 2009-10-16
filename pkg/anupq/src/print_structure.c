/****************************************************************************
**
*A  print_structure.c           ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: print_structure.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"

/* print structure of generator with base address pointer */

void print_generator (generator, pointer, pcp)
int generator;
int pointer;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int address = -pointer + 1;
   register int length = y[address];
#include "access.h"

   printf ("%d = ", generator);
   for (i = 1; i <= length; ++i)
      printf ("%d^%d ", FIELD2 (y[address + i]), FIELD1 (y[address + i]));
   printf ("\n");
}

/* find the definition of generator of supplied weight 
   and set it up with address pointer */

int find_definition (generator, pointer, weight, pcp)
int generator;
int pointer;
int weight;
struct pcp_vars *pcp;
{  
#include "define_y.h"

   register int u, v;
   register int structure = pcp->structure;
#include "access.h"

   pointer += weight + 1;
   do {
      u = PART2 (y[structure + generator]);
      v = PART3 (y[structure + generator]);
      
      /* deal with case where generator is a defining generator */
      if (generator < v) v = generator;

      if (u == 0)  
	 y[--pointer] = v;
      else {
	 if (v == 0) {
	    /* definition is a power, u^p */
	    v = 2;
	    while (u > y[pcp->clend + 1]) {
	       ++v;
	       u = PART2 (y[structure + u]);
	    }
	    for (; v > 0; --v)
	       y[--pointer] = u;
	    return pointer;
	 }
	 else {
	    /* definition is a commutator [v, u] */
	    y[--pointer] = v;
	    generator = u;
	 }
      }
   } while (u != 0);

   return pointer;
}

/* what layer of the lower exponent-p central series is generator in? */

int layer (generator, pcp) 
int generator;
struct pcp_vars *pcp;
{
#include "define_y.h"
   
   int i;

   for (i = 1; i <= pcp->cc && y[pcp->clend + i] != 0 &&
	   generator > y[pcp->clend + i]; ++i)
      ;

   return MIN (i, pcp->cc);
}

/* print the structure of each of the pcp generators, 
   numbered from first to last inclusive */

void print_structure (first, last, pcp)
int first, last;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int structure = pcp->structure;
   register int u, v;
   register int gen, i;
   register int previous = 0;
   register int current;
   int value;
   int weight;
   int pointer;
#include "access.h"

   for (gen = first; gen <= last; ++gen) {
      pointer = y[structure + gen];
      weight = WT(pointer);

      if ((current = layer (gen, pcp)) != previous) {
	 printf ("Class %d\n", current);
	 previous = current;
      }

      if (pointer <= 0) {
	 printf ("%d = ", gen);
	 print_word (pointer, pcp);
      }
      else {
	 u = PART2 (pointer);
	 v = PART3 (pointer);
	 if (u == 0)  
	    printf ("%d is defined on image of defining generator %d\n", gen, v);
	 else {
	    for (i = 1; i <= weight; ++i)
	       y[pcp->lused + i] = 0;

	    find_definition (gen, pcp->lused, weight, pcp);
	    if (v == 0)  
	       printf ("%d is defined on %d^%d = ", gen, u, pcp->p);
	    else   
	       printf ("%d is defined on [%d, %d] = ", gen, u, v);

	    for (i = 1; i <= weight; ++i)  
	       if ((value = y[pcp->lused + i]) != 0)
		  printf ("%d ", value);
	    printf ("\n");
	 }
      }
   }
}
