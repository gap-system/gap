/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions concerned with saving and loading
**  the workspace. There are support functions in gasman.c and elsewhere
**  throughout the kernel
*/

#ifndef GAP_SAVELOAD_H
#define GAP_SAVELOAD_H

#include "common.h"

#ifdef GAP_ENABLE_SAVELOAD

/***************************************************************************
**
*F  SaveWorkspace( <fname> ) . . . . . .save the workspace to the named file
**
**  'SaveWorkspace' is the entry point to the workspace saving. It is not
**  installed as a GAP function, but instead as a keyword, so that we can be
**  sure it is only being called from the top-most prompt level
**  The file saveload.tex in the dev directory describes the saved format
**  in more detail. Most of the work will be done from inside GASMAN, because
**  we need to fiddle with Bag internals somewhat
**
**  The return value is either True or Fail
*/

Obj SaveWorkspace(Obj fname);

void LoadWorkspace(Char * fname);

void SaveUInt1(UInt1 x);
void SaveUInt2(UInt2 x);
void SaveUInt4(UInt4 x);
void SaveUInt(UInt x);
void SaveUInt8(UInt8 x);
void SaveCStr(const Char * s);
void SaveString(Obj string);
void LoadString(Obj string);
void SaveSubObj(Obj o);

UInt1 LoadUInt1(void);
UInt2 LoadUInt2(void);
UInt4 LoadUInt4(void);
UInt  LoadUInt(void);
UInt8 LoadUInt8(void);
void LoadCStr(Char * buf, UInt maxlen);
Obj  LoadSubObj(void);

#endif // GAP_ENABLE_SAVELOAD


/***************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoSaveLoad()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoSaveLoad ( void );


#endif // GAP_SAVELOAD_H
