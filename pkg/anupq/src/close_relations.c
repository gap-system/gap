/****************************************************************************
**
*A  close_relations.c           ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: close_relations.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "pq_functions.h"
#define SORT_FACTOR 25

/* close a queue of relations under the action of the automorphisms;

   each of length entries in the queue is a pointer to 
   a relation of the sort

          x = y1^a1 ... yq^aq 
         
   where each of x and y<i> are among the new generators introduced;
   apply automorphism alpha to this relation and rewrite to obtain 

           (y1^a1 ... yq^aq)<alpha> * x<alpha>^-1 = identity

   this new relation is now echelonised */

void close_relations (report, limit, queue_type, head, list, queue, 
                      length, long_queue, long_queue_length, pcp)
Logical report;
int limit;
int queue_type;
int *head;
int *list;
int *queue;
int length;
int *long_queue;
int *long_queue_length;
struct pcp_vars *pcp;
{
#include "define_y.h"

   char *s;
   char *t;
   int nmr_reds = 0;

   int current = 1;
   int gen;

   int relation_length;
   int generator, exponent;

   register int offset;

   int *copy;

   int alpha, i;
   int cp, p1;
   int start = y[pcp->clend + pcp->cc - 1] + 1;
   int prime = pcp->p;
   int pm1 = pcp->pm1;
#include "access.h"

   while (current <= length) {
   
      gen = queue[current];
      ++current;

      if (gen == 0) continue;

      if (current % SORT_FACTOR == 1) {
	 copy = queue + current - 1;
	 bubble_sort (copy, length - current + 1, pcp);
      }
        
      /* apply automorphism alpha to the relation */
      for (alpha = 1; alpha <= pcp->m; ++alpha) {

	 if (is_space_exhausted (2 * pcp->lastg, pcp)) {
	    pcp->overflow = TRUE;
	    return;
	 }

	 cp = pcp->lused; 
	 for (i = 1; i <= 2 * pcp->lastg; ++i)
	    y[cp + i] = 0;
        
	 offset = (alpha - 1) * pcp->lastg;
         
	 /* is the relation trivial? */
	 if (y[pcp->structure + gen] == 0)  
	    traverse_list (1, head[offset + gen], list, cp, pcp);
	 else {
	    /* the relation was non-trivial; first, set up (gen<alpha>)^-1 */
	    traverse_list (pm1, head[offset + gen], list, cp, pcp);

	    /* now apply the automorphism to each entry of 
	       the string pointed to by y[pcp->structure + gen] */
             
	    p1 = -y[pcp->structure + gen];
	    relation_length = y[p1 + 1];

	    if (queue_type == 1 && relation_length > limit) {
	       long_queue[++*long_queue_length] = gen;
	       break;
	    }

	    for (i = 1; i <= relation_length; ++i) {
	       generator = FIELD2 (y[p1 + 1 + i]);
	       exponent  = FIELD1 (y[p1 + 1 + i]);
	       traverse_list (exponent, head[offset + generator], list, cp, pcp);
	    }

	    /* now reduce the entries mod p */
	    for (i = start; i <= pcp->lastg; ++i)
	       y[cp + i] %= prime;
	 }

	 relation_length = echelon (pcp);
	 if (pcp->complete)  
	    return;

	 /* if appropriate, add a new relation to the queue */
	 if (pcp->eliminate_flag) {
	    ++nmr_reds;
	    if (relation_length <= limit || queue_type == 2)
	       queue[++length] = pcp->redgen;
	    if (relation_length > limit || queue_type == 2)
	       long_queue[++*long_queue_length] = pcp->redgen;
	 }
      }
   }

   if (report || pcp->fullop || pcp->diagn) {
      if (queue_type == 1) s = "Short"; else s = "Long";
      if (nmr_reds == 1) t = "y"; else t = "ies"; 
      printf ("%s queue gave %d redundanc%s\n", s, nmr_reds, t);
   }
}

/* add exponent times the action of automorphism with pointer head
   to the contents of the exponent-vector with base address cp */
   
void traverse_list (exponent, head, list, cp, pcp)
int exponent;
int head;
int *list;
int cp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int value;
   register int length = list[++head];
#include "access.h"

   while (length != 0) {
      value = list[head + length];
      y[cp + FIELD2 (value)] += FIELD1 (value) * exponent;
      --length;
   }
}
