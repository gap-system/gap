/****************************************************************************
**
*A  iteration.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: iteration.c,v 1.4 2001/12/20 11:26:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "pq_functions.h"
#define ITERATION 6

/* this procedure controls each iteration of the generation algorithm; 
   it is called recursively and sets out to construct the immediate 
   descendants of some or all of the groups present on input_file; 
   
   call_depth is the level of recursion; 
   class_bound, step_sequence, order_bound are set up in iteration_information; 
   subgroup_rank is the rank of the initial segment subgroup; 
   flag is a copy of the basic pga flags */

void iteration (call_depth, step_sequence, subgroup_rank, flag, input_file, 
                nmr_of_descendants, class_bound, order_bound, pga, pcp) 
int call_depth;
int *step_sequence;
int subgroup_rank;
struct pga_vars *flag;
FILE_TYPE input_file;
int nmr_of_descendants;
int class_bound;
int order_bound;
struct pga_vars *pga;
struct pcp_vars *pcp;
{  
   int ***auts;
   register int group_nmr, first = 1;
   int next_class = 0;
   FILE_TYPE descendant_file;
   char name[MAXWORD];
   char *s, *t;

   if (step_sequence != NULL) {
      pga->step_size = step_sequence[call_depth];
      flag->step_size = step_sequence[call_depth];
   }

   CreateName (name, call_depth, pcp);

   if (call_depth == 1) {
      first = nmr_of_descendants;
      if (nmr_of_descendants > 1) {
	 auts = restore_group (FALSE, input_file, nmr_of_descendants - 1, 
			       pga, pcp);
	 free_array (auts, pga->m, pcp->lastg, 1);
      }
   }

   descendant_file = OpenFile (name, "w+");

   for (group_nmr = first; group_nmr <= nmr_of_descendants; ++group_nmr)
      next_class += construct (call_depth, flag, ITERATION, descendant_file, 
			       input_file, subgroup_rank, order_bound, group_nmr, pga, pcp);
   
   if (call_depth != 1) 
      CloseFile (input_file);

   if (next_class != 0) {
      RESET(descendant_file);
      printf ("\n**************************************************\n");
      s = (next_class == 1) ? "" : "s";
      t = (pga->terminal) ? "" : " capable";
      printf ("%d%s group%s saved on file %s\n", next_class, t, s, name);
      if ((pcp->newgen == 0 && pcp->cc < class_bound  - 1) 
	  || (pcp->newgen != 0 && pcp->cc < class_bound))  
	 iteration (call_depth + 1, step_sequence, subgroup_rank, flag, 
		    descendant_file, next_class, class_bound, order_bound, pga, pcp);
   }
   else
      CloseFile (descendant_file);
}

/* set up output file name */

void CreateName (name, call_depth, pcp) 
char *name;
int call_depth;
struct pcp_vars *pcp;
{
   register int i, adjoin;

   for (i = 0; i <= (int) strlen (pcp->ident) && pcp->ident[i] != ' '; ++i)
      name[i] = pcp->ident[i];
   name[i] = '\0';

   strcat (name, "_class");

   if (call_depth == 1) 
      adjoin = pcp->cc;
   else if (pcp->newgen == 0) 
      adjoin = pcp->cc + 2;
   else 
      adjoin = pcp->cc + 1;

   sprintf (name + strlen (name), "%d\0", adjoin);
}
