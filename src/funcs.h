/****************************************************************************
**
*W  funcs.h                     GAP source                   Martin Schoenert
**
*H  @(#)$Id: funcs.h,v 4.9 2009/09/25 15:17:05 gap Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the function interpreter package.
**
**  The function interpreter package   contains the executors  for  procedure
**  calls, the  evaluators  for function calls,  the   evaluator for function
**  expressions, and the handlers for the execution of function bodies.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_funcs_h =
   "@(#)$Id: funcs.h,v 4.9 2009/09/25 15:17:05 gap Exp $";
#endif


/****************************************************************************
**

*F  MakeFunction(<fexp>)  . . . . . . . . . . . . . . . . . . make a function
**
**  'MakeFunction' makes a function from the function expression bag <fexp>.
*/
extern  Obj             MakeFunction (
            Obj                 fexp );


/****************************************************************************
**
*F  ExecBegin( <frame> ) . . . . . . . . .begin an execution in context frame
**  if in doubt, pass BottomLVars as <frame>
**
*F  ExecEnd(<error>)  . . . . . . . . . . . . . . . . . . .  end an execution
*/
extern  void            ExecBegin ( Obj frame );

extern  void            ExecEnd (
            UInt                error );


extern Int RecursionDepth;
/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoFuncs() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoFuncs ( void );


/****************************************************************************
**

*E  funcs.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



