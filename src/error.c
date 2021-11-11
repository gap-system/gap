/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file implements functions for raising user errors and interacting
**  with the break loop.
**
*/

#include "error.h"

#include "bool.h"
#include "code.h"
#include "exprs.h"
#include "funcs.h"
#include "gapstate.h"
#include "gaputils.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "precord.h"
#include "records.h"
#include "stats.h"
#include "stringobj.h"
#include "sysstr.h"
#include "trycatch.h"
#include "vars.h"

#ifdef HPCGAP
#include "hpc/thread.h"
#endif

#include <stdio.h>


static Obj ErrorInner;
static Obj ERROR_OUTPUT = NULL;
static Obj IsOutputStream;


/****************************************************************************
**
*F * * * * * * * * * * * * * * error functions * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  OpenErrorOutput()  . . . . . . . open the file or stream assigned to the
**                                   ERROR_OUTPUT global variable defined in
**                                   error.g, or "*errout*" otherwise
*/
UInt OpenErrorOutput(TypOutputFile * output)
{
    /* Try to print the output to stream. Use *errout* as a fallback. */
    UInt ret = 0;

    if (ERROR_OUTPUT != NULL) {
        if (IsStringConv(ERROR_OUTPUT)) {
            ret = OpenOutput(output, CONST_CSTR_STRING(ERROR_OUTPUT), FALSE);
        }
        else {
            if (CALL_1ARGS(IsOutputStream, ERROR_OUTPUT) == True) {
                ret = OpenOutputStream(output, ERROR_OUTPUT);
            }
        }
    }

    if (!ret) {
        /* It may be we already tried and failed to open *errout* above but
         * but this is an extreme case so it can't hurt to try again
         * anyways */
        ret = OpenOutput(output, "*errout*", FALSE);
        if (ret) {
            Pr("failed to open error stream\n", 0, 0);
        }
        else {
            Panic("failed to open *errout*");
        }
    }

    return ret;
}


/****************************************************************************
**
*F  FuncDownEnv( <self>, <level> )  . . . . . . . . .  change the environment
*/
static Obj FuncDownEnv(Obj self, Obj args)
{
    Int depth;

    if (LEN_PLIST(args) == 0) {
        depth = 1;
    }
    else if (LEN_PLIST(args) == 1 && IS_INTOBJ(ELM_PLIST(args, 1))) {
        depth = INT_INTOBJ(ELM_PLIST(args, 1));
    }
    else {
        ErrorQuit("usage: DownEnv( [ <depth> ] )", 0, 0);
    }
    if (IsBottomLVars(STATE(ErrorLVars))) {
        Pr("not in any function\n", 0, 0);
        return (Obj)0;
    }

    STATE(ErrorLLevel) += depth;;
    return (Obj)0;
}

static Obj FuncUpEnv(Obj self, Obj args)
{
    Int depth;
    if (LEN_PLIST(args) == 0) {
        depth = 1;
    }
    else if (LEN_PLIST(args) == 1 && IS_INTOBJ(ELM_PLIST(args, 1))) {
        depth = INT_INTOBJ(ELM_PLIST(args, 1));
    }
    else {
        ErrorQuit("usage: UpEnv( [ <depth> ] )", 0, 0);
    }
    if (IsBottomLVars(STATE(ErrorLVars))) {
        Pr("not in any function\n", 0, 0);
        return (Obj)0;
    }

    STATE(ErrorLLevel) -= depth;
    return (Obj)0;
}

static Obj FuncCURRENT_STATEMENT_LOCATION(Obj self, Obj context)
{
    if (IsBottomLVars(context))
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

    Obj currLVars = SWITCH_TO_OLD_LVARS(context);

    Obj retlist = Fail;
    Int type = TNUM_STAT(call);
    if ((FIRST_STAT_TNUM <= type && type <= LAST_STAT_TNUM) ||
        (FIRST_EXPR_TNUM <= type && type <= LAST_EXPR_TNUM)) {
        Int line = LINE_STAT(call);
        Obj filename = GET_FILENAME_BODY(body);
        retlist = NewPlistFromArgs(filename, INTOBJ_INT(line));
    }
    SWITCH_TO_OLD_LVARS(currLVars);
    return retlist;
}

static Obj FuncPRINT_CURRENT_STATEMENT(Obj self, Obj stream, Obj context)
{
    if (IsBottomLVars(context))
        return 0;

    /* HACK: we want to redirect output */
    /* Try to print the output to stream. Use *errout* as a fallback. */
    TypOutputFile output = { 0 };
    if ((IsStringConv(stream) &&
         !OpenOutput(&output, CONST_CSTR_STRING(stream), FALSE)) ||
        (!IS_STRING(stream) && !OpenOutputStream(&output, stream))) {
        if (OpenOutput(&output, "*errout*", FALSE)) {
            Pr("PRINT_CURRENT_STATEMENT: failed to open error stream\n", 0, 0);
        }
        else {
            Panic("failed to open *errout*");
        }
    }

    BOOL rethrow = FALSE;
    GAP_TRY
    {
        Obj func = FUNC_LVARS(context);
        GAP_ASSERT(func);
        Stat call = STAT_LVARS(context);
        Obj  body = BODY_FUNC(func);
        if (IsKernelFunction(func)) {
            PrintKernelFunction(func);
            Obj funcname = NAME_FUNC(func);
            if (funcname) {
                Pr(" in function %g", (Int)funcname, 0);
            }
        }
        else if (call < OFFSET_FIRST_STAT ||
                 call > SIZE_BAG(body) - sizeof(StatHeader)) {
            Pr("<corrupted statement> ", 0, 0);
        }
        else {
            Obj currLVars = SWITCH_TO_OLD_LVARS(context);

            Int type = TNUM_STAT(call);
            Obj filename = GET_FILENAME_BODY(body);
            if (FIRST_STAT_TNUM <= type && type <= LAST_STAT_TNUM) {
                PrintStat(call);
                Pr(" at %g:%d", (Int)filename, LINE_STAT(call));
            }
            else if (FIRST_EXPR_TNUM <= type && type <= LAST_EXPR_TNUM) {
                PrintExpr(call);
                Pr(" at %g:%d", (Int)filename, LINE_STAT(call));
            }
            SWITCH_TO_OLD_LVARS(currLVars);
        }
    }
    GAP_CATCH
    {
        rethrow = TRUE;
    }

    /* HACK: close the output again */
    CloseOutput(&output);

    if (rethrow)
        GAP_THROW();

    return 0;
}

/****************************************************************************
**
*F  FuncCALL_WITH_CATCH( <self>, <func> )
**
*/
static Obj FuncCALL_WITH_CATCH(Obj self, Obj func, Obj args)
{
    return CALL_WITH_CATCH(func, args);
}

Obj CALL_WITH_CATCH(Obj func, volatile Obj args)
{
    volatile Obj       res;
    volatile Obj       currLVars;
    volatile Obj       tilde;

    RequireFunction("CALL_WITH_CATCH", func);
    if (!IS_LIST(args))
        RequireArgument("CALL_WITH_CATCH", args, "must be a list");
#ifdef HPCGAP
    if (!IS_PLIST(args)) {
        args = PLAIN_LIST_COPY(args);
    }
#endif

    currLVars = STATE(CurrLVars);
    tilde = STATE(Tilde);
    res = NEW_PLIST_IMM(T_PLIST_DENSE, 2);
#ifdef HPCGAP
    int      lockSP = RegionLockSP();
    Region * savedRegion = TLS(currentRegion);
#endif
    GAP_TRY
    {
        Obj result = CallFuncList(func, args);
        // Make an explicit check if an interrupt occurred
        // in case func was a kernel function.
        TakeInterrupt();
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
    GAP_CATCH
    {
        SET_LEN_PLIST(res, 2);
        SET_ELM_PLIST(res, 1, False);
        SET_ELM_PLIST(res, 2, STATE(ThrownObject));
        CHANGED_BAG(res);
        STATE(ThrownObject) = 0;
        SWITCH_TO_OLD_LVARS(currLVars);
        STATE(Tilde) = tilde;
#ifdef HPCGAP
        PopRegionLocks(lockSP);
        TLS(currentRegion) = savedRegion;
        if (TLS(CurrentHashLock))
            HashUnlock(TLS(CurrentHashLock));
#endif
    }
    return res;
}

static Obj FuncJUMP_TO_CATCH(Obj self, Obj payload)
{
    STATE(ThrownObject) = payload;
    if (STATE(JumpToCatchCallback) != 0) {
        (*STATE(JumpToCatchCallback))();
    }
    GAP_THROW();
    return 0;
}

static Obj FuncSetUserHasQuit(Obj Self, Obj value)
{
    STATE(UserHasQuit) = INT_INTOBJ(value);
    return 0;
}


/****************************************************************************
**
*F  RegisterBreakloopObserver( <func> )
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
    SPrTo(message, sizeof(message), msg, arg1, arg2);
    message[sizeof(message) - 1] = '\0';
    return MakeImmString(message);
}


static Obj CallErrorInner(const Char * msg,
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
    l = NewPlistFromArgs(EarlyMsg);
    MakeImmutableNoRecurse(l);

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
    Panic("ErrorQuit must not return");
}


/****************************************************************************
**
*F  ErrorMayQuitNrArgs( <narg>, <actual> ) . . . .  wrong number of arguments
*/
void ErrorMayQuitNrArgs(Int narg, Int actual)
{
    ErrorMayQuit("Function: number of arguments must be %d (not %d)",
                 narg, actual);
}

/****************************************************************************
**
*F  ErrorMayQuitNrAtLeastArgs( <narg>, <actual> ) . . .  not enough arguments
*/
void ErrorMayQuitNrAtLeastArgs(Int narg, Int actual)
{
    ErrorMayQuit(
        "Function: number of arguments must be at least %d (not %d)",
        narg, actual);
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
    Panic("ErrorMayQuit must not return");
}

/****************************************************************************
**
*F  CheckIsPossList( <desc>, <poss> ) . . . . . . . . . . check for poss list
*/
void CheckIsPossList(const Char * desc, Obj poss)
{
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorMayQuit("%s: <poss> must be a dense list of positive integers",
            (Int)desc, 0 );
    }
}

/****************************************************************************
**
*F  CheckIsDenseList( <desc>, <listName>, <list> ) . . . check for dense list
*/
void CheckIsDenseList(const Char * desc, const Char * listName, Obj list)
{
    if (!IS_DENSE_LIST(list)) {
        ErrorMayQuit("%s: <%s> must be a dense list", (Int)desc, (Int)listName);
    }
}

/****************************************************************************
**
*F  CheckSameLength
*/
void CheckSameLength(const Char * desc,
                     const Char * name1,
                     const Char * name2,
                     Obj          op1,
                     Obj          op2)
{
    UInt len1 = LEN_LIST(op1);
    UInt len2 = LEN_LIST(op2);
    if (len1 != len2) {
        Char message[1024];
        snprintf(message, sizeof(message),
                 "%s: <%s> must have the same length as <%s> "
                 "(lengths are %d and %d)",
                 desc, name1, name2, (int)len1, (int)len2);
        ErrorMayQuit(message, 0, 0);
    }
}

/****************************************************************************
**
*F  RequireArgumentEx
*/
void RequireArgumentEx(const char * funcname,
                       Obj          op,
                       const char * argname,
                       const char * msg)
{
    char msgbuf[1024] = { 0 };
    Int  arg1 = 0;

    if (funcname) {
        gap_strlcat(msgbuf, funcname, sizeof(msgbuf));
        gap_strlcat(msgbuf, ": ", sizeof(msgbuf));
    }
    if (argname) {
        gap_strlcat(msgbuf, argname, sizeof(msgbuf));
        gap_strlcat(msgbuf, " ", sizeof(msgbuf));
    }
    gap_strlcat(msgbuf, msg, sizeof(msgbuf));
    if (IS_INTOBJ(op)) {
        gap_strlcat(msgbuf, " (not the integer %d)", sizeof(msgbuf));
        arg1 = INT_INTOBJ(op);
    }
    else if (op == True)
        gap_strlcat(msgbuf, " (not the value 'true')", sizeof(msgbuf));
    else if (op == False)
        gap_strlcat(msgbuf, " (not the value 'false')", sizeof(msgbuf));
    else if (op == Fail)
        gap_strlcat(msgbuf, " (not the value 'fail')", sizeof(msgbuf));
    else {
        const char * tnam = TNAM_OBJ(op);
        // heuristic to choose between 'a' and 'an': use 'an' before a vowel
        // and 'a' otherwise; however, that's not always correct, e.g. it is
        // "an FFE", so we add a special case for that as well
        if (TNUM_OBJ(op) == T_FFE || tnam[0] == 'a' || tnam[0] == 'e' ||
            tnam[0] == 'i' || tnam[0] == 'o' || tnam[0] == 'u')
            gap_strlcat(msgbuf, " (not an %s)", sizeof(msgbuf));
        else
            gap_strlcat(msgbuf, " (not a %s)", sizeof(msgbuf));
        arg1 = (Int)tnam;
    }

    ErrorMayQuit(msgbuf, arg1, 0);
}

const char * SELF_NAME_HELPER(Obj self, const char * func)
{
    if (self && NAME_FUNC(self))
        return CONST_CSTR_STRING(NAME_FUNC(self));
    return func;
}

void ErrorBoundedInt(
    const char * funcname, Obj op, const char * argname, int min, int max)
{
#define BOUNDED_INT_FORMAT "must be an integer between %d and %d"
    // The maximal number of decimal digits in a signed 64 bit value is 20, so
    // reserve space for that (actually, we would need a bit less because the
    // `%d` in the format string of course also adds to the length, but a
    // few bytes more or less don't matter).
    // Also note that in practice, `int` will be a 32 bit type anyway...
    char msg[sizeof(BOUNDED_INT_FORMAT) + 2 * 20];
    snprintf(msg, sizeof(msg), BOUNDED_INT_FORMAT, min, max);
    RequireArgumentEx(funcname, op, argname, msg);
#undef BOUNDED_INT_FORMAT
}


void AssertionFailure(void)
{
    ErrorReturnVoid("Assertion failure", 0, 0, "you may 'return;'");
}


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(DownEnv, -1, "args"),
    GVAR_FUNC(UpEnv, -1, "args"),

    GVAR_FUNC_2ARGS(CALL_WITH_CATCH, func, args),
    GVAR_FUNC_1ARGS(JUMP_TO_CATCH, payload),

    GVAR_FUNC_2ARGS(PRINT_CURRENT_STATEMENT, stream, context),
    GVAR_FUNC_1ARGS(CURRENT_STATEMENT_LOCATION, context),

    GVAR_FUNC_1ARGS(SetUserHasQuit, value),

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    STATE(ThrownObject) = 0;
    InitGlobalBag( &STATE(ThrownObject), "src/gap.c:ThrownObject"      );

    // init filters and functions
    InitHdlrFuncsFromTable(GVarFuncs);

    ImportFuncFromLibrary("ErrorInner", &ErrorInner);
    ImportFuncFromLibrary("IsOutputStream", &IsOutputStream);
    ImportGVarFromLibrary("ERROR_OUTPUT", &ERROR_OUTPUT);

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
