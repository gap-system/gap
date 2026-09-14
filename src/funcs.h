/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the function interpreter package.
**
**  The function interpreter package   contains the executors  for  procedure
**  calls, the  evaluators  for function calls,  the   evaluator for function
**  expressions, and the handlers for the execution of function bodies.
*/

#ifndef GAP_FUNCS_H
#define GAP_FUNCS_H

#include "common.h"

/****************************************************************************
**
*F  MakeFunction(<fexp>)  . . . . . . . . . . . . . . . . . . make a function
**
**  'MakeFunction' makes a function from the function expression bag <fexp>.
*/
Obj MakeFunction(Obj fexp) GAP_GC_CANSAFEPOINT;


/****************************************************************************
**
**  Functions for tracking the recursion depth, and detecting if it exceeds
**  some threshold. This is used to abort recursion beyond a certain depth,
**  to protect against stack overflows and the resulting crashes.
*/

Int  IncRecursionDepth(void) GAP_GC_NOTSAFEPOINT;
void DecRecursionDepth(void) GAP_GC_NOTSAFEPOINT;
Int  GetRecursionDepth(void) GAP_GC_NOTSAFEPOINT;
void SetRecursionDepth(Int depth) GAP_GC_NOTSAFEPOINT;

extern UInt RecursionTrapInterval;
void        RecursionDepthTrap(void) GAP_GC_CANSAFEPOINT;

EXPORT_INLINE void CheckRecursionBefore( void ) GAP_GC_CANSAFEPOINT
{
    Int depth = IncRecursionDepth();
    if ( RecursionTrapInterval &&
         0 == (depth % RecursionTrapInterval) )
      RecursionDepthTrap();
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoFuncs() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoFuncs ( void );

#endif // GAP_FUNCS_H
