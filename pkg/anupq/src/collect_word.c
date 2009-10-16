/****************************************************************************
**
*A  collect_word.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: collect_word.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#include "constants.h"
#include "word_types.h"

/* collect word in pcp generators of group; word has base address ptr; 
   set up the result as exponent vector with base address cp */

void collect_word (ptr, cp, pcp)
int ptr;
int cp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int temp;
   int gen, exp;
   register int i;
   register int lastg = pcp->lastg;
   register int length = y[ptr];

   /* zero out lastg entries in array in order to store result */
   for (i = 1; i <= lastg; ++i)  
      y[cp + i] = 0;

   /* collect the word */
   for (i = 2; i <= length; ++i) {
      if ((gen = y[ptr + i]) > 0) 
	 collect (gen, cp, pcp);
      else
	 invert_generator (-gen, 1, cp, pcp);
   }

   /* now calculate the appropriate power of the collected part */
   if ((exp = y[ptr + 1]) != 1) {
      temp =  ptr + y[ptr] + 1;
      calculate_power (exp, temp, cp, pcp);
   }
}

/* calculate the exp power of word stored as exponent-vector at cp;
   ptr is index of free position for temporary storage in y */
void calculate_power (exp, ptr, cp, pcp)
int exp;
int ptr;
int cp;
struct pcp_vars *pcp;
{ 
#include "define_y.h"

   register int i;
   register int lastg = pcp->lastg;

   power (abs (exp), cp, pcp);

   /* if necessary, calculate the inverse */
   if (exp < 0) {
      ++ptr;
      vector_to_word (cp, ptr, pcp);
      for (i = 1; i <= lastg; ++i) 
	 y[cp + i] = 0;
      invert_word (ptr, cp, pcp);
   }
}

/* collect a word in pcp generators which may be already stored
   or is read in as string with base address ptr; store the result
   as an exponent vector at cp; convert exponent vector
   to string with base address ptr; and print out result */

void setup_word_to_collect (file, format, type, cp, pcp)
FILE_TYPE file;
int format;
int type;
int cp; 
struct pcp_vars *pcp;
{
   int disp = pcp->lastg + 2;
   register int ptr;

   ptr = pcp->lused + 1 + disp;

   if (type != FIRST_ENTRY && type != NEXT_ENTRY) {
      if (format == BASIC) 
	 read_word (file, disp, type, pcp);
      else 
	 pretty_read_word (file, disp, type, pcp);
   }

   collect_word (ptr, cp, pcp);

   if (type == VALUE_A || type == VALUE_B || file != stdin) return;

   setup_word_to_print ("result of collection", cp, ptr, pcp);
}
