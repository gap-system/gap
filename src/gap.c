/****************************************************************************
**
*W  gap.c                       GAP source                       Frank Celler
*W                                                         & Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the various read-eval-print loops and  related  stuff.
*/

#include <src/gap.h>

#include <src/ariths.h>
#include <src/bool.h>
#include <src/calls.h>
#include <src/compiler.h>
#include <src/error.h>
#include <src/funcs.h>
#include <src/gapstate.h>
#include <src/gvars.h>
#include <src/integer.h>
#include <src/io.h>
#include <src/lists.h>
#include <src/modules.h>
#include <src/plist.h>
#include <src/precord.h>
#include <src/records.h>
#include <src/read.h>
#include <src/saveload.h>
#include <src/stats.h>   // for ClearError
#include <src/streams.h>
#include <src/stringobj.h>
#include <src/sysfiles.h>
#include <src/sysmem.h>
#include <src/vars.h>

#ifdef HPCGAP
#include <src/intrprtr.h>
#include <src/hpc/misc.h>
#include <src/hpc/thread.h>
#include <src/hpc/threadapi.h>
#endif


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
UInt Last;


/****************************************************************************
**
*V  Last2 . . . . . . . . . . . . . . . . . . . . . . global variable 'last2'
*/
UInt Last2;


/****************************************************************************
**
*V  Last3 . . . . . . . . . . . . . . . . . . . . . . global variable 'last3'
*/
UInt Last3;


/****************************************************************************
**
*V  Time  . . . . . . . . . . . . . . . . . . . . . . global variable  'time'
**
**  'Time' is the global variable 'time', which is automatically assigned the
**  time the last command took.
*/
UInt Time;

/****************************************************************************
**
*V  MemoryAllocated . . . . . . . . . . . global variable  'memory_allocated'
**
**  'MemoryAllocated' is the global variable 'memory_allocated', 
**  which is automatically assigned the amount of memory allocated while
**  executing the last command.
*/
UInt MemoryAllocated;


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
  volatile Obj        func;
  syJmp_buf             readJmpError;

  /* get the functions                                                   */
  func = ValAutoGVar(ViewObjGVar);

  /* if non-zero use this function, otherwise use `PrintObj'             */
  memcpy( readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf) );
  TRY_READ {
    if ( func != 0 && TNUM_OBJ(func) == T_FUNCTION ) {
      ViewObj(obj);
    }
    else {
      PrintObj( obj );
    }
    Pr( "\n", 0L, 0L );
  }
  memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
}


/****************************************************************************
**
*F  main( <argc>, <argv> )  . . . . . . .  main program, read-eval-print loop
*/
UInt QUITTINGGVar;


static char **sysenviron;

/*
TL: Obj ShellContext = 0;
TL: Obj BaseShellContext = 0;
*/

Obj Shell ( Obj context, 
            UInt canReturnVoid,
            UInt canReturnObj,
            UInt lastDepth,
            UInt setTime,
            Char *prompt,
            Obj preCommandHook,
            UInt catchQUIT,
            Char *inFile,
            Char *outFile)
{
  UInt time = 0;
  UInt8 mem = 0;
  UInt status;
  Obj evalResult;
  UInt dualSemicolon;
  UInt oldPrintDepth;
  Obj res;
  Obj oldShellContext;
  Obj oldBaseShellContext;
  Int oldRecursionDepth;
  oldShellContext = STATE(ShellContext);
  STATE(ShellContext) = context;
  oldBaseShellContext = STATE(BaseShellContext);
  STATE(BaseShellContext) = context;
  Int oldErrorLLevel = STATE(ErrorLLevel);
  STATE(ErrorLLevel) = 0;
  oldRecursionDepth = GetRecursionDepth();
  
  /* read-eval-print loop                                                */
  if (!OpenOutput(outFile))
      ErrorQuit("SHELL: can't open outfile %s",(Int)outFile,0);

  if(!OpenInput(inFile))
    {
      CloseOutput();
      ErrorQuit("SHELL: can't open infile %s",(Int)inFile,0);
    }
  
  oldPrintDepth = STATE(PrintObjDepth);
  STATE(PrintObjDepth) = 0;

  while ( 1 ) {

    /* start the stopwatch                                             */
    if (setTime) {
          time = SyTime();
          mem = SizeAllBags;
    }

    /* read and evaluate one command                                   */
    STATE(Prompt) = prompt;
    ClearError();
    STATE(PrintObjDepth) = 0;
    ResetOutputIndent();
    SetRecursionDepth(0);
      
    /* here is a hook: */
    if (preCommandHook) {
      if (!IS_FUNC(preCommandHook))
        {
                  Pr("#E CommandHook was non-function, ignoring\n",0L,0L);
        }
      else
        {
          Call0ArgsInNewReader(preCommandHook);
          /* Recover from a potential break loop: */
          STATE(Prompt) = prompt;
          ClearError();
        }
    }

    /* now  read and evaluate and view one command  */
    status = ReadEvalCommand(STATE(ShellContext), &evalResult, &dualSemicolon);
    if (STATE(UserHasQUIT))
      break;


    /* handle ordinary command                                         */
    if ( status == STATUS_END && evalResult != 0 ) {

      /* remember the value in 'last'    */
      if (lastDepth >= 3)
        AssGVar( Last3, ValGVarTL( Last2 ) );
      if (lastDepth >= 2)
        AssGVar( Last2, ValGVarTL( Last  ) );
      if (lastDepth >= 1)
        AssGVar( Last, evalResult );

      /* print the result                                            */
      if ( ! dualSemicolon ) {
        ViewObjHandler( evalResult );
      }
            
    }

    /* handle return-value or return-void command                      */
    else if (status & STATUS_RETURN_VAL) 
      if(canReturnObj)
        break;
      else
        Pr( "'return <object>' cannot be used in this read-eval-print loop\n",
            0L, 0L );

    else if (status & STATUS_RETURN_VOID) 
      if(canReturnVoid ) 
        break;
      else
        Pr( "'return' cannot be used in this read-eval-print loop\n",
            0L, 0L );
    
    /* handle quit command or <end-of-file>                            */
    else if ( status & (STATUS_EOF | STATUS_QUIT ) ) {
      SetRecursionDepth(0);
      STATE(UserHasQuit) = 1;
      break;
    }
        
    /* handle QUIT */
    else if (status & (STATUS_QQUIT)) {
      STATE(UserHasQUIT) = 1;
      break;
    }
        
    /* stop the stopwatch                                          */
    if (setTime) {
      AssGVar( Time, INTOBJ_INT( SyTime() - time ) );
      AssGVar(MemoryAllocated, ObjInt_Int8(SizeAllBags - mem));
    }

    if (STATE(UserHasQuit))
      {
        FlushRestOfInputLine();
        STATE(UserHasQuit) = 0;        /* quit has done its job if we are here */
      }

  }
  
  STATE(PrintObjDepth) = oldPrintDepth;
  CloseInput();
  CloseOutput();
  STATE(BaseShellContext) = oldBaseShellContext;
  STATE(ShellContext) = oldShellContext;
  STATE(ErrorLLevel) = oldErrorLLevel;
  SetRecursionDepth(oldRecursionDepth);

  if (STATE(UserHasQUIT))
    {
      if (catchQUIT)
        {
          STATE(UserHasQUIT) = 0;
          MakeReadWriteGVar(QUITTINGGVar);
          AssGVar(QUITTINGGVar, True);
          MakeReadOnlyGVar(QUITTINGGVar);
          return Fail;
        }
      else
        ReadEvalError();
    }

  if (status & (STATUS_EOF | STATUS_QUIT | STATUS_QQUIT))
    {
      return Fail;
    }
  if (status & STATUS_RETURN_VOID)
    {
      res = NEW_PLIST(T_PLIST_EMPTY,0);
      SET_LEN_PLIST(res,0);
      return res;
    }
  if (status & STATUS_RETURN_VAL)
    {
      res = NEW_PLIST(T_PLIST_HOM,1);
      SET_LEN_PLIST(res,1);
      SET_ELM_PLIST(res,1,evalResult);
      return res;
    }
  assert(0); 
  return (Obj) 0;
}



Obj FuncSHELL (Obj self, Obj args)
{
  Obj context = 0;
  UInt canReturnVoid = 0;
  UInt canReturnObj = 0;
  Int lastDepth = 0;
  UInt setTime = 0;
  Obj prompt = 0;
  Obj preCommandHook = 0;
  Obj infile;
  Obj outfile;
  Obj res;
  Char promptBuffer[81];
  UInt catchQUIT = 0;
  
  if (!IS_PLIST(args) || LEN_PLIST(args) != 10)
    ErrorMayQuit("SHELL takes 10 arguments",0,0);
  
  context = ELM_PLIST(args,1);
  if (!IS_LVARS_OR_HVARS(context))
    ErrorMayQuit("SHELL: 1st argument should be a local variables bag",0,0);
  
  if (ELM_PLIST(args,2) == True)
    canReturnVoid = 1;
  else if (ELM_PLIST(args,2) == False)
    canReturnVoid = 0;
  else
    ErrorMayQuit("SHELL: 2nd argument (can return void) should be true or false",0,0);

  if (ELM_PLIST(args,3) == True)
    canReturnObj = 1;
  else if (ELM_PLIST(args,3) == False)
    canReturnObj = 0;
  else
    ErrorMayQuit("SHELL: 3rd argument (can return object) should be true or false",0,0);
  
  if (!IS_INTOBJ(ELM_PLIST(args,4)))
    ErrorMayQuit("SHELL: 4th argument (last depth) should be a small integer",0,0);
  lastDepth = INT_INTOBJ(ELM_PLIST(args,4));
  if (lastDepth < 0 )
    {
      Pr("#W SHELL: negative last depth treated as zero\n",0,0);
      lastDepth = 0;
    }
  else if (lastDepth > 3 )
    {
      Pr("#W SHELL: last depth greater than 3 treated as 3\n",0,0);
      lastDepth = 3;
    }

  if (ELM_PLIST(args,5) == True)
    setTime = 1;
  else if (ELM_PLIST(args,5) == False)
    setTime = 0;
  else
    ErrorMayQuit("SHELL: 5th argument (set time) should be true or false",0,0);
  
  prompt = ELM_PLIST(args,6);
  if (!IsStringConv(prompt) || GET_LEN_STRING(prompt) > 80)
    ErrorMayQuit("SHELL: 6th argument (prompt) must be a string of length at most 80 characters",0,0);
  promptBuffer[0] = '\0';
  strlcat(promptBuffer, CSTR_STRING(prompt), sizeof(promptBuffer));

  preCommandHook = ELM_PLIST(args,7);
 
  if (preCommandHook == False)
    preCommandHook = 0;
  else if (!IS_FUNC(preCommandHook))
    ErrorMayQuit("SHELL: 7th argument (preCommandHook) must be function or false",0,0);

  
  infile = ELM_PLIST(args,8);
  if (!IsStringConv(infile))
    ErrorMayQuit("SHELL: 8th argument (infile) must be a string",0,0);

  outfile = ELM_PLIST(args,9);
  if (!IsStringConv(outfile))
    ErrorMayQuit("SHELL: 9th argument (outfile) must be a string",0,0);

  if (ELM_PLIST(args,10) == True)
    catchQUIT = 1;
  else if (ELM_PLIST(args,10) == False)
    catchQUIT = 0;
  else
    ErrorMayQuit("SHELL: 10th argument (catch QUIT) should be true or false",0,0);

  res =  Shell(context, canReturnVoid, canReturnObj, lastDepth, setTime, promptBuffer, preCommandHook, catchQUIT,
               CSTR_STRING(infile), CSTR_STRING(outfile));

  STATE(UserHasQuit) = 0;
  return res;
}

int realmain( int argc, char * argv[], char * environ[] )
{
  UInt                type;                   /* result of compile       */
  Obj                 func;                   /* function (compiler)     */
  Int4                crc;                    /* crc of file to compile  */

  SetupGAPLocation(argc, argv);

  /* initialize everything and read init.g which runs the GAP session */
  InitializeGap( &argc, argv, environ );
  if (!STATE(UserHasQUIT)) {         /* maybe the user QUIT from the initial
                                   read of init.g  somehow*/
    /* maybe compile in which case init.g got skipped */
    if ( SyCompilePlease ) {
      if ( ! OpenInput(SyCompileInput) ) {
        SyExit(1);
      }
      func = READ_AS_FUNC();
      crc  = SyGAPCRC(SyCompileInput);
      type = CompileFunc(
                         MakeImmString(SyCompileOutput),
                         func,
                         MakeImmString(SyCompileName),
                         crc,
                         MakeImmString(SyCompileMagic1) );
      if ( type == 0 )
        SyExit( 1 );
      SyExit( 0 );
    }
  }
  SyExit(SystemErrorCode);
  return 0;
}

#if !defined(COMPILECYGWINDLL)
int main ( int argc, char * argv[], char * environ[] )
{
#if defined(HAVE_BACKTRACE) && defined(PRINT_BACKTRACE)
  InstallBacktraceHandlers();
#endif

#ifdef HPCGAP
  RunThreadedMain(realmain, argc, argv, environ);
  return 0;
#else
  return realmain(argc, argv, environ);
#endif
}

#endif

/****************************************************************************
**
*F  FuncID_FUNC( <self>, <val1> ) . . . . . . . . . . . . . . . return <val1>
*/
Obj FuncID_FUNC (
                 Obj                 self,
                 Obj                 val1 )
{
  return val1;
}

/****************************************************************************
**
*F  FuncRETURN_FIRST( <self>, <args> ) . . . . . . . . Return first argument
*/
Obj FuncRETURN_FIRST (
                 Obj                 self,
                 Obj                 args )
{
  if (!IS_PLIST(args) || LEN_PLIST(args) < 1)
        ErrorMayQuit("RETURN_FIRST requires one or more arguments",0,0);

  return ELM_PLIST(args, 1);
}

/****************************************************************************
**
*F  FuncRETURN_NOTHING( <self>, <arg> ) . . . . . . . . . . . Return nothing
*/
Obj FuncRETURN_NOTHING (
                 Obj                 self,
                 Obj                 arg )
{
  return 0;
}


/****************************************************************************
**
*F  FuncRuntime( <self> ) . . . . . . . . . . . . internal function 'Runtime'
**
**  'FuncRuntime' implements the internal function 'Runtime'.
**
**  'Runtime()'
**
**  'Runtime' returns the time spent since the start of GAP in  milliseconds.
**  How much time execution of statements take is of course system dependent.
**  The accuracy of this number is also system dependent.
*/
Obj FuncRuntime (
                 Obj                 self )
{
  return INTOBJ_INT( SyTime() );
}


Obj FuncRUNTIMES( Obj     self)
{
  Obj    res;
  res = NEW_PLIST(T_PLIST, 4);
  SET_LEN_PLIST(res, 4);
  SET_ELM_PLIST(res, 1, INTOBJ_INT( SyTime() ));
  SET_ELM_PLIST(res, 2, INTOBJ_INT( SyTimeSys() ));
  SET_ELM_PLIST(res, 3, INTOBJ_INT( SyTimeChildren() ));
  SET_ELM_PLIST(res, 4, INTOBJ_INT( SyTimeChildrenSys() ));
  return res;
}


/****************************************************************************
**
*F  FuncNanosecondsSinceEpoch( <self> )
**
**  'FuncNanosecondsSinceEpoch' returns an integer which represents the
**  number of nanoseconds since some unspecified starting point. This
**  function wraps SyNanosecondsSinceEpoch.
**
*/
Obj FuncNanosecondsSinceEpoch(Obj self)
{
  Int8 val = SyNanosecondsSinceEpoch();

  if(val == -1) {
    return Fail;
  }
  else {
    return ObjInt_Int8(val);
  }
}

/****************************************************************************
**
*F  FuncNanosecondsSinceEpochInfo( <self> )
**
**  'FuncNanosecondsSinceEpochInformation' returns a plain record
**  contains information about the timers used for FuncNanosecondsSinceEpoch
**
*/
Obj FuncNanosecondsSinceEpochInfo(Obj self)
{
  Obj res, tmp;
  Int8 resolution;

  res = NEW_PREC(4);
  /* Note this has to be "DYN" since we're not passing a
     literal but a const char * */
  tmp = MakeImmString(SyNanosecondsSinceEpochMethod);
  AssPRec(res, RNamName("Method"), tmp);
  AssPRec(res, RNamName("Monotonic"),
               SyNanosecondsSinceEpochMonotonic ? True : False);
  resolution = SyNanosecondsSinceEpochResolution();
  if (resolution > 0) {
      AssPRec(res, RNamName("Resolution"), ObjInt_Int8(resolution));
      AssPRec(res, RNamName("Reliable"), True);
  } else if (resolution <= 0) {
      AssPRec(res, RNamName("Resolution"), ObjInt_Int8(-resolution));
      AssPRec(res, RNamName("Reliable"), False);
  }
  return res;
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
Obj FuncSizeScreen (
                    Obj                 self,
                    Obj                 args )
{
  Obj                 size;           /* argument and result list        */
  Obj                 elm;            /* one entry from size             */
  UInt                len;            /* length of lines on the screen   */
  UInt                nr;             /* number of lines on the screen   */

  /* check the arguments                                                 */
  while ( ! IS_SMALL_LIST(args) || 1 < LEN_LIST(args) ) {
    args = ErrorReturnObj(
                          "Function: number of arguments must be 0 or 1 (not %d)",
                          LEN_LIST(args), 0L,
                          "you can replace the argument list <args> via 'return <args>;'" );
  }

  /* get the arguments                                                   */
  if ( LEN_LIST(args) == 0 ) {
    size = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( size, 0 );
  }

  /* otherwise check the argument                                        */
  else {
    size = ELM_LIST( args, 1 );
    while ( ! IS_SMALL_LIST(size) || 2 < LEN_LIST(size) ) {
      size = ErrorReturnObj(
                            "SizeScreen: <size> must be a list of length 2",
                            0L, 0L,
                            "you can replace <size> via 'return <size>;'" );
    }
  }

  /* extract the length                                                  */
  if ( LEN_LIST(size) < 1 || ELM0_LIST(size,1) == 0 ) {
    len = 0;
  }
  else {
    elm = ELMW_LIST(size,1);
    while ( !IS_INTOBJ(elm) ) {
      elm = ErrorReturnObj(
                           "SizeScreen: <x> must be an integer",
                           0L, 0L,
                           "you can replace <x> via 'return <x>;'" );
    }
    len = INT_INTOBJ( elm );
    if ( len < 20  )  len = 20;
    if ( MAXLENOUTPUTLINE < len )  len = MAXLENOUTPUTLINE;
  }

  /* extract the number                                                  */
  if ( LEN_LIST(size) < 2 || ELM0_LIST(size,2) == 0 ) {
    nr = 0;
  }
  else {
    elm = ELMW_LIST(size,2);
    while ( !IS_INTOBJ(elm) ) {
      elm = ErrorReturnObj(
                           "SizeScreen: <y> must be an integer",
                           0L, 0L,
                           "you can replace <y> via 'return <y>;'" );
    }
    nr = INT_INTOBJ( elm );
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
  SET_LEN_PLIST( size, 2 );
  SET_ELM_PLIST( size, 1, INTOBJ_INT(SyNrCols) );
  SET_ELM_PLIST( size, 2, INTOBJ_INT(SyNrRows)  );
  return size;

}


/****************************************************************************
**
*F  FuncWindowCmd( <self>, <args> ) . . . . . . . .  execute a window command
*/
static Obj WindowCmdString;

Obj FuncWindowCmd (
                   Obj              self,
                   Obj             args )
{
  Obj             tmp;
  Obj               list;
  Int             len;
  Int             n,  m;
  Int             i;
  Char *          ptr;
  const Char *    inptr;
  Char *          qtr;

  /* check arguments                                                     */
  while ( ! IS_SMALL_LIST(args) ) {
    args = ErrorReturnObj( "argument list must be a list (not a %s)",
                           (Int)TNAM_OBJ(args), 0L,
                           "you can replace the argument list <args> via 'return <args>;'" );

  }
  tmp = ELM_LIST(args,1);
  while ( ! IsStringConv(tmp) || 3 != LEN_LIST(tmp) ) {
    while ( ! IsStringConv(tmp) ) {
      tmp = ErrorReturnObj( "<cmd> must be a string (not a %s)",
                            (Int)TNAM_OBJ(tmp), 0L,
                            "you can replace <cmd> via 'return <cmd>;'" );
    }
    if ( 3 != LEN_LIST(tmp) ) {
      tmp = ErrorReturnObj( "<cmd> must be a string of length 3",
                            0L, 0L,
                            "you can replace <cmd> via 'return <cmd>;'" );
    }
  }

  /* compute size needed to store argument string                        */
  len = 13;
  for ( i = 2;  i <= LEN_LIST(args);  i++ )
    {
      tmp = ELM_LIST( args, i );
      while ( !IS_INTOBJ(tmp) && ! IsStringConv(tmp) ) {
        tmp = ErrorReturnObj(
                             "%d. argument must be a string or integer (not a %s)",
                             i, (Int)TNAM_OBJ(tmp),
                             "you can replace the argument <arg> via 'return <arg>;'" );
        SET_ELM_PLIST( args, i, tmp );
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
  memcpy( ptr, CSTR_STRING( ELM_LIST(args,1) ), 3 + 1 );
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
        qtr = CSTR_STRING(tmp);
        for ( m = LEN_LIST(tmp);  0 < m;  m-- )
          *ptr++ = *qtr++;
      }
    }
  *ptr = 0;

  /* now call the window front end with the argument string              */
  qtr = CSTR_STRING(WindowCmdString);
  inptr = SyWinCmd( qtr, strlen(qtr) );
  len = strlen(inptr);

  /* now convert result back into a list                                 */
  list = NEW_PLIST( T_PLIST, 11 );
  SET_LEN_PLIST( list, 0 );
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
      C_NEW_STRING(tmp, n, inptr);
      inptr += n;
      len -= n+2;
      AssPlist( list, i, tmp );
    }
    else {
      ErrorQuit( "unknown return value '%s'", (Int)inptr, 0 );
      return 0;
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
Obj FuncGASMAN (
    Obj                 self,
    Obj                 args )
{
    /* check the argument                                                  */
    if ( ! IS_SMALL_LIST(args) || LEN_LIST(args) == 0 ) {
        ErrorMayQuit(
            "usage: GASMAN( \"display\"|\"displayshort\"|\"clear\"|\"collect\"|\"message\"|\"partial\" )",
            0L, 0L);
    }

    /* loop over the arguments                                             */
    for ( UInt i = 1; i <= LEN_LIST(args); i++ ) {

        /* evaluate and check the command                                  */
        Obj cmd = ELM_PLIST( args, i );
again:
        while ( ! IsStringConv(cmd) ) {
           cmd = ErrorReturnObj(
               "GASMAN: <cmd> must be a string (not a %s)",
               (Int)TNAM_OBJ(cmd), 0L,
               "you can replace <cmd> via 'return <cmd>;'" );
       }

#if !defined(USE_GASMAN)
        if ( strcmp( CSTR_STRING(cmd), "collect" ) == 0 ) {
            CollectBags(0,1);
        }
        else {
            cmd = ErrorReturnObj(
                "GASMAN: <cmd> must be \"collect\"", 0L, 0L,
                "you can replace <cmd> via 'return <cmd>;'" );
            goto again;
        }

#else

        /* if request display the statistics                               */
        if ( strcmp( CSTR_STRING(cmd), "display" ) == 0 ) {
#ifdef COUNT_BAGS
            Pr( "%40s ", (Int)"type",  0L          );
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( UInt k = 0; k < 256; k++ ) {
                if ( InfoBags[k].name != 0 ) {
                    Char buf[41];
                    buf[0] = '\0';
                    strlcat( buf, InfoBags[k].name, sizeof(buf) );
                    Pr("%40s ",    (Int)buf, 0L );
                    Pr("%8d %8d ", (Int)InfoBags[k].nrLive,
                                   (Int)(InfoBags[k].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[k].nrAll,
                                   (Int)(InfoBags[k].sizeAll/1024));
                }
            }
#endif
        }

        /* if request give a short display of the statistics                */
        else if ( strcmp( CSTR_STRING(cmd), "displayshort" ) == 0 ) {
#ifdef COUNT_BAGS
            Pr( "%40s ", (Int)"type",  0L          );
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( UInt k = 0; k < 256; k++ ) {
                if ( InfoBags[k].name != 0 && 
                     (InfoBags[k].nrLive != 0 ||
                      InfoBags[k].sizeLive != 0 ||
                      InfoBags[k].nrAll != 0 ||
                      InfoBags[k].sizeAll != 0) ) {
                    Char buf[41];
                    buf[0] = '\0';
                    strlcat( buf, InfoBags[k].name, sizeof(buf) );
                    Pr("%40s ",    (Int)buf, 0L );
                    Pr("%8d %8d ", (Int)InfoBags[k].nrLive,
                                   (Int)(InfoBags[k].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[k].nrAll,
                                   (Int)(InfoBags[k].sizeAll/1024));
                }
            }
#endif
        }

        /* if request display the statistics                               */
        else if ( strcmp( CSTR_STRING(cmd), "clear" ) == 0 ) {
#ifdef COUNT_BAGS
            for ( UInt k = 0; k < 256; k++ ) {
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

        /* or collect the garbage                                          */
        else if ( strcmp( CSTR_STRING(cmd), "collect" ) == 0 ) {
            CollectBags(0,1);
        }

        /* or collect the garbage                                          */
        else if ( strcmp( CSTR_STRING(cmd), "partial" ) == 0 ) {
            CollectBags(0,0);
        }

        /* or display information about global bags                        */
        else if ( strcmp( CSTR_STRING(cmd), "global" ) == 0 ) {
            for ( i = 0;  i < GlobalBags.nr;  i++ ) {
                if ( *(GlobalBags.addr[i]) != 0 ) {
                    Pr( "%50s: %12d bytes\n", (Int)GlobalBags.cookie[i], 
                        (Int)SIZE_BAG(*(GlobalBags.addr[i])) );
                }
            }
        }

        /* or finally toggle Gasman messages                               */
        else if ( strcmp( CSTR_STRING(cmd), "message" ) == 0 ) {
            SyMsgsFlagBags = (SyMsgsFlagBags + 1) % 3;
        }

        /* otherwise complain                                              */
        else {
            cmd = ErrorReturnObj(
                "GASMAN: <cmd> must be %s or %s",
                (Int)"\"display\" or \"clear\" or \"global\" or ",
                (Int)"\"collect\" or \"partial\" or \"message\"",
                "you can replace <cmd> via 'return <cmd>;'" );
            goto again;
        }
#endif // USE_GASMAN
    }

    /* return nothing, this function is a procedure                        */
    return 0;
}

Obj FuncGASMAN_STATS(Obj self)
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

Obj FuncGASMAN_MESSAGE_STATUS( Obj self )
{
  return INTOBJ_INT(SyMsgsFlagBags);
}

Obj FuncGASMAN_LIMITS( Obj self )
{
  Obj list;
  list = NEW_PLIST_IMM(T_PLIST_CYC, 3);
  SET_LEN_PLIST(list,3);
  SET_ELM_PLIST(list, 1, INTOBJ_INT(SyStorMin));
  SET_ELM_PLIST(list, 2, INTOBJ_INT(SyStorMax));
  SET_ELM_PLIST(list, 3, INTOBJ_INT(SyStorKill));
  return list;
}

#ifdef GAP_MEM_CHECK

extern Int EnableMemCheck;

Obj FuncGASMAN_MEM_CHECK(Obj self, Obj newval)
{
    EnableMemCheck = INT_INTOBJ(newval);
    return 0;
}

#endif

/****************************************************************************
**
*F  FuncTotalMemoryAllocated( <self> ) .expert function 'TotalMemoryAllocated'
*/

Obj FuncTotalMemoryAllocated( Obj self )
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
Obj FuncSIZE_OBJ(Obj self, Obj obj)
{
    if (IS_INTOBJ(obj) || IS_FFE(obj))
        return INTOBJ_INT(0);
    return ObjInt_UInt(SIZE_OBJ(obj));
}

/****************************************************************************
**
*F  FuncTNUM_OBJ( <self>, <obj> ) . . . . . . . .  expert function 'TNUM_OBJ'
*/
Obj FuncTNUM_OBJ(Obj self, Obj obj)
{
    return INTOBJ_INT(TNUM_OBJ(obj));
}

/****************************************************************************
**
*F  FuncTNAM_OBJ( <self>, <obj> ) . . . . . . . .  expert function 'TNAM_OBJ'
*/
Obj FuncTNAM_OBJ(Obj self, Obj obj)
{
    return MakeImmString(TNAM_OBJ(obj));
}

/****************************************************************************
**
*F  FuncOBJ_HANDLE( <self>, <obj> ) . . . . . .  expert function 'OBJ_HANDLE'
*/
Obj FuncOBJ_HANDLE (
    Obj                 self,
    Obj                 obj )
{
    UInt                hand;
    UInt                prod;
    Obj                 rem;

    if ( IS_INTOBJ(obj) ) {
        return (Obj)INT_INTOBJ(obj);
    }
    else if ( TNUM_OBJ(obj) == T_INTPOS ) {
        hand = 0;
        prod = 1;
        while ( EQ( obj, INTOBJ_INT(0) ) == 0 ) {
            rem  = RemInt( obj, INTOBJ_INT( 1 << 16 ) );
            obj  = QuoInt( obj, INTOBJ_INT( 1 << 16 ) );
            hand = hand + prod * INT_INTOBJ(rem);
            prod = prod * ( 1 << 16 );
        }
        return (Obj) hand;
    }
    else {
        ErrorQuit( "<handle> must be a positive integer", 0L, 0L );
        return (Obj) 0;
    }
}


/****************************************************************************
**
*F  FuncHANDLE_OBJ( <self>, <obj> ) . . . . . .  expert function 'HANDLE_OBJ'
**
**  This is a very quick function which returns a unique integer for each
**  object non-identical objects will have different handles. The integers
**  may be large.
*/
Obj FuncHANDLE_OBJ(Obj self, Obj obj)
{
    return ObjInt_UInt((UInt) obj);
}

/* This function does quite  a similar job to HANDLE_OBJ, but (a) returns 0
for all immediate objects (small integers or ffes) and (b) returns reasonably
small results (roughly in the range from 1 to the max number of objects that
have existed in this session. In HPC-GAP it returns almost the same value as
HANDLE_OBJ for non-immediate objects, but divided by sizeof(Obj), which gets
rids of a few zero bits and thus increases the chance of the result value
to be an immediate integer. */

Obj FuncMASTER_POINTER_NUMBER(Obj self, Obj o)
{
    if (IS_INTOBJ(o) || IS_FFE(o)) {
        return INTOBJ_INT(0);
    }
#ifdef USE_GASMAN
    if ((void **) o >= (void **) MptrBags && (void **) o < (void **) MptrEndBags) {
        return INTOBJ_INT( ((void **) o - (void **) MptrBags) + 1 );
    } else {
        return INTOBJ_INT( 0 );
    }
#else
    return ObjInt_UInt((UInt)o / sizeof(Obj));
#endif
}

/* Returns a measure of the size of a GAP function */
Obj FuncFUNC_BODY_SIZE(Obj self, Obj f)
{
    Obj body;
    if (TNUM_OBJ(f) != T_FUNCTION) return Fail;
    body = BODY_FUNC(f);
    if (body == 0) return INTOBJ_INT(0);
    else return ObjInt_UInt( SIZE_BAG( body ) );
}

/****************************************************************************
**
*F  FuncSleep( <self>, <secs> )
**
*/

#ifdef HPCGAP
  extern UInt HaveInterrupt();
#endif

Obj FuncSleep( Obj self, Obj secs )
{
  Int  s;

  while( ! IS_INTOBJ(secs) )
    secs = ErrorReturnObj( "<secs> must be a small integer", 0L, 0L, 
                           "you can replace <secs> via 'return <secs>;'" );

  
  if ( (s = INT_INTOBJ(secs)) > 0)
    SySleep((UInt)s);
  
  /* either we used up the time, or we were interrupted. */
#ifdef HPCGAP
  if (HaveInterrupt())
#else
  if (SyIsIntr())
#endif
    {
      ClearError(); /* The interrupt may still be pending */
      ErrorReturnVoid("user interrupt in sleep", 0L, 0L,
                    "you can 'return;' as if the sleep was finished");
    }
  
  return (Obj) 0;
}


/****************************************************************************
**
*F  FuncMicroSleep( <self>, <secs> )
**
*/

Obj FuncMicroSleep( Obj self, Obj msecs )
{
  Int  s;

  while( ! IS_INTOBJ(msecs) )
    msecs = ErrorReturnObj( "<usecs> must be a small integer", 0L, 0L, 
                           "you can replace <usecs> via 'return <usecs>;'" );

  
  if ( (s = INT_INTOBJ(msecs)) > 0)
    SyUSleep((UInt)s);
  
  /* either we used up the time, or we were interrupted. */
#ifdef HPCGAP
  if (HaveInterrupt())
#else
  if (SyIsIntr())
#endif
    {
      ClearError(); /* The interrupt may still be pending */
      ErrorReturnVoid("user interrupt in microsleep", 0L, 0L,
                    "you can 'return;' as if the microsleep was finished");
    }
  
  return (Obj) 0;
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
*F  FuncGAP_EXIT_CODE() . . . . . . . . Set the code with which GAP exits.
**
*/

Obj FuncGAP_EXIT_CODE( Obj self, Obj code )
{
  if (!SetExitValue(code))
    ErrorQuit("GAP_EXIT_CODE: Argument must be boolean or integer", 0L, 0L);
  return (Obj) 0;
}


/****************************************************************************
**
*F  FuncQUIT_GAP()
**
*/

Obj FuncQUIT_GAP( Obj self, Obj args )
{
  if ( LEN_LIST(args) == 0 ) {
    SystemErrorCode = 0;
  }
  else if ( LEN_LIST(args) != 1 
            || !SetExitValue(ELM_PLIST(args, 1) ) ) {
    ErrorQuit( "usage: QUIT_GAP( [ <return value> ] )", 0L, 0L );
  }
  STATE(UserHasQUIT) = 1;
  ReadEvalError();
  return (Obj)0; 
}

/****************************************************************************
**
*F  FuncFORCE_QUIT_GAP()
**
*/

Obj FuncFORCE_QUIT_GAP( Obj self, Obj args )
{
  if ( LEN_LIST(args) == 0 )
  {
    SyExit(SystemErrorCode);
  }
  else if ( LEN_LIST(args) != 1 
            || !SetExitValue(ELM_PLIST(args, 1) ) ) {
    ErrorQuit( "usage: FORCE_QUIT_GAP( [ <return value> ] )", 0L, 0L );
  }
  SyExit(SystemErrorCode);
}

/****************************************************************************
**
*F  FuncSHOULD_QUIT_ON_BREAK()
**
*/

Obj FuncSHOULD_QUIT_ON_BREAK( Obj self)
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

Obj FuncKERNEL_INFO(Obj self) {
  Obj res = NEW_PREC(0);
  UInt r,lenvec,lenstr,lenstr2;
  Char *p;
  Obj tmp,list,str;
  UInt i,j;

  /* GAP_ARCHITECTURE                                                    */
  tmp = MakeImmString( SyArchitecture );
  r = RNamName("GAP_ARCHITECTURE");
  AssPRec(res,r,tmp);
  /* KERNEL_VERSION */
  tmp = MakeImmString( SyKernelVersion );
  r = RNamName("KERNEL_VERSION");
  AssPRec(res,r,tmp);
  tmp = MakeImmString( SyBuildVersion );
  r = RNamName("BUILD_VERSION");
  AssPRec(res,r,tmp);
  tmp = MakeImmString( SyBuildDateTime );
  r = RNamName("BUILD_DATETIME");
  AssPRec(res,r,tmp);
  /* GAP_ROOT_PATH                                                       */
  /* do we need this. Could we rebuild it from the command line in GAP
     if so, should we                                                    */
  list = NEW_PLIST_IMM( T_PLIST, MAX_GAP_DIRS );
  for ( i = 0, j = 1;  i < MAX_GAP_DIRS;  i++ ) {
    if ( SyGapRootPaths[i][0] ) {
      tmp = MakeImmString( SyGapRootPaths[i] );
      SET_ELM_PLIST( list, j, tmp );
      j++;
    }
  }
  SET_LEN_PLIST( list, j-1 );
  r = RNamName("GAP_ROOT_PATHS");
  AssPRec(res,r,list);
  /* And also the DotGapPath if available */
#ifdef HAVE_DOTGAPRC
  tmp = MakeImmString( DotGapPath );
  r = RNamName("DOT_GAP_PATH");
  AssPRec(res,r,tmp);
#endif
    
  /* make command line and environment available to GAP level       */
  for (lenvec=0; SyOriginalArgv[lenvec]; lenvec++);
  tmp = NEW_PLIST_IMM( T_PLIST, lenvec );
  SET_LEN_PLIST( tmp, lenvec );
  for (i = 0; i<lenvec; i++) {
    str = MakeImmString( SyOriginalArgv[i] );
    SET_ELM_PLIST(tmp, i+1, str);
    CHANGED_BAG(tmp);
  }
  r = RNamName("COMMAND_LINE");
  AssPRec(res,r, tmp);

  tmp = NEW_PREC(0);
  for (i = 0; sysenviron[i]; i++) {
    for (p = sysenviron[i]; *p != '='; p++)
      ;
    lenstr2 = (UInt) (p-sysenviron[i]);
    p++;   /* Move pointer behind = character */
    lenstr = strlen(p);
    if (lenstr2 > lenstr)
        str = NEW_STRING(lenstr2);
    else
        str = NEW_STRING(lenstr);
    strncat(CSTR_STRING(str),sysenviron[i],lenstr2);
    r = RNamName(CSTR_STRING(str));
    *(CSTR_STRING(str)) = 0;
    strncat(CSTR_STRING(str),p, lenstr);
    SET_LEN_STRING(str, lenstr);
    SHRINK_STRING(str);
    AssPRec(tmp,r , str);
  }
  r = RNamName("ENVIRONMENT");
  AssPRec(res,r, tmp);

#ifdef HPCGAP
  r = RNamName("NUM_CPUS");
  AssPRec(res, r, INTOBJ_INT(SyNumProcessors));
#endif

  /* export if we want to use readline  */
  r = RNamName("HAVE_LIBREADLINE");
  if (SyUseReadline)
    AssPRec(res, r, True);
  else
    AssPRec(res, r, False);

  /* export GMP version  */
  str = MakeImmString( gmp_version );
  r = RNamName("GMP_VERSION");
  AssPRec(res, r, str);

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

UInt BreakPointValue;

Obj FuncBREAKPOINT(Obj self, Obj arg) {
  if (IS_INTOBJ(arg))
    BreakPointValue = INT_INTOBJ(arg);
  return (Obj) 0;
}

#ifdef HPCGAP

/****************************************************************************
**
*F FuncTHREAD_UI  ... Whether we use a multi-threaded interface
**
*/

Obj FuncTHREAD_UI(Obj self)
{
  return ThreadUI ? True : False;
}


GVarDescriptor GVarTHREAD_INIT;
GVarDescriptor GVarTHREAD_EXIT;

void ThreadedInterpreter(void *funcargs) {
  Obj tmp, func;
  int i;

  /* initialize everything and begin an interpreter                       */
  STATE(IntrCoding) = 0;
  STATE(IntrIgnoring) = 0;
  STATE(NrError) = 0;
  STATE(ThrownObject) = 0;

  IntrBegin( STATE(BottomLVars) );
  tmp = KEPTALIVE(funcargs);
  StopKeepAlive(funcargs);
  func = ELM_PLIST(tmp, 1);
  for (i=2; i<=LEN_PLIST(tmp); i++)
  {
    Obj item = ELM_PLIST(tmp, i);
    SET_ELM_PLIST(tmp, i-1, item);
  }
  SET_LEN_PLIST(tmp, LEN_PLIST(tmp)-1);

  TRY_READ {
    Obj init, exit;
    if (sySetjmp(TLS(threadExit)))
      return;
    init = GVarOptFunction(&GVarTHREAD_INIT);
    if (init) CALL_0ARGS(init);
    CallFuncList(func, tmp);
    exit = GVarOptFunction(&GVarTHREAD_EXIT);
    if (exit) CALL_0ARGS(exit);
    PushVoidObj();
    /* end the interpreter                                                 */
    IntrEnd( 0UL );
  } CATCH_READ_ERROR {
    IntrEnd( 1UL );
    ClearError();
  } 
}

#endif


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(Runtime, 0, ""),
    GVAR_FUNC(RUNTIMES, 0, ""),
    GVAR_FUNC(NanosecondsSinceEpoch, 0, ""),
    GVAR_FUNC(NanosecondsSinceEpochInfo, 0, ""),
    GVAR_FUNC(SizeScreen, -1, "args"),
    GVAR_FUNC(ID_FUNC, 1, "object"),
    GVAR_FUNC(RETURN_FIRST, -1, "object"),
    GVAR_FUNC(RETURN_NOTHING, -1, "object"),
    GVAR_FUNC(GASMAN, -1, "args"),
    GVAR_FUNC(GASMAN_STATS, 0, ""),
    GVAR_FUNC(GASMAN_MESSAGE_STATUS, 0, ""),
    GVAR_FUNC(GASMAN_LIMITS, 0, ""),
#ifdef GAP_MEM_CHECK
    GVAR_FUNC(GASMAN_MEM_CHECK, 1, "int"),
#endif
    GVAR_FUNC(TotalMemoryAllocated, 0, ""),
    GVAR_FUNC(SIZE_OBJ, 1, "object"),
    GVAR_FUNC(TNUM_OBJ, 1, "object"),
    GVAR_FUNC(TNAM_OBJ, 1, "object"),
    GVAR_FUNC(OBJ_HANDLE, 1, "object"),
    GVAR_FUNC(HANDLE_OBJ, 1, "object"),
    GVAR_FUNC(WindowCmd, 1, "arg-list"),
    GVAR_FUNC(MicroSleep, 1, "msecs"),
    GVAR_FUNC(Sleep, 1, "secs"),
    GVAR_FUNC(GAP_EXIT_CODE, 1, "exitCode"),
    GVAR_FUNC(QUIT_GAP, -1, "args"),
    GVAR_FUNC(FORCE_QUIT_GAP, -1, "args"),
    GVAR_FUNC(SHOULD_QUIT_ON_BREAK, 0, ""),
    GVAR_FUNC(SHELL, -1, "context, canReturnVoid, canReturnObj, lastDepth, "
                         "setTime, prompt, promptHook, infile, outfile"),
    GVAR_FUNC(KERNEL_INFO, 0, ""),
#ifdef HPCGAP
    GVAR_FUNC(THREAD_UI, 0, ""),
#endif
    GVAR_FUNC(MASTER_POINTER_NUMBER, 1, "ob"),
    GVAR_FUNC(FUNC_BODY_SIZE, 1, "f"),
    GVAR_FUNC(BREAKPOINT, 1, "integer"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* init the completion function                                        */
#if !defined(HPCGAP)
    InitGlobalBag( &STATE(ThrownObject), "src/gap.c:ThrownObject"      );
#endif

    /* list of exit functions                                              */
    InitGlobalBag( &WindowCmdString, "src/gap.c:WindowCmdString" );

    InitGlobalBag( &STATE(ShellContext), "STATE(ShellContext)" );
    InitGlobalBag( &STATE(BaseShellContext), "STATE(BaseShellContext)" );

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* establish Fopy of ViewObj                                           */
    ImportFuncFromLibrary(  "ViewObj", 0L );
    ImportFuncFromLibrary(  "Error", &Error );

#ifdef HPCGAP
    DeclareGVar(&GVarTHREAD_INIT, "THREAD_INIT");
    DeclareGVar(&GVarTHREAD_EXIT, "THREAD_EXIT");
#endif

#ifdef HAVE_SELECT
    InitCopyGVar("OnCharReadHookActive",&OnCharReadHookActive);
    InitCopyGVar("OnCharReadHookInFds",&OnCharReadHookInFds);
    InitCopyGVar("OnCharReadHookInFuncs",&OnCharReadHookInFuncs);
    InitCopyGVar("OnCharReadHookOutFds",&OnCharReadHookOutFds);
    InitCopyGVar("OnCharReadHookOutFuncs",&OnCharReadHookOutFuncs);
    InitCopyGVar("OnCharReadHookExcFds",&OnCharReadHookExcFds);
    InitCopyGVar("OnCharReadHookExcFuncs",&OnCharReadHookExcFuncs);
#endif

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
      UInt var;

    /* library name and other stuff                                        */
    var = GVarName( "DEBUG_LOADING" );
    MakeReadWriteGVar(var);
    AssGVar( var, (SyDebugLoading ? True : False) );
    MakeReadOnlyGVar(var);

    /* construct the `ViewObj' variable                                    */
    ViewObjGVar = GVarName( "ViewObj" ); 

    /* construct the last and time variables                               */
    Last              = GVarName( "last"  );
    Last2             = GVarName( "last2" );
    Last3             = GVarName( "last3" );
    Time              = GVarName( "time"  );
    MemoryAllocated   = GVarName( "memory_allocated"  );
    AssGVar(Time, INTOBJ_INT(0));
    AssGVar(MemoryAllocated, INTOBJ_INT(0));
    QUITTINGGVar      = GVarName( "QUITTING" );
    
    /* return success                                                      */
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

    /* return success                                                      */
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
**  Each module  (builtin  or compiled) exports  a sturctures  which contains
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
**  does  assignments of auxillary C   variables (for example, pointers  from
**  objects, length of hash lists).  This function is only used for starting.
**
**  `PostRestore': Everything in  `InitLibrary' execpt  creating objects.  In
**  general    `InitLibrary'  will  create    all objects    and  then  calls
**  `PostRestore'.  This function is only used when restoring.
*/
#ifdef USE_GASMAN
extern TNumMarkFuncBags TabMarkFuncBags [ 256 ];
#endif

static Obj POST_RESTORE;

void InitializeGap (
    int *               pargc,
    char *              argv [],
    char *              environ [] )
{
    /* initialize the basic system and gasman                              */
    InitSystem( *pargc, argv );

    /* Initialise memory  -- have to do this here to make sure we are at top of C stack */
    InitBags( SyStorMin,
              0, (Bag*)(((UInt)pargc/C_STACK_ALIGN)*C_STACK_ALIGN), C_STACK_ALIGN );
#ifdef USE_GASMAN
    InitMsgsFuncBags( SyMsgsBags );
#endif

    STATE(IntrCoding)   = 0;
    STATE(IntrIgnoring) = 0;
    STATE(NrError)      = 0;
    STATE(ThrownObject) = 0;
    STATE(UserHasQUIT) = 0;
    STATE(UserHasQuit) = 0;
    STATE(JumpToCatchCallback) = 0;

    sysenviron = environ;

    // get info structures for the built in modules
    ModulesSetup();

    // call kernel initialisation
    ModulesInitKernel();

#ifdef HPCGAP
    InitMainThread();
#endif
    InitGAPState(ActiveGAPState());

    InitGlobalBag(&POST_RESTORE, "gap.c: POST_RESTORE");
    InitFopyGVar( "POST_RESTORE", &POST_RESTORE);

#ifdef COUNT_BAGS
    if (SyDebugLoading) {
        if ( SyRestoring ) {
            Pr( "#W  after setup\n", 0L, 0L );
            Pr( "#W  %36s ", (Int)"type",  0L          );
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( i = 0;  i < 256;  i++ ) {
                if ( InfoBags[i].name != 0 && InfoBags[i].nrAll != 0 ) {
                    char    buf[41];

                    buf[0] = '\0';
                    strlcat( buf, InfoBags[i].name, sizeof(buf) );
                    Pr("#W  %36s ",    (Int)buf, 0L );
                    Pr("%8d %8d ", (Int)InfoBags[i].nrLive,
                       (Int)(InfoBags[i].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[i].nrAll,
                       (Int)(InfoBags[i].sizeAll/1024));
                }
            }
        }
    }
#endif

#ifdef USE_GASMAN
    /* and now for a special hack                                          */
    for ( UInt i = LAST_CONSTANT_TNUM+1; i <= LAST_REAL_TNUM; i++ ) {
      if (TabMarkFuncBags[i + COPYING] == MarkAllSubBagsDefault)
        TabMarkFuncBags[ i+COPYING ] = TabMarkFuncBags[ i ];
    }
#endif

    /* if we are restoring, load the workspace and call the post restore   */
    if ( SyRestoring ) {
        LoadWorkspace(SyRestoring);
        SyRestoring = NULL;


        /* Call POST_RESTORE which is a GAP function that now takes control, 
           calls the post restore functions and then runs a GAP session */
        if (POST_RESTORE != (Obj) 0 &&
            IS_FUNC(POST_RESTORE))
          TRY_READ {
            CALL_0ARGS(POST_RESTORE);
          }
    }


    /* otherwise call library initialisation                               */
    else {
#ifdef USE_GASMAN
        CheckAllHandlers();
#endif

        SyInitializing = 1;
        ModulesInitLibrary();
    }

    /* check initialisation                                                */
    ModulesCheckInit();

    /* read the init files      
       this now actually runs the GAP session, we only get 
       past here when we're about to exit. 
                                           */
    if ( SyLoadSystemInitFile ) {
      TRY_READ {
        if ( READ_GAP_ROOT("lib/init.g") == 0 ) {
          /*             if ( ! SyQuiet ) { */
                Pr( "gap: hmm, I cannot find 'lib/init.g' maybe",
                    0L, 0L );
                Pr( " use option '-l <gaproot>'?\n If you ran the GAP"
                    " binary directly, try running the 'gap.sh' or 'gap.bat'"
                    " script instead.", 0L, 0L );
            }
      }
      CATCH_READ_ERROR
        {
          Pr("Caught error at top-most level, probably quit from library loading",0L,0L);
          SyExit(1);
        }
        /*         } */
    }

}
