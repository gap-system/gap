/****************************************************************************
**
*W  funcs.h                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file declares the functions of the function interpreter package.
**
**  The function interpreter package   contains the executors  for  procedure
**  calls, the  evaluators  for function calls,  the   evaluator for function
**  expressions, and the handlers for the execution of function bodies.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_funcs_h =
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

*F  InitInfoFuncs() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoFuncs ( void );


/****************************************************************************
**

*E  funcs.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



