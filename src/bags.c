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
#include "objects.h"    // HACK: for FIRST_IMM_MUT_TNUM; remove this later

/****************************************************************************
**
*V  InfoBags[<type>]  . . . . . . . . . . . . . . . . .  information for bags
*/
#ifdef COUNT_BAGS
TNumInfoBags InfoBags[NUM_TYPES];
#endif


UInt8 SizeAllBags;


#ifdef GAP_KERNEL_DEBUG
void PrecheckRetypeBag(Bag bag, UInt new_type)
{
    // If the new type contains an (im)mutability bit, verify that this does
    // not remove mutability from an object that was previously mutable --
    // something we generally don't allow
    if (FIRST_IMM_MUT_TNUM <= new_type && new_type <= LAST_IMM_MUT_TNUM) {
#if !defined(USE_THREADSAFE_COPYING)
        // HACK: T_COPYING is used for mutable and immutable objects alike, so
        // we can't really determine whether it is "mutable" or not. In
        // fact, it is not even a "real" TNUM (it comes after LAST_REAL_TNUM),
        // so asking such an object for mutability is not even supported.
        //
        // In the future, there are at least two ways we could get rid of this
        // hack: Either we drop T_COPYING by adopting the copying code from
        // HPC-GAP for regular GAP as well. Or we could add an
        // IMMUTABLE_OBJ_FLAG which can be used to mark any object as
        // immutable, including T_COPYING objects.
        if (TNUM_BAG(bag) == T_COPYING)
            return;
#endif

        // Some GAP code and packages (including EDIM) produce invalid
        // T_DATOBJ objects without correct type info, so skip T_DATOBJ for now
        if (IS_DATOBJ(bag))
            return;

#ifndef HPCGAP
        // HACK: when using `DeclareGlobalVariable`, the placeholder object of
        // type `IsToBeDefinedObj` is immutable, while `InstallValue` also
        // accepts mutable values, which are then copied into the placeholder
        // *bag* itself, thus turning the placeholder (which is a T_POSOBJ)
        // into any different kind of bag, including mutable ones.
        if (TNUM_BAG(bag) == T_POSOBJ)
            return;
#endif
    }
}
#endif


// TODO: perhaps this should become RetypeObj ?
void RetypeBagSM(Bag bag, UInt new_type)
{
    RetypeBag(bag, new_type);
}

#ifdef HPCGAP
void RetypeBagSMIfWritable(Bag bag, UInt new_type)
{
    RetypeBagIfWritable(bag, new_type);
}
#endif
