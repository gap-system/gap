/****************************************************************************
**
*A  code.c                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of the coder package.
**
**  The  coder package  is   the part of   the interpreter  that creates  the
**  expressions.  Its functions are called from the reader.
*/
char *          Revision_code_c =
   "@(#)$Id$";

#include        <assert.h>              /* assert                          */

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TNUM_OBJ, types            */
#include        "scanner.h"             /* Pr                             ?*/

#include        "calls.h"               /* NARG_FUNC, NLOC_FUNC, NAMS_FU...*/
/*N 1996/06/16 mschoene func expressions should be different from funcs    */

#include        "records.h"             /* RNamIntg                        */

#include        "integer.h"             /* SumInt, ProdInt                 */

#include        "plist.h"               /* LEN_PLIST, ELM_PLIST, ...       */

#include        "funcs.h"               /* MakeFunction                    */

#define INCLUDE_DECLARATION_PART
#include        "code.h"                /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "vars.h"                /* SWITCH_TO_NEW_LVARS, ...        */

#include        "gap.h"                 /* CompNowFuncs, CompNowCount      */


/****************************************************************************
**
*S  T_BODY  . . . . . . . . . . . . . . . . . . . . type of function body bag
**
**  'T_BODY' is the type of the function body bags.
**
**  'T_BODY' is defined in the declaration part of this package as follows
**
#define T_BODY                  175
*/


/****************************************************************************
**
*T  Stat  . . . . . . . . . . . . . . . . . . . . . . . .  type of statements
**
**  'Stat' is the type of statements.
**
**  If 'Stat' is different  from 'Expr', then  a lot of things will  probably
**  break.
**
**  'Stat' is defined in the declaration part of this package as follows
**
#define Stat            UInt4
*/


/****************************************************************************
**
*V  PtrBody . . . . . . . . . . . . . . . . . . . . . pointer to current body
**
**  'PtrBody' is a pointer to the current body.
*/
Stat *          PtrBody;


/****************************************************************************
**
*V  OffsBody  . . . . . . . . . . . . . . . . . . . .  offset in current body
**
**  'OffsBody' is the  offset in the current   body.  It is  only valid while
**  coding.
*/
Stat            OffsBody;


/****************************************************************************
**
*V  FIRST_STAT_CURR_FUNC  . . . . . . . .  index of first statement in a body
**
**  'FIRST_STAT_CURR_FUNC' is the index of the first statement in a body.
**
** 'FIRST_STAT_CURR_FUNC' is defined in  the declaration part of this package
** as follows
**
#define FIRST_STAT_CURR_FUNC    sizeof(Stat)
*/


/****************************************************************************
**
*S  T_<name>  . . . . . . . . . . . . . .  symbolic names for statement types
*S  FIRST_STAT_TNUM . . . . . . . . . . . . . . . . . .  first statement type
*S  LAST_STAT_TNUM  . . . . . . . . . . . . . . . . . . . last statement type
**
**  For every type  of statements there is  a symbolic name  defined for this
**  type.
**
**  As long as statements   are represented by  bags,  these types  must  not
**  overlap with the values types, lest Gasman becomes confused.
**
**  The types are defined in the declaration part of this package as follows
**
#define FIRST_STAT_TNUM         0

#define T_PROCCALL_0ARGS        (FIRST_STAT_TNUM+ 0)
#define T_PROCCALL_1ARGS        (FIRST_STAT_TNUM+ 1)
#define T_PROCCALL_2ARGS        (FIRST_STAT_TNUM+ 2)
#define T_PROCCALL_3ARGS        (FIRST_STAT_TNUM+ 3)
#define T_PROCCALL_4ARGS        (FIRST_STAT_TNUM+ 4)
#define T_PROCCALL_5ARGS        (FIRST_STAT_TNUM+ 5)
#define T_PROCCALL_6ARGS        (FIRST_STAT_TNUM+ 6)
#define T_PROCCALL_XARGS        (FIRST_STAT_TNUM+ 7)

#define T_SEQ_STAT              (FIRST_STAT_TNUM+ 8)
#define T_SEQ_STAT2             (FIRST_STAT_TNUM+ 9)
#define T_SEQ_STAT3             (FIRST_STAT_TNUM+10)
#define T_SEQ_STAT4             (FIRST_STAT_TNUM+11)
#define T_SEQ_STAT5             (FIRST_STAT_TNUM+12)
#define T_SEQ_STAT6             (FIRST_STAT_TNUM+13)
#define T_SEQ_STAT7             (FIRST_STAT_TNUM+14)
#define T_IF                    (FIRST_STAT_TNUM+15)
#define T_IF_ELSE               (FIRST_STAT_TNUM+16)
#define T_IF_ELIF               (FIRST_STAT_TNUM+17)
#define T_IF_ELIF_ELSE          (FIRST_STAT_TNUM+18)
#define T_FOR                   (FIRST_STAT_TNUM+19)
#define T_FOR2                  (FIRST_STAT_TNUM+20)
#define T_FOR3                  (FIRST_STAT_TNUM+21)
#define T_FOR_RANGE             (FIRST_STAT_TNUM+22)
#define T_FOR_RANGE2            (FIRST_STAT_TNUM+23)
#define T_FOR_RANGE3            (FIRST_STAT_TNUM+24)
#define T_WHILE                 (FIRST_STAT_TNUM+25)
#define T_WHILE2                (FIRST_STAT_TNUM+26)
#define T_WHILE3                (FIRST_STAT_TNUM+27)
#define T_REPEAT                (FIRST_STAT_TNUM+28)
#define T_REPEAT2               (FIRST_STAT_TNUM+29)
#define T_REPEAT3               (FIRST_STAT_TNUM+30)
#define T_BREAK                 (FIRST_STAT_TNUM+31)
#define T_RETURN_OBJ            (FIRST_STAT_TNUM+32)
#define T_RETURN_VOID           (FIRST_STAT_TNUM+33)

#define T_ASS_LVAR              (FIRST_STAT_TNUM+34)
#define T_ASS_LVAR_01           (FIRST_STAT_TNUM+35)
#define T_ASS_LVAR_02           (FIRST_STAT_TNUM+36)
#define T_ASS_LVAR_03           (FIRST_STAT_TNUM+37)
#define T_ASS_LVAR_04           (FIRST_STAT_TNUM+38)
#define T_ASS_LVAR_05           (FIRST_STAT_TNUM+39)
#define T_ASS_LVAR_06           (FIRST_STAT_TNUM+40)
#define T_ASS_LVAR_07           (FIRST_STAT_TNUM+41)
#define T_ASS_LVAR_08           (FIRST_STAT_TNUM+42)
#define T_ASS_LVAR_09           (FIRST_STAT_TNUM+43)
#define T_ASS_LVAR_10           (FIRST_STAT_TNUM+44)
#define T_ASS_LVAR_11           (FIRST_STAT_TNUM+45)
#define T_ASS_LVAR_12           (FIRST_STAT_TNUM+46)
#define T_ASS_LVAR_13           (FIRST_STAT_TNUM+47)
#define T_ASS_LVAR_14           (FIRST_STAT_TNUM+48)
#define T_ASS_LVAR_15           (FIRST_STAT_TNUM+49)
#define T_ASS_LVAR_16           (FIRST_STAT_TNUM+50)
#define T_UNB_LVAR              (FIRST_STAT_TNUM+51)
#define T_ASS_HVAR              (FIRST_STAT_TNUM+52)
#define T_UNB_HVAR              (FIRST_STAT_TNUM+53)
#define T_ASS_GVAR              (FIRST_STAT_TNUM+54)
#define T_UNB_GVAR              (FIRST_STAT_TNUM+55)
#define T_ASS_LIST              (FIRST_STAT_TNUM+56)
#define T_ASSS_LIST             (FIRST_STAT_TNUM+57)
#define T_ASS_LIST_LEV          (FIRST_STAT_TNUM+58)
#define T_ASSS_LIST_LEV         (FIRST_STAT_TNUM+59)
#define T_UNB_LIST              (FIRST_STAT_TNUM+60)
#define T_ASS_REC_NAME          (FIRST_STAT_TNUM+61)
#define T_ASS_REC_EXPR          (FIRST_STAT_TNUM+62)
#define T_UNB_REC_NAME          (FIRST_STAT_TNUM+63)
#define T_UNB_REC_EXPR          (FIRST_STAT_TNUM+64)
#define T_ASS_POSOBJ            (FIRST_STAT_TNUM+65)
#define T_ASSS_POSOBJ           (FIRST_STAT_TNUM+66)
#define T_ASS_POSOBJ_LEV        (FIRST_STAT_TNUM+67)
#define T_ASSS_POSOBJ_LEV       (FIRST_STAT_TNUM+68)
#define T_UNB_POSOBJ            (FIRST_STAT_TNUM+69)
#define T_ASS_COMOBJ_NAME       (FIRST_STAT_TNUM+70)
#define T_ASS_COMOBJ_EXPR       (FIRST_STAT_TNUM+71)
#define T_UNB_COMOBJ_NAME       (FIRST_STAT_TNUM+72)
#define T_UNB_COMOBJ_EXPR       (FIRST_STAT_TNUM+73)

#define T_INFO                  (FIRST_STAT_TNUM+74)
#define T_ASSERT_2ARGS          (FIRST_STAT_TNUM+75)
#define T_ASSERT_3ARGS          (FIRST_STAT_TNUM+76)

#define LAST_STAT_TNUM          T_ASSERT_3ARGS
*/


/****************************************************************************
**
*F  TNUM_STAT(<stat>) . . . . . . . . . . . . . . . . . . type of a statement
**
**  'TNUM_STAT' returns the type of the statement <stat>.
**
**  'TNUM_STAT' is defined in the declaration part of this package as follows
**
#define TNUM_STAT(stat) (ADDR_STAT(stat)[-1] & 0xFF)
*/


/****************************************************************************
**
*F  SIZE_STAT(<stat>) . . . . . . . . . . . . . . . . . . size of a statement
**
**  'SIZE_STAT' returns the size of the statement <stat>.
**
**  'SIZE_STAT' is defined in the declaration part of this package as follows
**
#define SIZE_STAT(stat) (ADDR_STAT(stat)[-1] >> 8)
*/


/****************************************************************************
**
*F  ADDR_STAT(<stat>) . . . . . . . . . . . . absolute address of a statement
**
**  'ADDR_STAT' returns   the  absolute address of the    memory block of the
**  statement <stat>.
**
**  'ADDR_STAT' is defined in the declaration part of this package as follows
**
#define ADDR_STAT(stat) ((Stat*)(((char*)PtrBody)+(stat)))
*/


/****************************************************************************
**
*F  NewStat(<type>,<size>)  . . . . . . . . . . . .  allocate a new statement
**
**  'NewStat'   allocates a new   statement memory block  of  type <type> and
**  <size> bytes.  'NewStat' returns the identifier of the new statement.
*/
Stat            NewStat (
    UInt                type,
    UInt                size )
{
    Stat                stat;           /* result                          */

    /* this is where the new statement goes                                */
    stat = OffsBody + FIRST_STAT_CURR_FUNC;

    /* increase the offset                                                 */
    OffsBody = stat + ((size+sizeof(Stat)-1) / sizeof(Stat)) * sizeof(Stat);

    /* make certain that the current body bag is large enough              */
    while ( SIZE_BAG(BODY_FUNC(CURR_FUNC)) < OffsBody ) {
        ResizeBag( BODY_FUNC(CURR_FUNC), 2*SIZE_BAG(BODY_FUNC(CURR_FUNC)) );
        PtrBody = (Stat*)PTR_BAG( BODY_FUNC(CURR_FUNC) );
    }

    /* enter type and size                                                 */
    ADDR_STAT(stat)[-1] = (size << 8) + type;

    /* return the new statement                                            */
    return stat;
}


/****************************************************************************
**
*T  Expr  . . . . . . . . . . . . . . . . . . . . . . . . type of expressions
**
**  'Expr' is the type of expressions.
**
**  If 'Expr' is different  from 'Stat', then  a lot of things will  probably
**  break.
**
**  'Expr' is defined in the declaration part of this package as follows
**
#define Expr            Stat
*/


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
**
**  'IS_REFLVAR', 'REFLVAR_LVAR',   and 'LVAR_REFLVAR'   are defined  in  the
**  declaration part of this package as follows
**
#define IS_REFLVAR(expr)        \
                        (((Int)(expr) & 0x03) == 0x03)

#define REFLVAR_LVAR(lvar)      \
                        ((Expr)(((lvar) << 2) + 0x03))

#define LVAR_REFLVAR(expr)      \
                        ((Int)(expr) >> 2)
*/


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
**
**  'IS_INTEXPR', 'INTEXPR_INT', and    'INT_INTEXPR'  are defined in     the
**  declaration part of this package as follows
**
#define IS_INTEXPR(expr)        \
                        (((Int)(expr) & 0x03) == 0x01)

#define INTEXPR_INT(indx)       \
                        ((Expr)(((indx) << 2) + 0x01))

#define INT_INTEXPR(expr)       \
                        (((Int)(Int4)(expr)) / 4)
*/


/****************************************************************************
**
*S  T_<name>  . . . . . . . . . . . . . . symbolic names for expression types
*S  FIRST_EXPR_TNUM . . . . . . . . . . . . . . . . . . first expression type
*S  LAST_EXPR_TNUM  . . . . . . . . . . . . . . . . . .  last expression type
**
**  For every type of expressions there  is a symbolic  name defined for this
**  type.
**
**  As long as  expressions  are represented by  bags,  these types must  not
**  overlap with the values types, lest Gasman becomes confused.
**
**  The types are defined in the declaration part of this package as follows
**
#define FIRST_EXPR_TNUM         128

#define T_FUNCCALL_0ARGS        (FIRST_EXPR_TNUM+ 0)
#define T_FUNCCALL_1ARGS        (FIRST_EXPR_TNUM+ 1)
#define T_FUNCCALL_2ARGS        (FIRST_EXPR_TNUM+ 2)
#define T_FUNCCALL_3ARGS        (FIRST_EXPR_TNUM+ 3)
#define T_FUNCCALL_4ARGS        (FIRST_EXPR_TNUM+ 4)
#define T_FUNCCALL_5ARGS        (FIRST_EXPR_TNUM+ 5)
#define T_FUNCCALL_6ARGS        (FIRST_EXPR_TNUM+ 6)
#define T_FUNCCALL_XARGS        (FIRST_EXPR_TNUM+ 7)
#define T_FUNC_EXPR             (FIRST_EXPR_TNUM+ 8)

#define T_OR                    (FIRST_EXPR_TNUM+ 9)
#define T_AND                   (FIRST_EXPR_TNUM+10)
#define T_NOT                   (FIRST_EXPR_TNUM+11)
#define T_EQ                    (FIRST_EXPR_TNUM+12)
#define T_NE                    (FIRST_EXPR_TNUM+13)
#define T_LT                    (FIRST_EXPR_TNUM+14)
#define T_GE                    (FIRST_EXPR_TNUM+15)
#define T_GT                    (FIRST_EXPR_TNUM+16)
#define T_LE                    (FIRST_EXPR_TNUM+17)
#define T_IN                    (FIRST_EXPR_TNUM+18)
#define T_SUM                   (FIRST_EXPR_TNUM+19)
#define T_AINV                  (FIRST_EXPR_TNUM+20)
#define T_DIFF                  (FIRST_EXPR_TNUM+21)
#define T_PROD                  (FIRST_EXPR_TNUM+22)
#define T_INV                   (FIRST_EXPR_TNUM+23)
#define T_QUO                   (FIRST_EXPR_TNUM+24)
#define T_MOD                   (FIRST_EXPR_TNUM+25)
#define T_POW                   (FIRST_EXPR_TNUM+26)

#define T_INTEXPR               (FIRST_EXPR_TNUM+27)
#define T_INT_EXPR              (FIRST_EXPR_TNUM+28)
#define T_TRUE_EXPR             (FIRST_EXPR_TNUM+29)
#define T_FALSE_EXPR            (FIRST_EXPR_TNUM+30)
#define T_CHAR_EXPR             (FIRST_EXPR_TNUM+31)
#define T_PERM_EXPR             (FIRST_EXPR_TNUM+32)
#define T_PERM_CYCLE            (FIRST_EXPR_TNUM+33)
#define T_LIST_EXPR             (FIRST_EXPR_TNUM+34)
#define T_LIST_TILD_EXPR        (FIRST_EXPR_TNUM+35)
#define T_RANGE_EXPR            (FIRST_EXPR_TNUM+36)
#define T_STRING_EXPR           (FIRST_EXPR_TNUM+37)
#define T_REC_EXPR              (FIRST_EXPR_TNUM+38)
#define T_REC_TILD_EXPR         (FIRST_EXPR_TNUM+39)

#define T_REFLVAR               (FIRST_EXPR_TNUM+40)
#define T_REF_LVAR              (FIRST_EXPR_TNUM+41)
#define T_REF_LVAR_01           (FIRST_EXPR_TNUM+42)
#define T_REF_LVAR_02           (FIRST_EXPR_TNUM+43)
#define T_REF_LVAR_03           (FIRST_EXPR_TNUM+44)
#define T_REF_LVAR_04           (FIRST_EXPR_TNUM+45)
#define T_REF_LVAR_05           (FIRST_EXPR_TNUM+46)
#define T_REF_LVAR_06           (FIRST_EXPR_TNUM+47)
#define T_REF_LVAR_07           (FIRST_EXPR_TNUM+48)
#define T_REF_LVAR_08           (FIRST_EXPR_TNUM+49)
#define T_REF_LVAR_09           (FIRST_EXPR_TNUM+50)
#define T_REF_LVAR_10           (FIRST_EXPR_TNUM+51)
#define T_REF_LVAR_11           (FIRST_EXPR_TNUM+52)
#define T_REF_LVAR_12           (FIRST_EXPR_TNUM+53)
#define T_REF_LVAR_13           (FIRST_EXPR_TNUM+54)
#define T_REF_LVAR_14           (FIRST_EXPR_TNUM+55)
#define T_REF_LVAR_15           (FIRST_EXPR_TNUM+56)
#define T_REF_LVAR_16           (FIRST_EXPR_TNUM+57)
#define T_ISB_LVAR              (FIRST_EXPR_TNUM+58)
#define T_REF_HVAR              (FIRST_EXPR_TNUM+59)
#define T_ISB_HVAR              (FIRST_EXPR_TNUM+60)
#define T_REF_GVAR              (FIRST_EXPR_TNUM+61)
#define T_ISB_GVAR              (FIRST_EXPR_TNUM+62)
#define T_ELM_LIST              (FIRST_EXPR_TNUM+63)
#define T_ELMS_LIST             (FIRST_EXPR_TNUM+64)
#define T_ELM_LIST_LEV          (FIRST_EXPR_TNUM+65)
#define T_ELMS_LIST_LEV         (FIRST_EXPR_TNUM+66)
#define T_ISB_LIST              (FIRST_EXPR_TNUM+67)
#define T_ELM_REC_NAME          (FIRST_EXPR_TNUM+68)
#define T_ELM_REC_EXPR          (FIRST_EXPR_TNUM+69)
#define T_ISB_REC_NAME          (FIRST_EXPR_TNUM+70)
#define T_ISB_REC_EXPR          (FIRST_EXPR_TNUM+71)
#define T_ELM_POSOBJ            (FIRST_EXPR_TNUM+72)
#define T_ELMS_POSOBJ           (FIRST_EXPR_TNUM+73)
#define T_ELM_POSOBJ_LEV        (FIRST_EXPR_TNUM+74)
#define T_ELMS_POSOBJ_LEV       (FIRST_EXPR_TNUM+75)
#define T_ISB_POSOBJ            (FIRST_EXPR_TNUM+76)
#define T_ELM_COMOBJ_NAME       (FIRST_EXPR_TNUM+77)
#define T_ELM_COMOBJ_EXPR       (FIRST_EXPR_TNUM+78)
#define T_ISB_COMOBJ_NAME       (FIRST_EXPR_TNUM+79)
#define T_ISB_COMOBJ_EXPR       (FIRST_EXPR_TNUM+80)

#define LAST_EXPR_TNUM          T_ISB_COMOBJ_EXPR
*/


/****************************************************************************
**
*F  TNUM_EXPR(<expr>) . . . . . . . . . . . . . . . . . type of an expression
**
**  'TNUM_EXPR' returns the type of the expression <expr>.
**
**  'TNUM_EXPR' is defined in the declaration part of this package as follows
**
#define TNUM_EXPR(expr)         \
                        (IS_REFLVAR( (expr) ) ? T_REFLVAR : \
                         (IS_INTEXPR( (expr) ) ? T_INTEXPR : \
                          TNUM_STAT(expr) ))
*/


/****************************************************************************
**
*F  SIZE_EXPR(<expr>) . . . . . . . . . . . . . . . . . size of an expression
**
**  'SIZE_EXPR' returns the size of the expression <expr>.
**
**  Note  that  it is *fatal*  to apply  'SIZE_EXPR'   to expressions of type
**  'T_REFLVAR' or 'T_INTEXPR'.
**
**  'SIZE_EXPR' is defined in the declaration part of this package as follows
**
#define SIZE_EXPR(expr) SIZE_STAT(expr)
*/


/****************************************************************************
**
*F  ADDR_EXPR(<expr>) . . . . . . . . . . . absolute address of an expression
**
**  'ADDR_EXPR' returns  the absolute  address  of  the memory  block of  the
**  expression <expr>.
**
**  Note  that  it is *fatal*  to apply  'ADDR_EXPR'   to expressions of type
**  'T_REFLVAR' or 'T_INTEXPR'.
**
**  'ADDR_EXPR' is defined in the declaration part of this package as follows
**
#define ADDR_EXPR(expr) ADD_STAT(expr)
*/


/****************************************************************************
**
*F  NewExpr(<type>,<size>)  . . . . . . . . . . . . allocate a new expression
**
**  'NewExpr' allocates a new expression memory block of  the type <type> and
**  <size> bytes.  'NewExpr' returns the identifier of the new expression.
*/
Expr            NewExpr (
    UInt                type,
    UInt                size )
{
    Expr                expr;           /* result                          */

    /* this is where the new expression goes                               */
    expr = OffsBody + FIRST_STAT_CURR_FUNC;

    /* increase the offset                                                 */
    OffsBody = expr + ((size+sizeof(Expr)-1) / sizeof(Expr)) * sizeof(Expr);

    /* make certain that the current body bag is large enough              */
    while ( SIZE_BAG(BODY_FUNC(CURR_FUNC)) < OffsBody ) {
        ResizeBag( BODY_FUNC(CURR_FUNC), 2*SIZE_BAG(BODY_FUNC(CURR_FUNC)) );
        PtrBody = (Stat*)PTR_BAG( BODY_FUNC(CURR_FUNC) );
    }

    /* enter type and size                                                 */
    ADDR_EXPR(expr)[-1] = (size << 8) + type;

    /* return the new expression                                           */
    return expr;
}


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
**
**  'FUNC_CALL', 'ARGI_CALL',  'NARG_SIZE_CALL',   and  'SIZE_NARG_CALL'  are
**  defined in the declaration part of this package as follows
**
#define FUNC_CALL(call)         (* (ADDR_EXPR((call)) +0     ) )
#define ARGI_CALL(call,i)       (* (ADDR_EXPR((call)) +0 +(i)) )
#define NARG_SIZE_CALL(size)    (((size) / sizeof(Expr)) - 1)
#define SIZE_NARG_CALL(narg)    (((narg) + 1) * sizeof(Expr))
*/

/****************************************************************************
**
*F  ARGI_INFO(<info>,<i>) . . .  <i>-th formal argument for an Info statement
*F  NARG_SIZE_INFO(<size>)  . . . . number of arguments for an Info statement
*F  SIZE_NARG_INFO(<narg>)  . . . . . . size of the bag for an Info statement
**
**  'ARGI_INFO'  returns  the expression that evaluates  to the <i>-th actual
**  argument for the Info statement <info>.  This is a legal left
**  value, so it can be used to set the expression too.
**
**  'NARG_SIZE_INFO' returns the number of  arguments in a function call from
**  the size <size> of the function call bag (as returned by 'SIZE_STAT').
**
**  'SIZE_NARG_INFO' returns the size a  function call bag  should have for a
**  function call bag with <narg> arguments.
**  defined in the declaration part of this package as follows
**
#define ARGI_INFO(info,i)       (* (ADDR_STAT((info))+(i) -1) )
#define NARG_SIZE_INFO(size)    ((size) / sizeof(Expr))
#define SIZE_NARG_INFO(narg)    ((narg) * sizeof(Expr))
*/



/****************************************************************************
**
*V  CodeResult  . . . . . . . . . . . . . . . . . . . . . .  result of coding
**
**  'CodeResult'  is the result  of the coding, i.e.,   the function that was
**  coded.
*/
Obj             CodeResult;


/****************************************************************************
**
*V  StackStat . . . . . . . . . . . . . . . . . . . . . . .  statements stack
*V  CountStat . . . . . . . . . . . . . . . number of statements on the stack
*F  PushStat(<stat>)  . . . . . . . . . . . . . push statement onto the stack
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
Bag             StackStat;

Int             CountStat;

void            PushStat (
    Stat                stat )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( StackStat != 0 );
    assert( 0 <= CountStat );
    assert( CountStat <= SIZE_BAG(StackStat)/sizeof(Stat) );
    assert( stat != 0 );

    /* count up and put the statement onto the stack                       */
    if ( CountStat == SIZE_BAG(StackStat)/sizeof(Stat) ) {
        ResizeBag( StackStat, 2*CountStat*sizeof(Stat) );
    }
    ((Stat*)PTR_BAG(StackStat))[CountStat] = stat;
    CountStat++;
}

Stat            PopStat ( void )
{
    Stat                stat;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    assert( StackStat != 0 );
    assert( 1 <= CountStat );
    assert( CountStat <= SIZE_BAG(StackStat)/sizeof(Stat) );

    /* get the top statement from the stack, and count down                */
    CountStat--;
    stat = ((Stat*)PTR_BAG(StackStat))[CountStat];

    /* return the popped statement                                         */
    return stat;
}

Stat            PopSeqStat (
    UInt                nr )
{
    Stat                body;           /* sequence, result                */
    Stat                stat;           /* single statement                */
    UInt                i;              /* loop variable                   */

    /* special case for a single statement                                 */
    if ( nr == 1 ) {
        body = PopStat();
    }

    /* general case                                                        */
    else {

        /* allocate the sequence                                           */
        if ( 2 <= nr && nr <= 7 ) {
            body = NewStat( T_SEQ_STAT+(nr-1), nr * sizeof(Stat) );
        }
        else {
            body = NewStat( T_SEQ_STAT,        nr * sizeof(Stat) );
        }

        /* enter the statements into the sequence                          */
        for ( i = nr; 1 <= i; i-- ) {
            stat = PopStat();
            ADDR_STAT(body)[i-1] = stat;
        }
    }

    /* return the sequence                                                 */
    return body;
}


/****************************************************************************
**
*V  StackExpr . . . . . . . . . . . . . . . . . . . . . . . expressions stack
*V  CountExpr . . . . . . . . . . . . . .  number of expressions on the stack
*F  PushExpr(<expr>)  . . . . . . . . . . . .  push expression onto the stack
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
Bag             StackExpr;

Int             CountExpr;

void            PushExpr (
    Expr                expr )
{
    /* there must be a stack, it must not be underfull or overfull         */
    assert( StackExpr != 0 );
    assert( 0 <= CountExpr );
    assert( CountExpr <= SIZE_BAG(StackExpr)/sizeof(Expr) );
    assert( expr != 0 );

    /* count up and put the expression onto the stack                      */
    if ( CountExpr == SIZE_BAG(StackExpr)/sizeof(Expr) ) {
        ResizeBag( StackExpr, 2*CountExpr*sizeof(Expr) );
    }
    ((Expr*)PTR_BAG(StackExpr))[CountExpr] = expr;
    CountExpr++;
}

Expr            PopExpr ( void )
{
    Expr                expr;

    /* there must be a stack, it must not be underfull/empty or overfull   */
    assert( StackExpr != 0 );
    assert( 1 <= CountExpr );
    assert( CountExpr <= SIZE_BAG(StackExpr)/sizeof(Expr) );

    /* get the top expression from the stack, and count down               */
    CountExpr--;
    expr = ((Expr*)PTR_BAG(StackExpr))[CountExpr];

    /* return the popped expression                                        */
    return expr;
}


/****************************************************************************
**
*F  PushUnaryOp(<type>) . . . . . . . . . . . . . . . . . push unary operator
**
**  'PushUnaryOp' pushes a   unary  operator expression onto the   expression
**  stack.  <type> is the type of the operator (currently only 'T_NOT').
*/
void            PushUnaryOp (
    UInt                type )
{
    Expr                unop;           /* unary operator, result          */
    Expr                op;             /* operand                         */

    /* allocate the unary operator                                         */
    unop = NewExpr( type, sizeof(Expr) );

    /* enter the operand                                                   */
    op = PopExpr();
    ADDR_EXPR(unop)[0] = op;

    /* push the unary operator                                             */
    PushExpr( unop );
}


/****************************************************************************
**
*F  PushBinaryOp(<type>)  . . . . . . . . . . . . . . .  push binary operator
**
**  'PushBinaryOp' pushes a binary   operator expression onto  the expression
**  stack.  <type> is the type of the operator.
*/
void            PushBinaryOp (
    UInt                type )
{
    Expr                binop;          /* binary operator, result         */
    Expr                opL;            /* left operand                    */
    Expr                opR;            /* right operand                   */

    /* allocate the binary operator                                        */
    binop = NewExpr( type, 2*sizeof(Expr) );

    /* enter the right operand                                             */
    opR = PopExpr();
    ADDR_EXPR(binop)[1] = opR;

    /* enter the left operand                                              */
    opL = PopExpr();
    ADDR_EXPR(binop)[0] = opL;

    /* push the binary operator                                            */
    PushExpr( binop );
}


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
**  the coder should only clean up.
**
**  ...only function expressions inbetween...
*/
Bag             CodeLVars;

void            CodeBegin ( void )
{
    /* the stacks must be empty                                            */
    assert( CountStat == 0 );
    assert( CountExpr == 0 );

    /* remember the current frame                                          */
    CodeLVars = CurrLVars;

    /* clear the code result bag                                           */
    CodeResult = 0;
}

UInt            CodeEnd (
    UInt                error )
{
    /* if everything went fine                                             */
    if ( ! error ) {

        /* the stacks must be empty                                        */
        assert( CountStat == 0 );
        assert( CountExpr == 0 );

        /* we must be back to 'CurrLVars'                                  */
        assert( CurrLVars == CodeLVars );

        /* 'CodeFuncExprEnd' left the function already in 'CodeResult'     */
    }

    /* otherwise clean up the mess                                         */
    else {

        /* empty the stacks                                                */
        CountStat = 0;
        CountExpr = 0;

        /* go back to the correct frame                                    */
        SWITCH_TO_OLD_LVARS( CodeLVars );
    }

    /* return value is ignored                                             */
    return 0;
}


/****************************************************************************
**
*F  CodeFuncCallBegin() . . . . . . . . . . . . . . code function call, begin
*F  CodeFuncCallEnd(<funccall>,<nr>)  . . . . . . . . code function call, end
**
**  'CodeFuncCallBegin'  is an action to code  a function call.  It is called
**  by the reader  when it encounters the parenthesis  '(', i.e., *after* the
**  function expression is read.
**
**  'CodeFuncCallEnd' is an action to code a  function call.  It is called by
**  the reader when  it  encounters the parenthesis  ')',  i.e.,  *after* the
**  argument expressions are read.   <funccall> is 1  if  this is a  function
**  call,  and 0  if  this  is  a procedure  call.    <nr> is the   number of
**  arguments.
*/
void            CodeFuncCallBegin ( void )
{
}

void            CodeFuncCallEnd (
    UInt                funccall,
    UInt                nr )
{
    Expr                call;           /* function call, result           */
    Expr                func;           /* function expression             */
    Expr                arg;            /* one argument expression         */
    UInt                i;              /* loop variable                   */

    /* allocate the function call                                          */
    if ( funccall && nr <= 6 ) {
        call = NewExpr( T_FUNCCALL_0ARGS+nr, SIZE_NARG_CALL(nr) );
    }
    else if ( funccall /* && 6 < nr */ ) {
        call = NewExpr( T_FUNCCALL_XARGS,    SIZE_NARG_CALL(nr) );
    }
    else if ( /* ! funccall && */ nr <=6 ) {
        call = NewExpr( T_PROCCALL_0ARGS+nr, SIZE_NARG_CALL(nr) );
    }
    else /* if ( ! funccall && 6 < nr ) */ {
        call = NewExpr( T_PROCCALL_XARGS,    SIZE_NARG_CALL(nr) );
    }

    /* enter the argument expressions                                      */
    for ( i = nr; 1 <= i; i-- ) {
        arg = PopExpr();
        ARGI_CALL(call,i) = arg;
    }

    /* enter the function expression                                       */
    func = PopExpr();
    FUNC_CALL(call) = func;

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
*F  CodeFuncExprBegin(<narg>,<nloc>,<nams>) . code function expression, begin
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
*/
void            CodeFuncExprBegin (
    Int                 narg,
    Int                 nloc,
    Obj                 nams )
{
    Obj                 fexp;           /* function expression bag         */
    Obj                 fexs;           /* function expressions list       */
    Bag                 body;           /* function body                   */
    Bag                 old;            /* old frame                       */
    Stat                stat1;          /* first statement in body         */

    /* remember the current offset                                         */
    SET_BRK_CALL_TO( OffsBody );

    /* create a function expression                                        */
    fexp = NewBag( T_FUNCTION, SIZE_FUNC );
    NARG_FUNC( fexp ) = narg;
    NLOC_FUNC( fexp ) = nloc;
    NAMS_FUNC( fexp ) = nams;
    CHANGED_BAG( fexp );

    /* give it a functions expressions list                                */
    fexs = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( fexs, 0 );
    FEXS_FUNC( fexp ) = fexs;
    CHANGED_BAG( fexp );

    /* give it a body                                                      */
    body = NewBag( T_BODY, 1024*sizeof(Stat) );
    BODY_FUNC( fexp ) = body;
    CHANGED_BAG( fexp );
    OffsBody = 0;

    /* give it an environment                                              */
    ENVI_FUNC( fexp ) = CurrLVars;
    CHANGED_BAG( fexp );

    /* switch to this function                                             */
    SWITCH_TO_NEW_LVARS( fexp, (narg != -1 ? narg : 1), nloc, old );

    /* allocate the top level statement sequence                           */
    stat1 = NewStat( T_SEQ_STAT, 8*sizeof(Stat) );
    assert( stat1 == FIRST_STAT_CURR_FUNC );
}

void            CodeFuncExprEnd (
    UInt                nr,
    UInt                mapsto )
{
    Expr                expr;           /* function expression, result     */
    Stat                stat1;          /* single statement of body        */
    Obj                 fexp;           /* function expression bag         */
    Obj                 fexs;           /* funct. expr. list of outer func */
    UInt                len;            /* length of func. expr. list      */
    UInt                i;              /* loop variable                   */

    /* get the function expression                                         */
    fexp = CURR_FUNC;

    /* get the body of the function                                        */
    /* push an addition return-void-statement if neccessary                */
    /* the function interpreters depend on each function ``returning''     */
    if ( nr == 0 ) {
        CodeReturnVoid();
        nr++;
    }
    else {
        stat1 = PopStat();
        PushStat( stat1 );
        if ( TNUM_STAT(stat1) != T_RETURN_VOID
          && TNUM_STAT(stat1) != T_RETURN_OBJ ) {
            CodeReturnVoid();
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
    ADDR_STAT(FIRST_STAT_CURR_FUNC)[-1]
        = ((nr*sizeof(Stat)) << 8) + T_SEQ_STAT+nr-1;
    for ( i = 1; i <= nr; i++ ) {
        stat1 = PopStat();
        ADDR_STAT(FIRST_STAT_CURR_FUNC)[nr-i] = stat1;
    }

    /* make the body smaller                                               */
    ResizeBag( BODY_FUNC(fexp), OffsBody );

    /* switch back to the previous function                                */
    SWITCH_TO_OLD_LVARS( ENVI_FUNC(fexp) );

    /* restore the remembered offset                                       */
    OffsBody = BRK_CALL_TO();

    /* if this was inside another function definition, make the expression */
    /* and store it in the function expression list of the outer function  */
    if ( CurrLVars != CodeLVars ) {
        fexs = FEXS_FUNC( CURR_FUNC );
        len = LEN_PLIST( fexs );
        GROW_PLIST(      fexs, len+1 );
        SET_LEN_PLIST(   fexs, len+1 );
        SET_ELM_PLIST(   fexs, len+1, fexp );
        CHANGED_BAG(     fexs );
        expr = NewExpr( T_FUNC_EXPR, sizeof(Expr) );
        ADDR_EXPR(expr)[0] = (Expr)(len+1);
        PushExpr( expr );
    }

    /* otherwise, make the function and store it in 'CodeResult'           */
    else {
        CodeResult = MakeFunction( fexp );
        if ( CompNowFuncs != 0 ) {
            CompNowCount++;
            if ( CompNowCount <= LEN_PLIST( CompNowFuncs ) ) {
                fexp = ELM_PLIST( CompNowFuncs, CompNowCount );
                for ( i = 0;  i <= 7;  i++ ) {
                    HDLR_FUNC( fexp, i ) = HDLR_FUNC( CodeResult, i );
                }
                NARG_FUNC( fexp ) = NARG_FUNC( CodeResult );
                NAMS_FUNC( fexp ) = NAMS_FUNC( CodeResult );
                NLOC_FUNC( fexp ) = NLOC_FUNC( CodeResult );
                BODY_FUNC( fexp ) = BODY_FUNC( CodeResult );
                FEXS_FUNC( fexp ) = FEXS_FUNC( CodeResult );
                CHANGED_BAG( fexp );
            }
            else {
                GROW_PLIST(    CompNowFuncs, CompNowCount );
                SET_LEN_PLIST( CompNowFuncs, CompNowCount );
                SET_ELM_PLIST( CompNowFuncs, CompNowCount, CodeResult );
                CHANGED_BAG(   CompNowFuncs );
            }
        }
    }

}


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
void            CodeIfBegin ( void )
{
}

void            CodeIfElif ( void )
{
}

void            CodeIfElse ( void )
{
    CodeTrueExpr();
}

void            CodeIfBeginBody ( void )
{
}

void            CodeIfEndBody (
    UInt                nr )
{
    /* collect the statements in a statement sequence if necessary         */
    PushStat( PopSeqStat( nr ) );
}

void            CodeIfEnd (
    UInt                nr )
{
    Stat                stat;           /* if-statement, result            */
    Expr                cond;           /* condition of a branch           */
    Stat                body;           /* body of a branch                */
    UInt                hase;           /* has else branch                 */
    UInt                i;              /* loop variable                   */

    /* peek at the last condition                                          */
    body = PopStat();
    cond = PopExpr();
    hase = (TNUM_EXPR(cond) == T_TRUE_EXPR);
    PushExpr( cond );
    PushStat( body );

    /* allocate the if-statement                                           */
    if      ( nr == 1 ) {
        stat = NewStat( T_IF,            nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else if ( nr == 2 && hase ) {
        stat = NewStat( T_IF_ELSE,       nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else if ( ! hase ) {
        stat = NewStat( T_IF_ELIF,       nr * (sizeof(Expr)+sizeof(Stat)) );
    }
    else {
        stat = NewStat( T_IF_ELIF_ELSE,  nr * (sizeof(Expr)+sizeof(Stat)) );
    }

    /* enter the branches                                                  */
    for ( i = nr; 1 <= i; i-- ) {
        body = PopStat();
        cond = PopExpr();
        ADDR_STAT(stat)[2*(i-1)] = cond;
        ADDR_STAT(stat)[2*(i-1)+1] = body;
    }

    /* push the if-statement                                               */
    PushStat( stat );
}


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
void            CodeForBegin ( void )
{
}

void            CodeForIn ( void )
{
}

void            CodeForBeginBody ( void )
{
}

void            CodeForEndBody (
    UInt                nr )
{
    Stat                stat;           /* for-statement, result           */
    UInt                type;           /* type of for-statement           */
    Expr                var;            /* variable                        */
    Expr                list;           /* list                            */
    Stat                stat1;          /* single statement of body        */
    UInt                i;              /* loop variable                   */

    /* collect the statements into a statement sequence if necessary       */
    if ( 3 < nr ) {
        PushStat( PopSeqStat( nr ) );
        nr = 1;
    }

    /* get the list expression                                             */
    list = PopExpr();

    /* get the variable reference                                          */
    var = PopExpr();

    /* select the type of the for-statement                                */
    if ( TNUM_EXPR(list) == T_RANGE_EXPR && SIZE_EXPR(list) == 2*sizeof(Expr)
      && TNUM_EXPR(var)  == T_REFLVAR ) {
        type = T_FOR_RANGE + (nr-1);
    }
    else {
        type = T_FOR + (nr-1);
    }

    /* allocate the for-statement                                          */
    stat = NewStat( type, 2*sizeof(Expr) + nr * sizeof(Stat) );

    /* enter the body statements                                           */
    for ( i = nr; 1 <= i; i-- ) {
        stat1 = PopStat();
        ADDR_STAT(stat)[i+1] = stat1;
    }

    /* enter the list expression                                           */
    ADDR_STAT(stat)[1] = list;

    /* enter the variable reference                                        */
    ADDR_STAT(stat)[0] = var;

    /* push the for-statement                                              */
    PushStat( stat );
}

void            CodeForEnd ( void )
{
}


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
void            CodeWhileBegin ( void )
{
}

void            CodeWhileBeginBody ( void )
{
}

void            CodeWhileEndBody (
    UInt                nr )
{
    Stat                stat;           /* while-statement, result         */
    Expr                cond;           /* condition                       */
    Stat                stat1;          /* single statement of body        */
    UInt                i;              /* loop variable                   */

    /* collect the statements into a statement sequence if necessary       */
    if ( 3 < nr ) {
        PushStat( PopSeqStat( nr ) );
        nr = 1;
    }

    /* allocate the while-statement                                        */
    stat = NewStat( T_WHILE + (nr-1), sizeof(Expr) + nr * sizeof(Stat) );

    /* enter the statements                                                */
    for ( i = nr; 1 <= i; i-- ) {
        stat1 = PopStat();
        ADDR_STAT(stat)[i] = stat1;
    }

    /* enter the condition                                                 */
    cond = PopExpr();
    ADDR_STAT(stat)[0] = cond;

    /* push the while-statement                                            */
    PushStat( stat );
}

void            CodeWhileEnd ( void )
{
}


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
void            CodeRepeatBegin ( void )
{
}

void            CodeRepeatBeginBody ( void )
{
}

void            CodeRepeatEndBody (
    UInt                nr )
{
    /* leave the number of statements in the body on the expression stack  */
    PushExpr( INTEXPR_INT(nr) );
}

void            CodeRepeatEnd ( void )
{
    Stat                stat;           /* repeat-statement, result        */
    UInt                nr;             /* number of statements in body    */
    Expr                cond;           /* condition                       */
    Stat                stat1;          /* single statement of body        */
    Expr                tmp;            /* temporary                       */
    UInt                i;              /* loop variable                   */

    /* get the condition                                                   */
    cond = PopExpr();

    /* get the number of statements in the body                            */
    /* 'CodeUntil' left this number on the expression stack (hack)         */
    tmp = PopExpr();
    nr = INT_INTEXPR( tmp );

    /* collect the statements into a statement sequence if necessary       */
    if ( 3 < nr ) {
        PushStat( PopSeqStat( nr ) );
        nr = 1;
    }

    /* allocate the repeat-statement                                       */
    stat = NewStat( T_REPEAT + (nr-1), sizeof(Expr) + nr * sizeof(Stat) );

    /* enter the condition                                                 */
    ADDR_STAT(stat)[0] = cond;

    /* enter the statements                                                */
    for ( i = nr; 1 <= i; i-- ) {
        stat1 = PopStat();
        ADDR_STAT(stat)[i] = stat1;
    }

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
    stat = NewStat( T_BREAK, 0 * sizeof(Expr) );

    /* push the break-statement                                            */
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
void            CodeReturnObj ( void )
{
    Stat                stat;           /* return-statement, result        */
    Expr                expr;           /* expression                      */

    /* allocate the return-statement                                       */
    stat = NewStat( T_RETURN_OBJ, sizeof(Expr) );

    /* enter the expression                                                */
    expr = PopExpr();
    ADDR_STAT(stat)[0] = expr;

    /* push the return-statement                                           */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeReturnVoid()  . . . . . . . . . . . . . .  code return-void-statement
**
**  'CodeReturnVoid' is the action  to  code a return-void-statement.   It is
**  called when the reader encounters a 'return;'.
*/
void            CodeReturnVoid ( void )
{
    Stat                stat;           /* return-statement, result        */

    /* allocate the return-statement                                       */
    stat = NewStat( T_RETURN_VOID, 0 * sizeof(Expr) );

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
*F  CodeInv() . . . . . . . . . . . . . . . . . . . . . . code ^-1-expression
*F  CodeQuo() . . . . . . . . . . . . . . . . . . . . . . . code /-expression
*F  CodeMod() . . . . . . . . . . . . . . . . . . . . . . code mod-expression
*F  CodePow() . . . . . . . . . . . . . . . . . . . . . . . code ^-expression
**
**  'CodeOr', 'CodeAnd', 'CodeNot',  'CodeEq', 'CodeNe',  'CodeGt', 'CodeGe',
**  'CodeIn',  'CodeSum',  'CodeDiff', 'CodeProd', 'CodeQuo',  'CodeMod', and
**  'CodePow' are the actions to   code the respective operator  expressions.
**  They are called by the reader *after* *both* operands are read.
*/
void            CodeOrL ( void )
{
}

void            CodeOr ( void )
{
    PushBinaryOp( T_OR );
}

void            CodeAndL ( void )
{
}

void            CodeAnd ( void )
{
    PushBinaryOp( T_AND );
}

void            CodeNot ( void )
{
    PushUnaryOp( T_NOT );
}

void            CodeEq ( void )
{
    PushBinaryOp( T_EQ );
}

void            CodeNe ( void )
{
    PushBinaryOp( T_NE );
}

void            CodeLt ( void )
{
    PushBinaryOp( T_LT );
}

void            CodeGe ( void )
{
    PushBinaryOp( T_GE );
}

void            CodeGt ( void )
{
    PushBinaryOp( T_GT );
}

void            CodeLe ( void )
{
    PushBinaryOp( T_LE );
}

void            CodeIn ( void )
{
    PushBinaryOp( T_IN );
}

void            CodeSum ( void )
{
    PushBinaryOp( T_SUM );
}

void            CodeAInv ( void )
{
    Expr                expr;
    Int                 i;
    expr = PopExpr();
    if ( IS_INTEXPR(expr) && INT_INTEXPR(expr) != -(1L<<28) ) {
        i = INT_INTEXPR(expr);
        PushExpr( INTEXPR_INT( -i ) );
    }
    else {
        PushExpr( expr );
        PushUnaryOp( T_AINV );
    }
}

void            CodeDiff ( void )
{
    PushBinaryOp( T_DIFF );
}

void            CodeProd ( void )
{
    PushBinaryOp( T_PROD );
}

void            CodeInv ( void )
{
    PushUnaryOp( T_INV );
}

void            CodeQuo ( void )
{
    PushBinaryOp( T_QUO );
}

void            CodeMod ( void )
{
    PushBinaryOp( T_MOD );
}

void            CodePow ( void )
{
    PushBinaryOp( T_POW );
}


/****************************************************************************
**
*F  CodeIntExpr(<str>)  . . . . . . . . . . . code literal integer expression
**
**  'CodeIntExpr' is the action to code a literal integer expression.  <str>
**  is the integer as a (null terminated) C character string.
*/
void            CodeIntExpr (
    Char *              str )
{
    Expr                expr;           /* expression, result              */
    Obj                 val;            /* value = <upp> * <pow> + <low>    */
    Obj                 upp;            /* upper part                       */
    Int                 pow;            /* power                            */
    Int                 low;            /* lower part                       */
    Int                 sign;           /* is the integer negative          */
    UInt                i;              /* loop variable                    */

    /* get the signs, if any                                                */
    sign = 1;
    i = 0;
    while ( str[i] == '-' ) {
        sign = - sign;
        i++;
    }

    /* collect the digits in groups of 8                                    */
    low = 0;
    pow = 1;
    upp = INTOBJ_INT(0);
    while ( str[i] != '\0' ) {
        low = 10 * low + str[i] - '0';
        pow = 10 * pow;
        if ( pow == 100000000L ) {
            upp = SumInt( ProdInt( upp, INTOBJ_INT(pow) ),
                          INTOBJ_INT(sign*low) );
            pow = 1;
            low = 0;
        }
        i++;
    }

    /* compose the integer value (set <val> first to silence 'lint')       */
    val = 0;
    if ( upp == INTOBJ_INT(0) ) {
        val = INTOBJ_INT(sign*low);
    }
    else if ( pow == 1 ) {
        val = upp;
    }
    else {
        val = SumInt( ProdInt( upp, INTOBJ_INT(pow) ),
                      INTOBJ_INT(sign*low) );
    }

    /* if it is small enough code it immediately                           */
    if ( IS_INTOBJ(val) ) {
        expr = INTEXPR_INT( INT_INTOBJ(val) );
    }

    /* otherwise stuff the value into the values list                      */
    else {
        expr = NewExpr( T_INT_EXPR, sizeof(UInt2) + SIZE_OBJ(val) );
        ((UInt2*)ADDR_EXPR(expr))[0] = (Expr)sign;
        for ( i = 1; i < SIZE_EXPR(expr)/sizeof(UInt2); i++ ) {
            ((UInt2*)ADDR_EXPR(expr))[i] = ((UInt2*)ADDR_OBJ(val))[i-1];
        }
    }

    /* push the expression                                                 */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeTrueExpr()  . . . . . . . . . . . . . .  code literal true expression
**
**  'CodeTrueExpr' is the action to code a literal true expression.
*/
extern  void            CodeTrueExpr ( void )
{
    PushExpr( NewExpr( T_TRUE_EXPR, 0L ) );
}


/****************************************************************************
**
*F  CodeFalseExpr() . . . . . . . . . . . . . . code literal false expression
**
**  'CodeFalseExpr' is the action to code a literal false expression.
*/
extern  void            CodeFalseExpr ( void )
{
    PushExpr( NewExpr( T_FALSE_EXPR, 0L ) );
}


/****************************************************************************
**
*F  CodeCharExpr(<chr>) . . . . . . . . . code a literal character expression
**
**  'CodeCharExpr'  is the action  to  code a  literal  character expression.
**  <chr> is the C character.
*/
void            CodeCharExpr (
    Char                chr )
{
    Expr                litr;           /* literal expression, result      */

    /* allocate the character expression                                   */
    litr = NewExpr( T_CHAR_EXPR, sizeof(UChar) );
    ((UChar*)ADDR_EXPR(litr))[0] = chr;

    /* push the literal expression                                         */
    PushExpr( litr );
}


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
void            CodePermCycle (
    UInt                nrx,
    UInt                nrc )
{
    Expr                cycle;          /* cycle, result                   */
    Expr                entry;          /* entry of cycle                  */
    UInt                j;              /* loop variable                   */

    /* allocate the new cycle                                              */
    cycle = NewExpr( T_PERM_CYCLE, nrx * sizeof(Expr) );

    /* enter the entries                                                   */
    for ( j = nrx; 1 <= j; j-- ) {
        entry = PopExpr();
        ADDR_EXPR(cycle)[j-1] = entry;
    }

    /* push the cycle                                                      */
    PushExpr( cycle );
}

void            CodePerm (
    UInt                nrc )
{
    Expr                perm;           /* permutation, result             */
    Expr                cycle;          /* cycle of permutation            */
    UInt                i;              /* loop variable                   */

    /* allocate the new permutation                                        */
    perm = NewExpr( T_PERM_EXPR, nrc * sizeof(Expr) );

    /* enter the cycles                                                    */
    for ( i = nrc; 1 <= i; i-- ) {
        cycle = PopExpr();
        ADDR_EXPR(perm)[i-1] = cycle;
    }

    /* push the permutation                                                */
    PushExpr( perm );

}


/****************************************************************************
**
*F  CodeListExprBegin(<top>)  . . . . . . . . . . code list expression, begin
*F  CodeListExprBeginElm(<pos>) . . . . . code list expression, begin element
*F  CodeListExprEndElm()  . . . . . . .  .. code list expression, end element
*F  CodeListExprEnd(<nr>,<range>,<top>,<tilde>) . . code list expression, end
*/
void            CodeListExprBegin (
    UInt                top )
{
}

void            CodeListExprBeginElm (
    UInt                pos )
{
    /* push the literal integer value                                      */
    PushExpr( INTEXPR_INT(pos) );
}

void            CodeListExprEndElm ( void )
{
}

void            CodeListExprEnd (
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
        list = NewExpr( T_LIST_EXPR,      INT_INTEXPR(pos) * sizeof(Expr) );
    }
    else if ( ! range && (top && tilde) ) {
        list = NewExpr( T_LIST_TILD_EXPR, INT_INTEXPR(pos) * sizeof(Expr) );
    }
    else /* if ( range && ! (top && tilde) ) */ {
        list = NewExpr( T_RANGE_EXPR,     INT_INTEXPR(pos) * sizeof(Expr) );
    }

    /* enter the entries                                                   */
    for ( i = nr; 1 <= i; i-- ) {
        entry = PopExpr();
        pos   = PopExpr();
        ADDR_EXPR(list)[ INT_INTEXPR(pos)-1 ] = entry;
    }

    /* push the list                                                       */
    PushExpr( list );
}


/****************************************************************************
**
*F  CodeStringExpr(<str>) . . . . . . . . . .  code literal string expression
*/
void            CodeStringExpr (
    Char *              str )
{
    Expr                string;         /* string, result                  */

    /* allocate the string expression                                      */
    string = NewExpr( T_STRING_EXPR, SyStrlen(str)+1 );

    /* copy the string                                                     */
    SyStrncat( (Char*)ADDR_EXPR(string), str, SIZE_EXPR(string)-1 );

    /* push the string                                                     */
    PushExpr( string );
}


/****************************************************************************
**
*F  CodeRecExprBegin(<top>) . . . . . . . . . . . . . code record expr, begin
*F  CodeRecExprBeginElmName(<rnam>) . . . . . code record expr, begin element
*F  CodeRecExprBeginElmExpr() . . . . . . . . code record expr, begin element
*F  CodeRecExprEndElmExpr() . . . . . . . . . . code record expr, end element
*F  CodeRecExprEnd(<nr>,<top>,<tilde>)  . . . . . . . . code record expr, end
*/
void            CodeRecExprBegin (
    UInt                top )
{
}

void            CodeRecExprBeginElmName (
    UInt                rnam )
{
    /* push the record name as integer expressions                         */
    PushExpr( INTEXPR_INT( rnam ) );
}

void            CodeRecExprBeginElmExpr ( void )
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

void            CodeRecExprEndElm ( void )
{
}

void            CodeRecExprEnd (
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
        record = NewExpr( T_REC_EXPR,      nr * 2 * sizeof(Expr) );
    }
    else /* if ( (top && tilde) ) */ {
        record = NewExpr( T_REC_TILD_EXPR, nr * 2 * sizeof(Expr) );
    }

    /* enter the entries                                                   */
    for ( i = nr; 1 <= i; i-- ) {
        entry = PopExpr();
        rnam  = PopExpr();
        ADDR_EXPR(record)[2*(i-1)]   = rnam;
        ADDR_EXPR(record)[2*(i-1)+1] = entry;
    }

    /* push the record                                                     */
    PushExpr( record );
}


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
void            CodeAssLVar (
    UInt                lvar )
{
    Stat                ass;            /* assignment, result              */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    if ( lvar <= 16 ) {
        ass = NewStat( T_ASS_LVAR + lvar, 2 * sizeof(Stat) );
    }
    else {
        ass = NewStat( T_ASS_LVAR,        2 * sizeof(Stat) );
    }

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)rhsx;

    /* enter the local variable                                            */
    ADDR_STAT(ass)[0] = (Stat)lvar;

    /* push the assignment                                                 */
    PushStat( ass );
}

void            CodeUnbLVar (
    UInt                lvar )
{
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_LVAR, sizeof(Stat) );

    /* enter the local variable                                            */
    ADDR_STAT(ass)[0] = (Stat)lvar;

    /* push the unbind                                                     */
    PushStat( ass );
}


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
void            CodeRefLVar (
    UInt                lvar )
{
    Expr                ref;            /* reference, result               */

    /* make the reference                                                  */
    ref = REFLVAR_LVAR(lvar);

    /* push the reference                                                  */
    PushExpr( ref );
}

void            CodeIsbLVar (
    UInt                lvar )
{
    Expr                ref;            /* isbound, result                 */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_LVAR, sizeof(Expr) );

    /* enter the local variable                                            */
    ADDR_EXPR(ref)[0] = (Expr)lvar;

    /* push the isbound                                                    */
    PushExpr( ref );
}


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
void            CodeAssHVar (
    UInt                hvar )
{
    Stat                ass;            /* assignment, result              */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASS_HVAR, 2 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)rhsx;

    /* enter the higher variable                                           */
    ADDR_STAT(ass)[0] = (Stat)hvar;

    /* push the assignment                                                 */
    PushStat( ass );
}

void            CodeUnbHVar (
    UInt                hvar )
{
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_HVAR, sizeof(Stat) );

    /* enter the higher variable                                           */
    ADDR_STAT(ass)[0] = (Stat)hvar;

    /* push the unbind                                                     */
    PushStat( ass );
}


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
void            CodeRefHVar (
    UInt                hvar )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_REF_HVAR, sizeof(Expr) );

    /* enter the higher variable                                           */
    ADDR_EXPR(ref)[0] = (Expr)hvar;

    /* push the reference                                                  */
    PushExpr( ref );
}

void            CodeIsbHVar (
    UInt                hvar )
{
    Expr                ref;            /* isbound, result                 */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_HVAR, sizeof(Expr) );

    /* enter the higher variable                                           */
    ADDR_EXPR(ref)[0] = (Expr)hvar;

    /* push the isbound                                                    */
    PushExpr( ref );
}


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
void            CodeAssGVar (
    UInt                gvar )
{
    Stat                ass;            /* assignment, result              */
    Expr                rhsx;           /* right hand side expression      */

    /*  allocate the assignment                                            */
    ass = NewStat( T_ASS_GVAR, 2 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)rhsx;

    /* enter the global variable                                           */
    ADDR_STAT(ass)[0] = (Stat)gvar;

    /* push the assignment                                                 */
    PushStat( ass );
}

void            CodeUnbGVar (
    UInt                gvar )
{
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_GVAR, sizeof(Stat) );

    /* enter the global variable                                           */
    ADDR_STAT(ass)[0] = (Stat)gvar;

    /* push the unbind                                                     */
    PushStat( ass );
}


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
void            CodeRefGVar (
    UInt                gvar )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_REF_GVAR, sizeof(Expr) );

    /* enter the global variable                                           */
    ADDR_EXPR(ref)[0] = (Expr)gvar;

    /* push the reference                                                  */
    PushExpr( ref );
}

void            CodeIsbGVar (
    UInt                gvar )
{
    Expr                ref;            /* isbound, result                 */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_GVAR, sizeof(Expr) );

    /* enter the global variable                                           */
    ADDR_EXPR(ref)[0] = (Expr)gvar;

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssList() . . . . . . . . . . . . . . . . . code assignment to a list
*F  CodeAsssList()  . . . . . . . . . . .  code multiple assignment to a list
*F  CodeAssListLevel(<level>) . . . . . . .  code assignment to several lists
*F  CodeAsssListLevel(<level>)  . . code multiple assignment to several lists
*/
void            CodeAssListUniv (
    Stat                ass )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Expr                rhsx;           /* right hand side expression      */

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[2] = (Stat)rhsx;

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_STAT(ass)[0] = (Stat)list;

    /* push the assignment                                                 */
    PushStat( ass );
}

void            CodeAssList ( void )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASS_LIST, 3 * sizeof(Stat) );

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass );
}

void            CodeAsssList ( void )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASSS_LIST, 3 * sizeof(Stat) );

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass );
}

void            CodeAssListLevel (
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( T_ASS_LIST_LEV, 4 * sizeof(Stat) );
    ADDR_STAT(ass)[3] = (Stat)level;

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass );
}

void            CodeAsssListLevel (
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( T_ASSS_LIST_LEV, 4 * sizeof(Stat) );
    ADDR_STAT(ass)[3] = (Stat)level;

    /* let 'CodeAssListUniv' do the rest                                   */
    CodeAssListUniv( ass );
}

void            CodeUnbList ( void )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_LIST, 2 * sizeof(Stat) );

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_STAT(ass)[0] = (Stat)list;

    /* push the unbind                                                     */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeElmList() . . . . . . . . . . . . . . . . .  code selection of a list
*F  CodeElmsList()  . . . . . . . . . . . . code multiple selection of a list
*F  CodeElmListLevel(<level>) . . . . . . . . code selection of several lists
*F  CodeElmsListLevel(<level>)  . .  code multiple selection of several lists
*/
void            CodeElmListUniv (
    Expr                ref )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_EXPR(ref)[1] = pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_EXPR(ref)[0] = list;

    /* push the reference                                                  */
    PushExpr( ref );
}

void            CodeElmList ( void )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_ELM_LIST, 2 * sizeof(Expr) );

    /* let 'CodeElmListUniv' to the rest                                   */
    CodeElmListUniv( ref );
}

void            CodeElmsList ( void )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_ELMS_LIST, 2 * sizeof(Expr) );

    /* let 'CodeElmListUniv' to the rest                                   */
    CodeElmListUniv( ref );
}

void            CodeElmListLevel (
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( T_ELM_LIST_LEV, 3 * sizeof(Expr) );
    ADDR_EXPR(ref)[2] = (Stat)level;

    /* let 'CodeElmListUniv' do the rest                                   */
    CodeElmListUniv( ref );
}

void            CodeElmsListLevel (
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( T_ELMS_LIST_LEV, 3 * sizeof(Expr) );
    ADDR_EXPR(ref)[2] = (Stat)level;

    /* let 'CodeElmListUniv' do the rest                                   */
    CodeElmListUniv( ref );
}

void            CodeIsbList ( void )
{
    Expr                ref;            /* isbound, result                 */
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_LIST, 2 * sizeof(Expr) );

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_EXPR(ref)[1] = pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_EXPR(ref)[0] = list;

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssRecName(<rnam>)  . . . . . . . . . . . code assignment to a record
*F  CodeAssRecExpr()  . . . . . . . . . . . . . . code assignment to a record
*/
void            CodeAssRecName (
    UInt                rnam )
{
    Stat                stat;           /* assignment, result              */
    Expr                rec;            /* record expression               */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( T_ASS_REC_NAME, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(stat)[2] = (Stat)rhsx;

    /* enter the name                                                      */
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

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
    stat = NewStat( T_ASS_REC_EXPR, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(stat)[2] = (Stat)rhsx;

    /* enter the name expression                                           */
    rnam = PopExpr();
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the assignment                                                 */
    PushStat( stat );
}

void            CodeUnbRecName (
    UInt                rnam )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */

    /* allocate the unbind                                                 */
    stat = NewStat( T_UNB_REC_NAME, 2 * sizeof(Stat) );

    /* enter the name                                                      */
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the unbind                                                     */
    PushStat( stat );
}

void            CodeUnbRecExpr ( void )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */
    Expr                rnam;           /* name expression                 */

    /* allocate the unbind                                                 */
    stat = NewStat( T_UNB_REC_EXPR, 2 * sizeof(Stat) );

    /* enter the name expression                                           */
    rnam = PopExpr();
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the unbind                                                     */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeElmRecName(<rnam>)  . . . . . . . . . . .  code selection of a record
*F  CodeElmRecExpr()  . . . . . . . . . . . . . .  code selection of a record
*/
void            CodeElmRecName (
    UInt                rnam )
{
    Expr                expr;           /* reference, result               */
    Expr                rec;            /* record expresion                */

    /* allocate the reference                                              */
    expr = NewExpr( T_ELM_REC_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    ADDR_EXPR(expr)[1] = (Expr)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the reference                                                  */
    PushExpr( expr );
}

void            CodeElmRecExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expresion                */

    /* allocate the reference                                              */
    expr = NewExpr( T_ELM_REC_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    ADDR_EXPR(expr)[1] = rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the reference                                                  */
    PushExpr( expr );
}

void            CodeIsbRecName (
    UInt                rnam )
{
    Expr                expr;           /* isbound, result                 */
    Expr                rec;            /* record expresion                */

    /* allocate the isbound                                                */
    expr = NewExpr( T_ISB_REC_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    ADDR_EXPR(expr)[1] = (Expr)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the isbound                                                    */
    PushExpr( expr );
}

void            CodeIsbRecExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expresion                */

    /* allocate the isbound                                                */
    expr = NewExpr( T_ISB_REC_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    ADDR_EXPR(expr)[1] = rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the isbound                                                    */
    PushExpr( expr );
}


/****************************************************************************
**
*F  CodeAssPosObj() . . . . . . . . . . . . . . . . code assignment to a list
*F  CodeAsssPosObj()  . . . . . . . . . .  code multiple assignment to a list
*F  CodeAssPosObjLevel(<level>) . . . . . .  code assignment to several lists
*F  CodeAsssPosObjLevel(<level>)  . code multiple assignment to several lists
*/
void            CodeAssPosObjUniv (
    Stat                ass )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Expr                rhsx;           /* right hand side expression      */

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(ass)[2] = (Stat)rhsx;

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_STAT(ass)[0] = (Stat)list;

    /* push the assignment                                                 */
    PushStat( ass );
}

void            CodeAssPosObj ( void )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASS_POSOBJ, 3 * sizeof(Stat) );

    /* let 'CodeAssPosObjUniv' do the rest                                 */
    CodeAssPosObjUniv( ass );
}

void            CodeAsssPosObj ( void )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment                                             */
    ass = NewStat( T_ASSS_POSOBJ, 3 * sizeof(Stat) );

    /* let 'CodeAssPosObjUniv' do the rest                                 */
    CodeAssPosObjUniv( ass );
}

void            CodeAssPosObjLevel (
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( T_ASS_POSOBJ_LEV, 4 * sizeof(Stat) );
    ADDR_STAT(ass)[3] = (Stat)level;

    /* let 'CodeAssPosObjUniv' do the rest                                 */
    CodeAssPosObjUniv( ass );
}

void            CodeAsssPosObjLevel (
    UInt                level )
{
    Stat                ass;            /* assignment, result              */

    /* allocate the assignment and enter the level                         */
    ass = NewStat( T_ASSS_POSOBJ_LEV, 4 * sizeof(Stat) );
    ADDR_STAT(ass)[3] = (Stat)level;

    /* let 'CodeAssPosObjUniv' do the rest                                 */
    CodeAssPosObjUniv( ass );
}

void            CodeUnbPosObj ( void )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */
    Stat                ass;            /* unbind, result                  */

    /* allocate the unbind                                                 */
    ass = NewStat( T_UNB_POSOBJ, 2 * sizeof(Stat) );

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_STAT(ass)[1] = (Stat)pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_STAT(ass)[0] = (Stat)list;

    /* push the unbind                                                     */
    PushStat( ass );
}


/****************************************************************************
**
*F  CodeElmPosObj() . . . . . . . . . . . . . . . .  code selection of a list
*F  CodeElmsPosObj()  . . . . . . . . . . . code multiple selection of a list
*F  CodeElmPosObjLevel(<level>) . . . . . . . code selection of several lists
*F  CodeElmsPosObjLevel(<level>)  .  code multiple selection of several lists
*/
void            CodeElmPosObjUniv (
    Expr                ref )
{
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_EXPR(ref)[1] = pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_EXPR(ref)[0] = list;

    /* push the reference                                                  */
    PushExpr( ref );
}

void            CodeElmPosObj ( void )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_ELM_POSOBJ, 2 * sizeof(Expr) );

    /* let 'CodeElmPosObjUniv' to the rest                                   */
    CodeElmPosObjUniv( ref );
}

void            CodeElmsPosObj ( void )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference                                              */
    ref = NewExpr( T_ELMS_POSOBJ, 2 * sizeof(Expr) );

    /* let 'CodeElmPosObjUniv' to the rest                                   */
    CodeElmPosObjUniv( ref );
}

void            CodeElmPosObjLevel (
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( T_ELM_POSOBJ_LEV, 3 * sizeof(Expr) );
    ADDR_EXPR(ref)[2] = (Stat)level;

    /* let 'CodeElmPosObjUniv' do the rest                                 */
    CodeElmPosObjUniv( ref );
}

void            CodeElmsPosObjLevel (
    UInt                level )
{
    Expr                ref;            /* reference, result               */

    /* allocate the reference and enter the level                          */
    ref = NewExpr( T_ELMS_POSOBJ_LEV, 3 * sizeof(Expr) );
    ADDR_EXPR(ref)[2] = (Stat)level;

    /* let 'CodeElmPosObjUniv' do the rest                                 */
    CodeElmPosObjUniv( ref );
}

void            CodeIsbPosObj ( void )
{
    Expr                ref;            /* isbound, result                 */
    Expr                list;           /* list expression                 */
    Expr                pos;            /* position expression             */

    /* allocate the isbound                                                */
    ref = NewExpr( T_ISB_POSOBJ, 2 * sizeof(Expr) );

    /* enter the position expression                                       */
    pos = PopExpr();
    ADDR_EXPR(ref)[1] = pos;

    /* enter the list expression                                           */
    list = PopExpr();
    ADDR_EXPR(ref)[0] = list;

    /* push the isbound                                                    */
    PushExpr( ref );
}


/****************************************************************************
**
*F  CodeAssComObjName(<rnam>) . . . . . . . . . . code assignment to a record
*F  CodeAssComObjExpr() . . . . . . . . . . . . . code assignment to a record
*/
void            CodeAssComObjName (
    UInt                rnam )
{
    Stat                stat;           /* assignment, result              */
    Expr                rec;            /* record expression               */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( T_ASS_COMOBJ_NAME, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(stat)[2] = (Stat)rhsx;

    /* enter the name                                                      */
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the assignment                                                 */
    PushStat( stat );
}

void            CodeAssComObjExpr ( void )
{
    Stat                stat;           /* assignment, result              */
    Expr                rec;            /* record expression               */
    Expr                rnam;           /* name expression                 */
    Expr                rhsx;           /* right hand side expression      */

    /* allocate the assignment                                             */
    stat = NewStat( T_ASS_COMOBJ_EXPR, 3 * sizeof(Stat) );

    /* enter the right hand side expression                                */
    rhsx = PopExpr();
    ADDR_STAT(stat)[2] = (Stat)rhsx;

    /* enter the name expression                                           */
    rnam = PopExpr();
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the assignment                                                 */
    PushStat( stat );
}

void            CodeUnbComObjName (
    UInt                rnam )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */

    /* allocate the unbind                                                 */
    stat = NewStat( T_UNB_COMOBJ_NAME, 2 * sizeof(Stat) );

    /* enter the name                                                      */
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the unbind                                                     */
    PushStat( stat );
}

void            CodeUnbComObjExpr ( void )
{
    Stat                stat;           /* unbind, result                  */
    Expr                rec;            /* record expression               */
    Expr                rnam;           /* name expression                 */

    /* allocate the unbind                                                 */
    stat = NewStat( T_UNB_COMOBJ_EXPR, 2 * sizeof(Stat) );

    /* enter the name expression                                           */
    rnam = PopExpr();
    ADDR_STAT(stat)[1] = (Stat)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_STAT(stat)[0] = (Stat)rec;

    /* push the unbind                                                     */
    PushStat( stat );
}


/****************************************************************************
**
*F  CodeElmComObjName(<rnam>) . . . . . . . . . .  code selection of a record
*F  CodeElmComObjExpr() . . . . . . . . . . . . .  code selection of a record
*/
void            CodeElmComObjName (
    UInt                rnam )
{
    Expr                expr;           /* reference, result               */
    Expr                rec;            /* record expresion                */

    /* allocate the reference                                              */
    expr = NewExpr( T_ELM_COMOBJ_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    ADDR_EXPR(expr)[1] = (Expr)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the reference                                                  */
    PushExpr( expr );
}

void            CodeElmComObjExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expresion                */

    /* allocate the reference                                              */
    expr = NewExpr( T_ELM_COMOBJ_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    ADDR_EXPR(expr)[1] = rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the reference                                                  */
    PushExpr( expr );
}

void            CodeIsbComObjName (
    UInt                rnam )
{
    Expr                expr;           /* isbound, result                 */
    Expr                rec;            /* record expresion                */

    /* allocate the isbound                                                */
    expr = NewExpr( T_ISB_COMOBJ_NAME, 2 * sizeof(Expr) );

    /* enter the name                                                      */
    ADDR_EXPR(expr)[1] = (Expr)rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the isbound                                                    */
    PushExpr( expr );
}

void            CodeIsbComObjExpr ( void )
{
    Expr                expr;           /* reference, result               */
    Expr                rnam;           /* name expression                 */
    Expr                rec;            /* record expresion                */

    /* allocate the isbound                                                */
    expr = NewExpr( T_ISB_COMOBJ_EXPR, 2 * sizeof(Expr) );

    /* enter the expression                                                */
    rnam = PopExpr();
    ADDR_EXPR(expr)[1] = rnam;

    /* enter the record expression                                         */
    rec = PopExpr();
    ADDR_EXPR(expr)[0] = rec;

    /* push the isbound                                                    */
    PushExpr( expr );
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
void            CodeInfoBegin ( void )
{
}

void            CodeInfoMiddle ( void )
{
}

void            CodeInfoEnd   (
    UInt                narg )
{
    Stat                stat;           /* we build the statement here     */
    Expr                expr;           /* expression                      */
    UInt                i;              /* loop variable                   */

    /* allocate the new statement                                          */
    stat = NewStat( T_INFO, SIZE_NARG_INFO(2+narg) );

    /* narg only counts the printable arguments                            */
    for ( i = narg + 2; 0 < i; i-- ) {
        expr = PopExpr();
        ARGI_INFO( stat, i ) = expr;
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
void            CodeAssertBegin ( void )
{
}

void            CodeAssertAfterLevel ( void )
{
}

void            CodeAssertAfterCondition ( void )
{
}

void            CodeAssertEnd2Args ( void )
{
    Stat                stat;           /* we build the statement here     */

    stat = NewStat( T_ASSERT_2ARGS, 2*sizeof(Expr) );

    ADDR_STAT(stat)[1] = PopExpr(); /* condition */
    ADDR_STAT(stat)[0] = PopExpr(); /* level */

    PushStat( stat );
}

void            CodeAssertEnd3Args ( void )
{
    Stat                stat;           /* we build the statement here     */

    stat = NewStat( T_ASSERT_3ARGS, 3*sizeof(Expr) );

    ADDR_STAT(stat)[2] = PopExpr(); /* message */
    ADDR_STAT(stat)[1] = PopExpr(); /* condition */
    ADDR_STAT(stat)[0] = PopExpr(); /* level */

    PushStat( stat );
}


/****************************************************************************
**
*F  InitCode()  . . . . . . . . . . . . . . . .  initialize the coder package
**
**  'InitCode' initializes the coder package.
*/
void            InitCode ( void )
{
    /* make the result variable known to Gasman                            */
    InitGlobalBag( &CodeResult, "CodeResult" );

    /* allocate the statements and expressions stacks                      */
    InitGlobalBag( &StackStat, "StackStat" );
    StackStat = NewBag( T_BODY, 64*sizeof(Stat) );
    InitGlobalBag( &StackExpr, "StackExpr" );
    StackExpr = NewBag( T_BODY, 64*sizeof(Expr) );

    /* install the marking functions for function body bags                */
    InfoBags[         T_BODY           ].name = "function body bag";
    InitMarkFuncBags( T_BODY           , MarkNoSubBags );
}


/****************************************************************************
**
*E  code.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



