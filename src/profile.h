/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains profile related functionality.
**
*/

#ifndef GAP_PROFILE_H
#define GAP_PROFILE_H

#include "common.h"

Int enableProfilingAtStartup(Char ** argv, void * dummy);
Int enableMemoryProfilingAtStartup(Char ** argv, void * dummy);
Int enableCodeCoverageAtStartup(Char ** argv, void * dummy);
void pauseProfiling(void);
void unpauseProfiling(void);

// When a child is forked off, we force profile information to be stored
// in a new file for the child, to avoid corruption.
// This function is for use by the IO package
void InformProfilingThatThisIsAForkedGAP(void);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoProfile() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoProfile ( void );

#endif // GAP_PROFILE_H
