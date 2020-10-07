/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file  declares the functions of the  generic function call mechanism
**  package.
**
**  This package defines the *call mechanism* through which one GAP function,
**  named the *caller*, can temporarily transfer control to another function,
**  named the *callee*.
**
**  There are *compiled functions* and  *interpreted functions*.  Thus  there
**  are four possible pairings of caller and callee.
**
**  If the caller is compiled,  then the call comes directly from the caller.
**  If it  is interpreted, then   the call comes  from one  of the  functions
**  'EvalFunccall<i>args' that implement evaluation of function calls.
**
**  If the callee is compiled,  then the call goes  directly  to the  callee.
**  If   it is interpreted,   then the  call   goes to one  of  the  handlers
**  'DoExecFunc<i>args' that implement execution of function bodies.
**
**  The call mechanism makes it in any case unnecessary for the calling code
**  to  know  whether the callee  is  a compiled or  an interpreted function.
**  Likewise the called code need not know, actually cannot know, whether the
**  caller is a compiled or an interpreted function.
**
**  Also the call mechanism checks that the number of arguments passed by the
**  caller is the same as the number of arguments  expected by the callee, or
**  it  collects the arguments   in a list  if  the callee allows  a variable
**  number of arguments.
**
**  Finally the call mechanism profiles all functions if requested.
**
**  All this has very little overhead.  In the  case of one compiled function
**  calling  another compiled function, which expects fewer than 4 arguments,
**  with no profiling, the overhead is only a couple of instructions.
*/

#ifndef GAP_CALLS_H
#define GAP_CALLS_H

#include "gaputils.h"
#include "objects.h"


/****************************************************************************
**
*F  HDLR_FUNC(<func>,<i>) . . . . . . . . . <i>-th call handler of a function
*F  NAME_FUNC(<func>) . . . . . . . . . . . . . . . . . .  name of a function
*F  NARG_FUNC(<func>) . . . . . . . . . . . number of arguments of a function
*F  NAMS_FUNC(<func>) . . . . . . . .  names of local variables of a function
*F  NAMI_FUNC(<func>) . . . . . . name of <i>-th local variable of a function
*F  PROF_FUNC(<func>) . . . . . . . . profiling information bag of a function
*F  NLOC_FUNC(<func>) . . . . . . . . . . . .  number of locals of a function
*F  BODY_FUNC(<func>) . . . . . . . . . . . . . . . . . .  body of a function
*F  ENVI_FUNC(<func>) . . . . . . . . . . . . . . . environment of a function
**
**  These functions make it possible to access the various components of a
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
**  'ENVI_FUNC(<func>)'  is the  environment (i.e., the local  variables bag)
**  that was current when <func> was created.
**
**  'LCKS_FUNC(<func>)' is a string that contains the lock mode for the
**  arguments of <func>. Each byte corresponds to the mode for an argument:
**  0 means no lock, 1 means a read-only lock, 2 means a read-write lock.
**  The value of the bag can be null, in which case no argument requires a
**  lock. Only used in HPC-GAP.
*/
typedef struct {
    ObjFunc handlers[8];
    Obj name;
    Obj nargs;
    Obj namesOfArgsAndLocals;
    Obj prof;
    Obj nloc;
    Obj body;
    Obj envi;
#ifdef HPCGAP
    Obj locks;
#endif
    // additional data follows for operations
} FuncBag;

EXPORT_INLINE FuncBag * FUNC(Obj func)
{
    GAP_ASSERT(TNUM_OBJ(func) == T_FUNCTION);
    return (FuncBag *)ADDR_OBJ(func);
}

EXPORT_INLINE const FuncBag * CONST_FUNC(Obj func)
{
    GAP_ASSERT(TNUM_OBJ(func) == T_FUNCTION);
    return (const FuncBag *)CONST_ADDR_OBJ(func);
}


EXPORT_INLINE ObjFunc HDLR_FUNC(Obj func, Int i)
{
    GAP_ASSERT(0 <= i && i < 8);
    return CONST_FUNC(func)->handlers[i];
}

EXPORT_INLINE Obj NAME_FUNC(Obj func)
{
    return CONST_FUNC(func)->name;
}

EXPORT_INLINE Int NARG_FUNC(Obj func)
{
    return INT_INTOBJ(CONST_FUNC(func)->nargs);
}

EXPORT_INLINE Obj NAMS_FUNC(Obj func)
{
    return CONST_FUNC(func)->namesOfArgsAndLocals;
}

Obj NAMI_FUNC(Obj func, Int i);

EXPORT_INLINE Obj PROF_FUNC(Obj func)
{
    return CONST_FUNC(func)->prof;
}

EXPORT_INLINE UInt NLOC_FUNC(Obj func)
{
    return INT_INTOBJ(CONST_FUNC(func)->nloc);
}

EXPORT_INLINE Obj BODY_FUNC(Obj func)
{
    return CONST_FUNC(func)->body;
}

EXPORT_INLINE Obj ENVI_FUNC(Obj func)
{
    return CONST_FUNC(func)->envi;
}

#ifdef HPCGAP
EXPORT_INLINE Obj LCKS_FUNC(Obj func)
{
    return CONST_FUNC(func)->locks;
}

#endif

EXPORT_INLINE void SET_HDLR_FUNC(Obj func, Int i, ObjFunc hdlr)
{
    GAP_ASSERT(0 <= i && i < 8);
    FUNC(func)->handlers[i] = hdlr;
}

void SET_NAME_FUNC(Obj func, Obj name);

EXPORT_INLINE void SET_NARG_FUNC(Obj func, Int nargs)
{
    FUNC(func)->nargs = INTOBJ_INT(nargs);
}

EXPORT_INLINE void SET_NAMS_FUNC(Obj func, Obj namesOfArgsAndLocals)
{
    FUNC(func)->namesOfArgsAndLocals = namesOfArgsAndLocals;
}

EXPORT_INLINE void SET_PROF_FUNC(Obj func, Obj prof)
{
    FUNC(func)->prof = prof;
}

EXPORT_INLINE void SET_NLOC_FUNC(Obj func, UInt nloc)
{
    FUNC(func)->nloc = INTOBJ_INT(nloc);
}

EXPORT_INLINE void SET_BODY_FUNC(Obj func, Obj body)
{
    GAP_ASSERT(TNUM_OBJ(body) == T_BODY);
    FUNC(func)->body = body;
}

EXPORT_INLINE void SET_ENVI_FUNC(Obj func, Obj envi)
{
    FUNC(func)->envi = envi;
}

#ifdef HPCGAP
EXPORT_INLINE void SET_LCKS_FUNC(Obj func, Obj locks)
{
    FUNC(func)->locks = locks;
}
#endif

/****************************************************************************
*
*F  IsKernelFunction( <func> )
**
**  'IsKernelFunction' returns 1 if <func> is a kernel function (i.e.
**  compiled from C code), and 0 otherwise.
*/
BOOL IsKernelFunction(Obj func);


EXPORT_INLINE ObjFunc_0ARGS HDLR_0ARGS(Obj func)
{
    return (ObjFunc_0ARGS)HDLR_FUNC(func, 0);
}

EXPORT_INLINE ObjFunc_1ARGS HDLR_1ARGS(Obj func)
{
    return (ObjFunc_1ARGS)HDLR_FUNC(func, 1);
}

EXPORT_INLINE ObjFunc_2ARGS HDLR_2ARGS(Obj func)
{
    return (ObjFunc_2ARGS)HDLR_FUNC(func, 2);
}

EXPORT_INLINE ObjFunc_3ARGS HDLR_3ARGS(Obj func)
{
    return (ObjFunc_3ARGS)HDLR_FUNC(func, 3);
}

EXPORT_INLINE ObjFunc_4ARGS HDLR_4ARGS(Obj func)
{
    return (ObjFunc_4ARGS)HDLR_FUNC(func, 4);
}

EXPORT_INLINE ObjFunc_5ARGS HDLR_5ARGS(Obj func)
{
    return (ObjFunc_5ARGS)HDLR_FUNC(func, 5);
}

EXPORT_INLINE ObjFunc_6ARGS HDLR_6ARGS(Obj func)
{
    return (ObjFunc_6ARGS)HDLR_FUNC(func, 6);
}

EXPORT_INLINE ObjFunc_1ARGS HDLR_XARGS(Obj func)
{
    return (ObjFunc_1ARGS)HDLR_FUNC(func, 7);
}


/****************************************************************************
**
*F  IS_FUNC( <obj> )  . . . . . . . . . . . . . check if object is a function
*/
EXPORT_INLINE BOOL IS_FUNC(Obj obj)
{
    return TNUM_OBJ(obj) == T_FUNCTION;
}


/****************************************************************************
**
*F  CALL_0ARGS(<func>)  . . . . . . . . . call a function with 0    arguments
*F  CALL_1ARGS(<func>,<arg1>) . . . . . . call a function with 1    arguments
*F  CALL_2ARGS(<func>,<arg1>...)  . . . . call a function with 2    arguments
*F  CALL_3ARGS(<func>,<arg1>...)  . . . . call a function with 3    arguments
*F  CALL_4ARGS(<func>,<arg1>...)  . . . . call a function with 4    arguments
*F  CALL_5ARGS(<func>,<arg1>...)  . . . . call a function with 5    arguments
*F  CALL_6ARGS(<func>,<arg1>...)  . . . . call a function with 6    arguments
*F  CALL_XARGS(<func>,<args>) . . . . . . call a function with more arguments
**
**  'CALL_<i>ARGS' passes control  to  the function  <func>, which must  be a
**  function object  ('T_FUNCTION').  It returns the  return value of <func>.
**  'CALL_0ARGS' is for calls passing   no arguments, 'CALL_1ARGS' for  calls
**  passing one argument, and so on.   'CALL_XARGS' is for calls passing more
**  than 5 arguments, where the arguments must be collected  in a plain list,
**  and this plain list must then be passed.
**
**  'CALL_<i>ARGS' can be used independently  of whether the called  function
**  is a compiled   or interpreted function.    It checks that the number  of
**  passed arguments is the same  as the number of  arguments expected by the
**  callee,  or it collects the  arguments in a list  if  the callee allows a
**  variable number of arguments.
*/
EXPORT_INLINE Obj CALL_0ARGS(Obj f)
{
    return HDLR_0ARGS(f)(f);
}

EXPORT_INLINE Obj CALL_1ARGS(Obj f, Obj a1)
{
    return HDLR_1ARGS(f)(f, a1);
}

EXPORT_INLINE Obj CALL_2ARGS(Obj f, Obj a1, Obj a2)
{
    return HDLR_2ARGS(f)(f, a1, a2);
}

EXPORT_INLINE Obj CALL_3ARGS(Obj f, Obj a1, Obj a2, Obj a3)
{
    return HDLR_3ARGS(f)(f, a1, a2, a3);
}

EXPORT_INLINE Obj CALL_4ARGS(Obj f, Obj a1, Obj a2, Obj a3, Obj a4)
{
    return HDLR_4ARGS(f)(f, a1, a2, a3, a4);
}

EXPORT_INLINE Obj CALL_5ARGS(Obj f, Obj a1, Obj a2, Obj a3, Obj a4, Obj a5)
{
    return HDLR_5ARGS(f)(f, a1, a2, a3, a4, a5);
}

EXPORT_INLINE Obj CALL_6ARGS(Obj f, Obj a1, Obj a2, Obj a3, Obj a4, Obj a5, Obj a6)
{
    return HDLR_6ARGS(f)(f, a1, a2, a3, a4, a5, a6);
}

EXPORT_INLINE Obj CALL_XARGS(Obj f, Obj as)
{
    return HDLR_XARGS(f)(f, as);
}


/****************************************************************************
**
*F  CALL_0ARGS_PROF( <func>, <arg1> ) . . . . .  call a prof func with 0 args
*F  CALL_1ARGS_PROF( <func>, <arg1>, ... )  . .  call a prof func with 1 arg
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
EXPORT_INLINE Obj CALL_0ARGS_PROF(Obj f)
{
    return HDLR_0ARGS(PROF_FUNC(f))(f);
}

EXPORT_INLINE Obj CALL_1ARGS_PROF(Obj f, Obj a1)
{
    return HDLR_1ARGS(PROF_FUNC(f))(f, a1);
}

EXPORT_INLINE Obj CALL_2ARGS_PROF(Obj f, Obj a1, Obj a2)
{
    return HDLR_2ARGS(PROF_FUNC(f))(f, a1, a2);
}

EXPORT_INLINE Obj CALL_3ARGS_PROF(Obj f, Obj a1, Obj a2, Obj a3)
{
    return HDLR_3ARGS(PROF_FUNC(f))(f, a1, a2, a3);
}

EXPORT_INLINE Obj CALL_4ARGS_PROF(Obj f, Obj a1, Obj a2, Obj a3, Obj a4)
{
    return HDLR_4ARGS(PROF_FUNC(f))(f, a1, a2, a3, a4);
}

EXPORT_INLINE Obj CALL_5ARGS_PROF(Obj f, Obj a1, Obj a2, Obj a3, Obj a4, Obj a5)
{
    return HDLR_5ARGS(PROF_FUNC(f))(f, a1, a2, a3, a4, a5);
}

EXPORT_INLINE Obj CALL_6ARGS_PROF(Obj f, Obj a1, Obj a2, Obj a3, Obj a4, Obj a5, Obj a6)
{
    return HDLR_6ARGS(PROF_FUNC(f))(f, a1, a2, a3, a4, a5, a6);
}

EXPORT_INLINE Obj CALL_XARGS_PROF(Obj f, Obj as)
{
    return HDLR_XARGS(PROF_FUNC(f))(f, as);
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

void InitHandlerFunc(ObjFunc hdlr, const Char * cookie);

#ifdef USE_GASMAN

const Char * CookieOfHandler(ObjFunc hdlr);

ObjFunc HandlerOfCookie(const Char * cookie);

void SortHandlers(UInt byWhat);

void CheckAllHandlers(void);

#endif

/****************************************************************************
**
*F  NewFunction( <name>, <narg>, <nams>, <hdlr> )  . . .  make a new function
*F  NewFunctionC( <name>, <narg>, <nams>, <hdlr> ) . . .  make a new function
*F  NewFunctionT( <type>, <size>, <name>, <narg>, <nams>, <hdlr> )
**
**  'NewFunction' creates and returns a new function.  <name> must be  a  GAP
**  string containing the name of the function.  <narg> must be the number of
**  arguments, where -1 means a variable number of arguments.  <nams> must be
**  a GAP list containg the names  of  the  arguments.  <hdlr>  must  be  the
**  C function (accepting <self> and  the  <narg>  arguments)  that  will  be
**  called to execute the function.
**
**  'NewFunctionC' does the same as 'NewFunction',  but  expects  <name>  and
**  <nams> as C strings.
**
**  'NewFunctionT' does the same as 'NewFunction', but allows to specify  the
**  <type> and <size> of the newly created bag.
*/
Obj NewFunction(Obj name, Int narg, Obj nams, ObjFunc hdlr);

Obj NewFunctionC(const Char * name,
                 Int          narg,
                 const Char * nams,
                 ObjFunc      hdlr);

Obj NewFunctionT(
    UInt type, UInt size, Obj name, Int narg, Obj nams, ObjFunc hdlr);


/****************************************************************************
**
*F  ArgStringToList( <nams_c> )
**
**  'ArgStringToList' takes a C string <nams_c> containing a list of comma
**  separated argument names, and turns it into a plist of strings, ready
**  to be passed to 'NewFunction' as <nams>.
*/
Obj ArgStringToList(const Char * nams_c);


/****************************************************************************
**
*F * * * * * * * * * * * * * type and print function  * * * * * * * * * * * *
*/

void PrintKernelFunction(Obj func);


/****************************************************************************
**
**  'CallFuncList( <func>, <list> )'
**
**  'CallFuncList' calls the  function <func> with the arguments list <list>,
**  i.e., it is equivalent to '<func>( <list>[1], <list>[2]... )'.
*/

Obj CallFuncList(Obj func, Obj list);

extern Obj CallFuncListOper;

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoCalls() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoCalls ( void );


#endif // GAP_CALLS_H
