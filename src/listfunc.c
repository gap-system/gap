/****************************************************************************
**
*W  listfunc.c                  GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions for generic lists.
*/
#include <src/system.h>                 /* Ints, UInts */



#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/stringobj.h>              /* strings */

#include <src/bool.h>                   /* booleans */

#include <src/permutat.h>               /* permutations */
#include <src/finfield.h>               /* finite fields */
#include <src/trans.h>                  /* transformations */
#include <src/pperm.h>                  /* partial perms */

#include <src/listfunc.h>               /* functions for generic lists */

#include <src/plist.h>                  /* plain lists */
#include <src/set.h>                    /* plain sets */
#include <src/code.h>
#include <src/gmpints.h>

#include <src/hpc/guards.h>
#include <src/hpc/aobjects.h>           /* atomic objects */

#include <src/blister.h>


#include <string.h>
#include <stdlib.h> 

/****************************************************************************
**
*F  AddList(<list>,<obj>) . . . . . . . .  add an object to the end of a list
**
**  'AddList' adds the object <obj> to the end  of  the  list  <list>,  i.e.,
**  it is equivalent to the assignment '<list>[ Length(<list>)+1 ] := <obj>'.
**  The  list is  automatically extended to   make room for  the new element.
**  'AddList' returns nothing, it is called only for its side effect.
*/
void            AddList3 (
    Obj                 list,
    Obj                 obj,
    Int                 pos)
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

extern Obj FuncADD_LIST(
    Obj                 self,
    Obj                 list,
    Obj                 obj );

extern Obj FuncADD_LIST3(
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 pos );


void            AddPlist3 (
    Obj                 list,
    Obj                 obj,
    Int                 pos )
{
  UInt len;

    if ( ! IS_MUTABLE_PLIST(list) ) {
        list = ErrorReturnObj(
                "Lists Assignment: <list> must be a mutable list",
                0L, 0L,
                "you may replace <list> via 'return <list>;'" );
        FuncADD_LIST( 0, list, obj );
        return;
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
      memmove(ADDR_OBJ(list) + pos+1,
              CONST_ADDR_OBJ(list) + pos,
              (size_t)(sizeof(Obj)*(len - pos + 1)));
    }
    ASS_LIST( list, pos, obj);
}
void            AddPlist (
    Obj                 list,
    Obj                 obj)
{

  AddPlist3(list, obj, -1);
}

Obj AddListOper;

Obj FuncADD_LIST3 (
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 pos)
{
    /* dispatch                */
  Int ipos;
  if (pos == (Obj)0)
    ipos = -1;
  else if (IS_INTOBJ(pos) && INT_INTOBJ(pos) > 0)
    ipos = INT_INTOBJ(pos);
  else {
    DoOperation3Args( self, list,  obj, pos);
    return (Obj) 0;
  }
  if ( IS_PLIST( list ) ) {
    AddPlist3( list, obj, ipos );
  } else if ( TNUM_OBJ( list ) < FIRST_EXTERNAL_TNUM ) {
    AddList3( list, obj, ipos );
#ifdef HPCGAP
  } else if ( TNUM_OBJ(list) == T_ALIST ) {
    AddAList( list, obj );
#endif
  } else {
    if (pos == 0)
      DoOperation2Args( self, list, obj );
    else
      DoOperation3Args( self, list, obj, pos);
  }

    /* return nothing                                                      */
    return (Obj)0;
}


Obj FuncADD_LIST (
                  Obj self,
                  Obj list,
                  Obj obj)
{
  FuncADD_LIST3(self, list, obj, (Obj)0);
  return (Obj) 0;
}


/****************************************************************************
**
*F  RemList(<list>) . . . . . . . .  add an object to the end of a list
**
**  'RemList' removes the last object <obj> from the end  of  the  list  
** <list>,  and returns it.
*/
Obj            RemList (
    Obj                 list)
{
    Int                 pos; 
    Obj result;
    pos = LEN_LIST( list ) ;
    if ( pos == 0L ) {
        list = ErrorReturnObj(
                "Remove: <list> must not be empty",
                0L, 0L,
                "you may replace <list> via 'return <list>;'" );
        return RemList(list);
    }
    result = ELM_LIST(list, pos);
    UNB_LIST(list, pos);
    return result;
}

extern Obj FuncREM_LIST(
    Obj                 self,
    Obj                 list);

Obj            RemPlist (
                          Obj                 list)
{
    Int                 pos;           
    Obj removed; 

    if ( ! IS_MUTABLE_PLIST(list) ) {
        list = ErrorReturnObj(
                "Remove: <list> must be a mutable list",
                0L, 0L,
                "you may replace <list> via 'return <list>;'" );
        return FuncREM_LIST( 0, list);
    }
    pos = LEN_PLIST( list );
    if ( pos == 0L ) {
        list = ErrorReturnObj(
                "Remove: <list> must not be empty",
                0L, 0L,
                "you may replace <list> via 'return <list>;'" );
        return FuncREM_LIST( 0, list);
    }
    removed = ELM_PLIST(list, pos);
    SET_ELM_PLIST(list, pos, (Obj)0L);
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

Obj RemListOper;

Obj FuncREM_LIST (
    Obj                 self,
    Obj                 list)

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
**  'FuncAPPEND_LIST_INTR' implements the function 'AppendList'.
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
    UInt                len1;           /* length of the first list        */
    UInt                len2;           /* length of the second list       */
    Obj *               ptr1;           /* pointer into the first list     */
    const Obj *         ptr2;           /* pointer into the second list    */
    Obj                 elm;            /* one element of the second list  */
    Int                 i;              /* loop variable                   */

    /* check the mutability of the first argument */
    while ( !IS_MUTABLE_OBJ( list1) )
      list1 = ErrorReturnObj (
                "Append: <list1> must be a mutable list",
                0L, 0L,
                "you can replace <list1> via 'return <list1>;'");
    

    /* handle the case of strings now */
    if ( IS_STRING_REP(list1) && IS_STRING_REP(list2))
      {
        len1 = GET_LEN_STRING(list1);
        len2 = GET_LEN_STRING(list2);
        GROW_STRING(list1, len1 + len2);
        SET_LEN_STRING(list1, len1 + len2);
        CLEAR_FILTS_LIST(list1);
        memmove( CHARS_STRING(list1) + len1, CHARS_STRING(list2), len2 + 1);
        /* ensure trailing zero */
        *(CHARS_STRING(list1) + len1 + len2) = 0;    
        return (Obj) 0;
      }
    
    /* check the type of the first argument                                */
    if ( TNUM_OBJ( list1 ) != T_PLIST ) {
        while ( ! IS_SMALL_LIST( list1 ) ) {
            list1 = ErrorReturnObj(
                "AppendList: <list1> must be a small list (not a %s)",
                (Int)TNAM_OBJ(list1), 0L,
                "you can replace <list1> via 'return <list1>;'" );
        }
        if ( ! IS_PLIST( list1 ) ) {
            PLAIN_LIST( list1 );
        }
        RetypeBag( list1, T_PLIST );
    }
    len1 = LEN_PLIST( list1 );

    /* check the type of the second argument                               */
    if ( ! IS_PLIST( list2 ) ) {
        while ( ! IS_SMALL_LIST( list2 ) ) {
            list2 = ErrorReturnObj(
                "AppendList: <list2> must be a small list (not a %s)",
                (Int)TNAM_OBJ(list2), 0L,
                "you can replace <list2> via 'return <list2>;'"  );
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
    if ( IS_PLIST(list2) ) {
        ptr1 = ADDR_OBJ(list1) + len1;
        ptr2 = CONST_ADDR_OBJ(list2);
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
    while ( ! IS_SMALL_LIST(list) ) {
        list = ErrorReturnObj(
            "POSITION_SORTED_LIST: <list> must be a small list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can replace <list> via 'return <list>;'" );
    }

    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) ) {
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

Obj             FuncPOSITION_SORTED_LIST_COMP (
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 func )
{
    UInt                h;              /* position, result                */

    /* check the first argument                                            */
    while ( ! IS_SMALL_LIST(list) ) {
        list = ErrorReturnObj(
            "POSITION_SORTED_LIST_COMP: <list> must be a small list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can replace <list> via 'return <list>;'" );
    }

    /* check the third argument                                            */
    while ( TNUM_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "POSITION_SORTED_LIST_COMP: <func> must be a function (not a %s)",
            (Int)TNAM_OBJ(func), 0L,
            "you can replace <func> via 'return <func>;'" );
    }

    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) ) {
        h = PositionSortedDensePlistComp( list, obj, func );
    }
    else {
        h = POSITION_SORTED_LISTComp( list, obj, func );
    }

    /* return the result                                                   */
    return INTOBJ_INT( h );
}


Obj             FuncPOSITION_FIRST_COMPONENT_SORTED (
    Obj                 self,
    Obj                 list,
    Obj                 obj)
{
  UInt top, bottom,middle;
  Obj x;
  Obj l;
  bottom = 1;
  top = LEN_PLIST(list);
  while (bottom <= top) {
    middle = (top + bottom)/2;
    l = ELM_PLIST(list,middle);
    if (!IS_PLIST(l))
      return TRY_NEXT_METHOD;
    x = ELM_PLIST(l,1);
    if (LT(x,obj)) {
      bottom = middle+1;
    } else if (LT(obj,x)) {
      top = middle -1;
    } else {
      return INTOBJ_INT(middle);
    }
  }
  return INTOBJ_INT(bottom);
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

#include <src/sortbase.h>

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

#include <src/sortbase.h>

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

#include <src/sortbase.h>

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

#include <src/sortbase.h>

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

#include <src/sortbase.h>

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

#include <src/sortbase.h>

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

#include <src/sortbase.h>
  
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

#include <src/sortbase.h>



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
**  Some common checks.
*/

static void CheckIsSmallList( Obj list, const Char * caller)
{
  if ( ! IS_SMALL_LIST(list) ) {
    ErrorMayQuit("%s: <list> must be a small list (not a %s)",
                 (Int)caller, (Int)TNAM_OBJ(list));
  }
}

static void CheckIsFunction(Obj func, const Char * caller)
{
  if ( TNUM_OBJ( func ) != T_FUNCTION ) {
    ErrorMayQuit("%s: <func> must be a function (not a %s)",
          (Int)caller, (Int)TNAM_OBJ(func));
  }
}

/****************************************************************************
**
*F  FuncSORT_LIST( <self>, <list> ) . . . . . . . . . . . . . . . sort a list
*/
Obj FuncSORT_LIST (
    Obj                 self,
    Obj                 list )
{
    /* check the first argument                                            */
    CheckIsSmallList(list, "SORT_LIST");

    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) ) {
        SortDensePlist( list );
    }
    else {
        SORT_LIST( list );
    }
    IS_SSORT_LIST(list);

    /* return nothing                                                      */
    return (Obj)0;
}

Obj FuncSTABLE_SORT_LIST (
    Obj                 self,
    Obj                 list )
{
    /* check the first argument                                            */
    CheckIsSmallList(list, "STABLE_SORT_LIST");

    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) ) {
        SortDensePlistMerge( list );
    }
    else {
        SORT_LISTMerge( list );
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
    CheckIsSmallList(list, "SORT_LIST_COMP");

    /* check the third argument                                            */
    CheckIsFunction(func, "SORT_LIST_COMP");

    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) ) {
        SortDensePlistComp( list, func );
    }
    else {
        SORT_LISTComp( list, func );
    }

    /* return nothing                                                      */
    return (Obj)0;
}

Obj FuncSTABLE_SORT_LIST_COMP (
    Obj                 self,
    Obj                 list,
    Obj                 func )
{
    /* check the first argument                                            */
    CheckIsSmallList(list, "STABLE_SORT_LIST_COMP");

    /* check the third argument                                            */
    CheckIsFunction(func, "STABLE_SORT_LIST_COMP");

    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) ) {
        SortDensePlistCompMerge( list, func );
    }
    else {
        SORT_LISTCompMerge( list, func );
    }

    /* return nothing                                                      */
    return (Obj)0;
}


/****************************************************************************
**
*F  FuncSORT_PARA_LIST( <self>, <list> )  . . . . . . sort a list with shadow
*/
Obj FuncSORT_PARA_LIST (
    Obj                 self,
    Obj                 list,
    Obj               shadow )
{
    /* check the first two arguments                                       */
    CheckIsSmallList(list, "SORT_PARA_LIST");
    CheckIsSmallList(shadow, "SORT_PARA_LIST");

    if( LEN_LIST( list ) != LEN_LIST( shadow ) ) {
        ErrorMayQuit( 
            "SORT_PARA_LIST: lists must have the same length (not %d and %d)",
            (Int)LEN_LIST( list ),
            (Int)LEN_LIST( shadow ));
    }

    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) && IS_DENSE_PLIST(shadow) ) {
        SortParaDensePlist( list, shadow );
    }
    else {
        SORT_PARA_LIST( list, shadow );
    }
    IS_SSORT_LIST(list);

    /* return nothing                                                      */
    return (Obj)0;
}

Obj FuncSTABLE_SORT_PARA_LIST (
    Obj                 self,
    Obj                 list,
    Obj               shadow )
{
    /* check the first two arguments                                       */
    CheckIsSmallList(list, "STABLE_SORT_PARA_LIST");
    CheckIsSmallList(shadow, "STABLE_SORT_PARA_LIST");

    if( LEN_LIST( list ) != LEN_LIST( shadow ) ) {
        ErrorMayQuit( 
            "STABLE_SORT_PARA_LIST: lists must have the same length (not %d and %d)",
            (Int)LEN_LIST( list ),
            (Int)LEN_LIST( shadow ));
    }

    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) && IS_DENSE_PLIST(shadow) ) {
        SortParaDensePlistMerge( list, shadow );
    }
    else {
        SORT_PARA_LISTMerge( list, shadow );
    }
    IS_SSORT_LIST(list);

    /* return nothing                                                      */
    return (Obj)0;
}


/****************************************************************************
**
*F  FuncSORT_LIST_COMP( <self>, <list>, <func> )  . . . . . . . . sort a list
*/
Obj FuncSORT_PARA_LIST_COMP (
    Obj                 self,
    Obj                 list,
    Obj               shadow,
    Obj                 func )
{
    /* check the first two arguments                                       */
    CheckIsSmallList(list, "SORT_PARA_LIST_COMP");
    CheckIsSmallList(shadow, "SORT_PARA_LIST_COMP");

    if( LEN_LIST( list ) != LEN_LIST( shadow ) ) {
        ErrorMayQuit( 
            "SORT_PARA_LIST_COMP: lists must have the same length (not %d and %d)",
            (Int)LEN_LIST( list ),
            (Int)LEN_LIST( shadow ));
    }

    /* check the third argument                                            */
    CheckIsFunction(func, "SORT_PARA_LIST_COMP");
    
    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) && IS_DENSE_PLIST(shadow) ) {
        SortParaDensePlistComp( list, shadow, func );
    }
    else {
        SORT_PARA_LISTComp( list, shadow, func );
    }

    /* return nothing                                                      */
    return (Obj)0;
}

Obj FuncSTABLE_SORT_PARA_LIST_COMP (
    Obj                 self,
    Obj                 list,
    Obj               shadow,
    Obj                 func )
{
    /* check the first two arguments                                       */
    CheckIsSmallList(list, "SORT_PARA_LIST_COMP");
    CheckIsSmallList(shadow, "SORT_PARA_LIST_COMP");

    if( LEN_LIST( list ) != LEN_LIST( shadow ) ) {
        ErrorMayQuit( 
            "SORT_PARA_LIST_COMP: lists must have the same length (not %d and %d)",
            (Int)LEN_LIST( list ),
            (Int)LEN_LIST( shadow ));
    }

    /* check the third argument                                            */
    CheckIsFunction(func, "SORT_PARA_LIST_COMP");
    
    /* dispatch                                                            */
    if ( IS_DENSE_PLIST(list) && IS_DENSE_PLIST(shadow) ) {
        SortParaDensePlistCompMerge( list, shadow, func );
    }
    else {
        SORT_PARA_LISTCompMerge( list, shadow, func );
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
    while ( ! IS_SMALL_LIST( pair ) || LEN_LIST( pair ) != 2 ) {
        pair = ErrorReturnObj(
            "OnPairs: <pair> must be a list of length 2 (not a %s)",
            (Int)TNAM_OBJ(pair), 0L,
            "you can replace <pair> via 'return <pair>;'" );
    }

    /* create a new bag for the result                                     */
    img = NEW_PLIST( IS_MUTABLE_OBJ(pair) ? T_PLIST : T_PLIST+IMMUTABLE, 2 );
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
    while ( ! IS_SMALL_LIST( tuple ) ) {
        tuple = ErrorReturnObj(
            "OnTuples: <tuple> must be a small list (not a %s)",
            (Int)TNAM_OBJ(tuple), 0L,
            "you can replace <tuple> via 'return <tuple>;'" );
    }

    /* special case for the empty list */
    if ( HAS_FILT_LIST( tuple, FN_IS_EMPTY )) {
      if (IS_MUTABLE_OBJ(tuple)) {
        img = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(img,0);
        return img;
      } else {
        return tuple;
      }
    }
    /* special case for permutations                                       */
    if ( TNUM_OBJ(elm) == T_PERM2 || TNUM_OBJ(elm) == T_PERM4 ) {
        PLAIN_LIST( tuple );
        return OnTuplesPerm( tuple, elm );
    }

    /* special case for transformations                                       */
    if ( TNUM_OBJ(elm) == T_TRANS2 || TNUM_OBJ(elm) == T_TRANS4 ) {
        PLAIN_LIST( tuple );
        return OnTuplesTrans( tuple, elm );
    }

    /* special case for partial perms */
    if ( TNUM_OBJ(elm) == T_PPERM2 || TNUM_OBJ(elm) == T_PPERM4 ) {
        PLAIN_LIST( tuple );
        return OnTuplesPPerm( tuple, elm );
    }

    /* create a new bag for the result                                     */
    img = NEW_PLIST( IS_MUTABLE_OBJ(tuple) ? T_PLIST : T_PLIST+IMMUTABLE, LEN_LIST(tuple) );
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
    UInt                status;        /* the elements are mutable        */

    /* check the type of the first argument                                */
    while ( !HAS_FILT_LIST(set, FN_IS_SSORT) && ! IsSet( set ) ) {
        set = ErrorReturnObj(
            "OnSets: <set> must be a set (not a %s)",
            (Int)TNAM_OBJ(set), 0L,
            "you can replace <set> via 'return <set>;'" );
    }

    /* special case for the empty list */
    if ( HAS_FILT_LIST( set, FN_IS_EMPTY )) {
      if (IS_MUTABLE_OBJ(set)) {
        img = NEW_PLIST(T_PLIST_EMPTY, 0);
        SET_LEN_PLIST(img,0);
        return img;
      } else {
        return set;
      }
    }
        
    /* special case for permutations                                       */
    if ( TNUM_OBJ(elm) == T_PERM2 || TNUM_OBJ(elm) == T_PERM4 ) {
        PLAIN_LIST( set );
        return OnSetsPerm( set, elm );
    }

    /* special case for transformations */
    if ( TNUM_OBJ(elm)== T_TRANS2 || TNUM_OBJ(elm) == T_TRANS4 ){
      PLAIN_LIST(set);
      return OnSetsTrans( set, elm);
    }
    
    /* special case for partial perms */
    if ( TNUM_OBJ(elm)== T_PPERM2 || TNUM_OBJ(elm) == T_PPERM4 ){
      PLAIN_LIST(set);
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
        RetypeBag( img, T_PLIST_DENSE_NHOM_SSORT );

      case 2:
        RetypeBag( img, T_PLIST_HOM_SSORT );

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
*F  FuncOnLeftInverse( <self>, <point>, <elm> ) . . op by mult. from the left
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
      return NEW_PLIST(T_PLIST_EMPTY,0);
    }
  val = NewBag(T_DATOBJ, (n+1)*sizeof(UInt));
  stack = NEW_PLIST(T_PLIST_CYC, n);
  SET_LEN_PLIST(stack, 0);
  comps = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(comps, 0);
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
*/

static inline Int GetIntObj( Obj list, UInt pos)
{
  Obj entry;
  entry = ELM_PLIST(list, pos);
  if (!entry)
    {
      Pr("panic: internal inconsistency", 0L, 0L);
      SyExit(1);
    }
  if (!IS_INTOBJ(entry))
    {
      ErrorMayQuit("COPY_LIST_ENTRIES: argument %d  must be a small integer, not a %s",
                   (Int)pos, (Int)InfoBags[TNUM_OBJ(entry)].name);
    }
  return INT_INTOBJ(entry);
}

Obj FuncCOPY_LIST_ENTRIES( Obj self, Obj args )
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

  if (!IS_PLIST(args))
    {
      Pr("panic: internal inconsistency",0L,0L);
      SyExit(1);
    }
  if (LEN_PLIST(args) != 7)
    {
      ErrorMayQuit("COPY_LIST_ENTRIES: number of arguments must be 7, not %d",
                   (Int)LEN_PLIST(args), 0L);
    }
  srclist = ELM_PLIST(args,1);
  if (!srclist)
    {
      Pr("panic: internal inconsistency", 0L, 0L);
      SyExit(1);
    }
  if (!IS_PLIST(srclist))
    {
      ErrorMayQuit("COPY_LIST_ENTRIES: source must be a plain list not a %s",
                   (Int)InfoBags[TNUM_OBJ(srclist)].name, 0L);
    }

  srcstart = GetIntObj(args,2);
  srcinc = GetIntObj(args,3);
  dstlist = ELM_PLIST(args,4);
  if (!dstlist)
    {
      Pr("panic: internal inconsistency", 0L, 0L);
      SyExit(1);
    }
  while (!IS_PLIST(dstlist) || !IS_MUTABLE_OBJ(dstlist))
    {
      ErrorMayQuit("COPY_LIST_ENTRIES: destination must be a mutable plain list not a %s",
                   (Int)InfoBags[TNUM_OBJ(dstlist)].name, 0L);
    }
  dststart = GetIntObj(args,5);
  dstinc = GetIntObj(args,6);
  number = GetIntObj(args,7);
  
  if (number == 0)
    return (Obj) 0;
  
  if ( srcstart <= 0 || dststart <= 0 ||
       srcstart + (number-1)*srcinc <= 0 || dststart + (number-1)*dstinc <= 0)
    {
      ErrorMayQuit("COPY_LIST_ENTRIES: list indices must be positive integers",0L,0L);
    }

  srcmax = (srcinc > 0) ? srcstart + (number-1)*srcinc : srcstart;
  dstmax = (dstinc > 0) ? dststart + (number-1)*dstinc : dststart;
  
  GROW_PLIST(dstlist, dstmax);
  GROW_PLIST(srclist, srcmax);
  if (srcinc == 1 && dstinc == 1)
    {
      memmove(ADDR_OBJ(dstlist) + dststart,
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


Obj FuncLIST_WITH_IDENTICAL_ENTRIES(Obj self, Obj n, Obj obj)
{
    if (!IS_NONNEG_INTOBJ(n)) {
        ErrorQuit("<n> must be a non-negative integer (not a %s)",
                  (Int)TNAM_OBJ(n), 0L);
    }

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
                *ptrBlist |= (1UL << len) - 1;
        }
    }
    else if (len == 0) {
        list = NEW_PLIST(T_PLIST_EMPTY, 0);
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
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
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

    GVAR_OPER(REM_LIST, 1, "list", &RemListOper),
    GVAR_OPER(APPEND_LIST, 2, "list, val", &AppendListOper),
    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(APPEND_LIST_INTR, 2, "list1, list2"),
    GVAR_FUNC(POSITION_SORTED_LIST, 2, "list, obj"),
    GVAR_FUNC(POSITION_SORTED_LIST_COMP, 3, "list, obj, func"),
    GVAR_FUNC(POSITION_FIRST_COMPONENT_SORTED, 2, "list, obj"),
    GVAR_FUNC(SORT_LIST, 1, "list"),
    GVAR_FUNC(STABLE_SORT_LIST, 1, "list"),
    GVAR_FUNC(SORT_LIST_COMP, 2, "list, func"),
    GVAR_FUNC(STABLE_SORT_LIST_COMP, 2, "list, func"),
    GVAR_FUNC(SORT_PARA_LIST, 2, "list, list"),
    GVAR_FUNC(STABLE_SORT_PARA_LIST, 2, "list, list"),
    GVAR_FUNC(SORT_PARA_LIST_COMP, 3, "list, list, func"),
    GVAR_FUNC(STABLE_SORT_PARA_LIST_COMP, 3, "list, list, func"),
    GVAR_FUNC(OnPoints, 2, "pnt, elm"),
    GVAR_FUNC(OnPairs, 2, "pair, elm"),
    GVAR_FUNC(OnTuples, 2, "tuple, elm"),
    GVAR_FUNC(OnSets, 2, "set, elm"),
    GVAR_FUNC(OnRight, 2, "pnt, elm"),
    GVAR_FUNC(OnLeftAntiOperation, 2, "pnt, elm"),
    GVAR_FUNC(OnLeftInverse, 2, "pnt, elm"),
    GVAR_FUNC(COPY_LIST_ENTRIES, -1, "srclist,srcstart,srcinc,dstlist,dststart,dstinc,number"),
    GVAR_FUNC(STRONGLY_CONNECTED_COMPONENTS_DIGRAPH, 1, "digraph"),
    GVAR_FUNC(LIST_WITH_IDENTICAL_ENTRIES, 2, "n, obj"),
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

    /* make and install the 'ADD_LIST' operation                           */
    SET_HDLR_FUNC( AddListOper, 2, FuncADD_LIST);
    SET_HDLR_FUNC( AddListOper, 3, FuncADD_LIST3);

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
    return &module;
}
