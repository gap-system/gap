/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_PPERM_H
#define GAP_PPERM_H

#include "objects.h"

EXPORT_INLINE BOOL IS_PPERM(Obj f)
{
    return (TNUM_OBJ(f) == T_PPERM2 || TNUM_OBJ(f) == T_PPERM4);
}

Obj NEW_PPERM2(UInt deg);

EXPORT_INLINE UInt2 * ADDR_PPERM2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    return ((UInt2 *)((Obj *)(ADDR_OBJ(f)) + 2) + 1);
}

EXPORT_INLINE const UInt2 * CONST_ADDR_PPERM2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    return ((const UInt2 *)((const Obj *)(CONST_ADDR_OBJ(f)) + 2) + 1);
}

EXPORT_INLINE UInt DEG_PPERM2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    return ((UInt)(SIZE_OBJ(f) - sizeof(UInt2) - 2 * sizeof(Obj)) /
            sizeof(UInt2));
}

UInt CODEG_PPERM2(Obj f);
UInt RANK_PPERM2(Obj f);

Obj NEW_PPERM4(UInt deg);

EXPORT_INLINE UInt4 * ADDR_PPERM4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    return ((UInt4 *)((Obj *)(ADDR_OBJ(f)) + 2) + 1);
}

EXPORT_INLINE const UInt4 * CONST_ADDR_PPERM4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    return ((const UInt4 *)((const Obj *)(CONST_ADDR_OBJ(f)) + 2) + 1);
}

EXPORT_INLINE UInt DEG_PPERM4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    return ((UInt)(SIZE_OBJ(f) - sizeof(UInt4) - 2 * sizeof(Obj)) /
            sizeof(UInt4));
}

UInt CODEG_PPERM4(Obj f);
UInt RANK_PPERM4(Obj f);

EXPORT_INLINE UInt DEG_PPERM(Obj f)
{
    GAP_ASSERT(IS_PPERM(f));
    return (TNUM_OBJ(f) == T_PPERM2 ? DEG_PPERM2(f) : DEG_PPERM4(f));
}

EXPORT_INLINE UInt CODEG_PPERM(Obj f)
{
    GAP_ASSERT(IS_PPERM(f));
    return (TNUM_OBJ(f) == T_PPERM2 ? CODEG_PPERM2(f) : CODEG_PPERM4(f));
}

EXPORT_INLINE UInt RANK_PPERM(Obj f)
{
    GAP_ASSERT(IS_PPERM(f));
    return (TNUM_OBJ(f) == T_PPERM2 ? RANK_PPERM2(f) : RANK_PPERM4(f));
}

/****************************************************************************
**
*F  OnTuplesPPerm( <tup>, <f> )  . . . .  operations on tuples of points
**
**  'OnTuplesPPerm'  returns  the  image  of  the  tuple  <tup>   under  the
**  PPerm <f>.
*/

Obj OnTuplesPPerm(Obj set, Obj f);

/****************************************************************************
**
*F  OnSetsPPerm( <set>, <f> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsPPerm' returns the  image of the  tuple <set> under the
**  partial perm <f>.
*/

Obj OnSetsPPerm(Obj set, Obj f);

/****************************************************************************
**
*F  HashFuncForPPerm( <f> ) . . . hash pperm
**
**  Returns a hash value for a partial permutation
*/

Int HashFuncForPPerm(Obj f);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoPPerm() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPPerm(void);

#endif    // GAP_PPERM_H
