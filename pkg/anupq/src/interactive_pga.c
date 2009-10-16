/****************************************************************************
**
*A  interactive_pga.c           ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: interactive_pga.c,v 1.6 2001/06/21 23:04:21 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "menus.h"
#include "standard.h"
#include "pq_functions.h"
#include "global.h"

#define MAX_INTERACTIVE_OPTION 18  /* maximum number of menu options */

#define COMBINATION 100

/* interactive menu for p-group generation */

void interactive_pga (group_present, StartFile, group_nmr, auts, pga, pcp)
Logical group_present;
FILE_TYPE StartFile;
int group_nmr;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   struct pga_vars flag;
   int option;
   Logical soluble_group = TRUE;

   FILE_TYPE OutputFile;
   FILE *LINK_input;

   char *StartName; 
   int t;

   int **perms;
   int index;
   int **S;
   int k;
   int K;
   int label;
   int *a, *b;
   char *c;
   int *orbit_length;
   int nmr_of_exponents;
   int *subset;
   int alpha;
   int upper_step;
   int rep;
   int i;

   /*
     int l;
     FILE *CAYLEY_input;
     Logical x;
     int i, l, u;
     */

   list_interactive_pga_menu ();

   do {
      option = read_option (MAX_INTERACTIVE_OPTION);      
      switch (option) {

      case -1:
	 list_interactive_pga_menu ();
	 break;

      case SUPPLY_AUTS:
	 auts = read_auts (PGA, &pga->m, &nmr_of_exponents, pcp);
#if defined (LARGE_INT) 
	 autgp_order (pga, pcp);
#endif 
	 pga->soluble = TRUE; 
	 start_group (&StartFile, auts, pga, pcp);
	 break;

      case EXTEND_AUTS:
	 extend_automorphisms (auts, pga->m, pcp);
	 print_auts (pga->m, pcp->lastg, auts, pcp);
	 break;

      case RESTORE_GP:
	 StartName = GetString ("Enter input file name: ");
	 StartFile = OpenFileInput (StartName);
	 if (StartFile != NULL) {
	    read_value (TRUE, "Which group? ", &group_nmr, 0);
	    auts = restore_group (TRUE, StartFile, group_nmr, pga, pcp);
	    RESET(StartFile);
	 }
	 break;

      case DISPLAY_GP:
	 print_presentation (FALSE, pcp);
	 print_structure (1, pcp->lastg, pcp);
	 print_pcp_relations (pcp);
	 break;

      case SINGLE_STAGE:
	 t = runTime ();
	 if (group_present && pga->m == 0)
	    start_group (&StartFile, auts, pga, pcp);
	 construct (1, &flag, SINGLE_STAGE, OutputFile, StartFile, 
		    0, ALL, group_nmr, pga, pcp);
	 t = runTime () - t;
	 printf ("Time for intermediate stage is %.2f seconds\n", t * CLK_SCALE);
	 break;

      case DEGREE:
	 read_step_size (pga, pcp);
	 read_subgroup_rank (&k);
	 query_exponent_law (pga);
	 enforce_laws (pga, pga, pcp);
	 extend_automorphisms (auts, pga->m, pcp);
	 step_range (k, &pga->s, &upper_step, auts, pga, pcp);

	 if (pga->s > upper_step)  
	    printf ("Desired step size is invalid for current group\n");
	 else {
	    if (pga->s < upper_step) {
	       printf ("The permitted relative step sizes range from %d to %d\n", 
		       pga->s, upper_step);
	       read_value (TRUE, "Input the chosen relative step size: ", 
			   &pga->s, 0);
	    }
         

	    store_definition_sets (pga->r, pga->s, pga->s, pga);
	    get_definition_sets (pga);
	    pga->print_degree = TRUE;
	    compute_degree (pga);
	    pga->print_degree = FALSE;
	 }
	 break;

      case PERMUTATIONS:
	 if (pga->Degree != 0) {
	    t = runTime ();

	    query_solubility (pga);
	    pga->trace = FALSE;
	    if (pga->soluble) 
	       query_space_efficiency (pga);
	    else 
	       pga->space_efficient = FALSE;
	    query_perm_information (pga);

	    strip_identities (auts, pga, pcp);
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
	       StartGapFile (pga);
#else
#if defined (GAP_LINK_VIA_FILE)
	       start_GAP_file (&LINK_input, auts, pga, pcp);
#endif
#endif
#endif
#endif
	    }
	    perms = permute_subgroups (LINK_input, &a, &b, &c, 
				       auts, pga, pcp); 

#if defined (CAYLEY_LINK) || defined (Magma_LINK) || defined (GAP_LINK_VIA_FILE)
	    if (!soluble_group)
	       CloseFile (LINK_input);
#endif 
	    t = runTime () - t;
	    printf ("Time to compute permutations is %.2f seconds\n", t * CLK_SCALE);
	 }
	 else
	    printf ("You must first select option %d\n", DEGREE);

	 /*
           
	   CAYLEY_input = OpenFile ("CAYLEY_perms", "w");
	   for (i = 1; i <= pga->nmr_of_perms; ++i)
	   write_CAYLEY_permutation (CAYLEY_input, i, perms[i], pga);
	   */
	 break;
         
      case ORBITS: 
	 orbit_option (option, perms, &a, &b, &c, &orbit_length, pga);
	 break;

      case STABILISERS: case STABILISER: 
	 stabiliser_option (option, auts, perms, a, b, c, orbit_length, 
			    pga, pcp);
	 /*
	   free_space (pga->soluble, perms, orbit_length,
	   a, b, c, pga);
	   */
	 break;

      case MATRIX_TO_LABEL:
	 S = allocate_matrix (pga->s, pga->q, 0, FALSE);
	 subset = allocate_vector (pga->s, 0, FALSE);
	 printf ("Input the %d x %d subgroup matrix:\n", pga->s, pga->q);
	 read_matrix (S, pga->s, pga->q);
	 K = echelonise_matrix (S, pga->s, pga->q, pga->p, subset, pga);
	 printf ("The standard matrix is:\n");
	 print_matrix (S, pga->s, pga->q);
	 printf ("The label is %d\n", subgroup_to_label (S, K, subset, pga));
	 free_vector (subset, 0);
	 break;

      case LABEL_TO_MATRIX:
	 read_value (TRUE, "Input allowable subgroup label: ", &label, 1);
	 S = label_to_subgroup (&index, &subset, label, pga);
	 printf ("The corresponding standard matrix is\n");
	 print_matrix (S, pga->s, pga->q);
	 break;

      case IMAGE:
	 t = runTime ();
	 /*
	   invert_automorphisms (auts, pga, pcp);
	   print_auts (pga->m, pcp->lastg, auts, pcp);
	   */
	 printf ("Input the subgroup label and automorphism number: ");
	 read_value (TRUE, "", &label, 1);
	 read_value (FALSE, "", &alpha, 1);
	 printf ("Image is %d\n", find_image (label, auts[alpha], pga, pcp));
	 t = runTime () - t;
	 printf ("Computation time in seconds is %.2f\n", t * CLK_SCALE );
	 break;

      case SUBGROUP_RANK:
	 read_subgroup_rank (&k);
	 printf ("Closure of initial segment subgroup has rank %d\n", 
		 close_subgroup (k, auts, pga, pcp));
	 break;

      case ORBIT_REP:
	 printf ("Input label for subgroup: ");
	 read_value (TRUE, "", &label, 1);
	 rep = abs (a[label]);
	 for (i = 1; i <= pga->nmr_orbits && pga->rep[i] != rep; ++i)
	    ;
	 printf ("Subgroup with label %d has representative %d and is in orbit %d\n", 
		 label, rep, i);
	 break;
         
        
      case COMPACT_DESCRIPTION:
	 Compact_Description = TRUE;
	 read_value (TRUE, "Lower bound for order (0 for all groups generated)? ",
		     &Compact_Order, 0);
	 break;

      case AUT_CLASSES:
	 t = runTime ();
	 permute_elements ();
	 t = runTime () - t;
	 printf ("Time to compute orbits is %.2f seconds\n", t * CLK_SCALE );
	 break;

	 /*
	   printf ("Input label: ");
	   scanf ("%d", &l);
	   process_complete_orbit (a, l, pga, pcp);
	   break;
           
	   case TEMP:
	   printf ("Input label: ");
	   scanf ("%d", &l);
	   printf ("Input label: ");
	   scanf ("%d", &u);
	   for (i = l; i <= u; ++i) {
	   x = IsValidAllowableSubgroup (i, pga);
	   printf ("%d is %d\n", i, x);
	   }
	   StartName = GetString ("Enter output file name: ");
	   OutputFile = OpenFileOutput (StartName);
	   part_setup_reps (pga->rep, pga->nmr_orbits, orbit_length, perms, a, b, c, 
	   auts, OutputFile, OutputFile, pga, pcp); 
           
	   list_word (pga, pcp);
           
	   read_value (TRUE, "Input the rank of the subgroup: ", &pga->q, 1);
	   strip_identities (auts, pga, pcp);
	   break;
	   */

      case EXIT: case MAX_INTERACTIVE_OPTION:
	 printf ("Exiting from interactive p-group generation menu\n");
	 break;

      }                         /* switch */

   } while (option != 0 && option != MAX_INTERACTIVE_OPTION);      

#if defined (GAP_LINK)
   if (!soluble_group)
      QuitGap ();
#endif

}

/* list available menu options */

void list_interactive_pga_menu ()
{
   printf ("\nAdvanced Menu for p-Group Generation\n");
   printf ("-------------------------------------\n");
   printf ("%d. Read automorphism information for starting group\n",
	   SUPPLY_AUTS);
   printf ("%d. Extend and display automorphisms\n", EXTEND_AUTS);
   printf ("%d. Specify input file and group number\n", RESTORE_GP);
   printf ("%d. List group presentation\n", DISPLAY_GP);
   printf ("%d. Carry out intermediate stage calculation\n", SINGLE_STAGE);
   printf ("%d. Compute definition sets & find degree\n", DEGREE);
   printf ("%d. Construct permutations of subgroups under automorphisms\n",
	   PERMUTATIONS);
   printf ("%d. Compute and list orbit information\n", ORBITS);
   printf ("%d. Process all orbit representatives\n", STABILISERS);
   printf ("%d. Process individual orbit representative\n", STABILISER);
   printf ("%d. Compute label for standard matrix of subgroup\n",
	   MATRIX_TO_LABEL);
   printf ("%d. Compute standard matrix for subgroup from label\n",
	   LABEL_TO_MATRIX);
   printf ("%d. Find image of allowable subgroup under automorphism\n",
	   IMAGE);
   printf ("%d. Find rank of closure of initial segment subgroup\n",
	   SUBGROUP_RANK);
   printf ("%d. List representative and orbit for supplied label\n", ORBIT_REP);
   printf ("%d. Write compact descriptions of generated groups to file\n", 
	   COMPACT_DESCRIPTION);
   printf ("%d. Find automorphism classes of elements of vector space\n",
	   AUT_CLASSES);
   printf ("%d. Exit to main p-group generation menu\n", MAX_INTERACTIVE_OPTION);
}

void orbit_option (option, perms, a, b, c, orbit_length, pga)
int option;
int **perms;
int **a;
int **b;
char **c;
int **orbit_length;
struct pga_vars *pga;
{
   int t; 
   Logical soluble_group;
    FILE_TYPE file;


   if (option != COMBINATION && option != STANDARDISE) {
      query_solubility (pga);
      if (pga->soluble) 
	 query_space_efficiency (pga);
      else
	 pga->space_efficient = FALSE;
      query_orbit_information (pga);
   }
   else if (option == COMBINATION) {
      pga->print_orbit_summary = FALSE;
      pga->print_orbits = FALSE;
   }
   else if (option == STANDARDISE) {
      pga->print_orbit_summary = FALSE;
      pga->print_orbits = FALSE;
   }
            
   soluble_group = (pga->soluble || pga->Degree == 1 || pga->nmr_of_perms == 0);

   if (!pga->space_efficient) {
      t = runTime ();
      if (soluble_group)  
	 compute_orbits (a, b, c, perms, pga);
      else   
	 insoluble_compute_orbits (a, b, c, perms, pga);
      if (option != COMBINATION && option != STANDARDISE) {
	 t = runTime () - t;
	 printf ("Time to compute orbits is %.2f seconds\n", t * CLK_SCALE );
      }
   }

   /* if in soluble portion of combination, we do not need to 
      set up representives */
   if (option == COMBINATION && pga->soluble) return;

   *orbit_length = find_orbit_reps (*a, *b, pga);

   if (pga->print_orbit_summary)   
      orbit_summary (*orbit_length, pga);
   /*   file = OpenFile ("COUNT", "a+");
        fprintf (file, "%d,\n", pga->nmr_orbits);
   */

}

void stabiliser_option (option, auts, perms, a, b, c, orbit_length, pga, pcp)
int option;
int ***auts;
int **perms;
int *a, *b;
char *c;
int *orbit_length;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int t;
   int i;
   Logical soluble_group;
   FILE_TYPE OutputFile;
   char *StartName; 
   int *rep;
   int *length;
   rep = allocate_vector (1, 1, 0); 
   length = allocate_vector (1, 1, 0); 

   t = runTime ();

   query_solubility (pga);
   if (pga->soluble)
      query_space_efficiency (pga);
   else
      pga->space_efficient = FALSE;
   soluble_group = (pga->soluble || pga->Degree == 1 || pga->nmr_of_perms == 0);

   query_terminal (pga);
   query_exponent_law (pga);
   query_metabelian_law (pga);
   query_group_information (pga->p, pga);
   query_aut_group_information (pga);
   StartName = GetString ("Enter output file name: ");
   OutputFile = OpenFileOutput (StartName);

   pga->final_stage = (pga->q == pga->multiplicator_rank);
   pga->nmr_of_descendants = 0;
   pga->nmr_of_capables = 0;

   if (option == STABILISER) {
      read_value (TRUE, "Input the orbit representative: ", &rep[1], 1);
      /* find the length of the orbit having this representative */
      for (i = 1; i <= pga->nmr_orbits && pga->rep[i] != rep[1]; ++i)
	 ;
      if (pga->rep[i] == rep[1])
	 length[1] = orbit_length[i];
      else {
	 printf ("%d is not an orbit representative\n", rep[1]);
	 return;
      }
   }

   if (option == STABILISER)
      setup_reps (rep, 1, length, perms, a, b, c, auts, 
		  OutputFile, OutputFile, pga, pcp); 
   else 
      setup_reps (pga->rep, pga->nmr_orbits, orbit_length, perms, a, b, c, 
		  auts, OutputFile, OutputFile, pga, pcp); 

   /*
     #if defined (GAP_LINK)
     if (!soluble_group)
     QuitGap ();
     #endif
     */

   RESET (OutputFile);

   printf ("Time to process representative is %.2f seconds\n", 
	   (runTime () - t) * CLK_SCALE);
}


/* list orbit representatives as words subject to the supplied map */ 

int list_word (pga, pcp)
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   register int i, j;
   int start_length;

   int start[100];
   int word[100];

   int **S;
   int index;
   int *subset;
   int length = 0;
   register int k, r;
   register int lastg = pcp->lastg;

   start_length = 0;
   /*
     read_value (TRUE, "Input length of initial segment: ", &start_length, 0);
     for (i = 1; i <= start_length; ++i)
     scanf ("%d", &start[i]);
     */

   for (r = 1; r <= pga->nmr_orbits; ++r) {

      S = label_to_subgroup (&index, &subset, pga->rep[r], pga);

      print_matrix (S, pga->s, pga->q);

      for (i = 0; i < pga->q; ++i) {

	 if  (1 << i & pga->list[index]) continue;

	 for (j = 1; j <= lastg; ++j)
	    word[j] = 0;

	 for (j = 0; j < pga->s; ++j)
	    if (S[j][i] != 0)
	       word[pcp->ccbeg + subset[j]] = pga->p - S[j][i];

	 word[pcp->ccbeg + i] = 1;

	 print_array (word, pcp->ccbeg, lastg + 1);
     
	 length = 0;
	 for (k = pcp->ccbeg; k <= lastg; ++k)
	    if (word[k] != 0)
	       ++length;

	 printf ("%d\n", length + start_length);
	 for (k = 1; k <= start_length; ++k)
	    printf ("%d 1 ", start[k]);
   
	 for (k = pcp->ccbeg; k <= lastg; ++k)
	    if (word[k] != 0)
	       printf ("%d %d ", k, word[k]);
	 printf ("\n");
      }
   }

   return 0;
}
