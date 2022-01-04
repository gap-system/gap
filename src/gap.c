/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the various read-eval-print loops and  related  stuff.
*/

#include "gap.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "compiler.h"
#include "error.h"
#include "funcs.h"
#include "gapstate.h"
#ifdef USE_GASMAN
#include "gasman_intern.h"
#endif
#include "gaptime.h"
#include "gvars.h"
#include "integer.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "precord.h"
#include "read.h"
#include "records.h"
#include "saveload.h"
#include "streams.h"
#include "stringobj.h"
#include "sysenv.h"
#include "sysfiles.h"
#include "sysopt.h"
#include "sysroots.h"
#include "sysstr.h"
#include "trycatch.h"
#include "vars.h"
#include "version.h"

#ifdef HPCGAP
#include "hpc/misc.h"
#include "hpc/thread.h"
#include "hpc/threadapi.h"
#endif

#if defined(USE_GASMAN)
#include "sysmem.h"
#elif defined(USE_JULIA_GC)
#include "julia.h"
#elif defined(USE_BOEHM_GC)
#include "boehm_gc.h"
#endif

#include "config.h"

#include <gmp.h>

static Obj Error;

static UInt SystemErrorCode;


/****************************************************************************
**
*V  Last  . . . . . . . . . . . . . . . . . . . . . . global variable  'last'
**
**  'Last',  'Last2', and 'Last3'  are the  global variables 'last', 'last2',
**  and  'last3', which are automatically  assigned  the result values in the
**  main read-eval-print loop.
*/
static UInt Last;


/****************************************************************************
**
*V  Last2 . . . . . . . . . . . . . . . . . . . . . . global variable 'last2'
*/
static UInt Last2;


/****************************************************************************
**
*V  Last3 . . . . . . . . . . . . . . . . . . . . . . global variable 'last3'
*/
static UInt Last3;


/****************************************************************************
**
*V  Time  . . . . . . . . . . . . . . . . . . . . . . global variable  'time'
**
**  'Time' is the global variable 'time', which is automatically assigned the
**  time the last command took.
*/
static UInt Time;

/****************************************************************************
**
*V  MemoryAllocated . . . . . . . . . . . global variable  'memory_allocated'
**
**  'MemoryAllocated' is the global variable 'memory_allocated', 
**  which is automatically assigned the amount of memory allocated while
**  executing the last command.
*/
static UInt MemoryAllocated;


#ifndef HPCGAP
GAPState MainGAPState;
#endif


/****************************************************************************
**
*F  ViewObjHandler  . . . . . . . . . handler to view object and catch errors
**
**  This is the function actually called in Read-Eval-View loops.
**  We might be in trouble if the library has not (yet) loaded and so ViewObj
**  is not yet defined, or the fallback methods not yet installed. To avoid
**  this problem, we check, and use PrintObj if there is a problem
**
**  This function also supplies the \n after viewing.
*/
UInt ViewObjGVar;

void ViewObjHandler ( Obj obj )
{
  // save some values in case view runs into error
  volatile Bag  currLVars   = STATE(CurrLVars);

  /* if non-zero use this function, otherwise use `PrintObj'             */
  GAP_TRY {
    Obj func = ValAutoGVar(ViewObjGVar);
    if ( func != 0 && TNUM_OBJ(func) == T_FUNCTION ) {
      ViewObj(obj);
    }
    else {
      PrintObj( obj );
    }
    Pr("\n", 0, 0);
    GAP_ASSERT(currLVars == STATE(CurrLVars));
  }
  GAP_CATCH {
    SWITCH_TO_OLD_LVARS(currLVars);
  }
}


/****************************************************************************
**
*F  main( <argc>, <argv> )  . . . . . . .  main program, read-eval-print loop
*/
static UInt QUITTINGGVar;


static Obj FuncSHELL(Obj self,
                     Obj context,
                     Obj canReturnVoid,
                     Obj canReturnObj,
                     Obj breakLoop,
                     Obj prompt,
                     Obj preCommandHook)
{
    //
    // validate all arguments
    //
    if (!IS_LVARS_OR_HVARS(context))
        RequireArgument(SELF_NAME, context, "must be a local variables bag");

    RequireTrueOrFalse(SELF_NAME, canReturnVoid);
    RequireTrueOrFalse(SELF_NAME, canReturnObj);
    RequireTrueOrFalse(SELF_NAME, breakLoop);
    RequireStringRep(SELF_NAME, prompt);
    if (GET_LEN_STRING(prompt) > 80)
        ErrorMayQuit("SHELL: <prompt> must be a string of length at most 80",
                     0, 0);

    if (preCommandHook == False)
        preCommandHook = 0;
    else if (!IS_FUNC(preCommandHook))
        RequireArgument(SELF_NAME, preCommandHook,
                        "must be function or false");

    //
    // open input and output streams
    //
    const Char * inFile;
    const Char * outFile;

    if (breakLoop == True) {
        inFile = "*errin*";
        outFile = "*errout*";
    }
#ifdef HPCGAP
    else if (ThreadUI) {
        inFile = "*defin*";
        outFile = "*defout*";
    }
#endif
    else {
        inFile = "*stdin*";
        outFile = "*stdout*";
    }

    TypOutputFile output = { 0 };
    if (!OpenOutput(&output, outFile, FALSE))
        ErrorQuit("SHELL: can't open outfile %s", (Int)outFile, 0);

    TypInputFile input = { 0 };
    if (!OpenInput(&input, inFile)) {
        CloseOutput(&output);
        ErrorQuit("SHELL: can't open infile %s", (Int)inFile, 0);
    }

    //
    // save some state
    //
    Int  oldErrorLLevel = STATE(ErrorLLevel);
    Int  oldRecursionDepth = GetRecursionDepth();
    UInt oldPrintObjState = SetPrintObjState(0);

    //
    // return values of ReadEvalCommand
    //
    ExecStatus status;
    Obj  evalResult;

    //
    // start the REPL (read-eval-print loop)
    //
    STATE(ErrorLLevel) = 0;
    while (1) {
        UInt  time = 0;
        UInt8 mem = 0;

        /* start the stopwatch                                             */
        if (breakLoop == False) {
            time = SyTime();
            mem = SizeAllBags;
        }

        /* read and evaluate one command                                   */
        SetPrompt(CONST_CSTR_STRING(prompt));
        SetPrintObjState(0);
        ResetOutputIndent();
        SetRecursionDepth(0);

        /* here is a hook: */
        if (preCommandHook) {
            Call0ArgsInNewReader(preCommandHook);
            // Recover from a potential break loop:
            SetPrompt(CONST_CSTR_STRING(prompt));
        }

        // update ErrorLVars based on ErrorLLevel
        //
        // It is slightly wasteful to do this every time, but that's OK since
        // this code is only used for interactive input, and the time it takes
        // a user to press the return key is something like a thousand times
        // greater than the time it takes to execute this loop.
        Int depth = STATE(ErrorLLevel);
        Obj errorLVars = context;
        STATE(ErrorLLevel) = 0;
        while (0 < depth && !IsBottomLVars(errorLVars) &&
               !IsBottomLVars(PARENT_LVARS(errorLVars))) {
            errorLVars = PARENT_LVARS(errorLVars);
            STATE(ErrorLLevel)++;
            depth--;
        }
        STATE(ErrorLVars) = errorLVars;

        // read and evaluate one command (statement or expression)
        BOOL dualSemicolon;
        status =
            ReadEvalCommand(errorLVars, &input, &evalResult, &dualSemicolon);

        // if the input we just processed *indirectly* executed a `QUIT` statement
        // (e.g. by reading a file via `READ`) then bail out
        if (STATE(UserHasQUIT))
            break;

        // if the statement we just processed itself was `QUIT`, also bail out
        if (status == STATUS_QQUIT) {
            STATE(UserHasQUIT) = TRUE;
            break;
        }

        /* handle ordinary command                                         */
        if (status == STATUS_END && evalResult != 0) {
            UpdateLast(evalResult);
            if (!dualSemicolon) {
                ViewObjHandler(evalResult);
            }
        }

        /* handle return-value or return-void command                      */
        else if (status == STATUS_RETURN && evalResult != 0) {
            if (canReturnObj == True)
                break;
            Pr("'return <object>' cannot be used in this read-eval-print "
               "loop\n",
               0, 0);
        }
        else if (status == STATUS_RETURN && evalResult == 0) {
            if (canReturnVoid == True)
                break;
            Pr("'return' cannot be used in this read-eval-print loop\n", 0,
               0);
        }
        /* handle quit command or <end-of-file>                            */
        else if (status == STATUS_EOF || status == STATUS_QUIT) {
            break;
        }

        /* stop the stopwatch                                          */
        if (breakLoop == False) {
            UpdateTime(time);
            AssGVarWithoutReadOnlyCheck(MemoryAllocated,
                                        ObjInt_Int8(SizeAllBags - mem));
        }

        if (STATE(UserHasQuit)) {
            // If we get here, then some code invoked indirectly by the
            // command we just processed was aborted via `quit` (most likely:
            // `quit` was entered in a break loop). Stop processing any
            // further input in the current line of input. Thus if the input
            // is `f(); g();` and executing `f()` triggers a break loop that
            // the user aborts via `quit`, then we won't try to execute `g()`
            // anymore.
            //
            // So in a sense we are (ab)using `UserHasQuit` to see if an error
            // occurred.
            FlushRestOfInputLine(&input);
            STATE(UserHasQuit) = FALSE;
        }
    }

    //
    // cleanup: restore state, close input/output streams
    //
    SetPrintObjState(oldPrintObjState);
    SetRecursionDepth(oldRecursionDepth);
    STATE(ErrorLLevel) = oldErrorLLevel;
    CloseInput(&input);
    CloseOutput(&output);

    //
    // handle QUIT
    //
    if (STATE(UserHasQUIT)) {
        // If we are in a break loop, throw so that the next higher up
        // read&eval loop can process the QUIT
        if (breakLoop == True)
            GAP_THROW();

        // If we are the topmost REPL, then indicating we are QUITing to the
        // GAP language level, and simply end the loop. This implicitly
        // assumes that the only places using SHELL() are the primary REPL and
        // break loops.
        STATE(UserHasQuit) = FALSE;
        STATE(UserHasQUIT) = FALSE;
        AssGVarWithoutReadOnlyCheck(QUITTINGGVar, True);
        return Fail;
    }

    //
    // handle the remaining status codes; note that `STATUS_QQUIT` is handled
    // above, as part of the `UserHasQUIT` handling
    //
    if (status == STATUS_EOF || status == STATUS_QUIT) {
        return Fail;
    }
    if (status == STATUS_RETURN) {
        return evalResult ? NewPlistFromArgs(evalResult) : NewEmptyPlist();
    }

    Panic("SHELL: unhandled status %d, this code should never be reached",
          (int)status);
    return (Obj)0;
}

int realmain( int argc, char * argv[] )
{
  UInt                type;                   /* result of compile       */
  Obj                 func;                   /* function (compiler)     */
  Int4                crc;                    /* crc of file to compile  */

  /* initialize everything and read init.g which runs the GAP session */
  InitializeGap( &argc, argv, 1 );
  if (!STATE(UserHasQUIT)) {         /* maybe the user QUIT from the initial
                                   read of init.g  somehow*/
    /* maybe compile in which case init.g got skipped */
    if ( SyCompilePlease ) {
      TypInputFile input = { 0 };
      if ( ! OpenInput(&input, SyCompileInput) ) {
        return 1;
      }
      func = READ_AS_FUNC(&input);
      if (!CloseInput(&input)) {
          return 2;
      }
      crc  = SyGAPCRC(SyCompileInput);
      type = CompileFunc(
                         MakeImmString(SyCompileOutput),
                         func,
                         MakeImmString(SyCompileName),
                         crc,
                         MakeImmString(SyCompileMagic1) );
      return ( type == 0 ) ? 1 : 0;
    }
  }
  return SystemErrorCode;
}

#if !defined(COMPILECYGWINDLL)
int main ( int argc, char * argv[] )
{
  InstallBacktraceHandlers();

#ifdef HPCGAP
  RunThreadedMain(realmain, argc, argv);
  return 0;
#else
  return realmain(argc, argv);
#endif
}

#endif

/****************************************************************************
**
*F  FuncID_FUNC( <self>, <val1> ) . . . . . . . . . . . . . . . return <val1>
*/
static Obj FuncID_FUNC(Obj self, Obj val1)
{
  return val1;
}

/****************************************************************************
**
*F  FuncRETURN_FIRST( <self>, <args> ) . . . . . . . . Return first argument
*/
static Obj FuncRETURN_FIRST(Obj self, Obj args)
{
    if (!IS_PLIST(args) || LEN_PLIST(args) < 1)
        ErrorMayQuit("RETURN_FIRST requires one or more arguments",0,0);

    return ELM_PLIST(args, 1);
}

/****************************************************************************
**
*F  FuncRETURN_NOTHING( <self>, <arg> ) . . . . . . . . . . . Return nothing
*/
static Obj FuncRETURN_NOTHING(Obj self, Obj arg)
{
  return 0;
}


/****************************************************************************
**
*F  FuncSizeScreen( <self>, <args> )  . . . .  internal function 'SizeScreen'
**
**  'FuncSizeScreen'  implements  the  internal  function 'SizeScreen' to get
**  or set the actual screen size.
**
**  'SizeScreen()'
**
**  In this form 'SizeScreen'  returns the size of the  screen as a list with
**  two  entries.  The first is  the length of each line,  the  second is the
**  number of lines.
**
**  'SizeScreen( [ <x>, <y> ] )'
**
**  In this form 'SizeScreen' sets the size of the screen.  <x> is the length
**  of each line, <y> is the number of lines.  Either value may  be  missing,
**  to leave this value unaffected.  Note that those parameters can  also  be
**  set with the command line options '-x <x>' and '-y <y>'.
*/
static Obj FuncSizeScreen(Obj self, Obj args)
{
  Obj                 size;           /* argument and result list        */
  Obj                 elm;            /* one entry from size             */
  UInt                len;            /* length of lines on the screen   */
  UInt                nr;             /* number of lines on the screen   */

  RequireSmallList(SELF_NAME, args);
  if (1 < LEN_LIST(args)) {
      ErrorMayQuit("SizeScreen: number of arguments must be 0 or 1 (not %d)",
                   LEN_LIST(args), 0);
  }

  /* get the arguments                                                   */
  if ( LEN_LIST(args) == 0 ) {
    size = NEW_PLIST( T_PLIST, 0 );
  }

  /* otherwise check the argument                                        */
  else {
    size = ELM_LIST( args, 1 );
    if (!IS_SMALL_LIST(size) || 2 < LEN_LIST(size)) {
        ErrorMayQuit("SizeScreen: <size> must be a list of length at most 2",
                     0, 0);
    }
  }

  /* extract the length                                                  */
  if ( LEN_LIST(size) < 1 || ELM0_LIST(size,1) == 0 ) {
    len = 0;
  }
  else {
    elm = ELMW_LIST(size,1);
    len = GetSmallIntEx("SizeScreen", elm, "<x>");
    if ( len < 20  )  len = 20;
    if ( MAXLENOUTPUTLINE < len )  len = MAXLENOUTPUTLINE;
  }

  /* extract the number                                                  */
  elm = ELM0_LIST(size, 2);
  if ( elm == 0 ) {
    nr = 0;
  }
  else {
    nr = GetSmallIntEx("SizeScreen", elm, "<y>");
    if ( nr < 10 )  nr = 10;
  }

  /* set length and number                                               */
  if (len != 0)
    {
      SyNrCols = len;
      SyNrColsLocked = 1;
    }
  if (nr != 0)
    {
      SyNrRows = nr;
      SyNrRowsLocked = 1;
    }

  /* make and return the size of the screen                              */
  size = NEW_PLIST( T_PLIST, 2 );
  PushPlist(size, ObjInt_UInt(SyNrCols));
  PushPlist(size, ObjInt_UInt(SyNrRows));
  return size;

}


/****************************************************************************
**
*F  FuncWindowCmd( <self>, <args> ) . . . . . . . .  execute a window command
*/
static Obj WindowCmdString;

static Obj FuncWindowCmd(Obj self, Obj args)
{
  Obj             tmp;
  Obj               list;
  Int             len;
  Int             n,  m;
  Int             i;
  Char *          ptr;
  const Char *    inptr;
  const Char *    qtr;

  RequireSmallList(SELF_NAME, args);
  tmp = ELM_LIST(args, 1);
  if (!IsStringConv(tmp)) {
      RequireArgumentEx(SELF_NAME, tmp, "<cmd>", "must be a string");
  }
    if ( 3 != LEN_LIST(tmp) ) {
        ErrorMayQuit("WindowCmd: <cmd> must be a string of length 3", 0, 0);
    }

  /* compute size needed to store argument string                        */
  len = 13;
  for ( i = 2;  i <= LEN_LIST(args);  i++ )
    {
      tmp = ELM_LIST( args, i );
      if (!IS_INTOBJ(tmp) && !IsStringConv(tmp)) {
          ErrorMayQuit("WindowCmd: the argument in position %d must be a "
                       "string or integer (not a %s)",
                       i, (Int)TNAM_OBJ(tmp));
          SET_ELM_PLIST(args, i, tmp);
      }
      if ( IS_INTOBJ(tmp) )
        len += 12;
      else
        len += 12 + LEN_LIST(tmp);
    }
  if ( SIZE_OBJ(WindowCmdString) <= len ) {
    ResizeBag( WindowCmdString, 2*len+1 );
  }

  /* convert <args> into an argument string                              */
  ptr  = (Char*) CSTR_STRING(WindowCmdString);

  /* first the command name                                              */
  memcpy( ptr, CONST_CSTR_STRING( ELM_LIST(args,1) ), 3 + 1 );
  ptr += 3;

  /* and now the arguments                                               */
  for ( i = 2;  i <= LEN_LIST(args);  i++ )
    {
      tmp = ELM_LIST(args,i);

      if ( IS_INTOBJ(tmp) ) {
        *ptr++ = 'I';
        m = INT_INTOBJ(tmp);
        for ( m = (m<0)?-m:m;  0 < m;  m /= 10 )
          *ptr++ = (m%10) + '0';
        if ( INT_INTOBJ(tmp) < 0 )
          *ptr++ = '-';
        else
          *ptr++ = '+';
      }
      else {
        *ptr++ = 'S';
        m = LEN_LIST(tmp);
        for ( ; 0 < m;  m/= 10 )
          *ptr++ = (m%10) + '0';
        *ptr++ = '+';
        qtr = CONST_CSTR_STRING(tmp);
        for ( m = LEN_LIST(tmp);  0 < m;  m-- )
          *ptr++ = *qtr++;
      }
    }
  *ptr = 0;

  /* now call the window front end with the argument string              */
  qtr = CONST_CSTR_STRING(WindowCmdString);
  inptr = SyWinCmd( qtr, strlen(qtr) );
  len = strlen(inptr);

  /* now convert result back into a list                                 */
  list = NEW_PLIST( T_PLIST, 11 );
  i = 1;
  while ( 0 < len ) {
    if ( *inptr == 'I' ) {
      inptr++;
      for ( n=0,m=1; '0' <= *inptr && *inptr <= '9'; inptr++,m *= 10,len-- )
        n += (*inptr-'0') * m;
      if ( *inptr++ == '-' )
        n *= -1;
      len -= 2;
      AssPlist( list, i, INTOBJ_INT(n) );
    }
    else if ( *inptr == 'S' ) {
      inptr++;
      for ( n=0,m=1;  '0' <= *inptr && *inptr <= '9';  inptr++,m *= 10,len-- )
        n += (*inptr-'0') * m;
      inptr++; /* ignore the '+' */
      tmp = MakeImmStringWithLen(inptr, n);
      inptr += n;
      len -= n+2;
      AssPlist( list, i, tmp );
    }
    else {
      ErrorQuit( "unknown return value '%s'", (Int)inptr, 0 );
    }
    i++;
  }

  /* if the first entry is one signal an error */
  if ( ELM_LIST(list,1) == INTOBJ_INT(1) ) {
      tmp = MakeString("window system: ");
      SET_ELM_PLIST(list, 1, tmp);
      SET_LEN_PLIST(list, i - 1);
      return CALL_XARGS(Error, list);
  }
  else {
    for ( m = 1;  m <= i-2;  m++ )
      SET_ELM_PLIST( list, m, ELM_PLIST(list,m+1) );
    SET_LEN_PLIST( list, i-2 );
    return list;
  }
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * debug functions  * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncGASMAN( <self>, <args> )  . . . . . . . . .  expert function 'GASMAN'
**
**  'FuncGASMAN' implements the internal function 'GASMAN'
**
**  'GASMAN( "display" | "clear" | "collect" | "message" | "partial" )'
*/
static Obj FuncGASMAN(Obj self, Obj args)
{
    if ( ! IS_SMALL_LIST(args) || LEN_LIST(args) == 0 ) {
        ErrorMayQuit(
            "usage: GASMAN( \"display\"|\"displayshort\"|\"clear\"|\"collect\"|\"message\"|\"partial\" )",
            0, 0);
    }

    /* loop over the arguments                                             */
    for ( UInt i = 1; i <= LEN_LIST(args); i++ ) {

        /* evaluate and check the command                                  */
        Obj cmd = ELM_PLIST( args, i );
        RequireStringRep(SELF_NAME, cmd);

        // perform full garbage collection
        if (streq(CONST_CSTR_STRING(cmd), "collect")) {
            CollectBags(0,1);
        }

        // perform partial garbage collection
        else if (streq(CONST_CSTR_STRING(cmd), "partial")) {
            CollectBags(0,0);
        }

#if !defined(USE_GASMAN)
        else {
            ErrorMayQuit("GASMAN: <cmd> must be \"collect\" or \"partial\"",
                         0, 0);
        }

#else

        /* if request display the statistics                               */
        else if (streq(CONST_CSTR_STRING(cmd), "display")) {
#ifdef COUNT_BAGS
            Pr("%40s ", (Int)"type", 0);
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( UInt k = 0; k < NUM_TYPES; k++ ) {
                if ( TNAM_TNUM(k) != 0 ) {
                    Char buf[41];
                    buf[0] = '\0';
                    gap_strlcat( buf, TNAM_TNUM(k), sizeof(buf) );
                    Pr("%40s ",    (Int)buf, 0);
                    Pr("%8d %8d ", (Int)InfoBags[k].nrLive,
                                   (Int)(InfoBags[k].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[k].nrAll,
                                   (Int)(InfoBags[k].sizeAll/1024));
                }
            }
#endif
        }

        /* if request give a short display of the statistics                */
        else if (streq(CONST_CSTR_STRING(cmd), "displayshort")) {
#ifdef COUNT_BAGS
            Pr("%40s ", (Int)"type", 0);
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( UInt k = 0; k < NUM_TYPES; k++ ) {
                if ( TNAM_TNUM(k) != 0 && 
                     (InfoBags[k].nrLive != 0 ||
                      InfoBags[k].sizeLive != 0 ||
                      InfoBags[k].nrAll != 0 ||
                      InfoBags[k].sizeAll != 0) ) {
                    Char buf[41];
                    buf[0] = '\0';
                    gap_strlcat( buf, TNAM_TNUM(k), sizeof(buf) );
                    Pr("%40s ",    (Int)buf, 0);
                    Pr("%8d %8d ", (Int)InfoBags[k].nrLive,
                                   (Int)(InfoBags[k].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[k].nrAll,
                                   (Int)(InfoBags[k].sizeAll/1024));
                }
            }
#endif
        }

        /* if request display the statistics                               */
        else if (streq(CONST_CSTR_STRING(cmd), "clear")) {
#ifdef COUNT_BAGS
            for ( UInt k = 0; k < NUM_TYPES; k++ ) {
#ifdef GASMAN_CLEAR_TO_LIVE
                InfoBags[k].nrAll    = InfoBags[k].nrLive;
                InfoBags[k].sizeAll  = InfoBags[k].sizeLive;
#else
                InfoBags[k].nrAll    = 0;
                InfoBags[k].sizeAll  = 0;
#endif
            }
#endif
        }

        /* or display information about global bags                        */
        else if (streq(CONST_CSTR_STRING(cmd), "global")) {
            for ( i = 0;  i < GlobalBags.nr;  i++ ) {
                Bag bag = *(GlobalBags.addr[i]);
                if (bag != 0) {
                    const UInt sz = ((Int)bag & 3) ? 0 : SIZE_BAG(bag);
                    Pr("%50s: %12d bytes\n", (Int)GlobalBags.cookie[i], sz);
                }
                else {
                    Pr("%50s: not allocated\n", (Int)GlobalBags.cookie[i], 0);
                }
            }
        }

        /* or finally toggle Gasman messages                               */
        else if (streq(CONST_CSTR_STRING(cmd), "message")) {
            SyMsgsFlagBags = (SyMsgsFlagBags + 1) % 3;
        }

        /* otherwise complain                                              */
        else {
            ErrorMayQuit("GASMAN: <cmd> must be "
                         "\"display\" or \"clear\" or \"global\" or "
                         "\"collect\" or \"partial\" or \"message\"", 0, 0);
        }
#endif // USE_GASMAN
    }

    return 0;
}

#ifdef USE_GASMAN
static Obj FuncGASMAN_STATS(Obj self)
{
  Obj res;
  Obj row;
  UInt i,j;
  Int x;
  res = NEW_PLIST_IMM(T_PLIST_TAB_RECT, 2);
  SET_LEN_PLIST(res, 2);
  for (i = 1; i <= 2; i++)
    {
      row = NEW_PLIST_IMM(T_PLIST_CYC, 9);
      SET_ELM_PLIST(res, i, row);
      CHANGED_BAG(res);
      SET_LEN_PLIST(row, 9);
      for (j = 1; j <= 8; j++)
        {
          x = SyGasmanNumbers[i-1][j];
          SET_ELM_PLIST(row, j, ObjInt_Int(x));
        }
      SET_ELM_PLIST(row, 9, INTOBJ_INT(SyGasmanNumbers[i-1][0]));       
    }
  return res;      
}

static Obj FuncGASMAN_MESSAGE_STATUS(Obj self)
{
    return ObjInt_UInt(SyMsgsFlagBags);
}
#endif

static Obj FuncGASMAN_LIMITS(Obj self)
{
  Obj list;
  list = NEW_PLIST_IMM(T_PLIST_CYC, 3);
#ifdef USE_GASMAN
  ASS_LIST(list, 1, ObjInt_Int(SyStorMin));
  ASS_LIST(list, 2, ObjInt_Int(SyStorMax));
#endif
#if defined(USE_GASMAN) || defined(USE_BOEHM_GC)
  ASS_LIST(list, 3, ObjInt_Int(SyStorKill));
#endif
  return list;
}

#ifdef GAP_MEM_CHECK

static Obj FuncGASMAN_MEM_CHECK(Obj self, Obj newval)
{
    EnableMemCheck = INT_INTOBJ(newval);
    return 0;
}

#endif


static Obj FuncTOTAL_GC_TIME(Obj self)
{
    return ObjInt_UInt8(TotalGCTime());
}

/****************************************************************************
**
*F  FuncTotalMemoryAllocated( <self> ) .expert function 'TotalMemoryAllocated'
*/
static Obj FuncTotalMemoryAllocated(Obj self)
{
    return ObjInt_UInt8(SizeAllBags);
}

/****************************************************************************
**
*F  FuncSIZE_OBJ( <self>, <obj> ) . . . .  expert function 'SIZE_OBJ'
**
**  'SIZE_OBJ( <obj> )' returns 0 for immediate objects, and otherwise
**  returns the bag size of the object. This does not include the size of
**  sub-objects.
*/
static Obj FuncSIZE_OBJ(Obj self, Obj obj)
{
    if (IS_INTOBJ(obj) || IS_FFE(obj))
        return INTOBJ_INT(0);
    return ObjInt_UInt(SIZE_OBJ(obj));
}

/****************************************************************************
**
*F  FuncTNUM_OBJ( <self>, <obj> ) . . . . . . . .  expert function 'TNUM_OBJ'
*/
static Obj FuncTNUM_OBJ(Obj self, Obj obj)
{
    return INTOBJ_INT(TNUM_OBJ(obj));
}

/****************************************************************************
**
*F  FuncTNAM_OBJ( <self>, <obj> ) . . . . . . . .  expert function 'TNAM_OBJ'
*/
static Obj FuncTNAM_OBJ(Obj self, Obj obj)
{
    return MakeImmString(TNAM_OBJ(obj));
}

/****************************************************************************
**
*F  FuncOBJ_HANDLE( <self>, <handle> ) . . . . . expert function 'OBJ_HANDLE'
*/
static Obj FuncOBJ_HANDLE(Obj self, Obj handle)
{
    if (handle != INTOBJ_INT(0) && !IS_POS_INT(handle))
        RequireArgument(SELF_NAME, handle, "must be a non-negative integer");
    return (Obj)UInt_ObjInt(handle);
}

/****************************************************************************
**
*F  FuncHANDLE_OBJ( <self>, <obj> ) . . . . . .  expert function 'HANDLE_OBJ'
**
**  This is a very quick function which returns a unique integer for each
**  object non-identical objects will have different handles. The integers
**  may be large.
*/
static Obj FuncHANDLE_OBJ(Obj self, Obj obj)
{
    return ObjInt_UInt((UInt) obj);
}

/* This function does quite  a similar job to HANDLE_OBJ, but (a) returns 0
for all immediate objects (small integers or ffes) and (b) returns reasonably
small results (roughly in the range from 1 to the max number of objects that
have existed in this session. In HPC-GAP it returns almost the same value as
HANDLE_OBJ for non-immediate objects, but divided by sizeof(Obj), which gets
rid of a few zero bits and thus increases the chance of the result value
fitting into an immediate integer. */

static Obj FuncMASTER_POINTER_NUMBER(Obj self, Obj o)
{
    if (IS_INTOBJ(o) || IS_FFE(o)) {
        return INTOBJ_INT(0);
    }
#ifdef USE_GASMAN
    if ((void **) o >= (void **) MptrBags && (void **) o < (void **) MptrEndBags) {
        return ObjInt_UInt(((void **)o - (void **)MptrBags) + 1);
    } else {
        return INTOBJ_INT(0);
    }
#else
    return ObjInt_UInt((UInt)o / sizeof(Obj));
#endif
}


// Common code in the next 3 methods.
static int SetExitValue(Obj code)
{
  if (code == False || code == Fail)
    SystemErrorCode = 1;
  else if (code == True)
    SystemErrorCode = 0;
  else if (IS_INTOBJ(code))
    SystemErrorCode = INT_INTOBJ(code);
  else
    return 0;
  return 1;
}

/****************************************************************************
**
*F  FuncGapExitCode() . . . . . . . . Set the code with which GAP exits.
**
*/

static Obj FuncGapExitCode(Obj self, Obj args)
{
    if (LEN_LIST(args) > 1) {
        ErrorQuit("usage: GapExitCode( [ <return value> ] )", 0, 0);
    }

    Obj prev_exit_value = ObjInt_Int(SystemErrorCode);

    if (LEN_LIST(args) == 1) {
        Obj code = ELM_PLIST(args, 1);
        RequireArgumentCondition("GapExitCode", code, SetExitValue(code),
                                 "Argument must be boolean or integer");
    }
    return (Obj)prev_exit_value;
}


/****************************************************************************
**
*F  FuncQuitGap()
**
*/

static Obj FuncQuitGap(Obj self, Obj args)
{
  if ( LEN_LIST(args) == 0 ) {
    SystemErrorCode = 0;
  }
  else if ( LEN_LIST(args) != 1 
            || !SetExitValue(ELM_PLIST(args, 1) ) ) {
    ErrorQuit( "usage: QuitGap( [ <return value> ] )", 0, 0);
  }
  STATE(UserHasQUIT) = TRUE;
  GAP_THROW();
  return (Obj)0; 
}

/****************************************************************************
**
*F  FuncForceQuitGap()
**
*/

static Obj FuncForceQuitGap(Obj self, Obj args)
{
  if ( LEN_LIST(args) == 0 )
  {
    SyExit(SystemErrorCode);
  }
  else if ( LEN_LIST(args) != 1 
            || !SetExitValue(ELM_PLIST(args, 1) ) ) {
    ErrorQuit( "usage: ForceQuitGap( [ <return value> ] )", 0, 0);
  }
  SyExit(SystemErrorCode);
}

/****************************************************************************
**
*F  FuncSHOULD_QUIT_ON_BREAK()
**
*/

static Obj FuncSHOULD_QUIT_ON_BREAK(Obj self)
{
  return SyQuitOnBreak ? True : False;
}

/****************************************************************************
**
*F  KERNEL_INFO() ......................record of information from the kernel
** 
** The general idea is to put all kernel-specific info in here, and clean up
** the assortment of global variables previously used
*/

static Obj FuncKERNEL_INFO(Obj self)
{
    Obj  res = NEW_PREC(0);
    UInt r;
    Obj  tmp;
    UInt i;

    AssPRec(res, RNamName("GAP_ARCHITECTURE"), MakeImmString(GAPARCH));
    AssPRec(res, RNamName("KERNEL_VERSION"), MakeImmString(SyKernelVersion));
    AssPRec(res, RNamName("KERNEL_API_VERSION"), INTOBJ_INT(GAP_KERNEL_API_VERSION));
    AssPRec(res, RNamName("BUILD_VERSION"), MakeImmString(SyBuildVersion));
    AssPRec(res, RNamName("BUILD_DATETIME"), MakeImmString(SyBuildDateTime));
    AssPRec(res, RNamName("RELEASEDAY"), MakeImmString(SyReleaseDay));
    AssPRec(res, RNamName("GAP_ROOT_PATHS"), SyGetGapRootPaths());
    AssPRec(res, RNamName("DOT_GAP_PATH"), MakeImmString(SyDotGapPath()));

    // Get OS Kernel Release info
    AssPRec(res, RNamName("uname"), SyGetOsRelease());

    // make command line available to GAP level
    tmp = NEW_PLIST_IMM(T_PLIST, 16);
    for (i = 0; SyOriginalArgv[i]; i++) {
        PushPlist(tmp, MakeImmString(SyOriginalArgv[i]));
    }
    AssPRec(res, RNamName("COMMAND_LINE"), tmp);

    // make environment available to GAP level
    tmp = NEW_PREC(0);
    for (i = 0; environ[i]; i++) {
        Char * p = strchr(environ[i], '=');
        if (!p) {
            // should never happen...
            // FIXME: should we print a warning here?
            continue;
        }
        r = RNamNameWithLen(environ[i], p - environ[i]);
        p++; /* Move pointer behind = character */
        AssPRec(tmp, r, MakeImmString(p));
    }
    AssPRec(res, RNamName("ENVIRONMENT"), tmp);

#ifdef HPCGAP
    AssPRec(res, RNamName("NUM_CPUS"), INTOBJ_INT(SyNumProcessors));
#endif

    // export if we want to use readline
    AssPRec(res, RNamName("HAVE_LIBREADLINE"), SyUseReadline ? True : False);

    // export GMP version
    AssPRec(res, RNamName("GMP_VERSION"), MakeImmString(gmp_version));

    // export name of the garbage collector we use
#if defined(USE_GASMAN)
    tmp = MakeImmString("GASMAN");
#elif defined(USE_BOEHM_GC)
    tmp = MakeImmString("Boehm GC");
#elif defined(USE_JULIA_GC)
    tmp = MakeImmString("Julia GC");
#else
#error Unsupported garbage collector
#endif
    AssPRec(res, RNamName("GC"), tmp);

#ifdef USE_JULIA_GC
    // export Julia version
    AssPRec(res, RNamName("JULIA_VERSION"), MakeImmString(jl_ver_string()));
#endif

    r = RNamName("KernelDebug");
#ifdef GAP_KERNEL_DEBUG
    AssPRec(res, r, True);
#else
    AssPRec(res, r, False);
#endif

    r = RNamName("MemCheck");
#ifdef GAP_MEM_CHECK
    AssPRec(res, r, True);
#else
    AssPRec(res, r, False);
#endif

    MakeImmutable(res);

    return res;
}

/****************************************************************************
**
*F FuncBREAKPOINT . . . . . . . . . . . . Mark kernel breakpoints in GAP code
**
** The purpose behind this function is to mark positions in the GAP code
** and to transfer a stage flag to the kernel in a way that facilitates
** the use of kernel breakpoints depending on GAP state.
**
** One use case is to simply insert BREAKPOINT(0) at a specific GAP
** source location and then set a breakpoint on FuncBREAKPOINT in the
** kernel.
**
** The function accepts any argument; if it is a small integer, it will be
** converted and stored in the global variable BreakPointValue. This
** also allows the encoding of GAP state in that value and to attach a
** condition based on the value of BreakPointValue to other breakpoints.
*/

static UInt BreakPointValue;

static Obj FuncBREAKPOINT(Obj self, Obj arg)
{
    if (IS_INTOBJ(arg))
        BreakPointValue = INT_INTOBJ(arg);
    return (Obj)0;
}

#ifdef HPCGAP

/****************************************************************************
**
*F FuncTHREAD_UI  ... Whether we use a multi-threaded interface
**
*/

static Obj FuncTHREAD_UI(Obj self)
{
    return (ThreadUI && !SingleThreadStartup) ? True : False;
}

/****************************************************************************
**
*F  FuncSINGLE_THREAD_STARTUP . . whether to start up in single-threaded mode
**
*/

static Obj FuncSINGLE_THREAD_STARTUP(Obj self)
{
    return SingleThreadStartup ? True : False;
}

#endif

void UpdateLast(Obj newLast)
{
    AssGVarWithoutReadOnlyCheck(Last3, ValGVarTL(Last2));
    AssGVarWithoutReadOnlyCheck(Last2, ValGVarTL(Last));
    AssGVarWithoutReadOnlyCheck(Last, newLast);
}

void UpdateTime(UInt startTime)
{
    AssGVarWithoutReadOnlyCheck(Time, ObjInt_Int(SyTime() - startTime));
}


// UPDATE_STAT lets code assign the special variables which GAP
// automatically sets in interactive sessions. This is for demonstration
// code which wants to look like iteractive usage of GAP. Using this
// function will not stop GAP automatically changing these variables as
// usual.
static Obj FuncUPDATE_STAT(Obj self, Obj name, Obj newStat)
{
    RequireStringRep(SELF_NAME, name);

    const char * cname = CONST_CSTR_STRING(name);
    if (streq(cname, "time")) {
        AssGVarWithoutReadOnlyCheck(Time, newStat);
    }
    else if (streq(cname, "last")) {
        AssGVarWithoutReadOnlyCheck(Last, newStat);
    }
    else if (streq(cname, "last2")) {
        AssGVarWithoutReadOnlyCheck(Last2, newStat);
    }
    else if (streq(cname, "last3")) {
        AssGVarWithoutReadOnlyCheck(Last3, newStat);
    }
    else if (streq(cname, "memory_allocated")) {
        AssGVarWithoutReadOnlyCheck(MemoryAllocated, newStat);
    }
    else {
        ErrorMayQuit("UPDATE_STAT: unsupported <name> value '%g'", (Int)name, 0);
    }
    return 0;
}


static Obj FuncSetAssertionLevel(Obj self, Obj level)
{
    RequireNonnegativeSmallInt(SELF_NAME, level);
    STATE(CurrentAssertionLevel) = INT_INTOBJ(level);
    return 0;
}


static Obj FuncAssertionLevel(Obj self)
{
    return INTOBJ_INT(STATE(CurrentAssertionLevel));
}


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(SizeScreen, -1, "args"),
    GVAR_FUNC_1ARGS(ID_FUNC, object),
    GVAR_FUNC(RETURN_FIRST, -2, "first, rest"),
    GVAR_FUNC(RETURN_NOTHING, -1, "object"),
    GVAR_FUNC(GASMAN, -1, "args"),
#ifdef USE_GASMAN
    GVAR_FUNC_0ARGS(GASMAN_STATS),
    GVAR_FUNC_0ARGS(GASMAN_MESSAGE_STATUS),
#endif
    GVAR_FUNC_0ARGS(GASMAN_LIMITS),
#ifdef GAP_MEM_CHECK
    GVAR_FUNC_1ARGS(GASMAN_MEM_CHECK, int),
#endif
    GVAR_FUNC_0ARGS(TOTAL_GC_TIME),
    GVAR_FUNC_0ARGS(TotalMemoryAllocated),
    GVAR_FUNC_1ARGS(SIZE_OBJ, object),
    GVAR_FUNC_1ARGS(TNUM_OBJ, object),
    GVAR_FUNC_1ARGS(TNAM_OBJ, object),
    GVAR_FUNC_1ARGS(OBJ_HANDLE, handle),
    GVAR_FUNC_1ARGS(HANDLE_OBJ, object),
    GVAR_FUNC_1ARGS(WindowCmd, args),
    GVAR_FUNC(GapExitCode, -1, "exitCode"),
    GVAR_FUNC(QuitGap, -1, "args"),
    GVAR_FUNC(ForceQuitGap, -1, "args"),
    GVAR_FUNC_0ARGS(SHOULD_QUIT_ON_BREAK),
    GVAR_FUNC_6ARGS(SHELL,
                    context,
                    canReturnVoid,
                    canReturnObj,
                    breakLoop,
                    prompt,
                    preCommandHook),
    GVAR_FUNC_0ARGS(KERNEL_INFO),
#ifdef HPCGAP
    GVAR_FUNC_0ARGS(THREAD_UI),
    GVAR_FUNC_0ARGS(SINGLE_THREAD_STARTUP),
#endif
    GVAR_FUNC_1ARGS(MASTER_POINTER_NUMBER, ob),
    GVAR_FUNC_1ARGS(BREAKPOINT, integer),
    GVAR_FUNC_2ARGS(UPDATE_STAT, string, object),

    GVAR_FUNC_1ARGS(SetAssertionLevel, level),
    GVAR_FUNC_0ARGS(AssertionLevel),

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* list of exit functions                                              */
    InitGlobalBag( &WindowCmdString, "src/gap.c:WindowCmdString" );

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* establish Fopy of ViewObj                                           */
    ImportFuncFromLibrary(  "ViewObj", 0 );
    ImportFuncFromLibrary(  "Error", &Error );
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    /* construct the `ViewObj' variable                                    */
    ViewObjGVar = GVarName( "ViewObj" );

    /* construct the last and time variables                               */
    Last              = GVarName( "last"  );
    Last2             = GVarName( "last2" );
    Last3             = GVarName( "last3" );
    Time              = GVarName( "time"  );
    MemoryAllocated   = GVarName( "memory_allocated"  );

    QUITTINGGVar      = GVarName( "QUITTING" );

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* create windows command buffer                                       */
    WindowCmdString = NEW_STRING( 1000 );

#ifdef HPCGAP
    AssConstantGVar( GVarName( "HPCGAP" ), True );
    AssConstantGVar( GVarName( "IsHPCGAP" ), True );
#else
    AssConstantGVar( GVarName( "IsHPCGAP" ), False );
#endif

    AssReadOnlyGVar(GVarName("last"), Fail);
    AssReadOnlyGVar(GVarName("last2"), Fail);
    AssReadOnlyGVar(GVarName("last3"), Fail);
    AssReadOnlyGVar(GVarName("time"), INTOBJ_INT(0));
    AssReadOnlyGVar(GVarName("memory_allocated"), INTOBJ_INT(0));

    // ensure any legacy code which directly tries to set the former GAP
    // global 'CurrentAssertionLevel' or tries to compare to an integer,
    // runs into an error.
    AssConstantGVar(GVarName("CurrentAssertionLevel"), False);

    return PostRestore( module );
}


/****************************************************************************
**
*F  InitInfoGap() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "gap",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore
};

StructInitInfo * InitInfoGap ( void )
{
    return &module;
}


/****************************************************************************
**
*F  InitializeGap() . . . . . . . . . . . . . . . . . . . . . . intialize GAP
**
**  Each module  (builtin  or compiled) exports  a structure  which  contains
**  information about the name, version, crc, init function, save and restore
**  functions.
**
**  The init process is split into three different functions:
**
**  `InitKernel':   This function setups the   internal  data structures  and
**  tables,   registers the global bags  and   functions handlers, copies and
**  fopies.  It is not allowed to create objects, gvar or rnam numbers.  This
**  function is used for both starting and restoring.
**
**  `InitLibrary': This function creates objects,  gvar and rnam number,  and
**  does  assignments of auxiliary C   variables (for example, pointers  from
**  objects, length of hash lists).  This function is only used for starting.
**
**  `PostRestore': Everything in  `InitLibrary' execpt  creating objects.  In
**  general    `InitLibrary'  will  create    all objects    and  then  calls
**  `PostRestore'.  This function is only used when restoring.
*/
static Obj POST_RESTORE;

void InitializeGap (
    int *               pargc,
    char *              argv [],
    UInt                handleSignals )
{
    /* initialize the basic system and gasman                              */
    InitSystem( *pargc, argv, handleSignals );

    /* Initialise memory  -- have to do this here to make sure we are at top of C stack */
    InitBags(
#if defined(USE_GASMAN)
        SyStorMin,
#else
        0,
#endif
             (Bag *)(((UInt)pargc / C_STACK_ALIGN) * C_STACK_ALIGN));

    STATE(UserHasQUIT) = FALSE;
    STATE(UserHasQuit) = FALSE;
    STATE(JumpToCatchCallback) = 0;

    // get info structures for the built in modules
    ModulesSetup();

    // call kernel initialisation
    ModulesInitKernel();

#ifdef HPCGAP
    InitMainThread();
#endif

    InitGlobalBag(&POST_RESTORE, "gap.c: POST_RESTORE");
    InitFopyGVar( "POST_RESTORE", &POST_RESTORE);

#ifdef GAP_ENABLE_SAVELOAD
    if ( SyRestoring ) {

#ifdef COUNT_BAGS
        if (SyDebugLoading) {
            Pr("#W  after setup\n", 0, 0);
            Pr("#W  %36s ", (Int)"type", 0);
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( Int i = 0;  i < NUM_TYPES;  i++ ) {
                if ( TNAM_TNUM(i) != 0 && InfoBags[i].nrAll != 0 ) {
                    char    buf[41];

                    buf[0] = '\0';
                    gap_strlcat( buf, TNAM_TNUM(i), sizeof(buf) );
                    Pr("#W  %36s ",    (Int)buf, 0);
                    Pr("%8d %8d ", (Int)InfoBags[i].nrLive,
                       (Int)(InfoBags[i].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[i].nrAll,
                       (Int)(InfoBags[i].sizeAll/1024));
                }
            }
        }
#endif

        // we are restoring, load the workspace and call the post restore
        ModulesInitModuleState();
        LoadWorkspace(SyRestoring);
        SyRestoring = NULL;

        /* Call POST_RESTORE which is a GAP function that now takes control, 
           calls the post restore functions and then runs a GAP session */
        if (POST_RESTORE != 0 && IS_FUNC(POST_RESTORE)) {
          Call0ArgsInNewReader(POST_RESTORE);
        }

        return;
    }
#endif // GAP_ENABLE_SAVELOAD

    /* otherwise call library initialisation                               */
#ifdef USE_GASMAN
    CheckAllHandlers();
#endif

    SyInitializing = 1;
    ModulesInitLibrary();
    ModulesInitModuleState();

    /* check initialisation                                                */
    ModulesCheckInit();

    /* read the init files      
       this now actually runs the GAP session, we only get 
       past here when we're about to exit. 
                                           */
    if ( SyLoadSystemInitFile ) {
      GAP_TRY {
        if ( READ_GAP_ROOT("lib/init.g") == 0 ) {
                Pr( "gap: hmm, I cannot find 'lib/init.g' maybe",
                    0, 0);
                Pr( " use option '-l <gaproot>'?\n If you ran the GAP"
                    " binary directly, try running the 'gap.sh' or 'gap.bat'"
                    " script instead.", 0, 0);
            }
      }
      GAP_CATCH {
          Panic("Caught error at top-most level, probably quit from "
                "library loading");
      }
    }

}
