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


/****************************************************************************
**

*F  NEW_PLIST(<type>,<plen>)  . . . . . . . . . . . allocate a new plain list
**
**  'NEW_PLIST'  allocates    a new plain   list  of  type <type> ('T_PLIST',
**  'T_SET', 'T_VECTOR') that has room for at least <plen> elements.
**
**  Note that 'NEW_PLIST' is a  macro, so do not call  it with arguments that
**  have side effects.
*/
#define NEW_PLIST(type,plen)            NewBag(type,((plen)+1)*sizeof(Obj))


/****************************************************************************
**
*F  GROW_PLIST(<list>,<plen>) . . . .  make sure a plain list is large enough
**
**  'GROW_PLIST' grows  the plain list <list>  if necessary to ensure that it
**  has room for at least <plen> elements.
**
**  Note that 'GROW_PLIST' is a macro, so do not call it with arguments that
**  have side effects.
*/
#define GROW_PLIST(list,plen)   ((plen) < SIZE_OBJ(list)/sizeof(Obj) ? \
                                 0L : GrowPlist(list,plen) )

extern  Int             GrowPlist (
            Obj                 list,
            UInt                need );


/****************************************************************************
**
*F  SHRINK_PLIST(<list>,<plen>) . . . . . . . . . . . . . shrink a plain list
**
**  'SHRINK_PLIST' shrinks  the plain list <list>  if possible  so that it has
**  still room for at least <plen> elements.
**
**  Note that 'SHRINK_PLIST' is a macro, so do not call it with arguments that
**  have side effects.
*/
#define SHRINK_PLIST(list,plen)         ResizeBag(list,((plen)+1)*sizeof(Obj))


/****************************************************************************
**
*F  SET_LEN_PLIST(<list>,<len>) . . . . . . .  set the length of a plain list
**
**  'SET_LEN_PLIST' sets the length of  the plain list  <list> to <len>.
**
**  Note  that 'SET_LEN_PLIST'  is a macro, so do not call it with  arguments
**  that have side effects.
*/
#define SET_LEN_PLIST(list,len)         (ADDR_OBJ(list)[0] = (Obj)(len))


/****************************************************************************
**
*F  LEN_PLIST(<list>) . . . . . . . . . . . . . . . .  length of a plain list
**
**  'LEN_PLIST' returns the logical length of the list <list> as a C integer.
**
**  Note that 'LEN_PLIST' is a  macro, so do  not call it with arguments that
**  have side effects.
*/
#define LEN_PLIST(list)                 ((Int)(ADDR_OBJ(list)[0]))


/****************************************************************************
**
*F  SET_ELM_PLIST(<list>,<pos>,<val>) . . . assign an element to a plain list
**
**  'SET_ELM_PLIST' assigns the value  <val> to the  plain list <list> at the
**  position <pos>.  <pos> must be a  positive integer less  than or equal to
**  the length of <list>.
**
**  Note that 'SET_ELM_PLIST' is a  macro, so do not  call it  with arguments
**  that have side effects.
**
** old version that causes problems if val can trigger a garbage collection
**
#define SET_ELM_PLIST(list,pos,val)     (ADDR_OBJ(list)[pos] = (val))
**
** New version should be safe
*/
#define SET_ELM_PLIST(list, pos, val) do { Obj sep_Obj = (val); ADDR_OBJ(list)[pos] = sep_Obj; } while (0)

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
*F  IS_PLIST( <list> )  . . . . . . . . . . . check if <list> is a plain list
*/
#define IS_PLIST( list ) \
  (FIRST_PLIST_TNUM <= TNUM_OBJ(list) && TNUM_OBJ(list) <= LAST_PLIST_TNUM)


/****************************************************************************
**
*F  IS_DENSE_PLIST( <list> )  . . . . . check if <list> is a dense plain list
**
** Note that this only checks for plists that are known to be dense.  This is  
** very fast.  If you want  to also handle plists  for which it  is now known      
** whether they  are dense or not  (i.e. of type T_PLIST),  use IS_DENSE_LIST 
** instead.                                                                   
*/
#define IS_DENSE_PLIST( list ) \
  (T_PLIST_DENSE <= TNUM_OBJ(list) && TNUM_OBJ(list) <= LAST_PLIST_TNUM)


/****************************************************************************
**
*F  IS_MUTABLE_PLIST( <list> )  . . . . . . . . . . . is a plain list mutable
*/
#define IS_MUTABLE_PLIST(list)  (!((TNUM_OBJ(list) - T_PLIST) % 2))

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
