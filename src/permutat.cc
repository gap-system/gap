/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions for permutations (small and large).
**
**  Mathematically a permutation is a bijective mapping  of a finite set onto
**  itself.  In \GAP\ this subset must always be of the form [ 1, 2, .., N ],
**  where N is at most $2^32$.
**
**  Internally a permutation <p> is viewed as a mapping of [ 0, 1, .., N-1 ],
**  because in C indexing of  arrays is done with the origin  0 instead of 1.
**  A permutation is represented by a bag of type 'T_PERM2' or 'T_PERM4' of
**  the form
**
**      (CONST_)ADDR_OBJ(p)
**      |
**      v
**      +------+-------+-------+-------+-------+- - - -+-------+-------+
**      | inv. | image | image | image | image |       | image | image |
**      | perm | of  0 | of  1 | of  2 | of  3 |       | of N-2| of N-1|
**      +------+-------+-------+-------+-------+- - - -+-------+-------+
**             ^
**             |
**             (CONST_)ADDR_PERM2(p) resp. (CONST_)ADDR_PERM4(p)
**
**  The first entry of the bag <p> is either zero, or a reference to another
**  permutation representing the inverse of <p>. The remaining entries of the
**  bag form an array describing the permutation. For bags of type 'T_PERM2',
**  the entries are of type 'UInt2' (defined in 'system.h' as an 16 bit wide
**  unsigned integer type), for type 'T_PERM4' the entries are of type
**  'UInt4' (defined as a 32bit wide unsigned integer type). The first of
**  these entries is the image of 0, the second is the image of 1, and so on.
**  Thus, the entry at C index <i> is the image of <i>, if we view the
**  permutation as mapping of [ 0, 1, 2, .., N-1 ] as described above.
**
**  Permutations are never  shortened.  For  example, if  the product  of two
**  permutations of degree 100 is the identity, it  is nevertheless stored as
**  array of length 100, in  which the <i>-th  entry is of course simply <i>.
**  Testing whether a product has trailing  fixpoints would be pretty costly,
**  and permutations of equal degree can be handled by the functions faster.
*/

extern "C" {

#include "permutat.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "gapstate.h"
#include "integer.h"
#include "io.h"
#include "listfunc.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "precord.h"
#include "range.h"
#include "records.h"
#include "saveload.h"
#include "sysfiles.h"
#include "trans.h"

} // extern "C"


#ifdef GAP_KERNEL_DEBUG
template <typename T>
static bool CHECK_PERM_TYPE(Obj perm);

template <>
inline bool CHECK_PERM_TYPE<UInt2>(Obj perm)
{
    return TNUM_OBJ(perm) == T_PERM2;
}

template <>
inline bool CHECK_PERM_TYPE<UInt4>(Obj perm)
{
    return TNUM_OBJ(perm) == T_PERM4;
}
#endif

template <typename T>
static inline UInt SIZEBAG_PERM(UInt deg)
{
    return sizeof(Obj) + deg * sizeof(T);
}

template <typename T>
static inline Obj NEW_PERM(UInt deg)
{
    return NewBag(sizeof(T) == 2 ? T_PERM2 : T_PERM4, SIZEBAG_PERM<T>(deg));
}

template <typename T>
static inline UInt DEG_PERM(Obj perm)
{
    GAP_ASSERT(CHECK_PERM_TYPE<T>(perm));
    return (SIZE_OBJ(perm) - sizeof(Obj)) / sizeof(T);
}

template <typename T>
static inline T * ADDR_PERM(Obj perm)
{
    GAP_ASSERT(CHECK_PERM_TYPE<T>(perm));
    return (T *)(ADDR_OBJ(perm) + 1);
}

template <typename T>
static inline const T * CONST_ADDR_PERM(Obj perm)
{
    GAP_ASSERT(CHECK_PERM_TYPE<T>(perm));
    return (const T *)(CONST_ADDR_OBJ(perm) + 1);
}

//
// The 'ResultType' template is used by functions which take two permutations
// as argument to select the type of the output they produce: by default, a
// T_PERM4, whose entries are stored as UInt4. But if both inputs are
// T_PERM2, then as a special case the output is also a T_PERM2, whose
// entries are stored as UInt2.
//
template <typename TL, typename TR>
struct ResultType {
    typedef UInt4 type;
};
template <>
struct ResultType<UInt2, UInt2> {
    typedef UInt2 type;
};

/****************************************************************************
**
*F  IMAGE(<i>,<pt>,<dg>)  . . . . . .  image of <i> under <pt> of degree <dg>
**
**  'IMAGE'  returns the  image of the   point <i> under  the permutation  of
**  degree <dg> pointed to  by <pt>.   If the  point  <i> is greater  than or
**  equal to <dg> the image is <i> itself.
**
**  'IMAGE' is  implemented as a macro so  do not use  it with arguments that
**  have side effects.
*/
#define IMAGE(i,pt,dg)  (((i) < (dg)) ? (pt)[(i)] : (i))


/****************************************************************************
**
*V  IdentityPerm  . . . . . . . . . . . . . . . . . . .  identity permutation
**
**  'IdentityPerm' is an identity permutation.
*/
Obj             IdentityPerm;



static ModuleStateOffset PermutatStateOffset = -1;

typedef struct {

/****************************************************************************
**
*V  TmpPerm . . . . . . . handle of the buffer bag of the permutation package
**
**  'TmpPerm' is the handle  of a bag of type  'T_PERM4', which is created at
**  initialization time  of this package.  Functions  in this package can use
**  this bag for  whatever  purpose they want.  They   have to make sure   of
**  course that it is large enough.
**  The buffer is *not* guaranteed to have any particular value, routines
**  that require a zero-initialization need to do this at the start.
**  This buffer is only constructed once it is needed, to avoid startup
**  costs (particularly when starting new threads).
**  Use the UseTmpPerm(<size>) utility function to ensure it is constructed!
*/
Obj TmpPerm;

} PermutatModuleState;

#define  TmpPerm MODULE_STATE(Permutat).TmpPerm


static UInt1 * UseTmpPerm(UInt size)
{
    if (TmpPerm == (Obj)0)
        TmpPerm  = NewBag(T_PERM4, size);
    else if (SIZE_BAG(TmpPerm) < size)
        ResizeBag(TmpPerm, size);
    return (UInt1 *)(ADDR_OBJ(TmpPerm) + 1);
}

template <typename T>
static inline T * ADDR_TMP_PERM()
{
    // no GAP_ASSERT here on purpose
    return (T *)(ADDR_OBJ(TmpPerm) + 1);
}


/****************************************************************************
**
*F  TypePerm( <perm> )  . . . . . . . . . . . . . . . . type of a permutation
**
**  'TypePerm' returns the type of permutations.
**
**  'TypePerm' is the function in 'TypeObjFuncs' for permutations.
*/
Obj             TYPE_PERM2;

Obj             TYPE_PERM4;

Obj             TypePerm2 (
    Obj                 perm )
{
    return TYPE_PERM2;
}

Obj             TypePerm4 (
    Obj                 perm )
{
    return TYPE_PERM4;
}


/****************************************************************************
**
*F  PrintPerm( <perm> ) . . . . . . . . . . . . . . . . . print a permutation
**
**  'PrintPerm' prints the permutation <perm> in the usual cycle notation. It
**  uses the degree to print all points with same width, which  looks  nicer.
**  Linebreaks are prefered most after cycles and  next  most  after  commas.
**
**  It does not remember which points have already  been  printed.  To  avoid
**  printing a cycle twice each is printed with the smallest  element  first.
**  This may in the worst case, for (1,2,..,n), take n^2/2 steps, but is fast
**  enough to keep a terminal at 9600 baud busy for all but the extrem cases.
*/
template <typename T>
void PrintPerm(Obj perm)
{
    UInt                degPerm;        /* degree of the permutation       */
    const T *           ptPerm;         /* pointer to the permutation      */
    UInt                p,  q;          /* loop variables                  */
    UInt                isId;           /* permutation is the identity?    */
    const char *        fmt1;           /* common formats to print points  */
    const char *        fmt2;           /* common formats to print points  */

    /* set up the formats used, so all points are printed with equal width */
    degPerm = DEG_PERM<T>(perm);
    if      ( degPerm <    10 ) { fmt1 = "%>(%>%1d%<"; fmt2 = ",%>%1d%<"; }
    else if ( degPerm <   100 ) { fmt1 = "%>(%>%2d%<"; fmt2 = ",%>%2d%<"; }
    else if ( degPerm <  1000 ) { fmt1 = "%>(%>%3d%<"; fmt2 = ",%>%3d%<"; }
    else if ( degPerm < 10000 ) { fmt1 = "%>(%>%4d%<"; fmt2 = ",%>%4d%<"; }
    else                        { fmt1 = "%>(%>%5d%<"; fmt2 = ",%>%5d%<"; }

    /* run through all points                                              */
    isId = 1;
    ptPerm = CONST_ADDR_PERM<T>(perm);
    for ( p = 0; p < degPerm; p++ ) {

        /* find the smallest element in this cycle                         */
        q = ptPerm[p];
        while ( p < q )  q = ptPerm[q];

        /* if the smallest is the one we started with lets print the cycle */
        if ( p == q && ptPerm[p] != p ) {
            isId = 0;
            Pr(fmt1,(Int)(p+1),0L);
            ptPerm = CONST_ADDR_PERM<T>(perm);
            for ( q = ptPerm[p]; q != p; q = ptPerm[q] ) {
                Pr(fmt2,(Int)(q+1),0L);
                ptPerm = CONST_ADDR_PERM<T>(perm);
            }
            Pr("%<)",0L,0L);
            /* restore pointer, in case Pr caused a garbage collection */
            ptPerm = CONST_ADDR_PERM<T>(perm);
        }

    }

    /* special case for the identity                                       */
    if ( isId )  Pr("()",0L,0L);
}


/****************************************************************************
**
*F  EqPerm( <opL>, <opR> )  . . . . . . .  test if two permutations are equal
**
**  'EqPerm' returns 'true' if the two permutations <opL> and <opR> are equal
**  and 'false' otherwise.
**
**  Two permutations may be equal, even if the two sequences do not have  the
**  same length, if  the  larger  permutation  fixes  the  exceeding  points.
**
*/
template <typename TL, typename TR>
Int EqPerm(Obj opL, Obj opR)
{
    UInt                degL;           /* degree of the left operand      */
    const TL *          ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const TR *          ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees                                                     */
    degL = DEG_PERM<TL>(opL);
    degR = DEG_PERM<TR>(opR);

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM<TL>(opL);
    ptR = CONST_ADDR_PERM<TR>(opR);

    /* search for a difference and return False if you find one          */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) )
                return 0L;
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) )
                return 0L;
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) )
                return 0L;
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) !=        p )
                return 0L;
    }

    /* otherwise they must be equal                                        */
    return 1L;
}


/****************************************************************************
**
*F  LtPerm( <opL>, <opR> )  . test if one permutation is smaller than another
**
**  'LtPerm' returns  'true' if the permutation <opL>  is strictly  less than
**  the permutation  <opR>.  Permutations are  ordered lexicographically with
**  respect to the images of 1,2,.., etc.
*/
template <typename TL, typename TR>
Int LtPerm(Obj opL, Obj opR)
{
    UInt                degL;           /* degree of the left operand      */
    const TL *          ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const TR *          ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM<TL>(opL);
    degR = DEG_PERM<TR>(opR);

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM<TL>(opL);
    ptR = CONST_ADDR_PERM<TR>(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {

        for (p = 0; p < degL; p++, ptL++, ptR++)
            if (*ptL != *ptR) {
                return *ptL < *ptR;
            }
        for (p = degL; p < degR; p++, ptR++)
            if (p != *ptR) {
                return p < *ptR;
            }
    }
    else {
        for (p = 0; p < degR; p++, ptL++, ptR++)
            if (*ptL != *ptR) {
                return *ptL < *ptR;
            }
        for (p = degR; p < degL; p++, ptL++)
            if (*ptL != p) {
                return *ptL < p;
            }
    }

    /* otherwise they must be equal                                        */
    return 0;
}


/****************************************************************************
**
*F  ProdPerm( <opL>, <opR> )  . . . . . . . . . . . . product of permutations
**
**  'ProdPerm' returns the product of the two permutations <opL> and <opR>.
**
**  This is a little bit tuned but should be sufficiently easy to understand.
*/
template <typename TL, typename TR>
Obj ProdPerm(Obj opL, Obj opR)
{
    typedef typename ResultType<TL,TR>::type Res;

    Obj                 prd;            /* handle of the product (result)  */
    UInt                degP;           /* degree of the product           */
    Res *               ptP;            /* pointer to the product          */
    UInt                degL;           /* degree of the left operand      */
    const TL *          ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const TR *          ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM<TL>(opL);
    degR = DEG_PERM<TR>(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM<Res>( degP );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM<TL>(opL);
    ptR = CONST_ADDR_PERM<TR>(opR);
    ptP = ADDR_PERM<Res>(prd);

    /* if the left (inner) permutation has smaller degree, it is very easy */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            *(ptP++) = ptR[ *(ptL++) ];
        for ( p = degL; p < degR; p++ )
            *(ptP++) = ptR[ p ];
    }

    /* otherwise we have to use the macro 'IMAGE'                          */
    else {
        for ( p = 0; p < degL; p++ )
            *(ptP++) = IMAGE( ptL[ p ], ptR, degR );
    }

    /* return the result                                                   */
    return prd;
}


/****************************************************************************
**
*F  QuoPerm( <opL>, <opR> ) . . . . . . . . . . . .  quotient of permutations
**
**  'QuoPerm' returns the quotient of the permutations <opL> and <opR>, i.e.,
**  the product '<opL>\*<opR>\^-1'.
**
**  Unfortunatly this can not be done in <degree> steps, we need 2 * <degree>
**  steps.
*/
Obj QuoPerm(Obj opL, Obj opR)
{
    return PROD(opL, INV(opR));
}


/****************************************************************************
**
*F  LQuoPerm( <opL>, <opR> )  . . . . . . . . . left quotient of permutations
**
**  'LQuoPerm' returns the  left quotient of  the  two permutations <opL> and
**  <opR>, i.e., the value of '<opL>\^-1*<opR>', which sometimes comes handy.
**
**  This can be done as fast as a single multiplication or inversion.
*/
template <typename TL, typename TR>
Obj LQuoPerm(Obj opL, Obj opR)
{
    typedef typename ResultType<TL,TR>::type Res;

    Obj                 mod;            /* handle of the quotient (result) */
    UInt                degM;           /* degree of the quotient          */
    Res *               ptM;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    const TL *          ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const TR *          ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM<TL>(opL);
    degR = DEG_PERM<TR>(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM<Res>( degM );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM<TL>(opL);
    ptR = CONST_ADDR_PERM<TR>(opR);
    ptM = ADDR_PERM<Res>(mod);

    /* it is one thing if the left (inner) permutation is smaller          */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            ptM[ *(ptL++) ] = *(ptR++);
        for ( p = degL; p < degR; p++ )
            ptM[ p ] = *(ptR++);
    }

    /* and another if the right (outer) permutation is smaller             */
    else {
        for ( p = 0; p < degR; p++ )
            ptM[ *(ptL++) ] = *(ptR++);
        for ( p = degR; p < degL; p++ )
            ptM[ *(ptL++) ] = p;
    }

    /* return the result                                                   */
    return mod;
}


/****************************************************************************
**
*F  InvPerm( <perm> ) . . . . . . . . . . . . . . .  inverse of a permutation
*/
template <typename T>
Obj InvPerm(Obj perm)
{
    Obj                 inv;            /* handle of the inverse (result)  */
    T *                 ptInv;          /* pointer to the inverse          */
    const T *           ptPerm;         /* pointer to the permutation      */
    UInt                deg;            /* degree of the permutation       */
    UInt                p;              /* loop variables                  */

    inv = STOREDINV_PERM(perm);
    if (inv != 0)
        return inv;

    deg = DEG_PERM<T>(perm);
    inv = NEW_PERM<T>(deg);

    // get pointer to the permutation and the inverse
    ptPerm = CONST_ADDR_PERM<T>(perm);
    ptInv = ADDR_PERM<T>(inv);

    // invert the permutation
    for ( p = 0; p < deg; p++ )
        ptInv[ *ptPerm++ ] = p;

    // store and return the inverse
    SET_STOREDINV_PERM(perm, inv);
    return inv;
}


/****************************************************************************
**
*F  PowPermInt( <opL>, <opR> )  . . . . . . .  integer power of a permutation
**
**  'PowPermInt' returns the <opR>-th power  of the permutation <opL>.  <opR>
**  must be a small integer.
**
**  This repeatedly applies the permutation <opR> to all points  which  seems
**  to be faster than binary powering, and does not need  temporary  storage.
*/
template <typename T>
Obj PowPermInt(Obj opL, Obj opR)
{
    Obj                 pow;            /* handle of the power (result)    */
    T *                 ptP;            /* pointer to the power            */
    const T *           ptL;            /* pointer to the permutation      */
    UInt1 *             ptKnown;        /* pointer to temporary bag        */
    UInt                deg;            /* degree of the permutation       */
    Int                 exp,  e;        /* exponent (right operand)        */
    UInt                len;            /* length of cycle (result)        */
    UInt                p,  q,  r;      /* loop variables                  */


    /* handle zeroth and first powers and stored inverses separately */
    if ( opR == INTOBJ_INT(0)) 
      return IdentityPerm;
    if ( opR == INTOBJ_INT(1))
      return opL;
    if (opR == INTOBJ_INT(-1))
        return InvPerm<T>(opL);

    /* get the operands and allocate a result bag                          */
    deg = DEG_PERM<T>(opL);
    pow = NEW_PERM<T>(deg);

    /* compute the power by repeated mapping for small positive exponents  */
    if ( IS_INTOBJ(opR)
      && 2 <= INT_INTOBJ(opR) && INT_INTOBJ(opR) < 8 ) {

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM<T>(opL);
        ptP = ADDR_PERM<T>(pow);

        /* loop over the points of the permutation                         */
        for ( p = 0; p < deg; p++ ) {
            q = p;
            for ( e = 0; e < exp; e++ )
                q = ptL[q];
            ptP[p] = q;
        }

    }

    /* compute the power by raising the cycles individually for large exps */
    else if ( IS_INTOBJ(opR) && 8 <= INT_INTOBJ(opR) ) {

        /* make sure that the buffer bag is large enough                   */
        UseTmpPerm(SIZE_OBJ(opL));
        ptKnown = ADDR_TMP_PERM<UInt1>();

        /* clear the buffer bag                                            */
        memset(ptKnown, 0, DEG_PERM<T>(opL));

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM<T>(opL);
        ptP = ADDR_PERM<T>(pow);

        /* loop over all cycles                                            */
        for ( p = 0; p < deg; p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown[p] == 0 ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptL[p]; q != p; q = ptL[q] ) {
                    len++;  ptKnown[q] = 1;
                }

                /* raise this cycle to the power <exp> mod <len>           */
                r = p;
                for ( e = 0; e < exp % len; e++ )
                    r = ptL[r];
                ptP[p] = r;
                r = ptL[r];
                for ( q = ptL[p]; q != p; q = ptL[q] ) {
                    ptP[q] = r;
                    r = ptL[r];
                }

            }

        }


    }

    /* compute the power by raising the cycles individually for large exps */
    else if ( TNUM_OBJ(opR) == T_INTPOS ) {

        /* make sure that the buffer bag is large enough                   */
        UseTmpPerm(SIZE_OBJ(opL));
        ptKnown = ADDR_TMP_PERM<UInt1>();

        /* clear the buffer bag                                            */
        memset(ptKnown, 0, DEG_PERM<T>(opL));

        /* get pointer to the permutation and the power                    */
        ptL = CONST_ADDR_PERM<T>(opL);
        ptP = ADDR_PERM<T>(pow);

        /* loop over all cycles                                            */
        for ( p = 0; p < deg; p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown[p] == 0 ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptL[p]; q != p; q = ptL[q] ) {
                    len++;  ptKnown[q] = 1;
                }

                /* raise this cycle to the power <exp> mod <len>           */
                r = p;
                exp = INT_INTOBJ( ModInt( opR, INTOBJ_INT(len) ) );
                for ( e = 0; e < exp; e++ )
                    r = ptL[r];
                ptP[p] = r;
                r = ptL[r];
                for ( q = ptL[p]; q != p; q = ptL[q] ) {
                    ptP[q] = r;
                    r = ptL[r];
                }

            }

        }

    }

    /* compute the power by repeated mapping for small negative exponents  */
    else if ( IS_INTOBJ(opR)
          && -8 < INT_INTOBJ(opR) && INT_INTOBJ(opR) < 0 ) {

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM<T>(opL);
        ptP = ADDR_PERM<T>(pow);

        /* loop over the points                                            */
        for ( p = 0; p < deg; p++ ) {
            q = p;
            for ( e = 0; e < exp; e++ )
                q = ptL[q];
            ptP[q] = p;
        }

    }

    /* compute the power by raising the cycles individually for large exps */
    else if ( IS_INTOBJ(opR) && INT_INTOBJ(opR) <= -8 ) {

        /* make sure that the buffer bag is large enough                   */
        UseTmpPerm(SIZE_OBJ(opL));
        ptKnown = ADDR_TMP_PERM<UInt1>();

        /* clear the buffer bag                                            */
        memset(ptKnown, 0, DEG_PERM<T>(opL));

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM<T>(opL);
        ptP = ADDR_PERM<T>(pow);

        /* loop over all cycles                                            */
        for ( p = 0; p < deg; p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown[p] == 0 ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptL[p]; q != p; q = ptL[q] ) {
                    len++;  ptKnown[q] = 1;
                }

                /* raise this cycle to the power <exp> mod <len>           */
                r = p;
                for ( e = 0; e < exp % len; e++ )
                    r = ptL[r];
                ptP[r] = p;
                r = ptL[r];
                for ( q = ptL[p]; q != p; q = ptL[q] ) {
                    ptP[r] = q;
                    r = ptL[r];
                }

            }

        }

    }

    /* compute the power by raising the cycles individually for large exps */
    else if ( TNUM_OBJ(opR) == T_INTNEG ) {
        /* do negation first as it can cause a garbage collection          */
        opR = AInvInt(opR);

        /* make sure that the buffer bag is large enough                   */
        UseTmpPerm(SIZE_OBJ(opL));
        ptKnown = ADDR_TMP_PERM<UInt1>();

        /* clear the buffer bag                                            */
        memset(ptKnown, 0, DEG_PERM<T>(opL));

        /* get pointer to the permutation and the power                    */
        ptL = CONST_ADDR_PERM<T>(opL);
        ptP = ADDR_PERM<T>(pow);

        /* loop over all cycles                                            */
        for ( p = 0; p < deg; p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown[p] == 0 ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptL[p]; q != p; q = ptL[q] ) {
                    len++;  ptKnown[q] = 1;
                }

                /* raise this cycle to the power <exp> mod <len>           */
                r = p;
                exp = INT_INTOBJ( ModInt( opR, INTOBJ_INT(len) ) );
                for ( e = 0; e < exp % len; e++ )
                    r = ptL[r];
                ptP[r] = p;
                r = ptL[r];
                for ( q = ptL[p]; q != p; q = ptL[q] ) {
                    ptP[r] = q;
                    r = ptL[r];
                }

            }

        }

    }

    /* return the result                                                   */
    return pow;
}


/****************************************************************************
**
*F  PowIntPerm( <opL>, <opR> )  . . . image of an integer under a permutation
**
**  'PowIntPerm' returns the  image of the positive  integer  <opL> under the
**  permutation <opR>.  If <opL>  is larger than the  degree of <opR> it is a
**  fixpoint of the permutation and thus simply returned.
*/
template <typename T>
Obj PowIntPerm(Obj opL, Obj opR)
{
    Int                 img;            /* image (result)                  */

    GAP_ASSERT(TNUM_OBJ(opL) == T_INTPOS || TNUM_OBJ(opL) == T_INT);

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TNUM_OBJ(opL) == T_INTPOS )
        return opL;

    img = INT_INTOBJ(opL);
    RequireArgumentCondition("PowIntPerm", opL, "point", img > 0,
                             "must be a positive integer");

    /* compute the image                                                   */
    if ( img <= DEG_PERM<T>(opR) ) {
        img = (CONST_ADDR_PERM<T>(opR))[img-1] + 1;
    }

    /* return it                                                           */
    return INTOBJ_INT(img);
}


/****************************************************************************
**
*F  QuoIntPerm( <opL>, <opR> )  .  preimage of an integer under a permutation
**
**  'QuoIntPerm' returns the preimage of the preimage integer <opL> under the
**  permutation <opR>.  If <opL> is larger than  the degree of  <opR> is is a
**  fixpoint, and thus simply returned.
**
**  There are basically two ways to find the preimage.  One is to run through
**  <opR>  and  look  for <opL>.  The index where it's found is the preimage.
**  The other is to  find  the image of  <opL> under <opR>, the image of that
**  point and so on, until we come  back to  <opL>.  The  last point  is  the
**  preimage of <opL>.  This is faster because the cycles are  usually short.
*/
static Obj PERM_INVERSE_THRESHOLD;

template <typename T>
Obj QuoIntPerm(Obj opL, Obj opR)
{
    T                   pre;            /* preimage (result)               */
    Int                 img;            /* image (left operand)            */
    const T *           ptR;            /* pointer to the permutation      */

    GAP_ASSERT(TNUM_OBJ(opL) == T_INTPOS || TNUM_OBJ(opL) == T_INT);

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TNUM_OBJ(opL) == T_INTPOS )
        return opL;

    img = INT_INTOBJ(opL);
    RequireArgumentCondition("QuoIntPerm", opL, "point", img > 0,
                             "must be a positive integer");

    Obj inv = STOREDINV_PERM(opR);

    if (inv == 0 && PERM_INVERSE_THRESHOLD != 0 &&
        IS_INTOBJ(PERM_INVERSE_THRESHOLD) &&
        DEG_PERM<T>(opR) <= INT_INTOBJ(PERM_INVERSE_THRESHOLD))
        inv = InvPerm<T>(opR);

    if (inv != 0)
        return INTOBJ_INT(
            IMAGE(img - 1, CONST_ADDR_PERM<T>(inv), DEG_PERM<T>(inv)) + 1);

    /* compute the preimage                                                */
    if ( img <= DEG_PERM<T>(opR) ) {
        pre = T(img - 1);
        ptR = CONST_ADDR_PERM<T>(opR);
        while (ptR[pre] != T(img - 1))
            pre = ptR[pre];
        /* return it */
        return INTOBJ_INT(pre + 1);
    }
    else
        return INTOBJ_INT(img);
}


/****************************************************************************
**
*F  PowPerm( <opL>, <opR> ) . . . . . . . . . . . conjugation of permutations
**
**  'PowPerm' returns the   conjugation  of the  two permutations  <opL>  and
**  <opR>, that s  defined as the  following product '<opR>\^-1 \*\ <opL> \*\
**  <opR>'.
*/
template <typename TL, typename TR>
Obj PowPerm(Obj opL, Obj opR)
{
    typedef typename ResultType<TL,TR>::type Res;

    Obj                 cnj;            /* handle of the conjugation (res) */
    UInt                degC;           /* degree of the conjugation       */
    Res *               ptC;            /* pointer to the conjugation      */
    UInt                degL;           /* degree of the left operand      */
    const TL *          ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const TR *          ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM<TL>(opL);
    degR = DEG_PERM<TR>(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM<Res>( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM<TL>(opL);
    ptR = CONST_ADDR_PERM<TR>(opR);
    ptC = ADDR_PERM<Res>(cnj);

    /* it is faster if the both permutations have the same size            */
    if ( degL == degR ) {
        for ( p = 0; p < degC; p++ )
            ptC[ ptR[p] ] = ptR[ ptL[p] ];
    }

    /* otherwise we have to use the macro 'IMAGE' three times              */
    else {
        for ( p = 0; p < degC; p++ )
            ptC[ IMAGE(p,ptR,degR) ] = IMAGE( IMAGE(p,ptL,degL), ptR, degR );
    }

    /* return the result                                                   */
    return cnj;
}


/****************************************************************************
**
*F  CommPerm( <opL>, <opR> )  . . . . . . . .  commutator of two permutations
**
**  'CommPerm' returns the  commutator  of  the  two permutations  <opL>  and
**  <opR>, that is defined as '<hd>\^-1 \*\ <opR>\^-1 \*\ <opL> \*\ <opR>'.
*/
template <typename TL, typename TR>
Obj CommPerm(Obj opL, Obj opR)
{
    typedef typename ResultType<TL,TR>::type Res;

    Obj                 com;            /* handle of the commutator  (res) */
    UInt                degC;           /* degree of the commutator        */
    Res *               ptC;            /* pointer to the commutator       */
    UInt                degL;           /* degree of the left operand      */
    const TL *          ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const TR *          ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM<TL>(opL);
    degR = DEG_PERM<TR>(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM<Res>( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM<TL>(opL);
    ptR = CONST_ADDR_PERM<TR>(opR);
    ptC = ADDR_PERM<Res>(com);

    /* it is faster if the both permutations have the same size            */
    if ( degL == degR ) {
        for ( p = 0; p < degC; p++ )
            ptC[ ptL[ ptR[ p ] ] ] = ptR[ ptL[ p ] ];
    }

    /* otherwise we have to use the macro 'IMAGE' four times               */
    else {
        for ( p = 0; p < degC; p++ )
            ptC[ IMAGE( IMAGE(p,ptR,degR), ptL, degL ) ]
               = IMAGE( IMAGE(p,ptL,degL), ptR, degR );
    }

    /* return the result                                                   */
    return com;
}


/****************************************************************************
**
*F  OnePerm( <perm> )
*/
Obj OnePerm (
    Obj                 op )
{
    return IdentityPerm;
}



/****************************************************************************
**
*F  IsPermHandler( <self>, <val> )  . . . .  test if a value is a permutation
**
**  'FuncIsPerm' implements the internal function 'IsPerm'.
**
**  'IsPerm( <val> )'
**
**  'IsPerm' returns 'true' if the value <val> is a permutation and  'false'
**  otherwise.
*/
Obj IsPermFilt;

Obj IsPermHandler (
    Obj                 self,
    Obj                 val )
{
    /* return 'true' if <val> is a permutation and 'false' otherwise       */
    if ( TNUM_OBJ(val) == T_PERM2 || TNUM_OBJ(val) == T_PERM4 ) {
        return True;
    }
    else if ( TNUM_OBJ(val) < FIRST_EXTERNAL_TNUM ) {
        return False;
    }
    else {
        return DoFilter( self, val );
    }
}


/****************************************************************************
**
*F  FuncPermList( <self>, <list> )  . . . . . convert a list to a permutation
**
**  'FuncPermList' implements the internal function 'PermList'
**
**  'PermList( <list> )'
**
**  Converts the list <list> into a  permutation,  which  is  then  returned.
**
**  'FuncPermList' simply copies the list pointwise into  a  permutation  bag.
**  It also does some checks to make sure that the  list  is  a  permutation.
*/
template <typename T>
static inline Obj PermList(Obj list)
{
    Obj                 perm;           /* handle of the permutation       */
    T *                 ptPerm;         /* pointer to the permutation      */
    UInt                degPerm;        /* degree of the permutation       */
    const Obj *         ptList;         /* pointer to the list             */
    T *                 ptTmp;          /* pointer to the buffer bag       */
    Int                 i,  k;          /* loop variables                  */

    PLAIN_LIST( list );

    degPerm = LEN_LIST( list );

    /* make sure that the global buffer bag is large enough for checkin*/
    UseTmpPerm(SIZEBAG_PERM<T>(degPerm));

    /* allocate the bag for the permutation and get pointer            */
    perm    = NEW_PERM<T>(degPerm);
    ptPerm  = ADDR_PERM<T>(perm);
    ptList  = CONST_ADDR_OBJ(list);
    ptTmp   = ADDR_TMP_PERM<T>();

    /* make the buffer bag clean                                       */
    for ( i = 1; i <= degPerm; i++ )
        ptTmp[i-1] = 0;

    /* run through all entries of the list                             */
    for ( i = 1; i <= degPerm; i++ ) {

        /* get the <i>th entry of the list                             */
        if ( ptList[i] == 0 ) {
            return Fail;
        }
        if ( !IS_INTOBJ(ptList[i]) ) {
            return Fail;
        }
        k = INT_INTOBJ(ptList[i]);
        if ( k <= 0 || degPerm < k ) {
            return Fail;
        }

        /* make sure we haven't seen this entry yet                     */
        if ( ptTmp[k-1] != 0 ) {
            return Fail;
        }
        ptTmp[k-1] = 1;

        /* and finally copy it into the permutation                    */
        ptPerm[i-1] = k-1;
    }

    /* return the permutation                                              */
    return perm;
}

Obj             FuncPermList (
    Obj                 self,
    Obj                 list )
{
    /* check the arguments                                                 */
    RequireSmallList("PermList", list);

    UInt len = LEN_LIST( list );
    if ( len <= 65536 ) {
        return PermList<UInt2>(list);
    }
    else if (len <= MAX_DEG_PERM4) {
        return PermList<UInt4>(list);
    }
    else {
        ErrorMayQuit("PermList: list length %i exceeds maximum permutation degree\n",
             len, 0);
    }
}

/****************************************************************************
**
*F  LargestMovedPointPerm( <perm> ) largest point moved by perm
**
**  'LargestMovedPointPerm' returns  the  largest  positive  integer that  is
**  moved by the permutation <perm>.
**
**  This is easy, except that permutations may  contain  trailing  fixpoints.
*/
template <typename T>
static inline UInt LargestMovedPointPerm_(Obj perm)
{
    UInt      sup;
    const T * ptPerm;

    ptPerm = CONST_ADDR_PERM<T>(perm);
    for (sup = DEG_PERM<T>(perm); 1 <= sup; sup--) {
        if (ptPerm[sup - 1] != sup - 1)
            break;
    }
    return sup;
}

UInt LargestMovedPointPerm(Obj perm)
{
    GAP_ASSERT(TNUM_OBJ(perm) == T_PERM2 || TNUM_OBJ(perm) == T_PERM4);

    if (TNUM_OBJ(perm) == T_PERM2)
        return LargestMovedPointPerm_<UInt2>(perm);
    else
        return LargestMovedPointPerm_<UInt4>(perm);
}


/****************************************************************************
**
*F  FuncLARGEST_MOVED_POINT_PERM( <self>, <perm> ) largest point moved by perm
**
**  GAP-level wrapper for 'LargestMovedPointPerm'.
*/
Obj FuncLARGEST_MOVED_POINT_PERM(Obj self, Obj perm)
{

    /* check the argument                                                  */
    RequirePermutation("LargestMovedPointPerm", perm);

    return INTOBJ_INT(LargestMovedPointPerm(perm));
}


/****************************************************************************
**
*F  FuncCYCLE_LENGTH_PERM_INT( <self>, <perm>, <point> ) . . . . . . . . . . 
*F  . . . . . . . . . . . . . . . . . . length of a cycle under a permutation
**
**  'FuncCycleLengthInt' implements the internal function
**  'CycleLengthPermInt'
**
**  'CycleLengthPermInt( <perm>, <point> )'
**
**  'CycleLengthPermInt' returns the length of the cycle  of  <point>,  which
**  must be a positive integer, under the permutation <perm>.
**
**  Note that the order of the arguments to this function has been  reversed.
*/
template <typename T>
static inline Obj CYCLE_LENGTH_PERM_INT(Obj perm, Obj point)
{
    const T *           ptPerm;         /* pointer to the permutation      */
    UInt                deg;            /* degree of the permutation       */
    UInt                pnt;            /* value of the point              */
    UInt                len;            /* length of cycle (result)        */
    UInt                p;              /* loop variable                   */

    /* get pointer to the permutation, the degree, and the point       */
    ptPerm = CONST_ADDR_PERM<T>(perm);
    deg = DEG_PERM<T>(perm);
    pnt = INT_INTOBJ(point)-1;

    /* now compute the length by looping over the cycle                */
    len = 1;
    if ( pnt < deg ) {
        for ( p = ptPerm[pnt]; p != pnt; p = ptPerm[p] )
            len++;
    }

    return INTOBJ_INT(len);
}

Obj             FuncCYCLE_LENGTH_PERM_INT (
    Obj                 self,
    Obj                 perm,
    Obj                 point )
{
    /* evaluate and check the arguments                                    */
    RequirePermutation("CycleLengthPermInt", perm);
    RequirePositiveSmallInt("CycleLengthPermInt", point, "point");

    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return CYCLE_LENGTH_PERM_INT<UInt2>(perm, point);
    }
    else {
        return CYCLE_LENGTH_PERM_INT<UInt4>(perm, point);
    }
}


/****************************************************************************
**
*F  FuncCYCLE_PERM_INT( <self>, <perm>, <point> ) . .  cycle of a permutation
*
**  'FuncCYCLE_PERM_INT' implements the internal function 'CyclePermInt'.
**
**  'CyclePermInt( <perm>, <point> )'
**
**  'CyclePermInt' returns the cycle of <point>, which  must  be  a  positive
**  integer, under the permutation <perm> as a list.
*/
template <typename T>
static inline Obj CYCLE_PERM_INT(Obj perm, Obj point)
{
    Obj                 list;           /* handle of the list (result)     */
    Obj *               ptList;         /* pointer to the list             */
    const T *           ptPerm;         /* pointer to the permutation      */
    UInt                deg;            /* degree of the permutation       */
    UInt                pnt;            /* value of the point              */
    UInt                len;            /* length of the cycle             */
    UInt                p;              /* loop variable                   */

    /* get pointer to the permutation, the degree, and the point       */
    ptPerm = CONST_ADDR_PERM<T>(perm);
    deg = DEG_PERM<T>(perm);
    pnt = INT_INTOBJ(point)-1;

    /* now compute the length by looping over the cycle                */
    len = 1;
    if ( pnt < deg ) {
        for ( p = ptPerm[pnt]; p != pnt; p = ptPerm[p] )
            len++;
    }

    /* allocate the list                                               */
    list = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( list, len );
    ptList = ADDR_OBJ(list);
    ptPerm = CONST_ADDR_PERM<T>(perm);

    /* copy the points into the list                                   */
    len = 1;
    ptList[len++] = INTOBJ_INT( pnt+1 );
    if ( pnt < deg ) {
        for ( p = ptPerm[pnt]; p != pnt; p = ptPerm[p] )
            ptList[len++] = INTOBJ_INT( p+1 );
    }

    return list;
}

Obj             FuncCYCLE_PERM_INT (
    Obj                 self,
    Obj                 perm,
    Obj                 point )
{

    /* evaluate and check the arguments                                    */
    RequirePermutation("CyclePermInt", perm);
    RequirePositiveSmallInt("CyclePermInt", point, "point");

    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return CYCLE_PERM_INT<UInt2>(perm, point);
    }
    else {
        return CYCLE_PERM_INT<UInt4>(perm, point);
    }
}

/****************************************************************************
**
*F  FuncCYCLE_STRUCT_PERM( <self>, <perm> ) . . . . . cycle structure of perm
*
**  'FuncCYCLE_STRUCT_PERM' implements the internal function
**  `CycleStructPerm'.
**
**  `CycleStructPerm( <perm> )'
**
**  'CycleStructPerm' returns a list of the form as described under
**  `CycleStructure'.
*/
template <typename T>
static inline Obj CYCLE_STRUCT_PERM(Obj perm)
{
    Obj                 list;           /* handle of the list (result)     */
    Obj *               ptList;         /* pointer to the list             */
    const T *           ptPerm;         /* pointer to the permutation      */
    T *                 scratch;
    T *                 offset;
    UInt                deg;            /* degree of the permutation       */
    UInt                pnt;            /* value of the point              */
    UInt                len;            /* length of the cycle             */
    UInt                p;              /* loop variable                   */
    UInt                max;            /* maximal cycle length            */
    UInt                cnt;
    UInt                ende;
    UInt                bytes;
    UInt1 *             clr;

    /* make sure that the buffer bag is large enough                       */
    UseTmpPerm(SIZE_OBJ(perm) + 8);

    /* find the largest moved point                                    */
    ptPerm = CONST_ADDR_PERM<T>(perm);
    for (deg = DEG_PERM<T>(perm); 1 <= deg; deg--) {
        if (ptPerm[deg - 1] != deg - 1)
            break;
    }
    if (deg == 0) {
        /* special treatment of identity */
        list = NEW_PLIST(T_PLIST, 0);
        return list;
    }

    scratch = ADDR_TMP_PERM<T>();

    /* the first deg bytes of TmpPerm hold a bit list of points done
     * so far. The remaining bytes will form the lengths of nontrivial
     * cycles (as numbers of type T). As every nontrivial cycle requires
     * at least 2 points, this is guaranteed to fit. */
    bytes = ((deg / sizeof(T)) + 1) * sizeof(T); // ensure alignment
    offset = (T *)((UInt)scratch + (bytes));
    clr = (UInt1 *)scratch;

    /* clear out the bits */
    for (cnt = 0; cnt < bytes; cnt++) {
        clr[cnt] = (UInt1)0;
    }

    cnt = 0;
    clr = (UInt1 *)scratch;
    max = 0;
    for (pnt = 0; pnt < deg; pnt++) {
        if (clr[pnt] == 0) {
            len = 1;
            clr[pnt] = 1;
            for (p = ptPerm[pnt]; p != pnt; p = ptPerm[p]) {
                clr[p] = 1;
                len++;
            }

            if (len > 1) {
                offset[cnt] = (T)len;
                cnt++;
                if (len > max) {
                    max = len;
                }
            }
        }
    }

    ende = cnt;

    /* create the list */
    list = NEW_PLIST(T_PLIST, max - 1);
    SET_LEN_PLIST(list, max - 1);
    ptList = ADDR_OBJ(list);

    /* Recalculate after possible GC */
    scratch = ADDR_TMP_PERM<T>();
    offset = (T *)((UInt)scratch + (bytes));

    for (pnt = 1; pnt < max; pnt++) {
        ptList[pnt] = 0;
    } /* clean out */

    for (cnt = 0; cnt < ende; cnt++) {
        pnt = (UInt)offset[cnt];
        pnt--;
        ptList[pnt] = (Obj)((UInt)ptList[pnt] + 1);
    }

    for (pnt = 1; pnt < max; pnt++) {
        if (ptList[pnt] != 0) {
            ptList[pnt] = INTOBJ_INT((UInt)ptList[pnt]);
        }
    }

    return list;
}

Obj FuncCYCLE_STRUCT_PERM(Obj self, Obj perm)
{
    /* evaluate and check the arguments                                    */
    RequirePermutation("CycleStructPerm", perm);

    if (TNUM_OBJ(perm) == T_PERM2) {
        return CYCLE_STRUCT_PERM<UInt2>(perm);
    }
    else {
        return CYCLE_STRUCT_PERM<UInt4>(perm);
    }
}

/****************************************************************************
**
*F  FuncORDER_PERM( <self>, <perm> ) . . . . . . . . . order of a permutation
**
**  'FuncORDER_PERM' implements the internal function 'OrderPerm'.
**
**  'OrderPerm( <perm> )'
**
**  'OrderPerm' returns the  order  of  the  permutation  <perm>,  i.e.,  the
**  smallest positive integer <n> such that '<perm>\^<n>' is the identity.
**
**  Since the largest element in S(65536) has oder greater than  10^382  this
**  computation may easily overflow.  So we have to use  arbitrary precision.
*/
template <typename T>
static inline Obj ORDER_PERM(Obj perm)
{
    const T *           ptPerm;         /* pointer to the permutation      */
    Obj                 ord;            /* order (result), may be huge     */
    T *                 ptKnown;        /* pointer to temporary bag        */
    UInt                len;            /* length of one cycle             */
    UInt                p, q;           /* loop variables                  */

    /* make sure that the buffer bag is large enough                       */
    UseTmpPerm(SIZE_OBJ(perm));

    /* get the pointer to the bags                                     */
    ptPerm  = CONST_ADDR_PERM<T>(perm);
    ptKnown = ADDR_TMP_PERM<T>();

    /* clear the buffer bag                                            */
    for ( p = 0; p < DEG_PERM<T>(perm); p++ )
        ptKnown[p] = 0;

    /* start with order 1                                              */
    ord = INTOBJ_INT(1);

    /* loop over all cycles                                            */
    for ( p = 0; p < DEG_PERM<T>(perm); p++ ) {

        /* if we haven't looked at this cycle so far                   */
        if ( ptKnown[p] == 0 && ptPerm[p] != p ) {

            /* find the length of this cycle                           */
            len = 1;
            for ( q = ptPerm[p]; q != p; q = ptPerm[q] ) {
                len++;  ptKnown[q] = 1;
            }

            ord = LcmInt( ord, INTOBJ_INT( len ) );

            // update bag pointers, in case a garbage collection happened
            ptPerm  = CONST_ADDR_PERM<T>(perm);
            ptKnown = ADDR_TMP_PERM<T>();

        }

    }

    /* return the order                                                    */
    return ord;
}

Obj             FuncORDER_PERM (
    Obj                 self,
    Obj                 perm )
{
    /* check arguments and extract permutation                             */
    RequirePermutation("OrderPerm", perm);

    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return ORDER_PERM<UInt2>(perm);
    }
    else {
        return ORDER_PERM<UInt4>(perm);
    }
}


/****************************************************************************
**
*F  FuncSIGN_PERM( <self>, <perm> ) . . . . . . . . . . sign of a permutation
**
**  'FuncSIGN_PERM' implements the internal function 'SignPerm'.
**
**  'SignPerm( <perm> )'
**
**  'SignPerm' returns the sign of the permutation <perm>.  The sign is +1 if
**  <perm> is the product of an *even* number of transpositions,  and  -1  if
**  <perm> is the product of an *odd*  number  of  transpositions.  The  sign
**  is a homomorphism from the symmetric group onto the multiplicative  group
**  $\{ +1, -1 \}$, the kernel of which is the alternating group.
*/
template <typename T>
static inline Obj SIGN_PERM(Obj perm)
{
    const T *           ptPerm;         /* pointer to the permutation      */
    Int                 sign;           /* sign (result)                   */
    T *                 ptKnown;        /* pointer to temporary bag        */
    UInt                len;            /* length of one cycle             */
    UInt                p,  q;          /* loop variables                  */

    /* make sure that the buffer bag is large enough                       */
    UseTmpPerm(SIZE_OBJ(perm));

    /* get the pointer to the bags                                     */
    ptPerm  = CONST_ADDR_PERM<T>(perm);
    ptKnown = ADDR_TMP_PERM<T>();

    /* clear the buffer bag                                            */
    for ( p = 0; p < DEG_PERM<T>(perm); p++ )
        ptKnown[p] = 0;

    /* start with sign  1                                              */
    sign = 1;

    /* loop over all cycles                                            */
    for ( p = 0; p < DEG_PERM<T>(perm); p++ ) {

        /* if we haven't looked at this cycle so far                   */
        if ( ptKnown[p] == 0 && ptPerm[p] != p ) {

            /* find the length of this cycle                           */
            len = 1;
            for ( q = ptPerm[p]; q != p; q = ptPerm[q] ) {
                len++;  ptKnown[q] = 1;
            }

            /* if the length is even invert the sign                   */
            if ( len % 2 == 0 )
                sign = -sign;

        }

    }

    /* return the sign                                                     */
    return INTOBJ_INT( sign );
}

Obj             FuncSIGN_PERM (
    Obj                 self,
    Obj                 perm )
{
    /* check arguments and extract permutation                             */
    RequirePermutation("SignPerm", perm);

    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return SIGN_PERM<UInt2>(perm);
    }
    else {
        return SIGN_PERM<UInt4>(perm);
    }
}


/****************************************************************************
**
*F  FuncSMALLEST_GENERATOR_PERM( <self>, <perm> ) . . . . . . . . . . . . . .
*F  . . . . . . . smallest generator of cyclic group generated by permutation
**
**  'FuncSMALLEST_GENERATOR_PERM' implements the internal function
**  'SmallestGeneratorPerm'.
**
**  'SmallestGeneratorPerm( <perm> )'
**
**  'SmallestGeneratorPerm' returns the   smallest generator  of  the  cyclic
**  group generated by the  permutation  <perm>.  That  is   the result is  a
**  permutation that generates the same  cyclic group as  <perm> and is  with
**  respect  to the lexicographical order  defined  by '\<' the smallest such
**  permutation.
*/
template <typename T>
static inline Obj SMALLEST_GENERATOR_PERM(Obj perm)
{
    Obj                 small;          /* handle of the smallest gen      */
    T *                 ptSmall;        /* pointer to the smallest gen     */
    const T *           ptPerm;         /* pointer to the permutation      */
    T *                 ptKnown;        /* pointer to temporary bag        */
    Obj                 ord;            /* order, may be huge              */
    Obj                 pow;            /* power, may also be huge         */
    UInt                len;            /* length of one cycle             */
    UInt                gcd,  s,  t;    /* gcd( len, ord ), temporaries    */
    UInt                min;            /* minimal element in a cycle      */
    UInt                p,  q;          /* loop variables                  */
    UInt                l, n, x, gcd2;  /* loop variable                   */

    /* make sure that the buffer bag is large enough                       */
    UseTmpPerm(SIZE_OBJ(perm));

    /* allocate the result bag                                         */
    small = NEW_PERM<T>( DEG_PERM<T>(perm) );

    /* get the pointer to the bags                                     */
    ptPerm   = CONST_ADDR_PERM<T>(perm);
    ptKnown  = ADDR_TMP_PERM<T>();
    ptSmall  = ADDR_PERM<T>(small);

    /* clear the buffer bag                                            */
    for ( p = 0; p < DEG_PERM<T>(perm); p++ )
        ptKnown[p] = 0;

    /* we only know that we must raise <perm> to a power = 0 mod 1     */
    ord = INTOBJ_INT(1);  pow = INTOBJ_INT(0);

    /* loop over all cycles                                            */
    for ( p = 0; p < DEG_PERM<T>(perm); p++ ) {

        /* if we haven't looked at this cycle so far                   */
        if ( ptKnown[p] == 0 ) {

            /* find the length of this cycle                           */
            len = 1;
            for ( q = ptPerm[p]; q != p; q = ptPerm[q] ) {
                len++;  ptKnown[q] = 1;
            }

            /* compute the gcd with the previously order ord           */
            /* Note that since len is single precision, ord % len is to*/
            gcd = len;  s = INT_INTOBJ( ModInt( ord, INTOBJ_INT(len) ) );
            while ( s != 0 ) {
                t = s;  s = gcd % s;  gcd = t;
            }

            /* we must raise the cycle into a power = pow mod gcd      */
            x = INT_INTOBJ( ModInt( pow, INTOBJ_INT( gcd ) ) );

            /* find the smallest element in the cycle at such a positio*/
            min = DEG_PERM<T>(perm)-1;
            n = 0;
            for ( q = p, l = 0; l < len; l++ ) {
                gcd2 = len;  s = l;
                while ( s != 0 ) { t = s; s = gcd2 % s; gcd2 = t; }
                if ( l % gcd == x && gcd2 == 1 && q <= min ) {
                    min = q;
                    n = l;
                }
                q = ptPerm[q];
            }

            /* raise the cycle to that power and put it in the result  */
            ptSmall[p] = min;
            for ( q = ptPerm[p]; q != p; q = ptPerm[q] ) {
                min = ptPerm[min];  ptSmall[q] = min;
            }

            /* compute the new order and the new power                 */
            while ( INT_INTOBJ( ModInt( pow, INTOBJ_INT(len) ) ) != n )
                pow = SumInt( pow, ord );
            ord = ProdInt( ord, INTOBJ_INT( len / gcd ) );

        }

    }

    /* return the smallest generator                                       */
    return small;
}

Obj             FuncSMALLEST_GENERATOR_PERM (
    Obj                 self,
    Obj                 perm )
{
    /* check arguments and extract permutation                             */
    RequirePermutation("SmallestGeneratorPerm", perm);

    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return SMALLEST_GENERATOR_PERM<UInt2>(perm);
    }
    else {
        return SMALLEST_GENERATOR_PERM<UInt4>(perm);
    }
}

/****************************************************************************
**
*F  FuncRESTRICTED_PERM( <self>, <perm>, <dom>, <test> ) . . RestrictedPerm
**
**  'FuncRESTRICTED_PERM' implements the internal function
**  'RESTRICTED_PERM'.
**
**  'RESTRICTED_PERM( <perm>, <dom>, <test> )'
**
**  'RESTRICTED_PERM' returns the restriction of <perm> to <dom>. If <test>
**  is set to `true' is is verified that <dom> is the union of cycles of
**  <perm>.
*/
template <typename T>
static inline Obj RESTRICTED_PERM(Obj perm, Obj dom, Obj test)
{
    Obj rest;
    T *                ptRest;
    const T *          ptPerm;
    const Obj *        ptDom;
    Int i,inc,len,p,deg;

    /* make sure that the buffer bag is large enough */
    UseTmpPerm(SIZE_OBJ(perm));

    /* allocate the result bag                                         */
    deg = DEG_PERM<T>(perm);
    rest = NEW_PERM<T>(deg);

    /* get the pointer to the bags                                     */
    ptPerm  = CONST_ADDR_PERM<T>(perm);
    ptRest  = ADDR_PERM<T>(rest);

    /* create identity everywhere */
    for ( p = 0; p < deg; p++ ) {
        ptRest[p]=(T)p;
    }

    if ( ! IS_RANGE(dom) ) {
      if ( ! IS_PLIST( dom ) ) {
        return Fail;
      }
      /* domain is list */
      ptPerm  = CONST_ADDR_PERM<T>(perm);
      ptRest  = ADDR_PERM<T>(rest);
      ptDom  = CONST_ADDR_OBJ(dom);
      len = LEN_LIST(dom);
      for (i = 1; i <= len; i++) {
          if (IS_POS_INTOBJ(ptDom[i])) {
              p = INT_INTOBJ(ptDom[i]);
              if (p <= deg) {
                  p -= 1;
                  ptRest[p] = ptPerm[p];
              }
          }
          else {
              return Fail;
          }
      }
    }
    else {
      len = GET_LEN_RANGE(dom);
      p = GET_LOW_RANGE(dom);
      inc = GET_INC_RANGE(dom);
      while (p<1) {
        p+=inc;
        len=-1;
      }
      i=p+(inc*len)-1;
      while (i>deg) {
        i-=inc;
      }
      p-=1;
      i-=1;
      while (p<=i) {
        ptRest[p]=ptPerm[p];
        p+=inc;
      }
    }

    if (test==True) {

      T * ptTmp  = ADDR_TMP_PERM<T>();

      /* cleanout */
      for ( p = 0; p < deg; p++ ) {
        ptTmp[p]=0;
      }

      /* check whether the result is a permutation */
      for (p=0;p<deg;p++) {
        inc=ptRest[p];
        if (ptTmp[inc]==1) return Fail; /* point was known */
        else ptTmp[inc]=1; /* now point is known */
      }

    }

    /* return the restriction */
    return rest;
}

Obj             FuncRESTRICTED_PERM (
    Obj                 self,
    Obj                 perm,
    Obj                 dom,
    Obj                 test )
{
    /* check arguments and extract permutation                             */
    RequirePermutation("RestrictedPerm", perm);

    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return RESTRICTED_PERM<UInt2>(perm, dom, test);
    }
    else {
        return RESTRICTED_PERM<UInt4>(perm, dom, test);
    }
}

/****************************************************************************
**
*F  FuncTRIM_PERM( <self>, <perm>, <n> ) . . . . . . . . . trim a permutation
**
**  'TRIM_PERM' trims a permutation to the first <n> points. This can be
##  useful to save memory
*/
Obj             FuncTRIM_PERM (
    Obj                 self,
    Obj                 perm,
    Obj                 n )
{
    UInt        deg,rdeg,i;
    UInt4*      addr;

    /* check arguments and extract permutation */
    RequirePermutation("TRIM_PERM", perm);

    deg = INT_INTOBJ(n);
    /*T a test might be useful here */

    if ( TNUM_OBJ(perm) == T_PERM2 ) {
      rdeg = deg < DEG_PERM2(perm) ? deg : DEG_PERM2(perm);
      ResizeBag(perm, SIZEBAG_PERM2(rdeg));
    }
    else {
      rdeg = deg < DEG_PERM4(perm) ? deg : DEG_PERM4(perm);
      if (rdeg > 65536UL ) {
          ResizeBag(perm, SIZEBAG_PERM4(rdeg));
      }
      else {
        /* Convert to 2Byte rep: move the points up */
        addr=ADDR_PERM4(perm);
        for (i=0;i<=rdeg;i++) {
          ((UInt2*)addr)[i]=(UInt2)addr[i];
        }
        RetypeBag( perm, T_PERM2 );
        ResizeBag(perm, SIZEBAG_PERM2(rdeg));
      }
    }

    return (Obj)0;
}

/****************************************************************************
**
*F  FuncSPLIT_PARTITION( <Ppoints>, <Qnum>,<j>,<g>,<l>)
**  <l> is a list [<a>,<b>,<max>] -- needed because of large parameter number
**
**  This function is used in the partition backtrack to split a partition.
**  The points <i> in the list Ppoints between a (start) and b (end) such
**  that Qnum[i^g]=j will be moved at the end.
**  At most <max> points will be moved.
**  The function returns the start point of the new partition (or -1 if too
**  many are moved).
**  Ppoints and Qnum must be plain lists of small integers.
*/
template <typename T>
static inline Obj
SPLIT_PARTITION(Obj Ppoints, Obj Qnum, Obj jval, Obj g, Obj lst)
{
  Int a;
  Int b;
  Int cnt;
  Int max;
  Int blim;
  UInt deg;
  const T * ptPerm;
  Obj tmp;


  a=INT_INTOBJ(ELM_PLIST(lst,1))-1;
  b=INT_INTOBJ(ELM_PLIST(lst,2))+1;
  max=INT_INTOBJ(ELM_PLIST(lst,3));
  cnt=0;
  blim=b-max-1;

    deg=DEG_PERM<T>(g);
    ptPerm=CONST_ADDR_PERM<T>(g);
    while ( (a<b)) {
      do {
        b--;
        if (b<blim) {
          /* too many points got moved out */
          return INTOBJ_INT(-1);
        }
      } while (ELM_PLIST(Qnum,
               IMAGE(INT_INTOBJ(ELM_PLIST(Ppoints,b))-1,ptPerm,deg)+1)==jval);
      do {
        a++;
      } while ((a<b)
              &&(!(ELM_PLIST(Qnum,
                   IMAGE(INT_INTOBJ(ELM_PLIST(Ppoints,a))-1,ptPerm,deg)+1)==jval)));
      /* swap */
      if (a<b) {
        tmp=ELM_PLIST(Ppoints,a);
        SET_ELM_PLIST(Ppoints,a,ELM_PLIST(Ppoints,b));
        SET_ELM_PLIST(Ppoints,b,tmp);
        cnt++;
      }
    }

  /* list is not necc. sorted wrt. \< (any longer) */
  RESET_FILT_LIST(Ppoints, FN_IS_SSORT);
  RESET_FILT_LIST(Ppoints, FN_IS_NSORT);

  return INTOBJ_INT(b+1);
}

Obj FuncSPLIT_PARTITION(
    Obj self,
    Obj Ppoints,
    Obj Qnum,
    Obj jval,
    Obj g,
    Obj lst)
{
  if (TNUM_OBJ(g)==T_PERM2) {
    return SPLIT_PARTITION<UInt2>(Ppoints, Qnum, jval, g, lst);
  }
  else {
    return SPLIT_PARTITION<UInt4>(Ppoints, Qnum, jval, g, lst);
  }
}

/*****************************************************************************
**
*F  FuncDISTANCE_PERMS( <perm1>, <perm2> )
**
**  'DistancePerms' returns the number of points moved by <perm1>/<perm2>
**
*/
template <typename TL, typename TR>
static inline Obj DISTANCE_PERMS(Obj opL, Obj opR)
{
    UInt       dist = 0;
    const TL * ptL = CONST_ADDR_PERM<TL>(opL);
    const TR * ptR = CONST_ADDR_PERM<TR>(opR);
    UInt       degL = DEG_PERM<TL>(opL);
    UInt       degR = DEG_PERM<TR>(opR);
    UInt       i;
    if (degL < degR) {
        for (i = 0; i < degL; i++)
            if (ptL[i] != ptR[i])
                dist++;
        for (; i < degR; i++)
            if (ptR[i] != i)
                dist++;
    }
    else {
        for (i = 0; i < degR; i++)
            if (ptL[i] != ptR[i])
                dist++;
        for (; i < degL; i++)
            if (ptL[i] != i)
                dist++;
    }

    return INTOBJ_INT(dist);
}

Obj FuncDISTANCE_PERMS(Obj self, Obj opL, Obj opR)
{
    UInt type = (TNUM_OBJ(opL) == T_PERM2 ? 20 : 40) + (TNUM_OBJ(opR) == T_PERM2 ? 2 : 4);
    switch (type) {
    case 22:
        return DISTANCE_PERMS<UInt2, UInt2>(opL, opR);
    case 24:
        return DISTANCE_PERMS<UInt2, UInt4>(opL, opR);
    case 42:
        return DISTANCE_PERMS<UInt4, UInt2>(opL, opR);
    case 44:
        return DISTANCE_PERMS<UInt4, UInt4>(opL, opR);
    }
    return Fail;
}

/****************************************************************************
**
*F  FuncSMALLEST_IMG_TUP_PERM( <tup>, <perm> )
**
**  `SmallestImgTuplePerm' returns the smallest image of the  tuple  <tup>
**  under  the permutation <perm>.
*/
template <typename T>
static inline Obj SMALLEST_IMG_TUP_PERM(Obj tup, Obj perm)
{
    UInt                res;            /* handle of the image, result     */
    const Obj *         ptTup;          /* pointer to the tuple            */
    const T *           ptPrm;         /* pointer to the permutation      */
    UInt                tmp;            /* temporary handle                */
    UInt                lmp;            /* largest moved point             */
    UInt                i, k;           /* loop variables                  */

    res = MAX_DEG_PERM4; /* ``infty''. */

    /* get the pointer                                                 */
    ptTup = CONST_ADDR_OBJ(tup) + LEN_LIST(tup);
    ptPrm = CONST_ADDR_PERM<T>(perm);
    lmp = DEG_PERM<T>(perm);

    /* loop over the entries of the tuple                              */
    for ( i = LEN_LIST(tup); 1 <= i; i--, ptTup-- ) {
      k = INT_INTOBJ( *ptTup );
      if ( k <= lmp )
          tmp = ptPrm[k-1] + 1;
      else
          tmp = k;
      if (tmp<res) res = tmp;
    }

    /* return the result                                                   */
    return INTOBJ_INT(res);

}

Obj             FuncSMALLEST_IMG_TUP_PERM (
    Obj                 self,
    Obj                 tup,
    Obj                 perm )
{
    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return SMALLEST_IMG_TUP_PERM<UInt2>(tup, perm);
    }
    else {
        return SMALLEST_IMG_TUP_PERM<UInt4>(tup, perm);
    }
}

/****************************************************************************
**
*F  OnTuplesPerm( <tup>, <perm> )  . . . .  operations on tuples of points
**
**  'OnTuplesPerm'  returns  the  image  of  the  tuple  <tup>   under  the
**  permutation <perm>.  It is called from 'FuncOnTuples'.
**
**  The input <tup> must be a non-empty and dense plain list. This is is not
**  verified.
*/
template <typename T>
static inline Obj OnTuplesPerm_(Obj tup, Obj perm)
{
    Obj                 res;            /* handle of the image, result     */
    Obj *               ptRes;          /* pointer to the result           */
    const Obj *         ptTup;          /* pointer to the tuple            */
    const T *           ptPrm;          /* pointer to the permutation      */
    Obj                 tmp;            /* temporary handle                */
    UInt                lmp;            /* largest moved point             */
    UInt                i, k;           /* loop variables                  */

    GAP_ASSERT(IS_PLIST(tup));
    GAP_ASSERT(LEN_PLIST(tup) > 0);

    const UInt len = LEN_PLIST(tup);

    /* make a bag for the result and initialize pointers                   */
    res = NEW_PLIST_WITH_MUTABILITY(IS_PLIST_MUTABLE(tup), T_PLIST, len);
    SET_LEN_PLIST(res, len);

    /* get the pointer                                                 */
    ptTup = CONST_ADDR_OBJ(tup) + len;
    ptRes = ADDR_OBJ(res) + len;
    ptPrm = CONST_ADDR_PERM<T>(perm);
    lmp = DEG_PERM<T>(perm);

    /* loop over the entries of the tuple                              */
    for ( i = len; 1 <= i; i--, ptTup--, ptRes-- ) {
        if (IS_POS_INTOBJ(*ptTup)) {
            k = INT_INTOBJ( *ptTup );
            if (k <= lmp)
                tmp = INTOBJ_INT( ptPrm[k-1] + 1 );
            else
                tmp = *ptTup;
            *ptRes = tmp;
        }
        else {
            if (*ptTup == NULL) {
              ErrorQuit("OnTuples for perm: list must not contain holes",
                        0L, 0L);
            }
            tmp = POW( *ptTup, perm );
            ptTup = CONST_ADDR_OBJ(tup) + i;
            ptRes = ADDR_OBJ(res) + i;
            ptPrm = CONST_ADDR_PERM<T>(perm);
            *ptRes = tmp;
            CHANGED_BAG( res );
        }
    }

    return res;
}

Obj             OnTuplesPerm (
    Obj                 tup,
    Obj                 perm )
{
    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return OnTuplesPerm_<UInt2>(tup, perm);
    }
    else {
        return OnTuplesPerm_<UInt4>(tup, perm);
    }
}


/****************************************************************************
**
*F  OnSetsPerm( <set>, <perm> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsPerm' returns the  image of the  tuple <set> under the permutation
**  <perm>.  It is called from 'FuncOnSets'.
**
**  The input <set> must be a non-empty set, i.e., plain, dense and strictly
**  sorted. This is is not verified.
*/
template <typename T>
static inline Obj OnSetsPerm_(Obj set, Obj perm)
{
    Obj                 res;            /* handle of the image, result     */
    Obj *               ptRes;          /* pointer to the result           */
    const Obj *         ptTup;          /* pointer to the tuple            */
    const T *           ptPrm;          /* pointer to the permutation      */
    Obj                 tmp;            /* temporary handle                */
    UInt                lmp;            /* largest moved point             */
    UInt                isint;          /* <set> only holds integers       */
    UInt                i, k;           /* loop variables                  */

    GAP_ASSERT(IS_PLIST(set));
    GAP_ASSERT(LEN_PLIST(set) > 0);

    const UInt len = LEN_PLIST(set);

    /* make a bag for the result and initialize pointers                   */
    res = NEW_PLIST_WITH_MUTABILITY(IS_PLIST_MUTABLE(set), T_PLIST, len);
    SET_LEN_PLIST(res, len);

    /* get the pointer                                                 */
    ptTup = CONST_ADDR_OBJ(set) + len;
    ptRes = ADDR_OBJ(res) + len;
    ptPrm = CONST_ADDR_PERM<T>(perm);
    lmp = DEG_PERM<T>(perm);

    /* loop over the entries of the tuple                              */
    isint = 1;
    for ( i = len; 1 <= i; i--, ptTup--, ptRes-- ) {
        if (IS_POS_INTOBJ(*ptTup)) {
            k = INT_INTOBJ( *ptTup );
            if (k <= lmp)
                tmp = INTOBJ_INT( ptPrm[k-1] + 1 );
            else
                tmp = INTOBJ_INT( k );
            *ptRes = tmp;
        }
        else {
            isint = 0;
            tmp = POW( *ptTup, perm );
            ptTup = CONST_ADDR_OBJ(set) + i;
            ptRes = ADDR_OBJ(res) + i;
            ptPrm = CONST_ADDR_PERM<T>(perm);
            *ptRes = tmp;
            CHANGED_BAG( res );
        }
    }

    // sort the result
    if (isint) {
        SortPlistByRawObj(res);
        RetypeBag(res, IS_PLIST_MUTABLE(set) ? T_PLIST_CYC_SSORT
                                             : T_PLIST_CYC_SSORT + IMMUTABLE);
    }
    else {
        SortDensePlist(res);
    }

    /* return the result                                                   */
    return res;
}

Obj             OnSetsPerm (
    Obj                 set,
    Obj                 perm )
{
    if ( TNUM_OBJ(perm) == T_PERM2 ) {
        return OnSetsPerm_<UInt2>(set, perm);
    }
    else {
        return OnSetsPerm_<UInt4>(set, perm);
    }
}


/****************************************************************************
**
*F  SavePerm2( <perm2> )
**
*/
void SavePerm2(Obj perm)
{
    SaveSubObj(STOREDINV_PERM(perm));
    UInt len = DEG_PERM2(perm);
    const UInt2 *ptr = CONST_ADDR_PERM2(perm);
    for (UInt i = 0; i < len; i++)
        SaveUInt2( *ptr++);
}

/****************************************************************************
**
*F  SavePerm4( <perm4> )
**
*/
void SavePerm4(Obj perm)
{
    SaveSubObj(STOREDINV_PERM(perm));
    UInt len = DEG_PERM4(perm);
    const UInt4 *ptr = CONST_ADDR_PERM4(perm);
    for (UInt i = 0; i < len; i++)
        SaveUInt4( *ptr++);
}

/****************************************************************************
**
*F  LoadPerm2( <perm2> )
**
*/
void LoadPerm2(Obj perm)
{
    ADDR_OBJ(perm)[0] = LoadSubObj();    // stored inverse
    UInt len = DEG_PERM2(perm);
    UInt2 *ptr = ADDR_PERM2(perm);
    for (UInt i = 0; i < len; i++)
        *ptr++ = LoadUInt2();
}

/****************************************************************************
**
*F  LoadPerm4( <perm4> )
**
*/
void LoadPerm4(Obj perm)
{
    ADDR_OBJ(perm)[0] = LoadSubObj();    // stored inverse
    UInt len = DEG_PERM4(perm);
    UInt4 *ptr = ADDR_PERM4(perm);
    for (UInt i = 0; i < len; i++)
        *ptr++ = LoadUInt4( );
}


/****************************************************************************
**
*F  Array2Perm( <array> ) . . . . . . . . . convert array of cycles into perm
*/
Obj Array2Perm (
    Obj                 array )
{
    Obj                 perm;           /* permutation, result             */
    UInt4 *             ptr4;           /* pointer into perm               */
    UInt2 *             ptr2;           /* pointer into perm               */
    Obj                 val;            /* one entry as value              */
    UInt                c, p, l;        /* entries in permutation          */
    UInt                m;              /* maximal entry in permutation    */
    Obj                 cycle;          /* one cycle of permutation        */
    UInt                i, j, k;        /* loop variable                   */

    /* special case for identity permutation                               */
    if ( LEN_LIST(array) == 0 ) {
        return IdentityPerm;
    }

    /* allocate the new permutation                                        */
    m = 0;
    perm = NEW_PERM4( 0 );

    /* loop over the cycles                                                */
    for ( i = 1; i <= LEN_LIST(array); i++ ) {
        cycle = ELM_LIST( array, i );
        RequireSmallList("Array2Perm", cycle);

        /* loop over the entries of the cycle                              */
        c = p = l = 0;
        for ( j = LEN_LIST(cycle); 1 <= j; j-- ) {

            /* get and check current entry for the cycle                   */
            val = ELM_LIST( cycle, j );
            c = GetPositiveSmallIntEx("Permutation", val, "expr");
            if (c > MAX_DEG_PERM4)
              ErrorMayQuit( "Permutation literal exceeds maximum permutation degree",
                            0, 0);

            /* if necessary resize the permutation                         */
            if (DEG_PERM4(perm) < c) {
                ResizeBag(perm, SIZEBAG_PERM4((c + 1023) / 1024 * 1024));
                ptr4 = ADDR_PERM4( perm );
                for (k = m + 1; k <= DEG_PERM4(perm); k++) {
                    ptr4[k-1] = k-1;
                }
            }
            if ( m < c ) {
                m = c;
            }

            /* check that the cycles are disjoint                          */
            ptr4 = ADDR_PERM4( perm );
            if ( (p != 0 && p == c) || (ptr4[c-1] != c-1) ) {
                ErrorMayQuit(
                    "Permutation: cycles must be disjoint and duplicate-free",
                    0, 0);
            }

            /* enter the previous entry at current location                */
            ptr4 = ADDR_PERM4( perm );
            if ( p != 0 ) { ptr4[c-1] = p-1; }
            else          { l = c;          }

            /* remember current entry for next round                       */
            p = c;
        }

        /* enter first (last popped) entry at last (first popped) location */
        ptr4 = ADDR_PERM4( perm );
        if (ptr4[l-1] != l-1) {
            ErrorMayQuit(
                "Permutation: cycles must be disjoint and duplicate-free", 0,
                0);
        }
        ptr4[l-1] = p-1;

    }

    /* if possible represent the permutation with short entries            */
    if ( m <= 65536UL ) {
        ptr2 = ADDR_PERM2( perm );
        ptr4 = ADDR_PERM4( perm );
        for ( k = 1; k <= m; k++ ) {
            ptr2[k-1] = ptr4[k-1];
        };
        RetypeBag( perm, T_PERM2 );
        ResizeBag(perm, SIZEBAG_PERM2(m));
    }

    /* otherwise just shorten the permutation                              */
    else {
        ResizeBag(perm, SIZEBAG_PERM4(m));
    }

    /* return the permutation                                              */
    return perm;
}

static inline Int myquo(Obj pt, Obj perm)
{
  if (TNUM_OBJ(perm) == T_PERM2)
    return INT_INTOBJ(QuoIntPerm<UInt2>(pt, perm));
  else if (TNUM_OBJ(perm) == T_PERM4)
    return INT_INTOBJ(QuoIntPerm<UInt4>(pt, perm));
  else
    return INT_INTOBJ(QUO(pt, perm));
}
  

/* Stabilizer chain helper implements AddGeneratorsExtendSchreierTree Inner loop */
Obj FuncAGESTC( Obj self, Obj args)
{
  Int i,j;
  Obj pt;
  Obj oj, lj;
  Int img;
  Obj orbit = ELM_PLIST(args,1);
  Obj newlabs = ELM_PLIST(args,2);
  Obj cycles = ELM_PLIST(args,3);
  Obj labels = ELM_PLIST(args,4);
  Obj translabels = ELM_PLIST(args,5);
  Obj transversal = ELM_PLIST(args, 6);
  Obj genlabels = ELM_PLIST(args,7);
  Int len = LEN_PLIST(orbit);
  Int len2 = len;
  Int lenn = LEN_PLIST(newlabs);
  Int lenl = LEN_PLIST(genlabels);
  for (i = 1; i<= len; i++) {
    pt = ELM_PLIST(orbit, i);
    for (j = 1; j <= lenn; j++) {
      oj = ELM_PLIST(newlabs,j);
      lj = ELM_PLIST(labels, INT_INTOBJ(oj));
      img = myquo(pt, lj);
      if (img <= LEN_PLIST(translabels) && (Obj)0 != ELM_PLIST(translabels,img)) 
        ASS_LIST(cycles, i, True);
      else {
        ASS_LIST(translabels, img, oj);
        ASS_LIST(transversal, img, lj);
        ASS_LIST(orbit, ++len2, INTOBJ_INT(img));
        ASS_LIST(cycles, len2, False);
      }
    }
  }
  while (i <= len2) {
    pt = ELM_PLIST(orbit, i);
    for (j = 1; j <= lenl; j++) {
      oj = ELM_PLIST(genlabels, j);
      lj = ELM_PLIST(labels, INT_INTOBJ(oj));
      img = myquo(pt, lj);
      if (img <= LEN_PLIST(translabels) && (Obj)0 != ELM_PLIST(translabels,img)) 
        ASS_LIST(cycles, i, True);
      else {
        ASS_LIST(translabels, img, oj);
        ASS_LIST(transversal, img, lj);
        ASS_LIST(orbit, ++len2, INTOBJ_INT(img));
        ASS_LIST(cycles, len2, False);
      }
    }
    i++;
  }
  return (Obj) 0;
}

/* Stabilizer chain helper implements AddGeneratorsExtendSchreierTree Inner loop */
Obj FuncAGEST( Obj self, Obj orbit, Obj newlabs,  Obj labels, Obj translabels, Obj transversal, Obj genlabels)
{
  Int i,j;
  Int len = LEN_PLIST(orbit);
  Int len2 = len;
  Int lenn = LEN_PLIST(newlabs);
  Int lenl = LEN_PLIST(genlabels);
  Obj pt;
  Obj oj,lj;
  Int img;
  for (i = 1; i<= len; i++) {
    pt = ELM_PLIST(orbit, i);
    for (j = 1; j <= lenn; j++) {
      oj = ELM_PLIST(newlabs,j);
      lj = ELM_PLIST(labels, INT_INTOBJ(oj));
      img = myquo(pt,lj);
      if (img > LEN_PLIST(translabels) || (Obj)0 == ELM_PLIST(translabels,img)) {
        ASS_LIST(translabels, img, oj);
        ASS_LIST(transversal, img, lj);
        ASS_LIST(orbit, ++len2, INTOBJ_INT(img));
      }
    }
  }
  while (i <= len2) {
    pt = ELM_PLIST(orbit, i);
    for (j = 1; j <= lenl; j++) {
      oj = ELM_PLIST(genlabels, j);
      lj = ELM_PLIST(labels, INT_INTOBJ(oj));
      img = myquo(pt, lj);
        if (img > LEN_PLIST(translabels) || (Obj)0 == ELM_PLIST(translabels,img)) {
          ASS_LIST(translabels, img, oj);
          ASS_LIST(transversal, img, lj);
          ASS_LIST(orbit, ++len2, INTOBJ_INT(img));
        }
    }
    i++;
  }
  return (Obj) 0;
}


/****************************************************************************
**
*F  MappingPermListList( <src>, <dst> ) . . . . . return a perm mapping src to
**  dst
**
*/

#define DEGREELIMITONSTACK 512

Obj FuncMappingPermListList(Obj self, Obj src, Obj dst)
{
    Int l;
    Int i;
    Int d;
    Int next;
    Obj out;
    Obj tabdst, tabsrc;
    Int x;
    Obj obj;
    Int mytabs[DEGREELIMITONSTACK+1];
    Int mytabd[DEGREELIMITONSTACK+1];

    if (!IS_LIST(src) ) {
        ErrorMayQuit("first argument must be a list (not a %s)", (Int)TNAM_OBJ(src), 0L);
    }
    if (!IS_LIST(dst) ) {
        ErrorMayQuit("second argument must be a list (not a %s)", (Int)TNAM_OBJ(dst), 0L);
    }
    l = LEN_LIST(src);
    if (l != LEN_LIST(dst)) {
        ErrorMayQuit( "arguments must be lists of equal length", 0L, 0L);
    }
    d = 0;
    for (i = 1;i <= l;i++) {
        obj = ELM_LIST(src, i);
        if (!IS_POS_INTOBJ(obj)) {
            ErrorMayQuit("first argument must be a list of positive integers", 0L, 0L);
        }
        x = INT_INTOBJ(obj);
        if (x > d) d = x;
    }
    for (i = 1;i <= l;i++) {
        obj = ELM_LIST(dst, i);
        if (!IS_POS_INTOBJ(obj)) {
            ErrorMayQuit("second argument must be a list of positive integers", 0L, 0L);
        }
        x = INT_INTOBJ(obj);
        if (x > d) d = x;
    }
    if (d <= DEGREELIMITONSTACK) {
        /* Small case where we work on the stack: */
        memset(&mytabs,0,sizeof(mytabs));
        memset(&mytabd,0,sizeof(mytabd));
        for (i = 1;i <= l;i++) {
            Int val = INT_INTOBJ(ELM_LIST(src, i));
            if (mytabs[val]) {
                // Already read where this value maps, check it is the same
                if (ELM_LIST(dst, mytabs[val]) != ELM_LIST(dst, i)) {
                    return Fail;
                }
            }
            mytabs[val] = i;
        }
        for (i = 1;i <= l;i++) {
            Int val = INT_INTOBJ(ELM_LIST(dst, i));
            if (mytabd[val]) {
                // Already read where this value is mapped from, check it is
                // the same
                if (ELM_LIST(src, mytabd[val]) != ELM_LIST(src, i)) {
                    return Fail;
                }
            }
            mytabd[val] = i;
        }

        out = NEW_PLIST(T_PLIST_CYC,d);
        SET_LEN_PLIST(out,d);
        /* No garbage collection from here ... */
        next = 1;
        for (i = 1;i <= d;i++) {
            if (mytabs[i]) {   /* if i is in src */
                SET_ELM_PLIST(out,i, ELM_LIST(dst,mytabs[i]));
            } else {
                if (mytabd[i]) {
                    // Skip things in dst:
                    while (mytabd[next] ||
                           (mytabs[next] == 0 && mytabd[next] == 0))
                        next++;
                    SET_ELM_PLIST(out, i, INTOBJ_INT(next));
                    next++;
                }
                else {    // map elements in neither list to themselves
                    SET_ELM_PLIST(out, i, INTOBJ_INT(i));
                }
            }
        }
        /* ... to here! No CHANGED_BAG needed since this is a new object! */
    } else {
        /* Version with intermediate objects: */
        tabsrc = NEW_PLIST(T_PLIST,d);
        /* No garbage collection from here ... */
        for (i = 1;i <= l;i++) {
            Int val = INT_INTOBJ(ELM_LIST(src, i));
            if (ELM_PLIST(tabsrc, val)) {
                if (ELM_LIST(dst, INT_INTOBJ(ELM_PLIST(tabsrc, val))) !=
                    ELM_LIST(dst, i)) {
                    return Fail;
                }
            }
            else {
                SET_ELM_PLIST(tabsrc, val, INTOBJ_INT(i));
            }
        }
        /* ... to here! No CHANGED_BAG needed since this is a new object! */
        tabdst = NEW_PLIST(T_PLIST,d);
        /* No garbage collection from here ... */
        for (i = 1;i <= l;i++) {
            int val = INT_INTOBJ(ELM_LIST(dst, i));
            if (ELM_PLIST(tabdst, val)) {
                if (ELM_LIST(src, INT_INTOBJ(ELM_PLIST(tabdst, val))) !=
                    ELM_LIST(src, i)) {
                    return Fail;
                }
            }
            else {
                SET_ELM_PLIST(tabdst, val, INTOBJ_INT(i));
            }
        }
        /* ... to here! No CHANGED_BAG needed since this is a new object! */
        out = NEW_PLIST(T_PLIST_CYC,d);
        SET_LEN_PLIST(out,d);
        /* No garbage collection from here ... */
        next = 1;
        for (i = 1;i <= d;i++) {
            if (ELM_PLIST(tabsrc,i)) {   /* if i is in src */
                SET_ELM_PLIST(out,i,
                    ELM_LIST(dst,INT_INTOBJ(ELM_PLIST(tabsrc,i))));
            } else {
                if (ELM_PLIST(tabdst, i)) {
                    // Skip things in dst:
                    while (ELM_PLIST(tabdst, next) ||
                           (ELM_PLIST(tabdst, next) == 0 &&
                            ELM_PLIST(tabsrc, next) == 0)) {
                        next++;
                    }
                    SET_ELM_PLIST(out, i, INTOBJ_INT(next));
                    next++;
                }
                else {
                    SET_ELM_PLIST(out, i, INTOBJ_INT(i));
                }
            }
        }
        /* ... to here! No CHANGED_BAG needed since this is a new object! */
    }
    return FuncPermList(self,out);
}

/* InstallGlobalFunction( SCRSift, function ( S, g ) */
/*     local stb,   # the stabilizer of S we currently work with */
/*           bpt;   # first point of stb.orbit */

/*     stb := S; */
/*     while IsBound( stb.stabilizer ) do */
/*         bpt := stb.orbit[1]; */
/*         if IsBound( stb.transversal[bpt^g] ) then */
/*             while bpt <> bpt^g do */
/*                 g := g*stb.transversal[bpt^g]; */
/*             od; */
/*             stb := stb.stabilizer; */
/*         else */
/*             #current g witnesses that input was not in S */
/*             return g; */
/*         fi; */
/*     od; */

/*     return g; */
/* end ); */


Obj FuncSCR_SIFT_HELPER(Obj self, Obj S, Obj g, Obj n)
{
  Obj stb = S;
  static UInt RN_stabilizer = 0;
  static UInt RN_orbit = 0;
  static UInt RN_transversal = 0;
  UInt nn = INT_INTOBJ(n);
  UInt useP2;
  Obj result;
  Obj t;
  Obj trans;
  int i;

  /* Setup the result, sort out which rep we are going to work in  */
  if (nn > 65535) {
    result = NEW_PERM4(nn);
    useP2 = 0;
  } else {
    result = NEW_PERM2(nn);
    useP2 = 1;
  }

  UInt dg;
  if (IS_PERM2(g))
    dg = DEG_PERM2(g);
  else
    dg = DEG_PERM4(g);

  if (dg > nn) /* In this case the caller has messed up or 
                  g just ends with a lot of fixed points which we can 
                  ignore */
    dg = nn;

  /* Copy g into the buffer */
  if (IS_PERM2(g) && useP2) {
    UInt2 * ptR = ADDR_PERM2(result);
    memcpy(ptR, CONST_ADDR_PERM2(g), 2*dg);
    for ( i = dg; i < nn; i++)
      ptR[i] = (UInt2)i;
  } else if (IS_PERM4(g) && !useP2) {
    UInt4 *ptR = ADDR_PERM4(result);
    memcpy(ptR, CONST_ADDR_PERM4(g), 4*dg);
    for ( i = dg; i <nn; i++)
      ptR[i] = (UInt4)i;
  } else if (IS_PERM2(g) && !useP2) {
    UInt4 *ptR = ADDR_PERM4(result);
    const UInt2 *ptG = CONST_ADDR_PERM2(g);
    for ( i = 0; i < dg; i++)
      ptR[i] = (UInt4)ptG[i];
    for (i = dg; i < nn; i++)
      ptR[i] = (UInt4)i;
  } else {
    UInt2 *ptR = ADDR_PERM2(result);
    const UInt4 *ptG = CONST_ADDR_PERM4(g);
    for ( i = 0; i < dg; i++)
      ptR[i] = (UInt2)ptG[i];
    for (i = dg; i < nn; i++)
      ptR[i] = (UInt2)i;
  }    
    
  
  if (!RN_stabilizer)
    RN_stabilizer = RNamName("stabilizer");
  if (!RN_orbit)
    RN_orbit = RNamName("orbit");
  if (!RN_transversal)
    RN_transversal = RNamName("transversal");
  while (IsbPRec(stb,RN_stabilizer)) {
    trans = ElmPRec(stb, RN_transversal);
    Obj orb = ElmPRec(stb,RN_orbit);
    Int bpt = INT_INTOBJ(ELM_LIST(orb,1))-1;
    Int im;

    if (useP2) {
        const UInt2* ptrResult = CONST_ADDR_PERM2(result);
        UInt degResult = DEG_PERM2(result);
        im = (Int)(IMAGE(bpt, ptrResult, degResult));
    }
    else {
        const UInt4* ptrResult = CONST_ADDR_PERM4(result);
        UInt degResult = DEG_PERM2(result);
        im = (Int)(IMAGE(bpt, ptrResult, degResult));
    }

    if (!(t = ELM0_LIST(trans,im+1)))
      break;
    else {
      while (bpt != im) {

        /* Ugly -- eight versions of the loop */
        if (useP2) {
          UInt2 *ptR = ADDR_PERM2(result);
          if (IS_PERM2(t)) {
            const UInt2 *ptT = CONST_ADDR_PERM2(t);
            UInt dt = DEG_PERM2(t);
            if (dt >= nn)
              for (i = 0; i < nn; i++) 
                ptR[i] = ptT[ptR[i]];
            else
              for ( i = 0; i < nn; i++)
                ptR[i] = IMAGE(ptR[i], ptT, dt);
          }
          else {
            const UInt4 *ptT = CONST_ADDR_PERM4(t);
            UInt dt = DEG_PERM4(t);
            if (dt >= nn)
              for ( i = 0; i < nn; i++)
                ptR[i] = (UInt2) ptT[ptR[i]];
            else
              for ( i = 0; i < nn; i++)
                ptR[i] = (UInt2)IMAGE(ptR[i], ptT, dt);
          }
          im = (Int)ptR[bpt];
        } else {
          UInt4 *ptR = ADDR_PERM4(result);
          if (IS_PERM2(t)) {
            const UInt2 *ptT = CONST_ADDR_PERM2(t);
            UInt dt = DEG_PERM2(t);
            if (dt >= nn)
              for ( i = 0; i < nn; i++)
                ptR[i] = (UInt4)ptT[ptR[i]];
            else
              for ( i = 0; i < nn; i++)
                ptR[i] = (UInt4)IMAGE(ptR[i], ptT, dt);
          }
          else {
            const UInt4 *ptT = CONST_ADDR_PERM4(t);
            UInt dt = DEG_PERM4(t);
            if (dt >= nn)
              for ( i = 0; i < nn; i++)
                ptR[i] = ptT[ptR[i]];
            else
              for ( i = 0; i < nn; i++)
                ptR[i] = IMAGE(ptR[i], ptT, dt);
          }
          im = (Int)ptR[bpt];
        }
        t = ELM_PLIST(trans,im+1);
      }
    }
    stb = ElmPRec(stb, RN_stabilizer);
  }
  /* so we're done sifting, and now we just have to clean up result */  
  return result;
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
  { T_PERM2, "permutation (small)" },
  { T_PERM4, "permutation (large)" },
  { -1, "" }
};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    { "IS_PERM", "obj", &IsPermFilt,
      IsPermHandler, "src/permutat.c:IS_PERM" },

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(PermList, 1, "list"),
    GVAR_FUNC(LARGEST_MOVED_POINT_PERM, 1, "perm"),
    GVAR_FUNC(CYCLE_LENGTH_PERM_INT, 2, "perm, point"),
    GVAR_FUNC(CYCLE_PERM_INT, 2, "perm, point"),
    GVAR_FUNC(CYCLE_STRUCT_PERM, 1, "perm"),
    GVAR_FUNC(ORDER_PERM, 1, "perm"),
    GVAR_FUNC(SIGN_PERM, 1, "perm"),
    GVAR_FUNC(SMALLEST_GENERATOR_PERM, 1, "perm"),
    GVAR_FUNC(RESTRICTED_PERM, 3, "perm,domain,test"),
    GVAR_FUNC(TRIM_PERM, 2, "perm, degree"),
    GVAR_FUNC(SPLIT_PARTITION, 5, "Ppoints,Qn,j,g,a_b_max"),
    GVAR_FUNC(SMALLEST_IMG_TUP_PERM, 2, "tuple, perm"),
    GVAR_FUNC(DISTANCE_PERMS, 2, "perm1, perm2"),
    GVAR_FUNC(AGEST, 6, "orbit, newlabels, labels, translabels, transversal,genblabels"),
    GVAR_FUNC(AGESTC, -1, "orbit, newlabels, cycles, labels, translabels, transversal, genlabels"),
    GVAR_FUNC(MappingPermListList, 2, "src, dst"),
    GVAR_FUNC(SCR_SIFT_HELPER, 3, "stabrec, perm, n"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/

static Int InitKernel (
    StructInitInfo *    module )
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking function                                        */
    InitMarkFuncBags(T_PERM2, MarkOneSubBags);
    InitMarkFuncBags(T_PERM4, MarkOneSubBags);

#ifdef HPCGAP
    MakeBagTypePublic( T_PERM2);
    MakeBagTypePublic( T_PERM4);
#endif

    ImportGVarFromLibrary("PERM_INVERSE_THRESHOLD", &PERM_INVERSE_THRESHOLD);

    /* install the type functions                                           */
    ImportGVarFromLibrary( "TYPE_PERM2", &TYPE_PERM2 );
    ImportGVarFromLibrary( "TYPE_PERM4", &TYPE_PERM4 );


    TypeObjFuncs[ T_PERM2 ] = TypePerm2;
    TypeObjFuncs[ T_PERM4 ] = TypePerm4;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* make the buffer bag                                                 */
#ifndef HPCGAP
    InitGlobalBag( &TmpPerm, "src/permutat.cc:TmpPerm" );
#endif

    /* make the identity permutation                                       */
    InitGlobalBag( &IdentityPerm, "src/permutat.cc:IdentityPerm" );

    /* install the saving functions */
    SaveObjFuncs[ T_PERM2 ] = SavePerm2;
    SaveObjFuncs[ T_PERM4 ] = SavePerm4;
    LoadObjFuncs[ T_PERM2 ] = LoadPerm2;
    LoadObjFuncs[ T_PERM4 ] = LoadPerm4;

    /* install the printing functions                                      */
    PrintObjFuncs[ T_PERM2   ] = PrintPerm<UInt2>;
    PrintObjFuncs[ T_PERM4   ] = PrintPerm<UInt4>;

    /* install the comparison methods                                      */
    EqFuncs  [ T_PERM2  ][ T_PERM2  ] = EqPerm<UInt2, UInt2>;
    EqFuncs  [ T_PERM2  ][ T_PERM4  ] = EqPerm<UInt2, UInt4>;
    EqFuncs  [ T_PERM4  ][ T_PERM2  ] = EqPerm<UInt4, UInt2>;
    EqFuncs  [ T_PERM4  ][ T_PERM4  ] = EqPerm<UInt4, UInt4>;
    LtFuncs  [ T_PERM2  ][ T_PERM2  ] = LtPerm<UInt2, UInt2>;
    LtFuncs  [ T_PERM2  ][ T_PERM4  ] = LtPerm<UInt2, UInt4>;
    LtFuncs  [ T_PERM4  ][ T_PERM2  ] = LtPerm<UInt4, UInt2>;
    LtFuncs  [ T_PERM4  ][ T_PERM4  ] = LtPerm<UInt4, UInt4>;

    /* install the binary operations                                       */
    ProdFuncs[ T_PERM2  ][ T_PERM2  ] = ProdPerm<UInt2, UInt2>;
    ProdFuncs[ T_PERM2  ][ T_PERM4  ] = ProdPerm<UInt2, UInt4>;
    ProdFuncs[ T_PERM4  ][ T_PERM2  ] = ProdPerm<UInt4, UInt2>;
    ProdFuncs[ T_PERM4  ][ T_PERM4  ] = ProdPerm<UInt4, UInt4>;
    QuoFuncs[T_PERM2][T_PERM2] = QuoPerm;
    QuoFuncs[T_PERM2][T_PERM4] = QuoPerm;
    QuoFuncs[T_PERM4][T_PERM2] = QuoPerm;
    QuoFuncs[T_PERM4][T_PERM4] = QuoPerm;
    LQuoFuncs[ T_PERM2  ][ T_PERM2  ] = LQuoPerm<UInt2, UInt2>;
    LQuoFuncs[ T_PERM2  ][ T_PERM4  ] = LQuoPerm<UInt2, UInt4>;
    LQuoFuncs[ T_PERM4  ][ T_PERM2  ] = LQuoPerm<UInt4, UInt2>;
    LQuoFuncs[ T_PERM4  ][ T_PERM4  ] = LQuoPerm<UInt4, UInt4>;
    PowFuncs [ T_PERM2  ][ T_INT    ] = PowPermInt<UInt2>;
    PowFuncs [ T_PERM2  ][ T_INTPOS ] = PowPermInt<UInt2>;
    PowFuncs [ T_PERM2  ][ T_INTNEG ] = PowPermInt<UInt2>;
    PowFuncs [ T_PERM4  ][ T_INT    ] = PowPermInt<UInt4>;
    PowFuncs [ T_PERM4  ][ T_INTPOS ] = PowPermInt<UInt4>;
    PowFuncs [ T_PERM4  ][ T_INTNEG ] = PowPermInt<UInt4>;
    PowFuncs [ T_INT    ][ T_PERM2  ] = PowIntPerm<UInt2>;
    PowFuncs [ T_INTPOS ][ T_PERM2  ] = PowIntPerm<UInt2>;
    PowFuncs [ T_INT    ][ T_PERM4  ] = PowIntPerm<UInt4>;
    PowFuncs [ T_INTPOS ][ T_PERM4  ] = PowIntPerm<UInt4>;
    QuoFuncs [ T_INT    ][ T_PERM2  ] = QuoIntPerm<UInt2>;
    QuoFuncs [ T_INTPOS ][ T_PERM2  ] = QuoIntPerm<UInt2>;
    QuoFuncs [ T_INT    ][ T_PERM4  ] = QuoIntPerm<UInt4>;
    QuoFuncs [ T_INTPOS ][ T_PERM4  ] = QuoIntPerm<UInt4>;
    PowFuncs [ T_PERM2  ][ T_PERM2  ] = PowPerm<UInt2, UInt2>;
    PowFuncs [ T_PERM2  ][ T_PERM4  ] = PowPerm<UInt2, UInt4>;
    PowFuncs [ T_PERM4  ][ T_PERM2  ] = PowPerm<UInt4, UInt2>;
    PowFuncs [ T_PERM4  ][ T_PERM4  ] = PowPerm<UInt4, UInt4>;
    CommFuncs[ T_PERM2  ][ T_PERM2  ] = CommPerm<UInt2, UInt2>;
    CommFuncs[ T_PERM2  ][ T_PERM4  ] = CommPerm<UInt2, UInt4>;
    CommFuncs[ T_PERM4  ][ T_PERM2  ] = CommPerm<UInt4, UInt2>;
    CommFuncs[ T_PERM4  ][ T_PERM4  ] = CommPerm<UInt4, UInt4>;

    /* install the 'ONE' function for permutations                         */
    OneFuncs[ T_PERM2 ] = OnePerm;
    OneFuncs[ T_PERM4 ] = OnePerm;
    OneMutFuncs[ T_PERM2 ] = OnePerm;
    OneMutFuncs[ T_PERM4 ] = OnePerm;

    /* install the 'INV' function for permutations                         */
    InvFuncs[ T_PERM2 ] = InvPerm<UInt2>;
    InvFuncs[ T_PERM4 ] = InvPerm<UInt4>;
    InvMutFuncs[ T_PERM2 ] = InvPerm<UInt2>;
    InvMutFuncs[ T_PERM4 ] = InvPerm<UInt4>;

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    /* make the identity permutation                                       */
    IdentityPerm = NEW_PERM2(0);

    /* return success                                                      */
    return 0;
}


static Int InitModuleState(void)
{
    /* make the buffer bag                                                 */
    TmpPerm = 0;

    // return success
    return 0;
}


/****************************************************************************
**
*F  InitInfoPermutat()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
 /* type        = */ MODULE_BUILTIN,
 /* name        = */ "permutat",
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
 /* moduleStateSize      = */ sizeof(PermutatModuleState),
 /* moduleStateOffsetPtr = */ &PermutatStateOffset,
 /* initModuleState      = */ InitModuleState,
 /* destroyModuleState   = */ 0,
};

StructInitInfo * InitInfoPermutat ( void )
{
    return &module;
}
