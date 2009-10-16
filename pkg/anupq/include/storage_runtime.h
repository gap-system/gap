/****************************************************************************
**
*A  storage_runtime.h           ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: storage_runtime.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* largest number of defining generators = 2^GSC1 - 1 */ 
extern unsigned long GSC1; 
extern unsigned long MAXGENS; 

/* largest number of pc generators = 2^GSC2 - 1 */ 
extern unsigned long GSC2;
extern unsigned long MAXPC;

/* largest class */
extern unsigned long MAXCLASS;

#define INSWT(i) ((i) << SC3)
#define WT(i) ((i) >> SC3)

#define PACK2(i, j) (((i)<<SC2) + (j))
#define FIELD1(i) ((i) >> SC2)
#define FIELD2(i) ((i) & MASK2)

#define PACK3(i, j, k) (((((i) << SC2) + (j)) << SC1) + (k))
#define PART2(i) (((i) >> SC1) & MASK2)
#define PART3(i) ((i) & MASK1)

