/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_OBJSET_H
#define GAP_OBJSET_H

#include "system.h"

#define OBJSET_HDRSIZE 4

#define OBJSET_SIZE 0
#define OBJSET_BITS 1
#define OBJSET_USED 2
#define OBJSET_DIRTY 3

extern Obj  NewObjSet(void);
extern Int  FindObjSet(Obj set, Obj obj);
extern void AddObjSet(Obj set, Obj obj);
extern void RemoveObjSet(Obj set, Obj obj);
extern void ClearObjSet(Obj set);
extern Obj  ObjSetValues(Obj set);

extern Obj  NewObjMap(void);
extern Int  FindObjMap(Obj map, Obj key);
extern Obj  LookupObjMap(Obj map, Obj key);
extern void AddObjMap(Obj map, Obj key, Obj value);
extern void RemoveObjMap(Obj map, Obj obj);
extern void ClearObjMap(Obj map);
extern Obj  ObjMapValues(Obj map);
extern Obj  ObjMapKeys(Obj map);

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoObjSets() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo *InitInfoObjSets( void );

#endif // GAP_OBJSET_H
