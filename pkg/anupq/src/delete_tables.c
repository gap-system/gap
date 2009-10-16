/****************************************************************************
**
*A  delete_tables.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: delete_tables.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"

/* subroutine to delete all word and subgroup tables 
   entries, depending upon the value of type; 
   if type = 1 delete only the word table entries; 
   if type = 2, delete only the subgroup table entries; 
   if type = 0, delete both */

void delete_tables (type, pcp)
int type;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int j;
   register int n;
   register int p1;
   register int nsubgp = pcp->nsubgp;
   register int address;

   /* delete all entries (pointers) in the words table */
   if (type != 2) {
      if ((n = pcp->nwords) != 0) {
	 address = pcp->words;
	 for (i = 1; i <= n; i++)
	    if ((p1 = -y[address + i]) != 0)
	       y[p1] = 0;

	 /* shift up the subgroup table, if it exists */
	 if (type && pcp->nsubgp) {
	    j = pcp->structure + 1;
	    for (i = 1; i <= nsubgp; i++, j--) {
	       p1 = y[j - n];
	       y[j] = p1;
	       if (p1 != 0)
		  y[-p1] = j;
	    }
	    pcp->subgrp = j - 1;
	    pcp->submlg = pcp->subgrp - pcp->lastg;
	 }
	 pcp->words = pcp->structure;
	 pcp->nwords = 0;
      }
   }

   /* delete all entries (pointers) in the subgroup table */
   if (type != 1) {
      address = pcp->subgrp;
      for (i = 1; i <= nsubgp; i++) {
	 if ((p1 = -y[address + i]) != 0) {
	    y[address + i] = 0;
	    y[p1] = 0;
	 }
      }
      pcp->nsubgp = 0;
      pcp->subgrp = pcp->words;
      pcp->submlg = pcp->subgrp - pcp->lastg;
   }
}
