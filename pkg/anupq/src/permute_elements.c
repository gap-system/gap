/****************************************************************************
**
*A  permute_elements.c          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: permute_elements.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#undef DEBUG
#include "pga_vars.h"
#include "pq_functions.h"

/* compute automorphism classes of elements of a vector space;

   procedure requests as input rank and prime and those matrices
   which act on the space; 

   it also permits the computation of the permutations induced 
   by multiplying each element of the vector space by a supplied 
   basis element; the basis element are numbered 1 .. <rank>

   elements are generated in sequence and their images 
   computed by matrix multiplication; orbits under the
   action of these permutations are then computed and
   orbit representatives listed;

   given the label of an orbit representative, its p-adic
   expansion corresponds to the element */

void expand_padic (x, k, p, expand)
int x;
int k;
int p;
int *expand;
{
   register int alpha;
   register int val;

   while (x > 0 && k >= 0) {
      val = int_power (p, k);
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

void padic (p, rank, pga)
int p;
int rank;
struct pga_vars *pga;
{
   int number;
   int *expand;
   int bound = rank;
   int i, r;
   expand = allocate_vector (rank + 1, 0, FALSE);
  
   for (r = 1; r <= pga->nmr_orbits; ++r) {
      number = pga->rep[r];
      for (i = 0; i <= rank; ++i)
	 expand[i] = 0;
      bound = rank;
      while (bound > 0 && int_power (p, bound) > number)
	 --bound;
      ++bound;

      expand_padic (number, bound, p, expand);
      printf ("The element with label %5d is ", number);
      print_array (expand, 0, rank);
   }
}

void permute_elements ()
{
   int index;
   int **position;
   int rank;
   int p;
   int i;
   int label;
   int map;
   int **A;
   int **B;
   int subgp;
   int **permutation;
   struct pga_vars pga;
 
   int *length;
   int alpha;
   int m;
   int q, x;
   int *orbit;
   int *schreier, *backptr;
   int nmr_maps;
   int Degree;

   read_value (TRUE, "Input rank of vector space: ", &rank, 1);
   read_value (TRUE, "Input prime: ", &p, 2);
   read_value (TRUE, "Input number of automorphism matrices: ", &m, 0);
   read_value (TRUE, "Input number of multiplication maps: ", &nmr_maps, 0);

   Degree = int_power (p, rank);
   position = allocate_matrix (1, rank + 1, 0, 0);
   permutation = allocate_matrix (nmr_maps + m, Degree, 1, 0);

   q = rank;
   A = allocate_matrix (q, rank + 1, 0, 0);

   /* first process automorphisms */

   for (alpha = 1; alpha <= m; ++alpha) {
      printf ("Input the matrix for automorphism %d\n", alpha);
      read_matrix (A, q, q); 

      for (x = 0; x <= rank; ++x)
	 position[0][x] = 0;

      subgp = 0;
      do {
	 index = 0;
	 ++position[0][0];
	 while (index < rank && position[0][index] == p) {
	    position[0][index] = 0;
	    ++index;
	    ++position[0][index];
	 }   
      
#ifdef DEBUG
	 printf ("\n");
	 for (i = 0; i < rank; ++i)
	    printf ("%d ", position[0][i]);
#endif
	 label = 0;
	 for (i = 0; i < rank; ++i)
	    label += (position[0][i] * int_power (p, i));
#ifdef DEBUG
	 printf ("label is %d\n", label);
#endif
 
	 /* now multiply mod p */
	 B = multiply_matrix (position, 1, q, A, q, p);
#ifdef DEBUG
	 print_matrix (B, 1, q);
#endif
	 label = 0;
	 for (i = 0; i < rank; ++i)
	    label += (B[0][i] * int_power (p, i));
#ifdef DEBUG
	 printf ("label is %d\n", label);
	 if (subgp % 10000 == 0) printf ("Completed %d subgroups\n", subgp);
#endif
	 if (label == 0) label = Degree;
	 permutation[alpha][++subgp] = label;
  
	 free_matrix (B, 1, 0);
      
      } while (index < rank);

#ifdef DEBUG
      print_array (permutation[alpha], 1, subgp + 1);
#endif 
   }

   pga.Degree = Degree;

   /* now process multiplication maps */

   for (alpha = 1; alpha <= nmr_maps; ++alpha) {
      subgp = 0;
   
      for (x = 0; x <= rank; ++x)
	 position[0][x] = 0;

      read_value (TRUE, "Input basis element to multiply by: ", &map, 1);
      --map;

      do {
	 index = 0;
	 ++position[0][0];
	 while (index < rank && position[0][index] == p) {
	    position[0][index] = 0;
	    ++index;
	    ++position[0][index];
	 }   

#if DEBUG
	 printf ("\n");
	 for (i = 0; i < rank; ++i)
	    printf ("%d ", position[0][i]);
#endif

	 label = 0;
	 for (i = 0; i < rank; ++i)
	    label += (position[0][i] * int_power (p, i));
#if DEBUG
	 printf ("label is %d\n", label);
#endif
 
	 B = allocate_matrix (1, rank + 1, 0, 0);
	 for (i = 0; i < rank; ++i)
	    B[0][i] = position[0][i];
	 B[0][map] = (B[0][map] + 1) % p;

#if DEBUG
	 print_matrix (B, 1, q);
#endif
	 label = 0;
	 for (i = 0; i < rank; ++i)
	    label += (B[0][i] * int_power (p, i));
#if DEBUG
	 printf ("label is %d\n", label);
#endif

	 if (label == 0) label = pga.Degree;

	 permutation[m + alpha][++subgp] = label;
	 free_matrix (B, 1, 0);
      
      } while (index < rank);
#if DEBUG
      print_array (permutation[m + alpha], 1, subgp + 1);
#endif
   }

   pga.Degree = subgp;
   pga.m = m + nmr_maps;
   pga.nmr_of_perms = m + nmr_maps;
   pga.soluble = FALSE;
   pga.print_orbits = FALSE;

   insoluble_compute_orbits (&orbit, &backptr, &schreier, permutation, &pga);
   length =  find_orbit_reps (orbit, orbit, &pga);
   orbit_summary (length, &pga);

   padic (p, rank, &pga);
}
