/****************************************************************************
**
*A  start_group.c               ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: start_group.c,v 1.5 2011/11/29 09:43:58 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"

FILE * TemporaryFile ();

/* save start group to StartFile */

void start_group (StartFile, auts, pga, pcp)
FILE * *StartFile;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   register int *y = y_address;

   int retain;
   int ***central;

   *StartFile = TemporaryFile ();
   save_pcp (*StartFile, pcp);
   retain = pcp->lastg;
   pcp->lastg = y[pcp->clend + pcp->cc - 1];
   pga->nmr_stabilisers = pga->m;
   pga->nmr_centrals = 0;
   pga->final_stage = TRUE;
   set_values (pga, pcp);
   save_pga (*StartFile, central, auts, pga, pcp);
   RESET(*StartFile);
   pcp->lastg = retain;
}
