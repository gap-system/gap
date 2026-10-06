/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "error.h"
#include "gasman.h"
#include "objects.h"

#ifdef HPCGAP
#include "hpc/guards.h"
#endif

/****************************************************************************
**
*V  InfoBags[<type>]  . . . . . . . . . . . . . . . . .  information for bags
*/
#ifdef COUNT_BAGS
TNumInfoBags InfoBags[NUM_TYPES];
#endif


UInt8 SizeAllBags;


// An object which records its mutability in its type, such as a compressed
// vector, needs the flag once it turns into a list or record.
static void KeepMutability(Bag bag, UInt new_type)
{
    if (new_type < FIRST_IMM_MUT_TNUM || LAST_IMM_MUT_TNUM < new_type)
        return;
    if (!IS_MUTABLE_OBJ(bag))
        SET_OBJ_FLAG(bag, OBJ_FLAG_IMMUTABLE);
}

// TODO: perhaps this should become RetypeObj ?
void RetypeBagSM(Bag bag, UInt new_type)
{
    KeepMutability(bag, new_type);
    RetypeBag(bag, new_type);
}

#ifdef HPCGAP
void RetypeBagSMIfWritable(Bag bag, UInt new_type)
{
    if (!CheckWriteAccess(bag))
        return;
    KeepMutability(bag, new_type);
    RetypeBag(bag, new_type);
}
#endif
