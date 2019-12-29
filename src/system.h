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

/****************************************************************************
**
*V  autoconf  . . . . . . . . . . . . . . . . . . . . . . . .  use "config.h"
*/
#include "config.h"

#include <assert.h>
#include <limits.h>
#include <setjmp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "debug.h"


/* check if we are on a 64 bit machine                                     */
#if SIZEOF_VOID_P == 8
# define SYS_IS_64_BIT          1
#elif !defined(SIZEOF_VOID_P)
# error Something is wrong with this GAP installation: SIZEOF_VOID_P not defined
#endif

// check that the pointer size detected by configure matches that of the
// current compiler; this helps prevent kernel extensions from being
// compiled with the wrong ABI
GAP_STATIC_ASSERT(sizeof(void *) == SIZEOF_VOID_P, "sizeof(void *) is wrong");


// EXPORT_INLINE is used for most inline functions declared in our header
// files; it is set to `inline` by default, except in debug.c, where it is set
// to `extern inline`, to ensure exactly one instance of the function is
// actually emitted.
//
// We make an exception for HPC-GAP, were we default to `static inline`
// instead, to avoid warnings in code using atomic_ops functions; this is OK,
// as we don't support a libgap version of HPC-GAP right now, and if we ever
// wanted to, a lot more work (and planning) would have to be invested into
// that anyway.
#ifndef EXPORT_INLINE
#ifdef HPCGAP
#define EXPORT_INLINE static inline
#else
#define EXPORT_INLINE inline
#endif
#endif

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
#if defined(HAVE_FUNC_ATTRIBUTE_ALWAYS_INLINE) && !defined(GAP_KERNEL_DEBUG)
#define ALWAYS_INLINE __attribute__((always_inline)) inline
#else
#define ALWAYS_INLINE inline
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_NOINLINE
#define NOINLINE __attribute__((noinline))
#else
#define NOINLINE
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_NORETURN
#define NORETURN __attribute__((noreturn))
#else
#define NORETURN
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_PURE
#define PURE_FUNC __attribute__((pure))
#else
#define PURE_FUNC
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_CONSTRUCTOR
#define CONSTRUCTOR_FUNC __attribute__((constructor))
#else
#define CONSTRUCTOR_FUNC
#endif


/****************************************************************************
**
*T  Char, Int1, Int2, Int4, Int, UChar, UInt1, UInt2, UInt4, UInt .  integers
**
**  'Char', 'Int1', 'Int2', 'Int4', 'Int8', 'Int', 'UChar', 'UInt1', 'UInt2',
**  'UInt4', 'UInt8', 'UInt' are the integer types.
**
**  '(U)Int<n>' should be exactly <n> bytes long
**  '(U)Int' should be the same length as a bag identifier
*/


typedef char     Char;
typedef uint8_t  UChar;

typedef int8_t   Int1;
typedef int16_t  Int2;
typedef int32_t  Int4;
typedef int64_t  Int8;

typedef uint8_t  UInt1;
typedef uint16_t UInt2;
typedef uint32_t UInt4;
typedef uint64_t UInt8;

typedef intptr_t  Int;
typedef uintptr_t UInt;

GAP_STATIC_ASSERT(sizeof(void *) == sizeof(Int), "sizeof(Int) is wrong");
GAP_STATIC_ASSERT(sizeof(void *) == sizeof(UInt), "sizeof(UInt) is wrong");


/****************************************************************************
**
**  'START_ENUM_RANGE' and 'END_ENUM_RANGE' simplify creating "ranges" of
**  enum variables.
**
**  Usage example:
**    enum {
**      START_ENUM_RANGE(FIRST),
**        FOO,
**        BAR,
**      END_ENUM_RANGE(LAST)
**    };
**  is essentially equivalent to
**    enum {
**      FIRST,
**        FOO = FIRST,
**        BAR,
**      LAST = BAR
**    };
**  Note that if we add a value into the range after 'BAR', we must adjust
**  the definition of 'LAST', which is easy to forget. Also, reordering enum
**  values may require extra work. With the range macros, all of this is
**  taken care of automatically.
*/
#define START_ENUM_RANGE(id)            id, _##id##_post = id - 1
#define START_ENUM_RANGE_INIT(id,init)  id = init, _##id##_post = id - 1
#define END_ENUM_RANGE(id)              _##id##_pre, id = _##id##_pre - 1


/****************************************************************************
**
*t  Bag . . . . . . . . . . . . . . . . . . . type of the identifier of a bag
**
**  (The documentation of 'Bag' is contained in 'gasman.h'.)
*/
typedef UInt * *        Bag;


/****************************************************************************
**
*T  Obj . . . . . . . . . . . . . . . . . . . . . . . . . . . type of objects
**
**  'Obj' is the type of objects.
*/
typedef Bag Obj;


/****************************************************************************
**
*T  ObjFunc . . . . . . . . . . . . . . . . type of function returning object
**
**  'ObjFunc' is the type of a function returning an object.
*/
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstrict-prototypes"
typedef Obj (* ObjFunc) (/*arguments*/);
#pragma GCC diagnostic pop

typedef Obj (* ObjFunc_0ARGS) (Obj self);
typedef Obj (* ObjFunc_1ARGS) (Obj self, Obj a1);
typedef Obj (* ObjFunc_2ARGS) (Obj self, Obj a1, Obj a2);
typedef Obj (* ObjFunc_3ARGS) (Obj self, Obj a1, Obj a2, Obj a3);
typedef Obj (* ObjFunc_4ARGS) (Obj self, Obj a1, Obj a2, Obj a3, Obj a4);
typedef Obj (* ObjFunc_5ARGS) (Obj self, Obj a1, Obj a2, Obj a3, Obj a4, Obj a5);
typedef Obj (* ObjFunc_6ARGS) (Obj self, Obj a1, Obj a2, Obj a3, Obj a4, Obj a5, Obj a6);


/****************************************************************************
**
*T  Stat  . . . . . . . . . . . . . . . . . . . . . . . .  type of statements
**
**  'Stat' is the type of statements.
**
**  If 'Stat' is different  from 'Expr', then  a lot of things will  probably
**  break.
*/
typedef UInt Stat;


/****************************************************************************
**
*T  Expr  . . . . . . . . . . . . . . . . . . . . . . . . type of expressions
**
**  'Expr' is the type of expressions.
**
**  If 'Expr' is different  from 'Stat', then  a lot of things will  probably
**  break.
*/
typedef Stat Expr;


/****************************************************************************
**
*V  BIPEB . . . . . . . . . . . . . . . . . . . . . . . . . .  bits per block
**
**  'BIPEB' is the  number of bits  per  block, where a  block  fills a UInt,
**  which must be the same size as a bag identifier.
**  'LBIPEB' is the log to the base 2 of BIPEB
**
*/
enum { BIPEB = sizeof(UInt) * 8, LBIPEB = (BIPEB == 64) ? 6 : 5 };


/****************************************************************************
**
*/
typedef const struct init_info StructInitInfo;
typedef StructInitInfo* (*InitInfoFunc)(void);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  SyExit( <ret> ) . . . . . . . . . . . . . exit GAP with return code <ret>
**
**  'SyExit' is the offical  way  to  exit GAP, bus errors are the inoffical.
**  The function 'SyExit' must perform all the neccessary cleanup operations.
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
