/****************************************************************************
**
*W  exprs.h                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the expressions package.
**
**  The expressions  package is the  part  of the interpreter  that evaluates
**  expressions to their values and prints expressions.
*/

#ifndef GAP_EXPRS_H
#define GAP_EXPRS_H

#include "system.h"

/****************************************************************************
**
*F  OBJ_REFLVAR(<expr>) . . . . . . . . . . . value of a reference to a local
**
**  'OBJ_REFLVAR'  returns  the value of  the reference  to a  local variable
**  <expr>.
*/
#define OBJ_REFLVAR(expr)       \
                        (OBJ_LVAR( LVAR_REFLVAR( expr ) ) != 0 ? \
                         OBJ_LVAR( LVAR_REFLVAR( expr ) ) : \
                         ObjLVar( LVAR_REFLVAR( expr ) ) )

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

#define OBJ_INTEXPR(expr)   ((Obj)(expr))


/****************************************************************************
**
*V  EvalExprFuncs[<type>]  . . . . . evaluator for expressions of type <type>
**
**  'EvalExprFuncs'  is the dispatch table   that contains for  every type of
**  expressions a pointer  to the  evaluator  for expressions of this   type,
**  i.e., the function that should be  called to evaluate expressions of this
**  type.
*/
extern  Obj             (* EvalExprFuncs [256]) ( Expr expr );


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
#include "code.h"
#include "vars.h"
static inline Obj EVAL_EXPR(Expr expr)
{
    if (IS_REFLVAR(expr))
        return OBJ_REFLVAR(expr);
    if (IS_INTEXPR(expr))
        return OBJ_INTEXPR(expr);
    Stat oldStat = BRK_CALL_TO();
    SET_BRK_CALL_TO(expr);
    UInt tnum = TNUM_STAT(expr);
    Obj val = (*EvalExprFuncs[tnum])( expr );
    SET_BRK_CALL_TO(oldStat);
    return val;
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
extern  Obj             (* EvalBoolFuncs [256]) ( Expr expr );


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
extern Obj EvalUnknownBool(Expr expr);

static inline Obj EVAL_BOOL_EXPR(Expr expr)
{
    UInt tnum = TNUM_STAT(expr);
    if (EvalUnknownBool == EvalBoolFuncs[tnum]) {
        return EvalUnknownBool(expr);
    }
    Stat oldStat = BRK_CALL_TO();
    SET_BRK_CALL_TO(expr);
    Obj val = (*EvalBoolFuncs[tnum])( expr );
    SET_BRK_CALL_TO(oldStat);
    return val;
}

/****************************************************************************
**
*F  PrintExpr(<expr>) . . . . . . . . . . . . . . . . . . print an expression
**
**  'PrintExpr' prints the expression <expr>.
*/
extern  void            PrintExpr (
            Expr                expr );


extern void PrintRecExpr1 ( Expr expr ); /* needed for printing
                                          function calls with options */

/****************************************************************************
**
*V  PrintExprFuncs[<type>]  . .  printing function for objects of type <type>
**
**  'PrintExprFuncs' is the dispatching table that contains for every type of
**  expressions a pointer to the printer for expressions  of this type, i.e.,
**  the function that should be called to print expressions of this type.
*/
extern  void            (* PrintExprFuncs [256] ) ( Expr expr );


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
