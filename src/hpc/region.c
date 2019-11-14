/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "hpc/region.h"

#ifdef USE_BOEHM_GC
#include "boehm_gc.h"
#endif
#include "gasman.h"
#include "objects.h"

// #include "hpc/misc.h"
#include "hpc/thread.h"
#include "hpc/guards.h"


#include <pthread.h>


static void LockFinalizer(void * lock, void * data)
{
    pthread_rwlock_destroy(lock);
}

Region * NewRegion(void)
{
    Region *           result;
    pthread_rwlock_t * lock;
    Obj                region_obj;
#ifdef DISABLE_GC
    result = calloc(1, sizeof(Region) + (MAX_THREADS + 1));
    lock = malloc(sizeof(*lock));
#elif defined(USE_BOEHM_GC)
    result = GC_malloc(sizeof(Region) + (MAX_THREADS + 1));
    lock = GC_malloc_atomic(sizeof(*lock));
    GC_register_finalizer(lock, LockFinalizer, NULL, NULL, NULL);
#else
    #error Not yet implemented for this garbage collector
#endif
    pthread_rwlock_init(lock, NULL);
    region_obj = NewBag(T_REGION, sizeof(Region *));
    MakeBagPublic(region_obj);
    *(Region **)(PTR_BAG(region_obj)) = result;
    result->obj = region_obj;
    result->lock = lock;
    return result;
}

Region * RegionBag(Bag bag)
{
    Region * result = REGION(bag);
    MEMBAR_READ();
    return result;
}

Bag MakeBagPublic(Bag bag)
{
    MEMBAR_WRITE();
    SET_REGION(bag, 0);
    return bag;
}

Bag MakeBagReadOnly(Bag bag)
{
    MEMBAR_WRITE();
    SET_REGION(bag, ReadOnlyRegion);
    return bag;
}

void RetypeBagIfWritable(Obj obj, UInt new_type)
{
    if (CheckWriteAccess(obj))
        RetypeBag(obj, new_type);
}
