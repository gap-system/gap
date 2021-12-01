/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the immediate interpreter package.
**
**  The immediate interpreter package  is  the part  of the interpreter  that
**  interprets code immediately (while it is read).  Its functions are called
**  from the reader.  When it encounters  constructs that it cannot interpret
**  immediately, it switches into coding mode, and  delegates the work to the
**  coder.
*/

#ifndef GAP_INTRPRTR_H
#define GAP_INTRPRTR_H

#include "common.h"
#include "gap.h"


struct IntrState {

    // If 'IntrIgnoring' is non-zero, the interpreter is currently ignoring
    // actions. The interpreter switches to this mode for the right operand of
    // 'or' and 'and' constructs where the left operand already determines the
    // outcome.
    //
    // This mode is also used in Info and Assert, when arguments are not
    // printed.
    UInt ignoring;

    // If 'coding' is non-zero, the interpreter is currently coding actions.
    // The interpreter switches to this mode for constructs that it cannot
    // directly interpret, such as loops or function bodies.
    UInt coding;

    // If 'returning' is non-zero, the interpreter is currently exiting
    // statements enclosing a return statement. Actions from these statements
    // are ignored.
    ExecStatus returning;

    // Record the first line of the fragment of code currently being
    // interpreted in 'startLine', so we can mark interpreted code lines when
    // profiling
    UInt startLine;

    // 'StackObj' is the stack of values.
    Obj StackObj;
};

typedef struct IntrState IntrState;


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
void IntrBegin(IntrState * intr);

ExecStatus IntrEnd(IntrState * intr, BOOL error, Obj * result);


/****************************************************************************
**
*F  IntrAbortCoding() . . . . . . . . . . . . . . . . . . . . .  abort coding
**
**  'IntrAbortCoding' aborts coding, if it is active.
*/
void IntrAbortCoding(IntrState * intr);


/****************************************************************************
**
*F  IntrFuncCallBegin() . . . . . . . . . . .  interpret function call, begin
*F  IntrFuncCallEnd(<funccall>,<options>,<nr>)  interpret function call, end
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
void IntrFuncCallBegin(IntrState * intr);

void IntrFuncCallEnd(IntrState * intr, UInt funccall, UInt options, UInt nr);

/****************************************************************************
**
*F  IntrFuncCallOptionsBegin() . . . . . . . . . . . interpret options, begin
*F  IntrFuncCallOptionsBeginElmName(<rnam>)  interpret options, begin element
*F  IntrFuncCallOptionsBeginElmExpr() . . .  interpret options, begin element
*F  IntrFuncCallOptionsEndElm() . . . . . . .  interpret options, end element
*F  IntrFuncCallOptionsEndElmEmpty() . . . . . interpret options, end element
*F  IntrFuncCallOptionsEnd(<nr>) . . . . . . . . . . . interpret options, end
**
**  The net effect of all of these is to leave a record object on the stack
**  where IntrFuncCallEnd can use it
*/
void IntrFuncCallOptionsBegin(IntrState * intr);

void IntrFuncCallOptionsBeginElmName(IntrState * intr, UInt rnam);

void IntrFuncCallOptionsBeginElmExpr(IntrState * intr);

void IntrFuncCallOptionsEndElm(IntrState * intr);

void IntrFuncCallOptionsEndElmEmpty(IntrState * intr);

void IntrFuncCallOptionsEnd(IntrState * intr, UInt nr);

/****************************************************************************
**
*F  IntrFuncExprBegin(<narg>,<nloc>,<nams>,<startline>) .  interpret function expr, begin
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
    IntrState * intr, Int narg, Int nloc, Obj nams, Int startLine);

void IntrFuncExprEnd(IntrState * intr, UInt nr);


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
void IntrIfBegin(IntrState * intr);

void IntrIfElif(IntrState * intr);

void IntrIfElse(IntrState * intr);

void IntrIfBeginBody(IntrState * intr);

Int IntrIfEndBody(IntrState * intr, UInt nr);

void IntrIfEnd(IntrState * intr, UInt nr);


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
void IntrForBegin(IntrState * intr, Obj stackNams);

void IntrForIn(IntrState * intr);

void IntrForBeginBody(IntrState * intr);

void IntrForEndBody(IntrState * intr, UInt nr);

void IntrForEnd(IntrState * intr, Obj stackNams);


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
void IntrWhileBegin(IntrState * intr, Obj stackNams);

void IntrWhileBeginBody(IntrState * intr);

void IntrWhileEndBody(IntrState * intr, UInt nr);

void IntrWhileEnd(IntrState * intr, Obj stackNams);


/****************************************************************************
**
*F  IntrQualifiedExprBegin(<qual>) .  interpret readonly/readwrite expr start
*F  IntrQualifiedExprEnd() . . . . . .  interpret readonly/readwrite expr end
**
**  These functions interpret the beginning and end of the readonly/readwrite
**  qualified expressions of an atomic statement.
*/
void IntrQualifiedExprBegin(IntrState * intr, UInt qual);

void IntrQualifiedExprEnd(IntrState * intr);


/****************************************************************************
**
*F  IntrAtomicBegin() . . . .  interpret atomic-statement, begin of statement
*F  IntrAtomicBeginBody() . . . . . interpret atomic-statement, begin of body
*F  IntrAtomicEndBody(<nr>) . . . . . interpret atomic-statement, end of body
*F  IntrAtomicEnd() . . . . . .  interpret atomic-statement, end of statement
**
**  'IntrAtomicBegin' is an action to interpret an atomic-statement. It is
**  called when the reader encounters the 'atomic', i.e., *before* the
**  condition is read.
**
**  'IntrAtomicBeginBody' is an action to interpret an atomic-statement. It is
**  called when the reader encounters the beginning of the statement body,
**  i.e., *after* the expressions to be locked have been read. <nrexprs> is
**  the number of such  expressions.
**
**  'IntrAtomicEndBody' is an action to interpret an atomic-statement. It is
**  called when the reader encounters the end of the statement body. <nr> is
**  the number of statements in the body.
**
**  'IntrAtomicEnd' is an action to interpret an atomic-statement. It is
**  called when the reader encounters the end of the statement, i.e.,
**  lyimmediate after 'IntrAtomicEndBody'.
**
**  These functions only do something meaningful inside HPC-GAP; otherwise,
**  they are simply placeholders.
*/

void IntrAtomicBegin(IntrState * intr, Obj stackNams);

void IntrAtomicBeginBody(IntrState * intr, UInt nrexprs);

void IntrAtomicEndBody(IntrState * intr, Int nrstats);

void IntrAtomicEnd(IntrState * intr, Obj stackNams);

#ifdef HPCGAP
/* TODO: move these constants to a more appropriate location */
enum {
    MAX_ATOMIC_OBJS = 256
};
#endif


/****************************************************************************
**
*F  IntrRepeatBegin() . . . .  interpret repeat-statement, begin of statement
*F  IntrRepeatBeginBody() . . . . . interpret repeat-statement, begin of body
*F  IntrRepeatEndBody(<nr>) . . . . . interpret repeat-statement, end of body
*F  IntrRepeatEnd() . . . . . .  interpret repeat-statement, end of statement
**
**  'IntrRepeatBegin'  is an action to interpret  a  repeat-statement.  It is
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
void IntrRepeatBegin(IntrState * intr, Obj stackNams);

void IntrRepeatBeginBody(IntrState * intr);

void IntrRepeatEndBody(IntrState * intr, UInt nr);

void IntrRepeatEnd(IntrState * intr, Obj stackNams);


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
void IntrBreak(IntrState * intr);


/****************************************************************************
**
*F  IntrReturnObj() . . . . . . . . . . . .  interpret return-value-statement
**
**  'IntrReturnObj' is the action  to interpret a return-value-statement.  It
**  is  called when  the reader encounters  a  'return  <expr>;', but *after*
**  reading the expression <expr>.
*/
void IntrReturnObj(IntrState * intr);


/****************************************************************************
**
*F  IntrReturnVoid()  . . . . . . . . . . . . interpret return-void-statement
**
**  'IntrReturnVoid' is the action to interpret  a return-void-statement.  It
**  is called when the reader encounters a 'return;'.
*/
void IntrReturnVoid(IntrState * intr);


/****************************************************************************
**
*F  IntrQuit()  . . . . . . . . . . . . . . . . . .  interpret quit-statement
**
**  'IntrQuit' is the  action to interpret   a quit-statement.  It  is called
**  when the reader encounters a 'quit;'.
*/
void IntrQuit(IntrState * intr);

/****************************************************************************
**
*F  IntrQUIT()  . . . . . . . . . . . . . . . . . .  interpret QUIT-statement
**
**  'IntrQUIT' is the  action to interpret   a QUIT-statement.  It  is called
**  when the reader encounters a 'QUIT;'.
*/
void IntrQUIT(IntrState * intr);


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
void IntrOrL(IntrState * intr);

void IntrOr(IntrState * intr);


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
void IntrAndL(IntrState * intr);

void IntrAnd(IntrState * intr);


/****************************************************************************
**
*F  IntrNot() . . . . . . . . . . . . . . . . . . .  interpret not-expression
**
**  'IntrNot' is the action to interpret a not-expression.  It is called when
**  the reader encounters a not-expression, *after* the operand is read.
*/
void IntrNot(IntrState * intr);


/****************************************************************************
**
*F  IntrEq()  . . . . . . . . . . . . . . . . . . . .  interpret =-expression
*F  IntrNe()  . . . . . . . . . . . . . . . . . . . . interpret <>-expression
*F  IntrLt()  . . . . . . . . . . . . . . . . . . . . interpret  <-expression
*F  IntrGe()  . . . . . . . . . . . . . . . . . . . . interpret >=-expression
*F  IntrGt()  . . . . . . . . . . . . . . . . . . . . interpret >-expression
*F  IntrLe()  . . . . . . . . . . . . . . . . . . . . interpret <=-expression
**
**  'IntrEq', 'IntrNe', 'IntrLt', 'IntrGe', 'IntrGt',   and 'IntrLe' are  the
**  actions to interpret the respective operator expression.  They are called
**  by the reader *after* *both* operands are read.
*/
void IntrEq(IntrState * intr);

void IntrNe(IntrState * intr);

void IntrLt(IntrState * intr);

void IntrGe(IntrState * intr);

void IntrGt(IntrState * intr);

void IntrLe(IntrState * intr);


/****************************************************************************
**
*F  IntrIn()  . . . . . . . . . . . . . . . . . . . . interpret in-expression
**
**  'IntrIn'  is the action  to interpret an  in-expression.  It is called by
**  the reader *after* *both* operands are read.
*/
void IntrIn(IntrState * intr);


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
void IntrSum(IntrState * intr);

void IntrAInv(IntrState * intr);

void IntrDiff(IntrState * intr);

void IntrProd(IntrState * intr);

void IntrQuo(IntrState * intr);

void IntrMod(IntrState * intr);

void IntrPow(IntrState * intr);


/****************************************************************************
**
*F  IntrIntObjExpr(<val>)
*/
void IntrIntObjExpr(IntrState * intr, Obj val);


/****************************************************************************
**
*F  IntrIntExpr(<str>)  . . . . . . . .  interpret literal integer expression
**
**  'IntrIntExpr' is the action  to  interpret a literal  integer expression.
**  <str> is the integer as a (null terminated) C character string.
*/
void IntrIntExpr(IntrState * intr, Obj string, Char * str);


/****************************************************************************
**
*F  IntrFloatExpr(<str>)  . . . . . . . .  interpret literal float expression
**
**  'IntrFloatExpr' is the action  to  interpret a literal  float expression.
**  <str> is the float as a (null terminated) C character string.
*/
void IntrFloatExpr(IntrState * intr, Obj string, Char * str);


/****************************************************************************
**
*F  IntrTrueExpr()  . . . . . . . . . . . . interpret literal true expression
**
**  'IntrTrueExpr' is the action to interpret a literal true expression.
*/
void IntrTrueExpr(IntrState * intr);


/****************************************************************************
**
*F  IntrFalseExpr() . . . . . . . . . . .  interpret literal false expression
**
**  'IntrFalseExpr' is the action to interpret a literal false expression.
*/
void IntrFalseExpr(IntrState * intr);

/****************************************************************************
**
*F  IntrTildeExpr() . . . . . . . . . . . . . . . interpret tilde expression
**
**  'IntrTildeExpr' is the action to interpret a tilde expression.
*/
void IntrTildeExpr(IntrState * intr);

void IntrHelp(IntrState * intr, Obj topic);

/****************************************************************************
**
*F  IntrCharExpr(<chr>) . . . . . . .  interpret literal character expression
**
**  'IntrCharExpr' is the action to interpret a literal character expression.
**  <chr> is the C character.
*/
void IntrCharExpr(IntrState * intr, Char chr);


/****************************************************************************
**
*F  IntrPermCycle(<nr>) . . . . . .  interpret literal permutation expression
*F  IntrPerm(<nr>)  . . . . . . . .  interpret literal permutation expression
*/
void IntrPermCycle(IntrState * intr, UInt nrx, UInt nrc);

void IntrPerm(IntrState * intr, UInt nrc);


/****************************************************************************
**
*F  IntrListExprBegin(<top>)  . . . . . . . . . .  interpret list expr, begin
*F  IntrListExprBeginElm(<pos>) . . . . .  interpret list expr, begin element
*F  IntrListExprEndElm()  . . . . . . . . .  interpret list expr, end element
*F  IntrListExprEnd(<nr>,<range>,<top>,<tilde>) . .  interpret list expr, end
*/
void IntrListExprBegin(IntrState * intr, UInt top);

void IntrListExprBeginElm(IntrState * intr, UInt pos);

void IntrListExprEndElm(IntrState * intr);

void IntrListExprEnd(
    IntrState * intr, UInt nr, UInt range, UInt top, UInt tilde);


/****************************************************************************
**
*F  IntrStringExpr(<str>) . . . . . . . . interpret literal string expression
*/
void IntrStringExpr(IntrState * intr, Obj string);

void IntrPragma(IntrState * intr, Obj pragma);


/****************************************************************************
**
*F  IntrRecExprBegin(<top>) . . . . . . . . . .  interpret record expr, begin
*F  IntrRecExprBeginElmName(<rnam>) . .  interpret record expr, begin element
*F  IntrRecExprBeginElmExpr() . . . . .  interpret record expr, begin element
*F  IntrRecExprEndElmExpr() . . . . . . .  interpret record expr, end element
*F  IntrRecExprEnd(<nr>,<top>,<tilde>)  . . . . .  interpret record expr, end
*/
void IntrRecExprBegin(IntrState * intr, UInt top);

void IntrRecExprBeginElmName(IntrState * intr, UInt rnam);

void IntrRecExprBeginElmExpr(IntrState * intr);

void IntrRecExprEndElm(IntrState * intr);

void IntrRecExprEnd(IntrState * intr, UInt nr, UInt top, UInt tilde);


/****************************************************************************
**
*F  IntrAssLVar(<lvar>) . . . . . . . . . . . . interpret assignment to local
*/
void IntrAssLVar(IntrState * intr, UInt lvar);

void IntrUnbLVar(IntrState * intr, UInt lvar);


/****************************************************************************
**
*F  IntrRefLVar(<lvar>) . . . . . . . . . . . .  interpret reference to local
*/
void IntrRefLVar(IntrState * intr, UInt lvar);

void IntrIsbLVar(IntrState * intr, UInt lvar);


/****************************************************************************
**
*F  IntrAssHVar(<hvar>) . . . . . . . . . . .  interpret assignment to higher
*/
void IntrAssHVar(IntrState * intr, UInt hvar);

void IntrUnbHVar(IntrState * intr, UInt hvar);


/****************************************************************************
**
*F  IntrRefHVar(<hvar>) . . . . . . . . . . . . interpret reference to higher
*/
void IntrRefHVar(IntrState * intr, UInt hvar);

void IntrIsbHVar(IntrState * intr, UInt hvar);


/****************************************************************************
**
*F  IntrAssDVar(<dvar>) . . . . . . . . . . . . interpret assignment to debug
*/
void IntrAssDVar(IntrState * intr, UInt dvar, UInt depth);

void IntrUnbDVar(IntrState * intr, UInt dvar, UInt depth);


/****************************************************************************
**
*F  IntrRefDVar(<dvar>) . . . . . . . . . . . .  interpret reference to debug
*/
void IntrRefDVar(IntrState * intr, UInt dvar, UInt depth);

void IntrIsbDVar(IntrState * intr, UInt dvar, UInt depth);


/****************************************************************************
**
*F  IntrAssGVar(<gvar>) . . . . . . . . . . .  interpret assignment to global
*/
void IntrAssGVar(IntrState * intr, UInt gvar);

void IntrUnbGVar(IntrState * intr, UInt gvar);


/****************************************************************************
**
*F  IntrRefGVar(<gvar>) . . . . . . . . . . . . interpret reference to global
*/
void IntrRefGVar(IntrState * intr, UInt gvar);

void IntrIsbGVar(IntrState * intr, UInt gvar);


/****************************************************************************
**
*F  IntrAssList() . . . . . . . . . . . . . .  interpret assignment to a list
*F  IntrAsssList()  . . . . . . . . . interpret multiple assignment to a list
*F  IntrAssListLevel(<level>) . . . . . interpret assignment to several lists
*F  IntrAsssListLevel(<level>)  . . intr multiple assignment to several lists
*/
void IntrAssList(IntrState * intr, Int narg);

void IntrAsssList(IntrState * intr);

void IntrAssListLevel(IntrState * intr, Int narg, UInt level);

void IntrAsssListLevel(IntrState * intr, UInt level);

void IntrUnbList(IntrState * intr, Int narg);


/****************************************************************************
**
*F  IntrElmList() . . . . . . . . . . . . . . . interpret selection of a list
*F  IntrElmsList()  . . . . . . . . .  interpret multiple selection of a list
*F  IntrElmListLevel(<level>) . . . . .  interpret selection of several lists
*F  IntrElmsListLevel(<level>)  . .  intr multiple selection of several lists
*/
void IntrElmList(IntrState * intr, Int narg);

void IntrElmsList(IntrState * intr);

void IntrElmListLevel(IntrState * intr, Int narg, UInt level);

void IntrElmsListLevel(IntrState * intr, UInt level);

void IntrIsbList(IntrState * intr, Int narg);


/****************************************************************************
**
*F  IntrAssRecName(<rnam>)  . . . . . . . .  interpret assignment to a record
*F  IntrAssRecExpr()  . . . . . . . . . . .  interpret assignment to a record
*/
void IntrAssRecName(IntrState * intr, UInt rnam);

void IntrAssRecExpr(IntrState * intr);

void IntrUnbRecName(IntrState * intr, UInt rnam);

void IntrUnbRecExpr(IntrState * intr);


/****************************************************************************
**
*F  IntrElmRecName(<rnam>)  . . . . . . . . . interpret selection of a record
*F  IntrElmRecExpr()  . . . . . . . . . . . . interpret selection of a record
*/
void IntrElmRecName(IntrState * intr, UInt rnam);

void IntrElmRecExpr(IntrState * intr);

void IntrIsbRecName(IntrState * intr, UInt rnam);

void IntrIsbRecExpr(IntrState * intr);


/****************************************************************************
**
*F  IntrAssPosObj() . . . . . . . . . . . .  interpret assignment to a posobj
*/
void IntrAssPosObj(IntrState * intr);

void IntrUnbPosObj(IntrState * intr);


/****************************************************************************
**
*F  IntrElmPosObj() . . . . . . . . . . . . . interpret selection of a posobj
*/
void IntrElmPosObj(IntrState * intr);

void IntrIsbPosObj(IntrState * intr);


/****************************************************************************
**
*F  IntrAssComObjName(<rnam>) . . . . . . .  interpret assignment to a comobj
*F  IntrAssComObjExpr() . . . . . . . . . .  interpret assignment to a comobj
*/
void IntrAssComObjName(IntrState * intr, UInt rnam);

void IntrAssComObjExpr(IntrState * intr);

void IntrUnbComObjName(IntrState * intr, UInt rnam);

void IntrUnbComObjExpr(IntrState * intr);


/****************************************************************************
**
*F  IntrElmComObjName(<rnam>) . . . . . . . . interpret selection of a comobj
*F  IntrElmComObjExpr() . . . . . . . . . . . interpret selection of a comobj
*/
void IntrElmComObjName(IntrState * intr, UInt rnam);

void IntrElmComObjExpr(IntrState * intr);

void IntrIsbComObjName(IntrState * intr, UInt rnam);

void IntrIsbComObjExpr(IntrState * intr);

/****************************************************************************
**
*F  IntrEmpty() . . . . . . . . . . . . .  Interpret an empty statement body
**
*/
void IntrEmpty(IntrState * intr);

/****************************************************************************
**
*F  IntrInfoBegin() . . . . . . . . .  start interpretation of Info statement
*F  IntrInfoMiddle() . . . . . . .  shift to interpreting printable arguments
*F  IntrInfoEnd( <narg> ) . . Info statement complete, <narg> things to print
*/

void IntrInfoBegin(IntrState * intr);
void IntrInfoMiddle(IntrState * intr);
void IntrInfoEnd(IntrState * intr, UInt narg);


/****************************************************************************
**
*F  IntrAssertBegin() . . . . . . .  start interpretation of Assert statement
*F  IntrAsseerAfterLevel()  . . called after the first argument has been read
**
**  At this stage, we can decide whether to evaluate the second argument --
**   the check in question
**
*F  IntrAssertAfterCondition() called after the second argument has been read
**
**  At this point we know whether there is an assertion failure. We still
**  need to read the third argument if any, to decide what to do about it.
**
*F  IntrAssertEnd2Args() . . . . called after reading the closing parenthesis
*F  IntrAssertEnd3Args() . . . . called after reading the closing parenthesis
*/

void IntrAssertBegin(IntrState * intr);
void IntrAssertAfterLevel(IntrState * intr);
void IntrAssertAfterCondition(IntrState * intr);
void IntrAssertEnd2Args(IntrState * intr);
void IntrAssertEnd3Args(IntrState * intr);


/****************************************************************************
**
*F  IntrContinue() . . . . . . . . . . . . . . . interpret continue-statement
*/
void IntrContinue(IntrState * intr);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoIntrprtr()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoIntrprtr ( void );


#endif // GAP_INTRPRTR_H
