/****************************************************************************
**
*A  matrix.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: matrix.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pq_functions.h"

/* read an n x matrix, a */

void read_matrix (a, n, m) 
int **a;
int n, m;
{
   register int i, j;

   for (i = 0; i < n; ++i) {
      for (j = 0; j < m - 1; ++j) 
	 read_value (FALSE, "", &a[i][j], 0);
      read_value (TRUE, "", &a[i][j], 0);
   }
   printf ("\n");
}

/* print an n x m matrix a */

void print_matrix (a, n, m) 
int **a;
int n, m;
{
   register int i, j;

   for (i = 0; i < n; ++i) {
      for (j = 0; j < m; ++j) 
	 printf ("%d ", a[i][j]);
      printf ("\n");
   }
}

/* modulo p, multiply the n x m matrix a by the m x q matrix b */

int** multiply_matrix (a, n, m, b, q, p)
int **a;
int n, m;
int **b;
int q;
int p;
{ 
   register int i, j, k;
   int **product = allocate_matrix (n, q, 0, 1);

   for (i = 0; i < n; ++i)
      for (j = 0; j < q; ++j) { 
	 for (k = 0; k < m; ++k)
	    product[i][j] += a[i][k] * b[k][j];
	 product[i][j] %= p;
      }

   return product;
}

int** transpose (a, n, m) 
int **a;
int n, m;
{
   register int i, j;
   int** transpose = allocate_matrix (m, n, 0, 0);

   for (i = 0; i < m; ++i)
      for (j = 0; j < n; ++j)
	 transpose[i][j] = a[j][i];

   return transpose;
}

/* check if the n x n matrix a is the identity;
   start is its first index position */

Logical is_identity (a, n, start) 
int **a;
int n;
int start;
{
   int identity = 1;
   register int i = start;
   register int j;

   while (i < n + start && identity) {
      j = start;
      while (j < n + start && identity) {
	 identity = (i == j) ? a[i][j] == 1 : a[i][j] == 0;
	 ++j;
      }
      ++i;
   }

   return identity;
}

/* check if each row of the n x n matrix a has a non-zero 
   entry and whether its entries lie between 0 and p - 1; 
   start is its first index position */

Logical valid_matrix (a, n, p,start) 
int **a;
int n;
int p;
int start;
{
   register int i, j; 
   int non_zero = 0;
   Logical valid = TRUE;
   Logical first;

   for (i = start; i < n + start && valid; ++i) {
      first = TRUE;
      for (j = start; j < n + start && valid; ++j) {
	 valid = (a[i][j] >= 0 && a[i][j] < p);
	 if (a[i][j] > 0 && first) {
	    ++non_zero;
	    first = FALSE;
	 }
      }
   }

   if (valid && non_zero == n) 
      return TRUE; 
   else 
      return FALSE;
}
