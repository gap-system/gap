/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the objects package.
*/

#include "objects.h"

#include "bool.h"
#include "calls.h"
#include "error.h"
#include "gapstate.h"
#include "gvars.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "precord.h"
#include "records.h"
#include "saveload.h"
#include "stringobj.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#include "hpc/guards.h"
#include "hpc/thread.h"
#include "hpc/traverse.h"
#endif

#if defined(USE_THREADSAFE_COPYING)
#include "hpc/traverse.h"
#endif

#include <stdio.h>
#include <stdlib.h>


enum {
    MAXPRINTDEPTH = 64,
};

static ModuleStateOffset ObjectsStateOffset = -1;

typedef struct {
    UInt  PrintObjDepth;
#ifdef HPCGAP
    Obj   PrintObjThissObj;
    Obj * PrintObjThiss;
    Obj   PrintObjIndicesObj;
    Int * PrintObjIndices;
#else
    Obj   PrintObjThiss[MAXPRINTDEPTH];
    Int   PrintObjIndices[MAXPRINTDEPTH];
#endif

    // This variable is used to allow a ViewObj method to call PrintObj on the
    // same object without triggering use of '~'. It contains one of the
    // values 0, 1 and 2 according to whether ...
    // 0: there is no enclosing call to PrintObj or ViewObj still open, or
    // 1: the innermost such is PrintObj, or
    // 2: the innermost such is ViewObj.
    UInt LastPV;

} ObjectsModuleState;


static Int lastFreePackageTNUM = FIRST_PACKAGE_TNUM;


/****************************************************************************
**
*V  NameOfType[<type>] . . . . . . . . . . . . . . . . . . . . names of types
**
**  'NameOfType[<type>]' is the name of the type <type>.
*/
static const char * NameOfType[NUM_TYPES];


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

    SET_TNAM_TNUM(tnum, name);
    TypeObjFuncs[tnum] = typeObjFunc;

    return tnum;
}

const Char * TNAM_TNUM(UInt tnum)
{
    return NameOfType[tnum];
}

void SET_TNAM_TNUM(UInt tnum, const Char *name)
{
    GAP_ASSERT(NameOfType[tnum] == 0);
    NameOfType[tnum] = name;
}


/****************************************************************************
**
*F  FuncFAMILY_TYPE( <self>, <type> ) . . . . . . handler for 'FAMILY_TYPE'
*/
static Obj FuncFAMILY_TYPE(Obj self, Obj type)
{
    return FAMILY_TYPE( type );
}


/****************************************************************************
**
*F  FuncFAMILY_OBJ( <self>, <obj> ) . . . . . . .  handler for 'FAMILY_OBJ'
*/
static Obj FuncFAMILY_OBJ(Obj self, Obj obj)
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

static Obj TypeObjError(Obj obj)
{
    ErrorQuit("Panic: basic object of type '%s' is unkind",
              (Int)TNAM_OBJ(obj), 0);
    return 0;
}

/****************************************************************************
**
*F  SET_TYPE_OBJ( <obj>, <type> ) . . . . . . . . . . . set type of an object
**
**  'SET_TYPE_OBJ' sets the type of the object <obj> to <type>; if <obj>
**  is not a posobj/comobj/datobj, attempts to first convert it to one; if
**  that fails, an error is raised.
*/
void SET_TYPE_OBJ(Obj obj, Obj type)
{
    switch (TNUM_OBJ(obj)) {
#ifdef HPCGAP
    case T_ALIST:
    case T_FIXALIST:
        HashLock(obj);
        ADDR_OBJ(obj)[1] = type;
        CHANGED_BAG(obj);
        RetypeBag(obj, T_APOSOBJ);
        HashUnlock(obj);
        MEMBAR_WRITE();
        break;
    case T_APOSOBJ:
        HashLock(obj);
        ADDR_OBJ(obj)[1] = type;
        CHANGED_BAG(obj);
        HashUnlock(obj);
        MEMBAR_WRITE();
        break;
    case T_AREC:
    case T_ACOMOBJ:
        ADDR_OBJ(obj)[0] = type;
        CHANGED_BAG(obj);
        RetypeBag(obj, T_ACOMOBJ);
        MEMBAR_WRITE();
        break;
#endif
    case T_PREC:
#ifdef HPCGAP
        MEMBAR_WRITE();
#endif
        RetypeBag(obj, T_COMOBJ);
        SET_TYPE_COMOBJ(obj, type);
        CHANGED_BAG(obj);
        break;
    case T_COMOBJ:
#ifdef HPCGAP
        ReadGuard(obj);
        MEMBAR_WRITE();
#endif
        SET_TYPE_COMOBJ(obj, type);
        CHANGED_BAG(obj);
        break;
    case T_POSOBJ:
#ifdef HPCGAP
        ReadGuard(obj);
        MEMBAR_WRITE();
#endif
        SET_TYPE_POSOBJ(obj, type);
        CHANGED_BAG(obj);
        break;
    case T_DATOBJ:
        SetTypeDatObj(obj, type);
        break;

    default:
        if (IS_STRING_REP(obj)) {
            // FIXME/TODO: Hap calls Objectify on a string...
        }
        else if (IS_PLIST(obj)) {
#ifdef HPCGAP
            MEMBAR_WRITE();
#endif
            RetypeBag(obj, T_POSOBJ);
            SET_TYPE_POSOBJ(obj, type);
            CHANGED_BAG(obj);
        }
        else {
            ErrorMayQuit("cannot change type of a %s", (Int)TNAM_OBJ(obj), 0);
        }
        break;
    }
}


/****************************************************************************
**
*F  FuncTYPE_OBJ( <self>, <obj> ) . . . . . . . . .  handler for 'TYPE_OBJ'
*/
#ifndef WARD_ENABLED
static Obj FuncTYPE_OBJ(Obj self, Obj obj)
{
    return TYPE_OBJ( obj );
}
#endif

/****************************************************************************
**
*F  FuncSET_TYPE_OBJ( <self>, <obj>, <type> ) . . handler for 'SET_TYPE_OBJ'
*/
static Obj FuncSET_TYPE_OBJ(Obj self, Obj obj, Obj type)
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
BOOL (*IsMutableObjFuncs[LAST_REAL_TNUM + 1])(Obj obj);

static Obj IsMutableObjFilt;

static BOOL IsMutableObjError(Obj obj)
{
    ErrorQuit("Panic: tried to test mutability of unsupported type '%s'",
              (Int)TNAM_OBJ(obj), 0);
    return FALSE;
}

static BOOL IsMutableObjObject(Obj obj)
{
#ifdef HPCGAP
    if (RegionBag(obj) == ReadOnlyRegion)
        return FALSE;
#endif
    return (DoFilter( IsMutableObjFilt, obj ) == True);
}


/****************************************************************************
**
*F  FiltIS_MUTABLE_OBJ( <self>, <obj> )  . . .  handler for 'IS_MUTABLE_OBJ'
*/
static Obj FiltIS_MUTABLE_OBJ(Obj self, Obj obj)
{
    return (IS_MUTABLE_OBJ( obj ) ? True : False);
}

/****************************************************************************
**
*F  FiltIS_INTERNALLY_MUTABLE_OBJ(<self>, <obj>) 
*/

#ifdef HPCGAP

static Obj IsInternallyMutableObjFilt;

static Obj FiltIS_INTERNALLY_MUTABLE_OBJ(Obj self, Obj obj)
{
    return (TNUM_OBJ(obj) == T_DATOBJ &&
      RegionBag(obj) != ReadOnlyRegion &&
      DoFilter( IsInternallyMutableObjFilt, obj) == True) ? True : False;
}

BOOL IsInternallyMutableObj(Obj obj)
{
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
BOOL (*IsCopyableObjFuncs[LAST_REAL_TNUM + 1])(Obj obj);

static Obj IsCopyableObjFilt;

static BOOL IsCopyableObjError(Obj obj)
{
    ErrorQuit("Panic: tried to test copyability of unsupported type '%s'",
              (Int)TNAM_OBJ(obj), 0);
    return FALSE;
}

static BOOL IsCopyableObjObject(Obj obj)
{
    return (DoFilter( IsCopyableObjFilt, obj ) == True);
}


/****************************************************************************
**
*F  FiltIS_COPYABLE_OBJ( <self>, <obj> ) . . . handler for 'IS_COPYABLE_OBJ'
*/
static Obj FiltIS_COPYABLE_OBJ(Obj self, Obj obj)
{
    return (IS_COPYABLE_OBJ( obj ) ? True : False);
}


/****************************************************************************
**
*V  ShallowCopyObjFuncs[<type>] . . . . . . . . . .  shallow copier functions
*/
Obj (*ShallowCopyObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

static Obj ShallowCopyObjOper;


/****************************************************************************
**
*F  ShallowCopyObjError( <obj> )  . . . . . . . . . . . . . . .  unknown type
*/
static Obj ShallowCopyObjError(Obj obj)
{
    ErrorQuit("Panic: tried to shallow copy object of unsupported type '%s'",
              (Int)TNAM_OBJ(obj), 0);
    return (Obj)0;
}


/****************************************************************************
**
*F  ShallowCopyObjConstant( <obj> ) . . . . . . . . . . . . . . .  do nothing
*/
static Obj ShallowCopyObjConstant(Obj obj)
{
    return obj;
}


/****************************************************************************
**
*F  ShallowCopyObjObject( <obj> ) . . . . . . . . . . . . . . . . call method
*/
static Obj ShallowCopyObjObject(Obj obj)
{
    return DoOperation1Args( ShallowCopyObjOper, obj );
}


/****************************************************************************
**
*F  ShallowCopyObjDefault( <obj> )  . . . . . . . . . .  default shallow copy
*/
static Obj ShallowCopyObjDefault(Obj obj)
{
    Obj                 new;
    const Obj *         o;
    Obj *               n;

    /* make the new object and copy the contents                           */
    new = NewBag( MUTABLE_TNUM(TNUM_OBJ(obj)), SIZE_OBJ(obj) );
    o = CONST_ADDR_OBJ(obj);
    n = ADDR_OBJ( new );
    memcpy(n, o, SIZE_OBJ(obj) );

    /* 'CHANGED_BAG(new);' not needed, <new> is newest object              */
    return new;
}


/****************************************************************************
**
*F  FuncSHALLOW_COPY_OBJ( <self>, <obj> ) . .  handler for 'SHALLOW_COPY_OBJ'
*/
static Obj FuncSHALLOW_COPY_OBJ(Obj self, Obj obj)
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
#ifdef USE_THREADSAFE_COPYING
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


#if !defined(USE_THREADSAFE_COPYING)

/****************************************************************************
**
*V  CopyObjFuncs[<type>]  . . . . . . . . . . . .  table of copying functions
*/
Obj (*CopyObjFuncs[ LAST_REAL_TNUM+1 ]) ( Obj obj, Int mut );


/****************************************************************************
**
*V  CleanObjFuncs[<type>] . . . . . . . . . . . . table of cleaning functions
*/
void (*CleanObjFuncs[ LAST_REAL_TNUM+1 ]) ( Obj obj );


/****************************************************************************
**
*F  PrepareCopy(<obj>,<copy>) . . .  helper for use in CopyObjFuncs functions
**
*/
void PrepareCopy(Obj obj, Obj copy)
{
    // insert a forwarding pointer into <obj> which contains...
    // - the value overwritten by this forwarding pointer,
    // - a pointer to <copy>,
    // - the TNUM of <obj>.
    // Note that we cannot simply restore the overwritten value by copying
    // the corresponding value from <copy>, as they may actually differ
    // between original and copy (e.g. for objects, they point to the type;
    // if making an immutable copy of a mutable object, the types will
    // differ).
    // Likewise, the TNUM of the copy and the original can and will differ;
    // e.g. for a weak pointer list, the copy can be a plist.
    Obj tmp = NEW_PLIST(T_PLIST, 3);
    SET_LEN_PLIST(tmp, 3);
    SET_ELM_PLIST(tmp, 1, CONST_ADDR_OBJ(obj)[0]);
    SET_ELM_PLIST(tmp, 2, copy);
    SET_ELM_PLIST(tmp, 3, INTOBJ_INT(TNUM_OBJ(obj)));

    // insert the forwarding pointer
    GAP_ASSERT(SIZE_OBJ(obj) >= sizeof(Obj));
    ADDR_OBJ(obj)[0] = tmp;
    CHANGED_BAG(obj);

    // update the TNUM to indicate the object is being copied
    RetypeBag(obj, T_COPYING);
}


/****************************************************************************
**
*F  COPY_OBJ(<obj>) . . . . . . . . . . . make a structural copy of an object
**
**  'COPY_OBJ'  implements  the first pass  of  'CopyObj', i.e., it makes the
**  structural copy of <obj> and marks <obj> as already copied.
*/
Obj COPY_OBJ(Obj obj, Int mut)
{
    UInt tnum = TNUM_OBJ(obj);
    Obj copy;

    if (tnum == T_COPYING) {
        // get the plist reference by the forwarding pointer
        Obj fpl = CONST_ADDR_OBJ(obj)[0];

        // return pointer to the copy
        copy = ELM_PLIST(fpl, 2);
    }
    else if (!IS_MUTABLE_OBJ(obj)) {
        copy = obj;
    }
    else {
        copy = (*CopyObjFuncs[tnum])(obj, mut);
    }
    return copy;
}


/****************************************************************************
**
*F  CLEAN_OBJ(<obj>)  . . . . . . . . . . . . . clean up object after copying
**
**  'CLEAN_OBJ' implements the second pass of 'CopyObj', i.e., it removes the
**  mark from <obj>.
*/
void CLEAN_OBJ(Obj obj)
{
    if (TNUM_OBJ(obj) != T_COPYING)
        return;

    // get the plist reference by the forwarding pointer
    Obj fpl = CONST_ADDR_OBJ(obj)[0];

    // remove the forwarding pointer
    ADDR_OBJ(obj)[0] = ELM_PLIST(fpl, 1);
    CHANGED_BAG(obj);

    // restore the tnum
    UInt tnum = INT_INTOBJ(ELM_PLIST(fpl, 3));
    RetypeBag(obj, tnum);

    // invoke type specific cleanup, if any
    if (CleanObjFuncs[tnum])
        CleanObjFuncs[tnum](obj);
}

#if !defined(USE_THREADSAFE_COPYING) && !defined(USE_BOEHM_GC)

static void MarkCopyingSubBags(Obj obj)
{
    Obj fpl = CONST_ADDR_OBJ(obj)[0];

    // mark the forwarding pointer
    MarkBag(fpl);

    // mark the rest as in the non-copied case
    UInt tnum = INT_INTOBJ(ELM_PLIST(fpl, 3));
    TabMarkFuncBags[tnum](obj);
}

#endif


/****************************************************************************
**
*F  CopyObjError( <obj> ) . . . . . . . . . . . . . . . . . . .  unknown type
*/
static Obj CopyObjError(Obj obj, Int mut)
{
    ErrorQuit("Panic: tried to copy object of unsupported type '%s'",
              (Int)TNAM_OBJ(obj), 0);
    return (Obj)0;
}


/****************************************************************************
**
*F  CleanObjError( <obj> )  . . . . . . . . . . . . . . . . . .  unknown type
*/
static void CleanObjError(Obj obj)
{
    ErrorQuit("Panic: tried to clean object of unsupported type '%s'",
              (Int)TNAM_OBJ(obj), 0);
}


/****************************************************************************
**
*F  CopyObjConstant( <obj> )  . . . . . . . . . . . .  copy a constant object
*/
static Obj CopyObjConstant(Obj obj, Int mut)
{
    return obj;
}


/****************************************************************************
**
*F  CopyObjPosObj( <obj>, <mut> ) . . . . . . . . .  copy a positional object
*/
static Obj CopyObjPosObj(Obj obj, Int mut)
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    UInt                i;              /* loop variable                   */

    // immutable input is handled by COPY_OBJ
    GAP_ASSERT(IS_MUTABLE_OBJ(obj));

    /* if the object is not copyable return                                */
    if ( ! IS_COPYABLE_OBJ(obj) ) {
        ErrorQuit("Panic: encountered mutable, non-copyable object", 0, 0);
    }

    /* make a copy                                                         */
    copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
    ADDR_OBJ(copy)[0] = CONST_ADDR_OBJ(obj)[0];
    if ( !mut ) {
        CALL_2ARGS( RESET_FILTER_OBJ, copy, IsMutableObjFilt );
    }

    /* leave a forwarding pointer                                          */
    PrepareCopy(obj, copy);

    /* copy the subvalues                                                  */
    for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i++ ) {
        if (CONST_ADDR_OBJ(obj)[i] != 0) {
            tmp = COPY_OBJ(CONST_ADDR_OBJ(obj)[i], mut);
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
static void CleanObjPosObj(Obj obj)
{
    UInt                i;              /* loop variable                   */

    /* clean the subvalues                                                 */
    for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i++ ) {
        if (CONST_ADDR_OBJ(obj)[i] != 0)
            CLEAN_OBJ(CONST_ADDR_OBJ(obj)[i]);
    }

}


/****************************************************************************
**
*F  CopyObjComObj( <obj>, <mut> ) . . . . . . . . . . . . . . . copy a comobj
*/
static Obj CopyObjComObj(Obj obj, Int mut)
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */

    // immutable input is handled by COPY_OBJ
    GAP_ASSERT(IS_MUTABLE_OBJ(obj));

    /* if the object is not copyable return                                */
    if ( ! IS_COPYABLE_OBJ(obj) ) {
        ErrorQuit("Panic: encountered mutable, non-copyable object", 0, 0);
    }

    /* make a copy                                                         */
    copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
    memcpy(ADDR_OBJ(copy), CONST_ADDR_OBJ(obj), SIZE_OBJ(obj));
    if ( !mut ) {
        CALL_2ARGS( RESET_FILTER_OBJ, copy, IsMutableObjFilt );
    }

    /* leave a forwarding pointer                                          */
    PrepareCopy(obj, copy);

    // copy the subvalues; since we used memcpy above, we don't need to worry
    // about copying the length or RNAMs; and by working solely inside the
    // copy, we avoid triggering tnum assertions in GET_ELM_PREC and
    // SET_ELM_PREC
    const UInt len = LEN_PREC(copy);
    for (UInt i = 1; i <= len; i++) {
        tmp = COPY_OBJ(GET_ELM_PREC(copy, i), mut);
        SET_ELM_PREC(copy, i, tmp);
        CHANGED_BAG(copy);
    }

    /* return the copy                                                     */
    return copy;
}


/****************************************************************************
**
*F  CleanObjComObj( <obj> ) . . . . . . . . . . . . . . . . .  clean a comobj
*/
static void CleanObjComObj(Obj obj)
{
    UInt                i;              /* loop variable                   */

    /* clean the subvalues                                                 */
    for ( i = 1; i <= LEN_PREC(obj); i++ ) {
        CLEAN_OBJ( GET_ELM_PREC(obj,i) );
    }

}


/****************************************************************************
**
*F  CopyObjDatObj( <obj>, <mut> ) . . . . . . . . . . . . . . . copy a datobj
*/
static Obj CopyObjDatObj(Obj obj, Int mut)
{
    Obj                 copy;           /* copy, result                    */

    // immutable input is handled by COPY_OBJ
    GAP_ASSERT(IS_MUTABLE_OBJ(obj));

    /* if the object is not copyable return                                */
    if ( ! IS_COPYABLE_OBJ(obj) ) {
        ErrorQuit("Panic: encountered mutable, non-copyable object", 0, 0);
    }

    /* make a copy                                                         */
    copy = NewBag( TNUM_OBJ(obj), SIZE_OBJ(obj) );
    memcpy(ADDR_OBJ(copy), CONST_ADDR_OBJ(obj), SIZE_OBJ(obj));
    if ( !mut ) {
        CALL_2ARGS( RESET_FILTER_OBJ, copy, IsMutableObjFilt );
    }

    /* leave a forwarding pointer                                          */
    PrepareCopy(obj, copy);

    /* return the copy                                                     */
    return copy;
}


/****************************************************************************
**
*F  CleanObjDatObj( <obj> ) . . . . . . . . . . . . . . . . .  clean a datobj
*/
static void CleanObjDatObj(Obj obj)
{
}

#endif // !defined(USE_THREADSAFE_COPYING)

/****************************************************************************
**
*F  FuncIMMUTABLE_COPY_OBJ( <self>, <obj> )  . . . . immutable copy of <obj>
*/
static Obj FuncIMMUTABLE_COPY_OBJ(Obj self, Obj obj)
{
    return CopyObj( obj, 0 );
}


/****************************************************************************
**
*F  FuncDEEP_COPY_OBJ( <self>, <obj> )  . . . . . . mutable copy of <obj>
*/
static Obj FuncDEEP_COPY_OBJ(Obj self, Obj obj)
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

static Obj PostMakeImmutableOp = 0;

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
    ErrorMayQuit("MakeImmutable: Argument has inaccessible subobjects", 0, 0);
  MakeImmutable(obj);
}
#endif

static void MakeImmutableError(Obj obj)
{
  ErrorQuit("No make immutable function installed for a %s",
            (Int)TNAM_OBJ(obj), 0);
}


static void MakeImmutableComObj(Obj obj)
{
  CALL_2ARGS( RESET_FILTER_OBJ, obj, IsMutableObjFilt );
  CALL_1ARGS( PostMakeImmutableOp, obj);
}

static void MakeImmutablePosObj(Obj obj)
{
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

static void MakeImmutableDatObj(Obj obj)
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

static Obj FuncMakeImmutable(Obj self, Obj obj)
{
#ifdef HPCGAP
  CheckedMakeImmutable(obj);
#else
  MakeImmutable(obj);
#endif
  return obj;
}

static Obj FuncGET_TNAM_FROM_TNUM(Obj self, Obj obj)
{
    UInt         tnum = GetBoundedInt("GET_TNAM_FROM_TNUM", obj, 0, NUM_TYPES - 1);
    const char * name = TNAM_TNUM(tnum);
    return MakeImmString(name ? name : "<unnamed tnum>");
}


// This function is used to keep track of which objects are already
// being printed or viewed to trigger the use of ~ when needed.
static inline BOOL IS_ON_PRINT_STACK(const ObjectsModuleState * os, Obj obj)
{
    if (!(FIRST_RECORD_TNUM <= TNUM_OBJ(obj) &&
          TNUM_OBJ(obj) <= LAST_LIST_TNUM))
        return FALSE;
    for (UInt i = 0; i < os->PrintObjDepth; i++)
        if (os->PrintObjThiss[i] == obj)
            return TRUE;
    return FALSE;
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

#ifdef HPCGAP
/* On-demand creation of the PrintObj stack */
static void InitPrintObjStack(ObjectsModuleState * os)
{
    if (!os->PrintObjThiss) {
        os->PrintObjThissObj = NewBag(T_DATOBJ, MAXPRINTDEPTH*sizeof(Obj)+sizeof(Obj));
        os->PrintObjThiss = ADDR_OBJ(os->PrintObjThissObj)+1;
        os->PrintObjIndicesObj = NewBag(T_DATOBJ, MAXPRINTDEPTH*sizeof(Int)+sizeof(Obj));
        os->PrintObjIndices = (Int *)(ADDR_OBJ(os->PrintObjIndicesObj)+1);
    }
}
#endif
    
/****************************************************************************
**
*F  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
**
**  'PrintObj' prints the object <obj>.
*/
void PrintObj(Obj obj)
{
#if defined(HPCGAP) && !defined(WARD_ENABLED)
    if (IS_BAG_REF(obj) && !CheckReadAccess(obj)) {
        PrintInaccessibleObject(obj);
        return;
    }
#endif

    ObjectsModuleState * os = &MODULE_STATE(Objects);

#ifdef HPCGAP
    InitPrintObjStack(os);
#endif

    // First check if <obj> is actually the current object being viewed, since
    // ViewObj(<obj>) may result in a call to PrintObj(<obj>); in that case,
    // we should not put <obj> on the print stack
    if ((os->PrintObjDepth > 0) && (os->LastPV == 2) &&
        (obj == os->PrintObjThiss[os->PrintObjDepth - 1])) {
        os->LastPV = 1;
        PRINT_OBJ(obj);
        os->LastPV = 2;
    }

    // print the path if <obj> is on the stack
    else if (IS_ON_PRINT_STACK(os, obj)) {
        Pr("~", 0, 0);
        for (int i = 0; obj != os->PrintObjThiss[i]; i++) {
            PRINT_PATH(os->PrintObjThiss[i], os->PrintObjIndices[i]);
        }
    }

    // dispatch to the appropriate printing function
    else if (os->PrintObjDepth < MAXPRINTDEPTH) {

        // push obj on the stack
        os->PrintObjThiss[os->PrintObjDepth] = obj;
        os->PrintObjIndices[os->PrintObjDepth] = 0;
        os->PrintObjDepth++;

        UInt lastPV = os->LastPV;
        os->LastPV = 1;
        PRINT_OBJ(obj);
        os->LastPV = lastPV;

        // pop <obj> from the stack
        os->PrintObjDepth--;
    }
    else {
        Pr("\nprinting stopped, too many recursion levels!\n", 0, 0);
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
void (* PrintObjFuncs [ LAST_REAL_TNUM  +1 ])( Obj obj );


/****************************************************************************
**
*F  PrintObjObject( <obj> ) . . . . . . . . . . . . . . . . . print an object
*/
Obj PrintObjOper;

static void PrintObjObject(Obj obj)
{
    DoOperation1Args( PrintObjOper, obj );
}


/****************************************************************************
**
*F  FuncPRINT_OBJ( <self>, <obj> ) . . . . . . . . . . handler for 'PrintObj'
*/
static Obj FuncPRINT_OBJ(Obj self, Obj obj)
{
    PrintObj( obj );
    return 0;
}

UInt SetPrintObjState(UInt state)
{
    UInt oldDepth = MODULE_STATE(Objects).PrintObjDepth;
    UInt oldLastPV = MODULE_STATE(Objects).LastPV;
    MODULE_STATE(Objects).PrintObjDepth = state >> 2;
    MODULE_STATE(Objects).LastPV = state & 3;
    return (oldDepth << 2) | oldLastPV;
}

void SetPrintObjIndex(Int index)
{
    UInt depth = MODULE_STATE(Objects).PrintObjDepth;
    if (depth == 0)
        ErrorQuit("SetPrintObjIndex: bad state, PrintObjDepth is 0", 0, 0);
    MODULE_STATE(Objects).PrintObjIndices[depth - 1] = index;
}

static Obj FuncSET_PRINT_OBJ_INDEX(Obj self, Obj index)
{
    SetPrintObjIndex(GetSmallInt("SET_PRINT_OBJ_INDEX", index));
    return 0;
}


/****************************************************************************
**
*F  ViewObj( <obj> ) . . . . . . . . . . . . . . . . . . . . . view an object
**
**  'ViewObj' views the object <obj>.
**
**  ViewObj shares all the associated variables with PrintObj, so that
**  recursion works nicely.
*/

static Obj ViewObjOper;

void ViewObj(Obj obj)
{
#if defined(HPCGAP) && !defined(WARD_ENABLED)
    if (IS_BAG_REF(obj) && !CheckReadAccess(obj)) {
        PrintInaccessibleObject(obj);
        return;
    }
#endif

    ObjectsModuleState * os = &MODULE_STATE(Objects);

#ifdef HPCGAP
    InitPrintObjStack(os);
#endif

    // print the path if <obj> is on the stack
    if (IS_ON_PRINT_STACK(os, obj)) {
        Pr("~", 0, 0);
        for (int i = 0; obj != os->PrintObjThiss[i]; i++) {
            PRINT_PATH(os->PrintObjThiss[i], os->PrintObjIndices[i]);
        }
    }

    // dispatch to the appropriate viewing function
    else if (os->PrintObjDepth < MAXPRINTDEPTH) {

        // push obj on the stack
        os->PrintObjThiss[os->PrintObjDepth] = obj;
        os->PrintObjIndices[os->PrintObjDepth] = 0;
        os->PrintObjDepth++;

        UInt lastPV = os->LastPV;
        os->LastPV = 2;
        DoOperation1Args(ViewObjOper, obj);
        os->LastPV = lastPV;

        // pop <obj> from the stack
        os->PrintObjDepth--;
    }
    else {
        Pr("\nviewing stopped, too many recursion levels!\n", 0, 0);
    }
}


/****************************************************************************
**
*F  FuncVIEW_OBJ( <self>, <obj> ) . . . . . . . . . . . handler for 'ViewObj'
*/
static Obj FuncVIEW_OBJ(Obj self, Obj obj)
{
    ViewObj( obj );
    return 0;
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

static void PrintPathError(Obj obj, Int indx)
{
    ErrorQuit("Panic: tried to print a path of unsupported type '%s'",
              (Int)TNAM_OBJ(obj), 0);
}


/****************************************************************************
**
*F  TypeComObj( <obj> ) . . . . . . . . . . function version of 'TYPE_COMOBJ'
*/
#ifndef WARD_ENABLED
static Obj TypeComObj(Obj obj)
{
    Obj result = TYPE_COMOBJ( obj );
#ifdef HPCGAP
    MEMBAR_READ();
#endif
    return result;
}

#endif


/*****************************************************************************
**
*F  FuncIS_COMOBJ( <self>, <obj> ) . . . . . . . . handler for 'IS_COMOBJ'
*/
static Obj FuncIS_COMOBJ(Obj self, Obj obj)
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
*F  FuncSET_TYPE_COMOBJ( <self>, <obj>, <type> ) . . .  'SET_TYPE_COMOBJ'
*/
static Obj FuncSET_TYPE_COMOBJ(Obj self, Obj obj, Obj type)
{
    switch (TNUM_OBJ(obj)) {
    case T_PREC:
    case T_COMOBJ:
#ifdef HPCGAP
    case T_AREC:
    case T_ACOMOBJ:
#endif
        SET_TYPE_OBJ(obj, type);
        break;
    default:
        ErrorMayQuit("You can't make a component object from a %s",
                     (Int)TNAM_OBJ(obj), 0);
    }
    return obj;
}


/****************************************************************************
**
*F  AssComObj( <obj>, <rnam>, <val> )
*F  UnbComObj( <obj>, <rnam> )
*F  ElmComObj( <obj>, <rnam> )
*F  IsbComObj( <obj>, <rnam> )
*/
void AssComObj(Obj obj, UInt rnam, Obj val)
{
    switch (TNUM_OBJ(obj)) {
    case T_COMOBJ:
        AssPRec(obj, rnam, val);
        break;
#ifdef HPCGAP
    case T_ACOMOBJ:
        SetARecordField(obj, rnam, val);
        break;
#endif
    default:
        ASS_REC(obj, rnam, val);
        break;
    }
}

void UnbComObj(Obj obj, UInt rnam)
{
    switch (TNUM_OBJ(obj)) {
    case T_COMOBJ:
        UnbPRec(obj, rnam);
        break;
#ifdef HPCGAP
    case T_ACOMOBJ:
        UnbARecord(obj, rnam);
        break;
#endif
    default:
        UNB_REC(obj, rnam);
        break;
    }
}

Obj ElmComObj(Obj obj, UInt rnam)
{
    switch (TNUM_OBJ(obj)) {
    case T_COMOBJ:
        return ElmPRec(obj, rnam);
#ifdef HPCGAP
    case T_ACOMOBJ:
        return ElmARecord(obj, rnam);
#endif
    default:
        return ELM_REC(obj, rnam);
    }
}

BOOL IsbComObj(Obj obj, UInt rnam)
{
    switch (TNUM_OBJ(obj)) {
    case T_COMOBJ:
        return IsbPRec(obj, rnam);
#ifdef HPCGAP
    case T_ACOMOBJ:
        return IsbARecord(obj, rnam);
#endif
    default:
        return ISB_REC(obj, rnam);
    }
}


/****************************************************************************
**
*F  TypePosObj( <obj> ) . . . . . . . . . . function version of 'TYPE_POSOBJ'
*/
#ifndef WARD_ENABLED
static Obj TypePosObj(Obj obj)
{
    Obj result = TYPE_POSOBJ( obj );
#ifdef HPCGAP
    MEMBAR_READ();
#endif
    return result;
}
#endif


/****************************************************************************
**
*F  FuncIS_POSOBJ( <self>, <obj> )  . . . . . . . handler for 'IS_POSOBJ'
*/
static Obj FuncIS_POSOBJ(Obj self, Obj obj)
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
*F  FuncSET_TYPE_POSOBJ( <self>, <obj>, <type> )  . . .  'SET_TYPE_POSOB'
*/
static Obj FuncSET_TYPE_POSOBJ(Obj self, Obj obj, Obj type)
{
    switch (TNUM_OBJ(obj)) {
#ifdef HPCGAP
    case T_APOSOBJ:
    case T_ALIST:
    case T_FIXALIST:
#endif
    case T_POSOBJ:
        break;
    default:
        if (IS_STRING_REP(obj)) {
            // FIXME/TODO: Hap calls Objectify on a string...
        }
        else if (!IS_PLIST(obj)) {
            ErrorMayQuit("You can't make a positional object from a %s",
                         (Int)TNAM_OBJ(obj), 0);
        }
        // TODO: we should also reject immutable plists, but that risks
        // breaking existing code
        break;
    }
    SET_TYPE_OBJ(obj, type);
    return obj;
}


/****************************************************************************
**
*F  FuncLEN_POSOBJ( <self>, <obj> ) . . . . . .  handler for 'LEN_POSOBJ'
*/
static Obj FuncLEN_POSOBJ(Obj self, Obj obj)
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
*F  AssPosbj( <obj>, <rnam>, <val> )
*F  UnbPosbj( <obj>, <rnam> )
*F  ElmPosbj( <obj>, <rnam> )
*F  IsbPosbj( <obj>, <rnam> )
*/
void AssPosObj(Obj obj, Int idx, Obj val)
{
    if (TNUM_OBJ(obj) == T_POSOBJ) {
#ifdef HPCGAP
        // Because BindOnce() functions can reallocate the list even if they
        // only have read-only access, we have to be careful when accessing
        // positional objects. Hence the explicit WriteGuard().
        WriteGuard(obj);
#endif
        if (SIZE_OBJ(obj) / sizeof(Obj) - 1 < idx) {
            ResizeBag(obj, (idx + 1) * sizeof(Obj));
        }
        SET_ELM_PLIST(obj, idx, val);
        CHANGED_BAG(obj);
    }
#ifdef HPCGAP
    else if (TNUM_OBJ(obj) == T_APOSOBJ) {
        AssListFuncs[T_FIXALIST](obj, idx, val);
    }
#endif
    else {
        ASS_LIST(obj, idx, val);
    }
}

void UnbPosObj(Obj obj, Int idx)
{
    if (TNUM_OBJ(obj) == T_POSOBJ) {
#ifdef HPCGAP
        // Because BindOnce() functions can reallocate the list even if they
        // only have read-only access, we have to be careful when accessing
        // positional objects. Hence the explicit WriteGuard().
        WriteGuard(obj);
#endif
        if (idx <= SIZE_OBJ(obj) / sizeof(Obj) - 1) {
            SET_ELM_PLIST(obj, idx, 0);
        }
    }
#ifdef HPCGAP
    else if (TNUM_OBJ(obj) == T_APOSOBJ) {
        UnbListFuncs[T_FIXALIST](obj, idx);
    }
#endif
    else {
        UNB_LIST(obj, idx);
    }
}

Obj ElmPosObj(Obj obj, Int idx)
{
    Obj elm;
    if (TNUM_OBJ(obj) == T_POSOBJ) {
#ifdef HPCGAP
        // Because BindOnce() functions can reallocate the list even if they
        // only have read-only access, we have to be careful when accessing
        // positional objects.
        const Bag * contents = CONST_PTR_BAG(obj);
        MEMBAR_READ(); /* essential memory barrier */
        if (SIZE_BAG_CONTENTS(contents) / sizeof(Obj) - 1 < idx) {
            ErrorMayQuit(
                "PosObj Element: <PosObj>![%d] must have an assigned value",
                (Int)idx, 0);
        }
        elm = contents[idx];
#else
        if (SIZE_OBJ(obj) / sizeof(Obj) - 1 < idx) {
            ErrorMayQuit(
                "PosObj Element: <PosObj>![%d] must have an assigned value",
                (Int)idx, 0);
        }
        elm = ELM_PLIST(obj, idx);
#endif
        if (elm == 0) {
            ErrorMayQuit(
                "PosObj Element: <PosObj>![%d] must have an assigned value",
                (Int)idx, 0);
        }
    }
#ifdef HPCGAP
    else if (TNUM_OBJ(obj) == T_APOSOBJ) {
        elm = ElmListFuncs[T_FIXALIST](obj, idx);
    }
#endif
    else {
        elm = ELM_LIST(obj, idx);
    }
    return elm;
}

BOOL IsbPosObj(Obj obj, Int idx)
{
    BOOL isb;
    if (TNUM_OBJ(obj) == T_POSOBJ) {
#ifdef HPCGAP
        // Because BindOnce() functions can reallocate the list even if they
        // only have read-only access, we have to be careful when accessing
        // positional objects.
        const Bag * contents = CONST_PTR_BAG(obj);
        if (idx > SIZE_BAG_CONTENTS(contents) / sizeof(Obj) - 1)
            isb = FALSE;
        else
            isb = contents[idx] != 0;
#else
        isb = (idx <= SIZE_OBJ(obj) / sizeof(Obj) - 1 &&
               ELM_PLIST(obj, idx) != 0);
#endif
    }
#ifdef HPCGAP
    else if (TNUM_OBJ(obj) == T_APOSOBJ) {
        isb = IsbListFuncs[T_FIXALIST](obj, idx);
    }
#endif
    else {
        isb = ISB_LIST(obj, idx);
    }
    return isb;
}


/****************************************************************************
**
*F  TypeDatObj( <obj> ) . . . . . . . . . . function version of 'TYPE_DATOBJ'
*/
static Obj TypeDatObj(Obj obj)
{
    return TYPE_DATOBJ( obj );
}

void SetTypeDatObj( Obj obj, Obj type)
{
    SET_TYPE_DATOBJ(obj, type);
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
*F  FuncIS_DATOBJ( <self>, <obj> ) . . . . . . . . handler for 'IS_DATOBJ'
*/
static Obj FuncIS_DATOBJ(Obj self, Obj obj)
{
    return (TNUM_OBJ(obj) == T_DATOBJ ? True : False);
}


/****************************************************************************
**
*F  FuncSET_TYPE_DATOBJ( <self>, <obj>, <type> ) . . .  'SET_TYPE_DATOBJ'
*/
static Obj FuncSET_TYPE_DATOBJ(Obj self, Obj obj, Obj type)
{
#ifndef WARD_ENABLED
#ifdef HPCGAP
    ReadGuard( obj );
#endif
    SET_TYPE_DATOBJ(obj, type);
    RetypeBag( obj, T_DATOBJ );
    CHANGED_BAG( obj );
    return obj;
#endif
}


/****************************************************************************
**
*F  NewKernelBuffer( <size> )  . . . . . . . . . . return a new kernel buffer
*/
static Obj TYPE_KERNEL_OBJECT;

Obj NewKernelBuffer(UInt size)
{
    Obj obj = NewBag(T_DATOBJ, size);
    SET_TYPE_DATOBJ(obj, TYPE_KERNEL_OBJECT);
    return obj;
}


/****************************************************************************
**
*F  FuncIS_IDENTICAL_OBJ( <self>, <obj1>, <obj2> )  . . . . .  handler for '=='
**
**  'FuncIS_IDENTICAL_OBJ' implements 'IsIdentical'
*/
static Obj FuncIS_IDENTICAL_OBJ(Obj self, Obj obj1, Obj obj2)
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
#ifdef GAP_ENABLE_SAVELOAD
void (*SaveObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

void SaveObjError( Obj obj )
{
    ErrorQuit("Panic: tried to save an object of unsupported type '%s'",
              (Int)TNAM_OBJ(obj), 0);
}
#endif


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
#ifdef GAP_ENABLE_SAVELOAD
void (*LoadObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

void LoadObjError( Obj obj )
{
    ErrorQuit("Panic: tried to load an object of unsupported type '%s'",
              (Int)TNAM_OBJ(obj), 0);
}
#endif


/****************************************************************************
**
*F  SaveComObj( Obj comobj)
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveComObj(Obj comobj)
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
#endif

/****************************************************************************
**
*F  SavePosObj( Obj posobj)
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SavePosObj(Obj posobj)
{
  UInt len,i;
  SaveSubObj(TYPE_POSOBJ( posobj ));
  len = (SIZE_OBJ(posobj)/sizeof(Obj) - 1);
  for (i = 1; i <= len; i++)
    {
      SaveSubObj(CONST_ADDR_OBJ(posobj)[i]);
    }
}
#endif

/****************************************************************************
**
*F  SaveDatObj( Obj datobj)
**
**  Here we lose endianness protection, because we don't know if this is really
**  UInts, or if it might be smaller data
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveDatObj(Obj datobj)
{
  UInt len,i;
  const UInt * ptr;
  SaveSubObj(TYPE_DATOBJ( datobj ));
  len = ((SIZE_OBJ(datobj)+sizeof(UInt)-1)/sizeof(UInt) - 1);
  ptr = (const UInt *)CONST_ADDR_OBJ(datobj) + 1;
  for (i = 1; i <= len; i++)
    {
      SaveUInt(*ptr++);
    }
}
#endif

/****************************************************************************
**
*F  LoadComObj( Obj comobj)
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadComObj(Obj comobj)
{
  UInt len,i;
  SET_TYPE_COMOBJ(comobj, LoadSubObj());
  len = LoadUInt();
  SET_LEN_PREC(comobj,len);
  for (i = 1; i <= len; i++)
    {
      SET_RNAM_PREC(comobj, i, LoadUInt());
      SET_ELM_PREC(comobj, i, LoadSubObj());
    }
}
#endif

/****************************************************************************
**
*F  LoadPosObj( Obj posobj)
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadPosObj(Obj posobj)
{
  UInt len,i;
  SET_TYPE_POSOBJ(posobj, LoadSubObj());
  len = (SIZE_OBJ(posobj)/sizeof(Obj) - 1);
  for (i = 1; i <= len; i++)
    {
      ADDR_OBJ(posobj)[i] = LoadSubObj();
    }
}
#endif

/****************************************************************************
**
*F  LoadDatObj( Obj datobj)
**
**  Here we lose endianness protection, because we don't know if this is really
**  UInts, or if it might be smaller data
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadDatObj(Obj datobj)
{
  UInt len,i;
  UInt *ptr;
  SET_TYPE_DATOBJ(datobj, LoadSubObj());
  len = ((SIZE_OBJ(datobj)+sizeof(UInt)-1)/sizeof(UInt) - 1);
  ptr = (UInt *)ADDR_OBJ(datobj)+1;
  for (i = 1; i <= len; i++)
    {
      *ptr ++ = LoadUInt();
    }
}
#endif


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
static Obj IsToBeDefinedObj;

static Obj REREADING;

static Obj FuncCLONE_OBJ(Obj self, Obj dst, Obj src)
{
    const Obj *     psrc;
    Obj *           pdst;

    /* check <src>                                                         */
    if ( IS_INTOBJ(src) ) {
        ErrorMayQuit("small integers cannot be cloned", 0, 0);
    }
    if ( IS_FFE(src) ) {
        ErrorMayQuit("finite field elements cannot be cloned", 0, 0);
    }
    if ( TNUM_OBJ(src) == T_BOOL ) {
        ErrorMayQuit("booleans cannot be cloned", 0, 0);
    }

#ifdef HPCGAP
    switch (TNUM_OBJ(src)) {
        case T_AREC:
        case T_ACOMOBJ:
        case T_TLREC:
            ErrorMayQuit("cannot clone %ss", (Int)TNAM_OBJ(src), 0);
    }
    if (!REGION(dst)) {
        ErrorMayQuit("CLONE_OBJ() cannot overwrite public objects", 0, 0);
    }
    if (REGION(src) != REGION(dst) && REGION(src)) {
        ErrorMayQuit("objects can only be cloned to replace objects within"
                     "the same region or if the object is public",
                     0, 0);
    }
#endif
    
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
    psrc = CONST_ADDR_OBJ(src);
    memcpy(pdst, psrc, SIZE_OBJ(src));
    CHANGED_BAG(dst);
#ifdef HPCGAP
    SET_REGION(dst, REGION(src));
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

static Obj FuncSWITCH_OBJ(Obj self, Obj obj1, Obj obj2)
{
    if ( IS_INTOBJ(obj1) || IS_INTOBJ(obj2) ) {
        ErrorMayQuit("small integer objects cannot be switched", 0, 0);
    }
    if ( IS_FFE(obj1) || IS_FFE(obj2) ) {
        ErrorMayQuit("finite field elements cannot be switched", 0, 0);
    }
#ifdef HPCGAP
    Region * ds1 = REGION(obj1);
    Region * ds2 = REGION(obj2);
    if (!ds1 || ds1->owner != GetTLS())
        ErrorQuit("SWITCH_OBJ: Cannot write to first object's region.", 0, 0);
    if (!ds2 || ds2->owner != GetTLS())
        ErrorQuit("SWITCH_OBJ: Cannot write to second object's region.", 0, 0);
    SET_REGION(obj2, ds1);
    SET_REGION(obj1, ds2);
#endif
    SwapMasterPoint(obj1, obj2);
    return 0;
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

static Obj FuncFORCE_SWITCH_OBJ(Obj self, Obj obj1, Obj obj2)
{
    if ( IS_INTOBJ(obj1) || IS_INTOBJ(obj2) ) {
        ErrorMayQuit("small integer objects cannot be switched", 0, 0);
    }
    if ( IS_FFE(obj1) || IS_FFE(obj2) ) {
        ErrorMayQuit("finite field elements cannot be switched", 0, 0);
    }
#ifdef HPCGAP
    Region * ds1 = REGION(obj1);
    Region * ds2 = REGION(obj2);
    if (ds1 && ds1->owner != GetTLS())
        ErrorQuit("FORCE_SWITCH_OBJ: Cannot write to first object's region.", 0, 0);
    if (ds2 && ds2->owner != GetTLS())
        ErrorQuit("FORCE_SWITCH_OBJ: Cannot write to second object's region.", 0, 0);
    SET_REGION(obj2, ds1);
    SET_REGION(obj1, ds2);
#endif
    SwapMasterPoint(obj1, obj2);
    return 0;
}


/****************************************************************************
**
*F  FuncDEBUG_TNUM_NAMES
**
**  Print all defined TNUM values and names
*/
#define START_SYMBOLIC_TNUM(name)                                            \
    if (k == name) {                                                         \
        Pr("%3d: %s", k, (Int)indentStr);                                    \
        Pr("%s" #name "\n", (Int)indentStr, 0);                              \
        assert(indentLvl + 1 < sizeof(indentStr));                           \
        indentStr[indentLvl++] = ' ';                                        \
        indentStr[indentLvl] = 0;                                            \
    }

#define STOP_SYMBOLIC_TNUM(name)                                             \
    if (k == name) {                                                         \
        assert(indentLvl > 0);                                               \
        indentStr[--indentLvl] = 0;                                          \
        Pr("%3d: %s", k, (Int)indentStr);                                    \
        Pr("%s" #name "\n", (Int)indentStr, 0);                              \
    }

static Obj FuncDEBUG_TNUM_NAMES(Obj self)
{
    UInt indentLvl = 0;
    Char indentStr[20] = "";
    for (UInt k = 0; k < NUM_TYPES; k++) {
        START_SYMBOLIC_TNUM(FIRST_REAL_TNUM);
        START_SYMBOLIC_TNUM(FIRST_CONSTANT_TNUM);
        START_SYMBOLIC_TNUM(FIRST_MULT_TNUM);
        START_SYMBOLIC_TNUM(FIRST_IMM_MUT_TNUM);
        START_SYMBOLIC_TNUM(FIRST_RECORD_TNUM);
        START_SYMBOLIC_TNUM(FIRST_LIST_TNUM);
        START_SYMBOLIC_TNUM(FIRST_PLIST_TNUM);
        START_SYMBOLIC_TNUM(FIRST_OBJSET_TNUM);
#ifdef HPCGAP
        START_SYMBOLIC_TNUM(FIRST_SHARED_TNUM);
        START_SYMBOLIC_TNUM(FIRST_ATOMIC_TNUM);
        START_SYMBOLIC_TNUM(FIRST_ATOMIC_LIST_TNUM);
        START_SYMBOLIC_TNUM(FIRST_ATOMIC_RECORD_TNUM);
#endif
        START_SYMBOLIC_TNUM(FIRST_EXTERNAL_TNUM);
        START_SYMBOLIC_TNUM(FIRST_PACKAGE_TNUM);
        const char *name = TNAM_TNUM(k);
        Pr("%3d: %s", k, (Int)indentStr);
        Pr("%s%s\n", (Int)indentStr, (Int)(name ? name : "."));
        if (name == 0 && k >= FIRST_PACKAGE_TNUM) {
            // scan ahead and skip over all unused package slots
            int i = k + 1;
            while (i <= LAST_PACKAGE_TNUM && TNAM_TNUM(i) == 0)
                i++;
            i--;
            if (i > k + 1)
                Pr("...  %s%s.\n", (Int)indentStr, (Int)indentStr);
            if (i > k) {
                Pr("%3d: %s", i, (Int)indentStr);
                Pr("%s.\n", (Int)indentStr, 0);
            }
            k = i;
        }

        STOP_SYMBOLIC_TNUM(LAST_MULT_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_CONSTANT_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_RECORD_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_PLIST_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_LIST_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_OBJSET_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_IMM_MUT_TNUM);
#ifdef HPCGAP
        STOP_SYMBOLIC_TNUM(LAST_SHARED_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_ATOMIC_RECORD_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_ATOMIC_LIST_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_ATOMIC_TNUM);
#endif
        STOP_SYMBOLIC_TNUM(LAST_PACKAGE_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_EXTERNAL_TNUM);
        STOP_SYMBOLIC_TNUM(LAST_REAL_TNUM);
    }
    return 0;
}
#undef START_SYMBOLIC_TNUM
#undef STOP_SYMBOLIC_TNUM


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_COMOBJ,                         "component object"               },
  { T_POSOBJ,                         "positional object"              },
  { T_DATOBJ,                         "data object"                    },
#if !defined(USE_THREADSAFE_COPYING)
  { T_COPYING,                        "copy in progress"               },
#endif
  { -1,                               ""                               }
};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_MUTABLE_OBJ, "obj", &IsMutableObjFilt),
    GVAR_FILT(IS_COPYABLE_OBJ, "obj", &IsCopyableObjFilt),
#ifdef HPCGAP
    GVAR_FILT(IS_INTERNALLY_MUTABLE_OBJ, "obj", &IsInternallyMutableObjFilt),
#endif
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    GVAR_OPER_1ARGS(SHALLOW_COPY_OBJ, obj, &ShallowCopyObjOper),
    GVAR_OPER_1ARGS(PRINT_OBJ, obj, &PrintObjOper),
    GVAR_OPER_1ARGS(VIEW_OBJ, obj, &ViewObjOper),

    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_1ARGS(FAMILY_TYPE, type),
    GVAR_FUNC_1ARGS(TYPE_OBJ, obj),
    GVAR_FUNC_2ARGS(SET_TYPE_OBJ, obj, type),
    GVAR_FUNC_1ARGS(FAMILY_OBJ, obj),
    GVAR_FUNC_1ARGS(IMMUTABLE_COPY_OBJ, obj),
    GVAR_FUNC_1ARGS(DEEP_COPY_OBJ, obj),
    GVAR_FUNC_2ARGS(IS_IDENTICAL_OBJ, obj1, obj2),
    GVAR_FUNC_1ARGS(IS_COMOBJ, obj),
    GVAR_FUNC_2ARGS(SET_TYPE_COMOBJ, obj, type),
    GVAR_FUNC_1ARGS(IS_POSOBJ, obj),
    GVAR_FUNC_2ARGS(SET_TYPE_POSOBJ, obj, type),
    GVAR_FUNC_1ARGS(LEN_POSOBJ, obj),
    GVAR_FUNC_1ARGS(IS_DATOBJ, obj),
    GVAR_FUNC_2ARGS(SET_TYPE_DATOBJ, obj, type),
    GVAR_FUNC_2ARGS(CLONE_OBJ, dst, src),
    GVAR_FUNC_2ARGS(SWITCH_OBJ, obj1, obj2),
    GVAR_FUNC_2ARGS(FORCE_SWITCH_OBJ, obj1, obj2),
    GVAR_FUNC_1ARGS(SET_PRINT_OBJ_INDEX, index),
    GVAR_FUNC_1ARGS(MakeImmutable, obj),
    GVAR_FUNC_1ARGS(GET_TNAM_FROM_TNUM, obj),
    GVAR_FUNC_0ARGS(DEBUG_TNUM_NAMES),

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

    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking methods                                         */
    InitMarkFuncBags( T_COMOBJ          , MarkPRecSubBags );
    InitMarkFuncBags( T_POSOBJ          , MarkAllSubBags  );
    InitMarkFuncBags( T_DATOBJ          , MarkOneSubBags  );
#if !defined(USE_THREADSAFE_COPYING) && !defined(USE_BOEHM_GC)
    InitMarkFuncBags(T_COPYING, MarkCopyingSubBags);
#endif

    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(TypeObjFuncs[ t ] == 0);
        TypeObjFuncs[ t ] = TypeObjError;
    }

    TypeObjFuncs[ T_COMOBJ ] = TypeComObj;
    TypeObjFuncs[ T_POSOBJ ] = TypePosObj;
    TypeObjFuncs[ T_DATOBJ ] = TypeDatObj;

    /* functions for 'to-be-defined' objects                               */
    ImportFuncFromLibrary( "IsToBeDefinedObj", &IsToBeDefinedObj );
    ImportFuncFromLibrary( "PostMakeImmutable", &PostMakeImmutableOp );
    ImportGVarFromLibrary( "REREADING", &REREADING );
    ImportGVarFromLibrary( "TYPE_KERNEL_OBJECT", &TYPE_KERNEL_OBJECT );

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

#ifdef USE_THREADSAFE_COPYING
    SetTraversalMethod(T_POSOBJ, TRAVERSE_ALL_BUT_FIRST, 0, 0);
    SetTraversalMethod(T_COMOBJ, TRAVERSE_BY_FUNCTION, TraversePRecord, CopyPRecord);
    SetTraversalMethod(T_DATOBJ, TRAVERSE_NONE, 0, 0);
#else
    /* make and install the 'COPY_OBJ' function                            */
    for ( t = FIRST_REAL_TNUM; t <= LAST_REAL_TNUM; t++ ) {
        assert(CopyObjFuncs [ t ] == 0);
        CopyObjFuncs [ t ] = CopyObjError;
        assert(CleanObjFuncs[ t ] == 0);
        CleanObjFuncs[ t ] = CleanObjError;
    }
    for ( t = FIRST_CONSTANT_TNUM; t <= LAST_CONSTANT_TNUM; t++ ) {
        CopyObjFuncs [ t ] = CopyObjConstant;
        CleanObjFuncs[ t ] = 0;
    }
    CopyObjFuncs[  T_POSOBJ           ] = CopyObjPosObj;
    CleanObjFuncs[ T_POSOBJ           ] = CleanObjPosObj;
    CopyObjFuncs[  T_COMOBJ           ] = CopyObjComObj;
    CleanObjFuncs[ T_COMOBJ           ] = CleanObjComObj;
    CopyObjFuncs[  T_DATOBJ           ] = CopyObjDatObj;
    CleanObjFuncs[ T_DATOBJ           ] = CleanObjDatObj;
#endif

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

#ifdef GAP_ENABLE_SAVELOAD
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
#endif

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
    ExportAsConstantGVar(FIRST_REAL_TNUM);
    ExportAsConstantGVar(LAST_REAL_TNUM);

    ExportAsConstantGVar(FIRST_CONSTANT_TNUM);
    ExportAsConstantGVar(LAST_CONSTANT_TNUM);

    ExportAsConstantGVar(FIRST_MULT_TNUM);
    ExportAsConstantGVar(LAST_MULT_TNUM);

    ExportAsConstantGVar(FIRST_IMM_MUT_TNUM);
    ExportAsConstantGVar(LAST_IMM_MUT_TNUM);

    ExportAsConstantGVar(FIRST_RECORD_TNUM);
    ExportAsConstantGVar(LAST_RECORD_TNUM);

    ExportAsConstantGVar(FIRST_LIST_TNUM);
    ExportAsConstantGVar(LAST_LIST_TNUM);

    ExportAsConstantGVar(FIRST_PLIST_TNUM);
    ExportAsConstantGVar(LAST_PLIST_TNUM);

    ExportAsConstantGVar(FIRST_OBJSET_TNUM);
    ExportAsConstantGVar(LAST_OBJSET_TNUM);

    ExportAsConstantGVar(FIRST_EXTERNAL_TNUM);
    ExportAsConstantGVar(LAST_EXTERNAL_TNUM);

    ExportAsConstantGVar(FIRST_PACKAGE_TNUM);
    ExportAsConstantGVar(LAST_PACKAGE_TNUM);

#ifdef HPCGAP
    ExportAsConstantGVar(FIRST_SHARED_TNUM);
    ExportAsConstantGVar(LAST_SHARED_TNUM);
#endif

    ExportAsConstantGVar(T_INT);
    ExportAsConstantGVar(T_INTPOS);
    ExportAsConstantGVar(T_INTNEG);
    ExportAsConstantGVar(T_RAT);
    ExportAsConstantGVar(T_CYC);
    ExportAsConstantGVar(T_FFE);
    ExportAsConstantGVar(T_PERM2);
    ExportAsConstantGVar(T_PERM4);
    ExportAsConstantGVar(T_TRANS2);
    ExportAsConstantGVar(T_TRANS4);
    ExportAsConstantGVar(T_PPERM2);
    ExportAsConstantGVar(T_PPERM4);
    ExportAsConstantGVar(T_BOOL);
    ExportAsConstantGVar(T_CHAR);
    ExportAsConstantGVar(T_FUNCTION);
    ExportAsConstantGVar(T_BODY);
    ExportAsConstantGVar(T_FLAGS);
    ExportAsConstantGVar(T_MACFLOAT);
    ExportAsConstantGVar(T_LVARS);
    ExportAsConstantGVar(T_HVARS);

    ExportAsConstantGVar(T_PREC);

    ExportAsConstantGVar(T_PLIST);
    ExportAsConstantGVar(T_PLIST_NDENSE);
    ExportAsConstantGVar(T_PLIST_DENSE);
    ExportAsConstantGVar(T_PLIST_DENSE_NHOM);
    ExportAsConstantGVar(T_PLIST_DENSE_NHOM_SSORT);
    ExportAsConstantGVar(T_PLIST_DENSE_NHOM_NSORT);
    ExportAsConstantGVar(T_PLIST_EMPTY);
    ExportAsConstantGVar(T_PLIST_HOM);
    ExportAsConstantGVar(T_PLIST_HOM_NSORT);
    ExportAsConstantGVar(T_PLIST_HOM_SSORT);
    ExportAsConstantGVar(T_PLIST_TAB);
    ExportAsConstantGVar(T_PLIST_TAB_NSORT);
    ExportAsConstantGVar(T_PLIST_TAB_SSORT);
    ExportAsConstantGVar(T_PLIST_TAB_RECT);
    ExportAsConstantGVar(T_PLIST_TAB_RECT_NSORT);
    ExportAsConstantGVar(T_PLIST_TAB_RECT_SSORT);
    ExportAsConstantGVar(T_PLIST_CYC);
    ExportAsConstantGVar(T_PLIST_CYC_NSORT);
    ExportAsConstantGVar(T_PLIST_CYC_SSORT);
    ExportAsConstantGVar(T_PLIST_FFE);

    ExportAsConstantGVar(T_RANGE_NSORT);
    ExportAsConstantGVar(T_RANGE_SSORT);
    ExportAsConstantGVar(T_BLIST);
    ExportAsConstantGVar(T_BLIST_NSORT);
    ExportAsConstantGVar(T_BLIST_SSORT);
    ExportAsConstantGVar(T_STRING);
    ExportAsConstantGVar(T_STRING_NSORT);
    ExportAsConstantGVar(T_STRING_SSORT);

    ExportAsConstantGVar(T_OBJSET);
    ExportAsConstantGVar(T_OBJMAP);

    ExportAsConstantGVar(T_COMOBJ);
    ExportAsConstantGVar(T_POSOBJ);
    ExportAsConstantGVar(T_DATOBJ);
    ExportAsConstantGVar(T_WPOBJ);
#ifdef HPCGAP
    ExportAsConstantGVar(T_APOSOBJ);
    ExportAsConstantGVar(T_ACOMOBJ);

    ExportAsConstantGVar(T_THREAD);
    ExportAsConstantGVar(T_MONITOR);
    ExportAsConstantGVar(T_REGION);
    ExportAsConstantGVar(T_SEMAPHORE);
    ExportAsConstantGVar(T_CHANNEL);
    ExportAsConstantGVar(T_BARRIER);
    ExportAsConstantGVar(T_SYNCVAR);
    ExportAsConstantGVar(T_FIXALIST);
    ExportAsConstantGVar(T_ALIST);
    ExportAsConstantGVar(T_AREC);
    ExportAsConstantGVar(T_AREC_INNER);
    ExportAsConstantGVar(T_TLREC);
    ExportAsConstantGVar(T_TLREC_INNER);
#endif

#if !defined(USE_THREADSAFE_COPYING)
    ExportAsConstantGVar(T_COPYING);
#endif

    // export positions of data in type objects
    ExportAsConstantGVar(POS_FAMILY_TYPE);
    ExportAsConstantGVar(POS_FLAGS_TYPE);
    ExportAsConstantGVar(POS_DATA_TYPE);
    ExportAsConstantGVar(POS_NUMB_TYPE);
    ExportAsConstantGVar(POS_FIRST_FREE_TYPE);

    // export small integer limits
    AssConstantGVar(GVarName("INTOBJ_MIN"), INTOBJ_MIN);
    AssConstantGVar(GVarName("INTOBJ_MAX"), INTOBJ_MAX);

    return 0;
}


/****************************************************************************
**
*F  InitInfoObjects() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "objects",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,

    .moduleStateSize = sizeof(ObjectsModuleState),
    .moduleStateOffsetPtr = &ObjectsStateOffset,
};

StructInitInfo * InitInfoObjects ( void )
{
    return &module;
}
