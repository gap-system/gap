/****************************************************************************
**
*A  vars.h                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_vars_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**
*F  CURR_FUNC . . . . . . . . . . . . . . . . . . . . . . .  current function
**
**  'CURR_FUNC' is the function that is currently executing.
**
**  This  is  in this package,  because  it is stored   along  with the local
**  variables in the local variables bag.
*/
#define CURR_FUNC       (PtrLVars[0])

#ifndef NO_BRK_CALLS
#define BRK_CALL_TO()                   (PtrLVars[1])
#define SET_BRK_CALL_TO(expr)           (PtrLVars[1] = (expr))
#define BRK_CALL_FROM()                 (PtrLVars[2])
#define SET_BRK_CALL_FROM(lvars)        (PtrLVars[2] = (lvars))
#endif
#ifdef  NO_BRK_CALLS
#define BRK_CALL_TO()                   /* do nothing */
#define SET_BRK_CALL_TO(expr)           /* do nothing */
#define BRK_CALL_FROM()                 /* do nothing */
#define SET_BRK_CALL_FROM(lvars)        /* do nothing */
#endif


/****************************************************************************
**
*F  SWITCH_TO_NEW_LVARS(<func>,<narg>,<nloc>,<old>) . . switch to a new local
*F  SWITCH_TO_OLD_LVARS(<old>)  . . . .  switch to an old local variables bag
**
**  'SWITCH_TO_NEW_LVARS'  creates and switches  to a new local variabes bag,
**  for  the function    <func>,   with <narg> arguments    and  <nloc> local
**  variables.  The old local variables bag is saved in <old>.
**
**  'SWITCH_TO_OLD_LVARS' switches back to the old local variables bag <old>.
*/
#define SWITCH_TO_NEW_LVARS(func,narg,nloc,old)                             \
                        do {                                                \
                            (old) = CurrLVars;                              \
                            CHANGED_BAG( (old) );                           \
                            CurrLVars = NewBag( T_LVARS,                    \
                                                sizeof(Obj)*(3+narg+nloc) );\
                            PtrLVars  = PTR_BAG( CurrLVars );               \
                            CURR_FUNC = (func);                             \
                            SET_BRK_CALL_FROM( old );                       \
                        } while ( 0 )

#define SWITCH_TO_OLD_LVARS(old)                                            \
                        do {                                                \
                            CurrLVars = (old);                              \
                            PtrLVars  = PTR_BAG( CurrLVars );               \
                        } while ( 0 )


/****************************************************************************
**
*V  CurrLVars   . . . . . . . . . . . . . . . . . . . . . local variables bag
*V  BottomLVars . . . . . . . . . . . . . . . . .  bottom local variables bag
*V  PtrLVars  . . . . . . . . . . . . . . . .  pointer to local variables bag
**
**  'CurrLVars'  is the bag containing the  values  of the local variables of
**  the currently executing interpreted function.
**
**  'BottomLVars' is the local variables bag at the bottom of the call stack.
**  Without   such a dummy  frame at  the bottom, 'SWITCH_TO_NEW_LVARS' would
**  have to check for the bottom, slowing it down.
**
**  'PtrLVars' is a pointer to the 'CurrLVars' bag.  This  makes it faster to
**  access local variables.
*/
extern  Bag             CurrLVars;

extern  Bag             BottomLVars;

extern  Obj *           PtrLVars;


/****************************************************************************
**

*F  ASS_LVAR( <lvar>, <val> ) . . . . . . . . . . .  assign to local variable
**
**  'ASS_LVAR' assigns the value <val> to the local variable <lvar>.
*/
#define ASS_LVAR(lvar,val) \
    do { PtrLVars[(lvar)+2] = (val); CHANGED_BAG((CurrLVars)); } while (0)


/****************************************************************************
**
*F  OBJ_LVAR( <lvar> )  . . . . . . . . . . . . . . . value of local variable
**
**  'OBJ_LVAR' returns the value of the local variable <lvar>.
*/
#define OBJ_LVAR(lvar)          (PtrLVars[(lvar)+2])


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
*F  InitVars()  . . . . . . . . . . . . . . . .  initialize variables package
**
**  'InitVars' initializes the variables package.
*/
extern  void            InitVars ( void );



