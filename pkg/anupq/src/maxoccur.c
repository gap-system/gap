/****************************************************************************
**
*A  maxoccur.c                  ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: maxoccur.c,v 1.5 2011/11/28 17:47:20 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"

/* set maximal occurrences for pcp generators of weight one */

void set_maxoccur (pcp)
struct pcp_vars *pcp;
{
   register int *y = y_address;

   register int ndgen = pcp->ndgen;
   register int dgen = pcp->dgen;
   register int moccur = dgen + ndgen;
   register int nmr_of_generators = y[pcp->clend + 1];
   register int sum = 0;
   register int i;
   Logical zero = FALSE;
   Logical flag;

   printf ("Input occurrence limits for each of the %d", nmr_of_generators);
   printf (" pcp generators of weight one: ");

   for (i = 1; i <= nmr_of_generators; i++) {
      flag = (i == nmr_of_generators) ? TRUE : FALSE;
      read_value (flag, "", &y[moccur + i], 0);
      sum += y[moccur + i];
      zero |= (y[moccur + i] == 0);
   }

   if (sum == 0)
      pcp->nocset = 0;
   else if (zero)
      pcp->nocset = 1;
   else
      pcp->nocset = sum;
}
