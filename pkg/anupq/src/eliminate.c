/****************************************************************************
**
*A  eliminate.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: eliminate.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* eliminate all redundant generators to construct the consistent 
   power commutator presentation for the group to class current_class;
   
   if middle_of_tails is TRUE, do not delete space set aside in 
   setup; in this case, only deallocate redundant generators */

void eliminate (middle_of_tails, pcp)
Logical middle_of_tails;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int j;
   register int k;
   register int l;
   register int p1;
   register int ba;
   register int lg;
   register int length;
   register int bound;

   register int structure = pcp->structure;
   register int current_class = pcp->cc;
   register int lused = pcp->lused;
   register int prime = pcp->p;
   register int dgen = pcp->dgen;
   register int ndgen = pcp->ndgen;
   register int pointer;
   register int value;

#include "access.h"

   /* calculate new values for irredundant generators and set them up 
      in a renumbering table of length pcp->lastg - pcp->ccbeg + 1 
      which looks to compact like a normal exponent-generator string 
      pointed to by y[dgen] */

   if (current_class != 1) {

      if (is_space_exhausted (pcp->lastg - pcp->ccbeg + 3, pcp))
	 return;

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

      /* update pcp->first_pseudo */
      bound = pcp->lastg;
      for (i = pcp->first_pseudo; i <= bound && y[structure + i] <= 0; i++)  
	 ;
      pcp->first_pseudo = (i > pcp->lastg) ? lg + 1 : y[ba + i];

      /* update the commutator tables */
      p1 = y[pcp->ppcomm + 2];
      for (i = 1, bound = pcp->ncomm; i <= bound; i++) {
	 update (p1 + i, pcp);
	 if (pcp->overflow)
	    return;
      }

      /* update the power tables */
      for (i = 2, bound = pcp->ccbeg; i <= bound; i++) {
	 /* fix (i - 1)^p */
	 update (pcp->ppower + i - 1, pcp);
	 if (pcp->overflow)
	    return;
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

      if (middle_of_tails) {
	 pointer = pcp->structure + pcp->ccbeg - 1;
	 for (i = pcp->ccbeg; i <= pcp->lastg; ++i) {
	    if ((value = y[pcp->structure + i]) > 0)  
	       y[++pointer] = value;
	    else if (value < 0)
	       y[-value] = 0;
	 }
      }
      else {
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
      } 

      pcp->lastg = lg;
      y[pcp->clend + current_class] = pcp->lastg;

      /* deallocate the renumbering table */
      p1 = -y[dgen];
      y[p1] = 0;
      return;
   }

   /* class 1 */

   pcp->lastg = 0;
   for (i = 1; i <= ndgen; i++) {
      if ((j = y[structure + i]) == 0) {
	 /* defining generator i is trivially redundant */
	 y[dgen + i] = 0;
	 if (y[dgen - i] < 0) {
	    /* deallocate old inverse */
	    p1 = -y[dgen - i];
	    y[p1] = 0;
	    /* set new inverse trivial */
	    y[dgen - i] = 0;
	 }
      }
      else if (j < 0) {
	 /* defining generator i is redundant with value pointed 
	    to by -y[structure + i] */
	 y[dgen + i] = y[structure + i];
	 p1 = -y[dgen + i];
	 length = y[p1 + 1];
	 y[p1] = dgen + i;

	 /* renumber value of defining generator i */
	 for (k = 1; k <= length; k++) {
	    l = FIELD2 (y[p1 + k + 1]);
	    y[p1 + k + 1] += y[dgen + l] - l;
	 }

	 if (y[dgen - i] < 0) {
	    /* i inverse occurs in a defining relation, so recompute 
	       the inverse and set up header block for inverse */
	    y[lused + 1] = dgen - i;
	    y[lused + 2] = length;

	    /* set up inverse */
	    for (j = 1; j <= length; j++) {
	       k = y[p1 + j + 1];
	       y[lused + 2 + j] = PACK2 (prime - FIELD1 (k), FIELD2 (k));
	    }

	    /* deallocate old inverse */
	    p1 = -y[dgen - i];
	    y[p1] = 0;
	    y[dgen - i] = -(lused + 1);
	    pcp->lused += length + 2;
	    lused = pcp->lused;
	 }
      }
      else {
	 /* i is an irredundant generator */
	 pcp->lastg++;
	 y[dgen + i] = pcp->lastg;
	 /* note that its weight is set to be 1 */
	 y[structure + pcp->lastg] = PACK3 (1, 0, i); 

	 /* check if inverse of i is required */
	 if (y[dgen - i] < 0) {
	    /* yes, so renumber previously set up inverse */
	    p1 = -y[dgen - i];
	    y[p1 + 2] += pcp->lastg - i;
	 }
      }
   }

   if (pcp->lastg < 1) {
      text (7, prime, 0, 0, 0);
      pcp->complete = 1;
      pcp->cc = 0;
   }
   else {
      y[pcp->clend + 1] = pcp->lastg;
      pcp->submlg = pcp->subgrp - pcp->lastg;
   }
}
