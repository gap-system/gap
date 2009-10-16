/****************************************************************************
**
*A  collectp2.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: collectp2.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#if defined (NEXT)
#define STACK_SIZE 5000
#endif

void add_p2string ();

/* collection procedure for the prime 2; 
   this routine is documented in the file collect.c */

void collectp2 (pointer, collected_part, pcp)
int pointer;
int collected_part;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int p1;             /* string pointer */
   register int cg;             /* collected generator */
   register int ug;             /* uncollected generator */
   register int sp = 0;         /* stack pointer */
   register int len = 1;        /* length */
   register int str;            /* string pointer */
   register int halfwt;         /* last generator with weight <= cc/2 */
   register int weight_diff;    /* current class - weight of ug */
   register int firstcg;        /* first collected generator for loop counter */
   register int lastcg;         /* last collected generator for loop counter */

   register int cp = collected_part;
   register int class_end = pcp->clend; 
   register int current_class = pcp->cc;
   register int p_pcomm = pcp->ppcomm;
   register int p_power = pcp->ppower;
   register int structure = pcp->structure;

   int strstk[STACK_SIZE];      /* string stack */
   int lenstk[STACK_SIZE];      /* length stack */

   register int i;

#include "access.h"

   /* Step (0) --
      initialize collector */

   if (pointer < 0)
      lenstk[0] = y[-pointer + 1];
   else if (pointer == 0)
      return;

   halfwt = y[class_end + current_class / 2];
   strstk[0] = pointer;

   /* Step (1) -- 
      process next word on stack */

   while (sp >= 0) {
      str = strstk[sp];
      if (str < 0) {
	 /* we have a genuine string */
	 len = lenstk[sp];
	 sp--;

	 /* get first generator from string */
	 i = y[-str + 2];
	 ug = FIELD2 (i);
	 /* if ug > halfwt, whole string can be added to the  
	    collected part without creating any commutators */
	 if (ug > halfwt) {
	    add_p2string (str, len, cp, pcp);
	    continue;
	 }

	 if (len != 1) {
	    /* stack remainder of string */
	    strstk[++sp] = str - 1;
	    lenstk[sp] = len - 1;
	 }
      }
      else {
	 /* str is a generator */
	 ug = str;
	 sp--;
	 /* if ug > halfwt, ug commutes with all higher generators */
	 if (ug > halfwt) {
	    add_p2string (ug, 1, cp, pcp);
	    continue;
	 }
      }

      /* Step (2) --
	 combinatorial collection;
	 move ug past entries in the collected part, adding
	 commutators directly to the collected part;
	 if 2 * WT(cg) + WT(ug) > current_class then [cg, ug] 
	 commutes with all generators k such that k >= cg;
	 scan collected part towards the left, bypassing 
	 generators we know must commute with ug */

      weight_diff = current_class - WT(y[structure + ug]);
      firstcg = y[class_end + weight_diff];
      lastcg = y[class_end + weight_diff / 2];

      for (cg = firstcg; cg > ug; cg--) {
	 if (y[cp + cg] != 0) {
	    /* add [cg, ug] directly to the collected part */
	    p1 = y[p_pcomm + cg];
	    p1 = y[p1 + ug];
	    if (p1 != 0) {
	       if (cg <= lastcg)
		  break;
	       if (p1 < 0)
		  len = y[-p1 + 1];
	       add_p2string (p1, len, cp, pcp);
	    }
	 }
      }

      if (cg == ug) {
	 /* we have reached the ug position during combinatorial collection;
	    check whether we can avoid stacking collected part */
	 if (y[cp + ug] == 0) {
	    y[cp + ug] = 1;
	    continue;
	 }
	 else {
	    if (y[p_power + ug] == 0) {
	       y[cp + ug] = 0;
	       continue;
	    }
	 }
      }

      /* we do have to stack some of the collected part */
      for (i = firstcg; i > cg; i--) {
	 if (y[cp + i] != 0) {
	    /* set entry to zero and stack i */
	    y[cp + i] = 0;
	    if (++sp >= STACK_SIZE)
	       stack_overflow ();
	    strstk[sp] = i;
	 }
      }

      /* Step (3) --
	 ordinary collection; continue scanning towards the left,
	 stacking up commutators and entries in collected part 
	 until we reach ug position */

      for (; cg > ug; cg--) {
	 if (y[cp + cg] != 0) {
	    /* zero the cg entry of collected part */
	    y[cp + cg] = 0;
	    /* get [cg, ug] */
	    p1 = y[p_pcomm + cg];
	    p1 = y[p1 + ug];

	    /* move ug past cg stacking [cg, ug] and cg */
	    if (sp + 2 >= STACK_SIZE)
	       stack_overflow ();
	    if (p1 != 0) {
	       /* stack [cg, ug] if it is non-trivial */
	       strstk[++sp] = p1;
	       if (p1 < 0)
		  lenstk[sp] = y[-p1 + 1];
	    }

	    /* stack cg */
	    strstk[++sp] = cg;
	 }
      }

      add_p2string (ug, 1, cp, pcp);
      continue;
   }
}

/* prime = 2;
   add the string with address string and length length
   directly to the collected part with base address collected_part, 
   recursively adding powers as required */

void add_p2string (string, length, collected_part, pcp)
int string;
int length;
int collected_part;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int cp = collected_part;
   register int str = string;
   register int len = length;
   register int ug;

   register int class_begin = pcp->ccbeg;
   register int p_power = pcp->ppower;

   register int i;
   int lower, upper;
#include "access.h"

   if (str > 0) {
      /* Step (4) --
	 we have moved generator str to the correct position;  
	 add 1 to the str entry of the collected part; reduce 
	 entry modulo 2 and add str^2 to collected part if necessary */

      if (y[cp + str] == 0)
	 y[cp + str] = 1;
      else {
	 /* we need to recursively add in str^2 */
	 y[cp + str] = 0;
	 if (str < class_begin) {
	    str = y[p_power + str];
	    if (str != 0) {
	       if (str < 0)
		  len = y[-str + 1];
	       add_p2string (str, len, cp, pcp);
	    }
	 }
      }
   }
   else {
      /* Step (5) --
	 add string with base address -str and length len directly
	 to the collected part; if this creates an entry >= 2, reduce 
	 entry modulo 2 and recursively add in the appropriate power */

      lower = -str + 2;
      upper = -str + len + 1;

      /* get one generator exponent pair at a time from string */

      for (i = lower; i <= upper; i++) {
	 ug = FIELD2 (y[i]);
	 if (y[cp + ug] == 0)
	    y[cp + ug] = 1;
	 else {
	    y[cp + ug] = 0;
	    if (ug < class_begin) {
	       /* we need to recursively add in ug^2 */
	       str = y[p_power + ug];
	       if (str != 0) {
		  if (str < 0)
		     len = y[-str + 1];
		  add_p2string (str, len, cp, pcp);
	       }
	    }
	 }
      }
   }
}
