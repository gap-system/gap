/****************************************************************************
**
*A  tails.c                     ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: tails.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

#define BOTH_TAILS 0 
#define NEW_TAILS 1
#define COMPUTE_TAILS 2

/* introduce tails for the class work_class part of class pcp->cc */ 

void tails (type, work_class, start_weight, end_weight, pcp)
int type;
int work_class;
int start_weight;
int end_weight;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int structure = pcp->structure;
   register int class_end = pcp->clend;
   register int lastg = pcp->lastg;
   register int current_class = pcp->cc;
   register int nmr_at_start = pcp->lastg;
   register int final_class = work_class - 1;
   register int start = y[class_end + final_class - 1] + 1;
   register int end   = y[class_end + final_class];
   register int f, ff;

   register int s, bound;

   register int value;
   register int p1;
   Logical equal = FALSE;
#include "access.h"

   if (pcp->complete != 0 && !pcp->multiplicator)
      return;

   if (type == NEW_TAILS || type == BOTH_TAILS) {

      /* first, introduce left-normed commutators of class 
	 work_class as generators or pseudo-generators */

      for (f = start; f <= end; f++) {
	 bound = MIN(f - 1, y[class_end + 1]);
	 if (bound > 0) {
	    p1 = y[pcp->ppcomm + f];
	    for (s = 1; s <= bound; s++) {
	       value = y[p1 + s];
	       if (value == 0)  
		  /* we are inserting generators or pseudo-generators with 
		     old entry trivial; if we are inserting pseudo-generators 
		     we do not insert one if (f, s) is defining */
		  create_tail (p1 + s, f, s, pcp);
	       else if (value < 0)  
		  /* old entry was non-trivial so we deallocate it 
		     and insert pseudo-generator */
		  extend_tail (p1 + s, f, s, pcp);
	       if (pcp->overflow)
		  return;
	       lastg = pcp->lastg;
	    }
	 }
      }

#if defined (GROUP) 
#ifndef EXPONENT_P 
      /* now, introduce pth powers of final_class generators which
	 are pth powers or correspond to defining generators */

      if (final_class == 1)
	 ff = 1;
      else {
	 ff = end;
	 while (PART3 (y[structure + ff]) == 0 && --ff >= start)
	    ;
	 if (ff != end)
	    ++ff;
	 else
	    equal = TRUE;
      }

      if (!equal) {
	 for (f = ff; f <= end; f++) {
	    /* f is a pth power or corresponds to a defining generator;
	       if we are inserting pseudo-generators, we do not insert 
	       one if f^p is defining */
	    value = y[pcp->ppower + f];
	    if (value == 0)  
	       /* we are inserting generators or pseudo-generators 
		  with old entry trivial */
	       create_tail (pcp->ppower + f, f, 0, pcp);
	    else if (value < 0)  
	       /* old entry was non-trivial so we deallocate it 
		  and insert pseudo-generator */
	       extend_tail (pcp->ppower + f, f, 0, pcp);
	    if (pcp->overflow)
	       return;
	    lastg = pcp->lastg;
	 }
      }
#endif 
#endif 

   }

   if (type == COMPUTE_TAILS || type == BOTH_TAILS) {

      /* calculate pth powers of class final_class generators which
	 are commutators by doing the appropriate collections */
      if (final_class != 1)  
	 calculate_tails (final_class, start_weight, end_weight, pcp);
      if (pcp->overflow)
	 return;
   }

   pcp->submlg = pcp->subgrp - lastg;

   if (work_class == current_class) {
      /* note first pseudo-generator and number of actual generators */
      pcp->first_pseudo = lastg + 1;
      pcp->newgen = pcp->first_pseudo - pcp->ccbeg;
   }

   /* report on the number of new generators added */
   if ((pcp->fullop || pcp->diagn) && type != COMPUTE_TAILS)
      printf ("The number of new generators introduced for weight %d is %d\n", 
	      work_class, pcp->lastg - nmr_at_start);
}

#if !defined (TAILS_FILTER)

/* calculate pth powers of class final_class generators which
   are commutators by doing the appropriate collections */

void calculate_tails (final_class, start_weight, end_weight, pcp) 
int final_class;
int start_weight;
int end_weight;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int structure = pcp->structure;
   register int class_end = pcp->clend;

   register int f;
   register int start = y[class_end + final_class - 1] + 1;
   register int end   = y[class_end + final_class];

   register int s, s1, s2;
   register int start_class = 1;

   register int a, b;
   register int value;
   register int p1;

#include "access.h"

#if defined (GROUP)

   if (pcp->fullop || pcp->diagn) 
      printf ("Processing tails for generators of weight %d and %d\n", 
	      final_class, 1);

   for (f = start; f <= end; f++) {

#ifdef DEBUG
      printf ("Processing generator f = %d, Lused = %d\n", f, pcp->lused);
#endif
      value = y[structure + f];
      a = PART3 (value);
      if (a == 0)
	 break;
      b = PART2 (value);
      
      /* f is the commutator (b, a);
	 calculate the class current_class part of f^p by collecting 
	 (b^p) a = b^(p-1) (ba); by formal collection, we see that 
	 the class current_class part of f^p is obtained by subtracting 
	 (modulo p) the rhs of the above equation from the lhs */

      jacobi (b, b, a, pcp->ppower + f, pcp);
      if (pcp->overflow)
	 return;
   }
#endif

#if defined (LIE) 
   final_class = MIN (start_weight + 1, final_class);
   start_class = MAX (pcp->cc - final_class, 1);
#endif

   /* calculate the non left-normed commutators of class work_class 
      in the order (work_class - 2, 2), (work_class - 3, 3) .. */

   class_end = pcp->clend;
   while (--final_class >= ++start_class) {
      
#if defined (LIE) 
      if (final_class < end_weight) return;
#endif

      if (pcp->fullop || pcp->diagn) 
	 printf ("Processing tails for generators of weight %d and %d\n", 
		 final_class, start_class);

      start = y[class_end + final_class - 1] + 1;
      end = y[class_end + final_class];
      s1 = y[class_end + start_class - 1] + 1;

      for (f = start; f <= end; f++) {
#ifdef DEBUG
	 printf ("Processing generator f = %d, Lused = %d\n", f, pcp->lused);
#endif
	 s2 = MIN(f - 1, y[class_end + start_class]);
	 if (s2 - s1 < 0)
	    continue;
	 p1 = y[pcp->ppcomm + f];
	 for (s = s1; s <= s2; s++) {
	    /* insert the class current_class part on (f, s) */
	    value = y[structure + s];
	    b = PART2 (value);
	    a = PART3 (value);
	    if (a == 0)  
	       a = b;
	    else if (pcp->metabelian && PART3 (y[structure + f]) != 0)
	       continue;
               
	    /* s = (b, a); calculate the class current_class part 
	       of (f, (b, a)) by collecting (fb) a = f (ba) or the 
	       class current_class part of (f, (b^p)) by collecting 
	       (fb) b^(p - 1) = f (b^p);
	       since we require only the class current_class part - 
	       the rest has been computed earlier -  we calculate it 
	       by subtracting (modulo p) the rhs of the above equation 
	       from the lhs (proof by formal collection) */

	    jacobi (f, b, a, p1 + s, pcp);
	    if (pcp->overflow)
	       return;
	 }
      }
   }
}

#endif

/* insert a new generator or pseudo-generator */

void create_tail (address, f, s, pcp)
int address, f, s;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int bound;
   register int lastg; 

   register int lused = pcp->lused;
   register int structure = pcp->structure;
   register int current_class = pcp->cc;
   register int pointer;

#include "access.h"

   pcp->lastg++;
   lastg = pcp->lastg;
   y[address] = lastg;
   y[structure + lastg] = PACK3 (0, f, s) + INSWT (current_class);

   if (pcp->nocset == 0)
      return;
            
   /* work out the number of occurrences of each defining generator 
      in the new generator, storing this in a table above 
      y[lused + current_class] -- the entry y[lused + current_class + gen] 
      is the number of occurrences of defining generator gen */

   if (is_space_exhausted (current_class + pcp->ndgen, pcp)) 
      return;

   lused = pcp->lused;
   pointer = find_definition (lastg, lused, current_class, pcp);
   for (i = 1, bound = pcp->ndgen; i <= bound; i++)
      y[lused + current_class + i] = 0;
   for (i = pointer, bound = lused + current_class; i <= bound; i++)  
      ++y[lused + current_class + y[i]];

   /* see that the number of occurrences of a defining generator 
      passes some test that has been set up in option */
   if (is_genlim_exceeded (pcp))
      return;
            
   /* the test wasn't passed, so we discard the new generator */
   pcp->lastg--;
   y[address] = 0;
}

/* insert a new pseudo-generator, where the old 
   entry was non-trivial and must be deallocated */

void extend_tail (address, f, s, pcp)
int address, f, s;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int start;
   register int length;
   register int lastg; 
   register int lused;
   register int current_class = pcp->cc;

#include "access.h"

   if (is_space_exhausted (pcp->ccbeg + 1, pcp))
      return;

   lused = pcp->lused;
   start = -y[address];
   length = y[start + 1];
            
   /* set up new header block with length increased by 1 */
   y[lused + 1] = y[start];
   y[lused + 2] = length + 1;
           
   /* set up pointer to new block */
   y[address] = -(lused + 1);
            
   /* deallocate old block by setting its pointer to 0 */
   y[start] = 0;
            
   /* copy old entry across */
   for (i = 1; i <= length; i++)
      y[lused + 2 + i] = y[start + i + 1];

   pcp->lused += length + 3;
   lused = pcp->lused;

   /* add pseudo-generator */
   pcp->lastg++;
   lastg = pcp->lastg;
   y[lused] = PACK2 (1, lastg);
   y[pcp->structure + lastg] = PACK3 (0, f, s) + INSWT (current_class);
}
