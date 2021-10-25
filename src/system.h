/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  The  file 'system.c'  declares  all operating system  dependent functions
**  except file/stream handling which is done in "sysfiles.h".
*/

#ifndef GAP_SYSTEM_H
#define GAP_SYSTEM_H

#include "common.h"


/****************************************************************************
**
*S  GAP_PATH_MAX . . . . . . . . . . . .  size for buffers storing file paths
**
**  'GAP_PATH_MAX' is the default buffer size GAP uses internally to store
**  most paths. If any longer paths are encountered, they will be either
**  truncated, or GAP aborts.
**
**  Note that no fixed buffer size is sufficient to store arbitrary paths
**  on contemporary operating systems, as paths can have arbitrary length.
**  This also means that the POSIX constant PATH_MAX does not really do the
**  job its name would suggest (nor do MAXPATHLEN, MAX_PATH etc.).
**
**  Writing POSIX compliant code without a hard coded buffer size is rather
**  challenging, as often there is no way to find out in advance how large a
**  buffer may need to be. So you have to start with some buffer size, then
**  check for errors; if 'errno' equals 'ERANGE', double the buffer size and
**  repeat, until you succeed or run out of memory.
**
**  Instead of going down this road, we use a fixed buffer size after all.
**  This way, at least our code stays simple. Also, this is what most (?)
**  code out there does, too, so if somebody actually uses such long paths,
**  at least GAP won't be the only program to run into problems.
*/
enum {
#if defined(PATH_MAX) && PATH_MAX > 4096
    GAP_PATH_MAX = PATH_MAX,
#else
    GAP_PATH_MAX = 4096,
#endif
};


/****************************************************************************
**
*T  Wrappers for various compiler attributes
**
*/

// recent clang and gcc versions have __has_attribute; for compilers that lack
// it, we have to rely on the autoconf test results.
#ifdef __has_attribute

#if __has_attribute(always_inline)
#define HAVE_FUNC_ATTRIBUTE_ALWAYS_INLINE 1
#endif

#if __has_attribute(noreturn)
#define HAVE_FUNC_ATTRIBUTE_NORETURN 1
#endif

#if __has_attribute(noinline)
#define HAVE_FUNC_ATTRIBUTE_NOINLINE 1
#endif

#if __has_attribute(format)
#define HAVE_FUNC_ATTRIBUTE_FORMAT 1
#endif

#endif

#if defined(HAVE_FUNC_ATTRIBUTE_ALWAYS_INLINE) && !defined(GAP_KERNEL_DEBUG)
#define ALWAYS_INLINE __attribute__((always_inline)) inline
#else
#define ALWAYS_INLINE inline
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_NORETURN
#define NORETURN __attribute__((noreturn))
#else
#define NORETURN
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_NOINLINE
#define NOINLINE __attribute__((noinline))
#else
#define NOINLINE
#endif


/****************************************************************************
**
*F  SyExit( <ret> ) . . . . . . . . . . . . . exit GAP with return code <ret>
**
**  'SyExit' is the offical  way  to  exit GAP, bus errors are the inoffical.
**  The function 'SyExit' must perform all the necessary cleanup operations.
**  If ret is 0 'SyExit' should signal to a calling proccess that all is  ok.
**  If ret is 1 'SyExit' should signal a  failure  to  the  calling proccess.
*/
void SyExit(UInt ret) NORETURN;


/****************************************************************************
**
*F  Panic( <msg> )
*/
void Panic_(const char * file, int line, const char * fmt, ...) NORETURN
#ifdef HAVE_FUNC_ATTRIBUTE_FORMAT
    __attribute__((format(printf, 3, 4)))
#endif
    ;
#define Panic(...) \
    Panic_(__FILE__, __LINE__, __VA_ARGS__)


/****************************************************************************
**
*F  InitSystem( <argc>, <argv>, <handleSignals> ) . initialize system package
**
**  'InitSystem' is called very early during the initialization from  'main'.
**  It is passed the command line array  <argc>, <argv>  to look for options.
**
**  For UNIX it initializes the default files 'stdin', 'stdout' and 'stderr',
**  and if handleSignals is non-zero installs the handler 'syAnswerIntr' to
**  answer the user interrupts '<ctr>-C', scans the command line for options,
**  sets up the GAP root paths, locates the '.gaprc' file (if any), and more.
*/
void InitSystem(Int argc, Char * argv[], UInt handleSignals);

#endif // GAP_SYSTEM_H
