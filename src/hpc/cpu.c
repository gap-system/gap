/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "hpc/cpu.h"

#ifdef _POSIX_C_SOURCE
#include <sys/unistd.h>
#elif _WIN32_WINNT >= _WIN32_WINNT_WIN7
#include <windows.h>
#endif

static const UInt FALLBACK_CPUS_NUMBER = 4;

/****************************************************************************
**
*V  SyNumProcessors  . . . . . . . . . . . . . . . . . number of logical CPUs
**
*/
UInt SyNumProcessors = FALLBACK_CPUS_NUMBER;

/****************************************************************************
**
*F  SyCountProcessors() . . . . . . . . . . . . . . compute the number of CPUs
**
**  SyCountProcessors() retrieves the number of active logical processors.
*/
UInt SyCountProcessors(void)
{
#if _POSIX_C_SOURCE
    const int result = sysconf(_SC_NPROCESSORS_ONLN);
    if (result < 1) {
        return FALLBACK_CPUS_NUMBER;
    }
    return result;
#elif _WIN32_WINNT >= _WIN32_WINNT_WIN7
    return GetActiveProcessorCount(ALL_PROCESSOR_GROUPS);
#else
    return FALLBACK_CPUS_NUMBER;
#endif
}
