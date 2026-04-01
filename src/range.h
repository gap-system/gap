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

#include "error.h"
#include "objects.h"

/****************************************************************************
**
*F  NEW_RANGE() . . . . . . . . . . . . . . . . . . . . . .  make a new range
**
**  'NEW_RANGE' returns a new range.  The length, low and increment must all
**  fit in a SmallInt.
*/
Obj NEW_RANGE(Int len, Int low, Int inc);

/****************************************************************************
**
*F  NEW_RANGE_BIGINT() . . . . . . . . . . . . . . . make a new range (bigint)
**
**  'NEW_RANGE_BIGINT' returns a new range.  The length, low and increment
**  can be arbitrary GAP integers (either immediate integers or large integers).
*/
Obj NEW_RANGE_BIGINT(Obj len, Obj low, Obj inc);


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
*F  IS_RANGE_SMALL(<list>) . . . . . test if a range uses only small integers
**
**  'IS_RANGE_SMALL' returns 1 if the range <list> has length, low and
**  increment all stored as immediate integers (SmallInts), and 0 otherwise.
**
**  WARNING: This does NOT guarantee that all elements of the range fit in
**  SmallInts. Use IS_RANGE_ALL_SMALL for that check.
*/
EXPORT_INLINE BOOL IS_RANGE_SMALL(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    return IS_INTOBJ(CONST_ADDR_OBJ(list)[0]) &&
           IS_INTOBJ(CONST_ADDR_OBJ(list)[1]) &&
           IS_INTOBJ(CONST_ADDR_OBJ(list)[2]);
}


/****************************************************************************
**
*F  IS_RANGE_ALL_SMALL(<list>)  . . test if all elements fit in small integers
**
**  'IS_RANGE_ALL_SMALL' returns 1 if the range <list> has all its elements
**  representable as immediate integers (SmallInts). This includes checking
**  that the last element (low + (len-1) * inc) fits in a SmallInt.
**
**  This function is declared in range.h but implemented in range.c because
**  it needs access to GAP integer arithmetic functions.
*/
BOOL IS_RANGE_ALL_SMALL(Obj list);


/****************************************************************************
**
*F  SET_LEN_RANGE(<list>,<len>) . . . . . . . . . . set the length of a range
**
**  'SET_LEN_RANGE' sets the length  of the range <list>  to the value <len>,
**  which must be a C integer larger than 1 that fits in a SmallInt.
*/
EXPORT_INLINE void SET_LEN_RANGE(Obj list, Int len)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[0] = INTOBJ_INT(len);
}

/****************************************************************************
**
*F  SET_LEN_RANGE_OBJ(<list>,<len>) . . . . . . . . set the length of a range
**
**  'SET_LEN_RANGE_OBJ' sets the length of the range <list> to the value
**  <len>, which must be a GAP integer (immediate or large).
*/
EXPORT_INLINE void SET_LEN_RANGE_OBJ(Obj list, Obj len)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[0] = len;
}


/****************************************************************************
**
*F  GET_LEN_RANGE(<list>) . . . . . . . . . . . . . . . . . length of a range
**
**  'GET_LEN_RANGE' returns the  logical length of  the range <list>, as  a C
**  integer.  This function only works for 'small ranges' where all elements
**  fit in SmallInts.  Use GET_LEN_RANGE_BIGINT for arbitrary ranges.
*/
EXPORT_INLINE Int GET_LEN_RANGE(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    RequireArgumentConditionEx("GET_LEN_RANGE", list, "<range>",
        IS_RANGE_ALL_SMALL(list),
        "this function only supports small ranges (use GET_LEN_RANGE_BIGINT)");
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[0]);
}

/****************************************************************************
**
*F  GET_LEN_RANGE_BIGINT(<list>) . . . . . . . . . . . . .  length of a range
**
**  'GET_LEN_RANGE_BIGINT' returns the logical length of the range <list>
**  as a GAP integer object (which may be an immediate or large integer).
*/
EXPORT_INLINE Obj GET_LEN_RANGE_BIGINT(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    return CONST_ADDR_OBJ(list)[0];
}


/****************************************************************************
**
*F  SET_LOW_RANGE(<list>,<low>) . . . . . .  set the first element of a range
**
**  'SET_LOW_RANGE' sets the  first element of the range  <list> to the value
**  <low>, which must be a C integer that fits in a SmallInt.
*/
EXPORT_INLINE void SET_LOW_RANGE(Obj list, Int low)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[1] = INTOBJ_INT(low);
}

/****************************************************************************
**
*F  SET_LOW_RANGE_OBJ(<list>,<low>) . . . .  set the first element of a range
**
**  'SET_LOW_RANGE_OBJ' sets the first element of the range <list> to the
**  value <low>, which must be a GAP integer (immediate or large).
*/
EXPORT_INLINE void SET_LOW_RANGE_OBJ(Obj list, Obj low)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[1] = low;
}


/****************************************************************************
**
*F  GET_LOW_RANGE(<list>) . . . . . . . . . . . . .  first element of a range
**
**  'GET_LOW_RANGE' returns the first  element  of the  range  <list> as a  C
**  integer.  This function only works for 'small ranges' where all elements
**  fit in SmallInts.  Use GET_LOW_RANGE_BIGINT for arbitrary ranges.
*/
EXPORT_INLINE Int GET_LOW_RANGE(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    RequireArgumentConditionEx("GET_LOW_RANGE", list, "<range>",
        IS_RANGE_ALL_SMALL(list),
        "this function only supports small ranges (use GET_LOW_RANGE_BIGINT)");
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[1]);
}

/****************************************************************************
**
*F  GET_LOW_RANGE_BIGINT(<list>) . . . . . . . . . . first element of a range
**
**  'GET_LOW_RANGE_BIGINT' returns the first element of the range <list>
**  as a GAP integer object (which may be an immediate or large integer).
*/
EXPORT_INLINE Obj GET_LOW_RANGE_BIGINT(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    return CONST_ADDR_OBJ(list)[1];
}


/****************************************************************************
**
*F  SET_INC_RANGE(<list>,<inc>) . . . . . . . .  set the increment of a range
**
**  'SET_INC_RANGE' sets  the  increment of  the range  <list>   to the value
**  <inc>, which must be a C integer that fits in a SmallInt.
*/
EXPORT_INLINE void SET_INC_RANGE(Obj list, Int inc)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[2] = INTOBJ_INT(inc);
}

/****************************************************************************
**
*F  SET_INC_RANGE_OBJ(<list>,<inc>) . . . . . .  set the increment of a range
**
**  'SET_INC_RANGE_OBJ' sets the increment of the range <list> to the value
**  <inc>, which must be a GAP integer (immediate or large).
*/
EXPORT_INLINE void SET_INC_RANGE_OBJ(Obj list, Obj inc)
{
    GAP_ASSERT(IS_RANGE(list));
    ADDR_OBJ(list)[2] = inc;
}


/****************************************************************************
**
*F  GET_INC_RANGE(<list>) . . . . . . . . . . . . . . .  increment of a range
**
**  'GET_INC_RANGE' returns the increment of the range <list> as a C integer.
**  This function only works for 'small ranges' where all elements fit in
**  SmallInts.  Use GET_INC_RANGE_BIGINT for arbitrary ranges.
*/
EXPORT_INLINE Int GET_INC_RANGE(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    RequireArgumentConditionEx("GET_INC_RANGE", list, "<range>",
        IS_RANGE_ALL_SMALL(list),
        "this function only supports small ranges (use GET_INC_RANGE_BIGINT)");
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[2]);
}

/****************************************************************************
**
*F  GET_INC_RANGE_BIGINT(<list>) . . . . . . . . . . .  increment of a range
**
**  'GET_INC_RANGE_BIGINT' returns the increment of the range <list>
**  as a GAP integer object (which may be an immediate or large integer).
*/
EXPORT_INLINE Obj GET_INC_RANGE_BIGINT(Obj list)
{
    GAP_ASSERT(IS_RANGE(list));
    return CONST_ADDR_OBJ(list)[2];
}


/****************************************************************************
**
*F  GET_ELM_RANGE(<list>,<pos>) . . . . . . . . . . . . .  element of a range
**
**  'GET_ELM_RANGE' return  the <pos>-th element  of the range <list>.  <pos>
**  must be a positive integer less than or equal to the length of <list>.
**  This function only works for 'small ranges' where all elements fit in
**  SmallInts.  Use GET_ELM_RANGE_BIGINT for arbitrary ranges.
*/
EXPORT_INLINE Obj GET_ELM_RANGE(Obj list, Int pos)
{
    Int val;
    GAP_ASSERT(IS_RANGE(list));
    GAP_ASSERT(pos >= 1);
    RequireArgumentConditionEx("GET_ELM_RANGE", list, "<range>",
        IS_RANGE_ALL_SMALL(list),
        "this function only supports small ranges (use GET_ELM_RANGE_BIGINT)");
    val = INT_INTOBJ(CONST_ADDR_OBJ(list)[1]) +
          ((pos)-1) * INT_INTOBJ(CONST_ADDR_OBJ(list)[2]);
    return INTOBJ_INT(val);
}

/****************************************************************************
**
*F  GET_ELM_RANGE_BIGINT(<list>,<pos>)  . . . . . . . . .  element of a range
**
**  'GET_ELM_RANGE_BIGINT' returns the <pos>-th element of the range <list>.
**  <pos> must be a GAP integer. Works with ranges containing large integers.
**  This function is declared in range.h but implemented in range.c.
*/
Obj GET_ELM_RANGE_BIGINT(Obj list, Obj pos);

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
**
**  'Range2Check' constructs a range from <first> to <last> with increment 1.
**  Both <first> and <last> must be SmallInts.
*/
Obj Range2Check(Obj first, Obj last);


/****************************************************************************
**
*F  Range3Check( <first>, <second>, <last> )  . . . . . . . . construct range
**
**  'Range3Check' constructs a range from <first> to <last> with increment
**  <second> - <first>.  All arguments must be SmallInts.
*/
Obj Range3Check(Obj first, Obj second, Obj last);


/****************************************************************************
**
*F  Range2CheckBigInt( <first>, <last> )  . . . . . . . . . . construct range
**
**  'Range2CheckBigInt' constructs a range from <first> to <last> with
**  increment 1.  Both <first> and <last> can be arbitrary GAP integers.
*/
Obj Range2CheckBigInt(Obj first, Obj last);


/****************************************************************************
**
*F  Range3CheckBigInt( <first>, <second>, <last> )  . . . . . construct range
**
**  'Range3CheckBigInt' constructs a range from <first> to <last> with
**  increment <second> - <first>.  All arguments can be arbitrary GAP integers.
*/
Obj Range3CheckBigInt(Obj first, Obj second, Obj last);


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
