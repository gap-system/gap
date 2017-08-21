/****************************************************************************
**
*W  calls.c                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions for the function call mechanism package.
**
**  For a  description of what the function  call mechanism is  about see the
**  declaration part of this package.
**
**  Each function is  represented by a function  bag (of type  'T_FUNCTION'),
**  which has the following format.
**
**      +-------+-------+- - - -+-------+
**      |handler|handler|       |handler|   (for all functions)
**      |   0   |   1   |       |   7   |
**      +-------+-------+- - - -+-------+
**
**      +-------+-------+-------+-------+
**      | name  | number| args &| prof- |   (for all functions)
**      | func. |  args | locals| iling |
**      +-------+-------+-------+-------+
**
**      +-------+-------+-------+-------+
**      | number| body  | envir-| funcs.|   (only for interpreted functions)
**      | locals| func. | onment| exprs.|
**      +-------+-------+-------+-------+
**
**  ...what the handlers are..
**  ...what the other components are...
*/
#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>



#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */

#include <src/opers.h>                  /* generic operations */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */

#include <src/bool.h>                   /* booleans */

#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/code.h>                   /* coder */

#include <src/stats.h>                  /* statements */

#include <src/saveload.h>               /* saving and loading */
#include <src/hpc/tls.h>                /* thread-local storage */

#include <src/vars.h>                   /* variables */

#include <assert.h>

/****************************************************************************
**
*F * * * * wrapper for functions with variable number of arguments  * * * * *
*/

/****************************************************************************
**
*F  DoWrap0args( <self> ) . . . . . . . . . . . wrap up 0 arguments in a list
**
**  'DoWrap<i>args' accepts the  <i>  arguments  <arg1>, <arg2>, and   so on,
**  wraps them up in a list, and  then calls  <self>  again via 'CALL_XARGS',
**  passing this list.    'DoWrap<i>args' are the  handlers  for callees that
**  accept a   variable   number of   arguments.    Note that   there   is no
**  'DoWrapXargs' handler,  since in  this  case the function  call mechanism
**  already requires that the passed arguments are collected in a list.
*/
Obj DoWrap0args (
    Obj                 self )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 args;           /* arguments list                  */

    /* make the arguments list                                             */
    args = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( args, 0 );

    /* call the variable number of arguments function                      */
    result = CALL_XARGS( self, args );
    return result;
}


/****************************************************************************
**
*F  DoWrap1args( <self>, <arg1> ) . . . . . . . wrap up 1 arguments in a list
*/
Obj DoWrap1args (
    Obj                 self,
    Obj                 arg1 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 args;           /* arguments list                  */

    /* make the arguments list                                             */
    args = NEW_PLIST( T_PLIST, 1 );
    SET_LEN_PLIST( args, 1 );
    SET_ELM_PLIST( args, 1, arg1 );

    /* call the variable number of arguments function                      */
    result = CALL_XARGS( self, args );
    return result;
}


/****************************************************************************
**
*F  DoWrap2args( <self>, <arg1>, ... )  . . . . wrap up 2 arguments in a list
*/
Obj DoWrap2args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 args;           /* arguments list                  */

    /* make the arguments list                                             */
    args = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( args, 2 );
    SET_ELM_PLIST( args, 1, arg1 );
    SET_ELM_PLIST( args, 2, arg2 );

    /* call the variable number of arguments function                      */
    result = CALL_XARGS( self, args );
    return result;
}


/****************************************************************************
**
*F  DoWrap3args( <self>, <arg1>, ... )  . . . . wrap up 3 arguments in a list
*/
Obj DoWrap3args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 args;           /* arguments list                  */

    /* make the arguments list                                             */
    args = NEW_PLIST( T_PLIST, 3 );
    SET_LEN_PLIST( args, 3 );
    SET_ELM_PLIST( args, 1, arg1 );
    SET_ELM_PLIST( args, 2, arg2 );
    SET_ELM_PLIST( args, 3, arg3 );

    /* call the variable number of arguments function                      */
    result = CALL_XARGS( self, args );
    return result;
}


/****************************************************************************
**
*F  DoWrap4args( <self>, <arg1>, ... )  . . . . wrap up 4 arguments in a list
*/
Obj DoWrap4args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 args;           /* arguments list                  */

    /* make the arguments list                                             */
    args = NEW_PLIST( T_PLIST, 4 );
    SET_LEN_PLIST( args, 4 );
    SET_ELM_PLIST( args, 1, arg1 );
    SET_ELM_PLIST( args, 2, arg2 );
    SET_ELM_PLIST( args, 3, arg3 );
    SET_ELM_PLIST( args, 4, arg4 );

    /* call the variable number of arguments function                      */
    result = CALL_XARGS( self, args );
    return result;
}


/****************************************************************************
**
*F  DoWrap5args( <self>, <arg1>, ... )  . . . . wrap up 5 arguments in a list
*/
Obj DoWrap5args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 args;           /* arguments list                  */

    /* make the arguments list                                             */
    args = NEW_PLIST( T_PLIST, 5 );
    SET_LEN_PLIST( args, 5 );
    SET_ELM_PLIST( args, 1, arg1 );
    SET_ELM_PLIST( args, 2, arg2 );
    SET_ELM_PLIST( args, 3, arg3 );
    SET_ELM_PLIST( args, 4, arg4 );
    SET_ELM_PLIST( args, 5, arg5 );

    /* call the variable number of arguments function                      */
    result = CALL_XARGS( self, args );
    return result;
}


/****************************************************************************
**
*F  DoWrap6args( <self>, <arg1>, ... )  . . . . wrap up 6 arguments in a list
*/
Obj DoWrap6args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 args;           /* arguments list                  */

    /* make the arguments list                                             */
    args = NEW_PLIST( T_PLIST, 6 );
    SET_LEN_PLIST( args, 6 );
    SET_ELM_PLIST( args, 1, arg1 );
    SET_ELM_PLIST( args, 2, arg2 );
    SET_ELM_PLIST( args, 3, arg3 );
    SET_ELM_PLIST( args, 4, arg4 );
    SET_ELM_PLIST( args, 5, arg5 );
    SET_ELM_PLIST( args, 6, arg6 );

    /* call the variable number of arguments function                      */
    result = CALL_XARGS( self, args );
    return result;
}


/****************************************************************************
**
*F * * wrapper for functions with do not support the number of arguments  * *
*/

/****************************************************************************
**
*F  DoFail0args( <self> )  . . . . . .  fail a function call with 0 arguments
**
**  'DoFail<i>args' accepts the <i> arguments <arg1>, <arg2>,  and so on, and
**  signals an error,  because  the  function for  which  they  are installed
**  expects another number of arguments.  'DoFail<i>args' are the handlers in
**  the other slots of a function.
*/

/* Pull this out to avoid repetition, since it gets a little more complex in 
   the presence of partially variadic functions */

Obj NargError( Obj func, Int actual) {
  Int narg = NARG_FUNC(func);

  if (narg >= 0) {
    assert(narg != actual);
    return ErrorReturnObj(
			  "Function: number of arguments must be %d (not %d)",
			  narg, actual,
			  "you can replace the argument list <args> via 'return <args>;'" );
  } else {
    assert(-narg-1 > actual);
    return ErrorReturnObj(
        "Function: number of arguments must be at least %d (not %d)",
        -narg-1, actual,
        "you can replace the argument list <args> via 'return <args>;'" );
  }
}

Obj DoFail0args (
    Obj                 self )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx =NargError(self, 0);
    return CallFuncList( self, argx );
}


/****************************************************************************
**
*F  DoFail1args( <self>,<arg1> ) . . .  fail a function call with 1 arguments
*/
Obj DoFail1args (
    Obj                 self,
    Obj                 arg1 )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx =NargError(self, 1);
    return CallFuncList( self, argx );
}


/****************************************************************************
**
*F  DoFail2args( <self>, <arg1>, ... )  fail a function call with 2 arguments
*/
Obj DoFail2args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx =NargError(self, 2);
    return CallFuncList( self, argx );
}


/****************************************************************************
**
*F  DoFail3args( <self>, <arg1>, ... )  fail a function call with 3 arguments
*/
Obj DoFail3args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx =NargError(self, 3);
    return CallFuncList( self, argx );
}


/****************************************************************************
**
*F  DoFail4args( <self>, <arg1>, ... )  fail a function call with 4 arguments
*/
Obj DoFail4args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx =NargError(self, 4);
    return CallFuncList( self, argx );
}


/****************************************************************************
**
*F  DoFail5args( <self>, <arg1>, ... )  fail a function call with 5 arguments
*/
Obj DoFail5args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx =NargError(self, 5);
    return CallFuncList( self, argx );
}


/****************************************************************************
**
*F  DoFail6args( <self>, <arg1>, ... )  fail a function call with 6 arguments
*/
Obj DoFail6args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx =NargError(self, 6);
    return CallFuncList( self, argx );
}


/****************************************************************************
**
*F  DoFailXargs( <self>, <args> )  . .  fail a function call with X arguments
*/
Obj DoFailXargs (
    Obj                 self,
    Obj                 args )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx =NargError(self, LEN_LIST(args));
    return CallFuncList( self, argx );
}


/****************************************************************************
**
*F * * * * * * * * * * * * *  wrapper for profiling * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  TimeDone  . . . . . .   amount of time spent for completed function calls
**
**  'TimeDone' is  the amount of time spent  for all function calls that have
**  already been completed.
*/
UInt TimeDone;


/****************************************************************************
**
*V  StorDone  . . . . .  amount of storage spent for completed function calls
**
**  'StorDone' is the amount of storage spent for all function call that have
**  already been completed.
*/
UInt StorDone;


/****************************************************************************
**
*F  DoProf0args( <self> ) . . . . . . . . profile a function with 0 arguments
**
**  'DoProf<i>args' accepts the <i> arguments <arg1>, <arg2>,  and so on, and
**  calls  the function through the  secondary  handler.  It also updates the
**  profiling  information in  the profiling information   bag of  the called
**  function.  'DoProf<i>args' are  the primary  handlers  for all  functions
**  when profiling is requested.
*/
Obj DoProf0args (
    Obj                 self )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 prof;           /* profiling bag                   */
    UInt                timeElse;       /* time    spent elsewhere         */
    UInt                timeCurr;       /* time    spent in current funcs. */
    UInt                storElse;       /* storage spent elsewhere         */
    UInt                storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    result = CALL_0ARGS_PROF( self );

    /* number of invocation of this function                               */
    SET_COUNT_PROF( prof, COUNT_PROF(prof) + 1 );

    /* time and storage spent in this function and its children            */
    SET_TIME_WITH_PROF( prof, SyTime() - timeElse );
    SET_STOR_WITH_PROF( prof, SizeAllBags - storElse );

    /* time and storage spent by this invocation of this function          */
    timeCurr = SyTime() - TimeDone - timeCurr;
    SET_TIME_WOUT_PROF( prof, TIME_WOUT_PROF(prof) + timeCurr );
    TimeDone += timeCurr;
    storCurr = SizeAllBags - StorDone - storCurr;
    SET_STOR_WOUT_PROF( prof, STOR_WOUT_PROF(prof) + storCurr );
    StorDone += storCurr;

    /* return the result from the function                                 */
    return result;
}


/****************************************************************************
**
*F  DoProf1args( <self>, <arg1>)  . . . . profile a function with 1 arguments
*/
Obj DoProf1args (
    Obj                 self,
    Obj                 arg1 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 prof;           /* profiling bag                   */
    UInt                timeElse;       /* time    spent elsewhere         */
    UInt                timeCurr;       /* time    spent in current funcs. */
    UInt                storElse;       /* storage spent elsewhere         */
    UInt                storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    result = CALL_1ARGS_PROF( self, arg1 );

    /* number of invocation of this function                               */
    SET_COUNT_PROF( prof, COUNT_PROF(prof) + 1 );

    /* time and storage spent in this function and its children            */
    SET_TIME_WITH_PROF( prof, SyTime() - timeElse );
    SET_STOR_WITH_PROF( prof, SizeAllBags - storElse );

    /* time and storage spent by this invocation of this function          */
    timeCurr = SyTime() - TimeDone - timeCurr;
    SET_TIME_WOUT_PROF( prof, TIME_WOUT_PROF(prof) + timeCurr );
    TimeDone += timeCurr;
    storCurr = SizeAllBags - StorDone - storCurr;
    SET_STOR_WOUT_PROF( prof, STOR_WOUT_PROF(prof) + storCurr );
    StorDone += storCurr;

    /* return the result from the function                                 */
    return result;
}


/****************************************************************************
**
*F  DoProf2args( <self>, <arg1>, ... )  . profile a function with 2 arguments
*/
Obj DoProf2args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 prof;           /* profiling bag                   */
    UInt                timeElse;       /* time    spent elsewhere         */
    UInt                timeCurr;       /* time    spent in current funcs. */
    UInt                storElse;       /* storage spent elsewhere         */
    UInt                storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    result = CALL_2ARGS_PROF( self, arg1, arg2 );

    /* number of invocation of this function                               */
    SET_COUNT_PROF( prof, COUNT_PROF(prof) + 1 );

    /* time and storage spent in this function and its children             */
    SET_TIME_WITH_PROF( prof, SyTime() - timeElse );
    SET_STOR_WITH_PROF( prof, SizeAllBags - storElse );

    /* time and storage spent by this invocation of this function           */
    timeCurr = SyTime() - TimeDone - timeCurr;
    SET_TIME_WOUT_PROF( prof, TIME_WOUT_PROF(prof) + timeCurr );
    TimeDone += timeCurr;
    storCurr = SizeAllBags - StorDone - storCurr;
    SET_STOR_WOUT_PROF( prof, STOR_WOUT_PROF(prof) + storCurr );
    StorDone += storCurr;

    /* return the result from the function                                 */
    return result;
}


/****************************************************************************
**
*F  DoProf3args( <self>, <arg1>, ... )  . profile a function with 3 arguments
*/
Obj DoProf3args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 prof;           /* profiling bag                   */
    UInt                timeElse;       /* time    spent elsewhere         */
    UInt                timeCurr;       /* time    spent in current funcs. */
    UInt                storElse;       /* storage spent elsewhere         */
    UInt                storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    result = CALL_3ARGS_PROF( self, arg1, arg2, arg3 );

    /* number of invocation of this function                               */
    SET_COUNT_PROF( prof, COUNT_PROF(prof) + 1 );

    /* time and storage spent in this function and its children            */
    SET_TIME_WITH_PROF( prof, SyTime() - timeElse );
    SET_STOR_WITH_PROF( prof, SizeAllBags - storElse );

    /* time and storage spent by this invocation of this function          */
    timeCurr = SyTime() - TimeDone - timeCurr;
    SET_TIME_WOUT_PROF( prof, TIME_WOUT_PROF(prof) + timeCurr );
    TimeDone += timeCurr;
    storCurr = SizeAllBags - StorDone - storCurr;
    SET_STOR_WOUT_PROF( prof, STOR_WOUT_PROF(prof) + storCurr );
    StorDone += storCurr;

    /* return the result from the function                                 */
    return result;
}


/****************************************************************************
**
*F  DoProf4args( <self>, <arg1>, ... )  . profile a function with 4 arguments
*/
Obj DoProf4args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 prof;           /* profiling bag                   */
    UInt                timeElse;       /* time    spent elsewhere         */
    UInt                timeCurr;       /* time    spent in current funcs. */
    UInt                storElse;       /* storage spent elsewhere         */
    UInt                storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    result = CALL_4ARGS_PROF( self, arg1, arg2, arg3, arg4 );

    /* number of invocation of this function                               */
    SET_COUNT_PROF( prof, COUNT_PROF(prof) + 1 );

    /* time and storage spent in this function and its children            */
    SET_TIME_WITH_PROF( prof, SyTime() - timeElse );
    SET_STOR_WITH_PROF( prof, SizeAllBags - storElse );

    /* time and storage spent by this invocation of this function          */
    timeCurr = SyTime() - TimeDone - timeCurr;
    SET_TIME_WOUT_PROF( prof, TIME_WOUT_PROF(prof) + timeCurr );
    TimeDone += timeCurr;
    storCurr = SizeAllBags - StorDone - storCurr;
    SET_STOR_WOUT_PROF( prof, STOR_WOUT_PROF(prof) + storCurr );
    StorDone += storCurr;

    /* return the result from the function                                 */
    return result;
}


/****************************************************************************
**
*F  DoProf5args( <self>, <arg1>, ... )  . profile a function with 5 arguments
*/
Obj DoProf5args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 prof;           /* profiling bag                   */
    UInt                timeElse;       /* time    spent elsewhere         */
    UInt                timeCurr;       /* time    spent in current funcs. */
    UInt                storElse;       /* storage spent elsewhere         */
    UInt                storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    result = CALL_5ARGS_PROF( self, arg1, arg2, arg3, arg4, arg5 );

    /* number of invocation of this function                               */
    SET_COUNT_PROF( prof, COUNT_PROF(prof) + 1 );

    /* time and storage spent in this function and its children            */
    SET_TIME_WITH_PROF( prof, SyTime() - timeElse );
    SET_STOR_WITH_PROF( prof, SizeAllBags - storElse );

    /* time and storage spent by this invocation of this function          */
    timeCurr = SyTime() - TimeDone - timeCurr;
    SET_TIME_WOUT_PROF( prof, TIME_WOUT_PROF(prof) + timeCurr );
    TimeDone += timeCurr;
    storCurr = SizeAllBags - StorDone - storCurr;
    SET_STOR_WOUT_PROF( prof, STOR_WOUT_PROF(prof) + storCurr );
    StorDone += storCurr;

    /* return the result from the function                                 */
    return result;
}


/****************************************************************************
**
*F  DoProf6args( <self>, <arg1>, ... )  . profile a function with 6 arguments
*/
Obj DoProf6args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 prof;           /* profiling bag                   */
    UInt                timeElse;       /* time    spent elsewhere         */
    UInt                timeCurr;       /* time    spent in current funcs. */
    UInt                storElse;       /* storage spent elsewhere         */
    UInt                storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    result = CALL_6ARGS_PROF( self, arg1, arg2, arg3, arg4, arg5, arg6 );

    /* number of invocation of this function                               */
    SET_COUNT_PROF( prof, COUNT_PROF(prof) + 1 );

    /* time and storage spent in this function and its children            */
    SET_TIME_WITH_PROF( prof, SyTime() - timeElse );
    SET_STOR_WITH_PROF( prof, SizeAllBags - storElse );

    /* time and storage spent by this invocation of this function          */
    timeCurr = SyTime() - TimeDone - timeCurr;
    SET_TIME_WOUT_PROF( prof, TIME_WOUT_PROF(prof) + timeCurr );
    TimeDone += timeCurr;
    storCurr = SizeAllBags - StorDone - storCurr;
    SET_STOR_WOUT_PROF( prof, STOR_WOUT_PROF(prof) + storCurr );
    StorDone += storCurr;

    /* return the result from the function                                 */
    return result;
}


/****************************************************************************
**
*F  DoProfXargs( <self>, <args> ) . . . . profile a function with X arguments
*/
Obj DoProfXargs (
    Obj                 self,
    Obj                 args )
{
    Obj                 result;         /* value of function call, result  */
    Obj                 prof;           /* profiling bag                   */
    UInt                timeElse;       /* time    spent elsewhere         */
    UInt                timeCurr;       /* time    spent in current funcs. */
    UInt                storElse;       /* storage spent elsewhere         */
    UInt                storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    result = CALL_XARGS_PROF( self, args );

    /* number of invocation of this function                               */
    SET_COUNT_PROF( prof, COUNT_PROF(prof) + 1 );

    /* time and storage spent in this function and its children            */
    SET_TIME_WITH_PROF( prof, SyTime() - timeElse );
    SET_STOR_WITH_PROF( prof, SizeAllBags - storElse );

    /* time and storage spent by this invocation of this function          */
    timeCurr = SyTime() - TimeDone - timeCurr;
    SET_TIME_WOUT_PROF( prof, TIME_WOUT_PROF(prof) + timeCurr );
    TimeDone += timeCurr;
    storCurr = SizeAllBags - StorDone - storCurr;
    SET_STOR_WOUT_PROF( prof, STOR_WOUT_PROF(prof) + storCurr );
    StorDone += storCurr;

    /* return the result from the function                                 */
    return result;
}


/****************************************************************************
**
*F * * * * * * * * * * * * *  create a new function * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitHandlerFunc( <handler>, <cookie> ) . . . . . . . . register a handler
**
**  Every handler should  be registered (once) before  it is installed in any
**  function bag. This is needed so that it can be  identified when loading a
**  saved workspace.  <cookie> should be a  unique  C string, identifying the
**  handler
*/
#ifndef MAX_HANDLERS
#define MAX_HANDLERS 20000
#endif

typedef struct {
    ObjFunc             hdlr;
    const Char *        cookie;
}
TypeHandlerInfo;

static UInt HandlerSortingStatus = 0;

static TypeHandlerInfo HandlerFuncs[MAX_HANDLERS];
static UInt NHandlerFuncs = 0;
 
void InitHandlerFunc (
    ObjFunc             hdlr,
    const Char *        cookie )
{
    if ( NHandlerFuncs >= MAX_HANDLERS ) {
        Pr( "No room left for function handler\n", 0L, 0L );
        SyExit(1);
    }
#ifdef DEBUG_HANDLER_REGISTRATION
    {
      UInt i;
      for (i = 0; i < NHandlerFuncs; i++)
        if (!strcmp(HandlerFuncs[i].cookie, cookie))
          Pr("Duplicate cookie %s\n", (Int)cookie, 0L);
    }
#endif
    HandlerFuncs[NHandlerFuncs].hdlr   = hdlr;
    HandlerFuncs[NHandlerFuncs].cookie = cookie;
    HandlerSortingStatus = 0; /* no longer sorted by handler or cookie */
    NHandlerFuncs++;
}



/****************************************************************************
**
*f  CheckHandlersBag( <bag> ) . . . . . . check that handlers are initialised
*/

#ifdef DEBUG_HANDLER_REGISTRATION

static void CheckHandlersBag(
    Bag         bag )
{
    UInt        i;
    UInt        j;
    ObjFunc     hdlr;

    if ( TNUM_BAG(bag) == T_FUNCTION ) {
        for ( j = 0;  j < 8;  j++ ) {
            hdlr = HDLR_FUNC(bag,j);

            /* zero handlers are used in a few odd places                  */
            if ( hdlr != 0 ) {
                for ( i = 0;  i < NHandlerFuncs;  i++ ) {
                    if ( hdlr == HandlerFuncs[i].hdlr )
                        break;
                }
                if ( i == NHandlerFuncs ) {
                    Pr("Unregistered Handler %d args  ", j, 0L);
                    PrintObj(NAME_FUNC(bag));
                    Pr("\n",0L,0L);
                }
            }
        }
    }
}

void CheckAllHandlers(
       void )
{
  CallbackForAllBags( CheckHandlersBag);
}

#endif

static int IsLessHandlerInfo (
    TypeHandlerInfo *           h1, 
    TypeHandlerInfo *           h2,
    UInt                        byWhat )
{
    switch (byWhat) {
        case 1:
            /* cast to please Irix CC and HPUX CC */
            return (UInt)(h1->hdlr) < (UInt)(h2->hdlr);
        case 2:
            return strcmp(h1->cookie, h2->cookie) < 0;
        default:
            ErrorQuit( "Invalid sort mode %u", (Int)byWhat, 0L );
            return 0; /* please lint */
    }
}

void SortHandlers( UInt byWhat )
{
  TypeHandlerInfo tmp;
  UInt len, h, i, k;
  if (HandlerSortingStatus == byWhat)
    return;
  len = NHandlerFuncs;
  h = 1;
  while ( 9*h + 4 < len ) 
    { h = 3*h + 1; }
  while ( 0 < h ) {
    for ( i = h; i < len; i++ ) {
      tmp = HandlerFuncs[i];
      k = i;
      while ( h <= k && IsLessHandlerInfo(&tmp, HandlerFuncs+(k-h), byWhat))
        {
          HandlerFuncs[k] = HandlerFuncs[k-h];
          k -= h;
        }
      HandlerFuncs[k] = tmp;
    }
    h = h / 3;
  }
  HandlerSortingStatus = byWhat;
}

const Char * CookieOfHandler (
    ObjFunc             hdlr )
{
    UInt                i, top, bottom, middle;

    if ( HandlerSortingStatus != 1 ) {
        for ( i = 0; i < NHandlerFuncs; i++ ) {
            if ( hdlr == HandlerFuncs[i].hdlr )
                return HandlerFuncs[i].cookie;
        }
        return (Char *)0L;
    }
    else {
        top = NHandlerFuncs;
        bottom = 0;
        while ( top >= bottom ) {
            middle = (top + bottom)/2;
            if ( (UInt)(hdlr) < (UInt)(HandlerFuncs[middle].hdlr) )
                top = middle-1;
            else if ( (UInt)(hdlr) > (UInt)(HandlerFuncs[middle].hdlr) )
                bottom = middle+1;
            else
                return HandlerFuncs[middle].cookie;
        }
        return (Char *)0L;
    }
}

ObjFunc HandlerOfCookie(
       const Char * cookie )
{
  Int i,top,bottom,middle;
  Int res;
  if (HandlerSortingStatus != 2) 
    {
      for (i = 0; i < NHandlerFuncs; i++)
        {
          if (strcmp(cookie, HandlerFuncs[i].cookie) == 0)
            return HandlerFuncs[i].hdlr;
        }
      return (ObjFunc)0L;
    }
  else
    {
      top = NHandlerFuncs;
      bottom = 0;
      while (top >= bottom) {
        middle = (top + bottom)/2;
        res = strcmp(cookie,HandlerFuncs[middle].cookie);
        if (res < 0)
          top = middle-1;
        else if (res > 0)
          bottom = middle+1;
        else
          return HandlerFuncs[middle].hdlr;
      }
      return (ObjFunc)0L;
    }
}
                                      
                       

/****************************************************************************
**
*F  NewFunction( <name>, <narg>, <nams>, <hdlr> ) . . . . make a new function
**
**  'NewFunction' creates and returns a new function.  <name> must be  a  GAP
**  string containing the name of the function.  <narg> must be the number of
**  arguments, where -1 means a variable number of arguments.  <nams> must be
**  a GAP list containg the names  of  the  arguments.  <hdlr>  must  be  the
**  C function (accepting <self> and  the  <narg>  arguments)  that  will  be
**  called to execute the function.
*/
Obj NewFunction (
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr )
{
    return NewFunctionT( T_FUNCTION, SIZE_FUNC, name, narg, nams, hdlr );
}
    

/****************************************************************************
**
*F  NewFunctionC( <name>, <narg>, <nams>, <hdlr> )  . . . make a new function
**
**  'NewFunctionC' does the same as 'NewFunction',  but  expects  <name>  and
**  <nams> as C strings.
*/
Obj NewFunctionC (
    const Char *        name,
    Int                 narg,
    const Char *        nams,
    ObjFunc             hdlr )
{
    return NewFunctionCT( T_FUNCTION, SIZE_FUNC, name, narg, nams, hdlr );
}
    

/****************************************************************************
**
*F  NewFunctionT( <type>, <size>, <name>, <narg>, <nams>, <hdlr> )
**
**  'NewFunctionT' does the same as 'NewFunction', but allows to specify  the
**  <type> and <size> of the newly created bag.
*/
Obj NewFunctionT (
    UInt                type,
    UInt                size,
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr )
{
    Obj                 func;           /* function, result                */
    Obj                 prof;           /* profiling bag                   */


    /* make the function object                                            */
    func = NewBag( type, size );

    /* create a function with a fixed number of arguments                  */
    if ( narg >= 0 ) {
        SET_HDLR_FUNC(func, 0, DoFail0args);
        SET_HDLR_FUNC(func, 1, DoFail1args);
        SET_HDLR_FUNC(func, 2, DoFail2args);
        SET_HDLR_FUNC(func, 3, DoFail3args);
        SET_HDLR_FUNC(func, 4, DoFail4args);
        SET_HDLR_FUNC(func, 5, DoFail5args);
        SET_HDLR_FUNC(func, 6, DoFail6args);
        SET_HDLR_FUNC(func, 7, DoFailXargs);
        SET_HDLR_FUNC(func, (narg <= 6 ? narg : 7), hdlr );
    }

    /* create a function with a variable number of arguments               */
    else {
      SET_HDLR_FUNC(func, 0, (narg >= -1) ? DoWrap0args : DoFail0args);
      SET_HDLR_FUNC(func, 1, (narg >= -2) ? DoWrap1args : DoFail1args);
      SET_HDLR_FUNC(func, 2, (narg >= -3) ? DoWrap2args : DoFail2args);
      SET_HDLR_FUNC(func, 3, (narg >= -4) ? DoWrap3args : DoFail3args);
      SET_HDLR_FUNC(func, 4, (narg >= -5) ? DoWrap4args : DoFail4args);
      SET_HDLR_FUNC(func, 5, (narg >= -6) ? DoWrap5args : DoFail5args);
      SET_HDLR_FUNC(func, 6, (narg >= -7) ? DoWrap6args : DoFail6args);
      SET_HDLR_FUNC(func, 7, hdlr);
    }

    /* enter the arguments and the names                               */
    SET_NAME_FUNC(func, ConvImmString(name));
    SET_NARG_FUNC(func, narg);
    SET_NAMS_FUNC(func, nams);
    if (nams) MakeBagPublic(nams);
    CHANGED_BAG(func);

    /* enter the profiling bag                                             */
    prof = NEW_PLIST( T_PLIST, LEN_PROF );
    SET_LEN_PLIST( prof, LEN_PROF );
    SET_COUNT_PROF( prof, 0 );
    SET_TIME_WITH_PROF( prof, 0 );
    SET_TIME_WOUT_PROF( prof, 0 );
    SET_STOR_WITH_PROF( prof, 0 );
    SET_STOR_WOUT_PROF( prof, 0 );
    SET_PROF_FUNC(func, prof);
    CHANGED_BAG(func);

    /* return the function bag                                             */
    return func;
}
    

/****************************************************************************
**
*F  NewFunctionCT( <type>, <size>, <name>, <narg>, <nams>, <hdlr> )
**
**  'NewFunctionCT' does the same as 'NewFunction', but  expects  <name>  and
**  <nams> as C strings, and allows to specify the <type> and <size>  of  the
**  newly created bag.
*/
Obj NewFunctionCT (
    UInt                type,
    UInt                size,
    const Char *        name_c,
    Int                 narg,
    const Char *        nams_c,
    ObjFunc             hdlr )
{
    Obj                 name_o;         /* name as an object               */

    /* convert the name to an object                                       */
    name_o = MakeImmString(name_c);

    /* make the function                                                   */
    return NewFunctionT( type, size, name_o, narg, ArgStringToList( nams_c ), hdlr );
}
    

/****************************************************************************
**
*F  ArgStringToList( <nams_c> )
**
** 'ArgStringToList' takes a C string <nams_c> containing a list of comma
** separated argument names, and turns it into a plist of strings, ready
** to be passed to 'NewFunction' as <nams>.
*/
Obj ArgStringToList(const Char *nams_c) {
    Obj                 tmp;            /* argument name as an object      */
    Obj                 nams_o;         /* nams as an object               */
    UInt                len;            /* length                          */
    UInt                i, k, l;        /* loop variables                  */

    /* convert the arguments list to an object                             */
    len = 0;
    for ( k = 0; nams_c[k] != '\0'; k++ ) {
        if ( (0 == k || nams_c[k-1] == ' ' || nams_c[k-1] == ',')
          && (          nams_c[k  ] != ' ' && nams_c[k  ] != ',') ) {
            len++;
        }
    }
    nams_o = NEW_PLIST( T_PLIST, len );
    SET_LEN_PLIST( nams_o, len );
    k = 0;
    for ( i = 1; i <= len; i++ ) {
        while ( nams_c[k] == ' ' || nams_c[k] == ',' ) {
            k++;
        }
        l = k;
        while ( nams_c[l] != ' ' && nams_c[l] != ',' && nams_c[l] != '\0' ) {
            l++;
        }
        C_NEW_STRING( tmp, l - k, nams_c + k );
        RetypeBag( tmp, T_STRING+IMMUTABLE );
        SET_ELM_PLIST( nams_o, i, tmp );
        CHANGED_BAG( nams_o );
        k = l;
    }

    return nams_o;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * type and print function  * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  TypeFunction( <func> )  . . . . . . . . . . . . . . .  type of a function
**
**  'TypeFunction' returns the type of the function <func>.
**
**  'TypeFunction' is the function in 'TypeObjFuncs' for functions.
*/
Obj TYPE_FUNCTION;
Obj TYPE_OPERATION;

Obj TypeFunction (
    Obj                 func )
{
    return ( IS_OPERATION(func) ? TYPE_OPERATION : TYPE_FUNCTION );
}



/****************************************************************************
**
*F  PrintFunction( <func> )   . . . . . . . . . . . . . . .  print a function
**
*/

Obj PrintOperation;

void PrintFunction (
    Obj                 func )
{
    Int                 narg;           /* number of arguments             */
    Int                 nloc;           /* number of locals                */
    Obj                 oldLVars;       /* terrible hack                   */
    UInt                i;              /* loop variable                   */
    UInt                isvarg;         /* does function have varargs?     */
#ifdef HPCGAP
    UChar               *locks = 0L;
#endif

    isvarg = 0;

    if ( IS_OPERATION(func) ) {
      CALL_1ARGS( PrintOperation, func );
      return;
    }

#ifdef HPCGAP
    /* print 'function (' or 'atomic function ('                          */
    if (LCKS_FUNC(func)) {
      locks = CHARS_STRING(LCKS_FUNC(func));
      Pr("%5>atomic function%< ( %>",0L,0L);
    } else
      Pr("%5>function%< ( %>",0L,0L);
#else
    /* print 'function ('                                                  */
    Pr("%5>function%< ( %>",0L,0L);
#endif

    /* print the arguments                                                 */
    narg = NARG_FUNC(func);
    if (narg < 0) {
      isvarg = 1;
      narg = -narg;
    }
    
    for ( i = 1; i <= narg; i++ ) {
#ifdef HPCGAP
        if (locks) {
            switch(locks[i-1]) {
            case 1:
                Pr("%>readonly %<", 0L, 0L);
                break;
            case 2:
                Pr("%>readwrite %<", 0L, 0L);
                break;
            }
        }
#endif
        if ( NAMS_FUNC(func) != 0 )
            Pr( "%I", (Int)NAMI_FUNC( func, (Int)i ), 0L );
        else
            Pr( "<<arg-%d>>", (Int)i, 0L );
        if(isvarg && i == narg) {
            Pr("...", 0L, 0L);
        }
        if ( i != narg )  Pr("%<, %>",0L,0L);
    }
    Pr(" %<)",0L,0L);

        Pr("\n",0L,0L);

        /* print the locals                                                */
        nloc = NLOC_FUNC(func);
        if ( nloc >= 1 ) {
            Pr("%>local  ",0L,0L);
            for ( i = 1; i <= nloc; i++ ) {
                if ( NAMS_FUNC(func) != 0 )
                    Pr( "%I", (Int)NAMI_FUNC( func, (Int)(narg+i) ), 0L );
                else
                    Pr( "<<loc-%d>>", (Int)i, 0L );
                if ( i != nloc )  Pr("%<, %>",0L,0L);
            }
            Pr("%<;\n",0L,0L);
        }

        /* print the body                                                  */
        if (FuncIsKernelFunction(0L, func) == True) {
            UInt outputtedfunc = 0;
            if ( BODY_FUNC(func) ) {
                Obj body = BODY_FUNC(func);
                if ( GET_FILENAME_BODY(body) ) {
                    if ( GET_LOCATION_BODY(body) ) {
                        Pr("<<kernel code from %s:%s>>",
                            (Int)CSTR_STRING(GET_FILENAME_BODY(body)),
                            (Int)CSTR_STRING(GET_LOCATION_BODY(body)));
                            outputtedfunc = 1;
                    }
                    else if ( GET_STARTLINE_BODY(body) ) {
                        Pr("<<compiled GAP code from %s:%d>>",
                            (Int)CSTR_STRING(GET_FILENAME_BODY(body)),
                            GET_STARTLINE_BODY(body));
                            outputtedfunc = 1;
                    }
                }
            }
            if(!outputtedfunc) {
                Pr("<<kernel or compiled code>>",0L,0L);
            }
        }
        else {
            SWITCH_TO_NEW_LVARS( func, narg, NLOC_FUNC(func),
                                 oldLVars );
            PrintStat( FIRST_STAT_CURR_FUNC );
            SWITCH_TO_OLD_LVARS( oldLVars );
        }
        Pr("%4<\n",0L,0L);
    
    /* print 'end'                                                         */
    Pr("end",0L,0L);
}


/****************************************************************************
**
*F  FuncIS_FUNCTION( <self>, <func> ) . . . . . . . . . . . test for function
**
**  'FuncIS_FUNCTION' implements the internal function 'IsFunction'.
**
**  'IsFunction( <func> )'
**
**  'IsFunction' returns   'true'  if  <func>   is a function    and  'false'
**  otherwise.
*/
Obj IsFunctionFilt;

Obj FuncIS_FUNCTION (
    Obj                 self,
    Obj                 obj )
{
    if      ( TNUM_OBJ(obj) == T_FUNCTION ) {
        return True;
    }
    else if ( TNUM_OBJ(obj) < FIRST_EXTERNAL_TNUM ) {
        return False;
    }
    else {
        return DoFilter( self, obj );
    }
}


/****************************************************************************
**
*F  FuncCALL_FUNC_LIST( <self>, <func>, <list> )  . . . . . . call a function
**
**  'FuncCALL_FUNC_LIST' implements the internal function 'CallFuncList'.
**
**  'CallFuncList( <func>, <list> )'
**
**  'CallFuncList' calls the  function <func> with the arguments list <list>,
**  i.e., it is equivalent to '<func>( <list>[1], <list>[2]... )'.
*/
Obj CallFuncListOper;
Obj CallFuncListWrapOper;

Obj CallFuncList ( Obj func, Obj list )
{
    Obj                 result;         /* result                          */
    Obj                 list2;          /* list of arguments               */
    Obj                 arg;            /* one argument                    */
    UInt                i;              /* loop variable                   */
   

    if (TNUM_OBJ(func) == T_FUNCTION) {

      /* call the function                                                   */
      if      ( LEN_LIST(list) == 0 ) {
        result = CALL_0ARGS( func );
      }
      else if ( LEN_LIST(list) == 1 ) {
        result = CALL_1ARGS( func, ELMV_LIST(list,1) );
      }
      else if ( LEN_LIST(list) == 2 ) {
        result = CALL_2ARGS( func, ELMV_LIST(list,1), ELMV_LIST(list,2) );
      }
      else if ( LEN_LIST(list) == 3 ) {
        result = CALL_3ARGS( func, ELMV_LIST(list,1), ELMV_LIST(list,2),
                             ELMV_LIST(list,3) );
      }
      else if ( LEN_LIST(list) == 4 ) {
        result = CALL_4ARGS( func, ELMV_LIST(list,1), ELMV_LIST(list,2),
                             ELMV_LIST(list,3), ELMV_LIST(list,4) );
      }
      else if ( LEN_LIST(list) == 5 ) {
        result = CALL_5ARGS( func, ELMV_LIST(list,1), ELMV_LIST(list,2),
                             ELMV_LIST(list,3), ELMV_LIST(list,4),
                             ELMV_LIST(list,5) );
      }
      else if ( LEN_LIST(list) == 6 ) {
        result = CALL_6ARGS( func, ELMV_LIST(list,1), ELMV_LIST(list,2),
                             ELMV_LIST(list,3), ELMV_LIST(list,4),
                             ELMV_LIST(list,5), ELMV_LIST(list,6) );
      }
      else {
        list2 = NEW_PLIST( T_PLIST, LEN_LIST(list) );
        SET_LEN_PLIST( list2, LEN_LIST(list) );
        for ( i = 1; i <= LEN_LIST(list); i++ ) {
          arg = ELMV_LIST( list, (Int)i );
          SET_ELM_PLIST( list2, i, arg );
        }
        result = CALL_XARGS( func, list2 );
      }
    } else {
      result = DoOperation2Args(CallFuncListOper, func, list);
    }
    /* return the result                                                   */
    return result;

}

Obj FuncCALL_FUNC_LIST (
    Obj                 self,
    Obj                 func,
    Obj                 list )
{
    /* check that the second argument is a list                            */
    if ( ! IS_SMALL_LIST( list ) ) {
       ErrorMayQuit("CallFuncList: <list> must be a small list", 0L, 0L);
    }
    return CallFuncList(func, list);
}

Obj FuncCALL_FUNC_LIST_WRAP (
    Obj                 self,
    Obj                 func,
    Obj                 list )
{
    Obj retval, retlist;
    /* check that the second argument is a list                            */
    if ( ! IS_SMALL_LIST( list ) ) {
       ErrorMayQuit("CallFuncListWrap: <list> must be a small list", 0L, 0L);
    }
    retval = CallFuncList(func, list);

    if (retval == 0)
    {
        retlist = NEW_PLIST(T_PLIST_EMPTY + IMMUTABLE, 0);
    }
    else
    {
        retlist = NEW_PLIST(T_PLIST, 1);
        SET_LEN_PLIST(retlist, 1);
        SET_ELM_PLIST(retlist, 1, retval);
        CHANGED_BAG(retlist);
    }
    return retlist;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * * * utility functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncNAME_FUNC( <self>, <func> ) . . . . . . . . . . .  name of a function
*/
Obj NAME_FUNC_Oper;
Obj SET_NAME_FUNC_Oper;

Obj FuncNAME_FUNC (
    Obj                 self,
    Obj                 func )
{
    Obj                 name;

    if ( TNUM_OBJ(func) == T_FUNCTION ) {
        name = NAME_FUNC(func);
        if ( name == 0 ) {
            name = MakeImmString("unknown");
            SET_NAME_FUNC(func, name);
            CHANGED_BAG(func);
        }
        return name;
    }
    else {
        return DoOperation1Args( self, func );
    }
}

Obj FuncSET_NAME_FUNC(
                      Obj self,
                      Obj func,
                      Obj name )
{
  while (!IsStringConv(name)) {
    name = ErrorReturnObj("SET_NAME_FUNC( <func>, <name> ): <name> must be a string, not a %s",
                          (Int)TNAM_OBJ(name), 0, "YOu can return a new name to continue");
  }
  if (TNUM_OBJ(func) == T_FUNCTION ) {
    SET_NAME_FUNC(func, ConvImmString(name));
    CHANGED_BAG(func);
  } else
    DoOperation2Args(SET_NAME_FUNC_Oper, func, name);
  return (Obj) 0;
}


/****************************************************************************
**
*F  FuncNARG_FUNC( <self>, <func> ) . . . . number of arguments of a function
*/
Obj NARG_FUNC_Oper;

Obj FuncNARG_FUNC (
    Obj                 self,
    Obj                 func )
{
    if ( TNUM_OBJ(func) == T_FUNCTION ) {
        return INTOBJ_INT( NARG_FUNC(func) );
    }
    else {
        return DoOperation1Args( self, func );
    }
}


/****************************************************************************
**
*F  FuncNAMS_FUNC( <self>, <func> ) . . . . names of local vars of a function
*/
Obj NAMS_FUNC_Oper;

Obj FuncNAMS_FUNC (
    Obj                 self,
    Obj                 func )
{
  Obj nams;
    if ( TNUM_OBJ(func) == T_FUNCTION ) {
        nams = NAMS_FUNC(func);
        return (nams != (Obj)0) ? nams : Fail;
    }
    else {
        return DoOperation1Args( self, func );
    }
}

#ifdef HPCGAP

/****************************************************************************
**
*F  FuncLOCKS_FUNC( <self>, <func> ) . . . . locking status of a possibly
**                                           atomic function
*/
Obj LOCKS_FUNC_Oper;

Obj FuncLOCKS_FUNC (
    Obj                 self,
    Obj                 func )
{
  Obj locks;
    if ( TNUM_OBJ(func) == T_FUNCTION ) {
      locks = LCKS_FUNC(func);
      if ( locks == (Obj)0) 
	return Fail;
      else
	return locks;
    }
    else {
        return DoOperation1Args( self, func );
    }
}

#endif


/****************************************************************************
**
*F  FuncPROF_FUNC( <self>, <func> ) . . . . . .  profiling info of a function
*/
Obj PROF_FUNC_Oper;

Obj FuncPROF_FUNC (
    Obj                 self,
    Obj                 func )
{
    Obj                 prof;

    if ( TNUM_OBJ(func) == T_FUNCTION ) {
        prof = PROF_FUNC(func);
        if ( TNUM_OBJ(prof) == T_FUNCTION ) {
            return PROF_FUNC(prof);
        } else {
            return prof;
        }
    }
    else {
        return DoOperation1Args( self, func );
    }
}


/****************************************************************************
**
*F  FuncCLEAR_PROFILE_FUNC( <self>, <func> )  . . . . . . . . . clear profile
*/
Obj FuncCLEAR_PROFILE_FUNC(
    Obj                 self,
    Obj                 func )
{
    Obj                 prof;

    /* check the argument                                                  */
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit( "<func> must be a function", 0L, 0L );
        return 0;
    }

    /* clear profile info                                                  */
    prof = PROF_FUNC(func);
    if ( prof == 0 ) {
        ErrorQuit( "<func> has corrupted profile info", 0L, 0L );
        return 0;
    }
    if ( TNUM_OBJ(prof) == T_FUNCTION ) {
        prof = PROF_FUNC(prof);
    }
    if ( prof == 0 ) {
        ErrorQuit( "<func> has corrupted profile info", 0L, 0L );
        return 0;
    }
    SET_COUNT_PROF( prof, 0 );
    SET_TIME_WITH_PROF( prof, 0 );
    SET_TIME_WOUT_PROF( prof, 0 );
    SET_STOR_WITH_PROF( prof, 0 );
    SET_STOR_WOUT_PROF( prof, 0 );

    return (Obj)0;
}


/****************************************************************************
**
*F  FuncPROFILE_FUNC( <self>, <func> )  . . . . . . . . . . . . start profile
*/
Obj FuncPROFILE_FUNC(
    Obj                 self,
    Obj                 func )
{
    Obj                 prof;
    Obj                 copy;

    /* check the argument                                                  */
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit( "<func> must be a function", 0L, 0L );
        return 0;
    }
    /* uninstall trace handler                                             */
    ChangeDoOperations( func, 0 );

    /* install profiling                                                   */
    prof = PROF_FUNC(func);
    
    /* install new handlers                                                */
    if ( TNUM_OBJ(prof) != T_FUNCTION ) {
        copy = NewBag( TNUM_OBJ(func), SIZE_OBJ(func) );
        SET_HDLR_FUNC(copy,0, HDLR_FUNC(func,0));
        SET_HDLR_FUNC(copy,1, HDLR_FUNC(func,1));
        SET_HDLR_FUNC(copy,2, HDLR_FUNC(func,2));
        SET_HDLR_FUNC(copy,3, HDLR_FUNC(func,3));
        SET_HDLR_FUNC(copy,4, HDLR_FUNC(func,4));
        SET_HDLR_FUNC(copy,5, HDLR_FUNC(func,5));
        SET_HDLR_FUNC(copy,6, HDLR_FUNC(func,6));
        SET_HDLR_FUNC(copy,7, HDLR_FUNC(func,7));
        SET_NAME_FUNC(copy,   NAME_FUNC(func));
        SET_NARG_FUNC(copy,   NARG_FUNC(func));
        SET_NAMS_FUNC(copy,   NAMS_FUNC(func));
        SET_PROF_FUNC(copy,   PROF_FUNC(func));
        SET_HDLR_FUNC(func,0, DoProf0args);
        SET_HDLR_FUNC(func,1, DoProf1args);
        SET_HDLR_FUNC(func,2, DoProf2args);
        SET_HDLR_FUNC(func,3, DoProf3args);
        SET_HDLR_FUNC(func,4, DoProf4args);
        SET_HDLR_FUNC(func,5, DoProf5args);
        SET_HDLR_FUNC(func,6, DoProf6args);
        SET_HDLR_FUNC(func,7, DoProfXargs);
        SET_PROF_FUNC(func,   copy);
        CHANGED_BAG(func);
    }

    return (Obj)0;
}


/****************************************************************************
**
*F  FuncIS_PROFILED_FUNC( <self>, <func> )  . . check if function is profiled
*/
Obj FuncIS_PROFILED_FUNC(
    Obj                 self,
    Obj                 func )
{
    /* check the argument                                                  */
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit( "<func> must be a function", 0L, 0L );
        return 0;
    }
    return ( TNUM_OBJ(PROF_FUNC(func)) != T_FUNCTION ) ? False : True;
}

Obj FuncFILENAME_FUNC(Obj self, Obj func) {

    /* check the argument                                                  */
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit( "<func> must be a function", 0L, 0L );
        return 0;
    }

    if (BODY_FUNC(func)) {
        Obj fn =  GET_FILENAME_BODY(BODY_FUNC(func));
        if (fn)
            return fn;
    }
    return Fail;
}

Obj FuncSTARTLINE_FUNC(Obj self, Obj func) {
    /* check the argument                                                  */
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit( "<func> must be a function", 0L, 0L );
        return 0;
    }

    if (BODY_FUNC(func)) {
        UInt sl = GET_STARTLINE_BODY(BODY_FUNC(func));
        if (sl)
            return INTOBJ_INT(sl);
    }
    return Fail;
}

Obj FuncENDLINE_FUNC(Obj self, Obj func) {
    /* check the argument                                                  */
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit( "<func> must be a function", 0L, 0L );
        return 0;
    }

    if (BODY_FUNC(func)) {
        UInt el = GET_ENDLINE_BODY(BODY_FUNC(func));
        if (el)
            return INTOBJ_INT(el);
    }
    return Fail;
}

Obj FuncLOCATION_FUNC(Obj self, Obj func) {
    /* check the argument                                                  */
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit( "<func> must be a function", 0L, 0L );
        return 0;
    }

    if (BODY_FUNC(func)) {
        Obj sl = GET_LOCATION_BODY(BODY_FUNC(func));
        if (sl)
            return sl;
    }
    return Fail;
}

/****************************************************************************
**
*F  FuncUNPROFILE_FUNC( <self>, <func> )  . . . . . . . . . . .  stop profile
*/
Obj FuncUNPROFILE_FUNC(
    Obj                 self,
    Obj                 func )
{
    Obj                 prof;

    /* check the argument                                                  */
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit( "<func> must be a function", 0L, 0L );
        return 0;
    }

    /* uninstall trace handler                                             */
    ChangeDoOperations( func, 0 );

    /* profiling is active, restore handlers                               */
    prof = PROF_FUNC(func);
    if ( TNUM_OBJ(prof) == T_FUNCTION ) {
        for (Int i = 0; i <= 7; i++)
            SET_HDLR_FUNC(func, i, HDLR_FUNC(prof, i));
        SET_PROF_FUNC(func, PROF_FUNC(prof));
        CHANGED_BAG(func);
    }

    return (Obj)0;
}

Obj FuncIsKernelFunction(Obj self, Obj func) {
  if (!IS_FUNC(func))
    return Fail;
  else 
    return ((BODY_FUNC(func) == 0) ||
            (SIZE_OBJ(BODY_FUNC(func))
             == sizeof(BodyHeader))) ? True : False;
}

Obj FuncHandlerCookieOfFunction(Obj self, Obj func)
{
  Int narg;
  ObjFunc hdlr;
  const Char *cookie;
  Obj cookieStr;
  if (!IS_FUNC(func))
    return Fail;
  narg = NARG_FUNC(func);
  if (narg == -1)
    narg = 7;
  hdlr = HDLR_FUNC(func, narg);
  cookie = CookieOfHandler(hdlr);
  cookieStr = MakeString(cookie);
  return cookieStr;
}

/****************************************************************************
**
*F  SaveFunction( <func> )  . . . . . . . . . . . . . . . . . save a function
**
*/
void SaveFunction ( Obj func )
{
  FunctionHeader * header = FUNC_HEADER(func);
  for (UInt i = 0; i <= 7; i++)
    SaveHandler(header->handlers[i]);
  SaveSubObj(header->name);
  SaveUInt(header->nargs);
  SaveSubObj(header->namesOfLocals);
  SaveSubObj(header->prof);
  SaveUInt(header->nloc);
  SaveSubObj(header->body);
  SaveSubObj(header->envi);
  SaveSubObj(header->fexs);
  if (SIZE_OBJ(func) != SIZE_FUNC)
    SaveOperationExtras( func );
}

/****************************************************************************
**
*F  LoadFunction( <func> )  . . . . . . . . . . . . . . . . . load a function
**
*/
void LoadFunction ( Obj func )
{
  FunctionHeader * header = FUNC_HEADER(func);
  for (UInt i = 0; i <= 7; i++)
    header->handlers[i] = LoadHandler();
  header->name = LoadSubObj();
  header->nargs = LoadUInt();
  header->namesOfLocals = LoadSubObj();
  header->prof = LoadSubObj();
  header->nloc = LoadUInt();
  header->body = LoadSubObj();
  header->envi = LoadSubObj();
  header->fexs = LoadSubObj();
  if (SIZE_OBJ(func) != SIZE_FUNC)
    LoadOperationExtras( func );
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILTER(IS_FUNCTION, "obj", &IsFunctionFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    GVAR_OPER(CALL_FUNC_LIST, 2, "func, list", &CallFuncListOper),
    GVAR_OPER(CALL_FUNC_LIST_WRAP, 2, "func, list", &CallFuncListWrapOper),
    GVAR_OPER(NAME_FUNC, 1, "func", &NAME_FUNC_Oper),
    GVAR_OPER(SET_NAME_FUNC, 2, "func, name", &SET_NAME_FUNC_Oper),
    GVAR_OPER(NARG_FUNC, 1, "func", &NARG_FUNC_Oper),
    GVAR_OPER(NAMS_FUNC, 1, "func", &NAMS_FUNC_Oper),
#ifdef HPCGAP
    GVAR_OPER(LOCKS_FUNC, 1, "func", &LOCKS_FUNC_Oper),
#endif
    GVAR_OPER(PROF_FUNC, 1, "func", &PROF_FUNC_Oper),
    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(CLEAR_PROFILE_FUNC, 1, "func"),
    GVAR_FUNC(IS_PROFILED_FUNC, 1, "func"),
    GVAR_FUNC(PROFILE_FUNC, 1, "func"),
    GVAR_FUNC(UNPROFILE_FUNC, 1, "func"),
    GVAR_FUNC(IsKernelFunction, 1, "func"),
    GVAR_FUNC(HandlerCookieOfFunction, 1, "func"),
    GVAR_FUNC(FILENAME_FUNC, 1, "func"),
    GVAR_FUNC(LOCATION_FUNC, 1, "func"),
    GVAR_FUNC(STARTLINE_FUNC, 1, "func"),
    GVAR_FUNC(ENDLINE_FUNC, 1, "func"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  
    /* install the marking functions                                       */
    InfoBags[ T_FUNCTION ].name = "function";
    InitMarkFuncBags( T_FUNCTION , MarkAllSubBags );

    /* install the type functions                                          */
    ImportGVarFromLibrary( "TYPE_FUNCTION",  &TYPE_FUNCTION  );
    ImportGVarFromLibrary( "TYPE_OPERATION", &TYPE_OPERATION );
    TypeObjFuncs[ T_FUNCTION ] = TypeFunction;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* and the saving function                                             */
    SaveObjFuncs[ T_FUNCTION ] = SaveFunction;
    LoadObjFuncs[ T_FUNCTION ] = LoadFunction;

    /* install the printer                                                 */
    InitFopyGVar( "PRINT_OPERATION", &PrintOperation );
    PrintObjFuncs[ T_FUNCTION ] = PrintFunction;


    /* initialise all 'Do<Something><N>args' handlers, give the most       */
    /* common ones short cookies to save space in in the saved workspace   */
    InitHandlerFunc( DoFail0args, "f0" );
    InitHandlerFunc( DoFail1args, "f1" );
    InitHandlerFunc( DoFail2args, "f2" );
    InitHandlerFunc( DoFail3args, "f3" );
    InitHandlerFunc( DoFail4args, "f4" );
    InitHandlerFunc( DoFail5args, "f5" );
    InitHandlerFunc( DoFail6args, "f6" );
    InitHandlerFunc( DoFailXargs, "f7" );

    InitHandlerFunc( DoWrap0args, "w0" );
    InitHandlerFunc( DoWrap1args, "w1" );
    InitHandlerFunc( DoWrap2args, "w2" );
    InitHandlerFunc( DoWrap3args, "w3" );
    InitHandlerFunc( DoWrap4args, "w4" );
    InitHandlerFunc( DoWrap5args, "w5" );
    InitHandlerFunc( DoWrap6args, "w6" );

    InitHandlerFunc( DoProf0args, "p0" );
    InitHandlerFunc( DoProf1args, "p1" );
    InitHandlerFunc( DoProf2args, "p2" );
    InitHandlerFunc( DoProf3args, "p3" );
    InitHandlerFunc( DoProf4args, "p4" );
    InitHandlerFunc( DoProf5args, "p5" );
    InitHandlerFunc( DoProf6args, "p6" );
    InitHandlerFunc( DoProfXargs, "pX" );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module ){
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoCalls() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "calls",                            /* name                           */
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

StructInitInfo * InitInfoCalls ( void )
{
    return &module;
}
