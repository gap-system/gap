/****************************************************************************
**
*A  is_space_exhausted.c        ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: is_space_exhausted.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"

/* beware - calls to this procedure are context sensitive since 
   it may call compact which moves strings; hence, calls should
   be carefully placed with a suitable upper bound as argument; 

   check if there is room available for required words; 
   if so, return FALSE, otherwise compact the workspace 
   and try again; if there is still no room, report this, 
   set pcp->overflow TRUE, and return TRUE */

Logical is_space_exhausted (required, pcp)
int required;
struct pcp_vars *pcp;   
{
#include "define_y.h"

   int remain;

   if (pcp->lused + required - pcp->subgrp <= 0)
      return FALSE;

   /* not enough room currently available, so we compact tables */
   compact (pcp);
   if (pcp->lused + required - pcp->subgrp <= 0)
      return FALSE;
   pcp->overflow = TRUE;
   /* number of generators in last class */
   remain = pcp->lastg - y[pcp->clend + pcp->cc - 1]; 
   text (11, remain, 0, 0, 0);
   return TRUE;
}
