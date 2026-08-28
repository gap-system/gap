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

#include "gaptime.h"

#include "bool.h"
#include "error.h"
#include "integer.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "precord.h"
#include "records.h"
#include "stats.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "system.h"

#include "config.h"

#include <errno.h>
#include <stddef.h>
#include <sys/types.h>
#include <unistd.h>

#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#endif

#ifdef SYS_IS_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <windows.h>    // for Sleep
#endif

#if defined(__APPLE__) && defined(__MACH__) // macOS
#include <mach/mach_time.h>
#elif defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
#include <time.h>
#elif defined(HAVE_GETTIMEOFDAY)
#include <sys/time.h>
#endif

// Pick the source for the wall clock, see FuncCurrentSecondsSinceEpoch.
// POSIX fixes the epoch of the first two to 1970-01-01 00:00:00 UTC; the
// fallback needs converting, so it is named separately.
#if defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_REALTIME)
#define GAP_WALLCLOCK_CLOCK_GETTIME
#elif defined(HAVE_GETTIMEOFDAY)
#define GAP_WALLCLOCK_GETTIMEOFDAY
#else
#define GAP_WALLCLOCK_TIME
#endif

// 'time' is in C89 and thus always available, unlike the monotonic timer,
// which needs whatever the platform happens to offer.
#include <time.h>
#ifdef GAP_WALLCLOCK_GETTIMEOFDAY
#include <sys/time.h>
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
#ifdef EMSCRIPTEN
    // Emscripten's standard library always returns the same values
    // for getrusage, which makes some GAP functions enter an
    // infinite loop, as they use this function to try running
    // for some period of time. Use NanosecondsSinceEpoch() as
    // a substitute (it is not perfect, as NanosecondsSinceEpoch()
    // is walltime, while RUSAGE_SELF is CPU time).
    return SyNanosecondsSinceEpoch()/1000000000;
#elif !defined(HAVE_GETRUSAGE)
    // no getrusage: substitute wallclock milliseconds for CPU time
    // TODO(windows-port): use GetProcessTimes
    return SyNanosecondsSinceEpoch()/1000000;
#else
    struct rusage buf;

    if (getrusage(RUSAGE_SELF, &buf)) {
        ErrorMayQuit("SyTime: could not get time: "
                     "%s (errno %d)",
                     (Int)strerror(errno), (Int)errno);
    }
    return buf.ru_utime.tv_sec * 1000 + buf.ru_utime.tv_usec / 1000;
#endif
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

#if defined(__APPLE__) && defined(__MACH__) // macOS
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
static Int8 SyNanosecondsSinceEpochResolution(void)
{
    Int8 res;

#if defined(__APPLE__) && defined(__MACH__)
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


/****************************************************************************
**
*F  FuncRuntime( <self> ) . . . . . . . . . . . . internal function 'Runtime'
**
**  'FuncRuntime' implements the internal function 'Runtime'.
**
**  'Runtime()'
**
**  'Runtime' returns the time spent since the start of GAP in  milliseconds.
**  How much time execution of statements take is of course system dependent.
**  The accuracy of this number is also system dependent.
*/
static Obj FuncRuntime(Obj self)
{
    return ObjInt_UInt(SyTime());
}


static Obj FuncRUNTIMES(Obj self)
{
#ifndef HAVE_GETRUSAGE
    // TODO(windows-port): use GetProcessTimes
    return Fail;
#else
    UInt          tmp;
    struct rusage buf;
    Obj           res = NEW_PLIST(T_PLIST, 4);

    if (getrusage(RUSAGE_SELF, &buf)) {
        ErrorMayQuit("RUNTIMES: call to getrusage(RUSAGE_SELF) failed: "
                     "%s (errno %d)",
                     (Int)strerror(errno), (Int)errno);
    }
    tmp = buf.ru_utime.tv_sec * 1000 + buf.ru_utime.tv_usec / 1000;
    ASS_LIST(res, 1, ObjInt_UInt(tmp));

    tmp = buf.ru_stime.tv_sec * 1000 + buf.ru_stime.tv_usec / 1000;
    ASS_LIST(res, 2, ObjInt_UInt(tmp));

    if (getrusage(RUSAGE_CHILDREN, &buf)) {
        ErrorMayQuit("RUNTIMES: call to getrusage(RUSAGE_CHILDREN) failed: "
                     "%s (errno %d)",
                     (Int)strerror(errno), (Int)errno);
    }
    tmp = buf.ru_utime.tv_sec * 1000 + buf.ru_utime.tv_usec / 1000;
    ASS_LIST(res, 3, ObjInt_UInt(tmp));

    tmp = buf.ru_stime.tv_sec * 1000 + buf.ru_stime.tv_usec / 1000;
    ASS_LIST(res, 4, ObjInt_UInt(tmp));

    return res;
#endif
}


/****************************************************************************
**
*F  FuncNanosecondsSinceEpoch( <self> )
**
**  'FuncNanosecondsSinceEpoch' returns an integer which represents the
**  number of nanoseconds since some unspecified starting point. This
**  function wraps SyNanosecondsSinceEpoch.
*/
static Obj FuncNanosecondsSinceEpoch(Obj self)
{
    Int8 val = SyNanosecondsSinceEpoch();
    return val >= 0 ? ObjInt_Int8(val) : Fail;
}


#ifdef GAP_WALLCLOCK_TIME

/****************************************************************************
**
*F  SyUnixEpochSecondsFromTimeT( <t> )
**
**  Convert a 'time_t' to the number of seconds since 1970-01-01 00:00:00 UTC.
**
**  ISO C leaves the epoch of 'time_t' implementation defined, so a value from
**  'time' cannot simply be returned as is.  Breaking it down with 'gmtime'
**  and counting from the fields is independent of whatever epoch the system
**  uses.  Returns -1 if the conversion fails.
**
**  Only correct for dates from 1970 onwards, which is all we need: the input
**  is the current time.
*/
static Int8 SyUnixEpochSecondsFromTimeT(time_t t)
{
    struct tm * bd;
    Int8        year, days, leaps;

    bd = gmtime(&t);
    if (bd == NULL)
        return -1;

    year = (Int8)bd->tm_year + 1900;
    if (year < 1970)
        return -1;

    // leap days completed between 1970-01-01 and 1 January of <year>
    leaps = (year - 1) / 4 - (year - 1) / 100 + (year - 1) / 400 -
            (1969 / 4 - 1969 / 100 + 1969 / 400);
    days = (year - 1970) * 365 + leaps + bd->tm_yday;

    return ((days * 24 + bd->tm_hour) * 60 + bd->tm_min) * 60 + bd->tm_sec;
}

#endif    // GAP_WALLCLOCK_TIME


/****************************************************************************
**
*F  FuncCurrentSecondsSinceEpoch( <self> )
**
**  'FuncCurrentSecondsSinceEpoch' returns the number of seconds that have
**  passed since 1970-01-01 00:00:00 UTC, ignoring leap seconds, or 'fail' if
**  the system clock cannot be read.  That epoch is guaranteed, whatever the
**  system happens to count from.
**
**  Note that this is a different quantity from the one returned by
**  'SyNanosecondsSinceEpoch', which counts from an unspecified point and is
**  monotonic where possible.  That makes it right for measuring durations
**  and useless for recording when something happened, which is what this is
**  for.
*/
static Obj FuncCurrentSecondsSinceEpoch(Obj self)
{
    Int8 secs;

    // POSIX pins both of these to 1970-01-01 00:00:00 UTC, so their seconds
    // field is already the value we promise.
#if defined(GAP_WALLCLOCK_CLOCK_GETTIME)
    struct timespec ts;

    if (clock_gettime(CLOCK_REALTIME, &ts) != 0)
        return Fail;
    secs = (Int8)ts.tv_sec;
#elif defined(GAP_WALLCLOCK_GETTIMEOFDAY)
    struct timeval tv;

    if (gettimeofday(&tv, NULL) != 0)
        return Fail;
    secs = (Int8)tv.tv_sec;
#else
    time_t t = time(NULL);

    if (t == (time_t)-1)
        return Fail;
    secs = SyUnixEpochSecondsFromTimeT(t);
    if (secs < 0)
        return Fail;
#endif

    return ObjInt_Int8(secs);
}


/****************************************************************************
**
*F  FuncNanosecondsSinceEpochInfo( <self> )
**
**  'FuncNanosecondsSinceEpochInformation' returns a plain record which
**  contains information about the timers used for FuncNanosecondsSinceEpoch.
**
*/
static Obj FuncNanosecondsSinceEpochInfo(Obj self)
{
    Obj          res, tmp;
    Int8         resolution;
    const char * method = "unsupported";
    BOOL         monotonic = FALSE;

#if defined(__APPLE__) && defined(__MACH__)
    method = "mach_absolute_time";
    monotonic = TRUE;
#elif defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
    method = "clock_gettime";
    monotonic = TRUE;
#elif defined(HAVE_GETTIMEOFDAY)
    method = "gettimeofday";
    monotonic = FALSE;
#endif

    res = NEW_PREC(4);
    // Note this has to be "DYN" since we're not passing a
    // literal but a const char *
    tmp = MakeImmString(method);
    AssPRec(res, RNamName("Method"), tmp);
    AssPRec(res, RNamName("Monotonic"), monotonic ? True : False);
    resolution = SyNanosecondsSinceEpochResolution();
    if (resolution > 0) {
        AssPRec(res, RNamName("Resolution"), ObjInt_Int8(resolution));
        AssPRec(res, RNamName("Reliable"), True);
    }
    else if (resolution <= 0) {
        AssPRec(res, RNamName("Resolution"), ObjInt_Int8(-resolution));
        AssPRec(res, RNamName("Reliable"), False);
    }
    return res;
}


/****************************************************************************
**
*F  FuncSleep( <self>, <secs> )
**
*/
static Obj FuncSleep(Obj self, Obj secs)
{
    Int s = GetSmallInt(SELF_NAME, secs);

    if (s > 0)
#ifdef SYS_IS_WINDOWS
        Sleep((DWORD)s * 1000);
#else
        sleep((UInt)s);
#endif

    // either we used up the time, or we were interrupted.
    if (HaveInterrupt()) {
        ClearError(); // The interrupt may still be pending
        ErrorReturnVoid("user interrupt in sleep", 0, 0,
                        "you can enter 'return;' as if the sleep was finished");
    }

    return 0;
}


/****************************************************************************
**
*F  FuncMicroSleep( <self>, <secs> )
**
*/
static Obj FuncMicroSleep(Obj self, Obj msecs)
{
    Int s = GetSmallInt(SELF_NAME, msecs);

    if (s > 0)
#ifdef SYS_IS_WINDOWS
        Sleep((DWORD)(s / 1000));
#else
        usleep((UInt)s);
#endif

    // either we used up the time, or we were interrupted.
    if (HaveInterrupt()) {
        ClearError(); // The interrupt may still be pending
        ErrorReturnVoid(
            "user interrupt in microsleep", 0, 0,
            "you can enter 'return;' as if the microsleep was finished");
    }

    return 0;
}


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_0ARGS(Runtime),
    GVAR_FUNC_0ARGS(RUNTIMES),
    GVAR_FUNC_0ARGS(NanosecondsSinceEpoch),
    GVAR_FUNC_0ARGS(NanosecondsSinceEpochInfo),
    GVAR_FUNC_0ARGS(CurrentSecondsSinceEpoch),

    GVAR_FUNC_1ARGS(Sleep, secs),
    GVAR_FUNC_1ARGS(MicroSleep, msecs),

    { 0, 0, 0, 0, 0 }

};

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    // init filters and functions
    InitHdlrFuncsFromTable(GVarFuncs);

    return 0;
}
/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    // init filters and functions
    InitGVarFuncsFromTable(GVarFuncs);

    return 0;
}


/****************************************************************************
**
*F  InitInfoTime() . . . . . . . . . . . . . . . . .  table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "time",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoTime(void)
{
    return &module;
}
