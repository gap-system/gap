/****************************************************************************
**
*A  meataxe.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: meataxe.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* read result of meataxe calculation -- we obtain additional
   relations in generators of highest weight; these relations 
   are echelonised against the presentation; an elimination
   is then performed 

   the meataxe file contains nmr_rels relations; each relation 
   is stored as a sequence of nmr_exponents exponents where 
   nmr_exponents is the number of generators of last class */

void meataxe_result (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   int field_width, prime, nmr_rels, nmr_exponents;
   int limit = y[pcp->clend + pcp->cc - 1];
   register int lastg = pcp->lastg;
   register int i, k;

   scanf ("%d %d %d %d", &field_width, &prime, &nmr_rels, &nmr_exponents);

   for (i = 1; i <= nmr_rels; ++i) {
      for (k = 1; k <= limit; ++k)
	 y[pcp->lused + k] = 0; 
      if (prime < 10) {
	 for (k = limit + 1; k <= lastg; ++k)
	    scanf ("%1d", &y[pcp->lused + k]);
      }
      else {
	 for (k = limit + 1; k <= lastg; ++k)
	    scanf ("%d", &y[pcp->lused + k]);
      }

      for (k = 1; k <= lastg; ++k)
	 y[pcp->lused + lastg + k] = 0; 
      echelon (pcp);
   }

   if (pcp->cc != 1)
      eliminate (FALSE, pcp);
   else
      class1_eliminate (pcp);
}
