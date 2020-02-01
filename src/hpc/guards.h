/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_HPC_GUARD_H
#define GAP_HPC_GUARD_H

#include "gasman.h"
#include "hpc/region.h"
#include "hpc/tls.h"

#ifndef HPCGAP
#error This header is only meant to be used with HPC-GAP
#endif

static ALWAYS_INLINE Bag WriteGuard(Bag bag)
{
    if (!WriteCheck(bag))
        HandleWriteGuardError(bag);
    return bag;
}


EXPORT_INLINE int CheckWriteAccess(Bag bag)
{
    Region * region;
    if (!IS_BAG_REF(bag))
        return 1;
    region = REGION(bag);
    return !(region && region->owner != GetTLS() &&
             region->alt_owner != GetTLS()) ||
           TLS(DisableGuards) >= 2;
}

EXPORT_INLINE int CheckExclusiveWriteAccess(Bag bag)
{
    Region * region;
    if (!IS_BAG_REF(bag))
        return 1;
    region = REGION(bag);
    if (!region)
        return 0;
    return region->owner == GetTLS() || region->alt_owner == GetTLS() ||
           TLS(DisableGuards) >= 2;
}

static ALWAYS_INLINE Bag ReadGuard(Bag bag)
{
    if (!ReadCheck(bag))
        HandleReadGuardError(bag);
    return bag;
}

static ALWAYS_INLINE int CheckReadAccess(Bag bag)
{
    Region * region;
    if (!IS_BAG_REF(bag))
        return 1;
    region = REGION(bag);
    return !(region && region->owner != GetTLS() &&
             !region->readers[TLS(threadID)] &&
             region->alt_owner != GetTLS()) ||
           TLS(DisableGuards) >= 2;
}

#endif    // GAP_HPC_GUARD_H
