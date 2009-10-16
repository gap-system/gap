/****************************************************************************
**
*A  central_auts.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: central_auts.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "pq_functions.h"

/* determine which of the central outer automorphisms of the immediate 
   descendant are required for iteration purposes; set up those 
   which are necessary in the array central, which is returned */

int*** central_automorphisms (pga, pcp)
struct pga_vars *pga;
struct pcp_vars *pcp;
{ 
#include "define_y.h"

   int ***central;  
   int **commutator;            /* result of commutator calculations */
   char **redundant;            /* automorphisms which are not required */
   Logical found;
   register int gamma = 0;
   register int i, j, k;
   register int u, v;

   /* number of generators of last class in group */
   int x =  y[pcp->clend + pcp->cc - 1] - y[pcp->clend + pcp->cc - 2];
   register int nmr_columns;

   /* dummy variable -- not used in this routine but 
      required for echelonise_matrix call */
   /*
     int *subset;
     subset = allocate_vector (x, 0, 0); 
     echelonise_matrix (commutator, x, nmr_columns, pcp->p, subset, pga);
     free_vector (subset, 0);
     */

   /* maximum number of central outer automorphisms */
   nmr_columns = pga->nmr_centrals = pga->ndgen * pga->s; 

   commutator = commutator_matrix (pga, pcp);
   if (pga->print_commutator_matrix) { 
      printf ("The commutator matrix is \n");
      print_matrix (commutator, x, nmr_columns);
   } 
   
   reduce_matrix (commutator, x, nmr_columns, pcp->p, pga);

   redundant = allocate_char_matrix (pga->ndgen, pga->s, 0, TRUE);
   for (i = 0; i < x; ++i) {
      found = FALSE;
      j = 0;
      while (j < nmr_columns && !(found = (commutator[i][j] == 1)))  
	 ++j;
      if (found) {
	 u = j / pga->s;
	 v = j % pga->s;
	 redundant[u][v] = TRUE;
	 --pga->nmr_centrals;
      }
   }

   /* set up, in the array central, all necessary automorphisms of the form 
      u --> u * (pcp->ccbeg + v) 
      k --> k
      where both u and k are defining generators, k distinct from u,
      and v runs from 0 to pga->s - 1 */
                                           
   if (pga->nmr_centrals != 0) {
      central = allocate_array (pga->nmr_centrals, pga->ndgen, pcp->lastg, TRUE);

      for (u = 0; u < pga->ndgen; ++u) { 
	 for (v = 0; v < pga->s; ++v) {
	    if (redundant[u][v] == FALSE) {
	       ++gamma;
	       for (k = 0; k < pga->ndgen; ++k) {
		  central[gamma][k + 1][k + 1] = 1;
		  if (k == u)
		     central[gamma][k + 1][pcp->ccbeg + v] = 1;
	       }
	    }
	 }      
      }
   }

   free_matrix (commutator, x, 0);
   free_char_matrix (redundant, pga->ndgen);

   return central;
}

/* for each of the x generators of highest class - 1, look up 
   its commutator with each of the pga->ndgen defining generators;
   set up the exponents of the pga->s new generators which occur 
   in the commutator as part of a row of an 
   x by pga->ndgen * pga->s matrix, commutator, which is returned */

int** commutator_matrix (pga, pcp)
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   /* first and last generator of last class of parent */
   int first = y[pcp->clend + pcp->cc - 2] + 1;
   int last = y[pcp->clend + pcp->cc - 1];

   int x = last - first + 1;
   int **commutator; 
   int *result;
   int pointer, value, entry, length;
   int offset;
   int u, v;
   register int i, j, k;
#include "access.h"

#ifdef CARANTI
   commutator = allocate_matrix (x, pga->ndgen * pga->s, 0, TRUE);
   return commutator;
#else
   commutator = allocate_matrix (x, pga->ndgen * pga->s, 0, FALSE);
#endif

   for (i = first; i <= last; ++i) {

      offset = 0;

      for (j = 1; j <= pga->ndgen; ++j) {

	 /* store the result of [i, j] */
	 result = allocate_vector (pga->s, 0, 1);

	 if (i != j) {

	    if (i < j) {
	       u = i; v = j;
	    }
	    else {
	       u = j; v = i;
	    }

	    /* look up the value of [v, u] */
	    pointer = y[pcp->ppcomm + v];
	    entry = y[pointer + u]; 
	    if (entry > 0)  
	       result[entry - pcp->ccbeg] = 1;
	    else if (entry < 0) {
	       length = y[-entry + 1];
	       for (k = 1; k <= length; ++k) {
		  value = y[-entry + 1 + k];
		  result[FIELD2 (value) - pcp->ccbeg] = FIELD1 (value);
	       }
	    }
            
	    /* since, we want the value of [i, j], we may now 
	       need to invert [v, u] */
	    if (j == v) {
	       for (k = 0; k < pga->s; ++k)  
		  if (result[k] != 0)
		     result[k] = (pga->p - result[k]) % pga->p;
	    } 
	 }

	 /* now copy the result to commutator */
	 for (k = 0; k < pga->s; ++k)
	    commutator[i - first][k + offset] = result[k];
	 offset += pga->s;

	 free_vector (result, 0);

      }
   }

   return commutator;
}
