/****************************************************************************
**
*A  intrprtr.c                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of the immediate interpreter package.
**
**  The immediate interpreter package  is  the part  of the interpreter  that
**  interprets code immediately (while it is read).  Its functions are called
**  from the reader.  When it encounters  constructs that it cannot interpret
**  immediately, it switches into coding mode, and  delegates the work to the
**  coder.
*/
char *          Revision_intrprtr_c =
   "@(#)$Id$";

#include        <assert.h>              /* assert                          */

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* Tilde, VAL_GVAR, AssGVar        */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* generic operations              */
#include        "records.h"             /* generic records                 */
#include        "lists.h"               /* generic lists                   */

#include        "bool.h"                /* True, False                     */

#include        "permutat.h"            /* NEW_PERM2, ADDR_PERM2, ...      */

#include        "precord.h"             /* NEW_PREC, InPRec                */

#include        "plist.h"               /* SET_LEN_PLIST, SET_ELM_PLIST    */
#include        "range.h"               /* NEW_RANGE, SET_LEN_RANGE,    ...*/
#include        "string.h"              /* ObjsChar, NEW_STRING, CSTR_ST...*/

#include        "code.h"                /* CodeBegin, CodeEnd, ...         */
#include        "vars.h"                /* ??? */
#include        "funcs.h"               /* ExecBegin, ExecEnd              */

#define INCLUDE_DECLARATION_PART
#include        "intrprtr.h"            /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*V  IntrResult  . . . . . . . . . . . . . . . . . result value of interpreter
**
**  'IntrResult'  is the result value of  the interpreter, i.e., the value of
**  the  statement  that  was  last  interpreted (which   might  have been  a
**  return-value-statement).
*/
Obj IntrResult;


/****************************************************************************
**
*V  IntrReturning   . . . . . . . . . . .  interpreter is currently returning
**
**  If 'IntrReturning' is  non-zero, the interpreter is currently  returning.
**  The interpreter switches  to this mode when  it finds a return-statement.
**  If it interpretes a return-value-statement, it sets 'IntrReturning' to 1.
**  If it interpretes a return-void-statement,  it sets 'IntrReturning' to 2.
**  If it interpretes a quit-statement, it sets 'IntrReturning' to 8.
*/
UInt IntrReturning;


/****************************************************************************
**
*V  IntrIgnoring  . . . . . . . . . interpreter is currently ignoring actions
**
**  If 'IntrIgnoring'  is  non-zero,  the interpreter  is  currently ignoring
**  actions.  The interpreter switches to this mode for  the right operand of
**  'or' and 'and'  constructs where the  left operand already determines the
**  outcome.
**
**  This mode is also used in Info and Assert, when arguments are not printed. 
*/
UInt IntrIgnoring;


/****************************************************************************
**
*V  IntrCoding  . . . . . . . . . . . interpreter is currently coding actions
**
**  If 'IntrCoding' is non-zero, the interpreter is currently coding actions.
**  The interpreter  switches  to this  mode for  constructs  that it  cannot
**  directly interpret, such as loops or function bodies.
*/
UInt IntrCoding;


/****************************************************************************
**
*F  StackObj  . . . . . . . . . . . . . . . . . . . . . . . . .  values stack
*F  CountObj  . . . . . . . . . . . . . . . . . number of values on the stack
*F  PushObj(<val>)  . . . . . . . . . . . . . . . . push value onto the stack
*F  PushVoidObj() . . . . . . . . . . . . . .  push void value onto the stack
*F  PopObj()  . . . . . . . . . . . . . . . . . . .  pop value from the stack
*F  PopVoidObj()  . . . . . . . . . . . . . . . . .  pop value from the stack
**
**  'StackObj' is the stack of values.
**
**  'CountObj' is the number of values currently on the values stack.
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
**
**  Since interpreters  can nest, there can   be more than one  values stack.
**  The bottom  two  elements of each values  stack  are the  'StackObj'  and
**  'CountObj' there were active when the current interpreter was started and
**  which will be made active again when the current interpreter will stop.
*/
Obj             IntrState;

Obj             StackObj;

Int             CountObj;

void            PushObj (
    Obj                 val )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( StackObj != 0 );
    assert( 0 <= CountObj && CountObj == LEN_PLIST(StackObj) );
    assert( val != 0 );

    /* count up and put the value onto the stack                           */
    CountObj++;
    GROW_PLIST(    StackObj, CountObj );
    SET_LEN_PLIST( StackObj, CountObj );
    SET_ELM_PLIST( StackObj, CountObj, val );
    CHANGED_BAG(   StackObj );
}

void            PushVoidObj ( void )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( StackObj != 0 );
    assert( 0 <= CountObj && CountObj == LEN_PLIST(StackObj) );

    /* count up and put the void value onto the stack                      */
    CountObj++;
    GROW_PLIST(    StackObj, CountObj );
    SET_LEN_PLIST( StackObj, CountObj );
    SET_ELM_PLIST( StackObj, CountObj, (Obj)0 );
}

Obj             PopObj ( void )
{
    Obj                 val;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    assert( StackObj != 0 );
    assert( 1 <= CountObj && CountObj == LEN_LIST(StackObj) );

    /* get the top element from the stack and count down                   */
    val = ELM_PLIST( StackObj, CountObj );
    SET_ELM_PLIST( StackObj, CountObj, 0 );
    SET_LEN_PLIST( StackObj, CountObj-1  );
    CountObj--;

    /* return the popped value (which must be non-void)                    */
    assert( val != 0 );
    return val;
}

Obj             PopVoidObj ( void )
{
    Obj                 val;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    assert( StackObj != 0 );
    assert( 1 <= CountObj && CountObj == LEN_LIST(StackObj) );

    /* get the top element from the stack and count down                   */
    val = ELM_PLIST( StackObj, CountObj );
    SET_ELM_PLIST( StackObj, CountObj, 0 );
    SET_LEN_PLIST( StackObj, CountObj-1  );
    CountObj--;

    /* return the popped value (which may be void)                         */
    return val;
}


/****************************************************************************
**
*F  IntrBegin() . . . . . . . . . . . . . . . . . . . .  start an interpreter
*F  IntrEnd(<error>)  . . . . . . . . . . . . . . . . . . stop an interpreter
**
**  'IntrBegin' starts a new interpreter.
**
**  'IntrEnd(<error>)' stops the current interpreter.
**
**  If <error>  is non-zero a  syntax error was found by  the reader, and the
**  interpreter only clears up the mess.
**
**  If 'IntrEnd' returns  0, then no  return-statement or quit-statement  was
**  interpreted.  If  'IntrEnd' returns 1,  then a return-value-statement was
**  interpreted and in this case the  return value is stored in 'IntrResult'.
**  If  'IntrEnd' returns 2, then a  return-void-statement  was  interpreted.
**  If 'IntrEnd' returns 8, then a quit-statement was interpreted.
*/
void            IntrBegin ( void )
{
    Obj                 intrState;      /* old interpreter state           */

    /* remember old interpreter state                                      */
    intrState = NewBag( T_PLIST, 4*sizeof(Obj) );
    ADDR_OBJ(intrState)[0] = (Obj)3;
    ADDR_OBJ(intrState)[1] = IntrState;
    ADDR_OBJ(intrState)[2] = StackObj;
    ADDR_OBJ(intrState)[3] = INTOBJ_INT(CountObj);
    IntrState = intrState;

    /* allocate a new values stack                                         */
    StackObj = NEW_PLIST( T_PLIST, 64 );
    SET_LEN_PLIST( StackObj, 0 );
    CountObj = 0;

    /* must be in immediate (non-ignoring, non-coding) mode                */
    assert( IntrIgnoring == 0 );
    assert( IntrCoding   == 0 );

    /* no return-statement was yet interpreted                             */
    IntrReturning = 0;

    /* start an execution environment                                      */
    ExecBegin();
}

Int             IntrEnd (
    UInt                error )
{
    UInt                intrReturning;  /* interpreted return-statement?   */

    /* if everything went fine                                             */
    if ( ! error ) {

        /* leave the execution environment                                 */
        ExecEnd( 0UL );

        /* remember whether the interpreter interpreted a return-statement */
        intrReturning = IntrReturning;
        IntrReturning = 0;
        
        /* must be back in immediate (non-ignoring, non-coding) mode       */
        assert( IntrIgnoring == 0 );
        assert( IntrCoding   == 0 );

        /* and the stack must contain the result value (which may be void) */
        if ( CompNowFuncs == 0 ) {
            assert( CountObj == 1 );
            IntrResult = PopVoidObj();
        }
        else {
            IntrResult = 0;
        }

        /* switch back to the old state                                    */
        CountObj  = INT_INTOBJ( ADDR_OBJ(IntrState)[3] );
        StackObj  = ADDR_OBJ(IntrState)[2];
        IntrState = ADDR_OBJ(IntrState)[1];

    }

    /* otherwise clean up the mess                                         */
    else {

        /* leave the execution environment                                 */
        ExecEnd( 1UL );

        /* clean up the coder too                                          */
        if ( IntrCoding > 0 ) { CodeEnd( 1UL ); }

        /* remember that we had an error                                   */
        intrReturning = 32;
        IntrReturning = 0;

        /* must be back in immediate (non-ignoring, non-coding) mode       */
        IntrIgnoring = 0;
        IntrCoding   = 0;

        /* dummy result value (probably ignored)                           */
        IntrResult = (Obj)0;

        /* switch back to the old state                                    */
        CountObj  = INT_INTOBJ( ADDR_OBJ(IntrState)[3] );
        StackObj  = ADDR_OBJ(IntrState)[2];
        IntrState = ADDR_OBJ(IntrState)[1];

    }

    /* indicate whether a return-statement was interpreted                 */
    return intrReturning;
}


/****************************************************************************
**
*F  IntrFuncCallBegin() . . . . . . . . . . .  interpret function call, begin
*F  IntrFuncCallEnd(<funccall>,<nr>)  . . . . .  interpret function call, end
**
**  'IntrFuncCallBegin' is an action  to  interpret a  function call.  It  is
**  called by  the reader  when  it  encounters  the parenthesis  '(',  i.e.,
**  *after* the function expression is read.
**
**  'IntrFuncCallEnd'  is an  action to  interpret  a  function call.   It is
**  called by    the reader when it encounters     the parenthesis ')', i.e.,
**  *after* the argument expressions are read.  <funccall>  is 1 if this is a
**  function call, and 0 if this is a procedure call.  <nr>  is the number of
**  arguments.
*/
void            IntrFuncCallBegin ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeFuncCallBegin(); return; }
    if ( CompNowFuncs != 0 ) { return; }
}

void            IntrFuncCallEnd (
    UInt                funccall,
    UInt                nr )
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
    UInt                i;              /* loop variable                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeFuncCallEnd( funccall, nr ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the arguments from the stack                                    */
    a1 = a2 = a3 = a4 = a5 = a6 = args = 0;
    if ( nr <= 6 ) {
        if ( 6 <= nr ) { a6 = PopObj(); }
        if ( 5 <= nr ) { a5 = PopObj(); }
        if ( 4 <= nr ) { a4 = PopObj(); }
        if ( 3 <= nr ) { a3 = PopObj(); }
        if ( 2 <= nr ) { a2 = PopObj(); }
        if ( 1 <= nr ) { a1 = PopObj(); }
    }
    else {
        args = NEW_PLIST( T_PLIST, nr );
        SET_LEN_PLIST( args, nr );
        for ( i = nr; 1 <= i; i-- ) {
            argi = PopObj();
            SET_ELM_PLIST( args, i, argi );
        }
    }

    /* get and check the function from the stack                           */
    func = PopObj();
    if ( TYPE_OBJ(func) != T_FUNCTION ) {
        ErrorQuit(
            "<func> must be a function (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(func)].name), 0L );
    }

    /* call the function                                                   */
    if      ( 0 == nr ) { val = CALL_0ARGS( func ); }
    else if ( 1 == nr ) { val = CALL_1ARGS( func, a1 ); }
    else if ( 2 == nr ) { val = CALL_2ARGS( func, a1, a2 ); }
    else if ( 3 == nr ) { val = CALL_3ARGS( func, a1, a2, a3 ); }
    else if ( 4 == nr ) { val = CALL_4ARGS( func, a1, a2, a3, a4 ); }
    else if ( 5 == nr ) { val = CALL_5ARGS( func, a1, a2, a3, a4, a5 ); }
    else if ( 6 == nr ) { val = CALL_6ARGS( func, a1, a2, a3, a4, a5, a6 ); }
    else                { val = CALL_XARGS( func, args ); }

    /* check the return value                                              */
    if ( funccall && val == 0 ) {
        ErrorQuit(
            "Function call: <func> must return a value",
            0L, 0L );
    }

    /* push the value onto the stack                                       */
    if ( val == 0 )
        PushVoidObj();
    else
        PushObj( val );
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
void            IntrFuncExprBegin (
    Int                 narg,
    Int                 nloc,
    Obj                 nams )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) {
        IntrCoding++;
        CodeFuncExprBegin( narg, nloc, nams );
        return;
    }

    /* switch to coding mode now                                           */
    CodeBegin();
    IntrCoding = 1;

    /* code a function expression                                          */
    CodeFuncExprBegin( narg, nloc, nams );
}

void            IntrFuncExprEnd (
    UInt                nr,
    UInt                mapsto )
{
    Obj                 func;           /* the function, result            */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 1 ) {
        IntrCoding--;
        CodeFuncExprEnd( nr, mapsto );
        return;
    }

    /* must be coding                                                      */
    assert( IntrCoding > 0 );

    /* code a function expression                                          */
    CodeFuncExprEnd( nr, mapsto );

    /* switch back to immediate mode, get the function                     */
    CodeEnd( 0 );
    IntrCoding = 0;
    func = CodeResult;

    /* push the function                                                   */
    PushObj( func );
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
void            IntrIfBegin ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { IntrIgnoring++; return; }
    if ( IntrCoding    > 0 ) { CodeIfBegin(); return; }
    if ( CompNowFuncs != 0 ) { return; }
}

void            IntrIfElif ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIfElif(); return; }
    if ( CompNowFuncs != 0 ) { return; }
}

void            IntrIfElse ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIfElse(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* push 'true' (to execute body of else-branch)                        */
    PushObj( True );
}

void            IntrIfBeginBody ( void )
{
    Obj                 cond;           /* value of condition              */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { IntrIgnoring++; return; }
    if ( IntrCoding    > 0 ) { CodeIfBeginBody(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the condition                                         */
    cond = PopObj();
    if ( cond != True && cond != False ) {
        ErrorQuit(
            "<expr> must be 'true' or 'false' (not to a %s)",
            (Int)(InfoBags[TYPE_OBJ(cond)].name), 0L );
    }

    /* if the condition is 'false', ignore the body                        */
    if ( cond == False ) {
        IntrIgnoring = 1;
    }
}

void            IntrIfEndBody (
    UInt                nr )
{
    UInt                i;              /* loop variable                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 1 ) { IntrIgnoring--; return; }
    if ( IntrCoding    > 0 ) { CodeIfEndBody( nr ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* if the condition was 'false', the body was ignored                  */
    if ( IntrIgnoring == 1 ) {
        IntrIgnoring = 0;
        return;
    }

    /* otherwise drop the values for the statements executed in the body   */
    for ( i = nr; 1 <= i; i-- ) {
        PopVoidObj();
    }

    /* one branch of the if-statement was executed, ignore the others      */
    IntrIgnoring = 1;
}

void            IntrIfEnd (
    UInt                nr )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 1 ) { IntrIgnoring--; return; }
    if ( IntrCoding    > 0 ) { CodeIfEnd( nr ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* if one branch was executed (ignoring the others)                    */
    if ( IntrIgnoring == 1 ) {
        IntrIgnoring = 0;
        PushVoidObj();
    }

    /* if no branch was executed                                           */
    else {
        PushVoidObj();
    }
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
void IntrForBegin ( void )
{
    Obj                 nams;           /* (empty) list of names           */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { IntrCoding++; CodeForBegin(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* switch to coding mode now                                           */
    CodeBegin();
    IntrCoding = 1;

    /* code a function expression (with no arguments and locals)           */
    nams = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( nams, 0 );
    CodeFuncExprBegin( 0, 0, nams );

    /* code a for loop                                                     */
    CodeForBegin();
}

void IntrForIn ( void )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeForIn();
}

void IntrForBeginBody ( void )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeForBeginBody();
}

void IntrForEndBody (
    UInt                nr )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( IntrCoding == 0 && CompNowFuncs != 0 ) {
	while ( 1 < --nr ) {
	    PopStat();
	}
    }
    else {
	assert( IntrCoding > 0 );
	CodeForEndBody( nr );
    }
}

void IntrForEnd ( void )
{
    Obj                 func;           /* the function, result            */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 1 ) { IntrCoding--; CodeForEnd(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );

    /* code a function expression (with one statement in the body)         */
    CodeFuncExprEnd( 1UL, 0UL );

    /* switch back to immediate mode, get the function                     */
    IntrCoding = 0;
    CodeEnd( 0 );
    func = CodeResult;

    /* call the function                                                   */
    CALL_0ARGS( func );

    /* push void                                                           */
    PushVoidObj();
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
void            IntrWhileBegin ( void )
{
    Obj                 nams;           /* (empty) list of names           */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { IntrCoding++; CodeWhileBegin(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* switch to coding mode now                                           */
    CodeBegin();
    IntrCoding = 1;

    /* code a function expression (with no arguments and locals)           */
    nams = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( nams, 0 );
    CodeFuncExprBegin( 0, 0, nams );

    /* code a while loop                                                   */
    CodeWhileBegin();
}

void            IntrWhileBeginBody ( void )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeWhileBeginBody();
}

void            IntrWhileEndBody (
    UInt                nr )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( IntrCoding == 0 && CompNowFuncs != 0 ) {
	while ( 1 < --nr ) {
	    PopStat();
	}
    }
    else {
	assert( IntrCoding > 0 );
	CodeWhileEndBody( nr );
    }
}

void            IntrWhileEnd ( void )
{
    Obj                 func;           /* the function, result            */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 1 ) { IntrCoding--; CodeWhileEnd(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeWhileEnd();

    /* code a function expression (with one statement in the body)         */
    CodeFuncExprEnd( 1UL, 0UL );

    /* switch back to immediate mode, get the function                     */
    IntrCoding = 0;
    CodeEnd( 0 );
    func = CodeResult;

    /* call the function                                                   */
    CALL_0ARGS( func );

    /* push void                                                           */
    PushVoidObj();
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
void            IntrRepeatBegin ( void )
{
    Obj                 nams;           /* (empty) list of names           */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { IntrCoding++; CodeRepeatBegin(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* switch to coding mode now                                           */
    CodeBegin();
    IntrCoding = 1;

    /* code a function expression (with no arguments and locals)           */
    nams = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( nams, 0 );
    CodeFuncExprBegin( 0, 0, nams );

    /* code a repeat loop                                                  */
    CodeRepeatBegin();
}

void            IntrRepeatBeginBody ( void )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeRepeatBeginBody();
}

void            IntrRepeatEndBody (
    UInt                nr )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( IntrCoding == 0 && CompNowFuncs != 0 ) {
	while ( 1 < --nr ) {
	    PopStat();
	}
    }
    else {
	assert( IntrCoding > 0 );
	CodeRepeatEndBody( nr );
    }
}

void            IntrRepeatEnd ( void )
{
    Obj                 func;           /* the function, result            */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 1 ) { IntrCoding--; CodeRepeatEnd(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeRepeatEnd();

    /* code a function expression (with one statement in the body)         */
    CodeFuncExprEnd( 1UL, 0UL );

    /* switch back to immediate mode, get the function                     */
    IntrCoding = 0;
    CodeEnd( 0 );
    func = CodeResult;

    /* call the function                                                   */
    CALL_0ARGS( func );

    /* push void                                                           */
    PushVoidObj();
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
void            IntrBreak ( void )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( IntrCoding == 0 )
      ErrorQuit("A break statement can only appear inside a loop",0L,0L);
    else
      CodeBreak();
    return;
}


/****************************************************************************
**
*F  IntrReturnObj() . . . . . . . . . . . .  interpret return-value-statement
**
**  'IntrReturnObj' is the action  to interpret a return-value-statement.  It
**  is  called when  the reader encounters  a  'return  <expr>;', but *after*
**  reading the expression <expr>.
*/
void            IntrReturnObj ( void )
{
    Obj                 val;            /* return value                    */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeReturnObj(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* empty the values stack and push the return value                    */
    val = PopObj();
    SET_LEN_PLIST( StackObj, 0 );
    CountObj = 0;
    PushObj( val );

    /* indicate that a return-value-statement was interpreted              */
    IntrReturning = 1;
}


/****************************************************************************
**
*F  IntrReturnVoid()  . . . . . . . . . . . . interpret return-void-statement
**
**  'IntrReturnVoid' is the action to interpret  a return-void-statement.  It
**  is called when the reader encounters a 'return;'.
*/
void            IntrReturnVoid ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeReturnVoid(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* empty the values stack and push the void value                      */
    SET_LEN_PLIST( StackObj, 0 );
    CountObj = 0;
    PushVoidObj();

    /* indicate that a return-void-statement was interpreted               */
    IntrReturning = 2;
}


/****************************************************************************
**
*F  IntrQuit()  . . . . . . . . . . . . . . . . . .  interpret quit-statement
**
**  'IntrQuit' is the  action to interpret   a quit-statement.  It  is called
**  when the reader encounters a 'quit;'.
*/
void            IntrQuit ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* 'quit' is not allowed in functions (by the reader)                  */
    assert( IntrCoding == 0 );

    /* empty the values stack and push the void value                      */
    SET_LEN_PLIST( StackObj, 0 );
    CountObj = 0;
    PushVoidObj();

    /* indicate that a quit-statement was interpreted                      */
    IntrReturning = 8;
}


/****************************************************************************
**
*F  IntrOrL() . . . . . . . . . .  interpret or-expression, left operand read
*F  IntrOr()  . . . . . . . . . . interpret or-expression, right operand read
**
**  'IntrOrL' is an action to interpret an or-expression.   It is called when
**  the reader encounters the 'or' keyword, i.e., *after* the left operand is
**  read by *before* the right operand is read.
**
**  'IntrOr' is an action to  interpret an or-expression.   It is called when
**  the reader encountered  the  end of  the  expression, i.e., *after*  both
**  operands are read.
*/
void            IntrOrL ( void )
{
    Obj                 opL;            /* value of left operand           */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { IntrIgnoring++; return; }
    if ( IntrCoding    > 0 ) { CodeOrL(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* if the left operand is 'true', ignore the right operand             */
    opL = PopObj();
    PushObj( opL );
    if ( opL == True ) {
        PushObj( opL );
        IntrIgnoring = 1;
    }
}

void            IntrOr ( void )
{
    Obj                 opL;            /* value of left  operand          */
    Obj                 opR;            /* value of right operand          */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 1 ) { IntrIgnoring--; return; }
    if ( IntrCoding    > 0 ) { CodeOr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* stop ignoring things now                                            */
    IntrIgnoring = 0;

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* if the left operand is 'true', this is the result                   */
    if      ( opL == True ) {
        PushObj( opL );
    }

    /* if the left operand is 'false', the result is the right operand     */
    else if ( opL == True  ) {
        if ( opR == True || opR == False  ) {
            PushObj( opR );
        }
        else {
            ErrorQuit(
                "<expr> must be 'true' or 'false' (not to a %s)",
                (Int)(InfoBags[TYPE_OBJ(opR)].name), 0L );
        }
    }
    
    /* signal an error                                                     */
    else {
        ErrorQuit(
            "<expr> must be 'true' or 'false' (not to a %s)",
            (Int)(InfoBags[TYPE_OBJ(opL)].name), 0L );
    }
}


/****************************************************************************
**
*F  IntrAndL()  . . . . . . . . . interpret and-expression, left operand read
*F  IntrAnd() . . . . . . . . .  interpret and-expression, right operand read
**
**  'IntrAndL' is  an action  to interpret an   and-expression.  It is called
**  when the reader  encounters the  'and'  keyword, i.e., *after*  the  left
**  operand is read by *before* the right operand is read.
**
**  'IntrAnd' is an action to interpret an and-expression.  It is called when
**  the reader encountered   the end of   the expression, i.e., *after*  both
**  operands are read.
*/
void            IntrAndL ( void )
{
    Obj                 opL;            /* value of left operand           */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { IntrIgnoring++; return; }
    if ( IntrCoding    > 0 ) { CodeAndL(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* if the left operand is 'false', ignore the right operand            */
    opL = PopObj();
    PushObj( opL );
    if ( opL == False ) {
        PushObj( opL );
        IntrIgnoring = 1;
    }
}

extern  Obj             NewAndFilter (
            Obj                     oper1,
            Obj                     oper2 );

void            IntrAnd ( void )
{
    Obj                 opL;            /* value of left  operand          */
    Obj                 opR;            /* value of right operand          */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 1 ) { IntrIgnoring--; return; }
    if ( IntrCoding    > 0 ) { CodeAnd(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* stop ignoring things now                                            */
    IntrIgnoring = 0;

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* if the left operand is 'false', this is the result                  */
    if      ( opL == False ) {
        PushObj( opL );
    }

    /* if the left operand is 'true', the result is the right operand      */
    else if ( opL == True  ) {
        if ( opR == False || opR == True  ) {
            PushObj( opR );
        }
        else {
            ErrorQuit(
                "<expr> must be 'true' or 'false' (not to a %s)",
                (Int)(InfoBags[TYPE_OBJ(opR)].name), 0L );
        }
    }

    /* handle the 'and' of two features                                    */
    else if ( TYPE_OBJ(opL) == T_FUNCTION ) {
        if ( TYPE_OBJ(opR) == T_FUNCTION ) {
            PushObj( NewAndFilter( opL, opR ) );
        }
        else {
            ErrorQuit(
                "<expr> must be 'true' or 'false' (not to a %s)",
                (Int)(InfoBags[TYPE_OBJ(opL)].name), 0L );
        }
    }
    
    /* signal an error                                                     */
    else {
        ErrorQuit(
            "<expr> must be 'true' or 'false' (not to a %s)",
            (Int)(InfoBags[TYPE_OBJ(opL)].name), 0L );
    }
}


/****************************************************************************
**
*F  IntrNot() . . . . . . . . . . . . . . . . . . .  interpret not-expression
**
**  'IntrNot' is the action to interpret a not-expression.  It is called when
**  the reader encounters a not-expression, *after* the operand is read.
*/
void            IntrNot ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 op;             /* operand                         */

    /* ignore or code                                                      */
    if ( IntrIgnoring > 0 ) { return; }
    if ( IntrCoding   > 0 ) { CodeNot(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the operand                                           */
    op = PopObj();
    if ( op != True && op != False ) {
        ErrorQuit(
            "<expr> must be 'true' or 'false' (not to a %s)",
            (Int)(InfoBags[TYPE_OBJ(op)].name), 0L );
    }

    /* negate the operand                                                  */
    val = (op == False ? True : False);

    /* push the result                                                     */
    PushObj( val );
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
void            IntrXX ( void )
{
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* push the operands in reverse order                                  */
    PushObj( opR );
    PushObj( opL );
}

void            IntrEq ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeEq(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* compare them                                                        */
    val = (EQ( opL, opR ) ? True : False);

    /* push the result                                                     */
    PushObj( val );
}

void            IntrNe ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeNe(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* '<left> <> <right>' is 'not <left> = <right>'                       */
    IntrEq();
    IntrNot();
}

void            IntrLt ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeLt(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* compare them                                                        */
    val = (LT( opL, opR ) ? True : False);

    /* push the result                                                     */
    PushObj( val );
}

void            IntrGe ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeGe(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* '<left> >= <right>' is 'not <left> < <right>'                       */
    IntrLt();
    IntrNot();
}

void            IntrGt ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeGt(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* '<left> > <right>' is '<right> < <left>'                            */
    IntrXX();
    IntrLt();
}

void            IntrLe ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeLe(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* '<left> <= <right>' is 'not <right> < <left>'                       */
    IntrXX();
    IntrLt();
    IntrNot();
}


/****************************************************************************
**
*F  IntrIn()  . . . . . . . . . . . . . . . . . . . . interpret in-expression
**
**  'IntrIn'  is the action  to interpret an  in-expression.  It is called by
**  the reader *after* *both* operands are read.
*/
void            IntrIn ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIn(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* perform the test                                                    */
    val = (IN( opL, opR ) ? True : False);

    /* push the result                                                     */
    PushObj( val );
}


/****************************************************************************
**
*F  IntrSum() . . . . . . . . . . . . . . . . . . . .  interpret +-expression
*F  IntrAInv()  . . . . . . . . . . . . . . . .  interpret unary --expression
*F  IntrDiff()  . . . . . . . . . . . . . . . . . . .  interpret --expression
*F  IntrProd()  . . . . . . . . . . . . . . . . . . .  interpret *-expression
*F  IntrInv() . . . . . . . . . . . . . . . . . . .  interpret ^-1-expression
*F  IntrQuo() . . . . . . . . . . . . . . . . . . . .  interpret /-expression
*F  IntrMod()   . . . . . . . . . . . . . . . . . .  interpret mod-expression
*F  IntrPow() . . . . . . . . . . . . . . . . . . . .  interpret ^-expression
**
**  'IntrSum', 'IntrDiff',  'IntrProd',  'IntrQuo',  'IntrMod', and 'IntrPow'
**  are  the actions to interpret  the  respective operator expression.  They
**  are called by the reader *after* *both* operands are read.
*/
void            IntrSum ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeSum(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* compute the sum                                                     */
    val = SUM( opL, opR );

    /* push the result                                                     */
    PushObj( val );
}

void            IntrAInv ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAInv(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operand                                                     */
    opL = PopObj();

    /* compute the additive inverse                                        */
    val = AINV( opL );

    /* push the result                                                     */
    PushObj( val );
}

void            IntrDiff ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeDiff(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* compute the difference                                              */
    val = DIFF( opL, opR );

    /* push the result                                                     */
    PushObj( val );
}

void            IntrProd ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeProd(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* compute the product                                                 */
    val = PROD( opL, opR );

    /* push the result                                                     */
    PushObj( val );
}

void            IntrInv ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeInv(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operand                                                     */
    opL = PopObj();

    /* compute the multiplicative inverse                                  */
    val = INV( opL );

    /* push the result                                                     */
    PushObj( val );
}

void            IntrQuo ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeQuo(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* compute the quotient                                                */
    val = QUO( opL, opR );

    /* push the result                                                     */
    PushObj( val );
}

void            IntrMod ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeMod(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* compute the remainder                                               */
    val = MOD( opL, opR );

    /* push the result                                                     */
    PushObj( val );
}

void            IntrPow ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodePow(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* compute the power                                                   */
    val = POW( opL, opR );

    /* push the result                                                     */
    PushObj( val );
}


/****************************************************************************
**
*F  IntrIntExpr(<str>)  . . . . . . . .  interpret literal integer expression
**
**  'IntrIntExpr' is the action  to  interpret a literal  integer expression.
**  <str> is the integer as a (null terminated) C character string.
*/
void            IntrIntExpr (
    Char *              str )
{
    Obj                 val;            /* value = <upp> * <pow> + <low>   */
    Obj                 upp;            /* upper part                      */
    Int                 pow;            /* power                           */
    Int                 low;            /* lower part                      */
    Int                 sign;           /* is the integer negative         */
    UInt                i;              /* loop variable                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIntExpr( str ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the signs, if any                                                */
    sign = 1;
    i = 0;
    while ( str[i] == '-' ) {
        sign = - sign;
        i++;
    }

    /* collect the digits in groups of 8                                   */
    low = 0;
    pow = 1;
    upp = INTOBJ_INT(0);
    while ( str[i] != '\0' ) {
        low = 10 * low + str[i] - '0';
        pow = 10 * pow;
        if ( pow == 100000000L ) {
            upp = SUM( PROD(upp,INTOBJ_INT(pow) ), INTOBJ_INT(sign*low) );
            pow = 1;
            low = 0;
        }
        i++;
    }

    /* compose the integer value                                           */
    val = 0;
    if ( upp == INTOBJ_INT(0) ) {
        val = INTOBJ_INT(sign*low);
    }
    else if ( pow == 1 ) {
        val = upp;
    }
    else {
        val = SUM( PROD( upp, INTOBJ_INT(pow) ), INTOBJ_INT(sign*low) );
    }

    /* push the integer value                                              */
    PushObj( val );
}


/****************************************************************************
**
*F  IntrTrueExpr()  . . . . . . . . . . . . interpret literal true expression
**
**  'IntrTrueExpr' is the action to interpret a literal true expression.
*/
void            IntrTrueExpr ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeTrueExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* push the value                                                      */
    PushObj( True );
}


/****************************************************************************
**
*F  IntrFalseExpr() . . . . . . . . . . .  interpret literal false expression
**
**  'IntrFalseExpr' is the action to interpret a literal false expression.
*/
void            IntrFalseExpr ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeFalseExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* push the value                                                      */
    PushObj( False );
}


/****************************************************************************
**
*F  IntrCharExpr(<chr>) . . . . . . .  interpret literal character expression
**
**  'IntrCharExpr' is the action to interpret a literal character expression.
**  <chr> is the C character.
*/
void            IntrCharExpr (
    Char                chr )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeCharExpr( chr ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* push the value                                                      */
    PushObj( ObjsChar[ (UChar)chr ] );
}


/****************************************************************************
**
*F  IntrPermCycle(<nr>) . . . . . .  interpret literal permutation expression
*F  IntrPerm(<nr>)  . . . . . . . .  interpret literal permutation expression
*/
void            IntrPermCycle (
    UInt                nrx,
    UInt                nrc )
{
    Obj                 perm;           /* permutation                     */
    UInt4 *             ptr4;           /* pointer into perm               */
    Obj                 val;            /* one entry as value              */
    UInt                c, p, l;        /* entries in permutation          */
    UInt                m;              /* maximal entry in permutation    */
    UInt                j, k;           /* loop variable                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodePermCycle(nrx,nrc); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the permutation (allocate for the first cycle)                  */
    if ( nrc == 1 ) {
        m = 0;
        perm = NEW_PERM4( 0 );
        ptr4 = ADDR_PERM4( perm );
    }
    else {
        m = INT_INTOBJ( ELM_LIST( StackObj, CountObj - nrx ) );
        perm = ELM_LIST( StackObj, CountObj - nrx - 1 );
        ptr4 = ADDR_PERM4( perm );
    }

    /* multiply the permutation with the cycle                             */
    c = p = l = 0;
    for ( j = nrx; 1 <= j; j-- ) {

        /* get and check current entry for the cycle                       */
        val = PopObj();
        if ( ! IS_INTOBJ(val) || INT_INTOBJ(val) <= 0 ) {
            ErrorQuit(
                "Permutation: <expr> must be a positive integer (not a %s)",
                (Int)(InfoBags[TYPE_OBJ(val)].name), 0L );
        }
        c = INT_INTOBJ(val);

        /* if necessary resize the permutation                             */
        if ( SIZE_OBJ(perm)/sizeof(UInt4) < c ) {
            ResizeBag( perm, (c + 1023) / 1024 * 1024 * sizeof(UInt4) );
            ptr4 = ADDR_PERM4( perm );
            for ( k = m+1; k <= SIZE_OBJ(perm)/sizeof(UInt4); k++ ) {
                ptr4[k-1] = k-1;
            }
        }
        if ( m < c ) {
            m = c;
        }

        /* check that the cycles are disjoint                              */
        if ( (p != 0 && p == c) || (ptr4[c-1] != c-1) ) {
            ErrorQuit(
                "Permutation: cycles must be disjoint",
                0L, 0L );
        }

        /* enter the previous entry at current location                    */
        if ( p != 0 ) { ptr4[c-1] = p-1; }
        else          { l = c;          }

        /* remember current entry for next round                           */
        p = c;
    }

    /* enter first (last popped) entry at last (first popped) location     */
    ptr4[l-1] = p-1;
        
    /* push the permutation (if necessary, drop permutation first)         */
    if ( nrc != 1 ) { PopObj(); PopObj(); }
    PushObj( perm );
    PushObj( INTOBJ_INT(m) );
}

void            IntrPerm (
    UInt                nrc )
{
    Obj                 perm;           /* permutation, result             */
    UInt4 *             ptr4;           /* pointer into permutation        */
    UInt2 *             ptr2;           /* pointer into permutation        */
    UInt                m;              /* maximal entry in permutation    */
    UInt                k;              /* loop variable                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodePerm(nrc); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* special case for identity permutation                               */
    if ( nrc == 0 ) {
        perm = NEW_PERM2( 0 );
    }

    /* otherwise                                                           */
    else {

        /* get the permutation and its maximal entry                       */
        m  = INT_INTOBJ( PopObj() );
        perm = PopObj();

        /* if possible represent the permutation with short entries        */
        if ( m <= 65536UL ) {
            ptr2 = ADDR_PERM2( perm );
            ptr4 = ADDR_PERM4( perm );
            for ( k = 1; k <= m; k++ ) {
                ptr2[k-1] = ptr4[k-1];
            };
            RetypeBag( perm, T_PERM2 );
            ResizeBag( perm, m * sizeof(UInt2) );
        }

        /* otherwise just shorten the permutation                          */
        else {
            ResizeBag( perm, m * sizeof(UInt4) );
        }

    }

    /* push the result                                                     */
    PushObj( perm );
}


/****************************************************************************
**
*F  IntrListExprBegin(<top>)  . . . . . . . . . .  interpret list expr, begin
*F  IntrListExprBeginElm(<pos>) . . . . .  interpret list expr, begin element
*F  IntrListExprEndElm()  . . . . . . . . .  interpret list expr, end element
*F  IntrListExprEnd(<nr>,<range>,<top>,<tilde>) . .  interpret list expr, end
*/
void            IntrListExprBegin (
    UInt                top )
{
    Obj                 list;           /* new list                        */
    Obj                 old;            /* old value of '~'                */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeListExprBegin( top ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* allocate the new list                                               */
    list = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( list, 0 );

    /* if this is an outmost list, save it for reference in '~'            */
    /* (and save the old value of '~' on the values stack)                 */
    if ( top ) {
        old = VAL_GVAR( Tilde );
        if ( old != 0 ) { PushObj( old ); }
        else            { PushVoidObj();  }
        AssGVar( Tilde, list );
    }

    /* push the list                                                       */
    PushObj( list );
}

void            IntrListExprBeginElm (
    UInt                pos )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeListExprBeginElm( pos ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* remember this position on the values stack                          */
    PushObj( INTOBJ_INT(pos) );
}

void            IntrListExprEndElm ( void )
{
    Obj                 list;           /* list that is currently made     */
    Obj                 pos;            /* position                        */
    UInt                p;              /* position, as a C integer        */
    Obj                 val;            /* value to assign into list       */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeListExprEndElm(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the value                                                       */
    val = PopObj();

    /* get the position                                                    */
    pos = PopObj();
    p = INT_INTOBJ( pos );

    /* get the list                                                        */
    list = PopObj();

    /* assign the element into the list                                    */
    ASS_LIST( list, p, val );

    /* push the list again                                                 */
    PushObj( list );
}

void            IntrListExprEnd (
    UInt                nr,
    UInt                range,
    UInt                top,
    UInt                tilde )
{
    Obj                 list;           /* the list, result                */
    Obj                 old;            /* old value of '~'                */
    Int                 low;            /* low value of range              */
    Int                 inc;            /* increment of range              */
    Int                 high;           /* high value of range             */
    Obj                 val;            /* temporary value                 */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeListExprEnd(nr,range,top,tilde); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* if this was a top level expression, restore the value of '~'        */
    if ( top ) {
        list = PopObj();
        old = PopVoidObj();
        AssGVar( Tilde, old );
        PushObj( list );
    }

    /* if this was a range, convert the list to a range                    */
    if ( range ) {

        /* get the list                                                    */
        list = PopObj();

        /* get the low value                                               */
        val = ELM_LIST( list, 1 );
        if ( ! IS_INTOBJ(val) ) {
            ErrorQuit(
                "Range: <first> must be an integer (not a %s)",
                (Int)(InfoBags[TYPE_OBJ(val)].name), 0L );
        }
        low = INT_INTOBJ( val );

        /* get the increment                                               */
        if ( nr == 3 ) {
            val = ELM_LIST( list, 2 );
            if ( ! IS_INTOBJ(val) ) {
                ErrorQuit(
                    "Range: <second> must be an integer (not a %s)",
                    (Int)(InfoBags[TYPE_OBJ(val)].name), 0L );
            }
            if ( INT_INTOBJ(val) == low ) {
                ErrorQuit(
                      "Range: <second> must not be equal to <first> (%d)",
                      (Int)low, 0L );
            }
            inc = INT_INTOBJ(val) - low;
        }
        else {
            inc = 1;
        }

        /* get and check the high value                                    */
        val = ELM_LIST( list, LEN_LIST(list) );
        if ( ! IS_INTOBJ(val) ) {
            ErrorQuit(
                "Range: <last> must not be an integer (not a %s)",
                (Int)(InfoBags[TYPE_OBJ(val)].name), 0L );
        }
        if ( (INT_INTOBJ(val) - low) % inc != 0 ) {
            ErrorQuit(
                "Range: <last>-<first> (%d) must be divisible by <inc> (%d)",
                (Int)(INT_INTOBJ(val)-low), (Int)inc );
        }
        high = INT_INTOBJ(val);

        /* if <low> is larger than <high> the range is empty               */
        if ( (0 < inc && high < low) || (inc < 0 && low < high) ) {
            list = NEW_PLIST( T_PLIST, 0 );
            SET_LEN_PLIST( list, 0 );
        }

        /* if <low> is equal to <high> the range is a singleton list       */
        else if ( low == high ) {
            list = NEW_PLIST( T_PLIST, 1 );
            SET_LEN_PLIST( list, 1 );
            SET_ELM_PLIST( list, 1, INTOBJ_INT(low) );
        }

        /* else make the range                                             */
        else {
            if ( 0 < inc )
                list = NEW_RANGE_SSORT();
            else
                list = NEW_RANGE_NSORT();
            SET_LEN_RANGE( list, (high-low) / inc + 1 );
            SET_LOW_RANGE( list, low );
            SET_INC_RANGE( list, inc );
        }

        /* push the list again                                             */
        PushObj( list );
    }
}


/****************************************************************************
**
*F  IntrStringExpr(<str>) . . . . . . . . interpret literal string expression
*/
void            IntrStringExpr (
    Char *              str )
{
    Obj                 val;            /* string value, result            */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeStringExpr( str ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* create the string and copy the stuff                                */
    val = NEW_STRING( SyStrlen(str) );
    SyStrncat( CSTR_STRING(val), str, SyStrlen(str) );

    /* push the string                                                     */
    PushObj( val );
}


/****************************************************************************
**
*F  IntrRecExprBegin(<top>) . . . . . . . . . .  interpret record expr, begin
*F  IntrRecExprBeginElmName(<rnam>) . .  interpret record expr, begin element
*F  IntrRecExprBeginElmExpr() . . . . .  interpret record expr, begin element
*F  IntrRecExprEndElmExpr() . . . . . . .  interpret record expr, end element
*F  IntrRecExprEnd(<nr>,<top>,<tilde>)  . . . . .  interpret record expr, end
*/
void            IntrRecExprBegin (
    UInt                top )
{
    Obj                 record;         /* new record                      */
    Obj                 old;            /* old value of '~'                */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeRecExprBegin( top ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* allocate the new record                                             */
    record = NEW_PREC( 0 );

    /* if this is an outmost record, save it for reference in '~'          */
    /* (and save the old value of '~' on the values stack)                 */
    if ( top ) {
        old = VAL_GVAR( Tilde );
        if ( old != 0 ) { PushObj( old ); }
        else            { PushVoidObj();  }
        AssGVar( Tilde, record );
    }

    /* push the record                                                     */
    PushObj( record );
}

void            IntrRecExprBeginElmName (
    UInt                rnam )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeRecExprBeginElmName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* remember the name on the values stack                               */
    PushObj( (Obj)rnam );
}

void            IntrRecExprBeginElmExpr ( void )
{
    UInt                rnam;           /* record name                     */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeRecExprBeginElmExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* convert the expression to a record name                             */
    rnam = RNamObj( PopObj() );

    /* remember the name on the values stack                               */
    PushObj( (Obj)rnam );
}

void            IntrRecExprEndElm ( void )
{
    Obj                 record;         /* record that is currently made   */
    UInt                rnam;           /* name of record element          */
    Obj                 val;            /* value of record element         */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeRecExprEndElm(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the value                                                       */
    val = PopObj();

    /* get the record name                                                 */
    rnam = (UInt)PopObj();

    /* get the record                                                      */
    record = PopObj();

    /* assign the value into the record                                    */
    ASS_REC( record, rnam, val );

    /* push the record again                                               */
    PushObj( record );
}

void            IntrRecExprEnd (
    UInt                nr,
    UInt                top,
    UInt                tilde )
{
    Obj                 record;         /* record that is currently made   */
    Obj                 old;            /* old value of '~'                */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeRecExprEnd(nr,top,tilde); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* if this was a top level expression, restore the value of '~'        */
    if ( top ) {
        record = PopObj();
        old = PopVoidObj();
        AssGVar( Tilde, old );
        PushObj( record );
    }
}


/****************************************************************************
**
*F  IntrAssLVar(<lvar>) . . . . . . . . . . . . interpret assignment to local
*/
void            IntrAssLVar (
    UInt                lvar )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeAssLVar( lvar );
}

void            IntrUnbLVar (
    UInt                lvar )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeUnbLVar( lvar );
}


/****************************************************************************
**
*F  IntrRefLVar(<lvar>) . . . . . . . . . . . .  interpret reference to local
*/
void            IntrRefLVar (
    UInt                lvar )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeRefLVar( lvar );
}

void            IntrIsbLVar (
    UInt                lvar )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeIsbLVar( lvar );
}


/****************************************************************************
**
*F  IntrAssHVar(<hvar>) . . . . . . . . . . .  interpret assignment to higher
*/
void            IntrAssHVar (
    UInt                hvar )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeAssHVar( hvar );
}

void            IntrUnbHVar (
    UInt                hvar )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeUnbHVar( hvar );
}


/****************************************************************************
**
*F  IntrRefHVar(<hvar>) . . . . . . . . . . . . interpret reference to higher
*/
void            IntrRefHVar (
    UInt                hvar )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeRefHVar( hvar );
}

void            IntrIsbHVar (
    UInt                hvar )
{
    /* ignore                                                              */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( IntrCoding > 0 );
    CodeIsbHVar( hvar );
}


/****************************************************************************
**
*F  IntrAssDVar(<dvar>) . . . . . . . . . . . . interpret assignment to debug
*/
extern  Obj             ErrorLVars;

void            IntrAssDVar (
    UInt                dvar )
{
    Obj                 rhs;            /* right hand side                 */
    Obj                 currLVars;

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    /* if ( IntrCoding    > 0 ) { CodeAssDVar( gvar ); return; } */
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand side                                             */
    rhs = PopObj();

    /* assign the right hand side                                          */
    currLVars = CurrLVars;
    SWITCH_TO_OLD_LVARS( ErrorLVars );
    ASS_HVAR( dvar, rhs );
    SWITCH_TO_OLD_LVARS( currLVars  );

    /* push the right hand side again                                      */
    PushObj( rhs );
}

void            IntrUnbDVar (
    UInt                dvar )
{
    Obj                 currLVars;

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    /* if ( IntrCoding    > 0 ) { CodeUnbGVar( gvar ); return; } */
    if ( CompNowFuncs != 0 ) { return; }

    /* assign the right hand side                                          */
    currLVars = CurrLVars;
    SWITCH_TO_OLD_LVARS( ErrorLVars );
    ASS_HVAR( dvar, (Obj)0 );
    SWITCH_TO_OLD_LVARS( currLVars  );

    /* push void                                                           */
    PushVoidObj();
}


/****************************************************************************
**
*F  IntrRefDVar(<dvar>) . . . . . . . . . . . .  interpret reference to debug
*/
void            IntrRefDVar (
    UInt                dvar )
{
    Obj                 val;            /* value, result                   */
    Obj                 currLVars;

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    /* if ( IntrCoding    > 0 ) { CodeRefGVar( gvar ); return; } */
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the value                                             */
    currLVars = CurrLVars;
    SWITCH_TO_OLD_LVARS( ErrorLVars );
    val = OBJ_HVAR( dvar );
    SWITCH_TO_OLD_LVARS( currLVars  );
    if ( val == 0 ) {
        ErrorQuit(
            "Variable: <debug-variable-%d-%d> must have a value",
            dvar >> 16, dvar & 0xFFFF );
    }

    /* push the value                                                      */
    PushObj( val );
}

void            IntrIsbDVar (
    UInt                dvar )
{
    Obj                 val;            /* value, result                   */
    Obj                 currLVars;

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    /* if ( IntrCoding    > 0 ) { CodeIsbGVar( gvar ); return; } */
    if ( CompNowFuncs != 0 ) { return; }

    /* get the value                                                       */
    currLVars = CurrLVars;
    SWITCH_TO_OLD_LVARS( ErrorLVars );
    val = OBJ_HVAR( dvar );
    SWITCH_TO_OLD_LVARS( currLVars  );

    /* push the value                                                      */
    PushObj( (val != 0 ? True : False) );
}


/****************************************************************************
**
*F  IntrAssGVar(<gvar>) . . . . . . . . . . .  interpret assignment to global
*/
void            IntrAssGVar (
    UInt                gvar )
{
    Obj                 rhs;            /* right hand side                 */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssGVar( gvar ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand side                                             */
    rhs = PopObj();

    /* assign the right hand side                                          */
    AssGVar( gvar, rhs );

    /* push the right hand side again                                      */
    PushObj( rhs );
}

void            IntrUnbGVar (
    UInt                gvar )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeUnbGVar( gvar ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* assign the right hand side                                          */
    AssGVar( gvar, (Obj)0 );

    /* push void                                                           */
    PushVoidObj();
}


/****************************************************************************
**
*F  IntrRefGVar(<gvar>) . . . . . . . . . . . . interpret reference to global
*/
void            IntrRefGVar (
    UInt                gvar )
{
    Obj                 val;            /* value, result                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeRefGVar( gvar ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the value                                             */
    if ( (val = ValAutoGVar( gvar )) == 0 ) {
        ErrorQuit(
            "Variable: '%s' must have a value",
            (Int)NameGVar(gvar), 0L );
    }

    /* push the value                                                      */
    PushObj( val );
}

void            IntrIsbGVar (
    UInt                gvar )
{
    Obj                 val;            /* value, result                   */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIsbGVar( gvar ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the value                                                       */
    val = ValAutoGVar( gvar );

    /* push the value                                                      */
    PushObj( (val != 0 ? True : False) );
}


/****************************************************************************
**
*F  IntrAssList() . . . . . . . . . . . . . .  interpret assignment to a list
*F  IntrAsssList()  . . . . . . . . . interpret multiple assignment to a list
*F  IntrAssListLevel(<level>) . . . . . interpret assignment to several lists
*F  IntrAsssListLevel(<level>)  . . intr multiple assignment to several lists
*/
void            IntrAssList ( void )
{
    Obj                 list;           /* list                            */
    Obj                 pos;            /* position                        */
    Int                 p;              /* position, as a C integer        */
    Obj                 rhs;            /* right hand side                 */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssList(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand side                                             */
    rhs = PopObj();

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
         "List Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ(pos);

    /* get the list (checking is done by 'ASS_LIST')                       */
    list = PopObj();

    /* assign to the element of the list                                   */
    ASS_LIST( list, p, rhs );

    /* push the right hand side again                                      */
    PushObj( rhs );
}

void            IntrAsssList ( void )
{
    Obj                 list;           /* list                            */
    Obj                 poss;           /* positions                       */
    Obj                 rhss;           /* right hand sides                */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAsssList(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand sides                                            */
    rhss = PopObj();
    if ( ! IS_DENSE_LIST( rhss ) ) {
        ErrorQuit(
            "List Assignment: <rhss> must be a dense list",
            0L, 0L );
    }

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
    "List Assignment: <positions> must be a dense list of positive integers",
               0L, 0L );
    }
    if ( LEN_LIST( poss ) != LEN_LIST( rhss ) ) {
        ErrorQuit(
     "List Assignment: <rhss> must have the same length as <positions> (%d)",
            (Int)LEN_LIST(poss), 0L );
    }

    /* get the list (checking is done by 'ASSS_LIST')                      */
    list = PopObj();

    /* assign to several elements of the list                              */
    ASSS_LIST( list, poss, rhss );

    /* push the right hand sides again                                     */
    PushObj( rhss );
}

void            IntrAssListLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as C integer          */
    Obj                 rhss;           /* right hand sides, right operand */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssListLevel( level ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get right hand sides (checking is done by 'AssListLevel')           */
    rhss = PopObj();

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
         "List Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ(pos);

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'AssListLevel')     */
    lists = PopObj();

    /* assign the right hand sides to the elements of several lists        */
    AssListLevel( lists, p, rhss, level );

    /* push the assigned values again                                      */
    PushObj( rhss );
}

void            IntrAsssListLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAsssListLevel( level ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get right hand sides (checking is done by 'AsssListLevel')          */
    rhss = PopObj();

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
    "List Assignment: <positions> must be a dense list of positive integers",
            0L, 0L );
    }

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'AsssListLevel')    */
    lists = PopObj();

    /* assign the right hand sides to several elements of several lists    */
    AsssListLevel( lists, poss, rhss, level );

    /* push the assigned values again                                      */
    PushObj( rhss );
}

void            IntrUnbList ( void )
{
    Obj                 list;           /* list                            */
    Obj                 pos;            /* position                        */
    Int                 p;              /* position, as a C integer        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeUnbList(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
         "List Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ(pos);

    /* get the list (checking is done by 'UNB_LIST')                       */
    list = PopObj();

    /* unbind the element                                                  */
    UNB_LIST( list, p );

    /* push void                                                           */
    PushVoidObj();
}


/****************************************************************************
**
*F  IntrElmList() . . . . . . . . . . . . . . . interpret selection of a list
*F  IntrElmsList()  . . . . . . . . .  interpret multiple selection of a list
*F  IntrElmListLevel(<level>) . . . . .  interpret selection of several lists
*F  IntrElmsListLevel(<level>)  . .  intr multiple selection of several lists
*/
void            IntrElmList ( void )
{
    Obj                 elm;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmList(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
            "List Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ( pos );

    /* get the list (checking is done by 'ELM_LIST')                       */
    list = PopObj();

    /* get the element of the list                                         */
    elm = ELM_LIST( list, p );

    /* push the element                                                    */
    PushObj( elm );
}

void            IntrElmsList ( void )
{
    Obj                 elms;           /* elements, result                */
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, right operand        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmsList(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
      "List Elements: <positions> must be a dense list of positive integers",
            0L, 0L );
    }

    /* get the list (checking is done by 'ELMS_LIST')                      */
    list = PopObj();

    /* select several elements from the list                               */
    elms = ELMS_LIST( list, poss );

    /* push the elements                                                   */
    PushObj( elms );
}

void            IntrElmListLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmListLevel( level ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
            "List Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ( pos );

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'ElmListLevel')     */
    lists = PopObj();

    /* select the elements from several lists (store them in <lists>)      */
    ElmListLevel( lists, p, level );

    /* push the elements                                                   */
    PushObj( lists );
}

void            IntrElmsListLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* positions, right operand        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmsListLevel( level ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
      "List Elements: <positions> must be a dense list of positive integers",
            0L, 0L );
    }

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'ElmsListLevel')    */
    lists = PopObj();

    /* select several elements from several lists (store them in <lists>)  */
    ElmsListLevel( lists, poss, level );

    /* push the elements                                                   */
    PushObj( lists );
}

void            IntrIsbList ( void )
{
    Obj                 isb;            /* isbound, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIsbList(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
            "List Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ( pos );

    /* get the list (checking is done by 'ISB_LIST')                       */
    list = PopObj();

    /* get the result                                                      */
    isb = (ISB_LIST( list, p ) ? True : False);

    /* push the result                                                     */
    PushObj( isb );
}


/****************************************************************************
**
*F  IntrAssRecName(<rnam>)  . . . . . . . .  interpret assignment to a record
*F  IntrAssRecExpr()  . . . . . . . . . . .  interpret assignment to a record
*/
void            IntrAssRecName (
    UInt                rnam )
{
    Obj                 record;         /* record, left operand            */
    Obj                 rhs;            /* rhs, right operand              */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssRecName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand side                                             */
    rhs = PopObj();

    /* get the record (checking is done by 'ASS_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    ASS_REC( record, rnam, rhs );

    /* push the assigned value                                             */
    PushObj( rhs );
}

void            IntrAssRecExpr ( void )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssRecExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand side                                             */
    rhs = PopObj();

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ASS_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    ASS_REC( record, rnam, rhs );

    /* push the assigned value                                             */
    PushObj( rhs );
}

void            IntrUnbRecName (
    UInt                rnam )
{
    Obj                 record;         /* record, left operand            */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeUnbRecName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the record (checking is done by 'UNB_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    UNB_REC( record, rnam );

    /* push void                                                           */
    PushVoidObj();
}

void            IntrUnbRecExpr ( void )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeUnbRecExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'UNB_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    UNB_REC( record, rnam );

    /* push void                                                           */
    PushVoidObj();
}


/****************************************************************************
**
*F  IntrElmRecName(<rnam>)  . . . . . . . . . interpret selection of a record
*F  IntrElmRecExpr()  . . . . . . . . . . . . interpret selection of a record
*/
void            IntrElmRecName (
    UInt                rnam )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmRecName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the record (checking is done by 'ELM_REC')                      */
    record = PopObj();

    /* select the element of the record                                    */
    elm = ELM_REC( record, rnam );

    /* push the element                                                    */
    PushObj( elm );
}

void            IntrElmRecExpr ( void )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmRecExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ELM_REC')                      */
    record = PopObj();

    /* select the element of the record                                    */
    elm = ELM_REC( record, rnam );

    /* push the element                                                    */
    PushObj( elm );
}

void            IntrIsbRecName (
    UInt                rnam )
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIsbRecName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the record (checking is done by 'ISB_REC')                      */
    record = PopObj();

    /* get the result                                                      */
    isb = (ISB_REC( record, rnam ) ? True : False);

    /* push the result                                                     */
    PushObj( isb );
}

void            IntrIsbRecExpr ( void )
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIsbRecExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ISB_REC')                      */
    record = PopObj();

    /* get the result                                                      */
    isb = (ISB_REC( record, rnam ) ? True : False);

    /* push the result                                                     */
    PushObj( isb );
}


/****************************************************************************
**
*F  IntrAssPosObj() . . . . . . . . . . . . .  interpret assignment to a list
*F  IntrAsssPosObj()  . . . . . . . . interpret multiple assignment to a list
*F  IntrAssPosObjLevel(<level>) . . . . interpret assignment to several lists
*F  IntrAsssPosObjLevel(<level>)  . intr multiple assignment to several lists
*/
void            IntrAssPosObj ( void )
{
    Obj                 list;           /* list                            */
    Obj                 pos;            /* position                        */
    Int                 p;              /* position, as a C integer        */
    Obj                 rhs;            /* right hand side                 */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssPosObj(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand side                                             */
    rhs = PopObj();

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
         "PosObj Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ(pos);

    /* get the list (checking is done by 'ASS_LIST')                       */
    list = PopObj();

    /* assign to the element of the list                                   */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        if ( SIZE_OBJ(list)/sizeof(Obj) - 1 < p ) {
            ResizeBag( list, (p+1) * sizeof(Obj) );
        }
        SET_ELM_PLIST( list, p, rhs );
        CHANGED_BAG( list );
    }
    else {
        ASS_LIST( list, p, rhs );
    }

    /* push the right hand side again                                      */
    PushObj( rhs );
}

void            IntrAsssPosObj ( void )
{
    Obj                 list;           /* list                            */
    Obj                 poss;           /* positions                       */
    Obj                 rhss;           /* right hand sides                */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAsssPosObj(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand sides                                            */
    rhss = PopObj();
    if ( ! IS_DENSE_LIST( rhss ) ) {
        ErrorQuit(
            "PosObj Assignment: <rhss> must be a dense list",
            0L, 0L );
    }

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
    "PosObj Assignment: <positions> must be a dense list of positive integers",
               0L, 0L );
    }
    if ( LEN_LIST( poss ) != LEN_LIST( rhss ) ) {
        ErrorQuit(
     "PosObj Assignment: <rhss> must have the same length as <positions> (%d)",
            (Int)LEN_LIST(poss), 0L );
    }

    /* get the list (checking is done by 'ASSS_LIST')                      */
    list = PopObj();

    /* assign to several elements of the list                              */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        ErrorQuit( "sorry: <posobj>!{<poss>} not yet implemented", 0L, 0L );
    }
    else {
        ASSS_LIST( list, poss, rhss );
    }

    /* push the right hand sides again                                     */
    PushObj( rhss );
}

void            IntrAssPosObjLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as C integer          */
    Obj                 rhss;           /* right hand sides, right operand */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssPosObjLevel( level ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get right hand sides (checking is done by 'AssPosObjLevel')           */
    rhss = PopObj();

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
         "PosObj Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ(pos);

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'AssPosObjLevel')     */
    lists = PopObj();

    /* assign the right hand sides to the elements of several lists        */
    ErrorQuit(
        "sorry: <lists>{<poss>}![<pos>] not yet implemented",
        0L, 0L );

    /* push the assigned values again                                      */
    PushObj( rhss );
}

void            IntrAsssPosObjLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAsssPosObjLevel( level ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get right hand sides (checking is done by 'AsssPosObjLevel')          */
    rhss = PopObj();

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
    "PosObj Assignment: <positions> must be a dense list of positive integers",
            0L, 0L );
    }

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'AsssPosObjLevel')    */
    lists = PopObj();

    /* assign the right hand sides to several elements of several lists    */
    ErrorQuit(
        "sorry: <lists>{<poss>}!{<poss>} not yet implemented",
        0L, 0L );

    /* push the assigned values again                                      */
    PushObj( rhss );
}

void            IntrUnbPosObj ( void )
{
    Obj                 list;           /* list                            */
    Obj                 pos;            /* position                        */
    Int                 p;              /* position, as a C integer        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeUnbPosObj(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
         "PosObj Assignment: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ(pos);

    /* get the list (checking is done by 'UNB_LIST')                       */
    list = PopObj();

    /* unbind the element                                                  */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        if ( p <= SIZE_OBJ(list)/sizeof(Obj)-1 ) {
            SET_ELM_PLIST( list, p, 0 );
        }
    }
    else {
        UNB_LIST( list, p );
    }

    /* push void                                                           */
    PushVoidObj();
}


/****************************************************************************
**
*F  IntrElmPosObj() . . . . . . . . . . . . . . interpret selection of a list
*F  IntrElmsPosObj()  . . . . . . . .  interpret multiple selection of a list
*F  IntrElmPosObjLevel(<level>) . . . .  interpret selection of several lists
*F  IntrElmsPosObjLevel(<level>)  .  intr multiple selection of several lists
*/
void            IntrElmPosObj ( void )
{
    Obj                 elm;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmPosObj(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
            "PosObj Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ( pos );

    /* get the list (checking is done by 'ELM_LIST')                       */
    list = PopObj();

    /* get the element of the list                                         */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        if ( SIZE_OBJ(list)/sizeof(Obj)-1 < p ) {
            ErrorQuit(
                "PosObj Element: <posobj>![%d] must have an assigned value",
                (Int)p, 0L );
        }
        elm = ELM_PLIST( list, p );
        if ( elm == 0 ) {
            ErrorQuit(
                "PosObj Element: <posobj>![%d] must have an assigned value",
                (Int)p, 0L );
        }
    }
    else {
        elm = ELM_LIST( list, p );
    }

    /* push the element                                                    */
    PushObj( elm );
}

void            IntrElmsPosObj ( void )
{
    Obj                 elms;           /* elements, result                */
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, right operand        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmsPosObj(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
      "PosObj Elements: <positions> must be a dense list of positive integers",
            0L, 0L );
    }

    /* get the list (checking is done by 'ELMS_LIST')                      */
    list = PopObj();

    /* select several elements from the list                               */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        elms = 0;
        ErrorQuit( "sorry: <posobj>!{<poss>} not yet implemented", 0L, 0L );
    }
    else {
        elms = ELMS_LIST( list, poss );
    }

    /* push the elements                                                   */
    PushObj( elms );
}

void            IntrElmPosObjLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmPosObjLevel( level ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
            "PosObj Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ( pos );

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'ElmPosObjLevel')     */
    lists = PopObj();

    /* select the elements from several lists (store them in <lists>)      */
    ErrorQuit(
        "sorry: <lists>{<poss>}![<pos>] not yet implemented",
        0L, 0L );

    /* push the elements                                                   */
    PushObj( lists );
}

void            IntrElmsPosObjLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* positions, right operand        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmsPosObjLevel( level ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
      "PosObj Elements: <positions> must be a dense list of positive integers",
            0L, 0L );
    }

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'ElmsPosObjLevel')    */
    lists = PopObj();

    /* select several elements from several lists (store them in <lists>)  */
    ErrorQuit(
        "sorry: <lists>{<poss>}!{<poss>} not yet implemented",
        0L, 0L );

    /* push the elements                                                   */
    PushObj( lists );
}

void            IntrIsbPosObj ( void )
{
    Obj                 isb;            /* isbound, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIsbPosObj(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_INTOBJ(pos) || INT_INTOBJ(pos) <= 0 ) {
        ErrorQuit(
            "PosObj Element: <position> must be a positive integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L );
    }
    p = INT_INTOBJ( pos );

    /* get the list (checking is done by 'ISB_LIST')                       */
    list = PopObj();

    /* get the result                                                      */
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        isb = (p <= SIZE_OBJ(list)/sizeof(Obj)-1 && ELM_PLIST(list,p) != 0 ?
               True : False);
    }
    else {
        isb = (ISB_LIST( list, p ) ? True : False);
    }

    /* push the result                                                     */
    PushObj( isb );
}


/****************************************************************************
**
*F  IntrAssComObjName(<rnam>) . . . . . . .  interpret assignment to a record
*F  IntrAssComObjExpr() . . . . . . . . . .  interpret assignment to a record
*/
void            IntrAssComObjName (
    UInt                rnam )
{
    Obj                 record;         /* record, left operand            */
    Obj                 rhs;            /* rhs, right operand              */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssComObjName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand side                                             */
    rhs = PopObj();

    /* get the record (checking is done by 'ASS_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        AssPRec( record, rnam, rhs );
    }
    else {
        ASS_REC( record, rnam, rhs );
    }

    /* push the assigned value                                             */
    PushObj( rhs );
}

void            IntrAssComObjExpr ( void )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssComObjExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the right hand side                                             */
    rhs = PopObj();

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ASS_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        AssPRec( record, rnam, rhs );
    }
    else {
        ASS_REC( record, rnam, rhs );
    }

    /* push the assigned value                                             */
    PushObj( rhs );
}

void            IntrUnbComObjName (
    UInt                rnam )
{
    Obj                 record;         /* record, left operand            */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeUnbComObjName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the record (checking is done by 'UNB_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        UnbPRec( record, rnam );
    }
    else {
        UNB_REC( record, rnam );
    }

    /* push void                                                           */
    PushVoidObj();
}

void            IntrUnbComObjExpr ( void )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeUnbComObjExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'UNB_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        UnbPRec( record, rnam );
    }
    else {
        UNB_REC( record, rnam );
    }

    /* push void                                                           */
    PushVoidObj();
}


/****************************************************************************
**
*F  IntrElmComObjName(<rnam>) . . . . . . . . interpret selection of a record
*F  IntrElmComObjExpr() . . . . . . . . . . . interpret selection of a record
*/
void            IntrElmComObjName (
    UInt                rnam )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmComObjName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the record (checking is done by 'ELM_REC')                      */
    record = PopObj();

    /* select the element of the record                                    */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        elm = ElmPRec( record, rnam );
    }
    else {
        elm = ELM_REC( record, rnam );
    }

    /* push the element                                                    */
    PushObj( elm );
}

void            IntrElmComObjExpr ( void )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeElmComObjExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ELM_REC')                      */
    record = PopObj();

    /* select the element of the record                                    */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        elm = ElmPRec( record, rnam );
    }
    else {
        elm = ELM_REC( record, rnam );
    }

    /* push the element                                                    */
    PushObj( elm );
}

void            IntrIsbComObjName (
    UInt                rnam )
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIsbComObjName( rnam ); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the record (checking is done by 'ISB_REC')                      */
    record = PopObj();

    /* get the result                                                      */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        isb = (IsbPRec( record, rnam ) ? True : False);
    }
    else {
        isb = (ISB_REC( record, rnam ) ? True : False);
    }

    /* push the result                                                     */
    PushObj( isb );
}

void            IntrIsbComObjExpr ( void )
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeIsbComObjExpr(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ISB_REC')                      */
    record = PopObj();

    /* get the result                                                      */
    if ( TYPE_OBJ(record) == T_COMOBJ ) {
        isb = (IsbPRec( record, rnam ) ? True : False);
    }
    else {
        isb = (ISB_REC( record, rnam ) ? True : False);
    }

    /* push the result                                                     */
    PushObj( isb );
}

/****************************************************************************
**
*F  IntrInfoBegin() . . . . . . . . .  start interpretation of Info statement
*F  IntrInfoMiddle()  . . . . . .  shift to interpreting printable statements
*F  IntrInfoEnd( <narg> ) . . Info statement complete, <narg> things to print
*V  InfoDecision . . . . . . . . . . .  fopy of the InfoDecision GAP function
*V  InfoDoPrint  . . . . . . . . . . . . fopy of the InfoDoPrint GAP function
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


void            IntrInfoBegin( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeInfoBegin(); return; }
    if ( CompNowFuncs != 0 ) { return; }
}

Obj             InfoDecision;

void            IntrInfoMiddle( void )
{

    Obj selectors;   /* first argument of Info */
    Obj level;       /* second argument of Info */
    Obj selected;    /* GAP Boolean answer to whether this message
			gets printed or not */
  
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { IntrIgnoring++; return; }
    if ( IntrCoding    > 0 ) { CodeInfoMiddle(); return; }
    if ( CompNowFuncs != 0 ) { return; }
    
    level = PopObj();
    selectors = PopObj();
    selected = CALL_2ARGS( InfoDecision, selectors, level);
    if (selected == False)
      IntrIgnoring = 1;
    return;
}

Obj             InfoDoPrint;

void            IntrInfoEnd( UInt narg )
{

     Obj args;    /* gathers up the arguments to be printed */
       
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeInfoEnd( narg ); return; }
    if ( CompNowFuncs != 0 ) { return; }
    
    /* print if necessary                                                  */
    if ( IntrIgnoring  > 0 )
      IntrIgnoring--;
    else
      {
	args = NEW_PLIST( T_PLIST, narg);
	SET_LEN_PLIST(args, narg);
	
	while (narg > 0)
	  SET_ELM_PLIST(args, narg--, PopObj());
	
	CALL_1ARGS(InfoDoPrint, args);
      }

    /* If we actually executed this statement at all
       (even if we printed nothing) then return a Void */
    if (IntrIgnoring == 0)
      PushVoidObj();
    return;
}
  

/****************************************************************************
**
*F  IntrAssertBegin()  . . . . . . . start interpretation of Assert statement
*F  IntrAsseerAfterLevel() . .  called after the first argument has been read
**
**  At this stage, we can decide whether to evaluate the second argument --
**   the check in question
**
*F  IntrAssertAfterCondition() called after the second argument has been read
**
**  At this point we know whether there is an assertion failure. We still need
**  to read the third argument if any, to decide what to do about it One of:
**
*F  IntrAssertEnd2Args() . . . . called after reading the closing parenthesis
*F  IntrAssertEnd3Args() . . . . called after reading the closing parenthesis
**
*V  CurrentAssertionLevel  . .  . . . . . . . . . . . .  copy of GAP variable
**
**
**  IntrIgnoring is increased by (a total of) 2 if an assertion either is not
**  tested (because we were Ignoring when we got to it, or due to level)
**  or is tested and passes
*/

Obj              CurrentAssertionLevel;

void              IntrAssertBegin ( void )
{
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssertBegin(); return; }
    if ( CompNowFuncs != 0 ) { return; }
}


void             IntrAssertAfterLevel ( void )
{
  Obj level;
  
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { IntrIgnoring++; return; }
    if ( IntrCoding    > 0 ) { CodeAssertAfterLevel(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    level = PopObj();

    if (LT( CurrentAssertionLevel, level))
	   IntrIgnoring = 1;
}   

void             IntrAssertAfterCondition ( void )
{
  Obj condition;
  
    /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrIgnoring  > 0 ) { IntrIgnoring++; return; }
    if ( IntrCoding    > 0 ) { CodeAssertAfterCondition(); return; }
    if ( CompNowFuncs != 0 ) { return; }

    condition = PopObj();

    if (condition == True)
      IntrIgnoring= 2;
    else if (condition != False)
        ErrorQuit(
            "<condition> in Assert must yield 'true' or 'false' (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(condition)].name), 0L );
}   

void             IntrAssertEnd2Args ( void )
{
      /* ignore or code                                                      */
    if ( IntrReturning > 0 ) { return; }
    if ( IntrCoding    > 0 ) { CodeAssertEnd2Args(); return; }
    if ( CompNowFuncs != 0 ) { return; }
    
    if ( IntrIgnoring  == 0 )
      ErrorQuit("Assertion Failure", 0, 0);
    else
      IntrIgnoring -= 2;
    
    if (IntrIgnoring == 0)
      PushVoidObj();
    return;
}

    
void             IntrAssertEnd3Args ( void )
{
  Obj message;
  /* ignore or code                                                      */
  if ( IntrReturning > 0 ) { return; }
  if ( IntrCoding    > 0 ) { CodeAssertEnd3Args(); return; }
  if ( CompNowFuncs != 0 ) { return; }
  
  if ( IntrIgnoring  == 0 )
    {
      message = PopVoidObj();
      if (message != (Obj) 0)
	PrintObj(message);
    }
  else
    IntrIgnoring -= 2;
  
  if (IntrIgnoring == 0)
      PushVoidObj();
  return;
}



/****************************************************************************
**
*F  InitIntrprtr()  . . . . . . . . . . . . . . .  initialize the interpreter
**
**  'InitIntrprtr' initializes the interpreter.
*/
void InitIntrprtr ( void )
{
    UInt	    lev;

    InitGlobalBag( &IntrResult, "interpreter: result"       );
    InitGlobalBag( &IntrState,  "interpreter: state"        );
    InitGlobalBag( &StackObj,   "interpreter: object stack" );

    /* The work of handling Info messages is delegated to the GAP level */
    ImportFuncFromLibrary( "InfoDecision", &InfoDecision );
    ImportFuncFromLibrary( "InfoDoPrint",  &InfoDoPrint  );

    /* The Assertion level is also controlled at GAP level */
    lev = GVarName("CurrentAssertionLevel");
    InitCopyGVar( lev, &CurrentAssertionLevel );
    AssGVar( lev, INTOBJ_INT(0) );
}



