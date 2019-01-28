/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_PERMUTAT_INTERN_H
#define GAP_PERMUTAT_INTERN_H

#include "objects.h"


//
// Various helper functions for permutations
//
template <typename T>
struct T_PERM {
};
template <>
struct T_PERM<UInt2> {
    static const UInt tnum = T_PERM2;
};
template <>
struct T_PERM<UInt4> {
    static const UInt tnum = T_PERM4;
};

template <typename T>
static void ASSERT_IS_PERM(Obj perm)
{
    GAP_ASSERT(TNUM_OBJ(perm) == T_PERM<T>::tnum);
}

template <typename T>
static inline UInt SIZEBAG_PERM(UInt deg)
{
    return sizeof(Obj) + deg * sizeof(T);
}

template <typename T>
static inline Obj NEW_PERM(UInt deg)
{
    return NewBag(T_PERM<T>::tnum, SIZEBAG_PERM<T>(deg));
}

template <typename T>
static inline UInt DEG_PERM(Obj perm)
{
    ASSERT_IS_PERM<T>(perm);
    return (SIZE_OBJ(perm) - sizeof(Obj)) / sizeof(T);
}

template <typename T>
static inline T * ADDR_PERM(Obj perm)
{
    ASSERT_IS_PERM<T>(perm);
    return (T *)(ADDR_OBJ(perm) + 1);
}

template <typename T>
static inline const T * CONST_ADDR_PERM(Obj perm)
{
    ASSERT_IS_PERM<T>(perm);
    return (const T *)(CONST_ADDR_OBJ(perm) + 1);
}


//
// The 'ResultType' template is used by functions which take two permutations,
// partial permutations or transformations as arguments to select the size of
// the output they produce: by default, entries are stored  as UInt4. But if
// both inputs are T_PERM2, T_PPERM2 resp. T_TRANS2,, then as a special case
// the output entries are stored as UInt2.
//
template <typename TL, typename TR>
struct ResultType {
    typedef UInt4 type;
};
template <>
struct ResultType<UInt2, UInt2> {
    typedef UInt2 type;
};

#endif
