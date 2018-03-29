/****************************************************************************
**
*W  funcs.h                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the function interpreter package.
**
**  The function interpreter package   contains the executors  for  procedure
**  calls, the  evaluators  for function calls,  the   evaluator for function
**  expressions, and the handlers for the execution of function bodies.
*/

#ifndef GAP_FUNCS_H
#define GAP_FUNCS_H

#include <src/system.h>

/****************************************************************************
**
*F  MakeFunction(<fexp>)  . . . . . . . . . . . . . . . . . . make a function
**
**  'MakeFunction' makes a function from the function expression bag <fexp>.
*/
extern Obj MakeFunction(Obj fexp);

/****************************************************************************
**
*F  ExecBegin( <frame> ) . . . . . . . . .begin an execution in context frame
**  if in doubt, pass STATE(BottomLVars) as <frame>
**
*F  ExecEnd(<error>)  . . . . . . . . . . . . . . . . . . .  end an execution
*/
extern void ExecBegin(Obj frame);
extern void ExecEnd(UInt error);


/****************************************************************************
**
**  Functions for tracking the recursion depth, and detecting if it exceeds
**  some threshold. This is used to abort recursion beyond a certain depth,
**  to protect against stack overflows and the resulting crashes.
*/

void IncRecursionDepth(void);
void DecRecursionDepth(void);
Int GetRecursionDepth(void);
void SetRecursionDepth(Int depth);

extern UInt RecursionTrapInterval;
extern void RecursionDepthTrap( void );

static inline void CheckRecursionBefore( void )
{
    IncRecursionDepth();
    if ( RecursionTrapInterval &&
         0 == (GetRecursionDepth() % RecursionTrapInterval) )
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
