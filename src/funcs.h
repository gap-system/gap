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
Obj MakeFunction(Obj fexp);


/****************************************************************************
**
**  Functions for tracking the recursion depth, and detecting if it exceeds
**  some threshold. This is used to abort recursion beyond a certain depth,
**  to protect against stack overflows and the resulting crashes.
*/

Int IncRecursionDepth(void);
void DecRecursionDepth(void);
Int  GetRecursionDepth(void);
void SetRecursionDepth(Int depth);

extern UInt RecursionTrapInterval;
void        RecursionDepthTrap(void);

EXPORT_INLINE void CheckRecursionBefore( void )
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
