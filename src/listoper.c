/****************************************************************************
**
*W  listoper.c                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file contains  the functions of the  package with the operations for
**  generic lists.
*/
#include        "system.h"              /* Ints, UInts                     */

const char * Revision_listoper_c =
   "@(#)$Id$";

#include        "sysfiles.h"            /* file input/output               */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */

#include        "ariths.h"              /* basic arithmetic                */

#include        "bool.h"                /* booleans                        */

#include        "integer.h"             /* integers                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#define INCLUDE_DECLARATION_PART
#include        "listoper.h"            /* operations for generic lists    */
#undef  INCLUDE_DECLARATION_PART
#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */
#include        "opers.h"               /* TRY_NEXT_METHOD                 */
#include        "range.h"               /* Ranges                          */


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
*F  SumListList<listL>,<listR>)  . . . . . . . . . . . . .  sum of two lists
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

#ifdef  XTNUMS
Obj             SumList (
    Obj                 listL,
    Obj                 listR )
{
    return (*SumFuncs[XTNum(listL)][XTNum(listR)])( listL, listR );
}

#endif

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
    listS = NEW_PLIST( IS_MUTABLE_OBJ(listR) ?
		       T_PLIST : (T_PLIST + IMMUTABLE), len );
    SET_LEN_PLIST( listS, len );

    /* loop over the entries and add                                       */
    for ( i = 1; i <= len; i++ ) {
        elmR = ELMV0_LIST( listR, i );
	if (elmR)
	  {
	    elmS = SUM( listL, elmR );
	    SET_ELM_PLIST( listS, i, elmS );
	    CHANGED_BAG( listS );
	  }
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
    listS = NEW_PLIST( IS_MUTABLE_OBJ(listL) ?
		       T_PLIST : T_PLIST+IMMUTABLE, len );
    SET_LEN_PLIST( listS, len );

    /* loop over the entries and add                                       */
    for ( i = 1; i <= len; i++ ) {
        elmL = ELMV0_LIST( listL, i );
	if (elmL)
	  {
	    elmS = SUM( elmL, listR );
	    SET_ELM_PLIST( listS, i, elmS );
	    CHANGED_BAG( listS );
	  }
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
    Int                 lenL,lenR, lenS;/* lengths                         */
    Int                 i;              /* loop variable                   */

    /* get and check the length                                            */
    lenL = LEN_LIST( listL );
#if 0
    if ( len != LEN_LIST( listR ) ) {
        listR = ErrorReturnObj(
            "Vector +: <right> must have the same length as <left> (%d)",
            (Int)LEN_LIST(listR), 0L,
            "you can replace list <right> via 'return <right>;'" );
        return SUM( listL, listR );
    }
#endif
    lenR = LEN_LIST( listR );
    lenS = (lenR > lenL) ? lenR : lenL;
    listS = NEW_PLIST( (IS_MUTABLE_OBJ(listL) || IS_MUTABLE_OBJ(listR)) ?
		       T_PLIST : T_PLIST+IMMUTABLE, lenS );
    SET_LEN_PLIST( listS, lenS );

    /* loop over the entries and add                                       */
    for ( i = 1; i <= lenS; i++ ) {
      elmL = ELM0_LIST( listL, i ) ;
      elmR = ELM0_LIST( listR, i ) ;
      elmS =  elmL ? (elmR ? SUM( elmL, elmR ) : elmL) : elmR;
      if (elmS)
	{
	  SET_ELM_PLIST( listS, i, elmS );
	  CHANGED_BAG( listS );
	}
    }

    /* return the result                                                   */
    return listS;
}

Obj             SumSclListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return SumSclList( listL, listR );
}

Obj             SumListSclHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return SumListScl( listL, listR );
}

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

#ifdef XTNUMS
Obj             ZeroList (
    Obj                 list )
{
    return (*ZeroFuncs[XTNum(list)])( list );
}
#endif


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
    /* For now, lets just do the simplest and safest thing */
    for (i = 1; i <= len; i++ )
      {
	Obj tmp = ELM0_LIST( list, i);
	if (tmp) {
	  tmp = ZERO(tmp);
	  SET_ELM_PLIST( res, i,tmp );
	  CHANGED_BAG( res);
	}
      }
    /* Now adjust the result TNUM info */

    if (len == 0)
      SET_FILT_LIST( res, FN_IS_EMPTY );
    else if (IS_PLIST( list ))
      {
	if (TNUM_OBJ(list) == T_PLIST_FFE ||
	    TNUM_OBJ(list) == T_PLIST_FFE+IMMUTABLE)
	  RetypeBag(res, T_PLIST_FFE);
	else if (TNUM_OBJ(list) >= T_PLIST_CYC &&
		 TNUM_OBJ(list) < T_PLIST_FFE)
	  RetypeBag(res, T_PLIST_CYC);
	else if (HAS_FILT_LIST(list, FN_IS_DENSE))
	  {
	    SET_FILT_LIST( res, FN_IS_DENSE );
	    if (HAS_FILT_LIST (list, FN_IS_HOMOG))
	      {
		SET_FILT_LIST( res, FN_IS_HOMOG);
		if (HAS_FILT_LIST( list, FN_IS_TABLE))
		  {
		    SET_FILT_LIST( res, FN_IS_TABLE);
		    if (HAS_FILT_LIST( list, FN_IS_RECT))
		      SET_FILT_LIST( res, FN_IS_RECT);
		  }
	      }
	  }
	else if (HAS_FILT_LIST(list, FN_IS_NDENSE))
	  SET_FILT_LIST( res, FN_IS_NDENSE );
      }

    /* return the result                                                   */
    return res;
}

Obj             ZeroListDefaultHandler (
    Obj                 self,
    Obj                 list )
{
    return ZeroListDefault( list );
}


/* This is intended to be installed as a method for the Attribute Zero, for
   rectangular matrices
   rather than the Operation ZeroOp. This is useful because, knowing that
   we want an immutable result, we can (a) reuse a single row of zeros
   (b) record that the result is a rectangular table */

Obj ZeroAttrMat( Obj self, Obj mat )
{
  Obj zrow;
  UInt len;
  UInt i;
  Obj res;
  len = LEN_LIST(mat);
  if (len == 0)
    return NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
  zrow = ZERO(ELM_LIST(mat,1));
  MakeImmutable(zrow);
  res = NEW_PLIST(T_PLIST_TAB_RECT+IMMUTABLE, len);
  SET_LEN_PLIST(res,len);
  for (i = 1; i <= len; i++)
    SET_ELM_PLIST(res,i,zrow);
  return res;
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
#ifdef XTNUMS

Obj AInvList (
    Obj                 list )
{
    return (*AInvFuncs[XTNum(list)])( list );
}

#endif

Obj AInvListDefault (
    Obj                 list )
{
    Obj                 res;
    Obj                 elm;
    Int                 len;
    Int                 i;

    /* make the result list                                                */
    len = LEN_LIST( list );
    res = NEW_PLIST(T_PLIST, len );
    SET_LEN_PLIST( res, len );

    /* enter the additive inverses everywhere                              */
    for ( i = 1; i <= len; i++ ) {
        elm = ELM0_LIST( list, i );
	if (elm) {
	  elm = AINV( elm );
	  SET_ELM_PLIST( res, i, elm );
	  CHANGED_BAG( res );
	}
    }

    /* Now adjust the result TNUM info */

    if (len == 0)
      SET_FILT_LIST( res, FN_IS_EMPTY );
    else if (IS_PLIST( list ))
      {
	if (TNUM_OBJ(list) == T_PLIST_FFE ||
	    TNUM_OBJ(list) == T_PLIST_FFE+IMMUTABLE)
	  RetypeBag(res, T_PLIST_FFE);
	else if (TNUM_OBJ(list) >= T_PLIST_CYC &&
		 TNUM_OBJ(list) < T_PLIST_FFE)
	  RetypeBag(res, T_PLIST_CYC);
	else if (HAS_FILT_LIST(list, FN_IS_DENSE))
	  {
	    SET_FILT_LIST( res, FN_IS_DENSE );
	    if (HAS_FILT_LIST (list, FN_IS_HOMOG))
	      {
		SET_FILT_LIST( res, FN_IS_HOMOG);
		if (HAS_FILT_LIST( list, FN_IS_TABLE))
		  {
		    SET_FILT_LIST( res, FN_IS_TABLE);
		    if (HAS_FILT_LIST( list, FN_IS_RECT))
		      SET_FILT_LIST( res, FN_IS_RECT);
		  }
	      }
	  }
	else if (HAS_FILT_LIST(list, FN_IS_NDENSE))
	  SET_FILT_LIST( res, FN_IS_NDENSE );
      }
    /* return the result                                                   */
    return res;
}

Obj AInvListDefaultHandler (
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

#ifdef XTNUMS
Obj             DiffList (
    Obj                 listL,
    Obj                 listR )
{
    return (*DiffFuncs[XTNum(listL)][XTNum(listR)])( listL, listR );
}
#endif

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
    listD = NEW_PLIST(IS_MUTABLE_OBJ(listR) ? T_PLIST :
		      T_PLIST+IMMUTABLE, len );
    SET_LEN_PLIST( listD, len );

    /* loop over the entries and subtract                                  */
    for ( i = 1; i <= len; i++ ) {
        elmR = ELMV0_LIST( listR, i );
	if (elmR)
	  {
	    elmD = DIFF( listL, elmR );
	    SET_ELM_PLIST( listD, i, elmD );
	    CHANGED_BAG( listD );
	  }
    }

    /* Now adjust the result TNUM info */

    if (len == 0)
      SET_FILT_LIST( listD, FN_IS_EMPTY );
    else if (IS_PLIST( listR ))
      {
	 if (HAS_FILT_LIST(listR, FN_IS_DENSE))
	   SET_FILT_LIST( listD, FN_IS_DENSE );
	 else if (HAS_FILT_LIST(listR, FN_IS_NDENSE))
	   SET_FILT_LIST( listD, FN_IS_NDENSE );
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
    listD = NEW_PLIST( IS_MUTABLE_OBJ(listL) ? T_PLIST :
		       T_PLIST+IMMUTABLE, len );
    SET_LEN_PLIST( listD, len );

    /* loop over the entries and subtract                                  */
    for ( i = 1; i <= len; i++ ) {
        elmL = ELMV0_LIST( listL, i );
	if (elmL)
	  {
	    elmD = DIFF( elmL, listR );
	    SET_ELM_PLIST( listD, i, elmD );
	    CHANGED_BAG( listD );
	  }
    }

    /* Now adjust the result TNUM info */

    if (len == 0)
      SET_FILT_LIST( listD, FN_IS_EMPTY );
    else if (IS_PLIST( listL ))
      {
	 if (HAS_FILT_LIST(listL, FN_IS_DENSE))
	   SET_FILT_LIST( listD, FN_IS_DENSE );
	 else if (HAS_FILT_LIST(listL, FN_IS_NDENSE))
	   SET_FILT_LIST( listD, FN_IS_NDENSE );
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
    Int                 lenL,lenR,lenD; /* length                          */
    Int                 i;              /* loop variable                   */

    /* get and check the length                                            */
    lenL = LEN_LIST( listL );
    lenR = LEN_LIST( listR );
    lenD = (lenR > lenL) ? lenR : lenL;
    listD = NEW_PLIST( (IS_MUTABLE_OBJ(listL) || IS_MUTABLE_OBJ(listR)) ?
		       T_PLIST : T_PLIST+IMMUTABLE, lenD );
    SET_LEN_PLIST( listD, lenD );

    /* loop over the entries and subtract                                  */
    for ( i = 1; i <= lenD; i++ ) {
        elmL = ELM0_LIST( listL, i );
        elmR = ELM0_LIST( listR, i );
        elmD = elmL ? (elmR ? DIFF( elmL, elmR ) : elmL) : (elmR ? AINV(elmR) : 0);
	if (elmD)
	  {
	    SET_ELM_PLIST( listD, i, elmD );
	    CHANGED_BAG( listD );
	  }
    }
    /* Now adjust the result TNUM info. There's not so much we
       can say here with total reliability */

    if (lenD == 0)
      SET_FILT_LIST( listD, FN_IS_EMPTY );
    else if (IS_PLIST( listR ) && IS_PLIST(listL) &&
	     HAS_FILT_LIST(listR, FN_IS_DENSE) &&
	     HAS_FILT_LIST(listL, FN_IS_DENSE))
      SET_FILT_LIST( listD, FN_IS_DENSE );
    
    /* return the result                                                   */
    return listD;
}

Obj             DiffSclListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return DiffSclList( listL, listR );
}

Obj             DiffListSclHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return DiffListScl( listL, listR );
}

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

#ifdef XTNUMS

Obj             ProdList (
    Obj                 listL,
    Obj                 listR )
{
    return (*ProdFuncs[XTNum(listL)][XTNum(listR)])( listL, listR );
}

#endif
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
    listP = NEW_PLIST( IS_MUTABLE_OBJ(listR) ? T_PLIST :T_PLIST+IMMUTABLE, len );
    SET_LEN_PLIST( listP, len );

    /* loop over the entries and multiply                                  */
    for ( i = 1; i <= len; i++ ) {
        elmR = ELMV0_LIST( listR, i );
	if (elmR)
	  {
	    elmP = PROD( listL, elmR );
	    SET_ELM_PLIST( listP, i, elmP );
	    CHANGED_BAG( listP );
	  }
    }
    if (len == 0)
      SET_FILT_LIST( listP, FN_IS_EMPTY );
    else if (IS_PLIST( listR ))
      {
	 if (HAS_FILT_LIST(listR, FN_IS_DENSE))
	   SET_FILT_LIST( listP, FN_IS_DENSE );
	 else if (HAS_FILT_LIST(listR, FN_IS_NDENSE))
	   SET_FILT_LIST( listP, FN_IS_NDENSE );
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
    listP = NEW_PLIST( (IS_MUTABLE_OBJ(listL) || IS_MUTABLE_OBJ(listR))
		       ? T_PLIST :T_PLIST+IMMUTABLE, len );
    SET_LEN_PLIST( listP, len );

    /* loop over the entries and multiply                                  */
    for ( i = 1; i <= len; i++ ) {
        elmL = ELMV0_LIST( listL, i );
	if (elmL) {
	  elmP = PROD( elmL, listR );
	  SET_ELM_PLIST( listP, i, elmP );
	  CHANGED_BAG( listP );
	}
    }

    if (len == 0)
      SET_FILT_LIST( listP, FN_IS_EMPTY );
    else if (IS_PLIST( listL ))
      {
	 if (HAS_FILT_LIST(listL, FN_IS_DENSE))
	   SET_FILT_LIST( listP, FN_IS_DENSE );
	 else if (HAS_FILT_LIST(listL, FN_IS_NDENSE))
	   SET_FILT_LIST( listP, FN_IS_NDENSE );
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
    Int                 lenL,lenR,len; /* length                          */
    Int                 i;              /* loop variable                   */

    /* get and check the length                                            */
    lenL = LEN_LIST( listL );
    lenR = LEN_LIST( listR );
    len =  (lenL < lenR) ? lenL : lenR;
#if 0
    if ( len != LEN_LIST( listR ) ) {
        listR = ErrorReturnObj(
            "Vector *: <right> must have the same length as <left> (%d)",
            (Int)LEN_LIST(listR), 0L,
            "you can replace list <right> via 'return <right>;'" );
        return PROD( listL, listR );
    }
#endif
    /* loop over the entries and multiply and accumulate                   */
    listP = 0;
    for (i = 1; i <= len; i++)
      {
        elmL = ELM0_LIST( listL, i );
        elmR = ELM0_LIST( listR, i );
	if (elmL && elmR)
	  {
	    elmP = PROD( elmL, elmR );
	    if (listP)
	      listP = SUM( listP, elmP );
	    else
	      listP = elmP;
	  }
    }

    if (!listP)
      ErrorQuit("Inner product multiplication of lists: no summands", 0, 0);
    
    /* adjust mutability */

    if ((IS_MUTABLE_OBJ(listL) || IS_MUTABLE_OBJ(listR))
	&& !IS_MUTABLE_OBJ(listP))
      listP = SHALLOW_COPY_OBJ(listP);

    /* return the result                                                   */
    return listP;
}

Obj             ProdSclListHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return ProdSclList( listL, listR );
}

Obj             ProdListSclHandler (
    Obj                 self,
    Obj                 listL,
    Obj                 listR )
{
    return ProdListScl( listL, listR );
}

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

#ifdef XTNUMS
Obj             OneList (
    Obj                 list )
{
    return (*OneFuncs[XTNum(list)])( list );
}
#endif
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
            "you can replace ONE matrix <mat> via 'return <mat>;'" );
    }

    /* get the zero and the one                                            */
    zero = ZERO( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
    one  = ONE( zero );

    /* make the identity matrix                                            */
    res = NEW_PLIST(  T_PLIST, len );
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
**  'InvMatrix' is a generic function for the inverse. In nearly all
**  circumstances, we should use a more efficient function based on
**  calls to AddRowVector, etc.
*/
#ifdef XTNUMS

Obj             InvList (
    Obj                 list )
{
    return (*InvFuncs[XTNum(list)])( list );
}

#endif
#ifdef SYS_IS_MAC_MWC
#pragma global_optimizer on /* CW Pro 2 can't compile this w/o global optimization */
#endif

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
            "you can replace <mat> via 'return <mat>;'" );
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

#ifdef SYS_IS_MAC_MWC
#pragma global_optimizer reset 
#endif

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
#ifdef XTNUMS
Obj             QuoList (
    Obj                 listL,
    Obj                 listR )
{
    return (*QuoFuncs[XTNum(listL)][XTNum(listR)])( listL, listR );
}
#endif

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

#ifdef XTNUMS
Obj             LQuoList (
    Obj                 listL,
    Obj                 listR )
{
    return (*LQuoFuncs[XTNum(listL)][XTNum(listR)])( listL, listR );
}
#endif

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
#ifdef XTNUMS
Obj             PowList (
    Obj                 listL,
    Obj                 listR )
{
    return (*PowFuncs[XTNum(listL)][XTNum(listR)])( listL, listR );
}
#endif

Obj             PowMatrixInt (
    Obj                 mat,
    Obj                 n )
{
    Obj                 res = 0;        /* result                          */
    UInt                i, k, l;        /* loop variables                  */

    /* if the integer is zero, return the neutral element of the operand   */
    if      ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) ==  0 ) {
        res = OneMatrix( mat );
    }

    /* if the integer is one, return a copy of the operand                 */
    else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) ==  1 ) {
        res = CopyObj( mat, 0 );
    }

    /* if the integer is minus one, return the inverse of the operand      */
    else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) == -1 ) {
        res = INV( mat );
    }

    /* if the integer is negative, invert the operand and the integer      */
    else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) <  -1 ) {
        res = INV( mat );
        if ( res == Fail ) {
            return ErrorReturnObj(
                "Operations: <mat> must have an inverse",
                0L, 0L,
                "you can supply a matrix <inverse> via 'return <inverse>;'" );
        }
        res = PowMatrixInt( res, AINV( n ) );
    }

    /* if the integer is negative, invert the operand and the integer      */
    else if ( TNUM_OBJ(n) == T_INTNEG ) {
        res = INV( mat );
        if ( res == Fail ) {
            return ErrorReturnObj(
                "Operations: <mat> must have an inverse",
                0L, 0L,
                "you can supply a matrix <inverse> via 'return <inverse>;'" );
        }
        res = PowMatrixInt( res, AINV( n ) );
    }

    /* if the integer is small, compute the power by repeated squaring     */
    /* the loop invariant is <result> = <res>^<k> * <op>^<l>, <l> < <k>    */
    /* <res> = 0 means that <res> is the neutral element                   */
    else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) >   1 ) {
        res = 0;
        k = ((UInt)1L) << 31;
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
    else if ( TNUM_OBJ(n) == T_INTPOS ) {
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

#ifdef XTNUMS
Obj             CommList (
    Obj                 listL,
    Obj                 listR )
{
    return (*CommFuncs[XTNum(listL)][XTNum(listR)])( listL, listR );
}
#endif

/****************************************************************************
**
*F  FuncADD_ROW_VECTOR_5( <self>, <list1>, <list2>, <mult>, <from>, <to> )
**
**  This function adds <mult>*<list2>[i] destructively to <list1>[i] for
**  each i in the range <from>..<to>. It does very little checking
**
*/

/* We need these to redispatch when the user has supplied a replacement value. */

static Obj AddRowVectorOp;   /* BH changed to static */
static Obj MultRowVectorOp;  /* BH changed to static */

Obj FuncADD_ROW_VECTOR_5( Obj self,
			  Obj list1,
			  Obj list2,
			  Obj mult,
			  Obj from,
			  Obj to )
{
  UInt i;
  Obj el1,el2;
  while (!IS_INTOBJ(to) ||
	 INT_INTOBJ(to) > LEN_LIST(list1) ||
	 INT_INTOBJ(to) > LEN_LIST(list2))
    to = ErrorReturnObj("AddRowVector: Upper limit too large", 0L, 0L, 
                        "you can replace limit by <lim> via 'return <lim>;'");
  for (i = INT_INTOBJ(from); i <= INT_INTOBJ(to); i++)
    {
      el1 = ELM_LIST(list1,i);
      el2 = ELM_LIST(list2,i);
      el2 = PROD(mult, el2);
      el1 = SUM(el1,el2);
      ASS_LIST(list1,i,el1);
      CHANGED_BAG(list1);
    }
  return 0;
}

/****************************************************************************
**
*F  FuncADD_ROW_VECTOR_5_FAST( <self>, <list1>, <list2>, <mult>, <from>, <to> )
**
**  This function adds <mult>*<list2>[i] destructively to <list1>[i] for
**  each i in the range <from>..<to>. It does very little checking
**
**  This version is specialised to the "fast" case where list1 and list2 are
**  plain lists of cyclotomics and mult is a small integers
*/
Obj FuncADD_ROW_VECTOR_5_FAST ( Obj self,
				Obj list1,
				Obj list2,
				Obj mult,
				Obj from,
				Obj to )
{
  UInt i;
  Obj e1,e2, prd, sum;
  while (!IS_INTOBJ(to) ||
	 INT_INTOBJ(to) > LEN_LIST(list1) ||
	 INT_INTOBJ(to) > LEN_LIST(list2))
    to = ErrorReturnObj("AddRowVector: Upper limit too large", 0L, 0L, 
                        "you can replace limit by <lim> via 'return <lim>;'");
  for (i = INT_INTOBJ(from); i <= INT_INTOBJ(to); i++)
    {
      e1 = ELM_PLIST(list1,i);
      e2 = ELM_PLIST(list2,i);
      if ( !ARE_INTOBJS( e2, mult ) || !PROD_INTOBJS( prd, e2, mult ))
	{
	  prd = PROD(e2,mult);
	}
      if ( !ARE_INTOBJS(e1, prd) || !SUM_INTOBJS( sum, e1, prd) )
	{
	  sum = SUM(e1,prd);
	  SET_ELM_PLIST(list1,i,sum);
	  CHANGED_BAG(list1);
	}
      else
	  SET_ELM_PLIST(list1,i,sum);
    }
  return 0;
}

/****************************************************************************
**
*F  FuncADD_ROW_VECTOR_3( <self>, <list1>, <list2>, <mult> )
**
**  This function adds <mult>*<list2>[i] destructively to <list1>[i] for
**  each i in the range 1..Length(<list1>). It does very little checking
**
*T  This could be speeded up still further by using special code for various
**  types of list -- this version just uses generic list ops
*/
Obj FuncADD_ROW_VECTOR_3( Obj self,
			  Obj list1,
			  Obj list2,
			  Obj mult)
{
  UInt i;
  UInt len = LEN_LIST(list1);
  Obj el1, el2;
  if (LEN_LIST(list2) != len)
    {
      list2 = ErrorReturnObj("AddRowVector: lists must be the same length",
			     0L, 0L, 
                             "you can replace second list <list2> via 'return <list2>;'");
      return CALL_3ARGS(AddRowVectorOp, list1, list2,mult);
    }
  for (i = 1; i <= len; i++)
    {
      el1 = ELMW_LIST(list1,i);
      el2 = ELMW_LIST(list2,i);
      el2 = PROD(mult, el2);
      el1 = SUM(el1 , el2);
      ASS_LIST(list1,i,el1);
      CHANGED_BAG(list1);
    }
  return 0;
}

/****************************************************************************
**
*F  FuncADD_ROW_VECTOR_3_FAST( <self>, <list1>, <list2>, <mult> )
**
**  This function adds <mult>*<list2>[i] destructively to <list1>[i] for
**  each i in the range 1..Length(<list1>). It does very little checking
**
**  This version is specialised to the "fast" case where list1 and list2 are
**  plain lists of cyclotomics and mult is a small integers
*/
Obj FuncADD_ROW_VECTOR_3_FAST ( Obj self,
				Obj list1,
				Obj list2,
				Obj mult )
{
  UInt i;
  Obj e1,e2, prd, sum;
  UInt len = LEN_PLIST(list1);
  if (LEN_PLIST(list2) != len)
    {
      list2 = ErrorReturnObj("AddRowVector: lists must be the same length",
			     0L, 0L, 
                             "you can replace second list <list2> via 'return <list2>;'");
      return CALL_3ARGS(AddRowVectorOp, list1, list2, mult);
    }
      
  for (i = 1; i <= len; i++)
    {
      e1 = ELM_PLIST(list1,i);
      e2 = ELM_PLIST(list2,i);
      if ( !ARE_INTOBJS( e2, mult ) || !PROD_INTOBJS( prd, e2, mult ))
	{
	  prd = PROD(e2,mult);
	}
      if ( !ARE_INTOBJS(e1, prd) || !SUM_INTOBJS( sum, e1, prd) )
	{
	  sum = SUM(e1,prd);
	  SET_ELM_PLIST(list1,i,sum);
	  CHANGED_BAG(list1);
	}
      else
	  SET_ELM_PLIST(list1,i,sum);
    }
  return 0;
}

/****************************************************************************
**
*F  FuncADD_ROW_VECTOR_2( <self>, <list1>, <list2>)
**
**  This function adds <list2>[i] destructively to <list1>[i] for
**  each i in the range 1..Length(<list1>). It does very little checking
**
*T  This could be speeded up still further by using special code for various
**  types of list -- this version just uses generic list ops
*/
Obj FuncADD_ROW_VECTOR_2( Obj self,
			  Obj list1,
			  Obj list2)
{
  UInt i;
  Obj el1,el2;
  UInt len = LEN_LIST(list1);
  if (LEN_LIST(list2) != len)
    {
      list2 = ErrorReturnObj("AddRowVector: lists must be the same length",
			     0L, 0L, 
                             "you can replace second list <list2> via 'return <list2>;'");
      return CALL_2ARGS(AddRowVectorOp, list1, list2);
    }
  for (i = 1; i <= len; i++)
    {
      el1 = ELMW_LIST(list1,i);
      el2 = ELMW_LIST(list2,i);
      el1 = SUM(el1, el2 );
      ASS_LIST(list1,i,el1);
      CHANGED_BAG(list1);
    }
  return 0;
}

/****************************************************************************
**
*F  FuncADD_ROW_VECTOR_2_FAST( <self>, <list1>, <list2> )
**
**  This function adds <list2>[i] destructively to <list1>[i] for
**  each i in the range 1..Length(<list1>). It does very little checking
**
**  This version is specialised to the "fast" case where list1 and list2 are
**  plain lists of cyclotomics 
*/
Obj FuncADD_ROW_VECTOR_2_FAST ( Obj self,
				Obj list1,
				Obj list2 )
{
  UInt i;
  Obj e1,e2, sum;
  UInt len = LEN_PLIST(list1);
  if (LEN_PLIST(list2) != len)
    {
      list2 = ErrorReturnObj("AddRowVector: lists must be the same length",
			     0L, 0L, 
                             "you can replace second list <list2> via 'return <list2>;'");
      return CALL_2ARGS(AddRowVectorOp, list1, list2);
    }
  for (i = 1; i <= len; i++)
    {
      e1 = ELM_PLIST(list1,i);
      e2 = ELM_PLIST(list2,i);
      if ( !ARE_INTOBJS(e1, e2) || !SUM_INTOBJS( sum, e1, e2) )
	{
	  sum = SUM(e1,e2);
	  SET_ELM_PLIST(list1,i,sum);
	  CHANGED_BAG(list1);
	}
      else
	  SET_ELM_PLIST(list1,i,sum);
    }
  return 0;
}

/****************************************************************************
**
*F  FuncMULT_ROW_VECTOR_2( <self>, <list>, <mult> )
**
**  This function destructively multiplies the entries of <list> by <mult>
**  It does very little checking
**
*/

Obj FuncMULT_ROW_VECTOR_2( Obj self,
			   Obj list,
			   Obj mult )
{
  UInt i;
  Obj prd;
  UInt len = LEN_LIST(list);
  for (i = 1; i <= len; i++)
    {
      prd = ELMW_LIST(list,i);
      prd = PROD(prd,mult);
      ASS_LIST(list,i,prd);
      CHANGED_BAG(list);
    }
  return 0;
}

/****************************************************************************
**
*F  FuncMULT_ROW_VECTOR_2_FAST( <self>, <list>, <mult> )
**
**  This function destructively multiplies the entries of <list> by <mult>
**  It does very little checking
**
**  This is the fast method for plain lists of cyclotomics and an integer
**  multiplier
*/

Obj FuncMULT_ROW_VECTOR_2_FAST( Obj self,
				Obj list,
				Obj mult )
{
  UInt i;
  Obj el,prd;
  UInt len = LEN_PLIST(list);
  for (i = 1; i <= len; i++)
    {
      el = ELM_PLIST(list,i);
      if (!ARE_INTOBJS(el, mult) || !PROD_INTOBJS(prd,el,mult))
	{
	  prd = PROD(el,mult);
	  SET_ELM_PLIST(list,i,prd);
	  CHANGED_BAG(list);
	}
      else
	  SET_ELM_PLIST(list,i,prd);
    }
  return 0;
}

/****************************************************************************
**
*F  FuncPROD_VEC_MAT_DEFAULT( <self>, <vec>, <mat> )
**
**  This is a specialized version of PROD_LIST_LIST_DEFAULT, that uses
**  AddRowVector rather than SUM and PROD.
*/


Obj FuncPROD_VEC_MAT_DEFAULT( Obj self,
			      Obj vec,
			      Obj mat )
{
  Obj res;
  Obj elt;
  Obj vecr;
  UInt i,len;
  Obj z;
  Obj o;
  res = (Obj) 0;
  len = LEN_LIST(vec);
  if (len != LEN_LIST(mat))
    {
      mat = ErrorReturnObj("<vec> * <mat>: vector and matrix must have same length", 0L, 0L,
			   "you can replace <mat> via 'return <mat>;'");
      return PROD(vec,mat);
    }
  elt = ELMW_LIST(vec,1);
  z = ZERO(elt);
  for (i = 1; i <= len; i++)
    {
      elt = ELMW_LIST(vec,i);
      if (!EQ(elt,z))
	{
	  vecr = ELMW_LIST(mat,i);
	  if (res == (Obj)0)
	    {
	      res = SHALLOW_COPY_OBJ(vecr);
	      CALL_2ARGS(MultRowVectorOp,res,elt);
	    }
	  else
	    CALL_3ARGS(AddRowVectorOp, res, vecr, elt);
	}
    }
  if (res == (Obj)0)
    res = ZERO(ELMW_LIST(mat,1));
  if (!IS_MUTABLE_OBJ(vec) && !IS_MUTABLE_OBJ(mat))
    MakeImmutable(res);
  return res;
}

/****************************************************************************
**
*F  FuncINV_MAT_DEFAULT
**
**  A faster version of InvMat for those matrices for whose rows AddRowVector
** and MultRowVector make sense (and might have fast kernel methods)
**
*/

#ifdef SYS_IS_MAC_MWC
#pragma global_optimizer on /* CW 11 can't compile this w/o global optimization */
#endif

Obj ConvertToMatrixRep;

Obj FuncINV_MAT_DEFAULT( Obj self, Obj mat)
{
  Obj                 res;            /* result                          */
  Obj                 matcopy;        /* copy of mat                     */
  Obj                 row;            /* one row of matcopy              */
  Obj                 row2;           /* corresponding row of res        */
  Obj                 row3;           /* another row of matcopy          */
  Obj                 x;              /* one element of the matrix       */
  Obj                 xi;             /* 1/x                             */
  Obj                 y;              /* another element of the matrix   */
  Obj                 yi;             /* -y                              */
  Obj                 zero;           /* zero element                    */
  Obj                 zerov;          /* zero vector                     */
  Obj                 one;            /* one element                     */
  UInt                len;            /* length (and width) of matrix    */
  UInt                i, k, j;        /* loop variables                  */

  /* check that the operand is a *square* matrix                         */
  len = LEN_LIST( mat );
  if ( len != LEN_LIST( ELM_LIST( mat, 1 ) ) ) {
    mat = ErrorReturnObj(
			 "Matrix INV: <mat> must be square (not %d by %d)",
			 (Int)len, (Int)LEN_LIST( ELM_LIST( mat, 1 ) ),
			 "you can replace <mat> via 'return <mat>;'" );
    return INV(mat);
  }

  /* get the zero and the one                                            */
  zerov = ZERO( ELMW_LIST(mat, 1));
  zero = ZERO( ELMW_LIST( ELMW_LIST( mat, 1 ), 1 ) );
  one  = ONE( zero );

  /* set up res (initially the identity) and matcopy */
  res = NEW_PLIST(T_PLIST,len);
  matcopy = NEW_PLIST(T_PLIST,len);
  SET_LEN_PLIST(res,len);
  SET_LEN_PLIST(matcopy,len);
  for (i = 1; i <= len; i++)
    {
      row = SHALLOW_COPY_OBJ(zerov);
      ASS_LIST(row,i,one);
      SET_ELM_PLIST(res,i,row);
      CHANGED_BAG(res);
      row = SHALLOW_COPY_OBJ(ELM_LIST(mat,i));
      SET_ELM_PLIST(matcopy,i,row);
      CHANGED_BAG(matcopy);
    }


  /* Now to work, make matcopy an identity by row operations and
     do the same row operations to res */

  /* outer loop over columns of matcopy */
  for (i = 1; i <= len; i++)
    {
      /* Find a non-zero leading entry that is in that column */
      for (j = i; j <= len; j++)
	{
	  row = ELM_PLIST(matcopy,j);
	  x = ELMW_LIST(row,i);
	  if (!EQ(x,zero))
	    break;
	}

      /* if there isn't one then the matrix is not invertible */
      if (j > len)
	return Fail;

      /* Maybe swap two rows */
      /* But I will want this value anyway */
      row2 = ELM_PLIST(res,j);
      if (j != i)
	{
	  SET_ELM_PLIST(matcopy,j,ELM_PLIST(matcopy,i));
	  SET_ELM_PLIST(res,j,ELM_PLIST(res,i));
	  SET_ELM_PLIST(matcopy,i,row);
	  SET_ELM_PLIST(res,i,row2);
	}

      /*Maybe rescale the row */
      if (!EQ(x, one))
	{
	  xi = INV(x);
	  CALL_2ARGS(MultRowVectorOp, row, xi);
	  CALL_2ARGS(MultRowVectorOp, row2, xi);
	}

      /* Clear the entries. We know that we can ignore the entries in rows i..j */
      for (k = 1; k < i; k++)
	{
	  row3 = ELM_PLIST(matcopy,k);
	  y = ELMW_LIST(row3,i);
	  if (!EQ(y,zero))
	    {
	      yi = AINV(y);
	      CALL_3ARGS(AddRowVectorOp, row3, row, yi);
	      CALL_3ARGS(AddRowVectorOp, ELM_PLIST(res,k), row2, yi);
	    }
	}
      for (k = j+1; k <= len; k++)
	{
	  row3 = ELM_PLIST(matcopy,k);
	  y = ELMW_LIST(row3,i);
	  if (!EQ(y,zero))
	    {
	      yi = AINV(y);
	      CALL_3ARGS(AddRowVectorOp, row3, row, yi);
	      CALL_3ARGS(AddRowVectorOp, ELM_PLIST(res,k), row2, yi);
	    }
	}
				 
    }

  /* if the matrix entries are not immutable, we cannot convert to a compact
   * representation */
  MakeImmutable(res);

  /* Now res contains the result.
     We put it into optimum format */
  CALL_1ARGS(ConvertToMatrixRep, res);
  return res;
}
  
#ifdef SYS_IS_MAC_MWC
#pragma global_optimizer reset 
#endif

/****************************************************************************
**
*F  FuncADD_TO_LIST_ENTRIES_PLIST_RANGE( <list>, <range>, <x> )
**
**  This is a method for the operation AddToListEntries, used mainly in
** the MPQS of Stefan Kohl.
**
**  This method requires a plain list for the first argument, and a
**  range for the second and is optimised for the case where x and the list
** entries are small integers, as are their sums
*/

Obj FuncADD_TO_LIST_ENTRIES_PLIST_RANGE ( 
			      Obj self,
			      Obj list,
			      Obj range,
			      Obj x)
{
  UInt low, high, incr;
  Obj y,z;
  UInt i;
  if (!IS_INTOBJ(x))
    return TRY_NEXT_METHOD;
  low = GET_LOW_RANGE(range);
  incr = GET_INC_RANGE(range);
  high = low + incr*(GET_LEN_RANGE(range)-1);
  for (i = low; i <= high; i+= incr)
    {
      y = ELM_PLIST(list,i);
      if (!IS_INTOBJ(y) ||
	  !SUM_INTOBJS(z,x,y))
	{
	  z = SUM(x,y);
	  SET_ELM_PLIST(list,i,z);
	  CHANGED_BAG(list);
	}
      else
	SET_ELM_PLIST(list,i,z);
	
    }
  return (Obj) 0;
}


/****************************************************************************
**
*F  MONOM_TOT_DEG_LEX( u, v ) . . . . . total degree lexicographical ordering
**
**  This function  implements the total degree  plus lexicographical ordering
**  for monomials  of commuting indeterminates.   It is in this  file because
**  monomials  are presently implemented  as lists  of indeterminate-exponent
**  pairs.  Should there be  more functions supporting polynomial arithmetic,
**  then this function should go into a separate file.
**
**  Examples:      x^2y^3 < y^7,   x^4 y^5 < x^3 y^6
*/
static Obj  FuncMONOM_TOT_DEG_LEX ( Obj self, Obj u, Obj  v ) {

  Int4 i, lu, lv;

  Obj  total;
  Obj  lexico;
 
  while ( !(T_PLIST<=TNUM_OBJ(u) && TNUM_OBJ(u)<=LAST_PLIST_TNUM)
	  || !IS_DENSE_LIST(u)) {
      u = ErrorReturnObj(
      "MONOM_TOT_DEG_LEX: first <list> must be a dense plain list (not a %s)", 
      (Int)TNAM_OBJ(u), 0L, "you can replace <list> via 'return <list>;'" );
  }
  while ( !(T_PLIST<=TNUM_OBJ(v) && TNUM_OBJ(v)<=LAST_PLIST_TNUM) ||
	  !IS_DENSE_LIST(v)) {
      v = ErrorReturnObj(
      "MONOM_TOT_DEG_LEX: first <list> must be a dense plain list (not a %s)", 
      (Int)TNAM_OBJ(v), 0L, "you can replace <list> via 'return <list>;'" );
  }
    
  lu = LEN_PLIST( u );
  lv = LEN_PLIST( v );

  /* strip off common prefixes                                             */
  i = 1;
  while ( i <= lu && i <= lv && EQ(ELM_PLIST( u,i ), ELM_PLIST( v,i )) ) 
      i++;
 
  /* Is u a prefix of v ? Return true if u is a proper prefix.             */
  if ( i > lu ) return (lu < lv) ? True : False;

  /* Is v a  prefix of u ?                                                 */
  if ( i > lv ) return False;
 
  /* Now determine the lexicographic order.  The monomial is interpreted   */
  /* as a string of indeterminates.                                        */
  if ( i % 2 == 1 ) {
    /* The first difference between u and v is an indeterminate.           */
    lexico = LT(ELM_PLIST( u, i ), ELM_PLIST( v, i )) ? True : False;
    i++;  
  }
  else {
    /* The first difference between u and v is an exponent.                */
    lexico = LT(ELM_PLIST( v, i ), ELM_PLIST( u, i )) ? True : False;
  }
 
  /* Now add up the remaining exponents in order to compare the total      */
  /* degrees.                                                              */
  total = INTOBJ_INT(0);
  while ( i <= lu && i <= lv )  {
    C_SUM_FIA(  total, total, ELM_PLIST( u, i ) );
    C_DIFF_FIA( total, total, ELM_PLIST( v, i ) );
    i += 2;
  }

  /* Only one of the following while loops is executed                     */
  while ( i <= lu ) {
    C_SUM_FIA(  total, total, ELM_PLIST( u, i ) );
    i += 2;
  }
  while ( i <= lv ) {
    C_DIFF_FIA( total, total, ELM_PLIST( v, i ) );
    i += 2;
  }
 
  if ( EQ( total, INTOBJ_INT(0)) ) return lexico;

  return LT( total, INTOBJ_INT(0)) ? True : False;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * * */


/****************************************************************************
**

*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "EQ_LIST_LIST_DEFAULT", 2, "listL, listR",
      EqListListHandler, "src/listoper.c:EQ_LIST_LIST_DEFAULT" },

    { "LT_LIST_LIST_DEFAULT", 2, "listL, listR",
      LtListListHandler, "src/listoper.c:LT_LIST_LIST_DEFAULT" },

    { "IN_LIST_DEFAULT", 2, "obj, list",
      InListDefaultHandler, "src/listoper.c:IN_LIST_DEFAULT" },

    { "SUM_SCL_LIST_DEFAULT", 2, "listL, listR",
      SumSclListHandler, "src/listoper.c:SUM_SCL_LIST_DEFAULT" },

    { "SUM_LIST_SCL_DEFAULT", 2, "listL, listR",
      SumListSclHandler, "src/listoper.c:SUM_LIST_SCL_DEFAULT" },

    { "SUM_LIST_LIST_DEFAULT", 2, "listL, listR",
      SumListListHandler, "src/listoper.c:SUM_LIST_LIST_DEFAULT" },

    { "ZERO_LIST_DEFAULT", 1, "list",
      ZeroListDefaultHandler, "src/listoper.c:ZERO_LIST_DEFAULT" },

    { "ZERO_ATTR_MAT", 1, "mat",
      ZeroAttrMat, "src/listoper.c:ZERO_ATTR_MAT" },

    { "AINV_LIST_DEFAULT", 1, "list",
      AInvListDefaultHandler, "src/listoper.c:AINV_LIST_DEFAULT" },

    { "DIFF_SCL_LIST_DEFAULT", 2, "listL, listR",
      DiffSclListHandler, "src/listoper.c:DIFF_SCL_LIST_DEFAULT" },

    { "DIFF_LIST_SCL_DEFAULT", 2, "listL, listR",
      DiffListSclHandler, "src/listoper.c:DIFF_LIST_SCL_DEFAULT" },

    { "DIFF_LIST_LIST_DEFAULT", 2, "listL, listR",
      DiffListListHandler, "src/listoper.c:DIFF_LIST_LIST_DEFAULT" },

    { "PROD_SCL_LIST_DEFAULT", 2, "listL, listR",
      ProdSclListHandler, "src/listoper.c:PROD_SCL_LIST_DEFAULT" },

    { "PROD_LIST_SCL_DEFAULT", 2, "listL, listR",
      ProdListSclHandler, "src/listoper.c:PROD_LIST_SCL_DEFAULT" },

    { "PROD_LIST_LIST_DEFAULT", 2, "listL, listR",
      ProdListListHandler, "src/listoper.c:PROD_LIST_LIST_DEFAULT" },

    { "ONE_MATRIX", 1, "list",
      OneMatrixHandler, "src/listoper.c:ONE_MATRIX" },

    { "INV_MATRIX", 1, "list",
      InvMatrixHandler, "src/listoper.c:INV_MATRIX" },

    { "POW_MATRIX_INT", 2, "list, int",
      PowMatrixIntHandler, "src/listoper.c:POW_MATRIX_INT" },

    { "ADD_ROW_VECTOR_5", 5, "list1, list2, mult, from, to",
      FuncADD_ROW_VECTOR_5, "src/listoper.c:ADD_ROW_VECTOR_5" },

    { "ADD_ROW_VECTOR_5_FAST", 5, "list1, list2, mult, from, to",
      FuncADD_ROW_VECTOR_5_FAST, "src/listoper.c:ADD_ROW_VECTOR_5_FAST" },

    { "ADD_ROW_VECTOR_3", 3, "list1, list2, mult",
      FuncADD_ROW_VECTOR_3, "src/listoper.c:ADD_ROW_VECTOR_3" },

    { "ADD_ROW_VECTOR_3_FAST", 3, "list1, list2, mult",
      FuncADD_ROW_VECTOR_3_FAST, "src/listoper.c:ADD_ROW_VECTOR_3_FAST" },

    { "ADD_ROW_VECTOR_2", 2, "list1, list2",
      FuncADD_ROW_VECTOR_2, "src/listoper.c:ADD_ROW_VECTOR_2" },

    { "ADD_ROW_VECTOR_2_FAST", 2, "list1, list2",
      FuncADD_ROW_VECTOR_2_FAST, "src/listoper.c:ADD_ROW_VECTOR_2_FAST" },

    { "MULT_ROW_VECTOR_2", 2, "list, mult",
      FuncMULT_ROW_VECTOR_2, "src/listoper.c:MULT_ROW_VECTOR_2" },

    { "MULT_ROW_VECTOR_2_FAST", 2, "list, mult",
      FuncMULT_ROW_VECTOR_2_FAST, "src/listoper.c:MULT_ROW_VECTOR_2_FAST" },

    { "PROD_VEC_MAT_DEFAULT", 2, "vec, mat",
      FuncPROD_VEC_MAT_DEFAULT, "src/listoper.c:PROD_VEC_MAT_DEFAULT" },
    
    { "INV_MAT_DEFAULT", 1, "mat",
      FuncINV_MAT_DEFAULT, "src/listoper.c:INV_MAT_DEFAULT" },

    { "ADD_TO_LIST_ENTRIES_PLIST_RANGE", 3, "list, range, x",
      FuncADD_TO_LIST_ENTRIES_PLIST_RANGE, "src/listfunc.c:ADD_TO_LIST_ENTRIES_PLIST_RANGE" },

    { "MONOM_TOT_DEG_LEX", 2, "monomial, monomial",
      FuncMONOM_TOT_DEG_LEX,
      "src/ratfun.c:FuncMONOM_TOT_DEG_LEX" },

    { 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
**
*/

static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                t1;             /* type of left  operand           */
    UInt                t2;             /* type of right operand           */

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    InitFopyGVar( "AddRowVector", &AddRowVectorOp );
    InitFopyGVar( "MultRowVector", &MultRowVectorOp );
    InitFopyGVar( "ConvertToMatrixRep", &ConvertToMatrixRep );


    /* install the generic comparisons                                     */
    for ( t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
        for ( t2 = FIRST_LIST_TNUM; t2 <= LAST_LIST_TNUM; t2++ ) {
            EqFuncs[ t1 ][ t2 ] = EqListList;
        }
    }
    for ( t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
        for ( t2 = FIRST_LIST_TNUM; t2 <= LAST_LIST_TNUM; t2++ ) {
            LtFuncs[ t1 ][ t2 ] = LtListList;
        }
    }
    for ( t1 = FIRST_REAL_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
        for ( t2 = FIRST_LIST_TNUM; t2 <= LAST_LIST_TNUM; t2++ ) {
            InFuncs[ t1 ][ t2 ] = InList;
        }
    }

    for (t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
            ZeroFuncs[t1] = ZeroListDefault;
    }

    for (t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
            AInvFuncs[t1] = AInvListDefault;
    }

    /* No kernel installations for One or Inverse any more */

    /* Sum. Here we can do list + non-list and non-list + list,
       we have to careful about list+list, though, as it might
       really be list+matrix or matrix+list

       for the T_PLIST_CYC and T_PLIST_FFE cases, we know the nesting
       depth (1) and so we can do the cases of adding them to each
       other and to T_PLIST_TAB objects, which have at least nesting
       depth 2. Some of this will be overwritten in vector.c and
       vecffe.c

       SumListList will also always handle the empty list and another list

       everything else needs to wait until the library */
       
    for (t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
      for (t2 = FIRST_REAL_TNUM; t2 < FIRST_LIST_TNUM; t2++ ) {
	SumFuncs[t1][t2] = SumListScl;
	SumFuncs[t2][t1] = SumSclList;
      }
      for (t2 = T_PLIST_EMPTY; t2 <= T_PLIST_EMPTY+IMMUTABLE; t2++)
	{
	  SumFuncs[t1][t2] = SumListList;
	  SumFuncs[t2][t1] = SumListList;
	}
    }
    for (t1 = T_PLIST_CYC; t1 <= T_PLIST_FFE+IMMUTABLE; t1++) {
      for (t2 = T_PLIST_CYC; t2 <= T_PLIST_FFE+IMMUTABLE; t2++) {
	SumFuncs[t1][t2] = SumListList;
      }
      for (t2 = T_PLIST_TAB; t2 <= T_PLIST_TAB_RECT_SSORT+IMMUTABLE; t2++) {
	SumFuncs[t1][t2] = SumSclList;
	SumFuncs[t2][t1] = SumListScl;
      }
    }
	
    /* Diff is just like Sum */
    
    for (t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
      for (t2 = FIRST_REAL_TNUM; t2 < FIRST_LIST_TNUM; t2++ ) {
	DiffFuncs[t1][t2] = DiffListScl;
	DiffFuncs[t2][t1] = DiffSclList;
      }
      for (t2 = T_PLIST_EMPTY; t2 <= T_PLIST_EMPTY+IMMUTABLE; t2++)
	{
	  DiffFuncs[t1][t2] = DiffListList;
	  DiffFuncs[t2][t1] = DiffListList;
	}
    }
    for (t1 = T_PLIST_CYC; t1 <= T_PLIST_FFE+IMMUTABLE; t1++) {
      for (t2 = T_PLIST_CYC; t2 <= T_PLIST_FFE+IMMUTABLE; t2++) {
	DiffFuncs[t1][t2] = DiffListList;
      }
      for (t2 = T_PLIST_TAB; t2 <= T_PLIST_TAB_RECT_SSORT+IMMUTABLE; t2++) {
	DiffFuncs[t1][t2] = DiffSclList;
	DiffFuncs[t2][t1] = DiffListScl;
      }
    }

    /* Prod.

    Here we can't do the T_PLIST_TAB cases, in case they are nesting depth three or more
    in which case different rules apply.

    It's also less obvious what happens with the empty list
    */
    
    
    for (t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
      for (t2 = FIRST_REAL_TNUM; t2 < FIRST_LIST_TNUM; t2++ ) {
	ProdFuncs[t1][t2] = ProdListScl;
	ProdFuncs[t2][t1] = ProdSclList;
      }
    }
    for (t1 = T_PLIST_CYC; t1 <= T_PLIST_FFE+IMMUTABLE; t1++) {
      for (t2 = T_PLIST_CYC; t2 <= T_PLIST_FFE+IMMUTABLE; t2++) {
	ProdFuncs[t1][t2] = ProdListList;
      }
    }
    

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
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoListOper()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "listoper",                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoListOper ( void )
{
    module.revision_c = Revision_listoper_c;
    module.revision_h = Revision_listoper_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  listoper.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
