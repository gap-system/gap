/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_REGION_H
#define GAP_REGION_H

#include "common.h"

#ifndef HPCGAP
#error This header is only meant to be used with HPC-GAP
#endif

#include "hpc/atomic.h"

typedef struct Region Region;

struct Region {
    void *lock;       /* void * so that we don't have to include pthread.h always */
    Bag obj;          /* references a unique T_REGION object per region */
    Bag name;         /* name of the region, or a null pointer */
    Int prec;         /* locking precedence */
    int fixed_owner;
    void *owner;      /* opaque thread descriptor */
    void *alt_owner;  /* for paused threads */
    int count_active; /* whether we counts number of (contended) locks */
    AtomicUInt locks_acquired;    /* number of times the lock was acquired successfully */
    AtomicUInt locks_contended;   /* number of failed attempts at acuiring the lock */
    unsigned char readers[];     /* this field extends with number of threads
                                     don't add any fields after it */
};

/****************************************************************************
**
*F  NewRegion() . . . . . . . . . . . . . . . . allocate a new region
*/

Region *NewRegion(void);

/****************************************************************************
**
*F  REGION(<bag>)  . . . . . . . .  return the region containing the bag
*F  RegionBag(<bag>)   . . . . . .  return the region containing the bag
**
**  RegionBag() also contains a memory barrier.
*/
EXPORT_INLINE Region * REGION(Obj bag)
{
    return ((Region **)bag)[1];
}

EXPORT_INLINE void SET_REGION(Obj bag, Region * region)
{
    ((Region **)bag)[1] = region;
}

Region *RegionBag(Bag bag);

#endif // GAP_REGION_H
