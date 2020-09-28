/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of variables package.
**
**  The variables  package is  the  part of   the interpreter  that  executes
**  assignments to variables and evaluates references to variables.
**
**  There are five  kinds of variables,  local variables (i.e., arguments and
**  locals), higher variables (i.e., local variables of enclosing functions),
**  global variables, list elements, and record elements.
*/

#ifndef GAP_VARS_H
#define GAP_VARS_H

#include "calls.h"
#include "gapstate.h"
#include "objects.h"


/****************************************************************************
**
*V  CurrLVars   . . . . . . . . . . . . . . . . . . . . . local variables bag
**
**  'CurrLVars'  is the bag containing the  values  of the local variables of
**  the currently executing interpreted function.
**
**  Assignments  to  the local variables change   this bag.  We  do  not call
**  'CHANGED_BAG' for  each of such change.  Instead we wait until  a garbage
**  collection begins  and then  call  'CHANGED_BAG'  in  'BeginCollectBags'.
*/
/* TL: extern  Bag             CurrLVars; */


/****************************************************************************
**
*F  IsBottomLVars(<lvars>) . . test whether lvars is at the call stack bottom
*/
BOOL IsBottomLVars(Obj lvars);


/****************************************************************************
**
*V  PtrLVars  . . . . . . . . . . . . . . . .  pointer to local variables bag
**
**  'PtrLVars' is a pointer to the 'CurrLVars' bag.  This  makes it faster to
**  access local variables.
**
**  Since   a   garbage collection may  move   this  bag  around, the pointer
**  'PtrLVars' must be recalculated afterwards in 'VarsAfterCollectBags'.
*/
/* TL: extern  Obj *           PtrLVars; */


/****************************************************************************
**
*F  IS_LVARS_OR_HVARS()
**
*/
EXPORT_INLINE BOOL IS_LVARS_OR_HVARS(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return tnum == T_LVARS || tnum == T_HVARS;
}


typedef struct {
    Expr stat;
    Obj func;
    Obj parent;
} LVarsHeader;

/****************************************************************************
**
*F  FUNC_LVARS . . . . . . . . . . . function to which the given lvars belong
**
*/
EXPORT_INLINE Obj FUNC_LVARS_PTR(const void * lvars_ptr)
{
    return ((const LVarsHeader *)lvars_ptr)->func;
}

EXPORT_INLINE Obj FUNC_LVARS(Obj lvars_obj)
{
    return FUNC_LVARS_PTR(CONST_ADDR_OBJ(lvars_obj));
}


/****************************************************************************
**
*F  STAT_LVARS . . . . . . . current statement in function of the given lvars
**
*/
EXPORT_INLINE Expr STAT_LVARS_PTR(const void * lvars_ptr)
{
    return ((const LVarsHeader *)lvars_ptr)->stat;
}

EXPORT_INLINE Expr STAT_LVARS(Obj lvars_obj)
{
    return STAT_LVARS_PTR(CONST_ADDR_OBJ(lvars_obj));
}


/****************************************************************************
**
*F  PARENT_LVARS . . . . . . . . . . . . . .  parent lvars of the given lvars
**
*/
EXPORT_INLINE Obj PARENT_LVARS_PTR(const void * lvars_ptr)
{
    return ((const LVarsHeader *)lvars_ptr)->parent;
}

EXPORT_INLINE Obj PARENT_LVARS(Obj lvars_obj)
{
    return PARENT_LVARS_PTR(CONST_ADDR_OBJ(lvars_obj));
}


/****************************************************************************
**
*F  CURR_FUNC . . . . . . . . . . . . . . . . . . . . . . .  current function
**
**  'CURR_FUNC' is the function that is currently executing.
**
**  This  is  in this package,  because  it is stored   along  with the local
**  variables in the local variables bag.
*/
EXPORT_INLINE Obj CURR_FUNC(void)
{
    GAP_ASSERT(IS_LVARS_OR_HVARS(STATE(CurrLVars)));
    GAP_ASSERT(STATE(PtrLVars) == PTR_BAG(STATE(CurrLVars)));
    return FUNC_LVARS_PTR(STATE(PtrLVars));
}


/****************************************************************************
**
*F  SET_BRK_CALL_TO(expr) . . . set expr. which was called from current frame
*/
EXPORT_INLINE void SET_BRK_CALL_TO(Expr expr)
{
    ((LVarsHeader *)STATE(PtrLVars))->stat = expr;
}


/****************************************************************************
**
*F  NewLVarsBag( <slots> ) . . make new lvars bag with <slots> variable slots
*F  FreeLVarsBag( <bag> )  . . . . . . . . . . . . . . . . . . free lvars bag
*/

Bag  NewLVarsBag(UInt slots);
void FreeLVarsBag(Bag bag);

/****************************************************************************
**
*F  MakeHighVars( <bag> ) . . turn all frames on the stack into high vars
*/

EXPORT_INLINE void MakeHighVars( Bag bag ) {
  while (bag && TNUM_OBJ(bag) == T_LVARS) {
    RetypeBag(bag, T_HVARS);
    bag = PARENT_LVARS(bag);
  }
}


/****************************************************************************
**
*F  SWITCH_TO_OLD_LVARS( <old> )  . . .  switch to an old local variables bag
**
**  'SWITCH_TO_OLD_LVARS' switches back to the old local variables bag <old>.
*/
EXPORT_INLINE Obj SWITCH_TO_OLD_LVARS(Obj old)
{
    // As an optimization, we never call CHANGED_BAG on CurrLVars directly,
    // instead a callback that is run just before any GC takes care of that.
    // However, that means that when changing the value of CurrLVars, we must
    // call CHANGED_BAG on the previous value.
    Obj prev = STATE(CurrLVars);
    CHANGED_BAG(prev);

    GAP_ASSERT(IS_LVARS_OR_HVARS(old));
    LVarsHeader * hdr = (LVarsHeader *)ADDR_OBJ(old);
    STATE(CurrLVars) = old;
    STATE(PtrLVars) = (Obj *)hdr;
    STATE(PtrBody) = ADDR_OBJ(BODY_FUNC(hdr->func));

    return prev;
}

EXPORT_INLINE void SWITCH_TO_OLD_LVARS_AND_FREE(Obj old)
{
  // remove the link to the calling function, in case this values bag stays
  // alive due to higher variable reference
  ((LVarsHeader *)STATE(PtrLVars))->parent = 0;

  if (STATE(CurrLVars) != old && TNUM_OBJ(STATE(CurrLVars)) == T_LVARS)
    FreeLVarsBag(STATE(CurrLVars));

  SWITCH_TO_OLD_LVARS(old);
}


/****************************************************************************
**
*F  SWITCH_TO_NEW_LVARS( <func>, <narg>, <nloc> ) . . . . switch to new lvars
**
**  'SWITCH_TO_NEW_LVARS'  creates and switches  to a new local variabes bag,
**  for  the function    <func>,   with <narg> arguments    and  <nloc> local
**  variables.  The old local variables bag is return.
*/
EXPORT_INLINE Obj SWITCH_TO_NEW_LVARS(Obj func, UInt narg, UInt nloc)
{
    // create new lvars (may cause garbage collection)
    Obj           new_lvars = NewLVarsBag(narg + nloc);
    LVarsHeader * hdr = (LVarsHeader *)ADDR_OBJ(new_lvars);
    hdr->stat = 0;
    hdr->func = func;
    hdr->parent = STATE(CurrLVars);

    return SWITCH_TO_OLD_LVARS(new_lvars);
}


/****************************************************************************
**
*F  SWITCH_TO_BOTTOM_LVARS( ) . . . . .  switch to bottom local variables bag
*/
Obj SWITCH_TO_BOTTOM_LVARS(void);


/****************************************************************************
**
*F  ASS_LVAR( <lvar>, <val> ) . . . . . . . . . . .  assign to local variable
**
**  'ASS_LVAR' assigns the value <val> to the local variable <lvar>.
*/
EXPORT_INLINE void ASS_LVAR(UInt lvar, Obj val)
{
    STATE(PtrLVars)[lvar + 2] = val;
}

EXPORT_INLINE void ASS_LVAR_WITH_CONTEXT(Obj context, UInt lvar, Obj val)
{
    ADDR_OBJ(context)[lvar + 2] = val;
}


/****************************************************************************
**
*F  OBJ_LVAR( <lvar> )  . . . . . . . . . . . . . . . value of local variable
**
**  'OBJ_LVAR' returns the value of the local variable <lvar>.
*/
EXPORT_INLINE Obj OBJ_LVAR(UInt lvar)
{
    return STATE(PtrLVars)[lvar + 2];
}

EXPORT_INLINE Obj OBJ_LVAR_WITH_CONTEXT(Obj context, UInt lvar)
{
    return CONST_ADDR_OBJ(context)[lvar + 2];
}


/****************************************************************************
**
*F  NAME_LVAR( <lvar> ) . . . . . . . . . . . . . . .  name of local variable
**
**  'NAME_LVAR' returns the name of the local variable <lvar>.
*/
EXPORT_INLINE Obj NAME_LVAR(UInt lvar)
{
    return NAMI_FUNC(CURR_FUNC(), lvar);
}

EXPORT_INLINE Obj NAME_LVAR_WITH_CONTEXT(Obj context, UInt lvar)
{
    return NAMI_FUNC(FUNC_LVARS(context), lvar);
}


/****************************************************************************
**
*F  ObjLVar(<lvar>) . . . . . . . . . . . . . . . . value of a local variable
**
**  'ObjLVar' returns the value of the local variable <lvar>.
*/
Obj ObjLVar(UInt lvar);


/****************************************************************************
**
*F  ASS_HVAR(<hvar>,<val>)  . . . . . . . . . . . assign to a higher variable
*F  OBJ_HVAR(<hvar>)  . . . . . . . . . . . . . .  value of a higher variable
*F  NAME_HVAR(<hvar>) . . . . . . . . . . . . . . . name of a higher variable
**
**  'ASS_HVAR' assigns the value <val> to the higher variable <hvar>.
**
**  'OBJ_HVAR' returns the value of the higher variable <hvar>.
**
**  'NAME_HVAR' returns the name of the higher variable <hvar>.
*/
void ASS_HVAR(UInt hvar, Obj val);
Obj  OBJ_HVAR(UInt hvar);
Obj  NAME_HVAR(UInt hvar);

void ASS_HVAR_WITH_CONTEXT(Obj context, UInt hvar, Obj val);
Obj  OBJ_HVAR_WITH_CONTEXT(Obj context, UInt hvar);
Obj  NAME_HVAR_WITH_CONTEXT(Obj context, UInt hvar);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoVars()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoVars ( void );


#endif // GAP_VARS_H
