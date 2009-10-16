/****************************************************************************
**
*A  degree.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: degree.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"
#include "pq_functions.h"
#include "constants.h"

/* compute the number of allowable subgroups;
   also, set up powers, offset, and inverses arrays */

void compute_degree (pga)
struct pga_vars *pga;
{
   register int i;
   register int maximum = 0;

   pga->Degree = 0;

   /* compute degree; store offset for each definition set */
   for (i = 0; i < pga->nmr_def_sets; ++i) {
      pga->offset[i] = pga->Degree;

      /* this is a test to try to prevent integer overflow */

      if (int_power (pga->p, pga->available[i]) > (INT_MAX - pga->Degree)) {
	 text (19, 0, 0, 0, 0);
	 if (!isatty (0)) 
	    exit (FAILURE);
	 else 
	    return;
      }
      pga->Degree += int_power (pga->p, pga->available[i]);
      if (maximum < pga->available[i]) 
	 maximum = pga->available[i];
   }

   /* store powers of prime */
   pga->powers = allocate_vector (maximum + 1, 0, 0);
   for (i = 0; i <= maximum; ++i)
      pga->powers[i] = int_power (pga->p, i);

   /* store inverses of 1 .. p - 1 */
   pga->inverse_modp = allocate_vector (pga->p, 0, 0);
   for (i = 1; i < pga->p; ++i)
      pga->inverse_modp[i] = invert_modp (i, pga->p);

   if (pga->print_degree)
      printf ("Degree of permutation group is %d\n", pga->Degree);
}
