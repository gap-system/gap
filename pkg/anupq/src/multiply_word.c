/****************************************************************************
**
*A  multiply_word.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: multiply_word.c,v 1.5 2011/11/28 17:47:20 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
    
#if defined (GROUP)

/* post-multiply exponent vector with base address cp 
   by word with base address ptr */

void multiply_word (ptr, cp, pcp)
int ptr;
int cp;
struct pcp_vars *pcp;
{
   register int *y = y_address;
    
   register int i;
   register int gen;
   register int exp;
   register int length = abs (y[ptr]) - 1;

   for (exp = y[ptr + 1]; exp > 0; --exp) {
      for (i = 1; i <= length; ++i) {
	 gen = y[ptr + 1 + i];
	 if (gen > 0)    
	    collect (gen, cp, pcp);
	 else 
	    invert_generator (-gen, 1, cp, pcp);
      }
   }
}

#endif
