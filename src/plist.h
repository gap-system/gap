/****************************************************************************
**
*W  plist.h                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions that deal with plain lists.
**
**  A  plain list is a list  that may have holes  and may contain elements of
**  arbitrary types.  A plain list may also have room for elements beyond its
**  current  logical length.  The  last position to  which  an element can be
**  assigned without resizing the plain list is called the physical length.
**
**  This representation  is encoded by  the macros 'NEW_PLIST', 'GROW_PLIST',
**  'SHRINK_PLIST', 'SET_LEN_PLIST',    'LEN_PLIST',     'SET_ELM_PLIST', and
**  'ELM_PLIST', which are used by the functions in this package and the rest
**  of the {\GAP} kernel to access plain lists.
**
**  This package also contains the list functions for  plain lists, which are
**  installed in the appropriate tables by 'InitPlist'.
*/

#ifndef GAP_PLIST_H
#define GAP_PLIST_H

#include <src/debug.h> /* for GAP_ASSERT */

/****************************************************************************
**
*F  NEW_PLIST(<type>,<plen>)  . . . . . . . . . . . allocate a new plain list
**
**  'NEW_PLIST'  allocates    a new plain   list  of  type <type> ('T_PLIST',
**  'T_SET', 'T_VECTOR') that has room for at least <plen> elements.
**
*/
static inline Obj NEW_PLIST(UInt type, Int plen)
{
    GAP_ASSERT(plen >= 0);
    return NewBag(type, (plen + 1) * sizeof(Obj));
}

/****************************************************************************
**
*F  IS_PLIST( <list> )  . . . . . . . . . . . check if <list> is a plain list
*/
static inline Int IS_PLIST(Obj list)
{
    return FIRST_PLIST_TNUM <= TNUM_OBJ(list) &&
           TNUM_OBJ(list) <= LAST_PLIST_TNUM;
}

/****************************************************************************
**
*F  IS_PLIST_OR_POSOBJ( <list> )  . . . . . . .check type of <list>
**
**  Checks if this is 'PLIST'-like.
**  This function is used in a GAP_ASSERT checking if calling functions like
**  SET_ELM_PLIST is acceptable on an Obj.
**  We also check is the 'COPYING' bit is set (which is not checked by
**  normal IS_PLIST).
*/

static inline Int IS_PLIST_OR_POSOBJ(Obj list)
{
    Int tnum = TNUM_OBJ(list);
    if (tnum > COPYING)
        tnum -= COPYING;
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
static inline Int CAPACITY_PLIST(Obj list)
{
    return SIZE_OBJ(list) / sizeof(Obj) - 1;
}

extern  Int             GrowPlist (
            Obj                 list,
            UInt                need );

/****************************************************************************
**
*F  GROW_PLIST(<list>,<plen>) . . . .  make sure a plain list is large enough
**
**  'GROW_PLIST' grows  the plain list <list>  if necessary to ensure that it
**  has room for at least <plen> elements.
**
*/
static inline void GROW_PLIST(Obj list, Int plen)
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
static inline void SHRINK_PLIST(Obj list, Int plen)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
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
static inline void SET_LEN_PLIST(Obj list, Int len)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    GAP_ASSERT(len >= 0);
    GAP_ASSERT(len <= CAPACITY_PLIST(list));
    ADDR_OBJ(list)[0] = (Obj)len;
}


/****************************************************************************
**
*F  LEN_PLIST(<list>) . . . . . . . . . . . . . . . .  length of a plain list
**
**  'LEN_PLIST' returns the logical length of the list <list> as a C integer.
**
*/
static inline Int LEN_PLIST(Obj list)
{
    GAP_ASSERT(IS_PLIST_OR_POSOBJ(list));
    return ((Int)(ADDR_OBJ(list)[0]));
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
static inline void SET_ELM_PLIST(Obj list, Int pos, Obj val)
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
**
**  Note that  'ELM_PLIST' is a macro, so do  not call it with arguments that
**  have side effects.
*/
#define ELM_PLIST(list,pos)             (ADDR_OBJ(list)[pos])




/****************************************************************************
**
*F  IS_DENSE_PLIST( <list> )  . . . . . check if <list> is a dense plain list
**
** Note that this only checks for plists that are known to be dense.  This is  
** very fast.  If you want  to also handle plists  for which it  is now known      
** whether they  are dense or not  (i.e. of type T_PLIST),  use IS_DENSE_LIST 
** instead.                                                                   
*/
static inline Int IS_DENSE_PLIST(Obj list)
{
    return T_PLIST_DENSE <= TNUM_OBJ(list) &&
           TNUM_OBJ(list) <= LAST_PLIST_TNUM;
}


/****************************************************************************
**
*F  IS_MUTABLE_PLIST( <list> )  . . . . . . . . . . . is a plain list mutable
*/
static inline Int IS_MUTABLE_PLIST(Obj list)
{
    return !((TNUM_OBJ(list) - T_PLIST) % 2);
}

/****************************************************************************
**
*F  AssPlist(<list>,<pos>,<val>)  . . . . . . . . . .  assign to a plain list
*/
extern void            AssPlist (
    Obj                 list,
    Int                 pos,
    Obj                 val );

/****************************************************************************
**

*F  AssPlistEmpty( <list>, <pos>, <val> ) . . . . .  assignment to empty list
*F  UnbPlistImm( <list>, <pos> ) . . . . . unbind an element from a plain list
*/
extern void AssPlistEmpty (
    Obj                 list,
    Int                 pos,
    Obj                 val );

extern void AssPlistFfe   (
    Obj                 list,
    Int                 pos,
    Obj                 val );

extern Int KTNumPlist (
    Obj                 list,
    Obj                 *famfirst);

void            UnbPlistImm (
    Obj                 list,
    Int                 pos );

/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoPlist() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPlist ( void );


#endif // GAP_PLIST_H

/****************************************************************************
**

*E  plist.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
