/****************************************************************************
**
*W  precord.h                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions for plain records.
*/

#ifndef GAP_PRECORD_H
#define GAP_PRECORD_H


#include <src/records.h>


/****************************************************************************
**
*F * * * * * * * * * * standard macros for plain records  * * * * * * * * * *
*/


/****************************************************************************
**
*F  NEW_PREC( <len> ) . . . . . . . . . . . . . . . . make a new plain record
**
**  'NEW_PREC' returns a new plain record with room for <len> components.
**  Note that you still have to set the actual length once you have populated
**  the record!
*/
extern Obj NEW_PREC(UInt len);


/****************************************************************************
**
*F  IS_PREC( <rec> ) . . . . . . . . .  check if <rec> is in plain record rep
*/
static inline Int IS_PREC(Obj rec)
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
**  Unlike IS_PREC, this function also accepts precs which are being copied
**  (and hence have the COPYING flag set), as well as component objects
**  (which have the same memory layout as precs), as the precs APIs using it
**  for assertion checks are in practice invoked on such objects, too.
*/
static inline Int IS_PREC_OR_COMOBJ(Obj rec)
{
    UInt tnum = TNUM_OBJ(rec);
    if (tnum > COPYING)
        tnum -= COPYING;
    return tnum == T_PREC || tnum == T_PREC+IMMUTABLE || tnum == T_COMOBJ;
}


/****************************************************************************
**
*F  CAPACITY_PREC(<list>) . . . . . . . . . . . .  capacity of a plain record
**
**  'CAPACITY_PREC' returns the maximum capacity of a PREC.
**
*/
static inline Int CAPACITY_PREC(Obj rec)
{
    return SIZE_OBJ(rec) / (2 * sizeof(Obj)) - 1;
}


/****************************************************************************
**
*F  LEN_PREC( <rec> ) . . . . . . . . .  number of components of plain record
**
**  'LEN_PREC' returns the number of components of the plain record <rec>.
*/
static inline UInt LEN_PREC(Obj rec)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    return ((UInt *)(ADDR_OBJ(rec)))[1];
}


/****************************************************************************
**
*F  SET_LEN_PREC( <rec> ) . . . . .  set number of components of plain record
**
**  'SET_LEN_PREC' sets the number of components of the plain record <rec>.
*/
static inline void SET_LEN_PREC(Obj rec, UInt nr)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    ((UInt *)(ADDR_OBJ(rec)))[1] = nr;
}


/****************************************************************************
**
*F  SET_RNAM_PREC( <rec>, <i>, <rnam> ) . set name of <i>-th record component
**
**  'SET_RNAM_PREC' sets   the name of  the  <i>-th  record component  of the
**  record <rec> to the record name <rnam>.
*/
static inline void SET_RNAM_PREC(Obj rec, UInt i, UInt rnam)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    GAP_ASSERT(i <= CAPACITY_PREC(rec));
    *(UInt *)(ADDR_OBJ(rec)+2*(i)) = rnam;
}


/****************************************************************************
**
*F  GET_RNAM_PREC( <rec>, <i> ) . . . . . . . name of <i>-th record component
**
**  'GET_RNAM_PREC' returns the record name of the <i>-th record component of
**  the record <rec>.
*/
static inline UInt GET_RNAM_PREC(Obj rec, UInt i)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    GAP_ASSERT(i <= CAPACITY_PREC(rec));
    return *(UInt *)(ADDR_OBJ(rec)+2*(i));
}


/****************************************************************************
**
*F  SET_ELM_PREC( <rec>, <i>, <val> ) .  set value of <i>-th record component
**
**  'SET_ELM_PREC' sets  the value  of  the  <i>-th  record component of  the
**  record <rec> to the value <val>.
*/
static inline void SET_ELM_PREC(Obj rec, UInt i, Obj val)
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
static inline Obj GET_ELM_PREC(Obj rec, UInt i)
{
    GAP_ASSERT(IS_PREC_OR_COMOBJ(rec));
    GAP_ASSERT(i <= CAPACITY_PREC(rec));
    return *(ADDR_OBJ(rec)+2*(i)+1);
}


/****************************************************************************
**
*F * * * * * * * * * standard functions for plain records * * * * * * * * * *
*/

/****************************************************************************
**
*F FindPRec( <rec>, <rnam>, <pos>, <cleanup> )
**   . . . . . . . . . . . . . . . . . find a component name by binary search
**
** Searches rnam in rec, sets pos to the position where it is found (return
** value 1) or where it should be inserted if it is not found (return val 0).
** If cleanup is nonzero, a dirty record is automatically cleaned up.
** If cleanup is 0, this does not happen.
**/

extern UInt FindPRec( Obj rec, UInt rnam, UInt *pos, int cleanup );


/****************************************************************************
**
*F  ElmPRec(<rec>,<rnam>) . . . . . . . select an element from a plain record
**
**  'ElmPRec' returns the element, i.e., the value of the component, with the
**  record name <rnam> in  the plain record <rec>.   An error is signalled if
**  <rec> has no component with record name <rnam>.
*/
extern  Obj             ElmPRec (
            Obj                 rec,
            UInt                rnam );


/****************************************************************************
**
*F  IsbPRec(<rec>,<rnam>)  . . . . .  test for an element from a plain record
**
**  'IsbPRec' returns 1 if the record <rec> has a component with  the  record
**  name <rnam>, and 0 otherwise.
*/
extern  Int             IsbPRec (
            Obj                 rec,
            UInt                rnam );


/****************************************************************************
**
*F  AssPRec(<rec>,<rnam>,<val>)  . . . . . . . . . . assign to a plain record
**
**  'AssPRec' assigns the value <val> to the record component with the record
**  name <rnam> in the plain record <rec>.
*/
extern  void            AssPRec (
            Obj                 rec,
            UInt                rnam,
            Obj                 val );


/****************************************************************************
**
*F  UnbPRec(<rec>,<rnam>) . . . unbind a record component from a plain record
**
**  'UnbPRec'  removes the record component  with the record name <rnam> from
**  the record <rec>.
*/
extern  void            UnbPRec (
            Obj                 rec,
            UInt                rnam );


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
extern  void            SortPRecRNam (
            Obj                 rec,
            int                 inplace );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoPRecord() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPRecord ( void );


#endif // GAP_PRECORD_H
