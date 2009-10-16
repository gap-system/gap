/****************************************************************************
**
*A  get_definition_sets.c       ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: get_definition_sets.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"
#include "pq_functions.h"

int *subset;       /* temporary storage for definition set */

/* a definition set is a subset of cardinality pga->s 
   of the relative nucleus, a set of cardinality pga->r;
   here, we find all subsets of cardinality pga->s which 
   contain the elements 0 .. pga->fixed - 1;
   set up all of the definition sets as a array, list */

void get_definition_sets (pga)
struct pga_vars *pga;
{
   register int i;
   register int bound;

   pga->nmr_def_sets = 0;
   subset = allocate_vector (pga->s, 0, 0);

   /* initialise each definition set to contain 0 .. pga->fixed - 1 */
   for (i = 0; i < pga->fixed; ++i)
      subset[i] = i;

   if (pga->fixed == pga->s)
      add_to_list (subset, pga);
   else {
      bound = MIN(pga->r - (pga->s - pga->fixed), pga->r);
      for (i = pga->fixed; i <= bound; ++i) 
	 visit (i, pga->s - pga->fixed - 1, pga);
   }

   free_vector (subset, 0);
}

/* store the definition set as a bit string; compute the number 
   of available positions determined by this definition set */

void add_to_list (subset, pga)
int *subset;
struct pga_vars *pga;
{
   register int i;
   int bit_string = 0;          /* to store subset */

   /* convert each subset to bit string */
   for (i = 0; i < pga->s; ++i)  
      bit_string |= 1 << subset[i];

   pga->list[pga->nmr_def_sets] = bit_string; 

   /* compute the number of available positions */
   pga->available[pga->nmr_def_sets] = available_positions (subset, pga);

   ++pga->nmr_def_sets;
}

/* visit node k; d remaining elements to be found to make up 
   subset of cardinality pga->s */ 

void visit (k, d, pga) 
int k;
int d;
struct pga_vars *pga;
{  
   register int i;

   subset[pga->s - d - 1] = k;

   if (d == 0)  
      add_to_list (subset, pga);

   for (i = k + 1; i < pga->r && d > 0; ++i)  
      visit (i, d - 1, pga);
}

/* find the number of available positions for definition set K */

int available_positions (K, pga) 
int *K;
struct pga_vars *pga;
{
   register int l;
   register int available = pga->q * pga->s - pga->s * (pga->s - 1) / 2;

   for (l = 0; l < pga->s; ++l)
      available -= (K[l] + 1);
   return available;
}
