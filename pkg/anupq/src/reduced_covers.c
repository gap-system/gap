/****************************************************************************
**
*A  reduced_covers.c            ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: reduced_covers.c,v 1.3 2001/06/15 14:31:52 werner Exp $
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

void trace_details ();

/* default processing -- 
   1. calculate the extended automorphisms 
   2. characteristically close k-initial segment subgroup 
   3. calculate the relevant permutations of the allowable 
      subgroups relative to this subgroup 
   4. compute orbits of the allowable subgroups and choose 
      the representatives of these orbits 
   4. factor each orbit representative to obtain descendant
   5. save presentation + automorphisms to file 
   
   return the number of reduced p-covering groups constructed */

int reduced_covers (descendant_file, covers_file, k, auts, pga, pcp)
FILE_TYPE descendant_file;
FILE_TYPE covers_file;
int k;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int lower_step, upper_step;
   int nmr_of_covers = 0;
   int *a, *b;                  /* arrays needed for orbit calculation */
   char *c;                     /* array needed for stabiliser calculation */
   int **perms;                 /* store all permutations */
   int *orbit_length;           /* length of orbits */
   FILE_TYPE LINK_input;        /* input file for CAYLEY, Magma or GAP */
   Logical process_fork = FALSE; /* has GAP process forked? */        
   Logical soluble_group;       /* indicates that orbits and stabilisers may 
				   be computed using soluble machinery */

   /* calculate the extended automorphisms */
   extend_automorphisms (auts, pga->m, pcp);
   if (pcp->overflow) return;

   if (pga->print_extensions && pga->m != 0) {  
      printf ("\nThe extension%s:\n", pga->m == 1 ? " is" : "s are");
      print_auts (pga->m, pcp->lastg, auts, pcp);
   }

   /* find range of permitted step sizes */
   step_range (k, &lower_step, &upper_step, auts, pga, pcp);

   /* set up space for definition sets */
   store_definition_sets (pga->r, lower_step, upper_step, pga);

   /* loop over each permitted step size */ 
   for (pga->s = lower_step; pga->s <= upper_step; ++pga->s) {

      if (pga->trace)
	 trace_details (pga);

      get_definition_sets (pga);
      compute_degree (pga);

      /* establish which automorphisms induce the identity 
	 on the relevant subgroup of the p-multiplicator */
      strip_identities (auts, pga, pcp);

      /* if possible, use the more efficient soluble code --
	 in particular, certain extreme cases can be handled */
      soluble_group = (pga->soluble || pga->Degree == 1 || 
		       pga->nmr_of_perms == 0);

      if (!soluble_group) {
#if defined (CAYLEY_LINK)
	 start_CAYLEY_file (&LINK_input, auts, pga);
#else
#if defined (Magma_LINK)
	 start_Magma_file (&LINK_input, auts, pga);
#else
#if defined (GAP_LINK) 
	 if (!process_fork) {
	    start_GAP_file (auts, pga);
	    process_fork = TRUE;
	 }
	 StartGapFile (pga);
#else
#if defined (GAP_LINK_VIA_FILE) 
	 start_GAP_file (&LINK_input, auts, pga, pcp);
#endif
#endif
#endif
#endif
      }

      perms = permute_subgroups (LINK_input, &a, &b, &c, auts, pga, pcp);

      if (!pga->space_efficient) 
	 if (soluble_group)
	    compute_orbits (&a, &b, &c, perms, pga);
	 else
	    insoluble_compute_orbits (&a, &b, &c, perms, pga);

      orbit_length = find_orbit_reps (a, b, pga);

      if (pga->print_orbit_summary)
	 orbit_summary (orbit_length, pga);

      if (soluble_group && pga->print_orbit_arrays)
	 print_orbit_information (a, b, c, pga);

      pga->final_stage = (pga->q == pga->multiplicator_rank);

      if (!soluble_group) {
#if defined (CAYLEY_LINK) || defined (Magma_LINK) || defined (GAP_LINK_VIA_FILE) 
	 CloseFile (LINK_input);
#endif 
      }

      setup_reps (pga->rep, pga->nmr_orbits, orbit_length, perms, a, b, c, 
		  auts, descendant_file, covers_file, pga, pcp);

      if (!pga->final_stage)
	 nmr_of_covers += pga->nmr_orbits;

      free_space (soluble_group, perms, orbit_length, 
		  a, b, c, pga); 
   }     

#if defined (GAP_LINK)
   if (process_fork) 
      QuitGap ();
#endif 

   free_vector (pga->list, 0);
   free_vector (pga->available, 0);
   free_vector (pga->offset, 0);

   return nmr_of_covers;
}

/* print algorithm trace details for group */

void trace_details (pga)
struct pga_vars *pga;
{
   printf ("\n------------------------------------------------------\n");
   printf ("Processing step size %d\n", pga->s);
   printf ("The value of FIXED is %d\n", pga->fixed);
   printf ("The rank of the initial segment subgroup is %d\n", pga->q);
}
