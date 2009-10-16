/****************************************************************************
**
*A  invert_auts.c               ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: invert_auts.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "pq_functions.h"

/* developmental code -- not finished */

void new_collect_image_of_string ();

/* for each automorphism, compute its inverse */

int*** invert_automorphisms (auts, pga, pcp)
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int alpha;
   int ***inverse;
   int nmr_of_bytes = pcp->lastg;
   int **Power;
   int string = pcp->lused + pcp->lastg;
   int cp = pcp->submlg - pcp->lastg - 2;
   register int i, j;
   int loop;

   inverse = allocate_array (pga->m, pcp->lastg, pcp->lastg, TRUE); 
   Power = allocate_matrix (pcp->lastg, pcp->lastg, 1, FALSE); 

   for (alpha = 1; alpha <= pga->m; ++alpha) { 
      printf ("Processing alpha_%d\n", alpha);

      Copy_Matrix (auts[alpha], inverse[alpha], pcp->lastg, nmr_of_bytes);
      Copy_Matrix (auts[alpha], Power, pcp->lastg, nmr_of_bytes);

      loop = 0;
      while (!is_identity (Power, pcp->lastg, 1)) {

	 ++loop;
	 printf ("loop is %d\n", loop);
	 Copy_Matrix (Power, inverse[alpha], pcp->lastg, nmr_of_bytes);

	 for (i = 1; i <= pcp->lastg; ++i) {
	    image_to_word (string, Power[i], pcp);
	    for (j = 1; j <= pcp->lastg; ++j)
	       y[cp + j] = 0;
	    collect_image_of_string (string, cp, auts[alpha], pcp);
	    for (j = 1; j <= pcp->lastg; ++j)
	       Power[i][j] = y[cp + j];
	    print_matrix (Power, pcp->lastg, pcp->lastg, 1);
	 }
      }
   }

   return inverse;
}

/* collect image of supplied string under the action of
   supplied automorphism, auts, and store the result at cp */

void new_collect_image_of_string (string, cp, auts, pcp)
int string;
int cp;
int **auts;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   int generator, exp;
   int length = y[string + 1];  /* last element of string
				   is in p-multiplicator */
#include "access.h"

   /* collect the string generator by generator */
   for (i = 1; i <= length; ++i) {
      generator = FIELD2 (y[string + 1 + i]);
      exp = FIELD1 (y[string + 1 + i]);
      while (exp > 0) {
	 collect_image_of_generator (cp, auts[generator], pcp);
	 --exp;
      }
   }
}


/* convert image of generator to word with base address string */

void image_to_word (string, image, pcp)
int string;
int *image;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i; 
   register int length = 0;
#include "access.h"

   for (i = 1; i <= pcp->lastg; ++i)
      if (image[i] != 0) {
	 ++length;
	 y[string + length + 1] = PACK2 (image[i], i);
      }
   y[string + 1] = length + 1;
}

void Copy_Matrix (A, B, nmr_of_rows, nmr_of_bytes)
int **A;
int **B;
int nmr_of_rows;
int nmr_of_bytes;
{
   register int i, j;
   for (i = 1; i <= nmr_of_rows; ++i)
      for (j = 1; j <= nmr_of_bytes; ++j)
	 B[i][j] = A[i][j];

   /* memcpy (B[i], A[i], nmr_of_bytes); */
}
