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

#ifndef GAP_SYSJMP_H
#define GAP_SYSJMP_H

#include "system.h"

#include <setjmp.h>

/****************************************************************************
**
*F  sySetjmp( <jump buffer> )
*F  syLongjmp( <jump buffer>, <value> )
**
**  macros and functions, defining our selected longjump mechanism
*/

#if defined(HAVE_SIGSETJMP)
#define sySetjmp(buff) (sigsetjmp((buff), 0))
#define syLongjmpInternal siglongjmp
#define syJmp_buf sigjmp_buf
#elif defined(HAVE__SETJMP)
#define sySetjmp _setjmp
#define syLongjmpInternal _longjmp
#define syJmp_buf jmp_buf
#else
#define sySetjmp setjmp
#define syLongjmpInternal longjmp
#define syJmp_buf jmp_buf
#endif

void syLongjmp(syJmp_buf * buf, int val) NORETURN;

/****************************************************************************
**
*F  RegisterSyLongjmpObserver( <func> )
**
**  register a function to be called before longjmp is called.
*/

typedef void (*voidfunc)(void);

Int RegisterSyLongjmpObserver(voidfunc);

#endif    // GAP_SYSJMP_H
