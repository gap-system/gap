/****************************************************************************
**
*W  stats.c                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the statements package.
**
**  The  statements package  is the  part  of  the interpreter that  executes
**  statements for their effects and prints statements.
*/
#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>


#include <src/sysfiles.h>               /* file input/output */

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/bool.h>                   /* booleans */

#include <src/code.h>                   /* coder */
#include <src/exprs.h>                  /* expressions */

#include <src/intrprtr.h>               /* interpreter */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/stats.h>                  /* statements */

#include <src/profile.h>                /* installing methods */

#include <assert.h>

#include <src/hpc/tls.h>
#include <src/hpc/thread.h>

#include <src/vars.h>                   /* variables */

#include <src/hookintrprtr.h>           /* visit statements for profiling */

/****************************************************************************
**

*F  EXEC_STAT(<stat>) . . . . . . . . . . . . . . . . . . execute a statement
**
**  'EXEC_STAT' executes the statement <stat>.
**
**  If   this  causes   the  execution  of   a  return-value-statement,  then
**  'EXEC_STAT' returns 1, and the return value is stored in 'ReturnObjStat'.
**  If this causes the execution of a return-void-statement, then 'EXEC_STAT'
**  returns 2.  If  this causes execution  of a break-statement (which cannot
**  happen if <stat> is the body of a  function), then 'EXEC_STAT' returns 4.
**  Similarly, for a continue-statement, EXEC_STAT returns 8
**  Otherwise 'EXEC_STAT' returns 0.
**
**  'EXEC_STAT'  causes  the  execution  of  <stat>  by dispatching   to  the
**  executor, i.e., to the  function that executes statements  of the type of
**  <stat>.
**
**  'EXEC_STAT' is defined in the declaration part of this package as follows:
**
#define EXEC_STAT(stat) ( (*STATE(CurrExecStatFuncs)[ TNUM_STAT(stat) ]) ( stat ) )
*/


/****************************************************************************
**
*V  ExecStatFuncs[<type>] . . . . . .  executor for statements of type <type>
**
**  'ExecStatFuncs' is   the dispatch table  that contains  for every type of
**  statements a pointer to the executor  for statements of  this type, i.e.,
**  the function  that should  be  called  if a  statement   of that type  is
**  executed.
*/
UInt            (* ExecStatFuncs[256]) ( Stat stat );


/****************************************************************************
**
*V  CurrStat  . . . . . . . . . . . . . . . . .  currently executed statement
**
**  'CurrStat'  is the statement that  is currently being executed.  The sole
**  purpose of 'CurrStat' is to make it possible to  point to the location in
**  case an error is signalled.
*/
/* TL: Stat            CurrStat; */


/****************************************************************************
**
*V  ReturnObjStat . . . . . . . . . . . . . . . .  result of return-statement
**
**  'ReturnObjStat'  is   the result of the   return-statement  that was last
**  executed.  It is set  in  'ExecReturnObj' and  used in the  handlers that
**  interpret functions.
*/
/* TL: Obj             ReturnObjStat; */


/****************************************************************************
**

*F  ExecUnknownStat(<stat>) . . . . . executor for statements of unknown type
**
**  'ExecUnknownStat' is the executor that is called if an attempt is made to
**  execute a statement <stat> of an unknown type.  It  signals an error.  If
**  this  is  ever  called, then   GAP is   in  serious  trouble, such as  an
**  overwritten type field of a statement.
*/
UInt            ExecUnknownStat (
    Stat                stat )
{
    Pr(
        "Panic: tried to execute a statement of unknown type '%d'\n",
        (Int)TNUM_STAT(stat), 0L );
    return 0;
}

/****************************************************************************
**
*F  UInt HaveInterrupt() . . . . . . . . check for user interrupts
**
*/

#define HaveInterrupt()   SyIsIntr()


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
**  A statement sequence with <n> statements is represented by  a bag of type
**  'T_SEQ_STAT' with  <n> subbags.  The first  is  the  first statement, the
**  second is the second statement, and so on.
*/
UInt            ExecSeqStat (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                nr;             /* number of statements            */
    UInt                i;              /* loop variable                   */

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);

    /* loop over the statements                                            */
    for ( i = 1; i <= nr; i++ ) {

        /* execute the <i>-th statement                                    */
        if ( (leave = EXEC_STAT( ADDR_STAT(stat)[i-1] )) != 0 ) {
            return leave;
        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecSeqStat2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[1] );
}

UInt            ExecSeqStat3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[2] );
}

UInt            ExecSeqStat4 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[2] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[3] );
}

UInt            ExecSeqStat5 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[2] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[3] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[4] );
}

UInt            ExecSeqStat6 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[2] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[3] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[4] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[5] );
}

UInt            ExecSeqStat7 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */

    /* execute the statements                                              */
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[0] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[1] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[2] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[3] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[4] )) != 0 ) { return leave; }
    if ( (leave = EXEC_STAT( ADDR_STAT(stat)[5] )) != 0 ) { return leave; }

    /* execute the last statement                                          */
    return EXEC_STAT( ADDR_STAT(stat)[6] );
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
**  An if-statement with <n> branches is represented by  a bag of type 'T_IF'
**  with 2*<n> subbags.  The first subbag is  the first condition, the second
**  subbag is the  first body, the third subbag  is the second condition, the
**  fourth subbag is the second body, and so  on.  If the if-statement has an
**  else-branch, this is represented by a branch without a condition.
*/
UInt            ExecIf (
    Stat                stat )
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */

    /* if the condition evaluates to 'true', execute the if-branch body    */
    SET_BRK_CURR_STAT( stat );
    cond = ADDR_STAT(stat)[0];
    if ( EVAL_BOOL_EXPR( cond ) != False ) {

        /* execute the if-branch body and leave                            */
        body = ADDR_STAT(stat)[1];
        return EXEC_STAT( body );

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecIfElse (
    Stat                stat )
{
    Expr                cond;           /* condition                       */
    Stat                body;           /* body                            */

    /* if the condition evaluates to 'true', execute the if-branch body    */
    SET_BRK_CURR_STAT( stat );
    cond = ADDR_STAT(stat)[0];
    if ( EVAL_BOOL_EXPR( cond ) != False ) {

        /* execute the if-branch body and leave                            */
        body = ADDR_STAT(stat)[1];
        return EXEC_STAT( body );

    }

    /* otherwise execute the else-branch body and leave                    */
    body = ADDR_STAT(stat)[3];
    return EXEC_STAT( body );
}

UInt            ExecIfElif (
    Stat                stat )
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
        SET_BRK_CURR_STAT( stat );
        cond = ADDR_STAT(stat)[2*(i-1)];
        if ( EVAL_BOOL_EXPR( cond ) != False ) {

            /* execute the branch body and leave                           */
            body = ADDR_STAT(stat)[2*(i-1)+1];
            return EXEC_STAT( body );

        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecIfElifElse (
    Stat                stat )
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
        SET_BRK_CURR_STAT( stat );
        cond = ADDR_STAT(stat)[2*(i-1)];
        if ( EVAL_BOOL_EXPR( cond ) != False ) {

            /* execute the branch body and leave                           */
            body = ADDR_STAT(stat)[2*(i-1)+1];
            return EXEC_STAT( body );

        }

    }

    /* otherwise execute the else-branch body and leave                    */
    body = ADDR_STAT(stat)[2*(i-1)+1];
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
**  A for-loop with <n> statements  in its body   is represented by a bag  of
**  type 'T_FOR' with <n>+2  subbags.  The first  subbag is an assignment bag
**  for the loop variable, the second subbag  is the list-expression, and the
**  remaining subbags are the statements.
*/
Obj             ITERATOR;

Obj             IS_DONE_ITER;

Obj             NEXT_ITER;

Obj             STD_ITER;

UInt            ExecFor (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                var;            /* variable                        */
    UInt                vart;           /* variable type                   */
    Obj                 list;           /* list to loop over               */
    Obj                 elm;            /* one element of the list         */
    Stat                body;           /* body of loop                    */
    UInt                i;              /* loop variable                   */
    Obj                 nfun, dfun;     /* functions for NextIterator and
                                           IsDoneIterator                  */  

    /* get the variable (initialize them first to please 'lint')           */
    if ( IS_REFLVAR( ADDR_STAT(stat)[0] ) ) {
        var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );
        vart = 'l';
    }
    else if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_HVAR ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'h';
    }
    else /* if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_GVAR ) */ {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'g';
    }

    /* evaluate the list                                                   */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[1] );

    /* get the body                                                        */
    body = ADDR_STAT(stat)[2];

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

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( HaveInterrupt() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }

        }

    }

    /* general case                                                        */
    else {

        /* get the iterator                                                */
        list = CALL_1ARGS( ITERATOR, list );

        if ( CALL_1ARGS( STD_ITER, list ) == True && IS_PREC_REP(list) ) {
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

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( HaveInterrupt() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }

        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecFor2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                var;            /* variable                        */
    UInt                vart;           /* variable type                   */
    Obj                 list;           /* list to loop over               */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    UInt                i;              /* loop variable                   */
    Obj                 nfun, dfun;     /* functions for NextIterator and
                                           IsDoneIterator                  */  

    /* get the variable (initialize them first to please 'lint')           */
    if ( IS_REFLVAR( ADDR_STAT(stat)[0] ) ) {
        var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );
        vart = 'l';
    }
    else if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_HVAR ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'h';
    }
    else /* if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_GVAR ) */ {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'g';
    }

    /* evaluate the list                                                   */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[1] );

    /* get the body                                                        */
    body1 = ADDR_STAT(stat)[2];
    body2 = ADDR_STAT(stat)[3];

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

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( HaveInterrupt() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body1 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body2 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }

        }

    }

    /* general case                                                        */
    else {

        /* get the iterator                                                */
        list = CALL_1ARGS( ITERATOR, list );

        if ( CALL_1ARGS( STD_ITER, list ) == True && IS_PREC_REP(list) ) {
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

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( HaveInterrupt() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body1 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body2 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }

        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecFor3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
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

    /* get the variable (initialize them first to please 'lint')           */
    if ( IS_REFLVAR( ADDR_STAT(stat)[0] ) ) {
        var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );
        vart = 'l';
    }
    else if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_HVAR ) {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'h';
    }
    else /* if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_GVAR ) */ {
        var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
        vart = 'g';
    }

    /* evaluate the list                                                   */
    SET_BRK_CURR_STAT( stat );
    list = EVAL_EXPR( ADDR_STAT(stat)[1] );

    /* get the body                                                        */
    body1 = ADDR_STAT(stat)[2];
    body2 = ADDR_STAT(stat)[3];
    body3 = ADDR_STAT(stat)[4];

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

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( HaveInterrupt() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body1 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body2 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body3 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }


        }

    }

    /* general case                                                        */
    else {

        /* get the iterator                                                */
        list = CALL_1ARGS( ITERATOR, list );

        if ( CALL_1ARGS( STD_ITER, list ) == True && IS_PREC_REP(list) ) {
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

#if ! HAVE_SIGNAL
            /* test for an interrupt                                       */
            if ( HaveInterrupt() ) {
                ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
            }
#endif

            /* execute the statements in the body                          */
            if ( (leave = EXEC_STAT( body1 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body2 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }
            if ( (leave = EXEC_STAT( body3 )) != 0 ) {
                if (leave == 8) 
                    continue;
                return (leave & 3);
            }


        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
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
**  A short for-loop with <n> statements in its body is  represented by a bag
**  of   type 'T_FOR_RANGE'  with <n>+2 subbags.     The  first subbag is  an
**  assignment   bag  for  the  loop  variable,   the second    subbag is the
**  list-expression, and the remaining subbags are the statements.
*/
UInt            ExecForRange (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                lvar;           /* local variable                  */
    Int                 first;          /* first value of range            */
    Int                 last;           /* last value of range             */
    Obj                 elm;            /* one element of the list         */
    Stat                body;           /* body of the loop                */
    Int                 i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    lvar = LVAR_REFLVAR( ADDR_STAT(stat)[0] );

    /* evaluate the range                                                  */
    SET_BRK_CURR_STAT( stat );
    VisitStatIfHooked(ADDR_STAT(stat)[1]);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[0] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <first> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can replace <first> via 'return <first>;'" );
    }
    first = INT_INTOBJ(elm);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[1] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <last> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can replace <last> via 'return <last>;'" );
    }
    last  = INT_INTOBJ(elm);

    /* get the body                                                        */
    body = ADDR_STAT(stat)[2];

    /* loop over the range                                                 */
    for ( i = first; i <= last; i++ ) {

        /* get the element and assign it to the variable                   */
        elm = INTOBJ_INT( i );
        ASS_LVAR( lvar, elm );

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the statements in the body                              */
        if ( (leave = EXEC_STAT( body )) != 0 ) {
          if (leave == 8) 
            continue;
          return (leave & 3);
        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecForRange2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                lvar;           /* local variable                  */
    Int                 first;          /* first value of range            */
    Int                 last;           /* last value of range             */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Int                 i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    lvar = LVAR_REFLVAR( ADDR_STAT(stat)[0] );

    /* evaluate the range                                                  */
    SET_BRK_CURR_STAT( stat );
    VisitStatIfHooked(ADDR_STAT(stat)[1]);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[0] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <first> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can replace <first> via 'return <first>;'" );
    }
    first = INT_INTOBJ(elm);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[1] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <last> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can replace <last> via 'return <last>;'" );
    }
    last  = INT_INTOBJ(elm);

    /* get the body                                                        */
    body1 = ADDR_STAT(stat)[2];
    body2 = ADDR_STAT(stat)[3];

    /* loop over the range                                                 */
    for ( i = first; i <= last; i++ ) {

        /* get the element and assign it to the variable                   */
        elm = INTOBJ_INT( i );
        ASS_LVAR( lvar, elm );

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the statements in the body                              */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt            ExecForRange3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    UInt                lvar;           /* local variable                  */
    Int                 first;          /* first value of range            */
    Int                 last;           /* last value of range             */
    Obj                 elm;            /* one element of the list         */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */
    Int                 i;              /* loop variable                   */

    /* get the variable (initialize them first to please 'lint')           */
    lvar = LVAR_REFLVAR( ADDR_STAT(stat)[0] );

    /* evaluate the range                                                  */
    SET_BRK_CURR_STAT( stat );
    VisitStatIfHooked(ADDR_STAT(stat)[1]);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[0] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <first> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can replace <first> via 'return <first>;'" );
    }
    first = INT_INTOBJ(elm);
    elm = EVAL_EXPR( ADDR_EXPR( ADDR_STAT(stat)[1] )[1] );
    while ( ! IS_INTOBJ(elm) ) {
        elm = ErrorReturnObj(
            "Range: <last> must be an integer (not a %s)",
            (Int)TNAM_OBJ(elm), 0L,
            "you can replace <last> via 'return <last>;'" );
    }
    last  = INT_INTOBJ(elm);

    /* get the body                                                        */
    body1 = ADDR_STAT(stat)[2];
    body2 = ADDR_STAT(stat)[3];
    body3 = ADDR_STAT(stat)[4];

    /* loop over the range                                                 */
    for ( i = first; i <= last; i++ ) {

        /* get the element and assign it to the variable                   */
        elm = INTOBJ_INT( i );
        ASS_LVAR( lvar, elm );

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the statements in the body                              */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body3 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

/****************************************************************************
**
*F  ExecAtomic(<stat>)
*/

UInt ExecAtomic(
		Stat stat)
{
#ifdef HPCGAP
  Obj tolock[MAX_ATOMIC_OBJS];
  int locktypes[MAX_ATOMIC_OBJS];
  int lockstatus[MAX_ATOMIC_OBJS];
  int lockSP;
  UInt mode, nrexprs,i,j,status;
  Obj o;
  
  SET_BRK_CURR_STAT( stat );
  nrexprs = ((SIZE_STAT(stat)/sizeof(Stat))-1)/2;
  
  j = 0;
  for (i = 1; i <= nrexprs; i++) {
    o = EVAL_EXPR(ADDR_STAT(stat)[2*i]);
    if (!((Int)o & 0x3)) {
      tolock[j] =  o;
      mode = INT_INTEXPR(ADDR_STAT(stat)[2*i-1]);
      locktypes[j] = (mode == 2) ? 1 : (mode == 1) ? 0 : DEFAULT_LOCK_TYPE;
      j++;
    }
  }
  
  nrexprs = j;

  GetLockStatus(nrexprs, tolock, lockstatus);

  j = 0;
  for (i = 0; i < nrexprs; i++) { 
    switch (lockstatus[i]) {
    case 0:
      tolock[j] = tolock[i];
      locktypes[j] = locktypes[i];
      j++;
      break;
    case 2:
      if (locktypes[i] == 1)
        ErrorMayQuit("Attempt to change from read to write lock", 0L, 0L);
      break;
    case 1:
      break;
    default:
      assert(0);
    }
  }
  lockSP = LockObjects(j, tolock, locktypes);
  if (lockSP >= 0) {
    status = EXEC_STAT(ADDR_STAT(stat)[0]);
    PopRegionLocks(lockSP);
  } else {
    status = 0;
    ErrorMayQuit("Cannot lock required regions", 0L, 0L);      
  }
  return status;
#else
    // In non-HPC GAP, we completely ignore all the 'atomic' terms
    return EXEC_STAT(ADDR_STAT(stat)[0]);
#endif
}


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
**  A while-loop with <n> statements  in its body  is represented by a bag of
**  type  'T_WHILE' with <n>+1 subbags.   The first  subbag is the condition,
**  the second subbag is the first statement,  the third subbag is the second
**  statement, and so on.
*/
UInt ExecWhile (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body;           /* body of loop                    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body = ADDR_STAT(stat)[1];

    /* while the condition evaluates to 'true', execute the body           */
    SET_BRK_CURR_STAT( stat );
    while ( EVAL_BOOL_EXPR( cond ) != False ) {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt ExecWhile2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body1 = ADDR_STAT(stat)[1];
    body2 = ADDR_STAT(stat)[2];

    /* while the condition evaluates to 'true', execute the body           */
    SET_BRK_CURR_STAT( stat );
    while ( EVAL_BOOL_EXPR( cond ) != False ) {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt ExecWhile3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body1 = ADDR_STAT(stat)[1];
    body2 = ADDR_STAT(stat)[2];
    body3 = ADDR_STAT(stat)[3];

    /* while the condition evaluates to 'true', execute the body           */
    SET_BRK_CURR_STAT( stat );
    while ( EVAL_BOOL_EXPR( cond ) != False ) {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body3 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    }

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
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
**  A repeat-loop with <n> statements in its body is  represented by a bag of
**  type 'T_REPEAT'  with <n>+1 subbags.  The  first subbag is the condition,
**  the second subbag is the first statement, the  third subbag is the second
**  statement, and so on.
*/
UInt ExecRepeat (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body;           /* body of loop                    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body = ADDR_STAT(stat)[1];

    /* execute the body until the condition evaluates to 'true'            */
    SET_BRK_CURR_STAT( stat );
    do {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    } while ( EVAL_BOOL_EXPR( cond ) == False );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt ExecRepeat2 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body1 = ADDR_STAT(stat)[1];
    body2 = ADDR_STAT(stat)[2];

    /* execute the body until the condition evaluates to 'true'            */
    SET_BRK_CURR_STAT( stat );
    do {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    } while ( EVAL_BOOL_EXPR( cond ) == False );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}

UInt ExecRepeat3 (
    Stat                stat )
{
    UInt                leave;          /* a leave-statement was executed  */
    Expr                cond;           /* condition                       */
    Stat                body1;          /* first  stat. of body of loop    */
    Stat                body2;          /* second stat. of body of loop    */
    Stat                body3;          /* third  stat. of body of loop    */

    /* get the condition and the body                                      */
    cond = ADDR_STAT(stat)[0];
    body1 = ADDR_STAT(stat)[1];
    body2 = ADDR_STAT(stat)[2];
    body3 = ADDR_STAT(stat)[3];

    /* execute the body until the condition evaluates to 'true'            */
    SET_BRK_CURR_STAT( stat );
    do {

#if ! HAVE_SIGNAL
        /* test for an interrupt                                           */
        if ( HaveInterrupt() ) {
            ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
        }
#endif

        /* execute the body                                                */
        if ( (leave = EXEC_STAT( body1 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body2 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        if ( (leave = EXEC_STAT( body3 )) != 0 ) {
            if (leave == 8) 
                continue;
            return (leave & 3);
        }
        SET_BRK_CURR_STAT( stat );

    } while ( EVAL_BOOL_EXPR( cond ) == False );

    /* return 0 (to indicate that no leave-statement was executed)         */
    return 0;
}


/****************************************************************************
**
*F  ExecBreak(<stat>) . . . . . . . . . . . . . . . execute a break-statement
**
**  'ExecBreak' executes the break-statement <stat>.
**
**  This  is done   by  returning 4  (to tell  the   calling executor that  a
**  break-statement was executed).
**
**  A break-statement is  represented  by a bag of   type 'T_BREAK' with   no
**  subbags.
*/
UInt            ExecBreak (
    Stat                stat )
{
    /* return to the next loop                                             */
    return 4;
}

/****************************************************************************
**
*F  ExecContinue(<stat>) . . . . . . . . . . . . . . . execute a continue-statement
**
**  'ExecContinue' executes the continue-statement <stat>.
**
**  This  is done   by  returning 8 (to tell  the   calling executor that  a
**  continue-statement was executed).
**
**  A continue-statement is  represented  by a bag of   type 'T_CONTINUE' with   no
**  subbags.
*/
UInt            ExecContinue (
    Stat                stat )
{
    /* return to the next loop                                             */
    return 8;
}

/****************************************************************************
**
*F  ExecEmpty( <stat> ) . . . . . execute an empty statement
**
**  Does nothing
*/
UInt ExecEmpty( Stat stat )
{
  return 0;
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
**  An  info-statement is represented by a  bag of type 'T_INFO' with subbags
**  for the arguments
*/
UInt ExecInfo (
    Stat            stat )
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

    SET_BRK_CALL_TO( stat );
    SET_BRK_CURR_STAT( stat );

    selected = CALL_2ARGS(InfoDecision, selectors, level);
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
        CALL_1ARGS(InfoDoPrint, args);
    }
    return 0;
}

/****************************************************************************
**
*F  ExecAssert2Args(<stat>) . . . . . . . . . . . execute an assert-statement
**
**  'ExecAssert2Args' executes the 2 argument assert-statement <stat>.
**
**  A 2 argument assert-statement is  represented  by a bag of   type
**  'T_ASSERT_2ARGS' with subbags for the 2 arguments
*/
UInt ExecAssert2Args (
    Stat            stat )
{
    Obj             level;
    Obj             decision;

    SET_BRK_CURR_STAT( stat );
    SET_BRK_CALL_TO( stat );

    level = EVAL_EXPR( ADDR_STAT( stat )[0] );
    if ( ! LT(CurrentAssertionLevel, level) )  {
        decision = EVAL_EXPR( ADDR_STAT( stat )[1]);
        while ( decision != True && decision != False ) {
         decision = ErrorReturnObj(
          "Assertion condition must evaluate to 'true' or 'false', not a %s",
          (Int)TNAM_OBJ(decision), 0L,
          "you may 'return true;' or 'return false;'");
        }
        if ( decision == False ) {
            SET_BRK_CURR_STAT( stat );
            ErrorReturnVoid( "Assertion failure", 0L, 0L, "you may 'return;'");
        }

        /* decision must be 'True' here                                    */
        else {
            return 0;
        }
    }
  return 0;
}

/****************************************************************************
**
*F  ExecAssert3Args(<stat>) . . . . . . . . . . . execute an assert-statement
**
**  'ExecAssert3Args' executes the 3 argument assert-statement <stat>.
**
**  A 3 argument assert-statement is  represented  by a bag of   type
**  'T_ASSERT_3ARGS' with subbags for the 3 arguments
*/
UInt ExecAssert3Args (
    Stat            stat )
{
    Obj             level;
    Obj             decision;
    Obj             message;

    SET_BRK_CURR_STAT( stat );
    SET_BRK_CALL_TO( stat );
    
    level = EVAL_EXPR( ADDR_STAT( stat )[0] );
    if ( ! LT(CurrentAssertionLevel, level) ) {
        decision = EVAL_EXPR( ADDR_STAT( stat )[1]);
        while ( decision != True && decision != False ) {
            decision = ErrorReturnObj(
            "Assertion condition must evaluate to 'true' or 'false', not a %s",
            (Int)TNAM_OBJ(decision), 0L,
            "you may 'return true;' or 'return false;'");
        }
        if ( decision == False ) {
            message = EVAL_EXPR(ADDR_STAT( stat )[2]);
            if ( message != (Obj) 0 ) {
                if (IS_STRING_REP( message ))
                    PrintString1( message );
                else
                    PrintObj(message);
            }
        }
        return 0;
    }
    return 0;
}


/****************************************************************************
**
*F  ExecReturnObj(<stat>) . . . . . . . . .  execute a return-value-statement
**
**  'ExecRetval' executes the return-value-statement <stat>.
**
**  This    is  done  by  setting  'ReturnObjStat'    to   the  value of  the
**  return-value-statement, and returning   1 (to tell   the calling executor
**  that a return-value-statement was executed).
**
**  A return-value-statement  is represented by a  bag of type 'T_RETURN_OBJ'
**  with      one  subbag.    This  subbag     is   the    expression  of the
**  return-value-statement.
*/
UInt            ExecReturnObj (
    Stat                stat )
{
#if ! HAVE_SIGNAL
    /* test for an interrupt                                               */
    if ( HaveInterrupt() ) {
        ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
    }
#endif

    /* evaluate the expression                                             */
    SET_BRK_CURR_STAT( stat );
    STATE(ReturnObjStat) = EVAL_EXPR( ADDR_STAT(stat)[0] );

    /* return up to function interpreter                                   */
    return 1;
}


/****************************************************************************
**
*F  ExecReturnVoid(<stat>)  . . . . . . . . . execute a return-void-statement
**
**  'ExecReturnVoid'   executes  the return-void-statement <stat>,  i.e., the
**  return-statement that returns not value.
**
**  This  is done by   returning 2  (to tell    the calling executor  that  a
**  return-void-statement was executed).
**
**  A return-void-statement  is represented by  a bag of type 'T_RETURN_VOID'
**  with no subbags.
*/
UInt            ExecReturnVoid (
    Stat                stat )
{
#if ! HAVE_SIGNAL
    /* test for an interrupt                                               */
    if ( HaveInterrupt() ) {
        ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
    }
#endif

    /* set 'STATE(ReturnObjStat)' to void                                         */
    STATE(ReturnObjStat) = 0;

    /* return up to function interpreter                                   */
    return 2;
}

UInt (* RealExecStatFuncs[256]) ( Stat stat );

#ifdef HAVE_SIG_ATOMIC_T
sig_atomic_t volatile RealExecStatCopied;
#else
int volatile RealExecStatCopied;
#endif

/****************************************************************************
**
*F  void CheckAndRespondToAlarm()
**
*/

static void CheckAndRespondToAlarm(void) {
  if ( SyAlarmHasGoneOff ) {
    SyAlarmHasGoneOff = 0;
    assert(NumAlarmJumpBuffers);
    syLongjmp(&(AlarmJumpBuffers[--NumAlarmJumpBuffers]),1);
  }
}

/****************************************************************************
**
*F  UInt TakeInterrupt() . . . . . . . . allow user interrupts
**
**  When you call this you promise that the heap is in a normal state, 
**  allowing GAP execution in the usual way
**
**  This will do nothing (pretty quickly) if Ctrl-C has not been pressed and 
**  return 0. Otherwise it
**   will respond appropriately.  This may result in a longjmp
**  or in returning to the caller after arbitrary execution of GAP code
** including possible garbage collection. In this case 1 is returned.
*/

UInt TakeInterrupt( void ) {
  if (HaveInterrupt()) {
    UnInterruptExecStat();
    CheckAndRespondToAlarm();
    
    ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
    return 1;
  }
  return 0;
}


/****************************************************************************
**
*F  UnInterruptExecStat()  . . . . .revert the Statement execution jump table 
**                                   to normal 
*/

void UnInterruptExecStat() {
  UInt i;
  assert(RealExecStatCopied);
  for ( i=0; i<sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
    ExecStatFuncs[i] = RealExecStatFuncs[i];
  }
  RealExecStatCopied = 0;
  return;
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

UInt ExecIntrStat (
    Stat                stat )
{

    /* change the entries in 'ExecStatFuncs' back to the original          */
    if ( RealExecStatCopied ) {
      UnInterruptExecStat();
    }
    HaveInterrupt();


    /* One reason we might be here is a timeout. If so longjump out to the 
       CallWithTimeLimit where we started */
    CheckAndRespondToAlarm();

    /* and now for something completely different                          */
    SET_BRK_CURR_STAT( stat );
    if ( SyStorOverrun != 0 ) {
      SyStorOverrun = 0; /* reset */
      ErrorReturnVoid(
  "reached the pre-set memory limit\n(change it with the -o command line option)",
        0L, 0L, "you can 'return;'" );
    }
    else {
      ErrorReturnVoid( "user interrupt", 0L, 0L, "you can 'return;'" );
    }

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
    UInt                i;              /* loop variable                   */
    /*    assert(reason > 0) */

    /* remember the original entries from the table 'ExecStatFuncs'        */
    if ( ! RealExecStatCopied ) {
        for ( i=0; i<sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
            RealExecStatFuncs[i] = ExecStatFuncs[i];
        }
        RealExecStatCopied = 1;
    }

    /* change the entries in the table 'ExecStatFuncs' to 'ExecIntrStat'   */
    for ( i = 0;
          i < T_SEQ_STAT;
          i++ ) {
        ExecStatFuncs[i] = ExecIntrStat;
    }
    for ( i = T_RETURN_VOID;
          i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]);
          i++ ) {
        ExecStatFuncs[i] = ExecIntrStat;
    }
}

/****************************************************************************
**
*F  ClearError()  . . . . . . . . . . . . . .  reset execution and error flag
*/

Int BreakLoopPending( void ) {
     return RealExecStatCopied;
}

void ClearError ( void )
{

    /* change the entries in 'ExecStatFuncs' back to the original          */
    
    if ( RealExecStatCopied ) {
      UnInterruptExecStat();
        /* check for user interrupt */
        if ( HaveInterrupt() ) {
          Pr("Noticed user interrupt, but you are back in main loop anyway.\n",
              0L, 0L);
        }
        /* and check if maximal memory was overrun */
        if ( SyStorOverrun != 0 ) {
          SyStorOverrun = 0; /* reset */
          Pr("GAP has exceeded the permitted memory (-o option),\n", 0L, 0L);
          Pr("the maximum is now enlarged to %d kB.\n", (Int)SyStorMax, 0L);
        }
    }

    /* reset <STATE(NrError)>                                                */
    STATE(NrError) = 0;
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
void            (* PrintStatFuncs[256] ) ( Stat stat );


/****************************************************************************
**
*F  PrintUnknownStat(<stat>)  . . . . . . . . print statement of unknown type
**
**  'PrintUnknownStat' is the printer  that is called if  an attempt  is made
**  print a statement <stat>  of an unknown type.   It signals an error.   If
**  this  is  ever called,   then GAP  is in  serious   trouble, such  as  an
**  overwritten type field of a statement.
*/
void            PrintUnknownStat (
    Stat                stat )
{
    ErrorQuit(
        "Panic: cannot print statement of type '%d'",
        (Int)TNUM_STAT(stat), 0L );
}


/****************************************************************************
**
*F  PrintSeqStat(<stat>)  . . . . . . . . . . . .  print a statement sequence
**
**  'PrintSeqStat' prints the statement sequence <stat>.
*/
void            PrintSeqStat (
    Stat                stat )
{
    UInt                nr;             /* number of statements            */
    UInt                i;              /* loop variable                   */

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);

    /* loop over the statements                                            */
    for ( i = 1; i <= nr; i++ ) {

        /* print the <i>-th statement                                      */
        PrintStat( ADDR_STAT(stat)[i-1] );

        /* print a line break after all but the last statement             */
        if ( i < nr )  Pr( "\n", 0L, 0L );

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
void            PrintIf (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    /* print the 'if' branch                                               */
    Pr( "if%4> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<  then%2>\n", 0L, 0L );
    PrintStat( ADDR_STAT(stat)[1] );
    Pr( "%4<\n", 0L, 0L );

    /* print the 'elif' branch                                             */
    for ( i = 2; i <= SIZE_STAT(stat)/(2*sizeof(Stat)); i++ ) {
        if ( TNUM_EXPR( ADDR_STAT(stat)[2*(i-1)] ) == T_TRUE_EXPR ) {
            Pr( "else%4>\n", 0L, 0L );
        }
        else {
            Pr( "elif%4> ", 0L, 0L );
            PrintExpr( ADDR_STAT(stat)[2*(i-1)] );
            Pr( "%2<  then%2>\n", 0L, 0L );
        }
        PrintStat( ADDR_STAT(stat)[2*(i-1)+1] );
        Pr( "%4<\n", 0L, 0L );
    }

    /* print the 'fi'                                                      */
    Pr( "fi;", 0L, 0L );
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
void            PrintFor (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    Pr( "for%4> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<  in%2> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr( "%2<  do%2>\n", 0L, 0L );
    for ( i = 2; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat( ADDR_STAT(stat)[i] );
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr( "\n", 0L, 0L );
    }
    Pr( "%4<\nod;", 0L, 0L );
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
void            PrintWhile (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    Pr( "while%4> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<  do%2>\n", 0L, 0L );
    for ( i = 1; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat( ADDR_STAT(stat)[i] );
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr( "\n", 0L, 0L );
    }
    Pr( "%4<\nod;", 0L, 0L );
}

/****************************************************************************
**
*F  PrintAtomic(<stat>)  . . . . . . . . . . . . . . . . .  print a atomic loop
**
**  'PrintAtomic' prints the atomic-loop <stat>.
**
**  Linebreaks are printed after the 'do' and the statments  in the body.  If
**  necessary one is preferred immediately before the 'do'.
*/
void            PrintAtomic (
    Stat                stat )
{
  UInt nrexprs;
    UInt                i;              /* loop variable                   */

    Pr( "atomic%4> ", 0L, 0L );
    nrexprs = ((SIZE_STAT(stat)/sizeof(Stat))-1)/2;
    for (i = 1; i <=  nrexprs; i++) {
      if (i != 1)
	Pr(", ",0L,0L);
      switch (INT_INTEXPR(ADDR_STAT(stat)[2*i-1])) {
      case 0: break;
      case 1: Pr("readonly ",0L,0L);
	break;
      case 2: Pr("readwrite ",0L,0L);
	break;
      }
      PrintExpr(ADDR_STAT(stat)[2*i]);
    }
    Pr( "%2<  do%2>\n", 0L, 0L );
    PrintStat( ADDR_STAT(stat)[0]);
    Pr( "%4<\nod;", 0L, 0L );
}


/****************************************************************************
**
*F  PrintRepeat(<stat>) . . . . . . . . . . . . . . . . . print a repeat-loop
**
**  'PrintRepeat' prints the repeat-loop <stat>.
**
**  Linebreaks are printed after the 'repeat' and the statements in the body.
**  If necessary one is preferred after the 'until'.
*/
void            PrintRepeat (
    Stat                stat )
{
    UInt                i;              /* loop variable                   */

    Pr( "repeat%4>\n", 0L, 0L );
    for ( i = 1; i <= SIZE_STAT(stat)/sizeof(Stat)-1; i++ ) {
        PrintStat( ADDR_STAT(stat)[i] );
        if ( i < SIZE_STAT(stat)/sizeof(Stat)-1 )  Pr( "\n", 0L, 0L );
    }
    Pr( "%4<\nuntil%2> ", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<;", 0L, 0L );
}


/****************************************************************************
**
*F  PrintBreak(<stat>)  . . . . . . . . . . . . . . . print a break-statement
**
**  'PrintBreak' prints the break-statement <stat>.
*/
void            PrintBreak (
    Stat                stat )
{
    Pr( "break;", 0L, 0L );
}

/****************************************************************************
**
*F  PrintContinue(<stat>)  . . . . . . . . . . . . . . . print a continue-statement
**
**  'PrintContinue' prints the continue-statement <stat>.
*/
void            PrintContinue (
    Stat                stat )
{
    Pr( "continue;", 0L, 0L );
}

/****************************************************************************
**
*F  PrintEmpty(<stat>)
**
*/
void             PrintEmpty( Stat stat )
{
  Pr( ";", 0L, 0L);
}

/****************************************************************************
**
*F  PrintInfo(<stat>)  . . . . . . . . . . . . . . . print an info-statement
**
**  'PrintInfo' prints the info-statement <stat>.
*/

void            PrintInfo (
    Stat               stat )
{
    UInt                i;              /* loop variable                   */

    /* print the keyword                                                   */
    Pr("%2>Info",0L,0L);

    /* print the opening parenthesis                                       */
    Pr("%<( %>",0L,0L);

    /* print the expressions that evaluate to the actual arguments         */
    for ( i = 1; i <= NARG_SIZE_INFO( SIZE_STAT(stat) ); i++ ) {
        PrintExpr( ARGI_INFO(stat,i) );
        if ( i != NARG_SIZE_INFO( SIZE_STAT(stat) ) ) {
            Pr("%<, %>",0L,0L);
        }
    }

    /* print the closing parenthesis                                       */
    Pr(" %2<);",0L,0L);
}

/****************************************************************************
**
*F  PrintAssert2Args(<stat>)  . . . . . . . . . . . . print an info-statement
**
**  'PrintAssert2Args' prints the 2 argument assert-statement <stat>.
*/

void            PrintAssert2Args (
    Stat               stat )
{

    /* print the keyword                                                   */
    Pr("%2>Assert",0L,0L);

    /* print the opening parenthesis                                       */
    Pr("%<( %>",0L,0L);

    /* Print the arguments, separated by a comma                           */
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<, %>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );

    /* print the closing parenthesis                                       */
    Pr(" %2<);",0L,0L);
}
  
/****************************************************************************
**
*F  PrintAssert3Args(<stat>)  . . . . . . . . . . . . print an info-statement
**
**  'PrintAssert3Args' prints the 3 argument assert-statement <stat>.
*/

void            PrintAssert3Args (
    Stat               stat )
{

    /* print the keyword                                                   */
    Pr("%2>Assert",0L,0L);

    /* print the opening parenthesis                                       */
    Pr("%<( %>",0L,0L);

    /* Print the arguments, separated by commas                            */
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr("%<, %>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[1] );
    Pr("%<, %>",0L,0L);
    PrintExpr( ADDR_STAT(stat)[2] );

    /* print the closing parenthesis                                       */
    Pr(" %2<);",0L,0L);
}
  


/****************************************************************************
**
*F  PrintReturnObj(<stat>)  . . . . . . . . .  print a return-value-statement
**
**  'PrintReturnObj' prints the return-value-statement <stat>.
*/
void            PrintReturnObj (
    Stat                stat )
{
    Pr( "%2>return%< %>", 0L, 0L );
    PrintExpr( ADDR_STAT(stat)[0] );
    Pr( "%2<;", 0L, 0L );
}


/****************************************************************************
**
*F  PrintReturnVoid(<stat>) . . . . . . . . . . print a return-void-statement
**
**  'PrintReturnVoid' prints the return-void-statement <stat>.
*/
void            PrintReturnVoid (
    Stat                stat )
{
    Pr( "return;", 0L, 0L );
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/



/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{

    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                i;              /* loop variable                   */

    RealExecStatCopied = 0;
    
    /* make the global bags known to Gasman                                */
    /* 'InitGlobalBag( &CurrStat );' is not really needed, since we are in */
    /* for a lot of trouble if 'CurrStat' ever becomes the last reference. */
    /* furthermore, statements are no longer bags                          */
    /* InitGlobalBag( &CurrStat );                                         */
#if !defined HPCGAP
    InitGlobalBag( &STATE(ReturnObjStat), "src/stats.c:ReturnObjStat" );
#endif

    /* connect to external functions                                       */
    ImportFuncFromLibrary( "Iterator",       &ITERATOR );
    ImportFuncFromLibrary( "IsDoneIterator", &IS_DONE_ITER );
    ImportFuncFromLibrary( "NextIterator",   &NEXT_ITER );
    ImportFuncFromLibrary( "IsStandardIterator",   &STD_ITER );

    /* install executors for non-statements                                */
    for ( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++ ) {
        InstallExecStatFunc(i, ExecUnknownStat);
    }

    /* install executors for compound statements                           */
    InstallExecStatFunc( T_SEQ_STAT       , ExecSeqStat);
    InstallExecStatFunc( T_SEQ_STAT2      , ExecSeqStat2);
    InstallExecStatFunc( T_SEQ_STAT3      , ExecSeqStat3);
    InstallExecStatFunc( T_SEQ_STAT4      , ExecSeqStat4);
    InstallExecStatFunc( T_SEQ_STAT5      , ExecSeqStat5);
    InstallExecStatFunc( T_SEQ_STAT6      , ExecSeqStat6);
    InstallExecStatFunc( T_SEQ_STAT7      , ExecSeqStat7);
    InstallExecStatFunc( T_IF             , ExecIf);
    InstallExecStatFunc( T_IF_ELSE        , ExecIfElse);
    InstallExecStatFunc( T_IF_ELIF        , ExecIfElif);
    InstallExecStatFunc( T_IF_ELIF_ELSE   , ExecIfElifElse);
    InstallExecStatFunc( T_FOR            , ExecFor);
    InstallExecStatFunc( T_FOR2           , ExecFor2);
    InstallExecStatFunc( T_FOR3           , ExecFor3);
    InstallExecStatFunc( T_FOR_RANGE      , ExecForRange);
    InstallExecStatFunc( T_FOR_RANGE2     , ExecForRange2);
    InstallExecStatFunc( T_FOR_RANGE3     , ExecForRange3);
    InstallExecStatFunc( T_WHILE          , ExecWhile);
    InstallExecStatFunc( T_WHILE2         , ExecWhile2);
    InstallExecStatFunc( T_WHILE3         , ExecWhile3);
    InstallExecStatFunc( T_REPEAT         , ExecRepeat);
    InstallExecStatFunc( T_REPEAT2        , ExecRepeat2);
    InstallExecStatFunc( T_REPEAT3        , ExecRepeat3);
    InstallExecStatFunc( T_BREAK          , ExecBreak);
    InstallExecStatFunc( T_CONTINUE       , ExecContinue);
    InstallExecStatFunc( T_INFO           , ExecInfo);
    InstallExecStatFunc( T_ASSERT_2ARGS   , ExecAssert2Args);
    InstallExecStatFunc( T_ASSERT_3ARGS   , ExecAssert3Args);
    InstallExecStatFunc( T_RETURN_OBJ     , ExecReturnObj);
    InstallExecStatFunc( T_RETURN_VOID    , ExecReturnVoid);
    InstallExecStatFunc( T_EMPTY          , ExecEmpty);
    InstallExecStatFunc( T_ATOMIC         , ExecAtomic);

    /* install printers for non-statements                                */
    for ( i = 0; i < sizeof(PrintStatFuncs)/sizeof(PrintStatFuncs[0]); i++ ) {
        InstallPrintStatFunc(i, PrintUnknownStat);
    }
    /* install printing functions for compound statements                  */
    InstallPrintStatFunc( T_SEQ_STAT       , PrintSeqStat);
    InstallPrintStatFunc( T_SEQ_STAT2      , PrintSeqStat);
    InstallPrintStatFunc( T_SEQ_STAT3      , PrintSeqStat);
    InstallPrintStatFunc( T_SEQ_STAT4      , PrintSeqStat);
    InstallPrintStatFunc( T_SEQ_STAT5      , PrintSeqStat);
    InstallPrintStatFunc( T_SEQ_STAT6      , PrintSeqStat);
    InstallPrintStatFunc( T_SEQ_STAT7      , PrintSeqStat);
    InstallPrintStatFunc( T_IF             , PrintIf);
    InstallPrintStatFunc( T_IF_ELSE        , PrintIf);
    InstallPrintStatFunc( T_IF_ELIF        , PrintIf);
    InstallPrintStatFunc( T_IF_ELIF_ELSE   , PrintIf);
    InstallPrintStatFunc( T_FOR            , PrintFor);
    InstallPrintStatFunc( T_FOR2           , PrintFor);
    InstallPrintStatFunc( T_FOR3           , PrintFor);
    InstallPrintStatFunc( T_FOR_RANGE      , PrintFor);
    InstallPrintStatFunc( T_FOR_RANGE2     , PrintFor);
    InstallPrintStatFunc( T_FOR_RANGE3     , PrintFor);
    InstallPrintStatFunc( T_WHILE          , PrintWhile);
    InstallPrintStatFunc( T_WHILE2         , PrintWhile);
    InstallPrintStatFunc( T_WHILE3         , PrintWhile);
    InstallPrintStatFunc( T_REPEAT         , PrintRepeat);
    InstallPrintStatFunc( T_REPEAT2        , PrintRepeat);
    InstallPrintStatFunc( T_REPEAT3        , PrintRepeat);
    InstallPrintStatFunc( T_BREAK          , PrintBreak);
    InstallPrintStatFunc( T_CONTINUE       , PrintContinue);
    InstallPrintStatFunc( T_INFO           , PrintInfo);
    InstallPrintStatFunc( T_ASSERT_2ARGS   , PrintAssert2Args);
    InstallPrintStatFunc( T_ASSERT_3ARGS   , PrintAssert3Args);
    InstallPrintStatFunc( T_RETURN_OBJ     , PrintReturnObj);
    InstallPrintStatFunc( T_RETURN_VOID    , PrintReturnVoid);
    InstallPrintStatFunc( T_EMPTY          , PrintEmpty);
    InstallPrintStatFunc( T_ATOMIC         , PrintAtomic);

    /* return success                                                      */
    return 0;
}

void InitStatState(GAPState * state)
{
  state->CurrExecStatFuncs = ExecStatFuncs;
}

void DestroyStatState(GAPState * state)
{
}


/****************************************************************************
**
*F  InitInfoStats() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "stats",                            /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoStats ( void )
{
    return &module;
}


/****************************************************************************
**

*E  stats.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
