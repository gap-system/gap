/****************************************************************************
**
*A  read.c                      ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: read.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#ifndef Magma
#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "pq_functions.h"
#include "constants.h"

/* check whether required data has been read from file */

void verify_read (nmr_items, required)
int nmr_items;
int required;
{
   if (nmr_items != required) { 
      printf ("Insufficent data read in from or written to file\n");
      exit (FAILURE);
   }
}

/* restore pcp structure from file ifp -- if selected workspace is
   larger or smaller than saved workspace, then update pointers */

void restore_pcp (ifp, pcp)
FILE *ifp;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i, j, l; 
   int new_workspace = pcp->backy;
   int offset = 0;
   int value, end, min;
   int weight, p1, p2;
   int nmr_items, total;

#include "access.h"

   nmr_items = fread (pcp, sizeof(struct pcp_vars), 1, ifp);
   verify_read (nmr_items, 1);

   /* this resetting of print flags may later be changed */
   pcp->fullop = FALSE;
   pcp->diagn = FALSE;

   if (new_workspace != pcp->backy) {
      if (new_workspace < pcp->backy) {
	 min = pcp->lused + (pcp->backy - pcp->structure + 1) + pcp->lastg;
	 if (new_workspace < min) {
	    printf ("Program workspace must be at least %d\n", min);
	    exit (FAILURE);
	 }
      }
      offset = new_workspace - pcp->backy; 
      pcp->backy += offset;
      pcp->structure += offset;
      pcp->subgrp += offset;
      pcp->words += offset;
      pcp->submlg += offset;
      pcp->ppower += offset;
      pcp->ppcomm += offset;
   }

   nmr_items = fread (y, sizeof(int), pcp->lused + 1, ifp);
   verify_read (nmr_items, pcp->lused + 1);

   total = pcp->backy - pcp->subgrp + 1; 
   nmr_items = fread (y + pcp->subgrp, sizeof(int), total, ifp);
   verify_read (nmr_items, total);

   if (offset != 0) {
      end = pcp->structure + pcp->lastg;
      for (i = pcp->structure + 1; i <= end; ++i) {
	 if ((value = y[i]) < 0) 
	    y[-value] += offset;
      }
      end = y[pcp->clend + pcp->cc - 1];
      for (i = 1; i <= end; i++) {
	 if ((value = y[pcp->ppower + i]) < 0) 
	    y[-value] += offset;
      }
      for (i = 2; i <= end; i++)  
	 y[pcp->ppcomm + i] += offset;

      for (i = 2; i <= end; i++) {
	 weight = WT(y[pcp->structure + i]);
	 p1 = y[pcp->ppcomm + i];
	 l = MIN(i - 1, y[pcp->clend + pcp->cc - weight]);
	 for (j = 1; j <= l; j++) {
	    p2 = y[p1 + j];
	    if (p2 < 0)
	       y[-p2] += offset;
	 }
      }
   }
}

/* fread in the pga structure and the automorphisms for group from file ifp */

int*** restore_pga (ifp, pga, pcp)
FILE *ifp;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i, j;
   int ***auts;
   int nmr_generators; 
   int nmr_items;

#if defined (LARGE_INT) 
   MP_INT aut_ord;

   mpz_init (&aut_ord);
   mpz_inp_str (&aut_ord, ifp, 10);
#endif 

   nmr_items = fread (pga, sizeof (struct pga_vars), 1, ifp);
   verify_read (nmr_items, 1);

#if defined (LARGE_INT) 
   mpz_init_set (&pga->aut_order, &aut_ord);
   mpz_clear (&aut_ord);
#endif 

   auts = allocate_array (pga->m, pcp->lastg, pcp->lastg, TRUE); 

   nmr_generators = pga->final_stage ?
      y[pcp->clend + pcp->cc - 1] : pcp->lastg;

   if (pga->nuclear_rank == 0) 
      nmr_generators = pcp->lastg;

   for (i = 1; i <= pga->m; ++i) { 
      for (j = 1; j <= pga->ndgen; ++j) {
	 nmr_items = fread (auts[i][j] + 1, sizeof (int), nmr_generators, ifp);
	 verify_read (nmr_items, nmr_generators);
      }
   }

   pga->relative = allocate_vector (pga->nmr_soluble, 1, FALSE); 
   fread (pga->relative + 1, sizeof (int), pga->nmr_soluble, ifp);                 
   return auts;
}
#endif
