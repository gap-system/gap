/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file defines the functions of the objects package.
**
**  The objects package is the part that defines the 'Obj' type,  the objects
**  types  (i.e., the numbers  that  Gasman needs  to distinguish types), the
**  dispatcher for the printing of objects, etc.
*/

#ifndef GAP_OBJECTS_H
#define GAP_OBJECTS_H

#include "gasman.h"
#include "intobj.h"

#ifdef HPCGAP
#define USE_THREADSAFE_COPYING
#endif


/****************************************************************************
**
*t  Obj . . . . . . . . . . . . . . . . . . . . . . . . . . . type of objects
**
**  'Obj' is the type of objects.
**
**  The following is defined in "common.h"
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
EXPORT_INLINE BOOL IS_FFE(Obj o)
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
Int RegisterPackageTNUM(const char * name, Obj (*typeObjFunc)(Obj obj));


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

        // The next range contains all constant TNUMs for which multiplication
        // with an integer resp. powering by an integer makes sense
        START_ENUM_RANGE(FIRST_MULT_TNUM),
            T_INT,      // immediate
            T_INTPOS,
            T_INTNEG,
            T_RAT,
            T_CYC,
            T_FFE,      // immediate
            T_MACFLOAT,
            T_PERM2,
            T_PERM4,
            T_TRANS2,
            T_TRANS4,
            T_PPERM2,
            T_PPERM4,
        END_ENUM_RANGE(LAST_MULT_TNUM),

        T_BOOL,
        T_CHAR,

        T_FUNCTION,
        T_BODY,     // the type of function body bags
        T_FLAGS,
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

    // external types
    START_ENUM_RANGE(FIRST_EXTERNAL_TNUM),
        T_COMOBJ,
        T_POSOBJ,
        T_DATOBJ,
        T_WPOBJ,
#ifdef HPCGAP
        T_ACOMOBJ,
        T_APOSOBJ,
#endif
        // package TNUMs, for use by kernel extensions
        FIRST_PACKAGE_TNUM,
        LAST_PACKAGE_TNUM = 253,

    END_ENUM_RANGE(LAST_EXTERNAL_TNUM),

    END_ENUM_RANGE(LAST_REAL_TNUM),

#if !defined(USE_THREADSAFE_COPYING)
    T_COPYING,
#endif
};

#if !defined(USE_THREADSAFE_COPYING)
GAP_STATIC_ASSERT(T_COPYING <= 254, "T_COPYING is too large");
#else
GAP_STATIC_ASSERT(LAST_REAL_TNUM <= 254, "LAST_REAL_TNUM is too large");
#endif


/****************************************************************************
**
*F  TEST_OBJ_FLAG(<obj>, <flag>) . . . . . . . . . . . . . . test object flag
*F  SET_OBJ_FLAG(<obj>, <flag>) . . . . . . . . . . . . . . . set object flag
*F  CLEAR_OBJ_FLAG(<obj>, <flag>) . . . . . . . . . . . . . clear object flag
**
**  These three functions test, set, and clear object flags, respectively.
**  For non-immediate objects, these are simply the bag flags, see
**  TEST_BAG_FLAG, SET_BAG_FLAG, CLEAR_BAG_FLAG.
**
**  For immediate objects, objects flags are always 0.
*/
EXPORT_INLINE uint8_t TEST_OBJ_FLAG(Obj obj, uint8_t flag)
{
    if (IS_BAG_REF(obj))
        return TEST_BAG_FLAG(obj, flag);
    else
        return 0;
}

EXPORT_INLINE void SET_OBJ_FLAG(Obj obj, uint8_t flag)
{
    if (IS_BAG_REF(obj))
        SET_BAG_FLAG(obj, flag);
}

EXPORT_INLINE void CLEAR_OBJ_FLAG(Obj obj, uint8_t flag)
{
    if (IS_BAG_REF(obj))
        CLEAR_BAG_FLAG(obj, flag);
}


/****************************************************************************
**
**  Object flags for use with SET_OBJ_FLAG() etc.
**
*/
enum {
    // OBJ_FLAG_TESTING is used by KTNumPlist for tagging objects as they are
    // recursively traversed
    OBJ_FLAG_TESTING = (1 << 0),

#ifdef HPCGAP
    OBJ_FLAG_TESTED  = (1 << 1),
#endif
};


/****************************************************************************
**
*F  TNUM_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . type of an object
**
**  'TNUM_OBJ' returns the type of the object <obj>.
*/
EXPORT_INLINE UInt TNUM_OBJ(Obj obj)
{
    if (IS_INTOBJ(obj))
        return T_INT;
    if (IS_FFE(obj))
        return T_FFE;
    return TNUM_BAG(obj);
}


/****************************************************************************
**
*F  TNAM_TNUM( <obj> ) . . . . . . . . . . . . . . . . . . . . name of a type
*/
const Char * TNAM_TNUM(UInt tnum);


/****************************************************************************
**
*F  SET_TNAM_TNUM( <obj> ) . . . . . . . . . . . . . . set the name of a type
*/
void SET_TNAM_TNUM(UInt tnum, const Char * name);


/****************************************************************************
**
*F  TNAM_OBJ( <obj> ) . . . . . . . . . . . . . name of the type of an object
*/
EXPORT_INLINE const Char * TNAM_OBJ(Obj obj)
{
    return TNAM_TNUM(TNUM_OBJ(obj));
}


/****************************************************************************
**
*F  SIZE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . size of an object
**
**  'SIZE_OBJ' returns the size of the object <obj>.
*/
EXPORT_INLINE UInt SIZE_OBJ(Obj obj)
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
EXPORT_INLINE Obj *ADDR_OBJ(Obj obj)
{
    return PTR_BAG(obj);
}

EXPORT_INLINE const Obj *CONST_ADDR_OBJ(Obj obj)
{
    return CONST_PTR_BAG(obj);
}


/****************************************************************************
**
*S  POS_FAMILY_TYPE . . . . . . position where the family of a type is stored
*S  POS_FLAGS_TYPE . . . . . .  position where the flags of a type are stored
*S  POS_DATA_TYPE . . . . . . . . position where the data of a type is stored
*S  POS_NUMB_TYPE . . . . . . . position where the number of a type is stored
*S  POS_FIRST_FREE_TYPE . . . . .  first position that has no overall meaning
*/
enum {
    POS_FAMILY_TYPE = 1,
    POS_FLAGS_TYPE = 2,
    POS_DATA_TYPE = 3,
    POS_NUMB_TYPE = 4,
    POS_FIRST_FREE_TYPE = 5,
};


/****************************************************************************
**
*F  FAMILY_TYPE( <type> ) . . . . . . . . . . . . . . . . .  family of a type
**
**  'FAMILY_TYPE' returns the family of the type <type>.
*/
#define FAMILY_TYPE(type)       ELM_PLIST( type, POS_FAMILY_TYPE )


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
#define FLAGS_TYPE(type)        ELM_PLIST( type, POS_FLAGS_TYPE )


/****************************************************************************
**
*F  DATA_TYPE( <type> ) . . . . . . . . . . . . . . . . shared data of a type
**
**  'DATA_TYPE' returns the shared data of the type <type>.
**  Not used by the GAP kernel right now, but useful for kernel extensions.
*/
#define DATA_TYPE(type)       ELM_PLIST( type, POS_DATA_TYPE )


/****************************************************************************
**
*F  ID_TYPE( <type> ) . . . . . . . . . . . . . . . . . . . . .  id of a type
**
**  'ID_TYPE' returns the ID of  a type.  Warning: if  GAP runs out of ID  it
**  will renumber all IDs.  Therefore the  corresponding routine must exactly
**  know where such numbers are stored.
*/
#define ID_TYPE(type) ELM_PLIST(type, POS_NUMB_TYPE)
#define SET_ID_TYPE(type, val) SET_ELM_PLIST(type, POS_NUMB_TYPE, val)


/****************************************************************************
**
*F  TYPE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . type of an object
**
**  'TYPE_OBJ' returns the type of the object <obj>.
*/
extern Obj (*TypeObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );
EXPORT_INLINE Obj TYPE_OBJ(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return (*TypeObjFuncs[tnum])(obj);
}


/****************************************************************************
**
*F  SET_TYPE_OBJ( <obj>, <type> ) . . . . . . . . . . . set type of an object
**
**  'SET_TYPE_OBJ' sets the type of the object <obj> to <type>; if <obj>
**  is not a posobj/comobj/datobj, attempts to first convert it to one; if
**  that fails, an error is raised.
*/
void SET_TYPE_OBJ(Obj obj, Obj type);


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
void MakeImmutable(Obj obj);


/****************************************************************************
**
*F  MakeImmutableNoRecurse( <obj> ) . . set immutable flag on internal object
**
**  This is an unsafe helper function, for use in functions installed as
**  handlers in 'MakeImmutableObjFuncs' for internal objects tracking their
**  mutability, i.e., in the range FIRST_IMM_MUT_TNUM to LAST_IMM_MUT_TNUM.
**  It only modifies the TNUM, and does not make subobjects immutable.
*/
EXPORT_INLINE void MakeImmutableNoRecurse(Obj obj)
{
    UInt type = TNUM_OBJ(obj);
    GAP_ASSERT((FIRST_IMM_MUT_TNUM <= type) && (type <= LAST_IMM_MUT_TNUM));
    RetypeBag(obj, type | IMMUTABLE);
}


/****************************************************************************
**
*F  CheckedMakeImmutable( <obj> )  . . . . . . . . . make an object immutable
**
**  Same effect as MakeImmutable( <obj> ), but checks first that all
**  subobjects lie in a writable region.
*/

#ifdef HPCGAP
void CheckedMakeImmutable(Obj obj);
#endif

/****************************************************************************
**
*F  IS_MUTABLE_OBJ( <obj> ) . . . . . . . . . . . . . .  is an object mutable
**
**  'IS_MUTABLE_OBJ' returns   1 if the object  <obj> is mutable   (i.e., can
**  change due to assignments), and 0 otherwise.
*/
extern BOOL (*IsMutableObjFuncs[LAST_REAL_TNUM + 1])(Obj obj);
EXPORT_INLINE BOOL IS_MUTABLE_OBJ(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    if (/*FIRST_CONSTANT_TNUM <= tnum &&*/ tnum <= LAST_CONSTANT_TNUM)
        return FALSE;
    if (FIRST_IMM_MUT_TNUM <= tnum && tnum <= LAST_IMM_MUT_TNUM)
        return !(tnum & IMMUTABLE);
    return ((*IsMutableObjFuncs[tnum])(obj));
}


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
BOOL IsInternallyMutableObj(Obj obj);
#endif

/****************************************************************************
**
*V  SaveObjFuncs[ <type> ]  . . . . . . . . . . . . functions to save objects
**
**  'SaveObjFuncs' is the dispatch table that  contains, for every type
**  of  objects, a pointer to the saving function for objects of that type
**  These should not handle the file directly, but should work via the
**  functions 'SaveObjRef', 'SaveUInt<n>' (<n> = 1,2,4 or 8), and others
**  to be determined. Their role is to identify the C types of the various
**  parts of the bag, and perhaps to leave out some information that does
**  not need to be saved. By the time this function is called, the bag
**  size and type have already been saved.
**  No saving function may allocate any bag.
*/
#ifdef GAP_ENABLE_SAVELOAD
extern void (*SaveObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

void SaveObjError(Obj obj);
#endif


/****************************************************************************
**
*V  LoadObjFuncs[ <type> ]  . . . . . . . . . . . . functions to load objects
**
**  'LoadObjFuncs' is the dispatch table that  contains, for every type
**  of  objects, a pointer to the loading function for objects of that type
**  These should not handle the file directly, but should work via the
**  functions 'LoadObjRef', 'LoadUInt<n>' (<n> = 1,2,4 or 8), and others
**  to be determined. Their role is to reinstall the information in the bag
**  and reconstruct anything that was left out. By the time this function is
**  called, the bag size and type have already been loaded and the bag argument
**  contains the bag in question.
**  No loading function may allocate any bag.
*/
#ifdef GAP_ENABLE_SAVELOAD

extern void (*LoadObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );

void LoadObjError(Obj obj);
#endif


/****************************************************************************
**
*F  IS_COPYABLE_OBJ( <obj> )  . . . . . . . . . . . . . is an object copyable
**
**  'IS_COPYABLE_OBJ' returns 1 if the object <obj> is copyable (i.e., can be
**  copied into a mutable object), and 0 otherwise.
*/
extern BOOL (*IsCopyableObjFuncs[LAST_REAL_TNUM + 1])(Obj obj);
EXPORT_INLINE BOOL IS_COPYABLE_OBJ(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return (IsCopyableObjFuncs[tnum])(obj);
}


/****************************************************************************
**
*V  ShallowCopyObjFuncs[<type>] . . . . . . . . . .  shallow copier functions
*F  SHALLOW_COPY_OBJ( <obj> ) . . . . . . .  make a shallow copy of an object
**
**  'SHALLOW_COPY_OBJ' makes a shallow copy of the object <obj>.
*/
extern Obj (*ShallowCopyObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );
EXPORT_INLINE Obj SHALLOW_COPY_OBJ(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return (ShallowCopyObjFuncs[tnum])(obj);
}


/****************************************************************************
**
*F  CopyObj( <obj> )  . . . . . . . . . . make a structural copy of an object
**
**  'CopyObj' returns a  structural (deep) copy  of the object <obj>, i.e., a
**  recursive copy that preserves the structure.
*/
Obj CopyObj(Obj obj, Int mut);


/****************************************************************************
**
*F  COPY_OBJ(<obj>) . . . . . . . . . . . make a structural copy of an object
**
**  'COPY_OBJ'  implements  the first pass  of  'CopyObj', i.e., it makes the
**  structural copy of <obj> and marks <obj> as already copied.
**
**  'COPY_OBJ' must only be used from within CopyObjFuncs functions. To copy
**  an object from regular code, call 'CopyObj'.
*/
#if !defined(USE_THREADSAFE_COPYING)
Obj COPY_OBJ(Obj obj, Int mut);
#endif

/****************************************************************************
**
*F  PrepareCopy(<obj>,<copy>) . . .  helper for use in CopyObjFuncs functions
**
*/
#if !defined(USE_THREADSAFE_COPYING)
void PrepareCopy(Obj obj, Obj copy);
#endif


/****************************************************************************
**
*F  CLEAN_OBJ(<obj>)  . . . . . . . . . . . . . clean up object after copying
**
**  'CLEAN_OBJ' implements the second pass of 'CopyObj', i.e., it removes the
**  mark from <obj>.
*/
#if !defined(USE_THREADSAFE_COPYING)
void CLEAN_OBJ(Obj obj);
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
extern Obj (*CopyObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj, Int mut );
#endif


/****************************************************************************
**
*V  CleanObjFuncs[<type>] . . . . . . . . . . . . table of cleaning functions
*/
#if !defined(USE_THREADSAFE_COPYING)
extern void (*CleanObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );
#endif


/****************************************************************************
**
*V  MakeImmutableObjFuncs[<type>] . . . . . . . . . . . .  table of functions
*/
extern void (*MakeImmutableObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );


/****************************************************************************
**
*F  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
**
**  'PrintObj' prints the object <obj>.
*/
void PrintObj(Obj obj);

extern Obj PrintObjOper;

/****************************************************************************
**
**
*/
UInt SetPrintObjState(UInt state); // returns the old state
void SetPrintObjIndex(Int index);


/****************************************************************************
**
*V  PrintObjFuncs[<type>] . . . . . . . .  printer for objects of type <type>
**
**  'PrintObjFuncs' is  the dispatch  table that  contains  for every type of
**  objects a pointer to the printer for objects of this  type.  The  printer
**  is the function '<func>(<obj>)' that should be called to print the object
**  <obj> of this type.
*/
extern void (* PrintObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );
EXPORT_INLINE void PRINT_OBJ(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    (PrintObjFuncs[tnum])(obj);
}


/****************************************************************************
**
*F  ViewObj( <obj> ) . . . . . . . . . . . . . . . . . . . . view an object
**
**  'ViewObj' views the object <obj>.
*/
void ViewObj(Obj obj);


/****************************************************************************
**
*V  PrintPathFuncs[<type>]  . . . . . . printer for subobjects of type <type>
**
**  'PrintPathFuncs'  is   the   dispatch table  that     contains for  every
**  appropriate type of objects a pointer to  the path printer for objects of
**  that type.  The path  printer is the function '<func>(<obj>,<idx>)' that
**  should be  called  to print  the  selector   that selects  the  <idx>-th
**  subobject of the object <obj> of this type.
**
**  These are also used for viewing
*/
extern void (*PrintPathFuncs[LAST_REAL_TNUM + 1])(Obj obj, Int idx);
EXPORT_INLINE void PRINT_PATH(Obj obj, Int idx)
{
    UInt tnum = TNUM_OBJ(obj);
    (PrintPathFuncs[tnum])(obj, idx);
}


/****************************************************************************
**
*F  IS_COMOBJ( <obj> )  . . . . . . . . . . . is an object a component object
*/
EXPORT_INLINE BOOL IS_COMOBJ(Obj obj)
{
    return TNUM_OBJ(obj) == T_COMOBJ;
}


/****************************************************************************
**
*F  TYPE_COMOBJ( <obj> )  . . . . . . . . . . . .  type of a component object
*/
EXPORT_INLINE Obj TYPE_COMOBJ(Obj obj)
{
    return CONST_ADDR_OBJ(obj)[0];
}


/****************************************************************************
**
*F  SET_TYPE_COMOBJ( <obj>, <val> ) . . .  set the type of a component object
*/
EXPORT_INLINE void SET_TYPE_COMOBJ(Obj obj, Obj val)
{
    ADDR_OBJ(obj)[0] = val;
}


/****************************************************************************
**
*F  AssComObj( <obj>, <rnam>, <val> )
*F  UnbComObj( <obj>, <rnam> )
*F  ElmComObj( <obj>, <rnam> )
*F  IsbComObj( <obj>, <rnam> )
*/
void AssComObj(Obj obj, UInt rnam, Obj val);
void UnbComObj(Obj obj, UInt rnam);
Obj  ElmComObj(Obj obj, UInt rnam);
BOOL IsbComObj(Obj obj, UInt rnam);


/****************************************************************************
**
*F  IS_POSOBJ( <obj> )  . . . . . . . . . .  is an object a positional object
*/
EXPORT_INLINE BOOL IS_POSOBJ(Obj obj)
{
    return TNUM_OBJ(obj) == T_POSOBJ;
}


/****************************************************************************
**
*F  TYPE_POSOBJ( <obj> )  . . . . . . . . . . . . type of a positional object
*/
EXPORT_INLINE Obj TYPE_POSOBJ(Obj obj)
{
    return CONST_ADDR_OBJ(obj)[0];
}


/****************************************************************************
**
*F  SET_TYPE_POSOBJ( <obj>, <val> ) . . . set the type of a positional object
*/
EXPORT_INLINE void SET_TYPE_POSOBJ(Obj obj, Obj val)
{
    ADDR_OBJ(obj)[0] = val;
}


/****************************************************************************
**
*F  AssPosbj( <obj>, <rnam>, <val> )
*F  UnbPosbj( <obj>, <rnam> )
*F  ElmPosbj( <obj>, <rnam> )
*F  IsbPosbj( <obj>, <rnam> )
*/
void AssPosObj(Obj obj, Int idx, Obj val);
void UnbPosObj(Obj obj, Int idx);
Obj  ElmPosObj(Obj obj, Int idx);
BOOL IsbPosObj(Obj obj, Int idx);


/****************************************************************************
**
*F  IS_DATOBJ( <obj> )  . . . . . . . . . . . . .  is an object a data object
*/
EXPORT_INLINE BOOL IS_DATOBJ(Obj obj)
{
    return TNUM_OBJ(obj) == T_DATOBJ;
}


/****************************************************************************
**
*F  TYPE_DATOBJ( <obj> )  . . . . . . . . . . . . . . . type of a data object
*/
EXPORT_INLINE Obj TYPE_DATOBJ(Obj obj)
{
    return CONST_ADDR_OBJ(obj)[0];
}


/****************************************************************************
**
*F  SetTypeDatobj( <obj>, <kind> ) . . . . . .  set the type of a data object
**
**  'SetTypeDatobj' sets the kind <kind> of the data object <obj>.
*/
EXPORT_INLINE void SET_TYPE_DATOBJ(Obj obj, Obj val)
{
    ADDR_OBJ(obj)[0] = val;
}

void SetTypeDatObj(Obj obj, Obj type);


/****************************************************************************
**
*F  NewKernelBuffer( <size> )  . . . . . . . . . . return a new kernel buffer
**
**  Return a new T_DATOBJ of the specified <size>, with its type set to the
**  special value TYPE_KERNEL_OBJECT.
**
**  Note that <size> must include storage for the first slot of the bag,
**  which points to the type object.
*/
Obj NewKernelBuffer(UInt size);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoObjects() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoObjects ( void );


#endif // GAP_OBJECTS_H
