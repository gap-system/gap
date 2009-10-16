/****************************************************************************
**
*A  FreeSpace.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: FreeSpace.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"
#include "pcp_vars.h"

#ifdef Magma

/* free work space */

void pq_free_WorkSpace (pcp)
struct pcp_vars *pcp;
{
   mem_delete_hptr(&pcp->y_handle);
}

#endif  /* Magma */

/* free space used by vector, a, whose first index is start */

void free_vector (a, start)
int *a;
int start;
{

#ifdef DEBUG 
   printf ("Free vector\n");
#endif

   if (start) ++a;
   free (a);
}

/* free space used by matrix, a, whose indices commence at either 0 or 1 */

void free_matrix (a, n, start)
int **a;
int n;
int start;
{
   register int i;
#ifdef DEBUG 
   printf ("Free matrix\n");
#endif

   if (n == 0) n = 1;

   for (i = start; i < start + n; ++i) {
      if (start) ++a[i];
      free (a[i]);
   }

   if (start) ++a;
   free (a);
}

/* free space used by array, a, whose indices commence at either 0 or 1 */

void free_array (a, n, m, start)
int ***a;
int n;
int m;
int start;
{
   register int i, j;
#ifdef DEBUG 
   printf ("Free array\n");
#endif

   if (n == 0) n = 1;
   if (m == 0) m = 1;

   for (i = start; i < start + n; ++i) {
      for (j = start; j < start + m; ++j) {
	 if (start) ++a[i][j];
	 free (a[i][j]);
      }
      if (start) ++a[i];
      free (a[i]);
   }

   if (start) ++a;
   free (a);
}

/* free space used by character vector, a, whose first index is start */

void free_char_vector (a, start)
char *a;
int start;
{

#ifdef DEBUG 
   printf ("Free char vector\n");
#endif

   if (start) ++a;
   free (a);
}

/* free space used by character matrix, a */ 

void free_char_matrix (a, n)
char **a;
int n;
{
   register int i;
#ifdef DEBUG 
   printf ("Free char matrix\n");
#endif

   if (n == 0) n = 1;

   for (i = 0; i < n; ++i)  
      free (a[i]);

   free (a);
}

/* free space used in computing orbits and stabilisers */

void free_space (soluble_computation, perms, orbit_length, a, b, c, pga) 
Logical soluble_computation;
int **perms;
int *orbit_length;
int *a, *b;
char *c;
struct pga_vars *pga;
{
   int nmr_of_perms = (pga->space_efficient ? 1 : pga->nmr_of_perms);

#ifdef DEBUG 
   printf ("Free space routine\n");
#endif

   free_matrix (perms, nmr_of_perms, 1);
   free_vector (orbit_length, 1);
   free_vector (a, 1);
   if (soluble_computation) {
      free_vector (b, 1);
      free_char_vector (c, 1);
   }
   free_vector (pga->map, 1);
   free_vector (pga->rep, 1);
   free_vector (pga->powers, 0);
   free_vector (pga->inverse_modp, 0);
}
