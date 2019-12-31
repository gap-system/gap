/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_FIBHASH_H
#define GAP_FIBHASH_H

#include "common.h"

enum {
    FIB_HASH_BITS = sizeof(void *) * 8,
};

EXPORT_INLINE UInt FibHash(UInt word, unsigned bits)
{
    const UInt FIB_HASH_MULT = (FIB_HASH_BITS == 64) ? 0x9e3779b97f4a7c13UL : 0x9e3779b9UL;
    return (word * FIB_HASH_MULT) >> (FIB_HASH_BITS - bits);
}

#endif // GAP_FIBHASH_H
