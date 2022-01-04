/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_COMMON_H
#define GAP_COMMON_H

#include <assert.h>
#include <stdint.h>

#include "debug.h"

// check if we are on a 64 or 32 bit machine; in the former
// case, define SYS_IS_64_BIT.
// also define SIZEOF_VOID_P for backwards compatibility with some
// GAP packages that expect it
#if INTPTR_MAX == INT64_MAX
#define SYS_IS_64_BIT 1
#define SIZEOF_VOID_P 8
#elif INTPTR_MAX == INT32_MAX
#undef SYS_IS_64_BIT
#define SIZEOF_VOID_P 4
#else
#error Unknown pointer size or missing size macros!
#endif

// check that the pointer size detected by configure matches that of the
// current compiler; this helps prevent kernel extensions from being
// compiled with the wrong ABI
GAP_STATIC_ASSERT(sizeof(void *) == SIZEOF_VOID_P, "sizeof(void *) is wrong");


// check for cygwin
#if defined(__CYGWIN__) || defined(__CYGWIN32__)
// for historical reasons, the macro we define is called SYS_IS_CYGWIN32
#define SYS_IS_CYGWIN32 1
#endif


// Some packages check the USE_GMP flag; retain it for now to allow these
// packages to work correctly for now. We should remove this eventually.
#define USE_GMP 1


#ifdef USE_GASMAN
#define GAP_ENABLE_SAVELOAD
#endif


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

// FIXME: workaround a conflict with the Semigroups package
#undef BOOL
typedef Int BOOL; // TODO: should be changed to `char` once packages adapted
enum { FALSE = 0, TRUE = 1 };


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

typedef void (*voidfunc)(void);


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
*T  StructInitInfo  . . . . . . . . . . . . . . . . . module init information
**
**  This is a forward declaration so that StructInitInfo can be used in other
**  header files. The actual declaration is in modules.h.
*/
typedef const struct init_info StructInitInfo;


/****************************************************************************
**
*T  TypInputFile  . . . . . . . . . .  structure of an open input file, local
**
**  This is a forward declaration so that TypInputFile can be used in header
**  files. The actual declaration is in io.h.
*/
typedef struct TypInputFile TypInputFile;


/****************************************************************************
**
*T  TypOutputFile . . . . . . . . . . structure of an open output file, local
**
**  This is a forward declaration so that TypOutputFiles can be used in
**  header files. The actual declaration is in io.h.
*/
typedef struct TypOutputFile TypOutputFile;


/****************************************************************************
**
*T  ExecStatus . . . .  type of status values returned by read, eval and exec
**                      subroutines, explaining why evaluation, or execution
**                      has terminated.
*/

typedef enum {
    STATUS_END,         // ran off the end of the code
    STATUS_RETURN,      // 'return' statement
    STATUS_BREAK,       // 'break' statement
    STATUS_CONTINUE,    // 'continue' statement
    STATUS_QUIT,        // 'quit' statement
    STATUS_QQUIT,       // 'QUIT' statement
    STATUS_EOF,         // end of file while parsing
    STATUS_ERROR,       // syntax error while parsing
} ExecStatus;


/****************************************************************************
**
*T  EvalBoolFunc
*T  EvalExprFunc
*T  ExecStatFunc
*T  PrintStatFunc
*T  PrintExprFunc
*/
typedef Obj (*EvalBoolFunc)(Expr);
typedef Obj (*EvalExprFunc)(Expr);
typedef ExecStatus (*ExecStatFunc)(Stat);
typedef void (*PrintStatFunc)(Stat);
typedef void (*PrintExprFunc)(Expr);


#endif // GAP_COMMON_H
