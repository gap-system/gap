/****************************************************************************
**
*A  storage_fixed.h             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: storage_fixed.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* the default values of SC1 and SC2 may be altered 
   provided SC1 + SC2 + MAXCLASS = WORD_LENGTH */

/* largest number of defining generators = 2^SC1 - 1 */
#define SC1 9 
#define MAXGENS (1 << SC1) - 1 

/* largest number of pc generators = 2^SC2 - 1 */
#define SC2 16 
#define MAXPC (1 << SC2) - 1

#define SC3 (SC1 + SC2)

/* largest class = 2^(WORD_LENGTH - (SC1 + SC2)) - 1 */
#define MAXCLASS (1 << (WORD_LENGTH - SC3)) - 1

#define MASK1 (1UL << SC1) - 1
#define MASK2 (1UL << SC2) - 1

#define INSWT(i) ((i) << SC3)
#define WT(i) ((i) >> SC3)

#define PACK2(i, j) (((i)<<SC2) + (j))
#define FIELD1(i) ((i) >> SC2)
#define FIELD2(i) ((i) & MASK2)

#define PACK3(i, j, k) (((((i) << SC2) + (j)) << SC1) + (k))
#define PART2(i) (((i) >> SC1) & MASK2)
#define PART3(i) ((i) & MASK1)

