/****************************************************************************
**
*W  permutat.c                  GAP source                   Martin Schoenert
**                                                           & Alice Niemeyer
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions for permutations (small and large).
**
**  Mathematically a permutation is a bijective mapping  of a finite set onto
**  itself.  In \GAP\ this subset must always be of the form [ 1, 2, .., N ],
**  where N is at most $2^16$.
**
**  Internally a permutation  is viewed as a mapping  of [ 0,  1,  .., N-1 ],
**  because in C indexing of  arrays is done  with the origin  0 instad of 1.
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
char *          Revision_permutat_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */
#include        "scanner.h"             /* Pr                              */
#include        "gasman.h"              /* NewBag, CHANGED_BAG             */

#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* Function                        */
#include        "opers.h"               /* NewFilterC                      */

#include        "ariths.h"              /* generic operations package      */
#include        "lists.h"               /* generic lists package           */

#include        "bool.h"                /* True, False                     */

#include        "integer.h"             /* SumInt, DiffInt, ProdInt, Quo...*/

#define INCLUDE_DECLARATION_PART
#include        "permutat.h"            /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "plist.h"               /* plain lists                     */

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*F  NEW_PERM2(<deg>)  . . . . . . . . . . . .  make a new (small) permutation
*F  DEG_PERM2(<perm>) . . . . . . . . . . . . . degree of (small) permutation
*F  ADDR_PERM2(<perm>)  . . . . . . . absolute address of (small) permutation
*F  NEW_PERM4(<deg>)  . . . . . . . . . . . .  make a new (large) permutation
*F  DEG_PERM4(<perm>) . . . . . . . . . . . . . degree of (large) permutation
*F  ADDR_PERM4(<perm>)  . . . . . . . absolute address of (large) permutation
**
**  'NEW_PERM2', 'DEG_PERM2',  'ADDR_PERM2',   'NEW_PERM4', 'DEG_PERM4',  and
**  'ADDR_PERM4'  are defined in  the declaration  part   of this package  as
**  follows
**
#define NEW_PERM2(deg)          NewBag( T_PERM2, (deg) * sizeof(UInt2))
#define DEG_PERM2(perm)         (SIZE_OBJ(perm) / sizeof(UInt2))
#define ADDR_PERM2(perm)        ((UInt2*)ADDR_OBJ(perm))
#define NEW_PERM4(deg)          NewBag( T_PERM4, (deg) * sizeof(UInt4))
#define DEG_PERM4(perm)         (SIZE_OBJ(perm) / sizeof(UInt4))
#define ADDR_PERM4(perm)        ((UInt4*)ADDR_OBJ(perm))
*/


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


/****************************************************************************
**
*V  TmpPerm . . . . . . . handle of the buffer bag of the permutation package
**
**  'TmpPerm' is the handle  of a bag of type  'T_PERM4', which is created at
**  initialization time  of this package.  Functions  in this package can use
**  this bag for  whatever  purpose they want.  They   have to make sure   of
**  course that it is large enough.
*/
Obj                     TmpPerm;


/****************************************************************************
**
*F  KindPerm( <perm> )  . . . . . . . . . . . . . . . . kind of a permutation
**
**  'KindPerm' returns the kind of permutations.
**
**  'KindPerm' is the function in 'KindObjFuncs' for permutations.
*/
Obj             KIND_PERM2;

Obj             KIND_PERM4;

Obj             KindPerm2 (
    Obj                 perm )
{
    return KIND_PERM2;
}

Obj             KindPerm4 (
    Obj                 perm )
{
    return KIND_PERM4;
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
**  This is done, because it is forbidden to create new bags during printing.
*/
void            PrintPermP (
    Obj                 perm )
{
    UInt                degPerm;        /* degree of the permutation       */
    UInt2 *             ptPerm;         /* pointer to the permutation      */
    UInt                p,  q;          /* loop variables                  */
    UInt                isId;           /* permutation is the identity?    */
    char *              fmt1;           /* common formats to print points  */
    char *              fmt2;           /* common formats to print points  */

    /* set up the formats used, so all points are printed with equal width */
    degPerm = DEG_PERM2(perm);
    if      ( degPerm <    10 ) { fmt1 = "%>(%>%1d%<"; fmt2 = ",%>%1d%<"; }
    else if ( degPerm <   100 ) { fmt1 = "%>(%>%2d%<"; fmt2 = ",%>%2d%<"; }
    else if ( degPerm <  1000 ) { fmt1 = "%>(%>%3d%<"; fmt2 = ",%>%3d%<"; }
    else if ( degPerm < 10000 ) { fmt1 = "%>(%>%4d%<"; fmt2 = ",%>%4d%<"; }
    else                        { fmt1 = "%>(%>%5d%<"; fmt2 = ",%>%5d%<"; }

    /* run through all points                                              */
    isId = 1;
    ptPerm = ADDR_PERM2(perm);
    for ( p = 0; p < degPerm; p++ ) {

        /* find the smallest element in this cycle                         */
        q = ptPerm[p];
        while ( p < q )  q = ptPerm[q];

        /* if the smallest is the one we started with lets print the cycle */
        if ( p == q && ptPerm[p] != p ) {
            isId = 0;
            Pr(fmt1,(Int)(p+1),0L);
            for ( q = ptPerm[p]; q != p; q = ptPerm[q] )
                Pr(fmt2,(Int)(q+1),0L);
            Pr("%<)",0L,0L);
        }

    }

    /* special case for the identity                                       */
    if ( isId )  Pr("()",0L,0L);
}

void            PrintPermQ (
    Obj                 perm )
{
    UInt                degPerm;        /* degree of the permutation       */
    UInt4 *             ptPerm;         /* pointer to the permutation      */
    UInt                p,  q;          /* loop variables                  */
    UInt                isId;           /* permutation is the identity?    */
    char *              fmt1;           /* common formats to print points  */
    char *              fmt2;           /* common formats to print points  */

    /* set up the formats used, so all points are printed with equal width */
    degPerm = DEG_PERM4(perm);
    if      ( degPerm <    10 ) { fmt1 = "%>(%>%1d%<"; fmt2 = ",%>%1d%<"; }
    else if ( degPerm <   100 ) { fmt1 = "%>(%>%2d%<"; fmt2 = ",%>%2d%<"; }
    else if ( degPerm <  1000 ) { fmt1 = "%>(%>%3d%<"; fmt2 = ",%>%3d%<"; }
    else if ( degPerm < 10000 ) { fmt1 = "%>(%>%4d%<"; fmt2 = ",%>%4d%<"; }
    else                        { fmt1 = "%>(%>%5d%<"; fmt2 = ",%>%5d%<"; }

    /* run through all points                                              */
    isId = 1;
    ptPerm = ADDR_PERM4(perm);
    for ( p = 0; p < degPerm; p++ ) {

        /* find the smallest element in this cycle                         */
        q = ptPerm[p];
        while ( p < q )  q = ptPerm[q];

        /* if the smallest is the one we started with lets print the cycle */
        if ( p == q && ptPerm[p] != p ) {
            isId = 0;
            Pr(fmt1,(Int)(p+1),0L);
            for ( q = ptPerm[p]; q != p; q = ptPerm[q] )
                Pr(fmt2,(Int)(q+1),0L);
            Pr("%<)",0L,0L);
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
*/
Int             EqPerm22 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees                                                     */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM2(opR);

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

Int             EqPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees                                                     */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM4(opR);

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

Int             EqPerm42 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees                                                     */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM2(opR);

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

Int             EqPerm44 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees                                                     */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM4(opR);

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
Int             LtPerm22 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM2(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) )
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) )
                if (        p < *(--ptR) )  return 1L ;
                else                        return 0L;
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) )
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) != p )
                if ( *(--ptL) <        p )  return 1L ;
                else                        return 0L;
    }

    /* otherwise they must be equal                                        */
    return 0L;
}

Int             LtPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM4(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) )
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) )
                if (        p < *(--ptR) )  return 1L ;
                else                        return 0L;
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) )
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) != p )
                if ( *(--ptL) <        p )  return 1L ;
                else                        return 0L;
    }

    /* otherwise they must be equal                                        */
    return 0L;
}

Int             LtPerm42 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM2(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) )
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) )
                if (        p < *(--ptR) )  return 1L ;
                else                        return 0L;
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) )
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) != p )
                if ( *(--ptL) <        p )  return 1L ;
                else                        return 0L;
    }

    /* otherwise they must be equal                                        */
    return 0L;
}

Int             LtPerm44 (
    Obj                 opL,
    Obj                 opR )
{
    UInt                degL;           /* degree of the left operand      */
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* get the degrees of the permutations                                 */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM4(opR);

    /* search for a difference and return if you find one                  */
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            if ( *(ptL++) != *(ptR++) )
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
        for ( p = degL; p < degR; p++ )
            if (        p != *(ptR++) )
                if (        p < *(--ptR) )  return 1L ;
                else                        return 0L;
    }
    else {
        for ( p = 0; p < degR; p++ )
            if ( *(ptL++) != *(ptR++) )
                if ( *(--ptL) < *(--ptR) )  return 1L ;
                else                        return 0L;
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) != p )
                if ( *(--ptL) <        p )  return 1L ;
                else                        return 0L;
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
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM2( degP );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM2(opR);
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
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM4( degP );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM4(opR);
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
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM4( degP );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM2(opR);
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
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degP = degL < degR ? degR : degL;
    prd  = NEW_PERM4( degP );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM4(opR);
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
Obj             QuoPerm22 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 quo;            /* handle of the quotient (result) */
    UInt                degQ;           /* degree of the quotient          */
    UInt2 *             ptQ;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt2 *             ptI;            /* pointer to the inverse          */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degQ = degL < degR ? degR : degL;
    quo  = NEW_PERM2( degQ );

    /* make sure that the buffer bag is large enough to hold the inverse   */
    if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opR) ) {
        ResizeBag( TmpPerm, SIZE_OBJ(opR) );
    }

    /* invert the right permutation into the buffer bag                    */
    ptI = ADDR_PERM2(TmpPerm);
    ptR = ADDR_PERM2(opR);
    for ( p = 0; p < degR; p++ )
        ptI[ *ptR++ ] = p;

    /* multiply the left permutation with the inverse                      */
    ptL = ADDR_PERM2(opL);
    ptI = ADDR_PERM2(TmpPerm);
    ptQ = ADDR_PERM2(quo);
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            *(ptQ++) = ptI[ *(ptL++) ];
        for ( p = degL; p < degR; p++ )
            *(ptQ++) = ptI[ p ];
    }
    else {
        for ( p = 0; p < degL; p++ )

            *(ptQ++) = IMAGE( ptL[ p ], ptI, degR );
    }

    /* make the buffer bag clean again                                     */
    ptI = ADDR_PERM2(TmpPerm);
    for ( p = 0; p < degR; p++ )
        ptI[ p ] = 0;

    /* return the result                                                   */
    return quo;
}

Obj             QuoPerm24 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 quo;            /* handle of the quotient (result) */
    UInt                degQ;           /* degree of the quotient          */
    UInt4 *             ptQ;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt4 *             ptI;            /* pointer to the inverse          */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degQ = degL < degR ? degR : degL;
    quo  = NEW_PERM4( degQ );

    /* make sure that the buffer bag is large enough to hold the inverse   */
    if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opR) ) {
        ResizeBag( TmpPerm, SIZE_OBJ(opR) );
    }

    /* invert the right permutation into the buffer bag                    */
    ptI = ADDR_PERM4(TmpPerm);
    ptR = ADDR_PERM4(opR);
    for ( p = 0; p < degR; p++ )
        ptI[ *ptR++ ] = p;

    /* multiply the left permutation with the inverse                      */
    ptL = ADDR_PERM2(opL);
    ptI = ADDR_PERM4(TmpPerm);
    ptQ = ADDR_PERM4(quo);
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            *(ptQ++) = ptI[ *(ptL++) ];
        for ( p = degL; p < degR; p++ )
            *(ptQ++) = ptI[ p ];
    }
    else {
        for ( p = 0; p < degL; p++ )
            *(ptQ++) = IMAGE( ptL[ p ], ptI, degR );
    }

    /* make the buffer bag clean again                                     */
    ptI = ADDR_PERM4(TmpPerm);
    for ( p = 0; p < degR; p++ )
        ptI[ p ] = 0;

    /* return the result                                                   */
    return quo;
}

Obj             QuoPerm42 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 quo;            /* handle of the quotient (result) */
    UInt                degQ;           /* degree of the quotient          */
    UInt4 *             ptQ;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt2 *             ptI;            /* pointer to the inverse          */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degQ = degL < degR ? degR : degL;
    quo  = NEW_PERM4( degQ );

    /* make sure that the buffer bag is large enough to hold the inverse   */
    if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opR) ) {
        ResizeBag( TmpPerm, SIZE_OBJ(opR) );
    }

    /* invert the right permutation into the buffer bag                    */
    ptI = ADDR_PERM2(TmpPerm);
    ptR = ADDR_PERM2(opR);
    for ( p = 0; p < degR; p++ )
        ptI[ *ptR++ ] = p;

    /* multiply the left permutation with the inverse                      */
    ptL = ADDR_PERM4(opL);
    ptI = ADDR_PERM2(TmpPerm);
    ptQ = ADDR_PERM4(quo);
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            *(ptQ++) = ptI[ *(ptL++) ];
        for ( p = degL; p < degR; p++ )
            *(ptQ++) = ptI[ p ];
    }
    else {
        for ( p = 0; p < degL; p++ )
            *(ptQ++) = IMAGE( ptL[ p ], ptI, degR );
    }

    /* make the buffer bag clean again                                     */
    ptI = ADDR_PERM2(TmpPerm);
    for ( p = 0; p < degR; p++ )
        ptI[ p ] = 0;

    /* return the result                                                   */
    return quo;
}

Obj             QuoPerm44 (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 quo;            /* handle of the quotient (result) */
    UInt                degQ;           /* degree of the quotient          */
    UInt4 *             ptQ;            /* pointer to the quotient         */
    UInt                degL;           /* degree of the left operand      */
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt4 *             ptI;            /* pointer to the inverse          */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degQ = degL < degR ? degR : degL;
    quo  = NEW_PERM4( degQ );

    /* make sure that the buffer bag is large enough to hold the inverse   */
    if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opR) ) {
        ResizeBag( TmpPerm, SIZE_OBJ(opR) );
    }

    /* invert the right permutation into the buffer bag                    */
    ptI = ADDR_PERM4(TmpPerm);
    ptR = ADDR_PERM4(opR);
    for ( p = 0; p < degR; p++ )
        ptI[ *ptR++ ] = p;

    /* multiply the left permutation with the inverse                      */
    ptL = ADDR_PERM4(opL);
    ptI = ADDR_PERM4(TmpPerm);
    ptQ = ADDR_PERM4(quo);
    if ( degL <= degR ) {
        for ( p = 0; p < degL; p++ )
            *(ptQ++) = ptI[ *(ptL++) ];
        for ( p = degL; p < degR; p++ )
            *(ptQ++) = ptI[ p ];
    }
    else {
        for ( p = 0; p < degL; p++ )
            *(ptQ++) = IMAGE( ptL[ p ], ptI, degR );
    }

    /* make the buffer bag clean again                                     */
    ptI = ADDR_PERM4(TmpPerm);
    for ( p = 0; p < degR; p++ )
        ptI[ p ] = 0;

    /* return the result                                                   */
    return quo;
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
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM2( degM );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM2(opR);
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
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM4( degM );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM4(opR);
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
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM4( degM );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM2(opR);
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
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degM = degL < degR ? degR : degL;
    mod = NEW_PERM4( degM );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM4(opR);
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
    UInt2 *             ptL;            /* pointer to the permutation      */
    UInt2 *             ptKnown;        /* pointer to temporary bag        */
    UInt                deg;            /* degree of the permutation       */
    Int                 exp,  e;        /* exponent (right operand)        */
    UInt                len;            /* length of cycle (result)        */
    UInt                p,  q,  r;      /* loop variables                  */

    /* get the operands and allocate a result bag                          */
    deg = DEG_PERM2(opL);
    pow = NEW_PERM2( deg );

    /* compute the power by repeated mapping for small positive exponents  */
    if ( TYPE_OBJ(opR) == T_INT
      && 0 <= INT_INTOBJ(opR) && INT_INTOBJ(opR) < 8 ) {

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = ADDR_PERM2(opL);
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
    else if ( TYPE_OBJ(opR) == T_INT && 8 <= INT_INTOBJ(opR) ) {

        /* make sure that the buffer bag is large enough                   */
        if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opL) ) {
            ResizeBag( TmpPerm, SIZE_OBJ(opL) );
        }
        ptKnown = ADDR_PERM2(TmpPerm);

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = ADDR_PERM2(opL);
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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM2(opL); p++ )
            ptKnown[p] = 0;

    }

    /* compute the power by raising the cycles individually for large exps */
    else if ( TYPE_OBJ(opR) == T_INTPOS ) {

        /* make sure that the buffer bag is large enough                   */
        if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opL) ) {
            ResizeBag( TmpPerm, SIZE_OBJ(opL) );
        }
        ptKnown = ADDR_PERM2(TmpPerm);

        /* get pointer to the permutation and the power                    */
        ptL = ADDR_PERM2(opL);
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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM2(opL); p++ )
            ptKnown[p] = 0;

    }

    /* special case for inverting permutations                             */
    else if ( TYPE_OBJ(opR) == T_INT && INT_INTOBJ(opR) == -1 ) {

        /* get pointer to the permutation and the power                    */
        ptL = ADDR_PERM2(opL);
        ptP = ADDR_PERM2(pow);

        /* invert the permutation                                          */
        for ( p = 0; p < deg; p++ )
            ptP[ *(ptL++) ] = p;

    }

    /* compute the power by repeated mapping for small negative exponents  */
    else if ( TYPE_OBJ(opR) == T_INT
          && -8 < INT_INTOBJ(opR) && INT_INTOBJ(opR) < 0 ) {

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = ADDR_PERM2(opL);
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
    else if ( TYPE_OBJ(opR) == T_INT && INT_INTOBJ(opR) <= -8 ) {

        /* make sure that the buffer bag is large enough                   */
        if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opL) ) {
            ResizeBag( TmpPerm, SIZE_OBJ(opL) );
        }
        ptKnown = ADDR_PERM2(TmpPerm);

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = ADDR_PERM2(opL);
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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM2(opL); p++ )
            ptKnown[p] = 0;

    }

    /* compute the power by raising the cycles individually for large exps */
    else if ( TYPE_OBJ(opR) == T_INTNEG ) {

        /* make sure that the buffer bag is large enough                   */
        if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opL) ) {
            ResizeBag( TmpPerm, SIZE_OBJ(opL) );
        }
        ptKnown = ADDR_PERM2(TmpPerm);

        /* get pointer to the permutation and the power                    */
        opR = ProdInt( INTOBJ_INT(-1), opR );
        ptL = ADDR_PERM2(opL);
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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM2(opL); p++ )
            ptKnown[p] = 0;

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
    UInt4 *             ptL;            /* pointer to the permutation      */
    UInt4 *             ptKnown;        /* pointer to temporary bag        */
    UInt                deg;            /* degree of the permutation       */
    Int                 exp,  e;        /* exponent (right operand)        */
    UInt                len;            /* length of cycle (result)        */
    UInt                p,  q,  r;      /* loop variables                  */

    /* get the operands and allocate a result bag                          */
    deg = DEG_PERM4(opL);
    pow = NEW_PERM4( deg );

    /* compute the power by repeated mapping for small positive exponents  */
    if ( TYPE_OBJ(opR) == T_INT
      && 0 <= INT_INTOBJ(opR) && INT_INTOBJ(opR) < 8 ) {

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = ADDR_PERM4(opL);
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
    else if ( TYPE_OBJ(opR) == T_INT && 8 <= INT_INTOBJ(opR) ) {

        /* make sure that the buffer bag is large enough                   */
        if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opL) ) {
            ResizeBag( TmpPerm, SIZE_OBJ(opL) );
        }
        ptKnown = ADDR_PERM4(TmpPerm);

        /* get pointer to the permutation and the power                    */
        exp = INT_INTOBJ(opR);
        ptL = ADDR_PERM4(opL);
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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM4(opL); p++ )
            ptKnown[p] = 0;

    }

    /* compute the power by raising the cycles individually for large exps */
    else if ( TYPE_OBJ(opR) == T_INTPOS ) {

        /* make sure that the buffer bag is large enough                   */
        if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opL) ) {
            ResizeBag( TmpPerm, SIZE_OBJ(opL) );
        }
        ptKnown = ADDR_PERM4(TmpPerm);

        /* get pointer to the permutation and the power                    */
        ptL = ADDR_PERM4(opL);
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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM4(opL); p++ )
            ptKnown[p] = 0;

    }

    /* special case for inverting permutations                             */
    else if ( TYPE_OBJ(opR) == T_INT && INT_INTOBJ(opR) == -1 ) {

        /* get pointer to the permutation and the power                    */
        ptL = ADDR_PERM4(opL);
        ptP = ADDR_PERM4(pow);

        /* invert the permutation                                          */
        for ( p = 0; p < deg; p++ )
            ptP[ *(ptL++) ] = p;

    }

    /* compute the power by repeated mapping for small negative exponents  */
    else if ( TYPE_OBJ(opR) == T_INT
           && -8 < INT_INTOBJ(opR) && INT_INTOBJ(opR) < 0 ) {

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = ADDR_PERM4(opL);
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
    else if ( TYPE_OBJ(opR) == T_INT && INT_INTOBJ(opR) <= -8 ) {

        /* make sure that the buffer bag is large enough                   */
        if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opL) ) {
            ResizeBag( TmpPerm, SIZE_OBJ(opL) );
        }
        ptKnown = ADDR_PERM4(TmpPerm);

        /* get pointer to the permutation and the power                    */
        exp = -INT_INTOBJ(opR);
        ptL = ADDR_PERM4(opL);
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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM4(opL); p++ )
            ptKnown[p] = 0;

    }

    /* compute the power by raising the cycles individually for large exps */
    else if ( TYPE_OBJ(opR) == T_INTNEG ) {

        /* make sure that the buffer bag is large enough                   */
        if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(opL) ) {
            ResizeBag( TmpPerm, SIZE_OBJ(opL) );
        }
        ptKnown = ADDR_PERM4(TmpPerm);

        /* get pointer to the permutation and the power                    */
        opR = ProdInt( INTOBJ_INT(-1), opR );
        ptL = ADDR_PERM4(opL);
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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM4(opL); p++ )
            ptKnown[p] = 0;

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
Obj             PowIntPerm2 (
    Obj                 opL,
    Obj                 opR )
{
    Int                 img;            /* image (result)                  */

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TYPE_OBJ(opL) == T_INTPOS )
        return opL;

    /* permutations do not act on negative integers                        */
    img = INT_INTOBJ( opL );
    if ( img <= 0 ) {
        opL = ErrorReturnObj(
            "Perm. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L,
            "you can return a positive integer for <point>" );
        return POW( opL, opR );
    }

    /* compute the image                                                   */
    if ( img <= DEG_PERM2(opR) ) {
        img = (ADDR_PERM2(opR))[img-1] + 1;
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
    if ( TYPE_OBJ(opL) == T_INTPOS )
        return opL;

    /* permutations do not act on negative integers                        */
    img = INT_INTOBJ( opL );
    if ( img <= 0 ) {
        opL = ErrorReturnObj(
            "Perm. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L,
            "you can return a positive integer for <point>" );
        return POW( opL, opR );
    }

    /* compute the image                                                   */
    if ( img <= DEG_PERM4(opR) ) {
        img = (ADDR_PERM4(opR))[img-1] + 1;
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
Obj             QuoIntPerm2 (
    Obj                 opL,
    Obj                 opR )
{
    Int                 pre;            /* preimage (result)               */
    Int                 img;            /* image (left operand)            */
    UInt2 *             ptR;            /* pointer to the permutation      */

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TYPE_OBJ(opL) == T_INTPOS )
        return opL;

    /* permutations do not act on negative integers                        */
    img = INT_INTOBJ(opL);
    if ( img <= 0 ) {
        opL = ErrorReturnObj(
            "Perm. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L,
            "you can return a positive integer for <point>" );
        return QUO( opL, opR );
    }

    /* compute the preimage                                                */
    pre = img;
    ptR = ADDR_PERM2(opR);
    if ( img <= DEG_PERM2(opR) ) {
        while ( ptR[ pre-1 ] != img-1 )
            pre = ptR[ pre-1 ] + 1;
    }

    /* return it                                                           */
    return INTOBJ_INT(pre);
}

Obj             QuoIntPerm4 (
    Obj                 opL,
    Obj                 opR )
{
    Int                 pre;            /* preimage (result)               */
    Int                 img;            /* image (left operand)            */
    UInt4 *             ptR;            /* pointer to the permutation      */

    /* large positive integers (> 2^28-1) are fixed by any permutation     */
    if ( TYPE_OBJ(opL) == T_INTPOS )
        return opL;

    /* permutations do not act on negative integers                        */
    img = INT_INTOBJ(opL);
    if ( img <= 0 ) {
        opL = ErrorReturnObj(
            "Perm. Operations: <point> must be a positive integer (not %d)",
            (Int)img, 0L,
            "you can return a positive integer for <point>" );
        return QUO( opL, opR );
    }

    /* compute the preimage                                                */
    pre = img;
    ptR = ADDR_PERM4(opR);
    if ( img <= DEG_PERM4(opR) ) {
        while ( ptR[ pre-1 ] != img-1 )
            pre = ptR[ pre-1 ] + 1;
    }

    /* return it                                                           */
    return INTOBJ_INT(pre);
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
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM2( degC );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM2(opR);
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
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM4(opR);
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
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM2(opR);
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
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degC = degL < degR ? degR : degL;
    cnj = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM4(opR);
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
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM2(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM2( degC );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM2(opR);
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
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM2(opL);
    degR = DEG_PERM4(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM2(opL);
    ptR = ADDR_PERM4(opR);
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
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM2(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM2(opR);
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
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt                degR;           /* degree of the right operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* compute the size of the result and allocate a bag                   */
    degL = DEG_PERM4(opL);
    degR = DEG_PERM4(opR);
    degC = degL < degR ? degR : degL;
    com = NEW_PERM4( degC );

    /* set up the pointers                                                 */
    ptL = ADDR_PERM4(opL);
    ptR = ADDR_PERM4(opR);
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
*F  IsPermHadnler( <self>, <val> )  . . . .  test if a value is a permutation
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
    switch ( TYPE_OBJ(val) ) {

	case T_PERM2:
	case T_PERM4:
	    return True;

	case T_COMOBJ:
	case T_POSOBJ:
	case T_DATOBJ:
	    return DoFilter( self, val );

        default:
	    return False;
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
**  'FunPermList' simply copies the list pointwise into  a  permutation  bag.
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
    Obj *               ptList;         /* pointer to the list             */
    UInt2 *             ptTmp2;         /* pointer to the buffer bag       */
    UInt4 *             ptTmp4;         /* pointer to the buffer bag       */
    Int                 i,  k;          /* loop variables                  */

    /* check the arguments                                                 */
    while ( ! IS_LIST( list ) ) {
        list = ErrorReturnObj(
            "PermList: <list> must be a list (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(list)].name), 0L,
            "you can return a list for <list>" );
    }
    PLAIN_LIST( list );

    /* handle small permutations                                           */
    if ( LEN_LIST( list ) <= 65536 ) {

        degPerm = LEN_LIST( list );

        /* make sure that the global buffer bag is large enough for checkin*/
        if ( SIZE_OBJ(TmpPerm) < degPerm * sizeof(UInt2) ) {
            ResizeBag( TmpPerm, degPerm * sizeof(UInt2) );
        }

        /* allocate the bag for the permutation and get pointer            */
        perm    = NEW_PERM2( degPerm );
        ptPerm2 = ADDR_PERM2(perm);
        ptList  = ADDR_OBJ(list);
        ptTmp2  = ADDR_PERM2(TmpPerm);

        /* run through all entries of the list                             */
        for ( i = 1; i <= degPerm; i++ ) {

            /* get the <i>th entry of the list                             */
            if ( ptList[i] == 0 ) {
                for ( i = 1; i <= degPerm; i++ )  ptTmp2[i-1] = 0;
                list = ErrorReturnObj(
                    "PermList: <list>[%d] must have an assigned value",
                    (Int)i, 0L,
                    "you can return a new list for <list>" );
                return FuncPermList( 0, list );
            }
            if ( TYPE_OBJ(ptList[i]) != T_INT ) {
                for ( i = 1; i <= degPerm; i++ )  ptTmp2[i-1] = 0;
                list = ErrorReturnObj(
                    "PermList: <list>[%d] must be an integer",
                    (Int)i, 0L,
                    "you can return a new list for <list>" );
                return FuncPermList( 0, list );
            }
            k = INT_INTOBJ(ptList[i]);
            if ( k <= 0 || degPerm < k ) {
                for ( i = 1; i <= degPerm; i++ )  ptTmp2[i-1] = 0;
                list = ErrorReturnObj(
                    "PermList: <list>[%d] must lie in [1..%d]",
                    (Int)i, (Int)degPerm,
                    "you can return a new list for <list>" );
                return FuncPermList( 0, list );
            }

            /* make sure we haven't seen this entry yet                     */
            if ( ptTmp2[k-1] != 0 ) {
                for ( i = 1; i <= degPerm; i++ )  ptTmp2[i-1] = 0;
                list = ErrorReturnObj(
                    "PermList: the point %d must occur only once",
                    (Int)k, 0L,
                    "you can return a new list for <list>" );
                return FuncPermList( 0, list );
            }
            ptTmp2[k-1] = 1;

            /* and finally copy it into the permutation                    */
            ptPerm2[i-1] = k-1;
        }

        /* make the buffer bag clean again                                 */
        for ( i = 1; i <= degPerm; i++ )
            ptTmp2[i-1] = 0;

    }

    /* handle large permutations                                           */
    else {

        degPerm = LEN_LIST( list );

        /* make sure that the global buffer bag is large enough for checkin*/
        if ( SIZE_OBJ(TmpPerm) < degPerm * sizeof(UInt4) ) {
            ResizeBag( TmpPerm, degPerm * sizeof(UInt4) );
        }

        /* allocate the bag for the permutation and get pointer            */
        perm    = NEW_PERM4( degPerm );
        ptPerm4 = ADDR_PERM4(perm);
        ptList  = ADDR_OBJ( list);
        ptTmp4  = ADDR_PERM4(TmpPerm);

        /* run through all entries of the list                             */
        for ( i = 1; i <= degPerm; i++ ) {

            /* get the <i>th entry of the list                             */
            if ( ptList[i] == 0 ) {
                for ( i = 1; i <= degPerm; i++ )  ptTmp4[i-1] = 0;
                list = ErrorReturnObj(
                    "PermList: <list>[%d] must have an assigned value",
                    (Int)i, 0L,
                    "you can return a new list for <list>" );
                return FuncPermList( 0, list );
            }
            if ( TYPE_OBJ(ptList[i]) != T_INT ) {
                for ( i = 1; i <= degPerm; i++ )  ptTmp4[i-1] = 0;
                list = ErrorReturnObj(
                    "PermList: <list>[%d] must be an integer",
                    (Int)i, 0L,
                    "you can return a new list for <list>" );
                return FuncPermList( 0, list );
            }
            k = INT_INTOBJ(ptList[i]);
            if ( k <= 0 || degPerm < k ) {
                for ( i = 1; i <= degPerm; i++ )  ptTmp4[i-1] = 0;
                list = ErrorReturnObj(
                    "PermList: <list>[%d] must lie in [1..%d]",
                    (Int)i, (Int)degPerm,
                    "you can return a new list for <list>" );
                return FuncPermList( 0, list );
            }

            /* make sure we haven't seen this entry yet                     */
            if ( ptTmp4[k-1] != 0 ) {
                for ( i = 1; i <= degPerm; i++ )  ptTmp4[i-1] = 0;
                list = ErrorReturnObj(
                    "PermList: the point %d must occur only once",
                    (Int)k, 0L,
                    "you can return a new list for <list>" );
                return FuncPermList( 0, list );
            }
            ptTmp4[k-1] = 1;

            /* and finally copy it into the permutation                    */
            ptPerm4[i-1] = k-1;
        }

        /* make the buffer bag clean again                                 */
        for ( i = 1; i <= degPerm; i++ )
            ptTmp4[i-1] = 0;

    }

    /* return the permutation                                              */
    return perm;
}


/****************************************************************************
**
*F  FuncLargestMovedPointPerm( <self>, <perm> ) largest point moved by a perm
**
**  'FuncLargestMovedPointPerm' implements the internal function
**  'LargestMovedPointPerm'.
**
**  'LargestMovedPointPerm( <perm> )'
**
**  'LargestMovedPointPerm' returns  the  largest  positive  integer that  is
**  moved by the permutation <perm>.
**
**  This is easy, except that permutations may  contain  trailing  fixpoints.
*/
Obj             FuncLargestMovedPointPerm (
    Obj                 self,
    Obj                 perm )
{
    UInt                sup;            /* support (result)                */
    UInt2 *             ptPerm2;        /* pointer to the permutation      */
    UInt4 *             ptPerm4;        /* pointer to the permutation      */

    /* check the argument                                                  */
    while ( TYPE_OBJ(perm) != T_PERM2 && TYPE_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "LargestMovedPointPerm: <perm> must be a permutation (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(perm)].name), 0L,
            "you can return a permutation for <perm>" );
    }

    /* handle small permutations                                           */
    if ( TYPE_OBJ(perm) == T_PERM2 ) {

        /* find the largest moved point                                    */
        ptPerm2 = ADDR_PERM2(perm);
        for ( sup = DEG_PERM2(perm); 1 <= sup; sup-- ) {
            if ( ptPerm2[sup-1] != sup-1 )
                break;
        }

    }

    /* handle large permutations                                           */
    else {

        /* find the largest moved point                                    */
        ptPerm4 = ADDR_PERM4(perm);
        for ( sup = DEG_PERM4(perm); 1 <= sup; sup-- ) {
            if ( ptPerm4[sup-1] != sup-1 )
                break;
        }

    }

    /* check for identity                                                  */
    if ( sup == 0 ) {
        return ErrorReturnObj(
            "LargestMovedPointPerm: <perm> must not be the identity",
            0L, 0L,
            "you can return a result value (i.e., a largest moved point)" );
    }

    /* return it                                                           */
    return INTOBJ_INT( sup );
}


/****************************************************************************
**
*F  FuncCycleLengthPermInt( <self>, <perm>, <point> ) . . . . . . . . . . . .
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
Obj             FuncCycleLengthPermInt (
    Obj                 self,
    Obj                 perm,
    Obj                 point )
{
    UInt2 *             ptPerm2;        /* pointer to the permutation      */
    UInt4 *             ptPerm4;        /* pointer to the permutation      */
    UInt                deg;            /* degree of the permutation       */
    UInt                pnt;            /* value of the point              */
    UInt                len;            /* length of cycle (result)        */
    UInt                p;              /* loop variable                   */

    /* evaluate and check the arguments                                    */
    while ( TYPE_OBJ(perm) != T_PERM2 && TYPE_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "CycleLengthPermInt: <perm> must be a permutation (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(perm)].name), 0L,
            "you can return a permutation for <perm>" );
    }
    while ( TYPE_OBJ(point) != T_INT || INT_INTOBJ(point) <= 0 ) {
        point = ErrorReturnObj(
         "CycleLengthPermInt: <point> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(point)].name), 0L,
            "you can return a positive integer for <point>" );
    }

    /* handle small permutations                                           */
    if ( TYPE_OBJ(perm) == T_PERM2 ) {

        /* get pointer to the permutation, the degree, and the point       */
        ptPerm2 = ADDR_PERM2(perm);
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
        ptPerm4 = ADDR_PERM4(perm);
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
*F  FuncCyclePermInt( <self>, <perm>, <point> ) . . .  cycle of a permutation
*
**  'FuncCyclePermInt' implements the internal function 'CyclePermInt'.
**
**  'CyclePermInt( <perm>, <point> )'
**
**  'CyclePermInt' returns the cycle of <point>, which  must  be  a  positive
**  integer, under the permutation <perm> as a list.
*/
Obj             FuncCyclePermInt (
    Obj                 self,
    Obj                 perm,
    Obj                 point )
{
    Obj                 list;           /* handle of the list (result)     */
    Obj *               ptList;         /* pointer to the list             */
    UInt2 *             ptPerm2;        /* pointer to the permutation      */
    UInt4 *             ptPerm4;        /* pointer to the permutation      */
    UInt                deg;            /* degree of the permutation       */
    UInt                pnt;            /* value of the point              */
    UInt                len;            /* length of the cycle             */
    UInt                p;              /* loop variable                   */

    /* evaluate and check the arguments                                    */
    while ( TYPE_OBJ(perm) != T_PERM2 && TYPE_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "CyclePermInt: <perm> must be a permutation (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(perm)].name), 0L,
            "you can return a permutation for <perm>" );
    }
    while ( TYPE_OBJ(point) != T_INT || INT_INTOBJ(point) <= 0 ) {
        point = ErrorReturnObj(
            "CyclePermInt: <point> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(point)].name), 0L,
            "you can return a positive integer for <point>" );
    }

    /* handle small permutations                                           */
    if ( TYPE_OBJ(perm) == T_PERM2 ) {

        /* get pointer to the permutation, the degree, and the point       */
        ptPerm2 = ADDR_PERM2(perm);
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
        ptPerm2 = ADDR_PERM2(perm);

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
        ptPerm4 = ADDR_PERM4(perm);
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
        ptPerm4 = ADDR_PERM4(perm);

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
*F  FuncOrderPerm( <self>, <perm> ) . . . . . . . . .  order of a permutation
**
**  'FuncOrderPerm' implements the internal function 'OrderPerm'.
**
**  'OrderPerm( <perm> )'
**
**  'OrderPerm' returns the  order  of  the  permutation  <perm>,  i.e.,  the
**  smallest positive integer <n> such that '<perm>\^<n>' is the identity.
**
**  Since the largest element in S(65536) has oder greater than  10^382  this
**  computation may easily overflow.  So we have to use  arbitrary precision.
*/
Obj             FuncOrderPerm (
    Obj                 self,
    Obj                 perm )
{
    UInt2 *             ptPerm2;        /* pointer to the permutation      */
    UInt4 *             ptPerm4;        /* pointer to the permutation      */
    Obj                 ord;            /* order (result), may be huge     */
    UInt2 *             ptKnown2;       /* pointer to temporary bag        */
    UInt4 *             ptKnown4;       /* pointer to temporary bag        */
    UInt                len;            /* length of one cycle             */
    UInt                gcd, s, t;      /* gcd( len, ord ), temporaries    */
    UInt                p, q;           /* loop variables                  */

    /* check arguments and extract permutation                             */
    while ( TYPE_OBJ(perm) != T_PERM2 && TYPE_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "OrderPerm: <perm> must be a permutation (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(perm)].name), 0L,
            "you can return a permutation for <perm>" );
    }

    /* make sure that the buffer bag is large enough                       */
    if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(perm) ) {
        ResizeBag( TmpPerm, SIZE_OBJ(perm) );
    }

    /* handle small permutations                                           */
    if ( TYPE_OBJ(perm) == T_PERM2 ) {

        /* get the pointer to the bags                                     */
        ptPerm2  = ADDR_PERM2(perm);
        ptKnown2 = ADDR_PERM2(TmpPerm);

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

                /* compute the gcd with the previously order ord           */
                /* Note that since len is single precision, ord % len is to*/
                gcd = len;  s = INT_INTOBJ( ModInt( ord, INTOBJ_INT(len) ) );
                while ( s != 0 ) {
                    t = s;  s = gcd % s;  gcd = t;
                }
                ord = ProdInt( ord, INTOBJ_INT( len / gcd ) );

            }

        }

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM2(perm); p++ )
            ptKnown2[p] = 0;

    }

    /* handle larger permutations                                          */
    else {

        /* get the pointer to the bags                                     */
        ptPerm4  = ADDR_PERM4(perm);
        ptKnown4 = ADDR_PERM4(TmpPerm);

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

                /* compute the gcd with the previously order ord           */
                /* Note that since len is single precision, ord % len is to*/
                gcd = len;  s = INT_INTOBJ( ModInt( ord, INTOBJ_INT(len) ) );
                while ( s != 0 ) {
                    t = s;  s = gcd % s;  gcd = t;
                }
                ord = ProdInt( ord, INTOBJ_INT( len / gcd ) );

            }

        }

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM4(perm); p++ )
            ptKnown4[p] = 0;

    }

    /* return the order                                                    */
    return ord;
}


/****************************************************************************
**
*F  FuncSignPerm( <self>, <perm> )  . . . . . . . . . . sign of a permutation
**
**  'FuncSignPerm' implements the internal function 'SignPerm'.
**
**  'SignPerm( <perm> )'
**
**  'SignPerm' returns the sign of the permutation <perm>.  The sign is +1 if
**  <perm> is the product of an *even* number of transpositions,  and  -1  if
**  <perm> is the product of an *odd*  number  of  transpositions.  The  sign
**  is a homomorphism from the symmetric group onto the multiplicative  group
**  $\{ +1, -1 \}$, the kernel of which is the alternating group.
*/
Obj             FuncSignPerm (
    Obj                 self,
    Obj                 perm )
{
    UInt2 *             ptPerm2;        /* pointer to the permutation      */
    UInt4 *             ptPerm4;        /* pointer to the permutation      */
    Int                 sign;           /* sign (result)                   */
    UInt2 *             ptKnown2;       /* pointer to temporary bag        */
    UInt4 *             ptKnown4;       /* pointer to temporary bag        */
    UInt                len;            /* length of one cycle             */
    UInt                p,  q;          /* loop variables                  */

    /* check arguments and extract permutation                             */
    while ( TYPE_OBJ(perm) != T_PERM2 && TYPE_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "SignPerm: <perm> must be a permutation (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(perm)].name), 0L,
            "you can return a permutation for <perm>" );
    }

    /* make sure that the buffer bag is large enough                       */
    if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(perm) ) {
        ResizeBag( TmpPerm, SIZE_OBJ(perm) );
    }

    /* handle small permutations                                           */
    if ( TYPE_OBJ(perm) == T_PERM2 ) {

        /* get the pointer to the bags                                     */
        ptPerm2  = ADDR_PERM2(perm);
        ptKnown2 = ADDR_PERM2(TmpPerm);

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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM2(perm); p++ )
            ptKnown2[p] = 0;

    }

    /* handle large permutations                                           */
    else {

        /* get the pointer to the bags                                     */
        ptPerm4  = ADDR_PERM4(perm);
        ptKnown4 = ADDR_PERM4(TmpPerm);

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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM4(perm); p++ )
            ptKnown4[p] = 0;

    }

    /* return the sign                                                     */
    return INTOBJ_INT( sign );
}


/****************************************************************************
**
*F  FuncSmallestGeneratorPerm( <self>, <perm> ) . . . . . . . . . . . . . . .
*F  . . . . . . . smallest generator of cyclic group generated by permutation
**
**  'FuncSmallestGeneratorPerm' implements the internal function
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
Obj             FuncSmallestGeneratorPerm (
    Obj                 self,
    Obj                 perm )
{
    Obj                 small;          /* handle of the smallest gen      */
    UInt2 *             ptSmall2;       /* pointer to the smallest gen     */
    UInt4 *             ptSmall4;       /* pointer to the smallest gen     */
    UInt2 *             ptPerm2;        /* pointer to the permutation      */
    UInt4 *             ptPerm4;        /* pointer to the permutation      */
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
    while ( TYPE_OBJ(perm) != T_PERM2 && TYPE_OBJ(perm) != T_PERM4 ) {
        perm = ErrorReturnObj(
            "SmallestGeneratorPerm: <perm> must be a permutation (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(perm)].name), 0L,
            "you can return a permutation for <perm>" );
    }

    /* make sure that the buffer bag is large enough                       */
    if ( SIZE_OBJ(TmpPerm) < SIZE_OBJ(perm) ) {
        ResizeBag( TmpPerm, SIZE_OBJ(perm) );
    }

    /* handle small permutations                                           */
    if ( TYPE_OBJ(perm) == T_PERM2 ) {

        /* allocate the result bag                                         */
        small = NEW_PERM2( DEG_PERM2(perm) );

        /* get the pointer to the bags                                     */
        ptPerm2   = ADDR_PERM2(perm);
        ptKnown2  = ADDR_PERM2(TmpPerm);
        ptSmall2  = ADDR_PERM2(small);

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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM2(perm); p++ )
            ptKnown2[p] = 0;

    }

    /* handle large permutations                                           */
    else {

        /* allocate the result bag                                         */
        small = NEW_PERM4( DEG_PERM4(perm) );

        /* get the pointer to the bags                                     */
        ptPerm4   = ADDR_PERM4(perm);
        ptKnown4  = ADDR_PERM4(TmpPerm);
        ptSmall4  = ADDR_PERM4(small);

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

        /* clear the buffer bag again                                      */
        for ( p = 0; p < DEG_PERM4(perm); p++ )
            ptKnown4[p] = 0;

    }

    /* return the smallest generator                                       */
    return small;
}


/****************************************************************************
**
*F  OnTuplesPerm( <tup>, <perm> )  . . . .  operations on tuples of points
**
**  'OnTuplesPerm'  returns  the  image  of  the  tuple  <tup>   under  the
**  permutation <perm>.  It is called from 'FunOnTuples'.
*/
Obj             OnTuplesPerm (
    Obj                 tup,
    Obj                 perm )
{
    Obj                 res;            /* handle of the image, result     */
    Obj *               ptRes;          /* pointer to the result           */
    Obj *               ptTup;          /* pointer to the tuple            */
    UInt2 *             ptPrm2;         /* pointer to the permutation      */
    UInt4 *             ptPrm4;         /* pointer to the permutation      */
    Obj                 tmp;            /* temporary handle                */
    UInt                lmp;            /* largest moved point             */
    UInt                i, k;           /* loop variables                  */

    /* make a bag for the result and initialize pointers                   */
    res = NEW_PLIST( T_PLIST, LEN_LIST(tup) );
    ADDR_OBJ(res)[0] = ADDR_OBJ(tup)[0];

    /* handle small permutations                                           */
    if ( TYPE_OBJ(perm) == T_PERM2 ) {

        /* get the pointer                                                 */
        ptTup = ADDR_OBJ(tup) + LEN_LIST(tup);
        ptRes = ADDR_OBJ(res) + LEN_LIST(tup);
        ptPrm2 = ADDR_PERM2(perm);
        lmp = DEG_PERM2(perm);

        /* loop over the entries of the tuple                              */
        for ( i = LEN_LIST(tup); 1 <= i; i--, ptTup--, ptRes-- ) {
            if ( TYPE_OBJ( *ptTup ) == T_INT && 0 < INT_INTOBJ( *ptTup ) ) {
                k = INT_INTOBJ( *ptTup );
                if ( k <= lmp )
                    tmp = INTOBJ_INT( ptPrm2[k-1] + 1 );
                else
                    tmp = INTOBJ_INT( k );
                *ptRes = tmp;
            }
            else {
                tmp = POW( *ptTup, perm );
                ptTup = ADDR_OBJ(tup) + i;
                ptRes = ADDR_OBJ(res) + i;
                ptPrm2 = ADDR_PERM2(perm);
                *ptRes = tmp;
                CHANGED_BAG( res );
            }
        }

    }

    /* handle large permutations                                           */
    else {

        /* get the pointer                                                 */
        ptTup = ADDR_OBJ(tup) + LEN_LIST(tup);
        ptRes = ADDR_OBJ(res) + LEN_LIST(tup);
        ptPrm4 = ADDR_PERM4(perm);
        lmp = DEG_PERM4(perm);

        /* loop over the entries of the tuple                              */
        for ( i = LEN_LIST(tup); 1 <= i; i--, ptTup--, ptRes-- ) {
            if ( TYPE_OBJ( *ptTup ) == T_INT && 0 < INT_INTOBJ( *ptTup ) ) {
                k = INT_INTOBJ( *ptTup );
                if ( k <= lmp )
                    tmp = INTOBJ_INT( ptPrm4[k-1] + 1 );
                else
                    tmp = INTOBJ_INT( k );
                *ptRes = tmp;
            }
            else {
                tmp = POW( *ptTup, perm );
                ptTup = ADDR_OBJ(tup) + i;
                ptRes = ADDR_OBJ(res) + i;
                ptPrm4 = ADDR_PERM4(perm);
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
**  <perm>.  It is called from 'FunOnSets'.
*/
Obj             OnSetsPerm (
    Obj                 set,
    Obj                 perm )
{
    Obj                 res;            /* handle of the image, result     */
    Obj *               ptRes;          /* pointer to the result           */
    Obj *               ptTup;          /* pointer to the tuple            */
    UInt2 *             ptPrm2;         /* pointer to the permutation      */
    UInt4 *             ptPrm4;         /* pointer to the permutation      */
    Obj                 tmp;            /* temporary handle                */
    UInt                lmp;            /* largest moved point             */
    UInt                isint;          /* <set> only holds integers       */
    UInt                len;            /* logical length of the list      */
    UInt                h;              /* gap width in the shellsort      */
    UInt                i, k;           /* loop variables                  */

    /* make a bag for the result and initialize pointers                   */
    res = NEW_PLIST( T_PLIST, LEN_LIST(set) );
    ADDR_OBJ(res)[0] = ADDR_OBJ(set)[0];

    /* handle small permutations                                           */
    if ( TYPE_OBJ(perm) == T_PERM2 ) {

        /* get the pointer                                                 */
        ptTup = ADDR_OBJ(set) + LEN_LIST(set);
        ptRes = ADDR_OBJ(res) + LEN_LIST(set);
        ptPrm2 = ADDR_PERM2(perm);
        lmp = DEG_PERM2(perm);

        /* loop over the entries of the tuple                              */
        isint = 1;
        for ( i = LEN_LIST(set); 1 <= i; i--, ptTup--, ptRes-- ) {
            if ( TYPE_OBJ( *ptTup ) == T_INT && 0 < INT_INTOBJ( *ptTup ) ) {
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
                ptTup = ADDR_OBJ(set) + i;
                ptRes = ADDR_OBJ(res) + i;
                ptPrm2 = ADDR_PERM2(perm);
                *ptRes = tmp;
                CHANGED_BAG( res );
            }
        }

    }

    /* handle large permutations                                           */
    else {

        /* get the pointer                                                 */
        ptTup = ADDR_OBJ(set) + LEN_LIST(set);
        ptRes = ADDR_OBJ(res) + LEN_LIST(set);
        ptPrm4 = ADDR_PERM4(perm);
        lmp = DEG_PERM4(perm);

        /* loop over the entries of the tuple                              */
        isint = 1;
        for ( i = LEN_LIST(set); 1 <= i; i--, ptTup--, ptRes-- ) {
            if ( TYPE_OBJ( *ptTup ) == T_INT && 0 < INT_INTOBJ( *ptTup ) ) {
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
                ptTup = ADDR_OBJ(set) + i;
                ptRes = ADDR_OBJ(res) + i;
                ptPrm4 = ADDR_PERM4(perm);
                *ptRes = tmp;
                CHANGED_BAG( res );
            }
        }

    }

    /* special case if the result only holds integers                      */
    if ( isint ) {

        /* sort the set with a shellsort                                   */
        len = LEN_LIST(res);
        h = 1;  while ( 9*h + 4 < len )  h = 3*h + 1;
        while ( 0 < h ) {
            for ( i = h+1; i <= len; i++ ) {
                tmp = ADDR_OBJ(res)[i];  k = i;
                while ( h < k && ((Int)tmp < (Int)(ADDR_OBJ(res)[k-h])) ) {
                    ADDR_OBJ(res)[k] = ADDR_OBJ(res)[k-h];
                    k -= h;
                }
                ADDR_OBJ(res)[k] = tmp;
            }
            h = h / 3;
        }
        RetypeBag( res, T_PLIST_CYC_SSORT );
    }

    /* general case                                                        */
    else {

        /* sort the set with a shellsort                                   */
        len = LEN_LIST(res);
        h = 1;  while ( 9*h + 4 < len )  h = 3*h + 1;
        while ( 0 < h ) {
            for ( i = h+1; i <= len; i++ ) {
                tmp = ADDR_OBJ(res)[i];  k = i;
                while ( h < k && LT( tmp, ADDR_OBJ(res)[k-h] ) ) {
                    ADDR_OBJ(res)[k] = ADDR_OBJ(res)[k-h];
                    k -= h;
                }
                ADDR_OBJ(res)[k] = tmp;
            }
            h = h / 3;
        }

        /* remove duplicates, shrink bag if possible                       */
        if ( 0 < len ) {
            tmp = ADDR_OBJ(res)[1];  k = 1;
            for ( i = 2; i <= len; i++ ) {
                if ( ! EQ( tmp, ADDR_OBJ(res)[i] ) ) {
                    k++;
                    tmp = ADDR_OBJ(res)[i];
                    ADDR_OBJ(res)[k] = tmp;
                }
            }
            if ( k < len ) {
                ResizeBag( res, (k+1)*sizeof(Obj) );
                ADDR_OBJ(res)[0] = INTOBJ_INT(k);
            }
        }

    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**

*F  InitPermutat()  . . . . . . . . . . . initializes the permutation package
**
**  Is  called  during  the  initialization  to  initialize  the  permutation
**  package.
*/
void            InitPermutat ( void )
{
    /* install the marking function                                        */
    InfoBags[           T_PERM2         ].name = "permutation (small)";
    InitMarkFuncBags(   T_PERM2         , MarkNoSubBags );
    InfoBags[           T_PERM4         ].name = "permutation (large)";
    InitMarkFuncBags(   T_PERM4         , MarkNoSubBags );


    /* install the kind function                                           */
    InitCopyGVar( GVarName("KIND_PERM2"), &KIND_PERM2 );
    InitCopyGVar( GVarName("KIND_PERM4"), &KIND_PERM4 );
    KindObjFuncs[ T_PERM2 ] = KindPerm2;
    KindObjFuncs[ T_PERM4 ] = KindPerm4;


    /* install the printing functions                                      */
    PrintObjFuncs[ T_PERM2   ] = PrintPermP;
    PrintObjFuncs[ T_PERM4   ] = PrintPermQ;


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
    QuoFuncs [ T_PERM2  ][ T_PERM2  ] = QuoPerm22;
    QuoFuncs [ T_PERM2  ][ T_PERM4  ] = QuoPerm24;
    QuoFuncs [ T_PERM4  ][ T_PERM2  ] = QuoPerm42;
    QuoFuncs [ T_PERM4  ][ T_PERM4  ] = QuoPerm44;
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


    /* install the internal functions                                      */
    IsPermFilt = NewFilterC( "IS_PERM", 1L, "obj",
                                IsPermHandler );
    AssGVar( GVarName( "IS_PERM" ), IsPermFilt );

    AssGVar( GVarName( "PermList" ),
         NewFunctionC( "PermList", 1L, "list",
                    FuncPermList                   ) );

    AssGVar( GVarName( "LargestMovedPointPerm" ),
         NewFunctionC( "LargestMovedPointPerm", 1L, "perm",
                    FuncLargestMovedPointPerm      ) );

    AssGVar( GVarName( "CycleLengthPermInt" ),
         NewFunctionC( "CycleLengthPermInt", 2L, "perm, point",
                    FuncCycleLengthPermInt         ) );

    AssGVar( GVarName( "CyclePermInt" ),
         NewFunctionC( "CyclePermInt", 2L, "perm, point",
                    FuncCyclePermInt               ) );

    AssGVar( GVarName( "OrderPerm" ),
         NewFunctionC( "OrderPerm", 1L, "perm",
                    FuncOrderPerm                  ) );

    AssGVar( GVarName( "SignPerm" ),
         NewFunctionC( "SignPerm", 1L, "perm",
                    FuncSignPerm                   ) );

    AssGVar( GVarName( "SmallestGeneratorPerm" ),
         NewFunctionC( "SmallestGeneratorPerm", 1L, "perm",
                    FuncSmallestGeneratorPerm      ) );


    /* make the buffer bag                                                 */
    TmpPerm = NEW_PERM4( 1000 );
    InitGlobalBag( &TmpPerm );


    /* make the identity permutation                                       */
    IdentityPerm = NEW_PERM2( 0 );
    InitGlobalBag( &IdentityPerm );


    /* install the 'ONE' function for permutations                         */
    OneFuncs[ T_PERM2 ] = OnePerm;
    OneFuncs[ T_PERM4 ] = OnePerm;
}


/****************************************************************************
**

*E  permutat.c 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
