/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the statements package.
**
**  The  statements package  is the  part  of  the interpreter that  executes
**  statements for their effects and prints statements.
*/

#include "stats.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "code.h"
#include "error.h"
#include "exprs.h"
#include "gvars.h"
#include "hookintrprtr.h"
#include "info.h"
#include "intrprtr.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "precord.h"
#include "records.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "vars.h"

#include "config.h"

#ifdef USE_GASMAN
#include "sysmem.h"
#endif

#ifdef HPCGAP
#include "hpc/thread.h"
#endif

#include <assert.h>


inline ExecStatus EXEC_STAT(Stat stat)
{
    UInt tnum = TNUM_STAT(stat);
    SET_BRK_CALL_TO(stat);
    return (*STATE(CurrExecStatFuncs)[ tnum ]) ( stat );
}

extern inline Obj EXEC_CURR_FUNC(void)
{
    Obj result;
    EXEC_STAT(OFFSET_FIRST_STAT);
    result = STATE(ReturnObjStat);
    STATE(ReturnObjStat) = 0;
    return result;
}

// The next macro is used in loop bodies to handle 'break', 'continue' and
// 'return' statements. Note that here, during execution, `status` can only
// take on the value STATUS_BREAK, STATUS_CONTINUE, STATUS_RETURN, and
// STATUS_END; while STATUS_EOF, STATUS_ERROR, STATUS_QUIT, STATUS_QQUIT are
// impossible.
//
// The checks are arranged so that the most frequent cases (i.e. a statement
// which is not break/continue/return) is handled first.
#define EXEC_STAT_IN_LOOP(stat)                                              \
    {                                                                        \
        ExecStatus status = EXEC_STAT(stat);                                 \
        if (status != STATUS_END) {                                          \
            if (status == STATUS_CONTINUE)                                   \
                continue;                                                    \
            return (status == STATUS_RETURN) ? STATUS_RETURN : STATUS_END;   \
        }                                                                    \
    }

/****************************************************************************
**
*V  ExecStatFuncs[<type>] . . . . . .  executor for statements of type <type>
**
**  'ExecStatFuncs' is   the dispatch table  that contains  for every type of
**  statements a pointer to the executor  for statements of  this type, i.e.,
**  the function  that should  be  called  if a  statement   of that type  is
**  executed.
*/
ExecStatFunc ExecStatFuncs[256];


/****************************************************************************
**
*F  ExecUnknownStat(<stat>) . . . . . executor for statements of unknown type
**
**  'ExecUnknownStat' is the executor that is called if an attempt is made to
**  execute a statement <stat> of an unknown type.  It  signals an error.  If
**  this  is  ever  called, then   GAP is   in  serious  trouble, such as  an
**  overwritten type field of a statement.
*/
static ExecStatus ExecUnknownStat(Stat stat)
{
    Pr("Panic: tried to execute a statement of unknown type '%d'\n",
       (Int)TNUM_STAT(stat), 0);
    return STATUS_END;
}

/****************************************************************************
**
*F  HaveInterrupt . . . . . . . . . . . . . . . . . check for user interrupts
**
*/
#ifdef HPCGAP
UInt HaveInterrupt(void)
{
    return STATE(CurrExecStatFuncs) == IntrExecStatFuncs;
}
#endif

/****************************************************************************
**
*F  ExecSeqStat(<stat>) . . . . . . . . . . . .  execute a statement sequence
**
**  'ExecSeqStat' executes the statement sequence <stat>.
**
**  This is done  by  executing  the  statements one  after  another.  If   a
**  leave-statement  ('break' or  'return')  is executed  inside  one  of the
**  statements, then the execution of  the  statement sequence is  terminated
**  and the non-zero leave-value  is returned (to  tell the calling  executor
**  that a leave-statement was executed).  If no leave-statement is executed,
**  then 0 is returned.
**
**  A statement sequence with <n> statements is a statement of type
**  'STAT_SEQ_STAT' with <n> slots. The first points to the first statement,
**  the second points to the second statement, and so on.
*/
static ALWAYS_INLINE ExecStatus ExecSeqStatHelper(Stat stat, UInt nr)
{
    // loop over the statements
    for (UInt i = 1; i <= nr; i++) {
        // execute the <i>-th statement
        ExecStatus status = EXEC_STAT(READ_STAT(stat, i - 1));
        if (status != STATUS_END) {
            return status;
        }
    }

    return STATUS_END;
}

static ExecStatus ExecSeqStat(Stat stat)
{
    // get the number of statements
    UInt nr = SIZE_STAT( stat ) / sizeof(Stat);
    return ExecSeqStatHelper(stat, nr);
}

static ExecStatus ExecSeqStat2(Stat stat)
{
    return ExecSeqStatHelper(stat, 2);
}

static ExecStatus ExecSeqStat3(Stat stat)
{
    return ExecSeqStatHelper(stat, 3);
}

static ExecStatus ExecSeqStat4(Stat stat)
{
    return ExecSeqStatHelper(stat, 4);
}

static ExecStatus ExecSeqStat5(Stat stat)
{
    return ExecSeqStatHelper(stat, 5);
}

static ExecStatus ExecSeqStat6(Stat stat)
{
    return ExecSeqStatHelper(stat, 6);
}

static ExecStatus ExecSeqStat7(Stat stat)
{
    return ExecSeqStatHelper(stat, 7);
}


/****************************************************************************
**
*F  ExecIf(<stat>)  . . . . . . . . . . . . . . . . . execute an if-statement
**
**  'ExecIf' executes the if-statement <stat>.
**
**  This is done by evaluating the conditions  until one evaluates to 'true',
**  and then executing the corresponding body.  If a leave-statement ('break'
**  or  'return') is executed  inside the  body, then   the execution of  the
**  if-statement is  terminated and the  non-zero leave-value is returned (to
**  tell the  calling executor that a  leave-statement was executed).   If no
**  leave-statement is executed, then 0 is returned.
**
**  An if-statement with <n> branches is a statement of type 'STAT_IF' with
**  2*<n> slots. The first slot points to the first condition, the second
**  slot points to the first body, the third slot points to the second
**  condition, the fourth slot points to the second body, and so on. If the
**  if-statement has an else-branch, this is represented by a branch with
**  'EXPR_TRUE' as condition.
*/
static ExecStatus ExecIf(Stat stat)
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */

    /* if the condition evaluates to 'true', execute the if-branch body    */
    cond = READ_STAT(stat, 0);
    if ( EVAL_BOOL_EXPR( cond ) != False ) {

        /* execute the if-branch body and leave                            */
        body = READ_STAT(stat, 1);
        return EXEC_STAT( body );

    }

    return STATUS_END;
}

static ExecStatus ExecIfElse(Stat stat)
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */

    /* if the condition evaluates to 'true', execute the if-branch body    */
    cond = READ_STAT(stat, 0);
    if ( EVAL_BOOL_EXPR( cond ) != False ) {

        /* execute the if-branch body and leave                            */
        body = READ_STAT(stat, 1);
        return EXEC_STAT( body );

    }

    SET_BRK_CALL_TO(stat);

    /* otherwise execute the else-branch body and leave                    */
    body = READ_STAT(stat, 3);
    return EXEC_STAT( body );
}

static ExecStatus ExecIfElif(Stat stat)
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */
    UInt                nr;             /* number of branches              */
    UInt                i;              /* loop variable                   */

    /* get the number of branches                                          */
    nr = SIZE_STAT( stat ) / (2*sizeof(Stat));

    /* loop over all branches                                              */
    for ( i = 1; i <= nr; i++ ) {

        /* if the condition evaluates to 'true', execute the branch body   */
        cond = READ_STAT(stat, 2 * (i - 1));
        if ( EVAL_BOOL_EXPR( cond ) != False ) {

            /* execute the branch body and leave                           */
            body = READ_STAT(stat, 2 * (i - 1) + 1);
            return EXEC_STAT( body );

        }

        SET_BRK_CALL_TO(stat);
    }

    return STATUS_END;
}

static ExecStatus ExecIfElifElse(Stat stat)
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */
    UInt                nr;             /* number of branches              */
    UInt                i;              /* loop variable                   */

    /* get the number of branches                                          */
    nr = SIZE_STAT( stat ) / (2*sizeof(Stat)) - 1;

    /* loop over all branches                                              */
    for ( i = 1; i <= nr; i++ ) {

        /* if the condition evaluates to 'true', execute the branch body   */
        cond = READ_STAT(stat, 2 * (i - 1));
        if ( EVAL_BOOL_EXPR( cond ) != False ) {

            /* execute the branch body and leave                           */
            body = READ_STAT(stat, 2 * (i - 1) + 1);
            return EXEC_STAT( body );

        }

        SET_BRK_CALL_TO(stat);
    }

    /* otherwise execute the else-branch body and leave                    */
    body = READ_STAT(stat, 2 * (i - 1) + 1);
    return EXEC_STAT( body );
}


/****************************************************************************
**
*F  ExecFor(<stat>) . . . . . . . . . . . . . . . . . . .  execute a for-loop
**
**  'ExecFor' executes the for-loop <stat>.
**
**  This  is   done by   evaluating  the  list-expression, checking  that  it
**  evaluates  to  a list, and   then looping over the   entries in the list,
**  executing the  body for each element  of the list.   If a leave-statement
**  ('break' or 'return') is executed inside the  body, then the execution of
**  the for-loop is terminated and 0 is returned if the leave-statement was a
**  break-statement   or  the   non-zero leave-value   is   returned  if  the
**  leave-statement was a return-statement (to tell the calling executor that
**  a return-statement was  executed).  If  no leave-statement was  executed,
**  then 0 is returned.
**
**  A for-loop with <n> statements in its body is a statement of type
**  'STAT_FOR' with <n>+2 slots. The first slot points to an assignment bag
**  for the loop variable, the second slot points to the list-expression, and
**  the remaining slots points to the statements.
*/
Obj ITERATOR;
Obj IS_DONE_ITER;
Obj NEXT_ITER;
static Obj STD_ITER;

static ALWAYS_INLINE ExecStatus ExecForHelper(Stat stat, UInt nr)
{
    UInt                var;            /* variable                        */
    UInt                vart;           /* variable type                   */
    Obj                 list;           /* list to loop over               */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */
    UInt                i;              /* loop variable                   */
    Obj                 nfun, dfun;     /* functions for NextIterator and
                                           IsDoneIterator                  */  

    GAP_ASSERT(1 <= nr && nr <= 3);

    /* get the variable (initialize them first to please 'lint')           */
    const Stat varstat = READ_STAT(stat, 0);
    if (IS_REF_LVAR(varstat)) {
        var = LVAR_REF_LVAR(varstat);
        vart = 'l';
    }
    else if (TNUM_EXPR(varstat) == EXPR_REF_HVAR) {
        var = READ_EXPR(varstat, 0);
        vart = 'h';
    }
    else /* if ( TNUM_EXPR( varstat ) == EXPR_REF_GVAR ) */ {
        var = READ_EXPR(varstat, 0);
        vart = 'g';
    }

    /* evaluate the list                                                   */
    list = EVAL_EXPR(READ_STAT(stat, 1));

    /* get the body                                                        */
    body1 = READ_STAT(stat, 2);
    body2 = (nr >= 2) ? READ_STAT(stat, 3) : 0;
    body3 = (nr >= 3) ? READ_STAT(stat, 4) : 0;

    /* special case for lists                                              */
    if ( IS_SMALL_LIST( list ) ) {

        /* loop over the list, skipping unbound entries                    */
        i = 1;
        while ( i <= LEN_LIST(list) ) {

            /* get the element and assign it to the variable               */
            elm = ELMV0_LIST( list, i );
            i++;
            if ( elm == 0 )  continue;
            if      ( vart == 'l' )  ASS_LVAR( var, elm );
            else if ( vart == 'h' )  ASS_HVAR( var, elm );
            else if ( vart == 'g' )  AssGVar(  var, elm );

#if !defined(HAVE_SIGNAL)
            /* test for an interrupt                                       */
            if ( HaveInterrupt() ) {
                ErrorReturnVoid("user interrupt", 0, 0, "you can 'return;'");
            }
#endif

            /* execute the statements in the body                          */
            EXEC_STAT_IN_LOOP(body1);
            if (nr >= 2)
                EXEC_STAT_IN_LOOP(body2);
            if (nr >= 3)
                EXEC_STAT_IN_LOOP(body3);
        }

    }

    /* general case                                                        */
    else {

        /* get the iterator                                                */
        list = CALL_1ARGS( ITERATOR, list );

        if (IS_PREC_OR_COMOBJ(list) && CALL_1ARGS(STD_ITER, list) == True) {
            /* this can avoid method selection overhead on iterator        */
            dfun = ElmPRec( list, RNamName("IsDoneIterator") );
            nfun = ElmPRec( list, RNamName("NextIterator") );
        } else {
            dfun = IS_DONE_ITER;
            nfun = NEXT_ITER;
        }

        /* loop over the iterator                                          */
        while ( CALL_1ARGS( dfun, list ) == False ) {

            /* get the element and assign it to the variable               */
            elm = CALL_1ARGS( nfun, list );
            if      ( vart == 'l' )  ASS_LVAR( var, elm );
            else if ( vart == 'h' )  ASS_HVAR( var, elm );
            else if ( vart == 'g' )  AssGVar(  var, elm );

#if !defined(HAVE_SIGNAL)
            /* test for an interrupt                                       */
            if ( HaveInterrupt() ) {
                ErrorReturnVoid("user interrupt", 0, 0, "you can 'return;'");
            }
#endif

            /* execute the statements in the body                          */
            EXEC_STAT_IN_LOOP(body1);
            if (nr >= 2)
                EXEC_STAT_IN_LOOP(body2);
            if (nr >= 3)
                EXEC_STAT_IN_LOOP(body3);
        }

    }

    return STATUS_END;
}

static ExecStatus ExecFor(Stat stat)
{
    return ExecForHelper(stat, 1);
}


static ExecStatus ExecFor2(Stat stat)
{
    return ExecForHelper(stat, 2);
}

static ExecStatus ExecFor3(Stat stat)
{
    return ExecForHelper(stat, 3);
}


/****************************************************************************
**
*F  ExecForRange(<stat>)  . . . . . . . . . . . . . . . .  execute a for-loop
**
**  'ExecForRange' executes the  for-loop  <stat>, which is a  for-loop whose
**  loop variable is  a  local variable and  whose  list is a  literal  range
**  expression.
**
**  This  is   done by   evaluating  the  list-expression, checking  that  it
**  evaluates  to  a list, and   then looping over the   entries in the list,
**  executing the  body for each element  of the list.   If a leave-statement
**  ('break' or 'return') is executed inside the  body, then the execution of
**  the for-loop is terminated and 0 is returned if the leave-statement was a
**  break-statement   or  the   non-zero leave-value   is   returned  if  the
**  leave-statement was a return-statement (to tell the calling executor that
**  a return-statement was  executed).  If  no leave-statement was  executed,
**  then 0 is returned.
**
**  A short for-loop with <n> statements in its body is a statement of type
**  'STAT_FOR_RANGE' with <n>+2 slots. The first slot points to an assignment
**  bag for the loop variable, the second slot points to the list-expression,
**  and the remaining slots points to the statements.
*/
static ALWAYS_INLINE ExecStatus ExecForRangeHelper(Stat stat, UInt nr)
{
    UInt                lvar;           /* local variable                  */
    Int                 first;          /* first value of range            */
    Int                 last;           /* last value of range             */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */
    Int                 i;              /* loop variable                   */

    GAP_ASSERT(1 <= nr && nr <= 3);

    /* get the variable (initialize them first to please 'lint')           */
    lvar = LVAR_REF_LVAR(READ_STAT(stat, 0));

    /* evaluate the range                                                  */
    VisitStatIfHooked(READ_STAT(stat, 1));
    elm = EVAL_EXPR(READ_EXPR(READ_STAT(stat, 1), 0));
    first = GetSmallIntEx("Range", elm, "<first>");
    elm = EVAL_EXPR(READ_EXPR(READ_STAT(stat, 1), 1));
    last = GetSmallIntEx("Range", elm, "<last>");

    /* get the body                                                        */
    body1 = READ_STAT(stat, 2);
    body2 = (nr >= 2) ? READ_STAT(stat, 3) : 0;
    body3 = (nr >= 3) ? READ_STAT(stat, 4) : 0;

    /* loop over the range                                                 */
    for ( i = first; i <= last; i++ ) {

        /* get the element and assign it to the variable                   */
        elm = INTOBJ_INT( i );
        ASS_LVAR( lvar, elm );

#if !defined(HAVE_SIGNAL)
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid("user interrupt", 0, 0, "you can 'return;'");
        }
#endif

        /* execute the statements in the body                              */
        EXEC_STAT_IN_LOOP(body1);
        if (nr >= 2)
            EXEC_STAT_IN_LOOP(body2);
        if (nr >= 3)
            EXEC_STAT_IN_LOOP(body3);
    }

    return STATUS_END;
}

static ExecStatus ExecForRange(Stat stat)
{
    return ExecForRangeHelper(stat, 1);
}

static ExecStatus ExecForRange2(Stat stat)
{
    return ExecForRangeHelper(stat, 2);
}

static ExecStatus ExecForRange3(Stat stat)
{
    return ExecForRangeHelper(stat, 3);
}

/****************************************************************************
**
*F  ExecAtomic(<stat>)
*/

#ifdef HPCGAP
static ExecStatus ExecAtomic(Stat stat)
{
  Obj tolock[MAX_ATOMIC_OBJS];
  LockMode lockmode[MAX_ATOMIC_OBJS];
  LockStatus lockstatus[MAX_ATOMIC_OBJS];
  int lockSP;
  UInt nrexprs,i,j,status;
  Obj o;
  
  nrexprs = ((SIZE_STAT(stat)/sizeof(Stat))-1)/2;
  
  j = 0;
  for (i = 1; i <= nrexprs; i++) {
    o = EVAL_EXPR(READ_STAT(stat, 2*i));
    if (IS_BAG_REF(o)) {
      tolock[j] =  o;
      LockQual qual = INT_INTEXPR(READ_STAT(stat, 2*i-1));
      if (qual == LOCK_QUAL_READWRITE)
        lockmode[j] = LOCK_MODE_READWRITE;
      else if (qual == LOCK_QUAL_READONLY)
        lockmode[j] = LOCK_MODE_READONLY;
      else /* if (qual == LOCK_QUAL_NONE) */
        lockmode[j] = LOCK_MODE_DEFAULT;
      j++;
    }
  }
  
  nrexprs = j;

  GetLockStatus(nrexprs, tolock, lockstatus);

  j = 0;
  for (i = 0; i < nrexprs; i++) { 
    switch (lockstatus[i]) {
    case LOCK_STATUS_UNLOCKED:
      tolock[j] = tolock[i];
      lockmode[j] = lockmode[i];
      j++;
      break;
    case LOCK_STATUS_READONLY_LOCKED:
      if (lockmode[i] == LOCK_MODE_READWRITE)
        ErrorMayQuit("Attempt to change from read to write lock", 0, 0);
      break;
    case LOCK_STATUS_READWRITE_LOCKED:
      break;
    }
  }
  lockSP = LockObjects(j, tolock, lockmode);
  if (lockSP >= 0) {
    status = EXEC_STAT(READ_STAT(stat, 0));
    PopRegionLocks(lockSP);
  } else {
    status = 0;
    ErrorMayQuit("Cannot lock required regions", 0, 0);
  }
  return status;
}
#endif


/****************************************************************************
**
*F  ExecWhile(<stat>) . . . . . . . . . . . . . . . . .  execute a while-loop
**
**  'ExecWhile' executes the while-loop <stat>.
**
**  This is done  by  executing the  body while  the condition   evaluates to
**  'true'.  If a leave-statement   ('break' or 'return') is executed  inside
**  the  body, then the execution of  the while-loop  is  terminated and 0 is
**  returned if the  leave-statement was  a  break-statement or the  non-zero
**  leave-value is returned if the leave-statement was a return-statement (to
**  tell the calling executor  that a return-statement  was executed).  If no
**  leave-statement was executed, then 0 is returned.
**
**  A while-loop with <n> statements in its body is a statement of type
**  'STAT_WHILE' with <n>+1 slots. The first slot points to the condition,
**  the second slot points to the first statement, the third slot points to
**  the second statement, and so on.
*/
static ALWAYS_INLINE ExecStatus ExecWhileHelper(Stat stat, UInt nr)
{
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */

    GAP_ASSERT(1 <= nr && nr <= 3);

    /* get the condition and the body                                      */
    cond = READ_STAT(stat, 0);
    body1 = READ_STAT(stat, 1);
    body2 = (nr >= 2) ? READ_STAT(stat, 2) : 0;
    body3 = (nr >= 3) ? READ_STAT(stat, 3) : 0;

    /* while the condition evaluates to 'true', execute the body           */
    while ( EVAL_BOOL_EXPR( cond ) != False ) {

#if !defined(HAVE_SIGNAL)
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid("user interrupt", 0, 0, "you can 'return;'");
        }
#endif

        /* execute the body                                                */
        EXEC_STAT_IN_LOOP(body1);
        if (nr >= 2)
            EXEC_STAT_IN_LOOP(body2);
        if (nr >= 3)
            EXEC_STAT_IN_LOOP(body3);

        SET_BRK_CALL_TO(stat);
    }

    return STATUS_END;
}

static ExecStatus ExecWhile(Stat stat)
{
    return ExecWhileHelper(stat, 1);
}

static ExecStatus ExecWhile2(Stat stat)
{
    return ExecWhileHelper(stat, 2);
}

static ExecStatus ExecWhile3(Stat stat)
{
    return ExecWhileHelper(stat, 3);
}


/****************************************************************************
**
*F  ExecRepeat(<stat>)  . . . . . . . . . . . . . . . . execute a repeat-loop
**
**  'ExecRepeat' executes the repeat-loop <stat>.
**
**  This is  done by  executing  the body until   the condition evaluates  to
**  'true'.  If  a leave-statement ('break'  or 'return')  is executed inside
**  the  body, then the  execution of the repeat-loop  is terminated and 0 is
**  returned  if the leave-statement   was a break-statement  or the non-zero
**  leave-value is returned if the leave-statement was a return-statement (to
**  tell the  calling executor that a  return-statement was executed).  If no
**  leave-statement was executed, then 0 is returned.
**
**  A repeat-loop with <n> statements in its body is a statement of type
**  'STAT_REPEAT' with <n>+1 slots. The first slot points to the condition
**  second slot points to the first statement, the third slot points to the
**  second statement, and so on.
*/
static ALWAYS_INLINE ExecStatus ExecRepeatHelper(Stat stat, UInt nr)
{
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = READ_STAT(stat, 0);
    body1 = READ_STAT(stat, 1);
    body2 = (nr >= 2) ? READ_STAT(stat, 2) : 0;
    body3 = (nr >= 3) ? READ_STAT(stat, 3) : 0;

    /* execute the body until the condition evaluates to 'true'            */
    do {

#if !defined(HAVE_SIGNAL)
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid("user interrupt", 0, 0, "you can 'return;'");
        }
#endif

        /* execute the body                                                */
        EXEC_STAT_IN_LOOP(body1);
        if (nr >= 2)
            EXEC_STAT_IN_LOOP(body2);
        if (nr >= 3)
            EXEC_STAT_IN_LOOP(body3);

        SET_BRK_CALL_TO(stat);

    } while ( EVAL_BOOL_EXPR( cond ) == False );

    return STATUS_END;
}

static ExecStatus ExecRepeat(Stat stat)
{
    return ExecRepeatHelper(stat, 1);
}

static ExecStatus ExecRepeat2(Stat stat)
{
    return ExecRepeatHelper(stat, 2);
}

static ExecStatus ExecRepeat3(Stat stat)
{
    return ExecRepeatHelper(stat, 3);
}


/****************************************************************************
**
*F  ExecBreak(<stat>) . . . . . . . . . . . . . . . execute a break-statement
**
**  'ExecBreak' executes the break-statement <stat>.
**
**  This is done by returning STATUS_BREAK (to tell the calling executor that
**  a break-statement was executed).
**
**  A break-statement is a statement of type 'STAT_BREAK' with no slots.
*/
static ExecStatus ExecBreak(Stat stat)
{
    /* return to the next loop                                             */
    return STATUS_BREAK;
}

/****************************************************************************
**
*F  ExecContinue(<stat>) . . . . . . . . . . . . execute a continue-statement
**
**  'ExecContinue' executes the continue-statement <stat>.
**
**  This is done by returning STATUS_CONTINUE (to tell the calling executor
**  that a continue-statement was executed).
**
**  A continue-statement is a statement of type 'STAT_CONTINUE' with no
**  slots.
*/
static ExecStatus ExecContinue(Stat stat)
{
    /* return to the next loop                                             */
    return STATUS_CONTINUE;
}

/****************************************************************************
**
*F  ExecEmpty( <stat> ) . . . . . execute an empty statement
**
**  Does nothing
*/
static ExecStatus ExecEmpty(Stat stat)
{
    return STATUS_END;
}


/****************************************************************************
**
*F  ExecInfo( <stat> )  . . . . . . . . . . . . . . execute an info-statement
**
**  'ExecInfo' executes the info-statement <stat>.
**
**  This is  done by evaluating the first  two arguments, using the GAP level
**  function InfoDecision to decide whether the message has to be printed. If
**  it has, the other arguments are evaluated and passed to InfoDoPrint
**
**  An info-statement is a statement of type 'STAT_INFO' with slots for the
**  arguments.
*/
static ExecStatus ExecInfo(Stat stat)
{
    Obj             selectors;
    Obj             level;
    Obj             selected;
    UInt            narg;
    UInt            i;
    Obj             args;
    Obj             arg;

    selectors = EVAL_EXPR( ARGI_INFO( stat, 1 ) );
    level = EVAL_EXPR( ARGI_INFO( stat, 2) );

    selected = InfoCheckLevel(selectors, level);
    if (selected == True) {

        /* Get the number of arguments to be printed                       */
        narg = NARG_SIZE_INFO(SIZE_STAT(stat)) - 2;

        /* set up a list                                                   */
        args = NEW_PLIST( T_PLIST, narg );
        SET_LEN_PLIST( args, narg );

        /* evaluate the objects to be printed into the list                */
        for (i = 1; i <= narg; i++) {

            /* These two statements must not be combined into one because of
               the risk of a garbage collection during the evaluation
               of arg, which may happen after the pointer to args has been
               extracted
            */
            arg = EVAL_EXPR(ARGI_INFO(stat, i+2));
            SET_ELM_PLIST(args, i, arg);
            CHANGED_BAG(args);
        }

        /* and print them                                                  */
        InfoDoPrint(selectors, level, args);
    }
    return STATUS_END;
}

/****************************************************************************
**
*F  ExecAssert2Args(<stat>) . . . . . . . . . . . execute an assert-statement
**
**  'ExecAssert2Args' executes the 2 argument assert-statement <stat>.
**
**  A 2 argument assert-statement is a statement of type 'STAT_ASSERT_2ARGS'
**  with slots for the two arguments
*/
static ExecStatus ExecAssert2Args(Stat stat)
{
    Obj             level;
    Int             lev;
    Obj             cond;

    level = EVAL_EXPR(READ_STAT(stat, 0));
    lev = GetSmallIntEx("Assert", level, "<lev>");

    if (STATE(CurrentAssertionLevel) >= lev) {
        cond = EVAL_EXPR(READ_STAT(stat, 1));
        RequireTrueOrFalse("Assert", cond);
        if (cond == False) {
            AssertionFailure();
        }
    }

    return STATUS_END;
}

/****************************************************************************
**
*F  ExecAssert3Args(<stat>) . . . . . . . . . . . execute an assert-statement
**
**  'ExecAssert3Args' executes the 3 argument assert-statement <stat>.
**
**  A 3 argument assert-statement is a statement of type 'STAT_ASSERT_3ARGS'
**  with slots for the three arguments.
*/
static ExecStatus ExecAssert3Args(Stat stat)
{
    Obj             level;
    Int             lev;
    Obj             cond;
    Obj             message;

    level = EVAL_EXPR(READ_STAT(stat, 0));
    lev = GetSmallIntEx("Assert", level, "<lev>");

    if (STATE(CurrentAssertionLevel) >= lev) {
        cond = EVAL_EXPR(READ_STAT(stat, 1));
        RequireTrueOrFalse("Assert", cond);
        if (cond == False) {
            message = EVAL_EXPR(READ_STAT(stat, 2));
            if ( message != (Obj) 0 ) {
                SET_BRK_CALL_TO( stat );
                if (IS_STRING_REP( message ))
                    PrintString1( message );
                else
                    PrintObj(message);
            }
        }
    }
    return STATUS_END;
}


/****************************************************************************
**
*F  ExecReturnObj(<stat>) . . . . . . . . .  execute a return-value-statement
**
**  'ExecRetval' executes the return-value-statement <stat>.
**
**  This is done by setting 'STATE(ReturnObjStat)' to the value of the
**  return-value-statement, and returning 'STATUS_RETURN' (to tell the
**  calling executor that a return-statement was executed).
**
**  A return-value-statement is a statement of type 'STAT_RETURN_OBJ' with
**  one slot. This slot points to the expression whose value is to be
**  returned.
*/
static ExecStatus ExecReturnObj(Stat stat)
{
#if !defined(HAVE_SIGNAL)
    /* test for an interrupt                                               */
    if ( HaveInterrupt() ) {
        ErrorReturnVoid("user interrupt", 0, 0, "you can 'return;'");
    }
#endif

    STATE(ReturnObjStat) = EVAL_EXPR(READ_STAT(stat, 0));
    return STATUS_RETURN;
}


/****************************************************************************
**
*F  ExecReturnVoid(<stat>)  . . . . . . . . . execute a return-void-statement
**
**  'ExecReturnVoid'   executes  the return-void-statement <stat>,  i.e., the
**  return-statement that returns not value.
**
**  This is done by setting 'STATE(ReturnObjStat)' to zero, and returning
**  'STATUS_RETURN' (to tell the calling executor that a return-statement was
**  executed).
**
**  A return-void-statement is a statement of type 'STAT_RETURN_VOID' with no
**  slots.
*/
static ExecStatus ExecReturnVoid(Stat stat)
{
#if !defined(HAVE_SIGNAL)
    /* test for an interrupt                                               */
    if ( HaveInterrupt() ) {
        ErrorReturnVoid("user interrupt", 0, 0, "you can 'return;'");
    }
#endif

    STATE(ReturnObjStat) = 0;
    return STATUS_RETURN;
}

ExecStatFunc IntrExecStatFuncs[256];

static inline Int BreakLoopPending(void)
{
     return STATE(CurrExecStatFuncs) == IntrExecStatFuncs;
}



/****************************************************************************
**
*F  UnInterruptExecStat()  . . . . .revert the Statement execution jump table 
**                                   to normal 
*/

static void UnInterruptExecStat(void)
{
    assert(STATE(CurrExecStatFuncs) != ExecStatFuncs);
    STATE(CurrExecStatFuncs) = ExecStatFuncs;
}


/****************************************************************************
**
*F  UInt TakeInterrupt() . . . . . . . . allow user interrupts
**
**  When you call this you promise that the heap is in a normal state, 
**  allowing GAP execution in the usual way
**
**  This will do nothing (pretty quickly) if Ctrl-C has not been pressed and 
**  return 0. Otherwise it will respond appropriately. This may result in a
**  longjmp or in returning to the caller after arbitrary execution of GAP
**  code including possible garbage collection. In this case 1 is returned.
*/

UInt TakeInterrupt( void )
{
  if (HaveInterrupt()) {
      UnInterruptExecStat();
      ErrorReturnVoid("user interrupt", 0, 0, "you can 'return;'");
      return 1;
  }
  return 0;
}


/****************************************************************************
**
*F  ExecIntrStat(<stat>)  . . . . . . . . . . . . . . interrupt a computation
**
**  'ExecIntrStat' is called when a computation was interrupted (by a call to
**  'InterruptExecStat').  It  changes   the entries in    the dispatch table
**  'ExecStatFuncs' back   to   their original   value,   calls 'Error',  and
**  redispatches after a return from the break-loop.
*/

static ExecStatus ExecIntrStat(Stat stat)
{

    /* change the entries in 'ExecStatFuncs' back to the original          */
    if ( BreakLoopPending() ) {
        UnInterruptExecStat();
    }

#ifdef HPCGAP
    /* and now for something completely different                          */
    HandleInterrupts(1, stat);
#else
    // ensure global interrupt flag syLastIntr is cleared
    HaveInterrupt();

    /* and now for something completely different                          */
#ifdef USE_GASMAN
    if (SyStorOverrun != SY_STOR_OVERRUN_CLEAR) {
        Int printError = (SyStorOverrun == SY_STOR_OVERRUN_TO_REPORT);
        SyStorOverrun = SY_STOR_OVERRUN_CLEAR; /* reset */
        if (printError) {
            ErrorReturnVoid("reached the pre-set memory limit\n"
                            "(change it with the -o command line option)",
                            0, 0, "you can 'return;'");
        }
    }
    else
#endif
      ErrorReturnVoid( "user interrupt", 0, 0, "you can 'return;'" );
#endif

    /* continue at the interrupted statement                               */
    return EXEC_STAT( stat );
}


/****************************************************************************
**
*F  InterruptExecStat() . . . . . . . . interrupt the execution of statements
**
**  'InterruptExecStat'  interrupts the execution of   statements at the next
**  possible moment.  It is called from 'SyAnsIntr' if an interrupt signal is
**  received.  It is never called on systems that do not support signals.  On
**  those systems the executors test 'SyIsIntr' at regular intervals.
**
**  'InterruptExecStat' changes all entries   in the executor  dispatch table
**  'ExecStatFuncs'  to point to  'ExecIntrStat',  which changes  the entries
**  back, calls 'Error', and redispatches after a return from the break-loop.
*/
void InterruptExecStat ( void )
{
    /* remember the original entries from the table 'ExecStatFuncs'        */
    STATE(CurrExecStatFuncs) = IntrExecStatFuncs;
}


/****************************************************************************
**
*F  ClearError()  . . . . . . . . . . . . . .  reset execution and error flag
*/

void ClearError ( void )
{

    /* change the entries in 'ExecStatFuncs' back to the original          */
    if ( BreakLoopPending() ) {
        UnInterruptExecStat();

        /* check for user interrupt */
        if ( HaveInterrupt() ) {
          Pr("Noticed user interrupt, but you are back in main loop anyway.\n",
              0, 0);
        }
#ifdef USE_GASMAN
        /* and check if maximal memory was overrun */
        if (SyStorOverrun != SY_STOR_OVERRUN_CLEAR) {
            if (SyStorOverrun == SY_STOR_OVERRUN_TO_REPORT) {
                Pr("GAP has exceeded the permitted memory (-o option),\n", 0,
                   0);
                Pr("the maximum is now enlarged to %d kB.\n", (Int)SyStorMax,
                   0);
            }
            SyStorOverrun = SY_STOR_OVERRUN_CLEAR; /* reset */
        }
#endif
    }
}

/****************************************************************************
**
*F  PrintStat(<stat>) . . . . . . . . . . . . . . . . . . . print a statement
**
**  'PrintStat' prints the statements <stat>.
**
**  'PrintStat' simply dispatches  through the table  'PrintStatFuncs' to the
**  appropriate printer.
*/
void            PrintStat (
    Stat                stat )
{
    (*PrintStatFuncs[TNUM_STAT(stat)])( stat );
}


/****************************************************************************
**
*V  PrintStatFuncs[<type>]  . .  print function for statements of type <type>
**
**  'PrintStatFuncs' is the dispatching table that contains for every type of
**  statements a pointer to the  printer for statements  of this type,  i.e.,
**  the function that should be called to print statements of this type.
*/
PrintStatFunc PrintStatFuncs[256];


/****************************************************************************
**
*F  PrintUnknownStat(<stat>)  . . . . . . . . print statement of unknown type
**
**  'PrintUnknownStat' is the printer  that is called if  an attempt  is made
**  print a statement <stat>  of an unknown type.   It signals an error.   If
**  this  is  ever called,   then GAP  is in  serious   trouble, such  as  an
**  overwritten type field of a statement.
*/
static void PrintUnknownStat(Stat stat)
{
    ErrorQuit("Panic: cannot print statement of type '%d'",
              (Int)TNUM_STAT(stat), 0);
}


/****************************************************************************
**
*F  PrintSeqStat(<stat>)  . . . . . . . . . . . .  print a statement sequence
**
**  'PrintSeqStat' prints the statement sequence <stat>.
*/
static void PrintSeqStat(Stat stat)
{
    UInt                nr;             /* number of statements            */
    UInt                i;              /* loop variable                   */

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);

    /* loop over the statements                                            */
    for ( i = 1; i <= nr; i++ ) {

        /* print the <i>-th statement                                      */
        PrintStat(READ_STAT(stat, i - 1));

        /* print a line break after all but the last statement             */
        if ( i < nr )  Pr("\n", 0, 0);

    }

}


/****************************************************************************
**
*F  PrintIf(<stat>) . . . . . . . . . . . . . . . . . . print an if-statement
**
**  'PrIf' prints the if-statement <stat>.
**
**  Linebreaks are printed after the 'then' and the statements in the bodies.
**  If necessary one is preferred immediately before the 'then'.
*/
static void PrintIf(Stat stat)
{
    UInt                i;              /* loop variable                   */
    UInt                len;            /* length of loop                  */

    /* print the 'if' branch                                               */
    Pr("if%4> ", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%2< then%2>\n", 0, 0);
    PrintStat(READ_STAT(stat, 1));
    Pr("%4<\n", 0, 0);

    len = SIZE_STAT(stat) / (2 * sizeof(Stat));
    /* print the 'elif' branch                                             */
    for (i = 2; i <= len; i++) {
        if (i == len &&
            TNUM_EXPR(READ_STAT(stat, 2 * (i - 1))) == EXPR_TRUE) {
            Pr("else%4>\n", 0, 0);
        }
        else {
            Pr("elif%4> ", 0, 0);
            PrintExpr(READ_EXPR(stat, 2 * (i - 1)));
            Pr("%2< then%2>\n", 0, 0);
        }
        PrintStat(READ_STAT(stat, 2 * (i - 1) + 1));
        Pr("%4<\n", 0, 0);
    }

    /* print the 'fi'                                                      */
    Pr("fi;", 0, 0);
}


/****************************************************************************
**
*F  PrintFor(<stat>)  . . . . . . . . . . . . . . . . . . .  print a for-loop
**
**  'PrintFor' prints the for-loop <stat>.
**
**  Linebreaks are printed after the 'do' and the statements in the body.  If
**  necesarry it is preferred immediately before the 'in'.
*/
static void PrintFor(Stat stat)
{
    UInt                i;              /* loop variable                   */

    Pr("for%4> ", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%2< in%2> ", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%2< do%2>\n", 0, 0);
    for ( i = 2; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat(READ_STAT(stat, i));
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr("\n", 0, 0);
    }
    Pr("%4<\nod;", 0, 0);
}


/****************************************************************************
**
*F  PrintWhile(<stat>)  . . . . . . . . . . . . . . . . .  print a while loop
**
**  'PrintWhile' prints the while-loop <stat>.
**
**  Linebreaks are printed after the 'do' and the statments  in the body.  If
**  necessary one is preferred immediately before the 'do'.
*/
static void PrintWhile(Stat stat)
{
    UInt                i;              /* loop variable                   */

    Pr("while%4> ", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%2< do%2>\n", 0, 0);
    for ( i = 1; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat(READ_STAT(stat, i));
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr("\n", 0, 0);
    }
    Pr("%4<\nod;", 0, 0);
}

/****************************************************************************
**
*F  PrintAtomic(<stat>)  . . . . . . . . . . . . . . . . print an atomic loop
**
**  'PrintAtomic' prints the atomic-loop <stat>.
**
**  Linebreaks are printed after the 'do' and the statments  in the body.  If
**  necessary one is preferred immediately before the 'do'.
*/
#ifdef HPCGAP
static void PrintAtomic(Stat stat)
{
  UInt nrexprs;
    UInt                i;              /* loop variable                   */

    Pr("atomic%4> ", 0, 0);
    nrexprs = ((SIZE_STAT(stat)/sizeof(Stat))-1)/2;
    for (i = 1; i <=  nrexprs; i++) {
      if (i != 1)
        Pr(", ", 0, 0);
      switch (INT_INTEXPR(READ_STAT(stat, 2 * i - 1))) {
      case LOCK_QUAL_NONE:
        break;
      case LOCK_QUAL_READONLY:
        Pr("readonly ", 0, 0);
        break;
      case LOCK_QUAL_READWRITE:
        Pr("readwrite ", 0, 0);
        break;
      }
      PrintExpr(READ_EXPR(stat, 2 * i));
    }
    Pr("%2< do%2>\n", 0, 0);
    PrintStat(READ_STAT(stat, 0));
    Pr("%4<\nod;", 0, 0);
}
#endif


/****************************************************************************
**
*F  PrintRepeat(<stat>) . . . . . . . . . . . . . . . . . print a repeat-loop
**
**  'PrintRepeat' prints the repeat-loop <stat>.
**
**  Linebreaks are printed after the 'repeat' and the statements in the body.
**  If necessary one is preferred after the 'until'.
*/
static void PrintRepeat(Stat stat)
{
    UInt                i;              /* loop variable                   */

    Pr("repeat%4>\n", 0, 0);
    for ( i = 1; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat(READ_STAT(stat, i));
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr("\n", 0, 0);
    }
    Pr("%4<\nuntil%2> ", 0, 0);
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%2<;", 0, 0);
}


/****************************************************************************
**
*F  PrintBreak(<stat>)  . . . . . . . . . . . . . . . print a break-statement
**
**  'PrintBreak' prints the break-statement <stat>.
*/
static void PrintBreak(Stat stat)
{
    Pr("break;", 0, 0);
}


/****************************************************************************
**
*F  PrintContinue(<stat>) . . . . . . . . . . . .  print a continue-statement
**
**  'PrintContinue' prints the continue-statement <stat>.
*/
static void PrintContinue(Stat stat)
{
    Pr("continue;", 0, 0);
}


/****************************************************************************
**
*F  PrintEmpty(<stat>)
**
*/
static void PrintEmpty(Stat stat)
{
    Pr(";", 0, 0);
}


/****************************************************************************
**
*F  PrintInfo(<stat>) . . . . . . . . . . . . . . . . print an info-statement
**
**  'PrintInfo' prints the info-statement <stat>.
*/
static void PrintInfo(Stat stat)
{
    UInt                i;              /* loop variable                   */

    /* print the keyword                                                   */
    Pr("%2>Info", 0, 0);

    /* print the opening parenthesis                                       */
    Pr("%<( %>", 0, 0);

    /* print the expressions that evaluate to the actual arguments         */
    for ( i = 1; i <= NARG_SIZE_INFO( SIZE_STAT(stat) ); i++ ) {
        PrintExpr( ARGI_INFO(stat,i) );
        if ( i != NARG_SIZE_INFO( SIZE_STAT(stat) ) ) {
            Pr("%<, %>", 0, 0);
        }
    }

    /* print the closing parenthesis                                       */
    Pr(" %2<);", 0, 0);
}


/****************************************************************************
**
*F  PrintAssert2Args(<stat>)  . . . . . . . . . . . . print an info-statement
**
**  'PrintAssert2Args' prints the 2 argument assert-statement <stat>.
*/
static void PrintAssert2Args(Stat stat)
{
    /* print the keyword                                                   */
    Pr("%2>Assert", 0, 0);

    /* print the opening parenthesis                                       */
    Pr("%<( %>", 0, 0);

    /* Print the arguments, separated by a comma                           */
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<, %>", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));

    /* print the closing parenthesis                                       */
    Pr(" %2<);", 0, 0);
}


/****************************************************************************
**
*F  PrintAssert3Args(<stat>)  . . . . . . . . . . . . print an info-statement
**
**  'PrintAssert3Args' prints the 3 argument assert-statement <stat>.
*/
static void PrintAssert3Args(Stat stat)
{
    /* print the keyword                                                   */
    Pr("%2>Assert", 0, 0);

    /* print the opening parenthesis                                       */
    Pr("%<( %>", 0, 0);

    /* Print the arguments, separated by commas                            */
    PrintExpr(READ_EXPR(stat, 0));
    Pr("%<, %>", 0, 0);
    PrintExpr(READ_EXPR(stat, 1));
    Pr("%<, %>", 0, 0);
    PrintExpr(READ_EXPR(stat, 2));

    /* print the closing parenthesis                                       */
    Pr(" %2<);", 0, 0);
}


/****************************************************************************
**
*F  PrintReturnObj(<stat>)  . . . . . . . . .  print a return-value-statement
**
**  'PrintReturnObj' prints the return-value-statement <stat>.
*/
static void PrintReturnObj(Stat stat)
{
    Expr expr = READ_STAT(stat, 0);
    if (TNUM_EXPR(expr) == EXPR_REF_GVAR &&
        READ_STAT(expr, 0) == GVarName("TRY_NEXT_METHOD")) {
        Pr("TryNextMethod();", 0, 0);
    }
    else {
        Pr("%2>return%< %>", 0, 0);
        PrintExpr( expr );
        Pr("%2<;", 0, 0);
    }
}


/****************************************************************************
**
*F  PrintReturnVoid(<stat>) . . . . . . . . . . print a return-void-statement
**
**  'PrintReturnVoid' prints the return-void-statement <stat>.
*/
static void PrintReturnVoid(Stat stat)
{
    Pr("return;", 0, 0);
}


/****************************************************************************
**
*F  PrintPragma(<stat>) . . . . . . . . . . . . . .  print a pragma-statement
*/
static void PrintPragma(Stat stat)
{
    UInt ix = READ_STAT(stat, 0);
    Obj string = GET_VALUE_FROM_CURRENT_BODY(ix);

    Pr("#%g", (Int)string, 0);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                i;              /* loop variable                   */

    /* make the global bags known to Gasman                                */
    InitGlobalBag( &STATE(ReturnObjStat), "src/stats.c:ReturnObjStat" );

    /* connect to external functions                                       */
    ImportFuncFromLibrary( "Iterator",       &ITERATOR );
    ImportFuncFromLibrary( "IsDoneIterator", &IS_DONE_ITER );
    ImportFuncFromLibrary( "NextIterator",   &NEXT_ITER );
    ImportFuncFromLibrary( "IsStandardIterator",   &STD_ITER );

    /* install executors for non-statements                                */
    for ( i = 0; i < ARRAY_SIZE(ExecStatFuncs); i++ ) {
        InstallExecStatFunc(i, ExecUnknownStat);
    }

    /* install executors for compound statements                           */
    InstallExecStatFunc( STAT_SEQ_STAT       , ExecSeqStat);
    InstallExecStatFunc( STAT_SEQ_STAT2      , ExecSeqStat2);
    InstallExecStatFunc( STAT_SEQ_STAT3      , ExecSeqStat3);
    InstallExecStatFunc( STAT_SEQ_STAT4      , ExecSeqStat4);
    InstallExecStatFunc( STAT_SEQ_STAT5      , ExecSeqStat5);
    InstallExecStatFunc( STAT_SEQ_STAT6      , ExecSeqStat6);
    InstallExecStatFunc( STAT_SEQ_STAT7      , ExecSeqStat7);
    InstallExecStatFunc( STAT_IF             , ExecIf);
    InstallExecStatFunc( STAT_IF_ELSE        , ExecIfElse);
    InstallExecStatFunc( STAT_IF_ELIF        , ExecIfElif);
    InstallExecStatFunc( STAT_IF_ELIF_ELSE   , ExecIfElifElse);
    InstallExecStatFunc( STAT_FOR            , ExecFor);
    InstallExecStatFunc( STAT_FOR2           , ExecFor2);
    InstallExecStatFunc( STAT_FOR3           , ExecFor3);
    InstallExecStatFunc( STAT_FOR_RANGE      , ExecForRange);
    InstallExecStatFunc( STAT_FOR_RANGE2     , ExecForRange2);
    InstallExecStatFunc( STAT_FOR_RANGE3     , ExecForRange3);
    InstallExecStatFunc( STAT_WHILE          , ExecWhile);
    InstallExecStatFunc( STAT_WHILE2         , ExecWhile2);
    InstallExecStatFunc( STAT_WHILE3         , ExecWhile3);
    InstallExecStatFunc( STAT_REPEAT         , ExecRepeat);
    InstallExecStatFunc( STAT_REPEAT2        , ExecRepeat2);
    InstallExecStatFunc( STAT_REPEAT3        , ExecRepeat3);
    InstallExecStatFunc( STAT_BREAK          , ExecBreak);
    InstallExecStatFunc( STAT_CONTINUE       , ExecContinue);
    InstallExecStatFunc( STAT_INFO           , ExecInfo);
    InstallExecStatFunc( STAT_ASSERT_2ARGS   , ExecAssert2Args);
    InstallExecStatFunc( STAT_ASSERT_3ARGS   , ExecAssert3Args);
    InstallExecStatFunc( STAT_RETURN_OBJ     , ExecReturnObj);
    InstallExecStatFunc( STAT_RETURN_VOID    , ExecReturnVoid);
    InstallExecStatFunc( STAT_EMPTY          , ExecEmpty);
    InstallExecStatFunc( STAT_PRAGMA         , ExecEmpty);
#ifdef HPCGAP
    InstallExecStatFunc( STAT_ATOMIC         , ExecAtomic);
#endif

    /* install printers for non-statements                                */
    for ( i = 0; i < ARRAY_SIZE(PrintStatFuncs); i++ ) {
        InstallPrintStatFunc(i, PrintUnknownStat);
    }
    /* install printing functions for compound statements                  */
    InstallPrintStatFunc( STAT_SEQ_STAT       , PrintSeqStat);
    InstallPrintStatFunc( STAT_SEQ_STAT2      , PrintSeqStat);
    InstallPrintStatFunc( STAT_SEQ_STAT3      , PrintSeqStat);
    InstallPrintStatFunc( STAT_SEQ_STAT4      , PrintSeqStat);
    InstallPrintStatFunc( STAT_SEQ_STAT5      , PrintSeqStat);
    InstallPrintStatFunc( STAT_SEQ_STAT6      , PrintSeqStat);
    InstallPrintStatFunc( STAT_SEQ_STAT7      , PrintSeqStat);
    InstallPrintStatFunc( STAT_IF             , PrintIf);
    InstallPrintStatFunc( STAT_IF_ELSE        , PrintIf);
    InstallPrintStatFunc( STAT_IF_ELIF        , PrintIf);
    InstallPrintStatFunc( STAT_IF_ELIF_ELSE   , PrintIf);
    InstallPrintStatFunc( STAT_FOR            , PrintFor);
    InstallPrintStatFunc( STAT_FOR2           , PrintFor);
    InstallPrintStatFunc( STAT_FOR3           , PrintFor);
    InstallPrintStatFunc( STAT_FOR_RANGE      , PrintFor);
    InstallPrintStatFunc( STAT_FOR_RANGE2     , PrintFor);
    InstallPrintStatFunc( STAT_FOR_RANGE3     , PrintFor);
    InstallPrintStatFunc( STAT_WHILE          , PrintWhile);
    InstallPrintStatFunc( STAT_WHILE2         , PrintWhile);
    InstallPrintStatFunc( STAT_WHILE3         , PrintWhile);
    InstallPrintStatFunc( STAT_REPEAT         , PrintRepeat);
    InstallPrintStatFunc( STAT_REPEAT2        , PrintRepeat);
    InstallPrintStatFunc( STAT_REPEAT3        , PrintRepeat);
    InstallPrintStatFunc( STAT_BREAK          , PrintBreak);
    InstallPrintStatFunc( STAT_CONTINUE       , PrintContinue);
    InstallPrintStatFunc( STAT_INFO           , PrintInfo);
    InstallPrintStatFunc( STAT_ASSERT_2ARGS   , PrintAssert2Args);
    InstallPrintStatFunc( STAT_ASSERT_3ARGS   , PrintAssert3Args);
    InstallPrintStatFunc( STAT_RETURN_OBJ     , PrintReturnObj);
    InstallPrintStatFunc( STAT_RETURN_VOID    , PrintReturnVoid);
    InstallPrintStatFunc( STAT_EMPTY          , PrintEmpty);
    InstallPrintStatFunc( STAT_PRAGMA         , PrintPragma);
#ifdef HPCGAP
    InstallPrintStatFunc( STAT_ATOMIC         , PrintAtomic);
#endif

    for ( i = 0; i < ARRAY_SIZE(ExecStatFuncs); i++ )
        IntrExecStatFuncs[i] = ExecIntrStat;
    for (i = FIRST_NON_INTERRUPT_STAT; i <= LAST_NON_INTERRUPT_STAT; i++)
        IntrExecStatFuncs[i] = ExecStatFuncs[i];

    return 0;
}

static Int InitModuleState(void)
{
    STATE(CurrExecStatFuncs) = ExecStatFuncs;
#ifdef HPCGAP
    MEMBAR_FULL();
    if (GetThreadState(TLS(threadID)) >= TSTATE_INTERRUPT) {
        MEMBAR_FULL();
        STATE(CurrExecStatFuncs) = IntrExecStatFuncs;
    }
#endif

    return 0;
}

/****************************************************************************
**
*F  InitInfoStats() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "stats",
    .initKernel = InitKernel,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoStats ( void )
{
    return &module;
}
