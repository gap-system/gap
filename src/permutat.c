/****************************************************************************
**
*W  permutat.c                  GAP source                   Martin Schönert
**                                                           & Alice Niemeyer
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions for permutations (small and large).
**
**  Mathematically a permutation is a bijective mapping  of a finite set onto
**  itself.  In \GAP\ this subset must always be of the form [ 1, 2, .., N ],
**  where N is at most $2^16$.
**
**  Internally a permutation  is viewed as a mapping  of [ 0,  1,  .., N-1 ],
**  because in C indexing of  arrays is done with the origin  0 instead of 1.
**  A permutation is represented by a bag of type 'T_PERM' of the form
**
**      +-------+-------+-------+-------+- - - -+-------+-------+
**      | image | image | image | image |       | image | image |
**      | of  0 | of  1 | of  2 | of  3 |       | of N-2| of N-1|
**      +-------+-------+-------+-------+- - - -+-------+-------+
**
**  The entries of the bag are of type  'UInt2'  (defined in 'system.h' as an
**  at least 16 bit   wide unsigned integer  type).   The first entry is  the
**  image of 0, the second is the image of 1, and so  on.  Thus, the entry at
**  C index <i> is the image of <i>, if we view the permutation as mapping of
**  [ 0, 1, 2, .., N-1 ] as described above.
**
**  Permutations are never  shortened.  For  example, if  the product  of two
**  permutations of degree 100 is the identity, it  is nevertheless stored as
**  array of length 100, in  which the <i>-th  entry is of course simply <i>.
**  Testing whether a product has trailing  fixpoints would be pretty costly,
**  and permutations of equal degree can be handled by the functions faster.
**
*N  13-Jan-91 martin should add 'CyclesPerm', 'CycleLengthsPerm'
*/

#include <src/permutat.h>

#include <src/ariths.h>
#include <src/bool.h>
#include <src/gap.h>
#include <src/gapstate.h>
#include <src/integer.h>
#include <src/io.h>
#include <src/listfunc.h>
#include <src/lists.h>
#include <src/opers.h>
#include <src/plist.h>
#include <src/precord.h>
#include <src/range.h>
#include <src/records.h>
#include <src/saveload.h>
#include <src/sysfiles.h>
#include <src/trans.h>

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
*F  IMAGETWO(<i>,<pt>,<dg>)  . . . . . .  image of <i> under <pt> of degree <dg>
**
**  as IMAGE but for a 2-byte permutation: If we map, we have to cast in UInt2.
*/
#define IMAGETWO(i,pt,dg)  (((i) < (dg)) ? (pt)[(UInt2)(i)] : (i))


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


static void UseTmpPerm(UInt size)
{
    if (TmpPerm == (Obj)0)
        TmpPerm  = NewBag(T_PERM4, size);
    else if (SIZE_BAG(TmpPerm) < size)
        ResizeBag(TmpPerm, size);
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
void            PrintPerm2 (
    Obj                 perm )
{
    UInt                degPerm;        /* degree of the permutation       */
    const UInt2 *       ptPerm;         /* pointer to the permutation      */
    UInt                p,  q;          /* loop variables                  */
    UInt                isId;           /* permutation is the identity?    */
    const char *        fmt1;           /* common formats to print points  */
    const char *        fmt2;           /* common formats to print points  */

    /* set up the formats used, so all points are printed with equal width */
    degPerm = DEG_PERM2(perm);
    if      ( degPerm <    10 ) { fmt1 = "%>(%>%1d%<"; fmt2 = ",%>%1d%<"; }
    else if ( degPerm <   100 ) { fmt1 = "%>(%>%2d%<"; fmt2 = ",%>%2d%<"; }
    else if ( degPerm <  1000 ) { fmt1 = "%>(%>%3d%<"; fmt2 = ",%>%3d%<"; }
    else if ( degPerm < 10000 ) { fmt1 = "%>(%>%4d%<"; fmt2 = ",%>%4d%<"; }
    else                        { fmt1 = "%>(%>%5d%<"; fmt2 = ",%>%5d%<"; }

    /* run through all points                                              */
    isId = 1;
    ptPerm = CONST_ADDR_PERM2(perm);
    for ( p = 0; p < degPerm; p++ ) {

        /* find the smallest element in this cycle                         */
        q = ptPerm[p];
        while ( p < q )  q = ptPerm[q];

        /* if the smallest is the one we started with lets print the cycle */
        if ( p == q && ptPerm[p] != p ) {
            isId = 0;
            Pr(fmt1,(Int)(p+1),0L);
            for ( q = CONST_ADDR_PERM2(perm)[p]; q != p; q = CONST_ADDR_PERM2(perm)[q] ) {
                Pr(fmt2,(Int)(q+1),0L);
            }
            Pr("%<)",0L,0L);
            /* restore pointer, in case Pr caused a garbage collection */
            ptPerm = CONST_ADDR_PERM2(perm);  
        }

    }

    /* special case for the identity                                       */
    if ( isId )  Pr("()",0L,0L);
}

void            PrintPerm4 (
    Obj                 perm )
{
    UInt                degPerm;        /* degree of the permutation       */
    const UInt4 *       ptPerm;         /* pointer to the permutation      */
    UInt                p,  q;          /* loop variables                  */
    UInt                isId;           /* permutation is the identity?    */
    const char *        fmt1;           /* common formats to print points  */
    const char *        fmt2;           /* common formats to print points  */

    /* set up the formats used, so all points are printed with equal width */
    degPerm = DEG_PERM4(perm);
    if      ( degPerm <    10 ) { fmt1 = "%>(%>%1d%<"; fmt2 = ",%>%1d%<"; }
    else if ( degPerm <   100 ) { fmt1 = "%>(%>%2d%<"; fmt2 = ",%>%2d%<"; }
    else if ( degPerm <  1000 ) { fmt1 = "%>(%>%3d%<"; fmt2 = ",%>%3d%<"; }
    else if ( degPerm < 10000 ) { fmt1 = "%>(%>%4d%<"; fmt2 = ",%>%4d%<"; }
    else                        { fmt1 = "%>(%>%5d%<"; fmt2 = ",%>%5d%<"; }

    /* run through all points                                              */
    isId = 1;
    ptPerm = CONST_ADDR_PERM4(perm);
    for ( p = 0; p < degPerm; p++ ) {

        /* find the smallest element in this cycle                         */
        q = ptPerm[p];
        while ( p < q )  q = ptPerm[q];

        /* if the smallest is the one we started with lets print the cycle */
        if ( p == q && ptPerm[p] != p ) {
            isId = 0;
            Pr(fmt1,(Int)(p+1),0L);
            for ( q = CONST_ADDR_PERM4(perm)[p]; q != p; q = CONST_ADDR_PERM4(perm)[q] )
                Pr(fmt2,(Int)(q+1),0L);
            Pr("%<)",0L,0L);
            /* restore pointer, in case Pr caused a garbage collection */
            ptPerm = CONST_ADDR_PERM4(perm);
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
Int             EqPerm22 (
    Obj                 opL,
    Obj                 opR ) {
  return EqPermTrans22(DEG_PERM2(opL), 
                       DEG_PERM2(opR), 
                       CONST_ADDR_PERM2(opL),
                       CONST_ADDR_PERM2(opR));
}

Int             EqPerm44 (
    Obj                 opL,
    Obj                 opR ) {
  return EqPermTrans44(DEG_PERM4(opL), 
                       DEG_PERM4(opR), 
                       CONST_ADDR_PERM4(opL),
                       CONST_ADDR_PERM4(opR));
}

Int             EqPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees                                                     */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM4(opR);

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

Int EqPerm42(Obj opL, Obj opR)
{
    return EqPerm24(opR, opL);
}

/****************************************************************************
**
*F  LtPerm( <opL>, <opR> )  . test if one permutation is smaller than another
**
**  'LtPerm' returns  'true' if the permutation <opL>  is strictly  less than
**  the permutation  <opR>.  Permutations are  ordered lexicographically with
**  respect to the images of 1,2,.., etc.
*/
Int             LtPerm22 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM2(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {
      
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) ) {
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) ) {
                if (        p < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) ) {
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) != p ) {
                if ( *(--ptL) <        p )  return 1L ;
                else                        return 0L;
	    }
    }

    /* otherwise they must be equal                                        */
    return 0L;
}

Int             LtPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM4(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) ) {
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) ) {
                if (        p < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) ) {
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) != p ) {
                if ( *(--ptL) <        p )  return 1L ;
                else                        return 0L;
	    }
    }

    /* otherwise they must be equal                                        */
    return 0L;
}

Int             LtPerm42 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM2(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) ) {
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) ) {
                if (        p < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) ) {
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) != p ) {
                if ( *(--ptL) <        p )  return 1L ;
                else                        return 0L;
	    }
    }

    /* otherwise they must be equal                                        */
    return 0L;
}

Int             LtPerm44 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM4(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) ) {
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) ) {
                if (        p < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) ) {
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
	    }
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) != p ) {
                if ( *(--ptL) <        p )  return 1L ;
                else                        return 0L;
	    }
    }

    /* otherwise they must be equal                                        */
    return 0L;
}


/****************************************************************************
**
*F  ProdPerm( <opL>, <opR> )  . . . . . . . . . . . . product of permutations
**
**  'ProdPerm' returns the product of the two permutations <opL> and <opR>.
**
**  This is a little bit tuned but should be sufficiently easy to understand.
*/
Obj             ProdPerm22 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 prd;            /* handle of the product (result)  */
    UInt                degP;           /* degree of the product           */
    UInt2 *             ptP;            /* pointer to the product          */
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM2( degP );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM2(opR);
    ptP = ADDR_PERM2(prd);

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


Obj             ProdPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 prd;            /* handle of the product (result)  */
    UInt                degP;           /* degree of the product           */
    UInt4 *             ptP;            /* pointer to the product          */
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM4( degP );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM4(opR);
    ptP = ADDR_PERM4(prd);

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


Obj             ProdPerm42 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 prd;            /* handle of the product (result)  */
    UInt                degP;           /* degree of the product           */
    UInt4 *             ptP;            /* pointer to the product          */
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM4( degP );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM2(opR);
    ptP = ADDR_PERM4(prd);

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


Obj             ProdPerm44 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 prd;            /* handle of the product (result)  */
    UInt                degP;           /* degree of the product           */
    UInt4 *             ptP;            /* pointer to the product          */
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM4( degP );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM4(opR);
    ptP = ADDR_PERM4(prd);

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
Obj InvPerm(Obj);

Obj QuoPerm(Obj opL, Obj opR)
{
    return PROD(opL, InvPerm(opR));
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
Obj             LQuoPerm22 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 mod;            /* handle of the quotient (result) */
    UInt                degM;           /* degree of the quotient          */
    UInt2 *             ptM;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM2( degM );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM2(opR);
    ptM = ADDR_PERM2(mod);

    /* its one thing if the left (inner) permutation is smaller            */
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

Obj             LQuoPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 mod;            /* handle of the quotient (result) */
    UInt                degM;           /* degree of the quotient          */
    UInt4 *             ptM;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM4( degM );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM4(opR);
    ptM = ADDR_PERM4(mod);

    /* its one thing if the left (inner) permutation is smaller            */
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

Obj             LQuoPerm42 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 mod;            /* handle of the quotient (result) */
    UInt                degM;           /* degree of the quotient          */
    UInt4 *             ptM;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM4( degM );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM2(opR);
    ptM = ADDR_PERM4(mod);

    /* its one thing if the left (inner) permutation is smaller            */
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

Obj             LQuoPerm44 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 mod;            /* handle of the quotient (result) */
    UInt                degM;           /* degree of the quotient          */
    UInt4 *             ptM;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM4( degM );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM4(opR);
    ptM = ADDR_PERM4(mod);

    /* its one thing if the left (inner) permutation is smaller            */
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
*F  PowPermInt( <opL>, <opR> )  . . . . . . .  integer power of a permutation
**
**  'PowPermInt' returns the <opR>-th power  of the permutation <opL>.  <opR>
**  must be a small integer.
**
**  This repeatedly applies the permutation <opR> to all points  which  seems
**  to be faster than binary powering, and does not need  temporary  storage.
*/

Obj             PowPerm2Int (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 pow;            /* handle of the power (result)    */
    UInt2 *             ptP;            /* pointer to the power            */
    const UInt2 *       ptL;            /* pointer to the permutation      */
    UInt2 *             ptKnown;        /* pointer to temporary bag        */
    UInt                deg;            /* degree of the permutation       */
    Int                 exp,  e;        /* exponent (right operand)        */
    UInt                len;            /* length of cycle (result)        */
    UInt                p,  q,  r;      /* loop variables                  */


    /* handle zeroth and first powers and stored inverses separately */
    if ( opR == INTOBJ_INT(0)) 
      return IdentityPerm;
    if ( opR == INTOBJ_INT(1))
      return opL;
    if (opR == INTOBJ_INT(-1) && STOREDINV_PERM(opL) != 0)
        return STOREDINV_PERM(opL);

    /* get the operands and allocate a result bag                          */
    deg = DEG_PERM2(opL);
    pow = NEW_PERM2( deg );

    /* compute the power by repeated mapping for small positive exponents  */
    if ( IS_INTOBJ(opR)
      && 2 <= INT_INTOBJ(opR) && INT_INTOBJ(opR) < 8 ) {

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM2(opL);
        ptP = ADDR_PERM2(pow);

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
        ptKnown = ADDR_PERM2(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM2(opL); p++ )
            ptKnown[p] = 0;

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM2(opL);
        ptP = ADDR_PERM2(pow);

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
        ptKnown = ADDR_PERM2(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM2(opL); p++ )
            ptKnown[p] = 0;

        /* get pointer to the permutation and the power                    */
        ptL = CONST_ADDR_PERM2(opL);
        ptP = ADDR_PERM2(pow);

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

    /* special case for inverting permutations                             */
    else if ( IS_INTOBJ(opR) && INT_INTOBJ(opR) == -1 ) {

        /* get pointer to the permutation and the power                    */
        ptL = CONST_ADDR_PERM2(opL);
        ptP = ADDR_PERM2(pow);

        /* invert the permutation                                          */
        for ( p = 0; p < deg; p++ )
            ptP[ *(ptL++) ] = p;

    }

    /* compute the power by repeated mapping for small negative exponents  */
    else if ( IS_INTOBJ(opR)
          && -8 < INT_INTOBJ(opR) && INT_INTOBJ(opR) < 0 ) {

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM2(opL);
        ptP = ADDR_PERM2(pow);

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
        ptKnown = ADDR_PERM2(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM2(opL); p++ )
            ptKnown[p] = 0;

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM2(opL);
        ptP = ADDR_PERM2(pow);

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

        /* make sure that the buffer bag is large enough                   */
        UseTmpPerm(SIZE_OBJ(opL));
        ptKnown = ADDR_PERM2(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM2(opL); p++ )
            ptKnown[p] = 0;

        /* get pointer to the permutation and the power                    */
        opR = AInvInt(opR);
        ptL = CONST_ADDR_PERM2(opL);
        ptP = ADDR_PERM2(pow);

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

Obj             PowPerm4Int (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 pow;            /* handle of the power (result)    */
    UInt4 *             ptP;            /* pointer to the power            */
    const UInt4 *       ptL;            /* pointer to the permutation      */
    UInt4 *             ptKnown;        /* pointer to temporary bag        */
    UInt                deg;            /* degree of the permutation       */
    Int                 exp,  e;        /* exponent (right operand)        */
    UInt                len;            /* length of cycle (result)        */
    UInt                p,  q,  r;      /* loop variables                  */

    /* handle zeroth and first powers separately  and stored inverses */
    if ( opR == INTOBJ_INT(0)) 
      return IdentityPerm;
    if ( opR == INTOBJ_INT(1))
      return opL;
    if (opR == INTOBJ_INT(-1) && STOREDINV_PERM(opL) != 0)
        return STOREDINV_PERM(opL);


    /* get the operands and allocate a result bag                          */
    deg = DEG_PERM4(opL);
    pow = NEW_PERM4( deg );

    /* compute the power by repeated mapping for small positive exponents  */
    if ( IS_INTOBJ(opR)
      && 0 <= INT_INTOBJ(opR) && INT_INTOBJ(opR) < 8 ) {

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM4(opL);
        ptP = ADDR_PERM4(pow);

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
        ptKnown = ADDR_PERM4(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM4(opL); p++ )
            ptKnown[p] = 0;

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM4(opL);
        ptP = ADDR_PERM4(pow);

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
        ptKnown = ADDR_PERM4(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM4(opL); p++ )
            ptKnown[p] = 0;

        /* get pointer to the permutation and the power                    */
        ptL = CONST_ADDR_PERM4(opL);
        ptP = ADDR_PERM4(pow);

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

    /* special case for inverting permutations                             */
    else if ( IS_INTOBJ(opR) && INT_INTOBJ(opR) == -1 ) {

        /* get pointer to the permutation and the power                    */
        ptL = CONST_ADDR_PERM4(opL);
        ptP = ADDR_PERM4(pow);

        /* invert the permutation                                          */
        for ( p = 0; p < deg; p++ )
            ptP[ *(ptL++) ] = p;

    }

    /* compute the power by repeated mapping for small negative exponents  */
    else if ( IS_INTOBJ(opR)
           && -8 < INT_INTOBJ(opR) && INT_INTOBJ(opR) < 0 ) {

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM4(opL);
        ptP = ADDR_PERM4(pow);

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
        ptKnown = ADDR_PERM4(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM4(opL); p++ )
            ptKnown[p] = 0;

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = CONST_ADDR_PERM4(opL);
        ptP = ADDR_PERM4(pow);

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

        /* make sure that the buffer bag is large enough                   */
        UseTmpPerm(SIZE_OBJ(opL));
        ptKnown = ADDR_PERM4(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM4(opL); p++ )
            ptKnown[p] = 0;

        /* get pointer to the permutation and the power                    */
        opR = AInvInt(opR);
        ptL = CONST_ADDR_PERM4(opL);
        ptP = ADDR_PERM4(pow);

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
*F  InvPerm( <perm> ) . . . . . . . . . . . . . . .  inverse of a permutation
*/
Obj InvPerm (
    Obj             perm )
{
    Obj inv = STOREDINV_PERM(perm);
    if (inv != 0)
        return inv;
    inv = POW(perm, INTOBJ_INT(-1));
    SET_STOREDINV_PERM(perm, inv);
    return inv;
}


/****************************************************************************
**
*F  PowIntPerm( <opL>, <opR> )  . . . image of an integer under a permutation
**
**  'PowIntPerm' returns the  image of the positive  integer  <opL> under the
**  permutation <opR>.  If <opL>  is larger than the  degree of <opR> it is a
**  fixpoint of the permutation and thus simply returned.
*/
Obj             PowIntPerm2 (
    Obj                 opL,
    Obj                 opR )
{
    Int                 img;            /* image (result)                  */

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TNUM_OBJ(opL) == T_INTPOS )
        return opL;

    /* permutations do not act on negative integers                        */
    img = INT_INTOBJ( opL );
    if ( img <= 0 ) {
        opL = ErrorReturnObj(
            "Perm. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L,
            "you can replace <point> via 'return <point>;'" );
        return POW( opL, opR );
    }

    /* compute the image                                                   */
    if ( img <= DEG_PERM2(opR) ) {
        img = (CONST_ADDR_PERM2(opR))[img-1] + 1;
    }

    /* return it                                                           */
    return INTOBJ_INT(img);
}

Obj             PowIntPerm4 (
    Obj                 opL,
    Obj                 opR )
{
    Int                 img;            /* image (result)                  */

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TNUM_OBJ(opL) == T_INTPOS )
        return opL;

    /* permutations do not act on negative integers                        */
    img = INT_INTOBJ( opL );
    if ( img <= 0 ) {
        opL = ErrorReturnObj(
            "Perm. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L,
            "you can replace <point> via 'return <point>;'" );
        return POW( opL, opR );
    }

    /* compute the image                                                   */
    if ( img <= DEG_PERM4(opR) ) {
        img = (CONST_ADDR_PERM4(opR))[img-1] + 1;
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

Obj             QuoIntPerm2 (
    Obj                 opL,
    Obj                 opR )
{
    UInt2               pre;            /* preimage (result)               */
    Int                 img;            /* image (left operand)            */
    const UInt2 *       ptR;            /* pointer to the permutation      */

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TNUM_OBJ(opL) == T_INTPOS )
        return opL;

    /* permutations do not act on negative integers                        */
    img = INT_INTOBJ(opL);
    if ( img <= 0 ) {
        opL = ErrorReturnObj(
            "Perm. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L,
            "you can replace <point> via 'return <point>;'" );
        return QUO( opL, opR );
    }

    Obj inv = STOREDINV_PERM(opR);

    if (inv == 0 && PERM_INVERSE_THRESHOLD != 0 &&
        IS_INTOBJ(PERM_INVERSE_THRESHOLD) &&
        DEG_PERM2(opR) <= INT_INTOBJ(PERM_INVERSE_THRESHOLD))
        inv = InvPerm(opR);

    if (inv != 0)
        return INTOBJ_INT(
            IMAGE(img - 1, CONST_ADDR_PERM2(inv), DEG_PERM2(inv)) + 1);

    /* compute the preimage                                                */
    if ( img <= DEG_PERM2(opR) ) {
        pre = (UInt2)(img - 1);
        ptR = CONST_ADDR_PERM2(opR);
        while (ptR[pre] != (UInt2)(img - 1))
            pre = ptR[pre];
        /* return it */
        return INTOBJ_INT(pre + 1);
    }
    else
        return INTOBJ_INT(img);
}

Obj             QuoIntPerm4 (
    Obj                 opL,
    Obj                 opR )
{
    UInt4               pre;            /* preimage (result)               */
    Int                 img;            /* image (left operand)            */
    const UInt4 *       ptR;            /* pointer to the permutation      */

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TNUM_OBJ(opL) == T_INTPOS )
        return opL;

    /* permutations do not act on negative integers                        */
    img = INT_INTOBJ(opL);
    if ( img <= 0 ) {
        opL = ErrorReturnObj(
            "Perm. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L,
            "you can replace <point> via 'return <point>;'" );
        return QUO( opL, opR );
    }

    Obj inv = STOREDINV_PERM(opR);

    if (inv == 0 && PERM_INVERSE_THRESHOLD != 0 &&
        IS_INTOBJ(PERM_INVERSE_THRESHOLD) &&
        DEG_PERM2(opR) <= INT_INTOBJ(PERM_INVERSE_THRESHOLD))
        inv = InvPerm(opR);

    if (inv != 0)
        return INTOBJ_INT(
            IMAGE(img - 1, CONST_ADDR_PERM4(inv), DEG_PERM4(inv)) + 1);

    /* compute the preimage                                                */
    if ( img <= DEG_PERM4(opR) ) {
        pre = (UInt4)(img - 1);
        ptR = CONST_ADDR_PERM4(opR);
        while (ptR[pre] != (UInt4)(img - 1))
            pre = ptR[pre];
        /* return it */
        return INTOBJ_INT((Int)(pre + 1));
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
Obj             PowPerm22 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 cnj;            /* handle of the conjugation (res) */
    UInt                degC;           /* degree of the conjugation       */
    UInt2 *             ptC;            /* pointer to the conjugation      */
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM2( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM2(opR);
    ptC = ADDR_PERM2(cnj);

    /* its faster if the both permutations have the same size              */
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

Obj             PowPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 cnj;            /* handle of the conjugation (res) */
    UInt                degC;           /* degree of the conjugation       */
    UInt4 *             ptC;            /* pointer to the conjugation      */
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM4(opR);
    ptC = ADDR_PERM4(cnj);

    /* its faster if the both permutations have the same size              */
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

Obj             PowPerm42 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 cnj;            /* handle of the conjugation (res) */
    UInt                degC;           /* degree of the conjugation       */
    UInt4 *             ptC;            /* pointer to the conjugation      */
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM2(opR);
    ptC = ADDR_PERM4(cnj);

    /* its faster if the both permutations have the same size              */
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

Obj             PowPerm44 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 cnj;            /* handle of the conjugation (res) */
    UInt                degC;           /* degree of the conjugation       */
    UInt4 *             ptC;            /* pointer to the conjugation      */
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM4(opR);
    ptC = ADDR_PERM4(cnj);

    /* its faster if the both permutations have the same size              */
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
Obj             CommPerm22 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 com;            /* handle of the commutator  (res) */
    UInt                degC;           /* degree of the commutator        */
    UInt2 *             ptC;            /* pointer to the commutator       */
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM2( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM2(opR);
    ptC = ADDR_PERM2(com);

    /* its faster if the both permutations have the same size              */
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

Obj             CommPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 com;            /* handle of the commutator  (res) */
    UInt                degC;           /* degree of the commutator        */
    UInt4 *             ptC;            /* pointer to the commutator       */
    UInt                degL;           /* degree of the left operand      */
    const UInt2 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM2(opL);
    ptR = CONST_ADDR_PERM4(opR);
    ptC = ADDR_PERM4(com);

    /* its faster if the both permutations have the same size              */
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

Obj             CommPerm42 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 com;            /* handle of the commutator  (res) */
    UInt                degC;           /* degree of the commutator        */
    UInt4 *             ptC;            /* pointer to the commutator       */
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt2 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM2(opR);
    ptC = ADDR_PERM4(com);

    /* its faster if the both permutations have the same size              */
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

Obj             CommPerm44 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 com;            /* handle of the commutator  (res) */
    UInt                degC;           /* degree of the commutator        */
    UInt4 *             ptC;            /* pointer to the commutator       */
    UInt                degL;           /* degree of the left operand      */
    const UInt4 *       ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    const UInt4 *       ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = CONST_ADDR_PERM4(opL);
    ptR = CONST_ADDR_PERM4(opR);
    ptC = ADDR_PERM4(com);

    /* its faster if the both permutations have the same size              */
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
Obj             FuncPermList (
    Obj                 self,
    Obj                 list )
{
    Obj                 perm;           /* handle of the permutation       */
    UInt2 *             ptPerm2;        /* pointer to the permutation      */
    UInt4 *             ptPerm4;        /* pointer to the permutation      */
    UInt                degPerm;        /* degree of the permutation       */
    const Obj *         ptList;         /* pointer to the list             */
    UInt2 *             ptTmp2;         /* pointer to the buffer bag       */
    UInt4 *             ptTmp4;         /* pointer to the buffer bag       */
    Int                 i,  k;          /* loop variables                  */

    /* check the arguments                                                 */
    while ( ! IS_SMALL_LIST( list ) ) {
        list = ErrorReturnObj(
            "PermList: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can replace <list> via 'return <list>;'" );
    }
    PLAIN_LIST( list );

    /* handle small permutations                                           */
    if ( LEN_LIST( list ) <= 65536 ) {

        degPerm = LEN_LIST( list );

        /* make sure that the global buffer bag is large enough for checkin*/
        UseTmpPerm(SIZEBAG_PERM2(degPerm));

        /* allocate the bag for the permutation and get pointer            */
        perm    = NEW_PERM2( degPerm );
        ptPerm2 = ADDR_PERM2(perm);
        ptList  = CONST_ADDR_OBJ(list);
        ptTmp2  = ADDR_PERM2(TmpPerm);

        /* make the buffer bag clean                                       */
        for ( i = 1; i <= degPerm; i++ )
            ptTmp2[i-1] = 0;

        /* run through all entries of the list                             */
        for ( i = 1; i <= degPerm; i++ ) {

            /* get the <i>th entry of the list                             */
            if ( ptList[i] == 0 ) {
                /* list = ErrorReturnObj(
                    "PermList: <list>[%d] must have an assigned value",
                    (Int)i, 0L,
                    "you can replace <list> via 'return <list>;'" );
                return FuncPermList( 0, list ); */
		return Fail;
            }
            if ( !IS_INTOBJ(ptList[i]) ) {
                /* list = ErrorReturnObj(
                    "PermList: <list>[%d] must be a integer",
                    (Int)i, 0L,
                    "you can replace <list> via 'return <list>;'" );
                return FuncPermList( 0, list ); */
		return Fail;
            }
            k = INT_INTOBJ(ptList[i]);
            if ( k <= 0 || degPerm < k ) {
                /* list = ErrorReturnObj(
                    "PermList: <list>[%d] must lie in [1..%d]",
                    (Int)i, (Int)degPerm,
                    "you can replace <list> via 'return <list>;'" );
                return FuncPermList( 0, list ); */
		return Fail;
            }

            /* make sure we haven't seen this entry yet                     */
            if ( ptTmp2[k-1] != 0 ) {
		/* list = ErrorReturnObj(
                    "PermList: the point %d must occur only once",
                    (Int)k, 0L,
                    "you can replace <list> via 'return <list>;'" );
                return FuncPermList( 0, list ); */
		return Fail;
            }
            ptTmp2[k-1] = 1;

            /* and finally copy it into the permutation                    */
            ptPerm2[i-1] = k-1;
        }

    }

    /* handle large permutations                                           */
    else {

        degPerm = LEN_LIST( list );

	if (degPerm > MAX_DEG_PERM4)
	  ErrorMayQuit("PermList: list length %i exceeds maximum permutation degree %i\n",
		       degPerm, MAX_DEG_PERM4);

        /* make sure that the global buffer bag is large enough for checkin*/
        UseTmpPerm(SIZEBAG_PERM4(degPerm));

        /* allocate the bag for the permutation and get pointer            */
        perm    = NEW_PERM4( degPerm );
        ptPerm4 = ADDR_PERM4(perm);
        ptList  = CONST_ADDR_OBJ( list);
        ptTmp4  = ADDR_PERM4(TmpPerm);

        /* make the buffer bag clean                                       */
        for ( i = 1; i <= degPerm; i++ )
            ptTmp4[i-1] = 0;

        /* run through all entries of the list                             */
        for ( i = 1; i <= degPerm; i++ ) {

            /* get the <i>th entry of the list                             */
            if ( ptList[i] == 0 ) {
                /* list = ErrorReturnObj(
                    "PermList: <list>[%d] must have an assigned value",
                    (Int)i, 0L,
                    "you can replace <list> via 'return <list>;'" );
                return FuncPermList( 0, list ); */
		return Fail;
            }
            if ( !IS_INTOBJ(ptList[i]) ) {
                /* list = ErrorReturnObj(
                    "PermList: <list>[%d] must be a integer",
                    (Int)i, 0L,
                    "you can replace <list> via 'return <list>;'" );
                return FuncPermList( 0, list ); */
		return Fail;
            }
            k = INT_INTOBJ(ptList[i]);
            if ( k <= 0 || degPerm < k ) {
                /* list = ErrorReturnObj(
                    "PermList: <list>[%d] must lie in [1..%d]",
                    (Int)i, (Int)degPerm,
                    "you can replace <list> via 'return <list>;'" );
                return FuncPermList( 0, list ); */
		return Fail;
            }

            /* make sure we haven't seen this entry yet                     */
            if ( ptTmp4[k-1] != 0 ) {
                /* list = ErrorReturnObj(
                    "PermList: the point %d must occur only once",
                    (Int)k, 0L,
                    "you can replace <list> via 'return <list>;'" );
                return FuncPermList( 0, list ); */
		return Fail;
            }
            ptTmp4[k-1] = 1;

            /* and finally copy it into the permutation                    */
            ptPerm4[i-1] = k-1;
        }

    }

    /* return the permutation                                              */
    return perm;
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
UInt LargestMovedPointPerm(Obj perm)
{
    UInt                sup;            /* support (result)                */
    const UInt2 *       ptPerm2;        /* pointer to the permutation      */
    const UInt4 *       ptPerm4;        /* pointer to the permutation      */

    GAP_ASSERT(TNUM_OBJ(perm) == T_PERM2 || TNUM_OBJ(perm) == T_PERM4);

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* find the largest moved point                                    */
        ptPerm2 = CONST_ADDR_PERM2(perm);
        for ( sup = DEG_PERM2(perm); 1 <= sup; sup-- ) {
            if ( ptPerm2[sup-1] != sup-1 )
                break;
        }

    }

    /* handle large permutations                                           */
    else {

        /* find the largest moved point                                    */
        ptPerm4 = CONST_ADDR_PERM4(perm);
        for ( sup = DEG_PERM4(perm); 1 <= sup; sup-- ) {
            if ( ptPerm4[sup-1] != sup-1 )
                break;
        }

    }

    return sup;
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
    while (TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4) {
        perm = ErrorReturnObj(
            "LargestMovedPointPerm: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'");
    }

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
Obj             FuncCYCLE_LENGTH_PERM_INT (
    Obj                 self,
    Obj                 perm,
    Obj                 point )
{
    const UInt2 *       ptPerm2;        /* pointer to the permutation      */
    const UInt4 *       ptPerm4;        /* pointer to the permutation      */
    UInt                deg;            /* degree of the permutation       */
    UInt                pnt;            /* value of the point              */
    UInt                len;            /* length of cycle (result)        */
    UInt                p;              /* loop variable                   */

    /* evaluate and check the arguments                                    */
    while ( TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "CycleLengthPermInt: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'" );
    }
    while ( !IS_INTOBJ(point) || INT_INTOBJ(point) <= 0 ) {
        point = ErrorReturnObj(
         "CycleLengthPermInt: <point> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(point), 0L,
            "you can replace <point> via 'return <point>;'" );
    }

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* get pointer to the permutation, the degree, and the point       */
        ptPerm2 = CONST_ADDR_PERM2(perm);
        deg = DEG_PERM2(perm);
        pnt = INT_INTOBJ(point)-1;

        /* now compute the length by looping over the cycle                */
        len = 1;
        if ( pnt < deg ) {
            for ( p = ptPerm2[pnt]; p != pnt; p = ptPerm2[p] )
                len++;
        }

    }

    /* handle large permutations                                           */
    else {

        /* get pointer to the permutation, the degree, and the point       */
        ptPerm4 = CONST_ADDR_PERM4(perm);
        deg = DEG_PERM4(perm);
        pnt = INT_INTOBJ(point)-1;

        /* now compute the length by looping over the cycle                */
        len = 1;
        if ( pnt < deg ) {
            for ( p = ptPerm4[pnt]; p != pnt; p = ptPerm4[p] )
                len++;
        }

    }

    /* return the length                                                   */
    return INTOBJ_INT(len);
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
Obj             FuncCYCLE_PERM_INT (
    Obj                 self,
    Obj                 perm,
    Obj                 point )
{
    Obj                 list;           /* handle of the list (result)     */
    Obj *               ptList;         /* pointer to the list             */
    const UInt2 *       ptPerm2;        /* pointer to the permutation      */
    const UInt4 *       ptPerm4;        /* pointer to the permutation      */
    UInt                deg;            /* degree of the permutation       */
    UInt                pnt;            /* value of the point              */
    UInt                len;            /* length of the cycle             */
    UInt                p;              /* loop variable                   */

    /* evaluate and check the arguments                                    */
    while ( TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "CyclePermInt: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'" );
    }
    while ( !IS_INTOBJ(point) || INT_INTOBJ(point) <= 0 ) {
        point = ErrorReturnObj(
            "CyclePermInt: <point> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(point), 0L,
            "you can replace <point> via 'return <point>;'" );
    }

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* get pointer to the permutation, the degree, and the point       */
        ptPerm2 = CONST_ADDR_PERM2(perm);
        deg = DEG_PERM2(perm);
        pnt = INT_INTOBJ(point)-1;

        /* now compute the length by looping over the cycle                */
        len = 1;
        if ( pnt < deg ) {
            for ( p = ptPerm2[pnt]; p != pnt; p = ptPerm2[p] )
                len++;
        }

        /* allocate the list                                               */
        list = NEW_PLIST( T_PLIST, len );
        SET_LEN_PLIST( list, len );
        ptList = ADDR_OBJ(list);
        ptPerm2 = CONST_ADDR_PERM2(perm);

        /* copy the points into the list                                   */
        len = 1;
        ptList[len++] = INTOBJ_INT( pnt+1 );
        if ( pnt < deg ) {
            for ( p = ptPerm2[pnt]; p != pnt; p = ptPerm2[p] )
                ptList[len++] = INTOBJ_INT( p+1 );
        }

    }

    /* handle large permutations                                           */
    else {

        /* get pointer to the permutation, the degree, and the point       */
        ptPerm4 = CONST_ADDR_PERM4(perm);
        deg = DEG_PERM4(perm);
        pnt = INT_INTOBJ(point)-1;

        /* now compute the length by looping over the cycle                */
        len = 1;
        if ( pnt < deg ) {
            for ( p = ptPerm4[pnt]; p != pnt; p = ptPerm4[p] )
                len++;
        }

        /* allocate the list                                               */
        list = NEW_PLIST( T_PLIST, len );
        SET_LEN_PLIST( list, len );
        ptList = ADDR_OBJ(list);
        ptPerm4 = CONST_ADDR_PERM4(perm);

        /* copy the points into the list                                   */
        len = 1;
        ptList[len++] = INTOBJ_INT( pnt+1 );
        if ( pnt < deg ) {
            for ( p = ptPerm4[pnt]; p != pnt; p = ptPerm4[p] )
                ptList[len++] = INTOBJ_INT( p+1 );
        }

    }

    /* return the list                                                     */
    return list;
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
**  integer, under the permutation <perm> as a list.
*/
Obj             FuncCYCLE_STRUCT_PERM (
    Obj                 self,
    Obj                 perm )
{
    Obj                 list;           /* handle of the list (result)     */
    Obj *               ptList;         /* pointer to the list             */
    const UInt2 *       ptPerm2;        /* pointer to the permutation      */
    UInt2 * 		scratch2;
    UInt2 *		offset2;
    const UInt4 *       ptPerm4;        /* pointer to the permutation      */
    UInt4 * 		scratch4;
    UInt4 *		offset4;
    UInt                deg;            /* degree of the permutation       */
    UInt                pnt;            /* value of the point              */
    UInt                len;            /* length of the cycle             */
    UInt                p;              /* loop variable                   */
    UInt 		max;		/* maximal cycle length            */
    UInt		cnt;
    UInt		ende;
    UInt		bytes;
    UInt1 *		clr;

    /* evaluate and check the arguments                                    */
    while ( TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "CycleStructPerm: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'" );
    }

    /* make sure that the buffer bag is large enough                       */
    UseTmpPerm(SIZE_OBJ(perm)+8);

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* get pointer to the permutation and the degree       */

        /* find the largest moved point                                    */
        ptPerm2 = CONST_ADDR_PERM2(perm);
        for ( deg = DEG_PERM2(perm); 1 <= deg; deg-- ) {
            if ( ptPerm2[deg-1] != deg-1 )
                break;
        }
	if (deg==0) {
	  /* special treatment of identity */
	  list = NEW_PLIST( T_PLIST, 0 );
	  SET_LEN_PLIST( list, 0 );
	  return list;
	}

        scratch2=ADDR_PERM2(TmpPerm);

	/* the first deg bytes of TmpPerm hold a bit list of points done
	 * so far. The remaining bytes will form the lengths of nontrivial 
	 * cycles (as 2 byte numbers). As every nontrivial cycle requires at
	 * least 2 points, this is guaranteed to fit. */
        bytes=((deg/2)+1)*2; /* ensure 2-byte align */
        offset2=(UInt2*)((UInt)scratch2+(bytes));
	clr=(UInt1*)scratch2;
	/* clear out the bits */
	for (cnt=0;cnt<bytes;cnt++) {
	  clr[cnt]=(UInt1)0;
	}

	cnt=0;
	clr=(UInt1*)scratch2;
	max=0;
	for (pnt=0;pnt<deg;pnt++) {
	  if ( clr[pnt] ==0 ) {
	    len=1;
	    clr[pnt]=1;
	    for ( p = ptPerm2[pnt]; p != pnt; p = ptPerm2[p] ) {
	      clr[p]=1;
	      len++;
	    }
	    /*Pr("pnt:%d, len=%d\n",pnt,len);*/
	    if (len>1) {
	      offset2[cnt]=(UInt2)len;
	      cnt++;
	      if (len>max) { max=len;}
	    }
	  }
	}
       
	ende=cnt;

	/*Pr("max=%d cnt=%d\n",max,cnt);*/
	/* create the list */
	list=NEW_PLIST(T_PLIST,max-1);
	SET_LEN_PLIST(list,max-1);
        ptList = ADDR_OBJ(list);

        /* Recalculate after possible GC */
        scratch2=ADDR_PERM2(TmpPerm);
        offset2=(UInt2*)((UInt)scratch2+(bytes));

	for (pnt=1;pnt<=max-1;pnt++) { ptList[pnt]=0; } /* clean out */

	for (cnt=0; cnt<ende;cnt++) {
	  pnt=(UInt)offset2[cnt];
	  /*Pr("> cnt=%d pnt=%d\n",cnt,pnt);*/
	  pnt--;
	  ptList[pnt]=(Obj)((UInt)ptList[pnt]+1);

	} 

    } 

    /* handle large permutations                                           */
    else {

        /* get pointer to the permutation and the degree       */

        /* find the largest moved point                                    */
        ptPerm4 = ADDR_PERM4(perm);
        for ( deg = DEG_PERM4(perm); 1 <= deg; deg-- ) {
            if ( ptPerm4[deg-1] != deg-1 )
                break;
        }
	if (deg==0) {
	  /* special treatment of identity */
	  list = NEW_PLIST( T_PLIST, 0 );
	  SET_LEN_PLIST( list, 0 );
	  return list;
	}

	/* the first deg bytes of TmpPerm hold a bit list of points done
	 * so far. The remaining bytes will form the lengths of nontrivial 
	 * cycles (as 4 byte numbers). As every nontrivial cycle requires at
	 * least 2 points, this is guaranteed to fit. */
        scratch4=ADDR_PERM4(TmpPerm);
        bytes=((deg/4)+1)*4; /* ensure 4-byte align */
        offset4=(UInt4*)((UInt)scratch4+(bytes));
	clr=(UInt1*)scratch4;
	/* clear out the bits */
	for (cnt=0;cnt<bytes;cnt++) {
	  clr[cnt]=(UInt1)0;
	}

	cnt=0;
	clr=(UInt1*)scratch4;
	max=0;
	for (pnt=0;pnt<deg;pnt++) {
	  if ( clr[pnt] ==0 ) {
	    len=1;
	    clr[pnt]=1;
	    for ( p = ptPerm4[pnt]; p != pnt; p = ptPerm4[p] ) {
	      clr[p]=1;
	      len++;
	    }
	    /*Pr("pnt:%d, len=%d\n",pnt,len);*/
	    if (len>1) {
	      offset4[cnt]=(UInt4)len;
	      cnt++;
	      if (len>max) { max=len;}
	    }
	  }
	}
       
	ende=cnt;

	/*Pr("max=%d cnt=%d\n",max,cnt);*/
	/* create the list */
	list=NEW_PLIST(T_PLIST,max-1);
	SET_LEN_PLIST(list,max-1);
        ptList = ADDR_OBJ(list);

        /* Recalculate after possible GC */
        scratch4=ADDR_PERM4(TmpPerm);
        offset4=(UInt4*)((UInt)scratch4+(bytes));

	for (pnt=1;pnt<max;pnt++) { ptList[pnt]=0; } /* clean out */

	for (cnt=0; cnt<ende;cnt++) {
	  pnt=(UInt)offset4[cnt];
	  /*Pr("> cnt=%d pnt=%d\n",cnt,pnt);*/
	  pnt--;
	  ptList[pnt]=(Obj)((UInt)ptList[pnt]+1);

	} 

    }

    for (pnt=1; pnt<max;pnt++) {
      if (ptList[pnt]!=0) { ptList[pnt]=INTOBJ_INT((UInt)ptList[pnt]);}
    } 

    /* return the list                                                     */
    return list;
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
Obj             FuncORDER_PERM (
    Obj                 self,
    Obj                 perm )
{
    const UInt2 *       ptPerm2;        /* pointer to the permutation      */
    const UInt4 *       ptPerm4;        /* pointer to the permutation      */
    Obj                 ord;            /* order (result), may be huge     */
    UInt2 *             ptKnown2;       /* pointer to temporary bag        */
    UInt4 *             ptKnown4;       /* pointer to temporary bag        */
    UInt                len;            /* length of one cycle             */
    UInt                p, q;           /* loop variables                  */

    /* check arguments and extract permutation                             */
    while ( TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "OrderPerm: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'" );
    }

    /* make sure that the buffer bag is large enough                       */
    UseTmpPerm(SIZE_OBJ(perm));

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* get the pointer to the bags                                     */
        ptPerm2  = CONST_ADDR_PERM2(perm);
        ptKnown2 = ADDR_PERM2(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM2(perm); p++ )
            ptKnown2[p] = 0;

        /* start with order 1                                              */
        ord = INTOBJ_INT(1);

        /* loop over all cycles                                            */
        for ( p = 0; p < DEG_PERM2(perm); p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown2[p] == 0 && ptPerm2[p] != p ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptPerm2[p]; q != p; q = ptPerm2[q] ) {
                    len++;  ptKnown2[q] = 1;
                }

                ord = LcmInt( ord, INTOBJ_INT( len ) );

                // update bag pointers, in case a garbage collection happened
                ptPerm2  = CONST_ADDR_PERM2(perm);
                ptKnown2 = ADDR_PERM2(TmpPerm);

            }

        }

    }

    /* handle larger permutations                                          */
    else {

        /* get the pointer to the bags                                     */
        ptPerm4  = CONST_ADDR_PERM4(perm);
        ptKnown4 = ADDR_PERM4(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM4(perm); p++ )
            ptKnown4[p] = 0;

        /* start with order 1                                              */
        ord = INTOBJ_INT(1);

        /* loop over all cycles                                            */
        for ( p = 0; p < DEG_PERM4(perm); p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown4[p] == 0 && ptPerm4[p] != p ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptPerm4[p]; q != p; q = ptPerm4[q] ) {
                    len++;  ptKnown4[q] = 1;
                }

                ord = LcmInt( ord, INTOBJ_INT( len ) );

                // update bag pointers, in case a garbage collection happened
                ptPerm4  = CONST_ADDR_PERM4(perm);
                ptKnown4 = ADDR_PERM4(TmpPerm);

            }

        }

    }

    /* return the order                                                    */
    return ord;
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
Obj             FuncSIGN_PERM (
    Obj                 self,
    Obj                 perm )
{
    const UInt2 *       ptPerm2;        /* pointer to the permutation      */
    const UInt4 *       ptPerm4;        /* pointer to the permutation      */
    Int                 sign;           /* sign (result)                   */
    UInt2 *             ptKnown2;       /* pointer to temporary bag        */
    UInt4 *             ptKnown4;       /* pointer to temporary bag        */
    UInt                len;            /* length of one cycle             */
    UInt                p,  q;          /* loop variables                  */

    /* check arguments and extract permutation                             */
    while ( TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "SignPerm: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'" );
    }

    /* make sure that the buffer bag is large enough                       */
    UseTmpPerm(SIZE_OBJ(perm));

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* get the pointer to the bags                                     */
        ptPerm2  = CONST_ADDR_PERM2(perm);
        ptKnown2 = ADDR_PERM2(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM2(perm); p++ )
            ptKnown2[p] = 0;

        /* start with sign  1                                              */
        sign = 1;

        /* loop over all cycles                                            */
        for ( p = 0; p < DEG_PERM2(perm); p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown2[p] == 0 && ptPerm2[p] != p ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptPerm2[p]; q != p; q = ptPerm2[q] ) {
                    len++;  ptKnown2[q] = 1;
                }

                /* if the length is even invert the sign                   */
                if ( len % 2 == 0 )
                    sign = -sign;

            }

        }

    }

    /* handle large permutations                                           */
    else {

        /* get the pointer to the bags                                     */
        ptPerm4  = CONST_ADDR_PERM4(perm);
        ptKnown4 = ADDR_PERM4(TmpPerm);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM4(perm); p++ )
            ptKnown4[p] = 0;

        /* start with sign  1                                              */
        sign = 1;

        /* loop over all cycles                                            */
        for ( p = 0; p < DEG_PERM4(perm); p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown4[p] == 0 && ptPerm4[p] != p ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptPerm4[p]; q != p; q = ptPerm4[q] ) {
                    len++;  ptKnown4[q] = 1;
                }

                /* if the length is even invert the sign                   */
                if ( len % 2 == 0 )
                    sign = -sign;

            }

        }

    }

    /* return the sign                                                     */
    return INTOBJ_INT( sign );
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
Obj             FuncSMALLEST_GENERATOR_PERM (
    Obj                 self,
    Obj                 perm )
{
    Obj                 small;          /* handle of the smallest gen      */
    UInt2 *             ptSmall2;       /* pointer to the smallest gen     */
    UInt4 *             ptSmall4;       /* pointer to the smallest gen     */
    const UInt2 *       ptPerm2;        /* pointer to the permutation      */
    const UInt4 *       ptPerm4;        /* pointer to the permutation      */
    UInt2 *             ptKnown2;       /* pointer to temporary bag        */
    UInt4 *             ptKnown4;       /* pointer to temporary bag        */
    Obj                 ord;            /* order, may be huge              */
    Obj                 pow;            /* power, may also be huge         */
    UInt                len;            /* length of one cycle             */
    UInt                gcd,  s,  t;    /* gcd( len, ord ), temporaries    */
    UInt                min;            /* minimal element in a cycle      */
    UInt                p,  q;          /* loop variables                  */
    UInt                l, n, x, gcd2;  /* loop variable                   */

    /* check arguments and extract permutation                             */
    while ( TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "SmallestGeneratorPerm: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'" );
    }

    /* make sure that the buffer bag is large enough                       */
    UseTmpPerm(SIZE_OBJ(perm));

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* allocate the result bag                                         */
        small = NEW_PERM2( DEG_PERM2(perm) );

        /* get the pointer to the bags                                     */
        ptPerm2   = CONST_ADDR_PERM2(perm);
        ptKnown2  = ADDR_PERM2(TmpPerm);
        ptSmall2  = ADDR_PERM2(small);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM2(perm); p++ )
            ptKnown2[p] = 0;

        /* we only know that we must raise <perm> to a power = 0 mod 1     */
        ord = INTOBJ_INT(1);  pow = INTOBJ_INT(0);

        /* loop over all cycles                                            */
        for ( p = 0; p < DEG_PERM2(perm); p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown2[p] == 0 ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptPerm2[p]; q != p; q = ptPerm2[q] ) {
                    len++;  ptKnown2[q] = 1;
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
                min = DEG_PERM2(perm)-1;
                n = 0;
                for ( q = p, l = 0; l < len; l++ ) {
                    gcd2 = len;  s = l;
                    while ( s != 0 ) { t = s; s = gcd2 % s; gcd2 = t; }
                    if ( l % gcd == x && gcd2 == 1 && q <= min ) {
                        min = q;
                        n = l;
                    }
                    q = ptPerm2[q];
                }

                /* raise the cycle to that power and put it in the result  */
                ptSmall2[p] = min;
                for ( q = ptPerm2[p]; q != p; q = ptPerm2[q] ) {
                    min = ptPerm2[min];  ptSmall2[q] = min;
                }

                /* compute the new order and the new power                 */
                while ( INT_INTOBJ( ModInt( pow, INTOBJ_INT(len) ) ) != n )
                    pow = SumInt( pow, ord );
                ord = ProdInt( ord, INTOBJ_INT( len / gcd ) );

            }

        }

    }

    /* handle large permutations                                           */
    else {

        /* allocate the result bag                                         */
        small = NEW_PERM4( DEG_PERM4(perm) );

        /* get the pointer to the bags                                     */
        ptPerm4   = CONST_ADDR_PERM4(perm);
        ptKnown4  = ADDR_PERM4(TmpPerm);
        ptSmall4  = ADDR_PERM4(small);

        /* clear the buffer bag                                            */
        for ( p = 0; p < DEG_PERM4(perm); p++ )
            ptKnown4[p] = 0;

        /* we only know that we must raise <perm> to a power = 0 mod 1     */
        ord = INTOBJ_INT(1);  pow = INTOBJ_INT(0);

        /* loop over all cycles                                            */
        for ( p = 0; p < DEG_PERM4(perm); p++ ) {

            /* if we haven't looked at this cycle so far                   */
            if ( ptKnown4[p] == 0 ) {

                /* find the length of this cycle                           */
                len = 1;
                for ( q = ptPerm4[p]; q != p; q = ptPerm4[q] ) {
                    len++;  ptKnown4[q] = 1;
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
                min = DEG_PERM4(perm)-1;
                n = 0;
                for ( q = p, l = 0; l < len; l++ ) {
                    gcd2 = len;  s = l;
                    while ( s != 0 ) { t = s; s = gcd2 % s; gcd2 = t; }
                    if ( l % gcd == x && gcd2 == 1 && q <= min ) {
                        min = q;
                        n = l;
                    }
                    q = ptPerm4[q];
                }

                /* raise the cycle to that power and put it in the result  */
                ptSmall4[p] = min;
                for ( q = ptPerm4[p]; q != p; q = ptPerm4[q] ) {
                    min = ptPerm4[min];  ptSmall4[q] = min;
                }

                /* compute the new order and the new power                 */
                while ( INT_INTOBJ( ModInt( pow, INTOBJ_INT(len) ) ) != n )
                    pow = SumInt( pow, ord );
                ord = ProdInt( ord, INTOBJ_INT( len / gcd ) );

            }

        }

    }

    /* return the smallest generator                                       */
    return small;
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
Obj             FuncRESTRICTED_PERM (
    Obj                 self,
    Obj                 perm,
    Obj                 dom,
    Obj 		test )
{
    Obj rest;
    UInt2 *            ptRest2;
    const UInt2 *      ptPerm2;
    UInt4 *            ptRest4;
    const UInt4 *      ptPerm4;
    const Obj *        ptDom;
    Int i,inc,len,p,deg;

    /* check arguments and extract permutation                             */
    while ( TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "RestrictedPerm: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'" );
    }

    /* make sure that the buffer bag is large enough */
    UseTmpPerm(SIZE_OBJ(perm));

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

      /* allocate the result bag                                         */
      deg = DEG_PERM2(perm);
      rest = NEW_PERM2(deg);

      /* get the pointer to the bags                                     */
      ptPerm2  = CONST_ADDR_PERM2(perm);
      ptRest2  = ADDR_PERM2(rest);

      /* create identity everywhere */
      for ( p = 0; p < deg; p++ ) {
	  ptRest2[p]=(UInt2)p;
      }

      if ( ! IS_RANGE(dom) ) {
	if ( ! IS_PLIST( dom ) ) {
	  return Fail;
	}
	/* domain is list */
	ptPerm2  = CONST_ADDR_PERM2(perm);
	ptRest2  = ADDR_PERM2(rest);
	ptDom  = CONST_ADDR_OBJ(dom);
	len = LEN_LIST(dom);
	for (i=1;i<=len;i++) {
            if (IS_POS_INTOBJ(ptDom[i])) {
                p = INT_INTOBJ(ptDom[i]);
                if (p <= deg) {
                    p -= 1;
                    ptRest2[p] = ptPerm2[p];
                }
          }
	  else{
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
	  ptRest2[p]=ptPerm2[p];
	  p+=inc;
	}
      }

      if (test==True) {

	UInt2 * ptTmp2  = ADDR_PERM2(TmpPerm);

	/* cleanout */
	for (p=0; p<deg; p++ ) {
	  ptTmp2[p]=0;
	}

        /* check whether the result is a permutation */
	for (p=0;p<deg;p++) {
	  inc=ptRest2[p];
	  if (ptTmp2[inc]==1) return Fail; /* point was known */
	  else ptTmp2[inc]=1; /* now point is known */
	}

      }

    }
    else {
      /* allocate the result bag                                         */
      deg = DEG_PERM4(perm);
      rest = NEW_PERM4(deg);

      /* get the pointer to the bags                                     */
      ptPerm4  = ADDR_PERM4(perm);
      ptRest4  = ADDR_PERM4(rest);

      /* create identity everywhere */
      for ( p = 0; p < deg; p++ ) {
	  ptRest4[p]=(UInt4)p;
      }

      if ( ! IS_RANGE(dom) ) {
	if ( ! IS_PLIST( dom ) ) {
	  return Fail;
	}
	/* domain is list */
	ptPerm4  = ADDR_PERM4(perm);
	ptRest4  = ADDR_PERM4(rest);
	ptDom  = ADDR_OBJ(dom);
	len = LEN_LIST(dom);
        for (i = 1; i <= len; i++) {
            if (IS_POS_INTOBJ(ptDom[i])) {
                p = INT_INTOBJ(ptDom[i]);
                if (p <= deg) {
                    p -= 1;
                    ptRest4[p] = ptPerm4[p];
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
	  ptRest4[p]=ptPerm4[p];
	  p+=inc;
	}
      }

      if (test==True) {

	UInt4 * ptTmp4  = ADDR_PERM4(TmpPerm);

	/* cleanout */
	for ( p = 0; p < deg; p++ ) {
	  ptTmp4[p]=0;
	}

        /* check whether the result is a permutation */
	for (p=0;p<deg;p++) {
	  inc=ptRest4[p];
	  if (ptTmp4[inc]==1) return Fail; /* point was known */
	  else ptTmp4[inc]=1; /* now point is known */
	}

      }
    }

    /* return the restriction */
    return rest;
}

/****************************************************************************
**
*F  FuncTRIM_PERM( <self>, <perm>, <n> ) . . . . . . . . . trim a permutation
**
**  'TRIM_PERM' trims a permutation to the first <n> points. This can be
##  useful to save memory
*/
Obj             FuncTRIM_PERM (
    Obj			self,
    Obj                 perm,
    Obj                 n )
{
    UInt	deg,rdeg,i;
    UInt4*	addr;

    /* check arguments and extract permutation */
    while ( TNUM_OBJ(perm) != T_PERM2 && TNUM_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "TRIM_PERM: <perm> must be a permutation (not a %s)",
            (Int)TNAM_OBJ(perm), 0L,
            "you can replace <perm> via 'return <perm>;'" );
    }

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
Obj FuncSPLIT_PARTITION(
    Obj self,
    Obj Ppoints,
    Obj Qnum,
    Obj jval,
    Obj g,
    Obj lst)
{
  Int a;
  Int b;
  Int cnt;
  Int max;
  Int blim;
  UInt deg;
  const UInt2 * gpt; /* perm pointer for 2 and 4 bytes */
  const UInt4 * gpf;
  Obj tmp;


  a=INT_INTOBJ(ELM_PLIST(lst,1))-1;
  b=INT_INTOBJ(ELM_PLIST(lst,2))+1;
  max=INT_INTOBJ(ELM_PLIST(lst,3));
  cnt=0;
  blim=b-max-1;

  if (TNUM_OBJ(g)==T_PERM2) {
    deg=DEG_PERM2(g);
    gpt=CONST_ADDR_PERM2(g);
    while ( (a<b)) {
      do {
	b--;
	if (b<blim) {
	  /* too many points got moved out */
	  return INTOBJ_INT(-1);
	}
      } while (ELM_PLIST(Qnum,
	      IMAGETWO(INT_INTOBJ(ELM_PLIST(Ppoints,b))-1,gpt,deg)+1)==jval);
      do {
	a++;
      } while ((a<b)
	      &&(!(ELM_PLIST(Qnum,
	      IMAGETWO(INT_INTOBJ(ELM_PLIST(Ppoints,a))-1,gpt,deg)+1)==jval)));
      /* swap */
      if (a<b) {
	tmp=ELM_PLIST(Ppoints,a);
	SET_ELM_PLIST(Ppoints,a,ELM_PLIST(Ppoints,b));
	SET_ELM_PLIST(Ppoints,b,tmp);
	cnt++;
      }
    }
  }
  else {
    deg=DEG_PERM4(g);
    gpf=CONST_ADDR_PERM4(g);
    while ( (a<b)) {
      do {
	b--;
	if (b<blim) {
	  /* too many points got moved out */
	  return INTOBJ_INT(-1);
	}
      } while (ELM_PLIST(Qnum,
		  IMAGE(INT_INTOBJ(ELM_PLIST(Ppoints,b))-1,gpf,deg)+1)==jval);
      do {
	a++;
      } while ((a<b)
	      &&(!(ELM_PLIST(Qnum,
		  IMAGE(INT_INTOBJ(ELM_PLIST(Ppoints,a))-1,gpf,deg)+1)==jval)));
      /* swap */
      if (a<b) {
	tmp=ELM_PLIST(Ppoints,a);
	SET_ELM_PLIST(Ppoints,a,ELM_PLIST(Ppoints,b));
	SET_ELM_PLIST(Ppoints,b,tmp);
	cnt++;
      }
    }
  }
  /* list is not necc. sorted wrt. \< (any longer) */
  RESET_FILT_LIST(Ppoints, FN_IS_SSORT);
  RESET_FILT_LIST(Ppoints, FN_IS_NSORT);

  return INTOBJ_INT(b+1);
}

/*****************************************************************************
**
*F  FuncDISTANCE_PERMS( <perm1>, <perm2> )
**
**  'DistancePerms' returns the number of points moved by <perm1>/<perm2>
**
*/

Obj FuncDISTANCE_PERMS( Obj self, Obj p1, Obj p2)
{
  UInt dist = 0;
  if (TNUM_OBJ(p1) == T_PERM2 && TNUM_OBJ(p2) == T_PERM2) {
    const UInt2 *pt1 = CONST_ADDR_PERM2(p1);
    const UInt2 *pt2 = CONST_ADDR_PERM2(p2);
    UInt l1 = DEG_PERM2(p1);
    UInt l2 = DEG_PERM2(p2);
    UInt lmin = (l1 < l2) ? l1 : l2;
    UInt i;
    for (i = 0; i < lmin; i++)
      if (pt1[i] != pt2[i])
	dist++;
    for (; i < l1; i++)
      if (pt1[i] != i)
	dist++;
    for (; i < l2; i++)
      if (pt2[i] != i)
	dist++;
  } else {
    if (TNUM_OBJ(p1) == T_PERM2 && TNUM_OBJ(p2) == T_PERM4) {
      Obj temp = p1;
      p1 = p2;
      p2 = temp;
    }
    if (TNUM_OBJ(p1) == T_PERM4 && TNUM_OBJ(p2) == T_PERM2) {
      const UInt4 *pt1 = CONST_ADDR_PERM4(p1);
      const UInt2 *pt2 = CONST_ADDR_PERM2(p2);
      UInt l1 = DEG_PERM4(p1);
      UInt l2 = DEG_PERM2(p2);
      UInt lmin = (l1 < l2) ? l1 : l2;
      UInt i;
      for (i = 0; i < lmin; i++)
	if (pt1[i] != pt2[i])
	  dist++;
      for (; i < l1; i++)
	if (pt1[i] != i)
	  dist++;
      for (; i < l2; i++)
	if (pt2[i] != i)
	  dist++;
    } else {
      const UInt4 *pt1 = CONST_ADDR_PERM4(p1);
      const UInt4 *pt2 = CONST_ADDR_PERM4(p2);
      UInt l1 = DEG_PERM4(p1);
      UInt l2 = DEG_PERM4(p2);
      UInt lmin = (l1 < l2) ? l1 : l2;
      UInt i;
      for (i = 0; i < lmin; i++)
	if (pt1[i] != pt2[i])
	  dist++;
      for (; i < l1; i++)
	if (pt1[i] != i)
	  dist++;
      for (; i < l2; i++)
	if (pt2[i] != i)
	  dist++;
    }
  }
  return INTOBJ_INT(dist);
}

/****************************************************************************
**
*F  FuncSMALLEST_IMG_TUP_PERM( <tup>, <perm> )
**
**  `SmallestImgTuplePerm' returns the smallest image of the  tuple  <tup>
**  under  the permutation <perm>.
*/
Obj             FuncSMALLEST_IMG_TUP_PERM (
    Obj			self,
    Obj                 tup,
    Obj                 perm )
{
    UInt                res;            /* handle of the image, result     */
    const Obj *         ptTup;          /* pointer to the tuple            */
    const UInt2 *       ptPrm2;         /* pointer to the permutation      */
    const UInt4 *       ptPrm4;         /* pointer to the permutation      */
    UInt                tmp;            /* temporary handle                */
    UInt                lmp;            /* largest moved point             */
    UInt                i, k;           /* loop variables                  */

    res = MAX_DEG_PERM4; /* ``infty''. */
    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* get the pointer                                                 */
        ptTup = CONST_ADDR_OBJ(tup) + LEN_LIST(tup);
        ptPrm2 = CONST_ADDR_PERM2(perm);
        lmp = DEG_PERM2(perm);

        /* loop over the entries of the tuple                              */
        for ( i = LEN_LIST(tup); 1 <= i; i--, ptTup-- ) {
	  k = INT_INTOBJ( *ptTup );
	  if ( k <= lmp )
	      tmp = ptPrm2[k-1] + 1;
	  else
	      tmp = k ;
	  if (tmp<res) res = tmp;
        }

    }

    /* handle large permutations                                           */
    else {

        /* get the pointer                                                 */
        ptTup = CONST_ADDR_OBJ(tup) + LEN_LIST(tup);
        ptPrm4 = CONST_ADDR_PERM4(perm);
        lmp = DEG_PERM4(perm);

        /* loop over the entries of the tuple                              */
        for ( i = LEN_LIST(tup); 1 <= i; i--, ptTup-- ) {
	  k = INT_INTOBJ( *ptTup );
	  if ( k <= lmp )
	      tmp = ptPrm4[k-1] + 1;
	  else
	      tmp = k;
	  if (tmp<res) res = tmp;
        }

    }

    /* return the result                                                   */
    return INTOBJ_INT(res);
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
Obj             OnTuplesPerm (
    Obj                 tup,
    Obj                 perm )
{
    Obj                 res;            /* handle of the image, result     */
    Obj *               ptRes;          /* pointer to the result           */
    const Obj *         ptTup;          /* pointer to the tuple            */
    const UInt2 *       ptPrm2;         /* pointer to the permutation      */
    const UInt4 *       ptPrm4;         /* pointer to the permutation      */
    Obj                 tmp;            /* temporary handle                */
    UInt                lmp;            /* largest moved point             */
    UInt                i, k;           /* loop variables                  */

    GAP_ASSERT(IS_PLIST(tup));
    GAP_ASSERT(LEN_PLIST(tup) > 0);

    const UInt len = LEN_PLIST(tup);

    /* make a bag for the result and initialize pointers                   */
    res = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_PLIST(tup), T_PLIST, len);
    SET_LEN_PLIST(res, len);

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* get the pointer                                                 */
        ptTup = CONST_ADDR_OBJ(tup) + len;
        ptRes = ADDR_OBJ(res) + len;
        ptPrm2 = CONST_ADDR_PERM2(perm);
        lmp = DEG_PERM2(perm);

        /* loop over the entries of the tuple                              */
        for ( i = len; 1 <= i; i--, ptTup--, ptRes-- ) {
            if (IS_INTOBJ(*ptTup) && (0 < INT_INTOBJ(*ptTup))) {
                k = INT_INTOBJ( *ptTup );
                if (k > lmp) {
                    tmp = *ptTup;
                } else
                    tmp = INTOBJ_INT( ptPrm2[k-1] + 1 );
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
                ptPrm2 = CONST_ADDR_PERM2(perm);
                *ptRes = tmp;
                CHANGED_BAG( res );
            }
        }

    }

    /* handle large permutations                                           */
    else {

        /* get the pointer                                                 */
        ptTup = CONST_ADDR_OBJ(tup) + len;
        ptRes = ADDR_OBJ(res) + len;
        ptPrm4 = CONST_ADDR_PERM4(perm);
        lmp = DEG_PERM4(perm);

        /* loop over the entries of the tuple                              */
        for ( i = len; 1 <= i; i--, ptTup--, ptRes-- ) {
            if (IS_INTOBJ(*ptTup) && (0 < INT_INTOBJ(*ptTup))) {
                k = INT_INTOBJ( *ptTup );
                if (k > lmp) {
                    tmp = *ptTup;
                } else
                    tmp = INTOBJ_INT( ptPrm4[k-1] + 1 );
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
                ptPrm4 = CONST_ADDR_PERM4(perm);
                *ptRes = tmp;
                CHANGED_BAG( res );
            }
        }

    }

    /* return the result                                                   */
    return res;
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
Obj             OnSetsPerm (
    Obj                 set,
    Obj                 perm )
{
    Obj                 res;            /* handle of the image, result     */
    Obj *               ptRes;          /* pointer to the result           */
    const Obj *         ptTup;          /* pointer to the tuple            */
    const UInt2 *       ptPrm2;         /* pointer to the permutation      */
    const UInt4 *       ptPrm4;         /* pointer to the permutation      */
    Obj                 tmp;            /* temporary handle                */
    UInt                lmp;            /* largest moved point             */
    UInt                isint;          /* <set> only holds integers       */
    UInt                i, k;           /* loop variables                  */

    GAP_ASSERT(IS_PLIST(set));
    GAP_ASSERT(LEN_PLIST(set) > 0);

    const UInt len = LEN_PLIST(set);

    /* make a bag for the result and initialize pointers                   */
    res = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_PLIST(set), T_PLIST, len);
    SET_LEN_PLIST(res, len);

    /* handle small permutations                                           */
    if ( TNUM_OBJ(perm) == T_PERM2 ) {

        /* get the pointer                                                 */
        ptTup = CONST_ADDR_OBJ(set) + len;
        ptRes = ADDR_OBJ(res) + len;
        ptPrm2 = CONST_ADDR_PERM2(perm);
        lmp = DEG_PERM2(perm);

        /* loop over the entries of the tuple                              */
        isint = 1;
        for ( i = len; 1 <= i; i--, ptTup--, ptRes-- ) {
            if ( IS_INTOBJ( *ptTup ) && 0 < INT_INTOBJ( *ptTup ) ) {
                k = INT_INTOBJ( *ptTup );
                if ( k <= lmp )
                    tmp = INTOBJ_INT( ptPrm2[k-1] + 1 );
                else
                    tmp = INTOBJ_INT( k );
                *ptRes = tmp;
            }
            else {
                isint = 0;
                tmp = POW( *ptTup, perm );
                ptTup = CONST_ADDR_OBJ(set) + i;
                ptRes = ADDR_OBJ(res) + i;
                ptPrm2 = CONST_ADDR_PERM2(perm);
                *ptRes = tmp;
                CHANGED_BAG( res );
            }
        }

    }

    /* handle large permutations                                           */
    else {

        /* get the pointer                                                 */
        ptTup = CONST_ADDR_OBJ(set) + len;
        ptRes = ADDR_OBJ(res) + len;
        ptPrm4 = CONST_ADDR_PERM4(perm);
        lmp = DEG_PERM4(perm);

        /* loop over the entries of the tuple                              */
        isint = 1;
        for ( i = len; 1 <= i; i--, ptTup--, ptRes-- ) {
            if ( IS_INTOBJ( *ptTup ) && 0 < INT_INTOBJ( *ptTup ) ) {
                k = INT_INTOBJ( *ptTup );
                if ( k <= lmp )
                    tmp = INTOBJ_INT( ptPrm4[k-1] + 1 );
                else
                    tmp = INTOBJ_INT( k );
                *ptRes = tmp;
            }
            else {
                isint = 0;
                tmp = POW( *ptTup, perm );
                ptTup = CONST_ADDR_OBJ(set) + i;
                ptRes = ADDR_OBJ(res) + i;
                ptPrm4 = CONST_ADDR_PERM4(perm);
                *ptRes = tmp;
                CHANGED_BAG( res );
            }
        }

    }

    // sort the result
    if (isint) {
        SortPlistByRawObj(res);
        RetypeBag(res, IS_MUTABLE_PLIST(set) ? T_PLIST_CYC_SSORT
                                             : T_PLIST_CYC_SSORT + IMMUTABLE);
    }
    else {
        SortDensePlist(res);
    }

    /* return the result                                                   */
    return res;
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
        while ( ! IS_SMALL_LIST(cycle) ) {
            cycle = ErrorReturnObj(
                "Array2Perm: <cycle> must be a small list (not a %s)",
                (Int)TNAM_OBJ(cycle), 0L,
                "you can replace <cycle> via 'return <cycle>;'" );
        }

        /* loop over the entries of the cycle                              */
        c = p = l = 0;
        for ( j = LEN_LIST(cycle); 1 <= j; j-- ) {

            /* get and check current entry for the cycle                   */
            val = ELM_LIST( cycle, j );
            while ( ! IS_INTOBJ(val) || INT_INTOBJ(val) <= 0 ) {
                val = ErrorReturnObj(
              "Permutation: <expr> must be a positive integer (not to a %s)",
                    (Int)TNAM_OBJ(val), 0L,
                    "you can replace <expr> via 'return <expr>;'" );
            }
            c = INT_INTOBJ(val);
	    if (c > MAX_DEG_PERM4)
	      ErrorMayQuit( "Permutation literal exceeds maximum permutatuion degree -- %i vs %i",
			    c, MAX_DEG_PERM4);

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
                return ErrorReturnObj(
                    "Permutation: cycles must be disjoint",
                    0L, 0L,
                    "you can replace the permutation <perm> via 'return <perm>;'" );
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

static inline Int myquo( Obj pt, Obj perm) {
  if (TNUM_OBJ(perm) == T_PERM2)
    return INT_INTOBJ(QuoIntPerm2(pt, perm));
  else if (TNUM_OBJ(perm) == T_PERM4)
    return INT_INTOBJ(QuoIntPerm4(pt, perm));
  else
    return INT_INTOBJ(QUO(pt,perm ));
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
        SET_LEN_PLIST(tabsrc,0);
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
        SET_LEN_PLIST(tabdst,0);
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
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

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
    /* install the marking function                                        */
    InfoBags[           T_PERM2         ].name = "permutation (small)";
    InitMarkFuncBags(T_PERM2, MarkOneSubBags);
    InfoBags[           T_PERM4         ].name = "permutation (large)";
    InitMarkFuncBags(T_PERM4, MarkOneSubBags);

    MakeBagTypePublic( T_PERM2);
    MakeBagTypePublic( T_PERM4);

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
    InitGlobalBag( &TmpPerm, "src/permutat.c:TmpPerm" );
#endif

    /* make the identity permutation                                       */
    InitGlobalBag( &IdentityPerm, "src/permutat.c:IdentityPerm" );

    /* install the saving functions */
    SaveObjFuncs[ T_PERM2 ] = SavePerm2;
    SaveObjFuncs[ T_PERM4 ] = SavePerm4;
    LoadObjFuncs[ T_PERM2 ] = LoadPerm2;
    LoadObjFuncs[ T_PERM4 ] = LoadPerm4;

    /* install the printing functions                                      */
    PrintObjFuncs[ T_PERM2   ] = PrintPerm2;
    PrintObjFuncs[ T_PERM4   ] = PrintPerm4;

    /* install the comparison methods                                      */
    EqFuncs  [ T_PERM2  ][ T_PERM2  ] = EqPerm22;
    EqFuncs  [ T_PERM2  ][ T_PERM4  ] = EqPerm24;
    EqFuncs  [ T_PERM4  ][ T_PERM2  ] = EqPerm42;
    EqFuncs  [ T_PERM4  ][ T_PERM4  ] = EqPerm44;
    LtFuncs  [ T_PERM2  ][ T_PERM2  ] = LtPerm22;
    LtFuncs  [ T_PERM2  ][ T_PERM4  ] = LtPerm24;
    LtFuncs  [ T_PERM4  ][ T_PERM2  ] = LtPerm42;
    LtFuncs  [ T_PERM4  ][ T_PERM4  ] = LtPerm44;

    /* install the binary operations                                       */
    ProdFuncs[ T_PERM2  ][ T_PERM2  ] = ProdPerm22;
    ProdFuncs[ T_PERM2  ][ T_PERM4  ] = ProdPerm24;
    ProdFuncs[ T_PERM4  ][ T_PERM2  ] = ProdPerm42;
    ProdFuncs[ T_PERM4  ][ T_PERM4  ] = ProdPerm44;
    QuoFuncs[T_PERM2][T_PERM2] = QuoPerm;
    QuoFuncs[T_PERM2][T_PERM4] = QuoPerm;
    QuoFuncs[T_PERM4][T_PERM2] = QuoPerm;
    QuoFuncs[T_PERM4][T_PERM4] = QuoPerm;
    LQuoFuncs[ T_PERM2  ][ T_PERM2  ] = LQuoPerm22;
    LQuoFuncs[ T_PERM2  ][ T_PERM4  ] = LQuoPerm24;
    LQuoFuncs[ T_PERM4  ][ T_PERM2  ] = LQuoPerm42;
    LQuoFuncs[ T_PERM4  ][ T_PERM4  ] = LQuoPerm44;
    PowFuncs [ T_PERM2  ][ T_INT    ] = PowPerm2Int;
    PowFuncs [ T_PERM2  ][ T_INTPOS ] = PowPerm2Int;
    PowFuncs [ T_PERM2  ][ T_INTNEG ] = PowPerm2Int;
    PowFuncs [ T_PERM4  ][ T_INT    ] = PowPerm4Int;
    PowFuncs [ T_PERM4  ][ T_INTPOS ] = PowPerm4Int;
    PowFuncs [ T_PERM4  ][ T_INTNEG ] = PowPerm4Int;
    PowFuncs [ T_INT    ][ T_PERM2  ] = PowIntPerm2;
    PowFuncs [ T_INTPOS ][ T_PERM2  ] = PowIntPerm2;
    PowFuncs [ T_INT    ][ T_PERM4  ] = PowIntPerm4;
    PowFuncs [ T_INTPOS ][ T_PERM4  ] = PowIntPerm4;
    QuoFuncs [ T_INT    ][ T_PERM2  ] = QuoIntPerm2;
    QuoFuncs [ T_INTPOS ][ T_PERM2  ] = QuoIntPerm2;
    QuoFuncs [ T_INT    ][ T_PERM4  ] = QuoIntPerm4;
    QuoFuncs [ T_INTPOS ][ T_PERM4  ] = QuoIntPerm4;
    PowFuncs [ T_PERM2  ][ T_PERM2  ] = PowPerm22;
    PowFuncs [ T_PERM2  ][ T_PERM4  ] = PowPerm24;
    PowFuncs [ T_PERM4  ][ T_PERM2  ] = PowPerm42;
    PowFuncs [ T_PERM4  ][ T_PERM4  ] = PowPerm44;
    CommFuncs[ T_PERM2  ][ T_PERM2  ] = CommPerm22;
    CommFuncs[ T_PERM2  ][ T_PERM4  ] = CommPerm24;
    CommFuncs[ T_PERM4  ][ T_PERM2  ] = CommPerm42;
    CommFuncs[ T_PERM4  ][ T_PERM4  ] = CommPerm44;

    /* install the 'ONE' function for permutations                         */
    OneFuncs[ T_PERM2 ] = OnePerm;
    OneFuncs[ T_PERM4 ] = OnePerm;
    OneMutFuncs[ T_PERM2 ] = OnePerm;
    OneMutFuncs[ T_PERM4 ] = OnePerm;

    /* install the 'INV' function for permutations                         */
    InvFuncs[ T_PERM2 ] = InvPerm;
    InvFuncs[ T_PERM4 ] = InvPerm;
    InvMutFuncs[ T_PERM2 ] = InvPerm;
    InvMutFuncs[ T_PERM4 ] = InvPerm;

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


static void InitModuleState(ModuleStateOffset offset)
{
    /* make the buffer bag                                                 */
    TmpPerm = 0;
}


/****************************************************************************
**
*F  InitInfoPermutat()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "permutat",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoPermutat ( void )
{
    PermutatStateOffset = RegisterModuleState(sizeof(PermutatModuleState), InitModuleState, 0);
    return &module;
}
