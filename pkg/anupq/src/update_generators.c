/****************************************************************************
**
*A  update_generators.c         ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: update_generators.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* add pseudo-generators to redundant defining generators;
   also recompute required inverses of defining generators;

   this routine must be called before a call to collect defining 
   relations; if there are redundant defining generators, calls to 
   eliminate should only be done after calling update_generator 
   because the space reserved for the pseudo-generator(s) added 
   by update_generator in structure is not set up yet */

void update_generators (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int f;
   register int i;
   register int cp;
   register int start;
   register int ycol;
   register int length;
   register int extra;
   register int value;

   register int prime = pcp->p;
   register int dgen = pcp->dgen;
   register int ndgen = pcp->ndgen;
   register int lused;
   register int lastg; 

#include "access.h"

   /* first, add pseudo-generators to redundant defining generators */

   for (f = 1; f <= ndgen; f++) {
      value = y[dgen + f];
      if (value == 0) {
	 /* defining generator f was trivial; insert pseudo-generator */

	 if (is_space_exhausted (3, pcp))
	    return;

	 pcp->lused += 3;
	 lused = pcp->lused;

	 /* set up block header block and pointer to it */
	 y[lused - 2] = dgen + f;
	 y[lused - 1] = 1;
	 y[dgen + f] = -(lused - 2);

	 /* add pseudo-generator */
	 pcp->lastg++;
	 y[lused] = PACK2 (1, pcp->lastg);

	 /* if there are greater than MAXGENS defining generators
	    then this field will overflow; such an overflow causes 
	    some output idiocies, but no logical errors */

	 y[pcp->structure + pcp->lastg] = PACK3 (0, 0, f) + INSWT (pcp->cc);

      }
      else if (value < 0) {
	 /* old entry was non-trivial so we deallocate it
	    and insert pseudo-generator */
	 extend_tail (dgen + f, 0, f, pcp);
	 if (pcp->overflow)
	    return;
      }
   }

   /* update submlg to account for any new pseudo-generators introduced */
   pcp->submlg = pcp->subgrp - pcp->lastg;

   /* now, recompute required inverses -- 
      we know the inverse of f to the end of class pcp->cc - 1;
      denote this by f'; evaluate f * f' and take the inverse of 
      this result to give the class pcp->cc part of f^-1 */

   for (f = 1; f <= ndgen; f++) {
      if (y[dgen - f] > 0)
	 continue;

      if (is_space_exhausted (2 * pcp->lastg + 2, pcp))
	 return;

      lastg = pcp->lastg;
      lused = pcp->lused;
      cp = lused + lastg + 2;
      for (i = 1; i <= lastg; ++i)
	 y[cp + i] = 0;
      ycol = y[dgen + f];
      collect (ycol, cp, pcp);
      ycol = y[dgen - f];
      collect (ycol, cp, pcp);

      /* inverse of the class pcp->cc part of f^(-1) is now in 
	 y[cp + pcp->ccbeg] to y[cp + pcp->lastg] in exponent form; 
	 convert it to string form */

      length = 0;
      for (i = pcp->ccbeg; i <= lastg; i++) {
	 if ((ycol = y[cp + i]) > 0) {
	    ++length;
	    y[lused + 2 + length] = PACK2 (prime - ycol, i);
	 }
      }
      if (length == 0) continue;

      /* the class pcp->cc part of f^(-1) is nontrivial */

      if (y[dgen - f] >= 0) {

	 /* f^(-1) was previously trivial */
	 y[lused + 1] = dgen - f;
	 y[lused + 2] = length;
	 y[dgen - f] = -(lused + 1);
	 pcp->lused += length + 2;
	 lused = pcp->lused;
      }
      else {

	 /* f^(-1) was nontrivial, so make room for lower class entries */
	 start = -y[dgen - f];
	 extra = y[start + 1];
	 ycol = lused + length + 3;
	 for (i = 1; i <= length; i++)
	    y[ycol + extra - i] = y[ycol - i];

	 /* copy header block and lower class entries */
	 for (i = 1; i <= extra; i++)
	    y[lused + i + 2] = y[start + i + 1];

	 /* fix header block */
	 y[lused + 1] = y[start];
	 y[lused + 2] = length + extra;

	 /* deallocate old entry */
	 y[start] = 0;

	 /* set up pointer to new entry */
	 y[dgen - f] = -(lused + 1);
	 pcp->lused += length + extra + 2;
      }
   }
}
