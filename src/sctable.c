/****************************************************************************
**
*W  sctable.c                   GAP source                     Marcel Roelofs
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,        CWI,        Amsterdam,        The Netherlands
**
**  This file contains a fast access function  for structure constants tables
**  and the multiplication of two elements using a structure constants table.
**
**  Structure constants tables in GAP have the following layout
**  
**        [ [ 1 ],
**          ...
**          [ i ],  ---> [ [ 1 ], ..., [ j ], ..., [ n ] ]
**          ...                          |
**          [ n ],                       |
**          flag,                        |  
**          zero ]                       V  
**                                       [ [ k        , ... ],
**                                         [ c_{ij}^k , ... ]  ]
**
**  where the two outer lists for i and j are full lists  of the dimension of
**  the underlying vectorspace,   and the lists for k and c_{ij}^k are stored 
**  sparsely, that is, only for those k with non-zero c_{ij}^k.
**  
**  The last two elements of the outermost list have a special meaning.
**
**  The flag is an integer that indicates  whether the product defined by the
**  table is commutative (+1) or anti-commutative (-1) or neither (0).
**
**  zero is the zero element of the coefficient ring/field of the algebra.
**
**  NOTE: most of the code consists of dimension- and type checks,  as a user
**        can fool around with SCTables as he likes. 
*/
char *          Revision_sctable_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* Bag, NewBag                     */
#include        "objects.h"             /* Obj, TNUM_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* NewFunctionC                    */
#include        "ariths.h"              /* EQ, LT                          */

#include        "lists.h"               /* IS_LIST, LEN_LIST, ELM_LIST, ...*/

#include        "plist.h"               /* SET_LEN_PLIST, SET_ELM_PLIST,...*/

#define INCLUDE_DECLARATION_PART
#include        "sctable.h"             /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**
*F  SCTableEntry(<table>,<i>,<j>,<k>) . . . . . . .  entry of structure table
**
**  'SCTableEntry' returns the coefficient $c_{i,j}^{k}$ from the structure
**  constants table <table>.
*/
Obj         SCTableEntryFunc;

Obj         SCTableEntryHandler (
    Obj                 self,
    Obj                 table,
    Obj                 i,
    Obj                 j,
    Obj                 k )
{
    Obj                 tmp;            /* temporary                       */
    Obj                 basis;          /* basis  list                     */
    Obj                 coeffs;         /* coeffs list                     */
    Int                 dim;            /* dimension                       */
    Int                 len;            /* length of basis/coeffs lists    */
    Int                 l;              /* loop variable                   */

    /* check the table                                                     */
    if ( ! IS_LIST(table) ) {
        table = ErrorReturnObj(
            "SCTableEntry: <table> must be a list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(table)].name), 0L,
            "you can return a list for <table>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }
    dim = LEN_LIST(table) - 2;
    if ( dim <= 0 ) {
        table = ErrorReturnObj(
            "SCTableEntry: <table> must be a list with at least 3 elements",
            0L, 0L,
            "you can return a list for <table>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }

    /* check <i>                                                           */
    if ( ! IS_INTOBJ(i) || INT_INTOBJ(i) <= 0 || dim < INT_INTOBJ(i) ) {
        i = ErrorReturnObj(
            "SCTableEntry: <i> must be an integer between 0 and %d",
            dim, 0L,
            "you can return an integer for <i>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }

    /* get and check the relevant row                                      */
    tmp = ELM_LIST( table, INT_INTOBJ(i) );
    if ( ! IS_LIST(tmp) || LEN_LIST(tmp) != dim ) {
        table = ErrorReturnObj(
            "SCTableEntry: <table>[%d] must be a list with %d elements",
            INT_INTOBJ(i), dim,
            "you can return a list for <table>" );
        return SCTableEntryHandler( self, table, i, j, k );

    }

    /* check <j>                                                           */
    if ( ! IS_INTOBJ(j) || INT_INTOBJ(j) <= 0 || dim < INT_INTOBJ(j) ) {
        j = ErrorReturnObj(
            "SCTableEntry: <j> must be an integer between 0 and %d",
            dim, 0L,
            "you can return an integer for <j>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }

    /* get and check the basis and coefficients list                       */
    tmp = ELM_LIST( tmp, INT_INTOBJ(j) );
    if ( ! IS_LIST(tmp) || LEN_LIST(tmp) != 2 ) {
        table = ErrorReturnObj(
            "SCTableEntry: <table>[%d][%d] must be a basis/coeffs list",
            0L, 0L,
            "you can return a list for <table>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }

    /* get and check the basis list                                        */
    basis = ELM_LIST( tmp, 1 );
    if ( ! IS_LIST(basis) ) {
        table = ErrorReturnObj(
            "SCTableEntry: <table>[%d][%d][1] must be a basis list",
            0L, 0L,
            "you can return a list for <table>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }

    /* get and check the coeffs list                                       */
    coeffs = ELM_LIST( tmp, 2 );
    if ( ! IS_LIST(coeffs) ) {
        table = ErrorReturnObj(
            "SCTableEntry: <table>[%d][%d][2] must be a coeffs list",
            0L, 0L,
            "you can return a list for <table>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }

    /* check that they have the same length                                */
    len = LEN_LIST(basis);
    if ( LEN_LIST(coeffs) != len ) {
        table = ErrorReturnObj(
            "SCTableEntry: <table>[%d][%d][1], ~[2] must have equal length",
            0L, 0L,
            "you can return a list for <table>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }

    /* check <k>                                                           */
    if ( ! IS_INTOBJ(k) || INT_INTOBJ(k) <= 0 || dim < INT_INTOBJ(k) ) {
        k = ErrorReturnObj(
            "SCTableEntry: <k> must be an integer between 0 and %d",
            dim, 0L,
            "you can return an integer for <k>" );
        return SCTableEntryHandler( self, table, i, j, k );
    }

    /* look for the (i,j,k) entry                                          */
    for ( l = 1; l <= len; l++ ) {
        if ( EQ( ELM_LIST( basis, l ), k ) )
            break;
    }

    /* return the coefficient of zero                                      */
    if ( l <= len ) {
        return ELM_LIST( coeffs, l );
    }
    else {
        return ELM_LIST( table, dim+2 );
    }
}


/****************************************************************************
**
*F  SCTableProduct(<table>,<list1>,<list2>) . . . product wrt structure table
**
**  'SCTableProduct'  returns the product   of  the two elements <list1>  and
**  <list2> with respect to the structure constants table <table>.
*/
void            SCTableProdAdd (
    Obj                 res,
    Obj                 coeff,
    Obj                 basis_coeffs,
    Int                 dim )
{
    Obj                 basis;
    Obj                 coeffs;
    Int                 len;
    Obj                 k;
    Obj                 c1, c2;
    Int                 l;

    basis  = ELM_LIST( basis_coeffs, 1 );
    coeffs = ELM_LIST( basis_coeffs, 2 );
    len = LEN_LIST( basis );
    if ( LEN_LIST( coeffs ) != len ) {
        ErrorQuit("SCTableProduct: corrupted <table>",0L,0L);
    }
    for ( l = 1; l <= len; l++ ) {
        k = ELM_LIST( basis, l );
        if ( ! IS_INTOBJ(k) || INT_INTOBJ(k) <= 0 || dim < INT_INTOBJ(k) ) {
            ErrorQuit("SCTableProduct: corrupted <table>",0L,0L);
        }
        c1 = ELM_LIST( coeffs, l );
        c1 = PROD( coeff, c1 );
        c2 = ELM_PLIST( res, INT_INTOBJ(k) );
        c2 = SUM( c2, c1 );
        SET_ELM_PLIST( res, INT_INTOBJ(k), c2 );
        CHANGED_BAG( res );
    }
}

Obj             SCTableProductFunc;

Obj             SCTableProductHandler (
    Obj                 self,
    Obj                 table,
    Obj                 list1,
    Obj                 list2 )
{
    Obj                 res;            /* result list                     */
    Obj                 row;            /* one row of sc table             */
    Obj                 zero;           /* zero from sc table              */
    Obj                 ai, aj;         /* elements from list1             */
    Obj                 bi, bj;         /* elements from list2             */
    Obj                 c, c1, c2;      /* products of above               */
    Int                 dim;            /* dimension of vectorspace        */
    Int                 i, j;           /* loop variables                  */

    /* check the arguments a bit                                           */
    if ( ! IS_LIST(table) ) {
        table = ErrorReturnObj(
            "SCTableProduct: <table> must be a list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(table)].name), 0L,
            "you can return a list for <table>" );
        return SCTableProductHandler( self, table, list1, list2 );
    }
    dim = LEN_LIST(table) - 2;
    if ( dim <= 0 ) {
        table = ErrorReturnObj(
            "SCTableProduct: <table> must be a list with at least 3 element",
            0L, 0L,
            "you can return a list for <table>" );
        return SCTableProductHandler( self, table, list1, list2 );
    }
    zero = ELM_LIST( table, dim+2 );
    if ( ! IS_LIST(list1) || LEN_LIST(list1) != dim ) {
        list1 = ErrorReturnObj(
            "SCTableProduct: <list1> must be a list with %d elements",
            dim, 0L,
            "you can return a list for <list1>" );
        return SCTableProductHandler( self, table, list1, list2 );
    }
    if ( ! IS_LIST(list2) || LEN_LIST(list2) != dim ) {
        list2 = ErrorReturnObj(
            "SCTableProduct: <list2> must be a list with %d elements",
            dim, 0L,
            "you can return a list for <list2>" );
        return SCTableProductHandler( self, table, list1, list2 );
    }

    /* make the result list                                                */
    res = NEW_PLIST( T_PLIST, dim );
    SET_LEN_PLIST( res, dim );
    for ( i = 1; i <= dim; i++ ) {
        SET_ELM_PLIST( res, i, zero );
    }
    CHANGED_BAG( res );

    /* general case                                                        */
    if      ( EQ( ELM_LIST( table, dim+1 ), INTOBJ_INT(0) ) ) {
        for ( i = 1; i <= dim; i++ ) {
            ai = ELM_LIST( list1, i );
            if ( EQ( ai, zero ) )  continue;
            row = ELM_LIST( table, i );
            for ( j = 1; j <= dim; j++ ) {
                bj = ELM_LIST( list2, j );
                if ( EQ( bj, zero ) )  continue;
                c = PROD( ai, bj );
                if ( ! EQ( c, zero ) ) {
                    SCTableProdAdd( res, c, ELM_LIST( row, j ), dim );
                }
            }
        }
    }

    /* commutative case                                                    */
    else if ( EQ( ELM_LIST( table, dim+1 ), INTOBJ_INT(1) ) ) {
        for ( i = 1; i <= dim; i++ ) {
            ai = ELM_LIST( list1, i );
            bi = ELM_LIST( list2, i );
            if ( EQ( ai, zero ) && EQ( bi, zero ) )  continue;
            row = ELM_LIST( table, i );
            c = PROD( ai, bi );
            if ( ! EQ( c, zero ) ) {
                SCTableProdAdd( res, c, ELM_LIST( row, i ), dim );
            }
            for ( j = i+1; j <= dim; j++ ) {
                bj = ELM_LIST( list2, j );
                aj = ELM_LIST( list1, j );
                if ( EQ( aj, zero ) && EQ( bj, zero ) )  continue;
                c1 = PROD( ai, bj );
                c2 = PROD( aj, bi );
                c = SUM( c1, c2 );
                if ( ! EQ( c, zero ) ) {
                    SCTableProdAdd( res, c, ELM_LIST( row, j ), dim );
                }
            }
        }
    }

    /* anticommutative case                                                */
    else if ( EQ( ELM_LIST( table, dim+1 ), INTOBJ_INT(-1) ) ) {
        for ( i = 1; i <= dim; i++ ) {
            ai = ELM_LIST( list1, i );
            bi = ELM_LIST( list2, i );
            if ( EQ( ai, zero ) && EQ( bi, zero ) )  continue;
            row = ELM_LIST( table, i );
            for ( j = i+1; j <= dim; j++ ) {
                bj = ELM_LIST( list2, j );
                aj = ELM_LIST( list1, j ); 
                if ( EQ( aj, zero ) && EQ( bj, zero ) )  continue;
                c1 = PROD( ai, bj );
                c2 = PROD( aj, bi );
                c = DIFF( c1, c2 );
                if ( ! EQ( c, zero ) ) {
                    SCTableProdAdd( res, c, ELM_LIST( row, j ), dim );
                }
            }
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*F  InitSCTable() . . . . . . . . . . .  initialize structure constant tables
**
**  Is called  during the initialization  of GAP to initialize  the structure
**  constant table package.
*/
void            InitSCTable ( void )
{
    InitHandlerFunc( SCTableEntryHandler, "SC_TABLE_ENTRY" );
    SCTableEntryFunc = NewFunctionC(
        "SC_TABLE_ENTRY", 4L, "table,i,j,k", SCTableEntryHandler );
    AssGVar( GVarName( "SC_TABLE_ENTRY" ), SCTableEntryFunc );
    InitHandlerFunc( SCTableProductHandler, "SC_TABLE_PRODUCT" );
    SCTableProductFunc = NewFunctionC(
        "SC_TABLE_PRODUCT", 3L, "table,list1,list2", SCTableProductHandler );
    AssGVar( GVarName( "SC_TABLE_PRODUCT" ), SCTableProductFunc );
}


/****************************************************************************
**
*E  sctable.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



