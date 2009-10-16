/****************************************************************************
**
*A  pgroup.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pgroup.c,v 1.6 2004/02/03 18:36:20 gap Exp $
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
#include "pq_functions.h"
#include "standard.h"

#if defined (CARANTI)
#define CARANTI_DISPLAY 7
#define MAX_PGA_OPTION 8
#else 
#define MAX_PGA_OPTION 7
#endif

/* coordinating routine for the pgroup generation part of the program; 
   group_present flag indicates whether a group description has 
   been constructed or restored in previous menu */

void pgroup_generation (group_present, pcp)
Logical *group_present;
struct pcp_vars *pcp;
{
#include "define_y.h"

   struct pga_vars pga;
   struct pga_vars flag;
   int option;
   int subgroup_rank;

   char *StartName; 
   FILE_TYPE StartFile;

   int ***auts;
   int t;

   int group_nmr = 1;
   int *step_sequence = NULL;
   int class_bound, order_bound;  
   int nmr_of_exponents;

   Logical new_group = FALSE;
   StandardPresentation = FALSE;

   initialise_pga (&pga, pcp);
   pga.m = 0;
   pga.nmr_soluble = 0;

   if (*group_present) {
      pga.ndgen = y[pcp->clend + 1];
      set_values (&pga, pcp);
      /* it's possible that the complete flag may be set */
      pcp->complete = FALSE;
   }

   list_pga_menu ();

   do {
      option = read_option (MAX_PGA_OPTION);      
      switch (option) {

      case -1:
	 list_pga_menu ();
	 break;

      case SUPPLY_AUTOMORPHISMS:

        auts = read_auts (PGA, &pga.m, &nmr_of_exponents, pcp);

#if defined (LARGE_INT)
        autgp_order (&pga, pcp);
#endif

        new_group = TRUE;

        read_value (TRUE, 
                    "Input number of soluble generators for automorphism group: ", 
                    &pga.nmr_soluble, INT_MIN);

        if( pga.nmr_soluble > 0 ) {

          int k;

          pga.relative = allocate_vector (pga.nmr_soluble, 1, FALSE);

          for (k = 1; k <= pga.nmr_soluble; ++k) {
            printf("Input relative order of soluble generator %d: ", k);
            read_value (TRUE, "", &pga.relative[k], 0); 
          }
        }
        
        start_group (&StartFile, auts, &pga, pcp);
        
        break;


      case EXTEND_AUTOMORPHISMS:
	 extend_automorphisms (auts, pga.m, pcp);
	 print_auts (pga.m, pcp->lastg, auts, pcp);
	 break;

      case RESTORE_GROUP:
	 StartName = GetString ("Enter input file name: ");
	 StartFile = OpenFileInput (StartName);
	 new_group = FALSE;
	 if (StartFile != NULL) {
	    read_value (TRUE, "Which group? ", &group_nmr, 0);
	    auts = restore_group (TRUE, StartFile, group_nmr, &pga, pcp);
	    RESET(StartFile);
	    *group_present = TRUE;
	 }
	 CloseFile (StartFile);
	 break;

      case DISPLAY_GROUP:
	 print_presentation (FALSE, pcp);
	 print_structure (1, pcp->lastg, pcp);
	 print_pcp_relations (pcp);
	 break;

      case ITERATION:
	 t = runTime ();
	 /* it's possible that the complete flag may be set */
	 pcp->complete = FALSE;
	 if (pcp->newgen == 0) {
	    --pcp->cc;
	    print_group_details (&pga, pcp);
	    invalid_group (pcp);
	    if (!isatty (0))
	       exit (FAILURE);
	 }
	 else {
	    if (new_group) 
	       start_group (&StartFile, auts, &pga, pcp);
	    else
	       StartFile = OpenFile (StartName, "r");
            

	    /*
	      free_array (auts, pga.m, pcp->lastg, 1);
	      */
	    pga.nmr_of_perms = pga.m;
	    iteration_information (&subgroup_rank, &flag, &class_bound, 
				   &order_bound, &step_sequence, &pga, pcp);
	    iteration (1, step_sequence, subgroup_rank, &flag, StartFile, 
		       group_nmr, class_bound, order_bound, &pga, pcp); 
	    if (!new_group)  {
	       StartFile = OpenFile (StartName, "r");
	       auts = restore_group (TRUE, StartFile, group_nmr, &pga, pcp);
	    }
	    else {
	       RESET (StartFile);
	       auts = restore_group (TRUE, StartFile, 1, &pga, pcp);
	    }

	    t = runTime () - t;
	    printf ("Construction of descendants took %.2f seconds\n", 
		    t * CLK_SCALE);
	 }
	 CloseFile (StartFile);
	 break;

      case INTERACTIVE_PGA:
	 interactive_pga (*group_present, StartFile, group_nmr, auts, &pga, pcp);
	 break;

#ifdef CARANTI
      case CARANTI_DISPLAY:
	 if (!pcp->complete)
	    last_class (pcp);
	 print_structure (1, pcp->lastg, pcp);
	 print_pcp_relations (pcp);
	 print_auts (pga.m, pcp->ndgen, auts, pcp);
	 break;
#endif

      case EXIT: case MAX_PGA_OPTION:
	 printf ("Exiting from p-group generation\n");
	 break;

      }                         /* switch */

   } while (option != EXIT && option != MAX_PGA_OPTION);      
}

/* list available menu options */

void list_pga_menu ()
{
   printf ("\nMenu for p-Group Generation\n");
   printf ("-----------------------------\n");
   printf ("%d. Read automorphism information for starting group\n", 
	   SUPPLY_AUTOMORPHISMS);
   printf ("%d. Extend and display automorphisms\n", EXTEND_AUTOMORPHISMS);
   printf ("%d. Specify input file and group number\n", RESTORE_GROUP);
   printf ("%d. List group presentation\n", DISPLAY_GROUP);
   printf ("%d. Construct descendants\n", ITERATION);
   printf ("%d. Advanced p-group generation menu\n", INTERACTIVE_PGA);
   printf ("%d. Exit to basic menu\n", MAX_PGA_OPTION);
}
