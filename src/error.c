/****************************************************************************
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002-2018 The GAP Group
**
**  This file declares functions for raising user errors and interacting
**  with the break loop.
**
*/

#include <src/error.h>

#include <src/bool.h>
#include <src/code.h>
#include <src/exprs.h>
#include <src/funcs.h>
#include <src/gapstate.h>
#include <src/gaputils.h>
#include <src/io.h>
#include <src/lists.h>
#include <src/modules.h>
#include <src/plist.h>
#include <src/precord.h>
#include <src/records.h>
#include <src/stats.h>
#include <src/stringobj.h>
#include <src/vars.h>

#ifdef HPCGAP
#include <src/hpc/thread.h>
#endif

#include <stdio.h>


static Obj ErrorInner;


/****************************************************************************
**
*F * * * * * * * * * * * * * * error functions * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncDownEnv( <self>, <level> )  . . . . . . . . .  change the environment
*/

void DownEnvInner(Int depth)
{
    /* if we are asked to go up ... */
    if (depth < 0) {
        /* ... we determine which level we are supposed to end up on ... */
        depth = STATE(ErrorLLevel) + depth;
        if (depth < 0) {
            depth = 0;
        }
        /* ... then go back to the top, and later go down to the appropriate
         * level. */
        STATE(ErrorLVars) = STATE(BaseShellContext);
        STATE(ErrorLLevel) = 0;
        STATE(ShellContext) = STATE(BaseShellContext);
    }

    /* now go down */
    while (0 < depth && STATE(ErrorLVars) != STATE(BottomLVars) &&
           PARENT_LVARS(STATE(ErrorLVars)) != STATE(BottomLVars)) {
        STATE(ErrorLVars) = PARENT_LVARS(STATE(ErrorLVars));
        STATE(ErrorLLevel)++;
        STATE(ShellContext) = PARENT_LVARS(STATE(ShellContext));
        depth--;
    }
}

Obj FuncDownEnv(Obj self, Obj args)
{
    Int depth;

    if (LEN_PLIST(args) == 0) {
        depth = 1;
    }
    else if (LEN_PLIST(args) == 1 && IS_INTOBJ(ELM_PLIST(args, 1))) {
        depth = INT_INTOBJ(ELM_PLIST(args, 1));
    }
    else {
        ErrorQuit("usage: DownEnv( [ <depth> ] )", 0L, 0L);
    }
    if (STATE(ErrorLVars) == STATE(BottomLVars)) {
        Pr("not in any function\n", 0L, 0L);
        return (Obj)0;
    }

    DownEnvInner(depth);
    return (Obj)0;
}

Obj FuncUpEnv(Obj self, Obj args)
{
    Int depth;
    if (LEN_PLIST(args) == 0) {
        depth = 1;
    }
    else if (LEN_PLIST(args) == 1 && IS_INTOBJ(ELM_PLIST(args, 1))) {
        depth = INT_INTOBJ(ELM_PLIST(args, 1));
    }
    else {
        ErrorQuit("usage: UpEnv( [ <depth> ] )", 0L, 0L);
    }
    if (STATE(ErrorLVars) == STATE(BottomLVars)) {
        Pr("not in any function\n", 0L, 0L);
        return (Obj)0;
    }

    DownEnvInner(-depth);
    return (Obj)0;
}

Obj FuncCURRENT_STATEMENT_LOCATION(Obj self, Obj context)
{
    if (context == STATE(BottomLVars))
        return Fail;

    Obj func = FUNC_LVARS(context);
    GAP_ASSERT(func);
    Stat call = STAT_LVARS(context);
    if (IsKernelFunction(func)) {
        return Fail;
    }
    Obj body = BODY_FUNC(func);
    if (call < OFFSET_FIRST_STAT ||
        call > SIZE_BAG(body) - sizeof(StatHeader)) {
        return Fail;
    }

    Obj currLVars = STATE(CurrLVars);
    SWITCH_TO_OLD_LVARS(context);
    GAP_ASSERT(call == BRK_CALL_TO());

    Obj retlist = Fail;
    Int type = TNUM_STAT(call);
    if ((FIRST_STAT_TNUM <= type && type <= LAST_STAT_TNUM) ||
        (FIRST_EXPR_TNUM <= type && type <= LAST_EXPR_TNUM)) {
        Int line = LINE_STAT(call);
        Obj filename = GET_FILENAME_BODY(body);
        retlist = NEW_PLIST(T_PLIST, 2);
        SET_LEN_PLIST(retlist, 2);
        SET_ELM_PLIST(retlist, 1, filename);
        SET_ELM_PLIST(retlist, 2, INTOBJ_INT(line));
        CHANGED_BAG(retlist);
    }
    SWITCH_TO_OLD_LVARS(currLVars);
    return retlist;
}

Obj FuncPRINT_CURRENT_STATEMENT(Obj self, Obj context)
{
    if (context == STATE(BottomLVars))
        return 0;

    Obj func = FUNC_LVARS(context);
    GAP_ASSERT(func);
    Stat call = STAT_LVARS(context);
    if (IsKernelFunction(func)) {
        Pr("<compiled statement> ", 0L, 0L);
        return 0;
    }
    Obj body = BODY_FUNC(func);
    if (call < OFFSET_FIRST_STAT ||
        call > SIZE_BAG(body) - sizeof(StatHeader)) {
        Pr("<corrupted statement> ", 0L, 0L);
        return 0;
    }

    Obj currLVars = STATE(CurrLVars);
    SWITCH_TO_OLD_LVARS(context);
    GAP_ASSERT(call == BRK_CALL_TO());

    Int type = TNUM_STAT(call);
    Obj filename = GET_FILENAME_BODY(body);
    if (FIRST_STAT_TNUM <= type && type <= LAST_STAT_TNUM) {
        PrintStat(call);
        Pr(" at %s:%d", (UInt)CSTR_STRING(filename), LINE_STAT(call));
    }
    else if (FIRST_EXPR_TNUM <= type && type <= LAST_EXPR_TNUM) {
        PrintExpr(call);
        Pr(" at %s:%d", (UInt)CSTR_STRING(filename), LINE_STAT(call));
    }
    SWITCH_TO_OLD_LVARS(currLVars);
    return 0;
}

/****************************************************************************
**
*F  FuncCALL_WITH_CATCH( <self>, <func> )
**
*/
Obj FuncCALL_WITH_CATCH(Obj self, Obj func, volatile Obj args)
{
    volatile syJmp_buf readJmpError;
    volatile Obj       res;
    volatile Obj       currLVars;
    volatile Obj       tilde;
    volatile Int       recursionDepth;
    volatile Stat      currStat;

    if (!IS_FUNC(func))
        ErrorMayQuit(
            "CALL_WITH_CATCH(<func>, <args>): <func> must be a function", 0,
            0);
    if (!IS_LIST(args))
        ErrorMayQuit("CALL_WITH_CATCH(<func>, <args>): <args> must be a list",
                     0, 0);
#ifdef HPCGAP
    if (!IS_PLIST(args)) {
        args = SHALLOW_COPY_OBJ(args);
        PLAIN_LIST(args);
    }
#endif

    memcpy((void *)&readJmpError, (void *)&STATE(ReadJmpError),
           sizeof(syJmp_buf));
    currLVars = STATE(CurrLVars);
    currStat = STATE(CurrStat);
    recursionDepth = GetRecursionDepth();
    tilde = STATE(Tilde);
    res = NEW_PLIST_IMM(T_PLIST_DENSE, 2);
#ifdef HPCGAP
    int      lockSP = RegionLockSP();
    Region * savedRegion = TLS(currentRegion);
#endif
    if (sySetjmp(STATE(ReadJmpError))) {
        SET_LEN_PLIST(res, 2);
        SET_ELM_PLIST(res, 1, False);
        SET_ELM_PLIST(res, 2, STATE(ThrownObject));
        CHANGED_BAG(res);
        STATE(ThrownObject) = 0;
        SET_CURR_LVARS(currLVars);
        STATE(CurrStat) = currStat;
        SetRecursionDepth(recursionDepth);
#ifdef HPCGAP
        STATE(Tilde) = tilde;
        PopRegionLocks(lockSP);
        TLS(currentRegion) = savedRegion;
        if (TLS(CurrentHashLock))
            HashUnlock(TLS(CurrentHashLock));
#else
        STATE(Tilde) = tilde;
#endif
    }
    else {
        Obj result = CallFuncList(func, args);
#ifdef HPCGAP
        /* There should be no locks to pop off the stack, but better safe than
         * sorry. */
        PopRegionLocks(lockSP);
        TLS(currentRegion) = savedRegion;
#endif
        SET_ELM_PLIST(res, 1, True);
        if (result) {
            SET_LEN_PLIST(res, 2);
            SET_ELM_PLIST(res, 2, result);
            CHANGED_BAG(res);
        }
        else
            SET_LEN_PLIST(res, 1);
    }
    memcpy((void *)&STATE(ReadJmpError), (void *)&readJmpError,
           sizeof(syJmp_buf));
    return res;
}

Obj FuncJUMP_TO_CATCH(Obj self, Obj payload)
{
    STATE(ThrownObject) = payload;
    if (STATE(JumpToCatchCallback) != 0) {
        (*STATE(JumpToCatchCallback))();
    }
    syLongjmp(&(STATE(ReadJmpError)), 1);
    return 0;
}

Obj FuncSetUserHasQuit(Obj Self, Obj value)
{
    STATE(UserHasQuit) = INT_INTOBJ(value);
    if (STATE(UserHasQuit))
        SetRecursionDepth(0);
    return 0;
}


/****************************************************************************
**
*F RegisterBreakloopObserver( <func> )
**
** Register a function which will be called when the break loop is entered
** and left. Function should take a single Int argument which will be 1 when
** break loop is entered, 0 when leaving.
**
** Note that it is also possible to leave the break loop (or any GAP code)
** by longjmping. This should be tracked with RegisterSyLongjmpObserver.
*/

static intfunc signalBreakFuncList[16];

Int RegisterBreakloopObserver(intfunc func)
{
    Int i;
    for (i = 0; i < ARRAY_SIZE(signalBreakFuncList); ++i) {
        if (signalBreakFuncList[i] == 0) {
            signalBreakFuncList[i] = func;
            return 1;
        }
    }
    return 0;
}

/****************************************************************************
**
*F  ErrorMessageToGAPString( <msg>, <arg1>, <arg2> )
*/

static Obj ErrorMessageToGAPString(const Char * msg, Int arg1, Int arg2)
{
    Char message[1024];
    Obj  Message;
    SPrTo(message, sizeof(message), msg, arg1, arg2);
    message[sizeof(message) - 1] = '\0';
    Message = MakeString(message);
    return Message;
}


Obj CallErrorInner(const Char * msg,
                   Int          arg1,
                   Int          arg2,
                   UInt         justQuit,
                   UInt         mayReturnVoid,
                   UInt         mayReturnObj,
                   Obj          lateMessage,
                   UInt         printThisStatement)
{
    // Must do this before creating any other GAP objects,
    // as one of the args could be a pointer into a Bag.
    Obj EarlyMsg = ErrorMessageToGAPString(msg, arg1, arg2);

    Obj r = NEW_PREC(0);
    Obj l;
    Int i;

#ifdef HPCGAP
    Region * savedRegion = TLS(currentRegion);
    TLS(currentRegion) = TLS(threadRegion);
#endif
    AssPRec(r, RNamName("context"), STATE(CurrLVars));
    AssPRec(r, RNamName("justQuit"), justQuit ? True : False);
    AssPRec(r, RNamName("mayReturnObj"), mayReturnObj ? True : False);
    AssPRec(r, RNamName("mayReturnVoid"), mayReturnVoid ? True : False);
    AssPRec(r, RNamName("printThisStatement"),
            printThisStatement ? True : False);
    AssPRec(r, RNamName("lateMessage"), lateMessage);
    l = NEW_PLIST_IMM(T_PLIST_HOM, 1);
    SET_ELM_PLIST(l, 1, EarlyMsg);
    SET_LEN_PLIST(l, 1);
    SET_BRK_CALL_TO(STATE(CurrStat));
    // Signal functions about entering and leaving break loop
    for (i = 0; i < ARRAY_SIZE(signalBreakFuncList) && signalBreakFuncList[i];
         ++i)
        (signalBreakFuncList[i])(1);
    Obj res = CALL_2ARGS(ErrorInner, r, l);
    for (i = 0; i < ARRAY_SIZE(signalBreakFuncList) && signalBreakFuncList[i];
         ++i)
        (signalBreakFuncList[i])(0);
#ifdef HPCGAP
    TLS(currentRegion) = savedRegion;
#endif
    return res;
}

void ErrorQuit(const Char * msg, Int arg1, Int arg2)
{
    CallErrorInner(msg, arg1, arg2, 1, 0, 0, False, 1);
    FPUTS_TO_STDERR("panic: ErrorQuit must not return\n");
    SyExit(1);
}


/****************************************************************************
**
*F  ErrorQuitBound( <name> )  . . . . . . . . . . . . . . .  unbound variable
*/
void ErrorQuitBound(const Char * name)
{
    ErrorQuit("variable '%s' must have an assigned value", (Int)name, 0L);
}


/****************************************************************************
**
*F  ErrorQuitFuncResult() . . . . . . . . . . . . . . . . must return a value
*/
void ErrorQuitFuncResult(void)
{
    ErrorQuit("function must return a value", 0L, 0L);
}


/****************************************************************************
**
*F  ErrorQuitIntSmall( <obj> )  . . . . . . . . . . . . . not a small integer
*/
void ErrorQuitIntSmall(Obj obj)
{
    ErrorQuit("<obj> must be a small integer (not a %s)", (Int)TNAM_OBJ(obj),
              0L);
}


/****************************************************************************
**
*F  ErrorQuitIntSmallPos( <obj> ) . . . . . . .  not a positive small integer
*/
void ErrorQuitIntSmallPos(Obj obj)
{
    ErrorQuit("<obj> must be a positive small integer (not a %s)",
              (Int)TNAM_OBJ(obj), 0L);
}

/****************************************************************************
**
*F  ErrorQuitIntPos( <obj> ) . . . . . . .  not a positive small integer
*/
void ErrorQuitIntPos(Obj obj)
{
    ErrorQuit("<obj> must be a positive integer (not a %s)",
              (Int)TNAM_OBJ(obj), 0L);
}


/****************************************************************************
**
*F  ErrorQuitBool( <obj> )  . . . . . . . . . . . . . . . . . . not a boolean
*/
void ErrorQuitBool(Obj obj)
{
    ErrorQuit("<obj> must be 'true' or 'false' (not a %s)",
              (Int)TNAM_OBJ(obj), 0L);
}


/****************************************************************************
**
*F  ErrorQuitFunc( <obj> )  . . . . . . . . . . . . . . . . .  not a function
*/
void ErrorQuitFunc(Obj obj)
{
    ErrorQuit("<obj> must be a function (not a %s)", (Int)TNAM_OBJ(obj), 0L);
}


/****************************************************************************
**
*F  ErrorQuitNrArgs( <narg>, <args> ) . . . . . . . wrong number of arguments
*/
void ErrorQuitNrArgs(Int narg, Obj args)
{
    ErrorQuit("Function Calls: number of arguments must be %d (not %d)", narg,
              LEN_PLIST(args));
}

/****************************************************************************
**
*F  ErrorQuitNrAtLeastArgs( <narg>, <args> ) . . . . . . not enough arguments
*/
void ErrorQuitNrAtLeastArgs(Int narg, Obj args)
{
    ErrorQuit(
        "Function Calls: number of arguments must be at least %d (not %d)",
        narg, LEN_PLIST(args));
}

/****************************************************************************
**
*F  ErrorQuitRange3( <first>, <second>, <last> ) . . divisibility
*/
void ErrorQuitRange3(Obj first, Obj second, Obj last)
{
    ErrorQuit("Range expression <last>-<first> must be divisible by "
              "<second>-<first>, not %d %d",
              INT_INTOBJ(last) - INT_INTOBJ(first),
              INT_INTOBJ(second) - INT_INTOBJ(first));
}


/****************************************************************************
**
*F  ErrorReturnObj( <msg>, <arg1>, <arg2>, <msg2> ) . .  print and return obj
*/
Obj ErrorReturnObj(const Char * msg, Int arg1, Int arg2, const Char * msg2)
{
    Obj LateMsg;
    LateMsg = MakeString(msg2);
    return CallErrorInner(msg, arg1, arg2, 0, 0, 1, LateMsg, 1);
}


/****************************************************************************
**
*F  ErrorReturnVoid( <msg>, <arg1>, <arg2>, <msg2> )  . . .  print and return
*/
void ErrorReturnVoid(const Char * msg, Int arg1, Int arg2, const Char * msg2)
{
    Obj LateMsg;
    LateMsg = MakeString(msg2);
    CallErrorInner(msg, arg1, arg2, 0, 1, 0, LateMsg, 1);
    /*    ErrorMode( msg, arg1, arg2, (Obj)0, msg2, 'x' ); */
}

/****************************************************************************
**
*F  ErrorMayQuit( <msg>, <arg1>, <arg2> )  . . .  print and return
*/
void ErrorMayQuit(const Char * msg, Int arg1, Int arg2)
{
    Obj LateMsg = MakeString("type 'quit;' to quit to outer loop");
    CallErrorInner(msg, arg1, arg2, 0, 0, 0, LateMsg, 1);
    FPUTS_TO_STDERR("panic: ErrorMayQuit must not return\n");
    SyExit(1);
}


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(DownEnv, -1, "args"),
    GVAR_FUNC(UpEnv, -1, "args"),

    GVAR_FUNC(CALL_WITH_CATCH, 2, "func, args"),
    GVAR_FUNC(JUMP_TO_CATCH, 1, "payload"),

    GVAR_FUNC(PRINT_CURRENT_STATEMENT, 1, "context"),
    GVAR_FUNC(CURRENT_STATEMENT_LOCATION, 1, "context"),

    GVAR_FUNC(SetUserHasQuit, 1, "value"),

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    // init filters and functions
    InitHdlrFuncsFromTable(GVarFuncs);

    ImportFuncFromLibrary("ErrorInner", &ErrorInner);

    // return success
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    // init filters and functions
    InitGVarFuncsFromTable(GVarFuncs);

    // return success
    return 0;
}


/****************************************************************************
**
*F  InitInfoError() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "error",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoError(void)
{
    return &module;
}
