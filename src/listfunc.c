/****************************************************************************
**
*W  listfunc.c                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions for generic lists.
*/
#include        "system.h"              /* Ints, UInts                     */

SYS_CONST char * Revision_listfunc_c =
   "@(#)$Id$";


#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "string.h"              /* strings                         */

#include        "bool.h"                /* booleans                        */

#include        "permutat.h"            /* permutations                    */

#define INCLUDE_DECLARATION_PART
#include        "listfunc.h"            /* functions for generic lists     */
#undef  INCLUDE_DECLARATION_PART

#include        "plist.h"               /* plain lists                     */
#include        "set.h"                 /* plain sets                      */
#include        "range.h"               /* ranges                          */


/****************************************************************************
**

*F  AddList(<list>,<obj>) . . . . . . . .  add an object to the end of a list
**
**  'AddList' adds the object <obj> to the end  of  the  list  <list>,  i.e.,
**  it is equivalent to the assignment '<list>[ Length(<list>)+1 ] := <obj>'.
**  The  list is  automatically extended to   make room for  the new element.
**  'AddList' returns nothing, it is called only for its sideeffect.
*/
void            AddList (
    Obj                 list,
    Obj                 obj )
{
    Int                 pos;            /* position to assign to           */
    pos = LEN_LIST( list ) + 1;
    ASS_LIST( list, pos, obj );
}

extern Obj AddListHandler(
    Obj                 self,
    Obj                 list,
    Obj                 obj );

void            AddPlist (
    Obj                 list,
    Obj                 obj )
{
    Int                 pos;            /* position to assign to           */

    if ( ! IS_MUTABLE_PLIST(list) ) {
        list = ErrorReturnObj(
                "Lists Assignment: <list> must be a mutable list",
                0L, 0L,
                "you may return a mutable list" );
        AddListHandler( 0, list, obj );
        return;
    }
    RetypeBag( list, T_PLIST );
    pos = LEN_PLIST( list ) + 1;
    GROW_PLIST( list, pos );
    SET_LEN_PLIST( list, pos );
    SET_ELM_PLIST( list, pos, obj );
    CHANGED_BAG( list );
}

Obj             AddListOper;

Obj             AddListHandler (
    Obj                 self,
    Obj                 list,
    Obj                 obj )
{
    /* dispatch                                                            */
    if ( T_PLIST          <= TNUM_OBJ( list )
      && TNUM_OBJ( list ) <= T_PLIST_CYC_SSORT ) {
        AddPlist( list, obj );
    }
    else if ( TNUM_OBJ( list ) < FIRST_EXTERNAL_TNUM ) {
        AddList( list, obj );
    }
    else {
        DoOperation2Args( self, list, obj );
    }

    /* return nothing                                                      */
    return (Obj)0;
}


/****************************************************************************
**
*F  AppendListHandler(<list1>,<list2>)  . . . . . . append elements to a list
**
**  'AppendListHandler' implements the function 'AppendList'.
**
**  'AppendList(<list1>,<list2>)'
**
**  'AppendList' adds (see "Add") the elements of the list <list2> to the end
**  of the list <list1>. It is allowed that <list2> contains empty positions,
**  in which case the corresponding positions  will be left empty in <list1>.
**  'AppendList' returns nothing, it is called only for its side effect.
*/
Obj             AppendListIntrHandler (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    Int                 len1;           /* length of the first list        */
    Int                 len2;           /* length of the second list       */
    Obj *               ptr1;           /* pointer into the first list     */
    Obj *               ptr2;           /* pointer into the second list    */
    Obj                 elm;            /* one element of the second list  */
    Int                 i;              /* loop variable                   */

    /* check the type of the first argument                                */
    if ( TNUM_OBJ( list1 ) != T_PLIST ) {
        while ( ! IS_LIST( list1 ) ) {
            list1 = ErrorReturnObj(
                "AppendList: <list1> must be a list (not a %s)",
                (Int)TNAM_OBJ(list1), 0L,
                "you can return a list for <list1>" );
        }
        PLAIN_LIST( list1 );
        RetypeBag( list1, T_PLIST );
    }
    len1 = LEN_PLIST( list1 );

    /* check the type of the second argument                               */
    if ( TNUM_OBJ( list2 ) != T_PLIST ) {
        while ( ! IS_LIST( list2 ) ) {
            list2 = ErrorReturnObj(
                "AppendList: <list2> must be a list (not a %s)",
                (Int)TNAM_OBJ(list2), 0L,
                "you can return a list for <list2>"  );
        }
        len2 = LEN_LIST( list2 );
    }
    else {
        len2 = LEN_PLIST( list2 );
    }

    /* if the list has no room at the end, enlarge it                      */
    if ( 0 < len2 ) {
        GROW_PLIST( list1, len1+len2 );
        SET_LEN_PLIST( list1, len1+len2 );
    }

    /* add the elements                                                    */
    if ( TNUM_OBJ(list2) == T_PLIST ) {
        ptr1 = ADDR_OBJ(list1) + len1;
        ptr2 = ADDR_OBJ(list2);
        for ( i = 1; i <= len2; i++ ) {
            ptr1[i] = ptr2[i];
            /* 'CHANGED_BAG(list1);' not needed, ELM_PLIST does not NewBag */
        }
        CHANGED_BAG( list1 );
    }
    else {
        for ( i = 1; i <= len2; i++ ) {
            elm = ELMV0_LIST( list2, i );
            SET_ELM_PLIST( list1, i+len1, elm );
            CHANGED_BAG( list1 );
        }
    }

    /* return void                                                         */
    return (Obj)0;
}

Obj             AppendListOper;

Obj             AppendListHandler (
    Obj                 self,
    Obj                 list,
    Obj                 obj )
{
    /* dispatch                                                            */
    if ( TNUM_OBJ( list ) < FIRST_EXTERNAL_TNUM ) {
        AppendListIntrHandler( 0, list, obj );
    }
    else {
        DoOperation2Args( self, list, obj );
    }

    /* return nothing                                                      */
    return (Obj)0;
}

/****************************************************************************
**
*F  PositionSortedList(<list>,<obj>)  . . . . find an object in a sorted list
*F  PositionSortedDensePlist(<list>,<obj>)  . find an object in a sorted list
**
**  'PositionSortedList' returns the position of the  object <obj>, which may
**  be an object of any type, with respect to the sorted list <list>.
**
**  'PositionSortedList' returns  <pos>  such that  '<list>[<pos>-1] < <obj>'
**  and '<obj> <= <list>[<pos>]'.  That means if <obj> appears once in <list>
**  its position is returned.  If <obj> appears several  times in <list>, the
**  position of the first occurrence is returned.  If <obj> is not an element
**  of <list>, the index where <obj> must be inserted to keep the list sorted
**  is returned.
*/
UInt            PositionSortedList (
    Obj                 list,
    Obj                 obj )
{
    UInt                l;              /* low                             */
    UInt                h;              /* high                            */
    UInt                m;              /* mid                             */
    Obj                 v;              /* one element of the list         */

    /* perform the binary search to find the position                      */
    l = 0;  h = LEN_LIST( list ) + 1;
    while ( l+1 < h ) {                 /* list[l] < obj && obj <= list[h] */
        m = (l + h) / 2;                /* l < m < h                       */
        v = ELMV_LIST( list, m );
        if ( LT( v, obj ) ) { l = m; }
        else                { h = m; }
    }

    /* return the position                                                 */
    return h;
}

UInt            PositionSortedDensePlist (
    Obj                 list,
    Obj                 obj )
{
    UInt                l;              /* low                             */
    UInt                h;              /* high                            */
    UInt                m;              /* mid                             */
    Obj                 v;              /* one element of the list         */

    /* perform the binary search to find the position                      */
    l = 0;  h = LEN_PLIST( list ) + 1;
    while ( l+1 < h ) {                 /* list[l] < obj && obj <= list[h] */
        m = (l + h) / 2;                /* l < m < h                       */
        v = ELM_PLIST( list, m );
        if ( LT( v, obj ) ) { l = m; }
        else                { h = m; }
    }

    /* return the position                                                 */
    return h;
}

Obj             PositionSortedListHandler (
    Obj                 self,
    Obj                 list,
    Obj                 obj )
{
    UInt                h;              /* position, result                */

    /* check the first argument                                            */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "PositionSortedList: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can return a list for <list>" );
    }

    /* dispatch                                                            */
    if ( T_PLIST_DENSE  <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_PLIST_CYC_SSORT ) {
        h = PositionSortedDensePlist( list, obj );
    }
    else {
        h = PositionSortedList( list, obj );
    }

    /* return the result                                                   */
    return INTOBJ_INT( h );
}


/****************************************************************************
**
*F  PositionSortedListComp(<list>,<obj>,<func>)  . . find an object in a list
*F  PositionSortedDensePlistComp(<list>,<obj>,<func>)find an object in a list
**
**  'PositionSortedListComp' returns the position of the  object <obj>, which
**  may be an object of any type, with respect to the list <list>,  which  is
**  sorted with respect to the comparison function <func>.
**
**  'PositionSortedListComp' returns <pos> such that '<list>[<pos>-1] < <obj>'
**  and '<obj> <= <list>[<pos>]'.  That means if <obj> appears once in <list>
**  its position is returned.  If <obj> appears several  times in <list>, the
**  position of the first occurrence is returned.  If <obj> is not an element
**  of <list>, the index where <obj> must be inserted to keep the list sorted
**  is returned.
*/
UInt            PositionSortedListComp (
    Obj                 list,
    Obj                 obj,
    Obj                 func )
{
    UInt                l;              /* low                             */
    UInt                h;              /* high                            */
    UInt                m;              /* mid                             */
    Obj                 v;              /* one element of the list         */

    /* perform the binary search to find the position                      */
    l = 0;  h = LEN_LIST( list ) + 1;
    while ( l+1 < h ) {                 /* list[l] < obj && obj <= list[h] */
        m = (l + h) / 2;                /* l < m < h                       */
        v = ELMV_LIST( list, m );
        if ( CALL_2ARGS( func, v, obj ) == True ) { l = m; }
        else                                      { h = m; }
    }

    /* return the position                                                 */
    return h;
}

UInt            PositionSortedDensePlistComp (
    Obj                 list,
    Obj                 obj,
    Obj                 func )
{
    UInt                l;              /* low                             */
    UInt                h;              /* high                            */
    UInt                m;              /* mid                             */
    Obj                 v;              /* one element of the list         */

    /* perform the binary search to find the position                      */
    l = 0;  h = LEN_PLIST( list ) + 1;
    while ( l+1 < h ) {                 /* list[l] < obj && obj <= list[h] */
        m = (l + h) / 2;                /* l < m < h                       */
        v = ELM_PLIST( list, m );
        if ( CALL_2ARGS( func, v, obj ) == True ) { l = m; }
        else                                      { h = m; }
    }

    /* return the position                                                 */
    return h;
}

Obj             PositionSortedListCompHandler (
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 func )
{
    UInt                h;              /* position, result                */

    /* check the first argument                                            */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "PositionSortedListComp: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can return a list for <list>" );
    }

    /* check the third argument                                            */
    while ( TNUM_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "PositionSortedListComp: <func> must be a function (not a %s)",
            (Int)TNAM_OBJ(func), 0L,
            "you can return a function for <func>" );
    }

    /* dispatch                                                            */
    if ( T_PLIST_DENSE  <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_PLIST_CYC_SSORT ) {
        h = PositionSortedDensePlistComp( list, obj, func );
    }
    else {
        h = PositionSortedListComp( list, obj, func );
    }

    /* return the result                                                   */
    return INTOBJ_INT( h );
}


/****************************************************************************
**
*F  SortList(<list>)  . . . . . . . . . . . . . . . . . . . . . . sort a list
*F  SortDensePlist(<list>)  . . . . . . . . . . . . . . . . . . . sort a list
**
**  'SortList' sorts the list <list> in increasing  order.
**
**  'Sort' uses Shell's diminishing increment sort, which extends bubblesort.
**  The bubble sort works by  running  through  the  list  again  and  again,
**  each time exchanging pairs of adjacent elements which are out  of  order.
**  Thus large elements ``bubble'' to the top, hence the name of the  method.
**  However elements need many moves to come close to their  final  position.
**  In shellsort the first passes do not compare element j with its  neighbor
**  but with the element j+h, where h is larger than one.  Thus elements that
**  are not at their final position make large moves towards the destination.
**  This increment h is diminished, until during the last  pass  it  is  one.
**  A good sequence of incremements is given by Knuth:  (3^k-1)/2,... 13,4,1.
**  For this sequence shellsort uses on average  approximatly  N^1.25  moves.
**
**  Shellsort is the method of choice to  sort  lists  for  various  reasons:
**  Shellsort is quite easy to get right, much easier than,  say,  quicksort.
**  It runs as fast as quicksort for lists with  less  than  ~5000  elements.
**  It handles both  almost  sorted  and  reverse  sorted  lists  very  good.
**  It works well  in  the  presence  of  duplicate  elements  in  the  list.
**  Says Sedgewick: ``In short, if you have a sorting problem,  use the above
**  program, then determine whether the extra effort required to  replace  it
**  with a sophisticated method will be worthwile.''
**
**  Donald Knuth, The Art of Computer Programming, Vol.3, AddWes 1973, 84-95
**  Donald Shell, CACM 2, July 1959, 30-32
**  Robert Sedgewick, Algorithms 2nd ed., AddWes 1988, 107-123
*/
void            SortList (
    Obj                 list )
{
    UInt                len;            /* length of the list              */
    UInt                h;              /* gap width in the shellsort      */
    Obj                 v, w;           /* two element of the list         */
    UInt                i, k;           /* loop variables                  */

    /* sort the list with a shellsort                                      */
    len = LEN_LIST( list );
    h = 1;
    while ( 9*h + 4 < len ) { h = 3*h + 1; }
    while ( 0 < h ) {
        for ( i = h+1; i <= len; i++ ) {
            v = ELMV_LIST( list, i );
            k = i;
            w = ELMV_LIST( list, k-h );
            while ( h < k && LT( v, w ) ) {
                ASS_LIST( list, k, w );
                k -= h;
                w = ELMV_LIST( list, k-h );
            }
            ASS_LIST( list, k, v );
        }
        h = h / 3;
    }
}

void            SortDensePlist (
    Obj                 list )
{
    UInt                len;            /* length of the list              */
    UInt                h;              /* gap width in the shellsort      */
    Obj                 v, w;           /* two element of the list         */
    UInt                i, k;           /* loop variables                  */

    /* sort the list with a shellsort                                      */
    len = LEN_PLIST( list );
    h = 1;
    while ( 9*h + 4 < len ) { h = 3*h + 1; }
    while ( 0 < h ) {
        for ( i = h+1; i <= len; i++ ) {
            v = ELM_PLIST( list, i );
            k = i;
            w = ELM_PLIST( list, k-h );
            while ( h < k && LT( v, w ) ) {
                SET_ELM_PLIST( list, k, w );
                k -= h;
                w = ELM_PLIST( list, k-h );
            }
            SET_ELM_PLIST( list, k, v );
        }
        h = h / 3;
    }
}

Obj             SortListHandler (
    Obj                 self,
    Obj                 list )
{
    /* check the first argument                                            */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "SortList: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can return a list for <list>" );
    }

    /* dispatch                                                            */
    if ( T_PLIST_DENSE  <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_PLIST_CYC_SSORT ) {
        SortDensePlist( list );
    }
    else {
        SortList( list );
    }

    /* return nothing                                                      */
    return (Obj)0;
}


/****************************************************************************
**
*F  SortListComp(<list>,<func>) . . . . . . . . . . . . . . . . . sort a list
*F  SortDensePlistComp(<list>,<func>) . . . . . . . . . . . . . . sort a list
**
**  'SortListComp' sorts the list <list> in increasing order, with respect to
**  comparison function <func>.
*/
void            SortListComp (
    Obj                 list,
    Obj                 func )
{
    UInt                len;            /* length of the list              */
    UInt                h;              /* gap width in the shellsort      */
    Obj                 v, w;           /* two element of the list         */
    UInt                i, k;           /* loop variables                  */

    /* sort the list with a shellsort                                      */
    len = LEN_LIST( list );
    h = 1;
    while ( 9*h + 4 < len ) { h = 3*h + 1; }
    while ( 0 < h ) {
        for ( i = h+1; i <= len; i++ ) {
            v = ELMV_LIST( list, i );
            k = i;
            w = ELMV_LIST( list, k-h );
            while ( h < k && CALL_2ARGS( func, v, w ) == True ) {
                ASS_LIST( list, k, w );
                k -= h;
                w = ELMV_LIST( list, k-h );
            }
            ASS_LIST( list, k, v );
        }
        h = h / 3;
    }
}

void            SortDensePlistComp (
    Obj                 list,
    Obj                 func )
{
    UInt                len;            /* length of the list              */
    UInt                h;              /* gap width in the shellsort      */
    Obj                 v, w;           /* two element of the list         */
    UInt                i, k;           /* loop variables                  */

    /* sort the list with a shellsort                                      */
    len = LEN_PLIST( list );
    h = 1;
    while ( 9*h + 4 < len ) { h = 3*h + 1; }
    while ( 0 < h ) {
        for ( i = h+1; i <= len; i++ ) {
            v = ELM_PLIST( list, i );
            k = i;
            w = ELM_PLIST( list, k-h );
            while ( h < k && CALL_2ARGS( func, v, w ) == True ) {
                SET_ELM_PLIST( list, k, w );
                k -= h;
                w = ELM_PLIST( list, k-h );
            }
            SET_ELM_PLIST( list, k, v );
        }
        h = h / 3;
    }
}

Obj             SortListCompHandler (
    Obj                 self,
    Obj                 list,
    Obj                 func )
{
    /* check the first argument                                            */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "SortListComp: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can return a list for <list>" );
    }

    /* check the third argument                                            */
    while ( TNUM_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "SortListComp: <func> must be a function (not a %s)",
            (Int)TNAM_OBJ(func), 0L,
            "you can return a function for <func>" );
    }

    /* dispatch                                                            */
    if ( T_PLIST_DENSE  <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_PLIST_CYC_SSORT ) {
        SortDensePlistComp( list, func );
    }
    else {
        SortListComp( list, func );
    }

    /* return nothing                                                      */
    return (Obj)0;
}


/****************************************************************************
**
*F  RemoveDupsDensePlist(<list>)  . . . . remove duplicates from a plain list
**
**  'RemoveDupsDensePlist' removes  duplicate elements from  the dense  plain
**  list <list>.  <list> must be sorted.  'RemoveDupsDensePlist' returns 1 if
**  <list> contains mutable elements, and 0 otherwise.
*/
UInt            RemoveDupsDensePlist (
    Obj                 list )
{
    UInt                mutable;        /* the elements are mutable        */
    Int                 len;            /* length of the list              */
    Obj                 v, w;           /* two elements of the list        */
    UInt                l, i;           /* loop variables                  */

    /* get the length, nothing to be done for empty lists                  */
    len = LEN_PLIST( list );
    if ( len == 0 ) { return 0; }

    /* select the first element as the first representative                */
    l = 1;
    v = ELM_PLIST( list, l );
    mutable = IS_MUTABLE_OBJ(v);

    /* loop over the other elements, compare them with the current rep.    */
    for ( i = 2; i <= len; i++ ) {
        w = ELM_PLIST( list, i );
        if ( ! EQ( v, w ) ) {
            if ( l+1 != i ) {
                SET_ELM_PLIST( list, l+1, w );
                SET_ELM_PLIST( list, i, (Obj)0 );
            }
            l += 1;
            v = w;
            mutable = (mutable || IS_MUTABLE_OBJ(v));
        }
    }

    /* the list may be shorter now                                         */
    SET_LEN_PLIST( list, l );
    SHRINK_PLIST(  list, l );

    /* return whether the list contains mutable elements                   */
    return mutable;
}


/****************************************************************************
**
*F  FuncOnPoints(<self>,<point>,<elm>)  . . . . . . . . . operation on points
**
**  'FuncOnPoints' implements the internal function 'OnPoints'.
**
**  'OnPoints( <point>, <elm> )'
**
**  specifies  the  canonical  default operation.   Passing  this function is
**  equivalent  to  specifying no operation.   This function  exists  because
**  there are places where the operation in not an option.
*/
Obj             FuncOnPoints (
    Obj                 self,
    Obj                 point,
    Obj                 elm )
{
    return POW( point, elm );
}


/****************************************************************************
**
*F  FuncOnPairs(<self>,<pair>,<elm>) . . . . . . operation on pairs of points
**
**  'FuncOnPairs' implements the internal function 'OnPairs'.
**
**  'OnPairs( <pair>, <elm> )'
**
**  specifies  the componentwise operation    of group elements on  pairs  of
**  points, which are represented by lists of length 2.
*/
Obj             FuncOnPairs (
    Obj                 self,
    Obj                 pair,
    Obj                 elm )
{
    Obj                 img;            /* image, result                   */
    Obj                 tmp;            /* temporary                       */

    /* check the type of the first argument                                */
    while ( ! IS_LIST( pair ) || LEN_LIST( pair ) != 2 ) {
        pair = ErrorReturnObj(
            "OnPairs: <pair> must be a list of length 2 (not a %s)",
            (Int)TNAM_OBJ(pair), 0L,
            "you can return a list of length 2 for <pair>" );
    }

    /* create a new bag for the result                                     */
    img = NEW_PLIST( T_PLIST+IMMUTABLE, 2 );
    SET_LEN_PLIST( img, 2 );

    /* and enter the images of the points into the result bag              */
    tmp = POW( ELMV_LIST( pair, 1 ), elm );
    SET_ELM_PLIST( img, 1, tmp );
    CHANGED_BAG( img );
    tmp = POW( ELMV_LIST( pair, 2 ), elm );
    SET_ELM_PLIST( img, 2, tmp );
    CHANGED_BAG( img );

    /* return the result                                                   */
    return img;
}


/****************************************************************************
**
*F  FuncOnTuples(<self>,<tuple>,<elm>) . . . .  operation on tuples of points
**
**  'FuncOnTuples' implements the internal function 'OnTuples'.
**
**  'OnTuples( <tuple>, <elm> )'
**
**  specifies the componentwise  operation  of  group elements  on tuples  of
**  points, which are represented by lists.  'OnPairs' is the special case of
**  'OnTuples' for tuples with two elements.
*/
Obj             FuncOnTuples (
    Obj                 self,
    Obj                 tuple,
    Obj                 elm )
{
    Obj                 img;            /* image, result                   */
    Obj                 tmp;            /* temporary                       */
    UInt                i;              /* loop variable                   */

    /* check the type of the first argument                                */
    while ( ! IS_LIST( tuple ) ) {
        tuple = ErrorReturnObj(
            "OnTuples: <tuple> must be a list (not a %s)",
            (Int)TNAM_OBJ(tuple), 0L,
            "you can return a list for <tuple>" );
    }

    /* special case for permutations                                       */
    if ( TNUM_OBJ(elm) == T_PERM2 || TNUM_OBJ(elm) == T_PERM4 ) {
        PLAIN_LIST( tuple );
        return OnTuplesPerm( tuple, elm );
    }

    /* create a new bag for the result                                     */
    img = NEW_PLIST( T_PLIST+IMMUTABLE, LEN_LIST(tuple) );
    SET_LEN_PLIST( img, LEN_LIST(tuple) );

    /* and enter the images of the points into the result bag              */
    for ( i = LEN_LIST(tuple); 1 <= i; i-- ) {
        tmp = POW( ELMV_LIST( tuple, i ), elm );
        SET_ELM_PLIST( img, i, tmp );
        CHANGED_BAG( img );
    }

    /* return the result (must be a dense plain list, see 'FuncOnSets')    */
    return img;
}


/****************************************************************************
**
*F  FuncOnSets(<self>,<tuple>,<elm>) . . . . . .  operation on sets of points
**
**  'FuncOnSets' implements the internal function 'OnSets'.
**
**  'OnSets( <tuple>, <elm> )'
**
**  specifies the operation  of group elements  on  sets of points, which are
**  represented by sorted lists of points without duplicates (see "Sets").
*/
Obj             FuncOnSets (
    Obj                 self,
    Obj                 set,
    Obj                 elm )
{
    Obj                 img;            /* handle of the image, result     */
    UInt                mutable;        /* the elements are mutable        */

    /* check the type of the first argument                                */
    while ( TNUM_OBJ( set ) != T_PLIST_HOM_SSORT && ! IsSet( set ) ) {
        set = ErrorReturnObj(
            "OnSets: <set> must be a set (not a %s)",
            (Int)TNAM_OBJ(set), 0L,
            "you can return a set for <set>" );
    }

    /* special case for permutations                                       */
    if ( TNUM_OBJ(elm) == T_PERM2 || TNUM_OBJ(elm) == T_PERM4 ) {
        return OnSetsPerm( set, elm );
    }

    /* compute the list of images                                          */
    img = FuncOnTuples( self, set, elm );

    /* sort the images list (which is a dense plain list)                  */
    SortDensePlist( img );

    /* remove duplicates, check for mutable elements                       */
    mutable = RemoveDupsDensePlist( img );

    /* if possible, turn this into a set                                   */
    if ( ! mutable ) { RetypeBag( img, T_PLIST_HOM_SSORT ); }

    /* return set                                                          */
    return img;
}


/****************************************************************************
**
*F  FuncOnRight(<self>,<point>,<elm>)  . .  operation by mult. from the right
**
**  'FuncOnRight' implements the internal function 'OnRight'.
**
**  'OnRight( <point>, <elm> )'
**
**  specifies that group elements operate by multiplication from the right.
*/
Obj             FuncOnRight (
    Obj                 self,
    Obj                 point,
    Obj                 elm )
{
    return PROD( point, elm );
}


/****************************************************************************
**
*F  FuncOnLeft(<self>,<point>,<elm>) . . . . operation by mult. from the left
**
**  'FuncOnLeft' implements the internal function 'OnLeft'.
**
**  'OnLeft( <point>, <elm> )'
**
**  specifies that group elements operate by multiplication from the left.
*/
Obj             FuncOnLeft (
    Obj                 self,
    Obj                 point,
    Obj                 elm )
{
    return PROD( elm, point );
}


/****************************************************************************
**
*F  FuncOnLeftInverse(<self>,<point>,<elm>)  operation by mult. from the left
**
**  'FuncOnLeft' implements the internal function 'OnLeft'.
**
**  'OnLeft( <point>, <elm> )'
**
**  specifies that group elements operate by multiplication from the left.
*/
Obj             FuncOnLeftInverse (
    Obj                 self,
    Obj                 point,
    Obj                 elm )
{
    point = INV(point);
    return PROD( elm, point );
}


/****************************************************************************
**
*F  DepthListx( <vec> ) . . . . . . . . . . . . . . . . . . depth of a vector
*/
Obj             DepthListx (
    Obj                 vec )
{
    Int                 pos;            /* current position                */
    Obj                 zero;           /* zero element                    */
    Int                 len;            /* length of <vec>                 */
    Obj                 tmp;

    /* if <vec> is trivial return one                                      */
    len = LEN_LIST(vec);
    if ( len == 0 )
        return INTOBJ_INT(1);

    /* construct zero                                                      */
    tmp = ELMV_LIST(vec,1);
    if ( TNUM_OBJ(tmp) == T_INT )
        zero = INTOBJ_INT( 0L );
    else
        zero = PROD( INTOBJ_INT( 0L ), tmp );

    /* loop over vector and compare                                        */
    for ( pos = 1;  pos <= len;  pos++ ) {
        tmp = ELMV_LIST(vec,pos);
        while ( FIRST_LIST_TNUM <= TNUM_OBJ(tmp)
             && TNUM_OBJ(tmp) <= LAST_LIST_TNUM ) {
            tmp = ErrorReturnObj(
                "DepthVector: <list> must be a vector (not a %s)",
                (Int)TNAM_OBJ(tmp), 0L,
                "you can return a vector for <list>" );
        }
        if ( ! EQ( zero, tmp ) )
            break;
    }

    /* and return the position                                             */
    return INTOBJ_INT(pos);
}


/****************************************************************************
**
*F  DepthVector(<vec>)  . . . . . . . . . . . . . . . . . . depth of a vector
*/
Obj       (*DepthVectorFuncs[LAST_REAL_TNUM+1]) ( Obj vec );

Obj       CantDepthVector (
    Obj                 vec )
{
    vec = ErrorReturnObj(
        "DepthVector: <vec> must be a vector (not a %s)",
        (Int)TNAM_OBJ(vec), 0L,
        "you can return a vector for <vec>" );
    return DepthVectorFuncs[XTNum(vec)]( vec );
}

Obj       DepthVectorHandler (
    Obj                 self,
    Obj                 vec )
{
    /* jump through the table 'DepthVectorFuncs'                           */
    return DepthVectorFuncs[XTNum(vec)]( vec );
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupListFunc() . . . . . . . . .  initialize the lists functions package
*/
void SetupListFunc ( void )
{
    UInt                type;           /* loop variable                   */

    /* install tables for gap functions                                    */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        DepthVectorFuncs[ type ] = CantDepthVector;
    }
    DepthVectorFuncs[ T_PLIST_CYC       ] = DepthListx;
    DepthVectorFuncs[ T_PLIST_CYC_NSORT ] = DepthListx;
    DepthVectorFuncs[ T_PLIST_CYC_SSORT ] = DepthListx;
}



/****************************************************************************
**
*F  InitListFunc()  . . . . . . . . .  initialize the lists functions package
**
**  'InitListFunc' initializes the lists functions package.
*/
void InitListFunc ( void )
{
    /* install the internal functions                                      */
    C_NEW_GVAR_OPER( "ADD_LIST", 2, "list, val", AddListOper, AddListHandler,
      "src/listfunc.c:ADD_LIST" );

    C_NEW_GVAR_OPER( "APPEND_LIST", 2, "list, val", AppendListOper, AppendListHandler,
      "src/listfunc.c:APPEND_LIST" );

    C_NEW_GVAR_FUNC( "APPEND_LIST_INTR", 2, "list1, list2", 
                    AppendListIntrHandler,
      "src/listfunc.c:APPEND_LIST_INTR" );


    /* make and install the 'POSITION_SORTED_LIST' function                */
    C_NEW_GVAR_FUNC( "POSITION_SORTED_LIST", 2, "list, obj", 
                      PositionSortedListHandler,
      "src/listfunc.c:POSITION_SORTED_LIST" );


    /* make and install the 'POSITION_SORTED_LIST_COMP' function           */
    C_NEW_GVAR_FUNC( "POSITION_SORTED_LIST_COMP", 3, "list, obj, func", 
                      PositionSortedListCompHandler,
      "src/listfunc.c:POSITION_SORTED_LIST_COMP" );


    /* make and install the 'SORT_LIST' function                           */
    C_NEW_GVAR_FUNC( "SORT_LIST", 1, "list",
                      SortListHandler,
      "src/listfunc.c:SORT_LIST" );


    /* make and install the 'SORT_LIST_COMP' function                      */
    C_NEW_GVAR_FUNC( "SORT_LIST_COMP", 2, "list, func",
                      SortListCompHandler,
      "src/listfunc.c:SORT_LIST_COMP" );


    /* make and install the `OnSomething' functions                        */
    C_NEW_GVAR_FUNC( "OnPoints", 2, "pnt, elm",
                  FuncOnPoints,
      "src/listfunc.c:OnPoints" );

    C_NEW_GVAR_FUNC( "OnPairs", 2, "pair, elm",
                  FuncOnPairs,
      "src/listfunc.c:OnPairs" );

    C_NEW_GVAR_FUNC( "OnTuples", 2, "tuple, elm",
                  FuncOnTuples,
      "src/listfunc.c:OnTuples" );

    C_NEW_GVAR_FUNC( "OnSets", 2, "set, elm",
                  FuncOnSets,
      "src/listfunc.c:OnSets" );

    C_NEW_GVAR_FUNC( "OnRight", 2, "pnt, elm",
                  FuncOnRight,
      "src/listfunc.c:OnRight" );

    C_NEW_GVAR_FUNC( "OnLeftAntiOperation", 2, "pnt, elm",
                  FuncOnLeft,
      "src/listfunc.c:OnLeftAntiOperation" );

    C_NEW_GVAR_FUNC( "OnLeftInverse", 2, "pnt, elm",
                  FuncOnLeftInverse,
      "src/listfunc.c:OnLeftInverse" );

    C_NEW_GVAR_FUNC( "Depthvector", 1, "list",
                  DepthVectorHandler,
      "src/listfunc.c:Depthvector" );
}



/****************************************************************************
**
*F  CheckListFunc() . check the initialisation of the lists functions package
*/
void CheckListFunc ( void )
{
    SET_REVISION( "listfunc_c", Revision_listfunc_c );
    SET_REVISION( "listfunc_h", Revision_listfunc_h );
}


/****************************************************************************
**

*E  listfunc.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
