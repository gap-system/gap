/****************************************************************************
**
*A  access.h                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: access.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (RUN_TIME) 
   /* variables which determine access functions for words stored in y */
   unsigned long SC1, SC2, SC3, MASK1, MASK2;
   SC1 = GSC1;  SC2 = GSC2;  SC3 = SC1 + SC2;
   MASK1 = (1L << SC1) - 1; MASK2 = (1L << SC2) - 1;
#endif

