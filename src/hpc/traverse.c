/*
 * Functionality to traverse nested object structures.
 */
#include <src/system.h>
#include <src/gapstate.h>
#include <src/gasman.h>
#include <src/objects.h>
#include <src/bool.h>
#include <src/gvars.h>
#include <src/scanner.h>
#include <src/code.h>
#include <src/plist.h>
#include <src/stringobj.h>
#include <src/precord.h>
#include <src/stats.h>
#include <src/gap.h>
#include <src/hpc/tls.h>
#include <src/hpc/thread.h>
#include <src/hpc/traverse.h>
#include <src/fibhash.h>
#include <src/objset.h>

#ifdef BOEHM_GC
# ifdef HPCGAP
#  define GC_THREADS
# endif
# include <gc/gc.h>
#endif

#ifndef WARD_ENABLED

typedef struct TraversalState {
    struct TraversalState * previousTraversal;
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
    int (*traversalCheck)(Bag bag);
} TraversalState;

static inline TraversalState * currentTraversal(void)
{
    return TLS(traversalState);
}

static Obj NewList(UInt size)
{
    Obj list;
    list = NEW_PLIST(size == 0 ? T_PLIST_EMPTY : T_PLIST, size);
    SET_LEN_PLIST(list, size);
    return list;
}


void QueueForTraversal(Obj obj);

typedef enum {
    TRAVERSE_BY_FUNCTION,
    TRAVERSE_NONE,
    TRAVERSE_ALL,
    TRAVERSE_ALL_BUT_FIRST,
} TraversalMethodEnum;

typedef void (*TraversalCopyFunction)(Obj copy, Obj original);

TraversalFunction     TraversalFunc[LAST_REAL_TNUM + 1];
TraversalCopyFunction TraversalCopyFunc[LAST_REAL_TNUM + 1];
TraversalMethodEnum   TraversalMethod[LAST_REAL_TNUM + 1];

void TraversePList(Obj obj)
{
    UInt  len = LEN_PLIST(obj);
    Obj * ptr = ADDR_OBJ(obj) + 1;
    while (len) {
        QueueForTraversal(*ptr++);
        len--;
    }
}

void TraverseWPObj(Obj obj)
{
    /* This is a hack, we rely on weak pointer objects
     * having the same layout as plain lists, so we don't
     * have to replicate the macro here.
     */
    UInt  len = LEN_PLIST(obj);
    Obj * ptr = ADDR_OBJ(obj) + 1;
    while (len) {
        volatile Obj tmp = *ptr;
        MEMBAR_READ();
        if (tmp && *ptr)
            QueueForTraversal(*ptr);
        ptr++;
        len--;
    }
}

static UInt FindTraversedObj(Obj);

static inline Obj ReplaceByCopy(Obj obj)
{
    TraversalState * traversal = currentTraversal();
    UInt             found = FindTraversedObj(obj);
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

void CopyPList(Obj copy, Obj original)
{
    UInt  len = LEN_PLIST(original);
    Obj * ptr = ADDR_OBJ(original) + 1;
    Obj * copyptr = ADDR_OBJ(copy) + 1;
    while (len) {
        *copyptr++ = ReplaceByCopy(*ptr++);
        len--;
    }
}

void CopyWPObj(Obj copy, Obj original)
{
    /* This is a hack, we rely on weak pointer objects
     * having the same layout as plain lists, so we don't
     * have to replicate the macro here.
     */
    UInt  len = LEN_PLIST(original);
    Obj * ptr = ADDR_OBJ(original) + 1;
    Obj * copyptr = ADDR_OBJ(copy) + 1;
    while (len) {
        volatile Obj tmp = *ptr;
        MEMBAR_READ();
        if (tmp && *ptr)
            *copyptr = ReplaceByCopy(tmp);
        REGISTER_WP(copyptr, tmp);
        ptr++;
        copyptr++;
    }
}

void TraversePRecord(Obj obj)
{
    UInt i, len = LEN_PREC(obj);
    for (i = 1; i <= len; i++)
        QueueForTraversal((Obj)GET_ELM_PREC(obj, i));
}

void CopyPRecord(Obj copy, Obj original)
{
    UInt i, len = LEN_PREC(original);
    for (i = 1; i <= len; i++)
        SET_ELM_PREC(copy, i, ReplaceByCopy(GET_ELM_PREC(original, i)));
}

void TraverseObjSet(Obj obj)
{
    UInt i, len = *(UInt *)(ADDR_OBJ(obj) + OBJSET_SIZE);
    for (i = 0; i < len; i++) {
        Obj item = ADDR_OBJ(obj)[OBJSET_HDRSIZE + i];
        if (item && item != Undefined)
            QueueForTraversal(item);
    }
}

void CopyObjSet(Obj copy, Obj original)
{
    UInt i, len = *(UInt *)(ADDR_OBJ(original) + OBJSET_SIZE);
    for (i = 0; i < len; i++) {
        Obj item = ADDR_OBJ(original)[OBJSET_HDRSIZE + i];
        ADDR_OBJ(copy)[OBJSET_HDRSIZE + i] = ReplaceByCopy(item);
    }
}

void TraverseObjMap(Obj obj)
{
    UInt i, len = *(UInt *)(ADDR_OBJ(obj) + OBJSET_SIZE);
    for (i = 0; i < len; i++) {
        Obj key = ADDR_OBJ(obj)[OBJSET_HDRSIZE + 2 * i];
        Obj val = ADDR_OBJ(obj)[OBJSET_HDRSIZE + 2 * i + 1];
        if (key && key != Undefined) {
            QueueForTraversal(key);
            QueueForTraversal(val);
        }
    }
}

void CopyObjMap(Obj copy, Obj original)
{
    UInt i, len = *(UInt *)(ADDR_OBJ(original) + OBJSET_SIZE);
    for (i = 0; i < len; i++) {
        Obj key = ADDR_OBJ(original)[OBJSET_HDRSIZE + 2 * i];
        Obj val = ADDR_OBJ(original)[OBJSET_HDRSIZE + 2 * i + 1];
        ADDR_OBJ(copy)[OBJSET_HDRSIZE + 2 * i] = ReplaceByCopy(key);
        ADDR_OBJ(copy)[OBJSET_HDRSIZE + 2 * i + 1] = ReplaceByCopy(val);
    }
}

void InitTraversalModule(void)
{
    int i;
    for (i = FIRST_REAL_TNUM; i <= LAST_REAL_TNUM; i++) {
        assert(TraversalMethod[i] == 0);
        TraversalMethod[i] = TRAVERSE_NONE;
    }
    TraversalMethod[T_PREC] = TRAVERSE_BY_FUNCTION;
    TraversalMethod[T_PREC + IMMUTABLE] = TRAVERSE_BY_FUNCTION;
    TraversalFunc[T_PREC] = TraversePRecord;
    TraversalCopyFunc[T_PREC] = CopyPRecord;
    TraversalFunc[T_PREC + IMMUTABLE] = TraversePRecord;
    TraversalCopyFunc[T_PREC + IMMUTABLE] = CopyPRecord;
    for (i = FIRST_PLIST_TNUM; i <= LAST_PLIST_TNUM; i++) {
        TraversalMethod[i] = TRAVERSE_BY_FUNCTION;
        TraversalFunc[i] = TraversePList;
        TraversalCopyFunc[i] = CopyPList;
    }
    TraversalMethod[T_PLIST_CYC] = TRAVERSE_NONE;
    TraversalMethod[T_PLIST_CYC_NSORT] = TRAVERSE_NONE;
    TraversalMethod[T_PLIST_CYC_SSORT] = TRAVERSE_NONE;
    TraversalMethod[T_PLIST_FFE] = TRAVERSE_NONE;

    TraversalMethod[T_POSOBJ] = TRAVERSE_ALL_BUT_FIRST;

    TraversalMethod[T_COMOBJ] = TRAVERSE_BY_FUNCTION;
    TraversalFunc[T_COMOBJ] = TraversePRecord;
    TraversalCopyFunc[T_COMOBJ] = CopyPRecord;

    TraversalFunc[T_WPOBJ] = TraverseWPObj;
    TraversalCopyFunc[T_WPOBJ] = CopyWPObj;

    TraversalMethod[T_DATOBJ] = TRAVERSE_NONE;

    TraversalMethod[T_OBJSET] = TRAVERSE_BY_FUNCTION;
    TraversalFunc[T_OBJSET] = TraverseObjSet;
    TraversalCopyFunc[T_OBJSET] = CopyObjSet;

    TraversalMethod[T_OBJMAP] = TRAVERSE_BY_FUNCTION;
    TraversalFunc[T_OBJMAP] = TraverseObjMap;
    TraversalCopyFunc[T_OBJMAP] = CopyObjMap;
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
    traversal->previousTraversal = currentTraversal();
    TLS(traversalState) = traversal;
}

static void EndTraversal(void)
{
    TLS(traversalState) = currentTraversal()->previousTraversal;
}

static void TraversalRehash(TraversalState * traversal);

static int SeenDuringTraversal(Obj obj)
{
    TraversalState * traversal = currentTraversal();
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

static UInt FindTraversedObj(Obj obj)
{
    TraversalState * traversal = currentTraversal();
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
        Obj obj = ADDR_OBJ(oldlist)[i];
        if (obj != NULL)
            SeenDuringTraversal(obj);
    }
}

void QueueForTraversal(Obj obj)
{
    int              i;
    TraversalState * traversal;
    if (!IS_BAG_REF(obj))
        return; /* skip ojects that aren't bags */
    traversal = currentTraversal();
    if (!traversal->traversalCheck(obj))
        return;
    if (!SeenDuringTraversal(obj))
        return; /* don't revisit objects that we've already seen */
    if (traversal->listSize == traversal->listCapacity) {
        unsigned oldcapacity = traversal->listCapacity;
        unsigned newcapacity =
            oldcapacity * 25 / 16; /* 25/16 < golden ratio */
        Obj oldlist = traversal->list;
        Obj list = NewList(newcapacity);
        for (i = 1; i <= oldcapacity; i++)
            ADDR_OBJ(list)[i] = ADDR_OBJ(oldlist)[i];
        traversal->list = list;
        traversal->listCapacity = newcapacity;
    }
    ADDR_OBJ(traversal->list)[++traversal->listSize] = obj;
}

void TraverseRegionFrom(TraversalState * traversal,
                        Obj              obj,
                        int (*traversalCheck)(Obj))
{
    if (!IS_BAG_REF(obj) || !REGION(obj) || !CheckReadAccess(obj)) {
        traversal->list = NewList(0);
        return;
    }
    traversal->traversalCheck = traversalCheck;
    traversal->region = REGION(obj);
    QueueForTraversal(obj);
    while (traversal->listCurrent < traversal->listSize) {
        Obj current = ADDR_OBJ(traversal->list)[++traversal->listCurrent];
        int tnum = TNUM_BAG(current);
        const TraversalMethodEnum method = TraversalMethod[TNUM_BAG(current)];
        int                       size;
        Obj *                     ptr;
        switch (method) {
        case TRAVERSE_BY_FUNCTION:
            TraversalFunc[tnum](current);
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
                QueueForTraversal(*ptr);
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

static int IsSameRegion(Obj obj)
{
    return REGION(obj) == currentTraversal()->region;
}

static int IsMutable(Obj obj)
{
    return CheckReadAccess(obj) && IS_MUTABLE_OBJ(obj);
}

static int IsWritableOrImmutable(Obj obj)
{
    int writable = CheckExclusiveWriteAccess(obj);
    if (!writable && IS_MUTABLE_OBJ(obj)) {
        currentTraversal()->border = 1;
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
    traversal.traversalCheck = IsSameRegion;
    TraverseRegionFrom(&traversal, obj, IsSameRegion);
    EndTraversal();
    return traversal.list;
}

static Obj CopyBag(Obj copy, Obj original)
{
    UInt                      size = SIZE_BAG(original);
    UInt                      type = TNUM_BAG(original);
    const TraversalMethodEnum method = TraversalMethod[type];
    Obj *                     ptr = ADDR_OBJ(copy);
    memcpy(ptr, ADDR_OBJ(original), size);

    switch (method) {
    case TRAVERSE_BY_FUNCTION:
        TraversalCopyFunc[type](copy, original);
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
            *ptr = ReplaceByCopy(*ptr);
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
    switch (TNUM_OBJ(obj)) {
    case T_STRING:
        return 1;
    }
    BeginTraversal(&traversal);
    traversal.border = 0;
    TraverseRegionFrom(&traversal, obj, IsWritableOrImmutable);
    EndTraversal();
    return !traversal.border;
}

Obj CopyReachableObjectsFrom(Obj obj, int delimited, int asList, int imm)
{
    Obj *          traversed, *copies, copyList;
    TraversalState traversal;
    UInt           len, i;
    if (!IS_BAG_REF(obj) || REGION(obj) == NULL) {
        if (asList) {
            copyList = NewList(1);
            SET_ELM_PLIST(copyList, 1, obj);
            return copyList;
        }
        else
            return obj;
    }
    BeginTraversal(&traversal);
    if (imm) {
        if (!IS_MUTABLE_OBJ(obj))
            return obj;
        TraverseRegionFrom(&traversal, obj, IsMutable);
    }
    else
        TraverseRegionFrom(&traversal, obj, IsSameRegion);
    traversed = ADDR_OBJ(traversal.list);
    len = LEN_PLIST(traversal.list);
    copyList = NewList(len);
    copies = ADDR_OBJ(copyList);
    traversal.border = delimited;
    if (len == 0) {
        EndTraversal();
        if (delimited)
            return GetRegionOf(obj)->obj;
        ErrorQuit("Object not in a readable region", 0L, 0L);
    }
    traversal.copyMap = NewList(LEN_PLIST(traversal.hashTable));
    for (i = 1; i <= len; i++) {
        UInt loc = FindTraversedObj(traversed[i]);
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
            CopyBag(copies[i], traversed[i]);
    EndTraversal();
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
    Obj            copyList, *copies, *traversed;
    TraversalState traversal;
    UInt           len, i;
    traversed = ADDR_OBJ(traversedList);
    BeginTraversal(&traversal);
    len = LEN_PLIST(traversedList);
    if (len == 1) {
        Obj obj = traversed[1];
        if (!IS_BAG_REF(obj) || REGION(obj) == NULL)
            return obj;
    }
    for (i = 1; i <= len; i++)
        SeenDuringTraversal(traversed[i]);
    copyList = NewList(len);
    copies = ADDR_OBJ(copyList);
    traversal.copyMap = NewList(LEN_PLIST(traversal.hashTable));
    for (i = 1; i <= len; i++) {
        Obj  original = traversed[i];
        UInt loc = FindTraversedObj(original);
        Obj  copy;
        copy = NewBag(TNUM_BAG(original), SIZE_BAG(original));
        SET_ELM_PLIST(traversal.copyMap, loc, copy);
        copies[i] = copy;
    }
    for (i = 1; i <= len; i++)
        CopyBag(copies[i], traversed[i]);
    EndTraversal();
    return copies[1];
}

#endif
