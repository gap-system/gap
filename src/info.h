/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions handling Info statements.
*/

#ifndef GAP_INFO_H
#define GAP_INFO_H

#include "gap.h"

/****************************************************************************
**
*F  InfoCheckLevel( <selectors>, <level> )  . . . check if Info should output
**  InfoDoPrint( <selectors>, <level>, <args> ) . . . print an Info statement
*/

Obj InfoCheckLevel(Obj selectors, Obj level);

void InfoDoPrint(Obj cls, Obj lvl, Obj args);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoInfo()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoInfo(void);

#endif
