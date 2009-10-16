/****************************************************************************
**
*A  stages.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: stages.c,v 1.5 2001/06/15 14:31:52 werner Exp $
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

/* begin intermediate stage calculations; descendant_file contains the  */

void start_stage (descendant_file, k, auts, pga, pcp)  
FILE_TYPE descendant_file;
int k;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int nmr_of_covers;
   FILE_TYPE covers_file;

   covers_file = TemporaryFile ();

   nmr_of_covers = reduced_covers (descendant_file, 
				   covers_file, k, auts, pga, pcp); 
   if (pcp->overflow) exit (FAILURE);

   if (nmr_of_covers != 0) {
      RESET(covers_file);
      intermediate_stage (descendant_file, covers_file, nmr_of_covers, pga, pcp);
   }
   else
      CloseFile (covers_file);
}

/* input_file contains nmr_of_covers reduced p-covering 
   groups from one intermediate stage of computations;
   process all of these, writing new reduced p-covering 
   groups constructed (if any) to file covers_file;

   note that this procedure is called recursively */

void intermediate_stage (descendant_file, input_file, nmr_of_covers, pga, pcp) 
FILE_TYPE descendant_file;
FILE_TYPE input_file;
int nmr_of_covers;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   register int i;
   int ***auts;
   int next_stage = 0;          /* total number of covers constructed at next stage */
   int nmr_of_descendants;
   int nmr_of_capables;
   int x_dim, y_dim; 

   FILE_TYPE covers_file;
   covers_file = TemporaryFile ();

   for (i = 1; i <= nmr_of_covers; ++i) {
      nmr_of_descendants = pga->nmr_of_descendants;
      nmr_of_capables = pga->nmr_of_capables;
      restore_pcp (input_file, pcp); 

      if (i != 1)
	 free_array (auts, x_dim, y_dim, 1);
      auts = restore_pga (input_file, pga, pcp);
      x_dim = pga->m; y_dim = pcp->lastg;
      pga->nmr_of_descendants = nmr_of_descendants;
      pga->nmr_of_capables = nmr_of_capables;
      next_stage += reduced_covers (descendant_file, covers_file, 
				    0, auts, pga, pcp);
      if (pcp->overflow) exit (FAILURE);
   }

   free_array (auts, x_dim, y_dim, 1);

   CloseFile (input_file);

   if (next_stage != 0) {
      RESET(covers_file);
      intermediate_stage (descendant_file, covers_file, next_stage, pga, pcp);
   }
   else
      CloseFile (covers_file);
}
