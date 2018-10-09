/****************************************************************************
**
*W  profile.h                     GAP source              Chris Jefferson
**
**
*Y  Copyright (C) 2014 The GAP Group
**
**  This file contains profile related functionality.
**
*/

#ifndef GAP_PROFILE_H
#define GAP_PROFILE_H

#include "system.h"

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

// When a child is forked off, we force profile information to be stored
// in a new file for the child, to avoid corruption.
// This function is for use by the IO package
void InformProfilingThatThisIsAForkedGAP(void);


/****************************************************************************
**
*F  InitInfoProfile() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoProfile ( void );

#endif // GAP_PROFILE_H
