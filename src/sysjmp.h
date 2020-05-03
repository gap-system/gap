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
*F  RegisterSyLongjmpObserver( <func> )
**
**  Register a function to be called before longjmp is called.
**  Returns 1 on success, 0 if the table of functions is already full.
**  This function is idempotent -- if a function is passed multiple times
**  it is still only registered once.
*/
Int RegisterSyLongjmpObserver(voidfunc);

#endif    // GAP_SYSJMP_H
