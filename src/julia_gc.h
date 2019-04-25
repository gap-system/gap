/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares functions of the Julia GC interface.
*/

#ifndef GAP_JULIA_GC_H
#define GAP_JULIA_GC_H

/****************************************************************************
**
*F  MarkJuliaObj(<obj>) . . . . . . . . . . . . . . . . . . mark Julia object
**
**  'MarkJuliaObjSafe' marks a Julia object; the argument can be NULL.
*/

void MarkJuliaObj(void * obj);

/****************************************************************************
**
*F  MarkJuliaObjSafe(<obj>) . . . . . . . . . . . . . . . . mark Julia object
**
**  'MarkJuliaObjSafe' marks a Julia object; the argument may be NULL.
**  Extra validation steps are performed to determine whether <obj> is
**  a valid Julia object. If not, it is silently ignored.
*/

void MarkJuliaObjSafe(void * obj);

#endif
