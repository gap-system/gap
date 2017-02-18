/****************************************************************************
**
*W  funcs.c                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the function interpreter package.
**
**  The function interpreter package   contains the executors  for  procedure
**  calls, the  evaluators  for function calls,  the   evaluator for function
**  expressions, and the handlers for the execution of function bodies.
**
**  It uses the function call mechanism defined by the calls package.
*/
#include        <stdio.h>               /* on SunOS, assert.h uses stderr
                                           but does not include stdio.h    */
#include        <assert.h>              /* assert                          */
#include        "system.h"              /* Ints, UInts                     */
#include        "bool.h"


#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "stringobj.h"              /* strings                         */
#include        "calls.h"               /* generic call mechanism          */

#include        "code.h"                /* coder                           */
#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */

#include        "funcs.h"               /* functions                       */

#include        "read.h"                /* read expressions                */
#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */


#include        "saveload.h"            /* saving and loading              */

#include        "opers.h"               /* generic operations              */
#include        "gvars.h"
#include        "hpc/thread.h"          /* threads                         */
#include        "hpc/tls.h"             /* thread-local storage            */

#include        "vars.h"                /* variables                       */


#include        "profile.h"             /* installing methods              */
/****************************************************************************
**
*F ExecProccallOpts( <call> ). . execute a procedure call with options
**
** Calls with options are wrapped in an outer statement, which is
** handled here
*/

static Obj PushOptions;
static Obj PopOptions;

UInt ExecProccallOpts(
    Stat                call )
{
  Obj opts;
  
  SET_BRK_CURR_STAT( call );
  opts = EVAL_EXPR( ADDR_STAT(call)[0] );
  CALL_1ARGS(PushOptions, opts);

  EXEC_STAT( ADDR_STAT( call )[1]);

  CALL_0ARGS(PopOptions);
  
  return 0;
}


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

static Obj DispatchFuncCall( Obj func, Int nargs, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6)
{ 
  Obj arglist;
  if (nargs != -1) {
    arglist = NEW_PLIST(T_PLIST_DENSE, nargs);
    SET_LEN_PLIST(arglist, nargs);
    switch(nargs) {
    case 6: 
      SET_ELM_PLIST(arglist,6, arg6);
    case 5:
      SET_ELM_PLIST(arglist,5, arg5);
    case 4: 
      SET_ELM_PLIST(arglist,4, arg4);
    case 3:
      SET_ELM_PLIST(arglist,3, arg3);
    case 2: 
      SET_ELM_PLIST(arglist,2, arg2);
    case 1:
      SET_ELM_PLIST(arglist,1, arg1);
    case 0:
      CHANGED_BAG(arglist);
    }
  } else {
    arglist = arg1;
  }
  return DoOperation2Args(CallFuncListOper, func, arglist);
}


UInt            ExecProccall0args (
    Stat                call )
{
    Obj                 func;           /* function                        */

    /* evaluate the function                                               */
    SET_BRK_CURR_STAT( call );
    func = EVAL_EXPR( FUNC_CALL( call ) );

    /* call the function                                                   */
    SET_BRK_CALL_TO( call );
    if (TNUM_OBJ(func) != T_FUNCTION)
      DispatchFuncCall(func, 0, (Obj) 0L,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L);
    else {
      CALL_0ARGS( func );
    }
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
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
  
    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
 
    /* call the function                                                   */
    if (TNUM_OBJ(func) != T_FUNCTION)
      DispatchFuncCall(func, 1, (Obj) arg1,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L);
    else {
      SET_BRK_CALL_TO( call );
      CALL_1ARGS( func, arg1 );
    } 
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
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
 
    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );

    /* call the function                                                   */
    if (TNUM_OBJ(func) != T_FUNCTION)
      DispatchFuncCall(func, 2, (Obj) arg1,  (Obj) arg2,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L);
    else {
      SET_BRK_CALL_TO( call );
      CALL_2ARGS( func, arg1, arg2 );
    }
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
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
 
    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );

    /* call the function                                                   */
    if (TNUM_OBJ(func) != T_FUNCTION)
      DispatchFuncCall(func, 3, (Obj) arg1,  (Obj) arg2,  (Obj) arg3,  (Obj) 0L,  (Obj) 0L,  (Obj) 0L);
    else {
      SET_BRK_CALL_TO( call );
      CALL_3ARGS( func, arg1, arg2, arg3 );
    }
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
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
 
    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );

    /* call the function                                                   */
    if (TNUM_OBJ(func) != T_FUNCTION)
      DispatchFuncCall(func, 4, (Obj) arg1,  (Obj) arg2,  (Obj) arg3,  (Obj) arg4,  (Obj) 0,  (Obj) 0);
    else {
      SET_BRK_CALL_TO( call );
      CALL_4ARGS( func, arg1, arg2, arg3, arg4 );
    }
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
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
    while ( TNUM_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "Function Calls: <func> must be a function (not a %s)",
            (Int)TNAM_OBJ(func), 0L,
            "you can replace <func> via 'return <func>;'" );
    }

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );
    arg5 = EVAL_EXPR( ARGI_CALL( call, 5 ) );

    /* call the function                                                   */
    if (TNUM_OBJ(func) != T_FUNCTION)
      DispatchFuncCall(func, 5, (Obj) arg1,  (Obj) arg2,  (Obj) arg3,  (Obj) arg4,  (Obj) arg5,  (Obj) 0L);
    else {
      SET_BRK_CALL_TO( call );
      CALL_5ARGS( func, arg1, arg2, arg3, arg4, arg5 );
    }
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
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
 
    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );
    arg5 = EVAL_EXPR( ARGI_CALL( call, 5 ) );
    arg6 = EVAL_EXPR( ARGI_CALL( call, 6 ) );

    /* call the function                                                   */
    if (TNUM_OBJ(func) != T_FUNCTION)
      DispatchFuncCall(func, 6, (Obj) arg1,  (Obj) arg2,  (Obj) arg3,  (Obj) arg4,  (Obj) arg5,  (Obj) arg6);
    else {
      SET_BRK_CALL_TO( call );
      CALL_6ARGS( func, arg1, arg2, arg3, arg4, arg5, arg6 );
    }
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
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
 

    /* evaluate the arguments                                              */
    args = NEW_PLIST( T_PLIST, NARG_SIZE_CALL(SIZE_STAT(call)) );
    SET_LEN_PLIST( args, NARG_SIZE_CALL(SIZE_STAT(call)) );
    for ( i = 1; i <= NARG_SIZE_CALL(SIZE_STAT(call)); i++ ) {
        argi = EVAL_EXPR( ARGI_CALL( call, i ) );
        SET_ELM_PLIST( args, i, argi );
        CHANGED_BAG( args );
    }

    /* call the function                                                   */
    if (TNUM_OBJ(func) != T_FUNCTION) {
      DoOperation2Args(CallFuncListOper, func, args);
    } else {
      SET_BRK_CALL_TO( call );
      CALL_XARGS( func, args );
    }

    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

/****************************************************************************
**
*F EvalFunccallOpts( <call> ). . evaluate a function call with options
**
** Calls with options are wrapped in an outer statement, which is
** handled here
*/

Obj EvalFunccallOpts(
    Expr                call )
{
  Obj opts;
  Obj res;
  
  
  opts = EVAL_EXPR( ADDR_STAT(call)[0] );
  CALL_1ARGS(PushOptions, opts);

  res = EVAL_EXPR( ADDR_STAT( call )[1]);

  CALL_0ARGS(PopOptions);
  
  return res;
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

    if (TNUM_OBJ(func) != T_FUNCTION) {
      return DispatchFuncCall(func, 0, (Obj) 0, (Obj) 0, (Obj) 0, (Obj) 0, (Obj) 0, (Obj) 0 );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_0ARGS( func );
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can supply one by 'return <value>;'" );
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
      /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );

    if (TNUM_OBJ(func) != T_FUNCTION) {
      return DispatchFuncCall(func, 1, (Obj) arg1, (Obj) 0, (Obj) 0, (Obj) 0, (Obj) 0, (Obj) 0 );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_1ARGS( func, arg1 );
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can supply one by 'return <value>;'" );
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

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );

    if (TNUM_OBJ(func) != T_FUNCTION) {
      return DispatchFuncCall(func, 2, (Obj) arg1, (Obj) arg2, (Obj) 0, (Obj) 0, (Obj) 0, (Obj) 0 );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_2ARGS( func, arg1, arg2 );
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can supply one by 'return <value>;'" );
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

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );

    if (TNUM_OBJ(func) != T_FUNCTION) {
      return DispatchFuncCall(func, 1, (Obj) arg1, (Obj) arg2, (Obj) arg3, (Obj) 0, (Obj) 0, (Obj) 0 );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_3ARGS( func, arg1, arg2, arg3 );
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can supply one by 'return <value>;'" );
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
    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );

    if (TNUM_OBJ(func) != T_FUNCTION) {
      return DispatchFuncCall(func, 4, (Obj) arg1, (Obj) arg2, (Obj) arg3, (Obj) arg4, (Obj) 0, (Obj) 0 );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_4ARGS( func, arg1, arg2, arg3, arg4 );
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can supply one by 'return <value>;'" );
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

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );
    arg5 = EVAL_EXPR( ARGI_CALL( call, 5 ) );

    if (TNUM_OBJ(func) != T_FUNCTION) {
      return DispatchFuncCall(func, 5, (Obj) arg1, (Obj) arg2, (Obj) arg3, (Obj) arg4, (Obj) arg5, (Obj) 0 );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_5ARGS( func, arg1, arg2, arg3, arg4, arg5 );
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can supply one by 'return <value>;'" );
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

    /* evaluate the arguments                                              */
    arg1 = EVAL_EXPR( ARGI_CALL( call, 1 ) );
    arg2 = EVAL_EXPR( ARGI_CALL( call, 2 ) );
    arg3 = EVAL_EXPR( ARGI_CALL( call, 3 ) );
    arg4 = EVAL_EXPR( ARGI_CALL( call, 4 ) );
    arg5 = EVAL_EXPR( ARGI_CALL( call, 5 ) );
    arg6 = EVAL_EXPR( ARGI_CALL( call, 6 ) );

    if (TNUM_OBJ(func) != T_FUNCTION) {
      return DispatchFuncCall(func, 6, (Obj) arg1, (Obj) arg2, (Obj) arg3, (Obj) arg4, (Obj) arg5, (Obj) arg6 );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_6ARGS( func, arg1, arg2, arg3, arg4, arg5, arg6 );
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can supply one by 'return <value>;'" );
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

    /* evaluate the arguments                                              */
    args = NEW_PLIST( T_PLIST, NARG_SIZE_CALL(SIZE_EXPR(call)) );
    SET_LEN_PLIST( args, NARG_SIZE_CALL(SIZE_EXPR(call)) );
    for ( i = 1; i <= NARG_SIZE_CALL(SIZE_EXPR(call)); i++ ) {
        argi = EVAL_EXPR( ARGI_CALL( call, i ) );
        SET_ELM_PLIST( args, i, argi );
        CHANGED_BAG( args );
    }

    if (TNUM_OBJ(func) != T_FUNCTION) {
      return DispatchFuncCall(func, -1, (Obj) args, (Obj) 0, (Obj) 0, (Obj) 0, (Obj) 0, (Obj) 0 );
    }

    /* call the function and return the result                             */
    SET_BRK_CALL_TO( call );
    result = CALL_XARGS( func, args );
    if (TLS(UserHasQuit) || TLS(UserHasQUIT)) /* the procedure must have called
                                       READ() and the user quit from a break
                                       loop inside it */
      ReadEvalError();
    while ( result == 0 ) {
        result = ErrorReturnObj(
            "Function Calls: <func> must return a value",
            0L, 0L,
            "you can supply one by 'return <value>;'" );
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
**  values bag.  Finally it returns the result from 'TLS(ReturnObjStat)'.
**
**  Note that these functions are never called directly, they are only called
**  through the function call mechanism.
**
**  The following functions implement the recursion depth control.
**
*/

/* TL: Int RecursionDepth; */
UInt RecursionTrapInterval;

void RecursionDepthTrap( void )
{
    Int recursionDepth;
    /* in interactive work the RecursionDepth could become slightly negative
     * when quit-ting a higher level brk-loop to a lower level one.
     * Therefore we don't do anything if  RecursionDepth <= 0
    */
    if (TLS(RecursionDepth) > 0) {
        recursionDepth = TLS(RecursionDepth);
        TLS(RecursionDepth) = 0;
        ErrorReturnVoid( "recursion depth trap (%d)",
                         (Int)recursionDepth, 0L,
                         "you may 'return;'" );
        TLS(RecursionDepth) = recursionDepth;
    }
}
     
Obj STEVES_TRACING;

#define CHECK_RECURSION_BEFORE \
            CheckRecursionBefore(); \
            ProfileLineByLineIntoFunction(func);

#define CHECK_RECURSION_AFTER \
            TLS(RecursionDepth)--; \
            ProfileLineByLineOutFunction(func);

#define REMEMBER_LOCKSTACK() \
    do { } while (0)

#define CLEAR_LOCK_STACK() \
    do { } while (0)


Obj DoExecFunc0args (
    Obj                 func )
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    CHECK_RECURSION_BEFORE

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 0, NLOC_FUNC(func), oldLvars );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* Switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER
    
    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }
}

Obj             DoExecFunc1args (
    Obj                 func,
    Obj                 arg1 )
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    CHECK_RECURSION_BEFORE

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 1, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    ASS_LVAR( 1, arg1 );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }
}

Obj             DoExecFunc2args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2 )
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    CHECK_RECURSION_BEFORE

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, 2, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    ASS_LVAR( 1, arg1 );
    ASS_LVAR( 2, arg2 );

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }
}

Obj             DoExecFunc3args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    CHECK_RECURSION_BEFORE

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
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }
}

Obj             DoExecFunc4args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    CHECK_RECURSION_BEFORE

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
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }
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
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    CHECK_RECURSION_BEFORE

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
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }
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
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */

    CHECK_RECURSION_BEFORE

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
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }
}

Obj             DoExecFuncXargs (
    Obj                 func,
    Obj                 args )
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */
    UInt                len;            /* number of arguments             */
    UInt                i;              /* loop variable                   */

    CHECK_RECURSION_BEFORE

    /* check the number of arguments                                       */
    len = NARG_FUNC( func );
    while ( len != LEN_PLIST( args ) ) {
        args = ErrorReturnObj(
            "Function Calls: number of arguments must be %d (not %d)",
            len, LEN_PLIST( args ),
            "you can replace the <list> of arguments via 'return <list>;'" );
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
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }
}



Obj DoPartialUnWrapFunc(Obj func, Obj args)
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
    OLD_BRK_CURR_STAT                   /* old executing statement         */
    UInt                named;          /* number of arguments             */
    UInt                i;              /* loop variable                   */
    UInt len;
    Obj argx;


    named = ((UInt)-NARG_FUNC(func))-1;
    len = LEN_PLIST(args);

    if (named > len) { /* Can happen for > 6 arguments */
      argx = NargError(func, len);
      return DoOperation2Args(CallFuncListOper, func, argx);
    }

    CHECK_RECURSION_BEFORE

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, named+1, NLOC_FUNC(func), oldLvars );

    for (i = 1; i <= named; i++) {
      ASS_LVAR(i, ELM_PLIST(args,i));
    }
    for (i = named+1; i <= len; i++) {
      SET_ELM_PLIST(args, i-named, ELM_PLIST(args,i));
    }
    SET_LEN_PLIST(args, len-named);
    ASS_LVAR(named+1, args);

    /* execute the statement sequence                                      */
    REM_BRK_CURR_STAT();
    EXEC_STAT( FIRST_STAT_CURR_FUNC );
    RES_BRK_CURR_STAT();
    CLEAR_LOCK_STACK();

   /* remove the link to the calling function, in case this values bag
       stays alive due to higher variable reference */
    SET_BRK_CALL_FROM( ((Obj) 0));

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
      {
        Obj                 returnObjStat;
        returnObjStat = TLS(ReturnObjStat);
        TLS(ReturnObjStat) = (Obj)0;
        return returnObjStat;
      }  
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
    else if ( NARG_FUNC(fexp) == -1 )  hdlr = DoExecFunc1args;
    else /* NARG_FUNC(fexp) < -1 */    hdlr = DoPartialUnWrapFunc;

    /* make the function                                                   */
    func = NewFunctionT( T_FUNCTION, SIZE_FUNC,
                         NAME_FUNC( fexp ),
                         NARG_FUNC( fexp ), NAMS_FUNC( fexp ),
                         hdlr );

    /* install the things an interpreted function needs                    */
    NLOC_FUNC( func ) = NLOC_FUNC( fexp );
    BODY_FUNC( func ) = BODY_FUNC( fexp );
    ENVI_FUNC( func ) = TLS(CurrLVars);
    /* the 'CHANGED_BAG(TLS(CurrLVars))' is needed because it is delayed        */
    CHANGED_BAG( TLS(CurrLVars) );
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
*F  PrintFuncExpr(<expr>) . . . . . . . . . . . . print a function expression
**
**  'PrintFuncExpr' prints a function expression.
*/
void            PrintFuncExpr (
    Expr                expr )
{
    Obj                 fexs;           /* func. expr. list of curr. func. */
    Obj                 fexp;           /* function expression bag         */

    /* get the function expression bag                                     */
    fexs = FEXS_FUNC( CURR_FUNC );
    fexp = ELM_PLIST( fexs, (Int)(ADDR_EXPR(expr)[0]) );
    PrintFunction( fexp );
    /* Pr("function ... end",0L,0L); */
}


/****************************************************************************
**
*F  PrintProccall(<call>) . . . . . . . . . . . . . .  print a procedure call
**
**  'PrintProccall' prints a procedure call.
*/
extern  void            PrintFunccall (
            Expr                call );

extern  void            PrintFunccallOpts (
            Expr                call );

void            PrintProccall (
    Stat                call )
{
    PrintFunccall( call );
    Pr( ";", 0L, 0L );
}

void            PrintProccallOpts (
    Stat                call )
{
    PrintFunccallOpts( call );
    Pr( ";", 0L, 0L );
}


/****************************************************************************
**
*F  PrintFunccall(<call>) . . . . . . . . . . . . . . . print a function call
**
**  'PrintFunccall' prints a function call.
*/
static void            PrintFunccall1 (
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

    return;
    
}

void            PrintFunccall (
    Expr                call )
{
  PrintFunccall1( call );
  
  /* print the closing parenthesis                                       */
  Pr(" %2<)",0L,0L);
}


void             PrintFunccallOpts (
    Expr                call )
{
  PrintFunccall1( ADDR_STAT( call )[1]);
  Pr(" :%2> ", 0L, 0L);
  PrintRecExpr1 ( ADDR_STAT( call )[0]);
  Pr(" %4<)",0L,0L);
}

  

/****************************************************************************
**
*F  ExecBegin() . . . . . . . . . . . . . . . . . . . . .  begin an execution
*F  ExecEnd(<error>)  . . . . . . . . . . . . . . . . . . .  end an execution
*/
/* TL: Obj             ExecState; */

void            ExecBegin ( Obj frame )
{
    Obj                 execState;      /* old execution state             */

    /* remember the old execution state                                    */
    execState = NewBag( T_PLIST, 4*sizeof(Obj) );
    ADDR_OBJ(execState)[0] = (Obj)3;
    ADDR_OBJ(execState)[1] = TLS(ExecState);
    ADDR_OBJ(execState)[2] = TLS(CurrLVars);
    /* the 'CHANGED_BAG(TLS(CurrLVars))' is needed because it is delayed        */
    CHANGED_BAG( TLS(CurrLVars) );
    ADDR_OBJ(execState)[3] = INTOBJ_INT((Int)TLS(CurrStat));
    TLS(ExecState) = execState;

    /* set up new state                                                    */
    SWITCH_TO_OLD_LVARS( frame );
    SET_BRK_CURR_STAT( 0 );
}

void            ExecEnd (
    UInt                error )
{
    /* if everything went fine                                             */
    if ( ! error ) {

        /* the state must be primal again                                  */
        assert( TLS(CurrStat)  == 0 );

    }

    /* switch back to the old state                                    */
    SET_BRK_CURR_STAT( (Stat)INT_INTOBJ((ADDR_OBJ(TLS(ExecState))[3]) ));
    SWITCH_TO_OLD_LVARS( ADDR_OBJ(TLS(ExecState))[2] );
    TLS(ExecState) = ADDR_OBJ(TLS(ExecState))[1];
}

/****************************************************************************
**
*F  FuncSetRecursionTrapInterval( <self>, <interval> )
**
*/

Obj FuncSetRecursionTrapInterval( Obj self,  Obj interval )
{
  while (!IS_INTOBJ(interval) || INT_INTOBJ(interval) < 0)
    interval = ErrorReturnObj( "SetRecursionTrapInterval( <interval> ): "
                               "<interval> must be a non-negative small integer",
                               0L, 0L, 
                               "you can replace <interval> via 'return <interval>;'");
  RecursionTrapInterval = INT_INTOBJ( interval);
  return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "SetRecursionTrapInterval", 1, "interval",
      FuncSetRecursionTrapInterval, "src/funcs.c:SetRecursionTrapInterval" },

    { 0 }

};

/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );


    /* return success                                                      */
    return 0;
}


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    RecursionTrapInterval = 5000;
    InitCopyGVar("STEVES_TRACING", &STEVES_TRACING);
  
    /* make the global variable known to Gasman                            */
    InitGlobalBag( &TLS(ExecState), "src/funcs.c:ExecState" );

    /* Register the handler for our exported function                      */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* Import some functions from the library                              */
    ImportFuncFromLibrary( "PushOptions", &PushOptions );
    ImportFuncFromLibrary( "PopOptions",  &PopOptions  );

    /* use short cookies to save space in saved workspace                  */
    InitHandlerFunc( DoExecFunc0args, "i0");
    InitHandlerFunc( DoExecFunc1args, "i1");
    InitHandlerFunc( DoExecFunc2args, "i2");
    InitHandlerFunc( DoExecFunc3args, "i3");
    InitHandlerFunc( DoExecFunc4args, "i4");
    InitHandlerFunc( DoExecFunc5args, "i5");
    InitHandlerFunc( DoExecFunc6args, "i6");
    InitHandlerFunc( DoExecFuncXargs, "iX");
    InitHandlerFunc( DoPartialUnWrapFunc, "pUW");

    /* install the evaluators and executors                                */
    InstallExecStatFunc( T_PROCCALL_0ARGS , ExecProccall0args);
    InstallExecStatFunc( T_PROCCALL_1ARGS , ExecProccall1args);
    InstallExecStatFunc( T_PROCCALL_2ARGS , ExecProccall2args);
    InstallExecStatFunc( T_PROCCALL_3ARGS , ExecProccall3args);
    InstallExecStatFunc( T_PROCCALL_4ARGS , ExecProccall4args);
    InstallExecStatFunc( T_PROCCALL_5ARGS , ExecProccall5args);
    InstallExecStatFunc( T_PROCCALL_6ARGS , ExecProccall6args);
    InstallExecStatFunc( T_PROCCALL_XARGS , ExecProccallXargs);
    InstallExecStatFunc( T_PROCCALL_OPTS  , ExecProccallOpts);

    InstallEvalExprFunc( T_FUNCCALL_0ARGS , EvalFunccall0args);
    InstallEvalExprFunc( T_FUNCCALL_1ARGS , EvalFunccall1args);
    InstallEvalExprFunc( T_FUNCCALL_2ARGS , EvalFunccall2args);
    InstallEvalExprFunc( T_FUNCCALL_3ARGS , EvalFunccall3args);
    InstallEvalExprFunc( T_FUNCCALL_4ARGS , EvalFunccall4args);
    InstallEvalExprFunc( T_FUNCCALL_5ARGS , EvalFunccall5args);
    InstallEvalExprFunc( T_FUNCCALL_6ARGS , EvalFunccall6args);
    InstallEvalExprFunc( T_FUNCCALL_XARGS , EvalFunccallXargs);
    InstallEvalExprFunc( T_FUNCCALL_OPTS  , EvalFunccallOpts);
    InstallEvalExprFunc( T_FUNC_EXPR      , EvalFuncExpr);

    /* install the printers                                                */
    InstallPrintStatFunc( T_PROCCALL_0ARGS , PrintProccall);
    InstallPrintStatFunc( T_PROCCALL_1ARGS , PrintProccall);
    InstallPrintStatFunc( T_PROCCALL_2ARGS , PrintProccall);
    InstallPrintStatFunc( T_PROCCALL_3ARGS , PrintProccall);
    InstallPrintStatFunc( T_PROCCALL_4ARGS , PrintProccall);
    InstallPrintStatFunc( T_PROCCALL_5ARGS , PrintProccall);
    InstallPrintStatFunc( T_PROCCALL_6ARGS , PrintProccall);
    InstallPrintStatFunc( T_PROCCALL_XARGS , PrintProccall);
    InstallPrintStatFunc( T_PROCCALL_OPTS  , PrintProccallOpts);
    InstallPrintExprFunc( T_FUNCCALL_0ARGS , PrintFunccall);
    InstallPrintExprFunc( T_FUNCCALL_1ARGS , PrintFunccall);
    InstallPrintExprFunc( T_FUNCCALL_2ARGS , PrintFunccall);
    InstallPrintExprFunc( T_FUNCCALL_3ARGS , PrintFunccall);
    InstallPrintExprFunc( T_FUNCCALL_4ARGS , PrintFunccall);
    InstallPrintExprFunc( T_FUNCCALL_5ARGS , PrintFunccall);
    InstallPrintExprFunc( T_FUNCCALL_6ARGS , PrintFunccall);
    InstallPrintExprFunc( T_FUNCCALL_XARGS , PrintFunccall);
    InstallPrintExprFunc( T_FUNCCALL_OPTS  , PrintFunccallOpts);
    InstallPrintExprFunc( T_FUNC_EXPR      , PrintFuncExpr);

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoFuncs() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "funcs",                            /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoFuncs ( void )
{
    return &module;
}


/****************************************************************************
**

*E  funcs.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
