/****************************************************************************
**
*A  construct.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: construct.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "exp_vars.h"
#include "constants.h"
#include "pq_functions.h"
#define ITERATION 6
#define SINGLE_STAGE 5

/* prepare to construct, partially or completely, some or all of the 
   immediate descendants of group group_nmr stored on start_file */

int construct (call_depth, flag, option, output_file, start_file, k, 
               order_bound, group_nmr, pga, pcp)
int call_depth;
struct pga_vars *flag;
int option;
FILE_TYPE output_file;
FILE_TYPE start_file;
int k;
int order_bound;
int group_nmr;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int ***auts;
   char *name;
   register int step;
   int min_step, max_step;
   int nmr_of_descendants = 0;
   int nmr_of_capables = 0; 
   int nmr_of_covers;
   int x_dim, y_dim;
   FILE_TYPE tmp_file;
   Logical change;

   if (option == ITERATION) {
      restore_pcp (start_file, pcp);
      auts = restore_pga (start_file, pga, pcp);
      /* enforce any law on the p-covering group of starting group */
      if (call_depth == 1)  
	 enforce_laws (flag, pga, pcp);
      start_group (&tmp_file, auts, pga, pcp);
   }
   else {
      auts = restore_group (TRUE, start_file, group_nmr, pga, pcp);
      RESET(start_file);
   }


   /* save dimension of autormorphism array for later call to free */
   x_dim = pga->m;
   y_dim = pcp->lastg;

   pga->nmr_of_descendants = 0;
   pga->nmr_of_capables = 0;

   switch (option) {

   case SINGLE_STAGE:
      defaults_pga (option, &k, flag, pga, pcp);
      copy_flags (flag, pga);
      name = GetString ("Input output file name: ");
      output_file = OpenFileOutput (name);
      enforce_laws (flag, pga, pcp);
      print_group_details (pga, pcp);
      nmr_of_covers = reduced_covers (output_file, output_file, k, 
				      auts, pga, pcp);
      if (pcp->overflow) exit (FAILURE);
      nmr_of_descendants = pga->nmr_of_descendants;
      nmr_of_capables = pga->nmr_of_capables;
      report (nmr_of_capables, nmr_of_descendants, nmr_of_covers, pga, pcp);
      auts = restore_group (TRUE, start_file, group_nmr, pga, pcp);
      RESET(start_file);
      RESET(output_file);
      break;

   case ITERATION:
      print_group_details (pga, pcp);
      /* check if automorphism group is now soluble */
      change = (pga->soluble == LINK_SOLUBLE_FLAG);
      copy_flags (flag, pga);
      if (change) pga->soluble = LINK_SOLUBLE_FLAG;
      if (!select_group (&min_step, &max_step, order_bound, pga, pcp)) {
	 free_array (auts, x_dim, y_dim, 1);
	 CloseFile (tmp_file);
	 break;
      }

      for (step = min_step; step <= max_step; ++step) {
	 pga->step_size = step;
	 start_stage (output_file, k, auts, pga, pcp);
	 report (pga->nmr_of_capables - nmr_of_capables, 
		 pga->nmr_of_descendants - nmr_of_descendants, 0, pga, pcp);
	 nmr_of_descendants = pga->nmr_of_descendants;
	 nmr_of_capables = pga->nmr_of_capables; 
	 free_array (auts, x_dim, y_dim, 1);
	 if (step != max_step) {
	    auts = restore_group (TRUE, tmp_file, 1, pga, pcp);
	    RESET(tmp_file);
	 }
	 pga->nmr_of_descendants = nmr_of_descendants;           
	 pga->nmr_of_capables = nmr_of_capables;
	 change = (pga->soluble == LINK_SOLUBLE_FLAG);
	 copy_flags (flag, pga);
	 if (change) pga->soluble = LINK_SOLUBLE_FLAG;
      }
      CloseFile (tmp_file);
      break;
   }                            /* switch */

   /* were terminal groups processed? */
   if (pga->terminal)
      return nmr_of_descendants;
   else 
      return nmr_of_capables;
}

/* report on the number immediate descendants and on those capable */

void report (nmr_of_capables, nmr_of_descendants, nmr_of_covers, pga, pcp)
int nmr_of_capables, nmr_of_descendants, nmr_of_covers;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

/* 
  FILE_TYPE COUNT;
  COUNT = OpenFile ("COUNT", "a+");
  fprintf (COUNT, "%d,\n", nmr_of_descendants);
*/

   if (nmr_of_descendants != 0) {
      printf ("# of immediate descendants of order %d^%d is %d\n", pcp->p, 
      y[pcp->clend + pcp->cc - 1] + pga->step_size,  nmr_of_descendants);
      if (nmr_of_capables != 0) 
	 printf ("# of capable immediate descendants is %d\n", nmr_of_capables);
   }
   else if (nmr_of_covers != 0) 
      printf ("# of reduced %d-covering groups is %d\n", pcp->p, nmr_of_covers);
}

/* print out basic information about the starting group */

void print_group_details (pga, pcp)
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"
   int order;

   printf ("\n**************************************************\n");
   printf ("Starting group: %s\n", pcp->ident);
   order = pcp->newgen ? y[pcp->clend + pcp->cc - 1] : y[pcp->clend + pcp->cc];
   printf ("Order: %d^%d\n", pcp->p, order);
   printf ("Nuclear rank: %d\n", pga->nuclear_rank);
   printf ("%d-multiplicator rank: %d\n", pga->p, pga->multiplicator_rank);
}

/* check if the group is a valid starting group */

Logical select_group (min_step, max_step, order_bound, pga, pcp)
int *min_step;
int *max_step;
int order_bound;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int max_extension = order_bound - y[pcp->clend + pcp->cc - 1];
   Logical select = TRUE;

   if (pga->step_size == ALL) {
      *max_step = MIN(pcp->newgen, max_extension); 
      if (*max_step <= 0) {
	 invalid_group (pcp);
	 return FALSE;
      }
      else 
	 *min_step = 1;
   }
        
   else {
      if (pga->step_size > pcp->newgen || pga->step_size > max_extension) {
	 invalid_group (pcp);
	 return FALSE;
      }
      else
	 *min_step = *max_step = pga->step_size;
   }

   return select;
}

/* print a message that the group is not a valid starting group */

void invalid_group (pcp)
struct pcp_vars *pcp;
{
   printf ("Group %s is an invalid starting group\n", pcp->ident); 
}

/* enforce laws on p-covering group of starting group --
   these include exponent and metabelian laws */

void enforce_laws (flag, pga, pcp)
struct pga_vars *flag;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   struct exp_vars exp_flag;

   if (flag->exponent_law != 0) {
      initialise_exponent (&exp_flag, pcp);
      pcp->extra_relations = flag->exponent_law;
#ifdef Magma
      extra_relations (&exp_flag, NULL_HANDLE, pcp);
#else
      extra_relations (&exp_flag, pcp);
#endif
      eliminate (FALSE, pcp);
      set_values (pga, pcp);
   }
}
