/****************************************************************************
**
*W  vars.c                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of variables package.
**
**  The variables  package is  the  part of   the interpreter  that  executes
**  assignments to variables and evaluates references to variables.
**
**  There are five  kinds of variables,  local variables (i.e., arguments and
**  locals), higher variables (i.e., local variables of enclosing functions),
**  global variables, list elements, and record elements.
*/
char * Revision_vars_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */
#include        "scanner.h"             /* Pr                              */
#include        "gasman.h"              /* NewBag, CHANGED_BAG             */

#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* NAMI_FUNC, ENVI_FUNC            */

#include        "records.h"             /* ASS_REC, UNB_REC, ELM_REC       */
#include        "lists.h"               /* generic lists package           */

#include        "bool.h"                /* True, False                     */

#include        "precord.h"             /* AssPRec, UnbPRec, ElmPRec, ...  */

#include        "plist.h"               /* ELM_PLIST, SET_ELM_PLIST, ...   */
#include        "string.h"              /* CSTR_STRING used by NAME_RNAM   */

#include        "code.h"                /* Stat, Expr, TYPE_EXPR, ADDR_E...*/

#define INCLUDE_DECLARATION_PART
#include        "vars.h"                /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "exprs.h"               /* EVAL_EXPR, EvalExprFuncs        */
#include        "stats.h"               /* EXEC_STAT, ExecStatFuncs        */

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*S  T_LVARS . . . . . . . . . . . . . . . .  symbolic name for lvars bag type
**
**  'T_LVARS' is the type of bags used to store values of local variables.
**
**  'T_LVARS' is defined in the declaration part of this package as follows
**
#define T_LVARS                 174
*/


/****************************************************************************
**

*F  SWITCH_TO_NEW_LVARS( <func>, <narg>, <nloc>, <old> )  . . . . . new local
**
**  'SWITCH_TO_NEW_LVARS'  creates and switches  to a new local variabes bag,
**  for  the function    <func>,   with <narg> arguments    and  <nloc> local
**  variables.  The old local variables bag is saved in <old>.
**
**  'SWITCH_TO_NEW_LVARS' is defined in the  declaration part of this package
**  as follows
**
#define SWITCH_TO_NEW_LVARS(func,narg,nloc,old)                             \
                        do {                                                \
                            (old) = CurrLVars;                              \
                            CHANGED_BAG( (old) );                           \
                            CurrLVars = NewBag( T_LVARS,                    \
                                                sizeof(Obj)*(1+narg+nloc) );\
                            PtrLVars  = PTR_BAG( CurrLVars );               \
                            CURR_FUNC = (func);                             \
                            PtrBody   = PTR_BAG( BODY_FUNC( CURR_FUNC ) );  \
                            SET_BRK_CALL_FROM( old );                       \
                        } while ( 0 )
*/


/****************************************************************************
**
*F  SWITCH_TO_OLD_LVARS( <old> )  . . .  switch to an old local variables bag
**
**  'SWITCH_TO_OLD_LVARS' switches back to the old local variables bag <old>.
**
**  'SWITCH_TO_NEW_LVARS' is defined in the  declaration part of this package
**  as follows
**
#define SWITCH_TO_OLD_LVARS(old)                                            \
                        do {                                                \
                            CurrLVars = (old);                              \
                            PtrLVars  = PTR_BAG( CurrLVars );               \
                            PtrBody   = PTR_BAG( BODY_FUNC( CURR_FUNC ) );  \
                        } while ( 0 )
*/


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
Bag             CurrLVars;


/****************************************************************************
**
*V  BottomLVars . . . . . . . . . . . . . . . . .  bottom local variables bag
**
**  'BottomLVars' is the local variables bag at the bottom of the call stack.
**  Without   such a dummy  frame at  the bottom, 'SWITCH_TO_NEW_LVARS' would
**  have to check for the bottom, slowing it down.
**
*/
Bag             BottomLVars;


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
Obj *           PtrLVars;


/****************************************************************************
**

*F  CURR_FUNC . . . . . . . . . . . . . . . . . . . . . . .  current function
**
**  'CURR_FUNC' is the function that is currently executing.
**
**  This  is  in this package,  because  it is stored   along  with the local
**  variables in the local variables bag.
**
**  'CURR_FUNC' is defined in the declaration part of this package as follows
**
#define CURR_FUNC       (PtrLVars[0])
*/


/****************************************************************************
**
*F  BRK_CALL_TO() . . . . . . . . . expr. which was called from current frame
*F  SET_BRK_CALL_TO(expr) . . . set expr. which was called from current frame
**
**  'BRK_CALL_TO'  and 'SET_BRK_CALL_TO' are defined  in the declaration part
**  of this package as follows
**
#ifndef NO_BRK_CALLS
#define BRK_CALL_TO()                   (PtrLVars[1])
#define SET_BRK_CALL_TO(expr)           (PtrLVars[1] = (expr))
#endif
#ifdef  NO_BRK_CALLS
#define BRK_CALL_TO()
#define SET_BRK_CALL_TO(expr)
#endif
*/


/****************************************************************************
**
*F  BRK_CALL_FROM() . . . . . . . . .  frame from which this frame was called
*F  SET_BRK_CALL_FROM(lvars)  . .  set frame from which this frame was called
**
**  'BRK_CALL_FROM' and  'SET_BRK_CALL_FROM' are defined  in the  declaration
**  part of this package as follows
**
#ifndef NO_BRK_CALLS
#define BRK_CALL_FROM()                 (PtrLVars[2])
#define SET_BRK_CALL_FROM(lvars)        (PtrLVars[2] = (lvars))
#endif
#ifdef  NO_BRK_CALLS
#define BRK_CALL_FROM()
#define SET_BRK_CALL_FROM(lvars)
#endif
*/


/****************************************************************************
**

*F  ASS_LVAR( <lvar>, <val> ) . . . . . . . . . . .  assign to local variable
**
**  'ASS_LVAR' assigns the value <val> to the local variable <lvar>.
**
**  'ASS_LVAR' is defined in the declaration part of this package as follows
**
#define ASS_LVAR(lvar,val) \
    do { PtrLVars[(lvar)+2] = (val); CHANGED_BAG((lvar)); } while (0)
*/


/****************************************************************************
**
*F  OBJ_LVAR( <lvar> )  . . . . . . . . . . . . . . . value of local variable
**
**  'OBJ_LVAR' returns the value of the local variable <lvar>.
**
**  'OBJ_LVAR' is defined in the declaration part of this package as follows
**
#define OBJ_LVAR(lvar)          (PtrLVars[(lvar)+2])
*/


/****************************************************************************
**
*F  NAME_LVAR( <lvar> ) . . . . . . . . . . . . . . .  name of local variable
**
**  'NAME_LVAR' returns the name of the local variable <lvar> as a C string.
**
**  'NAME_LVAR' is defined in the declaration part of this package as follows
**
#define NAME_LVAR(lvar)         NAMI_FUNC( CURR_FUNC, lvar )
*/


/****************************************************************************
**
*F  ObjLVar(<lvar>) . . . . . . . . . . . . . . . . value of a local variable
**
**  'ObjLVar' returns the value of the local variable <lvar>.
*/
Obj             ObjLVar (
    UInt                lvar )
{
    Obj                 val;            /* value result                    */
    while ( (val = OBJ_LVAR(lvar)) == 0 ) {
        ErrorReturnVoid(
            "Variable: '%s' must have an assigned value",
            (Int)NAME_LVAR( lvar ), 0L,
            "you can return after assigning a value" );
    }
    return val;
}


/****************************************************************************
**
*F  ExecAssLVar(<stat>) . . . . . . . . . assign to            local variable
**
**  'ExecAssLVar' executes the local  variable assignment statement <stat> to
**  the local variable that is referenced in <stat>.
*/
UInt            ExecAssLVar (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( (UInt)(ADDR_STAT(stat)[0]), rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}



/****************************************************************************
**
*F  ExecAssLVar01(<stat>) . . . . . . . . assign to first      local variable
*F  ExecAssLVar02(<stat>) . . . . . . . . assign to second     local variable
*F  ExecAssLVar03(<stat>) . . . . . . . . assign to third      local variable
*F  ExecAssLVar04(<stat>) . . . . . . . . assign to fourth     local variable
*F  ExecAssLVar05(<stat>) . . . . . . . . assign to fifth      local variable
*F  ExecAssLVar06(<stat>) . . . . . . . . assign to sixth      local variable
*F  ExecAssLVar07(<stat>) . . . . . . . . assign to seventh    local variable
*F  ExecAssLVar08(<stat>) . . . . . . . . assign to eigth      local variable
*F  ExecAssLVar09(<stat>) . . . . . . . . assign to ninth      local variable
*F  ExecAssLVar10(<stat>) . . . . . . . . assign to tenth      local variable
*F  ExecAssLVar11(<stat>) . . . . . . . . assign to eleventh   local variable
*F  ExecAssLVar12(<stat>) . . . . . . . . assign to twelveth   local variable
*F  ExecAssLVar13(<stat>) . . . . . . . . assign to thirteenth local variable
*F  ExecAssLVar14(<stat>) . . . . . . . . assign to fourteenth local variable
*F  ExecAssLVar15(<stat>) . . . . . . . . assign to fifteenth  local variable
*F  ExecAssLVar16(<stat>) . . . . . . . . assign to sixteenth  local variable
**
**  'ExecAssLVar<i>' executes  the local variable assignment statement <stat>
**  to the local variable <i>.
*/
UInt            ExecAssLVar01 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 1, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar02 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 2, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar03 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 3, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar04 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 4, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar05 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 5, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar06 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 6, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar07 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 7, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar08 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 8, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar09 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 9, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar10 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 10, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar11 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 11, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar12 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 12, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar13 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 13, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar14 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 14, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar15 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 15, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecAssLVar16 (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_LVAR( 16, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecUnbLVar (
    Stat                stat )
{
    /* unbind the local variable                                           */
    ASS_LVAR( (UInt)(ADDR_STAT(stat)[0]), (Obj)0 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalRefLVar(<lvar>) . . . . . . . . .  value of            local variable
*F  EvalRefLVar01(<lvar>) . . . . . . . .  value of first      local variable
*F  EvalRefLVar02(<lvar>) . . . . . . . .  value of second     local variable
*F  EvalRefLVar03(<lvar>) . . . . . . . .  value of third      local variable
*F  EvalRefLVar04(<lvar>) . . . . . . . .  value of fourth     local variable
*F  EvalRefLVar05(<lvar>) . . . . . . . .  value of fifth      local variable
*F  EvalRefLVar06(<lvar>) . . . . . . . .  value of sixth      local variable
*F  EvalRefLVar07(<lvar>) . . . . . . . .  value of seventh    local variable
*F  EvalRefLVar08(<lvar>) . . . . . . . .  value of eigth      local variable
*F  EvalRefLVar09(<lvar>) . . . . . . . .  value of ninth      local variable
*F  EvalRefLVar10(<lvar>) . . . . . . . .  value of tenth      local variable
*F  EvalRefLVar11(<lvar>) . . . . . . . .  value of eleventh   local variable
*F  EvalRefLVar12(<lvar>) . . . . . . . .  value of twelth     local variable
*F  EvalRefLVar13(<lvar>) . . . . . . . .  value of thirteenth local variable
*F  EvalRefLVar14(<lvar>) . . . . . . . .  value of fourteenth local variable
*F  EvalRefLVar15(<lvar>) . . . . . . . .  value of fifteenth  local variable
*F  EvalRefLVar16(<lvar>) . . . . . . . .  value of sixteenth  local variable
**
**  'EvalRefLVar' evaluates the local variable reference expression <expr> to
**  the local variable that is referenced in <expr>
**
**  'EvalRefLVar<i>' evaluates the local variable reference expression <expr>
**  to the local variable <i>.
*/
Obj             EvalRefLVar (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( (UInt)(ADDR_EXPR(expr)[0]) )) == 0 ) {
        while ( (val = OBJ_LVAR( (UInt)(ADDR_EXPR(expr)[0]) )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( (UInt)(ADDR_EXPR(expr)[0]) ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar01 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 1 )) == 0 ) {
        while ( (val = OBJ_LVAR( 1 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 1 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar02 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 2 )) == 0 ) {
        while ( (val = OBJ_LVAR( 2 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 2 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar03 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 3 )) == 0 ) {
        while ( (val = OBJ_LVAR( 3 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 3 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar04 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 4 )) == 0 ) {
        while ( (val = OBJ_LVAR( 4 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 4 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar05 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 5 )) == 0 ) {
        while ( (val = OBJ_LVAR( 5 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 5 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar06 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 6 )) == 0 ) {
        while ( (val = OBJ_LVAR( 6 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 6 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar07 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 7 )) == 0 ) {
        while ( (val = OBJ_LVAR( 7 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 7 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar08 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 8 )) == 0 ) {
        while ( (val = OBJ_LVAR( 8 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 8 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar09 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 9 )) == 0 ) {
        while ( (val = OBJ_LVAR( 9 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 9 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar10 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 10 )) == 0 ) {
        while ( (val = OBJ_LVAR( 10 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 10 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar11 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 11 )) == 0 ) {
        while ( (val = OBJ_LVAR( 11 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 11 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar12 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 12 )) == 0 ) {
        while ( (val = OBJ_LVAR( 12 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 12 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar13 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 13 )) == 0 ) {
        while ( (val = OBJ_LVAR( 13 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 13 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar14 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 14 )) == 0 ) {
        while ( (val = OBJ_LVAR( 14 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 14 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar15 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 15 )) == 0 ) {
        while ( (val = OBJ_LVAR( 15 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 15 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalRefLVar16 (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the local variable                       */
    if ( (val = OBJ_LVAR( 16 )) == 0 ) {
        while ( (val = OBJ_LVAR( 16 )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_LVAR( 16 ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalIsbLVar (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get the value of the local variable                                 */
    val = OBJ_LVAR( (UInt)(ADDR_EXPR(expr)[0]) );

    /* return the value                                                    */
    return (val != (Obj)0 ? True : False);
}


/****************************************************************************
**
*F  PrintAssLVar(<stat>)  . . . . . . print an assignment to a local variable
**
**  'PrintAssLVar' prints the local variable assignment statement <stat>.
*/
void            PrintAssLVar (
    Stat                stat )
{
    Pr( "%2>", 0L, 0L );
    Pr( "%I", (Int)NAME_LVAR( (UInt)(ADDR_STAT(stat)[0]) ), 0L );
    Pr( "%< %>:= ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr( "%2<;", 0L, 0L );
}

void            PrintUnbLVar (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr( "%I", (Int)NAME_LVAR( (UInt)(ADDR_STAT(stat)[0]) ), 0L );
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  PrintRefLVar(<expr>)  . . . . . . . print a reference to a local variable
**
**  'PrintRefLVar' prints the local variable reference expression <expr>.
*/
void            PrintRefLVar (
    Expr                expr )
{
    if ( IS_REFLVAR(expr) )
        Pr( "%I", (Int)NAME_LVAR( LVAR_REFLVAR(expr) ), 0L );
    else
        Pr( "%I", (Int)NAME_LVAR( (UInt)(ADDR_EXPR(expr)[0]) ), 0L );
}

void            PrintIsbLVar (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr( "%I", (Int)NAME_LVAR( (UInt)(ADDR_EXPR(expr)[0]) ), 0L );
    Pr( ")", 0L, 0L );
}


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
void            ASS_HVAR (
    UInt                hvar,
    Obj                 val )
{
    Bag                 currLVars;      /* old current local variables     */
    UInt                i;              /* loop variable                   */

    /* walk up the environment chain to the correct values bag             */
    currLVars = CurrLVars;
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        SWITCH_TO_OLD_LVARS( ENVI_FUNC( CURR_FUNC ) );
    }

    /* assign the value                                                    */
    ASS_LVAR( hvar & 0xFFFF, val );
    CHANGED_BAG( CurrLVars );

    /* switch back to current local variables bag                          */
    SWITCH_TO_OLD_LVARS( currLVars );
}

Obj             OBJ_HVAR (
    UInt                hvar )
{
    Obj                 val;            /* value, result                   */
    Bag                 currLVars;      /* old current local variables     */
    UInt                i;              /* loop variable                   */

    /* walk up the environment chain to the correct values bag             */
    currLVars = CurrLVars;
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        SWITCH_TO_OLD_LVARS( ENVI_FUNC( CURR_FUNC ) );
    }

    /* get the value                                                       */
    val = OBJ_LVAR( hvar & 0xFFFF );

    /* switch back to current local variables bag                          */
    SWITCH_TO_OLD_LVARS( currLVars );

    /* return the value                                                    */
    return val;
}

Char *          NAME_HVAR (
    UInt                hvar )
{
    Char *              name;           /* name, result                    */
    Bag                 currLVars;      /* old current local variables     */
    UInt                i;              /* loop variable                   */

    /* walk up the environment chain to the correct values bag             */
    currLVars = CurrLVars;
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        SWITCH_TO_OLD_LVARS( ENVI_FUNC( CURR_FUNC ) );
    }

    /* get the name                                                        */
    name = NAME_LVAR( hvar & 0xFFFF );

    /* switch back to current local variables bag                          */
    SWITCH_TO_OLD_LVARS( currLVars );

    /* return the name                                                     */
    return name;
}


/****************************************************************************
**
*F  ExecAssHVar(<stat>) . . . . . . . . . . . . . . assign to higher variable
**
**  'ExecAssHVar' executes the higher variable assignment statement <stat> to
**  the higher variable that is referenced in <stat>.
*/
UInt            ExecAssHVar (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the higher variable                   */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    ASS_HVAR( (UInt)(ADDR_STAT(stat)[0]), rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecUnbHVar (
    Stat                stat )
{
    /* unbind the higher variable                                          */
    ASS_HVAR( (UInt)(ADDR_STAT(stat)[0]), 0 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalRefHVar(<expr>) . . . . . . . . . . . . . .  value of higher variable
**
**  'EvalRefLVarXX' evaluates the higher variable reference expression <expr>
**  to the higher variable that is referenced in <expr>.
*/
Obj             EvalRefHVar (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the higher variable                      */
    if ( (val = OBJ_HVAR( (UInt)(ADDR_EXPR(expr)[0]) )) == 0 ) {
        while ( (val = OBJ_HVAR( (UInt)(ADDR_EXPR(expr)[0]) )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NAME_HVAR( (UInt)(ADDR_EXPR(expr)[0]) ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalIsbHVar (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get the value of the higher variable                                */
    val = OBJ_HVAR( (UInt)(ADDR_EXPR(expr)[0]) );

    /* return the value                                                    */
    return (val != (Obj)0 ? True : False);
}


/****************************************************************************
**
*F  PrintAssHVar(<stat>)  . . . . . . . . print assignment to higher variable
**
**  'PrintAssHVar' prints the higher variable assignment statement <stat>.
*/
void            PrintAssHVar (
    Stat                stat )
{
    Pr( "%2>", 0L, 0L );
    Pr( "%I", (Int)NAME_HVAR( (UInt)(ADDR_STAT(stat)[0]) ), 0L );
    Pr( "%< %>:= ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr( "%2<;", 0L, 0L );
}

void            PrintUnbHVar (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr( "%I", (Int)NAME_HVAR( (UInt)(ADDR_STAT(stat)[0]) ), 0L );
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  PrintRefHVar(<expr>) . . . . . . . . . print reference to higher variable
**
**  'PrintRefHVar' prints the higher variable reference expression <expr>.
*/
void            PrintRefHVar (
    Expr                expr )
{
    Pr( "%I", (Int)NAME_HVAR( (UInt)(ADDR_EXPR(expr)[0]) ), 0L );
}

void            PrintIsbHVar (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr( "%I", (Int)NAME_HVAR( (UInt)(ADDR_EXPR(expr)[0]) ), 0L );
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  ExecAssGVar(<stat>) . . . . . . . . . . . . . assign to a global variable
**
**  'ExecAssGVar' executes the global variable assignment statement <stat> to
**  the global variable that is referenced in <stat>.
*/
UInt            ExecAssGVar (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the global variable                   */
    SET_BRK_CURR_STAT( stat );
    rhs = EVAL_EXPR( ADDR_STAT(stat)[1] );
    AssGVar( (UInt)(ADDR_STAT(stat)[0]), rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecUnbGVar (
    Stat                stat )
{
    /* unbind the global variable                                          */
    AssGVar( (UInt)(ADDR_STAT(stat)[0]), (Obj)0 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalRefGVar(<expr>) . . . . . . . . . . . . . value of a globale variable
**
**  'EvalRefGVar' evaluates the  global variable reference expression  <expr>
**  to the global variable that is referenced in <expr>.
*/
Obj             EvalRefGVar (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the global variable                      */
    if ( (val = VAL_GVAR( (UInt)(ADDR_EXPR(expr)[0]) )) == 0
      && (val = ValAutoGVar( (UInt)(ADDR_EXPR(expr)[0]) )) == 0 ) {
        while ( (val = VAL_GVAR( (UInt)(ADDR_EXPR(expr)[0]) )) == 0
             && (val = ValAutoGVar( (UInt)(ADDR_EXPR(expr)[0]) )) == 0 ) {
            ErrorReturnVoid(
                "Variable: '%s' must have an assigned value",
                (Int)NameGVar( (UInt)(ADDR_EXPR(expr)[0]) ), 0L,
                "you can return after assigning a value" );
        }
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalIsbGVar (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get the value of the global variable                                */
    val = ValAutoGVar( (UInt)(ADDR_EXPR(expr)[0]) );

    /* return the value                                                    */
    return (val != (Obj)0 ? True : False);
}


/****************************************************************************
**
*F  PrintAssGVar(<stat>)  . . . . .  print an assignment to a global variable
**
**  'PrVarAss' prints the global variable assignment statement <stat>.
*/
void            PrintAssGVar (
    Stat                stat )
{
    Pr( "%2>", 0L, 0L );
    Pr( "%I", (Int)NameGVar( (UInt)(ADDR_STAT(stat)[0]) ), 0L );
    Pr( "%< %>:= ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr( "%2<;", 0L, 0L );
}

void            PrintUnbGVar (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr( "%I", (Int)NameGVar( (UInt)(ADDR_STAT(stat)[0]) ), 0L );
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  PrintRefGVar(<expr>)  . . . . . .  print a reference to a global variable
**
**  'PrintRefGVar' prints the global variable reference expression <expr>.
*/
void            PrintRefGVar (
    Expr                expr )
{
    Pr( "%I", (Int)NameGVar( (UInt)(ADDR_STAT(expr)[0]) ), 0L );
}

void            PrintIsbGVar (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr( "%I", (Int)NameGVar( (UInt)(ADDR_EXPR(expr)[0]) ), 0L );
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  ExecAssList(<ass>)  . . . . . . . . . . .  assign to an element of a list
**
**  'ExexAssList'  executes the list  assignment statement <stat> of the form
**  '<list>[<position>] := <rhs>;'.
*/
UInt            ExecAssList (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as a C integer        */
    Obj                 rhs;            /* right hand side, right operand  */

    /* evaluate the list (checking is done by 'ASS_LIST')                  */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_STAT(stat)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
         "List Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ(pos);

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR( ADDR_STAT(stat)[2] );

    /* special case for plain list                                         */
    if ( TYPE_OBJ(list) == T_PLIST ) {
        if ( LEN_PLIST(list) < p ) {
            GROW_PLIST( list, p );
            SET_LEN_PLIST( list, p );
        }
        SET_ELM_PLIST( list, p, rhs );
        CHANGED_BAG( list );
    }

    /* generic case                                                        */
    else {
        ASS_LIST( list, p, rhs );
    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecAsssList(<stat>) . . . . . . . . assign to several elements of a list
**
**  'ExecAsssList' executes the list assignment statement  <stat> of the form
**  '<list>{<positions>} := <rhss>;'.
*/
UInt            ExecAsssList (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, left operand         */
    Obj                 rhss;           /* right hand sides, right operand */

    /* evaluate the list (checking is done by 'ASSS_LIST')                 */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR( ADDR_STAT(stat)[1] );
    while ( ! IS_POSS_LIST( poss ) ) {
        poss = ErrorReturnObj(
    "List Assignment: <positions> must be a dense list of positive integers",
            0L, 0L,
        "you can return a dense list of positive integers for <positions>" );
    }

    /* evaluate and check right hand sides                                 */
    rhss = EVAL_EXPR( ADDR_STAT(stat)[2] );
    while ( ! IS_DENSE_LIST( rhss )
         || LEN_LIST( poss ) != LEN_LIST( rhss ) ) {
        if ( ! IS_DENSE_LIST( rhss ) ) {
            rhss = ErrorReturnObj(
                "List Assignment: <rhss> must be a dense list (not a %s)",
                (Int)(InfoBags[TYPE_OBJ(rhss)].name), 0L,
                "you can return a dense list for <rhss>" );
        }
        else /* if ( LEN_LIST( poss ) != LEN_LIST( rhss ) ) */ {
            rhss = ErrorReturnObj(
     "List Assignment: <rhss> must have the same length as <positions> (%d)",
                (Int)LEN_LIST( poss ), 0L,
                "you can return a new dense list for <rhss>" );
        }
    }

    /* assign the right hand sides to several elements of the list         */
    ASSS_LIST( list, poss, rhss );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecAssListLevel(<stat>) . . . . . .  assign to elements of several lists
**
**  'ExecAssListLevel' executes the  list assignment statement  <stat> of the
**  form '<list>...{<positions>}...[<position>] :=  <rhss>;', where there may
**  actually be    several '{<positions>}'  selections  between  <list>   and
**  '[<position>]'.   The number of       those   is called    the     level.
**  'ExecAssListLevel' goes  that deep into  the left operand  and <rhss> and
**  assigns the  values from <rhss> to each  of those lists.  For example, if
**  the level is 1, the left operand must be a list  of lists, <rhss> must be
**  a  list, and 'ExecAssListLevel' assigns the  element '<rhss>[<i>]' to the
**  list '<list>[<i>]' at <position>.
*/
UInt            ExecAssListLevel (
    Expr                stat )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as C integer          */
    Obj                 rhss;           /* right hand sides, right operand */
    Int                 level;          /* level                           */

    /* evaluate lists (if this works, then <lists> is nested <level> deep, */
    /* checking it is nested <level>+1 deep is done by 'AssListLevel')     */
    SET_BRK_CURR_STAT( stat );
    lists = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_STAT(stat)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
         "List Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ(pos);

    /* evaluate right hand sides (checking is done by 'AssListLevel')      */
    rhss = EVAL_EXPR( ADDR_STAT(stat)[2] );

    /* get the level                                                       */
    level = (Int)(ADDR_STAT(stat)[3]);

    /* assign the right hand sides to the elements of several lists        */
    AssListLevel( lists, p, rhss, level );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecAsssListLevel(<stat>) . . assign to several elements of several lists
**
**  'ExecAsssListLevel' executes the list  assignment statement <stat> of the
**  form '<list>...{<positions>}...{<positions>} := <rhss>;', where there may
**  actually be   several  '{<positions>}'  selections  between   <list>  and
**  '{<positions>}'.   The  number   of    those   is  called   the    level.
**  'ExecAsssListLevel' goes  that deep into the left  operand and <rhss> and
**  assigns the sublists from <rhss> to each of those lists.  For example, if
**  the level is 1, the left operand must be a  list of lists, <rhss> must be
**  a list, and 'ExecAsssListLevel' assigns the elements '<rhss>[<i>]' to the
**  list '<list>[<i>]' at the positions <positions>.
*/
UInt            ExecAsssListLevel (
    Expr                stat )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */
    Int                 level;          /* level                           */

    /* evaluate lists (if this works, then <lists> is nested <level> deep, */
    /* checking it is nested <level>+1 deep is done by 'AsssListLevel')    */
    SET_BRK_CURR_STAT( stat );
    lists = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR( ADDR_EXPR(stat)[1] );
    while ( ! IS_POSS_LIST( poss ) ) {
        poss = ErrorReturnObj(
    "List Assignment: <positions> must be a dense list of positive integers",
            0L, 0L,
        "you can return a dense list of positive integers for <positions>" );
    }

    /* evaluate right hand sides (checking is done by 'AsssListLevel')     */
    rhss = EVAL_EXPR( ADDR_STAT(stat)[2] );

    /* get the level                                                       */
    level = (Int)(ADDR_STAT(stat)[3]);

    /* assign the right hand sides to several elements of several lists    */
    AsssListLevel( lists, poss, rhss, level );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbList(<ass>)  . . . . . . . . . . . . . unbind an element of a list
**
**  'ExexUnbList'  executes the list   unbind  statement <stat> of the   form
**  'Unbind( <list>[<position>] );'.
*/
UInt            ExecUnbList (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as a C integer        */

    /* evaluate the list (checking is done by 'LEN_LIST')                  */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_STAT(stat)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
         "List Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ(pos);

    /* unbind the element                                                  */
    UNB_LIST( list, p );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalElmList(<expr>) . . . . . . . . . . . . . select an element of a list
**
**  'EvalElmList' evaluates the list  element expression  <expr> of the  form
**  '<list>[<position>]'.
*/
Obj             EvalElmList (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* evaluate the list (checking is done by 'ELM_LIST')                  */
    list = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_EXPR(expr)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
            "List Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ( pos );

    /* special case for plain lists (use generic code to signal errors)    */
    if ( TYPE_OBJ(list) == T_PLIST ) {
        if ( LEN_PLIST(list) < p ) {
            return ELM_LIST( list, p );
        }
        elm = ELM_PLIST( list, p );
        if ( elm == 0 ) {
            return ELM_LIST( list, p );
        }
    }

    /* generic case                                                        */
    else {
        elm = ELM_LIST( list, p );
    }

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalElmsList(<expr>)  . . . . . . . . . select several elements of a list
**
**  'EvalElmsList' evaluates the  list element expression  <expr> of the form
**  '<list>{<positions>}'.
*/
Obj             EvalElmsList (
    Expr                expr )
{
    Obj                 elms;           /* elements, result                */
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, right operand        */

    /* evaluate the list (checking is done by 'ELMS_LIST')                 */
    list = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR( ADDR_EXPR(expr)[1] );
    while ( ! IS_POSS_LIST( poss ) ) {
        poss = ErrorReturnObj(
      "List Elements: <positions> must be a dense list of positive integers",
            0L, 0L,
        "you can return a dense list of positive integers for <positions>" );
    }

    /* select several elements from the list                               */
    elms = ELMS_LIST( list, poss );

    /* return the elements                                                 */
    return elms;
}


/****************************************************************************
**
*F  EvalElmListLevel(<expr>)  . . . . . . .  select elements of several lists
**
**  'EvalElmListLevel' evaluates the  list element  expression <expr> of  the
**  form '<list>...{<positions>}...[<position>]', where there may actually be
**  several '{<positions>}' selections   between <list> and   '[<position>]'.
**  The  number of those is called   the level.  'EvalElmListLevel' goes that
**  deep  into the left operand  and  selects the  element at <position> from
**  each of those  lists.  For example,  if the level  is 1, the left operand
**  must be a  list of lists  and 'EvalElmListLevel'  selects the element  at
**  <position> from each of the lists and returns the list of those values.
*/
Obj             EvalElmListLevel (
    Expr                expr )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */
    Int                 level;          /* level                           */

    /* evaluate lists (if this works, then <lists> is nested <level> deep, */
    /* checking it is nested <level>+1 deep is done by 'ElmListLevel')     */
    lists = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_EXPR(expr)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
            "List Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ( pos );

    /* get the level                                                       */
    level = (Int)(ADDR_EXPR(expr)[2]);

    /* select the elements from several lists (store them in <lists>)      */
    ElmListLevel( lists, p, level );

    /* return the elements                                                 */
    return lists;
}


/****************************************************************************
**
*F  EvalElmsListLevel(<expr>) . . .  select several elements of several lists
**
**  'EvalElmsListLevel' evaluates the  list element expression <expr>  of the
**  form '<list>...{<positions>}...{<positions>}',   where there may actually
**  be several '{<positions>}' selections between <list> and '{<positions>}'.
**  The  number of those is called  the level.  'EvalElmsListLevel' goes that
**  deep into  the left operand and selects  the elements at <positions> from
**  each of those lists.   For example, if the  level is 1, the left  operand
**  must be  a list of lists  and 'EvalElmsListLevel' selects the elements at
**  <positions>  from each   of the lists  and  returns   the  list  of those
**  sublists.
*/
Obj             EvalElmsListLevel (
    Expr                expr )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* positions, right operand        */
    Int                 level;          /* level                           */

    /* evaluate lists (if this works, then <lists> is nested <level> deep, */
    /* checking it is nested <level>+1 deep is done by 'ElmsListLevel')    */
    lists = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR( ADDR_EXPR(expr)[1] );
    while ( ! IS_POSS_LIST( poss ) ) {
        poss = ErrorReturnObj(
      "List Elements: <positions> must be a dense list of positive integers",
            0L, 0L,
        "you can return a dense list of positive integers for <positions>" );
    }

    /* get the level                                                       */
    level = (Int)(ADDR_EXPR(expr)[2]);

    /* select several elements from several lists (store them in <lists>)  */
    ElmsListLevel( lists, poss, level );

    /* return the elements                                                 */
    return lists;
}


/****************************************************************************
**
*F  EvalIsbList(<expr>) . . . . . . . . test if an element of a list is bound
**
**  'EvalElmList'  evaluates the list  isbound expression  <expr> of the form
**  'IsBound( <list>[<position>] )'.
*/
Obj             EvalIsbList (
    Expr                expr )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* evaluate the list (checking is done by 'ISB_LIST')                  */
    list = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_EXPR(expr)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
            "List Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ( pos );

    /* return the result                                                   */
    return (ISB_LIST( list, p ) ? True : False);
}


/****************************************************************************
**
*F  PrintAssList(<stat>)  . . . . print an assignment to an element of a list
**
**  'PrintAssList' prints the list  assignment statement  <stat> of the  form
**  '<list>[<position>] := <rhs>;'.
**
**  Linebreaks are preferred before the ':='.
*/
void            PrintAssList (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<[",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr("%<]",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );
    Pr("%2<;",0L,0L);
}

void            PrintUnbList (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<[",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr("%<]",0L,0L);
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  PrintAsssList(<stat>) . print an assignment to several elements of a list
**
**  'PrintAsssList'  prints the list assignment  statement <stat> of the form
**  '<list>{<positions>} := <rhss>;'.
**
**  Linebreaks are preferred before the ':='.
*/
void            PrintAsssList (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<{",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr("%<}",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );
    Pr("%2<;",0L,0L);
}


/****************************************************************************
**
*F  PrintElmList(<expr>)  . . . . . print a selection of an element of a list
**
**  'PrintElmList'   prints the list element   expression  <expr> of the form
**  '<list>[<position>]'.
**
**  Linebreaks are preferred after the '['.
*/
void            PrintElmList (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<[",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr("%<]",0L,0L);
}

void            PrintIsbList (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<[",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr("%<]",0L,0L);
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmsList(<expr>) . . print a selection of several elements of a list
**
**  'PrElmsList'  prints the list  elements  expression  <expr> of the   form
**  '<list>{<positions>}'.
**
**  Linebreaks are preferred after the '{'.
*/
void            PrintElmsList (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<{",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr("%<}",0L,0L);
}


/****************************************************************************
**
*F  ExecAssRecName(<stat>)  . . . . . . . .  assign to an element of a record
**
**  'ExecAssRecName' executes the record  assignment statement <stat>  of the
**  form '<record>.<name> := <rhs>;'.
*/
UInt            ExecAssRecName (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* evaluate the record (checking is done by 'ASS_REC')                 */
    SET_BRK_CURR_STAT( stat );
    record = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR( ADDR_STAT(stat)[2] );

    /* assign the right hand side to the element of the record             */
    ASS_REC( record, rnam, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecAssRecExpr(<stat>)  . . . . . . . .  assign to an element of a record
**
**  'ExecAssRecExpr'  executes the record assignment  statement <stat> of the
**  form '<record>.(<name>) := <rhs>;'.
*/
UInt            ExecAssRecExpr (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* evaluate the record (checking is done by 'ASS_REC')                 */
    SET_BRK_CURR_STAT( stat );
    record = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj( EVAL_EXPR( ADDR_STAT(stat)[1] ) );

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR( ADDR_STAT(stat)[2] );

    /* assign the right hand side to the element of the record             */
    ASS_REC( record, rnam, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbRecName(<stat>)  . . . . . . . . . . unbind an element of a record
**
**  'ExecAssRecName' executes the record  unbind statement <stat> of the form
**  'Unbind( <record>.<name> );'.
*/
UInt            ExecUnbRecName (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    SET_BRK_CURR_STAT( stat );
    record = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);

    /* unbind the element of the record                                    */
    UNB_REC( record, rnam );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbRecExpr(<stat>)  . . . . . . . . . . unbind an element of a record
**
**  'ExecAssRecExpr' executes the record  unbind statement <stat> of the form
**  'Unbind( <record>.(<name>) );'.
*/
UInt            ExecUnbRecExpr (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    SET_BRK_CURR_STAT( stat );
    record = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj( EVAL_EXPR( ADDR_STAT(stat)[1] ) );

    /* unbind the element of the record                                    */
    UNB_REC( record, rnam );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalElmRecName(<expr>)  . . . . . . . . . . . . . select a record element
**
**  'EvalElmRecName' evaluates the   record element expression  <expr> of the
**  form '<record>.<name>'.
*/
Obj             EvalElmRecName (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ELM_REC')                 */
    record = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = (UInt)(ADDR_EXPR(expr)[1]);

    /* select the element of the record                                    */
    elm = ELM_REC( record, rnam );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalElmRecExpr(<expr>)  . . . . . . . . . . . . . select a record element
**
**  'EvalElmRecExpr'  evaluates the record   element expression <expr> of the
**  form '<record>.(<name>)'.
*/
Obj             EvalElmRecExpr (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ELM_REC')                 */
    record = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj( EVAL_EXPR( ADDR_EXPR(expr)[1] ) );

    /* select the element of the record                                    */
    elm = ELM_REC( record, rnam );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalIsbRecName(<expr>)  . . . . . . . . test if a record element is bound
**
**  'EvalElmRecName' evaluates the   record isbound expression  <expr> of the
**  form 'IsBound( <record>.<name> )'.
*/
Obj             EvalIsbRecName (
    Expr                expr )
{
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = (UInt)(ADDR_EXPR(expr)[1]);

    /* return the result                                                   */
    return (ISB_REC( record, rnam ) ? True : False);
}


/****************************************************************************
**
*F  EvalIsbRecExpr(<expr>)  . . . . . . . . test if a record element is bound
**
**  'EvalIsbRecExpr' evaluates  the record isbound  expression  <expr> of the
**  form 'IsBound( <record>.(<name>) )'.
*/
Obj             EvalIsbRecExpr (
    Expr                expr )
{
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj( EVAL_EXPR( ADDR_EXPR(expr)[1] ) );

    /* return the result                                                   */
    return (ISB_REC( record, rnam ) ? True : False);
}


/****************************************************************************
**
*F  PrintAssRecName(<stat>) . . print an assignment to an element of a record
**
**  'PrintAssRecName' prints the  record  assignment statement <stat>  of the
**  form '<record>.<name> := <rhs>;'.
*/
void            PrintAssRecName (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<.",0L,0L);
    Pr("%I",(Int)NAME_RNAM((UInt)(ADDR_STAT(stat)[1])),0L);
    Pr("%<",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );
    Pr("%2<;",0L,0L);
}

void            PrintUnbRecName (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<.",0L,0L);
    Pr("%I",(Int)NAME_RNAM((UInt)(ADDR_STAT(stat)[1])),0L);
    Pr("%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  PrintAssRecExpr(<stat>) . . print an assignment to an element of a record
**
**  'PrintAssRecExpr' prints the  record  assignment statement <stat>  of the
**  form '<record>.(<name>) := <rhs>;'.
*/
void            PrintAssRecExpr (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<.(",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr(")%<",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );
    Pr("%2<;",0L,0L);
}

void            PrintUnbRecExpr (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<.(",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr(")%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmRecName(<expr>) . . . print a selection of an element of a record
**
**  'PrintElmRecName' prints the record element expression <expr> of the form
**  '<record>.<name>'.
*/
void            PrintElmRecName (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<.",0L,0L);
    Pr("%I",(Int)NAME_RNAM((UInt)(ADDR_EXPR(expr)[1])),0L);
    Pr("%<",0L,0L);
}

void            PrintIsbRecName (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<.",0L,0L);
    Pr("%I",(Int)NAME_RNAM((UInt)(ADDR_EXPR(expr)[1])),0L);
    Pr("%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmRecExpr(<expr>) . . . print a selection of an element of a record
**
**  'PrintElmRecExpr' prints the record element expression <expr> of the form
**  '<record>.(<name>)'.
*/
void            PrintElmRecExpr (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<.(",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr(")%<",0L,0L);
}

void            PrintIsbRecExpr (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<.(",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr(")%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  ExecAssPosobj(<ass>)  . . . . . . . . . . .  assign to an element of a list
**
**  'ExexAssPosobj'  executes the list  assignment statement <stat> of the form
**  '<list>[<position>] := <rhs>;'.
*/
UInt            ExecAssPosobj (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as a C integer        */
    Obj                 rhs;            /* right hand side, right operand  */

    /* evaluate the list (checking is done by 'ASS_LIST')                  */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_STAT(stat)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
         "Posobj Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ(pos);

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR( ADDR_STAT(stat)[2] );

    /* special case for plain list                                         */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        if ( SIZE_OBJ(list)/sizeof(Obj)-1 < p ) {
            ResizeBag( list, (p+1) * sizeof(Obj) );
        }
        SET_ELM_PLIST( list, p, rhs );
        CHANGED_BAG( list );
    }

    /* generic case                                                        */
    else {
        ASS_LIST( list, p, rhs );
    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbPosobj(<ass>)  . . . . . . . . . . . . . unbind an element of a list
**
**  'ExexUnbPosobj'  executes the list   unbind  statement <stat> of the   form
**  'Unbind( <list>[<position>] );'.
*/
UInt            ExecUnbPosobj (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as a C integer        */

    /* evaluate the list (checking is done by 'LEN_LIST')                  */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_STAT(stat)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
         "Posobj Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ(pos);

    /* unbind the element                                                  */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        if ( p <= SIZE_OBJ(list)/sizeof(Obj)-1 ) {
            SET_ELM_PLIST( list, p, 0 );
        }
    }
    else {
        UNB_LIST( list, p );
    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalElmPosobj(<expr>) . . . . . . . . . . . . . select an element of a list
**
**  'EvalElmPosobj' evaluates the list  element expression  <expr> of the  form
**  '<list>[<position>]'.
*/
Obj             EvalElmPosobj (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* evaluate the list (checking is done by 'ELM_LIST')                  */
    list = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_EXPR(expr)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
            "Posobj Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ( pos );

    /* special case for plain lists (use generic code to signal errors)    */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        while ( SIZE_OBJ(list)/sizeof(Obj)-1 < p ) {
            ErrorReturnVoid(
                "Posobj Element: <Posobj>![%d] must have an assigned value",
                (Int)p, 0L,
                "you can return after assigning a value" );
        }
        elm = ELM_PLIST( list, p );
        while ( elm == 0 ) {
            ErrorReturnVoid(
                "Posobj Element: <Posobj>![%d] must have an assigned value",
                (Int)p, 0L,
                "you can return after assigning a value" );
        }
    }

    /* generic case                                                        */
    else {
        elm = ELM_LIST( list, p );
    }

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalIsbPosobj(<expr>) . . . . . . . . test if an element of a list is bound
**
**  'EvalElmPosobj'  evaluates the list  isbound expression  <expr> of the form
**  'IsBound( <list>[<position>] )'.
*/
Obj             EvalIsbPosobj (
    Expr                expr )
{
    Obj                 isb;            /* isbound, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* evaluate the list (checking is done by 'ISB_LIST')                  */
    list = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR( ADDR_EXPR(expr)[1] );
    while ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        pos = ErrorReturnObj(
            "Posobj Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return a positive integer for <position>" );
    }
    p = INT_INTOBJ( pos );

    /* get the result                                                      */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        isb = (p <= SIZE_OBJ(list)/sizeof(Obj)-1 && ELM_PLIST(list,p) != 0 ?
               True : False);
    }
    else {
        isb = (ISB_LIST( list, p ) ? True : False);
    }

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  PrintAssPosobj(<stat>)  . . . . print an assignment to an element of a list
**
**  'PrintAssPosobj' prints the list  assignment statement  <stat> of the  form
**  '<list>[<position>] := <rhs>;'.
**
**  Linebreaks are preferred before the ':='.
*/
void            PrintAssPosobj (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<![",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr("%<]",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );
    Pr("%2<;",0L,0L);
}

void            PrintUnbPosobj (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<![",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr("%<]",0L,0L);
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmPosobj(<expr>)  . . . . . print a selection of an element of a list
**
**  'PrintElmPosobj'   prints the list element   expression  <expr> of the form
**  '<list>[<position>]'.
**
**  Linebreaks are preferred after the '['.
*/
void            PrintElmPosobj (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<![",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr("%<]",0L,0L);
}

void            PrintIsbPosobj (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<![",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr("%<]",0L,0L);
    Pr( ")", 0L, 0L );
}


/****************************************************************************
**
*F  ExecAssComobjName(<stat>) . . . . . . . .  assign to an element of a record
**
**  'ExecAssComobjName' executes the  record assignment statement <stat> of the
**  form '<record>.<name> := <rhs>;'.
*/
UInt            ExecAssComobjName (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* evaluate the record (checking is done by 'ASS_REC')                 */
    SET_BRK_CURR_STAT( stat );
    record = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR( ADDR_STAT(stat)[2] );

    /* assign the right hand side to the element of the record             */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        AssPRec( record, rnam, rhs );
    }
    else {
        ASS_REC( record, rnam, rhs );
    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecAssComobjExpr(<stat>) . . . . . . . .  assign to an element of a record
**
**  'ExecAssComobjExpr' executes the record assignment  statement <stat> of the
**  form '<record>.(<name>) := <rhs>;'.
*/
UInt            ExecAssComobjExpr (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* evaluate the record (checking is done by 'ASS_REC')                 */
    SET_BRK_CURR_STAT( stat );
    record = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj( EVAL_EXPR( ADDR_STAT(stat)[1] ) );

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR( ADDR_STAT(stat)[2] );

    /* assign the right hand side to the element of the record             */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        AssPRec( record, rnam, rhs );
    }
    else {
        ASS_REC( record, rnam, rhs );
    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbComobjName(<stat>) . . . . . . . . . . unbind an element of a record
**
**  'ExecAssComobjName' executes the record unbind statement <stat> of the form
**  'Unbind( <record>.<name> );'.
*/
UInt            ExecUnbComobjName (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    SET_BRK_CURR_STAT( stat );
    record = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);

    /* unbind the element of the record                                    */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        UnbPRec( record, rnam );
    }
    else {
        UNB_REC( record, rnam );
    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbComobjExpr(<stat>) . . . . . . . . . . unbind an element of a record
**
**  'ExecAssComobjExpr' executes the record unbind statement <stat> of the form
**  'Unbind( <record>.(<name>) );'.
*/
UInt            ExecUnbComobjExpr (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    SET_BRK_CURR_STAT( stat );
    record = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj( EVAL_EXPR( ADDR_STAT(stat)[1] ) );

    /* unbind the element of the record                                    */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        UnbPRec( record, rnam );
    }
    else {
        UNB_REC( record, rnam );
    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalElmComobjName(<expr>) . . . . . . . . . . . . . select a record element
**
**  'EvalElmComobjName' evaluates the  record element expression  <expr> of the
**  form '<record>.<name>'.
*/
Obj             EvalElmComobjName (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ELM_REC')                 */
    record = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = (UInt)(ADDR_EXPR(expr)[1]);

    /* select the element of the record                                    */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        elm = ElmPRec( record, rnam );
    }
    else {
        elm = ELM_REC( record, rnam );
    }

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalElmComobjExpr(<expr>) . . . . . . . . . . . . . select a record element
**
**  'EvalElmComobjExpr' evaluates the  record element expression  <expr> of the
**  form '<record>.(<name>)'.
*/
Obj             EvalElmComobjExpr (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ELM_REC')                 */
    record = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj( EVAL_EXPR( ADDR_EXPR(expr)[1] ) );

    /* select the element of the record                                    */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        elm = ElmPRec( record, rnam );
    }
    else {
        elm = ELM_REC( record, rnam );
    }

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalIsbComobjName(<expr>) . . . . . . . . test if a record element is bound
**
**  'EvalElmComobjName' evaluates  the record isbound  expression <expr> of the
**  form 'IsBound( <record>.<name> )'.
*/
Obj             EvalIsbComobjName (
    Expr                expr )
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = (UInt)(ADDR_EXPR(expr)[1]);

    /* select the element of the record                                    */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        isb = (IsbPRec( record, rnam ) ? True : False);
    }
    else {
        isb = (ISB_REC( record, rnam ) ? True : False);
    }

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  EvalIsbComobjExpr(<expr>) . . . . . . . . test if a record element is bound
**
**  'EvalIsbComobjExpr'  evaluates the record isbound  expression <expr> of the
**  form 'IsBound( <record>.(<name>) )'.
*/
Obj             EvalIsbComobjExpr (
    Expr                expr )
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                */
    record = EVAL_EXPR( ADDR_EXPR(expr)[0] );

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj( EVAL_EXPR( ADDR_EXPR(expr)[1] ) );

    /* select the element of the record                                    */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        isb = (IsbPRec( record, rnam ) ? True : False);
    }
    else {
        isb = (ISB_REC( record, rnam ) ? True : False);
    }

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  PrintAssComobjName(<stat>)  . print an assignment to an element of a record
**
**  'PrintAssComobjName' prints the  record assignment statement <stat>  of the
**  form '<record>.<name> := <rhs>;'.
*/
void            PrintAssComobjName (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<!.",0L,0L);
    Pr("%I",(Int)NAME_RNAM((UInt)(ADDR_STAT(stat)[1])),0L);
    Pr("%<",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );
    Pr("%2<;",0L,0L);
}

void            PrintUnbComobjName (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<!.",0L,0L);
    Pr("%I",(Int)NAME_RNAM((UInt)(ADDR_STAT(stat)[1])),0L);
    Pr("%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  PrintAssComobjExpr(<stat>)  . print an assignment to an element of a record
**
**  'PrintAssComobjExpr' prints the  record assignment statement <stat>  of the
**  form '<record>.(<name>) := <rhs>;'.
*/
void            PrintAssComobjExpr (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<!.(",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr(")%<",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );
    Pr("%2<;",0L,0L);
}

void            PrintUnbComobjExpr (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<!.(",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr(")%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmComobjName(<expr>)  . . print a selection of an element of a record
**
**  'PrintElmComobjName' prints the  record  element expression <expr> of   the
**  form '<record>.<name>'.
*/
void            PrintElmComobjName (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<!.",0L,0L);
    Pr("%I",(Int)NAME_RNAM((UInt)(ADDR_EXPR(expr)[1])),0L);
    Pr("%<",0L,0L);
}

void            PrintIsbComobjName (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<!.",0L,0L);
    Pr("%I",(Int)NAME_RNAM((UInt)(ADDR_EXPR(expr)[1])),0L);
    Pr("%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmComobjExpr(<expr>)  . . print a selection of an element of a record
**
**  'PrintElmComobjExpr' prints the record   element expression <expr>  of  the
**  form '<record>.(<name>)'.
*/
void            PrintElmComobjExpr (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<!.(",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr(")%<",0L,0L);
}

void            PrintIsbComobjExpr (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[0] );
    Pr("%<!.(",0L,0L);
    PrintExpr( ADDR_EXPR(expr)[1] );
    Pr(")%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  VarsBeforeCollectBags() . . . . . . . . actions before garbage collection
*F  VarsAfterCollectBags()  . . . . . . . .  actions after garbage collection
*/
void            VarsBeforeCollectBags ( void )
{
    CHANGED_BAG( CurrLVars );
}

void            VarsAfterCollectBags ( void )
{
    PtrLVars = PTR_BAG( CurrLVars );
    PtrBody  = (Stat*)PTR_BAG( BODY_FUNC( CURR_FUNC ) );
    PtrGVars = PTR_BAG( ValGVars );
}


/****************************************************************************
**

*F  InitVars()  . . . . . . . . . . . . . . . .  initialize variables package
**
**  'InitVars' initializes the variables package.
*/
void            InitVars ( )
{
    UInt                i;              /* loop variable                   */
    Obj                 tmp;

    /* install the marking functions for local variables bag               */
    InfoBags[        T_LVARS          ].name = "values bag";
    InitMarkFuncBags( T_LVARS          , MarkAllSubBags );

    /* install executors, evaluators, and printers for local variables     */
    ExecStatFuncs [ T_ASS_LVAR       ] = ExecAssLVar;
    ExecStatFuncs [ T_ASS_LVAR_01    ] = ExecAssLVar01;
    ExecStatFuncs [ T_ASS_LVAR_02    ] = ExecAssLVar02;
    ExecStatFuncs [ T_ASS_LVAR_03    ] = ExecAssLVar03;
    ExecStatFuncs [ T_ASS_LVAR_04    ] = ExecAssLVar04;
    ExecStatFuncs [ T_ASS_LVAR_05    ] = ExecAssLVar05;
    ExecStatFuncs [ T_ASS_LVAR_06    ] = ExecAssLVar06;
    ExecStatFuncs [ T_ASS_LVAR_07    ] = ExecAssLVar07;
    ExecStatFuncs [ T_ASS_LVAR_08    ] = ExecAssLVar08;
    ExecStatFuncs [ T_ASS_LVAR_09    ] = ExecAssLVar09;
    ExecStatFuncs [ T_ASS_LVAR_10    ] = ExecAssLVar10;
    ExecStatFuncs [ T_ASS_LVAR_11    ] = ExecAssLVar11;
    ExecStatFuncs [ T_ASS_LVAR_12    ] = ExecAssLVar12;
    ExecStatFuncs [ T_ASS_LVAR_13    ] = ExecAssLVar13;
    ExecStatFuncs [ T_ASS_LVAR_14    ] = ExecAssLVar14;
    ExecStatFuncs [ T_ASS_LVAR_15    ] = ExecAssLVar15;
    ExecStatFuncs [ T_ASS_LVAR_16    ] = ExecAssLVar16;
    ExecStatFuncs [ T_UNB_LVAR       ] = ExecUnbLVar;
    EvalExprFuncs [ T_REF_LVAR       ] = EvalRefLVar;
    EvalExprFuncs [ T_REF_LVAR_01    ] = EvalRefLVar01;
    EvalExprFuncs [ T_REF_LVAR_02    ] = EvalRefLVar02;
    EvalExprFuncs [ T_REF_LVAR_03    ] = EvalRefLVar03;
    EvalExprFuncs [ T_REF_LVAR_04    ] = EvalRefLVar04;
    EvalExprFuncs [ T_REF_LVAR_05    ] = EvalRefLVar05;
    EvalExprFuncs [ T_REF_LVAR_06    ] = EvalRefLVar06;
    EvalExprFuncs [ T_REF_LVAR_07    ] = EvalRefLVar07;
    EvalExprFuncs [ T_REF_LVAR_08    ] = EvalRefLVar08;
    EvalExprFuncs [ T_REF_LVAR_09    ] = EvalRefLVar09;
    EvalExprFuncs [ T_REF_LVAR_10    ] = EvalRefLVar10;
    EvalExprFuncs [ T_REF_LVAR_11    ] = EvalRefLVar11;
    EvalExprFuncs [ T_REF_LVAR_12    ] = EvalRefLVar12;
    EvalExprFuncs [ T_REF_LVAR_13    ] = EvalRefLVar13;
    EvalExprFuncs [ T_REF_LVAR_14    ] = EvalRefLVar14;
    EvalExprFuncs [ T_REF_LVAR_15    ] = EvalRefLVar15;
    EvalExprFuncs [ T_REF_LVAR_16    ] = EvalRefLVar16;
    EvalExprFuncs [ T_ISB_LVAR       ] = EvalIsbLVar;
    PrintStatFuncs[ T_ASS_LVAR       ] = PrintAssLVar;
    for ( i = T_ASS_LVAR_01; i <= T_ASS_LVAR_16; i++ ) {
        PrintStatFuncs[ i ] = PrintAssLVar;
    }
    PrintStatFuncs[ T_UNB_LVAR       ] = PrintUnbLVar;
    PrintExprFuncs[ T_REFLVAR        ] = PrintRefLVar;
    PrintExprFuncs[ T_REF_LVAR       ] = PrintRefLVar;
    for ( i = T_REF_LVAR_01; i <= T_REF_LVAR_16; i++ ) {
        PrintExprFuncs[ i ] = PrintRefLVar;
    }
    PrintExprFuncs[ T_ISB_LVAR       ] = PrintIsbLVar;

    /* install executors, evaluators, and printers for higher variables    */
    ExecStatFuncs [ T_ASS_HVAR       ] = ExecAssHVar;
    ExecStatFuncs [ T_UNB_HVAR       ] = ExecUnbHVar;
    EvalExprFuncs [ T_REF_HVAR       ] = EvalRefHVar;
    EvalExprFuncs [ T_ISB_HVAR       ] = EvalIsbHVar;
    PrintStatFuncs[ T_ASS_HVAR       ] = PrintAssHVar;
    PrintStatFuncs[ T_UNB_HVAR       ] = PrintUnbHVar;
    PrintExprFuncs[ T_REF_HVAR       ] = PrintRefHVar;
    PrintExprFuncs[ T_ISB_HVAR       ] = PrintIsbHVar;

    /* install executors, evaluators, and printers for global variables    */
    ExecStatFuncs [ T_ASS_GVAR       ] = ExecAssGVar;
    ExecStatFuncs [ T_UNB_GVAR       ] = ExecUnbGVar;
    EvalExprFuncs [ T_REF_GVAR       ] = EvalRefGVar;
    EvalExprFuncs [ T_ISB_GVAR       ] = EvalIsbGVar;
    PrintStatFuncs[ T_ASS_GVAR       ] = PrintAssGVar;
    PrintStatFuncs[ T_UNB_GVAR       ] = PrintUnbGVar;
    PrintExprFuncs[ T_REF_GVAR       ] = PrintRefGVar;
    PrintExprFuncs[ T_ISB_GVAR       ] = PrintIsbGVar;

    /* install executors, evaluators, and printers for list elements       */
    ExecStatFuncs [ T_ASS_LIST       ] = ExecAssList;
    ExecStatFuncs [ T_ASSS_LIST      ] = ExecAsssList;
    ExecStatFuncs [ T_ASS_LIST_LEV   ] = ExecAssListLevel;
    ExecStatFuncs [ T_ASSS_LIST_LEV  ] = ExecAsssListLevel;
    ExecStatFuncs [ T_UNB_LIST       ] = ExecUnbList;
    EvalExprFuncs [ T_ELM_LIST       ] = EvalElmList;
    EvalExprFuncs [ T_ELMS_LIST      ] = EvalElmsList;
    EvalExprFuncs [ T_ELM_LIST_LEV   ] = EvalElmListLevel;
    EvalExprFuncs [ T_ELMS_LIST_LEV  ] = EvalElmsListLevel;
    EvalExprFuncs [ T_ISB_LIST       ] = EvalIsbList;
    PrintStatFuncs[ T_ASS_LIST       ] = PrintAssList;
    PrintStatFuncs[ T_ASSS_LIST      ] = PrintAsssList;
    PrintStatFuncs[ T_ASS_LIST_LEV   ] = PrintAssList;
    PrintStatFuncs[ T_ASSS_LIST_LEV  ] = PrintAsssList;
    PrintStatFuncs[ T_UNB_LIST       ] = PrintUnbList;
    PrintExprFuncs[ T_ELM_LIST       ] = PrintElmList;
    PrintExprFuncs[ T_ELMS_LIST      ] = PrintElmsList;
    PrintExprFuncs[ T_ELM_LIST_LEV   ] = PrintElmList;
    PrintExprFuncs[ T_ELMS_LIST_LEV  ] = PrintElmsList;
    PrintExprFuncs[ T_ISB_LIST       ] = PrintIsbList;

    /* install executors, evaluators, and printers for record elements     */
    ExecStatFuncs [ T_ASS_REC_NAME   ] = ExecAssRecName;
    ExecStatFuncs [ T_ASS_REC_EXPR   ] = ExecAssRecExpr;
    ExecStatFuncs [ T_UNB_REC_NAME   ] = ExecUnbRecName;
    ExecStatFuncs [ T_UNB_REC_EXPR   ] = ExecUnbRecExpr;
    EvalExprFuncs [ T_ELM_REC_NAME   ] = EvalElmRecName;
    EvalExprFuncs [ T_ELM_REC_EXPR   ] = EvalElmRecExpr;
    EvalExprFuncs [ T_ISB_REC_NAME   ] = EvalIsbRecName;
    EvalExprFuncs [ T_ISB_REC_EXPR   ] = EvalIsbRecExpr;
    PrintStatFuncs[ T_ASS_REC_NAME   ] = PrintAssRecName;
    PrintStatFuncs[ T_ASS_REC_EXPR   ] = PrintAssRecExpr;
    PrintStatFuncs[ T_UNB_REC_NAME   ] = PrintUnbRecName;
    PrintStatFuncs[ T_UNB_REC_EXPR   ] = PrintUnbRecExpr;
    PrintExprFuncs[ T_ELM_REC_NAME   ] = PrintElmRecName;
    PrintExprFuncs[ T_ELM_REC_EXPR   ] = PrintElmRecExpr;
    PrintExprFuncs[ T_ISB_REC_NAME   ] = PrintIsbRecName;
    PrintExprFuncs[ T_ISB_REC_EXPR   ] = PrintIsbRecExpr;

    /* install executors, evaluators, and printers for list elements       */
    ExecStatFuncs [ T_ASS_POSOBJ       ] = ExecAssPosobj;
    ExecStatFuncs [ T_UNB_POSOBJ       ] = ExecUnbPosobj;
    EvalExprFuncs [ T_ELM_POSOBJ       ] = EvalElmPosobj;
    EvalExprFuncs [ T_ISB_POSOBJ       ] = EvalIsbPosobj;
    PrintStatFuncs[ T_ASS_POSOBJ       ] = PrintAssPosobj;
    PrintStatFuncs[ T_UNB_POSOBJ       ] = PrintUnbPosobj;
    PrintExprFuncs[ T_ELM_POSOBJ       ] = PrintElmPosobj;
    PrintExprFuncs[ T_ISB_POSOBJ       ] = PrintIsbPosobj;

    /* install executors, evaluators, and printers for record elements     */
    ExecStatFuncs [ T_ASS_COMOBJ_NAME  ] = ExecAssComobjName;
    ExecStatFuncs [ T_ASS_COMOBJ_EXPR  ] = ExecAssComobjExpr;
    ExecStatFuncs [ T_UNB_COMOBJ_NAME  ] = ExecUnbComobjName;
    ExecStatFuncs [ T_UNB_COMOBJ_EXPR  ] = ExecUnbComobjExpr;
    EvalExprFuncs [ T_ELM_COMOBJ_NAME  ] = EvalElmComobjName;
    EvalExprFuncs [ T_ELM_COMOBJ_EXPR  ] = EvalElmComobjExpr;
    EvalExprFuncs [ T_ISB_COMOBJ_NAME  ] = EvalIsbComobjName;
    EvalExprFuncs [ T_ISB_COMOBJ_EXPR  ] = EvalIsbComobjExpr;
    PrintStatFuncs[ T_ASS_COMOBJ_NAME  ] = PrintAssComobjName;
    PrintStatFuncs[ T_ASS_COMOBJ_EXPR  ] = PrintAssComobjExpr;
    PrintStatFuncs[ T_UNB_COMOBJ_NAME  ] = PrintUnbComobjName;
    PrintStatFuncs[ T_UNB_COMOBJ_EXPR  ] = PrintUnbComobjExpr;
    PrintExprFuncs[ T_ELM_COMOBJ_NAME  ] = PrintElmComobjName;
    PrintExprFuncs[ T_ELM_COMOBJ_EXPR  ] = PrintElmComobjExpr;
    PrintExprFuncs[ T_ISB_COMOBJ_NAME  ] = PrintIsbComobjName;
    PrintExprFuncs[ T_ISB_COMOBJ_EXPR  ] = PrintIsbComobjExpr;

    /* install before and after actions for garbage collections            */
    InitCollectFuncBags( VarsBeforeCollectBags, VarsAfterCollectBags );

    /* make 'CurrLVars' known to Gasman                                    */
    InitGlobalBag( &CurrLVars );
    InitGlobalBag( &BottomLVars );
    BottomLVars = NewBag( T_LVARS, 3*sizeof(Obj) );
    tmp = NewFunctionC( "bottom", 0, "", 0 );
    PTR_BAG(BottomLVars)[0] = tmp;
    tmp = NewBag( T_BODY, 0 );
    BODY_FUNC( PTR_BAG(BottomLVars)[0] ) = tmp;
    SWITCH_TO_OLD_LVARS( BottomLVars );
}


/****************************************************************************
**

*E  vars.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
