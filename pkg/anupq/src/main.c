/****************************************************************************
**
*A  main.c                      ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: main.c,v 1.6 2001/06/21 23:04:21 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#ifdef NEEDS_TYPES_H
#include <sys/types.h>
#endif

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#include "constants.h"
#include "pq_author.h"
#include "menus.h"
#include "global.h"
#include "standard.h"

#if defined (QUOTPIC)
#include "times.h"
#endif 

#if defined (RUN_TIME)
#include "runtime.h"
#endif

/* main routine for p-quotient program; the run-time parameters are 

   -b to choose basic format for input of presentation; 
   -C to write CAYLEY group library;
   -G used by GAP 4, essentially equivalent to: -i -g -k simultaneously
      except that it also sends requests back via GAP's iostream when
      it needs GAP to compute stabilisers;
   -g to write GAP group library and to run pq from within GAP;
   -m to write Magma group library;
   -i to choose standard presentation menu;
   -k to read from file using key words; 
   -q to choose quotpic menu; 
   -s <integer> to allocate array of size <integer> for workspace y;
   -t to pass time limit in CPU seconds for computation 
      where t = 0 implies infinite time;
   -v prints the version of the pq binary and exits;
   -w <filename> to write group descriptions in CAYLEY/GAP/Magma format 
      to <filename> -- used in conjunction with -C or -g or -m

   if compiled with RUN_TIME flag then there are two additional options:
   -c to set class bound;
   -d to set defining generator bound;

   if workspace not passed, the default size of y is the constant PQSPACE */

int work_space = PQSPACE;
int format = PRETTY;
int menu = DEFAULT_MENU;
Logical StandardPresentation = FALSE;
Logical GAP4iostream = FALSE;

main (argc, argv)
int argc;
char *argv[];
{
#include "define_y.h"

   int t;
   struct pcp_vars pcp;
#include "access.h" 

#ifdef MALLOC_DEBUG
   malloc_debug (8);   
#endif

#ifndef VMS
   setbuf (stdout, NULL);
#endif

#if defined (QUOTPIC)
   time_limit = 0;
#endif 

   Compact_Description = FALSE;

   /* process run-time parameters */
   if (process_parameters (argc, argv) == 0) {
#if defined (RUN_TIME) 
      printf ("Usage: pq [-b] [-c] [-C] [-d] [-G] [-g] [-i] [-k] [-m] [-s <integer>] [-v] [-w <filename>]\n");
#else 
      printf ("Usage: pq [-b] [-C] [-G] [-g] [-i] [-k] [-m] [-s <integer>] [-v] [-w <filename>]\n");
#endif
      exit (INPUT_ERROR);
   }

#ifdef Magma
   y = (int *) allocate_vector (work_space + 1000, 0, FALSE);
   bh_initialize (y, work_space + 1000, NULL);
   bh_set_no_zeroing (1);
#endif
       
   Allocate_WorkSpace (work_space, &pcp);

   /* print startup message */
   print_message (work_space);

#if defined (QUOTPIC)
   if (menu == QUOTPIC_MENU)
      quotpic_menu (format, &pcp);
   else 
#endif
#if defined (GROUP) 
#if defined (STANDARD_PCP)
      if (menu == ISOM_MENU) 
	 isom_options (format, &pcp); 
      else 
#endif 
#endif 
	 options (DEFAULT_MENU, format, &pcp); 

   t = runTime ();
   printf ("Total user time in seconds is %.2f\n", t * CLK_SCALE);

   exit (SUCCESS);
}

/* process run-time parameters */

int process_parameters (argc, argv)
int argc;
char *argv[];
{
   int i;
   Logical error;

#if defined (RUN_TIME) 
   int A1, A3;
   A1 = 0; A3 = 0;
#endif

   Group_library_file = NULL;

   for (i = 1; i < argc; ++i) {
      if (strcmp (argv[i], "-s") == 0) {
	 if (i == argc - 1) return (0);
	 work_space = string_to_int (argv[++i], &error);
	 if (error) return (0);
      }
      else if (strcmp (argv[i], "-w") == 0) {
	 if (i == argc - 1 || argv[++i][0] == '-') 
	    return (0);
	 Group_library_file = allocate_char_vector (strlen (argv[i]), 0, FALSE);
	 strcpy (Group_library_file, argv[i]);
      }
      else if (strcmp (argv[i], "-b") == 0)  
	 format = BASIC;
#if defined (QUOTPIC)
      else if (strcmp (argv[i], "-t") == 0) {
	 if (i == argc - 1) 
	    return (0);
	 time_limit = (string_to_int (argv[++i], &error)) * CLK_TCK;
	 if (error) return (0);
      }
#endif 
#if defined (RUN_TIME) 
      else if (strcmp (argv[i], "-d") == 0) { 
	 if (i == argc - 1) return (0);
	 A1 = string_to_int (argv[++i], &error);
	 if (error) return (0);
      }
      else if (strcmp (argv[i], "-c") == 0)  {
	 if (i == argc - 1) return (0);
	 A3 = string_to_int (argv[++i], &error);
	 if (error) return (0);
      }
#endif
#if defined (STANDARD_PCP)
      else if (strcmp (argv[i], "-i") == 0)  
	 menu = ISOM_MENU;
#endif
      else if (strcmp (argv[i], "-k") == 0)  
	 format = FILE_INPUT;
      else if (strcmp (argv[i], "-C") == 0)  
	 Group_library = CAYLEY_LIBRARY;
      else if (strcmp (argv[i], "-G") == 0)  
	{Group_library = GAP_LIBRARY;
	 menu = ISOM_MENU;
	 format = FILE_INPUT;
         GAP4iostream = TRUE;}
      else if (strcmp (argv[i], "-g") == 0)  
	 Group_library = GAP_LIBRARY;
      else if (strcmp (argv[i], "-m") == 0)  
	 Group_library = Magma_LIBRARY;
#if defined (QUOTPIC)
      else if (strcmp (argv[i], "-q") == 0)  
	 menu = QUOTPIC_MENU;
#endif 
      else if (strcmp (argv[i], "-v") == 0)  
	{printf ("%s\n", PQ_VERSION);
         exit (SUCCESS);}
      else 
	 return (0);
   }        

#if defined (RUN_TIME) 
   ExamineOptions (A1, A3);
#endif

#if defined (GAP)
   CreateGAPLibraryFile ();
#endif 

   return 1;
}

#if defined (RUN_TIME) 

/* how many bits are needed to store x? */

int NmrOfBits (x)
int x;
{
   int nmr = 0;
   while (x >= 1) {x = x >> 1; ++nmr;}
   return nmr;
}

int ExamineOptions (A1, A3)
int A1, A3;
{  
   if (A1 == 0 && A3 == 0) return;
  
   if (A1 <= 0 || A3 <= 0) {
      printf ("You must supply positive values for each of -d and -c\n");
      exit (INPUT_ERROR);
   }

   A1 = NmrOfBits (A1);
   A3 = NmrOfBits (A3);

   if (A1 + A3 >= WORD_LENGTH) {
      printf ("Product of the values for -d and -c must need at most %d bits\n",
	      WORD_LENGTH - 1);
      exit (INPUT_ERROR);
   }

   GSC1 = A1;
   GSC2 = WORD_LENGTH - (A1 + A3);

   MAXGENS = int_power (2, GSC1) - 1;
   MAXPC = int_power (2, GSC2) - 1;
   MAXCLASS = int_power (2, A3) - 1;

   printf ("********************************************\n");
   printf ("Program now uses the following bounds:\n");
   printf ("Number of defining generators: %d\n", MAXGENS); 
   printf ("Number of pc generators: %d\n", MAXPC); 
   printf ("Class bound: %d\n", MAXCLASS); 
   printf ("********************************************\n");
}

#endif

#if defined (GAP)

/* if pq is called successfully from GAP, we want GAP_library file to exist 
   in all cases, even if no group descriptions have been saved to it */

void CreateGAPLibraryFile ()
{
   FILE *GAP_library;
   
   if (Group_library == GAP_LIBRARY) {
      if (Group_library_file == NULL)
	 Group_library_file = "GAP_library";
      GAP_library = OpenFile (Group_library_file, "a+");
      fprintf (GAP_library, "ANUPQmagic := \"groups saved to file\";\n");
      CloseFile (GAP_library);
   }
}

#endif 
