/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the generic list package.
**
**  This package provides a uniform   interface to the functions that  access
**  lists and their elements  for the other packages  in the GAP kernel.  For
**  example, 'ExecFor' can loop over the elements  in a list using 'LEN_LIST'
**  and 'ELM_LIST' independently of the type of the list.
*/

#ifndef GAP_LISTS_H
#define GAP_LISTS_H

#include "error.h"
#include "io.h"
#include "objects.h"

/****************************************************************************
**
*F  IS_LIST(<obj>)  . . . . . . . . . . . . . . . . . . . is an object a list
*V  IsListFuncs[<type>] . . . . . . . . . . . . . . . . . table for list test
**
**  'IS_LIST' returns a nonzero value if  the object <obj> is a list and zero
**  otherwise.
**
**  A package implementing  an ordinary list type <type>   must set the  flag
**  'IsListFlag[<type>]'  for  this type to '1'.   A  package  implementing a
**  vector type must set  it to '2'.  A  package implementing a matrix  type
**  must set it to '3'.
*/
extern BOOL (*IsListFuncs[LAST_REAL_TNUM + 1])(Obj obj);

EXPORT_INLINE BOOL IS_LIST(Obj obj)
{
    return (*IsListFuncs[TNUM_OBJ(obj)])(obj);
}


/****************************************************************************
**
*F  IS_SMALL_LIST(<obj>)  . . . . . . . . . . . . . is an object a small list
*V  IsSmallListFuncs[<type>] . . . . . . . . . . .. table for small list test
**
**  'IS_SMALL_LIST' returns a nonzero value if  the object <obj> is a small
**  list (meaning that its length will fit in 28 bits and zero otherwise.
**  in particular, it returns zero if <obj> is not a list at all
**
**  If <obj> is an external object it does not trigger length computation
**  in general
**  instead it will check if the object HasIsSmallList and IsSmallList, or
**  HasLength in which case Length will be checked
*/
extern BOOL (*IsSmallListFuncs[LAST_REAL_TNUM + 1])(Obj obj);

EXPORT_INLINE BOOL IS_SMALL_LIST(Obj obj)
{
    return (*IsSmallListFuncs[TNUM_OBJ(obj)])(obj);
}

/****************************************************************************
**
*F  IS_DENSE_LIST(<list>) . . . . . . . . . . . . . . .  test for dense lists
*V  IsDenseListFuncs[<type>]  . . . . . .  table of dense list test functions
**
**  'IS_DENSE_LIST'  returns 1 if the   list <list> is a   dense  list and  0
**  otherwise, i.e., if either <list> is not a list, or if it is not dense.
**
**  A package  implementing a list type  <type> must provide such  a function
**  and  install it in  'IsDenseListFuncs[<type>]'.   This function must loop
**  over the list and test for holes, unless  the type of the list guarantees
**  already that the list is dense (e.g. for sets).
*/

extern BOOL (*IsDenseListFuncs[LAST_REAL_TNUM + 1])(Obj list);

EXPORT_INLINE BOOL IS_DENSE_LIST(Obj list)
{
    return (*IsDenseListFuncs[TNUM_OBJ(list)])(list);
}

/****************************************************************************
**
*F  IS_HOMOG_LIST(<list>) . . . . . . . . . . . .  test for homogeneous lists
*V  IsHomogListFuncs[<type>]  . . .  table of homogeneous list test functions
**
**  'IS_HOMOG_LIST' returns 1 if  the list <list>  is a  homogeneous list and
**  0 otherwise, i.e., if either <list> is not  a  list,  or  if  it  is  not
**  homogeneous.
**
**  A  package implementing a list  type <type> must  provide such a function
**  and install  it  in 'IsHomogListFuncs[<type>]'.  This function  must loop
**  over the list   and test whether all  elements  lie in  the  same family,
**  unless  the type  of   the list  guarantees    already that the  list  is
**  homogeneous (e.g. for sets).
*/

extern BOOL (*IsHomogListFuncs[LAST_REAL_TNUM + 1])(Obj list);

EXPORT_INLINE BOOL IS_HOMOG_LIST(Obj list)
{
    return (*IsHomogListFuncs[TNUM_OBJ(list)])(list);
}

/****************************************************************************
**
*F  IS_POSS_LIST(<list>)  . . . . . . . . . . . . .  test for positions lists
*V  IsPossListFuncs[<type>] . . . . . . table of positions list test function
**
**  'IS_POSS_LIST' returns  1 if the list  <list> is  a dense list containing
**  only positive  integers and 0 otherwise, i.e.,  if either <list> is not a
**  list, or if it is not dense,  or if it contains  an element that is not a
**  positive integer.
**
**  A package  implementing a list type  <type> must provide such  a function
**  and install  it  in 'IsPossListFuncs[<type>]'.   This function  must loop
**  over the list  and  test for holes   and elements that are  not  positive
**  integers, unless the type of the list guarantees already that the list is
**  acceptable (e.g. a range with positive <low> and <high> values).
*/

extern BOOL (*IsPossListFuncs[LAST_REAL_TNUM + 1])(Obj list);

EXPORT_INLINE BOOL IS_POSS_LIST(Obj list)
{
    return (*IsPossListFuncs[TNUM_OBJ(list)])(list);
}

/****************************************************************************
**
*F  LEN_LIST(<list>)  . . . . . . . . . . . . . . . . . . .  length of a list
*V  LenListFuncs[<type>]  . . . . . . . . . . . . . table of length functions
**
**  A package  implementing a list type <type>  must  provide such a function
**  and install it in 'LenListFuncs[<type>]'.
*/
extern  Int             (*LenListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

EXPORT_INLINE Int LEN_LIST(Obj list)
{
    return (*LenListFuncs[TNUM_OBJ(list)])(list);
}


/****************************************************************************
**
*F  LENGTH(<list>)  . . . . . . . . . . . . . . . . . . .  length of a list
*V  LengthFuncs[<type>]  . . . . . . . . . . . . . table of length functions
**
**  'LENGTH' returns the logical length of the list <list>  as a GAP object
**  An error is signalled if <list> is not a list.
**
**  A package  implementing a list type <type>  must  provide such a function
**  and install it in 'LengthFuncs[<type>]'.
*/
extern  Obj             (*LengthFuncs[LAST_REAL_TNUM+1]) ( Obj list );

EXPORT_INLINE Obj LENGTH(Obj list)
{
    return (*LengthFuncs[TNUM_OBJ(list)])(list);
}


/****************************************************************************
**
*F  ISB_LIST(<list>,<pos>)  . . . . . . . . . .  test for element from a list
*V  IsbListFuncs[<type>]  . . . . . . . . . . . . . . table of test functions
**
**  'ISB_LIST' returns 1  if the list <list>  has an entry at  position <pos>
**  and 0 otherwise.  An error is signalled  if <list> is not  a list.  It is
**  the  responsibility of  the  caller to  ensure that  <pos> is a  positive
**  integer.
**
**  A  package implementing a  list type <type>  must  provide a function for
**  'ISB_LIST' and install it in 'IsbListFuncs[<type>]'.
**
*/

extern BOOL (*IsbListFuncs[LAST_REAL_TNUM + 1])(Obj list, Int pos);

EXPORT_INLINE BOOL ISB_LIST(Obj list, Int pos)
{
    return (*IsbListFuncs[TNUM_OBJ(list)])(list, pos);
}

BOOL ISBB_LIST(Obj list, Obj pos);

BOOL ISB_MAT(Obj list, Obj row, Obj col);


/****************************************************************************
**
*F * * * * * * * * * * * * list access functions  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  Elm0ListFuncs[ <type> ] . . . . . . . . . .  table of selection functions
**
**  A package  implementing a  list type <type>  must provide  a function for
**  'ELM0_LIST' and install it in 'Elm0ListFuncs[<type>]'.
*/
extern Obj (*Elm0ListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*F  ELM0_LIST( <list>, <pos> )  . . . . . . . . select an element from a list
**
**  'ELM0_LIST' returns the element at the position <pos> in the list <list>,
**  or 0 if <list>  has no assigned  object at position  <pos>.  An  error is
**  signalled if <list>  is  not a list.  It   is the responsibility   of the
**  caller to ensure that <pos> is a positive integer.
*/
EXPORT_INLINE Obj ELM0_LIST(Obj list, Int pos)
{
    return (*Elm0ListFuncs[TNUM_OBJ(list)])(list, pos);
}

/****************************************************************************
**
*V  ElmDefListFuncs[ <type> ] . . . . . . . . .  table of selection functions
**
**  A package implementing a list type <type> can provide a function for
**  'ELM_DEFAULT_LIST' and install it in 'ElmDefListFuncs[<type>]', otherwise
**  a default implementation is provided.
*/
extern Obj (*ElmDefListFuncs[LAST_REAL_TNUM + 1])(Obj list, Int pos, Obj def);


/****************************************************************************
**
*F  ELM_DEFAULT_LIST( <list>, <pos>, <default> )select an element from a list
**
**  'ELM_DEFAULT_LIST' returns the element at the position <pos> in the list
**  <list>, or <default> if <list> has no assigned object at position <pos>.
**  An error is signalled if <list> is not a list. It is the responsibility
**  of the caller to ensure that <pos> is a positive integer.
*/
EXPORT_INLINE Obj ELM_DEFAULT_LIST(Obj list, Int pos, Obj def)
{
    return (*ElmDefListFuncs[TNUM_OBJ(list)])(list, pos, def);
}


/****************************************************************************
**
*V  Elmv0ListFuncs[ <type> ]  . . . . . . . . .  table of selection functions
**
**  A package implementing  a lists type  <type> must provide a function  for
**  'ELMV0_LIST( <list>, <pos> )' and install it in 'Elmv0ListFuncs[<type>]'.
**  This function need not test whether <pos> is less than or equal to the
**  length of <list>.
*/
extern  Obj (*Elm0vListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*F  ELMV0_LIST( <list>, <pos> ) . . . . . . . . select an element from a list
**
**  'ELMV0_LIST' does the same as 'ELM0_LIST', but the caller also guarantees
**  that <list> is a list and that <pos> is less than  or equal to the length
**  of <list>.
*/
EXPORT_INLINE Obj ELMV0_LIST(Obj list, Int pos)
{
    GAP_ASSERT(pos > 0);
    GAP_ASSERT(pos <= LEN_LIST(list));
    return (*Elm0vListFuncs[TNUM_OBJ(list)])(list, pos);
}


/****************************************************************************
**
*V  ElmListFuncs[ <type> ]  . . . . . . . . . .  table of selection functions
**
**  A package implementing a  list  type <type> must  provide a  function for
**  'ELM_LIST( <list>, <pos> )' and install it in 'ElmListFuncs[<type>]'.
**  This function must signal an error if <pos> is larger than the length of
**  <list> or if <list> has no assigned object at <pos>.
*/
extern Obj (*ElmListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*F  ELM_LIST( <list>, <pos> ) . . . . . . . . . select an element from a list
*F  ELMB_LIST( <list>, <pos> ) . . . . . . . . . select an element from a list
**
**  'ELM_LIST' returns the element at the position  <pos> in the list <list>.
**  An  error is signalled if  <list> is not a list,  if <pos> is larger than
**  the length of <list>, or if <list>  has no assigned  object at <pos>.  It
**  is the responsibility  of the caller to  ensure that <pos>  is a positive
**  integer.
**
**  The difference between 'ELM_LIST' and 'ELMB_LIST' is that 'ELMB_LIST'
**  accepts an object as the second argument.
**  It is intended as an interface for access to elements of large external
**  lists, on the rare occasions when the kernel needs to do this.
*/
Obj ELMB_LIST(Obj list, Obj pos);

EXPORT_INLINE Obj ELM_LIST(Obj list, Int pos)
{
    Obj ret = (*ElmListFuncs[TNUM_OBJ(list)])(list, pos);
    GAP_ASSERT(ret != 0);
    return ret;
}


/****************************************************************************
**
*F  ELM_MAT( <list>, <row>, <col> ) . . . . select an element from a list
**
**  'ELM_MAT' implements 'list[row,col]', which for lists of lists is
**  defined as 'list[row][col]', and for other kind of objects is handled
**  by method dispatch through the GAP operation 'ELM_LIST' with three
**  arguments.
*/
Obj ELM_MAT(Obj list, Obj row, Obj col);


/****************************************************************************
**
*V  ElmvListFuncs[ <type> ] . . . . . . . . . .  table of selection functions
**
**  A package implementing  a list  type  <type> must provide a  function for
**  'ELMV_LIST' and  install  it  in 'ElmvListFuncs[<type>]'.   This function
**  need not check that <pos> is less than or equal to  the length of <list>,
**  but it must signal an error if <list> has no assigned object at <pos>.
**
*/
extern Obj (*ElmvListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*F  ELMV_LIST( <list>, <pos> )  . . . . . . . . select an element from a list
**
**  'ELMV_LIST' does  the same as 'ELM_LIST', but  the caller also guarantees
**  that <list> is a list and that <pos> is less  than or equal to the length
**  of <list>.
*/
EXPORT_INLINE Obj ELMV_LIST(Obj list, Int pos)
{
    GAP_ASSERT(pos > 0);
    GAP_ASSERT(pos <= LEN_LIST(list));
    return (*ElmvListFuncs[TNUM_OBJ(list)])(list, pos);
}


/****************************************************************************
**
*V  ElmwListFuncs[ <type> ] . . . . . . . . . .  table of selection functions
**
**  A package implementing a  list type  <type>  must provide a  function for
**  'ELMW_LIST' and install them  in 'ElmwListFuncs[<type>]'.  This  function
**  need not check that <pos> is  less than or equal  to the length of <list>
**  or that <list> has an assigned object at <pos>.
*/
extern Obj (*ElmwListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*F  ELMW_LIST( <list>, <pos> )  . . . . . . . . select an element from a list
**
**  'ELMW_LIST' does the same as 'ELMV_LIST', but  the caller also guarantees
**  that <list> has an assigned object at the position <pos>.
*/
EXPORT_INLINE Obj ELMW_LIST(Obj list, Int pos)
{
    GAP_ASSERT(pos > 0);
    GAP_ASSERT(pos <= LEN_LIST(list));
    Obj ret = (*ElmwListFuncs[TNUM_OBJ(list)])(list, pos);
    GAP_ASSERT(ret != 0);
    return ret;
}


/****************************************************************************
**
*V  ElmsListFuncs[ <type> ] . . . . . . . . . .  table of selection functions
**
**  A package implementing a list  type <type> must  provide such a  function
**  and install it in 'ElmsListFuncs[<type>]'.  This  function must signal an
**  error if any of the positions  is larger than the length  of <list> or if
**  <list>  has no assigned object at any of the positions  (and thus it will
**  always return a dense list).  It *must* create a new list, even if <poss>
**  is equal to  '[1..Length(<list>)]', 'EvalElmListLevel' depends on this so
**  that it can call 'ElmListLevel', which  overwrites this new list.  If the
**  result is a list of lists, then it also *must* create a new list that has
**  the same representation as a plain list.
*/
extern Obj (*ElmsListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Obj poss );



/****************************************************************************
**
*F  ELMS_LIST(<list>,<poss>)  . . . . . . select several elements from a list
**
**  'ELMS_LIST' returns a  new list containing the  elements at the positions
**  given in the list <poss> from the list <list>.  An  error is signalled if
**  <list> is not a list, if  any of the positions  is larger than the length
**  of  <list>, or if <list> has  no assigned object at any of the positions.
**  It is the responsibility of the  caller to ensure  that <poss> is a dense
**  list of positive integers.
*/
EXPORT_INLINE Obj ELMS_LIST(Obj list, Obj poss)
{
    GAP_ASSERT(IS_POSS_LIST(poss));
    return (*ElmsListFuncs[TNUM_OBJ(list)])(list, poss);
}


/****************************************************************************
**
*F  ElmsListDefault( <list>, <poss> ) . . .  default function for 'ELMS_LIST'
*/
Obj ElmsListDefault(Obj list, Obj poss);


/****************************************************************************
**
*F  ElmsListCheck( <list>, <poss> ) . . . . . . . . .  'ELMS_LIST' with check
*/
Obj ElmsListCheck(Obj list, Obj poss);


/****************************************************************************
**
*F  ElmsListLevelCheck( <lists>, <poss>, <level> ) 'ElmsListLevel' with check
*/
void ElmsListLevelCheck(Obj lists, Obj poss, Int level);


/****************************************************************************
**
*F  UNB_LIST(<list>,<pos>)  . . . . . . . . . . .  unbind element from a list
*V  UnbListFuncs[<type>]  . . . . . . . . . . . . . table of unbind functions
**
**  'UNB_LiST' unbinds the element at the position <pos> in the list  <list>.
**  Note that the unbinding may change the length of  the  representation  of
**  <list>.  An error is signalled if  <list>  is  not  a  list.  It  is  the
**  responsibility of the caller to ensure that <pos> is a positive integer.
**
**  A package implementing a list type <type> must provide  such  a  function
**  and install it in 'UnbListFuncs[<type>]'.  This function must change  the
**  representation of <list> to that of a plain list if necessary.
*/

extern void             (*UnbListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

void UNBB_LIST(Obj list, Obj pos);

EXPORT_INLINE void UNB_LIST(Obj list, Int pos)
{
    GAP_ASSERT(pos > 0);
    UInt tnum = TNUM_OBJ(list);
    if (FIRST_LIST_TNUM <= tnum && tnum <= LAST_LIST_TNUM &&
        (tnum & IMMUTABLE)) {
        ErrorMayQuit("List Unbind: <list> must be a mutable list", 0, 0);
    }
    (*UnbListFuncs[TNUM_OBJ(list)])(list, pos);
}

void UNB_MAT(Obj list, Obj row, Obj col);


/****************************************************************************
**
*F  ASS_LIST(<list>,<pos>,<obj>)  . . . . . . . . assign an element to a list
*V  AssListFuncs[<type>]  . . . . . . . . . . . table of assignment functions
**
**  'ASS_LIST' assigns the object <obj> to the list <list> at position <pos>.
**  Note that  the assignment may change  the length or the representation of
**  <list>.  An error   is signalled if  <list>  is not a  list.    It is the
**  responsibility of the caller to ensure that <pos>  is a positive integer,
**  and that <obj> is not 0.
**
**  A package  implementing a list type  <type> must provide  such a function
**  and   install it in  'AssListFuncs[<type>]'.   This  function must extend
**  <list> if <pos> is larger than the length of  <list> and must also change
**  the representation of <list> to that of a plain list if necessary.
*/


extern  void            (*AssListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos, Obj obj );

void ASSB_LIST(Obj list, Obj pos, Obj obj);

EXPORT_INLINE void ASS_LIST(Obj list, Int pos, Obj obj)
{
    GAP_ASSERT(pos > 0);
    GAP_ASSERT(obj != 0);
    UInt tnum = TNUM_OBJ(list);
    if (FIRST_LIST_TNUM <= tnum && tnum <= LAST_LIST_TNUM &&
        (tnum & IMMUTABLE)) {
        ErrorMayQuit("List Assignment: <list> must be a mutable list", 0, 0);
    }
    (*AssListFuncs[TNUM_OBJ(list)])(list, pos, obj);
}


/****************************************************************************
**
*F  ASS_MAT( <mat>, <row>, <col>, <obj> )
**
**  'ASS_MAT' implements 'mat[row,col]:=obj', which for lists of lists
**  is defined as 'mat[row][col]:=obj', and for other kind of objects is
**  handled by method dispatch through the GAP operation 'ASS_LIST' with
**  three arguments.
*/
void ASS_MAT(Obj list, Obj row, Obj col, Obj obj);


/****************************************************************************
**
*F  ASSS_LIST(<list>,<poss>,<objs>) . . . . assign several elements to a list
*V  AsssListFuncs[<type>] . . . . . . . . . . .  table of assignment function
**
**  'ASSS_LIST'  assigns the objects from  the list  <objs> at the positions
**  given in the  list <poss> to the list  <list>.  Note that  the assignment
**  may  change  the length or  the  representation of  <list>.   An error is
**  signalled if  <list> is  not  a list.   It  is the  responsibility of the
**  caller to ensure that  <poss> is a dense  list  of positive  integers and
**  that <objs> is a dense list of the same length as <poss>.
**
**  A package implementing  a list type <type> must  provide  such a function
**  and install it in 'AsssListFuncs[<type>]'.  This function must extend the
**  <list> if any of the  positions is larger than the  length of <list>  and
**  must also change the representation of <list> to that  of a plain list if
**  necessary.
*/
extern  void            (*AsssListFuncs[LAST_REAL_TNUM+1]) (Obj list, Obj poss, Obj objs);

void AsssListDefault(Obj list, Obj poss, Obj objs);

EXPORT_INLINE void ASSS_LIST(Obj list, Obj poss, Obj objs)
{
    GAP_ASSERT(IS_POSS_LIST(poss));
    GAP_ASSERT(IS_DENSE_LIST(objs));
    GAP_ASSERT(LEN_LIST(poss) == LEN_LIST(objs));
    UInt tnum = TNUM_OBJ(list);
    if (FIRST_LIST_TNUM <= tnum && tnum <= LAST_LIST_TNUM &&
        (tnum & IMMUTABLE)) {
        ErrorMayQuit("List Assignments: <list> must be a mutable list", 0, 0);
    }
    (*AsssListFuncs[TNUM_OBJ(list)])(list, poss, objs);
}

/****************************************************************************
**
*F  AssListObject( <list>, <pos>, <obj> ) . . . . . . . assign to list object
*/
void AssListObject(Obj list, Int pos, Obj obj);


/****************************************************************************
**
*F  IS_TABLE_LIST(<list>) . . . . . . . . . . . . . . .  test for table lists
*V  IsTableListFuncs[<type>]  . . . . . .  table of table list test functions
**
**  'IS_TABLE_LIST'  returns  1 if  the  list  <list>  is  a  table, i.e.,  a
**  homogeneous list of homogeneous lists of equal length, and 0 otherwise.
**
**  A  package implementing a list  type <type> must  provide such a function
**  and install it in  'IsTableListFuncs[<type>]'.   This function must  loop
**  over the list and test whether  all elements lie  in the same family, are
**  homogenous lists, and have  the same length, unless the  type of the list
**  guarantees already that the list has this property.
*/

extern BOOL (*IsTableListFuncs[LAST_REAL_TNUM + 1])(Obj list);

EXPORT_INLINE BOOL IS_TABLE_LIST(Obj list)
{
    return (*IsTableListFuncs[TNUM_OBJ(list)])(list);
}

/****************************************************************************
**
*F  IS_SSORT_LIST(<list>) . . . . . . . . . .  test for strictly sorted lists
*V  IsSSortListFuncs[<type>]  .  table of strictly sorted list test functions
**
**  'IS_SSORT_LIST' returns 1 if the list <list> is  a strictly  sorted  list
**  and 0 otherwise,  i.e., if either <list>  is not a list,  or if it is not
**  strictly sorted.
**
**  A  package implementing a  list type <type>  must provide such a function
**  and install it  in  'IsSSortListFuncs[<type>]'.  This function must  loop
**  over the list and compare each element with the next one, unless the type
**  of the list guarantees already that the list is strictly sorted.
*/

extern BOOL (*IsSSortListFuncs[LAST_REAL_TNUM + 1])(Obj list);

EXPORT_INLINE BOOL IS_SSORT_LIST(Obj list)
{
    return (*IsSSortListFuncs[TNUM_OBJ(list)])(list);
}


/****************************************************************************
**
*F  POS_LIST(<list>,<obj>,<start>)  . . . . . . . . find an element in a list
*V  PosListFuncs[<type>]  . . . . . . . . . . .  table of searching functions
**
**  'POS_LIST' returns  the  position of the  first  occurrence of  the object
**  <obj>,  which may be an object of any type, in the  list <list> after the
**  position  <start> as GAP Integer.  Fail is returned if  <obj> is not in the
**  list after <start>.  An error is signalled if <list> is not a list.
**
**  A package implementing a list  type <type> must  provide such a  function
**  and install it in 'PosListFuncs[<type>]'.
*/

extern  Obj             (*PosListFuncs[LAST_REAL_TNUM+1]) (Obj list, Obj obj, Obj start);

EXPORT_INLINE Obj POS_LIST(Obj list, Obj obj, Obj start)
{
    return (*PosListFuncs[TNUM_OBJ(list)])(list, obj, start);
}

/****************************************************************************
**
*F  ElmListLevel(<lists>,<pos>,<level>) . . . . . . . . . . . . . . . . . . .
*F  . . . . . . . . . . . . .  select an element of several lists in parallel
**
**  'ElmListLevel' assigns to '<lists>[<p_1>][<p_2>]...[<p_level>]' the value
**  '<lists>[<p_1>][<p_2>]...[<p_level>][<pos>]' for all  appropriate  tuples
**  of positions <p_1>,<p_2>,...,<p_level>.  An error is signalled if for any
**  tuple of positions  '<list> = <lists>[<p_1>][<p_2>]...[<p_level>]' is not
**  a list, <pos>  is larger  than  the length of <list>,   or <list> has  no
**  assigned object  at <pos>.   It is the   responsibility of the  caller to
**  ensure that <pos> is a positive integer.
**
**  It  is also  the responsibility of   the caller  to ensure  that <lists>,
**  '<lists>[<p_1>]', ...,   '<lists>[<p_1>][<p_2>]...[<p_level-1>]'  are all
**  dense lists with the same representation as plain lists.  Usually <lists>
**  is the   result of <level>  nested applications   of 'ELMS_LIST',  so  we
**  require 'ELMS_LIST' (resp.  the   functions implementing 'ELMS_LIST')  to
**  satisfy this requirements.
*/
void ElmListLevel(Obj lists, Obj pos, Int level);


/****************************************************************************
**
*F  ElmsListLevel(<lists>,<poss>,<level>) . . . . . . . . . . . . . . . . . .
*F  . . . . . . . . . .  select several elements of several lists in parallel
**
**  'ElmsListLevel'    assigns  to '<lists>[<p_1>][<p_2>]...[<p_level>]'  the
**  objects '<lists>[<p_1>][<p_2>]...[<p_level>]{<poss>}' for all appropriate
**  tuples of positions <p_1>,<p_2>,...,<p_level>.   An error is signalled if
**  for any tuple of positions '<list> = <lists>[<p_1>][<p_2>]...[<p_level>]'
**  is not a list, any  of the positions of  <poss> is larger than the length
**  of <list>, or <list> has  no assigned object at any of the positions.  It
**  is also the responsibility of the caller to ensure that <poss> is a dense
**  list of positive integers.
**
**  It  is  also the  responsibility  of the  caller  to ensure that <lists>,
**  '<lists>[<p_1>]',  ...,   '<lists>[<p_1>][<p_2>]...[<p_level-1>]' are all
**  dense lists with the same representation as plain lists.  Usually <lists>
**  is the result   of  <level> nested applications   of 'ELMS_LIST',  so  we
**  require 'ELMS_LIST' (resp.  the   functions implementing 'ELMS_LIST')  to
**  satisfy this requirements.
*/
void ElmsListLevel(Obj lists, Obj poss, Int level);


/****************************************************************************
**
*F  AssListLevel(<lists>,<pos>,<objs>,<level>)  . . . . . . . . . . . . . . .
*F  . . . . . . . . . . . . .  assign an element to several lists in parallel
**
**  'AssListLevel' assigns to    '<lists>[<p_1>][<p_2>]...[<p_level>][<pos>]'
**  the value '<objs>[<p_1>][<p_2>]...[<p_level>]' for all appropriate tuples
**  of positions <p_1>,<p_2>,...,<p_level>.  An error is signalled if for any
**  tuple of positions '<list>  = <lists>[<p_1>][<p_2>]...[<p_level>]' is not
**  a list, '<obj> =  <objs>[<p_1>][<p_2>]...[<p_i-1>]' is not a  dense list,
**  or  <obj> has not  the same length as '<list>[<p_1>][<p_2>]...[<p_i-1>]'.
**  It is the responsibility of the caller to ensure that <pos> is a positive
**  integer.
**
**  It is  also  the responsibility of   the caller  to  ensure that <lists>,
**  '<lists>[<p_1>]',   ...,  '<lists>[<p_1>][<p_2>]...[<p_level-1>]' are all
**  dense lists with the same representation as plain lists.  Usually <lists>
**  is the  result of   <level> nested applications  of  'ELMS_LIST',   so we
**  require  'ELMS_LIST'  (resp.  the functions implementing  'ELMS_LIST') to
**  satisfy this requirements.
*/
void AssListLevel(Obj lists, Obj pos, Obj objs, Int level);


/****************************************************************************
**
*F  AsssListLevel(<lists>,<poss>,<objs>,<level>)  . . . . . . . . . . . . . .
*F  . . . . . . . . . .  assign several elements to several lists in parallel
**
**  'AsssListLevel'  assigns to '<lists>[<p_1>][<p_2>]...[<p_level>]{<poss>}'
**  the  objects  '<objs>[<p_1>][<p_2>]...[<p_level>]' for  all   appropriate
**  tuples of positions <p_1>,<p_2>,...,<p_level>.   An error is signalled if
**  for any tuple of positions '<list> = <lists>[<p_1>][<p_2>]...[<p_level>]'
**  is not a list, '<obj> = <objs>[<p_1>][<p_2>]...[<p_i-1>]'  is not a dense
**  list, <obj> has not the same length as '<list>[<p_1>][<p_2>]...[<p_i-1>]'
**  or  '<objs>[<p_1>][<p_2>]...[<p_level>]' is not a  dense list of the same
**  length as <poss>.  It is the responsibility  of the caller to ensure that
**  <poss> is a dense list of positive integers.
**
**  It is also the   responsibility of the caller   to ensure that   <lists>,
**  '<lists>[<p_1>]',    ..., '<lists>[<p_1>][<p_2>]...[<p_level-1>]' are all
**  dense lists with the same representation as plain lists.  Usually <lists>
**  is the   result  of <level> nested applications   of   'ELMS_LIST', so we
**  require 'ELMS_LIST' (resp.   the functions  implementing 'ELMS_LIST')  to
**  satisfy this requirements.
*/
void AsssListLevel(Obj lists, Obj poss, Obj objs, Int lev);


/****************************************************************************
**
*F  PLAIN_LIST(<list>)  . . . . . . . . . . .  convert a list to a plain list
*V  PlainListFuncs[<type>]  . . . . . . . . . . table of conversion functions
**
**  'PLAIN_LIST' changes  the representation of the  list <list> to that of a
**  plain list. An error is signalled if <list> is not a list.
**
**  A package implementing a  list type <type>  must provide such  a function
**  and install it in 'PlainListFuncs[<type>]'.
*/

extern  void            (*PlainListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

EXPORT_INLINE void PLAIN_LIST(Obj list)
{
    ((*PlainListFuncs[TNUM_OBJ(list)])(list));
}


/****************************************************************************
**
*F  PLAIN_LIST_COPY(<list>) . . . . . . . copy a list to a mutable plain list
*/
Obj PLAIN_LIST_COPY(Obj list);


/****************************************************************************
**
*F  TYPES_LIST_FAM(<fam>) . . . . . . .  list of types of lists over a family
*/
Obj TYPES_LIST_FAM(Obj fam);


/****************************************************************************
**
*F * * * * * * * * * * * * * important filters  * * * * * * * * * * * * * * *
*/

typedef enum {
    /** filter number for 'IsSSortedList' */
    FN_IS_SSORT,

    /** filter number for 'IsNSortedList' */
    FN_IS_NSORT,

    /** filter number for 'IsDenseList' */
    FN_IS_DENSE,

    /** filter number for 'IsNDenseList' */
    FN_IS_NDENSE,

    /** filter number for 'IsHomogeneousList' */
    FN_IS_HOMOG,

    /** filter number for 'IsNonHomogeneousList' */
    FN_IS_NHOMOG,

    /** filter number for 'IsTable' */
    FN_IS_TABLE,

    /** filter number for 'IsRectangularTable' */
    FN_IS_RECT,

    LAST_FN = FN_IS_RECT
} FilterNumber;


/****************************************************************************
**
*V  SetFiltListTNums[ <tnum> ][ <fnum> ]  . . . . . new tnum after filter set
**
**  If a list  with type number <tnum>  gains  the filter  with filter number
**  <fnum>, then the new type number is stored in:
**
**  'SetFiltListTNums[<tnum>][<fnum>]'
**
**  'SET_FILT_LIST' is used to set the filter for a list by changing its
**  type number.
**
**  Two values are treated specially:
**    0 : The default. This tnum should not change.
**   (UInt)-1 : It is an error to apply this filter (for example,
**              marking an empty list as not sorted)
*/
extern UInt SetFiltListTNums [ LAST_REAL_TNUM ] [ LAST_FN + 1 ];


/****************************************************************************
**
*F  SET_FILT_LIST( <list>, <fnum> ) . . . . . . . . . . . . . .  set a filter
*/
EXPORT_INLINE void SET_FILT_LIST(Obj list, FilterNumber fn)
{
    UInt n = SetFiltListTNums[TNUM_OBJ(list)][fn];
    if (n == 0) {
        return;
    }
    if (n != (UInt)-1)
        RetypeBagIfWritable(list, n);
    else {
        Pr("#E  SET_FILT_LIST[%s][%d]\n", (Int)TNAM_OBJ(list), fn);
    }
}

/****************************************************************************
**
*F  SET_FILTER_LIST( <list>, <filter> ) . . . . . . . . . . . . .  set filter
*/
Obj SET_FILTER_LIST(Obj list, Obj filter);

/****************************************************************************
**
*V  ResetFiltListTNums[ <tnum> ][ <fnum> ]  . . . new tnum after filter reset
**
**  If a list  with type number <tnum>  loses  the filter  with filter number
**  <fnum>, then the new type number is stored in:
**
**  'ResetFiltListTNums[<tnum>][<fnum>]'
**
**  'RESET_FILT_LIST' is used to set the filter for a list by changing its
**  type number.
**
**  The same special values are used as SetFiltListTNums.
*/
extern UInt ResetFiltListTNums [ LAST_REAL_TNUM ] [ LAST_FN + 1 ];


/****************************************************************************
**
*F  RESET_FILT_LIST( <list>, <fnum> ) . . . . . . . . . . . .  reset a filter
*/
EXPORT_INLINE void RESET_FILT_LIST(Obj list, FilterNumber fn)
{
    UInt n = ResetFiltListTNums[TNUM_OBJ(list)][fn];
    if (n == 0) {
        return;
    }
    if (n != (UInt)-1)
        RetypeBag(list, n);
    else {
        Pr("#E  RESET_FILT_LIST[%s][%d]\n", (Int)TNAM_OBJ(list), fn);
    }
}

/****************************************************************************
**
*V  HasFiltListTNums[ <tnum> ][ <fnum> ]  . . . . . . . . . . . .  has filter
*/
extern Int HasFiltListTNums [ LAST_REAL_TNUM ] [ LAST_FN + 1 ];


/****************************************************************************
**
*F  HAS_FILT_LIST( <list>, <fnum> ) . . . . . . . . . . . . . . .  has filter
*/
#define HAS_FILT_LIST(list,fn)   HasFiltListTNums[TNUM_OBJ(list)][fn]


/****************************************************************************
**
*V  ClearFiltsTNums[ <tnum> ] . . . . . . . . . . . .  clear all list filters
**
**  The type  number without any  known properties  of a  list of type number
**  <tnum> is stored in:
**
**  'ClearPropsTNums[<tnum>]'
**
**  'CLEAR_PROPS_LIST' is used to clear all properties of a list.
*/
extern UInt ClearFiltsTNums [ LAST_REAL_TNUM ];


/****************************************************************************
**
*F  CLEAR_FILTS_LIST( <list> )  . . . . . . . . . . . . . .  clear properties
*/
EXPORT_INLINE void CLEAR_FILTS_LIST(Obj list)
{
    UInt n = ClearFiltsTNums[TNUM_OBJ(list)];
    if (n > 0) {
        RetypeBag(list, n);
    }
}


/****************************************************************************
**
*F * * * * * * * * * * * functions with checking  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  AsssListCheck( <list>, <poss>, <rhss> ) . . . . . . . . . . . . ASSS_LIST
*/
void AsssListCheck(Obj list, Obj poss, Obj rhss);


/****************************************************************************
**
*F  AsssListLevelCheck( <lists>, <poss>, <rhss>, <level> )  . . AsssListLevel
*/
void AsssListLevelCheck(Obj lists, Obj poss, Obj rhss, Int level);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoLists() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoLists ( void );


#endif // GAP_LISTS_H
