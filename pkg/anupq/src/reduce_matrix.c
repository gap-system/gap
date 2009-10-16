/****************************************************************************
**
*A  reduce_matrix.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: reduce_matrix.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"

/* left echelonise mod p the matrix a, which has the supplied dimensions;
   set up its definition set both as a subset and as a bit string  */

int reduce_matrix (a, nmr_rows, nmr_columns, p, pga)
int **a;
int nmr_rows;
int nmr_columns;
int p;
struct pga_vars *pga;
{
   Logical zero;
   register int bound = nmr_columns - 1;
   register int row, column, i, j, index, val;
   register int entry;

   for (row = 0; row < MIN(nmr_rows, nmr_columns); ++row) {

      /* start with the diagonal entry */
      column = row;

      /* find first non-zero entry, if any, in this column;
	 if none, advance to next column */
      do {
	 index = row;
	 while (index < nmr_rows && (zero = (a[index][column] == 0)))
	    ++index;
	 if (zero)
	    if (column < bound)  
	       ++column;
	    else 
	       return; 
      } while (zero);

      /* if necessary, interchange current row with row index */
      if (index > row) {
	 for (j = column; j < nmr_columns; ++j) {
	    val = a[index][j];
	    a[index][j] = a[row][j];
	    a[row][j] = val;
	 }
      }

      /* multiply row by the inverse in GF(p) of a[row][column] */
      if ((entry = a[row][column]) != 1) {
	 val = pga->inverse_modp[entry];
	 a[row][column] = 1;
	 for (j = column + 1; j < nmr_columns; ++j)
	    a[row][j] = (a[row][j] * val) % p;
      }

      /* now zero out all other entries in this column */
      for (i = 0; i < nmr_rows; ++i) {
	 if (a[i][column] == 0 || i == row) continue;
	 val = p - a[i][column];
	 a[i][column] = 0;
	 for (j = column + 1; j < nmr_columns; ++j)
	    a[i][j] = (a[i][j] + val * a[row][j]) % p;
      }
   }
}
