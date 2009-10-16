/****************************************************************************
**
*A  permute_subgroups.c         ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: permute_subgroups.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "pq_functions.h"
#include "constants.h"

/* compute all of the permutations of the allowable subgroups
  induced by the extended automorphisms described in auts;
  store them in image format in a 2-dimensional array, perms */

int** permute_subgroups (LINK_input, a, b, c, auts, pga, pcp)
FILE_TYPE LINK_input;
int **a;
int **b;
char **c;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   register int alpha;
   register int nmr_of_perms;
   register int q = pga->q;
   int **A;                     /* automorphism matrix */
   int **perms;
   Logical soluble_group; 

   soluble_group = (pga->soluble || pga->Degree == 1 || pga->nmr_of_perms == 0);

   /* set up space for automorphism matrix */
   A = allocate_matrix (q, q, 0, FALSE);

   /* set up space for orbit and stabiliser information */
   if (soluble_group && pga->space_efficient)
      space_for_orbits (a, b, c, pga);

   /* set up space to store permutations */
   nmr_of_perms = (pga->space_efficient ? 1 : MAX(pga->nmr_of_perms, 1)); 
   perms = allocate_matrix (nmr_of_perms, pga->Degree, 1, FALSE);

   /* the stabiliser of a reduced p-covering group may be trivial */
   if (pga->nmr_of_perms == 0) 
      setup_identity_perm (perms[nmr_of_perms], pga);

   for (alpha = 1; alpha <= pga->m; ++alpha) {

      if (pga->trace) 
	 printf ("Processing automorphism %d:\n", alpha);

      assemble_matrix (A, q, auts[alpha], pcp);

      /* check if the matrix passes some elementary tests */
      if (!valid_matrix (A, q, pga->p, 0)) {
	 printf ("The following automorphism matrix is invalid\n"); 
	 print_matrix (A, q, q);
	 exit (FAILURE);
      }
          
      if (pga->print_automorphism_matrix) {
	 printf ("Automorphism matrix %d is\n", alpha);
	 print_matrix (A, q, q);
      }

      if (!soluble_group) {
#if defined (CAYLEY_LINK)
	 write_CAYLEY_matrix (LINK_input, "genq", "glqp", A, q, 0, alpha);
#else
#if defined (Magma_LINK)
	 write_Magma_matrix (LINK_input, "genq", "glqp", A, q, 0, alpha);
#else
#if defined (GAP_LINK) || defined (GAP_LINK_VIA_FILE) 
	 write_GAP_matrix (LINK_input, "ANUPQglb.genQ", A, q, 0, alpha);
#endif
#endif
#endif
      }

      /* is the action on the p-multiplicator non-trivial? */
      if (pga->map[alpha] != 0) {
      
	 nmr_of_perms = (pga->space_efficient ? 1 : pga->map[alpha]); 
	 compute_permutation (perms[nmr_of_perms], A, pga);

	 if (pga->print_permutation) {
	    printf ("Permutation %d is\n", alpha);
	    print_array (perms[nmr_of_perms], 1, pga->Degree + 1);
	 }
      }

      if (soluble_group && pga->space_efficient) {
	 if (pga->map[alpha] != 0)
	    orbits (perms[nmr_of_perms], *a, *b, *c, pga);
	 else
	    process_identity_perm (*a, *b, *c, pga);
      }

      /*
	else {
	insoluble_compute_orbits (*a, *b, *c, perms[nmr_of_perms], pga);
	write_CAYLEY_permutation (CAYLEY_input, nmr_of_perms, 
	perms[nmr_of_perms], pga);
	}
	*/
   }

   free_matrix (A, q, 0);
   return perms;
}

/* compute and store in image form the permutation that the extended 
   automorphism stored in A induces on the allowable subgroups */

void compute_permutation (permutation, A, pga)
int *permutation;           
int **A;
struct pga_vars *pga;
{
   register int i;

   if (pga->s != 0) {
      /* process each definition set in turn */
      pga->nmr_subgroups = 0; 
      for (i = 0; i < pga->nmr_def_sets; ++i)  
	 compute_images (A, pga->list[i], pga->available[i], permutation, pga);
   }
   else {
      permutation[1] = 1;
      pga->nmr_subgroups = 1; 
   }
}

/* compute the images of all allowable subgroups having definition 
   set K under the action of automorphism matrix A */

void compute_images (A, K, depth, permutation, pga)
int **A;               
int K;
int depth;             /* number of available positions */
int *permutation;
struct pga_vars *pga;
{
   int **S;                     /* standard matrix */
   int **Image;                 /* image of allowable subgroup under A */
   int *row;                    /* indices of available positions in S */
   int *column;
   int *position;               /* array to keep track of processed image */
   int *subset;                 /* array to store definition set of image */
   int K_Image;                 /* bit string representation of same */
   int nmr_of_bytes = pga->q * sizeof (int);
   register int i;
   register int index;
   register int s = pga->s;
   register int q = pga->q;
   register int p = pga->p;
   register int nmr_subgroups = pga->nmr_subgroups;

   S = allocate_matrix (s, q, 0, FALSE); 

   Image = allocate_matrix (s, q, 0, TRUE); 

   subset = allocate_vector (s, 0, 0);

   position = allocate_vector (depth + 1, 0, 1);

   /* set up row and column indices of available positions as 
      arrays of length depth + 1; also set up Image as image of 
      allowable subgroup with least label under action of A */

   find_available_positions (K, A, Image, &row, &column, depth, pga);

   /* for each allowable subgroup in turn, compute its image under A */

   do {

      /* make a copy of the image matrix and echelonise the copy */
      for (i = 0; i < s; ++i)
	 memcpy (S[i], Image[i], nmr_of_bytes);

      K_Image = echelonise_matrix (S, s, q, p, subset, pga);

      /* compute and store the label of the resulting standard matrix */
      ++nmr_subgroups;
if (nmr_subgroups % 1000000 == 0) 
   printf ("processing subgroup %d\n", nmr_subgroups);

      permutation[nmr_subgroups] = subgroup_to_label (S, K_Image, subset, pga);

      index = 0;
      ++position[0];
      update_image (A, column[index], Image, row[index], pga);  

      while (index < depth && position[index] == p) {
	 position[index] = 0;
	 ++index;
	 ++position[index];
	 update_image (A, column[index], Image, row[index], pga);  
      }
   } while (index < depth);

   pga->nmr_subgroups = nmr_subgroups;

   free_vector (row, 0);
   free_vector (column, 0);
   free_vector (subset, 0);
   free_vector (position, 0);
   free_matrix (S, s, 0);
   free_matrix (Image, s, 0);
}

/* add column of A to row of Image */

void update_image (A, column, Image, row, pga)
int **A;
int column;
int **Image;
int row;
struct pga_vars *pga;
{
   register int i;
   register int q = pga->q;
   register int p = pga->p;

   for (i = 0; i < q; ++i)
      Image[row][i] = (Image[row][i] + A[i][column]) % p;
}

/* set up the indices of the available positions of the standard matrices 
   determined by K as two arrays, row and column; also set up Image as 
   image of allowable subgroup with least label under action of A */

void find_available_positions (K, A, Image, row, column, depth, pga)
int K;
int **A;
int **Image;
int **row;
int **column;
int depth;
struct pga_vars *pga;
{
   register int i, j;
   register int index = 0;
   register int s = pga->s;
   register int q = pga->q;
   int *subset;

   subset = bitstring_to_subset (K, pga); 
   
   *row = allocate_vector (depth + 1, 0, 0);
   *column = allocate_vector (depth + 1, 0, 0);
   (*row)[depth] = 0;
   (*column)[depth] = 0;

   for (i = 0; i < s; ++i) {
      update_image (A, subset[i], Image, i, pga);
      for (j = subset[i] + 1; j < q; ++j) {
	 if  (1 << j & K) continue;
	 (*row)[index] = i;
	 (*column)[index] = j;
	 ++index;
      }
   }

   free_vector (subset, 0);
}

