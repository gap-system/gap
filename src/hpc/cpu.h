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
*F  SyCountProcessors() . . . . . . . . . . . . compute the number of CPUs.
**
**  SyCountProcessors() retrieves the number of active logical processors.
**  In case of Linux, calls get_nprocs().
**  In case of Windows 7 and higher, calls
**  GetActiveProcessorCount(ALL_PROCESSOR_GROUPS).
**  In case of older versions of Windows, tries to load the number of
**  processors in current processor group via GetSystemInfo with proper
**  arguments and falls back to the value of 4 in case of an error.
**  In case of macOS sysctl is called with HW_AVAILCPU flag.
**  In case of other operating systems the value of 4 is returned.
*/

UInt SyCountProcessors(void);

#endif    // GAP_HPC_CPU_H
