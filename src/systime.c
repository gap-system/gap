/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
*/

#include "systime.h"

#include "system.h"

#include <sys/time.h>
#include <sys/types.h>

#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#endif

#ifdef SYS_IS_DARWIN
#include <mach/mach_time.h>
#endif


/****************************************************************************
**
*F  SyTime()  . . . . . . . . . . . . . . . return time spent in milliseconds
**
**  'SyTime' returns the number of milliseconds spent by GAP so far.
**
**  Should be as accurate as possible,  because it  is  used  for  profiling.
*/
UInt SyTime(void)
{
    struct rusage buf;

    if (getrusage(RUSAGE_SELF, &buf)) {
        Panic("'SyTime' could not get time");
    }
    return buf.ru_utime.tv_sec * 1000 + buf.ru_utime.tv_usec / 1000;
}

UInt SyTimeSys(void)
{
    struct rusage buf;

    if (getrusage(RUSAGE_SELF, &buf)) {
        Panic("'SyTimeSys' could not get time");
    }
    return buf.ru_stime.tv_sec * 1000 + buf.ru_stime.tv_usec / 1000;
}

UInt SyTimeChildren(void)
{
    struct rusage buf;

    if (getrusage(RUSAGE_CHILDREN, &buf)) {
        Panic("'SyTimeChildren' could not get time");
    }
    return buf.ru_utime.tv_sec * 1000 + buf.ru_utime.tv_usec / 1000;
}

UInt SyTimeChildrenSys(void)
{
    struct rusage buf;

    if (getrusage(RUSAGE_CHILDREN, &buf)) {
        Panic("'SyTimeChildrenSys' could not get time");
    }
    return buf.ru_stime.tv_sec * 1000 + buf.ru_stime.tv_usec / 1000;
}


/****************************************************************************
**
*F  SyNanosecondsSinceEpoch()
**
**  'SyNanosecondsSinceEpoch' returns a 64-bit integer which represents the
**  number of nanoseconds since some unspecified starting point. This means
**  that the number returned by this function is not in itself meaningful,
**  but the difference between the values returned by two consecutive calls
**  can be used to measure wallclock time.
**
**  The accuracy of this is system dependent. For systems that implement
**  clock_getres, we could get the promised accuracy.
**
**  Note that gettimeofday has been marked obsolete in the POSIX standard.
**  We are using it because it is implemented in most systems still.
**
**  If we are using gettimeofday we cannot guarantee the values that
**  are returned by SyNanosecondsSinceEpoch to be monotonic.
**
**  Returns -1 to represent failure
**
*/
Int8 SyNanosecondsSinceEpoch(void)
{
    Int8 res;

#if defined(SYS_IS_DARWIN)
    static mach_timebase_info_data_t timeinfo;
    if (timeinfo.denom == 0) {
        (void)mach_timebase_info(&timeinfo);
    }
    res = mach_absolute_time();

    res *= timeinfo.numer;
    res /= timeinfo.denom;
#elif defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
    struct timespec ts;

    if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0) {
        res = ts.tv_sec;
        res *= 1000000000L;
        res += ts.tv_nsec;
    }
    else {
        res = -1;
    }
#elif defined(HAVE_GETTIMEOFDAY)
    struct timeval tv;

    if (gettimeofday(&tv, NULL) == 0) {
        res = tv.tv_sec;
        res *= 1000000L;
        res += tv.tv_usec;
        res *= 1000;
    }
    else {
        res = -1;
    };
#else
    res = -1;
#endif

    return res;
}


/****************************************************************************
**
*V  SyNanosecondsSinceEpochMethod
*V  SyNanosecondsSinceEpochMonotonic
**
**  These constants give information about the method used to obtain
**  NanosecondsSinceEpoch, and whether the values returned are guaranteed
**  to be monotonic.
*/
#if defined(SYS_IS_DARWIN)
const char * const SyNanosecondsSinceEpochMethod = "mach_absolute_time";
const Int          SyNanosecondsSinceEpochMonotonic = 1;
#elif defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
const char * const SyNanosecondsSinceEpochMethod = "clock_gettime";
const Int SyNanosecondsSinceEpochMonotonic = 1;
#elif defined(HAVE_GETTIMEOFDAY)
const char * const SyNanosecondsSinceEpochMethod = "gettimeofday";
const Int SyNanosecondsSinceEpochMonotonic = 0;
#else
const char * const SyNanosecondsSinceEpochMethod = "unsupported";
const Int SyNanosecondsSinceEpochMonotonic = 0;
#endif


/****************************************************************************
**
*F  SyNanosecondsSinceEpochResolution()
**
**  'SyNanosecondsSinceEpochResolution' returns a 64-bit integer which
**  represents the resolution in nanoseconds of the timer used for
**  SyNanosecondsSinceEpoch.
**
**  If the return value is positive then the value has been returned
**  by the operating system can probably be relied on. If the
**  return value is negative it is just an estimate (as in the case
**  of gettimeofday we have no way to get the exact resolution so we
**  just pretend that the resolution is 1000 nanoseconds).
**
**  A result of 0 signifies inability to obtain any sensible value.
*/
Int8 SyNanosecondsSinceEpochResolution(void)
{
    Int8 res;

#if defined(SYS_IS_DARWIN)
    static mach_timebase_info_data_t timeinfo;
    if (timeinfo.denom == 0) {
        (void)mach_timebase_info(&timeinfo);
    }
    res = timeinfo.numer;
    res /= timeinfo.denom;
#elif defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
    struct timespec ts;

    if (clock_getres(CLOCK_MONOTONIC, &ts) == 0) {
        res = ts.tv_sec;
        res *= 1000000000L;
        res += ts.tv_nsec;
    }
    else {
        res = 0;
    }
#elif defined(HAVE_GETTIMEOFDAY)
    res = -1000;
#else
    res = 0;
#endif

    return res;
}
