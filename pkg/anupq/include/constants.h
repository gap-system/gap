/****************************************************************************
**
*A  constants.h                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: constants.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* constants used in p-quotient program */

#ifndef __PQ_CONSTANTS__
#define __PQ_CONSTANTS__

#define PQSPACE 10000000       /* space allocated for computation in array y */
#define MAXWORD 10000          /* maximum length of word */

#define STACK_SIZE 50000       /* dimension of collection stack */
#define DEFAULT_CLASS 10       /* default class bound for computation */
#define LINK_SOLUBLE_FLAG -1   /* flag in Magma or GAP output file indicating
                                  soluble stabiliser */
#define ALL 999                /* step size flag to indicate that all
				  descendants should be constructed */

#define PQ 1                   /* two algorithms */
#define PGA 2

#define MIN_PRINT 0            /* print flags */
#define DEFAULT_PRINT 1
#define INTERMEDIATE_PRINT 2
#define MAX_PRINT 3

#define MAX_STANDARD_PRINT 2   /* print flags for standard presentation */
#define DEFAULT_STANDARD_PRINT 1
#define MIN_STANDARD_PRINT 0

#define BASIC 1                /* input formats for presentation and words */
#define PRETTY 2
#define FILE_INPUT 3

#define SUCCESS 0              /* successful computation */
#define FAILURE 1              /* computation failed -- lack of resources*/
#define CPU_TIME_LIMIT 1       /* exit when time limit exceeded */
#define INPUT_ERROR 2          /* input or command line options are wrong */

#endif 
