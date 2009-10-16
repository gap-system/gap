/****************************************************************************
**
*A  exponent_info.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: exponent_info.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"
#include "exp_vars.h"
#include "pq_functions.h"

/* read information for exponent checking */

void exponent_info (exp_flag, pcp)
struct exp_vars *exp_flag;
struct pcp_vars *pcp;
{
   Logical reading = TRUE;
   Logical Default;
   
   read_value (TRUE, "Accept default exponent checking? ", &Default, INT_MIN);

   if (Default) {
      exp_flag->list = (pcp->m == 0) ? ALL_WORDS : REDUCED_LIST;
      exp_flag->process = TRUE;
      exp_flag->complete = FALSE;
      exp_flag->partitions = FALSE;
      exp_flag->filter = FALSE;
      exp_flag->start_process = 0;
      exp_flag->report_unit = 0;
      exp_flag->word_list = FALSE;
      exp_flag->all_trivial = TRUE;
      exp_flag->check_exponent = FALSE;
      return;
   }

   while (reading) {
      read_value (TRUE, "Complete list (1), reduced list (2), or word list (3)? ", 
		  &exp_flag->list, 1);
      reading = !(exp_flag->list == ALL_WORDS || exp_flag->list == REDUCED_LIST
		  || exp_flag->list == INITIAL_SEGMENT); 
      if (reading) printf ("Supplied value must be one of %d, %d, or %d\n",
			   ALL_WORDS, REDUCED_LIST, INITIAL_SEGMENT); 
   }

   read_value (TRUE, "Power valid words and echelonise results? ", 
	       &exp_flag->process, INT_MIN);

   if (exp_flag->process) { 
      read_value (TRUE, "Input number of the first valid word to process? ", 
		  &exp_flag->start_process, 0);
      read_value (TRUE, "Report after collecting how many words (0 for no report)? ", 
		  &exp_flag->report_unit, 0);
   }
   else {
      exp_flag->start_process = 0;
      exp_flag->report_unit = 0;
   }

   read_value (TRUE, "Print list prior to applying filters? ", 
	       &exp_flag->complete, INT_MIN);


   read_value (TRUE, "Identify filter applied to remove word? ", 
	       &exp_flag->filter, INT_MIN);

   read_value (TRUE, "Write list of test words to relation file? ", 
	       &exp_flag->word_list, INT_MIN);

   exp_flag->partitions = FALSE;
}

/* default exponent flag settings */

void initialise_exponent (exp_flag, pcp)
struct exp_vars *exp_flag;
struct pcp_vars *pcp;
{  
   int length;

   exp_flag->list = ALL_WORDS;
   exp_flag->process = TRUE;
   exp_flag->complete = FALSE;
   exp_flag->partitions = FALSE;
   exp_flag->filter = FALSE;
   exp_flag->start_process = 0;
   exp_flag->report_unit = 0;
   exp_flag->word_list = FALSE;
   exp_flag->all_trivial = TRUE;
   exp_flag->check_exponent = FALSE;

   if (pcp->m != 0) {
      length = MAX (1, pcp->lastg - pcp->ccbeg + 1 );
      exp_flag->queue = allocate_vector (length, 1, FALSE);
      exp_flag->queue_length = 0;
   }
}
