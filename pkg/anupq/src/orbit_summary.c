/****************************************************************************
**
*A  orbit_summary.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: orbit_summary.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"

/* print a summary of the orbits, listing their lengths 
   and their representatives */

void orbit_summary (length, pga)
int *length;
struct pga_vars *pga;
{
   register int i;

   printf ("\n  Orbit          Length      Representative\n");
   for (i = 1; i <= pga->nmr_orbits; ++i)
      printf ("%7d %15d %15d\n", i, length[i], pga->rep[i]);
   printf ("\nNumber of orbits is %d\n", pga->nmr_orbits);
}
