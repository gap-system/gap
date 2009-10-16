/****************************************************************************
**
*A  report_error.c              ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: report_error.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "constants.h"

/* print a run-time error message -- it usually occurs 
   when a relation references an unknown generator */

void report_error (a, b, c)
int a, b, c;
{
   printf ("The program has a run-time error. Please ");
   printf ("check that all generators\nused in the relations ");
   printf ("are declared in the generator list.\n");
   exit (INPUT_ERROR);
}
