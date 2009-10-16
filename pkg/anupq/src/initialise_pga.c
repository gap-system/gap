/****************************************************************************
**
*A  initialise_pga.c            ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: initialise_pga.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"

/* initialise the pga structure */

void initialise_pga (pga, pcp)
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   pga->p = pcp->p;
   pga->q = pga->r = pga->s = 0;
   pga->fixed = 0;
   pga->Degree = 0;
   pga->nmr_of_descendants = 0;
   pga->available = NULL;
   pga->list = NULL;
   pga->map = NULL;
   pga->rep = NULL;
   pga->offset = NULL;
   pga->powers = NULL;
   pga->inverse_modp = NULL;
}

/* set up values for pga structure */

void set_values (pga, pcp) 
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   pga->multiplicator_rank = y[pcp->clend + pcp->cc] - 
      y[pcp->clend + pcp->cc - 1];
   pga->nuclear_rank = pcp->newgen;
}
