/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

/*****************************************************************************
*
* A transformation <f> has internal representation as follows:
*
* [Obj* image set, Obj* flat kernel, Obj* external degree,
*  entries image list]
*
* The <internal degree> of <f> is just the length of <entries image
* list>, this is accessed here using <DEG_TRANS2> and <DEG_TRANS4>.
*
* Transformations must always have internal degree greater than or equal
* to the largest point in <entries image list>.
*
* An element of <entries image list> of a transformation in T_TRANS2
* must be at most 65535 and be UInt2. Hence the internal and external
* degrees of a T_TRANS2 are at most 65536. If <f> is T_TRANS4, then the
* elements of <entries image list> must be UInt4.
*
* The <image set> and <flat kernel> are found relative to the internal
* degree of the transformation, and must not be changed after they are
* first found.
*
* The <external degree> is the largest non-negative integer <n> such
* that n ^ f != n or i ^ f = n  for some i != n, or equivalently the
* degree of a transformation is the least non-negative <n> such that [n
* + 1, n + 2, .. ] is fixed pointwise by <f>. This value is an invariant
* of <f>, in the sense that it does not depend on the internal
* representation. In GAP, DegreeOfTransformation(f) returns the external
* degree, so that if f = g, then DegreeOfTransformation(f) =
* DegreeOfTransformation(g).
*
* In this file, the external degree of a transformation is accessed
* using FuncDegreeOfTransformation(self, f), and the internal degree is
* accessed using DEG_TRANS2/4(f).
*
*****************************************************************************/

extern "C" {

#include "trans.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "gapstate.h"
#include "gvars.h"
#include "integer.h"
#include "intfuncs.h"
#include "listfunc.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "permutat.h"
#include "plist.h"
#include "saveload.h"

#include <stdio.h>

} // extern "C"

#include "permutat_intern.hh"


//
// convert TNUM to underlying C data type
//
template <UInt tnum>
struct DataType;

template <>
struct DataType<T_TRANS2> {
    typedef UInt2 type;
};
template <>
struct DataType<T_TRANS4> {
    typedef UInt4 type;
};


//
// convert underlying C data type to TNUM
//
template <typename T>
struct T_TRANS {
};
template <>
struct T_TRANS<UInt2> {
    static const UInt tnum = T_TRANS2;
};
template <>
struct T_TRANS<UInt4> {
    static const UInt tnum = T_TRANS4;
};


//
// Various helper functions for partial permutations
//
template <typename T>
static void ASSERT_IS_TRANS(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS<T>::tnum);
}

template <typename T>
static inline Obj NEW_TRANS(UInt deg)
{
    return NewBag(T_TRANS<T>::tnum, deg * sizeof(T) + 3 * sizeof(Obj));
}

template <typename T>
static inline T * ADDR_TRANS(Obj f)
{
    ASSERT_IS_TRANS<T>(f);
    return (T *)(ADDR_OBJ(f) + 3);
}

template <typename T>
static inline const T * CONST_ADDR_TRANS(Obj f)
{
    ASSERT_IS_TRANS<T>(f);
    return (const T *)(CONST_ADDR_OBJ(f) + 3);
}

template <typename T>
static inline UInt DEG_TRANS(Obj f)
{
    ASSERT_IS_TRANS<T>(f);
    return (UInt)(SIZE_OBJ(f) - 3 * sizeof(Obj)) / sizeof(T);
}


#define MIN(a, b) (a < b ? a : b)
#define MAX(a, b) (a < b ? b : a)

#define RequireTransformation(funcname, op)                                  \
    RequireArgumentCondition(funcname, op, IS_TRANS(op),                     \
                             "must be a transformation")


/****************************************************************************
**
*F  GetPositiveListEntryEx, GetPositiveListEntry
**
**  Extract list[idx] and check that it is a positive small integer; if so,
**  return that integer; otherwise raise an error.
*/
static Int GetPositiveListEntryEx(const char * funcname,
                           Obj          list,
                           Int          idx,
                           const char * argname)
{
    Obj value = ELM_LIST(list, idx);
    if (!IS_POS_INTOBJ(value)) {
        char buf[1024];
        snprintf(buf, sizeof(buf), "%s[%d]", argname, (int)idx);
        buf[sizeof(buf) - 1] = '\0';
        RequireArgumentEx(funcname, value, buf,
                          "must be a positive small integer");
    }
    return INT_INTOBJ(value);
}

#define GetPositiveListEntry(funcname, list, idx)                            \
    GetPositiveListEntryEx(funcname, list, idx, NICE_ARGNAME(list))


static ModuleStateOffset TransStateOffset = -1;

typedef struct {
    // TmpTrans is essentially the same as TmpPerm
    Obj TmpTrans;
} TransModuleState;

static inline Obj GetTmpTrans(void)
{
    return MODULE_STATE(Trans).TmpTrans;
}

static inline UInt4 * AddrTmpTrans(void)
{
    return ADDR_TRANS4(GetTmpTrans());
}


/****************************************************************************
**
*V  IdentityTrans  . . . . . . . . . . . . . . . . .  identity transformation
**
**  'IdentityTrans' is an identity transformation.
*/
/* mp this will become a ReadOnly object? */
static Obj IdentityTrans;

/*******************************************************************************
** Forward declarations
*******************************************************************************/

static Obj FuncIMAGE_SET_TRANS(Obj self, Obj f);

/*******************************************************************************
** Internal functions for transformations
*******************************************************************************/

static inline Obj IMG_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return CONST_ADDR_OBJ(f)[0];
}

static inline Obj KER_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return CONST_ADDR_OBJ(f)[1];
}

static inline Obj EXT_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return CONST_ADDR_OBJ(f)[2];
}

static inline void SET_IMG_TRANS(Obj f, Obj img)
{
    GAP_ASSERT(IS_TRANS(f));
    GAP_ASSERT(img == NULL || (IS_PLIST(img) && !IS_PLIST_MUTABLE(img)));
    ADDR_OBJ(f)[0] = img;
}

static inline void SET_KER_TRANS(Obj f, Obj ker)
{
    GAP_ASSERT(IS_TRANS(f));
    GAP_ASSERT(ker == NULL || (IS_PLIST(ker) && !IS_PLIST_MUTABLE(ker) &&
                               LEN_PLIST(ker) == DEG_TRANS(f)));
    ADDR_OBJ(f)[1] = ker;
}

static inline void SET_EXT_TRANS(Obj f, Obj deg)
{
    GAP_ASSERT(IS_TRANS(f));
    GAP_ASSERT(deg == NULL ||
               (IS_INTOBJ(deg) && INT_INTOBJ(deg) <= DEG_TRANS(f)));
    ADDR_OBJ(f)[2] = deg;
}

static inline void ResizeTmpTrans(UInt len)
{
    Obj tmpTrans = GetTmpTrans();
    if (tmpTrans == (Obj)0) {
        MODULE_STATE(Trans).TmpTrans = NewBag(T_TRANS4, len * sizeof(UInt4) + 3 * sizeof(Obj));
    }
    else if (SIZE_OBJ(tmpTrans) < len * sizeof(UInt4) + 3 * sizeof(Obj)) {
        ResizeBag(tmpTrans, len * sizeof(UInt4) + 3 * sizeof(Obj));
    }
}

static inline UInt4 * ResizeInitTmpTrans(UInt len)
{
    ResizeTmpTrans(len);

    UInt4 * pttmp = AddrTmpTrans();
    memset(pttmp, 0, len * sizeof(UInt4));
    return pttmp;
}

// Find the rank, flat kernel, and image set (unsorted) of a transformation of
// degree at most 65536.

static UInt INIT_TRANS2(Obj f)
{
    UInt    deg, rank, i, j;
    const UInt2 * ptf;
    UInt4 * pttmp;
    Obj     img, ker;

    deg = DEG_TRANS2(f);

    if (deg == 0) {
        // special case for degree 0
        img = NewImmutableEmptyPlist();
        SET_IMG_TRANS(f, img);
        SET_KER_TRANS(f, img);
        CHANGED_BAG(f);
        return 0;
    }

    img = NEW_PLIST_IMM(T_PLIST_CYC, deg);
    ker = NEW_PLIST_IMM(T_PLIST_CYC_NSORT, deg);
    SET_LEN_PLIST(ker, (Int)deg);

    pttmp = ResizeInitTmpTrans(deg);
    ptf = CONST_ADDR_TRANS2(f);

    rank = 0;
    for (i = 0; i < deg; i++) {
        j = ptf[i];
        if (pttmp[j] == 0) {
            pttmp[j] = ++rank;
            SET_ELM_PLIST(img, rank, INTOBJ_INT(j + 1));
        }
        SET_ELM_PLIST(ker, i + 1, INTOBJ_INT(pttmp[j]));
    }

    SHRINK_PLIST(img, (Int)rank);
    SET_LEN_PLIST(img, (Int)rank);

    SET_IMG_TRANS(f, img);
    SET_KER_TRANS(f, ker);
    CHANGED_BAG(f);
    return rank;
}

// Find the rank, flat kernel, and image set (unsorted) of a transformation of
// degree at least 65537.

static UInt INIT_TRANS4(Obj f)
{
    UInt    deg, rank, i, j;
    const UInt4 * ptf;
    UInt4 * pttmp;
    Obj     img, ker;

    deg = DEG_TRANS4(f);

    if (deg == 0) {
        // Special case for degree 0.

        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        img = NewImmutableEmptyPlist();
        SET_IMG_TRANS(f, img);
        SET_KER_TRANS(f, img);
        CHANGED_BAG(f);
        return 0;
    }

    img = NEW_PLIST_IMM(T_PLIST_CYC, deg);
    ker = NEW_PLIST_IMM(T_PLIST_CYC_NSORT, deg);
    SET_LEN_PLIST(ker, (Int)deg);

    pttmp = ResizeInitTmpTrans(deg);
    ptf = CONST_ADDR_TRANS4(f);

    rank = 0;
    for (i = 0; i < deg; i++) {
        j = ptf[i];
        if (pttmp[j] == 0) {
            pttmp[j] = ++rank;
            SET_ELM_PLIST(img, rank, INTOBJ_INT(j + 1));
        }
        SET_ELM_PLIST(ker, i + 1, INTOBJ_INT(pttmp[j]));
    }

    SHRINK_PLIST(img, (Int)rank);
    SET_LEN_PLIST(img, (Int)rank);

    SET_IMG_TRANS(f, img);
    SET_KER_TRANS(f, ker);
    CHANGED_BAG(f);
    return rank;
}

static UInt INIT_TRANS(Obj f)
{
   return (TNUM_OBJ(f) == T_TRANS2) ? INIT_TRANS2(f) : INIT_TRANS4(f);

}


UInt RANK_TRANS2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS2);
    return (IMG_TRANS(f) == NULL ? INIT_TRANS2(f) : LEN_PLIST(IMG_TRANS(f)));
}

UInt RANK_TRANS4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS4);
    return (IMG_TRANS(f) == NULL ? INIT_TRANS4(f) : LEN_PLIST(IMG_TRANS(f)));
}

// Retyping is the responsibility of the caller, this should only be called
// after a call to SortPlistByRawObj.

static void REMOVE_DUPS_PLIST_INTOBJ(Obj res)
{
    Obj  tmp;
    UInt i, k, len;
    Obj  *data;

    len = LEN_PLIST(res);

    if (0 < len) {
        data = ADDR_OBJ(res);
        tmp = data[1];
        k = 1;
        for (i = 2; i <= len; i++) {
            if (tmp != data[i]) {
                k++;
                tmp = data[i];
                data[k] = tmp;
            }
        }
        if (k < len) {
            ResizeBag(res, (k + 1) * sizeof(Obj));
            SET_LEN_PLIST(res, k);
        }
    }
}

/*******************************************************************************
** GAP level functions for creating transformations
*******************************************************************************/

// Returns a transformation with list of images <list>, this does not check
// that <list> is really a list or that its entries define a transformation.

static Obj FuncTransformationNC(Obj self, Obj list)
{
    UInt    i, deg;
    UInt2 * ptf2;
    UInt4 * ptf4;
    Obj     f;

    deg = LEN_LIST(list);

    if (deg <= 65536) {
        f = NEW_TRANS2(deg);
        ptf2 = ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            ptf2[i] = INT_INTOBJ(ELM_LIST(list, i + 1)) - 1;
        }
    }
    else {
        f = NEW_TRANS4(deg);
        ptf4 = ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            ptf4[i] = INT_INTOBJ(ELM_LIST(list, i + 1)) - 1;
        }
    }
    return f;
}

// Returns a transformation that maps <src> to <ran>, this does not check that
// <src> is duplicate-free.

static Obj FuncTransformationListListNC(Obj self, Obj src, Obj ran)
{
    Int     deg, i, s, r;
    Obj     f;
    UInt2 * ptf2;
    UInt4 * ptf4;

    RequireSmallList(SELF_NAME, src);
    RequireSmallList(SELF_NAME, ran);
    RequireSameLength(SELF_NAME, src, ran);

    deg = 0;
    for (i = LEN_LIST(src); 1 <= i; i--) {
        s = GetPositiveListEntry("TransformationListListNC", src, i);
        r = GetPositiveListEntry("TransformationListListNC", ran, i);

        if (s != r) {
            if (s > deg) {
                deg = s;
            }
            if (r > deg) {
                deg = r;
            }
        }
    }

    if (deg <= 65536) {
        f = NEW_TRANS2(deg);
        ptf2 = ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            ptf2[i] = i;
        }
        for (i = LEN_LIST(src); 1 <= i; i--) {
            s = INT_INTOBJ(ELM_LIST(src, i));
            r = INT_INTOBJ(ELM_LIST(ran, i));
            // deg may be smaller than s if s = r
            if (s != r) {
                ptf2[s - 1] = r - 1;
            }
        }
    }
    else {
        f = NEW_TRANS4(deg);
        ptf4 = ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            ptf4[i] = i;
        }
        for (i = LEN_LIST(src); 1 <= i; i--) {
            s = INT_INTOBJ(ELM_LIST(src, i));
            r = INT_INTOBJ(ELM_LIST(ran, i));
            if (s != r) {
                ptf4[s - 1] = r - 1;
            }
        }
    }
    return f;
}

// Returns a transformation with image <img> and flat kernel <ker> under the
// (unchecked) assumption that the arguments are valid and that there is such
// a transformation, i.e.  that the maximum value in <ker> equals the length
// of <img>.

static Obj FuncTRANS_IMG_KER_NC(Obj self, Obj img, Obj ker)
{
    Obj     f, copy_img, copy_ker;
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i, pos, deg;

    copy_img = PLAIN_LIST_COPY(img);
    copy_ker = PLAIN_LIST_COPY(ker);
    MakeImmutableNoRecurse(copy_img);
    MakeImmutableNoRecurse(copy_ker);

    deg = LEN_LIST(copy_ker);

    if (deg <= 65536) {
        f = NEW_TRANS2(deg);
        ptf2 = ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            pos = INT_INTOBJ(ELM_PLIST(copy_ker, i + 1));
            ptf2[i] = INT_INTOBJ(ELM_PLIST(copy_img, pos)) - 1;
        }
    }
    else {
        f = NEW_TRANS4(deg);
        ptf4 = ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            pos = INT_INTOBJ(ELM_PLIST(copy_ker, i + 1));
            ptf4[i] = INT_INTOBJ(ELM_PLIST(copy_img, pos)) - 1;
        }
    }

    SET_IMG_TRANS(f, copy_img);
    SET_KER_TRANS(f, copy_ker);
    CHANGED_BAG(f);

    return f;
}

// Returns an idempotent transformation with image <img> and flat kernel <ker>
// under the (unchecked) assumption that the arguments are valid and that
// there
// is such a transformation, i.e.  that the maximum value in <ker> equals the
// length of <img>.
//
// Note that this does not return the same transformation as TRANS_IMG_KER_NC
// with the same arguments.

static Obj FuncIDEM_IMG_KER_NC(Obj self, Obj img, Obj ker)
{
    Obj     f, copy_img, copy_ker;
    UInt2 * ptf2;
    UInt4 * ptf4, *pttmp;
    UInt    i, j, deg, rank;

    copy_img = PLAIN_LIST_COPY(img);
    copy_ker = PLAIN_LIST_COPY(ker);
    MakeImmutableNoRecurse(copy_img);
    MakeImmutableNoRecurse(copy_ker);

    deg = LEN_LIST(copy_ker);
    rank = LEN_LIST(copy_img);
    ResizeTmpTrans(deg);
    pttmp = AddrTmpTrans();

    // setup the lookup table
    for (i = 0; i < rank; i++) {
        j = INT_INTOBJ(ELM_PLIST(copy_img, i + 1));
        pttmp[INT_INTOBJ(ELM_PLIST(copy_ker, j)) - 1] = j - 1;
    }
    if (deg <= 65536) {
        f = NEW_TRANS2(deg);
        ptf2 = ADDR_TRANS2(f);
        pttmp = AddrTmpTrans();

        for (i = 0; i < deg; i++) {
            ptf2[i] = pttmp[INT_INTOBJ(ELM_PLIST(copy_ker, i + 1)) - 1];
        }
    }
    else {
        f = NEW_TRANS4(deg);
        ptf4 = ADDR_TRANS4(f);
        pttmp = AddrTmpTrans();

        for (i = 0; i < deg; i++) {
            ptf4[i] = pttmp[INT_INTOBJ(ELM_PLIST(copy_ker, i + 1)) - 1];
        }
    }

    SET_IMG_TRANS(f, copy_img);
    SET_KER_TRANS(f, copy_ker);
    CHANGED_BAG(f);
    return f;
}

// Returns an idempotent transformation e with ker(e) = ker(f), where <f> is a
// transformation.

static Obj FuncLEFT_ONE_TRANS(Obj self, Obj f)
{
    Obj  ker, img;
    UInt rank, n, i;

    RequireTransformation(SELF_NAME, f);

    rank = RANK_TRANS(f);
    ker = KER_TRANS(f);
    img = NEW_PLIST(T_PLIST_CYC, rank);
    n = 1;

    for (i = 1; n <= rank; i++) {
        if ((UInt)INT_INTOBJ(ELM_PLIST(ker, i)) == n) {
            SET_ELM_PLIST(img, n++, INTOBJ_INT(i));
        }
    }

    SET_LEN_PLIST(img, (Int)n - 1);
    return FuncIDEM_IMG_KER_NC(self, img, ker);
}

// Returns an idempotent transformation e with im(e) = im(f), where <f> is a
// transformation.

static Obj FuncRIGHT_ONE_TRANS(Obj self, Obj f)
{
    Obj  ker, img;
    UInt deg, len, i, j, n;

    RequireTransformation(SELF_NAME, f);

    deg = DEG_TRANS(f);
    img = FuncIMAGE_SET_TRANS(self, f);
    ker = NEW_PLIST(T_PLIST_CYC, deg);
    SET_LEN_PLIST(ker, deg);
    len = LEN_PLIST(img);
    j = 1;
    n = 0;

    for (i = 0; i < deg; i++) {
        if (j < len && i + 1 == (UInt)INT_INTOBJ(ELM_PLIST(img, j + 1))) {
            j++;
        }
        SET_ELM_PLIST(ker, ++n, INTOBJ_INT(j));
    }
    return FuncIDEM_IMG_KER_NC(self, img, ker);
}

/*******************************************************************************
** GAP level functions for degree and rank of transformations
*******************************************************************************/

// Returns the degree of the transformation <f>, i.e. the least value <n> such
// that <f> fixes [n + 1, n + 2, .. ].

static Obj FuncDegreeOfTransformation(Obj self, Obj f)
{
    UInt    n, i, deg;
    const UInt2 * ptf2;
    const UInt4 * ptf4;

    RequireTransformation(SELF_NAME, f);

    if (EXT_TRANS(f) == NULL) {
        n = DEG_TRANS(f);
        if (TNUM_OBJ(f) == T_TRANS2) {
            ptf2 = CONST_ADDR_TRANS2(f);
            if (ptf2[n - 1] != n - 1) {
                SET_EXT_TRANS(f, INTOBJ_INT(n));
            }
            else {
                deg = 0;
                for (i = 0; i < n; i++) {
                    if (ptf2[i] > i && ptf2[i] + 1 > deg) {
                        deg = ptf2[i] + 1;
                    }
                    else if (ptf2[i] < i && i + 1 > deg) {
                        deg = i + 1;
                    }
                }
                SET_EXT_TRANS(f, INTOBJ_INT(deg));
            }
        }
        else {
            ptf4 = CONST_ADDR_TRANS4(f);
            if (ptf4[n - 1] != n - 1) {
                SET_EXT_TRANS(f, INTOBJ_INT(n));
            }
            else {
                deg = 0;
                for (i = 0; i < n; i++) {
                    if (ptf4[i] > i && ptf4[i] + 1 > deg) {
                        deg = ptf4[i] + 1;
                    }
                    else if (ptf4[i] < i && i + 1 > deg) {
                        deg = i + 1;
                    }
                }
                SET_EXT_TRANS(f, INTOBJ_INT(deg));
            }
        }
    }
    return EXT_TRANS(f);
}

// Returns the rank of transformation, i.e. number of distinct values in
// [(1)f .. (n)f] where n = DegreeOfTransformation(f).

static Obj FuncRANK_TRANS(Obj self, Obj f)
{
    RequireTransformation(SELF_NAME, f);
    return SumInt(INTOBJ_INT(RANK_TRANS(f) - DEG_TRANS(f)),
                  FuncDegreeOfTransformation(self, f));
}

// Returns the rank of the transformation <f> on [1 .. n], i.e. the number of
// distinct values in [(1)f .. (n)f].

static Obj FuncRANK_TRANS_INT(Obj self, Obj f, Obj n)
{
    UInt    rank, i, m, deg;
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * pttmp;

    RequireTransformation(SELF_NAME, f);
    RequireNonnegativeSmallInt(SELF_NAME, n);

    m = INT_INTOBJ(n);
    deg = DEG_TRANS(f);
    if (m >= deg) {
        rank = RANK_TRANS(f) - deg + m;
    }
    else if (TNUM_OBJ(f) == T_TRANS2) {
        pttmp = ResizeInitTmpTrans(deg);
        ptf2 = CONST_ADDR_TRANS2(f);
        rank = 0;
        for (i = 0; i < m; i++) {
            if (pttmp[ptf2[i]] == 0) {
                rank++;
                pttmp[ptf2[i]] = 1;
            }
        }
    }
    else {
        pttmp = ResizeInitTmpTrans(deg);
        ptf4 = CONST_ADDR_TRANS4(f);
        rank = 0;
        for (i = 0; i < m; i++) {
            if (pttmp[ptf4[i]] == 0) {
                rank++;
                pttmp[ptf4[i]] = 1;
            }
        }
    }
    return INTOBJ_INT(rank);
}

// Returns the rank of the transformation <f> on the <list>, i.e. the number
// of
// distinct values in [(list[1])f .. (list[n])f], where <list> consists of
// positive ints.

static Obj FuncRANK_TRANS_LIST(Obj self, Obj f, Obj list)
{
    UInt    rank, i, j, len, def;
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * pttmp;

    RequireTransformation(SELF_NAME, f);
    RequireSmallList(SELF_NAME, list);

    len = LEN_LIST(list);
    rank = 0;
    if (TNUM_OBJ(f) == T_TRANS2) {
        def = DEG_TRANS2(f);
        pttmp = ResizeInitTmpTrans(def);
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 1; i <= len; i++) {
            j = GetPositiveListEntry("RANK_TRANS_LIST", list, i) - 1;
            if (j < def) {
                j = ptf2[j];
                if (pttmp[j] == 0) {
                    rank++;
                    pttmp[j] = 1;
                }
            }
            else {
                rank++;
            }
        }
    }
    else {
        def = DEG_TRANS4(f);
        pttmp = ResizeInitTmpTrans(def);
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 1; i <= len; i++) {
            j = GetPositiveListEntry("RANK_TRANS_LIST", list, i) - 1;
            if (j < def) {
                j = ptf4[j];
                if (pttmp[j] == 0) {
                    rank++;
                    pttmp[j] = 1;
                }
            }
            else {
                rank++;
            }
        }
    }

    return INTOBJ_INT(rank);
}

/*******************************************************************************
** GAP level functions for the kernel and preimages of a transformation
*******************************************************************************/

// Returns the flat kernel of transformation on
// [1 .. DegreeOfTransformation(f)].

static Obj FuncFLAT_KERNEL_TRANS(Obj self, Obj f)
{
    RequireTransformation(SELF_NAME, f);

    if (KER_TRANS(f) == NULL) {
        INIT_TRANS(f);
    }
    return KER_TRANS(f);
}

// Returns the flat kernel of the transformation <f> on [1 .. n].

static Obj FuncFLAT_KERNEL_TRANS_INT(Obj self, Obj f, Obj n)
{
    Obj newObj, *ptnew;
    const Obj *ptker;
    UInt deg, m, i;

    RequireTransformation(SELF_NAME, f);
    RequireNonnegativeSmallInt(SELF_NAME, n);

    m = INT_INTOBJ(n);
    if (m == 0) {
        return NewEmptyPlist();
    }
    if (KER_TRANS(f) == NULL) {
        INIT_TRANS(f);
    }
    deg = DEG_TRANS(f);
    if (m == deg) {
        return KER_TRANS(f);
    }

    newObj = NEW_PLIST(T_PLIST_CYC_NSORT, m);
    SET_LEN_PLIST(newObj, m);
    ptker = CONST_ADDR_OBJ(KER_TRANS(f)) + 1;
    ptnew = ADDR_OBJ(newObj) + 1;

    // copy the kernel set up to minimum of m, deg
    if (m < deg) {
        for (i = 0; i < m; i++) {
            *ptnew++ = *ptker++;
        }
    }
    else {
        // m > deg
        for (i = 0; i < deg; i++) {
            *ptnew++ = *ptker++;
        }
        // we must now add another (m - deg) points,
        // starting with the class number (rank + 1)
        for (i = 1; i <= m - deg; i++) {
            *ptnew++ = INTOBJ_INT(i + RANK_TRANS(f));
        }
    }
    return newObj;
}

// Returns the kernel of a transformation <f> as a partition of [1 .. n].

static Obj FuncKERNEL_TRANS(Obj self, Obj f, Obj n)
{
    Obj     ker;
    UInt    i, j, deg, nr, m, rank, min;
    UInt4 * pttmp;

    RequireNonnegativeSmallInt(SELF_NAME, n);
    RequireTransformation(SELF_NAME, f);

    m = INT_INTOBJ(n);

    // special case for the identity
    if (m == 0) {
        return NewEmptyPlist();
    }

    deg = DEG_TRANS(f);
    rank = RANK_TRANS(f);
    min = MIN(m, deg);
    nr = (min == m ? rank : rank + m - deg);    // the number of classes

    ker = NEW_PLIST(T_PLIST_HOM_SSORT, nr);
    pttmp = ResizeInitTmpTrans(nr);

    // RANK_TRANS(f) should install KER_TRANS(f)
    assert(KER_TRANS(f) != NULL);

    nr = 0;
    // read off flat kernel
    for (i = 0; i < min; i++) {
        j = INT_INTOBJ(ELM_PLIST(KER_TRANS(f), i + 1));
        if (pttmp[j - 1] == 0) {
            nr++;
            SET_ELM_PLIST(ker, j, NEW_PLIST(T_PLIST_CYC_SSORT, 1));
            CHANGED_BAG(ker);
            pttmp = AddrTmpTrans();
        }
        AssPlist(ELM_PLIST(ker, j), (Int)++pttmp[j - 1], INTOBJ_INT(i + 1));
        pttmp = AddrTmpTrans();
    }

    // add trailing singletons, if any
    for (i = deg; i < m; i++) {
        SET_ELM_PLIST(ker, ++nr, NEW_PLIST(T_PLIST_CYC_SSORT, 1));
        SET_LEN_PLIST(ELM_PLIST(ker, nr), 1);
        SET_ELM_PLIST(ELM_PLIST(ker, nr), 1, INTOBJ_INT(i + 1));
        CHANGED_BAG(ker);
    }
    SET_LEN_PLIST(ker, (Int)nr);
    return ker;
}

// Returns the set (pt)f ^ -1.

static Obj FuncPREIMAGES_TRANS_INT(Obj self, Obj f, Obj pt)
{
    UInt deg, nr, i, j;
    Obj  out;

    RequireTransformation(SELF_NAME, f);
    i = GetPositiveSmallInt("PREIMAGES_TRANS_INT", pt) - 1;

    deg = DEG_TRANS(f);

    if (i >= deg) {
        return NewPlistFromArgs(pt);
    }

    out = NEW_PLIST(T_PLIST_CYC_SSORT, 0);
    nr = 0;

    if (TNUM_OBJ(f) == T_TRANS2) {
        for (j = 0; j < deg; j++) {
            if ((CONST_ADDR_TRANS2(f))[j] == i) {
                AssPlist(out, ++nr, INTOBJ_INT(j + 1));
            }
        }
    }
    else {
        for (j = 0; j < deg; j++) {
            if ((CONST_ADDR_TRANS4(f))[j] == i) {
                AssPlist(out, ++nr, INTOBJ_INT(j + 1));
            }
        }
    }

    if (nr == 0) {
        RetypeBag(out, T_PLIST_EMPTY);
        SET_LEN_PLIST(out, 0);
    }

    return out;
}

/*******************************************************************************
** GAP level functions for the image sets and lists of a transformation
*******************************************************************************/

// Returns the duplicate free list of images of the transformation f on
// [1 .. n] where n = DEG_TRANS(f). Note that this might not be sorted.

static Obj FuncUNSORTED_IMAGE_SET_TRANS(Obj self, Obj f)
{
    RequireTransformation(SELF_NAME, f);

    if (IMG_TRANS(f) == NULL) {
        INIT_TRANS(f);
    }
    return IMG_TRANS(f);
}

// Returns the image set of the transformation f on [1 .. n] where n =
// DegreeOfTransformation(f).

static Obj FuncIMAGE_SET_TRANS(Obj self, Obj f)
{

    Obj out = FuncUNSORTED_IMAGE_SET_TRANS(self, f);

    if (!IS_SSORT_LIST(out)) {
        SortPlistByRawObj(out);
        RetypeBagSM(out, T_PLIST_CYC_SSORT);
        return out;
    }
    return out;
}

// Returns the image set of the transformation f on [1 .. n].

static Obj FuncIMAGE_SET_TRANS_INT(Obj self, Obj f, Obj n)
{
    Obj     im, newObj;
    UInt    deg, m, len, i, j, rank;
    Obj *   ptnew;
    const Obj *ptim;
    UInt4 * pttmp;
    const UInt4 * ptf4;
    const UInt2 * ptf2;

    RequireNonnegativeSmallInt(SELF_NAME, n);
    RequireTransformation(SELF_NAME, f);

    m = INT_INTOBJ(n);
    deg = DEG_TRANS(f);

    if (m == deg) {
        return FuncIMAGE_SET_TRANS(self, f);
    }
    else if (m == 0) {
        return NewImmutableEmptyPlist();
    }
    else if (m < deg) {
        newObj = NEW_PLIST_IMM(T_PLIST_CYC, m);
        pttmp = ResizeInitTmpTrans(deg);

        if (TNUM_OBJ(f) == T_TRANS2) {
            ptf2 = CONST_ADDR_TRANS2(f);
            rank = 0;
            for (i = 0; i < m; i++) {
                j = ptf2[i];
                if (pttmp[j] == 0) {
                    pttmp[j] = ++rank;
                    SET_ELM_PLIST(newObj, rank, INTOBJ_INT(j + 1));
                }
            }
        }
        else {
            ptf4 = CONST_ADDR_TRANS4(f);
            rank = 0;
            for (i = 0; i < m; i++) {
                j = ptf4[i];
                if (pttmp[j] == 0) {
                    pttmp[j] = ++rank;
                    SET_ELM_PLIST(newObj, rank, INTOBJ_INT(j + 1));
                }
            }
        }
        SHRINK_PLIST(newObj, (Int)rank);
        SET_LEN_PLIST(newObj, (Int)rank);
        SortPlistByRawObj(newObj);
        RetypeBagSM(newObj, T_PLIST_CYC_SSORT);
    }
    else {
        // m > deg and so m is at least 1!
        im = FuncIMAGE_SET_TRANS(self, f);
        len = LEN_PLIST(im);
        newObj = NEW_PLIST(T_PLIST_CYC_SSORT, m - deg + len);
        SET_LEN_PLIST(newObj, m - deg + len);

        ptnew = ADDR_OBJ(newObj) + 1;
        ptim = CONST_ADDR_OBJ(im) + 1;

        // copy the image set
        for (i = 0; i < len; i++) {
            *ptnew++ = *ptim++;
        }
        // add newObj points
        for (i = deg + 1; i <= m; i++) {
            *ptnew++ = INTOBJ_INT(i);
        }
    }
    return newObj;
}

// Returns the image list [(1)f .. (n)f] of the transformation f.

static Obj FuncIMAGE_LIST_TRANS_INT(Obj self, Obj f, Obj n)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    i, deg, m;
    Obj     out;

    RequireNonnegativeSmallInt(SELF_NAME, n);
    RequireTransformation(SELF_NAME, f);

    m = INT_INTOBJ(n);

    if (m == 0) {
        out = NewImmutableEmptyPlist();
        return out;
    }

    out = NEW_PLIST_IMM(T_PLIST_CYC, m);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        deg = MIN(DEG_TRANS2(f), m);
        for (i = 0; i < deg; i++) {
            SET_ELM_PLIST(out, i + 1, INTOBJ_INT(ptf2[i] + 1));
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        deg = MIN(DEG_TRANS4(f), m);
        for (i = 0; i < deg; i++) {
            SET_ELM_PLIST(out, i + 1, INTOBJ_INT(ptf4[i] + 1));
        }
    }
    for (; i < m; i++)
        SET_ELM_PLIST(out, i + 1, INTOBJ_INT(i + 1));
    SET_LEN_PLIST(out, (Int)m);
    return out;
}

/*******************************************************************************
** GAP level functions for properties of transformations
*******************************************************************************/

// Test if a transformation is the identity.

static Obj FuncIS_ID_TRANS(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    deg, i;

    RequireTransformation(SELF_NAME, f);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptf2[i] != i) {
                return False;
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptf4[i] != i) {
                return False;
            }
        }
    }
    return True;
}

// Returns true if the transformation <f> is an idempotent and false if it is
// not.

static Obj FuncIS_IDEM_TRANS(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    deg, i;

    RequireTransformation(SELF_NAME, f);

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptf2[ptf2[i]] != ptf2[i]) {
                return False;
            }
        }
    }
    else {
        deg = DEG_TRANS4(f);
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptf4[ptf4[i]] != ptf4[i]) {
                return False;
            }
        }
    }
    return True;
}

/*******************************************************************************
** GAP level functions for attributes of transformations
*******************************************************************************/

// Returns the least m and r such that f ^ (m + r) = f ^ m, where f is a
// transformation.

static Obj FuncIndexPeriodOfTransformation(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * seen;
    UInt    deg, i, pt, dist, pow, len, last_pt;
    Obj     ord;
    Int     cyc;

    RequireTransformation(SELF_NAME, f);

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (deg == 0) {
        return NewPlistFromArgs(INTOBJ_INT(1), INTOBJ_INT(1));
    }

    // seen[pt] = 0 -> haven't seen pt before
    //
    // seen[pt] = d where (1 <= d <= deg)
    //   -> pt belongs to a component we've seen before and (pt)f ^ (d - 1)
    //   belongs to a cycle
    //
    // seen[pt] = deg + 1 -> pt belongs to a component not seen before

    seen = ResizeInitTmpTrans(deg);

    pow = 2;
    ord = INTOBJ_INT(1);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (seen[i] == 0) {
                len = 0;
                // repeatedly apply f to pt until we see something we've seen
                // already
                for (pt = i; seen[pt] == 0; pt = ptf2[pt], len++) {
                    seen[pt] = deg + 1;
                }
                last_pt = pt;
                if (seen[pt] <= deg) {
                    // pt belongs to a component we've seen before
                    dist = seen[pt] + len;
                    // the distance of i from the cycle in its component + 1
                }
                else {
                    // pt belongs to a component we've not seen before

                    for (cyc = 0; seen[pt] == deg + 1; pt = ptf2[pt], cyc++) {
                        // go around the cycle again and set the value of
                        // seen,
                        // and get the length of the cycle
                        seen[pt] = 1;
                    }

                    ord = LcmInt(ord, INTOBJ_INT(cyc));

                    // the distance of i from the cycle in its component + 1
                    dist = len - cyc + 1;

                    // update bag pointers, in case a garbage collection happened
                    ptf2 = CONST_ADDR_TRANS2(f);
                    seen = AddrTmpTrans();
                }
                if (dist > pow) {
                    pow = dist;
                }
                // record the distances of the points from the cycle
                for (pt = i; pt != last_pt; pt = ptf2[pt]) {
                    seen[pt] = dist--;
                }
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (seen[i] == 0) {
                len = 0;
                // repeatedly apply f to pt until we see something we've seen
                // already
                for (pt = i; seen[pt] == 0; pt = ptf4[pt], len++) {
                    seen[pt] = deg + 1;
                }
                last_pt = pt;
                if (seen[pt] <= deg) {
                    // pt belongs to a component we've seen before
                    dist = seen[pt] + len;
                    // the distance of i from the cycle in its component + 1
                }
                else {
                    // pt belongs to a component we've not seen before

                    for (cyc = 0; seen[pt] == deg + 1; pt = ptf4[pt], cyc++) {
                        // go around the cycle again and set the value of
                        // seen,
                        // and get the length of the cycle
                        seen[pt] = 1;
                    }

                    ord = LcmInt(ord, INTOBJ_INT(cyc));

                    // the distance of i from the cycle in its component + 1
                    dist = len - cyc + 1;

                    // update bag pointers, in case a garbage collection happened
                    ptf4 = CONST_ADDR_TRANS4(f);
                    seen = AddrTmpTrans();
                }
                if (dist > pow) {
                    pow = dist;
                }
                // record the distances of the points from the cycle
                for (pt = i; pt != last_pt; pt = ptf4[pt]) {
                    seen[pt] = dist--;
                }
            }
        }
    }

    return NewPlistFromArgs(INTOBJ_INT(--pow), ord);
}

// Returns the least integer m such that f ^ m is an idempotent.

static Obj FuncSMALLEST_IDEM_POW_TRANS(Obj self, Obj f)
{
    Obj x, ind, per, pow;

    x = FuncIndexPeriodOfTransformation(self, f);
    ind = ELM_PLIST(x, 1);
    per = ELM_PLIST(x, 2);
    pow = per;
    while (LtInt(pow, ind)) {
        pow = SumInt(pow, per);
    }
    return pow;
}

/*******************************************************************************
** GAP level functions for regularity of transformations
*******************************************************************************/

// Returns True if the transformation or list <obj> is injective on the list
// <list>.

static Obj FuncIsInjectiveListTrans(Obj self, Obj list, Obj obj)
{
    UInt    n, i, j;
    const UInt2 * ptt2;
    const UInt4 * ptt4;
    UInt4 * pttmp = 0;

    RequireSmallList(SELF_NAME, list);
    if (!IS_TRANS(obj) && !IS_LIST(obj)) {
        RequireArgument(SELF_NAME, obj, "must be a transformation or a list");
    }
    // init buffer
    n = (IS_TRANS(obj) ? DEG_TRANS(obj) : LEN_LIST(obj));
    pttmp = ResizeInitTmpTrans(n);

    if (TNUM_OBJ(obj) == T_TRANS2) {
        ptt2 = CONST_ADDR_TRANS2(obj);
        for (i = LEN_LIST(list); i >= 1; i--) {
            j = GetPositiveListEntry("IsInjectiveListTrans", list, i);
            if (j <= n) {
                if (pttmp[ptt2[j - 1]] != 0) {
                    return False;
                }
                pttmp[ptt2[j - 1]] = 1;
            }
        }
    }
    else if (TNUM_OBJ(obj) == T_TRANS4) {
        ptt4 = CONST_ADDR_TRANS4(obj);
        for (i = LEN_LIST(list); i >= 1; i--) {
            j = GetPositiveListEntry("IsInjectiveListTrans", list, i);
            if (j <= n) {
                if (pttmp[ptt4[j - 1]] != 0) {
                    return False;
                }
                pttmp[ptt4[j - 1]] = 1;
            }
        }
    }
    else {
        // obj is a list, first we check it describes a transformation
        for (i = 1; i <= n; i++) {
            j = GetPositiveListEntry("IsInjectiveListTrans", obj, i);
            if (j > n) {
                ErrorQuit(
                    "<obj> must be a list of positive small integers "
                    "in the range [1 .. %d]",
                    (Int)n, 0);
            }
        }
        for (i = LEN_LIST(list); i >= 1; i--) {
            j = GetPositiveListEntry("IsInjectiveListTrans", list, i);
            if (j <= n) {
                if (pttmp[INT_INTOBJ(ELM_LIST(obj, j)) - 1] != 0) {
                    return False;
                }
                pttmp[INT_INTOBJ(ELM_LIST(obj, j)) - 1] = 1;
            }
        }
    }
    return True;
}

// Returns a transformation g such that transformation f * g * f = f and
// g * f * g = g, where f is a transformation.

static Obj FuncInverseOfTransformation(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt2 * ptg2;
    UInt4 * ptg4;
    UInt   deg, i;
    Obj    g;

    RequireTransformation(SELF_NAME, f);
    if (FuncIS_ID_TRANS(self, f) == True) {
        return f;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        g = NEW_TRANS2(deg);
        ptf2 = CONST_ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);
        for (i = 0; i < deg; i++) {
            ptg2[i] = 0;
        }
        for (i = deg - 1; i > 0; i--) {
            ptg2[ptf2[i]] = i;
        }
        // to ensure that 1 is in the image and so rank of g equals that of f
        ptg2[ptf2[0]] = 0;
    }
    else {
        deg = DEG_TRANS4(f);
        g = NEW_TRANS4(deg);
        ptf4 = CONST_ADDR_TRANS4(f);
        ptg4 = ADDR_TRANS4(g);
        for (i = 0; i < deg; i++) {
            ptg4[i] = 0;
        }
        for (i = deg - 1; i > 0; i--) {
            ptg4[ptf4[i]] = i;
        }
        // to ensure that 1 is in the image and so rank of g equals that of f
        ptg4[ptf4[0]] = 0;
    }
    return g;
}

/*******************************************************************************
** GAP level functions for actions of transformations
*******************************************************************************/

// Returns the flat kernel of a transformation obtained by multiplying <f> by
// any transformation with kernel equal to <ker>. If the argument <ker> =
// [0], then the flat kernel of <f> on [1 .. <n>] is returned. Otherwise, the
// argument <n> is redundant.

// FIXME this should just always return a flat kernel of length <n>, the
// special case should be removed, and [0] should be replaced by [1 .. n] in
// the Semigroup package.

static Obj FuncON_KERNEL_ANTI_ACTION(Obj self, Obj ker, Obj f, Obj n)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * pttmp;
    UInt    deg, i, j, rank, len;
    Obj     out;

    RequireSmallList(SELF_NAME, ker);
    RequireTransformation(SELF_NAME, f);
    RequireNonnegativeSmallInt(SELF_NAME, n);

    len = LEN_LIST(ker);
    if (len == 1 && ELM_LIST(ker, 1) == INTOBJ_INT(0)) {
        return FuncFLAT_KERNEL_TRANS_INT(self, f, n);
    }

    rank = 1;
    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));
    if (len < deg) {
        ErrorQuit("ON_KERNEL_ANTI_ACTION: the length of <ker> "
                  "must be at least %d",
                  (Int)deg, 0);
    }

    if (len == 0) {
        out = NewImmutableEmptyPlist();
        return out;
    }
    out = NEW_PLIST_IMM(T_PLIST_CYC, len);
    SET_LEN_PLIST(out, len);
    pttmp = ResizeInitTmpTrans(len);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            // <f> then <g> with ker(<g>) = <ker>
            j = INT_INTOBJ(ELM_LIST(ker, ptf2[i] + 1)) - 1;    // f first!
            if (pttmp[j] == 0) {
                pttmp[j] = rank++;
            }
            SET_ELM_PLIST(out, i + 1, INTOBJ_INT(pttmp[j]));
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            // <f> then <g> with ker(<g>) = <ker>
            j = INT_INTOBJ(ELM_LIST(ker, ptf4[i] + 1)) - 1;    // f first!
            if (pttmp[j] == 0) {
                pttmp[j] = rank++;
            }
            SET_ELM_PLIST(out, i + 1, INTOBJ_INT(pttmp[j]));
        }
    }

    i++;
    for (; i <= len; i++) {
        // just <ker>
        j = INT_INTOBJ(ELM_LIST(ker, i)) - 1;
        if (pttmp[j] == 0) {
            pttmp[j] = rank++;
        }
        SET_ELM_PLIST(out, i, INTOBJ_INT(pttmp[j]));
    }
    return out;
}

/*******************************************************************************
** GAP level functions for changing representation of a permutation to a
** transformation
*******************************************************************************/

// Returns a transformation <f> such that (i)f = (i)p for all i <= n where <p>
// is a permutation <p> and <n> is a positive integer. Note that the returned
// transformation is not necessarily a permutation (mathematically), when n is
// less than the largest moved point of p.

static Obj FuncAS_TRANS_PERM_INT(Obj self, Obj p, Obj deg)
{
    const UInt2 *ptp2;
    UInt2 *ptf2;
    const UInt4 *ptp4;
    UInt4 *ptf4;
    Obj    f;
    UInt   def, dep, i, min, n;

    RequireNonnegativeSmallInt(SELF_NAME, deg);
    RequirePermutation(SELF_NAME, p);

    n = INT_INTOBJ(deg);

    if (n == 0) {
        return IdentityTrans;
    }

    // find the degree of f
    def = n;
    dep = (TNUM_OBJ(p) == T_PERM2 ? DEG_PERM2(p) : DEG_PERM4(p));

    if (def < dep) {
        min = def;
        if (TNUM_OBJ(p) == T_PERM2) {
            ptp2 = CONST_ADDR_PERM2(p);
            for (i = 0; i < n; i++) {
                if (ptp2[i] + 1 > def) {
                    def = ptp2[i] + 1;
                }
            }
        }
        else {
            ptp4 = CONST_ADDR_PERM4(p);
            for (i = 0; i < n; i++) {
                if (ptp4[i] + 1 > def) {
                    def = ptp4[i] + 1;
                }
            }
        }
    }
    else {
        min = dep;
        def = dep;    // no point in defining <f> to have lots of trailing
                      // fixed points
    }

    if (def <= 65536) {
        f = NEW_TRANS2(def);
        ptf2 = ADDR_TRANS2(f);

        if (TNUM_OBJ(p) == T_PERM2) {
            ptp2 = CONST_ADDR_PERM2(p);
            for (i = 0; i < min; i++) {
                ptf2[i] = ptp2[i];
            }
        }
        else {    // TNUM_OBJ(p) == T_PERM4
            ptp4 = CONST_ADDR_PERM4(p);
            for (i = 0; i < min; i++) {
                ptf2[i] = ptp4[i];
            }
        }
        for (; i < def; i++) {
            ptf2[i] = i;
        }
    }
    else {    // dep >= def > 65536
        f = NEW_TRANS4(def);
        ptf4 = ADDR_TRANS4(f);
        assert(TNUM_OBJ(p) == T_PERM4);
        ptp4 = CONST_ADDR_PERM4(p);
        for (i = 0; i < min; i++) {
            ptf4[i] = ptp4[i];
        }
        for (; i < def; i++) {
            ptf4[i] = i;
        }
    }

    return f;
}

// Returns a transformation <f> such that (i)f = (i)p for all i <= n where <p>
// is a permutation <p> and <n> is the largest moved point of <p>.

static Obj FuncAS_TRANS_PERM(Obj self, Obj p)
{
    const UInt2 * ptPerm2;
    const UInt4 * ptPerm4;
    UInt    sup;

    RequirePermutation(SELF_NAME, p);

    // find largest moved point
    if (TNUM_OBJ(p) == T_PERM2) {
        ptPerm2 = CONST_ADDR_PERM2(p);
        for (sup = DEG_PERM2(p); 1 <= sup; sup--) {
            if (ptPerm2[sup - 1] != sup - 1) {
                break;
            }
        }
        return FuncAS_TRANS_PERM_INT(self, p, INTOBJ_INT(sup));
    }
    else {
        ptPerm4 = CONST_ADDR_PERM4(p);
        for (sup = DEG_PERM4(p); 1 <= sup; sup--) {
            if (ptPerm4[sup - 1] != sup - 1) {
                break;
            }
        }
        return FuncAS_TRANS_PERM_INT(self, p, INTOBJ_INT(sup));
    }
}

/*******************************************************************************
** GAP level functions for changing representation of a transformation to a
** permutation
*******************************************************************************/

// Returns a permutation mathematically equal to the transformation <f> if
// possible, and returns Fail if it is not possible

static Obj FuncAS_PERM_TRANS(Obj self, Obj f)
{
    const UInt2 *ptf2;
    const UInt4 *ptf4;
    UInt2 *ptp2;
    UInt4 *ptp4;
    UInt   deg, i;
    Obj    p;

    RequireTransformation(SELF_NAME, f);

    deg = DEG_TRANS(f);
    if (RANK_TRANS(f) != deg) {
        return Fail;
    }
    if (TNUM_OBJ(f) == T_TRANS2) {
        p = NEW_PERM2(deg);
        ptp2 = ADDR_PERM2(p);
        ptf2 = CONST_ADDR_TRANS2(f);

        for (i = 0; i < deg; i++) {
            ptp2[i] = ptf2[i];
        }
    }
    else {
        p = NEW_PERM4(deg);
        ptp4 = ADDR_PERM4(p);
        ptf4 = CONST_ADDR_TRANS4(f);

        for (i = 0; i < deg; i++) {
            ptp4[i] = ptf4[i];
        }
    }
    return p;
}

// Returns the permutation of the image of the transformation <f> induced by
// <f> if possible, and returns Fail if it is not possible.

static Obj FuncPermutationOfImage(Obj self, Obj f)
{
    const UInt2 *ptf2;
    const UInt4 *ptf4;
    UInt2 *ptp2;
    UInt4 *ptp4, *pttmp;
    UInt   deg, rank, i, j;
    Obj    p, img;

    RequireTransformation(SELF_NAME, f);

    rank = RANK_TRANS(f);
    deg = DEG_TRANS(f);
    if (TNUM_OBJ(f) == T_TRANS2) {
        p = NEW_PERM2(deg);
        ResizeTmpTrans(deg);

        pttmp = AddrTmpTrans();
        ptp2 = ADDR_PERM2(p);
        for (i = 0; i < deg; i++) {
            pttmp[i] = 0;
            ptp2[i] = i;
        }

        ptf2 = CONST_ADDR_TRANS2(f);
        img = IMG_TRANS(f);
        assert(img != NULL);    // should be installed by RANK_TRANS2

        for (i = 0; i < rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(img, i + 1)) - 1;
            if (pttmp[ptf2[j]] != 0) {
                return Fail;
            }
            pttmp[ptf2[j]] = 1;
            ptp2[j] = ptf2[j];
        }
    }
    else {
        p = NEW_PERM4(deg);
        ResizeTmpTrans(deg);

        pttmp = AddrTmpTrans();
        ptp4 = ADDR_PERM4(p);
        for (i = 0; i < deg; i++) {
            pttmp[i] = 0;
            ptp4[i] = i;
        }

        ptf4 = CONST_ADDR_TRANS4(f);
        img = IMG_TRANS(f);
        assert(img != NULL);    // should be installed by RANK_TRANS2

        for (i = 0; i < rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(img, i + 1)) - 1;
            if (pttmp[ptf4[j]] != 0) {
                return Fail;
            }
            pttmp[ptf4[j]] = 1;
            ptp4[j] = ptf4[j];
        }
    }
    return p;
}

// Returns the permutation of the im(f) induced by f ^ -1 * g under the
// (unchecked) assumption that im(f) = im(g) and ker(f) = ker(g).

static Obj FuncPermLeftQuoTransformationNC(Obj self, Obj f, Obj g)
{
    const UInt2 *ptf2, *ptg2;
    const UInt4 *ptf4, *ptg4;
    UInt4 *ptp;
    UInt   def, deg, i, min, max;
    Obj    perm;

    RequireTransformation(SELF_NAME, f);
    RequireTransformation(SELF_NAME, g);

    def = DEG_TRANS(f);
    deg = DEG_TRANS(g);
    min = MIN(def, deg);
    max = MAX(def, deg);

    // always return a T_PERM4 to reduce the amount of code here.
    perm = NEW_PERM4(max);
    ptp = ADDR_PERM4(perm);

    if (TNUM_OBJ(f) == T_TRANS2 && TNUM_OBJ(g) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        ptg2 = CONST_ADDR_TRANS2(g);

        for (i = 0; i < max; i++) {
            ptp[i] = i;
        }
        for (i = 0; i < min; i++) {
            ptp[ptf2[i]] = ptg2[i];
        }
        for (; i < deg; i++) {
            ptp[i] = ptg2[i];
        }
        for (; i < def; i++) {
            ptp[ptf2[i]] = i;
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS2 && TNUM_OBJ(g) == T_TRANS4) {
        ptf2 = CONST_ADDR_TRANS2(f);
        ptg4 = CONST_ADDR_TRANS4(g);

        for (i = 0; i < max; i++) {
            ptp[i] = i;
        }
        for (i = 0; i < min; i++) {
            ptp[ptf2[i]] = ptg4[i];
        }
        for (; i < deg; i++) {
            ptp[i] = ptg4[i];
        }
        for (; i < def; i++) {
            // The only transformation created within this file that is of
            // type
            // T_TRANS4 and that does not have (internal) degree 65537 or
            // greater
            // is ID_TRANS4.
            ptp[ptf2[i]] = i;
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS4 && TNUM_OBJ(g) == T_TRANS2) {
        ptf4 = CONST_ADDR_TRANS4(f);
        ptg2 = CONST_ADDR_TRANS2(g);

        for (i = 0; i < max; i++) {
            ptp[i] = i;
        }
        for (i = 0; i < min; i++) {
            ptp[ptf4[i]] = ptg2[i];
        }
        for (; i < deg; i++) {
            // The only transformation created within this file that is of
            // type
            // T_TRANS4 and that does not have (internal) degree 65537 or
            // greater
            // is ID_TRANS4.
            ptp[i] = ptg2[i];
        }
        for (; i < def; i++) {
            ptp[ptf4[i]] = i;
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS4 && TNUM_OBJ(g) == T_TRANS4) {
        ptf4 = CONST_ADDR_TRANS4(f);
        ptg4 = CONST_ADDR_TRANS4(g);

        for (i = 0; i < max; i++) {
            ptp[i] = i;
        }
        for (i = 0; i < min; i++) {
            ptp[ptf4[i]] = ptg4[i];
        }
        for (; i < deg; i++) {
            ptp[i] = ptg4[i];
        }
        for (; i < def; i++) {
            ptp[ptf4[i]] = i;
        }
    }
    return perm;
}

/*******************************************************************************
** GAP level functions for changing representation of a transformation to a
** transformation
*******************************************************************************/

// Returns a transformation g such that (i)g = (i)f for all i in list, and
// where (i)g = i for every other value of i.

static Obj FuncRestrictedTransformation(Obj self, Obj f, Obj list)
{
    UInt   deg, i, k, len;
    const UInt2 *ptf2;
    const UInt4 *ptf4;
    UInt2 *ptg2;
    UInt4 *ptg4;
    Obj    g;

    RequireTransformation(SELF_NAME, f);
    RequireSmallList(SELF_NAME, list);

    len = LEN_LIST(list);

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        g = NEW_TRANS2(deg);

        ptf2 = CONST_ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);

        // g fixes every point
        for (i = 0; i < deg; i++) {
            ptg2[i] = i;
        }

        // g acts like f on list * /
        for (i = 0; i < len; i++) {
            k = GetPositiveListEntry("RestrictedTransformation", list, i + 1) - 1;
            if (k < deg) {
                ptg2[k] = ptf2[k];
            }
        }
    }
    else {
        deg = DEG_TRANS4(f);
        g = NEW_TRANS4(deg);

        ptf4 = CONST_ADDR_TRANS4(f);
        ptg4 = ADDR_TRANS4(g);

        // g fixes every point
        for (i = 0; i < deg; i++) {
            ptg4[i] = i;
        }

        // g acts like f on list
        for (i = 0; i < len; i++) {
            k = GetPositiveListEntry("RestrictedTransformation", list, i + 1) - 1;
            if (k < deg) {
                ptg4[k] = ptf4[k];
            }
        }
    }
    return g;
}

// AsTransformation for a transformation <f> and a pos int <m> either
// restricts
// <f> to [1 .. m] or returns <f> depending on whether m is less than or equal
// DegreeOfTransformation(f) or not.

// In the first form, this is similar to TRIM_TRANS except that a new
// transformation is returned.

static Obj FuncAS_TRANS_TRANS(Obj self, Obj f, Obj m)
{
    const UInt2 *ptf2;
    const UInt4 *ptf4;
    UInt2 *ptg2;
    UInt4 *ptg4;
    UInt   i, n, def;
    Obj    g;

    RequireTransformation(SELF_NAME, f);
    RequireNonnegativeSmallInt(SELF_NAME, m);

    n = INT_INTOBJ(m);

    def = DEG_TRANS(f);
    if (def <= n) {
        return f;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        g = NEW_TRANS2(n);
        ptf2 = CONST_ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);
        for (i = 0; i < n; i++) {
            if (ptf2[i] > n - 1) {
                return Fail;
            }
            ptg2[i] = ptf2[i];
        }
    }
    else {
        if (n > 65536) {
            // g is T_TRANS4
            g = NEW_TRANS4(n);
            ptf4 = CONST_ADDR_TRANS4(f);
            ptg4 = ADDR_TRANS4(g);
            for (i = 0; i < n; i++) {
                if (ptf4[i] > n - 1) {
                    return Fail;
                }
                ptg4[i] = ptf4[i];
            }
        }
        else {
            //  f is T_TRANS4 but n <= 65536 < def and so g will be T_TRANS2 *
            //  /
            g = NEW_TRANS2(n);
            ptf4 = CONST_ADDR_TRANS4(f);
            ptg2 = ADDR_TRANS2(g);
            for (i = 0; i < n; i++) {
                if (ptf4[i] > n - 1) {
                    return Fail;
                }
                ptg2[i] = (UInt2)ptf4[i];
            }
        }
    }
    return g;
}

// Changes the transformation <f> in-place to reduce the degree to <m>.  It is
// assumed that f is actually a transformation of [1 .. m], i.e. that i ^ f <=
// m for all i in [1 .. m].

static Obj FuncTRIM_TRANS(Obj self, Obj f, Obj m)
{
    UInt    deg, i;
    UInt4 * ptf;

    RequireTransformation(SELF_NAME, f);
    RequireNonnegativeSmallInt(SELF_NAME, m);

    deg = INT_INTOBJ(m);

    if (TNUM_OBJ(f) == T_TRANS2) {
        // output is T_TRANS2
        if (deg > DEG_TRANS2(f)) {
            return 0;
        }
        ResizeBag(f, deg * sizeof(UInt2) + 3 * sizeof(Obj));
    }
    else {
        if (deg > DEG_TRANS4(f)) {
            return 0;
        }
        if (deg > 65536UL) {
            // output is T_TRANS4
            ResizeBag(f, deg * sizeof(UInt4) + 3 * sizeof(Obj));
        }
        else {
            // output is T_TRANS2
            ptf = ADDR_TRANS4(f);
            for (i = 0; i < deg; i++) {
                ((UInt2 *)ptf)[i] = (UInt2)ptf[i];
            }
            RetypeBag(f, T_TRANS2);
            ResizeBag(f, deg * sizeof(UInt2) + 3 * sizeof(Obj));
        }
    }

    SET_IMG_TRANS(f, NULL);
    SET_KER_TRANS(f, NULL);
    SET_EXT_TRANS(f, NULL);
    CHANGED_BAG(f);

    return 0;
}

/*******************************************************************************
** GAP level functions for hashing transformations
*******************************************************************************/

// A hash function for transformations.

Int HashFuncForTrans(Obj f)
{
    UInt deg;

    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS2 || TNUM_OBJ(f) == T_TRANS4);

    deg = INT_INTOBJ(FuncDegreeOfTransformation(0, f));

    if (TNUM_OBJ(f) == T_TRANS4) {
        if (deg <= 65536) {
            FuncTRIM_TRANS(0, f, INTOBJ_INT(deg));
        }
        else {
            return HASHKEY_BAG_NC(f, (UInt4)255, 3 * sizeof(Obj), (int)4 * deg);
        }
    }

    return HASHKEY_BAG_NC(f, (UInt4)255, 3 * sizeof(Obj), (int)2 * deg);
}

static Obj FuncHASH_FUNC_FOR_TRANS(Obj self, Obj f, Obj data)
{
    return INTOBJ_INT((HashFuncForTrans(f) % INT_INTOBJ(data)) + 1);
}

/*******************************************************************************
** GAP level functions for moved points (and related) of a transformation
*******************************************************************************/

// Returns the largest value i such that (i)f <> i or 0 if no such i exists.

static Obj FuncLARGEST_MOVED_PT_TRANS(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    i;

    RequireTransformation(SELF_NAME, f);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = DEG_TRANS2(f); 1 <= i; i--) {
            if (ptf2[i - 1] != i - 1) {
                break;
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = DEG_TRANS4(f); 1 <= i; i--) {
            if (ptf4[i - 1] != i - 1) {
                break;
            }
        }
    }
    return INTOBJ_INT(i);
}

// Returns the largest value in [(1)f .. (n)f] where n = LargestMovedPoint(f).

static Obj FuncLARGEST_IMAGE_PT(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    i, max, def;

    RequireTransformation(SELF_NAME, f);
    max = 0;
    if (TNUM_OBJ(f) == T_TRANS2) {
        def = DEG_TRANS2(f);
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = DEG_TRANS2(f); 1 <= i; i--) {
            if (ptf2[i - 1] != i - 1) {
                break;
            }
        }
        for (; 1 <= i; i--) {
            if (ptf2[i - 1] + 1 > max) {
                max = ptf2[i - 1] + 1;
                if (max == def) {
                    break;
                }
            }
        }
    }
    else {
        def = DEG_TRANS4(f);
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = DEG_TRANS4(f); 1 <= i; i--) {
            if (ptf4[i - 1] != i - 1) {
                break;
            }
        }
        for (; 1 <= i; i--) {
            if (ptf4[i - 1] + 1 > max) {
                max = ptf4[i - 1] + 1;
                if (max == def)
                    break;
            }
        }
    }
    return INTOBJ_INT(max);
}

// Returns the smallest value <i> such that (i)f <> i if it exists, and Fail
// if
// not. Note that this differs from the GAP level function which returns
// infinity if (i)f = i for all i.

static Obj FuncSMALLEST_MOVED_PT_TRANS(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    i, deg;

    RequireTransformation(SELF_NAME, f);
    if (FuncIS_ID_TRANS(self, f) == True) {
        return Fail;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        for (i = 1; i <= deg; i++) {
            if (ptf2[i - 1] != i - 1) {
                break;
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);
        for (i = 1; i <= deg; i++) {
            if (ptf4[i - 1] != i - 1) {
                break;
            }
        }
    }
    return INTOBJ_INT(i);
}

// Returns the smallest value in [SmallestMovedPoint(f) ..
// LargestMovedPoint(f)] ^ f if it exists and Fail if it does not. Note that
// this differs from the GAP level function which returns infinity if (i)f = i
// for all i.

static Obj FuncSMALLEST_IMAGE_PT(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    i, min, deg;

    RequireTransformation(SELF_NAME, f);
    if (FuncIS_ID_TRANS(self, f) == True) {
        return Fail;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        min = deg;
        for (i = 0; i < deg; i++) {
            if (ptf2[i] != i && ptf2[i] < min) {
                min = ptf2[i];
            }
        }
        return INTOBJ_INT(min + 1);
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);
        min = deg;
        for (i = 0; i < deg; i++) {
            if (ptf4[i] != i && ptf4[i] < min) {
                min = ptf4[i];
            }
        }
    }
    return INTOBJ_INT(min + 1);
}

// Returns the number of values <i> in [1 .. n] such that (i)f <> i, where n =
// DegreeOfTransformation(f).

static Obj FuncNR_MOVED_PTS_TRANS(Obj self, Obj f)
{
    UInt    nr, i, deg;
    const UInt2 * ptf2;
    const UInt4 * ptf4;

    RequireTransformation(SELF_NAME, f);

    nr = 0;
    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptf2[i] != i) {
                nr++;
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptf4[i] != i) {
                nr++;
            }
        }
    }
    return INTOBJ_INT(nr);
}

// Returns the set of values <i> in [1 .. n] such that (i)f <> i, where n =
// DegreeOfTransformation(f).

static Obj FuncMOVED_PTS_TRANS(Obj self, Obj f)
{
    UInt    len, deg, i;
    Obj     out;
    const UInt2 * ptf2;
    const UInt4 * ptf4;

    RequireTransformation(SELF_NAME, f);

    len = 0;
    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        out = NEW_PLIST(T_PLIST_CYC_SSORT, 0);
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptf2[i] != i) {
                AssPlist(out, ++len, INTOBJ_INT(i + 1));
                ptf2 = CONST_ADDR_TRANS2(f);
            }
        }
    }
    else {
        deg = DEG_TRANS4(f);
        out = NEW_PLIST(T_PLIST_CYC_SSORT, 0);
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptf4[i] != i) {
                AssPlist(out, ++len, INTOBJ_INT(i + 1));
                ptf4 = CONST_ADDR_TRANS4(f);
            }
        }
    }

    if (LEN_PLIST(out) == 0) {
        RetypeBag(out, T_PLIST_EMPTY);
    }

    return out;
}

/*******************************************************************************
** GAP level functions for connected components of a transformation
*******************************************************************************/

// Returns the representatives, in the following sense, of the components of
// the transformation <f>. For every i in [1 ..  DegreeOfTransformation(<f>)]
// there exists a representative j and a positive integer k such that i ^ (<f>
// ^ k) = j. The least number of representatives is returned and these
// representatives are partitioned according to the component they belong to.

static Obj FuncCOMPONENT_REPS_TRANS(Obj self, Obj f)
{
    UInt    deg, i, nr, pt, index;
    Obj     img, out, comp;
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * seen;

    RequireTransformation(SELF_NAME, f);

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (deg == 0) {
        out = NewEmptyPlist();
        return out;
    }

    img = FuncUNSORTED_IMAGE_SET_TRANS(self, f);
    out = NEW_PLIST(T_PLIST, 1);

    seen = ResizeInitTmpTrans(deg);

    for (i = 1; i <= (UInt)LEN_PLIST(img); i++) {
        seen[INT_INTOBJ(ELM_PLIST(img, i)) - 1] = 1;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        nr = 1;
        for (i = 0; i < deg; i++) {
            if (seen[i] == 0) {
                // i belongs to dom(f) but not im(f)
                // repeatedly apply f to pt until we see something we've seen
                // already
                pt = i;
                do {
                    seen[pt] = nr + 1;
                    pt = ptf2[pt];
                } while (seen[pt] == 1);

                index = seen[pt];

                if (index != nr + 1) {
                    // pt belongs to a component we've seen before
                    ptf2 = CONST_ADDR_TRANS2(f);
                    pt = i;
                    do {
                        seen[pt] = index;
                        pt = ptf2[pt];
                    } while (seen[pt] == nr + 1);
                    comp = ELM_PLIST(out, seen[pt] - 1);
                    AssPlist(comp, LEN_PLIST(comp) + 1, INTOBJ_INT(i + 1));
                }
                else {
                    // pt belongs to a component we've not seen before
                    comp = NEW_PLIST(T_PLIST_CYC, 1);
                    SET_LEN_PLIST(comp, 1);
                    SET_ELM_PLIST(comp, 1, INTOBJ_INT(i + 1));
                    AssPlist(out, nr++, comp);
                }
                ptf2 = CONST_ADDR_TRANS2(f);
                seen = AddrTmpTrans();
            }
        }
        for (i = 0; i < deg; i++) {
            if (seen[i] == 1) {
                // i belongs to a cycle
                for (pt = i; seen[pt] == 1; pt = ptf2[pt]) {
                    seen[pt] = 0;
                }
                comp = NEW_PLIST(T_PLIST_CYC, 1);
                SET_LEN_PLIST(comp, 1);
                SET_ELM_PLIST(comp, 1, INTOBJ_INT(i + 1));
                AssPlist(out, nr++, comp);
                ptf2 = CONST_ADDR_TRANS2(f);
                seen = AddrTmpTrans();
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        nr = 1;
        for (i = 0; i < deg; i++) {
            if (seen[i] == 0) {
                // i belongs to dom(f) but not im(f)
                // repeatedly apply f to pt until we see something we've seen
                // already
                pt = i;
                do {
                    seen[pt] = nr + 1;
                    pt = ptf4[pt];
                } while (seen[pt] == 1);

                index = seen[pt];

                if (index != nr + 1) {
                    // pt belongs to a component we've seen before
                    pt = i;
                    do {
                        seen[pt] = index;
                        pt = ptf4[pt];
                    } while (seen[pt] == nr + 1);
                    comp = ELM_PLIST(out, seen[pt] - 1);
                    AssPlist(comp, LEN_PLIST(comp) + 1, INTOBJ_INT(i + 1));
                }
                else {
                    // pt belongs to a component we've not seen before
                    comp = NEW_PLIST(T_PLIST_CYC, 1);
                    SET_LEN_PLIST(comp, 1);
                    SET_ELM_PLIST(comp, 1, INTOBJ_INT(i + 1));
                    AssPlist(out, nr++, comp);
                }
                ptf4 = CONST_ADDR_TRANS4(f);
                seen = AddrTmpTrans();
            }
        }
        for (i = 0; i < deg; i++) {
            if (seen[i] == 1) {
                // i belongs to a cycle
                for (pt = i; seen[pt] == 1; pt = ptf4[pt]) {
                    seen[pt] = 0;
                }
                comp = NEW_PLIST(T_PLIST_CYC, 1);
                SET_LEN_PLIST(comp, 1);
                SET_ELM_PLIST(comp, 1, INTOBJ_INT(i + 1));
                AssPlist(out, nr++, comp);
                ptf4 = CONST_ADDR_TRANS4(f);
                seen = AddrTmpTrans();
            }
        }
    }
    return out;
}

// Returns the number of connected components of the transformation <f>,
// thought of as a functional digraph with DegreeOfTransformation(f) vertices.

static Obj FuncNR_COMPONENTS_TRANS(Obj self, Obj f)
{
    UInt    nr, m, i, j, deg;
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * ptseen;

    RequireTransformation(SELF_NAME, f);

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));
    ptseen = ResizeInitTmpTrans(deg);
    nr = 0;
    m = 0;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptseen[i] == 0) {
                m++;
                for (j = i; ptseen[j] == 0; j = ptf2[j]) {
                    ptseen[j] = m;
                }
                if (ptseen[j] == m) {
                    nr++;
                }
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptseen[i] == 0) {
                m++;
                for (j = i; ptseen[j] == 0; j = ptf4[j]) {
                    ptseen[j] = m;
                }
                if (ptseen[j] == m) {
                    nr++;
                }
            }
        }
    }
    return INTOBJ_INT(nr);
}

// Returns the connected components of the transformation <f>, thought of as a
// functional digraph with DegreeOfTransformation(f) vertices.

static Obj FuncCOMPONENTS_TRANS(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * seen;
    UInt    deg, i, pt, csize, nr, index, pos;
    Obj     out, comp;

    RequireTransformation(SELF_NAME, f);

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (deg == 0) {
        out = NewEmptyPlist();
        return out;
    }

    out = NEW_PLIST(T_PLIST, 1);
    seen = ResizeInitTmpTrans(deg);
    nr = 0;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (seen[i] == 0) {
                // repeatedly apply f to pt until we see something we've seen
                // already
                csize = 0;
                pt = i;
                do {
                    csize++;
                    seen[pt] = deg + 1;
                    pt = ptf2[pt];
                } while (seen[pt] == 0);

                if (seen[pt] <= deg) {
                    // pt belongs to a component we've seen before
                    index = seen[pt];
                    comp = ELM_PLIST(out, index);
                    pos = LEN_PLIST(comp) + 1;
                    GROW_PLIST(comp, LEN_PLIST(comp) + csize);
                    SET_LEN_PLIST(comp, LEN_PLIST(comp) + csize);
                }
                else {
                    // pt belongs to a component we've not seen before
                    index = ++nr;
                    pos = 1;

                    comp = NEW_PLIST(T_PLIST_CYC, csize);
                    SET_LEN_PLIST(comp, csize);
                    AssPlist(out, nr, comp);
                }
                seen = AddrTmpTrans();
                ptf2 = CONST_ADDR_TRANS2(f);

                pt = i;
                while (seen[pt] == deg + 1) {
                    SET_ELM_PLIST(comp, pos++, INTOBJ_INT(pt + 1));
                    seen[pt] = index;
                    pt = ptf2[pt];
                }
                CHANGED_BAG(out);
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (seen[i] == 0) {
                // repeatedly apply f to pt until we see something we've seen
                // already
                csize = 0;
                pt = i;
                do {
                    csize++;
                    seen[pt] = deg + 1;
                    pt = ptf4[pt];
                } while (seen[pt] == 0);

                if (seen[pt] <= deg) {
                    // pt belongs to a component we've seen before
                    index = seen[pt];
                    comp = ELM_PLIST(out, index);
                    pos = LEN_PLIST(comp) + 1;
                    GROW_PLIST(comp, LEN_PLIST(comp) + csize);
                    SET_LEN_PLIST(comp, LEN_PLIST(comp) + csize);
                }
                else {
                    // pt belongs to a component we've not seen before
                    index = ++nr;
                    pos = 1;

                    comp = NEW_PLIST(T_PLIST_CYC, csize);
                    SET_LEN_PLIST(comp, csize);
                    AssPlist(out, nr, comp);
                }
                seen = AddrTmpTrans();
                ptf4 = CONST_ADDR_TRANS4(f);

                pt = i;
                while (seen[pt] == deg + 1) {
                    SET_ELM_PLIST(comp, pos++, INTOBJ_INT(pt + 1));
                    seen[pt] = index;
                    pt = ptf4[pt];
                }
                CHANGED_BAG(out);
            }
        }
    }
    return out;
}

// Returns the list of distinct values [pt, (pt)f, (pt)f ^ 2, ..] where <f> is
// a transformation and <pt> is a positive integer.

static Obj FuncCOMPONENT_TRANS_INT(Obj self, Obj f, Obj pt)
{
    UInt    deg, cpt, len;
    Obj     out;
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * ptseen;

    RequireTransformation(SELF_NAME, f);
    cpt = GetPositiveSmallInt("COMPONENT_TRANS_INT", pt) - 1;

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (cpt >= deg) {
        out = NewPlistFromArgs(pt);
        return out;
    }
    out = NEW_PLIST(T_PLIST_CYC, 0);
    ptseen = ResizeInitTmpTrans(deg);

    len = 0;

    // install the points
    if (TNUM_OBJ(f) == T_TRANS2) {
        do {
            AssPlist(out, ++len, INTOBJ_INT(cpt + 1));
            ptseen = AddrTmpTrans();
            ptf2 = CONST_ADDR_TRANS2(f);
            ptseen[cpt] = 1;
            cpt = ptf2[cpt];
        } while (ptseen[cpt] == 0);
    }
    else {
        do {
            AssPlist(out, ++len, INTOBJ_INT(cpt + 1));
            ptseen = AddrTmpTrans();
            ptf4 = CONST_ADDR_TRANS4(f);
            ptseen[cpt] = 1;
            cpt = ptf4[cpt];
        } while (ptseen[cpt] == 0);
    }
    SET_LEN_PLIST(out, (Int)len);
    return out;
}

/*******************************************************************************
** GAP level functions for cycles of a transformation
*******************************************************************************/

// Returns the cycle contained in the component of the transformation <f>
// containing the positive integer <pt>.

static Obj FuncCYCLE_TRANS_INT(Obj self, Obj f, Obj pt)
{
    UInt    deg, cpt, len, i;
    Obj     out;
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * ptseen;

    RequireTransformation(SELF_NAME, f);
    cpt = GetPositiveSmallInt("CYCLE_TRANS_INT", pt) - 1;

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (cpt >= deg) {
        out = NEW_PLIST(T_PLIST_CYC_SSORT, 1);
        SET_LEN_PLIST(out, 1);
        SET_ELM_PLIST(out, 1, pt);
        return out;
    }

    out = NEW_PLIST(T_PLIST_CYC, 0);
    ptseen = ResizeInitTmpTrans(deg);
    len = 0;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        // find component
        do {
            ptseen[cpt] = 1;
            cpt = ptf2[cpt];
        } while (ptseen[cpt] == 0);
        // find cycle
        i = cpt;
        do {
            AssPlist(out, ++len, INTOBJ_INT(i + 1));
            ptf2 = CONST_ADDR_TRANS2(f);
            i = ptf2[i];
        } while (i != cpt);
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        // find component
        do {
            ptseen[cpt] = 1;
            cpt = ptf4[cpt];
        } while (ptseen[cpt] == 0);
        // find cycle
        i = cpt;
        do {
            AssPlist(out, ++len, INTOBJ_INT(i + 1));
            ptf4 = CONST_ADDR_TRANS4(f);
            i = ptf4[i];
        } while (i != cpt);
    }
    return out;
}

// Returns the cycles of the transformation <f>, thought of as a
// functional digraph with DegreeOfTransformation(f) vertices.

static Obj FuncCYCLES_TRANS(Obj self, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * seen;
    UInt    deg, i, pt, nr;
    Obj     out, comp;

    RequireTransformation(SELF_NAME, f);
    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (deg == 0) {
        out = NewEmptyPlist();
        return out;
    }

    out = NEW_PLIST(T_PLIST, 0);
    nr = 0;

    seen = ResizeInitTmpTrans(deg);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (seen[i] == 0) {
                // repeatedly apply f to pt until we see something we've seen
                // already
                for (pt = i; seen[pt] == 0; pt = ptf2[pt]) {
                    seen[pt] = 1;
                }
                if (seen[pt] == 1) {
                    // pt belongs to a component we've not seen before

                    comp = NEW_PLIST(T_PLIST_CYC, 0);
                    AssPlist(out, ++nr, comp);

                    seen = AddrTmpTrans();
                    ptf2 = CONST_ADDR_TRANS2(f);

                    for (; seen[pt] == 1; pt = ptf2[pt]) {
                        seen[pt] = 2;
                        AssPlist(comp, LEN_PLIST(comp) + 1,
                                 INTOBJ_INT(pt + 1));
                        seen = AddrTmpTrans();
                        ptf2 = CONST_ADDR_TRANS2(f);
                    }
                }
                for (pt = i; seen[pt] == 1; pt = ptf2[pt]) {
                    seen[pt] = 2;
                }
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (seen[i] == 0) {
                // repeatedly apply f to pt until we see something we've seen
                // already
                for (pt = i; seen[pt] == 0; pt = ptf4[pt]) {
                    seen[pt] = 1;
                }
                if (seen[pt] == 1) {
                    // pt belongs to a component we've not seen before

                    comp = NEW_PLIST(T_PLIST_CYC, 0);
                    AssPlist(out, ++nr, comp);

                    seen = AddrTmpTrans();
                    ptf4 = CONST_ADDR_TRANS4(f);

                    for (; seen[pt] == 1; pt = ptf4[pt]) {
                        seen[pt] = 2;
                        AssPlist(comp, LEN_PLIST(comp) + 1,
                                 INTOBJ_INT(pt + 1));
                        seen = AddrTmpTrans();
                        ptf4 = CONST_ADDR_TRANS4(f);
                    }
                }
                for (pt = i; seen[pt] == 1; pt = ptf4[pt]) {
                    seen[pt] = 2;
                }
            }
        }
    }
    return out;
}

// Returns the cycles of the transformation <f> contained in the components of
// any of the elements in <list>.

static Obj FuncCYCLES_TRANS_LIST(Obj self, Obj f, Obj list)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt4 * seen;
    UInt    deg, i, j, pt, nr;
    Obj     out, comp;

    RequireTransformation(SELF_NAME, f);
    RequireSmallList(SELF_NAME, list);

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (LEN_LIST(list) == 0) {
        out = NewEmptyPlist();
        return out;
    }

    out = NEW_PLIST(T_PLIST, 0);
    nr = 0;

    seen = ResizeInitTmpTrans(deg);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        for (i = 1; i <= (UInt)LEN_LIST(list); i++) {
            j = GetPositiveListEntry("CYCLES_TRANS_LIST", list, i) - 1;
            if (j >= deg) {
                comp = NEW_PLIST(T_PLIST_CYC, 1);
                SET_LEN_PLIST(comp, 1);
                SET_ELM_PLIST(comp, 1, INTOBJ_INT(j + 1));
                AssPlist(out, ++nr, comp);
                seen = AddrTmpTrans();
                ptf2 = CONST_ADDR_TRANS2(f);
            }
            else if (seen[j] == 0) {
                // repeatedly apply f to pt until we see something we've seen
                // already
                for (pt = j; seen[pt] == 0; pt = ptf2[pt]) {
                    seen[pt] = 1;
                }
                if (seen[pt] == 1) {
                    // pt belongs to a component we've not seen before

                    comp = NEW_PLIST(T_PLIST_CYC, 0);
                    AssPlist(out, ++nr, comp);

                    seen = AddrTmpTrans();
                    ptf2 = CONST_ADDR_TRANS2(f);

                    for (; seen[pt] == 1; pt = ptf2[pt]) {
                        seen[pt] = 2;
                        AssPlist(comp, LEN_PLIST(comp) + 1,
                                 INTOBJ_INT(pt + 1));
                        seen = AddrTmpTrans();
                        ptf2 = CONST_ADDR_TRANS2(f);
                    }
                }
                for (pt = j; seen[pt] == 1; pt = ptf2[pt]) {
                    seen[pt] = 2;
                }
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        for (i = 1; i <= (UInt)LEN_LIST(list); i++) {
            j = GetPositiveListEntry("CYCLES_TRANS_LIST", list, i) - 1;
            if (j >= deg) {
                comp = NEW_PLIST(T_PLIST_CYC, 1);
                SET_LEN_PLIST(comp, 1);
                SET_ELM_PLIST(comp, 1, INTOBJ_INT(j + 1));
                AssPlist(out, ++nr, comp);
                seen = AddrTmpTrans();
                ptf4 = CONST_ADDR_TRANS4(f);
            }
            else if (seen[j] == 0) {
                // repeatedly apply f to pt until we see something we've seen
                // already
                for (pt = j; seen[pt] == 0; pt = ptf4[pt]) {
                    seen[pt] = 1;
                }
                if (seen[pt] == 1) {
                    // pt belongs to a component we've not seen before

                    comp = NEW_PLIST(T_PLIST_CYC, 0);
                    AssPlist(out, ++nr, comp);

                    seen = AddrTmpTrans();
                    ptf4 = CONST_ADDR_TRANS4(f);

                    for (; seen[pt] == 1; pt = ptf4[pt]) {
                        seen[pt] = 2;
                        AssPlist(comp, LEN_PLIST(comp) + 1,
                                 INTOBJ_INT(pt + 1));
                        seen = AddrTmpTrans();
                        ptf4 = CONST_ADDR_TRANS4(f);
                    }
                }
                for (pt = j; seen[pt] == 1; pt = ptf4[pt]) {
                    seen[pt] = 2;
                }
            }
        }
    }
    return out;
}

/*******************************************************************************
** GAP level functions for the Semigroups package
*******************************************************************************/

// Returns a transformation g such that ((i)f)g = i for all i in list,
// it is assumed (and not checked) that the transformation f is injective on
// list.

static Obj FuncINV_LIST_TRANS(Obj self, Obj list, Obj f)
{
    const UInt2 *ptf2;
    const UInt4 *ptf4;
    UInt2 *ptg2;
    UInt4 *ptg4;
    UInt   deg, i, j;
    Obj    g;

    RequireDenseList(SELF_NAME, list);
    RequireTransformation(SELF_NAME, f);

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        g = NEW_TRANS2(deg);
        ptf2 = CONST_ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);

        for (j = 0; j < deg; j++) {
            ptg2[j] = j;
        }
        for (j = 1; j <= (UInt)LEN_LIST(list); j++) {
            i = GetPositiveListEntry("INV_LIST_TRANS", list, j) - 1;
            if (i < deg) {
                ptg2[ptf2[i]] = i;
            }
        }
    }
    else {
        deg = DEG_TRANS4(f);
        g = NEW_TRANS4(deg);
        ptf4 = CONST_ADDR_TRANS4(f);
        ptg4 = ADDR_TRANS4(g);

        for (j = 0; j < deg; j++) {
            ptg4[j] = j;
        }
        for (j = 1; j <= (UInt)LEN_LIST(list); j++) {
            i = GetPositiveListEntry("INV_LIST_TRANS", list, j) - 1;
            if (i < deg) {
                ptg4[ptf4[i]] = i;
            }
        }
    }
    return g;
}

// If ker(f) = ker(g), then TRANS_IMG_CONJ returns the permutation p
// such that i ^ (f ^ -1 * g) = i ^ p for all i in im(f).
//
// The permutation returned is the same as:
//
//     MappingPermListList(ImageListOfTransformation(f, n),
//                         ImageListOfTransformation(g, n));
//
// where n = max{DegreeOfTransformation(f), DegreeOfTransformation(g)}.
// However, this is included to avoid the overhead of producing the image
// lists
// of f and g in the above.

static Obj FuncTRANS_IMG_CONJ(Obj self, Obj f, Obj g)
{
    Obj    perm;
    const UInt2 *ptf2, *ptg2;
    const UInt4 *ptf4, *ptg4;
    UInt4 *ptsrc, *ptdst, *ptp;
    UInt   def, deg, i, j, max, min;

    RequireTransformation(SELF_NAME, f);
    RequireTransformation(SELF_NAME, g);

    def = DEG_TRANS(f);
    deg = DEG_TRANS(g);
    max = MAX(def, deg);
    min = MIN(def, deg);

    // always return a T_PERM4 to reduce the amount of code in this function
    perm = NEW_PERM4(max);

    ptsrc = ResizeInitTmpTrans(2 * max);
    ptdst = ptsrc + max;

    ptp = ADDR_PERM4(perm);

    if (TNUM_OBJ(f) == T_TRANS2 && TNUM_OBJ(g) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        ptg2 = CONST_ADDR_TRANS2(g);

        for (i = 0; i < min; i++) {
            ptsrc[ptf2[i]] = 1;
            ptdst[ptg2[i]] = 1;
            ptp[ptf2[i]] = ptg2[i];
        }

        // if deg = min, then this isn't executed
        for (; i < deg; i++) {
            // ptsrc[i] = 1;
            ptdst[ptg2[i]] = 1;
            ptp[i] = ptg2[i];
        }

        // if def = min, then this isn't executed
        for (; i < def; i++) {
            ptsrc[ptf2[i]] = 1;
            ptdst[i] = 1;
            ptp[ptf2[i]] = i;
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS2 && TNUM_OBJ(g) == T_TRANS4) {
        ptf2 = CONST_ADDR_TRANS2(f);
        ptg4 = CONST_ADDR_TRANS4(g);

        for (i = 0; i < min; i++) {
            ptsrc[ptf2[i]] = 1;
            ptdst[ptg4[i]] = 1;
            ptp[ptf2[i]] = ptg4[i];
        }

        // if deg = min, then this isn't executed
        for (; i < deg; i++) {
            // ptsrc[i] = 1;
            ptdst[ptg4[i]] = 1;
            ptp[i] = ptg4[i];
        }

        // if def = min, then this isn't executed
        for (; i < def; i++) {
            // The only transformation created within this file that is of
            // type
            // T_TRANS4 and that does not have (internal) degree 65537 or
            // greater
            // is ID_TRANS4.
            ptsrc[ptf2[i]] = 1;
            ptdst[i] = 1;
            ptp[ptf2[i]] = i;
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS4 && TNUM_OBJ(g) == T_TRANS2) {
        ptf4 = CONST_ADDR_TRANS4(f);
        ptg2 = CONST_ADDR_TRANS2(g);

        for (i = 0; i < min; i++) {
            ptsrc[ptf4[i]] = 1;
            ptdst[ptg2[i]] = 1;
            ptp[ptf4[i]] = ptg2[i];
        }

        // if deg = min, then this isn't executed
        for (; i < deg; i++) {
            // The only transformation created within this file that is of
            // type
            // T_TRANS4 and that does not have (internal) degree 65537 or
            // greater
            // is ID_TRANS4.
            // ptsrc[i] = 1;
            ptdst[ptg2[i]] = 1;
            ptp[i] = ptg2[i];
        }

        // if def = min, then this isn't executed
        for (; i < def; i++) {
            ptsrc[ptf4[i]] = 1;
            ptdst[i] = 1;
            ptp[ptf4[i]] = i;
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS4 && TNUM_OBJ(g) == T_TRANS4) {
        ptf4 = CONST_ADDR_TRANS4(f);
        ptg4 = CONST_ADDR_TRANS4(g);

        for (i = 0; i < min; i++) {
            ptsrc[ptf4[i]] = 1;
            ptdst[ptg4[i]] = 1;
            ptp[ptf4[i]] = ptg4[i];
        }

        // if deg = min, then this isn't executed
        for (; i < deg; i++) {
            // ptsrc[i] = 1;
            ptdst[ptg4[i]] = 1;
            ptp[i] = ptg4[i];
        }

        // if def = min, then this isn't executed
        for (; i < def; i++) {
            ptsrc[ptf4[i]] = 1;
            ptdst[i] = 1;
            ptp[ptf4[i]] = i;
        }
    }

    // complete the permutation
    j = 0;
    for (i = 0; i < def; i++) {
        if (ptsrc[i] == 0) {
            while (ptdst[j] != 0) {
                j++;
            }
            ptp[i] = j;
            j++;
        }
    }
    return perm;
}

// Returns the flat kernel of <p> ^ -1 * f * <p> where f is any transformation
// such that ker(f) = <ker>, <p> is a permutation and <ker> is itself a flat
// kernel of transformation. This assumes (but doesn't check) that <p> is a
// permutation of [1 .. Length(<ker>)] regardless of its degree.

static Obj FuncPOW_KER_PERM(Obj self, Obj ker, Obj p)
{
    UInt    len, rank, i, dep;
    Obj     out;
    UInt4 * ptcnj, *ptlkp;
    const UInt4 * ptp4;
    const UInt2 * ptp2;

    RequirePermutation(SELF_NAME, p);

    len = LEN_LIST(ker);

    if (len == 0) {
        out = NEW_PLIST_IMM(T_PLIST_EMPTY, len);
        SET_LEN_PLIST(out, len);
        return out;
    }

    out = NEW_PLIST_IMM(T_PLIST_CYC, len);
    SET_LEN_PLIST(out, len);

    ResizeTmpTrans(2 * len);
    ptcnj = AddrTmpTrans();

    rank = 1;
    ptlkp = ptcnj + len;

    if (TNUM_OBJ(p) == T_PERM2) {
        dep = DEG_PERM2(p);
        ptp2 = CONST_ADDR_PERM2(p);

        if (dep <= len) {
            // form the conjugate in ptcnj and init the lookup
            for (i = 0; i < dep; i++) {
                // < p ^ - 1 * g * p > then < g > with ker( < g >) = < ker >
                ptcnj[ptp2[i]] = ptp2[INT_INTOBJ(ELM_LIST(ker, i + 1)) - 1];
                ptlkp[i] = 0;
            }
            for (; i < len; i++) {
                ptcnj[i] = IMAGE((UInt)INT_INTOBJ(ELM_LIST(ker, i + 1)) - 1,
                                 ptp2, dep);
                ptlkp[i] = 0;
            }
        }
        else {
            // dep > len but p fixes [1..len] setwise

            // form the conjugate in ptcnj and init the lookup
            for (i = 0; i < len; i++) {
                // < p ^ - 1 * g * p > then < g > with ker( < g >) = < ker >
                ptcnj[ptp2[i]] = ptp2[INT_INTOBJ(ELM_LIST(ker, i + 1)) - 1];
                ptlkp[i] = 0;
            }
        }
    }
    else {
        dep = DEG_PERM4(p);
        ptp4 = CONST_ADDR_PERM4(p);

        if (dep <= len) {
            // form the conjugate in ptcnj and init the lookup
            for (i = 0; i < dep; i++) {
                // < p ^ - 1 * g * p > then < g > with ker( < g >) = < ker >
                ptcnj[ptp4[i]] = ptp4[INT_INTOBJ(ELM_LIST(ker, i + 1)) - 1];
                ptlkp[i] = 0;
            }
            for (; i < len; i++) {
                ptcnj[i] = IMAGE((UInt)INT_INTOBJ(ELM_LIST(ker, i + 1)) - 1,
                                 ptp4, dep);
                ptlkp[i] = 0;
            }
        }
        else {
            // dep > len but p fixes [1..len] setwise

            // form the conjugate in ptcnj and init the lookup
            for (i = 0; i < len; i++) {
                // < p ^ - 1 * g * p > then < g > with ker( < g >) = < ker >
                ptcnj[ptp4[i]] = ptp4[INT_INTOBJ(ELM_LIST(ker, i + 1)) - 1];
                ptlkp[i] = 0;
            }
        }
    }

    // form the flat kernel
    for (i = 0; i < len; i++) {
        if (ptlkp[ptcnj[i]] == 0) {
            ptlkp[ptcnj[i]] = rank++;
        }
        SET_ELM_PLIST(out, i + 1, INTOBJ_INT(ptlkp[ptcnj[i]]));
    }
    return out;
}

// If <f> is a transformation and <X> is a flat kernel of a transformation,
// then we denote OnKernelAntiAction(X, f) by f ^ X. Suppose that x is a
// transformation with ker(x) = <X> and ker(<f>x) = f ^ ker(x) has the same
// number of classes as ker(x). Then INV_KER_TRANS(X, f) returns a
// transformation g such that g<f> ^ ker(x) = ker(x) = ker(gfx) and the action
// of g<f> on ker(x) is the identity.
template <typename TF, typename TG>
static Obj INV_KER_TRANS(Obj X, Obj f)
{
    Obj    g;
    const TF * ptf;
    TG *       ptg;
    UInt4 *    pttmp;
    UInt   deg, i, len;

    len = LEN_LIST(X);
    ResizeTmpTrans(len);

    deg = DEG_TRANS<TF>(f);
    g = NEW_TRANS<TG>(len);
    pttmp = AddrTmpTrans();
    ptf = CONST_ADDR_TRANS<TF>(f);
    ptg = ADDR_TRANS<TG>(g);
    if (deg >= len) {
        // calculate a transversal of f ^ ker(x) = ker(fx)
        for (i = 0; i < len; i++) {
            pttmp[INT_INTOBJ(ELM_LIST(X, ptf[i] + 1)) - 1] = i;
        }
    }
    else {
        for (i = 0; i < deg; i++) {
            pttmp[INT_INTOBJ(ELM_LIST(X, ptf[i] + 1)) - 1] = i;
        }
        for (; i < len; i++) {
            pttmp[INT_INTOBJ(ELM_LIST(X, i + 1)) - 1] = i;
        }
    }
    for (i = len; i >= 1; i--) {
        ptg[i - 1] = pttmp[INT_INTOBJ(ELM_LIST(X, i)) - 1];
    }
    return g;
}

static Obj FuncINV_KER_TRANS(Obj self, Obj X, Obj f)
{
    RequireTransformation(SELF_NAME, f);
    UInt len = LEN_LIST(X);

    if (TNUM_OBJ(f) == T_TRANS2) {
        if (len <= 65536) {
            return INV_KER_TRANS<UInt2, UInt2>(X, f);
        }
        else {
            return INV_KER_TRANS<UInt2, UInt4>(X, f);
        }
    }
    else {
        if (len <= 65536) {
            return INV_KER_TRANS<UInt4, UInt2>(X, f);
        }
        else {
            return INV_KER_TRANS<UInt4, UInt4>(X, f);
        }
    }
}

// Returns the same value as OnSets(set, f) except if set = [0], when the
// image
// set of <f> on [1 .. n] is returned instead. If the argument <set> is not
// [0], then the third argument is ignored.

static Obj FuncOnPosIntSetsTrans(Obj self, Obj set, Obj f, Obj n)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    const Obj * ptset;
    UInt    deg;
    Obj *   ptres, res;
    UInt    i, k;

    RequireTransformation(SELF_NAME, f);

    const UInt len = LEN_LIST(set);

    if (len == 0) {
        return set;
    }

    if (len == 1 && ELM_LIST(set, 1) == INTOBJ_INT(0)) {
        return FuncIMAGE_SET_TRANS_INT(self, f, n);
    }

    if (IS_PLIST(set)) {
        res = NEW_PLIST_WITH_MUTABILITY(IS_PLIST_MUTABLE(set), T_PLIST_CYC_SSORT, len);
        SET_LEN_PLIST(res, len);
    }
    else {
        // input is not a plain list, so we make a copy of it, and then also reuse
        // that copy for our output
        res = PLAIN_LIST_COPY(set);
        if (!IS_MUTABLE_OBJ(set))
            MakeImmutableNoRecurse(res);
        set = res;
    }

    ptset = CONST_ADDR_OBJ(set) + len;
    ptres = ADDR_OBJ(res) + len;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        for (i = len; 1 <= i; i--, ptset--, ptres--) {
            k = INT_INTOBJ(*ptset);
            if (k <= deg) {
                k = ptf2[k - 1] + 1;
            }
            *ptres = INTOBJ_INT(k);
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);
        for (i = len; 1 <= i; i--, ptset--, ptres--) {
            k = INT_INTOBJ(*ptset);
            if (k <= deg) {
                k = ptf4[k - 1] + 1;
            }
            *ptres = INTOBJ_INT(k);
        }
    }
    SortPlistByRawObj(res);
    REMOVE_DUPS_PLIST_INTOBJ(res);
    RetypeBagSM(res, T_PLIST_CYC_SSORT);
    return res;
}

/*******************************************************************************
 *******************************************************************************
 * GAP kernel functions for transformations
 *******************************************************************************
 *******************************************************************************/

// Returns the identity transformation.

static Obj OneTrans(Obj f)
{
    return IdentityTrans;
}

/*******************************************************************************
** Equality for transformations
*******************************************************************************/

static Int EqTrans22(Obj opL, Obj opR)
{
    UInt degL = DEG_TRANS2(opL);
    UInt degR = DEG_TRANS2(opR);
    const UInt2 * ptLstart = CONST_ADDR_TRANS2(opL);
    const UInt2 * ptRstart = CONST_ADDR_TRANS2(opR);

    const UInt2 * ptL;  // pointer to the left operand
    const UInt2 * ptR;  // pointer to the right operand
    UInt    p;          // loop variable

    // if perms/trans are different sizes, check final element as an early
    // check

    if (degL != degR) {
        if (degL < degR) {
            if (*(ptRstart + degR - 1) != (degR - 1)) {
                return 0;
            }
        }
        else {
            if (*(ptLstart + degL - 1) != (degL - 1)) {
                return 0;
            }
        }
    }

    // search for a difference and return False if you find one
    if (degL <= degR) {
        ptR = ptRstart + degL;
        for (p = degL; p < degR; p++) {
            if (*(ptR++) != p) {
                return 0;
            }
        }
        if (memcmp(ptLstart, ptRstart, degL * sizeof(UInt2)) != 0) {
            return 0;
        }
    }
    else {
        ptL = ptLstart + degR;
        for (p = degR; p < degL; p++) {
            if (*(ptL++) != p) {
                return 0;
            }
        }
        if (memcmp(ptLstart, ptRstart, degR * sizeof(UInt2)) != 0) {
            return 0;
        }
    }

    // otherwise they must be equal
    return 1;
}

static Int EqTrans44(Obj opL, Obj opR)
{
    UInt degL = DEG_TRANS4(opL);
    UInt degR = DEG_TRANS4(opR);
    const UInt4 * ptLstart = CONST_ADDR_TRANS4(opL);
    const UInt4 * ptRstart = CONST_ADDR_TRANS4(opR);

    const UInt4 * ptL;  // pointer to the left operand
    const UInt4 * ptR;  // pointer to the right operand
    UInt    p;          // loop variable

    // if perms/trans are different sizes, check final element as an early
    // check

    if (degL != degR) {
        if (degL < degR) {
            if (*(ptRstart + degR - 1) != (degR - 1)) {
                return 0;
            }
        }
        else {
            if (*(ptLstart + degL - 1) != (degL - 1)) {
                return 0;
            }
        }
    }

    // search for a difference and return False if you find one
    if (degL <= degR) {
        ptR = ptRstart + degL;
        for (p = degL; p < degR; p++) {
            if (*(ptR++) != p) {
                return 0;
            }
        }
        if (memcmp(ptLstart, ptRstart, degL * sizeof(UInt4)) != 0) {
            return 0;
        }
    }
    else {
        ptL = ptLstart + degR;
        for (p = degR; p < degL; p++) {
            if (*(ptL++) != p) {
                return 0;
            }
        }
        if (memcmp(ptLstart, ptRstart, degR * sizeof(UInt4)) != 0) {
            return 0;
        }
    }

    // otherwise they must be equal
    return 1;
}

static Int EqTrans24(Obj f, Obj g)
{
    UInt    i, def, deg;
    const UInt2 * ptf;
    const UInt4 * ptg;

    ptf = CONST_ADDR_TRANS2(f);
    ptg = CONST_ADDR_TRANS4(g);
    def = DEG_TRANS2(f);
    deg = DEG_TRANS4(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            if (*(ptf++) != *(ptg++)) {
                return 0;
            }
        }
        for (; i < deg; i++) {
            if (*(ptg++) != i) {
                return 0;
            }
        }
    }
    else {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        for (i = 0; i < deg; i++) {
            if (*(ptf++) != *(ptg++)) {
                return 0;
            }
        }
        for (; i < def; i++) {
            if (*(ptf++) != i) {
                return 0;
            }
        }
    }

    return 1;
}

static Int EqTrans42(Obj f, Obj g)
{
    return EqTrans24(g, f);
}

/*******************************************************************************
** Less than for transformations
*******************************************************************************/

template <typename TF, typename TG>
static Int LtTrans(Obj f, Obj g)
{
    UInt def = DEG_TRANS<TF>(f);
    UInt deg = DEG_TRANS<TG>(g);
    UInt i;

    const TF * ptf = CONST_ADDR_TRANS<TF>(f);
    const TG * ptg = CONST_ADDR_TRANS<TG>(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            if (ptf[i] != ptg[i]) {
                return ptf[i] < ptg[i];
            }
        }
        for (; i < deg; i++) {
            if (ptg[i] != i) {
                return i < ptg[i];
            }
        }
    }
    else {
        for (i = 0; i < deg; i++) {
            if (ptf[i] != ptg[i]) {
                return ptf[i] < ptg[i];
            }
        }
        for (; i < def; i++) {
            if (ptf[i] != i) {
                return ptf[i] < i;
            }
        }
    }
    return 0;
}


/*******************************************************************************
** Products for transformations
*******************************************************************************/

template <typename TF, typename TG>
static Obj ProdTrans(Obj f, Obj g)
{
    typedef typename ResultType<TF, TG>::type Res;

    UInt def = DEG_TRANS<TF>(f);
    UInt deg = DEG_TRANS<TG>(g);
    UInt i;

    Obj fg = NEW_TRANS<Res>(MAX(def, deg));

    Res *      ptfg = ADDR_TRANS<Res>(fg);
    const TF * ptf = CONST_ADDR_TRANS<TF>(f);
    const TG * ptg = CONST_ADDR_TRANS<TG>(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            *ptfg++ = ptg[*ptf++];
        }
        for (; i < deg; i++) {
            *ptfg++ = ptg[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *ptfg++ = IMAGE(ptf[i], ptg, deg);
        }
    }

    return fg;
}


/*******************************************************************************
** Products for a transformation and permutation
*******************************************************************************/

template <typename TF, typename TP>
static Obj ProdTransPerm(Obj f, Obj p)
{
    typedef typename ResultType<TF, TP>::type Res;

    UInt dep = DEG_PERM<TP>(p);
    UInt def = DEG_TRANS<TF>(f);
    UInt i;

    Obj fp = NEW_TRANS<Res>(MAX(def, dep));

    Res *      ptfp = ADDR_TRANS<Res>(fp);
    const TF * ptf = CONST_ADDR_TRANS<TF>(f);
    const TP * ptp = CONST_ADDR_PERM<TP>(p);

    if (def <= dep) {
        for (i = 0; i < def; i++) {
            *ptfp++ = ptp[*ptf++];
        }
        for (; i < dep; i++) {
            *ptfp++ = ptp[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *ptfp++ = IMAGE(ptf[i], ptp, dep);
        }
    }
    return fp;
}


/*******************************************************************************
** Products for a permutation and transformation
*******************************************************************************/

template <typename TP, typename TF>
static Obj ProdPermTrans(Obj p, Obj f)
{
    typedef typename ResultType<TF, TP>::type Res;

    UInt dep = DEG_PERM<TP>(p);
    UInt def = DEG_TRANS<TF>(f);
    UInt i;

    Obj pf = NEW_TRANS<Res>(MAX(def, dep));

    Res *      ptpf = ADDR_TRANS<Res>(pf);
    const TF * ptf = CONST_ADDR_TRANS<TF>(f);
    const TP * ptp = CONST_ADDR_PERM<TP>(p);

    if (dep <= def) {
        for (i = 0; i < dep; i++) {
            *ptpf++ = ptf[*ptp++];
        }
        for (; i < def; i++) {
            *ptpf++ = ptf[i];
        }
    }
    else {
        for (i = 0; i < dep; i++) {
            *ptpf++ = IMAGE(ptp[i], ptf, def);
        }
    }
    return pf;
}


/*******************************************************************************
** Conjugate a transformation f by a permutation p: p ^ -1 * f * p
*******************************************************************************/

template <typename TF, typename TP>
static Obj PowTransPerm(Obj f, Obj p)
{
    typedef typename ResultType<TF, TP>::type Res;

    UInt dep = DEG_PERM<TP>(p);
    UInt def = DEG_TRANS<TF>(f);
    UInt decnj = MAX(dep, def);
    UInt i;

    Obj cnj = NEW_TRANS<Res>(decnj);

    Res *      ptcnj = ADDR_TRANS<Res>(cnj);
    const TF * ptf = CONST_ADDR_TRANS<TF>(f);
    const TP * ptp = CONST_ADDR_PERM<TP>(p);

    if (def == dep) {
        for (i = 0; i < decnj; i++) {
            ptcnj[ptp[i]] = ptp[ptf[i]];
        }
    }
    else {
        for (i = 0; i < decnj; i++) {
            ptcnj[IMAGE(i, ptp, dep)] = IMAGE(IMAGE(i, ptf, def), ptp, dep);
        }
    }
    return cnj;
}


/*******************************************************************************
** Left quotient a transformation f by a permutation p: p ^ -1 * f
*******************************************************************************/

template <typename TL, typename TR>
static Obj LQuoPermTrans(Obj opL, Obj opR)
{
    typedef typename ResultType<TL, TR>::type Res;

    UInt degL = DEG_PERM<TL>(opL);
    UInt degR = DEG_TRANS<TR>(opR);
    UInt degM = degL < degR ? degR : degL;
    UInt p;

    Obj mod = NEW_TRANS<Res>(degM);

    Res *      ptM = ADDR_TRANS<Res>(mod);
    const TL * ptL = CONST_ADDR_PERM<TL>(opL);
    const TR * ptR = CONST_ADDR_TRANS<TR>(opR);

    if (degL <= degR) {
        for (p = 0; p < degL; p++) {
            ptM[*(ptL++)] = *(ptR++);
        }
        for (p = degL; p < degR; p++) {
            ptM[p] = *(ptR++);
        }
    }
    else {
        for (p = 0; p < degR; p++) {
            ptM[*(ptL++)] = *(ptR++);
        }
        for (p = degR; p < degL; p++) {
            ptM[*(ptL++)] = p;
        }
    }

    return mod;
}


/*******************************************************************************
** Apply a transformation to a point
*******************************************************************************/

static Obj PowIntTrans2(Obj point, Obj f)
{
    Int img;

    if (TNUM_OBJ(point) == T_INTPOS) {
        return point;
    }

    img = GetPositiveSmallInt("Tran. Operations", point);

    if ((UInt)img <= DEG_TRANS2(f)) {
        img = (CONST_ADDR_TRANS2(f))[img - 1] + 1;
    }

    return INTOBJ_INT(img);
}

static Obj PowIntTrans4(Obj point, Obj f)
{
    Int img;

    if (TNUM_OBJ(point) == T_INTPOS) {
        return point;
    }

    img = GetPositiveSmallInt("Tran. Operations", point);

    if ((UInt)img <= DEG_TRANS4(f)) {
        img = (CONST_ADDR_TRANS4(f))[img - 1] + 1;
    }

    return INTOBJ_INT(img);
}

/****************************************************************************
**
*F  OnSetsTrans( <set>, <f> ) . . . . . . . . .  operations on sets of points
**
**  'OnSetsTrans' returns the  image of the tuple <set> under the
**  transformation <f>.  It is called from 'FuncOnSets'.
**
**  The input <set> must be a non-empty set, i.e., plain, dense and strictly
**  sorted. This is not verified.
*/
Obj OnSetsTrans(Obj set, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    deg;
    Obj *   ptres, tmp, res;
    UInt    i, isint, k;

    // copy the list into a mutable plist, which we will then modify in place
    res = PLAIN_LIST_COPY(set);
    const UInt len = LEN_PLIST(res);

    ptres = ADDR_OBJ(res) + 1;
    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        // loop over the entries of the tuple
        isint = 1;
        for (i = 1; i <= len; i++, ptres++) {
            tmp = *ptres;
            if (IS_POS_INTOBJ(tmp)) {
                k = INT_INTOBJ(tmp);
                if (k <= deg) {
                    *ptres = INTOBJ_INT(ptf2[k - 1] + 1);
                }
            }
            else {
                isint = 0;
                tmp = POW(tmp, f);
                ptres = ADDR_OBJ(res) + i;
                ptf2 = CONST_ADDR_TRANS2(f);
                *ptres = tmp;
                CHANGED_BAG(res);
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);

        // loop over the entries of the tuple
        isint = 1;
        for (i = 1; i <= len; i++, ptres++) {
            tmp = *ptres;
            if (IS_POS_INTOBJ(tmp)) {
                k = INT_INTOBJ(tmp);
                if (k <= deg) {
                    *ptres = INTOBJ_INT(ptf4[k - 1] + 1);
                }
            }
            else {
                isint = 0;
                tmp = POW(tmp, f);
                ptres = ADDR_OBJ(res) + i;
                ptf4 = CONST_ADDR_TRANS4(f);
                *ptres = tmp;
                CHANGED_BAG(res);
            }
        }
    }

    // sort the result and remove dups
    if (isint) {
        SortPlistByRawObj(res);
        REMOVE_DUPS_PLIST_INTOBJ(res);
        RetypeBagSM(res, T_PLIST_CYC_SSORT);
    }
    else {
        SortDensePlist(res);
        RemoveDupsDensePlist(res);
        RESET_FILT_LIST(res, FN_IS_SSORT);
    }

    return res;
}

/****************************************************************************
**
*F  OnTuplesTrans( <tup>, <f> ) . . . . . . .  operations on tuples of points
**
**  'OnTuplesTrans'  returns  the  image  of  the  tuple  <tup>   under  the
**  transformation <f>.  It is called from 'FuncOnTuples'.
**
**  The input <tup> must be a non-empty and dense plain list. This is not
**  verified.
*/
Obj OnTuplesTrans(Obj tup, Obj f)
{
    const UInt2 * ptf2;
    const UInt4 * ptf4;
    UInt    deg, i, k;
    Obj *   ptres, res, tmp;

    // copy the list into a mutable plist, which we will then modify in place
    res = PLAIN_LIST_COPY(tup);
    RESET_FILT_LIST(res, FN_IS_NSORT);
    const UInt len = LEN_PLIST(res);

    ptres = ADDR_OBJ(res) + 1;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = CONST_ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);

        // loop over the entries of the tuple
        for (i = 1; i <= len; i++, ptres++) {
            tmp = *ptres;
            if (IS_POS_INTOBJ(tmp)) {
                k = INT_INTOBJ(tmp);
                if (k <= deg) {
                    k = ptf2[k - 1] + 1;
                }
                *ptres = INTOBJ_INT(k);
            }
            else if (tmp == NULL) {
                ErrorQuit("OnTuples: <tup> must not contain holes", 0, 0);
            }
            else {
                tmp = POW(tmp, f);
                ptres = ADDR_OBJ(res) + i;
                ptf2 = CONST_ADDR_TRANS2(f);
                *ptres = tmp;
                CHANGED_BAG(res);
            }
        }
    }
    else {
        ptf4 = CONST_ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);

        // loop over the entries of the tuple
        for (i = 1; i <= len; i++, ptres++) {
            tmp = *ptres;
            if (IS_POS_INTOBJ(tmp)) {
                k = INT_INTOBJ(tmp);
                if (k <= deg) {
                    k = ptf4[k - 1] + 1;
                }
                *ptres = INTOBJ_INT(k);
            }
            else if (tmp == NULL) {
                ErrorQuit("OnTuples: <tup> must not contain holes", 0, 0);
            }
            else {
                tmp = POW(tmp, f);
                ptres = ADDR_OBJ(res) + i;
                ptf4 = CONST_ADDR_TRANS4(f);
                *ptres = tmp;
                CHANGED_BAG(res);
            }
        }
    }
    return res;
}

/*******************************************************************************
** Save and load workspace, garbage collection, IS_TRANS
*******************************************************************************/

#ifdef GAP_ENABLE_SAVELOAD
// Save and load
static void SaveTrans2(Obj f)
{
    const UInt2 * ptr;
    UInt    len, i;
    ptr = CONST_ADDR_TRANS2(f);    // save the image list
    len = DEG_TRANS2(f);
    for (i = 0; i < len; i++) {
        SaveUInt2(*ptr++);
    }
}

static void LoadTrans2(Obj f)
{
    UInt2 * ptr;
    UInt    len, i;
    len = DEG_TRANS2(f);
    ptr = ADDR_TRANS2(f);
    for (i = 0; i < len; i++) {
        *ptr++ = LoadUInt2();
    }
}

static void SaveTrans4(Obj f)
{
    const UInt4 * ptr;
    UInt    len, i;
    ptr = CONST_ADDR_TRANS4(f);    // save the image list
    len = DEG_TRANS4(f);
    for (i = 0; i < len; i++) {
        SaveUInt4(*ptr++);
    }
}

static void LoadTrans4(Obj f)
{
    UInt4 * ptr;
    UInt    len, i;
    len = DEG_TRANS4(f);
    ptr = ADDR_TRANS4(f);
    for (i = 0; i < len; i++) {
        *ptr++ = LoadUInt4();
    }
}
#endif


static Obj TYPE_TRANS2;

static Obj TypeTrans2(Obj f)
{
    return TYPE_TRANS2;
}

static Obj TYPE_TRANS4;

static Obj TypeTrans4(Obj f)
{
    return TYPE_TRANS4;
}

static Obj IsTransFilt;

static Obj FiltIS_TRANS(Obj self, Obj val)
{
    if (TNUM_OBJ(val) == T_TRANS2 || TNUM_OBJ(val) == T_TRANS4) {
        return True;
    }
    else if (TNUM_OBJ(val) < FIRST_EXTERNAL_TNUM) {
        return False;
    }
    else {
        return DoFilter(self, val);
    }
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_TRANS2, "transformation (small)" },
  { T_TRANS4, "transformation (large)" },
  { -1, "" }
};

/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts[] = {

    GVAR_FILT(IS_TRANS, "obj", &IsTransFilt),
    { 0, 0, 0, 0, 0 }

};

/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_1ARGS(TransformationNC, list),
    GVAR_FUNC_2ARGS(TransformationListListNC, src, ran),
    GVAR_FUNC_1ARGS(DegreeOfTransformation, f),
    GVAR_FUNC_2ARGS(HASH_FUNC_FOR_TRANS, f, data),
    GVAR_FUNC_1ARGS(RANK_TRANS, f),
    GVAR_FUNC_2ARGS(RANK_TRANS_INT, f, n),
    GVAR_FUNC_2ARGS(RANK_TRANS_LIST, f, list),
    GVAR_FUNC_1ARGS(LARGEST_MOVED_PT_TRANS, f),
    GVAR_FUNC_1ARGS(LARGEST_IMAGE_PT, f),
    GVAR_FUNC_1ARGS(SMALLEST_MOVED_PT_TRANS, f),
    GVAR_FUNC_1ARGS(SMALLEST_IMAGE_PT, f),
    GVAR_FUNC_1ARGS(NR_MOVED_PTS_TRANS, f),
    GVAR_FUNC_1ARGS(MOVED_PTS_TRANS, f),
    GVAR_FUNC_2ARGS(IMAGE_LIST_TRANS_INT, f, n),
    GVAR_FUNC_1ARGS(FLAT_KERNEL_TRANS, f),
    GVAR_FUNC_2ARGS(FLAT_KERNEL_TRANS_INT, f, n),
    GVAR_FUNC_1ARGS(IMAGE_SET_TRANS, f),
    GVAR_FUNC_1ARGS(UNSORTED_IMAGE_SET_TRANS, f),
    GVAR_FUNC_2ARGS(IMAGE_SET_TRANS_INT, f, n),
    GVAR_FUNC_2ARGS(KERNEL_TRANS, f, n),
    GVAR_FUNC_2ARGS(PREIMAGES_TRANS_INT, f, pt),
    GVAR_FUNC_1ARGS(AS_TRANS_PERM, f),
    GVAR_FUNC_2ARGS(AS_TRANS_PERM_INT, f, n),
    GVAR_FUNC_1ARGS(AS_PERM_TRANS, f),
    GVAR_FUNC_1ARGS(PermutationOfImage, f),
    GVAR_FUNC_2ARGS(RestrictedTransformation, f, list),
    GVAR_FUNC_2ARGS(AS_TRANS_TRANS, f, m),
    GVAR_FUNC_2ARGS(TRIM_TRANS, f, m),
    GVAR_FUNC_2ARGS(IsInjectiveListTrans, list, obj),
    GVAR_FUNC_2ARGS(PermLeftQuoTransformationNC, f, g),
    GVAR_FUNC_2ARGS(TRANS_IMG_KER_NC, img, ker),
    GVAR_FUNC_2ARGS(IDEM_IMG_KER_NC, img, ker),
    GVAR_FUNC_1ARGS(InverseOfTransformation, f),
    GVAR_FUNC_2ARGS(INV_LIST_TRANS, list, f),
    GVAR_FUNC_2ARGS(TRANS_IMG_CONJ, f, g),
    GVAR_FUNC_1ARGS(IndexPeriodOfTransformation, f),
    GVAR_FUNC_1ARGS(SMALLEST_IDEM_POW_TRANS, f),
    GVAR_FUNC_2ARGS(POW_KER_PERM, ker, f),
    GVAR_FUNC_3ARGS(ON_KERNEL_ANTI_ACTION, ker, f, n),
    GVAR_FUNC_2ARGS(INV_KER_TRANS, ker, f),
    GVAR_FUNC_1ARGS(IS_IDEM_TRANS, f),
    GVAR_FUNC_1ARGS(IS_ID_TRANS, f),
    GVAR_FUNC_1ARGS(COMPONENT_REPS_TRANS, f),
    GVAR_FUNC_1ARGS(NR_COMPONENTS_TRANS, f),
    GVAR_FUNC_1ARGS(COMPONENTS_TRANS, f),
    GVAR_FUNC_2ARGS(COMPONENT_TRANS_INT, f, pt),
    GVAR_FUNC_2ARGS(CYCLE_TRANS_INT, f, pt),
    GVAR_FUNC_1ARGS(CYCLES_TRANS, f),
    GVAR_FUNC_2ARGS(CYCLES_TRANS_LIST, f, pt),
    GVAR_FUNC_1ARGS(LEFT_ONE_TRANS, f),
    GVAR_FUNC_1ARGS(RIGHT_ONE_TRANS, f),
    GVAR_FUNC_3ARGS(OnPosIntSetsTrans, set, f, n),
    { 0, 0, 0, 0, 0 }

};


/******************************************************************************
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking functions                                       */
    InitMarkFuncBags(T_TRANS2, MarkThreeSubBags);
    InitMarkFuncBags(T_TRANS4, MarkThreeSubBags);

#ifdef HPCGAP
    MakeBagTypePublic(T_TRANS2);
    MakeBagTypePublic(T_TRANS4);
#endif

    /* install the type functions                                          */
    ImportGVarFromLibrary("TYPE_TRANS2", &TYPE_TRANS2);
    ImportGVarFromLibrary("TYPE_TRANS4", &TYPE_TRANS4);

    TypeObjFuncs[T_TRANS2] = TypeTrans2;
    TypeObjFuncs[T_TRANS4] = TypeTrans4;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable(GVarFilts);
    InitHdlrFuncsFromTable(GVarFuncs);

/* make the buffer bag                                                 */
#ifndef HPCGAP
    InitGlobalBag(&MODULE_STATE(Trans).TmpTrans, "src/trans.c:TmpTrans");
#endif

    // make the identity trans
    InitGlobalBag(&IdentityTrans, "src/trans.c:IdentityTrans");

#ifdef GAP_ENABLE_SAVELOAD
    /* install the saving functions */
    SaveObjFuncs[T_TRANS2] = SaveTrans2;
    LoadObjFuncs[T_TRANS2] = LoadTrans2;
    SaveObjFuncs[T_TRANS4] = SaveTrans4;
    LoadObjFuncs[T_TRANS4] = LoadTrans4;
#endif

    /* install the comparison methods                                      */
    EqFuncs[T_TRANS2][T_TRANS2] = EqTrans22;
    EqFuncs[T_TRANS2][T_TRANS4] = EqTrans24;
    EqFuncs[T_TRANS4][T_TRANS2] = EqTrans42;
    EqFuncs[T_TRANS4][T_TRANS4] = EqTrans44;
    LtFuncs[T_TRANS2][T_TRANS2] = LtTrans<UInt2, UInt2>;
    LtFuncs[T_TRANS2][T_TRANS4] = LtTrans<UInt2, UInt4>;
    LtFuncs[T_TRANS4][T_TRANS2] = LtTrans<UInt4, UInt2>;
    LtFuncs[T_TRANS4][T_TRANS4] = LtTrans<UInt4, UInt4>;

    /* install the binary operations */
    ProdFuncs[T_TRANS2][T_TRANS2] = ProdTrans<UInt2, UInt2>;
    ProdFuncs[T_TRANS2][T_TRANS4] = ProdTrans<UInt2, UInt4>;
    ProdFuncs[T_TRANS4][T_TRANS2] = ProdTrans<UInt4, UInt2>;
    ProdFuncs[T_TRANS4][T_TRANS4] = ProdTrans<UInt4, UInt4>;
    ProdFuncs[T_TRANS2][T_PERM2] = ProdTransPerm<UInt2, UInt2>;
    ProdFuncs[T_TRANS2][T_PERM4] = ProdTransPerm<UInt2, UInt4>;
    ProdFuncs[T_TRANS4][T_PERM2] = ProdTransPerm<UInt4, UInt2>;
    ProdFuncs[T_TRANS4][T_PERM4] = ProdTransPerm<UInt4, UInt4>;
    ProdFuncs[T_PERM2][T_TRANS2] = ProdPermTrans<UInt2, UInt2>;
    ProdFuncs[T_PERM2][T_TRANS4] = ProdPermTrans<UInt2, UInt4>;
    ProdFuncs[T_PERM4][T_TRANS2] = ProdPermTrans<UInt4, UInt2>;
    ProdFuncs[T_PERM4][T_TRANS4] = ProdPermTrans<UInt4, UInt4>;
    PowFuncs[T_TRANS2][T_PERM2] = PowTransPerm<UInt2, UInt2>;
    PowFuncs[T_TRANS2][T_PERM4] = PowTransPerm<UInt2, UInt4>;
    PowFuncs[T_TRANS4][T_PERM2] = PowTransPerm<UInt4, UInt2>;
    PowFuncs[T_TRANS4][T_PERM4] = PowTransPerm<UInt4, UInt4>;
    // for quotients of a transformation by a permutation, we rely on the
    // default handler 'QuoDefault'; that uses the inverse of the permutation,
    // which is cached
    LQuoFuncs[T_PERM2][T_TRANS2] = LQuoPermTrans<UInt2, UInt2>;
    LQuoFuncs[T_PERM2][T_TRANS4] = LQuoPermTrans<UInt2, UInt4>;
    LQuoFuncs[T_PERM4][T_TRANS2] = LQuoPermTrans<UInt4, UInt2>;
    LQuoFuncs[T_PERM4][T_TRANS4] = LQuoPermTrans<UInt4, UInt4>;
    PowFuncs[T_INT][T_TRANS2] = PowIntTrans2;
    PowFuncs[T_INT][T_TRANS4] = PowIntTrans4;
    PowFuncs[T_INTPOS][T_TRANS2] = PowIntTrans2;
    PowFuncs[T_INTPOS][T_TRANS4] = PowIntTrans4;

    /* install the 'ONE' function for transformations */
    OneFuncs[T_TRANS2] = OneTrans;
    OneMutFuncs[T_TRANS2] = OneTrans;
    OneFuncs[T_TRANS4] = OneTrans;
    OneMutFuncs[T_TRANS4] = OneTrans;

    return 0;
}

/******************************************************************************
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable(GVarFuncs);
    InitGVarFiltsFromTable(GVarFilts);
    IdentityTrans = NEW_TRANS2(0);

    // We make the next transformation to allow testing of some parts of the
    // code which would not otherwise be accessible, since no other
    // transformation created in this file is a T_TRANS4 unless its internal
    // degree is > 65536. Such transformation can be created by packages with
    // a
    // kernel module, and so we introduce the next transformation for testing
    // purposes.
    Obj ID_TRANS4 = NEW_TRANS4(0);
    AssReadOnlyGVar(GVarName("ID_TRANS4"), ID_TRANS4);

    return 0;
}

static Int InitModuleState(void)
{
    MODULE_STATE(Trans).TmpTrans = 0;

    return 0;
}

/****************************************************************************
**
*F  InitInfoTrans()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
 /* type        = */ MODULE_BUILTIN,
 /* name        = */ "trans",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 0,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ 0,
 /* moduleStateSize      = */ sizeof(TransModuleState),
 /* moduleStateOffsetPtr = */ &TransStateOffset,
 /* initModuleState      = */ InitModuleState,
 /* destroyModuleState   = */ 0,
};

StructInitInfo * InitInfoTrans(void)
{
    return &module;
}
