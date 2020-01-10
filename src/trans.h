/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_TRANS_H
#define GAP_TRANS_H

#include "objects.h"

EXPORT_INLINE BOOL IS_TRANS(Obj f)
{
    return (TNUM_OBJ(f) == T_TRANS2 || TNUM_OBJ(f) == T_TRANS4);
}

EXPORT_INLINE Obj NEW_TRANS2(UInt deg)
{
    GAP_ASSERT(deg <= 65536);
    return NewBag(T_TRANS2, deg * sizeof(UInt2) + 3 * sizeof(Obj));
}

EXPORT_INLINE UInt2 * ADDR_TRANS2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS2);
    return (UInt2 *)(ADDR_OBJ(f) + 3);
}

EXPORT_INLINE const UInt2 * CONST_ADDR_TRANS2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS2);
    return (const UInt2 *)(CONST_ADDR_OBJ(f) + 3);
}

EXPORT_INLINE UInt DEG_TRANS2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS2);
    return ((UInt)(SIZE_OBJ(f) - 3 * sizeof(Obj)) / sizeof(UInt2));
}

UInt RANK_TRANS2(Obj f);

EXPORT_INLINE Obj NEW_TRANS4(UInt deg)
{
    // No assert here since we allow creating new T_TRANS4's when the degree
    // is low enough to fit in a T_TRANS2.
    return NewBag(T_TRANS4, deg * sizeof(UInt4) + 3 * sizeof(Obj));
}

EXPORT_INLINE UInt4 * ADDR_TRANS4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS4);
    return (UInt4 *)(ADDR_OBJ(f) + 3);
}

EXPORT_INLINE const UInt4 * CONST_ADDR_TRANS4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS4);
    return (const UInt4 *)(CONST_ADDR_OBJ(f) + 3);
}

EXPORT_INLINE UInt DEG_TRANS4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS4);
    return ((UInt)(SIZE_OBJ(f) - 3 * sizeof(Obj)) / sizeof(UInt4));
}

UInt RANK_TRANS4(Obj f);

EXPORT_INLINE Obj NEW_TRANS(UInt deg)
{
    if (deg < 65536) {
        return NEW_TRANS2(deg);
    }
    else {
        return NEW_TRANS4(deg);
    }
}

EXPORT_INLINE UInt DEG_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return (TNUM_OBJ(f) == T_TRANS2 ? DEG_TRANS2(f) : DEG_TRANS4(f));
}

EXPORT_INLINE UInt RANK_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return (TNUM_OBJ(f) == T_TRANS2 ? RANK_TRANS2(f) : RANK_TRANS4(f));
}

/****************************************************************************
**
*F  OnTuplesTrans( <tup>, <f> )  . . . .  operations on tuples of points
**
**  'OnTuplesTrans'  returns  the  image  of  the  tuple  <tup>   under  the
**  transformation <f>.
*/
Obj OnTuplesTrans(Obj tup, Obj f);

/****************************************************************************
**
*F  OnSetsTrans( <set>, <f> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsTrans' returns the  image of the  tuple <set> under the
**  transformation <f>.
*/
Obj OnSetsTrans(Obj set, Obj f);


/****************************************************************************
**
*F  HashFuncForTrans( <f> ) . . . hash transformation
**
**  Returns a hash value for a transformation
*/
Int HashFuncForTrans(Obj f);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoTrans() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoTrans(void);

#endif    // GAP_TRANS_H
