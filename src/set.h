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

#include "common.h"


/****************************************************************************
**
*F  SetList(<list>) . . . . . . . . . . . . . . . . .  make a set from a list
**
**  'SetList' returns  a new set that contains  the elements of <list>.  Note
**  that 'SetList' returns a new plain list even if <list> was already a set.
**  In this case 'SetList' is equal to 'ShallowCopy'.
**
**  'SetList' makes a copy  of the list  <list>, removes the holes, sorts the
**  copy and finally removes duplicates, which must appear next to each other
**  now that the copy is sorted.
*/
Obj SetList(Obj list);


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
