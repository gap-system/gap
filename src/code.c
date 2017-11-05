/****************************************************************************
**
*W  code.c                      GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the coder package.
**
**  The  coder package  is   the part of   the interpreter  that creates  the
**  expressions.  Its functions are called from the reader.
*/
#include <stdio.h>               /* on SunOS, assert.h uses stderr
                                           but does not include stdio.h    */
#include <assert.h>                     /* assert */
#include <src/system.h>                 /* Ints, UInts */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/calls.h>                  /* generic call mechanism */
/*N 1996/06/16 mschoene func expressions should be different from funcs    */

#include <src/records.h>                /* generic records */

#include <src/gmpints.h>                /* integers */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/funcs.h>                  /* functions */

#include <src/code.h>                   /* coder */

#include <src/bool.h>                   /* For fail */

#include <src/saveload.h>               /* saving and loading */
#include <src/read.h>                   /* to access stack of for loop globals */
#include <src/gvars.h>
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/aobjects.h>           /* atomic objects */

#include <src/vars.h>                   /* variables */
#include <src/hookintrprtr.h>


GAP_STATIC_ASSERT(sizeof(StatHeader) == 8, "StatHeader has wrong size");

/****************************************************************************
**
*V  PtrBody . . . . . . . . . . . . . . . . . . . . . pointer to current body
**
**  'PtrBody' is a pointer to the current body.
*/
/* TL: Stat * PtrBody; */

/****************************************************************************
**
*V  FilenameCache . . . . . . . . . . . . . . . . . . list of filenames
**
**  'FilenameCache' is a list of previously opened filenames.
*/
Obj FilenameCache;

/****************************************************************************
**
*V  OffsBody  . . . . . . . . . . . . . . . . . . . .  offset in current body
**
**  'OffsBody' is the  offset in the current   body.  It is  only valid while
**  coding.
*/
#define MAX_FUNC_EXPR_NESTING 1024
/* TL: Stat OffsBody; */

/* TL: Stat OffsBodyStack[1024]; */
/* TL: UInt OffsBodyCount = 0; */

/* TL: UInt LoopNesting = 0; */
/* TL: UInt LoopStack[MAX_FUNC_EXPR_NESTING]; */
/* TL: UInt LoopStackCount = 0; */

static inline void PushOffsBody( void ) {
  assert(STATE(OffsBodyCount) <= MAX_FUNC_EXPR_NESTING-1);
  STATE(OffsBodyStack)[STATE(OffsBodyCount)++] = STATE(OffsBody);
}

static inline void PopOffsBody( void ) {
  assert(STATE(OffsBodyCount));
  STATE(OffsBody) = STATE(OffsBodyStack)[--STATE(OffsBodyCount)];
}

static inline void PushLoopNesting( void ) {
  assert(STATE(LoopStackCount) <= MAX_FUNC_EXPR_NESTING-1);
  STATE(LoopStack)[STATE(LoopStackCount)++] = STATE(LoopNesting);
}

static inline void PopLoopNesting( void ) {
  assert(STATE(LoopStackCount));
  STATE(LoopNesting) = STATE(LoopStack)[--STATE(LoopStackCount)];
}

static inline void SetupGapname(TypInputFile* i)
{
    if (i->gapnameid == 0) {
        Obj filename = MakeImmString(i->name);
#ifdef HPCGAP
        // TODO/FIXME: adjust this code to work more like the corresponding
        // code below for GAP?!?
        i->gapnameid = AddAList(FilenameCache, filename);
#else
        Obj pos = POS_LIST(FilenameCache, filename, INTOBJ_INT(1));
        if (pos == Fail) {
            i->gapnameid = PushPlist(FilenameCache, filename);
        }
        else {
            i->gapnameid = INT_INTOBJ(pos);
        }
#endif
    }
}

Obj FuncGET_FILENAME_CACHE(Obj self)
{
  return CopyObj(FilenameCache, 1);
}

Obj FILENAME_STAT(Stat stat)
{
  Obj filename;
  UInt filenameid = FILENAMEID_STAT(stat);
  if (filenameid == 0)
      filename = NEW_STRING(0);
  else
      filename = ELM_LIST(FilenameCache, filenameid);
  return filename;
}

Obj GET_FILENAME_BODY(Obj body)
{
    return BODY_HEADER(body)->filename;
}

void SET_FILENAME_BODY(Obj body, Obj val)
{
    GAP_ASSERT(IS_STRING_REP(val));
    MakeImmutableString(val);
    BODY_HEADER(body)->filename = val;
}

Obj GET_LOCATION_BODY(Obj body)
{
    Obj location = BODY_HEADER(body)->location;
    return IS_STRING_REP(location) ? location : 0;
}

void SET_LOCATION_BODY(Obj body, Obj val)
{
    GAP_ASSERT(IS_STRING_REP(val));
    MakeImmutableString(val);
    BODY_HEADER(body)->location = val;
}

UInt GET_STARTLINE_BODY(Obj body)
{
    Obj line = BODY_HEADER(body)->startline;
    return IS_POS_INTOBJ(line) ? INT_INTOBJ(line) : 0;
}

void SET_STARTLINE_BODY(Obj body, UInt val)
{
    BODY_HEADER(body)->startline = val ? INTOBJ_INT(val) : 0;
}

UInt GET_ENDLINE_BODY(Obj body)
{
    Obj line = BODY_HEADER(body)->endline;
    return IS_POS_INTOBJ(line) ? INT_INTOBJ(line) : 0;
}

void SET_ENDLINE_BODY(Obj body, UInt val)
{
    BODY_HEADER(body)->endline = val ? INTOBJ_INT(val) : 0;
}

/****************************************************************************
**
** Fill in filename and line of a statement, checking we do not overflow
** the space we have for storing information
*/
static StatHeader fillFilenameLine(Int fileid, Int line, Int size, Int type)
{
  if (fileid < 0 || fileid >= (1 << 15)) {
    fileid = (1 << 15) - 1;
    ReportFileNumberOverflowOccured();
  }
  if (line < 0 || line >= (1 << 16)) {
    line = (1 << 16) - 1;
    ReportLineNumberOverflowOccured();
  }

  StatHeader header = { 0, fileid, line, size, type };
  return header;
}



/****************************************************************************
**
*F  NewStat( <type>, <size> ) . . . . . . . . . . .  allocate a new statement
**
**  'NewStat'   allocates a new   statement memory block  of  type <type> and
**  <size> bytes.  'NewStat' returns the identifier of the new statement.
**
**  NewStatWithProf( <type>, <size>, <line>, <file> ) allows the line number
**  and fileid of the statement to also be specified, else the current line
**  and file when NewStat was called is used. line=0, file=0 is used
**  to denote a statement which should not be tracked.
*/
static Stat NewStatWithProf (
    UInt                type,
    UInt                size,
    UInt                line,
    UInt                file)
{
    Stat                stat;           /* result                          */

    /* this is where the new statement goes                                */
    stat = STATE(OffsBody) + sizeof(StatHeader);

    /* increase the offset                                                 */
    STATE(OffsBody) = stat + ((size+sizeof(Stat)-1) / sizeof(Stat)) * sizeof(Stat);

    /* make certain that the current body bag is large enough              */
    Obj body = BODY_FUNC(CURR_FUNC());
    UInt bodySize = SIZE_BAG(body);
    if (bodySize == 0)
        bodySize = STATE(OffsBody);
    while (bodySize < STATE(OffsBody))
        bodySize *= 2;
    ResizeBag(body, bodySize);
    STATE(PtrBody) = (Stat*)PTR_BAG(body);

    /* enter type and size                                                 */
    *STAT_HEADER(stat) = fillFilenameLine(file, line, size, type);
    RegisterStatWithHook(stat);
    /* return the new statement                                            */
    return stat;
}

Stat NewStat (
    UInt                type,
    UInt                size)
{
    SetupGapname(STATE(Input));
    return NewStatWithProf(type, size, STATE(Input)->number, STATE(Input)->gapnameid);
}


/****************************************************************************
**
*F  NewExpr( <type>, <size> ) . . . . . . . . . . . allocate a new expression
**
**  'NewExpr' allocates a new expression memory block of  the type <type> and
**  <size> bytes.  'NewExpr' returns the identifier of the new expression.
*/
Expr            NewExpr (
    UInt                type,
    UInt                size )
{
    return NewStat(type, size);
}


/****************************************************************************
**
*V  CodeResult  . . . . . . . . . . . . . . . . . . . . . .  result of coding
**
**  'CodeResult'  is the result  of the coding, i.e.,   the function that was
**  coded.
*/
/* TL: Obj CodeResult; */


/****************************************************************************
**
*V  StackStat . . . . . . . . . . . . . . . . . . . . . . .  statements stack
*V  CountStat . . . . . . . . . . . . . . . number of statements on the stack
*F  PushStat( <stat> )  . . . . . . . . . . . . push statement onto the stack
*F  PopStat() . . . . . . . . . . . . . . . . .  pop statement from the stack
**
**  'StackStat' is the stack of statements that have been coded.
**
**  'CountStat'   is the number   of statements  currently on  the statements
**  stack.
**
**  'PushStat'  pushes the statement  <stat> onto the  statements stack.  The
**  stack is automatically resized if necessary.
**
**  'PopStat' returns the  top statement from the  statements  stack and pops
**  it.  It is an error if the stack is empty.
*/
/* TL: Bag StackStat; */

/* TL: Int CountStat; */

void PushStat (
    Stat                stat )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( STATE(StackStat) != 0 );
    assert( 0 <= STATE(CountStat) );
    assert( STATE(CountStat) <= SIZE_BAG(STATE(StackStat))/sizeof(Stat) );
    assert( stat != 0 );

    /* count up and put the statement onto the stack                       */
    if ( STATE(CountStat) == SIZE_BAG(STATE(StackStat))/sizeof(Stat) ) {
        ResizeBag( STATE(StackStat), 2*STATE(CountStat)*sizeof(Stat) );
    }
    ((Stat*)PTR_BAG(STATE(StackStat)))[STATE(CountStat)] = stat;
    STATE(CountStat)++;
}

Stat PopStat ( void )
{
    Stat                stat;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    assert( STATE(StackStat) != 0 );
    assert( 1 <= STATE(CountStat) );
    assert( STATE(CountStat) <= SIZE_BAG(STATE(StackStat))/sizeof(Stat) );

    /* get the top statement from the stack, and count down                */
    STATE(CountStat)--;
    stat = ((Stat*)PTR_BAG(STATE(StackStat)))[STATE(CountStat)];

    /* return the popped statement                                         */
    return stat;
}

Stat PopSeqStat (
    UInt                nr )
{
    Stat                body;           /* sequence, result                */
    Stat                stat;           /* single statement                */
    UInt                i;              /* loop variable                   */

    if (nr == 0 ) {
      body = NewStat(T_EMPTY, 0);
    }
    /* special case for a single statement                                 */
    else if ( nr == 1 ) {
        body = PopStat();
    }

    /* general case                                                        */
    else {

        /* allocate the sequence                                           */
        if ( 2 <= nr && nr <= 7 ) {
            body = NewStat( T_SEQ_STAT+(nr-1), nr * sizeof(Stat) );
        }
        else {
            body = NewStat( T_SEQ_STAT,        nr * sizeof(Stat) );
        }

        /* enter the statements into the sequence                          */
        for ( i = nr; 1 <= i; i-- ) {
            stat = PopStat();
            ADDR_STAT(body)[i-1] = stat;
        }
    }

    /* return the sequence                                                 */
    return body;
}

static inline Stat PopLoopStat(UInt baseType, UInt extra, UInt nr)
{
    // fix up the case of no statements
    if (0 == nr) {
        PushStat(NewStat(T_EMPTY, 0));
        nr = 1;
    }

    // collect the statements into a statement sequence if necessary
    else if (3 < nr) {
        PushStat(PopSeqStat(nr));
        nr = 1;
    }

    // allocate the compound statement
    Stat stat = NewStat(baseType + (nr - 1),
                        extra * sizeof(Expr) + nr * sizeof(Stat));

    // enter the statements
    for (UInt i = nr; 1 <= i; i--) {
        Stat stat1 = PopStat();
        ADDR_STAT(stat)[i + extra - 1] = stat1;
    }

    return stat;
}


/****************************************************************************
**
*V  StackExpr . . . . . . . . . . . . . . . . . . . . . . . expressions stack
*V  CountExpr . . . . . . . . . . . . . .  number of expressions on the stack
*F  PushExpr( <expr> )  . . . . . . . . . . .  push expression onto the stack
*F  PopExpr() . . . . . . . . . . . . . . . .   pop expression from the stack
**
**  'StackExpr' is the stack of expressions that have been coded.
**
**  'CountExpr'  is the number   of expressions currently  on the expressions
**  stack.
**
**  'PushExpr' pushes the expression <expr> onto the  expressions stack.  The
**  stack is automatically resized if necessary.
**
**  'PopExpr' returns the top expressions from the expressions stack and pops
**  it.  It is an error if the stack is empty.
*/
/* TL: Bag StackExpr; */

/* TL: Int CountExpr; */

void PushExpr (
    Expr                expr )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( STATE(StackExpr) != 0 );
    assert( 0 <= STATE(CountExpr) );
    assert( STATE(CountExpr) <= SIZE_BAG(STATE(StackExpr))/sizeof(Expr) );
    assert( expr != 0 );

    /* count up and put the expression onto the stack                      */
    if ( STATE(CountExpr) == SIZE_BAG(STATE(StackExpr))/sizeof(Expr) ) {
        ResizeBag( STATE(StackExpr), 2*STATE(CountExpr)*sizeof(Expr) );
    }
    ((Expr*)PTR_BAG(STATE(StackExpr)))[STATE(CountExpr)] = expr;
    STATE(CountExpr)++;
}

Expr PopExpr ( void )
{
    Expr                expr;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    assert( STATE(StackExpr) != 0 );
    assert( 1 <= STATE(CountExpr) );
    assert( STATE(CountExpr) <= SIZE_BAG(STATE(StackExpr))/sizeof(Expr) );

    /* get the top expression from the stack, and count down               */
    STATE(CountExpr)--;
    expr = ((Expr*)PTR_BAG(STATE(StackExpr)))[STATE(CountExpr)];

    /* return the popped expression                                        */
    return expr;
}


/****************************************************************************
**
*F  PushUnaryOp( <type> ) . . . . . . . . . . . . . . . . push unary operator
**
**  'PushUnaryOp' pushes a   unary  operator expression onto the   expression
**  stack.  <type> is the type of the operator (currently only 'T_NOT').
*/
void PushUnaryOp (
    UInt                type )
{
    Expr                unop;           /* unary operator, result          */
    Expr                op;             /* operand                         */

    /* allocate the unary operator                                         */
    unop = NewExpr( type, sizeof(Expr) );

    /* enter the operand                                                   */
    op = PopExpr();
    ADDR_EXPR(unop)[0] = op;

    /* push the unary operator                                             */
    PushExpr( unop );
}


/****************************************************************************
**
*F  PushBinaryOp( <type> )  . . . . . . . . . . . . . .  push binary operator
**
**  'PushBinaryOp' pushes a binary   operator expression onto  the expression
**  stack.  <type> is the type of the operator.
*/
void PushBinaryOp (
    UInt                type )
{
    Expr                binop;          /* binary operator, result         */
    Expr                opL;            /* left operand                    */
    Expr                opR;            /* right operand                   */

    /* allocate the binary operator                                        */
    binop = NewExpr( type, 2*sizeof(Expr) );

    /* enter the right operand                                             */
    opR = PopExpr();
    ADDR_EXPR(binop)[1] = opR;

    /* enter the left operand                                              */
    opL = PopExpr();
    ADDR_EXPR(binop)[0] = opL;

    /* push the binary operator                                            */
    PushExpr( binop );
}


/****************************************************************************
**
*F * * * * * * * * * * * * *  coder functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  CodeFuncCallOptionsBegin() . . . . . . . . . . . . .  code options, begin
*F  CodeFuncCallOptionsBeginElmName(<rnam>). . .  code options, begin element
*F  CodeFuncCallOptionsBeginElmExpr() . .. . . . .code options, begin element
*F  CodeFuncCallOptionsEndElm() . . .. .  . . . . . code options, end element
*F  CodeFuncCallOptionsEndElmEmpty() .. .  . . . . .code options, end element
*F  CodeFuncCallOptionsEnd(<nr>)  . . . . . . . . . . . . . code options, end
**
**  The net effect of all of these is to leave a record expression on the stack
**  containing the options record. It will be picked up by
**  CodeFuncCallEnd()
**
*/
void            CodeFuncCallOptionsBegin ( void )
{
}

void            CodeFuncCallOptionsBeginElmName (
    UInt                rnam )
{
    /* push the record name as integer expressions                         */
    PushExpr( INTEXPR_INT( rnam ) );
}

void            CodeFuncCallOptionsBeginElmExpr ( void )
{
  /* The expression is on the stack where we want it */
}

void            CodeFuncCallOptionsEndElm ( void )
{
}

void            CodeFuncCallOptionsEndElmEmpty ( void )
{
  /* The default value is true */
      PushExpr( NewExpr( T_TRUE_EXPR, 0L ) );
}

void            CodeFuncCallOptionsEnd ( UInt nr )
{
    Expr                record;         /* record, result                  */
    Expr                entry;          /* entry                           */
    Expr                rnam;           /* position of an entry            */
    UInt                i;              /* loop variable                   */

    /* allocate the record expression                                      */
    record = NewExpr( T_REC_EXPR,      nr * 2 * sizeof(Expr) );
    

    /* enter the entries                                                   */
    for ( i = nr; 1 <= i; i-- ) {
        entry = PopExpr();
        rnam  = PopExpr();
        ADDR_EXPR(record)[2*(i-1)]   = rnam;
        ADDR_EXPR(record)[2*(i-1)+1] = entry;
    }

    /* push the record                                                     */
    PushExpr( record );

}


/****************************************************************************
**
*F  CodeBegin() . . . . . . . . . . . . . . . . . . . . . . . start the coder
*F  CodeEnd( <error> )  . . . . . . . . . . . . . . . . . . .  stop the coder
**
**  'CodeBegin'  starts  the  coder.    It is   called  from  the   immediate
**  interpreter   when he encounters  a construct  that it cannot immediately
**  interpret.
**
**  'CodeEnd' stops the coder.  It  is called from the immediate  interpreter
**  when he is done with the construct  that it cannot immediately interpret.
**  If <error> is  non-zero, a syntax error  was detected by the  reader, and
**  the coder should only clean up.
**
**  ...only function expressions inbetween...
*/
/* TL: Bag CodeLVars; */

void CodeBegin ( void )
{
    /* the stacks must be empty                                            */
    assert( STATE(CountStat) == 0 );
    assert( STATE(CountExpr) == 0 );

    /* remember the current frame                                          */
    STATE(CodeLVars) = STATE(CurrLVars);

    /* clear the code result bag                                           */
    STATE(CodeResult) = 0;
}

UInt CodeEnd (
    UInt                error )
{
    /* if everything went fine                                             */
    if ( ! error ) {

        /* the stacks must be empty                                        */
        assert( STATE(CountStat) == 0 );
        assert( STATE(CountExpr) == 0 );

        /* we must be back to 'STATE(CurrLVars)'                                  */
        assert( STATE(CurrLVars) == STATE(CodeLVars) );

        /* 'CodeFuncExprEnd' left the function already in 'STATE(CodeResult)'     */
    }

    /* otherwise clean up the mess                                         */
    else {

        /* empty the stacks                                                */
        STATE(CountStat) = 0;
        STATE(CountExpr) = 0;

        /* go back to the correct frame                                    */
        SWITCH_TO_OLD_LVARS( STATE(CodeLVars) );
    }

    /* return value is ignored                                             */
    return 0;
}


/****************************************************************************
**
*F  CodeFuncCallBegin() . . . . . . . . . . . . . . code function call, begin
*F  CodeFuncCallEnd( <funccall>, <options>, <nr> )  code function call, end
**
**  'CodeFuncCallBegin'  is an action to code  a function call.  It is called
**  by the reader  when it encounters the parenthesis  '(', i.e., *after* the
**  function expression is read.
**
**  'CodeFuncCallEnd' is an action to code a  function call.  It is called by
**  the reader when  it  encounters the parenthesis  ')',  i.e.,  *after* the
**  argument expressions are read.   <funccall> is 1  if  this is a  function
**  call,  and 0  if  this  is  a procedure  call.    <nr> is the   number of
**  arguments. <options> is 1 if options were present after the ':' in which
**  case the options have been read already.
*/
void CodeFuncCallBegin ( void )
{
}

void CodeFuncCallEnd (
    UInt                funccall,
    UInt                options,
    UInt                nr )
{
    Expr                call;           /* function call, result           */
    Expr                func;           /* function expression             */
    Expr                arg;            /* one argument expression         */
    UInt                i;              /* loop variable                   */
    Expr                opts = 0;       /* record literal for the options  */
    Expr                wrapper;        /* wrapper for calls with options  */

    /* allocate the function call                                          */
    if ( funccall && nr <= 6 ) {
        call = NewExpr( T_FUNCCALL_0ARGS+nr, SIZE_NARG_CALL(nr) );
    }
    else if ( funccall /* && 6 < nr */ ) {
        call = NewExpr( T_FUNCCALL_XARGS,    SIZE_NARG_CALL(nr) );
    }
    else if ( /* ! funccall && */ nr <=6 ) {
        call = NewExpr( T_PROCCALL_0ARGS+nr, SIZE_NARG_CALL(nr) );
    }
    else /* if ( ! funccall && 6 < nr ) */ {
        call = NewExpr( T_PROCCALL_XARGS,    SIZE_NARG_CALL(nr) );
    }

    /* get the options record if any */
    if (options)
      opts = PopExpr();
    
    /* enter the argument expressions                                      */
    for ( i = nr; 1 <= i; i-- ) {
        arg = PopExpr();
        ARGI_CALL(call,i) = arg;
    }

    /* enter the function expression                                       */
    func = PopExpr();
    FUNC_CALL(call) = func;

    /* wrap up the call with the options */
    if (options)
      {
        wrapper = NewExpr( funccall ? T_FUNCCALL_OPTS : T_PROCCALL_OPTS, 
                           2*sizeof(Expr));
        ADDR_EXPR(wrapper)[0] = opts;
        ADDR_EXPR(wrapper)[1] = call;
        call = wrapper;
      }

    /* push the function call                                              */
    if ( funccall ) {
        PushExpr( call );
    }
    else {
        PushStat( call );
    }
}


/****************************************************************************
**
*F  CodeFuncExprBegin( <narg>, <nloc>, <nams> ) . . code function expr, begin
*F  CodeFuncExprEnd( <nr>, <mapsto> )   . . . . code function expression, end
**
**  'CodeFuncExprBegin'  is an action to code  a  function expression.  It is
**  called when the reader encounters the beginning of a function expression.
**  <narg> is the number of  arguments (-1 if the  function takes a  variable
**  number of arguments), <nloc> is the number of locals, <nams> is a list of
**  local variable names.
**
**  'CodeFuncExprEnd'  is an action to  code  a function  expression.  It  is
**  called when the reader encounters the end of a function expression.  <nr>
**  is the number of statements in the body of the function.
*/
void CodeFuncExprBegin (
    Int                 narg,
    Int                 nloc,
    Obj                 nams,
    Int                 startLine)
{
    Obj                 fexp;           /* function expression bag         */
    Obj                 fexs;           /* function expressions list       */
    Bag                 body;           /* function body                   */
    Bag                 old;            /* old frame                       */
    Stat                stat1;          /* first statement in body         */

    /* remember the current offset                                         */
    PushOffsBody();

    /* and the loop nesting depth */
    PushLoopNesting();
    
    /* create a function expression                                        */
    fexp = NewBag( T_FUNCTION, sizeof(FunctionHeader) );
    SET_NARG_FUNC( fexp, narg );
    SET_NLOC_FUNC( fexp, nloc );
    SET_NAMS_FUNC( fexp, nams );
#ifdef HPCGAP
    if (nams) MakeBagPublic(nams);
#endif
    CHANGED_BAG( fexp );

    /* give it a functions expressions list                                */
    fexs = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( fexs, 0 );
    SET_FEXS_FUNC( fexp, fexs );
    CHANGED_BAG( fexp );

    /* give it a body                                                      */
    body = NewBag( T_BODY, 1024*sizeof(Stat) );
    SET_BODY_FUNC( fexp, body );
    CHANGED_BAG( fexp );

    /* record where we are reading from */
    SetupGapname(STATE(Input));
    Obj filename = ELM_LIST(FilenameCache, STATE(Input)->gapnameid);
    SET_FILENAME_BODY(body, filename);
    SET_STARTLINE_BODY(body, startLine);
    /*    Pr("Coding begin at %s:%d ",(Int)(STATE(Input)->name),STATE(Input)->number);
          Pr(" Body id %d\n",(Int)(body),0L); */
    STATE(OffsBody) = sizeof(BodyHeader);
    STATE(LoopNesting) = 0;

    /* give it an environment                                              */
    SET_ENVI_FUNC( fexp, STATE(CurrLVars) );
    CHANGED_BAG( fexp );
    MakeHighVars(STATE(CurrLVars));

    /* switch to this function                                             */
    SWITCH_TO_NEW_LVARS( fexp, (narg >0 ? narg : -narg), nloc, old );
    (void) old; /* please picky compilers. */

    /* allocate the top level statement sequence                           */
    stat1 = NewStat( T_SEQ_STAT, 8*sizeof(Stat) );
    assert( stat1 == OFFSET_FIRST_STAT );
}

void CodeFuncExprEnd (
    UInt                nr,
    UInt                mapsto )
{
    Expr                expr;           /* function expression, result     */
    Stat                stat1;          /* single statement of body        */
    Obj                 fexp;           /* function expression bag         */
    Obj                 fexs;           /* funct. expr. list of outer func */
    UInt                len;            /* length of func. expr. list      */
    UInt                i;              /* loop variable                   */

    /* get the function expression                                         */
    fexp = CURR_FUNC();
    assert(!STATE(LoopNesting));
    
    /* get the body of the function                                        */
    /* push an additional return-void-statement if neccessary              */
    /* the function interpreters depend on each function ``returning''     */
    if ( nr == 0 ) {
        CodeReturnVoid();
        nr++;
    }
    else {
        stat1 = PopStat();
        PushStat( stat1 );
        if ( TNUM_STAT(stat1) != T_RETURN_VOID
          && TNUM_STAT(stat1) != T_RETURN_OBJ )
        {
            CodeReturnVoidWhichIsNotProfiled();
            nr++;
        }
    }

    /* if the body is a long sequence, pack the other statements           */
    if ( 7 < nr ) {
        stat1 = PopSeqStat( nr-6 );
        PushStat( stat1 );
        nr = 7;
    }

    /* stuff the first statements into the first statement sequence       */
    /* Making sure to preserve the line number and file name              */
    *STAT_HEADER(OFFSET_FIRST_STAT)
        = fillFilenameLine(
            FILENAMEID_STAT(OFFSET_FIRST_STAT),
            LINE_STAT(OFFSET_FIRST_STAT),
            nr*sizeof(Stat),
            T_SEQ_STAT+nr-1);
    for ( i = 1; i <= nr; i++ ) {
        stat1 = PopStat();
        ADDR_STAT(OFFSET_FIRST_STAT)[nr-i] = stat1;
    }

    // make the function expression list immutable
    MakeImmutable( FEXS_FUNC( fexp ) );

    /* make the body smaller                                               */
    ResizeBag( BODY_FUNC(fexp), STATE(OffsBody) );
    SET_ENDLINE_BODY(BODY_FUNC(fexp), STATE(Input)->number);
    /*    Pr("  finished coding %d at line %d\n",(Int)(BODY_FUNC(fexp)), STATE(Input)->number); */

    /* switch back to the previous function                                */
    SWITCH_TO_OLD_LVARS( ENVI_FUNC(fexp) );

    /* restore loop nesting info */
    PopLoopNesting();
    
    /* restore the remembered offset                                       */
    PopOffsBody();

    /* if this was inside another function definition, make the expression */
    /* and store it in the function expression list of the outer function  */
    if ( STATE(CurrLVars) != STATE(CodeLVars) ) {
        fexs = FEXS_FUNC( CURR_FUNC() );
        len = PushPlist( fexs, fexp );
        expr = NewExpr( T_FUNC_EXPR, sizeof(Expr) );
        ADDR_EXPR(expr)[0] = (Expr)len;
        PushExpr( expr );
    }

    /* otherwise, make the function and store it in 'STATE(CodeResult)'           */
    else {
        STATE(CodeResult) = MakeFunction( fexp );
    }

}


/****************************************************************************
**
*F  CodeIfBegin() . . . . . . . . . . . code if-statement, begin of statement
*F  CodeIfElif()  . . . . . . . . . . code if-statement, begin of elif-branch
*F  CodeIfElse()  . . . . . . . . . . code if-statement, begin of else-branch
*F  CodeIfBeginBody() . . . . . . . . . . .  code if-statement, begin of body
*F  CodeIfEndBody( <nr> ) . . . . . . . . . .  code if-statement, end of body
*F  CodeIfEnd( <nr> ) . . . . . . . . . . code if-statement, end of statement
**
**  'CodeIfBegin' is an  action to code an  if-statement.  It is called  when
**  the reader encounters the 'if', i.e., *before* the condition is read.
**
**  'CodeIfElif' is an action to code an if-statement.  It is called when the
**  reader encounters an 'elif', i.e., *before* the condition is read.
**
**  'CodeIfElse' is an action to code an if-statement.  It is called when the
**  reader encounters an 'else'.
**
**  'CodeIfBeginBody' is  an action to   code an if-statement.  It  is called
**  when  the  reader encounters the beginning   of the statement  body of an
**  'if', 'elif', or 'else' branch, i.e., *after* the condition is read.
**
**  'CodeIfEndBody' is an action to code an if-statement.   It is called when
**  the reader encounters the end of the  statements body of an 'if', 'elif',
**  or 'else' branch.  <nr> is the number of statements in the body.
**
**  'CodeIfEnd' is an action to code an if-statement.  It  is called when the
**  reader encounters the end of the statement.   <nr> is the number of 'if',
**  'elif', or 'else' branches.
*/
void CodeIfBegin ( void )
{
}

void CodeIfElif ( void )
{
}

void CodeIfElse ( void )
{
    CodeTrueExpr();
}

void CodeIfBeginBody ( void )
{
}

void CodeIfEndBody (
    UInt                nr )
{
    /* collect the statements in a statement sequence if necessary         */
    PushStat( PopSeqStat( nr ) );
}

void CodeIfEnd (
    UInt                nr )
{
    Stat                stat;           /* if-statement, result            */
    Expr                cond;           /* condition of a branch           */
    UInt                hase;           /* has else branch                 */
    UInt                i;              /* loop variable                   */
    Expr                cond1 = 0;      /* first condition                 */
    Expr                cond2 = 0;      /* second condition                */

    /* peek at the last two conditions                                     */
    cond1 = PopExpr();
    hase = (TNUM_EXPR(cond1) == T_TRUE_EXPR);
    if (nr == 2) {
        cond2 = PopExpr();
        PushExpr(cond2);
    }
    PushExpr(cond1);

    // Some optimisation cases
    if (nr == 1) {
        if (TNUM_EXPR(cond1) == T_TRUE_EXPR) {
            // Leave statement
            PopExpr();
            return;
        }
        else if (TNUM_EXPR(cond1) == T_FALSE_EXPR) {
            // Remove entire if statement
            PopStat();
            PopExpr();
            PushStat(NewStat(T_EMPTY, 0));
            return;
        }
    }

    if (nr == 2 && hase) {
        if (TNUM_EXPR(cond2) == T_TRUE_EXPR) {
            // Leave 'true' case
            PopStat();
            PopExpr();
            PopExpr();
            return;
        }
        else if (TNUM_EXPR(cond2) == T_FALSE_EXPR) {
            // Leave 'false' case
            Stat body = PopStat();
            PopExpr();
            PopStat();
            PopExpr();
            PushStat(body);
            return;
        }
    }

    /* allocate the if-statement                                           */
    if      ( nr == 1 ) {
        stat = NewStat( T_IF,            nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else if ( nr == 2 && hase ) {
        stat = NewStat( T_IF_ELSE,       nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else if ( ! hase ) {
        stat = NewStat( T_IF_ELIF,       nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else {
        stat = NewStat( T_IF_ELIF_ELSE,  nr * (sizeof(Expr)+sizeof(Stat)) );
    }

    /* enter the branches                                                  */
    for ( i = nr; 1 <= i; i-- ) {
        Stat body = PopStat();
        cond = PopExpr();
        ADDR_STAT(stat)[2*(i-1)] = cond;
        ADDR_STAT(stat)[2*(i-1)+1] = body;
    }

    /* push the if-statement                                               */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeForBegin()  . . . . . . . . .  code for-statement, begin of statement
*F  CodeForIn() . . . . . . . . . . . . . . . . code for-statement, 'in' read
*F  CodeForBeginBody()  . . . . . . . . . . code for-statement, begin of body
*F  CodeForEndBody( <nr> )  . . . . . . . . . code for-statement, end of body
*F  CodeForEnd()  . . . . . . . . . . .  code for-statement, end of statement
**
**  'CodeForBegin' is  an action to code  a for-statement.  It is called when
**  the reader encounters the 'for', i.e., *before* the variable is read.
**
**  'CodeForIn' is an action to code a for-statement.  It  is called when the
**  reader encounters  the 'in',  i.e., *after*  the  variable  is  read, but
**  *before* the list expression is read.
**
**  'CodeForBeginBody'  is an action to  code a for-statement.   It is called
**  when   the reader encounters the beginning   of the statement body, i.e.,
**  *after* the list expression is read.
**
**  'CodeForEndBody' is an action to code a for-statement.  It is called when
**  the reader encounters the end of the statement  body.  <nr> is the number
**  of statements in the body.
**
**  'CodeForEnd' is an action to code a for-statement.  It is called when the
**  reader encounters  the end of   the  statement, i.e., immediately   after
**  'CodeForEndBody'.
*/
void CodeForBegin ( void )
{
}

void CodeForIn ( void )
{
  Expr var = PopExpr();
  if (TNUM_EXPR(var) == T_REF_GVAR)
    {
      PushGlobalForLoopVariable((UInt)ADDR_EXPR(var)[0]);
    }
  PushExpr(var);
}

void CodeForBeginBody ( void )
{
  STATE(LoopNesting)++;
}

void CodeForEndBody (
    UInt                nr )
{
    Stat                stat;           /* for-statement, result           */
    UInt                type;           /* type of for-statement           */
    Expr                var;            /* variable                        */
    Expr                list;           /* list                            */

    /* get the list expression                                             */
    list = PopExpr();

    /* get the variable reference                                          */
    var = PopExpr();

    if (TNUM_EXPR(var) == T_REF_GVAR)
      PopGlobalForLoopVariable();
    
    /* select the type of the for-statement                                */
    if ( TNUM_EXPR(list) == T_RANGE_EXPR && SIZE_EXPR(list) == 2*sizeof(Expr)
      && IS_REFLVAR(var) ) {
        type = T_FOR_RANGE;
    }
    else {
        type = T_FOR;
    }

    /* allocate the for-statement                                          */
    stat = PopLoopStat(type, 2, nr);

    /* enter the list expression                                           */
    ADDR_STAT(stat)[1] = list;

    /* enter the variable reference                                        */
    ADDR_STAT(stat)[0] = var;

    /* push the for-statement                                              */
    PushStat( stat );

    /* decrement loop nesting count */
    STATE(LoopNesting)--;
}

void CodeForEnd ( void )
{
}


/****************************************************************************
**
*F  CodeAtomicBegin()  . . . . . . .  code atomic-statement, begin of statement
*F  CodeAtomicBeginBody()  . . . . . . . . code atomic-statement, begin of body
*F  CodeAtomicEndBody( <nr> )  . . . . . . . code atomic-statement, end of body
*F  CodeAtomicEnd()  . . . . . . . . .  code atomic-statement, end of statement
**
**  'CodeAtomicBegin'  is an action to  code a atomic-statement.   It is called
**  when the  reader encounters the 'atomic',  i.e., *before* the condition is
**  read.
**
**  'CodeAtomicBeginBody'  is  an action   to code a  atomic-statement.   It is
**  called when  the reader encounters  the beginning  of the statement body,
**  i.e., *after* the condition is read.
**
**  'CodeAtomicEndBody' is an action to  code a atomic-statement.  It is called
**  when the reader encounters  the end of  the statement body.  <nr> is  the
**  number of statements in the body.
**
**  'CodeAtomicEnd' is an action to code a atomic-statement.  It is called when
**  the reader encounters  the end  of the  statement, i.e., immediate  after
**  'CodeAtomicEndBody'.
*/

void CodeAtomicBegin ( void )
{
}

void CodeAtomicBeginBody ( UInt nrexprs )
{
  PushExpr(INTEXPR_INT(nrexprs)); 
}

void CodeAtomicEndBody (
    UInt                nrstats )
{
    Stat                stat;           /* atomic-statement, result         */
    Stat                stat1;          /* single statement of body        */
    UInt                i;              /* loop variable                   */
    UInt nrexprs;
    Expr  e,qual;

    /* collect the statements into a statement sequence   */
    stat1 = PopSeqStat( nrstats );

    nrexprs = INT_INTEXPR(PopExpr());
    
    /* allocate the atomic-statement                                        */
    stat = NewStat( T_ATOMIC, sizeof(Stat) + nrexprs*2*sizeof(Stat) );
    
    /* enter the statement sequence */
    ADDR_STAT(stat)[0] = stat1;

    /* enter the expressions                                                */
    for ( i = 2*nrexprs; 1 <= i; i -= 2 ) {
        e = PopExpr();
        qual = PopExpr();
        ADDR_STAT(stat)[i] = e;
        ADDR_STAT(stat)[i-1] = qual;
    }

    /* push the atomic-statement                                            */
    PushStat( stat );
}

void CodeAtomicEnd ( void )
{
}

/****************************************************************************
**
*F  CodeQualifiedExprBegin()  . . . code readonly/readwrite expression start
*F  CodeQualifiedExprEnd()  . . . . . code readonly/readwrite expression end
**
**  These functions code the beginning and end of the readonly/readwrite
**  qualified expressions of an atomic statement.
*/

void CodeQualifiedExprBegin(UInt qual) 
{
  PushExpr(INTEXPR_INT(qual));
}

void CodeQualifiedExprEnd(void) 
{
}




/****************************************************************************
**
*F  CodeWhileBegin()  . . . . . . .  code while-statement, begin of statement
*F  CodeWhileBeginBody()  . . . . . . . . code while-statement, begin of body
*F  CodeWhileEndBody( <nr> )  . . . . . . . code while-statement, end of body
*F  CodeWhileEnd()  . . . . . . . . .  code while-statement, end of statement
**
**  'CodeWhileBegin'  is an action to  code a while-statement.   It is called
**  when the  reader encounters the 'while',  i.e., *before* the condition is
**  read.
**
**  'CodeWhileBeginBody'  is  an action   to code a  while-statement.   It is
**  called when  the reader encounters  the beginning  of the statement body,
**  i.e., *after* the condition is read.
**
**  'CodeWhileEndBody' is an action to  code a while-statement.  It is called
**  when the reader encounters  the end of  the statement body.  <nr> is  the
**  number of statements in the body.
**
**  'CodeWhileEnd' is an action to code a while-statement.  It is called when
**  the reader encounters  the end  of the  statement, i.e., immediate  after
**  'CodeWhileEndBody'.
*/
void CodeWhileBegin ( void )
{
}

void CodeWhileBeginBody ( void )
{
  STATE(LoopNesting)++;
}

void CodeWhileEndBody (
    UInt                nr )
{
    Stat                stat;           /* while-statement, result         */
    Expr                cond;           /* condition                       */

    /* allocate the while-statement                                        */
    stat = PopLoopStat(T_WHILE, 1, nr);

    /* enter the condition                                                 */
    cond = PopExpr();
    ADDR_STAT(stat)[0] = cond;

    /* decrmement loop nesting */
    STATE(LoopNesting)--;
    
    /* push the while-statement                                            */
    PushStat( stat );
}

void CodeWhileEnd ( void )
{
}


/****************************************************************************
**
*F  CodeRepeatBegin() . . . . . . . code repeat-statement, begin of statement
*F  CodeRepeatBeginBody() . . . . . . .  code repeat-statement, begin of body
*F  CodeRepeatEndBody( <nr> ) . . . . . .  code repeat-statement, end of body
*F  CodeRepeatEnd() . . . . . . . . . code repeat-statement, end of statement
**
**  'CodeRepeatBegin' is an action to code a  repeat-statement.  It is called
**  when the reader encounters the 'repeat'.
**
**  'CodeRepeatBeginBody' is an  action  to code  a  repeat-statement.  It is
**  called when the reader encounters  the  beginning of the statement  body,
**  i.e., immediately after 'CodeRepeatBegin'.
**
**  'CodeRepeatEndBody'   is an action  to code   a repeat-statement.  It  is
**  called when  the reader encounters the end  of  the statement body, i.e.,
**  *before* the condition is read.  <nr> is the  number of statements in the
**  body.
**
**  'CodeRepeatEnd' is an action to   code a repeat-statement.  It is  called
**  when  the reader encounters the end  of the statement,  i.e., *after* the
**  condition is read.
*/
void CodeRepeatBegin ( void )
{
}

void CodeRepeatBeginBody ( void )
{
  STATE(LoopNesting)++;
}

void CodeRepeatEndBody (
    UInt                nr )
{
    /* leave the number of statements in the body on the expression stack  */
    PushExpr( INTEXPR_INT(nr) );
    STATE(LoopNesting)--;
}

void CodeRepeatEnd ( void )
{
    Stat                stat;           /* repeat-statement, result        */
    UInt                nr;             /* number of statements in body    */
    Expr                cond;           /* condition                       */
    Expr                tmp;            /* temporary                       */

    /* get the condition                                                   */
    cond = PopExpr();

    /* get the number of statements in the body                            */
    /* 'CodeUntil' left this number on the expression stack (hack)         */
    tmp = PopExpr();
    nr = INT_INTEXPR( tmp );

    /* allocate the repeat-statement                                       */
    stat = PopLoopStat(T_REPEAT, 1, nr);

    /* enter the condition                                                 */
    ADDR_STAT(stat)[0] = cond;

    /* push the repeat-statement                                           */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeBreak() . . . . . . . . . . . . . . . . . . . .  code break-statement
**
**  'CodeBreak' is the  action to code a  break-statement.  It is called when
**  the reader encounters a 'break;'.
*/
void            CodeBreak ( void )
{
    Stat                stat;           /* break-statement, result         */

    if (!STATE(LoopNesting))
      SyntaxError("'break' statement not enclosed in a loop");
    
    /* allocate the break-statement                                        */
    stat = NewStat( T_BREAK, 0 * sizeof(Expr) );

    /* push the break-statement                                            */
    PushStat( stat );
}

/****************************************************************************
**
*F  CodeContinue() . . . . . . . . . . . . . . . . . . . .  code continue-statement
**
**  'CodeContinue' is the  action to code a  continue-statement.  It is called when
**  the reader encounters a 'continue;'.
*/
void            CodeContinue ( void )
{
    Stat                stat;           /* continue-statement, result         */

    if (!STATE(LoopNesting))
      SyntaxError("'continue' statement not enclosed in a loop");

    /* allocate the continue-statement                                        */
    stat = NewStat( T_CONTINUE, 0 * sizeof(Expr) );

    /* push the continue-statement                                            */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeReturnObj() . . . . . . . . . . . . . . . code return-value-statement
**
**  'CodeReturnObj' is the  action to code  a return-value-statement.  It  is
**  called when the reader encounters a 'return <expr>;', but *after* reading
**  the expression <expr>.
*/
void CodeReturnObj ( void )
{
    Stat                stat;           /* return-statement, result        */
    Expr                expr;           /* expression                      */

    /* allocate the return-statement                                       */
    stat = NewStat( T_RETURN_OBJ, sizeof(Expr) );

    /* enter the expression                                                */
    expr = PopExpr();
    ADDR_STAT(stat)[0] = expr;

    /* push the return-statement                                           */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeReturnVoid()  . . . . . . . . . . . . . .  code return-void-statement
**
**  'CodeReturnVoid' is the action  to  code a return-void-statement.   It is
**  called when the reader encounters a 'return;'.
**
**  'CodeReturnVoidWhichIsNotProfiled' creates a return which will not
**  be tracked by profiling. This is used for the implicit return put
**  at the end of functions.
*/
void CodeReturnVoid ( void )
{
    Stat                stat;           /* return-statement, result        */

    /* allocate the return-statement                                       */
    stat = NewStat( T_RETURN_VOID, 0 * sizeof(Expr) );

    /* push the return-statement                                           */
    PushStat( stat );
}

void CodeReturnVoidWhichIsNotProfiled ( void )
{
    Stat                stat;           /* return-statement, result        */

    /* allocate the return-statement, without profile information          */

    stat = NewStatWithProf( T_RETURN_VOID, 0 * sizeof(Expr), 0, 0 );

    /* push the return-statement                                           */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeOr()  . . . . . . . . . . . . . . . . . . . . . .  code or-expression
*F  CodeAnd() . . . . . . . . . . . . . . . . . . . . . . code and-expression
*F  CodeNot() . . . . . . . . . . . . . . . . . . . . . . code not-expression
*F  CodeEq()  . . . . . . . . . . . . . . . . . . . . . . . code =-expression
*F  CodeNe()  . . . . . . . . . . . . . . . . . . . . . .  code <>-expression
*F  CodeLt()  . . . . . . . . . . . . . . . . . . . . . . . code <-expression
*F  CodeGe()  . . . . . . . . . . . . . . . . . . . . . .  code >=-expression
*F  CodeGt()  . . . . . . . . . . . . . . . . . . . . . . . code >-expression
*F  CodeLe()  . . . . . . . . . . . . . . . . . . . . . .  code <=-expression
*F  CodeIn()  . . . . . . . . . . . . . . . . . . . . . .  code in-expression
*F  CodeSum() . . . . . . . . . . . . . . . . . . . . . . . code +-expression
*F  CodeAInv()  . . . . . . . . . . . . . . . . . . . code unary --expression
*F  CodeDiff()  . . . . . . . . . . . . . . . . . . . . . . code --expression
*F  CodeProd()  . . . . . . . . . . . . . . . . . . . . . . code *-expression
*F  CodeQuo() . . . . . . . . . . . . . . . . . . . . . . . code /-expression
*F  CodeMod() . . . . . . . . . . . . . . . . . . . . . . code mod-expression
*F  CodePow() . . . . . . . . . . . . . . . . . . . . . . . code ^-expression
**
**  'CodeOr', 'CodeAnd', 'CodeNot',  'CodeEq', 'CodeNe',  'CodeGt', 'CodeGe',
**  'CodeIn',  'CodeSum',  'CodeDiff', 'CodeProd', 'CodeQuo',  'CodeMod', and
**  'CodePow' are the actions to   code the respective operator  expressions.
**  They are called by the reader *after* *both* operands are read.
*/
void CodeOrL ( void )
{
}

void CodeOr ( void )
{
    PushBinaryOp( T_OR );
}

void CodeAndL ( void )
{
}

void CodeAnd ( void )
{
    PushBinaryOp( T_AND );
}

void CodeNot ( void )
{
    PushUnaryOp( T_NOT );
}

void CodeEq ( void )
{
    PushBinaryOp( T_EQ );
}

void CodeNe ( void )
{
    PushBinaryOp( T_NE );
}

void CodeLt ( void )
{
    PushBinaryOp( T_LT );
}

void CodeGe ( void )
{
    PushBinaryOp( T_GE );
}

void CodeGt ( void )
{
    PushBinaryOp( T_GT );
}

void CodeLe ( void )
{
    PushBinaryOp( T_LE );
}

void CodeIn ( void )
{
    PushBinaryOp( T_IN );
}

void CodeSum ( void )
{
    PushBinaryOp( T_SUM );
}

void CodeAInv ( void )
{
    Expr                expr;
    Int                 i;

    expr = PopExpr();
    if ( IS_INTEXPR(expr) && INT_INTEXPR(expr) != -(1L<<NR_SMALL_INT_BITS) ) {
        i = INT_INTEXPR(expr);
        PushExpr( INTEXPR_INT( -i ) );
    }
    else {
        PushExpr( expr );
        PushUnaryOp( T_AINV );
    }
}

void CodeDiff ( void )
{
    PushBinaryOp( T_DIFF );
}

void CodeProd ( void )
{
    PushBinaryOp( T_PROD );
}

void CodeQuo ( void )
{
    PushBinaryOp( T_QUO );
}

void CodeMod ( void )
{
    PushBinaryOp( T_MOD );
}

void CodePow ( void )
{
    PushBinaryOp( T_POW );
}


/****************************************************************************
**
*F  CodeIntExpr( <val> )  . . . . . . . . . . code literal integer expression
**
**  'CodeIntExpr' is the action to code a literal integer expression.  <val>
**  is the integer as a GAP object.
*/
void CodeIntExpr(Obj val)
{
    Expr                expr;           /* expression, result              */

    /* if it is small enough code it immediately                           */
    if ( IS_INTOBJ(val) ) {
        expr = INTEXPR_INT( INT_INTOBJ(val) );
    }

    /* otherwise stuff the value into the values list                      */
    else {
        GAP_ASSERT(TNUM_OBJ(val) == T_INTPOS || TNUM_OBJ(val) == T_INTNEG);
        expr = NewExpr( T_INT_EXPR, sizeof(UInt) + SIZE_OBJ(val) );
        ((UInt *)ADDR_EXPR(expr))[0] = (UInt)TNUM_OBJ(val);
        memcpy((UInt *)ADDR_EXPR(expr)+1, CONST_ADDR_OBJ(val), (size_t)SIZE_OBJ(val));
    }

    /* push the expression                                                 */
    PushExpr( expr );
}

/****************************************************************************
**
*F  CodeTildeExpr()  . . . . . . . . . . . . . .  code tilde expression
**
**  'CodeTildeExpr' is the action to code a tilde expression.
*/
void CodeTildeExpr ( void )
{
    PushExpr( NewExpr( T_TILDE_EXPR, 0L ) );
}

/****************************************************************************
**
*F  CodeTrueExpr()  . . . . . . . . . . . . . .  code literal true expression
**
**  'CodeTrueExpr' is the action to code a literal true expression.
*/
void CodeTrueExpr ( void )
{
    PushExpr( NewExpr( T_TRUE_EXPR, 0L ) );
}


/****************************************************************************
**
*F  CodeFalseExpr() . . . . . . . . . . . . . . code literal false expression
**
**  'CodeFalseExpr' is the action to code a literal false expression.
*/
void CodeFalseExpr ( void )
{
    PushExpr( NewExpr( T_FALSE_EXPR, 0L ) );
}


/****************************************************************************
**
*F  CodeCharExpr( <chr> ) . . . . . . . . code a literal character expression
**
**  'CodeCharExpr'  is the action  to  code a  literal  character expression.
**  <chr> is the C character.
*/
void CodeCharExpr (
    Char                chr )
{
    Expr                litr;           /* literal expression, result      */

    /* allocate the character expression                                   */
    litr = NewExpr( T_CHAR_EXPR, sizeof(UChar) );
    ((UChar*)ADDR_EXPR(litr))[0] = chr;

    /* push the literal expression                                         */
    PushExpr( litr );
}


/****************************************************************************
**
*F  CodePermCycle( <nrx>, <nrc> ) . . . . code literal permutation expression
*F  CodePerm( <nrc> ) . . . . . . . . . . code literal permutation expression
**
**  'CodePermCycle'  is an action to code  a  literal permutation expression.
**  It is called when one cycles is read completely.  <nrc>  is the number of
**  elements in that cycle.  <nrx> is the number of that  cycles (i.e., 1 for
**  the first cycle, 2 for the second, and so on).
**
**  'CodePerm' is an action to code a  literal permutation expression.  It is
**  called when  the permutation is read completely.   <nrc> is the number of
**  cycles.
*/
void CodePermCycle (
    UInt                nrx,
    UInt                nrc )
{
    Expr                cycle;          /* cycle, result                   */
    Expr                entry;          /* entry of cycle                  */
    UInt                j;              /* loop variable                   */

    /* allocate the new cycle                                              */
    cycle = NewExpr( T_PERM_CYCLE, nrx * sizeof(Expr) );

    /* enter the entries                                                   */
    for ( j = nrx; 1 <= j; j-- ) {
        entry = PopExpr();
        ADDR_EXPR(cycle)[j-1] = entry;
    }

    /* push the cycle                                                      */
    PushExpr( cycle );
}

void CodePerm (
    UInt                nrc )
{
    Expr                perm;           /* permutation, result             */
    Expr                cycle;          /* cycle of permutation            */
    UInt                i;              /* loop variable                   */

    /* allocate the new permutation                                        */
    perm = NewExpr( T_PERM_EXPR, nrc * sizeof(Expr) );

    /* enter the cycles                                                    */
    for ( i = nrc; 1 <= i; i-- ) {
        cycle = PopExpr();
        ADDR_EXPR(perm)[i-1] = cycle;
    }

    /* push the permutation                                                */
    PushExpr( perm );

}


/****************************************************************************
**
*F  CodeListExprBegin( <top> )  . . . . . . . . . code list expression, begin
*F  CodeListExprBeginElm( <pos> ) . . . . code list expression, begin element
*F  CodeListExprEndElm()  . . . . . . .  .. code list expression, end element
*F  CodeListExprEnd( <nr>, <range>, <top>, <tilde> )  . . code list expr, end
*/
void CodeListExprBegin (
    UInt                top )
{
}

void CodeListExprBeginElm (
    UInt                pos )
{
    /* push the literal integer value                                      */
    PushExpr( INTEXPR_INT(pos) );
}

void CodeListExprEndElm ( void )
{
}

void CodeListExprEnd (
    UInt                nr,
    UInt                range,
    UInt                top,
    UInt                tilde )
{
    Expr                list;           /* list, result                    */
    Expr                entry;          /* entry                           */
    Expr                pos;            /* position of an entry            */
    UInt                i;              /* loop variable                   */

    /* peek at the last position (which is the largest)                    */
    if ( nr != 0 ) {
        entry = PopExpr();
        pos   = PopExpr();
        PushExpr( pos );
        PushExpr( entry );
    }
    else {
        pos = INTEXPR_INT(0);
    }

    /* allocate the list expression                                        */
    if ( ! range && ! (top && tilde) ) {
        list = NewExpr( T_LIST_EXPR,      INT_INTEXPR(pos) * sizeof(Expr) );
    }
    else if ( ! range && (top && tilde) ) {
        list = NewExpr( T_LIST_TILDE_EXPR, INT_INTEXPR(pos) * sizeof(Expr) );
    }
    else /* if ( range && ! (top && tilde) ) */ {
        list = NewExpr( T_RANGE_EXPR,     INT_INTEXPR(pos) * sizeof(Expr) );
    }

    /* enter the entries                                                   */
    for ( i = nr; 1 <= i; i-- ) {
        entry = PopExpr();
        pos   = PopExpr();
        ADDR_EXPR(list)[ INT_INTEXPR(pos)-1 ] = entry;
    }

    /* push the list                                                       */
    PushExpr( list );
}


/****************************************************************************
**
*F  CodeStringExpr( <str> ) . . . . . . . .  code literal string expression
*/
void CodeStringExpr (
    Obj              str )
{
    Expr                string;         /* string, result                  */

    /* allocate the string expression                                      */
    string = NewExpr( T_STRING_EXPR, SIZEBAG_STRINGLEN(GET_LEN_STRING(str)) );

    /* copy the string                                                     */
    memcpy( ADDR_EXPR(string), CONST_ADDR_OBJ(str),
                        SIZEBAG_STRINGLEN(GET_LEN_STRING(str)) );

    /* push the string                                                     */
    PushExpr( string );
}

/****************************************************************************
**
*F  CodeFloatExpr( <str> ) . . . . . . . .  code literal float expression
*/
#define FLOAT_0_INDEX 1
#define FLOAT_1_INDEX 2
#define MAX_FLOAT_INDEX ((1L<<NR_SMALL_INT_BITS)-2)

static UInt GVAR_SAVED_FLOAT_INDEX;
static UInt NextFloatExprNumber = 3;

#if !defined(HPCGAP)
static UInt NextEagerFloatLiteralNumber = 1;
#endif

static Obj EAGER_FLOAT_LITERAL_CACHE = 0;
static Obj CONVERT_FLOAT_LITERAL_EAGER;


static UInt getNextFloatExprNumber( void ) {
  UInt next;
  HashLock(&NextFloatExprNumber);
  if (NextFloatExprNumber > MAX_FLOAT_INDEX)
    next = 0;
  else {
    next = NextFloatExprNumber++;
  }
  HashUnlock(&NextFloatExprNumber);
  return next;
}

static UInt CheckForCommonFloat(Char *str) {
  /* skip leading zeros */
  while (*str == '0')
    str++;
  if (*str == '.')
    /* might be zero literal */
    {
      /* skip point */
      str++;
      /* skip more zeroes */
      while (*str == '0')
        str++;
      /* if we've got to end of string we've got zero. */
      if (!IsDigit(*str))
        return FLOAT_0_INDEX;
    }
  if (*str++ !='1')
    return 0;
  /* might be one literal */
  if (*str++ != '.')
    return 0;
  /* skip zeros */
  while (*str == '0')
    str++;
  if (*str == '\0')
    return FLOAT_1_INDEX;
  if (IsDigit(*str))
    return 0;
  /* must now be an exponent character */
  assert(IsAlpha(*str));
  /* skip it */
  str++;
  /*skip + and - in exponent */
  if (*str == '+' || *str == '-')
    str++;
  /* skip leading zeros in the exponent */
  while (*str == '0')
    str++;
  /* if there's anything but leading zeros this isn't 
     a one literal */
  if (*str == '\0')
    return FLOAT_1_INDEX;
  else
    return 0;
}

static void CodeLazyFloatExpr( Char *str, UInt len) {
    UInt ix;

    /* Lazy case, store the string for conversion at run time */
    Expr fl = NewExpr( T_FLOAT_EXPR_LAZY, 2*sizeof(UInt) +len+1  );
    /* copy the string                                                     */
    memcpy( (char *)ADDR_EXPR(fl)+2*sizeof(UInt), str, 
            len+1 );
      
    *(UInt *)ADDR_EXPR(fl) = len;
    ix = CheckForCommonFloat(str);
    if (!ix) 
      ix = getNextFloatExprNumber();
    ((UInt *)ADDR_EXPR(fl))[1] = ix;
    
    /* push the expression                                                     */
    PushExpr( fl );
}

static void CodeEagerFloatExpr( Obj str, Char mark ) {
  /* Eager case, do the conversion now */
  UInt l = GET_LEN_STRING(str);
  Expr fl = NewExpr( T_FLOAT_EXPR_EAGER, sizeof(UInt)* 3 + l + 1);
  Obj v = CALL_2ARGS(CONVERT_FLOAT_LITERAL_EAGER, str, ObjsChar[(Int)mark]);
  UInt ix;
  assert(EAGER_FLOAT_LITERAL_CACHE);
#ifdef HPCGAP
  assert(TNUM_OBJ(EAGER_FLOAT_LITERAL_CACHE) == T_ALIST);
  ix = AddAList(EAGER_FLOAT_LITERAL_CACHE, v);
#else
  assert(IS_PLIST(EAGER_FLOAT_LITERAL_CACHE));
  AssPlist(EAGER_FLOAT_LITERAL_CACHE, NextEagerFloatLiteralNumber, v);
  ix = NextEagerFloatLiteralNumber++;
#endif
  ADDR_EXPR(fl)[0] = ix;
  ADDR_EXPR(fl)[1] = l;
  ADDR_EXPR(fl)[2] = (UInt)mark;
  memcpy(ADDR_EXPR(fl)+3, CHARS_STRING(str), l+1);
  PushExpr(fl);
}

void CodeFloatExpr (
    Char *              str )
{
  
  UInt l = strlen(str);
  UInt l1 = l;
  Char mark = '\0'; /* initialize to please compilers */
  if (str[l-1] == '_' )
    {
      l1 = l-1;
      mark = '\0';
    }
  else if (str[l-2] == '_')
    {
      l1 = l-2;
      mark = str[l-1];
    }
  if (l1 < l)
    {
      Obj s;
      C_NEW_STRING(s, l1, str);
      CodeEagerFloatExpr(s,mark);
    } else {
    CodeLazyFloatExpr(str, l);
  }
}

/****************************************************************************
**
*F  CodeLongFloatExpr( <str> ) . . . . . . .code long literal float expression
*/

void CodeLongFloatExpr (
    Obj              str )
{
  Char mark = '\0'; /* initialize to please compilers */

    /* allocate the float expression                                      */
    UInt l = GET_LEN_STRING(str);
    UInt l1 = l;
    if (CHARS_STRING(str)[l-1] == '_') {
      l1 = l-1;
      mark = '\0';
    } else if (CHARS_STRING(str)[l-2] == '_') {
      l1 = l-2;
      mark = CHARS_STRING(str)[l-1];
    }
    if (l1 < l) {
      CHARS_STRING(str)[l1] = '\0';
      SET_LEN_STRING(str,l1);
      CodeEagerFloatExpr(str, mark);
    } else {
      CodeLazyFloatExpr((Char *)CHARS_STRING(str), l);
    }
    
}


/****************************************************************************
**
*F  CodeRecExprBegin( <top> ) . . . . . . . . . . . . code record expr, begin
*F  CodeRecExprBeginElmName( <rnam> ) . . . . code record expr, begin element
*F  CodeRecExprBeginElmExpr() . . . . . . . . code record expr, begin element
*F  CodeRecExprEndElmExpr() . . . . . . . . . . code record expr, end element
*F  CodeRecExprEnd( <nr>, <top>, <tilde> )  . . . . . . code record expr, end
*/
void CodeRecExprBegin (
    UInt                top )
{
}

void CodeRecExprBeginElmName (
    UInt                rnam )
{
    /* push the record name as integer expressions                         */
    PushExpr( INTEXPR_INT( rnam ) );
}

void CodeRecExprBeginElmExpr ( void )
{
    Expr                expr;

    /* convert an integer expression to a record name                      */
    expr = PopExpr();
    if ( IS_INTEXPR(expr) ) {
        PushExpr( INTEXPR_INT( RNamIntg( INT_INTEXPR(expr) ) ) );
    }
    else {
        PushExpr( expr );
    }
}

void CodeRecExprEndElm ( void )
{
}

void CodeRecExprEnd (
    UInt                nr,
    UInt                top,
    UInt                tilde )
{
    Expr                record;         /* record, result                  */
    Expr                entry;          /* entry                           */
    Expr                rnam;           /* position of an entry            */
    UInt                i;              /* loop variable                   */

    /* allocate the record expression                                      */
    if ( ! (top && tilde) ) {
        record = NewExpr( T_REC_EXPR,      nr * 2 * sizeof(Expr) );
    }
    else /* if ( (top && tilde) ) */ {
        record = NewExpr( T_REC_TILDE_EXPR, nr * 2 * sizeof(Expr) );
    }

    /* enter the entries                                                   */
    for ( i = nr; 1 <= i; i-- ) {
        entry = PopExpr();
        rnam  = PopExpr();
        ADDR_EXPR(record)[2*(i-1)]   = rnam;
        ADDR_EXPR(record)[2*(i-1)+1] = entry;
    }

    /* push the record                                                     */
    PushExpr( record );
}


/****************************************************************************
**
*F  CodeAssLVar( <lvar> ) . . . . . . . . . . . . .  code assignment to local
**
**  'CodeAssLVar' is the action  to code an  assignment to the local variable
**  <lvar> (given  by its  index).  It is   called by the  reader *after* the
**  right hand side expression is read.
**
**  An assignment  to a  local variable  is   represented by a  bag with  two
**  subexpressions.  The  *first* is the local variable,  the *second* is the
**  right hand side expression.
*/
void CodeAssLVar (
    UInt                lvar )
{
    Stat                ass;            /* assignment, result              */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASS_LVAR,        2 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)rhsx;

    /* enter the local variable                                            */
    ADDR_STAT(ass)[0] = (Stat)lvar;

    /* push the assignment                                                 */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeUnbLVar( <lvar> ) . . . . . . . . . . .  code unbind a local variable
*/
void CodeUnbLVar (
    UInt                lvar )
{
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_LVAR, sizeof(Stat) );

    /* enter the local variable                                            */
    ADDR_STAT(ass)[0] = (Stat)lvar;

    /* push the unbind                                                     */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeRefLVar( <lvar> ) . . . . . . . . . . . . . . code reference to local
**
**  'CodeRefLVar' is  the action  to code a  reference  to the local variable
**  <lvar> (given  by its   index).  It is   called by  the  reader  when  it
**  encounters a local variable.
**
**  A   reference to   a local  variable    is represented immediately   (see
**  'REFLVAR_LVAR').
*/
void CodeRefLVar (
    UInt                lvar )
{
    Expr                ref;            /* reference, result               */

    /* make the reference                                                  */
    ref = REFLVAR_LVAR(lvar);

    /* push the reference                                                  */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeIsbLVar( <lvar> ) . . . . . . . . . . code bound local variable check
*/
void CodeIsbLVar (
    UInt                lvar )
{
    Expr                ref;            /* isbound, result                 */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_LVAR, sizeof(Expr) );

    /* enter the local variable                                            */
    ADDR_EXPR(ref)[0] = (Expr)lvar;

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssHVar( <hvar> ) . . . . . . . . . . . . . code assignment to higher
**
**  'CodeAssHVar' is the action to code an  assignment to the higher variable
**  <hvar> (given by its  level  and  index).  It  is  called by  the  reader
**  *after* the right hand side expression is read.
**
**  An assignment to a higher variable is represented by a statement bag with
**  two subexpressions.  The *first* is the higher  variable, the *second* is
**  the right hand side expression.
*/
void CodeAssHVar (
    UInt                hvar )
{
    Stat                ass;            /* assignment, result              */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASS_HVAR, 2 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)rhsx;

    /* enter the higher variable                                           */
    ADDR_STAT(ass)[0] = (Stat)hvar;

    /* push the assignment                                                 */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeUnbHVar( <hvar> ) . . . . . . . . . . . . . . . code unbind of higher
*/
void CodeUnbHVar (
    UInt                hvar )
{
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_HVAR, sizeof(Stat) );

    /* enter the higher variable                                           */
    ADDR_STAT(ass)[0] = (Stat)hvar;

    /* push the unbind                                                     */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeRefHVar( <hvar> ) . . . . . . . . . . . . .  code reference to higher
**
**  'CodeRefHVar' is the  action to code  a reference to the higher  variable
**  <hvar> (given by its level  and index).  It is  called by the reader when
**  it encounters a higher variable.
**
**  A reference to a higher variable is represented by an expression bag with
**  one subexpression.  This is the higher variable.
*/
void CodeRefHVar (
    UInt                hvar )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_REF_HVAR, sizeof(Expr) );

    /* enter the higher variable                                           */
    ADDR_EXPR(ref)[0] = (Expr)hvar;

    /* push the reference                                                  */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeIsbHVar( <hvar> ) . . . . . . . . . . . . . . code bound higher check
*/
void CodeIsbHVar (
    UInt                hvar )
{
    Expr                ref;            /* isbound, result                 */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_HVAR, sizeof(Expr) );

    /* enter the higher variable                                           */
    ADDR_EXPR(ref)[0] = (Expr)hvar;

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssGVar( <gvar> ) . . . . . . . . . . . . . code assignment to global
**
**  'CodeAssGVar' is the action to code  an assignment to the global variable
**  <gvar>.  It is  called   by  the reader    *after* the right   hand  side
**  expression is read.
**
**  An assignment to a global variable is represented by a statement bag with
**  two subexpressions.  The *first* is the  global variable, the *second* is
**  the right hand side expression.
*/
void CodeAssGVar (
    UInt                gvar )
{
    Stat                ass;            /* assignment, result              */
    Expr                rhsx;           /* right hand side expression      */

    /*  allocate the assignment                                            */
    ass = NewStat( T_ASS_GVAR, 2 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)rhsx;

    /* enter the global variable                                           */
    ADDR_STAT(ass)[0] = (Stat)gvar;

    /* push the assignment                                                 */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeUnbGVar( <gvar> ) . . . . . . . . . . . . . . . code unbind of global
*/
void CodeUnbGVar (
    UInt                gvar )
{
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_GVAR, sizeof(Stat) );

    /* enter the global variable                                           */
    ADDR_STAT(ass)[0] = (Stat)gvar;

    /* push the unbind                                                     */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeRefGVar( <gvar> ) . . . . . . . . . . . . .  code reference to global
**
**  'CodeRefGVar' is the  action to code a  reference to  the global variable
**  <gvar>.  It is called by the reader when it encounters a global variable.
**
**  A reference to a global variable is represented by an expression bag with
**  one subexpression.  This is the global variable.
*/
void CodeRefGVar (
    UInt                gvar )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_REF_GVAR, sizeof(Expr) );

    /* enter the global variable                                           */
    ADDR_EXPR(ref)[0] = (Expr)gvar;

    /* push the reference                                                  */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeIsbGVar( <gvar> ) . . . . . . . . . . . . . . code bound global check
*/
void CodeIsbGVar (
    UInt                gvar )
{
    Expr                ref;            /* isbound, result                 */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_GVAR, sizeof(Expr) );

    /* enter the global variable                                           */
    ADDR_EXPR(ref)[0] = (Expr)gvar;

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssList() . . . . . . . . . . . . . . . . . code assignment to a list
*F  CodeAsssList()  . . . . . . . . . . .  code multiple assignment to a list
*F  CodeAssListLevel( <level> ) . . . . . .  code assignment to several lists
*F  CodeAsssListLevel( <level> )  . code multiple assignment to several lists
*/
void CodeAssListUniv ( 
		      Stat                ass,
		       Int narg)
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Expr                rhsx;           /* right hand side expression      */
    Int i;

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[narg+1] = (Stat)rhsx;

    /* enter the position expression                                       */
    for (i = narg; i > 0; i--) {
      pos = PopExpr();
      ADDR_STAT(ass)[i] = (Stat)pos;
    }

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_STAT(ass)[0] = (Stat)list;

    /* push the assignment                                                 */
    PushStat( ass );
}

void CodeAssList ( Int narg )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    if (narg == 1)
      ass = NewStat( T_ASS_LIST, 3 * sizeof(Stat) );
    else if (narg == 2)
      ass = NewStat( T_ASS2_LIST, 4 * sizeof(Stat));
    else
      ass = NewStat( T_ASSX_LIST, (narg + 2) * sizeof(Stat));

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass, narg );
}

void CodeAsssList ( void )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASSS_LIST, 3 * sizeof(Stat) );

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass, 1 );
}

void CodeAssListLevel ( Int narg,
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( T_ASS_LIST_LEV, (narg + 3) * sizeof(Stat) );
    ADDR_STAT(ass)[narg+2] = (Stat)level;

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass, narg );
}

void CodeAsssListLevel (
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( T_ASSS_LIST_LEV, 4 * sizeof(Stat) );
    ADDR_STAT(ass)[3] = (Stat)level;

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass, 1 );
}


/****************************************************************************
**
*F  CodeUnbList() . . . . . . . . . . . . . . .  code unbind of list position
*/
void CodeUnbList ( Int narg )
{
    Stat                ass;            /* unbind, result                  */
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Int i;

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_LIST, (narg+1) * sizeof(Stat) );

    /* enter the position expressions                                       */
    for (i = narg; i > 0; i--) {
      pos = PopExpr();
      ADDR_STAT(ass)[i] = (Stat)pos;
    }

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_STAT(ass)[0] = (Stat)list;

    /* push the unbind                                                     */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeElmList() . . . . . . . . . . . . . . . . .  code selection of a list
*F  CodeElmsList()  . . . . . . . . . . . . code multiple selection of a list
*F  CodeElmListLevel( <level> ) . . . . . . . code selection of several lists
*F  CodeElmsListLevel( <level> )  .  code multiple selection of several lists
*/
void CodeElmListUniv (
		      Expr                ref,
		      Int narg)
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Int                i;

    /* enter the position expression                                       */

    for (i = narg; i > 0; i--) {
      pos = PopExpr();
      ADDR_EXPR(ref)[i] = pos;
    }

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_EXPR(ref)[0] = list;

    /* push the reference                                                  */
    PushExpr( ref );
}

void CodeElmList ( Int narg )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    if (narg == 1)
      ref = NewExpr( T_ELM_LIST, 2 * sizeof(Expr) );
    else if (narg == 2)
      ref = NewExpr( T_ELM2_LIST, 3 * sizeof(Expr) );
    else
      ref = NewExpr( T_ELMX_LIST, (narg + 1) * sizeof(Expr));
      
    /* let 'CodeElmListUniv' to the rest                                   */
    CodeElmListUniv( ref, narg );
}

void CodeElmsList ( void )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_ELMS_LIST, 2 * sizeof(Expr) );

    /* let 'CodeElmListUniv' to the rest                                   */
    CodeElmListUniv( ref, 1 );
}

void CodeElmListLevel ( Int narg,
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( T_ELM_LIST_LEV, (narg + 2) * sizeof(Expr));
    ADDR_EXPR(ref)[narg+1] = (Stat)level;

    /* let 'CodeElmListUniv' do the rest                                   */
    CodeElmListUniv( ref, narg );
}

void CodeElmsListLevel (
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( T_ELMS_LIST_LEV, 3 * sizeof(Expr) );
    ADDR_EXPR(ref)[2] = (Stat)level;

    /* let 'CodeElmListUniv' do the rest                                   */
    CodeElmListUniv( ref, 1 );
}


/****************************************************************************
**
*F  CodeIsbList() . . . . . . . . . . . . . .  code bound list position check
*/
void CodeIsbList ( Int narg )
{
    Expr                ref;            /* isbound, result                 */
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Int i;

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_LIST, (narg + 1) * sizeof(Expr) );

    /* enter the position expression                                       */
    for (i = narg; i > 0; i--) {
      pos = PopExpr();
      ADDR_EXPR(ref)[i] = pos;
    }

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_EXPR(ref)[0] = list;

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssRecName( <rnam> )  . . . . . . . . . . code assignment to a record
*F  CodeAssRecExpr()  . . . . . . . . . . . . . . code assignment to a record
*/
void            CodeAssRecName (
    UInt                rnam )
{
    Stat                stat;           /* assignment, result              */
    Expr                rec;            /* record expression               */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( T_ASS_REC_NAME, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(stat)[2] = (Stat)rhsx;

    /* enter the name                                                      */
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the assignment                                                 */
    PushStat( stat );
}

void            CodeAssRecExpr ( void )
{
    Stat                stat;           /* assignment, result              */
    Expr                rec;            /* record expression               */
    Expr                rnam;           /* name expression                 */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( T_ASS_REC_EXPR, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(stat)[2] = (Stat)rhsx;

    /* enter the name expression                                           */
    rnam = PopExpr();
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the assignment                                                 */
    PushStat( stat );
}

void            CodeUnbRecName (
    UInt                rnam )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */

    /* allocate the unbind                                                 */
    stat = NewStat( T_UNB_REC_NAME, 2 * sizeof(Stat) );

    /* enter the name                                                      */
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the unbind                                                     */
    PushStat( stat );
}

void            CodeUnbRecExpr ( void )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */
    Expr                rnam;           /* name expression                 */

    /* allocate the unbind                                                 */
    stat = NewStat( T_UNB_REC_EXPR, 2 * sizeof(Stat) );

    /* enter the name expression                                           */
    rnam = PopExpr();
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the unbind                                                     */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeElmRecName( <rnam> )  . . . . . . . . . .  code selection of a record
*F  CodeElmRecExpr()  . . . . . . . . . . . . . .  code selection of a record
*/
void CodeElmRecName (
    UInt                rnam )
{
    Expr                expr;           /* reference, result               */
    Expr                rec;            /* record expresion                */

    /* allocate the reference                                              */
    expr = NewExpr( T_ELM_REC_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    ADDR_EXPR(expr)[1] = (Expr)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the reference                                                  */
    PushExpr( expr );
}

void CodeElmRecExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expresion                */

    /* allocate the reference                                              */
    expr = NewExpr( T_ELM_REC_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    ADDR_EXPR(expr)[1] = rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the reference                                                  */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeIsbRecName( <rnam> )  . . . . . . . . . . . code bound rec name check
*/
void CodeIsbRecName (
    UInt                rnam )
{
    Expr                expr;           /* isbound, result                 */
    Expr                rec;            /* record expresion                */

    /* allocate the isbound                                                */
    expr = NewExpr( T_ISB_REC_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    ADDR_EXPR(expr)[1] = (Expr)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the isbound                                                    */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeIsbRecExpr()  . . . . . . . . . . . . . . . code bound rec expr check
*/
void CodeIsbRecExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expresion                */

    /* allocate the isbound                                                */
    expr = NewExpr( T_ISB_REC_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    ADDR_EXPR(expr)[1] = rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the isbound                                                    */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeAssPosObj() . . . . . . . . . . . . . . . . code assignment to a list
*F  CodeAsssPosObj()  . . . . . . . . . .  code multiple assignment to a list
*F  CodeAssPosObjLevel( <level> ) . . . . .  code assignment to several lists
*F  CodeAsssPosObjLevel( <level> )  code multiple assignment to several lists
*/
void CodeAssPosObjUniv (
    Stat                ass )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Expr                rhsx;           /* right hand side expression      */

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[2] = (Stat)rhsx;

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_STAT(ass)[0] = (Stat)list;

    /* push the assignment                                                 */
    PushStat( ass );
}

void CodeAssPosObj ( void )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASS_POSOBJ, 3 * sizeof(Stat) );

    /* let 'CodeAssPosObjUniv' do the rest                                 */
    CodeAssPosObjUniv( ass );
}

void CodeAsssPosObj ( void )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASSS_POSOBJ, 3 * sizeof(Stat) );

    /* let 'CodeAssPosObjUniv' do the rest                                 */
    CodeAssPosObjUniv( ass );
}

void CodeAssPosObjLevel (
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( T_ASS_POSOBJ_LEV, 4 * sizeof(Stat) );
    ADDR_STAT(ass)[3] = (Stat)level;

    /* let 'CodeAssPosObjUniv' do the rest                                 */
    CodeAssPosObjUniv( ass );
}

void CodeAsssPosObjLevel (
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( T_ASSS_POSOBJ_LEV, 4 * sizeof(Stat) );
    ADDR_STAT(ass)[3] = (Stat)level;

    /* let 'CodeAssPosObjUniv' do the rest                                 */
    CodeAssPosObjUniv( ass );
}


/****************************************************************************
**
*F  CodeUnbPosObj() . . . . . . . . . . . . . . . . .  code unbind pos object
*/
void CodeUnbPosObj ( void )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_POSOBJ, 2 * sizeof(Stat) );

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_STAT(ass)[0] = (Stat)list;

    /* push the unbind                                                     */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeElmPosObj() . . . . . . . . . . . . . . . .  code selection of a list
*F  CodeElmsPosObj()  . . . . . . . . . . . code multiple selection of a list
*F  CodeElmPosObjLevel( <level> ) . . . . . . code selection of several lists
*F  CodeElmsPosObjLevel( <level> )   code multiple selection of several lists
*/
void CodeElmPosObjUniv (
    Expr                ref )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_EXPR(ref)[1] = pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_EXPR(ref)[0] = list;

    /* push the reference                                                  */
    PushExpr( ref );
}

void CodeElmPosObj ( void )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_ELM_POSOBJ, 2 * sizeof(Expr) );

    /* let 'CodeElmPosObjUniv' to the rest                                   */
    CodeElmPosObjUniv( ref );
}

void CodeElmsPosObj ( void )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_ELMS_POSOBJ, 2 * sizeof(Expr) );

    /* let 'CodeElmPosObjUniv' to the rest                                   */
    CodeElmPosObjUniv( ref );
}

void CodeElmPosObjLevel (
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( T_ELM_POSOBJ_LEV, 3 * sizeof(Expr) );
    ADDR_EXPR(ref)[2] = (Stat)level;

    /* let 'CodeElmPosObjUniv' do the rest                                 */
    CodeElmPosObjUniv( ref );
}

void CodeElmsPosObjLevel (
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( T_ELMS_POSOBJ_LEV, 3 * sizeof(Expr) );
    ADDR_EXPR(ref)[2] = (Stat)level;

    /* let 'CodeElmPosObjUniv' do the rest                                 */
    CodeElmPosObjUniv( ref );
}


/****************************************************************************
**
*F  CodeIsbPosObj() . . . . . . . . . . . . . . . code bound pos object check
*/
void CodeIsbPosObj ( void )
{
    Expr                ref;            /* isbound, result                 */
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_POSOBJ, 2 * sizeof(Expr) );

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_EXPR(ref)[1] = pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_EXPR(ref)[0] = list;

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssComObjName( <rnam> ) . . . . . . . . . code assignment to a record
*F  CodeAssComObjExpr() . . . . . . . . . . . . . code assignment to a record
*/
void            CodeAssComObjName (
    UInt                rnam )
{
    Stat                stat;           /* assignment, result              */
    Expr                rec;            /* record expression               */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( T_ASS_COMOBJ_NAME, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(stat)[2] = (Stat)rhsx;

    /* enter the name                                                      */
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the assignment                                                 */
    PushStat( stat );
}

void            CodeAssComObjExpr ( void )
{
    Stat                stat;           /* assignment, result              */
    Expr                rec;            /* record expression               */
    Expr                rnam;           /* name expression                 */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( T_ASS_COMOBJ_EXPR, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(stat)[2] = (Stat)rhsx;

    /* enter the name expression                                           */
    rnam = PopExpr();
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the assignment                                                 */
    PushStat( stat );
}

void            CodeUnbComObjName (
    UInt                rnam )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */

    /* allocate the unbind                                                 */
    stat = NewStat( T_UNB_COMOBJ_NAME, 2 * sizeof(Stat) );

    /* enter the name                                                      */
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the unbind                                                     */
    PushStat( stat );
}

void            CodeUnbComObjExpr ( void )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */
    Expr                rnam;           /* name expression                 */

    /* allocate the unbind                                                 */
    stat = NewStat( T_UNB_COMOBJ_EXPR, 2 * sizeof(Stat) );

    /* enter the name expression                                           */
    rnam = PopExpr();
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the unbind                                                     */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeElmComObjName( <rnam> ) . . . . . . . . .  code selection of a record
*F  CodeElmComObjExpr() . . . . . . . . . . . . .  code selection of a record
*/
void CodeElmComObjName (
    UInt                rnam )
{
    Expr                expr;           /* reference, result               */
    Expr                rec;            /* record expresion                */

    /* allocate the reference                                              */
    expr = NewExpr( T_ELM_COMOBJ_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    ADDR_EXPR(expr)[1] = (Expr)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the reference                                                  */
    PushExpr( expr );
}

void CodeElmComObjExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expresion                */

    /* allocate the reference                                              */
    expr = NewExpr( T_ELM_COMOBJ_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    ADDR_EXPR(expr)[1] = rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the reference                                                  */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeIsbComObjName( <rname> )  . . . . .  code bound com object name check
*/
void CodeIsbComObjName (
    UInt                rnam )
{
    Expr                expr;           /* isbound, result                 */
    Expr                rec;            /* record expresion                */

    /* allocate the isbound                                                */
    expr = NewExpr( T_ISB_COMOBJ_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    ADDR_EXPR(expr)[1] = (Expr)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the isbound                                                    */
    PushExpr( expr );
}

/****************************************************************************
**
*F  CodeIsbComObjExpr() . . . . . . . . . .  code bound com object expr check
*/
void CodeIsbComObjExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expresion                */

    /* allocate the isbound                                                */
    expr = NewExpr( T_ISB_COMOBJ_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    ADDR_EXPR(expr)[1] = rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the isbound                                                    */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeEmpty()  . . . . code an empty statement
**
*/

extern void CodeEmpty( void )
{
  Stat stat;
  stat = NewStat(T_EMPTY, 0);
  PushStat( stat );
}

/****************************************************************************
**
*F  CodeInfoBegin() . . . . . . . . . . . . .  start coding of Info statement
*F  CodeInfoMiddle()  . . . . . . . . .   shift to coding printable arguments
*F  CodeInfoEnd( <narg> ) . . Info statement complete, <narg> things to print
**
**  These  actions deal  with the  Info  statement, which is coded specially,
**  because not all of its arguments are always evaluated.
**
**  Only CodeInfoEnd actually does anything
*/
void CodeInfoBegin ( void )
{
}

void CodeInfoMiddle ( void )
{
}

void CodeInfoEnd   (
    UInt                narg )
{
    Stat                stat;           /* we build the statement here     */
    Expr                expr;           /* expression                      */
    UInt                i;              /* loop variable                   */

    /* allocate the new statement                                          */
    stat = NewStat( T_INFO, SIZE_NARG_INFO(2+narg) );

    /* narg only counts the printable arguments                            */
    for ( i = narg + 2; 0 < i; i-- ) {
        expr = PopExpr();
        ARGI_INFO( stat, i ) = expr;
    }

    /* push the statement                                                  */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeAssertBegin() . . . . . . .  start interpretation of Assert statement
*F  CodeAsseerAfterLevel()  . . called after the first argument has been read
*F  CodeAssertAfterCondition() called after the second argument has been read
*F  CodeAssertEnd2Args() . . . . called after reading the closing parenthesis
*F  CodeAssertEnd3Args() . . . . called after reading the closing parenthesis
**
**  Only the End functions actually do anything
*/
void CodeAssertBegin ( void )
{
}

void CodeAssertAfterLevel ( void )
{
}

void CodeAssertAfterCondition ( void )
{
}

void CodeAssertEnd2Args ( void )
{
    Stat                stat;           /* we build the statement here     */

    stat = NewStat( T_ASSERT_2ARGS, 2*sizeof(Expr) );

    ADDR_STAT(stat)[1] = PopExpr(); /* condition */
    ADDR_STAT(stat)[0] = PopExpr(); /* level */

    PushStat( stat );
}

void CodeAssertEnd3Args ( void )
{
    Stat                stat;           /* we build the statement here     */

    stat = NewStat( T_ASSERT_3ARGS, 3*sizeof(Expr) );

    ADDR_STAT(stat)[2] = PopExpr(); /* message */
    ADDR_STAT(stat)[1] = PopExpr(); /* condition */
    ADDR_STAT(stat)[0] = PopExpr(); /* level */

    PushStat( stat );
}

/****************************************************************************
**
*F  SaveBody( <body> ) . . . . . . . . . . . . . . .  workspace saving method
**
**  A body is made up of statements and expressions, and these are all
**  organised to regular boundaries based on the types Stat and Expr, which
**  are currently both UInt
**
**  String literals should really be saved byte-wise, to be safe across machines
**  of different endianness, but this would mean parsing the bag as we save it
**  which it would be nice to avoid just now.
*/
void SaveBody ( Obj body )
{
  UInt i;
  const UInt *ptr = (const UInt *) CONST_ADDR_OBJ(body);
  /* Save the new inforation in the body */
  for (i =0; i < sizeof(BodyHeader)/sizeof(Obj); i++)
    SaveSubObj((Obj)(*ptr++));
  /* and the rest */
  for (; i < (SIZE_OBJ(body)+sizeof(UInt)-1)/sizeof(UInt); i++)
    SaveUInt(*ptr++);
}

/****************************************************************************
**
*F  LoadBody( <body> ) . . . . . . . . . . . . . . . workspace loading method
**
**  A body is made up of statements and expressions, and these are all
**  organised to regular boundaries based on the types Stat and Expr, which
**  are currently both UInt
**
*/
void LoadBody ( Obj body )
{
  UInt i;
  UInt *ptr;
  ptr = (UInt *) ADDR_OBJ(body);
  for (i =0; i < sizeof(BodyHeader)/sizeof(Obj); i++)
    *(Obj *)(ptr++) = LoadSubObj();
  for (; i < (SIZE_OBJ(body)+sizeof(UInt)-1)/sizeof(UInt); i++)
    *ptr++ = LoadUInt();
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

  GVAR_FUNC(GET_FILENAME_CACHE, 0, ""),
  { 0, 0, 0, 0, 0 }

};

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* install the marking functions for function body bags                */
    InfoBags[ T_BODY ].name = "function body bag";
    InitMarkFuncBags( T_BODY, MarkThreeSubBags );

    SaveObjFuncs[ T_BODY ] = SaveBody;
    LoadObjFuncs[ T_BODY ] = LoadBody;

    /* Allocate function bodies in the public data space */
    MakeBagTypePublic(T_BODY);

#if !defined(HPCGAP)
    /* make the result variable known to Gasman                            */
    InitGlobalBag( &STATE(CodeResult), "CodeResult" );
#endif

    InitGlobalBag( &FilenameCache, "FilenameCache" );

    /* allocate the statements and expressions stacks                      */
    InitGlobalBag( &STATE(StackStat), "STATE(StackStat)" );
    InitGlobalBag( &STATE(StackExpr), "STATE(StackExpr)" );

    /* some functions and globals needed for float conversion */
    InitCopyGVar( "EAGER_FLOAT_LITERAL_CACHE", &EAGER_FLOAT_LITERAL_CACHE);
    InitFopyGVar( "CONVERT_FLOAT_LITERAL_EAGER", &CONVERT_FLOAT_LITERAL_EAGER);

    InitHdlrFuncsFromTable( GVarFuncs );

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
    UInt gv;
    Obj cache;

    /* allocate the statements and expressions stacks                      */
    STATE(StackStat) = NewBag( T_BODY, 64*sizeof(Stat) );
    STATE(StackExpr) = NewBag( T_BODY, 64*sizeof(Expr) );
#ifdef HPCGAP
    FilenameCache = NewAtomicList(0);
#else
    FilenameCache = NEW_PLIST(T_PLIST, 0);
#endif

    GVAR_SAVED_FLOAT_INDEX = GVarName("SavedFloatIndex");
    
    gv = GVarName("EAGER_FLOAT_LITERAL_CACHE");
#ifdef HPCGAP
    cache = NewAtomicList(1);
#else
    cache = NEW_PLIST(T_PLIST+IMMUTABLE, 1000L);
    SET_LEN_PLIST(cache,0);
#endif
    AssGVar(gv, cache);

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . .  recover
*/
static Int PostRestore (
    StructInitInfo *    module )
{
  GVAR_SAVED_FLOAT_INDEX = GVarName("SavedFloatIndex");
  NextFloatExprNumber = INT_INTOBJ(ValGVar(GVAR_SAVED_FLOAT_INDEX));
  return 0;
}


/****************************************************************************
**
*F  PreSave( <module> ) . . . . . . .  clean up before saving
*/
static Int PreSave (
    StructInitInfo *    module )
{
  UInt i;

  /* Can't save in mid-parsing */
  if (STATE(CountExpr) || STATE(CountStat))
    return 1;

  /* push the FP cache index out into a GAP Variable */
  AssGVar(GVAR_SAVED_FLOAT_INDEX, INTOBJ_INT(NextFloatExprNumber));

  /* clean any old data out of the statement and expression stacks */
  for (i = 0; i < SIZE_BAG(STATE(StackStat))/sizeof(UInt); i++)
    ADDR_OBJ(STATE(StackStat))[i] = (Obj)0;
  for (i = 0; i < SIZE_BAG(STATE(StackExpr))/sizeof(UInt); i++)
    ADDR_OBJ(STATE(StackExpr))[i] = (Obj)0;
  /* return success                                                      */
  return 0;
}

static void InitModuleState(ModuleStateOffset offset)
{
    STATE(OffsBodyCount) = 0;
    STATE(LoopNesting) = 0;
    STATE(LoopStackCount) = 0;
    STATE(StackStat) = NewBag( T_BODY, 64*sizeof(Stat) );
    STATE(StackExpr) = NewBag( T_BODY, 64*sizeof(Expr) );

#ifdef HPCGAP
    STATE(OffsBodyStack) = AllocateMemoryBlock(MAX_FUNC_EXPR_NESTING*sizeof(Stat));
    STATE(LoopStack) = AllocateMemoryBlock(MAX_FUNC_EXPR_NESTING*sizeof(UInt));
#else
    static Stat MainOffsBodyStack[MAX_FUNC_EXPR_NESTING];
    static UInt MainLoopStack[MAX_FUNC_EXPR_NESTING];
    STATE(OffsBodyStack) = MainOffsBodyStack;
    STATE(LoopStack) = MainLoopStack;
#endif
}

/****************************************************************************
**
*F  InitInfoCode()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "code",                             /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                        /* checkInit                      */
    PreSave,                            /* preSave                        */
    0,                                  /* postSave                       */
    PostRestore                        /* postRestore                    */
};

StructInitInfo * InitInfoCode ( void )
{
    RegisterModuleState(0, InitModuleState, 0);
    return &module;
}
