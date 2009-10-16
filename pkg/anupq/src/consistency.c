/****************************************************************************
**
*A  consistency.c               ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: consistency.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if !defined (CONSISTENCY_FILTER)

#include "pq_defs.h"
#include "pcp_vars.h"

/* process those consistency relations of weight wc not already used; 
   the value of type determines the consistency relations processed;
   if type = 0 then all relations are processed;
   for Lie Algebra calculations, the type is always 3  */

void consistency (type, queue, queue_length, wc, pcp)
int type;
int *queue;
int *queue_length;
int wc;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int a;
   register int b;
   register int c;

   register int wta;            /* weight of a */

   register int a_start;        /* start of range for a */
   register int a_end;          /* end of range for a */
   register int b_start;
   register int b_end;
   register int c_start;
   register int c_end;

   register int jacobi_wt = wc;
   register int bound = jacobi_wt >> 1; 
   register int constant;
   register int offset;   
   register int entry;
   register int p1;

   register int class_end = pcp->clend;
   register int p_pcomm = pcp->ppcomm;
   register int p_power = pcp->ppower;
   register int structure = pcp->structure;

   register Logical metabelian = pcp->metabelian;
   register Logical compute;    /* is it necessary to compute jacobi? */

#include "access.h"

   /* process the consistency equations (a^p) a = a (a^p) 
      where 2 * WT(a) + 1 = jacobi_wt */

   if (type == 0 || type == 1) {
      if (MOD(jacobi_wt, 2) != 0) {

	 /* find range of a */
	 offset = class_end + bound - 1;
	 a_start = y[offset] + 1;
	 a_end = y[++offset];

	 for (a = a_start; a <= a_end; a++) {
	    compute = (!metabelian || (metabelian && 
           (PART2 (y[structure + a]) == 0 || PART3 (y[structure + a]) == 0)));
	    if (compute) {
	       jacobi (a, a, a, 0, pcp);
	       if (pcp->redgen != 0 && pcp->m != 0) 
		  queue[++*queue_length] = pcp->redgen;
	    }
	    if (pcp->overflow || pcp->complete != 0 && !pcp->multiplicator)
	       return;
	 }
      }
   }

   /* process the consistency equations 
      (b^p) a = b^(p - 1) (ba) and b (a^p) = (ba) a^(p - 1) 
      where b > a and WT(b) + WT(a) + 1 = jacobi_wt */

   if (type == 0 || type == 2) {
      for (wta = 1; wta <= bound; ++wta) {

	 /* find range of a */
	 offset = class_end + wta - 1;
	 a_start = y[offset] + 1;
	 a_end = y[++offset];

	 /* find maximum value of b */
	 offset = class_end + jacobi_wt - wta - 2;
	 b_end = y[offset + 1];

	 for (a = a_start; a <= a_end; ++a) {

	    /* ensure b > a */
	    b_start = MAX(y[offset] + 1, a + 1); 
	    for (b = b_start; b <= b_end; ++b) {

	       /* introduce Vaughan-Lee consistency check restriction */
	       if (wta == 1) {
		  /* check if this jacobi relation has already been used
		     in filling in the tail on (b, a)^p */
		  p1 = y[p_pcomm + b];
		  if (y[p1 + a] <= 0 || y[p1 + a] >= pcp->first_pseudo) {
		     compute = (!metabelian || (metabelian && (PART2 
              (y[structure + b]) == 0 || PART3(y[structure + b]) == 0))); 
		     if (compute) {
			jacobi (b, b, a, 0, pcp);
			if (pcp->redgen != 0 && pcp->m != 0) 
			   queue[++*queue_length] = pcp->redgen;
		     }
		     if (pcp->overflow || pcp->complete && !pcp->multiplicator)
			return;
		  }
	       }

	       /* check if this jacobi relation has already been 
		  used in filling in the tail on (b, a^p) */
	       entry = y[p_power + a];
	       if (entry <= 0 || entry >= b) {
		  compute = (!metabelian || (metabelian && (
	  PART2 (y[structure + a]) == 0 || PART3 (y[structure + a]) == 0 ||
          PART2 (y[structure + b]) == 0 || PART3(y[structure + b]) == 0)));
		  if (compute) {
		     jacobi (b, a, a, 0, pcp);
		     if (pcp->redgen != 0 && pcp->m != 0) 
			queue[++*queue_length] = pcp->redgen;
		  }
		  if (pcp->overflow || pcp->complete != 0 && !pcp->multiplicator)
		     return;
	       }
	    }
	 }
      }
   }

   /* process the consistency equations (cb) a = c (ba), where
      c > b > a, WT(a) + WT(b) + WT(c) = jacobi_wt, and WT(a) = 1 */

   if (type == 0 || type == 3) {

      /* first, find maximum values of a and b */
      a_end = y[class_end + 1];
      b_end = y[class_end + ((jacobi_wt - 1) >> 1)];
      constant = class_end + jacobi_wt - 2;

      for (a = 1; a <= a_end; ++a) {
	 for (b = a + 1; b <= b_end; ++b) {

	    /* find range of c and ensure c > b */
	    offset = constant - WT(y[structure + b]);
	    c_start = MAX(y[offset] + 1, b + 1); 
	    c_end = y[++offset]; 

	    /* where possible, avoid redoing those jacobis used to 
	       fill in tails on (c, (b, a)) */
	    if (!metabelian) {
	       p1 = y[p_pcomm + b];
	       if (y[p1 + a] > 0)
		  c_end = MIN(c_end, y[p1 + a]);
	    }

	    for (c = c_start; c <= c_end; ++c) {
	       compute = (!metabelian || (metabelian &&  
   (PART2 (y[structure + b]) == 0 || PART3 (y[structure + b]) == 0 ||
   PART2 (y[structure + c]) == 0 || PART3 (y[structure + c]) == 0)));
	       if (compute) {
		  jacobi (c, b, a, 0, pcp);
		  if (pcp->redgen != 0 && pcp->m != 0) 
		     queue[++*queue_length] = pcp->redgen;
	       }
	       if (pcp->overflow || pcp->complete != 0 && !pcp->multiplicator)
		  return;
	    }
	 }
      }
   }
}

#endif 
