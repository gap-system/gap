/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the GAP build version
*/

#include "system.h"


/****************************************************************************
**
*V  SyKernelVersion . . . . . . . . . . . . . . . . . . kernel version number
**
**  'SyKernelVersion' is something like "4.12.2" or "4.12.dev".
*/
extern const char * SyKernelVersion;


/****************************************************************************
**
*V  SyReleaseDay . . . . . . . . . . . . . . release date of this GAP version
**
**  'SyReleaseDay' is the date of the release, e.g. "19-Jun-2019"; for
**  development versions, this is set to "today".
*/
extern const char * SyReleaseDay;


/****************************************************************************
**
*V  SyBuildVersion . . . . . . . . . . . . . . . . . source version for build
**
**  'SyBuildVersion' is identical to 'SyKernelVersion' for release versions.
**  For development versions, it is something like "4.12dev-302-g09161ee".
*/
extern const char * SyBuildVersion;


/****************************************************************************
**
*V  SyBuildDateTime . . . . . . . . . . . . . . . date the build was compiled
**
**  'SyBuildDateTime' is identical to 'SyReleaseDay' for release versions.
**  For development versions, it is something like "2020-01-30 09:48:08" in
**  local time.
*/
extern const char * SyBuildDateTime;
