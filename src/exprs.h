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


/****************************************************************************
**
*F  OBJ_REFLVAR(<expr>) . . . . . . . . . . . value of a reference to a local
**
**  'OBJ_REFLVAR'  returns  the value of  the reference  to a  local variable
**  <expr>.
*/
#ifdef  NO_LVAR_CHECKS
#define OBJ_REFLVAR(expr)       \
                        OBJ_LVAR( LVAR_REFLVAR( (expr) ) )
#endif
#ifndef NO_LVAR_CHECKS

#ifdef SYS_IS_64_BIT
#define OFFSET_REFLVAR(expr)  (((expr)*2)+10)
#else
#define OFFSET_REFLVAR(expr)  ((expr) + 5)
#endif

#define OBJ_REFLVAR(expr)       \
                        (*(Obj*)(((char*)STATE(PtrLVars))+OFFSET_REFLVAR(expr)) != 0 ? \
                         *(Obj*)(((char*)STATE(PtrLVars))+OFFSET_REFLVAR(expr)) : \
                         ObjLVar( LVAR_REFLVAR( expr ) ) )
#endif


/****************************************************************************
**
*F  OBJ_INTEXPR(<expr>) . . . . . . . . . . .  value of an integer expression
**
**  'OBJ_INTEXPR' returns the (immediate)  integer  value of the  (immediate)
**  integer expression <expr>.
**
**  'OBJ_INTEXPR(<expr>)'  should  be 'OBJ_INT(INT_INTEXPR(<expr>))', but for
**  performance  reasons we implement  it   as '(Obj)(<expr>)'.  This is   of
**  course    highly  dependent  on    (immediate)  integer   expressions and
**  (immediate) integer values having the same representation.
*/

#ifndef SYS_IS_64_BIT
#define OBJ_INTEXPR(expr)       \
                        ((Obj)(Int)(Int4)(expr))
#else
#define OBJ_INTEXPR(expr)       \
                        (INTOBJ_INT(INT_INTEXPR((expr))))
#endif

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
#define EVAL_EXPR(expr) \
                        (IS_REFLVAR(expr) ? OBJ_REFLVAR(expr) : \
                         (IS_INTEXPR(expr) ? OBJ_INTEXPR(expr) : \
                          (*EvalExprFuncs[ TNUM_STAT(expr) ])( expr ) ))


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
*F  EVAL_BOOL_EXPR(<expr>)  . . . . evaluate an expression to a boolean value
**
**  'EVAL_BOOL_EXPR' evaluates   the expression  <expr> and  checks  that the
**  value is either  'true' or 'false'.  If the  expression does not evaluate
**  to 'true' or 'false', then an error is signalled.
**
**  'EVAL_BOOL_EXPR' returns the  value of <expr> (which  is either 'true' or
**  'false').
*/
#define EVAL_BOOL_EXPR(expr) \
                        ( (*EvalBoolFuncs[ TNUM_EXPR( expr ) ])( expr ) )


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

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoExprs() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoExprs ( void );


#endif // GAP_EXPRS_H

/****************************************************************************
**

*E  exprs.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
