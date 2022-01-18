/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the coder package.
**
**  The  coder package  is   the part of   the interpreter  that creates  the
**  expressions.  Its functions are called from the reader.
*/

#include "code.h"

#include "bool.h"
#include "calls.h"
#include "funcs.h"
#include "gap.h"
#include "gapstate.h"
#include "gvars.h"
#include "hookintrprtr.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "records.h"
#include "saveload.h"
#include "stringobj.h"
#include "sysstr.h"
#include "vars.h"

#include "hpc/thread.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#endif


/*N 1996/06/16 mschoene func expressions should be different from funcs    */

GAP_STATIC_ASSERT(sizeof(StatHeader) == 8, "StatHeader has wrong size");


/****************************************************************************
**
*V  PtrBody . . . . . . . . . . . . . . . . . . . . . pointer to current body
**
**  'PtrBody' is a pointer to the current body.
*/
/* TL: Stat * PtrBody; */

struct CodeState {

/****************************************************************************
**
*V  OffsBody  . . . . . . . . . . . . . . . . . . . .  offset in current body
**
**  'OffsBody' is the  offset in the current   body.  It is  only valid while
**  coding.
*/
Stat OffsBody;

Stat * OffsBodyStack;
UInt OffsBodyCount;

/****************************************************************************
**
*V  CodeResult  . . . . . . . . . . . . . . . . . . . . . .  result of coding
**
**  'CodeResult'  is the result  of the coding, i.e.,   the function that was
**  coded.
*/
Obj CodeResult;

Bag StackStat;
Int CountStat;

Bag StackExpr;
Int CountExpr;

Bag CodeLVars;

};

static ModuleStateOffset CodeStateOffset = -1;

extern inline struct CodeState * CodeState(void)
{
    return (struct CodeState *)StateSlotsAtOffset(CodeStateOffset);
}

#define CS(x) (CodeState()->x)


/****************************************************************************
**
*F  NewFunctionBody() . . . . . . . . . . . . . .  create a new function body
*/
Obj NewFunctionBody(void)
{
    return NewBag(T_BODY, sizeof(BodyHeader));
}

/****************************************************************************
**
*F  ADDR_EXPR(<expr>) . . . . . . . . . . . absolute address of an expression
**
**  'ADDR_EXPR' returns  the absolute  address  of  the memory  block of  the
**  expression <expr>.
**
**  Note  that  it is *fatal*  to apply  'ADDR_EXPR'   to expressions of type
**  'EXPR_REF_LVAR' or 'EXPR_INT'.
*/
static Expr * ADDR_EXPR(Expr expr)
{
    return (Expr *)STATE(PtrBody) + expr / sizeof(Expr);
}

/****************************************************************************
**
*F  ADDR_STAT(<stat>) . . . . . . . . . . . . absolute address of a statement
**
**  'ADDR_STAT' returns   the  absolute address of the    memory block of the
**  statement <stat>.
*/
static Stat * ADDR_STAT(Stat stat)
{
    return (Stat *)STATE(PtrBody) + stat / sizeof(Stat);
}

void WRITE_EXPR(Expr expr, UInt idx, UInt val)
{
    GAP_ASSERT(expr / sizeof(Expr) + idx <
               SIZE_BAG(BODY_FUNC(CURR_FUNC())) / sizeof(Expr));

    ADDR_EXPR(expr)[idx] = val;
}

static void WRITE_STAT(Stat stat, UInt idx, UInt val)
{
    GAP_ASSERT(stat / sizeof(Stat) + idx <
               SIZE_BAG(BODY_FUNC(CURR_FUNC())) / sizeof(Stat));

    ADDR_STAT(stat)[idx] = val;
}

static StatHeader * STAT_HEADER(Stat stat)
{
    return (StatHeader *)ADDR_STAT(stat) - 1;
}

void SET_VISITED_STAT(Stat stat)
{
    STAT_HEADER(stat)->visited = 1;
}


#define SET_FUNC_CALL(call,x)   WRITE_EXPR(call, 0, x)
#define SET_ARGI_CALL(call,i,x) WRITE_EXPR(call, i, x)
#define SET_ARGI_INFO(info,i,x) WRITE_STAT(info, (i) - 1, x)


static inline void PushOffsBody( void ) {
    GAP_ASSERT(CS(OffsBodyCount) < MAX_FUNC_EXPR_NESTING);
    CS(OffsBodyStack)[CS(OffsBodyCount)++] = CS(OffsBody);
}

static inline void PopOffsBody( void ) {
    GAP_ASSERT(CS(OffsBodyCount));
    CS(OffsBody) = CS(OffsBodyStack)[--CS(OffsBodyCount)];
}

// filename

Obj GET_FILENAME_BODY(Obj body)
{
    Obj val = BODY_HEADER(body)->filename_or_id;
    if (IS_INTOBJ(val)) {
        UInt gapnameid = INT_INTOBJ(val);
        val = GetCachedFilename(gapnameid);
    }

    return val;
}

void SET_FILENAME_BODY(Obj body, Obj val)
{
    GAP_ASSERT(IS_STRING_REP(val));
    MakeImmutable(val);
    BODY_HEADER(body)->filename_or_id = val;
}

// gapnameid

UInt GET_GAPNAMEID_BODY(Obj body)
{
    Obj gapnameid = BODY_HEADER(body)->filename_or_id;
    return IS_POS_INTOBJ(gapnameid) ? INT_INTOBJ(gapnameid) : 0;
}

void SET_GAPNAMEID_BODY(Obj body, UInt val)
{
    BODY_HEADER(body)->filename_or_id = INTOBJ_INT(val);
}

// location

Obj GET_LOCATION_BODY(Obj body)
{
    Obj location = BODY_HEADER(body)->startline_or_location;
    return (location && IS_STRING_REP(location)) ? location : 0;
}

void SET_LOCATION_BODY(Obj body, Obj val)
{
    GAP_ASSERT(IS_STRING_REP(val));
    MakeImmutable(val);
    BODY_HEADER(body)->startline_or_location = val;
}

// startline

UInt GET_STARTLINE_BODY(Obj body)
{
    Obj line = BODY_HEADER(body)->startline_or_location;
    return IS_POS_INTOBJ(line) ? INT_INTOBJ(line) : 0;
}

void SET_STARTLINE_BODY(Obj body, UInt val)
{
    BODY_HEADER(body)->startline_or_location = val ? INTOBJ_INT(val) : 0;
}

// endline

UInt GET_ENDLINE_BODY(Obj body)
{
    Obj line = BODY_HEADER(body)->endline;
    return IS_POS_INTOBJ(line) ? INT_INTOBJ(line) : 0;
}

void SET_ENDLINE_BODY(Obj body, UInt val)
{
    BODY_HEADER(body)->endline = val ? INTOBJ_INT(val) : 0;
}

Obj GET_VALUE_FROM_CURRENT_BODY(Int ix)
{
    Obj values = ((BodyHeader *)STATE(PtrBody))->values;
    return ELM_PLIST(values, ix);
}

Stat NewStatOrExpr (
    UInt                type,
    UInt                size,
    UInt                line)
{
    Stat                stat;           /* result                          */

    /* this is where the new statement goes                                */
    stat = CS(OffsBody) + sizeof(StatHeader);

    /* increase the offset                                                 */
    CS(OffsBody) = stat + ((size+sizeof(Stat)-1) / sizeof(Stat)) * sizeof(Stat);

    /* make certain that the current body bag is large enough              */
    Obj body = BODY_FUNC(CURR_FUNC());
    UInt bodySize = SIZE_BAG(body);
    if (bodySize == 0)
        bodySize = CS(OffsBody);
    while (bodySize < CS(OffsBody))
        bodySize *= 2;
    GAP_ASSERT(STATE(PtrBody) == PTR_BAG(body));
    ResizeBag(body, bodySize);
    // resize a bag can change its address, even without a GC taking place;
    // so we must update PtrBody here
    STATE(PtrBody) = PTR_BAG(body);

    /* enter type and size                                                 */
    STAT_HEADER(stat)->line = line;
    STAT_HEADER(stat)->size = size;
    STAT_HEADER(stat)->type = type;
    RegisterStatWithHook(stat);
    /* return the new statement                                            */
    return stat;
}

static Stat NewStat(UInt type, UInt size)
{
    return NewStatOrExpr(type, size, GetInputLineNumber(GetCurrentInput()));
}


/****************************************************************************
**
*F  NewExpr( <type>, <size> ) . . . . . . . . . . . allocate a new expression
**
**  'NewExpr' allocates a new expression memory block of  the type <type> and
**  <size> bytes.  'NewExpr' returns the identifier of the new expression.
*/
static Expr NewExpr(UInt type, UInt size)
{
    return NewStat(type, size);
}


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
static inline UInt CapacityStatStack(void)
{
    return SIZE_BAG(CS(StackStat)) / sizeof(Stat) - 1;
}

void PushStat (
    Stat                stat )
{
    /* there must be a stack, it must not be underfull or overfull         */
    GAP_ASSERT(CS(StackStat) != 0);
    GAP_ASSERT(0 <= CS(CountStat));
    GAP_ASSERT(CS(CountStat) <= CapacityStatStack());
    GAP_ASSERT( stat != 0 );

    // count up and put the statement onto the stack
    if (CS(CountStat) == CapacityStatStack()) {
        ResizeBag(CS(StackStat), (2 * CS(CountStat) + 1) * sizeof(Stat));
    }

    // put
    Stat * data = (Stat *)PTR_BAG(CS(StackStat)) + 1;
    data[CS(CountStat)] = stat;
    CS(CountStat)++;
}

static Stat PopStat ( void )
{
    Stat                stat;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    GAP_ASSERT(CS(StackStat) != 0);
    GAP_ASSERT(1 <= CS(CountStat));
    GAP_ASSERT(CS(CountStat) <= CapacityStatStack());

    /* get the top statement from the stack, and count down                */
    CS(CountStat)--;
    Stat * data = (Stat *)PTR_BAG(CS(StackStat)) + 1;
    stat = data[CS(CountStat)];

    /* return the popped statement                                         */
    return stat;
}

static Stat PopSeqStat (
    UInt                nr )
{
    Stat                body;           /* sequence, result                */
    Stat                stat;           /* single statement                */
    UInt                i;              /* loop variable                   */

    if (nr == 0 ) {
      body = NewStat(STAT_EMPTY, 0);
    }
    /* special case for a single statement                                 */
    else if ( nr == 1 ) {
        body = PopStat();
    }

    /* general case                                                        */
    else {

        /* allocate the sequence                                           */
        if ( 2 <= nr && nr <= 7 ) {
            body = NewStat( STAT_SEQ_STAT+(nr-1), nr * sizeof(Stat) );
        }
        else {
            body = NewStat( STAT_SEQ_STAT,        nr * sizeof(Stat) );
        }

        /* enter the statements into the sequence                          */
        for ( i = nr; 1 <= i; i-- ) {
            stat = PopStat();
            WRITE_STAT(body, i - 1, stat);
        }
    }

    /* return the sequence                                                 */
    return body;
}

static inline Stat PopLoopStat(UInt baseType, UInt extra, UInt nr)
{
    // fix up the case of no statements
    if (0 == nr) {
        PushStat(NewStat(STAT_EMPTY, 0));
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
        WRITE_STAT(stat, i + extra - 1, stat1);
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
static inline UInt CapacityStackExpr(void)
{
    return SIZE_BAG(CS(StackExpr)) / sizeof(Expr) - 1;
}

static void PushExpr(Expr expr)
{
    /* there must be a stack, it must not be underfull or overfull         */
    GAP_ASSERT(CS(StackExpr) != 0);
    GAP_ASSERT(0 <= CS(CountExpr));
    GAP_ASSERT(CS(CountExpr) <= CapacityStackExpr());
    GAP_ASSERT( expr != 0 );

    /* count up and put the expression onto the stack                      */
    if (CS(CountExpr) == CapacityStackExpr()) {
        ResizeBag(CS(StackExpr), (2 * CS(CountExpr) + 1) * sizeof(Expr));
    }

    Expr * data = (Expr *)PTR_BAG(CS(StackExpr)) + 1;
    data[CS(CountExpr)] = expr;
    CS(CountExpr)++;
}

static Expr PopExpr(void)
{
    Expr                expr;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    GAP_ASSERT(CS(StackExpr) != 0);
    GAP_ASSERT(1 <= CS(CountExpr));
    GAP_ASSERT(CS(CountExpr) <= CapacityStackExpr());

    /* get the top expression from the stack, and count down               */
    CS(CountExpr)--;
    Expr * data = (Expr *)PTR_BAG(CS(StackExpr)) + 1;
    expr = data[CS(CountExpr)];

    /* return the popped expression                                        */
    return expr;
}


/****************************************************************************
**
*F  PushUnaryOp( <type> ) . . . . . . . . . . . . . . . . push unary operator
**
**  'PushUnaryOp' pushes a   unary  operator expression onto the   expression
**  stack.  <type> is the type of the operator (currently only 'EXPR_NOT').
*/
static void PushUnaryOp(UInt type)
{
    Expr                unop;           /* unary operator, result          */
    Expr                op;             /* operand                         */

    /* allocate the unary operator                                         */
    unop = NewExpr( type, sizeof(Expr) );

    /* enter the operand                                                   */
    op = PopExpr();
    WRITE_EXPR(unop, 0, op);

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
static void PushBinaryOp(UInt type)
{
    Expr                binop;          /* binary operator, result         */
    Expr                opL;            /* left operand                    */
    Expr                opR;            /* right operand                   */

    /* allocate the binary operator                                        */
    binop = NewExpr( type, 2*sizeof(Expr) );

    /* enter the right operand                                             */
    opR = PopExpr();
    WRITE_EXPR(binop, 1, opR);

    /* enter the left operand                                              */
    opL = PopExpr();
    WRITE_EXPR(binop, 0, opL);

    /* push the binary operator                                            */
    PushExpr( binop );
}


Int AddValueToBody(Obj val)
{
    BodyHeader * header = (BodyHeader *)STATE(PtrBody);
    Obj values = header->values;
    if (!values) {
        values = NEW_PLIST(T_PLIST, 4);
        // Recalculate header in case NEW_PLIST caused a GC
        header = (BodyHeader *)STATE(PtrBody);
        header->values = values;
        GAP_ASSERT(STATE(PtrBody) == PTR_BAG(BODY_FUNC(CURR_FUNC())));
        // This is the bag PtrBody points at
        CHANGED_BAG(BODY_FUNC(CURR_FUNC()));
    }
    return PushPlist(values, val);
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
**  The net effect of all of these is to leave a record expression on the
**  stack containing the options record. It will be picked up by
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
      PushExpr( NewExpr( EXPR_TRUE, 0 ) );
}

void            CodeFuncCallOptionsEnd ( UInt nr )
{
    Expr                record;         /* record, result                  */
    Expr                entry;          /* entry                           */
    Expr                rnam;           /* position of an entry            */
    UInt                i;              /* loop variable                   */

    /* allocate the record expression                                      */
    record = NewExpr( EXPR_REC,      nr * 2 * sizeof(Expr) );
    

    /* enter the entries                                                   */
    for ( i = nr; 1 <= i; i-- ) {
        entry = PopExpr();
        rnam  = PopExpr();
        WRITE_EXPR(record, 2 * (i - 1), rnam);
        WRITE_EXPR(record, 2 * (i - 1) + 1, entry);
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
**  ...only function expressions in between...
*/

void CodeBegin ( void )
{
    /* the stacks must be empty                                            */
    GAP_ASSERT(CS(CountStat) == 0);
    GAP_ASSERT(CS(CountExpr) == 0);

    /* remember the current frame                                          */
    CS(CodeLVars) = STATE(CurrLVars);

    /* clear the code result bag                                           */
    CS(CodeResult) = 0;
}

Obj CodeEnd(UInt error)
{
    /* if everything went fine                                             */
    if ( ! error ) {

        /* the stacks must be empty                                        */
        GAP_ASSERT(CS(CountStat) == 0);
        GAP_ASSERT(CS(CountExpr) == 0);
        GAP_ASSERT(CS(OffsBodyCount) == 0);

        // we must be back to 'STATE(CurrLVars)'
        GAP_ASSERT(STATE(CurrLVars) == CS(CodeLVars));

        // 'CodeFuncExprEnd' left the function already in 'CS(CodeResult)'
        return CS(CodeResult);
    }

    /* otherwise clean up the mess                                         */
    else {

        /* empty the stacks                                                */
        CS(CountStat) = 0;
        CS(CountExpr) = 0;
        CS(OffsBodyCount) = 0;

        /* go back to the correct frame                                    */
        SWITCH_TO_OLD_LVARS(CS(CodeLVars));

        return 0;
    }
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
        call = NewExpr( EXPR_FUNCCALL_0ARGS+nr, SIZE_NARG_CALL(nr) );
    }
    else if ( funccall /* && 6 < nr */ ) {
        call = NewExpr( EXPR_FUNCCALL_XARGS,    SIZE_NARG_CALL(nr) );
    }
    else if ( /* ! funccall && */ nr <=6 ) {
        call = NewExpr( STAT_PROCCALL_0ARGS+nr, SIZE_NARG_CALL(nr) );
    }
    else /* if ( ! funccall && 6 < nr ) */ {
        call = NewExpr( STAT_PROCCALL_XARGS,    SIZE_NARG_CALL(nr) );
    }

    /* get the options record if any */
    if (options)
      opts = PopExpr();
    
    /* enter the argument expressions                                      */
    for ( i = nr; 1 <= i; i-- ) {
        arg = PopExpr();
        SET_ARGI_CALL(call, i, arg);
    }

    /* enter the function expression                                       */
    func = PopExpr();
    SET_FUNC_CALL(call, func);

    /* wrap up the call with the options */
    if (options)
      {
        wrapper = NewExpr( funccall ? EXPR_FUNCCALL_OPTS : STAT_PROCCALL_OPTS, 
                           2*sizeof(Expr));
        WRITE_EXPR(wrapper, 0, opts);
        WRITE_EXPR(wrapper, 1, call);
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
*F  CodeFuncExprEnd( <nr> ) . . . . . . . . . . code function expression, end
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
    Bag                 body;           /* function body                   */
    Stat                stat1;          /* first statement in body         */

    /* remember the current offset                                         */
    PushOffsBody();

    /* create a function expression                                        */
    fexp = NewBag( T_FUNCTION, sizeof(FuncBag) );
    SET_NARG_FUNC( fexp, narg );
    SET_NLOC_FUNC( fexp, nloc );
    SET_NAMS_FUNC( fexp, nams );
#ifdef HPCGAP
    if (nams) MakeBagPublic(nams);
#endif
    CHANGED_BAG( fexp );

    /* give it a body                                                      */
    body = NewBag( T_BODY, 1024*sizeof(Stat) );
    SET_BODY_FUNC( fexp, body );
    CHANGED_BAG( fexp );

    /* record where we are reading from */
    SET_GAPNAMEID_BODY(body, GetInputFilenameID(GetCurrentInput()));
    SET_STARTLINE_BODY(body, startLine);
    CS(OffsBody) = sizeof(BodyHeader);

    /* give it an environment                                              */
    SET_ENVI_FUNC( fexp, STATE(CurrLVars) );
    CHANGED_BAG( fexp );
    MakeHighVars(STATE(CurrLVars));

    /* switch to this function                                             */
    SWITCH_TO_NEW_LVARS(fexp, (narg > 0 ? narg : -narg), nloc);

    /* allocate the top level statement sequence                           */
    stat1 = NewStat( STAT_SEQ_STAT, 8*sizeof(Stat) );
    assert( stat1 == OFFSET_FIRST_STAT );
}

Expr CodeFuncExprEnd(UInt nr, UInt pushExpr)
{
    Expr                expr;           /* function expression, result     */
    Stat                stat1;          /* single statement of body        */
    Obj                 fexp;           /* function expression bag         */
    UInt                len;            /* length of func. expr. list      */
    UInt                i;              /* loop variable                   */

    /* get the function expression                                         */
    fexp = CURR_FUNC();
    
    /* get the body of the function                                        */
    /* push an additional return-void-statement if necessary              */
    /* the function interpreters depend on each function ``returning''     */
    if ( nr == 0 ) {
        CodeReturnVoid();
        nr++;
    }
    else {
        stat1 = PopStat();
        PushStat(stat1);
        //  If we code a function where the body is already packed into nested
        //  sequence statements, e.g., from reading in a syntax tree, we need
        //  to find the last `real` statement of the last innermost sequence
        //  statement to determine if there is already a return or not.
        while (STAT_SEQ_STAT <= TNUM_STAT(stat1) &&
               TNUM_STAT(stat1) <= STAT_SEQ_STAT7) {
            UInt size = SIZE_STAT(stat1) / sizeof(Stat);
            stat1 = READ_STAT(stat1, size - 1);
        }
        if (TNUM_STAT(stat1) != STAT_RETURN_VOID &&
            TNUM_STAT(stat1) != STAT_RETURN_OBJ) {
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
    STAT_HEADER(OFFSET_FIRST_STAT)->line = LINE_STAT(OFFSET_FIRST_STAT);
    STAT_HEADER(OFFSET_FIRST_STAT)->size = nr*sizeof(Stat);
    STAT_HEADER(OFFSET_FIRST_STAT)->type = STAT_SEQ_STAT+nr-1;
    for ( i = 1; i <= nr; i++ ) {
        stat1 = PopStat();
        WRITE_STAT(OFFSET_FIRST_STAT, nr - i, stat1);
    }

    // make the body values list (if any) immutable
    Obj values = ((BodyHeader *)STATE(PtrBody))->values;
    if (values)
        MakeImmutable(values);

    /* make the body smaller                                               */
    ResizeBag(BODY_FUNC(fexp), CS(OffsBody));
    SET_ENDLINE_BODY(BODY_FUNC(fexp), GetInputLineNumber(GetCurrentInput()));

    /* switch back to the previous function                                */
    SWITCH_TO_OLD_LVARS( ENVI_FUNC(fexp) );

    /* restore the remembered offset                                       */
    PopOffsBody();

    /* if this was inside another function definition, make the expression */
    /* and store it in the function expression list of the outer function  */
    if (STATE(CurrLVars) != CS(CodeLVars)) {
        len = AddValueToBody(fexp);
        expr = NewExpr( EXPR_FUNC, sizeof(Expr) );
        WRITE_EXPR(expr, 0, len);
        if (pushExpr) {
            PushExpr(expr);
        }
        return expr;
    }

    // otherwise, make the function and store it in 'CS(CodeResult)'
    else {
        CS(CodeResult) = MakeFunction(fexp);
    }

    return 0;
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

Int CodeIfBeginBody ( void )
{
    // get and check the condition
    Expr cond = PopExpr();

    // if the condition is 'false', ignore the body
    if (TNUM_EXPR(cond) == EXPR_FALSE) {
        return 1; // signal interpreter to set IntrIgnoring to 1
    }
    else {
        // put the condition expression back on the stack
        PushExpr(cond);
        return 0;
    }
}

Int CodeIfEndBody (
    UInt                nr )
{
    /* collect the statements in a statement sequence if necessary         */
    PushStat( PopSeqStat( nr ) );

    // get and check the condition
    Expr cond = PopExpr();
    PushExpr(cond);

    // if the condition is 'true', signal interpreter to set IntrIgnoring to
    // 1, so that other branches of the if-statement are ignored
    return TNUM_EXPR(cond) == EXPR_TRUE;
}

void CodeIfEnd (
    UInt                nr )
{
    Stat                stat;           /* if-statement, result            */
    Expr                cond;           /* condition of a branch           */
    UInt                hase;           /* has else branch                 */
    UInt                i;              /* loop variable                   */

    // if all conditions were false, the if-statement is an empty statement
    if (nr == 0) {
        PushStat(NewStat(STAT_EMPTY, 0));
        return;
    }

    // peek at the last condition
    cond = PopExpr();
    hase = (TNUM_EXPR(cond) == EXPR_TRUE);
    PushExpr(cond);

    // optimize 'if true then BODY; fi;' to just 'BODY;'
    if (nr == 1 && hase) {
        // drop the condition expression, leave the body statement
        PopExpr();
        return;
    }

    /* allocate the if-statement                                           */
    if      ( nr == 1 ) {
        stat = NewStat( STAT_IF,            nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else if ( nr == 2 && hase ) {
        stat = NewStat( STAT_IF_ELSE,       nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else if ( ! hase ) {
        stat = NewStat( STAT_IF_ELIF,       nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else {
        stat = NewStat( STAT_IF_ELIF_ELSE,  nr * (sizeof(Expr)+sizeof(Stat)) );
    }

    /* enter the branches                                                  */
    for ( i = nr; 1 <= i; i-- ) {
        Stat body = PopStat();
        cond = PopExpr();
        WRITE_STAT(stat, 2 * (i - 1), cond);
        WRITE_STAT(stat, 2 * (i - 1) + 1, body);
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
}

void CodeForBeginBody ( void )
{
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

    /* select the type of the for-statement                                */
    if ( TNUM_EXPR(list) == EXPR_RANGE && SIZE_EXPR(list) == 2*sizeof(Expr)
      && IS_REF_LVAR(var) ) {
        type = STAT_FOR_RANGE;
    }
    else {
        type = STAT_FOR;
    }

    /* allocate the for-statement                                          */
    stat = PopLoopStat(type, 2, nr);

    /* enter the list expression                                           */
    WRITE_STAT(stat, 1, list);

    /* enter the variable reference                                        */
    WRITE_STAT(stat, 0, var);

    /* push the for-statement                                              */
    PushStat( stat );
}

void CodeForEnd ( void )
{
}


/****************************************************************************
**
*F  CodeAtomicBegin() . . . . . . . code atomic-statement, begin of statement
*F  CodeAtomicBeginBody() . . . . . . .  code atomic-statement, begin of body
*F  CodeAtomicEndBody( <nr> ) . . . . . .  code atomic-statement, end of body
*F  CodeAtomicEnd() . . . . . . . . . code atomic-statement, end of statement
**
**  'CodeAtomicBegin' is an action to code an atomic-statement. It is called
**  when the reader encounters the 'atomic', i.e., *before* the condition is
**  read.
**
**  'CodeAtomicBeginBody' is an action  to code an atomic-statement. It is
**  called when the reader encounters the beginning of the statement body,
**  i.e., *after* the condition is read.
**
**  'CodeAtomicEndBody' is an action to code an atomic-statement. It is called
**  when the reader encounters the end of the statement body. <nr> is the
**  number of statements in the body.
**
**  'CodeAtomicEnd' is an action to code an atomic-statement. It is called
**  when the reader encounters the end of the statement, i.e., immediate
**  after 'CodeAtomicEndBody'.
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
#ifdef HPCGAP
    Stat                stat;           /* atomic-statement, result        */
    Stat                stat1;          /* single statement of body        */
    UInt                i;              /* loop variable                   */
    UInt nrexprs;
    Expr  e,qual;

    /* collect the statements into a statement sequence   */
    stat1 = PopSeqStat( nrstats );

    nrexprs = INT_INTEXPR(PopExpr());
    
    /* allocate the atomic-statement                                       */
    stat = NewStat( STAT_ATOMIC, sizeof(Stat) + nrexprs*2*sizeof(Stat) );
    
    /* enter the statement sequence */
    WRITE_STAT(stat, 0, stat1);

    /* enter the expressions                                               */
    for ( i = 2*nrexprs; 1 <= i; i -= 2 ) {
        e = PopExpr();
        qual = PopExpr();
        WRITE_STAT(stat, i, e);
        WRITE_STAT(stat, i - 1, qual);
    }

    /* push the atomic-statement                                           */
    PushStat( stat );
#else
    Stat stat  = PopSeqStat( nrstats );
    UInt nrexprs = INT_INTEXPR(PopExpr());
    while (nrexprs--) {
        PopExpr();
        PopExpr();
    }
    PushStat( stat );
#endif
}

void CodeAtomicEnd ( void )
{
}

/****************************************************************************
**
*F  CodeQualifiedExprBegin(<qual>) . code readonly/readwrite expression start
*F  CodeQualifiedExprEnd() . . . . . . code readonly/readwrite expression end
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
}

void CodeWhileEndBody (
    UInt                nr )
{
    Stat                stat;           /* while-statement, result         */
    Expr                cond;           /* condition                       */

    /* allocate the while-statement                                        */
    stat = PopLoopStat(STAT_WHILE, 1, nr);

    /* enter the condition                                                 */
    cond = PopExpr();
    WRITE_STAT(stat, 0, cond);

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
}

void CodeRepeatEndBody (
    UInt                nr )
{
    /* leave the number of statements in the body on the expression stack  */
    PushExpr( INTEXPR_INT(nr) );
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
    stat = PopLoopStat(STAT_REPEAT, 1, nr);

    /* enter the condition                                                 */
    WRITE_STAT(stat, 0, cond);

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

    /* allocate the break-statement                                        */
    stat = NewStat( STAT_BREAK, 0 * sizeof(Expr) );

    /* push the break-statement                                            */
    PushStat( stat );
}

/****************************************************************************
**
*F  CodeContinue() . . . . . . . . . . . . . . . . .  code continue-statement
**
**  'CodeContinue' is the action to code a continue-statement. It is called
**  when the reader encounters a 'continue;'.
*/
void            CodeContinue ( void )
{
    Stat                stat;           /* continue-statement, result      */

    /* allocate the continue-statement                                     */
    stat = NewStat( STAT_CONTINUE, 0 * sizeof(Expr) );

    /* push the continue-statement                                         */
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
    stat = NewStat( STAT_RETURN_OBJ, sizeof(Expr) );

    /* enter the expression                                                */
    expr = PopExpr();
    WRITE_STAT(stat, 0, expr);

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
    stat = NewStat( STAT_RETURN_VOID, 0 * sizeof(Expr) );

    /* push the return-statement                                           */
    PushStat( stat );
}

void CodeReturnVoidWhichIsNotProfiled ( void )
{
    Stat                stat;           /* return-statement, result        */

    /* allocate the return-statement, without profile information          */

    stat = NewStatOrExpr( STAT_RETURN_VOID, 0 * sizeof(Expr), 0 );

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
    PushBinaryOp( EXPR_OR );
}

void CodeAndL ( void )
{
}

void CodeAnd ( void )
{
    PushBinaryOp( EXPR_AND );
}

void CodeNot ( void )
{
    // peek at expression
    Expr expr = PopExpr();
    if ( TNUM_EXPR(expr) == EXPR_TRUE ) {
        CodeFalseExpr();
    }
    else if ( TNUM_EXPR(expr) == EXPR_FALSE ) {
        CodeTrueExpr();
    }
    else {
        PushExpr( expr );
        PushUnaryOp( EXPR_NOT );
    }
}

void CodeEq ( void )
{
    PushBinaryOp( EXPR_EQ );
}

void CodeNe ( void )
{
    PushBinaryOp( EXPR_NE );
}

void CodeLt ( void )
{
    PushBinaryOp( EXPR_LT );
}

void CodeGe ( void )
{
    PushBinaryOp( EXPR_GE );
}

void CodeGt ( void )
{
    PushBinaryOp( EXPR_GT );
}

void CodeLe ( void )
{
    PushBinaryOp( EXPR_LE );
}

void CodeIn ( void )
{
    PushBinaryOp( EXPR_IN );
}

void CodeSum ( void )
{
    PushBinaryOp( EXPR_SUM );
}

void CodeAInv ( void )
{
    Expr                expr;
    Int                 i;

    expr = PopExpr();
    if ( IS_INTEXPR(expr) && INT_INTEXPR(expr) != INT_INTOBJ_MIN ) {
        i = INT_INTEXPR(expr);
        PushExpr( INTEXPR_INT( -i ) );
    }
    else {
        PushExpr( expr );
        PushUnaryOp( EXPR_AINV );
    }
}

void CodeDiff ( void )
{
    PushBinaryOp( EXPR_DIFF );
}

void CodeProd ( void )
{
    PushBinaryOp( EXPR_PROD );
}

void CodeQuo ( void )
{
    PushBinaryOp( EXPR_QUO );
}

void CodeMod ( void )
{
    PushBinaryOp( EXPR_MOD );
}

void CodePow ( void )
{
    PushBinaryOp( EXPR_POW );
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
        expr = NewExpr( EXPR_INTPOS, sizeof(UInt) );
        Int ix = AddValueToBody(val);
        WRITE_EXPR(expr, 0, ix);
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
    PushExpr( NewExpr( EXPR_TILDE, 0 ) );
}

/****************************************************************************
**
*F  CodeTrueExpr()  . . . . . . . . . . . . . .  code literal true expression
**
**  'CodeTrueExpr' is the action to code a literal true expression.
*/
void CodeTrueExpr ( void )
{
    PushExpr( NewExpr( EXPR_TRUE, 0 ) );
}


/****************************************************************************
**
*F  CodeFalseExpr() . . . . . . . . . . . . . . code literal false expression
**
**  'CodeFalseExpr' is the action to code a literal false expression.
*/
void CodeFalseExpr ( void )
{
    PushExpr( NewExpr( EXPR_FALSE, 0 ) );
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
    litr = NewExpr( EXPR_CHAR, sizeof(UChar) );
    WRITE_EXPR(litr, 0, chr);

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
    cycle = NewExpr( EXPR_PERM_CYCLE, nrx * sizeof(Expr) );

    /* enter the entries                                                   */
    for ( j = nrx; 1 <= j; j-- ) {
        entry = PopExpr();
        WRITE_EXPR(cycle, j - 1, entry);
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
    perm = NewExpr( EXPR_PERM, nrc * sizeof(Expr) );

    /* enter the cycles                                                    */
    for ( i = nrc; 1 <= i; i-- ) {
        cycle = PopExpr();
        WRITE_EXPR(perm, i - 1, cycle);
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
        list = NewExpr( EXPR_LIST,      INT_INTEXPR(pos) * sizeof(Expr) );
    }
    else if ( ! range && (top && tilde) ) {
        list = NewExpr( EXPR_LIST_TILDE, INT_INTEXPR(pos) * sizeof(Expr) );
    }
    else /* if ( range && ! (top && tilde) ) */ {
        list = NewExpr( EXPR_RANGE,     INT_INTEXPR(pos) * sizeof(Expr) );
    }

    /* enter the entries                                                   */
    for ( i = nr; 1 <= i; i-- ) {
        entry = PopExpr();
        pos   = PopExpr();
        WRITE_EXPR(list, INT_INTEXPR(pos) - 1, entry);
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
    GAP_ASSERT(IS_STRING_REP(str));

    Expr string = NewExpr( EXPR_STRING, sizeof(UInt) );
    Int ix = AddValueToBody(str);
    WRITE_EXPR(string, 0, ix);
    PushExpr( string );
}


/****************************************************************************
**
*F  CodePragma(<pragma>)
*/
void CodePragma(Obj pragma)
{
    GAP_ASSERT(IS_STRING_REP(pragma));

    Expr pragmaexpr = NewStat(STAT_PRAGMA, sizeof(UInt));
    Int  ix = AddValueToBody(pragma);
    WRITE_EXPR(pragmaexpr, 0, ix);
    PushStat(pragmaexpr);
}


/****************************************************************************
**
*F  CodeFloatExpr( <str> ) . . . . . . . .  code literal float expression
*/
enum {
    FLOAT_0_INDEX = 1,    // reserved for constant 0.0
    FLOAT_1_INDEX = 2,    // reserved for constant 1.0

    // the maximal index must be less than INT_INTOBJ_MAX and INT_MAX, so
    // simply hardcode it to 1<<28
    MAX_FLOAT_INDEX = (1<<28) - 2,
};
static UInt NextFloatExprNumber = 3;

static Obj CONVERT_FLOAT_LITERAL_EAGER;


static UInt getNextFloatExprNumber(void)
{
    UInt next;
    HashLock(&NextFloatExprNumber);
    assert(NextFloatExprNumber < MAX_FLOAT_INDEX);
    next = NextFloatExprNumber++;
    HashUnlock(&NextFloatExprNumber);
    return next;
}

static UInt CheckForCommonFloat(const Char * str)
{
    /* skip leading zeros */
    while (*str == '0')
        str++;
    /* might be zero literal */
    if (*str == '.') {
        /* skip point */
        str++;
        /* skip more zeroes */
        while (*str == '0')
            str++;
        /* if we've got to end of string we've got zero. */
        if (!IsDigit(*str))
            return FLOAT_0_INDEX;
    }
    if (*str++ != '1')
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

Expr CodeLazyFloatExpr(Obj str, UInt pushExpr)
{
    UInt ix;

    /* Lazy case, store the string for conversion at run time */
    Expr fl = NewExpr(EXPR_FLOAT_LAZY, 2 * sizeof(UInt));

    ix = CheckForCommonFloat(CONST_CSTR_STRING(str));
    if (!ix)
        ix = getNextFloatExprNumber();
    WRITE_EXPR(fl, 0, ix);
    WRITE_EXPR(fl, 1, AddValueToBody(str));

    /* push the expression */
    if (pushExpr) {
        PushExpr(fl);
    }
    return fl;
}

static void CodeEagerFloatExpr(Obj str, Char mark)
{
    /* Eager case, do the conversion now */
    Expr fl = NewExpr(EXPR_FLOAT_EAGER, sizeof(UInt) * 3);
    Obj v = CALL_2ARGS(CONVERT_FLOAT_LITERAL_EAGER, str, ObjsChar[(Int)mark]);
    WRITE_EXPR(fl, 0, AddValueToBody(v));
    WRITE_EXPR(fl, 1, AddValueToBody(str));  // store for printing
    WRITE_EXPR(fl, 2, (UInt)mark);
    PushExpr(fl);
}

void CodeFloatExpr(Obj s)
{
    Char * str = CSTR_STRING(s);

    const UInt l = GET_LEN_STRING(s);
    UInt l1 = l;
    Char mark = '\0'; /* initialize to please compilers */
    if (str[l - 1] == '_') {
        l1 = l - 1;
        mark = '\0';
    }
    else if (str[l - 2] == '_') {
        l1 = l - 2;
        mark = str[l - 1];
    }
    if (l1 < l) {
        str[l1] = '\0';
        SET_LEN_STRING(s, l1);
        CodeEagerFloatExpr(s, mark);
    }
    else {
        CodeLazyFloatExpr(s, 1);
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
        record = NewExpr( EXPR_REC,      nr * 2 * sizeof(Expr) );
    }
    else /* if ( (top && tilde) ) */ {
        record = NewExpr( EXPR_REC_TILDE, nr * 2 * sizeof(Expr) );
    }

    /* enter the entries                                                   */
    for ( i = nr; 1 <= i; i-- ) {
        entry = PopExpr();
        rnam  = PopExpr();
        WRITE_EXPR(record, 2 * (i - 1), rnam);
        WRITE_EXPR(record, 2 * (i - 1) + 1, entry);
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
    ass = NewStat( STAT_ASS_LVAR,        2 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(ass, 1, rhsx);

    /* enter the local variable                                            */
    WRITE_STAT(ass, 0, lvar);

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
    ass = NewStat( STAT_UNB_LVAR, sizeof(Stat) );

    /* enter the local variable                                            */
    WRITE_STAT(ass, 0, lvar);

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
**  'REF_LVAR_LVAR').
*/
void CodeRefLVar (
    UInt                lvar )
{
    Expr                ref;            /* reference, result               */

    /* make the reference                                                  */
    ref = REF_LVAR_LVAR(lvar);

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
    ref = NewExpr( EXPR_ISB_LVAR, sizeof(Expr) );

    /* enter the local variable                                            */
    WRITE_EXPR(ref, 0, lvar);

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
    ass = NewStat( STAT_ASS_HVAR, 2 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(ass, 1, rhsx);

    /* enter the higher variable                                           */
    WRITE_STAT(ass, 0, hvar);

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
    ass = NewStat( STAT_UNB_HVAR, sizeof(Stat) );

    /* enter the higher variable                                           */
    WRITE_STAT(ass, 0, hvar);

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
    ref = NewExpr( EXPR_REF_HVAR, sizeof(Expr) );

    /* enter the higher variable                                           */
    WRITE_EXPR(ref, 0, hvar);

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
    ref = NewExpr( EXPR_ISB_HVAR, sizeof(Expr) );

    /* enter the higher variable                                           */
    WRITE_EXPR(ref, 0, hvar);

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
    ass = NewStat( STAT_ASS_GVAR, 2 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(ass, 1, rhsx);

    /* enter the global variable                                           */
    WRITE_STAT(ass, 0, gvar);

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
    ass = NewStat( STAT_UNB_GVAR, sizeof(Stat) );

    /* enter the global variable                                           */
    WRITE_STAT(ass, 0, gvar);

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
    ref = NewExpr( EXPR_REF_GVAR, sizeof(Expr) );

    /* enter the global variable                                           */
    WRITE_EXPR(ref, 0, gvar);

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
    ref = NewExpr( EXPR_ISB_GVAR, sizeof(Expr) );

    /* enter the global variable                                           */
    WRITE_EXPR(ref, 0, gvar);

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
static void CodeAssListUniv(Stat ass, Int narg)
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Expr                rhsx;           /* right hand side expression      */
    Int i;

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(ass, narg + 1, rhsx);

    /* enter the position expression                                       */
    for (i = narg; i > 0; i--) {
      pos = PopExpr();
      WRITE_STAT(ass, i, pos);
    }

    /* enter the list expression                                           */
    list = PopExpr();
    WRITE_STAT(ass, 0, list);

    /* push the assignment                                                 */
    PushStat( ass );
}

void CodeAssList ( Int narg )
{
    Stat                ass;            /* assignment, result              */

    GAP_ASSERT(narg == 1 || narg == 2);

    /* allocate the assignment                                             */
    if (narg == 1)
      ass = NewStat( STAT_ASS_LIST, 3 * sizeof(Stat) );
    else /* if (narg == 2) */
      ass = NewStat( STAT_ASS_MAT, 4 * sizeof(Stat));

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass, narg );
}

void CodeAsssList ( void )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    ass = NewStat( STAT_ASSS_LIST, 3 * sizeof(Stat) );

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass, 1 );
}

void CodeAssListLevel ( Int narg,
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( STAT_ASS_LIST_LEV, (narg + 3) * sizeof(Stat) );
    WRITE_STAT(ass, narg + 2, level);

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass, narg );
}

void CodeAsssListLevel (
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( STAT_ASSS_LIST_LEV, 4 * sizeof(Stat) );
    WRITE_STAT(ass, 3, level);

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
    ass = NewStat( STAT_UNB_LIST, (narg+1) * sizeof(Stat) );

    /* enter the position expressions                                       */
    for (i = narg; i > 0; i--) {
      pos = PopExpr();
      WRITE_STAT(ass, i, pos);
    }

    /* enter the list expression                                           */
    list = PopExpr();
    WRITE_STAT(ass, 0, list);

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
static void CodeElmListUniv (
                      Expr                ref,
                      Int narg)
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Int                i;

    /* enter the position expression                                       */

    for (i = narg; i > 0; i--) {
      pos = PopExpr();
      WRITE_EXPR(ref, i, pos);
    }

    /* enter the list expression                                           */
    list = PopExpr();
    WRITE_EXPR(ref, 0, list);

    /* push the reference                                                  */
    PushExpr( ref );
}

void CodeElmList ( Int narg )
{
    Expr                ref;            /* reference, result               */

    GAP_ASSERT(narg == 1 || narg == 2);

    /* allocate the reference                                              */
    if (narg == 1)
      ref = NewExpr( EXPR_ELM_LIST, 2 * sizeof(Expr) );
    else /* if (narg == 2) */
      ref = NewExpr( EXPR_ELM_MAT, 3 * sizeof(Expr) );
      
    /* let 'CodeElmListUniv' to the rest                                   */
    CodeElmListUniv( ref, narg );
}

void CodeElmsList ( void )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( EXPR_ELMS_LIST, 2 * sizeof(Expr) );

    /* let 'CodeElmListUniv' to the rest                                   */
    CodeElmListUniv( ref, 1 );
}

void CodeElmListLevel ( Int narg,
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( EXPR_ELM_LIST_LEV, (narg + 2) * sizeof(Expr));
    WRITE_EXPR(ref, narg + 1, level);

    /* let 'CodeElmListUniv' do the rest                                   */
    CodeElmListUniv( ref, narg );
}

void CodeElmsListLevel (
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( EXPR_ELMS_LIST_LEV, 3 * sizeof(Expr) );
    WRITE_EXPR(ref, 2, level);

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
    ref = NewExpr( EXPR_ISB_LIST, (narg + 1) * sizeof(Expr) );

    /* enter the position expression                                       */
    for (i = narg; i > 0; i--) {
      pos = PopExpr();
      WRITE_EXPR(ref, i, pos);
    }

    /* enter the list expression                                           */
    list = PopExpr();
    WRITE_EXPR(ref, 0, list);

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
    stat = NewStat( STAT_ASS_REC_NAME, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(stat, 2, rhsx);

    /* enter the name                                                      */
    WRITE_STAT(stat, 1, rnam);

    /* enter the record expression                                         */
    rec = PopExpr();
    WRITE_STAT(stat, 0, rec);

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
    stat = NewStat( STAT_ASS_REC_EXPR, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(stat, 2, rhsx);

    /* enter the name expression                                           */
    rnam = PopExpr();
    WRITE_STAT(stat, 1, rnam);

    /* enter the record expression                                         */
    rec = PopExpr();
    WRITE_STAT(stat, 0, rec);

    /* push the assignment                                                 */
    PushStat( stat );
}

void            CodeUnbRecName (
    UInt                rnam )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */

    /* allocate the unbind                                                 */
    stat = NewStat( STAT_UNB_REC_NAME, 2 * sizeof(Stat) );

    /* enter the name                                                      */
    WRITE_STAT(stat, 1, rnam);

    /* enter the record expression                                         */
    rec = PopExpr();
    WRITE_STAT(stat, 0, rec);

    /* push the unbind                                                     */
    PushStat( stat );
}

void            CodeUnbRecExpr ( void )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */
    Expr                rnam;           /* name expression                 */

    /* allocate the unbind                                                 */
    stat = NewStat( STAT_UNB_REC_EXPR, 2 * sizeof(Stat) );

    /* enter the name expression                                           */
    rnam = PopExpr();
    WRITE_STAT(stat, 1, rnam);

    /* enter the record expression                                         */
    rec = PopExpr();
    WRITE_STAT(stat, 0, rec);

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
    Expr                rec;            /* record expression               */

    /* allocate the reference                                              */
    expr = NewExpr( EXPR_ELM_REC_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    WRITE_EXPR(expr, 1, rnam);

    /* enter the record expression                                         */
    rec = PopExpr();
    WRITE_EXPR(expr, 0, rec);

    /* push the reference                                                  */
    PushExpr( expr );
}

void CodeElmRecExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expression               */

    /* allocate the reference                                              */
    expr = NewExpr( EXPR_ELM_REC_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    WRITE_EXPR(expr, 1, rnam);

    /* enter the record expression                                         */
    rec = PopExpr();
    WRITE_EXPR(expr, 0, rec);

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
    Expr                rec;            /* record expression               */

    /* allocate the isbound                                                */
    expr = NewExpr( EXPR_ISB_REC_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    WRITE_EXPR(expr, 1, rnam);

    /* enter the record expression                                         */
    rec = PopExpr();
    WRITE_EXPR(expr, 0, rec);

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
    Expr                rec;            /* record expression               */

    /* allocate the isbound                                                */
    expr = NewExpr( EXPR_ISB_REC_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    WRITE_EXPR(expr, 1, rnam);

    /* enter the record expression                                         */
    rec = PopExpr();
    WRITE_EXPR(expr, 0, rec);

    /* push the isbound                                                    */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeAssPosObj() . . . . . . . . . . . . . . . code assignment to a posobj
*/
void CodeAssPosObj ( void )
{
    Stat                ass;            /* assignment, result              */
    Expr                posobj;         // posobj expression
    Expr                pos;            /* position expression             */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    ass = NewStat( STAT_ASS_POSOBJ, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(ass, 2, rhsx);

    /* enter the position expression                                       */
    pos = PopExpr();
    WRITE_STAT(ass, 1, pos);

    // enter the posobj expression
    posobj = PopExpr();
    WRITE_STAT(ass, 0, posobj);

    /* push the assignment                                                 */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeUnbPosObj() . . . . . . . . . . . . . . . . .  code unbind pos object
*/
void CodeUnbPosObj ( void )
{
    Expr                posobj;         // posobj expression
    Expr                pos;            /* position expression             */
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( STAT_UNB_POSOBJ, 2 * sizeof(Stat) );

    /* enter the position expression                                       */
    pos = PopExpr();
    WRITE_STAT(ass, 1, pos);

    // enter the posobj expression
    posobj = PopExpr();
    WRITE_STAT(ass, 0, posobj);

    /* push the unbind                                                     */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeElmPosObj() . . . . . . . . . . . . . . .  code selection of a posobj
*/
void CodeElmPosObj ( void )
{
    Expr                ref;            /* reference, result               */
    Expr                posobj;         // posobj expression
    Expr                pos;            /* position expression             */

    /* allocate the reference                                              */
    ref = NewExpr( EXPR_ELM_POSOBJ, 2 * sizeof(Expr) );

    /* enter the position expression                                       */
    pos = PopExpr();
    WRITE_EXPR(ref, 1, pos);

    // enter the posobj expression
    posobj = PopExpr();
    WRITE_EXPR(ref, 0, posobj);

    /* push the reference                                                  */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeIsbPosObj() . . . . . . . . . . . . . . . code bound pos object check
*/
void CodeIsbPosObj ( void )
{
    Expr                ref;            /* isbound, result                 */
    Expr                posobj;         // posobj expression
    Expr                pos;            /* position expression             */

    /* allocate the isbound                                                */
    ref = NewExpr( EXPR_ISB_POSOBJ, 2 * sizeof(Expr) );

    /* enter the position expression                                       */
    pos = PopExpr();
    WRITE_EXPR(ref, 1, pos);

    // enter the posobj expression
    posobj = PopExpr();
    WRITE_EXPR(ref, 0, posobj);

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssComObjName( <rnam> ) . . . . . . . . . code assignment to a comobj
*F  CodeAssComObjExpr() . . . . . . . . . . . . . code assignment to a comobj
*/
void CodeAssComObjName(UInt rnam)
{
    Stat                stat;           /* assignment, result              */
    Expr                comobj;         // comobj expression
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( STAT_ASS_COMOBJ_NAME, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(stat, 2, rhsx);

    /* enter the name                                                      */
    WRITE_STAT(stat, 1, rnam);

    // enter the comobj expression
    comobj = PopExpr();
    WRITE_STAT(stat, 0, comobj);

    /* push the assignment                                                 */
    PushStat( stat );
}

void CodeAssComObjExpr(void)
{
    Stat                stat;           /* assignment, result              */
    Expr                comobj;         // comobj expression
    Expr                rnam;           /* name expression                 */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( STAT_ASS_COMOBJ_EXPR, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    WRITE_STAT(stat, 2, rhsx);

    /* enter the name expression                                           */
    rnam = PopExpr();
    WRITE_STAT(stat, 1, rnam);

    // enter the comobj expression
    comobj = PopExpr();
    WRITE_STAT(stat, 0, comobj);

    /* push the assignment                                                 */
    PushStat( stat );
}

void CodeUnbComObjName(UInt rnam)
{
    Stat                stat;           /* unbind, result                  */
    Expr                comobj;         // comobj expression

    /* allocate the unbind                                                 */
    stat = NewStat( STAT_UNB_COMOBJ_NAME, 2 * sizeof(Stat) );

    /* enter the name                                                      */
    WRITE_STAT(stat, 1, rnam);

    // enter the comobj expression
    comobj = PopExpr();
    WRITE_STAT(stat, 0, comobj);

    /* push the unbind                                                     */
    PushStat( stat );
}

void CodeUnbComObjExpr(void)
{
    Stat                stat;           /* unbind, result                  */
    Expr                comobj;         // comobj expression
    Expr                rnam;           /* name expression                 */

    /* allocate the unbind                                                 */
    stat = NewStat( STAT_UNB_COMOBJ_EXPR, 2 * sizeof(Stat) );

    /* enter the name expression                                           */
    rnam = PopExpr();
    WRITE_STAT(stat, 1, rnam);

    // enter the comobj expression
    comobj = PopExpr();
    WRITE_STAT(stat, 0, comobj);

    /* push the unbind                                                     */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeElmComObjName( <rnam> ) . . . . . . . . .  code selection of a comobj
*F  CodeElmComObjExpr() . . . . . . . . . . . . .  code selection of a comobj
*/
void CodeElmComObjName(UInt rnam)
{
    Expr                expr;           /* reference, result               */
    Expr                comobj;         // comobj expression

    /* allocate the reference                                              */
    expr = NewExpr( EXPR_ELM_COMOBJ_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    WRITE_EXPR(expr, 1, rnam);

    // enter the comobj expression
    comobj = PopExpr();
    WRITE_EXPR(expr, 0, comobj);

    /* push the reference                                                  */
    PushExpr( expr );
}

void CodeElmComObjExpr(void)
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                comobj;         // comobj expression

    /* allocate the reference                                              */
    expr = NewExpr( EXPR_ELM_COMOBJ_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    WRITE_EXPR(expr, 1, rnam);

    // enter the comobj expression
    comobj = PopExpr();
    WRITE_EXPR(expr, 0, comobj);

    /* push the reference                                                  */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeIsbComObjName( <rname> )  . . . . .  code bound com object name check
*/
void CodeIsbComObjName(UInt rnam)
{
    Expr                expr;           /* isbound, result                 */
    Expr                comobj;         // comobj expression

    /* allocate the isbound                                                */
    expr = NewExpr( EXPR_ISB_COMOBJ_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    WRITE_EXPR(expr, 1, rnam);

    // enter the comobj expression
    comobj = PopExpr();
    WRITE_EXPR(expr, 0, comobj);

    /* push the isbound                                                    */
    PushExpr( expr );
}

/****************************************************************************
**
*F  CodeIsbComObjExpr() . . . . . . . . . .  code bound com object expr check
*/
void CodeIsbComObjExpr(void)
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                comobj;         // comobj expression

    /* allocate the isbound                                                */
    expr = NewExpr( EXPR_ISB_COMOBJ_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    WRITE_EXPR(expr, 1, rnam);

    // enter the comobj expression
    comobj = PopExpr();
    WRITE_EXPR(expr, 0, comobj);

    /* push the isbound                                                    */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeEmpty()  . . . . code an empty statement
**
*/

void CodeEmpty(void)
{
  Stat stat;
  stat = NewStat(STAT_EMPTY, 0);
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
    stat = NewStat( STAT_INFO, SIZE_NARG_INFO(2+narg) );

    /* narg only counts the printable arguments                            */
    for ( i = narg + 2; 0 < i; i-- ) {
        expr = PopExpr();
        SET_ARGI_INFO(stat, i, expr);
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

    stat = NewStat( STAT_ASSERT_2ARGS, 2*sizeof(Expr) );

    WRITE_STAT(stat, 1, PopExpr()); /* condition */
    WRITE_STAT(stat, 0, PopExpr()); /* level */

    PushStat( stat );
}

void CodeAssertEnd3Args ( void )
{
    Stat                stat;           /* we build the statement here     */

    stat = NewStat( STAT_ASSERT_3ARGS, 3*sizeof(Expr) );

    WRITE_STAT(stat, 2, PopExpr()); /* message */
    WRITE_STAT(stat, 1, PopExpr()); /* condition */
    WRITE_STAT(stat, 0, PopExpr()); /* level */

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
**  String literals should really be saved byte-wise, to be safe across
**  machines of different endianness, but this would mean parsing the bag as
**  we save it which it would be nice to avoid just now.
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveBody(Obj body)
{
  UInt i;
  const UInt *ptr = (const UInt *) CONST_ADDR_OBJ(body);
  /* Save the new information in the body */
  for (i =0; i < sizeof(BodyHeader)/sizeof(Obj); i++)
    SaveSubObj((Obj)(*ptr++));
  /* and the rest */
  for (; i < (SIZE_OBJ(body)+sizeof(UInt)-1)/sizeof(UInt); i++)
    SaveUInt(*ptr++);
}
#endif


/****************************************************************************
**
*F  LoadBody( <body> ) . . . . . . . . . . . . . . . workspace loading method
**
**  A body is made up of statements and expressions, and these are all
**  organised to regular boundaries based on the types Stat and Expr, which
**  are currently both UInt
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadBody(Obj body)
{
  UInt i;
  UInt *ptr;
  ptr = (UInt *) ADDR_OBJ(body);
  for (i =0; i < sizeof(BodyHeader)/sizeof(Obj); i++)
    *(Obj *)(ptr++) = LoadSubObj();
  for (; i < (SIZE_OBJ(body)+sizeof(UInt)-1)/sizeof(UInt); i++)
    *ptr++ = LoadUInt();
}
#endif


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_BODY, "function body bag" },
  { -1,     ""                  }
};

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking functions for function body bags                */
    InitMarkFuncBags( T_BODY, MarkFourSubBags );

#ifdef GAP_ENABLE_SAVELOAD
    SaveObjFuncs[ T_BODY ] = SaveBody;
    LoadObjFuncs[ T_BODY ] = LoadBody;
#endif

#ifdef HPCGAP
    /* Allocate function bodies in the public data space */
    MakeBagTypePublic(T_BODY);
#endif

    /* make the result variable known to Gasman                            */
    InitGlobalBag(&CS(CodeResult), "CodeResult");

    /* allocate the statements and expressions stacks                      */
    InitGlobalBag(&CS(StackStat), "CS(StackStat)");
    InitGlobalBag(&CS(StackExpr), "CS(StackExpr)");

    /* some functions and globals needed for float conversion */
    InitFopyGVar( "CONVERT_FLOAT_LITERAL_EAGER", &CONVERT_FLOAT_LITERAL_EAGER);

    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . .  recover
*/
static Int PostRestore (
    StructInitInfo *    module )
{
  NextFloatExprNumber = INT_INTOBJ(ValGVar(GVarName("SavedFloatIndex")));
  return 0;
}


/****************************************************************************
**
*F  PreSave( <module> ) . . . . . . .  clean up before saving
*/
static Int PreSave (
    StructInitInfo *    module )
{
  /* Can't save in mid-parsing */
  if (CS(CountExpr) || CS(CountStat))
    return 1;

  /* push the FP cache index out into a GAP Variable */
  AssGVar(GVarName("SavedFloatIndex"), INTOBJ_INT(NextFloatExprNumber));

  // clean any old data out of the statement and expression stacks,
  // but leave the type field alone
  memset(ADDR_OBJ(CS(StackStat)) + 1, 0, SIZE_BAG(CS(StackStat)) - sizeof(Obj));
  memset(ADDR_OBJ(CS(StackExpr)) + 1, 0, SIZE_BAG(CS(StackExpr)) - sizeof(Obj));

  return 0;
}

static Int InitModuleState(void)
{
    CS(OffsBodyCount) = 0;

    // allocate the statements and expressions stacks
    CS(StackStat) = NewKernelBuffer(sizeof(Obj) + 64 * sizeof(Stat));
    CS(StackExpr) = NewKernelBuffer(sizeof(Obj) + 64 * sizeof(Expr));

#ifdef HPCGAP
    CS(OffsBodyStack) = AllocateMemoryBlock(MAX_FUNC_EXPR_NESTING*sizeof(Stat));
#else
    static Stat MainOffsBodyStack[MAX_FUNC_EXPR_NESTING];
    CS(OffsBodyStack) = MainOffsBodyStack;
#endif

    return 0;
}

/****************************************************************************
**
*F  InitInfoCode()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "code",
    .initKernel = InitKernel,
    .preSave = PreSave,
    .postRestore = PostRestore,

    .moduleStateSize = sizeof(struct CodeState),
    .moduleStateOffsetPtr = &CodeStateOffset,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoCode ( void )
{
    return &module;
}
