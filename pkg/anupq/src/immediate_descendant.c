/****************************************************************************
**
*A  immediate_descendant.c      ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: immediate_descendant.c,v 1.7 2001/09/25 13:30:49 gap Exp $
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
#include "pq_functions.h"

/* if immediate descendant is capable or terminal flag
   is set, save its covering group to descendant_file and 
   compute required central automorphisms */

int*** immediate_descendant (descendant_file, pga, pcp)
FILE_TYPE descendant_file;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int ***central;
   int **auts;
   struct exp_vars exp_flag;

   /* compute the p-covering group of the descendant */

   /* if metabelian law is to be enforced, set pcp flag true */
   if (pga->metabelian)
      pcp->metabelian = TRUE;

   pcp->multiplicator = TRUE;
   next_class (FALSE, auts, auts, pcp);
   if (pcp->overflow) exit (FAILURE);
   pcp->multiplicator = FALSE;

   /* enforce an exponent law, if any */
   if (pga->exponent_law) {
      pcp->extra_relations = pga->exponent_law;
      initialise_exponent (&exp_flag, pcp);
#ifdef Magma
      extra_relations (&exp_flag, NULL_HANDLE, pcp);
#else
      extra_relations (&exp_flag, pcp);
#endif
      eliminate (0, pcp);
   }

   pga->capable = (pcp->newgen != 0);

/* pga->capable = FALSE;
pga->terminal = FALSE;
*/

   pcp->multiplicator_rank = pcp->lastg - y[pcp->clend + pcp->cc - 1];

   /* possible that nucleus is trivial but presentation 
      for p-covering group present */
   if (pga->terminal && pcp->newgen == 0 && pcp->complete == FALSE) {
      last_class (pcp);
      pcp->complete = TRUE;
   }

/* 
   if (pga->trace || (pga->capable && pga->print_automorphisms 
		      && pga->final_stage && !pga->print_group)) {
      printf ("------------------------------------------\n");
      printf ("Immediate descendant %s\n", pcp->ident);
   }
*/
                                            
   if (pga->print_nuclear_rank) 
      printf ("Group %s has nuclear rank %d\n", pcp->ident, pcp->newgen);

   if (pga->print_multiplicator_rank) 
      printf ("Group %s has %d-multiplicator rank %d\n", pcp->ident,
	      pcp->p, pcp->lastg - y[pcp->clend + pcp->cc - 1]);

   /* if descendant is capable or terminal is true, 
      compute central automorphisms */
   if (pga->capable || pga->terminal) { 
      /* save group description to file -- if group is capable, save 
	 p-covering group presentation, else save that of group */
      save_pcp (descendant_file, pcp);

      set_values (pga, pcp);

      /* revert to last class for automorphism group calculations */
      if (!pcp->complete)
	 last_class (pcp);

      /* determine the required central outer automorphisms */
      central = central_automorphisms (pga, pcp); 
      if (pga->print_automorphisms) 
	 print_auts (pga->nmr_centrals, pga->ndgen, central, pcp);
   }

   return central;
}
