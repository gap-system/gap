/****************************************************************************
**
*A  class1_eliminate.c          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: class1_eliminate.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* eliminate all redundant generators to construct the consistent 
   power commutator presentation for the class 1 quotient;

   this procedure is called only for class 1 in order to 
   eliminate redundancies brought about by collecting and 
   then echelonising words against an existing consistent 
   class 1 presentation;

   in all other circumstances, the usual eliminate procedure 
   is called */

void class1_eliminate (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int j;
   register int k;
   register int p1;
   register int ba;
   register int lg;
   register int bound;

   register int structure = pcp->structure;
   register int current_class = pcp->cc;
   register int lused = pcp->lused;
   register int dgen = pcp->dgen;
   register int ndgen = pcp->ndgen;

   /* calculate new values for irredundant generators and set them up 
      in a renumbering table of length pcp->lastg - pcp->ccbeg + 1 
      which looks to compact like a normal exponent-generator string 
      pointed to by y[dgen] */

   structure = pcp->structure;
   lused = pcp->lused;
   y[lused + 1] = dgen;
   y[dgen] = -(lused + 1);
   y[lused + 2] = pcp->lastg - pcp->ccbeg + 1;
   ba = lused + 3 - pcp->ccbeg;
   pcp->lused += pcp->lastg - pcp->ccbeg + 3;
   lused = pcp->lused;
   lg = pcp->ccbeg - 1;
   for (i = pcp->ccbeg, bound = pcp->lastg; i <= bound; i++) {
      y[ba + i] = 0;
      if (y[structure + i] > 0)
	 y[ba + i] = ++lg;
   }

   /* update the redundant defining generators and inverses */
   for (i = 1; i <= ndgen; i++) {
      update (dgen + i, pcp);
      if (pcp->overflow)
	 return;
      update (dgen - i, pcp);
      if (pcp->overflow)
	 return;
   }

   /* finally update and move structure information */

   pcp->ppcomm = pcp->structure;
   pcp->ppower = pcp->ppcomm;
   k = pcp->ppower;
   structure = pcp->structure;
   for (i = pcp->lastg; i >= pcp->ccbeg; i--) {
      if ((j = y[structure + i]) > 0) {
	 y[k] = j; 
	 k--;
      }
      else if (j < 0) {
	 /* deallocate equation for redundant generator i */
	 p1 = -j;
	 y[p1] = 0;
      }
   }

   for (; i > 0; i--)
      y[k--] = y[structure + i];
   if (pcp->subgrp != structure)
      delete_tables (0, pcp);
   pcp->structure = k;
   structure = pcp->structure;
   pcp->words = k;
   pcp->subgrp = k;
   pcp->submlg = pcp->subgrp - lg;

   pcp->lastg = lg;
   y[pcp->clend + current_class] = pcp->lastg;

   /* deallocate the renumbering table */
   p1 = -y[dgen];
   y[p1] = 0;
   return;
}
