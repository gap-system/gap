/****************************************************************************
**
*A  funcs.c                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of the function interpreter package.
**
**  The function interpreter package   contains the executors  for  procedure
**  calls, the  evaluators  for function calls,  the   evaluator for function
**  expressions, and the handlers for the execution of function bodies.
**
**  It uses the function call mechanism defined by the calls package.
*/
char *          Revision_funcs_c =
   "@(#)$Id$";

#include        <assert.h>              /* assert                          */

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "calls.h"               /* CALL_<i>ARGS, Function, ObjFunc */

#include        "lists.h"               /* ELM_LIST, LEN_LIST              */

#include        "plist.h"               /* SET_ELM_PLIST, SET_LEN_PLIST,...*/

#include        "code.h"                /* Stat, Expr, FUNC_CALL, ARGI_C...*/
#include        "vars.h"                /* ASS_LVAR, SWITCH_TO_NEW_LVARS...*/
#include        "exprs.h"               /* EVAL_EXPR, EvalExprFuncs        */
#include        "stats.h"               /* EXEC_STAT, ReturnObjStat, ...   */

#define INCLUDE_DECLARATION_PART
#include        "funcs.h"               /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**
*F  ExecProccall0args(<call>)  .  execute a procedure call with 0    arguments
*F  ExecProccall1args(<call>)  .  execute a procedure call with 1    arguments
*F  ExecProccall2args(<call>)  .  execute a procedure call with 2    arguments
*F  ExecProccall3args(<call>)  .  execute a procedure call with 3    arguments
*F  ExecProccall4args(<call>)  .  execute a procedure call with 4    arguments
*F  ExecProccall5args(<call>)  .  execute a procedure call with 5    arguments
*F  ExecProccall6args(<call>)  .  execute a procedure call with 6    arguments
*F  ExecProccallXargs(<call>)  .  execute a procedure call with more arguments
**
**  'ExecProccall<i>args'  executes  a  procedure   call   to the    function
**  'FUNC_CALL(<call>)'   with   the   arguments   'ARGI_CALL(<call>,1)'   to
**  'ARGI_CALL(<call>,<i>)'.  It returns the value returned by the function.
*/
UInt            ExecProccall0args (
    Stat                call )
{
    Obj                 func;           /* function                        */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    CALL_0ARGS( func );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecProccall1args (
    Stat                call )
{
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    CALL_1ARGS( func, arg1 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecProccall2args (
    Stat                call )
{
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    CALL_2ARGS( func, arg1, arg2 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecProccall3args (
    Stat                call )
{
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */
    Obj                 arg3;           /* third  argument                 */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    CALL_3ARGS( func, arg1, arg2, arg3 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecProccall4args (
    Stat                call )
{
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */
    Obj                 arg3;           /* third  argument                 */
    Obj                 arg4;           /* fourth argument                 */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    CALL_4ARGS( func, arg1, arg2, arg3, arg4 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecProccall5args (
    Stat                call )
{
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */
    Obj                 arg3;           /* third  argument                 */
    Obj                 arg4;           /* fourth argument                 */
    Obj                 arg5;           /* fifth  argument                 */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );
    arg5 = EVAL_EXPR( ARGI_CALL( call, 5 ) );

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    CALL_5ARGS( func, arg1, arg2, arg3, arg4, arg5 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecProccall6args (
    Stat                call )
{
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */
    Obj                 arg3;           /* third  argument                 */
    Obj                 arg4;           /* fourth argument                 */
    Obj                 arg5;           /* fifth  argument                 */
    Obj                 arg6;           /* sixth  argument                 */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );
    arg5 = EVAL_EXPR( ARGI_CALL( call, 5 ) );
    arg6 = EVAL_EXPR( ARGI_CALL( call, 6 ) );

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    CALL_6ARGS( func, arg1, arg2, arg3, arg4, arg5, arg6 );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecProccallXargs (
    Stat                call )
{
    Obj                 func;           /* function                        */
    Obj                 args;           /* argument list                   */
    Obj                 argi;           /* <i>-th argument                 */
    UInt                i;              /* loop variable                   */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    args = NEW_PLIST( T_PLIST, NARG_SIZE_CALL(SIZE_STAT(call)) );
    SET_LEN_PLIST( args, NARG_SIZE_CALL(SIZE_STAT(call)) );
    for ( i = 1; i <= NARG_SIZE_CALL(SIZE_STAT(call)); i++ ) {
        argi = EVAL_EXPR( ARGI_CALL( call, i ) );
        SET_ELM_PLIST( args, i, argi );
        CHANGED_BAG( args );
    }

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    CALL_XARGS( func, args );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalFunccall0args(<call>)  . . execute a function call with 0    arguments
*F  EvalFunccall1args(<call>)  . . execute a function call with 1    arguments
*F  EvalFunccall2args(<call>)  . . execute a function call with 2    arguments
*F  EvalFunccall3args(<call>)  . . execute a function call with 3    arguments
*F  EvalFunccall4args(<call>)  . . execute a function call with 4    arguments
*F  EvalFunccall5args(<call>)  . . execute a function call with 5    arguments
*F  EvalFunccall6args(<call>)  . . execute a function call with 6    arguments
*F  EvalFunccallXargs(<call>)  . . execute a function call with more arguments
**
**  'EvalFunccall<i>args'  executes  a     function call   to   the  function
**  'FUNC_CALL(<call>)'    with  the   arguments    'ARGI_CALL(<call>,1)'  to
**  'ARGI_CALL(<call>,<i>)'.  It returns the value returned by the function.
*/
Obj             EvalFunccall0args (
    Expr                call )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 func;           /* function                        */

    /* evaluate the function                                               */
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_0ARGS( func );
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can return a value for the result" );
    }
    return result;
}

Obj             EvalFunccall1args (
    Expr                call )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */

    /* evaluate the function                                               */
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_1ARGS( func, arg1 );
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can return a value for the result" );
    }
    return result;
}

Obj             EvalFunccall2args (
    Expr                call )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */

    /* evaluate the function                                               */
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_2ARGS( func, arg1, arg2 );
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can return a value for the result" );
    }
    return result;
}

Obj             EvalFunccall3args (
    Expr                call )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */
    Obj                 arg3;           /* third  argument                 */

    /* evaluate the function                                               */
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_3ARGS( func, arg1, arg2, arg3 );
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can return a value for the result" );
    }
    return result;
}

Obj             EvalFunccall4args (
    Expr                call )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */
    Obj                 arg3;           /* third  argument                 */
    Obj                 arg4;           /* fourth argument                 */

    /* evaluate the function                                               */
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_4ARGS( func, arg1, arg2, arg3, arg4 );
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can return a value for the result" );
    }
    return result;
}

Obj             EvalFunccall5args (
    Expr                call )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */
    Obj                 arg3;           /* third  argument                 */
    Obj                 arg4;           /* fourth argument                 */
    Obj                 arg5;           /* fifth  argument                 */

    /* evaluate the function                                               */
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );
    arg5 = EVAL_EXPR( ARGI_CALL( call, 5 ) );

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_5ARGS( func, arg1, arg2, arg3, arg4, arg5 );
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can return a value for the result" );
    }
    return result;
}

Obj             EvalFunccall6args (
    Expr                call )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 func;           /* function                        */
    Obj                 arg1;           /* first  argument                 */
    Obj                 arg2;           /* second argument                 */
    Obj                 arg3;           /* third  argument                 */
    Obj                 arg4;           /* fourth argument                 */
    Obj                 arg5;           /* fifth  argument                 */
    Obj                 arg6;           /* sixth  argument                 */

    /* evaluate the function                                               */
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );
    arg5 = EVAL_EXPR( ARGI_CALL( call, 5 ) );
    arg6 = EVAL_EXPR( ARGI_CALL( call, 6 ) );

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_6ARGS( func, arg1, arg2, arg3, arg4, arg5, arg6 );
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can return a value for the result" );
    }
    return result;
}

Obj             EvalFunccallXargs (
    Expr                call )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 func;           /* function                        */
    Obj                 args;           /* argument list                   */
    Obj                 argi;           /* <i>-th argument                 */
    UInt                i;              /* loop variable                   */

    /* evaluate the function                                               */
    func = EVAL_EXPR( FUNC_CALL( call ) );
    while ( TYPE_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* evaluate the arguments                                              */
    args = NEW_PLIST( T_PLIST, NARG_SIZE_CALL(SIZE_EXPR(call)) );
    SET_LEN_PLIST( args, NARG_SIZE_CALL(SIZE_EXPR(call)) );
    for ( i = 1; i <= NARG_SIZE_CALL(SIZE_EXPR(call)); i++ ) {
        argi = EVAL_EXPR( ARGI_CALL( call, i ) );
        SET_ELM_PLIST( args, i, argi );
        CHANGED_BAG( args );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_XARGS( func, args );
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can return a value for the result" );
    }
    return result;
}


/****************************************************************************
**
*F  DoExecFunc0args(<func>)  . . . .  interpret a function with 0    arguments
*F  DoExecFunc1args(<func>,<arg1>) .  interpret a function with 1    arguments
*F  DoExecFunc2args(<func>,<arg1>...) interpret a function with 2    arguments
*F  DoExecFunc3args(<func>,<arg1>...) interpret a function with 3    arguments
*F  DoExecFunc4args(<func>,<arg1>...) interpret a function with 4    arguments
*F  DoExecFunc5args(<func>,<arg1>...) interpret a function with 5    arguments
*F  DoExecFunc6args(<func>,<arg1>...) interpret a function with 6    arguments
*F  DoExecFuncXargs(<func>,<args>) .  interpret a function with more arguments
**
**  'DoExecFunc<i>args' interprets   the function  <func>  that  expects  <i>
**  arguments with the <i> actual argument <arg1>, <arg2>, and so on.  If the
**  function expects more than 4 arguments the actual arguments are passed in
**  the plain list <args>.
**
**  'DoExecFunc<i>args'  is the  handler  for interpreted functions expecting
**  <i> arguments.
**
**  'DoExecFunc<i>args' first switches  to a new  values bag.  Then it enters
**  the arguments <arg1>, <arg2>, and so on in this new  values bag.  Then it
**  executes  the function body.   After  that it  switches back  to  the old
**  values bag.  Finally it returns the result from 'ReturnObjStat'.
**
**  Note that these functions are never called directly, they are only called
**  through the function call mechanism.
*/
Obj             DoExecFunc0args (
    Obj                 func )
{
    Bag                 oldLvars;       /* old values bag                  */
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 0, NLOC_FUNC(func), oldLvars );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS( oldLvars );

    /* return the result                                                   */
    return ReturnObjStat;
}

Obj             DoExecFunc1args (
    Obj                 func,
    Obj                 arg1 )
{
    Bag                 oldLvars;       /* old values bag                  */
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 1, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    ASS_LVAR( 1, arg1 );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS( oldLvars );

    /* return the result                                                   */
    return ReturnObjStat;
}

Obj             DoExecFunc2args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2 )
{
    Bag                 oldLvars;       /* old values bag                  */
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 2, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    ASS_LVAR( 1, arg1 );
    ASS_LVAR( 2, arg2 );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS( oldLvars );

    /* return the result                                                   */
    return ReturnObjStat;
}

Obj             DoExecFunc3args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Bag                 oldLvars;       /* old values bag                  */
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 3, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    ASS_LVAR( 1, arg1 );
    ASS_LVAR( 2, arg2 );
    ASS_LVAR( 3, arg3 );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS( oldLvars );

    /* return the result                                                   */
    return ReturnObjStat;
}

Obj             DoExecFunc4args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Bag                 oldLvars;       /* old values bag                  */
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 4, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    ASS_LVAR( 1, arg1 );
    ASS_LVAR( 2, arg2 );
    ASS_LVAR( 3, arg3 );
    ASS_LVAR( 4, arg4 );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS( oldLvars );

    /* return the result                                                   */
    return ReturnObjStat;
}

Obj             DoExecFunc5args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Bag                 oldLvars;       /* old values bag                  */
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 5, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    ASS_LVAR( 1, arg1 );
    ASS_LVAR( 2, arg2 );
    ASS_LVAR( 3, arg3 );
    ASS_LVAR( 4, arg4 );
    ASS_LVAR( 5, arg5 );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS( oldLvars );

    /* return the result                                                   */
    return ReturnObjStat;
}

Obj             DoExecFunc6args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Bag                 oldLvars;       /* old values bag                  */
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 6, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    ASS_LVAR( 1, arg1 );
    ASS_LVAR( 2, arg2 );
    ASS_LVAR( 3, arg3 );
    ASS_LVAR( 4, arg4 );
    ASS_LVAR( 5, arg5 );
    ASS_LVAR( 6, arg6 );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS( oldLvars );

    /* return the result                                                   */
    return ReturnObjStat;
}

Obj             DoExecFuncXargs (
    Obj                 func,
    Obj                 args )
{
    Bag                 oldLvars;       /* old values bag                  */
    OLD_BRK_CURR_STAT                   /* old executing statement         */
    UInt                len;            /* number of arguments             */
    UInt                i;              /* loop variable                   */

    /* check the number of arguments                                       */
    len = NARG_FUNC( func );
    while ( len != LEN_PLIST( args ) ) {
        args = ErrorReturnObj(
            "Function Calls: number of arguments must be %d (not %d)",
            len, LEN_PLIST( args ),
            "you can return a list of arguments" );
        PLAIN_LIST( args );
    }

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, len, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    for ( i = 1; i <= len; i++ ) {
        ASS_LVAR( i, ELM_PLIST( args, i ) );
    }

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS( oldLvars );

    /* return the result                                                   */
    return ReturnObjStat;
}


/****************************************************************************
**
*F  MakeFunction(<fexp>)  . . . . . . . . . . . . . . . . . . make a function
**
**  'MakeFunction' makes a function from the function expression bag <fexp>.
*/
Obj             MakeFunction (
    Obj                 fexp )
{
    Obj                 func;           /* function, result                */
    ObjFunc             hdlr;           /* handler                         */

    /* select the right handler                                            */
    if      ( NARG_FUNC(fexp) ==  0 )  hdlr = DoExecFunc0args;
    else if ( NARG_FUNC(fexp) ==  1 )  hdlr = DoExecFunc1args;
    else if ( NARG_FUNC(fexp) ==  2 )  hdlr = DoExecFunc2args;
    else if ( NARG_FUNC(fexp) ==  3 )  hdlr = DoExecFunc3args;
    else if ( NARG_FUNC(fexp) ==  4 )  hdlr = DoExecFunc4args;
    else if ( NARG_FUNC(fexp) ==  5 )  hdlr = DoExecFunc5args;
    else if ( NARG_FUNC(fexp) ==  6 )  hdlr = DoExecFunc6args;
    else if ( NARG_FUNC(fexp) >=  7 )  hdlr = DoExecFuncXargs;
    else   /* NARG_FUNC(fexp) == -1 */ hdlr = DoExecFunc1args;

    /* make the function                                                   */
    func = NewFunctionT( T_FUNCTION, SIZE_FUNC,
                         NAME_FUNC( fexp ),
                         NARG_FUNC( fexp ), NAMS_FUNC( fexp ),
                         hdlr );

    /* install the things an interpreted function needs                    */
    NLOC_FUNC( func ) = NLOC_FUNC( fexp );
    BODY_FUNC( func ) = BODY_FUNC( fexp );
    ENVI_FUNC( func ) = CurrLVars;
    /* the 'CHANGED_BAG(CurrLVars)' is needed because it is delayed        */
    CHANGED_BAG( CurrLVars );
    FEXS_FUNC( func ) = FEXS_FUNC( fexp );

    /* return the function                                                 */
    return func;
}


/****************************************************************************
**
*F  EvalFuncExpr(<expr>)  . . .  evaluate a function expression to a function
**
**  'EvalFuncExpr' evaluates the function expression <expr> to a function.
*/
Obj             EvalFuncExpr (
    Expr                expr )
{
    Obj                 fexs;           /* func. expr. list of curr. func. */
    Obj                 fexp;           /* function expression bag         */

    /* get the function expression bag                                     */
    fexs = FEXS_FUNC( CURR_FUNC );
    fexp = ELM_PLIST( fexs, (Int)(ADDR_EXPR(expr)[0]) );

    /* and make the function                                               */
    return MakeFunction( fexp );
}


/****************************************************************************
**
*F  PrintProccall(<call>) . . . . . . . . . . . . . .  print a procedure call
**
**  'PrintProccall' prints a procedure call.
*/
extern  void            PrintFunccall (
            Expr                call );

void            PrintProccall (
    Stat                call )
{
    PrintFunccall( call );
    Pr( ";", 0L, 0L );
}


/****************************************************************************
**
*F  PrintFunccall(<call>) . . . . . . . . . . . . . . . print a function call
**
**  'PrintFunccall' prints a function call.
*/
void            PrintFunccall (
    Expr                call )
{
    UInt                i;              /* loop variable                   */

    /* print the expression that should evaluate to a function             */
    Pr("%2>",0L,0L);
    PrintExpr( FUNC_CALL(call) );

    /* print the opening parenthesis                                       */
    Pr("%<( %>",0L,0L);

    /* print the expressions that evaluate to the actual arguments         */
    for ( i = 1; i <= NARG_SIZE_CALL( SIZE_EXPR(call) ); i++ ) {
        PrintExpr( ARGI_CALL(call,i) );
        if ( i != NARG_SIZE_CALL( SIZE_EXPR(call) ) ) {
            Pr("%<, %>",0L,0L);
        }
    }

    /* print the closing parenthesis                                       */
    Pr(" %2<)",0L,0L);
}


/****************************************************************************
**
*F  PrintFuncExpr(<expr>) . . . . . . . . . . . . print a function expression
**
**  'PrintFuncExpr' prints a function expression.
*/
void            PrintFuncExpr (
    Expr                expr )
{
    Pr("function ... end",0L,0L);
}


/****************************************************************************
**
*F  ExecBegin() . . . . . . . . . . . . . . . . . . . . .  begin an execution
*F  ExecEnd(<error>)  . . . . . . . . . . . . . . . . . . .  end an execution
*/
Obj             ExecState;

void            ExecBegin ( void )
{
    Obj                 execState;      /* old execution state             */

    /* remember the old execution state                                    */
    execState = NewBag( T_PLIST, 4*sizeof(Obj) );
    ADDR_OBJ(execState)[0] = (Obj)3;
    ADDR_OBJ(execState)[1] = ExecState;
    ADDR_OBJ(execState)[2] = CurrLVars;
    /* the 'CHANGED_BAG(CurrLVars)' is needed because it is delayed        */
    CHANGED_BAG( CurrLVars );
    ADDR_OBJ(execState)[3] = (Obj)(Int)CurrStat;
    ExecState = execState;

    /* set up new state                                                    */
    SWITCH_TO_OLD_LVARS( BottomLVars );
    SET_BRK_CURR_STAT( 0 );
}

void            ExecEnd (
    UInt                error )
{
    /* if everything went fine                                             */
    if ( ! error ) {

        /* the state must be primal again                                  */
        assert( CurrLVars == BottomLVars );
        assert( CurrStat  == 0 );

        /* switch back to the old state                                    */
        SET_BRK_CURR_STAT( (Stat)(Int)(ADDR_OBJ(ExecState)[3]) );
        SWITCH_TO_OLD_LVARS( ADDR_OBJ(ExecState)[2] );
        ExecState = ADDR_OBJ(ExecState)[1];

    }

    /* otherwise clean up the mess                                         */
    else {

        /* switch back to the old state                                    */
        SET_BRK_CURR_STAT( (Stat)(Int)(ADDR_OBJ(ExecState)[3]) );
        SWITCH_TO_OLD_LVARS( ADDR_OBJ(ExecState)[2] );
        ExecState = ADDR_OBJ(ExecState)[1];

    }
}


/****************************************************************************
**
*F  InitFuncs() . . . . . . . . . . . . . . . . . initialize function package
**
**  'InitFuncs' installs the  executing   functions that  are  needed by  the
**  executor  to execute procedure  calls,  the evaluating functions that are
**  needed by the  evaluator to evaluate function  calls, and  the evaluating
**  function that   is   needed  by  the  evaluator to    evaluate   function
**  expressions.   It  also  installs the printing    functions for procedure
**  calls, function calls, and function expressions.
*/
void            InitFuncs ( void )
{
    /* make the global variable known to Gasman                            */
    InitGlobalBag( &ExecState, "funcs: ExecState" );

    /* install the evaluators and executors                                */
    ExecStatFuncs [ T_PROCCALL_0ARGS ] = ExecProccall0args;
    ExecStatFuncs [ T_PROCCALL_1ARGS ] = ExecProccall1args;
    ExecStatFuncs [ T_PROCCALL_2ARGS ] = ExecProccall2args;
    ExecStatFuncs [ T_PROCCALL_3ARGS ] = ExecProccall3args;
    ExecStatFuncs [ T_PROCCALL_4ARGS ] = ExecProccall4args;
    ExecStatFuncs [ T_PROCCALL_5ARGS ] = ExecProccall5args;
    ExecStatFuncs [ T_PROCCALL_6ARGS ] = ExecProccall6args;
    ExecStatFuncs [ T_PROCCALL_XARGS ] = ExecProccallXargs;
    EvalExprFuncs [ T_FUNCCALL_0ARGS ] = EvalFunccall0args;
    EvalExprFuncs [ T_FUNCCALL_1ARGS ] = EvalFunccall1args;
    EvalExprFuncs [ T_FUNCCALL_2ARGS ] = EvalFunccall2args;
    EvalExprFuncs [ T_FUNCCALL_3ARGS ] = EvalFunccall3args;
    EvalExprFuncs [ T_FUNCCALL_4ARGS ] = EvalFunccall4args;
    EvalExprFuncs [ T_FUNCCALL_5ARGS ] = EvalFunccall5args;
    EvalExprFuncs [ T_FUNCCALL_6ARGS ] = EvalFunccall6args;
    EvalExprFuncs [ T_FUNCCALL_XARGS ] = EvalFunccallXargs;
    EvalExprFuncs [ T_FUNC_EXPR      ] = EvalFuncExpr;

    /* install the printers                                                */
    PrintStatFuncs[ T_PROCCALL_0ARGS ] = PrintProccall;
    PrintStatFuncs[ T_PROCCALL_1ARGS ] = PrintProccall;
    PrintStatFuncs[ T_PROCCALL_2ARGS ] = PrintProccall;
    PrintStatFuncs[ T_PROCCALL_3ARGS ] = PrintProccall;
    PrintStatFuncs[ T_PROCCALL_4ARGS ] = PrintProccall;
    PrintStatFuncs[ T_PROCCALL_5ARGS ] = PrintProccall;
    PrintStatFuncs[ T_PROCCALL_6ARGS ] = PrintProccall;
    PrintStatFuncs[ T_PROCCALL_XARGS ] = PrintProccall;
    PrintExprFuncs[ T_FUNCCALL_0ARGS ] = PrintFunccall;
    PrintExprFuncs[ T_FUNCCALL_1ARGS ] = PrintFunccall;
    PrintExprFuncs[ T_FUNCCALL_2ARGS ] = PrintFunccall;
    PrintExprFuncs[ T_FUNCCALL_3ARGS ] = PrintFunccall;
    PrintExprFuncs[ T_FUNCCALL_4ARGS ] = PrintFunccall;
    PrintExprFuncs[ T_FUNCCALL_5ARGS ] = PrintFunccall;
    PrintExprFuncs[ T_FUNCCALL_6ARGS ] = PrintFunccall;
    PrintExprFuncs[ T_FUNCCALL_XARGS ] = PrintFunccall;
    PrintExprFuncs[ T_FUNC_EXPR      ] = PrintFuncExpr;


    InitHandlerFunc( DoExecFunc0args, "0 arg interpreted function");
    InitHandlerFunc( DoExecFunc1args, "1 arg interpreted function");
    InitHandlerFunc( DoExecFunc2args, "2 arg interpreted function");
    InitHandlerFunc( DoExecFunc3args, "3 arg interpreted function");
    InitHandlerFunc( DoExecFunc4args, "4 arg interpreted function");
    InitHandlerFunc( DoExecFunc5args, "5 arg interpreted function");
    InitHandlerFunc( DoExecFunc6args, "6 arg interpreted function");
    InitHandlerFunc( DoExecFuncXargs, "X arg interpreted function");
}


/****************************************************************************
**
*E  funcs.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



