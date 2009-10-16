/****************************************************************************
**
*A  generator_definition.c      ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: generator_definition.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* find the structure of a pcp generator, gen, recursively from struct,
   storing the result in y[pcp->lused + k] to y[pcp->lused + pcp->cc];
   room is needed to store a string of length pcp->cc */

void generator_definition (gen, k, pcp)
int gen;
int *k;
struct pcp_vars *pcp; 
{
#include "define_y.h"

   register int i, j;
#include "access.h"

   if (is_space_exhausted (pcp->cc, pcp))
      return;

   *k = pcp->cc + 1;

   do {
      i = PART2 (y[pcp->structure + gen]);
      j = PART3 (y[pcp->structure + gen]);

      if (j != 0) {
	 --(*k);
	 y[pcp->lused + *k] = j;
	 gen = i;
      }
      else {
	 /* we have a power entry -- work out its structure recursively; 
	    the structure (d^p)^j, where d is a defining generator, has 
	    weight j + 1 and thus its structure is j + 1 copies of d */
	 j = 2;
	 while (i > pcp->ndgen) {
	    i = PART2 (y[pcp->structure + i]);
	    ++j;
	 }
	 for (; j > 0; --j, --(*k)) 
	    y[pcp->lused + *k] = i;
      }
   } while (i != 0); 
}
