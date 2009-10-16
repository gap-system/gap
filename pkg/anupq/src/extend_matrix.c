/****************************************************************************
**
*A  extend_matrix.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: extend_matrix.c,v 1.5 2001/06/15 14:31:51 werner Exp $
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
#include "define_y.h"

   int nmr_of_generators;
   int **auts;

   nmr_of_generators = y[pcp->clend + 1];

   auts = reallocate_matrix (current, nmr_of_generators,
			     nmr_of_generators, pcp->lastg, pcp->lastg, TRUE); 

   return auts;
}
