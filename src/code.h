/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the coder package.
**
**  The  coder package  is   the part of   the interpreter  that creates  the
**  expressions.  Its functions are called from the reader.
*/

#ifndef GAP_CODE_H
#define GAP_CODE_H

#include "gapstate.h"
#include "objects.h"

/****************************************************************************
**
*T  StatHeader
**
*/
typedef struct {
    unsigned int visited : 1;
    unsigned int line : 31;
    unsigned int size : 24;
    unsigned int type : 8;
} StatHeader;

GAP_STATIC_ASSERT((sizeof(StatHeader) % sizeof(Stat)) == 0,
                  "StatHeader size must be multiple of Stat size");

/****************************************************************************
**
*V  PtrBody . . . . . . . . . . . . . . . . . . . . . pointer to current body
**
**  'PtrBody' is a pointer to the current body.
*/
/* TL: extern  Stat *          PtrBody; */


/****************************************************************************
**
**  Function body headers
**
**  'FILENAME_BODY' is a string containing the file of a function.
**  'STARTLINE_BODY' is the line number where a function starts.
**  'ENDLINE_BODY' is the line number where a function ends.
**  'LOCATION_BODY' is a string describing the location of a function.
**  Typically this will be the name of a C function implementing it.
**
**  These each have a 'GET' and a 'SET' variant, to read or set the value.
**  Note that STARTLINE_BODY and LOCATION_BODY are stored in the same place,
**  so writing one will overwrite the other.
**
**  All of these variables may be 0, if the information is not known,
*/

typedef struct {
    // if non-zero, this is either a string containing the name of the
    // file of a function, or an immediate integer containing the index
    // of the filename inside FilenameCache
    Obj filename_or_id;

    // if non-zero, this is either an immediate integer encoding the
    // line number where a function starts, or string describing the
    // location of a function. Typically this will be the name of a C
    // function implementing it.
    Obj startline_or_location;

    // if non-zero, this is an immediate integer encoding the line
    // number where a function ends
    Obj endline;

    // if non-zero, this points to a dense plist containing constant values
    // referenced by the code in this function body
    Obj values;

} BodyHeader;

EXPORT_INLINE BodyHeader *BODY_HEADER(Obj body)
{
    GAP_ASSERT(TNUM_OBJ(body) == T_BODY);
    return (BodyHeader *)ADDR_OBJ(body);
}

Obj  GET_FILENAME_BODY(Obj body);
void SET_FILENAME_BODY(Obj body, Obj val);

UInt GET_GAPNAMEID_BODY(Obj body);
void SET_GAPNAMEID_BODY(Obj body, UInt val);

Obj  GET_LOCATION_BODY(Obj body);
void SET_LOCATION_BODY(Obj body, Obj val);

UInt GET_STARTLINE_BODY(Obj body);
void SET_STARTLINE_BODY(Obj body, UInt val);
UInt GET_ENDLINE_BODY(Obj body);
void SET_ENDLINE_BODY(Obj body, UInt val);

Obj GET_VALUE_FROM_CURRENT_BODY(Int ix);

EXPORT_INLINE Obj VALUES_BODY(Obj body)
{
    return BODY_HEADER(body)->values;
}


/****************************************************************************
**
*F  NewStatOrExpr(<type>,<size>,<line>) . . . . . .  allocate a new statement
**
**  'NewStatOrExpr' allocates a new statement or expressions memory block of
**  type <type> and with <size> bytes. It also records the line number <line>
**  of the statement for profiling. It returns the offset of the new
**  statement.
**
**  Callers may pass zero for <line> to denote a statement which should not
**  be tracked by the profiling code.
*/
Stat NewStatOrExpr(UInt type, UInt size, UInt line);


void PushStat(Stat stat);


/****************************************************************************
**
*V  OFFSET_FIRST_STAT . . . . . . . . . . offset of first statement in a body
**
**  'OFFSET_FIRST_STAT' is the offset of the first statement in a body.
*/

enum {
    OFFSET_FIRST_STAT = sizeof(StatHeader)+sizeof(BodyHeader)
};


/****************************************************************************
**
*F  NewFunctionBody() . . . . . . . . . . . . . .  create a new function body
*/
Obj NewFunctionBody(void);


void WRITE_EXPR(Expr expr, UInt idx, UInt val);


/****************************************************************************
**
*S  T_<name>  . . . . . . . . . . . . . .  symbolic names for statement types
*S  FIRST_STAT_TNUM . . . . . . . . . . . . . . . . . .  first statement type
*S  LAST_STAT_TNUM  . . . . . . . . . . . . . . . . . . . last statement type
**
**  For every type  of statements there is  a symbolic name  defined for this
**  type.
*/
enum STAT_TNUM {
    START_ENUM_RANGE(FIRST_STAT_TNUM),

        STAT_PROCCALL_0ARGS,
        STAT_PROCCALL_1ARGS,
        STAT_PROCCALL_2ARGS,
        STAT_PROCCALL_3ARGS,
        STAT_PROCCALL_4ARGS,
        STAT_PROCCALL_5ARGS,
        STAT_PROCCALL_6ARGS,
        STAT_PROCCALL_XARGS,

        STAT_PROCCALL_OPTS,

        // STAT_EMPTY could also be considered to be "T_SEQ_STAT0", but it
        // must be an interruptible statement, so that loops with empty
        // body can be interrupted.
        STAT_EMPTY,

        // The statement types between FIRST_NON_INTERRUPT_STAT and
        // LAST_NON_INTERRUPT_STAT will not be interrupted (which may happen
        // for two reasons: the user interrupted, e.g. via ctrl-c; or memory
        // run full). We don't want to compound statements to be interrupted,
        // relying instead on their sub-statements being interruptible. This
        // results in a slightly better user experience in break loops, where
        // the interrupted statement is printed, which works better for
        // single statements than for compound statements.
        START_ENUM_RANGE(FIRST_NON_INTERRUPT_STAT),

            START_ENUM_RANGE(FIRST_COMPOUND_STAT),

            STAT_SEQ_STAT,
            STAT_SEQ_STAT2,
            STAT_SEQ_STAT3,
            STAT_SEQ_STAT4,
            STAT_SEQ_STAT5,
            STAT_SEQ_STAT6,
            STAT_SEQ_STAT7,

            STAT_IF,
            STAT_IF_ELSE,
            STAT_IF_ELIF,
            STAT_IF_ELIF_ELSE,

            STAT_FOR,
            STAT_FOR2,
            STAT_FOR3,

            STAT_FOR_RANGE,
            STAT_FOR_RANGE2,
            STAT_FOR_RANGE3,

            STAT_WHILE,
            STAT_WHILE2,
            STAT_WHILE3,

            STAT_REPEAT,
            STAT_REPEAT2,
            STAT_REPEAT3,

#ifdef HPCGAP
            STAT_ATOMIC,
#endif

            END_ENUM_RANGE(LAST_COMPOUND_STAT),

        END_ENUM_RANGE(LAST_NON_INTERRUPT_STAT),

        START_ENUM_RANGE(FIRST_CONTROL_FLOW_STAT),

            STAT_BREAK,
            STAT_CONTINUE,
            STAT_RETURN_OBJ,
            STAT_RETURN_VOID,

        END_ENUM_RANGE(LAST_CONTROL_FLOW_STAT),

        STAT_ASS_LVAR,
        STAT_UNB_LVAR,

        STAT_ASS_HVAR,
        STAT_UNB_HVAR,

        STAT_ASS_GVAR,
        STAT_UNB_GVAR,

        STAT_ASS_LIST,
        STAT_ASS_MAT,
        STAT_ASSS_LIST,
        STAT_ASS_LIST_LEV,
        STAT_ASSS_LIST_LEV,
        STAT_UNB_LIST,

        STAT_ASS_REC_NAME,
        STAT_ASS_REC_EXPR,
        STAT_UNB_REC_NAME,
        STAT_UNB_REC_EXPR,

        STAT_ASS_POSOBJ,
        STAT_UNB_POSOBJ,

        STAT_ASS_COMOBJ_NAME,
        STAT_ASS_COMOBJ_EXPR,
        STAT_UNB_COMOBJ_NAME,
        STAT_UNB_COMOBJ_EXPR,

        STAT_INFO,
        STAT_ASSERT_2ARGS,
        STAT_ASSERT_3ARGS,
        STAT_PRAGMA,

    END_ENUM_RANGE(LAST_STAT_TNUM),
};


/****************************************************************************
**
*F  ADDR_STAT(<stat>) . . . . . . . . . . . . absolute address of a statement
**
**  'ADDR_STAT' returns   the  absolute address of the    memory block of the
**  statement <stat>.
*/
EXPORT_INLINE const Stat * CONST_ADDR_STAT(Stat stat)
{
    return (const Stat *)STATE(PtrBody) + stat / sizeof(Stat);
}


/****************************************************************************
**
*F  READ_STAT(<stat>,<idx>)
*/
EXPORT_INLINE Stat READ_STAT(Stat stat, UInt idx)
{
    return CONST_ADDR_STAT(stat)[idx];
}


/****************************************************************************
**
*F  CONST_STAT_HEADER(<stat>)
*/
EXPORT_INLINE const StatHeader * CONST_STAT_HEADER(Stat stat)
{
    return (const StatHeader *)CONST_ADDR_STAT(stat) - 1;
}


/****************************************************************************
**
*F  TNUM_STAT(<stat>) . . . . . . . . . . . . . . . . . . type of a statement
**
**  'TNUM_STAT' returns the type of the statement <stat>.
*/
EXPORT_INLINE Int TNUM_STAT(Stat stat)
{
    return CONST_STAT_HEADER(stat)->type;
}


/****************************************************************************
**
*F  SIZE_STAT(<stat>) . . . . . . . . . . . . . . . . . . size of a statement
**
**  'SIZE_STAT' returns the size of the statement <stat>.
*/
EXPORT_INLINE Int SIZE_STAT(Stat stat)
{
    return CONST_STAT_HEADER(stat)->size;
}


/****************************************************************************
**
*F  LINE_STAT(<stat>) . . . . . . . . . . . . . . line number of a statement
**
**  'LINE_STAT' returns the line number of the statement <stat>.
*/
EXPORT_INLINE Int LINE_STAT(Stat stat)
{
    return CONST_STAT_HEADER(stat)->line;
}


/****************************************************************************
**
*F  VISITED_STAT(<stat>) . . . . . . . . . . . if statement has even been run
**
**  'VISITED_STAT' returns true if the statement has ever been executed
**  while profiling is turned on.
*/
EXPORT_INLINE Int VISITED_STAT(Stat stat)
{
    return CONST_STAT_HEADER(stat)->visited;
}


/****************************************************************************
**
*F  SET_VISITED_STAT(<stat>) . . . . . . . . . . mark statement as having run
**
**  'SET_VISITED_STAT' marks the statement as having been executed while
**  profiling wass turned on.
*/
void SET_VISITED_STAT(Stat stat);


/****************************************************************************
**
*F  IS_REF_LVAR(<expr>) . . . test if an expression is a reference to a local
*F  REF_LVAR_LVAR(<lvar>) . . . . . convert a local to a reference to a local
*F  LVAR_REF_LVAR(<expr>) . . . . . convert a reference to a local to a local
**
**  'IS_REF_LVAR' returns 1 if the expression <expr> is an (immediate)
**  reference to a local variable, and 0 otherwise.
**
**  'REF_LVAR_LVAR' returns a (immediate) reference to the local variable
**  <lvar> (given by its index).
**
**  'LVAR_REF_LVAR' returns the local variable (by its index) to which <expr>
**  is a (immediate) reference.
*/
EXPORT_INLINE BOOL IS_REF_LVAR(Expr expr)
{
    return ((Int)expr & 0x03) == 0x03;
}

EXPORT_INLINE Expr REF_LVAR_LVAR(Int lvar)
{
    return (Expr)((lvar << 2) + 0x03);
}

EXPORT_INLINE Int LVAR_REF_LVAR(Expr expr)
{
    return (Int)expr >> 2;
}


/****************************************************************************
**
*F  IS_INTEXPR(<expr>). . . .  test if an expression is an integer expression
*F  INTEXPR_INT(<i>)  . . . . .  convert a C integer to an integer expression
*F  INT_INTEXPR(<expr>) . . . .  convert an integer expression to a C integer
**
**  'IS_INTEXPR' returns 1 if the expression <expr> is an (immediate) integer
**  expression, and 0 otherwise.
**
**  'INTEXPR_INT' converts    the C integer <i>    to  an (immediate) integer
**  expression.
**
**  'INT_INTEXPR' converts the (immediate) integer  expression <expr> to a  C
**  integer.
*/
EXPORT_INLINE BOOL IS_INTEXPR(Expr expr)
{
    return ((Int)expr & 0x03) == 0x01;
}

EXPORT_INLINE Expr INTEXPR_INT(Int indx)
{
    return (Expr)(((UInt)indx << 2) + 0x01);
}

EXPORT_INLINE Int INT_INTEXPR(Expr expr)
{
    return ((Int)expr-0x01) >> 2;
}


/****************************************************************************
**
*S  T_<name>  . . . . . . . . . . . . . . symbolic names for expression types
*S  FIRST_EXPR_TNUM . . . . . . . . . . . . . . . . . . first expression type
*S  LAST_EXPR_TNUM  . . . . . . . . . . . . . . . . . .  last expression type
**
**  For every type of expressions there  is a symbolic  name defined for this
**  type.
*/
enum EXPR_TNUM {
    START_ENUM_RANGE_INIT(FIRST_EXPR_TNUM, 128),

    EXPR_FUNCCALL_0ARGS,
    EXPR_FUNCCALL_1ARGS,
    EXPR_FUNCCALL_2ARGS,
    EXPR_FUNCCALL_3ARGS,
    EXPR_FUNCCALL_4ARGS,
    EXPR_FUNCCALL_5ARGS,
    EXPR_FUNCCALL_6ARGS,
    EXPR_FUNCCALL_XARGS,
    EXPR_FUNC,

    EXPR_FUNCCALL_OPTS,

    EXPR_OR,
    EXPR_AND,
    EXPR_NOT,
    EXPR_EQ,
    EXPR_NE,
    EXPR_LT,
    EXPR_GE,
    EXPR_GT,
    EXPR_LE,
    EXPR_IN,
    EXPR_SUM,
    EXPR_AINV,
    EXPR_DIFF,
    EXPR_PROD,
    EXPR_QUO,
    EXPR_MOD,
    EXPR_POW,

    EXPR_INT,
    EXPR_INTPOS,
    EXPR_TRUE,
    EXPR_FALSE,
    EXPR_TILDE,
    EXPR_CHAR,
    EXPR_PERM,
    EXPR_PERM_CYCLE,
    EXPR_LIST,
    EXPR_LIST_TILDE,
    EXPR_RANGE,
    EXPR_STRING,
    EXPR_REC,
    EXPR_REC_TILDE,

    EXPR_FLOAT_EAGER,
    EXPR_FLOAT_LAZY,

    EXPR_REF_LVAR,
    EXPR_ISB_LVAR,

    EXPR_REF_HVAR,
    EXPR_ISB_HVAR,

    EXPR_REF_GVAR,
    EXPR_ISB_GVAR,

    EXPR_ELM_LIST,
    EXPR_ELM_MAT,
    EXPR_ELMS_LIST,
    EXPR_ELM_LIST_LEV,
    EXPR_ELMS_LIST_LEV,
    EXPR_ISB_LIST,

    EXPR_ELM_REC_NAME,
    EXPR_ELM_REC_EXPR,
    EXPR_ISB_REC_NAME,
    EXPR_ISB_REC_EXPR,

    EXPR_ELM_POSOBJ,
    EXPR_ISB_POSOBJ,

    EXPR_ELM_COMOBJ_NAME,
    EXPR_ELM_COMOBJ_EXPR,
    EXPR_ISB_COMOBJ_NAME,
    EXPR_ISB_COMOBJ_EXPR,

    END_ENUM_RANGE(LAST_EXPR_TNUM)
};


/****************************************************************************
**
*F  TNUM_EXPR(<expr>) . . . . . . . . . . . . . . . . . type of an expression
**
**  'TNUM_EXPR' returns the type of the expression <expr>.
*/
EXPORT_INLINE Int TNUM_EXPR(Expr expr)
{
    if (IS_REF_LVAR(expr))
        return EXPR_REF_LVAR;
    if (IS_INTEXPR(expr))
        return EXPR_INT;
    return TNUM_STAT(expr);
}


/****************************************************************************
**
*F  SIZE_EXPR(<expr>) . . . . . . . . . . . . . . . . . size of an expression
**
**  'SIZE_EXPR' returns the size of the expression <expr>.
**
**  Note  that  it is *fatal*  to apply  'SIZE_EXPR'   to expressions of type
**  'EXPR_REF_LVAR' or 'EXPR_INT'.
*/
#define SIZE_EXPR(expr) SIZE_STAT(expr)


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
#define CONST_ADDR_EXPR(expr) CONST_ADDR_STAT(expr)

#define READ_EXPR(expr, idx) (CONST_ADDR_EXPR(expr)[idx])

/****************************************************************************
**
*F  FUNC_CALL(<call>) . . . . . . . . . . . . .  function for a function call
*F  ARGI_CALL(<call>,<i>) . . . .  <i>-th formal argument for a function call
*F  NARG_SIZE_CALL(<size>)  . . . . . number of arguments for a function call
*F  SIZE_NARG_CALL(<narg>)  . . . . . . . size of the bag for a function call
**
**  'FUNC_CALL'  returns the expression that should  evaluate to the function
**  for the procedure or  function call <call>.   This is a legal left value,
**  so it can be used to set the expression too.
**
**  'ARGI_CALL'  returns  the expression that evaluate   to the <i>-th actual
**  argument for the procedure or function call <call>.  This is a legal left
**  value, so it can be used to set the expression too.
**
**  'NARG_SIZE_CALL' returns the number of  arguments in a function call from
**  the size <size> of the function call bag (as returned by 'SIZE_EXPR').
**
**  'SIZE_NARG_CALL' returns the size a  function call bag  should have for a
**  function call bag with <narg> arguments.
*/
#define FUNC_CALL(call)         READ_EXPR(call, 0)
#define ARGI_CALL(call,i)       READ_EXPR(call, i)
#define NARG_SIZE_CALL(size)    (((size) / sizeof(Expr)) - 1)
#define SIZE_NARG_CALL(narg)    (((narg) + 1) * sizeof(Expr))


/****************************************************************************
**
*F  ARGI_INFO(<info>,<i>) . . .  <i>-th formal argument for an Info statement
*F  NARG_SIZE_INFO(<size>)  . . . . number of arguments for an Info statement
*F  SIZE_NARG_INFO(<narg>)  . . . . . . size of the bag for an Info statement
**
**  'ARGI_INFO' returns the expression   that evaluates to the <i>-th  actual
**  argument for the Info  statement <info>.  This is a  legal left value, so
**  it can be used to set the expression too.
**
**  'NARG_SIZE_INFO' returns the number of  arguments in a function call from
**  the size <size> of the function call bag (as returned by 'SIZE_STAT').
**
**  'SIZE_NARG_INFO' returns the size a  function call bag  should have for a
**  function call bag with <narg> arguments.
*/
#define ARGI_INFO(info,i)       READ_STAT(info, (i) - 1)
#define NARG_SIZE_INFO(size)    ((size) / sizeof(Expr))
#define SIZE_NARG_INFO(narg)    ((narg) * sizeof(Expr))


/****************************************************************************
**
*V  CodeResult  . . . . . . . . . . . . . . . . . . . . . .  result of coding
**
**  'CodeResult'  is the result  of the coding, i.e.,   the function that was
**  coded.
*/
/* TL: extern  Obj             CodeResult; */


/****************************************************************************
**
*F * * * * * * * * * * * * *  coder functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  CodeBegin() . . . . . . . . . . . . . . . . . . . . . . . start the coder
*F  CodeEnd(<error>)  . . . . . . . . . . . . . . . . . . . .  stop the coder
**
**  'CodeBegin'  starts  the  coder.    It is   called  from  the   immediate
**  interpreter   when he encounters  a construct  that it cannot immediately
**  interpret.
**
**  'CodeEnd' stops the coder.  It  is called from the immediate  interpreter
**  when he is done with the construct  that it cannot immediately interpret.
**  If <error> is  non-zero, a syntax error  was detected by the  reader, and
**  the coder should only clean up. Otherwise, returns the newly coded
**  function.
**
**  ...only function expressions inbetween...
*/
void CodeBegin(void);

Obj CodeEnd(UInt error);


/****************************************************************************
**
*F  CodeFuncCallBegin() . . . . . . . . . . . . . . code function call, begin
*F  CodeFuncCallEnd(<funccall>,<options>, <nr>)  . code function call, end
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
void CodeFuncCallBegin(void);

void CodeFuncCallEnd(UInt funccall, UInt options, UInt nr);


/****************************************************************************
**
*F  CodeFuncExprBegin(<narg>,<nloc>,<nams>,<startline>) . code function expression, begin
*F  CodeFuncExprEnd(<nr>,<pushExpr>) . . . . .  code function expression, end
**
**  'CodeFuncExprBegin'  is an action to code  a  function expression.  It is
**  called when the reader encounters the beginning of a function expression.
**  <narg> is the number of  arguments (-1 if the  function takes a  variable
**  number of arguments), <nloc> is the number of locals, <nams> is a list of
**  local variable names.
**
**  'CodeFuncExprEnd'  is an action to  code  a function  expression.  It  is
**  called when the reader encounters the end of a function expression.  <nr>
**  is the number of statements in the body of the function. If <pushExpr> is
**  set, the current function expression is pushed on the expression stack.
*/
void CodeFuncExprBegin(Int narg, Int nloc, Obj nams, Int startLine);

Expr CodeFuncExprEnd(UInt nr, UInt pushExpr);

/****************************************************************************
**
*F  AddValueToBody( <val> ) . . . . . . . . . . .  store value in values list
**
**  'AddValueToBody' adds a value into the value list of the body of the
**  function currently being coded, and returns the index at which the value
**  was inserted. This function must only be called while coding a function.
*/
Int AddValueToBody(Obj val);

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
**  CodeFuncCallEnd().
**
*/
void CodeFuncCallOptionsBegin(void);


void CodeFuncCallOptionsBeginElmName(UInt rnam);

void CodeFuncCallOptionsBeginElmExpr(void);

void CodeFuncCallOptionsEndElm(void);


void CodeFuncCallOptionsEndElmEmpty(void);

void CodeFuncCallOptionsEnd(UInt nr);


/****************************************************************************
**
*F  CodeIfBegin() . . . . . . . . . . . code if-statement, begin of statement
*F  CodeIfElif()  . . . . . . . . . . code if-statement, begin of elif-branch
*F  CodeIfElse()  . . . . . . . . . . code if-statement, begin of else-branch
*F  CodeIfBeginBody() . . . . . . . . . . .  code if-statement, begin of body
*F  CodeIfEndBody(<nr>) . . . . . . . . . . .  code if-statement, end of body
*F  CodeIfEnd(<nr>) . . . . . . . . . . . code if-statement, end of statement
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
void CodeIfBegin(void);

void CodeIfElif(void);

void CodeIfElse(void);

Int CodeIfBeginBody(void);

Int CodeIfEndBody(UInt nr);

void CodeIfEnd(UInt nr);


/****************************************************************************
**
*F  CodeForBegin()  . . . . . . . . .  code for-statement, begin of statement
*F  CodeForIn() . . . . . . . . . . . . . . . . code for-statement, 'in' read
*F  CodeForBeginBody()  . . . . . . . . . . code for-statement, begin of body
*F  CodeForEndBody(<nr>)  . . . . . . . . . . code for-statement, end of body
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
void CodeForBegin(void);

void CodeForIn(void);

void CodeForBeginBody(void);

void CodeForEndBody(UInt nr);

void CodeForEnd(void);

/****************************************************************************
**
*F  CodeAtomicBegin() . . . . . . . code atomic-statement, begin of statement
*F  CodeAtomicBeginBody() . . . . . . .  code atomic-statement, begin of body
*F  CodeAtomicEndBody(<nr>) . . . . . . .  code atomic-statement, end of body
*F  CodeAtomicEnd() . . . . . . . . . code atomic-statement, end of statement
**
**  'CodeAtomicBegin' is an action to code an atomic-statement. It is called
**  when the reader encounters the 'atomic', i.e., *before* the condition is
**  read.
**
**  'CodeAtomicBeginBody' is an action to code an atomic-statement. It is
**  called when the reader encounters the beginning of the statement body,
**  i.e., *after* the condition is read.
**
**  'CodeAtomicEndBody' is an action to code an atomic-statement. It is called
**  when the reader encounters the end of the statement body. <nr> is the
**  number of statements in the body.
**
**  'CodeAtomicEnd' is an action to code an atomic-statement. It is called
**  when the reader encounters the end of the statement, i.e., immediately
**  after 'CodeAtomicEndBody'.
*/

void CodeAtomicBegin(void);

void CodeAtomicBeginBody(UInt nrexprs);

void CodeAtomicEndBody(UInt nrstats);
void CodeAtomicEnd(void);

/****************************************************************************
**
*F  CodeQualifiedExprBegin(<qual>) . code readonly/readwrite expression start
*F  CodeQualifiedExprEnd() . . . . . . code readonly/readwrite expression end
**
**  These functions code the beginning and end of the readonly/readwrite
**  qualified expressions of an atomic statement.
*/
void CodeQualifiedExprBegin(UInt qual);

void CodeQualifiedExprEnd(void);


/****************************************************************************
**
*F  CodeWhileBegin()  . . . . . . .  code while-statement, begin of statement
*F  CodeWhileBeginBody()  . . . . . . . . code while-statement, begin of body
*F  CodeWhileEndBody(<nr>)  . . . . . . . . code while-statement, end of body
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
void CodeWhileBegin(void);

void CodeWhileBeginBody(void);

void CodeWhileEndBody(UInt nr);

void CodeWhileEnd(void);


/****************************************************************************
**
*F  CodeRepeatBegin() . . . . . . . code repeat-statement, begin of statement
*F  CodeRepeatBeginBody() . . . . . . .  code repeat-statement, begin of body
*F  CodeRepeatEndBody(<nr>) . . . . . . .  code repeat-statement, end of body
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
void CodeRepeatBegin(void);

void CodeRepeatBeginBody(void);

void CodeRepeatEndBody(UInt nr);

void CodeRepeatEnd(void);


/****************************************************************************
**
*F  CodeBreak() . . . . . . . . . . . . . . . . . . . .  code break-statement
**
**  'CodeBreak' is the  action to code a  break-statement.  It is called when
**  the reader encounters a 'break;'.
*/
void CodeBreak(void);


/****************************************************************************
**
*F  CodeContinue() . . . . . . . . . . . . . . . . .  code continue-statement
**
**  'CodeContinue' is the action to code a continue-statement. It is called
**  when the reader encounters a 'continue;'.
*/
void CodeContinue(void);


/****************************************************************************
**
*F  CodeReturnObj() . . . . . . . . . . . . . . . code return-value-statement
**
**  'CodeReturnObj' is the  action to code  a return-value-statement.  It  is
**  called when the reader encounters a 'return <expr>;', but *after* reading
**  the expression <expr>.
*/
void CodeReturnObj(void);


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
void CodeReturnVoid(void);
void CodeReturnVoidWhichIsNotProfiled(void);

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
void CodeOrL(void);

void CodeOr(void);

void CodeAndL(void);

void CodeAnd(void);

void CodeNot(void);

void CodeEq(void);

void CodeNe(void);

void CodeLt(void);

void CodeGe(void);

void CodeGt(void);

void CodeLe(void);

void CodeIn(void);

void CodeSum(void);

void CodeAInv(void);

void CodeDiff(void);

void CodeProd(void);

void CodeQuo(void);

void CodeMod(void);

void CodePow(void);


/****************************************************************************
**
*F  CodeIntExpr(<val>)  . . . . . . . . . . . code literal integer expression
**
**  'CodeIntExpr' is the action to code a literal integer expression.  <val>
**  is the integer as a GAP object.
*/
void CodeIntExpr(Obj val);

/****************************************************************************
**
*F  CodeTildeExpr()  . . . . . . . . . . . . . .  code tilde expression
**
**  'CodeTildeExpr' is the action to code a tilde expression.
*/
void CodeTildeExpr(void);

/****************************************************************************
**
*F  CodeTrueExpr()  . . . . . . . . . . . . . .  code literal true expression
**
**  'CodeTrueExpr' is the action to code a literal true expression.
*/
void CodeTrueExpr(void);


/****************************************************************************
**
*F  CodeFalseExpr() . . . . . . . . . . . . . . code literal false expression
**
**  'CodeFalseExpr' is the action to code a literal false expression.
*/
void CodeFalseExpr(void);


/****************************************************************************
**
*F  CodeCharExpr(<chr>) . . . . . . . . . . code literal character expression
**
**  'CodeCharExpr'  is the action  to  code a  literal  character expression.
**  <chr> is the C character.
*/
void CodeCharExpr(Char chr);


/****************************************************************************
**
*F  CodePermCycle(<nrx>,<nrc>)  . . . . . code literal permutation expression
*F  CodePerm(<nrc>) . . . . . . . . . . . code literal permutation expression
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
void CodePermCycle(UInt nrx, UInt nrc);

void CodePerm(UInt nrc);


/****************************************************************************
**
*F  CodeListExprBegin(<top>)  . . . . . . . . . . code list expression, begin
*F  CodeListExprBeginElm(<pos>) . . . . . code list expression, begin element
*F  CodeListExprEndElm()  . . . . . . . . . code list expression, end element
*F  CodeListExprEnd(<nr>,<range>,<top>,<tilde>) . . code list expression, end
*/
void CodeListExprBegin(UInt top);

void CodeListExprBeginElm(UInt pos);

void CodeListExprEndElm(void);

void CodeListExprEnd(UInt nr, UInt range, UInt top, UInt tilde);


/****************************************************************************
**
*F  CodeStringExpr(<str>) . . . . . . . . . .  code literal string expression
*/
void CodeStringExpr(Obj str);


/****************************************************************************
**
*F  CodePragma(<pragma>)
*/
void CodePragma(Obj pragma);


/****************************************************************************
**
*F  CodeLazyFloatExpr(<str>,<pushExpr>) . . . . .  code lazy float expression
*/
Expr CodeLazyFloatExpr(Obj str, UInt pushExpr);


/****************************************************************************
**
*F  CodeFloatExpr(<str>) . . . . . . . . . .  code literal float expression
*/
void CodeFloatExpr(Obj str);


/****************************************************************************
**
*F  CodeRecExprBegin(<top>) . . . . . . . . . . code record expression, begin
*F  CodeRecExprBeginElmName(<rnam>) . . code record expression, begin element
*F  CodeRecExprBeginElmExpr() . . . . . code record expression, begin element
*F  CodeRecExprEndElmExpr() . . . . . . . code record expression, end element
*F  CodeRecExprEnd(<nr>,<top>,<tilde>)  . . . . . code record expression, end
*/
void CodeRecExprBegin(UInt top);

void CodeRecExprBeginElmName(UInt rnam);

void CodeRecExprBeginElmExpr(void);

void CodeRecExprEndElm(void);

void CodeRecExprEnd(UInt nr, UInt top, UInt tilde);


/****************************************************************************
**
*F  CodeAssLVar(<lvar>) . . . . . . . . . . . . . .  code assignment to local
**
**  'CodeAssLVar' is the action  to code an  assignment to the local variable
**  <lvar> (given  by its  index).  It is   called by the  reader *after* the
**  right hand side expression is read.
**
**  An assignment  to a  local variable  is   represented by a  bag with  two
**  subexpressions.  The  *first* is the local variable,  the *second* is the
**  right hand side expression.
*/
void CodeAssLVar(UInt lvar);

void CodeUnbLVar(UInt lvar);


/****************************************************************************
**
*F  CodeRefLVar(<lvar>) . . . . . . . . . . . . . . . code reference to local
**
**  'CodeRefLVar' is  the action  to code a  reference  to the local variable
**  <lvar> (given  by its   index).  It is   called by  the  reader  when  it
**  encounters a local variable.
**
**  A   reference to   a local  variable    is represented immediately   (see
**  'REF_LVAR_LVAR').
*/
void CodeRefLVar(UInt lvar);

void CodeIsbLVar(UInt lvar);


/****************************************************************************
**
*F  CodeAssHVar(<hvar>) . . . . . . . . . . . . . . code assignment to higher
**
**  'CodeAssHVar' is the action to code an  assignment to the higher variable
**  <hvar> (given by its  level  and  index).  It  is  called by  the  reader
**  *after* the right hand side expression is read.
**
**  An assignment to a higher variable is represented by a statement bag with
**  two subexpressions.  The *first* is the higher  variable, the *second* is
**  the right hand side expression.
*/
void CodeAssHVar(UInt hvar);

void CodeUnbHVar(UInt hvar);


/****************************************************************************
**
*F  CodeRefHVar(<hvar>) . . . . . . . . . . . . . .  code reference to higher
**
**  'CodeRefHVar' is the  action to code  a reference to the higher  variable
**  <hvar> (given by its level  and index).  It is  called by the reader when
**  it encounters a higher variable.
**
**  A reference to a higher variable is represented by an expression bag with
**  one subexpression.  This is the higher variable.
*/
void CodeRefHVar(UInt hvar);

void CodeIsbHVar(UInt hvar);


/****************************************************************************
**
*F  CodeAssGVar(<gvar>) . . . . . . . . . . . . . . code assignment to global
**
**  'CodeAssGVar' is the action to code  an assignment to the global variable
**  <gvar>.  It is  called   by  the reader    *after* the right   hand  side
**  expression is read.
**
**  An assignment to a global variable is represented by a statement bag with
**  two subexpressions.  The *first* is the  global variable, the *second* is
**  the right hand side expression.
*/
void CodeAssGVar(UInt gvar);

void CodeUnbGVar(UInt gvar);


/****************************************************************************
**
*F  CodeRefGVar(<gvar>) . . . . . . . . . . . . . .  code reference to global
**
**  'CodeRefGVar' is the  action to code a  reference to  the global variable
**  <gvar>.  It is called by the reader when it encounters a global variable.
**
**  A reference to a global variable is represented by an expression bag with
**  one subexpression.  This is the global variable.
*/
void CodeRefGVar(UInt gvar);

void CodeIsbGVar(UInt gvar);


/****************************************************************************
**
*F  CodeAssList() . . . . . . . . . . . . . . . . . code assignment to a list
*F  CodeAsssList()  . . . . . . . . . . .  code multiple assignment to a list
*F  CodeAssListLevel(<level>) . . . . . . .  code assignment to several lists
*F  CodeAsssListLevel(<level>)  . . code multiple assignment to several lists
*/
void CodeAssList(Int narg);

void CodeAsssList(void);

void CodeAssListLevel(Int narg, UInt level);

void CodeAsssListLevel(UInt level);

void CodeUnbList(Int narg);


/****************************************************************************
**
*F  CodeElmList() . . . . . . . . . . . . . . . . .  code selection of a list
*F  CodeElmsList()  . . . . . . . . . . . . code multiple selection of a list
*F  CodeElmListLevel(<level>) . . . . . . . . code selection of several lists
*F  CodeElmsListLevel(<level>)  . .  code multiple selection of several lists
*/
void CodeElmList(Int narg);

void CodeElmsList(void);

void CodeElmListLevel(Int narg, UInt level);

void CodeElmsListLevel(UInt level);

void CodeIsbList(Int narg);


/****************************************************************************
**
*F  CodeAssRecName(<rnam>)  . . . . . . . . . . . code assignment to a record
*F  CodeAssRecExpr()  . . . . . . . . . . . . . . code assignment to a record
*/
void CodeAssRecName(UInt rnam);

void CodeAssRecExpr(void);

void CodeUnbRecName(UInt rnam);

void CodeUnbRecExpr(void);


/****************************************************************************
**
*F  CodeElmRecName(<rnam>)  . . . . . . . . . . .  code selection of a record
*F  CodeElmRecExpr()  . . . . . . . . . . . . . .  code selection of a record
*/
void CodeElmRecName(UInt rnam);

void CodeElmRecExpr(void);

void CodeIsbRecName(UInt rnam);

void CodeIsbRecExpr(void);


/****************************************************************************
**
*F  CodeAssPosObj() . . . . . . . . . . . . . . . code assignment to a posobj
*/
void CodeAssPosObj(void);

void CodeUnbPosObj(void);


/****************************************************************************
**
*F  CodeElmPosObj() . . . . . . . . . . . . . . .  code selection of a posobj
*/
void CodeElmPosObj(void);

void CodeIsbPosObj(void);


/****************************************************************************
**
*F  CodeAssComObjName(<rnam>) . . . . . . . . . . code assignment to a comobj
*F  CodeAssComObjExpr() . . . . . . . . . . . . . code assignment to a comobj
*/
void CodeAssComObjName(UInt rnam);

void CodeAssComObjExpr(void);

void CodeUnbComObjName(UInt rnam);

void CodeUnbComObjExpr(void);


/****************************************************************************
**
*F  CodeElmComObjName(<rnam>) . . . . . . . . . .  code selection of a comobj
*F  CodeElmComObjExpr() . . . . . . . . . . . . .  code selection of a comobj
*/
void CodeElmComObjName(UInt rnam);

void CodeElmComObjExpr(void);

void CodeIsbComObjName(UInt rnam);

void CodeIsbComObjExpr(void);

/****************************************************************************
**
*F  CodeEmpty()  . . . . code an empty statement
**
*/

void CodeEmpty(void);

/****************************************************************************
**
*F  CodeInfoBegin() . . . . . . . . . . . . .  start coding of Info statement
*F  CodeInfoMiddle()  . . . . . . . . .   shift to coding printable arguments
*F  CodeInfoEnd( <narg> ) . . Info statement complete, <narg> things to print
**
**  These  actions deal  with the  Info  statement, which is coded specially,
**  because not all of its arguments are always evaluated.
*/
void CodeInfoBegin(void);

void CodeInfoMiddle(void);

void CodeInfoEnd(UInt narg);


/****************************************************************************
**
*F  CodeAssertBegin() . . . . . . .  start interpretation of Assert statement
*F  CodeAsseerAfterLevel()  . . called after the first argument has been read
*F  CodeAssertAfterCondition() called after the second argument has been read
*F  CodeAssertEnd2Args() . . . . called after reading the closing parenthesis
*F  CodeAssertEnd3Args() . . . . called after reading the closing parenthesis
*/
void CodeAssertBegin(void);

void CodeAssertAfterLevel(void);

void CodeAssertAfterCondition(void);

void CodeAssertEnd2Args(void);

void CodeAssertEnd3Args(void);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoCode() . . . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoCode ( void );



#endif // GAP_CODE_H
