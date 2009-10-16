/****************************************************************************
**
*A  convert.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: convert.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"

#if defined (LIE) 

/* ensure exponent-generator string is in appropriate form 
   for multiplication */
 
int verify_string (string, pcp)
int string;
struct pcp_vars *pcp;
{
#include "define_y.h"
#include "access.h"
 
   if (y[string + 1] == 0)
      string = 0;
   else if (y[string + 1] == 1 && FIELD1 (y[string + 2]) == 1)
      string = FIELD2 (y[string + 2]);
   else
      string = -string;
 
   return string;
}

#endif

/* convert exponent vector with base address  
   cp to string whose base address is str */

int vector_to_string (cp, str, pcp)
int cp;
int str;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int length = 0;   
   register int lastg = pcp->lastg;
   register int ptr;

#include "access.h" 
   
   for (i = 1; i <= lastg; ++i) {
      if (y[cp + i] != 0) {
	 ++length;
	 y[str + 1 + length] = PACK2 (y[cp + i], i);
      }
   }

   y[str + 1] = length;

#if defined (LIE)
   ptr = verify_string(str, pcp);
   return ptr;
#endif 
}

/* convert exponent-vector with base address cp 
   to word with base address ptr */

int vector_to_word (cp, ptr, pcp)
int cp;
int ptr;
struct pcp_vars *pcp;
{   
#include "define_y.h"

   int i, j;
   register int length = 1;
   register int lastg = pcp->lastg;

   y[ptr + 1] = 1;
   for (i = 1; i <= lastg; ++i) {
      for (j = 1; j <= y[cp + i]; ++j) {
	 ++length;
	 y[ptr + length] = i;
      }
   }

   y[ptr] = length; 
   return length;
}

/* convert normal word with base address ptr and exponent 1 
   to string with base address str */
void word_to_string (ptr, str, pcp)
int ptr;
int str;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int length = y[ptr];   
   /* register int exp = y[ptr + 1]; */
#include "access.h"

   for (i = 1; i <= length; ++i)
      y[str + 1 + i] = PACK2 (1, y[ptr + 1 + i]);

   y[str + 1] = length;
}

/* convert string with base address str to 
   exponent vector whose base address is cp */

void string_to_vector (str, cp, pcp)
int str;
int cp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int length = y[str + 1];

#include "access.h"

   for (i = 1; i <= pcp->lastg; ++i)
      y[cp + i] = 0;

   for (i = 1; i <= length; ++i)
      y[cp + FIELD2 (y[str + 1 + i])] = FIELD1 (y[str + 1 + i]);

}
