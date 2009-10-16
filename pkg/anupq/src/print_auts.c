/****************************************************************************
**
*A  print_auts.c                ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: print_auts.c,v 1.5 2001/06/15 14:31:51 werner Exp $
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

/* list the actions of the nmr_auts automorphisms on the 
   nmr_gens generators of the group */

void Aprint_auts (nmr_auts, nmr_gens, auts, pcp)
int nmr_auts;
int nmr_gens;
int ***auts;
struct pcp_vars *pcp;
{
   register int i, j, k, x;
   FILE_TYPE output_file;
   char *file_name;
  int image;

   file_name = allocate_char_vector (MAXWORD + 1, 0, FALSE);

   sprintf (file_name, "auts%d^%d", pcp->p, pcp->lastg);
   /* open the file in update mode */
   output_file = OpenFile (file_name, "a+");

   fprintf (output_file, "[");

   for (i = 1; i <= nmr_auts; ++i) {
      for (j = 1; j <= nmr_gens; ++j) {
image = 0;
	 for (k = 1; k <= pcp->lastg; ++k)
            if (auts[i][j][k] != 0)
               image = 10*image + k;
         
         fprintf (output_file, "%d", image);
      if (i == nmr_auts && j == nmr_gens) 
         x = 1;
      else fprintf (output_file, ",");
/* 
            if (auts[i][j][k] != 0)
               fprintf (output_file, "%d ", k);
               fprintf (output_file, "%d ", auts[i][j][k]);
*/
      }
   }
	 fprintf (output_file, "],\n");

  CloseFile (output_file);

   free (file_name);
}

void print_auts (nmr_auts, nmr_gens, auts, pcp)
int nmr_auts;
int nmr_gens;
int ***auts;
struct pcp_vars *pcp;
{
   register int i, j, k;

   for (i = 1; i <= nmr_auts; ++i) {
      printf ("Automorphism %d:\n", i);
      for (j = 1; j <= nmr_gens; ++j) {
	 printf ("Generator %2d --> ", j);
	 for (k = 1; k <= pcp->lastg; ++k)
	    printf ("%d ", auts[i][j][k]);
	 printf ("\n");
      }
   }
}
