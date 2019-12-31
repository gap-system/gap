/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions for generic lists.
*/

#ifndef GAP_LISTFUNC_H
#define GAP_LISTFUNC_H

#include "common.h"

/****************************************************************************
**
*F  AddList(<list>,<obj>) . . . . . . . .  add an object to the end of a list
**
**  'AddList' adds the object <obj> to the end  of  the  list  <list>,  i.e.,
**  it is equivalent to the assignment '<list>[ Length(<list>)+1 ] := <obj>'.
**  The  list is  automatically extended to   make room for  the new element.
**  'AddList' returns nothing, it is called only for its side effect.
*/
void AddList(Obj list, Obj obj);

void AddPlist(Obj list, Obj obj);


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
UInt PositionSortedList(Obj list, Obj obj);

UInt PositionSortedDensePlist(Obj list, Obj obj);


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
*F  SortPlistByRawObj(<list>) . . . . . . . .  sort a list by raw obj pointer
**  'SortList' sorts the list <list> in increasing  order.
*/
void SORT_LIST(Obj list);

void SortDensePlist(Obj list);

void SORT_LISTComp(Obj list, Obj func);

void SortDensePlistComp(Obj list, Obj func);

void SORT_PARA_LIST(Obj list, Obj shadow);

void SortParaDensePlist(Obj list, Obj shadow);

void SORT_PARA_LISTComp(Obj list, Obj shadow, Obj func);

void SortParaDensePlistComp(Obj list, Obj shadow, Obj func);

void SortPlistByRawObj(Obj list);

/****************************************************************************
**
*F  RemoveDupsDensePlist(<list>)  . . . . remove duplicates from a plain list
**
**  'RemoveDupsDensePlist' removes duplicate elements from the dense
**  plain list <list>.  <list> must be sorted.  'RemoveDupsDensePlist'
**  returns 0 if <list> contains mutable elements, 1 if immutable but
**  not homogeneous, 2 otherwise
*/
UInt RemoveDupsDensePlist(Obj list);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoListFunc()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoListFunc ( void );


#endif // GAP_LISTFUNC_H
