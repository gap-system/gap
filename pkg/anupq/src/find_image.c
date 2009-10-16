/****************************************************************************
**
*A  find_image.c                ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: find_image.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "pq_functions.h"

/* find the image of the allowable subgroup having supplied label under 
   the action of automorphism; compute and return its label */

int find_image (label, auts, pga, pcp)
int label;
int **auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int index;
   int **A;
   int **Image, **Image_transpose;
   int **S, **S_transpose;
   int *subset;
   int K;

   subset = allocate_vector (pga->s, 0, 0);

   A = allocate_matrix (pga->q, pga->q, 0, FALSE);
   assemble_matrix (A, pga->q, auts, pcp);

   S = label_to_subgroup (&index, &subset, label, pga);
   S_transpose = transpose (S, pga->s, pga->q);
   Image_transpose = multiply_matrix (A, pga->q, pga->q, 
				      S_transpose, pga->s, pga->p);
   Image = transpose (Image_transpose, pga->q, pga->s);
   K = echelonise_matrix (Image, pga->s, pga->q, pga->p, subset, pga);

   free_matrix (A, pga->q, 0);
   free_matrix (S, pga->s, 0);
   free_matrix (S_transpose, pga->q, 0);
   free_matrix (Image_transpose, pga->q, 0);

   label = subgroup_to_label (Image, K, subset, pga);
   free_matrix (Image, pga->s, 0);
   free_vector (subset, 0);

   return label;
}
