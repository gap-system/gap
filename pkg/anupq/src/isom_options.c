/****************************************************************************
**
*A  isom_options.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: isom_options.c,v 1.5 2001/06/21 23:04:21 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (GROUP)
#if defined (STANDARD_PCP)
#include "constants.h"
#include "pq_defs.h"
#include "pretty_filterfns.h"
#include "standard.h"
#include "menus.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "pq_functions.h"
#include "word_types.h"

#ifdef __386BSD__
static char FileBuffer[1024];

copy_file ( from , to )
    char*   from;
    char*   to;
{
   FILE*   in;
   FILE*   out;
   int     n;

   in  = fopen( from, "r" );
   if ( in == NULL )
   {
      perror(from);
      exit(FAILURE);
   }
   out = fopen( to, "w" );
   if ( out == NULL )
   {
      perror(to);
      exit(FAILURE);
   }
   do
   {
      n = fread( FileBuffer, 1, 1024, in );
      if ( 0 < n )
	 fwrite( FileBuffer, 1, n, out );
      if ( ferror(in) )
      {
	 perror(from);
	 exit(FAILURE);
      }
      if ( ferror(out) )
      {
	 perror(to);
	 exit(FAILURE);
      }
   }
   while ( !feof(in) );
   fclose(in);
   fclose(out);
}

append_file ( from , to )
    char*   from;
    char*   to;
{
   FILE*   in;
   FILE*   out;
   int     n;

   in = fopen( from, "r" );
   if ( in == NULL )
   {
      perror(from);
      exit(FAILURE);
   }
   out = fopen( to, "a" );
   if ( out == NULL )
   {
      perror(to);
      exit(FAILURE);
   }
   do
   {
      n = fread( FileBuffer, 1, 1024, in );
      if ( 0 < n )
	 fwrite( FileBuffer, 1, n, out );
      if ( ferror(in) )
      {
	 perror(from);
	 exit(FAILURE);
      }
      if ( ferror(out) )
      {
	 perror(to);
	 exit(FAILURE);
      }
   }
   while ( !feof(in) );
   fclose(in);
   fclose(out);
}

#endif

#define ISOM_OPTION 8
#define MAXOPTION 9           /* maximum number of menu options */

void list_isom_menu ();

/* control routine for computing standard presentation */

void isom_options (format, pcp)
int format;
struct pcp_vars *pcp;
{
#include "define_y.h"

   FILE *Status;
   FILE *FileName;
   FILE *Subgroup;

   struct pga_vars pga;

   Logical user_supplied = FALSE;
   Logical group_present = FALSE;
   Logical identity_map;
   Logical finished;
   Logical valid;
   Logical equal;

   int output = DEFAULT_STANDARD_PRINT;
   int start_class, final_class;
   int option;
   int t;
   int status;
   int complete;
   int iteration;
   int *seq1;
   int *seq2;
   int len1, len2;
   int nmr_items;
   int ***auts;
   int x_dim, y_dim;
   FILE_TYPE GAP_library;
   char *name;
   char *command;
   int nmr_of_exponents;

   StandardPresentation = TRUE;
   pga.nmr_soluble = 0;

   list_isom_menu ();

   do {
      option = read_option (MAXOPTION);      
      switch (option) {

      case -1:
	 list_isom_menu ();
	 break;

      case START_INFO:
	 t = runTime ();
	 group_present = setup_start_info (FALSE, 0, stdin, format, &pga, pcp);
	 handle_error (group_present);
	 user_supplied = TRUE;
	 t = runTime () - t;
	 /* it is possible that the p-quotient is trivial */
	 if (pcp->cc == 0) {
	    group_present = FALSE; 
	    break; 
	 }
	 printf ("Class %d %d-quotient and its %d-covering group computed in %.2f seconds\n", 
		 pcp->cc - 1, pcp->p, pcp->p, t * CLK_SCALE);
	 break;

      case CONSTRUCT:
	 if (!user_supplied) {
	    name = GetString ("Enter input file name for group information: ");
	    FileName = OpenFile (name, "r");
	    if (FileName == NULL) break;
	 }
            
	 name = GetString ("Enter output file name for group information: ");

	 read_value (TRUE, "Standardise presentation to what class? ",
		     &final_class, 0);
	 if (user_supplied && final_class < pcp->cc) { 
	    printf ("Value supplied for end class must be at least %d\n", 
		    pcp->cc);
	 }

	 /* read in data from file and set up group to end of start_class 
	    and compute its p-covering group */

	 if (!user_supplied) {
	    group_present = setup_start_info (FALSE, 0, FileName, 
					      FILE_INPUT, &pga, pcp);
	    handle_error (group_present);
	    if (final_class < pcp->cc) {
	       CloseFile (FileName);
	       printf ("Value supplied for end class must be at least %d\n", 
		       pcp->cc);
	    }
	 }

	 if (pcp->cc == 0) { 
	    printf ("%d-quotient is trivial\n", pcp->p); 
	    break;
	 }

	 complete = (pcp->newgen == 0) ? TERMINAL : CAPABLE; 
	 iteration = 0;

	 for (start_class = pcp->cc; start_class <= final_class && 
		 complete != TERMINAL; ++start_class) {

	    t = runTime ();

	    identity_map = FALSE;
	    Subgroup = OpenFile ("ISOM_Subgroup", "w");

	    do {
	       ++iteration;
	       set_defaults (&pga);
	       /*
		 pga.space_efficient = TRUE;
		 */

	       /* either prompt for information or read it from file */
	       if (user_supplied) {
		  auts = read_auts (STANDARDISE, &pga.m, &nmr_of_exponents, pcp)
		     ;
		  pga.fixed = 0;
		  query_solubility (&pga);
		  user_supplied = FALSE;
#if defined (LARGE_INT) 
		  autgp_order (&pga, pcp);
#endif 
	       }
	       else {
		  auts = read_auts_from_file (FileName, &pga.m, pcp);
		  nmr_items = fscanf (FileName, "%d", &pga.fixed);
		  verify_read (nmr_items, 1);
		  nmr_items = fscanf (FileName, "%d", &pga.soluble);
		  verify_read (nmr_items, 1);

#if defined (LARGE_INT)
		  fscanf (FileName, "\n");
		  mpz_init (&pga.aut_order);
		  mpz_inp_str (&pga.aut_order, FileName, 10);
#endif
		  CloseFile (FileName);
	       }
	       x_dim = pga.m; y_dim = pcp->lastg;

	       /* construct standard presentation relative to smallest 
		  permissible characteristic subgroup in p-multiplicator */

	       standard_presentation (&identity_map, output, auts, &pga, pcp);

	       free_array (auts, x_dim, y_dim, 1);

	       /* was the characteristic subgroup chosen in this iteration
		  the whole of the p-multiplicator? */

	       Status = OpenFile ("ISOM_Status", "r");
	       fscanf (Status, "%d", &status);
	       fscanf (Status, "%d", &complete);
	       CloseFile (Status);
                 
	       /* have we finished the construction? */
	       finished = (status == END_OF_CLASS && 
			   (start_class == final_class || complete == TERMINAL));

	       /* organise to write modified presentation + automorphisms 
		  to file ISOM_PP */
              
#ifdef __386BSD__
	       if (!identity_map || finished)  
	       {
		  copy_file( "ISOM_present", "ISOM_PP" );
		  append_file( "ISOM_NextClass", "ISOM_PP" );
	       }
	       else
		  copy_file( "ISOM_NextClass", "ISOM_PP" );
#else
	       if (!identity_map || finished)  
		  system ("cat ISOM_present ISOM_NextClass > ISOM_PP");
	       else
		  system ("cat ISOM_NextClass > ISOM_PP");
#endif

	       if (finished) break;

	       /* if necessary, set up new presentation + other information */
	       FileName = OpenFile ("ISOM_PP", "r");
	       group_present = setup_start_info (identity_map, status, 
						 FileName, FILE_INPUT, &pga, pcp);

	       handle_error (group_present);

	       /* if appropriate, factor subgroup from p-multiplicator */
	       if (status != END_OF_CLASS) 
		  factor_subgroup (pcp);

	       /* reinitialise pga structure */
	       initialise_pga (&pga, pcp);
	       pga.m = 0;
	       pga.ndgen = y[pcp->clend + 1];
	       set_values (&pga, pcp);

	    } while (status != END_OF_CLASS && complete != TERMINAL);

	    CloseFile (Subgroup);

	    /* the group may have completed only when relations are enforced;
	       this is an attempt to determine this case */
	    if (pga.nuclear_rank != 0 && pcp->complete) 
	       break;
            
	    t = runTime () - t;
	    printf ("Computing standard presentation for class %d took %.2f seconds\n", 
		    start_class, t * CLK_SCALE);
	 }

	 /* we currently may have presentation for p-covering group;
	    or is the starting group terminal? if so, we may want to 
	    use last_class to revert to group presentation */

	 if (!user_supplied && iteration == 0 && !pcp->complete)
	    last_class (pcp);

	 /* is the group terminal? */
	 if (complete == TERMINAL) 
	    printf ("The largest %d-quotient of the group has class %d\n", 
		    pcp->p, pcp->cc);

	 if (iteration == 0) break;

	 /* copy file ISOM_PP containing iteration info to nominated file */
#ifdef __386BSD__
	 rename( "ISOM_PP", name );
#else
	 command = (char *) malloc ((strlen (name) + 15) * sizeof (char));
	 strcpy (command, "mv ISOM_PP ");
	 strcat (command, name);
	 system (command);
	 free (command);
#endif

	 break;

      case PRINT_PCP:
	 if (group_present) 
	    print_presentation (TRUE, pcp);
	 break;

      case SAVE_PRES:
	 name = GetString ("Enter output file name: ");
	 FileName = OpenFileOutput (name);
	 if (group_present && FileName != NULL) {
	    save_pcp (FileName, pcp);
	    CloseFile (FileName);
	    printf ("Presentation written to file\n");
	 }
	 break;
 
      case COMPARE:
	 valid = get_description ("Enter file name storing first presentation: ",
				  &len1, &seq1, pcp);
	 if (!valid) break;
	 valid = get_description ("Enter file name storing second presentation: ", 
				  &len2, &seq2, pcp);

	 if (!valid) break;
	 equal = (len1 == len2) ? compare_sequences (seq1, seq2, len1): FALSE;

	 printf ("Identical presentations? %s\n", equal == TRUE ? 
		 "True" : "False");
	 free_vector (seq1, 1);
	 free_vector (seq2, 1);
	 break;

      case STANDARD_PRINT_LEVEL: 
	 read_value (TRUE, "Input print level for construction (0-2): ",
		     &output, 0);
	 /* allow user to supply same max print level as for 
	    p-quotient calculations */
	 if (output == MAX_STANDARD_PRINT + 1)
	    --output; 
	 if (output > MAX_STANDARD_PRINT) {
	    printf ("Print level must lie between %d and %d\n",
		    MIN_STANDARD_PRINT, MAX_STANDARD_PRINT);
	    output = DEFAULT_STANDARD_PRINT;
	 }
	 break;

      case PQ_MENU:
	 options (ISOM_MENU, format, pcp);
	 break;

      case ISOM_OPTION:
	 FileName = OpenFile (name, "r");
	 group_present = setup_start_info (FALSE, 0, FileName, 
					   FILE_INPUT, &pga, pcp);
         pcp->multiplicator_rank = pcp->lastg - y[pcp->clend + pcp->cc-1];
	 last_class (pcp);
	 auts = read_auts_from_file (FileName, &pga.m, pcp);
	 nmr_items = fscanf (FileName, "%d", &pga.fixed);
	 verify_read (nmr_items, 1);
	 nmr_items = fscanf (FileName, "%d", &pga.soluble);
	 verify_read (nmr_items, 1);
        
	 printf ("Images of user-supplied generators are listed last below\n"); 
	 print_map (pcp);
#if defined (LARGE_INT)
	 fscanf (FileName, "\n");
	 mpz_init (&pga.aut_order);
	 mpz_inp_str (&pga.aut_order, FileName, 10);
#endif
	 CloseFile (FileName);
	 GAP_library = OpenFile ("GAP_library", "a+");
	 write_GAP_library (GAP_library, pcp);
	 pga.nmr_centrals = pga.m;
	 pga.nmr_stabilisers = 0;

	 GAP_auts (GAP_library, auts, auts, &pga, pcp);
	 CloseFile (GAP_library);
	 printf ("Presentation listing images of user-supplied generators written to GAP_library\n");
	 break;

      case EXIT: case MAXOPTION:
#ifdef __386BSD__
	 unlink( "ISOM_present" );
	 unlink( "ISOM_Subgroup" );
	 unlink( "ISOM_cover_file" );
	 unlink( "ISOM_group_file" );
	 unlink( "ISOM_XX" );
	 unlink( "ISOM_NextClass" );
	 unlink( "ISOM_Status" );
#else
	 system ("rm -f ISOM_present ISOM_Subgroup ISOM_cover_file");
	 system ("rm -f ISOM_group_file ISOM_XX ISOM_NextClass ISOM_Status");
#endif
	 printf ("Exiting from ANU p-Quotient Program\n");
	 break;

      }                         /* switch */
   } while (option != 0 && option != MAXOPTION);      
}

/* list available menu options */

void list_isom_menu ()
{
   printf ("\nStandard Presentation Menu\n");
   printf ("-----------------------------\n");
   printf ("%d. Supply start information\n", START_INFO);
   printf ("%d. Compute standard presentation to supplied class\n", CONSTRUCT);
   printf ("%d. Save presentation to file\n", SAVE_PRES);
   printf ("%d. Display presentation\n", PRINT_PCP);
   printf ("%d. Set print level for construction\n", STANDARD_PRINT_LEVEL);
   printf ("%d. Compare two presentations stored in files\n", COMPARE);
   printf ("%d. Call basic menu for p-Quotient program\n", PQ_MENU);
   printf ("%d. Compute the isomorphism\n", ISOM_OPTION);
   printf ("%d. Exit from program\n", MAXOPTION);
}

/* set up the group to the desired class and its p-covering group;
   identity_map indicates whether standard automorphism applied
   was the identity; status indicates whether we are end of class;
   the presentation is read from file using indicated format */

Logical setup_start_info (identity_map, status, file, format, pga, pcp)
Logical identity_map;
Logical status;
FILE *file;
int format;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   FILE_TYPE FileName;
   FILE_TYPE presentation_file;
   Logical group_present = FALSE;
   int exit_value;
   int *list, *head;
   int i;

#if defined (TIME)
   int t;
   t = runTime ();
#endif 

   if (!identity_map) {

      /* we must recompute the presentation since generators and
	 relations have been altered by applying the standard map */ 

      /* memory leak September 1996 */
      if (user_gen_name != NULL) {
         num_gens = user_gen_name[0].first;

         for (i = 1; i <= num_gens; ++i) {
            free_vector (user_gen_name[i].g, 0);
         }
         free_vector (user_gen_name, 0);
         user_gen_name = NULL;
         free_vector (inv_of, 0);
         free_vector (pairnumber, 0);
      }

      exit_value = pquotient (0, 0, file, format, pcp);
      if (exit_value == SUCCESS) 
	 group_present = TRUE;

#if defined (TIME)
      printf ("Time to recompute pcp is %.2f\n", (runTime () - t) * CLK_SCALE);
#endif 

   }
   else {
      /* generators and relations of presentation have not changed --
	 we can restore presentation for either full p-covering group 
	 or class c + 1 quotient */
      if (status == END_OF_CLASS) 
	 presentation_file = OpenFile ("ISOM_group_file", "r");
      else 
	 presentation_file = OpenFile ("ISOM_cover_file", "r");

      restore_pcp (presentation_file, pcp);
      CloseFile (presentation_file);
      group_present = TRUE;
   }

#if defined (DEBUG)
   pcp->diagn = TRUE;
   printf ("The modified presentation is \n");
   print_presentation (TRUE, pcp);
   pcp->diagn = FALSE;
#endif 

   if (!group_present || pcp->cc == 0)
      return group_present;

   /* do we need to compute the full p-covering group? */

   if (!identity_map || status == END_OF_CLASS) {
      pcp->multiplicator = TRUE;
      next_class (FALSE, &head, &list, pcp);

      pga->exponent_law = pcp->extra_relations;
      pga->metabelian = pcp->metabelian;
      enforce_laws (pga, pga, pcp);

      pcp->multiplicator = FALSE;
      FileName = OpenFile ("ISOM_cover_file", "w");
      save_pcp (FileName, pcp);
      CloseFile (FileName);
   }

   initialise_pga (pga, pcp);
   pga->m = 0;
   pga->ndgen = y[pcp->clend + 1];
   set_values (pga, pcp);

   return group_present;
}

/* factor subgroup whose generators are listed in Subgroup file 
   from p-multiplicator to give reduced p-multiplicator */

void factor_subgroup (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   FILE_TYPE Subgroup;
   int flag;
   int cp;
   int i;

   Subgroup = fopen ("ISOM_Subgroup", "r");

   if (Subgroup == (FILE *) NULL) return;

   while (!feof (Subgroup)) {
 
      if (fscanf (Subgroup, "%d", &flag) == -1) 
	 continue;

      /* should we eliminate (in order to renumber the generators)? */
      if (flag == ELIMINATE)
	 eliminate (FALSE, pcp);

      if (fscanf (Subgroup, "%d", &flag) == -1)
	 continue;

      setup_symbols (pcp);
      cp = pcp->lused;
      setup_word_to_collect (Subgroup, PRETTY, WORD, cp, pcp);

      for (i = 1; i <= pcp->lastg; ++i)
	 y[cp + pcp->lastg + i] = 0;
  
      echelon (pcp);

   }
   CloseFile (Subgroup);
}

void handle_error (group_present)
Logical group_present;
{  
   if (group_present == FALSE) {
      printf ("Error in Standard Presentation Program\n");
      exit (FAILURE);
   }
}

/* compare two sequences, s and t, of length length */

Logical compare_sequences (s, t, length)
int *s;
int *t;
int length;
{
   register int i;
   Logical equal = TRUE;

   for (i = 1; i <= length && (equal = (s[i] == t[i])); ++i)
      ;

   return equal;
}

/* read group from file and set up its compact description 
   as sequence seq of length len */

int get_description (string, len, seq, pcp)
char *string;
int *len;
int **seq;
struct pcp_vars *pcp;
{
   char *name;
   FILE *file;

   name = GetString (string);
   file = OpenFile (name, "r");
   if (file == NULL) {
      if (isatty (0)) 
	 return FALSE;
      else
	 exit (FAILURE);
   }

   restore_pcp (file, pcp);
   CloseFile (file);

   /* length of sequence */
   *len = choose (pcp->lastg + 1, 3);

   /* sequence of exponents */
   *seq = compact_description (FALSE, pcp);

   return TRUE;
}
         
#endif 
#endif 
