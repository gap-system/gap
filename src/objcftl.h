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
#define PC_DEFAULT_TYPE             15

/* the following are defined in polycyclic:

#define PC_PCP_ELEMENTS_FAMILY          16
#define PC_PCP_ELEMENTS_TYPE            17

#define PC_COMMUTATORS                  18
#define PC_INVERSECOMMUTATORS           19
#define PC_COMMUTATORSINVERSE           20
#define PC_INVERSECOMMUTATORSINVERSE    21

#define PC_NILPOTENT_COMMUTE            22
#define PC_WEIGHTS                      23
#define PC_ABELIAN_START                24
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
