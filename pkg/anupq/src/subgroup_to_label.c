/****************************************************************************
**
*A  subgroup_to_label.c         ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: subgroup_to_label.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"

/* compute the label for the allowable subgroup having standard matrix S */

int subgroup_to_label (S, K, subset, pga)
int **S;
int K;        /* bit string representation of definition set */
int *subset;  /* definition set */
struct pga_vars *pga;
{
   register int i, j;
   register int exp = 0;
   register int label = 1;
   register int index = 0;

   /* first determine the offset */
   while (index < pga->nmr_def_sets && pga->list[index] != K)  
      ++index;
   label += pga->offset[index];

   for (i = 0; i < pga->s; ++i)
      for (j = subset[i] + 1; j < pga->q; ++j) {
	 if  (1 << j & K) continue;
	 if (S[i][j] != 0)
	    label += S[i][j] * pga->powers[exp];
	 ++exp;
      }

   return label;
}
