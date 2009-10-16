/****************************************************************************
**
*A  maxoccur.c                  ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: maxoccur.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"

#ifdef Magma
#include "eseq.e"
#endif

/* set maximal occurrences for pcp generators of weight one */

#ifdef Magma
void set_maxoccur (seq, pcp)
t_handle seq;
struct pcp_vars *pcp;
#else
void set_maxoccur (pcp)
struct pcp_vars *pcp;
#endif
{
#include "define_y.h"

   register int ndgen = pcp->ndgen;
   register int dgen = pcp->dgen;
   register int moccur = dgen + ndgen;
   register int nmr_of_generators = y[pcp->clend + 1];
   register int sum = 0;
   register int i;
   Logical zero = FALSE;
   Logical flag;
#ifdef Magma
   t_handle    s;
   t_int       e, it;

   for (i = 1; i <= nmr_of_generators; i++)
   {
      eseq_old_get(seq, i, &s, &e, &it);
      y[moccur + i] = e;
      sum += y[moccur + i];
      zero |= y[moccur + i] == 0;
   }

#else

   printf ("Input occurrence limits for each of the %d", nmr_of_generators);
   printf (" pcp generators of weight one: ");

   for (i = 1; i <= nmr_of_generators; i++) {
      flag = (i == nmr_of_generators) ? TRUE : FALSE;
      read_value (flag, "", &y[moccur + i], 0);
      sum += y[moccur + i];
      zero |= (y[moccur + i] == 0);
   }
#endif

   if (sum == 0)
      pcp->nocset = 0;
   else if (zero)
      pcp->nocset = 1;
   else
      pcp->nocset = sum;
}
