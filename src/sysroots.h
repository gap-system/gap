/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
*/

#ifndef GAP_SYSROOTS_H
#define GAP_SYSROOTS_H

#include "common.h"
#include "system.h"


/****************************************************************************
**
*V  SyDefaultRootPath
**
**  Default initial root path. Default is the current directory, if we have
**  no other idea, for backwards compatibility.
*/
extern char SyDefaultRootPath[GAP_PATH_MAX];

#include <stddef.h>


/****************************************************************************
**
*F  SySetGapRootPath( <string> )  . . . . . . . . .  set the root directories
**
**  'SySetGapRootPath' takes a string and modifies a list of root directories
**  in 'SyGapRootPaths'.
**
**  A  leading semicolon in  <string> means  that the list  of directories in
**  <string> is  appended  to the  existing list  of  root paths.  A trailing
**  semicolon means they are prepended.   If there is  no leading or trailing
**  semicolon, then the root paths are overwritten.
*/
void SySetGapRootPath(const Char * string);


/****************************************************************************
**
*F  SyFindGapRootFile( <filename> ) . . . . . . . .  find file in system area
**
**  This function searches for a readable file with the name <filename> in
**  the system area. If such a file is found then its absolute path is
**  returned as a string object. If no file is found then NULL is returned.
*/
Obj SyFindGapRootFile(const Char * filename);


/****************************************************************************
**
*F  SyGetGapRootPaths() . . . . . . . . . return the list of root directories
**
**  Returns a plain list containing absolute paths of the root directories as
**  string objects.
*/
Obj SyGetGapRootPaths(void);


#endif    // GAP_SYSROOTS_H
