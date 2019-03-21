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

#include "system.h"
#include "gap.h"

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
/* TL: extern UInt IntrIgnoring; */


/****************************************************************************
**
*V  IntrCoding  . . . . . . . . . . . interpreter is currently coding actions
**
**  If 'IntrCoding' is non-zero, the interpreter is currently coding actions.
**  The interpreter  switches  to this  mode for  constructs  that it  cannot
**  directly interpret, such as loops or function bodies.
*/
/* TL: extern UInt IntrCoding; */

/****************************************************************************
**
*V  IntrReturning  . . . . . . . interpreter is currently exiting statements
**                                 enclosing a return;
**
**  If 'IntrReturning' is non-zero, the interpreter is currently exiting
**  statements enclosing a return statement. Actions from these statements
**  are ignored.
*/
/* TL: extern UInt IntrReturning; */

/****************************************************************************
**
*F  IntrBegin() . . . . . . . . . . . . . . . . . . . .  start an interpreter
*F  IntrEnd(<error>,<result>)  . . . . . . . . . . . . .  stop an interpreter
**
**  'IntrBegin' starts a new interpreter in context <frame>. If in doubt,
**  pass STATE(BottomLVars) as <frame>
**
**  'IntrEnd' stops the current interpreter.
**
**  If <error>  is non-zero a  syntax error was found by  the reader, and the
**  interpreter only clears up the mess.
**
**  If 'IntrEnd' returns 'STATUS_END', then no return-statement or
**  quit-statement was interpreted. If 'IntrEnd' returns 'STATUS_RETURN_VAL',
**  then a return-value-statement was interpreted and in this case the return
**  value is assigned to the address <result> points at (but only if <result>
**  is not 0). If 'IntrEnd' returns 'STATUS_RETURN_VOID', then a
**  return-void-statement was interpreted. If 'IntrEnd' returns 'STATUS_QUIT',
**  then a quit-statement was interpreted.
*/
void IntrBegin(Obj frame);

ExecStatus IntrEnd(UInt error, Obj * result);


/****************************************************************************
**
*F  IntrAbortCoding(<lvars>) . . . . . . . . . . . . . . . . . . abort coding
**
**  'IntrAbortCoding' aborts coding, if it is active, and resets the active
**  lvars to <lvars>.
*/
void IntrAbortCoding(Obj lvars);


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
void IntrFuncCallBegin(void);

void IntrFuncCallEnd(UInt funccall, UInt options, UInt nr);

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
void IntrFuncCallOptionsBegin(void);

void IntrFuncCallOptionsBeginElmName(UInt rnam);

void IntrFuncCallOptionsBeginElmExpr(void);

void IntrFuncCallOptionsEndElm(void);

void IntrFuncCallOptionsEndElmEmpty(void);

void IntrFuncCallOptionsEnd(UInt nr);

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
void IntrFuncExprBegin(Int narg, Int nloc, Obj nams, Int startLine);

void IntrFuncExprEnd(UInt nr);


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
void IntrIfBegin(void);

void IntrIfElif(void);

void IntrIfElse(void);

void IntrIfBeginBody(void);

Int IntrIfEndBody(UInt nr);

void IntrIfEnd(UInt nr);


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
void IntrForBegin(void);

void IntrForIn(void);

void IntrForBeginBody(void);

void IntrForEndBody(UInt nr);

void IntrForEnd(void);


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
void IntrWhileBegin(void);

void IntrWhileBeginBody(void);

void IntrWhileEndBody(UInt nr);

void IntrWhileEnd(void);

void IntrQualifiedExprBegin(UInt access);

void IntrQualifiedExprEnd(void);


/****************************************************************************
**
*F  IntrAtomicBegin() . . . .  interpret atomic-statement, begin of statement
*F  IntrAtomicBeginBody() . . . . . interpret atomic-statement, begin of body
*F  IntrAtomicEndBody(<nr>) . . . . . interpret atomic-statement, end of body
*F  IntrAtomicEnd() . . . . . .  interpret atomic-statement, end of statement
**
**  'IntrAtomicBegin' is an action to interpret a atomic-statement. It is
**  called when the reader encounters the 'atomic', i.e., *before* the
**  condition is read.
**
**  'IntrAtomicBeginBody' is an action to interpret a atomic-statement. It is
**  called when the reader encounters the beginning of the statement body,
**  i.e., *after* the expressions to be locked have been read. <nrexprs> is
**  the number of such  expressions.
**
**  'IntrAtomicEndBody' is an action to interpret a atomic-statement. It is
**  called when the reader encounters the end of the statement body. <nr> is
**  the number of statements in the body.
**
**  'IntrAtomicEnd' is an action to interpret a atomic-statement. It is
**  called when the reader encounters the end of the statement, i.e.,
**  lyimmediate after 'IntrAtomicEndBody'.
**
**  These functions only do something meaningful inside HPC-GAP; otherwise,
**  they are simply placeholders.
*/

void IntrAtomicBegin(void);

void IntrAtomicBeginBody(UInt nrexprs);

void IntrAtomicEndBody(Int nrstats);

void IntrAtomicEnd(void);

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
void IntrRepeatBegin(void);

void IntrRepeatBeginBody(void);

void IntrRepeatEndBody(UInt nr);

void IntrRepeatEnd(void);


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
void IntrBreak(void);


/****************************************************************************
**
*F  IntrReturnObj() . . . . . . . . . . . .  interpret return-value-statement
**
**  'IntrReturnObj' is the action  to interpret a return-value-statement.  It
**  is  called when  the reader encounters  a  'return  <expr>;', but *after*
**  reading the expression <expr>.
*/
void IntrReturnObj(void);


/****************************************************************************
**
*F  IntrReturnVoid()  . . . . . . . . . . . . interpret return-void-statement
**
**  'IntrReturnVoid' is the action to interpret  a return-void-statement.  It
**  is called when the reader encounters a 'return;'.
*/
void IntrReturnVoid(void);


/****************************************************************************
**
*F  IntrQuit()  . . . . . . . . . . . . . . . . . .  interpret quit-statement
**
**  'IntrQuit' is the  action to interpret   a quit-statement.  It  is called
**  when the reader encounters a 'quit;'.
*/
void IntrQuit(void);

/****************************************************************************
**
*F  IntrQUIT()  . . . . . . . . . . . . . . . . . .  interpret QUIT-statement
**
**  'IntrQUIT' is the  action to interpret   a QUIT-statement.  It  is called
**  when the reader encounters a 'QUIT;'.
*/
void IntrQUIT(void);


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
void IntrOrL(void);

void IntrOr(void);


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
void IntrAndL(void);

void IntrAnd(void);


/****************************************************************************
**
*F  IntrNot() . . . . . . . . . . . . . . . . . . .  interpret not-expression
**
**  'IntrNot' is the action to interpret a not-expression.  It is called when
**  the reader encounters a not-expression, *after* the operand is read.
*/
void IntrNot(void);


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
void IntrEq(void);

void IntrNe(void);

void IntrLt(void);

void IntrGe(void);

void IntrGt(void);

void IntrLe(void);


/****************************************************************************
**
*F  IntrIn()  . . . . . . . . . . . . . . . . . . . . interpret in-expression
**
**  'IntrIn'  is the action  to interpret an  in-expression.  It is called by
**  the reader *after* *both* operands are read.
*/
void IntrIn(void);


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
void IntrSum(void);

void IntrAInv(void);

void IntrDiff(void);

void IntrProd(void);

void IntrQuo(void);

void IntrMod(void);

void IntrPow(void);


/****************************************************************************
**
*F  IntrIntObjExpr(<val>)
*/
void IntrIntObjExpr(Obj val);


/****************************************************************************
**
*F  IntrIntExpr(<str>)  . . . . . . . .  interpret literal integer expression
**
**  'IntrIntExpr' is the action  to  interpret a literal  integer expression.
**  <str> is the integer as a (null terminated) C character string.
*/
void IntrIntExpr(Obj string, Char * str);


/****************************************************************************
**
*F  IntrFloatExpr(<str>)  . . . . . . . .  interpret literal float expression
**
**  'IntrFloatExpr' is the action  to  interpret a literal  float expression.
**  <str> is the float as a (null terminated) C character string.
*/
void IntrFloatExpr(Obj string, Char * str);


/****************************************************************************
**
*F  IntrTrueExpr()  . . . . . . . . . . . . interpret literal true expression
**
**  'IntrTrueExpr' is the action to interpret a literal true expression.
*/
void IntrTrueExpr(void);


/****************************************************************************
**
*F  IntrFalseExpr() . . . . . . . . . . .  interpret literal false expression
**
**  'IntrFalseExpr' is the action to interpret a literal false expression.
*/
void IntrFalseExpr(void);

/****************************************************************************
**
*F  IntrTildeExpr() . . . . . . . . . . . . . . . interpret tilde expression
**
**  'IntrTildeExpr' is the action to interpret a tilde expression.
*/
void IntrTildeExpr(void);

void IntrHelp(Obj topic);

/****************************************************************************
**
*F  IntrCharExpr(<chr>) . . . . . . .  interpret literal character expression
**
**  'IntrCharExpr' is the action to interpret a literal character expression.
**  <chr> is the C character.
*/
void IntrCharExpr(Char chr);


/****************************************************************************
**
*F  IntrPermCycle(<nr>) . . . . . .  interpret literal permutation expression
*F  IntrPerm(<nr>)  . . . . . . . .  interpret literal permutation expression
*/
void IntrPermCycle(UInt nrx, UInt nrc);

void IntrPerm(UInt nrc);


/****************************************************************************
**
*F  IntrListExprBegin(<top>)  . . . . . . . . . .  interpret list expr, begin
*F  IntrListExprBeginElm(<pos>) . . . . .  interpret list expr, begin element
*F  IntrListExprEndElm()  . . . . . . . . .  interpret list expr, end element
*F  IntrListExprEnd(<nr>,<range>,<top>,<tilde>) . .  interpret list expr, end
*/
void IntrListExprBegin(UInt top);

void IntrListExprBeginElm(UInt pos);

void IntrListExprEndElm(void);

void IntrListExprEnd(UInt nr, UInt range, UInt top, UInt tilde);


/****************************************************************************
**
*F  IntrStringExpr(<str>) . . . . . . . . interpret literal string expression
*/
void IntrStringExpr(Obj string);

void IntrPragma(Obj pragma);


/****************************************************************************
**
*F  IntrRecExprBegin(<top>) . . . . . . . . . .  interpret record expr, begin
*F  IntrRecExprBeginElmName(<rnam>) . .  interpret record expr, begin element
*F  IntrRecExprBeginElmExpr() . . . . .  interpret record expr, begin element
*F  IntrRecExprEndElmExpr() . . . . . . .  interpret record expr, end element
*F  IntrRecExprEnd(<nr>,<top>,<tilde>)  . . . . .  interpret record expr, end
*/
void IntrRecExprBegin(UInt top);

void IntrRecExprBeginElmName(UInt rnam);

void IntrRecExprBeginElmExpr(void);

void IntrRecExprEndElm(void);

void IntrRecExprEnd(UInt nr, UInt top, UInt tilde);


/****************************************************************************
**
*F  IntrAssLVar(<lvar>) . . . . . . . . . . . . interpret assignment to local
*/
void IntrAssLVar(UInt lvar);

void IntrUnbLVar(UInt lvar);


/****************************************************************************
**
*F  IntrRefLVar(<lvar>) . . . . . . . . . . . .  interpret reference to local
*/
void IntrRefLVar(UInt lvar);

void IntrIsbLVar(UInt lvar);


/****************************************************************************
**
*F  IntrAssHVar(<hvar>) . . . . . . . . . . .  interpret assignment to higher
*/
void IntrAssHVar(UInt hvar);

void IntrUnbHVar(UInt hvar);


/****************************************************************************
**
*F  IntrRefHVar(<hvar>) . . . . . . . . . . . . interpret reference to higher
*/
void IntrRefHVar(UInt hvar);

void IntrIsbHVar(UInt hvar);


/****************************************************************************
**
*F  IntrAssDVar(<dvar>) . . . . . . . . . . . . interpret assignment to debug
*/
void IntrAssDVar(UInt dvar, UInt depth);

void IntrUnbDVar(UInt dvar, UInt depth);


/****************************************************************************
**
*F  IntrRefDVar(<dvar>) . . . . . . . . . . . .  interpret reference to debug
*/
void IntrRefDVar(UInt dvar, UInt depth);

void IntrIsbDVar(UInt dvar, UInt depth);


/****************************************************************************
**
*F  IntrAssGVar(<gvar>) . . . . . . . . . . .  interpret assignment to global
*/
void IntrAssGVar(UInt gvar);

void IntrUnbGVar(UInt gvar);


/****************************************************************************
**
*F  IntrRefGVar(<gvar>) . . . . . . . . . . . . interpret reference to global
*/
void IntrRefGVar(UInt gvar);

void IntrIsbGVar(UInt gvar);


/****************************************************************************
**
*F  IntrAssList() . . . . . . . . . . . . . .  interpret assignment to a list
*F  IntrAsssList()  . . . . . . . . . interpret multiple assignment to a list
*F  IntrAssListLevel(<level>) . . . . . interpret assignment to several lists
*F  IntrAsssListLevel(<level>)  . . intr multiple assignment to several lists
*/
void IntrAssList(Int narg);

void IntrAsssList(void);

void IntrAssListLevel(Int narg, UInt level);

void IntrAsssListLevel(UInt level);

void IntrUnbList(Int narg);


/****************************************************************************
**
*F  IntrElmList() . . . . . . . . . . . . . . . interpret selection of a list
*F  IntrElmsList()  . . . . . . . . .  interpret multiple selection of a list
*F  IntrElmListLevel(<level>) . . . . .  interpret selection of several lists
*F  IntrElmsListLevel(<level>)  . .  intr multiple selection of several lists
*/
void IntrElmList(Int narg);

void IntrElmsList(void);

void IntrElmListLevel(Int narg, UInt level);

void IntrElmsListLevel(UInt level);

void IntrIsbList(Int narg);


/****************************************************************************
**
*F  IntrAssRecName(<rnam>)  . . . . . . . .  interpret assignment to a record
*F  IntrAssRecExpr()  . . . . . . . . . . .  interpret assignment to a record
*/
void IntrAssRecName(UInt rnam);

void IntrAssRecExpr(void);

void IntrUnbRecName(UInt rnam);

void IntrUnbRecExpr(void);


/****************************************************************************
**
*F  IntrElmRecName(<rnam>)  . . . . . . . . . interpret selection of a record
*F  IntrElmRecExpr()  . . . . . . . . . . . . interpret selection of a record
*/
void IntrElmRecName(UInt rnam);

void IntrElmRecExpr(void);

void IntrIsbRecName(UInt rnam);

void IntrIsbRecExpr(void);


/****************************************************************************
**
*F  IntrAssPosObj() . . . . . . . . . . . .  interpret assignment to a posobj
*/
void IntrAssPosObj(void);

void IntrUnbPosObj(void);


/****************************************************************************
**
*F  IntrElmPosObj() . . . . . . . . . . . . . interpret selection of a posobj
*/
void IntrElmPosObj(void);

void IntrIsbPosObj(void);


/****************************************************************************
**
*F  IntrAssComObjName(<rnam>) . . . . . . .  interpret assignment to a comobj
*F  IntrAssComObjExpr() . . . . . . . . . .  interpret assignment to a comobj
*/
void IntrAssComObjName(UInt rnam);

void IntrAssComObjExpr(void);

void IntrUnbComObjName(UInt rnam);

void IntrUnbComObjExpr(void);


/****************************************************************************
**
*F  IntrElmComObjName(<rnam>) . . . . . . . . interpret selection of a comobj
*F  IntrElmComObjExpr() . . . . . . . . . . . interpret selection of a comobj
*/
void IntrElmComObjName(UInt rnam);

void IntrElmComObjExpr(void);

void IntrIsbComObjName(UInt rnam);

void IntrIsbComObjExpr(void);

/****************************************************************************
**
*F  IntrEmpty() . . . . . . . . . . . . .  Interpret an empty statement body
**
*/
void IntrEmpty(void);

/****************************************************************************
**
*F  IntrInfoBegin() . . . . . . . . .  start interpretation of Info statement
*F  IntrInfoMiddle() . . . . . . .  shift to interpreting printable arguments
*F  IntrInfoEnd( <narg> ) . . Info statement complete, <narg> things to print
*/

void IntrInfoBegin(void);
void IntrInfoMiddle(void);
void IntrInfoEnd(UInt narg);


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
**
*V  CurrentAssertionLevel . . . .  . . . . . . . . . . . copy of GAP variable
*/

void IntrAssertBegin(void);
void IntrAssertAfterLevel(void);
void IntrAssertAfterCondition(void);
void IntrAssertEnd2Args(void);
void IntrAssertEnd3Args(void);

extern Obj              CurrentAssertionLevel;

/****************************************************************************
**
*F  IntrSaveWSBegin() . . . . . . . . . . . . . Start interpreting a save WS
**
*F  IntrSaveWSEnd() . . . . . . . . . . . . . . Actually save the workspace
**
**  'IntrSaveWSBegin' is called when the reader starts reading a
**  SaveWorkspace command. 
*/

void IntrSaveWSBegin(void);

void IntrSaveWSEnd(void);

/****************************************************************************
**
*F  IntrContinue() . . . . . . . . . . . . . . . interpret continue-statement
*/
void IntrContinue(void);


/****************************************************************************
**
*F  PushVoidObj() . . . . . . . . . . . . . .  push void value onto the stack
*/
void PushVoidObj(void);


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
