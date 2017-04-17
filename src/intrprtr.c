/****************************************************************************
**
*W  intrprtr.c                  GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the immediate interpreter package.
**
**  The immediate interpreter package  is  the part  of the interpreter  that
**  interprets code immediately (while it is read).  Its functions are called
**  from the reader.  When it encounters  constructs that it cannot interpret
**  immediately, it switches into coding mode, and  delegates the work to the
**  coder.
*/
#include <assert.h>                     /* assert */
#include <src/system.h>                 /* Ints, UInts */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */
#include <src/read.h>                   /* reader */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */
#include <src/records.h>                /* generic records */
#include <src/lists.h>                  /* generic lists */

#include <src/bool.h>                   /* booleans */
#include <src/gmpints.h>                /* integers */

#include <src/permutat.h>               /* permutations */
#include <src/trans.h>                  /* transformations */
#include <src/pperm.h>                  /* partial perms */

#include <src/precord.h>                /* plain records */

#include <src/plist.h>                  /* plain lists */
#include <src/range.h>                  /* ranges */
#include <src/stringobj.h>              /* strings */

#include <src/code.h>                   /* coder */
#include <src/funcs.h>                  /* functions */
#include <src/read.h>

#include <src/intrprtr.h>               /* interpreter */

#include <src/hpc/tls.h>
#include <src/hpc/thread.h>
#include <src/hpc/aobjects.h>           /* atomic objects */

#include <src/vars.h>                   /* variables */

#include <src/saveload.h>               /* saving and loading */

/****************************************************************************
**

*V  IntrResult  . . . . . . . . . . . . . . . . . result value of interpreter
**
**  'IntrResult'  is the result value of  the interpreter, i.e., the value of
**  the  statement  that  was  last  interpreted (which   might  have been  a
**  return-value-statement).
*/
/* TL: Obj IntrResult; */


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
/* TL: UInt IntrReturning; */


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
/* TL: UInt IntrIgnoring; */


/****************************************************************************
**
*V  IntrCoding  . . . . . . . . . . . interpreter is currently coding actions
**
**  If 'IntrCoding' is non-zero, the interpreter is currently coding actions.
**  The interpreter  switches  to this  mode for  constructs  that it  cannot
**  directly interpret, such as loops or function bodies.
*/
/* TL: UInt IntrCoding; */


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
/* TL: Obj             IntrState; */

/* TL: Obj             StackObj; */

/* TL: Int             CountObj; */

void            PushObj (
    Obj                 val )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( STATE(StackObj) != 0 );
    assert( 0 <= STATE(CountObj) && STATE(CountObj) == LEN_PLIST(STATE(StackObj)) );
    assert( val != 0 );

    /* count up and put the value onto the stack                           */
    STATE(CountObj)++;
    GROW_PLIST(    STATE(StackObj), STATE(CountObj) );
    SET_LEN_PLIST( STATE(StackObj), STATE(CountObj) );
    SET_ELM_PLIST( STATE(StackObj), STATE(CountObj), val );
    CHANGED_BAG(   STATE(StackObj) );
}

/* Special marker value to denote that a function returned no value, so we
 * can produce a useful error message. This value only ever appears on the
 * stack, and should never be visible outside the Push and Pop methods below
 *
 * The only place other than these methods which access the stack is
 * the permutation reader, but it only directly accesses values it wrote,
 * so it will not see this magic value. */
Obj VoidReturnMarker;

void            PushFunctionVoidReturn ( void )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( STATE(StackObj) != 0 );
    assert( 0 <= STATE(CountObj) && STATE(CountObj) == LEN_PLIST(STATE(StackObj)) );

    /* count up and put the void value onto the stack                      */
    STATE(CountObj)++;
    GROW_PLIST(    STATE(StackObj), STATE(CountObj) );
    SET_LEN_PLIST( STATE(StackObj), STATE(CountObj) );
    SET_ELM_PLIST( STATE(StackObj), STATE(CountObj), (Obj)&VoidReturnMarker );
}

void            PushVoidObj ( void )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( STATE(StackObj) != 0 );
    assert( 0 <= STATE(CountObj) && STATE(CountObj) == LEN_PLIST(STATE(StackObj)) );

    /* count up and put the void value onto the stack                      */
    STATE(CountObj)++;
    GROW_PLIST(    STATE(StackObj), STATE(CountObj) );
    SET_LEN_PLIST( STATE(StackObj), STATE(CountObj) );
    SET_ELM_PLIST( STATE(StackObj), STATE(CountObj), (Obj)0 );
}

Obj             PopObj ( void )
{
    Obj                 val;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    assert( STATE(StackObj) != 0 );
    assert( 1 <= STATE(CountObj) && STATE(CountObj) == LEN_LIST(STATE(StackObj)) );

    /* get the top element from the stack and count down                   */
    val = ELM_PLIST( STATE(StackObj), STATE(CountObj) );
    SET_ELM_PLIST( STATE(StackObj), STATE(CountObj), 0 );
    SET_LEN_PLIST( STATE(StackObj), STATE(CountObj)-1  );
    STATE(CountObj)--;

    if(val == (Obj)&VoidReturnMarker) {
        ErrorQuit(
            "Function call: <func> must return a value",
            0L, 0L );
    }
    /* return the popped value (which must be non-void)                    */
    assert( val != 0 );
    return val;
}

Obj             PopVoidObj ( void )
{
    Obj                 val;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    assert( STATE(StackObj) != 0 );
    assert( 1 <= STATE(CountObj) && STATE(CountObj) == LEN_LIST(STATE(StackObj)) );

    /* get the top element from the stack and count down                   */
    val = ELM_PLIST( STATE(StackObj), STATE(CountObj) );
    SET_ELM_PLIST( STATE(StackObj), STATE(CountObj), 0 );
    SET_LEN_PLIST( STATE(StackObj), STATE(CountObj)-1  );
    STATE(CountObj)--;

    /* Treat a function which returned no value the same as 'void'         */
    if(val == (Obj)&VoidReturnMarker) {
        val = 0;
    }

    /* return the popped value (which may be void)                         */
    return val;
}


/****************************************************************************
**

*F  IntrBegin() . . . . . . . . . . . . . . . . . . . .  start an interpreter
*F  IntrEnd( <error> )  . . . . . . . . . . . . . . . . . stop an interpreter
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
**  interpreted and in this case the  return value is stored in 'STATE(IntrResult)'.
**  If  'IntrEnd' returns 2, then a  return-void-statement  was  interpreted.
**  If 'IntrEnd' returns 8, then a quit-statement was interpreted.
*/
void IntrBegin ( Obj frame )
{
    Obj                 intrState;      /* old interpreter state           */

    /* remember old interpreter state                                      */
    /* This bag cannot exist at the top-most loop, which is the only
       place from which we might call SaveWorkspace */
    intrState = NewBag( T_PLIST, 4*sizeof(Obj) );
    ADDR_OBJ(intrState)[0] = (Obj)3;
    ADDR_OBJ(intrState)[1] = STATE(IntrState);
    ADDR_OBJ(intrState)[2] = STATE(StackObj);
    ADDR_OBJ(intrState)[3] = INTOBJ_INT(STATE(CountObj));
    STATE(IntrState) = intrState;

    /* allocate a new values stack                                         */
    STATE(StackObj) = NEW_PLIST( T_PLIST, 64 );
    SET_LEN_PLIST( STATE(StackObj), 0 );
    STATE(CountObj) = 0;

    /* must be in immediate (non-ignoring, non-coding) mode                */
    assert( STATE(IntrIgnoring) == 0 );
    assert( STATE(IntrCoding)   == 0 );

    /* no return-statement was yet interpreted                             */
    STATE(IntrReturning) = 0;

    /* start an execution environment                                      */
    ExecBegin(frame);
}

ExecStatus IntrEnd (
    UInt                error )
{
    UInt                intrReturning;  /* interpreted return-statement?   */

    /* if everything went fine                                             */
    if ( ! error ) {

        /* leave the execution environment                                 */
        ExecEnd( 0UL );

        /* remember whether the interpreter interpreted a return-statement */
        intrReturning = STATE(IntrReturning);
        STATE(IntrReturning) = 0;

        /* must be back in immediate (non-ignoring, non-coding) mode       */
        assert( STATE(IntrIgnoring) == 0 );
        assert( STATE(IntrCoding)   == 0 );

        /* and the stack must contain the result value (which may be void) */
        assert( STATE(CountObj) == 1 );
        STATE(IntrResult) = PopVoidObj();

        /* switch back to the old state                                    */
        STATE(CountObj)  = INT_INTOBJ( ADDR_OBJ(STATE(IntrState))[3] );
        STATE(StackObj)  = ADDR_OBJ(STATE(IntrState))[2];
        STATE(IntrState) = ADDR_OBJ(STATE(IntrState))[1];

    }

    /* otherwise clean up the mess                                         */
    else {

        /* leave the execution environment                                 */
        ExecEnd( 1UL );

        /* clean up the coder too                                          */
        if ( STATE(IntrCoding) > 0 ) { CodeEnd( 1UL ); }

        /* remember that we had an error                                   */
        intrReturning = STATUS_ERROR;
        STATE(IntrReturning) = 0;

        /* must be back in immediate (non-ignoring, non-coding) mode       */
        STATE(IntrIgnoring) = 0;
        STATE(IntrCoding)   = 0;

        /* dummy result value (probably ignored)                           */
        STATE(IntrResult) = (Obj)0;

        /* switch back to the old state                                    */
        STATE(CountObj)  = INT_INTOBJ( ADDR_OBJ(STATE(IntrState))[3] );
        STATE(StackObj)  = ADDR_OBJ(STATE(IntrState))[2];
        STATE(IntrState) = ADDR_OBJ(STATE(IntrState))[1];

    }

    /* indicate whether a return-statement was interpreted                 */
    return intrReturning;
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
void            IntrFuncCallBegin ( void )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeFuncCallBegin(); return; }

}

static Obj PushOptions;
static Obj PopOptions;

void            IntrFuncCallEnd (
    UInt                funccall,
    UInt                options,
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
    Obj                 opts;           /* record of options               */
    UInt                i;              /* loop variable                   */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) {
      CodeFuncCallEnd( funccall, options, nr );
      return; }


    if (options) {
        opts = PopObj();
        CALL_1ARGS(PushOptions, opts);
    }

    /* get the arguments from the stack                                    */
    a1 = a2 = a3 = a4 = a5 = a6 = args = 0;
    if ( nr <= 6 ) {
        if ( 6 <= nr ) { a6 = PopObj(); }
        if ( 5 <= nr ) { a5 = PopObj(); }
        if ( 4 <= nr ) { a4 = PopObj(); }
        if ( 3 <= nr ) { a3 = PopObj(); }
        if ( 2 <= nr ) { a2 = PopObj(); }
        if ( 1 <= nr ) { a1 = PopObj(); }
    } else {
        args = NEW_PLIST( T_PLIST, nr );
        SET_LEN_PLIST( args, nr );
        for ( i = nr; 1 <= i; i-- ) {
            argi = PopObj();
            SET_ELM_PLIST( args, i, argi );
        }
    }

    /* get and check the function from the stack                           */
    func = PopObj();
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
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
      val = DoOperation2Args(CallFuncListOper, func, args);
    } else {
      /* call the function                                                   */
      if      ( 0 == nr ) { val = CALL_0ARGS( func ); }
      else if ( 1 == nr ) { val = CALL_1ARGS( func, a1 ); }
      else if ( 2 == nr ) { val = CALL_2ARGS( func, a1, a2 ); }
      else if ( 3 == nr ) { val = CALL_3ARGS( func, a1, a2, a3 ); }
      else if ( 4 == nr ) { val = CALL_4ARGS( func, a1, a2, a3, a4 ); }
      else if ( 5 == nr ) { val = CALL_5ARGS( func, a1, a2, a3, a4, a5 ); }
      else if ( 6 == nr ) { val = CALL_6ARGS( func, a1, a2, a3, a4, a5, a6 ); }
      else                { val = CALL_XARGS( func, args ); }

      if (STATE(UserHasQuit) || STATE(UserHasQUIT)) {
        /* the procedure must have called READ() and the user quit
           from a break loop inside it */
        ReadEvalError();
      }
    }

    if (options)
      CALL_0ARGS(PopOptions);

    /* push the value onto the stack                                       */
    if ( val == 0 )
        PushFunctionVoidReturn();
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
    Obj                 nams,
    Int                 startLine)
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) {
        STATE(IntrCoding)++;
        CodeFuncExprBegin( narg, nloc, nams, startLine );
        return;
    }

    /* switch to coding mode now                                           */
    CodeBegin();
    STATE(IntrCoding) = 1;

    /* code a function expression                                          */
    CodeFuncExprBegin( narg, nloc, nams, startLine );
}

void            IntrFuncExprEnd (
    UInt                nr,
    UInt                mapsto )
{
    Obj                 func;           /* the function, result            */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 1 ) {
        STATE(IntrCoding)--;
        CodeFuncExprEnd( nr, mapsto );
        return;
    }

    /* must be coding                                                      */
    assert( STATE(IntrCoding) > 0 );

    /* code a function expression                                          */
    CodeFuncExprEnd( nr, mapsto );

    /* switch back to immediate mode, get the function                     */
    CodeEnd(0);
    STATE(IntrCoding) = 0;
    func = STATE(CodeResult);

    /* push the function                                                   */
    PushObj(func);
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)++; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIfBegin(); return; }

}

void            IntrIfElif ( void )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIfElif(); return; }

}

void            IntrIfElse ( void )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIfElse(); return; }


    /* push 'true' (to execute body of else-branch)                        */
    PushObj( True );
}

void            IntrIfBeginBody ( void )
{
    Obj                 cond;           /* value of condition              */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)++; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIfBeginBody(); return; }


    /* get and check the condition                                         */
    cond = PopObj();
    if ( cond != True && cond != False ) {
        ErrorQuit(
            "<expr> must be 'true' or 'false' (not a %s)",
            (Int)TNAM_OBJ(cond), 0L );
    }

    /* if the condition is 'false', ignore the body                        */
    if ( cond == False ) {
        STATE(IntrIgnoring) = 1;
    }
}

void            IntrIfEndBody (
    UInt                nr )
{
    UInt                i;              /* loop variable                   */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 1 ) { STATE(IntrIgnoring)--; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIfEndBody( nr ); return; }


    /* if the condition was 'false', the body was ignored                  */
    if ( STATE(IntrIgnoring) == 1 ) {
        STATE(IntrIgnoring) = 0;
        return;
    }

    /* otherwise drop the values for the statements executed in the body   */
    for ( i = nr; 1 <= i; i-- ) {
        PopVoidObj();
    }

    /* one branch of the if-statement was executed, ignore the others      */
    STATE(IntrIgnoring) = 1;
}

void            IntrIfEnd (
    UInt                nr )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 1 ) { STATE(IntrIgnoring)--; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIfEnd( nr ); return; }


    /* if one branch was executed (ignoring the others)                    */
    if ( STATE(IntrIgnoring) == 1 ) {
        STATE(IntrIgnoring) = 0;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { STATE(IntrCoding)++; CodeForBegin(); return; }


    /* switch to coding mode now                                           */
    CodeBegin();
    STATE(IntrCoding) = 1;

    /* code a function expression (with no arguments and locals)           */
    nams = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( nams, 0 );

    /* If we are in the break loop, then a local variable context may well exist,
       and we have to create an empty local variable names list to match the
       function expression that we are creating.

       If we are not in a break loop, then this would be a waste of time and effort */

    if (STATE(CountNams) > 0) {
        GROW_PLIST(STATE(StackNams), ++STATE(CountNams));
        SET_ELM_PLIST(STATE(StackNams), STATE(CountNams), nams);
        SET_LEN_PLIST(STATE(StackNams), STATE(CountNams));
    }

    CodeFuncExprBegin( 0, 0, nams, 0 );

    /* code a for loop                                                     */
    CodeForBegin();
}

void IntrForIn ( void )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }


    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );
    CodeForIn();
}

void IntrForBeginBody ( void )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }


    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );
    CodeForBeginBody();
}

void IntrForEndBody (
    UInt                nr )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( STATE(IntrCoding) != 0 ) {
        CodeForEndBody( nr );
    }
}

void IntrForEnd ( void )
{
    Obj                 func;           /* the function, result            */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 1 ) { STATE(IntrCoding)--; CodeForEnd(); return; }


    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );

    /* code a function expression (with one statement in the body)         */
    CodeFuncExprEnd( 1UL, 0UL );

    /* switch back to immediate mode, get the function                     */
    STATE(IntrCoding) = 0;
    CodeEnd( 0 );
    /* If we are in a break loop, then we will have created a "dummy" local
       variable names list to get the counts right. Remove it */
    if (STATE(CountNams) > 0)
      STATE(CountNams)--;

    func = STATE(CodeResult);

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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { STATE(IntrCoding)++; CodeWhileBegin(); return; }


    /* switch to coding mode now                                           */
    CodeBegin();
    STATE(IntrCoding) = 1;

    /* code a function expression (with no arguments and locals)           */
    nams = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( nams, 0 );

    /* If we are in the break loop, then a local variable context may well exist,
       and we have to create an empty local variable names list to match the
       function expression that we are creating.

       If we are not in a break loop, then this would be a waste of time and effort */

    if (STATE(CountNams) > 0) {
        GROW_PLIST(STATE(StackNams), ++STATE(CountNams));
        SET_ELM_PLIST(STATE(StackNams), STATE(CountNams), nams);
        SET_LEN_PLIST(STATE(StackNams), STATE(CountNams));
    }

    CodeFuncExprBegin( 0, 0, nams, 0 );

    /* code a while loop                                                   */
    CodeWhileBegin();
}

void            IntrWhileBeginBody ( void )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }


    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );
    CodeWhileBeginBody();
}

void            IntrWhileEndBody (
    UInt                nr )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );
    CodeWhileEndBody( nr );
}

void            IntrWhileEnd ( void )
{
    Obj                 func;           /* the function, result            */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 1 ) { STATE(IntrCoding)--; CodeWhileEnd(); return; }


    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );
    CodeWhileEnd();

    /* code a function expression (with one statement in the body)         */
    CodeFuncExprEnd( 1UL, 0UL );


    /* switch back to immediate mode, get the function                     */
    STATE(IntrCoding) = 0;
    CodeEnd( 0 );

    /* If we are in a break loop, then we will have created a "dummy" local
       variable names list to get the counts right. Remove it */
    if (STATE(CountNams) > 0)
      STATE(CountNams)--;

    func = STATE(CodeResult);


    /* call the function                                                   */
    CALL_0ARGS( func );

    /* push void                                                           */
    PushVoidObj();
}


/****************************************************************************
**
*F  IntrQualifiedExprBegin( UInt qual ) . . . . . . interpret expression guarded
**                                       by readwrite or readonlu
*F  IntrQualifiedExprEnd( ) 
**                                       by readwrite or readonlu
**
*/

void IntrQualifiedExprBegin(UInt qual) 
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)++; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeQualifiedExprBegin(qual); return; }
    PushObj(INTOBJ_INT(qual));
    return;
}

void IntrQualifiedExprEnd( void ) 
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)--; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeQualifiedExprEnd(); return; }
    return;
}

/****************************************************************************
**
*F  IntrAtomicBegin()  . . . . . interpret atomic-statement, begin of statement
*F  IntrAtomicBeginBody(<nrexprs>)  . . . . .  interpret atomic-statement, begin of body
*F  IntrAtomicEndBody(<nrstats>)  . . . . .  interpret atomic-statement, end of body
*F  IntrAtomicEnd()  . . . . . . . interpret atomic-statement, end of statement
**
**  'IntrAtomicBegin' is   an action to  interpret   a atomic-statement.  It is
**  called when the    reader encounters the    'atomic', i.e., *before*   the
**  expressions to be locked are read.
**
**  'IntrAtomicBeginBody' is an action  to interpret a atomic-statement.  It is
**  called when the reader encounters  the  beginning of the statement  body,
**  i.e., *after* the expressions to be locked are read. <nrexprs> is the number
** of expressions to be locked
**
**  'IntrAtomicEndBody' is  an action to interpret   a atomic-statement.  It is
**  called when the reader encounters the end of the statement body.  <nrstats> is
**  the number of statements in the body.
**
**  'IntrAtomicEnd' is an action to interpret a atomic-statement.  It is called
**  when  the reader encounters  the  end of  the  statement, i.e., immediate
**  after 'IntrAtomicEndBody'.
**
**  These functions only do something meaningful inside HPC-GAP; in plain GAP,
**  they are simply placeholders.
*/
void            IntrAtomicBegin ( void )
{

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAtomicBegin(); return; }
    /* nothing to do here */
    return;
  
}

void            IntrAtomicBeginBody ( UInt nrexprs )
{
  Obj nams;

    /* ignore    or code                                                          */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { STATE(IntrCoding)++; CodeAtomicBeginBody(nrexprs); return; }


    /* leave the expressions and qualifiers on the stack, switch to coding to process the body
       of the Atomic expression */
    PushObj(INTOBJ_INT(nrexprs));
    CodeBegin();
    STATE(IntrCoding) = 1;
    
    
    /* code a function expression (with no arguments and locals)           */
    
    nams = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( nams, 0 );
    
    /* If we are in the break loop, then a local variable context may well exist,
       and we have to create an empty local variable names list to match the
       function expression that we are creating.
       
       If we are not in a break loop, then this would be a waste of time and effort */
    
    if (STATE(CountNams) > 0) {
      GROW_PLIST(STATE(StackNams), ++STATE(CountNams));
      SET_ELM_PLIST(STATE(StackNams), STATE(CountNams), nams);
      SET_LEN_PLIST(STATE(StackNams), STATE(CountNams));
    }
    
    CodeFuncExprBegin( 0, 0, nams, STATE(Input)->number );
}

void            IntrAtomicEndBody (
    Int                nrstats )
{
  Obj body;

    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    if (STATE(IntrCoding) == 1) {
      /* This is the case where we are really immediately interpreting an atomic
	 statement, but we switched to coding to store the body until we have it all */

    /* If we are in a break loop, then we will have created a "dummy" local
       variable names list to get the counts right. Remove it */
      if (STATE(CountNams) > 0)
        STATE(CountNams)--;

      /* Code the body as a function expression */
      CodeFuncExprEnd( nrstats, 0UL );
    

      /* switch back to immediate mode, get the function                     */
      STATE(IntrCoding) = 0;
      CodeEnd( 0 );
      body = STATE(CodeResult);
      PushObj(body);
      return;
    } else {
      
        assert( STATE(IntrCoding) > 0 );
        CodeAtomicEndBody( nrstats );
    }
}


void            IntrAtomicEnd ( void )
{
    Obj                 body;           /* the function, result            */
    UInt                nrexprs;
    UInt                i;

#ifdef HPCGAP
    UInt                mode,j;
    Obj tolock[MAX_ATOMIC_OBJS];
    int locktypes[MAX_ATOMIC_OBJS];
    int lockstatus[MAX_ATOMIC_OBJS];
    int lockSP;
    Obj o;
#endif

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { STATE(IntrCoding)--; CodeAtomicEnd(); return; }
    /* Now we need to recover the objects to lock, and go to work */

    body = PopObj();

    nrexprs = INT_INTOBJ(PopObj());

#ifdef HPCGAP
    j = 0;
    for (i = 0; i < nrexprs; i++) {
      o = PopObj();
      mode = INT_INTOBJ(PopObj());
      if (!((Int)o & 0x3)) {
        tolock[j] =  o;
        locktypes[j++] = (mode == 2) ? 1 : (mode == 1) ? 0 : DEFAULT_LOCK_TYPE;
      }
    }
    nrexprs = j;

    GetLockStatus(nrexprs, tolock, lockstatus);

    j = 0;
    for (i = 0; i < nrexprs; i++) {
      switch (lockstatus[i]) {
      case 0:
        tolock[j] = tolock[i];
        locktypes[j] = locktypes[i];
        j++;
        break;
      case 2:
        if (locktypes[i] == 1)
          ErrorMayQuit("Attempt to change from read to write lock", 0L, 0L);
        break;
      case 1:
          break;
      default:
        assert(0);
      }
    }
    lockSP = LockObjects(j, tolock, locktypes);
    /* Push at least one empty region on the stack so we can tell
     * that we are inside an atomic section. */
    if (j == 0)
      PushRegionLock((Region *) 0);
    if (lockSP >= 0) {
      CALL_0ARGS( body );
      PopRegionLocks(lockSP);
    } else {
      ErrorMayQuit("Cannot lock required regions", 0L, 0L);
    }
#else
    for (i = 0; i < nrexprs; i++) {
      PopObj(); /* pop object */
      PopObj(); /* pop mode */
    }
    
    CALL_0ARGS( body );
#endif

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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { STATE(IntrCoding)++; CodeRepeatBegin(); return; }


    /* switch to coding mode now                                           */
    CodeBegin();
    STATE(IntrCoding) = 1;

    /* code a function expression (with no arguments and locals)           */
    nams = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( nams, 0 );

    /* If we are in the break loop, then a local variable context may well exist,
       and we have to create an empty local variable names list to match the
       function expression that we are creating.

       If we are not in a break loop, then this would be a waste of time and effort */

    if (STATE(CountNams) > 0) {
        GROW_PLIST(STATE(StackNams), ++STATE(CountNams));
        SET_ELM_PLIST(STATE(StackNams), STATE(CountNams), nams);
        SET_LEN_PLIST(STATE(StackNams), STATE(CountNams));
    }

    CodeFuncExprBegin( 0, 0, nams, STATE(Input)->number );

    /* code a repeat loop                                                  */
    CodeRepeatBegin();
}

void            IntrRepeatBeginBody ( void )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }


    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );
    CodeRepeatBeginBody();
}

void            IntrRepeatEndBody (
    UInt                nr )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );
    CodeRepeatEndBody( nr );
}

void            IntrRepeatEnd ( void )
{
    Obj                 func;           /* the function, result            */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 1 ) { STATE(IntrCoding)--; CodeRepeatEnd(); return; }


    /* otherwise must be coding                                            */
    assert( STATE(IntrCoding) > 0 );
    CodeRepeatEnd();

    /* code a function expression (with one statement in the body)         */
    CodeFuncExprEnd( 1UL, 0UL );

    /* switch back to immediate mode, get the function                     */
    STATE(IntrCoding) = 0;
    CodeEnd( 0 );
    /* If we are in a break loop, then we will have created a "dummy" local
       variable names list to get the counts right. Remove it */
    if (STATE(CountNams) > 0)
      STATE(CountNams)--;
    func = STATE(CodeResult);

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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( STATE(IntrCoding) == 0 )
      ErrorQuit("'break' statement can only appear inside a loop",0L,0L);
    else
      CodeBreak();
    return;
}


/****************************************************************************
**
*F  IntrContinue() . . . . . . . . . . . . . . . . . . interpret continue-statement
**
**  'IntrContinue'  is the action to interpret  a continue-statement.  It is called
**  when the reader encounters a 'continue;'.
**
**  Continue-statements are  always coded (if  they are not ignored), since they
**  can only appear in loops.
*/
void            IntrContinue ( void )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( STATE(IntrCoding) == 0 )
      ErrorQuit("'continue' statement can only appear inside a loop",0L,0L);
    else
      CodeContinue();
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeReturnObj(); return; }


    /* empty the values stack and push the return value                    */
    val = PopObj();
    SET_LEN_PLIST( STATE(StackObj), 0 );
    STATE(CountObj) = 0;
    PushObj( val );

    /* indicate that a return-value-statement was interpreted              */
    STATE(IntrReturning) = 1;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeReturnVoid(); return; }


    /* empty the values stack and push the void value                      */
    SET_LEN_PLIST( STATE(StackObj), 0 );
    STATE(CountObj) = 0;
    PushVoidObj();

    /* indicate that a return-void-statement was interpreted               */
    STATE(IntrReturning) = 2;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* 'quit' is not allowed in functions (by the reader)                  */
    /* assert( STATE(IntrCoding) == 0 ); */
    if ( STATE(IntrCoding) > 0 ) {
      SyntaxError("'quit;' cannot be used in this context");
    }

    /* empty the values stack and push the void value                      */
    SET_LEN_PLIST( STATE(StackObj), 0 );
    STATE(CountObj) = 0;
    PushVoidObj();


    /* indicate that a quit-statement was interpreted                      */
    STATE(IntrReturning) = STATUS_QUIT;
}

/****************************************************************************
**
*F  IntrQUIT()  . . . . . . . . . . . . . . . . . .  interpret quit-statement
**
**  'IntrQUIT' is the  action to interpret   a quit-statement.  It  is called
**  when the reader encounters a 'QUIT;'.
*/
void            IntrQUIT ( void )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* 'quit' is not allowed in functions (by the reader)                  */
    assert( STATE(IntrCoding) == 0 );

    /* empty the values stack and push the void value                      */
    SET_LEN_PLIST( STATE(StackObj), 0 );
    STATE(CountObj) = 0;
    PushVoidObj();


    /* indicate that a quit-statement was interpreted                      */
    STATE(IntrReturning) = STATUS_QQUIT;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)++; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeOrL(); return; }


    /* if the left operand is 'true', ignore the right operand             */
    opL = PopObj();
    PushObj( opL );
    if ( opL == True ) {
        PushObj( opL );
        STATE(IntrIgnoring) = 1;
    }
}

void            IntrOr ( void )
{
    Obj                 opL;            /* value of left  operand          */
    Obj                 opR;            /* value of right operand          */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 1 ) { STATE(IntrIgnoring)--; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeOr(); return; }


    /* stop ignoring things now                                            */
    STATE(IntrIgnoring) = 0;

    /* get the operands                                                    */
    opR = PopObj();
    opL = PopObj();

    /* if the left operand is 'true', this is the result                   */
    if      ( opL == True ) {
        PushObj( opL );
    }

    /* if the left operand is 'false', the result is the right operand     */
    else if ( opL == False  ) {
        if ( opR == True || opR == False  ) {
            PushObj( opR );
        }
        else {
            ErrorQuit( "<expr> must be 'true' or 'false' (not a %s)",
                       (Int)TNAM_OBJ(opR), 0L );
        }
    }

    /* signal an error                                                     */
    else {
        ErrorQuit( "<expr> must be 'true' or 'false' (not a %s)",
                   (Int)TNAM_OBJ(opL), 0L );
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)++; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAndL(); return; }


    /* if the left operand is 'false', ignore the right operand            */
    opL = PopObj();
    PushObj( opL );
    if ( opL == False ) {
        PushObj( opL );
        STATE(IntrIgnoring) = 1;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 1 ) { STATE(IntrIgnoring)--; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAnd(); return; }


    /* stop ignoring things now                                            */
    STATE(IntrIgnoring) = 0;

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
                "<expr> must be 'true' or 'false' (not a %s)",
                (Int)TNAM_OBJ(opR), 0L );
        }
    }

    /* handle the 'and' of two filters                                    */
    else if ( TNUM_OBJ(opL) == T_FUNCTION ) {
        if ( TNUM_OBJ(opR) == T_FUNCTION ) {
            PushObj( NewAndFilter( opL, opR ) );
        }
        else {
            ErrorQuit(
                "<expr> must be 'true' or 'false' (not a %s)",
                (Int)TNAM_OBJ(opL), 0L );
        }
    }

    /* signal an error                                                     */
    else {
        ErrorQuit(
            "<expr> must be 'true' or 'false' (not a %s)",
            (Int)TNAM_OBJ(opL), 0L );
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
    if ( STATE(IntrIgnoring) > 0 ) { return; }
    if ( STATE(IntrCoding)   > 0 ) { CodeNot(); return; }


    /* get and check the operand                                           */
    op = PopObj();
    if ( op != True && op != False ) {
        ErrorQuit(
            "<expr> must be 'true' or 'false' (not a %s)",
            (Int)TNAM_OBJ(op), 0L );
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeEq(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeNe(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeLt(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeGe(); return; }


    /* '<left> >= <right>' is 'not <left> < <right>'                       */
    IntrLt();
    IntrNot();
}

void            IntrGt ( void )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeGt(); return; }


    /* '<left> > <right>' is '<right> < <left>'                            */
    IntrXX();
    IntrLt();
}

void            IntrLe ( void )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeLe(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIn(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeSum(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAInv(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeDiff(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeProd(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeInv(); return; }


    /* get the operand                                                     */
    opL = PopObj();

    /* compute the multiplicative inverse                                  */
    val = INV_MUT( opL );

    /* push the result                                                     */
    PushObj( val );
}

void            IntrQuo ( void )
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* left operand                    */
    Obj                 opR;            /* right operand                   */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeQuo(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeMod(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodePow(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIntExpr( str ); return; }

    
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
            upp = PROD(upp,INTOBJ_INT(pow) );
            upp = SUM(upp  , INTOBJ_INT(sign*low) );
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
        upp =  PROD( upp, INTOBJ_INT(pow) );
        val = SUM( upp , INTOBJ_INT(sign*low) );
    }

    /* push the integer value                                              */
    PushObj( val );
}


/****************************************************************************
**
*F  IntrLongIntExpr(<str>)   .  .  interpret literal long integer expression
**
**  'IntrLongIntExpr' is the action to  interpret a long literal integer
**  expression whose digits are stored in a string GAP object.
*/
void            IntrLongIntExpr (
    Obj               string )
{
    Obj                 ret;            /* integer encoded as GAP obj      */
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeLongIntExpr( string ); return; }

    ret = IntStringInternal(string);
    
    if ( ret == Fail ) {
        /* This should never happen */
        ErrorQuit("Int: Invalid parsing (internal error)", 0, 0);
    }

    /* push the integer value                                              */
    PushObj( ret );
}

/****************************************************************************
**
*F  IntrFloatExpr(<str>)  . . . . . . . .  interpret literal float expression
**
**  'IntrFloatExpr' is the action  to  interpret a literal  float expression.
**  <str> is the float as a (null terminated) C character string.
*/

static Obj CONVERT_FLOAT_LITERAL_EAGER;

static Obj ConvertFloatLiteralEager(Obj str) {
  Char *chars = (Char *)CHARS_STRING(str);
  UInt len = GET_LEN_STRING(str);
  Char mark = '\0';
  if (chars[len-1] == '_') {
    SET_LEN_STRING(str, len-1);
    chars[len-1] = '\0';
  } else if (chars[len-2] == '_') {
    mark = chars[len-1];
    SET_LEN_STRING(str, len-2);
    chars[len-2] = '\0';
  }
  return CALL_2ARGS(CONVERT_FLOAT_LITERAL_EAGER, str, ObjsChar[(UInt)mark]);
}

void            IntrFloatExpr (
    Char *              str )
{
    Obj                 val;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) {  CodeFloatExpr( str );   return; }

    C_NEW_STRING_DYN(val, str);
    PushObj(ConvertFloatLiteralEager(val));
}


/****************************************************************************
**
*F  IntrLongFloatExpr(<str>)   .  .  interpret literal long float expression
**
**  'IntrLongFloatExpr' is the action to  interpret a long literal float
**  expression whose digits are stored in a string GAP object.
*/
void            IntrLongFloatExpr (
    Obj               string )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeLongFloatExpr( string );  return; }

    PushObj(ConvertFloatLiteralEager(string));
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeTrueExpr(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeFalseExpr(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeCharExpr( chr ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodePermCycle(nrx,nrc); return; }


    /* get the permutation (allocate for the first cycle)                  */
    if ( nrc == 1 ) {
        m = 0;
        perm = NEW_PERM4( 0 );
        ptr4 = ADDR_PERM4( perm );
    }
    else {
        m = INT_INTOBJ( ELM_LIST( STATE(StackObj), STATE(CountObj) - nrx ) );
        perm = ELM_LIST( STATE(StackObj), STATE(CountObj) - nrx - 1 );
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
                (Int)TNAM_OBJ(val), 0L );
        }
        c = INT_INTOBJ(val);
        if (c > MAX_DEG_PERM4)
          ErrorQuit( "Permutation literal exceeds maximum permutation degree -- %i vs %i",
                     c, MAX_DEG_PERM4);

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
                "Permutation: cycles must be disjoint and duplicate-free",
                0L, 0L );
        }

        /* enter the previous entry at current location                    */
        if ( p != 0 ) { ptr4[c-1] = p-1; }
        else          { l = c;          }

        /* remember current entry for next round                           */
        p = c;
    }

    /* enter first (last popped) entry at last (first popped) location     */
    if (ptr4[l-1] != l-1) {
        ErrorQuit("Permutation: cycles must be disjoint and duplicate-free", 0L, 0L );
    }
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodePerm(nrc); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeListExprBegin( top ); return; }


    /* allocate the new list                                               */
    list = NEW_PLIST( T_PLIST_EMPTY, 0 );
    SET_LEN_PLIST( list, 0 );

    /* if this is an outmost list, save it for reference in '~'            */
    /* (and save the old value of '~' on the values stack)                 */
    if ( top ) {
        old = VAL_GVAR( Tilde );
        if ( old != 0 ) { PushObj( old ); }
        else            { PushVoidObj();  }
        AssGVarUnsafe( Tilde, list );
    }

    /* push the list                                                       */
    PushObj( list );
}

void            IntrListExprBeginElm (
    UInt                pos )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeListExprBeginElm( pos ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeListExprEndElm(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeListExprEnd(nr,range,top,tilde); return; }


    /* if this was a top level expression, restore the value of '~'        */
    if ( top ) {
        list = PopObj();
        old = PopVoidObj();
        AssGVarUnsafe( Tilde, old );
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
                "Range: <first> must be an integer less than 2^%d (not a %s)",
                NR_SMALL_INT_BITS, (Int)TNAM_OBJ(val) );
        }
        low = INT_INTOBJ( val );

        /* get the increment                                               */
        if ( nr == 3 ) {
            val = ELM_LIST( list, 2 );
            if ( ! IS_INTOBJ(val) ) {
                ErrorQuit(
                    "Range: <second> must be an integer less than 2^%d (not a %s)",
                    NR_SMALL_INT_BITS, (Int)TNAM_OBJ(val) );
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
                "Range: <last> must be an integer less than 2^%d (not a %s)",
                NR_SMALL_INT_BITS, (Int)TNAM_OBJ(val) );
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
            /* length must be a small integer as well */
            if ((high-low) / inc + 1 >= (1L<<NR_SMALL_INT_BITS)) {
                ErrorQuit("Range: the length of a range must be less than 2^%d",
                           NR_SMALL_INT_BITS, 0L);
            }

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
    else {
        /* give back unneeded memory */
        list = PopObj( );
        SHRINK_PLIST( list, LEN_PLIST(list) );
        PushObj( list );
    }
}


/****************************************************************************
**
*F  IntrStringExpr(<str>) . . . . . . . . interpret literal string expression
*/
void           IntrStringExpr (
    Obj               string )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeStringExpr( string ); return; }


    /* push the string, already newly created                              */
    PushObj( string );
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeRecExprBegin( top ); return; }


    /* allocate the new record                                             */
    record = NEW_PREC( 0 );

    /* if this is an outmost record, save it for reference in '~'          */
    /* (and save the old value of '~' on the values stack)                 */
    if ( top ) {
        old = VAL_GVAR( Tilde );
        if ( old != 0 ) { PushObj( old ); }
        else            { PushVoidObj();  }
        AssGVarUnsafe( Tilde, record );
    }

    /* push the record                                                     */
    PushObj( record );
}

void            IntrRecExprBeginElmName (
    UInt                rnam )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeRecExprBeginElmName( rnam ); return; }


    /* remember the name on the values stack                               */
    PushObj( (Obj)rnam );
}

void            IntrRecExprBeginElmExpr ( void )
{
    UInt                rnam;           /* record name                     */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeRecExprBeginElmExpr(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeRecExprEndElm(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeRecExprEnd(nr,top,tilde); return; }


    /* if this was a top level expression, restore the value of '~'        */
    if ( top ) {
        record = PopObj();
        old = PopVoidObj();
        AssGVarUnsafe( Tilde, old );
        PushObj( record );
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
void            IntrFuncCallOptionsBegin ( void )
{
    Obj                 record;         /* new record                      */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeFuncCallOptionsBegin( ); return; }


    /* allocate the new record                                             */
    record = NEW_PREC( 0 );
    /* push the record                                                     */
    PushObj( record );
}

void            IntrFuncCallOptionsBeginElmName (
    UInt                rnam )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeFuncCallOptionsBeginElmName( rnam ); return; }


    /* remember the name on the values stack                               */
    PushObj( (Obj)rnam );
}

void            IntrFuncCallOptionsBeginElmExpr ( void )
{
    UInt                rnam;           /* record name                     */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeFuncCallOptionsBeginElmExpr(); return; }


    /* convert the expression to a record name                             */
    rnam = RNamObj( PopObj() );

    /* remember the name on the values stack                               */
    PushObj( (Obj)rnam );
}

void            IntrFuncCallOptionsEndElm ( void )
{
    Obj                 record;         /* record that is currently made   */
    UInt                rnam;           /* name of record element          */
    Obj                 val;            /* value of record element         */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeFuncCallOptionsEndElm(); return; }


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

void            IntrFuncCallOptionsEndElmEmpty ( void )
{
    Obj                 record;         /* record that is currently made   */
    UInt                rnam;           /* name of record element          */
    Obj                 val;            /* value of record element         */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeFuncCallOptionsEndElmEmpty(); return; }


    /* get the value                                                       */
    val = True;

    /* get the record name                                                 */
    rnam = (UInt)PopObj();

    /* get the record                                                      */
    record = PopObj();

    /* assign the value into the record                                    */
    ASS_REC( record, rnam, val );

    /* push the record again                                               */
    PushObj( record );
}

void            IntrFuncCallOptionsEnd ( UInt nr )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeFuncCallOptionsEnd(nr); return; }


}


/****************************************************************************
**
*F  IntrAssLVar(<lvar>) . . . . . . . . . . . . interpret assignment to local
*/
void            IntrAssLVar (
    UInt                lvar )
{
  Obj val;
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( STATE(IntrCoding) > 0 )
      CodeAssLVar( lvar );

    /* Or in the break loop */
    else {
        val = PopObj();
        ASS_LVAR(lvar, val);
        PushObj(val);
    }
}

void            IntrUnbLVar (
    UInt                lvar )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( STATE(IntrCoding) > 0 )
      CodeUnbLVar( lvar );

    /* or in the break loop */
    else {
        ASS_LVAR(lvar,0);
        PushVoidObj();
    }
}


/****************************************************************************
**
*F  IntrRefLVar(<lvar>) . . . . . . . . . . . .  interpret reference to local
*/
void            IntrRefLVar (
    UInt                lvar )
{
  Obj val;
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( STATE(IntrCoding) > 0 )
      CodeRefLVar( lvar );

    /* or in the break loop */

    else {
        while ((val = OBJ_LVAR(lvar))==0) {
            ErrorReturnVoid(
                            "Variable: '%s' must have an assigned value",
                            (Int)NAME_LVAR( (UInt)( lvar )), 0L,
                            "you can 'return;' after assigning a value" );

        }
        PushObj(val);
    }
}

void            IntrIsbLVar (
    UInt                lvar )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if( STATE(IntrCoding) > 0 )
      CodeIsbLVar( lvar );

    /* or debugging */
    else {
        PushObj(OBJ_LVAR(lvar) != (Obj)0 ? True : False);
    }
}


/****************************************************************************
**
*F  IntrAssHVar(<hvar>) . . . . . . . . . . .  interpret assignment to higher
*/
void            IntrAssHVar (
    UInt                hvar )
{
  Obj val;
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if( STATE(IntrCoding) > 0 )
      CodeAssHVar( hvar );
    /* Or in the break loop */
    else {
        val = PopObj();
        ASS_HVAR(hvar, val);
        PushObj(val);
    }
}

void            IntrUnbHVar (
    UInt                hvar )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if ( STATE(IntrCoding) > 0 )
      CodeUnbHVar( hvar );
    /* or debugging */
    else {
        ASS_HVAR(hvar, 0);
        PushVoidObj();
    }
}


/****************************************************************************
**
*F  IntrRefHVar(<hvar>) . . . . . . . . . . . . interpret reference to higher
*/
void            IntrRefHVar (
    UInt                hvar )
{
  Obj val;
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if( STATE(IntrCoding) > 0 )
      CodeRefHVar( hvar );
    /* or debugging */
    else {
        while ((val = OBJ_HVAR(hvar))==0) {
            ErrorReturnVoid(
                            "Variable: '%s' must have an assigned value",
                            (Int)NAME_HVAR( (UInt)( hvar )), 0L,
                            "you can 'return;' after assigning a value" );

        }
        PushObj(val);
    }
}

void            IntrIsbHVar (
    UInt                hvar )
{
    /* ignore                                                              */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }

    /* otherwise must be coding                                            */
    if( STATE(IntrCoding) > 0 )
      CodeIsbHVar( hvar );
    /* or debugging */
    else
      PushObj((OBJ_HVAR(hvar) != (Obj) 0) ? True : False);
}


/****************************************************************************
**
*F  IntrAssDVar(<dvar>) . . . . . . . . . . . . interpret assignment to debug
*/
/* TL: extern  Obj             ErrorLVars; */

void            IntrAssDVar (
    UInt                dvar,
    UInt                depth )
{
    Obj                 rhs;            /* right hand side                 */
    Obj                 currLVars;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    /* if ( STATE(IntrCoding)    > 0 ) { CodeAssDVar( gvar ); return; } */


    if ( STATE(IntrCoding) > 0 ) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> cannot be used here",
                   dvar >> 10, dvar & 0x3FF );
    }


    /* get the right hand side                                             */
    rhs = PopObj();

    /* assign the right hand side                                          */
    currLVars = STATE(CurrLVars);
    SWITCH_TO_OLD_LVARS( STATE(ErrorLVars) );
    while (depth--)
      SWITCH_TO_OLD_LVARS( PARENT_LVARS(STATE(CurrLVars)) );
    ASS_HVAR( dvar, rhs );
    SWITCH_TO_OLD_LVARS( currLVars  );

    /* push the right hand side again                                      */
    PushObj( rhs );
}

void            IntrUnbDVar (
    UInt                dvar,
    UInt                depth )
{
    Obj                 currLVars;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    /* if ( STATE(IntrCoding)    > 0 ) { CodeUnbGVar( gvar ); return; } */


    if ( STATE(IntrCoding) > 0 ) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> cannot be used here",
                   dvar >> 10, dvar & 0x3FF );
    }

    /* assign the right hand side                                          */
    currLVars = STATE(CurrLVars);
    SWITCH_TO_OLD_LVARS( STATE(ErrorLVars) );
    while (depth--)
      SWITCH_TO_OLD_LVARS( PARENT_LVARS(STATE(CurrLVars)) );
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
    UInt                dvar,
    UInt                depth )
{
    Obj                 val;            /* value, result                   */
    Obj                 currLVars;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    /* if ( STATE(IntrCoding)    > 0 ) { CodeRefGVar( gvar ); return; } */


    if ( STATE(IntrCoding) > 0 ) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> cannot be used here",
                   dvar >> 10, dvar & 0x3FF );
    }

    /* get and check the value                                             */
    currLVars = STATE(CurrLVars);
    SWITCH_TO_OLD_LVARS( STATE(ErrorLVars) );
    while (depth--)
      SWITCH_TO_OLD_LVARS( PARENT_LVARS(STATE(CurrLVars)) );
    val = OBJ_HVAR( dvar );
    SWITCH_TO_OLD_LVARS( currLVars  );
    if ( val == 0 ) {
        ErrorQuit( "Variable: <debug-variable-%d-%d> must have a value",
                   dvar >> 10, dvar & 0xFFFF );
    }

    /* push the value                                                      */
    PushObj( val );
}

void            IntrIsbDVar (
    UInt                dvar,
    UInt                depth )
{
    Obj                 val;            /* value, result                   */
    Obj                 currLVars;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    /* if ( STATE(IntrCoding)    > 0 ) { CodeIsbGVar( gvar ); return; } */


    /* get the value                                                       */
    currLVars = STATE(CurrLVars);
    SWITCH_TO_OLD_LVARS( STATE(ErrorLVars) );
    while (depth--)
      SWITCH_TO_OLD_LVARS( PARENT_LVARS(STATE(CurrLVars)) );
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssGVar( gvar ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeUnbGVar( gvar ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeRefGVar( gvar ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIsbGVar( gvar ); return; }


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
void            IntrAssList ( Int narg )
{
    Obj                 list;           /* list                            */
    Obj                 pos;            /* position                        */
    Obj                 rhs;            /* right hand side                 */
    Obj pos1,pos2;
    Obj ixs;
    Int i;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssList( narg); return; }

    /* get the right hand side                                             */
    rhs = PopObj();
    
    switch (narg) {
    case 1:

      /* get the position                                                    */
      pos = PopObj();

      /* get the list (checking is done by 'ASS_LIST' or 'ASSB_LIST')        */
      list = PopObj();

      /* assign to the element of the list                                   */
      if (IS_POS_INTOBJ(pos)) {
        ASS_LIST( list, INT_INTOBJ(pos), rhs );
      } else {
        ASSB_LIST(list, pos, rhs);
      }
      break;

    case 2:
      pos2 = PopObj();
      pos1 = PopObj();
      list = PopObj();

      ASS2_LIST(list, pos1, pos2, rhs);
      break;

    default:
      ixs = NEW_PLIST(T_PLIST, narg);
      for (i = narg; i > 0; i--) {
        pos = PopObj();
        SET_ELM_PLIST(ixs, i, pos);
        CHANGED_BAG(ixs);
      }
      SET_LEN_PLIST(ixs, narg);
      list = PopObj();
      ASSB_LIST(list, ixs, rhs);
    }
      
    /* push the right hand side again                                      */
    PushObj( rhs );
}

void            IntrAsssList ( void )
{
    Obj                 list;           /* list                            */
    Obj                 poss;           /* positions                       */
    Obj                 rhss;           /* right hand sides                */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAsssList(); return; }


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
                                  Int narg,
                                  UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */
    Obj ixs;
    Int i;
    
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssListLevel( narg, level ); return; }

    /* get right hand sides (checking is done by 'AssListLevel')           */
    rhss = PopObj();

    ixs = NEW_PLIST(T_PLIST, narg);
    for (i = narg; i > 0; i--) {
      /* get and check the position                                          */
      pos = PopObj();
      SET_ELM_PLIST(ixs, i, pos);
      CHANGED_BAG(ixs);
    }
    SET_LEN_PLIST(ixs, narg);

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'AssListLevel')     */
    lists = PopObj();

    /* assign the right hand sides to the elements of several lists        */
    AssListLevel( lists, ixs, rhss, level );

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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAsssListLevel( level ); return; }


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

void            IntrUnbList ( Int narg )
{
    Obj                 list;           /* list                            */
    Obj                 pos;            /* position                        */
    Obj                 ixs;
    Int                 i;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeUnbList( narg); return; }

    if (narg == 1) {
      /* get and check the position                                          */
      pos = PopObj();
      
      /* get the list (checking is done by 'UNB_LIST' or 'UNBB_LIST')        */
      list = PopObj();

      /* unbind the element                                                  */
      if (IS_POS_INTOBJ(pos)) {
        UNB_LIST( list, INT_INTOBJ(pos) );
      } else {
        UNBB_LIST(list, pos);
      }
    } else {
      ixs = NEW_PLIST(T_PLIST,narg);
      for (i = narg; i > 0; i--) {
        pos = PopObj();
        SET_ELM_PLIST(ixs, i, pos);
        CHANGED_BAG(ixs);
      }
      SET_LEN_PLIST(ixs, narg);
      list = PopObj();
      UNBB_LIST(list, ixs);
    }

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
void            IntrElmList ( Int narg )
{
  Obj                 elm = (Obj) 0;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */
    Int                 i;
    Obj                 ixs;
    Obj                 pos1;
    Obj                 pos2;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmList( narg ); return; }

    if (narg <= 0)
      SyntaxError("This should never happen");

    if (narg == 1) {
      /* get  the position                                                   */
      pos = PopObj();
      /* get the list (checking is done by 'ELM_LIST')                       */
      list = PopObj();
      
      
      if ( ! IS_INTOBJ(pos)  || (p = INT_INTOBJ(pos)) <= 0) {
        /* This mostly dispatches to the library */
        elm = ELMB_LIST( list, pos);
      } else {
        /* get the element of the list                                         */
        elm = ELM_LIST( list, p );
      }
    }
    if (narg == 2) {
      pos2 = PopObj();
      pos1 = PopObj();
      list = PopObj();
      /* leave open space for a fastpath for 2 */
      elm = ELM2_LIST(list, pos1, pos2);
    }
    
    if (narg > 2) {
      ixs = NEW_PLIST(T_PLIST,narg);
      for (i = narg; i > 0; i--) {
        SET_ELM_PLIST(ixs,i,PopObj());
        CHANGED_BAG(ixs);
      }
      SET_LEN_PLIST(ixs, narg);
      list = PopObj();
      elm = ELMB_LIST(list, ixs);
    }
      
    /* push the element                                                    */
    PushObj( elm );
}

void            IntrElmsList ( void )
{
    Obj                 elms;           /* elements, result                */
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, right operand        */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmsList(); return; }


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

void            IntrElmListLevel ( Int narg,
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, right operand         */
    Obj ixs;
    Int i;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmListLevel( narg, level ); return; }

    /* get the positions */
    ixs = NEW_PLIST(T_PLIST, narg);
    for (i = narg; i > 0; i--) {
      pos = PopObj();
      SET_ELM_PLIST(ixs,i,pos);
      CHANGED_BAG(ixs);
    }
    SET_LEN_PLIST(ixs, narg);
      
    /* /\* get and check the position                                          *\/ */
    /* pos = PopObj(); */
    /* if ( TNUM_OBJ(pos) != T_INTPOS && (! IS_POS_INTOBJ(pos) )) { */
    /*     ErrorQuit( */
    /*         "List Element: <position> must be a positive integer (not a %s)", */
    /*         (Int)TNAM_OBJ(pos), 0L ); */
    /* } */

    /* get lists (if this works, then <lists> is nested <level> deep,      */
    /* checking it is nested <level>+1 deep is done by 'ElmListLevel')     */
    lists = PopObj();

    /* select the elements from several lists (store them in <lists>)      */
    ElmListLevel( lists, ixs, level );

    /* push the elements                                                   */
    PushObj( lists );
}

void            IntrElmsListLevel (
    UInt                level )
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* positions, right operand        */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmsListLevel( level ); return; }


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

void            IntrIsbList ( Int narg )
{
    Obj                 isb;            /* isbound, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Obj ixs;
    Int i;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIsbList(narg); return; }

    if (narg == 1) {
      /* get and check the position                                          */
      pos = PopObj();
      
      /* get the list (checking is done by 'ISB_LIST' or 'ISBB_LIST')        */
      list = PopObj();
      
      /* get the result                                                      */
      if (IS_POS_INTOBJ(pos)) {
        isb = ISB_LIST( list, INT_INTOBJ(pos) ) ? True : False;
      } else {
        isb = ISBB_LIST( list, pos) ? True : False;
      }
    } else {
      ixs = NEW_PLIST(T_PLIST,narg);
      for (i = narg; i > 0; i--) {
        pos = PopObj();
        SET_ELM_PLIST(ixs, i, pos);
        CHANGED_BAG(ixs);
      }
      SET_LEN_PLIST(ixs, narg);
      list = PopObj();
      isb = ISBB_LIST(list, ixs) ? True: False;
    }
      
      
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssRecName( rnam ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssRecExpr(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeUnbRecName( rnam ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeUnbRecExpr(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmRecName( rnam ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmRecExpr(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIsbRecName( rnam ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIsbRecExpr(); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssPosObj(); return; }


    /* get the right hand side                                             */
    rhs = PopObj();

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_POS_INTOBJ(pos) ) {
        ErrorQuit(
         "PosObj Assignment: <position> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0L );
    }
    p = INT_INTOBJ(pos);

    /* get the list (checking is done by 'ASS_LIST')                       */
    list = PopObj();

    /* assign to the element of the list                                   */
    if ( TNUM_OBJ(list) == T_POSOBJ ) {
#ifdef HPCGAP
        /* Because BindOnce() functions can reallocate the list even if they
         * only have read-only access, we have to be careful when accessing
         * positional objects. Hence the explicit WriteGuard().
         */
        WriteGuard(list);
#endif
        if ( SIZE_OBJ(list)/sizeof(Obj) - 1 < p ) {
            ResizeBag( list, (p+1) * sizeof(Obj) );
        }
        SET_ELM_PLIST( list, p, rhs );
        CHANGED_BAG( list );
    }
#ifdef HPCGAP
    else if ( TNUM_OBJ(list) == T_APOSOBJ ) {
        AssListFuncs[T_FIXALIST]( list, p, rhs );
    }
#endif
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAsssPosObj(); return; }


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
    if ( TNUM_OBJ(list) == T_POSOBJ ) {
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
    Obj                 pos;            /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssPosObjLevel( level ); return; }


    /* get right hand sides (checking is done by 'AssPosObjLevel')           */
    rhss = PopObj();

    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_POS_INTOBJ(pos) ) {
        ErrorQuit(
         "PosObj Assignment: <position> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0L );
    }

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
    Obj                 poss;           /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAsssPosObjLevel( level ); return; }


    /* get right hand sides (checking is done by 'AsssPosObjLevel')          */
    rhss = PopObj();

    /* get and check the positions                                         */
    poss = PopObj();
    if ( ! IS_POSS_LIST( poss ) ) {
        ErrorQuit(
    "PosObj Assignment: <positions> must be a dense list of positive integers",
            0L, 0L );
    }

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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeUnbPosObj(); return; }


    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_POS_INTOBJ(pos) ) {
        ErrorQuit(
         "PosObj Assignment: <position> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0L );
    }
    p = INT_INTOBJ(pos);

    /* get the list (checking is done by 'UNB_LIST')                       */
    list = PopObj();

    /* unbind the element                                                  */
    if ( TNUM_OBJ(list) == T_POSOBJ ) {
#ifdef HPCGAP
        /* Because BindOnce() functions can reallocate the list even if they
         * only have read-only access, we have to be careful when accessing
         * positional objects. Hence the explicit WriteGuard().
         */
        WriteGuard(list);
#endif
        if ( p <= SIZE_OBJ(list)/sizeof(Obj)-1 ) {
            SET_ELM_PLIST( list, p, 0 );
        }
    }
#ifdef HPCGAP
    else if ( TNUM_OBJ(list) == T_APOSOBJ ) {
        UnbListFuncs[T_FIXALIST]( list, p );
    }
#endif
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmPosObj(); return; }


    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_POS_INTOBJ(pos) ) {
        ErrorQuit(
            "PosObj Element: <position> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0L );
    }
    p = INT_INTOBJ( pos );

    /* get the list (checking is done by 'ELM_LIST')                       */
    list = PopObj();

    /* get the element of the list                                         */
    if ( TNUM_OBJ(list) == T_POSOBJ ) {
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
#ifdef HPCGAP
    else if ( TNUM_OBJ(list) == T_APOSOBJ ) {
        elm = ElmListFuncs[T_FIXALIST]( list, p );
    }
#endif
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmsPosObj(); return; }


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
    if ( TNUM_OBJ(list) == T_POSOBJ ) {
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

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmPosObjLevel( level ); return; }


    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_POS_INTOBJ(pos) ) {
        ErrorQuit(
            "PosObj Element: <position> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0L );
    }

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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmsPosObjLevel( level ); return; }


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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIsbPosObj(); return; }


    /* get and check the position                                          */
    pos = PopObj();
    if ( ! IS_POS_INTOBJ(pos) ) {
        ErrorQuit(
            "PosObj Element: <position> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0L );
    }
    p = INT_INTOBJ( pos );

    /* get the list (checking is done by 'ISB_LIST')                       */
    list = PopObj();

    /* get the result                                                      */
    if ( TNUM_OBJ(list) == T_POSOBJ ) {
        isb = (p <= SIZE_OBJ(list)/sizeof(Obj)-1 && ELM_PLIST(list,p) != 0 ?
               True : False);
    }
#ifdef HPCGAP
    else if ( TNUM_OBJ(list) == T_APOSOBJ ) {
        isb = (IsbListFuncs[T_FIXALIST]( list, p ) ? True : False);
    }
#endif
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssComObjName( rnam ); return; }


    /* get the right hand side                                             */
    rhs = PopObj();

    /* get the record (checking is done by 'ASS_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    switch (TNUM_OBJ(record)) {
      case T_COMOBJ:
        AssPRec( record, rnam, rhs );
        break;
#ifdef HPCGAP
      case T_ACOMOBJ:
        SetARecordField( record, rnam, rhs );
        break;
#endif
      default:
        ASS_REC( record, rnam, rhs );
        break;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssComObjExpr(); return; }


    /* get the right hand side                                             */
    rhs = PopObj();

    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ASS_REC')                      */
    record = PopObj();

    /* assign the right hand side to the element of the record             */
    switch (TNUM_OBJ(record)) {
      case T_COMOBJ:
        AssPRec( record, rnam, rhs );
        break;
#ifdef HPCGAP
      case T_ACOMOBJ:
        SetARecordField( record, rnam, rhs );
        break;
#endif
      default:
        ASS_REC( record, rnam, rhs );
        break;
    }

    /* push the assigned value                                             */
    PushObj( rhs );
}

void            IntrUnbComObjName (
    UInt                rnam )
{
    Obj                 record;         /* record, left operand            */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeUnbComObjName( rnam ); return; }


    /* get the record (checking is done by 'UNB_REC')                      */
    record = PopObj();

    /* unbind the element of the record                                    */
    switch (TNUM_OBJ(record)) {
      case T_COMOBJ:
        UnbPRec( record, rnam );
        break;
#ifdef HPCGAP
      case T_ACOMOBJ:
        UnbARecord( record, rnam);
        break;
#endif
      default:
        UNB_REC( record, rnam );
        break;
    }

    /* push void                                                           */
    PushVoidObj();
}

void            IntrUnbComObjExpr ( void )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeUnbComObjExpr(); return; }


    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'UNB_REC')                      */
    record = PopObj();

    /* unbind the element of the record                                    */
    switch (TNUM_OBJ(record)) {
      case T_COMOBJ:
        UnbPRec( record, rnam );
        break;
#ifdef HPCGAP
      case T_ACOMOBJ:
        UnbARecord( record, rnam);
        break;
#endif
      default:
        UNB_REC( record, rnam );
        break;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmComObjName( rnam ); return; }


    /* get the record (checking is done by 'ELM_REC')                      */
    record = PopObj();

    /* select the element of the record                                    */

    switch (TNUM_OBJ(record)) {
      case T_COMOBJ:
        elm = ElmPRec( record, rnam );
        break;
#ifdef HPCGAP
      case T_ACOMOBJ:
        elm = ElmARecord ( record, rnam );
        break;
#endif
      default:
        elm = ELM_REC( record, rnam );
        break;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeElmComObjExpr(); return; }


    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ELM_REC')                      */
    record = PopObj();

    /* select the element of the record                                    */
    switch (TNUM_OBJ(record)) {
      case T_COMOBJ:
        elm = ElmPRec( record, rnam );
        break;
#ifdef HPCGAP
      case T_ACOMOBJ:
        elm = ElmARecord ( record, rnam );
        break;
#endif
      default:
        elm = ELM_REC( record, rnam );
        break;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIsbComObjName( rnam ); return; }


    /* get the record (checking is done by 'ISB_REC')                      */
    record = PopObj();

    /* get the result                                                      */
    switch (TNUM_OBJ(record)) {
      case T_COMOBJ:
        isb = IsbPRec( record, rnam ) ? True : False;
        break;
#ifdef HPCGAP
      case T_ACOMOBJ:
        isb = GetARecordField( record, rnam ) ? True : False;
        break;
#endif
      default:
        isb = ISB_REC( record, rnam ) ? True : False;
        break;
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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeIsbComObjExpr(); return; }


    /* get the name and convert it to a record name                        */
    rnam = RNamObj( PopObj() );

    /* get the record (checking is done by 'ISB_REC')                      */
    record = PopObj();

    /* get the result                                                      */
    switch (TNUM_OBJ(record)) {
      case T_COMOBJ:
        isb = IsbPRec( record, rnam ) ? True : False;
        break;
#ifdef HPCGAP
      case T_ACOMOBJ:
        isb = GetARecordField( record, rnam ) ? True : False;
        break;
#endif
      default:
        isb = ISB_REC( record, rnam ) ? True : False;
        break;
    }

    /* push the result                                                     */
    PushObj( isb );
}

/****************************************************************************
**
*F  IntrEmpty() . . . . . . . . . . . . .  Interpret an empty statement body
**
*/

void             IntrEmpty ( void )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeEmpty(); return; }


    /* interpret */
    PushVoidObj();
    return;

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
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeInfoBegin(); return; }

}

Obj             InfoDecision;

void            IntrInfoMiddle( void )
{

    Obj selectors;   /* first argument of Info */
    Obj level;       /* second argument of Info */
    Obj selected;    /* GAP Boolean answer to whether this message
                        gets printed or not */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)++; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeInfoMiddle(); return; }


    level = PopObj();
    selectors = PopObj();
    selected = CALL_2ARGS( InfoDecision, selectors, level);
    if (selected == False)
      STATE(IntrIgnoring) = 1;
    return;
}

Obj             InfoDoPrint;

void            IntrInfoEnd( UInt narg )
{

     Obj args;    /* gathers up the arguments to be printed */

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeInfoEnd( narg ); return; }


    /* print if necessary                                                  */
    if ( STATE(IntrIgnoring)  > 0 )
      STATE(IntrIgnoring)--;
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
    if (STATE(IntrIgnoring) == 0)
      PushVoidObj();
    return;
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
**  At this point we know whether there is an assertion failure. We still need
**  to read the third argument if any, to decide what to do about it One of:
**
*F  IntrAssertEnd2Args() . . . . called after reading the closing parenthesis
*F  IntrAssertEnd3Args() . . . . called after reading the closing parenthesis
**
*V  CurrentAssertionLevel  . .  . . . . . . . . . . . .  copy of GAP variable
**
**
**  STATE(IntrIgnoring) is increased by (a total of) 2 if an assertion either is not
**  tested (because we were Ignoring when we got to it, or due to level)
**  or is tested and passes
*/

Obj              CurrentAssertionLevel;

void              IntrAssertBegin ( void )
{
    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssertBegin(); return; }

}


void             IntrAssertAfterLevel ( void )
{
  Obj level;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)++; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssertAfterLevel(); return; }


    level = PopObj();

    if (LT( CurrentAssertionLevel, level))
           STATE(IntrIgnoring) = 1;
}

void             IntrAssertAfterCondition ( void )
{
  Obj condition;

    /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrIgnoring)  > 0 ) { STATE(IntrIgnoring)++; return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssertAfterCondition(); return; }


    condition = PopObj();

    if (condition == True)
      STATE(IntrIgnoring)= 2;
    else if (condition != False)
        ErrorQuit(
            "<condition> in Assert must yield 'true' or 'false' (not a %s)",
            (Int)TNAM_OBJ(condition), 0L );
}

void             IntrAssertEnd2Args ( void )
{
      /* ignore or code                                                      */
    if ( STATE(IntrReturning) > 0 ) { return; }
    if ( STATE(IntrCoding)    > 0 ) { CodeAssertEnd2Args(); return; }


    if ( STATE(IntrIgnoring)  == 0 )
      ErrorQuit("Assertion Failure", 0, 0);
    else
      STATE(IntrIgnoring) -= 2;

    if (STATE(IntrIgnoring) == 0)
      PushVoidObj();
    return;
}


void             IntrAssertEnd3Args ( void )
{
  Obj message;
  /* ignore or code                                                      */
  if ( STATE(IntrReturning) > 0 ) { return; }
  if ( STATE(IntrCoding)    > 0 ) { CodeAssertEnd3Args(); return; }


  if ( STATE(IntrIgnoring)  == 0 ) {
      message = PopVoidObj();
      if (message != (Obj) 0 ) {
          if (IS_STRING_REP( message ))
            PrintString1(message);
          else
            PrintObj(message);
      }
  } else
      STATE(IntrIgnoring) -= 2;

  if (STATE(IntrIgnoring) == 0)
      PushVoidObj();
  return;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
#if !defined(HPCGAP)
    InitGlobalBag( &STATE(IntrResult), "src/intrprtr.c:IntrResult" );
    InitGlobalBag( &STATE(IntrState),  "src/intrprtr.c:IntrState"  );
    InitGlobalBag( &STATE(StackObj),   "src/intrprtr.c:StackObj"   );
#endif
    InitCopyGVar( "CurrentAssertionLevel", &CurrentAssertionLevel );
    InitFopyGVar( "CONVERT_FLOAT_LITERAL_EAGER", &CONVERT_FLOAT_LITERAL_EAGER);

    /* The work of handling Info messages is delegated to the GAP level */
    ImportFuncFromLibrary( "InfoDecision", &InfoDecision );
    ImportFuncFromLibrary( "InfoDoPrint",  &InfoDoPrint  );

    /* The work of handling Options is also delegated*/
    ImportFuncFromLibrary( "PushOptions", &PushOptions );
    ImportFuncFromLibrary( "PopOptions",  &PopOptions  );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    UInt            lev;

    /* The Assertion level is also controlled at GAP level                 */
    lev = GVarName("CurrentAssertionLevel");
    AssGVar( lev, INTOBJ_INT(0) );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoIntrprtr()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "intrprtr",                          /* name                           */
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

StructInitInfo * InitInfoIntrprtr ( void )
{
    return &module;
}


/****************************************************************************
**

*E  intrprtr.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
