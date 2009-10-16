/****************************************************************************
**
*A  soluble_orbits.c            ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: soluble_orbits.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "pq_functions.h"

/* compute the orbits of the allowable subgroups, 
   where the permutation group is soluble */

void compute_orbits (a, b, c, perms, pga)
int **a;
int **b;
char **c;
int **perms;
struct pga_vars *pga;
{ 
   register int alpha;
   int perm_number;

   /* set up space for orbit and stabiliser information */
   space_for_orbits (a, b, c, pga);
                
   /* now compute the orbits */

   for (alpha = 1; alpha <= pga->m; ++alpha) {
      if ((perm_number = pga->map[alpha]) != 0)
	 orbits (perms[perm_number], *a, *b, *c, pga);
      else 
	 process_identity_perm (*a, *b, *c, pga);
   }
}

/* allocate and initialise space for orbit and stabiliser calculations */

void space_for_orbits (a, b, c, pga)
int **a;
int **b;
char **c;
struct pga_vars *pga;
{ 
   register int i;
   register int Degree = pga->Degree;

   *a = allocate_vector (Degree, 1, FALSE);

   *b = allocate_vector (Degree, 1, TRUE);

   *c = allocate_char_vector (Degree, 1, FALSE);

   for (i = 1; i <= Degree; ++i) {
      *(*a + i) = i;
      *(*c + i) = 1;
   }
}

/* process identity permutation -- we need only to update c[j] which is the 
   number of times j has been last image in orbit with leading term a[j] */

int process_identity_perm (a, b, c, pga)
int *a;
int *b;
char *c;
struct pga_vars *pga;
{
   register int Degree = pga->Degree;
   int j, last, element;

   /* find the last entry, last, for each orbit, and increment c[last] */
   for (j = 1; j <= Degree; ++j) { 
      if (a[j] == j) {
	 /* trace this orbit */
	 last = j;
	 element = j;
	 while (element != 0) {
	    last = element;
	    element = b[element];
	 }
	 ++c[last];
      }
   }
}

/* trace the action of the supplied permutation 
   on the existing orbits where

   a[j] = leading term of existing orbit containing j
   b[j] = next term in existing orbit containing j     
   
   c[j] = number of times j has been last image in orbit 
          with leading term a[j] */

void orbits (permutation, a, b, c, pga) 
int *permutation;
int *a;
int *b;
char *c;
struct pga_vars *pga;
{

   register int j;

   for (j = 1; j <= pga->Degree; ++j)  
      if (a[j] == j)    
	 trace_action (permutation, j, a, b, c);
}

/* trace the action of the permutation on the orbit whose leading term is j */

void trace_action (permutation, j, a, b, c)
int *permutation;
int j;
int *a;
int *b;
char *c;
{
   register int k, lead, image;
   Logical merge;

   /* find the last term, k, in the orbit of j */
   k = j;
   while (b[k] != 0)  
      k = b[k];

   /* while the image of k lies outside the orbit whose leading term is j,
      merge the existing orbit of k with that of j by running through 
      each element of the existing orbit of k and updating its entry 
      in array a so that it now lies in the orbit with leading term j;
      let k be the last entry of the existing orbit */

   merge = TRUE;
   while (merge) {
      image = permutation[k];
      lead = a[image];
      if (lead != j) {
	 b[k] = lead;
	 while (b[k] != 0) {
	    a[b[k]] = j;
	    c[b[k]] = 0;
	    k = b[k];
	 }
      }
      else {
	 ++c[k];
	 merge = FALSE;
      }
   }
}

/* find the orbit representatives, number of orbits, and orbit lengths;
   also list the individual orbits */

int* soluble_find_orbit_reps (a, b, pga)
int *a;
int *b;
struct pga_vars *pga;
{
   register int j;
   register int counter = 0;
   int *orbit_length;

   /* find the number of orbits */
   pga->nmr_orbits = 0;
   for (j = 1; j <= pga->Degree; ++j)  
      if (a[j] == j)  
	 ++pga->nmr_orbits;

   /* set up space to store orbit representatives and orbit lengths */
   pga->rep = allocate_vector (pga->nmr_orbits, 1, 0);
   orbit_length = allocate_vector (pga->nmr_orbits, 1, 0);

   /* list the elements of each orbit and find its length */
   for (j = 1; j <= pga->Degree && counter <= pga->nmr_orbits; ++j) { 
      if (a[j] == j)  {
	 ++counter;
	 pga->rep[counter] = j;
	 if (pga->print_orbits)
	    printf ("\nOrbit %d:\n", counter);
	 orbit_length[counter] = list_orbit (j, b);
	 if (pga->print_orbits)
	    printf ("\nLength is %d\n", orbit_length[counter]);  
      }
   }

   return orbit_length;
}

/* list the orbit with leading term j and return its length */

int soluble_list_orbit (j, b, pga)
int j;
int *b;
struct pga_vars *pga;
{
   register int orbit_length = 0;

   while (j != 0) {
      ++orbit_length;
      if (pga->print_orbits)
	 printf ("%d ", j);
      j = b[j];
   }

   return orbit_length;
}

/* print out contents of three arrays created during orbit calculation */

void print_orbit_information (a, b, c, pga)
int *a;
int *b;
char *c;
struct pga_vars *pga;
{
   printf ("The array A is \n"); 
   print_array (a, 1, pga->nmr_subgroups + 1);

   printf ("The array B is \n"); 
   print_array (b, 1, pga->nmr_subgroups + 1);

   printf ("The array C is \n"); 
   print_chars (c, 1, pga->nmr_subgroups + 1);

}
