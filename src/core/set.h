/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declaress the functions which mainly deal with proper sets.
**
**  A *proper set* is a list that has no holes, no duplicates, and is sorted.
**  For the full definition  of sets see chapter "Sets" in the {\GAP} Manual.
**  Read also section "More about Sets" about the internal flag for sets.
*/

#ifndef GAP_SET_H
#define GAP_SET_H

#include "system.h"

/****************************************************************************
**
*F  SetList(<list>) . . . . . . . . . . . . . . . . .  make a set from a list
**
**  'SetList' returns  a new set that contains  the elements of <list>.  Note
**  that 'SetList' returns a  new list even if <list>  was already a set.  In
**  this case 'SetList' is equal to 'ShallowCopy'.
**
**  'SetList' makes a copy  of the list  <list>, removes the holes, sorts the
**  copy and finally removes duplicates, which must appear next to each other
**  now that the copy is sorted.
*/
Obj SetList(Obj list);


/****************************************************************************
**
*F  IsSet(<list>) . . . . . . . . . . . . . . . . . . test if a list is a set
**
**  'IsSet' returns 1 if the list <list> is a proper set  and 0 otherwise.  A
**  proper set is a list that has no holes, no duplicates, and is sorted.  As
**  a side effect 'IsSet' may changes the type of proper sets.
**
**  A typical call in the set functions looks like this:                   \\
**  |    if ( ! IsSet(list) )  list = SetList(list); |                     \\
**  This tests if 'list' is a proper set.  If it is, then the type is changed
**  to reflect this. If it is not then 'SetList' is called to make a copy of
**  'list', remove the holes, sort the copy, and remove the duplicates.
*/
Int IsSet(Obj list);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoSet() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoSet ( void );


#endif // GAP_SET_H
