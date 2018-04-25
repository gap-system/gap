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

#include <src/funcs.h>

#include <src/calls.h>
#include <src/code.h>
#include <src/error.h>
#include <src/exprs.h>
#include <src/gapstate.h>
#include <src/hookintrprtr.h>
#include <src/io.h>
#include <src/lists.h>
#include <src/modules.h>
#include <src/opers.h>
#include <src/plist.h>
#include <src/read.h>
#include <src/stats.h>
#include <src/stringobj.h>
#include <src/vars.h>

#ifdef HPCGAP
#include <src/hpc/guards.h>
#include <src/hpc/thread.h>
#endif

static ModuleStateOffset FuncsStateOffset = -1;

struct FuncsModuleState {
    Int RecursionDepth;
    Obj ExecState;
};

extern inline struct FuncsModuleState *FuncsState(void)
{
    return (struct FuncsModuleState *)StateSlotsAtOffset(FuncsStateOffset);
}

void IncRecursionDepth(void)
{
    FuncsState()->RecursionDepth++;
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
**  'ARGI_CALL(<call>,<i>)'.  It discards the value returned by the function
**  and returns the statement execution status (as per EXEC_STAT, q.v.)
**  resulting from the procedure call, which in fact is always 0.
*/

static ALWAYS_INLINE Obj EvalOrExecCall(Int ignoreResult, UInt nr, Stat call)
{
    Obj func;
    Obj a[6] = { 0 };
    Obj args = 0;
    Obj result;

    // evaluate the function
    if (ignoreResult)
        SET_BRK_CURR_STAT( call );
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
        // the function must have called READ() and the user quit from
        // a break loop inside it
        ReadEvalError();
    }

    if (ignoreResult) {
        return 0;
    }

    while (result == 0) {
        result =
            ErrorReturnObj("Function Calls: <func> must return a value", 0, 0,
                           "you can supply one by 'return <value>;'");
    }
    return result;
}



UInt ExecProccall0args(Stat call)
{
    EvalOrExecCall(1, 0, call);

    // return 0 (to indicate that no leave-statement was executed)
    return 0;
}

UInt ExecProccall1args(Stat call)
{
    EvalOrExecCall(1, 1, call);

    // return 0 (to indicate that no leave-statement was executed)
    return 0;
}

UInt ExecProccall2args(Stat call)
{
    EvalOrExecCall(1, 2, call);

    // return 0 (to indicate that no leave-statement was executed)
    return 0;
}

UInt ExecProccall3args(Stat call)
{
    EvalOrExecCall(1, 3, call);

    // return 0 (to indicate that no leave-statement was executed)
    return 0;
}

UInt ExecProccall4args(Stat call)
{
    EvalOrExecCall(1, 4, call);

    // return 0 (to indicate that no leave-statement was executed)
    return 0;
}

UInt ExecProccall5args(Stat call)
{
    EvalOrExecCall(1, 5, call);

    // return 0 (to indicate that no leave-statement was executed)
    return 0;
}

UInt ExecProccall6args(Stat call)
{
    EvalOrExecCall(1, 6, call);

    // return 0 (to indicate that no leave-statement was executed)
    return 0;
}

UInt ExecProccallXargs(Stat call)
{
    // pass in 7 (instead of NARG_SIZE_CALL(SIZE_STAT(call)))
    // to allow the compiler to perform better optimizations
    // (as we know that the number of arguments is >= 7 here)
    EvalOrExecCall(1, 7, call);

    // return 0 (to indicate that no leave-statement was executed)
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

Obj EvalFunccall0args(Expr call)
{
    return EvalOrExecCall(0, 0, call);
}

Obj EvalFunccall1args(Expr call)
{
    return EvalOrExecCall(0, 1, call);
}

Obj EvalFunccall2args(Expr call)
{
    return EvalOrExecCall(0, 2, call);
}

Obj EvalFunccall3args(Expr call)
{
    return EvalOrExecCall(0, 3, call);
}

Obj EvalFunccall4args(Expr call)
{
    return EvalOrExecCall(0, 4, call);
}

Obj EvalFunccall5args(Expr call)
{
    return EvalOrExecCall(0, 5, call);
}

Obj EvalFunccall6args(Expr call)
{
    return EvalOrExecCall(0, 6, call);
}

Obj EvalFunccallXargs(Expr call)
{
    // pass in 7 (instead of NARG_SIZE_CALL(SIZE_EXPR(call)))
    // to allow the compiler to perform better optimizations
    // (as we know that the number of arguments is >= 7 here)
    return EvalOrExecCall(0, 7, call);
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
**  values bag.  Finally it returns the result from 'STATE(ReturnObjStat)'.
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
        ErrorReturnVoid( "recursion depth trap (%d)",
                         (Int)recursionDepth, 0L,
                         "you may 'return;'" );
        SetRecursionDepth(recursionDepth);
    }
}

#ifdef TRACEFRAMES
Obj STEVES_TRACING;
#endif

#define CHECK_RECURSION_BEFORE \
            CheckRecursionBefore(); \
            HookedLineIntoFunction(func);

#define CHECK_RECURSION_AFTER \
            DecRecursionDepth(); \
            HookedLineOutFunction(func);

#ifdef HPCGAP

#define REMEMBER_LOCKSTACK() \
    int lockSP = TLS(lockStackPointer)

#define CLEAR_LOCK_STACK() \
    if (lockSP != TLS(lockStackPointer)) \
      PopRegionLocks(lockSP)

#else

#define REMEMBER_LOCKSTACK() \
    do { } while (0)

#define CLEAR_LOCK_STACK() \
    do { } while (0)

#endif

static void ExecFuncHelper(void)
{
    OLD_BRK_CURR_STAT   // old executing statement

    // execute the statement sequence
    REM_BRK_CURR_STAT();
    EXEC_STAT( OFFSET_FIRST_STAT );
    RES_BRK_CURR_STAT();
}

static Obj PopReturnObjStat(void)
{
    Obj returnObjStat = STATE(ReturnObjStat);
    STATE(ReturnObjStat) = (Obj)0;
    return returnObjStat;
}

#ifdef HPCGAP

static void LockFuncArgs(Obj func, Int narg, const Obj * args)
{
    Int i;
    int count = 0;
    int *mode = alloca(narg * sizeof(int));
    UChar *locks = CHARS_STRING(LCKS_FUNC(func));
    Obj *objects = alloca(narg * sizeof(Obj));
    for (i=0; i<narg; i++) {
      Obj obj = args[i];
      switch (locks[i]) {
        case 1:
          if (CheckReadAccess(obj))
            break;
          mode[count] = 0;
          objects[count] = obj;
          count++;
          break;
        case 2:
          if (CheckWriteAccess(obj))
            break;
          mode[count] = 1;
          objects[count] = obj;
          count++;
          break;
      }
    }
    if (count && LockObjects(count, objects, mode) < 0)
      ErrorMayQuit("Cannot lock arguments of atomic function", 0L, 0L );
    /* Push at least one region so that we can tell that we are inside
     * an atomic function. */
    if (!count)
      PushRegionLock((Region *) 0);
}

#endif

static ALWAYS_INLINE Obj DoExecFunc(Obj func, Int narg, const Obj *arg, Int isAtomic)
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
#ifdef HPCGAP
    if (isAtomic)
        LockFuncArgs(func, narg, arg);
#else
    (void)isAtomic; // unused
#endif
    CHECK_RECURSION_BEFORE

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, narg, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    for (Int i = 0; i < narg; i++)
        ASS_LVAR( i+1, arg[i] );

    /* execute the statement sequence                                      */
    ExecFuncHelper();
    CLEAR_LOCK_STACK();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
    return PopReturnObjStat();
}

Obj DoExecFunc0args (
    Obj                 func )
{
    return DoExecFunc(func, 0, 0, 0);
}

Obj             DoExecFunc1args (
    Obj                 func,
    Obj                 arg1 )
{
    Obj arg[] = { arg1 };
    return DoExecFunc(func, 1, arg, 0);
}

Obj             DoExecFunc2args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj arg[] = { arg1, arg2 };
    return DoExecFunc(func, 2, arg, 0);
}

Obj             DoExecFunc3args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj arg[] = { arg1, arg2, arg3 };
    return DoExecFunc(func, 3, arg, 0);
}

Obj             DoExecFunc4args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj arg[] = { arg1, arg2, arg3, arg4 };
    return DoExecFunc(func, 4, arg, 0);
}

Obj             DoExecFunc5args (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj arg[] = { arg1, arg2, arg3, arg4, arg5 };
    return DoExecFunc(func, 5, arg, 0);
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
    Obj arg[] = { arg1, arg2, arg3, arg4, arg5, arg6 };
    return DoExecFunc(func, 6, arg, 0);
}

Obj             DoExecFuncXargs (
    Obj                 func,
    Obj                 args )
{
    Bag                 oldLvars;       /* old values bag                  */
    REMEMBER_LOCKSTACK();
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
    ExecFuncHelper();
    CLEAR_LOCK_STACK();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
    return PopReturnObjStat();
}


#ifdef HPCGAP

Obj             DoExecFunc0argsL (
    Obj                 func )
{
    return DoExecFunc(func, 0, 0, 1);
}

Obj             DoExecFunc1argsL (
    Obj                 func,
    Obj                 arg1 )
{
    Obj arg[] = { arg1 };
    return DoExecFunc(func, 1, arg, 1);
}

Obj             DoExecFunc2argsL (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj arg[] = { arg1, arg2 };
    return DoExecFunc(func, 2, arg, 1);
}

Obj             DoExecFunc3argsL (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj arg[] = { arg1, arg2, arg3 };
    return DoExecFunc(func, 3, arg, 1);
}

Obj             DoExecFunc4argsL (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj arg[] = { arg1, arg2, arg3, arg4 };
    return DoExecFunc(func, 4, arg, 1);
}

Obj             DoExecFunc5argsL (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj arg[] = { arg1, arg2, arg3, arg4, arg5 };
    return DoExecFunc(func, 5, arg, 1);
}

Obj             DoExecFunc6argsL (
    Obj                 func,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Obj arg[] = { arg1, arg2, arg3, arg4, arg5, arg6 };
    return DoExecFunc(func, 6, arg, 1);
}

Obj             DoExecFuncXargsL (
    Obj                 func,
    Obj                 args )
{
    Bag                 oldLvars;       /* old values bag                  */
    UInt                len;            /* number of arguments             */
    UInt                i;              /* loop variable                   */
    REMEMBER_LOCKSTACK();

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

    LockFuncArgs(func, len, CONST_ADDR_OBJ(args) + 1);

    /* switch to a new values bag                                          */
    SWITCH_TO_NEW_LVARS( func, len, NLOC_FUNC(func), oldLvars );

    /* enter the arguments                                                 */
    for ( i = 1; i <= len; i++ ) {
        ASS_LVAR( i, ELM_PLIST( args, i ) );
    }

    /* execute the statement sequence                                      */
    ExecFuncHelper();
    CLEAR_LOCK_STACK();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
    return PopReturnObjStat();
}

#endif /* HPCGAP */


Obj DoPartialUnWrapFunc(Obj func, Obj args)
{
    Bag                 oldLvars;       /* old values bag                  */
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
    REMEMBER_LOCKSTACK();
    ExecFuncHelper();
    CLEAR_LOCK_STACK();

    /* switch back to the old values bag                                   */
    SWITCH_TO_OLD_LVARS_AND_FREE( oldLvars );

    CHECK_RECURSION_AFTER

    /* return the result                                                   */
    return PopReturnObjStat();
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
#ifdef HPCGAP
    Obj                 locks;          /* Locks of the function?   */

    locks = LCKS_FUNC(fexp);
    /* select the right handler                                            */
    if (locks) {
        if      ( NARG_FUNC(fexp) ==  0 )  hdlr = DoExecFunc0argsL;
        else if ( NARG_FUNC(fexp) ==  1 )  hdlr = DoExecFunc1argsL;
        else if ( NARG_FUNC(fexp) ==  2 )  hdlr = DoExecFunc2argsL;
        else if ( NARG_FUNC(fexp) ==  3 )  hdlr = DoExecFunc3argsL;
        else if ( NARG_FUNC(fexp) ==  4 )  hdlr = DoExecFunc4argsL;
        else if ( NARG_FUNC(fexp) ==  5 )  hdlr = DoExecFunc5argsL;
        else if ( NARG_FUNC(fexp) ==  6 )  hdlr = DoExecFunc6argsL;
        else if ( NARG_FUNC(fexp) >=  7 )  hdlr = DoExecFuncXargsL;
        else   /* NARG_FUNC(fexp) == -1 */ hdlr = DoExecFunc1argsL;
    } else
#endif
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
    /* the 'CHANGED_BAG(STATE(CurrLVars))' is needed because it is delayed        */
    CHANGED_BAG( STATE(CurrLVars) );
    MakeHighVars(STATE(CurrLVars));
#ifdef HPCGAP
    SET_LCKS_FUNC( func, locks );
#endif
    SET_FEXS_FUNC( func, FEXS_FUNC( fexp ) );

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
    fexs = FEXS_FUNC( CURR_FUNC() );
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
    fexs = FEXS_FUNC( CURR_FUNC() );
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
    execState = NEW_PLIST(T_PLIST, 3);
    SET_LEN_PLIST(execState, 3);
    SET_ELM_PLIST(execState, 1, FuncsState()->ExecState);
    SET_ELM_PLIST(execState, 2, STATE(CurrLVars));
    /* the 'CHANGED_BAG(STATE(CurrLVars))' is needed because it is delayed        */
    CHANGED_BAG( STATE(CurrLVars) );
    SET_ELM_PLIST(execState, 3, INTOBJ_INT((Int)STATE(CurrStat)));
    FuncsState()->ExecState = execState;

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
        assert( STATE(CurrStat)  == 0 );

    }

    /* switch back to the old state                                    */
    SET_BRK_CURR_STAT((Stat)INT_INTOBJ(ELM_PLIST(FuncsState()->ExecState, 3)));
    SWITCH_TO_OLD_LVARS( ELM_PLIST(FuncsState()->ExecState, 2) );
    FuncsState()->ExecState = ELM_PLIST(FuncsState()->ExecState, 1);
}

/****************************************************************************
**
*F  FuncSetRecursionTrapInterval( <self>, <interval> )
**
*/

Obj FuncSetRecursionTrapInterval( Obj self,  Obj interval )
{
    while (!IS_INTOBJ(interval) || INT_INTOBJ(interval) <= 5)
        interval = ErrorReturnObj(
            "SetRecursionTrapInterval( <interval> ): "
            "<interval> must be a small integer greater than 5",
            0L, 0L, "you can replace <interval> via 'return <interval>;'");
    RecursionTrapInterval = INT_INTOBJ(interval);
    return 0;
}

Obj FuncGetRecursionDepth( Obj self )
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

    GVAR_FUNC(SetRecursionTrapInterval, 1, "interval"),
    GVAR_FUNC(GetRecursionDepth, 0, ""),
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
#ifdef TRACEFRAMES
    InitCopyGVar("STEVES_TRACING", &STEVES_TRACING);
#endif

#if !defined(HPCGAP)
    /* make the global variable known to Gasman                            */
    InitGlobalBag( &FuncsState()->ExecState, "src/funcs.c:ExecState" );
#endif

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

#ifdef HPCGAP
    InitHandlerFunc( DoExecFunc1argsL, "i1l");
    InitHandlerFunc( DoExecFunc2argsL, "i2l");
    InitHandlerFunc( DoExecFunc3argsL, "i3l");
    InitHandlerFunc( DoExecFunc4argsL, "i4l");
    InitHandlerFunc( DoExecFunc5argsL, "i5l");
    InitHandlerFunc( DoExecFunc6argsL, "i6l");
    InitHandlerFunc( DoExecFuncXargsL, "iXl");
#endif

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

static void InitModuleState(ModuleStateOffset offset)
{
    FuncsState()->ExecState = 0;
    FuncsState()->RecursionDepth = 0;
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
};

StructInitInfo * InitInfoFuncs ( void )
{
    FuncsStateOffset = RegisterModuleState(sizeof(struct FuncsModuleState), InitModuleState, 0);
    return &module;
}
