/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_HPC_CPU_H
#define GAP_HPC_CPU_H

#include "common.h"

#ifndef HPCGAP
#error This header is only meant to be used with HPC-GAP
#endif

/****************************************************************************
**
*V  SyNumProcessors  . . . . . . . . . . . . . . . . . number of logical CPUs
**
*/
extern UInt SyNumProcessors;

/****************************************************************************
**
*F  SyCountProcessors() . . . . . . . . . . . . . . compute the number of CPUs
**
**  SyCountProcessors() retrieves the number of active logical processors.
*/
UInt SyCountProcessors(void);

#endif    // GAP_HPC_CPU_H
