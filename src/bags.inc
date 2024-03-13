/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
** This file includes functions which are required by all GCs. For efficiency
** it is important these are defined in the same file as "MarkBag", so
** this file should be #included in each GC implementation.
*/

#include "error.h"
#include "gasman.h"

void MarkArrayOfBags(const Bag array[], UInt count, void * ref)
{
    for (UInt i = 0; i < count; i++) {
        MarkBag(array[i], ref);
    }
}

void MarkNoSubBags(Bag bag, void * ref)
{
}

void MarkOneSubBags(Bag bag, void * ref)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), 1, ref);
}

void MarkTwoSubBags(Bag bag, void * ref)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), 2, ref);
}

void MarkThreeSubBags(Bag bag, void * ref)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), 3, ref);
}

void MarkFourSubBags(Bag bag, void * ref)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), 4, ref);
}

void MarkAllSubBags(Bag bag, void * ref)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), SIZE_BAG(bag) / sizeof(Bag), ref);
}

void MarkAllButFirstSubBags(Bag bag, void * ref)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag) + 1, SIZE_BAG(bag) / sizeof(Bag) - 1, ref);
}
