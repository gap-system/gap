/****************************************************************************
**
*A  initialise_pcp.c            ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: initialise_pcp.c,v 1.6 2011/11/28 13:42:04 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"

/* initialise the contents of the pcp structure */

void initialise_pcp (output, pcp)
int output;
struct pcp_vars *pcp;
{
   pcp->fullop = output >= 2;
   pcp->diagn = output == 3;
   pcp->overflow = FALSE;
   pcp->multiplicator = FALSE;
   pcp->metabelian = FALSE;
   pcp->cover = FALSE;
   pcp->valid = TRUE;
   pcp->end_wt = 0;
   pcp->start_wt = 0;
   pcp->ncset = 0;
   pcp->complete = 0;
   pcp->nocset = 0;
   pcp->cc = 0;
   pcp->lastg = 0;
   pcp->pm1 = pcp->p - 1;
   pcp->m = 0;
}
