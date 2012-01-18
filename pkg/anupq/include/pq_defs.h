/****************************************************************************
**
*A  pq_defs.h                   ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pq_defs.h,v 1.13 2011/11/29 13:59:26 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* definition file for p-quotient program */

#ifndef PQ_DEFINES
#define PQ_DEFINES

#include "config.h"

enum {
  FALSE = 0,
  TRUE = 1
};
typedef int Logical;

#define PRINT printf

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h> 
#include <string.h>
#include <limits.h> 
#include <time.h> 

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

/* under Solaris, CLK_TCK is defined in <limits.h> */

#if !defined (CLK_TCK)
#define CLK_TCK 60
#endif

#define CLK_SCALE 1.0 / CLK_TCK

#ifdef HAVE_GMP
#include "gmp.h"
#endif

#define COMMENT '#'

#define RESET(File) (rewind((File)))

#define MOD(a, b) ((a) % (b))

#define WORD_LENGTH (8 * sizeof (int) - 1)

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

#include "pq_functions.h"

#endif
