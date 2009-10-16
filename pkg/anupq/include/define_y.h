/****************************************************************************
**
*A  define_y.h                  ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: define_y.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* definition of the y array;
   place this as the first line of the routine, before other declarations */

#ifdef Magma
register int *y = mem_access(pcp->y_handle);
#else
register int *y = y_address;
#endif
