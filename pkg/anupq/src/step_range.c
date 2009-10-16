/****************************************************************************
**
*A  step_range.c                ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: step_range.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"

/* find the range of permitted step sizes */

void step_range (k, lower_step, upper_step, auts, pga, pcp)
int k;
int *lower_step;
int *upper_step;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   /* the k-initial segment subgroup must include those 
      generators previously fixed */
   k = MAX(k, pga->fixed);

   /* find the rank of the characteristic closure of 
      k-initial segment subgroup of the p-multiplicator */
   pga->q = close_subgroup (k, auts, pga, pcp);

   /* what is the rank of the relative nucleus? */
   pga->r = MIN(pga->q, pga->nuclear_rank);

   /* is the rank of the subgroup < nuclear rank? */
   if (pga->q < pga->nuclear_rank)
      *lower_step = MAX(pga->fixed, 
			pga->step_size + pga->q - pga->nuclear_rank);
   else
      *lower_step = pga->step_size;

   *upper_step = MIN(pga->step_size, pga->q);
}
