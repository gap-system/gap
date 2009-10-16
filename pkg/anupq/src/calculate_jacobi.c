/****************************************************************************
**
*A  calculate_jacobi.c          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: calculate_jacobi.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"

/* calculate an individual jacobi */

#ifdef Magma
void calculate_jacobi (c, b, a, pcp)
int c;
int b;
int a;
struct pcp_vars *pcp;
#else
void calculate_jacobi (pcp)
struct pcp_vars *pcp;
#endif
{
#include "define_y.h"

   Logical invalid = FALSE;
   int bound = pcp->ccbeg;
   int output;
#ifndef Magma
   int a, b, c; 
#endif

#include "access.h"

#ifndef Magma
   printf ("Input the three components for the consistency calculation: ");
   read_value (FALSE, "", &c, 1);
   read_value (FALSE, "", &b, 1);
   read_value (TRUE,  "", &a, 1);
#endif

   /* check the validity of the components */
   invalid = outside (a, bound) || outside (b, bound) || outside (c, bound)
      || pcp->cc <= 2 || c < b || b < a 
      || (a != b && b != c && WT(y[pcp->structure + c]) +
	  WT(y[pcp->structure + b]) + WT(y[pcp->structure + a]) > pcp->cc) 
      || ((a == b || b == c) && 
	  WT(y[pcp->structure + a]) + WT(y[pcp->structure + c]) + 1 > pcp->cc);

   /* if valid, calculate the jacobi */
   if (!invalid) { 
      output = pcp->fullop;
      pcp->fullop = TRUE;
      jacobi (c, b, a, 0, pcp);
      pcp->fullop = output;
   }
   else {
      PRINT ("Incorrect values %d, %d, %d for Jacobi calculation\n", c, b, a);
      pcp->redgen = 0;
   }
}

/* check if x lies outside permitted range from 1 to y */
int outside (x, y)
int x;
int y;
{
   return (x <= 0) || (x > y);
}
