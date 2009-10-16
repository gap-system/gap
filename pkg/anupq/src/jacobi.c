/****************************************************************************
**
*A  jacobi.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: jacobi.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* solve the consistency equation
   1)  (a^p) a = a (a^p)        if c = b = a else
   2)  (b^p) a = b^(p - 1) (ba) if c = b     else
   3)  (ca) a^(p-1) = c (a^p)   if b = a     else
   4)  (cb) a = c (ba)

   if ptr > 0, use this equation to fill in the class pcp->cc part on y[ptr];

   if ptr = 0, use this equation to check consistency so we 
   calculate a new relation among the class pcp->cc generators */

void jacobi (c, b, a, ptr, pcp)
int c;
int b;
int a;
int ptr;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int k;
   register int p1;
   register int cp1;
   register int cp2;
   register int unc;
   register int address;
   register int ycol;
   register int commba;
   register int count;
   register int count2;
   register int offset;

   register int lastg = pcp->lastg;
   register int prime = pcp->p;
   register int pm1 = pcp->pm1;
   register int p_power = pcp->ppower;
   register int p_pcomm = pcp->ppcomm;

#include "access.h"

#if defined (GROUP) 
   if (is_space_exhausted (2 * lastg + 3, pcp))
      return;
#endif 

#if defined (LIE) 
   if (is_space_exhausted (6 * lastg + 6, pcp))
      return;
#endif 

   /* cp1 and cp2 are the base addresses for the collected 
      part of the lhs and of the rhs, respectively */
   cp1 = pcp->lused;
   cp2 = cp1 + lastg;
   unc = cp2 + lastg + 1;

   for (i = 1; i <= lastg; i++)  
      y[cp1 + i] = y[cp2 + i] = 0;

   /* calculate the class pcp->cc part of the jacobi relation
      (b^p) a = b^(p - 1) (ba) */

   if (c == b) {
      ycol = y[p_power + b];
      collect (ycol, cp1, pcp);
      collect (a, cp1, pcp);

      if (b != a) {
	 y[cp2 + b] = pm1;
	 p1 = y[p_pcomm + b];
	 commba = y[p1 + a];
	 collect (a, cp2, pcp);
	 collect (b, cp2, pcp);
	 collect (commba, cp2, pcp);
      }
      else  {
	 /* we are processing (a^p) a = a (a^p) */
	 ycol = y[p_power + a];
	 y[cp2 + a] = 1;
	 collect (ycol, cp2, pcp);
      }
   }
   else {
      if (b - a > 0) {
#if defined (GROUP)
	 /* calculate the class pcp->cc part of the jacobi relation
	    (cb) a = c (ba); set up a as the collected part for lhs */
	 y[cp1 + c] = 1;
	 collect (b, cp1, pcp);
	 collect (a, cp1, pcp);
	 y[cp2 + c] = 1;
	 collect (a, cp2, pcp);
	 collect (b, cp2, pcp);
	 p1 = y[p_pcomm + b];
	 commba = y[p1 + a];
	 collect (commba, cp2, pcp);
#endif 
#if defined (LIE) 
	 /* calculate the Jacobi word 
	    [[c, b], a] + [[b, a], c] + [[a, c], b] */
	 jacobi_word (a, b, c, cp1, cp2, pcp);
#endif 
      } 
      else {
	 /* calculate the class pcp->cc part of the jacobi relation 
	    (ca) a^(p - 1) = c (a^p); first collect rhs */
	 ycol = y[p_power + a];
	 y[cp2 + c] = 1;
	 collect (ycol, cp2, pcp);

	 /* collect lhs; set up c as collected part */
	 y[cp1 + c] = 1;
	 collect (a, cp1, pcp);
	 y[unc] = 1;
	 y[unc + 1] = PACK2 (pm1, a);
	 collect (-unc + 1, cp1, pcp);
      }
   }

   /* the jacobi collections are completed */

   if ((p1 = ptr) > 0) {
      /* we are filling in the tail on y[p1]; convert the class pcp->cc 
	 part to string form in y[cp1 + 2 + 1] to y[cp1 + 2 + count] 
	 where count is the string length */

      count = 0;
      for (i = pcp->ccbeg; i <= lastg; i++) {
	 k = y[cp1 + i] - y[cp2 + i];
	 if (k != 0) {
	    if (k < 0)
	       k += prime;
	    ++count; 
	    y[cp1 + 2 + count] = PACK2 (k, i);
	 }
      }

      if (count > 0) {
	 /* y[p1] was trivial to class pcp->cc - 1 so create a new entry */
	 if (y[p1] >= 0) {
	    y[p1] = -(cp1 + 1);
	    y[cp1 + 1] = p1;
	    y[cp1 + 2] = count;
	    pcp->lused += count + 2;
	 }
	 else {
	    /* the class pcp->cc part is nontrivial so make room for 
	       lower class terms */
	    address = -y[p1];
	    count2 = y[address + 1];

	    /* move class pcp->cc part up */
	    offset = cp1 + count + 3;
	    for (i = 1; i <= count; i++)  
	       y[offset + count2 - i] = y[offset - i];

	    /* copy in lower class terms */
	    for (i = 1; i <= count2; i++)  
	       y[cp1 + 2 + i] = y[address + i + 1];

	    /* create new header block */
	    y[cp1 + 1] = y[address];
	    y[cp1 + 2] = count + count2;

	    /* deallocate old entry */
	    y[address] = 0;

	    /* set up pointer to new entry */
	    y[p1] = -(cp1 + 1);
	    pcp->lused += count + count2 + 2;
	 }
      }
   }
   else {
      /* we are checking consistency equations */
      echelon (pcp);
      if ((pcp->fullop && pcp->eliminate_flag) || pcp->diagn)
	 text (9, c, b, a, 0);
   }
}
