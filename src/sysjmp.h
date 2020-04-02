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
*F  syLongjmp( <jump buffer>, <value> )
**
**  A wrapper around longjmp, so other functions can do work before longjmp
**  is called
*/

void syLongjmp(jmp_buf * buf, int val) NORETURN;

/****************************************************************************
**
*F  RegisterSyLongjmpObserver( <func> )
**
**  register a function to be called before longjmp is called.
*/

typedef void (*voidfunc)(void);

Int RegisterSyLongjmpObserver(voidfunc);

#endif    // GAP_SYSJMP_H
