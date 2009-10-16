/****************************************************************************
**
*A  pq_defs.h                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pq_defs.h,v 1.4 2001/11/15 15:59:02 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* definition file for p-quotient program */

#ifndef __PQ_DEFINES__

#define __PQ_DEFINES__

/* various definitions required by Magma */

#ifdef Magma
#include "defs.h"  /* Magma type definitions */
#define PRINT io_printf
#define CRASH do { error_internal("Bad p-group generation file");} while(0)
#undef A
#undef DEBUG 
#undef WORD
#undef extend
#ifdef df
#undef df
#endif
#define Magma_FP       1
#define Magma_PC       2
#define Magma_FORMAT   3
#define Magma_INTERNAL 4 
#define PQ_MIN_SPACE    10000
#define PQ_MISC_SPACE   5000

#else

#define TRUE	1
#define FALSE	0
#define Logical	int
#define PRINT printf
#define CRASH do { exit(0); } while(0)
#endif

#include <stdio.h>
#include <math.h>
#include <ctype.h> 
#include <string.h>
#include <limits.h> 
#include <time.h> 

/* under Solaris, CLK_TCK is defined in <limits.h> */

#if !defined (CLK_TCK)
#define CLK_TCK 60
#endif

#define CLK_SCALE 1.0 / CLK_TCK

#if defined (LARGE_INT)
#include "gmp.h"
#endif

#define COMMENT '#'

#define FILE_TYPE FILE*
#define RESET(File) (rewind((File)))
#define CLOSE(File) (fclose((File)))

#define and(a, b)	((a) & (b))
#define or(a, b)	((a) | (b))
#define not(a)		(~(a))
#define rshift(a, n)	((a) >> (n))
#define lshift(a, n)	((a) << (n))
#define xor(a, b)	((a) ^ (b))

#ifndef two_to_the_n
#define two_to_the_n(n)  (1 << (n))
#endif

#define MOD(a, b) ((a) % (b))

#define WORD_LENGTH 8 * sizeof (int) - 1

/* fixed storage or decision made at run-time? */

#if (RUN_TIME) 
#include "storage_runtime.h"
#else 
#include "storage_fixed.h"
#endif 

#ifdef MIN
#undef MIN
#endif

#ifdef MAX
#undef MAX
#endif

#define MIN(A, B) ((A) < (B) ? (A) : (B))
#define MAX(A, B) ((A) > (B) ? (A) : (B))
#define SWAP(A, B) {int t; t = A; A = B; B = t;}

#endif
