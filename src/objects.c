/****************************************************************************
**
*W  objects.c                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the objects package.
*/
#include <stdlib.h>

#include <src/system.h>                 /* Ints, UInts, SyIsIntr */
#include <src/gapstate.h>


#include <src/sysfiles.h>               /* file input/output */

#include <src/gasman.h>                 /* garbage collector */

#include <src/objects.h>                /* objects */

#include <src/scanner.h>                /* scanner */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/bool.h>                   /* booleans */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/saveload.h>               /* saving and loading */

#include <src/hpc/aobjects.h>           /* atomic objects */
#include <src/code.h>                   /* coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/traverse.h>           /* object traversal */
#include <src/hpc/tls.h>                /* thread-local storage */

#include <src/gaputils.h>


static Int lastFreePackageTNUM = FIRST_PACKAGE_TNUM;

/****************************************************************************
**
*F  RegisterPackageTNUM( <name>, <typeObjFunc> )
**
**  Allocates a TNUM for use by a package. The parameters <name> and
**  <typeObjFunc> are used to initialize the relevant entries in the
**  InfoBags and TypeObjFuncs arrays.
**
**  If allocation fails (e.g. because no more TNUMs are available),
**  a negative value is returned.
*/
Int RegisterPackageTNUM( const char *name, Obj (*typeObjFunc)(Obj obj) )
{
#ifdef HPCGAP
    HashLock(0);
#endif

    if (lastFreePackageTNUM > LAST_PACKAGE_TNUM)
        return -1;

    Int tnum = lastFreePackageTNUM++;
#ifdef HPCGAP
    HashUnlock(0);
#endif

    InfoBags[tnum].name = name;
    TypeObjFuncs[tnum] = typeObjFunc;

    return tnum;
}


/****************************************************************************
**
*F  FamilyTypeHandler( <self>, <type> ) . . . . . . handler for 'FAMILY_TYPE'
*/
Obj FamilyTypeHandler (
    Obj                 self,
    Obj                 type )
{
    return FAMILY_TYPE( type );
}


/****************************************************************************
**
*F  FamilyObjHandler( <self>, <obj> ) . . . . . . .  handler for 'FAMILY_OBJ'
*/
Obj FamilyObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return FAMILY_OBJ( obj );
}


/****************************************************************************
**
*F  TYPE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . type of an object
**
**  'TYPE_OBJ' returns the type of the object <obj>.
**
**  'TYPE_OBJ' is defined in the declaration part of this package.
*/
Obj (*TypeObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

Obj TypeObjError (
    Obj                 obj )
{
    ErrorQuit( "Panic: basic object of type '%s' is unkind",
               (Int)TNAM_OBJ(obj), 0L );
    return 0;
}

/****************************************************************************
**
*F  SET_TYPE_OBJ( <obj> )  . . . . . . . . . . . . . . set type of an object
**
**  'SET_TYPE_OBJ' sets the type of the object <obj>.
*/

void (*SetTypeObjFuncs[ LAST_REAL_TNUM+1 ]) ( Obj obj, Obj type );

void SetTypeObjError ( Obj obj, Obj type )
{
    ErrorQuit( "Panic: cannot change type of object of type '%s'",
               (Int)TNAM_OBJ(obj), 0L );
}


/****************************************************************************
**
*F  TypeObjHandler( <self>, <obj> ) . . . . . . . . .  handler for 'TYPE_OBJ'
*/
#ifndef WARD_ENABLED
Obj TypeObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return TYPE_OBJ( obj );
}
#endif

/****************************************************************************
**
*F  SetTypeObjHandler( <self>, <obj>, <type> ) . . handler for 'SET_TYPE_OBJ'
*/
Obj SetTypeObjHandler (
    Obj                 self,
    Obj                 obj,
    Obj                 type )
{
    SET_TYPE_OBJ( obj, type );
    return (Obj) 0;
}



/****************************************************************************
**
*F  IS_MUTABLE_OBJ( <obj> ) . . . . . . . . . . . . . .  is an object mutable
**
**  'IS_MUTABLE_OBJ' returns   1 if the object  <obj> is mutable   (i.e., can
**  change due to assignments), and 0 otherwise.
**
**  'IS_MUTABLE_OBJ' is defined in the declaration part of this package.
*/
Int (*IsMutableObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

Obj IsMutableObjFilt;

Int IsMutableObjError (
    Obj                 obj )
{
    ErrorQuit(
        "Panic: tried to test mutability of unknown type '%d'",
        (Int)TNUM_OBJ(obj), 0L );
    return 0;
}

Int IsMutableObjObject (
    Obj                 obj )
{
#ifdef HPCGAP
    if (RegionBag(obj) == ReadOnlyRegion)
        return 0;
#endif
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
*F  IsInternallyMutableObjHandler(<self>, <obj>)  -- 'IS_INTERNALLY_MUTABLE_OBJ'
*/

#ifdef HPCGAP

Obj IsInternallyMutableObjFilt;

Obj IsInternallyMutableObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return (TNUM_OBJ(obj) == T_DATOBJ &&
      RegionBag(obj) != ReadOnlyRegion &&
      DoFilter( IsInternallyMutableObjFilt, obj) == True) ? True : False;
}

Int IsInternallyMutableObj(Obj obj) {
    return TNUM_OBJ(obj) == T_DATOBJ &&
      RegionBag(obj) != ReadOnlyRegion &&
      DoFilter( IsInternallyMutableObjFilt, obj) == True;
}

#endif


/****************************************************************************
**
*F  IS_COPYABLE_OBJ(<obj>)  . . . . . . . . . . . . . . is an object copyable
**
**  'IS_COPYABLE_OBJ' returns 1 if the object <obj> is copyable (i.e., can be
**  copied into a mutable object), and 0 otherwise.
**
**  'IS_COPYABLE_OBJ' is defined in the declaration part of this package.
*/
Int (*IsCopyableObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

Obj IsCopyableObjFilt;

Int IsCopyableObjError (
    Obj                 obj )
{
    ErrorQuit(
        "Panic: tried to test copyability of unknown type '%d'",
        (Int)TNUM_OBJ(obj), 0L );
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
*V  ShallowCopyObjFuncs[<type>] . . . . . . . . . .  shallow copier functions
*/
Obj (*ShallowCopyObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

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
#ifdef HPCGAP
    return CopyReachableObjectsFrom(obj, 0, 0, !mut);
#else
    Obj                 new;            /* copy of <obj>                   */

    /* make a copy                                                         */
    new = COPY_OBJ( obj, mut );

    /* clean up the marks                                                  */
    CLEAN_OBJ( obj );

    /* return the copy                                                     */
    return new;
#endif
}


/****************************************************************************
**
*V  CopyObjFuncs[<type>]  . . . . . . . . . . . .  table of copying functions
*/
Obj (*CopyObjFuncs[ LAST_REAL_TNUM+COPYING+1 ]) ( Obj obj, Int mut );


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
    copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
    ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
    if ( !mut ) {
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
    copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
    ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
    SET_LEN_PREC(copy,LEN_PREC(obj));
    if ( !mut ) {
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
    for ( i = 1; i <= LEN_PREC(obj); i++) {
        SET_RNAM_PREC(copy,i,GET_RNAM_PREC(obj,i));
        tmp = COPY_OBJ( GET_ELM_PREC(obj,i), mut );
        SET_ELM_PREC(copy,i,tmp);
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
    for ( i = 1; i <= LEN_PREC(obj); i++ ) {
        CLEAN_OBJ( GET_ELM_PREC(obj,i) );
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
    copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
    ADDR_OBJ(copy)[0] = ADDR_OBJ(obj)[0];
    if ( !mut ) {
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
Obj MutableCopyObjHandler (
    Obj                 self,
    Obj                 obj )
{
    return CopyObj( obj, 1 );
}

/****************************************************************************
**
*F  MakeImmutable( <obj> . . . . . . . . . . make an object immutable inplace
**
**  Mark an object and all subobjects immutable in-place.
**  May cause confusion if there are shared subobjects
**
*/

Obj PostMakeImmutableOp = 0;

void (*MakeImmutableObjFuncs[LAST_REAL_TNUM+1])( Obj );


void MakeImmutable( Obj obj )
{
  if (IS_MUTABLE_OBJ( obj ))
    {
      (*(MakeImmutableObjFuncs[TNUM_OBJ(obj)]))(obj);
    }
}

#ifdef HPCGAP
void CheckedMakeImmutable( Obj obj )
{
  if (!PreMakeImmutableCheck(obj))
    ErrorQuit("MakeImmutable: Argument has inaccessible subobjects", 0L, 0L);
  MakeImmutable(obj);
}
#endif

void MakeImmutableError( Obj obj)
{
  ErrorQuit("No make immutable function installed for a %s",
	    (Int)TNAM_OBJ(obj), 0L);
}



void MakeImmutableComObj( Obj obj)
{
/*UInt i; */
  /* 
  for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i += 2 ) {
       MakeImmutable(ADDR_OBJ(obj)[i]);
       CHANGED_BAG(obj);
    }
  */
  CALL_2ARGS( RESET_FILTER_OBJ, obj, IsMutableObjFilt );
  CALL_1ARGS( PostMakeImmutableOp, obj);
}

void MakeImmutablePosObj( Obj obj)
{
/*UInt i; */
  /* 
  for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i += 1 ) {
       MakeImmutable(ADDR_OBJ(obj)[i]);
       CHANGED_BAG(obj);
    }
  */
  CALL_2ARGS( RESET_FILTER_OBJ, obj, IsMutableObjFilt );
  CALL_1ARGS( PostMakeImmutableOp, obj);
  
}

#ifdef HPCGAP
// HPCGAP-HACK:
// There is a considerable amount of library code that currently
// relies on being able to modify immutable data objects; in order
// to not break all of that, MakeImmutableDatObj() makes immutable
// data objects public, not read-only if they are not internally
// mutable. Note that this is potentially unsafe if these objects
// are shared between threads and then modified by kernel code.
//
// By setting the environment variable GAP_READONLY_DATOBJS, one
// can restore the old behavior in order to find and debug the
// offending code.
static int ReadOnlyDatObjs = 0;
#endif

void MakeImmutableDatObj( Obj obj)
{
  CALL_2ARGS( RESET_FILTER_OBJ, obj, IsMutableObjFilt );
#ifdef HPCGAP
  if (!IsInternallyMutableObj(obj)) {
    if (ReadOnlyDatObjs)
      MakeBagReadOnly(obj);
    else
      MakeBagPublic(obj);
  }
#endif
}

Obj FuncMakeImmutable( Obj self, Obj obj)
{
#ifdef HPCGAP
  CheckedMakeImmutable(obj);
#else
  MakeImmutable(obj);
#endif
  return obj;
}



/****************************************************************************
**
*F  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
**
**  'PrintObj' prints the object <obj>.
*/
/* TL: Obj PrintObjThis; */

/* TL: Int PrintObjIndex; */

/* TL: Int PrintObjFull; */

/* TL: Int PrintObjDepth; */

#define MAXPRINTDEPTH 1024L
/* TL: Obj PrintObjThiss [MAXPRINTDEPTH]; */

/* TL: Int PrintObjIndices [MAXPRINTDEPTH]; */

/****************************************************************************
**
*F  ViewObj( <obj> ) . . . . . . . . . . . . . . . . . . . . view an object
**
**  'ViewObj' views the object <obj>.
**
**  ViewObj shares all the assocaited variables with PrintObj, so that
**  recursion works nicely.
*/

/* These macros and the in-line function are used to keep track of
which objects are already being prted or viewed to trigger the use of
~ when needed. The names (and the no-op macros) are hangovers from an
earlier version in which the bags themselves were marked, rather than
checking the list. This had to be changed to ensure that the method
selection process (for ViewObj) only sees "pristine" bags"   SL 9/4/98 */

#define IS_MARKABLE(obj)    (FIRST_RECORD_TNUM <= TNUM_OBJ(obj) \
                            && TNUM_OBJ(obj) <= LAST_LIST_TNUM)

static inline UInt IS_MARKED( Obj obj )
{
  UInt i;
  if (!IS_MARKABLE(obj))
    return 0;
  for (i = 0; i < STATE(PrintObjDepth)-1; i++)
    if (STATE(PrintObjThiss)[i] == obj)
      return 1;
  return 0;
}

#ifdef HPCGAP
static void PrintInaccessibleObject(Obj obj)
{
  Char buffer[20];
  Char *name;
  Region *region;
  Obj nameobj;

  region = REGION(obj);
  if (!region)
    nameobj = PublicRegionName; /* this should not happen, but let's be safe */
  else
    nameobj = GetRegionName(region);
  if (nameobj) {
    name = CSTR_STRING(nameobj);
  } else {
    sprintf(buffer, "%p", (void *)region);
    name = buffer;
    Pr("<protected object in shared region %s (id: %d)>", (Int) name, (Int) obj);
    return;
  }
  Pr("<protected '%s' object (id: %d)>", (Int) name, (Int) obj);
}
#endif
     
#define MARK(obj)     do {} while (0)
#define UNMARK(obj)   do {} while (0)

/* This variable is used to allow a ViewObj method to call PrintObj on
   the same object without triggering use of ~ */

static UInt LastPV = 0; /* This variable contains one of the values
			   0, 1 and 2 according to whether (1) there
			   is no dynamically enc losing call to
			   PrintObj or ViewObj still open (0), or the
			   innermost such is Print (1) or View (2) */

#ifdef HPCGAP
/* On-demand creation of the PrintObj stack */
void InitPrintObjStack(void)
{
  if (!STATE(PrintObjThiss)) {
    STATE(PrintObjThissObj) = NewBag(T_DATOBJ, MAXPRINTDEPTH*sizeof(Obj)+sizeof(Obj));
    STATE(PrintObjThiss) = ADDR_OBJ(STATE(PrintObjThissObj))+1;
    STATE(PrintObjIndicesObj) = NewBag(T_DATOBJ, MAXPRINTDEPTH*sizeof(Int)+sizeof(Obj));
    STATE(PrintObjIndices) = (Int *)(ADDR_OBJ(STATE(PrintObjIndicesObj))+1);
  }
}
#endif
    
void            PrintObj (
    Obj                 obj )
{
    Int                 i;              /* loop variable                   */
    UInt                lastPV;        /* save LastPV */
    UInt                fromview;      /* non-zero when we were called
				        from viewObj of the SAME object */

    /* check for interrupts                                                */
    if ( SyIsIntr() ) {
        i = STATE(PrintObjDepth);
        Pr( "%c%c", (Int)'\03', (Int)'\04' );
        ErrorReturnVoid(
            "user interrupt while printing",
            0L, 0L,
            "you can 'return;'" );
        STATE(PrintObjDepth) = i;
    }

#if defined(HPCGAP) && !defined(WARD_ENABLED)
   if (IS_BAG_REF(obj) && !CheckReadAccess(obj)) {
     PrintInaccessibleObject(obj);
     return;
   }
#endif

    /* First check if <obj> is actually the current object being Viewed
       Since ViewObj(<obj>) may result in a call to PrintObj(<obj>) */

    lastPV = LastPV;
    LastPV = 1;
    fromview = (lastPV == 2) && (obj == STATE(PrintObjThis));

    /* if <obj> is a subobject, then mark and remember the superobject
       unless ViewObj has done that job already */

#ifdef HPCGAP
    InitPrintObjStack();
#endif

    if ( !fromview  && 0 < STATE(PrintObjDepth) ) {
        if ( IS_MARKABLE(STATE(PrintObjThis)) )  MARK( STATE(PrintObjThis) );
        STATE(PrintObjThiss)[STATE(PrintObjDepth)-1]   = STATE(PrintObjThis);
        STATE(PrintObjIndices)[STATE(PrintObjDepth)-1] = STATE(PrintObjIndex);
    }

    /* handle the <obj>                                                    */
    if (!fromview)
      {
	STATE(PrintObjDepth) += 1;
	STATE(PrintObjThis)   = obj;
	STATE(PrintObjIndex)  = 0;
      }

    /* dispatch to the appropriate printing function                       */
    if ( (! IS_MARKED( STATE(PrintObjThis) )) ) {
      if (STATE(PrintObjDepth) < MAXPRINTDEPTH) {
        (*PrintObjFuncs[ TNUM_OBJ(STATE(PrintObjThis)) ])( STATE(PrintObjThis) );
      }
      else {
        /* don't recurse if depth too high */
        Pr("\nprinting stopped, too many recursion levels!\n", 0L, 0L);
      }
    }

    /* or print the path                                                   */
    else {
        Pr( "~", 0L, 0L );
        for ( i = 0; STATE(PrintObjThis) != STATE(PrintObjThiss)[i]; i++ ) {
            (*PrintPathFuncs[ TNUM_OBJ(STATE(PrintObjThiss)[i])])
                ( STATE(PrintObjThiss)[i], STATE(PrintObjIndices)[i] );
        }
    }


    /* done with <obj>                                                     */
    if (!fromview)
      {
	STATE(PrintObjDepth) -= 1;
	
	/* if <obj> is a subobject, then restore and unmark the superobject    */
	if ( 0 < STATE(PrintObjDepth) ) {
	  STATE(PrintObjThis)  = STATE(PrintObjThiss)[STATE(PrintObjDepth)-1];
	  STATE(PrintObjIndex) = STATE(PrintObjIndices)[STATE(PrintObjDepth)-1];
	  if ( IS_MARKED(STATE(PrintObjThis)) )  UNMARK( STATE(PrintObjThis) );
	}
      }
    LastPV = lastPV;

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
void (* PrintObjFuncs [ LAST_REAL_TNUM  +1 ])( Obj obj );


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


Obj FuncSET_PRINT_OBJ_INDEX (Obj self, Obj ind)
{
  if (IS_INTOBJ(ind))
    STATE(PrintObjIndex) = INT_INTOBJ(ind);
  return 0;
}


/****************************************************************************
**
*F  ViewObj(<obj> )  . . .. . . . . . . . . . . . . . . . . .  view an object
**
**  This should really be merged with PrintObj
*/

Obj ViewObjOper;

void            ViewObj (
    Obj                 obj )
{
    Int                 i;              /* loop variable                   */
    UInt                lastPV;

    /* No check for interrupts here, viewing should not take so long that
       it is necessary */

#if defined(HPCGAP) && !defined(WARD_ENABLED)
   if (IS_BAG_REF(obj) && !CheckReadAccess(obj)) {
     PrintInaccessibleObject(obj);
     return;
   }
#endif


    lastPV = LastPV;
    LastPV = 2;
    
    /* if <obj> is a subobject, then mark and remember the superobject     */

#ifdef HPCGAP
    InitPrintObjStack();
#endif

    if ( 0 < STATE(PrintObjDepth) ) {
        if ( IS_MARKABLE(STATE(PrintObjThis)) )  MARK( STATE(PrintObjThis) );
        STATE(PrintObjThiss)[STATE(PrintObjDepth)-1]   = STATE(PrintObjThis);
        STATE(PrintObjIndices)[STATE(PrintObjDepth)-1] =  STATE(PrintObjIndex);
    }

    /* handle the <obj>                                                    */
    STATE(PrintObjDepth) += 1;
    STATE(PrintObjThis)   = obj;
    STATE(PrintObjIndex)  = 0;

    /* dispatch to the appropriate viewing function                       */

    if ( ! IS_MARKED( STATE(PrintObjThis) ) ) {
      if (STATE(PrintObjDepth) < MAXPRINTDEPTH) {
        DoOperation1Args( ViewObjOper, obj );
      }
      else {
        /* don't recurse any more */
        Pr("\nviewing stopped, too many recursion levels!\n", 0L, 0L);
      }
    }

    /* or view the path                                                   */
    else {
        Pr( "~", 0L, 0L );
        for ( i = 0; STATE(PrintObjThis) != STATE(PrintObjThiss)[i]; i++ ) {
            (*PrintPathFuncs[ TNUM_OBJ(STATE(PrintObjThiss)[i]) ])
                ( STATE(PrintObjThiss)[i], STATE(PrintObjIndices)[i] );
        }
    }

    /* done with <obj>                                                     */
    STATE(PrintObjDepth) -= 1;

    /* if <obj> is a subobject, then restore and unmark the superobject    */
    if ( 0 < STATE(PrintObjDepth) ) {
        STATE(PrintObjThis)  = STATE(PrintObjThiss)[STATE(PrintObjDepth)-1];
        STATE(PrintObjIndex) = STATE(PrintObjIndices)[STATE(PrintObjDepth)-1];
        if ( IS_MARKED(STATE(PrintObjThis)) )  UNMARK( STATE(PrintObjThis) );
    }

    LastPV = lastPV;
}


/****************************************************************************
**
*F  FuncViewObj( <self>, <obj> )  . . . . . . . .  handler for 'ViewObj'
*/
Obj FuncViewObj (
    Obj                 self,
    Obj                 obj )
{
    ViewObj( obj );
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
void (* PrintPathFuncs [ LAST_REAL_TNUM /* +PRINTING */+1 ])( Obj obj, Int indx );

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
*F  TypeComObj( <obj> ) . . . . . . . . . . function version of 'TYPE_COMOBJ'
*/
#ifndef WARD_ENABLED
Obj             TypeComObj (
    Obj                 obj )
{
    Obj result = TYPE_COMOBJ( obj );
#ifdef HPCGAP
    MEMBAR_READ();
#endif
    return result;
}

void SetTypeComObj( Obj obj, Obj type)
{
#ifdef HPCGAP
    ReadGuard(obj);
    MEMBAR_WRITE();
#endif
    TYPE_COMOBJ(obj) = type;
    CHANGED_BAG(obj);
}
#endif


/*****************************************************************************
**
*F  IS_COMOBJ_Handler( <self>, <obj> ) . . . . . . . . handler for 'IS_COMOBJ'
*/
Obj             IS_COMOBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
#ifdef HPCGAP
    switch (TNUM_OBJ(obj)) {
      case T_COMOBJ:
      case T_ACOMOBJ:
        return True;
      default:
        return False;
    }
#else
    return (TNUM_OBJ(obj) == T_COMOBJ ? True : False);
#endif
}


/****************************************************************************
**
*F  SET_TYPE_COMOBJ_Handler( <self>, <obj>, <type> ) . . .  'SET_TYPE_COMOBJ'
*/
Obj SET_TYPE_COMOBJ_Handler (
    Obj                 self,
    Obj                 obj,
    Obj                 type )
{
#ifdef HPCGAP
    switch (TNUM_OBJ(obj)) {
      case T_PREC:
        MEMBAR_WRITE();
        TYPE_COMOBJ( obj ) = type;
        RetypeBag( obj, T_COMOBJ );
        CHANGED_BAG( obj );
        break;
      case T_COMOBJ:
        SetTypeComObj(obj, type);
        break;
      case T_AREC:
      case T_ACOMOBJ:
        SET_TYPE_OBJ( obj, type );
        RetypeBag( obj, T_ACOMOBJ );
        CHANGED_BAG( obj );
        break;
      default:
        ErrorMayQuit("You can't make component object from a %s.",
                     (Int)TNAM_OBJ(obj), 0L);
    }
#else
    if (TNUM_OBJ(obj) == T_PREC+IMMUTABLE)
      ErrorMayQuit("You can't make a component object from an immutable object",
		   0L, 0L);
    TYPE_COMOBJ( obj ) = type;
    RetypeBag( obj, T_COMOBJ );
    CHANGED_BAG( obj );
#endif
    return obj;
}


/****************************************************************************
**
*F  TypePosObj( <obj> ) . . . . . . . . . . function version of 'TYPE_POSOBJ'
*/
#ifndef WARD_ENABLED
Obj TypePosObj (
    Obj                 obj )
{
    Obj result = TYPE_POSOBJ( obj );
#ifdef HPCGAP
    MEMBAR_READ();
#endif
    return result;
}

void SetTypePosObj( Obj obj, Obj type)
{
#ifdef HPCGAP
    ReadGuard(obj);
    MEMBAR_WRITE();
#endif
    TYPE_POSOBJ(obj) = type;
    CHANGED_BAG(obj);
}
#endif


/****************************************************************************
**
*F  IS_POSOBJ_Handler( <self>, <obj> )  . . . . . . . handler for 'IS_POSOBJ'
*/
Obj IS_POSOBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
   switch (TNUM_OBJ(obj)) {
      case T_POSOBJ:
#ifdef HPCGAP
      case T_APOSOBJ:
#endif
        return True;
      default:
        return False;
    }
}


/****************************************************************************
**
*F  SET_TYPE_POSOBJ_Handler( <self>, <obj>, <type> )  . . .  'SET_TYPE_POSOB'
*/
Obj SET_TYPE_POSOBJ_Handler (
    Obj                 self,
    Obj                 obj,
    Obj                 type )
{
#ifdef HPCGAP
    switch (TNUM_OBJ(obj)) {
      case T_APOSOBJ:
      case T_ALIST:
      case T_FIXALIST:
        SET_TYPE_OBJ( obj, type );
        RetypeBag( obj, T_APOSOBJ );
        CHANGED_BAG( obj );
        break;
      case T_POSOBJ:
        SetTypePosObj( obj, type );
        break;
      default:
        MEMBAR_WRITE();
        TYPE_POSOBJ( obj ) = type;
        RetypeBag( obj, T_POSOBJ );
        CHANGED_BAG( obj );
        break;
    }
#else
    TYPE_POSOBJ( obj ) = type;
    RetypeBag( obj, T_POSOBJ );
    CHANGED_BAG( obj );
#endif
    return obj;
}


/****************************************************************************
**
*F  LEN_POSOBJ_Handler( <self>, <obj> ) . . . . . .  handler for 'LEN_POSOBJ'
*/
Obj LEN_POSOBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
#ifdef HPCGAP
    switch (TNUM_OBJ(obj)) {
    case T_APOSOBJ:
    case T_ALIST:
    case T_FIXALIST:
      return LengthAList( obj );
    }
#endif
    return INTOBJ_INT( SIZE_OBJ(obj) / sizeof(Obj) - 1 );
}


/****************************************************************************
**
*F  TypeDatObj( <obj> ) . . . . . . . . . . function version of 'TYPE_DATOBJ'
*/
Obj             TypeDatObj (
    Obj                 obj )
{
    return TYPE_DATOBJ( obj );
}

void SetTypeDatObj( Obj obj, Obj type)
{
    TYPE_DATOBJ(obj) = type;
#ifdef HPCGAP
    if (TNUM_OBJ(obj) == T_DATOBJ &&
        !IsMutableObjObject(obj) && !IsInternallyMutableObj(obj)) {
      if (ReadOnlyDatObjs)
        MakeBagReadOnly(obj);
      else
        MakeBagPublic(obj);
    }
#endif
    CHANGED_BAG(obj);
}


/*****************************************************************************
**
*F  IS_DATOBJ_Handler( <self>, <obj> ) . . . . . . . . handler for 'IS_DATOBJ'
*/
Obj             IS_DATOBJ_Handler (
    Obj                 self,
    Obj                 obj )
{
    return (TNUM_OBJ(obj) == T_DATOBJ ? True : False);
}


/****************************************************************************
**
*F  SET_TYPE_DATOBJ_Handler( <self>, <obj>, <type> ) . . .  'SET_TYPE_DATOBJ'
*/
Obj SET_TYPE_DATOBJ_Handler (
    Obj                 self,
    Obj                 obj,
    Obj                 type )
{
#ifndef WARD_ENABLED
    ReadGuard( obj );
    TYPE_DATOBJ( obj ) = type;
#ifdef HPCGAP
    if (TNUM_OBJ(obj) != T_DATOBJ)
#endif
      RetypeBag( obj, T_DATOBJ );
    CHANGED_BAG( obj );
    return obj;
#endif
}


/****************************************************************************
**
*F  IsIdenticalHandler( <self>, <obj1>, <obj2> )  . . . . .  handler for '=='
**
**  'IsIdenticalHandler' implements 'IsIdentical'
*/
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
**  functions 'SaveSubObj', 'SaveUInt<n>' (<n> = 1,2,4 or 8), and others
**  to be determined. Their role is to identify the C types of the various
**  parts of the bag, and perhaps to leave out some information that does
**  not need to be saved. By the time this function is called, the bag
**  size and type have already been saved
**  No saving function may allocate any bag
*/

void (*SaveObjFuncs[256]) ( Obj obj );

void SaveObjError( Obj obj )
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

void (*LoadObjFuncs[256]) ( Obj obj );

void LoadObjError( Obj obj )
{
  ErrorQuit(
            "Panic: tried to load an object of unknown type '%d'",
            (Int)TNUM_OBJ(obj), 0L );
}

/****************************************************************************
**
*F  SaveComObj( Obj comobj)
**
*/

void SaveComObj( Obj comobj)
{
  UInt len,i;
  SaveSubObj(TYPE_COMOBJ( comobj ));
  len = LEN_PREC(comobj);
  SaveUInt(len);
  for (i = 1; i <= len; i++)
    {
      SaveUInt(GET_RNAM_PREC(comobj, i));
      SaveSubObj(GET_ELM_PREC(comobj, i));
    }
}

/****************************************************************************
**
*F  SavePosObj( Obj posobj)
**
*/

void SavePosObj( Obj posobj)
{
  UInt len,i;
  SaveSubObj(TYPE_POSOBJ( posobj ));
  len = (SIZE_OBJ(posobj)/sizeof(Obj) - 1);
  for (i = 1; i <= len; i++)
    {
      SaveSubObj(ADDR_OBJ(posobj)[i]);
    }
}

/****************************************************************************
**
*F  SaveDatObj( Obj datobj)
**
**  Here we lose endianness protection, because we don't know if this is really
**  UInts, or if it might be smaller data
*/

void SaveDatObj( Obj datobj)
{
  UInt len,i;
  UInt *ptr;
  SaveSubObj(TYPE_DATOBJ( datobj ));
  len = ((SIZE_OBJ(datobj)+sizeof(UInt)-1)/sizeof(UInt) - 1);
  ptr = (UInt *)ADDR_OBJ(datobj)+1;
  for (i = 1; i <= len; i++)
    {
      SaveUInt(*ptr++);
    }
}

/****************************************************************************
**
*F  LoadComObj( Obj comobj)
**
*/

void LoadComObj( Obj comobj)
{
  UInt len,i;
  TYPE_COMOBJ( comobj) = LoadSubObj( );
  len = LoadUInt();
  SET_LEN_PREC(comobj,len);
  for (i = 1; i <= len; i++)
    {
      SET_RNAM_PREC(comobj, i, LoadUInt());
      SET_ELM_PREC(comobj, i, LoadSubObj());
    }
}

/****************************************************************************
**
*F  LoadPosObj( Obj posobj)
**
*/

void LoadPosObj( Obj posobj)
{
  UInt len,i;
  TYPE_POSOBJ( posobj ) = LoadSubObj();
  len = (SIZE_OBJ(posobj)/sizeof(Obj) - 1);
  for (i = 1; i <= len; i++)
    {
      ADDR_OBJ(posobj)[i] = LoadSubObj();
    }
}

/****************************************************************************
**
*F  LoadDatObj( Obj datobj)
**
**  Here we lose endianness protection, because we don't know if this is really
**  UInts, or if it might be smaller data
*/

void LoadDatObj( Obj datobj)
{
  UInt len,i;
  UInt *ptr;
  TYPE_DATOBJ( datobj ) = LoadSubObj();
  len = ((SIZE_OBJ(datobj)+sizeof(UInt)-1)/sizeof(UInt) - 1);
  ptr = (UInt *)ADDR_OBJ(datobj)+1;
  for (i = 1; i <= len; i++)
    {
      *ptr ++ = LoadUInt();
    }
}


/****************************************************************************
**
*F * * * * * * * *  GAP functions for "to be defined" objects * * * * * * * *
*/


/****************************************************************************
**
*F  FuncCLONE_OBJ( <self>, <dst>, <src> ) . . . . . . .  clone <src> to <dst>
**
**  `CLONE_OBJ' clones  the source  <src> into  <dst>.  It  is not allowed to
**  clone small integers or finite field elements.
**
**  If <src> is a constant, than a "shallow" copy, that is to say, a bit-copy
**  of the bag of <src>  is created.  If <src>  is mutable than a "structural
**  copy is created, which is then in turn "shallow" cloned into <dst>.
**
**  WARNING: at the moment the functions breaks on cloning `[1,~]'.  This can
**  be fixed if necessary.
*/
Obj IsToBeDefinedObj;

static Obj REREADING;

Obj FuncCLONE_OBJ (
    Obj             self,
    Obj             dst,
    Obj             src )
{
    Obj *           psrc;
    Obj *           pdst;
    Int             i;

    /* check <src>                                                         */
    if ( IS_INTOBJ(src) ) {
        ErrorReturnVoid( "small integers cannot be cloned", 0, 0,
                         "you can 'return;' to skip the cloning" );
        return 0;
    }
    if ( IS_FFE(src) ) {
        ErrorReturnVoid( "finite field elements cannot be cloned", 0, 0,
                         "you can 'return;' to skip the cloning" );
        return 0;
    }

#ifdef HPCGAP
    switch (TNUM_OBJ(src)) {
        case T_AREC:
        case T_ACOMOBJ:
        case T_TLREC:
          ErrorReturnVoid( "cannot clone %ss",
                           (Int)(InfoBags[TNUM_OBJ(src)].name), 0,
                           "you can 'return;' to skip the cloning" );
          return 0;
    }
    if (!REGION(dst)) {
        ErrorReturnVoid( "CLONE_OBJ() cannot overwrite public objects", 0, 0,
                         "you can 'return;' to skip the cloning" );
        return 0;
    }
    if (REGION(src) != REGION(dst) && REGION(src)) {
        ErrorReturnVoid( "objects can only be cloned to replace objects within"
                         "the same region or if the object is public", 0, 0,
                         "you can 'return;' to skip the cloning" );
        return 0;
    }
#endif
    /* check <dst>                                                         
    if ( (REREADING != True) &&
	 (CALL_1ARGS( IsToBeDefinedObj, dst ) != True) ) {
        ErrorReturnVoid( "the destination must be `to-be-defined' (not a %s)",
                         (Int)TNAM_OBJ(dst), 0,
                         "you can 'return;'" );
        return 0;
    }

    */
    
    /* if object is mutable, produce a structural copy                     */
    if ( IS_MUTABLE_OBJ(src) ) {
        src = CopyObj( src, 1 );
    }

    /* now shallow clone the object                                        */
#ifdef HPCGAP
    Obj tmp = NewBag(TNUM_OBJ(src), SIZE_OBJ(src));
    pdst = ADDR_OBJ(tmp);
#else
    ResizeBag( dst, SIZE_OBJ(src) );
    RetypeBag( dst, TNUM_OBJ(src) );
    pdst = ADDR_OBJ(dst);
#endif
    psrc = ADDR_OBJ(src);
    for ( i = (SIZE_OBJ(src)+sizeof(Obj) - 1)/sizeof(Obj);  0 < i;  i-- ) {
        *pdst++ = *psrc++;
    }
    CHANGED_BAG(dst);
#ifdef HPCGAP
    REGION(dst) = REGION(src);
    MEMBAR_WRITE();
    /* The following is a no-op unless the region is public */
    SET_PTR_BAG(dst, PTR_BAG(tmp));
#endif

    return 0;
}

/****************************************************************************
**
*F  FuncSWITCH_OBJ( <self>, <obj1>, <obj2> ) . . .  switch <obj1> and <obj2>
**
**  `SWITCH_OBJ' exchanges the objects referenced by its two arguments.  It
**   is not allowed to switch clone small integers or finite field elements.
**
**   This is inspired by the Smalltalk 'become:' operation.
*/

Obj FuncSWITCH_OBJ(Obj self, Obj obj1, Obj obj2) {
    if ( IS_INTOBJ(obj1) || IS_INTOBJ(obj2) ) {
        ErrorReturnVoid( "small integer objects cannot be switched", 0, 0,
                         "you can 'return;' to leave them in place" );
        return 0;
    }
    if ( IS_FFE(obj1) || IS_FFE(obj2) ) {
        ErrorReturnVoid( "finite field elements cannot be switched", 0, 0,
                         "you can 'return;' to leave them in place" );
        return 0;
    }
#ifdef HPCGAP
    Region *ds1 = REGION(obj1);
    Region *ds2 = REGION(obj2);
    if (!ds1 || ds1->owner != realTLS)
        ErrorQuit("SWITCH_OBJ: Cannot write to first object's region.", 0, 0);
    if (!ds2 || ds2->owner != realTLS)
        ErrorQuit("SWITCH_OBJ: Cannot write to second object's region.", 0, 0);
    REGION(obj2) = ds1;
    REGION(obj1) = ds2;
#endif
    SwapMasterPoint(obj1, obj2);
    CHANGED_BAG(obj1);
    CHANGED_BAG(obj2);
    return (Obj) 0;
}


/****************************************************************************
**
*F  FuncFORCE_SWITCH_OBJ( <self>, <obj1>, <obj2> ) .  switch <obj1> and <obj2>
**
**  `FORCE_SWITCH_OBJ' exchanges the objects referenced by its two arguments.
**  It is not allowed to switch clone small integers or finite field
**  elements.
**
**  In GAP, FORCE_SWITCH_OBJ does the same thing as SWITCH_OBJ. In HPC_GAP
**  it allows public objects to be exchanged.
*/

Obj FuncFORCE_SWITCH_OBJ(Obj self, Obj obj1, Obj obj2) {
#ifdef HPCGAP
    Obj *ptr1, *ptr2;
    Region *ds1, *ds2;

    if ( IS_INTOBJ(obj1) || IS_INTOBJ(obj2) ) {
        ErrorReturnVoid( "small integer objects cannot be switched", 0, 0,
                         "you can 'return;' to leave them in place" );
        return 0;
    }
    if ( IS_FFE(obj1) || IS_FFE(obj2) ) {
        ErrorReturnVoid( "finite field elements cannot be switched", 0, 0,
                         "you can 'return;' to leave them in place" );
        return 0;
    }
    ptr1 = PTR_BAG(obj1);
    ptr2 = PTR_BAG(obj2);
    ds1 = REGION(obj1);
    ds2 = REGION(obj2);
    if (ds1 && ds1->owner != realTLS)
        ErrorQuit("FORCE_SWITCH_OBJ: Cannot write to first object's region.", 0, 0);
    if (ds2 && ds2->owner != realTLS)
        ErrorQuit("FORCE_SWITCH_OBJ: Cannot write to second object's region.", 0, 0);
    REGION(obj2) = ds1;
    SET_PTR_BAG(obj2, ptr1);
    REGION(obj1) = ds2;
    SET_PTR_BAG(obj1, ptr2);
    CHANGED_BAG(obj1);
    CHANGED_BAG(obj2);
    return (Obj) 0;
#else
    return FuncSWITCH_OBJ(self, obj1, obj2);
#endif
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    { "IS_MUTABLE_OBJ", "obj", &IsMutableObjFilt,
      IsMutableObjHandler, "src/objects.c:IS_MUTABLE_OBJ" },

    { "IS_COPYABLE_OBJ", "obj", &IsCopyableObjFilt,
      IsCopyableObjHandler, "src/objects.c:IS_COPYABLE_OBJ" },

#ifdef HPCGAP
    { "IS_INTERNALLY_MUTABLE_OBJ", "obj", &IsInternallyMutableObjFilt,
      IsInternallyMutableObjHandler, "src/objects.c:IS_INTERNALLY_MUTABLE_OBJ" },
#endif

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    { "SHALLOW_COPY_OBJ", 1, "obj", &ShallowCopyObjOper,
      ShallowCopyObjHandler, "src/objects.c:SHALLOW_COPY_OBJ" },

    { "PRINT_OBJ", 1, "obj", &PrintObjOper,
      PrintObjHandler, "src/objects.c:PRINT_OBJ" },

    { "VIEW_OBJ", 1, "obj", &ViewObjOper,
      FuncViewObj, "src/objects.c:VIEW_OBJ" },

    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "FAMILY_TYPE", 1, "type",
      FamilyTypeHandler, "src/objects.c:FAMILY_TYPE" },

    { "TYPE_OBJ", 1, "obj",
      TypeObjHandler, "src/objects.c:TYPE_OBJ" },

    { "SET_TYPE_OBJ", 2, "obj, type",
      SetTypeObjHandler, "src/objects.c:SET_TYPE_OBJ" },

    { "FAMILY_OBJ", 1, "obj",
      FamilyObjHandler, "src/objects.c:FAMILY_OBJ" },

    { "IMMUTABLE_COPY_OBJ", 1, "obj", 
      ImmutableCopyObjHandler, "src/objects.c:IMMUTABLE_COPY_OBJ" },

    { "DEEP_COPY_OBJ", 1, "obj",
          MutableCopyObjHandler, "src/objects.c:DEEP_COPY_OBJ" },

    { "IS_IDENTICAL_OBJ", 2, "obj1, obj2", 
      IsIdenticalHandler, "src/objects.c:IS_IDENTICAL_OBJ" },

    { "IS_COMOBJ", 1, "obj",
      IS_COMOBJ_Handler, "src/objects.c:IS_COMOBJ" },

    { "SET_TYPE_COMOBJ", 2, "obj, type",
      SET_TYPE_COMOBJ_Handler, "src/objects.c:SET_TYPE_COMOBJ" },

    { "IS_POSOBJ", 1, "obj",
      IS_POSOBJ_Handler, "src/objects.c:IS_POSOBJ" },
    
    { "SET_TYPE_POSOBJ", 2, "obj, type",
      SET_TYPE_POSOBJ_Handler, "src/objects.c:SET_TYPE_POSOBJ" },
    
    { "LEN_POSOBJ", 1, "obj",
      LEN_POSOBJ_Handler, "src/objects.c:LEN_POSOBJ" },
    
    { "IS_DATOBJ", 1, "obj",
      IS_DATOBJ_Handler, "src/objects.c:IS_DATOBJ" },
    
    { "SET_TYPE_DATOBJ", 2, "obj, type",
      SET_TYPE_DATOBJ_Handler, "src/objects.c:SET_TYPE_DATOBJ" },

    GVAR_FUNC(CLONE_OBJ, 2, "dst, src"),
    GVAR_FUNC(SWITCH_OBJ, 2, "obj1, obj2"),
    GVAR_FUNC(FORCE_SWITCH_OBJ, 2, "obj1, obj2"),
    GVAR_FUNC(SET_PRINT_OBJ_INDEX, 1, "index"),
    GVAR_FUNC(MakeImmutable, 1, "obj"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    Int                 t;              /* loop variable                   */

    /* install the marking methods                                         */
    InfoBags[         T_COMOBJ          ].name = "object (component)";
    InitMarkFuncBags( T_COMOBJ          , MarkAllSubBags  );
    InfoBags[         T_COMOBJ +COPYING ].name = "object (component,copied)";
    InitMarkFuncBags( T_COMOBJ +COPYING , MarkAllSubBags  );
    InfoBags[         T_POSOBJ          ].name = "object (positional)";
    InitMarkFuncBags( T_POSOBJ          , MarkAllSubBags  );
    InfoBags[         T_POSOBJ +COPYING ].name = "object (positional,copied)";
    InitMarkFuncBags( T_POSOBJ +COPYING , MarkAllSubBags  );
    InfoBags[         T_DATOBJ          ].name = "object (data)";
    InitMarkFuncBags( T_DATOBJ          , MarkOneSubBags  );
    InfoBags[         T_DATOBJ +COPYING ].name = "object (data,copied)";
    InitMarkFuncBags( T_DATOBJ +COPYING , MarkOneSubBags  );

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(TypeObjFuncs[ t ] == 0);
        TypeObjFuncs[ t ] = TypeObjError;
        SetTypeObjFuncs [ t] = SetTypeObjError;
    }

    TypeObjFuncs[ T_COMOBJ ] = TypeComObj;
    TypeObjFuncs[ T_POSOBJ ] = TypePosObj;
    TypeObjFuncs[ T_DATOBJ ] = TypeDatObj;

    SetTypeObjFuncs [ T_COMOBJ ] = SetTypeComObj;
    SetTypeObjFuncs [ T_POSOBJ ] = SetTypePosObj;
    SetTypeObjFuncs [ T_DATOBJ ] = SetTypeDatObj;

    /* functions for 'to-be-defined' objects                               */
    ImportFuncFromLibrary( "IsToBeDefinedObj", &IsToBeDefinedObj );
    ImportFuncFromLibrary( "PostMakeImmutable", &PostMakeImmutableOp );
    ImportGVarFromLibrary( "REREADING", &REREADING );

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* make and install the 'IS_MUTABLE_OBJ' filter                        */
    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(IsMutableObjFuncs[ t ] == 0);
        IsMutableObjFuncs[ t ] = IsMutableObjError;
    }
    for ( t = FIRST_CONSTANT_TNUM; t <= LAST_CONSTANT_TNUM; t++ )
        IsMutableObjFuncs[ t ] = AlwaysNo;
    for ( t = FIRST_EXTERNAL_TNUM; t <= LAST_EXTERNAL_TNUM; t++ )
        IsMutableObjFuncs[ t ] = IsMutableObjObject;

    /* make and install the 'IS_COPYABLE_OBJ' filter                       */
    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(IsCopyableObjFuncs[ t ] == 0);
        IsCopyableObjFuncs[ t ] = IsCopyableObjError;
    }
    for ( t = FIRST_CONSTANT_TNUM; t <= LAST_CONSTANT_TNUM; t++ )
        IsCopyableObjFuncs[ t ] = AlwaysNo;
    for ( t = FIRST_EXTERNAL_TNUM; t <= LAST_EXTERNAL_TNUM; t++ )
        IsCopyableObjFuncs[ t ] = IsCopyableObjObject;

    /* make and install the 'SHALLOW_COPY_OBJ' operation                   */
    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(ShallowCopyObjFuncs[ t ] == 0);
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjError;
    }
    for ( t = FIRST_CONSTANT_TNUM; t <= LAST_CONSTANT_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjConstant;
    for ( t = FIRST_RECORD_TNUM; t <= LAST_RECORD_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjDefault;
    for ( t = FIRST_LIST_TNUM; t <= LAST_LIST_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjDefault;
    for ( t = FIRST_EXTERNAL_TNUM; t <= LAST_EXTERNAL_TNUM; t++ )
        ShallowCopyObjFuncs[ t ] = ShallowCopyObjObject;

    /* make and install the 'COPY_OBJ' function                            */
    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(CopyObjFuncs [ t ] == 0);
        CopyObjFuncs [ t ] = CopyObjError;
        assert(CleanObjFuncs[ t ] == 0);
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
    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(PrintObjFuncs[ t ] == 0);
        PrintObjFuncs[ t ] = PrintObjObject;
    }

    /* enter 'PrintUnknownObj' in the dispatching tables                   */
    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(PrintPathFuncs[ t ] == 0);
        PrintPathFuncs[ t ] = PrintPathError;
    }

    /* enter 'SaveObjError' and 'LoadObjError' for all types initially     */
    for ( t = FIRST_REAL_TNUM;  t <= LAST_REAL_TNUM;  t++ ) {
        assert(SaveObjFuncs[ t ] == 0);
        SaveObjFuncs[ t ] = SaveObjError;
        assert(LoadObjFuncs[ t ] == 0);
        LoadObjFuncs[ t ] = LoadObjError;
    }
  
    /* install the saving functions */
    SaveObjFuncs[ T_COMOBJ ] = SaveComObj;
    SaveObjFuncs[ T_POSOBJ ] = SavePosObj;
    SaveObjFuncs[ T_DATOBJ ] = SaveDatObj;

    /* install the loading functions */
    LoadObjFuncs[ T_COMOBJ ] = LoadComObj;
    LoadObjFuncs[ T_POSOBJ ] = LoadPosObj;
    LoadObjFuncs[ T_DATOBJ ] = LoadDatObj;

    for (t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(MakeImmutableObjFuncs[ t ] == 0);
        MakeImmutableObjFuncs[t] = MakeImmutableError;
    }
    
    /* install the makeimmutableing functions */
    MakeImmutableObjFuncs[ T_COMOBJ ] = MakeImmutableComObj;
    MakeImmutableObjFuncs[ T_POSOBJ ] = MakeImmutablePosObj;
    MakeImmutableObjFuncs[ T_DATOBJ ] = MakeImmutableDatObj;

#ifdef HPCGAP
    ReadOnlyDatObjs = (getenv("GAP_READONLY_DATOBJS") != 0);
#endif

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    /* export certain TNUM values as global variable */
    AssGVar(GVarName("FIRST_CONSTANT_TNUM"), INTOBJ_INT(FIRST_CONSTANT_TNUM));
    MakeReadOnlyGVar(GVarName("FIRST_CONSTANT_TNUM"));

    AssGVar(GVarName("LAST_CONSTANT_TNUM"), INTOBJ_INT(LAST_CONSTANT_TNUM));
    MakeReadOnlyGVar(GVarName("LAST_CONSTANT_TNUM"));
    
    AssGVar(GVarName("FIRST_RECORD_TNUM"), INTOBJ_INT(FIRST_RECORD_TNUM));
    MakeReadOnlyGVar(GVarName("FIRST_RECORD_TNUM"));

    AssGVar(GVarName("LAST_RECORD_TNUM"), INTOBJ_INT(LAST_RECORD_TNUM));
    MakeReadOnlyGVar(GVarName("LAST_RECORD_TNUM"));

    AssGVar(GVarName("FIRST_LIST_TNUM"), INTOBJ_INT(FIRST_LIST_TNUM));
    MakeReadOnlyGVar(GVarName("FIRST_LIST_TNUM"));

    AssGVar(GVarName("LAST_LIST_TNUM"), INTOBJ_INT(LAST_LIST_TNUM));
    MakeReadOnlyGVar(GVarName("LAST_LIST_TNUM"));
    
    AssGVar(GVarName("FIRST_EXTERNAL_TNUM"), INTOBJ_INT(FIRST_EXTERNAL_TNUM));
    MakeReadOnlyGVar(GVarName("FIRST_EXTERNAL_TNUM"));

    AssGVar(GVarName("LAST_EXTERNAL_TNUM"), INTOBJ_INT(LAST_EXTERNAL_TNUM));
    MakeReadOnlyGVar(GVarName("LAST_EXTERNAL_TNUM"));
    
    AssGVar(GVarName("FIRST_REAL_TNUM"), INTOBJ_INT(FIRST_REAL_TNUM));
    MakeReadOnlyGVar(GVarName("FIRST_REAL_TNUM"));

    AssGVar(GVarName("LAST_REAL_TNUM"), INTOBJ_INT(LAST_REAL_TNUM));
    MakeReadOnlyGVar(GVarName("LAST_REAL_TNUM"));
    
    AssGVar(GVarName("FIRST_IMM_MUT_TNUM"), INTOBJ_INT(FIRST_IMM_MUT_TNUM));
    MakeReadOnlyGVar(GVarName("FIRST_IMM_MUT_TNUM"));

    AssGVar(GVarName("LAST_IMM_MUT_TNUM"), INTOBJ_INT(LAST_IMM_MUT_TNUM));
    MakeReadOnlyGVar(GVarName("LAST_IMM_MUT_TNUM"));

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoObjects() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "objects",                          /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoObjects ( void )
{
    return &module;
}
