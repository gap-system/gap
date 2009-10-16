/****************************************************************************
**
*A  defaults_pga.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: defaults_pga.c,v 1.5 2001/06/15 14:31:51 werner Exp $
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
#define SINGLE_STAGE 5

/* set up algorithm and print defaults for p-group generation calculation */

void defaults_pga (option, k, flag, pga, pcp)
int option;
int *k;
struct pga_vars *flag;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int default_algorithm;
   int default_output;
   int default_perm_info; 
   int default_group_info;
   int default_orbit_info;
   int default_automorphism_info;

   set_defaults (flag);

   if (option == SINGLE_STAGE)
      read_step_size (pga, pcp);
   flag->step_size = pga->step_size;

   query_solubility (flag);

   read_value (TRUE, "Do you want default algorithm? ", 
	       &default_algorithm, INT_MIN);
   if (!default_algorithm) {
      read_subgroup_rank (k);
      if (flag->soluble)
	 query_space_efficiency (flag);
      query_terminal (flag);
      query_exponent_law (flag);
      query_metabelian_law (flag);
   }      
   else {
      *k = 0;
   }

   read_value (TRUE, "Do you want default output? ", &default_output, INT_MIN);
   if (default_output) return;
       
   read_value (TRUE, "Do you want default permutation group output? ", 
	       &default_perm_info, INT_MIN);
   if (!default_perm_info)  {
      query_degree_aut_information (flag);
      query_perm_information (flag);
   }

   read_value (TRUE, "Do you want default orbit information? ", 
	       &default_orbit_info, INT_MIN);
   if (!default_orbit_info)  
      query_orbit_information (flag);

   read_value (TRUE, "Do you want default group information? ", 
	       &default_group_info, INT_MIN);
   if (!default_group_info)  
      query_group_information (pcp->p, flag);

   read_value (TRUE, "Do you want default automorphism group information? ", 
	       &default_automorphism_info, INT_MIN);
   if (!default_automorphism_info) 
      query_aut_group_information (flag);

   read_value (TRUE, "Do you want algorithm trace information? ", 
	       &flag->trace, INT_MIN);
}

/* set printing and algorithm defaults up in flag structure for storage */

void set_defaults (flag)
struct pga_vars *flag;
{
   flag->print_extensions = FALSE;
   flag->print_automorphism_matrix = FALSE;

   flag->print_degree = FALSE;
   flag->print_permutation = FALSE;

   flag->print_subgroup = FALSE;
   flag->print_reduced_cover = FALSE;
   flag->print_group = FALSE;
   flag->print_nuclear_rank = FALSE;
   flag->print_multiplicator_rank = FALSE;

   flag->print_orbit_summary = FALSE;
   flag->print_orbits = FALSE;
   flag->print_orbit_arrays = FALSE;

   flag->print_commutator_matrix = FALSE;
   flag->print_automorphisms = FALSE;
   flag->print_automorphism_order = FALSE;
   flag->print_stabiliser_array = FALSE;

   flag->trace = FALSE;

   flag->space_efficient = FALSE;
   flag->soluble = TRUE;
   flag->terminal = FALSE;
   flag->metabelian = FALSE;
   flag->exponent_law = 0;
}

/* copy printing and algorithm defaults from flag structure to pga */

void copy_flags (flag, pga) 
struct pga_vars *flag;
struct pga_vars *pga;
{
   pga->print_extensions = flag->print_extensions;
   pga->print_automorphism_matrix = flag->print_automorphism_matrix;

   pga->print_degree = flag->print_degree;
   pga->print_permutation = flag->print_permutation;

   pga->print_subgroup = flag->print_subgroup;
   pga->print_reduced_cover = flag->print_reduced_cover; 
   pga->print_group = flag->print_group;
   pga->print_nuclear_rank = flag->print_nuclear_rank;
   pga->print_multiplicator_rank = flag->print_multiplicator_rank;

   pga->print_orbits = flag->print_orbits;
   pga->print_orbit_summary = flag->print_orbit_summary;
   pga->print_orbit_arrays = flag->print_orbit_arrays;

   pga->print_commutator_matrix = flag->print_commutator_matrix;
   pga->print_automorphisms = flag->print_automorphisms;
   pga->print_automorphism_order = flag->print_automorphism_order;
   pga->print_stabiliser_array = flag->print_stabiliser_array;

   pga->trace = flag->trace;

   pga->space_efficient = flag->space_efficient;
   pga->soluble = flag->soluble;
   pga->terminal = flag->terminal;
   pga->exponent_law = flag->exponent_law;
   pga->metabelian = flag->metabelian;

   pga->step_size = flag->step_size;
}

/* use space efficient option? */

void query_space_efficiency (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "Space efficient computation? ", 
	       &pga->space_efficient, INT_MIN);
}

/* orbit information to be printed */

void query_orbit_information (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "Summary of orbit information? ", 
	       &pga->print_orbit_summary, INT_MIN);

   read_value (TRUE, "Complete listing of orbits? ", 
	       &pga->print_orbits, INT_MIN);

   pga->print_orbit_arrays = FALSE;
}

/* group information to be printed */

void query_group_information (p, pga)
int p;
struct pga_vars *pga;
{
   read_value (TRUE, "Print standard matrix of allowable subgroup? ", 
	       &pga->print_subgroup, INT_MIN);

   read_value (TRUE, "Presentation of reduced p-covering groups? ", 
	       &pga->print_reduced_cover, INT_MIN);

   read_value (TRUE, "Presentation of immediate descendants? ",
	       &pga->print_group, INT_MIN);

   read_value (TRUE, "Print nuclear rank of descendants? ", 
	       &pga->print_nuclear_rank, INT_MIN);

   read_value (TRUE, "Print p-multiplicator rank of descendants? ",
	       &pga->print_multiplicator_rank, INT_MIN);
}

/* automorphism group information to be printed */

void query_aut_group_information (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "Print commutator matrix? ", 
	       &pga->print_commutator_matrix, INT_MIN);

   read_value (TRUE, "Automorphism group description of descendants? ",
	       &pga->print_automorphisms, INT_MIN);

#if defined (LARGE_INT) 
   read_value (TRUE, "Automorphism group order of descendants? ",
	       &pga->print_automorphism_order, INT_MIN);
#endif 

   pga->print_stabiliser_array = FALSE;
}

/* degree and extended automorphism information to be printed */

void query_degree_aut_information (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "Print degree of permutation group? ",
	       &pga->print_degree, INT_MIN);

   read_value (TRUE, "Print extended automorphisms? ",
	       &pga->print_extensions, INT_MIN);
}

/* other permutation group information to be printed */

void query_perm_information (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "Print automorphism matrices? ",
	       &pga->print_automorphism_matrix, INT_MIN);

   read_value (TRUE, "Print permutations? ", &pga->print_permutation, INT_MIN);
}

/* read step size */

void read_step_size (pga, pcp) 
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   Logical reading = TRUE;

   while (reading) {
      read_value (TRUE, "Input step size: ", &pga->step_size, 1);
      reading = (pga->step_size <= 0);
      if (isatty ()) reading = (reading || (pga->step_size > pcp->newgen)); 
      if (reading) 
	 printf ("Error: step sizes range from 1 to %d only\n", pcp->newgen);
      /*
	if (reading = (pga->step_size <= 0 || pga->step_size > pcp->newgen)) 
	printf ("Error: step sizes range from 1 to %d only\n", pcp->newgen);
	*/
   }
}

/* read class bound */

void read_class_bound (class_bound, pcp) 
int *class_bound;
struct pcp_vars *pcp;
{
   read_value (TRUE, "Input class bound on descendants: ", 
	       class_bound, pcp->cc);
}

/* read order bound */

void read_order_bound (order_bound, pcp) 
int *order_bound;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int least_order = y[pcp->clend + pcp->cc - 1] + 1;
   read_value (TRUE, "Input order bound on descendants: ", 
	       order_bound, least_order);
}

/* read rank of initial-segment subgroup */

void read_subgroup_rank (k)
int *k;
{
   read_value (TRUE, "Rank of the initial segment subgroup? ", k, 0);
   *k = MAX(0, *k - 1);
}

/* supply a PAG-generating sequence for automorphism group? */

void query_solubility (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "PAG-generating sequence for automorphism group? ", 
	       &pga->soluble, INT_MIN);
}

/* completely process all (capable and terminal) descendants? */

void query_terminal (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "Completely process terminal descendants? ", 
	       &pga->terminal, INT_MIN);
}

/* set exponent law for all descendants to satisfy */

void query_exponent_law (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "Input exponent law (0 if none): ", &pga->exponent_law,
	       INT_MIN);
}

/* enforce metabelian law on all descendants */

void query_metabelian_law (pga)
struct pga_vars *pga;
{
   read_value (TRUE, "Enforce metabelian law? ", &pga->metabelian, INT_MIN);
}
