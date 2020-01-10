/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions for plain records.
*/

#ifndef GAP_PRECORD_H
#define GAP_PRECORD_H

#include "objects.h"

/****************************************************************************
**
*F * * * * * * * * * standard functions for plain records * * * * * * * * * *
*/


/****************************************************************************
**
*F  NEW_PREC( <len> ) . . . . . . . . . . . . . . . . make a new plain record
**
**  'NEW_PREC' returns a new plain record with room for <len> components.
**  Note that you still have to set the actual length once you have populated
**  the record!
*/
Obj NEW_PREC(UInt len);


/****************************************************************************
**
*F  IS_PREC( <rec> ) . . . . . . . . .  check if <rec> is in plain record rep
*/
EXPORT_INLINE BOOL IS_PREC(Obj rec)
{
    UInt tnum = TNUM_OBJ(rec);
    return tnum == T_PREC || tnum == T_PREC+IMMUTABLE;
}


/****************************************************************************
**
*F  IS_PREC_OR_COMOBJ( <list> ) . . . . . . . . . . . . . check type of <rec>
**
**  Checks if this is 'PREC'-like.
**  This function is used in a GAP_ASSERT checking if calling functions like
**  SET_ELM_PREC is acceptable on an Obj.
**
**  Unlike IS_PREC, this function also accepts component objects (which have
**  the same memory layout as precs), as the precs APIs using it for
**  assertion checks are in practice invoked on such objects, too.
*/
EXPORT_INLINE BOOL IS_PREC_OR_COMOBJ(Obj rec)
{
    UInt tnum = TNUM_OBJ(rec);
    return tnum == T_PREC || tnum == T_PREC+IMMUTABLE || tnum == T_COMOBJ;
}


/****************************************************************************
**
*F  CAPACITY_PREC(<list>) . . . . . . . . . . . .  capacity of a plain record
**
**  'CAPACITY_PREC' returns the maximum capacity of a PREC.
**
*/
EXPORT_INLINE UInt CAPACITY_PREC(Obj rec)
{
    return SIZE_OBJ(rec) / (2 * sizeof(Obj)) - 1;
}


/****************************************************************************
**
*F  LEN_PREC( <rec> ) . . . . . . . . .  number of components of plain record
**
**  'LEN_PREC' returns the number of components of the plain record <rec>.
*/
EXPORT_INLINE UInt LEN_PREC(Obj rec)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    return ((const UInt *)(CONST_ADDR_OBJ(rec)))[1];
}


/****************************************************************************
**
*F  SET_LEN_PREC( <rec> ) . . . . .  set number of components of plain record
**
**  'SET_LEN_PREC' sets the number of components of the plain record <rec>.
*/
EXPORT_INLINE void SET_LEN_PREC(Obj rec, UInt nr)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    GAP_ASSERT(nr <= CAPACITY_PREC(rec));
    ((UInt *)(ADDR_OBJ(rec)))[1] = nr;
}


/****************************************************************************
**
*F  SET_RNAM_PREC( <rec>, <i>, <rnam> ) . set name of <i>-th record component
**
**  'SET_RNAM_PREC' sets   the name of  the  <i>-th  record component  of the
**  record <rec> to the record name <rnam>.
*/
EXPORT_INLINE void SET_RNAM_PREC(Obj rec, UInt i, Int rnam)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    GAP_ASSERT(i <= CAPACITY_PREC(rec));
    *(Int *)(ADDR_OBJ(rec) + 2 * (i)) = rnam;
}


/****************************************************************************
**
*F  GET_RNAM_PREC( <rec>, <i> ) . . . . . . . name of <i>-th record component
**
**  'GET_RNAM_PREC' returns the record name of the <i>-th record component of
**  the record <rec>.
*/
EXPORT_INLINE Int GET_RNAM_PREC(Obj rec, UInt i)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    GAP_ASSERT(i <= LEN_PREC(rec));
    return *(const Int *)(CONST_ADDR_OBJ(rec) + 2 * (i));
}


/****************************************************************************
**
*F  SET_ELM_PREC( <rec>, <i>, <val> ) .  set value of <i>-th record component
**
**  'SET_ELM_PREC' sets  the value  of  the  <i>-th  record component of  the
**  record <rec> to the value <val>.
*/
EXPORT_INLINE void SET_ELM_PREC(Obj rec, UInt i, Obj val)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    GAP_ASSERT(i <= CAPACITY_PREC(rec));
    *(ADDR_OBJ(rec)+2*(i)+1) = val;
}


/****************************************************************************
**
*F  GET_ELM_PREC( <rec>, <i> )  . . . . . .  value of <i>-th record component
**
**  'GET_ELM_PREC' returns the value  of the <i>-th  record component of  the
**  record <rec>.
*/
EXPORT_INLINE Obj GET_ELM_PREC(Obj rec, UInt i)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    GAP_ASSERT(i <= LEN_PREC(rec));
    return *(CONST_ADDR_OBJ(rec)+2*(i)+1);
}


/****************************************************************************
**
*F * * * * * * * * * standard functions for plain records * * * * * * * * * *
*/

/****************************************************************************
**
*F  PositionPRec( <rec>, <rnam>, <cleanup> )
*F   . . . . . . . . . . . . . . . . . find a component name by binary search
**
**  Searches <rnam> in <rec>, returns the position where it is found, or 0
**  if it is not present.
**  If <cleanup> is nonzero, a dirty record is automatically cleaned up.
**  If <cleanup> is 0, this does not happen.
**
**
*F  FindPRec( <rec>, <rnam>, <pos>, <cleanup> )
*F   . . . . . . . . . . . . . . . . . find a component name by binary search
**  A deprecated variant of PositionPRec, which sets <pos> to the position
**  where the value is contained (or NULL if it is not present) and returns 1
**  if the record contained rnam, and 0 otherwise.
**/

UInt PositionPRec(Obj rec, UInt rnam, int cleanup);

EXPORT_INLINE UInt FindPRec(Obj rec, UInt rnam, UInt * pos, int cleanup)
{
    *pos = PositionPRec(rec, rnam, cleanup);
    return (*pos != 0);
}


/****************************************************************************
**
*F  ElmPRec(<rec>,<rnam>) . . . . . . . select an element from a plain record
**
**  'ElmPRec' returns the element, i.e., the value of the component, with the
**  record name <rnam> in  the plain record <rec>.   An error is signalled if
**  <rec> has no component with record name <rnam>.
*/
Obj ElmPRec(Obj rec, UInt rnam);


/****************************************************************************
**
*F  IsbPRec(<rec>,<rnam>)  . . . . .  test for an element from a plain record
**
**  'IsbPRec' returns 1 if the record <rec> has a component with  the  record
**  name <rnam>, and 0 otherwise.
*/
BOOL IsbPRec(Obj rec, UInt rnam);


/****************************************************************************
**
*F  AssPRec(<rec>,<rnam>,<val>)  . . . . . . . . . . assign to a plain record
**
**  'AssPRec' assigns the value <val> to the record component with the record
**  name <rnam> in the plain record <rec>.
*/
void AssPRec(Obj rec, UInt rnam, Obj val);


/****************************************************************************
**
*F  UnbPRec(<rec>,<rnam>) . . . unbind a record component from a plain record
**
**  'UnbPRec'  removes the record component  with the record name <rnam> from
**  the record <rec>.
*/
void UnbPRec(Obj rec, UInt rnam);


/****************************************************************************
**
*F  SortPRecRNam(<rec>, <inplace>) . . . . . . . sort the Rnams of the record
**
**  This is needed after the components of a record have been assigned
**  in not necessarily sorted order in the kernel. It is automatically
**  called on the first read access if necessary. See the top of "precord.c"
**  for a comment on lazy sorting.
**  If inplace is 1 then a slightly slower algorithm is used of
**  which we know that it does not produce garbage collections.
**  If inplace is 0 a garbage collection may be triggered.
**
*/
void SortPRecRNam(Obj rec, int inplace);


#ifdef USE_THREADSAFE_COPYING
typedef struct TraversalState TraversalState;
void TraversePRecord(TraversalState * traversal, Obj obj);
void CopyPRecord(TraversalState * traversal, Obj copy, Obj original);
#endif


void MarkPRecSubBags(Obj bag);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoPRecord() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPRecord ( void );


#endif // GAP_PRECORD_H
