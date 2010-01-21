/****************************************************************************
**
*W  gap.c                       GAP source                       Frank Celler
*W                                                         & Martin Schoenert
**
*H  @(#)$Id: gap.c,v 4.216 2009/09/25 15:17:05 gap Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the various read-eval-print loops and  related  stuff.
*/
#include        <stdio.h>
#include        <assert.h>
#include        <setjmp.h>              /* jmp_buf, setjmp, longjmp        */
#include        <string.h>              /* memcpy */
#include        <stdlib.h>

#include        "system.h"              /* system dependent part           */

const char * Revision_gap_c =
"@(#)$Id: gap.c,v 4.216 2009/09/25 15:17:05 gap Exp $";

/* TL: extern char * In; */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#define INCLUDE_DECLARATION_PART
#include        "gap.h"                 /* error handling, initialisation  */
#undef  INCLUDE_DECLARATION_PART

#include        "read.h"                /* reader                          */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */

#include        "integer.h"             /* integers                        */
#include        "rational.h"            /* rationals                       */
#include        "cyclotom.h"            /* cyclotomics                     */
#include        "finfield.h"            /* finite fields and ff elements   */

#include        "bool.h"                /* booleans                        */
#include        "macfloat.h"            /* machine doubles                 */
#include        "permutat.h"            /* permutations                    */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "listoper.h"            /* operations for generic lists    */
#include        "listfunc.h"            /* functions for generic lists     */
#include        "plist.h"               /* plain lists                     */
#include        "set.h"                 /* plain sets                      */
#include        "vector.h"              /* functions for plain vectors     */
#include        "vecffe.h"              /* functions for fin field vectors */
#include        "blister.h"             /* boolean lists                   */
#include        "range.h"               /* ranges                          */
#include        "string.h"              /* strings                         */
#include        "vecgf2.h"              /* functions for GF2 vectors       */
#include        "vec8bit.h"             /* functions for other compressed
					   GF(q) vectors                   */

#include        "objfgelm.h"            /* objects of free groups          */
#include        "objpcgel.h"            /* objects of polycyclic groups    */
#include        "objscoll.h"            /* single collector                */
#include        "objccoll.h"            /* combinatorial collector         */
#include        "objcftl.h"             /* from the left collect           */

#include        "dt.h"                  /* deep thought                    */
#include        "dteval.h"              /* deep though evaluation          */

#include        "sctable.h"             /* structure constant table        */
#include        "costab.h"              /* coset table                     */
#include        "tietze.h"              /* tietze helper functions         */

#include        "code.h"                /* coder                           */

#include        "vars.h"                /* variables                       */
#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */
#include        "funcs.h"               /* functions                       */


#include        "intrprtr.h"            /* interpreter                     */

#include        "compiler.h"            /* compiler                        */

#include        "compstat.h"            /* statically linked modules       */

#include        "saveload.h"            /* saving and loading              */

#include        "streams.h"             /* streams package                 */
#include        "sysfiles.h"            /* file input/output               */
#include        "weakptr.h"             /* weak pointers                   */

#ifdef GAPMPI
#include        "gapmpi.h"              /* ParGAP/MPI			   */
#endif

#include        "thread.h"
#include        "tls.h"

#ifdef SYS_IS_MAC_MWC
#include        "macintr.h"              /* Mac interrupt handlers	      */
#endif

#include        "iostream.h"

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
**  We also install a hook to use the GAP level function 'CustomView' if
**  it exists. This can for example be used to restrict the amount of output
**  or to show long output in a pager or .....
**  
**  This function also supplies the \n after viewing.
*/
UInt ViewObjGVar;
UInt CustomViewGVar;

void ViewObjHandler ( Obj obj )
{
  volatile Obj        func;
  volatile Obj        cfunc;
  jmp_buf             readJmpError;

  /* get the functions                                                   */
  func = ValAutoGVar(ViewObjGVar);
  cfunc = ValAutoGVar(CustomViewGVar);

  /* if non-zero use this function, otherwise use `PrintObj'             */
  memcpy( readJmpError, TLS->readJmpError, sizeof(jmp_buf) );
  if ( ! READ_ERROR() ) {
    if ( cfunc != 0 && TNUM_OBJ(cfunc) == T_FUNCTION ) {
      CALL_1ARGS(cfunc, obj);
    }
    else if ( func != 0 && TNUM_OBJ(func) == T_FUNCTION ) {
      ViewObj(obj);
    }
    else {
      PrintObj( obj );
    }
    Pr( "\n", 0L, 0L );
    memcpy( TLS->readJmpError, readJmpError, sizeof(jmp_buf) );
  }
  else {
    memcpy( TLS->readJmpError, readJmpError, sizeof(jmp_buf) );
  }
}


/****************************************************************************
**
*F  main( <argc>, <argv> )  . . . . . . .  main program, read-eval-print loop
*/
Obj AtExitFunctions;

Obj AlternativeMainLoop;

UInt SaveOnExitFileGVar;

UInt QUITTINGGVar;

Obj OnGapPromptHook;

Obj ErrorHandler;		/* not yet settable from GAP level */


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

/* int restart_argc; 
   char **restart_argv; */

char *original_argv0;
static char **sysargv;
static char **sysenviron;

/* 
jmp_buf SyRestartBuf;
*/

Obj ShellContext = 0;
Obj BaseShellContext = 0;
UInt ShellContextDepth;


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
  Obj res;
  Obj oldShellContext;
  Obj oldBaseShellContext;
  UInt oldShellContextDepth;
  oldShellContext = ShellContext;
  ShellContext = context;
  oldBaseShellContext = BaseShellContext;
  BaseShellContext = context;
  oldShellContextDepth = ShellContextDepth;
  ShellContextDepth = 0;
  
  /* read-eval-print loop                                                */
  if (!OpenOutput(outFile))
    ErrorMayQuit("SHELL: can't open outfile %s",(Int)outFile,0);

  if(!OpenInput(inFile))
    {
      CloseOutput();
      ErrorMayQuit("SHELL: can't open infile %s",(Int)inFile,0);
    }
  
  while ( 1 ) {

    /* start the stopwatch                                             */
    if (setTime)
      time = SyTime();

    /* read and evaluate one command                                   */
    TLS->prompt = prompt;
    ClearError();

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
          TLS->prompt = prompt;
          ClearError();
        }
    }

    /* now  read and evaluate and view one command  */
    status = ReadEvalCommand(ShellContext);
    if (UserHasQUIT)
      break;


    /* handle ordinary command                                         */
    if ( status == STATUS_END && TLS->readEvalResult != 0 ) {

      /* remember the value in 'last'    */
      if (lastDepth >= 3)
	AssGVar( Last3, VAL_GVAR( Last2 ) );
      if (lastDepth >= 2)
	AssGVar( Last2, VAL_GVAR( Last  ) );
      if (lastDepth >= 1)
	AssGVar( Last,  TLS->readEvalResult   );

      /* print the result                                            */
      if ( ! TLS->dualSemicolon ) {
	ViewObjHandler( TLS->readEvalResult );
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
      RecursionDepth = 0;
      UserHasQuit = 1;
      break;
    }
	
    /* handle QUIT */
    else if (status & (STATUS_QQUIT)) {
      UserHasQUIT = 1;
      break;
    }
	
    /* stop the stopwatch                                          */
    if (setTime)
      AssGVar( Time, INTOBJ_INT( SyTime() - time ) );

    if (UserHasQuit)
      {
	FlushRestOfInputLine();
	UserHasQuit = 0;	/* quit has done its job if we are here */
      }

  }

  CloseInput();
  CloseOutput();
  BaseShellContext = oldBaseShellContext;
  ShellContext = oldShellContext;
  if (UserHasQUIT)
    {
      if (catchQUIT)
	{
	  UserHasQUIT = 0;
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
      SET_ELM_PLIST(res,1,TLS->readEvalResult);
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
  SyStrncat(promptBuffer, CSTR_STRING(prompt), 80);

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

  UserHasQuit = 0;
  return res;
}

int realmain (
	  int                 argc,
	  char *              argv [],
          char *              environ [] );

int main (
	  int                 argc,
	  char *              argv [],
          char *              environ [] )
{
  RunThreadedMain(realmain, argc, argv, environ);
  return 0;
}

int realmain (
	  int                 argc,
	  char *              argv [],
          char *              environ [] )
{
  UInt                type;                   /* result of compile       */
  Obj                 func;                   /* function (compiler)     */
  Int4                crc;                    /* crc of file to compile  */

  
  original_argv0 = argv[0];
  sysargv = argv;
  sysenviron = environ;
  
  /* prepare for a possible restart 
  if (setjmp(SyRestartBuf))
    {
      argc = restart_argc;
      argv = restart_argv;
    }
    `*/

  /* Initialize assorted variables in this file */
  /*   BreakOnError = 1;
       ErrorCount = 0; */
  NrImportedGVars = 0;
  NrImportedFuncs = 0;
  ErrorHandler = (Obj) 0;
  UserHasQUIT = 0;
  UserHasQuit = 0;
    
  /* initialize everything and read init.g which runs the GAP session */
  InitializeGap( &argc, argv );
  if (!UserHasQUIT) {		/* maybe the user QUIT from the initial
				   read of init.g  somehow*/
    /* maybe compile in which case init.g got skipped */
    if ( SyCompilePlease ) {
      if ( ! OpenInput(SyCompileInput) ) {
	SyExit(1);
      }
      func = READ_AS_FUNC();
      crc  = SyGAPCRC(SyCompileInput);
      if (SyStrlen(SyCompileOptions) != 0)
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
  SyExit(0);
  return 0;
}

/****************************************************************************
**
*F  FuncRESTART_GAP( <self>, <cmdline> ) . . . . . . . .  restart gap
**
*/

Char restart_cmdline_buffer[10000];
Char *restart_argv_buffer[1000];

#include <unistd.h> /* move this and wrap execvp later */

Obj FuncRESTART_GAP( Obj self, Obj cmdline )
{
  Char *s, *d, **v;
  UInt l;
  UInt ct;
  while (!IsStringConv(cmdline))
    {
      cmdline = ErrorReturnObj("RESTART_GAP: <cmdline> must be a string, not a %s",
			       (Int) TNAM_OBJ(cmdline), (Int) 0,
			       "You can resturn a string to continue");
    }
  l = GET_LEN_STRING(cmdline);
  s = CSTR_STRING(cmdline);
  d = restart_cmdline_buffer;
  v = restart_argv_buffer;
  *v++ = original_argv0;
  ct = 1;
  while (l >0 && isspace(*s))
    {
      s++;
      l--;
    }
  while (l > 0)
    {
      *v++ = d;
      ct++;
      while (l > 0 && !isspace(*s)) {
	*d++ = *s++;
	l--;
      }
      *d++ = '\0';
      while (l >0 && isspace(*s))
	{
	  s++;
	  l--;
	}
    }
  *v = (Char *)0;
  /*  restart_argc = ct;
      restart_argv = restart_argv_buffer; */
  FinishBags();
  execvp(original_argv0, restart_argv_buffer);
  /*  longjmp(SyRestartBuf,1); */
  return Fail; /* shouldn't normally get here */
}



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
#if HAVE_GETRUSAGE
  res = NEW_PLIST(T_PLIST, 4);
  SET_LEN_PLIST(res, 4);
  SET_ELM_PLIST(res, 1, INTOBJ_INT( SyTime() ));
  SET_ELM_PLIST(res, 2, INTOBJ_INT( SyTimeSys() ));
  SET_ELM_PLIST(res, 3, INTOBJ_INT( SyTimeChildren() ));
  SET_ELM_PLIST(res, 4, INTOBJ_INT( SyTimeChildrenSys() ));
#else
  res = INTOBJ_INT( SyTime() );
#endif
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
    while ( TNUM_OBJ(elm) != T_INT ) {
      elm = ErrorReturnObj(
			   "SizeScreen: <x> must be an integer",
			   0L, 0L,
			   "you can replace <x> via 'return <x>;'" );
    }
    len = INT_INTOBJ( elm );
    if ( len < 20  )  len = 20;
    if ( 256 < len )  len = 256;
  }

  /* extract the number                                                  */
  if ( LEN_LIST(size) < 2 || ELM0_LIST(size,2) == 0 ) {
    nr = 0;
  }
  else {
    elm = ELMW_LIST(size,2);
    while ( TNUM_OBJ(elm) != T_INT ) {
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
		   Obj	      	    self,
		   Obj             args )
{
  Obj             tmp;
  Obj       	    list;
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
      while ( TNUM_OBJ(tmp) != T_INT && ! IsStringConv(tmp) ) {
	tmp = ErrorReturnObj(
			     "%d. argument must be a string or integer (not a %s)",
			     i, (Int)TNAM_OBJ(tmp),
			     "you can replace the argument <arg> via 'return <arg>;'" );
	SET_ELM_PLIST( args, i, tmp );
      }
      if ( TNUM_OBJ(tmp) == T_INT )
	len += 12;
      else
	len += 12 + LEN_LIST(tmp);
    }
  if ( SIZE_OBJ(WindowCmdString) <= len ) {
    ResizeBag( WindowCmdString, 2*len+1 );
  }

  /* convert <args> into an argument string                              */
  ptr  = (Char*) CSTR_STRING(WindowCmdString);
  *ptr = '\0';

  /* first the command name                                              */
  SyStrncat( ptr, CSTR_STRING( ELM_LIST(args,1) ), 3 );
  ptr += 3;

  /* and now the arguments                                               */
  for ( i = 2;  i <= LEN_LIST(args);  i++ )
    {
      tmp = ELM_LIST(args,i);

      if ( TNUM_OBJ(tmp) == T_INT ) {
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
  ptr = SyWinCmd( qtr, SyStrlen(qtr) );
  len = SyStrlen(ptr);

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
      /*CCC tmp = NEW_STRING(n);
      *CSTR_STRING(tmp) = '\0';
      SyStrncat( CSTR_STRING(tmp), ptr, n ); CCC*/
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
    /*CCCtmp = NEW_STRING(15);
      SyStrncat( CSTR_STRING(tmp), "window system: ", 15 );CCC*/
    C_NEW_STRING(tmp, 15, "window system: ");  
    SET_ELM_PLIST( list, 1, tmp );
    SET_LEN_PLIST( list, i-1 );
    return CALL_XARGS(Error,list);
    /*     return FuncError( 0, list );*/
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
UInt ErrorLevel;

Obj  ErrorLVars0;    
/* TL: Obj  ErrorLVars; */
Int  ErrorLLevel;

/* TL: extern Obj BottomLVars; */


void DownEnvInner( Int depth )
{
  /* if we really want to go up                                          */
  if ( depth < 0 && -ErrorLLevel <= -depth ) {
    depth = 0;
    TLS->errorLVars = ErrorLVars0;
    ErrorLLevel = 0;
    ShellContextDepth = 0;
    ShellContext = BaseShellContext;
  }
  else if ( depth < 0 ) {
    depth = -ErrorLLevel + depth;
    TLS->errorLVars = ErrorLVars0;
    ErrorLLevel = 0;
    ShellContextDepth = 0;
    ShellContext = BaseShellContext;
  }
  
  /* now go down                                                         */
  while ( 0 < depth
	  && TLS->errorLVars != TLS->bottomLVars
	  && PTR_BAG(TLS->errorLVars)[2] != TLS->bottomLVars ) {
    TLS->errorLVars = PTR_BAG(TLS->errorLVars)[2];
    ErrorLLevel--;
    ShellContext = PTR_BAG(ShellContext)[2];
    ShellContextDepth--;
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
  if ( TLS->errorLVars == 0 ) {
    Pr( "not in any function\n", 0L, 0L );
    return 0;
  }

  DownEnvInner( depth);

  /* return nothing                                                      */
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
  if ( TLS->errorLVars == 0 ) {
    Pr( "not in any function\n", 0L, 0L );
    return 0;
  }

  DownEnvInner(-depth);
  return 0;
}


Obj FuncPrintExecutingStatement(Obj self, Obj context)
{
  Obj currLVars = TLS->currLVars;
  Expr call;
  if (context == TLS->bottomLVars)
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
    }
    else if ( FIRST_EXPR_TNUM <= TNUM_EXPR(call)
	      && TNUM_EXPR(call)  <= LAST_EXPR_TNUM ) {
      PrintExpr( call );
    }
    SWITCH_TO_OLD_LVARS( currLVars );
    return (Obj) 0;
}    

/****************************************************************************
**
*F  FuncCallFuncTrapError( <self>, <func> )
**
*/
  
/* jmp_buf CatchBuffer; */
Obj ThrownObject = 0;

Obj FuncCALL_WITH_CATCH( Obj self, Obj func, Obj args )
  {
    Obj plain_args;
    jmp_buf readJmpError;
    Obj res;
    Obj currLVars;
    Obj result;
    Stat currStat;
    if (!IS_FUNC(func))
      ErrorMayQuit("CALL_WITH_CATCH(<func>,<args>): <func> must be a function",0,0);
    if (!IS_LIST(args))
      ErrorMayQuit("CALL_WITH_CATCH(<func>,<args>): <args> must be a list",0,0);
    if (!IS_PLIST(args))
      {
	plain_args = SHALLOW_COPY_OBJ(args);
	PLAIN_LIST(plain_args);
      }
    else 
      plain_args = args;
    memcpy((void *)&readJmpError, (void *)&TLS->readJmpError, sizeof(jmp_buf));
    currLVars = TLS->currLVars;
    currStat = TLS->currStat;
    res = NEW_PLIST(T_PLIST_DENSE+IMMUTABLE,2);
    if (setjmp(TLS->readJmpError)) {
      SET_LEN_PLIST(res,2);
      SET_ELM_PLIST(res,1,False);
      SET_ELM_PLIST(res,2,ThrownObject);
      CHANGED_BAG(res);
      ThrownObject = 0;
      TLS->currLVars = currLVars;
      TLS->ptrLVars = PTR_BAG(TLS->currLVars);
      TLS->ptrBody = (Stat*)PTR_BAG(BODY_FUNC(CURR_FUNC));
      TLS->currStat = currStat;
    } else {
      switch (LEN_PLIST(plain_args)) {
      case 0: result = CALL_0ARGS(func);
	break;
      case 1: result = CALL_1ARGS(func, ELM_PLIST(plain_args,1));
	break;
      case 2: result = CALL_2ARGS(func, ELM_PLIST(plain_args,1),
				  ELM_PLIST(plain_args,2));
	break;
      case 3: result = CALL_3ARGS(func, ELM_PLIST(plain_args,1),
				  ELM_PLIST(plain_args,2), ELM_PLIST(plain_args,3));
	break;
      case 4: result = CALL_4ARGS(func, ELM_PLIST(plain_args,1),
				  ELM_PLIST(plain_args,2), ELM_PLIST(plain_args,3),
				  ELM_PLIST(plain_args,4));
	break;
      case 5: result = CALL_5ARGS(func, ELM_PLIST(plain_args,1),
				  ELM_PLIST(plain_args,2), ELM_PLIST(plain_args,3),
				  ELM_PLIST(plain_args,4), ELM_PLIST(plain_args,5));
	break;
      case 6: result = CALL_6ARGS(func, ELM_PLIST(plain_args,1),
				  ELM_PLIST(plain_args,2), ELM_PLIST(plain_args,3),
				  ELM_PLIST(plain_args,4), ELM_PLIST(plain_args,5),
				  ELM_PLIST(plain_args,6));
	break;
      default: result = CALL_XARGS(func, plain_args);
      }
      SET_ELM_PLIST(res,1,True);
      if (result)
	{
	  SET_LEN_PLIST(res,2);
	  SET_ELM_PLIST(res,2,result);
	  CHANGED_BAG(res);
	}
      else
	SET_LEN_PLIST(res,1);
    }
    memcpy((void *)&TLS->readJmpError, (void *)&readJmpError, sizeof(jmp_buf));
    return res;      
  }

 Obj FuncJUMP_TO_CATCH( Obj self, Obj payload) {
   ThrownObject = payload;
   longjmp(TLS->readJmpError, 1);
   return 0;
 }
  

UInt UserHasQuit;
UInt UserHasQUIT; 

 Obj FuncSetUserHasQuit( Obj Self, Obj value)
   {
     UserHasQuit = INT_INTOBJ(value);
     if (UserHasQuit)
       RecursionDepth = 0;
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
  Char message[120];
  Obj Message;
  SPrTo(message, 120, msg, arg1, arg2);
  message[119] = '\0';
  C_NEW_STRING(Message, SyStrlen(message), message); 
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
  EarlyMsg = ErrorMessageToGAPString(msg, arg1, arg2);
  AssPRec(r, RNamName("context"), TLS->currLVars);
  AssPRec(r, RNamName("justQuit"), justQuit? True : False);
  AssPRec(r, RNamName("mayReturnObj"), mayReturnObj? True : False);
  AssPRec(r, RNamName("mayReturnVoid"), mayReturnVoid? True : False);
  AssPRec(r, RNamName("printThisStatement"), printThisStatement? True : False);
  AssPRec(r, RNamName("lateMessage"), lateMessage);
  l = NEW_PLIST(T_PLIST_HOM+IMMUTABLE, 1);
  SET_ELM_PLIST(l,1,EarlyMsg);
  SET_LEN_PLIST(l,1);
  SET_BRK_CALL_TO(TLS->currStat);
  return CALL_2ARGS(ErrorInner,r,l);  
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
    Char *              name )
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
  C_NEW_STRING(LateMsg, SyStrlen(msg2), msg2);
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
  C_NEW_STRING(LateMsg, SyStrlen(msg2), msg2);
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


/****************************************************************************
**

*F * * * * * * * * * functions for creating the init file * * * * * * * * * *
*/



/****************************************************************************
**

*F  Complete( <list> )  . . . . . . . . . . . . . . . . . . . complete a file
*/
Obj  CompNowFuncs;
UInt CompNowCount;
Obj  CompLists;
Obj  CompThenFuncs;

#define COMP_THEN_OFFSET        2

void Complete (
    Obj                 list )
{
    Obj                 filename;
    UInt                type;
    Int4                crc;
    Int4                crc1;

    /* get the filename                                                    */
    filename = ELM_PLIST( list, 1 );

    /* and the crc value                                                   */
    crc = INT_INTOBJ( ELM_PLIST( list, 2 ) );

    /* check the crc value                                                 */
    if ( SyCheckCompletionCrcRead ) {
        crc1 = SyGAPCRC( CSTR_STRING(filename) );
        if ( crc != crc1 ) {
            ErrorQuit(
 "Error, Rebuild completion files! (Crc value of\n\"%s\" does not match.)",
                (Int)CSTR_STRING(filename), 0L );
            return;
        }
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        return;
    }
    ClearError();
    
    /* switch on the buffer for faster reading */
    SySetBuffering(TLS->input->file);
    
    /* we are now completing                                               */
    if ( SyDebugLoading ) {
        Pr( "#I  completing '%s'\n", (Int)CSTR_STRING(filename), 0L );
    }
    CompNowFuncs = list;
    CompNowCount = COMP_THEN_OFFSET;

    /* now do the reading                                                  */
    while ( 1 ) {
        type = ReadEvalCommand(TLS->bottomLVars);
        if ( type == STATUS_RETURN_VAL || type == STATUS_RETURN_VOID ) {
            Pr( "'return' must not be used in file read-eval loop",
                0L, 0L );
        }
        else if ( type == STATUS_QUIT || type == STATUS_EOF ) {
            break;
        }
    }

    /* thats it for completing                                             */
    CompNowFuncs = 0;
    CompNowCount = 0;

    /* close the input file again, and return 'true'                       */
    if ( ! CloseInput() ) {
        ErrorQuit(
            "Panic: COMPLETE cannot close input, this should not happen",
            0L, 0L );
    }
    ClearError();
}


/****************************************************************************
**
*F  DoComplete<i>args( ... )  . . . . . . . . . .  handler to complete a file
*/
Obj DoComplete0args (
    Obj                 self )
{
    COMPLETE_FUNC( self );
    if ( IS_UNCOMPLETED_FUNC(self) ) {
        ErrorQuit( "panic: completion did not define function",
                   0, 0 );
        return 0;
    }
    return CALL_0ARGS( self );
}

Obj DoComplete1args (
    Obj                 self,
    Obj                 arg1 )
{
    COMPLETE_FUNC( self );
    if ( IS_UNCOMPLETED_FUNC(self) ) {
        ErrorQuit( "panic: completion did not define function",
                   0, 0 );
        return 0;
    }
    return CALL_1ARGS( self, arg1 );
}

Obj DoComplete2args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2 )
{
    COMPLETE_FUNC( self );
    if ( IS_UNCOMPLETED_FUNC(self) ) {
        ErrorQuit( "panic: completion did not define function",
                   0, 0 );
        return 0;
    }
    return CALL_2ARGS( self, arg1, arg2 );
}

Obj DoComplete3args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    COMPLETE_FUNC( self );
    if ( IS_UNCOMPLETED_FUNC(self) ) {
        ErrorQuit( "panic: completion did not define function",
                   0, 0 );
        return 0;
    }
    return CALL_3ARGS( self, arg1, arg2, arg3 );
}

Obj DoComplete4args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    COMPLETE_FUNC( self );
    if ( IS_UNCOMPLETED_FUNC(self) ) {
        ErrorQuit( "panic: completion did not define function",
                   0, 0 );
        return 0;
    }
    return CALL_4ARGS( self, arg1, arg2, arg3, arg4 );
}

Obj DoComplete5args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    COMPLETE_FUNC( self );
    if ( IS_UNCOMPLETED_FUNC(self) ) {
        ErrorQuit( "panic: completion did not define function",
                   0, 0 );
        return 0;
    }
    return CALL_5ARGS( self, arg1, arg2, arg3, arg4, arg5 );
}

Obj DoComplete6args (
    Obj                 self,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    COMPLETE_FUNC( self );
    if ( IS_UNCOMPLETED_FUNC(self) ) {
        ErrorQuit( "panic: completion did not define function",
                   0, 0 );
        return 0;
    }
    return CALL_6ARGS( self, arg1, arg2, arg3, arg4, arg5, arg6 );
}

Obj DoCompleteXargs (
    Obj                 self,
    Obj                 args )
{
    COMPLETE_FUNC( self );
    if ( IS_UNCOMPLETED_FUNC(self) ) {
        ErrorQuit( "panic: completion did not define function",
                   0, 0 );
        return 0;
    }
    return CALL_XARGS( self, args );
}


/****************************************************************************
**
*F  FuncCOM_FILE( <self>, <filename>, <crc> ) . . . . . . . . .  set filename
*/
Obj FuncCOM_FILE (
    Obj                 self,
    Obj                 filename,
    Obj                 crc )
{
    Int                 len;
    StructInitInfo *    info;
    Int4                crc1;
    Int4                crc2;
    Char                result[256];
    Int                 res;


    /* check the argument                                                  */
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    while ( ! IS_INTOBJ(crc) ) {
        crc = ErrorReturnObj(
            "<crc> must be a small integer (not a %s)",
            (Int)TNAM_OBJ(crc), 0L,
            "you can replace <crc> via 'return <crc>;'" );
    }

    /* check if have a statically or dynamically loadable module           */
    crc1 = INT_INTOBJ(crc);
    res  = SyFindOrLinkGapRootFile(CSTR_STRING(filename), crc1, result, 256);

    /* not found                                                           */
    if ( res == 0 ) {
        ErrorQuit( "cannot find module or file '%s'", 
                   (Int)CSTR_STRING(filename), 0L );
        return Fail;
    }

    /* dynamically linked                                                  */
    else if ( res == 1 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' dynamically\n",
                (Int)CSTR_STRING(filename), 0L );
        }
        info = *(StructInitInfo**)result;
        res  = info->initKernel(info);
	UpdateCopyFopyInfo();
        res  = res || info->initLibrary(info);
        if ( res ) {
            Pr( "#W  init functions returned non-zero exit code\n", 0L, 0L );
        }
	info->isGapRootRelative = 1;
	RecordLoadedModule(info, CSTR_STRING(filename));
        return INTOBJ_INT(1);
    }

    /* statically linked                                                   */
    else if ( res == 2 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' statically\n",
                (Int)CSTR_STRING(filename), 0L );
        }
        info = *(StructInitInfo**)result;
        res  = info->initKernel(info);
	UpdateCopyFopyInfo();
        res  = res || info->initLibrary(info);
        if ( res ) {
            Pr( "#W  init functions returned non-zero exit code\n", 0L, 0L );
        }
	info->isGapRootRelative = 1;
	RecordLoadedModule(info, CSTR_STRING(filename));
        return INTOBJ_INT(2);
    }


    /* we have to read the GAP file                                        */
    else if ( res == 3 ) {

        /* compute the crc value of the original and compare               */
        if ( SyCheckCompletionCrcComp ) {
            crc2 = SyGAPCRC(result);
            if ( crc1 != crc2 ) {
                return INTOBJ_INT(4);
            }
        }
        /*CCC filename = NEW_STRING( SyStrlen(result) );
	  SyStrncat( CSTR_STRING(filename), result, SyStrlen(result) );CCC*/
	len = SyStrlen(result);
	C_NEW_STRING(filename, len, result);

        CompThenFuncs = NEW_PLIST( T_PLIST, COMP_THEN_OFFSET );
        SET_LEN_PLIST( CompThenFuncs, COMP_THEN_OFFSET );
        SET_ELM_PLIST( CompThenFuncs, 1, filename );
        SET_ELM_PLIST( CompThenFuncs, 2, INTOBJ_INT(crc1) );

        len = LEN_PLIST( CompLists );
        GROW_PLIST(    CompLists, len+1 );
        SET_LEN_PLIST( CompLists, len+1 );
        SET_ELM_PLIST( CompLists, len+1, CompThenFuncs );
        CHANGED_BAG(   CompLists );

        return INTOBJ_INT(3);
    }

    /* we have to read the GAP file, crc mismatch                          */
    else if ( res == 4 ) {
        return INTOBJ_INT(4);
    }

    /* don't know                                                          */
    else {
        ErrorQuit( "unknown result code %d from 'SyFindGapRoot'", res, 0L );
        return Fail;
    }
}


/****************************************************************************
**
*F  FuncCOM_FUN( <self>, <num> )  . . . . . . . . make a completable function
*/
static Obj StringUncompleted;
static Obj EmptyList;

Obj FuncCOM_FUN (
    Obj                 self,
    Obj                 num )
{
    Obj                 func;
    Int                 n;

    /* if the file is not yet completed then make a new function           */
    n = INT_INTOBJ(num) + COMP_THEN_OFFSET;
    if ( LEN_PLIST( CompThenFuncs ) < n ) {
       
        /* make the function                                               */
        func = NewFunctionT( T_FUNCTION, SIZE_FUNC, EmptyList, -1,
                             StringUncompleted, 0 );
        HDLR_FUNC( func, 0 ) = DoComplete0args;
        HDLR_FUNC( func, 1 ) = DoComplete1args;
        HDLR_FUNC( func, 2 ) = DoComplete2args;
        HDLR_FUNC( func, 3 ) = DoComplete3args;
        HDLR_FUNC( func, 4 ) = DoComplete4args;
        HDLR_FUNC( func, 5 ) = DoComplete5args;
        HDLR_FUNC( func, 6 ) = DoComplete6args;
        HDLR_FUNC( func, 7 ) = DoCompleteXargs;
        BODY_FUNC( func )    = CompThenFuncs;

        /* add the function to the list of functions to complete           */
        GROW_PLIST(    CompThenFuncs, n );
        SET_LEN_PLIST( CompThenFuncs, n );
        SET_ELM_PLIST( CompThenFuncs, n, func );
        CHANGED_BAG(   CompThenFuncs );

    }

    /* return the function                                                 */
    return ELM_PLIST( CompThenFuncs, n );
}


/****************************************************************************
**
*F  FuncMAKE_INIT( <out>, <in>, ... ) . . . . . . . . . .  generate init file
**  XXX  This is not correct with long integers or strings which are long
**  or contain zero characters ! (FL) XXX
*/
#define MAKE_INIT_GET_SYMBOL                    \
    do {                                        \
        symbol = TLS->symbol;                        \
        value[0] = '\0';                        \
        SyStrncat( value, TLS->value, 1023 );        \
        if ( TLS->symbol != S_EOF )  GetSymbol();    \
    } while (0)


Obj FuncMAKE_INIT (
    Obj                 self,
    Obj                 output,
    Obj                 filename )
{
    volatile UInt       level;
    volatile UInt       symbol;
    Char                value [1024];
    volatile UInt       funcNum;
    jmp_buf             readJmpError;

    /* check the argument                                                  */
    if ( ! IsStringConv( filename ) ) {
        ErrorQuit( "%d.th argument must be a string (not a %s)",
                   (Int)TNAM_OBJ(filename), 0L );
    }

    /* try to open the output                                              */
    if ( ! OpenAppend(CSTR_STRING(output)) ) {
        ErrorQuit( "cannot open '%s' for output",
                   (Int)CSTR_STRING(output), 0L );
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        CloseOutput();
        ErrorQuit( "'%s' must exist and be readable",
                   (Int)CSTR_STRING(filename), 0L );
    }
    ClearError();

    /* where is this stuff                                                 */
    funcNum = 1;

    /* read the file                                                       */
    GetSymbol();
    MAKE_INIT_GET_SYMBOL;
    while ( symbol != S_EOF ) {

        memcpy( readJmpError, TLS->readJmpError, sizeof(jmp_buf) );
        if ( READ_ERROR() ) {
            memcpy( TLS->readJmpError, readJmpError, sizeof(jmp_buf) );
            CloseInput();
            CloseOutput();
            ReadEvalError();
        }
        memcpy( TLS->readJmpError, readJmpError, sizeof(jmp_buf) );

        /* handle function beginning and ending                            */
        if ( symbol == S_FUNCTION ) {
            Pr( "COM_FUN(%d)", funcNum++, 0L );
            MAKE_INIT_GET_SYMBOL;
            level = 0;
            while ( level != 0 || symbol != S_END ) {
                if ( symbol == S_FUNCTION )
                    level++;
                if ( symbol == S_END )
                    level--;
                MAKE_INIT_GET_SYMBOL;
            }
            MAKE_INIT_GET_SYMBOL;
        }

        /* handle -> expressions                                           */
        else if ( symbol == S_IDENT && TLS->symbol == S_MAPTO ) {
            Pr( "COM_FUN(%d)", funcNum++, 0L );
            symbol = TLS->symbol;  if ( TLS->symbol != S_EOF )  GetSymbol();
            MAKE_INIT_GET_SYMBOL;
            level = 0;
            while ( level != 0
                 || (symbol != S_RBRACK  && symbol != S_RBRACE
                 && symbol != S_RPAREN  && symbol != S_COMMA
                 && symbol != S_DOTDOT  && symbol != S_SEMICOLON) )
            {
                 if ( symbol == S_LBRACK  || symbol == S_LBRACE
                   || symbol == S_LPAREN  || symbol == S_FUNCTION 
                   || symbol == S_BLBRACK || symbol == S_BLBRACE )
                     level++;
                 if ( symbol == S_RBRACK  || symbol == S_RBRACE
                   || symbol == S_RPAREN  || symbol == S_END )
                     level--;
                 MAKE_INIT_GET_SYMBOL;
            }
        }
        
        /* handle the other symbols                                        */
        else {

            switch ( symbol ) {
            case S_IDENT:    Pr( "%I",      (Int)value, 0L );  break;
            case S_UNBIND:   Pr( "Unbind",  0L, 0L );  break;
            case S_ISBOUND:  Pr( "IsBound", 0L, 0L );  break;

            case S_LBRACK:   Pr( "[",       0L, 0L );  break;
            case S_RBRACK:   Pr( "]",       0L, 0L );  break;
            case S_LBRACE:   Pr( "{",       0L, 0L );  break;
            case S_RBRACE:   Pr( "}",       0L, 0L );  break;
            case S_DOT:      Pr( ".",       0L, 0L );  break;
            case S_LPAREN:   Pr( "(",       0L, 0L );  break;
            case S_RPAREN:   Pr( ")",       0L, 0L );  break;
            case S_COMMA:    Pr( ",",       0L, 0L );  break;
            case S_DOTDOT:   Pr( "%>..%<",  0L, 0L );  break;

            case S_BDOT:     Pr( "!.",      0L, 0L );  break;
            case S_BLBRACK:  Pr( "![",      0L, 0L );  break;
            case S_BLBRACE:  Pr( "!{",      0L, 0L );  break;

            case S_INT:      Pr( "%s",      (Int)value, 0L );  break;
            case S_TRUE:     Pr( "true",    0L, 0L );  break;
            case S_FALSE:    Pr( "false",   0L, 0L );  break;
            case S_CHAR:     Pr( "'%c'",    (Int)value[0], 0L );  break;
            case S_STRING:   Pr( "\"%S\"",  (Int)value, 0L );  break;

            case S_REC:      Pr( "rec",     0L, 0L );  break;

            case S_FUNCTION: /* handled above */       break;
            case S_LOCAL:    /* shouldn't happen */    break;
            case S_END:      /* handled above */       break;
            case S_MAPTO:    /* handled above */       break;

            case S_MULT:     Pr( "*",       0L, 0L );  break;
            case S_DIV:      Pr( "/",       0L, 0L );  break;
            case S_MOD:      Pr( " mod ",   0L, 0L );  break;
            case S_POW:      Pr( "^",       0L, 0L );  break;

            case S_PLUS:     Pr( "+",       0L, 0L );  break;
            case S_MINUS:    Pr( "-",       0L, 0L );  break;

            case S_EQ:       Pr( "=",       0L, 0L );  break;
            case S_LT:       Pr( "<",       0L, 0L );  break;
            case S_GT:       Pr( ">",       0L, 0L );  break;
            case S_NE:       Pr( "<>",      0L, 0L );  break;
            case S_LE:       Pr( "<=",      0L, 0L );  break;
            case S_GE:       Pr( ">=",      0L, 0L );  break;
            case S_IN:       Pr( " in ",    0L, 0L );  break;

            case S_NOT:      Pr( "not ",    0L, 0L );  break;
            case S_AND:      Pr( " and ",   0L, 0L );  break;
            case S_OR:       Pr( " or ",    0L, 0L );  break;

            case S_ASSIGN:   Pr( ":=",      0L, 0L );  break;

            case S_IF:       Pr( "if ",     0L, 0L );  break;
            case S_FOR:      Pr( "for ",    0L, 0L );  break;
            case S_WHILE:    Pr( "while ",  0L, 0L );  break;
            case S_REPEAT:   Pr( "repeat ", 0L, 0L );  break;

            case S_THEN:     Pr( " then\n", 0L, 0L );  break;
            case S_ELIF:     Pr( "elif ",   0L, 0L );  break;
            case S_ELSE:     Pr( "else\n",  0L, 0L );  break;
            case S_FI:       Pr( "fi",      0L, 0L );  break;
            case S_DO:       Pr( " do\n",   0L, 0L );  break;
            case S_OD:       Pr( "od",      0L, 0L );  break;
            case S_UNTIL:    Pr( "until ",  0L, 0L );  break;

            case S_BREAK:    Pr( "break",   0L, 0L );  break;
            case S_RETURN:   Pr( "return ", 0L, 0L );  break;
            case S_QUIT:     Pr( "quit",    0L, 0L );  break;

            case S_SEMICOLON: Pr( ";\n",    0L, 0L );  break;

            default: CloseInput();
                     CloseOutput();
                     ClearError();
                     ErrorQuit( "unknown symbol %d", (Int)symbol, 0L );

            }

            /* get the next symbol                                         */
            MAKE_INIT_GET_SYMBOL;
        }
    }

    /* close the input file again                                          */
    if ( ! CloseInput() ) {
        ErrorQuit( 
            "Panic: MAKE_INIT cannot close input, this should not happen",
            0L, 0L );
    }
    ClearError();

    /* close the output file                                               */
    CloseOutput();

    return 0;
}


/****************************************************************************
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
    init = SyLoadModule( CSTR_STRING(filename) );
    if ( (Int)init == 1 )
        ErrorQuit( "module '%s' not found", (Int)CSTR_STRING(filename), 0L );
    else if ( (Int) init == 3 )
        ErrorQuit( "symbol 'Init_Dynamic' not found", 0L, 0L );
    else if ( (Int) init == 5 )
        ErrorQuit( "forget symbol failed", 0L, 0L );

    /* no dynamic library support                                          */
    else if ( (Int) init == 7 ) {
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
    ExecBegin( TLS->bottomLVars );
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
        if ( ! SyStrcmp( CSTR_STRING(filename), info->name ) ) {
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
    ExecBegin( TLS->bottomLVars );
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
    Int                 len;

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
        /*CCC name = NEW_STRING( SyStrlen(info->name) );
	  SyStrncat( CSTR_STRING(name), info->name, SyStrlen(info->name) );CCC*/
	len = SyStrlen(info->name);
	C_NEW_STRING(name, len, info->name);

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
            C_NEW_STRING( str, SyStrlen(m->name), m->name );
            SET_ELM_PLIST( list, 3*i+2, str );
            SET_ELM_PLIST( list, 3*i+3, INTOBJ_INT(m->version) );
        }
        else if ( m->type == MODULE_DYNAMIC ) {
            SET_ELM_PLIST( list, 3*i+1, ObjsChar[(Int)'d'] );
	    CHANGED_BAG(list);
            C_NEW_STRING( str, SyStrlen(m->name), m->name );
            SET_ELM_PLIST( list, 3*i+2, str );
	    CHANGED_BAG(list);
            C_NEW_STRING( str, SyStrlen(m->filename), m->filename );
            SET_ELM_PLIST( list, 3*i+3, str );
        }
        else if ( m->type == MODULE_STATIC ) {
            SET_ELM_PLIST( list, 3*i+1, ObjsChar[(Int)'s'] );
	    CHANGED_BAG(list);
            C_NEW_STRING( str, SyStrlen(m->name), m->name );
            SET_ELM_PLIST( list, 3*i+2, str );
	    CHANGED_BAG(list);
            C_NEW_STRING( str, SyStrlen(m->filename), m->filename );
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
    Char                buf[100];

    /* check the argument                                                  */
    while ( ! IS_SMALL_LIST(args) || LEN_LIST(args) == 0 ) {
        args = ErrorReturnObj(
            "usage: GASMAN( \"display\"|\"displayshort\"|\"clear\"|\"collect\"|\"message\"|\"partial\" )",
            0L, 0L,
            "you can replace the argument list <args> via 'return <args>;'" );
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
        if ( SyStrcmp( CSTR_STRING(cmd), "display" ) == 0 ) {
            Pr( "%40s ", (Int)"type",  0L          );
            Pr( "%8s %8s ",  (Int)"alive", (Int)"kbyte" );
            Pr( "%8s %8s\n",  (Int)"total", (Int)"kbyte" );
            for ( k = 0; k < 256; k++ ) {
                if ( InfoBags[k].name != 0 ) {
                    buf[0] = '\0';
                    SyStrncat( buf, InfoBags[k].name, 40 );
                    Pr("%40s ",    (Int)buf, 0L );
                    Pr("%8d %8d ", (Int)InfoBags[k].nrLive,
                                   (Int)(InfoBags[k].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[k].nrAll,
                                   (Int)(InfoBags[k].sizeAll/1024));
                }
            }
        }

        /* if request give a short display of the statistics                */
        else if ( SyStrcmp( CSTR_STRING(cmd), "displayshort" ) == 0 ) {
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
                    SyStrncat( buf, InfoBags[k].name, 40 );
                    Pr("%40s ",    (Int)buf, 0L );
                    Pr("%8d %8d ", (Int)InfoBags[k].nrLive,
                                   (Int)(InfoBags[k].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[k].nrAll,
                                   (Int)(InfoBags[k].sizeAll/1024));
                }
            }
        }

        /* if request display the statistics                               */
        else if ( SyStrcmp( CSTR_STRING(cmd), "clear" ) == 0 ) {
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
        else if ( SyStrcmp( CSTR_STRING(cmd), "collect" ) == 0 ) {
            CollectBags(0,1);
        }

        /* or collect the garbage                                          */
        else if ( SyStrcmp( CSTR_STRING(cmd), "partial" ) == 0 ) {
            CollectBags(0,0);
        }

        /* or display information about global bags                        */
        else if ( SyStrcmp( CSTR_STRING(cmd), "global" ) == 0 ) {
            for ( i = 0;  i < GlobalBags.nr;  i++ ) {
                if ( *(GlobalBags.addr[i]) != 0 ) {
                    Pr( "%50s: %12d bytes\n", (Int)GlobalBags.cookie[i], 
                        (Int)SIZE_BAG(*(GlobalBags.addr[i])) );
                }
            }
        }

        /* or finally toggle Gasman messages                               */
        else if ( SyStrcmp( CSTR_STRING(cmd), "message" ) == 0 ) {
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
    return INTOBJ_INT( SIZE_BAG( obj ) );
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
    Int                 len;
    const Char *        cst;

    res = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( res, 2 );

    /* set the type                                                        */
    SET_ELM_PLIST( res, 1, INTOBJ_INT( TNUM_OBJ(obj) ) );
    cst = TNAM_OBJ(obj);
    /*CCC    str = NEW_STRING( SyStrlen(cst) );
      SyStrncat( CSTR_STRING(str), cst, SyStrlen(cst) );CCC*/
    len = SyStrlen(cst);
    C_NEW_STRING(str, len, cst);
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
*F  FuncXTNUM_OBJ( <self>, <obj> )  . . . . . . . expert function 'XTNUM_OBJ'
*/
Obj FuncXTNUM_OBJ (
    Obj                 self,
    Obj                 obj )
{
    Obj                 res;
    Obj                 str;

    res = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( res, 2 );
    SET_ELM_PLIST( res, 1, Fail );
    C_NEW_STRING(str, 16, "xtnums abolished");
    SET_ELM_PLIST(res, 2,str);
    /* and return                                                          */
    return res;
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
        return 0;
    }
}


/****************************************************************************
**
*F  FuncHANDLE_OBJ( <self>, <obj> ) . . . . . .  expert function 'HANDLE_OBJ'
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

Obj FuncMASTER_POINTER_NUMBER(Obj self, Obj o)
{
    if ((void **) o >= (void **) MptrBags && (void **) o < (void **) OldBags) {
        return INTOBJ_INT( ((void **) o - (void **) MptrBags) + 1 );
    } else {
        return INTOBJ_INT( 0 );
    }
}

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
    if ( TNUM_OBJ(obj1) == T_INT || TNUM_OBJ(obj1) == T_FFE ) {
        ErrorQuit("SWAP_MPTR: <obj1> must not be an integer or ffe", 0L, 0L);
        return 0;
    }
    if ( TNUM_OBJ(obj2) == T_INT || TNUM_OBJ(obj2) == T_FFE ) {
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

*F  FillInVersion( <module>, <rev_c>, <rev_h> ) . . .  fill in version number
*/
static UInt ExtractRevision (
    const Char *                rev,
    const Char * *              name )
{
    const Char *                p;
    const Char *                major;
    const Char *                minor;
    UInt                        ver1;
    UInt                        ver2;

    /* store the revision strings                                          */
    
    /* the revision string is "@(#)Id: filename.x,v major.minor ..."       */
    p = rev;
    while ( *p && *p != ':' )  p++;
    if ( *p )  p++;
    while ( *p && *p == ' ' )  p++;
    *name = p;
    while ( *p && *p != ' ' )  p++;
    while ( *p && *p == ' ' )  p++;
    major = p;
    while ( *p && *p != '.' )  p++;
    if ( *p )  p++;
    while ( *p && *p == '.' )  p++;
    minor = p;

    /* the version is MMmmm, that is 2 digits major, 3 digits minor        */
    ver1 = 0;
    while ( '0' <= *major && *major <= '9' ) {
        ver1 = ver1 * 10 + (UInt)( *major - '0' );
        major++;
    }
    ver2 = 0;
    while ( '0' <= *minor && *minor <= '9' ) {
        ver2 = ver2 * 10 + (UInt)( *minor - '0' );
        minor++;
    }

    return ver1 * 1000 + ver2;
}


void FillInVersion (
    StructInitInfo *            module )
{
    const Char *                p;
    const Char *                q;
    const Char *                name;
    const Char *                rev_c;
    const Char *                rev_h;
    UInt                        c_ver;
    UInt                        h_ver;

    /* store revision entries                                              */
    rev_c = module->revision_c;
    rev_h = module->revision_h;

    /* extract the filename and version entry from <rev_c>                 */
    c_ver = ExtractRevision( rev_c, &name );
    if ( module->name ) {
        p = name;
        q = module->name;
        while ( *p && *q && *p == *q ) { p++; q++; }
        if ( *q || *p != '.' ) {
            FPUTS_TO_STDERR( "#W  corrupt version info '" );
            FPUTS_TO_STDERR( rev_c );
            FPUTS_TO_STDERR( "'\n" );
        }
    }
    h_ver = ExtractRevision( rev_h, &name );
    if ( module->name ) {
        p = name;
        q = module->name;
        while ( *p && *q && *p == *q ) { p++; q++; }
        if ( *q || *p != '.' ) {
            FPUTS_TO_STDERR( "#W  corrupt version info '" );
            FPUTS_TO_STDERR( rev_h );
            FPUTS_TO_STDERR( "'\n" );
        }
    }
    module->version = c_ver*100000+h_ver;
}


/****************************************************************************
**
*F  RequireModule( <calling>, <required>, <version> ) . . . .  require module
*/
void RequireModule (
    StructInitInfo *            module,
    const Char *                required,
    UInt                        version )
{
}


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
        AssGVar( GVarName( tab[i].name ),
            NewFilterC( tab[i].name, 1, tab[i].argument, tab[i].handler ) );
        MakeReadOnlyGVar( GVarName( tab[i].name ) );
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
       AssGVar( GVarName( tab[i].name ),
         NewAttributeC( tab[i].name, 1, tab[i].argument, tab[i].handler ) );
       MakeReadOnlyGVar( GVarName( tab[i].name ) );
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
       AssGVar( GVarName( tab[i].name ),
         NewPropertyC( tab[i].name, 1, tab[i].argument, tab[i].handler ) );
       MakeReadOnlyGVar( GVarName( tab[i].name ) );
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
        AssGVar( GVarName( tab[i].name ), NewOperationC( tab[i].name, 
            tab[i].nargs, tab[i].args, tab[i].handler ) );
        MakeReadOnlyGVar( GVarName( tab[i].name ) );
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
        AssGVar( GVarName( tab[i].name ), NewFunctionC( tab[i].name, 
            tab[i].nargs, tab[i].args, tab[i].handler ) );
        MakeReadOnlyGVar( GVarName( tab[i].name ) );
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

/****************************************************************************
**
*F  FuncQUIT_GAP()
**
*/

Obj FuncQUIT_GAP( Obj self )
{
  UserHasQUIT = 1;
  ReadEvalError();
  return (Obj)0; 
}


/****************************************************************************
**
*V  Revisions . . . . . . . . . . . . . . . . . .  record of revision numbers
*/
Obj Revisions;


/****************************************************************************
**
*F  KERNEL_INFO() ......................record of information from the kernel
** 
** The general idea is to put all kernel-specific info in here, and clean up
** the assortment of global variables previously used
*/

Obj FuncKERNEL_INFO(Obj self) {
  Obj res = NEW_PREC(0);
  UInt r,len,lenvec,lenstr;
  Char *p;
  Obj tmp,list,str;
  UInt i,j;

  /* GAP_ARCHITECTURE                                                    */
  tmp = NEW_STRING(SyStrlen(SyArchitecture));
  RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
  SyStrncat( CSTR_STRING(tmp), SyArchitecture, SyStrlen(SyArchitecture) );
  r = RNamName("GAP_ARCHITECTURE");
  AssPRec(res,r,tmp);
  /* KERNEL_VERSION */
  tmp = NEW_STRING(SyStrlen(SyKernelVersion));
  RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
  SyStrncat( CSTR_STRING(tmp), SyKernelVersion, SyStrlen(SyKernelVersion) );
  r = RNamName("KERNEL_VERSION");
  AssPRec(res,r,tmp);
  /* GAP_ROOT_PATH                                                       */
  /* do we need this. Could we rebuild it from the command line in GAP
     if so, should we                                                    */
  list = NEW_PLIST( T_PLIST+IMMUTABLE, MAX_GAP_DIRS );
  for ( i = 0, j = 1;  i < MAX_GAP_DIRS;  i++ ) {
    if ( SyGapRootPaths[i][0] ) {
      len = SyStrlen(SyGapRootPaths[i]);
      tmp = NEW_STRING(len);
      RetypeBag( tmp, IMMUTABLE_TNUM(TNUM_OBJ(tmp)) );
      SyStrncat( CSTR_STRING(tmp), SyGapRootPaths[i], len );
      SET_ELM_PLIST( list, j, tmp );
      j++;
    }
  }
  SET_LEN_PLIST( list, j-1 );
  r = RNamName("GAP_ROOT_PATHS");
  AssPRec(res,r,list);
      
    /* create a revision record                                            */

    r = RNamName("Revision");
    AssPRec(res, r, Revisions);

    
    /* make command line and environment available to GAP level       */
    for (lenvec=0; SyOriginalArgv[lenvec]; lenvec++);
    tmp = NEW_PLIST( T_PLIST+IMMUTABLE, lenvec );
    SET_LEN_PLIST( tmp, lenvec );
    for (i = 0; i<lenvec; i++) {
      lenstr = SyStrlen(SyOriginalArgv[i]);
      str = NEW_STRING(lenstr);
      SyStrncat(CSTR_STRING(str), SyOriginalArgv[i], lenstr);
      SET_LEN_STRING(str, lenstr);
      SET_ELM_PLIST(tmp, i+1, str);
      CHANGED_BAG(tmp);
    }
    r = RNamName("COMMAND_LINE");
    AssPRec(res,r, tmp);

    tmp = NEW_PREC(0);
    for (i = 0; sysenviron[i]; i++) {
      for (p = sysenviron[i]; *p != '='; p++)
	;
      *p++ = '\0';
      lenstr = SyStrlen(p);
      str = NEW_STRING(lenstr);
      SyStrncat(CSTR_STRING(str),p, lenstr);
      SET_LEN_STRING(str, lenstr);
      AssPRec(tmp,RNamName(sysenviron[i]), str);
      *--p = '='; /* change back to allow a convenient rerun */
    }
    r = RNamName("ENVIRONMENT");
    AssPRec(res,r, tmp);
   
    return res;
  
}


/****************************************************************************
**
*F FuncGETPID  ... export UNIX getpid to GAP level
**
*/

Obj FuncGETPID(Obj self) {
  return INTOBJ_INT(getpid());
}

void ThreadedInterpreter(void *function) {
  Obj tmp;

  /* intialize everything and begin an interpreter                       */
  TLS->stackNams   = NEW_PLIST( T_PLIST, 16 );
  TLS->countNams   = 0;
  TLS->readTop     = 0;
  TLS->readTilde   = 0;
  TLS->currLHSGVar = 0;
  TLS->intrCoding = 0;
  TLS->intrIgnoring = 0;
  TLS->nrError = 0;
  TLS->bottomLVars = NewBag( T_LVARS, 3*sizeof(Obj) );
  tmp = NewFunctionC( "bottom", 0, "", 0 );
  PTR_BAG(TLS->bottomLVars)[0] = tmp;
  tmp = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );
  BODY_FUNC( PTR_BAG(TLS->bottomLVars)[0] ) = tmp;
  TLS->currLVars = TLS->bottomLVars;

  IntrBegin( TLS->bottomLVars );

  if (!READ_ERROR()) {
    CALL_0ARGS((Obj)function);
    PushVoidObj();
    /* end the interpreter                                                 */
    IntrEnd( 0UL );
  } else {
    IntrEnd( 1UL );
    ClearError();
  } 
}

/****************************************************************************
**
*F FuncCreateThread  ... create a new thread
**
** The function creates a new thread with a new interpreter and executes
** the function passed as an argument in it. It returns an integer that
** is a unique identifier for the thread.
*/

Obj FuncCreateThread(Obj self, Obj function) {
  int id;
  id = RunThread(ThreadedInterpreter, function);
  return INTOBJ_INT(id);
}

/****************************************************************************
**
*F FuncWaitThread  ... wait for a created thread to finish.
**
** The function waits for an existing thread to finish.
*/

Obj FuncWaitThread(Obj self, Obj id) {
  int thread_num = INT_INTOBJ(id);
  JoinThread(thread_num);
  return (Obj) 0;
}

/****************************************************************************
**
*F FuncLock ........... acquire write lock on an object.
*F FuncUnlock ......... release write lock on an object.
*F FuncLockShared ..... acquire read lock on an object.
*F FuncUnlockShared ... release read lock on an object.
**
*/


Obj FuncLock(Obj self, Obj target) {
  Lock(target);
  return (Obj) 0;
}

Obj FuncUnlock(Obj self, Obj target) {
  Unlock(target);
  return (Obj) 0;
}

Obj FuncLockShared(Obj self, Obj target) {
  LockShared(target);
  return (Obj) 0;
}

Obj FuncUnlockShared(Obj self, Obj target) {
  UnlockShared(target);
  return (Obj) 0;
}

/****************************************************************************
**
*F FuncSynchronized ......... execute a function while holding a write lock.
*F FuncSynchronizedShared ... execute a function while holding a read lock.
**
*/

Obj FuncSynchronized(Obj self, Obj target, Obj function) {
  volatile int locked = 0;
  jmp_buf readJmpError;
  memcpy( readJmpError, TLS->readJmpError, sizeof(jmp_buf) );
  if (!READ_ERROR()) {
    Lock(target);
    locked = 1;
    CALL_0ARGS(function);
    locked = 0;
    Unlock(target);
  }
  if (locked)
    Unlock(target);
  memcpy( TLS->readJmpError, readJmpError, sizeof(jmp_buf) );
  return (Obj) 0;
}

Obj FuncSynchronizedShared(Obj self, Obj target, Obj function) {
  volatile int locked = 0;
  jmp_buf readJmpError;
  memcpy( readJmpError, TLS->readJmpError, sizeof(jmp_buf) );
  if (!READ_ERROR()) {
    LockShared(target);
    locked = 1;
    CALL_0ARGS(function);
    locked = 0;
    UnlockShared(target);
  }
  if (locked)
    UnlockShared(target);
  memcpy( TLS->readJmpError, readJmpError, sizeof(jmp_buf) );
  return (Obj) 0;
}

Obj FuncCreateChannel(Obj self, Obj args);
Obj FuncDestroyChannel(Obj self, Obj id);
Obj FuncSendChannel(Obj self, Obj id, Obj obj);
Obj FuncReceiveChannel(Obj self, Obj id);
Obj FuncTrySendChannel(Obj self, Obj id, Obj obj);
Obj FuncTryReceiveChannel(Obj self, Obj id, Obj defaultobj);

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "Runtime", 0, "",
      FuncRuntime, "src/gap.c:Runtime" },

    { "RUNTIMES", 0, "",
      FuncRUNTIMES, "src/gap.c:RUNTIMES" },

    { "SizeScreen", -1, "args",
      FuncSizeScreen, "src/gap.c:SizeScreen" },

    { "ID_FUNC", 1, "object",
      FuncID_FUNC, "src/gap.c:ID_FUNC" },

    { "RESTART_GAP", 1, "cmdline",
      FuncRESTART_GAP, "src/gap.c:RESTART_GAP" },

    { "ExportToKernelFinished", 0, "",
      FuncExportToKernelFinished, "src/gap.c:ExportToKernelFinished" },

    { "DownEnv", -1, "args",
      FuncDownEnv, "src/gap.c:DownEnv" },

    { "UpEnv", -1, "args",
      FuncUpEnv, "src/gap.c:UpEnv" },


    { "COM_FILE", 2, "filename, crc",
      FuncCOM_FILE, "src/gap.c:COM_FILE" },

    { "COM_FUN", 1, "number",
      FuncCOM_FUN, "src/gap.c:COM_FUN" },

    { "MAKE_INIT", 2, "output, input",
      FuncMAKE_INIT, "src/gap.c:MAKE_INIT" },

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

    { "XTNUM_OBJ", 1, "object",
      FuncXTNUM_OBJ, "src/gap.c:XTNUM_OBJ" },

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


    { "Sleep", 1, "secs",
      FuncSleep, "src/gap.c:Sleep" },

    { "QUIT_GAP", 0, "",
      FuncQUIT_GAP, "src/gap.c:QUIT_GAP" },


    { "SHELL", -1, "context, canReturnVoid, canReturnObj, lastDepth, setTime, prompt, promptHook, infile, outfile",
      FuncSHELL, "src/gap.c:FuncSHELL" },

    { "CALL_WITH_CATCH", 2, "func, args",
      FuncCALL_WITH_CATCH, "src/gap.c:CALL_WITH_CATCH" },

    { "JUMP_TO_CATCH", 1, "payload",
      FuncJUMP_TO_CATCH, "src/gap.c:JUMP_TO_CATCH" },


    { "KERNEL_INFO", 0, "",
      FuncKERNEL_INFO, "src/gap.c:KERNEL_INFO" },

    { "SetUserHasQuit", 1, "value",
      FuncSetUserHasQuit, "src/gap.c:SetUserHasQuit" },

    { "GETPID", 0, "",
      FuncGETPID, "src/gap.c:GETPID" },

    { "MASTER_POINTER_NUMBER", 1, "ob",
      FuncMASTER_POINTER_NUMBER, "src/gap.c:MASTER_POINTER_NUMBER" },

    { "FUNC_BODY_SIZE", 1, "f",
      FuncFUNC_BODY_SIZE, "src/gap.c:FUNC_BODY_SIZE" },

    { "PRINT_CURRENT_STATEMENT", 1, "context",
      FuncPrintExecutingStatement, "src/gap.c:PRINT_CURRENT_STATEMENT" },

    { "CreateThread", 1, "function",
      FuncCreateThread, "src/gap.c:CreateThread" },

    { "WaitThread", 1, "threadID",
      FuncWaitThread, "src/gap.c:WaitThread" },

    { "Lock", 1, "object",
      FuncLock, "src/gap.c:Lock" },
    
    { "LockShared", 1, "object",
      FuncLockShared, "src/gap.c:LockShared" },
    
    { "Unlock", 1, "object",
      FuncUnlock, "src/gap.c:Unlock" },
    
    { "UnlockShared", 1, "object",
      FuncUnlockShared, "src/gap.c:UnlockShared" },

    { "Synchronized", 2, "object, function",
      FuncSynchronized, "src/gap.c:Synchronized" },

    { "SynchronizedShared", 2, "object, function",
      FuncSynchronizedShared, "src/gap.c:SynchronizedShared" },

    { "CreateChannel", -1, "string [, size]",
      FuncCreateChannel, "src/synchronize.c:CreateChannel" },

    { "DestroyChannel", 1, "channelid",
      FuncDestroyChannel, "src/synchronize.c:DestroyChannel" },

    { "SendChannel", 2, "channelid, obj",
      FuncSendChannel, "src/synchronize.c:SendChannel" },

    { "ReceiveChannel", 1, "channelid",
      FuncReceiveChannel, "src/synchronize:ReceiveChannel" },

    { "TryReceiveChannel", 2, "channelid, obj",
      FuncTryReceiveChannel, "src/synchronize.c:TryReceiveChannel" },

    { "TrySendChannel", 2, "channelid, obj",
      FuncTrySendChannel, "src/synchronize.c:TrySendChannel" },
    
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
    InitGlobalBag( &CompNowFuncs,      "src/gap.c:CompNowFuncs"      );
    InitGlobalBag( &CompThenFuncs,     "src/gap.c:CompThenFuncs"     );
    InitGlobalBag( &CompLists,         "src/gap.c:CompLists"         );
    InitGlobalBag( &StringUncompleted, "src/gap.c:StringUncompleted" );
    InitGlobalBag( &EmptyList,         "src/gap.c:EmptyList"         );

    InitGlobalBag( &Revisions,         "src/gap.c:Revisions"         );
    InitGlobalBag( &ThrownObject,      "src/gap.c:ThrownObject"      );

    /* list of exit functions                                              */
    InitGlobalBag( &AtExitFunctions, "src/gap.c:AtExitFunctions" );
    InitGlobalBag( &WindowCmdString, "src/gap.c:WindowCmdString" );

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* use short cookies to save space in saved workspace                  */
    InitHandlerFunc( DoComplete0args, "c0" );
    InitHandlerFunc( DoComplete1args, "c1" );
    InitHandlerFunc( DoComplete2args, "c2" );
    InitHandlerFunc( DoComplete3args, "c3" );
    InitHandlerFunc( DoComplete4args, "c4" );
    InitHandlerFunc( DoComplete5args, "c5" );
    InitHandlerFunc( DoComplete6args, "c6" );
    InitHandlerFunc( DoCompleteXargs, "cX" );


    /* establish Fopy of ViewObj                                           */
    ImportFuncFromLibrary(  "ViewObj", 0L );
    ImportFuncFromLibrary(  "Error", &Error );
    ImportFuncFromLibrary(  "ErrorInner", &ErrorInner );


#if !SYS_MAC_MWC
#if HAVE_SELECT
    InitCopyGVar("OnCharReadHookActive",&OnCharReadHookActive);
    InitCopyGVar("OnCharReadHookInFds",&OnCharReadHookInFds);
    InitCopyGVar("OnCharReadHookInFuncs",&OnCharReadHookInFuncs);
    InitCopyGVar("OnCharReadHookOutFds",&OnCharReadHookOutFds);
    InitCopyGVar("OnCharReadHookOutFuncs",&OnCharReadHookOutFuncs);
    InitCopyGVar("OnCharReadHookExcFds",&OnCharReadHookExcFds);
    InitCopyGVar("OnCharReadHookExcFuncs",&OnCharReadHookExcFuncs);
#endif
#endif

    /* If a package or .gaprc or file read from the command line
       sets this to a function, then we want to know                       */
    InitCopyGVar(  "AlternativeMainLoop", &AlternativeMainLoop );

    InitGlobalBag(&ErrorHandler, "gap.c: ErrorHandler");

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

    /* create a revision record                                            */
    Revisions = NEW_PREC(0);

    /* library name and other stuff                                        */
    var = GVarName( "DEBUG_LOADING" );
    MakeReadWriteGVar(var);
    AssGVar( var, (SyDebugLoading ? True : False) );
    MakeReadOnlyGVar(var);

    /* construct the `ViewObj' variable                                    */
    ViewObjGVar = GVarName( "ViewObj" ); 
    CustomViewGVar = GVarName( "CustomView" ); 

    /* construct the last and time variables                               */
    Last              = GVarName( "last"  );
    Last2             = GVarName( "last2" );
    Last3             = GVarName( "last3" );
    Time              = GVarName( "time"  );
    SaveOnExitFileGVar= GVarName( "SaveOnExitFile" );
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
    /* init the completion function                                        */
    CompLists = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( CompLists, 0 );


    /* share between uncompleted functions                                 */
    C_NEW_STRING( StringUncompleted, 11, "uncompleted" );
    RESET_FILT_LIST( StringUncompleted, FN_IS_MUTABLE );
    EmptyList = NEW_PLIST( T_PLIST+IMMUTABLE, 0 );
    SET_LEN_PLIST( EmptyList, 0 );

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
    module.revision_c = Revision_gap_c;
    module.revision_h = Revision_gap_h;
    FillInVersion( &module );
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
    InitInfoRat,
    InitInfoCyc,
    InitInfoFinfield,
    InitInfoPermutat,
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

#ifdef GAPMPI
    /* ParGAP/MPI module						   */
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
    len = SyStrlen(filename);
    if (NextLoadedModuleFilename + len + 1
	> LoadedModuleFilenames+MAX_MODULE_FILENAMES) {
      Pr( "panic: no room for module filename\n", 0L, 0L );
    }
    *NextLoadedModuleFilename = '\0';
    SyStrncat(NextLoadedModuleFilename,filename, len);
    info->filename = NextLoadedModuleFilename;
    NextLoadedModuleFilename += len +1;
    Modules[NrModules++] = info;
}


/****************************************************************************
**

*F  SET_REVISION( <file>, <revision> )  . . . . . . . . . enter revision info
*/
#define SET_REVISION( file, revision ) \
  do { \
      UInt                    rev_rnam; \
      Obj                     rev_str; \
      rev_rnam = RNamName(file); \
      C_NEW_STRING( rev_str, SyStrlen(revision), (revision) ); \
      RESET_FILT_LIST( rev_str, FN_IS_MUTABLE ); \
      AssPRec( Revisions, rev_rnam, rev_str ); \
  } while (0)


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
    char *              argv [] )
{
  /*    UInt                type; */
    UInt                i;
    Int                 ret;


    /* initialize the basic system and gasman                              */
#ifdef GAPMPI
    /* ParGAP/MPI needs to call MPI_Init() first to remove command line args */
    InitGapmpi( pargc, &argv, &BreakOnError );
#endif

    InitSystem( *pargc, argv );

    InitBags( SyAllocBags, SyStorMin,
              0, (Bag*)(((UInt)pargc/SyStackAlign)*SyStackAlign), SyStackAlign,
              SyCacheSize, 0, SyAbortBags );
    InitMsgsFuncBags( SyMsgsBags );


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
                    SyStrncat( buf, InfoBags[i].name, 40 );
                    Pr("#W  %36s ",    (Int)buf, 0L );
                    Pr("%8d %8d ", (Int)InfoBags[i].nrLive,
                       (Int)(InfoBags[i].sizeLive/1024));
                    Pr("%8d %8d\n",(Int)InfoBags[i].nrAll,
                       (Int)(InfoBags[i].sizeAll/1024));
                }
            }
        }
#   endif

#ifdef SYS_IS_MAC_MWC
	ActivateIntr ();
#endif

#ifndef BOEHM_GC
    /* and now for a special hack                                          */
    for ( i = LAST_CONSTANT_TNUM+1; i <= LAST_REAL_TNUM; i++ ) {
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
	  if (!READ_ERROR())
	    CALL_0ARGS(POST_RESTORE);
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

    /* create a revision record (overwrite a restored one)                 */
    for ( i = 0;  i < NrBuiltinModules;  i++ ) {
        Char buf[30];

        buf[0] = 0;
        SyStrncat( buf, Modules[i]->name, 27 );
        SyStrncat( buf, "_c", 2 );
        SET_REVISION( buf, Modules[i]->revision_c );
        buf[0] = 0;
        SyStrncat( buf, Modules[i]->name, 27 );
        SyStrncat( buf, "_h", 2 );
        SET_REVISION( buf, Modules[i]->revision_h );
    }

    /* add revisions for files which are not modules                       */
    {
        SET_REVISION( "system_c", Revision_system_c );
        SET_REVISION( "system_h", Revision_system_h );
        SET_REVISION( "gasman_c", Revision_gasman_c );
        SET_REVISION( "gasman_h", Revision_gasman_h );
    }

    /* read the init files      
       this now actually runs the GAP session, we only get 
       past here when we're about to exit. 
                                           */
    if ( SySystemInitFile[0] ) {
      if (!READ_ERROR()) {
        if ( READ_GAP_ROOT(SySystemInitFile) == 0 ) {
	  /*             if ( ! SyQuiet ) { */
                Pr( "gap: hmm, I cannot find '%s' maybe",
                    (Int)SySystemInitFile, 0L );
                Pr( " use option '-l <gaproot>'?\n If you ran the GAP\
 binary directly, try running the 'gap.sh' or 'gap.bat' script instead.", 0L, 0L );
            }
      }
      else
	{
	  Pr("Caught error at top-most level, probably quit from library loading",0L,0L);
	  SyExit(1);
	}
	/*         } */
    }

}

/* Read and write atomic words */

#define AtomicRead(v) (v)
#define AtomicWrite(x, v) (x) = (v)

#define MemoryBarrier()

#define TABLE_SIZE 4096

/* Shared object types */

#define T_CHANNEL 0
#define T_BARRIER 1
#define T_SYNCVAR 2

typedef struct SharedObject
{
  struct SharedObject *next;
  char *name;
  int type;
  unsigned id;
  pthread_mutex_t lock;
  void *data;
} SharedObject;

typedef struct Channel
{
  Obj queue;
  Obj keepAlive;
  unsigned id;
  int waiting;
  int head, tail;
  int size, capacity;
  int dynamic;
  pthread_mutex_t *lock;
  pthread_cond_t signal;
} Channel;

typedef struct Barrier
{
  int count;
} Barrier;


/* TODO: register globals */
Obj firstKeepAlive;
Obj lastKeepAlive;

#define ANON_OBJECT NULL
unsigned AnonIndex = 0;

SharedObject *SharedTable[TABLE_SIZE];

pthread_mutex_t tableLock;

void *Allocate(size_t size)
{
  return malloc(size);
}

void Free(void *addr)
{
  free(addr);
}

void LockTable()
{
  pthread_mutex_lock(&tableLock);
}

void UnlockTable()
{
  pthread_mutex_unlock(&tableLock);
}


SharedObject *AllocateSharedObject(char *name, int type, void *data, unsigned id)
{
  SharedObject *result = Allocate(sizeof(SharedObject));
  result->next = NULL;
  result->name = name;
  result->type = type;
  result->data = data;
  result->id = id;
  pthread_mutex_init(&result->lock, NULL);
  return result;
}

unsigned HashShared(char *name, int type)
{
  unsigned result = type;
  while (*name)
  {
    result *= 100093;
    result += *(unsigned char *)name;
    name++;
  }
  return result;
}

void LockSharedObject(SharedObject *ob)
{
  pthread_mutex_lock(&ob->lock);
}

void UnlockSharedObject(SharedObject *ob)
{
  pthread_mutex_unlock(&ob->lock);
}

SharedObject* CreateObject(char *name, int type, void *data)
{
  unsigned hash, index;
  unsigned pos = 0;
  SharedObject **currentp;
  SharedObject *current, *result;
  if (name == ANON_OBJECT)
  {
    LockTable();
    index = AnonIndex = (AnonIndex + 1) % TABLE_SIZE;
    currentp = &SharedTable[index];
    while ((current = *currentp))
    {
      if (current->name == name && current->type == type && current->data == 0)
      {
	LockSharedObject(current);
	MemoryBarrier();
        AtomicWrite(current->data, data);
	UnlockTable();
	return current;
      }
      pos++;
      currentp = &current->next;
    }
    result = AllocateSharedObject(name, type, data, index+TABLE_SIZE*pos);
    LockSharedObject(result);
    MemoryBarrier();
    AtomicWrite(*currentp, result);
    UnlockTable();
    return result;
  }
  hash = HashShared(name, type);
  index = hash % TABLE_SIZE;
  LockTable();
  currentp = &SharedTable[index];
  while ((current = AtomicRead(*currentp)))
  {
    if (strcmp(AtomicRead(current->name), name) == 0
        && AtomicRead(current->type) == type)
    {
      if (current->data == 0)
      {
	LockSharedObject(current);
	MemoryBarrier();
        AtomicWrite(current->data, data);
	UnlockTable();
	return current;
      }
      UnlockTable();
      return NULL;
    }
    currentp = &current->next;
    pos++;
  }
  result = AllocateSharedObject(name, type, data, index+TABLE_SIZE*pos);
  LockSharedObject(result);
  MemoryBarrier();
  AtomicWrite(*currentp, result);
  UnlockTable();
  return result;
}

void *DestroyObject(unsigned id, int type)
{
  SharedObject *current;
  unsigned index = id % TABLE_SIZE;
  void *result;
  LockTable();
  id /= TABLE_SIZE;
  current = AtomicRead(SharedTable[index]);
  while (id && current)
  {
    id--;
    current = AtomicRead(current->next);
  }
  if (current->type == type)
  {
    result = current->data;
    AtomicWrite(current->data, 0);
    UnlockTable();
    return result;
  }
  UnlockTable();
  return 0;
}

void *FindObjectById(unsigned id, int type)
{
  SharedObject *current;
  unsigned index = id % TABLE_SIZE;
  id /= TABLE_SIZE;
  current = AtomicRead(SharedTable[index]);
  while (id && current)
  {
    id--;
    current = AtomicRead(current->next);
  }
  if (current && AtomicRead(current->type) == type)
  {
    void *result;
    LockSharedObject(current);
    result = AtomicRead(current->data);
    if (result)
      return result;
    UnlockSharedObject(current);
    return NULL;
  }
  return NULL;
}

void *FindObjectByName(char *name, int type)
{
  SharedObject *current;
  unsigned hash = HashShared(name, type);
  unsigned index = hash % TABLE_SIZE;
  current = AtomicRead(SharedTable[index]);
  while (current)
  {
    if (strcmp(current->name, name) == 0
        && current->name != ANON_OBJECT
        && AtomicRead(current->type == type))
    {
      void *result;
      LockSharedObject(current);
      result = AtomicRead(current->data);
      if (result)
        return result;
      UnlockSharedObject(current);
      return NULL;
    }
  }
  return NULL;
}

#define PREV(obj) (ADDR_OBJ(obj)[2])
#define NEXT(obj) (ADDR_OBJ(obj)[3])

Obj KeepAlive(Obj obj)
{
  Obj newKeepAlive = NewBag( T_PLIST, 4*sizeof(Obj) );
  LockTable();
  ADDR_OBJ(newKeepAlive)[0] = (Obj) 3; /* Length 3 */
  ADDR_OBJ(newKeepAlive)[1] = obj;
  PREV(newKeepAlive) = lastKeepAlive;
  NEXT(newKeepAlive) = (Obj) 0;
  if (lastKeepAlive)
    NEXT(lastKeepAlive) = newKeepAlive;
  else
    firstKeepAlive = lastKeepAlive = newKeepAlive;
  UnlockTable();
  return newKeepAlive;
}

void StopKeepAlive(Obj node)
{
  Obj pred, succ;
  LockTable();
  pred = PREV(node);
  succ = NEXT(node);
  if (pred)
    NEXT(pred) = succ;
  else
    firstKeepAlive = succ;
  if (succ)
    PREV(succ) = pred;
  else
    lastKeepAlive = pred;
  UnlockTable();
}

static void LockChannel(Channel *channel)
{
  pthread_mutex_lock(channel->lock);
}

static void UnlockChannel(Channel *channel)
{
  pthread_mutex_unlock(channel->lock);
}

static void SignalChannel(Channel *channel)
{
  if (channel->waiting)
    pthread_cond_broadcast(&channel->signal);
}

static void WaitChannel(Channel *channel)
{
  channel->waiting++;
  pthread_cond_wait(&channel->signal, channel->lock);
  channel->waiting--;
}

static void ExpandChannel(Channel *channel)
{
  /* Growth ratio should be less than the golden ratio */
  unsigned oldCapacity = channel->capacity;
  unsigned newCapacity = oldCapacity * 16 / 10;
  unsigned i, tail;
  if (newCapacity == oldCapacity)
    newCapacity++;
  channel->capacity = newCapacity;
  GROW_PLIST(channel->queue, newCapacity);
  SET_LEN_PLIST(channel->queue, newCapacity);
  /* assert(channel->head == channel->tail); */
  if (channel->tail <= channel->head)
  {
    for (i = 0; i < channel->tail; i++)
    {
      unsigned d = oldCapacity+i;
      if (d >= newCapacity)
	d -= newCapacity;
      ADDR_OBJ(channel->queue)[d+1] = ADDR_OBJ(channel->queue)[i+1];
    }
    tail = channel->head + oldCapacity;
    if (tail >= newCapacity)
      tail -= newCapacity;
    channel->tail = tail;
  }
}

static void ContractChannel(Channel *channel)
{
  /* Not yet implemented */
}

static void SendChannel(Channel *channel, Obj obj)
{
  if (channel->size == channel->capacity && channel->dynamic)
    ExpandChannel(channel);
  while (channel->size == channel->capacity)
    WaitChannel(channel);
  ADDR_OBJ(channel->queue)[1+channel->tail++] = obj;
  if (channel->tail == channel->capacity)
    channel->tail = 0;
  channel->size++;
  SignalChannel(channel);
  UnlockChannel(channel);
}

static int TrySendChannel(Channel *channel, Obj obj)
{
  if (channel->size == channel->capacity && channel->dynamic)
    ExpandChannel(channel);
  if (channel->size == channel->capacity)
  {
    UnlockChannel(channel);
    return 0;
  }
  ADDR_OBJ(channel->queue)[1+channel->tail++] = obj;
  if (channel->tail == channel->capacity)
    channel->tail = 0;
  channel->size++;
  SignalChannel(channel);
  UnlockChannel(channel);
  return 1;
}

static Obj ReceiveChannel(Channel *channel)
{
  Obj result;
  while (channel->size == 0)
    WaitChannel(channel);
  result = ADDR_OBJ(channel->queue)[1+channel->head++];
  if (channel->head == channel->capacity)
    channel->head = 0;
  channel->size--;
  SignalChannel(channel);
  UnlockChannel(channel);
  return result;
}

static Obj TryReceiveChannel(Channel *channel, Obj defaultobj)
{
  Obj result;
  if (channel->size == 0)
  {
    UnlockChannel(channel);
    return defaultobj;
  }
  result = ADDR_OBJ(channel->queue)[1+channel->head++];
  if (channel->head == channel->capacity)
    channel->head = 0;
  channel->size--;
  SignalChannel(channel);
  UnlockChannel(channel);
  return result;
}

static int CreateChannel(char *name, int capacity)
{
  Channel *channel;
  SharedObject *container;
  channel = Allocate(sizeof(Channel));
  container = CreateObject(name, T_CHANNEL, channel);
  if (!container) {
    Free(channel);
    return -1;
  }
  channel->id = container->id;
  channel->lock = &container->lock;
  pthread_cond_init(&channel->signal, NULL);
  channel->size = channel->head = channel->tail = 0;
  channel->capacity = (capacity < 0) ? 10 : capacity;
  channel->dynamic = (capacity < 0);
  channel->waiting = 0;
  channel->queue = NEW_PLIST( T_PLIST, channel->capacity);
  SET_LEN_PLIST(channel->queue, channel->capacity);
  channel->keepAlive = KeepAlive(channel->queue);
  UnlockChannel(channel);
  UnlockTable();
  return container->id;
}

static int DestroyChannel(Channel *channel)
{
  Obj keepAlive = channel->keepAlive;
  if (channel->waiting)
  {
    UnlockChannel(channel);
    return 0;
  }
  DestroyObject(channel->id, T_CHANNEL);
  UnlockChannel(channel);
  pthread_cond_destroy(&channel->signal);
  Free(channel);
  StopKeepAlive(keepAlive);
  return 1;
}

void ImmediateError(char *message)
{
  ErrorQuit(message, 0, 0);
}

Obj FuncCreateChannel(Obj self, Obj args)
{
  char *name;
  int capacity;
  switch (LEN_PLIST(args))
  {
    case 0:
      name = ANON_OBJECT;
      capacity = -1;
      break;
    case 1:
      if (IS_STRING(ELM_PLIST(args, 1)))
      {
        name = CSTR_STRING(ELM_PLIST(args, 1));
	capacity = -1;
	break;
      }
      if (IS_INTOBJ(ELM_PLIST(args, 1)))
      {
        name = ANON_OBJECT;
	capacity = INT_INTOBJ(ELM_PLIST(args, 1));
	if (capacity <= 0)
	  ImmediateError("CreateChannel: Capacity must be positive");
	break;
      }
      ImmediateError("CreateChannel: Single argument must be a string or capacity");
    case 2:
      if (!IS_STRING(ELM_PLIST(args, 1)))
	ImmediateError("CreateChannel: First argument must be a string");
      if (!IS_INTOBJ(ELM_PLIST(args, 2)))
	ImmediateError("CreateChannel: Second argument must be an integer");
      name = CSTR_STRING(ELM_PLIST(args, 1));
      capacity = INT_INTOBJ(ELM_PLIST(args, 2));
      if (capacity <= 0)
	ImmediateError("CreateChannel: Capacity must be positive");
      break;
    default:
      ImmediateError("CreateChannel: Function takes up to two arguments");
      return (Obj) 0; /* control flow hint */
  }
  return INTOBJ_INT(CreateChannel(name, capacity));
}

Obj FuncDestroyChannel(Obj self, Obj ident)
{
  char *name;
  Channel *channel;
  if (IS_STRING(ident))
  {
    name = CSTR_STRING(ident);
    channel = FindObjectByName(name, T_CHANNEL);
  }
  else if (IS_INTOBJ(ident))
  {
    int id = INT_INTOBJ(ident);
    if (id < 0)
      ImmediateError("DestroyChannel: Channel identifier must be a non-negative integer");
    channel = FindObjectById(INT_INTOBJ(ident), T_CHANNEL);
  }
  else
  {
    ImmediateError("DestroyChannel: Argument must be a string or non-negative integer");
    return (Obj) 0; /* flow control hint */
  }
  if (!channel)
    ImmediateError("DestroyChannel: No such channel exists");
  if (!DestroyChannel(channel))
    ImmediateError("DestroyChannel: Channel is in use");
  return (Obj) 0;
}

Channel *LookupChannel(int id, char *func)
{
  Channel *channel = FindObjectById(id, T_CHANNEL);
  if (!channel)
    ImmediateError("%s: Can't find channel");
  return channel;
}

Obj FuncSendChannel(Obj self, Obj idobj, Obj obj)
{
  int id;
  if (!IS_INTOBJ(idobj))
    ImmediateError("SendChannel: Channel identifier must be a number");
  id = INT_INTOBJ(idobj);
  if (id < 0)
    ImmediateError("SendChannel: Channel identifier must be non-negative");
  SendChannel(LookupChannel(id, "SendChannel"), obj);
  return (Obj) 0;
}

Obj FuncTrySendChannel(Obj self, Obj idobj, Obj obj)
{
  int id;
  if (!IS_INTOBJ(idobj))
    ImmediateError("TrySendChannel: Channel identifier must be a number");
  id = INT_INTOBJ(idobj);
  if (id < 0)
    ImmediateError("TrySendChannel: Channel identifier must be non-negative");
  return INTOBJ_INT(TrySendChannel(LookupChannel(id, "TrySendChannel"), obj));
}

Obj FuncReceiveChannel(Obj self, Obj idobj)
{
  int id;
  if (!IS_INTOBJ(idobj))
    ImmediateError("ReceiveChannel: Channel identifier must be a number");
  id = INT_INTOBJ(idobj);
  if (id < 0)
    ImmediateError("ReceiveChannel: Channel identifier must be non-negative");
  return ReceiveChannel(LookupChannel(id, "ReceiveChannel"));
}

Obj FuncTryReceiveChannel(Obj self, Obj idobj, Obj obj)
{
  int id;
  if (!IS_INTOBJ(idobj))
    ImmediateError("TryReceiveChannel: Channel identifier must be a number");
  id = INT_INTOBJ(idobj);
  if (id < 0)
    ImmediateError("TryReceiveChannel: Channel identifier must be non-negative");
  return INTOBJ_INT(TryReceiveChannel(LookupChannel(id, "TryReceiveChannel"),
           obj));
}



/****************************************************************************
**

*E  gap.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


