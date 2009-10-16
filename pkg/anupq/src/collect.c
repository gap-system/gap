/****************************************************************************
**
*A  collect.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: collect.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#define MAXEXP two_to_the_n(30) 
#if defined (NEXT) 
#define STACK_SIZE 5000
#endif

void stack_overflow ();
void integer_overflow ();
void add_string ();

/* an exponent vector with base address collected_part 
   is multiplied on the right by a string with base address 
   pointer; the string is assumed to be normal    

   this routine follows the algorithm devised by 
   M.R. Vaughan-Lee for collection from the left; 
   step numbers correspond to step numbers in 
   "Collection from the Left" by M.R. Vaughan-Lee, 
   J. Symbolic Computation (1990) 9, 725-733   
      
   this version embodies a simpler form of combinatorial 
   collection as described on page 733, which lessens the 
   chance of integer overflow; it also incorporates recursion 
   when adding strings and generators to the exponent vector

   during the collection algorithm, pointers to a number of strings 
   are stored on a stack; theoretically, the stack depth could get 
   as large as (p - 1) * pcp->lastg * pcp->cc, but, in practice, depths 
   this large do not arise; however, it could be necessary to increase 
   the dimensions of the stack arrays for some calculations with large 
   groups; STACK_SIZE is the maximum depth of the stack; this constant 
   is declared in the constants header file; overflow is tested in 
   this algorithm

   integer overflow is also tested for, although it can only arise 
   if p^3 > 2^31; if p^2 > 2^31, integer overflow can arise which 
   is not tested for 
   
   if either overflow arises, a message is printed out and 
   the program terminates;
   
   #####################################################################

   note the sections in this code enclosed within  

   #ifndef EXPONENT_P  
   #endif 

   if you insert as part of the header material of this file 
   
   #define EXPONENT_P 

   or supply EXPONENT_P as a -D flag to the compiler, then the 
   resulting collector assumes that all generators of the pcp 
   have order p and does not execute these portions of the code */ 

   /* stack size on Apollo causes problems */

#ifdef APOLLO
   static t_int strstk[STACK_SIZE]; /* string stack */
   static t_int lenstk[STACK_SIZE]; /* length stack */
   static t_int expstk[STACK_SIZE]; /* exponent stack */
#endif

   /* if Lie program, use different collect routine */ 
#if defined (GROUP) 

void collect (pointer, collected_part, pcp)
int pointer;
int collected_part;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int p1;             /* string pointer */
   register int ce;             /* collected exponent */
   register int cg;             /* collected generator */
   register int ug;             /* uncollected generator */
   register int ue;             /* uncollected exponent */
   register int sp = 0;         /* stack pointer */
   register int exp;            /* exponent */
   register int len = 1;        /* length */
   register int str;            /* string pointer */
   register int halfwt;         /* last generator with weight <= cc/2 */
   register int thirdwt;        /* last generator with weight <= cc/3 */
   register int weight_diff;    /* current class - weight of ug */
   register int entry;          /* value to be inserted in collected part */
   register int firstcg;        /* first collected generator for loop counter */
   register int lastcg;         /* last collected generator for loop counter */
   register int maxexp;         /* max exponent allowed in call to add_string */

   register int cp = collected_part;
   register int class_end = pcp->clend; 
   register int current_class = pcp->cc;
   register int prime = pcp->p;
   register int pm1 = pcp->pm1;
   register int p_pcomm = pcp->ppcomm;
   register int p_power = pcp->ppower;
   register int structure = pcp->structure;

#ifndef APOLLO
   int strstk[STACK_SIZE];      /* string stack */
   int lenstk[STACK_SIZE];      /* length stack */
   int expstk[STACK_SIZE];      /* exponent stack */
#endif

   register int i;

#include "access.h"

   /* if prime is 2, use special collector */
   if (prime == 2) {
      collectp2 (pointer, collected_part, pcp);  
      return;
   }

   /* Step (0) --
      initialize collector */

   if (pointer < 0)
      lenstk[0] = y[-pointer + 1];
   else if (pointer == 0)
      return;

   strstk[0] = pointer;
   expstk[0] = 1;

   maxexp = (MAXEXP / prime) * 2;
   halfwt = y[class_end + current_class / 2];
   thirdwt = y[class_end + current_class / 3];

   /* Step (1) -- 
      process next word on stack */

   while (sp >= 0) {

      str = strstk[sp];
      exp = expstk[sp];

      /* check if str is a string or a generator */

      if (str < 0) {
	 /* we have a genuine string */
	 len = lenstk[sp];
	 sp--;

	 /* get first generator exponent pair from string */
	 i = y[-str + 2];
	 ug = FIELD2 (i);

	 /* if ug > halfwt, the string can be added to the
	    collected part without creating any commutators */
	 if (ug > halfwt) {
	    add_string (str, len, exp, cp, pcp);
	    continue;
	 }

	 /* ug <= halfwt and so exp must equal 1; stack remainder of string */
	 ue = FIELD1 (i);
	 if (len != 1) {
	    strstk[++sp] = str - 1;
	    lenstk[sp] = len - 1;
	 }
      }
      else {
	 /* str is a generator */
	 ug = str;
	 ue = exp;
	 sp--;
	 /* if ug > halfwt, ug commutes with all higher generators */
	 if (ug > halfwt) {
	    add_string (ug, 1, ue, cp, pcp);
	    continue;
	 }
      }

      /* ug <= halfwt; if ug > thirdwt, any commutators arising in 
	 collecting ug commute with all generators after ug, so ug 
	 can be collected without stacking up collected part */

      if (ug <= thirdwt) {

	 /* Step (2) --
	    combinatorial collection;
	    scan collected part towards the left;
	    bypass generators we know must commute with ug;
	    when 2 * WT(cg) + WT(ug) > current_class, all generators 
	    occurring in [cg, ug] commute with each other;   
	    [cg^ce, ug] = [cg, ug]^ce;
	    if cg1,..., cgk all satisfy this weight condition then
	    [cg1 * ... * cgk, ug] = [cg1, ug] ... [cgk, ug] */
      
	 if (ue != 1) {
	    /* we only move one ug at a time; stack ug^(ue - 1) */
	    if (++sp >= STACK_SIZE)
	       stack_overflow ();
	    strstk[sp] = ug;
	    expstk[sp] = ue - 1;
	    ue = 1;
	 }

	 weight_diff = current_class - WT(y[structure + ug]);
	 firstcg = y[class_end + weight_diff];
	 lastcg = y[class_end + weight_diff / 2];

	 /* scan collected part to the left, bypassing generators
	    which must commute with ug; the collected part between 
	    lastcg and firstcg contains a word w; we add in [w, ug] */

	 for (cg = firstcg; cg > ug; cg--) {
	    ce = y[cp + cg];
	    if (ce != 0) {
	       /* add [cg, ug]^ce to the collected part */
	       p1 = y[p_pcomm + cg] + ug;
	       p1 = y[p1];
	       if (p1 != 0) {
		  if (cg <= lastcg)
		     break;
		  if (p1 < 0)
		     len = y[-p1 + 1];
		  add_string (p1, len, ce, cp, pcp);
	       }
	    }
	 }

	 if (cg == ug) {
	    /* we have reached ug position during combinatorial
	       collection; add 1 to ug entry of collected part 
	       without stacking any entries if appropriate */
	    if (y[cp + ug] == pm1) {
	       if (y[p_power + ug] == 0) {
		  y[cp + ug] = 0;
		  continue;
	       }
	    }
	    else {
	       ++y[cp + ug];
	       continue;
	    }
	 }

	 /* we have now added in [w, ug]; stack up
	    collected part between firstcg and cg + 1 */
	 for (i = firstcg; i > cg; i--) {
	    ce = y[cp + i];
	    if (ce != 0) {
	       y[cp + i] = 0;
	       if (++sp >= STACK_SIZE)
		  stack_overflow ();
	       strstk[sp] = i;
	       expstk[sp] = ce;
	    }
	 }

	 /* Step (3) --
	    ordinary collection; we have moved ug to the cg position;  
	    continue scanning to the left */
	 for (; cg > ug; cg--) {
	    ce = y[cp + cg];
	    if (ce != 0) {
	       /* zero the cg entry of collected part */
	       y[cp + cg] = 0;

	       /* get [cg, ug] */
	       p1 = y[p_pcomm + cg] + ug;
	       p1 = y[p1];
	       if (p1 == 0) {
		  /* cg commutes with ug so stack cg^ce */
		  if (++sp >= STACK_SIZE)
		     stack_overflow ();
		  strstk[sp] = cg;
		  expstk[sp] = ce;
	       }
	       else {
		  /* cg does not commute with ug;
		     we can only move ug past one cg at a time; 
		     stack [cg, ug] and then cg a total of ce times */

		  if (sp + ce + ce >= STACK_SIZE)
		     stack_overflow ();
		  if (p1 < 0)
		     len = y[-p1 + 1];

		  for (; ce > 0; --ce) {
		     strstk[++sp] = p1;
		     lenstk[sp] = len;
		     expstk[sp] = 1;
		     strstk[++sp] = cg;
		     expstk[sp] = 1;
		  }
	       }
	    }
	 }

	 /* we have moved ug to the correct position;  
	    add 1 to the ug entry of collected part */
	 add_string (ug, 1, 1, cp, pcp);
	 continue;
      }                         /* ug <= thirdwt */

      /* Step (6) -- ug > thirdwt;
	 move ug^ue past entries in the collected part, adding
	 commutators directly to the collected part;
	 scan collected part towards the left, bypassing generators
	 we know must commute with ug; if the cg position in
	 the collected part contains an entry ce then this
	 represents cg^ce;  [cg^ce, ug^ue] = [cg, ug]^(ce * ue),
	 and we add the ce * ue power of [cg, ug] directly to
	 the collected part */

      weight_diff = current_class - WT(y[structure + ug]);
      firstcg = y[class_end + weight_diff];

      for (cg = firstcg; cg > ug; cg--) {
	 ce = y[cp + cg];
	 if (ce != 0) {
	    /* add [cg, ug]^(ce * ue) directly to the collected part */
	    p1 = y[p_pcomm + cg];
	    p1 = y[p1 + ug];
	    if (p1 != 0) {
	       exp = ce * ue;
	       if (exp > maxexp)
		  integer_overflow ();
	       if (p1 < 0)
		  len = y[-p1 + 1];
	       add_string (p1, len, exp, cp, pcp);
	    }
	 }
      }

      /* add ue to the ug entry of collected part */
      entry = y[cp + ug] + ue;
      if (entry < prime) {
	 y[cp + ug] = entry;
	 continue;
      }
      else {
	 y[cp + ug] = entry - prime;
	 p1 = y[p_power + ug];
	 if (p1 == 0)
	    continue;
      }

      /* adding ue to the ug entry has created an entry >= prime;   
	 we have to stack some of collected part */
      for (cg = firstcg; cg > ug; cg--) {
	 ce = y[cp + cg];
	 if (ce != 0) {
	    /* set entry to zero and stack cg^ce */
	    y[cp + cg] = 0;
	    if (++sp >= STACK_SIZE)
	       stack_overflow ();
	    strstk[sp] = cg;
	    expstk[sp] = ce;
	 }
      }

      /* add in ug^p; p1 is a pointer to ug^p */
      if (p1 < 0)
	 len = y[-p1 + 1];
      add_string (p1, len, 1, cp, pcp);
      continue;
   }

}

#endif /* GROUP*/

/* add exponent times the string with address string and length length
   directly to the collected part with base address collected_part, 
   recursively adding powers as required */

void add_string (string, length, exponent, collected_part, pcp)
int string;
int length;
int exponent;
int collected_part;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int cp = collected_part;
   register int exp = exponent;
   register int len = length;
   register int str = string;
   register int entry;
   register int ug;
   register int ue;
   register int power;

   register int class_begin = pcp->ccbeg;
   register int prime = pcp->p;
   register int p_power = pcp->ppower;

   register int i;
   int lower, upper;
#include "access.h"

   if (str > 0) {
      /* Step (4) --
	 we have moved generator str to the correct position;
	 add exp to the str entry of the collected part;
	 reduce entry modulo p and add a power of str^p
	 to the collected part if necessary */

      entry = y[cp + str] + exp;
      y[cp + str] = entry % prime;
      if (str < class_begin) {
	 exp = entry / prime;
#ifndef EXPONENT_P
	 if (exp != 0) {
	    /* we need to recursively add in (str^p)^exp */
	    str = y[p_power + str];
	    if (str != 0) {
	       if (str < 0)
		  len = y[-str + 1];
	       add_string (str, len, exp, cp, pcp);
	    }
	 }
#endif
      }
   }
   else {
      /* Step (5) --
	 add string with base address -str and length len 
	 directly to the collected part exp times; if this 
	 creates an entry >= prime we reduce the entry modulo 
	 prime and add in the appropriate power */

      lower = -str + 2;
      upper = -str + len + 1;

      /* get one generator exponent pair at a time from string */

      for (i = lower; i <= upper; i++) {
	 ug = FIELD2 (y[i]);
	 ue = FIELD1 (y[i]) * exp;
	 entry = y[cp + ug] + ue;

	 /* add ue to ug entry of the collected part and reduce mod p */
	 y[cp + ug] = entry % prime;

#ifndef EXPONENT_P
	 /* we need to recursively add in (ug^p)^power */
	 if (ug < class_begin) {
	    power = entry / prime;
	    if (power != 0) {
	       str = y[p_power + ug];
	       if (str != 0) {
		  if (str < 0)
		     len = y[-str + 1];
		  add_string (str, len, power, cp, pcp);
	       }
	    }
	 }
#endif
      }
   }
}

/* stack is not big enough */

void stack_overflow ()
{
   printf ("Stack overflow in collection routine; you should increase\n");
   printf ("value of STACK_SIZE in constants.h and recompile.\n");
   exit (FAILURE);
}

/* arithmetic overflow */

void integer_overflow ()
{
   printf ("Arithmetic overflow may occur in collection ");
   printf ("routine. Results may be invalid.\n");
   exit (FAILURE);
}
