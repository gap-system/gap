/****************************************************************************
**
*A  setup.c                     ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: setup.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"
#include "setup.h"

void class_setup ();

/* this routine moves existing structures in the array y to create 
   the space necessary to store the presentation to be computed for 
   the next class; for a description of the basic data structures, 
   read the header file setup.h */

void setup (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int e;
   register int i;
   register int j;
   register int k;
   register int s;
   register int w;
   register int x;
   register int p1;
   register int ee;

   register int moccur;
   register int new_space;      /* new space required for next class */
   register int max_gens;       /* upper bound for total number of generators */
   register int end_ccm2;       /* last generator of class pcp->cc - 2 */
   register int halfwt;
   register int oldpc;

   register int pcomm;
   register int extra_ppower;   /* extra pointers to powers */
   register int extra_ppcomm;   /* extra pointers to pointers to commutators */
   register int extra_comm;     /* extra pointers to commutators */

   register int bound;
   register int value;

   register int ndgen = pcp->ndgen;
   register int lastg = pcp->lastg;
   register int class_end;

#include "access.h"

   /* delete the pcp->words and subgroups entries if present */
   if (pcp->subgrp != pcp->structure && pcp->cc != 0)
      delete_tables (0, pcp);
   if (pcp->complete != 0 && !pcp->multiplicator)
      return;

   ++pcp->cc;
   pcp->ccbeg = pcp->lastg + 1;

   /* set up class 1 */
   if (pcp->cc == 1) {

      /* y[pcp->clend + i] is the number of the last pcp generator 
	 in class i; set y[pcp->clend] = 0 for convenience */

      pcp->clend = pcp->fronty;
      for (i = 0; i <= MAXCLASS; ++i)  
	 y[pcp->clend + i] = 0;

      pcp->dgen = pcp->clend + MAXCLASS + ndgen + 1;
      moccur = pcp->dgen + ndgen;
      pcp->relp = moccur + ndgen;

      pcp->first_pseudo = 0;
      pcp->newgen = ndgen;
      pcp->lastg = ndgen;

      /* structure information is stored at the back of y */
      pcp->structure = pcp->backy - ndgen;
      pcp->words = pcp->structure;
      pcp->subgrp = pcp->words;
      pcp->submlg = pcp->subgrp - pcp->lastg;
      pcp->nwords = 0;
      pcp->nsubgp = 0;

      /* pcp->lused is the last used location working from the front */
      pcp->lused = pcp->relp + 2 * pcp->ndrel;

      /* pcp->gspace is the index of the first garbage collectable
	 location in the array y */
      pcp->gspace = pcp->lused + 1;

      if (is_space_exhausted (0, pcp))
	 return;

      /* mark all defining generators as irredundant */
      for (i = 1; i <= ndgen; ++i) {
	 y[pcp->dgen + i] = i;
	 y[moccur + i] = 0;
      }

      /* read defining relations */
      /*
	read_relations (pcp);
	pcp->gspace = pcp->lused + 1;
	*/

      /* set up inverse, j^(p - 1), for defining generator j;
	 not all inverses are required but we choose to compute these 
	 as such information is useful for the Holt & Rees programs */

      for (j = 1; j <= ndgen; ++j) {
	 if (is_space_exhausted (3, pcp))
	    return;
	 pcp->lused += 3;
	 y[pcp->dgen - j] = -(pcp->lused - 2);
	 y[pcp->lused - 1] = 1;
	 y[pcp->lused - 2] = pcp->dgen - j;
	 y[pcp->lused] = PACK2 (pcp->pm1, j);
      }
   
      /* for generators of current class, generator eliminating 
	 equations are pointed to by y[structure + i];
	 y[structure + i] is positive if generator i is not redundant;
	 y[structure + i] = 0 if generator i is trivial;
	 y[structure + i] = -ptr if generator i has value pointed to by ptr;
         
	 each positive word in y[structure + i] has 3 pieces of 
	 information stored in it arranged as follows --
	 bits 25 to the (no of bits in a computer word - 1) contain 
	 weight (class) information; 
	 bits 0 to 24 contain the defining information for generator i;
	 the defining information is composed of 2 parts,
	 bits 0 to 8 containing a say, and bits 9 to 24 containing b say;
	 if b = 0 then generator i is on the image of defining generator a;
	 if a = 0 then generator i is on the power b^p;
	 if both a and b are non-zero then generator i is on the 
	 commutator (b, a); it is possible that this version allows the 
	 user to control the the precise breakdown of the word via
	 the run-time options -c and -d */

      /* insert structure information to indicate that i is irredundant */
      for (i = 1; i <= ndgen; ++i)  
	 y[pcp->structure + i] = i;

      return;
   }

   /* for class 2 we create space for --
      the pointers to powers (base address pcp->ppower), 
      pointers to pointers to commutators (base address pcp->ppcomm), 
      pointers to commutators, and additional structure information;
      this data is accommodated by moving the structure array forward */

   if (pcp->cc == 2) {

      pcp->ncomm = lastg * (lastg - 1) / 2;

      /* is the next class already set up? */
      if (pcp->ncset != 0) {
	 new_space = pcp->ncomm + ndgen;
	 class_setup (new_space, pcp);
	 return;
      }
   
      /* the following additional space is required --
	 for pcp->ppower = lastg; for pcp->ppower = lastg;
	 for pcp->ppcomm = lastg - 1; for pcomm = pcp->ncomm;
	 also required is pcp->ncomm + ndgen */

      new_space = lastg + lastg - 1 + pcp->ncomm + pcp->ncomm + ndgen;

      /* structure information is moved to accommodate the new data */
      pcp->structure -= new_space;
      pcp->words = pcp->structure;
      pcp->subgrp = pcp->words;
      pcp->submlg = pcp->subgrp - lastg;

      if (is_space_exhausted (0, pcp))
	 return;

      for (i = 1; i <= lastg; ++i)  
	 y[pcp->structure + i] = y[pcp->structure + new_space + i];

      /* pointers to powers follow structure plus any spare area */
      pcp->ppower = pcp->structure + lastg + pcp->ncomm + ndgen;

      for (i = 1; i <= lastg; ++i)  
	 y[pcp->ppower + i] = 0;

      /* initialise pcp->ppcomm so that y[pcp->ppcomm + 2] is the 
	 first location after y[pcp->ppower + lastg] */
      pcp->ppcomm = pcp->ppower + lastg - 1;
   
      /* pointers to commutators follow in lexicographic order
	 after y[pcp->ppcomm + lastg] */
      pcomm = pcp->ppcomm + lastg;
      for (i = 2; i <= lastg; ++i) {
	 pcomm += i - 2;
	 y[pcp->ppcomm + i] = pcomm;
      }

      for (i = 1, bound = pcp->ncomm; i <= bound; ++i)  
	 y[pcp->ppcomm + lastg + i] = 0;

      return;
   }

   /* class 3 onwards --
      check that occurrence conditions don't stop at this class */

   if (pcp->nocset > 1 && pcp->cc > pcp->nocset) {
      --pcp->cc;
      pcp->complete = 1;
      pcp->ccbeg = y[pcp->clend + pcp->cc - 1] + 1;
      /*
	text (5, pcp->cc, pcp->p, lastg, 0);
	*/
      return;
   }

   class_end = pcp->clend;

   /* calculate an upper bound for the number of new generators */
   value = y[class_end + 1];
   max_gens = value * (value - 1) / 2 + (lastg - value) * value + ndgen;

   /* is the next class already set up? */
   if (pcp->ncset != 0) {
      new_space = max_gens;
      class_setup (new_space, pcp);
      return;
   }

   /* compute the new space required */
   end_ccm2 = y[class_end + pcp->cc - 2];
   extra_ppower = lastg - end_ccm2;
   extra_ppcomm = extra_ppower;
   halfwt = (pcp->cc - 1) / 2;

   /* compute the number of extra commutators to be stored */
   for (i = 1, extra_comm = 0; i <= halfwt; ++i) {
      extra_comm += (y[class_end + i] - y[class_end + i - 1]) *
	 (y[class_end + pcp->cc - i] - y[class_end + pcp->cc - i - 1]);
   }

   if (MOD(pcp->cc, 2) == 0) {
      halfwt = pcp->cc / 2;
      extra_comm += (y[class_end + halfwt] - y[class_end + halfwt - 1]) *
	 (y[class_end + halfwt] - y[class_end + halfwt - 1] - 1) / 2;
   }

   new_space = max_gens + extra_ppower + extra_ppcomm + extra_comm;

   if (is_space_exhausted (new_space, pcp))
      return;

   /* move structure array forward */
   pcp->structure -= new_space;
   pcp->words = pcp->structure;
   pcp->subgrp = pcp->words;
   pcp->submlg = pcp->subgrp - lastg;

   for (i = 1; i <= lastg; ++i)  
      y[pcp->structure + i] = y[pcp->structure + new_space + i];

   /* move pointers to powers forward */
   for (i = 1; i <= end_ccm2; ++i) {
      y[pcp->structure + lastg + max_gens + i] = y[pcp->ppower + i];
      if (y[pcp->ppower + i] < 0) {
	 p1 = -y[pcp->ppower + i];
	 y[p1] = pcp->structure + lastg + max_gens + i;
      }
   }

   pcp->ppower = pcp->structure + lastg + max_gens;
   for (i = end_ccm2 + 1; i <= lastg; ++i)  
      y[pcp->ppower + i] = 0;

   oldpc = pcp->ppcomm + end_ccm2;
   pcp->ppcomm = pcp->ppower + lastg - 1;
   pcomm = pcp->ppcomm + lastg;

   /* move pointers to commutators and compute pointers to these */
   for (w = 3, bound = pcp->cc; w <= bound; w++) {
      s = MAX(y[class_end + w - 3] + 1, 2);
      e = y[class_end + w - 2];

      for (i = s; i <= e; ++i) {
	 y[pcp->ppcomm + i] = pcomm;
	 value = y[class_end + pcp->cc - w + 1];
	 for (ee = MIN(i - 1, value); ee > 0; --ee) {
	    y[++pcomm] = y[++oldpc];
	    if (y[pcomm] < 0) {
	       p1 = -y[pcomm];
	       y[p1] = pcomm;
	    }
	 }

	 x = w - 2 - halfwt;
	 if (x > 0) 
	    /* make room for (w - 2, pcp->cc - (w - 2)) commutators */
	    k = y[class_end + pcp->cc - w + 2] - value;
	 else {
	    if (x == 0 && MOD(pcp->cc, 2) == 0)
	       /* make room for (pcp->cc / 2, pcp->cc / 2) commutators */
	       k = MAX(0, i - y[class_end + halfwt - 1] - 1);
	    else
	       k = 0;
	 }
	 for (j = 1; j <= k; ++j)  
	    y[pcomm + j] = 0;
	 pcomm += k;
      }
   }

   /* append the left-normed commutators of class pcp->cc */
   s = y[class_end + pcp->cc - 2] + 1;
   k = y[class_end + 1];
   for (i = s; i <= lastg; ++i) {
      for (j = 1; j <= k; ++j)  
	 y[pcomm + j] = 0;
      y[pcp->ppcomm + i] = pcomm;
      pcomm += k;
   }

   pcp->ncomm += extra_comm;
}

/* was the class already setup? */

void class_setup (new_space, pcp)
int new_space;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int bound = pcp->lastg;

   new_space -= (pcp->ppower - (pcp->structure + pcp->lastg));
   if (new_space > 0) { 
      if (is_space_exhausted (new_space, pcp))
	 return;
      pcp->structure -= new_space;
      pcp->words = pcp->structure;
      pcp->subgrp = pcp->words;
      pcp->submlg = pcp->subgrp - pcp->lastg;

      for (i = 1; i <= bound; ++i)  
	 y[pcp->structure + i] = y[pcp->structure + new_space + i];
   }
   pcp->ncset = 0;
}
