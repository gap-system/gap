/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the expressions package.
**
**  The expressions  package is the  part  of the interpreter  that evaluates
**  expressions to their values and prints expressions.
*/

#include "exprs.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "code.h"
#include "error.h"
#include "gapstate.h"
#include "gvars.h"
#include "hookintrprtr.h"
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
#include "vars.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#endif

/****************************************************************************
**
*V  EvalExprFuncs[<type>]  . . . . . evaluator for expressions of type <type>
**
**  'EvalExprFuncs'  is the dispatch table   that contains for  every type of
**  expressions a pointer  to the  evaluator  for expressions of this   type,
**  i.e., the function that should be  called to evaluate expressions of this
**  type.
*/
EvalExprFunc EvalExprFuncs[256];


/****************************************************************************
**
*V  EvalBoolFuncs[<type>] . . boolean evaluator for expression of type <type>
**
**  'EvalBoolFuncs'  is  the dispatch table that  contains  for every type of
**  expression a pointer to a boolean evaluator for expressions of this type,
**  i.e., a pointer to  a function which  is  guaranteed to return a  boolean
**  value that should be called to evaluate expressions of this type.
*/
EvalBoolFunc EvalBoolFuncs[256];


/****************************************************************************
**
*F  EvalUnknownExpr(<expr>) . . . . . . . evaluate expression of unknown type
**
**  'EvalUnknownExpr' is the evaluator that  is called if  an attempt is made
**  to  evaluate an  expression  <expr> of  an  unknown type.   It signals an
**  error.  If this is ever called, then  GAP is in  serious trouble, such as
**  an overwritten type field of an expression.
*/
static Obj EvalUnknownExpr(Expr expr)
{
    Pr("Panic: tried to evaluate an expression of unknown type '%d'\n",
       (Int)TNUM_EXPR(expr), 0);
    return 0;
}


/****************************************************************************
**
*F  EvalUnknownBool(<expr>) . . . . boolean evaluator for general expressions
**
**  'EvalUnknownBool' evaluates   the expression <expr>  (using 'EVAL_EXPR'),
**  and checks that the value is either 'true' or 'false'.  If the expression
**  does not evaluate to 'true' or 'false', then an error is signalled.
**
**  This is the default function in 'EvalBoolFuncs' used for expressions that
**  are   not a priori    known  to evaluate  to a    boolean value  (such as
**  function calls).
*/
static Obj EvalUnknownBool(Expr expr)
{
    Obj                 val;            /* value, result                   */

    /* evaluate the expression                                             */
    val = EVAL_EXPR( expr );

    /* check that the value is either 'true' or 'false'                    */
    if (val != True && val != False) {
        RequireArgumentEx(0, val, "<expr>", "must be 'true' or 'false'");
    }

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalOr(<expr>)  . . . . . . . . . . . . . evaluate a boolean or operation
**
**  'EvalOr' evaluates the or-expression <expr> and  returns its value, i.e.,
**  'true'  if  either of  the operands  is  'true',  and 'false'  otherwise.
**  'EvalOr'  is   called from  'EVAL_EXPR' to  evaluate  expressions of type
**  'EXPR_OR'.
**
**  If '<expr>.left'  is   already  'true' 'EvalOr'  returns  'true'  without
**  evaluating '<expr>.right'.  This allows constructs like
**
**      if (index > max) or (list[index] = 0)  then ... fi;
*/
static Obj EvalOr(Expr expr)
{
    Obj                 opL;            /* evaluated left operand          */
    Expr                tmp;            /* temporary expression            */

    /* evaluate and test the left operand                                  */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_BOOL_EXPR( tmp );
    if ( opL != False ) {
        return True;
    }

    /* evaluate and test the right operand                                 */
    tmp = READ_EXPR(expr, 1);
    return EVAL_BOOL_EXPR( tmp );
}


/****************************************************************************
**
*F  EvalAnd(<expr>) . . . . . . . . . . . .  evaluate a boolean and operation
**
**  'EvalAnd'  evaluates  the and-expression <expr>   and  returns its value,
**  i.e.,   'true'  if both  operands  are   'true',  and  'false' otherwise.
**  'EvalAnd' is called from   'EVAL_EXPR' to  evaluate expressions  of  type
**  'EXPR_AND'.
**
**  If '<expr>.left' is  already  'false' 'EvalAnd' returns 'false'   without
**  evaluating '<expr>.right'.  This allows constructs like
**
**      if (index <= max) and (list[index] = 0)  then ... fi;
*/
static Obj EvalAnd(Expr expr)
{
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* if the left operand is 'false', this is the result                  */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    if      ( opL == False ) {
        return opL;
    }

    /* if the left operand is 'true', the result is the right operand      */
    else if ( opL == True  ) {
        tmp = READ_EXPR(expr, 1);
        return EVAL_BOOL_EXPR( tmp );
    }

    /* handle the 'and' of two filters                                    */
    else if (IS_FILTER(opL)) {
        tmp = READ_EXPR(expr, 1);
        opR = EVAL_EXPR( tmp );
        return NewAndFilter(opL, opR);
    }
    
    /* signal an error                                                     */
    else {
        RequireArgumentEx(0, opL, "<expr>",
                          "must be 'true' or 'false' or a filter");
    }
    
    /* please 'lint'                                                       */
    return 0;
}


/****************************************************************************
**
*F  EvalNot(<expr>) . . . . . . . . . . . . . . . . .  negate a boolean value
**
**  'EvalNot'  evaluates the  not-expression  <expr>  and returns its  value,
**  i.e., 'true' if the operand is 'false', and 'false' otherwise.  'EvalNot'
**  is called from 'EVAL_EXPR' to evaluate expressions of type 'EXPR_NOT'.
*/
static Obj EvalNot(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 op;             /* evaluated operand               */
    Expr                tmp;            /* temporary expression            */

    /* evaluate the operand to a boolean                                   */
    tmp = READ_EXPR(expr, 0);
    op = EVAL_BOOL_EXPR( tmp );

    /* compute the negation                                                */
    val = (op == False ? True : False);

    /* return the negated value                                            */
    return val;
}


/****************************************************************************
**
*F  EvalEq(<expr>)  . . . . . . . . . . . . . . . . . . evaluate a comparison
**
**  'EvalEq' evaluates the  equality-expression <expr> and returns its value,
**  i.e.,  'true' if  the  operand '<expr>.left'   is equal  to  the  operand
**  '<expr>.right'   and   'false'  otherwise.   'EvalEq'  is   called   from
**  'EVAL_EXPR' to evaluate expressions of type 'EXPR_EQ'.
**
**  'EvalEq' evaluates the operands and then calls the 'EQ' macro.
*/
static Obj EvalEq(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* compare the operands                                                */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = (EQ( opL, opR ) ? True : False);

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalNe(<expr>)  . . . . . . . . . . . . . . . . . . evaluate a comparison
**
**  'EvalNe'   evaluates the  comparison-expression  <expr>  and  returns its
**  value, i.e.,  'true'  if the operand   '<expr>.left' is not equal  to the
**  operand  '<expr>.right' and  'false' otherwise.  'EvalNe'  is called from
**  'EVAL_EXPR' to evaluate expressions of type 'EXPR_LT'.
**
**  'EvalNe' is simply implemented as 'not <objL> = <objR>'.
*/
static Obj EvalNe(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* compare the operands                                                */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = (EQ( opL, opR ) ? False : True);

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalLt(<expr>)  . . . . . . . . . . . . . . . . . . evaluate a comparison
**
**  'EvalLt' evaluates  the  comparison-expression   <expr> and  returns  its
**  value, i.e., 'true' if the operand '<expr>.left' is less than the operand
**  '<expr>.right'  and  'false'   otherwise.    'EvalLt'  is   called   from
**  'EVAL_EXPR' to evaluate expressions of type 'EXPR_LT'.
**
**  'EvalLt' evaluates the operands and then calls the 'LT' macro.
*/
static Obj EvalLt(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* compare the operands                                                */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = (LT( opL, opR ) ? True : False);

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalGe(<expr>)  . . . . . . . . . . . . . . . . . . evaluate a comparison
**
**  'EvalGe'  evaluates  the comparison-expression   <expr>  and returns  its
**  value, i.e., 'true' if the operand '<expr>.left' is greater than or equal
**  to the operand '<expr>.right' and 'false'  otherwise.  'EvalGe' is called
**  from 'EVAL_EXPR' to evaluate expressions of type 'EXPR_GE'.
**
**  'EvalGe' is simply implemented as 'not <objL> < <objR>'.
*/
static Obj EvalGe(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* compare the operands                                                */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = (LT( opL, opR ) ? False : True);

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalGt(<expr>)  . . . . . . . . . . . . . . . . . . evaluate a comparison
**
**  'EvalGt'  evaluates  the  comparison-expression <expr>   and  returns its
**  value, i.e.,  'true' if the  operand  '<expr>.left' is  greater than  the
**  operand '<expr>.right' and 'false' otherwise.    'EvalGt' is called  from
**  'EVAL_EXPR' to evaluate expressions of type 'EXPR_GT'.
**
**  'EvalGt' is simply implemented as '<objR> < <objL>'.
*/
static Obj EvalGt(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* compare the operands                                                */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = (LT( opR, opL ) ? True : False);

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalLe(<expr>)  . . . . . . . . . . . . . . . . . . evaluate a comparison
**
**  'EvalLe' evaluates   the comparison-expression   <expr> and  returns  its
**  value, i.e., 'true' if the operand '<expr>.left' is  less or equal to the
**  operand '<expr>.right' and 'false'   otherwise.  'EvalLe' is  called from
**  'EVAL_EXPR' to evaluate expressions of type 'EXPR_LE'.
**
**  'EvalLe' is simply implemented as 'not <objR> < <objR>'.
*/
static Obj EvalLe(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* compare the operands                                                */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = (LT( opR, opL ) ? False : True);

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalIn(<in>)  . . . . . . . . . . . . . . . test for membership in a list
**
**  'EvalIn' evaluates the in-expression <expr>  and returns its value, i.e.,
**  'true' if  the  operand '<expr>.left'  is a  member of '<expr>.right' and
**  'false' otherwise.    'EvalIn' is  called  from  'EVAL_EXPR'  to evaluate
**  expressions of type 'EXPR_IN'.
*/
static Obj EvalIn(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* evaluate <opL>                                                      */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );

    /* evaluate <opR>                                                      */
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* perform the test                                                    */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = (IN( opL, opR ) ? True : False);

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalSum(<expr>) . . . . . . . . . . . . . . . . . . . . .  evaluate a sum
**
**  'EvalSum'  evaluates the  sum-expression  <expr> and  returns its  value,
**  i.e., the sum of   the  two operands '<expr>.left'   and  '<expr>.right'.
**  'EvalSum'   is called from 'EVAL_EXPR'   to  evaluate expressions of type
**  'EXPR_SUM'.
**
**  'EvalSum' evaluates the operands and then calls the 'SUM' macro.
*/
static Obj EvalSum(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* first try to treat the operands as small integers with small result */
    if ( ! ARE_INTOBJS( opL, opR ) || ! SUM_INTOBJS( val, opL, opR ) ) {

        /* if that doesn't work, dispatch to the addition function         */
        SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
        val = SUM( opL, opR );

    }

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalAInv(<expr>)  . . . . . . . . . . . . .  evaluate an additive inverse
**
**  'EvalAInv' evaluates  the additive  inverse-expression  and  returns  its
**  value, i.e., the  additive inverse of  the operand.  'EvalAInv' is called
**  from 'EVAL_EXPR' to evaluate expressions of type 'EXPR_AINV'.
**
**  'EvalAInv' evaluates the operand and then calls the 'AINV' macro.
*/
static Obj EvalAInv(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );

    /* compute the additive inverse                                        */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = AINV( opL );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalDiff(<expr>)  . . . . . . . . . . . . . . . . . evaluate a difference
**
**  'EvalDiff'  evaluates  the difference-expression <expr>   and returns its
**  value, i.e.,   the   difference of  the two  operands   '<expr>.left' and
**  '<expr>.right'.  'EvalDiff'    is  called from   'EVAL_EXPR'  to evaluate
**  expressions of type 'EXPR_DIFF'.
**
**  'EvalDiff' evaluates the operands and then calls the 'DIFF' macro.
*/
static Obj EvalDiff(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* first try to treat the operands as small integers with small result */
    if ( ! ARE_INTOBJS( opL, opR ) || ! DIFF_INTOBJS( val, opL, opR ) ) {

        /* if that doesn't work, dispatch to the subtraction function      */
        SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
        val = DIFF( opL, opR );

    }

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalProd(<expr>)  . . . . . . . . . . . . . . . . . .  evaluate a product
**
**  'EvalProd' evaluates the product-expression <expr>  and returns it value,
**  i.e., the product of  the two operands '<expr>.left'  and '<expr>.right'.
**  'EvalProd'  is called from   'EVAL_EXPR' to evaluate  expressions of type
**  'EXPR_PROD'.
**
**  'EvalProd' evaluates the operands and then calls the 'PROD' macro.
*/
static Obj EvalProd(Expr expr)
{
    Obj                 val;            /* result                          */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* first try to treat the operands as small integers with small result */
    if ( ! ARE_INTOBJS( opL, opR ) || ! PROD_INTOBJS( val, opL, opR ) ) {

        /* if that doesn't work, dispatch to the multiplication function   */
        SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
        val = PROD( opL, opR );

    }

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalQuo(<expr>) . . . . . . . . . . . . . . . . . . . evaluate a quotient
**
**  'EvalQuo' evaluates the quotient-expression <expr> and returns its value,
**  i.e., the quotient of the  two operands '<expr>.left' and '<expr>.right'.
**  'EvalQuo' is  called  from 'EVAL_EXPR' to   evaluate expressions  of type
**  'EXPR_QUO'.
**
**  'EvalQuo' evaluates the operands and then calls the 'QUO' macro.
*/
static Obj EvalQuo(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* dispatch to the division function                                   */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = QUO( opL, opR );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalMod(<expr>) . . . . . . . . . . . . . . . . . .  evaluate a remainder
**
**  'EvalMod' evaluates the  remainder-expression   <expr> and returns    its
**  value, i.e.,  the  remainder  of   the two  operands   '<expr>.left'  and
**  '<expr>.right'.  'EvalMod'  is   called   from  'EVAL_EXPR'  to  evaluate
**  expressions of type 'EXPR_MOD'.
**
**  'EvalMod' evaluates the operands and then calls the 'MOD' macro.
*/
static Obj EvalMod(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* dispatch to the remainder function                                  */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = MOD( opL, opR );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalPow(<expr>) . . . . . . . . . . . . . . . . . . . .  evaluate a power
**
**  'EvalPow'  evaluates the power-expression  <expr>  and returns its value,
**  i.e.,   the power of the  two  operands '<expr>.left' and '<expr>.right'.
**  'EvalPow' is called  from  'EVAL_EXPR'  to evaluate expressions  of  type
**  'EXPR_POW'.
**
**  'EvalPow' evaluates the operands and then calls the 'POW' macro.
*/
static Obj EvalPow(Expr expr)
{
    Obj                 val;            /* value, result                   */
    Obj                 opL;            /* evaluated left  operand         */
    Obj                 opR;            /* evaluated right operand         */
    Expr                tmp;            /* temporary expression            */

    /* get the operands                                                    */
    tmp = READ_EXPR(expr, 0);
    opL = EVAL_EXPR( tmp );
    tmp = READ_EXPR(expr, 1);
    opR = EVAL_EXPR( tmp );

    /* dispatch to the powering function                                   */
    SET_BRK_CALL_TO(expr);     /* Note possible call for FuncWhere */
    val = POW( opL, opR );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  EvalIntExpr(<expr>) . . . . . . . . . evaluate literal integer expression
**
**  'EvalIntExpr' evaluates the literal integer expression <expr> and returns
**  its value.
*/
static Obj EvalIntExpr(Expr expr)
{
    UInt ix = READ_EXPR(expr, 0);
    return  GET_VALUE_FROM_CURRENT_BODY(ix);
}

/****************************************************************************
**
*F  EvalTildeExpr(<expr>)  . . . . . . . . .  evaluate tilde expression
**
**  'EvalTildeExpr' evaluates the tilde expression and returns its value.
*/
static Obj EvalTildeExpr(Expr expr)
{
    if( ! (STATE(Tilde)) ) {
        ErrorQuit("'~' does not have a value here", 0, 0);
    }
    return STATE(Tilde);
}

/****************************************************************************
**
*F  EvalTrueExpr(<expr>)  . . . . . . . . .  evaluate literal true expression
**
**  'EvalTrueExpr' evaluates the  literal true expression <expr> and  returns
**  its value (True).
*/
static Obj EvalTrueExpr(Expr expr)
{
    return True;
}


/****************************************************************************
**
*F  EvalFalseExpr(<expr>) . . . . . . . . . evaluate literal false expression
**
**  'EvalFalseExpr' evaluates the literal false expression <expr> and returns
**  its value (False).
*/
static Obj EvalFalseExpr(Expr expr)
{
    return False;
}


/****************************************************************************
**
*F  EvalCharExpr(<expr>)  . . . . . . evaluate a literal character expression
**
**  'EvalCharExpr' evaluates  the   literal character expression <expr>   and
**  returns its value.
*/
static Obj EvalCharExpr(Expr expr)
{
    return ObjsChar[ READ_EXPR(expr, 0) ];
}


/****************************************************************************
**
*F  EvalPermExpr(<expr>)  . . . . . . . . . evaluate a permutation expression
**
**  'EvalPermExpr' evaluates the permutation expression <expr>.
*/
static Obj GetFromExpr(Obj cycle, Int j)
{
    return EVAL_EXPR(READ_EXPR((Expr)cycle, j - 1));
}

static Obj EvalPermExpr(Expr expr)
{
    Obj                 perm;           /* permutation, result             */
    UInt                m;              /* maximal entry in permutation    */
    Expr                cycle;          /* one cycle of permutation        */
    UInt                i;              /* loop variable                   */

    /* special case for identity permutation                               */
    if ( SIZE_EXPR(expr) == 0 ) {
        return IdentityPerm;
    }

    /* allocate the new permutation                                        */
    m = 0;
    perm = NEW_PERM4( 0 );

    /* loop over the cycles                                                */
    for ( i = 1; i <= SIZE_EXPR(expr)/sizeof(Expr); i++ ) {
        cycle = READ_EXPR(expr, i - 1);

        // Need to inform profiling this cycle expression is executed, as
        // we never call EVAL_EXPR on it.
        VisitStatIfHooked(cycle);

        m = ScanPermCycle(perm, m, (Obj)cycle,
                          SIZE_EXPR(cycle) / sizeof(Expr), GetFromExpr);
    }

    /* if possible represent the permutation with short entries            */
    TrimPerm(perm, m);

    /* return the permutation                                              */
    return perm;
}


/****************************************************************************
**
*F  EvalListExpr(<expr>)  . . . . .  evaluate list expression to a list value
**
**  'EvalListExpr'  evaluates the list   expression, i.e., not  yet evaluated
**  list, <expr> to a list value.
*/
static Obj EvalListExpr(Expr expr)
{
    Obj                 list;           /* list value, result              */
    Obj                 sub;            /* value of a subexpression        */
    Int                 len;            /* logical length of the list      */
    Int                 i;              /* loop variable                   */
    Int                 dense;          /* track whether list is dense     */

    // get the length of the list
    len = SIZE_EXPR(expr) / sizeof(Expr);

    // handle empty list
    if (len == 0) {
        return NewEmptyPlist();
    }

    // allocate the list value
    list = NEW_PLIST(T_PLIST, len);

    // set the final list length
    SET_LEN_PLIST(list, len);

    // initially assume list is dense
    dense = 1;

    // handle the subexpressions
    for (i = 1; i <= len; i++) {
        Expr subExpr = READ_EXPR(expr, i - 1);

        // skip holes
        if (subExpr == 0) {
            // there is a hole, hence the list is not dense (note that list
            // expressions never contain holes at the end, so we do not have
            // to check if any bound entries follow)
            dense = 0;
            continue;
        }

        sub = EVAL_EXPR(subExpr);
        SET_ELM_PLIST(list, i, sub);
        CHANGED_BAG(list);
    }

    SET_FILT_LIST(list, dense ? FN_IS_DENSE : FN_IS_NDENSE);

    return list;
}


/****************************************************************************
**
*F  EvalListTildeExpr(<expr>) . . . . evaluate a list expression with a tilde
**
**  'EvalListTildeExpr' evaluates the     list  expression, i.e., not     yet
**  evaluated list, <expr> to a list value.  The difference to 'EvalListExpr'
**  is that  in <expr> there are  occurrences of '~'  referring to  this list
**  value.
**
**  Note that we do not track here whether the list is dense, as this can be
**  changed by code involving a tilde expression, as in this example:
**      x := [1,,3,function(x) x[2]:=2; return 4; end(~)];
**
**  For similar reasons, we must deal with the possibility that the list we
**  are creating changes its representation, and thus must use ASS_LIST
**  instead of SET_ELM_PLIST.
*/
static Obj EvalListTildeExpr(Expr expr)
{
    Obj                 list;           /* list value, result              */
    Obj                 tilde;          /* old value of tilde              */
    Obj                 sub;            /* value of a subexpression        */
    Int                 len;            /* logical length of the list      */
    Int                 i;              /* loop variable                   */

    // get the length of the list
    len = SIZE_EXPR(expr) / sizeof(Expr);

    // list expressions with tilde cannot be empty
    GAP_ASSERT(len > 0);

    // allocate the list value
    list = NEW_PLIST(T_PLIST, len);

    // remember the old value of '~'
    tilde = STATE(Tilde);

    // assign the list to '~'
    STATE(Tilde) = list;

    // handle the subexpressions
    for (i = 1; i <= len; i++) {
        Expr subExpr = READ_EXPR(expr, i - 1);

        // skip holes
        if (subExpr == 0)
            continue;

        sub = EVAL_EXPR(subExpr);
        ASS_LIST(list, i, sub);
    }

    // restore old value of '~'
    STATE(Tilde) = tilde;

    return list;
}


/****************************************************************************
**
*F  EvalRangeExpr(<expr>) . . . . .  eval a range expression to a range value
**
**  'EvalRangeExpr' evaluates the range expression <expr> to a range value.
*/
static Obj EvalRangeExpr(Expr expr)
{
    Obj                 range;          /* range, result                   */
    Obj                 val;            /* subvalue of range               */
    Int                 low;            /* low (as C integer)              */
    Int                 inc;            /* increment (as C integer)        */
    Int                 high;           /* high (as C integer)             */

    /* evaluate the low value                                              */
    val = EVAL_EXPR(READ_EXPR(expr, 0));
    low = GetSmallIntEx("Range", val, "<first>");

    /* evaluate the second value (if present)                              */
    if ( SIZE_EXPR(expr) == 3*sizeof(Expr) ) {
        val = EVAL_EXPR(READ_EXPR(expr, 1));
        Int ival = GetSmallIntEx("Range", val, "<second>");
        if (ival == low) {
            ErrorMayQuit("Range: <second> must not be equal to <first> (%d)",
                         (Int)low, 0);
        }
        inc = ival - low;
    }
    else {
        inc = 1;
    }

    /* evaluate and check the high value                                   */
    val = EVAL_EXPR(READ_EXPR(expr, SIZE_EXPR(expr) / sizeof(Expr) - 1));
    high = GetSmallIntEx("Range", val, "<last>");
    if ((high - low) % inc != 0) {
        ErrorMayQuit(
            "Range: <last>-<first> (%d) must be divisible by <inc> (%d)",
            (Int)(high - low), (Int)inc);
    }

    /* if <low> is larger than <high> the range is empty                   */
    if ( (0 < inc && high < low) || (inc < 0 && low < high) ) {
        range = NewEmptyPlist();
    }

    /* if <low> is equal to <high> the range is a singleton list           */
    else if ( low == high ) {
        range = NEW_PLIST( T_PLIST_CYC_SSORT, 1 );
        SET_LEN_PLIST( range, 1 );
        SET_ELM_PLIST( range, 1, INTOBJ_INT(low) );
    }

    /* else make the range                                                 */
    else {
        /* the length must be a small integer as well */
        if ((high-low) / inc + 1 > INT_INTOBJ_MAX) {
             ErrorQuit("Range: the length of a range must be a small integer",
                        0, 0);
        }
        range = NEW_RANGE((high - low) / inc + 1, low, inc);
    }

    /* return the range                                                    */
    return range;
}


/****************************************************************************
**
*F  EvalStringExpr(<expr>)  . . . . eval string expressions to a string value
**
**  'EvalStringExpr'   evaluates the  string  expression  <expr>  to a string
**  value.
*/
static Obj EvalStringExpr(Expr expr)
{
    UInt ix = READ_EXPR(expr, 0);
    Obj string = GET_VALUE_FROM_CURRENT_BODY(ix);
    return SHALLOW_COPY_OBJ(string);
}

/****************************************************************************
**
*F  EvalFloatExprLazy(<expr>)  . . . . eval float expressions to a float value
**
**  'EvalFloatExpr'   evaluates the  float  expression  <expr>  to a float
**  value.
*/
static Obj CONVERT_FLOAT_LITERAL;
static Obj FLOAT_LITERAL_CACHE;
static Obj MAX_FLOAT_LITERAL_CACHE_SIZE;

static Obj EvalFloatExprLazy(Expr expr)
{
    Obj                 string;         /* string value            */
    UInt                 ix;
    Obj cache= 0;
    Obj fl;
    
    /* This code is safe for threads trying to create or update the
     * cache concurrently in that it won't crash, but may occasionally
     * result in evaluating a floating point literal twice.
     */
    ix = READ_EXPR(expr, 0);
    if (ix && (!MAX_FLOAT_LITERAL_CACHE_SIZE || 
               MAX_FLOAT_LITERAL_CACHE_SIZE == INTOBJ_INT(0) ||
               ix <= INT_INTOBJ(MAX_FLOAT_LITERAL_CACHE_SIZE))) {
      cache = FLOAT_LITERAL_CACHE;
      assert(cache);
      fl = ELM0_LIST(cache, ix);
      if (fl)
        return fl;
    }
    string = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 1));
    fl = CALL_1ARGS(CONVERT_FLOAT_LITERAL, string);
    if (cache) {
      ASS_LIST(cache, ix, fl);
    }

    return fl;
}

/****************************************************************************
**
*F  EvalFloatExprEager(<expr>)  . . . . eval float expressions to a float value
**
**  'EvalFloatExpr'   evaluates the  float  expression  <expr>  to a float
**  value.
*/
static Obj EvalFloatExprEager(Expr expr)
{
    UInt ix = READ_EXPR(expr, 0);
    return GET_VALUE_FROM_CURRENT_BODY(ix);
}


/****************************************************************************
**
*F  EvalRecExpr(<expr>) . . . . . .  eval record expression to a record value
**
**  'EvalRecExpr' evaluates the record expression,   i.e., not yet  evaluated
**  record, <expr> to a record value.
**
**  'EvalRecExpr' just calls 'RecExpr1' and 'RecExpr2' to evaluate the record
**  expression.
*/
static Obj  RecExpr1(Expr expr);
static void RecExpr2(Obj rec, Expr expr);

static Obj EvalRecExpr(Expr expr)
{
    Obj                 rec;            /* record value, result            */

    /* evaluate the record expression                                      */
    rec = RecExpr1( expr );
    RecExpr2( rec, expr );

    return rec;
}


/****************************************************************************
**
*F  EvalRecTildeExpr(<expr>)  . . . evaluate a record expression with a tilde
**
**  'EvalRecTildeExpr'  evaluates  the    record expression,  i.e.,   not yet
**  evaluated   record, <expr>  to  a   record   value.  The   difference  to
**  'EvalRecExpr' is that in <expr> there are  occurrences of '~' referring to
**  this record value.
**
**  'EvalRecTildeExpr' just  calls 'RecExpr1'  to create the  record, assigns
**  the record to the variable '~',  and finally calls 'RecExpr2' to evaluate
**  the subexpressions  into the record.  Thus  subexpressions  in the record
**  expression    can refer to this variable    and its  subobjects to create
**  objects that are not trees.
*/
static Obj EvalRecTildeExpr(Expr expr)
{
    Obj                 rec;            /* record value, result            */
    Obj                 tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = STATE(Tilde);

    /* create the record value                                             */
    rec = RecExpr1( expr );

    /* assign the record value to the variable '~'                         */
    STATE(Tilde) = rec;

    /* evaluate the subexpressions into the record value                   */
    RecExpr2( rec, expr );

    /* restore the old value of '~'                                        */
    STATE(Tilde) = tilde;

    /* return the record value                                             */
    return rec;
}


/****************************************************************************
**
*F  RecExpr1(<expr>)  . . . . . . . . . make a record for a record expression
*F  RecExpr2(<rec>,<expr>)  . .  enter the subobjects for a record expression
**
**  'RecExpr1' and 'RecExpr2' together  evaluate the record expression <expr>
**  into the record <rec>.
**
**  'RecExpr1' allocates   a new record  of the    same size as   the  record
**  expression <expr> and returns this record.
**
**  'RecExpr2' evaluates the subexpressions   of <expr> and puts the   values
**  into the record <rec>  (which should be a record  of the same size as the
**  record expression <expr>, e.g., the one allocated by 'RecExpr1').
**
**  This two step allocation is necessary, because record expressions such as
**  'rec(  a := 1,  ~.a  )' requires that the   value of one subexpression is
**  entered into the record value before the next subexpression is evaluated.
*/
static Obj RecExpr1(Expr expr)
{
    Obj                 rec;            /* record value, result            */
    Int                 len;            /* number of components            */

    /* get the number of components                                        */
    len = SIZE_EXPR( expr ) / (2*sizeof(Expr));

    /* allocate the record value                                           */
    rec = NEW_PREC( len );

    /* return the record                                                   */
    return rec;
}

static void RecExpr2(Obj rec, Expr expr)
{
    UInt                rnam;           /* name of component               */
    Obj                 sub;            /* value of subexpression          */
    Int                 len;            /* number of components            */
    Expr                tmp;            /* temporary variable              */
    Int                 i;              /* loop variable                   */

    /* get the number of components                                        */
    len = SIZE_EXPR( expr ) / (2*sizeof(Expr));

    /* handle the subexpressions                                           */
    for ( i = 1; i <= len; i++ ) {

        /* handle the name                                                 */
        tmp = READ_EXPR(expr, 2 * i - 2);
        if ( IS_INTEXPR(tmp) ) {
            rnam = (UInt)INT_INTEXPR(tmp);
        }
        else {
            rnam = RNamObj( EVAL_EXPR(tmp) );
        }

        /* if the subexpression is empty (cannot happen for records)       */
        tmp = READ_EXPR(expr, 2 * i - 1);
        if ( tmp == 0 ) {
            continue;
        }
        sub = EVAL_EXPR( tmp );
        AssPRec(rec,rnam,sub);
    }
    SortPRecRNam(rec,0);

}


/****************************************************************************
**
*F  PrintExpr(<expr>) . . . . . . . . . . . . . . . . . . print an expression
**
**  'PrintExpr' prints the expression <expr>.
**
**  'PrintExpr' simply dispatches  through  the table 'PrintExprFuncs' to the
**  appropriate printer.
*/
void            PrintExpr (
    Expr                expr )
{
    (*PrintExprFuncs[ TNUM_EXPR(expr) ])( expr );
}


/****************************************************************************
**
*V  PrintExprFuncs[<type>]  . .  printing function for objects of type <type>
**
**  'PrintExprFuncs' is the dispatching table that contains for every type of
**  expressions a pointer to the printer for expressions  of this type, i.e.,
**  the function that should be called to print expressions of this type.
*/
PrintExprFunc PrintExprFuncs[256];


/****************************************************************************
**
*F  PrintUnknownExpr(<expr>)  . . . . . . .  print expression of unknown type
**
**  'PrintUnknownExpr' is the printer that is called if an attempt is made to
**  print an expression <expr> of an unknown type.  It signals  an error.  If
**  this  is ever called,   then  GAP is  in  serious   trouble, such as   an
**  overwritten type field of an expression.
*/
static void PrintUnknownExpr(Expr expr)
{
    Pr("Panic: tried to print an expression of unknown type '%d'\n",
       (Int)TNUM_EXPR(expr), 0);
}


struct ExprsState {

/****************************************************************************
**
*V  PrintPrecedence  . . . . . . . . . . . . . . . . current precedence level
**
**  'PrintPrecedence' contains the current precedence level, i.e., an integer
**  indicating the binding power of the currently printed operator. If one of
**  the operands is an operation that has lower binding power it is printed
**  in parenthesis. If the right operand has the same binding power it is put
**  in parenthesis, since all the operations are left associative.
**  Precedence: 14: ^; 12: mod,/,*; 10: -,+; 8: in,=; 6: not; 4: and; 2: or.
**  This sometimes puts in superfluous parenthesis: 2 * f( (3 + 4) ), since it
**  doesn't know that a function call adds automatically parenthesis.
*/
UInt PrintPrecedence;

};

static ModuleStateOffset ExprsStateOffset = -1;

extern inline struct ExprsState * ExprsState(void)
{
    return (struct ExprsState *)StateSlotsAtOffset(ExprsStateOffset);
}

#define PrintPrecedence ExprsState()->PrintPrecedence

/****************************************************************************
**
*F  PrintNot(<expr>)  . . . . . . . . . . . . .  print a boolean not operator
**
**  'PrintNot' print a not operation in the following form: 'not <expr>'.
*/
static void PrintNot(Expr expr)
{
    UInt                oldPrec;

    oldPrec = PrintPrecedence;
    PrintPrecedence = 6;
    
    /* if necessary print the opening parenthesis                          */
    if ( oldPrec >= PrintPrecedence ) Pr("%>(%>", 0, 0);
    else Pr("%2>", 0, 0);
    
    Pr("not%> ", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<", 0, 0);
    
    /* if necessary print the closing parenthesis                          */
    if ( oldPrec >= PrintPrecedence ) Pr("%2<)", 0, 0);
    else Pr("%2<", 0, 0);
    
    PrintPrecedence = oldPrec;
}


/****************************************************************************
**
*F  PrintBinop(<expr>)  . . . . . . . . . . . . . .  prints a binary operator
**
**  'PrintBinop'  prints  the   binary operator    expression <expr>,   using
**  'PrintPrecedence' for parenthesising.
*/
static void PrintAInv(Expr expr)
{
    UInt                oldPrec;

    oldPrec = PrintPrecedence;
    PrintPrecedence = 11;
    
    /* if necessary print the opening parenthesis                          */
    if ( oldPrec >= PrintPrecedence ) Pr("%>(%>", 0, 0);
    else Pr("%2>", 0, 0);
    
    Pr("-%> ", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<", 0, 0);
    
    /* if necessary print the closing parenthesis                          */
    if ( oldPrec >= PrintPrecedence ) Pr("%2<)", 0, 0);
    else Pr("%2<", 0, 0);
    
    PrintPrecedence = oldPrec;
}

static void PrintBinop(Expr expr)
{
    UInt                oldPrec;        /* old precedence level           */
    const Char *        op;             /* operand                         */
    BOOL                printEqPrec = FALSE; /* Print() at equal precedence */
    /* remember the current precedence level                              */
    oldPrec = PrintPrecedence;

    /* select the new precedence level                                    */
    switch ( TNUM_EXPR(expr) ) {
    case EXPR_OR:     op = "or";   PrintPrecedence =  2;  break;
    case EXPR_AND:    op = "and";  PrintPrecedence =  4;  break;
    case EXPR_EQ:     op = "=";    PrintPrecedence =  8;  break;
    case EXPR_LT:     op = "<";    PrintPrecedence =  8;  break;
    case EXPR_GT:     op = ">";    PrintPrecedence =  8;  break;
    case EXPR_NE:     op = "<>";   PrintPrecedence =  8;  break;
    case EXPR_LE:     op = "<=";   PrintPrecedence =  8;  break;
    case EXPR_GE:     op = ">=";   PrintPrecedence =  8;  break;
    case EXPR_IN:     op = "in";   PrintPrecedence =  8;  break;
    case EXPR_SUM:    op = "+";    PrintPrecedence = 10;  break;
    case EXPR_DIFF:   op = "-";    PrintPrecedence = 10;  break;
    case EXPR_PROD:   op = "*";    PrintPrecedence = 12;  break;
    case EXPR_QUO:    op = "/";    PrintPrecedence = 12;  break;
    case EXPR_MOD:    op = "mod";  PrintPrecedence = 12;  break;
    case EXPR_POW:    op = "^";    PrintPrecedence = 16;  break;
    default:       op = "<bogus-operator>";   break;
    }
    // The logical operators (=|<>|<|>|<=|>=|in) need brackets at
    // equal precedence level
    if (PrintPrecedence == 8) {
        printEqPrec = TRUE;
    }

    /* if necessary print the opening parenthesis                          */
    if (oldPrec > PrintPrecedence ||
        (oldPrec == PrintPrecedence && printEqPrec))
        Pr("%>(%>", 0, 0);
    else Pr("%2>", 0, 0);

    /* print the left operand                                              */
    if ( TNUM_EXPR(expr) == EXPR_POW
         && ((  (IS_INTEXPR(READ_EXPR(expr, 0))
                 && INT_INTEXPR(READ_EXPR(expr, 0)) < 0)
                || TNUM_EXPR(READ_EXPR(expr, 0)) == T_INTNEG)
             || TNUM_EXPR(READ_EXPR(expr, 0)) == EXPR_POW) ) {
        Pr( "(", 0, 0);
        PrintExpr(READ_EXPR(expr, 0));
        Pr(")", 0, 0);
    }
    else {
        PrintExpr(READ_EXPR(expr, 0));
    }

    /* print the operator                                                  */
    Pr("%2< %2>%s%> %<",(Int)op, 0);

    /* print the right operand                                             */
    PrintPrecedence++;
    PrintExpr(READ_EXPR(expr, 1));
    PrintPrecedence--;

    /* if necessary print the closing parenthesis                          */
    if (oldPrec > PrintPrecedence ||
        (oldPrec == PrintPrecedence && printEqPrec))
        Pr("%2<)", 0, 0);
    else Pr("%2<", 0, 0);

    /* restore the old precedence level                                   */
    PrintPrecedence = oldPrec;
}


/****************************************************************************
**
*F  PrintIntExpr(<expr>)  . . . . . . . . . . . . print an integer expression
**
**  'PrintIntExpr' prints the literal integer expression <expr>.
*/
static void PrintIntExpr(Expr expr)
{
    if ( IS_INTEXPR(expr) ) {
        Pr("%d", INT_INTEXPR(expr), 0);
    }
    else {
        PrintInt(EvalIntExpr(expr));
    }
}


/****************************************************************************
**
*F  PrintTildeExpr(<expr>) . . . . . . . . . . . print tilde expression
*/
static void PrintTildeExpr(Expr expr)
{
    Pr("~", 0, 0);
}

/****************************************************************************
**
*F  PrintTrueExpr(<expr>) . . . . . . . . . . . print literal true expression
*/
static void PrintTrueExpr(Expr expr)
{
    Pr("true", 0, 0);
}


/****************************************************************************
**
*F  PrintFalseExpr(<expr>)  . . . . . . . . .  print literal false expression
*/
static void PrintFalseExpr(Expr expr)
{
    Pr("false", 0, 0);
}


/****************************************************************************
**
*F  PrintCharExpr(<expr>) . . . . . . . .  print literal character expression
*/
static void PrintCharExpr(Expr expr)
{
    UChar               chr;

    chr = READ_EXPR(expr, 0);
    if      ( chr == '\n'  )  Pr("'\\n'", 0, 0);
    else if ( chr == '\t'  )  Pr("'\\t'", 0, 0);
    else if ( chr == '\r'  )  Pr("'\\r'", 0, 0);
    else if ( chr == '\b'  )  Pr("'\\b'", 0, 0);
    else if ( chr == '\03' )  Pr("'\\c'", 0, 0);
    else if ( chr == '\''  )  Pr("'\\''", 0, 0);
    else if ( chr == '\\'  )  Pr("'\\\\'", 0, 0);
    else                      Pr("'%c'",(Int)chr, 0);
}


/****************************************************************************
**
*F  PrintPermExpr(<expr>) . . . . . . . . . .  print a permutation expression
**
**  'PrintPermExpr' prints the permutation expression <expr>.
*/
static void PrintPermExpr(Expr expr)
{
    Expr                cycle;          /* one cycle of permutation expr.  */
    UInt                i, j;           /* loop variables                  */

    /* if there are no cycles, print the identity permutation              */
    if ( SIZE_EXPR(expr) == 0 ) {
        Pr("()", 0, 0);
    }
    
    /* print all cycles                                                    */
    for ( i = 1; i <= SIZE_EXPR(expr)/sizeof(Expr); i++ ) {
        cycle = READ_EXPR(expr, i - 1);
        Pr("%>(", 0, 0);

        /* print all entries of that cycle                                 */
        for ( j = 1; j <= SIZE_EXPR(cycle)/sizeof(Expr); j++ ) {
            Pr("%>", 0, 0);
            PrintExpr(READ_EXPR(cycle, j - 1));
            Pr("%<", 0, 0);
            if ( j < SIZE_EXPR(cycle)/sizeof(Expr) )  Pr(",", 0, 0);
        }

        Pr("%<)", 0, 0);
    }
}


/****************************************************************************
**
*F  PrintListExpr(<expr>) . . . . . . . . . . . . . . print a list expression
**
**  'PrintListExpr' prints the list expression <expr>.
*/
static void PrintListExpr(Expr expr)
{
    Int                 len;            /* logical length of <list>        */
    Expr                elm;            /* one element from <list>         */
    Int                 i;              /* loop variable                   */

    /* get the logical length of the list                                  */
    len = SIZE_EXPR( expr ) / sizeof(Expr);

    /* loop over the entries                                               */
    Pr("%2>[ %2>", 0, 0);
    for ( i = 1;  i <= len;  i++ ) {
        elm = READ_EXPR(expr, i - 1);
        if ( elm != 0 ) {
            if ( 1 < i )  Pr("%<,%< %2>", 0, 0);
            PrintExpr( elm );
        }
        else {
            if ( 1 < i )  Pr("%2<,%2>", 0, 0);
        }
    }
    Pr(" %4<]", 0, 0);
}


/****************************************************************************
**
*F  PrintRangeExpr(<expr>)  . . . . . . . . . . . . .  print range expression
**
**  'PrintRangeExpr' prints the record expression <expr>.
*/
static void PrintRangeExpr(Expr expr)
{
    if ( SIZE_EXPR( expr ) == 2*sizeof(Expr) ) {
        Pr("%2>[ %2>", 0, 0);    PrintExpr( READ_EXPR(expr, 0) );
        Pr("%2< .. %2>", 0, 0);  PrintExpr( READ_EXPR(expr, 1) );
        Pr(" %4<]", 0, 0);
    }
    else {
        Pr("%2>[ %2>", 0, 0);    PrintExpr( READ_EXPR(expr, 0) );
        Pr("%<,%< %2>", 0, 0);   PrintExpr( READ_EXPR(expr, 1) );
        Pr("%2< .. %2>", 0, 0);  PrintExpr( READ_EXPR(expr, 2) );
        Pr(" %4<]", 0, 0);
    }
}


/****************************************************************************
**
*F  PrintStringExpr(<expr>) . . . . . . . . . . . . print a string expression
**
**  'PrintStringExpr' prints the string expression <expr>.
*/
static void PrintStringExpr(Expr expr)
{
    UInt ix = READ_EXPR(expr, 0);
    Obj string =  GET_VALUE_FROM_CURRENT_BODY(ix);

    PrintString(string);
}

/****************************************************************************
**
*F  PrintFloatExpr(<expr>) . . . . . . . . . . . . print a float expression
**
**  'PrintFloatExpr' prints the float expression <expr>.
*/
static void PrintFloatExprLazy(Expr expr)
{
    UInt ix = READ_EXPR(expr, 1);
    Pr("%g", (Int)GET_VALUE_FROM_CURRENT_BODY(ix), 0);
}

/****************************************************************************
**
*F  PrintFloatExprEager(<expr>) . . . . . . . . . . . . print a float expression
**
**  'PrintFloatExpr' prints the float expression <expr>.
*/
static void PrintFloatExprEager(Expr expr)
{
    UInt ix = READ_EXPR(expr, 1);
    Char mark = (Char)READ_EXPR(expr, 2);
    Pr("%g_", (Int)GET_VALUE_FROM_CURRENT_BODY(ix), 0);
    if (mark != '\0') {
        Pr("%c", mark, 0);
    }
}


/****************************************************************************
**
*F  PrintRecExpr(<expr>)  . . . . . . . . . . . . . print a record expression
**
**  'PrintRecExpr' the record expression <expr>.
*/
void            PrintRecExpr1 (
    Expr                expr )
{
  Expr                tmp;            /* temporary variable              */
  UInt                i;              /* loop variable                   */
  
  for ( i = 1; i <= SIZE_EXPR(expr)/(2*sizeof(Expr)); i++ ) {
        /* print an ordinary record name                                   */
        tmp = READ_EXPR(expr, 2 * i - 2);
        if ( IS_INTEXPR(tmp) ) {
            Pr("%H", (Int)NAME_RNAM(INT_INTEXPR(tmp)), 0);
        }

        /* print an evaluating record name                                 */
        else {
            Pr(" (", 0, 0);
            PrintExpr( tmp );
            Pr(")", 0, 0);
        }

        /* print the component                                             */
        tmp = READ_EXPR(expr, 2 * i - 1);
        Pr("%< := %>", 0, 0);
        PrintExpr( tmp );
        if ( i < SIZE_EXPR(expr)/(2*sizeof(Expr)) )
            Pr("%2<,\n%2>", 0, 0);
    }
}

static void PrintRecExpr(Expr expr)
{
    Pr("%2>rec(\n%2>", 0, 0);
    PrintRecExpr1(expr);
    Pr(" %4<)", 0, 0);
}


static Obj FuncFLUSH_FLOAT_LITERAL_CACHE(Obj self)
{
#ifdef HPCGAP
    FLOAT_LITERAL_CACHE = NewAtomicList(T_ALIST, 0);
#else
    FLOAT_LITERAL_CACHE = NEW_PLIST(T_PLIST, 0);
#endif
    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
 **
 *V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
 */
static StructGVarFunc GVarFuncs [] = {

  GVAR_FUNC_0ARGS(FLUSH_FLOAT_LITERAL_CACHE),
  { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                type;           /* loop variable                   */

    InitFopyGVar("CONVERT_FLOAT_LITERAL",&CONVERT_FLOAT_LITERAL);
    InitCopyGVar("MAX_FLOAT_LITERAL_CACHE_SIZE",&MAX_FLOAT_LITERAL_CACHE_SIZE);

    InitGlobalBag( &FLOAT_LITERAL_CACHE, "FLOAT_LITERAL_CACHE" );
    InitHdlrFuncsFromTable( GVarFuncs );

    
    /* clear the evaluation dispatch table                                 */
    for ( type = 0; type < 256; type++ ) {
        InstallEvalExprFunc( type , EvalUnknownExpr);
        InstallEvalBoolFunc( type , EvalUnknownBool);
    }

    /* install the evaluators for logical operations                       */
    InstallEvalExprFunc( EXPR_OR             , EvalOr);   
    InstallEvalExprFunc( EXPR_AND            , EvalAnd);  
    InstallEvalExprFunc( EXPR_NOT            , EvalNot);  

    /* the logical operations are guaranteed to return booleans            */
    InstallEvalBoolFunc( EXPR_OR             , EvalOr);
    InstallEvalBoolFunc( EXPR_AND            , EvalAnd);
    InstallEvalBoolFunc( EXPR_NOT            , EvalNot);

    /* install the evaluators for comparison operations                    */
    InstallEvalExprFunc( EXPR_EQ             , EvalEq);   
    InstallEvalExprFunc( EXPR_NE             , EvalNe);   
    InstallEvalExprFunc( EXPR_LT             , EvalLt);   
    InstallEvalExprFunc( EXPR_GE             , EvalGe);   
    InstallEvalExprFunc( EXPR_GT             , EvalGt);   
    InstallEvalExprFunc( EXPR_LE             , EvalLe);   
    InstallEvalExprFunc( EXPR_IN             , EvalIn);     

    /* the comparison operations are guaranteed to return booleans         */
    InstallEvalBoolFunc( EXPR_EQ             , EvalEq);
    InstallEvalBoolFunc( EXPR_NE             , EvalNe);
    InstallEvalBoolFunc( EXPR_LT             , EvalLt);
    InstallEvalBoolFunc( EXPR_GE             , EvalGe);
    InstallEvalBoolFunc( EXPR_GT             , EvalGt);
    InstallEvalBoolFunc( EXPR_LE             , EvalLe);
    InstallEvalBoolFunc( EXPR_IN             , EvalIn);

    /* install the evaluators for binary operations                        */
    InstallEvalExprFunc( EXPR_SUM            , EvalSum);
    InstallEvalExprFunc( EXPR_AINV           , EvalAInv);
    InstallEvalExprFunc( EXPR_DIFF           , EvalDiff);
    InstallEvalExprFunc( EXPR_PROD           , EvalProd);
    InstallEvalExprFunc( EXPR_QUO            , EvalQuo);
    InstallEvalExprFunc( EXPR_MOD            , EvalMod);
    InstallEvalExprFunc( EXPR_POW            , EvalPow);

    /* install the evaluators for literal expressions                      */
    InstallEvalExprFunc( EXPR_INTPOS       , EvalIntExpr);
    InstallEvalExprFunc( EXPR_TRUE      , EvalTrueExpr);
    InstallEvalExprFunc( EXPR_FALSE     , EvalFalseExpr);
    InstallEvalExprFunc( EXPR_TILDE     , EvalTildeExpr);
    InstallEvalExprFunc( EXPR_CHAR      , EvalCharExpr);
    InstallEvalExprFunc( EXPR_PERM      , EvalPermExpr);
    InstallEvalExprFunc( EXPR_FLOAT_LAZY  , EvalFloatExprLazy);
    InstallEvalExprFunc( EXPR_FLOAT_EAGER , EvalFloatExprEager);

    /* install the evaluators for list and record expressions              */
    InstallEvalExprFunc( EXPR_LIST      , EvalListExpr);
    InstallEvalExprFunc( EXPR_LIST_TILDE, EvalListTildeExpr);
    InstallEvalExprFunc( EXPR_RANGE     , EvalRangeExpr);
    InstallEvalExprFunc( EXPR_STRING    , EvalStringExpr);
    InstallEvalExprFunc( EXPR_REC       , EvalRecExpr);
    InstallEvalExprFunc( EXPR_REC_TILDE , EvalRecTildeExpr);

    /* clear the tables for the printing dispatching                       */
    for ( type = 0; type < 256; type++ ) {
        InstallPrintExprFunc( type , PrintUnknownExpr);
    }

    /* install the printers for logical operations                         */
    InstallPrintExprFunc( EXPR_OR             , PrintBinop);
    InstallPrintExprFunc( EXPR_AND            , PrintBinop);
    InstallPrintExprFunc( EXPR_NOT            , PrintNot);

    /* install the printers for comparison operations                      */
    InstallPrintExprFunc( EXPR_EQ             , PrintBinop);
    InstallPrintExprFunc( EXPR_LT             , PrintBinop);
    InstallPrintExprFunc( EXPR_NE             , PrintBinop);
    InstallPrintExprFunc( EXPR_GE             , PrintBinop);
    InstallPrintExprFunc( EXPR_GT             , PrintBinop);
    InstallPrintExprFunc( EXPR_LE             , PrintBinop);
    InstallPrintExprFunc( EXPR_IN             , PrintBinop);

    /* install the printers for binary operations                          */
    InstallPrintExprFunc( EXPR_SUM            , PrintBinop);
    InstallPrintExprFunc( EXPR_AINV           , PrintAInv);
    InstallPrintExprFunc( EXPR_DIFF           , PrintBinop);
    InstallPrintExprFunc( EXPR_PROD           , PrintBinop);
    InstallPrintExprFunc( EXPR_QUO            , PrintBinop);
    InstallPrintExprFunc( EXPR_MOD            , PrintBinop);
    InstallPrintExprFunc( EXPR_POW            , PrintBinop);

    /* install the printers for literal expressions                        */
    InstallPrintExprFunc( EXPR_INT        , PrintIntExpr);
    InstallPrintExprFunc( EXPR_INTPOS       , PrintIntExpr);
    InstallPrintExprFunc( EXPR_TRUE      , PrintTrueExpr);
    InstallPrintExprFunc( EXPR_FALSE     , PrintFalseExpr);
    InstallPrintExprFunc( EXPR_TILDE     , PrintTildeExpr);
    InstallPrintExprFunc( EXPR_CHAR      , PrintCharExpr);
    InstallPrintExprFunc( EXPR_PERM      , PrintPermExpr);
    InstallPrintExprFunc( EXPR_FLOAT_LAZY  , PrintFloatExprLazy);
    InstallPrintExprFunc( EXPR_FLOAT_EAGER , PrintFloatExprEager);

    /* install the printers for list and record expressions                */
    InstallPrintExprFunc( EXPR_LIST      , PrintListExpr);
    InstallPrintExprFunc( EXPR_LIST_TILDE, PrintListExpr);
    InstallPrintExprFunc( EXPR_RANGE     , PrintRangeExpr);
    InstallPrintExprFunc( EXPR_STRING    , PrintStringExpr);
    InstallPrintExprFunc( EXPR_REC       , PrintRecExpr);
    InstallPrintExprFunc( EXPR_REC_TILDE , PrintRecExpr);

    return 0;
}


static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    FuncFLUSH_FLOAT_LITERAL_CACHE(0);

    return 0;
}

/****************************************************************************
**
*F  InitInfoExprs() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "exprs",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,

    .moduleStateSize = sizeof(struct ExprsState),
    .moduleStateOffsetPtr = &ExprsStateOffset,
};

StructInitInfo * InitInfoExprs ( void )
{
    return &module;
}
