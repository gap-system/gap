/****************************************************************************
**
*A  restore_group.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: restore_group.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "pq_functions.h"

/* restore the pcp description of group group_number 
   and its pga structure from input_file */

int*** restore_group (rewind_flag, input_file, group_number, pga, pcp) 
Logical rewind_flag;
FILE_TYPE input_file;
int group_number;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int ***auts;

   while (group_number > 0) {
      restore_pcp (input_file, pcp); 
      auts = restore_pga (input_file, pga, pcp);
      --group_number;
      if (group_number > 0)  
	 free_array (auts, pga->m, pcp->lastg, 1);
   }

   if (rewind_flag) 
      RESET(input_file); 

   return auts;
}
