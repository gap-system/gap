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
#include <stdio.h>
#include <assert.h>
#include <string.h>                     /* memcpy */
#include <stdlib.h>

#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>

#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>                     /* move this and wrap execvp later */

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */
#include <src/read.h>                   /* reader */

#include <src/gvars.h>                  /* global variables */
#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/gmpints.h>                /* integers */
#include <src/rational.h>               /* rationals */
#include <src/cyclotom.h>               /* cyclotomics */
#include <src/finfield.h>               /* finite fields and ff elements */

#include <src/bool.h>                   /* booleans */
#include <src/macfloat.h>               /* machine doubles */
#include <src/permutat.h>               /* permutations */
#include <src/trans.h>                  /* transformations */
#include <src/pperm.h>                  /* partial perms */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/listoper.h>               /* operations for generic lists */
#include <src/listfunc.h>               /* functions for generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/set.h>                    /* plain sets */
#include <src/vector.h>                 /* functions for plain vectors */
#include <src/vecffe.h>                 /* functions for fin field vectors */
#include <src/blister.h>                /* boolean lists */
#include <src/range.h>                  /* ranges */
#include <src/stringobj.h>              /* strings */
#include <src/vecgf2.h>                 /* functions for GF2 vectors */
#include <src/vec8bit.h>             /* functions for other compressed
                                           GF(q) vectors                   */
#include <src/objfgelm.h>               /* objects of free groups */
#include <src/objpcgel.h>               /* objects of polycyclic groups */
#include <src/objscoll.h>               /* single collector */
#include <src/objccoll.h>               /* combinatorial collector */
#include <src/objcftl.h>                /* from the left collect */

#include <src/dt.h>                     /* deep thought */
#include <src/dteval.h>                 /* deep thought evaluation */

#include <src/sctable.h>                /* structure constant table */
#include <src/costab.h>                 /* coset table */
#include <src/tietze.h>                 /* tietze helper functions */

#include <src/code.h>                   /* coder */

#include <src/exprs.h>                  /* expressions */
#include <src/stats.h>                  /* statements */
#include <src/funcs.h>                  /* functions */

#include <src/intrprtr.h>               /* interpreter */

#include <src/compiler.h>               /* compiler */

#include <src/compstat.h>               /* statically linked modules */

#include <src/saveload.h>               /* saving and loading */

#include <src/streams.h>                /* streams package */
#include <src/sysfiles.h>               /* file input/output */
#include <src/weakptr.h>                /* weak pointers */
#include <src/profile.h>                /* profiling */
#include <src/hookintrprtr.h>

#include <src/gapstate.h>

#ifdef GAPMPI
#include <src/hpc/gapmpi.h>             /* ParGAP/MPI */
#endif

#ifdef HPCGAP
#include <src/hpc/thread.h>
#include <src/hpc/tls.h>
#include <src/hpc/aobjects.h>
#include <src/hpc/misc.h>
#include <src/hpc/threadapi.h>
#include <src/hpc/serialize.h>          /* object serialization */

#include <src/objset.h>
#endif

#include <src/vars.h>                   /* variables */

#include <src/intfuncs.h>
#include <src/iostream.h>

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


typedef struct {
    const Char *                name;
    Obj *                       address;
} StructImportedGVars;

#ifndef MAX_IMPORTED_GVARS
#define MAX_IMPORTED_GVARS      1024
#endif

static StructImportedGVars ImportedGVars[MAX_IMPORTED_GVARS];
static Int NrImportedGVars;

static StructImportedGVars ImportedFuncs[MAX_IMPORTED_GVARS];
static Int NrImportedFuncs;

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
  UInt status;
  UInt dualSemicolon;
  UInt oldindent;
  UInt oldPrintDepth;
  Obj res;
  Obj oldShellContext;
  Obj oldBaseShellContext;
  Int oldRecursionDepth;
  oldShellContext = STATE(ShellContext);
  STATE(ShellContext) = context;
  oldBaseShellContext = STATE(BaseShellContext);
  STATE(BaseShellContext) = context;
  oldRecursionDepth = STATE(RecursionDepth);
  
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
  oldindent = STATE(Output)->indent;
  STATE(Output)->indent = 0;

  while ( 1 ) {

    /* start the stopwatch                                             */
    if (setTime)
      time = SyTime();

    /* read and evaluate one command                                   */
    STATE(Prompt) = prompt;
    ClearError();
    STATE(PrintObjDepth) = 0;
    STATE(Output)->indent = 0;
    STATE(RecursionDepth) = 0;
      
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
    status = ReadEvalCommand(STATE(ShellContext), &dualSemicolon);
    if (STATE(UserHasQUIT))
      break;


    /* handle ordinary command                                         */
    if ( status == STATUS_END && STATE(ReadEvalResult) != 0 ) {

      /* remember the value in 'last'    */
      if (lastDepth >= 3)
        AssGVar( Last3, VAL_GVAR( Last2 ) );
      if (lastDepth >= 2)
        AssGVar( Last2, VAL_GVAR( Last  ) );
      if (lastDepth >= 1)
        AssGVar( Last,  STATE(ReadEvalResult)   );

      /* print the result                                            */
      if ( ! dualSemicolon ) {
        ViewObjHandler( STATE(ReadEvalResult) );
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
      STATE(RecursionDepth) = 0;
      STATE(UserHasQuit) = 1;
      break;
    }
        
    /* handle QUIT */
    else if (status & (STATUS_QQUIT)) {
      STATE(UserHasQUIT) = 1;
      break;
    }
        
    /* stop the stopwatch                                          */
    if (setTime)
      AssGVar( Time, INTOBJ_INT( SyTime() - time ) );

    if (STATE(UserHasQuit))
      {
        FlushRestOfInputLine();
        STATE(UserHasQuit) = 0;        /* quit has done its job if we are here */
      }

  }
  
  STATE(PrintObjDepth) = oldPrintDepth;
  STATE(Output)->indent = oldindent;
  CloseInput();
  CloseOutput();
  STATE(BaseShellContext) = oldBaseShellContext;
  STATE(ShellContext) = oldShellContext;
  STATE(RecursionDepth) = oldRecursionDepth;
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
      SET_ELM_PLIST(res,1,STATE(ReadEvalResult));
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
  if (TNUM_OBJ(context) != T_LVARS)
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
      Pr("#W SHELL: negative last depth treated as zero",0,0);
      lastDepth = 0;
    }
  else if (lastDepth > 3 )
    {
      Pr("#W SHELL: last depth greater than 3 treated as 3",0,0);
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
  if (!IsStringConv(infile))
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

#if !defined(HPCGAP)
  InitMainGAPState();
#endif

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
      if (strlen(SyCompileOptions) != 0)
        SetCompileOpts(SyCompileOptions);
      type = CompileFunc(
                         SyCompileOutput,
                         func,
                         SyCompileName,
                         crc,
                         SyCompileMagic1 );
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
#ifdef PRINT_BACKTRACE
  void InstallBacktraceHandlers();
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
  C_NEW_STRING_DYN(tmp, SyNanosecondsSinceEpochMethod);
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
  ptr = SyWinCmd( qtr, strlen(qtr) );
  len = strlen(ptr);

  /* now convert result back into a list                                 */
  list = NEW_PLIST( T_PLIST, 11 );
  SET_LEN_PLIST( list, 0 );
  i = 1;
  while ( 0 < len ) {
    if ( *ptr == 'I' ) {
      ptr++;
      for ( n=0,m=1; '0' <= *ptr && *ptr <= '9'; ptr++,m *= 10,len-- )
        n += (*ptr-'0') * m;
      if ( *ptr++ == '-' )
        n *= -1;
      len -= 2;
      AssPlist( list, i, INTOBJ_INT(n) );
    }
    else if ( *ptr == 'S' ) {
      ptr++;
      for ( n=0,m=1;  '0' <= *ptr && *ptr <= '9';  ptr++,m *= 10,len-- )
        n += (*ptr-'0') * m;
      ptr++; /* ignore the '+' */
      C_NEW_STRING(tmp, n, ptr);
      ptr += n;
      len -= n+2;
      AssPlist( list, i, tmp );
    }
    else {
      ErrorQuit( "unknown return value '%s'", (Int)ptr, 0 );
      return 0;
    }
    i++;
  }

  /* if the first entry is one signal an error */
  if ( ELM_LIST(list,1) == INTOBJ_INT(1) ) {
    C_NEW_STRING_CONST(tmp, "window system: ");
    SET_ELM_PLIST( list, 1, tmp );
    SET_LEN_PLIST( list, i-1 );
    return CALL_XARGS(Error,list);
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

*F * * * * * * * * * * * * * * error functions * * * * * * * * * * * * * * *
*/



/****************************************************************************
**
*F  FuncDownEnv( <self>, <level> )  . . . . . . . . .  change the environment
*/

void DownEnvInner( Int depth )
{
  /* if we are asked to go up ... */
  if ( depth < 0 ) {
    /* ... we determine which level we are supposed to end up on ... */
    depth = STATE(ErrorLLevel) + depth;
    if (depth < 0) {
      depth = 0;
    }
    /* ... then go back to the top, and later go down to the appropriate level. */
    STATE(ErrorLVars) = STATE(ErrorLVars0);
    STATE(ErrorLLevel) = 0;
    STATE(ShellContext) = STATE(BaseShellContext);
  }
  
  /* now go down */
  while ( 0 < depth
          && STATE(ErrorLVars) != STATE(BottomLVars)
          && PARENT_LVARS(STATE(ErrorLVars)) != STATE(BottomLVars) ) {
    STATE(ErrorLVars) = PARENT_LVARS(STATE(ErrorLVars));
    STATE(ErrorLLevel)++;
    STATE(ShellContext) = PARENT_LVARS(STATE(ShellContext));
    depth--;
  }
}

Obj FuncDownEnv (
                 Obj                 self,
                 Obj                 args )
{
  Int                 depth;

  if ( LEN_LIST(args) == 0 ) {
    depth = 1;
  }
  else if ( LEN_LIST(args) == 1 && IS_INTOBJ( ELM_PLIST(args,1) ) ) {
    depth = INT_INTOBJ( ELM_PLIST( args, 1 ) );
  }
  else {
    ErrorQuit( "usage: DownEnv( [ <depth> ] )", 0L, 0L );
    return 0;
  }
  if ( STATE(ErrorLVars) == STATE(BottomLVars) ) {
    Pr( "not in any function\n", 0L, 0L );
    return 0;
  }

  DownEnvInner( depth);
  return 0;
}

Obj FuncUpEnv (
               Obj                 self,
               Obj                 args )
{
  Int                 depth;
  if ( LEN_LIST(args) == 0 ) {
    depth = 1;
  }
  else if ( LEN_LIST(args) == 1 && IS_INTOBJ( ELM_PLIST(args,1) ) ) {
    depth = INT_INTOBJ( ELM_PLIST( args, 1 ) );
  }
  else {
    ErrorQuit( "usage: UpEnv( [ <depth> ] )", 0L, 0L );
    return 0;
  }
  if ( STATE(ErrorLVars) == STATE(BottomLVars) ) {
    Pr( "not in any function\n", 0L, 0L );
    return 0;
  }

  DownEnvInner(-depth);
  return 0;
}

Obj FuncExecutingStatementLocation(Obj self, Obj context)
{
  Obj currLVars = STATE(CurrLVars);
  Expr call;
  Int line;
  Obj filename;
  Obj retlist;
  retlist = Fail;
  if (context == STATE(BottomLVars))
    return Fail;
  SWITCH_TO_OLD_LVARS(context);
  call = BRK_CALL_TO();
  if (
#if T_PROCCALL_0ARGS
        ( FIRST_STAT_TNUM <= TNUM_STAT(call)
                && TNUM_STAT(call)  <= LAST_STAT_TNUM ) ||
#else
        ( TNUM_STAT(call)  <= LAST_STAT_TNUM ) ||
#endif
        ( FIRST_EXPR_TNUM <= TNUM_EXPR(call)
              && TNUM_EXPR(call)  <= LAST_EXPR_TNUM ) ) {
    line = LINE_STAT(call);
    filename = FILENAME_STAT(call);
    retlist = NEW_PLIST(T_PLIST, 2);
    SET_LEN_PLIST(retlist, 2);
    SET_ELM_PLIST(retlist, 1, filename);
    SET_ELM_PLIST(retlist, 2, INTOBJ_INT(line));
    CHANGED_BAG(retlist);
  }
  SWITCH_TO_OLD_LVARS( currLVars );
  return retlist;
}

Obj FuncPrintExecutingStatement(Obj self, Obj context)
{
  Obj currLVars = STATE(CurrLVars);
  Expr call;
  if (context == STATE(BottomLVars))
    return (Obj) 0;
  SWITCH_TO_OLD_LVARS(context);
  call = BRK_CALL_TO();
  if ( call == 0 ) {
    Pr( "<compiled or corrupted statement> ", 0L, 0L );
  }
#if T_PROCCALL_0ARGS
    else if ( FIRST_STAT_TNUM <= TNUM_STAT(call)
              && TNUM_STAT(call)  <= LAST_STAT_TNUM ) {
#else
     else if ( TNUM_STAT(call)  <= LAST_STAT_TNUM ) {
#endif
      PrintStat( call );
      Pr(" at %s:%d",(UInt)CSTR_STRING(FILENAME_STAT(call)),LINE_STAT(call));
    }
    else if ( FIRST_EXPR_TNUM <= TNUM_EXPR(call)
              && TNUM_EXPR(call)  <= LAST_EXPR_TNUM ) {
      PrintExpr( call );
      Pr(" at %s:%d",(UInt)CSTR_STRING(FILENAME_STAT(call)),LINE_STAT(call));
    }
    SWITCH_TO_OLD_LVARS( currLVars );
    return (Obj) 0;
}    

/****************************************************************************
**
*F  FuncCallFuncTrapError( <self>, <func> )
**
*/
  
/* syJmp_buf CatchBuffer; */
/* TL: Obj ThrownObject = 0; */

Obj FuncCALL_WITH_CATCH( Obj self, Obj func, volatile Obj args )
{
    volatile syJmp_buf readJmpError;
    volatile Obj res;
    volatile Obj currLVars;
    volatile Obj tilde;
    volatile Int recursionDepth;
    volatile Stat currStat;

    if (!IS_FUNC(func))
      ErrorMayQuit("CALL_WITH_CATCH(<func>, <args>): <func> must be a function",0,0);
    if (!IS_LIST(args))
      ErrorMayQuit("CALL_WITH_CATCH(<func>, <args>): <args> must be a list",0,0);
#ifdef HPCGAP
    if (!IS_PLIST(args)) {
      args = SHALLOW_COPY_OBJ(args);
      PLAIN_LIST(args);
    }
#endif

    memcpy((void *)&readJmpError, (void *)&STATE(ReadJmpError), sizeof(syJmp_buf));
    currLVars = STATE(CurrLVars);
    currStat = STATE(CurrStat);
    recursionDepth = STATE(RecursionDepth);
    tilde = VAL_GVAR(Tilde);
    res = NEW_PLIST(T_PLIST_DENSE+IMMUTABLE,2);
#ifdef HPCGAP
    int lockSP = RegionLockSP();
    Region *savedRegion = TLS(currentRegion);
#endif
    if (sySetjmp(STATE(ReadJmpError))) {
      SET_LEN_PLIST(res,2);
      SET_ELM_PLIST(res,1,False);
      SET_ELM_PLIST(res,2,STATE(ThrownObject));
      CHANGED_BAG(res);
      STATE(ThrownObject) = 0;
      STATE(CurrLVars) = currLVars;
      STATE(PtrLVars) = PTR_BAG(STATE(CurrLVars));
      STATE(PtrBody) = (Stat*)PTR_BAG(BODY_FUNC(CURR_FUNC));
      STATE(CurrStat) = currStat;
      STATE(RecursionDepth) = recursionDepth;
#ifdef HPCGAP
      AssGVar(Tilde, tilde);
      PopRegionLocks(lockSP);
      TLS(currentRegion) = savedRegion;
      if (TLS(CurrentHashLock))
        HashUnlock(TLS(CurrentHashLock));
#else
      AssGVarUnsafe(Tilde, tilde);
#endif
    } else {
      Obj result = CallFuncList(func, args);
#ifdef HPCGAP
      /* There should be no locks to pop off the stack, but better safe than sorry. */
      PopRegionLocks(lockSP);
      TLS(currentRegion) = savedRegion;
#endif
      SET_ELM_PLIST(res,1,True);
      if (result) {
        SET_LEN_PLIST(res,2);
        SET_ELM_PLIST(res,2,result);
        CHANGED_BAG(res);
      } else
        SET_LEN_PLIST(res,1);
    }
    memcpy((void *)&STATE(ReadJmpError), (void *)&readJmpError, sizeof(syJmp_buf));
    return res;
}

Obj FuncJUMP_TO_CATCH( Obj self, Obj payload)
{
  STATE(ThrownObject) = payload;
  syLongjmp(&(STATE(ReadJmpError)), 1);
  return 0;
}


/* TL: UInt UserHasQuit; */
/* TL: UInt UserHasQUIT; */
UInt SystemErrorCode;

Obj FuncSetUserHasQuit( Obj Self, Obj value)
{
  STATE(UserHasQuit) = INT_INTOBJ(value);
  if (STATE(UserHasQuit))
    STATE(RecursionDepth) = 0;
  return 0;
}


#define MAX_TIMEOUT_NESTING_DEPTH 1024

syJmp_buf AlarmJumpBuffers[MAX_TIMEOUT_NESTING_DEPTH];
UInt NumAlarmJumpBuffers = 0;

Obj FuncTIMEOUTS_SUPPORTED(Obj self) {
#ifdef HPCGAP
  return False;
#endif
  return SyHaveAlarms ? True: False;
}

Obj FuncCALL_WITH_TIMEOUT( Obj self, Obj seconds, Obj microseconds, Obj func, Obj args )
{
#ifdef HPCGAP
  ErrorMayQuit("CALL_WITH_TIMEOUT: timeouts not supported in HPC-GAP", 0L, 0L);
  return 0;
#else
  Obj res;
  volatile Obj currLVars;
  Obj result;
  volatile Int recursionDepth;
  volatile Stat currStat;
  volatile UInt newJumpBuf = 1;
  volatile UInt mayNeedToRestore = 0;
  volatile Int iseconds, imicroseconds;
  volatile Int curr_seconds= 0, curr_microseconds=0, curr_nanoseconds=0;
  Int restore_seconds = 0, restore_microseconds = 0;


  if (!SyHaveAlarms)
    ErrorMayQuit("CALL_WITH_TIMEOUT: timeouts not supported on this system", 0L, 0L);
  if (!IS_INTOBJ(seconds) || 0 > INT_INTOBJ(seconds))
    ErrorMayQuit("CALL_WITH_TIMEOUT(<seconds>, <microseconds>, <func>, <args>):"
                 " <seconds> must be a non-negative small integer",0,0);
  if (!IS_INTOBJ(microseconds) || 0 > INT_INTOBJ(microseconds) || 999999 < INT_INTOBJ(microseconds))
    ErrorMayQuit("CALL_WITH_TIMEOUT(<seconds>, <microseconds>, <func>, <args>):"
                 " <microseconds> must be a non-negative small integer less than 10^9",0,0);
  iseconds = INT_INTOBJ(seconds);
  imicroseconds = INT_INTOBJ(microseconds);
  if (!IS_FUNC(func))
    ErrorMayQuit("CALL_WITH_TIMEOUT(<seconds>, <microseconds>, <func>, <args>): <func> must be a function",0,0);
  if (!IS_LIST(args))
    ErrorMayQuit("CALL_WITH_TIMEOUT(<seconds>, <microseconds>, <func>, <args>): <args> must be a list",0,0);
  if (SyAlarmRunning) {            
    /* ErrorMayQuit("CALL_WITH_TIMEOUT cannot currently be nested except via break loops."
       " There is already a timeout running", 0, 0); */
    SyStopAlarm((UInt *)&curr_seconds, (UInt *)&curr_nanoseconds);
    curr_microseconds = curr_nanoseconds/1000;
    if (iseconds > curr_seconds || (iseconds == curr_seconds && imicroseconds > curr_microseconds)) {
      /* The existing timeout will go off before we would so don't bother to set a timeout
         just reset the existing one and call the function */
      iseconds = curr_seconds;
      imicroseconds = curr_microseconds;
      newJumpBuf = 0;
    } else {
      /* We would time out before the other function, so we need to
         set our timeout, but remember to reset things later */
      mayNeedToRestore = 1;
      newJumpBuf = 1;
    }
  }
  if (newJumpBuf) {
    if (NumAlarmJumpBuffers >= MAX_TIMEOUT_NESTING_DEPTH-1)
      ErrorMayQuit("Nesting depth of timeouts limited to %i", MAX_TIMEOUT_NESTING_DEPTH, 0L);
    currLVars = STATE(CurrLVars);
    currStat = STATE(CurrStat);
    recursionDepth = STATE(RecursionDepth);
    if (sySetjmp(AlarmJumpBuffers[NumAlarmJumpBuffers++])) {
      /* Timeout happened */
      STATE(CurrLVars) = currLVars;
      STATE(PtrLVars) = PTR_BAG(STATE(CurrLVars));
      STATE(PtrBody) = (Stat*)PTR_BAG(BODY_FUNC(CURR_FUNC));
      STATE(CurrStat) = currStat;
      STATE(RecursionDepth) = recursionDepth;
      if (mayNeedToRestore) {
        /* In this case we used our ration of CPU time,
           so we know how much we need to restore 

           The jump buffer stack is already taken care of by the time we
           get here */
        restore_seconds = curr_seconds - iseconds;
        restore_microseconds = curr_microseconds - imicroseconds;
        if (restore_microseconds < 0) {
          restore_microseconds += 1000000;
          restore_seconds -= 1;
        }
        SyInstallAlarm(restore_seconds, 1000*restore_microseconds);
      }
      res = NEW_PLIST(T_PLIST_DENSE+IMMUTABLE,1);
      SET_ELM_PLIST(res,1,False);
      SET_LEN_PLIST(res,1);
      return res;
    }
  }

  /* The next timeout was too close, this is a bit of a hack, just as below */
  if ((iseconds==0) && (imicroseconds==0)) {
     imicroseconds = 1;
  }
  /* Here we actually call the function */
  SyInstallAlarm( iseconds, 1000*imicroseconds);
  result = CallFuncList(func, args);
   
  /* if newJumpBuf is false then we didn't set up our own alarm,
     just  reset the outer one, 
     and the outer one hasn't gone off yet, so we just return */
  if (newJumpBuf) {
    /* Here we did set our own alarm, but it hasn't gone off */
    Int unused_seconds, unused_microseconds, unused_nanoseconds;
    SyStopAlarm( (UInt *)&unused_seconds, (UInt *)&unused_nanoseconds);
    unused_microseconds = unused_nanoseconds/1000;
    /* Now the alarm might have gone off since we executed the last statement 
       of func. So */
    if (SyAlarmHasGoneOff) {
      SyAlarmHasGoneOff = 0;
      UnInterruptExecStat();
    }
    assert(NumAlarmJumpBuffers);
    NumAlarmJumpBuffers--;
     
    /* If there is an outer timer, we need to reset it */
    if (mayNeedToRestore) {
      restore_seconds = curr_seconds - (iseconds - unused_seconds);
      restore_microseconds = curr_microseconds - (imicroseconds - unused_microseconds);
      while (restore_microseconds < 0) {
        restore_microseconds += 1000000;
        restore_seconds -= 1;
      }
      while (restore_microseconds > 999999) {
        restore_microseconds -= 1000000;
        restore_seconds += 1;
      }

      /* nasty hack -- if the outer timer was right on the edge of going off
         and we try to restore it to zero we will actually stop it */
      if (!restore_seconds && !restore_microseconds)
        restore_microseconds = 1;

      SyInstallAlarm(restore_seconds, 1000*restore_microseconds);
    }
     
  }
   
  /* assemble and return the result */
  res = NEW_PLIST(T_PLIST_DENSE+IMMUTABLE, 2);
  SET_ELM_PLIST(res,1,True);
  if (result) {
    SET_LEN_PLIST(res,2);
    SET_ELM_PLIST(res,2,result);
    CHANGED_BAG(res);
  } else {
    SET_LEN_PLIST(res,1);
  }
  return res;
#endif
}

Obj FuncSTOP_TIMEOUT( Obj self ) {
  UInt seconds, nanoseconds;
  if (!SyHaveAlarms || !SyAlarmRunning) 
    return Fail;
  SyStopAlarm(&seconds, &nanoseconds);
  Obj state = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, 3);
  SET_ELM_PLIST(state,1,INTOBJ_INT(seconds));
  SET_ELM_PLIST(state,2,INTOBJ_INT(nanoseconds/1000));
  SET_ELM_PLIST(state,3,INTOBJ_INT(NumAlarmJumpBuffers));
  SET_LEN_PLIST(state,3);
  return state;
}

Obj FuncRESUME_TIMEOUT( Obj self, Obj state ) {
  if (!SyHaveAlarms || SyAlarmRunning) 
    return Fail;
  if (!IS_PLIST(state) || LEN_PLIST(state) < 2)
    return Fail;
  if (!IS_INTOBJ(ELM_PLIST(state,1)) ||
      !IS_INTOBJ(ELM_PLIST(state,2)))
    return Fail;
  Int s = INT_INTOBJ(ELM_PLIST(state,1));
  Int us = INT_INTOBJ(ELM_PLIST(state,2));
  if (s < 0 || us < 0 || us > 999999)
    return Fail;
  Int depth = INT_INTOBJ(ELM_PLIST(state,3));
  if (depth < 0 || depth >= MAX_TIMEOUT_NESTING_DEPTH)
    return Fail;
  NumAlarmJumpBuffers = depth;
  SyInstallAlarm(s, 1000*us);
  return True;
}

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

enum {signalBreakFuncListLen = 16 };

static intfunc signalBreakFuncList[signalBreakFuncListLen];

Int RegisterBreakloopObserver(intfunc func)
{
    Int i;
    for (i = 0; i < signalBreakFuncListLen; ++i) {
        if (signalBreakFuncList[i] == 0) {
            signalBreakFuncList[i] = func;
            return 1;
        }
    }
    return 0;
}

/****************************************************************************
**
*F  ErrorQuit( <msg>, <arg1>, <arg2> )  . . . . . . . . . . .  print and quit
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
  C_NEW_STRING_DYN(Message, message);
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
  Obj EarlyMsg;
  Obj r = NEW_PREC(0);
  Obj l;
  Int i;

#ifdef HPCGAP
  Region *savedRegion = TLS(currentRegion);
  TLS(currentRegion) = TLS(threadRegion);
#endif
  EarlyMsg = ErrorMessageToGAPString(msg, arg1, arg2);
  AssPRec(r, RNamName("context"), STATE(CurrLVars));
  AssPRec(r, RNamName("justQuit"), justQuit? True : False);
  AssPRec(r, RNamName("mayReturnObj"), mayReturnObj? True : False);
  AssPRec(r, RNamName("mayReturnVoid"), mayReturnVoid? True : False);
  AssPRec(r, RNamName("printThisStatement"), printThisStatement? True : False);
  AssPRec(r, RNamName("lateMessage"), lateMessage);
  l = NEW_PLIST(T_PLIST_HOM+IMMUTABLE, 1);
  SET_ELM_PLIST(l,1,EarlyMsg);
  SET_LEN_PLIST(l,1);
  SET_BRK_CALL_TO(STATE(CurrStat));
  // Signal functions about entering and leaving break loop
  for (i = 0; i < 16 && signalBreakFuncList[i]; ++i)
      (signalBreakFuncList[i])(1);
  Obj res = CALL_2ARGS(ErrorInner,r,l);
#ifdef HPCGAP
  TLS(currentRegion) = savedRegion;
#endif
  for (i = 0; i < 16 && signalBreakFuncList[i]; ++i)
      (signalBreakFuncList[i])(0);
  return res;
}

void ErrorQuit (
    const Char *        msg,
    Int                 arg1,
    Int                 arg2 )
{
  CallErrorInner(msg, arg1, arg2, 1, 0, 0, False, 1);
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
  C_NEW_STRING_DYN(LateMsg, msg2);
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
  C_NEW_STRING_DYN(LateMsg, msg2);
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
  CallErrorInner(msg, arg1, arg2, 0, 0,0, False, 1);
 
}

Obj Error;
Obj ErrorInner;

 

/*************************************************************************
**
*F * * * * * * * * * functions for dynamical/static modules * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncGAP_CRC( <self>, <name> ) . . . . . . . create a crc value for a file
*/
Obj FuncGAP_CRC (
    Obj                 self,
    Obj                 filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }

    /* compute the crc value                                               */
    return INTOBJ_INT( SyGAPCRC( CSTR_STRING(filename) ) );
}


/****************************************************************************
**
*F  FuncLOAD_DYN( <self>, <name>, <crc> ) . . .  try to load a dynamic module
*/
Obj FuncLOAD_DYN (
    Obj                 self,
    Obj                 filename,
    Obj                 crc )
{
    InitInfoFunc        init;
    StructInitInfo *    info;
    Obj                 crc1;
    Int                 res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    while ( ! IS_INTOBJ(crc) && crc!=False ) {
        crc = ErrorReturnObj(
            "<crc> must be a small integer or 'false' (not a %s)",
            (Int)TNAM_OBJ(crc), 0L,
            "you can replace <crc> via 'return <crc>;'" );
    }

    /* try to read the module                                              */
    res = SyLoadModule( CSTR_STRING(filename), &init );
    if ( res == 1 )
        ErrorQuit( "module '%s' not found", (Int)CSTR_STRING(filename), 0L );
    else if ( res == 3 )
        ErrorQuit( "symbol 'Init_Dynamic' not found", 0L, 0L );
    else if ( res == 5 )
        ErrorQuit( "forget symbol failed", 0L, 0L );

    /* no dynamic library support                                          */
    else if ( res == 7 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  LOAD_DYN: no support for dynamical loading\n", 0L, 0L );
        }
        return False; 
    }

    /* get the description structure                                       */
    info = (*init)();
    if ( info == 0 )
        ErrorQuit( "call to init function failed", 0L, 0L );

    /* check the crc value                                                 */
    if ( crc != False ) {
        crc1 = INTOBJ_INT( info->crc );
        if ( ! EQ( crc, crc1 ) ) {
            if ( SyDebugLoading ) {
                Pr( "#I  LOAD_DYN: crc values do not match, gap ", 0L, 0L );
                PrintInt( crc );
                Pr( ", dyn ", 0L, 0L );
                PrintInt( crc1 );
                Pr( "\n", 0L, 0L );
            }
            return False;
        }
    }

    /* link and init me                                                    */
    info->isGapRootRelative = 0;
    res = (info->initKernel)(info);
    UpdateCopyFopyInfo();

    /* Start a new executor to run the outer function of the module
       in global context */
    ExecBegin( STATE(BottomLVars) );
    res = res || (info->initLibrary)(info);
    ExecEnd(res ? STATUS_ERROR : STATUS_END);
    if ( res ) {
        Pr( "#W  init functions returned non-zero exit code\n", 0L, 0L );
    }
    RecordLoadedModule(info, CSTR_STRING(filename));

    return True;
}


/****************************************************************************
**
*F  FuncLOAD_STAT( <self>, <name>, <crc> )  . . . . try to load static module
*/
Obj FuncLOAD_STAT (
    Obj                 self,
    Obj                 filename,
    Obj                 crc )
{
    StructInitInfo *    info = 0;
    Obj                 crc1;
    Int                 k;
    Int                 res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    while ( !IS_INTOBJ(crc) && crc!=False ) {
        crc = ErrorReturnObj(
            "<crc> must be a small integer or 'false' (not a %s)",
            (Int)TNAM_OBJ(crc), 0L,
            "you can replace <crc> via 'return <crc>;'" );
    }

    /* try to find the module                                              */
    for ( k = 0;  CompInitFuncs[k];  k++ ) {
        info = (*(CompInitFuncs[k]))();
        if ( info == 0 ) {
            continue;
        }
        if ( ! strcmp( CSTR_STRING(filename), info->name ) ) {
            break;
        }
    }
    if ( CompInitFuncs[k] == 0 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  LOAD_STAT: no module named '%s' found\n",
                (Int)CSTR_STRING(filename), 0L );
        }
        return False;
    }

    /* check the crc value                                                 */
    if ( crc != False ) {
        crc1 = INTOBJ_INT( info->crc );
        if ( ! EQ( crc, crc1 ) ) {
            if ( SyDebugLoading ) {
                Pr( "#I  LOAD_STAT: crc values do not match, gap ", 0L, 0L );
                PrintInt( crc );
                Pr( ", stat ", 0L, 0L );
                PrintInt( crc1 );
                Pr( "\n", 0L, 0L );
            }
            return False;
        }
    }

    /* link and init me                                                    */
    info->isGapRootRelative = 0;
    res = (info->initKernel)(info);
    UpdateCopyFopyInfo();
    /* Start a new executor to run the outer function of the module
       in global context */
    ExecBegin( STATE(BottomLVars) );
    res = res || (info->initLibrary)(info);
    ExecEnd(res ? STATUS_ERROR : STATUS_END);
    if ( res ) {
        Pr( "#W  init functions returned non-zero exit code\n", 0L, 0L );
    }
    RecordLoadedModule(info, CSTR_STRING(filename));

    return True;
}


/****************************************************************************
**
*F  FuncSHOW_STAT() . . . . . . . . . . . . . . . . . . . show static modules
*/
Obj FuncSHOW_STAT (
    Obj                 self )
{
    Obj                 modules;
    Obj                 name;
    StructInitInfo *    info;
    Int                 k;
    Int                 im;

    /* count the number of install modules                                 */
    for ( k = 0,  im = 0;  CompInitFuncs[k];  k++ ) {
        info = (*(CompInitFuncs[k]))();
        if ( info == 0 ) {
            continue;
        }
        im++;
    }

    /* make a list of modules with crc values                              */
    modules = NEW_PLIST( T_PLIST, 2*im );
    SET_LEN_PLIST( modules, 2*im );

    for ( k = 0,  im = 1;  CompInitFuncs[k];  k++ ) {
        info = (*(CompInitFuncs[k]))();
        if ( info == 0 ) {
            continue;
        }
        C_NEW_STRING_DYN(name, info->name);

        SET_ELM_PLIST( modules, im, name );

        /* compute the crc value                                           */
        SET_ELM_PLIST( modules, im+1, INTOBJ_INT( info->crc ) );
        im += 2;
    }

    return modules;
}


/****************************************************************************
**
*F  FuncLoadedModules( <self> ) . . . . . . . . . . . list all loaded modules
*/
Obj FuncLoadedModules (
    Obj                 self )
{
    Int                 i;
    StructInitInfo *    m;
    Obj                 str;
    Obj                 list;

    /* create a list                                                       */
    list = NEW_PLIST( T_PLIST, NrModules * 3 );
    SET_LEN_PLIST( list, NrModules * 3 );
    for ( i = 0;  i < NrModules;  i++ ) {
        m = Modules[i];
        if ( m->type == MODULE_BUILTIN ) {
            SET_ELM_PLIST( list, 3*i+1, ObjsChar[(Int)'b'] );
            CHANGED_BAG(list);
            C_NEW_STRING_DYN( str, m->name );
            SET_ELM_PLIST( list, 3*i+2, str );
            SET_ELM_PLIST( list, 3*i+3, INTOBJ_INT(m->version) );
        }
        else if ( m->type == MODULE_DYNAMIC ) {
            SET_ELM_PLIST( list, 3*i+1, ObjsChar[(Int)'d'] );
            CHANGED_BAG(list);
            C_NEW_STRING_DYN( str, m->name );
            SET_ELM_PLIST( list, 3*i+2, str );
            CHANGED_BAG(list);
            C_NEW_STRING_DYN( str, m->filename );
            SET_ELM_PLIST( list, 3*i+3, str );
        }
        else if ( m->type == MODULE_STATIC ) {
            SET_ELM_PLIST( list, 3*i+1, ObjsChar[(Int)'s'] );
            CHANGED_BAG(list);
            C_NEW_STRING_DYN( str, m->name );
            SET_ELM_PLIST( list, 3*i+2, str );
            CHANGED_BAG(list);
            C_NEW_STRING_DYN( str, m->filename );
            SET_ELM_PLIST( list, 3*i+3, str );
        }
    }
    return CopyObj( list, 0 );
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
    Obj                 cmd;            /* argument                        */
    UInt                i,  k;          /* loop variables                  */
    Char                buf[41];

    /* check the argument                                                  */
    if ( ! IS_SMALL_LIST(args) || LEN_LIST(args) == 0 ) {
        ErrorMayQuit(
            "usage: GASMAN( \"display\"|\"displayshort\"|\"clear\"|\"collect\"|\"message\"|\"partial\" )",
            0L, 0L);
    }

    /* loop over the arguments                                             */
    for ( i = 1; i <= LEN_LIST(args); i++ ) {

        /* evaluate and check the command                                  */
        cmd = ELM_PLIST( args, i );
again:
        while ( ! IsStringConv(cmd) ) {
           cmd = ErrorReturnObj(
               "GASMAN: <cmd> must be a string (not a %s)",
               (Int)TNAM_OBJ(cmd), 0L,
               "you can replace <cmd> via 'return <cmd>;'" );
       }

        /* if request display the statistics                               */
        if ( strcmp( CSTR_STRING(cmd), "display" ) == 0 ) {
            Pr( "%40s ", (Int)"type",  0L          );
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( k = 0; k < 256; k++ ) {
                if ( InfoBags[k].name != 0 ) {
                    buf[0] = '\0';
                    strlcat( buf, InfoBags[k].name, sizeof(buf) );
                    Pr("%40s ",    (Int)buf, 0L );
                    Pr("%8d %8d ", (Int)InfoBags[k].nrLive,
                                   (Int)(InfoBags[k].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[k].nrAll,
                                   (Int)(InfoBags[k].sizeAll/1024));
                }
            }
        }

        /* if request give a short display of the statistics                */
        else if ( strcmp( CSTR_STRING(cmd), "displayshort" ) == 0 ) {
            Pr( "%40s ", (Int)"type",  0L          );
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( k = 0; k < 256; k++ ) {
                if ( InfoBags[k].name != 0 && 
                     (InfoBags[k].nrLive != 0 ||
                      InfoBags[k].sizeLive != 0 ||
                      InfoBags[k].nrAll != 0 ||
                      InfoBags[k].sizeAll != 0) ) {
                    buf[0] = '\0';
                    strlcat( buf, InfoBags[k].name, sizeof(buf) );
                    Pr("%40s ",    (Int)buf, 0L );
                    Pr("%8d %8d ", (Int)InfoBags[k].nrLive,
                                   (Int)(InfoBags[k].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[k].nrAll,
                                   (Int)(InfoBags[k].sizeAll/1024));
                }
            }
        }

        /* if request display the statistics                               */
        else if ( strcmp( CSTR_STRING(cmd), "clear" ) == 0 ) {
            for ( k = 0; k < 256; k++ ) {
#ifdef GASMAN_CLEAR_TO_LIVE
                InfoBags[k].nrAll    = InfoBags[k].nrLive;
                InfoBags[k].sizeAll  = InfoBags[k].sizeLive;
#else
                InfoBags[k].nrAll    = 0;
                InfoBags[k].sizeAll  = 0;
#endif
            }
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
    }

    /* return nothing, this function is a procedure                        */
    return 0;
}

Obj FuncGASMAN_STATS(Obj self)
{
  Obj res;
  Obj row;
  Obj entry;
  UInt i,j;
  Int x;
  res = NEW_PLIST(T_PLIST_TAB_RECT + IMMUTABLE, 2);
  SET_LEN_PLIST(res, 2);
  for (i = 1; i <= 2; i++)
    {
      row = NEW_PLIST(T_PLIST_CYC + IMMUTABLE, 9);
      SET_ELM_PLIST(res, i, row);
      CHANGED_BAG(res);
      SET_LEN_PLIST(row, 9);
      for (j = 1; j <= 8; j++)
        {
          x = SyGasmanNumbers[i-1][j];

          /* convert x to GAP integer. x may be too big to be a small int */
          if (x < (1L << NR_SMALL_INT_BITS))
            entry = INTOBJ_INT(x);
          else
            entry = SUM( PROD(INTOBJ_INT(x >> (NR_SMALL_INT_BITS/2)),
                              INTOBJ_INT(1 << (NR_SMALL_INT_BITS/2))),
                         INTOBJ_INT( x % ( 1 << (NR_SMALL_INT_BITS/2))));
          SET_ELM_PLIST(row, j, entry);
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
  list = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, 3);
  SET_LEN_PLIST(list,3);
  SET_ELM_PLIST(list, 1, INTOBJ_INT(SyStorMin));
  SET_ELM_PLIST(list, 2, INTOBJ_INT(SyStorMax));
  SET_ELM_PLIST(list, 3, INTOBJ_INT(SyStorKill));
  return list;
}

/****************************************************************************
**
*F  FuncSHALLOW_SIZE( <self>, <obj> ) . . . .  expert function 'SHALLOW_SIZE'
*/
Obj FuncSHALLOW_SIZE (
    Obj                 self,
    Obj                 obj )
{
  if (IS_INTOBJ(obj) || IS_FFE(obj))
    return INTOBJ_INT(0);
  else
    return ObjInt_UInt( SIZE_BAG( obj ) );
}


/****************************************************************************
**
*F  FuncTNUM_OBJ( <self>, <obj> ) . . . . . . . .  expert function 'TNUM_OBJ'
*/

Obj FuncTNUM_OBJ (
    Obj                 self,
    Obj                 obj )
{
    Obj                 res;
    Obj                 str;
    const Char *        cst;

    res = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( res, 2 );

    /* set the type                                                        */
    SET_ELM_PLIST( res, 1, INTOBJ_INT( TNUM_OBJ(obj) ) );
    cst = TNAM_OBJ(obj);
    C_NEW_STRING_DYN(str, cst);
    SET_ELM_PLIST( res, 2, str );

    /* and return                                                          */
    return res;
}

Obj FuncTNUM_OBJ_INT (
    Obj                 self,
    Obj                 obj )
{

  
    return  INTOBJ_INT( TNUM_OBJ(obj) ) ;
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
**  This is a very quick function which returns a unique integer for each object
**  non-identical objects will have different handles. The integers may be large.
*/
Obj FuncHANDLE_OBJ (
    Obj                 self,
    Obj                 obj )
{
    Obj                 hnum;
    Obj                 prod;
    Obj                 tmp;
    UInt                hand;

    hand = (UInt) obj;
    hnum = INTOBJ_INT(0);
    prod = INTOBJ_INT(1);
    while ( 0 < hand ) {
        tmp  = PROD( prod, INTOBJ_INT( hand & 0xffff ) );
        prod = PROD( prod, INTOBJ_INT( 1 << 16 ) );
        hnum = SUM(  hnum, tmp );
        hand = hand >> 16;
    }
    return hnum;
}

/* This function does quite  a similar job to HANDLE_OBJ, but (a) returns 0 for all 
immediate objects (small integers or ffes) and (b) returns reasonably small results
(roughly in teh range from 1 to the max number of objects that have existed in this session */

Obj FuncMASTER_POINTER_NUMBER(Obj self, Obj o)
{
    if ((void **) o >= (void **) MptrBags && (void **) o < (void **) OldBags) {
        return INTOBJ_INT( ((void **) o - (void **) MptrBags) + 1 );
    } else {
        return INTOBJ_INT( 0 );
    }
}

/* Returns a measure of the size of a GAP function */
Obj FuncFUNC_BODY_SIZE(Obj self, Obj f)
{
    Obj body;
    if (TNUM_OBJ(f) != T_FUNCTION) return Fail;
    body = BODY_FUNC(f);
    if (body == 0) return INTOBJ_INT(0);
    else return INTOBJ_INT( SIZE_BAG( body ) );
}

/****************************************************************************
**
*F  FuncSWAP_MPTR( <self>, <obj1>, <obj2> ) . . . . . . . swap master pointer
**
**  Never use this function unless you are debugging.
*/
Obj FuncSWAP_MPTR (
    Obj                 self,
    Obj                 obj1,
    Obj                 obj2 )
{
    if ( IS_INTOBJ(obj1) || IS_FFE(obj1) ) {
        ErrorQuit("SWAP_MPTR: <obj1> must not be an integer or ffe", 0L, 0L);
        return 0;
    }
    if ( IS_INTOBJ(obj2) || IS_FFE(obj2) ) {
        ErrorQuit("SWAP_MPTR: <obj2> must not be an integer or ffe", 0L, 0L);
        return 0;
    }
        
    SwapMasterPoint( obj1, obj2 );
    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitBagNamesFromTable( <table> )  . . . . . . . . .  initialise bag names
*/
void InitBagNamesFromTable (
    StructBagNames *            tab )
{
    Int                         i;

    for ( i = 0;  tab[i].tnum != -1;  i++ ) {
        InfoBags[tab[i].tnum].name = tab[i].name;
    }
}


/****************************************************************************
**
*F  InitClearFiltsTNumsFromTable( <tab> ) . . .  initialise clear filts tnums
*/
void InitClearFiltsTNumsFromTable (
    Int *               tab )
{
    Int                 i;

    for ( i = 0;  tab[i] != -1;  i += 2 ) {
        ClearFiltsTNums[tab[i]] = tab[i+1];
    }
}


/****************************************************************************
**
*F  InitHasFiltListTNumsFromTable( <tab> )  . . initialise tester filts tnums
*/
void InitHasFiltListTNumsFromTable (
    Int *               tab )
{
    Int                 i;

    for ( i = 0;  tab[i] != -1;  i += 3 ) {
        HasFiltListTNums[tab[i]][tab[i+1]] = tab[i+2];
    }
}


/****************************************************************************
**
*F  InitSetFiltListTNumsFromTable( <tab> )  . . initialise setter filts tnums
*/
void InitSetFiltListTNumsFromTable (
    Int *               tab )
{
    Int                 i;

    for ( i = 0;  tab[i] != -1;  i += 3 ) {
        SetFiltListTNums[tab[i]][tab[i+1]] = tab[i+2];
    }
}


/****************************************************************************
**
*F  InitResetFiltListTNumsFromTable( <tab> )  initialise unsetter filts tnums
*/
void InitResetFiltListTNumsFromTable (
    Int *               tab )
{
    Int                 i;

    for ( i = 0;  tab[i] != -1;  i += 3 ) {
        ResetFiltListTNums[tab[i]][tab[i+1]] = tab[i+2];
    }
}


/****************************************************************************
**
*F  InitGVarFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
void InitGVarFiltsFromTable (
    StructGVarFilt *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        UInt gvar = GVarName( tab[i].name );
        AssGVar( gvar,
            NewFilter( NameGVarObj( gvar ), 1, ArgStringToList( tab[i].argument ), tab[i].handler ) );
        MakeReadOnlyGVar( gvar );
    }
}


/****************************************************************************
**
*F  InitGVarAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
void InitGVarAttrsFromTable (
    StructGVarAttr *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        UInt gvar = GVarName( tab[i].name );
        AssGVar( gvar,
            NewAttribute( NameGVarObj( gvar ),
                          1,
                          ArgStringToList( tab[i].argument ),
                          tab[i].handler ) );
        MakeReadOnlyGVar( gvar );
    }
}

void SetupFuncInfo(Obj func, const Char* cookie)
{
    const Char* pos = strchr(cookie, ':');
    if ( pos ) {
        Obj filename, start;
        Obj body_bag = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
        char buffer[512];
        Int len = 511<(pos-cookie)?511:pos-cookie;
        memcpy(buffer, cookie, len);
        buffer[len] = 0;
        C_NEW_STRING_DYN(filename, buffer);
        C_NEW_STRING_DYN(start, pos+1);
        SET_FILENAME_BODY(body_bag, filename);
        SET_LOCATION_BODY(body_bag, start);
        BODY_FUNC(func) = body_bag;
        CHANGED_BAG(body_bag);
        CHANGED_BAG(func);
    }
}

/****************************************************************************
**
*F  InitGVarPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
void InitGVarPropsFromTable (
    StructGVarProp *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        UInt gvar = GVarName( tab[i].name );
        AssGVar( gvar,
            NewProperty( NameGVarObj( gvar ),
                        1,
                        ArgStringToList( tab[i].argument ),
                        tab[i].handler ) );
        MakeReadOnlyGVar( gvar );
    }
}


/****************************************************************************
**
*F  InitGVarOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
void InitGVarOpersFromTable (
    StructGVarOper *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        UInt gvar = GVarName( tab[i].name );
        AssGVar( gvar,
            NewOperation( NameGVarObj( gvar ),
                          tab[i].nargs,
                          ArgStringToList( tab[i].args ),
                          tab[i].handler ) );
        MakeReadOnlyGVar( gvar );
    }
}


/****************************************************************************
**
*F  InitGVarFuncsFromTable( <tab> ) . . . . . . . . . . . . . . new functions
*/
void InitGVarFuncsFromTable (
    StructGVarFunc *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        UInt gvar = GVarName( tab[i].name );
        Obj func = NewFunction( NameGVarObj( gvar ),
                                tab[i].nargs,
                                ArgStringToList( tab[i].args ),
                                tab[i].handler );
        SetupFuncInfo( func, tab[i].cookie );
        AssGVar( gvar, func );
        MakeReadOnlyGVar( gvar );
    }
}


/****************************************************************************
**
*F  InitHdlrFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
void InitHdlrFiltsFromTable (
    StructGVarFilt *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        InitHandlerFunc( tab[i].handler, tab[i].cookie );
        InitFopyGVar( tab[i].name, tab[i].filter );
    }
}


/****************************************************************************
**
*F  InitHdlrAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
void InitHdlrAttrsFromTable (
    StructGVarAttr *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        InitHandlerFunc( tab[i].handler, tab[i].cookie );
        InitFopyGVar( tab[i].name, tab[i].attribute );
    }
}


/****************************************************************************
**
*F  InitHdlrPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
void InitHdlrPropsFromTable (
    StructGVarProp *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        InitHandlerFunc( tab[i].handler, tab[i].cookie );
        InitFopyGVar( tab[i].name, tab[i].property );
    }
}


/****************************************************************************
**
*F  InitHdlrOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
void InitHdlrOpersFromTable (
    StructGVarOper *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        InitHandlerFunc( tab[i].handler, tab[i].cookie );
        InitFopyGVar( tab[i].name, tab[i].operation );
    }
}


/****************************************************************************
**
*F  InitHdlrFuncsFromTable( <tab> ) . . . . . . . . . . . . . . new functions
*/
void InitHdlrFuncsFromTable (
    StructGVarFunc *    tab )
{
    Int                 i;

    for ( i = 0;  tab[i].name != 0;  i++ ) {
        InitHandlerFunc( tab[i].handler, tab[i].cookie );
    }
}


/****************************************************************************
**
*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/


void ImportGVarFromLibrary(
    const Char *        name,
    Obj *               address )
{
    if ( NrImportedGVars == 1024 ) {
        Pr( "#W  warning: too many imported GVars\n", 0L, 0L );
    }
    else {
        ImportedGVars[NrImportedGVars].name    = name;
        ImportedGVars[NrImportedGVars].address = address;
        NrImportedGVars++;
    }
    if ( address != 0 ) {
        InitCopyGVar( name, address );
    }
}


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/


void ImportFuncFromLibrary(
    const Char *        name,
    Obj *               address )
{
    if ( NrImportedFuncs == 1024 ) {
        Pr( "#W  warning: too many imported Funcs\n", 0L, 0L );
    }
    else {
        ImportedFuncs[NrImportedFuncs].name    = name;
        ImportedFuncs[NrImportedFuncs].address = address;
        NrImportedFuncs++;
    }
    if ( address != 0 ) {
        InitFopyGVar( name, address );
    }
}


/****************************************************************************
**
*F  FuncExportToKernelFinished( <self> )  . . . . . . . . . . check functions
*/
Obj FuncExportToKernelFinished (
    Obj             self )
{
    UInt            i;
    Int             errs = 0;
    Obj             val;

    SyInitializing = 0;
    for ( i = 0;  i < NrImportedGVars;  i++ ) {
        if ( ImportedGVars[i].address == 0 ) {
            val = ValAutoGVar(GVarName(ImportedGVars[i].name));
            if ( val == 0 ) {
                errs++;
                if ( ! SyQuiet ) {
                    Pr( "#W  global variable '%s' has not been defined\n",
                        (Int)ImportedFuncs[i].name, 0L );
                }
            }
        }
        else if ( *ImportedGVars[i].address == 0 ) {
            errs++;
            if ( ! SyQuiet ) {
                Pr( "#W  global variable '%s' has not been defined\n",
                    (Int)ImportedGVars[i].name, 0L );
            }
        }
        else {
            MakeReadOnlyGVar(GVarName(ImportedGVars[i].name));
        }
    }
    
    for ( i = 0;  i < NrImportedFuncs;  i++ ) {
        if (  ImportedFuncs[i].address == 0 ) {
            val = ValAutoGVar(GVarName(ImportedFuncs[i].name));
            if ( val == 0 || ! IS_FUNC(val) ) {
                errs++;
                if ( ! SyQuiet ) {
                    Pr( "#W  global function '%s' has not been defined\n",
                        (Int)ImportedFuncs[i].name, 0L );
                }
            }
        }
        else if ( *ImportedFuncs[i].address == ErrorMustEvalToFuncFunc
          || *ImportedFuncs[i].address == ErrorMustHaveAssObjFunc )
        {
            errs++;
            if ( ! SyQuiet ) {
                Pr( "#W  global function '%s' has not been defined\n",
                    (Int)ImportedFuncs[i].name, 0L );
            }
        }
        else {
            MakeReadOnlyGVar(GVarName(ImportedFuncs[i].name));
        }
    }
    
    return errs == 0 ? True : False;
}


/****************************************************************************
**
*F  FuncSleep( <self>, <secs> )
**
*/

Obj FuncSleep( Obj self, Obj secs )
{
  Int  s;

  while( ! IS_INTOBJ(secs) )
    secs = ErrorReturnObj( "<secs> must be a small integer", 0L, 0L, 
                           "you can replace <secs> via 'return <secs>;'" );

  
  if ( (s = INT_INTOBJ(secs)) > 0)
    SySleep((UInt)s);
  
  /* either we used up the time, or we were interrupted. */
  if (SyIsIntr())
    {
      ClearError(); /* The interrupt may still be pending */
      ErrorReturnVoid("user interrupt in sleep", 0L, 0L,
                    "you can 'return;' as if the sleep was finished");
    }
  
  return (Obj) 0;
}


#ifdef HPCGAP

/****************************************************************************
**
*F  FuncMicroSleep( <self>, <secs> )
**
*/

Obj FuncMicroSleep( Obj self, Obj msecs )
{
  extern UInt HaveInterrupt();
  Int  s;

  while( ! IS_INTOBJ(msecs) )
    msecs = ErrorReturnObj( "<usecs> must be a small integer", 0L, 0L, 
                           "you can replace <usecs> via 'return <usecs>;'" );

  
  if ( (s = INT_INTOBJ(msecs)) > 0)
    SyUSleep((UInt)s);
  
  /* either we used up the time, or we were interrupted. */
  if (HaveInterrupt())
    {
      ClearError(); /* The interrupt may still be pending */
      ErrorReturnVoid("user interrupt in microsleep", 0L, 0L,
                    "you can 'return;' as if the microsleep was finished");
    }
  
  return (Obj) 0;
}

#endif


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
    return 0;
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
    return 0;
  }
  SyExit(SystemErrorCode);
  return (Obj) 0; /* should never get here */
}

/****************************************************************************
**
*F  FuncShouldQuitOnBreak()
**
*/

Obj FuncShouldQuitOnBreak( Obj self)
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
  C_NEW_STRING_DYN( tmp, SyArchitecture );
  RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
  r = RNamName("GAP_ARCHITECTURE");
  AssPRec(res,r,tmp);
  /* KERNEL_VERSION */
  C_NEW_STRING_DYN( tmp, SyKernelVersion );
  RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
  r = RNamName("KERNEL_VERSION");
  AssPRec(res,r,tmp);
  C_NEW_STRING_DYN( tmp, SyBuildVersion );
  RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
  r = RNamName("BUILD_VERSION");
  AssPRec(res,r,tmp);
  C_NEW_STRING_DYN( tmp, SyBuildDateTime );
  RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
  r = RNamName("BUILD_DATETIME");
  AssPRec(res,r,tmp);
  /* GAP_ROOT_PATH                                                       */
  /* do we need this. Could we rebuild it from the command line in GAP
     if so, should we                                                    */
  list = NEW_PLIST( T_PLIST+IMMUTABLE, MAX_GAP_DIRS );
  for ( i = 0, j = 1;  i < MAX_GAP_DIRS;  i++ ) {
    if ( SyGapRootPaths[i][0] ) {
      C_NEW_STRING_DYN( tmp, SyGapRootPaths[i] );
      RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
      SET_ELM_PLIST( list, j, tmp );
      j++;
    }
  }
  SET_LEN_PLIST( list, j-1 );
  r = RNamName("GAP_ROOT_PATHS");
  AssPRec(res,r,list);
  /* And also the DotGapPath if available */
#if HAVE_DOTGAPRC
  C_NEW_STRING_DYN( tmp, DotGapPath );
  RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
  r = RNamName("DOT_GAP_PATH");
  AssPRec(res,r,tmp);
#endif
    
  /* make command line and environment available to GAP level       */
  for (lenvec=0; SyOriginalArgv[lenvec]; lenvec++);
  tmp = NEW_PLIST( T_PLIST+IMMUTABLE, lenvec );
  SET_LEN_PLIST( tmp, lenvec );
  for (i = 0; i<lenvec; i++) {
    C_NEW_STRING_DYN( str, SyOriginalArgv[i] );
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

  /* and also the CONFIGNAME of the running  GAP kernel  */
  C_NEW_STRING_DYN( str, CONFIGNAME );
  r = RNamName("CONFIGNAME");
  AssPRec(res, r, str);
#ifdef HPCGAP
  extern UInt SyNumProcessors;
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
  C_NEW_STRING_DYN( str, gmp_version );
  RetypeBag( str, IMMUTABLE_TNUM(TNUM_OBJ(str)) );
  r = RNamName("GMP_VERSION");
  AssPRec(res, r, str);

  MakeImmutable(res);
  
  return res;
  
}


#ifdef HPCGAP

/****************************************************************************
**
*F FuncTHREAD_UI  ... Whether we use a multi-threaded interface
**
*/

Obj FuncTHREAD_UI(Obj self)
{
  extern UInt ThreadUI;
  return ThreadUI ? True : False;
}


GVarDescriptor GVarTHREAD_INIT;
GVarDescriptor GVarTHREAD_EXIT;

void ThreadedInterpreter(void *funcargs) {
  Obj tmp, func;
  int i;

  /* intialize everything and begin an interpreter                       */
  STATE(StackNams)   = NEW_PLIST( T_PLIST, 16 );
  STATE(CountNams)   = 0;
  STATE(ReadTop)     = 0;
  STATE(ReadTilde)   = 0;
  STATE(CurrLHSGVar) = 0;
  STATE(IntrCoding) = 0;
  STATE(IntrIgnoring) = 0;
  STATE(NrError) = 0;
  STATE(ThrownObject) = 0;
  STATE(BottomLVars) = NewBag( T_HVARS, 3*sizeof(Obj) );
  tmp = NewFunctionC( "bottom", 0, "", 0 );
  PTR_BAG(STATE(BottomLVars))[0] = tmp;
  tmp = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
  BODY_FUNC( PTR_BAG(STATE(BottomLVars))[0] ) = tmp;
  STATE(CurrLVars) = STATE(BottomLVars);

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
    if (sySetjmp(STATE(threadExit)))
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
static StructGVarFunc GVarFuncs [] = {

    { "Runtime", 0, "",
      FuncRuntime, "src/gap.c:Runtime" },

    { "RUNTIMES", 0, "",
      FuncRUNTIMES, "src/gap.c:RUNTIMES" },

    { "NanosecondsSinceEpoch", 0, "",
      FuncNanosecondsSinceEpoch, "src/gap.c:NanosecondsSinceEpoch" },

    { "NanosecondsSinceEpochInfo", 0, "",
      FuncNanosecondsSinceEpochInfo, "src/gap.c:NanosecondsSinceEpochInfo" },

    { "SizeScreen", -1, "args",
      FuncSizeScreen, "src/gap.c:SizeScreen" },

    { "ID_FUNC", 1, "object",
      FuncID_FUNC, "src/gap.c:ID_FUNC" },

    { "RETURN_FIRST", -1, "object",
      FuncRETURN_FIRST, "src/gap.c:RETURN_FIRST" },

    { "RETURN_NOTHING", -1, "object",
      FuncRETURN_NOTHING, "src/gap.c:RETURN_NOTHING" },

    { "ExportToKernelFinished", 0, "",
      FuncExportToKernelFinished, "src/gap.c:ExportToKernelFinished" },

    { "DownEnv", -1, "args",
      FuncDownEnv, "src/gap.c:DownEnv" },

    { "UpEnv", -1, "args",
      FuncUpEnv, "src/gap.c:UpEnv" },

    { "GAP_CRC", 1, "filename",
      FuncGAP_CRC, "src/gap.c:GAP_CRC" },

    { "LOAD_DYN", 2, "filename, crc",
      FuncLOAD_DYN, "src/gap.c:LOAD_DYN" },

    { "LOAD_STAT", 2, "filename, crc",
      FuncLOAD_STAT, "src/gap.c:LOAD_STAT" },

    { "SHOW_STAT", 0, "",
      FuncSHOW_STAT, "src/gap.c:SHOW_STAT" },

    { "GASMAN", -1, "args",
      FuncGASMAN, "src/gap.c:GASMAN" },

    { "GASMAN_STATS", 0, "",
      FuncGASMAN_STATS, "src/gap.c:GASMAN_STATS" },

    { "GASMAN_MESSAGE_STATUS", 0, "",
      FuncGASMAN_MESSAGE_STATUS, "src/gap.c:GASMAN_MESSAGE_STATUS" },

    { "GASMAN_LIMITS", 0, "",
      FuncGASMAN_LIMITS, "src/gap.c:GASMAN_LIMITS" },

    { "SHALLOW_SIZE", 1, "object",
      FuncSHALLOW_SIZE, "src/gap.c:SHALLOW_SIZE" },

    { "TNUM_OBJ", 1, "object",
      FuncTNUM_OBJ, "src/gap.c:TNUM_OBJ" },

    { "TNUM_OBJ_INT", 1, "object",
      FuncTNUM_OBJ_INT, "src/gap.c:TNUM_OBJ_INT" },

    { "OBJ_HANDLE", 1, "object",
      FuncOBJ_HANDLE, "src/gap.c:OBJ_HANDLE" },

    { "HANDLE_OBJ", 1, "object",
      FuncHANDLE_OBJ, "src/gap.c:HANDLE_OBJ" },

    { "SWAP_MPTR", 2, "obj1, obj2",
      FuncSWAP_MPTR, "src/gap.c:SWAP_MPTR" },

    { "LoadedModules", 0, "",
      FuncLoadedModules, "src/gap.c:LoadedModules" },

    { "WindowCmd", 1, "arg-list",
      FuncWindowCmd, "src/gap.c:WindowCmd" },

#ifdef HPCGAP
    { "MicroSleep", 1, "msecs",
      FuncMicroSleep, "src/gap.c:MicroSleep" },
#endif

    { "Sleep", 1, "secs",
      FuncSleep, "src/gap.c:Sleep" },

    { "GAP_EXIT_CODE", 1, "exit code",
      FuncGAP_EXIT_CODE, "src/gap.c:GAP_EXIT_CODE" },

    { "QUIT_GAP", -1, "args",
      FuncQUIT_GAP, "src/gap.c:QUIT_GAP" },

    { "FORCE_QUIT_GAP", -1, "args",
      FuncFORCE_QUIT_GAP, "src/gap.c:FORCE_QUIT_GAP" },

    { "SHOULD_QUIT_ON_BREAK", 0, "",
      FuncShouldQuitOnBreak, "src/gap.c:FuncShouldQuitOnBreak"},

    { "SHELL", -1, "context, canReturnVoid, canReturnObj, lastDepth, setTime, prompt, promptHook, infile, outfile",
      FuncSHELL, "src/gap.c:FuncSHELL" },

    { "CALL_WITH_CATCH", 2, "func, args",
      FuncCALL_WITH_CATCH, "src/gap.c:CALL_WITH_CATCH" },

    { "TIMEOUTS_SUPPORTED", 0, "",
      FuncTIMEOUTS_SUPPORTED, "src/gap.c:TIMEOUTS_SUPPORTED" },

    { "CALL_WITH_TIMEOUT", 4, "seconds, microseconds, func, args",
      FuncCALL_WITH_TIMEOUT, "src/gap.c:CALL_WITH_TIMEOUT" },

    {"STOP_TIMEOUT", 0, "",
     FuncSTOP_TIMEOUT, "src/gap.c:FuncSTOP_TIMEOUT" },

    {"RESUME_TIMEOUT", 1, "state",
     FuncRESUME_TIMEOUT, "src/gap.c:FuncRESUME_TIMEOUT" },

    { "JUMP_TO_CATCH", 1, "payload",
      FuncJUMP_TO_CATCH, "src/gap.c:JUMP_TO_CATCH" },


    { "KERNEL_INFO", 0, "",
      FuncKERNEL_INFO, "src/gap.c:KERNEL_INFO" },

#ifdef HPCGAP
    { "THREAD_UI", 0, "",
      FuncTHREAD_UI, "src/gap.c:THREAD_UI" },
#endif

    { "SetUserHasQuit", 1, "value",
      FuncSetUserHasQuit, "src/gap.c:SetUserHasQuit" },

    { "MASTER_POINTER_NUMBER", 1, "ob",
      FuncMASTER_POINTER_NUMBER, "src/gap.c:MASTER_POINTER_NUMBER" },

    { "FUNC_BODY_SIZE", 1, "f",
      FuncFUNC_BODY_SIZE, "src/gap.c:FUNC_BODY_SIZE" },

    { "PRINT_CURRENT_STATEMENT", 1, "context",
      FuncPrintExecutingStatement, "src/gap.c:PRINT_CURRENT_STATEMENT" },

    { "CURRENT_STATEMENT_LOCATION", 1, "context",
      FuncExecutingStatementLocation,
      "src/gap.c:CURRENT_STATEMENT_LOCATION" },

    { 0 }

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

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );



    /* establish Fopy of ViewObj                                           */
    ImportFuncFromLibrary(  "ViewObj", 0L );
    ImportFuncFromLibrary(  "Error", &Error );
    ImportFuncFromLibrary(  "ErrorInner", &ErrorInner );

#ifdef HPCGAP
    DeclareGVar(&GVarTHREAD_INIT, "THREAD_INIT");
    DeclareGVar(&GVarTHREAD_EXIT, "THREAD_EXIT");
#endif

#if HAVE_SELECT
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
    AssGVar(Time, INTOBJ_INT(0));
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

    /* return success                                                      */
    return PostRestore( module );
}


/****************************************************************************
**
*F  InitInfoGap() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "gap",                              /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    PostRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoGap ( void )
{
    return &module;
}


/****************************************************************************
**

*V  InitFuncsBuiltinModules . . . . .  list of builtin modules init functions
*/
static InitInfoFunc InitFuncsBuiltinModules[] = {

    /* global variables                                                    */
    InitInfoGVars,

    /* objects                                                             */
    InitInfoObjects,

    /* profiling and interpreter hooking information */
    InitInfoProfile,
    InitInfoHookIntrprtr,

    /* scanner, reader, interpreter, coder, caller, compiler               */
    InitInfoScanner,
    InitInfoRead,
    InitInfoCalls,
    InitInfoExprs,
    InitInfoStats,
    InitInfoCode,
    InitInfoVars,       /* must come after InitExpr and InitStats */
    InitInfoFuncs,
    InitInfoOpers,
    InitInfoIntrprtr,
    InitInfoCompiler,

    /* arithmetic operations                                               */
    InitInfoAriths,
    InitInfoInt,
    InitInfoIntFuncs,
    InitInfoRat,
    InitInfoCyc,
    InitInfoFinfield,
    InitInfoPermutat,
    InitInfoTrans,
    InitInfoPPerm,
    InitInfoBool,
    InitInfoMacfloat,

    /* record packages                                                     */
    InitInfoRecords,
    InitInfoPRecord,

    /* list packages                                                       */
    InitInfoLists,
    InitInfoListOper,
    InitInfoListFunc,
    InitInfoPlist,
    InitInfoSet,
    InitInfoVector,
    InitInfoVecFFE,
    InitInfoBlist,
    InitInfoRange,
    InitInfoString,
    InitInfoGF2Vec,
    InitInfoVec8bit,

    /* free and presented groups                                           */
    InitInfoFreeGroupElements,
    InitInfoCosetTable,
    InitInfoTietze,
    InitInfoPcElements,
    InitInfoSingleCollector,
    InitInfoCombiCollector,
    InitInfoPcc,
    InitInfoDeepThought,
    InitInfoDTEvaluation,

    /* algebras                                                            */
    InitInfoSCTable,

    /* save and load workspace, weak pointers                              */
    InitInfoWeakPtr,
    InitInfoSaveLoad,

    /* input and output                                                    */
    InitInfoStreams,
    InitInfoSysFiles,
    InitInfoIOStream,

    /* main module                                                         */
    InitInfoGap,

#ifdef HPCGAP
    /* threads                                                             */
    InitInfoThreadAPI,
    InitInfoAObjects,
    InitInfoObjSets,
    InitInfoSerialize,
#endif

#ifdef GAPMPI
    /* ParGAP/MPI module                                                   */
    InitInfoGapmpi,
#endif

    0
};


/****************************************************************************
**
*F  Modules . . . . . . . . . . . . . . . . . . . . . . . . . list of modules
*/
#ifndef MAX_MODULES
#define MAX_MODULES     1000
#endif


#ifndef MAX_MODULE_FILENAMES
#define MAX_MODULE_FILENAMES (MAX_MODULES*50)
#endif

Char LoadedModuleFilenames[MAX_MODULE_FILENAMES];
Char *NextLoadedModuleFilename = LoadedModuleFilenames;


StructInitInfo * Modules [ MAX_MODULES ];
UInt NrModules;
UInt NrBuiltinModules;


/****************************************************************************
**
*F  RecordLoadedModule( <module> )  . . . . . . . . store module in <Modules>
*/

void RecordLoadedModule (
    StructInitInfo *        info,
    Char *filename )
{
    UInt len;
    if ( NrModules == MAX_MODULES ) {
        Pr( "panic: no room to record module\n", 0L, 0L );
    }
    len = strlen(filename);
    if (NextLoadedModuleFilename + len + 1
        > LoadedModuleFilenames+MAX_MODULE_FILENAMES) {
      Pr( "panic: no room for module filename\n", 0L, 0L );
    }
    *NextLoadedModuleFilename = '\0';
    memcpy(NextLoadedModuleFilename, filename, len+1);
    info->filename = NextLoadedModuleFilename;
    NextLoadedModuleFilename += len +1;
    Modules[NrModules++] = info;
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
#ifndef BOEHM_GC
extern TNumMarkFuncBags TabMarkFuncBags [ 256 ];
#endif

static Obj POST_RESTORE;

void InitializeGap (
    int *               pargc,
    char *              argv [],
    char *              environ [] )
{
  /*    UInt                type; */
    UInt                i;
    Int                 ret;

    /* initialize the basic system and gasman                              */
#ifdef GAPMPI
    /* ParGAP/MPI needs to call MPI_Init() first to remove command line args */
    InitGapmpi( pargc, &argv );
#endif

    InitSystem( *pargc, argv );

    /* Initialise memory  -- have to do this here to make sure we are at top of C stack */
    InitBags( SyAllocBags, SyStorMin,
              0, (Bag*)(((UInt)pargc/SyStackAlign)*SyStackAlign), SyStackAlign,
              0, SyAbortBags );
              InitMsgsFuncBags( SyMsgsBags ); 

    STATE(StackNams)    = NEW_PLIST( T_PLIST, 16 );
    STATE(CountNams)    = 0;
    STATE(ReadTop)      = 0;
    STATE(ReadTilde)    = 0;
    STATE(CurrLHSGVar)  = 0;
    STATE(IntrCoding)   = 0;
    STATE(IntrIgnoring) = 0;
    STATE(NrError)      = 0;
    STATE(ThrownObject) = 0;
    STATE(UserHasQUIT) = 0;
    STATE(UserHasQuit) = 0;

    NrImportedGVars = 0;
    NrImportedFuncs = 0;

    sysenviron = environ;

    /* get info structures for the build in modules                        */
    NrModules = 0;
    for ( i = 0;  InitFuncsBuiltinModules[i];  i++ ) {
        if ( NrModules == MAX_MODULES ) {
            FPUTS_TO_STDERR( "panic: too many builtin modules\n" );
            SyExit(1);
        }
        Modules[NrModules++] = InitFuncsBuiltinModules[i]();
#       ifdef DEBUG_LOADING
            FPUTS_TO_STDERR( "#I  InitInfo(builtin " );
            FPUTS_TO_STDERR( Modules[NrModules-1]->name );
            FPUTS_TO_STDERR( ")\n" );
#       endif
    }
    NrBuiltinModules = NrModules;

    /* call kernel initialisation                                          */
    for ( i = 0;  i < NrBuiltinModules;  i++ ) {
        if ( Modules[i]->initKernel ) {
#           ifdef DEBUG_LOADING
                FPUTS_TO_STDERR( "#I  InitKernel(builtin " );
                FPUTS_TO_STDERR( Modules[i]->name );
                FPUTS_TO_STDERR( ")\n" );
#           endif
            ret =Modules[i]->initKernel( Modules[i] );
            if ( ret ) {
                FPUTS_TO_STDERR( "#I  InitKernel(builtin " );
                FPUTS_TO_STDERR( Modules[i]->name );
                FPUTS_TO_STDERR( ") returned non-zero value\n" );
            }
        }
    }

#ifdef HPCGAP
    InitMainThread();
    InitTLS();
#else
    InitGAPState(MainGAPState);
#endif

    InitGlobalBag(&POST_RESTORE, "gap.c: POST_RESTORE");
    InitFopyGVar( "POST_RESTORE", &POST_RESTORE);

    /* you should set 'COUNT_BAGS' as well                                 */
#   ifdef DEBUG_LOADING
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
#   endif

#ifndef BOEHM_GC
    /* and now for a special hack                                          */
    for ( i = LAST_CONSTANT_TNUM+1; i <= LAST_REAL_TNUM; i++ ) {
      if (TabMarkFuncBags[i + COPYING] == MarkAllSubBagsDefault)
        TabMarkFuncBags[ i+COPYING ] = TabMarkFuncBags[ i ];
    }
#endif

    /* if we are restoring, load the workspace and call the post restore   */
    if ( SyRestoring ) {
       LoadWorkspace(SyRestoring);
        for ( i = 0;  i < NrModules;  i++ ) {
            if ( Modules[i]->postRestore ) {
#               ifdef DEBUG_LOADING
                    FPUTS_TO_STDERR( "#I  PostRestore(builtin " );
                    FPUTS_TO_STDERR( Modules[i]->name );
                    FPUTS_TO_STDERR( ")\n" );
#               endif
                ret = Modules[i]->postRestore( Modules[i] );
                if ( ret ) {
                    FPUTS_TO_STDERR( "#I  PostRestore(builtin " );
                    FPUTS_TO_STDERR( Modules[i]->name );
                    FPUTS_TO_STDERR( ") returned non-zero value\n" );
                }
            }
        }
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
        WarnInitGlobalBag = 1;
#       ifdef DEBUG_HANDLER_REGISTRATION
            CheckAllHandlers();
#       endif

        SyInitializing = 1;    
        for ( i = 0;  i < NrBuiltinModules;  i++ ) {
            if ( Modules[i]->initLibrary ) {
#               ifdef DEBUG_LOADING
                    FPUTS_TO_STDERR( "#I  InitLibrary(builtin " );
                    FPUTS_TO_STDERR( Modules[i]->name );
                    FPUTS_TO_STDERR( ")\n" );
#               endif
                ret = Modules[i]->initLibrary( Modules[i] );
                if ( ret ) {
                    FPUTS_TO_STDERR( "#I  InitLibrary(builtin " );
                    FPUTS_TO_STDERR( Modules[i]->name );
                    FPUTS_TO_STDERR( ") returned non-zero value\n" );
                }
            }
        }
        WarnInitGlobalBag = 0;
    }

    /* check initialisation                                                */
    for ( i = 0;  i < NrModules;  i++ ) {
        if ( Modules[i]->checkInit ) {
#           ifdef DEBUG_LOADING
                FPUTS_TO_STDERR( "#I  CheckInit(builtin " );
                FPUTS_TO_STDERR( Modules[i]->name );
                FPUTS_TO_STDERR( ")\n" );
#           endif
            ret = Modules[i]->checkInit( Modules[i] );
            if ( ret ) {
                FPUTS_TO_STDERR( "#I  CheckInit(builtin " );
                FPUTS_TO_STDERR( Modules[i]->name );
                FPUTS_TO_STDERR( ") returned non-zero value\n" );
            }
        }
    }

    /* read the init files      
       this now actually runs the GAP session, we only get 
       past here when we're about to exit. 
                                           */
    if ( SySystemInitFile[0] ) {
      TRY_READ {
        if ( READ_GAP_ROOT(SySystemInitFile) == 0 ) {
          /*             if ( ! SyQuiet ) { */
                Pr( "gap: hmm, I cannot find '%s' maybe",
                    (Int)SySystemInitFile, 0L );
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

/****************************************************************************
**
*E  gap.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
