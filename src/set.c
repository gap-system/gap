/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions which mainly deal with proper sets.
**
**  A *proper set* is a list that has no holes, no duplicates, and is sorted.
**  For the full definition  of sets see chapter "Sets" in the {\GAP} Manual.
**  Read also section "More about Sets" about the internal flag for sets.
**
**  The second part consists  of the functions 'IsSet', 'SetList', 'SetList',
**  'IsEqualSet',  'IsSubsetSet',    'AddSet',    'RemoveSet',    'UniteSet',
**  'IntersectSet',  and 'SubtractSet'.  These  functions make it possible to
**  make sets, either  by converting a  list to  a  set, or  by computing the
**  union, intersection, or difference of two sets.
*/

#include "set.h"

#include "ariths.h"
#include "bool.h"
#include "cyclotom.h"
#include "error.h"
#include "io.h"
#include "listfunc.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "sysfiles.h"
#include "sysopt.h"    // for SyInitializing


#define RequireMutableSet(funcname, op)                                      \
    RequireArgumentCondition(funcname, op, IS_MUTABLE_OBJ(op) && IsSet(op),  \
                             "must be a mutable proper set")


/****************************************************************************
**
*F  IsSet( <list> ) . . . . . . . . . . . . . . . . . test if a list is a set
**
**  'IsSet' returns 1 if the list <list> is a proper set and 0
**  otherwise.  A proper set is a  list that has no holes,
**  no duplicates, and is sorted.  As a side effect 'IsSet' changes the
**  type of proper sets as appropriate.
**
**  A typical call in the set functions looks like this:
**
**  |    if ( ! IsSet(list) )  list = SetList(list); |
**
**  This tests if 'list' is a proper set and the type  is changed 
**  If it is not  then 'SetList' is  called to make  a copy of 'list', remove
**  the holes, sort the copy, and remove the duplicates.  
** 
*/

BOOL IsSet(Obj list)
{
    BOOL isSet = FALSE;

    /* if <list> is a plain list                                           */
    if ( IS_PLIST( list ) ) {

        /* if <list> is the empty list, it is a set (:-)                     */
        if ( LEN_PLIST(list) == 0 ) {
            RetypeBagSMIfWritable(list, T_PLIST_EMPTY);
            isSet = TRUE;
        }

        /* if <list>  strictly sorted, it is a set            */
        else if ( IS_SSORT_LIST(list) ) {
            isSet = TRUE;
        }

    }

    /* if it is another small list                                         */
    else if ( IS_SMALL_LIST(list) ) {

        /* if <list> is the empty list, it is a set (:-)                     */
        if ( LEN_LIST(list) == 0 ) {
            PLAIN_LIST( list );
            RetypeBagSMIfWritable(list, T_PLIST_EMPTY);
            isSet = TRUE;
        }

        /* if <list> strictly sorted, it is a set            */
        else if (  IS_SSORT_LIST(list) ) {
            PLAIN_LIST( list );
            /* SET_FILT_LIST( list, FN_IS_HOMOG ); */
            SET_FILT_LIST( list, FN_IS_SSORT );
            isSet = TRUE;
        }

    }

    return isSet;
}


/****************************************************************************
**
*F  SetList( <list> ) . . . . . . . . . . . . . . . .  make a set from a list
**
**  'SetList' returns  a new set that contains  the elements of <list>.  Note
**  that 'SetList' returns a new plain list even if <list> was already a set.
**
**  'SetList' makes a copy  of the list  <list>, removes the holes, sorts the
**  copy and finally removes duplicates, which must appear next to each other
**  now that the copy is sorted.
*/
Obj SetList (
    Obj                 list )
{
    Obj                 set;            /* result set                      */
    Int                 lenSet;         /* length of <set>                 */
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of the list         */
    UInt                status;        /* the elements are mutable        */
    UInt                i;              /* loop variable                   */

    /* make a dense copy                                                   */
    lenList = LEN_LIST( list );
    set = NEW_PLIST( T_PLIST, lenList );
    lenSet = 0;
    for ( i = 1; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );
        if ( elm != 0 ) {
            lenSet += 1;
            SET_ELM_PLIST( set, lenSet, elm );
            CHANGED_BAG(set);   /* in case elm had to be made, not just extracted  */
        }
    }
    SET_LEN_PLIST( set, lenSet );
    SET_FILT_LIST( set, FN_IS_DENSE );

    /* sort the set (which is a dense plain list)                          */
    SortDensePlist( set );

    /* remove duplicates                                                   */
    status = RemoveDupsDensePlist( set );

    /* adjust flags where possible                                   */
    switch(status)
      {
      case 0:
        break;
        
      case 1:
        SET_FILT_LIST(set, FN_IS_NHOMOG);
        SET_FILT_LIST(set, FN_IS_SSORT);
        break;
        
      case 2:
        SET_FILT_LIST( set, FN_IS_HOMOG );
        SET_FILT_LIST( set, FN_IS_SSORT );
        break;
      }

    /* return set                                                          */
    return set;
}


/****************************************************************************
**
*F  FuncLIST_SORTED_LIST( <self>, <list> )  . . . . .  make a set from a list
**
**  'FuncLIST_SORTED_LIST' implements the internal function 'SetList'.
**
**  'SetList( <list> )'
**
**  'SetList' returns a new proper set, which is represented as a sorted list
**  without holes or duplicates, containing the elements of the list <list>.
**
**  'SetList' returns a new list even if the list <list> is already a  proper
**  set, in this case it is equivalent to 'ShallowCopy' (see  "ShallowCopy").
*/
static Obj FuncLIST_SORTED_LIST(Obj self, Obj list)
{
    Obj                 set;            /* result                          */

    RequireSmallList("Set", list);

    /* if the list is empty create a new empty list                        */
    if ( LEN_LIST(list) == 0 ) {
        set = NewEmptyPlist();
    }

    /* if <list> is a set just shallow copy it                             */
    else if ( /* IS_HOMOG_LIST(list) && */ IS_SSORT_LIST(list) ) {
        set = SHALLOW_COPY_OBJ( list );
    }

    /* otherwise let 'SetList' do the work                                 */
    else {
        set = SetList( list );
    }

    /* return the set                                                      */
    return set;
}


/****************************************************************************
**
*F  FuncIS_EQUAL_SET(<self>,<l1>,<l2>) test if a two lists are equal as sets
**
**  'FuncIS_EQUAL_SET' implements the internal function 'IsEqualSet'.
**
**  'IsEqualSet( <list1>, <list2> )'
**
**  'IsEqualSet'  returns  'true' if the  two  lists <list1> and  <list2> are
**  equal *when viewed as sets*, and 'false'  otherwise.  <list1> and <list2>
**  are equal if every element of  <list1> is also  an element of <list2> and
**  if every element of <list2> is also an element of <list1>.
*/
static Int EqSet(Obj listL, Obj listR)
{
    Int                 lenL;           /* length of the left operand      */
    Int                 lenR;           /* length of the right operand     */
    Obj                 elmL;           /* element of the left operand     */
    Obj                 elmR;           /* element of the right operand    */
    UInt                i;              /* loop variable                   */

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_PLIST( listL );
    lenR = LEN_PLIST( listR );
    if ( lenL != lenR ) {
        return 0;
    }

    /* loop over the elements and compare them                             */
    for ( i = 1; i <= lenL; i++ ) {
        elmL = ELM_PLIST( listL, i );
        elmR = ELM_PLIST( listR, i );
        if ( ! EQ( elmL, elmR ) ) {
            return 0;
        }
    }

    /* no differences found, the lists are equal                           */
    return 1;
}

static Obj FuncIS_EQUAL_SET(Obj self, Obj list1, Obj list2)
{
    RequireSmallList("IsEqualSet", list1);
    RequireSmallList("IsEqualSet", list2);
    if ( ! IsSet( list1 ) )  list1 = SetList( list1 );
    if ( ! IsSet( list2 ) )  list2 = SetList( list2 );

    /* and now compare them                                                */
    return (EqSet( list1, list2 ) ? True : False );
}


/****************************************************************************
**
*F  FuncIS_SUBSET_SET(<self>,<s1>,<s2>) test if a set is a subset of another
**
**  'FuncIS_SUBSET_SET' implements the internal function 'IsSubsetSet'.
**
**  'IsSubsetSet( <set1>, <set2> )'
**
**  'IsSubsetSet' returns 'true'  if the set  <set2> is a  subset of the  set
**  <set1>, that is if every element of <set2>  is also an element of <set1>.
**  Either  argument may also  be a list that is  not a proper  set, in which
**  case 'IsSubsetSet' silently applies 'Set' (see "Set") to it first.
*/
static Obj FuncIS_SUBSET_SET(Obj self, Obj set1, Obj set2)
{
    UInt                len1;           /* length of  the left  set        */
    UInt                len2;           /* length of  the right set        */
    UInt                i1;             /* index into the left  set        */
    UInt                i2;             /* index into the right set        */
    Obj                 e1;             /* element of left  set            */
    Obj                 e2;             /* element of right set            */
    UInt                pos;            /* position                        */

    RequireSmallList("IsSubsetSet", set1);
    RequireSmallList("IsSubsetSet", set2);
    if ( ! IsSet( set1 ) )  set1 = SetList( set1 );
    if ( ! IsSet( set2 ) )  set2 = SetList( set2 );

    /* special case if the second argument is a set                        */
    if ( IsSet( set2 ) ) {

        /* get the logical lengths and get the pointer                     */
        len1 = LEN_PLIST( set1 );
        len2 = LEN_PLIST( set2 );
        i1 = 1;
        i2 = 1;

        /* now compare the two sets                                        */
        while ( i1 <= len1 && i2 <= len2 && len2 - i2 <= len1 - i1 ) {
            e1 = ELM_PLIST( set1, i1 );
            e2 = ELM_PLIST( set2, i2 );
            if ( EQ( e1, e2 ) ) {
                i1++;  i2++;
            }
            else if ( LT( e1, e2 ) ) {
                i1++;
            }
            else {
                break;
            }
        }

    }

    /* general case                                                        */
    else {

        /* first convert the other argument into a proper list             */
        PLAIN_LIST( set2 );

        /* get the logical lengths                                         */
        len1 = LEN_PLIST( set1 );
        len2 = LEN_PLIST( set2 );

        /* loop over the second list and look for every element            */
        for ( i2 = 1; i2 <= len2; i2++ ) {

            /* ignore holes                                                */
            if ( ELM_PLIST(set2,i2) == 0 )
                continue;

            /* perform the binary search to find the position              */
            pos = PositionSortedDensePlist( set1, ELM_PLIST(set2,i2) );

            /* test if the element was found at position k                 */
            if ( len1<pos || ! EQ(ELM_PLIST(set1,pos),ELM_PLIST(set2,i2)) ) {
                break;
            }

        }

    }

    /* return 'true' if every element of <set2> appeared in <set1>         */
    return ((i2 == len2 + 1) ? True : False);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncADD_SET( <self>, <set>, <obj> ) . . . . . . . add an element to a set
**
**  'FuncADD_SET' implements the internal function 'AddSet'.
**
**  'AddSet( <set>, <obj> )'
**
**  'AddSet' adds <obj>, which may be an object  of an arbitrary type, to the
**  set <set>, which must be a proper set.  If <obj> is already an element of
**  the set <set>, then <set> is not changed.  Otherwise <obj> is inserted at
**  the correct position such that <set> is again a set afterwards.
**
**  'AddSet' does not return  anything, it is only  called for the side effect
**  of changing <set>.
*/
static Obj FuncADD_SET(Obj self, Obj set, Obj obj)
{
  UInt                len;            /* logical length of the list      */
  UInt                pos;            /* position                        */
  BOOL                isCyc;          /* True if the set being added to consists
                                         of kernel cyclotomics           */
  UInt                notpos;         /* position of an original element
                                         (not the new one)               */
  UInt                wasHom;
  UInt                wasNHom;
  UInt                wasTab;
    
  RequireMutableSet("AddSet", set);
  len = LEN_PLIST(set);

  /* perform the binary search to find the position                      */
  pos = PositionSortedDensePlist( set, obj );

  /* add the element to the set if it is not already there               */
  if ( len < pos || ! EQ( ELM_PLIST(set,pos), obj ) ) {
    GROW_PLIST( set, len+1 );
    SET_LEN_PLIST( set, len+1 );
    Obj * ptr = ADDR_OBJ(set) + pos;
    SyMemmove(ptr + 1, ptr, sizeof(Obj) * (len - pos + 1));
    SET_ELM_PLIST( set, pos, obj );
    CHANGED_BAG( set );

    /* fix up the type of the result                                   */
    if ( HAS_FILT_LIST( set, FN_IS_SSORT ) ) {
      isCyc = (TNUM_OBJ(set) == T_PLIST_CYC_SSORT);
      wasHom = HAS_FILT_LIST(set, FN_IS_HOMOG);
      wasTab = HAS_FILT_LIST(set, FN_IS_TABLE);
      wasNHom = HAS_FILT_LIST(set, FN_IS_NHOMOG);
      CLEAR_FILTS_LIST(set);
      /* the result of addset is always dense */
      SET_FILT_LIST( set, FN_IS_DENSE );

                                /* if the object we added was not
                                   mutable then we might be able to
                                   conclude more */
      if ( ! IS_MUTABLE_OBJ(obj) ) {
                                /* a one element list is automatically
                                   homogenous  and ssorted */
        if (len == 0 )
          {
            if (IS_CYC(obj))
              RetypeBagIfWritable( set, T_PLIST_CYC_SSORT);
            else
              {
                SET_FILT_LIST( set, FN_IS_HOMOG );
                SET_FILT_LIST( set, FN_IS_SSORT );
                if (IS_HOMOG_LIST(obj)) /* it might be a table */
                  SET_FILT_LIST( set, FN_IS_TABLE );
              }
          }
        else
          {
            /* Now determine homogeneity */
            if (isCyc)
              if (IS_CYC(obj))
                RetypeBagIfWritable( set, T_PLIST_CYC_SSORT);
              else
                {
                  RESET_FILT_LIST(set, FN_IS_HOMOG);
                  SET_FILT_LIST(set, FN_IS_NHOMOG);
                }
            else if (wasHom)
              {
                if (!SyInitializing) {
                  notpos = (pos == 1) ? 2 : 1;
                  if (FAMILY_OBJ(ELM_PLIST(set,notpos)) == FAMILY_OBJ(obj))
                    {
                      SET_FILT_LIST(set, FN_IS_HOMOG);
                      if (wasTab) {
                        if (IS_HOMOG_LIST( obj ))
                          SET_FILT_LIST(set, FN_IS_TABLE);
                      }
                    }

                  else
                    SET_FILT_LIST(set, FN_IS_NHOMOG);
                }
              }
            else if (wasNHom)
              SET_FILT_LIST(set, FN_IS_NHOMOG);
          }
      }
      SET_FILT_LIST( set, FN_IS_SSORT );
    }
    else {
      CLEAR_FILTS_LIST(set);
      SET_FILT_LIST( set, FN_IS_DENSE );
    }
  }

  return 0;
}


/****************************************************************************
**
*F  FuncREM_SET( <self>, <set>, <obj> ) . . . .  remove an element from a set
**
**  'FuncREM_SET' implements the internal function 'RemoveSet'.
**
**  'RemoveSet( <set>, <obj> )'
**
**  'RemoveSet' removes <obj>, which may be an object of arbitrary type, from
**  the set <set>, which must be a  proper set.  If  <obj> is in  <set> it is
**  removed and all  entries of <set>  are shifted one position leftwards, so
**  that <set> has no  holes.  If <obj>  is not in  <set>, then <set>  is not
**  changed.  No error is signalled in this case.
**
**  'RemoveSet'   does   not return anything,  it   is  only called  for  the
**  side effect of changing <set>.
*/
static Obj FuncREM_SET(Obj self, Obj set, Obj obj)
{
    UInt                len;            /* logical length of the list      */
    UInt                pos;            /* position                        */

    RequireMutableSet("RemoveSet", set);
    len = LEN_PLIST(set);

    /* perform the binary search to find the position                      */
    pos = PositionSortedDensePlist( set, obj );

    /* remove the element from the set if it is there                      */
    if ( pos <= len && EQ( ELM_PLIST(set,pos), obj ) ) {

        Obj * ptr = ADDR_OBJ(set) + pos;
        SyMemmove(ptr, ptr + 1, sizeof(Obj) * (len - pos));
        SET_ELM_PLIST( set, len, 0 );
        SET_LEN_PLIST( set, len-1 );

        /* fix up the type of the result                                   */
        if ( len-1 == 0 ) {
            RetypeBag(set, T_PLIST_EMPTY);
        }
    }

    return 0;
}


/****************************************************************************
**
*F  FuncUNITE_SET( <self>, <set1>, <set2> ) . . .  unite one set with another
**
**  'FuncUNITE_SET' implements the internal function 'UniteSet'.
**
**  'UniteSet( <set1>, <set2> )'
**
**  'UniteSet' changes the set <set1> so that it becomes the  union of <set1>
**  and <set2>.  The union is the set of those elements  that are elements of
**  either set.  So 'UniteSet'  adds (see  "AddSet")  all elements to  <set1>
**  that are in <set2>.  <set2> may be a list that  is  not  a proper set, in
**  which case 'Set' is silently applied to it.
**
**  'FuncUNITE_SET' merges <set1> and <set2> into a  buffer that is allocated
**  at initialization time.
**
*/

static Obj FuncUNITE_SET(Obj self, Obj set1, Obj set2)
{
    UInt                lenr;           /* length  of result set           */
    UInt                len1;           /* length  of left  set            */
    UInt                len2;           /* length  of right set            */
    UInt                i1;             /* index into left  set            */
    UInt                i2;             /* index into right set            */
    Obj                 e1;             /* element of left  set            */
    Obj                 e2;             /* element of right set            */
    Obj                 TmpUnion;

    RequireMutableSet("UniteSet", set1);
    RequireSmallList("UniteSet", set2);
    if ( ! IsSet(set2) )  set2 = SetList(set2);

    /* get the logical lengths and the pointer                             */
    len1 = LEN_PLIST( set1 );
    len2 = LEN_PLIST( set2 );
    TmpUnion = NEW_PLIST(T_PLIST,len1+len2);
    lenr = 0;
    i1 = 1;
    i2 = 1;

    /* now merge the two sets into the union                               */
    while ( i1 <= len1 && i2 <= len2 ) {
        e1 = ELM_PLIST( set1, i1 );
        e2 = ELM_PLIST( set2, i2 );
        if ( EQ( e1, e2 ) ) {
            lenr++;
            SET_ELM_PLIST( TmpUnion, lenr, e1 );
            CHANGED_BAG( TmpUnion );
            i1++;  i2++;
        }
        else if ( LT( e1, e2 ) ) {
            lenr++;
            SET_ELM_PLIST( TmpUnion, lenr, e1 );
            CHANGED_BAG( TmpUnion );
            i1++;
        }
        else {
            lenr++;
            SET_ELM_PLIST( TmpUnion, lenr, e2 );
            CHANGED_BAG( TmpUnion );
            i2++;
        }
    }
    while ( i1 <= len1 ) {
        e1 = ELM_PLIST( set1, i1 );
        lenr++;
        SET_ELM_PLIST( TmpUnion, lenr, e1 );
        CHANGED_BAG( TmpUnion );
        i1++;
    }
    while ( i2 <= len2 ) {
        e2 = ELM_PLIST( set2, i2 );
        lenr++;
        SET_ELM_PLIST( TmpUnion, lenr, e2 );
        CHANGED_BAG( TmpUnion );
        i2++;
    }

    /* fix up the type of the result                                       */
    if ( 0 == LEN_PLIST(set1) ) {
        RetypeBag( set1, MUTABLE_TNUM(TNUM_OBJ(set2)) );
    } else if ( 0 != LEN_PLIST(set2)) {
      if (HAS_FILT_LIST(set1, FN_IS_HOMOG)) {
        if( !HAS_FILT_LIST(set2, FN_IS_HOMOG))
          RESET_FILT_LIST(set1, FN_IS_HOMOG);
        else if (!SyInitializing &&
                 FAMILY_OBJ(ELM_PLIST(set1,1)) != FAMILY_OBJ(ELM_PLIST(set2,1)))
          {
            RetypeBag(set1, T_PLIST_DENSE_NHOM);
          }
      }
    }

    SET_FILT_LIST(set1, FN_IS_SSORT);

    /* resize the result and copy back from the union                      */
    GROW_PLIST(    set1, lenr );
    SET_LEN_PLIST( set1, lenr );
    for ( i1 = 1;  i1 <= lenr;  i1++ ) {
        SET_ELM_PLIST( set1, i1, ELM_PLIST( TmpUnion, i1 ) );
        CHANGED_BAG( set1 );
        SET_ELM_PLIST( TmpUnion, i1, (Obj)0 );
    }

    return 0;
}


/****************************************************************************
**
*F  FuncINTER_SET( <self>, <set1>, <set2> ) .  intersect one set with another
**
**  'FuncINTER_SET' implements the internal function 'IntersectSet'.
**
**  'IntersectSet( <set1>, <set2> )'
**
**  'IntersectSet' changes the set <set1> so that it becomes the intersection
**  of <set1> and <set2>.  The intersection is the set of those elements that
**  are  elements in both sets.   So 'IntersectSet' removes (see "RemoveSet")
**  all elements from <set1> that are not  in  <set2>.  <set2> may be a  list
**  that is not a proper set, in which case 'Set' is silently applied to it.
*/

static UInt InterSetInner1( Obj set1, Obj set2, UInt len1, UInt len2) 
{
  UInt lenr, i1,i2;
  Obj e1,e2;
  lenr = 0;
  i1 = 1;
  i2 = 1;

  /* now merge the two sets into the intersection                        */
  while ( i1 <= len1 && i2 <= len2 ) {
    e1 = ELM_PLIST( set1, i1 );
    e2 = ELM_PLIST( set2, i2 );
    if ( EQ( e1, e2 ) ) {
      lenr++;
      SET_ELM_PLIST( set1, lenr, e1 );
      i1++;  i2++;
    }
    else if ( LT( e1, e2 ) ) {
      i1++;
    }
    else {
      i2++;
    }
  }
  return lenr;
}

/* set1 should be the smaller set. setr should be the one
   in which to put the results; */
static UInt InterSetInner2( Obj set1, Obj set2, Obj setr, UInt len1, UInt len2) 
{
  UInt i1,i2=1,bottom,top,middle,lenr=0,found;
  Obj e1,e2;
  for( i1 = 1; i1 <= len1; i1++)
    {
      e1 = ELM_PLIST( set1, i1 );
      bottom = i2;
      top = len2;
      found = 0;
      while (bottom <= top)
        {
          middle = (bottom + top)/2;
          e2 = ELM_PLIST(set2,middle);
          if (LT(e1,e2))
            top = middle-1;
          else if (EQ(e1,e2)) {
            lenr++;
            SET_ELM_PLIST(setr,lenr,e1);
            i2 = middle+1;
            found = 1;
            break;
          }
          else
            bottom = middle+1;
        }
      if (!found)
        i2 = bottom;
    }
  return lenr;
}


static Obj FuncINTER_SET(Obj self, Obj set1, Obj set2)
{
    UInt                len1;           /* length  of left  set            */
    UInt                len2;           /* length  of right set            */
    UInt                lenr;           /* length  of result set           */

    RequireMutableSet("IntersectSet", set1);
    RequireSmallList("IntersectSet", set2);
    if ( ! IsSet(set2) )  set2 = SetList(set2);

    /* get the logical lengths and the pointer                             */
    len1 = LEN_PLIST( set1 );
    len2 = LEN_PLIST( set2 );

    /* decide how to do the calculation and do it */
    if (len1 < len2) 
      {
        UInt x = len2;
        UInt ll = 0;
        while (x > 0)
          {
            ll++;
            x >>= 1;
          }
        if (len1*ll < len2)
          lenr = InterSetInner2(set1,set2,set1,len1,len2);
        else
          lenr = InterSetInner1(set1,set2,len1,len2);
      }
    else
      {
        UInt x = len1;
        UInt ll = 0;
        while (x > 0)
          {
            ll++;
            x >>= 1;
          }
        if (len2*ll < len1)
          lenr = InterSetInner2(set2,set1,set1,len2,len1);
        else
          lenr = InterSetInner1(set1,set2,len1,len2);
      }

    /* resize the result or clear the rest of the bag                      */
    SET_LEN_PLIST( set1, lenr );
    SHRINK_PLIST(  set1, lenr );

    /* fix up the type of the result                                       */
    if ( lenr == 0 ) {
        RetypeBag(set1, T_PLIST_EMPTY);
    }
    else if ( lenr == 1) {
      if (IS_CYC(ELM_PLIST(set1,1)))
        RetypeBag(set1, T_PLIST_CYC_SSORT);
      else
        RetypeBag(set1, T_PLIST_HOM_SSORT);
    }
    else
      {
        if ( TNUM_OBJ(set2) >= T_PLIST_CYC )
          RetypeBag(set1, MUTABLE_TNUM( TNUM_OBJ(set2)));
        else
          {
            RESET_FILT_LIST(set1, FN_IS_NHOMOG);
            if ( HAS_FILT_LIST( set2, FN_IS_HOMOG )) {
              SET_FILT_LIST(set1, FN_IS_HOMOG );
              SET_FILT_LIST(set1, FN_IS_SSORT );
            }
          }
      }

    return 0;
}


/****************************************************************************
**
*F  FuncSUBTR_SET( <self>, <set1>, <set2> ) . . subtract one set from another
**
**  'FuncSUBTR_SET' implements the internal function 'SubstractSet'.
**
**  'SubstractSet( <set1>, <set2> )'
**
**  'SubstractSet' changes the  set <set1> so  that it becomes the difference
**  of <set1> and <set2>.  The difference is the set of the elements that are
**  in <set1> but not in <set2>.  So 'SubtractSet' removes  (see "RemoveSet")
**  all elements from <set1> that are in <set2>.   <set2> may  be a list that
**  is not a proper set, in which case 'Set' is silently applied to it.
*/

static UInt SubtrSetInner1( Obj set1, Obj set2, UInt len1, UInt len2) 
{
  UInt lenr, i1,i2;
  Obj e1,e2;
  lenr = 0;
  i1 = 1;
  i2 = 1;

  /* now run through the two sets to find the difference  */
  while ( i1 <= len1 && i2 <= len2 ) {
    e1 = ELM_PLIST( set1, i1 );
    e2 = ELM_PLIST( set2, i2 );
    if ( EQ( e1, e2 ) ) {
      i1++;  i2++;
    }
    else if ( LT( e1, e2 ) ) {
      lenr++;
      SET_ELM_PLIST( set1, lenr, e1 );
      i1++;
    }
    else {
      i2++;
    }
  }
  while (i1 <= len1)
    {
      e1 = ELM_PLIST( set1, i1 );
      lenr++;
      SET_ELM_PLIST( set1, lenr, e1 );
      i1++;
    }
  return lenr;
}

/* set1 should be smaller. */
static UInt SubtrSetInner2( Obj set1, Obj set2, UInt len1, UInt len2) 
{
  UInt i1,i2=1,bottom,top,middle,lenr=0, found;
  Obj e1,e2;
  for( i1 = 1; i1 <= len1; i1++)
    {
      e1 = ELM_PLIST( set1, i1 );
      bottom = i2;
      top = len2;
      found = 0;
      while (bottom <= top)
        {
          middle = (bottom + top)/2;
          e2 = ELM_PLIST(set2,middle);
          if (LT(e1,e2))
            top = middle-1;
          else if (EQ(e1,e2)) {
            found = 1;
            i2 = middle+1;
            break;
          }
          else
            bottom = middle+1;
        }
      if (!found)
        {
          lenr++;
          SET_ELM_PLIST(set1,lenr,e1);
          i2 = bottom;
        }
    }
  return lenr;
}

static Obj FuncSUBTR_SET(Obj self, Obj set1, Obj set2)
{
    UInt                len1;           /* length  of left  set            */
    UInt                len2;           /* length  of right set            */
    UInt                lenr;           /* length  of result set           */
    UInt                x;            
    UInt                ll;           

    RequireMutableSet("SubtractSet", set1);
    RequireSmallList("SubtractSet", set2);
    if ( ! IsSet(set2) )  set2 = SetList(set2);

    /* get the logical lengths and the pointer                             */
    len1 = LEN_PLIST( set1 );
    len2 = LEN_PLIST( set2 );
    /* decide how to do the calculation and do it */
    x = len2;
    ll = 0;
    while (x > 0)
      {
        ll++;
        x >>= 1;
      }
    if (len1*ll < len2)
      lenr = SubtrSetInner2(set1,set2,len1,len2);
    else
      lenr = SubtrSetInner1(set1,set2,len1,len2);

    /* resize the result or clear the rest of the bag                      */
    SET_LEN_PLIST( set1, lenr );
    SHRINK_PLIST(  set1, lenr );

    /* fix up the type of the result                                       */
    if ( lenr == 0 ) {
        RetypeBag(set1, T_PLIST_EMPTY);
    }
    else if ( lenr == 1) {
      if (IS_CYC(ELM_PLIST(set1,1)))
        RetypeBag(set1, T_PLIST_CYC_SSORT);
      else
        RetypeBag(set1, T_PLIST_HOM_SSORT);
    }
    else
      RESET_FILT_LIST(set1, FN_IS_NHOMOG);

    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(LIST_SORTED_LIST, list),
    GVAR_FUNC_2ARGS(IS_EQUAL_SET, list1, list2),
    GVAR_FUNC_2ARGS(IS_SUBSET_SET, set1, set2),
    GVAR_FUNC_2ARGS(ADD_SET, set, val),
    GVAR_FUNC_2ARGS(REM_SET, set, val),
    GVAR_FUNC_2ARGS(UNITE_SET, set1, set2),
    GVAR_FUNC_2ARGS(INTER_SET, set1, set2),
    GVAR_FUNC_2ARGS(SUBTR_SET, set1, set2),
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
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitInfoSet() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "set",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoSet ( void )
{
    return &module;
}
