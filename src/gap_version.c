/****************************************************************************
**
*W  gap_version.c
**
*Y  Copyright (C) 2016 The GAP Group
**
**  This file contains the GAP build version
*/

#include "system.h"

#include "gap_version.h"

/****************************************************************************
**
*V  SyBuildVersion  . . . . . . . . . . . . . . . . source version for build 
*V  SyBuildDateTime . . . . . . . . . . . . . . . . . date and time of build 
*/
const Char * SyBuildVersion  = GAP_VERSION;
const Char * SyBuildDateTime = "today";
