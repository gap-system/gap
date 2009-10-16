/****************************************************************************
**
*A  start_iteration.c           ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: start_iteration.c,v 1.3 2001/06/15 14:31:52 werner Exp $
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

/* read class and order bounds and step size information 
   required in iteration of the algorithm */

void iteration_information (subgroup_rank, flag, class_bound, order_bound, step_sequence, pga, pcp)
int *subgroup_rank;
struct pga_vars *flag;
int *class_bound;
int *order_bound;
int **step_sequence;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   Logical All, Constant;
   int nmr_iterations;
   register int i;

   read_class_bound (class_bound, pcp);

   read_value (TRUE, "Construct all descendants? ", &All, INT_MIN);
   if (All) {
      pga->step_size = ALL;
      read_value (TRUE, "Set an order bound on the descendants? ", 
		  order_bound, INT_MIN);
      if (*order_bound)
	 read_order_bound (order_bound, pcp);
      else
	 *order_bound = ALL;
   }
   else
      *order_bound = ALL;

   nmr_iterations = *class_bound - pcp->cc + 1;

   if (!All) {
      if (nmr_iterations != 1) {
	 read_value (TRUE, "Constant step size? ", &Constant, INT_MIN);
      }
      if (Constant || nmr_iterations == 1) {
	 read_step_size (pga, pcp);
	 Constant = TRUE;
      }
   }

   if (!All && !Constant) {
      *step_sequence = allocate_vector (nmr_iterations, 1, 0);
      printf ("Input %d step sizes: ", nmr_iterations);
      for (i = 1; i < nmr_iterations; ++i)    
	 read_value (FALSE, "", &(*step_sequence)[i], 1);
      read_value (TRUE, "", &(*step_sequence)[i], 1);
   }
   else
      *step_sequence = NULL;

   defaults_pga (ITERATION, subgroup_rank, flag, pga, pcp);
}
