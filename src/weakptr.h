/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions that deal with weak pointer objects
**       it has to interwork somewhat closely with GASMAN.
**
**  A  weak pointer looks like a plain list, except that it does not cause
**  its entries to remain alive through a garbage collection, with the consequent
**  side effect, that its entries may vanish at any time.
**
**
*/

#ifndef GAP_WEAKPTR_H
#define GAP_WEAKPTR_H

#include "common.h"

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoWeakPtr() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoWeakPtr ( void );


#endif // GAP_WEAKPTR_H
