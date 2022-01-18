/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the immediate interpreter package.
**
**  The immediate interpreter package  is  the part  of the interpreter  that
**  interprets code immediately (while it is read).  Its functions are called
**  from the reader.  When it encounters  constructs that it cannot interpret
**  immediately, it switches into coding mode, and  delegates the work to the
**  coder.
*/

#include "intrprtr.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "code.h"
#include "error.h"
#include "funcs.h"
#include "gapstate.h"
#include "gvars.h"
#include "hookintrprtr.h"
#include "info.h"
#include "integer.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "permutat.h"
#include "plist.h"
#include "precord.h"
#include "range.h"
#include "records.h"
#include "stringobj.h"
#include "trycatch.h"
#include "vars.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#include "hpc/guards.h"
#endif

// INTERPRETER_PROFILE_HOOK deals with profiling of immediately executed
// code.
// If intr->coding is true, profiling is handled by the AST
// generation and execution. Otherwise, we always mark the line as
// read, and mark as executed if intr->returning and intr->ignoring
// are both false.
//
// IgnoreLevel gives the highest value of IntrIgnoring which means this
// statement is NOT ignored (this is usually, but not always, 0)
static void INTERPRETER_PROFILE_HOOK(IntrState * intr, int ignoreLevel)
{
    if (!intr->coding) {
        InterpreterHook(
            GetInputFilenameID(GetCurrentInput()), intr->startLine,
            intr->returning != STATUS_END || (intr->ignoring > ignoreLevel));
    }
    intr->startLine = 0;
}


// Put the profiling hook into SKIP_IF_RETURNING, as this is run in
// (nearly) every part of the interpreter, avoid lots of extra code.
#define SKIP_IF_RETURNING()                                                  \
    INTERPRETER_PROFILE_HOOK(intr, 0);                                       \
    SKIP_IF_RETURNING_NO_PROFILE_HOOK();

// Need to
#define SKIP_IF_RETURNING_NO_PROFILE_HOOK()                                  \
    if (intr->returning != STATUS_END) {                                     \
        return;                                                              \
    }

#define SKIP_IF_IGNORING()                                                   \
    if (intr->ignoring > 0) {                                                \
        return;                                                              \
    }


/****************************************************************************
**
*F  StackObj  . . . . . . . . . . . . . . . . . . . . . . . . .  values stack
*F  PushObj(<val>)  . . . . . . . . . . . . . . . . push value onto the stack
*F  PushVoidObj() . . . . . . . . . . . . . .  push void value onto the stack
*F  PopObj()  . . . . . . . . . . . . . . . . . . .  pop value from the stack
*F  PopVoidObj()  . . . . . . . . . . . . . . . . .  pop value from the stack
**
**  'StackObj' is the stack of values.
**
**  'PushObj' pushes the value <val>  onto the values stack.   It is an error
**  to push the void value.  The stack is automatically resized if necessary.
**
**  'PushVoidObj' pushes the void value onto the values stack.  This value is
**  the value of if-statements and loops and procedure calls.
**
**  'PopObj' returns the top element from  the values stack  and pops it.  It
**  is an error if the stack is empty or if the top element is void.
**
**  'PopVoidObj' returns the  top element from the values  stack and pops it.
**  It is an error if the stack is empty but not if the top element is void.
*/
/* TL: Obj             StackObj; */

static void PushObj(IntrState * intr, Obj val)
{
    GAP_ASSERT(val != 0);
    PushPlist(intr->StackObj, val);
}

/* Special marker value to denote that a function returned no value, so we
 * can produce a useful error message. This value only ever appears on the
 * stack, and should never be visible outside the Push and Pop methods below
 *
 * The only place other than these methods which access the stack is
 * the permutation reader, but it only directly accesses values it wrote,
 * so it will not see this magic value. */
static Obj VoidReturnMarker;

static void PushFunctionVoidReturn(IntrState * intr)
{
    PushPlist(intr->StackObj, VoidReturnMarker);
}

static void PushVoidObj(IntrState * intr)
{
    PushPlist(intr->StackObj, 0);
}

static Obj PopObj(IntrState * intr)
{
    Obj val = PopPlist(intr->StackObj);

    if (val == VoidReturnMarker) {
        ErrorQuit("Function call: <func> must return a value", 0, 0);
    }

    // return the popped value (which must be non-void)
    GAP_ASSERT(val != 0);
    return val;
}

static Obj PopVoidObj(IntrState * intr)
{
    Obj val = PopPlist(intr->StackObj);

    // Treat a function which returned no value the same as 'void'
    if (val == VoidReturnMarker) {
        val = 0;
    }

    // return the popped value (which may be void)
    return val;
}


static void StartFakeFuncExpr(IntrState * intr, Obj stackNams, Int startLine)
{
    GAP_ASSERT(intr->coding == 0);

    // switch to coding mode now
    CodeBegin();

    // code a function expression (with no arguments and locals)
    Obj nams = NEW_PLIST(T_PLIST, 0);

    // If we are in the break loop, then a local variable context may well
    // exist, and we have to create an empty local variable names list to
    // match the function expression that we are creating.
    //
    // Without this, access to variables defined in the existing local
    // variable context will be coded as LVAR accesses; but when we then
    // execute this code, they will not actually be available in the current
    // context, but rather one level up, i.e., they really should have been
    // coded as HVARs.
    //
    // If we are not in a break loop, then this would be a waste of time and
    // effort
    if (LEN_PLIST(stackNams) > 0) {
        PushPlist(stackNams, nams);
    }

    CodeFuncExprBegin(0, 0, nams, startLine);
}


static void FinishAndCallFakeFuncExpr(IntrState * intr, Obj stackNams)
{
    GAP_ASSERT(intr->coding == 0);

    // code a function expression (with one statement in the body)
    CodeFuncExprEnd(1, 1);

    // switch back to immediate mode and get the function
    Obj func = CodeEnd(0);

    // If we are in a break loop, then we will have created a "dummy" local
    // variable names list to get the counts right. Remove it.
    const UInt len = LEN_PLIST(stackNams);
    if (len > 0)
        PopPlist(stackNams);

    // call the function
    CALL_0ARGS(func);

    // push void
    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrBegin(<intr>) . . . . . . . . . . . . . . . . .  start an interpreter
*F  IntrEnd(<intr>,<error>,<result>)  . . . . . . . . . . stop an interpreter
**
**  'IntrBegin' starts a new interpreter.
**
**  'IntrEnd' stops the given interpreter.
**
**  If <error>  is non-zero a  syntax error was found by  the reader, and the
**  interpreter only clears up the mess.
**
**  If 'IntrEnd' returns 'STATUS_END', then no return-statement or
**  quit-statement was interpreted. If 'IntrEnd' returns 'STATUS_RETURN',
**  then a return-statement was interpreted. If a value was returned, and the
**  <result> is non-zero, then the returned value is assigned to the address
**  <result> points at. If 'IntrEnd' returns 'STATUS_QUIT', then a
**  quit-statement was interpreted. If 'IntrEnd' returns 'STATUS_QQUIT', then
**  a QUIT-statement was interpreted.
*/
void IntrBegin(IntrState * intr)
{
    /* allocate a new values stack                                         */
    intr->StackObj = NEW_PLIST(T_PLIST, 64);

    /* must be in immediate (non-ignoring, non-coding) mode                */
    GAP_ASSERT(intr->ignoring == 0);
    GAP_ASSERT(intr->coding == 0);

    /* no return-statement was yet interpreted                             */
    intr->returning = STATUS_END;
}

ExecStatus IntrEnd(IntrState * intr, BOOL error, Obj * result)
{
    /* if everything went fine                                             */
    if ( ! error ) {

        /* must be back in immediate (non-ignoring, non-coding) mode       */
        GAP_ASSERT(intr->ignoring == 0);
        GAP_ASSERT(intr->coding == 0);

        /* and the stack must contain the result value (which may be void) */
        GAP_ASSERT(LEN_PLIST(intr->StackObj) == 1);
        if (result)
            *result = PopVoidObj(intr);

        return intr->returning;
    }

    /* otherwise clean up the mess                                         */
    else {

        /* clean up the coder too                                          */
        if (intr->coding > 0) {
            CodeEnd(1);
        }

        /* dummy result value (probably ignored)                           */
        if (result)
            *result = 0;

        // indicate that we had an error
        return STATUS_ERROR;
    }
}


/****************************************************************************
**
*F  IntrAbortCoding() . . . . . . . . . . . . . . . . . . . . .  abort coding
**
**  'IntrAbortCoding' aborts coding, if it is active.
*/
void IntrAbortCoding(IntrState * intr)
{
    if (intr->coding) {
        CodeEnd(1);
        intr->coding--;
    }
}


/****************************************************************************
**
*F  IntrFuncCallBegin() . . . . . . . . . . .  interpret function call, begin
*F  IntrFuncCallEnd(<funccall>,<options>, <nr>)  interpret function call, end
**
**  'IntrFuncCallBegin' is an action  to  interpret a  function call.  It  is
**  called by  the reader  when  it  encounters  the parenthesis  '(',  i.e.,
**  *after* the function expression is read.
**
**  'IntrFuncCallEnd'  is an  action to  interpret  a  function call.   It is
**  called by    the reader when it encounters     the parenthesis ')', i.e.,
**  *after* the argument expressions are read.  <funccall>  is 1 if this is a
**  function call, and 0 if this is a procedure call.  <nr>  is the number of
**  arguments. <options> is 1 if options were present after the ':' in which
**  case the options have been read already.
*/
void IntrFuncCallBegin(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFuncCallBegin();
        return;
    }
}

static Obj PushOptions;
static Obj PopOptions;

void IntrFuncCallEnd(IntrState * intr, UInt funccall, UInt options, UInt nr)
{
    Obj                 func;           /* function                        */
    Obj                 a1;             /* first argument                  */
    Obj                 a2;             /* second argument                 */
    Obj                 a3;             /* third argument                  */
    Obj                 a4;             /* fourth argument                 */
    Obj                 a5;             /* fifth  argument                 */
    Obj                 a6;             /* sixth  argument                 */
    Obj                 args;           /* argument list                   */
    Obj                 argi;           /* <i>-th argument                 */
    Obj                 val;            /* return value of function        */
    Obj                 opts;           /* record of options               */
    UInt                i;              /* loop variable                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING_NO_PROFILE_HOOK();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFuncCallEnd(funccall, options, nr);
        return;
    }


    if (options) {
        opts = PopObj(intr);
        CALL_1ARGS(PushOptions, opts);
    }

    /* get the arguments from the stack                                    */
    a1 = a2 = a3 = a4 = a5 = a6 = args = 0;
    if ( nr <= 6 ) {
        if ( 6 <= nr ) { a6 = PopObj(intr); }
        if ( 5 <= nr ) { a5 = PopObj(intr); }
        if ( 4 <= nr ) { a4 = PopObj(intr); }
        if ( 3 <= nr ) { a3 = PopObj(intr); }
        if ( 2 <= nr ) { a2 = PopObj(intr); }
        if ( 1 <= nr ) { a1 = PopObj(intr); }
    } else {
        args = NEW_PLIST( T_PLIST, nr );
        SET_LEN_PLIST( args, nr );
        for ( i = nr; 1 <= i; i-- ) {
            argi = PopObj(intr);
            SET_ELM_PLIST( args, i, argi );
        }
    }

    /* get and check the function from the stack                           */
    func = PopObj(intr);
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
      if ( nr <= 6 ) {
        args = NEW_PLIST( T_PLIST_DENSE, nr );
        SET_LEN_PLIST( args, nr );
        switch(nr) {
        case 6: SET_ELM_PLIST(args,6,a6);
        case 5: SET_ELM_PLIST(args,5,a5);
        case 4: SET_ELM_PLIST(args,4,a4);
        case 3: SET_ELM_PLIST(args,3,a3);
        case 2: SET_ELM_PLIST(args,2,a2);
        case 1: SET_ELM_PLIST(args,1,a1);
        }
      }
      val = DoOperation2Args(CallFuncListOper, func, args);
    } else {
      /* call the function                                                 */
      if      ( 0 == nr ) { val = CALL_0ARGS( func ); }
      else if ( 1 == nr ) { val = CALL_1ARGS( func, a1 ); }
      else if ( 2 == nr ) { val = CALL_2ARGS( func, a1, a2 ); }
      else if ( 3 == nr ) { val = CALL_3ARGS( func, a1, a2, a3 ); }
      else if ( 4 == nr ) { val = CALL_4ARGS( func, a1, a2, a3, a4 ); }
      else if ( 5 == nr ) { val = CALL_5ARGS( func, a1, a2, a3, a4, a5 ); }
      else if ( 6 == nr ) { val = CALL_6ARGS( func, a1, a2, a3, a4, a5, a6 ); }
      else                { val = CALL_XARGS( func, args ); }

      if (STATE(UserHasQuit) || STATE(UserHasQUIT)) {
        // the procedure must have called READ() and the user quit from a break loop
        // inside it; or a file containing a `QUIT` statement was read at the top
        // execution level (e.g. in init.g, before the primary REPL starts) after
        // which the procedure was called, and now we are returning from that
        GAP_THROW();
      }
    }

    if (options)
      CALL_0ARGS(PopOptions);

    /* push the value onto the stack                                       */
    if ( val == 0 )
        PushFunctionVoidReturn(intr);
    else
        PushObj(intr, val);
}


/****************************************************************************
**
*F  IntrFuncExprBegin(<narg>,<nloc>,<nams>) .  interpret function expr, begin
*F  IntrFuncExprEnd(<nr>) . . . . . . . . . . .  interpret function expr, end
**
**  'IntrFuncExprBegin' is an action to interpret  a function expression.  It
**  is  called when   the reader  encounters  the  beginning  of  a  function
**  expression.  <narg> is the number of  arguments (-1 if the function takes
**  a variable number of arguments),  <nloc> is the  number of locals, <nams>
**  is a list of local variable names.
**
**  'IntrFuncExprEnd' is an action to interpret a function expression.  It is
**  called when the reader encounters the end  of a function expression. <nr>
**  is the number of statements in the body of the function.
*/
void IntrFuncExprBegin(
    IntrState * intr, Int narg, Int nloc, Obj nams, Int startLine)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding == 0) {
        CodeBegin();
    }
    intr->coding++;

    /* code a function expression                                          */
    CodeFuncExprBegin( narg, nloc, nams, startLine );
}

void IntrFuncExprEnd(IntrState * intr, UInt nr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);

    intr->coding--;
    CodeFuncExprEnd(nr, 1);

    if (intr->coding == 0) {
        // switch back to immediate mode and get the function
        Obj func = CodeEnd(0);

        // push the function
        PushObj(intr, func);
    }
}


/****************************************************************************
**
*F  IntrIfBegin() . . . . . . . .  interpret if-statement, begin of statement
*F  IntrIfElif()  . . . . . . .  interpret if-statement, begin of elif-branch
*F  IntrIfElse()  . . . . . . .  interpret if-statement, begin of else-branch
*F  IntrIfBeginBody() . . . . . . . . . interpret if-statement, begin of body
*F  IntrIfEndBody(<nr>) . . . . . . . . . interpret if-statement, end of body
*F  IntrIfEnd(<nr>) . . . . . . . .  interpret if-statement, end of statement
**
**  'IntrIfBegin' is an  action to interpret  an if-statement.   It is called
**  when the reader encounters the   'if',  i.e., *before* the condition   is
**  read.
**
**  'IntrIfElif' is  an action to   interpret an if-statement.  It is  called
**  when the  reader encounters an  'elif', i.e.,  *before* the condition  is
**  read.
**
**  'IntrIfElse' is  an  action to interpret an   if-statement.  It is called
**  when the reader encounters an 'else'.
**
**  'IntrIfBeginBody'  is  an action to   interpret  an if-statement.  It  is
**  called when the reader encounters the beginning  of the statement body of
**  an 'if', 'elif', or 'else' branch, i.e., *after* the condition is read.
**
**  'IntrIfEndBody' is an action to interpret  an if-statement.  It is called
**  when the reader  encounters the end of  the  statements body of an  'if',
**  'elif', or 'else' branch.  <nr> is the number of statements in the body.
**
**  'IntrIfEnd' is an action to interpret an if-statement.  It is called when
**  the reader  encounters the end of the  statement.  <nr>  is the number of
**  'if', 'elif', or 'else' branches.
*/
void IntrIfBegin(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();

    // if IntrIgnoring is positive, increment it, as IntrIgnoring == 1 has a
    // special meaning when parsing if-statements -- it is used to skip
    // interpreting or coding branches of the if-statement which never will
    // be executed, either because a previous branch is always executed
    // (i.e., it has a 'true' condition), or else because the current branch
    // has a 'false' condition
    if (intr->ignoring > 0) {
        intr->ignoring++;
        return;
    }
    if (intr->coding > 0) {
        CodeIfBegin();
        return;
    }
}

void IntrIfElif(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIfElif();
        return;
    }
}

void IntrIfElse(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIfElse();
        return;
    }


    /* push 'true' (to execute body of else-branch)                        */
    PushObj(intr, True);
}

void IntrIfBeginBody(IntrState * intr)
{
    Obj                 cond;           /* value of condition              */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    if (intr->ignoring > 0) {
        intr->ignoring++;
        return;
    }
    if (intr->coding > 0) {
        intr->ignoring = CodeIfBeginBody();
        return;
    }


    /* get and check the condition                                         */
    cond = PopObj(intr);
    if ( cond != True && cond != False ) {
        RequireArgumentEx(0, cond, "<expr>", "must be 'true' or 'false'");
    }

    /* if the condition is 'false', ignore the body                        */
    if ( cond == False ) {
        intr->ignoring = 1;
    }
}

Int IntrIfEndBody(IntrState * intr, UInt nr)
{
    UInt                i;              /* loop variable                   */

    /* explicitly check interpreter hooks, as not using SKIP_IF_RETURNING  */
    INTERPRETER_PROFILE_HOOK(intr, 0);

    /* ignore or code                                                      */
    if (intr->returning != STATUS_END) {
        return 0;
    }
    if (intr->ignoring > 0) {
        intr->ignoring--;
        return 0;
    }
    if (intr->coding > 0) {
        intr->ignoring = CodeIfEndBody(nr);
        return 1;
    }

    /* otherwise drop the values for the statements executed in the body   */
    for ( i = nr; 1 <= i; i-- ) {
        PopVoidObj(intr);
    }

    /* one branch of the if-statement was executed, ignore the others      */
    intr->ignoring = 1;

    return 1;
}

void IntrIfEnd(IntrState * intr, UInt nr)
{
    // ignore or code
    INTERPRETER_PROFILE_HOOK(intr, 1);
    SKIP_IF_RETURNING_NO_PROFILE_HOOK();

    if (intr->ignoring > 1) {
        intr->ignoring--;
        return;
    }

    // if one branch was executed (ignoring the others), reset IntrIgnoring
    if (intr->ignoring == 1) {
        intr->ignoring = 0;
    }

    if (intr->coding > 0) {
        CodeIfEnd(nr);
        return;
    }

    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrForBegin()  . . . . . . . interpret for-statement, begin of statement
*F  IntrForIn() . . . . . . . . . . . . .  interpret for-statement, 'in'-read
*F  IntrForBeginBody()  . . . . . . .  interpret for-statement, begin of body
*F  IntrForEndBody(<nr>)  . . . . . . .  interpret for-statement, end of body
*F  IntrForEnd()  . . . . . . . . . interpret for-statement, end of statement
**
**  'IntrForBegin' is  an action to interpret  a for-statement.  It is called
**  when the   reader encounters the  'for', i.e.,  *before*  the variable is
**  read.
**
**  'IntrForIn' is an action to interpret a for-statement.  It is called when
**  the  reader encounters the 'in', i.e.,  *after* the variable is read, but
**  *before* the list expression is read.
**
**  'IntrForBeginBody'  is  an action to interpret   a for-statement.   It is
**  called when  the reader encounters  the beginning  of the statement body,
**  i.e., *after* the list expression is read.
**
**  'IntrForEndBody' is an action to interpret a for-statement.  It is called
**  when the  reader encounters the  end of the  statement body.  <nr> is the
**  number of statements in the body.
**
**  'IntrForEnd' is an  action  to interpret a  for-statement.   It is called
**  when the  reader encounters the end of  the statement,  i.e., immediately
**  after 'IntrForEndBody'.
**
**  Since loops cannot be interpreted immediately,  the interpreter calls the
**  coder  to create a  procedure (with no arguments) and  calls that.
*/
void IntrForBegin(IntrState * intr, Obj stackNams)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding == 0)
        StartFakeFuncExpr(intr, stackNams, 0);

    intr->coding++;

    /* code a for loop                                                     */
    CodeForBegin();
}

void IntrForIn(IntrState * intr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeForIn();
}

void IntrForBeginBody(IntrState * intr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeForBeginBody();
}

void IntrForEndBody(IntrState * intr, UInt nr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeForEndBody(nr);
}

void IntrForEnd(IntrState * intr, Obj stackNams)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);

    intr->coding--;
    CodeForEnd();

    if (intr->coding == 0)
        FinishAndCallFakeFuncExpr(intr, stackNams);
}


/****************************************************************************
**
*F  IntrWhileBegin()  . . . . . interpret while-statement, begin of statement
*F  IntrWhileBeginBody()  . . . . .  interpret while-statement, begin of body
*F  IntrWhileEndBody(<nr>)  . . . . .  interpret while-statement, end of body
*F  IntrWhileEnd()  . . . . . . . interpret while-statement, end of statement
**
**  'IntrWhileBegin' is   an action to  interpret   a while-statement.  It is
**  called when the    reader encounters the    'while', i.e., *before*   the
**  condition is read.
**
**  'IntrWhileBeginBody' is an action  to interpret a while-statement.  It is
**  called when the reader encounters  the  beginning of the statement  body,
**  i.e., *after* the condition is read.
**
**  'IntrWhileEndBody' is  an action to interpret   a while-statement.  It is
**  called when the reader encounters the end of the statement body.  <nr> is
**  the number of statements in the body.
**
**  'IntrWhileEnd' is an action to interpret a while-statement.  It is called
**  when  the reader encounters  the  end of  the  statement, i.e., immediate
**  after 'IntrWhileEndBody'.
**
**  Since loops cannot be interpreted immediately,  the interpreter calls the
**  coder  to create a  procedure (with no arguments) and  calls that.
*/
void IntrWhileBegin(IntrState * intr, Obj stackNams)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding == 0)
        StartFakeFuncExpr(intr, stackNams, 0);

    intr->coding++;

    /* code a while loop                                                   */
    CodeWhileBegin();
}

void IntrWhileBeginBody(IntrState * intr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeWhileBeginBody();
}

void IntrWhileEndBody(IntrState * intr, UInt nr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeWhileEndBody( nr );
}

void IntrWhileEnd(IntrState * intr, Obj stackNams)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);

    intr->coding--;
    CodeWhileEnd();

    if (intr->coding == 0)
        FinishAndCallFakeFuncExpr(intr, stackNams);
}


/****************************************************************************
**
*F  IntrQualifiedExprBegin(<qual>) .  interpret readonly/readwrite expr start
*F  IntrQualifiedExprEnd() . . . . . .  interpret readonly/readwrite expr end
**
**  These functions interpret the beginning and end of the readonly/readwrite
**  qualified expressions of an atomic statement.
*/
void IntrQualifiedExprBegin(IntrState * intr, UInt qual)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeQualifiedExprBegin(qual);
}

void IntrQualifiedExprEnd(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeQualifiedExprEnd();
}

/****************************************************************************
**
*F  IntrAtomicBegin() . . . .  interpret atomic-statement, begin of statement
*F  IntrAtomicBeginBody(<nrexprs>)  interpret atomic-statement, begin of body
*F  IntrAtomicEndBody(<nrstats>) . .  interpret atomic-statement, end of body
*F  IntrAtomicEnd() . . . . . .  interpret atomic-statement, end of statement
**
**  'IntrAtomicBegin' is an action to interpret an atomic-statement. It is
**  called when the reader encounters the 'atomic', i.e., *before* the
**  expressions to be locked are read.
**
**  'IntrAtomicBeginBody' is an action to interpret an atomic-statement. It
**  is called when the reader encounters the beginning of the statement body,
**  i.e., *after* the expressions to be locked are read. <nrexprs> is the
**  number of expressions to be locked
**
**  'IntrAtomicEndBody' is an action to interpret an atomic-statement. It is
**  called when the reader encounters the end of the statement body.
**  <nrstats> is the number of statements in the body.
**
**  'IntrAtomicEnd' is an action to interpret an atomic-statement. It is
**  called when the reader encounters the end of the statement, i.e.,
**  immediately after 'IntrAtomicEndBody'.
**
**  These functions only do something meaningful inside HPC-GAP; in plain
**  GAP, they are simply placeholders.
*/
void IntrAtomicBegin(IntrState * intr, Obj stackNams)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding == 0)
        StartFakeFuncExpr(intr, stackNams,
                          GetInputLineNumber(GetCurrentInput()));

    intr->coding++;

    CodeAtomicBegin();
}

void IntrAtomicBeginBody(IntrState * intr, UInt nrexprs)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeAtomicBeginBody(nrexprs);
}

void IntrAtomicEndBody(IntrState * intr, Int nrstats)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    // must be coding
    GAP_ASSERT(intr->coding > 0);
    CodeAtomicEndBody(nrstats);
}

void IntrAtomicEnd(IntrState * intr, Obj stackNams)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);

    intr->coding--;
    CodeAtomicEnd();

    if (intr->coding == 0)
        FinishAndCallFakeFuncExpr(intr, stackNams);
}


/****************************************************************************
**
*F  IntrRepeatBegin() . . . .  interpret repeat-statement, begin of statement
*F  IntrRepeatBeginBody() . . . . . interpret repeat-statement, begin of body
*F  IntrRepeatEndBody(<nr>) . . . . . interpret repeat-statement, end of body
*F  IntrRepeatEnd() . . . . . .  interpret repeat-statement, end of statement
**
**  'IntrRepeatBegin"  is an action to interpret  a  repeat-statement.  It is
**  called when the read encounters the 'repeat'.
**
**  'IntrRepeatBeginBody' is an action  to interpret a  repeat-statement.  It
**  is called when the reader encounters the beginning of the statement body,
**  i.e., immediately after 'IntrRepeatBegin'.
**
**  'IntrRepeatEndBody' is an action  to interpret a repeat-statement.  It is
**  called when the reader  encounters the end of  the statement  body, i.e.,
**  *before* the condition is read.  <nr> is the  number of statements in the
**  body.
**
**  'IntrRepeatEnd' is  an  action to interpret  a repeat-statement.    It is
**  called when the reader encounters the end of the statement, i.e., *after*
**  the condition is read.
**
**  Since loops cannot be interpreted immediately,  the interpreter calls the
**  coder  to create a  procedure (with no arguments) and  calls that.
*/
void IntrRepeatBegin(IntrState * intr, Obj stackNams)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding == 0)
        StartFakeFuncExpr(intr, stackNams,
                          GetInputLineNumber(GetCurrentInput()));

    intr->coding++;

    /* code a repeat loop                                                  */
    CodeRepeatBegin();
}

void IntrRepeatBeginBody(IntrState * intr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeRepeatBeginBody();
}

void IntrRepeatEndBody(IntrState * intr, UInt nr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeRepeatEndBody( nr );
}

void IntrRepeatEnd(IntrState * intr, Obj stackNams)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);

    intr->coding--;
    CodeRepeatEnd();

    if (intr->coding == 0)
        FinishAndCallFakeFuncExpr(intr, stackNams);
}


/****************************************************************************
**
*F  IntrBreak() . . . . . . . . . . . . . . . . . . interpret break-statement
**
**  'IntrBreak'  is the action to interpret  a break-statement.  It is called
**  when the reader encounters a 'break;'.
**
**  Break-statements are  always coded (if  they are not ignored), since they
**  can only appear in loops.
*/
void IntrBreak(IntrState * intr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeBreak();
}


/****************************************************************************
**
*F  IntrContinue() . . . . . . . . . . . . . . . interpret continue-statement
**
**  'IntrContinue' is the action to interpret a continue-statement. It is
**  called when the reader encounters a 'continue;'.
**
**  Continue-statements are always coded (if they are not ignored), since
**  they can only appear in loops.
*/
void IntrContinue(IntrState * intr)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    GAP_ASSERT(intr->coding > 0);
    CodeContinue();
}


/****************************************************************************
**
*F  IntrReturnObj() . . . . . . . . . . . .  interpret return-value-statement
**
**  'IntrReturnObj' is the action  to interpret a return-value-statement.  It
**  is  called when  the reader encounters  a  'return  <expr>;', but *after*
**  reading the expression <expr>.
*/
void IntrReturnObj(IntrState * intr)
{
    Obj                 val;            /* return value                    */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeReturnObj();
        return;
    }


    /* empty the values stack and push the return value                    */
    val = PopObj(intr);
    SET_LEN_PLIST(intr->StackObj, 0);
    PushObj(intr, val);

    // indicate that a return-statement was interpreted
    intr->returning = STATUS_RETURN;
}


/****************************************************************************
**
*F  IntrReturnVoid()  . . . . . . . . . . . . interpret return-void-statement
**
**  'IntrReturnVoid' is the action to interpret  a return-void-statement.  It
**  is called when the reader encounters a 'return;'.
*/
void IntrReturnVoid(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeReturnVoid();
        return;
    }


    /* empty the values stack and push the void value                      */
    SET_LEN_PLIST(intr->StackObj, 0);
    PushVoidObj(intr);

    // indicate that a return-statement was interpreted
    intr->returning = STATUS_RETURN;
}


/****************************************************************************
**
*F  IntrQuit()  . . . . . . . . . . . . . . . . . .  interpret quit-statement
**
**  'IntrQuit' is the  action to interpret   a quit-statement.  It  is called
**  when the reader encounters a 'quit;'.
*/
void IntrQuit(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* 'quit' is not allowed in functions (by the reader)                  */
    GAP_ASSERT(intr->coding == 0);

    /* empty the values stack and push the void value                      */
    SET_LEN_PLIST(intr->StackObj, 0);
    PushVoidObj(intr);

    /* indicate that a quit-statement was interpreted                      */
    intr->returning = STATUS_QUIT;
}

/****************************************************************************
**
*F  IntrQUIT()  . . . . . . . . . . . . . . . . . .  interpret quit-statement
**
**  'IntrQUIT' is the  action to interpret   a quit-statement.  It  is called
**  when the reader encounters a 'QUIT;'.
*/
void IntrQUIT(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* 'QUIT' is not allowed in functions (by the reader)                  */
    GAP_ASSERT(intr->coding == 0);

    /* empty the values stack and push the void value                      */
    SET_LEN_PLIST(intr->StackObj, 0);
    PushVoidObj(intr);

    /* indicate that a QUIT-statement was interpreted                      */
    intr->returning = STATUS_QQUIT;
}

/****************************************************************************
 **
 *F  IntrHelp()
 **
 **  'IntrHelp' is the action to interpret a help statement.
 **
 */
void IntrHelp(IntrState * intr, Obj topic)
{
    UInt hgvar;
    Obj  help;
    Obj  res;

    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    // '?' is not allowed in functions (by the reader)
    GAP_ASSERT(intr->coding == 0);

    /* FIXME: Hard coded function name */
    hgvar = GVarName("HELP");
    help = ValGVar(hgvar);
    if (!help) {
        ErrorQuit(
            "Global variable \"HELP\" is not defined. Cannot access help", 0,
            0);
    }
    if (!IS_FUNC(help)) {
        ErrorQuit(
            "Global variable \"HELP\" is not a function. Cannot access help",
            0, 0);
    }

    res = CALL_1ARGS(help, topic);
    if (res)
        PushObj(intr, res);
    else
        PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrOrL() . . . . . . . . . .  interpret or-expression, left operand read
*F  IntrOr()  . . . . . . . . . . interpret or-expression, right operand read
**
**  'IntrOrL' is an action to interpret an or-expression.   It is called when
**  the reader encounters the 'or' keyword, i.e., *after* the left operand is
**  read but *before* the right operand is read.
**
**  'IntrOr' is an action to  interpret an or-expression.   It is called when
**  the reader encountered  the  end of  the  expression, i.e., *after*  both
**  operands are read.
*/
void IntrOrL(IntrState * intr)
{
    Obj                 opL;            /* value of left operand           */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    if (intr->ignoring > 0) {
        intr->ignoring++;
        return;
    }
    if (intr->coding > 0) {
        CodeOrL();
        return;
    }


    /* if the left operand is 'true', ignore the right operand             */
    opL = PopObj(intr);
    PushObj(intr, opL);
    if ( opL == True ) {
        PushObj(intr, opL);
        intr->ignoring = 1;
    }
}

void IntrOr(IntrState * intr)
{
    Obj                 opL;            /* value of left  operand          */
    Obj                 opR;            /* value of right operand          */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    if (intr->ignoring > 1) {
        intr->ignoring--;
        return;
    }
    if (intr->coding > 0) {
        CodeOr();
        return;
    }


    /* stop ignoring things now                                            */
    intr->ignoring = 0;

    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* if the left operand is 'true', this is the result                   */
    if      ( opL == True ) {
        PushObj(intr, opL);
    }

    /* if the left operand is 'false', the result is the right operand     */
    else if ( opL == False  ) {
        if ( opR == True || opR == False  ) {
            PushObj(intr, opR);
        }
        else {
            RequireArgumentEx(0, opR, "<expr>", "must be 'true' or 'false'");
        }
    }

    /* signal an error                                                     */
    else {
        RequireArgumentEx(0, opL, "<expr>", "must be 'true' or 'false'");
    }
}


/****************************************************************************
**
*F  IntrAndL()  . . . . . . . . . interpret and-expression, left operand read
*F  IntrAnd() . . . . . . . . .  interpret and-expression, right operand read
**
**  'IntrAndL' is  an action  to interpret an   and-expression.  It is called
**  when the reader  encounters the  'and'  keyword, i.e., *after*  the  left
**  operand is read but *before* the right operand is read.
**
**  'IntrAnd' is an action to interpret an and-expression.  It is called when
**  the reader encountered   the end of   the expression, i.e., *after*  both
**  operands are read.
*/
void IntrAndL(IntrState * intr)
{
    Obj                 opL;            /* value of left operand           */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    if (intr->ignoring > 0) {
        intr->ignoring++;
        return;
    }
    if (intr->coding > 0) {
        CodeAndL();
        return;
    }


    /* if the left operand is 'false', ignore the right operand            */
    opL = PopObj(intr);
    PushObj(intr, opL);
    if ( opL == False ) {
        PushObj(intr, opL);
        intr->ignoring = 1;
    }
}

void IntrAnd(IntrState * intr)
{
    Obj                 opL;            /* value of left  operand          */
    Obj                 opR;            /* value of right operand          */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    if (intr->ignoring > 1) {
        intr->ignoring--;
        return;
    }
    if (intr->coding > 0) {
        CodeAnd();
        return;
    }


    /* stop ignoring things now                                            */
    intr->ignoring = 0;

    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* if the left operand is 'false', this is the result                  */
    if      ( opL == False ) {
        PushObj(intr, opL);
    }

    /* if the left operand is 'true', the result is the right operand      */
    else if ( opL == True  ) {
        if ( opR == False || opR == True  ) {
            PushObj(intr, opR);
        }
        else {
            RequireArgumentEx(0, opR, "<expr>", "must be 'true' or 'false'");
        }
    }

    /* handle the 'and' of two filters                                    */
    else if (IS_FILTER(opL)) {
        PushObj(intr, NewAndFilter(opL, opR));
    }

    /* signal an error                                                     */
    else {
        RequireArgumentEx(0, opL, "<expr>",
                          "must be 'true' or 'false' or a filter");
    }
}


/****************************************************************************
**
*F  IntrNot() . . . . . . . . . . . . . . . . . . .  interpret not-expression
**
**  'IntrNot' is the action to interpret a not-expression.  It is called when
**  the reader encounters a not-expression, *after* the operand is read.
*/
void IntrNot(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 op;             /* operand                         */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeNot();
        return;
    }


    /* get and check the operand                                           */
    op = PopObj(intr);
    if ( op != True && op != False ) {
        RequireArgumentEx(0, op, "<expr>", "must be 'true' or 'false'");
    }

    /* negate the operand                                                  */
    val = (op == False ? True : False);

    /* push the result                                                     */
    PushObj(intr, val);
}


/****************************************************************************
**
*F  IntrEq()  . . . . . . . . . . . . . . . . . . . .  interpret =-expression
*F  IntrNe()  . . . . . . . . . . . . . . . . . . . . interpret <>-expression
*F  IntrLt()  . . . . . . . . . . . . . . . . . . . . interpret  <-expression
*F  IntrGe()  . . . . . . . . . . . . . . . . . . . . interpret >=-expression
*F  IntrGt()  . . . . . . . . . . . . . . . . . . . .  interpret >-expression
*F  IntrLe()  . . . . . . . . . . . . . . . . . . . . interpret <=-expression
**
**  'IntrEq', 'IntrNe', 'IntrLt', 'IntrGe', 'IntrGt',   and 'IntrLe' are  the
**  actions to interpret the respective operator expression.  They are called
**  by the reader *after* *both* operands are read.
*/
static void StackSwap(IntrState * intr)
{
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* push the operands in reverse order                                  */
    PushObj(intr, opR);
    PushObj(intr, opL);
}

void IntrEq(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeEq();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* compare them                                                        */
    val = (EQ( opL, opR ) ? True : False);

    /* push the result                                                     */
    PushObj(intr, val);
}

void IntrNe(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeNe();
        return;
    }


    /* '<left> <> <right>' is 'not <left> = <right>'                       */
    IntrEq(intr);
    IntrNot(intr);
}

void IntrLt(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeLt();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* compare them                                                        */
    val = (LT( opL, opR ) ? True : False);

    /* push the result                                                     */
    PushObj(intr, val);
}

void IntrGe(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeGe();
        return;
    }


    /* '<left> >= <right>' is 'not <left> < <right>'                       */
    IntrLt(intr);
    IntrNot(intr);
}

void IntrGt(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeGt();
        return;
    }


    /* '<left> > <right>' is '<right> < <left>'                            */
    StackSwap(intr);
    IntrLt(intr);
}

void IntrLe(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeLe();
        return;
    }


    /* '<left> <= <right>' is 'not <right> < <left>'                       */
    StackSwap(intr);
    IntrLt(intr);
    IntrNot(intr);
}


/****************************************************************************
**
*F  IntrIn()  . . . . . . . . . . . . . . . . . . . . interpret in-expression
**
**  'IntrIn'  is the action  to interpret an  in-expression.  It is called by
**  the reader *after* *both* operands are read.
*/
void IntrIn(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIn();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* perform the test                                                    */
    val = (IN( opL, opR ) ? True : False);

    /* push the result                                                     */
    PushObj(intr, val);
}


/****************************************************************************
**
*F  IntrSum() . . . . . . . . . . . . . . . . . . . .  interpret +-expression
*F  IntrAInv()  . . . . . . . . . . . . . . . .  interpret unary --expression
*F  IntrDiff()  . . . . . . . . . . . . . . . . . . .  interpret --expression
*F  IntrProd()  . . . . . . . . . . . . . . . . . . .  interpret *-expression
*F  IntrQuo() . . . . . . . . . . . . . . . . . . . .  interpret /-expression
*F  IntrMod()   . . . . . . . . . . . . . . . . . .  interpret mod-expression
*F  IntrPow() . . . . . . . . . . . . . . . . . . . .  interpret ^-expression
**
**  'IntrSum', 'IntrDiff',  'IntrProd',  'IntrQuo',  'IntrMod', and 'IntrPow'
**  are  the actions to interpret  the  respective operator expression.  They
**  are called by the reader *after* *both* operands are read.
*/
void IntrSum(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeSum();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* compute the sum                                                     */
    val = SUM( opL, opR );

    /* push the result                                                     */
    PushObj(intr, val);
}

void IntrAInv(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAInv();
        return;
    }


    /* get the operand                                                     */
    opL = PopObj(intr);

    /* compute the additive inverse                                        */
    val = AINV( opL );

    /* push the result                                                     */
    PushObj(intr, val);
}

void IntrDiff(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeDiff();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* compute the difference                                              */
    val = DIFF( opL, opR );

    /* push the result                                                     */
    PushObj(intr, val);
}

void IntrProd(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeProd();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* compute the product                                                 */
    val = PROD( opL, opR );

    /* push the result                                                     */
    PushObj(intr, val);
}

void IntrQuo(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeQuo();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* compute the quotient                                                */
    val = QUO( opL, opR );

    /* push the result                                                     */
    PushObj(intr, val);
}

void IntrMod(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeMod();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* compute the remainder                                               */
    val = MOD( opL, opR );

    /* push the result                                                     */
    PushObj(intr, val);
}

void IntrPow(IntrState * intr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodePow();
        return;
    }


    /* get the operands                                                    */
    opR = PopObj(intr);
    opL = PopObj(intr);

    /* compute the power                                                   */
    val = POW( opL, opR );

    /* push the result                                                     */
    PushObj(intr, val);
}


/****************************************************************************
**
*F  IntrIntExpr(<str>)  . . . . . . . .  interpret literal integer expression
**
**  'IntrIntExpr' is the action  to  interpret a literal  integer expression.
**  <str> is the integer as a (null terminated) C character string.
*/
void IntrIntExpr(IntrState * intr, Obj string, Char * str)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    
    Obj val = IntStringInternal(string, str);
    GAP_ASSERT(val != Fail);

    if (intr->coding > 0) {
        CodeIntExpr(val);
    }
    else {
        // push the integer value
        PushObj(intr, val);
    }
}


/****************************************************************************
**
*F  IntrFloatExpr(<str>)  . . . . . . . .  interpret literal float expression
**
**  'IntrFloatExpr' is the action  to  interpret a literal  float expression.
**  <str> is the float as a (null terminated) C character string.
*/

static Obj CONVERT_FLOAT_LITERAL_EAGER;

static Obj ConvertFloatLiteralEager(Obj str)
{
    Char * chars = (Char *)CHARS_STRING(str);
    UInt   len = GET_LEN_STRING(str);
    Char   mark = '\0';
    if (chars[len - 1] == '_') {
        SET_LEN_STRING(str, len - 1);
        chars[len - 1] = '\0';
    }
    else if (chars[len - 2] == '_') {
        mark = chars[len - 1];
        SET_LEN_STRING(str, len - 2);
        chars[len - 2] = '\0';
    }
    Obj res = CALL_2ARGS(CONVERT_FLOAT_LITERAL_EAGER, str, ObjsChar[(UInt)mark]);
    if (res == Fail)
        ErrorQuit("failed to convert float literal", 0, 0);
    return res;
}

void IntrFloatExpr(IntrState * intr, Obj string, Char * str)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (string == 0)
        string = MakeString(str);
    if (intr->coding > 0) {
        CodeFloatExpr(string);
        return;
    }

    PushObj(intr, ConvertFloatLiteralEager(string));
}


/****************************************************************************
**
*F   IntrIntObjExpr()  . . . . . . .  'interpret' a GAP small integer
**
**  'IntrIntObjExpr' is the action to 'interpret' a existing GAP small
**  integer. This is used for implementing constants.
*/
void IntrIntObjExpr(IntrState * intr, Obj val)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIntExpr(val);
        return;
    }


    /* push the value                                                      */
    PushObj(intr, val);
}

/****************************************************************************
**
*F  IntrTrueExpr()  . . . . . . . . . . . . interpret literal true expression
**
**  'IntrTrueExpr' is the action to interpret a literal true expression.
*/
void IntrTrueExpr(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeTrueExpr();
        return;
    }


    /* push the value                                                      */
    PushObj(intr, True);
}


/****************************************************************************
**
*F  IntrFalseExpr() . . . . . . . . . . .  interpret literal false expression
**
**  'IntrFalseExpr' is the action to interpret a literal false expression.
*/
void IntrFalseExpr(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFalseExpr();
        return;
    }


    /* push the value                                                      */
    PushObj(intr, False);
}


/****************************************************************************
**
*F  IntrTildeExpr()  . . . . . . . . . . . . interpret tilde expression
**
**  'IntrTildeExpr' is the action to interpret a tilde expression.
**
**  'Tilde' is the identifier for the operator '~', used in
**  expressions such as '[ [ 1, 2 ], ~[ 1 ] ]'.
**
*/
void IntrTildeExpr(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeTildeExpr();
        return;
    }

    if(! (STATE(Tilde)) ) {
        // this code should be impossible to reach, the parser won't allow us
        // to get here; but we leave it here out of paranoia
        ErrorQuit("'~' does not have a value here", 0, 0);
    }

    /* push the value                                                      */
    PushObj(intr, STATE(Tilde));
}


/****************************************************************************
**
*F  IntrCharExpr(<chr>) . . . . . . .  interpret literal character expression
**
**  'IntrCharExpr' is the action to interpret a literal character expression.
**  <chr> is the C character.
*/
void IntrCharExpr(IntrState * intr, Char chr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeCharExpr(chr);
        return;
    }


    /* push the value                                                      */
    PushObj(intr, ObjsChar[(UChar)chr]);
}


/****************************************************************************
**
*F  IntrPermCycle(<nr>) . . . . . .  interpret literal permutation expression
*F  IntrPerm(<nr>)  . . . . . . . .  interpret literal permutation expression
*/
static Obj GetFromStack(Obj cycle, Int j)
{
    IntrState * intr = (IntrState *)cycle;
    return PopObj(intr);
}

void IntrPermCycle(IntrState * intr, UInt nrx, UInt nrc)
{
    Obj                 perm;           /* permutation                     */
    UInt                m;              /* maximal entry in permutation    */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodePermCycle(nrx, nrc);
        return;
    }


    /* get the permutation (allocate for the first cycle)                  */
    if ( nrc == 1 ) {
        m = 0;
        perm = NEW_PERM4( 0 );
    }
    else {
        const UInt countObj = LEN_PLIST(intr->StackObj);
        m = INT_INTOBJ(ELM_LIST(intr->StackObj, countObj - nrx));
        perm = ELM_LIST(intr->StackObj, countObj - nrx - 1);
    }

    m = ScanPermCycle(perm, m, (Obj)intr, nrx, GetFromStack);

    /* push the permutation (if necessary, drop permutation first)         */
    if (nrc != 1) {
        PopObj(intr);
        PopObj(intr);
    }
    PushObj(intr, perm);
    PushObj(intr, INTOBJ_INT(m));
}

void IntrPerm(IntrState * intr, UInt nrc)
{
    Obj                 perm;           /* permutation, result             */
    UInt                m;              /* maximal entry in permutation    */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodePerm(nrc);
        return;
    }


    /* special case for identity permutation                               */
    if ( nrc == 0 ) {
        perm = NEW_PERM2( 0 );
    }

    /* otherwise                                                           */
    else {

        /* get the permutation and its maximal entry                       */
        m = INT_INTOBJ(PopObj(intr));
        perm = PopObj(intr);

        /* if possible represent the permutation with short entries        */
        TrimPerm(perm, m);
    }

    /* push the result                                                     */
    PushObj(intr, perm);
}


/****************************************************************************
**
*F  IntrListExprBegin(<top>)  . . . . . . . . . .  interpret list expr, begin
*F  IntrListExprBeginElm(<pos>) . . . . .  interpret list expr, begin element
*F  IntrListExprEndElm()  . . . . . . . . .  interpret list expr, end element
*F  IntrListExprEnd(<nr>,<range>,<top>,<tilde>) . .  interpret list expr, end
*/
void IntrListExprBegin(IntrState * intr, UInt top)
{
    Obj                 list;           /* new list                        */
    Obj                 old;            /* old value of '~'                */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeListExprBegin(top);
        return;
    }


    /* allocate the new list                                               */
    list = NewEmptyPlist();

    /* if this is an outmost list, save it for reference in '~'            */
    /* (and save the old value of '~' on the values stack)                 */
    if ( top ) {
        old = STATE(Tilde);
        if (old != 0) {
            PushObj(intr, old);
        }
        else {
            PushVoidObj(intr);
        }
        STATE(Tilde) = list;
    }

    /* push the list                                                       */
    PushObj(intr, list);
}

void IntrListExprBeginElm(IntrState * intr, UInt pos)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeListExprBeginElm(pos);
        return;
    }


    /* remember this position on the values stack                          */
    PushObj(intr, INTOBJ_INT(pos));
}

void IntrListExprEndElm(IntrState * intr)
{
    Obj                 list;           /* list that is currently made     */
    Obj                 pos;            /* position                        */
    UInt                p;              /* position, as a C integer        */
    Obj                 val;            /* value to assign into list       */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeListExprEndElm();
        return;
    }


    /* get the value                                                       */
    val = PopObj(intr);

    /* get the position                                                    */
    pos = PopObj(intr);
    p = INT_INTOBJ( pos );

    /* get the list                                                        */
    list = PopObj(intr);

    /* assign the element into the list                                    */
    ASS_LIST( list, p, val );

    /* push the list again                                                 */
    PushObj(intr, list);
}

void IntrListExprEnd(
    IntrState * intr, UInt nr, UInt range, UInt top, UInt tilde)
{
    Obj                 list;           /* the list, result                */
    Obj                 old;            /* old value of '~'                */
    Int                 low;            /* low value of range              */
    Int                 inc;            /* increment of range              */
    Int                 high;           /* high value of range             */
    Obj                 val;            /* temporary value                 */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeListExprEnd(nr, range, top, tilde);
        return;
    }


    /* if this was a top level expression, restore the value of '~'        */
    if ( top ) {
        list = PopObj(intr);
        old = PopVoidObj(intr);
        STATE(Tilde) = old;
        PushObj(intr, list);
    }

    /* if this was a range, convert the list to a range                    */
    if ( range ) {
        /* get the list                                                    */
        list = PopObj(intr);

        /* get the low value                                               */
        val = ELM_LIST( list, 1 );
        low = GetSmallIntEx("Range", val, "<first>");

        /* get the increment                                               */
        if ( nr == 3 ) {
            val = ELM_LIST( list, 2 );
            Int v = GetSmallIntEx("Range", val, "<second>");
            if ( v == low ) {
                ErrorQuit("Range: <second> must not be equal to <first> (%d)",
                          (Int)low, 0);
            }
            inc = v - low;
        }
        else {
            inc = 1;
        }

        /* get and check the high value                                    */
        val = ELM_LIST( list, LEN_LIST(list) );
        Int v = GetSmallIntEx("Range", val, "<last>");
        if ( (v - low) % inc != 0 ) {
            ErrorQuit(
                "Range: <last>-<first> (%d) must be divisible by <inc> (%d)",
                (Int)(v-low), (Int)inc );
        }
        high = v;

        /* if <low> is larger than <high> the range is empty               */
        if ( (0 < inc && high < low) || (inc < 0 && low < high) ) {
            list = NewEmptyPlist();
        }

        /* if <low> is equal to <high> the range is a singleton list       */
        else if ( low == high ) {
            list = NEW_PLIST( T_PLIST_CYC_SSORT, 1 );
            SET_LEN_PLIST( list, 1 );
            SET_ELM_PLIST( list, 1, INTOBJ_INT(low) );
        }

        /* else make the range                                             */
        else {
            /* length must be a small integer as well */
            if ((high-low) / inc >= INT_INTOBJ_MAX) {
                ErrorQuit("Range: the length of a range must be a small integer",
                           0, 0);
            }

            list = NEW_RANGE((high - low) / inc + 1, low, inc);
        }

        /* push the list again                                             */
        PushObj(intr, list);
    }
    else {
        /* give back unneeded memory */
        list = PopObj(intr);
        /* Might have transformed into another type of list */
        if (IS_PLIST(list)) {
            SHRINK_PLIST(list, LEN_PLIST(list));
        }
        PushObj(intr, list);
    }
}


/****************************************************************************
**
*F  IntrStringExpr(<str>) . . . . . . . . interpret literal string expression
*/
void IntrStringExpr(IntrState * intr, Obj string)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeStringExpr(string);
        return;
    }


    /* push the string, already newly created                              */
    PushObj(intr, string);
}

void IntrPragma(IntrState * intr, Obj pragma)
{
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodePragma( pragma );
    }
    else {
        // Push a void when interpreting
        PushVoidObj(intr);
    }
}

/****************************************************************************
**
*F  IntrRecExprBegin(<top>) . . . . . . . . . .  interpret record expr, begin
*F  IntrRecExprBeginElmName(<rnam>) . .  interpret record expr, begin element
*F  IntrRecExprBeginElmExpr() . . . . .  interpret record expr, begin element
*F  IntrRecExprEndElmExpr() . . . . . . .  interpret record expr, end element
*F  IntrRecExprEnd(<nr>,<top>,<tilde>)  . . . . .  interpret record expr, end
*/
void IntrRecExprBegin(IntrState * intr, UInt top)
{
    Obj                 record;         /* new record                      */
    Obj                 old;            /* old value of '~'                */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeRecExprBegin(top);
        return;
    }


    /* allocate the new record                                             */
    record = NEW_PREC( 0 );

    /* if this is an outmost record, save it for reference in '~'          */
    /* (and save the old value of '~' on the values stack)                 */
    if ( top ) {
        old = STATE(Tilde);
        if (old != 0) {
            PushObj(intr, old);
        }
        else {
            PushVoidObj(intr);
        }
        STATE(Tilde) = record;
    }

    /* push the record                                                     */
    PushObj(intr, record);
}

void IntrRecExprBeginElmName(IntrState * intr, UInt rnam)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeRecExprBeginElmName(rnam);
        return;
    }


    /* remember the name on the values stack                               */
    PushObj(intr, (Obj)rnam);
}

void IntrRecExprBeginElmExpr(IntrState * intr)
{
    UInt                rnam;           /* record name                     */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeRecExprBeginElmExpr();
        return;
    }


    /* convert the expression to a record name                             */
    rnam = RNamObj(PopObj(intr));

    /* remember the name on the values stack                               */
    PushObj(intr, (Obj)rnam);
}

void IntrRecExprEndElm(IntrState * intr)
{
    Obj                 record;         /* record that is currently made   */
    UInt                rnam;           /* name of record element          */
    Obj                 val;            /* value of record element         */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeRecExprEndElm();
        return;
    }


    /* get the value                                                       */
    val = PopObj(intr);

    /* get the record name                                                 */
    rnam = (UInt)PopObj(intr);

    /* get the record                                                      */
    record = PopObj(intr);

    /* assign the value into the record                                    */
    ASS_REC( record, rnam, val );

    /* push the record again                                               */
    PushObj(intr, record);
}

void IntrRecExprEnd(IntrState * intr, UInt nr, UInt top, UInt tilde)
{
    Obj                 record;         /* record that is currently made   */
    Obj                 old;            /* old value of '~'                */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeRecExprEnd(nr, top, tilde);
        return;
    }


    /* if this was a top level expression, restore the value of '~'        */
    if ( top ) {
        record = PopObj(intr);
        old = PopVoidObj(intr);
        STATE(Tilde) = old;
        PushObj(intr, record);
    }
}

/****************************************************************************
**
*F  IntrFuncCallOptionsBegin() . . . .. . . . . .  interpret options, begin
*F  IntrFuncCallOptionsBeginElmName(<rnam>).  interpret options, begin element
*F  IntrFuncCallOptionsBeginElmExpr() . .. .  interpret options, begin element
*F  IntrFuncCallOptionsEndElm() . . .. .  . .  interpret options, end element
*F  IntrFuncCallOptionsEndElmEmpty() .. .  . .  interpret options, end element
*F  IntrFuncCallOptionsEnd(<nr>)  . . . . . . . .  interpret options, end
**
**  The net effect of all of these is to leave a record object on the stack
**  where IntrFuncCallEnd can use it
*/
void IntrFuncCallOptionsBegin(IntrState * intr)
{
    Obj                 record;         /* new record                      */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFuncCallOptionsBegin();
        return;
    }


    /* allocate the new record                                             */
    record = NEW_PREC( 0 );
    /* push the record                                                     */
    PushObj(intr, record);
}

void IntrFuncCallOptionsBeginElmName(IntrState * intr, UInt rnam)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFuncCallOptionsBeginElmName(rnam);
        return;
    }


    /* remember the name on the values stack                               */
    PushObj(intr, (Obj)rnam);
}

void IntrFuncCallOptionsBeginElmExpr(IntrState * intr)
{
    UInt                rnam;           /* record name                     */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFuncCallOptionsBeginElmExpr();
        return;
    }


    /* convert the expression to a record name                             */
    rnam = RNamObj(PopObj(intr));

    /* remember the name on the values stack                               */
    PushObj(intr, (Obj)rnam);
}

void IntrFuncCallOptionsEndElm(IntrState * intr)
{
    Obj                 record;         /* record that is currently made   */
    UInt                rnam;           /* name of record element          */
    Obj                 val;            /* value of record element         */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFuncCallOptionsEndElm();
        return;
    }


    /* get the value                                                       */
    val = PopObj(intr);

    /* get the record name                                                 */
    rnam = (UInt)PopObj(intr);

    /* get the record                                                      */
    record = PopObj(intr);

    /* assign the value into the record                                    */
    ASS_REC( record, rnam, val );

    /* push the record again                                               */
    PushObj(intr, record);
}

void IntrFuncCallOptionsEndElmEmpty(IntrState * intr)
{
    Obj                 record;         /* record that is currently made   */
    UInt                rnam;           /* name of record element          */
    Obj                 val;            /* value of record element         */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFuncCallOptionsEndElmEmpty();
        return;
    }


    /* get the value                                                       */
    val = True;

    /* get the record name                                                 */
    rnam = (UInt)PopObj(intr);

    /* get the record                                                      */
    record = PopObj(intr);

    /* assign the value into the record                                    */
    ASS_REC( record, rnam, val );

    /* push the record again                                               */
    PushObj(intr, record);
}

void IntrFuncCallOptionsEnd(IntrState * intr, UInt nr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeFuncCallOptionsEnd(nr);
        return;
    }
}


/****************************************************************************
**
*F  IntrAssLVar(<lvar>) . . . . . . . . . . . . interpret assignment to local
*/
void IntrAssLVar(IntrState * intr, UInt lvar)
{
  Obj val;
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    if (intr->coding > 0)
        CodeAssLVar(lvar);

    /* Or in the break loop */
    else {
        val = PopObj(intr);
        ASS_LVAR(lvar, val);
        PushObj(intr, val);
    }
}

void IntrUnbLVar(IntrState * intr, UInt lvar)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    if (intr->coding > 0)
        CodeUnbLVar(lvar);

    /* or in the break loop */
    else {
        ASS_LVAR(lvar,0);
        PushVoidObj(intr);
    }
}


/****************************************************************************
**
*F  IntrRefLVar(<lvar>) . . . . . . . . . . . .  interpret reference to local
*/
void IntrRefLVar(IntrState * intr, UInt lvar)
{
  Obj val;
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    if (intr->coding > 0)
        CodeRefLVar(lvar);

    /* or in the break loop */

    else {
        val = OBJ_LVAR(lvar);
        if (val == 0) {
            ErrorMayQuit("Variable: '%g' must have an assigned value",
                         (Int)NAME_LVAR(lvar), 0);
        }
        PushObj(intr, val);
    }
}

void IntrIsbLVar(IntrState * intr, UInt lvar)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    if (intr->coding > 0)
        CodeIsbLVar(lvar);

    /* or debugging */
    else {
        PushObj(intr, OBJ_LVAR(lvar) != (Obj)0 ? True : False);
    }
}


/****************************************************************************
**
*F  IntrAssHVar(<hvar>) . . . . . . . . . . .  interpret assignment to higher
*/
void IntrAssHVar(IntrState * intr, UInt hvar)
{
  Obj val;
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    if (intr->coding > 0)
        CodeAssHVar(hvar);
    /* Or in the break loop */
    else {
        val = PopObj(intr);
        ASS_HVAR(hvar, val);
        PushObj(intr, val);
    }
}

void IntrUnbHVar(IntrState * intr, UInt hvar)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    if (intr->coding > 0)
        CodeUnbHVar(hvar);
    /* or debugging */
    else {
        ASS_HVAR(hvar, 0);
        PushVoidObj(intr);
    }
}


/****************************************************************************
**
*F  IntrRefHVar(<hvar>) . . . . . . . . . . . . interpret reference to higher
*/
void IntrRefHVar(IntrState * intr, UInt hvar)
{
  Obj val;
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    if (intr->coding > 0)
        CodeRefHVar(hvar);
    /* or debugging */
    else {
        val = OBJ_HVAR(hvar);
        while (val == 0) {
            ErrorMayQuit("Variable: '%g' must have an assigned value",
                         (Int)NAME_HVAR((UInt)(hvar)), 0);
        }
        PushObj(intr, val);
    }
}

void IntrIsbHVar(IntrState * intr, UInt hvar)
{
    /* ignore                                                              */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    /* otherwise must be coding                                            */
    if (intr->coding > 0)
        CodeIsbHVar(hvar);
    /* or debugging */
    else
        PushObj(intr, (OBJ_HVAR(hvar) != (Obj)0) ? True : False);
}


/****************************************************************************
**
*F  IntrAssDVar(<dvar>) . . . . . . . . . . . . interpret assignment to debug
*/

void IntrAssDVar(IntrState * intr, UInt dvar, UInt depth)
{
    Obj                 rhs;            /* right hand side                 */
    Obj                 context;

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding > 0) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> cannot be used here",
                   dvar >> MAX_FUNC_LVARS_BITS, dvar & MAX_FUNC_LVARS_MASK );
    }


    /* get the right hand side                                             */
    rhs = PopObj(intr);

    /* assign the right hand side                                          */
    context = STATE(ErrorLVars);
    while (depth--)
      context = PARENT_LVARS(context);
    ASS_HVAR_WITH_CONTEXT(context, dvar, rhs);

    /* push the right hand side again                                      */
    PushObj(intr, rhs);
}

void IntrUnbDVar(IntrState * intr, UInt dvar, UInt depth)
{
    Obj                 context;

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding > 0) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> cannot be used here",
                   dvar >> MAX_FUNC_LVARS_BITS, dvar & MAX_FUNC_LVARS_MASK );
    }

    /* assign the right hand side                                          */
    context = STATE(ErrorLVars);
    while (depth--)
      context = PARENT_LVARS(context);
    ASS_HVAR_WITH_CONTEXT(context, dvar, (Obj)0);

    /* push void                                                           */
    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrRefDVar(<dvar>) . . . . . . . . . . . .  interpret reference to debug
*/
void IntrRefDVar(IntrState * intr, UInt dvar, UInt depth)
{
    Obj                 val;            /* value, result                   */
    Obj                 context;

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding > 0) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> cannot be used here",
                   dvar >> MAX_FUNC_LVARS_BITS, dvar & MAX_FUNC_LVARS_MASK );
    }

    /* get and check the value                                             */
    context = STATE(ErrorLVars);
    while (depth--)
      context = PARENT_LVARS(context);
    val = OBJ_HVAR_WITH_CONTEXT(context, dvar);
    if ( val == 0 ) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> must have a value",
                   dvar >> MAX_FUNC_LVARS_BITS, dvar & MAX_FUNC_LVARS_MASK );
    }

    /* push the value                                                      */
    PushObj(intr, val);
}

void IntrIsbDVar(IntrState * intr, UInt dvar, UInt depth)
{
    Obj                 val;            /* value, result                   */
    Obj                 context;

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();

    if (intr->coding > 0) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> cannot be used here",
                   dvar >> MAX_FUNC_LVARS_BITS, dvar & MAX_FUNC_LVARS_MASK );
    }

    /* get the value                                                       */
    context = STATE(ErrorLVars);
    while (depth--)
      context = PARENT_LVARS(context);
    val = OBJ_HVAR_WITH_CONTEXT(context, dvar);

    /* push the value                                                      */
    PushObj(intr, val != 0 ? True : False);
}


/****************************************************************************
**
*F  IntrAssGVar(<gvar>) . . . . . . . . . . .  interpret assignment to global
*/
void IntrAssGVar(IntrState * intr, UInt gvar)
{
    Obj                 rhs;            /* right hand side                 */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssGVar(gvar);
        return;
    }


    /* get the right hand side                                             */
    rhs = PopObj(intr);

    /* assign the right hand side                                          */
    AssGVar( gvar, rhs );

    /* push the right hand side again                                      */
    PushObj(intr, rhs);
}

void IntrUnbGVar(IntrState * intr, UInt gvar)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeUnbGVar(gvar);
        return;
    }


    /* assign the right hand side                                          */
    AssGVar( gvar, (Obj)0 );

    /* push void                                                           */
    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrRefGVar(<gvar>) . . . . . . . . . . . . interpret reference to global
*/
void IntrRefGVar(IntrState * intr, UInt gvar)
{
    Obj                 val;            /* value, result                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeRefGVar(gvar);
        return;
    }


    /* get and check the value                                             */
    if ( (val = ValAutoGVar( gvar )) == 0 ) {
        ErrorQuit("Variable: '%g' must have a value", (Int)NameGVar(gvar), 0);
    }

    /* push the value                                                      */
    PushObj(intr, val);
}

void IntrIsbGVar(IntrState * intr, UInt gvar)
{
    Obj                 val;            /* value, result                   */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIsbGVar(gvar);
        return;
    }


    /* get the value                                                       */
    val = ValAutoGVar( gvar );

    /* push the value                                                      */
    PushObj(intr, val != 0 ? True : False);
}


/****************************************************************************
**
*F  IntrAssList() . . . . . . . . . . . . . .  interpret assignment to a list
*F  IntrAsssList()  . . . . . . . . . interpret multiple assignment to a list
*F  IntrAssListLevel(<level>) . . . . . interpret assignment to several lists
*F  IntrAsssListLevel(<level>)  . . intr multiple assignment to several lists
*/
void IntrAssList(IntrState * intr, Int narg)
{
    Obj                 list;           /* list                            */
    Obj                 pos;            /* position                        */
    Obj                 rhs;            /* right hand side                 */

    GAP_ASSERT(narg == 1 || narg == 2);

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssList(narg);
        return;
    }

    /* get the right hand side                                             */
    rhs = PopObj(intr);

    if (narg == 1) {
      /* get the position                                                  */
      pos = PopObj(intr);

      /* get the list (checking is done by 'ASS_LIST' or 'ASSB_LIST')      */
      list = PopObj(intr);

      /* assign to the element of the list                                 */
      if (IS_POS_INTOBJ(pos)) {
        ASS_LIST( list, INT_INTOBJ(pos), rhs );
      }
      else {
        ASSB_LIST(list, pos, rhs);
      }
    }
    else if (narg == 2) {
        Obj col = PopObj(intr);
        Obj row = PopObj(intr);
        list = PopObj(intr);

        ASS_MAT(list, row, col, rhs);
    }

    /* push the right hand side again                                      */
    PushObj(intr, rhs);
}


void IntrAsssList(IntrState * intr)
{
    Obj                 list;           /* list                            */
    Obj                 poss;           /* positions                       */
    Obj                 rhss;           /* right hand sides                */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAsssList();
        return;
    }


    /* get the right hand sides                                            */
    rhss = PopObj(intr);
    RequireDenseList("List Assignments", rhss);

    /* get and check the positions                                         */
    poss = PopObj(intr);
    CheckIsPossList("List Assignments", poss);
    RequireSameLength("List Assignments", rhss, poss);

    /* get the list (checking is done by 'ASSS_LIST')                      */
    list = PopObj(intr);

    /* assign to several elements of the list                              */
    ASSS_LIST( list, poss, rhss );

    /* push the right hand sides again                                     */
    PushObj(intr, rhss);
}

void IntrAssListLevel(IntrState * intr, Int narg, UInt level)
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */
    Obj ixs;
    Int i;

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssListLevel(narg, level);
        return;
    }

    /* get right hand sides (checking is done by 'AssListLevel')           */
    rhss = PopObj(intr);

    ixs = NEW_PLIST(T_PLIST, narg);
    for (i = narg; i > 0; i--) {
        /* get and check the position                                      */
        pos = PopObj(intr);
        SET_ELM_PLIST(ixs, i, pos);
        CHANGED_BAG(ixs);
    }
    SET_LEN_PLIST(ixs, narg);

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'AssListLevel')     */
    lists = PopObj(intr);

    /* assign the right hand sides to the elements of several lists        */
    AssListLevel( lists, ixs, rhss, level );

    /* push the assigned values again                                      */
    PushObj(intr, rhss);
}

void IntrAsssListLevel(IntrState * intr, UInt level)
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAsssListLevel(level);
        return;
    }


    /* get right hand sides (checking is done by 'AsssListLevel')          */
    rhss = PopObj(intr);

    /* get and check the positions                                         */
    poss = PopObj(intr);
    CheckIsPossList("List Assignments", poss);

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'AsssListLevel')    */
    lists = PopObj(intr);

    /* assign the right hand sides to several elements of several lists    */
    AsssListLevel( lists, poss, rhss, level );

    /* push the assigned values again                                      */
    PushObj(intr, rhss);
}

void IntrUnbList(IntrState * intr, Int narg)
{
    Obj                 list;           /* list                            */
    Obj                 pos;            /* position                        */

    GAP_ASSERT(narg == 1 || narg == 2);

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeUnbList(narg);
        return;
    }

    if (narg == 1) {
      /* get and check the position                                        */
      pos = PopObj(intr);

      /* get the list (checking is done by 'UNB_LIST' or 'UNBB_LIST')      */
      list = PopObj(intr);

      /* unbind the element                                                */
      if (IS_POS_INTOBJ(pos)) {
        UNB_LIST( list, INT_INTOBJ(pos) );
      }
      else {
        UNBB_LIST(list, pos);
      }
    }
    else if (narg == 2) {
        Obj col = PopObj(intr);
        Obj row = PopObj(intr);
        list = PopObj(intr);

        UNB_MAT(list, row, col);
    }

    /* push void                                                           */
    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrElmList() . . . . . . . . . . . . . . . interpret selection of a list
*F  IntrElmsList()  . . . . . . . . .  interpret multiple selection of a list
*F  IntrElmListLevel(<level>) . . . . .  interpret selection of several lists
*F  IntrElmsListLevel(<level>)  . .  intr multiple selection of several lists
*/
void IntrElmList(IntrState * intr, Int narg)
{
    Obj                 elm;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */

    GAP_ASSERT(narg == 1 || narg == 2);

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmList(narg);
        return;
    }

    if (narg == 1) {
      /* get the position                                                  */
      pos = PopObj(intr);

      /* get the list (checking is done by 'ELM_LIST')                     */
      list = PopObj(intr);

      /* get the element of the list                                       */
      if (IS_POS_INTOBJ(pos)) {
        elm = ELM_LIST( list, INT_INTOBJ( pos ) );
      }
      else {
        elm = ELMB_LIST( list, pos );
      }
    }
    else /*if (narg == 2)*/ {
        Obj col = PopObj(intr);
        Obj row = PopObj(intr);
        list = PopObj(intr);

        elm = ELM_MAT(list, row, col);
    }

    /* push the element                                                    */
    PushObj(intr, elm);
}

void IntrElmsList(IntrState * intr)
{
    Obj                 elms;           /* elements, result                */
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, right operand        */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmsList();
        return;
    }


    /* get and check the positions                                         */
    poss = PopObj(intr);
    CheckIsPossList("List Elements", poss);

    /* get the list (checking is done by 'ELMS_LIST')                      */
    list = PopObj(intr);

    /* select several elements from the list                               */
    elms = ELMS_LIST( list, poss );

    /* push the elements                                                   */
    PushObj(intr, elms);
}

void IntrElmListLevel(IntrState * intr, Int narg, UInt level)
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, right operand         */
    Obj ixs;
    Int i;

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmListLevel(narg, level);
        return;
    }

    /* get the positions */
    ixs = NEW_PLIST(T_PLIST, narg);
    for (i = narg; i > 0; i--) {
        pos = PopObj(intr);
        SET_ELM_PLIST(ixs, i, pos);
        CHANGED_BAG(ixs);
    }
    SET_LEN_PLIST(ixs, narg);

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'ElmListLevel')     */
    lists = PopObj(intr);

    /* select the elements from several lists (store them in <lists>)      */
    ElmListLevel( lists, ixs, level );

    /* push the elements                                                   */
    PushObj(intr, lists);
}

void IntrElmsListLevel(IntrState * intr, UInt level)
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* positions, right operand        */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmsListLevel(level);
        return;
    }


    /* get and check the positions                                         */
    poss = PopObj(intr);
    CheckIsPossList("List Elements", poss);

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'ElmsListLevel')    */
    lists = PopObj(intr);

    /* select several elements from several lists (store them in <lists>)  */
    ElmsListLevel( lists, poss, level );

    /* push the elements                                                   */
    PushObj(intr, lists);
}

void IntrIsbList(IntrState * intr, Int narg)
{
    Obj                 isb;            /* isbound, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */

    GAP_ASSERT(narg == 1 || narg == 2);

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIsbList(narg);
        return;
    }

    if (narg == 1) {
      /* get and check the position                                        */
      pos = PopObj(intr);

      /* get the list (checking is done by 'ISB_LIST' or 'ISBB_LIST')      */
      list = PopObj(intr);

      /* get the result                                                    */
      if (IS_POS_INTOBJ(pos)) {
        isb = ISB_LIST( list, INT_INTOBJ(pos) ) ? True : False;
      }
      else {
        isb = ISBB_LIST( list, pos ) ? True : False;
      }
    }
    else /*if (narg == 2)*/ {
        Obj col = PopObj(intr);
        Obj row = PopObj(intr);
        list = PopObj(intr);

        isb = ISB_MAT(list, row, col) ? True : False;
    }

    /* push the result                                                     */
    PushObj(intr, isb);
}


/****************************************************************************
**
*F  IntrAssRecName(<rnam>)  . . . . . . . .  interpret assignment to a record
*F  IntrAssRecExpr()  . . . . . . . . . . .  interpret assignment to a record
*/
void IntrAssRecName(IntrState * intr, UInt rnam)
{
    Obj                 record;         /* record, left operand            */
    Obj                 rhs;            /* rhs, right operand              */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssRecName(rnam);
        return;
    }


    /* get the right hand side                                             */
    rhs = PopObj(intr);

    /* get the record (checking is done by 'ASS_REC')                      */
    record = PopObj(intr);

    /* assign the right hand side to the element of the record             */
    ASS_REC( record, rnam, rhs );

    /* push the assigned value                                             */
    PushObj(intr, rhs);
}

void IntrAssRecExpr(IntrState * intr)
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssRecExpr();
        return;
    }


    /* get the right hand side                                             */
    rhs = PopObj(intr);

    /* get the name and convert it to a record name                        */
    rnam = RNamObj(PopObj(intr));

    /* get the record (checking is done by 'ASS_REC')                      */
    record = PopObj(intr);

    /* assign the right hand side to the element of the record             */
    ASS_REC( record, rnam, rhs );

    /* push the assigned value                                             */
    PushObj(intr, rhs);
}

void IntrUnbRecName(IntrState * intr, UInt rnam)
{
    Obj                 record;         /* record, left operand            */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeUnbRecName(rnam);
        return;
    }


    /* get the record (checking is done by 'UNB_REC')                      */
    record = PopObj(intr);

    /* assign the right hand side to the element of the record             */
    UNB_REC( record, rnam );

    /* push void                                                           */
    PushVoidObj(intr);
}

void IntrUnbRecExpr(IntrState * intr)
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeUnbRecExpr();
        return;
    }


    /* get the name and convert it to a record name                        */
    rnam = RNamObj(PopObj(intr));

    /* get the record (checking is done by 'UNB_REC')                      */
    record = PopObj(intr);

    /* assign the right hand side to the element of the record             */
    UNB_REC( record, rnam );

    /* push void                                                           */
    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrElmRecName(<rnam>)  . . . . . . . . . interpret selection of a record
*F  IntrElmRecExpr()  . . . . . . . . . . . . interpret selection of a record
*/
void IntrElmRecName(IntrState * intr, UInt rnam)
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmRecName(rnam);
        return;
    }


    /* get the record (checking is done by 'ELM_REC')                      */
    record = PopObj(intr);

    /* select the element of the record                                    */
    elm = ELM_REC( record, rnam );

    /* push the element                                                    */
    PushObj(intr, elm);
}

void IntrElmRecExpr(IntrState * intr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmRecExpr();
        return;
    }


    /* get the name and convert it to a record name                        */
    rnam = RNamObj(PopObj(intr));

    /* get the record (checking is done by 'ELM_REC')                      */
    record = PopObj(intr);

    /* select the element of the record                                    */
    elm = ELM_REC( record, rnam );

    /* push the element                                                    */
    PushObj(intr, elm);
}

void IntrIsbRecName(IntrState * intr, UInt rnam)
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIsbRecName(rnam);
        return;
    }


    /* get the record (checking is done by 'ISB_REC')                      */
    record = PopObj(intr);

    /* get the result                                                      */
    isb = (ISB_REC( record, rnam ) ? True : False);

    /* push the result                                                     */
    PushObj(intr, isb);
}

void IntrIsbRecExpr(IntrState * intr)
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIsbRecExpr();
        return;
    }


    /* get the name and convert it to a record name                        */
    rnam = RNamObj(PopObj(intr));

    /* get the record (checking is done by 'ISB_REC')                      */
    record = PopObj(intr);

    /* get the result                                                      */
    isb = (ISB_REC( record, rnam ) ? True : False);

    /* push the result                                                     */
    PushObj(intr, isb);
}


/****************************************************************************
**
*F  IntrAssPosObj() . . . . . . . . . . . .  interpret assignment to a posobj
*/
void IntrAssPosObj(IntrState * intr)
{
    Obj                 posobj;         // posobj
    Obj                 pos;            /* position                        */
    Int                 p;              /* position, as a C integer        */
    Obj                 rhs;            /* right hand side                 */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssPosObj();
        return;
    }


    /* get the right hand side                                             */
    rhs = PopObj(intr);

    /* get and check the position                                          */
    pos = PopObj(intr);
    p = GetPositiveSmallIntEx("PosObj Assignment", pos, "<position>");

    // get the posobj (checking is done by 'AssPosObj')
    posobj = PopObj(intr);

    // assign to the element of the posobj
    AssPosObj(posobj, p, rhs);

    /* push the right hand side again                                      */
    PushObj(intr, rhs);
}

void IntrUnbPosObj(IntrState * intr)
{
    Obj                 posobj;         // posobj
    Obj                 pos;            /* position                        */
    Int                 p;              /* position, as a C integer        */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeUnbPosObj();
        return;
    }


    /* get and check the position                                          */
    pos = PopObj(intr);
    p = GetPositiveSmallIntEx("PosObj Assignment", pos, "<position>");

    // get the posobj (checking is done by 'UnbPosObj')
    posobj = PopObj(intr);

    /* unbind the element                                                  */
    UnbPosObj(posobj, p);

    /* push void                                                           */
    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrElmPosObj() . . . . . . . . . . . . . interpret selection of a posobj
*/
void IntrElmPosObj(IntrState * intr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 posobj;         // posobj, left operand
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmPosObj();
        return;
    }


    /* get and check the position                                          */
    pos = PopObj(intr);
    p = GetPositiveSmallIntEx("PosObj Element", pos, "<position>");

    // get the posobj (checking is done by 'ElmPosObj')
    posobj = PopObj(intr);

    // get the element of the posobj
    elm = ElmPosObj(posobj, p);

    /* push the element                                                    */
    PushObj(intr, elm);
}

void IntrIsbPosObj(IntrState * intr)
{
    Obj                 isb;            /* isbound, result                 */
    Obj                 posobj;         // posobj, left operand
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIsbPosObj();
        return;
    }


    /* get and check the position                                          */
    pos = PopObj(intr);
    p = GetPositiveSmallIntEx("PosObj Element", pos, "<position>");

    // get the posobj (checking is done by 'IsbPosObj')
    posobj = PopObj(intr);

    /* get the result                                                      */
    isb = IsbPosObj(posobj, p) ? True : False;

    /* push the result                                                     */
    PushObj(intr, isb);
}


/****************************************************************************
**
*F  IntrAssComObjName(<rnam>) . . . . . . .  interpret assignment to a comobj
*F  IntrAssComObjExpr() . . . . . . . . . .  interpret assignment to a comobj
*/
void IntrAssComObjName(IntrState * intr, UInt rnam)
{
    Obj                 comobj;         // comobj, left operand
    Obj                 rhs;            /* rhs, right operand              */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssComObjName(rnam);
        return;
    }


    /* get the right hand side                                             */
    rhs = PopObj(intr);

    // get the comobj (checking is done by 'AssComObj')
    comobj = PopObj(intr);

    // assign the right hand side to the element of the comobj
    AssComObj(comobj, rnam, rhs);

    /* push the assigned value                                             */
    PushObj(intr, rhs);
}

void IntrAssComObjExpr(IntrState * intr)
{
    Obj                 comobj;         // comobj, left operand
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssComObjExpr();
        return;
    }


    /* get the right hand side                                             */
    rhs = PopObj(intr);

    // get the name and convert it to a comobj name
    rnam = RNamObj(PopObj(intr));

    // get the comobj (checking is done by 'AssComObj')
    comobj = PopObj(intr);

    // assign the right hand side to the element of the comobj
    AssComObj(comobj, rnam, rhs);

    /* push the assigned value                                             */
    PushObj(intr, rhs);
}

void IntrUnbComObjName(IntrState * intr, UInt rnam)
{
    Obj                 comobj;         // comobj, left operand

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeUnbComObjName(rnam);
        return;
    }


    // get the comobj (checking is done by 'UnbComObj')
    comobj = PopObj(intr);

    // unbind the element of the comobj
    UnbComObj(comobj, rnam);

    /* push void                                                           */
    PushVoidObj(intr);
}

void IntrUnbComObjExpr(IntrState * intr)
{
    Obj                 comobj;         // comobj, left operand
    UInt                rnam;           /* name, left operand              */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeUnbComObjExpr();
        return;
    }


    // get the name and convert it to a comobj name
    rnam = RNamObj(PopObj(intr));

    // get the comobj (checking is done by 'UnbComObj')
    comobj = PopObj(intr);

    // unbind the element of the comobj
    UnbComObj(comobj, rnam);

    /* push void                                                           */
    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrElmComObjName(<rnam>) . . . . . . . . interpret selection of a comobj
*F  IntrElmComObjExpr() . . . . . . . . . . . interpret selection of a comobj
*/
void IntrElmComObjName(IntrState * intr, UInt rnam)
{
    Obj                 elm;            /* element, result                 */
    Obj                 comobj;         // the comobj, left operand

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmComObjName(rnam);
        return;
    }

    // get the comobj (checking is done by 'ElmComObj')
    comobj = PopObj(intr);

    // select the element of the comobj
    elm = ElmComObj(comobj, rnam);

    /* push the element                                                    */
    PushObj(intr, elm);
}

void IntrElmComObjExpr(IntrState * intr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 comobj;         // the comobj, left operand
    UInt                rnam;           /* the name, right operand         */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeElmComObjExpr();
        return;
    }

    // get the name and convert it to a comobj name
    rnam = RNamObj(PopObj(intr));

    // get the comobj (checking is done by 'ElmComObj')
    comobj = PopObj(intr);

    // select the element of the comobj
    elm = ElmComObj(comobj, rnam);

    /* push the element                                                    */
    PushObj(intr, elm);
}

void IntrIsbComObjName(IntrState * intr, UInt rnam)
{
    Obj                 isb;            /* element, result                 */
    Obj                 comobj;         // the comobj, left operand

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIsbComObjName(rnam);
        return;
    }

    // get the comobj (checking is done by 'IsbComObj')
    comobj = PopObj(intr);

    /* get the result                                                      */
    isb = IsbComObj(comobj, rnam) ? True : False;

    /* push the result                                                     */
    PushObj(intr, isb);
}

void IntrIsbComObjExpr(IntrState * intr)
{
    Obj                 isb;            /* element, result                 */
    Obj                 comobj;         // the comobj, left operand
    UInt                rnam;           /* the name, right operand         */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeIsbComObjExpr();
        return;
    }

    // get the name and convert it to a comobj name
    rnam = RNamObj(PopObj(intr));

    // get the comobj (checking is done by 'IsbComObj')
    comobj = PopObj(intr);

    /* get the result                                                      */
    isb = IsbComObj(comobj, rnam) ? True : False;

    /* push the result                                                     */
    PushObj(intr, isb);
}

/****************************************************************************
**
*F  IntrEmpty() . . . . . . . . . . . . .  Interpret an empty statement body
**
*/

void IntrEmpty(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeEmpty();
        return;
    }


    /* interpret */
    PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrInfoBegin() . . . . . . . . .  start interpretation of Info statement
*F  IntrInfoMiddle()  . . . . . .  shift to interpreting printable statements
*F  IntrInfoEnd( <narg> ) . . Info statement complete, <narg> things to print
*V  InfoDecision . . . . . . . . . . .  fopy of the InfoDecision GAP function
**
**  These are the actions which are used to interpret an Info statement:
**
**  IntrInfoBegin is called after the Info is read
**
**  IntrInfoMiddle is called after reading two arguments, because we can
**  now decide whether we should evaluate or ignore the remaining arguments
**
**  IntrInfoEnd is called when the closing ')' is detected and should
**  trigger the actual printing, if needed. The argument is the number of
**  things to print
*/


void IntrInfoBegin(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeInfoBegin();
        return;
    }
}


void IntrInfoMiddle(IntrState * intr)
{
    Obj selectors;   /* first argument of Info */
    Obj level;       /* second argument of Info */
    Obj selected;    /* GAP Boolean answer to whether this message
                        gets printed or not */

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    if (intr->ignoring > 0) {
        intr->ignoring++;
        return;
    }
    if (intr->coding > 0) {
        CodeInfoMiddle();
        return;
    }


    level = PopObj(intr);
    selectors = PopObj(intr);

    selected = InfoCheckLevel(selectors, level);

    if (selected == False)
        intr->ignoring = 1;
    else {
        PushObj(intr, selectors);
        PushObj(intr, level);
    }
}

void IntrInfoEnd(IntrState * intr, UInt narg)
{
    Obj args; /* gathers up the arguments to be printed */

    /* ignore or code                                                      */
    INTERPRETER_PROFILE_HOOK(intr, 1);
    SKIP_IF_RETURNING_NO_PROFILE_HOOK();

    if (intr->ignoring > 1) {
        intr->ignoring--;
        return;
    }
    if (intr->coding > 0) {
        CodeInfoEnd(narg);
        return;
    }

    /* print if necessary                                                  */
    if (intr->ignoring > 0)
        intr->ignoring--;
    else {
        args = NEW_PLIST(T_PLIST, narg);
        SET_LEN_PLIST(args, narg);
        while (narg > 0)
            SET_ELM_PLIST(args, narg--, PopObj(intr));

        Obj level = PopObj(intr);
        Obj selectors = PopObj(intr);

        InfoDoPrint(selectors, level, args);
    }

    /* If we actually executed this statement at all
       (even if we printed nothing) then return a Void */
    if (intr->ignoring == 0)
        PushVoidObj(intr);
}


/****************************************************************************
**
*F  IntrAssertBegin()  . . . . . . . start interpretation of Assert statement
*F  IntrAssertAfterLevel() . .  called after the first argument has been read
**
**  At this stage, we can decide whether to evaluate the second argument --
**   the check in question
**
*F  IntrAssertAfterCondition() called after the second argument has been read
**
**  At this point we know whether there is an assertion failure. We still
**  need to read the third argument if any, to decide what to do about it;
**  one of:
**
*F  IntrAssertEnd2Args() . . . . called after reading the closing parenthesis
*F  IntrAssertEnd3Args() . . . . called after reading the closing parenthesis
**
**
**  intr->ignoring is increased by (a total of) 2 if an assertion either
**  is not tested (because we were Ignoring when we got to it, or due to
**  level) or is tested and passes
*/

void IntrAssertBegin(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    SKIP_IF_IGNORING();
    if (intr->coding > 0) {
        CodeAssertBegin();
        return;
    }
}


void IntrAssertAfterLevel(IntrState * intr)
{
    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    if (intr->ignoring > 0) {
        intr->ignoring++;
        return;
    }
    if (intr->coding > 0) {
        CodeAssertAfterLevel();
        return;
    }


    Int level = GetSmallIntEx("Assert", PopObj(intr), "<lev>");

    if (STATE(CurrentAssertionLevel) < level)
        intr->ignoring = 1;
}

void IntrAssertAfterCondition(IntrState * intr)
{
    Obj condition;

    /* ignore or code                                                      */
    SKIP_IF_RETURNING();
    if (intr->ignoring > 0) {
        intr->ignoring++;
        return;
    }
    if (intr->coding > 0) {
        CodeAssertAfterCondition();
        return;
    }


    condition = PopObj(intr);

    if (condition == True)
        intr->ignoring = 2;
    else if (condition != False)
        RequireArgumentEx("Assert", condition, "<cond>",
                          "must be 'true' or 'false'");
}

void IntrAssertEnd2Args(IntrState * intr)
{
    /* ignore or code                                                      */
    INTERPRETER_PROFILE_HOOK(intr, 2);
    SKIP_IF_RETURNING_NO_PROFILE_HOOK();
    if (intr->ignoring > 2) {
        intr->ignoring -= 2;
        return;
    }
    if (intr->coding > 0) {
        CodeAssertEnd2Args();
        return;
    }


    if (intr->ignoring == 0)
        AssertionFailure();
    else
        intr->ignoring -= 2;

    GAP_ASSERT(intr->ignoring == 0);
    PushVoidObj(intr);
}


void IntrAssertEnd3Args(IntrState * intr)
{
    Obj message;
    /* ignore or code                                                      */
    INTERPRETER_PROFILE_HOOK(intr, 2);
    SKIP_IF_RETURNING_NO_PROFILE_HOOK();
    if (intr->ignoring > 2) {
        intr->ignoring -= 2;
        return;
    }
    if (intr->coding > 0) {
        CodeAssertEnd3Args();
        return;
    }


    if (intr->ignoring == 0) {
        message = PopVoidObj(intr);
        if (message != (Obj)0) {
            if (IS_STRING_REP(message))
                PrintString1(message);
            else
                PrintObj(message);
        }
    }
    else
        intr->ignoring -= 2;

    GAP_ASSERT(intr->ignoring == 0);
    PushVoidObj(intr);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    InitGlobalBag( &STATE(ErrorLVars), "STATE(ErrorLVars)"         );

    /* Ensure that the value in '~' does not get garbage collected         */
    InitGlobalBag( &STATE(Tilde), "STATE(Tilde)" );

    InitGlobalBag( &VoidReturnMarker, "VoidReturnMarker");

    // Create a bag which is not used anywhere else
    VoidReturnMarker = NEW_STRING(0);

    InitFopyGVar( "CONVERT_FLOAT_LITERAL_EAGER", &CONVERT_FLOAT_LITERAL_EAGER);


    /* The work of handling Options is also delegated*/
    ImportFuncFromLibrary( "PushOptions", &PushOptions );
    ImportFuncFromLibrary( "PopOptions",  &PopOptions  );

    return 0;
}


/****************************************************************************
**
*F  InitInfoIntrprtr()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "intrprtr",
    .initKernel = InitKernel,
};

StructInitInfo * InitInfoIntrprtr(void)
{
    return &module;
}
