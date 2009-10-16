/****************************************************************************
**
*A  store_definition_sets.c     ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: store_definition_sets.c,v 1.5 2005/06/21 17:02:53 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"
#include "pq_functions.h"

/* set up the maximum storage space required for the definition sets -- 
   this is the maximum of r choose s where lower_step <= s <= upper_step */

void store_definition_sets (r, lower_step, upper_step, pga) 
int r;
int lower_step;
int upper_step;
struct pga_vars *pga;
{
   int s, nmr_of_sets = 0;

   for (s = lower_step; s <= upper_step; ++s) 
      nmr_of_sets = MAX (nmr_of_sets, choose (r, s));

   pga->list = allocate_vector (nmr_of_sets, 0, FALSE);
   pga->available = allocate_vector (nmr_of_sets, 0, FALSE);
   pga->offset = allocate_vector (nmr_of_sets, 0, FALSE);
}

/* calculate r choose s */

int choose (r, s)
{
   register int i;
   int binom = 1;

   for (i = 1; i <= s; ++i) {
      /* after the ith pass of the loop binom == binom(r, i) */
      binom *= (r + 1 - i);
      binom /= i;
   }

   return binom;
}
