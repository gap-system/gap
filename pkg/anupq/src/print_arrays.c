/****************************************************************************
**
*A  print_arrays.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: print_arrays.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* procedure to print out integer array */

void print_array (a, first, last)
int *a;
int first;
int last;
{
   register int i;
   for (i = first; i < last; ++i) {
      printf ("%d ", a[i]);
      if (i > first && (i - first) % 20 == 0)
	 printf ("\n");
   }
   printf ("\n");
}

/* procedure to print out character array */

void print_chars (a, first, last)
char *a;
int first;
int last;
{
   register int i;
   for (i = first; i < last; ++i)
      printf ("%d ", a[i]);
   printf ("\n");
}

