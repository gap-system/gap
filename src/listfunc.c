/****************************************************************************
**
*W  listfunc.c                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file contains the functions for generic lists.
*/
#include        "system.h"              /* Ints, UInts                     */

const char * Revision_listfunc_c =
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

extern Obj FuncADD_LIST(
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
        FuncADD_LIST( 0, list, obj );
        return;
    }
    /* in order to be optimistic when building list call assignment        */
    pos = LEN_PLIST( list ) + 1;
    if ( pos == 1 ) {
        AssPlistEmpty( list, pos, obj );
    }
    else {
        RetypeBag( list, T_PLIST );
        GROW_PLIST( list, pos );
        SET_LEN_PLIST( list, pos );
        SET_ELM_PLIST( list, pos, obj );
        CHANGED_BAG( list );
    }
}

Obj AddListOper;

Obj FuncADD_LIST (
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
*F  FuncAPPEND_LIST(<list1>,<list2>)  . . . . . . append elements to a list
**
**  'FuncAPPEND_LIST' implements the function 'AppendList'.
**
**  'AppendList(<list1>,<list2>)'
**
**  'AppendList' adds (see "Add") the elements of the list <list2> to the end
**  of the list <list1>. It is allowed that <list2> contains empty positions,
**  in which case the corresponding positions  will be left empty in <list1>.
**  'AppendList' returns nothing, it is called only for its side effect.
*/
Obj             FuncAPPEND_LIST_INTR (
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

Obj             FuncAPPEND_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 obj )
{
    /* dispatch                                                            */
    if ( TNUM_OBJ( list ) < FIRST_EXTERNAL_TNUM ) {
        FuncAPPEND_LIST_INTR( 0, list, obj );
    }
    else {
        DoOperation2Args( self, list, obj );
    }

    /* return nothing                                                      */
    return (Obj)0;
}

/****************************************************************************
**
*F  POSITION_SORTED_LIST(<list>,<obj>)  . . . . find an object in a sorted list
*F  PositionSortedDensePlist(<list>,<obj>)  . find an object in a sorted list
**
**  'POSITION_SORTED_LIST' returns the position of the  object <obj>, which may
**  be an object of any type, with respect to the sorted list <list>.
**
**  'POSITION_SORTED_LIST' returns  <pos>  such that  '<list>[<pos>-1] < <obj>'
**  and '<obj> <= <list>[<pos>]'.  That means if <obj> appears once in <list>
**  its position is returned.  If <obj> appears several  times in <list>, the
**  position of the first occurrence is returned.  If <obj> is not an element
**  of <list>, the index where <obj> must be inserted to keep the list sorted
**  is returned.
*/
UInt            POSITION_SORTED_LIST (
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

Obj             FuncPOSITION_SORTED_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 obj )
{
    UInt                h;              /* position, result                */

    /* check the first argument                                            */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "POSITION_SORTED_LIST: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can return a list for <list>" );
    }

    /* dispatch                                                            */
    if ( T_PLIST_DENSE  <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_PLIST_CYC_SSORT ) {
        h = PositionSortedDensePlist( list, obj );
    }
    else {
        h = POSITION_SORTED_LIST( list, obj );
    }

    /* return the result                                                   */
    return INTOBJ_INT( h );
}


/****************************************************************************
**
*F  POSITION_SORTED_LISTComp(<list>,<obj>,<func>)  . . find an object in a list
*F  PositionSortedDensePlistComp(<list>,<obj>,<func>)find an object in a list
**
**  'POSITION_SORTED_LISTComp' returns the position of the  object <obj>, which
**  may be an object of any type, with respect to the list <list>,  which  is
**  sorted with respect to the comparison function <func>.
**
**  'POSITION_SORTED_LISTComp' returns <pos> such that '<list>[<pos>-1] < <obj>'
**  and '<obj> <= <list>[<pos>]'.  That means if <obj> appears once in <list>
**  its position is returned.  If <obj> appears several  times in <list>, the
**  position of the first occurrence is returned.  If <obj> is not an element
**  of <list>, the index where <obj> must be inserted to keep the list sorted
**  is returned.
*/
UInt            POSITION_SORTED_LISTComp (
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

Obj             FuncPOSITION_SORTED_COMP (
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 func )
{
    UInt                h;              /* position, result                */

    /* check the first argument                                            */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "POSITION_SORTED_LISTComp: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can return a list for <list>" );
    }

    /* check the third argument                                            */
    while ( TNUM_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "POSITION_SORTED_LISTComp: <func> must be a function (not a %s)",
            (Int)TNAM_OBJ(func), 0L,
            "you can return a function for <func>" );
    }

    /* dispatch                                                            */
    if ( T_PLIST_DENSE  <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_PLIST_CYC_SSORT ) {
        h = PositionSortedDensePlistComp( list, obj, func );
    }
    else {
        h = POSITION_SORTED_LISTComp( list, obj, func );
    }

    /* return the result                                                   */
    return INTOBJ_INT( h );
}


/****************************************************************************
**
*F  SORT_LIST( <list> )  . . . . . . . . . . . . . . . . . . . .  sort a list
*F  SortDensePlist( <list> ) . . . . . . . . . . . . . . . . . .  sort a list
**
**  'SORT_LIST' sorts the list <list> in increasing  order.
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
void SORT_LIST (
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
                if ( h < k )  w = ELMV_LIST( list, k-h );
            }
            ASS_LIST( list, k, v );
        }
        h = h / 3;
    }
}

void SortDensePlist (
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
                if ( h < k )  w = ELM_PLIST( list, k-h );
            }
            SET_ELM_PLIST( list, k, v );
        }
        h = h / 3;
    }
}


/****************************************************************************
**
*F  SORT_LISTComp(<list>,<func>)  . . . . . . . . . . . . . . . . sort a list
*F  SortDensePlistComp(<list>,<func>) . . . . . . . . . . . . . . sort a list
**
**  'SORT_LISTComp' sorts the list <list> in increasing order, with respect to
**  comparison function <func>.
*/
void SORT_LISTComp (
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
                if ( h < k )  w = ELMV_LIST( list, k-h );
            }
            ASS_LIST( list, k, v );
        }
        h = h / 3;
    }
}

void SortDensePlistComp (
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
                if ( h < k )  w = ELM_PLIST( list, k-h );
            }
            SET_ELM_PLIST( list, k, v );
        }
        h = h / 3;
    }
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

*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncSORT_LIST( <self>, <list> ) . . . . . . . . . . . . . . . sort a list
*/
Obj FuncSORT_LIST (
    Obj                 self,
    Obj                 list )
{
    /* check the first argument                                            */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "SORT_LIST: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can return a list for <list>" );
    }

    /* dispatch                                                            */
    if ( T_PLIST_DENSE  <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_PLIST_CYC_SSORT ) {
        SortDensePlist( list );
    }
    else {
        SORT_LIST( list );
    }
    IS_SSORT_LIST(list);

    /* return nothing                                                      */
    return (Obj)0;
}


/****************************************************************************
**


*F  FuncSORT_LIST_COMP( <self>, <list>, <func> )  . . . . . . . . sort a list
*/
Obj FuncSORT_LIST_COMP (
    Obj                 self,
    Obj                 list,
    Obj                 func )
{
    /* check the first argument                                            */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "SORT_LISTComp: <list> must be a list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can return a list for <list>" );
    }

    /* check the third argument                                            */
    while ( TNUM_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "SORT_LISTComp: <func> must be a function (not a %s)",
            (Int)TNAM_OBJ(func), 0L,
            "you can return a function for <func>" );
    }

    /* dispatch                                                            */
    if ( T_PLIST_DENSE  <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_PLIST_CYC_SSORT ) {
        SortDensePlistComp( list, func );
    }
    else {
        SORT_LISTComp( list, func );
    }

    /* return nothing                                                      */
    return (Obj)0;
}


/****************************************************************************
**
*F  FuncOnPoints( <self>, <point>, <elm> )  . . . . . . . operation on points
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
*F  FuncOnPairs( <self>, <pair>, <elm> )  . . .  operation on pairs of points
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
*F  FuncOnTuples( <self>, <tuple>, <elm> )  . . operation on tuples of points
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
*F  FuncOnSets( <self>, <tuple>, <elm> )  . . . . operation on sets of points
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
*F  FuncOnRight( <self>, <point>, <elm> ) . operation by mult. from the right
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
*F  FuncOnLeftAntiOperation( <self>, <point>, <elm> ) op. by mult. from the left
**
**  'FuncOnLeftAntiOperation' implements the internal function
**  'OnLeftAntiOperation'.
**
**  'OnLeftAntiOperation( <point>, <elm> )'
**
**  specifies that group elements operate by multiplication from the left.
*/
Obj             FuncOnLeftAntiOperation (
    Obj                 self,
    Obj                 point,
    Obj                 elm )
{
    return PROD( elm, point );
}


/****************************************************************************
**
*F  FuncOnLeftInverse( <self>, <point>, <elm> )	. . op by mult. from the left
**
**  'FuncOnLeftInverse' implements the internal function 'OnLeftInverse'.
**
**  'OnLeftInverse( <point>, <elm> )'
**
**  specifies that group elements operate by multiplication from the left
**  with the inverse.
*/
Obj             FuncOnLeftInverse (
    Obj                 self,
    Obj                 point,
    Obj                 elm )
{
    elm = INV(elm);
    return PROD( elm, point );
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    { "ADD_LIST", 2, "list, val", &AddListOper,
      FuncADD_LIST, "src/listfunc.c:ADD_LIST" },

    { "APPEND_LIST", 2, "list, val", &AppendListOper,
      FuncAPPEND_LIST, "src/listfunc.c:APPEND_LIST" },

    { 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "APPEND_LIST_INTR", 2, "list1, list2", 
      FuncAPPEND_LIST_INTR, "src/listfunc.c:APPEND_LIST_INTR" },

    { "POSITION_SORTED_LIST", 2, "list, obj", 
      FuncPOSITION_SORTED_LIST, "src/listfunc.c:POSITION_SORTED_LIST" },

    { "POSITION_SORTED_LIST_COMP", 3, "list, obj, func", 
      FuncPOSITION_SORTED_COMP, "src/listfunc.c:POSITION_SORTED_LIST_COMP" },

    { "SORT_LIST", 1, "list",
      FuncSORT_LIST, "src/listfunc.c:SORT_LIST" },

    { "SORT_LIST_COMP", 2, "list, func",
      FuncSORT_LIST_COMP, "src/listfunc.c:SORT_LIST_COMP" },

    { "OnPoints", 2, "pnt, elm",
      FuncOnPoints, "src/listfunc.c:OnPoints" },

    { "OnPairs", 2, "pair, elm",
      FuncOnPairs, "src/listfunc.c:OnPairs" },

    { "OnTuples", 2, "tuple, elm",
      FuncOnTuples, "src/listfunc.c:OnTuples" },

    { "OnSets", 2, "set, elm",
      FuncOnSets, "src/listfunc.c:OnSets" },

    { "OnRight", 2, "pnt, elm",
      FuncOnRight, "src/listfunc.c:OnRight" },

    { "OnLeftAntiOperation", 2, "pnt, elm",
      FuncOnLeftAntiOperation, "src/listfunc.c:OnLeftAntiOperation" },

    { "OnLeftInverse", 2, "pnt, elm",
      FuncOnLeftInverse, "src/listfunc.c:OnLeftInverse" },

    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );

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
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoListFunc()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "listfunc",                         /* name                           */
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

StructInitInfo * InitInfoListFunc ( void )
{
    module.revision_c = Revision_listfunc_c;
    module.revision_h = Revision_listfunc_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  listfunc.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
