/****************************************************************************
**
*A  find_permutation.c          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: find_permutation.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"
#include "pq_functions.h"

/* for each k, find the first permutation, d[k], which brings k into orbit */

char* find_permutation (b, c, pga)
int *b;
char *c;
struct pga_vars *pga;
{
   register int i, j, k, l;
   char *d;

   d = allocate_char_vector (pga->Degree, 1, TRUE);

   /*
     d = (char *) calloc (pga->Degree, sizeof (char));
     --d;
     */

   for (i = 1; i <= pga->nmr_orbits; ++i) {
      j = pga->rep[i];
      /* trace the orbit with leading term j */
      k = j; 
      l = b[j];
      while (l != 0) {
	 d[l] = d[k] + c[k];
	 k = l;
	 l = b[l];
      }
   }

   return d;
}
