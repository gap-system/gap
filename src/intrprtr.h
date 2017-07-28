/****************************************************************************
**
*W  intrprtr.h                  GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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


/****************************************************************************
**
*V  IntrResult  . . . . . . . . . . . . . . . . . result value of interpreter
**
**  'IntrResult'  is the result value of  the interpreter, i.e., the value of
**  the  statement  that  was  last  interpreted (which   might  have been  a
**  return-value-statement).
*/
/* TL: extern  Obj             IntrResult; */


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
*F  IntrEnd(<error>)  . . . . . . . . . . . . . . . . . . stop an interpreter
**
**  'IntrBegin( <frame> )' starts a new interpreter in context <frame>
**  if in doubt, pass STATE(BottomLVars) as <frame>
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
extern  void            IntrBegin ( Obj frame );

extern  ExecStatus             IntrEnd (
            UInt                error );


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
extern  void            IntrFuncCallBegin ( void );

extern  void            IntrFuncCallEnd (
            UInt                funccall,
	    UInt                options,
            UInt                nr );

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
extern void            IntrFuncCallOptionsBegin ( void );

extern void            IntrFuncCallOptionsBeginElmName ( UInt rnam );

extern void            IntrFuncCallOptionsBeginElmExpr ( void );

extern void            IntrFuncCallOptionsEndElm ( void );

extern void            IntrFuncCallOptionsEndElmEmpty ( void );

extern void            IntrFuncCallOptionsEnd ( UInt nr );

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
extern  void            IntrFuncExprBegin (
            Int                 narg,
            Int                 nloc,
            Obj                 nams,
	    Int                 startLine);

extern  void            IntrFuncExprEnd (
            UInt                nr,
            UInt                mapsto );


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
extern  void            IntrIfBegin ( void );

extern  void            IntrIfElif ( void );

extern  void            IntrIfElse ( void );

extern  void            IntrIfBeginBody ( void );

extern  void            IntrIfEndBody (
            UInt                nr );

extern  void            IntrIfEnd (
            UInt                nr );


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
extern  void            IntrForBegin ( void );

extern  void            IntrForIn ( void );

extern  void            IntrForBeginBody ( void );

extern  void            IntrForEndBody (
            UInt                nr );

extern  void            IntrForEnd ( void );


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
extern  void            IntrWhileBegin ( void );

extern  void            IntrWhileBeginBody ( void );

extern  void            IntrWhileEndBody (
            UInt                nr );

extern  void            IntrWhileEnd ( void );

extern void IntrQualifiedExprBegin( UInt access);

extern void IntrQualifiedExprEnd( void);


/****************************************************************************
**
*F  IntrAtomicBegin()  . . . . . interpret atomic-statement, begin of statement
*F  IntrAtomicBeginBody()  . . . . .  interpret atomic-statement, begin of body
*F  IntrAtomicEndBody(<nr>)  . . . . .  interpret atomic-statement, end of body
*F  IntrAtomicEnd()  . . . . . . . interpret atomic-statement, end of statement
**
**  'IntrAtomicBegin' is   an action to  interpret   a atomic-statement.  It is
**  called when the    reader encounters the    'atomic', i.e., *before*   the
**  condition is read.
**
**  'IntrAtomicBeginBody' is an action  to interpret a atomic-statement.  It is
**  called when the reader encounters  the  beginning of the statement  body,
**  i.e., *after* the expressions to be locked have been read. <nrexprs> is the number of such 
**  expressions
**
**  'IntrAtomicEndBody' is  an action to interpret   a atomic-statement.  It is
**  called when the reader encounters the end of the statement body.  <nr> is
**  the number of statements in the body.
**
**  'IntrAtomicEnd' is an action to interpret a atomic-statement.  It is called
**  when  the reader encounters  the  end of  the  statement, i.e., immediate
**  after 'IntrAtomicEndBody'.
**
**  These functions only do something meaningful inside HPC-GAP; in plain GAP,
**  they are simply placeholders.
*/

extern  void            IntrAtomicBegin ( void );

extern  void            IntrAtomicBeginBody ( UInt nrexprs );

extern  void            IntrAtomicEndBody (
            Int                nrstats );

extern  void            IntrAtomicEnd ( void );

#ifdef HPCGAP
/* TODO: move these constants to a more appropriate location */
enum {
    DEFAULT_LOCK_TYPE  = 1,
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
extern  void            IntrRepeatBegin ( void );

extern  void            IntrRepeatBeginBody ( void );

extern  void            IntrRepeatEndBody (
            UInt                nr );

extern  void            IntrRepeatEnd ( void );


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
extern  void            IntrBreak ( void );


/****************************************************************************
**
*F  IntrReturnObj() . . . . . . . . . . . .  interpret return-value-statement
**
**  'IntrReturnObj' is the action  to interpret a return-value-statement.  It
**  is  called when  the reader encounters  a  'return  <expr>;', but *after*
**  reading the expression <expr>.
*/
extern  void            IntrReturnObj ( void );


/****************************************************************************
**
*F  IntrReturnVoid()  . . . . . . . . . . . . interpret return-void-statement
**
**  'IntrReturnVoid' is the action to interpret  a return-void-statement.  It
**  is called when the reader encounters a 'return;'.
*/
extern  void            IntrReturnVoid ( void );


/****************************************************************************
**
*F  IntrQuit()  . . . . . . . . . . . . . . . . . .  interpret quit-statement
**
**  'IntrQuit' is the  action to interpret   a quit-statement.  It  is called
**  when the reader encounters a 'quit;'.
*/
extern  void            IntrQuit ( void );

/****************************************************************************
**
*F  IntrQUIT()  . . . . . . . . . . . . . . . . . .  interpret QUIT-statement
**
**  'IntrQUIT' is the  action to interpret   a QUIT-statement.  It  is called
**  when the reader encounters a 'QUIT;'.
*/
extern  void            IntrQUIT ( void );


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
extern  void            IntrOrL ( void );

extern  void            IntrOr ( void );


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
extern  void            IntrAndL ( void );

extern  void            IntrAnd ( void );


/****************************************************************************
**
*F  IntrNot() . . . . . . . . . . . . . . . . . . .  interpret not-expression
**
**  'IntrNot' is the action to interpret a not-expression.  It is called when
**  the reader encounters a not-expression, *after* the operand is read.
*/
extern  void            IntrNot ( void );


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
extern  void            IntrEq ( void );

extern  void            IntrNe ( void );

extern  void            IntrLt ( void );

extern  void            IntrGe ( void );

extern  void            IntrGt ( void );

extern  void            IntrLe ( void );


/****************************************************************************
**
*F  IntrIn()  . . . . . . . . . . . . . . . . . . . . interpret in-expression
**
**  'IntrIn'  is the action  to interpret an  in-expression.  It is called by
**  the reader *after* *both* operands are read.
*/
extern  void            IntrIn ( void );


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
extern  void            IntrSum ( void );

extern  void            IntrAInv ( void );

extern  void            IntrDiff ( void );

extern  void            IntrProd ( void );

extern  void            IntrInv ( void );

extern  void            IntrQuo ( void );

extern  void            IntrMod ( void );

extern  void            IntrPow ( void );


/****************************************************************************
**
*F  IntrIntExpr(<str>)  . . . . . . . .  interpret literal integer expression
**
**  'IntrIntExpr' is the action  to  interpret a literal  integer expression.
**  <str> is the integer as a (null terminated) C character string.
*/
extern  void            IntrIntExpr (
            Char *              str );
extern  void            IntrLongIntExpr (
            Obj                 string );

/****************************************************************************
**
*F  IntrFloatExpr(<str>)  . . . . . . . .  interpret literal float expression
**
**  'IntrFloatExpr' is the action  to  interpret a literal  float expression.
**  <str> is the float as a (null terminated) C character string.
*/
extern  void            IntrFloatExpr (
            Char *              str );
extern  void            IntrLongFloatExpr (
            Obj                 string );

/****************************************************************************
**
*F  IntrTrueExpr()  . . . . . . . . . . . . interpret literal true expression
**
**  'IntrTrueExpr' is the action to interpret a literal true expression.
*/
extern  void            IntrTrueExpr ( void );


/****************************************************************************
**
*F  IntrFalseExpr() . . . . . . . . . . .  interpret literal false expression
**
**  'IntrFalseExpr' is the action to interpret a literal false expression.
*/
extern  void            IntrFalseExpr ( void );

/****************************************************************************
**
*F  IntrTildeExpr() . . . . . . . . . . . . . . . interpret tilde expression
**
**  'IntrTildeExpr' is the action to interpret a tilde expression.
*/
extern  void            IntrTildeExpr ( void );

/****************************************************************************
**
*F  IntrCharExpr(<chr>) . . . . . . .  interpret literal character expression
**
**  'IntrCharExpr' is the action to interpret a literal character expression.
**  <chr> is the C character.
*/
extern  void            IntrCharExpr (
            Char                chr );


/****************************************************************************
**
*F  IntrPermCycle(<nr>) . . . . . .  interpret literal permutation expression
*F  IntrPerm(<nr>)  . . . . . . . .  interpret literal permutation expression
*/
extern  void            IntrPermCycle (
            UInt                nrx,
            UInt                nrc );

extern  void            IntrPerm (
            UInt                nrc );


/****************************************************************************
**
*F  IntrListExprBegin(<top>)  . . . . . . . . . .  interpret list expr, begin
*F  IntrListExprBeginElm(<pos>) . . . . .  interpret list expr, begin element
*F  IntrListExprEndElm()  . . . . . . . . .  interpret list expr, end element
*F  IntrListExprEnd(<nr>,<range>,<top>,<tilde>) . .  interpret list expr, end
*/
extern  void            IntrListExprBegin (
            UInt                top );

extern  void            IntrListExprBeginElm (
            UInt                pos );

extern  void            IntrListExprEndElm ( void );

extern  void            IntrListExprEnd (
            UInt                nr,
            UInt                range,
            UInt                top,
            UInt                tilde );


/****************************************************************************
**
*F  IntrStringExpr(<str>) . . . . . . . . interpret literal string expression
*/
extern  void            IntrStringExpr (
            Obj                 string );


/****************************************************************************
**
*F  IntrRecExprBegin(<top>) . . . . . . . . . .  interpret record expr, begin
*F  IntrRecExprBeginElmName(<rnam>) . .  interpret record expr, begin element
*F  IntrRecExprBeginElmExpr() . . . . .  interpret record expr, begin element
*F  IntrRecExprEndElmExpr() . . . . . . .  interpret record expr, end element
*F  IntrRecExprEnd(<nr>,<top>,<tilde>)  . . . . .  interpret record expr, end
*/
extern  void            IntrRecExprBegin (
            UInt                top );

extern  void            IntrRecExprBeginElmName (
            UInt                rnam );

extern  void            IntrRecExprBeginElmExpr ( void );

extern  void            IntrRecExprEndElm ( void );

extern  void            IntrRecExprEnd (
            UInt                nr,
            UInt                top,
            UInt                tilde );


/****************************************************************************
**
*F  IntrAssLVar(<lvar>) . . . . . . . . . . . . interpret assignment to local
*/
extern  void            IntrAssLVar (
            UInt                lvar );

extern  void            IntrUnbLVar (
            UInt                lvar );


/****************************************************************************
**
*F  IntrRefLVar(<lvar>) . . . . . . . . . . . .  interpret reference to local
*/
extern  void            IntrRefLVar (
            UInt                lvar );

extern  void            IntrIsbLVar (
            UInt                lvar );


/****************************************************************************
**
*F  IntrAssHVar(<hvar>) . . . . . . . . . . .  interpret assignment to higher
*/
extern  void            IntrAssHVar (
            UInt                hvar );

extern  void            IntrUnbHVar (
            UInt                hvar );


/****************************************************************************
**
*F  IntrRefHVar(<hvar>) . . . . . . . . . . . . interpret reference to higher
*/
extern  void            IntrRefHVar (
            UInt                hvar );

extern  void            IntrIsbHVar (
            UInt                hvar );


/****************************************************************************
**
*F  IntrAssDVar(<dvar>) . . . . . . . . . . . . interpret assignment to debug
*/
extern  void            IntrAssDVar (
            UInt                dvar,
            UInt                depth );

extern  void            IntrUnbDVar (
            UInt                dvar,
            UInt                depth );


/****************************************************************************
**
*F  IntrRefDVar(<dvar>) . . . . . . . . . . . .  interpret reference to debug
*/
extern  void            IntrRefDVar (
            UInt                dvar,
            UInt                depth );

extern  void            IntrIsbDVar (
            UInt                dvar,
            UInt                depth );


/****************************************************************************
**
*F  IntrAssGVar(<gvar>) . . . . . . . . . . .  interpret assignment to global
*/
extern  void            IntrAssGVar (
            UInt                gvar );

extern  void            IntrUnbGVar (
            UInt                gvar );


/****************************************************************************
**
*F  IntrRefGVar(<gvar>) . . . . . . . . . . . . interpret reference to global
*/
extern  void            IntrRefGVar (
            UInt                gvar );

extern  void            IntrIsbGVar (
            UInt                gvar );


/****************************************************************************
**
*F  IntrAssList() . . . . . . . . . . . . . .  interpret assignment to a list
*F  IntrAsssList()  . . . . . . . . . interpret multiple assignment to a list
*F  IntrAssListLevel(<level>) . . . . . interpret assignment to several lists
*F  IntrAsssListLevel(<level>)  . . intr multiple assignment to several lists
*/
extern  void            IntrAssList ( Int narg );

extern  void            IntrAsssList ( void );

extern  void            IntrAssListLevel ( Int narg,
            UInt                level );

extern  void            IntrAsssListLevel (
            UInt                level );

extern  void            IntrUnbList (Int narg );


/****************************************************************************
**
*F  IntrElmList() . . . . . . . . . . . . . . . interpret selection of a list
*F  IntrElmsList()  . . . . . . . . .  interpret multiple selection of a list
*F  IntrElmListLevel(<level>) . . . . .  interpret selection of several lists
*F  IntrElmsListLevel(<level>)  . .  intr multiple selection of several lists
*/
extern  void            IntrElmList ( Int narg);

extern  void            IntrElmsList ( void );

extern  void            IntrElmListLevel ( Int narg,
            UInt                level );

extern  void            IntrElmsListLevel (
            UInt                level );

extern  void            IntrIsbList ( Int narg );


/****************************************************************************
**
*F  IntrAssRecName(<rnam>)  . . . . . . . .  interpret assignment to a record
*F  IntrAssRecExpr()  . . . . . . . . . . .  interpret assignment to a record
*/
extern  void            IntrAssRecName (
            UInt                rnam );

extern  void            IntrAssRecExpr ( void );

extern  void            IntrUnbRecName (
            UInt                rnam );

extern  void            IntrUnbRecExpr ( void );


/****************************************************************************
**
*F  IntrElmRecName(<rnam>)  . . . . . . . . . interpret selection of a record
*F  IntrElmRecExpr()  . . . . . . . . . . . . interpret selection of a record
*/
extern  void            IntrElmRecName (
            UInt                rnam );

extern  void            IntrElmRecExpr ( void );

extern  void            IntrIsbRecName (
            UInt                rnam );

extern  void            IntrIsbRecExpr ( void );


/****************************************************************************
**
*F  IntrAssPosObj() . . . . . . . . . . . . . .  interpret assignment to a list
*F  IntrAsssPosObj()  . . . . . . . . . interpret multiple assignment to a list
*F  IntrAssPosObjLevel(<level>) . . . . . interpret assignment to several lists
*F  IntrAsssPosObjLevel(<level>)  . . intr multiple assignment to several lists
*/
extern  void            IntrAssPosObj ( void );

extern  void            IntrAsssPosObj ( void );

extern  void            IntrAssPosObjLevel (
            UInt                level );

extern  void            IntrAsssPosObjLevel (
            UInt                level );

extern  void            IntrUnbPosObj ( void );


/****************************************************************************
**
*F  IntrElmPosObj() . . . . . . . . . . . . . . . interpret selection of a list
*F  IntrElmsPosObj()  . . . . . . . . .  interpret multiple selection of a list
*F  IntrElmPosObjLevel(<level>) . . . . .  interpret selection of several lists
*F  IntrElmsPosObjLevel(<level>)  . .  intr multiple selection of several lists
*/
extern  void            IntrElmPosObj ( void );

extern  void            IntrElmsPosObj ( void );

extern  void            IntrElmPosObjLevel (
            UInt                level );

extern  void            IntrElmsPosObjLevel (
            UInt                level );

extern  void            IntrIsbPosObj ( void );


/****************************************************************************
**
*F  IntrAssComObjName(<rnam>) . . . . . . . .  interpret assignment to a record
*F  IntrAssComObjExpr() . . . . . . . . . . .  interpret assignment to a record
*/
extern  void            IntrAssComObjName (
            UInt                rnam );

extern  void            IntrAssComObjExpr ( void );

extern  void            IntrUnbComObjName (
            UInt                rnam );

extern  void            IntrUnbComObjExpr ( void );


/****************************************************************************
**
*F  IntrElmComObjName(<rnam>) . . . . . . . . . interpret selection of a record
*F  IntrElmComObjExpr() . . . . . . . . . . . . interpret selection of a record
*/
extern  void            IntrElmComObjName (
            UInt                rnam );

extern  void            IntrElmComObjExpr ( void );

extern  void            IntrIsbComObjName (
            UInt                rnam );

extern  void            IntrIsbComObjExpr ( void );

/****************************************************************************
**
*F  IntrEmpty() . . . . . . . . . . . . .  Interpret an empty statement body
**
*/

extern void             IntrEmpty ( void );

/****************************************************************************
**
*F  IntrInfoBegin() . . . . . . . . .  start interpretation of Info statement
*F  IntrInfoMiddle()  . . . . . .  shift to interpreting printable arguments
*F  IntrInfoEnd( <narg> ) . . Info statement complete, <narg> things to print
*V  InfoCheckLevel(<selectors>,<level>) . . . . . check if Info should output
*V  InfoDoPrint  . . . . . . . . . . .  fopy of the InfoDoPrint GAP function
*/

extern void             IntrInfoBegin ( void );
extern void             IntrInfoMiddle( void );
extern void             IntrInfoEnd   (
           UInt                   narg );
extern Obj              InfoCheckLevel(Obj, Obj);
extern Obj              InfoDoPrint;


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
**  At this point we know whether there is an assertion failure. We still need
**  to read the third argument if any, to decide what to do about it One of:
**
*F  IntrAssertEnd2Args() . . . .  called after reading the closing parenthesis
*F  IntrAssertEnd3Args() . . . .  called after reading the closing parenthesis
**
*V  CurrentAssertionLevel . . . .  . . . . . . . . . . . . copy of GAP variable
*/

extern void             IntrAssertBegin ( void );
extern void             IntrAssertAfterLevel ( void );
extern void             IntrAssertAfterCondition ( void );
extern void             IntrAssertEnd2Args ( void );
extern void             IntrAssertEnd3Args ( void );

extern Obj              CurrentAssertionLevel;

/****************************************************************************
**
*F  IntrSaveWSBegin() . . . . . . . . . . . . . Start interpeting a save WS
**
*F  IntrSaveWSEnd() . . . . . . . . . . . . . . Actually save the workspace
**
**  'IntrSaveWSBegin' is called when the reader starts reading a
**  SaveWorkspace command. 
*/

extern void              IntrSaveWSBegin ( void );

extern void              IntrSaveWSEnd ( void );     

/****************************************************************************
*F  IntrContinue() . . . . . . . . . . . . . . . interpret continue-statement
*/
extern void            IntrContinue ( void );

/****************************************************************************
*F  PushVoidObj() . . . . . . . . . . . . . .  push void value onto the stack
*/
extern void            PushVoidObj ( void );

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoIntrprtr()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoIntrprtr ( void );


#endif // GAP_INTRPRTR_H
