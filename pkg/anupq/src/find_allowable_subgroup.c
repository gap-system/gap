/****************************************************************************
**
*A  find_allowable_subgroup.c   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: find_allowable_subgroup.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (STANDARD_PCP)
#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "pq_functions.h"
#include "standard.h"

/* given a presentation for the p-covering group of a 
   class c p-quotient; find the allowable subgroup which 
   determines the presentation for the class c + 1 quotient; 
   set up its definition set both as a bit_string and as a subset */

int **find_allowable_subgroup (option, cover_tmp_file, group_tmp_file, 
                               bit_string, subset, pga, pcp)
int option;
FILE_TYPE cover_tmp_file;
FILE_TYPE group_tmp_file;
int *bit_string;
int **subset;
struct pga_vars *pga;
struct pcp_vars *pcp;
{ 
#include "define_y.h"

   register int generator, exp, r, i;
   register int structure, lastg; 
   register int start = pcp->ccbeg;
   register int q = pga->q;
   register int end = start + q - 1;
   register int pointer;
   register int length;
   register int u, v;
   int **definition;
   int *relation;
   int **subgroup;
   int index, x;
   int nmr_defs;
#include "access.h"

   /* restore the presentation for the p-covering group */
   restore_pcp (cover_tmp_file, pcp);
   RESET (cover_tmp_file);

   definition = allocate_matrix (q, 2, 0, FALSE);

   structure = pcp->structure;

   /* store the definitions of the generators of the relevant 
      initial segment subgroup of the p-multiplicator */
   for (generator = start; generator <= end; ++generator) {
      pointer = y[structure + generator];
      u = PART2 (pointer);
      v = PART3 (pointer);
      definition[generator - start][0] = u;
      definition[generator - start][1] = v;
   }

#if defined (DEBUG)
   printf ("The definition matrix is\n");
   print_matrix (definition, q, 2);
#endif

   /* now restore the presentation for the class c + 1 quotient */
   restore_pcp (group_tmp_file, pcp);
   RESET (group_tmp_file);

#if defined (DEBUG)
   pcp->diagn = TRUE;
   print_presentation (TRUE, pcp);
   pcp->diagn = FALSE;
#endif

   structure = pcp->structure;
   lastg = pcp->lastg;

   subgroup = allocate_matrix (pga->s, q, 0, TRUE);
   relation = allocate_vector (q, 0, TRUE);

   *bit_string = 0;
   *subset = allocate_vector (lastg - start + 1, 0, FALSE);

   /* check the values of the definitions in this quotient 
      and set up its definition set */
   index = 0; 
   for (generator = start; generator <= lastg; ++generator) {
      pointer = y[structure + generator];
      u = PART2 (pointer);
      v = PART3 (pointer);
      if ((x = find_index (u, v, definition, q)) != -1) {
	 *bit_string |= 1 << x;
	 (*subset)[index] = x;
	 subgroup[index++][x]= 1;
	 relation[x] = TRUE;
      }
      else {
	 (*subset)[index++] = -1;
      }
   }

#if defined (DEBUG)
   printf ("Bit string and matrix are %d and ", *bit_string);
   print_array (*subset, 0, lastg - start);
#endif
      
   if (option == RELATIVE) {
      nmr_defs = 0;
      for (i = 0; i < lastg - start + 1; ++i)
	 if ((*subset)[i] >= 0) 
	    ++nmr_defs;
      pga->s = nmr_defs;

      /* memory leakage September 1996 */
      free_matrix (definition, q, 0);
      free_vector (relation, 0);
      free_matrix (subgroup, pga->s, 0);
      free_vector (*subset, 0);
      *subset = (int *) 0;
 
      return (int **) 0;
   }

   /* look up necessary relations in the class c + 1 quotient 
      and store the appropriate exponents in subgroup matrix */
   for (r = 0; r < q; ++r) {
      if (relation[r] == TRUE)
	 continue;
      
      u = definition[r][0];
      v = definition[r][1];
  
      /* look up u^p or [u, v] */
      pointer = (v == 0) ? y[pcp->ppower + u] : y[y[pcp->ppcomm + u] + v];
      
      /* set up the exponents of these relations in the subgroup matrix */ 
      if (pointer > 0)
	 subgroup[pointer - start][r] = 1;
      else if (pointer < 0) {
	 pointer = -pointer + 1;
	 length = y[pointer];
	 for (i = 1; i <= length; i++) {
	    exp = FIELD1 (y[pointer + i]);
	    generator = FIELD2 (y[pointer + i]);
	    if (generator >= start)
	       subgroup[generator - start][r] = exp;
	 }
      }
   }

#if defined (DEBUG)
   printf ("The subgroup matrix is\n");
   print_matrix (subgroup, pga->s, q);
#endif 

   free_matrix (definition, q, 0);
   free_vector (relation, 0);

   return subgroup;
}

/* which generator of the p-covering group did u and v define? */

int find_index (u, v, definition, q)
int u, v;
int **definition;
int q;
{
   register int i;

   for (i = 0; i < q; ++i)  
      if (u == definition[i][0] && v == definition[i][1])  
	 return i;

   return -1;
}
#endif 
