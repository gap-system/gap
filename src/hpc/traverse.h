/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_TRAVERSE_H
#define GAP_TRAVERSE_H

#include "common.h"

typedef struct TraversalState TraversalState;

/*
 * Functionality to traverse nested object structures.
 */

typedef void (*TraversalFunction)(TraversalState *, Obj);
typedef void (*TraversalCopyFunction)(TraversalState *, Obj copy, Obj original);

typedef enum {
    TRAVERSE_NONE,
    TRAVERSE_BY_FUNCTION,
    TRAVERSE_ALL,
    TRAVERSE_ALL_BUT_FIRST,
} TraversalMethodEnum;

// set the traversal method (and optionally, helper functions)
// for all objects with the specified tnum.
void SetTraversalMethod(UInt                  tnum,
                        TraversalMethodEnum   meth,
                        TraversalFunction     tf,
                        TraversalCopyFunction cf);


// helper to be called from traverse functions
void QueueForTraversal(TraversalState *, Obj obj);

// helper to be called from copy functions
Obj ReplaceByCopy(TraversalState *, Obj obj);


Obj ReachableObjectsFrom(Obj obj);
Obj CopyReachableObjectsFrom(Obj obj, int delimited, int asList, int imm);
Obj CopyTraversed(Obj traversed);

//
// PreMakeImmutableCheck checks whether the given object <obj> can be
// made immutable by the active thread, by traversing <obj> and all its
// subobjects and checking that they are either already immutable, or
// that the active thread has exclusive write access.
//
// Called by CheckedMakeImmutable().
//
int PreMakeImmutableCheck(Obj obj);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoTraverse() . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoTraverse( void );


#endif // GAP_TRAVERSE_H
