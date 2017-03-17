/****************************************************************************
**
*W  listfunc.h                  GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions for generic lists.
*/

#ifndef GAP_LISTFUNC_H
#define GAP_LISTFUNC_H


/****************************************************************************
**

*F  AddList(<list>,<obj>) . . . . . . . .  add an object to the end of a list
**
**  'AddList' adds the object <obj> to the end  of  the  list  <list>,  i.e.,
**  it is equivalent to the assignment '<list>[ Length(<list>)+1 ] := <obj>'.
**  The  list is  automatically extended to   make room for  the new element.
**  'AddList' returns nothing, it is called only for its side effect.
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
*F  SORT_LIST(<list>) . . . . . . . . . . . . . . . . . . . . . . sort a list
*F  SortDensePlist(<list>)  . . . . . . . . . . . . . . . . . . . sort a list
*F  SORT_LISTComp(<list>,<func>)  . . . . . . . . . . . . . . . . sort a list
*F  SortDensePlistComp(<list>,<func>) . . . . . . . . . . . . . . sort a list
**
*F  SORT_PARA_LIST(<list>,<shadow>) . . . . . . . . . sort a list with shadow
*F  SortParaDensePlistPara(<list>,<shadow>) . . . . . sort a list with shadow
*F  SORT_PARA_LISTComp(<list>,<shadow>,<func>)  . . . sort a list with shadow
*F  SortParaDensePlistComp(<list>,<shadow>,<func>)  . sort a list with shadow
**
**  'SortList' sorts the list <list> in increasing  order.
*/
extern  void SORT_LIST (
        Obj  list );

extern  void SortDensePlist (
        Obj  list );

extern  void SORT_LISTComp (
        Obj  list,
        Obj  func );

extern  void SortDensePlistComp (
        Obj  list,
        Obj  func );

extern  void SORT_PARA_LIST (
        Obj  list,
        Obj  shadow );

extern  void SortParaDensePlist (
        Obj  list,
        Obj  shadow );

extern  void SORT_PARA_LISTComp (
        Obj  list,
        Obj  shadow,
        Obj  func );

extern  void SortParaDensePlistComp (
        Obj  list,
        Obj  shadow,
        Obj  func );

/****************************************************************************
**
*F  RemoveDupsDensePlist(<list>)  . . . . remove duplicates from a plain list
**
**  'RemoveDupsDensePlist' removes duplicate elements from the dense
**  plain list <list>.  <list> must be sorted.  'RemoveDupsDensePlist'
**  returns 0 if <list> contains mutable elements, 1 if immutable but
**  not homogenout, 2 otherwise
*/
extern  UInt            RemoveDupsDensePlist (
            Obj                 list );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoListFunc()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoListFunc ( void );


#endif // GAP_LISTFUNC_H

/****************************************************************************
**

*E  listfunc.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
