/****************************************************************************
**
*A  quotpic.c                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: quotpic.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (QUOTPIC)

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "menus.h"
#include "pq_functions.h"

void list_quotpic_menu ();

#define MAXOPTION 4           /* maximum number of menu options */

/* control routine for link from QUOTPIC program to p-quotient program */

void quotpic_menu (format, pcp)
int format;
struct pcp_vars *pcp;
{
   int option, t;
   int output_bound;

   if (isatty (0))
      list_quotpic_menu ();

   do {
      option = read_option (MAXOPTION);      
      switch (option) {

      case -1:
	 list_quotpic_menu ();
	 break;

      case PQ_OPTIONS:
	 options (QUOTPIC_MENU, format, pcp);
	 break;

      case MATRIX:
	 t = runTime ();
	 /* if number of generators of quotient is less than k,
	    where k is supplied, and hence the extension degree 
	    is less than p^k, then compute and display the 
	    necessary matrix */
	 read_value (TRUE, "Input bound on number of generators to output: ", 
		     &output_bound, 0);
	 if (pcp->lastg <= output_bound) {
	    extend_representation (pcp);
	    printf ("Time to compute matrix is %.2f seconds\n", 
		    (runTime () - t) * CLK_SCALE);
	 }
	 else {
	    printf ("The order of the group exceeds the supplied bound\n");
	 }

	 break;

      case MEATAXE: 
	 meataxe_result (pcp);
	 t = runTime ();
	 break;

      case EXIT: case MAXOPTION:
	 printf ("Exiting from Quotpic Menu\n");
	 break;
      }                         /* switch */
   } while (option != 0 && option != MAXOPTION);      
}

void list_quotpic_menu ()
{
   printf ("\nQuotpic Menu\n");
   printf ("----------------\n");
   printf ("%d. Go to p-quotient menu\n", PQ_OPTIONS);
   printf ("%d. Compute matrix\n", MATRIX);
   printf ("%d. Process meataxe results\n", MEATAXE);
   printf ("%d. Exit from Quotpic Menu\n", MAXOPTION);
}

#endif 
