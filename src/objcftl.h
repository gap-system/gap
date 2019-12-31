/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the function collecting from the left with polycyclic
**  presentations.
*/

#ifndef GAP_OBJCFTL_H
#define GAP_OBJCFTL_H

#include "common.h"

#define PC_NUMBER_OF_GENERATORS      1
#define PC_GENERATORS                2
#define PC_INVERSES                  3
#define PC_COMMUTE                   4
#define PC_POWERS                    5
#define PC_INVERSEPOWERS             6
#define PC_EXPONENTS                 7
#define PC_CONJUGATES                8
#define PC_INVERSECONJUGATES         9
#define PC_CONJUGATESINVERSE        10
#define PC_INVERSECONJUGATESINVERSE 11
#define PC_DEEP_THOUGHT_POLS        12
#define PC_DEEP_THOUGHT_BOUND       13
#define PC_ORDERS                   14

// TODO: the following stack related positions are not
// used anymore by CollectPolycyc, and will not be used
// anymore in future releases of the polycyclic package.
// We should phase them out for GAP 4.10.
#define PC_WORD_STACK               15
#define PC_STACK_SIZE               16
#define PC_WORD_EXPONENT_STACK      17
#define PC_SYLLABLE_STACK           18
#define PC_EXPONENT_STACK           19
#define PC_STACK_POINTER            20
// TODO: end obsolete

#define PC_DEFAULT_TYPE             21

/* the following are defined in polycyclic:

#define PC_PCP_ELEMENTS_FAMILY          22
#define PC_PCP_ELEMENTS_TYPE            23

#define PC_COMMUTATORS                  24
#define PC_INVERSECOMMUTATORS           25
#define PC_COMMUTATORSINVERSE           26
#define PC_INVERSECOMMUTATORSINVERSE    27

#define PC_NILPOTENT_COMMUTE            28
#define PC_WEIGHTS                      29
#define PC_ABELIAN_START                30
*/

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoPcc() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPcc ( void );


#endif // GAP_OBJCFTL_H
