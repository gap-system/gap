/****************************************************************************
**
*W  vars.h                      GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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

#include <src/gapstate.h>   // for STATE

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
*V  BottomLVars . . . . . . . . . . . . . . . . .  bottom local variables bag
**
**  'BottomLVars' is the local variables bag at the bottom of the call stack.
**  Without   such a dummy  frame at  the bottom, 'SWITCH_TO_NEW_LVARS' would
**  have to check for the bottom, slowing it down.
**
*/
/* TL: extern  Bag             BottomLVars; */


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
static inline int IS_LVARS_OR_HVARS(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return tnum == T_LVARS || tnum == T_HVARS;
}


/****************************************************************************
**
*F  FUNC_LVARS . . . . . . . . . . . function to which the given lvars belong
**
*/
#define FUNC_LVARS_PTR(lvars_ptr)   (lvars_ptr[0])
#define FUNC_LVARS(lvars_obj)       FUNC_LVARS_PTR(ADDR_OBJ(lvars_obj))


/****************************************************************************
**
*F  PARENT_LVARS . . . . . . . . . . . . . .  parent lvars of the given lvars
**
*/
#define PARENT_LVARS_PTR(lvars_ptr) (lvars_ptr[2])
#define PARENT_LVARS(lvars_obj)     PARENT_LVARS_PTR(ADDR_OBJ(lvars_obj))


/****************************************************************************
**
*F  CURR_FUNC . . . . . . . . . . . . . . . . . . . . . . .  current function
**
**  'CURR_FUNC' is the function that is currently executing.
**
**  This  is  in this package,  because  it is stored   along  with the local
**  variables in the local variables bag.
*/
#define CURR_FUNC       FUNC_LVARS_PTR(STATE(PtrLVars))


/****************************************************************************
**
*F  BRK_CALL_TO() . . . . . . . . . expr. which was called from current frame
*F  SET_BRK_CALL_TO(expr) . . . set expr. which was called from current frame
*/

#ifdef TRACEFRAMES

extern Obj STEVES_TRACING;
extern Obj True;
#include <stdio.h>

static inline void SetBrkCallTo( Expr expr, char * file, int line ) {
  if (STEVES_TRACING == True) {
    fprintf(stderr,"SBCT: %i %x %s %i\n",
            (int)expr, (int)STATE(CurrLVars), file, line);
  }
  (STATE(PtrLVars)[1] = (Obj)(Int)(expr));
}

#else
#define SetBrkCallTo(expr, file, line)  (STATE(PtrLVars)[1] = (Obj)(Int)(expr))
#endif

#ifndef NO_BRK_CALLS
#define BRK_CALL_TO()                   ((Expr)(Int)(STATE(PtrLVars)[1]))
#define SET_BRK_CALL_TO(expr)           SetBrkCallTo(expr, __FILE__, __LINE__)
#else
#define BRK_CALL_TO()                   /* do nothing */
#define SET_BRK_CALL_TO(expr)           /* do nothing */
#endif


/****************************************************************************
**
*F  NewLVarsBag( <slots> ) . . make new lvars bag with <slots> variable slots
*F  FreeLVarsBag( <bag> )  . . . . . . . . . . . . . . . . . . free lvars bag
*/

Bag NewLVarsBag(UInt slots);
void FreeLVarsBag(Bag bag);

/****************************************************************************
**
*F  MakeHighVars( <bag> ) . . turn all frames on the stack into high vars
*/

static inline void MakeHighVars( Bag bag ) {
  while (bag && TNUM_OBJ(bag) == T_LVARS) {
    RetypeBag(bag, T_HVARS);
    bag = ADDR_OBJ(bag)[2];
  }
}


/****************************************************************************
**
*F  SET_CURR_LVARS
*/
static void SET_CURR_LVARS(Obj lvars)
{
    GAP_ASSERT(IS_LVARS_OR_HVARS(lvars));
    STATE(CurrLVars) = lvars;
    STATE(PtrLVars) = PTR_BAG(lvars);
    STATE(PtrBody) = (Stat *)PTR_BAG(BODY_FUNC(CURR_FUNC));
}


/****************************************************************************
**
*F  SWITCH_TO_NEW_LVARS( <func>, <narg>, <nloc>, <old> )  . . . . . new local
**
**  'SWITCH_TO_NEW_LVARS'  creates and switches  to a new local variabes bag,
**  for  the function    <func>,   with <narg> arguments    and  <nloc> local
**  variables.  The old local variables bag is saved in <old>.
*/

extern Obj STEVES_TRACING;

#include <stdio.h>

static inline Obj SwitchToNewLvars(Obj func, UInt narg, UInt nloc
#ifdef TRACEFRAMES
, char * file, int line
#endif
)
{
  Obj old = STATE(CurrLVars);
  CHANGED_BAG( old );
  STATE(CurrLVars) = NewLVarsBag( narg+nloc );
  STATE(PtrLVars)  = PTR_BAG( STATE(CurrLVars) );
  CURR_FUNC = func;
  STATE(PtrBody) = (Stat*)PTR_BAG(BODY_FUNC(CURR_FUNC));
  PARENT_LVARS_PTR(STATE(PtrLVars)) = old;
#ifdef TRACEFRAMES
  if (STEVES_TRACING == True) {
    Obj n = NAME_FUNC(func);
    Char *s = ((UInt)n) ? (Char *)CHARS_STRING(n) : (Char *)"nameless";
    fprintf(stderr,"STNL: %s %i\n   func %lx narg %i nloc %i function name %s\n     old lvars %lx new lvars %lx\n",
            file, line, (UInt) func, (int)narg, (int)nloc,s,(UInt)old, (UInt)STATE(CurrLVars));
  }
#endif
  return old;
}

#ifdef TRACEFRAMES
#define SWITCH_TO_NEW_LVARS(func, narg, nloc, old)     (old) = SwitchToNewLvars((func), (narg), (nloc), __FILE__, __LINE__)
#else
#define SWITCH_TO_NEW_LVARS(func, narg, nloc, old)     (old) = SwitchToNewLvars((func), (narg), (nloc))
#endif


/****************************************************************************
**
*F  SWITCH_TO_OLD_LVARS( <old> )  . . .  switch to an old local variables bag
**
**  'SWITCH_TO_OLD_LVARS' switches back to the old local variables bag <old>.
*/

static inline void SwitchToOldLVars( Obj old
#ifdef TRACEFRAMES
, char *file, int line
#endif
)
{
#ifdef TRACEFRAMES
  if (STEVES_TRACING == True) {
    fprintf(stderr,"STOL:  %s %i old lvars %lx new lvars %lx\n",
           file, line, (UInt)STATE(CurrLVars),(UInt)old);
  }
#endif
  CHANGED_BAG( STATE(CurrLVars) );
  SET_CURR_LVARS(old);
}

static inline void SwitchToOldLVarsAndFree( Obj old
#ifdef TRACEFRAMES
, char *file, int line
#endif
)
{
#ifdef TRACEFRAMES
  if (STEVES_TRACING == True) {
    fprintf(stderr,"STOL:  %s %i old lvars %lx new lvars %lx\n",
           file, line, (UInt)STATE(CurrLVars),(UInt)old);
  }
#endif
  // remove the link to the calling function, in case this values bag stays
  // alive due to higher variable reference
  PARENT_LVARS_PTR(STATE(PtrLVars)) = 0;

  CHANGED_BAG( STATE(CurrLVars) );
  if (STATE(CurrLVars) != old && TNUM_OBJ(STATE(CurrLVars)) == T_LVARS)
    FreeLVarsBag(STATE(CurrLVars));
  SET_CURR_LVARS(old);
}


#ifdef TRACEFRAMES
#define SWITCH_TO_OLD_LVARS(old) SwitchToOldLVars((old), __FILE__,__LINE__)
#else
#define SWITCH_TO_OLD_LVARS(old) SwitchToOldLVars((old))
#endif

#ifdef TRACEFRAMES
#define SWITCH_TO_OLD_LVARS_AND_FREE(old) SwitchToOldLVarsAndFree((old), __FILE__,__LINE__)
#else
#define SWITCH_TO_OLD_LVARS_AND_FREE(old) SwitchToOldLVarsAndFree((old))
#endif


/****************************************************************************
**
*F  ASS_LVAR( <lvar>, <val> ) . . . . . . . . . . .  assign to local variable
**
**  'ASS_LVAR' assigns the value <val> to the local variable <lvar>.
*/
#define ASS_LVAR(lvar,val)      (STATE(PtrLVars)[(lvar)+2] = (val))


/****************************************************************************
**
*F  OBJ_LVAR( <lvar> )  . . . . . . . . . . . . . . . value of local variable
**
**  'OBJ_LVAR' returns the value of the local variable <lvar>.
*/
#define OBJ_LVAR(lvar)          (STATE(PtrLVars)[(lvar)+2])


/****************************************************************************
**
*F  NAME_LVAR( <lvar> ) . . . . . . . . . . . . . . .  name of local variable
**
**  'NAME_LVAR' returns the name of the local variable <lvar> as a C string.
*/
#define NAME_LVAR(lvar)         NAMI_FUNC( CURR_FUNC, lvar )


/****************************************************************************
**
*F  ObjLVar(<lvar>) . . . . . . . . . . . . . . . . value of a local variable
**
**  'ObjLVar' returns the value of the local variable <lvar>.
*/
extern  Obj             ObjLVar (
            UInt                lvar );


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
**  'NAME_HVAR' returns the name of the higher variable <hvar> as a C string.
*/
extern  void            ASS_HVAR (
            UInt                hvar,
            Obj                 val );

extern  Obj             OBJ_HVAR (
            UInt                hvar );

extern  Char *          NAME_HVAR (
            UInt                hvar );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoVars()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoVars ( void );


#endif // GAP_VARS_H
