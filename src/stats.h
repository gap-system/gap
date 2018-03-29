/****************************************************************************
**
*W  stats.h                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the statements package.
**
**  The  statements package  is the  part  of  the interpreter that  executes
**  statements for their effects and prints statements.
*/

#ifndef GAP_STATS_H
#define GAP_STATS_H

#include <src/code.h>
#include <src/gapstate.h>

/****************************************************************************
**
*V  ExecStatFuncs[<type>] . . . . . .  executor for statements of type <type>
**
**  'ExecStatFuncs' is   the dispatch table  that contains  for every type of
**  statements a pointer to the executor  for statements of  this type, i.e.,
**  the function  that should  be  called  if a  statement   of that type  is
**  executed.
*/
extern  UInt            (* ExecStatFuncs[256]) ( Stat stat );

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
**  Otherwise 'EXEC_STAT' returns 0.
**
**  'EXEC_STAT'  causes  the  execution  of  <stat>  by dispatching   to  the
**  executor, i.e., to the  function that executes statements  of the type of
**  <stat>.
*/
extern UInt EXEC_STAT(Stat stat);


/****************************************************************************
**
*V  IntrExecStatFuncs[<type>] . . . .  pseudo executor to handle interrupts
**
**  'IntrExecStatFuncs' is a dispatch table that dispatches to an interrupt
**  function for every single entry; it is used in lieu of 'ExecStatFuncs'
**  when the normal control flow needs to be interrupted by an external
**  event.
*/

extern  UInt 		(* IntrExecStatFuncs[256]) ( Stat stat );


/****************************************************************************
**
*V  CurrStat  . . . . . . . . . . . . . . . . .  currently executed statement
**
**  'CurrStat'  is the statement that  is currently being executed.  The sole
**  purpose of 'CurrStat' is to make it possible to  point to the location in
**  case an error is signalled.
*/
/* TL: extern  Stat            CurrStat; */


/****************************************************************************
**
*F  SET_BRK_CURR_STAT(<stat>) . . . . . . . set currently executing statement
*F  OLD_BRK_CURR_STAT . . . . . . . . .  define variable to remember CurrStat
*F  REM_BRK_CURR_STAT() . . . . . . .  remember currently executing statement
*F  RES_BRK_CURR_STAT() . . . . . . . . restore currently executing statement
*/
#ifndef NO_BRK_CURR_STAT
#define SET_BRK_CURR_STAT(stat) (STATE(CurrStat) = (stat))
#define OLD_BRK_CURR_STAT       Stat oldStat;
#define REM_BRK_CURR_STAT()     (oldStat = STATE(CurrStat))
#define RES_BRK_CURR_STAT()     (STATE(CurrStat) = oldStat)
#endif
#ifdef  NO_BRK_CURR_STAT
#define SET_BRK_CURR_STAT(stat) /* do nothing */
#define OLD_BRK_CURR_STAT       /* do nothing */
#define REM_BRK_CURR_STAT()     /* do nothing */
#define RES_BRK_CURR_STAT()     /* do nothing */
#endif


/****************************************************************************
**
*V  ReturnObjStat . . . . . . . . . . . . . . . .  result of return-statement
**
**  'ReturnObjStat'  is   the result of the   return-statement  that was last
**  executed.  It is set  in  'ExecReturnObj' and  used in the  handlers that
**  interpret functions.
*/
/* TL: extern  Obj             ReturnObjStat; */


extern UInt TakeInterrupt();

/****************************************************************************
**
*F  InterruptExecStat() . . . . . . . . interrupt the execution of statements
**
**  'InterruptExecStat'  interrupts the execution of   statements at the next
**  possible moment.  It is called from 'SyAnsIntr' if an interrupt signal is
**  received.  It is never called on systems that do not support signals.  On
**  those systems the executors test 'SyIsIntr' at regular intervals.
*/
extern  void            InterruptExecStat ( );


/****************************************************************************
**
*F  PrintStat(<stat>) . . . . . . . . . . . . . . . . . . . print a statement
**
**  'PrintStat' prints the statements <stat>.
**
**  'PrintStat' simply dispatches  through the table  'PrintStatFuncs' to the
**  appropriate printer.
*/
extern  void            PrintStat (
            Stat                stat );


/****************************************************************************
**
*V  PrintStatFuncs[<type>]  . .  print function for statements of type <type>
**
**  'PrintStatFuncs' is the dispatching table that contains for every type of
**  statements a pointer to the  printer for statements  of this type,  i.e.,
**  the function that should be called to print statements of this type.
*/
extern  void            (* PrintStatFuncs[256] ) ( Stat stat );


/****************************************************************************
 **
 *F  ClearError()  . . . . . . . . . . . . . .  reset execution and error flag
 *
 * FIXME: This function accesses NrError which is state of the scanner, so
 *        scanner should have an API for this.
 * 
 */

extern void ClearError ( void );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoStats() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoStats ( void );


#endif // GAP_STATS_H
