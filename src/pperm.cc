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
 * A partial perm is of the form:
 *
 * [image set, domain, codegree, entries of image list]
 *
 * An element of the internal rep of a partial perm in T_PPERM2 must be
 * at most 65535 and be of UInt2. The <codegree> is just the degree of
 * the inverse or equivalently the maximum element of the image.
 *
 *****************************************************************************/

extern "C" {

#include "pperm.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "gapstate.h"
#include "gvars.h"
#include "integer.h"
#include "intfuncs.h"
#include "io.h"
#include "listfunc.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "permutat.h"
#include "plist.h"
#include "saveload.h"

} // extern "C"

#include "permutat_intern.hh"


//
// convert TNUM to underlying C data type
//
template <UInt tnum>
struct DataType;

template <>
struct DataType<T_PPERM2> {
    typedef UInt2 type;
};
template <>
struct DataType<T_PPERM4> {
    typedef UInt4 type;
};


//
// convert underlying C data type to TNUM
//
template <typename T>
struct T_PPERM {
};
template <>
struct T_PPERM<UInt2> {
    static const UInt tnum = T_PPERM2;
};
template <>
struct T_PPERM<UInt4> {
    static const UInt tnum = T_PPERM4;
};


//
// Various helper functions for partial permutations
//
template <typename T>
static void ASSERT_IS_PPERM(Obj pperm)
{
    GAP_ASSERT(TNUM_OBJ(pperm) == T_PPERM<T>::tnum);
}

template <typename T>
static inline T * ADDR_PPERM(Obj f)
{
    ASSERT_IS_PPERM<T>(f);
    return (T *)(ADDR_OBJ(f) + 2) + 1;
}

template <typename T>
static inline const T * CONST_ADDR_PPERM(Obj f)
{
    ASSERT_IS_PPERM<T>(f);
    return (const T *)(CONST_ADDR_OBJ(f) + 2) + 1;
}

template <typename T>
static inline UInt DEG_PPERM(Obj f)
{
    ASSERT_IS_PPERM<T>(f);
    return (UInt)(SIZE_OBJ(f) - sizeof(T) - 2 * sizeof(Obj)) / sizeof(T);
}


#define MAX(a, b) (a < b ? b : a)
#define MIN(a, b) (a < b ? a : b)

#define IMAGEPP(i, ptf, deg) (i <= deg ? ptf[i - 1] : 0)

static Obj EmptyPartialPerm;

#define RequirePartialPerm(funcname, op)                                     \
    RequireArgumentCondition(funcname, op, IS_PPERM(op),                     \
                             "must be a partial permutation")


static ModuleStateOffset PPermStateOffset = -1;

typedef struct {

    /**************************************************************************
     *
     *V TmpPPerm . . . . . . . handle of the buffer bag of the pperm package
     *
     * 'TmpPPerm' is the handle of a bag of type 'T_PPERM4', which is
     * created at initialization time of this package.  Functions in this
     * package can use this bag for  whatever purpose they want.  They have
     * to make sure of course that it is large enough.
     *
     * The buffer is *not* guaranteed to have any particular value, routines
     * that require a zero-initialization need to do this at the start.
     */
    Obj TmpPPerm;

} PPermModuleState;


#define TmpPPerm MODULE_STATE(PPerm).TmpPPerm

static inline void ResizeTmpPPerm(UInt len)
{
    if (TmpPPerm == (Obj)0) {
        TmpPPerm =
            NewBag(T_PPERM4, (len + 1) * sizeof(UInt4) + 2 * sizeof(Obj));
    }
    else if (SIZE_OBJ(TmpPPerm) <
             (len + 1) * sizeof(UInt4) + 2 * sizeof(Obj)) {
        ResizeBag(TmpPPerm, (len + 1) * sizeof(UInt4) + 2 * sizeof(Obj));
    }
}

/*****************************************************************************
 * Static functions for partial perms
 *****************************************************************************/

template <typename T>
static inline UInt GET_CODEG_PPERM(Obj f)
{
    ASSERT_IS_PPERM<T>(f);
    return *(const T *)(CONST_ADDR_OBJ(f) + 2);
}

template <typename T>
static inline void SET_CODEG_PPERM(Obj f, T codeg)
{
    ASSERT_IS_PPERM<T>(f);
    *(T *)(ADDR_OBJ(f) + 2) = codeg;
}

template <typename T>
static UInt CODEG_PPERM(Obj f)
{
    ASSERT_IS_PPERM<T>(f);
    if (GET_CODEG_PPERM<T>(f) != 0) {
        return GET_CODEG_PPERM<T>(f);
    }
    // The following is only ever entered by the EmptyPartialPerm.
    UInt    codeg = 0;
    UInt    i;
    const T * ptf = CONST_ADDR_PPERM<T>(f);
    for (i = 0; i < DEG_PPERM<T>(f); i++) {
        if (ptf[i] > codeg) {
            codeg = ptf[i];
        }
    }
    SET_CODEG_PPERM<T>(f, codeg);
    return codeg;
}

static inline void SET_CODEG_PPERM2(Obj f, UInt2 codeg)
{
    SET_CODEG_PPERM<UInt2>(f, codeg);
}

static inline void SET_CODEG_PPERM4(Obj f, UInt4 codeg)
{
    SET_CODEG_PPERM<UInt4>(f, codeg);
}

UInt CODEG_PPERM2(Obj f)
{
    return CODEG_PPERM<UInt2>(f);
}

UInt CODEG_PPERM4(Obj f)
{
    return CODEG_PPERM<UInt4>(f);
}

template <typename T>
static inline Obj NEW_PPERM(UInt deg)
{
    return NewBag(T_PPERM<T>::tnum, (deg + 1) * sizeof(T) + 2 * sizeof(Obj));

}

Obj NEW_PPERM2(UInt deg)
{
    // No assert since the values stored in this pperm must be UInt2s but the
    // degree might be a UInt4.
    return NEW_PPERM<UInt2>(deg);
}

Obj NEW_PPERM4(UInt deg)
{
    return NEW_PPERM<UInt4>(deg);
}

static inline Obj IMG_PPERM(Obj f)
{
    GAP_ASSERT(IS_PPERM(f));
    return CONST_ADDR_OBJ(f)[0];
}

static inline Obj DOM_PPERM(Obj f)
{
    GAP_ASSERT(IS_PPERM(f));
    return CONST_ADDR_OBJ(f)[1];
}

static inline void SET_IMG_PPERM(Obj f, Obj img)
{
    GAP_ASSERT(IS_PPERM(f));
    GAP_ASSERT(IS_PLIST(img) && !IS_PLIST_MUTABLE(img));
    GAP_ASSERT(DOM_PPERM(f) == NULL ||
               LEN_PLIST(img) == LEN_PLIST(DOM_PPERM(f)));
    // TODO check entries of img are valid
    ADDR_OBJ(f)[0] = img;
}

static inline void SET_DOM_PPERM(Obj f, Obj dom)
{
    GAP_ASSERT(IS_PPERM(f));
    GAP_ASSERT(IS_PLIST(dom) && !IS_PLIST_MUTABLE(dom));
    GAP_ASSERT(IMG_PPERM(f) == NULL ||
               LEN_PLIST(dom) == LEN_PLIST(IMG_PPERM(f)));
    // TODO check entries of img are valid
    ADDR_OBJ(f)[1] = dom;
}

// find domain and img set (unsorted) return the rank

template <typename T>
static UInt INIT_PPERM(Obj f)
{
    ASSERT_IS_PPERM<T>(f);

    UInt    deg, rank, i;
    T *     ptf;
    Obj     img, dom;

    deg = DEG_PPERM<T>(f);

    if (deg == 0) {
        dom = NewImmutableEmptyPlist();
        SET_DOM_PPERM(f, dom);
        SET_IMG_PPERM(f, dom);
        CHANGED_BAG(f);
        return deg;
    }

    dom = NEW_PLIST_IMM(T_PLIST_CYC_SSORT, deg);
    img = NEW_PLIST_IMM(T_PLIST_CYC, deg);

    /* renew the ptr in case of garbage collection */
    ptf = ADDR_PPERM<T>(f);

    rank = 0;
    for (i = 0; i < deg; i++) {
        if (ptf[i] != 0) {
            rank++;
            SET_ELM_PLIST(dom, rank, INTOBJ_INT(i + 1));
            SET_ELM_PLIST(img, rank, INTOBJ_INT(ptf[i]));
        }
    }
    GAP_ASSERT(rank != 0);    // rank = 0 => deg = 0, so this is not allowed

    SHRINK_PLIST(img, (Int)rank);
    SET_LEN_PLIST(img, (Int)rank);
    SHRINK_PLIST(dom, (Int)rank);
    SET_LEN_PLIST(dom, (Int)rank);

    SET_DOM_PPERM(f, dom);
    SET_IMG_PPERM(f, img);
    CHANGED_BAG(f);
    return rank;
}

static UInt INIT_PPERM(Obj f)
{
    if (TNUM_OBJ(f) == T_PPERM2) {
        return INIT_PPERM<UInt2>(f);
    }
    else {
        return INIT_PPERM<UInt4>(f);
    }
}

template <typename T>
static UInt RANK_PPERM(Obj f)
{
    ASSERT_IS_PPERM<T>(f);
    return (IMG_PPERM(f) == NULL ? INIT_PPERM<T>(f)
                                 : LEN_PLIST(IMG_PPERM(f)));
}

UInt RANK_PPERM2(Obj f)
{
    return RANK_PPERM<UInt2>(f);
}

UInt RANK_PPERM4(Obj f)
{
    return RANK_PPERM<UInt4>(f);
}

static Obj SORT_PLIST_INTOBJ(Obj res)
{
    GAP_ASSERT(IS_PLIST(res));
    if (LEN_PLIST(res) == 0)
        return res;

    SortPlistByRawObj(res);
    RetypeBagSM(res, T_PLIST_CYC_SSORT);
    return res;
}

template <typename T>
static Obj PreImagePPermInt(Obj pt, Obj f)
{
    GAP_ASSERT(IS_INTOBJ(pt));
    ASSERT_IS_PPERM<T>(f);

    const T * ptf;
    UInt    i, cpt, deg;

    cpt = INT_INTOBJ(pt);
    if (cpt > CODEG_PPERM<T>(f))
        return Fail;

    i = 0;
    ptf = CONST_ADDR_PPERM<T>(f);
    deg = DEG_PPERM<T>(f);
    while (i < deg && ptf[i] != cpt)
        i++;
    if (i == deg || ptf[i] != cpt)
        return Fail;
    return INTOBJ_INT(i + 1);
}

/*****************************************************************************
 * GAP functions for partial perms
 *****************************************************************************/

static Obj FuncEmptyPartialPerm(Obj self)
{
    return EmptyPartialPerm;
}

/* method for creating a partial perm */
static Obj FuncDensePartialPermNC(Obj self, Obj img)
{
    RequireSmallList("DensePartialPermNC", img);

    UInt    deg, i, j, codeg;
    UInt2 * ptf2;
    UInt4 * ptf4;
    Obj     f;

    if (LEN_LIST(img) == 0)
        return EmptyPartialPerm;

    // remove trailing 0s
    deg = LEN_LIST(img);
    while (deg > 0 && ELM_LIST(img, deg) == INTOBJ_INT(0))
        deg--;

    if (deg == 0)
        return EmptyPartialPerm;

    // find if we are PPERM2 or PPERM4
    codeg = 0;
    i = deg;
    while (codeg < 65536 && i > 0) {
        j = INT_INTOBJ(ELM_LIST(img, i--));
        if (j > codeg)
            codeg = j;
    }
    if (codeg < 65536) {
        f = NEW_PPERM2(deg);
        ptf2 = ADDR_PPERM2(f);
        for (i = 0; i < deg; i++) {
            j = INT_INTOBJ(ELM_LIST(img, i + 1));
            *ptf2++ = (UInt2)j;
        }
        SET_CODEG_PPERM2(f, codeg);    // codeg is already known
    }
    else {
        f = NEW_PPERM4(deg);
        ptf4 = ADDR_PPERM4(f);
        for (i = 0; i < deg; i++) {
            j = INT_INTOBJ(ELM_LIST(img, i + 1));
            if (j > codeg)
                codeg = j;
            *ptf4++ = (UInt4)j;
        }
        SET_CODEG_PPERM4(f, codeg);
    }
    return f;
}

/* assumes that dom is a set and that img is duplicatefree */
static Obj FuncSparsePartialPermNC(Obj self, Obj dom, Obj img)
{
    RequireSmallList("SparsePartialPermNC", dom);
    RequireSmallList("SparsePartialPermNC", img);
    RequireSameLength("SparsePartialPermNC", dom, img);

    UInt    rank, deg, i, j, codeg;
    Obj     f;
    UInt2 * ptf2;
    UInt4 * ptf4;

    if (LEN_LIST(dom) == 0)
        return EmptyPartialPerm;

    // make sure we have plain lists
    if (!IS_PLIST(dom))
        dom = PLAIN_LIST_COPY(dom);
    if (!IS_PLIST(img))
        img = PLAIN_LIST_COPY(img);

    // make img immutable
    MakeImmutable(img);
    MakeImmutable(dom);

    rank = LEN_PLIST(dom);
    deg = INT_INTOBJ(ELM_PLIST(dom, rank));

    // find if we are PPERM2 or PPERM4
    codeg = 0;
    i = rank;
    while (codeg < 65536 && i > 0) {
        j = INT_INTOBJ(ELM_PLIST(img, i--));
        if (j > codeg)
            codeg = j;
    }

    // create the pperm
    if (codeg < 65536) {
        f = NEW_PPERM2(deg);
        ptf2 = ADDR_PPERM2(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(img, i));
            ptf2[INT_INTOBJ(ELM_PLIST(dom, i)) - 1] = j;
        }
        SET_CODEG_PPERM2(f, codeg);
    }
    else {
        f = NEW_PPERM4(deg);
        ptf4 = ADDR_PPERM4(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(img, i));
            if (j > codeg)
                codeg = j;
            ptf4[INT_INTOBJ(ELM_PLIST(dom, i)) - 1] = j;
        }
        SET_CODEG_PPERM4(f, codeg);
    }
    SET_DOM_PPERM(f, dom);
    SET_IMG_PPERM(f, img);
    CHANGED_BAG(f);
    return f;
}

/* the degree of pperm is the maximum point where it is defined */
static Obj FuncDegreeOfPartialPerm(Obj self, Obj f)
{
    RequirePartialPerm(SELF_NAME, f);
    return INTOBJ_INT(DEG_PPERM(f));
}

/* the codegree of pperm is the maximum point in its image */

static Obj FuncCoDegreeOfPartialPerm(Obj self, Obj f)
{
    RequirePartialPerm(SELF_NAME, f);
    return INTOBJ_INT(CODEG_PPERM(f));
}

/* the rank is the number of points where it is defined */
static Obj FuncRankOfPartialPerm(Obj self, Obj f)
{
    RequirePartialPerm(SELF_NAME, f);
    return INTOBJ_INT(RANK_PPERM(f));
}

/* domain of a partial perm */
static Obj FuncDOMAIN_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("DOMAIN_PPERM", f);

    if (DOM_PPERM(f) == NULL) {
        INIT_PPERM(f);
    }
    return DOM_PPERM(f);
}

/* image list of pperm */
static Obj FuncIMAGE_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("IMAGE_PPERM", f);

    if (IMG_PPERM(f) == NULL) {
        INIT_PPERM(f);
        return IMG_PPERM(f);
    }
    else if (!IS_SSORT_LIST(IMG_PPERM(f))) {
        return IMG_PPERM(f);
    }

    UInt rank = RANK_PPERM(f);
    if (rank == 0) {
        return NewImmutableEmptyPlist();
    }

    Obj dom = DOM_PPERM(f);
    Obj out = NEW_PLIST_IMM(T_PLIST_CYC, rank);
    SET_LEN_PLIST(out, rank);

    if (TNUM_OBJ(f) == T_PPERM2) {
        UInt2 * ptf2 = ADDR_PPERM2(f);
        for (UInt i = 1; i <= rank; i++) {
            SET_ELM_PLIST(
                out, i, INTOBJ_INT(ptf2[INT_INTOBJ(ELM_PLIST(dom, i)) - 1]));
        }
    }
    else {
        UInt4 * ptf4 = ADDR_PPERM4(f);
        for (UInt i = 1; i <= rank; i++) {
            SET_ELM_PLIST(
                out, i, INTOBJ_INT(ptf4[INT_INTOBJ(ELM_PLIST(dom, i)) - 1]));
        }
    }
    return out;
}

/* image set of partial perm */
static Obj FuncIMAGE_SET_PPERM(Obj self, Obj f)
{
    RequirePartialPerm(SELF_NAME, f);

    if (IMG_PPERM(f) == NULL) {
        INIT_PPERM(f);
        return SORT_PLIST_INTOBJ(IMG_PPERM(f));
    }
    else if (!IS_SSORT_LIST(IMG_PPERM(f))) {
        return SORT_PLIST_INTOBJ(IMG_PPERM(f));
    }
    return IMG_PPERM(f);
}

/* preimage under a partial perm */
static Obj FuncPREIMAGE_PPERM_INT(Obj self, Obj f, Obj pt)
{
    RequirePartialPerm(SELF_NAME, f);
    RequireSmallInt(SELF_NAME, pt);
    if (TNUM_OBJ(f) == T_PPERM2)
        return PreImagePPermInt<UInt2>(pt, f);
    else
        return PreImagePPermInt<UInt4>(pt, f);
}

// find img(f)
static UInt4 * FindImg(UInt n, UInt rank, Obj img)
{
    GAP_ASSERT(IS_PLIST(img));

    UInt    i;
    UInt4 * ptseen;

    ResizeTmpPPerm(n);
    ptseen = ADDR_PPERM4(TmpPPerm);
    memset(ptseen, 0, n * sizeof(UInt4));

    for (i = 1; i <= rank; i++)
        ptseen[INT_INTOBJ(ELM_PLIST(img, i)) - 1] = 1;

    return ptseen;
}

// the least m, r such that f^m=f^m+r
static Obj FuncINDEX_PERIOD_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("INDEX_PERIOD_PPERM", f);

    UInt    i, len, j, pow, rank, k, deg, n;
    UInt2 * ptf2;
    UInt4 * ptseen, *ptf4;
    Obj     dom, img, ord;

    pow = 0;
    ord = INTOBJ_INT(1);
    n = MAX(DEG_PPERM(f), CODEG_PPERM(f));

    rank = RANK_PPERM(f);
    img = IMG_PPERM(f);
    ptseen = FindImg(n, rank, img);

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        ptf2 = ADDR_PPERM2(f);
        dom = DOM_PPERM(f);

        // find chains
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 0) {
                ptseen[j] = 2;
                len = 1;
                for (k = ptf2[j]; (k <= deg && ptf2[k - 1] != 0);
                     k = ptf2[k - 1]) {
                    len++;
                    ptseen[k - 1] = 2;
                }
                ptseen[k - 1] = 2;
                if (len > pow)
                    pow = len;
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 1) {
                len = 1;
                for (k = ptf2[j]; k != j + 1; k = ptf2[k - 1]) {
                    len++;
                    ptseen[k - 1] = 0;
                }
                ord = LcmInt(ord, INTOBJ_INT(len));
                // update ptseen, in case a garbage collection happened
                ptseen = ADDR_PPERM4(TmpPPerm);
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        ptf4 = ADDR_PPERM4(f);
        dom = DOM_PPERM(f);

        // find chains
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 0) {
                ptseen[j] = 2;
                len = 1;
                for (k = ptf4[j]; (k <= deg && ptf4[k - 1] != 0);
                     k = ptf4[k - 1]) {
                    len++;
                    ptseen[k - 1] = 2;
                }
                ptseen[k - 1] = 2;
                if (len > pow)
                    pow = len;
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 1) {
                len = 1;
                for (k = ptf4[j]; k != j + 1; k = ptf4[k - 1]) {
                    len++;
                    ptseen[k - 1] = 0;
                }
                ord = LcmInt(ord, INTOBJ_INT(len));
                // update ptseen, in case a garbage collection happened
                ptseen = ADDR_PPERM4(TmpPPerm);
            }
        }
    }
    return NewPlistFromArgs(INTOBJ_INT(pow + 1), ord);
}

// the least power of <f> which is an idempotent
static Obj FuncSMALLEST_IDEM_POW_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("SMALLEST_IDEM_POW_PPERM", f);

    Obj x, ind, per, pow;

    x = FuncINDEX_PERIOD_PPERM(self, f);
    ind = ELM_PLIST(x, 1);
    per = ELM_PLIST(x, 2);
    pow = per;
    while (LtInt(pow, ind))
        pow = SumInt(pow, per);
    return pow;
}

/* returns the least list <out> such that for all <i> in [1..degree(f)]
 * there exists <j> in <out> and a pos int <k> such that <j^(f^k)=i>. */
static Obj FuncCOMPONENT_REPS_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("COMPONENT_REPS_PPERM", f);

    UInt    i, j, rank, k, deg, nr, n;
    UInt2 * ptf2;
    UInt4 * ptseen, *ptf4;
    Obj     dom, img, out;

    n = MAX(DEG_PPERM(f), CODEG_PPERM(f));

    if (n == 0) {
        out = NewEmptyPlist();
        return out;
    }

    deg = DEG_PPERM(f);
    nr = 0;
    out = NEW_PLIST(T_PLIST_CYC, deg);

    rank = RANK_PPERM(f);
    img = IMG_PPERM(f);
    ptseen = FindImg(n, rank, img);

    if (TNUM_OBJ(f) == T_PPERM2) {
        dom = DOM_PPERM(f);
        ptf2 = ADDR_PPERM2(f);

        // find chains
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (ptseen[j - 1] == 0) {
                for (k = j; (k <= deg && ptf2[k - 1] != 0); k = ptf2[k - 1])
                    ptseen[k - 1] = 2;
                ptseen[k - 1] = 2;
                SET_ELM_PLIST(out, ++nr, ELM_PLIST(dom, i));
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 1) {
                ptseen[j] = 0;
                for (k = ptf2[j]; k != j + 1; k = ptf2[k - 1])
                    ptseen[k - 1] = 0;
                SET_ELM_PLIST(out, ++nr, ELM_PLIST(dom, i));
            }
        }
    }
    else {
        dom = DOM_PPERM(f);
        ptf4 = ADDR_PPERM4(f);

        // find chains
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (ptseen[j - 1] == 0) {
                for (k = j; (k <= deg && ptf4[k - 1] != 0); k = ptf4[k - 1])
                    ptseen[k - 1] = 2;
                ptseen[k - 1] = 2;
                SET_ELM_PLIST(out, ++nr, ELM_PLIST(dom, i));
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 1) {
                ptseen[j] = 0;
                for (k = ptf4[j]; k != j + 1; k = ptf4[k - 1])
                    ptseen[k - 1] = 0;
                SET_ELM_PLIST(out, ++nr, ELM_PLIST(dom, i));
            }
        }
    }

    SHRINK_PLIST(out, (Int)nr);
    SET_LEN_PLIST(out, (Int)nr);
    return out;
}

/* the number of components of a partial perm (as a functional digraph) */
static Obj FuncNR_COMPONENTS_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("NR_COMPONENTS_PPERM", f);

    UInt    i, j, n, rank, k, deg, nr;
    UInt2 * ptf2;
    UInt4 * ptseen, *ptf4;
    Obj     dom, img;

    n = MAX(DEG_PPERM(f), CODEG_PPERM(f));
    nr = 0;

    rank = RANK_PPERM(f);
    img = IMG_PPERM(f);
    ptseen = FindImg(n, rank, img);

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        ptf2 = ADDR_PPERM2(f);
        dom = DOM_PPERM(f);

        // find chains
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (ptseen[j - 1] == 0) {
                nr++;
                for (k = j; (k <= deg && ptf2[k - 1] != 0); k = ptf2[k - 1])
                    ptseen[k - 1] = 2;
                ptseen[k - 1] = 2;
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 1) {
                nr++;
                ptseen[j] = 0;
                for (k = ptf2[j]; k != j + 1; k = ptf2[k - 1])
                    ptseen[k - 1] = 0;
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        ptf4 = ADDR_PPERM4(f);
        dom = DOM_PPERM(f);

        // find chains
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (ptseen[j - 1] == 0) {
                nr++;
                for (k = j; (k <= deg && ptf4[k - 1] != 0); k = ptf4[k - 1])
                    ptseen[k - 1] = 2;
                ptseen[k - 1] = 2;
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 1) {
                nr++;
                ptseen[j] = 0;
                for (k = ptf4[j]; k != j + 1; k = ptf4[k - 1])
                    ptseen[k - 1] = 0;
            }
        }
    }
    return INTOBJ_INT(nr);
}

/* the components of a partial perm (as a functional digraph) */
static Obj FuncCOMPONENTS_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("COMPONENTS_PPERM", f);

    UInt i, j, n, rank, k, deg, nr, len;
    Obj  dom, img, out;

    n = MAX(DEG_PPERM(f), CODEG_PPERM(f));

    if (n == 0) {
        out = NewEmptyPlist();
        return out;
    }

    nr = 0;

    rank = RANK_PPERM(f);
    img = IMG_PPERM(f);
    out = NEW_PLIST(T_PLIST_CYC, rank);
    FindImg(n, rank, img);

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        dom = DOM_PPERM(f);

        // find chains
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (CONST_ADDR_PPERM4(TmpPPerm)[j - 1] == 0) {
                SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC, 30));
                CHANGED_BAG(out);
                len = 0;
                k = j;
                do {
                    AssPlist(ELM_PLIST(out, nr), ++len, INTOBJ_INT(k));
                    ADDR_PPERM4(TmpPPerm)[k - 1] = 2;
                    k = IMAGEPP(k, ADDR_PPERM2(f), deg);
                } while (k != 0);
                SHRINK_PLIST(ELM_PLIST(out, nr), len);
                SET_LEN_PLIST(ELM_PLIST(out, nr), (Int)len);
                CHANGED_BAG(out);
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (CONST_ADDR_PPERM4(TmpPPerm)[j - 1] == 1) {
                SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC, 30));
                CHANGED_BAG(out);
                len = 0;
                k = j;
                do {
                    AssPlist(ELM_PLIST(out, nr), ++len, INTOBJ_INT(k));
                    ADDR_PPERM4(TmpPPerm)[k - 1] = 0;
                    k = ADDR_PPERM2(f)[k - 1];
                } while (k != j);
                SHRINK_PLIST(ELM_PLIST(out, nr), len);
                SET_LEN_PLIST(ELM_PLIST(out, nr), (Int)len);
                CHANGED_BAG(out);
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        dom = DOM_PPERM(f);

        // find chains
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (CONST_ADDR_PPERM4(TmpPPerm)[j - 1] == 0) {
                SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC, 30));
                CHANGED_BAG(out);
                len = 0;
                k = j;
                do {
                    AssPlist(ELM_PLIST(out, nr), ++len, INTOBJ_INT(k));
                    ADDR_PPERM4(TmpPPerm)[k - 1] = 2;
                    k = IMAGEPP(k, ADDR_PPERM4(f), deg);
                } while (k != 0);
                SHRINK_PLIST(ELM_PLIST(out, nr), len);
                SET_LEN_PLIST(ELM_PLIST(out, nr), (Int)len);
                CHANGED_BAG(out);
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (CONST_ADDR_PPERM4(TmpPPerm)[j - 1] == 1) {
                SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC, 30));
                CHANGED_BAG(out);
                len = 0;
                k = j;
                do {
                    AssPlist(ELM_PLIST(out, nr), ++len, INTOBJ_INT(k));
                    ADDR_PPERM4(TmpPPerm)[k - 1] = 0;
                    k = ADDR_PPERM4(f)[k - 1];
                } while (k != j);
                SHRINK_PLIST(ELM_PLIST(out, nr), len);
                SET_LEN_PLIST(ELM_PLIST(out, nr), (Int)len);
                CHANGED_BAG(out);
            }
        }
    }

    SHRINK_PLIST(out, (Int)nr);
    SET_LEN_PLIST(out, (Int)nr);
    return out;
}

// the points that can be obtained from <pt> by successively applying <f>.
static Obj FuncCOMPONENT_PPERM_INT(Obj self, Obj f, Obj pt)
{
    RequirePartialPerm("COMPONENT_PPERM_INT", f);
    RequireSmallInt("COMPONENT_PPERM_INT", pt);

    UInt i, j, deg, len;
    Obj  out;

    i = INT_INTOBJ(pt);

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);

        if (i > deg || (ADDR_PPERM2(f))[i - 1] == 0) {
            out = NewEmptyPlist();
            return out;
        }

        out = NEW_PLIST(T_PLIST_CYC, 30);
        len = 0;
        j = i;

        do {
            AssPlist(out, ++len, INTOBJ_INT(j));
            j = IMAGEPP(j, ADDR_PPERM2(f), deg);
        } while (j != 0 && j != i);
    }
    else {
        deg = DEG_PPERM4(f);

        if (i > deg || (ADDR_PPERM4(f))[i - 1] == 0) {
            out = NewEmptyPlist();
            return out;
        }

        out = NEW_PLIST(T_PLIST_CYC, 30);
        len = 0;
        j = i;

        do {
            AssPlist(out, ++len, INTOBJ_INT(j));
            j = IMAGEPP(j, ADDR_PPERM4(f), deg);
        } while (j != 0 && j != i);
    }
    SHRINK_PLIST(out, (Int)len);
    SET_LEN_PLIST(out, (Int)len);
    return out;
}

// the fixed points of a partial perm
static Obj FuncFIXED_PTS_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("FIXED_PTS_PPERM", f);

    UInt    len, i, j, deg, rank;
    Obj     out, dom;
    UInt2 * ptf2;
    UInt4 * ptf4;

    len = 0;
    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        if (DOM_PPERM(f) == NULL) {
            out = NEW_PLIST(T_PLIST_CYC_SSORT, deg);
            ptf2 = ADDR_PPERM2(f);
            for (i = 0; i < deg; i++) {
                if (ptf2[i] == i + 1) {
                    SET_ELM_PLIST(out, ++len, INTOBJ_INT(i + 1));
                }
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            out = NEW_PLIST(T_PLIST_CYC_SSORT, rank);
            ptf2 = ADDR_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i));
                if (ptf2[j - 1] == j) {
                    SET_ELM_PLIST(out, ++len, INTOBJ_INT(j));
                }
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        if (DOM_PPERM(f) == NULL) {
            out = NEW_PLIST(T_PLIST_CYC_SSORT, deg);
            ptf4 = ADDR_PPERM4(f);
            for (i = 0; i < deg; i++) {
                if (ptf4[i] == i + 1) {
                    SET_ELM_PLIST(out, ++len, INTOBJ_INT(i + 1));
                }
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            out = NEW_PLIST(T_PLIST_CYC_SSORT, rank);
            ptf4 = ADDR_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i));
                if (ptf4[j - 1] == j) {
                    SET_ELM_PLIST(out, ++len, INTOBJ_INT(j));
                }
            }
        }
    }
    if (len == 0)
        RetypeBag(out, T_PLIST_EMPTY);

    SHRINK_PLIST(out, len);
    SET_LEN_PLIST(out, (Int)len);

    return out;
}

static Obj FuncNR_FIXED_PTS_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("NR_FIXED_PTS_PPERM", f);

    UInt    nr, i, j, deg, rank;
    Obj     dom;
    UInt2 * ptf2;
    UInt4 * ptf4;

    nr = 0;
    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        ptf2 = ADDR_PPERM2(f);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++)
                if (ptf2[i] == i + 1)
                    nr++;
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf2[j] == j + 1)
                    nr++;
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        ptf4 = ADDR_PPERM4(f);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++)
                if (ptf4[i] == i + 1)
                    nr++;
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf4[j] == j + 1)
                    nr++;
            }
        }
    }
    return INTOBJ_INT(nr);
}

// the moved points of a partial perm
static Obj FuncMOVED_PTS_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("MOVED_PTS_PPERM", f);

    UInt    len, i, j, deg, rank;
    Obj     out, dom;
    UInt2 * ptf2;
    UInt4 * ptf4;

    len = 0;
    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        if (DOM_PPERM(f) == NULL) {
            out = NEW_PLIST(T_PLIST_CYC_SSORT, deg);
            ptf2 = ADDR_PPERM2(f);
            for (i = 0; i < deg; i++) {
                if (ptf2[i] != 0 && ptf2[i] != i + 1) {
                    SET_ELM_PLIST(out, ++len, INTOBJ_INT(i + 1));
                }
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            out = NEW_PLIST(T_PLIST_CYC_SSORT, rank);
            ptf2 = ADDR_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf2[j] != j + 1) {
                    SET_ELM_PLIST(out, ++len, INTOBJ_INT(j + 1));
                }
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        if (DOM_PPERM(f) == NULL) {
            out = NEW_PLIST(T_PLIST_CYC_SSORT, deg);
            ptf4 = ADDR_PPERM4(f);
            for (i = 0; i < deg; i++) {
                if (ptf4[i] != 0 && ptf4[i] != i + 1) {
                    SET_ELM_PLIST(out, ++len, INTOBJ_INT(i + 1));
                }
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            out = NEW_PLIST(T_PLIST_CYC_SSORT, rank);
            ptf4 = ADDR_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf4[j] != j + 1) {
                    SET_ELM_PLIST(out, ++len, INTOBJ_INT(j + 1));
                }
            }
        }
    }
    if (len == 0)
        RetypeBag(out, T_PLIST_EMPTY);
    SHRINK_PLIST(out, len);
    SET_LEN_PLIST(out, (Int)len);
    return out;
}

static Obj FuncNR_MOVED_PTS_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("NR_MOVED_PTS_PPERM", f);

    UInt    nr, i, j, deg, rank;
    Obj     dom;
    UInt2 * ptf2;
    UInt4 * ptf4;

    nr = 0;
    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        ptf2 = ADDR_PPERM2(f);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++)
                if (ptf2[i] != 0 && ptf2[i] != i + 1)
                    nr++;
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf2[j] != j + 1)
                    nr++;
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        ptf4 = ADDR_PPERM4(f);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++)
                if (ptf4[i] != 0 && ptf4[i] != i + 1)
                    nr++;
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf4[j] != j + 1)
                    nr++;
            }
        }
    }
    return INTOBJ_INT(nr);
}

static Obj FuncLARGEST_MOVED_PT_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("LARGEST_MOVED_PT_PPERM", f);

    UInt    i, j, deg;
    Obj     dom;
    UInt2 * ptf2;
    UInt4 * ptf4;

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        ptf2 = ADDR_PPERM2(f);
        if (DOM_PPERM(f) == NULL) {
            for (i = deg; i > 0; i--) {
                if (ptf2[i - 1] != 0 && ptf2[i - 1] != i)
                    return INTOBJ_INT(i);
            }
        }
        else {
            dom = DOM_PPERM(f);
            for (i = RANK_PPERM2(f); i >= 1; i--) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf2[j] != j + 1)
                    return INTOBJ_INT(j + 1);
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        ptf4 = ADDR_PPERM4(f);
        if (DOM_PPERM(f) == NULL) {
            for (i = deg; i > 0; i--) {
                if (ptf4[i - 1] != 0 && ptf4[i - 1] != i)
                    return INTOBJ_INT(i);
            }
        }
        else {
            dom = DOM_PPERM(f);
            for (i = RANK_PPERM4(f); i >= 1; i--) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf4[j] != j + 1)
                    return INTOBJ_INT(j + 1);
            }
        }
    }
    return INTOBJ_INT(0);
}

static Obj FuncSMALLEST_MOVED_PT_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("SMALLEST_MOVED_PT_PPERM", f);

    UInt    i, j, deg, rank;
    Obj     dom;
    UInt2 * ptf2;
    UInt4 * ptf4;

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        ptf2 = ADDR_PPERM2(f);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++) {
                if (ptf2[i] != 0 && ptf2[i] != i + 1)
                    return INTOBJ_INT(i + 1);
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf2[j] != j + 1)
                    return INTOBJ_INT(j + 1);
            }
        }
    }
    else {
        deg = DEG_PPERM4(f);
        ptf4 = ADDR_PPERM4(f);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++) {
                if (ptf4[i] != 0 && ptf4[i] != i + 1)
                    return INTOBJ_INT(i + 1);
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf4[j] != j + 1)
                    return INTOBJ_INT(j + 1);
            }
        }
    }
    return Fail;
}

// convert a T_PPERM4 with codeg<65536 to a T_PPERM2
static Obj FuncTRIM_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("TRIM_PPERM", f);

    UInt    deg, i;
    UInt4 * ptf;

    if (TNUM_OBJ(f) != T_PPERM4 || CODEG_PPERM4(f) > 65535)
        return f;

    ptf = ADDR_PPERM4(f) - 1;
    deg = DEG_PPERM4(f);
    for (i = 0; i < deg + 1; i++)
        ((UInt2 *)ptf)[i] = (UInt2)ptf[i];

    RetypeBag(f, T_PPERM2);
    ResizeBag(f, (deg + 1) * sizeof(UInt2) + 2 * sizeof(Obj));
    return (Obj)0;
}

Int HashFuncForPPerm(Obj f)
{
    UInt codeg;

    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2 || TNUM_OBJ(f) == T_PPERM4);

    if (TNUM_OBJ(f) == T_PPERM4) {
        codeg = CODEG_PPERM4(f);
        if (codeg < 65536) {
            FuncTRIM_PPERM(0, f);
        }
        else {
            return HASHKEY_BAG_NC(f, (UInt4)255,
                                  2 * sizeof(Obj) + sizeof(UInt4),
                                  (int)4 * DEG_PPERM4(f));
        }
    }
    return HASHKEY_BAG_NC(f, (UInt4)255, 2 * sizeof(Obj) + sizeof(UInt2),
                          (int)2 * DEG_PPERM2(f));
}

static Obj FuncHASH_FUNC_FOR_PPERM(Obj self, Obj f, Obj data)
{
    return INTOBJ_INT(HashFuncForPPerm(f) % INT_INTOBJ(data) + 1);
}

// test if a partial perm is an idempotent
static Obj FuncIS_IDEM_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("IS_IDEM_PPERM", f);

    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg, i, j, rank;
    Obj     dom;

    if (TNUM_OBJ(f) == T_PPERM2) {
        ptf2 = ADDR_PPERM2(f);
        if (DOM_PPERM(f) == NULL) {
            deg = DEG_PPERM2(f);
            for (i = 0; i < deg; i++) {
                if (ptf2[i] != 0 && ptf2[i] != i + 1)
                    return False;
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf2[j] != 0 && ptf2[j] != j + 1)
                    return False;
            }
        }
    }
    else {
        ptf4 = ADDR_PPERM4(f);
        if (DOM_PPERM(f) == NULL) {
            deg = DEG_PPERM4(f);
            for (i = 0; i < deg; i++) {
                if (ptf4[i] != 0 && ptf4[i] != i + 1)
                    return False;
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptf4[j] != 0 && ptf4[j] != j + 1)
                    return False;
            }
        }
    }
    return True;
}

/* an idempotent partial perm <e> with ker(e)=ker(f) */
static Obj FuncLEFT_ONE_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("LEFT_ONE_PPERM", f);

    Obj     dom, g;
    UInt    deg, i, j, rank;
    UInt2 * ptg2;
    UInt4 * ptg4;

    if (TNUM_OBJ(f) == T_PPERM2) {
        rank = RANK_PPERM2(f);
        dom = DOM_PPERM(f);
        deg = DEG_PPERM2(f);
    }
    else {
        rank = RANK_PPERM4(f);
        dom = DOM_PPERM(f);
        deg = DEG_PPERM4(f);
    }

    if (deg < 65536) {
        g = NEW_PPERM2(deg);
        ptg2 = ADDR_PPERM2(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptg2[j] = j + 1;
        }
        SET_CODEG_PPERM2(g, deg);
        SET_DOM_PPERM(g, dom);
        SET_IMG_PPERM(g, dom);
    }
    else {
        g = NEW_PPERM4(deg);
        ptg4 = ADDR_PPERM4(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptg4[j] = j + 1;
        }
        SET_CODEG_PPERM4(g, deg);
        SET_DOM_PPERM(g, dom);
        SET_IMG_PPERM(g, dom);
    }
    CHANGED_BAG(g);
    return g;
}

// an idempotent partial perm <e> with im(e)=im(f)
static Obj FuncRIGHT_ONE_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("RIGHT_ONE_PPERM", f);

    Obj     g, img;
    UInt    i, j, codeg, rank;
    UInt2 * ptg2;
    UInt4 * ptg4;

    if (TNUM_OBJ(f) == T_PPERM2) {
        codeg = CODEG_PPERM2(f);
        rank = RANK_PPERM2(f);
        img = IMG_PPERM(f);
    }
    else {
        codeg = CODEG_PPERM4(f);
        rank = RANK_PPERM4(f);
        img = IMG_PPERM(f);
    }

    if (codeg < 65536) {
        g = NEW_PPERM2(codeg);
        ptg2 = ADDR_PPERM2(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(img, i)) - 1;
            ptg2[j] = j + 1;
        }
        if (IS_SSORT_LIST(img)) {
            SET_DOM_PPERM(g, img);
            SET_IMG_PPERM(g, img);
        }
        SET_CODEG_PPERM2(g, codeg);
    }
    else {
        g = NEW_PPERM4(codeg);
        ptg4 = ADDR_PPERM4(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(img, i)) - 1;
            ptg4[j] = j + 1;
        }
        if (IS_SSORT_LIST(img)) {
            SET_DOM_PPERM(g, img);
            SET_IMG_PPERM(g, img);
        }
        SET_CODEG_PPERM4(g, codeg);
    }
    CHANGED_BAG(g);
    return g;
}

// f<=g if and only if f is a restriction of g
template <typename TF, typename TG>
static Obj NaturalLeqPartialPerm(Obj f, Obj g)
{
    UInt   def, deg, i, j, rank;
    const TF * ptf;
    const TG * ptg;
    Obj    dom;

    def = DEG_PPERM<TF>(f);
    ptf = CONST_ADDR_PPERM<TF>(f);
    if (def == 0)
        return True;

    deg = DEG_PPERM<TG>(g);
    ptg = CONST_ADDR_PPERM<TG>(g);
    if (DOM_PPERM(f) == NULL) {
        for (i = 0; i < def; i++) {
            if (ptf[i] != 0 && ptf[i] != IMAGEPP(i + 1, ptg, deg))
                return False;
        }
    }
    else {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM<TF>(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i));
            if (ptf[j - 1] != IMAGEPP(j, ptg, deg))
                return False;
        }
    }

    return True;
}

static Obj FuncNaturalLeqPartialPerm(Obj self, Obj f, Obj g)
{
    RequirePartialPerm(SELF_NAME, f);
    RequirePartialPerm(SELF_NAME, g);

    if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM2) {
        return NaturalLeqPartialPerm<UInt2, UInt2>(f, g);
    }
    else if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM4) {
        return NaturalLeqPartialPerm<UInt2, UInt4>(f, g);
    }
    else if (TNUM_OBJ(f) == T_PPERM4 && TNUM_OBJ(g) == T_PPERM2) {
        return NaturalLeqPartialPerm<UInt4, UInt2>(f, g);
    }
    else /* if (TNUM_OBJ(f) == T_PPERM4 && TNUM_OBJ(g) == T_PPERM4) */ {
        return NaturalLeqPartialPerm<UInt4, UInt4>(f, g);
    }
}

template <typename TF, typename TG>
static Obj JOIN_IDEM_PPERMS(Obj f, Obj g)
{
    typedef typename ResultType<TF, TG>::type Res;

    UInt  def, deg, i;
    Obj   join = NULL;
    Res * ptjoin;
    const TF * ptf;
    const TG * ptg;

    def = DEG_PPERM(f);
    deg = DEG_PPERM(g);

    GAP_ASSERT(def <= deg);

    join = NEW_PPERM<Res>(deg);
    SET_CODEG_PPERM<Res>(join, deg);
    ptjoin = ADDR_PPERM<Res>(join);
    ptf = CONST_ADDR_PPERM<TF>(f);
    ptg = CONST_ADDR_PPERM<TG>(g);
    for (i = 0; i < def; i++) {
        ptjoin[i] = (ptf[i] != 0 ? ptf[i] : ptg[i]);
    }
    for (; i < deg; i++) {
        ptjoin[i] = ptg[i];
    }

    return join;
}

static Obj FuncJOIN_IDEM_PPERMS(Obj self, Obj f, Obj g)
{
    RequirePartialPerm("JOIN_IDEM_PPERMS", f);
    RequirePartialPerm("JOIN_IDEM_PPERMS", g);

    UInt def, deg;

    if (EQ(f, g)) {
        return f;
    }

    def = DEG_PPERM(f);
    deg = DEG_PPERM(g);

    if (def > deg) {
        SWAP(Obj, f, g);
        SWAP(UInt, def, deg);
    }

    if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM2) {
        return JOIN_IDEM_PPERMS<UInt2, UInt2>(f, g);
    }
    else if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM4) {
        return JOIN_IDEM_PPERMS<UInt2, UInt4>(f, g);
    }
    else /* if (TNUM_OBJ(f) == T_PPERM4 && TNUM_OBJ(g) == T_PPERM4) */ {
        return JOIN_IDEM_PPERMS<UInt4, UInt4>(f, g);
    }
}


// the union of f and g where this defines an injective function
template <typename TF, typename TG>
static Obj JOIN_PPERMS(Obj f, Obj g)
{
    typedef typename ResultType<TF, TG>::type Res;

    UInt   deg, i, j, degf, degg, codeg, rank;
    Res *   ptjoin;
    const TF * ptf;
    const TG * ptg;
    UInt4 * ptseen;
    Obj    join, dom;

    // init the buffer
    codeg = MAX(CODEG_PPERM(f), CODEG_PPERM(g));
    ResizeTmpPPerm(codeg);
    ptseen = ADDR_PPERM4(TmpPPerm);
    for (i = 0; i < codeg; i++)
        ptseen[i] = 0;

    degf = DEG_PPERM<TF>(f);
    degg = DEG_PPERM<TG>(g);
    deg = MAX(degf, degg);
    join = NEW_PPERM<Res>(deg);
    SET_CODEG_PPERM<Res>(join, codeg);

    ptjoin = ADDR_PPERM<Res>(join);
    ptf = CONST_ADDR_PPERM<TF>(f);
    ptg = CONST_ADDR_PPERM<TG>(g);
    ptseen = ADDR_PPERM4(TmpPPerm);

    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM<TF>(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptjoin[j] = ptf[j];
            ptseen[ptf[j] - 1] = 1;
        }
    }

    if (DOM_PPERM(g) != NULL) {
        dom = DOM_PPERM(g);
        rank = RANK_PPERM<TG>(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptjoin[j] == 0) {
                if (ptseen[ptg[j] - 1] == 0) {
                    ptjoin[j] = ptg[j];
                    ptseen[ptg[j] - 1] = 1;
                }
                else {
                    return Fail;    // join is not injective
                }
            }
            else if (ptjoin[j] != ptg[j]) {
                return Fail;
            }
        }
    }

    if (DOM_PPERM(f) == NULL) {
        for (i = 0; i < degf; i++) {
            if (ptf[i] != 0) {
                if (ptjoin[i] == 0) {
                    if (ptseen[ptf[i] - 1] == 0) {
                        ptjoin[i] = ptf[i];
                        ptseen[ptf[i] - 1] = 1;
                    }
                    else {
                        return Fail;
                    }
                }
                else if (ptjoin[i] != ptf[i]) {
                    return Fail;
                }
            }
        }
    }

    if (DOM_PPERM(g) == NULL) {
        for (i = 0; i < degg; i++) {
            if (ptg[i] != 0) {
                if (ptjoin[i] == 0) {
                    if (ptseen[ptg[i] - 1] == 0) {
                        ptjoin[i] = ptg[i];
                        ptseen[ptg[i] - 1] = 1;
                    }
                    else {
                        return Fail;
                    }
                }
                else if (ptjoin[i] != ptg[i]) {
                    return Fail;
                }
            }
        }
    }
    return join;
}

static Obj FuncJOIN_PPERMS(Obj self, Obj f, Obj g)
{
    RequirePartialPerm("JOIN_PPERMS", f);
    RequirePartialPerm("JOIN_PPERMS", g);

    if (EQ(f, g))
        return f;

    if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM2) {
        return JOIN_PPERMS<UInt2, UInt2>(f, g);
    }
    else if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM4) {
        return JOIN_PPERMS<UInt2, UInt4>(f, g);
    }
    else if (TNUM_OBJ(f) == T_PPERM4 && TNUM_OBJ(g) == T_PPERM2) {
        return JOIN_PPERMS<UInt4, UInt2>(f, g);
    }
    else /* if (TNUM_OBJ(f) == T_PPERM4 && TNUM_OBJ(g) == T_PPERM4) */ {
        return JOIN_PPERMS<UInt4, UInt4>(f, g);
    }
}

static Obj FuncMEET_PPERMS(Obj self, Obj f, Obj g)
{
    RequirePartialPerm("MEET_PPERMS", f);
    RequirePartialPerm("MEET_PPERMS", g);

    UInt   deg, i, j, degf, degg, codeg;
    UInt2 *ptf2, *ptg2, *ptmeet2;
    UInt4 *ptf4, *ptg4, *ptmeet4;
    Obj    meet;

    codeg = 0;
    if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM2) {
        degf = DEG_PPERM2(f);
        degg = DEG_PPERM2(g);
        ptf2 = ADDR_PPERM2(f);
        ptg2 = ADDR_PPERM2(g);

        // find degree
        for (deg = MIN(degf, degg); deg > 0; deg--) {
            j = IMAGEPP(deg, ptf2, degf);
            if (j != 0 && j == IMAGEPP(deg, ptg2, degg))
                break;
        }

        meet = NEW_PPERM2(deg);
        ptmeet2 = ADDR_PPERM2(meet);
        ptf2 = ADDR_PPERM2(f);
        ptg2 = ADDR_PPERM2(g);

        for (i = 0; i < deg; i++) {
            j = IMAGEPP(i + 1, ptf2, degf);
            if (IMAGEPP(i + 1, ptg2, degg) == j) {
                ptmeet2[i] = j;
                if (j > codeg)
                    codeg = j;
            }
        }
        SET_CODEG_PPERM2(meet, codeg);
    }
    else if (TNUM_OBJ(f) == T_PPERM4 && TNUM_OBJ(g) == T_PPERM2) {
        degf = DEG_PPERM4(f);
        degg = DEG_PPERM2(g);
        ptf4 = ADDR_PPERM4(f);
        ptg2 = ADDR_PPERM2(g);

        // find degree
        for (deg = (degf < degg ? degf : degg); deg > 0; deg--) {
            j = IMAGEPP(deg, ptf4, degf);
            if (j != 0 && j == IMAGEPP(deg, ptg2, degg))
                break;
        }

        meet = NEW_PPERM2(deg);
        ptmeet2 = ADDR_PPERM2(meet);
        ptf4 = ADDR_PPERM4(f);
        ptg2 = ADDR_PPERM2(g);

        for (i = 0; i < deg; i++) {
            j = IMAGEPP(i + 1, ptf4, degf);
            if (IMAGEPP(i + 1, ptg2, degg) == j) {
                ptmeet2[i] = j;
                if (j > codeg)
                    codeg = j;
            }
        }
        SET_CODEG_PPERM2(meet, codeg);
    }
    else if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM4) {
        degf = DEG_PPERM2(f);
        degg = DEG_PPERM4(g);
        ptf2 = ADDR_PPERM2(f);
        ptg4 = ADDR_PPERM4(g);

        // find degree
        for (deg = MIN(degf, degg); deg > 0; deg--) {
            j = IMAGEPP(deg, ptf2, degf);
            if (j != 0 && j == IMAGEPP(deg, ptg4, degg))
                break;
        }

        meet = NEW_PPERM2(deg);
        ptmeet2 = ADDR_PPERM2(meet);
        ptf2 = ADDR_PPERM2(f);
        ptg4 = ADDR_PPERM4(g);

        for (i = 0; i < deg; i++) {
            j = IMAGEPP(i + 1, ptf2, degf);
            if (IMAGEPP(i + 1, ptg4, degg) == j) {
                ptmeet2[i] = j;
                if (j > codeg)
                    codeg = j;
            }
        }
        SET_CODEG_PPERM2(meet, codeg);
    }
    else {
        degf = DEG_PPERM4(f);
        degg = DEG_PPERM4(g);
        ptf4 = ADDR_PPERM4(f);
        ptg4 = ADDR_PPERM4(g);

        // find degree
        for (deg = MIN(degf, degg); deg > 0; deg--) {
            j = IMAGEPP(deg, ptf4, degf);
            if (j != 0 && j == IMAGEPP(deg, ptg4, degg))
                break;
        }

        meet = NEW_PPERM4(deg);
        ptmeet4 = ADDR_PPERM4(meet);
        ptf4 = ADDR_PPERM4(f);
        ptg4 = ADDR_PPERM4(g);

        for (i = 0; i < deg; i++) {
            j = IMAGEPP(i + 1, ptf4, degf);
            if (IMAGEPP(i + 1, ptg4, degg) == j) {
                ptmeet4[i] = j;
                if (j > codeg)
                    codeg = j;
            }
        }
        SET_CODEG_PPERM4(meet, codeg);
    }
    return meet;
}

// restricted partial perm where set is assumed to be a set of positive ints
static Obj FuncRESTRICTED_PPERM(Obj self, Obj f, Obj set)
{
    GAP_ASSERT(IS_LIST(set));

    UInt   i, j, n, codeg, deg;
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4;
    Obj    g;

    n = LEN_LIST(set);
    codeg = 0;

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        ptf2 = ADDR_PPERM2(f);

        // find pos in list corresponding to degree of new pperm
        while (n > 0 && (UInt)INT_INTOBJ(ELM_LIST(set, n)) > deg)
            n--;
        while (n > 0 && ptf2[INT_INTOBJ(ELM_LIST(set, n)) - 1] == 0)
            n--;
        if (n == 0)
            return EmptyPartialPerm;

        g = NEW_PPERM2(INT_INTOBJ(ELM_LIST(set, n)));
        ptf2 = ADDR_PPERM2(f);
        ptg2 = ADDR_PPERM2(g);

        for (i = 0; i < n; i++) {
            j = INT_INTOBJ(ELM_LIST(set, i + 1)) - 1;
            ptg2[j] = ptf2[j];
            if (ptg2[j] > codeg)
                codeg = ptg2[j];
        }
        SET_CODEG_PPERM2(g, codeg);
        return g;
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        deg = DEG_PPERM4(f);
        ptf4 = ADDR_PPERM4(f);

        while (n > 0 && (UInt)INT_INTOBJ(ELM_LIST(set, n)) > deg)
            n--;
        while (n > 0 && ptf4[INT_INTOBJ(ELM_LIST(set, n)) - 1] == 0)
            n--;
        if (n == 0)
            return EmptyPartialPerm;

        g = NEW_PPERM4(INT_INTOBJ(ELM_LIST(set, n)));
        ptf4 = ADDR_PPERM4(f);
        ptg4 = ADDR_PPERM4(g);

        for (i = 0; i < n; i++) {
            j = INT_INTOBJ(ELM_LIST(set, i + 1)) - 1;
            ptg4[j] = ptf4[j];
            if (ptg4[j] > codeg)
                codeg = ptg4[j];
        }
        SET_CODEG_PPERM4(g, codeg);
        return g;
    }
    return Fail;
}

// convert a permutation <p> to a partial perm on <set>, which is assumed to
// be a set of positive integers
static Obj FuncAS_PPERM_PERM(Obj self, Obj p, Obj set)
{
    GAP_ASSERT(IS_PERM(p));
    GAP_ASSERT(IS_LIST(set));

    UInt   i, j, n, deg, codeg, dep;
    UInt2 *ptf2, *ptp2;
    UInt4 *ptf4, *ptp4;
    Obj    f;

    n = LEN_LIST(set);
    if (n == 0)
        return EmptyPartialPerm;
    deg = INT_INTOBJ(ELM_LIST(set, n));
    codeg = 0;

    if (TNUM_OBJ(p) == T_PERM2) {
        dep = DEG_PERM2(p);
        if (deg < 65536) {
            if (dep < deg) {
                f = NEW_PPERM2(deg);
                ptf2 = ADDR_PPERM2(f);
                ptp2 = ADDR_PERM2(p);
                for (i = 1; i <= n; i++) {
                    j = INT_INTOBJ(ELM_LIST(set, i)) - 1;
                    ptf2[j] = IMAGE(j, ptp2, dep) + 1;
                }
                SET_CODEG_PPERM2(f, deg);
            }
            else {    // deg(f)<=deg(p)<=65536
                f = NEW_PPERM2(deg);
                ptf2 = ADDR_PPERM2(f);
                ptp2 = ADDR_PERM2(p);
                for (i = 1; i <= n; i++) {
                    j = INT_INTOBJ(ELM_LIST(set, i)) - 1;
                    ptf2[j] = ptp2[j] + 1;
                    if (ptf2[j] > codeg)
                        codeg = ptf2[j];
                }
                SET_CODEG_PPERM2(f, codeg);
            }
        }
        else {    // deg(p)<=65536<=deg(f)
            f = NEW_PPERM4(deg);
            ptf4 = ADDR_PPERM4(f);
            ptp2 = ADDR_PERM2(p);
            for (i = 1; i <= n; i++) {
                j = INT_INTOBJ(ELM_LIST(set, i)) - 1;
                ptf4[j] = IMAGE(j, ptp2, dep) + 1;
            }
            SET_CODEG_PPERM4(f, deg);
        }
    }
    else {    // p is PERM4
        dep = DEG_PERM4(p);
        if (dep < deg) {
            f = NEW_PPERM4(deg);
            ptf4 = ADDR_PPERM4(f);
            ptp4 = ADDR_PERM4(p);
            for (i = 1; i <= n; i++) {
                j = INT_INTOBJ(ELM_LIST(set, i)) - 1;
                ptf4[j] = IMAGE(j, ptp4, dep) + 1;
            }
            SET_CODEG_PPERM4(f, deg);
        }
        else {    // deg<=dep
            // find the codeg
            i = deg;
            ptp4 = ADDR_PERM4(p);
            while (codeg < 65536 && i > 0) {
                j = ptp4[INT_INTOBJ(ELM_LIST(set, i--)) - 1] + 1;
                if (j > codeg)
                    codeg = j;
            }
            if (codeg < 65536) {
                f = NEW_PPERM2(deg);
                ptf2 = ADDR_PPERM2(f);
                ptp4 = ADDR_PERM4(p);
                for (i = 1; i <= n; i++) {
                    j = INT_INTOBJ(ELM_LIST(set, i)) - 1;
                    ptf2[j] = ptp4[j] + 1;
                }
                SET_CODEG_PPERM2(f, codeg);
            }
            else {
                f = NEW_PPERM4(deg);
                ptf4 = ADDR_PPERM4(f);
                ptp4 = ADDR_PERM4(p);
                for (i = 1; i <= n; i++) {
                    j = INT_INTOBJ(ELM_LIST(set, i)) - 1;
                    ptf4[j] = ptp4[j] + 1;
                    if (ptf4[j] > codeg)
                        codeg = ptf4[j];
                }
                SET_CODEG_PPERM4(f, deg);
            }
        }
    }
    return f;
}

// for a partial perm with equal dom and img
static Obj FuncAS_PERM_PPERM(Obj self, Obj f)
{
    RequirePartialPerm("AS_PERM_PPERM", f);

    UInt2 *ptf2, *ptp2;
    UInt4 *ptf4, *ptp4;
    UInt   deg, i, j, rank;
    Obj    p, dom, img;

    img = FuncIMAGE_SET_PPERM(self, f);
    dom = DOM_PPERM(f);
    if (!EQ(img, dom)) {
        return Fail;
    }
    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);
        p = NEW_PERM2(deg);
        ptp2 = ADDR_PERM2(p);
        ptf2 = ADDR_PPERM2(f);
        for (i = 0; i < deg; i++)
            ptp2[i] = i;
        rank = RANK_PPERM2(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptp2[j] = ptf2[j] - 1;
        }
    }
    else {
        deg = DEG_PPERM4(f);
        p = NEW_PERM4(deg);
        ptp4 = ADDR_PERM4(p);
        ptf4 = ADDR_PPERM4(f);
        for (i = 0; i < deg; i++)
            ptp4[i] = i;
        rank = RANK_PPERM4(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptp4[j] = ptf4[j] - 1;
        }
    }
    return p;
}

// the permutation induced on im(f) by f^-1*g when im(g)=im(f)
// and dom(f)=dom(g), no checking
static Obj FuncPERM_LEFT_QUO_PPERM_NC(Obj self, Obj f, Obj g)
{
    RequirePartialPerm("PERM_LEFT_QUO_PPERM_NC", f);
    RequirePartialPerm("PERM_LEFT_QUO_PPERM_NC", g);

    UInt   deg, i, j, rank;
    Obj    perm, dom;
    UInt2 *ptf2, *ptp2, *ptg2;
    UInt4 *ptf4, *ptp4, *ptg4;

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = CODEG_PPERM2(f);
        rank = RANK_PPERM2(f);
        dom = DOM_PPERM(f);

        perm = NEW_PERM2(deg);
        ptp2 = ADDR_PERM2(perm);
        for (i = 0; i < deg; i++)
            ptp2[i] = i;
        ptf2 = ADDR_PPERM2(f);
        if (TNUM_OBJ(g) == T_PPERM2) {
            ptg2 = ADDR_PPERM2(g);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptp2[ptf2[j] - 1] = ptg2[j] - 1;
            }
        }
        else {
            ptg4 = ADDR_PPERM4(g);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptp2[ptf2[j] - 1] = ptg4[j] - 1;
            }
        }
    }
    else {
        deg = CODEG_PPERM4(f);
        rank = RANK_PPERM4(f);
        dom = DOM_PPERM(f);

        perm = NEW_PERM4(deg);
        ptp4 = ADDR_PERM4(perm);
        for (i = 0; i < deg; i++)
            ptp4[i] = i;
        ptf4 = ADDR_PPERM4(f);
        if (TNUM_OBJ(g) == T_PPERM2) {
            ptg2 = ADDR_PPERM2(g);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptp4[ptf4[j] - 1] = ptg2[j] - 1;
            }
        }
        else {
            ptg4 = ADDR_PPERM4(g);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptp4[ptf4[j] - 1] = ptg4[j] - 1;
            }
        }
    }
    return perm;
}

static Obj FuncShortLexLeqPartialPerm(Obj self, Obj f, Obj g)
{
    UInt   rankf, rankg, i, j, k;
    Obj    domf, domg;
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4;

    RequirePartialPerm(SELF_NAME, f);
    RequirePartialPerm(SELF_NAME, g);

    if (TNUM_OBJ(f) == T_PPERM2) {
        if (DEG_PPERM2(f) == 0)
            return True;
        rankf = RANK_PPERM2(f);
        domf = DOM_PPERM(f);
    }
    else {
        if (DEG_PPERM4(f) == 0)
            return True;
        rankf = RANK_PPERM4(f);
        domf = DOM_PPERM(f);
    }

    if (TNUM_OBJ(g) == T_PPERM2) {
        if (DEG_PPERM2(g) == 0)
            return False;
        rankg = RANK_PPERM2(g);
        domg = DOM_PPERM(g);
    }
    else {
        if (DEG_PPERM4(g) == 0)
            return False;
        rankg = RANK_PPERM4(g);
        domg = DOM_PPERM(g);
    }

    if (rankf != rankg)
        return (rankf < rankg ? True : False);

    if (TNUM_OBJ(f) == T_PPERM2) {
        ptf2 = ADDR_PPERM2(f);
        if (TNUM_OBJ(g) == T_PPERM2) {
            ptg2 = ADDR_PPERM2(g);
            for (i = 1; i <= rankf; i++) {
                j = INT_INTOBJ(ELM_PLIST(domf, i)) - 1;
                k = INT_INTOBJ(ELM_PLIST(domg, i)) - 1;
                if (j != k)
                    return (j < k ? True : False);
                if (ptf2[j] != ptg2[j])
                    return (ptf2[j] < ptg2[j] ? True : False);
            }
        }
        else {
            ptg4 = ADDR_PPERM4(g);
            for (i = 1; i <= rankf; i++) {
                j = INT_INTOBJ(ELM_PLIST(domf, i)) - 1;
                k = INT_INTOBJ(ELM_PLIST(domg, i)) - 1;
                if (j != k)
                    return (j < k ? True : False);
                if (ptf2[j] != ptg4[j])
                    return (ptf2[j] < ptg4[j] ? True : False);
            }
        }
    }
    else {
        ptf4 = ADDR_PPERM4(f);
        if (TNUM_OBJ(g) == T_PPERM2) {
            ptg2 = ADDR_PPERM2(g);
            for (i = 1; i <= rankf; i++) {
                j = INT_INTOBJ(ELM_PLIST(domf, i)) - 1;
                k = INT_INTOBJ(ELM_PLIST(domg, i)) - 1;
                if (j != k)
                    return (j < k ? True : False);
                if (ptf4[j] != ptg2[j])
                    return (ptf4[j] < ptg2[j] ? True : False);
            }
        }
        else {
            ptg4 = ADDR_PPERM4(g);
            for (i = 1; i <= rankf; i++) {
                j = INT_INTOBJ(ELM_PLIST(domf, i)) - 1;
                k = INT_INTOBJ(ELM_PLIST(domg, i)) - 1;
                if (j != k)
                    return (j < k ? True : False);
                if (ptf4[j] != ptg4[j])
                    return (ptf4[j] < ptg4[j] ? True : False);
            }
        }
    }

    return False;
}

static Obj FuncHAS_DOM_PPERM(Obj self, Obj f)
{
    if (TNUM_OBJ(f) == T_PPERM2) {
        return (DOM_PPERM(f) == NULL ? False : True);
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        return (DOM_PPERM(f) == NULL ? False : True);
    }
    return Fail;
}

static Obj FuncHAS_IMG_PPERM(Obj self, Obj f)
{
    if (TNUM_OBJ(f) == T_PPERM2) {
        return (IMG_PPERM(f) == NULL ? False : True);
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        return (IMG_PPERM(f) == NULL ? False : True);
    }
    return Fail;
}

/**************************************************************************/

/* GAP kernel functions */

// an idempotent partial perm on the union of the domain and image
static Obj OnePPerm(Obj f)
{
    RequirePartialPerm("OnePPerm", f);

    Obj     g, img, dom;
    UInt    i, j, deg, rank;
    UInt2 * ptg2;
    UInt4 * ptg4;

    if (TNUM_OBJ(f) == T_PPERM2) {    // this could be shortened
        deg = MAX(DEG_PPERM2(f), CODEG_PPERM2(f));
        rank = RANK_PPERM2(f);
        dom = DOM_PPERM(f);
        img = IMG_PPERM(f);
    }
    else {
        deg = MAX(DEG_PPERM4(f), CODEG_PPERM4(f));
        rank = RANK_PPERM4(f);
        dom = DOM_PPERM(f);
        img = IMG_PPERM(f);
    }

    if (deg < 65536) {
        g = NEW_PPERM2(deg);
        ptg2 = ADDR_PPERM2(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(img, i)) - 1;
            ptg2[j] = j + 1;
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptg2[j] = j + 1;
        }
        SET_CODEG_PPERM2(g, deg);
    }
    else {
        g = NEW_PPERM4(deg);
        ptg4 = ADDR_PPERM4(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(img, i)) - 1;
            ptg4[j] = j + 1;
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptg4[j] = j + 1;
        }
        SET_CODEG_PPERM4(g, deg);
    }
    return g;
}

/* equality for partial perms */
template <typename TF, typename TG>
static Int EqPPerm(Obj f, Obj g)
{
    ASSERT_IS_PPERM<TF>(f);
    ASSERT_IS_PPERM<TG>(g);

    const TF * ptf = CONST_ADDR_PPERM<TF>(f);
    const TG * ptg = CONST_ADDR_PPERM<TG>(g);
    UInt    deg = DEG_PPERM<TF>(f);
    UInt    i, j, rank;
    Obj     dom;

    if (deg != DEG_PPERM<TG>(g) || CODEG_PPERM<TF>(f) != CODEG_PPERM<TG>(g))
        return 0;

    if (DOM_PPERM(f) == NULL || DOM_PPERM(g) == NULL) {
        for (i = 0; i < deg; i++)
            if (*ptf++ != *ptg++)
                return 0;
        return 1;
    }

    if (RANK_PPERM<TF>(f) != RANK_PPERM<TG>(g))
        return 0;
    dom = DOM_PPERM(f);
    rank = RANK_PPERM<TF>(f);

    for (i = 1; i <= rank; i++) {
        j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
        if (ptf[j] != ptg[j])
            return 0;
    }
    return 1;
}

/* less than for partial perms */
template <typename TF, typename TG>
static Int LtPPerm(Obj f, Obj g)
{
    ASSERT_IS_PPERM<TF>(f);
    ASSERT_IS_PPERM<TG>(g);

    const TF * ptf = CONST_ADDR_PPERM<TF>(f);
    const TG * ptg = CONST_ADDR_PPERM<TG>(g);
    UInt    deg, i;

    deg = DEG_PPERM<TF>(f);
    if (deg != DEG_PPERM<TG>(g)) {
        if (deg < DEG_PPERM<TG>(g)) {
            return 1;
        }
        else {
            return 0;
        }
    }

    for (i = 0; i < deg; i++) {
        if (*(ptf++) != *(ptg++)) {
            if (*(--ptf) < *(--ptg))
                return 1;
            else
                return 0;
        }
    }
    return 0;
}

/* product of partial perm and partial perm */
template <typename TF, typename TG>
static Obj ProdPPerm(Obj f, Obj g)
{
    ASSERT_IS_PPERM<TF>(f);
    ASSERT_IS_PPERM<TG>(g);

    UInt    deg, degg, i, j, rank, codeg;
    const TF * ptf;
    const TG * ptg;
    TG *    ptfg;
    Obj     fg, dom;

    // find the degree
    deg = DEG_PPERM<TF>(f);
    degg = DEG_PPERM<TG>(g);
    if (deg == 0 || degg == 0)
        return EmptyPartialPerm;

    ptf = CONST_ADDR_PPERM<TF>(f);
    ptg = CONST_ADDR_PPERM<TG>(g);
    while (deg > 0 &&
           (ptf[deg - 1] == 0 || IMAGEPP(ptf[deg - 1], ptg, degg) == 0))
        deg--;
    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    fg = NEW_PPERM<TG>(deg);
    ptfg = ADDR_PPERM<TG>(fg);
    ptf = CONST_ADDR_PPERM<TF>(f);
    ptg = CONST_ADDR_PPERM<TG>(g);
    codeg = 0;

    // compose in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM<TF>(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (j < deg && ptf[j] <= degg) {
                ptfg[j] = ptg[ptf[j] - 1];
                if (ptfg[j] > codeg)
                    codeg = ptfg[j];
            }
        }
    }
    else {
        // compose in deg operations
        for (i = 0; i < deg; i++) {
            if (ptf[i] != 0 && ptf[i] <= degg) {
                ptfg[i] = ptg[ptf[i] - 1];
                if (ptfg[i] > codeg)
                    codeg = ptfg[i];
            }
        }
    }
    SET_CODEG_PPERM<TG>(fg, codeg);
    return fg;
}


// compose partial perms and perms
static Obj ProdPPerm2Perm2(Obj f, Obj p)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    GAP_ASSERT(TNUM_OBJ(p) == T_PERM2);

    UInt2 * ptf, *ptp, *ptfp2;
    UInt4 * ptfp4;
    Obj     fp, dom;
    UInt    codeg, dep, deg, i, j, rank;

    dep = DEG_PERM2(p);
    deg = DEG_PPERM2(f);

    if (dep < 65536) {
        fp = NEW_PPERM2(deg);
    }
    else {    // i.e. deg(p)=65536
        fp = NEW_PPERM4(deg);
    }

    codeg = CODEG_PPERM2(f);
    ptf = ADDR_PPERM2(f);
    ptp = ADDR_PERM2(p);

    if (dep < 65536) {
        ptfp2 = ADDR_PPERM2(fp);
        if (codeg <= dep) {
            codeg = 0;
            if (DOM_PPERM(f) == NULL) {
                for (i = 0; i < deg; i++) {
                    if (ptf[i] != 0) {
                        ptfp2[i] = ptp[ptf[i] - 1] + 1;
                        if (ptfp2[i] > codeg)
                            codeg = ptfp2[i];
                    }
                }
            }
            else {
                dom = DOM_PPERM(f);
                rank = RANK_PPERM2(f);
                for (i = 1; i <= rank; i++) {
                    j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                    ptfp2[j] = ptp[ptf[j] - 1] + 1;
                    if (ptfp2[j] > codeg)
                        codeg = ptfp2[j];
                }
            }
        }
        else {
            if (DOM_PPERM(f) == NULL) {
                for (i = 0; i < deg; i++) {
                    if (ptf[i] != 0) {
                        ptfp2[i] = IMAGE(ptf[i] - 1, ptp, dep) + 1;
                    }
                }
            }
            else {
                dom = DOM_PPERM(f);
                rank = RANK_PPERM2(f);
                for (i = 1; i <= rank; i++) {
                    j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                    ptfp2[j] = IMAGE(ptf[j] - 1, ptp, dep) + 1;
                }
            }
        }
        SET_CODEG_PPERM2(fp, codeg);
    }
    else {
        ptfp4 = ADDR_PPERM4(fp);
        codeg = 0;
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptfp4[i] = ptp[ptf[i] - 1] + 1;
                    if (ptfp4[i] > codeg)
                        codeg = ptfp4[i];
                }
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptfp4[j] = ptp[ptf[j] - 1] + 1;
                if (ptfp4[j] > codeg)
                    codeg = ptfp4[j];
            }
        }
        SET_CODEG_PPERM4(fp, codeg);
    }
    return fp;
}

static Obj ProdPPerm4Perm4(Obj f, Obj p)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    GAP_ASSERT(TNUM_OBJ(p) == T_PERM4);

    UInt4 *ptf, *ptp, *ptfp;
    Obj    fp, dom;
    UInt   codeg, dep, deg, i, j, rank;

    deg = DEG_PPERM4(f);
    fp = NEW_PPERM4(deg);

    dep = DEG_PERM4(p);
    codeg = CODEG_PPERM4(f);

    ptf = ADDR_PPERM4(f);
    ptp = ADDR_PERM4(p);
    ptfp = ADDR_PPERM4(fp);

    if (codeg <= dep) {
        codeg = 0;
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptfp[i] = ptp[ptf[i] - 1] + 1;
                    if (ptfp[i] > codeg)
                        codeg = ptfp[i];
                }
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptfp[j] = ptp[ptf[j] - 1] + 1;
                if (ptfp[j] > codeg)
                    codeg = ptfp[j];
            }
        }
    }
    else {
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptfp[i] = IMAGE(ptf[i] - 1, ptp, dep) + 1;
                }
            }
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptfp[j] = IMAGE(ptf[j] - 1, ptp, dep) + 1;
            }
        }
    }
    SET_CODEG_PPERM4(fp, codeg);
    return fp;
}

static Obj ProdPPerm2Perm4(Obj f, Obj p)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    GAP_ASSERT(TNUM_OBJ(p) == T_PERM4);

    UInt2 * ptf;
    UInt4 * ptp, *ptfp;
    Obj     fp, dom;
    UInt    deg, codeg, i, j, rank;

    fp = NEW_PPERM4(DEG_PPERM2(f));
    ptf = ADDR_PPERM2(f);
    ptp = ADDR_PERM4(p);
    ptfp = ADDR_PPERM4(fp);
    codeg = 0;

    if (DOM_PPERM(f) == NULL) {
        deg = DEG_PPERM2(f);
        for (i = 0; i < deg; i++) {
            if (ptf[i] != 0) {
                ptfp[i] = ptp[ptf[i] - 1] + 1;
                if (ptfp[i] > codeg)
                    codeg = ptfp[i];
            }
        }
    }
    else {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM2(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptfp[j] = ptp[ptf[j] - 1] + 1;
            if (ptfp[j] > codeg)
                codeg = ptfp[j];
        }
    }
    SET_CODEG_PPERM4(fp, codeg);
    return fp;
}

static Obj ProdPPerm4Perm2(Obj f, Obj p)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    GAP_ASSERT(TNUM_OBJ(p) == T_PERM2);

    UInt4 *ptf, *ptfp;
    UInt2 *ptp;
    Obj    fp, dom;
    UInt   codeg, deg, dep,i, j, rank;

    deg = DEG_PPERM4(f);
    fp = NEW_PPERM4(deg);

    dep = DEG_PERM2(p);
    codeg = CODEG_PPERM4(f);

    ptf = ADDR_PPERM4(f);
    ptp = ADDR_PERM2(p);
    ptfp = ADDR_PPERM4(fp);

    if (DOM_PPERM(f) == NULL) {
        for (i = 0; i < deg; i++) {
            if (ptf[i] != 0) {
                ptfp[i] = IMAGE(ptf[i] - 1, ptp, dep) + 1;
            }
        }
    }
    else {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM4(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptfp[j] = IMAGE(ptf[j] - 1, ptp, dep) + 1;
        }
    }
    SET_CODEG_PPERM4(fp, codeg);
    return fp;
}

// product of a perm and a partial perm
template <typename TP, typename TF>
static Obj ProdPermPPerm(Obj p, Obj f)
{
    ASSERT_IS_PERM<TP>(p);
    ASSERT_IS_PPERM<TF>(f);

    const TP * ptp;
    const TF * ptf;
    TF * ptpf;
    UInt degp, degf, i;
    Obj  pf;

    if (DEG_PPERM<TF>(f) == 0)
        return EmptyPartialPerm;

    degp = DEG_PERM<TP>(p);
    degf = DEG_PPERM<TF>(f);

    if (degp < degf) {
        pf = NEW_PPERM<TF>(degf);
        ptpf = ADDR_PPERM<TF>(pf);
        ptp = CONST_ADDR_PERM<TP>(p);
        ptf = CONST_ADDR_PPERM<TF>(f);
        for (i = 0; i < degp; i++)
            *ptpf++ = ptf[*ptp++];
        for (; i < degf; i++)
            *ptpf++ = ptf[i];
    }
    else {    // deg(f)<=deg(p)
        // find the degree
        ptp = CONST_ADDR_PERM<TP>(p);
        ptf = CONST_ADDR_PPERM<TF>(f);
        while (ptp[degp - 1] >= degf || ptf[ptp[degp - 1]] == 0)
            degp--;
        pf = NEW_PPERM<TF>(degp);
        ptpf = ADDR_PPERM<TF>(pf);
        ptp = CONST_ADDR_PERM<TP>(p);
        ptf = CONST_ADDR_PPERM<TF>(f);
        for (i = 0; i < degp; i++)
            if (ptp[i] < degf)
                ptpf[i] = ptf[ptp[i]];
    }
    SET_CODEG_PPERM<TF>(pf, CODEG_PPERM<TF>(f));
    return pf;
}

// the inverse of a partial perm
template <typename Res, typename T>
static Obj InvPPerm(Obj f)
{
    ASSERT_IS_PPERM<T>(f);

    UInt    deg, codeg, i, j, rank;
    const T * ptf;
    Res *     ptinv;
    Obj     inv, dom;

    deg = DEG_PPERM<T>(f);
    codeg = CODEG_PPERM<T>(f);

    GAP_ASSERT((deg < 65536) == (sizeof(Res) == 2));

    inv = NEW_PPERM<Res>(codeg);
    ptf = CONST_ADDR_PPERM<T>(f);
    ptinv = ADDR_PPERM<Res>(inv);
    dom = DOM_PPERM(f);
    if (dom == NULL) {
        for (i = 0; i < deg; i++)
            if (ptf[i] != 0)
                ptinv[ptf[i] - 1] = i + 1;
    }
    else {
        rank = RANK_PPERM<T>(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptinv[ptf[j] - 1] = j + 1;
        }
    }
    SET_CODEG_PPERM<Res>(inv, deg);

    return inv;
}

static Obj InvPPerm2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    if (DEG_PPERM2(f) < 65536) {
        return InvPPerm<UInt2, UInt2>(f);
    }
    else {
        return InvPPerm<UInt4, UInt2>(f);
    }
}

static Obj InvPPerm4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    if (DEG_PPERM4(f) < 65536) {
        return InvPPerm<UInt2, UInt4>(f);
    }
    else {
        return InvPPerm<UInt4, UInt4>(f);
    }
}

// Conjugation: p ^ -1 * f * p
template <typename Res, typename TF, typename TP>
static Obj PowPPermPerm(Obj f, Obj p)
{
    ASSERT_IS_PPERM<TF>(f);
    ASSERT_IS_PERM<TP>(p);

    const TF * ptf;
    const TP * ptp;
    Res *   ptconj;
    UInt    deg, dep, rank, degconj, i, j, k, codeg;
    Obj     conj, dom;

    deg = DEG_PPERM<TF>(f);
    if (deg == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM<TP>(p);
    rank = RANK_PPERM<TF>(f);
    ptp = CONST_ADDR_PERM<TP>(p);
    dom = DOM_PPERM(f);

    // find deg of conjugate
    if (deg > dep) {
        degconj = deg;
    }
    else {
        degconj = 0;
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptp[j] >= degconj)
                degconj = ptp[j] + 1;
        }
    }

    conj = NEW_PPERM<Res>(degconj);
    ptconj = ADDR_PPERM<Res>(conj);
    ptp = CONST_ADDR_PERM<TP>(p);
    ptf = CONST_ADDR_PPERM<TF>(f);
    codeg = CODEG_PPERM<TF>(f);

    if (codeg > dep) {
        SET_CODEG_PPERM<Res>(conj, codeg);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptconj[IMAGE(j, ptp, dep)] = IMAGE(ptf[j] - 1, ptp, dep) + 1;
        }
    }
    else {
        codeg = 0;
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            k = ptp[ptf[j] - 1] + 1;
            ptconj[IMAGE(j, ptp, dep)] = k;
            if (k > codeg)
                codeg = k;
        }
        SET_CODEG_PPERM<Res>(conj, codeg);
    }
    return conj;
}

// special case for permutations of degree 65536
static Obj PowPPerm2Perm2(Obj f, Obj p)
{
    if (DEG_PERM2(p) == 65536)
        return PowPPermPerm<UInt4, UInt2, UInt2>(f, p);
    else
        return PowPPermPerm<UInt2, UInt2, UInt2>(f, p);
}

// g ^ -1 * f * g
template <typename TF, typename TG>
static Obj PowPPerm(Obj f, Obj g)
{
    typedef typename ResultType<TF, TG>::type Res;

    ASSERT_IS_PPERM<TF>(f);
    ASSERT_IS_PPERM<TG>(g);

    const TF * ptf;
    const TG * ptg;
    Res * ptconj;
    UInt  i, j, def, deg, dec, codeg, codec, min, img, len;
    Obj   dom, conj;

    // check if we're in the trivial case
    def = DEG_PPERM<TF>(f);
    deg = DEG_PPERM<TG>(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = CONST_ADDR_PPERM<TF>(f);
    ptg = CONST_ADDR_PPERM<TG>(g);
    dom = DOM_PPERM(f);
    codeg = CODEG_PPERM<TG>(g);
    dec = 0;
    codec = 0;

    if (dom == NULL) {
        min = MIN(def, deg);
        if (CODEG_PPERM<TF>(f) <= deg) {
            // find the degree
            for (i = 0; i < min; i++) {
                if (ptf[i] != 0 && ptg[i] > dec && ptg[ptf[i] - 1] != 0) {
                    dec = ptg[i];
                    if (dec == codeg)
                        break;
                }
            }

            if (dec == 0)
                return EmptyPartialPerm;

            // create new pperm
            conj = NEW_PPERM<Res>(dec);
            ptconj = ADDR_PPERM<Res>(conj);
            ptf = CONST_ADDR_PPERM<TF>(f);
            ptg = CONST_ADDR_PPERM<TG>(g);

            // multiply
            for (i = 0; i < min; i++) {
                if (ptf[i] != 0 && ptg[i] != 0) {
                    img = ptg[ptf[i] - 1];
                    if (img != 0) {
                        ptconj[ptg[i] - 1] = img;
                        if (img > codec)
                            codec = img;
                    }
                }
            }
        }
        else {    // codeg(f)>deg(g)
            // find the degree
            for (i = 0; i < min; i++) {
                if (ptf[i] != 0 && ptg[i] > dec &&
                    IMAGEPP(ptf[i], ptg, deg) != 0) {
                    dec = ptg[i];
                    if (dec == codeg)
                        break;
                }
            }

            if (dec == 0)
                return EmptyPartialPerm;

            // create new pperm
            conj = NEW_PPERM<Res>(dec);
            ptconj = ADDR_PPERM<Res>(conj);
            ptf = CONST_ADDR_PPERM<TF>(f);
            ptg = CONST_ADDR_PPERM<TG>(g);

            // multiply
            for (i = 0; i < min; i++) {
                if (ptf[i] != 0 && ptg[i] != 0) {
                    img = IMAGEPP(ptf[i], ptg, deg);
                    if (img != 0) {
                        ptconj[ptg[i] - 1] = img;
                        if (img > codec)
                            codec = img;
                    }
                }
            }
        }
    }
    else if (def > deg) {    // dom(f) is known
        if (CODEG_PPERM<TF>(f) <= deg) {
            // find the degree of conj
            len = LEN_PLIST(dom);
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (IMAGEPP(j + 1, ptg, deg) > dec && ptg[ptf[j] - 1] != 0) {
                    dec = ptg[j];
                    if (dec == codeg)
                        break;
                }
            }

            // create new pperm
            conj = NEW_PPERM<Res>(dec);
            ptconj = ADDR_PPERM<Res>(conj);
            ptf = CONST_ADDR_PPERM<TF>(f);
            ptg = CONST_ADDR_PPERM<TG>(g);

            // multiply
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (IMAGEPP(j + 1, ptg, deg) != 0) {
                    img = ptg[ptf[j] - 1];
                    if (img != 0) {
                        ptconj[ptg[j] - 1] = img;
                        if (img > codec)
                            codec = img;
                    }
                }
            }
        }
        else {    // codeg(f)>deg(g)
            // find the degree of conj
            len = LEN_PLIST(dom);
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (IMAGEPP(j + 1, ptg, deg) > dec &&
                    IMAGEPP(ptf[j], ptg, deg) != 0) {
                    dec = ptg[j];
                    if (dec == codeg)
                        break;
                }
            }

            // create new pperm
            conj = NEW_PPERM<Res>(dec);
            ptconj = ADDR_PPERM<Res>(conj);
            ptf = CONST_ADDR_PPERM<TF>(f);
            ptg = CONST_ADDR_PPERM<TG>(g);

            // multiply
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (IMAGEPP(j + 1, ptg, deg) != 0) {
                    img = IMAGEPP(ptf[j], ptg, deg);
                    if (img != 0) {
                        ptconj[ptg[j] - 1] = img;
                        if (img > codec)
                            codec = img;
                    }
                }
            }
        }
    }
    else {    // def<=deg and dom(f) is known
        if (CODEG_PPERM<TF>(f) <= deg) {
            // find the degree of conj
            len = LEN_PLIST(dom);
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptg[j] > dec && ptg[ptf[j] - 1] != 0) {
                    dec = ptg[j];
                    if (dec == codeg)
                        break;
                }
            }

            // create new pperm
            conj = NEW_PPERM<Res>(dec);
            ptconj = ADDR_PPERM<Res>(conj);
            ptf = CONST_ADDR_PPERM<TF>(f);
            ptg = CONST_ADDR_PPERM<TG>(g);

            // multiply
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptg[j] != 0) {
                    img = ptg[ptf[j] - 1];
                    if (img != 0) {
                        ptconj[ptg[j] - 1] = img;
                        if (img > codec)
                            codec = img;
                    }
                }
            }
        }
        else {    // codeg(f)>deg(g)
            // find the degree of conj
            len = LEN_PLIST(dom);
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptg[j] > dec && IMAGEPP(ptf[j], ptg, deg) != 0) {
                    dec = ptg[j];
                    if (dec == codeg)
                        break;
                }
            }

            // create new pperm
            conj = NEW_PPERM<Res>(dec);
            ptconj = ADDR_PPERM<Res>(conj);
            ptf = CONST_ADDR_PPERM<TF>(f);
            ptg = CONST_ADDR_PPERM<TG>(g);

            // multiply
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptg[j] != 0) {
                    img = IMAGEPP(ptf[j], ptg, deg);
                    if (img != 0) {
                        ptconj[ptg[j] - 1] = img;
                        if (img > codec)
                            codec = img;
                    }
                }
            }
        }
    }
    SET_CODEG_PPERM<Res>(conj, codec);
    return conj;
}


// f*g^-1 for partial perms
template <typename TF, typename TG>
static Obj QuoPPerm(Obj f, Obj g)
{
    ASSERT_IS_PPERM<TF>(f);
    ASSERT_IS_PPERM<TG>(g);

    const TF * ptf;
    const TG * ptg;
    UInt4 * ptquo;
    UInt4 * pttmp;
    UInt    deg, i, j, deginv, codeg, rank;
    Obj     quo, dom;

    // do nothing in the trivial case
    if (DEG_PPERM<TG>(g) == 0 || DEG_PPERM<TF>(f) == 0)
        return EmptyPartialPerm;

    // init the buffer bag
    deginv = CODEG_PPERM<TG>(g);
    ResizeTmpPPerm(deginv);
    pttmp = ADDR_PPERM4(TmpPPerm);
    for (i = 0; i < deginv; i++)
        pttmp[i] = 0;

    // invert g into the buffer bag
    ptg = CONST_ADDR_PPERM<TG>(g);
    if (DOM_PPERM(g) == NULL) {
        deg = DEG_PPERM<TG>(g);
        for (i = 0; i < deg; i++)
            if (ptg[i] != 0)
                pttmp[ptg[i] - 1] = i + 1;
    }
    else {
        dom = DOM_PPERM(g);
        rank = RANK_PPERM<TG>(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            pttmp[ptg[j] - 1] = j + 1;
        }
    }

    // find the degree of the quotient
    deg = DEG_PPERM<TF>(f);
    ptf = CONST_ADDR_PPERM<TF>(f);
    while (deg > 0 &&
           (ptf[deg - 1] == 0 || IMAGEPP(ptf[deg - 1], pttmp, deginv) == 0))
        deg--;
    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    quo = NEW_PPERM4(deg);
    ptquo = ADDR_PPERM4(quo);
    ptf = CONST_ADDR_PPERM<TF>(f);
    pttmp = ADDR_PPERM4(TmpPPerm);
    codeg = 0;

    // compose f with g^-1 in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM<TF>(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (j < deg && ptf[j] <= deginv) {
                ptquo[j] = pttmp[ptf[j] - 1];
                if (ptquo[j] > codeg)
                    codeg = ptquo[j];
            }
        }
    }
    else {
        // compose f with g^-1 in deg operations
        for (i = 0; i < deg; i++) {
            if (ptf[i] != 0 && ptf[i] <= deginv) {
                ptquo[i] = pttmp[ptf[i] - 1];
                if (ptquo[i] > codeg)
                    codeg = ptquo[i];
            }
        }
    }
    SET_CODEG_PPERM4(quo, codeg);
    return quo;
}


// i^f
static Obj PowIntPPerm2(Obj i, Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);

    if (!IS_POS_INTOBJ(i)) {
        ErrorQuit("usage: the first argument must be a positive small integer,",
                  0, 0);
    }
    return INTOBJ_INT(
        IMAGEPP((UInt)INT_INTOBJ(i), ADDR_PPERM2(f), DEG_PPERM2(f)));
}

static Obj PowIntPPerm4(Obj i, Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);

    if (!IS_POS_INTOBJ(i)) {
        ErrorQuit("usage: the first argument must be a positive small integer,",
                  0, 0);
    }
    return INTOBJ_INT(
        IMAGEPP((UInt)INT_INTOBJ(i), ADDR_PPERM4(f), DEG_PPERM4(f)));
}

// p^-1*f
template <typename TP, typename TF>
static Obj LQuoPermPPerm(Obj p, Obj f)
{
    ASSERT_IS_PERM<TP>(p);
    ASSERT_IS_PPERM<TF>(f);

    const TP *   ptp;
    const TF *   ptf;
    TF *   ptlquo;
    UInt   def, dep, i, j, del, len;
    Obj    dom, lquo;

    def = DEG_PPERM<TF>(f);
    if (def == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM<TP>(p);
    dom = DOM_PPERM(f);

    if (dep < def) {
        lquo = NEW_PPERM<TF>(def);
        ptlquo = ADDR_PPERM<TF>(lquo);
        ptp = CONST_ADDR_PERM<TP>(p);
        ptf = CONST_ADDR_PPERM<TF>(f);
        if (dom == NULL) {
            for (i = 0; i < dep; i++)
                ptlquo[ptp[i]] = ptf[i];
            for (; i < def; i++)
                ptlquo[i] = ptf[i];
        }
        else {
            len = LEN_PLIST(dom);
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptlquo[IMAGE(j, ptp, dep)] = ptf[j];
            }
        }
    }
    else {    // deg(p)>=deg(f)
        del = 0;
        ptp = CONST_ADDR_PERM<TP>(p);
        ptf = CONST_ADDR_PPERM<TF>(f);
        if (dom == NULL) {
            // find the degree
            for (i = 0; i < def; i++) {
                if (ptf[i] != 0 && ptp[i] >= del) {
                    del = ptp[i] + 1;
                    if (del == dep)
                        break;
                }
            }
            lquo = NEW_PPERM<TF>(del);
            ptlquo = ADDR_PPERM<TF>(lquo);
            ptp = CONST_ADDR_PERM<TP>(p);
            ptf = CONST_ADDR_PPERM<TF>(f);

            // if required below in case ptp[i]>del but ptf[i]=0
            for (i = 0; i < def; i++)
                if (ptf[i] != 0)
                    ptlquo[ptp[i]] = ptf[i];
        }
        else {    // dom(f) is known
            len = LEN_PLIST(dom);
            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptp[j] >= del) {
                    del = ptp[j] + 1;
                    if (del == dep)
                        break;
                }
            }
            lquo = NEW_PPERM<TF>(del);
            ptlquo = ADDR_PPERM<TF>(lquo);
            ptp = CONST_ADDR_PERM<TP>(p);
            ptf = CONST_ADDR_PPERM<TF>(f);

            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptlquo[ptp[j]] = ptf[j];
            }
        }
    }

    SET_CODEG_PPERM<TF>(lquo, CODEG_PPERM<TF>(f));
    return lquo;
}


// f^-1*g
template <typename TF, typename TG>
static Obj LQuoPPerm(Obj f, Obj g)
{
    ASSERT_IS_PPERM<TF>(f);
    ASSERT_IS_PPERM<TG>(g);

    const TF * ptf;
    const TG * ptg;
    TG * ptlquo;
    UInt i, j, def, deg, del, codef, codel, min, len;
    Obj  dom, lquo;

    // check if we're in the trivial case
    def = DEG_PPERM<TF>(f);
    deg = DEG_PPERM<TG>(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = CONST_ADDR_PPERM<TF>(f);
    ptg = CONST_ADDR_PPERM<TG>(g);
    dom = DOM_PPERM(g);
    del = 0;
    codef = CODEG_PPERM<TF>(f);
    codel = 0;

    if (dom == NULL) {
        // find the degree of lquo
        min = MIN(def, deg);
        for (i = 0; i < min; i++) {
            if (ptg[i] != 0 && ptf[i] > del) {
                del = ptf[i];
                if (del == codef)
                    break;
            }
        }
        if (del == 0)
            return EmptyPartialPerm;

        // create new pperm
        lquo = NEW_PPERM<TG>(del);
        ptlquo = ADDR_PPERM<TG>(lquo);
        ptf = CONST_ADDR_PPERM<TF>(f);
        ptg = CONST_ADDR_PPERM<TG>(g);

        // multiply
        for (i = 0; i < min; i++) {
            if (ptf[i] != 0 && ptg[i] != 0) {
                ptlquo[ptf[i] - 1] = ptg[i];
                if (ptg[i] > codel)
                    codel = ptg[i];
            }
        }
    }
    else if (deg > def) {    // dom(g) is known
        // find the degree of lquo
        len = LEN_PLIST(dom);
        for (i = 1; i <= len; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (IMAGEPP(j + 1, ptf, def) > del) {
                del = ptf[j];
                if (del == codef)
                    break;
            }
        }

        // create new pperm
        lquo = NEW_PPERM<TG>(del);
        ptlquo = ADDR_PPERM<TG>(lquo);
        ptf = CONST_ADDR_PPERM<TF>(f);
        ptg = CONST_ADDR_PPERM<TG>(g);

        // multiply
        for (i = 1; i <= len; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (IMAGEPP(j + 1, ptf, def) != 0) {
                ptlquo[ptf[j] - 1] = ptg[j];
                if (ptg[j] > codel)
                    codel = ptg[j];
            }
        }
    }
    else {    // deg<=def and dom(g) is known
        len = LEN_PLIST(dom);
        for (i = 1; i <= len; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptf[j] > del) {
                del = ptf[j];
                if (del == codef)
                    break;
            }
        }

        // create new pperm
        lquo = NEW_PPERM<TG>(del);
        ptlquo = ADDR_PPERM<TG>(lquo);
        ptf = CONST_ADDR_PPERM<TF>(f);
        ptg = CONST_ADDR_PPERM<TG>(g);

        // multiply
        for (i = 1; i <= len; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptf[j] != 0) {
                ptlquo[ptf[j] - 1] = ptg[j];
                if (ptg[j] > codel)
                    codel = ptg[j];
            }
        }
    }
    SET_CODEG_PPERM<TG>(lquo, codel);
    return lquo;
}


/****************************************************************************
**
*F  OnSetsPPerm( <set>, <f> ) . . . . . . . . .  operations on sets of points
**
**  'OnSetsPPerm' returns the  image of the  tuple <set> under the partial
**  permutation <f>.  It is called from 'FuncOnSets'.
**
**  The input <set> must be a non-empty set, i.e., plain, dense and strictly
**  sorted. This is not verified.
*/
Obj OnSetsPPerm(Obj set, Obj f)
{
    UInt2 *     ptf2;
    UInt4 *     ptf4;
    UInt        deg;
    Obj         res;
    const Obj * ptres;
    Obj *       ptresOut;
    UInt        i, k, reslen;
    Obj         tmp;

    // copy the list into a mutable plist, which we will then modify in place
    res = PLAIN_LIST_COPY(set);
    const UInt len = LEN_PLIST(res);

    /* get the pointer                                                 */
    ptres = CONST_ADDR_OBJ(res) + 1;
    ptresOut = ADDR_OBJ(res) + 1;
    reslen = 0;

    if (TNUM_OBJ(f) == T_PPERM2) {
        ptf2 = ADDR_PPERM2(f);
        deg = DEG_PPERM2(f);

        /* loop over the entries of the tuple                              */
        for (i = 1; i <= len; i++, ptres++) {
            tmp = *ptres;
            if (IS_POS_INTOBJ(tmp)) {
                k = INT_INTOBJ(tmp);
                if (k <= deg && ptf2[k - 1] != 0) {
                    reslen++;
                    *ptresOut++ = INTOBJ_INT(ptf2[k - 1]);
                }
            }
            else {
                // This case currently does not work since PowIntPPerm2/4 only
                // works for small integers, and returns an error for non-small
                // integers. The analogous code in permutat.c uses the macro
                // POW, which calls PowIntPerm2/4, which if called with a
                // non-small positive integer returns that integer, since every
                // permutation fixes every non-small positive integer.
                ErrorQuit("<set> must be a list of positive small integers", 0, 0);
            }
        }
    }
    else {
        ptf4 = ADDR_PPERM4(f);
        deg = DEG_PPERM4(f);

        /* loop over the entries of the tuple                              */
        for (i = 1; i <= len; i++, ptres++) {
            tmp = *ptres;
            if (IS_POS_INTOBJ(tmp)) {
                k = INT_INTOBJ(tmp);
                if (k <= deg && ptf4[k - 1] != 0) {
                    reslen++;
                    *ptresOut++ = INTOBJ_INT(ptf4[k - 1]);
                }
            }
            else {
                // This case currently does not work since PowIntPPerm2/4 only
                // works for small integers, and returns an error for non-small
                // integers. The analogous code in permutat.c uses the macro
                // POW, which calls PowIntPerm2/4, which if called with a
                // non-small positive integer returns that integer, since every
                // permutation fixes every non-small positive integer.
                ErrorQuit("<set> must be a list of positive small integers", 0, 0);
            }
        }
    }

    SET_LEN_PLIST(res, reslen);
    SHRINK_PLIST(res, reslen);

    if (reslen == 0) {
        RetypeBagSM(res, T_PLIST_EMPTY);
    }
    else {
        SortPlistByRawObj(res);
        RetypeBagSM(res, T_PLIST_CYC_SSORT);
    }

    return res;
}

/****************************************************************************
**
*F  OnTuplesPPerm( <tup>, <f> ) . . . . . . .  operations on tuples of points
**
**  'OnTuplesPPerm'  returns  the  image  of  the  tuple  <tup>   under  the
**  partial permutation <f>.  It is called from 'FuncOnTuples'.
**
**  The input <tup> must be a non-empty and dense plain list. This is not
**  verified.
*/
Obj OnTuplesPPerm(Obj tup, Obj f)
{
    UInt2 *     ptf2;
    UInt4 *     ptf4;
    UInt        deg;
    Obj         res;
    const Obj * ptres;
    Obj *       ptresOut;
    UInt        i, k, reslen;
    Obj         tmp;

    // copy the list into a mutable plist, which we will then modify in place
    res = PLAIN_LIST_COPY(tup);
    RESET_FILT_LIST(res, FN_IS_SSORT);
    RESET_FILT_LIST(res, FN_IS_NSORT);
    const UInt len = LEN_PLIST(res);

    /* get the pointer                                                 */
    ptres = CONST_ADDR_OBJ(res) + 1;
    ptresOut = ADDR_OBJ(res) + 1;
    reslen = 0;

    if (TNUM_OBJ(f) == T_PPERM2) {
        ptf2 = ADDR_PPERM2(f);
        deg = DEG_PPERM2(f);

        /* loop over the entries of the tuple                              */
        for (i = 1; i <= len; i++, ptres++) {
            tmp = *ptres;
            if (IS_POS_INTOBJ(tmp)) {
                k = INT_INTOBJ(tmp);
                if (k <= deg && ptf2[k - 1] != 0) {
                    reslen++;
                    *ptresOut++ = INTOBJ_INT(ptf2[k - 1]);
                }
            }
            else {
                // This case currently does not work since PowIntPPerm2/4 only
                // works for small integers, and returns an error for non-small
                // integers. The analogous code in permutat.c uses the macro
                // POW, which calls PowIntPerm2/4, which if called with a
                // non-small positive integer returns that integer, since every
                // permutation fixes every non-small positive integer.
                ErrorQuit("<tup> must be a list of small integers", 0, 0);
            }
        }
    }
    else {
        ptf4 = ADDR_PPERM4(f);
        deg = DEG_PPERM4(f);

        /* loop over the entries of the tuple                              */
        for (i = 1; i <= len; i++, ptres++) {
            tmp = *ptres;
            if (IS_POS_INTOBJ(tmp)) {
                k = INT_INTOBJ(tmp);
                if (k <= deg && ptf4[k - 1] != 0) {
                    reslen++;
                    *ptresOut++ = INTOBJ_INT(ptf4[k - 1]);
                }
            }
            else {
                // This case currently does not work since PowIntPPerm2/4 only
                // works for small integers, and returns an error for non-small
                // integers. The analogous code in permutat.c uses the macro
                // POW, which calls PowIntPerm2/4, which if called with a
                // non-small positive integer returns that integer, since every
                // permutation fixes every non-small positive integer.
                ErrorQuit("<tup> must be a list of small integers", 0, 0);
            }
        }
    }
    SET_LEN_PLIST(res, reslen);
    SHRINK_PLIST(res, reslen);

    return res;
}

static Obj FuncOnPosIntSetsPartialPerm(Obj self, Obj set, Obj f)
{
    RequireSmallList("OnPosIntSetsPartialPerm", set);
    RequirePartialPerm("OnPosIntSetsPartialPerm", f);

    const UInt len = LEN_LIST(set);

    if (len == 0)
        return set;

    if (len == 1 && ELM_LIST(set, 1) == INTOBJ_INT(0)) {
        return FuncIMAGE_SET_PPERM(self, f);
    }

    return OnSetsPPerm(set, f);
}

/****************************************************************************/
/****************************************************************************/

/* other internal things */

#ifdef GAP_ENABLE_SAVELOAD
/* Save and load */
static void SavePPerm2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);

    UInt2 * ptr;
    UInt    len, i;
    len = DEG_PPERM2(f);
    ptr = ADDR_PPERM2(f) - 1;
    for (i = 0; i < len + 1; i++)
        SaveUInt2(*ptr++);
}

static void LoadPPerm2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);

    UInt2 * ptr;
    UInt    len, i;
    len = DEG_PPERM2(f);
    ptr = ADDR_PPERM2(f) - 1;
    for (i = 0; i < len + 1; i++)
        *ptr++ = LoadUInt2();
}

static void SavePPerm4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);

    UInt4 * ptr;
    UInt    len, i;
    len = DEG_PPERM4(f);
    ptr = ADDR_PPERM4(f) - 1;
    for (i = 0; i < len + 1; i++)
        SaveUInt4(*ptr++);
}

static void LoadPPerm4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);

    UInt4 * ptr;
    UInt    len, i;
    len = DEG_PPERM4(f);
    ptr = ADDR_PPERM4(f) - 1;
    for (i = 0; i < len + 1; i++)
        *ptr++ = LoadUInt4();
}
#endif


static Obj TYPE_PPERM2;

static Obj TypePPerm2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    return TYPE_PPERM2;
}

static Obj TYPE_PPERM4;

static Obj TypePPerm4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    return TYPE_PPERM4;
}

static Obj IsPPermFilt;

static Obj FiltIS_PPERM(Obj self, Obj val)
{
    /* return 'true' if <val> is a partial perm and 'false' otherwise       */
    if (TNUM_OBJ(val) == T_PPERM2 || TNUM_OBJ(val) == T_PPERM4) {
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
  { T_PPERM2,                         "partial perm (small)"           },
  { T_PPERM4,                         "partial perm (large)"           },
  { -1,                               ""                               }
};


/**************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts[] = {

    GVAR_FILT(IS_PPERM, "obj", &IsPPermFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
 *V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
 */
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_0ARGS(EmptyPartialPerm),
    GVAR_FUNC_1ARGS(DensePartialPermNC, img),
    GVAR_FUNC_2ARGS(SparsePartialPermNC, dom, img),
    GVAR_FUNC_1ARGS(DegreeOfPartialPerm, f),
    GVAR_FUNC_1ARGS(CoDegreeOfPartialPerm, f),
    GVAR_FUNC_1ARGS(RankOfPartialPerm, f),
    GVAR_FUNC_1ARGS(IMAGE_PPERM, f),
    GVAR_FUNC_1ARGS(DOMAIN_PPERM, f),
    GVAR_FUNC_1ARGS(IMAGE_SET_PPERM, f),
    GVAR_FUNC_2ARGS(PREIMAGE_PPERM_INT, f, i),
    GVAR_FUNC_1ARGS(INDEX_PERIOD_PPERM, f),
    GVAR_FUNC_1ARGS(SMALLEST_IDEM_POW_PPERM, f),
    GVAR_FUNC_1ARGS(COMPONENT_REPS_PPERM, f),
    GVAR_FUNC_1ARGS(NR_COMPONENTS_PPERM, f),
    GVAR_FUNC_1ARGS(COMPONENTS_PPERM, f),
    GVAR_FUNC_2ARGS(COMPONENT_PPERM_INT, f, pt),
    GVAR_FUNC_1ARGS(FIXED_PTS_PPERM, f),
    GVAR_FUNC_1ARGS(NR_FIXED_PTS_PPERM, f),
    GVAR_FUNC_1ARGS(MOVED_PTS_PPERM, f),
    GVAR_FUNC_1ARGS(NR_MOVED_PTS_PPERM, f),
    GVAR_FUNC_1ARGS(LARGEST_MOVED_PT_PPERM, f),
    GVAR_FUNC_1ARGS(SMALLEST_MOVED_PT_PPERM, f),
    GVAR_FUNC_1ARGS(TRIM_PPERM, f),
    GVAR_FUNC_2ARGS(HASH_FUNC_FOR_PPERM, f, data),
    GVAR_FUNC_1ARGS(IS_IDEM_PPERM, f),
    GVAR_FUNC_1ARGS(LEFT_ONE_PPERM, f),
    GVAR_FUNC_1ARGS(RIGHT_ONE_PPERM, f),
    GVAR_FUNC_2ARGS(NaturalLeqPartialPerm, f, g),
    GVAR_FUNC_2ARGS(JOIN_PPERMS, f, g),
    GVAR_FUNC_2ARGS(JOIN_IDEM_PPERMS, f, g),
    GVAR_FUNC_2ARGS(MEET_PPERMS, f, g),
    GVAR_FUNC_2ARGS(RESTRICTED_PPERM, f, g),
    GVAR_FUNC_2ARGS(AS_PPERM_PERM, p, set),
    GVAR_FUNC_1ARGS(AS_PERM_PPERM, f),
    GVAR_FUNC_2ARGS(PERM_LEFT_QUO_PPERM_NC, f, g),
    GVAR_FUNC_2ARGS(ShortLexLeqPartialPerm, f, g),
    GVAR_FUNC_1ARGS(HAS_DOM_PPERM, f),
    GVAR_FUNC_1ARGS(HAS_IMG_PPERM, f),
    GVAR_FUNC_2ARGS(OnPosIntSetsPartialPerm, set, f),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
 *F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
 */
static Int InitKernel(StructInitInfo * module)
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking function                                        */
    InitMarkFuncBags(T_PPERM2, MarkTwoSubBags);
    InitMarkFuncBags(T_PPERM4, MarkTwoSubBags);

#ifdef HPCGAP
    MakeBagTypePublic(T_PPERM2);
    MakeBagTypePublic(T_PPERM4);
#endif

    /* install the type function                                           */
    ImportGVarFromLibrary("TYPE_PPERM2", &TYPE_PPERM2);
    ImportGVarFromLibrary("TYPE_PPERM4", &TYPE_PPERM4);

    TypeObjFuncs[T_PPERM2] = TypePPerm2;
    TypeObjFuncs[T_PPERM4] = TypePPerm4;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable(GVarFilts);
    InitHdlrFuncsFromTable(GVarFuncs);

/* make the buffer bag                                                 */
#ifndef HPCGAP
    InitGlobalBag(&TmpPPerm, "src/pperm.c:TmpPPerm");
#endif

    InitGlobalBag(&EmptyPartialPerm, "src/pperm.c:EmptyPartialPerm");

#ifdef GAP_ENABLE_SAVELOAD
    /* install the saving functions */
    SaveObjFuncs[T_PPERM2] = SavePPerm2;
    LoadObjFuncs[T_PPERM2] = LoadPPerm2;
    SaveObjFuncs[T_PPERM4] = SavePPerm4;
    LoadObjFuncs[T_PPERM4] = LoadPPerm4;
#endif

    /* install the comparison methods                                      */
    EqFuncs[T_PPERM2][T_PPERM2] = EqPPerm<UInt2, UInt2>;
    EqFuncs[T_PPERM4][T_PPERM4] = EqPPerm<UInt4, UInt4>;
    EqFuncs[T_PPERM4][T_PPERM2] = EqPPerm<UInt4, UInt2>;
    EqFuncs[T_PPERM2][T_PPERM4] = EqPPerm<UInt2, UInt4>;
    LtFuncs[T_PPERM2][T_PPERM2] = LtPPerm<UInt2, UInt2>;
    LtFuncs[T_PPERM4][T_PPERM4] = LtPPerm<UInt4, UInt4>;
    LtFuncs[T_PPERM2][T_PPERM4] = LtPPerm<UInt2, UInt4>;
    LtFuncs[T_PPERM4][T_PPERM2] = LtPPerm<UInt4, UInt2>;

    /* install the binary operations */
    ProdFuncs[T_PPERM2][T_PPERM2] = ProdPPerm<UInt2, UInt2>;
    ProdFuncs[T_PPERM4][T_PPERM2] = ProdPPerm<UInt4, UInt2>;
    ProdFuncs[T_PPERM2][T_PPERM4] = ProdPPerm<UInt2, UInt4>;
    ProdFuncs[T_PPERM4][T_PPERM4] = ProdPPerm<UInt4, UInt4>;
    ProdFuncs[T_PPERM2][T_PERM2] = ProdPPerm2Perm2;
    ProdFuncs[T_PPERM4][T_PERM4] = ProdPPerm4Perm4;
    ProdFuncs[T_PPERM2][T_PERM4] = ProdPPerm2Perm4;
    ProdFuncs[T_PPERM4][T_PERM2] = ProdPPerm4Perm2;
    ProdFuncs[T_PERM2][T_PPERM2] = ProdPermPPerm<UInt2, UInt2>;
    ProdFuncs[T_PERM4][T_PPERM4] = ProdPermPPerm<UInt4, UInt4>;
    ProdFuncs[T_PERM4][T_PPERM2] = ProdPermPPerm<UInt4, UInt2>;
    ProdFuncs[T_PERM2][T_PPERM4] = ProdPermPPerm<UInt2, UInt4>;
    PowFuncs[T_INT][T_PPERM2] = PowIntPPerm2;
    PowFuncs[T_INT][T_PPERM4] = PowIntPPerm4;
    PowFuncs[T_PPERM2][T_PERM2] = PowPPerm2Perm2; // special case
    PowFuncs[T_PPERM2][T_PERM4] = PowPPermPerm<UInt4, UInt2, UInt4>;
    PowFuncs[T_PPERM4][T_PERM2] = PowPPermPerm<UInt4, UInt4, UInt2>;
    PowFuncs[T_PPERM4][T_PERM4] = PowPPermPerm<UInt4, UInt4, UInt4>;
    PowFuncs[T_PPERM2][T_PPERM2] = PowPPerm<UInt2, UInt2>;
    PowFuncs[T_PPERM2][T_PPERM4] = PowPPerm<UInt2, UInt4>;
    PowFuncs[T_PPERM4][T_PPERM2] = PowPPerm<UInt4, UInt2>;
    PowFuncs[T_PPERM4][T_PPERM4] = PowPPerm<UInt4, UInt4>;
    // for quotients of a partial permutation by a permutation, we rely on the
    // default handler 'QuoDefault'; that uses the inverse of the permutation,
    // which is cached
    QuoFuncs[T_PPERM2][T_PPERM2] = QuoPPerm<UInt2, UInt2>;
    QuoFuncs[T_PPERM2][T_PPERM4] = QuoPPerm<UInt2, UInt4>;
    QuoFuncs[T_PPERM4][T_PPERM2] = QuoPPerm<UInt4, UInt2>;
    QuoFuncs[T_PPERM4][T_PPERM4] = QuoPPerm<UInt4, UInt4>;
    QuoFuncs[T_INT][T_PPERM2] = PreImagePPermInt<UInt2>;
    QuoFuncs[T_INT][T_PPERM4] = PreImagePPermInt<UInt4>;
    LQuoFuncs[T_PERM2][T_PPERM2] = LQuoPermPPerm<UInt2, UInt2>;
    LQuoFuncs[T_PERM2][T_PPERM4] = LQuoPermPPerm<UInt2, UInt4>;
    LQuoFuncs[T_PERM4][T_PPERM2] = LQuoPermPPerm<UInt4, UInt2>;
    LQuoFuncs[T_PERM4][T_PPERM4] = LQuoPermPPerm<UInt4, UInt4>;
    LQuoFuncs[T_PPERM2][T_PPERM2] = LQuoPPerm<UInt2, UInt2>;
    LQuoFuncs[T_PPERM2][T_PPERM4] = LQuoPPerm<UInt2, UInt4>;
    LQuoFuncs[T_PPERM4][T_PPERM2] = LQuoPPerm<UInt4, UInt2>;
    LQuoFuncs[T_PPERM4][T_PPERM4] = LQuoPPerm<UInt4, UInt4>;

    /* install the one function for partial perms */
    OneFuncs[T_PPERM2] = OnePPerm;
    OneFuncs[T_PPERM4] = OnePPerm;
    OneMutFuncs[T_PPERM2] = OnePPerm;
    OneMutFuncs[T_PPERM4] = OnePPerm;

    /* install the inverse functions for partial perms */
    InvFuncs[T_PPERM2] = InvPPerm2;
    InvFuncs[T_PPERM4] = InvPPerm4;
    InvMutFuncs[T_PPERM2] = InvPPerm2;
    InvMutFuncs[T_PPERM4] = InvPPerm4;

    return 0;
}

/****************************************************************************
 *F InitLibrary( <module> ) . . . . . . .  initialise library data structures
 */
static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable(GVarFuncs);
    InitGVarFiltsFromTable(GVarFilts);

    EmptyPartialPerm = NEW_PPERM2(0);

    // We make the following partial perms to allow testing of some parts of
    // the code which would not otherwise be accessible, since no partial perm
    // created in this file is a T_PPERM4 can have degree 0, for example. Such
    // partial perm can be created by packages with a kernel module, and so we
    // introduce these partial perms for testing purposes.
    Obj EMPTY_PPERM4 = NEW_PPERM4(0);
    AssReadOnlyGVar(GVarName("EMPTY_PPERM4"), EMPTY_PPERM4);

    Obj ID_PPERM2 = NEW_PPERM2(1);
    ADDR_PPERM2(ID_PPERM2)[0] = 1;
    AssReadOnlyGVar(GVarName("ID_PPERM2"), ID_PPERM2);

    Obj ID_PPERM4 = NEW_PPERM4(1);
    ADDR_PPERM4(ID_PPERM4)[0] = 1;
    AssReadOnlyGVar(GVarName("ID_PPERM4"), ID_PPERM4);

    return 0;
}


static Int InitModuleState(void)
{
    TmpPPerm = 0;

    return 0;
}


/**************************************************************************
 **
 *F InitInfoPPerm()   . . . . . . . . . . . . . . . table of init functions
 */
static StructInitInfo module = {
 /* type        = */ MODULE_BUILTIN,
 /* name        = */ "pperm",
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
 /* moduleStateSize      = */ sizeof(PPermModuleState),
 /* moduleStateOffsetPtr = */ &PPermStateOffset,
 /* initModuleState      = */ InitModuleState,
 /* destroyModuleState   = */ 0,
};

StructInitInfo * InitInfoPPerm(void)
{
    return &module;
}
