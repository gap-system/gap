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
*F  IS_INTOBJ( <o> )  . . . . . . . .  test if an object is an integer object
**
**  'IS_INTOBJ' returns 1 if the object <o> is an (immediate) integer object,
**  and 0 otherwise.
*/
static inline Int IS_INTOBJ(Obj o)
{
    return (Int)o & 0x01;
}


/****************************************************************************
**
*F  IS_POS_INTOBJ( <o> )  . .  test if an object is a positive integer object
**
**  'IS_POS_INTOBJ' returns 1 if the object <o> is an (immediate) integer
**  object encoding a positive integer, and 0 otherwise.
*/
static inline Int IS_POS_INTOBJ(Obj o)
{
    return ((Int)o & 0x01) && ((Int)o > 0x01);
}


/****************************************************************************
**
*F  ARE_INTOBJS( <o1>, <o2> ) . . . . test if two objects are integer objects
**
**  'ARE_INTOBJS' returns 1 if the objects <o1> and <o2> are both (immediate)
**  integer objects.
*/
static inline Int ARE_INTOBJS(Obj o1, Obj o2)
{
    return (Int)o1 & (Int)o2 & 0x01;
}


/****************************************************************************
**
*F  INT_INTOBJ( <o> ) . . . . . . .  convert an integer object to a C integer
**
**  'INT_INTOBJ' converts the (immediate) integer object <o> to a C integer.
*/
/* Note that the C standard does not define what >> does here if the
 * value is negative. So we have to be careful if the C compiler
 * chooses to do a logical right shift. */
static inline Int INT_INTOBJ(Obj o)
{
    GAP_ASSERT(IS_INTOBJ(o));
#ifdef HAVE_ARITHRIGHTSHIFT
    return (Int)o >> 2;
#else
    return ((Int)o - 1) / 4;
#endif
}


/****************************************************************************
**
*F  INTOBJ_INT( <i> ) . . . . . . .  convert a C integer to an integer object
**
**  'INTOBJ_INT' converts the C integer <i> to an (immediate) integer object.
*/
static inline Obj INTOBJ_INT(Int i)
{
    Obj o;
    o = (Obj)(((UInt)i << 2) + 0x01);
    GAP_ASSERT(INT_INTOBJ(o) == i);
    return o;
}

/****************************************************************************
**
*F  EQ_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'EQ_INTOBJS' returns 'True' if the  (immediate)  integer  object  <l>  is
**  equal to the (immediate) integer object <r> and  'False'  otherwise.  The
**  result is also stored in <o>.
*/
#define EQ_INTOBJS(o,l,r) \
    ((o) = (((Int)(l)) == ((Int)(r)) ? True : False))


/****************************************************************************
**
*F  LT_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'LT_INTOBJS' returns 'True' if the  (immediate)  integer  object  <l>  is
**  less than the (immediate) integer object <r> and  'False' otherwise.  The
**  result is also stored in <o>.
*/
#define LT_INTOBJS(o,l,r) \
    ((o) = (((Int)(l)) <  ((Int)(r)) ? True : False))


/****************************************************************************
**
*F  SUM_INTOBJS( <o>, <l>, <r> )  . . . . . . . .  sum of two integer objects
**
**  'SUM_INTOBJS' returns  1  if  the  sum  of  the  (imm.)  integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The sum itself is stored in <o>.
*/
#define SUM_INTOBJS(o,l,r)             \
    ((o) = (Obj)((Int)(l)+(Int)(r)-1), \
     ((((UInt) (o)) >> (sizeof(UInt)*8-2))-1) > 1)


/****************************************************************************
**
*F  DIFF_INTOBJS( <o>, <l>, <r> ) . . . . . difference of two integer objects
**
**  'DIFF_INTOBJS' returns 1 if the difference of the (imm.) integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The difference itself is stored in <o>.
*/
#define DIFF_INTOBJS(o,l,r)            \
    ((o) = (Obj)((Int)(l)-(Int)(r)+1), \
     ((((UInt) (o)) >> (sizeof(UInt)*8-2))-1) > 1)


/****************************************************************************
**
*F  PROD_INTOBJS( <o>, <l>, <r> ) . . . . . .  product of two integer objects
**
**  'PROD_INTOBJS' returns 1 if the product of  the  (imm.)  integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The product itself is stored in <o>.
*/


#if SIZEOF_VOID_P == SIZEOF_INT && defined(HAVE___BUILTIN_SMUL_OVERFLOW) && defined(HAVE_ARITHRIGHTSHIFT)
static inline Obj prod_intobjs(int l, int r)
{
  int prod;
  if (__builtin_smul_overflow(l >> 1, r ^ 1, &prod))
    return (Obj) 0;
  return (Obj) ((prod >> 1) ^ 1);
}
#elif SIZEOF_VOID_P == SIZEOF_LONG && defined(HAVE___BUILTIN_SMULL_OVERFLOW) && defined(HAVE_ARITHRIGHTSHIFT)
static inline Obj prod_intobjs(long l, long r)
{
  long prod;
  if (__builtin_smull_overflow(l >> 1, r ^ 1, &prod))
    return (Obj) 0;
  return (Obj) ((prod >> 1) ^ 1);
}
#elif SIZEOF_VOID_P == SIZEOF_LONG_LONG && defined(HAVE___BUILTIN_SMULLL_OVERFLOW) && defined(HAVE_ARITHRIGHTSHIFT)
static inline Obj prod_intobjs(long long l, long long r)
{
  long long prod;
  if (__builtin_smulll_overflow(l >> 1, r ^ 1, &prod))
    return (Obj) 0;
  return (Obj) ((prod >> 1) ^ 1);
}
#else

#ifdef SYS_IS_64_BIT
#define HALF_A_WORD 32
#else
#define HALF_A_WORD 16
#endif

static inline Obj prod_intobjs(Int l, Int r)
{
  Int prod;
  if (l == (Int)INTOBJ_INT(0) || r == (Int)INTOBJ_INT(0))
    return INTOBJ_INT(0);
  if (l == (Int)INTOBJ_INT(1))
    return (Obj)r;
  if (r == (Int)INTOBJ_INT(1))
    return (Obj)l;
  prod = ((Int)((UInt)l >> 2) * ((UInt)r-1)+1);

  if (((((UInt) (prod)) >> (sizeof(UInt)*8-2))-1) <= 1)
    return (Obj) 0;

  if ((Int)(((UInt)l)<<HALF_A_WORD)>>HALF_A_WORD == (Int) l &&
      (Int)(((UInt)r)<<HALF_A_WORD)>>HALF_A_WORD == (Int) r)
    return (Obj) prod;

#ifdef HAVE_ARITHRIGHTSHIFT
  if ((prod -1) / (l >> 2) == r-1)
    return (Obj) prod;
#else
  if ((prod-1) / ((l-1)/4) == r-1)
    return (Obj) prod;
#endif

  return (Obj) 0;
}
#endif

#define PROD_INTOBJS( o, l, r) ((o) = prod_intobjs((Int)(l),(Int)(r)), \
                                  (o) != (Obj) 0)

/****************************************************************************
**
*F  IS_FFE( <o> ) . . . . . . . . test if an object is a finite field element
**
**  'IS_FFE'  returns 1  if the  object <o>  is  an  (immediate) finite field
**  element and 0 otherwise.
*/
#define IS_FFE(o)               \
                        ((Int)(o) & 0x02)


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
*F  NEXT_EVEN_INT( <n> )
**
**  Compute next even integer larger than <n>. Note that <n> must be a
**  positive, literal integer constant.
*/
#define NEXT_EVEN_INT(n)   ( (n+2UL) & ~1UL )

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
enum {
    FIRST_REAL_TNUM         = 0,

    FIRST_CONSTANT_TNUM     = FIRST_REAL_TNUM,
        T_INT               = FIRST_CONSTANT_TNUM,  // immediate
        T_INTPOS,
        T_INTNEG,
        T_RAT,
        T_CYC,
        T_FFE,                                      // immediate
        T_PERM2,
        T_PERM4,
        T_TRANS2,
        T_TRANS4,
        T_PPERM2,
        T_PPERM4,
        T_BOOL,
        T_CHAR,
        T_FUNCTION,
        T_FLAGS,
        T_MACFLOAT,
        T_LVARS,
        T_HVARS,
    LAST_CONSTANT_TNUM      = T_HVARS,

    IMMUTABLE               = 1,    // IMMUTABLE is not a TNUM, but rather a bitmask

    // first mutable/immutable TNUM
    FIRST_IMM_MUT_TNUM      = NEXT_EVEN_INT(LAST_CONSTANT_TNUM),

        // records
        FIRST_RECORD_TNUM                   = FIRST_IMM_MUT_TNUM,
            T_PREC                          = FIRST_RECORD_TNUM,
        LAST_RECORD_TNUM                    = T_PREC+IMMUTABLE,

        // lists
        FIRST_LIST_TNUM                     = NEXT_EVEN_INT(LAST_RECORD_TNUM),

            // plists
            FIRST_PLIST_TNUM                = FIRST_LIST_TNUM,
                T_PLIST                     = FIRST_LIST_TNUM+ 0,
                T_PLIST_NDENSE              = FIRST_LIST_TNUM+ 2,
                T_PLIST_DENSE               = FIRST_LIST_TNUM+ 4,
                T_PLIST_DENSE_NHOM          = FIRST_LIST_TNUM+ 6,
                T_PLIST_DENSE_NHOM_SSORT    = FIRST_LIST_TNUM+ 8,
                T_PLIST_DENSE_NHOM_NSORT    = FIRST_LIST_TNUM+10,
                T_PLIST_EMPTY               = FIRST_LIST_TNUM+12,
                T_PLIST_HOM                 = FIRST_LIST_TNUM+14,
                T_PLIST_HOM_NSORT           = FIRST_LIST_TNUM+16,
                T_PLIST_HOM_SSORT           = FIRST_LIST_TNUM+18,
                T_PLIST_TAB                 = FIRST_LIST_TNUM+20,
                T_PLIST_TAB_NSORT           = FIRST_LIST_TNUM+22,
                T_PLIST_TAB_SSORT           = FIRST_LIST_TNUM+24,
                T_PLIST_TAB_RECT            = FIRST_LIST_TNUM+26,
                T_PLIST_TAB_RECT_NSORT      = FIRST_LIST_TNUM+28,
                T_PLIST_TAB_RECT_SSORT      = FIRST_LIST_TNUM+30,
                T_PLIST_CYC                 = FIRST_LIST_TNUM+32,
                T_PLIST_CYC_NSORT           = FIRST_LIST_TNUM+34,
                T_PLIST_CYC_SSORT           = FIRST_LIST_TNUM+36,
                T_PLIST_FFE                 = FIRST_LIST_TNUM+38,
            LAST_PLIST_TNUM                 = T_PLIST_FFE+IMMUTABLE,

            // other kinds of lists
            T_RANGE_NSORT                   = FIRST_LIST_TNUM+40,
            T_RANGE_SSORT                   = FIRST_LIST_TNUM+42,
            T_BLIST                         = FIRST_LIST_TNUM+44,
            T_BLIST_NSORT                   = FIRST_LIST_TNUM+46,
            T_BLIST_SSORT                   = FIRST_LIST_TNUM+48,
            T_STRING                        = FIRST_LIST_TNUM+50,
            T_STRING_NSORT                  = FIRST_LIST_TNUM+52,
            T_STRING_SSORT                  = FIRST_LIST_TNUM+54,

        LAST_LIST_TNUM                      = T_STRING_SSORT+IMMUTABLE,

        // object sets and maps
        FIRST_OBJSET_TNUM                   = NEXT_EVEN_INT(LAST_LIST_TNUM),
            T_OBJSET                        = FIRST_OBJSET_TNUM+0,
            T_OBJMAP                        = FIRST_OBJSET_TNUM+2,
        LAST_OBJSET_TNUM                    = T_OBJMAP+IMMUTABLE,

    // last mutable/immutable TNUM
    LAST_IMM_MUT_TNUM       = LAST_OBJSET_TNUM,

    // external types (IMMUTABLE is not used for them, but keep the parity anyway)
    FIRST_EXTERNAL_TNUM     = NEXT_EVEN_INT(LAST_IMM_MUT_TNUM),
        T_COMOBJ            = FIRST_EXTERNAL_TNUM,
        T_POSOBJ,
        T_DATOBJ,
        T_WPOBJ,
#ifdef HPCGAP
        T_APOSOBJ,
        T_ACOMOBJ,
#endif

        // package TNUMs, for use by kernel extensions
        // note thatLAST_COPYING_TNUM must not exceed 253, which restricts
        // the value for LAST_PACKAGE_TNUM indirectly
        FIRST_PACKAGE_TNUM,
#ifdef HPCGAP
        LAST_PACKAGE_TNUM   = FIRST_PACKAGE_TNUM + 42,
#else
        LAST_PACKAGE_TNUM   = FIRST_PACKAGE_TNUM + 50,
#endif

    LAST_EXTERNAL_TNUM      = LAST_PACKAGE_TNUM,

#ifdef HPCGAP
    FIRST_SHARED_TNUM       = LAST_EXTERNAL_TNUM+1,
        // primitive types
        T_THREAD            = FIRST_SHARED_TNUM,
        T_MONITOR,
        T_REGION,
        // user-programmable types
        T_SEMAPHORE,
        T_CHANNEL,
        T_BARRIER,
        T_SYNCVAR,
        // atomic lists and records, thread local records
        T_FIXALIST,
        T_ALIST,
        T_AREC,
        T_AREC_INNER,
        T_TLREC,
        T_TLREC_INNER,
    LAST_SHARED_TNUM        = T_TLREC_INNER,
#endif

#ifdef HPCGAP
    LAST_REAL_TNUM          = LAST_SHARED_TNUM,
#else
    LAST_REAL_TNUM          = LAST_EXTERNAL_TNUM,
#endif

    // virtual TNUMs for copying objects
    FIRST_COPYING_TNUM      = NEXT_EVEN_INT(LAST_REAL_TNUM),
    COPYING                 = LAST_EXTERNAL_TNUM - FIRST_IMM_MUT_TNUM,
    LAST_COPYING_TNUM       = LAST_REAL_TNUM + COPYING,

    // the type of function body bags
    T_BODY                  = 254,
};

/****************************************************************************
**
** Object flags for use with SET_OBJ_FLAG() etc.
**
*/

enum {
    OBJ_FLAG_TESTING   = (1 << 0),
#ifdef HPCGAP
    OBJ_FLAG_TESTED    = (1 << 1),
#endif
    OBJ_FLAG_IMMUTABLE = (1 << 2),
};

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
#define SIZE_OBJ        SIZE_BAG


/****************************************************************************
**
*F  ADDR_OBJ( <obj> ) . . . . . . . . . . . . . absolute address of an object
**
**  'ADDR_OBJ' returns the absolute address of the memory block of the object
**  <obj>.
*/
#define ADDR_OBJ(bag)        PTR_BAG(bag)


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
extern Int (*IsMutableObjFuncs[LAST_REAL_TNUM+1]) ( Obj obj );
static inline Int IS_MUTABLE_OBJ(Obj obj)
{
    if(IS_INTOBJ(obj) || IS_FFE(obj)) {
        return 0;
    } else if (TEST_OBJ_FLAG(obj, OBJ_FLAG_IMMUTABLE) == OBJ_FLAG_IMMUTABLE) {
        return 0;
    } else {
        return ((*IsMutableObjFuncs[TNUM_OBJ(obj)])(obj));
    }
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
#define COPY_OBJ(obj,mut) \
                        ((*CopyObjFuncs[ TNUM_OBJ(obj) ])( obj, mut ))


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
#define CLEAN_OBJ(obj) \
                        ((*CleanObjFuncs[ TNUM_OBJ(obj) ])( obj ))



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
extern Obj (*CopyObjFuncs[LAST_REAL_TNUM+COPYING+1]) ( Obj obj, Int mut );



/****************************************************************************
**
*V  CleanObjFuncs[<type>] . . . . . . . . . . . . table of cleaning functions
*/
extern void (*CleanObjFuncs[LAST_REAL_TNUM+COPYING+1]) ( Obj obj );


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
