/****************************************************************************
**
*A  options.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: options.c,v 1.4 2001/06/21 23:04:21 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "menus.h"
#include "constants.h"
#include "pq_functions.h"

#if defined (GROUP) 

#define MAXOPTION 10           /* maximum number of menu options */

/* control routine for p-quotient program */

void options (call, format, pcp)
int call;
int format;
struct pcp_vars *pcp;
{
   int option;
   int t;
   char *name;
   FILE_TYPE FileName;

   int output_level = DEFAULT_PRINT;
   Logical group_present = FALSE;
   Logical print_flag;
   int exit_value;
   Logical report;

   int *list, *head;

   if (isatty (0))
      list_pqa_menu ();

   if (call != DEFAULT_MENU)
      group_present = TRUE;

   do {
      option = read_option (MAXOPTION);      
      switch (option) {

      case -1:
	 list_pqa_menu ();
	 break;

      case COMPUTE_PCP:
	 t = runTime ();
#ifdef Magma
	 format = Magma_FORMAT;
#endif
	 exit_value = pquotient (0, 0, stdin, format, pcp);
	 if (exit_value == SUCCESS)
	    group_present = TRUE;
	 t = runTime () - t;
	 printf ("Computation of presentation took %.2f seconds\n", t * CLK_SCALE );
	 break;

      case SAVE_PCP:
	 name = GetString ("Enter output file name: ");
	 FileName = OpenFileOutput (name);
	 if (group_present && FileName != NULL) {
	    save_pcp (FileName, pcp);
	    if (pcp->m != 0)  
	       save_auts (FileName, head, list, pcp);
	    CloseFile (FileName);
	    printf ("Presentation written to file\n");
	 }
	 break;
 
      case RESTORE_GROUP:
	 name = GetString ("Enter input file name: ");
	 FileName = OpenFileInput (name);
	 if (FileName != NULL) {
	    restore_pcp (FileName, pcp);
#ifdef DEBUG
	    pcp->m = 0;
#endif
	    if (pcp->m != 0)   
	       restore_automorphisms (FileName, &head, &list, pcp);
	    group_present = TRUE;
	    RESET(FileName);
	    printf ("Presentation read from file\n");
	 }
	 break;

      case DISPLAY_PRESENTATION:
	 print_flag = (output_level >= MAX_PRINT - 1) ? TRUE : FALSE;
	 if (group_present)
	    print_presentation (print_flag, pcp);
	 break;

      case PRINT_LEVEL:
	 print_level (&output_level, pcp);
	 break;

      case NEXT_CLASS:
	 if (pcp->cc >= MAXCLASS || pcp->lastg >= MAXPC) {
	    printf ("You have reached the specified limits on class or number of defining generators\n");
	    break;
	 }
	 if (!pcp->overflow && group_present) {
	    t = runTime ();
	    report = pcp->complete; 
	    next_class (FALSE, &head, &list, pcp);
	    if (report || output_level == 1 && pcp->complete || pcp->lastg < 1)
	       text (5, pcp->cc, pcp->p, pcp->lastg, 0);
	    t = runTime () - t;
	    if (!pcp->overflow) {
	       print_flag = (output_level >= MAX_PRINT - 1) ? TRUE : FALSE;
	       print_presentation (print_flag, pcp);
	    }
	    printf ("Computation of next class took %.2f seconds\n", 
		    t * CLK_SCALE);
	 }
	 break;

      case PCOVER:
	 if (group_present) {
	    t = runTime ();
	    pcp->multiplicator = TRUE;
	    next_class (FALSE, &head, &list, pcp);
	    pcp->multiplicator = FALSE;
	    pcp->update = FALSE;
	    pcp->middle_of_tails = FALSE;
	    t = runTime () - t;
	    print_flag = (output_level >= MAX_PRINT - 1) ? TRUE : FALSE;
	    print_presentation (print_flag, pcp);
	    printf ("Computation of %d-covering group took %.2f seconds\n", 
		    pcp->p, t * CLK_SCALE);
	 }
	 break;

      case INTERACTIVE_PQ:
	 interactive_pq (group_present, format, output_level, &head, &list, pcp);
	 break;

      case PGP: 
	 pgroup_generation (&group_present, pcp);
	 break;

      case EXIT: case MAXOPTION:
	 printf ("Exiting from ANU p-Quotient Program\n");
	 break;
     

      }                         /* switch */
   } while (option != 0 && option != MAXOPTION);      
}

/* list available menu options */

void list_pqa_menu ()
{
   printf ("\nBasic Menu for p-Quotient Program\n");
   printf ("----------------------------------\n");
   printf ("%d. Compute pc presentation\n", COMPUTE_PCP);
   printf ("%d. Save presentation to file\n", SAVE_PCP);
   printf ("%d. Restore presentation from file\n", RESTORE_PCP);
   printf ("%d. Display presentation of group\n", DISPLAY_PRESENTATION);
   printf ("%d. Set print level\n", PRINT_LEVEL);
   printf ("%d. Calculate next class\n", NEXT_CLASS);
   printf ("%d. Compute p-covering group\n", PCOVER);
   printf ("%d. Advanced p-quotient menu\n", INTERACTIVE_PQ);
   printf ("%d. (Main) menu for p-group generation\n", PGP);
   printf ("%d. Exit from p-quotient program\n", MAXOPTION);
}

#endif 

/* prompt for & read menu option and check its validity */

int read_option (maxoption)
int maxoption;
{
   int option;
   Logical error;
  
   do {
      read_value (TRUE, "\nSelect option: ", &option, LEAST_OPTION);
      if ((error = valid (option, maxoption)) == 0)
	 printf ("Invalid option -- must lie between %d and %d\n", 
		 LEAST_OPTION, maxoption);
   } while (error == 0);

   return option;
}      

/* check whether option is valid */

int valid (option, maxoption)
int option;
int maxoption;
{
   return option >= LEAST_OPTION && option <= maxoption;
}
