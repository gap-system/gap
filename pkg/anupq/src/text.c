/****************************************************************************
**
*A  text.c                      ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: text.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"

/* print an informational or error message */

void text (message, arg1, arg2, arg3, arg4)
int message;
int arg1;
int arg2;
int arg3;
int arg4;
{
   char *s, *t;

   switch (message) {
   case 1:
      PRINT ("Defining relation was %d\n", arg1);
      return;
   case 2:
      PRINT ("Compact workspace: Lused = %d, Structure = %d\n", arg1, arg2);
      return;
   case 3:
      PRINT ("Generator %d is trivial\n", arg1);
      return;
   case 4:
      PRINT ("Generator %d is redundant\n", arg1);
      return;
   case 5:
#if defined (GROUP) 
      PRINT ("\nGroup completed.");
#endif
#if defined (LIE)
      PRINT ("\nLie ring completed.");
#endif
      PRINT (" Lower exponent-%d central class = %d,", arg2, arg1);
      PRINT (" Order = %d^%d\n", arg2, arg3);
      return;
   case 6:
      PRINT ("Relation not homogeneous of class %d.", arg1);
      PRINT (" Relation ignored.\n");
      return;
   case 7:
      PRINT ("%d-quotient is trivial\n", arg1);
      return;
   case 8:
      PRINT ("%d-quotient is cyclic\n", arg1);
      return;
   case 9:
      PRINT ("Jacobi was ");
      PRINT ("%d %d %d\n", arg1, arg2, arg3);
      return;
   case 10:
      PRINT ("Invalid Last Class call - option may be used only once\n");
      return;
   case 11:
      PRINT ("Ran out of space during computation\n");
      PRINT ("Number of generators in last class is %d\n", arg1); 
      return;
   case 12:
      PRINT ("\nRank of %d-multiplicator is %d\n", arg1, arg2);
      return;
   case 13:
      PRINT ("%d ", arg1);
      s = (arg1 == 1) ? "" : "s";  
      t = (arg3 == TRUE) ? "collected" : "will be collected";
      PRINT ("relation%s of class %d %s\n", s, arg2, t);
      return;
   case 14:
      PRINT ("Inappropriate value for exponent parameter: %d\n", arg1);
      return;
   case 15:
      PRINT ("Class bound of %d taken\n", arg1);
      return;
   case 16:
      PRINT ("Validity error. Results may be incorrect\n");
      return;
   case 17:
      PRINT ("The number of defining generators must be less than %d\n", arg1);
      return;
   case 18: 
      PRINT ("A relation is too long -- increase the value of MAXWORD ");
      PRINT ("in constants.h\nand recompile pq\n");
      return;
   case 19:
      PRINT ("Evaluation in compute_degree may cause integer overflow\n");
      return;
   default: 
      PRINT ("Bad message number %d", message);
   }
}
