/****************************************************************************
**
*W  listoper.c                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains  the functions of the  package with the operations for
**  generic lists.
*/
char *          Revision_listoper_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* NewFunctionC                    */

#include        "ariths.h"              /* generic operations package      */
#include        "lists.h"               /* XType, LEN_LIST, ELM_LIST,  ... */

#include        "bool.h"                /* True, False                     */

#include        "integer.h"             /* TypDigit                        */

#define INCLUDE_DECLARATION_PART
#include        "listoper.h"            /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "plist.h"               /* LEN_PLIST, SET_LEN_PLIST,   ... */

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*F  EqListList(<listL>,<listR>) . . . . . . . . . test if two lists are equal
**
**  'EqListList' returns  'true' if  the  two lists <listL> and  <listR>  are
**  equal and 'false' otherwise.  This is a generic function, which works for
**  all types of lists.
*/
Int             EqListList (
    Obj                 listL,
    Obj                 listR )
{
    Int                 lenL;           /* length of the left operand      */
    Int                 lenR;           /* length of the right operand     */
    Obj                 elmL;           /* element of the left operand     */
    Obj                 elmR;           /* element of the right operand    */
    Int                 i;              /* loop variable                   */

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_LIST( listL );
    lenR = LEN_LIST( listR );
    if ( lenL != lenR ) {
        return 0L;
    }

    /* loop over the elements and compare them                             */
    for ( i = 1; i <= lenL; i++ ) {
        elmL = ELMV0_LIST( listL, i );
        elmR = ELMV0_LIST( listR, i );
        if ( elmL == 0 && elmR != 0 ) {
            return 0L;
        }
        else if ( elmR == 0 && elmL != 0 ) {
            return 0L;
        }
        else if ( ! EQ( elmL, elmR ) ) {
            return 0L;
        }
    }

    /* no differences found, the lists are equal                           */
    return 1L;
}

Obj             EqListListFunc;

Obj             EqListListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return (EqListList( listL, listR ) ? True : False);
}


/****************************************************************************
**
*F  LtListList(<listL>,<listR>) . . . . . . . . . test if two lists are equal
**
**  'LtListList' returns 'true' if  the list <listL>   is less than the  list
**  <listR> and 'false'  otherwise.  This is a  generic function, which works
**  for all types of lists.
*/
Int             LtListList (
    Obj                 listL,
    Obj                 listR )
{
    Int                 lenL;           /* length of the left operand      */
    Int                 lenR;           /* length of the right operand     */
    Obj                 elmL;           /* element of the left operand     */
    Obj                 elmR;           /* element of the right operand    */
    Int                 i;              /* loop variable                   */

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_LIST( listL );
    lenR = LEN_LIST( listR );

    /* loop over the elements and compare them                             */
    for ( i = 1; i <= lenL && i <= lenR; i++ ) {
        elmL = ELMV0_LIST( listL, i );
        elmR = ELMV0_LIST( listR, i );
        if ( elmL == 0 && elmR != 0 ) {
            return 1L;
        }
        else if ( elmR == 0 && elmL != 0 ) {
            return 0L;
        }
        else if ( ! EQ( elmL, elmR ) ) {
            return LT( elmL, elmR );
        }
    }

    /* reached the end of at least one list                                */
    return (lenL < lenR);
}

Obj             LtListListFunc;

Obj             LtListListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return (LtListList( listL, listR ) ? True : False);
}


/****************************************************************************
**
*F  InList(<objL>,<listR>)  . . . . . . . . . . . . membership test for lists
**
**  'InList' returns a   nonzero value if  <objL>  is a  member of  the  list
**  <listR>, and zero otherwise.
*/
Int             InList (
    Obj                 objL,
    Obj                 listR )
{
    return POS_LIST( listR, objL, 0L );
}

Obj             InListDefaultFunc;

Obj             InListDefaultHandler (
    Obj                 self,
    Obj                 obj,
    Obj                 list )
{
    return (InList( obj, list ) ? True : False);
}


/****************************************************************************
**
*F  SumList(<listL>,<listR>)  . . . . . . . . . . . . . . . . .  sum of lists
*F  SumSclList(<listL>,<listR>) . . . . . . . . .  sum of a scalar and a list
*F  SumListScl(<listL>,<listR>) . . . . . . . . .  sum of a list and a scalar
*F  SumListList(<listL>,<listR>)  . . . . . . . . . . . . .  sum of two lists
**
**  'SumList' is the extended dispatcher for the  sums involving lists.  That
**  is, whenever  two operands are  added and at  least one operand is a list
**  and 'SumFuncs'  does not point to  a special  function, then 'SumList' is
**  called.  'SumList' determines the extended  types of the operands  (e.g.,
**  'T_INT', 'T_VECTOR',  'T_MATRIX', 'T_LISTX') and then  dispatches through
**  'SumFuncs' again.
**
**  'SumSclList' is a generic function  for the first kind  of sum, that of a
**  scalar and a list.
**
**  'SumListScl' is a generic function for the second  kind of sum, that of a
**  list and a scalar.
**
**  'SumListList' is a generic  function for the third kind  of sum,  that of
**  two lists.
*/
Obj             SumList (
    Obj                 listL,
    Obj                 listR )
{
    return (*SumFuncs[XType(listL)][XType(listR)])( listL, listR );
}

Obj             SumSclList (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listS;          /* sum, result                     */
    Obj                 elmS;           /* one element of sum list         */
    Obj                 elmR;           /* one element of right operand    */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_LIST( listR );
    listS = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( listS, len );

    /* loop over the entries and add                                       */
    for ( i = 1; i <= len; i++ ) {
        elmR = ELMV_LIST( listR, i );
        elmS = SUM( listL, elmR );
        SET_ELM_PLIST( listS, i, elmS );
        CHANGED_BAG( listS );
    }

    /* return the result                                                   */
    return listS;
}

Obj             SumListScl (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listS;          /* sum, result                     */
    Obj                 elmS;           /* one element of sum list         */
    Obj                 elmL;           /* one element of left operand     */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_LIST( listL );
    listS = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( listS, len );

    /* loop over the entries and add                                       */
    for ( i = 1; i <= len; i++ ) {
        elmL = ELMV_LIST( listL, i );
        elmS = SUM( elmL, listR );
        SET_ELM_PLIST( listS, i, elmS );
        CHANGED_BAG( listS );
    }

    /* return the result                                                   */
    return listS;
}

Obj             SumListList (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listS;          /* sum, result                     */
    Obj                 elmS;           /* one element of the sum          */
    Obj                 elmL;           /* one element of the left list    */
    Obj                 elmR;           /* one element of the right list   */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* get and check the length                                            */
    len = LEN_LIST( listL );
    if ( len != LEN_LIST( listR ) ) {
        listR = ErrorReturnObj(
            "Vector +: <right> must have the same length as <left> (%d)",
            (Int)LEN_LIST(listR), 0L,
            "you can return a new list for <right>" );
        return SUM( listL, listR );
    }
    listS = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( listS, len );

    /* loop over the entries and add                                       */
    for ( i = 1; i <= len; i++ ) {
        elmL = ELMV_LIST( listL, i );
        elmR = ELMV_LIST( listR, i );
        elmS = SUM( elmL, elmR );
        SET_ELM_PLIST( listS, i, elmS );
        CHANGED_BAG( listS );
    }

    /* return the result                                                   */
    return listS;
}

Obj             SumSclListFunc;

Obj             SumSclListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return SumSclList( listL, listR );
}

Obj             SumListSclFunc;

Obj             SumListSclHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return SumListScl( listL, listR );
}

Obj             SumListListFunc;

Obj             SumListListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return SumListList( listL, listR );
}


/****************************************************************************
**
*F  ZeroList(<list>)  . . . . . . . . . . . . . . . . . . . .  zero of a list
*F  ZeroListDefault(<list>) . . . . . . . . . . . . . . . . .  zero of a list
**
**  'ZeroList' is the extended dispatcher for the zero involving lists.  That
**  is, whenever zero for a list is called and  'ZeroFuncs' does not point to
**  a special function, then 'ZeroList' is called.  'ZeroList' determines the
**  extended   type of the  operand  and then  dispatches through 'ZeroFuncs'
**  again.
**
**  'ZeroListDefault' is a generic function for the zero.
*/
Obj             ZeroList (
    Obj                 list )
{
    return (*ZeroFuncs[XType(list)])( list );
}

Obj             ZeroListDefault (
    Obj                 list )
{
    Obj                 res;
    Obj                 elm;
    Int                 len;
    Int                 i;

    /* make the result list                                                */
    len = LEN_LIST( list );
    res = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( res, len );

    /* enter zeroes everywhere                                             */
    if ( len != 0 ) {
        elm = ZERO( ELM_LIST( list, 1 ) );
        for ( i = 1; i <= len; i++ ) {
            SET_ELM_PLIST( res, i, elm );
            CHANGED_BAG( res );
        }
    }

    /* return the result                                                   */
    return res;
}

Obj             ZeroListDefaultFunc;

Obj             ZeroListDefaultHandler (
    Obj                 self,
    Obj                 list )
{
    return ZeroListDefault( list );
}


/****************************************************************************
**
*F  AInvList(<list>)  . . . . . . . . . . . . . .  additive inverse of a list
*F  AInvListDefault(<list>) . . . . . . . . . . .  additive inverse of a list
**
**  'AInvList' is the extended dispatcher for  the additive inverse involving
**  lists.  That is, whenever  the additive inverse for  lists is called  and
**  'AInvFuncs' does not   point to a   special function, then  'AInvList' is
**  called.  'AInvList' determines the extended  type of the operand and then
**  dispatches through 'AInvFuncs' again.
**
**  'AInvListDefault' is a generic function for the additive inverse.
*/
Obj             AInvList (
    Obj                 list )
{
    return (*AInvFuncs[XType(list)])( list );
}

Obj             AInvListDefault (
    Obj                 list )
{
    Obj                 res;
    Obj                 elm;
    Int                 len;
    Int                 i;

    /* make the result list                                                */
    len = LEN_LIST( list );
    res = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( res, len );

    /* enter the additive inverses everywhere                              */
    for ( i = 1; i <= len; i++ ) {
        elm = ELM_PLIST( list, i );
        elm = AINV( elm );
        SET_ELM_PLIST( res, i, elm );
        CHANGED_BAG( res );
    }

    /* return the result                                                   */
    return res;
}

Obj             AInvListDefaultFunc;

Obj             AInvListDefaultHandler (
    Obj                 self,
    Obj                 list )
{
    return AInvListDefault( list );
}


/****************************************************************************
**
*F  DiffList(<listL>,<listR>) . . . . . . . . . . . . . . difference of lists
*F  DiffSclList(<listL>,<listR>)  . . . . . difference of a scalar and a list
*F  DiffListScl(<listL>,<listR>)  . . . . . difference of a list and a scalar
*F  DiffListList(<listL>,<listR>) . . . . . . . . . . difference of two lists
**
**  'DiffList' is  the   extended dispatcher for   the  differences involving
**  lists.  That  is, whenever two operands are  subtracted and at  least one
**  operand is a list and  'DiffFuncs' does not  point to a special function,
**  then 'DiffList' is called.   'DiffList' determines the extended  types of
**  the operands (e.g.,  'T_INT', 'T_VECTOR', 'T_MATRIX', 'T_LISTX') and then
**  dispatches through 'DiffFuncs' again.
**
**  'DiffSclList' is a  generic function  for  the first  kind of difference,
**  that of a scalar and a list.
**
**  'DiffListScl'  is a generic function for the  second kind of  difference,
**  that of a list and a scalar.
**
**  'DiffListList' is  a generic function for the  third  kind of difference,
**  that of two lists.
*/
Obj             DiffList (
    Obj                 listL,
    Obj                 listR )
{
    return (*DiffFuncs[XType(listL)][XType(listR)])( listL, listR );
}

Obj             DiffSclList (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listD;          /* difference, result              */
    Obj                 elmD;           /* one element of difference list  */
    Obj                 elmR;           /* one element of right operand    */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_LIST( listR );
    listD = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( listD, len );

    /* loop over the entries and subtract                                  */
    for ( i = 1; i <= len; i++ ) {
        elmR = ELMV_LIST( listR, i );
        elmD = DIFF( listL, elmR );
        SET_ELM_PLIST( listD, i, elmD );
        CHANGED_BAG( listD );
    }

    /* return the result                                                   */
    return listD;
}

Obj             DiffListScl (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listD;          /* difference, result              */
    Obj                 elmD;           /* one element of difference list  */
    Obj                 elmL;           /* one element of left operand     */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_LIST( listL );
    listD = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( listD, len );

    /* loop over the entries and subtract                                  */
    for ( i = 1; i <= len; i++ ) {
        elmL = ELMV_LIST( listL, i );
        elmD = DIFF( elmL, listR );
        SET_ELM_PLIST( listD, i, elmD );
        CHANGED_BAG( listD );
    }

    /* return the result                                                   */
    return listD;
}

Obj             DiffListList (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listD;          /* difference, result              */
    Obj                 elmD;           /* one element of the difference   */
    Obj                 elmL;           /* one element of the left list    */
    Obj                 elmR;           /* one element of the right list   */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* get and check the length                                            */
    len = LEN_LIST( listL );
    if ( len != LEN_LIST( listR ) ) {
        listR = ErrorReturnObj(
            "Vector -: <right> must have the same length as <left> (%d)",
            (Int)LEN_LIST(listR), 0L,
            "you can return a new list for <right>" );
        return DIFF( listL, listR );
    }
    listD = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( listD, len );

    /* loop over the entries and subtract                                  */
    for ( i = 1; i <= len; i++ ) {
        elmL = ELMV_LIST( listL, i );
        elmR = ELMV_LIST( listR, i );
        elmD = DIFF( elmL, elmR );
        SET_ELM_PLIST( listD, i, elmD );
        CHANGED_BAG( listD );
    }

    /* return the result                                                   */
    return listD;
}

Obj             DiffSclListFunc;

Obj             DiffSclListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return DiffSclList( listL, listR );
}

Obj             DiffListSclFunc;

Obj             DiffListSclHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return DiffListScl( listL, listR );
}

Obj             DiffListListFunc;

Obj             DiffListListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return DiffListList( listL, listR );
}


/****************************************************************************
**
*F  ProdList(<listL>,<listR>) . . . . . . . . . . . . . . .  product of lists
*F  ProdSclList(<listL>,<listR>)  . . . . . .  product of a scalar and a list
*F  ProdListScl(<listL>,<listR>)  . . . . . .  product of a list and a scalar
*F  ProdListList(<listL>,<listR>) . . . . . . . . . . .  product of two lists
**
**  'ProdList' is the extended  dispatcher for the products  involving lists.
**  That is, whenever two operands are multiplied and at least one operand is
**  a list   and  'ProdFuncs' does not    point to a  special function,  then
**  'ProdList' is called.  'ProdList'   determines the extended types  of the
**  operands (e.g.,   'T_INT',  'T_VECTOR', 'T_MATRIX',  'T_LISTX')  and then
**  dispatches through 'ProdFuncs' again.
**
**  'ProdSclList' is a generic  function for the first  kind of product, that
**  of a scalar and a list.  Note that this  includes kind of product defines
**  the product of a matrix with a list of matrices.
**
**  'ProdListScl' is a generic function for the  second kind of product, that
**  of a  list  and a  scalar.  Note that   this kind of  product defines the
**  product of a  matrix with a vector, the  product of two matrices, and the
**  product of a list of matrices and a matrix.
**
**  'ProdListList' is a generic function for the third  kind of product, that
**  of two lists.  Note that this kind of product  defines the product of two
**  vectors, a vector and a matrix, and the product of a vector and a list of
**  matrices.
*/
Obj             ProdList (
    Obj                 listL,
    Obj                 listR )
{
    return (*ProdFuncs[XType(listL)][XType(listR)])( listL, listR );
}

Obj             ProdSclList (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listP;          /* product, result                 */
    Obj                 elmP;           /* one element of product list     */
    Obj                 elmR;           /* one element of right operand    */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_LIST( listR );
    listP = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( listP, len );

    /* loop over the entries and multiply                                  */
    for ( i = 1; i <= len; i++ ) {
        elmR = ELMV_LIST( listR, i );
        elmP = PROD( listL, elmR );
        SET_ELM_PLIST( listP, i, elmP );
        CHANGED_BAG( listP );
    }

    /* return the result                                                   */
    return listP;
}

Obj             ProdListScl (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listP;          /* product, result                 */
    Obj                 elmP;           /* one element of product list     */
    Obj                 elmL;           /* one element of left operand     */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_LIST( listL );
    listP = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( listP, len );

    /* loop over the entries and multiply                                  */
    for ( i = 1; i <= len; i++ ) {
        elmL = ELMV_LIST( listL, i );
        elmP = PROD( elmL, listR );
        SET_ELM_PLIST( listP, i, elmP );
        CHANGED_BAG( listP );
    }

    /* return the result                                                   */
    return listP;
}

Obj             ProdListList (
    Obj                 listL,
    Obj                 listR )
{
    Obj                 listP;          /* product, result                 */
    Obj                 elmP;           /* one summand of the product      */
    Obj                 elmL;           /* one element of the left list    */
    Obj                 elmR;           /* one element of the right list   */
    Int                 len;            /* length                          */
    Int                 i;              /* loop variable                   */

    /* get and check the length                                            */
    len = LEN_LIST( listL );
    if ( len != LEN_LIST( listR ) ) {
        listR = ErrorReturnObj(
            "Vector *: <right> must have the same length as <left> (%d)",
            (Int)LEN_LIST(listR), 0L,
            "you can return a new list for <right>" );
        return PROD( listL, listR );
    }

    /* loop over the entries and multiply and accumulate                   */
    elmL = ELMV_LIST( listL, 1 );
    elmR = ELMV_LIST( listR, 1 );
    listP  = PROD( elmL, elmR );
    for ( i = 2; i <= len; i++ ) {
        elmL = ELMV_LIST( listL, i );
        elmR = ELMV_LIST( listR, i );
        elmP = PROD( elmL, elmR );
        listP = SUM( listP, elmP );
    }

    /* return the result                                                   */
    return listP;
}

Obj             ProdSclListFunc;

Obj             ProdSclListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return ProdSclList( listL, listR );
}

Obj             ProdListSclFunc;

Obj             ProdListSclHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return ProdListScl( listL, listR );
}

Obj             ProdListListFunc;

Obj             ProdListListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return ProdListList( listL, listR );
}


/****************************************************************************
**
*F  OneList(<list>) . . . . . . . . . . . . . . . . . . . . . . one of a list
*F  OneMatrix(<list>) . . . . . . . . . . . . . . . . . . . . . one of a list
**
**  'OneList' is  the extended dispatcher for  the one involving lists.  That
**  is, whenever one for a list is called and  'OneFuncs' does not point to a
**  special  function, then 'OneList'  is  called.  'OneList' determines  the
**  extended type of  the  operand and   then dispatches  through  'OneFuncs'
**  again.
**
**  'OneMatrix' is a generic function for the one.
*/
Obj             OneList (
    Obj                 list )
{
    return (*OneFuncs[XType(list)])( list );
}

Obj             OneMatrix (
    Obj                 mat )
{
    Obj                 res = 0;        /* one, result                     */
    Obj                 row;            /* one row of the result           */
    Obj                 zero;           /* zero element                    */
    Obj                 one;            /* one element                     */
    UInt                len;            /* length (and width) of matrix    */
    UInt                i, k;           /* loop variables                  */

    /* check that the operand is a *square* matrix                         */
    len = LEN_LIST( mat );
    if ( len != LEN_LIST( ELM_LIST( mat, 1 ) ) ) {
        return ErrorReturnObj(
            "Matrix ONE: <mat> must be square (not %d by %d)",
            (Int)len, (Int)LEN_LIST( ELM_LIST( mat, 1 ) ),
            "you can return a one matrix for <mat>" );
    }

    /* get the zero and the one                                            */
    zero = ZERO( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
    one  = ONE( zero );

    /* make the identity matrix                                            */
    res = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( res, len );
    for ( i = 1; i <= len; i++ ) {
        row = NEW_PLIST( T_PLIST, len );
        SET_LEN_PLIST( row, len );
        for ( k = 1; k <= len; k++ )
            SET_ELM_PLIST( row, k, zero );
        SET_ELM_PLIST( row, i, one );
        SET_ELM_PLIST( res, i, row );
        CHANGED_BAG( res );
    }

    /* return the identity matrix                                          */
    return res;
}

Obj             OneMatrixFunc;

Obj             OneMatrixHandler (
    Obj                 self,
    Obj                 list )
{
    return OneMatrix( list );
}


/****************************************************************************
**
*F  InvList(<list>) . . . . . . . . . . . . . . . . . . . . inverse of a list
*F  InvMatrix(<list>) . . . . . . . . . . . . . . . . . . . inverse of a list
**
**  'InvList' is the extended dispatcher for  inverses involving lists.  That
**  is, whenever inverse for a list  is called and  'InvFuncs' does not point
**  to  a special function,  then 'InvList'  is called.  'InvList' determines
**  the  extended type of the  operand and then  dispatches through 'InvList'
**  again.
**
**  'InvMatrix' is a generic function for the inverse.
*/
Obj             InvList (
    Obj                 list )
{
    return (*InvFuncs[XType(list)])( list );
}

Obj             InvMatrix (
    Obj                 mat )
{
    Obj                 res = 0;        /* power, result                   */
    Obj                 row;            /* one row of the matrix           */
    Obj                 row2;           /* another row of the matrix       */
    Obj                 elm;            /* one element of the matrix       */
    Obj                 elm2;           /* another element of the matrix   */
    Obj                 zero;           /* zero element                    */
    Obj                 one;            /* one element                     */
    UInt                len;            /* length (and width) of matrix    */
    UInt                i, k, l;        /* loop variables                  */

    /* check that the operand is a *square* matrix                         */
    len = LEN_LIST( mat );
    if ( len != LEN_LIST( ELM_LIST( mat, 1 ) ) ) {
        return ErrorReturnObj(
            "Matrix INV: <mat> must be square (not %d by %d)",
            (Int)len, (Int)LEN_LIST( ELM_LIST( mat, 1 ) ),
            "you can return an inverse matrix for <mat>" );
    }

    /* get the zero and the one                                            */
    zero = ZERO( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
    one  = ONE( zero );

    /* make a matrix of the form $ ( Id_<len> | <mat> ) $                  */
    res = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( res, len );
    for ( i = 1; i <= len; i++ ) {
        row = NEW_PLIST( T_PLIST, 2 * len );
        SET_LEN_PLIST( row, 2 * len );
        SET_ELM_PLIST( res, i, row );
        CHANGED_BAG( res );
    }
    for ( i = 1; i <= len; i++ ) {
        row = ELM_PLIST( res, i );
        for ( k = 1; k <= len; k++ )
            SET_ELM_PLIST( row, k, zero );
        SET_ELM_PLIST( row, i, one );
    }
    for ( i = 1; i <= len; i++ ) {
        row = ELM_PLIST( res, i );
        row2 = ELM_LIST( mat, i );
        for ( k = 1; k <= len; k++ ) {
            SET_ELM_PLIST( row, k + len, ELM_LIST( row2, k )  );
            CHANGED_BAG( row );
        }
    }

    /* make row operations to reach form $ ( <inv> | Id_<len> ) $          */
    /* loop over the columns of <mat>                                      */
    for ( k = len+1; k <= 2*len; k++ ) {

        /* find a nonzero entry in this column                             */
        for ( i = k-len; i <= len; i++ ) {
            if ( ! EQ( ELM_PLIST( ELM_PLIST(res,i), k ), zero ) )
               break;
        }
        if ( len < i ) {
            return Fail;
        }

        /* make the row the <k>-th row and normalize it                    */
        row = ELM_PLIST( res, i );
        SET_ELM_PLIST( res, i, ELM_PLIST( res, k-len ) );
        SET_ELM_PLIST( res, k-len, row );
        elm2 = INV( ELM_PLIST( row, k ) );
        for ( l = 1; l <= 2*len; l++ ) {
            elm = PROD( elm2, ELM_PLIST( row, l ) );
            SET_ELM_PLIST( row, l, elm );
            CHANGED_BAG( row );
        }

        /* clear all entries in this column                                */
        for ( i = 1; i <= len; i++ ) {
            row2 = ELM_PLIST( res, i );
            elm = AINV( ELM_PLIST( row2, k ) );
            if ( i != k-len && ! EQ(elm,zero) ) {
                for ( l = 1; l <= 2*len; l++ ) {
                    elm2 = PROD( elm, ELM_PLIST( row, l ) );
                    elm2 = SUM( ELM_PLIST( row2, l ), elm2 );
                    SET_ELM_PLIST( row2, l, elm2 );
                    CHANGED_BAG( row2 );
                }
            }
        }

    }

    /* throw away the right halves of each row                             */
    for ( i = 1; i <= len; i++ ) {
        SET_LEN_PLIST( ELM_PLIST( res, i ), len );
        SHRINK_PLIST(  ELM_PLIST( res, i ), len );
    }

    /* return the result                                                   */
    return res;
}

Obj             InvMatrixFunc;

Obj             InvMatrixHandler (
    Obj                 self,
    Obj                 list )
{
    return InvMatrix( list );
}


/****************************************************************************
**
*F  QuoList(<listL>,<listR>)  . . . . . . . . . . . . . . . quotient of lists
**
**  'QuoList' is the extended dispatcher  for the quotients involving  lists.
**  This  is, whenever two  operands are  divided and  at   least one  of the
**  operands is  a list and 'QuoFuncs' does  not point to a special function,
**  then 'QuoList' is called.  'QuoList' determines the extended types of the
**  operands (e.g.,   'T_INT', 'T_VECTOR',  'T_MATRIX',  'T_LISTX') and  then
**  dispatches through 'QuoFuncs' again.
*/
Obj             QuoList (
    Obj                 listL,
    Obj                 listR )
{
    return (*QuoFuncs[XType(listL)][XType(listR)])( listL, listR );
}


/****************************************************************************
**
*F  LQuoList(<listL>,<listR>) . . . . . . . . . . . .  left quotient of lists
**
**  'LQuoLists' is   the  extended dispatcher  for  left  quotients involving
**  lists.   This is,  whenever two operands   are  divided and at  least one
**  operand is a list and 'LQuoFuncs'  does not point  to a special function,
**  then 'LQuoList'  is called.  'LQuoList' determines  the extended types of
**  the operands (e.g., 'T_INT',  'T_VECTOR', 'T_MATRIX', 'T_LISTX') and then
**  dispatches through 'LQuoFuncs' again.
*/
Obj             LQuoList (
    Obj                 listL,
    Obj                 listR )
{
    return (*LQuoFuncs[XType(listL)][XType(listR)])( listL, listR );
}


/****************************************************************************
**
*F  PowList(<listL>,<listR>)  . . . . . . . . . . . . . . . .  power of lists
**
**  'PowList' is the extended dispatcher  for  powers involving lists.   That
**  is, whenever two operands  are  powered and at  least  one is a list  and
**  'PowFuncs' does not    point to a  special function,    then 'PowList' is
**  called.   'PowList' determines the  extended types of the operands (e.g.,
**  'T_INT', 'T_VECTOR', 'T_MATRIX',  'T_LISTX') and then  dispatches through
**  'PowFuncs' again.
**
**  'PowMatrixInt' is a specialization   of 'PowObjInt', which  avoids  going
**  through the extended dispatchers again and again.
**
*N  1996/08/28 M.Schoenert is this function really worth the trouble?
*/
Obj             PowList (
    Obj                 listL,
    Obj                 listR )
{
    return (*PowFuncs[XType(listL)][XType(listR)])( listL, listR );
}

Obj             PowMatrixInt (
    Obj                 mat,
    Obj                 n )
{
    Obj                 res = 0;        /* result                          */
    UInt                i, k, l;        /* loop variables                  */

    /* if the integer is zero, return the neutral element of the operand   */
    if      ( TYPE_OBJ(n) == T_INT && INT_INTOBJ(n) ==  0 ) {
        res = OneMatrix( mat );
    }

    /* if the integer is one, return a copy of the operand                 */
    else if ( TYPE_OBJ(n) == T_INT && INT_INTOBJ(n) ==  1 ) {
        res = CopyObj( mat, 0 );
    }

    /* if the integer is minus one, return the inverse of the operand      */
    else if ( TYPE_OBJ(n) == T_INT && INT_INTOBJ(n) == -1 ) {
        res = InvMatrix( mat );
    }

    /* if the integer is negative, invert the operand and the integer      */
    else if ( TYPE_OBJ(n) == T_INT && INT_INTOBJ(n) <  -1 ) {
        res = InvMatrix( mat );
        if ( res == Fail ) {
            return ErrorReturnObj(
                "Operations: <mat> must have an inverse",
                0L, 0L,
                "you can return an inverse for <mat>" );
        }
        res = PowMatrixInt( res, AINV( n ) );
    }

    /* if the integer is negative, invert the operand and the integer      */
    else if ( TYPE_OBJ(n) == T_INTNEG ) {
        res = InvMatrix( mat );
        if ( res == Fail ) {
            return ErrorReturnObj(
                "Operations: <mat> must have an inverse",
                0L, 0L,
                "you can return an inverse for <mat>" );
        }
        res = PowMatrixInt( res, AINV( n ) );
    }

    /* if the integer is small, compute the power by repeated squaring     */
    /* the loop invariant is <result> = <res>^<k> * <op>^<l>, <l> < <k>    */
    /* <res> = 0 means that <res> is the neutral element                   */
    else if ( TYPE_OBJ(n) == T_INT && INT_INTOBJ(n) >   1 ) {
        res = 0;
        k = 1L << 31;
        l = INT_INTOBJ(n);
        while ( 1 < k ) {
            res = (res == 0 ? res : ProdListScl( res, res ));
            k = k / 2;
            if ( k <= l ) {
                res = (res == 0 ? mat : ProdListScl( res, mat ));
                l = l - k;
            }
        }
    }

    /* if the integer is large, compute the power by repeated squaring     */
    else if ( TYPE_OBJ(n) == T_INTPOS ) {
        res = 0;
        for ( i = SIZE_OBJ(n)/sizeof(TypDigit); 0 < i; i-- ) {
            k = 1L << (8*sizeof(TypDigit));
            l = ((TypDigit*) ADDR_OBJ(n))[i-1];
            while ( 1 < k ) {
                res = (res == 0 ? res : ProdListScl( res, res ));
                k = k / 2;
                if ( k <= l ) {
                    res = (res == 0 ? mat : ProdListScl( res, mat ));
                    l = l - k;
                }
            }
        }
    }

    /* return the result                                                   */
    return res;
}

Obj             PowMatrixIntFunc;

Obj             PowMatrixIntHandler (
    Obj                 self,
    Obj                 opL,
    Obj                 opR )
{
    return PowMatrixInt( opL, opR );
}


/****************************************************************************
**
*F  CommList(<listL>,<listR>) . . . . . . . . . . . . . . commutator of lists
**
**  'CommList' is  the extended dispatcher   for commutators involving lists.
**  That is, whenever two operands are commutated and at least one operand is
**  a  list  and  'CommFuncs' does not  point   to a  special  function, then
**  'CommList'  is called.  'CommList' determines the   extended types of the
**  operands  (e.g., 'T_INT',  'T_VECTOR',  'T_MATRIX', 'T_LISTX')  and  then
**  dispatches through 'CommFuncs' again.
*/
Obj             CommList (
    Obj                 listL,
    Obj                 listR )
{
    return (*CommFuncs[XType(listL)][XType(listR)])( listL, listR );
}


/****************************************************************************
**

*F  InitListOper()  . . . . . . . . . . .  initialize generic list operations
**
**  'InitListOper' initializes the generic list operations.
**
**  C = constant, R = record, L = list,   X = extrnl, V = virtual
**
**  s = scalar, v = vector, m = matrix, e = empty,  - = nothing
**  i = incomplete type (call 'XType' and try again), ] = end marker
**
** 0    0    1    1    2    2    3    3    4    4    5    5    6    6
** 0    5    0    5    0    5    0    5    0    5    0    5    0    5
** CCCCCCCCCCCCRRLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLXXXVVV
*/
Char * CAT =
  "ssssssss----ssiiiiiiiieeiiiiiiiiiiiivvvvvvvvvvvvvvvv----------------mm]";

void InitListOper ( void )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    /* check that <CAT> is consistent with the number LAST_VIRTUAL_TYPE    */
    if ( CAT[LAST_VIRTUAL_TYPE+1] != ']' ) {
	SyFputs( "panic: <CAT> in file \"listoper.c\" is corrupted\n", 1 );
	exit(0);
    }

    /* install the generic comparisons                                     */
    for ( t1 = FIRST_LIST_TYPE; t1 <= LAST_LIST_TYPE; t1++ ) {
        for ( t2 = FIRST_LIST_TYPE; t2 <= LAST_LIST_TYPE; t2++ ) {
            EqFuncs[ t1 ][ t2 ] = EqListList;
        }
    }
    for ( t1 = FIRST_LIST_TYPE; t1 <= LAST_LIST_TYPE; t1++ ) {
        for ( t2 = FIRST_LIST_TYPE; t2 <= LAST_LIST_TYPE; t2++ ) {
            LtFuncs[ t1 ][ t2 ] = LtListList;
        }
    }
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_LIST_TYPE; t1++ ) {
        for ( t2 = FIRST_LIST_TYPE; t2 <= LAST_LIST_TYPE; t2++ ) {
            InFuncs[ t1 ][ t2 ] = InList;
        }
    }

    /* install generic methods for list operations                         */
    for ( t1 = FIRST_REAL_TYPE; t1 <= LAST_VIRTUAL_TYPE; t1++ ) {

        if ( CAT[t1] == '-' )
            continue;

        if      ( CAT[t1] == 'i' )
            ZeroFuncs[t1] = ZeroList;
        else if ( CAT[t1] != 's' )
            ZeroFuncs[t1] = ZeroListDefault;

        if      ( CAT[t1] == 'i' )
            AInvFuncs[t1] = AInvList;
        else if ( CAT[t1] != 's' )
            AInvFuncs[t1] = AInvListDefault;

        if      ( CAT[t1] == 'i' )
            OneFuncs [t1] = OneList;
        else if ( CAT[t1] == 'm' )
            OneFuncs [t1] = OneMatrix;

        if      ( CAT[t1] == 'i' )
            InvFuncs [t1] = InvList;
        else if ( CAT[t1] == 'm' )
            InvFuncs [t1] = InvMatrix;

        if      ( CAT[t1] == 'm' ) {
            PowFuncs [t1][T_INT   ] = PowMatrixInt;
            PowFuncs [t1][T_INTPOS] = PowMatrixInt;
            PowFuncs [t1][T_INTNEG] = PowMatrixInt;
        }

        for ( t2 = FIRST_REAL_TYPE; t2 <= LAST_VIRTUAL_TYPE; t2++ ){

            if      ( CAT[t1] == '-' || CAT[t2] == '-' )
                continue;

            if      ( CAT[t1] == 'i' || CAT[t2] == 'i' )
                SumFuncs [t1][t2] = SumList;
            else if ( CAT[t1] != 's' && CAT[t2] == 's' )
                SumFuncs [t1][t2] = SumListScl;
            else if ( CAT[t1] == 's' && CAT[t2] != 's' )
                SumFuncs [t1][t2] = SumSclList;
            else if ( CAT[t1] == 'v' && CAT[t2] == 'v' )
                SumFuncs [t1][t2] = SumListList;
            else if ( CAT[t1] == 'e' && CAT[t2] == 'e' )
                SumFuncs [t1][t2] = SumListList;
            else if ( CAT[t1] == 'm' && CAT[t2] == 'm' )
                SumFuncs [t1][t2] = SumListList;

            if      ( CAT[t1] == 'i' || CAT[t2] == 'i' )
                DiffFuncs[t1][t2] = DiffList;
            else if ( CAT[t1] != 's' && CAT[t2] == 's' )
                DiffFuncs[t1][t2] = DiffListScl;
            else if ( CAT[t1] == 's' && CAT[t2] != 's' )
                DiffFuncs[t1][t2] = DiffSclList;
            else if ( CAT[t1] == 'v' && CAT[t2] == 'v' )
                DiffFuncs[t1][t2] = DiffListList;
            else if ( CAT[t1] == 'e' && CAT[t2] == 'e' )
                DiffFuncs[t1][t2] = DiffListList;
            else if ( CAT[t1] == 'm' && CAT[t2] == 'm' )
                DiffFuncs[t1][t2] = DiffListList;

            if      ( CAT[t1] == 'i' || CAT[t2] == 'i' )
                ProdFuncs[t1][t2] = ProdList;
            else if ( CAT[t1] != 's' && CAT[t2] == 's' )
                ProdFuncs[t1][t2] = ProdListScl;
            else if ( CAT[t1] == 's' && CAT[t2] != 's' )
                ProdFuncs[t1][t2] = ProdSclList;
            else if ( CAT[t1] == 'v'                   )
                ProdFuncs[t1][t2] = ProdListList;
            else if (                   CAT[t2] == 'm' )
                ProdFuncs[t1][t2] = ProdListScl;
            else if ( CAT[t1] == 'm' && CAT[t2] == 'v' )
                ProdFuncs[t1][t2] = ProdListScl;
            else if ( CAT[t1] == 'm' && CAT[t2] == 'e' )
                ProdFuncs[t1][t2] = ProdSclList;

            if      ( CAT[t1] == 'i' || CAT[t2] == 'i' )
                QuoFuncs [t1][t2] = QuoList;

            if      ( CAT[t1] == 'i' || CAT[t2] == 'i' )
                LQuoFuncs[t1][t2] = LQuoList;

            if      ( CAT[t1] == 'i' || CAT[t2] == 'i' )
                PowFuncs [t1][t2] = PowList;
            else if ( CAT[t1] == 'v' && CAT[t2] == 'm' )
                PowFuncs [t1][t2] = ProdListList;
            else if ( CAT[t1] == 'm' && CAT[t2] == 'm' )
                PowFuncs [t1][t2] = PowDefault;

            if      ( CAT[t1] == 'i' || CAT[t2] == 'i' )
                CommFuncs[t1][t2] = CommList;
            
        }
    }

    InitHandlerFunc( EqListListHandler, "EQ_LIST_LIST_DEFAULT");
    EqListListFunc = NewFunctionC(
        "EQ_LIST_LIST_DEFAULT", 2L, "listL, listR", EqListListHandler );
    AssGVar( GVarName( "EQ_LIST_LIST_DEFAULT" ), EqListListFunc );

    InitHandlerFunc( LtListListHandler, "LT_LIST_LIST_DEFAULT");
    LtListListFunc = NewFunctionC(
        "LT_LIST_LIST_DEFAULT", 2L, "listL, listR", LtListListHandler );
    AssGVar( GVarName( "LT_LIST_LIST_DEFAULT" ), LtListListFunc );

    InitHandlerFunc( InListDefaultHandler, "IN_LIST_DEFAULT");
    InListDefaultFunc = NewFunctionC(
        "IN_LIST_DEFAULT", 2L, "obj, list", InListDefaultHandler );
    AssGVar( GVarName( "IN_LIST_DEFAULT" ), InListDefaultFunc );

    InitHandlerFunc( SumSclListHandler, "SUM_SCL_LIST_DEFAULT");
    SumSclListFunc = NewFunctionC(
        "SUM_SCL_LIST_DEFAULT", 2L, "listL, listR", SumSclListHandler );
    AssGVar( GVarName( "SUM_SCL_LIST_DEFAULT" ), SumSclListFunc );

    InitHandlerFunc( SumListSclHandler, "SUM_LIST_SCL_DEFAULT");
    SumListSclFunc = NewFunctionC(
        "SUM_LIST_SCL_DEFAULT", 2L, "listL, listR", SumListSclHandler );
    AssGVar( GVarName( "SUM_LIST_SCL_DEFAULT" ), SumListSclFunc );

    InitHandlerFunc( SumListListHandler, "SUM_LIST_LIST_DEFAULT");
    SumListListFunc = NewFunctionC(
        "SUM_LIST_LIST_DEFAULT", 2L, "listL, listR", SumListListHandler );
    AssGVar( GVarName( "SUM_LIST_LIST_DEFAULT" ), SumListListFunc );

    InitHandlerFunc( ZeroListDefaultHandler, "ZERO_LIST_DEFAULT");
    ZeroListDefaultFunc = NewFunctionC(
        "ZERO_LIST_DEFAULT", 1L, "list", ZeroListDefaultHandler );
    AssGVar( GVarName( "ZERO_LIST_DEFAULT" ), ZeroListDefaultFunc );

    InitHandlerFunc( AInvListDefaultHandler, "AINV_LIST_DEFAULT");
    AInvListDefaultFunc = NewFunctionC(
        "AINV_LIST_DEFAULT", 1L, "list", AInvListDefaultHandler );
    AssGVar( GVarName( "AINV_LIST_DEFAULT" ), AInvListDefaultFunc );

    InitHandlerFunc( DiffSclListHandler, "DIFF_SCL_LIST_DEFAULT");
    DiffSclListFunc = NewFunctionC(
        "DIFF_SCL_LIST_DEFAULT", 2L, "listL, listR", DiffSclListHandler );
    AssGVar( GVarName( "DIFF_SCL_LIST_DEFAULT" ), DiffSclListFunc );

    InitHandlerFunc( DiffListSclHandler, "DIFF_LIST_SCL_DEFAULT");
    DiffListSclFunc = NewFunctionC(
        "DIFF_LIST_SCL_DEFAULT", 2L, "listL, listR", DiffListSclHandler );
    AssGVar( GVarName( "DIFF_LIST_SCL_DEFAULT" ), DiffListSclFunc );

    InitHandlerFunc( DiffListListHandler, "DIFF_LIST_LIST_DEFAULT");
    DiffListListFunc = NewFunctionC(
        "DIFF_LIST_LIST_DEFAULT", 2L, "listL, listR", DiffListListHandler );
    AssGVar( GVarName( "DIFF_LIST_LIST_DEFAULT" ), DiffListListFunc );

    InitHandlerFunc( ProdSclListHandler, "PROD_SCL_LIST_DEFAULT");
    ProdSclListFunc = NewFunctionC(
        "PROD_SCL_LIST_DEFAULT", 2L, "listL, listR", ProdSclListHandler );
    AssGVar( GVarName( "PROD_SCL_LIST_DEFAULT" ), ProdSclListFunc );

    InitHandlerFunc( ProdListSclHandler, "PROD_LIST_SCL_DEFAULT");
    ProdListSclFunc = NewFunctionC(
        "PROD_LIST_SCL_DEFAULT", 2L, "listL, listR", ProdListSclHandler );
    AssGVar( GVarName( "PROD_LIST_SCL_DEFAULT" ), ProdListSclFunc );

    InitHandlerFunc( ProdListListHandler, "PROD_LIST_LIST_DEFAULT");
    ProdListListFunc = NewFunctionC(
        "PROD_LIST_LIST_DEFAULT", 2L, "listL, listR", ProdListListHandler );
    AssGVar( GVarName( "PROD_LIST_LIST_DEFAULT" ), ProdListListFunc );

    InitHandlerFunc( OneMatrixHandler, "ONE_MATRIX");
    OneMatrixFunc = NewFunctionC(
        "ONE_MATRIX", 1L, "list", OneMatrixHandler );
    AssGVar( GVarName( "ONE_MATRIX" ), OneMatrixFunc );

    InitHandlerFunc( InvMatrixHandler, "INV_MATRIX");
    InvMatrixFunc = NewFunctionC(
        "INV_MATRIX", 1L, "list", InvMatrixHandler );
    AssGVar( GVarName( "INV_MATRIX" ), InvMatrixFunc );

    InitHandlerFunc( PowMatrixIntHandler, "POW_MATRIX_INT");
    InvMatrixFunc = NewFunctionC(
        "POW_MATRIX_INT", 2L, "list, int", PowMatrixIntHandler );
    AssGVar( GVarName( "POW_MATRIX_INT" ), PowMatrixIntFunc );
}


/****************************************************************************
**

*E  listoper.c 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
