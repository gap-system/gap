/****************************************************************************
**
*W  funcs.h                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions of the function interpreter package.
**
**  The function interpreter package   contains the executors  for  procedure
**  calls, the  evaluators  for function calls,  the   evaluator for function
**  expressions, and the handlers for the execution of function bodies.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_funcs_h =
   "@(#)$Id$";
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
*F  ExecBegin() . . . . . . . . . . . . . . . . . . . . .  begin an execution
*F  ExecEnd(<error>)  . . . . . . . . . . . . . . . . . . .  end an execution
*/
extern  void            ExecBegin ( void );

extern  void            ExecEnd (
            UInt                error );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupFuncs()  . . . . . . . . . . . . . . . . initialize function package
*/
extern void SetupFuncs ( void );


/****************************************************************************
**
*F  InitFuncs() . . . . . . . . . . . . . . . . . initialize function package
**
**  'InitFuncs' installs the  executing   functions that  are  needed by  the
**  executor  to execute procedure  calls,  the evaluating functions that are
**  needed by the  evaluator to evaluate function  calls, and  the evaluating
**  function that   is   needed  by  the  evaluator to    evaluate   function
**  expressions.   It  also  installs the printing    functions for procedure
**  calls, function calls, and function expressions.
*/
extern void InitFuncs ( void );


/****************************************************************************
**
*F  CheckFuncs()  . . . . .  check the initialisation of the function package
*/
extern void CheckFuncs ( void );


/****************************************************************************
**

*E  funcs.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



