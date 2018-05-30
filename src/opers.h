/****************************************************************************
**
*W  opers.h                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the  filters, operations, attributes,
**  and properties package.
*/

#ifndef GAP_OPERS_H
#define GAP_OPERS_H

#include <src/system.h>
#include <src/calls.h>
#include <src/bool.h>


/****************************************************************************
**
**
*/
typedef struct {
    // an operation is a T_FUNCTION with additional data
    FuncBag func;

    // flag 1 list of an 'and' filter
    Obj flag1;

    // flag 2 list of an 'and' filter
    Obj flag2;

    // flags of a filter
    Obj flags;

    // setter of a filter
    Obj setter;

    // tester of a filter
    Obj tester;

    // method list of an operation
    Obj methods[8];

    // cache of an operation
    Obj cache[8];

    // 1 if the operation is an attribute and storing is enabled (default)
    // else 0
    Obj enabled;
} OperBag;


/****************************************************************************
**
*V  TRY_NEXT_METHOD . . . . . . . . . . . . . . . . .  'TRY_NEXT_METHOD' flag
*/
extern Obj TRY_NEXT_METHOD;


/****************************************************************************
**
*F  IS_OPERATION( <obj> ) . . . . . . . . . . check if object is an operation
*/
static inline Int IS_OPERATION(Obj func)
{
    return TNUM_OBJ(func) == T_FUNCTION && SIZE_OBJ(func) == sizeof(OperBag);
}


/****************************************************************************
**
*F  OPER
*/
static inline OperBag * OPER(Obj oper)
{
    GAP_ASSERT(IS_OPERATION(oper));
    return (OperBag *)ADDR_OBJ(oper);
}

static inline const OperBag * CONST_OPER(Obj oper)
{
    GAP_ASSERT(IS_OPERATION(oper));
    return (const OperBag *)CONST_ADDR_OBJ(oper);
}


/****************************************************************************
**
*F  FLAG1_FILT( <oper> )  . . . . . . . . . .  flag 1 list of an 'and' filter
*/
static inline Obj FLAG1_FILT(Obj oper)
{
    return CONST_OPER(oper)->flag1;
}

static inline void SET_FLAG1_FILT(Obj oper, Obj x)
{
    OPER(oper)->flag1 = x;
}


/****************************************************************************
**
*F  FLAG2_FILT( <oper> )  . . . . . . . . . .  flag 2 list of an 'and' filter
*/
static inline Obj FLAG2_FILT(Obj oper)
{
    return CONST_OPER(oper)->flag2;
}

static inline void SET_FLAG2_FILT(Obj oper, Obj x)
{
    OPER(oper)->flag2 = x;
}


/****************************************************************************
**
*F  FLAGS_FILT( <oper> )  . . . . . . . . . . . . . . . . . flags of a filter
*/
static inline Obj FLAGS_FILT(Obj oper)
{
    return CONST_OPER(oper)->flags;
}

static inline void SET_FLAGS_FILT(Obj oper, Obj x)
{
    OPER(oper)->flags = x;
}


/****************************************************************************
**
*F  SETTER_FILT( <oper> ) . . . . . . . . . . . . . . . .  setter of a filter
*/
static inline Obj SETTR_FILT(Obj oper)
{
    return CONST_OPER(oper)->setter;
}

static inline void SET_SETTR_FILT(Obj oper, Obj x)
{
    OPER(oper)->setter = x;
}


/****************************************************************************
**
*F  TESTR_FILT( <oper> )  . . . . . . . . . . . . . . . .  tester of a filter
*/
static inline Obj TESTR_FILT(Obj oper)
{
    return CONST_OPER(oper)->tester;
}

static inline void SET_TESTR_FILT(Obj oper, Obj x)
{
    OPER(oper)->tester = x;
}


/****************************************************************************
**
*F  METHS_OPER( <oper> )  . . . . . . . . . . . . method list of an operation
*/
static inline Obj METHS_OPER(Obj oper, Int i)
{
    GAP_ASSERT(0 <= i && i < 8);
    return CONST_OPER(oper)->methods[i];
}

static inline void SET_METHS_OPER(Obj oper, Int i, Obj x)
{
    GAP_ASSERT(0 <= i && i < 8);
    OPER(oper)->methods[i] = x;
}


/****************************************************************************
**
*F  CACHE_OPER( <oper> )  . . . . . . . . . . . . . . . cache of an operation
*/
static inline Obj CACHE_OPER(Obj oper, Int i)
{
    GAP_ASSERT(0 <= i && i < 8);
    return CONST_OPER(oper)->cache[i];
}

static inline void SET_CACHE_OPER(Obj oper, Int i, Obj x)
{
    GAP_ASSERT(0 <= i && i < 8);
    OPER(oper)->cache[i] = x;
}


/****************************************************************************
**
*F  ENABLED_ATTR( <oper> ) . . . . true if the operation is an attribute and
**                                 storing is enabled (default) else false
*/
static inline Int ENABLED_ATTR(Obj oper)
{
    Obj val = CONST_OPER(oper)->enabled;
    return val ? INT_INTOBJ(val) : 0;
}


/****************************************************************************
**
*F  SET_ENABLED_ATTR( <oper>, <new> )  . set a new value that records whether
**                                       storing is enabled for an operation
*/
static inline void SET_ENABLED_ATTR(Obj oper, Int x)
{
    OPER(oper)->enabled = INTOBJ_INT(x);
}


/****************************************************************************
**
*F * * * * * * * * * * * * internal flags functions * * * * * * * * * * * * *
**
** Attempting change April 2018. Flags will be stored as
** AND_CACHE -- Obj (put this first for GASMAN's convenience)
** Size (UInt)  -- could possibly be a UInt2 instead
** Hash (UInt)
** Sorted (increasing) array of filter numbers, stored as UInt2s
*/

typedef struct {
    Obj andCache;     // cache for AND_FLAGS results (or 0 if no cache
                      // allocated yet)
    UInt  size;       // number of filters set in flag
    UInt  hash;       // hash value of flag if computed (or 0)
    UInt2 trues[];    // filter numbers in increasing order
} FlagsHeader;


/****************************************************************************
**
*F  SIZE_PLEN_FLAGS( <fsize> ) . .  bag size for a flags list with <fsize>
*trues
*/
static inline UInt SIZE_PLEN_FLAGS(UInt fsize)
{
    return sizeof(FlagsHeader) + 2 * fsize;
}

/****************************************************************************
**
*F  NEW_FLAGS( <flags>, <len> ) . . . . . . . . . . . . . . .  new flags list
*/

static inline Obj NEW_FLAGS(UInt len)
{
    Obj flags = NewBag(T_FLAGS, SIZE_PLEN_FLAGS(len));
    return flags;
}

/****************************************************************************
**
*F  HEADER_FLAGS( <flags> ) . . . . . . . . . . . address of header struct
*/

static inline FlagsHeader* HEADER_FLAGS(Obj flags) {
    return (FlagsHeader *)ADDR_OBJ(flags);
}

static inline const FlagsHeader* CONST_HEADER_FLAGS(Obj flags) {
    return (const FlagsHeader *)CONST_ADDR_OBJ(flags);
}

/****************************************************************************
**
*F  SIZE_FLAGS( <flags> ) . . . . . . . . . . .number of true of <flags>
*/
static inline UInt SIZE_FLAGS(Obj flags)
{    
    return CONST_HEADER_FLAGS(flags)->size;
}

/****************************************************************************
**
*F  SET_SIZE_FLAGS( <flags>, <hash> ) . . . . . . . . . . . . . . .  set size
*/
static inline void SET_SIZE_FLAGS(Obj flags, UInt size)
{
    HEADER_FLAGS(flags)->size = size;
}

/****************************************************************************
**
*F  HASH_FLAGS( <flags> ) . . . . . . . . . . . .  hash value of <flags> or 0
*/
static inline UInt HASH_FLAGS(Obj flags)
{
    return CONST_HEADER_FLAGS(flags)->hash;
}

/****************************************************************************
**
*F  SET_HASH_FLAGS( <flags> ) . . . . . . . . . .  set  hash value of <flags>
*/
static inline void SET_HASH_FLAGS(Obj flags, UInt hash)
{
    HEADER_FLAGS(flags)->hash = hash;
}

/****************************************************************************
**
*F  AND_CACHE_FLAGS( <flags> )  . . . . . . . . . 'and' cache of a flags list
*/
static inline Obj AND_CACHE_FLAGS(Obj flags)
{
    return CONST_HEADER_FLAGS(flags)->andCache;
}


/****************************************************************************
**
*F  SET_AND_CACHE_FLAGS( <flags>, <len> ) set the 'and' cache of a flags list
*/
static inline void SET_AND_CACHE_FLAGS(Obj flags, Obj andc)
{
    HEADER_FLAGS(flags)->andCache = andc;
}

static inline const UInt2* ADDR_TRUES_FLAGS(Obj flags)
{
    return &(HEADER_FLAGS(flags)->trues[0]);
}

/****************************************************************************
**
*F  TRUE_FLAGS( <flags>, <ix> )  the <ix>th set position in flags
**                               caller is responsible for <ix> being in range
*/

static inline UInt TRUE_FLAGS(Obj flags, UInt ix)
{
    return (UInt)(CONST_HEADER_FLAGS(flags)->trues[ix]);
}

/****************************************************************************
**
*F  SET_TRUE_FLAGS( <flags>, <ix>, <filt> )  the <ix>th set position in flags
**                               caller is responsible for <ix> being in range
*/

static inline void SET_TRUE_FLAGS(Obj flags, UInt ix, UInt2 filt)
{
    HEADER_FLAGS(flags)->trues[ix] = filt;
}

/****************************************************************************
**
*F  FILT_IN_FLAGS( <list>, <filt> )  . . whether flags includes a filter
**
** returns 1 or 0
*/
extern UInt FILT_IN_FLAGS(Obj list, UInt filt);


/****************************************************************************
**
*F  FuncIS_SUBSET_FLAGS( <self>, <flags1>, <flags2> ) . . . . . . subset test
**
*T  export a proper function, rather than a handler
*/

extern Obj FuncIS_SUBSET_FLAGS(Obj self, Obj flags1, Obj flags2);

/****************************************************************************
**
*F * * * * * * * * * * *  internal filter functions * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  SET_FILTER_OBJ  . . . . . . . . . . . .  library function to set a filter
*/
extern Obj SET_FILTER_OBJ;


/****************************************************************************
**
*V  RESET_FILTER_OBJ  . . . . . . . . . .  library function to reset a filter
*/
extern Obj RESET_FILTER_OBJ;


/****************************************************************************
**
*F  SetterFilter( <oper> )  . . . . . . . . . . . . . . .  setter of a filter
*/
extern Obj SetterFilter(Obj oper);


/****************************************************************************
**
*F  SetterAndFilter( <getter> )  . . . . . .  setter of a concatenated filter
*/
extern Obj DoSetAndFilter(Obj self, Obj obj, Obj val);

extern Obj SetterAndFilter(Obj getter);


/****************************************************************************
**
*F  TesterFilter( <oper> )  . . . . . . . . . . . . . . .  tester of a filter
*/
extern Obj TesterFilter(Obj oper);


/****************************************************************************
**
*F  TestAndFilter( <getter> )  . . . . . . . .tester of a concatenated filter
*/
extern Obj DoTestAndFilter(Obj self, Obj obj);

extern Obj TesterAndFilter(Obj getter);


/****************************************************************************
**
*F  NewFilter( <name>, <narg>, <nams>, <hdlr> )  . . . . .  make a new filter
*/
extern Obj NewTesterFilter(Obj getter);

extern Obj DoSetFilter(Obj self, Obj obj, Obj val);

extern Obj NewSetterFilter(Obj getter);

extern Obj DoFilter(Obj self, Obj obj);

extern Obj NewFilter(Obj name, Int narg, Obj nams, ObjFunc hdlr);


extern Obj DoTestAttribute(Obj self, Obj obj);

/****************************************************************************
**
*F  NewAndFilter( <filt1>, <filt2> ) . . . . . make a new concatenated filter
*/
extern Obj DoAndFilter(Obj self, Obj obj);

extern Obj NewAndFilter(Obj oper1, Obj oper2);


/****************************************************************************
**
*V  ReturnTrueFilter . . . . . . . . . . . . . . . . the return 'true' filter
*/
extern Obj ReturnTrueFilter;


/****************************************************************************
**
*F * * * * * * * * * *  internal operation functions  * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  NewOperation( <name> )  . . . . . . . . . . . . . .  make a new operation
*/
extern Obj DoOperation0Args(Obj oper);

extern Obj DoOperation1Args(Obj oper, Obj arg1);

extern Obj DoOperation2Args(Obj oper, Obj arg1, Obj arg2);

extern Obj DoOperation3Args(Obj oper, Obj arg1, Obj arg2, Obj arg3);

extern Obj DoOperation4Args(Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4);

extern Obj
DoOperation5Args(Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5);

extern Obj DoOperation6Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6);

extern Obj DoOperationXArgs(Obj self, Obj args);

extern Obj DoVerboseOperation0Args(Obj oper);

extern Obj DoVerboseOperation1Args(Obj oper, Obj arg1);

extern Obj DoVerboseOperation2Args(Obj oper, Obj arg1, Obj arg2);

extern Obj DoVerboseOperation3Args(Obj oper, Obj arg1, Obj arg2, Obj arg3);

extern Obj
DoVerboseOperation4Args(Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4);

extern Obj DoVerboseOperation5Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5);

extern Obj DoVerboseOperation6Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6);

extern Obj DoVerboseOperationXArgs(Obj self, Obj args);

extern Obj NewOperation(Obj name, Int narg, Obj nams, ObjFunc hdlr);


/****************************************************************************
**
*F  NewAttribute( <name> )  . . . . . . . . . . . . . .  make a new attribute
*/
extern Obj DoAttribute(Obj self, Obj obj);

extern Obj DoVerboseAttribute(Obj self, Obj obj);

extern Obj NewAttribute(Obj name, Int narg, Obj nams, ObjFunc hdlr);

/****************************************************************************
**
*F  NewProperty( <name> ) . . . . . . . . . . . . . . . . make a new property
*/
extern Obj DoProperty(Obj self, Obj obj);

extern Obj NewProperty(Obj name, Int narg, Obj nams, ObjFunc hdlr);

/****************************************************************************
**
*F  InstallMethodArgs( <oper>, <func> ) . . . . . . . . . . .  clone function
**
**  There is a problem  with uncompleted functions: if  they are  cloned then
**  only   the orignal and not  the  clone will be  completed.  Therefore the
**  clone must postpone the real cloning.
*/
extern void InstallMethodArgs(Obj oper, Obj func);


/****************************************************************************
**
*F  ChangeDoOperations( <oper>, <verb> )
*/
extern void ChangeDoOperations(Obj oper, Int verb);

/****************************************************************************
**
*F  SaveOperationExtras( <oper> ) . . .  additional savng for functions which
**                                       are operations
**
**  This is called by SaveFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/

extern void SaveOperationExtras(Obj oper);

/****************************************************************************
**
*F  LoadOperationExtras( <oper> ) . .  additional loading for functions which
**                                       are operations
**
**  This is called by LoadFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/

extern void LoadOperationExtras(Obj oper);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoOpers() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoOpers(void);


#endif    // GAP_OPERS_H
