/****************************************************************************
**
*A  AllocateSpace.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: AllocateSpace.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"

/* allocate space for array y */

void Allocate_WorkSpace (work_space, pcp)
int work_space;
struct pcp_vars *pcp; 
{
#ifdef Magma
   if ((pcp->y_handle = mem_alloc_words (work_space + 1)) == NULL_HANDLE) {
      error_internal ("Not enough space to run p-Quotient Program");
   }
   *(mem_access (pcp->y_handle)) = 0;
#else
   if ((y_address = 
	(int *) malloc ((work_space + 1) * sizeof (int))) == (int *) 0) {
      perror ("malloc failed in Allocate_WorkSpace ()");
      exit (FAILURE);
   }
#endif  

   /* initialise the pcp structure */
   pcp->fronty = 1;
   pcp->backy = work_space;

}

/* allocate space for a vector, a, of size n, 
   whose subscript commences at position start */

int* allocate_vector (n, start, zero)
int n;          
int start;      /* start may be 0 or 1 */
Logical zero;
{
   int *a;

#ifdef DEBUG
   printf ("allocate vector of size %d\n", n);
#endif
   
   /* some versions of malloc crash when repeatedly asked to allocate
      small amounts of space -- in particular, under AIX and Ultrix */
   if (n < 4)
      n = 4;

   if (zero) {
      if ((a = (int *) calloc (n, sizeof (int))) == (int *) 0) {
	 perror ("Call to allocate_vector");
	 exit (FAILURE);
      }
   }
   else if ((a = (int *) malloc (n * sizeof (int))) == (int *) 0) {
      perror ("Call to allocate_vector");
      exit (FAILURE);
   }

   while (start) {
      --a;
      --start;
   }

   return a;

}

/* allocate space for an n x m integer matrix a, 
   whose subscripts start at position 0 or 1 */

int** allocate_matrix (n, m, start, zero)
int n;
int m;
int start;
Logical zero;
{
   int **a;
   int i;

#ifdef DEBUG
   printf ("allocate matrix %d x %d\n", n, m);
#endif

   if (n == 0)
      n = 1;
   if (m < 4)
      m = 4;

   if ((a = (int **) malloc (n * sizeof (int *))) == (int **) 0) {
      perror ("Call to allocate_matrix");
      exit (FAILURE);
   }
   if (start != 0)
      --a;

   for (i = start; i < start + n; ++i) {
      if (zero) {
	 if ((a[i] = (int *) calloc (m, sizeof (int))) == (int *) 0) {
	    perror ("Call to allocate_matrix");
	    exit (FAILURE);
	 }
      }
      else if ((a[i] = (int *) malloc (m * sizeof (int))) == (int *) 0) {
	 perror ("Call to allocate_matrix");
	 exit (FAILURE);
      }
      if (start != 0)
	 --a[i];
   }

   return a;
}

/* allocate space for an n x m x r integer array a,
   whose subscripts begin at 1, not 0 */

int*** allocate_array (n, m, r, zero)
int n;
int m;
int r;
Logical zero;
{
   int ***a;
   register int i, j;

#ifdef DEBUG
   printf ("allocate array %d x %d x %d\n", n, m, r);
#endif

   if (n == 0)
      n = 1;
   if (m == 0)
      m = 1;
   if (r < 4)
      r = 4;

   if ((a = (int ***) malloc (n * sizeof (int **))) == (int ***) 0) {
      perror ("Call to allocate_array");
      exit (FAILURE);
   }
   --a;

   for (i = 1; i <= n; ++i) {
      if ((a[i] = (int **) malloc (m * sizeof (int *))) == (int **) 0) {
	 perror ("Call to allocate_array");
	 exit (FAILURE);
      }
      --a[i];
      for (j = 1; j <= m; ++j) {
	 if (zero) {
	    if ((a[i][j] = (int *) calloc (r, sizeof (int))) == (int *) 0) {
	       perror ("Call to allocate_array");
	       exit (FAILURE);
	    }
	 }
	 else if ((a[i][j] = (int *) malloc (r * sizeof (int))) == (int *) 0) {
	    perror ("Call to allocate_array");
	    exit (FAILURE);
	 }
	 --a[i][j];
      }
   }

   return a;
} 

/* reallocate space for a vector, a, of size new which 
   was originally of size original */

int* reallocate_vector (a, original, new, start, zero)
int *a;
int original;
int new;
int start;
Logical zero;
{
   int j;

#ifdef DEBUG
   printf ("reallocate vector\n");
#endif
 
   if (original < 4) 
      original = 4;

   if (start && original != 0) ++a;

#ifdef DEBUG
   printf ("In reallocate: original = %d; new = %d\n", original, new);
   printf ("before reallocate: a = %d\n", a);
#endif

   if ((a = (int *) realloc (a, new * sizeof (int))) == (int *) 0) {
#ifdef DEBUG
      printf ("Original size is %d; new size is %d\n", original, new);
#endif
      perror ("Call to reallocate_vector");
      exit (FAILURE);
   }

   if (start) --a;

   if (zero)  
      for (j = start + original; j < start + new; ++j)
	 a[j] = 0;

#ifdef DEBUG
   printf ("after reallocate: a = %d\n", a);
#endif
   return a;
}

/* reallocate space for an n x m integer matrix a, whose subscripts begin 
   at 1, not 0; the original sizes are supplied */

int** reallocate_matrix (a, orig_n, orig_m, n, m, zero)
int **a;
int orig_n, orig_m;
int n;
int m;
Logical zero;
{
   register int i, j;

#ifdef DEBUG
   printf ("reallocate matrix\n");
#endif

   if (orig_n == 0)
      orig_n = 1;
   if (orig_m < 4)
      orig_m = 4;

   if ((a = (int **) realloc (++a, n * sizeof (int *))) == (int **) 0) {
      perror ("Call to reallocate_matrix");
      exit (FAILURE);
   }
   --a;

   for (i = 1; i <= n; ++i) {
      if (i > orig_n) {
	 if ((a[i] = (int *) malloc (m * sizeof (int))) == (int *) 0) {
	    perror ("Call to reallocate_matrix");
	    exit (FAILURE);
	 }
      }
      else { 
	 if ((a[i] = (int *) realloc (++a[i], m * sizeof (int))) == (int *) 0) {
	    perror ("Call to reallocate_matrix");
	    exit (FAILURE);
	 }
      }
      --a[i];
   }

   if (zero) {
      for (i = 1; i <= n; ++i)
	 for (j = 1; j <= m; ++j)
	    if (i > orig_n || j > orig_m) 
	       a[i][j] = 0;
   }

   return a;
} 

/* reallocate space for an n x m x r integer array a,
   whose subscripts begin at 1, not 0; the original
   sizes are supplied */

int*** reallocate_array (a, orig_n, orig_m, orig_r, n, m, r, zero)
int ***a;
int orig_n, orig_m, orig_r;
int n;
int m;
int r;
Logical zero;
{
   register int i, j, k;

#ifdef DEBUG
   printf ("reallocate array\n");
#endif

   if (orig_n == 0)
      orig_n = 1;
   if (orig_m == 0)
      orig_m = 1;
   if (orig_r < 4)
      orig_r = 4;

   if ((a = (int ***) realloc (++a, n * sizeof (int **))) == (int ***) 0) {
      perror ("Call to reallocate_array");
      exit (FAILURE);
   }
   --a;

   for (i = 1; i <= n; ++i) {
      if (i > orig_n) {
	 if ((a[i] = (int **) malloc (m * sizeof (int *))) == (int **) 0) {
	    perror ("Call to reallocate_array");
	    exit (FAILURE);
	 }
      }
      else { 
	 if ((a[i] = (int **) realloc (++a[i], 
				       m * sizeof (int *))) == (int **) 0) {
	    perror ("Call to reallocate_array");
	    exit (FAILURE);
	 }
      }
      --a[i];

      for (j = 1; j <= m; ++j) {
	 if (j > orig_m || i > orig_n) {
	    if ((a[i][j] = (int *) malloc (r * sizeof (int))) == (int *) 0) {
	       perror ("Call to allocate_array");
	       exit (FAILURE);
	    }
	 }
	 else {
	    if ((a[i][j] = (int *) realloc (++a[i][j], 
					    r * sizeof (int))) == (int *) 0) {
	       perror ("Call to allocate_array");
	       exit (FAILURE);
	    }
	 }
	 --a[i][j];
      }
   }

   if (zero) {
      for (i = 1; i <= n; ++i)
	 for (j = 1; j <= m; ++j)
	    for (k = 1; k <= r; ++k)  
	       if (i > orig_n || j > orig_m || k > orig_r) 
		  a[i][j][k] = 0;
   }

   return a;
} 

/* allocate space for a character vector, a, of size n, 
   whose subscript commences at position start */

char* allocate_char_vector (n, start, zero)
int n;
int start;
Logical zero;
{
   char *a;

#ifdef DEBUG
   printf ("allocate char vector\n");
#endif

   if (n < 4)
      n = 4;

   if (zero) {
      if ((a = (char *) calloc (n, sizeof (char))) == (char *) 0) {
	 perror ("Call to allocate_char_vector");
	 exit (FAILURE);
      }
   }
   else if ((a = (char *) malloc (n * sizeof (char))) == (char *) 0) {
      perror ("Call to allocate_char_vector");
      exit (FAILURE);
   }

   while (start) {
      --a;
      --start;
   }

   return a;
}

/* allocate space for an n x m character matrix a, 
   whose subscripts start at position 0 or 1 */

char** allocate_char_matrix (n, m, start, zero)
int n;
int m;
int start;
Logical zero;
{
   char **a;
   int i;

#ifdef DEBUG
   printf ("allocate char matrix\n");
#endif

   if (n == 0)
      n = 1;
   if (m < 4)
      m = 4; 

   if ((a = (char **) malloc (n * sizeof (char *))) == (char **) 0) {
      perror ("Call to allocate_matrix");
      exit (FAILURE);
   }
   if (start != 0)
      --a;

   for (i = start; i < start + n; ++i) {
      if (zero) {
	 if ((a[i] = (char *) calloc (m, sizeof (char))) == (char *) 0) {
	    perror ("Call to allocate_matrix");
	    exit (FAILURE);
	 }
      }
      else if ((a[i] = (char *) malloc (m * sizeof (char))) == (char *) 0) {
	 perror ("Call to allocate_matrix");
	 exit (FAILURE);
      }
      if (start != 0)
	 --a[i];
   }

   return a;
}

/* allocate space for an n x m x r character array a,
   whose subscripts begin at 1, not 0 */

char*** allocate_char_array (n, m, r, zero)
int n;
int m;
int r;
Logical zero;
{
   char ***a;
   register int i, j;

#ifdef DEBUG
   printf ("allocate char array\n");
#endif

   if (n == 0)
      n = 1;
   if (m == 0)
      m = 1;
   if (r < 4)
      r = 4; 

   if ((a = (char ***) malloc (n * sizeof (char **))) == (char ***) 0) {
      perror ("Call to allocate_char_array");
      exit (FAILURE);
   }
   --a;

   for (i = 1; i <= n; ++i) {
      if ((a[i] = (char **) malloc (m * sizeof (char *))) == (char **) 0) {
	 perror ("Call to allocate_char_array");
	 exit (FAILURE);
      }
      --a[i];
      for (j = 1; j <= m; ++j) {
	 if (zero) {
	    if ((a[i][j] = (char *) calloc (r, sizeof (char))) == (char *) 0) {
	       perror ("Call to allocate_char_array");
	       exit (FAILURE);
	    }
	 }
	 else {
	    if ((a[i][j] = (char *) malloc (r * sizeof (char))) == (char *) 0) {
	       perror ("Call to allocate_char_array");
	       exit (FAILURE);
	    }
	 }
	 --a[i][j];
      }
   }

   return a;
}
