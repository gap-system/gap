/****************************************************************************
**
*A  close_subgroup.c            ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: close_subgroup.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"

/* return the rank, t, of the smallest characteristic, 
   k-initial segment subgroup in the p-multiplicator */

int close_subgroup (k, auts, pga, pcp)
int k;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int alpha, i, j;

   int t = MIN(k + 1, pga->multiplicator_rank); /* least possible rank value */
   int n = y[pcp->clend + pcp->cc - 1]; /* number of pcp generators of group */

   Logical complete = (t == pga->multiplicator_rank);

   int start = t; 

   for (alpha = 1; alpha <= pga->m && !complete; ++alpha) {
      i = n;
      while (i < n + t && !complete) {
	 ++i;
	 j = y[pcp->clend + pcp->cc];
	 /* find the last non-zero entry in the image of generator i */
	 while (auts[alpha][i][j] == 0 && j > n + t)
	    --j;
	 t = j - n;
	 complete = (t == pga->multiplicator_rank);
      }
   }

   /* if rank of closure has increased, must now close new subgroup */
   if (t != start)
      t = close_subgroup (t - 1, auts, pga, pcp);

   return t;
}
