/****************************************************************************
**
*A  last_class.c                ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: last_class.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"

/* delete all entries for class pcp->cc and note that 
   it is still set up (that is, set pcp->ncset = 1) */

void last_class (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int j;
   register int p1;
   register int bound;
   register int structure;
   register int ndgen = pcp->ndgen;

   if (pcp->ncset != 0 || pcp->cc == 1) {
      text (10, 0, 0, 0, 0);
      return;
   }
   
   /* remove all word and subgroup tables entries */
   delete_tables (0, pcp);

   /* remove all equations */
   structure = pcp->structure;
   for (i = pcp->ccbeg, bound = pcp->lastg; i <= bound; i++) {
      if ((j = y[structure + i]) < 0) {
	 /* deallocate this equation */
	 y[-j] = 0;
      }
   }

   /* initialise this value to 0 */
   y[pcp->clend + pcp->cc] = 0;

   --pcp->cc;
   pcp->lastg = pcp->ccbeg - 1;
   pcp->submlg = pcp->subgrp - pcp->lastg;
   pcp->ccbeg = y[pcp->clend + pcp->cc - 1] + 1;

   for (i = 1, bound = pcp->lastg; i <= bound; i++)
      down_class (pcp->ppower + i, pcp);

   p1 = y[pcp->ppcomm + 2];
   for (i = 1, bound = pcp->ncomm; i <= bound; i++)
      down_class (p1 + i, pcp);

   for (i = 1; i <= ndgen; i++) {
      down_class (pcp->dgen + i, pcp);
      down_class (pcp->dgen - i, pcp);
   }

   pcp->ncset = 1;
}
