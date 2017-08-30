/*****************************************************************************
*
* A transformation <f> has internal representation as follows:
*
* [Obj* image set, Obj* flat kernel, Obj* external degree,
*  entries image list]
*
* The <internal degree> of <f> is just the length of <entries image
* list>, this is accessed here using <DEG_TRANS2> and <DEG_TRANS4>, in
* GAP it can be accessed using INT_DEG_TRANS (for debugging purposes
* only).
*
* Transformations must always have internal degree greater than or equal
* to the largest point in <entries image list>.
*
* An element of <entries image list> of a transformation in T_TRANS2
* must be at most 65535 and be UInt2. Hence the internal and external
* degrees of a T_TRANS2 are at most 65536. If <f> is T_TRANS4, then the
* elements of <entries image list> must be UInt4. The degree of a
* T_TRANS4 must be 65537 or higher, i.e. do not call NEW_TRANS4(n) when
* n < 65537.
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

#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling,
                                           initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/bool.h>                   /* booleans */

#include <src/gmpints.h>                /* integers */
#include <src/intfuncs.h>               /* hashing */

#include <src/permutat.h>               /* permutations */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/listfunc.h>               /* functions for lists */
#include <src/plist.h>                  /* plain lists */

#include <src/saveload.h>               /* saving and loading */

#include <src/set.h>                    /* sets */

#include <src/code.h>                   /* coder */
#include <src/hpc/guards.h>

#include <src/trans.h>                  /* transformations */
#include <assert.h>

#define MIN(a, b) (a < b ? a : b)
#define MAX(a, b) (a < b ? b : a)

// TmpTrans is the same as TmpPerm
#define TmpTrans STATE(TmpTrans)

/* mp this will become a ReadOnly object? */
Obj IdentityTrans;

/*******************************************************************************
** Forward declarations
*******************************************************************************/

Obj FuncIMAGE_SET_TRANS(Obj self, Obj f);

/*******************************************************************************
** Internal functions for transformations
*******************************************************************************/

static inline Obj IMG_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return ADDR_OBJ(f)[0];
}

static inline Obj KER_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return ADDR_OBJ(f)[1];
}

static inline Obj EXT_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return ADDR_OBJ(f)[2];
}

static inline void SET_IMG_TRANS(Obj f, Obj img)
{
    GAP_ASSERT(IS_TRANS(f));
    GAP_ASSERT(img == NULL || (IS_PLIST(img) && !IS_MUTABLE_PLIST(img)));
    ADDR_OBJ(f)[0] = img;
}

static inline void SET_KER_TRANS(Obj f, Obj ker)
{
    GAP_ASSERT(IS_TRANS(f));
    GAP_ASSERT(ker == NULL || (IS_PLIST(ker) && !IS_MUTABLE_PLIST(ker) &&
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
    if (TmpTrans == (Obj)0) {
        TmpTrans = NewBag(T_TRANS4, len * sizeof(UInt4) + 3 * sizeof(Obj));
    }
    else if (SIZE_OBJ(TmpTrans) < len * sizeof(UInt4) + 3 * sizeof(Obj)) {
        ResizeBag(TmpTrans, len * sizeof(UInt4) + 3 * sizeof(Obj));
    }
}

static inline UInt4 * ResizeInitTmpTrans(UInt len)
{
    UInt    i;
    UInt4 * pttmp;

    if (TmpTrans == (Obj)0) {
        TmpTrans = NewBag(T_TRANS4, len * sizeof(UInt4) + 3 * sizeof(Obj));
    }
    else if (SIZE_BAG(TmpTrans) < len * sizeof(UInt4) + 3 * sizeof(Obj)) {
        ResizeBag(TmpTrans, len * sizeof(UInt4) + 3 * sizeof(Obj));
    }

    pttmp = ADDR_TRANS4(TmpTrans);
    for (i = 0; i < len; i++) {
        pttmp[i] = 0;
    }
    return pttmp;
}

// Find the rank, flat kernel, and image set (unsorted) of a transformation of
// degree at most 65536.

UInt INIT_TRANS2(Obj f)
{
    UInt    deg, rank, i, j;
    UInt2 * ptf;
    UInt4 * pttmp;
    Obj     img, ker;

    deg = DEG_TRANS2(f);

    if (deg == 0) {
        // special case for degree 0
        img = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
        SET_LEN_PLIST(img, 0);
        SET_IMG_TRANS(f, img);
        SET_KER_TRANS(f, img);
        CHANGED_BAG(f);
        return 0;
    }

    img = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, deg);
    ker = NEW_PLIST(T_PLIST_CYC_NSORT + IMMUTABLE, deg);
    SET_LEN_PLIST(ker, (Int)deg);

    pttmp = ResizeInitTmpTrans(deg);
    ptf = ADDR_TRANS2(f);

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

UInt INIT_TRANS4(Obj f)
{
    UInt    deg, rank, i, j;
    UInt4 * ptf;
    UInt4 * pttmp;
    Obj     img, ker;

    deg = DEG_TRANS4(f);

    if (deg == 0) {
        // Special case for degree 0.

        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        img = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
        SET_LEN_PLIST(img, 0);
        SET_IMG_TRANS(f, img);
        SET_KER_TRANS(f, img);
        CHANGED_BAG(f);
        return 0;
    }

    img = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, deg);
    ker = NEW_PLIST(T_PLIST_CYC_NSORT + IMMUTABLE, deg);
    SET_LEN_PLIST(ker, (Int)deg);

    pttmp = ResizeInitTmpTrans(deg);
    ptf = ADDR_TRANS4(f);

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

// TODO should this use the newer sorting algorithm by CAJ in PR #609?
//
// Retyping is the responsibility of the caller.

static void SORT_PLIST_CYC(Obj res)
{
    Obj  tmp;
    UInt h, i, k, len;

    len = LEN_PLIST(res);

    if (0 < len) {
        h = 1;
        while (9 * h + 4 < len) {
            h = 3 * h + 1;
        }
        while (0 < h) {
            for (i = h + 1; i <= len; i++) {
                tmp = ADDR_OBJ(res)[i];
                k = i;
                while (h < k && ((Int)tmp < (Int)(ADDR_OBJ(res)[k - h]))) {
                    ADDR_OBJ(res)[k] = ADDR_OBJ(res)[k - h];
                    k -= h;
                }
                ADDR_OBJ(res)[k] = tmp;
            }
            h = h / 3;
        }
        CHANGED_BAG(res);
    }
}

// Retyping is the responsibility of the caller, this should only be called
// after a call to SORT_PLIST_CYC.

static void REMOVE_DUPS_PLIST_CYC(Obj res)
{
    Obj  tmp;
    UInt i, k, len;

    len = LEN_PLIST(res);

    if (0 < len) {
        tmp = ADDR_OBJ(res)[1];
        k = 1;
        for (i = 2; i <= len; i++) {
            if (tmp != ADDR_OBJ(res)[i]) {
                k++;
                tmp = ADDR_OBJ(res)[i];
                ADDR_OBJ(res)[k] = tmp;
            }
        }
        if (k < len) {
            ResizeBag(res, (k + 1) * sizeof(Obj));
            SET_LEN_PLIST(res, k);
        }
    }
}

/*******************************************************************************
** GAP level functions for debugging purposes only
*******************************************************************************/

/*
Obj FuncHAS_KER_TRANS (Obj self, Obj f) {
  if (IS_TRANS(f)) {
    return (KER_TRANS(f) == NULL?False:True);
  } else {
    return Fail;
  }
}

Obj FuncHAS_IMG_TRANS (Obj self, Obj f) {
  if (IS_TRANS(f)) {
    return (IMG_TRANS(f) == NULL?False:True);
  } else {
    return Fail;
  }
}

Obj FuncINT_DEG_TRANS (Obj self, Obj f) {
  if (TNUM_OBJ(f) == T_TRANS2) {
    return INTOBJ_INT(DEG_TRANS2(f));
  } else if (TNUM_OBJ(f) == T_TRANS4) {
    return INTOBJ_INT(DEG_TRANS4(f));
  }
  return Fail;
}*/

/*******************************************************************************
** GAP level functions for creating transformations
*******************************************************************************/

// Returns a transformation with list of images <list>, this does not check
// that <list> is really a list or that its entries define a transformation.

Obj FuncTransformationNC(Obj self, Obj list)
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

Obj FuncTransformationListListNC(Obj self, Obj src, Obj ran)
{
    Int     deg, i, s, r;
    Obj     f;
    UInt2 * ptf2;
    UInt4 * ptf4;

    if (!IS_SMALL_LIST(src)) {
        ErrorQuit("TransformationListListNC: <src> must be a list (not a %s)",
                  (Int)TNAM_OBJ(src), 0L);
    }
    if (!IS_SMALL_LIST(ran)) {
        ErrorQuit("TransformationListListNC: <ran> must be a list (not a %s)",
                  (Int)TNAM_OBJ(ran), 0L);
    }
    if (LEN_LIST(src) != LEN_LIST(ran)) {
        ErrorQuit("TransformationListListNC: <src> and <ran> must have equal "
                  "length,",
                  0L, 0L);
    }

    deg = 0;
    for (i = LEN_LIST(src); 1 <= i; i--) {
        if (!IS_INTOBJ(ELM_LIST(src, i))) {
            ErrorQuit("TransformationListListNC: <src>[%d] must be a small "
                      "integer (not a "
                      "%s)",
                      (Int)i, (Int)TNAM_OBJ(ELM_LIST(src, i)));
        }
        s = INT_INTOBJ(ELM_LIST(src, i));
        if (s < 1) {
            ErrorQuit(
                "TransformationListListNC: <src>[%d] must be greater than 0",
                (Int)i, 0L);
        }

        if (!IS_INTOBJ(ELM_LIST(ran, i))) {
            ErrorQuit("TransformationListListNC: <ran>[%d] must be a small "
                      "integer (not a "
                      "%s)",
                      (Int)i, (Int)TNAM_OBJ(ELM_LIST(ran, i)));
        }
        r = INT_INTOBJ(ELM_LIST(ran, i));
        if (r < 1) {
            ErrorQuit(
                "TransformationListListNC: <ran>[%d] must be greater than 0",
                (Int)i, 0L);
        }

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
            ptf2[INT_INTOBJ(ELM_LIST(src, i)) - 1] =
                INT_INTOBJ(ELM_LIST(ran, i)) - 1;
        }
    }
    else {
        f = NEW_TRANS4(deg);
        ptf4 = ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            ptf4[i] = i;
        }
        for (i = LEN_LIST(src); 1 <= i; i--) {
            ptf4[INT_INTOBJ(ELM_LIST(src, i)) - 1] =
                INT_INTOBJ(ELM_LIST(ran, i)) - 1;
        }
    }
    return f;
}

// Returns a transformation with image <img> and flat kernel <ker> under the
// (unchecked) assumption that the arguments are valid and that there is such
// a transformation, i.e.  that the maximum value in <ker> equals the length
// of <img>.

Obj FuncTRANS_IMG_KER_NC(Obj self, Obj img, Obj ker)
{
    Obj     f, copy_img, copy_ker;
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i, pos, deg;

    copy_img = SHALLOW_COPY_OBJ(img);
    copy_ker = SHALLOW_COPY_OBJ(ker);

    if (!IS_PLIST(copy_img)) {
        PLAIN_LIST(copy_img);
    }
    if (!IS_PLIST(copy_ker)) {
        PLAIN_LIST(copy_ker);
    }
    if (IS_MUTABLE_OBJ(copy_img)) {
        RetypeBag(copy_img, TNUM_OBJ(copy_img) + IMMUTABLE);
    }
    if (IS_MUTABLE_OBJ(copy_ker)) {
        RetypeBag(copy_ker, TNUM_OBJ(copy_ker) + IMMUTABLE);
    }

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

Obj FuncIDEM_IMG_KER_NC(Obj self, Obj img, Obj ker)
{
    Obj     f, copy_img, copy_ker;
    UInt2 * ptf2;
    UInt4 * ptf4, *pttmp;
    UInt    i, j, deg, rank;

    copy_img = SHALLOW_COPY_OBJ(img);
    copy_ker = SHALLOW_COPY_OBJ(ker);

    if (!IS_PLIST(copy_img)) {
        PLAIN_LIST(copy_img);
    }
    if (!IS_PLIST(copy_ker)) {
        PLAIN_LIST(copy_ker);
    }
    if (IS_MUTABLE_OBJ(copy_img)) {
        RetypeBag(copy_img, TNUM_OBJ(copy_img) + IMMUTABLE);
    }
    if (IS_MUTABLE_OBJ(copy_ker)) {
        RetypeBag(copy_ker, TNUM_OBJ(copy_ker) + IMMUTABLE);
    }

    deg = LEN_LIST(copy_ker);
    rank = LEN_LIST(copy_img);
    ResizeTmpTrans(deg);
    pttmp = ADDR_TRANS4(TmpTrans);

    // setup the lookup table
    for (i = 0; i < rank; i++) {
        j = INT_INTOBJ(ELM_PLIST(copy_img, i + 1));
        pttmp[INT_INTOBJ(ELM_PLIST(copy_ker, j)) - 1] = j - 1;
    }
    if (deg <= 65536) {
        f = NEW_TRANS2(deg);
        ptf2 = ADDR_TRANS2(f);
        pttmp = ADDR_TRANS4(TmpTrans);

        for (i = 0; i < deg; i++) {
            ptf2[i] = pttmp[INT_INTOBJ(ELM_PLIST(copy_ker, i + 1)) - 1];
        }
    }
    else {
        f = NEW_TRANS4(deg);
        ptf4 = ADDR_TRANS4(f);
        pttmp = ADDR_TRANS4(TmpTrans);

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

Obj FuncLEFT_ONE_TRANS(Obj self, Obj f)
{
    Obj  ker, img;
    UInt rank, n, i;

    if (TNUM_OBJ(f) == T_TRANS2) {
        rank = RANK_TRANS2(f);
        ker = KER_TRANS(f);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        rank = RANK_TRANS4(f);
        ker = KER_TRANS(f);
    }
    else {
        ErrorQuit("LEFT_ONE_TRANS: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
        return 0L;
    }

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

Obj FuncRIGHT_ONE_TRANS(Obj self, Obj f)
{
    Obj  ker, img;
    UInt deg, len, i, j, n;

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        deg = DEG_TRANS4(f);
    }
    else {
        ErrorQuit("RIGHT_ONE_TRANS: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
        return 0L;
    }

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

Obj FuncDegreeOfTransformation(Obj self, Obj f)
{
    UInt    n, i, deg;
    UInt2 * ptf2;
    UInt4 * ptf4;

    if (TNUM_OBJ(f) == T_TRANS2) {
        if (EXT_TRANS(f) == NULL) {
            n = DEG_TRANS2(f);
            ptf2 = ADDR_TRANS2(f);
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
        return EXT_TRANS(f);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        if (EXT_TRANS(f) == NULL) {
            n = DEG_TRANS4(f);
            ptf4 = ADDR_TRANS4(f);
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
        return EXT_TRANS(f);
    }
    ErrorQuit("DegreeOfTransformation: the argument must be a transformation "
              "(not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the rank of transformation, i.e. number of distinct values in
// [(1)f .. (n)f] where n = DegreeOfTransformation(f).

Obj FuncRANK_TRANS(Obj self, Obj f)
{
    if (TNUM_OBJ(f) == T_TRANS2) {
        return SumInt(INTOBJ_INT(RANK_TRANS2(f) - DEG_TRANS2(f)),
                      FuncDegreeOfTransformation(self, f));
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        return SumInt(INTOBJ_INT(RANK_TRANS4(f) - DEG_TRANS4(f)),
                      FuncDegreeOfTransformation(self, f));
    }
    ErrorQuit("RANK_TRANS: the argument must be a transformation "
              "(not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the rank of the transformation <f> on [1 .. n], i.e. the number of
// distinct values in [(1)f .. (n)f].

Obj FuncRANK_TRANS_INT(Obj self, Obj f, Obj n)
{
    UInt    rank, i, m;
    UInt2 * ptf2;
    UInt4 * pttmp, *ptf4;

    if (!IS_INTOBJ(n) || INT_INTOBJ(n) < 0) {
        ErrorQuit("RANK_TRANS_INT: <n> must be a non-negative integer", 0L,
                  0L);
        return 0L;
    }

    m = INT_INTOBJ(n);
    if (TNUM_OBJ(f) == T_TRANS2) {
        if (m >= DEG_TRANS2(f)) {
            return INTOBJ_INT(RANK_TRANS2(f) - DEG_TRANS2(f) + m);
        }
        else {
            pttmp = ResizeInitTmpTrans(DEG_TRANS2(f));
            ptf2 = ADDR_TRANS2(f);
            rank = 0;
            for (i = 0; i < m; i++) {
                if (pttmp[ptf2[i]] == 0) {
                    rank++;
                    pttmp[ptf2[i]] = 1;
                }
            }
            return INTOBJ_INT(rank);
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        if (m >= DEG_TRANS4(f)) {
            return INTOBJ_INT(RANK_TRANS4(f) - DEG_TRANS4(f) + m);
        }
        else {
            pttmp = ResizeInitTmpTrans(DEG_TRANS4(f));
            ptf4 = ADDR_TRANS4(f);
            rank = 0;
            for (i = 0; i < m; i++) {
                if (pttmp[ptf4[i]] == 0) {
                    rank++;
                    pttmp[ptf4[i]] = 1;
                }
            }
            return INTOBJ_INT(rank);
        }
    }
    ErrorQuit("RANK_TRANS_INT: <f> must be a transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the rank of the transformation <f> on the <list>, i.e. the number
// of
// distinct values in [(list[1])f .. (list[n])f], where <list> consists of
// positive ints.

Obj FuncRANK_TRANS_LIST(Obj self, Obj f, Obj list)
{
    UInt    rank, i, j, len, def;
    UInt2 * ptf2;
    UInt4 * pttmp, *ptf4;
    Obj     pt;

    if (!IS_LIST(list)) {
        ErrorQuit("RANK_TRANS_LIST: the second argument must be a list "
                  "(not a %s)",
                  (Int)TNAM_OBJ(list), 0L);
    }

    len = LEN_LIST(list);
    if (TNUM_OBJ(f) == T_TRANS2) {
        def = DEG_TRANS2(f);
        pttmp = ResizeInitTmpTrans(def);
        ptf2 = ADDR_TRANS2(f);
        rank = 0;
        for (i = 1; i <= len; i++) {
            pt = ELM_LIST(list, i);
            if (!IS_INTOBJ(pt) || INT_INTOBJ(pt) < 1) {
                ErrorQuit(
                    "RANK_TRANS_LIST: the second argument <list> must be a "
                    "list of positive integers (not a %s)",
                    (Int)TNAM_OBJ(pt), 0L);
            }
            j = INT_INTOBJ(pt) - 1;
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
        return INTOBJ_INT(rank);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        def = DEG_TRANS4(f);
        pttmp = ResizeInitTmpTrans(def);
        ptf4 = ADDR_TRANS4(f);
        rank = 0;
        for (i = 1; i <= len; i++) {
            pt = ELM_LIST(list, i);
            if (!IS_INTOBJ(pt) || INT_INTOBJ(pt) < 1) {
                ErrorQuit(
                    "RANK_TRANS_LIST: the second argument <list> must be a "
                    "list of positive integers (not a %s)",
                    (Int)TNAM_OBJ(pt), 0L);
            }
            j = INT_INTOBJ(pt) - 1;
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
        return INTOBJ_INT(rank);
    }

    ErrorQuit("RANK_TRANS_LIST: the first argument must be a transformation "
              "(not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

/*******************************************************************************
** GAP level functions for the kernel and preimages of a transformation
*******************************************************************************/

// Returns the flat kernel of transformation on
// [1 .. DegreeOfTransformation(f)].

Obj FuncFLAT_KERNEL_TRANS(Obj self, Obj f)
{

    if (TNUM_OBJ(f) == T_TRANS2) {
        if (KER_TRANS(f) == NULL) {
            INIT_TRANS2(f);
        }
        return KER_TRANS(f);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        if (KER_TRANS(f) == NULL) {
            INIT_TRANS4(f);
        }
        return KER_TRANS(f);
    }

    ErrorQuit("FLAT_KERNEL_TRANS: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the flat kernel of the transformation <f> on [1 .. n].

Obj FuncFLAT_KERNEL_TRANS_INT(Obj self, Obj f, Obj n)
{
    Obj new, *ptnew, *ptker;
    UInt deg, m, i;

    if (!IS_INTOBJ(n) || INT_INTOBJ(n) < 0) {
        ErrorQuit("FLAT_KERNEL_TRANS_INT: the second argument must be a "
                  "non-negative integer",
                  0L, 0L);
    }

    m = INT_INTOBJ(n);
    if (TNUM_OBJ(f) == T_TRANS2) {
        if (KER_TRANS(f) == NULL) {
            INIT_TRANS2(f);
        }
        deg = DEG_TRANS2(f);
        if (m == deg) {
            return KER_TRANS(f);
        }
        else if (m == 0) {
            new = NEW_PLIST(T_PLIST_EMPTY, 0);
            SET_LEN_PLIST(new, 0);
            return new;
        }
        else {
            new = NEW_PLIST(T_PLIST_CYC_NSORT, m);
            SET_LEN_PLIST(new, m);

            ptker = ADDR_OBJ(KER_TRANS(f)) + 1;
            ptnew = ADDR_OBJ(new) + 1;

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
                    *ptnew++ = INTOBJ_INT(i + RANK_TRANS2(f));
                }
            }
            return new;
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {

        if (KER_TRANS(f) == NULL) {
            INIT_TRANS4(f);
        }
        deg = DEG_TRANS4(f);
        if (m == deg) {
            return KER_TRANS(f);
        }
        else if (m == 0) {
            new = NEW_PLIST(T_PLIST_EMPTY, 0);
            SET_LEN_PLIST(new, 0);
            return new;
        }
        else {
            new = NEW_PLIST(T_PLIST_CYC_NSORT, m);
            SET_LEN_PLIST(new, m);

            ptker = ADDR_OBJ(KER_TRANS(f)) + 1;
            ptnew = ADDR_OBJ(new) + 1;

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
                    *ptnew++ = INTOBJ_INT(i + RANK_TRANS4(f));
                }
            }
            return new;
        }
    }
    ErrorQuit("FLAT_KERNEL_TRANS_INT: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the kernel of a transformation <f> as a partition of [1 .. n].

Obj FuncKERNEL_TRANS(Obj self, Obj f, Obj n)
{
    Obj     ker;
    UInt    i, j, deg, nr, m, rank, min;
    UInt4 * pttmp;

    if (!IS_INTOBJ(n) || INT_INTOBJ(n) < 0) {
        ErrorQuit("KERNEL_TRANS: the second argument must be a "
                  "non-negative integer",
                  0L, 0L);
    }
    else if (!IS_TRANS(f)) {
        ErrorQuit("KERNEL_TRANS: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    m = INT_INTOBJ(n);

    // special case for the identity
    if (m == 0) {
        ker = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(ker, 0);
        return ker;
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
            pttmp = ADDR_TRANS4(TmpTrans);
        }
        AssPlist(ELM_PLIST(ker, j), (Int)++pttmp[j - 1], INTOBJ_INT(i + 1));
        pttmp = ADDR_TRANS4(TmpTrans);
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

Obj FuncPREIMAGES_TRANS_INT(Obj self, Obj f, Obj pt)
{
    UInt deg, nr, i, j;
    Obj  out;

    if (!IS_INTOBJ(pt) || INT_INTOBJ(pt) < 1) {
        ErrorQuit("PREIMAGES_TRANS_INT: the second argument must be a "
                  "positive integer",
                  0L, 0L);
    }
    else if (!IS_TRANS(f)) {
        ErrorQuit("PREIMAGES_TRANS_INT: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    deg = DEG_TRANS(f);

    if ((UInt)INT_INTOBJ(pt) > deg) {
        out = NEW_PLIST(T_PLIST_CYC, 1);
        SET_LEN_PLIST(out, 1);
        SET_ELM_PLIST(out, 1, pt);
        return out;
    }

    i = INT_INTOBJ(pt) - 1;
    out = NEW_PLIST(T_PLIST_CYC_SSORT, 0);
    nr = 0;

    if (TNUM_OBJ(f) == T_TRANS2) {
        for (j = 0; j < deg; j++) {
            if ((ADDR_TRANS2(f))[j] == i) {
                AssPlist(out, ++nr, INTOBJ_INT(j + 1));
            }
        }
    }
    else {
        for (j = 0; j < deg; j++) {
            if ((ADDR_TRANS4(f))[j] == i) {
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

Obj FuncUNSORTED_IMAGE_SET_TRANS(Obj self, Obj f)
{

    if (TNUM_OBJ(f) == T_TRANS2) {
        if (IMG_TRANS(f) == NULL) {
            INIT_TRANS2(f);
        }
        return IMG_TRANS(f);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        if (IMG_TRANS(f) == NULL) {
            INIT_TRANS4(f);
        }
        return IMG_TRANS(f);
    }
    ErrorQuit("UNSORTED_IMAGE_SET_TRANS: the argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the image set of the transformation f on [1 .. n] where n =
// DegreeOfTransformation(f).

Obj FuncIMAGE_SET_TRANS(Obj self, Obj f)
{

    Obj out = FuncUNSORTED_IMAGE_SET_TRANS(self, f);

    if (!IS_SSORT_LIST(out)) {
        SORT_PLIST_CYC(out);
        RetypeBag(out, T_PLIST_CYC_SSORT + IMMUTABLE);
        CHANGED_BAG(out);
        return out;
    }
    return out;
}

// Returns the image set of the transformation f on [1 .. n].

Obj FuncIMAGE_SET_TRANS_INT(Obj self, Obj f, Obj n)
{
    Obj     im, new;
    UInt    deg, m, len, i, j, rank;
    Obj *   ptnew, *ptim;
    UInt4 * pttmp, *ptf4;
    UInt2 * ptf2;

    if (!IS_INTOBJ(n) || INT_INTOBJ(n) < 0) {
        ErrorQuit("IMAGE_SET_TRANS_INT: the second argument must be a "
                  "non-negative integer",
                  0L, 0L);
    }
    else if (!IS_TRANS(f)) {
        ErrorQuit("IMAGE_SET_TRANS_INT: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    m = INT_INTOBJ(n);
    deg = DEG_TRANS(f);

    if (m == deg) {
        return FuncIMAGE_SET_TRANS(self, f);
    }
    else if (m == 0) {
        new = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
        SET_LEN_PLIST(new, 0);
        return new;
    }
    else if (m < deg) {
        pttmp = ResizeInitTmpTrans(deg);
        new = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, m);
        pttmp = ADDR_TRANS4(TmpTrans);

        if (TNUM_OBJ(f) == T_TRANS2) {
            ptf2 = ADDR_TRANS2(f);
            rank = 0;
            for (i = 0; i < m; i++) {
                j = ptf2[i];
                if (pttmp[j] == 0) {
                    pttmp[j] = ++rank;
                    SET_ELM_PLIST(new, rank, INTOBJ_INT(j + 1));
                }
            }
        }
        else {
            ptf4 = ADDR_TRANS4(f);
            rank = 0;
            for (i = 0; i < m; i++) {
                j = ptf4[i];
                if (pttmp[j] == 0) {
                    pttmp[j] = ++rank;
                    SET_ELM_PLIST(new, rank, INTOBJ_INT(j + 1));
                }
            }
        }
        SHRINK_PLIST(new, (Int)rank);
        SET_LEN_PLIST(new, (Int)rank);
        SORT_PLIST_CYC(new);
        RetypeBag(new, T_PLIST_CYC_SSORT);
        CHANGED_BAG(new);
    }
    else {
        // m > deg and so m is at least 1!
        im = FuncIMAGE_SET_TRANS(self, f);
        len = LEN_PLIST(im);
        new = NEW_PLIST(T_PLIST_CYC_SSORT, m - deg + len);
        SET_LEN_PLIST(new, m - deg + len);

        ptnew = ADDR_OBJ(new) + 1;
        ptim = ADDR_OBJ(im) + 1;

        // copy the image set
        for (i = 0; i < len; i++) {
            *ptnew++ = *ptim++;
        }
        // add new points
        for (i = deg + 1; i <= m; i++) {
            *ptnew++ = INTOBJ_INT(i);
        }
    }
    return new;
}

// Returns the image list [(1)f .. (n)f] of the transformation f.

Obj FuncIMAGE_LIST_TRANS_INT(Obj self, Obj f, Obj n)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i, deg, m;
    Obj     out;

    if (!IS_INTOBJ(n) || INT_INTOBJ(n) < 0) {
        ErrorQuit("IMAGE_LIST_TRANS_INT: the second argument must be a "
                  "non-negative integer",
                  0L, 0L);
    }
    else if (!IS_TRANS(f)) {
        ErrorQuit("IMAGE_LIST_TRANS_INT: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    m = INT_INTOBJ(n);

    if (m == 0) {
        out = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
        SET_LEN_PLIST(out, 0);
        return out;
    }

    out = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, m);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        deg = MIN(DEG_TRANS2(f), m);
        for (i = 0; i < deg; i++) {
            SET_ELM_PLIST(out, i + 1, INTOBJ_INT(ptf2[i] + 1));
        }
    }
    else {
        ptf4 = ADDR_TRANS4(f);
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

Obj FuncIS_ID_TRANS(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg, i;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptf2[i] != i) {
                return False;
            }
        }
        return True;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        ptf4 = ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptf4[i] != i) {
                return False;
            }
        }
        return True;
    }
    ErrorQuit("IS_ID_TRANS: the first argument must be a transformation "
              "(not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns true if the transformation <f> is an idempotent and false if it is
// not.

Obj FuncIS_IDEM_TRANS(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg, i;

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        ptf2 = ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptf2[ptf2[i]] != ptf2[i]) {
                return False;
            }
        }
        return True;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        deg = DEG_TRANS4(f);
        ptf4 = ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptf4[ptf4[i]] != ptf4[i]) {
                return False;
            }
        }
        return True;
    }
    ErrorQuit("IS_IDEM_TRANS: the argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

/*******************************************************************************
** GAP level functions for attributes of transformations
*******************************************************************************/

// Returns the least m and r such that f ^ (m + r) = f ^ m, where f is a
// transformation.

Obj FuncIndexPeriodOfTransformation(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * seen, *ptf4;
    UInt    deg, i, pt, dist, pow, len, last_pt;
    Obj     ord, out;
    Int     s, t, gcd, cyc;

    if (!IS_TRANS(f)) {
        ErrorQuit("IndexPeriodOfTransformation: the argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (deg == 0) {
        out = NEW_PLIST(T_PLIST_CYC, 2);

        SET_LEN_PLIST(out, 2);
        SET_ELM_PLIST(out, 1, INTOBJ_INT(1));
        SET_ELM_PLIST(out, 2, INTOBJ_INT(1));
        return out;
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
        ptf2 = ADDR_TRANS2(f);
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

                    // compute the gcd of the cycle length with the previous
                    // order ord
                    gcd = cyc;
                    s = INT_INTOBJ(ModInt(ord, INTOBJ_INT(cyc)));
                    while (s != 0) {
                        t = s;
                        s = gcd % s;
                        gcd = t;
                    }
                    ord = ProdInt(ord, INTOBJ_INT(cyc / gcd));
                    dist = len - cyc + 1;
                    // the distance of i from the cycle in its component + 1
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
        ptf4 = ADDR_TRANS4(f);
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

                    // compute the gcd of the cycle length with the previous
                    // order ord
                    gcd = cyc;
                    s = INT_INTOBJ(ModInt(ord, INTOBJ_INT(cyc)));
                    while (s != 0) {
                        t = s;
                        s = gcd % s;
                        gcd = t;
                    }
                    ord = ProdInt(ord, INTOBJ_INT(cyc / gcd));
                    dist = len - cyc + 1;
                    // the distance of i from the cycle in its component + 1
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

    out = NEW_PLIST(T_PLIST_CYC, 2);

    SET_LEN_PLIST(out, 2);
    SET_ELM_PLIST(out, 1, INTOBJ_INT(--pow));
    SET_ELM_PLIST(out, 2, ord);
    return out;
}

// Returns the least integer m such that f ^ m is an idempotent.

Obj FuncSMALLEST_IDEM_POW_TRANS(Obj self, Obj f)
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

// Returns True if the transformation or list <t> is injective on the list
// <l>.

Obj FuncIsInjectiveListTrans(Obj self, Obj l, Obj t)
{
    UInt    n, i, j;
    UInt2 * ptt2;
    UInt4 * pttmp = 0L;
    UInt4 * ptt4;
    Obj     val;

    if (!IS_LIST(l)) {
        ErrorQuit("the first argument must be a list (not a %s)",
                  (Int)TNAM_OBJ(l), 0L);
    }
    else if (!IS_TRANS(t) && !IS_LIST(t)) {
        ErrorQuit("the second argument must be a transformation or a list "
                  "(not a %s)",
                  (Int)TNAM_OBJ(t), 0L);
    }
    // init buffer
    n = (IS_TRANS(t) ? DEG_TRANS(t) : LEN_LIST(t));
    pttmp = ResizeInitTmpTrans(n);

    if (TNUM_OBJ(t) == T_TRANS2) {
        ptt2 = ADDR_TRANS2(t);
        for (i = LEN_LIST(l); i >= 1; i--) {
            val = ELM_LIST(l, i);
            if (!IS_POS_INTOBJ(val)) {
                ErrorQuit(
                    "the entries of the first argument must be positive "
                    "integers (not a %s)",
                    (Int)TNAM_OBJ(val), 0L);
            }
            j = INT_INTOBJ(val);
            if (j <= n) {
                if (pttmp[ptt2[j - 1]] != 0) {
                    return False;
                }
                pttmp[ptt2[j - 1]] = 1;
            }
        }
    }
    else if (TNUM_OBJ(t) == T_TRANS4) {
        ptt4 = ADDR_TRANS4(t);
        for (i = LEN_LIST(l); i >= 1; i--) {
            val = ELM_LIST(l, i);
            if (!IS_POS_INTOBJ(val)) {
                ErrorQuit(
                    "the entries of the first argument must be positive "
                    "integers (not a %s)",
                    (Int)TNAM_OBJ(val), 0L);
            }
            j = INT_INTOBJ(val);
            if (j <= n) {
                if (pttmp[ptt4[j - 1]] != 0) {
                    return False;
                }
                pttmp[ptt4[j - 1]] = 1;
            }
        }
    }
    else {
        // t is a list, first we check it describes a transformation
        for (i = 1; i <= n; i++) {
            val = ELM_LIST(t, i);
            if (!IS_POS_INTOBJ(val)) {
                ErrorQuit(
                    "the second argument must consist of positive integers "
                    "(not a %s)",
                    (Int)TNAM_OBJ(val), 0L);
            }
            else if (INT_INTOBJ(val) > n) {
                ErrorQuit(
                    "the second argument must consist of positive integers "
                    "in the range [1 .. %d]",
                    (Int)n, 0L);
            }
        }
        for (i = LEN_LIST(l); i >= 1; i--) {
            val = ELM_LIST(l, i);
            if (!IS_POS_INTOBJ(val)) {
                ErrorQuit(
                    "the entries of the first argument must be positive "
                    "integers (not a %s)",
                    (Int)TNAM_OBJ(val), 0L);
            }
            j = INT_INTOBJ(val);
            if (j <= n) {
                if (pttmp[INT_INTOBJ(ELM_LIST(t, j)) - 1] != 0) {
                    return False;
                }
                pttmp[INT_INTOBJ(ELM_LIST(t, j)) - 1] = 1;
            }
        }
    }
    return True;
}

// Returns a transformation g such that transformation f * g * f = f and
// g * f * g = g, where f is a transformation.

Obj FuncInverseOfTransformation(Obj self, Obj f)
{
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4;
    UInt   deg, i;
    Obj    g;

    if (!IS_TRANS(f)) {
        ErrorQuit("InverseOfTransformation: the argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }
    else if (FuncIS_ID_TRANS(self, f) == True) {
        return f;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        g = NEW_TRANS2(deg);
        ptf2 = ADDR_TRANS2(f);
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
        ptf4 = ADDR_TRANS4(f);
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

Obj FuncON_KERNEL_ANTI_ACTION(Obj self, Obj ker, Obj f, Obj n)
{
    UInt2 * ptf2;
    UInt4 * ptf4, *pttmp;
    UInt    deg, i, j, rank, len;
    Obj     out;

    assert(IS_LIST(ker));
    assert(IS_INTOBJ(n));

    len = LEN_LIST(ker);
    if (len == 1 && INT_INTOBJ(ELM_LIST(ker, 1)) == 0) {
        return FuncFLAT_KERNEL_TRANS_INT(self, f, n);
    }

    rank = 1;

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));
        if (len >= deg) {
            if (len == 0) {
                out = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
                SET_LEN_PLIST(out, 0);
                return out;
            }
            out = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, len);
            SET_LEN_PLIST(out, len);
            pttmp = ResizeInitTmpTrans(len);
            ptf2 = ADDR_TRANS2(f);
            for (i = 0; i < deg; i++) {
                // <f> then <g> with ker(<g>) = <ker>
                j = INT_INTOBJ(ELM_LIST(ker, ptf2[i] + 1)) - 1;    // f first!
                if (pttmp[j] == 0) {
                    pttmp[j] = rank++;
                }
                SET_ELM_PLIST(out, i + 1, INTOBJ_INT(pttmp[j]));
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
        ErrorQuit("ON_KERNEL_ANTI_ACTION: the length of the first "
                  "argument must be at least %d",
                  (Int)deg, 0L);
        return 0L;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));
        if (len >= deg) {
            if (len == 0) {
                out = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
                SET_LEN_PLIST(out, 0);
                return out;
            }
            out = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, len);
            SET_LEN_PLIST(out, len);
            pttmp = ResizeInitTmpTrans(len);
            ptf4 = ADDR_TRANS4(f);
            for (i = 0; i < deg; i++) {
                // <f> then <g> with ker(<g>) = <ker>
                j = INT_INTOBJ(ELM_LIST(ker, ptf4[i] + 1)) - 1;    // f first!
                if (pttmp[j] == 0) {
                    pttmp[j] = rank++;
                }
                SET_ELM_PLIST(out, i + 1, INTOBJ_INT(pttmp[j]));
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
        ErrorQuit("ON_KERNEL_ANTI_ACTION: the length of the first "
                  "argument must be at least %d",
                  (Int)deg, 0L);
        return 0L;
    }
    ErrorQuit("ON_KERNEL_ANTI_ACTION: the argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

/*******************************************************************************
** GAP level functions for changing representation of a permutation to a
** transformation
*******************************************************************************/

// Returns a transformation <f> such that (i)f = (i)p for all i <= n where <p>
// is a permutation <p> and <n> is a positive integer. Note that the returned
// transformation is not necessarily a permutation (mathematically), when n is
// less than the largest moved point of p.

Obj FuncAS_TRANS_PERM_INT(Obj self, Obj p, Obj deg)
{
    UInt2 *ptp2, *ptf2;
    UInt4 *ptp4, *ptf4;
    Obj    f;
    UInt   def, dep, i, min, n;

    if (!IS_INTOBJ(deg) || INT_INTOBJ(deg) < 0) {
        ErrorQuit("AS_TRANS_PERM_INT: the second argument must be a "
                  "non-negative integer",
                  0L, 0L);
    }
    else if (TNUM_OBJ(p) != T_PERM2 && TNUM_OBJ(p) != T_PERM4) {
        ErrorQuit("AS_TRANS_PERM_INT: the first argument must be a "
                  "permutation (not a %s)",
                  (Int)TNAM_OBJ(p), 0L);
    }

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
            ptp2 = ADDR_PERM2(p);
            for (i = 0; i < n; i++) {
                if (ptp2[i] + 1 > def) {
                    def = ptp2[i] + 1;
                }
            }
        }
        else {
            ptp4 = ADDR_PERM4(p);
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
            ptp2 = ADDR_PERM2(p);
            for (i = 0; i < min; i++) {
                ptf2[i] = ptp2[i];
            }
        }
        else {    // TNUM_OBJ(p) == T_PERM4
            ptp4 = ADDR_PERM4(p);
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
        ptp4 = ADDR_PERM4(p);
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

Obj FuncAS_TRANS_PERM(Obj self, Obj p)
{
    UInt2 * ptPerm2;
    UInt4 * ptPerm4;
    UInt    sup;

    if (TNUM_OBJ(p) != T_PERM2 && TNUM_OBJ(p) != T_PERM4) {
        ErrorQuit("AS_TRANS_PERM: the first argument must be a "
                  "permutation (not a %s)",
                  (Int)TNAM_OBJ(p), 0L);
    }

    // find largest moved point
    if (TNUM_OBJ(p) == T_PERM2) {
        ptPerm2 = ADDR_PERM2(p);
        for (sup = DEG_PERM2(p); 1 <= sup; sup--) {
            if (ptPerm2[sup - 1] != sup - 1) {
                break;
            }
        }
        return FuncAS_TRANS_PERM_INT(self, p, INTOBJ_INT(sup));
    }
    else {
        ptPerm4 = ADDR_PERM4(p);
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

Obj FuncAS_PERM_TRANS(Obj self, Obj f)
{
    UInt2 *ptf2, *ptp2;
    UInt4 *ptf4, *ptp4;
    UInt   deg, i;
    Obj    p;

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        if (RANK_TRANS2(f) != deg) {
            return Fail;
        }

        p = NEW_PERM2(deg);
        ptp2 = ADDR_PERM2(p);
        ptf2 = ADDR_TRANS2(f);

        for (i = 0; i < deg; i++) {
            ptp2[i] = ptf2[i];
        }
        return p;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        deg = DEG_TRANS4(f);
        if (RANK_TRANS4(f) != deg) {
            return Fail;
        }

        p = NEW_PERM4(deg);
        ptp4 = ADDR_PERM4(p);
        ptf4 = ADDR_TRANS4(f);

        for (i = 0; i < deg; i++) {
            ptp4[i] = ptf4[i];
        }
        return p;
    }
    ErrorQuit("AS_PERM_TRANS: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the permutation of the image of the transformation <f> induced by
// <f> if possible, and returns Fail if it is not possible.

Obj FuncPermutationOfImage(Obj self, Obj f)
{
    UInt2 *ptf2, *ptp2;
    UInt4 *ptf4, *ptp4, *pttmp;
    UInt   deg, rank, i, j;
    Obj    p, img;

    if (TNUM_OBJ(f) == T_TRANS2) {
        rank = RANK_TRANS2(f);
        deg = DEG_TRANS2(f);

        p = NEW_PERM2(deg);
        ResizeTmpTrans(deg);

        pttmp = ADDR_TRANS4(TmpTrans);
        ptp2 = ADDR_PERM2(p);
        for (i = 0; i < deg; i++) {
            pttmp[i] = 0;
            ptp2[i] = i;
        }

        ptf2 = ADDR_TRANS2(f);
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
        return p;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        rank = RANK_TRANS4(f);
        deg = DEG_TRANS4(f);

        p = NEW_PERM4(deg);
        ResizeTmpTrans(deg);

        pttmp = ADDR_TRANS4(TmpTrans);
        ptp4 = ADDR_PERM4(p);
        for (i = 0; i < deg; i++) {
            pttmp[i] = 0;
            ptp4[i] = i;
        }

        ptf4 = ADDR_TRANS4(f);
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
        return p;
    }
    ErrorQuit("PermutationOfImage: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the permutation of the im(f) induced by f ^ -1 * g under the
// (unchecked) assumption that im(f) = im(g) and ker(f) = ker(g).

Obj FuncPermLeftQuoTransformationNC(Obj self, Obj f, Obj g)
{
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4, *ptp;
    UInt   def, deg, i, min, max;
    Obj    perm;

    if (!IS_TRANS(f) || !IS_TRANS(g)) {
        ErrorQuit("PermLeftQuoTransformationNC: the arguments must both be "
                  "transformations (not %s and %s)",
                  (Int)TNAM_OBJ(f), (Int)TNAM_OBJ(g));
    }

    def = DEG_TRANS(f);
    deg = DEG_TRANS(g);
    min = MIN(def, deg);
    max = MAX(def, deg);

    // always return a T_PERM4 to reduce the amount of code here.
    perm = NEW_PERM4(max);
    ptp = ADDR_PERM4(perm);

    if (TNUM_OBJ(f) == T_TRANS2 && TNUM_OBJ(g) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);

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
        ptf2 = ADDR_TRANS2(f);
        ptg4 = ADDR_TRANS4(g);

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
        ptf4 = ADDR_TRANS4(f);
        ptg2 = ADDR_TRANS2(g);

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
        ptf4 = ADDR_TRANS4(f);
        ptg4 = ADDR_TRANS4(g);

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

Obj FuncRestrictedTransformation(Obj self, Obj f, Obj list)
{
    UInt   deg, i, k, len;
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4;
    Obj    g, j;

    if (!IS_LIST(list)) {
        ErrorQuit(
            "RestrictedTransformation: the second argument must be a list "
            "(not a %s)",
            (Int)TNAM_OBJ(list), 0L);
    }

    len = LEN_LIST(list);

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        g = NEW_TRANS2(deg);

        ptf2 = ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);

        // g fixes every point
        for (i = 0; i < deg; i++) {
            ptg2[i] = i;
        }

        // g acts like f on list * /
        for (i = 0; i < len; i++) {
            j = ELM_LIST(list, i + 1);
            if (!IS_INTOBJ(j) || INT_INTOBJ(j) < 1) {
                ErrorQuit(
                    "RestrictedTransformation: <list>[%d] must be a positive "
                    " integer (not a %s)",
                    (Int)i + 1, (Int)TNAM_OBJ(j));
            }
            k = INT_INTOBJ(j) - 1;
            if (k < deg) {
                ptg2[k] = ptf2[k];
            }
        }
        return g;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        deg = DEG_TRANS4(f);
        g = NEW_TRANS4(deg);

        ptf4 = ADDR_TRANS4(f);
        ptg4 = ADDR_TRANS4(g);

        // g fixes every point
        for (i = 0; i < deg; i++) {
            ptg4[i] = i;
        }

        // g acts like f on list
        for (i = 0; i < len; i++) {
            j = ELM_LIST(list, i + 1);
            if (!IS_INTOBJ(j) || INT_INTOBJ(j) < 1) {
                ErrorQuit(
                    "RestrictedTransformation: <list>[%d] must be a positive "
                    " integer (not a %s)",
                    (Int)i + 1, (Int)TNAM_OBJ(j));
            }
            k = INT_INTOBJ(j) - 1;
            if (k < deg) {
                ptg4[k] = ptf4[k];
            }
        }
        return g;
    }
    ErrorQuit("RestrictedTransformation: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// AsTransformation for a transformation <f> and a pos int <m> either
// restricts
// <f> to [1 .. m] or returns <f> depending on whether m is less than or equal
// DegreeOfTransformation(f) or not.

// In the first form, this is similar to TRIM_TRANS except that a new
// transformation is returned.

Obj FuncAS_TRANS_TRANS(Obj self, Obj f, Obj m)
{
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4;
    UInt   i, n, def;
    Obj    g;

    if (!IS_INTOBJ(m) || INT_INTOBJ(m) < 0) {
        ErrorQuit(
            "AS_TRANS_TRANS: the second argument must be a non-negative "
            "integer (not a %s)",
            (Int)TNAM_OBJ(m), 0L);
    }

    n = INT_INTOBJ(m);

    if (TNUM_OBJ(f) == T_TRANS2) {
        def = DEG_TRANS2(f);
        if (def <= n) {
            return f;
        }

        g = NEW_TRANS2(n);
        ptf2 = ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);
        for (i = 0; i < n; i++) {
            if (ptf2[i] > n - 1) {
                return Fail;
            }
            ptg2[i] = ptf2[i];
        }
        return g;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        def = DEG_TRANS4(f);
        if (def <= n) {
            return f;
        }

        if (n > 65536) {
            // g is T_TRANS4
            g = NEW_TRANS4(n);
            ptf4 = ADDR_TRANS4(f);
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
            ptf4 = ADDR_TRANS4(f);
            ptg2 = ADDR_TRANS2(g);
            for (i = 0; i < n; i++) {
                if (ptf4[i] > n - 1) {
                    return Fail;
                }
                ptg2[i] = (UInt2)ptf4[i];
            }
        }
        return g;
    }
    ErrorQuit("AS_TRANS_TRANS: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Changes the transformation <f> in-place to reduce the degree to <m>.  It is
// assumed that f is actually a transformation of [1 .. m], i.e. that i ^ f <=
// m for all i in [1 .. m].

Obj FuncTRIM_TRANS(Obj self, Obj f, Obj m)
{
    UInt    deg, i;
    UInt4 * ptf;

    if (!IS_INTOBJ(m) || INT_INTOBJ(m) < 0) {
        ErrorQuit("TRIM_TRANS: the second argument must be a non-negative "
                  "integer (not a %s)",
                  (Int)TNAM_OBJ(m), 0L);
    }

    deg = INT_INTOBJ(m);

    if (TNUM_OBJ(f) == T_TRANS2) {
        // output is T_TRANS2
        if (deg > DEG_TRANS2(f)) {
            return (Obj)0;
        }
        ResizeBag(f, deg * sizeof(UInt2) + 3 * sizeof(Obj));
        SET_IMG_TRANS(f, NULL);
        SET_KER_TRANS(f, NULL);
        SET_EXT_TRANS(f, NULL);
        CHANGED_BAG(f);
        return (Obj)0;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        if (deg > DEG_TRANS4(f)) {
            return (Obj)0;
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
        SET_IMG_TRANS(f, NULL);
        SET_KER_TRANS(f, NULL);
        SET_EXT_TRANS(f, NULL);
        CHANGED_BAG(f);
        return (Obj)0;
    }

    ErrorQuit("TRIM_TRANS: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
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

Obj FuncHASH_FUNC_FOR_TRANS(Obj self, Obj f, Obj data)
{
    return INTOBJ_INT((HashFuncForTrans(f) % INT_INTOBJ(data)) + 1);
}

/*******************************************************************************
** GAP level functions for moved points (and related) of a transformation
*******************************************************************************/

// Returns the largest value i such that (i)f <> i or 0 if no such i exists.

Obj FuncLARGEST_MOVED_PT_TRANS(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        for (i = DEG_TRANS2(f); 1 <= i; i--) {
            if (ptf2[i - 1] != i - 1) {
                break;
            }
        }
        return INTOBJ_INT(i);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        ptf4 = ADDR_TRANS4(f);
        for (i = DEG_TRANS4(f); 1 <= i; i--) {
            if (ptf4[i - 1] != i - 1) {
                break;
            }
        }
        return INTOBJ_INT(i);
    }
    ErrorQuit("LARGEST_MOVED_PT_TRANS: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the largest value in [(1)f .. (n)f] where n = LargestMovedPoint(f).

Obj FuncLARGEST_IMAGE_PT(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i, max, def;

    max = 0;
    if (TNUM_OBJ(f) == T_TRANS2) {
        def = DEG_TRANS2(f);
        ptf2 = ADDR_TRANS2(f);
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
        return INTOBJ_INT(max);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        def = DEG_TRANS4(f);
        ptf4 = ADDR_TRANS4(f);
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
        return INTOBJ_INT(max);
    }
    ErrorQuit("LARGEST_IMAGE_PT: the first argument must be a transformation "
              "(not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the smallest value <i> such that (i)f <> i if it exists, and Fail
// if
// not. Note that this differs from the GAP level function which returns
// infinity if (i)f = i for all i.

Obj FuncSMALLEST_MOVED_PT_TRANS(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i, deg;

    if (!IS_TRANS(f)) {
        ErrorQuit("SMALLEST_MOVED_PTS_TRANS: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
        return 0L;
    }
    else if (FuncIS_ID_TRANS(self, f) == True) {
        return Fail;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        for (i = 1; i <= deg; i++) {
            if (ptf2[i - 1] != i - 1) {
                break;
            }
        }
    }
    else {
        ptf4 = ADDR_TRANS4(f);
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

Obj FuncSMALLEST_IMAGE_PT(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    i, min, deg;

    if (!IS_TRANS(f)) {
        ErrorQuit("SMALLEST_IMAGE_PT: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
        return 0L;
    }
    else if (FuncIS_ID_TRANS(self, f) == True) {
        return Fail;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
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
        ptf4 = ADDR_TRANS4(f);
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

Obj FuncNR_MOVED_PTS_TRANS(Obj self, Obj f)
{
    UInt    nr, i, deg;
    UInt2 * ptf2;
    UInt4 * ptf4;

    nr = 0;
    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptf2[i] != i) {
                nr++;
            }
        }
        return INTOBJ_INT(nr);
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        ptf4 = ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptf4[i] != i) {
                nr++;
            }
        }
        return INTOBJ_INT(nr);
    }
    ErrorQuit("NR_MOVED_PTS_TRANS: the first argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the set of values <i> in [1 .. n] such that (i)f <> i, where n =
// DegreeOfTransformation(f).

Obj FuncMOVED_PTS_TRANS(Obj self, Obj f)
{
    UInt    len, deg, i;
    Obj     out;
    UInt2 * ptf2;
    UInt4 * ptf4;

    if (!IS_TRANS(f)) {
        ErrorQuit("MOVED_PTS_TRANS: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
        return 0L;
    }

    len = 0;
    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        out = NEW_PLIST(T_PLIST_CYC_SSORT, 0);
        ptf2 = ADDR_TRANS2(f);
        for (i = 0; i < deg; i++) {
            if (ptf2[i] != i) {
                AssPlist(out, ++len, INTOBJ_INT(i + 1));
            }
        }
    }
    else {
        deg = DEG_TRANS4(f);
        out = NEW_PLIST(T_PLIST_CYC_SSORT, 0);
        ptf4 = ADDR_TRANS4(f);
        for (i = 0; i < deg; i++) {
            if (ptf4[i] != i) {
                AssPlist(out, ++len, INTOBJ_INT(i + 1));
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

Obj FuncCOMPONENT_REPS_TRANS(Obj self, Obj f)
{
    UInt    deg, i, nr, pt, index;
    Obj     img, out, comp;
    UInt2 * ptf2;
    UInt4 * seen, *ptf4;

    if (!IS_TRANS(f)) {
        ErrorQuit("COMPONENT_REPS_TRANS: the argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (deg == 0) {
        out = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(out, 0);
        return out;
    }

    img = FuncUNSORTED_IMAGE_SET_TRANS(self, f);
    out = NEW_PLIST(T_PLIST, 1);

    seen = ResizeInitTmpTrans(deg);

    for (i = 1; i <= (UInt)LEN_PLIST(img); i++) {
        seen[INT_INTOBJ(ELM_PLIST(img, i)) - 1] = 1;
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
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
                    ptf2 = ADDR_TRANS2(f);
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
                ptf2 = ADDR_TRANS2(f);
                seen = ADDR_TRANS4(TmpTrans);
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
                ptf2 = ADDR_TRANS2(f);
                seen = ADDR_TRANS4(TmpTrans);
            }
        }
    }
    else {
        ptf4 = ADDR_TRANS4(f);
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
                ptf4 = ADDR_TRANS4(f);
                seen = ADDR_TRANS4(TmpTrans);
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
                ptf4 = ADDR_TRANS4(f);
                seen = ADDR_TRANS4(TmpTrans);
            }
        }
    }
    return out;
}

// Returns the number of connected components of the transformation <f>,
// thought of as a functional digraph with DegreeOfTransformation(f) vertices.

Obj FuncNR_COMPONENTS_TRANS(Obj self, Obj f)
{
    UInt    nr, m, i, j, deg;
    UInt2 * ptf2;
    UInt4 * ptseen, *ptf4;

    if (!IS_TRANS(f)) {
        ErrorQuit("NR_COMPONENTS_TRANS: the argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));
    ptseen = ResizeInitTmpTrans(deg);
    nr = 0;
    m = 0;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
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
        ptf4 = ADDR_TRANS4(f);
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

Obj FuncCOMPONENTS_TRANS(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * seen, *ptf4;
    UInt    deg, i, pt, csize, nr, index, pos;
    Obj     out, comp;

    if (!IS_TRANS(f)) {
        ErrorQuit("COMPONENTS_TRANS: the argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (deg == 0) {
        out = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(out, 0);
        return out;
    }

    seen = ResizeInitTmpTrans(deg);
    out = NEW_PLIST(T_PLIST, 1);
    nr = 0;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
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
                seen = ADDR_TRANS4(TmpTrans);
                ptf2 = ADDR_TRANS2(f);

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
        ptf4 = ADDR_TRANS4(f);
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
                seen = ADDR_TRANS4(TmpTrans);
                ptf4 = ADDR_TRANS4(f);

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

Obj FuncCOMPONENT_TRANS_INT(Obj self, Obj f, Obj pt)
{
    UInt    deg, cpt, len;
    Obj     out;
    UInt2 * ptf2;
    UInt4 * ptseen, *ptf4;

    if (!IS_TRANS(f)) {
        ErrorQuit("COMPONENT_TRANS_INT: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }
    else if (!IS_INTOBJ(pt) || INT_INTOBJ(pt) < 1) {
        ErrorQuit("COMPONENT_TRANS_INT: the second argument must be a "
                  "positive integer (not a %s)",
                  (Int)TNAM_OBJ(pt), 0L);
    }

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));
    cpt = INT_INTOBJ(pt) - 1;

    if (cpt >= deg) {
        out = NEW_PLIST(T_PLIST_CYC_SSORT, 1);
        SET_LEN_PLIST(out, 1);
        SET_ELM_PLIST(out, 1, pt);
        return out;
    }
    out = NEW_PLIST(T_PLIST_CYC, 0);
    ptseen = ResizeInitTmpTrans(deg);

    len = 0;

    // install the points
    if (TNUM_OBJ(f) == T_TRANS2) {
        do {
            AssPlist(out, ++len, INTOBJ_INT(cpt + 1));
            ptseen = ADDR_TRANS4(TmpTrans);
            ptf2 = ADDR_TRANS2(f);
            ptseen[cpt] = 1;
            cpt = ptf2[cpt];
        } while (ptseen[cpt] == 0);
    }
    else {
        do {
            AssPlist(out, ++len, INTOBJ_INT(cpt + 1));
            ptseen = ADDR_TRANS4(TmpTrans);
            ptf4 = ADDR_TRANS4(f);
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

Obj FuncCYCLE_TRANS_INT(Obj self, Obj f, Obj pt)
{
    UInt    deg, cpt, len, i;
    Obj     out;
    UInt2 * ptf2;
    UInt4 * ptseen, *ptf4;

    if (!IS_TRANS(f)) {
        ErrorQuit("CYCLE_TRANS_INT: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }
    else if (!IS_INTOBJ(pt) || INT_INTOBJ(pt) < 1) {
        ErrorQuit("CYCLE_TRANS_INT: the second argument must be a "
                  "positive integer (not a %s)",
                  (Int)TNAM_OBJ(pt), 0L);
    }

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));
    cpt = INT_INTOBJ(pt) - 1;

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
        ptf2 = ADDR_TRANS2(f);
        // find component
        do {
            ptseen[cpt] = 1;
            cpt = ptf2[cpt];
        } while (ptseen[cpt] == 0);
        // find cycle
        i = cpt;
        do {
            AssPlist(out, ++len, INTOBJ_INT(i + 1));
            i = ptf2[i];
        } while (i != cpt);
    }
    else {
        ptf4 = ADDR_TRANS4(f);
        // find component
        do {
            ptseen[cpt] = 1;
            cpt = ptf4[cpt];
        } while (ptseen[cpt] == 0);
        // find cycle
        i = cpt;
        do {
            AssPlist(out, ++len, INTOBJ_INT(i + 1));
            i = ptf4[i];
        } while (i != cpt);
    }
    return out;
}

// Returns the cycles of the transformation <f>, thought of as a
// functional digraph with DegreeOfTransformation(f) vertices.

Obj FuncCYCLES_TRANS(Obj self, Obj f)
{
    UInt2 * ptf2;
    UInt4 * seen, *ptf4;
    UInt    deg, i, pt, nr;
    Obj     out, comp;

    if (!IS_TRANS(f)) {
        ErrorQuit("CYCLES_TRANS: the argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (deg == 0) {
        out = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(out, 0);
        return out;
    }

    seen = ResizeInitTmpTrans(deg);
    out = NEW_PLIST(T_PLIST, 0);
    nr = 0;

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
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

                    seen = ADDR_TRANS4(TmpTrans);
                    ptf2 = ADDR_TRANS2(f);

                    for (; seen[pt] == 1; pt = ptf2[pt]) {
                        seen[pt] = 2;
                        AssPlist(comp, LEN_PLIST(comp) + 1,
                                 INTOBJ_INT(pt + 1));
                        seen = ADDR_TRANS4(TmpTrans);
                        ptf2 = ADDR_TRANS2(f);
                    }
                }
                for (pt = i; seen[pt] == 1; pt = ptf2[pt]) {
                    seen[pt] = 2;
                }
            }
        }
    }
    else {
        ptf4 = ADDR_TRANS4(f);
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

                    seen = ADDR_TRANS4(TmpTrans);
                    ptf4 = ADDR_TRANS4(f);

                    for (; seen[pt] == 1; pt = ptf4[pt]) {
                        seen[pt] = 2;
                        AssPlist(comp, LEN_PLIST(comp) + 1,
                                 INTOBJ_INT(pt + 1));
                        seen = ADDR_TRANS4(TmpTrans);
                        ptf4 = ADDR_TRANS4(f);
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

Obj FuncCYCLES_TRANS_LIST(Obj self, Obj f, Obj list)
{
    UInt2 * ptf2;
    UInt4 * seen, *ptf4;
    UInt    deg, i, j, pt, nr;
    Obj     out, comp, list_i;

    if (!IS_TRANS(f)) {
        ErrorQuit("CYCLES_TRANS_LIST: the first argument must be a "
                  "transformation (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }
    else if (!IS_LIST(list)) {
        ErrorQuit("CYCLES_TRANS_LIST: the second argument must be a "
                  "list (not a %s)",
                  (Int)TNAM_OBJ(f), 0L);
    }

    deg = INT_INTOBJ(FuncDegreeOfTransformation(self, f));

    if (LEN_LIST(list) == 0) {
        out = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(out, 0);
        return out;
    }

    out = NEW_PLIST(T_PLIST, 0);
    nr = 0;

    seen = ResizeInitTmpTrans(deg);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        for (i = 1; i <= (UInt)LEN_LIST(list); i++) {
            list_i = ELM_LIST(list, i);
            if (!IS_INTOBJ(list_i) || INT_INTOBJ(list_i) < 1) {
                ErrorQuit("CYCLES_TRANS_LIST: the second argument must be a "
                          "list of positive integer (not a %s)",
                          (Int)TNAM_OBJ(list_i), 0L);
            }
            j = INT_INTOBJ(list_i) - 1;
            if (j >= deg) {
                comp = NEW_PLIST(T_PLIST_CYC, 1);
                SET_LEN_PLIST(comp, 1);
                SET_ELM_PLIST(comp, 1, list_i);
                AssPlist(out, ++nr, comp);
                seen = ADDR_TRANS4(TmpTrans);
                ptf2 = ADDR_TRANS2(f);
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

                    seen = ADDR_TRANS4(TmpTrans);
                    ptf2 = ADDR_TRANS2(f);

                    for (; seen[pt] == 1; pt = ptf2[pt]) {
                        seen[pt] = 2;
                        AssPlist(comp, LEN_PLIST(comp) + 1,
                                 INTOBJ_INT(pt + 1));
                        seen = ADDR_TRANS4(TmpTrans);
                        ptf2 = ADDR_TRANS2(f);
                    }
                }
                for (pt = j; seen[pt] == 1; pt = ptf2[pt]) {
                    seen[pt] = 2;
                }
            }
        }
    }
    else {
        ptf4 = ADDR_TRANS4(f);
        for (i = 1; i <= (UInt)LEN_LIST(list); i++) {
            list_i = ELM_LIST(list, i);
            if (!IS_INTOBJ(list_i) || INT_INTOBJ(list_i) < 1) {
                ErrorQuit("CYCLES_TRANS_LIST: the second argument must be a "
                          "positive integer (not a %s)",
                          (Int)TNAM_OBJ(list_i), 0L);
            }
            j = INT_INTOBJ(list_i) - 1;
            if (j >= deg) {
                comp = NEW_PLIST(T_PLIST_CYC, 1);
                SET_LEN_PLIST(comp, 1);
                SET_ELM_PLIST(comp, 1, list_i);
                AssPlist(out, ++nr, comp);
                seen = ADDR_TRANS4(TmpTrans);
                ptf4 = ADDR_TRANS4(f);
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

                    seen = ADDR_TRANS4(TmpTrans);
                    ptf4 = ADDR_TRANS4(f);

                    for (; seen[pt] == 1; pt = ptf4[pt]) {
                        seen[pt] = 2;
                        AssPlist(comp, LEN_PLIST(comp) + 1,
                                 INTOBJ_INT(pt + 1));
                        seen = ADDR_TRANS4(TmpTrans);
                        ptf4 = ADDR_TRANS4(f);
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

Obj FuncINV_LIST_TRANS(Obj self, Obj list, Obj f)
{
    UInt2 *ptf2, *ptg2;
    UInt4 *ptf4, *ptg4;
    UInt   deg, i, j;
    Obj    g, k;

    if (!IS_LIST(list)) {
        ErrorQuit("INV_LIST_TRANS: the first argument must be a "
                  "list (not a %s)",
                  (Int)TNAM_OBJ(list), 0L);
    }

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        g = NEW_TRANS2(deg);
        ptf2 = ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);

        for (j = 0; j < deg; j++) {
            ptg2[j] = j;
        }
        for (j = 1; j <= (UInt)LEN_LIST(list); j++) {
            k = ELM_LIST(list, j);
            if (!IS_INTOBJ(k) || INT_INTOBJ(k) < 1) {
                ErrorQuit(
                    "INV_LIST_TRANS: <list>[%d] must be a positive integer "
                    "(not a %s)",
                    (Int)j, (Int)TNAM_OBJ(k));
            }
            i = INT_INTOBJ(k) - 1;
            if (i < deg) {
                ptg2[ptf2[i]] = i;
            }
        }
        return g;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        deg = DEG_TRANS4(f);
        g = NEW_TRANS4(deg);
        ptf4 = ADDR_TRANS4(f);
        ptg4 = ADDR_TRANS4(g);

        i = INT_INTOBJ(ELM_LIST(list, 1)) - 1;
        for (j = 0; j < deg; j++) {
            ptg4[j] = j;
        }
        for (j = 1; j <= (UInt)LEN_LIST(list); j++) {
            k = ELM_LIST(list, j);
            if (!IS_INTOBJ(k) || INT_INTOBJ(k) < 1) {
                ErrorQuit(
                    "INV_LIST_TRANS: <list>[%d] must be a positive integer "
                    "(not a %s)",
                    (Int)j, (Int)TNAM_OBJ(k));
            }
            i = INT_INTOBJ(k) - 1;
            if (i < deg) {
                ptg4[ptf4[i]] = i;
            }
        }
        return g;
    }
    ErrorQuit("INV_LIST_TRANS: the second argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
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

Obj FuncTRANS_IMG_CONJ(Obj self, Obj f, Obj g)
{
    Obj    perm;
    UInt2 *ptf2, *ptg2;
    UInt4 *ptsrc, *ptdst, *ptp, *ptf4, *ptg4;
    UInt   def, deg, i, j, max, min;

    if (!IS_TRANS(f) || !IS_TRANS(g)) {
        ErrorQuit(
            "TRANS_IMG_CONJ: the arguments must both be transformations "
            "(not %s and %s)",
            (Int)TNAM_OBJ(f), (Int)TNAM_OBJ(g));
    }

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
        ptf2 = ADDR_TRANS2(f);
        ptg2 = ADDR_TRANS2(g);

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
        ptf2 = ADDR_TRANS2(f);
        ptg4 = ADDR_TRANS4(g);

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
        ptf4 = ADDR_TRANS4(f);
        ptg2 = ADDR_TRANS2(g);

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
        ptf4 = ADDR_TRANS4(f);
        ptg4 = ADDR_TRANS4(g);

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

Obj FuncPOW_KER_PERM(Obj self, Obj ker, Obj p)
{
    UInt    len, rank, i, dep;
    Obj     out;
    UInt4 * ptcnj, *ptlkp, *ptp4;
    UInt2 * ptp2;

    len = LEN_LIST(ker);

    if (len == 0) {
        out = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, len);
        SET_LEN_PLIST(out, len);
        return out;
    }

    out = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, len);
    SET_LEN_PLIST(out, len);

    ResizeTmpTrans(2 * len);
    ptcnj = (UInt4 *)ADDR_OBJ(TmpTrans);

    rank = 1;
    ptlkp = ptcnj + len;

    if (TNUM_OBJ(p) == T_PERM2) {
        dep = DEG_PERM2(p);
        ptp2 = ADDR_PERM2(p);

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

        // form the flat kernel
        for (i = 0; i < len; i++) {
            if (ptlkp[ptcnj[i]] == 0) {
                ptlkp[ptcnj[i]] = rank++;
            }
            SET_ELM_PLIST(out, i + 1, INTOBJ_INT(ptlkp[ptcnj[i]]));
        }
        return out;
    }
    else if (TNUM_OBJ(p) == T_PERM4) {
        dep = DEG_PERM4(p);
        ptp4 = ADDR_PERM4(p);

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

        // form the flat kernel
        for (i = 0; i < len; i++) {
            if (ptlkp[ptcnj[i]] == 0) {
                ptlkp[ptcnj[i]] = rank++;
            }
            SET_ELM_PLIST(out, i + 1, INTOBJ_INT(ptlkp[ptcnj[i]]));
        }
        return out;
    }

    ErrorQuit("POW_KER_TRANS: the argument must be a "
              "permutation (not a %s)",
              (Int)TNAM_OBJ(p), 0L);
    return 0L;
}

// If <f> is a transformation and <X> is a flat kernel of a transformation,
// then we denote OnKernelAntiAction(X, f) by f ^ X. Suppose that x is a
// transformation with ker(x) = <X> and ker(<f>x) = f ^ ker(x) has the same
// number of classes as ker(x). Then INV_KER_TRANS(X, f) returns a
// transformation g such that g<f> ^ ker(x) = ker(x) = ker(gfx) and the action
// of g<f> on ker(x) is the identity.

Obj FuncINV_KER_TRANS(Obj self, Obj X, Obj f)
{
    Obj    g;
    UInt2 *ptf2, *ptg2;
    UInt4 *pttmp, *ptf4, *ptg4;
    UInt   deg, i, len;

    len = LEN_LIST(X);
    ResizeTmpTrans(len);

    if (TNUM_OBJ(f) == T_TRANS2) {
        deg = DEG_TRANS2(f);
        if (len <= 65536) {
            // deg(g) <= 65536 and g is T_TRANS2
            g = NEW_TRANS2(len);
            pttmp = ADDR_TRANS4(TmpTrans);
            ptf2 = ADDR_TRANS2(f);
            ptg2 = ADDR_TRANS2(g);
            if (deg >= len) {
                // calculate a transversal of f ^ ker(x) = ker(fx)
                for (i = 0; i < len; i++) {
                    pttmp[INT_INTOBJ(ELM_LIST(X, ptf2[i] + 1)) - 1] = i;
                }
                // install values in g
                for (i = len; i >= 1; i--) {
                    ptg2[i - 1] = pttmp[INT_INTOBJ(ELM_LIST(X, i)) - 1];
                }
            }
            else {
                for (i = 0; i < deg; i++) {
                    pttmp[INT_INTOBJ(ELM_LIST(X, ptf2[i] + 1)) - 1] = i;
                }
                for (; i < len; i++) {
                    pttmp[INT_INTOBJ(ELM_LIST(X, i + 1)) - 1] = i;
                }
                for (i = len; i >= 1; i--) {
                    ptg2[i - 1] = pttmp[INT_INTOBJ(ELM_LIST(X, i)) - 1];
                }
            }
            return g;
        }
        else {
            // deg(g) = len > 65536 >= deg and g is T_TRANS4
            g = NEW_TRANS4(len);
            pttmp = ADDR_TRANS4(TmpTrans);
            ptf2 = ADDR_TRANS2(f);
            ptg4 = ADDR_TRANS4(g);
            for (i = 0; i < deg; i++) {
                pttmp[INT_INTOBJ(ELM_LIST(X, ptf2[i] + 1)) - 1] = i;
            }
            for (; i < len; i++) {
                pttmp[INT_INTOBJ(ELM_LIST(X, i + 1)) - 1] = i;
            }
            for (i = len; i >= 1; i--) {
                ptg4[i - 1] = pttmp[INT_INTOBJ(ELM_LIST(X, i)) - 1];
            }
            return g;
        }
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        deg = DEG_TRANS4(f);
        if (len <= 65536) {
            // deg(g) <= 65536 and g is T_TRANS2
            g = NEW_TRANS2(len);
            pttmp = ADDR_TRANS4(TmpTrans);
            ptf4 = ADDR_TRANS4(f);
            ptg2 = ADDR_TRANS2(g);
            // calculate a transversal of f ^ ker(x) = ker(fx)
            for (i = 0; i < len; i++) {
                pttmp[INT_INTOBJ(ELM_LIST(X, ptf4[i] + 1)) - 1] = i;
            }
            // install values in g
            for (i = len; i >= 1; i--) {
                ptg2[i - 1] = pttmp[INT_INTOBJ(ELM_LIST(X, i)) - 1];
            }
            return g;
        }
        else {
            // deg(g) = len > 65536 >= deg and g is T_TRANS4
            g = NEW_TRANS4(len);
            pttmp = ADDR_TRANS4(TmpTrans);
            ptf4 = ADDR_TRANS4(f);
            ptg4 = ADDR_TRANS4(g);
            for (i = 0; i < deg; i++) {
                pttmp[INT_INTOBJ(ELM_LIST(X, ptf4[i] + 1)) - 1] = i;
            }
            for (; i < len; i++) {
                pttmp[INT_INTOBJ(ELM_LIST(X, i + 1)) - 1] = i;
            }
            for (i = len; i >= 1; i--) {
                ptg4[i - 1] = pttmp[INT_INTOBJ(ELM_LIST(X, i)) - 1];
            }
            return g;
        }
    }
    ErrorQuit("INV_KER_TRANS: the argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

// Returns the same value as OnSets(set, f) except if set = [0], when the
// image
// set of <f> on [1 .. n] is returned instead. If the argument <set> is not
// [0], then the third argument is ignored.

Obj FuncOnPosIntSetsTrans(Obj self, Obj set, Obj f, Obj n)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg;
    Obj *   ptset, *ptres, res;
    UInt    i, k;

    if (LEN_LIST(set) == 0) {
        return set;
    }

    if (LEN_LIST(set) == 1 && INT_INTOBJ(ELM_LIST(set, 1)) == 0) {
        return FuncIMAGE_SET_TRANS_INT(self, f, n);
    }

    PLAIN_LIST(set);
    res = NEW_PLIST(IS_MUTABLE_PLIST(set) ? T_PLIST_CYC_SSORT
                                          : T_PLIST_CYC_SSORT + IMMUTABLE,
                    LEN_LIST(set));
    ADDR_OBJ(res)[0] = ADDR_OBJ(set)[0];

    ptset = ADDR_OBJ(set) + LEN_LIST(set);
    ptres = ADDR_OBJ(res) + LEN_LIST(set);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        for (i = LEN_LIST(set); 1 <= i; i--, ptset--, ptres--) {
            k = INT_INTOBJ(*ptset);
            if (k <= deg) {
                k = ptf2[k - 1] + 1;
            }
            *ptres = INTOBJ_INT(k);
        }
        SORT_PLIST_CYC(res);
        REMOVE_DUPS_PLIST_CYC(res);
        return res;
    }
    else if (TNUM_OBJ(f) == T_TRANS4) {
        ptf4 = ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);
        for (i = LEN_LIST(set); 1 <= i; i--, ptset--, ptres--) {
            k = INT_INTOBJ(*ptset);
            if (k <= deg) {
                k = ptf4[k - 1] + 1;
            }
            *ptres = INTOBJ_INT(k);
        }
        SORT_PLIST_CYC(res);
        REMOVE_DUPS_PLIST_CYC(res);
        return res;
    }
    ErrorQuit("OnPosIntSetsTrans: the argument must be a "
              "transformation (not a %s)",
              (Int)TNAM_OBJ(f), 0L);
    return 0L;
}

/*******************************************************************************
 *******************************************************************************
 * GAP kernel functions for transformations
 *******************************************************************************
 *******************************************************************************/

// Returns the identity transformation.

Obj OneTrans(Obj f)
{
    return IdentityTrans;
}

/*******************************************************************************
** Equality for transformations
*******************************************************************************/

// The following function is used to check equality of both permutations and
// transformations, it is written by Chris Jefferson in pull request #280.

Int EqPermTrans22(UInt degL, UInt degR, UInt2 * ptLstart, UInt2 * ptRstart)
{

    UInt2 * ptL;    // pointer to the left operand
    UInt2 * ptR;    // pointer to the right operand
    UInt    p;      // loop variable

    // if perms/trans are different sizes, check final element as an early
    // check

    if (degL != degR) {
        if (degL < degR) {
            if (*(ptRstart + degR - 1) != (degR - 1)) {
                return 0L;
            }
        }
        else {
            if (*(ptLstart + degL - 1) != (degL - 1)) {
                return 0L;
            }
        }
    }

    // search for a difference and return False if you find one
    if (degL <= degR) {
        ptR = ptRstart + degL;
        for (p = degL; p < degR; p++) {
            if (*(ptR++) != p) {
                return 0L;
            }
        }
        if (memcmp(ptLstart, ptRstart, degL * sizeof(UInt2)) != 0) {
            return 0L;
        }
    }
    else {
        ptL = ptLstart + degR;
        for (p = degR; p < degL; p++) {
            if (*(ptL++) != p) {
                return 0L;
            }
        }
        if (memcmp(ptLstart, ptRstart, degR * sizeof(UInt2)) != 0) {
            return 0L;
        }
    }

    // otherwise they must be equal
    return 1L;
}

Int EqPermTrans44(UInt degL, UInt degR, UInt4 * ptLstart, UInt4 * ptRstart)
{

    UInt4 * ptL;    // pointer to the left operand
    UInt4 * ptR;    // pointer to the right operand
    UInt    p;      // loop variable

    // if perms/trans are different sizes, check final element as an early
    // check

    if (degL != degR) {
        if (degL < degR) {
            if (*(ptRstart + degR - 1) != (degR - 1)) {
                return 0L;
            }
        }
        else {
            if (*(ptLstart + degL - 1) != (degL - 1)) {
                return 0L;
            }
        }
    }

    // search for a difference and return False if you find one
    if (degL <= degR) {
        ptR = ptRstart + degL;
        for (p = degL; p < degR; p++) {
            if (*(ptR++) != p) {
                return 0L;
            }
        }
        if (memcmp(ptLstart, ptRstart, degL * sizeof(UInt4)) != 0) {
            return 0L;
        }
    }
    else {
        ptL = ptLstart + degR;
        for (p = degR; p < degL; p++) {
            if (*(ptL++) != p) {
                return 0L;
            }
        }
        if (memcmp(ptLstart, ptRstart, degR * sizeof(UInt4)) != 0) {
            return 0L;
        }
    }

    // otherwise they must be equal
    return 1L;
}

Int EqTrans22(Obj opL, Obj opR)
{
    return EqPermTrans22(DEG_TRANS2(opL), DEG_TRANS2(opR), ADDR_TRANS2(opL),
                         ADDR_TRANS2(opR));
}

Int EqTrans44(Obj opL, Obj opR)
{
    return EqPermTrans44(DEG_TRANS4(opL), DEG_TRANS4(opR), ADDR_TRANS4(opL),
                         ADDR_TRANS4(opR));
}

Int EqTrans24(Obj f, Obj g)
{
    UInt    i, def, deg;
    UInt2 * ptf;
    UInt4 * ptg;

    ptf = ADDR_TRANS2(f);
    ptg = ADDR_TRANS4(g);
    def = DEG_TRANS2(f);
    deg = DEG_TRANS4(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            if (*(ptf++) != *(ptg++)) {
                return 0L;
            }
        }
        for (; i < deg; i++) {
            if (*(ptg++) != i) {
                return 0L;
            }
        }
    }
    else {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        for (i = 0; i < deg; i++) {
            if (*(ptf++) != *(ptg++)) {
                return 0L;
            }
        }
        for (; i < def; i++) {
            if (*(ptf++) != i) {
                return 0L;
            }
        }
    }

    return 1L;
}

Int EqTrans42(Obj f, Obj g)
{
    UInt    i, def, deg;
    UInt4 * ptf;
    UInt2 * ptg;

    ptf = ADDR_TRANS4(f);
    ptg = ADDR_TRANS2(g);
    def = DEG_TRANS4(f);
    deg = DEG_TRANS2(g);

    if (def <= deg) {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        for (i = 0; i < def; i++) {
            if (*(ptf++) != *(ptg++)) {
                return 0L;
            }
        }
        for (; i < deg; i++) {
            if (*(ptg++) != i) {
                return 0L;
            }
        }
    }
    else {
        for (i = 0; i < deg; i++) {
            if (*(ptf++) != *(ptg++)) {
                return 0L;
            }
        }
        for (; i < def; i++) {
            if (*(ptf++) != i) {
                return 0L;
            }
        }
    }

    return 1L;
}

/*******************************************************************************
** Less than for transformations
*******************************************************************************/

Int LtTrans22(Obj f, Obj g)
{
    UInt   i, def, deg;
    UInt2 *ptf, *ptg;

    ptf = ADDR_TRANS2(f);
    ptg = ADDR_TRANS2(g);
    def = DEG_TRANS2(f);
    deg = DEG_TRANS2(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            if (ptf[i] != ptg[i]) {
                if (ptf[i] < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
        for (; i < deg; i++) {
            if (ptg[i] != i) {
                if (i < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
    }
    else {
        // def > deg
        for (i = 0; i < deg; i++) {
            if (ptf[i] != ptg[i]) {
                if (ptf[i] < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
        for (; i < def; i++) {
            if (ptf[i] != i) {
                if (i > ptf[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
    }
    return 0L;
}

Int LtTrans24(Obj f, Obj g)
{
    UInt    i, def, deg;
    UInt2 * ptf;
    UInt4 * ptg;

    ptf = ADDR_TRANS2(f);
    ptg = ADDR_TRANS4(g);
    def = DEG_TRANS2(f);
    deg = DEG_TRANS4(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            if (ptf[i] != ptg[i]) {
                if (ptf[i] < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
        for (; i < deg; i++) {
            if (ptg[i] != i) {
                if (i < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
    }
    else {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        for (i = 0; i < deg; i++) {
            if (ptf[i] != ptg[i]) {
                if (ptf[i] < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
        for (; i < def; i++) {
            if (ptf[i] != i) {
                if (i > ptf[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
    }
    return 0L;
}

Int LtTrans42(Obj f, Obj g)
{
    UInt    i, def, deg;
    UInt4 * ptf;
    UInt2 * ptg;

    ptf = ADDR_TRANS4(f);
    ptg = ADDR_TRANS2(g);
    def = DEG_TRANS4(f);
    deg = DEG_TRANS2(g);

    if (def <= deg) {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        for (i = 0; i < def; i++) {
            if (ptf[i] != ptg[i]) {
                if (ptf[i] < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
        for (; i < deg; i++) {
            if (ptg[i] != i) {
                if (i < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
    }
    else {
        for (i = 0; i < deg; i++) {
            if (ptf[i] != ptg[i]) {
                if (ptf[i] < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
        for (; i < def; i++) {
            if (ptf[i] != i) {
                if (i > ptf[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
    }
    return 0L;
}

Int LtTrans44(Obj f, Obj g)
{
    UInt   i, def, deg;
    UInt4 *ptf, *ptg;

    ptf = ADDR_TRANS4(f);
    ptg = ADDR_TRANS4(g);
    def = DEG_TRANS4(f);
    deg = DEG_TRANS4(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            if (ptf[i] != ptg[i]) {
                if (ptf[i] < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
        for (; i < deg; i++) {
            if (ptg[i] != i) {
                if (i < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
    }
    else {
        for (i = 0; i < deg; i++) {
            if (ptf[i] != ptg[i]) {
                if (ptf[i] < ptg[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
        for (; i < def; i++) {
            if (ptf[i] != i) {
                if (i > ptf[i]) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }
        }
    }
    return 0L;
}

/*******************************************************************************
** Products for transformations
*******************************************************************************/

Obj ProdTrans22(Obj f, Obj g)
{
    UInt2 *ptf, *ptg, *ptfg;
    UInt   i, def, deg;
    Obj    fg;

    def = DEG_TRANS2(f);
    deg = DEG_TRANS2(g);
    fg = NEW_TRANS2(MAX(def, deg));

    ptfg = ADDR_TRANS2(fg);
    ptf = ADDR_TRANS2(f);
    ptg = ADDR_TRANS2(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            *(ptfg++) = ptg[*(ptf++)];
        }
        for (; i < deg; i++) {
            *(ptfg++) = ptg[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptfg++) = IMAGE(ptf[i], ptg, deg);
        }
    }
    return fg;
}

Obj ProdTrans24(Obj f, Obj g)
{
    UInt2 * ptf;
    UInt4 * ptg, *ptfg;
    UInt    i, def, deg;
    Obj     fg;

    def = DEG_TRANS2(f);
    deg = DEG_TRANS4(g);

    fg = NEW_TRANS4(MAX(def, deg));

    ptfg = ADDR_TRANS4(fg);
    ptf = ADDR_TRANS2(f);
    ptg = ADDR_TRANS4(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            *ptfg++ = ptg[*ptf++];
        }
        for (; i < deg; i++) {
            *ptfg++ = ptg[i];
        }
    }
    else {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        for (i = 0; i < def; i++) {
            *(ptfg++) = IMAGE(ptf[i], ptg, deg);
        }
    }

    return fg;
}

Obj ProdTrans42(Obj f, Obj g)
{
    UInt4 * ptf, *ptfg;
    UInt2 * ptg;
    UInt    i, def, deg;
    Obj     fg;

    def = DEG_TRANS4(f);
    deg = DEG_TRANS2(g);

    fg = NEW_TRANS4(MAX(def, deg));

    ptfg = ADDR_TRANS4(fg);
    ptf = ADDR_TRANS4(f);
    ptg = ADDR_TRANS2(g);

    if (def <= deg) {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.

        for (i = 0; i < def; i++) {
            *(ptfg++) = ptg[*(ptf++)];
        }
        for (; i < deg; i++) {
            *(ptfg++) = ptg[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptfg++) = IMAGE(ptf[i], ptg, deg);
        }
    }

    return fg;
}

Obj ProdTrans44(Obj f, Obj g)
{
    UInt4 *ptf, *ptg, *ptfg;
    UInt   i, def, deg;
    Obj    fg;

    def = DEG_TRANS4(f);
    deg = DEG_TRANS4(g);
    fg = NEW_TRANS4(MAX(def, deg));

    ptfg = ADDR_TRANS4(fg);
    ptf = ADDR_TRANS4(f);
    ptg = ADDR_TRANS4(g);

    if (def <= deg) {
        for (i = 0; i < def; i++) {
            *(ptfg++) = ptg[*(ptf++)];
        }
        for (; i < deg; i++) {
            *(ptfg++) = ptg[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptfg++) = IMAGE(ptf[i], ptg, deg);
        }
    }
    return fg;
}

/*******************************************************************************
** Products for a transformation and permutation
*******************************************************************************/

Obj ProdTrans2Perm2(Obj f, Obj p)
{
    UInt2 *ptf, *ptp, *ptfp;
    UInt   i, def, dep;
    Obj    fp;

    dep = DEG_PERM2(p);
    def = DEG_TRANS2(f);
    fp = NEW_TRANS2(MAX(def, dep));

    ptfp = ADDR_TRANS2(fp);
    ptf = ADDR_TRANS2(f);
    ptp = ADDR_PERM2(p);

    if (def <= dep) {
        for (i = 0; i < def; i++) {
            *(ptfp++) = ptp[*(ptf++)];
        }
        for (; i < dep; i++) {
            *(ptfp++) = ptp[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptfp++) = IMAGE(ptf[i], ptp, dep);
        }
    }
    return fp;
}

Obj ProdTrans2Perm4(Obj f, Obj p)
{
    UInt2 * ptf;
    UInt4 * ptp, *ptfp;
    UInt    i, def, dep;
    Obj     fp;

    dep = DEG_PERM4(p);
    def = DEG_TRANS2(f);
    fp = NEW_TRANS4(MAX(def, dep));

    ptfp = ADDR_TRANS4(fp);
    ptf = ADDR_TRANS2(f);
    ptp = ADDR_PERM4(p);

    if (def <= dep) {
        for (i = 0; i < def; i++) {
            *(ptfp++) = ptp[*(ptf++)];
        }
        for (; i < dep; i++) {
            *(ptfp++) = ptp[i];
        }
    }
    else {
        // I don't know how to create a permutation of type T_PERM4 with
        // (internal) degree 65536 or less, so this case isn't tested. It is
        // included to make the code more robust.
        for (i = 0; i < def; i++) {
            *(ptfp++) = IMAGE(ptf[i], ptp, dep);
        }
    }
    return fp;
}

Obj ProdTrans4Perm2(Obj f, Obj p)
{
    UInt4 * ptf, *ptfp;
    UInt2 * ptp;
    UInt    i, def, dep;
    Obj     fp;

    dep = DEG_PERM2(p);
    def = DEG_TRANS4(f);
    fp = NEW_TRANS4(MAX(def, dep));

    ptfp = ADDR_TRANS4(fp);
    ptf = ADDR_TRANS4(f);
    ptp = ADDR_PERM2(p);

    if (def <= dep) {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.
        for (i = 0; i < def; i++) {
            *(ptfp++) = ptp[*(ptf++)];
        }
        for (; i < dep; i++) {
            *(ptfp++) = ptp[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptfp++) = IMAGE(ptf[i], ptp, dep);
        }
    }
    return fp;
}

Obj ProdTrans4Perm4(Obj f, Obj p)
{
    UInt4 *ptf, *ptp, *ptfp;
    UInt   i, def, dep;
    Obj    fp;

    dep = DEG_PERM4(p);
    def = DEG_TRANS4(f);
    fp = NEW_TRANS4(MAX(def, dep));

    ptfp = ADDR_TRANS4(fp);
    ptf = ADDR_TRANS4(f);
    ptp = ADDR_PERM4(p);

    if (def <= dep) {
        for (i = 0; i < def; i++) {
            *(ptfp++) = ptp[*(ptf++)];
        }
        for (; i < dep; i++) {
            *(ptfp++) = ptp[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptfp++) = IMAGE(ptf[i], ptp, dep);
        }
    }
    return fp;
}

/*******************************************************************************
** Products for a permutation and transformation
*******************************************************************************/

Obj ProdPerm2Trans2(Obj p, Obj f)
{
    UInt2 *ptf, *ptp, *ptpf;
    UInt   i, def, dep;
    Obj    pf;

    dep = DEG_PERM2(p);
    def = DEG_TRANS2(f);
    pf = NEW_TRANS2(MAX(def, dep));

    ptpf = ADDR_TRANS2(pf);
    ptf = ADDR_TRANS2(f);
    ptp = ADDR_PERM2(p);

    if (dep <= def) {
        for (i = 0; i < dep; i++) {
            *(ptpf++) = ptf[*(ptp++)];
        }
        for (; i < def; i++) {
            *(ptpf++) = ptf[i];
        }
    }
    else {
        for (i = 0; i < dep; i++) {
            *(ptpf++) = IMAGE(ptp[i], ptf, def);
        }
    }
    return pf;
}

Obj ProdPerm2Trans4(Obj p, Obj f)
{
    UInt4 * ptf, *ptpf;
    UInt2 * ptp;
    UInt    i, def, dep;
    Obj     pf;

    dep = DEG_PERM2(p);
    def = DEG_TRANS4(f);
    pf = NEW_TRANS4(MAX(def, dep));

    ptpf = ADDR_TRANS4(pf);
    ptf = ADDR_TRANS4(f);
    ptp = ADDR_PERM2(p);

    if (dep <= def) {
        for (i = 0; i < dep; i++) {
            *(ptpf++) = ptf[*(ptp++)];
        }
        for (; i < def; i++) {
            *(ptpf++) = ptf[i];
        }
    }
    else {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.
        for (i = 0; i < dep; i++) {
            *(ptpf++) = IMAGE(ptp[i], ptf, def);
        }
    }
    return pf;
}

Obj ProdPerm4Trans2(Obj p, Obj f)
{
    UInt2 * ptf;
    UInt4 * ptp, *ptpf;
    UInt    i, def, dep;
    Obj     pf;

    dep = DEG_PERM4(p);
    def = DEG_TRANS2(f);
    pf = NEW_TRANS4(MAX(def, dep));

    ptpf = ADDR_TRANS4(pf);
    ptf = ADDR_TRANS2(f);
    ptp = ADDR_PERM4(p);

    if (dep <= def) {
        // I don't know how to create a permutation of type T_PERM4 with
        // (internal) degree 65536 or less, so this case isn't tested. It is
        // included to make the code more robust.
        for (i = 0; i < dep; i++) {
            *(ptpf++) = ptf[*(ptp++)];
        }
        for (; i < def; i++) {
            *(ptpf++) = ptf[i];
        }
    }
    else {
        for (i = 0; i < dep; i++) {
            *(ptpf++) = IMAGE(ptp[i], ptf, def);
        }
    }
    return pf;
}

Obj ProdPerm4Trans4(Obj p, Obj f)
{
    UInt4 *ptf, *ptp, *ptpf;
    UInt   i, def, dep;
    Obj    pf;

    dep = DEG_PERM4(p);
    def = DEG_TRANS4(f);
    pf = NEW_TRANS4(MAX(def, dep));

    ptpf = ADDR_TRANS4(pf);
    ptf = ADDR_TRANS4(f);
    ptp = ADDR_PERM4(p);

    if (dep <= def) {
        for (i = 0; i < dep; i++) {
            *(ptpf++) = ptf[*(ptp++)];
        }
        for (; i < def; i++) {
            *(ptpf++) = ptf[i];
        }
    }
    else {
        for (i = 0; i < dep; i++) {
            *(ptpf++) = IMAGE(ptp[i], ptf, def);
        }
    }
    return pf;
}

/*******************************************************************************
** Conjugate a transformation f by a permutation p: p ^ -1 * f * p
*******************************************************************************/

Obj PowTrans2Perm2(Obj f, Obj p)
{
    UInt2 *ptf, *ptp, *ptcnj;
    UInt   i, def, dep, decnj;
    Obj    cnj;

    dep = DEG_PERM2(p);
    def = DEG_TRANS2(f);
    decnj = MAX(dep, def);
    cnj = NEW_TRANS2(decnj);

    ptcnj = ADDR_TRANS2(cnj);
    ptf = ADDR_TRANS2(f);
    ptp = ADDR_PERM2(p);

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

Obj PowTrans2Perm4(Obj f, Obj p)
{
    UInt2 * ptf;
    UInt4 * ptp, *ptcnj;
    UInt    i, def, dep, decnj;
    Obj     cnj;

    dep = DEG_PERM4(p);
    def = DEG_TRANS2(f);
    decnj = MAX(dep, def);
    cnj = NEW_TRANS4(decnj);

    ptcnj = ADDR_TRANS4(cnj);
    ptf = ADDR_TRANS2(f);
    ptp = ADDR_PERM4(p);

    if (def == dep) {
        // I don't know how to create a permutation of type T_PERM4 with
        // (internal) degree 65536 or less, so this case isn't tested. It is
        // included to make the code more robust.
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

Obj PowTrans4Perm2(Obj f, Obj p)
{
    UInt2 * ptp;
    UInt4 * ptf, *ptcnj;
    UInt    i, def, dep, decnj;
    Obj     cnj;

    dep = DEG_PERM2(p);
    def = DEG_TRANS4(f);
    decnj = MAX(dep, def);
    cnj = NEW_TRANS4(decnj);

    ptcnj = ADDR_TRANS4(cnj);
    ptf = ADDR_TRANS4(f);
    ptp = ADDR_PERM2(p);

    if (def == dep) {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.
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

Obj PowTrans4Perm4(Obj f, Obj p)
{
    UInt4 *ptf, *ptp, *ptcnj;
    UInt   i, def, dep, decnj;
    Obj    cnj;

    dep = DEG_PERM4(p);
    def = DEG_TRANS4(f);
    decnj = MAX(dep, def);
    cnj = NEW_TRANS4(decnj);

    ptcnj = ADDR_TRANS4(cnj);
    ptf = ADDR_TRANS4(f);
    ptp = ADDR_PERM4(p);

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
** Quotient a transformation f by a permutation p: f * p ^ -1
*******************************************************************************/

Obj QuoTrans2Perm2(Obj f, Obj p)
{
    UInt    def, dep, i;
    UInt2 * ptf, *ptquo, *ptp;
    UInt4 * pttmp;
    Obj     quo;

    def = DEG_TRANS2(f);
    dep = DEG_PERM2(p);
    quo = NEW_TRANS2(MAX(def, dep));
    ResizeTmpTrans(SIZE_OBJ(p));

    // invert the permutation into the buffer bag
    pttmp = ADDR_TRANS4(TmpTrans);
    ptp = ADDR_PERM2(p);
    for (i = 0; i < dep; i++) {
        pttmp[*ptp++] = i;
    }

    ptf = ADDR_TRANS2(f);
    ptquo = ADDR_TRANS2(quo);

    if (def <= dep) {
        for (i = 0; i < def; i++) {
            *(ptquo++) = pttmp[*(ptf++)];
        }
        for (i = def; i < dep; i++) {
            *(ptquo++) = pttmp[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptquo++) = IMAGE(ptf[i], pttmp, dep);
        }
    }
    return quo;
}

Obj QuoTrans2Perm4(Obj f, Obj p)
{
    UInt    def, dep, i;
    UInt2 * ptf;
    UInt4 * ptquo, *ptp, *pttmp;
    Obj     quo;

    def = DEG_TRANS2(f);
    dep = DEG_PERM4(p);
    quo = NEW_TRANS4(MAX(def, dep));
    ResizeTmpTrans(SIZE_OBJ(p));

    // invert the permutation into the buffer bag
    pttmp = ADDR_TRANS4(TmpTrans);
    ptp = ADDR_PERM4(p);
    for (i = 0; i < dep; i++) {
        pttmp[*ptp++] = i;
    }

    ptf = ADDR_TRANS2(f);
    ptquo = ADDR_TRANS4(quo);

    if (def <= dep) {
        for (i = 0; i < def; i++) {
            *(ptquo++) = pttmp[*(ptf++)];
        }
        for (i = def; i < dep; i++) {
            *(ptquo++) = pttmp[i];
        }
    }
    else {
        // I don't know how to create a permutation of type T_PERM4 with
        // (internal) degree 65536 or less, so this case isn't tested. It is
        // included to make the code more robust.
        for (i = 0; i < def; i++) {
            *(ptquo++) = IMAGE(ptf[i], pttmp, dep);
        }
    }
    return quo;
}

Obj QuoTrans4Perm2(Obj f, Obj p)
{
    UInt    def, dep, i;
    UInt4 * ptf, *ptquo, *pttmp;
    UInt2 * ptp;
    Obj     quo;

    def = DEG_TRANS4(f);
    dep = DEG_PERM2(p);
    quo = NEW_TRANS4(MAX(def, dep));

    ResizeTmpTrans(SIZE_OBJ(p));

    // invert the permutation into the buffer bag
    pttmp = ADDR_TRANS4(TmpTrans);
    ptp = ADDR_PERM2(p);
    for (i = 0; i < dep; i++) {
        pttmp[*ptp++] = i;
    }

    ptf = ADDR_TRANS4(f);
    ptquo = ADDR_TRANS4(quo);

    if (def <= dep) {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.
        for (i = 0; i < def; i++) {
            *(ptquo++) = pttmp[*(ptf++)];
        }
        for (i = def; i < dep; i++) {
            *(ptquo++) = pttmp[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptquo++) = IMAGE(ptf[i], pttmp, dep);
        }
    }
    return quo;
}

Obj QuoTrans4Perm4(Obj f, Obj p)
{
    UInt   def, dep, i;
    UInt4 *ptf, *pttmp, *ptquo, *ptp;
    Obj    quo;

    def = DEG_TRANS4(f);
    dep = DEG_PERM4(p);
    quo = NEW_TRANS4(MAX(def, dep));

    ResizeTmpTrans(SIZE_OBJ(p));

    // invert the permutation into the buffer bag
    pttmp = ADDR_TRANS4(TmpTrans);
    ptp = ADDR_PERM4(p);
    for (i = 0; i < dep; i++) {
        pttmp[*ptp++] = i;
    }

    ptf = ADDR_TRANS4(f);
    ptquo = ADDR_TRANS4(quo);

    if (def <= dep) {
        for (i = 0; i < def; i++) {
            *(ptquo++) = pttmp[*(ptf++)];
        }
        for (i = def; i < dep; i++) {
            *(ptquo++) = pttmp[i];
        }
    }
    else {
        for (i = 0; i < def; i++) {
            *(ptquo++) = IMAGE(ptf[i], pttmp, dep);
        }
    }
    return quo;
}

/*******************************************************************************
** Left quotient a transformation f by a permutation p: p ^ -1 * f
*******************************************************************************/

Obj LQuoPerm2Trans2(Obj opL, Obj opR)
{
    UInt   degL, degR, degM, p;
    Obj    mod;
    UInt2 *ptL, *ptR, *ptM;

    degL = DEG_PERM2(opL);
    degR = DEG_TRANS2(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_TRANS2(degM);

    ptL = ADDR_PERM2(opL);
    ptR = ADDR_TRANS2(opR);
    ptM = ADDR_TRANS2(mod);

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

Obj LQuoPerm2Trans4(Obj opL, Obj opR)
{
    UInt    degL, degR, degM, p;
    Obj     mod;
    UInt2 * ptL;
    UInt4 * ptR, *ptM;

    degL = DEG_PERM2(opL);
    degR = DEG_TRANS4(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_TRANS4(degM);

    ptL = ADDR_PERM2(opL);
    ptR = ADDR_TRANS4(opR);
    ptM = ADDR_TRANS4(mod);

    if (degL <= degR) {
        for (p = 0; p < degL; p++) {
            ptM[*(ptL++)] = *(ptR++);
        }
        for (p = degL; p < degR; p++) {
            ptM[p] = *(ptR++);
        }
    }
    else {
        // The only transformation created within this file that is of type
        // T_TRANS4 and that does not have (internal) degree 65537 or greater
        // is ID_TRANS4.
        for (p = 0; p < degR; p++) {
            ptM[*(ptL++)] = *(ptR++);
        }
        for (p = degR; p < degL; p++) {
            ptM[*(ptL++)] = p;
        }
    }

    return mod;
}

Obj LQuoPerm4Trans2(Obj opL, Obj opR)
{
    UInt    degL, degR, degM, p;
    Obj     mod;
    UInt4 * ptL, *ptM;
    UInt2 * ptR;

    degL = DEG_PERM4(opL);
    degR = DEG_TRANS2(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_TRANS4(degM);

    ptL = ADDR_PERM4(opL);
    ptR = ADDR_TRANS2(opR);
    ptM = ADDR_TRANS4(mod);

    if (degL <= degR) {
        // I don't know how to create a permutation of type T_PERM4 with
        // (internal) degree 65536 or less, so this case isn't tested. It is
        // included to make the code more robust.
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

Obj LQuoPerm4Trans4(Obj opL, Obj opR)
{
    UInt   degL, degR, degM, p;
    Obj    mod;
    UInt4 *ptL, *ptR, *ptM;

    degL = DEG_PERM4(opL);
    degR = DEG_TRANS4(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_TRANS4(degM);

    ptL = ADDR_PERM4(opL);
    ptR = ADDR_TRANS4(opR);
    ptM = ADDR_TRANS4(mod);

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

Obj PowIntTrans2(Obj i, Obj f)
{
    Int img;

    if (TNUM_OBJ(i) == T_INTPOS) {
        return i;
    }

    img = INT_INTOBJ(i);

    if (img <= 0) {
        ErrorQuit("Tran. Operations: <point> must be a positive integer "
                  "(not %d)",
                  (Int)img, 0L);
    }

    if ((UInt)img <= DEG_TRANS2(f)) {
        img = (ADDR_TRANS2(f))[img - 1] + 1;
    }

    return INTOBJ_INT(img);
}

Obj PowIntTrans4(Obj i, Obj f)
{
    Int img;

    if (TNUM_OBJ(i) == T_INTPOS) {
        return i;
    }

    img = INT_INTOBJ(i);

    if (img <= 0) {
        ErrorQuit(
            "Tran. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L);
    }

    if ((UInt)img <= DEG_TRANS4(f)) {
        img = (ADDR_TRANS4(f))[img - 1] + 1;
    }

    return INTOBJ_INT(img);
}

/*******************************************************************************
** Apply a transformation to a set or tuple
*******************************************************************************/

// OnSetsTrans for use in FuncOnSets.

Obj OnSetsTrans(Obj set, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg;
    Obj *   ptset, *ptres, tmp, res;
    UInt    i, isint, k;

    res = NEW_PLIST(IS_MUTABLE_PLIST(set) ? T_PLIST : T_PLIST + IMMUTABLE,
                    LEN_LIST(set));

    ADDR_OBJ(res)[0] = ADDR_OBJ(set)[0];

    ptset = ADDR_OBJ(set) + LEN_LIST(set);
    ptres = ADDR_OBJ(res) + LEN_LIST(set);
    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);
        // loop over the entries of the tuple
        isint = 1;
        for (i = LEN_LIST(set); 1 <= i; i--, ptset--, ptres--) {
            if (IS_INTOBJ(*ptset) && 0 < INT_INTOBJ(*ptset)) {
                k = INT_INTOBJ(*ptset);
                if (k <= deg) {
                    k = ptf2[k - 1] + 1;
                }
                *ptres = INTOBJ_INT(k);
            }
            else {
                isint = 0;
                tmp = POW(*ptset, f);
                ptset = ADDR_OBJ(set) + i;
                ptres = ADDR_OBJ(res) + i;
                ptf2 = ADDR_TRANS2(f);
                *ptres = tmp;
                CHANGED_BAG(res);
            }
        }
    }
    else {
        ptf4 = ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);

        // loop over the entries of the tuple
        isint = 1;
        for (i = LEN_LIST(set); 1 <= i; i--, ptset--, ptres--) {
            if (IS_INTOBJ(*ptset) && 0 < INT_INTOBJ(*ptset)) {
                k = INT_INTOBJ(*ptset);
                if (k <= deg) {
                    k = ptf4[k - 1] + 1;
                }
                *ptres = INTOBJ_INT(k);
            }
            else {
                isint = 0;
                tmp = POW(*ptset, f);
                ptset = ADDR_OBJ(set) + i;
                ptres = ADDR_OBJ(res) + i;
                ptf4 = ADDR_TRANS4(f);
                *ptres = tmp;
                CHANGED_BAG(res);
            }
        }
    }

    // sort the result and remove dups
    if (isint) {
        SORT_PLIST_CYC(res);
        REMOVE_DUPS_PLIST_CYC(res);

        RetypeBag(res, IS_MUTABLE_PLIST(set) ? T_PLIST_CYC_SSORT
                                             : T_PLIST_CYC_SSORT + IMMUTABLE);
    }
    else {
        SortDensePlist(res);
        RemoveDupsDensePlist(res);
    }

    return res;
}

// OnTuplesTrans for use in FuncOnTuples

Obj OnTuplesTrans(Obj tup, Obj f)
{
    UInt2 * ptf2;
    UInt4 * ptf4;
    UInt    deg, i, k;
    Obj *   pttup, *ptres, res, tmp;

    res = NEW_PLIST(IS_MUTABLE_PLIST(tup) ? T_PLIST : T_PLIST + IMMUTABLE,
                    LEN_LIST(tup));

    ADDR_OBJ(res)[0] = ADDR_OBJ(tup)[0];

    pttup = ADDR_OBJ(tup) + LEN_LIST(tup);
    ptres = ADDR_OBJ(res) + LEN_LIST(tup);

    if (TNUM_OBJ(f) == T_TRANS2) {
        ptf2 = ADDR_TRANS2(f);
        deg = DEG_TRANS2(f);

        // loop over the entries of the tuple
        for (i = LEN_LIST(tup); 1 <= i; i--, pttup--, ptres--) {
            if (IS_INTOBJ(*pttup) && 0 < INT_INTOBJ(*pttup)) {
                k = INT_INTOBJ(*pttup);
                if (k <= deg) {
                    k = ptf2[k - 1] + 1;
                }
                *ptres = INTOBJ_INT(k);
            }
            else {
                if (*pttup == NULL) {
                    ErrorQuit("OnTuples for transformation: list must not "
                              "contain holes",
                              0L, 0L);
                }
                tmp = POW(*pttup, f);
                pttup = ADDR_OBJ(tup) + i;
                ptres = ADDR_OBJ(res) + i;
                ptf2 = ADDR_TRANS2(f);
                *ptres = tmp;
                CHANGED_BAG(res);
            }
        }
    }
    else {
        ptf4 = ADDR_TRANS4(f);
        deg = DEG_TRANS4(f);

        // loop over the entries of the tuple
        for (i = LEN_LIST(tup); 1 <= i; i--, pttup--, ptres--) {
            if (IS_INTOBJ(*pttup) && 0 < INT_INTOBJ(*pttup)) {
                k = INT_INTOBJ(*pttup);
                if (k <= deg) {
                    k = ptf4[k - 1] + 1;
                }
                *ptres = INTOBJ_INT(k);
            }
            else {
                if (*pttup == NULL) {
                    ErrorQuit("OnTuples for transformation: list must not "
                              "contain holes",
                              0L, 0L);
                }
                tmp = POW(*pttup, f);
                pttup = ADDR_OBJ(tup) + i;
                ptres = ADDR_OBJ(res) + i;
                ptf4 = ADDR_TRANS4(f);
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

// Save and load
void SaveTrans2(Obj f)
{
    UInt2 * ptr;
    UInt    len, i;
    ptr = ADDR_TRANS2(f);    // save the image list
    len = DEG_TRANS2(f);
    for (i = 0; i < len; i++) {
        SaveUInt2(*ptr++);
    }
}

void LoadTrans2(Obj f)
{
    UInt2 * ptr;
    UInt    len, i;
    len = DEG_TRANS2(f);
    ptr = ADDR_TRANS2(f);
    for (i = 0; i < len; i++) {
        *ptr++ = LoadUInt2();
    }
}

void SaveTrans4(Obj f)
{
    UInt4 * ptr;
    UInt    len, i;
    ptr = ADDR_TRANS4(f);    // save the image list
    len = DEG_TRANS4(f);
    for (i = 0; i < len; i++) {
        SaveUInt4(*ptr++);
    }
}

void LoadTrans4(Obj f)
{
    UInt4 * ptr;
    UInt    len, i;
    len = DEG_TRANS4(f);
    ptr = ADDR_TRANS4(f);
    for (i = 0; i < len; i++) {
        *ptr++ = LoadUInt4();
    }
}

Obj TYPE_TRANS2;

Obj TypeTrans2(Obj f)
{
    return TYPE_TRANS2;
}

Obj TYPE_TRANS4;

Obj TypeTrans4(Obj f)
{
    return TYPE_TRANS4;
}

Obj IsTransFilt;

Obj IsTransHandler(Obj self, Obj val)
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

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * *
 */

/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts[] = {

    { "IS_TRANS", "obj", &IsTransFilt, IsTransHandler,
      "src/trans.c:IS_TRANS" },

    { 0, 0, 0, 0, 0 }

};

/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    /*  GVAR_FUNC(HAS_KER_TRANS, 1, "f"),
      GVAR_FUNC(HAS_IMG_TRANS, 1, "f"),
      GVAR_FUNC(INT_DEG_TRANS, 1, "f"),
        */

    GVAR_FUNC(TransformationNC, 1, "list"),
    GVAR_FUNC(TransformationListListNC, 2, "src, ran"),
    GVAR_FUNC(DegreeOfTransformation, 1, "f"),
    GVAR_FUNC(HASH_FUNC_FOR_TRANS, 2, "f, data"),
    GVAR_FUNC(RANK_TRANS, 1, "f"),
    GVAR_FUNC(RANK_TRANS_INT, 2, "f, n"),
    GVAR_FUNC(RANK_TRANS_LIST, 2, "f, list"),
    GVAR_FUNC(LARGEST_MOVED_PT_TRANS, 1, "f"),
    GVAR_FUNC(LARGEST_IMAGE_PT, 1, "f"),
    GVAR_FUNC(SMALLEST_MOVED_PT_TRANS, 1, "f"),
    GVAR_FUNC(SMALLEST_IMAGE_PT, 1, "f"),
    GVAR_FUNC(NR_MOVED_PTS_TRANS, 1, "f"),
    GVAR_FUNC(MOVED_PTS_TRANS, 1, "f"),
    GVAR_FUNC(IMAGE_LIST_TRANS_INT, 2, "f, n"),
    GVAR_FUNC(FLAT_KERNEL_TRANS, 1, "f"),
    GVAR_FUNC(FLAT_KERNEL_TRANS_INT, 2, "f, n"),
    GVAR_FUNC(IMAGE_SET_TRANS, 1, "f"),
    GVAR_FUNC(UNSORTED_IMAGE_SET_TRANS, 1, "f"),
    GVAR_FUNC(IMAGE_SET_TRANS_INT, 2, "f, n"),
    GVAR_FUNC(KERNEL_TRANS, 2, "f, n"),
    GVAR_FUNC(PREIMAGES_TRANS_INT, 2, "f, pt"),
    GVAR_FUNC(AS_TRANS_PERM, 1, "f"),
    GVAR_FUNC(AS_TRANS_PERM_INT, 2, "f, n"),
    GVAR_FUNC(AS_PERM_TRANS, 1, "f"),
    GVAR_FUNC(PermutationOfImage, 1, "f"),
    GVAR_FUNC(RestrictedTransformation, 2, "f, list"),
    GVAR_FUNC(AS_TRANS_TRANS, 2, "f, m"),
    GVAR_FUNC(TRIM_TRANS, 2, "f, m"),
    GVAR_FUNC(IsInjectiveListTrans, 2, "t, l"),
    GVAR_FUNC(PermLeftQuoTransformationNC, 2, "f, g"),
    GVAR_FUNC(TRANS_IMG_KER_NC, 2, "img, ker"),
    GVAR_FUNC(IDEM_IMG_KER_NC, 2, "img, ker"),
    GVAR_FUNC(InverseOfTransformation, 1, "f"),
    GVAR_FUNC(INV_LIST_TRANS, 2, "list, f"),
    GVAR_FUNC(TRANS_IMG_CONJ, 2, "f, g"),
    GVAR_FUNC(IndexPeriodOfTransformation, 1, "f"),
    GVAR_FUNC(SMALLEST_IDEM_POW_TRANS, 1, "f"),
    GVAR_FUNC(POW_KER_PERM, 2, "ker, f"),
    GVAR_FUNC(ON_KERNEL_ANTI_ACTION, 3, "ker, f, n"),
    GVAR_FUNC(INV_KER_TRANS, 2, "ker, f"),
    GVAR_FUNC(IS_IDEM_TRANS, 1, "f"),
    GVAR_FUNC(IS_ID_TRANS, 1, "f"),
    GVAR_FUNC(COMPONENT_REPS_TRANS, 1, "f"),
    GVAR_FUNC(NR_COMPONENTS_TRANS, 1, "f"),
    GVAR_FUNC(COMPONENTS_TRANS, 1, "f"),
    GVAR_FUNC(COMPONENT_TRANS_INT, 2, "f, pt"),
    GVAR_FUNC(CYCLE_TRANS_INT, 2, "f, pt"),
    GVAR_FUNC(CYCLES_TRANS, 1, "f"),
    GVAR_FUNC(CYCLES_TRANS_LIST, 2, "f, pt"),
    GVAR_FUNC(LEFT_ONE_TRANS, 1, "f"),
    GVAR_FUNC(RIGHT_ONE_TRANS, 1, "f"),
    GVAR_FUNC(OnPosIntSetsTrans, 3, "set, f, n"),
    { 0, 0, 0, 0, 0 }

};
/******************************************************************************
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{

    /* install the marking functions                                       */
    InfoBags[T_TRANS2].name = "transformation (small)";
    InfoBags[T_TRANS4].name = "transformation (large)";
    InitMarkFuncBags(T_TRANS2, MarkThreeSubBags);
    InitMarkFuncBags(T_TRANS4, MarkThreeSubBags);

    MakeBagTypePublic(T_TRANS2);
    MakeBagTypePublic(T_TRANS4);

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
    InitGlobalBag(&TmpTrans, "src/trans.c:TmpTrans");
#endif

    // make the identity trans
    InitGlobalBag(&IdentityTrans, "src/trans.c:IdentityTrans");

    /* install the saving functions */
    SaveObjFuncs[T_TRANS2] = SaveTrans2;
    LoadObjFuncs[T_TRANS2] = LoadTrans2;
    SaveObjFuncs[T_TRANS4] = SaveTrans4;
    LoadObjFuncs[T_TRANS4] = LoadTrans4;

    /* install the comparison methods                                      */
    EqFuncs[T_TRANS2][T_TRANS2] = EqTrans22;
    EqFuncs[T_TRANS2][T_TRANS4] = EqTrans24;
    EqFuncs[T_TRANS4][T_TRANS2] = EqTrans42;
    EqFuncs[T_TRANS4][T_TRANS4] = EqTrans44;
    LtFuncs[T_TRANS2][T_TRANS2] = LtTrans22;
    LtFuncs[T_TRANS2][T_TRANS4] = LtTrans24;
    LtFuncs[T_TRANS4][T_TRANS2] = LtTrans42;
    LtFuncs[T_TRANS4][T_TRANS4] = LtTrans44;

    /* install the binary operations */
    ProdFuncs[T_TRANS2][T_TRANS2] = ProdTrans22;
    ProdFuncs[T_TRANS4][T_TRANS4] = ProdTrans44;
    ProdFuncs[T_TRANS2][T_TRANS4] = ProdTrans24;
    ProdFuncs[T_TRANS4][T_TRANS2] = ProdTrans42;
    ProdFuncs[T_TRANS2][T_PERM2] = ProdTrans2Perm2;
    ProdFuncs[T_TRANS2][T_PERM4] = ProdTrans2Perm4;
    ProdFuncs[T_TRANS4][T_PERM2] = ProdTrans4Perm2;
    ProdFuncs[T_TRANS4][T_PERM4] = ProdTrans4Perm4;
    ProdFuncs[T_PERM2][T_TRANS2] = ProdPerm2Trans2;
    ProdFuncs[T_PERM4][T_TRANS2] = ProdPerm4Trans2;
    ProdFuncs[T_PERM2][T_TRANS4] = ProdPerm2Trans4;
    ProdFuncs[T_PERM4][T_TRANS4] = ProdPerm4Trans4;
    PowFuncs[T_TRANS2][T_PERM2] = PowTrans2Perm2;
    PowFuncs[T_TRANS2][T_PERM4] = PowTrans2Perm4;
    PowFuncs[T_TRANS4][T_PERM2] = PowTrans4Perm2;
    PowFuncs[T_TRANS4][T_PERM4] = PowTrans4Perm4;
    QuoFuncs[T_TRANS2][T_PERM2] = QuoTrans2Perm2;
    QuoFuncs[T_TRANS2][T_PERM4] = QuoTrans2Perm4;
    QuoFuncs[T_TRANS4][T_PERM2] = QuoTrans4Perm2;
    QuoFuncs[T_TRANS4][T_PERM4] = QuoTrans4Perm4;
    LQuoFuncs[T_PERM2][T_TRANS2] = LQuoPerm2Trans2;
    LQuoFuncs[T_PERM4][T_TRANS2] = LQuoPerm4Trans2;
    LQuoFuncs[T_PERM2][T_TRANS4] = LQuoPerm2Trans4;
    LQuoFuncs[T_PERM4][T_TRANS4] = LQuoPerm4Trans4;
    PowFuncs[T_INT][T_TRANS2] = PowIntTrans2;
    PowFuncs[T_INT][T_TRANS4] = PowIntTrans4;
    PowFuncs[T_INTPOS][T_TRANS2] = PowIntTrans2;
    PowFuncs[T_INTPOS][T_TRANS4] = PowIntTrans4;

    /* install the 'ONE' function for transformations */
    OneFuncs[T_TRANS2] = OneTrans;
    OneMutFuncs[T_TRANS2] = OneTrans;
    OneFuncs[T_TRANS4] = OneTrans;
    OneMutFuncs[T_TRANS4] = OneTrans;

    /* return success                                                      */
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
    TmpTrans = 0;
    IdentityTrans = NEW_TRANS2(0);

    // We make the next transformation to allow testing of some parts of the
    // code which would not otherwise be accessible, since no other
    // transformation created in this file is a T_TRANS4 unless its internal
    // degree is > 65536. Such transformation can be created by packages with
    // a
    // kernel module, and so we introduce the next transformation for testing
    // purposes.
    Obj ID_TRANS4 = NEW_TRANS4(0);
    AssGVar(GVarName("ID_TRANS4"), ID_TRANS4);
    MakeReadOnlyGVar(GVarName("ID_TRANS4"));

    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  InitInfoTrans()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN, /* type                           */
    "trans",        /* name                           */
    0,              /* revision entry of c file       */
    0,              /* revision entry of h file       */
    0,              /* version                        */
    0,              /* crc                            */
    InitKernel,     /* initKernel                     */
    InitLibrary,    /* initLibrary                    */
    0,              /* checkInit                      */
    0,              /* preSave                        */
    0,              /* postSave                       */
    0               /* postRestore                    */
};

StructInitInfo * InitInfoTrans(void)
{
    return &module;
}
