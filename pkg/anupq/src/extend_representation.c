/****************************************************************************
**
*A  extend_representation.c     ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: extend_representation.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"

/* compute a matrix which permits the extension of an existing 
   permutation representation for a group by a group of order 
   p^rank; the matrix rows are indexed from 0 .. p^rank - 1;
   the matrix columns are indexed by the defining generators and 
   their inverses in the sequence 1, 1^-1, 2, 2^-1, etc. 

   M[i][j] = k, where a = (a_1,.....a_rank) is the vector of 
   coefficients of the p-adic expansion of i, b is the vector of 
   coefficients of the p-adic expansion of k, and within the 
   p-group b = a * im(j) */

void extend_representation (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   int *expand;                 /* array to store p-adic expansion */
   register int rank = y[pcp->clend + pcp->cc]; 
   register int i, j, gen, sum;
   int bound;
   int **M;
   int index;
   int *powers;                 /* store powers of p to avoid recomputation */
   register int p = pcp->p;
   int cp = pcp->lused;
   int ptr;

   bound = int_power (p, rank);

   /* set up room to store p-adic expansion and powers of p */ 
   expand = allocate_vector (rank, 0, TRUE);
   powers = allocate_vector (rank, 0, FALSE);

   for (i = 0; i < rank; ++i)
      powers[i] = int_power (p, i);

   /* set up matrix to store results */
   M = allocate_matrix (bound, 2 * pcp->ndgen, 0, FALSE);
  
   for (i = 0; i < bound; ++i) {

      /* find the p-adic expansion of i */
      compute_padic (powers, i, rank - 1, p, expand);

      /* now process each defining generator and its inverse in turn */
      
      for (gen = -pcp->ndgen; gen <= pcp->ndgen; ++gen) {

	 if (gen == 0) continue;

	 /* now copy p-adic expansion to y */
	 for (j = 0; j < rank; ++j)
	    y[cp + j + 1] = expand[j];

#if defined (DEBUG)
	 printf ("processing generator %d \n", gen);
	 printf ("Stored p-adic expansion for %d in y is ", i);
	 for (j = 1; j <= pcp->lastg; ++j) {
	    printf ("%d ", y[cp + j]);
	 }
	 printf ("\n");
#endif

	 /* look up image of gen which is stored as a generator-exponent 
	    string in y; post-multiply the p-adic expansion by this image */ 

	 ptr = y[pcp->dgen + gen];
	 if (ptr != 0)
	    collect (ptr, cp, pcp);

#if defined (DEBUG)
	 printf ("result of collection is ");
	 for (j = 1; j <= pcp->lastg; ++j) {
	    printf ("%d ", y[cp + j]);
	 }
	 printf ("\n");
#endif
 
	 /* store the result of the multiplication */
	 sum = 0; 
	 for (j = 1; j <= pcp->lastg; ++j)  
	    sum += (y[cp + j] * powers[j - 1]);
      
	 index = (gen < 0) ? 2 * (-gen) - 1: 2 * gen - 2;
	 M[i][index] = sum;
      }

      for (j = 0; j < rank; ++j)  
	 expand[j] = 0;
   }

   printf ("The extension matrix is\n");
   print_matrix (M, bound, 2 * pcp->ndgen);

   free_vector (expand, 0);
   free_vector (powers, 0);
   free_matrix (M, bound, 0);
}

/* compute p-adic expansion of x, where x < p^(k + 1) */

void compute_padic (powers, x, k, p, expand)
int *powers;
int x;
int k;
int p;
int *expand;
{
   register int alpha;
   register int val;

   while (x > 0 && k >= 0) {
      val = powers[k];
      if (val <= x) {
	 /* find largest multiple of p^k < x */
	 alpha = p - 1;
	 while (alpha * val > x)
	    --alpha;
	 expand[k] = alpha; 
	 x -= alpha * val;
      }
      --k;
   }      
}
