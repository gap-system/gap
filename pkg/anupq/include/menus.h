/****************************************************************************
**
*A  menus.h                     ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: menus.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* list all of the menu options */

#ifndef __PQ_MENUS__
#define __PQ_MENUS__

#define EXIT 0 
#define LEAST_OPTION -1            /* least option */

#if defined (GROUP)

/* constants for options menu */
#define COMPUTE_PCP 1
#define SAVE_PCP 2
#define RESTORE_PCP 3
#define DISPLAY_PRESENTATION 4
#define PRINT_LEVEL 5
#define NEXT_CLASS 6
#define PCOVER 7
#define INTERACTIVE_PQ 8
#define PGP 9

/* constants for interactive menu */
#define COLLECT 1
#define SOLVE 2
#define COMMUTATOR 3
#define DISPLAY_PRESENTATION 4
#define PRINT_LEVEL 5
#define SETUP 6
#define TAILS 7
#define CONSISTENCY 8
#define RELATIONS 9
#define EXTRA_RELATIONS 10
#define ELIMINATE 11
#define LAST_CLASS 12
#define MAXOCCUR 13
#define METABELIAN 14
#define JACOBI 15
#define COMPACT 16
#define ECHELON 17
#define AUTS 18
#define CLOSE_RELATIONS 19
#define STRUCTURE 20
#define LIST_AUTOMORPHISMS 21
#define MAGMA_AUTOMORPHISMS 22
#define DGEN_WORD 23
#define DGEN_COMM 24
#define OUTPUT_PRESENTATION 25
#define COMPACT_PRESENTATION 26
#define FORMULA 27
#define DGEN_AUT 28
#define CAY_NEXT_CLASS 25
#define CAY_PCOVER 26
#define CAY_PRINT_LEVEL 27
#define ENGEL 29
#define RELATIONS_FILE 30

#endif 

#if defined (LIE)
#include "lie_menus.h"
#endif 

#define CAY_NOT_SET (-100)

/* constants for pgroup generation menu */
#define SUPPLY_AUTOMORPHISMS 1
#define EXTEND_AUTOMORPHISMS 2
#define RESTORE_GROUP 3
#define DISPLAY_GROUP 4
#define ITERATION 5
#define INTERACTIVE_PGA 6
#define STANDARD 7

/* constants for interactive pgroup generation menu */
#define SUPPLY_AUTS 1
#define EXTEND_AUTS 2
#define RESTORE_GP 3
#define DISPLAY_GP 4
#define SINGLE_STAGE 5
#define DEGREE 6
#define PERMUTATIONS 7 
#define ORBITS 8
#define STABILISERS 9
#define STABILISER 10
#define MATRIX_TO_LABEL 11
#define LABEL_TO_MATRIX 12
#define IMAGE 13
#define SUBGROUP_RANK 14
#define ORBIT_REP 15
#define COMPACT_DESCRIPTION 16
#define AUT_CLASSES 17 
#define TEMP 19

/* constants for quotpic menu */
#define PQ_OPTIONS 1
#define MATRIX 2
#define MEATAXE 3

/* constants for standard presentation menu */
#define START_INFO 1
#define CONSTRUCT 2
#define SAVE_PRES 3
#define PRINT_PCP 4
#define STANDARD_PRINT_LEVEL 5
#define COMPARE 6
#define PQ_MENU 7

#define DEFAULT_MENU 0
#define QUOTPIC_MENU 1
#define ISOM_MENU 2

#endif 
