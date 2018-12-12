/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "system.h"
#include "compstat.h"

// #define AVOID_PRECOMPILED


/****************************************************************************
**
*V  CompInitFuncs . . . . . . . . . .  list of compiled module init functions
**
**  This a dummy list in case no module is statically linked.
*/
#ifndef AVOID_PRECOMPILED
extern StructInitInfo * Init__type1 ( void );
extern StructInitInfo * Init__oper1( void );
#endif

InitInfoFunc CompInitFuncs [] = {
#ifndef AVOID_PRECOMPILED
    Init__type1,
    Init__oper1,
#endif
    0
};
