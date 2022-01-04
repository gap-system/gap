/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the function interpreter package.
**
**  The function interpreter package   contains the executors  for  procedure
**  calls, the  evaluators  for function calls,  the   evaluator for function
**  expressions, and the handlers for the execution of function bodies.
**
**  It uses the function call mechanism defined by the calls package.
*/

#include "funcs.h"

#include "calls.h"
#include "code.h"
#include "error.h"
#include "exprs.h"
#include "gapstate.h"
#include "hookintrprtr.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "stats.h"
#include "stringobj.h"
#include "trycatch.h"
#include "vars.h"

#ifdef HPCGAP
#include "hpc/guards.h"
#include "hpc/thread.h"
#endif

#include <stdlib.h>


static ModuleStateOffset FuncsStateOffset = -1;

struct FuncsModuleState {
    Int RecursionDepth;
};

extern inline struct FuncsModuleState *FuncsState(void)
{
    return (struct FuncsModuleState *)StateSlotsAtOffset(FuncsStateOffset);
}

Int IncRecursionDepth(void)
{
    int depth = ++(FuncsState()->RecursionDepth);
    return depth;
}

void DecRecursionDepth(void)
{
    FuncsState()->RecursionDepth--;
    /* FIXME: According to a comment in the function
              RecursionDepthTrap below, RecursionDepth
              can become "slightly" negative. This
              needs some investigation.
    GAP_ASSERT(FuncsState()->RecursionDepth >= 0);
    */
}

Int GetRecursionDepth(void)
{
    return FuncsState()->RecursionDepth;
}

void SetRecursionDepth(Int depth)
{
    GAP_ASSERT(depth >= 0);
    FuncsState()->RecursionDepth = depth;
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
**  'ARGI_CALL(<call>,<i>)'.  It discards the value returned by the function
**  and returns the statement execution status (as per EXEC_STAT, q.v.)
**  resulting from the procedure call, which in fact is always 0.
*/

static Obj PushOptions;
static Obj PopOptions;

static ALWAYS_INLINE Obj EvalOrExecCall(Int ignoreResult, UInt nr, Stat call, Stat opts)
{
    Obj func;
    Obj a[6] = { 0 };
    Obj args = 0;
    Obj result;

    // evaluate the function
    func = EVAL_EXPR( FUNC_CALL( call ) );

    // evaluate the arguments
    if (nr <= 6 && TNUM_OBJ(func) == T_FUNCTION) {
        for (UInt i = 1; i <= nr; i++) {
            a[i - 1] = EVAL_EXPR(ARGI_CALL(call, i));
        }
    }
    else {
        UInt realNr = NARG_SIZE_CALL(SIZE_STAT(call));
        args = NEW_PLIST(T_PLIST, realNr);
        SET_LEN_PLIST(args, realNr);
        for (UInt i = 1; i <= realNr; i++) {
            Obj argi = EVAL_EXPR(ARGI_CALL(call, i));
            SET_ELM_PLIST(args, i, argi);
            CHANGED_BAG(args);
        }
    }

    if (opts) {
        CALL_1ARGS(PushOptions, EVAL_EXPR(opts));
    }

    // call the function
    SET_BRK_CALL_TO( call );
    if (TNUM_OBJ(func) != T_FUNCTION) {
        result = DoOperation2Args(CallFuncListOper, func, args);
    }
    else {
        switch (nr) {
        case 0:
            result = CALL_0ARGS(func);
            break;
        case 1:
            result = CALL_1ARGS(func, a[0]);
            break;
        case 2:
            result = CALL_2ARGS(func, a[0], a[1]);
            break;
        case 3:
            result = CALL_3ARGS(func, a[0], a[1], a[2]);
            break;
        case 4:
            result = CALL_4ARGS(func, a[0], a[1], a[2], a[3]);
            break;
        case 5:
            result = CALL_5ARGS(func, a[0], a[1], a[2], a[3], a[4]);
            break;
        case 6:
            result = CALL_6ARGS(func, a[0], a[1], a[2], a[3], a[4], a[5]);
            break;
        default:
            result = CALL_XARGS(func, args);
        }
    }
    if (STATE(UserHasQuit) || STATE(UserHasQUIT)) {
        // the function must have called READ() and the user quit from a break loop
        // inside it; or a file containing a `QUIT` statement was read at the top
        // execution level (e.g. in init.g, before the primary REPL starts) after
        // which the function was called, and now we are returning from that
        GAP_THROW();
    }

    if (!ignoreResult && result == 0) {
        ErrorMayQuit("Function Calls: <func> must return a value", 0, 0);
    }

    if (opts) {
        CALL_0ARGS(PopOptions);
    }

    return result;
}


/****************************************************************************
**
*F  ExecProccallOpts( <call> ). . execute a procedure call with options
**
**  Calls with options are wrapped in an outer statement, which is
**  handled here
*/

static ExecStatus ExecProccallOpts(Stat call)
{
    Expr opts = READ_STAT(call, 0);
    Expr real_call = READ_STAT(call, 1);
    UInt type = TNUM_STAT(real_call);
    GAP_ASSERT(/*STAT_PROCCALL_0ARGS <= type && */type <= STAT_PROCCALL_XARGS);
    UInt narg = (type - STAT_PROCCALL_0ARGS);

    EvalOrExecCall(1, narg, real_call, opts);

    return STATUS_END;
}


static ExecStatus ExecProccall0args(Stat call)
{
    EvalOrExecCall(1, 0, call, 0);
    return STATUS_END;
}

static ExecStatus ExecProccall1args(Stat call)
{
    EvalOrExecCall(1, 1, call, 0);
    return STATUS_END;
}

static ExecStatus ExecProccall2args(Stat call)
{
    EvalOrExecCall(1, 2, call, 0);
    return STATUS_END;
}

static ExecStatus ExecProccall3args(Stat call)
{
    EvalOrExecCall(1, 3, call, 0);
    return STATUS_END;
}

static ExecStatus ExecProccall4args(Stat call)
{
    EvalOrExecCall(1, 4, call, 0);
    return STATUS_END;
}

static ExecStatus ExecProccall5args(Stat call)
{
    EvalOrExecCall(1, 5, call, 0);
    return STATUS_END;
}

static ExecStatus ExecProccall6args(Stat call)
{
    EvalOrExecCall(1, 6, call, 0);
    return STATUS_END;
}

static ExecStatus ExecProccallXargs(Stat call)
{
    // pass in 7 (instead of NARG_SIZE_CALL(SIZE_STAT(call)))
    // to allow the compiler to perform better optimizations
    // (as we know that the number of arguments is >= 7 here)
    EvalOrExecCall(1, 7, call, 0);
    return STATUS_END;
}

/****************************************************************************
**
*F  EvalFunccallOpts( <call> ). . evaluate a function call with options
**
**  Calls with options are wrapped in an outer statement, which is
**  handled here
*/

static Obj EvalFunccallOpts(Expr call)
{
    Expr opts = READ_STAT(call, 0);
    Expr real_call = READ_STAT(call, 1);
    UInt type = TNUM_STAT(real_call);
    GAP_ASSERT(EXPR_FUNCCALL_0ARGS <= type && type <= EXPR_FUNCCALL_XARGS);
    UInt narg = (type - EXPR_FUNCCALL_0ARGS);
    return EvalOrExecCall(0, narg, real_call, opts);
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

static Obj EvalFunccall0args(Expr call)
{
    return EvalOrExecCall(0, 0, call, 0);
}

static Obj EvalFunccall1args(Expr call)
{
    return EvalOrExecCall(0, 1, call, 0);
}

static Obj EvalFunccall2args(Expr call)
{
    return EvalOrExecCall(0, 2, call, 0);
}

static Obj EvalFunccall3args(Expr call)
{
    return EvalOrExecCall(0, 3, call, 0);
}

static Obj EvalFunccall4args(Expr call)
{
    return EvalOrExecCall(0, 4, call, 0);
}

static Obj EvalFunccall5args(Expr call)
{
    return EvalOrExecCall(0, 5, call, 0);
}

static Obj EvalFunccall6args(Expr call)
{
    return EvalOrExecCall(0, 6, call, 0);
}

static Obj EvalFunccallXargs(Expr call)
{
    // pass in 7 (instead of NARG_SIZE_CALL(SIZE_EXPR(call)))
    // to allow the compiler to perform better optimizations
    // (as we know that the number of arguments is >= 7 here)
    return EvalOrExecCall(0, 7, call, 0);
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
**  values bag.
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
    if (GetRecursionDepth() > 0) {
        recursionDepth = GetRecursionDepth();
        SetRecursionDepth(0);
        ErrorReturnVoid("recursion depth trap (%d)", (Int)recursionDepth, 0,
                        "you may 'return;'");
        SetRecursionDepth(recursionDepth);
    }
}

#define CHECK_RECURSION_BEFORE \
            HookedLineIntoFunction(func); \
            CheckRecursionBefore();

#define CHECK_RECURSION_AFTER \
            DecRecursionDepth(); \
            HookedLineOutFunction(func);

#ifdef HPCGAP

#define REMEMBER_LOCKSTACK() \
    int lockSP = TLS(lockStackPointer)

#define CLEAR_LOCK_STACK() \
    if (lockSP != TLS(lockStackPointer)) \
      PopRegionLocks(lockSP)

#endif

#ifdef HPCGAP

static void LockFuncArgs(Obj func, Int narg, const Obj * args)
{
    Int i;
    int count = 0;
    LockMode * mode = alloca(narg * sizeof(int));
    UChar *locks = CHARS_STRING(LCKS_FUNC(func));
    Obj *objects = alloca(narg * sizeof(Obj));
    for (i=0; i<narg; i++) {
      Obj obj = args[i];
      switch (locks[i]) {
      case LOCK_QUAL_READONLY:
          if (CheckReadAccess(obj))
            break;
          mode[count] = LOCK_MODE_READONLY;
          objects[count] = obj;
          count++;
          break;
      case LOCK_QUAL_READWRITE:
          if (CheckWriteAccess(obj))
            break;
          mode[count] = LOCK_MODE_READWRITE;
          objects[count] = obj;
          count++;
          break;
      }
    }
    if (count && LockObjects(count, objects, mode) < 0)
      ErrorMayQuit("Cannot lock arguments of atomic function", 0, 0);
    /* Push at least one region so that we can tell that we are inside
     * an atomic function. */
    if (!count)
      PushRegionLock((Region *) 0);
}

#endif

static ALWAYS_INLINE Obj DoExecFunc(Obj func, Int narg, const Obj *arg)
{
    Bag oldLvars; /* old values bag */
    Obj result;
    CHECK_RECURSION_BEFORE

#ifdef HPCGAP
    REMEMBER_LOCKSTACK();
    if (LCKS_FUNC(func))
        LockFuncArgs(func, narg, arg);
#endif

    /* switch to a new values bag                                          */
    oldLvars = SWITCH_TO_NEW_LVARS(func, narg, NLOC_FUNC(func));

    /* enter the arguments                                                 */
    for (Int i = 0; i < narg; i++)
        ASS_LVAR( i+1, arg[i] );

    /* execute the statement sequence                                      */
    result = EXEC_CURR_FUNC();
#ifdef HPCGAP
    CLEAR_LOCK_STACK();
#endif

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    return result;
}

static Obj DoExecFunc0args(Obj func)
{
    return DoExecFunc(func, 0, 0);
}

static Obj DoExecFunc1args(Obj func, Obj a1)
{
    Obj arg[] = { a1 };
    return DoExecFunc(func, 1, arg);
}

static Obj DoExecFunc2args(Obj func, Obj a1, Obj a2)
{
    Obj arg[] = { a1, a2 };
    return DoExecFunc(func, 2, arg);
}

static Obj DoExecFunc3args(Obj func, Obj a1, Obj a2, Obj a3)
{
    Obj arg[] = { a1, a2, a3 };
    return DoExecFunc(func, 3, arg);
}

static Obj DoExecFunc4args(Obj func, Obj a1, Obj a2, Obj a3, Obj a4)
{
    Obj arg[] = { a1, a2, a3, a4 };
    return DoExecFunc(func, 4, arg);
}

static Obj DoExecFunc5args(Obj func, Obj a1, Obj a2, Obj a3, Obj a4, Obj a5)
{
    Obj arg[] = { a1, a2, a3, a4, a5 };
    return DoExecFunc(func, 5, arg);
}

static Obj DoExecFunc6args(Obj func, Obj a1, Obj a2, Obj a3, Obj a4, Obj a5, Obj a6)
{
    Obj arg[] = { a1, a2, a3, a4, a5, a6 };
    return DoExecFunc(func, 6, arg);
}

static Obj DoExecFuncXargs(Obj func, Obj args)
{
    Bag  oldLvars; /* old values bag */
    UInt len;      /* number of arguments */
    UInt i;        /* loop variable */
    Obj  result;

    CHECK_RECURSION_BEFORE

    /* check the number of arguments                                       */
    len = NARG_FUNC( func );
    if (len != LEN_PLIST(args)) {
        ErrorMayQuitNrArgs(len, LEN_PLIST(args));
    }

#ifdef HPCGAP
    REMEMBER_LOCKSTACK();
    if (LCKS_FUNC(func))
        LockFuncArgs(func, len, CONST_ADDR_OBJ(args) + 1);
#endif

    /* switch to a new values bag                                          */
    oldLvars = SWITCH_TO_NEW_LVARS(func, len, NLOC_FUNC(func));

    /* enter the arguments                                                 */
    for ( i = 1; i <= len; i++ ) {
        ASS_LVAR( i, ELM_PLIST( args, i ) );
    }

    /* execute the statement sequence                                      */
    result = EXEC_CURR_FUNC();
#ifdef HPCGAP
    CLEAR_LOCK_STACK();
#endif

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    return result;
}


static Obj DoPartialUnWrapFunc(Obj func, Obj args)
{
    Bag  oldLvars; /* old values bag */
    UInt named;    /* number of arguments */
    UInt i;        /* loop variable */
    UInt len;
    Obj  result;

    CHECK_RECURSION_BEFORE

    named = ((UInt)-NARG_FUNC(func))-1;
    len = LEN_PLIST(args);

    if (named > len) { /* Can happen for > 6 arguments */
        ErrorMayQuitNrAtLeastArgs(named, len);
    }

#ifdef HPCGAP
    REMEMBER_LOCKSTACK();
    if (LCKS_FUNC(func))
        LockFuncArgs(func, len, CONST_ADDR_OBJ(args) + 1);
#endif

    /* switch to a new values bag                                          */
    oldLvars = SWITCH_TO_NEW_LVARS(func, named + 1, NLOC_FUNC(func));

    /* enter the arguments                                                 */
    for (i = 1; i <= named; i++) {
      ASS_LVAR(i, ELM_PLIST(args,i));
    }
    for (i = named+1; i <= len; i++) {
      SET_ELM_PLIST(args, i-named, ELM_PLIST(args,i));
    }
    SET_LEN_PLIST(args, len-named);
    ASS_LVAR(named+1, args);

    /* execute the statement sequence                                      */
    result = EXEC_CURR_FUNC();
#ifdef HPCGAP
    CLEAR_LOCK_STACK();
#endif

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    return result;
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
    func = NewFunction( NAME_FUNC( fexp ),
                        NARG_FUNC( fexp ), NAMS_FUNC( fexp ),
                        hdlr );

    /* install the things an interpreted function needs                    */
    SET_NLOC_FUNC( func, NLOC_FUNC( fexp ) );
    SET_BODY_FUNC( func, BODY_FUNC( fexp ) );
    SET_ENVI_FUNC( func, STATE(CurrLVars) );
    MakeHighVars(STATE(CurrLVars));
#ifdef HPCGAP
    SET_LCKS_FUNC( func, LCKS_FUNC( fexp ) );
#endif

    /* return the function                                                 */
    return func;
}


/****************************************************************************
**
*F  EvalFuncExpr(<expr>)  . . .  evaluate a function expression to a function
**
**  'EvalFuncExpr' evaluates the function expression <expr> to a function.
*/
static Obj EvalFuncExpr(Expr expr)
{
    /* get the function expression bag                                     */
    Obj fexp = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 0));

    /* and make the function                                               */
    return MakeFunction( fexp );
}


/****************************************************************************
**
*F  PrintFuncExpr(<expr>) . . . . . . . . . . . . print a function expression
**
**  'PrintFuncExpr' prints a function expression.
*/
static void PrintFuncExpr(Expr expr)
{
    /* get the function expression bag                                     */
    Obj fexp = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 0));
    PrintObj( fexp );
}


/****************************************************************************
**
*F  PrintProccall(<call>) . . . . . . . . . . . . . .  print a procedure call
**
**  'PrintProccall' prints a procedure call.
*/
static void PrintFunccall(Expr call);

static void PrintFunccallOpts(Expr call);

static void PrintProccall(Stat call)
{
    PrintFunccall( call );
    Pr(";", 0, 0);
}

static void PrintProccallOpts(Stat call)
{
    PrintFunccallOpts( call );
    Pr(";", 0, 0);
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
    Pr("%2>", 0, 0);
    PrintExpr( FUNC_CALL(call) );

    /* print the opening parenthesis                                       */
    Pr("%<( %>", 0, 0);

    /* print the expressions that evaluate to the actual arguments         */
    for ( i = 1; i <= NARG_SIZE_CALL( SIZE_EXPR(call) ); i++ ) {
        PrintExpr( ARGI_CALL(call,i) );
        if ( i != NARG_SIZE_CALL( SIZE_EXPR(call) ) ) {
            Pr("%<, %>", 0, 0);
        }
    }
}

static void PrintFunccall(Expr call)
{
  PrintFunccall1( call );
  
  /* print the closing parenthesis                                       */
  Pr(" %2<)", 0, 0);
}


static void PrintFunccallOpts(Expr call)
{
    PrintFunccall1(READ_STAT(call, 1));
    Pr(" :%2> ", 0, 0);
    PrintRecExpr1(READ_STAT(call, 0));
    Pr(" %4<)", 0, 0);
}


/****************************************************************************
**
*F  FuncSetRecursionTrapInterval( <self>, <interval> )
**
*/

static Obj FuncSetRecursionTrapInterval(Obj self, Obj interval)
{
    if (!IS_INTOBJ(interval) || INT_INTOBJ(interval) <= 5)
        RequireArgument(SELF_NAME, interval,
                        "must be a small integer greater than 5");
    RecursionTrapInterval = INT_INTOBJ(interval);
    return 0;
}

static Obj FuncGetRecursionDepth(Obj self)
{
    return INTOBJ_INT(GetRecursionDepth());
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(SetRecursionTrapInterval, interval),
    GVAR_FUNC_0ARGS(GetRecursionDepth),
    { 0, 0, 0, 0, 0 }


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
    InstallExecStatFunc( STAT_PROCCALL_0ARGS , ExecProccall0args);
    InstallExecStatFunc( STAT_PROCCALL_1ARGS , ExecProccall1args);
    InstallExecStatFunc( STAT_PROCCALL_2ARGS , ExecProccall2args);
    InstallExecStatFunc( STAT_PROCCALL_3ARGS , ExecProccall3args);
    InstallExecStatFunc( STAT_PROCCALL_4ARGS , ExecProccall4args);
    InstallExecStatFunc( STAT_PROCCALL_5ARGS , ExecProccall5args);
    InstallExecStatFunc( STAT_PROCCALL_6ARGS , ExecProccall6args);
    InstallExecStatFunc( STAT_PROCCALL_XARGS , ExecProccallXargs);
    InstallExecStatFunc( STAT_PROCCALL_OPTS  , ExecProccallOpts);

    InstallEvalExprFunc( EXPR_FUNCCALL_0ARGS , EvalFunccall0args);
    InstallEvalExprFunc( EXPR_FUNCCALL_1ARGS , EvalFunccall1args);
    InstallEvalExprFunc( EXPR_FUNCCALL_2ARGS , EvalFunccall2args);
    InstallEvalExprFunc( EXPR_FUNCCALL_3ARGS , EvalFunccall3args);
    InstallEvalExprFunc( EXPR_FUNCCALL_4ARGS , EvalFunccall4args);
    InstallEvalExprFunc( EXPR_FUNCCALL_5ARGS , EvalFunccall5args);
    InstallEvalExprFunc( EXPR_FUNCCALL_6ARGS , EvalFunccall6args);
    InstallEvalExprFunc( EXPR_FUNCCALL_XARGS , EvalFunccallXargs);
    InstallEvalExprFunc( EXPR_FUNCCALL_OPTS  , EvalFunccallOpts);
    InstallEvalExprFunc( EXPR_FUNC      , EvalFuncExpr);

    /* install the printers                                                */
    InstallPrintStatFunc( STAT_PROCCALL_0ARGS , PrintProccall);
    InstallPrintStatFunc( STAT_PROCCALL_1ARGS , PrintProccall);
    InstallPrintStatFunc( STAT_PROCCALL_2ARGS , PrintProccall);
    InstallPrintStatFunc( STAT_PROCCALL_3ARGS , PrintProccall);
    InstallPrintStatFunc( STAT_PROCCALL_4ARGS , PrintProccall);
    InstallPrintStatFunc( STAT_PROCCALL_5ARGS , PrintProccall);
    InstallPrintStatFunc( STAT_PROCCALL_6ARGS , PrintProccall);
    InstallPrintStatFunc( STAT_PROCCALL_XARGS , PrintProccall);
    InstallPrintStatFunc( STAT_PROCCALL_OPTS  , PrintProccallOpts);
    InstallPrintExprFunc( EXPR_FUNCCALL_0ARGS , PrintFunccall);
    InstallPrintExprFunc( EXPR_FUNCCALL_1ARGS , PrintFunccall);
    InstallPrintExprFunc( EXPR_FUNCCALL_2ARGS , PrintFunccall);
    InstallPrintExprFunc( EXPR_FUNCCALL_3ARGS , PrintFunccall);
    InstallPrintExprFunc( EXPR_FUNCCALL_4ARGS , PrintFunccall);
    InstallPrintExprFunc( EXPR_FUNCCALL_5ARGS , PrintFunccall);
    InstallPrintExprFunc( EXPR_FUNCCALL_6ARGS , PrintFunccall);
    InstallPrintExprFunc( EXPR_FUNCCALL_XARGS , PrintFunccall);
    InstallPrintExprFunc( EXPR_FUNCCALL_OPTS  , PrintFunccallOpts);
    InstallPrintExprFunc( EXPR_FUNC      , PrintFuncExpr);

    return 0;
}

static Int InitModuleState(void)
{
    FuncsState()->RecursionDepth = 0;

    return 0;
}

/****************************************************************************
**
*F  InitInfoFuncs() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "funcs",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,

    .moduleStateSize = sizeof(struct FuncsModuleState),
    .moduleStateOffsetPtr = &FuncsStateOffset,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoFuncs ( void )
{
    return &module;
}
