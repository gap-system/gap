/****************************************************************************
**
*W  objects.c                   GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of the objects package.
*/
char * Revision_objects_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts, SyIsIntr           */
#include        "gasman.h"              /* Retype                          */

#define INCLUDE_DECLARATION_PART
#include        "objects.h"             /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* NewFunctionC                    */
#include        "opers.h"               /* NewFilterC, NewOperationC       */

#include        "bool.h"                /* True, False                     */

#include        "plist.h"               /* ELM_PLIST used by FAMILY_TYPE   */

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*T  Obj . . . . . . . . . . . . . . . . . . . . . . . . . . . type of objects
**
**  'Obj' is defined in the declaration part of this package.
*/


/****************************************************************************
**

*F  IS_INTOBJ( <o> )  . . . . . . . .  test if an object is an integer object
**
**  'IS_INTOBJ' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  ARE_INTOBJS( <o1>, <o2> ) . . . . test if two objects are integer objects
**
**  'ARE_INTOBJS' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  INTOBJ_INT( <i> ) . . . . . . .  convert a C integer to an integer object
**
**  'INTOBJ_INT' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  INT_INTOBJ( <o> ) . . . . . . .  convert an integer object to a C integer
**
**  'INT_INTOBJ' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  EQ_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'EQ_INTOBJS' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  LT_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'LT_INTOBJS' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  SUM_INTOBJS( <o>, <l>, <r> )  . . . . . . . .  sum of two integer objects
**
**  'SUM_INTOBJS' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  DIFF_INTOBJS( <o>, <l>, <r> ) . . . . . difference of two integer objects
**
**  'DIFF_INTOBJS' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  PROD_INTOBJS( <o>, <l>, <r> ) . . . . . .  product of two integer objects
**
**  'PROD_INTOBJS' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  IS_FFE( <o> ) . . . . . . . . test if an object is a finite field element
**
**  'IS_FFE'  returns 1  if the  object <o>  is  an  (immediate) finite field
**  element and 0 otherwise.
*/


/****************************************************************************
**

*S  T_<name>  . . . . . . . . . . . . . . . . symbolic names for object types
*S  FIRST_CONSTANT_TNUM, LAST_CONSTANT_TNUM . . . . range of constant   types
*S  FIRST_RECORD_TNUM,   LAST_RECORD_TNUM . . . . . range of record     types
*S  FIRST_LIST_TNUM,     LAST_LIST_TNUM . . . . . . range of list       types
*S  FIRST_EXTERNAL_TNUM, LAST_EXTERNAL_TNUM . . . . range of external   types
*S  FIRST_REAL_TNUM,     LAST_REAL_TNUM . . . . . . range of real       types
*S  FIRST_VIRTUAL_TNUM,  LAST_VIRTUAL_TNUM  . . . . range of virtual    types
*S  FIRST_IMM_MUT_TNUM,  LAST_IMM_MUT_TNUM  . . . . range of im/mutable types
**
**  The  objects types and the type ranges are  defined  in  the  declaration
**  part of this package.
*/


/****************************************************************************
**

*F  TNUM_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . type of an object
**
**  'TNUM_OBJ' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  TNUM_OBJ_Handler( <self>, <obj> ) . . . . . . . .  handler for 'TNUM_OBJ'
*/
Obj TNUM_OBJ_Func;

Obj TNUM_OBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
    return INTOBJ_INT( TNUM_OBJ(obj) );
}


/****************************************************************************
**
*F  SIZE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . size of an object
**
**  'SIZE_OBJ' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  SIZE_OBJ_Handler( <self>, <obj> ) . . . . . . . .  handler for 'SIZE_OBJ'
*/
Obj SIZE_OBJ_Func;

Obj SIZE_OBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
    return INTOBJ_INT( SIZE_OBJ(obj) );
}


/****************************************************************************
**
*F  ADDR_OBJ( <obj> ) . . . . . . . . . . . . . absolute address of an object
**
**  'ADDR_OBJ' is defined in the declaration part of this package.
*/


/****************************************************************************
**

*F  FAMILY_TYPE( <kind> ) . . . . . . . . . . . . . . . . .  family of a kind
**
**  'FAMILY_TYPE' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  FamilyTypeHandler( <self>, <kind> ) . . . . . . handler for 'FAMILY_TYPE'
*/
Obj FamilyTypeFunc;

Obj FamilyTypeHandler (
    Obj                 self,
    Obj                 kind )
{
    return FAMILY_TYPE( kind );
}


/****************************************************************************
**
*F  FAMILY_OBJ( <obj> ) . . . . . . . . . . . . . . . . . family of an object
**
**  'FAMILY_OBJ' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  FamilyObjHandler( <self>, <obj> ) . . . . . . .  handler for 'FAMILY_OBJ'
*/
Obj FamilyObjFunc;

Obj FamilyObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return FAMILY_OBJ( obj );
}


/****************************************************************************
**
*F  FLAGS_TYPE( <kind> )  . . . . . . . . . . .  flags boolean list of a kind
**
**  'FLAGS_TYPE' is defined in the declaration part of this package.
*/


/****************************************************************************
**
*F  SHARED_TYPE( <kind> ) . . . . . . . . . . . . . . . shared data of a kind
**
**  'SHARED_TYPE' is defined in the declaration part of this package.
*/


/****************************************************************************
**

*F  TYPE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . kind of an object
**
**  'TYPE_OBJ' returns the kind of the object <obj>.
**
**  'TYPE_OBJ' is defined in the declaration part of this package.
*/
Obj (*TypeObjFuncs[ LAST_REAL_TNUM+1 ]) ( Obj obj );

Obj TypeObjError (
    Obj                 obj )
{
    ErrorQuit(
        "Panic: basic object of type '%s' is unkind",
        (Int)(InfoBags[TNUM_OBJ(obj)].name), 0L );
    return 0;
}


/****************************************************************************
**
*F  TypeObjHandler( <self>, <obj> ) . . . . . . . . .  handler for 'TYPE_OBJ'
*/
Obj TypeObjFunc;

Obj TypeObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return TYPE_OBJ( obj );
}


/****************************************************************************
**

*F  MUTABLE_TNUM( <type> )  . . . . . . . . . . mutable type of internal type
*/


/****************************************************************************
**
*F  IMMUTABLE_TNUM( <type> )  . . . . . . . . immutable type of internal type
*/


/****************************************************************************
**
*F  IS_MUTABLE_OBJ( <obj> ) . . . . . . . . . . . . . .  is an object mutable
**
**  'IS_MUTABLE_OBJ' returns   1 if the object  <obj> is mutable   (i.e., can
**  change due to assignments), and 0 otherwise.
**
**  'IS_MUTABLE_OBJ' is defined in the declaration part of this package.
*/
Int (*IsMutableObjFuncs[ LAST_REAL_TNUM+1 ]) ( Obj obj );

Obj IsMutableObjFilt;

Int IsMutableObjError (
    Obj                 obj )
{
    ErrorQuit(
        "Panic: tried to test mutability of unknown type '%d'",
        (Int)TNUM_OBJ(obj), 0L );
    return 0;
}

Int IsMutableObjNot (
    Obj                 obj )
{
    return 0L;
}

Int IsMutableObjObject (
    Obj                 obj )
{
    return (DoFilter( IsMutableObjFilt, obj ) == True);
}


/****************************************************************************
**
*F  IsMutableObjHandler( <self>, <obj> )  . . .  handler for 'IS_MUTABLE_OBJ'
*/
Obj IsMutableObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return (IS_MUTABLE_OBJ( obj ) ? True : False);
}


/****************************************************************************
**
*F  IS_COPYABLE_OBJ(<obj>)  . . . . . . . . . . . . . . is an object copyable
**
**  'IS_COPYABLE_OBJ' returns 1 if the object <obj> is copyable (i.e., can be
**  copied into a mutable object), and 0 otherwise.
**
**  'IS_COPYABLE_OBJ' is defined in the declaration part of this package.
*/
Int (*IsCopyableObjFuncs[ LAST_REAL_TNUM+1 ]) ( Obj obj );

Obj IsCopyableObjFilt;

Int IsCopyableObjError (
    Obj                 obj )
{
    ErrorQuit(
        "Panic: tried to test copyability of unknown type '%d'",
        (Int)TNUM_OBJ(obj), 0L );
    return 0L;
}

Int IsCopyableObjNot (
    Obj                 obj )
{
    return 0L;
}

Int IsCopyableObjObject (
    Obj                 obj )
{
    return (DoFilter( IsCopyableObjFilt, obj ) == True);
}


/****************************************************************************
**
*F  IsCopyableObjHandler( <self>, <obj> ) . . . handler for 'IS_COPYABLE_OBJ'
*/
Obj IsCopyableObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return (IS_COPYABLE_OBJ( obj ) ? True : False);
}


/****************************************************************************
**

*F  SHALLOW_COPY_OBJ( <obj> ) . . . . . . .  make a shallow copy of an object
**
**  'SHALLOW_COPY_OBJ' makes a shallow copy of the object <obj>.
**
**  'SHALLOW_COPY_OBJ' is defined in the  declaration part of this package as
**  follows
**
#define SHALLOW_COPY_OBJ(obj) \
                        ((*ShallowCopyObjFuncs[ TNUM_OBJ(obj) ])( obj ))
*/


/****************************************************************************
**
*V  ShallowCopyObjFuncs[<type>] . . . . . . . . . .  shallow copier functions
*/
Obj (*ShallowCopyObjFuncs[ LAST_REAL_TNUM+1 ]) ( Obj obj );

Obj ShallowCopyObjOper;


/****************************************************************************
**
*F  ShallowCopyObjError( <obj> )  . . . . . . . . . . . . . . .  unknown type
*/
Obj ShallowCopyObjError (
    Obj                 obj )
{
    ErrorQuit(
        "Panic: tried to shallow copy object of unknown type '%d'",
        (Int)TNUM_OBJ(obj), 0L );
    return (Obj)0;
}


/****************************************************************************
**
*F  ShallowCopyObjConstant( <obj> ) . . . . . . . . . . . . . . .  do nothing
*/
Obj ShallowCopyObjConstant (
    Obj                 obj )
{
    return obj;
}


/****************************************************************************
**
*F  ShallowCopyObjObject( <obj> ) . . . . . . . . . . . . . . . . call method
*/
Obj ShallowCopyObjObject (
    Obj                 obj )
{
    return DoOperation1Args( ShallowCopyObjOper, obj );
}


/****************************************************************************
**
*F  ShallowCopyObjDefault( <obj> )  . . . . . . . . . .  default shallow copy
*/
Obj ShallowCopyObjDefault (
    Obj                 obj )
{
    Obj                 new;
    Obj *               o;
    Obj *               n;
    UInt                len;
    UInt                i;

    /* make the new object and copy the contents                           */
    len = (SIZE_OBJ( obj ) + sizeof(Obj)-1) / sizeof(Obj);
    new = NewBag( MUTABLE_TNUM(TNUM_OBJ(obj)), SIZE_OBJ(obj) );
    o = ADDR_OBJ( obj );
    n = ADDR_OBJ( new );
    for ( i = 0; i < len; i++ ) {
        *n++ = *o++;
    }

    /* 'CHANGED_BAG(new);' not needed, <new> is newest object              */
    return new;
}


/****************************************************************************
**
*F  ShallowCopyObjHandler( <self>, <obj> )  .  handler for 'SHALLOW_COPY_OBJ'
*/
Obj ShallowCopyObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return SHALLOW_COPY_OBJ( obj );
}


/****************************************************************************
**

*F  CopyObj( <obj>, <mut> ) . . . . . . . make a structural copy of an object
**
**  'CopyObj' only calls 'COPY_OBJ' and then 'CLEAN_OBJ'.
*/
Obj CopyObj (
    Obj                 obj,
    Int                 mut )
{
    Obj                 new;            /* copy of <obj>                   */

    /* make a copy                                                         */
    new = COPY_OBJ( obj, mut );

    /* clean up the marks                                                  */
    CLEAN_OBJ( obj );

    /* return the copy                                                     */
    return new;
}


/****************************************************************************
**
*F  COPY_OBJ( <obj>, <mut> )  . . . . . . make a structural copy of an object
**
**  'COPY_OBJ' calls the    function pointed to   by  'CopyObjFuncs[<type>]',
**  passing <obj> as argument.  If <type> is the type  of an constant object,
**  then  'CopyObjFuncs[<type>]' points   to  'CopyObjConstant',  which  just
**  returns <obj>, since those objects need not be copied.
**
**  'COPY_OBJ' is defined in the declaration part of this package as follows
**
#define COPY_OBJ(obj,mut) \
    ((*CopyObjFuncs[ TNUM_OBJ(obj) ])( obj, mut ))
*/


/****************************************************************************
**
*V  CopyObjFuncs[<type>]  . . . . . . . . . . . .  table of copying functions
*/
Obj (*CopyObjFuncs[ LAST_REAL_TNUM+COPYING+1 ]) ( Obj obj, Int mut );


/****************************************************************************
**
*F  CLEAN_OBJ( <obj> )  . . . . . . . . . . . . clean up object after copying
**
**  'CLEAN_OBJ' calls  the  function pointed to   by 'CleanObjFuncs[<type>]',
**  passing <obj> as argument.  If <type> is the type  of an constant object,
**  then  'CleanObjFuncs[<type>]'   points to  'CopyObjConstant', which  does
**  nothing, since those objects need not be copied.
**
**  'CLEAN_OBJ' is defined in the declaration part of this package as follows
**
#define CLEAN_OBJ(obj) \
    ((*CleanObjFuncs[ TNUM_OBJ(obj) ])( obj ))
*/


/****************************************************************************
**
*V  CleanObjFuncs[<type>] . . . . . . . . . . . . table of cleaning functions
*/
void (*CleanObjFuncs[ LAST_REAL_TNUM+COPYING+1 ]) ( Obj obj );


/****************************************************************************
**
*F  CopyObjError( <obj> ) . . . . . . . . . . . . . . . . . . .  unknown type
*/
Obj             CopyObjError (
    Obj                 obj,
    Int                 mut )
{
    ErrorQuit(
        "Panic: tried to copy object of unknown type '%d'",
        (Int)TNUM_OBJ(obj), 0L );
    return (Obj)0;
}


/****************************************************************************
**
*F  CleanObjError( <obj> )  . . . . . . . . . . . . . . . . . .  unknown type
*/
void CleanObjError (
    Obj                 obj )
{
    ErrorQuit(
        "Panic: tried to clean object of unknown type '%d'",
        (Int)TNUM_OBJ(obj), 0L );
}


/****************************************************************************
**
*F  CopyObjConstant( <obj> )  . . . . . . . . . . . .  copy a constant object
*/
Obj CopyObjConstant (
    Obj                 obj,
    Int                 mut )
{
    return obj;
}


/****************************************************************************
**
*F  CleanObjConstant(<obj>) . . . . . . . . . . . . . clean a constant object
*/
void CleanObjConstant (
    Obj                 obj )
{
}


/****************************************************************************
**
*F  CopyObjPosObj( <obj>, <mut> ) . . . . . . . . .  copy a positional object
*/
Obj CopyObjPosObj (
    Obj                 obj,
    Int                 mut )
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    UInt                i;              /* loop variable                   */

    /* don't change immutable objects                                      */
    if ( ! IS_MUTABLE_OBJ(obj) ) {
        return obj;
    }

    /* if the object is not copyable return                                */
    if ( ! IS_COPYABLE_OBJ(obj) ) {
        ErrorQuit("Panic: encountered mutable, non-copyable object",0L,0L);
        return obj;
    }

    /* make a copy                                                         */
    if ( mut ) {
        copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
        ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
    }
    else {
        copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
        ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
        CALL_2ARGS( RESET_FILTER_OBJ, copy, IsMutableObjFilt );
    }

    /* leave a forwarding pointer                                          */
    tmp = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( tmp, 2 );
    SET_ELM_PLIST( tmp, 1, ADDR_OBJ(obj)[0] );
    SET_ELM_PLIST( tmp, 2, copy );
    ADDR_OBJ(obj)[0] = tmp;
    CHANGED_BAG(obj);

    /* now it is copied                                                    */
    RetypeBag( obj, TNUM_OBJ(obj) + COPYING );

    /* copy the subvalues                                                  */
    for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i++ ) {
        if ( ADDR_OBJ(obj)[i] != 0 ) {
            tmp = COPY_OBJ( ADDR_OBJ(obj)[i], mut );
            ADDR_OBJ(copy)[i] = tmp;
            CHANGED_BAG( copy );
        }
    }

    /* return the copy                                                     */
    return copy;
}


/****************************************************************************
**
*F  CleanObjPosObj( <obj> ) . . . . . . . . . . . . . . . . . .  clean posobj
*/
void CleanObjPosObj (
    Obj                 obj )
{
}


/****************************************************************************
**
*F  CopyObjPosObjCopy( <obj>, <mut> ) . . . . . . . . . .  copy a posobj copy
*/
Obj CopyObjPosObjCopy (
    Obj                 obj,
    Int                 mut )
{
    return ELM_PLIST( ADDR_OBJ(obj)[0], 2 );
}


/****************************************************************************
**
*F  CleanObjPosObjCopy( <obj> ) . . . . . . . . . . . . . . clean posobj copy
*/
void CleanObjPosObjCopy (
    Obj                 obj )
{
    UInt                i;              /* loop variable                   */

    /* remove the forwarding pointer                                       */
    ADDR_OBJ(obj)[0] = ELM_PLIST( ADDR_OBJ(obj)[0], 1 );
    CHANGED_BAG(obj);

    /* now it is cleaned                                                   */
    RetypeBag( obj, TNUM_OBJ(obj) - COPYING );

    /* clean the subvalues                                                 */
    for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i++ ) {
        if ( ADDR_OBJ(obj)[i] != 0 )
            CLEAN_OBJ( ADDR_OBJ(obj)[i] );
    }

}


/****************************************************************************
**
*F  CopyObjComObj( <obj>, <mut> ) . . . . . . . . . . . . . . . copy a comobj
*/
Obj CopyObjComObj (
    Obj                 obj,
    Int                 mut )
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    UInt                i;              /* loop variable                   */

    /* don't change immutable objects                                      */
    if ( ! IS_MUTABLE_OBJ(obj) ) {
        return obj;
    }

    /* if the object is not copyable return                                */
    if ( ! IS_COPYABLE_OBJ(obj) ) {
        ErrorQuit("Panic: encountered mutable, non-copyable object",0L,0L);
        return obj;
    }

    /* make a copy                                                         */
    if ( mut ) {
        copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
        ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
    }
    else {
        copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
        ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
        CALL_2ARGS( RESET_FILTER_OBJ, copy, IsMutableObjFilt );
    }

    /* leave a forwarding pointer                                          */
    tmp = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( tmp, 2 );
    SET_ELM_PLIST( tmp, 1, ADDR_OBJ(obj)[0] );
    SET_ELM_PLIST( tmp, 2, copy );
    ADDR_OBJ(obj)[0] = tmp;
    CHANGED_BAG(obj);

    /* now it is copied                                                    */
    RetypeBag( obj, TNUM_OBJ(obj) + COPYING );

    /* copy the subvalues                                                  */
    for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i += 2 ) {
        tmp = ADDR_OBJ(obj)[i];
        ADDR_OBJ(copy)[i] = tmp;
        tmp = COPY_OBJ( ADDR_OBJ(obj)[i+1], mut );
        ADDR_OBJ(copy)[i+1] = tmp;
        CHANGED_BAG( copy );
    }

    /* return the copy                                                     */
    return copy;
}


/****************************************************************************
**
*F  CleanObjComObj( <obj> ) . . . . . . . . . . . . . . . . .  clean a comobj
*/
void CleanObjComObj (
    Obj                 obj )
{
}


/****************************************************************************
**
*F  CopyObjComObjCopy( <obj>, <mut> ) . . . . . . . . . .  copy a comobj copy
*/
Obj CopyObjComObjCopy (
    Obj                 obj,
    Int                 mut )
{
    return ELM_PLIST( ADDR_OBJ(obj)[0], 2 );
}


/****************************************************************************
**
*F  CleanObjComObjCopy( <obj> ) . . . . . . . . . . . . . clean a comobj copy
*/
void CleanObjComObjCopy (
    Obj                 obj )
{
    UInt                i;              /* loop variable                   */

    /* remove the forwarding pointer                                       */
    ADDR_OBJ(obj)[0] = ELM_PLIST( ADDR_OBJ(obj)[0], 1 );
    CHANGED_BAG(obj);

    /* now it is cleaned                                                   */
    RetypeBag( obj, TNUM_OBJ(obj) - COPYING );

    /* clean the subvalues                                                 */
    for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i += 2 ) {
        CLEAN_OBJ( ADDR_OBJ(obj)[i+1] );
    }

}


/****************************************************************************
**
*F  CopyObjDatObj( <obj>, <mut> ) . . . . . . . . . . . . . . . copy a datobj
*/
Obj CopyObjDatObj (
    Obj                 obj,
    Int                 mut )
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    UInt                i;              /* loop variable                   */
    Int               * src;
    Int               * dst;

    /* don't change immutable objects                                      */
    if ( ! IS_MUTABLE_OBJ(obj) ) {
        return obj;
    }

    /* if the object is not copyable return                                */
    if ( ! IS_COPYABLE_OBJ(obj) ) {
        ErrorQuit("Panic: encountered mutable, non-copyable object",0L,0L);
        return obj;
    }

    /* make a copy                                                         */
    if ( mut ) {
        copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
        ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
    }
    else {
        copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
        ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
        CALL_2ARGS( RESET_FILTER_OBJ, copy, IsMutableObjFilt );
    }

    /* leave a forwarding pointer                                          */
    tmp = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( tmp, 2 );
    SET_ELM_PLIST( tmp, 1, ADDR_OBJ(obj)[0] );
    SET_ELM_PLIST( tmp, 2, copy );
    ADDR_OBJ(obj)[0] = tmp;
    CHANGED_BAG(obj);

    /* now it is copied                                                    */
    RetypeBag( obj, TNUM_OBJ(obj) + COPYING );

    /* copy the subvalues                                                  */
    src = (Int*)( ADDR_OBJ(obj) + 1 );
    dst = (Int*)( ADDR_OBJ(copy) + 1 );
    i   = (SIZE_OBJ(obj)-sizeof(Obj)+sizeof(Int)-1) / sizeof(Int);
    for ( ;  0 < i;  i--, src++, dst++ ) {
        *dst = *src;
    }
    CHANGED_BAG(copy);

    /* return the copy                                                     */
    return copy;
}


/****************************************************************************
**
*F  CleanObjDatObj( <obj> ) . . . . . . . . . . . . . . . . .  clean a datobj
*/
void CleanObjDatObj (
    Obj                 obj )
{
}


/****************************************************************************
**
*F  CopyObjDatObjCopy( <obj>, <mut> ) . . . . . . . . . .  copy a datobj copy
*/
Obj CopyObjDatObjCopy (
    Obj                 obj,
    Int                 mut )
{
    return ELM_PLIST( ADDR_OBJ(obj)[0], 2 );
}


/****************************************************************************
**
*F  CleanObjDatObjCopy( <obj> ) . . . . . . . . . . . . . clean a datobj copy
*/
void CleanObjDatObjCopy (
    Obj                 obj )
{
    /* remove the forwarding pointer                                       */
    ADDR_OBJ(obj)[0] = ELM_PLIST( ADDR_OBJ(obj)[0], 1 );
    CHANGED_BAG(obj);

    /* now it is cleaned                                                   */
    RetypeBag( obj, TNUM_OBJ(obj) - COPYING );
}


/****************************************************************************
**

*F  ImmutableCopyObjHandler( <self>, <obj> )  . . . . immutable copy of <obj>
*/
Obj ImmutableCopyObjFunc;

Obj ImmutableCopyObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return CopyObj( obj, 0 );
}


/****************************************************************************
**
*F  MutableCopyObjHandler( <self>, <obj> )  . . . . . . mutable copy of <obj>
*/
Obj MutableCopyObjFunc;

Obj MutableCopyObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return CopyObj( obj, 1 );
}


/****************************************************************************
**

*F  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
**
**  'PrintObj' prints the object <obj>.
*/
Obj PrintObjThis;

Int PrintObjIndex;

Int PrintObjFull;

Int PrintObjDepth;

Obj PrintObjThiss [1024];

Int PrintObjIndices [1024];

#define IS_MARKABLE(obj)    (FIRST_RECORD_TNUM <= TNUM_OBJ(obj) \
                            && TNUM_OBJ(obj) <= LAST_LIST_TNUM)

#define IS_MARKED(obj)      (FIRST_PRINTING_TNUM <= TNUM_OBJ(obj) \
                            && TNUM_OBJ(obj) <= LAST_PRINTING_TNUM)

#define MARK(obj)           RetypeBag( obj, TNUM_OBJ(obj)+PRINTING )

#define UNMARK(obj)         RetypeBag( obj, TNUM_OBJ(obj)-PRINTING )

void            PrintObj (
    Obj                 obj )
{
    Int                 i;              /* loop variable                   */

    /* check for interrupts                                                */
    if ( SyIsIntr() ) {
        i = PrintObjDepth;
        PrintObjDepth = 0;
        Pr( "%c%c", (Int)'\03', (Int)'\04' );
        ErrorReturnVoid(
            "user interrupt while printing",
            0L, 0L,
            "you can return" );
        PrintObjDepth = i;
    }

    /* if <obj> is a subobject, then mark and remember the superobject     */
    if ( 0 < PrintObjDepth ) {
        if ( IS_MARKABLE(PrintObjThis) )  MARK( PrintObjThis );
        PrintObjThiss[PrintObjDepth-1]   = PrintObjThis;
        PrintObjIndices[PrintObjDepth-1] = PrintObjIndex;
    }

    /* handle the <obj>                                                    */
    PrintObjDepth += 1;
    PrintObjThis   = obj;
    PrintObjIndex  = 0;

    /* dispatch to the appropriate printing function                       */
    if ( ! IS_MARKED( PrintObjThis ) ) {
        (*PrintObjFuncs[ TNUM_OBJ(PrintObjThis) ])( PrintObjThis );
    }

    /* or print the path                                                   */
    else {
        Pr( "~", 0L, 0L );
        for ( i = 0; PrintObjThis != PrintObjThiss[i]; i++ ) {
            (*PrintPathFuncs[ TNUM_OBJ(PrintObjThiss[i])-PRINTING ])
                ( PrintObjThiss[i], PrintObjIndices[i] );
        }
    }

    /* done with <obj>                                                     */
    PrintObjDepth -= 1;

    /* if <obj> is a subobject, then restore and unmark the superobject    */
    if ( 0 < PrintObjDepth ) {
        PrintObjThis  = PrintObjThiss[PrintObjDepth-1];
        PrintObjIndex = PrintObjIndices[PrintObjDepth-1];
        if ( IS_MARKED(PrintObjThis) )  UNMARK( PrintObjThis );
    }

}



/****************************************************************************
**
*V  PrintObjFuncs[<type>] . . . . . . . .  printer for objects of type <type>
**
**  'PrintObjFuncs' is  the dispatch  table that  contains  for every type of
**  objects a pointer to the printer for objects of this  type.  The  printer
**  is the function '<func>(<obj>)' that should be called to print the object
**  <obj> of this type.
*/
void (* PrintObjFuncs [ LAST_REAL_TNUM+PRINTING+1 ])( Obj obj );


/****************************************************************************
**
*F  PrintObjObject( <obj> ) . . . . . . . . . . . . . . . . . print an object
*/
Obj PrintObjOper;

void PrintObjObject (
    Obj                 obj )
{
    DoOperation1Args( PrintObjOper, obj );
}


/****************************************************************************
**
*F  PrintObjHandler( <self>, <obj> )  . . . . . . . .  handler for 'PrintObj'
*/
Obj PrintObjHandler (
    Obj                 self,
    Obj                 obj )
{
    PrintObj( obj );
    return 0L;
}


/****************************************************************************
**
*V  PrintPathFuncs[<type>]  . . . . . . printer for subobjects of type <type>
**
**  'PrintPathFuncs'  is   the   dispatch table  that     contains for  every
**  appropriate type of objects a pointer to  the path printer for objects of
**  that type.  The path  printer is the function '<func>(<obj>,<indx>)' that
**  should be  called  to print  the  selector   that selects  the  <indx>-th
**  subobject of the object <obj> of this type.
*/
void (* PrintPathFuncs [ LAST_REAL_TNUM+PRINTING+1 ])( Obj obj, Int indx );

void PrintPathError (
    Obj                 obj,
    Int                 indx )
{
    ErrorQuit(
        "Panic: tried to print a path of unknown type '%d'",
        (Int)TNUM_OBJ(obj), 0L );
}


/****************************************************************************
**

*F  IS_COMOBJ( <obj> )  . . . . . . . . . . . is an object a component object
**
**  'IS_COMOBJ' is defined in the declaration part of this package as follows
**
#define IS_COMOBJ(obj)            (TNUM_OBJ(obj) == T_COMOBJ)
*/


/****************************************************************************
**
*F  TYPE_COMOBJ( <obj> )  . . . . . . . . . . . .  kind of a component object
**
**  'TYPE_COMOBJ'  is defined in  the  declaration part   of this package  as
**  follows
**
#define TYPE_COMOBJ(obj)          (ADDR_OBJ(obj)[0])
*/


/****************************************************************************
**
*F  SET_TYPE_COMOBJ( <obj>, <val> ) . . .  set the kind of a component object
**
**  'SET_TYPE_COMOBJ'  is defined in the  declaration part of this package as
**  follows
**
#define SET_TYPE_COMOBJ(obj,val)  (ADDR_OBJ(obj)[0] = (val))
*/


/****************************************************************************
**
*F  TypeComObj( <obj> ) . . . . . . . . . . function version of 'TYPE_COMOBJ'
*/
Obj             TypeComObj (
    Obj                 obj )
{
    return TYPE_COMOBJ( obj );
}


/*****************************************************************************
**
*F  IS_COMOBJ_Hander( <self>, <obj> ) . . . . . . . . handler for 'IS_COMOBJ'
*/
Obj             IS_COMOBJ_Func;

Obj             IS_COMOBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
    return (TNUM_OBJ(obj) == T_COMOBJ ? True : False);
}


/****************************************************************************
**
*F  SET_TYPE_COMOBJ_Handler( <self>, <obj>, <kind> ) . . .  'SET_TYPE_COMOBJ'
*/
Obj SET_TYPE_COMOBJ_Func;

Obj SET_TYPE_COMOBJ_Handler (
    Obj                 self,
    Obj                 obj,
    Obj                 kind )
{
    TYPE_COMOBJ( obj ) = kind;
    RetypeBag( obj, T_COMOBJ );
    CHANGED_BAG( obj );
    return obj;
}


/****************************************************************************
**

*F  IS_POSOBJ( <obj> )  . . . . . . . . . .  is an object a positional object
**
**  'IS_POSOBJ' is defined in the declaration part of this package as follows
**
#define IS_POSOBJ(obj)            (TNUM_OBJ(obj) == T_POSOBJ)
*/


/****************************************************************************
**
*F  TYPE_POSOBJ( <obj> )  . . . . . . . . . . . . kind of a positional object
**
**  'TYPE_POSOBJ'  is defined in  the  declaration part   of this package  as
**  follows
**
#define TYPE_POSOBJ(obj)          (ADDR_OBJ(obj)[0])
*/


/****************************************************************************
**
*F  SET_TYPE_POSOBJ( <obj>, <val> ) . . . set the kind of a positional object
**
**  'SET_TYPE_POSOBJ'  is defined in the  declaration part of this package as
**  follows
**
#define SET_TYPE_POSOBJ(obj,val)  (ADDR_OBJ(obj)[0] = (val))
*/


/****************************************************************************
**
*F  TypePosObj( <obj> ) . . . . . . . . . . function version of 'TYPE_POSOBJ'
*/
Obj TypePosObj (
    Obj                 obj )
{
    return TYPE_POSOBJ( obj );
}


/****************************************************************************
**
*F  IS_POSOBJ_Handler( <self>, <obj> )  . . . . . . . handler for 'IS_POSOBJ'
*/
Obj IS_POSOBJ_Func;

Obj IS_POSOBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
    return (TNUM_OBJ(obj) == T_POSOBJ ? True : False);
}


/****************************************************************************
**
*F  SET_TYPE_POSOBJ_Handler( <self>, <obj>, <kind> )  . . .  'SET_TYPE_POSOB'
*/
Obj SET_TYPE_POSOBJ_Func;

Obj SET_TYPE_POSOBJ_Handler (
    Obj                 self,
    Obj                 obj,
    Obj                 kind )
{
    TYPE_POSOBJ( obj ) = kind;
    RetypeBag( obj, T_POSOBJ );
    CHANGED_BAG( obj );
    return obj;
}


/****************************************************************************
**
*F  LEN_POSOBJ_Handler( <self>, <obj> ) . . . . . .  handler for 'LEN_POSOBJ'
*/
Obj LEN_POSOBJ_Func;

Obj LEN_POSOBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
    return INTOBJ_INT( SIZE_OBJ(obj) / sizeof(Obj) - 1 );
}


/****************************************************************************
**

*F  IS_DATOBJ( <obj> )  . . . . . . . . . . . . .  is an object a data object
**
**  'IS_DATOBJ' is defined in the declaration part of this package as follows
**
#define IS_DATOBJ(obj)            (TNUM_OBJ(obj) == T_DATOBJ)
*/


/****************************************************************************
**
*F  TYPE_DATOBJ( <obj> )  . . . . . . . . . . . . . . . kind of a data object
**
**  'TYPE_DATOBJ'  is defined in  the  declaration part   of this package  as
**  follows
**
#define TYPE_DATOBJ(obj)          (ADDR_OBJ(obj)[0])
*/


/****************************************************************************
**
*F  SET_TYPE_DATOBJ( <obj>, <val> ) . . . . . . set the kind of a data object
**
**  'SET_TYPE_DATOBJ'  is defined in the  declaration part of this package as
**  follows
**
#define SET_TYPE_DATOBJ(obj,val)  (ADDR_OBJ(obj)[0] = (val))
*/


/****************************************************************************
**
*F  TypeDatObj( <obj> ) . . . . . . . . . . function version of 'TYPE_DATOBJ'
*/
Obj             TypeDatObj (
    Obj                 obj )
{
    return TYPE_DATOBJ( obj );
}


/*****************************************************************************
**
*F  IS_DATOBJ_Hander( <self>, <obj> ) . . . . . . . . handler for 'IS_DATOBJ'
*/
Obj             IS_DATOBJ_Func;

Obj             IS_DATOBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
    return (TNUM_OBJ(obj) == T_DATOBJ ? True : False);
}


/****************************************************************************
**
*F  SET_TYPE_DATOBJ_Handler( <self>, <obj>, <kind> ) . . .  'SET_TYPE_DATOBJ'
*/
Obj SET_TYPE_DATOBJ_Func;

Obj SET_TYPE_DATOBJ_Handler (
    Obj                 self,
    Obj                 obj,
    Obj                 kind )
{
    TYPE_DATOBJ( obj ) = kind;
    RetypeBag( obj, T_DATOBJ );
    CHANGED_BAG( obj );
    return obj;
}


/****************************************************************************
**

*F  IsIdenticalHandler( <self>, <obj1>, <obj2> )  . . . . .  handler for '=='
**
**  'IsIdenticalHandler' implements 'IsIdentical'
*/
Obj IsIdenticalFunc;

Obj IsIdenticalHandler (
    Obj                 self,
    Obj                 obj1,
    Obj                 obj2 )
{
    return (obj1 == obj2 ? True : False);
}

/****************************************************************************
**
*V  SaveObjFuncs (<type>) . . . . . . . . . . . . . functions to save objects
**
** 'SaveObjFuncs' is the dispatch table that  contains, for every type
**  of  objects, a pointer to the saving function for objects of that type
**  These should not handle the file directly, but should work via the
**  functions 'SaveObjRef', 'SaveUInt<n>' (<n> = 1,2,4 or 8), and others
**  to be determined. Their role is to identify the C types of the various
**  parts of the bag, and perhaps to leave out some information that does
**  not need to be saved. By the time this function is called, the bag
**  size and type have already been saved
**  No saving function may allocate any bag
*/

void (*SaveObjFuncs[ LAST_REAL_TNUM + 1]) (Obj obj);

void SaveObjError (
		   Obj obj
		   )
{
  ErrorQuit(
	    "Panic: tried to save an object of unknown type '%d'",
	    (Int)TNUM_OBJ(obj), 0L );
}
    
		   
     
     
/****************************************************************************
**
*V  LoadObjFuncs (<type>) . . . . . . . . . . . . . functions to load objects
**
** 'LoadObjFuncs' is the dispatch table that  contains, for every type
**  of  objects, a pointer to the loading function for objects of that type
**  These should not handle the file directly, but should work via the
**  functions 'LoadObjRef', 'LoadUInt<n>' (<n> = 1,2,4 or 8), and others
**  to be determined. Their role is to reinstall the information in the bag
**  and reconstruct anything that was left out. By the time this function is
**  called, the bag size and type have already been loaded and the bag argument
**  contains the bag in question
**  No loading function may allocate any bag
*/

void (*LoadObjFuncs[ LAST_REAL_TNUM + 1]) (Obj obj, Bag bag);

void LoadObjError (
		   Obj obj,
		   Bag bag
		   )
{
  ErrorQuit(
	    "Panic: tried to loade an object of unknown type '%d'",
	    (Int)TNUM_OBJ(obj), 0L );
}



/****************************************************************************
**

*F  InitObjects() . . . . . . . . . . . . . .  initialize the objects package
**
** 'InitObjects' initializes the objects package.
*/
void InitObjects ( void )
{

  Int                 t;              /* loop variable                   */

    /* make and install the 'FAMILY_TYPE' function                         */
    InitHandlerFunc( FamilyTypeHandler, "FAMILY_TYPE" );
    FamilyTypeFunc = NewFunctionC(
        "FAMILY_TYPE", 1L, "kind", FamilyTypeHandler );
    AssGVar( GVarName( "FAMILY_TYPE" ), FamilyTypeFunc );


    /* make and install the 'TYPE_OBJ' function                            */
    InitHandlerFunc( TypeObjHandler, "TYPE_OBJ" );
    TypeObjFunc = NewFunctionC(
        "TYPE_OBJ", 1L, "obj", TypeObjHandler );
    AssGVar( GVarName( "TYPE_OBJ" ), TypeObjFunc );

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ )
        TypeObjFuncs[ t ] = TypeObjError;


    /* make and install the 'FAMILY_OBJ' function                          */
    InitHandlerFunc( FamilyObjHandler, "FAMILY_OBJ" );
    FamilyObjFunc = NewFunctionC(
        "FAMILY_OBJ", 1L, "obj", FamilyObjHandler );
    AssGVar( GVarName( "FAMILY_OBJ" ), FamilyObjFunc );


    /* make and install the 'IS_MUTABLE_OBJ' filter                        */
    InitHandlerFunc( IsMutableObjHandler, "IS_MUTABLE_OBJ" );
    IsMutableObjFilt = NewFilterC(
        "IS_MUTABLE_OBJ", 1L, "obj", IsMutableObjHandler );
    AssGVar( GVarName( "IS_MUTABLE_OBJ" ),
        IsMutableObjFilt );

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ )
        IsMutableObjFuncs[ t ] = IsMutableObjError;
    for ( t = FIRST_CONSTANT_TNUM; t <= LAST_CONSTANT_TNUM; t++ )
        IsMutableObjFuncs[ t ] = IsMutableObjNot;
    for ( t = FIRST_EXTERNAL_TNUM; t <= LAST_EXTERNAL_TNUM; t++ )
        IsMutableObjFuncs[ t ] = IsMutableObjObject;


    /* make and install the 'IS_COPYABLE_OBJ' filter                       */
    InitHandlerFunc( IsCopyableObjHandler, "IS_COPYABLE_OBJ" );
    IsCopyableObjFilt = NewFilterC(
        "IS_COPYABLE_OBJ", 1L, "obj", IsCopyableObjHandler );
    AssGVar( GVarName( "IS_COPYABLE_OBJ" ),
        IsCopyableObjFilt );

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ )
        IsCopyableObjFuncs[ t ] = IsCopyableObjError;
    for ( t = FIRST_CONSTANT_TNUM; t <= LAST_CONSTANT_TNUM; t++ )
        IsCopyableObjFuncs[ t ] = IsCopyableObjNot;
    for ( t = FIRST_EXTERNAL_TNUM; t <= LAST_EXTERNAL_TNUM; t++ )
        IsCopyableObjFuncs[ t ] = IsCopyableObjObject;


    /* make and install the 'SHALLOW_COPY_OBJ' operation                   */
    InitHandlerFunc( ShallowCopyObjHandler, "SHALLOW_COPY_OBJ" );
    ShallowCopyObjOper = NewOperationC(
        "SHALLOW_COPY_OBJ", 1L, "obj", ShallowCopyObjHandler );
    AssGVar( GVarName( "SHALLOW_COPY_OBJ" ),
        ShallowCopyObjOper );

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjError;
    for ( t = FIRST_CONSTANT_TNUM; t <= LAST_CONSTANT_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjConstant;
    for ( t = FIRST_RECORD_TNUM; t <= LAST_RECORD_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjDefault;
    for ( t = FIRST_LIST_TNUM; t <= LAST_LIST_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjDefault;
    for ( t = FIRST_EXTERNAL_TNUM; t <= LAST_EXTERNAL_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjObject;


    /* make and install the 'COPY_OBJ' function                            */
    InitHandlerFunc( ImmutableCopyObjHandler, "IMMUTABLE_COPY_OBJ" );
    ImmutableCopyObjFunc = NewFunctionC(
        "IMMUTABLE_COPY_OBJ", 1L, "obj", ImmutableCopyObjHandler );
    AssGVar( GVarName( "IMMUTABLE_COPY_OBJ" ),
        ImmutableCopyObjFunc );
    InitHandlerFunc( MutableCopyObjHandler, "DEEP_COPY_OBJ" );

    MutableCopyObjFunc = NewFunctionC(
        "DEEP_COPY_OBJ", 1L, "obj", MutableCopyObjHandler );
    AssGVar( GVarName( "DEEP_COPY_OBJ" ),
        MutableCopyObjFunc );

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        CopyObjFuncs [ t ] = CopyObjError;
        CleanObjFuncs[ t ] = CleanObjError;
    }
    for ( t = FIRST_CONSTANT_TNUM; t <= LAST_CONSTANT_TNUM; t++ ) {
        CopyObjFuncs [ t ] = CopyObjConstant;
        CleanObjFuncs[ t ] = CleanObjConstant;
    }
    CopyObjFuncs[  T_POSOBJ           ] = CopyObjPosObj;
    CopyObjFuncs[  T_POSOBJ + COPYING ] = CopyObjPosObjCopy;
    CleanObjFuncs[ T_POSOBJ           ] = CleanObjPosObj;
    CleanObjFuncs[ T_POSOBJ + COPYING ] = CleanObjPosObjCopy;
    CopyObjFuncs[  T_COMOBJ           ] = CopyObjComObj;
    CopyObjFuncs[  T_COMOBJ + COPYING ] = CopyObjComObjCopy;
    CleanObjFuncs[ T_COMOBJ           ] = CleanObjComObj;
    CleanObjFuncs[ T_COMOBJ + COPYING ] = CleanObjComObjCopy;
    CopyObjFuncs[  T_DATOBJ           ] = CopyObjDatObj;
    CopyObjFuncs[  T_DATOBJ + COPYING ] = CopyObjDatObjCopy;
    CleanObjFuncs[ T_DATOBJ           ] = CleanObjDatObj;
    CleanObjFuncs[ T_DATOBJ + COPYING ] = CleanObjDatObjCopy;


    /* make and install the 'PRINT_OBJ' operation                          */
    InitHandlerFunc( PrintObjHandler, "PRINT_OBJ" );
    PrintObjOper = NewOperationC(
        "PRINT_OBJ", 1L, "obj", PrintObjHandler );
    AssGVar( GVarName( "PRINT_OBJ" ), PrintObjOper );

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM+PRINTING; t++ )
        PrintObjFuncs[ t ] = PrintObjObject;

    /* enter 'PrintUnknownObj' in the dispatching tables                   */
    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM+PRINTING; t++ )
        PrintPathFuncs[ t ] = PrintPathError;

    /* enter 'SaveObjError' and 'LoadObjError' for all types initially     */

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ )
      {
	SaveObjFuncs[ t ] = SaveObjError;
	LoadObjFuncs[ t ] = LoadObjError;
      }
  
    /* make and install the 'IS_IDENTICAL_OBJ' function                    */
    InitHandlerFunc( IsIdenticalHandler, "IS_IDENTICAL_OBJ" );
    IsIdenticalFunc = NewFunctionC(
        "IS_IDENTICAL_OBJ", 2, "obj1, obj2", IsIdenticalHandler );
    AssGVar( GVarName( "IS_IDENTICAL_OBJ" ), IsIdenticalFunc );


    /* install the marking methods                                         */
    InfoBags[         T_COMOBJ          ].name = "object (component)";
    InitMarkFuncBags( T_COMOBJ          , MarkAllSubBags  );
    InfoBags[         T_COMOBJ +COPYING ].name = "object (component,copied)";
    InitMarkFuncBags( T_COMOBJ +COPYING , MarkAllSubBags  );
    InfoBags[         T_POSOBJ          ].name = "object (positional)";
    InitMarkFuncBags( T_POSOBJ          , MarkAllSubBags  );
    InfoBags[         T_POSOBJ +COPYING ].name = "object (positional,copied)";
    InitMarkFuncBags( T_POSOBJ +COPYING , MarkAllSubBags  );
    InfoBags[         T_DATOBJ          ].name = "object (data,copied)";
    InitMarkFuncBags( T_DATOBJ          , MarkOneSubBags  );
    InfoBags[         T_DATOBJ +COPYING ].name = "object (data,copied)";
    InitMarkFuncBags( T_DATOBJ +COPYING , MarkOneSubBags  );


    /* install the kind methods                                            */
    TypeObjFuncs[ T_COMOBJ ] = TypeComObj;
    TypeObjFuncs[ T_POSOBJ ] = TypePosObj;
    TypeObjFuncs[ T_DATOBJ ] = TypeDatObj;


    /* make and install the functions for low level accessing of objects   */
    InitHandlerFunc( IS_COMOBJ_Handler, "IS_COMOBJ" );
    IS_COMOBJ_Func = NewFunctionC(
        "IS_COMOBJ", 1L, "obj", IS_COMOBJ_Handler );
    AssGVar( GVarName( "IS_COMOBJ" ), IS_COMOBJ_Func );
    
    InitHandlerFunc( SET_TYPE_COMOBJ_Handler, "SET_TYPE_COMOBJ" );
    SET_TYPE_COMOBJ_Func = NewFunctionC(
        "SET_TYPE_COMOBJ", 2L, "obj, kind", SET_TYPE_COMOBJ_Handler );
    AssGVar( GVarName( "SET_TYPE_COMOBJ" ), SET_TYPE_COMOBJ_Func );
    
    InitHandlerFunc( IS_POSOBJ_Handler, "IS_POSOBJ" );
    IS_POSOBJ_Func = NewFunctionC(
        "IS_POSOBJ", 1L, "obj", IS_POSOBJ_Handler );
    AssGVar( GVarName( "IS_POSOBJ" ), IS_POSOBJ_Func );
    
    InitHandlerFunc( SET_TYPE_POSOBJ_Handler, "SET_TYPE_POSOBJ" );
    SET_TYPE_POSOBJ_Func = NewFunctionC(
        "SET_TYPE_POSOBJ", 2L, "obj, kind", SET_TYPE_POSOBJ_Handler );
    AssGVar( GVarName( "SET_TYPE_POSOBJ" ), SET_TYPE_POSOBJ_Func );
    
    InitHandlerFunc( LEN_POSOBJ_Handler, "LEN_POSOBJ" );
    LEN_POSOBJ_Func = NewFunctionC(
        "LEN_POSOBJ", 1L, "obj", LEN_POSOBJ_Handler );
    AssGVar( GVarName( "LEN_POSOBJ" ), LEN_POSOBJ_Func );
    
    InitHandlerFunc( IS_DATOBJ_Handler, "IS_DATOBJ" );
    IS_DATOBJ_Func = NewFunctionC(
        "IS_DATOBJ", 1L, "obj", IS_DATOBJ_Handler );
    AssGVar( GVarName( "IS_DATOBJ" ), IS_DATOBJ_Func );
    
    InitHandlerFunc( SET_TYPE_DATOBJ_Handler, "SET_TYPE_DATOBJ" );
    SET_TYPE_DATOBJ_Func = NewFunctionC(
        "SET_TYPE_DATOBJ", 2L, "obj, kind", SET_TYPE_DATOBJ_Handler );
    AssGVar( GVarName( "SET_TYPE_DATOBJ" ), SET_TYPE_DATOBJ_Func );


    /* install the debug functions                                         */
    InitHandlerFunc( SIZE_OBJ_Handler, "SIZE_OBJ" );
    SIZE_OBJ_Func = NewFunctionC(
        "SIZE_OBJ", 1L, "obj", SIZE_OBJ_Handler );
    AssGVar( GVarName( "SIZE_OBJ" ), SIZE_OBJ_Func );    

    InitHandlerFunc( TNUM_OBJ_Handler, "TNUM_OBJ" );
    TNUM_OBJ_Func = NewFunctionC(
        "TNUM_OBJ", 1L, "obj", TNUM_OBJ_Handler );
    AssGVar( GVarName( "TNUM_OBJ" ), TNUM_OBJ_Func );
}


/****************************************************************************
**

*E  objects.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/

