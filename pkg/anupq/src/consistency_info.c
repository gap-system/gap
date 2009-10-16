/****************************************************************************
**
*A  consistency_info.c          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: consistency_info.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"
#include "exp_vars.h"
#include "pq_functions.h"

/* read information for consistency checking */

void consistency_info (consistency_flag)
int *consistency_flag;
{
   Logical reading = TRUE;

   while (reading) {
      read_value (TRUE, "Process all consistency relations (0), Type 1, Type 2, or Type 3? ", 
		  consistency_flag, 0);
      reading = (*consistency_flag > 3);
      if (reading) printf ("Supplied value must lie between 0 and 3\n");
   }

}
