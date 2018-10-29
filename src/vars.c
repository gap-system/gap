/****************************************************************************
**
*W  vars.c                      GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
/* TL: Bag BottomLVars; */


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
    while ( (val = OBJ_LVAR(lvar)) == 0 ) {
        ErrorReturnVoid(
            "Variable: '%g' must have an assigned value",
            (Int)NAME_LVAR( lvar ), 0L,
            "you can 'return;' after assigning a value" );
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
    GAP_ASSERT(TNUM_OBJ(STATE(CurrLVars)) == T_LVARS);
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
UInt            ExecAssLVar (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the local variable                    */
    rhs = EVAL_EXPR(READ_STAT(stat, 1));
    ASS_LVAR(READ_STAT(stat, 0), rhs);

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecUnbLVar (
    Stat                stat )
{
    /* unbind the local variable                                           */
    ASS_LVAR(READ_STAT(stat, 0), (Obj)0);

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}



Obj             EvalIsbLVar (
    Expr                expr )
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
void            PrintAssLVar (
    Stat                stat )
{
    Pr( "%2>", 0L, 0L );
    Pr("%H", (Int)NAME_LVAR(READ_STAT(stat, 0)), 0L);
    Pr( "%< %>:= ", 0L, 0L );
    PrintExpr(READ_EXPR(stat, 1));
    Pr( "%2<;", 0L, 0L );
}

void            PrintUnbLVar (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%H", (Int)NAME_LVAR(READ_STAT(stat, 0)), 0L);
    Pr( " );", 0L, 0L );
}


/****************************************************************************
**
*F  PrintRefLVar(<expr>)  . . . . . . . print a reference to a local variable
**
**  'PrintRefLVar' prints the local variable reference expression <expr>.
*/
void            PrintRefLVar (
    Expr                expr )
{
    Pr( "%H", (Int)NAME_LVAR( LVAR_REFLVAR(expr) ), 0L );
}

void            PrintIsbLVar (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%H", (Int)NAME_LVAR(READ_EXPR(expr, 0)), 0L);
    Pr( " )", 0L, 0L );
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
UInt            ExecAssHVar (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the higher variable                   */
    rhs = EVAL_EXPR(READ_STAT(stat, 1));
    ASS_HVAR(READ_STAT(stat, 0), rhs);

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecUnbHVar (
    Stat                stat )
{
    /* unbind the higher variable                                          */
    ASS_HVAR(READ_STAT(stat, 0), 0);

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalRefHVar(<expr>) . . . . . . . . . . . . . .  value of higher variable
**
**  'EvalRefLVarXX' evaluates the higher variable reference expression <expr>
**  to the higher variable that is referenced in <expr>.
*/
Obj             EvalRefHVar (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */
    UInt                hvar = READ_EXPR(expr, 0);

    /* get and check the value of the higher variable                      */
    while ( (val = OBJ_HVAR(hvar)) == 0 ) {
        ErrorReturnVoid(
            "Variable: '%g' must have an assigned value",
            (Int)NAME_HVAR(hvar), 0L,
            "you can 'return;' after assigning a value" );
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalIsbHVar (
    Expr                expr )
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
void            PrintAssHVar (
    Stat                stat )
{
    Pr( "%2>", 0L, 0L );
    Pr("%H", (Int)NAME_HVAR(READ_STAT(stat, 0)), 0L);
    Pr( "%< %>:= ", 0L, 0L );
    PrintExpr(READ_EXPR(stat, 1));
    Pr( "%2<;", 0L, 0L );
}

void            PrintUnbHVar (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%H", (Int)NAME_HVAR(READ_STAT(stat, 0)), 0L);
    Pr( " );", 0L, 0L );
}


/****************************************************************************
**
*F  PrintRefHVar(<expr>) . . . . . . . . . print reference to higher variable
**
**  'PrintRefHVar' prints the higher variable reference expression <expr>.
*/
void            PrintRefHVar (
    Expr                expr )
{
    Pr("%H", (Int)NAME_HVAR(READ_EXPR(expr, 0)), 0L);
}

void            PrintIsbHVar (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%H", (Int)NAME_HVAR(READ_EXPR(expr, 0)), 0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  ExecAssGVar(<stat>) . . . . . . . . . . . . . assign to a global variable
**
**  'ExecAssGVar' executes the global variable assignment statement <stat> to
**  the global variable that is referenced in <stat>.
*/
UInt            ExecAssGVar (
    Stat                stat )
{
    Obj                 rhs;            /* value of right hand side        */

    /* assign the right hand side to the global variable                   */
    rhs = EVAL_EXPR(READ_STAT(stat, 1));
    AssGVar(READ_STAT(stat, 0), rhs);

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecUnbGVar (
    Stat                stat )
{
    /* unbind the global variable                                          */
    AssGVar(READ_STAT(stat, 0), (Obj)0);

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalRefGVar(<expr>) . . . . . . . . . . . . . value of a globale variable
**
**  'EvalRefGVar' evaluates the  global variable reference expression  <expr>
**  to the global variable that is referenced in <expr>.
*/
Obj             EvalRefGVar (
    Expr                expr )
{
    Obj                 val;            /* value, result                   */

    /* get and check the value of the global variable                      */
    while ( (val = ValAutoGVar( READ_EXPR(expr, 0) )) == 0 ) {
        ErrorReturnVoid(
            "Variable: '%g' must have an assigned value",
            (Int)NameGVar( READ_EXPR(expr, 0) ), 0L,
            "you can 'return;' after assigning a value" );
    }

    /* return the value                                                    */
    return val;
}

Obj             EvalIsbGVar (
    Expr                expr )
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
void            PrintAssGVar (
    Stat                stat )
{
    Pr( "%2>", 0L, 0L );
    Pr("%H", (Int)NameGVar(READ_STAT(stat, 0)), 0L);
    Pr( "%< %>:= ", 0L, 0L );
    PrintExpr(READ_EXPR(stat, 1));
    Pr( "%2<;", 0L, 0L );
}

void            PrintUnbGVar (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%H", (Int)NameGVar(READ_STAT(stat, 0)), 0L);
    Pr( " );", 0L, 0L );
}


/****************************************************************************
**
*F  PrintRefGVar(<expr>)  . . . . . .  print a reference to a global variable
**
**  'PrintRefGVar' prints the global variable reference expression <expr>.
*/
void            PrintRefGVar (
    Expr                expr )
{
    Pr("%H", (Int)NameGVar(READ_STAT(expr, 0)), 0L);
}

void            PrintIsbGVar (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%H", (Int)NameGVar(READ_EXPR(expr, 0)), 0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  ExecAssList(<ass>)  . . . . . . . . . . .  assign to an element of a list
**
**  'ExecAssList'  executes the list  assignment statement <stat> of the form
**  '<list>[<position>] := <rhs>;'.
*/
UInt            ExecAssList (
    Expr                stat )
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

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}
/****************************************************************************
**
*F  ExecAss2List(<ass>)  . . . . . . . . . . .  assign to an element of a list
**
**  'ExecAss2List'  executes the list  assignment statement <stat> of the form
**  '<list>[<position>,<position>] := <rhs>;'.
*/
UInt            ExecAss2List (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos1;           /* position, left operand          */
    Obj                 pos2;           /* position, left operand          */
    Obj                 rhs;            /* right hand side, right operand  */

    /* evaluate the list (checking is done by 'ASS_LIST')                  */
    list = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate the position                                               */
    pos1 = EVAL_EXPR(READ_STAT(stat, 1));
    pos2 = EVAL_EXPR(READ_STAT(stat, 2));

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR(READ_STAT(stat, 3));

    ASS2_LIST( list, pos1, pos2, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecAsssList(<stat>) . . . . . . . . assign to several elements of a list
**
**  'ExecAsssList' executes the list assignment statement  <stat> of the form
**  '<list>{<positions>} := <rhss>;'.
*/
UInt            ExecAsssList (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 poss;           /* positions, left operand         */
    Obj                 rhss;           /* right hand sides, right operand */

    /* evaluate the list (checking is done by 'ASSS_LIST')                 */
    list = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate and check the positions                                    */
    poss = EVAL_EXPR(READ_STAT(stat, 1));
    CheckIsPossList("List Assignment", poss);

    /* evaluate and check right hand sides                                 */
    rhss = EVAL_EXPR(READ_STAT(stat, 2));
    CheckIsDenseList("List Assignment", "rhss", rhss);
    CheckSameLength("List Assignment", "rhss", "positions", rhss, poss);

    /* assign the right hand sides to several elements of the list         */
    ASSS_LIST( list, poss, rhss );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
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
UInt            ExecAssListLevel (
    Expr                stat )
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

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
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
UInt            ExecAsssListLevel (
    Expr                stat )
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
    CheckIsPossList("List Assignment", poss);

    /* evaluate right hand sides (checking is done by 'AsssListLevel')     */
    rhss = EVAL_EXPR(READ_STAT(stat, 2));

    /* get the level                                                       */
    level = READ_STAT(stat, 3);

    /* assign the right hand sides to several elements of several lists    */
    AsssListLevel( lists, poss, rhss, level );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbList(<ass>)  . . . . . . . . . . . . . unbind an element of a list
**
**  'ExecUnbList'  executes the list   unbind  statement <stat> of the   form
**  'Unbind( <list>[<position>] );'.
*/
UInt            ExecUnbList (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Obj ixs;
    Int narg;
    Int i;

    /* evaluate the list (checking is done by 'LEN_LIST')                  */
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
    

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalElmList(<expr>) . . . . . . . . . . . . . select an element of a list
**
**  'EvalElmList' evaluates the list  element expression  <expr> of the  form
**  '<list>[<position>]'.
*/
Obj             EvalElmList (
    Expr                expr )
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
*F  EvalElm2List(<expr>) . . . . . . . . . . . . select an element of a list
**
**  'EvalElm2List' evaluates the list  element expression  <expr> of the  form
**  '<list>[<pos1>,<pos2>]'.
*/
Obj             EvalElm2List (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos1;           /* position, right operand         */
    Obj                 pos2;           /* position, right operand         */

    /* evaluate the list (checking is done by 'ELM2_LIST')                 */
    list = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate and check the positions                                    */
    pos1 = EVAL_EXPR(READ_EXPR(expr, 1));
    pos2 = EVAL_EXPR(READ_EXPR(expr, 2));

    elm = ELM2_LIST(list, pos1, pos2);

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalElmsList(<expr>)  . . . . . . . . . select several elements of a list
**
**  'EvalElmsList' evaluates the  list element expression  <expr> of the form
**  '<list>{<positions>}'.
*/
Obj             EvalElmsList (
    Expr                expr )
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
Obj             EvalElmListLevel (
    Expr                expr )
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
Obj             EvalElmsListLevel (
    Expr                expr )
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
Obj             EvalIsbList (
    Expr                expr )
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
void            PrintAssList (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<[",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<]",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;",0L,0L);
}

void            PrintAss2List (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<[",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<, %>",0L,0L);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%<]",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr(READ_EXPR(stat, 3));
    Pr("%2<;",0L,0L);
}

void            PrintUnbList (
    Stat                stat )
{
  Int narg = SIZE_STAT(stat)/sizeof(Stat) -1;
  Int i;
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<[",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    for (i = 2; i <= narg; i++) {
      Pr("%<, %>",0L,0L);
      PrintExpr(READ_EXPR(stat, i));
    }
    Pr("%<]",0L,0L);
    Pr( " );", 0L, 0L );
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
void            PrintAsssList (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<{",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<}",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;",0L,0L);
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
void            PrintElmList (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<[",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<]",0L,0L);
}

void PrintElm2List (
		     Expr expr )
{
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<[",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<, %<",0L,0L);
    PrintExpr(READ_EXPR(expr, 2));
    Pr("%<]",0L,0L);
}

void PrintElmListLevel (
		     Expr expr )
{
  Int i;
  Int narg = SIZE_EXPR(expr)/sizeof(Expr) -2 ;
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<[",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    for (i = 2; i <= narg; i++) {
      Pr("%<, %<",0L,0L);
      PrintExpr(READ_EXPR(expr, i));
    }
    Pr("%<]",0L,0L);
}


void            PrintIsbList (
    Expr                expr )
{
  Int narg = SIZE_EXPR(expr)/sizeof(Expr) - 1;
  Int i;
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<[",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    for (i = 2; i <= narg; i++) {
      Pr("%<, %>", 0L, 0L);
      PrintExpr(READ_EXPR(expr, i));
    }
    Pr("%<]",0L,0L);
    Pr( " )", 0L, 0L );
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
void            PrintElmsList (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<{",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<}",0L,0L);
}


/****************************************************************************
**
*F  ExecAssRecName(<stat>)  . . . . . . . .  assign to an element of a record
**
**  'ExecAssRecName' executes the record  assignment statement <stat>  of the
**  form '<record>.<name> := <rhs>;'.
*/
UInt            ExecAssRecName (
    Stat                stat )
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

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecAssRecExpr(<stat>)  . . . . . . . .  assign to an element of a record
**
**  'ExecAssRecExpr'  executes the record assignment  statement <stat> of the
**  form '<record>.(<name>) := <rhs>;'.
*/
UInt            ExecAssRecExpr (
    Stat                stat )
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

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbRecName(<stat>)  . . . . . . . . . . unbind an element of a record
**
**  'ExecUnbRecName' executes the record  unbind statement <stat> of the form
**  'Unbind( <record>.<name> );'.
*/
UInt            ExecUnbRecName (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    record = EVAL_EXPR(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);

    /* unbind the element of the record                                    */
    UNB_REC( record, rnam );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbRecExpr(<stat>)  . . . . . . . . . . unbind an element of a record
**
**  'ExecUnbRecExpr' executes the record  unbind statement <stat> of the form
**  'Unbind( <record>.(<name>) );'.
*/
UInt            ExecUnbRecExpr (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    record = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_STAT(stat, 1)));

    /* unbind the element of the record                                    */
    UNB_REC( record, rnam );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalElmRecName(<expr>)  . . . . . . . . . . . . . select a record element
**
**  'EvalElmRecName' evaluates the   record element expression  <expr> of the
**  form '<record>.<name>'.
*/
Obj             EvalElmRecName (
    Expr                expr )
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
Obj             EvalElmRecExpr (
    Expr                expr )
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
Obj             EvalIsbRecName (
    Expr                expr )
{
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);

    /* return the result                                                   */
    return (ISB_REC( record, rnam ) ? True : False);
}


/****************************************************************************
**
*F  EvalIsbRecExpr(<expr>)  . . . . . . . . test if a record element is bound
**
**  'EvalIsbRecExpr' evaluates  the record isbound  expression  <expr> of the
**  form 'IsBound( <record>.(<name>) )'.
*/
Obj             EvalIsbRecExpr (
    Expr                expr )
{
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_EXPR(expr, 1)));

    /* return the result                                                   */
    return (ISB_REC( record, rnam ) ? True : False);
}


/****************************************************************************
**
*F  PrintAssRecName(<stat>) . . print an assignment to an element of a record
**
**  'PrintAssRecName' prints the  record  assignment statement <stat>  of the
**  form '<record>.<name> := <rhs>;'.
*/
void            PrintAssRecName (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<.",0L,0L);
    Pr("%H", (Int)NAME_RNAM(READ_STAT(stat, 1)), 0L);
    Pr("%<",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;",0L,0L);
}

void            PrintUnbRecName (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<.",0L,0L);
    Pr("%H", (Int)NAME_RNAM(READ_STAT(stat, 1)), 0L);
    Pr("%<",0L,0L);
    Pr( " );", 0L, 0L );
}


/****************************************************************************
**
*F  PrintAssRecExpr(<stat>) . . print an assignment to an element of a record
**
**  'PrintAssRecExpr' prints the  record  assignment statement <stat>  of the
**  form '<record>.(<name>) := <rhs>;'.
*/
void            PrintAssRecExpr (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<.(",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr(")%<",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;",0L,0L);
}

void            PrintUnbRecExpr (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<.(",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr(")%<",0L,0L);
    Pr( " );", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmRecName(<expr>) . . . print a selection of an element of a record
**
**  'PrintElmRecName' prints the record element expression <expr> of the form
**  '<record>.<name>'.
*/
void            PrintElmRecName (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<.",0L,0L);
    Pr("%H", (Int)NAME_RNAM(READ_EXPR(expr, 1)), 0L);
    Pr("%<",0L,0L);
}

void            PrintIsbRecName (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<.",0L,0L);
    Pr("%H", (Int)NAME_RNAM(READ_EXPR(expr, 1)), 0L);
    Pr("%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmRecExpr(<expr>) . . . print a selection of an element of a record
**
**  'PrintElmRecExpr' prints the record element expression <expr> of the form
**  '<record>.(<name>)'.
*/
void            PrintElmRecExpr (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<.(",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr(")%<",0L,0L);
}

void            PrintIsbRecExpr (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<.(",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr(")%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  ExecAssPosObj(<ass>)  . . . . . . . . . . .  assign to an element of a list
**
**  'ExecAssPosObj'  executes the list  assignment statement <stat> of the form
**  '<list>[<position>] := <rhs>;'.
*/
UInt            ExecAssPosObj (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as a C integer        */
    Obj                 rhs;            /* right hand side, right operand  */

    /* evaluate the list (checking is done by 'ASS_LIST')                  */
    list = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_STAT(stat, 1));
    RequirePositiveSmallIntMayReplace("PosObj Assignment", pos, "position");
    p = INT_INTOBJ(pos);

    /* evaluate the right hand side                                        */
    rhs = EVAL_EXPR(READ_STAT(stat, 2));

    /* special case for plain list                                         */
    AssPosObj(list, p, rhs);

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbPosObj(<ass>)  . . . . . . . . . . . . . unbind an element of a list
**
**  'ExecUnbPosObj'  executes the list   unbind  statement <stat> of the   form
**  'Unbind( <list>[<position>] );'.
*/
UInt            ExecUnbPosObj (
    Expr                stat )
{
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, left operand          */
    Int                 p;              /* position, as a C integer        */

    /* evaluate the list (checking is done by 'LEN_LIST')                  */
    list = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_STAT(stat, 1));
    RequirePositiveSmallIntMayReplace("PosObj Assignment", pos, "position");
    p = INT_INTOBJ(pos);

    /* unbind the element                                                  */
    UnbPosObj(list, p);

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalElmPosObj(<expr>) . . . . . . . . . . . . . select an element of a list
**
**  'EvalElmPosObj' evaluates the list  element expression  <expr> of the  form
**  '<list>[<position>]'.
*/
Obj             EvalElmPosObj (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* evaluate the list (checking is done by 'ELM_LIST')                  */
    list = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_EXPR(expr, 1));
    RequirePositiveSmallIntMayReplace("PosObj Element", pos, "position");
    p = INT_INTOBJ( pos );

    /* special case for plain lists (use generic code to signal errors)    */
    elm = ElmPosObj(list, p);

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalIsbPosObj(<expr>) . . . . . . . . test if an element of a list is bound
**
**  'EvalElmPosObj'  evaluates the list  isbound expression  <expr> of the form
**  'IsBound( <list>[<position>] )'.
*/
Obj             EvalIsbPosObj (
    Expr                expr )
{
    Obj                 isb;            /* isbound, result                 */
    Obj                 list;           /* list, left operand              */
    Obj                 pos;            /* position, right operand         */
    Int                 p;              /* position, as C integer          */

    /* evaluate the list (checking is done by 'ISB_LIST')                  */
    list = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate and check the position                                     */
    pos = EVAL_EXPR(READ_EXPR(expr, 1));
    RequirePositiveSmallIntMayReplace("PosObj Element", pos, "position");
    p = INT_INTOBJ( pos );

    /* get the result                                                      */
    isb = IsbPosObj(list, p) ? True : False;

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  PrintAssPosObj(<stat>)  . . . . print an assignment to an element of a list
**
**  'PrintAssPosObj' prints the list  assignment statement  <stat> of the  form
**  '<list>[<position>] := <rhs>;'.
**
**  Linebreaks are preferred before the ':='.
*/
void            PrintAssPosObj (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<![",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<]",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;",0L,0L);
}

void            PrintUnbPosObj (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<![",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<]",0L,0L);
    Pr( " );", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmPosObj(<expr>)  . . . . . print a selection of an element of a list
**
**  'PrintElmPosObj'   prints the list element   expression  <expr> of the form
**  '<list>[<position>]'.
**
**  Linebreaks are preferred after the '['.
*/
void            PrintElmPosObj (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<![",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<]",0L,0L);
}

void            PrintIsbPosObj (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<![",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr("%<]",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  ExecAssComObjName(<stat>) . . . . . . . .  assign to an element of a record
**
**  'ExecAssComObjName' executes the  record assignment statement <stat> of the
**  form '<record>.<name> := <rhs>;'.
*/
UInt            ExecAssComObjName (
    Stat                stat )
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
    AssComObj( record, rnam, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecAssComObjExpr(<stat>) . . . . . . . .  assign to an element of a record
**
**  'ExecAssComObjExpr' executes the record assignment  statement <stat> of the
**  form '<record>.(<name>) := <rhs>;'.
*/
UInt            ExecAssComObjExpr (
    Stat                stat )
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
    AssComObj( record, rnam, rhs );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbComObjName(<stat>) . . . . . . . . . . unbind an element of a record
**
**  'ExecUnbComObjName' executes the record unbind statement <stat> of the form
**  'Unbind( <record>.<name> );'.
*/
UInt            ExecUnbComObjName (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    record = EVAL_EXPR(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);

    /* unbind the element of the record                                    */
    UnbComObj( record, rnam );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecUnbComObjExpr(<stat>) . . . . . . . . . . unbind an element of a record
**
**  'ExecUnbComObjExpr' executes the record unbind statement <stat> of the form
**  'Unbind( <record>.(<name>) );'.
*/
UInt            ExecUnbComObjExpr (
    Stat                stat )
{
    Obj                 record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* evaluate the record (checking is done by 'UNB_REC')                 */
    record = EVAL_EXPR(READ_STAT(stat, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_STAT(stat, 1)));

    /* unbind the element of the record                                    */
    UnbComObj( record, rnam );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  EvalElmComObjName(<expr>) . . . . . . . . . . . . . select a record element
**
**  'EvalElmComObjName' evaluates the  record element expression  <expr> of the
**  form '<record>.<name>'.
*/
Obj             EvalElmComObjName (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ELM_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);

    /* select the element of the record                                    */
    elm = ElmComObj( record, rnam );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalElmComObjExpr(<expr>) . . . . . . . . . . . . . select a record element
**
**  'EvalElmComObjExpr' evaluates the  record element expression  <expr> of the
**  form '<record>.(<name>)'.
*/
Obj             EvalElmComObjExpr (
    Expr                expr )
{
    Obj                 elm;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ELM_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_EXPR(expr, 1)));

    /* select the element of the record                                    */
    elm = ElmComObj( record, rnam );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  EvalIsbComObjName(<expr>) . . . . . . . . test if a record element is bound
**
**  'EvalIsbComObjName' evaluates  the record isbound  expression <expr> of the
**  form 'IsBound( <record>.<name> )'.
*/
Obj             EvalIsbComObjName (
    Expr                expr )
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);

    /* select the element of the record                                    */
    isb = IsbComObj( record, rnam ) ? True : False;

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  EvalIsbComObjExpr(<expr>) . . . . . . . . test if a record element is bound
**
**  'EvalIsbComObjExpr'  evaluates the record isbound  expression <expr> of the
**  form 'IsBound( <record>.(<name>) )'.
*/
Obj             EvalIsbComObjExpr (
    Expr                expr )
{
    Obj                 isb;            /* element, result                 */
    Obj                 record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* evaluate the record (checking is done by 'ISB_REC')                 */
    record = EVAL_EXPR(READ_EXPR(expr, 0));

    /* evaluate the name and convert it to a record name                   */
    rnam = RNamObj(EVAL_EXPR(READ_EXPR(expr, 1)));

    /* select the element of the record                                    */
    isb = IsbComObj( record, rnam ) ? True : False;

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  PrintAssComObjName(<stat>)  . print an assignment to an element of a record
**
**  'PrintAssComObjName' prints the  record assignment statement <stat>  of the
**  form '<record>.<name> := <rhs>;'.
*/
void            PrintAssComObjName (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<!.",0L,0L);
    Pr("%H", (Int)NAME_RNAM(READ_STAT(stat, 1)), 0L);
    Pr("%<",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;",0L,0L);
}

void            PrintUnbComObjName (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<!.",0L,0L);
    Pr("%H", (Int)NAME_RNAM(READ_STAT(stat, 1)), 0L);
    Pr("%<",0L,0L);
    Pr( " );", 0L, 0L );
}


/****************************************************************************
**
*F  PrintAssComObjExpr(<stat>)  . print an assignment to an element of a record
**
**  'PrintAssComObjExpr' prints the  record assignment statement <stat>  of the
**  form '<record>.(<name>) := <rhs>;'.
*/
void            PrintAssComObjExpr (
    Stat                stat )
{
    Pr("%4>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<!.(",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr(")%<",0L,0L);
    Pr("%< %>:= ",0L,0L);
    PrintExpr(READ_EXPR(stat, 2));
    Pr("%2<;",0L,0L);
}

void            PrintUnbComObjExpr (
    Stat                stat )
{
    Pr( "Unbind( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<!.(",0L,0L);
    PrintExpr(READ_EXPR(stat, 1));
    Pr(")%<",0L,0L);
    Pr( " );", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmComObjName(<expr>)  . . print a selection of an element of a record
**
**  'PrintElmComObjName' prints the  record  element expression <expr> of   the
**  form '<record>.<name>'.
*/
void            PrintElmComObjName (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<!.",0L,0L);
    Pr("%H", (Int)NAME_RNAM(READ_EXPR(expr, 1)), 0L);
    Pr("%<",0L,0L);
}

void            PrintIsbComObjName (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<!.",0L,0L);
    Pr("%H", (Int)NAME_RNAM(READ_EXPR(expr, 1)), 0L);
    Pr("%<",0L,0L);
    Pr( " )", 0L, 0L );
}


/****************************************************************************
**
*F  PrintElmComObjExpr(<expr>)  . . print a selection of an element of a record
**
**  'PrintElmComObjExpr' prints the record   element expression <expr>  of  the
**  form '<record>.(<name>)'.
*/
void            PrintElmComObjExpr (
    Expr                expr )
{
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<!.(",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr(")%<",0L,0L);
}

void            PrintIsbComObjExpr (
    Expr                expr )
{
    Pr( "IsBound( ", 0L, 0L );
    Pr("%2>",0L,0L);
    PrintExpr(READ_EXPR(expr, 0));
    Pr("%<!.(",0L,0L);
    PrintExpr(READ_EXPR(expr, 1));
    Pr(")%<",0L,0L);
    Pr( " )", 0L, 0L );
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


Obj FuncGetCurrentLVars( Obj self )
{
  return STATE(CurrLVars);
}

Obj FuncGetBottomLVars( Obj self )
{
  return STATE(BottomLVars);
}

Obj FuncParentLVars( Obj self, Obj lvars )
{
  if (!IS_LVARS_OR_HVARS(lvars)) {
    ErrorQuit( "<lvars> must be an lvars (not a %s)",
               (Int)TNAM_OBJ(lvars), 0L );
    return 0;
  }
  Obj parent = PARENT_LVARS(lvars);
  return parent ? parent : Fail;
}

Obj FuncContentsLVars (Obj self, Obj lvars )
{
  Obj contents = NEW_PREC(0);
  Obj func = FUNC_LVARS(lvars);
  Obj nams = NAMS_FUNC(func);
  UInt len = (SIZE_BAG(lvars) - 2*sizeof(Obj) - sizeof(UInt))/sizeof(Obj);
  Obj values = NEW_PLIST_IMM(T_PLIST, len);
  if (lvars == STATE(BottomLVars))
    return False;
  AssPRec(contents, RNamName("func"), func);
  AssPRec(contents, RNamName("names"), nams);
  memcpy(1+ADDR_OBJ(values), 3+CONST_ADDR_OBJ(lvars), len*sizeof(Obj));
  while (len > 0 && ELM_PLIST(values, len) == 0)
      len--;
  SET_LEN_PLIST(values, len);
  AssPRec(contents, RNamName("values"), values);
  if (ENVI_FUNC(func) != STATE(BottomLVars))
    AssPRec(contents, RNamName("higher"), ENVI_FUNC(func));
  return contents;
}

/****************************************************************************
**
*F  VarsBeforeCollectBags() . . . . . . . . actions before garbage collection
*F  VarsAfterCollectBags()  . . . . . . . .  actions after garbage collection
*/
#ifdef USE_GASMAN

void VarsBeforeCollectBags ( void )
{
  if (STATE(CurrLVars))
    CHANGED_BAG( STATE(CurrLVars) );
}

void VarsAfterCollectBags ( void )
{
  if (STATE(CurrLVars))
    {
      STATE(PtrLVars) = PTR_BAG( STATE(CurrLVars) );
      STATE(PtrBody)  = (Stat*)PTR_BAG( BODY_FUNC( CURR_FUNC() ) );
    }
  GVarsAfterCollectBags();
}

#endif

/****************************************************************************
**
*F  SaveLVars ( <lvars> )
**
*/

void SaveLVars( Obj lvars )
{
  UInt len,i;
  const Obj *ptr;
  SaveSubObj(FUNC_LVARS(lvars));
  SaveUInt(STAT_LVARS(lvars));
  SaveSubObj(PARENT_LVARS(lvars));
  len = (SIZE_OBJ(lvars) - (2*sizeof(Obj)+sizeof(UInt)))/sizeof(Obj);
  ptr = CONST_ADDR_OBJ(lvars)+3;
  for (i = 0; i < len; i++)
    SaveSubObj(*ptr++);
}

/****************************************************************************
**
*F  LoadLVars ( <lvars> )
**
*/

void LoadLVars( Obj lvars )
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

Obj TYPE_LVARS;

Obj TypeLVars( Obj lvars )
{
  return TYPE_LVARS;
}

void PrintLVars( Obj lvars )
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
  GVAR_FUNC(GetCurrentLVars, 0, ""),
  GVAR_FUNC(GetBottomLVars, 0, ""),
  GVAR_FUNC(ParentLVars, 1, "lvars"),
  GVAR_FUNC(ContentsLVars, 1, "lvars"),
  { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
#if !defined(HPCGAP)
    /* make 'CurrLVars' known to Gasman                                    */
    InitGlobalBag( &STATE(CurrLVars),   "src/vars.c:CurrLVars"   );
    InitGlobalBag( &STATE(BottomLVars), "src/vars.c:BottomLVars" );

    enum { count = ARRAY_SIZE(STATE(LVarsPool)) };
    static char cookies[count][24];
    for (int i = 0; i < count; i++) {
      snprintf(cookies[i], sizeof(cookies[i]), "src/vars.c:LVarsPool%d", i);
      InitGlobalBag(&STATE(LVarsPool[i]), cookies[i]);
    }
#endif

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

    /* and the save restore functions */
    SaveObjFuncs[ T_LVARS ] = SaveLVars;
    LoadObjFuncs[ T_LVARS ] = LoadLVars;
    SaveObjFuncs[ T_HVARS ] = SaveLVars;
    LoadObjFuncs[ T_HVARS ] = LoadLVars;

    /* and a type */
    TypeObjFuncs[ T_LVARS ] = TypeLVars;
    TypeObjFuncs[ T_HVARS ] = TypeLVars;
    PrintObjFuncs[ T_LVARS ] = PrintLVars;
    PrintObjFuncs[ T_HVARS ] = PrintLVars;

    /* install executors, evaluators, and printers for local variables     */
    InstallExecStatFunc( T_ASS_LVAR       , ExecAssLVar);
    InstallExecStatFunc( T_UNB_LVAR       , ExecUnbLVar);
    // no EvalExprFunc for T_REFLVAR, it is handled immediately by EVAL_EXPR
    InstallEvalExprFunc( T_ISB_LVAR       , EvalIsbLVar);

    InstallPrintStatFunc( T_ASS_LVAR       , PrintAssLVar);
    InstallPrintStatFunc( T_UNB_LVAR       , PrintUnbLVar);
    InstallPrintExprFunc( T_REFLVAR        , PrintRefLVar);
    InstallPrintExprFunc( T_ISB_LVAR       , PrintIsbLVar);

    /* install executors, evaluators, and printers for higher variables    */
    InstallExecStatFunc( T_ASS_HVAR       , ExecAssHVar);
    InstallExecStatFunc( T_UNB_HVAR       , ExecUnbHVar);
    InstallEvalExprFunc( T_REF_HVAR       , EvalRefHVar);
    InstallEvalExprFunc( T_ISB_HVAR       , EvalIsbHVar);
    InstallPrintStatFunc( T_ASS_HVAR       , PrintAssHVar);
    InstallPrintStatFunc( T_UNB_HVAR       , PrintUnbHVar);
    InstallPrintExprFunc( T_REF_HVAR       , PrintRefHVar);
    InstallPrintExprFunc( T_ISB_HVAR       , PrintIsbHVar);

    /* install executors, evaluators, and printers for global variables    */
    InstallExecStatFunc( T_ASS_GVAR       , ExecAssGVar);
    InstallExecStatFunc( T_UNB_GVAR       , ExecUnbGVar);
    InstallEvalExprFunc( T_REF_GVAR       , EvalRefGVar);
    InstallEvalExprFunc( T_ISB_GVAR       , EvalIsbGVar);
    InstallPrintStatFunc( T_ASS_GVAR       , PrintAssGVar);
    InstallPrintStatFunc( T_UNB_GVAR       , PrintUnbGVar);
    InstallPrintExprFunc( T_REF_GVAR       , PrintRefGVar);
    InstallPrintExprFunc( T_ISB_GVAR       , PrintIsbGVar);

    /* install executors, evaluators, and printers for list elements       */
    InstallExecStatFunc( T_ASS_LIST       , ExecAssList);
    InstallExecStatFunc( T_ASSS_LIST      , ExecAsssList);
    InstallExecStatFunc( T_ASS_LIST_LEV   , ExecAssListLevel);
    InstallExecStatFunc( T_ASSS_LIST_LEV  , ExecAsssListLevel);
    InstallExecStatFunc( T_ASS2_LIST  , ExecAss2List);
    InstallPrintStatFunc( T_ASS2_LIST  , PrintAss2List);
    
    InstallExecStatFunc( T_UNB_LIST       , ExecUnbList);
    InstallEvalExprFunc( T_ELM_LIST       , EvalElmList);
    InstallEvalExprFunc( T_ELMS_LIST      , EvalElmsList);
    InstallEvalExprFunc( T_ELM_LIST_LEV   , EvalElmListLevel);
    InstallEvalExprFunc( T_ELMS_LIST_LEV  , EvalElmsListLevel);
    InstallEvalExprFunc( T_ISB_LIST       , EvalIsbList);
    InstallEvalExprFunc( T_ELM2_LIST      , EvalElm2List);
    InstallPrintExprFunc( T_ELM2_LIST     , PrintElm2List);
    
    InstallPrintStatFunc( T_ASS_LIST       , PrintAssList);
    InstallPrintStatFunc( T_ASSS_LIST      , PrintAsssList);
    InstallPrintStatFunc( T_ASS_LIST_LEV   , PrintAssList);
    InstallPrintStatFunc( T_ASSS_LIST_LEV  , PrintAsssList);
    InstallPrintStatFunc( T_UNB_LIST       , PrintUnbList);
    InstallPrintExprFunc( T_ELM_LIST       , PrintElmList);
    InstallPrintExprFunc( T_ELMS_LIST      , PrintElmsList);
    InstallPrintExprFunc( T_ELM_LIST_LEV   , PrintElmListLevel);
    InstallPrintExprFunc( T_ELMS_LIST_LEV  , PrintElmsList);
    InstallPrintExprFunc( T_ISB_LIST       , PrintIsbList);


    /* install executors, evaluators, and printers for record elements     */
    InstallExecStatFunc( T_ASS_REC_NAME   , ExecAssRecName);
    InstallExecStatFunc( T_ASS_REC_EXPR   , ExecAssRecExpr);
    InstallExecStatFunc( T_UNB_REC_NAME   , ExecUnbRecName);
    InstallExecStatFunc( T_UNB_REC_EXPR   , ExecUnbRecExpr);
    InstallEvalExprFunc( T_ELM_REC_NAME   , EvalElmRecName);
    InstallEvalExprFunc( T_ELM_REC_EXPR   , EvalElmRecExpr);
    InstallEvalExprFunc( T_ISB_REC_NAME   , EvalIsbRecName);
    InstallEvalExprFunc( T_ISB_REC_EXPR   , EvalIsbRecExpr);
    InstallPrintStatFunc( T_ASS_REC_NAME   , PrintAssRecName);
    InstallPrintStatFunc( T_ASS_REC_EXPR   , PrintAssRecExpr);
    InstallPrintStatFunc( T_UNB_REC_NAME   , PrintUnbRecName);
    InstallPrintStatFunc( T_UNB_REC_EXPR   , PrintUnbRecExpr);
    InstallPrintExprFunc( T_ELM_REC_NAME   , PrintElmRecName);
    InstallPrintExprFunc( T_ELM_REC_EXPR   , PrintElmRecExpr);
    InstallPrintExprFunc( T_ISB_REC_NAME   , PrintIsbRecName);
    InstallPrintExprFunc( T_ISB_REC_EXPR   , PrintIsbRecExpr);

    /* install executors, evaluators, and printers for list elements       */
    InstallExecStatFunc( T_ASS_POSOBJ       , ExecAssPosObj);
    InstallExecStatFunc( T_UNB_POSOBJ       , ExecUnbPosObj);
    InstallEvalExprFunc( T_ELM_POSOBJ       , EvalElmPosObj);
    InstallEvalExprFunc( T_ISB_POSOBJ       , EvalIsbPosObj);
    InstallPrintStatFunc( T_ASS_POSOBJ       , PrintAssPosObj);
    InstallPrintStatFunc( T_UNB_POSOBJ       , PrintUnbPosObj);
    InstallPrintExprFunc( T_ELM_POSOBJ       , PrintElmPosObj);
    InstallPrintExprFunc( T_ISB_POSOBJ       , PrintIsbPosObj);

    /* install executors, evaluators, and printers for record elements     */
    InstallExecStatFunc( T_ASS_COMOBJ_NAME  , ExecAssComObjName);
    InstallExecStatFunc( T_ASS_COMOBJ_EXPR  , ExecAssComObjExpr);
    InstallExecStatFunc( T_UNB_COMOBJ_NAME  , ExecUnbComObjName);
    InstallExecStatFunc( T_UNB_COMOBJ_EXPR  , ExecUnbComObjExpr);
    InstallEvalExprFunc( T_ELM_COMOBJ_NAME  , EvalElmComObjName);
    InstallEvalExprFunc( T_ELM_COMOBJ_EXPR  , EvalElmComObjExpr);
    InstallEvalExprFunc( T_ISB_COMOBJ_NAME  , EvalIsbComObjName);
    InstallEvalExprFunc( T_ISB_COMOBJ_EXPR  , EvalIsbComObjExpr);
    InstallPrintStatFunc( T_ASS_COMOBJ_NAME  , PrintAssComObjName);
    InstallPrintStatFunc( T_ASS_COMOBJ_EXPR  , PrintAssComObjExpr);
    InstallPrintStatFunc( T_UNB_COMOBJ_NAME  , PrintUnbComObjName);
    InstallPrintStatFunc( T_UNB_COMOBJ_EXPR  , PrintUnbComObjExpr);
    InstallPrintExprFunc( T_ELM_COMOBJ_NAME  , PrintElmComObjName);
    InstallPrintExprFunc( T_ELM_COMOBJ_EXPR  , PrintElmComObjExpr);
    InstallPrintExprFunc( T_ISB_COMOBJ_NAME  , PrintIsbComObjName);
    InstallPrintExprFunc( T_ISB_COMOBJ_EXPR  , PrintIsbComObjExpr);

#ifdef USE_GASMAN
    /* install before and after actions for garbage collections            */
    InitCollectFuncBags( VarsBeforeCollectBags, VarsAfterCollectBags );
#endif

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    InitCopyGVar("TYPE_LVARS",&TYPE_LVARS);

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    STATE(CurrLVars) = STATE(BottomLVars);
    SWITCH_TO_OLD_LVARS( STATE(BottomLVars) );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


static Int InitModuleState(void)
{
    Obj tmpFunc, tmpBody;

    STATE(BottomLVars) = NewBag(T_HVARS, 3 * sizeof(Obj));
    tmpFunc = NewFunctionC( "bottom", 0, "", 0 );

    LVarsHeader * hdr = (LVarsHeader *)ADDR_OBJ(STATE(BottomLVars));
    hdr->func = tmpFunc;
    hdr->parent = Fail;
    tmpBody = NewBag( T_BODY, sizeof(BodyHeader) );
    SET_BODY_FUNC( tmpFunc, tmpBody );

    STATE(CurrLVars) = STATE(BottomLVars);
    SWITCH_TO_OLD_LVARS( STATE(BottomLVars) );

    // return success
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
