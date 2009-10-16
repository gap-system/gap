/****************************************************************************
**
*A  insoluble_orbits.c          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: insoluble_orbits.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "pq_functions.h"
#include "standard.h"

/* find the orbits of an insoluble permutation group,
   which has generators stored as a sequence in perms */

void insoluble_compute_orbits (orbit, backptr, schreier, perms, pga)
int **orbit;
int **backptr;
char **schreier;
int **perms;
struct pga_vars *pga;
{
   int *stack;
   int *pointer;
   int point, image;
   register int i, j;
   register int Degree = pga->Degree;
   register int nmr_of_perms = pga->nmr_of_perms;

   *orbit = allocate_vector (Degree, 1, FALSE);

   /* if standard presentation computation, set 
      up schreier vectors and backward pointers */

   if (StandardPresentation) {
      *schreier = allocate_char_vector (Degree, 1, TRUE);
      *backptr = allocate_vector (Degree, 1, TRUE);
   }

   for (i = 1; i <= Degree; ++i)
      *(*orbit + i) = i;

   stack = allocate_vector (Degree + 1, 0, FALSE);

   for (i = 1; i <= Degree; ++i) {

      if (*(*orbit + i) != i) continue;

      pointer = stack;
      *pointer = i;

      while (pointer - stack >= 0) {
	 point = *pointer;
	 for (j = 1; j <= nmr_of_perms; ++j) {
	    image = perms[j][point];
	    if ((image != i) && (*(*orbit + image) == image)) {
	       *pointer++ = image;
	       *(*orbit + image) = i;
	       if (StandardPresentation) {
		  *(*schreier + image) = j;
		  *(*backptr + image) = point;
	       }
	    }
	 }
	 --pointer;
      }
   }

   free_vector (stack, 0);
}

/* list the orbit of insoluble permutation group with leading term rep */

void insoluble_list_orbit (rep, orbit_length, a, pga)
int rep;
int orbit_length; 
int *a;
struct pga_vars *pga;
{
   register int j;
   register int Degree = pga->Degree;

   printf ("%d ", rep);
   --orbit_length;

   for (j = rep + 1; j <= Degree && orbit_length > 0; ++j)  
      if (*(a + j) == rep) { 
	 printf ("%d ", j);
	 --orbit_length;
      }
}

/* list the orbit of soluble permutation group with leading term j */

void list_orbit (j, b)
int j;
int *b;
{
   while (j != 0) {
      printf ("%d ", j);
      j = b[j];
   }
}

/* find the orbit representatives, number of orbits, and 
   orbit lengths; if required, list the individual orbits */

int* find_orbit_reps (a, b, pga)
int *a;
int *b;
struct pga_vars *pga;
{
   Logical soluble;
   register int Degree = pga->Degree;
   register int counter = 0;
   register int j;
   int *length;
   int size = 1000;

   pga->nmr_orbits = 0;

   /* set up space to store orbit representatives and orbit lengths */
   pga->rep = allocate_vector (1000, 1, FALSE);
   length = allocate_vector (1000, 1, FALSE);

   for (j = 1; j <= Degree; ++j) {
      if (*(a + j) == j) {
	 if (++pga->nmr_orbits > size) {
	    pga->rep = reallocate_vector (pga->rep, size, size + 1000, 1, 0);
	    length = reallocate_vector (length, size, size + 1000, 1, 0);
	    size += 1000;
	 }
	 pga->rep[pga->nmr_orbits] = j;
	 length[pga->nmr_orbits] = 1;
	 a[j] = -pga->nmr_orbits;
      }
      else
	 ++length[-a[a[j]]];
   } 

   soluble = (pga->soluble || pga->nmr_of_perms == 0 || Degree == 1);

   if (!soluble && !pga->print_orbits) return length;

   /* list the elements of each orbit -- this must be speeded up
      since it is potentially very expensive as written -- EO'B */

   for (j = 1; j <= Degree && counter < pga->nmr_orbits; ++j) {
      if (*(a + j) < 0) {
	 ++counter; 
	 if (soluble) *(a + j) = j;
	 if (pga->print_orbits) {
	    printf ("\nOrbit %d has length %d:\n", counter, length[counter]);
	    if (soluble)  
	       list_orbit (j, b);
	    else
	       insoluble_list_orbit (j, length[counter], a, pga);
	 }
      }
   }

   return length;
}
