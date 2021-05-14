/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions for generic lists.
*/

#include "listfunc.h"

#include "ariths.h"
#include "blister.h"
#include "bool.h"
#include "calls.h"
#include "error.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "permutat.h"
#include "plist.h"
#include "pperm.h"
#include "set.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "trans.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#endif

/****************************************************************************
**
*F  AddList(<list>,<obj>) . . . . . . . .  add an object to the end of a list
**
**  'AddList' adds the object <obj> to the end  of  the  list  <list>,  i.e.,
**  it is equivalent to the assignment '<list>[ Length(<list>)+1 ] := <obj>'.
**  The  list is  automatically extended to   make room for  the new element.
**  'AddList' returns nothing, it is called only for its side effect.
*/
static void AddList3(Obj list, Obj obj, Int pos)
{
    Int                 len;
    Int                 i;
    len = LEN_LIST(list);
    if (pos == (Int) -1)
      pos = len + 1;
    for (i = len +1; i > pos; i--)
      ASS_LIST(list, i, ELM_LIST(list, i-1));
    ASS_LIST( list, pos, obj );
}

void            AddList (
    Obj                 list,
    Obj                 obj)
{
  AddList3(list, obj, -1);
}


static void AddPlist3(Obj list, Obj obj, Int pos)
{
  UInt len;

    if ( ! IS_PLIST_MUTABLE(list) ) {
        ErrorMayQuit("List Assignment: <list> must be a mutable list", 0, 0);
    }
    /* in order to be optimistic when building list call assignment        */
    len = LEN_PLIST( list );
    if (pos == (Int)-1)
      pos = len + 1;
    if ( len == 0) {
        AssPlistEmpty( list, pos, obj );
        return;
    }
    if (pos <= len) {
      GROW_PLIST(list, len+1);
      SET_LEN_PLIST(list, len+1);
      Obj * ptr = ADDR_OBJ(list) + pos;
      SyMemmove(ptr + 1, ptr, sizeof(Obj) * (len - pos + 1));
    }
    ASS_LIST(list, pos, obj);
}

void            AddPlist (
    Obj                 list,
    Obj                 obj)
{

  AddPlist3(list, obj, -1);
}

static Obj AddListOper;

static Obj FuncADD_LIST3(Obj self, Obj list, Obj obj, Obj pos)
{
    /* dispatch                */
  Int ipos;
  if (pos == (Obj)0)
    ipos = -1;
  else if (IS_POS_INTOBJ(pos))
    ipos = INT_INTOBJ(pos);
  else {
    DoOperation3Args( self, list,  obj, pos);
    return (Obj) 0;
  }
  UInt tnum = TNUM_OBJ(list);
  if ( IS_PLIST( list ) ) {
    AddPlist3( list, obj, ipos );
  } else if ( FIRST_LIST_TNUM <= tnum && tnum <= LAST_LIST_TNUM ) {
    AddList3( list, obj, ipos );
#ifdef HPCGAP
  // Only support adding to end of atomic lists
  } else if ( tnum == T_ALIST && pos == (Obj)0 ) {
    AddAList( list, obj );
#endif
  } else {
    if (pos == 0)
      DoOperation2Args( self, list, obj );
    else
      DoOperation3Args( self, list, obj, pos);
  }

    return 0;
}


static Obj FuncADD_LIST(Obj self, Obj list, Obj obj)
{
  FuncADD_LIST3(self, list, obj, (Obj)0);
  return (Obj) 0;
}


/****************************************************************************
**
*F  RemList(<list>) . . . . . . . .  remove an object from the end of a list
**
**  'RemList' removes the last object <obj> from the end of the list <list>,
**  and returns it.
*/
static Obj RemList(Obj list)
{
    Int                 pos; 
    Obj result;
    pos = LEN_LIST( list ) ;
    if ( pos == 0 ) {
        ErrorMayQuit("Remove: <list> must not be empty", 0, 0);
    }
    result = ELM_LIST(list, pos);
    UNB_LIST(list, pos);
    return result;
}

static Obj RemPlist(Obj list)
{
    Int                 pos;           
    Obj removed; 

    if ( ! IS_PLIST_MUTABLE(list) ) {
        ErrorMayQuit("Remove: <list> must be a mutable list", 0, 0);
    }
    pos = LEN_PLIST( list );
    if ( pos == 0 ) {
        ErrorMayQuit("Remove: <list> must not be empty", 0, 0);
    }
    removed = ELM_PLIST(list, pos);
    SET_ELM_PLIST(list, pos, 0);
    pos--;
    while ( 1 <= pos && ELM_PLIST( list, pos ) == 0 ) { pos--; }
    SET_LEN_PLIST(list, pos);
    if ( pos == 0 ) {
      RetypeBag(list, T_PLIST_EMPTY);
    }
    if (4*pos*sizeof(Obj) < 3*SIZE_BAG(list))
      SHRINK_PLIST(list, pos);
    return removed;
}

static Obj RemListOper;

static Obj FuncREM_LIST(Obj self, Obj list)

{
    /* dispatch                                                            */
    if ( IS_PLIST( list ) ) {
        return RemPlist( list);
    }
    else if ( TNUM_OBJ( list ) < FIRST_EXTERNAL_TNUM ) {
        return RemList( list);
    }
    else {
        return DoOperation1Args( self, list);
    }

}


/****************************************************************************
**
*F  FuncAPPEND_LIST_INTR(<list1>,<list2>)  . . . . . append elements to a list
**
**  'FuncAPPEND_LIST_INTR' implements the function 'Append'.
**
**  'Append(<list1>,<list2>)'
**
**  'Append' adds (see "Add") the elements of the list <list2> to the end
**  of the list <list1>. It is allowed that <list2> contains empty positions,
**  in which case the corresponding positions  will be left empty in <list1>.
**  'Append' returns nothing, it is called only for its side effect.
*/
static Obj FuncAPPEND_LIST_INTR(Obj self, Obj list1, Obj list2)
{
    UInt                len1;           /* length of the first list        */
    UInt                len2;           /* length of the second list       */
    Obj                 elm;            /* one element of the second list  */
    Int                 i;              /* loop variable                   */

    RequireMutable(SELF_NAME, list1, "list");
    RequireSmallList(SELF_NAME, list1);
    RequireSmallList(SELF_NAME, list2);

    /* handle the case of strings now */
    if (IS_STRING_REP(list1) && IS_STRING_REP(list2)) {
        AppendString(list1, list2);
        return 0;
    }

    /* check the type of the first argument                                */
    if ( TNUM_OBJ( list1 ) != T_PLIST ) {
        if ( ! IS_PLIST( list1 ) ) {
            PLAIN_LIST( list1 );
        }
        RetypeBag( list1, T_PLIST );
    }
    len1 = LEN_PLIST( list1 );

    /* check the type of the second argument                               */
    if ( ! IS_PLIST( list2 ) ) {
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
    if ( IS_PLIST(list2) ) {
        // note that the two memory regions can never overlap, even
        // if list1 and list2 are identical
        memcpy(ADDR_OBJ(list1) + 1 + len1, CONST_ADDR_OBJ(list2) + 1,
               len2 * sizeof(Obj));
        CHANGED_BAG( list1 );
    }
    else {
        for ( i = 1; i <= len2; i++ ) {
            elm = ELMV0_LIST( list2, i );
            SET_ELM_PLIST( list1, i+len1, elm );
            CHANGED_BAG( list1 );
        }
    }

    return 0;
}

static Obj AppendListOper;

static Obj FuncAPPEND_LIST(Obj self, Obj list, Obj obj)
{
    /* dispatch                                                            */
    if ( TNUM_OBJ( list ) < FIRST_EXTERNAL_TNUM ) {
        FuncAPPEND_LIST_INTR( 0, list, obj );
    }
    else {
        DoOperation2Args( self, list, obj );
    }

    return 0;
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
static UInt POSITION_SORTED_LIST(Obj list, Obj obj)
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

static Obj FuncPOSITION_SORTED_LIST(Obj self, Obj list, Obj obj)
{
    RequireSmallList(SELF_NAME, list);

    UInt h;
    if ( IS_DENSE_PLIST(list) ) {
        h = PositionSortedDensePlist( list, obj );
    }
    else {
        h = POSITION_SORTED_LIST( list, obj );
    }

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
static UInt POSITION_SORTED_LISTComp(Obj list, Obj obj, Obj func)
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

static UInt PositionSortedDensePlistComp(Obj list, Obj obj, Obj func)
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

static Obj
FuncPOSITION_SORTED_LIST_COMP(Obj self, Obj list, Obj obj, Obj func)
{
    RequireSmallList(SELF_NAME, list);
    RequireFunction(SELF_NAME, func);

    UInt h;
    if ( IS_DENSE_PLIST(list) ) {
        h = PositionSortedDensePlistComp( list, obj, func );
    }
    else {
        h = POSITION_SORTED_LISTComp( list, obj, func );
    }

    return INTOBJ_INT( h );
}


/****************************************************************************
**
**  Low-level implementations of PositionSortedBy for dense Plists and lists.
*/
static Obj FuncPOSITION_SORTED_BY(Obj self, Obj list, Obj val, Obj func)
{
    RequirePlainList(SELF_NAME, list);
    RequireFunction(SELF_NAME, func);

    // perform the binary search to find the position
    UInt l = 0;
    UInt h = LEN_PLIST(list) + 1;
    while (l + 1 < h) {       // list[l] < val && val <= list[h]
        UInt m = (l + h) / 2; // l < m < h
        Obj  v = CALL_1ARGS(func, ELM_PLIST(list, m));
        if (LT(v, val)) {
            l = m;
        }
        else {
            h = m;
        }
    }

    return INTOBJ_INT(h);
}


/****************************************************************************
**
*F  SORT_LIST( <list> )  . . . . . . . . . . . . . . . . . . . .  sort a list
*F  SortDensePlist( <list> ) . . . . . . . . . . . . . . . . . .  sort a list
**
**  'SORT_LIST' sorts the list <list> in increasing  order.
*/

// See sortbase.h for a description of these macros.

// We put these first, as they are the same for the next 4 functions so
// we do not have to repeat them
#define SORT_CREATE_TEMP_BUFFER(len)  NEW_PLIST( T_PLIST, len + 1000);
#define SORT_ASS_BUF_TO_LOCAL(buffer, t, i) t = ELM_PLIST(buffer, i);
#define SORT_ASS_LOCAL_TO_BUF(buffer, i, j) \
  SET_ELM_PLIST(buffer, i, j); \
  CHANGED_BAG(buffer);


#define SORT_FUNC_NAME SORT_LIST
#define SORT_FUNC_ARGS  Obj list
#define SORT_ARGS list
#define SORT_CREATE_LOCAL(name) Obj name ;
#define SORT_LEN_LIST() LEN_LIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) t = ELMV_LIST(list, i)
#define SORT_ASS_LOCAL_TO_LIST(i, j) ASS_LIST(list, i, j)
#define SORT_COMP(v, w) LT(v, w)
#define SORT_FILTER_CHECKS() \
  if(IS_PLIST(list)) \
    RESET_FILT_LIST(list, FN_IS_NSORT);

#include "sortbase.h"

#define SORT_FUNC_NAME SortDensePlist
#define SORT_FUNC_ARGS Obj list
#define SORT_ARGS list
#define SORT_CREATE_LOCAL(name) Obj name ;
#define SORT_LEN_LIST() LEN_PLIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) t = ELM_PLIST(list, i)
#define SORT_ASS_LOCAL_TO_LIST(i, j)  \
  SET_ELM_PLIST(list, i, j); \
  CHANGED_BAG(list);
#define SORT_COMP(v, w) LT(v, w)
#define SORT_FILTER_CHECKS() \
  RESET_FILT_LIST(list, FN_IS_NSORT);

#include "sortbase.h"

// This is a variant of SortDensePlist, which sorts plists by
// Obj pointer. It works on non-dense plists, and can be
// used to efficiently sort lists of small integers.

#define SORT_FUNC_NAME SortPlistByRawObj
#define SORT_FUNC_ARGS Obj list
#define SORT_ARGS list
#define SORT_CREATE_LOCAL(name) Obj name;
#define SORT_LEN_LIST() LEN_PLIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) t = ELM_PLIST(list, i)
#define SORT_ASS_LOCAL_TO_LIST(i, j) SET_ELM_PLIST(list, i, j);
#define SORT_COMP(v, w) ((v) < (w))
#define SORT_FILTER_CHECKS() \
    RESET_FILT_LIST(list, FN_IS_NSORT); \
    RESET_FILT_LIST(list, FN_IS_SSORT);

#include "sortbase.h"

/****************************************************************************
**
*F  SORT_LISTComp(<list>,<func>)  . . . . . . . . . . . . . . . . sort a list
*F  SortDensePlistComp(<list>,<func>) . . . . . . . . . . . . . . sort a list
**
**  'SORT_LISTComp' sorts the list <list> in increasing order, with respect to
**  comparison function <func>.
*/
#define SORT_FUNC_NAME SORT_LISTComp
#define SORT_FUNC_ARGS Obj list, Obj func
#define SORT_ARGS list, func
#define SORT_CREATE_LOCAL(name) Obj name ;
#define SORT_LEN_LIST() LEN_LIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) t = ELMV_LIST(list, i)
#define SORT_ASS_LOCAL_TO_LIST(i, j) ASS_LIST(list, i, j)
#define SORT_COMP(v, w) CALL_2ARGS(func, v, w) == True
/* list is not necc. sorted wrt. \< (any longer) */
#define SORT_FILTER_CHECKS() \
  RESET_FILT_LIST(list, FN_IS_SSORT); \
  RESET_FILT_LIST(list, FN_IS_NSORT);

#include "sortbase.h"

#define SORT_FUNC_NAME SortDensePlistComp
#define SORT_FUNC_ARGS Obj list, Obj func
#define SORT_ARGS list, func
#define SORT_CREATE_LOCAL(name) Obj name ;
#define SORT_LEN_LIST() LEN_PLIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) t = ELM_PLIST(list, i)
#define SORT_ASS_LOCAL_TO_LIST(i, j) \
  SET_ELM_PLIST(list, i, j); \
  CHANGED_BAG(list);
#define SORT_COMP(v, w) CALL_2ARGS(func, v, w) == True
/* list is not necc. sorted wrt. \< (any longer) */
#define SORT_FILTER_CHECKS() \
  RESET_FILT_LIST(list, FN_IS_SSORT); \
  RESET_FILT_LIST(list, FN_IS_NSORT);

#include "sortbase.h"

/****************************************************************************
**
*F  SORT_PARA_LIST( <list> )  . . . . . . . . . . .  sort a lists with shadow
*F  SortParaDensePlistPara( <list> )  . . . . . . .  sort a lists with shadow
*F  SORT_PARA_LISTComp(<list>,<func>) . . . . . . .  sort a lists with shadow
*F  SortParaDensePlistComp(<list>,<func>) . . . . .  sort a lists with shadow
**
**  The following suite of functions mirrors the sort functions above.  They
**  sort the first list given and perform the same operations on the second
**  list, the shadow list.  All functions assume that shadow list has (at
**  least) the length of the first list. 
**
**  The code here is a duplication of the code above with the operations on
**  the second list added in.
*/

// Through this section, code of the form (void)(varname); stops
// various compilers warning about unused variables.
// These 3 macros are the same for all 4 of the following functions.
#undef SORT_CREATE_TEMP_BUFFER
#undef SORT_ASS_BUF_TO_LOCAL
#undef SORT_ASS_LOCAL_TO_BUF

#define SORT_CREATE_TEMP_BUFFER(len) NEW_PLIST( T_PLIST, len * 2 + 1000);
#define SORT_ASS_BUF_TO_LOCAL(buffer, t, i) \
  t = ELM_PLIST(buffer, 2*(i)); \
  t##s = ELM_PLIST(buffer,  2*(i)-1); (void)(t##s)
#define SORT_ASS_LOCAL_TO_BUF(buffer, i, j) \
  SET_ELM_PLIST(buffer, 2*(i), j); \
  SET_ELM_PLIST(buffer, 2*(i)-1, j##s); \
  CHANGED_BAG(buffer);



#define SORT_FUNC_NAME SORT_PARA_LIST
#define SORT_FUNC_ARGS Obj list, Obj shadow
#define SORT_ARGS list, shadow
#define SORT_CREATE_LOCAL(name) Obj name ; Obj name##s ; (void)(name##s) ;
#define SORT_LEN_LIST() LEN_LIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) \
  t = ELMV_LIST(list, i); \
  t##s = ELMV_LIST(shadow, i);
#define SORT_ASS_LOCAL_TO_LIST(i, t) \
  ASS_LIST(list, i, t); \
  ASS_LIST(shadow, i, t##s);
#define SORT_COMP(v, w) LT( v, w )
    /* if list was ssorted, then it still will be,
       but, we don't know anything else any more */
#define SORT_FILTER_CHECKS() \
  RESET_FILT_LIST(list, FN_IS_NSORT); \
  RESET_FILT_LIST(shadow, FN_IS_SSORT); \
  RESET_FILT_LIST(shadow, FN_IS_NSORT);

#include "sortbase.h"

#define SORT_FUNC_NAME SortParaDensePlist
#define SORT_FUNC_ARGS Obj list, Obj shadow
#define SORT_ARGS list, shadow
#define SORT_CREATE_LOCAL(name) Obj name ; Obj name##s ; (void)(name##s) ;
#define SORT_LEN_LIST() LEN_PLIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) \
  t = ELM_PLIST(list, i); \
  t##s = ELM_PLIST(shadow, i);
#define SORT_ASS_LOCAL_TO_LIST(i, t) \
  SET_ELM_PLIST(list, i, t); \
  SET_ELM_PLIST(shadow, i, t##s); \
  CHANGED_BAG(list); \
  CHANGED_BAG(shadow);
#define SORT_COMP(v, w) LT( v, w )
    /* if list was ssorted, then it still will be,
       but, we don't know anything else any more */
#define SORT_FILTER_CHECKS() \
  RESET_FILT_LIST(list, FN_IS_NSORT); \
  RESET_FILT_LIST(shadow, FN_IS_SSORT); \
  RESET_FILT_LIST(shadow, FN_IS_NSORT);

#include "sortbase.h"

#define SORT_FUNC_NAME SORT_PARA_LISTComp
#define SORT_FUNC_ARGS Obj list, Obj shadow, Obj func
#define SORT_ARGS list, shadow, func
#define SORT_CREATE_LOCAL(name) Obj name ; Obj name##s ; (void)(name##s) ;
#define SORT_LEN_LIST() LEN_LIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) \
  t = ELMV_LIST(list, i); \
  t##s = ELMV_LIST(shadow, i);
#define SORT_ASS_LOCAL_TO_LIST(i, t) \
  ASS_LIST(list, i, t); \
  ASS_LIST(shadow, i, t##s);
#define SORT_COMP(v, w) CALL_2ARGS( func, v, w ) == True
/* list is not necc. sorted wrt. \< (any longer) */
#define SORT_FILTER_CHECKS() \
    RESET_FILT_LIST(list, FN_IS_SSORT); \
    RESET_FILT_LIST(list, FN_IS_NSORT); \
    RESET_FILT_LIST(shadow, FN_IS_NSORT); \
    RESET_FILT_LIST(shadow, FN_IS_SSORT);

#include "sortbase.h"
  
#define SORT_FUNC_NAME SortParaDensePlistComp
#define SORT_FUNC_ARGS Obj list, Obj shadow, Obj func
#define SORT_ARGS list, shadow, func
#define SORT_CREATE_LOCAL(name) Obj name ; Obj name##s ; (void)(name##s) ;
#define SORT_LEN_LIST() LEN_PLIST(list)
#define SORT_ASS_LIST_TO_LOCAL(t, i) \
  t = ELM_PLIST(list, i); \
  t##s = ELM_PLIST(shadow, i);
#define SORT_ASS_LOCAL_TO_LIST(i, t) \
  SET_ELM_PLIST(list, i, t); \
  SET_ELM_PLIST(shadow, i, t##s); \
  CHANGED_BAG(list); \
  CHANGED_BAG(shadow);
#define SORT_COMP(v, w) CALL_2ARGS( func, v, w ) == True
/* list is not necc. sorted wrt. \< (any longer) */
#define SORT_FILTER_CHECKS() \
    RESET_FILT_LIST(list, FN_IS_SSORT); \
    RESET_FILT_LIST(list, FN_IS_NSORT); \
    RESET_FILT_LIST(shadow, FN_IS_NSORT); \
    RESET_FILT_LIST(shadow, FN_IS_SSORT);

#include "sortbase.h"



/****************************************************************************
**
*F  RemoveDupsDensePlist(<list>)  . . . . remove duplicates from a plain list
**
**  'RemoveDupsDensePlist' removes duplicate elements from the dense
**  plain list <list>.  <list> must be sorted.  'RemoveDupsDensePlist'
**  returns 0 if <list> contains mutable elements, 1 if not and 2 if
**  the list contains immutable elements all lying in the same family.
*/
UInt            RemoveDupsDensePlist (
    Obj                 list )
{
    UInt                mutable;        /* the elements are mutable        */
    UInt                homog;          /* the elements all lie in the same family */
    Int                 len;            /* length of the list              */
    Obj                 v, w;           /* two elements of the list        */
    UInt                l, i;           /* loop variables                  */
    Obj                 fam;

    /* get the length, nothing to be done for empty lists                  */
    len = LEN_PLIST( list );
    if ( len == 0 ) { return 0; }

    /* select the first element as the first representative                */
    l = 1;
    v = ELM_PLIST( list, l );
    mutable = IS_MUTABLE_OBJ(v);
    homog = 1;
    fam = FAMILY_OBJ(v);

    /* loop over the other elements, compare them with the current rep.    */
    for ( i = 2; i <= len; i++ ) {
        w = ELM_PLIST( list, i );
        mutable = (mutable || IS_MUTABLE_OBJ(w));
        if ( ! EQ( v, w ) ) {
            if ( l+1 != i ) {
                SET_ELM_PLIST( list, l+1, w );
                SET_ELM_PLIST( list, i, (Obj)0 );
            }
            l += 1;
            v = w;
            homog = (!mutable && homog && fam == FAMILY_OBJ(w));
        }
    }

    /* the list may be shorter now                                         */
    SET_LEN_PLIST( list, l );
    SHRINK_PLIST(  list, l );

    /* Set appropriate filters */
    if (!mutable)
      {
        if (!homog)
          SET_FILT_LIST(list, FN_IS_NHOMOG);
        else
          SET_FILT_LIST(list, FN_IS_HOMOG);
        SET_FILT_LIST(list, FN_IS_SSORT);
      }

    /* return whether the list contains mutable elements                   */
    if (mutable)
      return 0;
    if (!homog)
      return 1;
    else
      return 2;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncSORT_LIST( <self>, <list> ) . . . . . . . . . . . . . . . sort a list
*/
static Obj FuncSORT_LIST(Obj self, Obj list)
{
    RequireSmallList(SELF_NAME, list);

    if ( IS_DENSE_PLIST(list) ) {
        SortDensePlist( list );
    }
    else {
        SORT_LIST( list );
    }
    IS_SSORT_LIST(list);

    return 0;
}

static Obj FuncSTABLE_SORT_LIST(Obj self, Obj list)
{
    RequireSmallList(SELF_NAME, list);

    if ( IS_DENSE_PLIST(list) ) {
        SortDensePlistMerge( list );
    }
    else {
        SORT_LISTMerge( list );
    }
    IS_SSORT_LIST(list);

    return 0;
}



/****************************************************************************
**
*F  FuncSORT_LIST_COMP( <self>, <list>, <func> )  . . . . . . . . sort a list
*/
static Obj FuncSORT_LIST_COMP(Obj self, Obj list, Obj func)
{
    RequireSmallList(SELF_NAME, list);
    RequireFunction(SELF_NAME, func);

    if ( IS_DENSE_PLIST(list) ) {
        SortDensePlistComp( list, func );
    }
    else {
        SORT_LISTComp( list, func );
    }

    return 0;
}

static Obj FuncSTABLE_SORT_LIST_COMP(Obj self, Obj list, Obj func)
{
    RequireSmallList(SELF_NAME, list);
    RequireFunction(SELF_NAME, func);

    if ( IS_DENSE_PLIST(list) ) {
        SortDensePlistCompMerge( list, func );
    }
    else {
        SORT_LISTCompMerge( list, func );
    }

    return 0;
}


/****************************************************************************
**
*F  FuncSORT_PARA_LIST( <self>, <list> )  . . . . . . sort a list with shadow
*/
static Obj FuncSORT_PARA_LIST(Obj self, Obj list, Obj shadow)
{
    RequireSmallList(SELF_NAME, list);
    RequireSmallList(SELF_NAME, shadow);
    RequireSameLength(SELF_NAME, list, shadow);

    if ( IS_DENSE_PLIST(list) && IS_DENSE_PLIST(shadow) ) {
        SortParaDensePlist( list, shadow );
    }
    else {
        SORT_PARA_LIST( list, shadow );
    }
    IS_SSORT_LIST(list);

    return 0;
}

static Obj FuncSTABLE_SORT_PARA_LIST(Obj self, Obj list, Obj shadow)
{
    RequireSmallList(SELF_NAME, list);
    RequireSmallList(SELF_NAME, shadow);
    RequireSameLength(SELF_NAME, list, shadow);

    if ( IS_DENSE_PLIST(list) && IS_DENSE_PLIST(shadow) ) {
        SortParaDensePlistMerge( list, shadow );
    }
    else {
        SORT_PARA_LISTMerge( list, shadow );
    }
    IS_SSORT_LIST(list);

    return 0;
}


/****************************************************************************
**
*F  FuncSORT_LIST_COMP( <self>, <list>, <func> )  . . . . . . . . sort a list
*/
static Obj FuncSORT_PARA_LIST_COMP(Obj self, Obj list, Obj shadow, Obj func)
{
    RequireSmallList(SELF_NAME, list);
    RequireSmallList(SELF_NAME, shadow);
    RequireSameLength(SELF_NAME, list, shadow);
    RequireFunction(SELF_NAME, func);

    if ( IS_DENSE_PLIST(list) && IS_DENSE_PLIST(shadow) ) {
        SortParaDensePlistComp( list, shadow, func );
    }
    else {
        SORT_PARA_LISTComp( list, shadow, func );
    }

    return 0;
}

static Obj
FuncSTABLE_SORT_PARA_LIST_COMP(Obj self, Obj list, Obj shadow, Obj func)
{
    RequireSmallList(SELF_NAME, list);
    RequireSmallList(SELF_NAME, shadow);
    RequireSameLength(SELF_NAME, list, shadow);
    RequireFunction(SELF_NAME, func);

    if ( IS_DENSE_PLIST(list) && IS_DENSE_PLIST(shadow) ) {
        SortParaDensePlistCompMerge( list, shadow, func );
    }
    else {
        SORT_PARA_LISTCompMerge( list, shadow, func );
    }

    return 0;
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
static Obj FuncOnPoints(Obj self, Obj point, Obj elm)
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
static Obj FuncOnPairs(Obj self, Obj pair, Obj elm)
{
    Obj                 img;            /* image, result                   */
    Obj                 tmp;            /* temporary                       */

    RequireSmallList(SELF_NAME, pair);
    if (LEN_LIST(pair) != 2) {
        ErrorMayQuit("OnPairs: <pair> must have length 2, not length %d",
                     LEN_LIST(pair), 0);
    }

    /* create a new bag for the result                                     */
    img = NEW_PLIST_WITH_MUTABILITY( IS_MUTABLE_OBJ(pair), T_PLIST, 2 );
    SET_LEN_PLIST( img, 2 );

    /* and enter the images of the points into the result bag              */
    tmp = POW( ELMV_LIST( pair, 1 ), elm );
    SET_ELM_PLIST( img, 1, tmp );
    CHANGED_BAG( img );
    tmp = POW( ELMV_LIST( pair, 2 ), elm );
    SET_ELM_PLIST( img, 2, tmp );
    CHANGED_BAG( img );

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
static Obj FuncOnTuples(Obj self, Obj tuple, Obj elm)
{
    Obj                 img;            /* image, result                   */
    Obj                 tmp;            /* temporary                       */
    UInt                i;              /* loop variable                   */

    RequireSmallList(SELF_NAME, tuple);

    /* special case for the empty list */
    if (LEN_LIST(tuple) == 0) {
      if (IS_MUTABLE_OBJ(tuple)) {
        img = NewEmptyPlist();
        return img;
      } else {
        return tuple;
      }
    }
    /* special case for permutations                                       */
    if (IS_PERM(elm)) {
        return OnTuplesPerm( tuple, elm );
    }

    /* special case for transformations                                       */
    if (IS_TRANS(elm)) {
        return OnTuplesTrans( tuple, elm );
    }

    /* special case for partial perms */
    if (IS_PPERM(elm)) {
        return OnTuplesPPerm( tuple, elm );
    }

    /* create a new bag for the result                                     */
    img = NEW_PLIST_WITH_MUTABILITY( IS_MUTABLE_OBJ(tuple), T_PLIST, LEN_LIST(tuple) );
    SET_LEN_PLIST( img, LEN_LIST(tuple) );

    /* and enter the images of the points into the result bag              */
    for ( i = LEN_LIST(tuple); 1 <= i; i-- ) {
        tmp = POW( ELMV_LIST( tuple, i ), elm );
        SET_ELM_PLIST( img, i, tmp );
        CHANGED_BAG( img );
    }

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

static Obj FuncOnSets(Obj self, Obj set, Obj elm)
{
    Obj                 img;            /* handle of the image, result     */
    UInt                status;        /* the elements are mutable        */

    if (!HAS_FILT_LIST(set, FN_IS_SSORT) && !IS_SSORT_LIST(set)) {
        RequireArgument(SELF_NAME, set, "must be a set");
    }

    /* special case for the empty list */
    if (LEN_LIST(set) == 0) {
      if (IS_MUTABLE_OBJ(set)) {
        img = NewEmptyPlist();
        return img;
      } else {
        return set;
      }
    }
        
    /* special case for permutations                                       */
    if (IS_PERM(elm)) {
        return OnSetsPerm( set, elm );
    }

    /* special case for transformations */
    if (IS_TRANS(elm)){
      return OnSetsTrans( set, elm);
    }
    
    /* special case for partial perms */
    if (IS_PPERM(elm)){
      return OnSetsPPerm( set, elm);
    }

    /* compute the list of images                                          */
    img = FuncOnTuples( self, set, elm );

    /* sort the images list (which is a dense plain list)                  */
    SortDensePlist( img );

    /* remove duplicates, check for mutable elements                       */
    status = RemoveDupsDensePlist( img );

    /* if possible, turn this into a set                                   */
    switch (status)
      {
      case 0:
        break;
        
      case 1:
        RetypeBagSM( img, T_PLIST_DENSE_NHOM_SSORT );

      case 2:
        RetypeBagSM( img, T_PLIST_HOM_SSORT );

      }


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
static Obj FuncOnRight(Obj self, Obj point, Obj elm)
{
    return PROD( point, elm );
}


/****************************************************************************
**
*F  FuncOnLeftInverse( <self>, <point>, <elm> ) . . op by mult. from the left
**
**  'FuncOnLeftInverse' implements the internal function 'OnLeftInverse'.
**
**  'OnLeftInverse( <point>, <elm> )'
**
**  specifies that group elements operate by multiplication from the left
**  with the inverse.
*/
static Obj FuncOnLeftInverse(Obj self, Obj point, Obj elm)
{
    return LQUO(elm, point);
}

/****************************************************************************
**
*F  FuncSTRONGLY_CONNECTED_COMPONENTS_DIGRAPH
**
**  `digraph' should be a list whose entries and the lists of out-neighbours
** of the vertices. So [[2,3],[1],[2]] represents the graph whose edges are
** 1->2, 1->3, 2->1 and 3->2.
**
**  returns a newly constructed list whose elements are lists representing the
** strongly connected components of the directed graph. Neither the components,
** nor their elements are in any particular order.
**
** The algorithm is that of Tarjan, based on the implementation in Sedgwick,
** with a bug fixed, and made non-recursive to avoid problems with stack limits
** under (for instance) Linux. This version is a bit slower than the recursive
** version, but much faster than any of the GAP implementations.
**
** A possible change is to allocate the internal arrays rather smaller, and
** grow them if needed. This might allow some computations to complete that would
** otherwise run out of memory, but would slow things down a bit.
*/


static Obj FuncSTRONGLY_CONNECTED_COMPONENTS_DIGRAPH(Obj self, Obj digraph)
{
  UInt i,level,k,l,x,t,m;
  UInt now = 0,n;
  Obj val, stack, comps,comp;
  Obj frames, adj;
  UInt *fptr;

  n = LEN_LIST(digraph);
  if (n == 0)
    {
      return NewEmptyPlist();
    }
  val = NewBag(T_DATOBJ, (n+1)*sizeof(UInt));
  stack = NEW_PLIST(T_PLIST_CYC, n);
  comps = NEW_PLIST(T_PLIST_TAB, n);
  frames = NewBag(T_DATOBJ, (4*n+1)*sizeof(UInt));  
  for (k = 1; k <= n; k++)
    {
      if (((const UInt *)CONST_ADDR_OBJ(val))[k] == 0)
        {
          level = 1;
          adj = ELM_LIST(digraph, k);
          PLAIN_LIST(adj);
          fptr = (UInt *)ADDR_OBJ(frames);
          fptr[0] = k;
          now++;
          ((UInt *)ADDR_OBJ(val))[k] = now;
          fptr[1] = now;
          l = LEN_PLIST(stack);
          SET_ELM_PLIST(stack, l+1, INTOBJ_INT(k));
          SET_LEN_PLIST(stack, l+1);
          fptr[2] = 1;
          fptr[3] = (UInt)adj;
          while (level > 0 ) {
            if (fptr[2] > LEN_PLIST((Obj)fptr[3]))
              {
                if (fptr[1] == ((const UInt *)CONST_ADDR_OBJ(val))[fptr[0]])
                  {
                    l = LEN_PLIST(stack);
                    i = l;
                    do {
                      x = INT_INTOBJ(ELM_PLIST(stack, i));
                      ((UInt *)ADDR_OBJ(val))[x] = n+1;
                      i--;
                    } while (x != fptr[0]);
                    comp = NEW_PLIST(T_PLIST_CYC, l-i);
                    SET_LEN_PLIST(comp, l-i);
                    memcpy( (char *)(ADDR_OBJ(comp)) + sizeof(Obj),
                            (const char *)(CONST_ADDR_OBJ(stack)) + (i+1)*sizeof(Obj),
                            (size_t)((l - i )*sizeof(Obj)));
                    SET_LEN_PLIST(stack, i);
                    l = LEN_PLIST(comps);
                    SET_ELM_PLIST(comps, l+1, comp);
                    SET_LEN_PLIST(comps, l+1);
                    CHANGED_BAG(comps);
                    fptr = (UInt *)ADDR_OBJ(frames)+(level-1)*4;
                  }
                level--;
                fptr -= 4;
                if (level > 0 && fptr[5]  < fptr[1])
                  fptr[1] = fptr[5];
              }
            else
              {
                adj = (Obj)fptr[3];
                t = INT_INTOBJ(ELM_PLIST(adj, (fptr[2])++));
                m = ((const UInt *)CONST_ADDR_OBJ(val))[t];
                if (0 == m)
                  {
                    level++;
                    adj = ELM_LIST(digraph, t);
                    PLAIN_LIST(adj);
                    fptr = (UInt *)ADDR_OBJ(frames)+(level-1)*4;
                    fptr[0] = t;
                    now++;
                    ((UInt *)ADDR_OBJ(val))[t] = now;
                    fptr[1] = now;
                    l = LEN_PLIST(stack);
                    SET_ELM_PLIST(stack, l+1, INTOBJ_INT(t));
                    SET_LEN_PLIST(stack, l+1);
                    fptr[2] = 1;
                    fptr[3] = (UInt)adj;
                  }
                else
                  {
                    if (m < fptr[1])
                      fptr[1] = m;
                  }
              }
          }
        }
      
    }
  SHRINK_PLIST(comps, LEN_PLIST(comps));
  return comps;
}


/****************************************************************************
**
*F  FuncCOPY_LIST_ENTRIES( <self>, <args> ) . . mass move of list entries
**
**  Argument names in the manual: fromlst, fromind, fromstep, tolst, toind, tostep, n
*/

static Obj FuncCOPY_LIST_ENTRIES(Obj self, Obj args)
{  
  Obj srclist;
  Int srcstart;
  Int srcinc;
  Obj dstlist;
  Int dststart;
  Int dstinc;
  UInt number;
  UInt srcmax;
  UInt dstmax;
  const Obj *sptr;
  Obj *dptr;
  UInt ct;

  GAP_ASSERT(IS_PLIST(args));
  if (LEN_PLIST(args) != 7) {
      ErrorMayQuitNrArgs(7, LEN_PLIST(args));
  }
  srclist = ELM_PLIST(args, 1);
  GAP_ASSERT(srclist != 0);
  if (!IS_PLIST(srclist))
      RequireArgumentEx(SELF_NAME, srclist, "<fromlst>",
                        "must be a plain list");

  srcstart = GetSmallIntEx("CopyListEntries", ELM_PLIST(args, 2), "<fromind>");
  srcinc = GetSmallIntEx("CopyListEntries", ELM_PLIST(args, 3), "<fromstep>");
  dstlist = ELM_PLIST(args,4);
  GAP_ASSERT(dstlist != 0);
  if (!IS_PLIST(dstlist) || !IS_MUTABLE_OBJ(dstlist))
      RequireArgumentEx(SELF_NAME, dstlist, "<tolst>",
                        "must be a mutable plain list");
  dststart = GetSmallIntEx("CopyListEntries", ELM_PLIST(args, 5), "<toind>");
  dstinc = GetSmallIntEx("CopyListEntries", ELM_PLIST(args, 6), "<tostep>");
  number = GetSmallIntEx("CopyListEntries", ELM_PLIST(args, 7), "<n>");

  if (number == 0)
    return (Obj) 0;
  
  if ( srcstart <= 0 || dststart <= 0 ||
       srcstart + (number-1)*srcinc <= 0 || dststart + (number-1)*dstinc <= 0)
    {
      ErrorMayQuit("CopyListEntries: list indices must be positive integers",
                   0, 0);
    }

  srcmax = (srcinc > 0) ? srcstart + (number-1)*srcinc : srcstart;
  dstmax = (dstinc > 0) ? dststart + (number-1)*dstinc : dststart;
  
  GROW_PLIST(dstlist, dstmax);
  GROW_PLIST(srclist, srcmax);
  if (srcinc == 1 && dstinc == 1)
    {
      SyMemmove(ADDR_OBJ(dstlist) + dststart,
              CONST_ADDR_OBJ(srclist) + srcstart,
              (size_t) number*sizeof(Obj));
    }
  else if (srclist != dstlist)
    {
      sptr = CONST_ADDR_OBJ(srclist) + srcstart;
      dptr = ADDR_OBJ(dstlist) + dststart;
      for (ct = 0; ct < number ; ct++)
        {
          *dptr = *sptr;
          sptr += srcinc;
          dptr += dstinc;
        }
    }
  else if (srcinc == dstinc)
    {
      if (srcstart == dststart)
        return (Obj)0;
      else
        {
          if ((srcstart > dststart) == (srcinc > 0))
            {
              sptr = CONST_ADDR_OBJ(srclist) + srcstart;
              dptr = ADDR_OBJ(srclist) + dststart;
              for (ct = 0; ct < number ; ct++)
                {
                  *dptr = *sptr;
                  sptr += srcinc;
                  dptr += srcinc;
                }
            }
          else
            {
              sptr = CONST_ADDR_OBJ(srclist) + srcstart + number*srcinc;
              dptr = ADDR_OBJ(srclist) + dststart + number*srcinc;
              for (ct = 0; ct < number; ct++)
                {
                  sptr -= srcinc;
                  dptr -= srcinc;
                  *dptr = *sptr;
                }
              
            }
        }
              
    }
  else
    {
      Obj tmplist = NEW_PLIST(T_PLIST,number);
      sptr = CONST_ADDR_OBJ(srclist)+srcstart;
      dptr = ADDR_OBJ(tmplist)+1;
      for (ct = 0; ct < number; ct++)
        {
          *dptr = *sptr;
          dptr++;
          sptr += srcinc;
        }
      sptr = CONST_ADDR_OBJ(tmplist)+1;
      dptr = ADDR_OBJ(srclist)+dststart;
      for (ct = 0; ct < number; ct++)
        {
          *dptr = *sptr;
          sptr++;
          dptr += dstinc;
        }
    }

  if (dstmax > LEN_PLIST(dstlist))
    {
      sptr = CONST_ADDR_OBJ(dstlist)+dstmax;
      ct = dstmax;
      while (!*sptr)
        {
          ct--;
          sptr--;
        }
      SET_LEN_PLIST(dstlist, ct);
    }
  if (LEN_PLIST(dstlist) > 0)
    RetypeBag(dstlist, T_PLIST);
  else
    RetypeBag(dstlist, T_PLIST_EMPTY);
  return (Obj) 0;

}


static Obj FuncLIST_WITH_IDENTICAL_ENTRIES(Obj self, Obj n, Obj obj)
{
    RequireNonnegativeSmallInt(SELF_NAME, n);

    Obj  list = 0;
    Int  len = INT_INTOBJ(n);
    UInt tnum = TNUM_OBJ(obj);

    if (tnum == T_CHAR) {
        list = NEW_STRING(len);
        memset(CHARS_STRING(list), CHAR_VALUE(obj), len);
    }
    else if (obj == True || obj == False) {
        list = NewBag(T_BLIST, SIZE_PLEN_BLIST(len));
        SET_LEN_BLIST(list, len);
        if (obj == True) {
            UInt * ptrBlist = BLOCKS_BLIST(list);
            for (; len >= BIPEB; len -= BIPEB)
                *ptrBlist++ = ~(UInt)0;
            if (len > 0)
                *ptrBlist |= ((UInt)1 << len) - 1;
        }
    }
    else if (len == 0) {
        list = NewEmptyPlist();
    }
    else {
        switch (tnum) {
        case T_INT:
        case T_INTPOS:
        case T_INTNEG:
        case T_RAT:
        case T_CYC:
            tnum = T_PLIST_CYC;
            break;
        case T_FFE:
            tnum = T_PLIST_FFE;
            break;
        default:
            tnum = T_PLIST_HOM;
            break;
        }
        list = NEW_PLIST(tnum, len);
        for (int i = 1; i <= len; i++) {
            SET_ELM_PLIST(list, i, obj);
        }
        CHANGED_BAG(list);
        SET_LEN_PLIST(list, len);
    }

    return list;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    // ADD_LIST can take 2 or 3 arguments; since NewOperation ignores the
    // handler for variadic operations, use DoOperation0Args as a placeholder.
    { "ADD_LIST", -1, "list, obj[, pos]", &AddListOper,
      DoOperation0Args, "src/listfunc.c:ADD_LIST" },

    GVAR_OPER_1ARGS(REM_LIST, list, &RemListOper),
    GVAR_OPER_2ARGS(APPEND_LIST, list, val, &AppendListOper),
    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_2ARGS(APPEND_LIST_INTR, list1, list2),
    GVAR_FUNC_2ARGS(POSITION_SORTED_LIST, list, obj),
    GVAR_FUNC_3ARGS(POSITION_SORTED_LIST_COMP, list, obj, func),
    GVAR_FUNC_3ARGS(POSITION_SORTED_BY, list, val, func),
    GVAR_FUNC_1ARGS(SORT_LIST, list),
    GVAR_FUNC_1ARGS(STABLE_SORT_LIST, list),
    GVAR_FUNC_2ARGS(SORT_LIST_COMP, list, func),
    GVAR_FUNC_2ARGS(STABLE_SORT_LIST_COMP, list, func),
    GVAR_FUNC_2ARGS(SORT_PARA_LIST, list, list),
    GVAR_FUNC_2ARGS(STABLE_SORT_PARA_LIST, list, list),
    GVAR_FUNC_3ARGS(SORT_PARA_LIST_COMP, list, list, func),
    GVAR_FUNC_3ARGS(STABLE_SORT_PARA_LIST_COMP, list, list, func),
    GVAR_FUNC_2ARGS(OnPoints, pnt, elm),
    GVAR_FUNC_2ARGS(OnPairs, pair, elm),
    GVAR_FUNC_2ARGS(OnTuples, tuple, elm),
    GVAR_FUNC_2ARGS(OnSets, set, elm),
    GVAR_FUNC_2ARGS(OnRight, pnt, elm),
    GVAR_FUNC_2ARGS(OnLeftInverse, pnt, elm),
    GVAR_FUNC(COPY_LIST_ENTRIES, -1, "srclist,srcstart,srcinc,dstlist,dststart,dstinc,number"),
    GVAR_FUNC_1ARGS(STRONGLY_CONNECTED_COMPONENTS_DIGRAPH, digraph),
    GVAR_FUNC_2ARGS(LIST_WITH_IDENTICAL_ENTRIES, n, obj),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    /* ADD_LIST needs special consideration because we want distinct kernel
       handlers for 2 and 3 arguments */
    InitHandlerFunc( FuncADD_LIST, "src/listfunc.c:FuncADD_LIST" );
    InitHandlerFunc( FuncADD_LIST3, "src/listfunc.c:FuncADD_LIST3" );

    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );


    
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

    /* make and install the 'ADD_LIST' operation                           */
    SET_HDLR_FUNC( AddListOper, 2, FuncADD_LIST);
    SET_HDLR_FUNC( AddListOper, 3, FuncADD_LIST3);

    return 0;
}


/****************************************************************************
**
*F  InitInfoListFunc()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "listfunc",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoListFunc ( void )
{
    return &module;
}
