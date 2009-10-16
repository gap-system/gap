/****************************************************************************
**
*A  pquotient.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pquotient.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"

/* coordinating routine for calculation of power-commutator presentation */

int pquotient (max_class, output, file, format, pcp)
int max_class;  /* maximum class of p-quotient to be constructed */
int output;     /* determines level of output */
FILE *file;     /* file containing input presentation */
int format;     /* input format for data */
struct pcp_vars *pcp;
{
   int *auts;
   Logical report;

   /* read parameters for computation */

   if (format == BASIC || format == PRETTY) {
      read_parameters (format, &max_class, &output, pcp);
      if (!pcp->valid)
	 if (isatty (0)) return FAILURE; else exit (INPUT_ERROR);
   }
   else if (format == FILE_INPUT) {
      if (pretty_filter (file, &max_class, &output, pcp) == INPUT_ERROR)
	 if (isatty (0)) return FAILURE; else exit (INPUT_ERROR);
      if (!pcp->valid)
	 if (isatty (0)) return FAILURE; else exit (INPUT_ERROR);
   }
#ifdef Magma
   else if (format == Magma_FORMAT) {
      t_handle g;

      g = pq_create_grp (&max_class, &output, pcp);
      pq_cayley_to_pq (g, pcp);
      /* initialise pcp structure */
      initialise_pcp (output, pcp);
      setup (pcp);
      pq_read_cay_rels (pcp);
      read_relations (pcp);
   }
   else if (format == Magma_INTERNAL) {
      t_handle g;

      /* initialise pcp structure */
      initialise_pcp (output, pcp);
      setup (pcp);
      read_relations (pcp);
   }
#endif

   /* if appropriate, print start message for pq */
   if (output > 0 && pcp->cc == 1 && file == stdin) {
      printf ("\nLower exponent-%d central series for %s\n", pcp->p, pcp->ident)
	 ;
   }

   /* now calculate the pcp, proceeding class by class */
   do {
      report = pcp->complete;
      next_class (FALSE, &auts, &auts, pcp);
      if (check_for_error (pcp)) return FAILURE;
      if (output != 0 && !pcp->complete)
	 print_presentation (pcp->diagn, pcp);
      if (report || (output == 1 && pcp->complete) || pcp->lastg < 1)
	 text (5, pcp->cc, pcp->p, pcp->lastg, 0);
      if ((pcp->cc > 1 && pcp->cc == pcp->nocset) || pcp->complete) 
	 break;
   } while (pcp->cc < max_class);

   /* if necessary, calculate p-multiplicator */
   if (pcp->cover) {
      pcp->multiplicator = TRUE;
      next_class (FALSE, &auts, &auts, pcp);
      /* reset flag which affects next_class computation */
      pcp->multiplicator = FALSE;
      if (check_for_error (pcp)) return FAILURE;
      text (12, pcp->p, pcp->lastg - pcp->ccbeg + 1, 0, 0);
      if (output != 0)
	 print_presentation (pcp->fullop, pcp);
   }

   return SUCCESS;
}

int check_for_error (pcp)
struct pcp_vars *pcp;
{
   /* insufficient space */
   if (pcp->overflow) {
      /*
	text (11, pcp->newgen, 0, 0, 0);
	*/
      if (!isatty (0))
	 exit (FAILURE);
      else
	 return 1;
        
   }

   /* validity error */
   if (!pcp->valid) {
      text (16, 0, 0, 0, 0);
      if (!isatty (0))
	 exit (INPUT_ERROR);
      else
	 return 1;
   }
   
   return 0;
}
