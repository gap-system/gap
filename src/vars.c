/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of variables package.
**
**  The variables  package is  the  part of   the interpreter  that  executes
**  assignments to variables and evaluates references to variables.
**
**  There are five  kinds of variables,  local variables (i.e., arguments and
**  locals), higher variables (i.e., local variables of enclosing functions),
**  global variables, list elements, and record elements.
*/

#include "vars.h"

#include "bool.h"
#include "calls.h"
#include "code.h"
#include "error.h"
#include "exprs.h"
#include "gap.h"
#include "gaputils.h"
#include "gvars.h"
#include "hookintrprtr.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "precord.h"
#include "records.h"
#include "saveload.h"
#include "stats.h"
#include "stringobj.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#include "hpc/guards.h"
#endif

#include <stdio.h>


/****************************************************************************
**
*V  CurrLVars   . . . . . . . . . . . . . . . . . . . . . local variables bag
**
**  'CurrLVars'  is the bag containing the  values  of the local variables of
**  the currently executing interpreted function.
**
**  Assignments  to  the local variables change   this bag.  We  do  not call
**  'CHANGED_BAG' for  each of such change.  Instead we wait until  a garbage
**  collection begins  and then  call  'CHANGED_BAG'  in  'BeginCollectBags'.
*/
/* TL: Bag CurrLVars; */


/****************************************************************************
**
*V  BottomLVars . . . . . . . . . . . . . . . . .  bottom local variables bag
**
**  'BottomLVars' is the local variables bag at the bottom of the call stack.
**  Without   such a dummy  frame at  the bottom, 'SWITCH_TO_NEW_LVARS' would
**  have to check for the bottom, slowing it down.
**
*/
static Bag BottomLVars;


/****************************************************************************
**
*V  PtrLVars  . . . . . . . . . . . . . . . .  pointer to local variables bag
**
**  'PtrLVars' is a pointer to the 'STATE(CurrLVars)' bag.  This  makes it faster to
**  access local variables.
**
**  Since   a   garbage collection may  move   this  bag  around, the pointer
**  'PtrLVars' must be recalculated afterwards in 'VarsAfterCollectBags'.
*/
/* TL: Obj * PtrLVars; */


/****************************************************************************
**
*F  ObjLVar(<lvar>) . . . . . . . . . . . . . . . . value of a local variable
**
**  'ObjLVar' returns the value of the local variable <lvar>.
*/
Obj             ObjLVar (
    UInt                lvar )
{
    Obj                 val;            /* value result                    */
    val = OBJ_LVAR(lvar);
    if (val == 0) {
        ErrorMayQuit("Variable: '%g' must have an assigned value",
                     (Int)NAME_LVAR(lvar), 0);
    }
    return val;
}


/****************************************************************************
**
*F  NewLVarsBag(<slots>) . . . . . . . . . . . . . . allocate a new LVars bag
**
**  'NewLVarsBag' allocates a new 'T_LVAR' bag, with the given number of
**  local variable <slots>. It tries to satisfy the request from a pool of
**  available LVars with up to 16 slots. If the request cannot be satisfied
**  from a pool, a new bag is allocated instead.
**
**  The pools are stored as single linked lists, for which 'PARENT_LVARS'
**  is abused.
*/
Bag NewLVarsBag(UInt slots)
{
    Bag result;
    if (slots < ARRAY_SIZE(STATE(LVarsPool))) {
        result = STATE(LVarsPool)[slots];
        if (result) {
            STATE(LVarsPool)[slots] = PARENT_LVARS(result);
            return result;
        }
    }
    return NewBag(T_LVARS, sizeof(LVarsHeader) + sizeof(Obj) * slots);
}


/****************************************************************************
**
*F  FreeLVarsBag(<slots>) . . . . . . . . . . . . . . . . . free an LVars bag
**
**  'FreeLVarsBag' returns an unused 'T_LVAR' bag to one of the 'LVarsPool',
**  assuming its size (resp. number of local variable slots) is not too big.
*/
void FreeLVarsBag(Bag bag)
{
    GAP_ASSERT(TNUM_OBJ(bag) == T_LVARS);
    UInt slots = (SIZE_BAG(bag) - sizeof(LVarsHeader)) / sizeof(Obj);
    if (slots < ARRAY_SIZE(STATE(LVarsPool))) {
        // clean the bag
        memset(PTR_BAG(bag), 0, SIZE_BAG(bag));
        // put it into the linked list of available LVars bags
        LVarsHeader * hdr = (LVarsHeader *)ADDR_OBJ(bag);
        hdr->parent = STATE(LVarsPool)[slots];
        STATE(LVarsPool)[slots] = bag;
    }
}


/****************************************************************************
**
*F  ExecAssLVar(<stat>) . . . . . . . . . assign to            local variable
**
**  'ExecAssLVar' executes the local  variable assignment statement <stat> to
**  the local variable that is referenced in <stat>.
*/
static ExecStatus ExecAssLVar(Stat stat)
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    rhs = EVAL_EXPR(READ_STAT(stat, 1));
    ASS_LVAR(READ_STAT(stat, 0), rhs);

    return STATUS_END;
}

static ExecStatus ExecUnbLVar(Stat stat)
{
    /* unbind the local variable                                           */
    ASS_LVAR(READ_STAT(stat, 0), (Obj)0);

    return STATUS_END;
}


static Obj EvalIsbLVar(Expr expr)
{
    Obj                 val;            /* value, result                   */

    /* get the value of the local variable                                 */
    val = OBJ_LVAR(READ_EXPR(expr, 0));

    /* return the value                                                    */
    return (val != (Obj)0 ? True : False);
}


/****************************************************************************
**
*F  PrintAssLVar(<stat>)  . . . . . . print an assignment to a local variable
**
**  'PrintAssLVar' prints the local variable assignment statement <stat>.
*/
static void PrintAssLVar(Stat stat)
{
    Pr("%2>", 0, 0);
    Pr("%H", (Int)NAME_LVAR(READ_STAT(stat, 0)), 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%2<;", 0, 0);
}

static void PrintUnbLVar(Stat stat)
{
    Pr("Unbind( ", 0, 0);
    Pr("%H", (Int)NAME_LVAR(READ_STAT(stat, 0)), 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintRefLVar(<expr>)  . . . . . . . print a reference to a local variable
**
**  'PrintRefLVar' prints the local variable reference expression <expr>.
*/
static void PrintRefLVar(Expr expr)
{
    Pr("%H", (Int)NAME_LVAR(LVAR_REF_LVAR(expr)), 0);
}

static void PrintIsbLVar(Expr expr)
{
    Pr("IsBound( ", 0, 0);
    Pr("%H", (Int)NAME_LVAR(READ_EXPR(expr, 0)), 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  ASS_HVAR(<hvar>,<val>)  . . . . . . . . . . . assign to a higher variable
*F  OBJ_HVAR(<hvar>)  . . . . . . . . . . . . . .  value of a higher variable
*F  NAME_HVAR(<hvar>) . . . . . . . . . . . . . . . name of a higher variable
**
**  'ASS_HVAR' assigns the value <val> to the higher variable <hvar>.
**
**  'OBJ_HVAR' returns the value of the higher variable <hvar>.
**
**  'NAME_HVAR' returns the name of the higher variable <hvar>.
*/
void ASS_HVAR(UInt hvar, Obj val)
{
    ASS_HVAR_WITH_CONTEXT(STATE(CurrLVars), hvar, val);
}

Obj OBJ_HVAR(UInt hvar)
{
    return OBJ_HVAR_WITH_CONTEXT(STATE(CurrLVars), hvar);
}

Obj NAME_HVAR(UInt hvar)
{
    return NAME_HVAR_WITH_CONTEXT(STATE(CurrLVars), hvar);
}

void ASS_HVAR_WITH_CONTEXT(Obj context, UInt hvar, Obj val)
{
    // walk up the environment chain to the correct values bag
    for (UInt i = 1; i <= (hvar >> MAX_FUNC_LVARS_BITS); i++) {
        context = ENVI_FUNC(FUNC_LVARS(context));
    }

    // assign the value
    ASS_LVAR_WITH_CONTEXT(context, hvar & MAX_FUNC_LVARS_MASK, val);
    CHANGED_BAG(context);
}

Obj OBJ_HVAR_WITH_CONTEXT(Obj context, UInt hvar)
{
    // walk up the environment chain to the correct values bag
    for (UInt i = 1; i <= (hvar >> MAX_FUNC_LVARS_BITS); i++) {
        context = ENVI_FUNC(FUNC_LVARS(context));
    }

    // get the value
    Obj val = OBJ_LVAR_WITH_CONTEXT(context, hvar & MAX_FUNC_LVARS_MASK);

    // return the value
    return val;
}

Obj NAME_HVAR_WITH_CONTEXT(Obj context, UInt hvar)
{
    // walk up the environment chain to the correct values bag
    for (UInt i = 1; i <= (hvar >> MAX_FUNC_LVARS_BITS); i++) {
        context = ENVI_FUNC(FUNC_LVARS(context));
    }

    // get the name
    return NAME_LVAR_WITH_CONTEXT(context, hvar & MAX_FUNC_LVARS_MASK);
}


/****************************************************************************
**
*F  ExecAssHVar(<stat>) . . . . . . . . . . . . . . assign to higher variable
**
**  'ExecAssHVar' executes the higher variable assignment statement <stat> to
**  the higher variable that is referenced in <stat>.
*/
static ExecStatus ExecAssHVar(Stat stat)
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the higher variable                   */
    rhs = EVAL_EXPR(READ_STAT(stat, 1));
    ASS_HVAR(READ_STAT(stat, 0), rhs);

    return STATUS_END;
}

static ExecStatus ExecUnbHVar(Stat stat)
{
    /* unbind the higher variable                                          */
    ASS_HVAR(READ_STAT(stat, 0), 0);

    return STATUS_END;
}


/****************************************************************************
**
*F  EvalRefHVar(<expr>) . . . . . . . . . . . . . .  value of higher variable
**
**  'EvalRefLVarXX' evaluates the higher variable reference expression <expr>
**  to the higher variable that is referenced in <expr>.
*/
static Obj EvalRefHVar(Expr expr)
{
    Obj                 val;            /* value, result                   */
    UInt                hvar = READ_EXPR(expr, 0);

    /* get and check the value of the higher variable                      */
    val = OBJ_HVAR(hvar);
    if (val == 0) {
        ErrorMayQuit("Variable: '%g' must have an assigned value",
                     (Int)NAME_HVAR(hvar), 0);
    }

    /* return the value                                                    */
    return val;
}

static Obj EvalIsbHVar(Expr expr)
{
    Obj                 val;            /* value, result                   */

    /* get the value of the higher variable                                */
    val = OBJ_HVAR(READ_EXPR(expr, 0));

    /* return the value                                                    */
    return (val != (Obj)0 ? True : False);
}


/****************************************************************************
**
*F  PrintAssHVar(<stat>)  . . . . . . . . print assignment to higher variable
**
**  'PrintAssHVar' prints the higher variable assignment statement <stat>.
*/
static void PrintAssHVar(Stat stat)
{
    Pr("%2>", 0, 0);
    Pr("%H", (Int)NAME_HVAR(READ_STAT(stat, 0)), 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%2<;", 0, 0);
}

static void PrintUnbHVar(Stat stat)
{
    Pr("Unbind( ", 0, 0);
    Pr("%H", (Int)NAME_HVAR(READ_STAT(stat, 0)), 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintRefHVar(<expr>) . . . . . . . . . print reference to higher variable
**
**  'PrintRefHVar' prints the higher variable reference expression <expr>.
*/
static void PrintRefHVar(Expr expr)
{
    Pr("%H", (Int)NAME_HVAR(READ_EXPR(expr, 0)), 0);
}

static void PrintIsbHVar(Expr expr)
{
    Pr("IsBound( ", 0, 0);
    Pr("%H", (Int)NAME_HVAR(READ_EXPR(expr, 0)), 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  ExecAssGVar(<stat>) . . . . . . . . . . . . . assign to a global variable
**
**  'ExecAssGVar' executes the global variable assignment statement <stat> to
**  the global variable that is referenced in <stat>.
*/
static ExecStatus ExecAssGVar(Stat stat)
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the global variable                   */
    rhs = EVAL_EXPR(READ_STAT(stat, 1));
    AssGVar(READ_STAT(stat, 0), rhs);

    return STATUS_END;
}

static ExecStatus ExecUnbGVar(Stat stat)
{
    /* unbind the global variable                                          */
    AssGVar(READ_STAT(stat, 0), (Obj)0);

    return STATUS_END;
}


/****************************************************************************
**
*F  EvalRefGVar(<expr>) . . . . . . . . . . . . . value of a globale variable
**
**  'EvalRefGVar' evaluates the  global variable reference expression  <expr>
**  to the global variable that is referenced in <expr>.
*/
static Obj EvalRefGVar(Expr expr)
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the global variable                      */
    val = ValAutoGVar(READ_EXPR(expr, 0));
    if (val == 0) {
        ErrorMayQuit("Variable: '%g' must have an assigned value",
                     (Int)NameGVar(READ_EXPR(expr, 0)), 0);
    }

    /* return the value                                                    */
    return val;
}

static Obj EvalIsbGVar(Expr expr)
{
    Obj                 val;            /* value, result                   */

    /* get the value of the global variable                                */
    val = ValAutoGVar(READ_EXPR(expr, 0));

    /* return the value                                                    */
    return (val != (Obj)0 ? True : False);
}


/****************************************************************************
**
*F  PrintAssGVar(<stat>)  . . . . .  print an assignment to a global variable
**
**  'PrVarAss' prints the global variable assignment statement <stat>.
*/
static void PrintAssGVar(Stat stat)
{
    Pr("%2>", 0, 0);
    Pr("%H", (Int)NameGVar(READ_STAT(stat, 0)), 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%2<;", 0, 0);
}

static void PrintUnbGVar(Stat stat)
{
    Pr("Unbind( ", 0, 0);
    Pr("%H", (Int)NameGVar(READ_STAT(stat, 0)), 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintRefGVar(<expr>)  . . . . . .  print a reference to a global variable
**
**  'PrintRefGVar' prints the global variable reference expression <expr>.
*/
static void PrintRefGVar(Expr expr)
{
    Pr("%H", (Int)NameGVar(READ_STAT(expr, 0)), 0);
}

static void PrintIsbGVar(Expr expr)
{
    Pr("IsBound( ", 0, 0);
    Pr("%H", (Int)NameGVar(READ_EXPR(expr, 0)), 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  ExecAssList(<ass>)  . . . . . . . . . . .  assign to an element of a list
**
**  'ExecAssList'  executes the list  assignment statement <stat> of the form
**  '<list>[<position>] := <rhs>;'.
*/
static ExecStatus ExecAssList(Expr stat)
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as C integer          */
    Obj                 rhs;            /* right hand side, right operand  */

    /* evaluate the list (checking is done by 'ASS_LIST')                  */
    list = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate the position                                               */
    pos = EVAL_EXPR(READ_STAT(stat, 1));

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR(READ_STAT(stat, 2));

    if (IS_POS_INTOBJ(pos)) {
        p = INT_INTOBJ(pos);

        /* special case for plain list                                     */
        if ( TNUM_OBJ(list) == T_PLIST ) {
            if ( LEN_PLIST(list) < p ) {
                GROW_PLIST( list, p );
                SET_LEN_PLIST( list, p );
            }
            SET_ELM_PLIST( list, p, rhs );
            CHANGED_BAG( list );
        }

        /* generic case                                                    */
        else {
            ASS_LIST( list, p, rhs );
        }
    } else {
        ASSB_LIST(list, pos, rhs);
    }

    return STATUS_END;
}
/****************************************************************************
**
*F  ExecAssMat(<ass>) . . . . . . . . . . .  assign to an element of a matrix
**
**  'ExecAssMat' executes the matrix assignment statement <stat> of the form
**  '<mat>[<row>,<col>] := <rhs>;'.
*/
static ExecStatus ExecAssMat(Expr stat)
{
    // evaluate the matrix (checking is done by 'ASS_MAT')
    Obj mat = EVAL_EXPR(READ_STAT(stat, 0));

    // evaluate and check the row and column
    Obj row = EVAL_EXPR(READ_STAT(stat, 1));
    Obj col = EVAL_EXPR(READ_STAT(stat, 2));

    // evaluate the right hand side
    Obj rhs = EVAL_EXPR(READ_STAT(stat, 3));

    ASS_MAT(mat, row, col, rhs);

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecAsssList(<stat>) . . . . . . . . assign to several elements of a list
**
**  'ExecAsssList' executes the list assignment statement  <stat> of the form
**  '<list>{<positions>} := <rhss>;'.
*/
static ExecStatus ExecAsssList(Expr stat)
{
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, left operand         */
    Obj                 rhss;           /* right hand sides, right operand */

    /* evaluate the list (checking is done by 'ASSS_LIST')                 */
    list = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR(READ_STAT(stat, 1));
    CheckIsPossList("List Assignments", poss);

    /* evaluate and check right hand sides                                 */
    rhss = EVAL_EXPR(READ_STAT(stat, 2));
    RequireDenseList("List Assignments", rhss);
    RequireSameLength("List Assignments", rhss, poss);

    /* assign the right hand sides to several elements of the list         */
    ASSS_LIST( list, poss, rhss );

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecAssListLevel(<stat>) . . . . . .  assign to elements of several lists
**
**  'ExecAssListLevel' executes the  list assignment statement  <stat> of the
**  form '<list>...{<positions>}...[<position>] :=  <rhss>;', where there may
**  actually be    several '{<positions>}'  selections  between  <list>   and
**  '[<position>]'.   The number of       those   is called    the     level.
**  'ExecAssListLevel' goes  that deep into  the left operand  and <rhss> and
**  assigns the  values from <rhss> to each  of those lists.  For example, if
**  the level is 1, the left operand must be a list  of lists, <rhss> must be
**  a  list, and 'ExecAssListLevel' assigns the  element '<rhss>[<i>]' to the
**  list '<list>[<i>]' at <position>.
*/
static ExecStatus ExecAssListLevel(Expr stat)
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */
    UInt                level;          /* level                           */
    Int narg,i;
    Obj ixs;

    /* evaluate lists (if this works, then <lists> is nested <level> deep, */
    /* checking it is nested <level>+1 deep is done by 'AssListLevel')     */
    lists = EVAL_EXPR(READ_STAT(stat, 0));
    narg = SIZE_STAT(stat)/sizeof(Stat) -3;
    ixs = NEW_PLIST(T_PLIST, narg);
    for (i = 1; i <= narg; i++) {
        pos = EVAL_EXPR(READ_STAT(stat, i));
        SET_ELM_PLIST(ixs, i, pos);
        CHANGED_BAG(ixs);
    }
    SET_LEN_PLIST(ixs, narg);

    /* evaluate right hand sides (checking is done by 'AssListLevel')      */
    rhss = EVAL_EXPR(READ_STAT(stat, narg + 1));

    /* get the level                                                       */
    level = READ_STAT(stat, narg + 2);

    /* assign the right hand sides to the elements of several lists        */
    AssListLevel( lists, ixs, rhss, level );

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecAsssListLevel(<stat>) . . assign to several elements of several lists
**
**  'ExecAsssListLevel' executes the list  assignment statement <stat> of the
**  form '<list>...{<positions>}...{<positions>} := <rhss>;', where there may
**  actually be   several  '{<positions>}'  selections  between   <list>  and
**  '{<positions>}'.   The  number   of    those   is  called   the    level.
**  'ExecAsssListLevel' goes  that deep into the left  operand and <rhss> and
**  assigns the sublists from <rhss> to each of those lists.  For example, if
**  the level is 1, the left operand must be a  list of lists, <rhss> must be
**  a list, and 'ExecAsssListLevel' assigns the elements '<rhss>[<i>]' to the
**  list '<list>[<i>]' at the positions <positions>.
*/
static ExecStatus ExecAsssListLevel(Expr stat)
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* position, left operand          */
    Obj                 rhss;           /* right hand sides, right operand */
    UInt                level;          /* level                           */

    /* evaluate lists (if this works, then <lists> is nested <level> deep, */
    /* checking it is nested <level>+1 deep is done by 'AsssListLevel')    */
    lists = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR(READ_EXPR(stat, 1));
    CheckIsPossList("List Assignments", poss);

    /* evaluate right hand sides (checking is done by 'AsssListLevel')     */
    rhss = EVAL_EXPR(READ_STAT(stat, 2));

    /* get the level                                                       */
    level = READ_STAT(stat, 3);

    /* assign the right hand sides to several elements of several lists    */
    AsssListLevel( lists, poss, rhss, level );

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecUnbList(<ass>)  . . . . . . . . . . . . . unbind an element of a list
**
**  'ExecUnbList'  executes the list   unbind  statement <stat> of the   form
**  'Unbind( <list>[<position>] );'.
*/
static ExecStatus ExecUnbList(Expr stat)
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Obj ixs;
    Int narg;
    Int i;

    /* evaluate the list (checking is done by 'UNB_LIST')                  */
    list = EVAL_EXPR(READ_STAT(stat, 0));
    narg = SIZE_STAT(stat)/sizeof(Stat) - 1;
    if (narg == 1) {
      pos = EVAL_EXPR( READ_STAT(stat, 1) );
      /* unbind the element                                                */
      if (IS_POS_INTOBJ(pos)) {
        UNB_LIST( list, INT_INTOBJ(pos) );
      } else {
        UNBB_LIST( list, pos );
      }
    } else {
      ixs = NEW_PLIST(T_PLIST, narg);
      for (i = 1; i <= narg; i++) {
        /* evaluate the position                                               */
        pos = EVAL_EXPR(READ_STAT(stat, i));
        SET_ELM_PLIST(ixs,i,pos);
        CHANGED_BAG(ixs);
      }
      SET_LEN_PLIST(ixs, narg);
      UNBB_LIST(list, ixs);
    }

    return STATUS_END;
}


/****************************************************************************
**
*F  EvalElmList(<expr>) . . . . . . . . . . . . . select an element of a list
**
**  'EvalElmList' evaluates the list  element expression  <expr> of the  form
**  '<list>[<position>]'.
*/
static Obj EvalElmList(Expr expr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* evaluate the list (checking is done by 'ELM_LIST')                  */
    list = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_EXPR(expr, 1));

    if (IS_POS_INTOBJ(pos)) {
        p = INT_INTOBJ( pos );

        /* special case for plain lists (use generic code to signal errors) */
        if ( IS_PLIST( list ) ) {
            if ( LEN_PLIST(list) < p ) {
                return ELM_LIST( list, p );
            }
            elm = ELM_PLIST( list, p );
            if ( elm == 0 ) {
                return ELM_LIST( list, p );
            }
        }
        /* generic case                                                    */
        else {
            elm = ELM_LIST( list, p );
        }
    } else {
        elm = ELMB_LIST(list, pos);
    }

    /* return the element                                                  */
    return elm;
}

/****************************************************************************
**
*F  EvalElmMat(<expr>) . . . . . . . . . . . .  select an element of a matrix
**
**  'EvalElmMat' evaluates the matrix element expression <expr> of the form
**  '<mat>[<row>,<col>]'.
*/
static Obj EvalElmMat(Expr expr)
{
    // evaluate the matrix (checking is done by 'ELM_MAT')
    Obj mat = EVAL_EXPR(READ_EXPR(expr, 0));

    // evaluate and check the row and column
    Obj row = EVAL_EXPR(READ_EXPR(expr, 1));
    Obj col = EVAL_EXPR(READ_EXPR(expr, 2));

    // return the element
    return ELM_MAT(mat, row, col);
}


/****************************************************************************
**
*F  EvalElmsList(<expr>)  . . . . . . . . . select several elements of a list
**
**  'EvalElmsList' evaluates the  list element expression  <expr> of the form
**  '<list>{<positions>}'.
*/
static Obj EvalElmsList(Expr expr)
{
    Obj                 elms;           /* elements, result                */
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, right operand        */

    /* evaluate the list (checking is done by 'ELMS_LIST')                 */
    list = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR(READ_EXPR(expr, 1));
    CheckIsPossList("List Elements", poss);

    /* select several elements from the list                               */
    elms = ELMS_LIST( list, poss );

    /* return the elements                                                 */
    return elms;
}


/****************************************************************************
**
*F  EvalElmListLevel(<expr>)  . . . . . . .  select elements of several lists
**
**  'EvalElmListLevel' evaluates the  list element  expression <expr> of  the
**  form '<list>...{<positions>}...[<position>]', where there may actually be
**  several '{<positions>}' selections   between <list> and   '[<position>]'.
**  The  number of those is called   the level.  'EvalElmListLevel' goes that
**  deep  into the left operand  and  selects the  element at <position> from
**  each of those  lists.  For example,  if the level  is 1, the left operand
**  must be a  list of lists  and 'EvalElmListLevel'  selects the element  at
**  <position> from each of the lists and returns the list of those values.
*/
static Obj EvalElmListLevel(Expr expr)
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 pos;            /* position, right operand         */
    Obj                 ixs;
    UInt                level;          /* level                           */
    Int narg;
    Int i;

    /* evaluate lists (if this works, then <lists> is nested <level> deep, */
    /* checking it is nested <level>+1 deep is done by 'ElmListLevel')     */
    lists = EVAL_EXPR(READ_EXPR(expr, 0));
    narg = SIZE_EXPR(expr)/sizeof(Expr) -2;
    ixs = NEW_PLIST(T_PLIST, narg);
    for (i = 1; i <= narg; i++) {
      pos = EVAL_EXPR( READ_EXPR(expr, i));
      SET_ELM_PLIST(ixs, i, pos);
      CHANGED_BAG(ixs);
    }
    SET_LEN_PLIST(ixs, narg);
    /* get the level                                                       */
    level = READ_EXPR(expr, narg + 1);

    /* select the elements from several lists (store them in <lists>)      */
    ElmListLevel( lists, ixs, level );

    /* return the elements                                                 */
    return lists;
}


/****************************************************************************
**
*F  EvalElmsListLevel(<expr>) . . .  select several elements of several lists
**
**  'EvalElmsListLevel' evaluates the  list element expression <expr>  of the
**  form '<list>...{<positions>}...{<positions>}',   where there may actually
**  be several '{<positions>}' selections between <list> and '{<positions>}'.
**  The  number of those is called  the level.  'EvalElmsListLevel' goes that
**  deep into  the left operand and selects  the elements at <positions> from
**  each of those lists.   For example, if the  level is 1, the left  operand
**  must be  a list of lists  and 'EvalElmsListLevel' selects the elements at
**  <positions>  from each   of the lists  and  returns   the  list  of those
**  sublists.
*/
static Obj EvalElmsListLevel(Expr expr)
{
    Obj                 lists;          /* lists, left operand             */
    Obj                 poss;           /* positions, right operand        */
    UInt                level;          /* level                           */

    /* evaluate lists (if this works, then <lists> is nested <level> deep, */
    /* checking it is nested <level>+1 deep is done by 'ElmsListLevel')    */
    lists = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR(READ_EXPR(expr, 1));
    CheckIsPossList("List Elements", poss);

    /* get the level                                                       */
    level = READ_EXPR(expr, 2);

    /* select several elements from several lists (store them in <lists>)  */
    ElmsListLevel( lists, poss, level );

    /* return the elements                                                 */
    return lists;
}


/****************************************************************************
**
*F  EvalIsbList(<expr>) . . . . . . . . test if an element of a list is bound
**
**  'EvalIsbList'  evaluates the list  isbound expression  <expr> of the form
**  'IsBound( <list>[<position>] )'.
*/
static Obj EvalIsbList(Expr expr)
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Obj ixs;
    Int narg, i;

    /* evaluate the list (checking is done by 'ISB_LIST')                  */
    list = EVAL_EXPR(READ_EXPR(expr, 0));
    narg = SIZE_EXPR(expr)/sizeof(Expr) -1;
    if (narg == 1) {
      /* evaluate and check the position                                   */
      pos = EVAL_EXPR(READ_EXPR(expr, 1));

      if (IS_POS_INTOBJ(pos))
        return ISB_LIST( list, INT_INTOBJ(pos) ) ? True : False;
      else
        return ISBB_LIST(list, pos) ? True : False;
    } else {
      ixs = NEW_PLIST(T_PLIST, narg);
      for (i = 1; i <= narg; i++) {
        pos = EVAL_EXPR( READ_EXPR(expr, i) );
        SET_ELM_PLIST(ixs,i,pos);
        CHANGED_BAG(ixs);
      }
      SET_LEN_PLIST(ixs, narg);
      return ISBB_LIST(list, ixs) ? True : False;
    }
        
}


/****************************************************************************
**
*F  PrintAssList(<stat>)  . . . . print an assignment to an element of a list
**
**  'PrintAssList' prints the list  assignment statement  <stat> of the  form
**  '<list>[<position>] := <rhs>;'.
**
**  Linebreaks are preferred before the ':='.
*/
static void PrintAssList(Stat stat)
{
    Pr("%4>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<[", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<]", 0, 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;", 0, 0);
}

static void PrintAssMat(Stat stat)
{
    Pr("%4>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<[", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<, %>", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%<]", 0, 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 3));
    Pr("%2<;", 0, 0);
}

static void PrintUnbList(Stat stat)
{
    Int narg = SIZE_STAT(stat)/sizeof(Stat) -1;
    Int i;
    Pr("Unbind( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<[", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    for (i = 2; i <= narg; i++) {
        Pr("%<, %>", 0, 0);
        PrintExpr(READ_EXPR(stat, i));
    }
    Pr("%<]", 0, 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintAsssList(<stat>) . print an assignment to several elements of a list
**
**  'PrintAsssList'  prints the list assignment  statement <stat> of the form
**  '<list>{<positions>} := <rhss>;'.
**
**  Linebreaks are preferred before the ':='.
*/
static void PrintAsssList(Stat stat)
{
    Pr("%4>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<{", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<}", 0, 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;", 0, 0);
}


/****************************************************************************
**
*F  PrintElmList(<expr>)  . . . . . print a selection of an element of a list
**
**  'PrintElmList'   prints the list element   expression  <expr> of the form
**  '<list>[<position>]'.
**
**  Linebreaks are preferred after the '['.
*/
static void PrintElmList(Expr expr)
{
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<[", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<]", 0, 0);
}

static void PrintElmMat(Expr expr)
{
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<[", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<, %<", 0, 0);
    PrintExpr(READ_EXPR(expr, 2));
    Pr("%<]", 0, 0);
}

static void PrintElmListLevel(Expr expr)
{
    Int i;
    Int narg = SIZE_EXPR(expr)/sizeof(Expr) -2 ;
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<[", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    for (i = 2; i <= narg; i++) {
        Pr("%<, %<", 0, 0);
        PrintExpr(READ_EXPR(expr, i));
    }
    Pr("%<]", 0, 0);
}


static void PrintIsbList(Expr expr)
{
    Int narg = SIZE_EXPR(expr)/sizeof(Expr) - 1;
    Int i;
    Pr("IsBound( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<[", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    for (i = 2; i <= narg; i++) {
        Pr("%<, %>", 0, 0);
        PrintExpr(READ_EXPR(expr, i));
    }
    Pr("%<]", 0, 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  PrintElmsList(<expr>) . . print a selection of several elements of a list
**
**  'PrintElmsList'  prints the list  elements  expression  <expr> of the   form
**  '<list>{<positions>}'.
**
**  Linebreaks are preferred after the '{'.
*/
static void PrintElmsList(Expr expr)
{
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<{", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<}", 0, 0);
}


/****************************************************************************
**
*F  ExecAssRecName(<stat>)  . . . . . . . .  assign to an element of a record
**
**  'ExecAssRecName' executes the record  assignment statement <stat>  of the
**  form '<record>.<name> := <rhs>;'.
*/
static ExecStatus ExecAssRecName(Stat stat)
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* evaluate the record (checking is done by 'ASS_REC')                 */
    record = EVAL_EXPR(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR(READ_STAT(stat, 2));

    /* assign the right hand side to the element of the record             */
    ASS_REC( record, rnam, rhs );

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecAssRecExpr(<stat>)  . . . . . . . .  assign to an element of a record
**
**  'ExecAssRecExpr'  executes the record assignment  statement <stat> of the
**  form '<record>.(<name>) := <rhs>;'.
*/
static ExecStatus ExecAssRecExpr(Stat stat)
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    /* evaluate the record (checking is done by 'ASS_REC')                 */
    record = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_STAT(stat, 1)));

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR(READ_STAT(stat, 2));

    /* assign the right hand side to the element of the record             */
    ASS_REC( record, rnam, rhs );

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecUnbRecName(<stat>)  . . . . . . . . . . unbind an element of a record
**
**  'ExecUnbRecName' executes the record  unbind statement <stat> of the form
**  'Unbind( <record>.<name> );'.
*/
static ExecStatus ExecUnbRecName(Stat stat)
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    record = EVAL_EXPR(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);

    /* unbind the element of the record                                    */
    UNB_REC( record, rnam );

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecUnbRecExpr(<stat>)  . . . . . . . . . . unbind an element of a record
**
**  'ExecUnbRecExpr' executes the record  unbind statement <stat> of the form
**  'Unbind( <record>.(<name>) );'.
*/
static ExecStatus ExecUnbRecExpr(Stat stat)
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    record = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_STAT(stat, 1)));

    /* unbind the element of the record                                    */
    UNB_REC( record, rnam );

    return STATUS_END;
}


/****************************************************************************
**
*F  EvalElmRecName(<expr>)  . . . . . . . . . . . . . select a record element
**
**  'EvalElmRecName' evaluates the   record element expression  <expr> of the
**  form '<record>.<name>'.
*/
static Obj EvalElmRecName(Expr expr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ELM_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);

    /* select the element of the record                                    */
    elm = ELM_REC( record, rnam );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalElmRecExpr(<expr>)  . . . . . . . . . . . . . select a record element
**
**  'EvalElmRecExpr'  evaluates the record   element expression <expr> of the
**  form '<record>.(<name>)'.
*/
static Obj EvalElmRecExpr(Expr expr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ELM_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_EXPR(expr, 1)));

    /* select the element of the record                                    */
    elm = ELM_REC( record, rnam );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalIsbRecName(<expr>)  . . . . . . . . test if a record element is bound
**
**  'EvalElmRecName' evaluates the   record isbound expression  <expr> of the
**  form 'IsBound( <record>.<name> )'.
*/
static Obj EvalIsbRecName(Expr expr)
{
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);

    return (ISB_REC( record, rnam ) ? True : False);
}


/****************************************************************************
**
*F  EvalIsbRecExpr(<expr>)  . . . . . . . . test if a record element is bound
**
**  'EvalIsbRecExpr' evaluates  the record isbound  expression  <expr> of the
**  form 'IsBound( <record>.(<name>) )'.
*/
static Obj EvalIsbRecExpr(Expr expr)
{
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_EXPR(expr, 1)));

    return (ISB_REC( record, rnam ) ? True : False);
}


/****************************************************************************
**
*F  PrintAssRecName(<stat>) . . print an assignment to an element of a record
**
**  'PrintAssRecName' prints the  record  assignment statement <stat>  of the
**  form '<record>.<name> := <rhs>;'.
*/
static void PrintAssRecName(Stat stat)
{
    Pr("%4>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<.", 0, 0);
    Pr("%H", (Int)NAME_RNAM(READ_STAT(stat, 1)), 0);
    Pr("%<", 0, 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;", 0, 0);
}

static void PrintUnbRecName(Stat stat)
{
    Pr("Unbind( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<.", 0, 0);
    Pr("%H", (Int)NAME_RNAM(READ_STAT(stat, 1)), 0);
    Pr("%<", 0, 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintAssRecExpr(<stat>) . . print an assignment to an element of a record
**
**  'PrintAssRecExpr' prints the  record  assignment statement <stat>  of the
**  form '<record>.(<name>) := <rhs>;'.
*/
static void PrintAssRecExpr(Stat stat)
{
    Pr("%4>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<.(", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr(")%<", 0, 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;", 0, 0);
}

static void PrintUnbRecExpr(Stat stat)
{
    Pr("Unbind( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<.(", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr(")%<", 0, 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintElmRecName(<expr>) . . . print a selection of an element of a record
**
**  'PrintElmRecName' prints the record element expression <expr> of the form
**  '<record>.<name>'.
*/
static void PrintElmRecName(Expr expr)
{
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<.", 0, 0);
    Pr("%H", (Int)NAME_RNAM(READ_EXPR(expr, 1)), 0);
    Pr("%<", 0, 0);
}

static void PrintIsbRecName(Expr expr)
{
    Pr("IsBound( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<.", 0, 0);
    Pr("%H", (Int)NAME_RNAM(READ_EXPR(expr, 1)), 0);
    Pr("%<", 0, 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  PrintElmRecExpr(<expr>) . . . print a selection of an element of a record
**
**  'PrintElmRecExpr' prints the record element expression <expr> of the form
**  '<record>.(<name>)'.
*/
static void PrintElmRecExpr(Expr expr)
{
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<.(", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr(")%<", 0, 0);
}

static void PrintIsbRecExpr(Expr expr)
{
    Pr("IsBound( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<.(", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr(")%<", 0, 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  ExecAssPosObj(<ass>)  . . . . . . . . .  assign to an element of a posobj
**
**  'ExecAssPosObj' executes the posobj assignment statement <stat> of the
**  form '<posobj>[<position>] := <rhs>;'.
*/
static ExecStatus ExecAssPosObj(Expr stat)
{
    Obj                 posobj;         // posobj, left operand
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as a C integer        */
    Obj                 rhs;            /* right hand side, right operand  */

    // evaluate the posobj (checking is done by 'AssPosObj')
    posobj = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_STAT(stat, 1));
    p = GetPositiveSmallIntEx("PosObj Assignment", pos, "<position>");

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR(READ_STAT(stat, 2));

    // special case for plain posobj
    AssPosObj(posobj, p, rhs);

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecUnbPosObj(<ass>)  . . . . . . . . . . . unbind an element of a posobj
**
**  'ExecUnbPosObj' executes the posobj unbind statement <stat> of the form
**  'Unbind( <posobj>[<position>] );'.
*/
static ExecStatus ExecUnbPosObj(Expr stat)
{
    Obj                 posobj;         // posobj, left operand
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as a C integer        */

    // evaluate the posobj (checking is done by 'UnbPosObj')
    posobj = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_STAT(stat, 1));
    p = GetPositiveSmallIntEx("PosObj Assignment", pos, "<position>");

    /* unbind the element                                                  */
    UnbPosObj(posobj, p);

    return STATUS_END;
}


/****************************************************************************
**
*F  EvalElmPosObj(<expr>) . . . . . . . . . . . select an element of a posobj
**
**  'EvalElmPosObj' evaluates the posobj element expression <expr> of the
**  form '<posobj>[<position>]'.
*/
static Obj EvalElmPosObj(Expr expr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 posobj;         // posobj, left operand
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    // evaluate the posobj (checking is done by 'ElmPosObj')
    posobj = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_EXPR(expr, 1));
    p = GetPositiveSmallIntEx("PosObj Element", pos, "<position>");

    // special case for plain posobjs (use generic code to signal errors)
    elm = ElmPosObj(posobj, p);

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalIsbPosObj(<expr>) . . . . . . test if an element of a posobj is bound
**
**  'EvalElmPosObj' evaluates the posobj isbound expression <expr> of the
**  form 'IsBound( <posobj>[<position>] )'.
*/
static Obj EvalIsbPosObj(Expr expr)
{
    Obj                 isb;            /* isbound, result                 */
    Obj                 posobj;         // posobj, left operand
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    // evaluate the posobj (checking is done by 'IsbPosObj')
    posobj = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_EXPR(expr, 1));
    p = GetPositiveSmallIntEx("PosObj Element", pos, "<position>");

    /* get the result                                                      */
    isb = IsbPosObj(posobj, p) ? True : False;

    return isb;
}


/****************************************************************************
**
*F  PrintAssPosObj(<stat>) . .  print an assignment to an element of a posobj
**
**  'PrintAssPosObj' prints the posobj assignment statement <stat> of the
**  form '<posobj>[<position>] := <rhs>;'.
**
**  Linebreaks are preferred before the ':='.
*/
static void PrintAssPosObj(Stat stat)
{
    Pr("%4>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<![", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<]", 0, 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;", 0, 0);
}

static void PrintUnbPosObj(Stat stat)
{
    Pr("Unbind( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<![", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<]", 0, 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintElmPosObj(<expr>) . . .  print a selection of an element of a posobj
**
**  'PrintElmPosObj' prints the posobj element expression <expr> of the form
**  '<posobj>[<position>]'.
**
**  Linebreaks are preferred after the '['.
*/
static void PrintElmPosObj(Expr expr)
{
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<![", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<]", 0, 0);
}

static void PrintIsbPosObj(Expr expr)
{
    Pr("IsBound( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<![", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<]", 0, 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  ExecAssComObjName(<stat>) . . . . . . .  assign to an element of a comobj
**
**  'ExecAssComObjName' executes the comobj assignment statement <stat> of
**  the form '<comobj>!.<name> := <rhs>;'.
*/
static ExecStatus ExecAssComObjName(Stat stat)
{
    Obj                 comobj;         // comobj, left operand
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    // evaluate the comobj (checking is done by 'AssComObj')
    comobj = EVAL_EXPR(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR(READ_STAT(stat, 2));

    // assign the right hand side to the element of the comobj
    AssComObj(comobj, rnam, rhs);

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecAssComObjExpr(<stat>) . . . . . . .  assign to an element of a comobj
**
**  'ExecAssComObjExpr' executes the comobj assignment statement <stat> of
**  the form '<comobj>.(<name>) := <rhs>;'.
*/
static ExecStatus ExecAssComObjExpr(Stat stat)
{
    Obj                 comobj;         // comobj, left operand
    UInt                rnam;           /* name, left operand              */
    Obj                 rhs;            /* rhs, right operand              */

    // evaluate the comobj (checking is done by 'AssComObj')
    comobj = EVAL_EXPR(READ_STAT(stat, 0));

    // evaluate the name and convert it to a comobj name
    rnam = RNamObj(EVAL_EXPR(READ_STAT(stat, 1)));

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR(READ_STAT(stat, 2));

    // assign the right hand side to the element of the comobj
    AssComObj(comobj, rnam, rhs);

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecUnbComObjName(<stat>) . . . . . . . . . unbind an element of a comobj
**
**  'ExecUnbComObjName' executes the comobj unbind statement <stat> of the
**  form 'Unbind( <comobj>.<name> );'.
*/
static ExecStatus ExecUnbComObjName(Stat stat)
{
    Obj                 comobj;         // comobj, left operand
    UInt                rnam;           /* name, left operand              */

    // evaluate the comobj (checking is done by 'UnbComObj')
    comobj = EVAL_EXPR(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);

    // unbind the element of the comobj
    UnbComObj(comobj, rnam);

    return STATUS_END;
}


/****************************************************************************
**
*F  ExecUnbComObjExpr(<stat>) . . . . . . . . . unbind an element of a comobj
**
**  'ExecUnbComObjExpr' executes the comobj unbind statement <stat> of the
**  form 'Unbind( <comobj>.(<name>) );'.
*/
static ExecStatus ExecUnbComObjExpr(Stat stat)
{
    Obj                 comobj;         // comobj, left operand
    UInt                rnam;           /* name, left operand              */

    // evaluate the comobj (checking is done by 'UnbComObj')
    comobj = EVAL_EXPR(READ_STAT(stat, 0));

    // evaluate the name and convert it to a comobj name
    rnam = RNamObj(EVAL_EXPR(READ_STAT(stat, 1)));

    // unbind the element of the comobj
    UnbComObj(comobj, rnam);

    return STATUS_END;
}


/****************************************************************************
**
*F  EvalElmComObjName(<expr>) . . . . . . . . . . . . select a comobj element
**
**  'EvalElmComObjName' evaluates the comobj element expression <expr> of the
**  form '<comobj>.<name>'.
*/
static Obj EvalElmComObjName(Expr expr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 comobj;         // the comobj, left operand
    UInt                rnam;           /* the name, right operand         */

    // evaluate the comobj (checking is done by 'ElmComObj')
    comobj = EVAL_EXPR(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);

    // select the element of the comobj
    elm = ElmComObj(comobj, rnam);

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalElmComObjExpr(<expr>) . . . . . . . . . . . . select a comobj element
**
**  'EvalElmComObjExpr' evaluates the comobj element expression <expr> of the
**  form '<comobj>.(<name>)'.
*/
static Obj EvalElmComObjExpr(Expr expr)
{
    Obj                 elm;            /* element, result                 */
    Obj                 comobj;         // the comobj, left operand
    UInt                rnam;           /* the name, right operand         */

    // evaluate the comobj (checking is done by 'ElmComObj')
    comobj = EVAL_EXPR(READ_EXPR(expr, 0));

    // evaluate the name and convert it to a comobj name
    rnam = RNamObj(EVAL_EXPR(READ_EXPR(expr, 1)));

    // select the element of the comobj
    elm = ElmComObj(comobj, rnam);

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalIsbComObjName(<expr>) . . . . . . . test if a comobj element is bound
**
**  'EvalIsbComObjName' evaluates the comobj isbound expression <expr> of the
**  form 'IsBound( <comobj>.<name> )'.
*/
static Obj EvalIsbComObjName(Expr expr)
{
    Obj                 isb;            /* element, result                 */
    Obj                 comobj;         // the comobj, left operand
    UInt                rnam;           /* the name, right operand         */

    // evaluate the comobj (checking is done by 'IsbComObj')
    comobj = EVAL_EXPR(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);

    // select the element of the comobj
    isb = IsbComObj(comobj, rnam) ? True : False;

    return isb;
}


/****************************************************************************
**
*F  EvalIsbComObjExpr(<expr>) . . . . . . . test if a comobj element is bound
**
**  'EvalIsbComObjExpr' evaluates the comobj isbound expression <expr> of the
**  form 'IsBound( <comobj>.(<name>) )'.
*/
static Obj EvalIsbComObjExpr(Expr expr)
{
    Obj                 isb;            /* element, result                 */
    Obj                 comobj;         // the comobj, left operand
    UInt                rnam;           /* the name, right operand         */

    // evaluate the comobj (checking is done by 'IsbComObj')
    comobj = EVAL_EXPR(READ_EXPR(expr, 0));

    // evaluate the name and convert it to a comobj name
    rnam = RNamObj(EVAL_EXPR(READ_EXPR(expr, 1)));

    // select the element of the comobj
    isb = IsbComObj(comobj, rnam) ? True : False;

    return isb;
}


/****************************************************************************
**
*F  PrintAssComObjName(<stat>) . print an assignment to an element of a comobj
**
**  'PrintAssComObjName' prints the comobj assignment statement <stat> of the
**  form '<comobj>.<name> := <rhs>;'.
*/
static void PrintAssComObjName(Stat stat)
{
    Pr("%4>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<!.", 0, 0);
    Pr("%H", (Int)NAME_RNAM(READ_STAT(stat, 1)), 0);
    Pr("%<", 0, 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;", 0, 0);
}

static void PrintUnbComObjName(Stat stat)
{
    Pr("Unbind( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<!.", 0, 0);
    Pr("%H", (Int)NAME_RNAM(READ_STAT(stat, 1)), 0);
    Pr("%<", 0, 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintAssComObjExpr(<stat>) . print an assignment to an element of a comobj
**
**  'PrintAssComObjExpr' prints the comobj assignment statement <stat> of the
**  form '<comobj>.(<name>) := <rhs>;'.
*/
static void PrintAssComObjExpr(Stat stat)
{
    Pr("%4>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<!.(", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr(")%<", 0, 0);
    Pr("%< %>:= ", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;", 0, 0);
}

static void PrintUnbComObjExpr(Stat stat)
{
    Pr("Unbind( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<!.(", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr(")%<", 0, 0);
    Pr(" );", 0, 0);
}


/****************************************************************************
**
*F  PrintElmComObjName(<expr>) .  print a selection of an element of a comobj
**
**  'PrintElmComObjName' prints the comobj element expression <expr> of the
**  form '<comobj>.<name>'.
*/
static void PrintElmComObjName(Expr expr)
{
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<!.", 0, 0);
    Pr("%H", (Int)NAME_RNAM(READ_EXPR(expr, 1)), 0);
    Pr("%<", 0, 0);
}

static void PrintIsbComObjName(Expr expr)
{
    Pr("IsBound( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<!.", 0, 0);
    Pr("%H", (Int)NAME_RNAM(READ_EXPR(expr, 1)), 0);
    Pr("%<", 0, 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  PrintElmComObjExpr(<expr>) .  print a selection of an element of a comobj
**
**  'PrintElmComObjExpr' prints the comobj element expression <expr> of the
**  form '<comobj>.(<name>)'.
*/
static void PrintElmComObjExpr(Expr expr)
{
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<!.(", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr(")%<", 0, 0);
}

static void PrintIsbComObjExpr(Expr expr)
{
    Pr("IsBound( ", 0, 0);
    Pr("%2>", 0, 0);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<!.(", 0, 0);
    PrintExpr(READ_EXPR(expr, 1));
    Pr(")%<", 0, 0);
    Pr(" )", 0, 0);
}


/****************************************************************************
**
*F  FuncGetCurrentLVars
*F  FuncGetBottomLVars
*F  FuncParentLVars
*F  FuncContentsLVars
**
**  Provide access to local variable bags at GAP level. Mainly for use in
**  error handling.
**
*/


static Obj FuncGetCurrentLVars(Obj self)
{
  // Need to promote to High Vars, else bag will be freed when function exits
  MakeHighVars(STATE(CurrLVars));
  return STATE(CurrLVars);
}

static Obj FuncGetBottomLVars(Obj self)
{
  return BottomLVars;
}

static Obj FuncParentLVars(Obj self, Obj lvars)
{
  if (!IS_LVARS_OR_HVARS(lvars)) {
      RequireArgument(SELF_NAME, lvars, "must be an lvars");
  }
  Obj parent = PARENT_LVARS(lvars);
  return parent ? parent : Fail;
}

static Obj FuncContentsLVars(Obj self, Obj lvars)
{
  if (!IS_LVARS_OR_HVARS(lvars)) {
      RequireArgument(SELF_NAME, lvars, "must be an lvars");
  }
  Obj contents = NEW_PREC(0);
  Obj func = FUNC_LVARS(lvars);
  Obj nams = NAMS_FUNC(func);
  UInt len = (SIZE_BAG(lvars) - 2*sizeof(Obj) - sizeof(UInt))/sizeof(Obj);
  Obj values = NEW_PLIST_IMM(T_PLIST, len);
  if (IsBottomLVars(lvars))
    return Fail;
  AssPRec(contents, RNamName("func"), func);
  AssPRec(contents, RNamName("names"), nams);
  memcpy(1+ADDR_OBJ(values), 3+CONST_ADDR_OBJ(lvars), len*sizeof(Obj));
  while (len > 0 && ELM_PLIST(values, len) == 0)
      len--;
  SET_LEN_PLIST(values, len);
  AssPRec(contents, RNamName("values"), values);
  if (!IsBottomLVars(ENVI_FUNC(func)))
    AssPRec(contents, RNamName("higher"), ENVI_FUNC(func));
  return contents;
}

static Obj FuncENVI_FUNC(Obj self, Obj func)
{
    RequireFunction(SELF_NAME, func);
    Obj envi = ENVI_FUNC(func);
    return (envi && IS_LVARS_OR_HVARS(envi)) ? envi : Fail;
}


/****************************************************************************
**
*F  IsBottomLVars(<lvars>) . .  check whether some lvars are the bottom lvars
**
*/
BOOL IsBottomLVars(Obj lvars)
{
    return lvars == BottomLVars;
}


/****************************************************************************
**
*F  SWITCH_TO_BOTTOM_LVARS( ) . . . . .  switch to bottom local variables bag
*/
Obj SWITCH_TO_BOTTOM_LVARS(void)
{
    return SWITCH_TO_OLD_LVARS(BottomLVars);
}


/****************************************************************************
**
*F  VarsBeforeCollectBags() . . . . . . . . actions before garbage collection
*F  VarsAfterCollectBags()  . . . . . . . .  actions after garbage collection
*/
#ifdef USE_GASMAN

static void VarsBeforeCollectBags(void)
{
  // As an optimization, we never call CHANGED_BAG on CurrLVars directly,
  // instead thus function is run just before any GC to take care of that.
  if (STATE(CurrLVars))
    CHANGED_BAG( STATE(CurrLVars) );
}

static void VarsAfterCollectBags(void)
{
  if (STATE(CurrLVars))
    {
      STATE(PtrLVars) = PTR_BAG( STATE(CurrLVars) );
      STATE(PtrBody)  = PTR_BAG( BODY_FUNC( CURR_FUNC() ) );
    }
}

#endif

/****************************************************************************
**
*F  SaveLVars ( <lvars> )
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveLVars(Obj lvars)
{
  UInt len,i;
  const Obj *ptr;
  const LVarsHeader * hdr = (const LVarsHeader *)CONST_ADDR_OBJ(lvars);
  SaveSubObj(hdr->func);
  SaveUInt(hdr->stat);
  SaveSubObj(hdr->parent);
  len = (SIZE_OBJ(lvars) - (2*sizeof(Obj)+sizeof(UInt)))/sizeof(Obj);
  ptr = CONST_ADDR_OBJ(lvars)+3;
  for (i = 0; i < len; i++)
    SaveSubObj(*ptr++);
}
#endif


/****************************************************************************
**
*F  LoadLVars ( <lvars> )
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadLVars(Obj lvars)
{
  UInt len,i;
  Obj *ptr;
  LVarsHeader * hdr = (LVarsHeader *)ADDR_OBJ(lvars);
  hdr->func = LoadSubObj();
  hdr->stat = LoadUInt();
  hdr->parent = LoadSubObj();
  len = (SIZE_OBJ(lvars) - (2*sizeof(Obj)+sizeof(UInt)))/sizeof(Obj);
  ptr = ADDR_OBJ(lvars)+3;
  for (i = 0; i < len; i++)
    *ptr++ = LoadSubObj();
}
#endif


static Obj TYPE_LVARS;

static Obj TypeLVars(Obj lvars)
{
  return TYPE_LVARS;
}

static void PrintLVars(Obj lvars)
{
  Pr("<lvars bag>", 0,0);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * Initialize Package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_LVARS, "values bag"         },
  { T_HVARS, "high variables bag" },
  { -1,      ""                   }
};

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {
  GVAR_FUNC_0ARGS(GetCurrentLVars),
  GVAR_FUNC_0ARGS(GetBottomLVars),
  GVAR_FUNC_1ARGS(ParentLVars, lvars),
  GVAR_FUNC_1ARGS(ContentsLVars, lvars),
  GVAR_FUNC_1ARGS(ENVI_FUNC, func),
  { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* make 'CurrLVars' known to Gasman                                    */
    InitGlobalBag( &STATE(CurrLVars),   "src/vars.c:CurrLVars"   );
    InitGlobalBag( &BottomLVars, "src/vars.c:BottomLVars" );

    enum { count = ARRAY_SIZE(STATE(LVarsPool)) };
    static char cookies[count][24];
    for (int i = 0; i < count; i++) {
      snprintf(cookies[i], sizeof(cookies[i]), "src/vars.c:LVarsPool%d", i);
      InitGlobalBag(&STATE(LVarsPool[i]), cookies[i]);
    }

    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking functions for local variables bag               */
    InitMarkFuncBags( T_LVARS, MarkAllButFirstSubBags );
    InitMarkFuncBags( T_HVARS, MarkAllButFirstSubBags );

#ifdef HPCGAP
    /* Make T_LVARS bags public */
    MakeBagTypePublic(T_LVARS);
    MakeBagTypePublic(T_HVARS);
#endif

#ifdef GAP_ENABLE_SAVELOAD
    /* and the save restore functions */
    SaveObjFuncs[ T_LVARS ] = SaveLVars;
    LoadObjFuncs[ T_LVARS ] = LoadLVars;
    SaveObjFuncs[ T_HVARS ] = SaveLVars;
    LoadObjFuncs[ T_HVARS ] = LoadLVars;
#endif

    /* and a type */
    TypeObjFuncs[ T_LVARS ] = TypeLVars;
    TypeObjFuncs[ T_HVARS ] = TypeLVars;
    PrintObjFuncs[ T_LVARS ] = PrintLVars;
    PrintObjFuncs[ T_HVARS ] = PrintLVars;

    /* install executors, evaluators, and printers for local variables     */
    InstallExecStatFunc( STAT_ASS_LVAR       , ExecAssLVar);
    InstallExecStatFunc( STAT_UNB_LVAR       , ExecUnbLVar);
    // no EvalExprFunc for EXPR_REF_LVAR, it is handled immediately by EVAL_EXPR
    InstallEvalExprFunc( EXPR_ISB_LVAR       , EvalIsbLVar);

    InstallPrintStatFunc( STAT_ASS_LVAR       , PrintAssLVar);
    InstallPrintStatFunc( STAT_UNB_LVAR       , PrintUnbLVar);
    InstallPrintExprFunc( EXPR_REF_LVAR        , PrintRefLVar);
    InstallPrintExprFunc( EXPR_ISB_LVAR       , PrintIsbLVar);

    /* install executors, evaluators, and printers for higher variables    */
    InstallExecStatFunc( STAT_ASS_HVAR       , ExecAssHVar);
    InstallExecStatFunc( STAT_UNB_HVAR       , ExecUnbHVar);
    InstallEvalExprFunc( EXPR_REF_HVAR       , EvalRefHVar);
    InstallEvalExprFunc( EXPR_ISB_HVAR       , EvalIsbHVar);
    InstallPrintStatFunc( STAT_ASS_HVAR       , PrintAssHVar);
    InstallPrintStatFunc( STAT_UNB_HVAR       , PrintUnbHVar);
    InstallPrintExprFunc( EXPR_REF_HVAR       , PrintRefHVar);
    InstallPrintExprFunc( EXPR_ISB_HVAR       , PrintIsbHVar);

    /* install executors, evaluators, and printers for global variables    */
    InstallExecStatFunc( STAT_ASS_GVAR       , ExecAssGVar);
    InstallExecStatFunc( STAT_UNB_GVAR       , ExecUnbGVar);
    InstallEvalExprFunc( EXPR_REF_GVAR       , EvalRefGVar);
    InstallEvalExprFunc( EXPR_ISB_GVAR       , EvalIsbGVar);
    InstallPrintStatFunc( STAT_ASS_GVAR       , PrintAssGVar);
    InstallPrintStatFunc( STAT_UNB_GVAR       , PrintUnbGVar);
    InstallPrintExprFunc( EXPR_REF_GVAR       , PrintRefGVar);
    InstallPrintExprFunc( EXPR_ISB_GVAR       , PrintIsbGVar);

    // install executors, evaluators, and printers for list elements
    InstallExecStatFunc( STAT_ASS_LIST       , ExecAssList);
    InstallExecStatFunc( STAT_ASSS_LIST      , ExecAsssList);
    InstallExecStatFunc( STAT_ASS_LIST_LEV   , ExecAssListLevel);
    InstallExecStatFunc( STAT_ASSS_LIST_LEV  , ExecAsssListLevel);
    InstallExecStatFunc( STAT_UNB_LIST       , ExecUnbList);
    InstallEvalExprFunc( EXPR_ELM_LIST       , EvalElmList);
    InstallEvalExprFunc( EXPR_ELMS_LIST      , EvalElmsList);
    InstallEvalExprFunc( EXPR_ELM_LIST_LEV   , EvalElmListLevel);
    InstallEvalExprFunc( EXPR_ELMS_LIST_LEV  , EvalElmsListLevel);
    InstallEvalExprFunc( EXPR_ISB_LIST       , EvalIsbList);

    InstallPrintStatFunc( STAT_ASS_LIST       , PrintAssList);
    InstallPrintStatFunc( STAT_ASSS_LIST      , PrintAsssList);
    InstallPrintStatFunc( STAT_ASS_LIST_LEV   , PrintAssList);
    InstallPrintStatFunc( STAT_ASSS_LIST_LEV  , PrintAsssList);
    InstallPrintStatFunc( STAT_UNB_LIST       , PrintUnbList);
    InstallPrintExprFunc( EXPR_ELM_LIST       , PrintElmList);
    InstallPrintExprFunc( EXPR_ELMS_LIST      , PrintElmsList);
    InstallPrintExprFunc( EXPR_ELM_LIST_LEV   , PrintElmListLevel);
    InstallPrintExprFunc( EXPR_ELMS_LIST_LEV  , PrintElmsList);
    InstallPrintExprFunc( EXPR_ISB_LIST       , PrintIsbList);

    // install executors, evaluators, and printers for matrix elements
    InstallExecStatFunc(STAT_ASS_MAT, ExecAssMat);
    InstallEvalExprFunc(EXPR_ELM_MAT, EvalElmMat);
    InstallPrintStatFunc(STAT_ASS_MAT, PrintAssMat);
    InstallPrintExprFunc(EXPR_ELM_MAT, PrintElmMat);

    // install executors, evaluators, and printers for record elements
    InstallExecStatFunc( STAT_ASS_REC_NAME   , ExecAssRecName);
    InstallExecStatFunc( STAT_ASS_REC_EXPR   , ExecAssRecExpr);
    InstallExecStatFunc( STAT_UNB_REC_NAME   , ExecUnbRecName);
    InstallExecStatFunc( STAT_UNB_REC_EXPR   , ExecUnbRecExpr);
    InstallEvalExprFunc( EXPR_ELM_REC_NAME   , EvalElmRecName);
    InstallEvalExprFunc( EXPR_ELM_REC_EXPR   , EvalElmRecExpr);
    InstallEvalExprFunc( EXPR_ISB_REC_NAME   , EvalIsbRecName);
    InstallEvalExprFunc( EXPR_ISB_REC_EXPR   , EvalIsbRecExpr);
    InstallPrintStatFunc( STAT_ASS_REC_NAME   , PrintAssRecName);
    InstallPrintStatFunc( STAT_ASS_REC_EXPR   , PrintAssRecExpr);
    InstallPrintStatFunc( STAT_UNB_REC_NAME   , PrintUnbRecName);
    InstallPrintStatFunc( STAT_UNB_REC_EXPR   , PrintUnbRecExpr);
    InstallPrintExprFunc( EXPR_ELM_REC_NAME   , PrintElmRecName);
    InstallPrintExprFunc( EXPR_ELM_REC_EXPR   , PrintElmRecExpr);
    InstallPrintExprFunc( EXPR_ISB_REC_NAME   , PrintIsbRecName);
    InstallPrintExprFunc( EXPR_ISB_REC_EXPR   , PrintIsbRecExpr);

    // install executors, evaluators, and printers for positional objects
    InstallExecStatFunc( STAT_ASS_POSOBJ       , ExecAssPosObj);
    InstallExecStatFunc( STAT_UNB_POSOBJ       , ExecUnbPosObj);
    InstallEvalExprFunc( EXPR_ELM_POSOBJ       , EvalElmPosObj);
    InstallEvalExprFunc( EXPR_ISB_POSOBJ       , EvalIsbPosObj);
    InstallPrintStatFunc( STAT_ASS_POSOBJ       , PrintAssPosObj);
    InstallPrintStatFunc( STAT_UNB_POSOBJ       , PrintUnbPosObj);
    InstallPrintExprFunc( EXPR_ELM_POSOBJ       , PrintElmPosObj);
    InstallPrintExprFunc( EXPR_ISB_POSOBJ       , PrintIsbPosObj);

    // install executors, evaluators, and printers for component objects
    InstallExecStatFunc( STAT_ASS_COMOBJ_NAME  , ExecAssComObjName);
    InstallExecStatFunc( STAT_ASS_COMOBJ_EXPR  , ExecAssComObjExpr);
    InstallExecStatFunc( STAT_UNB_COMOBJ_NAME  , ExecUnbComObjName);
    InstallExecStatFunc( STAT_UNB_COMOBJ_EXPR  , ExecUnbComObjExpr);
    InstallEvalExprFunc( EXPR_ELM_COMOBJ_NAME  , EvalElmComObjName);
    InstallEvalExprFunc( EXPR_ELM_COMOBJ_EXPR  , EvalElmComObjExpr);
    InstallEvalExprFunc( EXPR_ISB_COMOBJ_NAME  , EvalIsbComObjName);
    InstallEvalExprFunc( EXPR_ISB_COMOBJ_EXPR  , EvalIsbComObjExpr);
    InstallPrintStatFunc( STAT_ASS_COMOBJ_NAME  , PrintAssComObjName);
    InstallPrintStatFunc( STAT_ASS_COMOBJ_EXPR  , PrintAssComObjExpr);
    InstallPrintStatFunc( STAT_UNB_COMOBJ_NAME  , PrintUnbComObjName);
    InstallPrintStatFunc( STAT_UNB_COMOBJ_EXPR  , PrintUnbComObjExpr);
    InstallPrintExprFunc( EXPR_ELM_COMOBJ_NAME  , PrintElmComObjName);
    InstallPrintExprFunc( EXPR_ELM_COMOBJ_EXPR  , PrintElmComObjExpr);
    InstallPrintExprFunc( EXPR_ISB_COMOBJ_NAME  , PrintIsbComObjName);
    InstallPrintExprFunc( EXPR_ISB_COMOBJ_EXPR  , PrintIsbComObjExpr);

#ifdef USE_GASMAN
    /* install before and after actions for garbage collections            */
    RegisterBeforeCollectFuncBags(VarsBeforeCollectBags);
    RegisterAfterCollectFuncBags(VarsAfterCollectBags);
#endif

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    InitCopyGVar("TYPE_LVARS",&TYPE_LVARS);

    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    STATE(CurrLVars) = BottomLVars;
    SWITCH_TO_BOTTOM_LVARS();

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    Obj tmpFunc, tmpBody;

    BottomLVars = NewBag(T_HVARS, 3 * sizeof(Obj));
    tmpFunc = NewFunctionC( "bottom", 0, "", 0 );

    LVarsHeader * hdr = (LVarsHeader *)ADDR_OBJ(BottomLVars);
    hdr->func = tmpFunc;
    hdr->parent = Fail;
    tmpBody = NewFunctionBody();
    SET_BODY_FUNC( tmpFunc, tmpBody );

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    return PostRestore(module);
}


static Int InitModuleState(void)
{
#ifdef HPCGAP
    STATE(CurrLVars) = BottomLVars;
    SWITCH_TO_BOTTOM_LVARS();
#endif

    return 0;
}


/****************************************************************************
**
*F  InitInfoVars()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "vars",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoVars ( void )
{
    return &module;
}
