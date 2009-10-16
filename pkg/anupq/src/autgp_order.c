/****************************************************************************
**
*A  autgp_order.c               ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: autgp_order.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (LARGE_INT) 

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "pq_functions.h"
#include "global.h"
#include "standard.h"

/* update the order of the automorphism group */

void update_autgp_order (orbit_length, pga, pcp)
int orbit_length;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int d, nmr_cent;
   MP_INT prime, nmr_centrals, orbit_size;
   MP_INT t;

   /* divide existing automorphism group order by size of orbit */
   mpz_init_set_si (&orbit_size, orbit_length);
   mpz_div (&(pga->aut_order), &(pga->aut_order), &orbit_size);

   /* multiply existing order by order of new central automorphisms */
   if (pga->final_stage) {

      d = y[pcp->clend + 1];
/* 
      nmr_cent = y[pcp->clend + pcp->cc] - y[pcp->clend + pcp->cc - 1];
*/
      nmr_cent = pga->nmr_centrals;

      mpz_init_set_si (&prime, pcp->p);
      mpz_init (&nmr_centrals);

/* 
      mpz_pow_ui (&nmr_centrals, &prime, nmr_cent * d);
*/
      mpz_pow_ui (&nmr_centrals, &prime, nmr_cent);

      mpz_init (&t);
      mpz_mul (&t, &(pga->aut_order), &nmr_centrals);
      mpz_set (&(pga->aut_order), &t);
      /*    mpz_mul (&(pga->aut_order), &(pga->aut_order), &nmr_centrals);
       */
      mpz_clear (&t);
      mpz_clear (&prime);
      mpz_clear (&nmr_centrals);
   }
   mpz_clear (&orbit_size);
}

/* report the group and automorphism group order */

void report_autgp_order (pga, pcp)
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int p, n;
   char *s;

   if (StandardPresentation) return;

   p = pcp->p;
   n = pcp->lastg;

   if (pga->print_automorphism_order && (pga->capable || pga->terminal)) {
      s = pga->upper_bound ? "at most " : "";
      printf ("Order of group is %d^%d;", p, n);
      printf (" automorphism group order is %s", s); 
      mpz_out_str (stdout, 10, &(pga->aut_order));
      printf ("\n");
   }
}


/* report the group and automorphism group order */

void Magma_report_autgp_order (Magma_rep, pga, pcp)
FILE *Magma_rep;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   fprintf (Magma_rep, "ANUPQsize := ");
   mpz_out_str (Magma_rep, 10, &(pga->aut_order));
   fprintf (Magma_rep, ";\n");
   fprintf (Magma_rep, "ANUPQagsize := ");
   fprintf (Magma_rep, "%d;;\n", pga->nmr_soluble);
}

/* compute (an upper bound for) the order of the automorphism group */

void autgp_order (pga, pcp)
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   MP_INT diff, prime, nmr_centrals, sub, large;
   MP_INT t;

   register int i, d, n, p;
   char *s;

   p = pcp->p;
   d = y[pcp->clend + 1];
   n = y[pcp->clend + pcp->cc - 1];

   mpz_init_set_si (&(pga->aut_order), 1);  
   mpz_init_set_si (&prime, pcp->p);

   /* large = p^d */
   mpz_init (&large);
   mpz_pow_ui (&large, &prime, d);

   mpz_init_set_si (&sub, 1);

   for (i = 0; i < d; ++i) {
      mpz_init (&diff);
      mpz_sub (&diff, &large, &sub);
      mpz_mul (&(pga->aut_order), &(pga->aut_order), &diff); 
      mpz_mul (&sub, &sub, &prime);
      mpz_clear (&diff);
   }

   mpz_init (&nmr_centrals);
   mpz_pow_ui (&nmr_centrals, &prime, (n - d) * d);
   /* mpz_mul (&(pga->aut_order), &(pga->aut_order), &nmr_centrals);
    */
   mpz_init (&t);
   mpz_mul (&t, &(pga->aut_order), &nmr_centrals);
   mpz_set (&(pga->aut_order), &t);
   mpz_clear (&t);

   mpz_clear (&sub);
   mpz_clear (&large);
   mpz_clear (&prime);
   mpz_clear (&nmr_centrals);

   /* if d < n, we only have an upper bound for the order */
   pga->upper_bound = (d < n);

   if (StandardPresentation) {
      s = pga->upper_bound ? "at most " : "";
      printf ("Starting group has order %d^%d;", p, n);
      printf (" its automorphism group order is %s", s); 
      mpz_out_str (stdout, 10, &(pga->aut_order));
      printf (" \n");
   }
}
#endif 
