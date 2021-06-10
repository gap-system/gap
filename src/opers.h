/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the  filters, operations, attributes,
**  and properties package.
*/

#ifndef GAP_OPERS_H
#define GAP_OPERS_H

#include "bool.h"
#include "calls.h"
#include "common.h"


enum {
    MAX_OPER_ARGS = 6
};

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
    Obj methods[MAX_OPER_ARGS+1];

    // cache of an operation
    Obj cache[MAX_OPER_ARGS+1];

    //
    Obj earlyMethod[MAX_OPER_ARGS+1];

    // small integer encoding a set of bit flags with information about the
    // operation, see OperExtras below
    //
    // note: this is encoded as an integer object, and not just stored
    // directly as C bitfield, to avoid the need for a custom marking function
    // which does not call 'MarkBag' on this field (while that would be safe
    // to do with GASMAN, it may not be in alternate GC implementations)
    Obj extra;
} OperBag;

enum OperExtras {
    OPER_IS_ATTR_STORING = (1 << 0),
    OPER_IS_FILTER       = (1 << 1),
};

/****************************************************************************
**
*V  TRY_NEXT_METHOD . . . . . . . . . . . . . . . . .  'TRY_NEXT_METHOD' flag
*/
extern Obj TRY_NEXT_METHOD;


/****************************************************************************
**
*F  IS_OPERATION( <obj> ) . . . . . . . . . . check if object is an operation
*/
EXPORT_INLINE BOOL IS_OPERATION(Obj obj)
{
    return TNUM_OBJ(obj) == T_FUNCTION && SIZE_OBJ(obj) == sizeof(OperBag);
}


/****************************************************************************
**
*F  OPER
*/
EXPORT_INLINE OperBag * OPER(Obj oper)
{
    GAP_ASSERT(IS_OPERATION(oper));
    return (OperBag *)ADDR_OBJ(oper);
}

EXPORT_INLINE const OperBag * CONST_OPER(Obj oper)
{
    GAP_ASSERT(IS_OPERATION(oper));
    return (const OperBag *)CONST_ADDR_OBJ(oper);
}


/****************************************************************************
**
*F  FLAG1_FILT( <oper> )  . . . . . . . . . .  flag 1 list of an 'and' filter
*/
EXPORT_INLINE Obj FLAG1_FILT(Obj oper)
{
    return CONST_OPER(oper)->flag1;
}

EXPORT_INLINE void SET_FLAG1_FILT(Obj oper, Obj x)
{
    OPER(oper)->flag1 = x;
}


/****************************************************************************
**
*F  FLAG2_FILT( <oper> )  . . . . . . . . . .  flag 2 list of an 'and' filter
*/
EXPORT_INLINE Obj FLAG2_FILT(Obj oper)
{
    return CONST_OPER(oper)->flag2;
}

EXPORT_INLINE void SET_FLAG2_FILT(Obj oper, Obj x)
{
    OPER(oper)->flag2 = x;
}


/****************************************************************************
**
*F  FLAGS_FILT( <oper> )  . . . . . . . . . . . . . . . . . flags of a filter
*/
EXPORT_INLINE Obj FLAGS_FILT(Obj oper)
{
    return CONST_OPER(oper)->flags;
}

EXPORT_INLINE void SET_FLAGS_FILT(Obj oper, Obj x)
{
    OPER(oper)->flags = x;
}


/****************************************************************************
**
*F  SETTER_FILT( <oper> ) . . . . . . . . . . . . . . . .  setter of a filter
*/
EXPORT_INLINE Obj SETTR_FILT(Obj oper)
{
    return CONST_OPER(oper)->setter;
}

EXPORT_INLINE void SET_SETTR_FILT(Obj oper, Obj x)
{
    OPER(oper)->setter = x;
}


/****************************************************************************
**
*F  TESTR_FILT( <oper> )  . . . . . . . . . . . . . . . .  tester of a filter
*/
EXPORT_INLINE Obj TESTR_FILT(Obj oper)
{
    return CONST_OPER(oper)->tester;
}

EXPORT_INLINE void SET_TESTR_FILT(Obj oper, Obj x)
{
    OPER(oper)->tester = x;
}


/****************************************************************************
**
*F  METHS_OPER( <oper> )  . . . . . . . . . . . . method list of an operation
*/
EXPORT_INLINE Obj METHS_OPER(Obj oper, Int i)
{
    GAP_ASSERT(0 <= i && i <= MAX_OPER_ARGS);
    return CONST_OPER(oper)->methods[i];
}

EXPORT_INLINE void SET_METHS_OPER(Obj oper, Int i, Obj x)
{
    GAP_ASSERT(0 <= i && i <= MAX_OPER_ARGS);
    OPER(oper)->methods[i] = x;
}


/****************************************************************************
**
*F  CACHE_OPER( <oper> )  . . . . . . . . . . . . . . . cache of an operation
*/
EXPORT_INLINE Obj CACHE_OPER(Obj oper, Int i)
{
    GAP_ASSERT(0 <= i && i <= MAX_OPER_ARGS);
    return CONST_OPER(oper)->cache[i];
}

EXPORT_INLINE void SET_CACHE_OPER(Obj oper, Int i, Obj x)
{
    GAP_ASSERT(0 <= i && i <= MAX_OPER_ARGS);
    OPER(oper)->cache[i] = x;
}


/****************************************************************************
**
*F  ENABLED_ATTR( <oper> ) . . . . true if the operation is an attribute and
**                                 storing is enabled (default) else false
*/
EXPORT_INLINE Int ENABLED_ATTR(Obj oper)
{
    Obj val = CONST_OPER(oper)->extra;
    Int v = val ? INT_INTOBJ(val) : 0;
    return v & OPER_IS_ATTR_STORING;
}


/****************************************************************************
**
*F  SET_ENABLED_ATTR( <oper>, <on> ) . set a new value that records whether 
**                                       storing is enabled for an operation
*/
EXPORT_INLINE void SET_ENABLED_ATTR(Obj oper, Int on)
{
    Obj val = CONST_OPER(oper)->extra;
    Int v = val ? INT_INTOBJ(val) : 0;
    if (on)
        v |= OPER_IS_ATTR_STORING;
    else
        v &= ~OPER_IS_ATTR_STORING;
    OPER(oper)->extra = INTOBJ_INT(v);
}

/****************************************************************************
**
*F  IS_FILTER( <oper> ) . . . . . . . . . . . . . check if object is a filter
*/
EXPORT_INLINE BOOL IS_FILTER(Obj oper)
{
    if (!IS_OPERATION(oper))
        return 0;
    Obj val = CONST_OPER(oper)->extra;
    Int v = val ? INT_INTOBJ(val) : 0;
    return v & OPER_IS_FILTER;
}


/****************************************************************************
**
*F  SET_IS_FILTER( <oper> ) . . . . . . . . . . .  mark operation as a filter
*/
EXPORT_INLINE void SET_IS_FILTER(Obj oper)
{
    Obj val = CONST_OPER(oper)->extra;
    Int v = val ? INT_INTOBJ(val) : 0;
    v |= OPER_IS_FILTER;
    OPER(oper)->extra = INTOBJ_INT(v);
}


/****************************************************************************
**
*F * * * * * * * * * * * * internal flags functions * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  NEW_FLAGS( <flags>, <len> ) . . . . . . . . . . . . . . .  new flags list
*/
EXPORT_INLINE Obj NEW_FLAGS(UInt len)
{
    UInt size = (3 + ((len+BIPEB-1) >> LBIPEB)) * sizeof(Obj);
    Obj flags = NewBag(T_FLAGS, size);
    return flags;
}


/****************************************************************************
**
*F  TRUES_FLAGS( <flags> )  . . . . . . . . . . list of trues of a flags list
**
**  returns the list of trues of <flags> or 0 if the list is not known yet.
*/
EXPORT_INLINE Obj TRUES_FLAGS(Obj flags)
{
    GAP_ASSERT(TNUM_OBJ(flags) == T_FLAGS);
    return CONST_ADDR_OBJ(flags)[0];
}


/****************************************************************************
**
*F  SET_TRUES_FLAGS( <flags>, <trues> ) . set number of trues of a flags list
*/
EXPORT_INLINE void SET_TRUES_FLAGS(Obj flags, Obj trues)
{
    GAP_ASSERT(TNUM_OBJ(flags) == T_FLAGS);
    ADDR_OBJ(flags)[0] = trues;
}


/****************************************************************************
**
*F  HASH_FLAGS( <flags> ) . . . . . . . . . . . .  hash value of <flags> or 0
*/
EXPORT_INLINE Obj HASH_FLAGS(Obj flags)
{
    GAP_ASSERT(TNUM_OBJ(flags) == T_FLAGS);
    return CONST_ADDR_OBJ(flags)[1];
}


/****************************************************************************
**
*F  SET_HASH_FLAGS( <flags>, <hash> ) . . . . . . . . . . . . . . .  set hash
*/
EXPORT_INLINE void SET_HASH_FLAGS(Obj flags, Obj hash)
{
    GAP_ASSERT(TNUM_OBJ(flags) == T_FLAGS);
    ADDR_OBJ(flags)[1] = hash;
}


/****************************************************************************
**
*F  LEN_FLAGS( <flags> )  . . . . . . . . . . . . . .  length of a flags list
*/
EXPORT_INLINE UInt LEN_FLAGS(Obj flags)
{
    return (SIZE_OBJ(flags) / sizeof(Obj) - 3) << LBIPEB;
}


/****************************************************************************
**
*F  AND_CACHE_FLAGS( <flags> )  . . . . . . . . . 'and' cache of a flags list
*/
EXPORT_INLINE Obj AND_CACHE_FLAGS(Obj list)
{
    GAP_ASSERT(TNUM_OBJ(list) == T_FLAGS);
    return CONST_ADDR_OBJ(list)[2];
}


/****************************************************************************
**
*F  SET_AND_CACHE_FLAGS( <flags>, <len> ) set the 'and' cache of a flags list
*/
EXPORT_INLINE void SET_AND_CACHE_FLAGS(Obj flags, Obj andc)
{
    GAP_ASSERT(TNUM_OBJ(flags) == T_FLAGS);
    ADDR_OBJ(flags)[2] = andc;
}


/****************************************************************************
**
*F  NRB_FLAGS( <flags> )  . . . . . .  number of basic blocks of a flags list
*/
EXPORT_INLINE UInt NRB_FLAGS(Obj flags)
{
    return SIZE_OBJ(flags) / sizeof(Obj) - 3;
}


/****************************************************************************
**
*F  BLOCKS_FLAGS( <flags> ) . . . . . . . . . . . . data area of a flags list
*/
EXPORT_INLINE UInt * BLOCKS_FLAGS(Obj flags)
{
    GAP_ASSERT(TNUM_OBJ(flags) == T_FLAGS);
    return (UInt *)(ADDR_OBJ(flags) + 3);
}


/****************************************************************************
**
*F  BLOCK_ELM_FLAGS( <list>, <pos> )  . . . . . . . .  block  of a flags list
**
**  'BLOCK_ELM_FLAGS' return the block containing the <pos>-th element of the
**  flags list <list> as a UInt value, which is also a  valid left hand side.
**  <pos>  must be a positive  integer  less than or  equal  to the length of
**  <list>.
*/
EXPORT_INLINE UInt BLOCK_ELM_FLAGS(Obj list, UInt pos)
{
    GAP_ASSERT(TNUM_OBJ(list) == T_FLAGS);
    GAP_ASSERT(pos <= LEN_FLAGS(list));
    return BLOCKS_FLAGS(list)[(pos - 1) >> LBIPEB];
}

/****************************************************************************
**
*F  MASK_POS_FLAGS( <pos> ) . . .  . .  bit mask for position of a flags list
**
**  'MASK_POS_FLAGS(<pos>)' returns a UInt with a single set  bit in position
**  '(<pos>-1) % BIPEB',
**  useful for accessing the <pos>-th element of a 'FLAGS' list.
**
*/
EXPORT_INLINE UInt MASK_POS_FLAGS(UInt pos)
{
    return ((UInt)1) << ((pos - 1) & (BIPEB - 1));
}


/****************************************************************************
**
*F  ELM_FLAGS( <list>, <pos> )  . . . . . . . . . . . element of a flags list
**
**  'ELM_FLAGS' return the <pos>-th element of the flags list <list>, which
**  is either 'true' or 'false'.  <pos> must  be a positive integer less than
**  or equal to the length of <hdList>.
**
**  'C_ELM_FLAGS' returns a result which it is better to use inside the kernel
**  since the C compiler can't know that True != False. Using C_ELM_FLAGS
**  gives slightly nicer C code and potential for a little more optimisation.
*/
EXPORT_INLINE Int C_ELM_FLAGS(Obj list, UInt pos)
{
     return (BLOCK_ELM_FLAGS(list, pos) & MASK_POS_FLAGS(pos)) != 0;
}

EXPORT_INLINE Obj ELM_FLAGS(Obj list, UInt pos)
{
    return C_ELM_FLAGS(list, pos) ? True : False;
}

EXPORT_INLINE Int SAFE_C_ELM_FLAGS(Obj flags, UInt pos)
{
    return (pos <= LEN_FLAGS(flags)) ? C_ELM_FLAGS(flags, pos) : 0;
}

EXPORT_INLINE Obj SAFE_ELM_FLAGS(Obj list, UInt pos)
{
    return SAFE_C_ELM_FLAGS(list, pos) ? True : False;
}


/****************************************************************************
**
*F  SET_ELM_FLAGS( <list>, <pos>, <val> ) . .  set an element of a flags list
**
**  'SET_ELM_FLAGS' sets  the element at position <pos>   in the flags list
**  <list> to True.  <pos> must be a positive integer less than or
**  equal to the length of <hdList>.
*/
EXPORT_INLINE void SET_ELM_FLAGS(Obj list, UInt pos)
{
    GAP_ASSERT(TNUM_OBJ(list) == T_FLAGS);
    GAP_ASSERT(pos <= LEN_FLAGS(list));
    BLOCKS_FLAGS(list)[(pos - 1) >> LBIPEB] |= MASK_POS_FLAGS(pos);
}


/****************************************************************************
**
*F  IS_SUBSET_FLAGS( <self>, <flags1>, <flags2> ) . . . . . . . . subset test
*/
BOOL IS_SUBSET_FLAGS(Obj flags1, Obj flags2);


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
*F  DoFilter( <self>, <obj> ) . . . . . . . . . . default handler for filters
*/
Obj DoFilter(Obj self, Obj obj);


/****************************************************************************
**
*F  NewFilter( <name>, <nams>, <hdlr> ) . . . . . . . . . . make a new filter
*/
Obj NewFilter(Obj name, Obj nams, ObjFunc_1ARGS hdlr);


/****************************************************************************
**
*F  NewAndFilter( <filt1>, <filt2> ) . . . . . make a new concatenated filter
*/
Obj NewAndFilter(Obj oper1, Obj oper2);


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
**  Default handlers for operations
*/
Obj DoOperation0Args(Obj oper);

Obj DoOperation1Args(Obj oper, Obj arg1);

Obj DoOperation2Args(Obj oper, Obj arg1, Obj arg2);

Obj DoOperation3Args(Obj oper, Obj arg1, Obj arg2, Obj arg3);

Obj DoOperation4Args(Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4);

Obj DoOperation5Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5);

Obj DoOperation6Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6);

Obj DoOperationXArgs(Obj self, Obj args);


/****************************************************************************
**
**  Default handlers for verbose operations
*/
Obj DoVerboseOperation0Args(Obj oper);

Obj DoVerboseOperation1Args(Obj oper, Obj arg1);

Obj DoVerboseOperation2Args(Obj oper, Obj arg1, Obj arg2);

Obj DoVerboseOperation3Args(Obj oper, Obj arg1, Obj arg2, Obj arg3);

Obj DoVerboseOperation4Args(Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4);

Obj DoVerboseOperation5Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5);

Obj DoVerboseOperation6Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6);

Obj DoVerboseOperationXArgs(Obj self, Obj args);


/****************************************************************************
**
*F  NewOperation( <name> ) . . . . . . . . . . . . . . . make a new operation
*/
Obj NewOperation(Obj name, Int narg, Obj nams, ObjFunc hdlr);


/****************************************************************************
**
*F  DoAttribute( <self>, <obj> ) . . . . . . . default handler for attributes
*/
Obj DoAttribute(Obj self, Obj obj);


/****************************************************************************
**
*F  DoTestAttribute( <self>, <obj> ) .  default handler for attribute testers
*/
Obj DoTestAttribute(Obj self, Obj obj);


/****************************************************************************
**
*F  NewAttribute( <name> ) . . . . . . . . . . . . . . . make a new attribute
*/
Obj NewAttribute(Obj name, Obj nams, ObjFunc_1ARGS hdlr);


/****************************************************************************
**
*F  DoProperty( <self>, <obj> ) . . . . . . .  default handler for properties
*/
Obj DoProperty(Obj self, Obj obj);


/****************************************************************************
**
*F  NewProperty( <name> ) . . . . . . . . . . . . . . . . make a new property
*/
Obj NewProperty(Obj name, Obj nams, ObjFunc_1ARGS hdlr);


/****************************************************************************
**
*F  InstallMethodArgs( <oper>, <func> ) . . . . . . . . . . .  clone function
**
**  There is a problem  with uncompleted functions: if  they are  cloned then
**  only   the orignal and not  the  clone will be  completed.  Therefore the
**  clone must postpone the real cloning.
*/
void InstallMethodArgs(Obj oper, Obj func);


/****************************************************************************
**
*F  ChangeDoOperations( <oper>, <verb> )
*/
void ChangeDoOperations(Obj oper, Int verb);


/****************************************************************************
**
*F  SaveOperationExtras( <oper> ) . . .  additional savng for functions which
**                                       are operations
**
**  This is called by SaveFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/
void SaveOperationExtras(Obj oper);


/****************************************************************************
**
*F  LoadOperationExtras( <oper> ) . .  additional loading for functions which
**                                       are operations
**
**  This is called by LoadFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/
void LoadOperationExtras(Obj oper);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoOpers() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoOpers ( void );


#endif // GAP_OPERS_H
