/****************************************************************************
**
*W  listfunc.h                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions for generic lists.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char *          Revision_listfunc_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F  AddList(<list>,<obj>) . . . . . . . .  add an object to the end of a list
**
**  'AddList' adds the object <obj> to the end  of  the  list  <list>,  i.e.,
**  it is equivalent to the assignment '<list>[ Length(<list>)+1 ] := <obj>'.
**  The  list is  automatically extended to   make room for  the new element.
**  'AddList' returns nothing, it is called only for its sideeffect.
*/
extern  void            AddList (
            Obj                 list,
            Obj                 obj );

extern  void            AddPlist (
            Obj                 list,
            Obj                 obj );


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
extern  UInt            PositionSortedList (
            Obj                 list,
            Obj                 obj );

extern  UInt            PositionSortedDensePlist (
            Obj                 list,
            Obj                 obj );


/****************************************************************************
**
*F  SortList(<list>)  . . . . . . . . . . . . . . . . . . . . . . sort a list
*F  SortDensePlist(<list>)  . . . . . . . . . . . . . . . . . . . sort a list
**
**  'SortList' sorts the list <list> in increasing  order.
*/
extern  void            SortList (
            Obj                 list );

extern  void            SortDensePlist (
            Obj                 list );


/****************************************************************************
**
*F  RemoveDupsDensePlist(<list>)  . . . . remove duplicates from a plain list
**
**  'RemoveDupsDensePlist' removes  duplicate elements from  the dense  plain
**  list <list>.  <list> must be sorted.  'RemoveDupsDensePlist' returns 1 if
**  <list> contains mutable elements, and 0 otherwise.
*/
extern  UInt            RemoveDupsDensePlist (
            Obj                 list );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupListFunc() . . . . . . . . .  initialize the lists functions package
*/
extern void SetupListFunc ( void );


/****************************************************************************
**
*F  InitListFunc()  . . . . . . . . .  initialize the lists functions package
**
**  'InitListFunc' initializes the lists functions package.
*/
extern void InitListFunc ( void );


/****************************************************************************
**
*F  CheckListFunc() . check the initialisation of the lists functions package
*/
extern void CheckListFunc ( void );


/****************************************************************************
**

*E  listfunc.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/

