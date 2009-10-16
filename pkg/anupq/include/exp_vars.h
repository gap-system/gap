/****************************************************************************
**
*A  exp_vars.h                  ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: exp_vars.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* definition file for structure to store exponent flag information */

#ifndef __EXP_VARS__
#define __EXP_VARS__

struct exp_vars {
   int list;          /* which list to generate? */
   Logical complete;  /* print list generated before filters applied */
   int partitions;    /* list weight partitions */
   Logical process;   /* power word and echelonise result */
   int start_process; /* index of first word to power */
   Logical filter;    /* reason to filter word from list */
   int report_unit;   /* report after this many additional words collected */
   int *queue;        /* queue to store redundancies obtained from echelon */
   int queue_length;  /* number of redundancies obtained */
   Logical word_list; /* save list of test words to file */
   Logical check_exponent; /* check whether group has particular exponent */
   Logical all_trivial; /* all test words are trivial */
};

#define ALL_WORDS 1
#define REDUCED_LIST 2
#define INITIAL_SEGMENT 3

#endif
