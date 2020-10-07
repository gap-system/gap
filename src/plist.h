/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions that deal with plain lists.
**
**  A  plain list is a list  that may have holes  and may contain elements of
**  arbitrary types.  A plain list may also have room for elements beyond its
**  current  logical length.  The  last position to  which  an element can be
**  assigned without resizing the plain list is called the physical length.
**
**  This representation is encoded by the functions 'NEW_PLIST', 'GROW_PLIST',
**  'SHRINK_PLIST', 'SET_LEN_PLIST',    'LEN_PLIST',     'SET_ELM_PLIST', and
**  'ELM_PLIST', which are used by the functions in this package and the rest
**  of the {\GAP} kernel to access plain lists.
**
**  This package also contains the list functions for  plain lists, which are
**  installed in the appropriate tables by 'InitPlist'.
*/

#ifndef GAP_PLIST_H
#define GAP_PLIST_H

#include "objects.h"

#include <string.h>

/****************************************************************************
**
*F  NEW_PLIST(<type>,<plen>)  . . . . . . . . . . . allocate a new plain list
**
**  'NEW_PLIST'  allocates a new plain list of type <type> that has room for
**  at least <plen> elements.
**
*/
EXPORT_INLINE Obj NEW_PLIST(UInt type, Int plen)
{
    GAP_ASSERT(plen >= 0);
    GAP_ASSERT(plen <= INT_INTOBJ_MAX);
    GAP_ASSERT(FIRST_PLIST_TNUM <= type && type <= LAST_PLIST_TNUM);
    Obj bag = NewBag(type, (plen + 1) * sizeof(Obj));
    ADDR_OBJ(bag)[0] = INTOBJ_INT(0);
    return bag;
}

EXPORT_INLINE Obj NEW_PLIST_IMM(UInt type, Int plen)
{
    return NEW_PLIST(type | IMMUTABLE, plen);
}

EXPORT_INLINE Obj NEW_PLIST_WITH_MUTABILITY(Int mut, UInt type, Int plen)
{
    if (!mut)
        type |= IMMUTABLE;
    return NEW_PLIST(type, plen);
}

/****************************************************************************
**
*F  IS_PLIST( <list> )  . . . . . . . . . . . check if <list> is a plain list
*/
EXPORT_INLINE BOOL IS_PLIST(Obj list)
{
    return FIRST_PLIST_TNUM <= TNUM_OBJ(list) &&
           TNUM_OBJ(list) <= LAST_PLIST_TNUM;
}

/****************************************************************************
**
*F  IS_PLIST_OR_POSOBJ( <list> ) . . . . . . . . . . . . check type of <list>
**
**  Checks if this is 'PLIST'-like.
**  This function is used in a GAP_ASSERT checking if calling functions like
**  SET_ELM_PLIST is acceptable on an Obj.
**
**  Unlike IS_PLIST, this function also accepts positional objects
**  (which have the same memory layout as plists), as the plist APIs using it
**  for assertion checks are in practice invoked on such objects, too.
*/
EXPORT_INLINE BOOL IS_PLIST_OR_POSOBJ(Obj list)
{
    UInt tnum = TNUM_OBJ(list);
    return (FIRST_PLIST_TNUM <= tnum && tnum <= LAST_PLIST_TNUM) ||
           tnum == T_POSOBJ;
}


/****************************************************************************
**
*F  CAPACITY_PLIST(<list>)  . . . . . . . . . . . capacity of a plain list
**
**  'CAPACITY_PLIST' returns the maximum capacity of a PLIST.
**
*/
EXPORT_INLINE Int CAPACITY_PLIST(Obj list)
{
    return SIZE_OBJ(list) / sizeof(Obj) - 1;
}

void GrowPlist(Obj list, UInt need);

/****************************************************************************
**
*F  GROW_PLIST(<list>,<plen>) . . . .  make sure a plain list is large enough
**
**  'GROW_PLIST' grows  the plain list <list>  if necessary to ensure that it
**  has room for at least <plen> elements.
**
*/
EXPORT_INLINE void GROW_PLIST(Obj list, Int plen)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    GAP_ASSERT(plen >= 0);
    if (plen > CAPACITY_PLIST(list)) {
        GrowPlist(list, plen);
    }
}


/****************************************************************************
**
*F  SHRINK_PLIST(<list>,<plen>) . . . . . . . . . . . . . shrink a plain list
**
**  'SHRINK_PLIST' shrinks  the plain list <list>  if possible  so that it has
**  still room for at least <plen> elements.
**
*/
EXPORT_INLINE void SHRINK_PLIST(Obj list, Int plen)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    GAP_ASSERT(plen >= 0);
    GAP_ASSERT(plen <= CAPACITY_PLIST(list));
    ResizeBag(list, (plen + 1) * sizeof(Obj));
}


/****************************************************************************
**
*F  SET_LEN_PLIST(<list>,<len>) . . . . . . .  set the length of a plain list
**
**  'SET_LEN_PLIST' sets the length of  the plain list  <list> to <len>.
**
*/
EXPORT_INLINE void SET_LEN_PLIST(Obj list, Int len)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    GAP_ASSERT(len >= 0);
    GAP_ASSERT(len <= CAPACITY_PLIST(list));
    ADDR_OBJ(list)[0] = INTOBJ_INT(len);
}


/****************************************************************************
**
*F  LEN_PLIST(<list>) . . . . . . . . . . . . . . . .  length of a plain list
**
**  'LEN_PLIST' returns the logical length of the list <list> as a C integer.
**
*/
EXPORT_INLINE Int LEN_PLIST(Obj list)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[0]);
}


/****************************************************************************
**
*F  SET_ELM_PLIST(<list>,<pos>,<val>) . . . assign an element to a plain list
**
**  'SET_ELM_PLIST' assigns the value  <val> to the  plain list <list> at the
**  position <pos>.  <pos> must be a  positive integer less  than or equal to
**  the length of <list>.
**
*/
EXPORT_INLINE void SET_ELM_PLIST(Obj list, Int pos, Obj val)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    GAP_ASSERT(pos >= 1);
    GAP_ASSERT(pos <= CAPACITY_PLIST(list));
    ADDR_OBJ(list)[pos] = val;
}

/****************************************************************************
**
*F  ELM_PLIST(<list>,<pos>) . . . . . . . . . . . . . element of a plain list
**
**  'ELM_PLIST' return the  <pos>-th element of  the list <list>.  <pos> must
**  be a positive  integer  less than  or  equal  to the  physical  length of
**  <list>.  If <list> has no assigned element at position <pos>, 'ELM_PLIST'
**  returns 0.
*/
EXPORT_INLINE Obj ELM_PLIST(Obj list, Int pos)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    GAP_ASSERT(pos >= 1);
    GAP_ASSERT(pos <= CAPACITY_PLIST(list));
    return CONST_ADDR_OBJ(list)[pos];
}

/****************************************************************************
**
*F  BASE_PTR_PLIST(<list>)  . . . . . . . . . . . . . element of a plain list
**
**  'BASE_PTR_PLIST' returns a point to the first element of the plist <list>
**
**  This point will be invalidated whenever a garbage collection occurs.
*/
EXPORT_INLINE Obj * BASE_PTR_PLIST(Obj list)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    return ADDR_OBJ(list) + 1;
}

/****************************************************************************
**
*F  IS_DENSE_PLIST( <list> )  . . . . . check if <list> is a dense plain list
**
**  Note that this only checks for plists that are known to be dense. This is
**  very fast.  If you want  to also handle plists  for which it is now known
**  whether they are dense or not (i.e. of type 'T_PLIST'),
**  use 'IS_DENSE_LIST' instead.
*/
EXPORT_INLINE BOOL IS_DENSE_PLIST(Obj list)
{
    return T_PLIST_DENSE <= TNUM_OBJ(list) &&
           TNUM_OBJ(list) <= LAST_PLIST_TNUM;
}

/****************************************************************************
**
*F  IS_PLIST_MUTABLE( <list> )  . . . . . . . . . . . is a plain list mutable
*/
EXPORT_INLINE BOOL IS_PLIST_MUTABLE(Obj list)
{
    GAP_ASSERT(IS_PLIST(list));
    return !((TNUM_OBJ(list) - T_PLIST) % 2);
}

/****************************************************************************
**
*F  AssPlist( <list>, <pos>, <val>) . . . . . . . . .  assign to a plain list
*/
void AssPlist(Obj list, Int pos, Obj val);

/****************************************************************************
**
*F  PushPlist( <list>, <val> ) . . . . . . . .  assign to end of a plain list
**
**  Note that this function does not adjust the TNUM of the list object. It
**  also does not attempt to convert the list to a different representation,
**  such as a string or blist. If your need that, use AddList or AddPlist
**  instead.
**
*/
EXPORT_INLINE UInt PushPlist(Obj list, Obj val)
{
    const UInt pos = LEN_PLIST(list) + 1;
    GROW_PLIST(list, pos);
    SET_LEN_PLIST(list, pos);
    SET_ELM_PLIST(list, pos, val);
    if (IS_BAG_REF(val))
        CHANGED_BAG(list);
    return pos;
}

/****************************************************************************
**
*F  PopPlist( <list> ) . . . . . . . . .  remove last element of a plain list
**
**  Also returns the removed element. Caller is responsible for ensuring that
**  the list is non-empty. Otherwise an assertion may be raised or the plist
**  be left in an invalid state.
**
**  Also clear the slot used by the pop'ed object, to avoid stale references
**  preventing the garbage collector from collecting the pop'ed object.
**
*/
EXPORT_INLINE Obj PopPlist(Obj list)
{
    const UInt pos = LEN_PLIST(list);
    Obj val = ELM_PLIST(list, pos);
    SET_LEN_PLIST(list, pos - 1);
    SET_ELM_PLIST(list, pos, 0);
    return val;
}


/****************************************************************************
**
*F  NewEmptyPlist() . . . . . . . . . .  create a new mutable empty plain list
*/
EXPORT_INLINE Obj NewEmptyPlist(void)
{
    return NEW_PLIST(T_PLIST_EMPTY, 0);
}


/****************************************************************************
**
*F  NewImmutableEmptyPlist() . . . . . create a new immutable empty plain list
*/
EXPORT_INLINE Obj NewImmutableEmptyPlist(void)
{
    return NEW_PLIST_IMM(T_PLIST_EMPTY, 0);
}


/****************************************************************************
**
*F  NewPlistFromArray(<list>,<length>) . . create a plain list from a C array
*/
EXPORT_INLINE Obj NewPlistFromArray(const Obj * list, Int length)
{
    if (length == 0) {
        return NewEmptyPlist();
    }

    Obj o = NEW_PLIST(T_PLIST, length);
    SET_LEN_PLIST(o, length);
    memcpy(BASE_PTR_PLIST(o), list, length * sizeof(Obj));
    CHANGED_BAG(o);
    return o;
}

/****************************************************************************
**
*F  NewPlistFromArgs(<args...>) .  create a plain list from list of arguments
**
**  NewPlistFromArgs turns a variable-length list of arguments into
**  an array, which is then passed to NewPlistFromArray.
**
**  There is no (nice) single implementation of NewPlistFromArgs that works
**  in both C and C++, so there are two separate implementations.
*/
#ifdef __cplusplus

// For C++, we use a variadic template function (requires C++11)
extern "C++" template <typename... Ts>
Obj NewPlistFromArgs(Ts... args)
{
    const int size = sizeof...(args);
    Obj       res[size] = { args... };
    return NewPlistFromArray(res, size);
}
#else

// For C, we use a variadic macro: __VA_ARGS__ contains the list of
// arguments given to this macro. (Obj[]){ __VA_ARGS__ } creates an
// array of Obj containing the elements of __VA_ARGS__.
#define NewPlistFromArgs(...)                                                \
    NewPlistFromArray((Obj[]){ __VA_ARGS__ },                                \
                      ARRAY_SIZE(((Obj[]){ __VA_ARGS__ })))
#endif

/****************************************************************************
**
*F  ShallowCopyPlist( <list>> )
*/
Obj ShallowCopyPlist(Obj list);


/****************************************************************************
**
*F  AssPlistEmpty( <list>, <pos>, <val> ) . . . . .  assignment to empty list
*/
void AssPlistEmpty(Obj list, Int pos, Obj val);

void AssPlistFfe(Obj list, Int pos, Obj val);

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoPlist() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPlist ( void );


#endif // GAP_PLIST_H
