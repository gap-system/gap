/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the expressions package.
**
**  The expressions  package is the  part  of the interpreter  that evaluates
**  expressions to their values and prints expressions.
*/

#ifndef GAP_EXPRS_H
#define GAP_EXPRS_H

#include "code.h"
#include "common.h"
#include "vars.h"

/****************************************************************************
**
*F  OBJ_REF_LVAR(<expr>) . . . . . . . . . . .value of a reference to a local
**
**  'OBJ_REF_LVAR' returns the value of the reference to a local variable
**  <expr>.
*/
EXPORT_INLINE Obj OBJ_REF_LVAR(Expr expr)
{
    Int lvar = LVAR_REF_LVAR(expr);
    if (OBJ_LVAR(lvar) != 0) {
        return OBJ_LVAR(lvar);
    }
    else {
        return ObjLVar(lvar);
    }
}

/****************************************************************************
**
*F  OBJ_INTEXPR(<expr>) . . . . . . . . . . .  value of an integer expression
**
**  'OBJ_INTEXPR' returns the (immediate)  integer  value of the  (immediate)
**  integer expression <expr>.
**
**  'OBJ_INTEXPR(<expr>)' should be 'INTOBJ_INT(INT_INTEXPR(<expr>))', but
**  for performance  reasons we implement  it as '(Obj)(<expr>)'.  This is of
**  course    highly  dependent  on    (immediate)  integer   expressions and
**  (immediate) integer values having the same representation.
*/

EXPORT_INLINE Obj OBJ_INTEXPR(Expr expr)
{
    GAP_ASSERT(IS_INTOBJ((Obj)expr));
    return (Obj)expr;
}


/****************************************************************************
**
*V  EvalExprFuncs[<type>]  . . . . . evaluator for expressions of type <type>
**
**  'EvalExprFuncs'  is the dispatch table   that contains for  every type of
**  expressions a pointer  to the  evaluator  for expressions of this   type,
**  i.e., the function that should be  called to evaluate expressions of this
**  type.
*/
extern EvalExprFunc EvalExprFuncs[256];


/****************************************************************************
**
*F  EVAL_EXPR(<expr>) . . . . . . . . . . . . . . . .  evaluate an expression
**
**  'EVAL_EXPR' evaluates the expression <expr>.
**
**  'EVAL_EXPR' returns the value of <expr>.
**
**  'EVAL_EXPR'  causes  the   evaluation of   <expr> by  dispatching  to the
**  evaluator, i.e., to  the function that evaluates  expressions of the type
**  of <expr>.
**
**  Note that 'EVAL_EXPR' does not use 'TNUM_EXPR', since it also handles the
**  two special cases that 'TNUM_EXPR' handles.
*/

EXPORT_INLINE Obj EVAL_EXPR(Expr expr)
{
    if (IS_REF_LVAR(expr)) {
        return OBJ_REF_LVAR(expr);
    }
    else if (IS_INTEXPR(expr)) {
        return OBJ_INTEXPR(expr);
    }
    else {
        return (*EvalExprFuncs[TNUM_STAT(expr)])(expr);
    }
}


/****************************************************************************
**
*V  EvalBoolFuncs[<type>] . . boolean evaluator for expression of type <type>
**
**  'EvalBoolFuncs'  is  the dispatch table that  contains  for every type of
**  expression a pointer to a boolean evaluator for expressions of this type,
**  i.e., a pointer to  a function which  is  guaranteed to return a  boolean
**  value that should be called to evaluate expressions of this type.
*/
extern EvalBoolFunc EvalBoolFuncs[256];


/****************************************************************************
**
*F  EVAL_BOOL_EXPR(<expr>)  . . . . evaluate an expression to a boolean value
**
**  'EVAL_BOOL_EXPR' evaluates   the expression  <expr> and  checks  that the
**  value is either  'true' or 'false'.  If the  expression does not evaluate
**  to 'true' or 'false', then an error is signalled.
**
**  'EVAL_BOOL_EXPR' returns the  value of <expr> (which  is either 'true' or
**  'false').
*/
EXPORT_INLINE Obj EVAL_BOOL_EXPR(Expr expr)
{
    return (*EvalBoolFuncs[TNUM_EXPR(expr)])(expr);
}


/****************************************************************************
**
*F  PrintExpr(<expr>) . . . . . . . . . . . . . . . . . . print an expression
**
**  'PrintExpr' prints the expression <expr>.
*/
void PrintExpr(Expr expr);


void PrintRecExpr1(Expr expr); /* needed for printing
                                       function calls with options */

/****************************************************************************
**
*V  PrintExprFuncs[<type>]  . .  printing function for objects of type <type>
**
**  'PrintExprFuncs' is the dispatching table that contains for every type of
**  expressions a pointer to the printer for expressions  of this type, i.e.,
**  the function that should be called to print expressions of this type.
*/
extern PrintExprFunc PrintExprFuncs[256];


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoExprs() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoExprs ( void );


#endif // GAP_EXPRS_H
