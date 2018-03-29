/****************************************************************************
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002-2018 The GAP Group
**
**  This file declares functions for raising user errors and interacting
**  with the break loop.
**
*/

#include <src/error.h>

#include <src/bool.h>
#include <src/gapstate.h>
#include <src/gaputils.h>
#include <src/io.h>
#include <src/modules.h>
#include <src/plist.h>
#include <src/precord.h>
#include <src/records.h>
#include <src/stringobj.h>
#include <src/vars.h>

#ifdef HPCGAP
#include <src/hpc/thread.h>
#endif

#include <stdio.h>


static Obj ErrorInner;


/****************************************************************************
**
*F RegisterBreakloopObserver( <func> )
**
** Register a function which will be called when the break loop is entered
** and left. Function should take a single Int argument which will be 1 when
** break loop is entered, 0 when leaving.
**
** Note that it is also possible to leave the break loop (or any GAP code)
** by longjmping. This should be tracked with RegisterSyLongjmpObserver.
*/

static intfunc signalBreakFuncList[16];

Int RegisterBreakloopObserver(intfunc func)
{
    Int i;
    for (i = 0; i < ARRAY_SIZE(signalBreakFuncList); ++i) {
        if (signalBreakFuncList[i] == 0) {
            signalBreakFuncList[i] = func;
            return 1;
        }
    }
    return 0;
}

/****************************************************************************
**
*F  ErrorMessageToGAPString( <msg>, <arg1>, <arg2> )
*/

static Obj ErrorMessageToGAPString( 
    const Char *        msg,
    Int                 arg1,
    Int                 arg2 )
{
  Char message[1024];
  Obj Message;
  SPrTo(message, sizeof(message), msg, arg1, arg2);
  message[sizeof(message)-1] = '\0';
  Message = MakeString(message);
  return Message;
}


Obj CallErrorInner (
    const Char *        msg,
    Int                 arg1,
    Int                 arg2,
    UInt                justQuit,
    UInt                mayReturnVoid,
    UInt                mayReturnObj,
    Obj                 lateMessage,
    UInt                printThisStatement)
{
  // Must do this before creating any other GAP objects,
  // as one of the args could be a pointer into a Bag.
  Obj EarlyMsg = ErrorMessageToGAPString(msg, arg1, arg2);

  Obj r = NEW_PREC(0);
  Obj l;
  Int i;

#ifdef HPCGAP
  Region *savedRegion = TLS(currentRegion);
  TLS(currentRegion) = TLS(threadRegion);
#endif
  AssPRec(r, RNamName("context"), STATE(CurrLVars));
  AssPRec(r, RNamName("justQuit"), justQuit? True : False);
  AssPRec(r, RNamName("mayReturnObj"), mayReturnObj? True : False);
  AssPRec(r, RNamName("mayReturnVoid"), mayReturnVoid? True : False);
  AssPRec(r, RNamName("printThisStatement"), printThisStatement? True : False);
  AssPRec(r, RNamName("lateMessage"), lateMessage);
  l = NEW_PLIST_IMM(T_PLIST_HOM, 1);
  SET_ELM_PLIST(l,1,EarlyMsg);
  SET_LEN_PLIST(l,1);
  SET_BRK_CALL_TO(STATE(CurrStat));
  // Signal functions about entering and leaving break loop
  for (i = 0; i < ARRAY_SIZE(signalBreakFuncList) && signalBreakFuncList[i]; ++i)
      (signalBreakFuncList[i])(1);
  Obj res = CALL_2ARGS(ErrorInner,r,l);
  for (i = 0; i < ARRAY_SIZE(signalBreakFuncList) && signalBreakFuncList[i]; ++i)
      (signalBreakFuncList[i])(0);
#ifdef HPCGAP
  TLS(currentRegion) = savedRegion;
#endif
  return res;
}

void ErrorQuit (
    const Char *        msg,
    Int                 arg1,
    Int                 arg2 )
{
    CallErrorInner(msg, arg1, arg2, 1, 0, 0, False, 1);
    FPUTS_TO_STDERR("panic: ErrorQuit must not return\n");
    SyExit(1);
}


/****************************************************************************
**
*F  ErrorQuitBound( <name> )  . . . . . . . . . . . . . . .  unbound variable
*/
void ErrorQuitBound (
    const Char *        name )
{
    ErrorQuit(
        "variable '%s' must have an assigned value",
        (Int)name, 0L );
}


/****************************************************************************
**
*F  ErrorQuitFuncResult() . . . . . . . . . . . . . . . . must return a value
*/
void ErrorQuitFuncResult ( void )
{
    ErrorQuit(
        "function must return a value",
        0L, 0L );
}


/****************************************************************************
**
*F  ErrorQuitIntSmall( <obj> )  . . . . . . . . . . . . . not a small integer
*/
void ErrorQuitIntSmall (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be a small integer (not a %s)",
        (Int)TNAM_OBJ(obj), 0L );
}


/****************************************************************************
**
*F  ErrorQuitIntSmallPos( <obj> ) . . . . . . .  not a positive small integer
*/
void ErrorQuitIntSmallPos (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be a positive small integer (not a %s)",
        (Int)TNAM_OBJ(obj), 0L );
}

/****************************************************************************
**
*F  ErrorQuitIntPos( <obj> ) . . . . . . .  not a positive small integer
*/
void ErrorQuitIntPos (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be a positive integer (not a %s)",
        (Int)TNAM_OBJ(obj), 0L );
}


/****************************************************************************
**
*F  ErrorQuitBool( <obj> )  . . . . . . . . . . . . . . . . . . not a boolean
*/
void ErrorQuitBool (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be 'true' or 'false' (not a %s)",
        (Int)TNAM_OBJ(obj), 0L );
}


/****************************************************************************
**
*F  ErrorQuitFunc( <obj> )  . . . . . . . . . . . . . . . . .  not a function
*/
void ErrorQuitFunc (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be a function (not a %s)",
        (Int)TNAM_OBJ(obj), 0L );
}


/****************************************************************************
**
*F  ErrorQuitNrArgs( <narg>, <args> ) . . . . . . . wrong number of arguments
*/
void ErrorQuitNrArgs (
    Int                 narg,
    Obj                 args )
{
    ErrorQuit(
        "Function Calls: number of arguments must be %d (not %d)",
        narg, LEN_PLIST( args ) );
}

/****************************************************************************
**
*F  ErrorQuitNrAtLeastArgs( <narg>, <args> ) . . . . . . not enough arguments
*/
void ErrorQuitNrAtLeastArgs (
    Int                 narg,
    Obj                 args )
{
    ErrorQuit(
        "Function Calls: number of arguments must be at least %d (not %d)",
        narg, LEN_PLIST( args ) );
}

/****************************************************************************
**
*F  ErrorQuitRange3( <first>, <second>, <last> ) . . divisibility
*/
void ErrorQuitRange3 (
                      Obj                 first,
                      Obj                 second,
                      Obj                 last)
{
    ErrorQuit(
        "Range expression <last>-<first> must be divisible by <second>-<first>, not %d %d",
        INT_INTOBJ(last)-INT_INTOBJ(first), INT_INTOBJ(second)-INT_INTOBJ(first) );
}


/****************************************************************************
**
*F  ErrorReturnObj( <msg>, <arg1>, <arg2>, <msg2> ) . .  print and return obj
*/
Obj ErrorReturnObj (
    const Char *        msg,
    Int                 arg1,
    Int                 arg2,
    const Char *        msg2 )
{
  Obj LateMsg;
  LateMsg = MakeString(msg2);
  return CallErrorInner(msg, arg1, arg2, 0, 0, 1, LateMsg, 1);
}


/****************************************************************************
**
*F  ErrorReturnVoid( <msg>, <arg1>, <arg2>, <msg2> )  . . .  print and return
*/
void ErrorReturnVoid (
    const Char *        msg,
    Int                 arg1,
    Int                 arg2,
    const Char *        msg2 )
{
  Obj LateMsg;
  LateMsg = MakeString(msg2);
  CallErrorInner( msg, arg1, arg2, 0,1,0,LateMsg, 1);
  /*    ErrorMode( msg, arg1, arg2, (Obj)0, msg2, 'x' ); */
}

/****************************************************************************
**
*F  ErrorMayQuit( <msg>, <arg1>, <arg2> )  . . .  print and return
*/
void ErrorMayQuit (
    const Char *        msg,
    Int                 arg1,
    Int                 arg2)
{
    Obj LateMsg = MakeString("type 'quit;' to quit to outer loop");
    CallErrorInner(msg, arg1, arg2, 0, 0, 0, LateMsg, 1);
    FPUTS_TO_STDERR("panic: ErrorMayQuit must not return\n");
    SyExit(1);
}


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo *    module )
{
    ImportFuncFromLibrary(  "ErrorInner", &ErrorInner );
  
  /* return success                                                        */
  return 0;
}


/****************************************************************************
**
*F  InitInfoError() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "error",
    .initKernel = InitKernel,
};

StructInitInfo * InitInfoError ( void )
{
  return &module;
}
