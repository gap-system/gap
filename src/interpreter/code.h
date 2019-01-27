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

#include "core/objects.h"
#include "gapstate.h"

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

        T_PROCCALL_0ARGS,
        T_PROCCALL_1ARGS,
        T_PROCCALL_2ARGS,
        T_PROCCALL_3ARGS,
        T_PROCCALL_4ARGS,
        T_PROCCALL_5ARGS,
        T_PROCCALL_6ARGS,
        T_PROCCALL_XARGS,

        T_PROCCALL_OPTS,

        // T_EMPTY could also be considered to be "T_SEQ_STAT0", but it
        // must be an interruptible statement, so that loops with empty
        // body can be interrupted.
        T_EMPTY,

        // The statement types between FIRST_NON_INTERRUPT_STAT and
        // LAST_NON_INTERRUPT_STAT will not be interrupted (which may happen
        // for two reasons: the user interrupted, e.g. via ctrl-c; or memory
        // run full). We don't want to compound statements to be interrupted,
        // relying instead on their sub-statements being interruptible. This
        // results in a slightly better user experience in break loops, where
        // the interrupted statement is printed, which works better for single
        // statements than for compound statements.
        START_ENUM_RANGE(FIRST_NON_INTERRUPT_STAT),

            START_ENUM_RANGE(FIRST_COMPOUND_STAT),

            T_SEQ_STAT,
            T_SEQ_STAT2,
            T_SEQ_STAT3,
            T_SEQ_STAT4,
            T_SEQ_STAT5,
            T_SEQ_STAT6,
            T_SEQ_STAT7,

            T_IF,
            T_IF_ELSE,
            T_IF_ELIF,
            T_IF_ELIF_ELSE,

            T_FOR,
            T_FOR2,
            T_FOR3,

            T_FOR_RANGE,
            T_FOR_RANGE2,
            T_FOR_RANGE3,

            T_WHILE,
            T_WHILE2,
            T_WHILE3,

            T_REPEAT,
            T_REPEAT2,
            T_REPEAT3,

#ifdef HPCGAP
            T_ATOMIC,
#endif

            END_ENUM_RANGE(LAST_COMPOUND_STAT),

        END_ENUM_RANGE(LAST_NON_INTERRUPT_STAT),

        START_ENUM_RANGE(FIRST_CONTROL_FLOW_STAT),

            T_BREAK,
            T_CONTINUE,
            T_RETURN_OBJ,
            T_RETURN_VOID,

        END_ENUM_RANGE(LAST_CONTROL_FLOW_STAT),

        T_ASS_LVAR,
        T_UNB_LVAR,

        T_ASS_HVAR,
        T_UNB_HVAR,

        T_ASS_GVAR,
        T_UNB_GVAR,

        T_ASS_LIST,
        T_ASS2_LIST,
        T_ASSS_LIST,
        T_ASS_LIST_LEV,
        T_ASSS_LIST_LEV,
        T_UNB_LIST,

        T_ASS_REC_NAME,
        T_ASS_REC_EXPR,
        T_UNB_REC_NAME,
        T_UNB_REC_EXPR,

        T_ASS_POSOBJ,
        T_UNB_POSOBJ,

        T_ASS_COMOBJ_NAME,
        T_ASS_COMOBJ_EXPR,
        T_UNB_COMOBJ_NAME,
        T_UNB_COMOBJ_EXPR,

        T_INFO,
        T_ASSERT_2ARGS,
        T_ASSERT_3ARGS,

    END_ENUM_RANGE(LAST_STAT_TNUM),

    T_NO_STAT = -1,
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
*F  IS_REFLVAR(<expr>). . . . test if an expression is a reference to a local
*F  REFLVAR_LVAR(<lvar>)  . . . . . convert a local to a reference to a local
*F  LVAR_REFLVAR(<expr>)  . . . . . convert a reference to a local to a local
**
**  'IS_REFLVAR'  returns  1  if  the  expression <expr>  is  an  (immediate)
**  reference to a local variable, and 0 otherwise.
**
**  'REFLVAR_LVAR'  returns  a (immediate) reference  to   the local variable
**  <lvar> (given by its index).
**
**  'LVAR_REFLVAR' returns the local variable (by  its index) to which <expr>
**  is a (immediate) reference.
*/
EXPORT_INLINE Int IS_REFLVAR(Expr expr)
{
    return ((Int)expr & 0x03) == 0x03;
}

EXPORT_INLINE Expr REFLVAR_LVAR(Int lvar)
{
    return (Expr)((lvar << 2) + 0x03);
}

EXPORT_INLINE Int LVAR_REFLVAR(Expr expr)
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
EXPORT_INLINE Int IS_INTEXPR(Expr expr)
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

    T_FUNCCALL_0ARGS,
    T_FUNCCALL_1ARGS,
    T_FUNCCALL_2ARGS,
    T_FUNCCALL_3ARGS,
    T_FUNCCALL_4ARGS,
    T_FUNCCALL_5ARGS,
    T_FUNCCALL_6ARGS,
    T_FUNCCALL_XARGS,
    T_FUNC_EXPR,

    T_FUNCCALL_OPTS,

    T_OR,
    T_AND,
    T_NOT,
    T_EQ,
    T_NE,
    T_LT,
    T_GE,
    T_GT,
    T_LE,
    T_IN,
    T_SUM,
    T_AINV,
    T_DIFF,
    T_PROD,
    T_QUO,
    T_MOD,
    T_POW,

    T_INTEXPR,
    T_INT_EXPR,
    T_TRUE_EXPR,
    T_FALSE_EXPR,
    T_TILDE_EXPR,
    T_CHAR_EXPR,
    T_PERM_EXPR,
    T_PERM_CYCLE,
    T_LIST_EXPR,
    T_LIST_TILDE_EXPR,
    T_RANGE_EXPR,
    T_STRING_EXPR,
    T_REC_EXPR,
    T_REC_TILDE_EXPR,

    T_FLOAT_EXPR_EAGER,
    T_FLOAT_EXPR_LAZY,

    T_REFLVAR,
    T_ISB_LVAR,

    T_REF_HVAR,
    T_ISB_HVAR,

    T_REF_GVAR,
    T_ISB_GVAR,

    T_ELM_LIST,
    T_ELM2_LIST,
    T_ELMS_LIST,
    T_ELM_LIST_LEV,
    T_ELMS_LIST_LEV,
    T_ISB_LIST,

    T_ELM_REC_NAME,
    T_ELM_REC_EXPR,
    T_ISB_REC_NAME,
    T_ISB_REC_EXPR,

    T_ELM_POSOBJ,
    T_ISB_POSOBJ,

    T_ELM_COMOBJ_NAME,
    T_ELM_COMOBJ_EXPR,
    T_ISB_COMOBJ_NAME,
    T_ISB_COMOBJ_EXPR,

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
    if (IS_REFLVAR(expr))
        return T_REFLVAR;
    if (IS_INTEXPR(expr))
        return T_INTEXPR;
    return TNUM_STAT(expr);
}


/****************************************************************************
**
*F  SIZE_EXPR(<expr>) . . . . . . . . . . . . . . . . . size of an expression
**
**  'SIZE_EXPR' returns the size of the expression <expr>.
**
**  Note  that  it is *fatal*  to apply  'SIZE_EXPR'   to expressions of type
**  'T_REFLVAR' or 'T_INTEXPR'.
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
**  'T_REFLVAR' or 'T_INTEXPR'.
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
*F  CodeFuncExprEnd(<nr>) . . . . . . . . . . . code function expression, end
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
**
*/
void CodeFuncExprBegin(Int narg, Int nloc, Obj nams, Int startLine);

void CodeFuncExprEnd(UInt nr);

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

void CodeAtomicBegin(void);

void CodeAtomicBeginBody(UInt nrexprs);

void CodeAtomicEndBody(UInt nrstats);
void CodeAtomicEnd(void);

/****************************************************************************
**
*F  CodeQualifiedExprBegin()  . . . code readonly/readwrite expression start
*F  CodeQualifiedExprEnd()  . . . . . code readonly/readwrite expression end
**
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
*F  CodeFloatExpr(<str>) . . . . . . . . . .  code literal float expression
*/
void CodeFloatExpr(Char * str);

void CodeLongFloatExpr(Obj str);


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
**  'REFLVAR_LVAR').
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
*F  CodeAssPosObj() . . . . . . . . . . . . . . . . code assignment to a list
*/
void CodeAssPosObj(void);

void CodeUnbPosObj(void);


/****************************************************************************
**
*F  CodeElmPosObj() . . . . . . . . . . . . . . . .  code selection of a list
*/
void CodeElmPosObj(void);

void CodeIsbPosObj(void);


/****************************************************************************
**
*F  CodeAssComObjName(<rnam>) . . . . . . . . . . code assignment to a record
*F  CodeAssComObjExpr() . . . . . . . . . . . . . code assignment to a record
*/
void CodeAssComObjName(UInt rnam);

void CodeAssComObjExpr(void);

void CodeUnbComObjName(UInt rnam);

void CodeUnbComObjExpr(void);


/****************************************************************************
**
*F  CodeElmComObjName(<rnam>) . . . . . . . . . .  code selection of a record
*F  CodeElmComObjExpr() . . . . . . . . . . . . .  code selection of a record
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

/*  CodeContinue() .  . . . . . . . . . . . .  code continue-statement */
void CodeContinue(void);


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
