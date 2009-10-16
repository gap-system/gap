/****************************************************************************
**
*A  print_level.c               ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: print_level.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"

/* set print levels for p-quotient calculation */

void print_level (output, pcp)
int *output;
struct pcp_vars *pcp;
{
   Logical reading = TRUE;

#ifndef Magma
   while (reading) {
      read_value (TRUE, "Input print level (0-3): ", output, MIN_PRINT);
      if (reading = (*output > MAX_PRINT))  
	 printf ("Print level must lie between %d and %d\n",
		 MIN_PRINT, MAX_PRINT);
   }
#endif

   pcp->diagn = (*output == MAX_PRINT);
   pcp->fullop = (*output >= INTERMEDIATE_PRINT);
}
