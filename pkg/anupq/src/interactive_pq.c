/****************************************************************************
**
*A  interactive_pq.c            ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: interactive_pq.c,v 1.9 2001/09/24 20:31:13 gap Exp $
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
#include "menus.h"
#include "pq_functions.h"
#include "pretty_filterfns.h"
#include "word_types.h"
#include "global.h"

#define MAXOPTION 31          /* maximum number of menu options */
#define CAYLEY_PRES_FORMAT 1
#define GAP_PRES_FORMAT 2 
#define MAGMA_PRES_FORMAT 3

#define BOTH_TAILS 0 
#define NEW_TAILS 1
#define COMPUTE_TAILS 2

#if defined (GROUP) 

int option_collect_word (format, start_gen, final_gen, pcp)
int format;
int start_gen;
int final_gen;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int t, cp, i;
   int type;
   FILE *Magma_Auts;

   t = runTime ();
   if (format != BASIC)
      setup_symbols (pcp);
   type = WORD;
   if (!is_space_exhausted (3 * pcp->lastg + 2, pcp)) {
      Magma_Auts = OpenFile ("Magma_Auts", "a+");
      cp = pcp->lused; 
      setup_word_to_collect (stdin, format, type, cp, pcp);
      t = runTime () - t;
      printf ("Collection took %.2f seconds\n", t * CLK_SCALE);
      fprintf (Magma_Auts, "v := \\[");
      for (i = start_gen; i < final_gen; ++i) { 
	 if (i % 20 == 0) fprintf (Magma_Auts, "\n");
	 fprintf (Magma_Auts, "%d, ", y[cp + i]);
      }
      fprintf (Magma_Auts, "%d];\n", y[cp + final_gen]);
      fprintf (Magma_Auts, "v := V!v;\n");
      CloseFile (Magma_Auts);
      return TRUE;
   }
       
   return FALSE;
}

int option_commute_word (format, start_gen, final_gen, pcp)
int format;
int start_gen;
int final_gen;
struct pcp_vars *pcp;
{
#include "define_y.h"
   int cp, t, i;
   FILE *Magma_Auts;

   t = runTime ();
   if (format != BASIC)
      setup_symbols (pcp);
   if (!is_space_exhausted (7 * pcp->lastg + 2, pcp)) {
      cp = pcp->lused; 
      Magma_Auts = OpenFile ("Magma_Auts", "a+");
      calculate_commutator (format, pcp);
      fprintf (Magma_Auts, "v := \\[");
      for (i = start_gen; i < final_gen; ++i) {
	 if (i % 20 == 0) fprintf (Magma_Auts, "\n");
	 fprintf (Magma_Auts, "%d, ", y[cp + i]);
      }
      fprintf (Magma_Auts, "%d];\n", y[cp + final_gen]);
      fprintf (Magma_Auts, "v := V!v;\n");
      CloseFile (Magma_Auts);
      t = runTime () - t;
      printf ("Commutator calculation took %.2f seconds\n", t * CLK_SCALE);
      return TRUE;
   }
   return FALSE;
}

/* interactive menu for p-quotient calculation */

void interactive_pq (group_present, format, output_level, head, list, pcp)
Logical group_present;
int format;
int output_level;
int **head;
int **list; 
struct pcp_vars *pcp;
{
#include "define_y.h"

   int option, t, class;
   register int cp;
   Logical print_flag;
   int type;
   int i;
   int factor, limit;
   int ***auts;
   char *s;
   char *name;
   FILE_TYPE FileName;
   FILE_TYPE MAGMA_Auts;

   int *queue, *long_queue;
   int start_length;
   int prev_qlength = 0, current_qlength; 
   int long_queue_length = 0, queue_length = 0;
   int consistency_type;
   int nmr_of_auts;
   int nmr_of_exponents;
   int tail_type;
   int start_gen, final_gen;

   Logical queue_setup = FALSE; /* redundancy queue set up? */
   Logical echelon_ready = FALSE; /* ready to echelonise? */

   Logical output;              /* temporarily store value of pcp->fullop */
   struct exp_vars exp_flag;

   Logical symbols_setup = FALSE;

   int file_format;

   if (isatty (0))
      list_interactive_pq_menu ();

   if (format != BASIC && group_present == TRUE) {
      setup_symbols (pcp);
      symbols_setup = TRUE;
   }

   do {
      option = read_option (MAXOPTION);      
      switch (option) {

      case -1:
	 list_interactive_pq_menu ();
	 break;
        
      case COLLECT:
	 t = runTime ();
	 if (format != BASIC && symbols_setup == FALSE) {
	    setup_symbols (pcp);
	    symbols_setup = TRUE;
	 }
	 type = WORD;
	 if (!is_space_exhausted (3 * pcp->lastg + 2, pcp)) {
	    cp = pcp->lused; 
	    setup_word_to_collect (stdin, format, type, cp, pcp);
	    t = runTime () - t;
	    printf ("Collection took %.2f seconds\n", t * CLK_SCALE);
	    echelon_ready = TRUE;
	 }
	 break;

      case SOLVE:
	 t = runTime ();
	 if (format != BASIC && symbols_setup == FALSE) {
	    setup_symbols (pcp);
	    symbols_setup = TRUE;
	 }
	 setup_to_solve_equation (format, pcp); 
	 t = runTime () - t;
	 printf ("Solving the equation took %.2f seconds\n", t * CLK_SCALE);
	 break;

      case COMMUTATOR:
	 t = runTime ();
	 if (format != BASIC && symbols_setup == FALSE) {
	    setup_symbols (pcp);
	    symbols_setup = TRUE;
	 }
	 calculate_commutator (format, pcp);
	 cp = pcp->lused; 
	 echelon_ready = TRUE;
	 t = runTime () - t;
	 printf ("Commutator calculation took %.2f seconds\n", t * CLK_SCALE);
	 break;
  
      case DISPLAY_PRESENTATION:
	 print_flag = (output_level >= MAX_PRINT - 1) ? TRUE : FALSE;
	 print_presentation (print_flag, pcp);
	 break;

      case PRINT_LEVEL:
	 print_level (&output_level, pcp);
	 break;

      case SETUP:
	 if (pcp->complete) { printf ("Group is complete\n"); break; }
	 setup (pcp);
	 pcp->update = FALSE;
	 pcp->middle_of_tails = FALSE;
	 printf ("Setup performed for class %d\n", pcp->cc);
	 break;

      case TAILS:
	 t = runTime ();
	 if (pcp->complete) { printf ("Group is complete\n"); break; }
	 pcp->middle_of_tails = FALSE;
	 read_value (TRUE, "Input class for tails computation (0 for all): ", 
		     &class, 0);
	 tail_info (&tail_type); 
	 if (class == 0 || (class > 1 && class <= pcp->cc)) {
	    if (class > 0) {
	       tails (tail_type, class, pcp->cc, 1, pcp);
	       if (class != 2)
		  pcp->middle_of_tails = TRUE;
	    }
	    else {
	       for (class = pcp->cc; class > 1; --class)  
		  tails (tail_type, class, pcp->cc, 1, pcp);
	    }
	    if (pcp->overflow && !isatty (0))
	       exit (FAILURE);
	    t = runTime () - t;
	    printf ("Tails computation took %.2f seconds \n", t * CLK_SCALE);
	 }
	 else
	    printf ("Class %d is invalid for tails calculations\n", class);
	 break;

      case CONSISTENCY:
	 t = runTime ();
	 if (pcp->complete) { printf ("Group is complete\n"); break; }
	 read_value (TRUE, "Input class for consistency check (0 for all): ", 
		     &class, 0);
	 consistency_info (&consistency_type);
	 if (class == 0 || (class > 2 && class <= pcp->cc)) {
	    if (pcp->m != 0) {
	       queue_setup = TRUE;
	       start_length = queue_length;
	       queue_space (&queue, &long_queue, &current_qlength, 
			    &prev_qlength, pcp);
	    }

	    if (class > 0) 
	       consistency (consistency_type, queue, &queue_length, class, pcp);
	    else
	       for (class = pcp->cc; class > 2; --class)  
		  consistency (consistency_type, queue, &queue_length, 
			       class, pcp);
	    if (pcp->overflow && !isatty (0))
	       exit (FAILURE);

	    if (pcp->m != 0) {
	       s = (queue_length - start_length == 1) ? "y" : "ies";
	       printf ("Consistency checks gave %d redundanc%s\n", 
		       queue_length - start_length, s);
	    }
	    if (pcp->complete && output_level <= 1)
	       text (5, pcp->cc, pcp->p, pcp->lastg, 0);
	    t = runTime () - t;
	    printf ("Consistency checks took %.2f seconds\n", t * CLK_SCALE);
	 }
	 else
	    printf ("Class %d is invalid for consistency checks\n", class);
	 break;

      case RELATIONS:
	 t = runTime ();
	 if (pcp->complete) { printf ("Group is complete\n"); break; }

	 /* if no tails have been added, do not perform update */
	 if (y[pcp->clend + pcp->cc - 1] < pcp->lastg) {
	    if (!pcp->complete && pcp->cc > 1 && !pcp->middle_of_tails 
		&& !pcp->update) { 
	       update_generators (pcp);
	       pcp->update = TRUE;
	    }
	    if (!pcp->complete) 
	       collect_relations (pcp);
	 }

	 if (pcp->complete && output_level <= 1)
	    text (5, pcp->cc, pcp->p, pcp->lastg, 0);

	 t = runTime () - t;
	 printf ("Collection of relations took %.2f seconds\n", t * CLK_SCALE);
	 break;

      case EXTRA_RELATIONS:
	 t = runTime ();
	 if (pcp->complete) { printf ("Group is complete\n"); break; }
	 if (pcp->extra_relations == 0) {
	    read_value (TRUE, "Input exponent law (0 if none): ",
			&pcp->extra_relations, 0);
	 }
	 read_value (TRUE, "Input start weight for exponent checking: ", 
		     &pcp->start_wt, 1);
	 read_value (TRUE, "Input end weight for exponent checking: ", 
		     &pcp->end_wt, pcp->start_wt);
	 exponent_info (&exp_flag, pcp);
	 if (pcp->m != 0) {
	    queue_setup = TRUE;
	    start_length = queue_length;
	    queue_space (&queue, &long_queue, &current_qlength, 
			 &prev_qlength, pcp);
	    exp_flag.queue = queue;
	    exp_flag.queue_length = queue_length;
	 }

	 extra_relations (&exp_flag, pcp);

	 if (pcp->m != 0) {
	    queue = exp_flag.queue;
	    queue_length = exp_flag.queue_length;
	    s = (queue_length - start_length == 1) ? "y" : "ies";
	    printf ("Exponent checks gave %d redundanc%s\n", 
		    queue_length - start_length, s);
	 }
  
	 if (pcp->complete && output_level <= 1)
	    text (5, pcp->cc, pcp->p, pcp->lastg, 0);

	 t = runTime () - t;
	 printf ("Time to check exponents is %.2f seconds\n", t * CLK_SCALE);
	 break;
        
      case ELIMINATE:
	 t = runTime ();
	 symbols_setup = FALSE;
	 if (pcp->cc == 1) 
	    class1_eliminate (pcp);
	 else {
	    /* if no tails have been added, do not perform update */
	    if (y[pcp->clend + pcp->cc - 1] < pcp->lastg) {
	       if (pcp->cc > 1 && !pcp->middle_of_tails && !pcp->update) { 
		  update_generators (pcp);
		  pcp->update = TRUE;
	       }
	       eliminate (pcp->middle_of_tails, pcp);
	       queue_length = 0;
	       long_queue_length = 0;
	    }
	 }
            
	 t = runTime () - t;
	 printf ("Elimination took %.2f seconds\n", t * CLK_SCALE);
	 break;

      case LAST_CLASS:
	 last_class (pcp);
	 break;

      case MAXOCCUR:
	 set_maxoccur (pcp);
	 break;

      case METABELIAN:
	 pcp->metabelian = TRUE;
	 break;

      case JACOBI:
	 calculate_jacobi (pcp);
	 if (pcp->redgen != 0 && pcp->m != 0) {
	    queue_setup = TRUE;
	    if (prev_qlength == 0)  
	       queue_space (&queue, &long_queue, &current_qlength, 
			    &prev_qlength, pcp);
	    queue[++queue_length] = pcp->redgen;
	 }
	 break;

      case ECHELON:
	 if (echelon_ready) {
	    for (i = 1; i <= pcp->lastg; ++i)
	       y[cp + pcp->lastg + i] = 0;
	    output = pcp->fullop;
	    pcp->fullop = TRUE;
	    echelon (pcp);
	    pcp->fullop = output;
	    if (pcp->redgen != 0 && pcp->m != 0) {
	       queue_setup = TRUE;
	       if (prev_qlength == 0)  
		  queue_space (&queue, &long_queue, &current_qlength, 
			       &prev_qlength, pcp);
	       queue[++queue_length] = pcp->redgen;
	    }
	    echelon_ready = FALSE;
	 }
	 else 
	    printf ("No relation to echelonise; first collect or commute\n"); 
	 break;

      case AUTS:
	 t = runTime ();
	 if (pcp->m == 0) {
	    auts = read_auts (PQ, &pcp->m, &nmr_of_exponents, pcp);
	    Setup_Action (head, list, auts, nmr_of_exponents, pcp);
	 }
	 Extend_Auts (head, list, y[pcp->clend + 1] + 1, pcp);

#ifdef DEBUG
	 read_value (TRUE, "Input start generator: ", &start_gen, 1);
	 read_value (TRUE, "Input final generator: ", &final_gen, start_gen);
	 List_Auts (*head, *list, start_gen, final_gen, pcp);
	 /* print_array (*head, 0, (*head)[0] + 2); */
#endif
	 queue_setup = TRUE;
	 queue_space (&queue, &long_queue, &current_qlength, &prev_qlength, pcp);

	 t = runTime () - t;
	 printf ("Extension of automorphisms took %.2f seconds\n", t * CLK_SCALE);
	 break;

      case CLOSE_RELATIONS:
	 t = runTime ();
	 s = (queue_length == 1) ? "y" : "ies";
	 printf ("The queue currently contains %d entr%s\n", queue_length, s);
	 /*
	   print_array (queue, 1, queue_length + 1);
	   */
	 read_value (TRUE, "Input queue factor: ", &factor, 0);
	 limit = factor * (pcp->lastg - pcp->ccbeg + 1) / 100;
	 if (!pcp->complete) {
	    close_relations (TRUE, limit, 1, *head, *list, queue, queue_length, 
			     long_queue, &long_queue_length, pcp);
	 }

	 if (!pcp->complete && !pcp->overflow) {
	    if (pcp->fullop || pcp->diagn) 
	       printf ("Length of long queue after short queue closed is %d\n", 
		       long_queue_length);
	    close_relations (TRUE, limit, 2, *head, *list, long_queue, 
			     long_queue_length, long_queue, &long_queue_length, pcp);
	    if (pcp->fullop || pcp->diagn)  {
	       printf ("Final long queue length was %d\n", long_queue_length);
	    }
	 }

	 if (pcp->complete && output_level <= 1) 
	    text (5, pcp->cc, pcp->p, pcp->lastg, 0);

	 queue_length = long_queue_length = 0;
	 t = runTime () - t;
	 printf ("Closing relations took %.2f seconds\n", t * CLK_SCALE);
	 break;

      case STRUCTURE:
	 read_value (TRUE, "Input initial pcp generator number: ", 
		     &start_gen, 1);
	 if (start_gen <= pcp->lastg) { 
	    read_value (TRUE, "Input final pcp generator number: ", 
			&final_gen, start_gen);
	    print_structure (start_gen, MIN (final_gen, pcp->lastg), pcp);
	 }
	 else
	    printf ("Invalid range supplied for pcp generator numbers\n");
	 break;
         
      case ENGEL:
	 t = runTime ();
	 queue_setup = TRUE;
	 queue_space (&queue, &long_queue, &current_qlength, &prev_qlength, pcp);
	 list_commutators (queue, &queue_length, pcp);

	 /*
	   List_Commutators (queue, &queue_length, pcp);
	   */
	 t = runTime () - t;
	 printf ("Evaluation of Engel [y, (p - 1)x] identity took %.2f seconds\n", t * CLK_SCALE);
	 break;

      case LIST_AUTOMORPHISMS:
	 read_value (TRUE, "Input start generator: ", &start_gen, 1);
	 read_value (TRUE, "Input final generator: ", &final_gen, start_gen);
	 List_Auts (*head, *list, start_gen, final_gen, pcp);
	 break;

      case MAGMA_AUTOMORPHISMS:
	 /*
	   read_value (TRUE, "Input start position: ", &start, 1);
	   */
	 read_value (TRUE, "Input start generator: ", &start_gen, 1);
	 read_value (TRUE, "Input final generator: ", &final_gen, start_gen);
	 final_gen = MIN (final_gen, pcp->lastg);
	 MAGMA_Auts = OpenFile ("Magma_Auts", "w+");
	 fprintf (MAGMA_Auts, "G := GL (%d, GF (%d));\n",
		  final_gen - start_gen + 1, pcp->p);
	 fprintf (MAGMA_Auts, "V := VectorSpace (GF (%d), %d);\n",
		  pcp->p, final_gen - start_gen + 1);
	 CloseFile (MAGMA_Auts);
	 Magma_Auts (*head, *list, start_gen, start_gen, final_gen, pcp);
/* 
	 type = 0;
	 do {
	    read_value (TRUE, "Collect word (1) or commutator (3) (0 to finish): ", 
			&type, 0);
	    if (type == 1) 
	       option_collect_word (format, start_gen, final_gen, pcp);
	    if (type == 3) 
	       option_commute_word (format, start_gen, final_gen, pcp);
	 } while (type != 0); 
*/
	 break;

      case RELATIONS_FILE:
	 if (pcp->m != 0) {
	    queue_setup = TRUE;
	    start_length = queue_length;
	    queue_space (&queue, &long_queue, &current_qlength, 
			 &prev_qlength, pcp);
	 }

	 read_relator_file (queue, &queue_length, pcp);

	 if (pcp->m != 0) {
	    s = (queue_length - start_length == 1) ? "y" : "ies";
	    printf ("Relation file gave %d redundanc%s\n", 
		    queue_length - start_length, s);
	    if (queue_length != 0)
	       print_array (queue, 1, queue_length + 1);
	 }
	 t = runTime () - t;
	 printf ("Processing relations file took %.2f seconds\n", t * CLK_SCALE);
	 break;

      case DGEN_WORD:
	 if (format != BASIC && symbols_setup == FALSE) {
	    setup_symbols (pcp);
	    symbols_setup = TRUE;
	 }
	 type = WORD;
	 if (!is_space_exhausted (3 * pcp->lastg + 2, pcp)) {
	    cp = pcp->lused; 
	    setup_defgen_word_to_collect (stdin, format, type, pcp->lused, pcp);
	    echelon_ready = TRUE;
	 }
	 break;

      case DGEN_COMM:
	 if (format != BASIC && symbols_setup == FALSE) {
	    setup_symbols (pcp);
	    symbols_setup = TRUE;
	 }
	 commute_defining_generators (format, pcp);
	 echelon_ready = TRUE;
	 break;

      case DGEN_AUT:
	 if (format != BASIC && symbols_setup == FALSE) {
	    setup_symbols (pcp);
	    symbols_setup = TRUE;
	 }
	 auts = determine_action (format, &nmr_of_auts, pcp);
	 break;
 
      case COMPACT:
	 compact (pcp);
	 break;

      case FORMULA:
	 t = runTime (); 
	 if (pcp->m != 0) {
	    queue_setup = TRUE;
	    start_length = queue_length;
	    queue_space (&queue, &long_queue, &current_qlength, 
			 &prev_qlength, pcp);
	 }

	 evaluate_formula (queue, &queue_length, pcp);
         
	 if (pcp->m != 0) {
	    s = (queue_length - start_length == 1) ? "y" : "ies";
	    printf ("Formula checks gave %d redundanc%s\n", 
		    queue_length - start_length, s);
	    if (queue_length != 0)
	       print_array (queue, 1, queue_length + 1);
	 }

	 t = runTime () - t;
	 printf ("Formula evaluation took %.2f seconds\n", t * CLK_SCALE);
	 break;

      case OUTPUT_PRESENTATION:
	 name = GetString ("Enter output file name: ");
	 read_value (TRUE, "Output file in CAYLEY (1) or GAP (2) or Magma (3) format? ", 
		     &file_format, CAYLEY_PRES_FORMAT);
	 FileName = OpenFile (name, "a+");
	 if (FileName != NULL) {
	    if (file_format == CAYLEY_PRES_FORMAT) {
	       CAYLEY_presentation (FileName, pcp);
	       printf ("Group presentation written in CAYLEY format to file\n");
	    }
	    else if (file_format == GAP_PRES_FORMAT) {
	       GAP_presentation (FileName, pcp, 1);
	       printf ("Group presentation written in GAP format to file\n");
	    }
	    else if (file_format == MAGMA_PRES_FORMAT) {
	       Magma_presentation (FileName, pcp);
	       printf ("Group presentation written in Magma format to file\n");
	    }
	    else
	       printf ("Format must be %d or %d or %d\n", 
		       CAYLEY_PRES_FORMAT, GAP_PRES_FORMAT, MAGMA_PRES_FORMAT);
	 }
	 CloseFile (FileName);
	 break;

      case COMPACT_PRESENTATION:
	 compact_description (TRUE, pcp);
	 printf ("Group description written to gps%d^%d\n", pcp->p, pcp->lastg);
	 break;

      case EXIT: case MAXOPTION:
	 printf ("Exiting from interactive p-Quotient menu\n");
	 break;

      }                         /* switch */
   } while (option != 0 && option != MAXOPTION);      

   if (queue_setup) {
      free_vector (queue, 1);
      free_vector (long_queue, 1);
   }
}

/* interactive p-quotient menu */

void list_interactive_pq_menu ()
{
   printf ("\nAdvanced p-Quotient Menu\n");
   printf ("-------------------------\n");
   printf ("%d. Do individual collection\n", COLLECT); 
   printf ("%d. Solve the equation ax = b for x\n", SOLVE);
   printf ("%d. Calculate commutator\n", COMMUTATOR);
   printf ("%d. Display group presentation\n", DISPLAY_PRESENTATION);
   printf ("%d. Set print level\n", PRINT_LEVEL);
   printf ("%d. Set up tables for next class\n", SETUP);
   printf ("%d. Insert tails for some or all classes\n", TAILS);
   printf ("%d. Check consistency for some or all classes\n", CONSISTENCY);
   printf ("%d. Collect defining relations\n", RELATIONS);
   printf ("%d. Carry out exponent checks\n", EXTRA_RELATIONS);
   printf ("%d. Eliminate redundant generators\n", ELIMINATE);
   printf ("%d. Revert to presentation for previous class\n", LAST_CLASS);
   printf ("%d. Set maximal occurrences for pcp generators\n", MAXOCCUR);
   printf ("%d. Set metabelian flag\n", METABELIAN);
   printf ("%d. Carry out an individual consistency calculation\n", JACOBI);
   printf ("%d. Carry out compaction\n", COMPACT);
   printf ("%d. Carry out echelonisation\n", ECHELON);
   printf ("%d. Supply and/or extend automorphisms\n", AUTS);
   printf ("%d. Close relations under automorphism actions\n", CLOSE_RELATIONS);
   printf ("%d. Print structure of a range of pcp generators\n", STRUCTURE);
   printf ("%d. Display automorphism actions on generators\n", 
	   LIST_AUTOMORPHISMS);
   printf ("%d. Write automorphism actions on generators in Magma format\n", 
	   MAGMA_AUTOMORPHISMS);
   printf ("%d. Collect word in defining generators\n", DGEN_WORD);
   printf ("%d. Compute commutator of defining generators\n", DGEN_COMM);
   printf ("%d. Write presentation to file in CAYLEY/GAP/Magma format\n", 
	   OUTPUT_PRESENTATION);
   printf ("%d. Write compact description of group to file\n", 
	   COMPACT_PRESENTATION);
   printf ("%d. Evaluate certain formulae\n", FORMULA);
   printf ("%d. Evaluate action specified on defining generators\n", DGEN_AUT);
   printf ("%d. Evaluate Engel (p - 1)-identity\n", ENGEL);
   printf ("%d. Process contents of relation file\n", RELATIONS_FILE);
   printf ("%d. Exit to basic menu\n", MAXOPTION);
}

#endif

/* set up space for the queues used in exponent checking */

int queue_space (queue, long_queue, current_qlength, prev_qlength, pcp)
int **queue; 
int **long_queue;
int *current_qlength;
int *prev_qlength; 
struct pcp_vars *pcp;
{
   *current_qlength = pcp->lastg - pcp->ccbeg + 1;
   if (*prev_qlength == 0) {
      *queue = allocate_vector (*current_qlength, 1, FALSE);
      *long_queue = allocate_vector (*current_qlength, 1, FALSE);
   }
   else if (*current_qlength != *prev_qlength) {
      *queue = reallocate_vector (*queue, *prev_qlength, 
				  *current_qlength, 1, FALSE);
      *long_queue = reallocate_vector (*long_queue, *prev_qlength, 
				       *current_qlength, 1, FALSE);
   }
   *prev_qlength = *current_qlength;

   return 0;
}
