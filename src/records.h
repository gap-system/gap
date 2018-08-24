/****************************************************************************
**
*W  records.h                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the generic record package.
**
**  This package  provides a uniform  interface to  the functions that access
**  records and the elements for the other packages in the GAP kernel.
*/

#ifndef GAP_RECORDS_H
#define GAP_RECORDS_H

#include "objects.h"

/****************************************************************************
**
*F  NAME_RNAM(<rnam>) . . . . . . . . . . .  name for a record name as an Obj
**
**  'NAME_RNAM' returns the name (as an Obj) for the record name <rnam>.
*/
extern Obj NAME_RNAM(UInt rnam);


/****************************************************************************
**
*F  RNamName(<name>)  . . . . . . . . . . . . convert a name to a record name
**
**  'RNamName' returns  the record name with the  name  <name> (which is  a C
**  string).
*/
extern  UInt            RNamName (
            const Char *        name );


/****************************************************************************
**
*F  RNamIntg(<intg>)  . . . . . . . . . . convert an integer to a record name
**
**  'RNamIntg' returns the record name corresponding to the integer <intg>.
*/
extern  UInt            RNamIntg (
            Int                 intg );


/****************************************************************************
**
*F  RNamObj(<obj>)  . . . . . . . . . . .  convert an object to a record name
**
**  'RNamObj' returns the record name  corresponding  to  the  object  <obj>,
**  which currently must be a string or an integer.
*/
extern  UInt            RNamObj (
            Obj                 obj );


/****************************************************************************
**
*F  IS_REC(<obj>) . . . . . . . . . . . . . . . . . . . is an object a record
*V  IsRecFuncs[<type>]  . . . . . . . . . . . . . . . . table of record tests
*/
extern Int (*IsRecFuncs[LAST_REAL_TNUM + 1])(Obj obj);

static inline Int IS_REC(Obj obj)
{
    return (*IsRecFuncs[TNUM_OBJ(obj)])(obj);
}


/****************************************************************************
**
*F  ELM_REC(<rec>,<rnam>) . . . . . . . . . . select an element from a record
**
**  'ELM_REC' returns the element, i.e., the value of the component, with the
**  record name <rnam> in  the record <rec>.   An error is signalled if <rec>
**  is not a record or if <rec> has no component with the record name <rnam>.
*/
extern Obj (*ElmRecFuncs[LAST_REAL_TNUM + 1])(Obj rec, UInt rnam);

static inline Obj ELM_REC(Obj rec, UInt rnam)
{
    return (*ElmRecFuncs[TNUM_OBJ(rec)])(rec, rnam);
}


/****************************************************************************
**
*F  ISB_REC(<rec>,<rnam>) . . . . . . . . . test for an element from a record
**
**  'ISB_REC' returns 1 if the record <rec> has a component with  the  record
**  name <rnam> and 0 otherwise.  An error is signalled if  <rec>  is  not  a
**  record.
*/
extern Int (*IsbRecFuncs[LAST_REAL_TNUM + 1])(Obj rec, UInt rnam);

static inline Int ISB_REC(Obj rec, UInt rnam)
{
    return (*IsbRecFuncs[TNUM_OBJ(rec)])(rec, rnam);
}

/****************************************************************************
**
*F  ASS_REC(<rec>,<rnam>,<obj>) . . . . . . . . . . . . .  assign to a record
**
**  'ASS_REC' assigns the object <obj>  to  the  record  component  with  the
**  record name <rnam> in the record <rec>.  An error is signalled  if  <rec>
**  is not a record.
*/
extern void (*AssRecFuncs[LAST_REAL_TNUM + 1])(Obj rec, UInt rnam, Obj obj);

static inline void ASS_REC(Obj rec, UInt rnam, Obj obj)
{
    return (*AssRecFuncs[TNUM_OBJ(rec)])(rec, rnam, obj);
}

/****************************************************************************
**
*F  UNB_REC(<rec>,<rnam>) . . . . . . unbind a record component from a record
**
**  'UNB_REC' removes the record component  with the record name <rnam>  from
**  the record <rec>.
*/
extern void (*UnbRecFuncs[LAST_REAL_TNUM + 1])(Obj rec, UInt rnam);

static inline void UNB_REC(Obj rec, UInt rnam)
{
    return (*UnbRecFuncs[TNUM_OBJ(rec)])(rec, rnam);
}


/****************************************************************************
**
*F  iscomplete_rnam( <name>, <len> )  . . . . . . . . . . . . .  check <name>
*/
extern UInt iscomplete_rnam (
            Char *              name,
            UInt                len );


/****************************************************************************
**
*F  completion_rnam( <name>, <len> )  . . . . . . . . . . . . find completion
*/
extern UInt completion_rnam (
            Char *              name,
            UInt                len );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoRecords() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoRecords ( void );


#endif // GAP_RECORDS_H
