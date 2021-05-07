/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
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

#include "calls.h"

#include "bool.h"
#include "code.h"
#include "error.h"
#ifdef USE_GASMAN
#include "gasman_intern.h"
#endif
#include "gaptime.h"
#include "gvars.h"
#include "integer.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "saveload.h"
#include "stats.h"
#include "stringobj.h"
#include "sysstr.h"
#include "vars.h"

#ifdef HPCGAP
#include "hpc/thread.h"
#endif

void SET_NAME_FUNC(Obj func, Obj name)
{
    GAP_ASSERT(name == 0 || IS_STRING_REP(name));
    FUNC(func)->name = name;
}

Obj NAMI_FUNC(Obj func, Int i)
{
    return ELM_LIST(NAMS_FUNC(func),i);
}


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
*/
#define COUNT_PROF(prof)            (INT_INTOBJ(ELM_PLIST(prof,1)))
#define TIME_WITH_PROF(prof)        (INT_INTOBJ(ELM_PLIST(prof,2)))
#define TIME_WOUT_PROF(prof)        (INT_INTOBJ(ELM_PLIST(prof,3)))
#define STOR_WITH_PROF(prof)        (UInt8_ObjInt(ELM_PLIST(prof,4)))
#define STOR_WOUT_PROF(prof)        (UInt8_ObjInt(ELM_PLIST(prof,5)))

#define SET_COUNT_PROF(prof,n)      SET_ELM_PLIST(prof,1,INTOBJ_INT(n))
#define SET_TIME_WITH_PROF(prof,n)  SET_ELM_PLIST(prof,2,INTOBJ_INT(n))
#define SET_TIME_WOUT_PROF(prof,n)  SET_ELM_PLIST(prof,3,INTOBJ_INT(n))

static inline void SET_STOR_WITH_PROF(Obj prof, UInt8 n)
{
    SET_ELM_PLIST(prof,4,ObjInt_Int8(n));
    CHANGED_BAG(prof);
}

static inline void SET_STOR_WOUT_PROF(Obj prof, UInt8 n)
{
    SET_ELM_PLIST(prof,5,ObjInt_Int8(n));
    CHANGED_BAG(prof);
}

#define LEN_PROF                    5


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
static Obj DoWrap0args(Obj self)
{
    Obj                 result;         /* value of function call, result  */
    Obj                 args;           /* arguments list                  */

    /* make the arguments list                                             */
    args = NEW_PLIST( T_PLIST, 0 );

    /* call the variable number of arguments function                      */
    result = CALL_XARGS( self, args );
    return result;
}


/****************************************************************************
**
*F  DoWrap1args( <self>, <arg1> ) . . . . . . . wrap up 1 argument in a list
*/
static Obj DoWrap1args(Obj self, Obj arg1)
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
static Obj DoWrap2args(Obj self, Obj arg1, Obj arg2)
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
static Obj DoWrap3args(Obj self, Obj arg1, Obj arg2, Obj arg3)
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
static Obj DoWrap4args(Obj self, Obj arg1, Obj arg2, Obj arg3, Obj arg4)
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
static Obj
DoWrap5args(Obj self, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5)
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
static Obj DoWrap6args(
    Obj self, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6)
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

NORETURN static void NargError(Obj func, Int actual)
{
  Int narg = NARG_FUNC(func);

  if (narg >= 0) {
    assert(narg != actual);
    ErrorMayQuitNrArgs(narg, actual);
  } else {
    assert(-narg-1 > actual);
    ErrorMayQuitNrAtLeastArgs(-narg - 1, actual);
  }
}

static Obj DoFail0args(Obj self)
{
    NargError(self, 0);
}


/****************************************************************************
**
*F  DoFail1args( <self>,<arg1> ) . . .  fail a function call with 1 argument
*/
static Obj DoFail1args(Obj self, Obj arg1)
{
    NargError(self, 1);
}


/****************************************************************************
**
*F  DoFail2args( <self>, <arg1>, ... )  fail a function call with 2 arguments
*/
static Obj DoFail2args(Obj self, Obj arg1, Obj arg2)
{
    NargError(self, 2);
}


/****************************************************************************
**
*F  DoFail3args( <self>, <arg1>, ... )  fail a function call with 3 arguments
*/
static Obj DoFail3args(Obj self, Obj arg1, Obj arg2, Obj arg3)
{
    NargError(self, 3);
}


/****************************************************************************
**
*F  DoFail4args( <self>, <arg1>, ... )  fail a function call with 4 arguments
*/
static Obj DoFail4args(Obj self, Obj arg1, Obj arg2, Obj arg3, Obj arg4)
{
    NargError(self, 4);
}


/****************************************************************************
**
*F  DoFail5args( <self>, <arg1>, ... )  fail a function call with 5 arguments
*/
static Obj
DoFail5args(Obj self, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5)
{
    NargError(self, 5);
}


/****************************************************************************
**
*F  DoFail6args( <self>, <arg1>, ... )  fail a function call with 6 arguments
*/
static Obj DoFail6args(
    Obj self, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6)
{
    NargError(self, 6);
}


/****************************************************************************
**
*F  DoFailXargs( <self>, <args> )  . .  fail a function call with X arguments
*/
static Obj DoFailXargs(Obj self, Obj args)
{
    NargError(self, LEN_LIST(args));
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
static UInt TimeDone;


/****************************************************************************
**
*V  StorDone  . . . . .  amount of storage spent for completed function calls
**
**  'StorDone' is the amount of storage spent for all function call that have
**  already been completed.
*/
static UInt8 StorDone;


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
static ALWAYS_INLINE Obj DoProfNNNargs (
    Obj                 self,
    Int                 n,
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
    UInt8               storElse;       /* storage spent elsewhere         */
    UInt8               storCurr;       /* storage spent in current funcs. */ 

    /* get the profiling bag                                               */
    prof = PROF_FUNC( PROF_FUNC( self ) );

    /* time and storage spent so far while this function what not active   */
    timeElse = SyTime() - TIME_WITH_PROF(prof);
    storElse = SizeAllBags - STOR_WITH_PROF(prof);

    /* time and storage spent so far by all currently suspended functions  */
    timeCurr = SyTime() - TimeDone;
    storCurr = SizeAllBags - StorDone;

    /* call the real function                                              */
    switch (n) {
    case  0: result = CALL_0ARGS_PROF( self ); break;
    case  1: result = CALL_1ARGS_PROF( self, arg1 ); break;
    case  2: result = CALL_2ARGS_PROF( self, arg1, arg2 ); break;
    case  3: result = CALL_3ARGS_PROF( self, arg1, arg2, arg3 ); break;
    case  4: result = CALL_4ARGS_PROF( self, arg1, arg2, arg3, arg4 ); break;
    case  5: result = CALL_5ARGS_PROF( self, arg1, arg2, arg3, arg4, arg5 ); break;
    case  6: result = CALL_6ARGS_PROF( self, arg1, arg2, arg3, arg4, arg5, arg6 ); break;
    case -1: result = CALL_XARGS_PROF( self, arg1 ); break;
    default: result = 0; GAP_ASSERT(0);
    }

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

    return result;
}

static Obj DoProf0args (
    Obj                 self )
{
    return DoProfNNNargs(self, 0, 0, 0, 0, 0, 0, 0);
}


/****************************************************************************
**
*F  DoProf1args( <self>, <arg1>)  . . . . profile a function with 1 argument
*/
static Obj DoProf1args (
    Obj                 self,
    Obj                 arg1 )
{
    return DoProfNNNargs(self, 1, arg1, 0, 0, 0, 0, 0);
}


/****************************************************************************
**
*F  DoProf2args( <self>, <arg1>, ... )  . profile a function with 2 arguments
*/
static Obj DoProf2args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2 )
{
    return DoProfNNNargs(self, 2, arg1, arg2, 0, 0, 0, 0);
}


/****************************************************************************
**
*F  DoProf3args( <self>, <arg1>, ... )  . profile a function with 3 arguments
*/
static Obj DoProf3args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    return DoProfNNNargs(self, 3, arg1, arg2, arg3, 0, 0, 0);
}


/****************************************************************************
**
*F  DoProf4args( <self>, <arg1>, ... )  . profile a function with 4 arguments
*/
static Obj DoProf4args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    return DoProfNNNargs(self, 4, arg1, arg2, arg3, arg4, 0, 0);
}


/****************************************************************************
**
*F  DoProf5args( <self>, <arg1>, ... )  . profile a function with 5 arguments
*/
static Obj DoProf5args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    return DoProfNNNargs(self, 5, arg1, arg2, arg3, arg4, arg5, 0);
}


/****************************************************************************
**
*F  DoProf6args( <self>, <arg1>, ... )  . profile a function with 6 arguments
*/
static Obj DoProf6args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    return DoProfNNNargs(self, 6, arg1, arg2, arg3, arg4, arg5, arg6);
}


/****************************************************************************
**
*F  DoProfXargs( <self>, <args> ) . . . . profile a function with X arguments
*/
static Obj DoProfXargs (
    Obj                 self,
    Obj                 args )
{
    return DoProfNNNargs(self, -1, args, 0, 0, 0, 0, 0);
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
        Panic("No room left for function handler");
    }

    for (UInt i = 0; i < NHandlerFuncs; i++)
        if (streq(HandlerFuncs[i].cookie, cookie))
            Pr("Duplicate cookie %s\n", (Int)cookie, 0);

    HandlerFuncs[NHandlerFuncs].hdlr   = hdlr;
    HandlerFuncs[NHandlerFuncs].cookie = cookie;
    HandlerSortingStatus = 0; /* no longer sorted by handler or cookie */
    NHandlerFuncs++;
}



/****************************************************************************
**
*f  CheckHandlersBag( <bag> ) . . . . . . check that handlers are initialised
*/
#ifdef USE_GASMAN

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
                    Pr("Unregistered Handler %d args  ", j, 0);
                    PrintObj(NAME_FUNC(bag));
                    Pr("\n", 0, 0);
                }
            }
        }
    }
}

void CheckAllHandlers(void)
{
    CallbackForAllBags(CheckHandlersBag);
}

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
            ErrorQuit("Invalid sort mode %u", (Int)byWhat, 0);
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
        return (Char *)0;
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
        return (Char *)0;
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
          if (streq(cookie, HandlerFuncs[i].cookie))
            return HandlerFuncs[i].hdlr;
        }
      return (ObjFunc)0;
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
      return (ObjFunc)0;
    }
}

#endif


/****************************************************************************
**
*F  NewFunction( <name>, <narg>, <nams>, <hdlr> ) . . . . make a new function
**
**  'NewFunction' creates and returns a new function.  <name> must be  a  GAP
**  string containing the name of the function.  <narg> must be the number of
**  arguments, where -1 means a variable number of arguments.  <nams> must be
**  a GAP list containing the names  of the arguments.  <hdlr>  must  be  the
**  C function (accepting <self> and  the  <narg>  arguments)  that  will  be
**  called to execute the function.
*/
Obj NewFunction (
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr )
{
    return NewFunctionT( T_FUNCTION, sizeof(FuncBag), name, narg, nams, hdlr );
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
    return NewFunction(MakeImmString(name), narg, ArgStringToList(nams), hdlr);
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
    SET_NAME_FUNC(func, name ? ImmutableString(name) : 0);
    SET_NARG_FUNC(func, narg);
    SET_NAMS_FUNC(func, nams);
    SET_NLOC_FUNC(func, 0);
#ifdef HPCGAP
    if (nams) MakeBagPublic(nams);
#endif
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
        tmp = MakeImmStringWithLen(nams_c + k, l - k);
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
static Obj TYPE_FUNCTION;
static Obj TYPE_OPERATION;
static Obj TYPE_FUNCTION_WITH_NAME;
static Obj TYPE_OPERATION_WITH_NAME;

static Obj TypeFunction(Obj func)
{
    if (NAME_FUNC(func) == 0)
        return (IS_OPERATION(func) ? TYPE_OPERATION : TYPE_FUNCTION);
    else
        return (IS_OPERATION(func) ? TYPE_OPERATION_WITH_NAME : TYPE_FUNCTION_WITH_NAME);
}


/****************************************************************************
**
*F  PrintFunction( <func> )   . . . . . . . . . . . . . . .  print a function
**
*/

static Obj PrintOperation;

static void PrintFunction(Obj func)
{
    Int                 narg;           /* number of arguments             */
    Int                 nloc;           /* number of locals                */
    UInt                i;              /* loop variable                   */
    BOOL                isvarg;         /* does function have varargs?     */

    isvarg = FALSE;

    if ( IS_OPERATION(func) ) {
      CALL_1ARGS( PrintOperation, func );
      return;
    }

#ifdef HPCGAP
    /* print 'function (' or 'atomic function ('                          */
    if (LCKS_FUNC(func)) {
      Pr("%5>atomic function%< ( %>", 0, 0);
    } else
      Pr("%5>function%< ( %>", 0, 0);
#else
    /* print 'function ('                                                  */
    Pr("%5>function%< ( %>", 0, 0);
#endif

    /* print the arguments                                                 */
    narg = NARG_FUNC(func);
    if (narg < 0) {
      isvarg = TRUE;
      narg = -narg;
    }
    
    for ( i = 1; i <= narg; i++ ) {
#ifdef HPCGAP
        if (LCKS_FUNC(func)) {
            const Char * locks = CONST_CSTR_STRING(LCKS_FUNC(func));
            switch(locks[i-1]) {
            case LOCK_QUAL_READONLY:
                Pr("%>readonly %<", 0, 0);
                break;
            case LOCK_QUAL_READWRITE:
                Pr("%>readwrite %<", 0, 0);
                break;
            }
        }
#endif
        if ( NAMS_FUNC(func) != 0 )
            Pr("%H", (Int)NAMI_FUNC(func, (Int)i), 0);
        else
            Pr("<<arg-%d>>", (Int)i, 0);
        if(isvarg && i == narg) {
            Pr("...", 0, 0);
        }
        if (i != narg)
            Pr("%<, %>", 0, 0);
    }
    Pr(" %<)\n", 0, 0);

    // print the body
    if (IsKernelFunction(func)) {
        PrintKernelFunction(func);
    }
    else {
        /* print the locals                                                */
        nloc = NLOC_FUNC(func);
        if ( nloc >= 1 ) {
            Pr("%>local ", 0, 0);
            for ( i = 1; i <= nloc; i++ ) {
                if ( NAMS_FUNC(func) != 0 )
                    Pr("%H", (Int)NAMI_FUNC(func, (Int)(narg + i)), 0);
                else
                    Pr("<<loc-%d>>", (Int)i, 0);
                if (i != nloc)
                    Pr("%<, %>", 0, 0);
            }
            Pr("%<;\n", 0, 0);
        }

        // print the code
        Obj oldLVars;
        oldLVars = SWITCH_TO_NEW_LVARS(func, narg, NLOC_FUNC(func));
        PrintStat( OFFSET_FIRST_STAT );
        SWITCH_TO_OLD_LVARS( oldLVars );
    }
    Pr("%4<\n", 0, 0);

    /* print 'end'                                                         */
    Pr("end", 0, 0);
}

void PrintKernelFunction(Obj func)
{
    GAP_ASSERT(IsKernelFunction(func));
    Obj body = BODY_FUNC(func);
    Obj filename = body ? GET_FILENAME_BODY(body) : 0;
    if (filename) {
        if ( GET_LOCATION_BODY(body) ) {
            Pr("<<kernel code>> from %g:%g",
                (Int)filename,
                (Int)GET_LOCATION_BODY(body));
        }
        else if ( GET_STARTLINE_BODY(body) ) {
            Pr("<<compiled GAP code>> from %g:%d",
                (Int)filename,
                GET_STARTLINE_BODY(body));
        }
    }
    else {
        Pr("<<kernel or compiled code>>", 0, 0);
    }
}


/****************************************************************************
**
*F  FiltIS_FUNCTION( <self>, <func> ) . . . . . . . . . . . test for function
**
**  'FiltIS_FUNCTION' implements the internal function 'IsFunction'.
**
**  'IsFunction( <func> )'
**
**  'IsFunction' returns   'true'  if  <func>   is a function    and  'false'
**  otherwise.
*/
static Obj IsFunctionFilt;

static Obj FiltIS_FUNCTION(Obj self, Obj obj)
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
static Obj CallFuncListWrapOper;

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
    return result;

}

static Obj FuncCALL_FUNC_LIST(Obj self, Obj func, Obj list)
{
    RequireSmallList(SELF_NAME, list);
    return CallFuncList(func, list);
}

static Obj FuncCALL_FUNC_LIST_WRAP(Obj self, Obj func, Obj list)
{
    RequireSmallList(SELF_NAME, list);
    Obj retval = CallFuncList(func, list);
    return (retval == 0) ? NewImmutableEmptyPlist()
                         : NewPlistFromArgs(retval);
}

/****************************************************************************
**
*F * * * * * * * * * * * * * * * utility functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  AttrNAME_FUNC( <self>, <func> ) . . . . . . . . . . .  name of a function
*/
static Obj NameFuncAttr;
static Obj SET_NAME_FUNC_Oper;

static Obj AttrNAME_FUNC(Obj self, Obj func)
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
        return DoAttribute( self, func );
    }
}

static Obj FuncSET_NAME_FUNC(Obj self, Obj func, Obj name)
{
    RequireStringRep(SELF_NAME, name);

  if (TNUM_OBJ(func) == T_FUNCTION ) {
    SET_NAME_FUNC(func, ImmutableString(name));
    CHANGED_BAG(func);
  } else
    DoOperation2Args(SET_NAME_FUNC_Oper, func, name);
  return (Obj) 0;
}


/****************************************************************************
**
*F  FuncNARG_FUNC( <self>, <func> ) . . . . number of arguments of a function
*/
static Obj NARG_FUNC_Oper;

static Obj FuncNARG_FUNC(Obj self, Obj func)
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
static Obj NAMS_FUNC_Oper;

static Obj FuncNAMS_FUNC(Obj self, Obj func)
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

/****************************************************************************
**
*F  FuncLOCKS_FUNC( <self>, <func> ) . . . . locking status of a possibly
**                                           atomic function
*/
static Obj LOCKS_FUNC_Oper;

static Obj FuncLOCKS_FUNC(Obj self, Obj func)
{
#ifdef HPCGAP
    Obj locks;
    if (TNUM_OBJ(func) == T_FUNCTION) {
        locks = LCKS_FUNC(func);
        if (locks == (Obj)0)
            return Fail;
        else
            return locks;
    }
    else {
        return DoOperation1Args(self, func);
    }
#else
    return Fail;
#endif
}


/****************************************************************************
**
*F  FuncPROF_FUNC( <self>, <func> ) . . . . . .  profiling info of a function
*/
static Obj PROF_FUNC_Oper;

static Obj FuncPROF_FUNC(Obj self, Obj func)
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
static Obj FuncCLEAR_PROFILE_FUNC(Obj self, Obj func)
{
    Obj                 prof;

    RequireFunction(SELF_NAME, func);

    /* clear profile info                                                  */
    prof = PROF_FUNC(func);
    if ( prof == 0 ) {
        ErrorQuit("<func> has corrupted profile info", 0, 0);
    }
    if ( TNUM_OBJ(prof) == T_FUNCTION ) {
        prof = PROF_FUNC(prof);
    }
    if ( prof == 0 ) {
        ErrorQuit("<func> has corrupted profile info", 0, 0);
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
static Obj FuncPROFILE_FUNC(Obj self, Obj func)
{
    Obj                 prof;
    Obj                 copy;

    RequireFunction(SELF_NAME, func);

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
        SET_NLOC_FUNC(copy,   NLOC_FUNC(func));
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
static Obj FuncIS_PROFILED_FUNC(Obj self, Obj func)
{
    RequireFunction(SELF_NAME, func);
    return ( TNUM_OBJ(PROF_FUNC(func)) != T_FUNCTION ) ? False : True;
}

static Obj FuncFILENAME_FUNC(Obj self, Obj func)
{
    RequireFunction(SELF_NAME, func);

    if (BODY_FUNC(func)) {
        Obj fn =  GET_FILENAME_BODY(BODY_FUNC(func));
        if (fn)
            return fn;
    }
    return Fail;
}

static Obj FuncSTARTLINE_FUNC(Obj self, Obj func)
{
    RequireFunction(SELF_NAME, func);

    if (BODY_FUNC(func)) {
        UInt sl = GET_STARTLINE_BODY(BODY_FUNC(func));
        if (sl)
            return INTOBJ_INT(sl);
    }
    return Fail;
}

static Obj FuncENDLINE_FUNC(Obj self, Obj func)
{
    RequireFunction(SELF_NAME, func);

    if (BODY_FUNC(func)) {
        UInt el = GET_ENDLINE_BODY(BODY_FUNC(func));
        if (el)
            return INTOBJ_INT(el);
    }
    return Fail;
}

static Obj FuncLOCATION_FUNC(Obj self, Obj func)
{
    RequireFunction(SELF_NAME, func);

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
static Obj FuncUNPROFILE_FUNC(Obj self, Obj func)
{
    Obj                 prof;

    RequireFunction(SELF_NAME, func);

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


/****************************************************************************
*
*F  FuncIsKernelFunction( <self>, <func> )
**
**  'FuncIsKernelFunction' returns Fail if <func> is not a function, True if
**  <func> is a kernel function, and False otherwise.
*/
static Obj FuncIsKernelFunction(Obj self, Obj func)
{
    if (!IS_FUNC(func))
        return Fail;
    return IsKernelFunction(func) ? True : False;
}

BOOL IsKernelFunction(Obj func)
{
    GAP_ASSERT(IS_FUNC(func));
    return (BODY_FUNC(func) == 0) ||
           (SIZE_OBJ(BODY_FUNC(func)) == sizeof(BodyHeader));
}


/* Returns a measure of the size of a GAP function */
static Obj FuncFUNC_BODY_SIZE(Obj self, Obj func)
{
    RequireFunction(SELF_NAME, func);
    Obj body = BODY_FUNC(func);
    if (body == 0)
        return INTOBJ_INT(0);
    return ObjInt_UInt(SIZE_BAG(body));
}

#ifdef GAP_ENABLE_SAVELOAD

static void SaveHandler(ObjFunc hdlr)
{
    const Char * cookie;
    if (hdlr == (ObjFunc)0)
        SaveCStr("");
    else {
        cookie = CookieOfHandler(hdlr);
        if (!cookie) {
            Pr("No cookie for Handler -- workspace will be corrupt\n", 0, 0);
            SaveCStr("");
        }
        else
            SaveCStr(cookie);
    }
}


static ObjFunc LoadHandler( void )
{
  Char buf[256];
  LoadCStr(buf, 256);
  if (buf[0] == '\0')
    return (ObjFunc) 0;
  else
    return HandlerOfCookie(buf);
}

/****************************************************************************
**
*F  SaveFunction( <func> )  . . . . . . . . . . . . . . . . . save a function
**
*/
static void SaveFunction(Obj func)
{
  const FuncBag * header = CONST_FUNC(func);
  for (UInt i = 0; i < ARRAY_SIZE(header->handlers); i++)
    SaveHandler(header->handlers[i]);
  SaveSubObj(header->name);
  SaveSubObj(header->nargs);
  SaveSubObj(header->namesOfArgsAndLocals);
  SaveSubObj(header->prof);
  SaveSubObj(header->nloc);
  SaveSubObj(header->body);
  SaveSubObj(header->envi);
  if (IS_OPERATION(func))
    SaveOperationExtras( func );
}

/****************************************************************************
**
*F  LoadFunction( <func> )  . . . . . . . . . . . . . . . . . load a function
**
*/
static void LoadFunction(Obj func)
{
  FuncBag * header = FUNC(func);
  for (UInt i = 0; i < ARRAY_SIZE(header->handlers); i++)
    header->handlers[i] = LoadHandler();
  header->name = LoadSubObj();
  header->nargs = LoadSubObj();
  header->namesOfArgsAndLocals = LoadSubObj();
  header->prof = LoadSubObj();
  header->nloc = LoadSubObj();
  header->body = LoadSubObj();
  header->envi = LoadSubObj();
  if (IS_OPERATION(func))
    LoadOperationExtras( func );
}

#endif

/****************************************************************************
**
*F  MarkFunctionSubBags( <bag> ) . . . . . . . marking function for functions
**
**  'MarkFunctionSubBags' is the marking function for bags of type 'T_FUNCTION'.
*/
static void MarkFunctionSubBags(Obj func)
{
    // the first eight slots are pointers to C functions, so we need
    // to skip those for marking
    UInt size = SIZE_BAG(func) / sizeof(Obj) - 8;
    const Bag * data = CONST_PTR_BAG(func) + 8;
    MarkArrayOfBags(data, size);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_FUNCTION, "function" },
  { -1,         ""         }
};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_FUNCTION, "obj", &IsFunctionFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarAttrs . . . . . . . . . . . . . . . . .  list of attributes to export
*/
static StructGVarAttr GVarAttrs [] = {

    GVAR_ATTR(NAME_FUNC, "func", &NameFuncAttr),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    GVAR_OPER_2ARGS(CALL_FUNC_LIST, func, list, &CallFuncListOper),
    GVAR_OPER_2ARGS(CALL_FUNC_LIST_WRAP, func, list, &CallFuncListWrapOper),
    GVAR_OPER_2ARGS(SET_NAME_FUNC, func, name, &SET_NAME_FUNC_Oper),
    GVAR_OPER_1ARGS(NARG_FUNC, func, &NARG_FUNC_Oper),
    GVAR_OPER_1ARGS(NAMS_FUNC, func, &NAMS_FUNC_Oper),
    GVAR_OPER_1ARGS(LOCKS_FUNC, func, &LOCKS_FUNC_Oper),
    GVAR_OPER_1ARGS(PROF_FUNC, func, &PROF_FUNC_Oper),
    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_1ARGS(CLEAR_PROFILE_FUNC, func),
    GVAR_FUNC_1ARGS(IS_PROFILED_FUNC, func),
    GVAR_FUNC_1ARGS(PROFILE_FUNC, func),
    GVAR_FUNC_1ARGS(UNPROFILE_FUNC, func),
    GVAR_FUNC_1ARGS(IsKernelFunction, func),
    GVAR_FUNC_1ARGS(FILENAME_FUNC, func),
    GVAR_FUNC_1ARGS(LOCATION_FUNC, func),
    GVAR_FUNC_1ARGS(STARTLINE_FUNC, func),
    GVAR_FUNC_1ARGS(ENDLINE_FUNC, func),

    GVAR_FUNC_1ARGS(FUNC_BODY_SIZE, func),

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking functions                                       */
    InitMarkFuncBags(T_FUNCTION, MarkFunctionSubBags);

#ifdef HPCGAP
    /* Allocate functions in the public region */
    MakeBagTypePublic(T_FUNCTION);
#endif

    /* install the type functions                                          */
    ImportGVarFromLibrary( "TYPE_FUNCTION",  &TYPE_FUNCTION  );
    ImportGVarFromLibrary( "TYPE_OPERATION", &TYPE_OPERATION );
    ImportGVarFromLibrary( "TYPE_FUNCTION_WITH_NAME",  &TYPE_FUNCTION_WITH_NAME  );
    ImportGVarFromLibrary( "TYPE_OPERATION_WITH_NAME", &TYPE_OPERATION_WITH_NAME );
    TypeObjFuncs[ T_FUNCTION ] = TypeFunction;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrAttrsFromTable( GVarAttrs );
    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );

#ifdef USE_GASMAN
    /* and the saving function                                             */
    SaveObjFuncs[ T_FUNCTION ] = SaveFunction;
    LoadObjFuncs[ T_FUNCTION ] = LoadFunction;
#endif

    /* install the printer                                                 */
    InitFopyGVar( "PRINT_OPERATION", &PrintOperation );
    PrintObjFuncs[ T_FUNCTION ] = PrintFunction;


    /* initialise all 'Do<Something><N>args' handlers, give the most       */
    /* common ones short cookies to save space in the saved workspace   */
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

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarAttrsFromTable( GVarAttrs );
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitInfoCalls() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "calls",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoCalls ( void )
{
    return &module;
}
