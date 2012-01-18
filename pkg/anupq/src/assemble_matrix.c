/****************************************************************************
**
*A  assemble_matrix.c           ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: assemble_matrix.c,v 1.6 2011/11/28 17:47:16 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"

/* assemble a t x t matrix, A, which represents the action of the 
   automorphism described by a 2-dimensional array, auts, 
   on an initial-segment rank t subgroup of the p-multiplicator;
   note that the indices of auts start at 1, not 0 */

void assemble_matrix (A, t, auts, pcp) 
int **A;
int t;
int** auts;
struct pcp_vars *pcp;
{
   register int *y = y_address;

   register int i, j;
   register int offset = y[pcp->clend + pcp->cc - 1] + 1;

   for (i = 0; i < t; ++i)
      for (j = 0; j < t; ++j)
	 A[i][j] = auts[offset + i][offset + j];
}
