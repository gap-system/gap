/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions that deal with ranges.
**
**  A *range* is  a list without  holes  consisting  of consecutive integers.
**  For the full definition of ranges see chapter "Ranges" in the GAP Manual.
**  Read  also   "More about Ranges"  about  the different  representation of
**  ranges.
**
**  Ranges can be accessed through the functions 'NEW_RANGE', 'IS_RANGE',
**  'SET_LEN_RANGE', 'GET_LEN_RANGE', 'SET_LOW_RANGE', 'GET_LOW_RANGE',
**  'SET_INC_RANGE', 'GET_INC_RANGE', and 'GET_ELM_RANGE'.
**
**  This package  also contains  the  list  functions  for ranges, which  are
**  installed in the appropriate tables by 'InitRange'.
*/

#ifndef GAP_RANGE_H
#define GAP_RANGE_H

#include "objects.h"

/****************************************************************************
**
*F  NEW_RANGE() . . . . . . . . . . . . . . . . . . . . . .  make a new range
**
**  'NEW_RANGE' returns a new range.
*/
Obj NEW_RANGE(Int len, Int low, Int inc);


/****************************************************************************
**
*F  IS_RANGE(<val>) . . . . . . . . . . . . . . .  test if a value is a range
**
**  'IS_RANGE' returns 1  if the value  <val> is known  to be a range,  and 0
**  otherwise.  Note that a list for which 'IS_RANGE' returns  0 may still be
**  a range, but  the kernel does not know  this yet.  Use  'IsRange' to test
**  whether a list is a range.
*/
EXPORT_INLINE BOOL IS_RANGE(Obj val)
{
    return TNUM_OBJ(val) >= T_RANGE_NSORT &&
           TNUM_OBJ(val) <= T_RANGE_SSORT + IMMUTABLE;
}


/****************************************************************************
**
*F  SET_LEN_RANGE(<list>,<len>) . . . . . . . . . . set the length of a range
**
**  'SET_LEN_RANGE' sets the length  of the range <list>  to the value <len>,
**  which must be a C integer larger than 1.
*/
EXPORT_INLINE void SET_LEN_RANGE(Obj list, Int len)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[0] = INTOBJ_INT(len);
}


/****************************************************************************
**
*F  GET_LEN_RANGE(<list>) . . . . . . . . . . . . . . . . . length of a range
**
**  'GET_LEN_RANGE' returns the  logical length of  the range <list>, as  a C
**  integer.
*/
EXPORT_INLINE Int GET_LEN_RANGE(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[0]);
}


/****************************************************************************
**
*F  SET_LOW_RANGE(<list>,<low>) . . . . . .  set the first element of a range
**
**  'SET_LOW_RANGE' sets the  first element of the range  <list> to the value
**  <low>, which must be a C integer.
*/
EXPORT_INLINE void SET_LOW_RANGE(Obj list, Int low)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[1] = INTOBJ_INT(low);
}


/****************************************************************************
**
*F  GET_LOW_RANGE(<list>) . . . . . . . . . . . . .  first element of a range
**
**  'GET_LOW_RANGE' returns the first  element  of the  range  <list> as a  C
**  integer.
*/
EXPORT_INLINE Int GET_LOW_RANGE(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[1]);
}


/****************************************************************************
**
*F  SET_INC_RANGE(<list>,<inc>) . . . . . . . .  set the increment of a range
**
**  'SET_INC_RANGE' sets  the  increment of  the range  <list>   to the value
**  <inc>, which must be a C integer.
*/
EXPORT_INLINE void SET_INC_RANGE(Obj list, Int inc)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[2] = INTOBJ_INT(inc);
}


/****************************************************************************
**
*F  GET_INC_RANGE(<list>) . . . . . . . . . . . . . . .  increment of a range
**
**  'GET_INC_RANGE' returns the increment of the range <list> as a C integer.
*/
EXPORT_INLINE Int GET_INC_RANGE(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[2]);
}


/****************************************************************************
**
*F  GET_ELM_RANGE(<list>,<pos>) . . . . . . . . . . . . .  element of a range
**
**  'GET_ELM_RANGE' return  the <pos>-th element  of the range <list>.  <pos>
**  must be a positive integer less than or equal to the length of <list>.
*/
EXPORT_INLINE Obj GET_ELM_RANGE(Obj list, Int pos)
{
    Int val;
    GAP_ASSERT(IS_RANGE(list));
    val = GET_LOW_RANGE(list) + ((pos)-1) * GET_INC_RANGE(list);
    GAP_ASSERT(pos >= 1 && pos <= GET_LEN_RANGE(list));
    return INTOBJ_INT(val);
}

/****************************************************************************
**
*F  PosRange(<list>,<val>,<start>)  . . . . position of an element in a range
**
**  'PosRange' returns the position  of the value <val>  in the range  <list>
**  after the first position <start> as a GAP integer. Fail is returned if <val>
**  is not in the list.
**
**  'PosRange' is the function in 'PosListFuncs' for ranges.
*/
Obj PosRange(Obj list, Obj val, Obj start);


/****************************************************************************
**
*F  Range2Check( <first>, <last> )  . . . . . . . . . . . . . construct range
*/
Obj Range2Check(Obj first, Obj last);


/****************************************************************************
**
*F  Range3Check( <first>, <second>, <last> )  . . . . . . . . construct range
*/
Obj Range3Check(Obj first, Obj second, Obj last);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoRange() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoRange ( void );


#endif // GAP_RANGE_H
