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
Obj NEW_PREC(UInt len);


/****************************************************************************
**
*F  LEN_PREC( <rec> ) . . . . . . . . .  number of components of plain record
**
**  'LEN_PREC' returns the number of components of the plain record <rec>.
*/
#define LEN_PREC(rec)   (((UInt *)(ADDR_OBJ(rec)))[1])

/****************************************************************************
**
*F  SET_LEN_PREC( <rec> ) . . . . . .set number of components of plain record
**
**  'SET_LEN_PREC' sets the number of components of the plain record <rec>.
*/
#define SET_LEN_PREC(rec,nr)   (((UInt *)(ADDR_OBJ(rec)))[1] = (nr))

/****************************************************************************
**
*F  SET_RNAM_PREC( <rec>, <i>, <rnam> ) . set name of <i>-th record component
**
**  'SET_RNAM_PREC' sets   the name of  the  <i>-th  record component  of the
**  record <rec> to the record name <rnam>.
*/
#define SET_RNAM_PREC(rec,i,rnam) \
           do { Int rrrr = (rnam); \
 *(UInt*)(ADDR_OBJ(rec)+2*(i)) = rrrr; } while (0)


/****************************************************************************
**
*F  GET_RNAM_PREC( <rec>, <i> ) . . . . . . . name of <i>-th record component
**
**  'GET_RNAM_PREC' returns the record name of the <i>-th record component of
**  the record <rec>.
*/
#define GET_RNAM_PREC(rec,i) \
                        (*(UInt*)(ADDR_OBJ(rec)+2*(i)))


/****************************************************************************
**
*F  SET_ELM_PREC( <rec>, <i>, <val> ) .  set value of <i>-th record component
**
**  'SET_ELM_PREC' sets  the value  of  the  <i>-th  record component of  the
**  record <rec> to the value <val>.
*/
#define SET_ELM_PREC(rec,i,val) \
                 do { Obj oooo = (val); \
                        *(ADDR_OBJ(rec)+2*(i)+1) = oooo; } while (0)


/****************************************************************************
**
*F  GET_ELM_PREC( <rec>, <i> )  . . . . . .  value of <i>-th record component
**
**  'GET_ELM_PREC' returns the value  of the <i>-th  record component of  the
**  record <rec>.
*/
#define GET_ELM_PREC(rec,i) \
                        (*(ADDR_OBJ(rec)+2*(i)+1))


/****************************************************************************
**
*F  IS_PREC_REP( <rec> )  . . . . . . . check if <rec> is in plain record rep
*/
#define IS_PREC_REP(list)  \
  ( T_PREC <= TNUM_OBJ(list) && TNUM_OBJ(list) <= T_PREC+IMMUTABLE )


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
