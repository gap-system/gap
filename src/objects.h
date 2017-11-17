/****************************************************************************
**
*W  objects.h                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file defines the functions of the objects package.
**
**  The objects package is the part that defines the 'Obj' type,  the objects
**  types  (i.e., the numbers  that  Gasman needs  to distinguish types), the
**  dispatcher for the printing of objects, etc.
*/

#ifndef GAP_OBJECTS_H
#define GAP_OBJECTS_H

#include <src/debug.h>
#include <src/intobj.h>

#ifdef HPCGAP
#define USE_THREADSAFE_COPYING
#endif


/****************************************************************************
**
*T  Obj . . . . . . . . . . . . . . . . . . . . . . . . . . . type of objects
**
**  'Obj' is the type of objects.
**
**  The following is defined in "system.h"
**
#define Obj             Bag
*/


/****************************************************************************
**
*F  IS_FFE( <o> ) . . . . . . . . test if an object is a finite field element
**
**  'IS_FFE'  returns 1  if the  object <o>  is  an  (immediate) finite field
**  element and 0 otherwise.
*/
static inline Int IS_FFE(Obj o)
{
    return (Int)o & 0x02;
}


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
Int RegisterPackageTNUM( const char *name, Obj (*typeObjFunc)(Obj obj) );


/****************************************************************************
**
*F  NEXT_ENUM_EVEN( <id> )
*F  START_ENUM_RANGE_EVEN( <id> )
*F  END_ENUM_RANGE_ODD( <id> )
**
**  'NEXT_ENUM_EVEN' can be used in an enum to force <id> to use the next
**  available even integer value.
**
**  'START_ENUM_RANGE_EVEN' is a variant of 'START_ENUM_RANGE' which always
**  sets the value of <id> to the next even integer.
**
**  'END_ENUM_RANGE_ODD' is a variant of 'END_ENUM_RANGE' which always sets
**  the value of <id> to an odd integer.
*/
#define NEXT_ENUM_EVEN(id)   \
    _##id##_pre, \
    id = _##id##_pre + (_##id##_pre & 1)
#define START_ENUM_RANGE_EVEN(id)   \
    NEXT_ENUM_EVEN(id), \
    _##id##_post = id - 1
#define END_ENUM_RANGE_ODD(id)   \
    _##id##_pre, \
    id = _##id##_pre - !(_##id##_pre & 1)


/****************************************************************************
**
*/
enum {
    IMMUTABLE = 1    // IMMUTABLE is not a TNUM, but rather a bitmask
};

/****************************************************************************
**
*S  T_<name>  . . . . . . . . . . . . . . . . symbolic names for object types
*S  FIRST_CONSTANT_TNUM, LAST_CONSTANT_TNUM . . . . range of constant   types
*S  FIRST_RECORD_TNUM,   LAST_RECORD_TNUM . . . . . range of record     types
*S  FIRST_LIST_TNUM,     LAST_LIST_TNUM . . . . . . range of list       types
*S  FIRST_EXTERNAL_TNUM, LAST_EXTERNAL_TNUM . . . . range of external   types
*S  FIRST_REAL_TNUM,     LAST_REAL_TNUM . . . . . . range of real       types
*S  FIRST_IMM_MUT_TNUM,  LAST_IMM_MUT_TNUM  . . . . range of im/mutable types
**
**  For every type of objects there is a symbolic name defined for this type.
**
**  'FIRST_CONSTANT_TNUM'  is  the first   type  of constant  objects,  e.g.,
**  integers, booleans, and functions.  'LAST_CONSTANT_TNUM' is the last type
**  of constant objects.
**
**  'FIRST_RECORD_TNUM' is the first type of record objects,  currently  only
**  plain records.  'LAST_RECORD_TNUM' is the last type of record objects.
**
**  'FIRST_LIST_TNUM' is the first type of list objects, e.g.,  plain  lists,
**  ranges, boolean lists, and strings.  'LAST_LIST_TNUM' is the last type of
**  list objects.
**
**  'FIRST_EXTERNAL_TNUM' is the  first type  of external objects,  currently
**  only   component   objects,  positional   objects,    and data   objects.
**  'LAST_EXTERNAL_TNUM' is the last type of external objects.
**
**  'FIRST_REAL_TNUM' is the first  real  type, namely 'FIRST_CONSTANT_TNUM'.
**  'LAST_REAL_TNUM'  is the last   real  type, namely  'LAST_EXTERNAL_TNUM'.
**
**  'FIRST_IMM_MUT_TNUM'  is the first  real  internal type of objects  which
**  might be mutable, 'LAST_IMM_MUT_TNUM' is the last such type.
**
**  The types *must* be sorted in this order, i.e., first the constant types,
**  then the record types, then the list types,  then the external types, and
**  finally the virtual types.
*/
enum TNUM {
    START_ENUM_RANGE(FIRST_REAL_TNUM),

    START_ENUM_RANGE(FIRST_CONSTANT_TNUM),
        T_INT,      // immediate
        T_INTPOS,
        T_INTNEG,
        T_RAT,
        T_CYC,
        T_FFE,      // immediate
        T_PERM2,
        T_PERM4,
        T_TRANS2,
        T_TRANS4,
        T_PPERM2,
        T_PPERM4,
        T_BOOL,
        T_CHAR,
        T_FUNCTION,
        T_BODY,     // the type of function body bags
        T_FLAGS,
        T_MACFLOAT,
        T_LVARS,
        T_HVARS,
    END_ENUM_RANGE(LAST_CONSTANT_TNUM),

    // first mutable/immutable TNUM
    START_ENUM_RANGE_EVEN(FIRST_IMM_MUT_TNUM),

        // records
        START_ENUM_RANGE_EVEN(FIRST_RECORD_TNUM),
            T_PREC,
        END_ENUM_RANGE_ODD(LAST_RECORD_TNUM),

        // lists
        START_ENUM_RANGE_EVEN(FIRST_LIST_TNUM),

            // plists
            START_ENUM_RANGE_EVEN(FIRST_PLIST_TNUM),
                NEXT_ENUM_EVEN(T_PLIST),
                NEXT_ENUM_EVEN(T_PLIST_NDENSE),
                NEXT_ENUM_EVEN(T_PLIST_DENSE),
                NEXT_ENUM_EVEN(T_PLIST_DENSE_NHOM),
                NEXT_ENUM_EVEN(T_PLIST_DENSE_NHOM_SSORT),
                NEXT_ENUM_EVEN(T_PLIST_DENSE_NHOM_NSORT),
                NEXT_ENUM_EVEN(T_PLIST_EMPTY),
                NEXT_ENUM_EVEN(T_PLIST_HOM),
                NEXT_ENUM_EVEN(T_PLIST_HOM_NSORT),
                NEXT_ENUM_EVEN(T_PLIST_HOM_SSORT),
                NEXT_ENUM_EVEN(T_PLIST_TAB),
                NEXT_ENUM_EVEN(T_PLIST_TAB_NSORT),
                NEXT_ENUM_EVEN(T_PLIST_TAB_SSORT),
                NEXT_ENUM_EVEN(T_PLIST_TAB_RECT),
                NEXT_ENUM_EVEN(T_PLIST_TAB_RECT_NSORT),
                NEXT_ENUM_EVEN(T_PLIST_TAB_RECT_SSORT),
                NEXT_ENUM_EVEN(T_PLIST_CYC),
                NEXT_ENUM_EVEN(T_PLIST_CYC_NSORT),
                NEXT_ENUM_EVEN(T_PLIST_CYC_SSORT),
                NEXT_ENUM_EVEN(T_PLIST_FFE),
            END_ENUM_RANGE_ODD(LAST_PLIST_TNUM),

            // other kinds of lists
            NEXT_ENUM_EVEN(T_RANGE_NSORT),
            NEXT_ENUM_EVEN(T_RANGE_SSORT),
            NEXT_ENUM_EVEN(T_BLIST),
            NEXT_ENUM_EVEN(T_BLIST_NSORT),
            NEXT_ENUM_EVEN(T_BLIST_SSORT),
            NEXT_ENUM_EVEN(T_STRING),
            NEXT_ENUM_EVEN(T_STRING_NSORT),
            NEXT_ENUM_EVEN(T_STRING_SSORT),

        END_ENUM_RANGE_ODD(LAST_LIST_TNUM),

        // object sets and maps
        START_ENUM_RANGE_EVEN(FIRST_OBJSET_TNUM),
            NEXT_ENUM_EVEN(T_OBJSET),
            NEXT_ENUM_EVEN(T_OBJMAP),
        END_ENUM_RANGE_ODD(LAST_OBJSET_TNUM),

    // last mutable/immutable TNUM
    END_ENUM_RANGE(LAST_IMM_MUT_TNUM),

    // external types
    START_ENUM_RANGE(FIRST_EXTERNAL_TNUM),
        T_COMOBJ,
        T_POSOBJ,
        T_DATOBJ,
        T_WPOBJ,
#ifdef HPCGAP
        T_APOSOBJ,
        T_ACOMOBJ,
#endif

        // package TNUMs, for use by kernel extensions
        //
        // The largest TNUM (which, depending on USE_THREADSAFE_COPYING, is
        // either LAST_REAL_TNUM or LAST_COPYING_TNUM) must not exceed 253.
        // This restricts the value for LAST_PACKAGE_TNUM indirectly. It is
        // difficult to describe the largest possible value with a formula, as
        // LAST_COPYING_TNUM itself changes depending LAST_PACKAGE_TNUM, and
        // the fact that some TNUMs are forced to be even causes additional
        // jumps; so increasing LAST_PACKAGE_TNUM by 1 can lead to
        // LAST_COPYING_TNUM growing by 2, 3 or even 4. So we simply hand-pick
        // LAST_PACKAGE_TNUM as the largest value that does not trigger the
        // GAP_STATIC_ASSERT following this enum.
        FIRST_PACKAGE_TNUM,
#ifdef HPCGAP
        LAST_PACKAGE_TNUM   = FIRST_PACKAGE_TNUM + 153,
#else
        LAST_PACKAGE_TNUM   = FIRST_PACKAGE_TNUM + 50,
#endif

    END_ENUM_RANGE(LAST_EXTERNAL_TNUM),

#ifdef HPCGAP
    START_ENUM_RANGE(FIRST_SHARED_TNUM),
        // primitive types
        T_THREAD,
        T_MONITOR,
        T_REGION,
        // user-programmable types
        T_SEMAPHORE,
        T_CHANNEL,
        T_BARRIER,
        T_SYNCVAR,
        // atomic lists and records, thread local records
    START_ENUM_RANGE(FIRST_ATOMIC_TNUM),
    START_ENUM_RANGE(FIRST_ATOMIC_LIST_TNUM),
        T_FIXALIST,
        T_ALIST,
    END_ENUM_RANGE(LAST_ATOMIC_LIST_TNUM),
    START_ENUM_RANGE(FIRST_ATOMIC_RECORD_TNUM),
        T_AREC,
        T_AREC_INNER,
        T_TLREC,
        T_TLREC_INNER,
    END_ENUM_RANGE(LAST_ATOMIC_RECORD_TNUM),
    END_ENUM_RANGE(LAST_ATOMIC_TNUM),
    END_ENUM_RANGE(LAST_SHARED_TNUM),
#endif

    END_ENUM_RANGE(LAST_REAL_TNUM),

#if !defined(USE_THREADSAFE_COPYING)
    // virtual TNUMs for copying objects
    START_ENUM_RANGE_EVEN(FIRST_COPYING_TNUM),
        COPYING             = FIRST_COPYING_TNUM - FIRST_IMM_MUT_TNUM,
        // we use LAST_EXTERNAL_TNUM+1 instead of LAST_REAL_TNUM to
        // skip over the shared TNUMs in HPC-GAP
    LAST_COPYING_TNUM       = LAST_EXTERNAL_TNUM + COPYING,
#endif
};

#if defined(USE_THREADSAFE_COPYING)
GAP_STATIC_ASSERT(LAST_REAL_TNUM <= 254, "LAST_REAL_TNUM is too large");
#else
GAP_STATIC_ASSERT(LAST_COPYING_TNUM <= 254, "LAST_COPYING_TNUM is too large");
#endif


/****************************************************************************
**
*F  TEST_OBJ_FLAG(<obj>, <flag>) . . . . . . . . . . . . . . test object flag
*F  SET_OBJ_FLAG(<obj>, <flag>) . . . . . . . . . . . . . . . set object flag
*F  CLEAR_OBJ_FLAG(<obj>, <flag>) . . . . . . . . . . . . . clear object flag
**
**  These three macros test, set, and clear object flags, respectively.
**  For non-immediate objects, these are simply the bag flags, see
**  TEST_BAG_FLAG, SET_BAG_FLAG, CLEAR_BAG_FLAG.
**
**  For immediate objects, objects flags are always 0.
*/
static inline uint8_t TEST_OBJ_FLAG(Obj obj, uint8_t flag)
{
    if (IS_BAG_REF(obj))
        return TEST_BAG_FLAG(obj, flag);
    else
        return 0;
}

static inline void SET_OBJ_FLAG(Obj obj, uint8_t flag)
{
    if (IS_BAG_REF(obj))
        SET_BAG_FLAG(obj, flag);
}

static inline void CLEAR_OBJ_FLAG(Obj obj, uint8_t flag)
{
    if (IS_BAG_REF(obj))
        CLEAR_BAG_FLAG(obj, flag);
}


/****************************************************************************
**
** Object flags for use with SET_OBJ_FLAG() etc.
**
*/

#define TESTING (1 << 0)

#ifdef HPCGAP
#define TESTED (1 << 1)
#endif


/****************************************************************************
**
*F  TNUM_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . type of an object
**
**  'TNUM_OBJ' returns the type of the object <obj>.
*/
static inline UInt TNUM_OBJ(Obj obj)
{
    if (IS_INTOBJ(obj))
        return T_INT;
    if (IS_FFE(obj))
        return T_FFE;
    return TNUM_BAG(obj);
}


/****************************************************************************
**
*F  TNAM_OBJ( <obj> ) . . . . . . . . . . . . . name of the type of an object
*/
static inline const Char * TNAM_OBJ(Obj obj)
{
    return InfoBags[TNUM_OBJ(obj)].name;
}


/****************************************************************************
**
*F  SIZE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . size of an object
**
**  'SIZE_OBJ' returns the size of the object <obj>.
*/
static inline UInt SIZE_OBJ(Obj obj)
{
    return SIZE_BAG(obj);
}


/****************************************************************************
**
*F  ADDR_OBJ( <obj> ) . . . . . . . . . . . . . absolute address of an object
**
**  'ADDR_OBJ' returns the absolute address of the memory block of the object
**  <obj>.
*/
static inline Obj *ADDR_OBJ(Obj obj)
{
    return PTR_BAG(obj);
}

static inline const Obj *CONST_ADDR_OBJ(Obj obj)
{
    return CONST_PTR_BAG(obj);
}


/****************************************************************************
**
*F  FAMILY_TYPE( <type> ) . . . . . . . . . . . . . . . . .  family of a type
**
**  'FAMILY_TYPE' returns the family of the type <type>.
*/
#define FAMILY_TYPE(type)       ELM_PLIST( type, 1 )


/****************************************************************************
**
*F  FAMILY_OBJ( <obj> ) . . . . . . . . . . . . . . . . . family of an object
*/
#define FAMILY_OBJ(obj)         FAMILY_TYPE( TYPE_OBJ(obj) )


/****************************************************************************
**
*F  FLAGS_TYPE( <type> ) . . . . . . . . . . . . flags boolean list of a type
**
**  'FLAGS_TYPE' returns the flags boolean list of the type <type>.
*/
#define FLAGS_TYPE(type)        ELM_PLIST( type, 2 )


/****************************************************************************
**
*F  DATA_TYPE( <type> ) . . . . . . . . . . . . . . . . shared data of a type
**
**  'DATA_TYPE' returns the shared data of the type <type>.
**  Not used by the GAP kernel right now, but useful for kernel extensions.
*/
#define DATA_TYPE(type)       ELM_PLIST( type, 3 )


/****************************************************************************
**
*F  ID_TYPE( <type> ) . . . . . . . . . . . . . . . . . . . . .  id of a type
**
**  'ID_TYPE' returns the ID of  a type.  Warning: if  GAP runs out of ID  it
**  will renumber all IDs.  Therefore the  corresponding routine must excatly
**  know where such numbers are stored.
*/
#define ID_TYPE(type) ELM_PLIST(type, 4)
#define SET_ID_TYPE(type, val) SET_ELM_PLIST(type, 4, val)


/****************************************************************************
**
*F  TYPE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . type of an object
**
**  'TYPE_OBJ' returns the type of the object <obj>.
*/
#define TYPE_OBJ(obj)   ((*TypeObjFuncs[ TNUM_OBJ(obj) ])( obj ))

extern Obj (*TypeObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );


/****************************************************************************
**
*F  SET_TYPE_OBJ( <obj>, <kind> ) . . . . . . . . . . . set kind of an object
**
**  'SET_TYPE_OBJ' sets the kind <kind>of the object <obj>.
*/
#define SET_TYPE_OBJ(obj, kind) \
  ((*SetTypeObjFuncs[ TNUM_OBJ(obj) ])( obj, kind ))

extern void (*SetTypeObjFuncs[ LAST_REAL_TNUM+1 ]) ( Obj obj, Obj kind );


/****************************************************************************
**
*F  MUTABLE_TNUM( <type> )  . . . . . . . . . . mutable type of internal type
*/
#define MUTABLE_TNUM(type) \
    ( ( (type) < FIRST_IMM_MUT_TNUM ? (type) : \
       ( LAST_IMM_MUT_TNUM < (type) ? (type) : \
        ( ((((type)-T_PLIST)&(~IMMUTABLE))+T_PLIST) ) ) ) )


/****************************************************************************
**
*F  IMMUTABLE_TNUM( <type> )  . . . . . . . . immutable type of internal type
*/
#define IMMUTABLE_TNUM(type) \
    ( ( (type) < FIRST_IMM_MUT_TNUM ? (type) : \
       ( LAST_IMM_MUT_TNUM < (type) ? (type) : \
        ( ((((type)-T_PLIST)|IMMUTABLE)+T_PLIST) ) ) ) )

/****************************************************************************
**
*F  MakeImmutable( <obj> ) . . . . . . . . . . . . . make an object immutable
*/
extern void MakeImmutable( Obj obj );

/****************************************************************************
**
*F  CheckedMakeImmutable( <obj> )  . . . . . . . . . make an object immutable
**
**  Same effect as MakeImmutable( <obj> ), but checks first that all
**  subobjects lie in a writable region.
*/

#ifdef HPCGAP
extern void CheckedMakeImmutable( Obj obj );
#endif

/****************************************************************************
**
*F  IS_MUTABLE_OBJ( <obj> ) . . . . . . . . . . . . . .  is an object mutable
**
**  'IS_MUTABLE_OBJ' returns   1 if the object  <obj> is mutable   (i.e., can
**  change due to assignments), and 0 otherwise.
*/
#define IS_MUTABLE_OBJ(obj) \
                        ((*IsMutableObjFuncs[ TNUM_OBJ(obj) ])( obj ))

extern Int (*IsMutableObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

/****************************************************************************
**
*F  IsInternallyMutableObj( <obj> ) . . . does an object have a mutable state
**
**  This function returns   1 if the object  <obj> has a mutable state, i.e.
**  if its internal representation can change even though its outwardly
**  visible properties do not, e.g. through code that transparently
**  reorganizes its structure.
*/

#ifdef HPCGAP
extern Int IsInternallyMutableObj(Obj obj);
#endif

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

extern void (*SaveObjFuncs[256]) ( Obj obj );

extern void SaveObjError( Obj obj );


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

extern void (*LoadObjFuncs[256]) ( Obj obj );

extern void LoadObjError( Obj obj );

/****************************************************************************
**
*F  IS_COPYABLE_OBJ( <obj> )  . . . . . . . . . . . . . is an object copyable
**
**  'IS_COPYABLE_OBJ' returns 1 if the object <obj> is copyable (i.e., can be
**  copied into a mutable object), and 0 otherwise.
*/
#define IS_COPYABLE_OBJ(obj) \
                        ((IsCopyableObjFuncs[ TNUM_OBJ(obj) ])( obj ))

extern Int (*IsCopyableObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );


/****************************************************************************
**
*F  SHALLOW_COPY_OBJ( <obj> ) . . . . . . .  make a shallow copy of an object
**
**  'SHALLOW_COPY_OBJ' makes a shallow copy of the object <obj>.
*/
#define SHALLOW_COPY_OBJ(obj) \
                        ((*ShallowCopyObjFuncs[ TNUM_OBJ(obj) ])( obj ))


/****************************************************************************
**
*V  ShallowCopyObjFuncs[<type>] . . . . . . . . . .  shallow copier functions
*/
extern Obj (*ShallowCopyObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );


/****************************************************************************
**
*F  CopyObj( <obj> )  . . . . . . . . . . make a structural copy of an object
**
**  'CopyObj' returns a  structural (deep) copy  of the object <obj>, i.e., a
**  recursive copy that preserves the structure.
*/
extern Obj CopyObj (
    Obj                 obj,
    Int                 mut );


/****************************************************************************
**
*F  COPY_OBJ(<obj>) . . . . . . . . . . . make a structural copy of an object
**
**  'COPY_OBJ'  implements  the first pass  of  'CopyObj', i.e., it makes the
**  structural copy of <obj> and marks <obj> as already copied.
**
**  Note that 'COPY_OBJ' and 'CLEAN_OBJ' are macros, so do not call them with
**  arguments that have side effects.
*/
#if !defined(USE_THREADSAFE_COPYING)
#define COPY_OBJ(obj,mut) \
                        ((*CopyObjFuncs[ TNUM_OBJ(obj) ])( obj, mut ))
#endif


/****************************************************************************
**
*F  CLEAN_OBJ(<obj>)  . . . . . . . . . . . . . clean up object after copying
**
**  'CLEAN_OBJ' implements the second pass of 'CopyObj', i.e., it removes the
**  mark <obj>.
**
**  Note that 'COPY_OBJ' and 'CLEAN_OBJ' are macros, so do not call them with
**  arguments that have side effects.
*/
#if !defined(USE_THREADSAFE_COPYING)
#define CLEAN_OBJ(obj) \
                        ((*CleanObjFuncs[ TNUM_OBJ(obj) ])( obj ))
#endif


/****************************************************************************
**
*V  CopyObjFuncs[<type>]  . . . . . . . . . . . .  table of copying functions
**
**  A package implementing a nonconstant object type <type> must provide such
**  functions      and     install them     in    'CopyObjFuncs[<type>]'  and
**  'CleanObjFuncs[<type>]'.
**
**  The function called  by 'COPY_OBJ' should  first create a  copy of <obj>,
**  somehow mark   <obj> as having  already been  copied, leave  a forwarding
**  pointer  to  the  copy  in <obj>,   and  then  copy all  subobjects  with
**  'COPY_OBJ'  recursively.  If  called   for an already  marked  object, it
**  should simply return the value  of the forward  pointer.  It should *not*
**  clear the mark, this is the job of 'CLEAN_OBJ' later.
**
**  The function  called by 'CLEAN_OBJ' should   clear the mark  left by the
**  corresponding 'COPY_OBJ' function,   remove the forwarding  pointer, and
**  then call 'CLEAN_OBJ'  for all subobjects recursively.  If called for an
**  already unmarked object, it should simply return.
*/
#if !defined(USE_THREADSAFE_COPYING)
extern Obj (*CopyObjFuncs[LAST_REAL_TNUM+COPYING+1]) ( Obj obj, Int mut );
#endif


/****************************************************************************
**
*V  CleanObjFuncs[<type>] . . . . . . . . . . . . table of cleaning functions
*/
#if !defined(USE_THREADSAFE_COPYING)
extern void (*CleanObjFuncs[LAST_REAL_TNUM+COPYING+1]) ( Obj obj );
#endif


extern void (*MakeImmutableObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

/****************************************************************************
**
*F  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
**
**  'PrintObj' prints the object <obj>.
*/
extern void PrintObj (
            Obj                 obj );


/****************************************************************************
**
*V  PrintObjFuncs[<type>] . . . . . . . .  printer for objects of type <type>
**
**  'PrintObjFuncs' is  the dispatch  table that  contains  for every type of
**  objects a pointer to the printer for objects of this  type.  The  printer
**  is the function '<func>(<obj>)' that should be called to print the object
**  <obj> of this type.
*/
/* TL: extern Obj  PrintObjThis; */

/* TL: extern Int  PrintObjIndex; */
/* TL: extern Int  PrintObjDepth; */

/* TL: extern Int  PrintObjFull; */

extern void (* PrintObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );


/****************************************************************************
**
*F  ViewObj( <obj> ) . . . . . . . . . . . . . . . . . . . . view an object
**
**  'ViewObj' views the object <obj>.
*/
extern void ViewObj (
            Obj                 obj );




/****************************************************************************
**
*V  PrintPathFuncs[<type>]  . . . . . . printer for subobjects of type <type>
**
**  'PrintPathFuncs'  is   the   dispatch table  that     contains for  every
**  appropriate type of objects a pointer to  the path printer for objects of
**  that type.  The path  printer is the function '<func>(<obj>,<indx>)' that
**  should be  called  to print  the  selector   that selects  the  <indx>-th
**  subobject of the object <obj> of this type.
**
**  These are also used for viewing
*/
extern void (* PrintPathFuncs[LAST_REAL_TNUM+1]) (
    Obj                 obj,
    Int                 indx );


/****************************************************************************
**
*F  IS_COMOBJ( <obj> )  . . . . . . . . . . . is an object a component object
*/
#define IS_COMOBJ(obj)            (TNUM_OBJ(obj) == T_COMOBJ)


/****************************************************************************
**
*F  TYPE_COMOBJ( <obj> )  . . . . . . . . . . . .  type of a component object
*/
#define TYPE_COMOBJ(obj)          ADDR_OBJ(obj)[0]


/****************************************************************************
**
*F  SET_TYPE_COMOBJ( <obj>, <val> ) . . .  set the type of a component object
*/
#define SET_TYPE_COMOBJ(obj,val)  (ADDR_OBJ(obj)[0] = (val))


/****************************************************************************
**
*F  IS_POSOBJ( <obj> )  . . . . . . . . . .  is an object a positional object
*/
#define IS_POSOBJ(obj)            (TNUM_OBJ(obj) == T_POSOBJ)


/****************************************************************************
**
*F  TYPE_POSOBJ( <obj> )  . . . . . . . . . . . . type of a positional object
*/
#define TYPE_POSOBJ(obj)          ADDR_OBJ(obj)[0]


/****************************************************************************
**
*F  SET_TYPE_POSOBJ( <obj>, <val> ) . . . set the type of a positional object
*/
#define SET_TYPE_POSOBJ(obj,val)  (ADDR_OBJ(obj)[0] = (val))


/****************************************************************************
**
*F  IS_DATOBJ( <obj> )  . . . . . . . . . . . . .  is an object a data object
*/
#define IS_DATOBJ(obj)            (TNUM_OBJ(obj) == T_DATOBJ)


/****************************************************************************
**
*F  TYPE_DATOBJ( <obj> )  . . . . . . . . . . . . . . . type of a data object
*/
#define TYPE_DATOBJ(obj)          ADDR_OBJ(obj)[0]


/****************************************************************************
**
*F  SetTypeDatobj( <obj>, <kind> ) . . . . . .  set the type of a data object
**
**  'SetTypeDatobj' sets the kind <kind> of the data object <obj>.
*/
extern void SetTypeDatObj( Obj obj, Obj type );

#define SET_TYPE_DATOBJ(obj, type)  SetTypeDatObj(obj, type)


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoObjects() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoObjects ( void );


#endif // GAP_OBJECTS_H
