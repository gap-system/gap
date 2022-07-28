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

#ifndef NUM_CPUS
#ifdef _POSIX_C_SOURCE
#include <sys/unistd.h>
#elif _WIN32
#if _WIN32_WINNT >= _WIN32_WINNT_WIN7
#include <windows.h>
#else
#include <sysinfoapi.h>
#endif
#endif
#endif

/****************************************************************************
**
*V  SyNumProcessors  . . . . . . . . . . . . . . . . . number of logical CPUs
**
*/
#ifdef NUM_CPUS
UInt SyNumProcessors = NUM_CPUS;
#else
UInt SyNumProcessors = 4;
#endif

/****************************************************************************
**
*F  SyCountProcessors() . . . . . . . . . . . . . . compute the number of CPUs
**
**  SyCountProcessors() retrieves the number of active logical processors.
*/
UInt SyCountProcessors(void)
{
#ifdef NUM_CPUS
    return NUM_CPUS;
#else
    const UInt fallback_cpus_number = 4;
#if _POSIX_C_SOURCE
    const int  result = sysconf(_SC_NPROCESSORS_ONLN);
    if (result < 1) {
        return fallback_cpus_number;
    }
    return result;
#else
#if _WIN32
#if _WIN32_WINNT >= _WIN32_WINNT_WIN7
    return GetActiveProcessorCount(ALL_PROCESSOR_GROUPS);
#else
    SYSTEM_INFO info;
    GetSystemInfo(&info);
    if (info.dwNumberOfProcessors < 1) {
        return fallback_cpus_number;
    }
    return info.dwNumberOfProcessors;
#endif
#else
    return fallback_cpus_number;
#endif
#endif
#endif
}
