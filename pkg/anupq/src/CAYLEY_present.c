/****************************************************************************
**
*A  CAYLEY_present.c            ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: CAYLEY_present.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"

void print_cayley_word ();

int CAYLEY_countcall = 0;

/* print the power and commutator relations in CAYLEY format so 
   that the file can be used as input to the CAYLEY pquotient command */

void CAYLEY_presentation (file, pcp)
FILE_TYPE file;
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

   fprintf (file, "F = free (");
   for (i = 1; i < pcp->lastg; ++i) {
      fprintf (file, "x%d, ", i); 
      if (i % 15 == 0) 
	 fprintf (file, "\n");
   }
   fprintf (file, "x%d);\n", i); 
   fprintf (file, "f.relations:\n");

   k = y[pcp->clend + pcp->cc - 1];

   for (i = 1; i <= k; i++) {
      p2 = y[pcp->ppower + i];
      fprintf (file, " x%d^%d =", i, pcp->p);
      print_cayley_word (file, p2, pcp);
      fprintf (file, ",\n");
   }

   for (i = 2; i <= k; i++) {
      weight = WT(y[pcp->structure + i]);
      p1 = y[pcp->ppcomm + i];
      l = MIN(i - 1, y[pcp->clend + pcp->cc - weight]);
      for (j = 1; j <= l; j++) {
	 p2 = y[p1 + j];
	 fprintf (file, "(x%d, x%d) =", i, j);
	 print_cayley_word (file, p2, pcp);
	 if (i == k && j == l)
	    fprintf (file, ";\n");
	 else
	    fprintf (file, ",\n");
      }
   }

   fprintf (file, "G = nilpotent quotient (F, %d, %d; ", pcp->p, pcp->cc);
   if (pcp->extra_relations != 0) 
      fprintf (file, "explaw = %d, ", pcp->extra_relations);
   fprintf (file, "pr = 0);\n");
}

/* write CAYLEY library file in form suitable for reading into CAYLEY */

void write_CAYLEY_library (file, pcp)
FILE_TYPE file;
struct pcp_vars *pcp;
{
   if (CAYLEY_countcall == 0)
      fprintf (file, "GroupList = empty;\n");

   CAYLEY_countcall++;

   CAYLEY_presentation (file, pcp);

   fprintf (file, "GroupList[Length (GroupList) + 1] = G;\n");

   /* special lines -- replace by whatever computation is desired */
   /*
     fprintf (file, "j = jennings series (g);\n");
     fprintf (file, "print j;\n");
     */
   fprintf (file, "delete F;\n");
}

/* print out a word of a pcp presentation in CAYLEY format */

void print_cayley_word (file, ptr, pcp)
FILE_TYPE file;
int ptr;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int gen, exp;
   register int i;
   register int count;
   register int length;
#include "access.h"

   if (ptr == 0)
      fprintf (file, " 1");
   else if (ptr > 0)
      fprintf (file, " x%d", ptr);
   else {
      length = 0; 
      ptr = -ptr + 1;
      count = y[ptr];
      for (i = 1; i <= count; i++) {
	 exp = FIELD1 (y[ptr + i]);
	 gen = FIELD2 (y[ptr + i]);
	 fprintf (file, " x%d", gen);
	 length += 4;
	 if (exp != 1) {
	    fprintf (file, "^%d", exp);
	    length += 3;
	 }
	 if (i != count) {
	    fprintf (file, " *");
	    length += 2;
	    if (length >= 70) {
	       length = 0;
	       fprintf (file, "\n");
	    }
	 }
      }
   }
}
