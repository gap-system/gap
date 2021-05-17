/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "compstat.h"
#include "common.h"

/****************************************************************************
**
*V  CompInitFuncs . . . . . . . . . .  list of compiled module init functions
**
**  This a dummy list in case no module is statically linked.
*/
extern StructInitInfo * Init__type1(void);
extern StructInitInfo * Init__oper1(void);

InitInfoFunc CompInitFuncs[] = {
    Init__type1,
    Init__oper1,
    0
};
