/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions for the floating point package
*/

#ifndef GAP_IOSTREAM_H
#define GAP_IOSTREAM_H

#include "common.h"

// Provide a feature macro to let libraries check if GAP supports
// CheckChildStatusChanged.
#define GAP_HasCheckChildStatusChanged

int CheckChildStatusChanged(int childPID, int status);

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoIOStream()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoIOStream(void);


#endif // GAP_IOSTREAM_H
