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

#include "gapstate.h"

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
UInt EXEC_STAT(Stat stat);

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

extern UInt (* IntrExecStatFuncs[256]) ( Stat stat );


/****************************************************************************
**
*V  ReturnObjStat . . . . . . . . . . . . . . . .  result of return-statement
**
**  'ReturnObjStat'  is   the result of the   return-statement  that was last
**  executed.  It is set  in  'ExecReturnObj' and  used in the  handlers that
**  interpret functions.
*/
/* TL: extern  Obj             ReturnObjStat; */


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
extern  void            (* PrintStatFuncs[256] ) ( Stat stat );


/****************************************************************************
 **
 *F  ClearError()  . . . . . . . . . . . . . .  reset execution and error flag
 *
 * FIXME: This function accesses NrError which is state of the scanner, so
 *        scanner should have an API for this.
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
