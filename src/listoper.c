/****************************************************************************
**
*W  listoper.c                  GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains  the functions of the  package with the operations for
**  generic lists.
*/
#include <src/system.h>                 /* Ints, UInts */


#include <src/sysfiles.h>               /* file input/output */

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/bool.h>                   /* booleans */

#include <src/gmpints.h>                /* integers */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/listoper.h>               /* operations for generic lists */
#include <src/listfunc.h>               /* functions for generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */
#include <src/opers.h>                  /* TRY_NEXT_METHOD */
#include <src/range.h>                  /* Ranges */
#include <src/code.h>                   /* Coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */


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
  return Fail != POS_LIST( listR, objL, INTOBJ_INT(0L) );
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
    listS = NEW_PLIST( IS_MUTABLE_OBJ(listL) ||  IS_MUTABLE_OBJ(listR) ?
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
    listS = NEW_PLIST( IS_MUTABLE_OBJ(listR) || IS_MUTABLE_OBJ(listL) ?
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
    UInt                mutS;

    /* get and check the length                                            */
    lenL = LEN_LIST( listL );
    lenR = LEN_LIST( listR );
    lenS = (lenR > lenL) ? lenR : lenL;
    listS = NEW_PLIST( (IS_MUTABLE_OBJ(listL) || IS_MUTABLE_OBJ(listR)) ?
                       T_PLIST : T_PLIST+IMMUTABLE, lenS );
    SET_LEN_PLIST( listS, lenS );

    /* Sort out mutability */
    mutS = 0;
    for (i = 1; i <= lenL; i++)
      if ((elmL = ELM0_LIST( listL, i)))
        {
          mutS = IS_MUTABLE_OBJ(elmL);
          break;
        }
    for (i = 1; i <= lenR; i++)
      if ((elmR = ELM0_LIST( listR, i)))
        {
          mutS = mutS || IS_MUTABLE_OBJ(elmR);
          break;
        }
    
    /* loop over the entries and add                                       */
    for ( i = 1; i <= lenS; i++ ) {
      elmL = ELM0_LIST( listL, i ) ;
      elmR = ELM0_LIST( listR, i ) ;
      elmS =  elmL ? (elmR ? SUM( elmL, elmR ) : mutS ? SHALLOW_COPY_OBJ(elmL): elmL) :
        elmR ? (mutS ? SHALLOW_COPY_OBJ(elmR): elmR) : 0;
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



Obj             ZeroListDefault (
    Obj                 list )
{
    Obj                 res;
/*  Obj                 elm; */
    Int                 len;
    Int                 i;

    /* make the result list -- same mutability as argument */
    len = LEN_LIST( list );
    res = NEW_PLIST( IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST+IMMUTABLE, len );
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
          RetypeBag(res, TNUM_OBJ(list));
        else if (TNUM_OBJ(list) >= T_PLIST_CYC &&
                 TNUM_OBJ(list) < T_PLIST_FFE)
          RetypeBag(res, IS_MUTABLE_OBJ(list) ? T_PLIST_CYC : T_PLIST_CYC+IMMUTABLE);
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


Obj             ZeroListMutDefault (
    Obj                 list )
{
    Obj                 res;
/*  Obj                 elm; */
    Int                 len;
    Int                 i;

    /* make the result list -- always mutable */
    len = LEN_LIST( list );
    res = NEW_PLIST(  T_PLIST ,len );
    SET_LEN_PLIST( res, len );

    /* enter zeroes everywhere                                             */
    /* For now, lets just do the simplest and safest thing */
    for (i = 1; i <= len; i++ )
      {
        Obj tmp = ELM0_LIST( list, i);
        if (tmp) {
          tmp = ZERO_MUT(tmp);
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
            if (HAS_FILT_LIST (list, FN_IS_HOMOG) &&
                !IS_MUTABLE_OBJ(ELM_PLIST(res,1)))
              {
                SET_FILT_LIST( res, FN_IS_HOMOG);
              }
          }
        else if (HAS_FILT_LIST(list, FN_IS_NDENSE))
          SET_FILT_LIST( res, FN_IS_NDENSE );
      }

    /* return the result                                                   */
    return res;
}

Obj             ZeroListMutDefaultHandler (
    Obj                 self,
    Obj                 list )
{
    return ZeroListMutDefault( list );
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
*F  AInvListDefault(<list>) . . . . . . . . . . .  additive inverse of a list
*F  AInvMutListDefault
**
**  'AInvList' is the extended dispatcher for  the additive inverse involving
**  lists.  That is, whenever  the additive inverse for  lists is called  and
**  'AInvFuncs' does not   point to a   special function, then  'AInvList' is
**  called.  'AInvList' determines the extended  type of the operand and then
**  dispatches through 'AInvFuncs' again.
**
**  'AInvListDefault' is a generic function for the additive inverse.
*/

Obj AInvMutListDefault (
    Obj                 list )
{
    Obj                 res;
    Obj                 elm;
    Int                 len;
    Int                 i;

    /* make the result list -- always mutable, since this might be a method for
       AdditiveInverseOp */
    len = LEN_LIST( list );
    res = NEW_PLIST( T_PLIST , len );
    SET_LEN_PLIST( res, len );

    /* enter the additive inverses everywhere                              */
    for ( i = 1; i <= len; i++ ) {
        elm = ELM0_LIST( list, i );
        if (elm) {
          elm = AINV_MUT( elm );
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
          RetypeBag(res, T_PLIST_CYC );
        else if (HAS_FILT_LIST(list, FN_IS_DENSE))
          {
            SET_FILT_LIST( res, FN_IS_DENSE );
            if (HAS_FILT_LIST (list, FN_IS_HOMOG) &&
                !IS_MUTABLE_OBJ(ELM_PLIST(res,1)))
              {
                SET_FILT_LIST( res, FN_IS_HOMOG);
                
              }
          }
        else if (HAS_FILT_LIST(list, FN_IS_NDENSE))
          SET_FILT_LIST( res, FN_IS_NDENSE );
      }
    /* return the result                                                   */
    return res;
}

Obj AInvMutListDefaultHandler (
    Obj                 self,
    Obj                 list )
{
    return AInvMutListDefault( list );
}

Obj AInvListDefault (
    Obj                 list )
{
    Obj                 res;
    Obj                 elm;
    Int                 len;
    Int                 i;

    /* make the result list -- same mutability as input */
    len = LEN_LIST( list );
    res = NEW_PLIST( IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST+IMMUTABLE , len );
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
          RetypeBag(res, TNUM_OBJ(list));
        else if (TNUM_OBJ(list) >= T_PLIST_CYC &&
                 TNUM_OBJ(list) < T_PLIST_FFE)
          RetypeBag(res, IS_MUTABLE_OBJ(list) ? T_PLIST_CYC : T_PLIST_CYC+IMMUTABLE );
        else if (HAS_FILT_LIST(list, FN_IS_DENSE))
          {
            SET_FILT_LIST( res, FN_IS_DENSE );
            if (HAS_FILT_LIST (list, FN_IS_HOMOG) &&
                !IS_MUTABLE_OBJ(ELM_PLIST(res,1)))
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
    listD = NEW_PLIST(IS_MUTABLE_OBJ(listL) || IS_MUTABLE_OBJ(listR) ? T_PLIST :
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
    listD = NEW_PLIST( IS_MUTABLE_OBJ(listL)|| IS_MUTABLE_OBJ(listR) ? T_PLIST :
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
    UInt                mutD;

    /* get and check the length                                            */
    lenL = LEN_LIST( listL );
    lenR = LEN_LIST( listR );
    lenD = (lenR > lenL) ? lenR : lenL;
    listD = NEW_PLIST( (IS_MUTABLE_OBJ(listL) || IS_MUTABLE_OBJ(listR)) ?
                       T_PLIST : T_PLIST+IMMUTABLE, lenD );
    SET_LEN_PLIST( listD, lenD );

    /* Sort out mutability */
    mutD = 0;
    for (i = 1; i <= lenL; i++)
      if ((elmL = ELM0_LIST( listL, i)))
        {
          mutD = IS_MUTABLE_OBJ(elmL);
          break;
        }
    for (i = 1; i <= lenR; i++)
      if ((elmR = ELM0_LIST( listR, i)))
        {
          mutD = mutD || IS_MUTABLE_OBJ(elmR);
          break;
        }    
           
    
    /* loop over the entries and subtract                                  */
    for ( i = 1; i <= lenD; i++ ) {
        elmL = ELM0_LIST( listL, i );
        elmR = ELM0_LIST( listR, i );
        

        /* Now compute the result 6 different cases! */
        if (elmL)
          {
            if (elmR)
              elmD= DIFF(elmL,elmR);
            else if ( mutD)
              elmD = SHALLOW_COPY_OBJ(elmL);
            else
              elmD = elmL;
          }
        else if (elmR)
          {
            if (mutD)
              elmD = AINV_MUT(elmR);
            else
              elmD = AINV(elmR);
          }
        else
          elmD = 0;
          
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
    listP = NEW_PLIST( IS_MUTABLE_OBJ(listL) || IS_MUTABLE_OBJ(listR) ?
                       T_PLIST :T_PLIST+IMMUTABLE, len );
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
    Int                 imm;

    /* get and check the length                                            */
    lenL = LEN_LIST( listL );
    lenR = LEN_LIST( listR );
    len =  (lenL < lenR) ? lenL : lenR;
    /* loop over the entries and multiply and accumulate                   */
    listP = 0;
    imm = 0;
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
              {
                listP = elmP;
                imm = !IS_MUTABLE_OBJ(listP);
              }
          }
    }

    if (imm && IS_MUTABLE_OBJ(listP))
      MakeImmutable(listP);

    if (!listP)
      ErrorMayQuit("Inner product multiplication of lists: no summands", 0, 0);
    
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
    Obj                 listR,
    Obj                 depthdiff)
{
  Obj prod;
  prod = ProdListList( listL, listR );

  /* possibly adjust mutability */
  if (!IS_MUTABLE_OBJ(prod))
    switch (INT_INTOBJ(depthdiff)) {
    case -1:
      if (IS_MUTABLE_OBJ(listL))
        prod = SHALLOW_COPY_OBJ(prod);
      break;
    case 1:
      if (IS_MUTABLE_OBJ(listR))
        prod = SHALLOW_COPY_OBJ(prod);
      break;
    case 0:
      break;
    default:
      ErrorReturnVoid("PROD_LIST_LIST_DEFAULT: depth difference should be -1, 0 or 1, not %i",
                      INT_INTOBJ(depthdiff),0L,"you can return to carry on anyway");
    }
  return prod;
        
}


/****************************************************************************
**
*F  OneMatrix(<list>, <mut>) . . .  . . . . . . . . . . . . . . one of a list
**
**
**  'OneMatrix' is a generic function for the one. mut may be 0, for an
**  immutable result, 1 for a result of the same mutability level as <list>
**  and 2 for a fully mutable result.
*/

Obj             OneMatrix (
    Obj                 mat,
    UInt                mut)
{
    Obj                 res = 0;        /* one, result                     */
    Obj                 row;            /* one row of the result           */
    Obj                 zero = 0;       /* zero element                    */
    Obj                 one = 0;        /* one element                     */
    UInt                len;            /* length (and width) of matrix    */
    UInt                i, k;           /* loop variables                  */
    UInt                rtype= 0;       /* tnum for rows of result        */
    UInt                ctype = 0;      /* tnum for  result        */

    /* check that the operand is a *square* matrix                         */
    len = LEN_LIST( mat );
    if ( len != LEN_LIST( ELM_LIST( mat, 1 ) ) ) {
        return ErrorReturnObj(
            "Matrix ONE: <mat> must be square (not %d by %d)",
            (Int)len, (Int)LEN_LIST( ELM_LIST( mat, 1 ) ),
            "you can replace ONE matrix <mat> via 'return <mat>;'" );
    }

    /* get the zero and the one                                            */
    switch (mut) {
    case 0:
      zero = ZERO_MUT( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
      one  = ONE_MUT( zero );
      MakeImmutable(zero);
      MakeImmutable(one);
      ctype = rtype = T_PLIST+IMMUTABLE;
      break;
      
    case 1:
      zero = ZERO_MUT( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
      one  = ONE_MUT( zero );
      if (IS_MUTABLE_OBJ(mat))
        {
          ctype = T_PLIST;
          rtype = IS_MUTABLE_OBJ(ELM_LIST(mat, 1)) ? T_PLIST : T_PLIST + IMMUTABLE;
        }
      else
        ctype = rtype = T_PLIST + IMMUTABLE;
      break;

    case 2:
      zero = ZERO( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
      one  = ONE( zero );
      ctype = rtype = T_PLIST;
      break;
    }

    

    /* make the identity matrix                                            */
    res = NEW_PLIST(  ctype, len );
    SET_LEN_PLIST( res, len );
    for ( i = 1; i <= len; i++ ) {
        row = NEW_PLIST( rtype , len );
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

Obj             FuncOneMatrixImmutable (
    Obj                 self,
    Obj                 list )
{
    return OneMatrix( list,0 );
}

Obj             FuncOneMatrixSameMutability (
    Obj                 self,
    Obj                 list )
{
    return OneMatrix( list,1 );
}

Obj             FuncOneMatrixMutable (
    Obj                 self,
    Obj                 list )
{
    return OneMatrix( list,2 );
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

Obj             InvMatrix (
    Obj                 mat,
    UInt                mut)
{
    Obj                 res = 0;        /* power, result                   */
    Obj                 row;            /* one row of the matrix           */
    Obj                 row2;           /* another row of the matrix       */
    Obj                 elm;            /* one element of the matrix       */
    Obj                 elm2;           /* another element of the matrix   */
    Obj                 zero = 0;       /* zero element                    */
    Obj                 one = 0;        /* one element                     */
    UInt                len;            /* length (and width) of matrix    */
    UInt                i, k, l;        /* loop variables                  */
    UInt                rtype = 0, ctype = 0;   /* types for lists to be created   */

    /* check that the operand is a *square* matrix                         */
    len = LEN_LIST( mat );
    if ( len != LEN_LIST( ELM_LIST( mat, 1 ) ) ) {
        return ErrorReturnObj(
            "Matrix INV: <mat> must be square (not %d by %d)",
            (Int)len, (Int)LEN_LIST( ELM_LIST( mat, 1 ) ),
            "you can replace <mat> via 'return <mat>;'" );
    }

    /* get the zero and the one                                            */
    switch(mut)
      {
      case 0:
        zero = ZERO_MUT( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
        one  = ONE_MUT( zero );
        ctype = rtype = T_PLIST+IMMUTABLE;
        MakeImmutable(zero);
        MakeImmutable(one);
        break;
        
      case 1:
        zero = ZERO_MUT( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
        one  = ONE_MUT( zero );
        if (IS_MUTABLE_OBJ(mat))
          {
            ctype = T_PLIST;
            rtype = IS_MUTABLE_OBJ(ELM_LIST(mat, 1)) ? T_PLIST : T_PLIST+IMMUTABLE;
          }
        else
          ctype = rtype = T_PLIST+IMMUTABLE;
        break;

      case 2:
        zero = ZERO( ELM_LIST( ELM_LIST( mat, 1 ), 1 ) );
        one  = ONE( zero );
        ctype = rtype = T_PLIST;
        break;
      }

    /* make a matrix of the form $ ( Id_<len> | <mat> ) $                  */
    res = NEW_PLIST( ctype, len );
    SET_LEN_PLIST( res, len );
    for ( i = 1; i <= len; i++ ) {
        row = NEW_PLIST( rtype, 2 * len );
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
        if (mut < 2)
          elm2 = INV_MUT( ELM_PLIST( row, k ) );
        else
          elm2 = INV( ELM_PLIST( row, k ) );
        for ( l = 1; l <= 2*len; l++ ) {
            elm = PROD( elm2, ELM_PLIST( row, l ) );
            SET_ELM_PLIST( row, l, elm );
            CHANGED_BAG( row );
        }

        /* clear all entries in this column                                */
        for ( i = 1; i <= len; i++ ) {
            row2 = ELM_PLIST( res, i );
            if (mut < 2)
              elm = AINV_MUT( ELM_PLIST( row2, k ) );
            else
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

Obj FuncINV_MATRIX_MUTABLE( Obj self, Obj mat)
{
  return InvMatrix(mat, 2);
}

Obj FuncINV_MATRIX_SAME_MUTABILITY( Obj self, Obj mat)
{
  return InvMatrix(mat, 1);
}

Obj FuncINV_MATRIX_IMMUTABLE( Obj self, Obj mat)
{
  return InvMatrix(mat, 0);
}

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
/*Obj o;  */
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

Obj ConvertToMatrixRep;

Obj InvMatWithRowVecs( Obj mat, UInt mut)
{
  Obj                 res;            /* result                          */
  Obj                 matcopy;        /* copy of mat                     */
  Obj                 row = 0;            /* one row of matcopy              */
  Obj                 row2;           /* corresponding row of res        */
  Obj                 row3;           /* another row of matcopy          */
  Obj                 x = 0;              /* one element of the matrix       */
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
    switch( mut) {
    case 0:
      res = INV(mat);
      MakeImmutable(res);
      return res;
      break;
    case 1:
      return INV_MUT(mat);
      break;
    case 2:
      return INV(mat);
      break;
    }
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

  /* Now we adjust mutability. Couldn't do it earlier, because AddRowVector, etc.
     needs mutable target vectors */
  switch (mut)
    {
    case 0:
      MakeImmutable(res);
      break;
      
    case 1:
      if (IS_MUTABLE_OBJ(mat))
        {
          if (!IS_MUTABLE_OBJ(ELM_LIST(mat,1)))
            for (i = 1; i <= len; i++)
              MakeImmutable(ELM_LIST(res,i));
        }
      else
        MakeImmutable(res);
      break;
    case 2:
      break;
    }
  
  return res;
}


Obj FuncINV_MAT_DEFAULT_MUTABLE ( Obj self, Obj mat)
{
  return InvMatWithRowVecs(mat, 2);
}

Obj FuncINV_MAT_DEFAULT_SAME_MUTABILITY ( Obj self, Obj mat)
{
  return InvMatWithRowVecs(mat, 1);
}

Obj FuncINV_MAT_DEFAULT_IMMUTABLE ( Obj self, Obj mat)
{
  return InvMatWithRowVecs(mat, 0);
}

  
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
*F  MONOM_GRLLEX( u, v ) . . . . . ``grlex'' ordering for internal monomials
**
**  This function  implements the ``grlex'' (degree, then lexicographic) ordering
**  for monomials  of commuting indeterminates with x_1>x_2>x_3 etc. (this
**  is standard textbook usage). It is in this  file because
**  monomials  are presently implemented  as lists  of indeterminate-exponent
**  pairs.  Should there be  more functions supporting polynomial arithmetic,
**  then this function should go into a separate file.
**
**  Examples:      x^2y^3 < y^7,   x^4 y^5 < x^3 y^6
*/
static Obj  FuncMONOM_GRLEX( Obj self, Obj u, Obj  v ) {

  Int4 i, lu, lv;

  Obj  total,ai,bi;
 
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

  /* compare the total degrees */
  total = INTOBJ_INT(0);
  for (i=2;i<=lu;i+=2) {
    C_SUM_FIA(  total, total, ELM_PLIST( u, i ) );
  }

  for (i=2;i<=lv;i+=2) {
    C_DIFF_FIA(  total, total, ELM_PLIST( v, i ) );
  }

  if ( ! (EQ( total, INTOBJ_INT(0))) ) {
    /* degrees differ, use these */
    return LT( total, INTOBJ_INT(0)) ? True : False;
  }

  /* now use lexicographic ordering */
  i=1;
  while (i<=lu && i<=lv) {
    ai=ELM_PLIST(u,i);
    bi=ELM_PLIST(v,i);
    if (LT(bi,ai)) {
      return True;
    }
    if (LT(ai,bi)) {
      return False;
    }
    ai=ELM_PLIST(u,i+1);
    bi=ELM_PLIST(v,i+1);
    if (LT(ai,bi)) {
      return True;
    }
    if (LT(bi,ai)) {
      return False;
    }
    i+=2;
  }
  if (i<lv) {
      return True;
  }
  return False;
}


/****************************************************************************
**
*F  ZIPPED_SUM_LISTS(z1,z2,zero,f)
**
**  implements the `ZippedSum' function to add polynomials in external
**  representation. This is time critical and thus in the kernel.
**  the function assumes that all lists are plists.
*/
static Obj  FuncZIPPED_SUM_LISTS( Obj self, Obj z1, Obj  z2, Obj zero, Obj f ) {

  Int l1,l2,i;
  Int i1,i2;
  Obj sum,x,y;
  Obj cmpfun,sumfun,a,b,c;

  l1=LEN_LIST(z1);
  l2=LEN_LIST(z2);
  cmpfun=ELM_LIST(f,1);
  sumfun=ELM_LIST(f,2);
  sum=NEW_PLIST(T_PLIST,0);
  SET_LEN_PLIST(sum,0);
  i1=1;
  i2=1;
  while ((i1<=l1) && (i2<=l2)) {
/* Pr("A= %d %d\n",i1,i2); */
    /* if z1[i1] = z2[i2] then */
    a=ELM_PLIST(z1,i1);
    b=ELM_PLIST(z2,i2);
    if (EQ(a,b)) {
      /* the entries are equal */
      x=ELM_PLIST(z1,i1+1);
      y=ELM_PLIST(z2,i2+1);
/* Pr("EQ, %d %d\n",INT_INTOBJ(x),INT_INTOBJ(y)); */
      c=CALL_2ARGS(sumfun,x,y);
      if (!(EQ(c,zero))) {
/* Pr("Added %d\n",INT_INTOBJ(c),0L); */
        AddList(sum,a);
        AddList(sum,c);
      }
      i1=i1+2;
      i2=i2+2;
    }
    else {
      /* compare */
      a=ELM_PLIST(z1,i1); /* in case the EQ triggered a GC */
      b=ELM_PLIST(z2,i2);
/* Pr("B= %d %d\n",ELM_LIST(a,1),ELM_LIST(b,1)); */
      c=CALL_2ARGS(cmpfun,a,b);
/* Pr("C= %d %d\n",c,0L); */

      if ( /* this construct is taken from the compiler */
          (Obj)(UInt)(c != False) ) {
        a=ELM_PLIST(z1,i1); 
        AddList(sum,a);
        c=ELM_PLIST(z1,i1+1);
        AddList(sum,c);
        i1=i1+2;
      }
      else {
        b=ELM_PLIST(z2,i2); 
        AddList(sum,b);
        c=ELM_PLIST(z2,i2+1);
        AddList(sum,c);
        i2=i2+2;
      } /* else */
    } /*else (elif)*/
  } /* while */

  for (i=i1;i<l1;i+=2) {
    AddList(sum,ELM_PLIST(z1,i));
    AddList(sum,ELM_PLIST(z1,i+1));
  }

  for (i=i2;i<l2;i+=2) {
    AddList(sum,ELM_PLIST(z2,i));
    AddList(sum,ELM_PLIST(z2,i+1));
  }
  return sum;

}

/****************************************************************************
**
*F  FuncMONOM_PROD(m1,m2)
**
**  implements the multiplication of monomials. Both must be plain lists 
**  of integers.
*/
static Obj  FuncMONOM_PROD( Obj self, Obj m1, Obj m2 ) {

   UInt a,b,l1,l2,i1,i2,i;
   Obj e,f,c,prod;

   prod=NEW_PLIST(T_PLIST,0);
   SET_LEN_PLIST(prod,0);
   l1=LEN_LIST(m1);
   l2=LEN_LIST(m2);
   i1=1;
   i2=1;
   while ((i1<l1) && (i2<l2)) {
     /* assume <2^28 variables) */
     a=INT_INTOBJ(ELM_PLIST(m1,i1));
     e=ELM_PLIST(m1,i1+1);
     b=INT_INTOBJ(ELM_PLIST(m2,i2));
     f=ELM_PLIST(m2,i2+1);
     if (a==b) {
       C_SUM_FIA(c,e,f); /* c=e+f, fast */
       AddList(prod,INTOBJ_INT(a));
       AddList(prod,c);
       i1+=2;
       i2+=2;
     }
     else {
       if (a<b) {
         AddList(prod,INTOBJ_INT(a));
         AddList(prod,e);
         i1+=2;
       }
       else {
         AddList(prod,INTOBJ_INT(b));
         AddList(prod,f);
         i2+=2;
       }
     }

   }

  for (i=i1;i<l1;i+=2) {
    AddList(prod,ELM_PLIST(m1,i));
    AddList(prod,ELM_PLIST(m1,i+1));
  }

  for (i=i2;i<l2;i+=2) {
    AddList(prod,ELM_PLIST(m2,i));
    AddList(prod,ELM_PLIST(m2,i+1));
  }
  return prod;

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

    { "ZERO_MUT_LIST_DEFAULT", 1, "list",
      ZeroListMutDefaultHandler, "src/listoper.c:ZERO_MUT_LIST_DEFAULT" },

    { "ZERO_ATTR_MAT", 1, "mat",
      ZeroAttrMat, "src/listoper.c:ZERO_ATTR_MAT" },

    { "AINV_LIST_DEFAULT", 1, "list",
      AInvListDefaultHandler, "src/listoper.c:AINV_LIST_DEFAULT" },

    { "AINV_MUT_LIST_DEFAULT", 1, "list",
      AInvMutListDefaultHandler, "src/listoper.c:AINV_MUT_LIST_DEFAULT" },

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

    { "PROD_LIST_LIST_DEFAULT", 3, "listL, listR, depthDiff",
      ProdListListHandler, "src/listoper.c:PROD_LIST_LIST_DEFAULT" },

    { "ONE_MATRIX_MUTABLE", 1, "list",
      FuncOneMatrixMutable, "src/listoper.c:ONE_MATRIX_MUTABLE" },

    { "ONE_MATRIX_SAME_MUTABILITY", 1, "list",
      FuncOneMatrixSameMutability, "src/listoper.c:ONE_MATRIX_SAME_MUTABILITY" },

    { "ONE_MATRIX_IMMUTABLE", 1, "list",
      FuncOneMatrixImmutable, "src/listoper.c:ONE_MATRIX_IMMUTABLE" },

    { "INV_MATRIX_MUTABLE", 1, "list",
      FuncINV_MATRIX_MUTABLE, "src/listoper.c:INV_MATRIX_MUTABLE" },

    { "INV_MATRIX_SAME_MUTABILITY", 1, "list",
      FuncINV_MATRIX_SAME_MUTABILITY, "src/listoper.c:INV_MATRIX_SAME_MUTABILITY" },

    { "INV_MATRIX_IMMUTABLE", 1, "list",
      FuncINV_MATRIX_IMMUTABLE, "src/listoper.c:INV_MATRIX_IMMUTABLE" },

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
    
    { "INV_MAT_DEFAULT_MUTABLE", 1, "mat",
      FuncINV_MAT_DEFAULT_MUTABLE, "src/listoper.c:INV_MAT_DEFAULT_MUTABLE" },

    { "INV_MAT_DEFAULT_SAME_MUTABILITY", 1, "mat",
      FuncINV_MAT_DEFAULT_SAME_MUTABILITY, "src/listoper.c:INV_MAT_DEFAULT_SAME_MUTABILITY" },

    { "INV_MAT_DEFAULT_IMMUTABLE", 1, "mat",
      FuncINV_MAT_DEFAULT_IMMUTABLE, "src/listoper.c:INV_MAT_DEFAULT_IMMUTABLE" },

    { "ADD_TO_LIST_ENTRIES_PLIST_RANGE", 3, "list, range, x",
      FuncADD_TO_LIST_ENTRIES_PLIST_RANGE, "src/listfunc.c:ADD_TO_LIST_ENTRIES_PLIST_RANGE" },

    { "MONOM_TOT_DEG_LEX", 2, "monomial, monomial",
      FuncMONOM_TOT_DEG_LEX, "src/ratfun.c:FuncMONOM_TOT_DEG_LEX" },

    { "MONOM_GRLEX", 2, "monomial, monomial",
      FuncMONOM_GRLEX, "src/ratfun.c:FuncMONOM_GRLEX" },

    { "ZIPPED_SUM_LISTS", 4, "list,list,zero,funclist",
      FuncZIPPED_SUM_LISTS, "src/ratfun.c:FuncZIPPED_SUM_LISTS" },

    { "MONOM_PROD", 2, "monomial, monomial",
      FuncMONOM_PROD, "src/ratfun.c:FuncMONOM_PROD" },

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

    for (t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1 ++ ) {
            ZeroFuncs[t1] = ZeroListDefault;
            ZeroMutFuncs[t1] = ZeroListMutDefault;
    }

    for (t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1 ++ ) {
            AInvFuncs[t1] = AInvListDefault;
            AInvMutFuncs[t1] = AInvMutListDefault;
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


       everything else needs to wait until the library */
       
    for (t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
      for (t2 = FIRST_REAL_TNUM; t2 < FIRST_LIST_TNUM; t2++ ) {
        SumFuncs[t1][t2] = SumListScl;
        SumFuncs[t2][t1] = SumSclList;
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
    return &module;
}


/****************************************************************************
**

*E  listoper.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
