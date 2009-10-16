/****************************************************************************
**
*A  setup_reps.c                ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: setup_reps.c,v 1.5 2001/06/15 14:31:52 werner Exp $
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
#include "global.h"
#include "standard.h"

/* factor out the allowable subgroups whose labels are listed
   in the array reps; assemble the necessary automorphism
   information and save the descriptions to file */

void setup_reps (reps, nmr_of_reps, orbit_length, perms, a, b, c, auts, 
                 descendant_file, covers_file, pga, pcp) 
int *reps;
int nmr_of_reps;
int *orbit_length;
int **perms;
int *a, *b;
char *c;
int ***auts;
FILE_TYPE descendant_file;
FILE_TYPE covers_file;
struct pga_vars *pga;
struct pcp_vars *pcp;
{ 

   char *d;                     /* used in stabiliser computation */
   FILE_TYPE tmp_file;
   struct pga_vars original;    /* copy of pga structure */
   register int i, ii;
   Logical soluble_group;       /* indicates that stabilisers may 
				   be computed using soluble machinery */

#if defined (LARGE_INT) 
   MP_INT original_aut;         /* copy of automorphism order */
#endif 

   soluble_group = (pga->soluble || pga->Degree == 1 || pga->nmr_of_perms == 0);

   tmp_file = TemporaryFile ();
   save_pcp (tmp_file, pcp);

   if (soluble_group) {
      d = find_permutation (b, c, pga);
      if (pga->print_stabiliser_array) {
	 printf ("The array D is \n"); 
	 print_chars (d, 1, pga->nmr_subgroups + 1);
      }
   }

#if defined (LARGE_INT) 
   /* first record current automorphism group order */
   mpz_init_set (&original_aut, &pga->aut_order);
   mpz_clear (&pga->aut_order);
#endif 

   /* keep copy of pga */
   original = *pga;

#if defined (LARGE_INT) 
   /* now reset automorphism order in pga */
   mpz_init_set (&pga->aut_order, &original_aut);
#endif 

   for (i = 1; i <= nmr_of_reps; ++i) {

      pga->fixed = pga->s;

      if (pga->final_stage) {
	 ++original.nmr_of_descendants;
	 update_name (pcp->ident, original.nmr_of_descendants, pga->s);
      }

      process_rep (perms, a, b, c, d, auts, reps[i], orbit_length[i], 
		   tmp_file, descendant_file, covers_file, pga, pcp);

      if (pga->final_stage && pga->capable) { 
	 ++original.nmr_of_capables;
	 if (pga->trace) 
	    printf ("Capable group #%d\n", original.nmr_of_capables);
      }

      /* revert to original pga structure */
      if (!StandardPresentation) {
#if defined (LARGE_INT) 
	 mpz_clear (&pga->aut_order);
#endif 

         *pga = original;                                                       

#if defined (LARGE_INT) 
	 mpz_init_set (&pga->aut_order, &original_aut);
#endif 
      }
   }
   
   if (soluble_group)
      free (++d);

#if defined (LARGE_INT) 
   mpz_clear (&original_aut);
#endif 

   CloseFile (tmp_file);
}

/* process orbit representative; if reduced p-covering group, 
   save description to covers_file, otherwise to descendant file */

void process_rep (perms, a, b, c, d, auts, rep, orbit_length, 
                  tmp_file, descendant_file, covers_file, pga, pcp)
int **perms;
int *a, *b;
char *c, *d;
int ***auts;
int rep;
int orbit_length;
FILE_TYPE tmp_file;
FILE_TYPE descendant_file;
FILE_TYPE covers_file;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"                                                           
   int index;
   int *subset;
   int ***central;
   int ***stabiliser;
   int **S;
   int *seq;
   FILE_TYPE file;
   FILE_TYPE GAP_library; 
   FILE_TYPE CAYLEY_library; 
   FILE_TYPE Magma_library; 
   int lused, rank_of_cover;
   int p = pga->p;
   int j;

   /* construct the presentation for the descendant and 
      assemble the necessary automorphism information */
   S = label_to_subgroup (&index, &subset, rep, pga);
   if (pga->print_subgroup) {
      printf ("The standard matrix for the allowable subgroup is:\n");
      print_matrix (S, pga->s, pga->q);
   }
   factorise_subgroup (S, index, subset, pga, pcp);
   free_matrix (S, pga->s, 0);

   free_vector (subset, 0);

   if ((pga->print_group && pga->final_stage) || pga->print_reduced_cover) {
      print_presentation (FALSE, pcp);
      print_structure (1, pcp->lastg, pcp);
      print_pcp_relations (pcp);
      printf ("\n");
   }

   if (pga->final_stage) {
      central = immediate_descendant (descendant_file, pga, pcp);

      /* should we write a compact description to file? */
      if ((pga->capable || pga->terminal) && (Compact_Description == TRUE  
&& (Compact_Order <= pcp->lastg || Compact_Order == 0))) {
	 seq = compact_description (TRUE, pcp);
	 free_vector (seq, 1);
      }

      /* should we write a description of group to CAYLEY/GAP/Magma file? */
      if (pga->capable || pga->terminal) {
	 if (Group_library == GAP_LIBRARY) {
	    if (Group_library_file != NULL) 
	       GAP_library = OpenFile (Group_library_file, "a+");
	    else 
	       GAP_library = OpenFile ("GAP_library", "a+");
	    write_GAP_library (GAP_library, pcp);
	    CloseFile (GAP_library);
	 }

	 if (Group_library == CAYLEY_LIBRARY) {
	    if (Group_library_file != NULL) 
	       CAYLEY_library = OpenFile (Group_library_file, "a+");
	    else 
	       CAYLEY_library = OpenFile ("CAYLEY_library", "a+");
	    write_CAYLEY_library (CAYLEY_library, pcp);
	    CloseFile (CAYLEY_library);
	 }

	 if (Group_library == Magma_LIBRARY) {
	    if (Group_library_file != NULL) 
	       Magma_library = OpenFile (Group_library_file, "a+");
	    else 
	       Magma_library = OpenFile ("Magma_library", "a+");
            setbuf (Magma_library, NULL);  
	    write_Magma_library (Magma_library, pcp);
	    CloseFile (Magma_library);
	 }
      }

      /* if the group is not capable and we do not want to 
	 process terminal groups, we are finished */
      if (!pga->capable && !pga->terminal) {
	 /* first restore the original p-covering group */
	 RESET(tmp_file);
	 restore_pcp (tmp_file, pcp);
	 return;
      }
   }
   else { 
      save_pcp (covers_file, pcp);
      /* if characteristic subgroup in nucleus, revise the nuclear rank */ 
      if (pga->s < pcp->newgen)
	 pcp->newgen = pga->nuclear_rank + pga->s - pga->q;
      set_values (pga, pcp);
      pga->nmr_centrals = 0;
   }

#if defined (LARGE_INT) 
   update_autgp_order (orbit_length, pga, pcp);
#endif 

   /* restore the original p-covering group before computing stabiliser */
   RESET(tmp_file);
   restore_pcp (tmp_file, pcp);

   /* note following information before computing stabiliser */
   rank_of_cover = pcp->lastg;
   lused = pcp->lused;

   stabiliser = stabiliser_of_rep (perms, rep, orbit_length,
				   a, b, c, d, auts, pga, pcp);

#if defined (LARGE_INT) 
   if (pga->final_stage) 
      report_autgp_order (pga, pcp);
#endif 

   if (pga->final_stage && (pga->capable || pga->terminal)) {
      if (Group_library == GAP_LIBRARY) {
	 GAP_library = OpenFile ("GAP_library", "a+");
	 GAP_auts (GAP_library, central, stabiliser, pga, pcp);
	 CloseFile (GAP_library);
      }
   }

   if (pga->final_stage) {
      if (StandardPresentation) pga->fixed = 0; else initialise_pga (pga, pcp);
      pga->step_size = 0; 
   }

   /* save structure + automorphism information */
   file = (pga->final_stage ? descendant_file : covers_file); 
      
   save_pga (file, central, stabiliser, pga, pcp);

#if defined (GROUP) 
#if defined (STANDARD_PCP)
   if (StandardPresentation)
      print_aut_description (central, stabiliser, pga, pcp);
#endif
#endif

   if (pga->nmr_centrals != 0) 
      free_array (central, pga->nmr_centrals, pga->ndgen, 1);
   if (pga->nmr_stabilisers != 0) {
      free_array (stabiliser, pga->nmr_stabilisers, pga->ndgen, 1);
   }

   pcp->lastg = rank_of_cover;
   pcp->lused = lused;
}
