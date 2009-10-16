/****************************************************************************
**
*A  compact.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: compact.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"

/* compact the group tables from pcp->gspace onwards */

void compact (pcp)
struct pcp_vars *pcp;   
{
#include "define_y.h"

   register int i;
   register int j;
   register int p1;
   register int new_address;
   register int bound;

   new_address = pcp->gspace - 1;
   i = pcp->gspace;

#ifndef DEBUG
   if (pcp->fullop || pcp->diagn)  
#endif
      text (2, pcp->lused, pcp->structure, 0, 0);

   while (i < pcp->lused) {

      /* the next block is currently allocated */
      if (y[i] > 0) {
	 p1 = y[i];
	 ++new_address;
	 y[p1] = -new_address;
	 y[new_address] = y[i];
	 bound = y[i + 1] + 1;
	 for (j = 1; j <= bound; ++j)
	    y[++new_address] = y[++i];
	 ++i;
      }
      else if (y[i] == 0)
	 /* this block is currently deallocated */
	 i += y[i + 1] + 2;
      else
	 /* this block consists only of the header block of length 1 */
	 ++i;
   }

   pcp->lused = new_address;

#ifndef DEBUG
   if (pcp->fullop || pcp->diagn)  
#endif
      PRINT ("After compaction Lused = %d\n", pcp->lused);

   return;
}
