/****************************************************************************
**
*A  print_presentation.c        ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: print_presentation.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* print relationship between group defining generators and 
   consistent power-commutator presentation generators */

void print_map (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   int ndgen = pcp->ndgen;
   int dgen = pcp->dgen;
   int p2;
   int i;

#if defined (LIE)
   printf ("\nRelationship between ring defining generators and ");
   printf ("consistent\nproduct presentation generators: \n");
#endif 
#if defined (GROUP)
   printf ("\nRelationship between group defining generators and ");
   printf ("consistent\npower-commutator presentation generators:\n");
#endif 

   for (i = 1; i <= ndgen; i++) {
      p2 = y[dgen + i];
      printf ("%d", i);
      printf ("  ");
      printf ("  =");
      print_word (p2, pcp);
      p2 = y[dgen - i];
      if (p2 <= 0) {
	 printf ("%d", i);
	 printf ("^-1 =");
	 print_word (p2, pcp);
      }
   }
}

/* print the pcp presentation of the group; if full output, print 
   non-trivial power and commutator relations; if diagnostic output, 
   also print relationship and structure information */

void print_presentation (full, pcp)
Logical full;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int k;
   register int l;
   register int length;

   register int relp = pcp->relp;
   register int ndrel = pcp->ndrel;
   register int gen, pointer;   

   Logical commutator_relation;

   char *s;

#if defined (LIE) 
   printf ("\nRing: %s to lower central class %d has order %d^%d\n",
	   pcp->ident, pcp->cc, pcp->p, pcp->lastg);
#endif 
#if defined (GROUP)
   printf ("\nGroup: %s to lower exponent-%d central class %d has order %d^%d\n", 
	   pcp->ident, pcp->p, pcp->cc, pcp->p, pcp->lastg);
#endif

   if (!full) return;

   if (pcp->diagn) {

      /* print out the defining relations of the group */
    
#if defined (GROUP) 
      s = "Group";
#endif
#if defined (LIE) 
      s = "Ring";
#endif
      if (pcp->ndrel != 0)
	 printf ("\n%s defining relations:\n", s);
      for (k = 1; k <= ndrel; ++k) {
	 for (l = 1; l <= 2; ++l) {
	    i = (k - 1) * 2 + l;
	    pointer = y[relp + i];
	    commutator_relation = (y[pointer] < 0);
	    length = abs (y[pointer]);
	    if (length == 0)
	       printf ("0");
	    else
	       printf ("%d", y[pointer + 1]);
	    if (commutator_relation)
	       printf (" [");
	    for (i = 2; i <= length; ++i) {
	       gen = y[pointer + i];
	       printf (" %d", gen);
	    }
	    if (commutator_relation)
	       printf (" ]");
	    printf ("\n");
	 }
	 printf ("\n");
      }

      /* print map from defining generators to pcp generators */
      print_map (pcp);

#if defined (LIE)
      printf ("\nValues of product presentation generators\n");
#endif 
#if defined (GROUP)
      printf ("\nValues of power-commutator presentation generators\n");
#endif
      print_structure (1, pcp->lastg, pcp);
   }

   if (pcp->cc != 1) 
      print_pcp_relations (pcp);
}

/* print out non-trivial pcp relations */

void print_pcp_relations (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int j;
   register int k;
   register int l;
   register int p1;
   register int p2;
   register int weight;

#include "access.h"

   k = y[pcp->clend + pcp->cc - 1];
   /*
     int start, finish;
     printf ("input start, finish: ");
     scanf ("%d %d", &start, &finish);
     */

#if defined (GROUP)
   printf ("\nNon-trivial powers:\n");
   /*
     for (i = start; i <= finish; i++) {
     */
   for (i = 1; i <= k; i++) {
      p2 = y[pcp->ppower + i];
      if (p2 != 0) {
	 printf (" .%d^%d =", i, pcp->p);
	 print_word (p2, pcp);
      }
   }

   printf ("\nNon-trivial commutators:\n");
#endif
#if defined (LIE)
   printf ("\nNon-trivial products:\n");
#endif   

   /*
     for (i = start; i <= finish; i++) {
     */
   for (i = 2; i <= k; i++) {
      weight = WT(y[pcp->structure + i]);
      p1 = y[pcp->ppcomm + i];
      l = MIN(i - 1, y[pcp->clend + pcp->cc - weight]);
      for (j = 1; j <= l; j++) {
	 p2 = y[p1 + j];
	 if (p2 != 0) {
	    printf ("[ .%d, .%d ] =", i, j);
	    print_word (p2, pcp);
	 }
      }
   }
}
