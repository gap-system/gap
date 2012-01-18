/****************************************************************************
**
*A  report_error.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: report_error.c,v 1.5 2011/12/31 19:36:23 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"

/* print a run-time error message -- it usually occurs 
   when a relation references an unknown generator */

void report_error (int a, int b, int c)
{
   printf ("The program has a run-time error. Please ");
   printf ("check that all generators\nused in the relations ");
   printf ("are declared in the generator list.\n");
   exit (INPUT_ERROR);
}
