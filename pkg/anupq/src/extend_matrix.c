/****************************************************************************
**
*A  extend_matrix.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: extend_matrix.c,v 1.6 2011/11/28 17:47:18 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"

int **reallocate_matrix ();

/* extend the space available for storage of automorphisms */

int **extend_matrix (current, pcp)
int **current;
struct pcp_vars *pcp;
{
   register int *y = y_address;

   int nmr_of_generators;
   int **auts;

   nmr_of_generators = y[pcp->clend + 1];

   auts = reallocate_matrix (current, nmr_of_generators,
			     nmr_of_generators, pcp->lastg, pcp->lastg, TRUE); 

   return auts;
}
