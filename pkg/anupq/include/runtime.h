/****************************************************************************
**
*A  runtime.h                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: runtime.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (RUN_TIME)

/* largest number of defining generators = 2^GSC1 - 1 */
unsigned long GSC1 = 9;
unsigned long MAXGENS = 511;

/* largest number of pc generators = 2^GSC2 - 1 */
unsigned long GSC2 = 16;
unsigned long MAXPC = 65535;

/* largest class */
unsigned long MAXCLASS = 63;

#endif

