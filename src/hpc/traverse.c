/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

/*
 * Functionality to traverse nested object structures.
 */
#include "hpc/traverse.h"

#include "bool.h"
#include "error.h"
#include "fibhash.h"
#include "gaputils.h"
#include "modules.h"
#include "plist.h"

#include "hpc/guards.h"
#include "hpc/thread.h"

#ifndef WARD_ENABLED

struct TraversalState {
    Obj                     list;
    UInt                    listSize;
    UInt                    listCurrent;
    UInt                    listCapacity;
    Obj                     hashTable;
    Obj                     copyMap;
    UInt                    hashSize;
    UInt                    hashCapacity;
    UInt                    hashBits;
    Region *                region;
    int                     border;
    int (*traversalCheck)(TraversalState *, Obj);
};

static Obj NewList(UInt size)
{
    Obj list;
    list = NEW_PLIST(size == 0 ? T_PLIST_EMPTY : T_PLIST, size);
    SET_LEN_PLIST(list, size);
    return list;
}


static TraversalFunction     TraversalFunc[LAST_REAL_TNUM + 1];
static TraversalCopyFunction TraversalCopyFunc[LAST_REAL_TNUM + 1];
static TraversalMethodEnum   TraversalMethod[LAST_REAL_TNUM + 1];

static UInt FindTraversedObj(TraversalState * traversal, Obj);

inline Obj ReplaceByCopy(TraversalState * traversal, Obj obj)
{
    if (!IS_BAG_REF(obj))
        return obj;

    UInt             found = FindTraversedObj(traversal, obj);
    if (found)
        return ELM_PLIST(traversal->copyMap, found);
    else if (traversal->border) {
        if (!IS_BAG_REF(obj) || !REGION(obj) ||
            REGION(obj) == traversal->region)
            return obj;
        else
            return GetRegionOf(obj)->obj;
    }
    else
        return obj;
}

void SetTraversalMethod(UInt tnum,
                        TraversalMethodEnum meth,
                        TraversalFunction tf,
                        TraversalCopyFunction cf)
{
    GAP_ASSERT(tnum < ARRAY_SIZE(TraversalMethod));
    TraversalMethod[tnum] = meth;
    TraversalFunc[tnum] = tf;
    TraversalCopyFunc[tnum] = cf;
}

static void BeginTraversal(TraversalState * traversal)
{
    traversal->hashTable = NewList(16);
    traversal->hashSize = 0;
    traversal->hashCapacity = 16;
    traversal->hashBits = 4;
    traversal->list = NewList(10);
    traversal->listSize = 0;
    traversal->listCapacity = 10;
    traversal->listCurrent = 0;
}

static void TraversalRehash(TraversalState * traversal);

static int SeenDuringTraversal(TraversalState * traversal, Obj obj)
{
    Obj *            hashTable;
    UInt             hash;
    if (!IS_BAG_REF(obj))
        return 0;
    if (traversal->hashSize * 3 / 2 >= traversal->hashCapacity)
        TraversalRehash(traversal);
    hash = FibHash((UInt)obj, traversal->hashBits);
    hashTable = ADDR_OBJ(traversal->hashTable) + 1;
    for (;;) {
        if (hashTable[hash] == NULL) {
            hashTable[hash] = obj;
            traversal->hashSize++;
            return 1;
        }
        if (hashTable[hash] == obj)
            return 0;
        hash = (hash + 1) & (traversal->hashCapacity - 1);
    }
}

static UInt FindTraversedObj(TraversalState * traversal, Obj obj)
{
    Obj *            hashTable;
    UInt             hash;
    if (!IS_BAG_REF(obj))
        return 0;
    hash = FibHash((UInt)obj, traversal->hashBits);
    hashTable = ADDR_OBJ(traversal->hashTable) + 1;
    for (;;) {
        if (hashTable[hash] == obj)
            return (int)hash + 1;
        if (hashTable[hash] == NULL)
            return 0;
        hash = (hash + 1) & (traversal->hashCapacity - 1);
    }
}

static void TraversalRehash(TraversalState * traversal)
{
    Obj list = NewList(traversal->hashCapacity * 2);
    int oldsize = traversal->hashCapacity;
    int i;
    Obj oldlist = traversal->hashTable;
    traversal->hashCapacity *= 2;
    traversal->hashTable = list;
    traversal->hashSize = 0;
    traversal->hashBits++;
    for (i = 1; i <= oldsize; i++) {
        Obj obj = CONST_ADDR_OBJ(oldlist)[i];
        if (obj != NULL)
            SeenDuringTraversal(traversal, obj);
    }
}

void QueueForTraversal(TraversalState * traversal, Obj obj)
{
    int              i;
    if (!IS_BAG_REF(obj))
        return; /* skip ojects that aren't bags */
    if (!traversal->traversalCheck(traversal, obj))
        return;
    if (!SeenDuringTraversal(traversal, obj))
        return; /* don't revisit objects that we've already seen */
    if (traversal->listSize == traversal->listCapacity) {
        unsigned oldcapacity = traversal->listCapacity;
        unsigned newcapacity =
            oldcapacity * 25 / 16; /* 25/16 < golden ratio */
        Obj oldlist = traversal->list;
        Obj list = NewList(newcapacity);
        for (i = 1; i <= oldcapacity; i++)
            ADDR_OBJ(list)[i] = CONST_ADDR_OBJ(oldlist)[i];
        traversal->list = list;
        traversal->listCapacity = newcapacity;
    }
    ADDR_OBJ(traversal->list)[++traversal->listSize] = obj;
}

static void TraverseRegionFrom(TraversalState * traversal,
                        Obj              obj,
                        int (*traversalCheck)(TraversalState *, Obj))
{
    GAP_ASSERT(IS_BAG_REF(obj));
    GAP_ASSERT(REGION(obj) != NULL);
    if (!CheckReadAccess(obj)) {
        traversal->list = NewList(0);
        return;
    }
    traversal->traversalCheck = traversalCheck;
    traversal->region = REGION(obj);
    QueueForTraversal(traversal, obj);
    while (traversal->listCurrent < traversal->listSize) {
        Obj current = ADDR_OBJ(traversal->list)[++traversal->listCurrent];
        int tnum = TNUM_BAG(current);
        const TraversalMethodEnum method = TraversalMethod[tnum];
        int                       size;
        Obj *                     ptr;
        switch (method) {
        case TRAVERSE_BY_FUNCTION:
            TraversalFunc[tnum](traversal, current);
            break;
        case TRAVERSE_NONE:
            break;
        case TRAVERSE_ALL:
        case TRAVERSE_ALL_BUT_FIRST:
            size = SIZE_BAG(current) / sizeof(Obj);
            ptr = PTR_BAG(current);
            if (size && method == TRAVERSE_ALL_BUT_FIRST) {
                ptr++;
                size--;
            }
            while (size) {
                QueueForTraversal(traversal, *ptr);
                ptr++;
                size--;
            }
            break;
        }
    }
    SET_LEN_PLIST(traversal->list, traversal->listSize);
}

// static int IsReadable(Obj obj) {
//   return CheckReadAccess(obj);
// }

static int IsSameRegion(TraversalState * traversal,Obj obj)
{
    return REGION(obj) == traversal->region;
}

static int IsMutable(TraversalState * traversal, Obj obj)
{
    return CheckReadAccess(obj) && IS_MUTABLE_OBJ(obj);
}

static int IsWritableOrImmutable(TraversalState * traversal, Obj obj)
{
    int writable = CheckExclusiveWriteAccess(obj);
    if (!writable && IS_MUTABLE_OBJ(obj)) {
        traversal->border = 1;
        return 0;
    }
    return 1;
}

Obj ReachableObjectsFrom(Obj obj)
{
    TraversalState traversal;
    if (!IS_BAG_REF(obj) || REGION(obj) == NULL)
        return NewList(0);
    BeginTraversal(&traversal);
    TraverseRegionFrom(&traversal, obj, IsSameRegion);
    return traversal.list;
}

static Obj CopyBag(TraversalState * traversal, Obj copy, Obj original)
{
    UInt                      size = SIZE_BAG(original);
    UInt                      type = TNUM_BAG(original);
    const TraversalMethodEnum method = TraversalMethod[type];
    Obj *                     ptr = ADDR_OBJ(copy);
    memcpy(ptr, CONST_ADDR_OBJ(original), size);

    switch (method) {
    case TRAVERSE_BY_FUNCTION:
        TraversalCopyFunc[type](traversal, copy, original);
        break;
    case TRAVERSE_NONE:
        break;
    case TRAVERSE_ALL:
    case TRAVERSE_ALL_BUT_FIRST:
        size = size / sizeof(Obj);
        if (size && method == TRAVERSE_ALL_BUT_FIRST) {
            ptr++;
            size--;
        }
        while (size) {
            *ptr = ReplaceByCopy(traversal, *ptr);
            ptr++;
            size -= 1;
        }
        break;
    }
    return copy;
}

int PreMakeImmutableCheck(Obj obj)
{
    TraversalState traversal;
    if (!IS_BAG_REF(obj))
        return 1;
    if (!IS_MUTABLE_OBJ(obj))
        return 1;
    if (!CheckExclusiveWriteAccess(obj))
        return 0;
    if (TraversalMethod[TNUM_OBJ(obj)] == TRAVERSE_NONE)
        return 1;
    BeginTraversal(&traversal);
    traversal.border = 0;
    TraverseRegionFrom(&traversal, obj, IsWritableOrImmutable);
    return !traversal.border;
}

static Obj WrappedInList(Obj obj)
{
    Obj list = NewList(1);
    SET_ELM_PLIST(list, 1, obj);
    return list;
}

Obj CopyReachableObjectsFrom(Obj obj, int delimited, int asList, int imm)
{
    Obj            copyList;
    TraversalState traversal;
    UInt           len, i;
    if (!IS_BAG_REF(obj) || REGION(obj) == NULL) {
        UInt tnum = TNUM_OBJ(obj);

        if (tnum >= FIRST_ATOMIC_TNUM && tnum <= LAST_ATOMIC_TNUM) {
            ErrorQuit("atomic objects cannot be copied", 0, 0);
        }

        return asList ? WrappedInList(obj) : obj;
    }
    if (imm && !IS_MUTABLE_OBJ(obj))
        return asList ? WrappedInList(obj) : obj;

    BeginTraversal(&traversal);
    TraverseRegionFrom(&traversal, obj, imm ? IsMutable : IsSameRegion);

    const Obj * traversed = CONST_ADDR_OBJ(traversal.list);
    len = LEN_PLIST(traversal.list);
    copyList = NewList(len);
    Obj * copies = ADDR_OBJ(copyList);
    traversal.border = delimited;
    if (len == 0) {
        if (delimited) {
            // FIXME: honor asList
            return GetRegionOf(obj)->obj;
        }
        ErrorQuit("Object not in a readable region", 0L, 0L);
    }
    traversal.copyMap = NewList(LEN_PLIST(traversal.hashTable));
    for (i = 1; i <= len; i++) {
        UInt loc = FindTraversedObj(&traversal, traversed[i]);
        if (loc) {
            Obj original = traversed[i];
            Obj copy;
            copy = NewBag(TNUM_BAG(original), SIZE_BAG(original));
            SET_ELM_PLIST(traversal.copyMap, loc, copy);
            copies[i] = copy;
        }
    }
    for (i = 1; i <= len; i++)
        if (copies[i])
            CopyBag(&traversal, copies[i], traversed[i]);
    if (imm) {
        for (i = 1; i <= len; i++) {
            if (copies[i])
                MakeImmutable(copies[i]);
        }
    }
    if (asList)
        return copyList;
    else
        return copies[1];
}

Obj CopyTraversed(Obj traversedList)
{
    TraversalState traversal;
    UInt           len, i;
    const Obj *    traversed = CONST_ADDR_OBJ(traversedList);
    BeginTraversal(&traversal);
    len = LEN_PLIST(traversedList);
    if (len == 1) {
        Obj obj = traversed[1];
        if (!IS_BAG_REF(obj) || REGION(obj) == NULL)
            return obj;
    }
    for (i = 1; i <= len; i++)
        SeenDuringTraversal(&traversal, traversed[i]);
    Obj   copyList = NewList(len);
    Obj * copies = ADDR_OBJ(copyList);
    traversal.copyMap = NewList(LEN_PLIST(traversal.hashTable));
    for (i = 1; i <= len; i++) {
        Obj  original = traversed[i];
        UInt loc = FindTraversedObj(&traversal, original);
        Obj  copy;
        copy = NewBag(TNUM_BAG(original), SIZE_BAG(original));
        SET_ELM_PLIST(traversal.copyMap, loc, copy);
        copies[i] = copy;
    }
    for (i = 1; i <= len; i++)
        CopyBag(&traversal, copies[i], traversed[i]);
    return copies[1];
}


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo * module )
{
    int i;
    for (i = FIRST_REAL_TNUM; i <= LAST_REAL_TNUM; i++) {
        assert(TraversalMethod[i] == 0);
        TraversalMethod[i] = TRAVERSE_NONE;
    }

    return 0;
}


/****************************************************************************
**
*F  InitInfoGVars() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "traverse",
    .initKernel = InitKernel,
};

StructInitInfo * InitInfoTraverse ( void )
{
    return &module;
}

#endif
