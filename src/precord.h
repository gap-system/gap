/****************************************************************************
**
*A  precord.h                   GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions for plain records.
*/
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_precord_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**
*F  NEW_PREC(<len>) . . . . . . . . . . . . . . . . . make a new plain record
**
**  'NEW_PREC' returns a new plain record with room for <len> components.
*/
#define NEW_PREC(len)   NewBag( T_PREC, (len) * 2*sizeof(Obj) + sizeof(Obj) )


/****************************************************************************
**
*F  LEN_PREC(<rec>) . . . . . . . . . .  number of components of plain record
**
**  'LEN_PREC' returns the number of components of the plain record <rec>.
*/
#define LEN_PREC(rec)   ((SIZE_OBJ(rec) - sizeof(Obj)) / (2*sizeof(Obj)))


/****************************************************************************
**
*F  SET_RNAM_PREC(<rec>,<i>,<rnam>) . . . set name of <i>-th record component
**
**  'SET_RNAM_PREC' sets   the name of  the  <i>-th  record component  of the
**  record <rec> to the record name <rnam>.
*/
#define SET_RNAM_PREC(rec,i,rnam) \
                        (*(UInt*)(ADDR_OBJ(rec)+2*(i)-1) = (rnam))


/****************************************************************************
**
*F  GET_RNAM_PREC(<rec>,<i>)  . . . . . . . . name of <i>-th record component
**
**  'GET_RNAM_PREC' returns the record name of the <i>-th record component of
**  the record <rec>.
*/
#define GET_RNAM_PREC(rec,i) \
                        (*(UInt*)(ADDR_OBJ(rec)+2*(i)-1))


/****************************************************************************
**
*F  SET_ELM_PREC(<rec>,<i>,<val>) . . .  set value of <i>-th record component
**
**  'SET_ELM_PREC' sets  the value  of  the  <i>-th  record component of  the
**  record <rec> to the value <val>.
*/
#define SET_ELM_PREC(rec,i,val) \
                        (*(ADDR_OBJ(rec)+2*(i)-0) = (val))


/****************************************************************************
**
*F  GET_ELM_PREC(<rec>,<i>) . . . . . . . .  value of <i>-th record component
**
**  'GET_ELM_PREC' returns the value  of the <i>-th  record component of  the
**  record <rec>.
*/
#define GET_ELM_PREC(rec,i) \
                        (*(ADDR_OBJ(rec)+2*(i)-0))


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
*F  InitPRecord() . . . . . . . . . . . . . . . . . initialize record package
**
**  'InitPRecord' initializes the record package.
*/
extern  void            InitPRecord ( void );



