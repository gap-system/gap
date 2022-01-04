/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the statements package.
**
**  The  statements package  is the  part  of  the interpreter that  executes
**  statements for their effects and prints statements.
*/

#ifndef GAP_STATS_H
#define GAP_STATS_H

#include "common.h"

/****************************************************************************
**
*V  ExecStatFuncs[<type>] . . . . . .  executor for statements of type <type>
**
**  'ExecStatFuncs' is   the dispatch table  that contains  for every type of
**  statements a pointer to the executor  for statements of  this type, i.e.,
**  the function  that should  be  called  if a  statement   of that type  is
**  executed.
*/
extern ExecStatFunc ExecStatFuncs[256];

/****************************************************************************
**
*F  EXEC_STAT(<stat>) . . . . . . . . . . . . . . . . . . execute a statement
**
**  'EXEC_STAT' executes the statement <stat>.
**
**  If   this  causes   the  execution  of   a  return-value-statement,  then
**  'EXEC_STAT' returns 'STATUS_RETURN', and the return value is stored
**  in 'STATE(ReturnObjStat)'. If a return-void-statement is executed, then
**  'EXEC_STAT' returns 'STATUS_RETURN' and sets 'STATE(ReturnObjStat)' to
**  zero. If a break-statement is executed (which cannot happen if <stat> is
**  the body of a function), then 'EXEC_STAT' returns 'STATUS_BREAK', and
**  similarly for a continue-statement 'STATUS_CONTINUE' is returned.
**  Otherwise 'EXEC_STAT' returns 'STATUS_END'.
**
**  'EXEC_STAT'  causes  the  execution  of  <stat>  by dispatching   to  the
**  executor, i.e., to the  function that executes statements  of the type of
**  <stat>.
*/
ExecStatus EXEC_STAT(Stat stat);

// Executes the current function and returns its return value
// if the last statement was STAT_RETURN_OBJ, or null if the last
// statement was STAT_RETURN_VOID
Obj EXEC_CURR_FUNC(void);

/****************************************************************************
**
*V  IntrExecStatFuncs[<type>] . . . .  pseudo executor to handle interrupts
**
**  'IntrExecStatFuncs' is a dispatch table that dispatches to an interrupt
**  function for every single entry; it is used in lieu of 'ExecStatFuncs'
**  when the normal control flow needs to be interrupted by an external
**  event.
*/
extern ExecStatFunc IntrExecStatFuncs[256];


/****************************************************************************
**
*F  HaveInterrupt . . . . . . . . . . . . . . . . . check for user interrupts
**
*/
#ifdef HPCGAP
UInt HaveInterrupt(void);
#else
#define HaveInterrupt() SyIsIntr()
#endif


/****************************************************************************
**
*/
UInt TakeInterrupt(void);


/****************************************************************************
**
*F  InterruptExecStat() . . . . . . . . interrupt the execution of statements
**
**  'InterruptExecStat'  interrupts the execution of   statements at the next
**  possible moment.  It is called from 'SyAnsIntr' if an interrupt signal is
**  received.  It is never called on systems that do not support signals.  On
**  those systems the executors test 'SyIsIntr' at regular intervals.
*/
void InterruptExecStat(void);


/****************************************************************************
**
*F  PrintStat(<stat>) . . . . . . . . . . . . . . . . . . . print a statement
**
**  'PrintStat' prints the statements <stat>.
**
**  'PrintStat' simply dispatches  through the table  'PrintStatFuncs' to the
**  appropriate printer.
*/
void PrintStat(Stat stat);


/****************************************************************************
**
*V  PrintStatFuncs[<type>]  . .  print function for statements of type <type>
**
**  'PrintStatFuncs' is the dispatching table that contains for every type of
**  statements a pointer to the  printer for statements  of this type,  i.e.,
**  the function that should be called to print statements of this type.
*/
extern PrintStatFunc PrintStatFuncs[256];


/****************************************************************************
 **
 *F  ClearError()  . . . . . . . . . . . . . .  reset execution and error flag
 *
 */
void ClearError(void);


/****************************************************************************
**
*/
extern Obj ITERATOR;
extern Obj IS_DONE_ITER;
extern Obj NEXT_ITER;


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
