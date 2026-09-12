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

#include "common.h"

enum {
    OBJSET_HDRSIZE = 4,

    OBJSET_SIZE = 0,
    OBJSET_BITS = 1,
    OBJSET_USED = 2,
    OBJSET_DIRTY = 3,
};

Obj  NewObjSet(void) GAP_GC_CANSAFEPOINT;
Int  FindObjSet(Obj set, Obj obj);
void AddObjSet(Obj set, Obj obj GAP_GC_ROOTED_BY_ARG(0)) GAP_GC_CANSAFEPOINT;
void RemoveObjSet(Obj set, Obj obj) GAP_GC_CANSAFEPOINT;
void ClearObjSet(Obj set) GAP_GC_CANSAFEPOINT;
Obj  ObjSetValues(Obj set) GAP_GC_CANSAFEPOINT;

Obj  NewObjMap(void) GAP_GC_CANSAFEPOINT;
Int  FindObjMap(Obj map, Obj key);
Obj  LookupObjMap(Obj map GAP_GC_PROPAGATES_ROOT, Obj key);
void AddObjMap(Obj map,
               Obj key GAP_GC_ROOTED_BY_ARG(0),
               Obj value GAP_GC_ROOTED_BY_ARG(0)) GAP_GC_CANSAFEPOINT;
void RemoveObjMap(Obj map, Obj obj) GAP_GC_CANSAFEPOINT;
void ClearObjMap(Obj map) GAP_GC_CANSAFEPOINT;
Obj  ObjMapValues(Obj map) GAP_GC_CANSAFEPOINT;
Obj  ObjMapKeys(Obj map) GAP_GC_CANSAFEPOINT;

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
