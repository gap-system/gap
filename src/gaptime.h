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

#ifndef GAP_GAPTIME_H
#define GAP_GAPTIME_H

#include "common.h"


/****************************************************************************
**
*F  SyTime()  . . . . . . . . . . . . . . . return time spent in milliseconds
**
**  'SyTime' returns the number of milliseconds spent by GAP so far.
**
**  Should be as accurate as possible,  because it  is  used  for  profiling.
*/
UInt SyTime(void);


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
**  Returns -1 to represent failure.
*/
Int8 SyNanosecondsSinceEpoch(void);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoTime() . . . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoTime(void);

#endif    // GAP_GAPTIME_H
