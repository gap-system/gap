/****************************************************************************
**
*A  echelon.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: echelon.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#define CAREFUL

/* echelonise the relation stored in exponent form in two parts; 
   left-hand side is in y[lused + 1] to y[lused + lastg]; 
   right-hand side is in y[lused + lastg + 1] to y[lused + 2 * lastg]; 

   the relation should be homogeneous of class pcp->cc; 
   if the result is nontrivial, set it up as a new relation pointed 
   to by the appropriate y[structure + ..]; then remove all occurrences 
   of newly found redundant generator from the other equations */

int echelon (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int j;
   register int k;
   register int p1;
   register int exp;
   register int redgen = 0;
   register int count = 0;
   register int factor;
   register int bound;
   register int offset;
   register int temp;
   register int value;
   register int free;

   register Logical trivial;
   register Logical first;

   register int p = pcp->p;
   register int pm1 = pcp->pm1;

#include "access.h"

   pcp->redgen = 0;
   pcp->eliminate_flag = FALSE;

   /* check that the relation is homogeneous of class pcp->cc */
   if (pcp->cc != 1) {
      offset = pcp->lused - 1;
      temp = pcp->lastg;
      for (i = 2, bound = pcp->ccbeg; i <= bound; i++) {
	 if (y[offset + i] != y[offset + temp + i]) {
	    text (6, pcp->cc, 0, 0, 0);
	    pcp->eliminate_flag = TRUE;
	    return -1;
	 }
      }
   }

   /* compute quotient of the relations and store quotient as an exponent 
      vector in y[pcp->lused + pcp->ccbeg] to y[pcp->lused + pcp->lastg] */
   k = 0;
   offset = pcp->lused;
   for (i = pcp->ccbeg, bound = pcp->lastg; i <= bound; i++) {
      y[offset + i] -= y[offset + bound + i];
      if ((j = y[offset + i])) {
	 if (j < 0)
	    y[offset + i] += p;
	 k = i;
      }
   }

   if (k <= 0)
      return -1;

   /* print out the quotient of the relations */
   if (pcp->diagn) {
      /* a call to compact is not permitted at this point */
      if (pcp->lused + 4 * pcp->lastg + 2 < pcp->structure) {
	 /* first copy relevant entries to new position in y */
	 free = pcp->lused + 2 * pcp->lastg + 1;
	 for (i = 1; i < pcp->ccbeg; ++i)
	    y[free + i] = 0;
	 for (i = pcp->ccbeg; i <= pcp->lastg; ++i)
	    y[free + i] = y[pcp->lused + i];
	 setup_word_to_print ("quotient relation", free, 
			      free + pcp->lastg + 1, pcp);
      }
   }

   first = TRUE;

   while (first || --k >= pcp->ccbeg) {
      /* does generator k occur in the unechelonised relation? */
      if (!first && y[pcp->lused + k] <= 0)
	 continue;

      /* yes */
      first = FALSE;
      exp = y[pcp->lused + k];
      if ((i = y[pcp->structure + k]) <= 0) {
	 if (i < 0) {
	    /* generator k was previously redundant, so eliminate it */
	    p1 = -y[pcp->structure + k];
	    count = y[p1 + 1];
	    offset = pcp->lused;
	    for (i = 1; i <= count; i++) {
	       value = y[p1 + i + 1];
	       j = FIELD2 (value);
	       /* integer overflow can occur here; see comments in collect */ 
	       y[offset + j] = (y[offset + j] + exp * FIELD1 (value)) % p;
	    }
	 }
	 y[pcp->lused + k] = 0;
      }
      else {
	 /* generator k was previously irredundant; have we already 
	    found a generator to eliminate using this relation? */
	 if (redgen > 0) {
	    /* yes, so multiply this term by the appropriate factor
	       and note that the value of redgen is not trivial */
	    trivial = FALSE;
	    /* integer overflow can occur here; see comments in collect */
	    y[pcp->lused + k] = (y[pcp->lused + k] * factor) % p;
	 }
	 else {
	    /* no, we will eliminate k using this relation */
	    redgen = k;
	    trivial = TRUE;

	    /* we want to compute the value of k so we will multiply the 
	       rest of the relation by the appropriate factor;
	       integer overflow can occur here; see comments in collect */
	    factor = pm1 * invert_modp (exp, p);

	    /* we carry out this mod computation to reduce possibility 
	       of integer overflow */
#if defined (CAREFUL)
	    factor = factor % p;
#endif 
	    y[pcp->lused + k] = 0;
	 }
      }
   }

   if (redgen <= 0)
      return -1;
   else 
      pcp->redgen = redgen;

   /* the relation is nontrivial; redgen is either trivial or redundant */

   if (trivial) {
      /* mark redgen as trivial */
      y[pcp->structure + redgen] = 0;

      if (pcp->fullop)
	 text (3, redgen, 0, 0, 0);

      complete_echelon (1, redgen, pcp);
   }
   else {
      /* redgen has value in exponent form in y[pcp->lused + pcp->ccbeg]
	 to y[pcp->lused + redgen(-1)] */
      count = 0;
      offset = pcp->lused;
      for (i = pcp->ccbeg; i <= redgen; i++)
	 if (y[offset + i] > 0) {
	    count++;
	    y[offset + count] = PACK2 (y[offset + i], i);
	 }
      offset = pcp->lused + count + 1;
      for (i = 1; i <= count; i++)
	 y[offset + 2 - i] = y[offset - i];

      /* set up the relation for redgen */
      y[pcp->lused + 1] = pcp->structure + redgen;
      y[pcp->lused + 2] = count;
      y[pcp->structure + redgen] = -(pcp->lused + 1);

      pcp->lused += count + 2;

      if (pcp->fullop)
	 text (4, redgen, 0, 0, 0);

      complete_echelon (0, redgen, pcp);
   }

   pcp->eliminate_flag = TRUE;
   if (redgen < pcp->first_pseudo)
      pcp->newgen--;
   if (pcp->newgen != 0 || pcp->multiplicator)
      return count;

   /* group is completed because all actual generators are redundant,
      so it is not necessary to continue calculation of this class */
   pcp->complete = 1;
   last_class (pcp);

   if (pcp->fullop || pcp->diagn) 
      text (5, pcp->cc, p, pcp->lastg, 0);

   return -1;
}

/* complete echelonisation of this relation by removing all occurrences
   of redgen from the other relations; if the generator redgen is 
   trivial, then the flag trivial is TRUE */

void complete_echelon (trivial, redgen, pcp)
Logical trivial;
int redgen;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int k;
   int i, j, jj, exp;
   int p1;
   int factor;
   int count, count1, count2;
   int predg;
   int offset;
   int temp;
   int value;
   int bound;
   int l;
   int p = pcp->p;

#include "access.h"

   if (trivial) {
      /* delete all occurrences of redgen from other equations */
      for (k = redgen + 1, bound = pcp->lastg; k <= bound; k++) {
	 if (y[pcp->structure + k] >= 0)
	    continue;
	 p1 = -y[pcp->structure + k];
	 count = y[p1 + 1];
	 for (j = 1; j <= count; j++)
	    if ((temp = FIELD2 (y[p1 + j + 1])) >= redgen)
	       break;
	 if (j > count || temp > redgen)
	    continue;

	 /* redgen occurs in this relation, so eliminate it;
	    is redgen in the last word? */
	 count1 = count - 1;

	 if (j < count) {
	    /* no, so pack up relation */
	    for (jj = j; jj <= count1; jj++)
	       y[p1 + jj + 1] = y[p1 + jj + 2];
	 }

	 if (j < count || (j >= count && count1 > 0)) {
	    /* deallocate last word and fix count in header block */
	    y[p1 + count + 1] = -1;
	    y[p1 + 1] = count1;
	    continue;
	 }

	 /* old relation is to be eliminated (it was 1 word long) */
	 y[p1] = 0;
	 y[pcp->structure + k] = 0;
      }
   }
   else {
      p1 = -y[pcp->structure + redgen];
      count = y[p1 + 1];

      /* eliminate all occurrences of redgen from the other relations 
	 by substituting its value */
      for (k = redgen + 1, bound = pcp->lastg; k <= bound; k++) {
	 if (y[pcp->structure + k] >= 0)
	    continue;
	 if (is_space_exhausted (pcp->lastg + 1, pcp))
	    return;
	 p1 = -y[pcp->structure + k];
	 count1 = y[p1 + 1];
	 for (j = 1; j <= count1; j++)
	    if ((temp = FIELD2 (y[p1 + j + 1])) >= redgen)
	       break;
	 if (j > count1 || temp > redgen)
	    continue;

	 /* redgen occurs in this relation, so eliminate it */
	 factor = FIELD1 (y[p1 + j + 1]);
	 predg = -y[pcp->structure + redgen];

	 /* merge old relation with factor * (new relation), deleting redgen; 
	    old relation is longer than new relation since it contains redgen */

	 /* commence merge */
	 count2 = 0;
	 offset = pcp->lused + 2;
	 for (i = 1, l = 1; ; ) {
	    temp = FIELD2 (y[p1 + i + 1]) - FIELD2 (y[predg + l + 1]);
	    if (temp < 0) {
	       count2++;
	       y[offset + count2] = y[p1 + i + 1];
	       i++;
	    }
	    else if (temp > 0) {
	       count2++;
	       /* integer overflow can occur here; see comments in collect */
	       value = y[predg + l + 1];
	       y[offset + count2] = PACK2 ((factor * FIELD1 (value)) % p, 
					   FIELD2 (value));
	       if (++l > count)
		  break;
	    }
	    else {
	       /* integer overflow can occur here; see comments in collect */
	       value = y[p1 + i + 1];
	       exp = (FIELD1 (value) + factor * FIELD1 (y[predg + l + 1])) % p;
	       if (exp > 0) {
		  count2++;
		  y[offset + count2] = PACK2 (exp, FIELD2 (value));
	       }
	       i++;
	       if (++l > count)
		  break;
	    }
	 }

	 /* all of the value of redgen has been merged in;
	    copy in the remainder of the old relation with redgen deleted */
	 offset = pcp->lused + 2;
	 for (jj = i; jj <= count1; jj++)
	    if (jj != j) {
	       count2++;
	       y[offset + count2] = y[p1 + jj + 1];
	    }

	 /* new relation is now in y[lused + 2 + 1] to y[lused + 2 + count2] */

	 /* new relation indicates generator k is trivial; deallocate old */
	 if (count2 <= 0) {
	    y[p1] = 0;
	    y[pcp->structure + k] = 0;
	    continue;
	 }

	 /* new relation is nontrivial */

	 if (count2 < count1) {
	    /* new relation is shorter than old; copy in new relation */
	    for (i = 1; i <= count2; i++)
	       y[p1 + i + 1] = y[pcp->lused + 2 + i];

	    /* reset count field for new relation */
	    y[p1 + 1] = count2;

	    /* deallocate rest of old relation */
	    if (count1 == count2 + 1)
	       y[p1 + count2 + 2] = -1;
	    else {
	       y[p1 + count2 + 2] = 0;
	       y[p1 + count2 + 3] = count1 - count2 - 2;
	    }
	 }
	 else if (count1 == count2) {
	    /* new relation has same length as old; overwrite old relation */
	    offset = pcp->lused + 2;
	    for (i = 1; i <= count2; i++)
	       y[p1 + i + 1] = y[offset + i];
	 }
	 else {
	    /* new relation is longer than old; deallocate old relation */
	    y[p1] = 0;

	    /* set up pointer to new relation and header block */
	    y[pcp->structure + k] = -(pcp->lused + 1);
	    y[pcp->lused + 1] = pcp->structure + k;
	    y[pcp->lused + 2] = count2;
	    pcp->lused += count2 + 2;
	 }
      }
   }
}
