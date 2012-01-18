/****************************************************************************
**
*A  read_parameters.c           ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: read_parameters.c,v 1.6 2011/12/02 16:42:15 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"

/* read parameters for p-quotient calculation */

void read_parameters (format, max_class, output, pcp)
int *max_class, *output;
struct pcp_vars *pcp;
{
   Logical reading = TRUE;
   char *ident;

#if defined (GROUP) 
   ident = GetString ("Input group identifier: ");
#endif 

   strcpy (pcp->ident, ident);

   while (reading) {
      read_value (TRUE, "Input prime: ", &pcp->p, 2);
      if (reading = (pcp->p != 2 && MOD(pcp->p, 2) == 0))
	 printf ("%d is not a prime\n", pcp->p);
   }

   read_value (TRUE, "Input maximum class: ", max_class, 0);
   if (*max_class == 0) {
      *max_class = DEFAULT_CLASS;
      text (15, DEFAULT_CLASS, 0, 0, 0);
   }
   else if (*max_class > MAXCLASS) {
      *max_class = MAXCLASS;
      text (15, MAXCLASS, 0, 0, 0);
   }

   print_level (output, pcp); 

   if (format == BASIC) {
      reading = TRUE;
      while (reading) {
	 read_value (TRUE, "Input number of generators: ", &pcp->ndgen, 1);
	 if (reading = (pcp->ndgen > MAXGENS)) 
	    printf ("The maximum number of defining generators is %d\n", MAXGENS);
      }

#if defined (GROUP)
      read_value (TRUE, "Input number of relations: ", &pcp->ndrel, 0);
      read_value (TRUE, "Input exponent law (0 if none): ", 
		  &pcp->extra_relations, 0);
#endif

      /* initialise pcp structure */
      initialise_pcp (*output, pcp);
      setup (pcp);
      read_relations (pcp);
   }
   else {
      pretty_read_generators (pcp);
      pretty_read_relations (*output, max_class, pcp);
   }
}
