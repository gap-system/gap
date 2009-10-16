/****************************************************************************
**
*A  read_auts.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: read_auts.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#include "standard.h"

/* for each automorphism in turn, read its actions on each 
   of the pcp generators of the Frattini quotient */

int*** read_auts (option, nmr_of_auts, nmr_of_exponents, pcp)
int option;
int *nmr_of_auts;
int *nmr_of_exponents;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i, j, k;
   int ***auts;
   int nmr_of_generators; 

   read_value (TRUE, "Input the number of automorphisms: ", nmr_of_auts, 0);

   if (*nmr_of_auts == 0) return NULL;

   /* allocate sufficient space to store the automorphisms --
      the indices of the array have been adjusted to start at 1, 
      rather than 0, because it simplifies the automorphism handling */

   if (option == PGA || option == STANDARDISE)
      *nmr_of_exponents = y[pcp->clend + pcp->cc - 1];
   else {
      if (option == PQ && pcp->cc > 1) 
	 read_value (TRUE, "Input the number of exponents: ", 
		     nmr_of_exponents, y[pcp->clend + 1]);
      else 
	 *nmr_of_exponents = y[pcp->clend + 1];
   }

   nmr_of_generators = y[pcp->clend + 1];

   if (option == PGA || option == STANDARDISE)
      auts = allocate_array (*nmr_of_auts, pcp->lastg, pcp->lastg, TRUE); 
   else 
      auts = allocate_array (*nmr_of_auts, nmr_of_generators, 
			     *nmr_of_exponents, TRUE); 

   for (i = 1; i <= *nmr_of_auts; ++i) {
      printf ("Now enter the data for automorphism %d\n", i);
      for (j = 1; j <= nmr_of_generators; ++j) {
	 printf ("Input %d exponents for image of pcp generator %d: ", 
		 *nmr_of_exponents, j); 
	 for (k = 1; k < *nmr_of_exponents; ++k)  
	    read_value (FALSE, "", &auts[i][j][k], 0);
	 read_value (TRUE, "", &auts[i][j][k], 0);
      }
   }

   return auts;
}
