/****************************************************************************
**
*A  update.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: update.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* the new values for irredundant generators have been 
   assembled in eliminate in a table pointed to by y[dgen]; 
   update the value represented by y[ptr] and y[ptr] if necessary */

void update (ptr, pcp)
int ptr;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int g;
   register int i;
   register int k;
   register int p1 = ptr;
   register int p2;
   register int p3;
   register int renumb;
   register int count;
   register int expfba;
   register int count1;
   register int factor;
   register int count2;
   register int lastg;
   register int value;

   register int structure = pcp->structure;
   register int lused = pcp->lused;
   register int class_beg = pcp->ccbeg;
   register int dgen = pcp->dgen;

#include "access.h"

   if (y[p1] == 0)
      return;

   /* consider case where y[ptr] represents a generator */
   if (y[p1] > 0) {

      if (class_beg - y[p1] > 0)
	 return;

      /* the generator is of class pcp->cc */
      g = y[p1];

      value = y[structure + g];
      if (value == 0) {
	 /* g is now trivial */
	 y[p1] = 0;
      }
      else if (value > 0) {
	 /* g is an irredundant generator */
	 renumb = -y[dgen] - class_beg + 2;
	 y[p1] = y[renumb + g];
      }
      else {
	 /* g is redundant with value pointed to by y[structure + g] */
	 if (is_space_exhausted (g - class_beg + 1, pcp))
	    return;
	 lused = pcp->lused;
	 p2 = -y[structure + g];
	 count = y[p2 + 1];
	 renumb = -y[dgen] - class_beg + 2;

	 /* make a renumbered copy of the value of g */
	 for (i = 1; i <= count; i++) {
	    k = FIELD2 (y[p2 + i + 1]);
	    y[lused + 2 + i] = PACK2 (FIELD1 (y[p2 + i + 1]), y[renumb + k]);
	 }
	 y[lused + 1] = p1;
	 y[lused + 2] = count;
	 y[p1] = -(lused + 1);
	 pcp->lused += count + 2;
      }

      return;
   }

   /* the value represented by y[ptr] is a string;
      find the length of the old class pcp->cc part and calculate
      the new class pcp->cc part (in exponent form from y[lused + 1]) */

   if (is_space_exhausted (pcp->lastg + 2, pcp))
      return;

   lused = pcp->lused;
   renumb = -y[dgen] - class_beg + 2;
   p3 = -y[p1];
   expfba = lused + 1 - class_beg;

   /* set exponent form trivial */
   for (i = class_beg, lastg = pcp->lastg; i <= lastg; i++)
      y[expfba + i] = 0;

   count = y[p3 + 1];

   /* convert each symbol of old class pcp->cc part */
   for (count1 = count;
	(g = FIELD2 (y[p3 + count1 + 1])) >= class_beg && count1 > 0; count1--) {
      if ((i = y[structure + g]) >= 0) {
	 /* g is irredundant so renumber it */
	 if (i > 0) {
	    g = y[renumb + g];
	    y[expfba + g] += FIELD1 (y[p3 + count1 + 1]);
	 }
      }
      else {
	 /* g is redundant */
	 p2 = -y[structure + g];
	 factor = FIELD1 (y[p3 + count1 + 1]);
	 count2 = y[p2 + 1];
	 for (i = 1; i <= count2; i++) {
	    g = FIELD2 (y[p2 + i + 1]);
	    g = y[renumb + g];
	    y[expfba + g] += factor * FIELD1 (y[p2 + i + 1]);
	 }
      }
   }

   /* check if old class pcp->cc part was trivial */
   if (count1 - count >= 0)
      return;

   /* convert new class pcp->cc part from exponent form to string */
   count2 = 0;
   for (i = class_beg, lastg = pcp->lastg; i <= lastg; i++) {
      if (y[expfba + i] % pcp->p > 0) {
	 count2++;
	 y[lused + count2] = PACK2 (y[expfba + i] % pcp->p, i);
      }
   }

   /* check if new class pcp->cc part is trivial */
   if (count2 <= 0) {
      /* if entire value is trivial, deallocate old value */
      if (count1 <= 0) {
	 y[p1] = y[p3] = 0;
	 return;
      }

      /* deallocate old class pcp->cc part */
      if (count == count1 + 1)
	 y[p3 + count1 + 2] = -1;
      else {
	 y[p3 + count1 + 3] = count - count1 - 2;
	 y[p3 + count1 + 2] = 0;
      }

      /* fix header block */
      y[p3 + 1] = count1;
      return;
   }

   /* new part is nontrivial; check if it is longer 
      than the old class pcp->cc part */

   if (count > count1 + count2) {
      /* new part is shorter than old part so deallocate the spare words */
      if (count == count1 + count2 + 1)
	 y[p3 + count1 + count2 + 2] = -1;
      else {
	 y[p3 + count1 + count2 + 2] = 0;
	 y[p3 + count1 + count2 + 3] = count - count1 - count2 - 2;
      }
   }

   if (count >= count1 + count2) {
      /* copy in the new class pcp->cc part */
      for (i = 1; i <= count2; i++)
	 y[p3 + count1 + i + 1] = y[lused + i];

      /* fix header block */
      y[p3 + 1] = count1 + count2;
      return;
   }

   /* new part is longer than the old part; move up the new 
      class pcp->cc part to copy in the earlier parts */
   k = lused + count2 + 1;
   for (i = 1; i <= count2; i++) {
      --k;
      y[k + 2 + count1] = y[k];
   }
   k = count1 + 2;

   /* copy in the earlier parts */
   for (i = 1; i <= k; i++)
      y[lused + i] = y[p3 - 1 + i];

   /* deallocate old value */
   y[p3] = 0;

   /* fix new header block */
   y[lused + 2] = count1 + count2;

   /* fix pointer */
   y[p1] = -(lused + 1);
   pcp->lused += count1 + count2 + 2;
}
