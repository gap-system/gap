/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions for the macfloat package
*/

#ifndef GAP_MACFLOAT_H
#define GAP_MACFLOAT_H

#include "objects.h"

typedef double Double;
#define PRINTFDIGITS 16
#define PRINTFFORMAT "g"
#define STRTOD strtod
#define MATH(name) name

Double VAL_MACFLOAT(Obj obj);
void SET_VAL_MACFLOAT(Obj obj, Double val);
BOOL IS_MACFLOAT(Obj obj);
Obj NEW_MACFLOAT(Double val);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoMacfloat() . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoMacfloat(void);


#endif    // GAP_MACFLOAT_H
