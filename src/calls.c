/****************************************************************************
**
*W  calls.c                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
char * Revision_calls_c =
   "@(#)$Id$";


#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* Bag, NewBag                     */
#include        "objects.h"             /* Obj, TNUM_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */

#define INCLUDE_DECLARATION_PART
#include        "calls.h"               /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "opers.h"               /* NewFilterC                      */

#include        "lists.h"               /* IS_LIST, LEN_LIST, ELM_LIST, ...*/

#include        "bool.h"                /* True, False                     */

#include        "plist.h"               /* SET_LEN_PLIST, SET_ELM_PLIST,...*/
#include        "string.h"              /* NEW_STRING, CSTR_STRING         */

#include        "code.h"                /* used by 'stats.h'               */
#include        "vars.h"                /* SWITCH_TO_NEW_LVARS, SWITCH_T...*/

#include        "stats.h"               /* PrintStat                       */

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*T  ObjFunc . . . . . . . . . . . . . . . . type of function returning object
**
**  'ObjFunc' is the type of a function returning an object.
**
**  'ObjFunc' is defined in the declaration part of this package as follows
**
typedef Obj (* ObjFunc) ();
*/


/****************************************************************************
**
*F  HDLR_FUNC( <func>, <i> )  . . . . . . . <i>-th call handler of a function
*F  NAME_FUNC( <func> ) . . . . . . . . . . . . . . . . .  name of a function
*F  NARG_FUNC( <func> ) . . . . . . . . . . number of arguments of a function
*F  NAMS_FUNC( <func> ) . . . . . . .  names of local variables of a function
*F  NAMI_FUNC( <func> ) . . . . . name of <i>-th local variable of a function
*F  PROF_FUNC( <func> ) . . . . . . . profiling information bag of a function
*F  NLOC_FUNC( <func> ) . . . . . . . . . . .  number of locals of a function
*F  BODY_FUNC( <func> ) . . . . . . . . . . . . . . . . .  body of a function
*F  ENVI_FUNC( <func> ) . . . . . . . . . . . . . . environment of a function
*F  FEXS_FUNC( <func> ) . . . . . . . . . . .  func. expr. list of a function
*V  SIZE_FUNC . . . . . . . . . . . . . . . . . size of the bag of a function
**
**  These macros  make it possible  to access  the  various components  of  a
**  function.
**
**  'HDLR_FUNC(<func>,<i>)' is the <i>-th handler of the function <func>.
**
**  'NAME_FUNC(<func>)' is the name of the function.
**
**  'NARG_FUNC(<func>)' is the number of arguments (-1  if  <func>  accepts a
**  variable number of arguments).
**
**  'NAMS_FUNC(<func>)'  is the list of the names of the local variables,
**
**  'NAMI_FUNC(<func>,<i>)' is the name of the <i>-th local variable.
**
**  'PROF_FUNC(<func>)' is the profiling information bag.
**
**  'NLOC_FUNC(<func>)' is the number of local variables of  the  interpreted
**  function <func>.
**
**  'BODY_FUNC(<func>)' is the body.
**
**  'ENVI_FUNC(<func>)'  is the  environment  (i.e., the local  variables bag
**  that was current when <func> was created).
**
**  'FEXS_FUNC(<func>)'  is the function expressions list (i.e., the list of
**  the function expressions of the functions defined inside of <func>).
**
**  'HDLR_FUNC',
**  'NAME_FUNC', 'NARG_FUNC', 'NAMS_FUNC', 'NAMI_FUNC', 'PROF_FUNC',
**  'NLOC_FUNC', 'BODY_FUNC', 'ENVI_FUNC', 'FEXS_FUNC', and 'SIZE_FUNC'
**  are defined in the declaration part of this package as follows
**
#define HDLR_FUNC(func,i)     (* (ObjFunc*) (ADDR_OBJ(func) + 0 +(i)) )
#define NAME_FUNC(func)       (*            (ADDR_OBJ(func) + 8     ) )
#define NARG_FUNC(func)       (* (Int*)     (ADDR_OBJ(func) + 9     ) )
#define NAMS_FUNC(func)       (*            (ADDR_OBJ(func) +10     ) )
#define NAMI_FUNC(func,i)     ((Char*)ADDR_OBJ(ELM_LIST(NAMS_FUNC(func),i)))
#define PROF_FUNC(func)       (*            (ADDR_OBJ(func) +11     ) )
#define NLOC_FUNC(func)       (* (Int*)     (ADDR_OBJ(func) +12     ) )
#define BODY_FUNC(func)       (*            (ADDR_OBJ(func) +13     ) )
#define ENVI_FUNC(func)       (*            (ADDR_OBJ(func) +14     ) )
#define FEXS_FUNC(func)       (*            (ADDR_OBJ(func) +15     ) )
#define SIZE_FUNC             (16*sizeof(Bag))
*/


/****************************************************************************
**

*F  CALL_0ARGS( <func> )  . . . . . . . . .  call a function with 0 arguments
*F  CALL_1ARGS( <func>, <arg1> )  . . . . .  call a function with 1 arguments
*F  CALL_2ARGS( <func>, <arg1>, ... ) . . .  call a function with 2 arguments
*F  CALL_3ARGS( <func>, <arg1>, ...)  . . .  call a function with 3 arguments
*F  CALL_4ARGS( <func>, <arg1>, ...)  . . .  call a function with 4 arguments
*F  CALL_5ARGS( <func>, <arg1>, ...)  . . .  call a function with 5 arguments
*F  CALL_6ARGS( <func>, <arg1>, ...)  . . .  call a function with 6 arguments
*F  CALL_XARGS( <func>, <args> )  . . . . .  call a function with X arguments
**
**  'CALL_<i>ARGS' passes control  to  the function  <func>, which must  be a
**  function object  ('T_FUNCTION').  It returns the  return value of <func>.
**  'CALL_0ARGS' is for calls passing   no arguments, 'CALL_1ARGS' for  calls
**  passing one argument, and so on.   'CALL_XARGS' is for calls passing more
**  than 6 arguments, where the arguments must be collected  in a plain list,
**  and this plain list must then be passed.
**
**  'CALL_<i>ARGS' can be used independently  of whether the called  function
**  is a compiled   or interpreted function.    It checks that the number  of
**  passed arguments is the same  as the number of  arguments expected by the
**  callee,  or it collects the  arguments in a list  if  the callee allows a
**  variable number of arguments.
**
**  'CALL_<i>ARGS'  are defined  in the declaration  part  of this package as
**  follows
**
#define CALL_0ARGS(f)                     HDLR_FUNC(f,0)(f)
#define CALL_1ARGS(f,a1)                  HDLR_FUNC(f,1)(f,a1)
#define CALL_2ARGS(f,a1,a2)               HDLR_FUNC(f,2)(f,a1,a2)
#define CALL_3ARGS(f,a1,a2,a3)            HDLR_FUNC(f,3)(f,a1,a2,a3)
#define CALL_4ARGS(f,a1,a2,a3,a4)         HDLR_FUNC(f,4)(f,a1,a2,a3,a4)
#define CALL_5ARGS(f,a1,a2,a3,a4,a5)      HDLR_FUNC(f,5)(f,a1,a2,a3,a4,a5)
#define CALL_6ARGS(f,a1,a2,a3,a4,a5,a6)   HDLR_FUNC(f,6)(f,a1,a2,a3,a4,a5,a6)
#define CALL_XARGS(f,as)                  HDLR_FUNC(f,7)(f,as)
*/


/****************************************************************************
**

*F  CALL_0ARGS_PROF( <func>, <arg1> ) . . . . .  call a prof func with 0 args
*F  CALL_1ARGS_PROF( <func>, <arg1>, ... )  . .  call a prof func with 1 args
*F  CALL_2ARGS_PROF( <func>, <arg1>, ... )  . .  call a prof func with 2 args
*F  CALL_3ARGS_PROF( <func>, <arg1>, ... )  . .  call a prof func with 3 args
*F  CALL_4ARGS_PROF( <func>, <arg1>, ... )  . .  call a prof func with 4 args
*F  CALL_5ARGS_PROF( <func>, <arg1>, ... )  . .  call a prof func with 5 args
*F  CALL_6ARGS_PROF( <func>, <arg1>, ... )  . .  call a prof func with 6 args
*F  CALL_XARGS_PROF( <func>, <arg1>, ... )  . .  call a prof func with X args
**
**  'CALL_<i>ARGS_PROF' is used   in the profile  handler 'DoProf<i>args'  to
**  call  the  real  handler  stored  in the   profiling  information of  the
**  function.
*/
#define CALL_0ARGS_PROF(f) \
        HDLR_FUNC(PROF_FUNC(f),0)(f)

#define CALL_1ARGS_PROF(f,a1) \
        HDLR_FUNC(PROF_FUNC(f),1)(f,a1)

#define CALL_2ARGS_PROF(f,a1,a2) \
        HDLR_FUNC(PROF_FUNC(f),2)(f,a1,a2)

#define CALL_3ARGS_PROF(f,a1,a2,a3) \
        HDLR_FUNC(PROF_FUNC(f),3)(f,a1,a2,a3)

#define CALL_4ARGS_PROF(f,a1,a2,a3,a4) \
        HDLR_FUNC(PROF_FUNC(f),4)(f,a1,a2,a3,a4)

#define CALL_5ARGS_PROF(f,a1,a2,a3,a4,a5) \
        HDLR_FUNC(PROF_FUNC(f),5)(f,a1,a2,a3,a4,a5)

#define CALL_6ARGS_PROF(f,a1,a2,a3,a4,a5,a6) \
        HDLR_FUNC(PROF_FUNC(f),6)(f,a1,a2,a3,a4,a5,a6)

#define CALL_XARGS_PROF(f,as) \
        HDLR_FUNC(PROF_FUNC(f),7)(f,as)


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

*F  DoFail0args( <self> )  . . . . . .  fail a function call with 0 arguments
**
**  'DoWrap<i>args' accepts the <i> arguments <arg1>, <arg2>,  and so on, and
**  signals an error,  because  the  function for  which  they  are installed
**  expects another number of arguments.  'DoFail<i>args' are the handlers in
**  the other slots of a function.
*/
extern  Obj CallFuncListHandler (
            Obj                 self,
            Obj                 func,
            Obj                 args );

Obj DoFail0args (
    Obj                 self )
{
    Obj                 argx;           /* arguments list (to continue)    */
    argx = ErrorReturnObj(
        "Function: number of arguments must be %d (not %d)",
        NARG_FUNC( self ), 0L,
        "you can return a list of arguments" );
    return CallFuncListHandler( (Obj)0, self, argx );
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
    argx = ErrorReturnObj(
        "Function: number of arguments must be %d (not %d)",
        NARG_FUNC( self ), 1L,
        "you can return a list of arguments" );
    return CallFuncListHandler( (Obj)0, self, argx );
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
    argx = ErrorReturnObj(
        "Function: number of arguments must be %d (not %d)",
        NARG_FUNC( self ), 2L,
        "you can return a list of arguments" );
    return CallFuncListHandler( (Obj)0, self, argx );
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
    argx = ErrorReturnObj(
        "Function: number of arguments must be %d (not %d)",
        NARG_FUNC( self ), 3L,
        "you can return a list of arguments" );
    return CallFuncListHandler( (Obj)0, self, argx );
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
    argx = ErrorReturnObj(
        "Function: number of arguments must be %d (not %d)",
        NARG_FUNC( self ), 4L,
        "you can return a list of arguments" );
    return CallFuncListHandler( (Obj)0, self, argx );
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
    argx = ErrorReturnObj(
        "Function: number of arguments must be %d (not %d)",
        NARG_FUNC( self ), 5L,
        "you can return a list of arguments" );
    return CallFuncListHandler( (Obj)0, self, argx );
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
    argx = ErrorReturnObj(
        "Function: number of arguments must be %d (not %d)",
        NARG_FUNC( self ), 6L,
        "you can return a list of arguments" );
    return CallFuncListHandler( (Obj)0, self, argx );
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
    argx = ErrorReturnObj(
        "Function: number of arguments must be %d (not %d)",
        NARG_FUNC( self ), LEN_LIST( args ),
        "you can return a list of arguments" );
    return CallFuncListHandler( (Obj)0, self, argx );
}


/****************************************************************************
**

*V  TimeDone  . . . . . .   amount of time spent for completed function calls
*V  StorDone  . . . . .  amount of storage spent for completed function calls
**
**  'TimeDone' is  the amount of time spent  for all function calls that have
**  already been completed.
**
**  'StorDone' is the amount of storage spent for all function call that have
**  already been completed.
*/
UInt            TimeDone;
UInt            StorDone;


/****************************************************************************
**
*F  COUNT_PROF( <prof> )  . . . . . . . . number of invocations of a function
*F  TIME_WITH_PROF( <prof> )  . . . . . . time with    children in a function
*F  TIME_WOUT_PROF( <prof> )  . . . . . . time without children in a function
*F  STOR_WITH_PROF( <prof> )  . . . .  storage with    children in a function
*F  STOR_WOUT_PROF( <prof> )  . . . .  storage without children in a function
*V  LEN_PROF  . . . . . . . . . . .  length of a profiling bag for a function
**
**  With each  function we associate two  time measurements.  First the *time
**  spent by this  function without its  children*, i.e., the amount  of time
**  during which this  function was active.   Second the *time  spent by this
**  function with its  children*, i.e., the amount  of time during which this
**  function was either active or suspended.
**
**  Likewise with each  function  we associate the two  storage measurements,
**  the storage spent by  this function without its  children and the storage
**  spent by this function with its children.
**
**  These  macros  make it possible to  access   the various components  of a
**  profiling information bag <prof> for a function <func>.
**
**  'COUNT_PROF(<prof>)' is the  number  of  calls  to the  function  <func>.
**  'TIME_WITH_PROF(<prof>) is  the time spent  while the function <func> was
**  either  active or suspended.   'TIME_WOUT_PROF(<prof>)' is the time spent
**  while the function <func>   was active.  'STOR_WITH_PROF(<prof>)'  is the
**  amount of  storage  allocated while  the  function  <func>  was active or
**  suspended.  'STOR_WOUT_PROF(<prof>)' is  the amount  of storage allocated
**  while the  function <func> was   active.  'LEN_PROF' is   the length of a
**  profiling information bag.
**
#define COUNT_PROF(prof)            (INT_INTOBJ(ELM_PLIST(prof,1)))
#define TIME_WITH_PROF(prof)        (INT_INTOBJ(ELM_PLIST(prof,2)))
#define TIME_WOUT_PROF(prof)        (INT_INTOBJ(ELM_PLIST(prof,3)))
#define STOR_WITH_PROF(prof)        (INT_INTOBJ(ELM_PLIST(prof,4)))
#define STOR_WOUT_PROF(prof)        (INT_INTOBJ(ELM_PLIST(prof,5)))

#define SET_COUNT_PROF(prof,n)      (SET_ELM_PLIST(prof,1,INTOBJ_INT(n)))
#define SET_TIME_WITH_PROF(prof,n)  (SET_ELM_PLIST(prof,2,INTOBJ_INT(n)))
#define SET_TIME_WOUT_PROF(prof,n)  (SET_ELM_PLIST(prof,3,INTOBJ_INT(n)))
#define SET_STOR_WITH_PROF(prof,n)  (SET_ELM_PLIST(prof,4,INTOBJ_INT(n)))
#define SET_STOR_WOUT_PROF(prof,n)  (SET_ELM_PLIST(prof,5,INTOBJ_INT(n)))

#define LEN_PROF                    5
*/


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
  ObjFunc hdlr;
  Char *cookie;
} TNumHandlerInfo;

static TNumHandlerInfo HandlerFuncs[MAX_HANDLERS];
static UInt NHandlerFuncs = 0;
 

void InitHandlerFunc (
     ObjFunc hdlr,
     Char *cookie)
{
  if (NHandlerFuncs >= MAX_HANDLERS)
    {
      Pr("No room left for function handler\n",0L,0L);
      SyExit(1);
    }
   HandlerFuncs[NHandlerFuncs].hdlr = hdlr;
   HandlerFuncs[NHandlerFuncs].cookie = cookie;
   NHandlerFuncs++;
}



static void CheckHandlersBag(
      Bag bag )
{
#ifdef DEBUG_HANDLER_REGISTRATION
  UInt i,j;
  ObjFunc hdlr;
  if (TNUM_BAG(bag) == T_FUNCTION)
  {
    for (j = 0; j < 8; j++)
      {
        hdlr = HDLR_FUNC(bag,j);
	/* zero handlers are used in a few odd places */
	if (hdlr != 0)
	  {
	    for (i = 0; i < NHandlerFuncs; i++)
	      {
		if (hdlr == HandlerFuncs[i].hdlr)
		  break;
	      }
	    if (i == NHandlerFuncs)
	      {
		Pr("Unregistered Handler %d args  ", j, 0L);
		PrintObj(NAME_FUNC(bag));
		Pr("\n",0L,0L);
	      }
	  }
      }
  }
#endif
  return;
}

void CheckAllHandlers(
       void )
{
  CallbackForAllBags( CheckHandlersBag);
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
    Char *              name,
    Int                 narg,
    Char *              nams,
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
    if ( narg != -1 ) {
        HDLR_FUNC(func,0) = DoFail0args;
        HDLR_FUNC(func,1) = DoFail1args;
        HDLR_FUNC(func,2) = DoFail2args;
        HDLR_FUNC(func,3) = DoFail3args;
        HDLR_FUNC(func,4) = DoFail4args;
        HDLR_FUNC(func,5) = DoFail5args;
        HDLR_FUNC(func,6) = DoFail6args;
        HDLR_FUNC(func,7) = DoFailXargs;
        HDLR_FUNC( func, (narg <= 6 ? narg : 7) ) = hdlr;
    }

    /* create a function with a variable number of arguments               */
    else {
        HDLR_FUNC(func,0) = DoWrap0args;
        HDLR_FUNC(func,1) = DoWrap1args;
        HDLR_FUNC(func,2) = DoWrap2args;
        HDLR_FUNC(func,3) = DoWrap3args;
        HDLR_FUNC(func,4) = DoWrap4args;
        HDLR_FUNC(func,5) = DoWrap5args;
        HDLR_FUNC(func,6) = DoWrap6args;
        HDLR_FUNC(func,7) = hdlr;
    }

    /* enter the the arguments and the names                               */
    NAME_FUNC(func) = name;
    NARG_FUNC(func) = narg;
    NAMS_FUNC(func) = nams;
    CHANGED_BAG(func);

    /* enter the profiling bag                                             */
    prof = NEW_PLIST( T_PLIST, LEN_PROF );
    SET_LEN_PLIST( prof, LEN_PROF );
    SET_COUNT_PROF( prof, 0 );
    SET_TIME_WITH_PROF( prof, 0 );
    SET_TIME_WOUT_PROF( prof, 0 );
    SET_STOR_WITH_PROF( prof, 0 );
    SET_STOR_WOUT_PROF( prof, 0 );
    PROF_FUNC(func) = prof;
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
    Char *              name_c,
    Int                 narg,
    Char *              nams_c,
    ObjFunc             hdlr )
{
    Obj                 name_o;         /* name as an object               */
    Obj                 nams_o;         /* nams as an object               */
    Int                 len;            /* length                          */
    Int                 i, k, l;        /* loop variables                  */


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
        while ( nams_c[l]!=' ' && nams_c[l]!=',' && nams_c[l]!='\0' ) {
            l++;
        }
        name_o = NEW_STRING( l-k );
        SyStrncat( CSTR_STRING(name_o), nams_c+k, l-k );
        SET_ELM_PLIST( nams_o, i, name_o );
        k = l;
    }

    /* convert the name to an object                                       */
    len = SyStrlen( name_c );
    name_o = NEW_STRING(len);
    SyStrncat( CSTR_STRING(name_o), name_c, len );

    /* make the function                                                   */
    return NewFunctionT( type, size, name_o, narg, nams_o, hdlr );
}
    

/****************************************************************************
**
*F  TypeFunction( <func> )  . . . . . . . . . . . . . . .  kind of a function
**
**  'TypeFunction' returns the kind of the function <func>.
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
**  'PrintFunction' prints  the   function  <func> in  abbreviated  form   if
**  'PrintObjFull' is false.
*/
void PrintFunction (
    Obj                 func )
{
    Int                 narg;           /* number of arguments             */
    Int                 nloc;           /* number of locals                */
    Obj                 oldLVars;       /* terrible hack                   */
    UInt                i;              /* loop variable                   */

    /* complete the function if necessary                                  */
    if ( IS_UNCOMPLETED_FUNC(func) ) {
	COMPLETE_FUNC(func);
    }

    /* print 'function ('                                                  */
    Pr("%5>function%< ( %>",0L,0L);

    /* print the arguments                                                 */
    narg = (NARG_FUNC(func) == -1 ? 1 : NARG_FUNC(func));
    for ( i = 1; i <= narg; i++ ) {
        if ( NAMS_FUNC(func) != 0 )
            Pr( "%I", (Int)NAMI_FUNC( func, i ), 0L );
        else
            Pr( "<<arg-%d>>", i, 0L );
        if ( i != narg )  Pr("%<, %>",0L,0L);
    }
    Pr(" %<)",0L,0L);

    /* print the function in the short form                                */
    if ( PrintObjFull == 0 ) {
        Pr(" ...%4< ",0L,0L);
    }

    /* print the function in the long form                                 */
    else {
        Pr("\n",0L,0L);

        /* print the locals                                                */
        nloc = NLOC_FUNC(func);
        if ( nloc >= 1 ) {
            Pr("%>local  ",0L,0L);
            for ( i = 1; i <= nloc; i++ ) {
                if ( NAMS_FUNC(func) != 0 )
                    Pr( "%I", (Int)NAMI_FUNC( func, narg + i ), 0L );
                else
                    Pr( "<<loc-%d>>", i, 0L );
                if ( i != nloc )  Pr("%<, %>",0L,0L);
            }
            Pr("%<;\n",0L,0L);
	}

        /* print the body                                                  */
 	if ( IS_UNCOMPLETED_FUNC(func) )  {
	    Pr( "<<uncompletable function>>", 0L, 0L );
	}
        else if ( BODY_FUNC(func) == 0 || SIZE_OBJ(BODY_FUNC(func)) == 0 ) {
            Pr("<<compiled code>>",0L,0L);
        }
        else {
            SWITCH_TO_NEW_LVARS( func, NARG_FUNC(func), NLOC_FUNC(func),
                                 oldLVars );
            PrintStat( FIRST_STAT_CURR_FUNC );
            SWITCH_TO_OLD_LVARS( oldLVars );
        }
        Pr("%4<\n",0L,0L);

    }

    /* print 'end'                                                         */
    Pr("end",0L,0L);
}


/****************************************************************************
**
*F  IsFunctionHandler( <self>, <func> ) . . . . . . . . . . test for function
**
**  'IsFunctionHandler' implements the internal function 'IsFunction'.
**
**  'IsFunction( <func> )'
**
**  'IsFunction' returns   'true'  if  <func>   is a function    and  'false'
**  otherwise.
*/
Obj IsFunctionFilt;

Obj IsFunctionHandler (
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
*F  CallFunctionHandler( <self>, <args> ) . . . . . . . . . . call a function
**
**  'CallFunctionHandler' implements the internal function 'CallFunction'.
**
**  'CallFunction( <func>, <arg1>... )'
**
**  'CallFunction' calls the  function <func> with the  arguments  <arg1>...,
**  i.e., it is equivalent to '<func>( <arg1>, <arg2>... )'.
*/
Obj CallFunctionOper;

Obj CallFunctionHandler (
    Obj                 self,
    Obj                 args )
{
    Obj                 result;         /* result                          */
    Obj                 func;           /* function                        */
    Obj                 list2;          /* list of arguments               */
    Obj                 arg;            /* one argument                    */
    UInt                i;              /* loop variable                   */

    /* the first argument is the function                                  */
    if ( LEN_LIST( args ) == 0 ) {
        func = ErrorReturnObj(
            "usage: CallFunction( <func>, <arg1>... )",
            0L, 0L,
            "you can return a function for <func>" );
    }
    else {
        func = ELMV_LIST( args, 1 );
    }    

    /* check that the first argument is a function                         */
    /*N 1996/06/26 mschoene this should be done by 'CALL_<i>ARGS'          */
    while ( TNUM_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "CallFunction: <func> must be a function",
            0L, 0L,
            "you can return a function for <func>" );
    }

    /* call the function                                                   */
    if      ( LEN_LIST(args) == 1 ) {
        result = CALL_0ARGS( func );
    }
    else if ( LEN_LIST(args) == 2 ) {
        result = CALL_1ARGS( func, ELMV_LIST(args,2) );
    }
    else if ( LEN_LIST(args) == 3 ) {
        result = CALL_2ARGS( func, ELMV_LIST(args,2), ELMV_LIST(args,3) );
    }
    else if ( LEN_LIST(args) == 4 ) {
        result = CALL_3ARGS( func, ELMV_LIST(args,2), ELMV_LIST(args,3),
                                   ELMV_LIST(args,4) );
    }
    else if ( LEN_LIST(args) == 5 ) {
        result = CALL_4ARGS( func, ELMV_LIST(args,2), ELMV_LIST(args,3),
                                   ELMV_LIST(args,4), ELMV_LIST(args,5) );
    }
    else if ( LEN_LIST(args) == 6 ) {
        result = CALL_5ARGS( func, ELMV_LIST(args,2), ELMV_LIST(args,3),
                                   ELMV_LIST(args,4), ELMV_LIST(args,5),
                                   ELMV_LIST(args,6) );
    }
    else if ( LEN_LIST(args) == 7 ) {
        result = CALL_6ARGS( func, ELMV_LIST(args,2), ELMV_LIST(args,3),
                                   ELMV_LIST(args,4), ELMV_LIST(args,5),
                                   ELMV_LIST(args,6), ELMV_LIST(args,7) );
    }
    else {
        list2 = NEW_PLIST( T_PLIST, LEN_LIST(args)-1 );
        SET_LEN_PLIST( list2, LEN_LIST(args)-1 );
        for ( i = 1; i <= LEN_LIST(args)-1; i++ ) {
            arg = ELMV_LIST( args, i+1 );
            SET_ELM_PLIST( list2, i, arg );
        }
        result = CALL_XARGS( func, list2 );
    }

    /* return the result                                                   */
    return result;
}


/****************************************************************************
**
*F  CallFuncListHandler( <self>, <func>, <list> ) . . . . . . call a function
**
**  'CallFuncListHandler' implements the internal function 'CallFuncList'.
**
**  'CallFuncList( <func>, <list> )'
**
**  'CallFuncList' calls the  function <func> with the arguments list <list>,
**  i.e., it is equivalent to '<func>( <list>[1], <list>[2]... )'.
*/
Obj CallFuncListOper;

Obj CallFuncListHandler (
    Obj                 self,
    Obj                 func,
    Obj                 list )
{
    Obj                 result;         /* result                          */
    Obj                 list2;          /* list of arguments               */
    Obj                 arg;            /* one argument                    */
    UInt                i;              /* loop variable                   */

    /* check that the second argument is a list                            */
    while ( ! IS_LIST( list ) ) {
        list = ErrorReturnObj(
            "CallFuncList: <list> must be a list",
            0L, 0L,
            "you can return a list for <list>" );
    }

    /* check that the first argument is a function                         */
    /*N 1996/06/26 mschoene this should be done by 'CALL_<i>ARGS'          */
    while ( TNUM_OBJ( func ) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "CallFuncList: <func> must be a function",
            0L, 0L,
            "you can return a function for <func>" );
    }

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
            arg = ELMV_LIST( list, i );
            SET_ELM_PLIST( list2, i, arg );
        }
        result = CALL_XARGS( func, list2 );
    }

    /* return the result                                                   */
    return result;
}


/****************************************************************************
**

*F  FuncNAME_FUNC( <self>, <func> ) . . . . . . . . . . .  name of a function
*/
Obj NAME_FUNC_Oper;

Obj FuncNAME_FUNC (
    Obj                 self,
    Obj                 func )
{
    Obj                 name;
    char *              deflt = "unknown";

    if ( TNUM_OBJ(func) == T_FUNCTION ) {
        name = NAME_FUNC(func);
        if ( name == 0 ) {
            name = NEW_STRING(SyStrlen(deflt));
            SyStrncat( CSTR_STRING(name), deflt, SyStrlen(deflt) );
	    RetypeBag( name, IMMUTABLE_TNUM(TNUM_OBJ(name)) );
            NAME_FUNC(func) = name;

        }
        return name;
    }
    else {
        return DoOperation1Args( self, func );
    }
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
        if ( IS_UNCOMPLETED_FUNC(func) )  {
	    COMPLETE_FUNC(func);
	    if ( IS_UNCOMPLETED_FUNC(func) ) {
		ErrorQuit( "<func> did not complete", 0L, 0L );
		return 0;
	    }
	}
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
    if ( TNUM_OBJ(func) == T_FUNCTION ) {
        if ( IS_UNCOMPLETED_FUNC(func) )  {
	    COMPLETE_FUNC(func);
	    if ( IS_UNCOMPLETED_FUNC(func) ) {
		ErrorQuit( "<func> did not complete", 0L, 0L );
		return 0;
	    }
	}
        return NAMS_FUNC(func);
    }
    else {
        return DoOperation1Args( self, func );
    }
}


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
    if ( IS_UNCOMPLETED_FUNC(func) ) {
	COMPLETE_FUNC(func);
	if ( IS_UNCOMPLETED_FUNC(func) ) {
	    ErrorQuit( "<func> did not complete", 0L, 0L );
	    return 0;
	}
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
    if ( IS_UNCOMPLETED_FUNC(func) ) {
	COMPLETE_FUNC(func);
	if ( IS_UNCOMPLETED_FUNC(func) ) {
	    ErrorQuit( "<func> did not complete", 0L, 0L );
	    return 0;
	}
    }

    /* uninstall trace handler                                             */
    ChangeDoOperations( func, 0 );

    /* install profiling                                                   */
    prof = PROF_FUNC(func);
    
    /* install new handlers                                                */
    if ( TNUM_OBJ(prof) != T_FUNCTION ) {
        copy = NewBag( TNUM_OBJ(func), SIZE_OBJ(func) );
        HDLR_FUNC(copy,0) = HDLR_FUNC(func,0);
        HDLR_FUNC(copy,1) = HDLR_FUNC(func,1);
        HDLR_FUNC(copy,2) = HDLR_FUNC(func,2);
        HDLR_FUNC(copy,3) = HDLR_FUNC(func,3);
        HDLR_FUNC(copy,4) = HDLR_FUNC(func,4);
        HDLR_FUNC(copy,5) = HDLR_FUNC(func,5);
        HDLR_FUNC(copy,6) = HDLR_FUNC(func,6);
        HDLR_FUNC(copy,7) = HDLR_FUNC(func,7);
        NAME_FUNC(copy)   = NAME_FUNC(func);
        NARG_FUNC(copy)   = NARG_FUNC(func);
        NAMS_FUNC(copy)   = NAMS_FUNC(func);
        PROF_FUNC(copy)   = PROF_FUNC(func);
        HDLR_FUNC(func,0) = DoProf0args;
        HDLR_FUNC(func,1) = DoProf1args;
        HDLR_FUNC(func,2) = DoProf2args;
        HDLR_FUNC(func,3) = DoProf3args;
        HDLR_FUNC(func,4) = DoProf4args;
        HDLR_FUNC(func,5) = DoProf5args;
        HDLR_FUNC(func,6) = DoProf6args;
        HDLR_FUNC(func,7) = DoProfXargs;
        PROF_FUNC(func)   = copy;
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
    if ( IS_UNCOMPLETED_FUNC(func) ) {
	COMPLETE_FUNC(func);
	if ( IS_UNCOMPLETED_FUNC(func) ) {
	    ErrorQuit( "<func> did not complete", 0L, 0L );
	    return 0;
	}
    }
    return ( TNUM_OBJ(PROF_FUNC(func)) != T_FUNCTION ) ? False : True;
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
    if ( IS_UNCOMPLETED_FUNC(func) ) {
	COMPLETE_FUNC(func);
	if ( IS_UNCOMPLETED_FUNC(func) ) {
	    ErrorQuit( "<func> did not complete", 0L, 0L );
	    return 0;
	}
    }

    /* uninstall trace handler                                             */
    ChangeDoOperations( func, 0 );

    /* profiling is active, restore handlers                               */
    prof = PROF_FUNC(func);
    if ( TNUM_OBJ(prof) == T_FUNCTION ) {
        HDLR_FUNC(func,0) = HDLR_FUNC(prof,0);
        HDLR_FUNC(func,1) = HDLR_FUNC(prof,1);
        HDLR_FUNC(func,2) = HDLR_FUNC(prof,2);
        HDLR_FUNC(func,3) = HDLR_FUNC(prof,3);
        HDLR_FUNC(func,4) = HDLR_FUNC(prof,4);
        HDLR_FUNC(func,5) = HDLR_FUNC(prof,5);
        HDLR_FUNC(func,6) = HDLR_FUNC(prof,6);
        HDLR_FUNC(func,7) = HDLR_FUNC(prof,7);
        PROF_FUNC(func)   = PROF_FUNC(prof);
        CHANGED_BAG(func);
    }

    return (Obj)0;
}


/****************************************************************************
**

*F  InitCalls() . . . . . . . . . . . . . . . . . initialize the call package
**
**  'InitCalls' initializes the call package.
*/
void            InitCalls ()
{
    /* install the marking functions                                       */
    InfoBags[         T_FUNCTION ].name = "function";
    InitMarkFuncBags( T_FUNCTION , MarkAllSubBags );

    /* install the kind function                                           */
    ImportGVarFromLibrary( "TYPE_FUNCTION",  &TYPE_FUNCTION  );
    ImportGVarFromLibrary( "TYPE_OPERATION", &TYPE_OPERATION );
    TypeObjFuncs[ T_FUNCTION ] = TypeFunction;

    /* install the printer                                                 */
    PrintObjFuncs[    T_FUNCTION ] = PrintFunction;

    /* make and install the 'IS_FUNCTION' filter                           */
    InitHandlerFunc( IsFunctionHandler, "IS_FUNCTION" );
    IsFunctionFilt = NewFilterC( "IS_FUNCTION", 1L, "obj",
                                  IsFunctionHandler );
    AssGVar( GVarName( "IS_FUNCTION" ), IsFunctionFilt );

    /* make and install the 'CALL_FUNC' operation                          */
    InitHandlerFunc( CallFunctionHandler, "CALL_FUNC" );
    CallFunctionOper = NewOperationC( "CALL_FUNC", -1L, "args",
                                       CallFunctionHandler );
    AssGVar( GVarName( "CALL_FUNC" ), CallFunctionOper );

    /* make and install the 'CALL_FUNC_LIST' operation                     */
    InitHandlerFunc( CallFuncListHandler, "CALL_FUNC_LIST" );
    CallFuncListOper = NewOperationC( "CALL_FUNC_LIST", 2L, "func, list",
                                       CallFuncListHandler );
    AssGVar( GVarName( "CALL_FUNC_LIST" ), CallFuncListOper );


    /* make and install the 'NAME_FUNC' etc. operations                    */
    InitHandlerFunc( FuncNAME_FUNC, "NAME_FUNC" );
    NAME_FUNC_Oper = NewOperationC( "NAME_FUNC", 1L, "func",
                                     FuncNAME_FUNC );
    AssGVar( GVarName( "NAME_FUNC" ), NAME_FUNC_Oper );

    InitHandlerFunc( FuncNARG_FUNC, "NARG_FUNC" );
    NARG_FUNC_Oper = NewOperationC( "NARG_FUNC", 1L, "func",
                                     FuncNARG_FUNC );
    AssGVar( GVarName( "NARG_FUNC" ), NARG_FUNC_Oper );

    InitHandlerFunc( FuncNAMS_FUNC, "NAMS_FUNC" );
    NAMS_FUNC_Oper = NewOperationC( "NAMS_FUNC", 1L, "func",
                                     FuncNAMS_FUNC );
    AssGVar( GVarName( "NAMS_FUNC" ), NAMS_FUNC_Oper );

    InitHandlerFunc( FuncPROF_FUNC, "PROF_FUNC" );
    PROF_FUNC_Oper = NewOperationC( "PROF_FUNC", 1L, "func",
                                     FuncPROF_FUNC );
    AssGVar( GVarName( "PROF_FUNC" ), PROF_FUNC_Oper );


    /* make and install the profile functions                              */
    InitHandlerFunc( FuncCLEAR_PROFILE_FUNC, "Clear Profile");
    AssGVar( GVarName( "CLEAR_PROFILE_FUNC" ),
         NewFunctionC( "CLEAR_PROFILE_FUNC", 1L, "function",
                    FuncCLEAR_PROFILE_FUNC ) );

    InitHandlerFunc( FuncIS_PROFILED_FUNC, "Is Profiled");
    AssGVar( GVarName( "IS_PROFILED_FUNC" ),
         NewFunctionC( "IS_PROFILED_FUNC", 1L, "function",
                    FuncIS_PROFILED_FUNC ) );

    InitHandlerFunc( FuncPROFILE_FUNC, "Profile function");
    AssGVar( GVarName( "PROFILE_FUNC" ),
         NewFunctionC( "PROFILE_FUNC", 1L, "function",
                    FuncPROFILE_FUNC ) );

    InitHandlerFunc( FuncUNPROFILE_FUNC, "Unprofile function");
    AssGVar( GVarName( "UNPROFILE_FUNC" ),
         NewFunctionC( "UNPROFILE_FUNC", 1L, "function",
                    FuncUNPROFILE_FUNC ) );


    InitHandlerFunc( DoFail0args, "0 arg fail");
    InitHandlerFunc( DoFail1args, "1 arg fail");
    InitHandlerFunc( DoFail2args, "2 arg fail");
    InitHandlerFunc( DoFail3args, "3 arg fail");
    InitHandlerFunc( DoFail4args, "4 arg fail");
    InitHandlerFunc( DoFail5args, "5 arg fail");
    InitHandlerFunc( DoFail6args, "6 arg fail");
    InitHandlerFunc( DoFailXargs, "X arg fail");

    InitHandlerFunc( DoWrap0args, "0 arg wrap");
    InitHandlerFunc( DoWrap1args, "1 arg wrap");
    InitHandlerFunc( DoWrap2args, "2 arg wrap");
    InitHandlerFunc( DoWrap3args, "3 arg wrap");
    InitHandlerFunc( DoWrap4args, "4 arg wrap");
    InitHandlerFunc( DoWrap5args, "5 arg wrap");
    InitHandlerFunc( DoWrap6args, "6 arg wrap");

    InitHandlerFunc( DoProf0args, "0 arg profile");
    InitHandlerFunc( DoProf1args, "1 arg profile");
    InitHandlerFunc( DoProf2args, "2 arg profile");
    InitHandlerFunc( DoProf3args, "3 arg profile");
    InitHandlerFunc( DoProf4args, "4 arg profile");
    InitHandlerFunc( DoProf5args, "5 arg profile");
    InitHandlerFunc( DoProf6args, "6 arg profile");
    InitHandlerFunc( DoProfXargs, "X arg profile");
}


/****************************************************************************
**

*E  calls.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
