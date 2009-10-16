/****************************************************************************
**
*A  invert.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: invert.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "word_types.h"

/* this procedure multiplies the exponent vector with 
   address cp by gen^(-exp), where gen is a pcp-generator 
   and exp is a positive integer in the range 0 to p */

void invert_generator (gen, exp, cp, pcp)
int gen;
int exp;
int cp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int inverse;
   register int entry;
   register int lastg = pcp->lastg; 
   register int cp1 = pcp->submlg;
   register int p = pcp->p;

#include "access.h"

   /* each call to collect involves a string of length 1;
      reserve two positions below y[pcp->submlg] for this */
   inverse = cp1 - 2;
   y[inverse + 1] = 1;

   /* set up gen^exp as an exponent vector with base address cp1 */
   for (i = 1; i <= lastg; ++i)
      y[cp1 + i] = 0;
   y[cp1 + gen] = exp;

   /* now calculate the inverse, storing the result at cp */
   for (i = gen; i <= lastg; ++i) {
      entry = y[cp1 + i];
      if (entry != 0) {
	 y[inverse + 2] = PACK2 (p - entry, i);
	 collect (-inverse, cp, pcp);
	 collect (-inverse, cp1, pcp);
      }
   }
}

/* calculate the inverse of the string with base address 
   y[str], using the collected part referenced by cp */

void invert_string (str, cp, pcp)
int str;
int cp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int length;
   register int gen, exp;
#include "access.h"

   for (length = abs (y[str + 1]); length > 0; --length) {
      gen = FIELD2 (y[str + length]);
      exp = FIELD1 (y[str + length]);
      invert_generator (gen, exp, cp, pcp);
   }
}

/* invert word with base address ptr; store result 
   as exponent vector with base address cp */

void invert_word (ptr, cp, pcp)
int ptr;
int cp;
struct pcp_vars *pcp;
{ 
#include "define_y.h"

   register int gen;
   register int exp;
   register int length = y[ptr];

   for (; length > 1; --length) {
      gen = y[ptr + length];
      if (gen < 0)      
	 collect (-gen, cp, pcp);
      else 
	 invert_generator (gen, 1, cp, pcp);
   }

   exp = y[ptr + 1];
   if (exp != 1)
      calculate_power (exp, ptr, cp, pcp);
}

/* read word, compute its inverse, and print out result */

void setup_word_to_invert (pcp) 
struct pcp_vars *pcp;
{
#include "define_y.h"

   int type = INVERSE_OF_WORD;
   int disp = pcp->lastg; 
   int cp = pcp->lused;
   int ptr = pcp->lused + 1 + disp;
   int str;
   register int i;

   for (i = 1; i <= pcp->lastg; ++i) 
      y[cp + i] = 0;

   read_word (stdin, disp, type, pcp);
   invert_word (ptr, cp, pcp);

   str = ptr + y[ptr] + 1;
   setup_word_to_print ("inverse", cp, str, pcp);
}
