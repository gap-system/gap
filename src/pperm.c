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

#include <src/pperm.h>

#include <src/ariths.h>
#include <src/bool.h>
#include <src/gap.h>
#include <src/gapstate.h>
#include <src/integer.h>
#include <src/intfuncs.h>
#include <src/io.h>
#include <src/lists.h>
#include <src/opers.h>
#include <src/permutat.h>
#include <src/plist.h>
#include <src/saveload.h>


#define MAX(a, b) (a < b ? b : a)
#define MIN(a, b) (a < b ? a : b)

#define IMAGEPP(i, ptf, deg) (i <= deg ? ptf[i - 1] : 0)

Obj EmptyPartialPerm;


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

static inline UInt GET_CODEG_PPERM2(Obj f)
{
    GAP_ASSERT(IS_PPERM(f));
    return (*(UInt2 *)((const Obj *)(CONST_ADDR_OBJ(f)) + 2));
}

static inline void SET_CODEG_PPERM2(Obj f, UInt2 codeg)
{
    GAP_ASSERT(IS_PPERM(f));
    (*(UInt2 *)((Obj *)(ADDR_OBJ(f)) + 2)) = codeg;
}

UInt CODEG_PPERM2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    if (GET_CODEG_PPERM2(f) != 0) {
      return GET_CODEG_PPERM2(f);
    }
    UInt codeg = 0;
    UInt i;
    UInt2* ptf = ADDR_PPERM2(f);
    for (i = 0; i < DEG_PPERM2(f); i++) {
      if (ptf[i] > codeg) {
        codeg = ptf[i];
      }
    }
    SET_CODEG_PPERM2(f, codeg);
    return codeg;
}

static inline UInt GET_CODEG_PPERM4(Obj f)
{
    GAP_ASSERT(IS_PPERM(f));
    return (*(const UInt4 *)((const Obj *)(CONST_ADDR_OBJ(f)) + 2));
}

static inline void SET_CODEG_PPERM4(Obj f, UInt4 codeg)
{
    GAP_ASSERT(IS_PPERM(f));
    (*(UInt4 *)((Obj *)(ADDR_OBJ(f)) + 2)) = codeg;
}

UInt CODEG_PPERM4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    if (GET_CODEG_PPERM4(f) != 0) {
      return GET_CODEG_PPERM4(f);
    }
    UInt codeg = 0;
    UInt i;
    UInt4* ptf = ADDR_PPERM4(f);
    for (i = 0; i < DEG_PPERM4(f); i++) {
      if (ptf[i] > codeg) {
        codeg = ptf[i];
      }
    }
    SET_CODEG_PPERM4(f, codeg);
    return codeg;
}

Obj NEW_PPERM2(UInt deg)
{
    // No assert since the values stored in this pperm must be UInt2s but the
    // degree might be a UInt4.
    return NewBag(T_PPERM2, (deg + 1) * sizeof(UInt2) + 2 * sizeof(Obj));
}

Obj NEW_PPERM4(UInt deg)
{
    return NewBag(T_PPERM4, (deg + 1) * sizeof(UInt4) + 2 * sizeof(Obj));
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
    GAP_ASSERT(IS_PLIST(img) && !IS_MUTABLE_PLIST(img));
    GAP_ASSERT(DOM_PPERM(f) == NULL ||
               LEN_PLIST(img) == LEN_PLIST(DOM_PPERM(f)));
    // TODO Could check entries of img are valid
    ADDR_OBJ(f)[0] = img;
}

static inline void SET_DOM_PPERM(Obj f, Obj dom)
{
    GAP_ASSERT(IS_PPERM(f));
    GAP_ASSERT(IS_PLIST(dom) && !IS_MUTABLE_PLIST(dom));
    GAP_ASSERT(IMG_PPERM(f) == NULL ||
               LEN_PLIST(dom) == LEN_PLIST(IMG_PPERM(f)));
    // TODO Could check entries of img are valid
    ADDR_OBJ(f)[1] = dom;
}

// find domain and img set (unsorted) return the rank

static UInt INIT_PPERM2(Obj f)
{
    UInt    deg, rank, i;
    UInt2 * ptf;
    Obj     img, dom;

    deg = DEG_PPERM2(f);

    if (deg == 0) {
        dom = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
        SET_LEN_PLIST(dom, 0);
        SET_DOM_PPERM(f, dom);
        SET_IMG_PPERM(f, dom);
        CHANGED_BAG(f);
        return deg;
    }

    dom = NEW_PLIST(T_PLIST_CYC_SSORT + IMMUTABLE, deg);
    img = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, deg);

    /* renew the ptr in case of garbage collection */
    ptf = ADDR_PPERM2(f);

    rank = 0;
    for (i = 0; i < deg; i++) {
        if (ptf[i] != 0) {
            rank++;
            SET_ELM_PLIST(dom, rank, INTOBJ_INT(i + 1));
            SET_ELM_PLIST(img, rank, INTOBJ_INT(ptf[i]));
        }
    }

    if (rank == 0) {
        RetypeBag(img, T_PLIST_EMPTY + IMMUTABLE);
        RetypeBag(dom, T_PLIST_EMPTY + IMMUTABLE);
    }

    SHRINK_PLIST(img, (Int)rank);
    SET_LEN_PLIST(img, (Int)rank);
    SHRINK_PLIST(dom, (Int)rank);
    SET_LEN_PLIST(dom, (Int)rank);

    SET_DOM_PPERM(f, dom);
    SET_IMG_PPERM(f, img);
    CHANGED_BAG(f);
    return rank;
}

static UInt INIT_PPERM4(Obj f)
{
    UInt    deg, rank, i;
    UInt4 * ptf;
    Obj     img, dom;

    deg = DEG_PPERM4(f);

    if (deg == 0) {
        dom = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
        SET_LEN_PLIST(dom, 0);
        SET_DOM_PPERM(f, dom);
        SET_IMG_PPERM(f, dom);
        CHANGED_BAG(f);
        return deg;
    }

    dom = NEW_PLIST(T_PLIST_CYC_SSORT + IMMUTABLE, deg);
    img = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, deg);

    ptf = ADDR_PPERM4(f);

    rank = 0;
    for (i = 0; i < deg; i++) {
        if (ptf[i] != 0) {
            rank++;
            SET_ELM_PLIST(dom, rank, INTOBJ_INT(i + 1));
            SET_ELM_PLIST(img, rank, INTOBJ_INT(ptf[i]));
        }
    }

    if (rank == 0) {
        RetypeBag(img, T_PLIST_EMPTY + IMMUTABLE);
        RetypeBag(dom, T_PLIST_EMPTY + IMMUTABLE);
    }

    SHRINK_PLIST(img, (Int)rank);
    SET_LEN_PLIST(img, (Int)rank);
    SHRINK_PLIST(dom, (Int)rank);
    SET_LEN_PLIST(dom, (Int)rank);

    SET_DOM_PPERM(f, dom);
    SET_IMG_PPERM(f, img);
    CHANGED_BAG(f);
    return rank;
}

UInt RANK_PPERM2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM2);
    return (IMG_PPERM(f) == NULL ? INIT_PPERM2(f) : LEN_PLIST(IMG_PPERM(f)));
}

UInt RANK_PPERM4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_PPERM4);
    return (IMG_PPERM(f) == NULL ? INIT_PPERM4(f) : LEN_PLIST(IMG_PPERM(f)));
}

static Obj SORT_PLIST_CYC(Obj res)
{
    Obj  tmp;
    UInt h, i, k, len;

    len = LEN_PLIST(res);
    if (len == 0)
        return res;

    h = 1;
    while (9 * h + 4 < len)
        h = 3 * h + 1;
    while (0 < h) {
        for (i = h + 1; i <= len; i++) {
            tmp = CONST_ADDR_OBJ(res)[i];
            k = i;
            while (h < k && ((Int)tmp < (Int)(CONST_ADDR_OBJ(res)[k - h]))) {
                ADDR_OBJ(res)[k] = CONST_ADDR_OBJ(res)[k - h];
                k -= h;
            }
            ADDR_OBJ(res)[k] = tmp;
        }
        h = h / 3;
    }
    RetypeBag(res, T_PLIST_CYC_SSORT + IMMUTABLE);
    CHANGED_BAG(res);
    return res;
}

static Obj PreImagePPermInt(Obj pt, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i, cpt, deg;

    cpt = INT_INTOBJ(pt);

    if (cpt > (TNUM_OBJ(f) == T_PPERM2 ? CODEG_PPERM2(f) : CODEG_PPERM4(f)))
        return Fail;

    i = 0;

    if (TNUM_OBJ(f) == T_PPERM2) {
        ptf2 = ADDR_PPERM2(f);
        deg = DEG_PPERM2(f);
        while (ptf2[i] != cpt && i < deg)
            i++;
        if (ptf2[i] != cpt)
            return Fail;
    }
    else {
        ptf4 = ADDR_PPERM4(f);
        deg = DEG_PPERM4(f);
        while (ptf4[i] != cpt && i < deg)
            i++;
        if (ptf4[i] != cpt)
            return Fail;
    }
    return INTOBJ_INT(i + 1);
}

/*****************************************************************************
* GAP functions for partial perms
*****************************************************************************/


Obj FuncEmptyPartialPerm(Obj self)
{
    return EmptyPartialPerm;
}

/* method for creating a partial perm */
Obj FuncDensePartialPermNC(Obj self, Obj img)
{
    UInt    deg, i, j, codeg;
    UInt2 * ptf2;
    UInt4 * ptf4;
    Obj     f;

    if (LEN_LIST(img) == 0)
        return EmptyPartialPerm;

    // remove trailing 0s
    deg = LEN_LIST(img);
    while (deg > 0 && INT_INTOBJ(ELM_LIST(img, deg)) == 0)
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
Obj FuncSparsePartialPermNC(Obj self, Obj dom, Obj img)
{
    UInt    rank, deg, i, j, codeg;
    Obj     f;
    UInt2 * ptf2;
    UInt4 * ptf4;

    if (LEN_LIST(dom) == 0)
        return EmptyPartialPerm;

    rank = LEN_LIST(dom);
    deg = INT_INTOBJ(ELM_LIST(dom, rank));

    // find if we are PPERM2 or PPERM4
    codeg = 0;
    i = rank;
    while (codeg < 65536 && i > 0) {
        j = INT_INTOBJ(ELM_LIST(img, i--));
        if (j > codeg)
            codeg = j;
    }

    // make sure we have plain lists
    if (!IS_PLIST(dom))
        PLAIN_LIST(dom);
    if (!IS_PLIST(img))
        PLAIN_LIST(img);

    // make img immutable
    MakeImmutable(img);
    MakeImmutable(dom);

    // create the pperm
    if (codeg < 65536) {
        f = NEW_PPERM2(deg);
        ptf2 = ADDR_PPERM2(f);
        for (i = 1; i <= rank; i++) {
            ptf2[INT_INTOBJ(ELM_PLIST(dom, i)) - 1] =
                INT_INTOBJ(ELM_PLIST(img, i));
        }
        SET_DOM_PPERM(f, dom);
        SET_IMG_PPERM(f, img);
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
        SET_DOM_PPERM(f, dom);
        SET_IMG_PPERM(f, img);
        SET_CODEG_PPERM4(f, codeg);
    }
    CHANGED_BAG(f);
    return f;
}

/* the degree of pperm is the maximum point where it is defined */
Obj FuncDegreeOfPartialPerm(Obj self, Obj f)
{
    if (TNUM_OBJ(f) == T_PPERM2) {
        return INTOBJ_INT(DEG_PPERM2(f));
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        return INTOBJ_INT(DEG_PPERM4(f));
    }
    ErrorQuit("usage: the argument should be a partial perm,", 0L, 0L);
    return Fail;
}

/* the codegree of pperm is the maximum point in its image */

Obj FuncCoDegreeOfPartialPerm(Obj self, Obj f)
{
    if (TNUM_OBJ(f) == T_PPERM2) {
        return INTOBJ_INT(CODEG_PPERM2(f));
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        return INTOBJ_INT(CODEG_PPERM4(f));
    }
    ErrorQuit("usage: the argument should be a partial perm,", 0L, 0L);
    return Fail;
}

/* the rank is the number of points where it is defined */
Obj FuncRankOfPartialPerm(Obj self, Obj f)
{
    if (TNUM_OBJ(f) == T_PPERM2) {
        return INTOBJ_INT(RANK_PPERM2(f));
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        return INTOBJ_INT(RANK_PPERM4(f));
    }
    ErrorQuit("usage: the argument should be a partial perm,", 0L, 0L);
    return Fail;
}

/* domain of a partial perm */
Obj FuncDOMAIN_PPERM(Obj self, Obj f)
{
    if (DOM_PPERM(f) == NULL) {
        if (TNUM_OBJ(f) == T_PPERM2) {
            INIT_PPERM2(f);
        }
        else {
            INIT_PPERM4(f);
        }
    }
    return DOM_PPERM(f);
}

/* image list of pperm */
Obj FuncIMAGE_PPERM(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i, rank;
    Obj     out, dom;
    if (TNUM_OBJ(f) == T_PPERM2) {
        if (IMG_PPERM(f) == NULL) {
            INIT_PPERM2(f);
            return IMG_PPERM(f);
        }
        else if (!IS_SSORT_LIST(IMG_PPERM(f))) {
            return IMG_PPERM(f);
        }
        rank = RANK_PPERM2(f);
        if (rank == 0) {
            out = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
            SET_LEN_PLIST(out, 0);
            return out;
        }
        out = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, rank);
        SET_LEN_PLIST(out, rank);
        ptf2 = ADDR_PPERM2(f);
        dom = DOM_PPERM(f);
        for (i = 1; i <= rank; i++) {
            SET_ELM_PLIST(
                out, i, INTOBJ_INT(ptf2[INT_INTOBJ(ELM_PLIST(dom, i)) - 1]));
        }
    }
    else {
        if (IMG_PPERM(f) == NULL) {
            INIT_PPERM4(f);
            return IMG_PPERM(f);
        }
        else if (!IS_SSORT_LIST(IMG_PPERM(f))) {
            return IMG_PPERM(f);
        }
        rank = RANK_PPERM4(f);
        if (rank == 0) {
            out = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
            SET_LEN_PLIST(out, 0);
            return out;
        }
        out = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, rank);
        SET_LEN_PLIST(out, rank);
        ptf4 = ADDR_PPERM4(f);
        dom = DOM_PPERM(f);
        for (i = 1; i <= rank; i++) {
            SET_ELM_PLIST(
                out, i, INTOBJ_INT(ptf4[INT_INTOBJ(ELM_PLIST(dom, i)) - 1]));
        }
    }
    return out;
}

/* image set of partial perm */
Obj FuncIMAGE_SET_PPERM(Obj self, Obj f)
{
    if (TNUM_OBJ(f) == T_PPERM2) {
        if (IMG_PPERM(f) == NULL) {
            INIT_PPERM2(f);
            return SORT_PLIST_CYC(IMG_PPERM(f));
        }
        else if (!IS_SSORT_LIST(IMG_PPERM(f))) {
            return SORT_PLIST_CYC(IMG_PPERM(f));
        }
        return IMG_PPERM(f);
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        if (IMG_PPERM(f) == NULL) {
            INIT_PPERM4(f);
            return SORT_PLIST_CYC(IMG_PPERM(f));
        }
        else if (!IS_SSORT_LIST(IMG_PPERM(f))) {
            return SORT_PLIST_CYC(IMG_PPERM(f));
        }
        return IMG_PPERM(f);
    }
    else {
        ErrorQuit("usage: the argument must be a partial perm,", 0L, 0L);
    }
    return Fail;
}

/* preimage under a partial perm */
Obj FuncPREIMAGE_PPERM_INT(Obj self, Obj f, Obj pt)
{
    return PreImagePPermInt(pt, f);
}

// find img(f)
static UInt4 * FindImg(UInt n, UInt rank, Obj img)
{
    UInt i;
    UInt4 * ptseen;

    ResizeTmpPPerm(n);
    ptseen = (UInt4 *)(ADDR_OBJ(TmpPPerm));
    memset(ptseen, 0, n * sizeof(UInt4));

    for (i = 1; i <= rank; i++)
        ptseen[INT_INTOBJ(ELM_PLIST(img, i)) - 1] = 1;

    return ptseen;
}

// the least m, r such that f^m=f^m+r
Obj FuncINDEX_PERIOD_PPERM(Obj self, Obj f)
{
    UInt    i, len, j, pow, rank, k, deg, n;
    UInt2 * ptf2;
    UInt4 * ptseen, *ptf4;
    Obj     dom, img, ord, out;

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
                ptseen = (UInt4 *)(ADDR_OBJ(TmpPPerm));
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
                ptseen = (UInt4 *)(ADDR_OBJ(TmpPPerm));
            }
        }
    }
    out = NEW_PLIST(T_PLIST_CYC, 2);
    SET_LEN_PLIST(out, 2);
    SET_ELM_PLIST(out, 1, INTOBJ_INT(pow + 1));
    SET_ELM_PLIST(out, 2, ord);
    return out;
}

// the least power of <f> which is an idempotent
Obj FuncSMALLEST_IDEM_POW_PPERM(Obj self, Obj f)
{
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
Obj FuncCOMPONENT_REPS_PPERM(Obj self, Obj f)
{
    UInt    i, j, rank, k, deg, nr, n;
    UInt2 * ptf2;
    UInt4 * ptseen, *ptf4;
    Obj     dom, img, out;

    n = MAX(DEG_PPERM(f), CODEG_PPERM(f));

    if (n == 0) {
        out = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(out, 0);
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
Obj FuncNR_COMPONENTS_PPERM(Obj self, Obj f)
{
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
                ptseen[k - 1] = 2;    // JDM really required?
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
                ptseen[k - 1] = 2;    // REALLY REQUIRED?? JDM
            }
        }

        // find cycles
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (ptseen[j] == 1) {
                nr++;
                ptseen[j] = 0;    // REALLY REQUIRED??? JDM
                for (k = ptf4[j]; k != j + 1; k = ptf4[k - 1])
                    ptseen[k - 1] = 0;
            }
        }
    }
    return INTOBJ_INT(nr);
}

/* the components of a partial perm (as a functional digraph) */
Obj FuncCOMPONENTS_PPERM(Obj self, Obj f)
{
    UInt    i, j, n, rank, k, deg, nr, len;
    Obj     dom, img, out;

    n = MAX(DEG_PPERM(f), CODEG_PPERM(f));

    if (n == 0) {
        out = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(out, 0);
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
            if (((const UInt4 *)(CONST_ADDR_OBJ(TmpPPerm)))[j - 1] == 0) {
                SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC, 30));
                CHANGED_BAG(out);
                len = 0;
                k = j;
                do {
                    AssPlist(ELM_PLIST(out, nr), ++len, INTOBJ_INT(k));
                    ((UInt4 *)(ADDR_OBJ(TmpPPerm)))[k - 1] = 2;
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
            if (((const UInt4 *)(CONST_ADDR_OBJ(TmpPPerm)))[j - 1] == 1) {
                SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC, 30));
                CHANGED_BAG(out);
                len = 0;
                k = j;
                do {
                    AssPlist(ELM_PLIST(out, nr), ++len, INTOBJ_INT(k));
                    ((UInt4 *)(ADDR_OBJ(TmpPPerm)))[k - 1] = 0;
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
            if (((const UInt4 *)(CONST_ADDR_OBJ(TmpPPerm)))[j - 1] == 0) {
                SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC, 30));
                CHANGED_BAG(out);
                len = 0;
                k = j;
                do {
                    AssPlist(ELM_PLIST(out, nr), ++len, INTOBJ_INT(k));
                    ((UInt4 *)(ADDR_OBJ(TmpPPerm)))[k - 1] = 2;
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
            if (((const UInt4 *)(CONST_ADDR_OBJ(TmpPPerm)))[j - 1] == 1) {
                SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC, 30));
                CHANGED_BAG(out);
                len = 0;
                k = j;
                do {
                    AssPlist(ELM_PLIST(out, nr), ++len, INTOBJ_INT(k));
                    ((UInt4 *)(ADDR_OBJ(TmpPPerm)))[k - 1] = 0;
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
Obj FuncCOMPONENT_PPERM_INT(Obj self, Obj f, Obj pt)
{
    UInt i, j, deg, len;
    Obj  out;

    i = INT_INTOBJ(pt);

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = DEG_PPERM2(f);

        if (i > deg || (ADDR_PPERM2(f))[i - 1] == 0) {
            out = NEW_PLIST(T_PLIST_EMPTY, 0);
            SET_LEN_PLIST(out, 0);
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
            out = NEW_PLIST(T_PLIST_EMPTY, 0);
            SET_LEN_PLIST(out, 0);
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
Obj FuncFIXED_PTS_PPERM(Obj self, Obj f)
{
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

Obj FuncNR_FIXED_PTS_PPERM(Obj self, Obj f)
{
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
Obj FuncMOVED_PTS_PPERM(Obj self, Obj f)
{
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

Obj FuncNR_MOVED_PTS_PPERM(Obj self, Obj f)
{
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

Obj FuncLARGEST_MOVED_PT_PPERM(Obj self, Obj f)
{
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

Obj FuncSMALLEST_MOVED_PT_PPERM(Obj self, Obj f)
{
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
Obj FuncTRIM_PPERM(Obj self, Obj f)
{
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

Obj FuncHASH_FUNC_FOR_PPERM(Obj self, Obj f, Obj data) {
    return INTOBJ_INT(HashFuncForPPerm(f) % INT_INTOBJ(data) + 1);
}

// test if a partial perm is an idempotent
Obj FuncIS_IDEM_PPERM(Obj self, Obj f)
{
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
Obj FuncLEFT_ONE_PPERM(Obj self, Obj f)
{
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
Obj FuncRIGHT_ONE_PPERM(Obj self, Obj f)
{
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
Obj FuncNaturalLeqPartialPerm(Obj self, Obj f, Obj g)
{
    UInt   def, deg, i, j, rank;
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4;
    Obj    dom;

    if (TNUM_OBJ(f) == T_PPERM2) {
        def = DEG_PPERM2(f);
        ptf2 = ADDR_PPERM2(f);
        if (def == 0)
            return True;

        if (TNUM_OBJ(g) == T_PPERM2) {
            deg = DEG_PPERM2(g);
            ptg2 = ADDR_PPERM2(g);
            if (DOM_PPERM(f) == NULL) {
                for (i = 0; i < def; i++) {
                    if (ptf2[i] != 0 && ptf2[i] != IMAGEPP(i + 1, ptg2, deg))
                        return False;
                }
            }
            else {
                dom = DOM_PPERM(f);
                rank = RANK_PPERM2(f);
                for (i = 1; i <= rank; i++) {
                    j = INT_INTOBJ(ELM_PLIST(dom, i));
                    if (ptf2[j - 1] != IMAGEPP(j, ptg2, deg))
                        return False;
                }
            }
        }
        else if (TNUM_OBJ(g) == T_PPERM4) {
            deg = DEG_PPERM4(g);
            ptg4 = ADDR_PPERM4(g);
            if (DOM_PPERM(f) == NULL) {
                for (i = 0; i < def; i++) {
                    if (ptf2[i] != 0 && ptf2[i] != IMAGEPP(i + 1, ptg4, deg))
                        return False;
                }
            }
            else {
                dom = DOM_PPERM(f);
                rank = RANK_PPERM2(f);
                for (i = 1; i <= rank; i++) {
                    j = INT_INTOBJ(ELM_PLIST(dom, i));
                    if (ptf2[j - 1] != IMAGEPP(j, ptg4, deg))
                        return False;
                }
            }
        }
        else {
            ErrorQuit("usage: the arguments must be partial perms,", 0L, 0L);
        }
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        def = DEG_PPERM4(f);
        ptf4 = ADDR_PPERM4(f);
        if (def == 0)
            return True;

        if (TNUM_OBJ(g) == T_PPERM2) {
            deg = DEG_PPERM2(g);
            ptg2 = ADDR_PPERM2(g);
            if (DOM_PPERM(f) == NULL) {
                for (i = 0; i < def; i++) {
                    if (ptf4[i] != 0 && ptf4[i] != IMAGEPP(i + 1, ptg2, deg))
                        return False;
                }
            }
            else {
                dom = DOM_PPERM(f);
                rank = RANK_PPERM4(f);
                for (i = 1; i <= rank; i++) {
                    j = INT_INTOBJ(ELM_PLIST(dom, i));
                    if (ptf4[j - 1] != IMAGEPP(j, ptg2, deg))
                        return False;
                }
            }
        }
        else if (TNUM_OBJ(g) == T_PPERM4) {
            deg = DEG_PPERM4(g);
            ptg4 = ADDR_PPERM4(g);
            if (DOM_PPERM(f) == NULL) {
                for (i = 0; i < def; i++) {
                    if (ptf4[i] != 0 && ptf4[i] != IMAGEPP(i + 1, ptg4, deg))
                        return False;
                }
            }
            else {
                dom = DOM_PPERM(f);
                rank = RANK_PPERM4(f);
                for (i = 1; i <= rank; i++) {
                    j = INT_INTOBJ(ELM_PLIST(dom, i));
                    if (ptf4[j - 1] != IMAGEPP(j, ptg4, deg))
                        return False;
                }
            }
        }
        else {
            ErrorQuit("usage: the arguments must be partial perms,", 0L, 0L);
        }
    }
    else {
        ErrorQuit("usage: the arguments must be partial perms,", 0L, 0L);
    }
    return True;
}

// could add use of rank to improve things here. JDM
Obj FuncJOIN_IDEM_PPERMS(Obj self, Obj f, Obj g)
{
    UInt   def, deg, dej, i;
    Obj    join;
    UInt2 *ptjoin2, *ptf2, *ptg2;
    UInt4 *ptjoin4, *ptf4, *ptg4;

    if (EQ(f, g))
        return f;

    def = DEG_PPERM(f);
    deg = DEG_PPERM(g);
    dej = MAX(def, deg);
    if (dej < 65536) {
        join = NEW_PPERM2(dej);
        SET_CODEG_PPERM2(join, dej);
        ptjoin2 = ADDR_PPERM2(join);
        ptf2 = ADDR_PPERM2(f);
        ptg2 = ADDR_PPERM2(g);
        if (def < deg) {
            for (i = 0; i < def; i++) {
                if (ptf2[i] != 0) {
                    ptjoin2[i] = ptf2[i];
                }
                else if (ptg2[i] != 0) {
                    ptjoin2[i] = ptg2[i];
                }
            }
            for (; i < deg; i++) {
                if (ptg2[i] != 0)
                    ptjoin2[i] = ptg2[i];
            }
        }
        else {
            for (i = 0; i < deg; i++) {
                if (ptg2[i] != 0) {
                    ptjoin2[i] = ptg2[i];
                }
                else if (ptf2[i] != 0) {
                    ptjoin2[i] = ptf2[i];
                }
            }
            for (; i < def; i++) {
                if (ptf2[i] != 0)
                    ptjoin2[i] = ptf2[i];
            }
        }
    }
    else if (def >= 65536 && deg >= 65536) {    // 3 more cases required
        join = NEW_PPERM4(dej);
        SET_CODEG_PPERM4(join, dej);
        ptjoin4 = ADDR_PPERM4(join);
        ptf4 = ADDR_PPERM4(f);
        ptg4 = ADDR_PPERM4(g);
        if (def < deg) {
            for (i = 0; i < def; i++) {
                if (ptf4[i] != 0) {
                    ptjoin4[i] = ptf4[i];
                }
                else if (ptg4[i] != 0) {
                    ptjoin4[i] = ptg4[i];
                }
            }
            for (; i < deg; i++) {
                if (ptg4[i] != 0)
                    ptjoin4[i] = ptg4[i];
            }
        }
        else {
            for (i = 0; i < deg; i++) {
                if (ptg4[i] != 0) {
                    ptjoin4[i] = ptg4[i];
                }
                else if (ptf4[i] != 0) {
                    ptjoin4[i] = ptf4[i];
                }
            }
            for (; i < def; i++) {
                if (ptf4[i] != 0)
                    ptjoin4[i] = ptf4[i];
            }
        }
    }
    else if (def > deg) {    // def>=65536>deg
        join = NEW_PPERM4(dej);
        SET_CODEG_PPERM4(join, dej);
        ptjoin4 = ADDR_PPERM4(join);
        ptf4 = ADDR_PPERM4(f);
        ptg2 = ADDR_PPERM2(g);
        for (i = 0; i < deg; i++) {
            if (ptg2[i] != 0) {
                ptjoin4[i] = ptg2[i];
            }
            else if (ptf4[i] != 0) {
                ptjoin4[i] = ptf4[i];
            }
        }
        for (; i < def; i++) {
            if (ptf4[i] != 0)
                ptjoin4[i] = ptf4[i];
        }
    }
    else {
        return FuncJOIN_IDEM_PPERMS(self, g, f);
    }
    return join;
}

// the union of f and g where this defines an injective function
Obj FuncJOIN_PPERMS(Obj self, Obj f, Obj g)
{
    UInt   deg, i, j, degf, degg, codeg, rank;
    UInt2 *ptf2, *ptg2, *ptjoin2;
    UInt4 *ptf4, *ptg4, *ptjoin4, *ptseen;
    Obj    join, dom;

    if (EQ(f, g))
        return f;

    // init the buffer
    codeg = MAX(CODEG_PPERM(f), CODEG_PPERM(g));
    ResizeTmpPPerm(codeg);
    ptseen = (UInt4 *)(ADDR_OBJ(TmpPPerm));
    for (i = 0; i < codeg; i++)
        ptseen[i] = 0;

    if (TNUM_OBJ(f) == T_PPERM4 && TNUM_OBJ(g) == T_PPERM4) {
        degf = DEG_PPERM4(f);
        degg = DEG_PPERM4(g);
        deg = MAX(degf, degg);
        join = NEW_PPERM4(deg);
        SET_CODEG_PPERM4(join, codeg);

        ptjoin4 = ADDR_PPERM4(join);
        ptf4 = ADDR_PPERM4(f);
        ptg4 = ADDR_PPERM4(g);
        ptseen = (UInt4 *)(ADDR_OBJ(TmpPPerm));

        if (DOM_PPERM(f) != NULL) {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptjoin4[j] = ptf4[j];
                ptseen[ptf4[j] - 1] = 1;
            }
        }

        if (DOM_PPERM(g) != NULL) {
            dom = DOM_PPERM(g);
            rank = RANK_PPERM4(g);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptjoin4[j] == 0) {
                    if (ptseen[ptg4[j] - 1] == 0) {
                        ptjoin4[j] = ptg4[j];
                        ptseen[ptg4[j] - 1] = 1;
                    }
                    else {
                        return Fail;    // join is not injective
                    }
                }
                else if (ptjoin4[j] != ptg4[j]) {
                    return Fail;
                }
            }
        }

        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < degf; i++) {
                if (ptf4[i] != 0) {
                    if (ptjoin4[i] == 0) {
                        if (ptseen[ptf4[i] - 1] == 0) {
                            ptjoin4[i] = ptf4[i];
                            ptseen[ptf4[i] - 1] = 1;
                        }
                        else {
                            return Fail;
                        }
                    }
                    else if (ptjoin4[i] != ptf4[i]) {
                        return Fail;
                    }
                }
            }
        }

        if (DOM_PPERM(g) == NULL) {
            for (i = 0; i < degg; i++) {
                if (ptg4[i] != 0) {
                    if (ptjoin4[i] == 0) {
                        if (ptseen[ptg4[i] - 1] == 0) {
                            ptjoin4[i] = ptg4[i];
                            ptseen[ptg4[i] - 1] = 1;
                        }
                        else {
                            return Fail;
                        }
                    }
                    else if (ptjoin4[i] != ptg4[i]) {
                        return Fail;
                    }
                }
            }
        }
    }
    else if (TNUM_OBJ(f) == T_PPERM4 && TNUM_OBJ(g) == T_PPERM2) {
        degf = DEG_PPERM4(f);
        degg = DEG_PPERM2(g);
        deg = MAX(degf, degg);
        join = NEW_PPERM4(deg);
        SET_CODEG_PPERM4(join, codeg);

        ptjoin4 = ADDR_PPERM4(join);
        ptf4 = ADDR_PPERM4(f);
        ptg2 = ADDR_PPERM2(g);
        ptseen = (UInt4 *)(ADDR_OBJ(TmpPPerm));

        if (DOM_PPERM(f) != NULL) {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptjoin4[j] = ptf4[j];
                ptseen[ptf4[j] - 1] = 1;
            }
        }

        if (DOM_PPERM(g) != NULL) {
            dom = DOM_PPERM(g);
            rank = RANK_PPERM2(g);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptjoin4[j] == 0) {
                    if (ptseen[ptg2[j] - 1] == 0) {
                        ptjoin4[j] = ptg2[j];
                        ptseen[ptg2[j] - 1] = 1;
                    }
                    else {
                        return Fail;    // join is not injective
                    }
                }
                else if (ptjoin4[j] != ptg2[j]) {
                    return Fail;
                }
            }
        }

        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < degf; i++) {
                if (ptf4[i] != 0) {
                    if (ptjoin4[i] == 0) {
                        if (ptseen[ptf4[i] - 1] == 0) {
                            ptjoin4[i] = ptf4[i];
                            ptseen[ptf4[i] - 1] = 1;
                        }
                        else {
                            return Fail;
                        }
                    }
                    else if (ptjoin4[i] != ptf4[i]) {
                        return Fail;
                    }
                }
            }
        }

        if (DOM_PPERM(g) == NULL) {
            for (i = 0; i < degg; i++) {
                if (ptg2[i] != 0) {
                    if (ptjoin4[i] == 0) {
                        if (ptseen[ptg2[i] - 1] == 0) {
                            ptjoin4[i] = ptg2[i];
                            ptseen[ptg2[i] - 1] = 1;
                        }
                        else {
                            return Fail;
                        }
                    }
                    else if (ptjoin4[i] != ptg2[i]) {
                        return Fail;
                    }
                }
            }
        }
    }
    else if (TNUM_OBJ(f) == T_PPERM2 && TNUM_OBJ(g) == T_PPERM4) {
        return FuncJOIN_PPERMS(self, g, f);
    }
    else {
        degf = DEG_PPERM2(f);
        degg = DEG_PPERM2(g);
        deg = MAX(degf, degg);
        join = NEW_PPERM2(deg);
        SET_CODEG_PPERM2(join, codeg);

        ptjoin2 = ADDR_PPERM2(join);
        ptf2 = ADDR_PPERM2(f);
        ptg2 = ADDR_PPERM2(g);
        ptseen = (UInt4 *)(ADDR_OBJ(TmpPPerm));

        if (DOM_PPERM(f) != NULL) {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptjoin2[j] = ptf2[j];
                ptseen[ptf2[j] - 1] = 1;
            }
        }

        if (DOM_PPERM(g) != NULL) {
            dom = DOM_PPERM(g);
            rank = RANK_PPERM2(g);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                if (ptjoin2[j] == 0) {
                    if (ptseen[ptg2[j] - 1] == 0) {
                        ptjoin2[j] = ptg2[j];
                        ptseen[ptg2[j] - 1] = 1;
                    }
                    else {
                        return Fail;    // join is not injective
                    }
                }
                else if (ptjoin2[j] != ptg2[j]) {
                    return Fail;
                }
            }
        }

        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < degf; i++) {
                if (ptf2[i] != 0) {
                    if (ptjoin2[i] == 0) {
                        if (ptseen[ptf2[i] - 1] == 0) {
                            ptjoin2[i] = ptf2[i];
                            ptseen[ptf2[i] - 1] = 1;
                        }
                        else {
                            return Fail;
                        }
                    }
                    else if (ptjoin2[i] != ptf2[i]) {
                        return Fail;
                    }
                }
            }
        }

        if (DOM_PPERM(g) == NULL) {
            for (i = 0; i < degg; i++) {
                if (ptg2[i] != 0) {
                    if (ptjoin2[i] == 0) {
                        if (ptseen[ptg2[i] - 1] == 0) {
                            ptjoin2[i] = ptg2[i];
                            ptseen[ptg2[i] - 1] = 1;
                        }
                        else {
                            return Fail;
                        }
                    }
                    else if (ptjoin2[i] != ptg2[i]) {
                        return Fail;
                    }
                }
            }
        }
    }
    return join;
}

Obj FuncMEET_PPERMS(Obj self, Obj f, Obj g)
{
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
Obj FuncRESTRICTED_PPERM(Obj self, Obj f, Obj set)
{
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
// be
// a set of positive integers
Obj FuncAS_PPERM_PERM(Obj self, Obj p, Obj set)
{
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
                // Pr("Case 1\n", 0L, 0L);
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
                // Pr("Case 2\n", 0L, 0L);
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
            // Pr("Case 3\n", 0L, 0L);
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
            // Pr("Case 4\n", 0L, 0L);
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

                // Pr("Case 5\n", 0L, 0L);
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
                // Pr("Case 6\n", 0L, 0L);
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
Obj FuncAS_PERM_PPERM(Obj self, Obj f)
{
    UInt2 *ptf2, *ptp2;
    UInt4 *ptf4, *ptp4;
    UInt   deg, i, j, rank;
    Obj    p, dom;

    if (TNUM_OBJ(f) == T_PPERM2) {
        if (!EQ(FuncIMAGE_SET_PPERM(self, f), DOM_PPERM(f))) {
            return Fail;
        }
        deg = DEG_PPERM2(f);
        p = NEW_PERM2(deg);
        dom = DOM_PPERM(f);
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
        if (!EQ(FuncIMAGE_SET_PPERM(self, f), DOM_PPERM(f))) {
            return Fail;
        }
        deg = DEG_PPERM4(f);
        p = NEW_PERM4(deg);
        dom = DOM_PPERM(f);
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
Obj FuncPERM_LEFT_QUO_PPERM_NC(Obj self, Obj f, Obj g)
{
    UInt   deg, i, j, rank;
    Obj    perm, dom;
    UInt2 *ptf2, *ptp2, *ptg2;
    UInt4 *ptf4, *ptp4, *ptg4;

    if (TNUM_OBJ(f) == T_PPERM2) {
        deg = CODEG_PPERM2(f);
        perm = NEW_PERM2(deg);
        ptp2 = ADDR_PERM2(perm);
        for (i = 0; i < deg; i++)
            ptp2[i] = i;
        rank = RANK_PPERM2(f);
        dom = DOM_PPERM(f);
        // renew pointers since RANK_PPERM can trigger garbage collection
        ptp2 = ADDR_PERM2(perm);
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
        perm = NEW_PERM4(deg);
        ptp4 = ADDR_PERM4(perm);
        for (i = 0; i < deg; i++)
            ptp4[i] = i;
        rank = RANK_PPERM4(f);
        dom = DOM_PPERM(f);
        // renew pointers since RANK_PPERM can trigger garbage collection
        ptp4 = ADDR_PERM4(perm);
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

Obj FuncShortLexLeqPartialPerm(Obj self, Obj f, Obj g)
{
    UInt   rankf, rankg, i, j, k;
    Obj    domf, domg;
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4;

    if (!IS_PPERM(f) || !IS_PPERM(g)) {
        ErrorQuit("usage: the arguments must be partial perms,", 0L, 0L);
    }

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
        domg = DOM_PPERM(f);
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

Obj FuncHAS_DOM_PPERM(Obj self, Obj f)
{
    if (TNUM_OBJ(f) == T_PPERM2) {
        return (DOM_PPERM(f) == NULL ? False : True);
    }
    else if (TNUM_OBJ(f) == T_PPERM4) {
        return (DOM_PPERM(f) == NULL ? False : True);
    }
    return Fail;
}

Obj FuncHAS_IMG_PPERM(Obj self, Obj f)
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
Obj OnePPerm(Obj f)
{
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
Int EqPPerm22(Obj f, Obj g)
{
    UInt2 * ptf = ADDR_PPERM2(f);
    UInt2 * ptg = ADDR_PPERM2(g);
    UInt    deg = DEG_PPERM2(f);
    UInt    i, j, rank;
    Obj     dom;

    if (deg != DEG_PPERM2(g) || CODEG_PPERM2(f) != CODEG_PPERM2(g))
        return 0L;

    if (DOM_PPERM(f) == NULL || DOM_PPERM(g) == NULL) {
        for (i = 0; i < deg; i++)
            if (*ptf++ != *ptg++)
                return 0L;
        return 1L;
    }

    if (RANK_PPERM2(f) != RANK_PPERM2(g))
        return 0L;
    dom = DOM_PPERM(f);
    rank = RANK_PPERM2(f);

    for (i = 1; i <= rank; i++) {
        j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
        if (ptf[j] != ptg[j]) {
            return 0L;
        }
    }
    return 1L;
}

Int EqPPerm24(Obj f, Obj g)
{
    UInt2 * ptf = ADDR_PPERM2(f);
    UInt4 * ptg = ADDR_PPERM4(g);
    UInt    deg = DEG_PPERM2(f);
    UInt    i, j, rank;
    Obj     dom;

    if (deg != DEG_PPERM4(g) || CODEG_PPERM2(f) != CODEG_PPERM4(g))
        return 0L;

    if (DOM_PPERM(f) == NULL || DOM_PPERM(g) == NULL) {
        for (i = 0; i < deg; i++)
            if (*(ptf++) != *(ptg++))
                return 0L;
        return 1L;
    }

    if (RANK_PPERM2(f) != RANK_PPERM4(g))
        return 0L;
    dom = DOM_PPERM(f);
    rank = RANK_PPERM2(f);

    for (i = 1; i <= rank; i++) {
        j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
        if (ptf[j] != ptg[j])
            return 0L;
    }
    return 1L;
}

Int EqPPerm42(Obj f, Obj g)
{
    return EqPPerm24(g, f);
}

Int EqPPerm44(Obj f, Obj g)
{
    UInt4 * ptf = ADDR_PPERM4(f);
    UInt4 * ptg = ADDR_PPERM4(g);
    UInt    i, j, rank;
    UInt    deg = DEG_PPERM4(f);
    Obj     dom;

    if (deg != DEG_PPERM4(g) || CODEG_PPERM4(f) != CODEG_PPERM4(g))
        return 0L;

    if (DOM_PPERM(f) == NULL || DOM_PPERM(g) == NULL) {
        for (i = 0; i < deg; i++)
            if (*(ptf++) != *(ptg++))
                return 0L;
        return 1L;
    }

    if (RANK_PPERM4(f) != RANK_PPERM4(g))
        return 0L;
    dom = DOM_PPERM(f);
    rank = RANK_PPERM4(f);

    for (i = 1; i <= rank; i++) {
        j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
        if (ptf[j] != ptg[j])
            return 0L;
    }
    return 1L;
}

/* less than for partial perms */
// beware this is different than it used to be...
Int LtPPerm22(Obj f, Obj g)
{
    UInt2 * ptf = ADDR_PPERM2(f);
    UInt2 * ptg = ADDR_PPERM2(g);
    UInt    deg, i;

    deg = DEG_PPERM2(f);
    if (deg != DEG_PPERM2(g)) {
        if (deg < DEG_PPERM2(g)) {
            return 1L;
        }
        else {
            return 0L;
        }
    }

    for (i = 0; i < deg; i++) {
        if (*(ptf++) != *(ptg++)) {
            if (*(--ptf) < *(--ptg))
                return 1L;
            else
                return 0L;
        }
    }
    return 0L;
}

Int LtPPerm24(Obj f, Obj g)
{
    UInt2 * ptf = ADDR_PPERM2(f);
    UInt4 * ptg = ADDR_PPERM4(g);
    UInt    deg, i;

    deg = DEG_PPERM2(f);
    if (deg != DEG_PPERM4(g)) {
        if (deg < DEG_PPERM4(g)) {
            return 1L;
        }
        else {
            return 0L;
        }
    }

    for (i = 0; i < deg; i++) {
        if (*(ptf++) != *(ptg++)) {
            if (*(--ptf) < *(--ptg))
                return 1L;
            else
                return 0L;
        }
    }
    return 0L;
}

Int LtPPerm42(Obj f, Obj g)
{
    UInt4 * ptf = ADDR_PPERM4(f);
    UInt2 * ptg = ADDR_PPERM2(g);
    UInt    deg, i;

    deg = DEG_PPERM4(f);
    if (deg != DEG_PPERM2(g)) {
        if (deg < DEG_PPERM2(g)) {
            return 1L;
        }
        else {
            return 0L;
        }
    }

    for (i = 0; i < deg; i++) {
        if (*(ptf++) != *(ptg++)) {
            if (*(--ptf) < *(--ptg))
                return 1L;
            else
                return 0L;
        }
    }
    return 0L;
}

Int LtPPerm44(Obj f, Obj g)
{
    UInt4 * ptf = ADDR_PPERM4(f);
    UInt4 * ptg = ADDR_PPERM4(g);
    UInt    deg, i;

    deg = DEG_PPERM4(f);
    if (deg != DEG_PPERM4(g)) {
        if (deg < DEG_PPERM4(g)) {
            return 1L;
        }
        else {
            return 0L;
        }
    }

    for (i = 0; i < deg; i++) {
        if (*(ptf++) != *(ptg++)) {
            if (*(--ptf) < *(--ptg))
                return 1L;
            else
                return 0L;
        }
    }
    return 0L;
}

/* product of partial perm and partial perm */
Obj ProdPPerm22(Obj f, Obj g)
{
    UInt   deg, degg, i, j, rank;
    UInt2 *ptf, *ptg, *ptfg, codeg;
    Obj    fg, dom;

    if (DEG_PPERM2(g) == 0)
        return EmptyPartialPerm;

    // find the degree
    deg = DEG_PPERM2(f);
    degg = DEG_PPERM2(g);
    ptf = ADDR_PPERM2(f);
    ptg = ADDR_PPERM2(g);
    while (deg > 0 &&
           (ptf[deg - 1] == 0 || IMAGEPP(ptf[deg - 1], ptg, degg) == 0))
        deg--;
    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    fg = NEW_PPERM2(deg);
    ptfg = ADDR_PPERM2(fg);
    ptf = ADDR_PPERM2(f);
    ptg = ADDR_PPERM2(g);
    codeg = 0;

    // compose in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM2(f);
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
            // JDM could have additional case so that we don't have to check
            // ptf[i]<=degg
            if (ptf[i] != 0 && ptf[i] <= degg) {
                ptfg[i] = ptg[ptf[i] - 1];
                if (ptfg[i] > codeg)
                    codeg = ptfg[i];
            }
        }
    }
    SET_CODEG_PPERM2(fg, codeg);
    return fg;
}

// the product is always pperm2
Obj ProdPPerm42(Obj f, Obj g)
{
    UInt    deg, degg, i, j, rank;
    UInt4 * ptf;
    UInt2 * ptg, *ptfg, codeg;
    Obj     fg, dom;

    if (DEG_PPERM2(g) == 0)
        return EmptyPartialPerm;

    // find the degree
    deg = DEG_PPERM4(f);
    degg = DEG_PPERM2(g);
    ptf = ADDR_PPERM4(f);
    ptg = ADDR_PPERM2(g);
    while (deg > 0 && (ptf[deg - 1] == 0 || ptf[deg - 1] > degg ||
                       ptg[ptf[deg - 1] - 1] == 0))
        deg--;
    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    fg = NEW_PPERM2(deg);
    ptfg = ADDR_PPERM2(fg);
    ptf = ADDR_PPERM4(f);
    ptg = ADDR_PPERM2(g);
    codeg = 0;

    // compose in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM4(f);
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
    SET_CODEG_PPERM2(fg, codeg);
    return fg;
}

// it is possible that f*g could be represented as a PPERM2
Obj ProdPPerm44(Obj f, Obj g)
{
    UInt   deg, degg, codeg, i, j, rank;
    UInt4 *ptf, *ptg, *ptfg;
    Obj    fg, dom;

    if (DEG_PPERM4(g) == 0) {
        return EmptyPartialPerm;
    }

    // find the degree
    deg = DEG_PPERM4(f);
    degg = DEG_PPERM4(g);
    ptf = ADDR_PPERM4(f);
    ptg = ADDR_PPERM4(g);
    while (deg > 0 && (ptf[deg - 1] == 0 || ptf[deg - 1] > degg ||
                       ptg[ptf[deg - 1] - 1] == 0)) {
        deg--;
    }

    if (deg == 0) {
        return EmptyPartialPerm;
    }

    // create new pperm
    fg = NEW_PPERM4(deg);
    ptfg = ADDR_PPERM4(fg);
    ptf = ADDR_PPERM4(f);
    ptg = ADDR_PPERM4(g);
    codeg = 0;

    // compose in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM4(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            if (j < deg && ptf[j] <= degg) {
                ptfg[j] = ptg[ptf[j] - 1];
                if (ptfg[j] > codeg) {
                    codeg = ptfg[j];
                }
            }
        }
    }
    else {
        // compose in deg operations
        for (i = 0; i < deg; i++) {
            if (ptf[i] != 0 && ptf[i] <= degg) {
                ptfg[i] = ptg[ptf[i] - 1];
                if (ptfg[i] > codeg) {
                    codeg = ptfg[i];
                }
            }
        }
    }
    SET_CODEG_PPERM4(fg, codeg);
    return fg;
}

// it is possible that f*g could be represented as a PPERM2
Obj ProdPPerm24(Obj f, Obj g)
{
    UInt    deg, degg, i, j, codeg, rank;
    UInt2 * ptf;
    UInt4 * ptg, *ptfg;
    Obj     fg, dom;

    if (DEG_PPERM4(g) == 0)
        return EmptyPartialPerm;

    // find the degree
    deg = DEG_PPERM2(f);
    degg = DEG_PPERM4(g);
    ptf = ADDR_PPERM2(f);
    ptg = ADDR_PPERM4(g);

    if (CODEG_PPERM2(f) <= degg) {
        while (deg > 0 && (ptf[deg - 1] == 0 || ptg[ptf[deg - 1] - 1] == 0))
            deg--;
    }
    else {
        while (deg > 0 &&
               (ptf[deg - 1] == 0 || IMAGEPP(ptf[deg - 1], ptg, degg) == 0))
            deg--;
    }

    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    fg = NEW_PPERM4(deg);
    ptfg = ADDR_PPERM4(fg);
    ptf = ADDR_PPERM2(f);
    ptg = ADDR_PPERM4(g);
    codeg = 0;

    // compose in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM2(f);
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
    SET_CODEG_PPERM4(fg, codeg);
    return fg;
}

// compose partial perms and perms
Obj ProdPPerm2Perm2(Obj f, Obj p)
{
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
                // Pr("Case 2\n", 0L, 0L);
                for (i = 0; i < deg; i++) {
                    if (ptf[i] != 0) {
                        ptfp2[i] = ptp[ptf[i] - 1] + 1;
                        if (ptfp2[i] > codeg)
                            codeg = ptfp2[i];
                    }
                }
            }
            else {
                // Pr("Case 1\n", 0L, 0L);
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
                // Pr("Case 4\n", 0L, 0L);
                for (i = 0; i < deg; i++) {
                    if (ptf[i] != 0) {
                        ptfp2[i] = IMAGE(ptf[i] - 1, ptp, dep) + 1;
                    }
                }
            }
            else {
                // Pr("Case 3\n", 0L, 0L);
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
            // Pr("Case 6\n", 0L, 0L);
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptfp4[i] = ptp[ptf[i] - 1] + 1;
                    if (ptfp4[i] > codeg)
                        codeg = ptfp4[i];
                }
            }
        }
        else {
            // Pr("Case 5\n", 0L, 0L);
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

Obj ProdPPerm4Perm4(Obj f, Obj p)
{
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
            // Pr("case 1\n", 0L, 0L);
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptfp[i] = ptp[ptf[i] - 1] + 1;
                    if (ptfp[i] > codeg)
                        codeg = ptfp[i];
                }
            }
        }
        else {
            // Pr("case 2\n", 0L, 0L);
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
            // Pr("case 3\n", 0L, 0L);
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptfp[i] = IMAGE(ptf[i] - 1, ptp, dep) + 1;
                }
            }
        }
        else {
            // Pr("case 4\n", 0L, 0L);
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

Obj ProdPPerm2Perm4(Obj f, Obj p)
{
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

Obj ProdPPerm4Perm2(Obj f, Obj p)
{
    UInt4 *ptf, *ptfp;
    UInt2 *ptp, dep;
    Obj    fp, dom;
    UInt   codeg, deg, i, j, rank;

    deg = DEG_PPERM4(f);
    fp = NEW_PPERM4(deg);

    dep = DEG_PERM2(p);
    codeg = CODEG_PPERM4(f);

    ptf = ADDR_PPERM4(f);
    ptp = ADDR_PERM2(p);
    ptfp = ADDR_PPERM4(fp);

    if (DOM_PPERM(f) == NULL) {
        // Pr("case 1\n", 0L, 0L);
        for (i = 0; i < deg; i++) {
            if (ptf[i] != 0) {
                ptfp[i] = IMAGE(ptf[i] - 1, ptp, dep) + 1;
            }
        }
    }
    else {
        // Pr("case 2\n", 0L, 0L);
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
Obj ProdPerm2PPerm2(Obj p, Obj f)
{
    UInt2 deg, *ptp, *ptf, *ptpf;
    UInt  degf, i;
    Obj   pf;

    if (DEG_PPERM2(f) == 0)
        return EmptyPartialPerm;

    deg = DEG_PERM2(p);
    degf = DEG_PPERM2(f);

    if (deg < degf) {
        // Pr("case 1\n", 0L, 0L);
        pf = NEW_PPERM2(degf);
        ptpf = ADDR_PPERM2(pf);
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM2(f);
        for (i = 0; i < deg; i++)
            *ptpf++ = ptf[*ptp++];
        for (; i < degf; i++)
            *ptpf++ = ptf[i];
    }
    else {    // deg(f)<=deg(p)
        // Pr("case 2\n", 0L, 0L);
        // find the degree
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM2(f);
        while (ptp[deg - 1] >= degf || ptf[ptp[deg - 1]] == 0)
            deg--;
        pf = NEW_PPERM2(deg);
        ptpf = ADDR_PPERM2(pf);
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM2(f);
        for (i = 0; i < deg; i++)
            if (ptp[i] < degf)
                ptpf[i] = ptf[ptp[i]];
    }
    SET_CODEG_PPERM2(pf, CODEG_PPERM2(f));
    return pf;
}

Obj ProdPerm4PPerm4(Obj p, Obj f)
{
    UInt4 deg, *ptp, *ptf, *ptpf;
    UInt  degf, i;
    Obj   pf;

    if (DEG_PPERM4(f) == 0)
        return EmptyPartialPerm;

    deg = DEG_PERM4(p);
    degf = DEG_PPERM4(f);

    if (deg < degf) {
        // Pr("case 1\n", 0L, 0L);
        pf = NEW_PPERM4(degf);
        ptpf = ADDR_PPERM4(pf);
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM4(f);
        for (i = 0; i < deg; i++)
            *ptpf++ = ptf[*ptp++];
        for (; i < degf; i++)
            *ptpf++ = ptf[i];
    }
    else {    // deg(f)<deg(p)
        // Pr("case 2\n", 0L, 0L);
        // fin the degree
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM4(f);
        while (ptp[deg - 1] >= degf || ptf[ptp[deg - 1]] == 0)
            deg--;
        pf = NEW_PPERM4(deg);
        ptpf = ADDR_PPERM4(pf);
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM4(f);
        for (i = 0; i < deg; i++)
            if (ptp[i] < degf)
                ptpf[i] = ptf[ptp[i]];
    }
    SET_CODEG_PPERM4(pf, CODEG_PPERM4(f));
    return pf;
}

Obj ProdPerm4PPerm2(Obj p, Obj f)
{
    UInt4  deg, *ptp;
    UInt2 *ptf, *ptpf;
    UInt   degf, i;
    Obj    pf;

    if (DEG_PPERM2(f) == 0)
        return EmptyPartialPerm;

    deg = DEG_PERM4(p);
    degf = DEG_PPERM2(f);
    if (deg < degf) {
        // Pr("case 1\n", 0L, 0L);
        pf = NEW_PPERM2(degf);
        ptpf = ADDR_PPERM2(pf);
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM2(f);
        for (i = 0; i < deg; i++)
            *ptpf++ = ptf[*ptp++];
        for (; i < degf; i++)
            *ptpf++ = ptf[i];
    }
    else {    // deg(f)<=deg(p)
        // Pr("case 2\n", 0L, 0L);
        // find the degree
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM2(f);
        while (ptp[deg - 1] >= degf || ptf[ptp[deg - 1]] == 0)
            deg--;
        pf = NEW_PPERM2(deg);
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM2(f);
        ptpf = ADDR_PPERM2(pf);
        for (i = 0; i < deg; i++)
            if (ptp[i] < degf)
                ptpf[i] = ptf[ptp[i]];
    }

    SET_CODEG_PPERM2(pf, CODEG_PPERM2(f));
    return pf;
}

Obj ProdPerm2PPerm4(Obj p, Obj f)
{
    UInt2 * ptp;
    UInt4 * ptf, *ptpf;
    UInt    deg, degf, i;
    Obj     pf;

    if (DEG_PPERM4(f) == 0)
        return EmptyPartialPerm;

    deg = DEG_PERM2(p);
    degf = DEG_PPERM4(f);
    if (deg < degf) {
        // Pr("case 1\n", 0L, 0L);
        pf = NEW_PPERM4(degf);
        ptpf = ADDR_PPERM4(pf);
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM4(f);
        for (i = 0; i < deg; i++)
            *ptpf++ = ptf[*ptp++];
        for (; i < degf; i++)
            *ptpf++ = ptf[i];
    }
    else {    // deg(f)<deg(p)
        // Pr("case 2\n", 0L, 0L);
        // find the degree
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM4(f);
        while (ptp[deg - 1] >= degf || ptf[ptp[deg - 1]] == 0)
            deg--;
        pf = NEW_PPERM4(deg);
        ptpf = ADDR_PPERM4(pf);
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM4(f);
        for (i = 0; i < deg; i++)
            if (ptp[i] < degf)
                ptpf[i] = ptf[ptp[i]];
    }

    SET_CODEG_PPERM4(pf, CODEG_PPERM4(f));
    return pf;
}

// the inverse of a partial perm
Obj InvPPerm2(Obj f)
{
    UInt    deg, codeg, i, j, rank;
    UInt2 * ptf, *ptinv2;
    UInt4 * ptinv4;
    Obj     inv, dom;

    deg = DEG_PPERM2(f);
    codeg = CODEG_PPERM2(f);

    if (deg < 65536) {
        inv = NEW_PPERM2(codeg);
        ptf = ADDR_PPERM2(f);
        ptinv2 = ADDR_PPERM2(inv);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++)
                if (ptf[i] != 0)
                    ptinv2[ptf[i] - 1] = i + 1;
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptinv2[ptf[j] - 1] = j + 1;
            }
        }
        SET_CODEG_PPERM2(inv, deg);
    }
    else {
        inv = NEW_PPERM4(codeg);
        ptf = ADDR_PPERM2(f);
        ptinv4 = ADDR_PPERM4(inv);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++)
                if (ptf[i] != 0)
                    ptinv4[ptf[i] - 1] = i + 1;
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptinv4[ptf[j] - 1] = j + 1;
            }
        }
        SET_CODEG_PPERM4(inv, deg);
    }
    return inv;
}

Obj InvPPerm4(Obj f)
{
    UInt    deg, codeg, i, j, rank;
    UInt2 * ptinv2;
    UInt4 * ptf, *ptinv4;
    Obj     inv, dom;

    deg = DEG_PPERM4(f);
    codeg = CODEG_PPERM4(f);

    if (deg < 65536) {
        inv = NEW_PPERM2(codeg);
        ptf = ADDR_PPERM4(f);
        ptinv2 = ADDR_PPERM2(inv);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++)
                if (ptf[i] != 0)
                    ptinv2[ptf[i] - 1] = i + 1;
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptinv2[ptf[j] - 1] = j + 1;
            }
        }
        SET_CODEG_PPERM2(inv, deg);
    }
    else {
        inv = NEW_PPERM4(codeg);
        ptf = ADDR_PPERM4(f);
        ptinv4 = ADDR_PPERM4(inv);
        if (DOM_PPERM(f) == NULL) {
            for (i = 0; i < deg; i++)
                if (ptf[i] != 0)
                    ptinv4[ptf[i] - 1] = i + 1;
        }
        else {
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptinv4[ptf[j] - 1] = j + 1;
            }
        }
        SET_CODEG_PPERM4(inv, deg);
    }
    return inv;
}

// Conjugation: p^-1*f*p
// lose the assumption that dom is known and renovate as per LquoPermPPerm
// JDM
Obj PowPPerm2Perm2(Obj f, Obj p)
{
    UInt   deg, rank, degconj, i, j, k, codeg;
    UInt2 *ptf, *ptp, *ptconj, dep;
    Obj    conj, dom;

    deg = DEG_PPERM2(f);
    if (deg == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM2(p);
    rank = RANK_PPERM2(f);
    ptp = ADDR_PERM2(p);
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

    conj = NEW_PPERM2(degconj);
    ptconj = ADDR_PPERM2(conj);
    ptp = ADDR_PERM2(p);
    ptf = ADDR_PPERM2(f);
    codeg = CODEG_PPERM2(f);

    if (codeg > dep) {
        SET_CODEG_PPERM2(conj, codeg);
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
        SET_CODEG_PPERM2(conj, codeg);
    }

    return conj;
}

Obj PowPPerm2Perm4(Obj f, Obj p)
{
    UInt    deg, rank, degconj, i, j, k, codeg;
    UInt2 * ptf;
    UInt4 * ptp, *ptconj, dep;
    Obj     conj, dom;

    deg = DEG_PPERM2(f);
    if (deg == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM4(p);
    rank = RANK_PPERM2(f);
    ptp = ADDR_PERM4(p);
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

    conj = NEW_PPERM4(degconj);
    ptconj = ADDR_PPERM4(conj);
    ptp = ADDR_PERM4(p);
    ptf = ADDR_PPERM2(f);
    codeg = 0;

    for (i = 1; i <= rank; i++) {
        j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
        k = ptp[ptf[j] - 1] + 1;
        ptconj[IMAGE(j, ptp, dep)] = k;
        if (k > codeg)
            codeg = k;
    }
    SET_CODEG_PPERM4(conj, codeg);

    return conj;
}

Obj PowPPerm4Perm2(Obj f, Obj p)
{
    UInt    deg, rank, degconj, i, j, k, codeg;
    UInt4 * ptf, *ptconj, dep;
    UInt2 * ptp;
    Obj     conj, dom;

    deg = DEG_PPERM4(f);
    if (deg == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM2(p);
    rank = RANK_PPERM4(f);
    ptp = ADDR_PERM2(p);
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

    conj = NEW_PPERM4(degconj);
    ptconj = ADDR_PPERM4(conj);
    ptp = ADDR_PERM2(p);
    ptf = ADDR_PPERM4(f);
    codeg = CODEG_PPERM4(f);

    if (codeg > dep) {
        SET_CODEG_PPERM4(conj, codeg);
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
        SET_CODEG_PPERM4(conj, codeg);
    }
    return conj;
}

Obj PowPPerm4Perm4(Obj f, Obj p)
{
    UInt   deg, rank, degconj, i, j, k, codeg;
    UInt4 *ptf, *ptp, *ptconj, dep;
    Obj    conj, dom;

    deg = DEG_PPERM4(f);
    if (deg == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM4(p);
    rank = RANK_PPERM4(f);
    ptp = ADDR_PERM4(p);
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

    conj = NEW_PPERM4(degconj);
    ptconj = ADDR_PPERM4(conj);
    ptp = ADDR_PERM4(p);
    ptf = ADDR_PPERM4(f);
    codeg = CODEG_PPERM4(f);

    if (codeg > dep) {
        // Pr("case 1\n", 0L, 0L);
        SET_CODEG_PPERM4(conj, codeg);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptconj[IMAGE(j, ptp, dep)] = IMAGE(ptf[j] - 1, ptp, dep) + 1;
        }
    }
    else {    // codeg(f)<=deg(p)
        // Pr("case 2"\n, 0L, 0L);
        codeg = 0;
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            k = ptp[ptf[j] - 1] + 1;
            ptconj[IMAGE(j, ptp, dep)] = k;
            if (k > codeg)
                codeg = k;
        }
        SET_CODEG_PPERM4(conj, codeg);
    }
    return conj;
}

// g^-1*f*g
// JDM not sure this is worth it...
Obj PowPPerm22(Obj f, Obj g)
{
    UInt2 *ptg, *ptf, *ptconj, img;
    UInt   i, j, def, deg, dec, codeg, codec, min, len;
    Obj    dom, conj;

    // check if we're in the trivial case
    def = DEG_PPERM2(f);
    deg = DEG_PPERM2(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = ADDR_PPERM2(f);
    ptg = ADDR_PPERM2(g);
    dom = DOM_PPERM(f);
    codeg = CODEG_PPERM2(g);
    dec = 0;
    codec = 0;

    if (dom == NULL) {
        min = MIN(def, deg);
        if (CODEG_PPERM2(f) <= deg) {
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
            conj = NEW_PPERM2(dec);
            ptconj = ADDR_PPERM2(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM2(g);

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
            conj = NEW_PPERM2(dec);
            ptconj = ADDR_PPERM2(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM2(g);

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
        if (CODEG_PPERM2(f) <= deg) {
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
            conj = NEW_PPERM2(dec);
            ptconj = ADDR_PPERM2(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM2(g);
            len = LEN_PLIST(dom);
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
            conj = NEW_PPERM2(dec);
            ptconj = ADDR_PPERM2(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM2(g);

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
        if (CODEG_PPERM2(f) <= deg) {
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
            conj = NEW_PPERM2(dec);
            ptconj = ADDR_PPERM2(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM2(g);

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
            conj = NEW_PPERM2(dec);
            ptconj = ADDR_PPERM2(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM2(g);

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
    SET_CODEG_PPERM2(conj, codec);
    return conj;
}

Obj PowPPerm24(Obj f, Obj g)
{
    UInt4 * ptg, *ptconj;
    UInt2 * ptf;
    UInt    i, j, def, deg, dec, codeg, codec, min, img, len;
    Obj     dom, conj;

    // check if we're in the trivial case
    def = DEG_PPERM2(f);
    deg = DEG_PPERM4(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = ADDR_PPERM2(f);
    ptg = ADDR_PPERM4(g);
    dom = DOM_PPERM(f);
    codeg = CODEG_PPERM4(g);
    dec = 0;
    codec = 0;

    if (dom == NULL) {
        min = MIN(def, deg);
        if (CODEG_PPERM2(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM4(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM4(g);

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
        if (CODEG_PPERM2(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM4(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM4(g);

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
        if (CODEG_PPERM2(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM4(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM2(f);
            ptg = ADDR_PPERM4(g);

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
    SET_CODEG_PPERM4(conj, codec);
    return conj;
}

Obj PowPPerm42(Obj f, Obj g)
{
    UInt4 * ptf, *ptconj;
    UInt2 * ptg;
    UInt    i, j, def, deg, dec, codeg, codec, min, img, len;
    Obj     dom, conj;

    // check if we're in the trivial case
    def = DEG_PPERM4(f);
    deg = DEG_PPERM2(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = ADDR_PPERM4(f);
    ptg = ADDR_PPERM2(g);
    dom = DOM_PPERM(f);
    codeg = CODEG_PPERM2(g);
    dec = 0;
    codec = 0;

    if (dom == NULL) {
        min = MIN(def, deg);
        if (CODEG_PPERM4(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM2(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM2(g);

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
        if (CODEG_PPERM4(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM2(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM2(g);

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
        if (CODEG_PPERM4(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM2(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM2(g);

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
    SET_CODEG_PPERM4(conj, codec);
    return conj;
}

Obj PowPPerm44(Obj f, Obj g)
{
    UInt4 *ptg, *ptf, *ptconj, img;
    UInt   i, j, def, deg, dec, codeg, codec, min, len;
    Obj    dom, conj;

    // check if we're in the trivial case
    def = DEG_PPERM4(f);
    deg = DEG_PPERM4(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = ADDR_PPERM4(f);
    ptg = ADDR_PPERM4(g);
    dom = DOM_PPERM(f);
    codeg = CODEG_PPERM4(g);
    dec = 0;
    codec = 0;

    if (dom == NULL) {
        min = MIN(def, deg);
        if (CODEG_PPERM4(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM4(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM4(g);

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
        if (CODEG_PPERM4(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM4(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM4(g);

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
        if (CODEG_PPERM4(f) <= deg) {
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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM4(g);

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
            conj = NEW_PPERM4(dec);
            ptconj = ADDR_PPERM4(conj);
            ptf = ADDR_PPERM4(f);
            ptg = ADDR_PPERM4(g);

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
    SET_CODEG_PPERM4(conj, codec);
    return conj;
}

// f*p^-1
Obj QuoPPerm2Perm2(Obj f, Obj p)
{
    UInt2 *ptf, *ptp, *ptquo2;
    UInt4 *ptquo4, *pttmp;
    Obj    quo, dom;
    UInt   codeg, lmp, deg, i, j, rank;

    if (DEG_PPERM2(f) == 0)
        return EmptyPartialPerm;

    // find the largest moved point
    lmp = DEG_PERM2(p);
    ptp = ADDR_PERM2(p);
    while (lmp > 0 && ptp[lmp - 1] == lmp - 1)
        lmp--;
    if (lmp == 0)
        return f;

    // invert the permutation into the buffer bag
    ResizeTmpPPerm(lmp);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    ptp = ADDR_PERM2(p);
    for (i = 0; i < lmp; i++)
        pttmp[*ptp++] = i;

    // create new pperm
    deg = DEG_PPERM2(f);
    codeg = CODEG_PPERM2(f);

    // multiply the partial perm with the inverse
    if (lmp < 65536) {
        quo = NEW_PPERM2(deg);
        ptf = ADDR_PPERM2(f);
        pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
        ptquo2 = ADDR_PPERM2(quo);
        if (codeg <= lmp) {
            codeg = 0;
            if (DOM_PPERM(f) == NULL) {
                // Pr("Case 2\n", 0L, 0L);
                for (i = 0; i < deg; i++) {
                    if (ptf[i] != 0) {
                        ptquo2[i] = pttmp[ptf[i] - 1] + 1;
                        if (ptquo2[i] > codeg)
                            codeg = ptquo2[i];
                    }
                }
            }
            else {
                // Pr("Case 1\n", 0L, 0L);
                dom = DOM_PPERM(f);
                rank = RANK_PPERM2(f);
                for (i = 1; i <= rank; i++) {
                    j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                    ptquo2[j] = pttmp[ptf[j] - 1] + 1;
                    if (ptquo2[j] > codeg)
                        codeg = ptquo2[j];
                }
            }
        }
        else {
            if (DOM_PPERM(f) == NULL) {
                // Pr("Case 4\n", 0L, 0L);
                for (i = 0; i < deg; i++) {
                    if (ptf[i] != 0) {
                        ptquo2[i] = IMAGE(ptf[i] - 1, pttmp, lmp) + 1;
                    }
                }
            }
            else {
                // Pr("Case 3\n", 0L, 0L);
                dom = DOM_PPERM(f);
                rank = RANK_PPERM2(f);
                for (i = 1; i <= rank; i++) {
                    j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                    ptquo2[j] = IMAGE(ptf[j] - 1, pttmp, lmp) + 1;
                }
            }
        }
        SET_CODEG_PPERM2(quo, codeg);
    }
    else {
        quo = NEW_PPERM4(deg);
        ptquo4 = ADDR_PPERM4(quo);
        ptf = ADDR_PPERM2(f);
        pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
        ptquo4 = ADDR_PPERM4(quo);
        codeg = 0;
        if (DOM_PPERM(f) == NULL) {
            // Pr("Case 6\n", 0L, 0L);
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptquo4[i] = pttmp[ptf[i] - 1] + 1;
                    if (ptquo4[i] > codeg)
                        codeg = ptquo4[i];
                }
            }
        }
        else {
            // Pr("Case 5\n", 0L, 0L);
            dom = DOM_PPERM(f);
            rank = RANK_PPERM2(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptquo4[j] = pttmp[ptf[j] - 1] + 1;
                if (ptquo4[j] > codeg)
                    codeg = ptquo4[j];
            }
        }
        SET_CODEG_PPERM4(quo, codeg);
    }
    return quo;
}

Obj QuoPPerm4Perm4(Obj f, Obj p)
{
    UInt4 *ptf, *ptp, *ptquo, *pttmp;
    Obj    quo, dom;
    UInt   codeg, lmp, deg, i, j, rank;

    if (DEG_PPERM4(f) == 0)
        return EmptyPartialPerm;

    // find the largest moved point
    lmp = DEG_PERM4(p);
    ptp = ADDR_PERM4(p);
    while (lmp > 0 && ptp[lmp - 1] == lmp - 1)
        lmp--;
    if (lmp == 0)
        return f;

    // invert the permutation into the buffer bag
    ResizeTmpPPerm(lmp);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    ptp = ADDR_PERM4(p);
    for (i = 0; i < lmp; i++)
        pttmp[*ptp++] = i;

    // create new pperm
    deg = DEG_PPERM4(f);
    codeg = CODEG_PPERM4(f);
    quo = NEW_PPERM4(deg);

    // renew pointers
    ptf = ADDR_PPERM4(f);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    ptquo = ADDR_PPERM4(quo);

    // multiply the partial perm with the inverse
    if (codeg <= lmp) {
        codeg = 0;
        if (DOM_PPERM(f) == NULL) {
            // Pr("case 1\n", 0L, 0L);
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptquo[i] = pttmp[ptf[i] - 1] + 1;
                    if (ptquo[i] > codeg)
                        codeg = ptquo[i];
                }
            }
        }
        else {
            // Pr("case 2\n", 0L, 0L);
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptquo[j] = pttmp[ptf[j] - 1] + 1;
                if (ptquo[j] > codeg)
                    codeg = ptquo[j];
            }
        }
    }
    else {
        if (DOM_PPERM(f) == NULL) {
            // Pr("case 3\n", 0L, 0L);
            for (i = 0; i < deg; i++) {
                if (ptf[i] != 0) {
                    ptquo[i] = IMAGE(ptf[i] - 1, pttmp, lmp) + 1;
                }
            }
        }
        else {
            // Pr("case 4\n", 0L, 0L);
            dom = DOM_PPERM(f);
            rank = RANK_PPERM4(f);
            for (i = 1; i <= rank; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptquo[j] = IMAGE(ptf[j] - 1, pttmp, lmp) + 1;
            }
        }
    }
    SET_CODEG_PPERM4(quo, codeg);
    return quo;
}

Obj QuoPPerm2Perm4(Obj f, Obj p)
{
    UInt4 * ptp, *ptquo, *pttmp;
    UInt2 * ptf;
    Obj     quo, dom;
    UInt    codeg, lmp, deg, i, j, rank;

    if (DEG_PPERM2(f) == 0)
        return EmptyPartialPerm;

    // find the largest moved point
    lmp = DEG_PERM4(p);
    ptp = ADDR_PERM4(p);
    while (lmp > 0 && ptp[lmp - 1] == lmp - 1)
        lmp--;
    if (lmp == 0)
        return f;

    // invert the permutation into the buffer bag
    ResizeTmpPPerm(lmp);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    ptp = ADDR_PERM4(p);
    for (i = 0; i < lmp; i++)
        pttmp[*ptp++] = i;

    // create new pperm
    deg = DEG_PPERM2(f);
    quo = NEW_PPERM4(deg);

    // renew pointers
    ptf = ADDR_PPERM2(f);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    ptquo = ADDR_PPERM4(quo);

    // multiply the partial perm with the inverse
    codeg = 0;
    if (DOM_PPERM(f) == NULL) {
        for (i = 0; i < deg; i++) {
            if (ptf[i] != 0) {
                ptquo[i] = pttmp[ptf[i] - 1] + 1;
                if (ptquo[i] > codeg)
                    codeg = ptquo[i];
            }
        }
    }
    else {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM2(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptquo[j] = pttmp[ptf[j] - 1] + 1;
            if (ptquo[j] > codeg)
                codeg = ptquo[j];
        }
    }
    SET_CODEG_PPERM4(quo, codeg);
    return quo;
}

Obj QuoPPerm4Perm2(Obj f, Obj p)
{
    UInt4 * ptf, *ptquo, *pttmp;
    UInt2 * ptp;
    Obj     quo, dom;
    UInt    lmp, deg, i, j, rank;

    if (DEG_PPERM4(f) == 0)
        return EmptyPartialPerm;

    // find the largest moved point
    lmp = DEG_PERM2(p);
    ptp = ADDR_PERM2(p);
    while (lmp > 0 && ptp[lmp - 1] == lmp - 1)
        lmp--;
    if (lmp == 0)
        return f;

    // invert the permutation into the buffer bag
    ResizeTmpPPerm(lmp);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    ptp = ADDR_PERM2(p);
    for (i = 0; i < lmp; i++)
        pttmp[*ptp++] = i;

    // create new pperm
    deg = DEG_PPERM4(f);
    quo = NEW_PPERM4(deg);

    // renew pointers
    ptf = ADDR_PPERM4(f);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    ptquo = ADDR_PPERM4(quo);

    // multiply the partial perm with the inverse
    if (DOM_PPERM(f) == NULL) {
        // Pr("case 1\n", 0L, 0L);
        for (i = 0; i < deg; i++) {
            if (ptf[i] != 0) {
                ptquo[i] = IMAGE(ptf[i] - 1, pttmp, lmp) + 1;
            }
        }
    }
    else {
        // Pr("case 2\n", 0L, 0L);
        dom = DOM_PPERM(f);
        rank = RANK_PPERM4(f);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            ptquo[j] = IMAGE(ptf[j] - 1, pttmp, lmp) + 1;
        }
    }
    SET_CODEG_PPERM4(quo, CODEG_PPERM4(f));
    return quo;
}

// f*g^-1 for partial perms
Obj QuoPPerm22(Obj f, Obj g)
{
    UInt   deg, i, j, deginv, codeg, rank;
    UInt2 *ptf, *ptg;
    UInt4 *ptquo, *pttmp;
    Obj    quo, dom;

    // do nothing in the trivial case
    if (DEG_PPERM2(g) == 0 || DEG_PPERM2(f) == 0)
        return EmptyPartialPerm;

    // init the buffer bag
    deginv = CODEG_PPERM2(g);
    ResizeTmpPPerm(deginv);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    for (i = 0; i < deginv; i++)
        pttmp[i] = 0;

    // invert g into the buffer bag
    ptg = ADDR_PPERM2(g);
    if (DOM_PPERM(g) == NULL) {
        deg = DEG_PPERM2(g);
        for (i = 0; i < deg; i++)
            if (ptg[i] != 0)
                pttmp[ptg[i] - 1] = i + 1;
    }
    else {
        dom = DOM_PPERM(g);
        rank = RANK_PPERM2(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            pttmp[ptg[j] - 1] = j + 1;
        }
    }

    // find the degree of the quotient
    deg = DEG_PPERM2(f);
    ptf = ADDR_PPERM2(f);
    while (deg > 0 &&
           (ptf[deg - 1] == 0 || IMAGEPP(ptf[deg - 1], pttmp, deginv) == 0))
        deg--;
    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    quo = NEW_PPERM4(deg);
    ptquo = ADDR_PPERM4(quo);
    ptf = ADDR_PPERM2(f);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    codeg = 0;

    // compose f with g^-1 in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM2(f);
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

Obj QuoPPerm24(Obj f, Obj g)
{
    UInt    deg, i, j, deginv, codeg, rank;
    UInt2 * ptf;
    UInt4 * ptg, *ptquo, *pttmp;
    Obj     quo, dom;

    // do nothing in the trivial case
    if (DEG_PPERM4(g) == 0 || DEG_PPERM2(f) == 0)
        return EmptyPartialPerm;

    // init the buffer bag
    deginv = CODEG_PPERM4(g);
    ResizeTmpPPerm(deginv);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    for (i = 0; i < deginv; i++)
        pttmp[i] = 0;

    // invert g into the buffer bag
    ptg = ADDR_PPERM4(g);
    if (DOM_PPERM(g) == NULL) {
        deg = DEG_PPERM4(g);
        for (i = 0; i < deg; i++)
            if (ptg[i] != 0)
                pttmp[ptg[i] - 1] = i + 1;
    }
    else {
        dom = DOM_PPERM(g);
        rank = RANK_PPERM4(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            pttmp[ptg[j] - 1] = j + 1;
        }
    }

    // find the degree of the quotient
    deg = DEG_PPERM2(f);
    ptf = ADDR_PPERM2(f);
    if (CODEG_PPERM2(f) <= deginv) {
        while (deg > 0 && (ptf[deg - 1] == 0 || pttmp[ptf[deg - 1] - 1] == 0))
            deg--;
    }
    else {
        while (deg > 0 && (ptf[deg - 1] == 0 ||
                           IMAGEPP(ptf[deg - 1], pttmp, deginv) == 0))
            deg--;
    }

    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    quo = NEW_PPERM4(deg);
    ptquo = ADDR_PPERM4(quo);
    ptf = ADDR_PPERM2(f);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    codeg = 0;

    // compose f with g^-1 in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM2(f);
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

Obj QuoPPerm42(Obj f, Obj g)
{
    UInt    deg, i, j, deginv, codeg, rank;
    UInt2 * ptg;
    UInt4 * ptf, *ptquo, *pttmp;
    Obj     quo, dom;

    // do nothing in the trivial case
    if (DEG_PPERM2(g) == 0 || DEG_PPERM4(f) == 0)
        return EmptyPartialPerm;

    // init the buffer bag
    deginv = CODEG_PPERM2(g);
    ResizeTmpPPerm(deginv);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    for (i = 0; i < deginv; i++)
        pttmp[i] = 0;

    // invert g into the buffer bag
    ptg = ADDR_PPERM2(g);
    if (DOM_PPERM(g) == NULL) {
        deg = DEG_PPERM2(g);
        for (i = 0; i < deg; i++)
            if (ptg[i] != 0)
                pttmp[ptg[i] - 1] = i + 1;
    }
    else {
        dom = DOM_PPERM(g);
        rank = RANK_PPERM2(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            pttmp[ptg[j] - 1] = j + 1;
        }
    }

    // find the degree of the quotient
    deg = DEG_PPERM4(f);
    ptf = ADDR_PPERM4(f);
    if (CODEG_PPERM4(f) <= deginv) {
        while (deg > 0 && (ptf[deg - 1] == 0 || pttmp[ptf[deg - 1] - 1] == 0))
            deg--;
    }
    else {
        while (deg > 0 && (ptf[deg - 1] == 0 ||
                           IMAGEPP(ptf[deg - 1], pttmp, deginv) == 0))
            deg--;
    }

    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    quo = NEW_PPERM4(deg);
    ptquo = ADDR_PPERM4(quo);
    ptf = ADDR_PPERM4(f);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    codeg = 0;

    // compose f with g^-1 in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM4(f);
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

Obj QuoPPerm44(Obj f, Obj g)
{
    UInt   deg, i, j, deginv, codeg, rank;
    UInt4 *ptf, *ptg, *ptquo, *pttmp;
    Obj    quo, dom;

    // do nothing in the trivial case
    if (DEG_PPERM4(g) == 0 || DEG_PPERM4(f) == 0)
        return EmptyPartialPerm;

    // init the buffer bag
    deginv = CODEG_PPERM4(g);
    ResizeTmpPPerm(deginv);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    for (i = 0; i < deginv; i++)
        pttmp[i] = 0;

    // invert g into the buffer bag
    ptg = ADDR_PPERM4(g);
    if (DOM_PPERM(g) == NULL) {
        deg = DEG_PPERM4(g);
        for (i = 0; i < deg; i++)
            if (ptg[i] != 0)
                pttmp[ptg[i] - 1] = i + 1;
    }
    else {
        dom = DOM_PPERM(g);
        rank = RANK_PPERM4(g);
        for (i = 1; i <= rank; i++) {
            j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
            pttmp[ptg[j] - 1] = j + 1;
        }
    }

    // find the degree of the quotient
    deg = DEG_PPERM4(f);
    ptf = ADDR_PPERM4(f);
    while (deg > 0 &&
           (ptf[deg - 1] == 0 || IMAGEPP(ptf[deg - 1], pttmp, deginv) == 0))
        deg--;
    if (deg == 0)
        return EmptyPartialPerm;

    // create new pperm
    quo = NEW_PPERM4(deg);
    ptquo = ADDR_PPERM4(quo);
    ptf = ADDR_PPERM4(f);
    pttmp = ((UInt4 *)ADDR_OBJ(TmpPPerm));
    codeg = 0;

    // compose f with g^-1 in rank operations
    if (DOM_PPERM(f) != NULL) {
        dom = DOM_PPERM(f);
        rank = RANK_PPERM4(f);
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
Obj PowIntPPerm2(Obj i, Obj f)
{

    if (!IS_INTOBJ(i) || INT_INTOBJ(i) <= 0) {
        ErrorQuit("usage: the first argument should be a positive integer,",
                  0L, 0L);
        return 0L;
    }
    return INTOBJ_INT(
        IMAGEPP((UInt)INT_INTOBJ(i), ADDR_PPERM2(f), DEG_PPERM2(f)));
}

Obj PowIntPPerm4(Obj i, Obj f)
{

    if (!IS_INTOBJ(i) || INT_INTOBJ(i) <= 0) {
        ErrorQuit("usage: the first argument should be a positive integer,",
                  0L, 0L);
        return 0L;
    }
    return INTOBJ_INT(
        IMAGEPP((UInt)INT_INTOBJ(i), ADDR_PPERM4(f), DEG_PPERM4(f)));
}

// p^-1*f
Obj LQuoPerm2PPerm2(Obj p, Obj f)
{
    UInt2 *ptp, *ptf, *ptlquo, dep;
    UInt   def, i, j, del, len;
    Obj    dom, lquo;

    def = DEG_PPERM2(f);
    if (def == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM2(p);
    dom = DOM_PPERM(f);

    if (dep < def) {
        lquo = NEW_PPERM2(def);
        ptlquo = ADDR_PPERM2(lquo);
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM2(f);
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
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM2(f);
        if (dom == NULL) {
            // find the degree
            for (i = 0; i < def; i++) {
                if (ptf[i] != 0 && ptp[i] >= del) {
                    del = ptp[i] + 1;
                    if (del == dep)
                        break;
                }
            }
            lquo = NEW_PPERM2(del);
            ptlquo = ADDR_PPERM2(lquo);
            ptp = ADDR_PERM2(p);
            ptf = ADDR_PPERM2(f);

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
            lquo = NEW_PPERM2(del);
            ptlquo = ADDR_PPERM2(lquo);
            ptp = ADDR_PERM2(p);
            ptf = ADDR_PPERM2(f);

            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptlquo[ptp[j]] = ptf[j];
            }
        }
    }

    SET_CODEG_PPERM2(lquo, CODEG_PPERM2(f));
    return lquo;
}

Obj LQuoPerm2PPerm4(Obj p, Obj f)
{
    UInt2 *ptp, dep;
    UInt4 *ptf, *ptlquo;
    UInt   def, i, j, del, len;
    Obj    dom, lquo;

    def = DEG_PPERM4(f);
    if (def == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM2(p);
    dom = DOM_PPERM(f);

    if (dep < def) {
        lquo = NEW_PPERM4(def);
        ptlquo = ADDR_PPERM4(lquo);
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM4(f);
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
        ptp = ADDR_PERM2(p);
        ptf = ADDR_PPERM4(f);
        if (dom == NULL) {
            // find the degree
            for (i = 0; i < def; i++) {
                if (ptf[i] != 0 && ptp[i] >= del) {
                    del = ptp[i] + 1;
                    if (del == dep)
                        break;
                }
            }
            lquo = NEW_PPERM4(del);
            ptlquo = ADDR_PPERM4(lquo);
            ptp = ADDR_PERM2(p);
            ptf = ADDR_PPERM4(f);

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
            lquo = NEW_PPERM4(del);
            ptlquo = ADDR_PPERM4(lquo);
            ptp = ADDR_PERM2(p);
            ptf = ADDR_PPERM4(f);

            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptlquo[ptp[j]] = ptf[j];
            }
        }
    }
    SET_CODEG_PPERM4(lquo, CODEG_PPERM4(f));
    return lquo;
}

Obj LQuoPerm4PPerm2(Obj p, Obj f)
{
    UInt4 *ptp, dep;
    UInt2 *ptf, *ptlquo;
    UInt   def, i, j, del, len;
    Obj    dom, lquo;

    def = DEG_PPERM2(f);
    if (def == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM4(p);
    dom = DOM_PPERM(f);

    if (dep < def) {
        lquo = NEW_PPERM2(def);
        ptlquo = ADDR_PPERM2(lquo);
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM2(f);
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
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM2(f);
        if (dom == NULL) {
            // find the degree
            for (i = 0; i < def; i++) {
                if (ptf[i] != 0 && ptp[i] >= del) {
                    del = ptp[i] + 1;
                    if (del == dep)
                        break;
                }
            }
            lquo = NEW_PPERM2(del);
            ptlquo = ADDR_PPERM2(lquo);
            ptp = ADDR_PERM4(p);
            ptf = ADDR_PPERM2(f);

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
            lquo = NEW_PPERM2(del);
            ptlquo = ADDR_PPERM2(lquo);
            ptp = ADDR_PERM4(p);
            ptf = ADDR_PPERM2(f);

            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptlquo[ptp[j]] = ptf[j];
            }
        }
    }

    SET_CODEG_PPERM2(lquo, CODEG_PPERM2(f));
    return lquo;
}

Obj LQuoPerm4PPerm4(Obj p, Obj f)
{
    UInt4 *ptp, *ptf, *ptlquo, dep;
    UInt   def, i, j, del, len;
    Obj    dom, lquo;

    def = DEG_PPERM4(f);
    if (def == 0)
        return EmptyPartialPerm;

    dep = DEG_PERM4(p);
    dom = DOM_PPERM(f);

    if (dep < def) {
        lquo = NEW_PPERM4(def);
        ptlquo = ADDR_PPERM4(lquo);
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM4(f);
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
        ptp = ADDR_PERM4(p);
        ptf = ADDR_PPERM4(f);
        if (dom == NULL) {
            // find the degree
            for (i = 0; i < def; i++) {
                if (ptf[i] != 0 && ptp[i] >= del) {
                    del = ptp[i] + 1;
                    if (del == dep)
                        break;
                }
            }
            lquo = NEW_PPERM4(del);
            ptlquo = ADDR_PPERM4(lquo);
            ptp = ADDR_PERM4(p);
            ptf = ADDR_PPERM4(f);

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
            lquo = NEW_PPERM4(del);
            ptlquo = ADDR_PPERM4(lquo);
            ptp = ADDR_PERM4(p);
            ptf = ADDR_PPERM4(f);

            for (i = 1; i <= len; i++) {
                j = INT_INTOBJ(ELM_PLIST(dom, i)) - 1;
                ptlquo[ptp[j]] = ptf[j];
            }
        }
    }

    SET_CODEG_PPERM4(lquo, CODEG_PPERM4(f));
    return lquo;
}

// f^-1*g
Obj LQuoPPerm22(Obj f, Obj g)
{
    UInt2 *ptg, *ptf, *ptlquo;
    UInt   i, j, def, deg, del, codef, codel, min, len;
    Obj    dom, lquo;

    // check if we're in the trivial case
    def = DEG_PPERM2(f);
    deg = DEG_PPERM2(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = ADDR_PPERM2(f);
    ptg = ADDR_PPERM2(g);
    dom = DOM_PPERM(g);
    del = 0;
    codef = CODEG_PPERM2(f);
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
        lquo = NEW_PPERM2(del);
        ptlquo = ADDR_PPERM2(lquo);
        ptf = ADDR_PPERM2(f);
        ptg = ADDR_PPERM2(g);

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
        lquo = NEW_PPERM2(del);
        ptlquo = ADDR_PPERM2(lquo);
        ptf = ADDR_PPERM2(f);
        ptg = ADDR_PPERM2(g);

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
        lquo = NEW_PPERM2(del);
        ptlquo = ADDR_PPERM2(lquo);
        ptf = ADDR_PPERM2(f);
        ptg = ADDR_PPERM2(g);

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
    SET_CODEG_PPERM2(lquo, codel);
    return lquo;
}

Obj LQuoPPerm24(Obj f, Obj g)
{
    UInt4 * ptg, *ptlquo;
    UInt2 * ptf;
    UInt    i, j, def, deg, del, codef, codel, min, len;
    Obj     dom, lquo;

    // check if we're in the trivial case
    def = DEG_PPERM2(f);
    deg = DEG_PPERM4(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = ADDR_PPERM2(f);
    ptg = ADDR_PPERM4(g);
    dom = DOM_PPERM(g);
    del = 0;
    codef = CODEG_PPERM2(f);
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
        lquo = NEW_PPERM4(del);
        ptlquo = ADDR_PPERM4(lquo);
        ptf = ADDR_PPERM2(f);
        ptg = ADDR_PPERM4(g);

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
        lquo = NEW_PPERM4(del);
        ptlquo = ADDR_PPERM4(lquo);
        ptf = ADDR_PPERM2(f);
        ptg = ADDR_PPERM4(g);

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
        lquo = NEW_PPERM4(del);
        ptlquo = ADDR_PPERM4(lquo);
        ptf = ADDR_PPERM2(f);
        ptg = ADDR_PPERM4(g);

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
    SET_CODEG_PPERM4(lquo, codel);
    return lquo;
}

Obj LQuoPPerm42(Obj f, Obj g)
{
    UInt2 * ptg, *ptlquo;
    UInt4 * ptf;
    UInt    i, j, def, deg, del, codef, codel, min, len;
    Obj     dom, lquo;

    // check if we're in the trivial case
    def = DEG_PPERM4(f);
    deg = DEG_PPERM2(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = ADDR_PPERM4(f);
    ptg = ADDR_PPERM2(g);
    dom = DOM_PPERM(g);
    del = 0;
    codef = CODEG_PPERM4(f);
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
        lquo = NEW_PPERM2(del);
        ptlquo = ADDR_PPERM2(lquo);
        ptf = ADDR_PPERM4(f);
        ptg = ADDR_PPERM2(g);

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
        lquo = NEW_PPERM2(del);
        ptlquo = ADDR_PPERM2(lquo);
        ptf = ADDR_PPERM4(f);
        ptg = ADDR_PPERM2(g);

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
        lquo = NEW_PPERM2(del);
        ptlquo = ADDR_PPERM2(lquo);
        ptf = ADDR_PPERM4(f);
        ptg = ADDR_PPERM2(g);

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
    SET_CODEG_PPERM2(lquo, codel);
    return lquo;
}

Obj LQuoPPerm44(Obj f, Obj g)
{
    UInt4 *ptg, *ptf, *ptlquo;
    UInt   i, j, def, deg, del, codef, codel, min, len;
    Obj    dom, lquo;

    // check if we're in the trivial case
    def = DEG_PPERM4(f);
    deg = DEG_PPERM4(g);
    if (def == 0 || deg == 0)
        return EmptyPartialPerm;

    ptf = ADDR_PPERM4(f);
    ptg = ADDR_PPERM4(g);
    dom = DOM_PPERM(g);
    del = 0;
    codef = CODEG_PPERM4(f);
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
        lquo = NEW_PPERM4(del);
        ptlquo = ADDR_PPERM4(lquo);
        ptf = ADDR_PPERM4(f);
        ptg = ADDR_PPERM4(g);

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
        lquo = NEW_PPERM4(del);
        ptlquo = ADDR_PPERM4(lquo);
        ptf = ADDR_PPERM4(f);
        ptg = ADDR_PPERM4(g);

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
        lquo = NEW_PPERM4(del);
        ptlquo = ADDR_PPERM4(lquo);
        ptf = ADDR_PPERM4(f);
        ptg = ADDR_PPERM4(g);

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
    SET_CODEG_PPERM4(lquo, codel);
    return lquo;
}

Obj OnSetsPPerm(Obj set, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg;
    const Obj * ptset;
    Obj *   ptres, tmp, res;
    UInt    i, isint, k, h, len;

    if (LEN_LIST(set) == 0)
        return set;

    res = NEW_PLIST(IS_MUTABLE_PLIST(set) ? T_PLIST : T_PLIST + IMMUTABLE,
                    LEN_LIST(set));

    /* get the pointer                                                 */
    ptset = CONST_ADDR_OBJ(set) + LEN_LIST(set);
    ptres = ADDR_OBJ(res) + 1;
    len = 0;

    if (TNUM_OBJ(f) == T_PPERM2) {
        ptf2 = ADDR_PPERM2(f);
        deg = DEG_PPERM2(f);
        /* loop over the entries of the tuple                              */
        isint = 1;
        for (i = LEN_LIST(set); 1 <= i; i--, ptset--) {
            if (IS_INTOBJ(*ptset) && 0 < INT_INTOBJ(*ptset)) {
                k = INT_INTOBJ(*ptset);
                if (k <= deg && ptf2[k - 1] != 0) {
                    tmp = INTOBJ_INT(ptf2[k - 1]);
                    len++;
                    *ptres++ = tmp;
                }
            }
            else { /* this case cannot occur since I think POW is not defined
                      */
                ErrorQuit("not yet implemented!", 0L, 0L);
            }
        }
    }
    else {
        ptf4 = ADDR_PPERM4(f);
        deg = DEG_PPERM4(f);

        /* loop over the entries of the tuple                              */
        isint = 1;
        for (i = LEN_LIST(set); 1 <= i; i--, ptset--) {
            if (IS_INTOBJ(*ptset) && 0 < INT_INTOBJ(*ptset)) {
                k = INT_INTOBJ(*ptset);
                if (k <= deg && ptf4[k - 1] != 0) {
                    tmp = INTOBJ_INT(ptf4[k - 1]);
                    len++;
                    *ptres++ = tmp;
                }
            }
            else { /* this case cannot occur since I think POW is not defined
                      */
                ErrorQuit("not yet implemented!", 0L, 0L);
            }
        }
    }
    // maybe a problem here if the result <res> has length 0, this certainly
    // caused a problem in OnPosIntSetsPPerm...
    if (len == 0) {
        RetypeBag(res, IS_MUTABLE_PLIST(set) ? T_PLIST_EMPTY
                                             : T_PLIST_EMPTY + IMMUTABLE);
        return res;
    }
    ResizeBag(res, (len + 1) * sizeof(Obj));
    SET_LEN_PLIST(res, len);

    /* sort the result */
    h = 1;
    while (9 * h + 4 < len)
        h = 3 * h + 1;
    while (0 < h) {
        for (i = h + 1; i <= len; i++) {
            tmp = CONST_ADDR_OBJ(res)[i];
            k = i;
            while (h < k && ((Int)tmp < (Int)(CONST_ADDR_OBJ(res)[k - h]))) {
                ADDR_OBJ(res)[k] = CONST_ADDR_OBJ(res)[k - h];
                k -= h;
            }
            ADDR_OBJ(res)[k] = tmp;
        }
        h = h / 3;
    }

    /* retype if we only have integers */
    if (isint) {
        RetypeBag(res, IS_MUTABLE_PLIST(set) ? T_PLIST_CYC_SSORT
                                             : T_PLIST_CYC_SSORT + IMMUTABLE);
    }

    return res;
}

Obj OnTuplesPPerm(Obj tup, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg;
    const Obj * pttup;
    Obj *   ptres, res;
    UInt    i, k, lentup, len;

    if (LEN_LIST(tup) == 0)
        return tup;

    res = NEW_PLIST(IS_MUTABLE_PLIST(tup) ? T_PLIST_CYC
                                          : T_PLIST_CYC + IMMUTABLE,
                    LEN_LIST(tup));

    /* get the pointer                                                 */
    pttup = CONST_ADDR_OBJ(tup) + 1;
    ptres = ADDR_OBJ(res) + 1;
    len = 0;

    if (TNUM_OBJ(f) == T_PPERM2) {
        ptf2 = ADDR_PPERM2(f);
        deg = DEG_PPERM2(f);
        /* loop over the entries of the tuple                              */
        lentup = LEN_LIST(tup);
        for (i = 1; i <= lentup; i++, pttup++) {
            if (IS_INTOBJ(*pttup) && 0 < INT_INTOBJ(*pttup)) {
                k = INT_INTOBJ(*pttup);
                if (k <= deg && ptf2[k - 1] != 0) {
                    len++;
                    *(ptres++) = INTOBJ_INT(ptf2[k - 1]);
                }
            }
            else { /* this case cannot occur since I think POW is not defined
                      */
                ErrorQuit("not yet implemented!", 0L, 0L);
            }
        }
    }
    else {
        ptf4 = ADDR_PPERM4(f);
        deg = DEG_PPERM4(f);
        /* loop over the entries of the tuple                              */
        lentup = LEN_LIST(tup);
        for (i = 1; i <= lentup; i++, pttup++) {
            if (IS_INTOBJ(*pttup) && 0 < INT_INTOBJ(*pttup)) {
                k = INT_INTOBJ(*pttup);
                if (k <= deg && ptf4[k - 1] != 0) {
                    len++;
                    *(ptres++) = INTOBJ_INT(ptf4[k - 1]);
                }
            }
            else { /* this case cannot occur since I think POW is not defined
                      */
                ErrorQuit("not yet implemented!", 0L, 0L);
            }
        }
    }
    SET_LEN_PLIST(res, (Int)len);
    SHRINK_PLIST(res, (Int)len);

    return res;
}

Obj FuncOnPosIntSetsPartialPerm(Obj self, Obj set, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg;
    const Obj * ptset;
    Obj *   ptres, tmp, res;
    UInt    i, k, h, len;

    if (LEN_LIST(set) == 0)
        return set;

    if (LEN_LIST(set) == 1 && INT_INTOBJ(ELM_LIST(set, 1)) == 0) {
        return FuncIMAGE_SET_PPERM(self, f);
    }

    PLAIN_LIST(set);
    res = NEW_PLIST(IS_MUTABLE_PLIST(set) ? T_PLIST_CYC_SSORT
                                          : T_PLIST_CYC_SSORT + IMMUTABLE,
                    LEN_LIST(set));

    /* get the pointer                                                 */
    ptset = CONST_ADDR_OBJ(set) + LEN_LIST(set);
    ptres = ADDR_OBJ(res) + 1;
    len = 0;

    if (TNUM_OBJ(f) == T_PPERM2) {
        ptf2 = ADDR_PPERM2(f);
        deg = DEG_PPERM2(f);
        /* loop over the entries of the tuple                              */
        for (i = LEN_LIST(set); 1 <= i; i--, ptset--) {
            k = INT_INTOBJ(*ptset);
            if (k <= deg && ptf2[k - 1] != 0) {
                tmp = INTOBJ_INT(ptf2[k - 1]);
                len++;
                *ptres++ = tmp;
            }
        }
    }
    else {
        ptf4 = ADDR_PPERM4(f);
        deg = DEG_PPERM4(f);
        /* loop over the entries of the tuple                              */
        for (i = LEN_LIST(set); 1 <= i; i--, ptset--) {
            k = INT_INTOBJ(*ptset);
            if (k <= deg && ptf4[k - 1] != 0) {
                tmp = INTOBJ_INT(ptf4[k - 1]);
                len++;
                *ptres++ = tmp;
            }
        }
    }
    ResizeBag(res, (len + 1) * sizeof(Obj));
    SET_LEN_PLIST(res, len);

    if (len == 0) {
        RetypeBag(res, IS_MUTABLE_PLIST(set) ? T_PLIST_EMPTY
                                             : T_PLIST_EMPTY + IMMUTABLE);
        return res;
    }

    /* sort the result */
    h = 1;
    while (9 * h + 4 < len)
        h = 3 * h + 1;
    while (0 < h) {
        for (i = h + 1; i <= len; i++) {
            tmp = CONST_ADDR_OBJ(res)[i];
            k = i;
            while (h < k && ((Int)tmp < (Int)(CONST_ADDR_OBJ(res)[k - h]))) {
                ADDR_OBJ(res)[k] = CONST_ADDR_OBJ(res)[k - h];
                k -= h;
            }
            ADDR_OBJ(res)[k] = tmp;
        }
        h = h / 3;
    }

    /* retype if we only have integers */
    return res;
}

/****************************************************************************/
/****************************************************************************/

/* other internal things */

/* Save and load */
void SavePPerm2(Obj f)
{
    UInt2 * ptr;
    UInt    len, i;
    len = DEG_PPERM2(f);
    ptr = ADDR_PPERM2(f) - 1;
    for (i = 0; i < len + 1; i++)
        SaveUInt2(*ptr++);
}

void LoadPPerm2(Obj f)
{
    UInt2 * ptr;
    UInt    len, i;
    len = DEG_PPERM2(f);
    ptr = ADDR_PPERM2(f) - 1;
    for (i = 0; i < len + 1; i++)
        *ptr++ = LoadUInt2();
}

void SavePPerm4(Obj f)
{
    UInt4 * ptr;
    UInt    len, i;
    len = DEG_PPERM4(f);
    ptr = ADDR_PPERM4(f) - 1;
    for (i = 0; i < len + 1; i++)
        SaveUInt4(*ptr++);
}

void LoadPPerm4(Obj f)
{
    UInt4 * ptr;
    UInt    len, i;
    len = DEG_PPERM4(f);
    ptr = ADDR_PPERM4(f) - 1;
    for (i = 0; i < len + 1; i++)
        *ptr++ = LoadUInt4();
}

Obj TYPE_PPERM2;

Obj TypePPerm2(Obj f)
{
    return TYPE_PPERM2;
}

Obj TYPE_PPERM4;

Obj TypePPerm4(Obj f)
{
    return TYPE_PPERM4;
}

Obj IsPPermFilt;

Obj IsPPermHandler(Obj self, Obj val)
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

/*F * * * * * * * * * * * * initialize package * * * * * * * * * * * * * *
 */

/**************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts[] = {

    { "IS_PPERM", "obj", &IsPPermFilt, IsPPermHandler,
      "src/pperm.c:IS_PPERM" },

    { 0, 0, 0, 0, 0 }

};

/****************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(EmptyPartialPerm, 0, ""),
    GVAR_FUNC(DensePartialPermNC, 1, "img"),
    GVAR_FUNC(SparsePartialPermNC, 2, "dom, img"),
    GVAR_FUNC(DegreeOfPartialPerm, 1, "f"),
    GVAR_FUNC(CoDegreeOfPartialPerm, 1, "f"),
    GVAR_FUNC(RankOfPartialPerm, 1, "f"),
    GVAR_FUNC(IMAGE_PPERM, 1, "f"),
    GVAR_FUNC(DOMAIN_PPERM, 1, "f"),
    GVAR_FUNC(IMAGE_SET_PPERM, 1, "f"),
    GVAR_FUNC(PREIMAGE_PPERM_INT, 2, "f, i"),
    GVAR_FUNC(INDEX_PERIOD_PPERM, 1, "f"),
    GVAR_FUNC(SMALLEST_IDEM_POW_PPERM, 1, "f"),
    GVAR_FUNC(COMPONENT_REPS_PPERM, 1, "f"),
    GVAR_FUNC(NR_COMPONENTS_PPERM, 1, "f"),
    GVAR_FUNC(COMPONENTS_PPERM, 1, "f"),
    GVAR_FUNC(COMPONENT_PPERM_INT, 2, "f, pt"),
    GVAR_FUNC(FIXED_PTS_PPERM, 1, "f"),
    GVAR_FUNC(NR_FIXED_PTS_PPERM, 1, "f"),
    GVAR_FUNC(MOVED_PTS_PPERM, 1, "f"),
    GVAR_FUNC(NR_MOVED_PTS_PPERM, 1, "f"),
    GVAR_FUNC(LARGEST_MOVED_PT_PPERM, 1, "f"),
    GVAR_FUNC(SMALLEST_MOVED_PT_PPERM, 1, "f"),
    GVAR_FUNC(TRIM_PPERM, 1, "f"),
    GVAR_FUNC(HASH_FUNC_FOR_PPERM, 2, "f, data"),
    GVAR_FUNC(IS_IDEM_PPERM, 1, "f"),
    GVAR_FUNC(LEFT_ONE_PPERM, 1, "f"),
    GVAR_FUNC(RIGHT_ONE_PPERM, 1, "f"),
    GVAR_FUNC(NaturalLeqPartialPerm, 2, "f, g"),
    GVAR_FUNC(JOIN_PPERMS, 2, "f, g"),
    GVAR_FUNC(JOIN_IDEM_PPERMS, 2, "f, g"),
    GVAR_FUNC(MEET_PPERMS, 2, "f, g"),
    GVAR_FUNC(RESTRICTED_PPERM, 2, "f, g"),
    GVAR_FUNC(AS_PPERM_PERM, 2, "p, set"),
    GVAR_FUNC(AS_PERM_PPERM, 1, "f"),
    GVAR_FUNC(PERM_LEFT_QUO_PPERM_NC, 2, "f, g"),
    GVAR_FUNC(ShortLexLeqPartialPerm, 2, "f, g"),
    GVAR_FUNC(HAS_DOM_PPERM, 1, "f"),
    GVAR_FUNC(HAS_IMG_PPERM, 1, "f"),
    GVAR_FUNC(OnPosIntSetsPartialPerm, 2, "set, f"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{

    /* install the marking function                                        */
    InfoBags[T_PPERM2].name = "partial perm (small)";
    InfoBags[T_PPERM4].name = "partial perm (large)";
    InitMarkFuncBags(T_PPERM2, MarkTwoSubBags);
    InitMarkFuncBags(T_PPERM4, MarkTwoSubBags);

    MakeBagTypePublic(T_PPERM2);
    MakeBagTypePublic(T_PPERM4);

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

    /* install the saving functions */
    SaveObjFuncs[T_PPERM2] = SavePPerm2;
    LoadObjFuncs[T_PPERM2] = LoadPPerm2;
    SaveObjFuncs[T_PPERM4] = SavePPerm4;
    LoadObjFuncs[T_PPERM4] = LoadPPerm4;

    /* install the comparison methods                                      */
    EqFuncs[T_PPERM2][T_PPERM2] = EqPPerm22;
    EqFuncs[T_PPERM4][T_PPERM4] = EqPPerm44;
    EqFuncs[T_PPERM4][T_PPERM2] = EqPPerm42;
    EqFuncs[T_PPERM2][T_PPERM4] = EqPPerm24;
    LtFuncs[T_PPERM2][T_PPERM2] = LtPPerm22;
    LtFuncs[T_PPERM4][T_PPERM4] = LtPPerm44;
    LtFuncs[T_PPERM2][T_PPERM4] = LtPPerm24;
    LtFuncs[T_PPERM4][T_PPERM2] = LtPPerm42;

    /* install the binary operations */
    ProdFuncs[T_PPERM2][T_PPERM2] = ProdPPerm22;
    ProdFuncs[T_PPERM4][T_PPERM2] = ProdPPerm42;
    ProdFuncs[T_PPERM2][T_PPERM4] = ProdPPerm24;
    ProdFuncs[T_PPERM4][T_PPERM4] = ProdPPerm44;
    ProdFuncs[T_PPERM2][T_PERM2] = ProdPPerm2Perm2;
    ProdFuncs[T_PPERM4][T_PERM4] = ProdPPerm4Perm4;
    ProdFuncs[T_PPERM2][T_PERM4] = ProdPPerm2Perm4;
    ProdFuncs[T_PPERM4][T_PERM2] = ProdPPerm4Perm2;
    ProdFuncs[T_PERM2][T_PPERM2] = ProdPerm2PPerm2;
    ProdFuncs[T_PERM4][T_PPERM4] = ProdPerm4PPerm4;
    ProdFuncs[T_PERM4][T_PPERM2] = ProdPerm4PPerm2;
    ProdFuncs[T_PERM2][T_PPERM4] = ProdPerm2PPerm4;
    PowFuncs[T_INT][T_PPERM2] = PowIntPPerm2;
    PowFuncs[T_INT][T_PPERM4] = PowIntPPerm4;
    PowFuncs[T_PPERM2][T_PERM2] = PowPPerm2Perm2;
    PowFuncs[T_PPERM2][T_PERM4] = PowPPerm2Perm4;
    PowFuncs[T_PPERM4][T_PERM2] = PowPPerm4Perm2;
    PowFuncs[T_PPERM4][T_PERM4] = PowPPerm4Perm4;
    PowFuncs[T_PPERM2][T_PPERM2] = PowPPerm22;
    PowFuncs[T_PPERM2][T_PPERM4] = PowPPerm24;
    PowFuncs[T_PPERM4][T_PPERM2] = PowPPerm42;
    PowFuncs[T_PPERM4][T_PPERM4] = PowPPerm44;
    QuoFuncs[T_PPERM2][T_PERM2] = QuoPPerm2Perm2;
    QuoFuncs[T_PPERM4][T_PERM4] = QuoPPerm4Perm4;
    QuoFuncs[T_PPERM2][T_PERM4] = QuoPPerm2Perm4;
    QuoFuncs[T_PPERM4][T_PERM2] = QuoPPerm4Perm2;
    QuoFuncs[T_PPERM2][T_PPERM2] = QuoPPerm22;
    QuoFuncs[T_PPERM2][T_PPERM4] = QuoPPerm24;
    QuoFuncs[T_PPERM4][T_PPERM2] = QuoPPerm42;
    QuoFuncs[T_PPERM4][T_PPERM4] = QuoPPerm44;
    QuoFuncs[T_INT][T_PPERM2] = PreImagePPermInt;
    QuoFuncs[T_INT][T_PPERM4] = PreImagePPermInt;
    LQuoFuncs[T_PERM2][T_PPERM2] = LQuoPerm2PPerm2;
    LQuoFuncs[T_PERM2][T_PPERM4] = LQuoPerm2PPerm4;
    LQuoFuncs[T_PERM4][T_PPERM2] = LQuoPerm4PPerm2;
    LQuoFuncs[T_PERM4][T_PPERM4] = LQuoPerm4PPerm4;
    LQuoFuncs[T_PPERM2][T_PPERM2] = LQuoPPerm22;
    LQuoFuncs[T_PPERM2][T_PPERM4] = LQuoPPerm24;
    LQuoFuncs[T_PPERM4][T_PPERM2] = LQuoPPerm42;
    LQuoFuncs[T_PPERM4][T_PPERM4] = LQuoPPerm44;

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

    /* return success                                                      */
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

    /* return success                                                      */
    return 0;
}


static void InitModuleState(ModuleStateOffset offset)
{
    TmpPPerm = 0;
}


/**************************************************************************
 **
 *F InitInfoPPerm()   . . . . . . . . . . . . . . . table of init functions
 */
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "pperm",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoPPerm(void)
{
    PPermStateOffset = RegisterModuleState(sizeof(PPermModuleState), InitModuleState, 0);
    return &module;
}
