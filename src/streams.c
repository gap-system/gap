/****************************************************************************
**
*W  streams.c                   GAP source                       Frank Celler
*W                                                  & Burkhard Höfling (MAC)
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the  various read-eval-print loops and streams related
**  stuff.  The system depend part is in "sysfiles.c".
*/

#include        "system.h"              /* system dependent part           */

#include        <errno.h>
#include        <stdio.h>
#include        <string.h>              /* memcpy */

#include        <unistd.h>              /* fstat, write, read              */
#include        <sys/types.h>
#include        <dirent.h>              /* for reading a directory         */
#include        <sys/stat.h>
#if HAVE_SYS_TIME_H
#include        <sys/time.h>
#endif



#include        "sysfiles.h"            /* file input/output               */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */
#include        "code.h"                /* coder                           */

#include        "gap.h"                 /* error handling, initialisation  */
#include        "read.h"                /* reader                          */
#include        "funcs.h"               /* functions                       */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */

#include        "bool.h"                /* booleans                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "saveload.h"            /* saving and loading              */

#include        "streams.h"             /* streams package                 */

#include        "code.h"

#include	"tls.h"

#include        "vars.h"                /* TLS(BottomLVars) for execution contexts */


/****************************************************************************
**

*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/

Int READ_COMMAND ( void )
{
    ExecStatus    status;

    ClearError();
    status = ReadEvalCommand(TLS(BottomLVars), 0);
    if( status == STATUS_EOF )
        return 0;

    if ( TLS(UserHasQuit) || TLS(UserHasQUIT) )
        return 0;
    
    /* handle return-value or return-void command                          */
    if ( status & (STATUS_RETURN_VAL | STATUS_RETURN_VOID) ) {
        Pr( "'return' must not be used in file read-eval loop", 0L, 0L );
    }

    /* handle quit command                                 */
    else if (status == STATUS_QUIT) {
        TLS(RecursionDepth) = 0;
        TLS(UserHasQuit) = 1;
    }
    else if (status == STATUS_QQUIT) {
        TLS(UserHasQUIT) = 1;
    }
    ClearError();

    return 1;
}

/*
 Returns a list with one or two entries. The first
 entry is set to "false" if there was any error
 executing the command, and "true" otherwise.
 The second entry, if present, is the return value of
 the command. If it not present, the command returned nothing.
*/
Obj FuncREAD_COMMAND_REAL ( Obj self, Obj stream, Obj echo )
{
    Int status;
    Obj result;

    result = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST(result, 1);
    SET_ELM_PLIST(result, 1, False);

    /* try to open the file                                                */
    if ( ! OpenInputStream(stream) ) {
        return result;
    }

    if (echo == True)
      TLS(Input)->echo = 1;
    else
      TLS(Input)->echo = 0;

    status = READ_COMMAND();
    
    CloseInput();

    if( status == 0 ) return result;

    if (TLS(UserHasQUIT)) {
      TLS(UserHasQUIT) = 0;
      return result;
    }

    if (TLS(UserHasQuit)) {
      TLS(UserHasQuit) = 0;
    }
    
    SET_ELM_PLIST(result, 1, True);
    if (TLS(ReadEvalResult)) {
        SET_LEN_PLIST(result, 2);
        SET_ELM_PLIST(result, 2, TLS(ReadEvalResult));
    }
    return result;
}

/*
 Deprecated alternative to READ_COMMAND_REAL, kept for now to maintain
 compatibility with the few packages that use it.
 */
Obj FuncREAD_COMMAND ( Obj self, Obj stream, Obj echo )
{
    Obj result;
    result = FuncREAD_COMMAND_REAL(self, stream, echo);
    return (LEN_PLIST(result) == 2) ? ELM_PLIST(result, 2) : SuPeRfail;
}

/****************************************************************************
**

*F  READ()  . . . . . . . . . . . . . . . . . . . . . . .  read current input
**
**  Read the current input and close the input stream.
*/

static UInt LastReadValueGVar;

static Int READ_INNER ( UInt UseUHQ )
{
    ExecStatus                status;

    if (TLS(UserHasQuit))
      {
        Pr("Warning: Entering READ with UserHasQuit set, this should never happen, resetting",0,0);
        TLS(UserHasQuit) = 0;
      }
    if (TLS(UserHasQUIT))
      {
        Pr("Warning: Entering READ with UserHasQUIT set, this should never happen, resetting",0,0);
        TLS(UserHasQUIT) = 0;
      }
    MakeReadWriteGVar(LastReadValueGVar);
    AssGVar( LastReadValueGVar, 0);
    MakeReadOnlyGVar(LastReadValueGVar);
    /* now do the reading                                                  */
    while ( 1 ) {
        ClearError();
        status = ReadEvalCommand(TLS(BottomLVars), 0);
	if (TLS(UserHasQuit) || TLS(UserHasQUIT))
	  break;
        /* handle return-value or return-void command                      */
        if ( status & (STATUS_RETURN_VAL | STATUS_RETURN_VOID) ) {
            Pr(
                "'return' must not be used in file read-eval loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( status  & (STATUS_ERROR | STATUS_EOF)) 
          break;
        else if (status == STATUS_QUIT) {
          TLS(RecursionDepth) = 0;
          TLS(UserHasQuit) = 1;
          break;
        }
        else if (status == STATUS_QQUIT) {
          TLS(UserHasQUIT) = 1;
          break;
        }
        if (TLS(ReadEvalResult))
          {
            MakeReadWriteGVar(LastReadValueGVar);
            AssGVar( LastReadValueGVar, TLS(ReadEvalResult));
            MakeReadOnlyGVar(LastReadValueGVar);
          }
        
    }


    /* close the input file again, and return 'true'                       */
    if ( ! CloseInput() ) {
        ErrorQuit(
            "Panic: READ cannot close input, this should not happen",
            0L, 0L );
    }
    ClearError();

    if (!UseUHQ && TLS(UserHasQuit)) {
      TLS(UserHasQuit) = 0; /* stop recovery here */
      return 2;
    }

    return 1;
}


static Int READ( void ) {
  return READ_INNER(1);
}

static Int READ_NORECOVERY( void ) {
  return READ_INNER(0);
}

/****************************************************************************
**
*F  READ_AS_FUNC()  . . . . . . . . . . . . .  read current input as function
**
**  Read the current input as function and close the input stream.
*/
Obj READ_AS_FUNC ( void )
{
    Obj                 func;
    UInt                type;

    /* now do the reading                                                  */
    ClearError();
    type = ReadEvalFile();

    /* get the function                                                    */
    if ( type == 0 ) {
        func = TLS(ReadEvalResult);
    }
    else {
        func = Fail;
    }

    /* close the input file again, and return 'true'                       */
    if ( ! CloseInput() ) {
        ErrorQuit(
            "Panic: READ_AS_FUNC cannot close input, this should not happen",
            0L, 0L );
    }
    ClearError();

    /* return the function                                                 */
    return func;
}


static void READ_TEST_OR_LOOP(void)
{
    UInt                type;
    UInt                oldtime;
    UInt                dualSemicolon;

    /* get the starting time                                               */
    oldtime = SyTime();

    /* now do the reading                                                  */
    while ( 1 ) {

        /* read and evaluate the command                                   */
        ClearError();
        type = ReadEvalCommand(TLS(BottomLVars), &dualSemicolon);

        /* stop the stopwatch                                              */
        AssGVar( Time, INTOBJ_INT( SyTime() - oldtime ) );

        /* handle ordinary command                                         */
        if ( type == 0 && TLS(ReadEvalResult) != 0 ) {

            /* remember the value in 'last' and the time in 'time'         */
            AssGVar( Last3, VAL_GVAR( Last2 ) );
            AssGVar( Last2, VAL_GVAR( Last  ) );
            AssGVar( Last,  TLS(ReadEvalResult)   );

            /* print the result                                            */
            if ( ! dualSemicolon ) {
                Bag currLVars = TLS(CurrLVars); /* in case view runs into error */
                ViewObjHandler( TLS(ReadEvalResult) );
                SWITCH_TO_OLD_LVARS(currLVars);
            }
        }

        /* handle return-value or return-void command                      */
        else if ( type & (STATUS_RETURN_VAL | STATUS_RETURN_VOID) ) {
            Pr( "'return' must not be used in file read-eval loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( type & (STATUS_QUIT | STATUS_EOF) ) {
            break;
        }
        // FIXME: what about other types? e.g. STATUS_ERROR and STATUS_QQUIT

    }
}


/****************************************************************************
**
*F  READ_LOOP() . . . . . . . . . .  read current input as read-eval-view loop
**
**  Read the current input as read-eval-view loop and close the input stream.
*/
static void READ_LOOP ( void )
{
    READ_TEST_OR_LOOP();

    /* close the input file again, and return 'true'                       */
    if ( ! CloseInput() ) {
        ErrorQuit(
            "Panic: ReadLoop cannot close input, this should not happen",
            0L, 0L );
    }
    ClearError();
}


/****************************************************************************
**
*F  READ_GAP_ROOT( <filename> ) . . .  read from gap root, dyn-load or static
**
**  'READ_GAP_ROOT' tries to find  a file under  the root directory,  it will
**  search all   directories given   in 'SyGapRootPaths',  check  dynamically
**  loadable modules and statically linked modules.
*/


Int READ_GAP_ROOT ( Char * filename )
{
    TypGRF_Data         result;
    Int                 res;
    UInt                type;
    StructInitInfo *    info;

    /* try to find the file                                                */
    res = SyFindOrLinkGapRootFile( filename, 0L, &result );

    /* not found                                                           */
    if ( res == 0 ) {
        return 0;
    }

    /* dynamically linked                                                  */
    else if ( res == 1 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' dynamically\n",
                (Int)filename, 0L );
        }
        info = result.module_info;
        res  = info->initKernel(info);
        if (!SyRestoring) {
          UpdateCopyFopyInfo();
          res  = res || info->initLibrary(info);
        }
        if ( res ) {
            Pr( "#W  init functions returned non-zero exit code\n", 0L, 0L );
        }
        
        info->isGapRootRelative = 1;
        RecordLoadedModule(info, filename);
        return 1;
    }

    /* statically linked                                                   */
    else if ( res == 2 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' statically\n",
                (Int)filename, 0L );
        }
        info = result.module_info;
        res  = info->initKernel(info);
        if (!SyRestoring) {
          UpdateCopyFopyInfo();
          res  = res || info->initLibrary(info);
        }
        if ( res ) {
            Pr( "#W  init functions returned non-zero exit code\n", 0L, 0L );
        }
        info->isGapRootRelative = 1;
        RecordLoadedModule(info, filename);
        return 1;
    }

    /* special handling for the other cases, if we are trying to load compiled
       modules needed for a saved workspace ErrorQuit is not available */
    else if (SyRestoring)
      {
        if (res == 3 || res == 4)
          {
            Pr("Can't find compiled module '%s' needed by saved workspace\n",
               (Int) filename, 0L);
            return 0;
          }
        else
          Pr("unknown result code %d from 'SyFindGapRoot'", res, 0L );
        SyExit(1);
      }
    
    /* ordinary gap file                                                   */
    else if ( res == 3 || res == 4  ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' as GAP file\n",
                (Int)filename, 0L );
        }
        if ( OpenInput(result.pathname) ) {
          SySetBuffering(TLS(Input)->file);
            while ( 1 ) {
                ClearError();
                type = ReadEvalCommand(TLS(BottomLVars), 0);
                if (TLS(UserHasQuit) || TLS(UserHasQUIT))
                  break;
                if ( type & (STATUS_RETURN_VAL | STATUS_RETURN_VOID) ) {
                    Pr( "'return' must not be used in file", 0L, 0L );
                }
                else if ( type & (STATUS_QUIT | STATUS_EOF) ) {
                    break;
                }
            }
            CloseInput();
            ClearError();
            return 1;
        }
        else {
            return 0;
        }
    }

    /* don't know                                                          */
    else {
        ErrorQuit( "unknown result code %d from 'SyFindGapRoot'", res, 0L );
        return 0;
    }
    return 0;
}


/****************************************************************************
**

*F  FuncCLOSE_LOG_TO()  . . . . . . . . . . . . . . . . . . . .  stop logging
**
**  'FuncCLOSE_LOG_TO' implements a method for 'LogTo'.
**
**  'LogTo()'
**
**  'LogTo' called with no argument closes the current logfile again, so that
**  input   from  '*stdin*'  and  '*errin*'  and  output  to  '*stdout*'  and
**  '*errout*' will no longer be echoed to a file.
*/
Obj FuncCLOSE_LOG_TO (
    Obj                 self )
{
    if ( ! CloseLog() ) {
        ErrorQuit("LogTo: can not close the logfile",0L,0L);
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncLOG_TO( <filename> ) . . . . . . . . . . . .  start logging to a file
**
**  'FuncLOG_TO' implements a method for 'LogTo'
**
**  'LogTo( <filename> )'
**
**  'LogTo' instructs GAP to echo all input from the  standard  input  files,
**  '*stdin*' and '*errin*' and all output  to  the  standard  output  files,
**  '*stdout*'  and  '*errout*',  to  the  file  with  the  name  <filename>.
**  The file is created if it does not  exist,  otherwise  it  is  truncated.
*/
Obj FuncLOG_TO (
    Obj                 self,
    Obj                 filename )
{
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "LogTo: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    if ( ! OpenLog( CSTR_STRING(filename) ) ) {
        ErrorReturnVoid( "LogTo: cannot log to %s",
                         (Int)CSTR_STRING(filename), 0L,
                         "you can 'return;'" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncLOG_TO_STREAM( <stream> ) . . . . . . . . . start logging to a stream
*/
Obj FuncLOG_TO_STREAM (
    Obj                 self,
    Obj                 stream )
{
    if ( ! OpenLogStream(stream) ) {
        ErrorReturnVoid( "LogTo: cannot log to stream", 0L, 0L,
                         "you can 'return;'" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncCLOSE_INPUT_LOG_TO()  . . . . . . . . . . . . . . . . .  stop logging
**
**  'FuncCLOSE_INPUT_LOG_TO' implements a method for 'InputLogTo'.
**
**  'InputLogTo()'
**
**  'InputLogTo' called with no argument closes the current logfile again, so
**  that input from  '*stdin*' and '*errin*' will   no longer be  echoed to a
**  file.
*/
Obj FuncCLOSE_INPUT_LOG_TO (
    Obj                 self )
{
    if ( ! CloseInputLog() ) {
        ErrorQuit("InputLogTo: can not close the logfile",0L,0L);
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncINPUT_LOG_TO( <filename> )  . . . . . . . . . start logging to a file
**
**  'FuncINPUT_LOG_TO' implements a method for 'InputLogTo'
**
**  'InputLogTo( <filename> )'
**
**  'InputLogTo'  instructs  GAP to echo   all input from  the standard input
**  files, '*stdin*' and '*errin*' to the file with the name <filename>.  The
**  file is created if it does not exist, otherwise it is truncated.
*/
Obj FuncINPUT_LOG_TO (
    Obj                 self,
    Obj                 filename )
{
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "InputLogTo: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    if ( ! OpenInputLog( CSTR_STRING(filename) ) ) {
        ErrorReturnVoid( "InputLogTo: cannot log to %s",
                         (Int)CSTR_STRING(filename), 0L,
                         "you can 'return;'" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncINPUT_LOG_TO_STREAM( <stream> ) . . . . . . start logging to a stream
*/
Obj FuncINPUT_LOG_TO_STREAM (
    Obj                 self,
    Obj                 stream )
{
    if ( ! OpenInputLogStream(stream) ) {
        ErrorReturnVoid( "InputLogTo: cannot log to stream", 0L, 0L,
                         "you can 'return;'" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncCLOSE_OUTPUT_LOG_TO()  . . . . . . . . . . . . . . . . . stop logging
**
**  'FuncCLOSE_OUTPUT_LOG_TO' implements a method for 'OutputLogTo'.
**
**  'OutputLogTo()'
**
**  'OutputLogTo'  called with no argument  closes the current logfile again,
**  so that output from '*stdin*' and '*errin*' will no longer be echoed to a
**  file.
*/
Obj FuncCLOSE_OUTPUT_LOG_TO (
    Obj                 self )
{
    if ( ! CloseOutputLog() ) {
        ErrorQuit("OutputLogTo: can not close the logfile",0L,0L);
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncOUTPUT_LOG_TO( <filename> )  . . . . . . . .  start logging to a file
**
**  'FuncOUTPUT_LOG_TO' implements a method for 'OutputLogTo'
**
**  'OutputLogTo( <filename> )'
**
**  'OutputLogTo' instructs GAP  to echo all  output from the standard output
**  files, '*stdin*' and '*errin*' to the file with the name <filename>.  The
**  file is created if it does not exist, otherwise it is truncated.
*/
Obj FuncOUTPUT_LOG_TO (
    Obj                 self,
    Obj                 filename )
{
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "OutputLogTo: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    if ( ! OpenOutputLog( CSTR_STRING(filename) ) ) {
        ErrorReturnVoid( "OutputLogTo: cannot log to %s",
                         (Int)CSTR_STRING(filename), 0L,
                         "you can 'return;'" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncOUTPUT_LOG_TO_STREAM( <stream> ) . . . . .  start logging to a stream
*/
Obj FuncOUTPUT_LOG_TO_STREAM (
    Obj                 self,
    Obj                 stream )
{
    if ( ! OpenOutputLogStream(stream) ) {
        ErrorReturnVoid( "OutputLogTo: cannot log to stream", 0L, 0L,
                         "you can 'return;'" );
        return False;
    }
    return True;
}


/****************************************************************************
**
*F  FuncPrint( <self>, <args> ) . . . . . . . . . . . . . . . .  print <args>
*/
Obj FuncPrint (
    Obj                 self,
    Obj                 args )
{
    volatile Obj        arg;
    volatile UInt       i;
    syJmp_buf           readJmpError;

    /* print all the arguments, take care of strings and functions         */
    for ( i = 1;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);
        if ( IS_PLIST(arg) && 0 < LEN_PLIST(arg) && IsStringConv(arg) ) {
            PrintString1(arg);
        }
        else if ( IS_STRING_REP(arg) ) {
            PrintString1(arg);
        }
        else if ( TNUM_OBJ( arg ) == T_FUNCTION ) {
            PrintFunction( arg );
        }
        else {
            memcpy( readJmpError, TLS(ReadJmpError), sizeof(syJmp_buf) );

            /* if an error occurs stop printing                            */
            if ( ! READ_ERROR() ) {
                PrintObj( arg );
            }
            else {
                memcpy( TLS(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
                ReadEvalError();
            }
            memcpy( TLS(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
        }
    }

    return 0;
}

static Obj PRINT_OR_APPEND_TO(Obj args, int append)
{
    const char          *funcname = append ? "AppendTo" : "PrintTo";
    volatile Obj        arg;
    volatile Obj        filename;
    volatile UInt       i;
    syJmp_buf           readJmpError;

    /* first entry is the filename                                         */
    filename = ELM_LIST(args,1);
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "%s: <filename> must be a string (not a %s)",
            (Int)funcname, (Int)TNAM_OBJ(filename),
            "you can replace <filename> via 'return <filename>;'" );
    }

    /* try to open the file for output                                     */
    i = append ? OpenAppend( CSTR_STRING(filename) )
               : OpenOutput( CSTR_STRING(filename) );
    if ( ! i ) {
        ErrorQuit( "%s: cannot open '%s' for output",
                   (Int)funcname, (Int)CSTR_STRING(filename) );
        return 0;
    }

    /* print all the arguments, take care of strings and functions         */
    for ( i = 2;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);
        if ( IS_PLIST(arg) && 0 < LEN_PLIST(arg) && IsStringConv(arg) ) {
            PrintString1(arg);
        }
        else if ( IS_STRING_REP(arg) ) {
            PrintString1(arg);
        }
        else if ( TNUM_OBJ(arg) == T_FUNCTION ) {
            TLS(PrintObjFull) = 1;
            PrintFunction( arg );
            TLS(PrintObjFull) = 0;
        }
        else {
            memcpy( readJmpError, TLS(ReadJmpError), sizeof(syJmp_buf) );

            /* if an error occurs stop printing                            */
            if ( ! READ_ERROR() ) {
                PrintObj( arg );
            }
            else {
                CloseOutput();
                memcpy( TLS(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
                ReadEvalError();
            }
            memcpy( TLS(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
        }
    }

    /* close the output file again, and return nothing                     */
    if ( ! CloseOutput() ) {
        ErrorQuit( "%s: cannot close output", (Int)funcname, 0L );
        return 0;
    }

    return 0;
}


static Obj PRINT_OR_APPEND_TO_STREAM(Obj args, int append)
{
    const char          *funcname = append ? "AppendTo" : "PrintTo";
    volatile Obj        arg;
    volatile Obj        stream;
    volatile UInt       i;
    syJmp_buf           readJmpError;

    /* first entry is the stream                                           */
    stream = ELM_LIST(args,1);

    /* try to open the file for output                                     */
    i = append ? OpenAppendStream(stream)
               : OpenOutputStream(stream);
    if ( ! i ) {
        ErrorQuit( "%s: cannot open stream for output", (Int)funcname, 0L );
        return 0;
    }

    /* print all the arguments, take care of strings and functions         */
    for ( i = 2;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);

        /* if an error occurs stop printing                                */
        memcpy( readJmpError, TLS(ReadJmpError), sizeof(syJmp_buf) );
        if ( ! READ_ERROR() ) {
            if ( IS_PLIST(arg) && 0 < LEN_PLIST(arg) && IsStringConv(arg) ) {
                PrintString1(arg);
            }
            else if ( IS_STRING_REP(arg) ) {
                PrintString1(arg);
            }
            else if ( TNUM_OBJ( arg ) == T_FUNCTION ) {
                TLS(PrintObjFull) = 1;
                PrintFunction( arg );
                TLS(PrintObjFull) = 0;
            }
            else {
                PrintObj( arg );
            }
        }
        else {
            CloseOutput();
            memcpy( TLS(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
            ReadEvalError();
        }
        memcpy( TLS(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
    }

    /* close the output file again, and return nothing                     */
    if ( ! CloseOutput() ) {
        ErrorQuit( "%s: cannot close output", (Int)funcname, 0L );
        return 0;
    }

    return 0;
}

/****************************************************************************
**
*F  FuncPRINT_TO( <self>, <args> )  . . . . . . . . . . . . . .  print <args>
*/
Obj FuncPRINT_TO (
    Obj                 self,
    Obj                 args )
{
    return PRINT_OR_APPEND_TO(args, 0);
}


/****************************************************************************
**
*F  FuncPRINT_TO_STREAM( <self>, <args> ) . . . . . . . . . . .  print <args>
*/
Obj FuncPRINT_TO_STREAM (
    Obj                 self,
    Obj                 args )
{
    return PRINT_OR_APPEND_TO_STREAM(args, 0);
}


/****************************************************************************
**
*F  FuncAPPEND_TO( <self>, <args> ) . . . . . . . . . . . . . . append <args>
*/
Obj FuncAPPEND_TO (
    Obj                 self,
    Obj                 args )
{
    return PRINT_OR_APPEND_TO(args, 1);
}


/****************************************************************************
**
*F  FuncAPPEND_TO_STREAM( <self>, <args> )  . . . . . . . . . . append <args>
*/
Obj FuncAPPEND_TO_STREAM (
    Obj                 self,
    Obj                 args )
{
    return PRINT_OR_APPEND_TO_STREAM(args, 1);
}

Obj FuncSET_OUTPUT (
    Obj                 self,
    Obj                 file,
    Obj                 append    )
{
    
    if ( IsStringConv(file) ) {
        if ( append != False ) {
          if ( ! OpenAppend( CSTR_STRING(file) ) ) {
             ErrorQuit( "SET_OUTPUT: cannot open '%s' for appending",
                                  (Int)CSTR_STRING(file), 0L );
          } else {
             return 0;
          }
        } else {
          if ( ! OpenOutput( CSTR_STRING(file) ) ) {
             ErrorQuit( "SET_OUTPUT: cannot open '%s' for output",
                                  (Int)CSTR_STRING(file), 0L );
          } else {
            return 0;
          }
        }
    } else {  /* an open stream */
        if ( append != False ) {
          if ( ! OpenAppendStream( file ) ) {
             ErrorQuit( "SET_OUTPUT: cannot open stream for appending", 0L, 0L );
          } else {
             return 0;
          }
        } else {
          if ( ! OpenOutputStream( file ) ) {
             ErrorQuit( "SET_OUTPUT: cannot open stream for output", 0L, 0L );
          } else {
            return 0;
          }
        }
    }
    return 0;
}

Obj FuncSET_PREVIOUS_OUTPUT( Obj self ) {
    /* close the current output stream, and return nothing  */

    if ( ! CloseOutput() ) {
        ErrorQuit( "SET_PREVIOUS_OUTPUT: cannot close output", 0L, 0L );
        return 0;
    }
    return 0;
}
     
/****************************************************************************
**
*F  FuncREAD( <self>, <filename> )  . . . . . . . . . . . . . . . read a file
**
**  Read the current input and close the input stream.
*/
Obj FuncREAD (
    Obj                 self,
    Obj                 filename )
{
   /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        return False;
    }

    SySetBuffering(TLS(Input)->file);
   
    /* read the test file                                                  */
    return READ() ? True : False;
}

/****************************************************************************
**
*F  FuncREAD_NORECOVERY( <self>, <filename> )  . . .  . . . . . . read a file
**
** Read the current input and close the input stream. Disable the normal 
** mechanism which ensures that quitting from a break loop gets you back to a 
** live prompt. This is initially designed for the files read from the command 
** line
*/
Obj FuncREAD_NORECOVERY (
    Obj                 self,
    Obj                 filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        return False;
    }

    SySetBuffering(TLS(Input)->file);
   
    /* read the file */
    switch (READ_NORECOVERY()) {
    case 0: return False;
    case 1: return True;
    case 2: return Fail;
    default: return Fail;
    }
}


/****************************************************************************
**
*F  FuncREAD_STREAM( <self>, <stream> )   . . . . . . . . . . . read a stream
*/
Obj FuncREAD_STREAM (
    Obj                 self,
    Obj                 stream )
{
    /* try to open the file                                                */
    if ( ! OpenInputStream(stream) ) {
        return False;
    }

    /* read the test file                                                  */
    return READ() ? True : False;
}

/****************************************************************************
**
*F  FuncREAD_STREAM_LOOP( <self>, <stream>, <catcherrstdout> ) . read a stream
*/
Obj FuncREAD_STREAM_LOOP (
    Obj                 self,
    Obj                 stream,
    Obj                 catcherrstdout )
{
    /* try to open the file                                                */
    if ( ! OpenInputStream(stream) ) {
        return False;
    }
    if ( catcherrstdout == True )
      TLS(IgnoreStdoutErrout) = TLS(Output);
    else
      TLS(IgnoreStdoutErrout) = NULL;


    /* read the test file                                                  */
    READ_LOOP();
    TLS(IgnoreStdoutErrout) = NULL;
    return True;
}


/****************************************************************************
**
*F  FuncREAD_AS_FUNC( <self>, <filename> )  . . . . . . . . . . . read a file
*/
Obj FuncREAD_AS_FUNC (
    Obj                 self,
    Obj                 filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ_AS_FUNC: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        return Fail;
    }

    SySetBuffering(TLS(Input)->file);
    
    /* read the function                                                   */
    return READ_AS_FUNC();
}


/****************************************************************************
**
*F  FuncREAD_AS_FUNC_STREAM( <self>, <filename> ) . . . . . . . . read a file
*/
Obj FuncREAD_AS_FUNC_STREAM (
    Obj                 self,
    Obj                 stream )
{
    /* try to open the file                                                */
    if ( ! OpenInputStream(stream) ) {
        return Fail;
    }

    /* read the function                                                   */
    return READ_AS_FUNC();
}


/****************************************************************************
**
*F  FuncREAD_GAP_ROOT( <self>, <filename> ) . . . . . . . . . . . read a file
*/
Obj FuncREAD_GAP_ROOT (
    Obj                 self,
    Obj                 filename )
{
    Char filenamecpy[4096];

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }

    /* Copy to avoid garbage collection moving string                      */
    strlcpy(filenamecpy, CSTR_STRING(filename), 4096);
    /* try to open the file                                                */
    return READ_GAP_ROOT(filenamecpy) ? True : False;
}


/****************************************************************************
**

*F  FuncTmpName( <self> ) . . . . . . . . . . . . . . return a temporary name
*/
Obj FuncTmpName (
    Obj                 self )
{
    Char *              tmp;
    Obj                 name;

    tmp = SyTmpname();
    if ( tmp == 0 )
        return Fail;
    C_NEW_STRING_DYN( name, tmp );
    return name;
}


/****************************************************************************
**
*F  FuncTmpDirectory( <self> )  . . . . . . . .  return a temporary directory
*/
Obj FuncTmpDirectory (
    Obj                 self )
{
    Char *              tmp;
    Obj                 name;

    tmp = SyTmpdir("tm");
    if ( tmp == 0 )
        return Fail;
    C_NEW_STRING_DYN( name, tmp );
    return name;
}


/****************************************************************************
**
*F  FuncRemoveFile( <self>, <name> )  . . . . . . . . . .  remove file <name>
*/
Obj FuncRemoveFile (
    Obj             self,
    Obj             filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    return SyRemoveFile( CSTR_STRING(filename) ) == -1 ? Fail : True;
}

/****************************************************************************
**
*F  FuncCreateDir( <self>, <name> )  . . . . . . . . . . . . create directory
*/
Obj FuncCreateDir (
    Obj             self,
    Obj             filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    return SyMkdir( CSTR_STRING(filename) ) == -1 ? Fail : True;
}

/****************************************************************************
**
*F  FuncRemoveDir( <self>, <name> )  . . . . . . . . . . . . remove directory
*/
Obj FuncRemoveDir (
    Obj             self,
    Obj             filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    return SyRmdir( CSTR_STRING(filename) ) == -1 ? Fail : True;
}

/****************************************************************************
**
*F  FuncIsDir( <self>, <name> )  . . . . . check whether something is a dir
*/
Obj FuncIsDir (
    Obj             self,
    Obj             filename )
{
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }

    /* call the system dependent function                                  */
    return SyIsDir( CSTR_STRING(filename) );
}




/****************************************************************************
**

*F * * * * * * * * * * * file access test functions * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FuncLastSystemError( <self> ) .  . . . . . .  return the last system error
*/
UInt ErrorMessageRNam;
UInt ErrorNumberRNam;

Obj FuncLastSystemError (
    Obj             self )
{
    Obj             err;
    Obj             msg;

    /* constructed an error record                                         */
    err = NEW_PREC(0);

    /* check if an errors has occured                                      */
    if ( SyLastErrorNo != 0 ) {
        ASS_REC( err, ErrorNumberRNam, INTOBJ_INT(SyLastErrorNo) );
        C_NEW_STRING_DYN(msg, SyLastErrorMessage);
        ASS_REC( err, ErrorMessageRNam, msg );
    }

    /* no error has occured                                                */
    else {
        ASS_REC( err, ErrorNumberRNam, INTOBJ_INT(0) );
        C_NEW_STRING_CONST( msg, "no error" );
        ASS_REC( err, ErrorMessageRNam, msg );
    }

    /* return the error record                                             */
    return err;
}


/****************************************************************************
**
*F  FuncIsExistingFile( <self>, <name> )  . . . . . . does file <name> exists
*/
Obj FuncIsExistingFile (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsExistingFile( CSTR_STRING(filename) );
    return res == -1 ? False : True;
}


/****************************************************************************
**
*F  FuncIsReadableFile( <self>, <name> )  . . . . . . is file <name> readable
*/
Obj FuncIsReadableFile (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsReadableFile( CSTR_STRING(filename) );
    return res == -1 ? False : True;
}


/****************************************************************************
**
*F  FuncIsWritableFile( <self>, <name> )  . . . . . . is file <name> writable
*/
Obj FuncIsWritableFile (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsWritableFile( CSTR_STRING(filename) );
    return res == -1 ? False : True;
}


/****************************************************************************
**
*F  FuncIsExecutableFile( <self>, <name> )  . . . . is file <name> executable
*/
Obj FuncIsExecutableFile (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsExecutableFile( CSTR_STRING(filename) );
    return res == -1 ? False : True;
}


/****************************************************************************
**
*F  FuncIsDirectoryPath( <self>, <name> ) . . . .  is file <name> a directory
*/
Obj FuncIsDirectoryPathString (
    Obj             self,
    Obj             filename )
{
    Int             res;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    res = SyIsDirectoryPath( CSTR_STRING(filename) );
    switch(res) {
    case 0:
        return True;
        break;
    case -1:
        return False;
        break;
    default:
        return Fail;
    }
}


/****************************************************************************
**
*F  FuncSTRING_LIST_DIR( <self>, <dirname> ) . . . read names of files in dir
**
**  This function returns a GAP string which contains the names of all files
**  contained in a directory <dirname>. The file names are separated by zero 
**  characters (which are not allowed in file names). 
**
**  If <dirname> could not be opened as a directory 'fail' is returned. The
**  reason for the error can be found with 'LastSystemError();' in GAP.
**
*/
Obj FuncSTRING_LIST_DIR (
    Obj         self,
    Obj         dirname  )
{
    DIR *dir;
    struct dirent *entry;
    Obj res;
    Int len, sl;

    /* check the argument                                                  */
    while ( ! IsStringConv( dirname ) ) {
        dirname = ErrorReturnObj(
            "<dirname> must be a string (not a %s)",
            (Int)TNAM_OBJ(dirname), 0L,
            "you can replace <dirname> via 'return <dirname>;'" );
    }
    
    SyClearErrorNo();
    dir = opendir(CSTR_STRING(dirname));
    if (dir == NULL) {
      SySetErrorNo();
      return Fail;
    }
    res = NEW_STRING(256);
    len = 0;
    entry = readdir(dir);
    while (entry != NULL) {
      sl = strlen(entry->d_name);
      GROW_STRING(res, len + sl + 1);
      memcpy(CHARS_STRING(res) + len, entry->d_name, sl + 1);
      len = len + sl + 1;
      entry = readdir(dir);
    }
    closedir(dir);
    /* tell the result string its length and terminate by 0 char */
    SET_LEN_STRING(res, len);
    *(CHARS_STRING(res) + len) = 0;
    return res;
}

/****************************************************************************
**

*F * * * * * * * * * * * * text stream functions  * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  FuncCLOSE_FILE( <self>, <fid> ) . . . . . . . . . . . . .  close a stream
*/
Obj FuncCLOSE_FILE (
    Obj             self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    
    /* call the system dependent function                                  */
    ret = SyFclose( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : True;
}


/****************************************************************************
**
*F  FuncINPUT_TEXT_FILE( <self>, <name> ) . . . . . . . . . . . open a stream
*/
Obj FuncINPUT_TEXT_FILE (
    Obj             self,
    Obj             filename )
{
    Int             fid;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    /* call the system dependent function                                  */
    SyClearErrorNo();
    fid = SyFopen( CSTR_STRING(filename), "r" );
    if ( fid == - 1)
        SySetErrorNo();
    return fid == -1 ? Fail : INTOBJ_INT(fid);
}


/****************************************************************************
**
*F  FuncIS_END_OF_FILE( <self>, <fid> ) . . . . . . . . . . .  is end of file
*/
Obj FuncIS_END_OF_FILE (
    Obj             self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    
    ret = SyIsEndOfFile( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : ( ret == 0 ? False : True );
}


/****************************************************************************
**
*F  FuncOUTPUT_TEXT_FILE( <self>, <name>, <append> )  . . . . . open a stream
*/
Obj FuncOUTPUT_TEXT_FILE (
    Obj             self,
    Obj             filename,
    Obj             append )
{
    Int             fid;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    while ( append != True && append != False ) {
        filename = ErrorReturnObj(
            "<append> must be a boolean (not a %s)",
            (Int)TNAM_OBJ(append), 0L,
            "you can replace <append> via 'return <append>;'" );
    }
    
    /* call the system dependent function                                  */
    SyClearErrorNo();
    if ( append == True ) {
        fid = SyFopen( CSTR_STRING(filename), "a" );
    }
    else {
        fid = SyFopen( CSTR_STRING(filename), "w" );
    }
    if ( fid == - 1)
        SySetErrorNo();
    return fid == -1 ? Fail : INTOBJ_INT(fid);
}


/****************************************************************************
**
*F  FuncPOSITION_FILE( <self>, <fid> )  . . . . . . . . .  position of stream
*/
Obj FuncPOSITION_FILE (
    Obj             self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    
    ret = SyFtell( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : INTOBJ_INT(ret);
}



/****************************************************************************
**
*F  FuncREAD_BYTE_FILE( <self>, <fid> ) . . . . . . . . . . . . . read a byte
*/
Obj FuncREAD_BYTE_FILE (
    Obj             self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    
    /* call the system dependent function                                  */
    ret = SyGetch( INT_INTOBJ(fid) );

    return ret == EOF ? Fail : INTOBJ_INT(ret);
}


/****************************************************************************
**
*F  FuncREAD_LINE_FILE( <self>, <fid> ) . . . . . . . . . . . . . read a line
**  
**  This uses fgets and works only if there are no zero characters in <fid>.
*/

/*  this would be a proper function but it reads single chars and is slower

Now SyFputs uses read byte-by-byte, so probably OK

Obj FuncREAD_LINE_FILE (
    Obj             self,
    Obj             fid )
{
    Int             fidc, len, i;
    Obj             str;
    UInt1           *p;
    Int              c;

    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    
    str = NEW_STRING(10);
    len = 10;
    i = 0;
    fidc = INT_INTOBJ(fid);
    p = CHARS_STRING(str); 
    while (1) {
      c = SyGetc(fidc);
      if (i == len) {
        len = GrowString(str, len+1);
        p = CHARS_STRING(str);
      }
      if (c == '\n') {
        p[i++] = (UInt1)c;
        break;
      }
      else if (c == EOF) 
        break;
      else {
        p[i++] = (UInt1)c;
      }
    }
    ResizeBag( str, SIZEBAG_STRINGLEN(i) );
    SET_LEN_STRING(str, i);
      
    return i == 0 ? Fail : str;
}
*/
Obj FuncREAD_LINE_FILE (
    Obj             self,
    Obj             fid )
{
    Char            buf[256];
    Char *          cstr;
    Int             ifid, len, buflen;
    UInt            lstr;
    Obj             str;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    ifid = INT_INTOBJ(fid);

    /* read <fid> until we see a newline or eof or we've read at least
       one byte and more are not immediately available */
    str = NEW_STRING(0);
    len = 0;
    while (1) {
      if ( len > 0 && !HasAvailableBytes(ifid))
        break;
      len += 255;
      GROW_STRING( str, len );
      if ( SyFgetsSemiBlock( buf, 256, ifid ) == 0 )
        break;
      buflen = strlen(buf);
      lstr = GET_LEN_STRING(str);
      cstr = CSTR_STRING(str) + lstr;
      memcpy( cstr, buf, buflen+1 );
      SET_LEN_STRING(str, lstr+buflen);
      if ( buf[buflen-1] == '\n' )
        break;
    }

    /* fix the length of <str>                                             */
    len = GET_LEN_STRING(str);
    ResizeBag( str, SIZEBAG_STRINGLEN(len) );

    /* and return                                                          */
    return len == 0 ? Fail : str;
}

/****************************************************************************
**
*F  FuncREAD_ALL_FILE( <self>, <fid>, <limit> )  . . . . . . . read remainder
**  
** more precisely, read until either
**   (a) we have read at least one byte and no more are available
**   (b) we have evidence that it will never be possible to read a byte
**   (c) we have read <limit> bytes (-1 indicates no limit)
*/

Obj FuncREAD_ALL_FILE (
    Obj             self,
    Obj             fid,
    Obj             limit)
{
    Char            buf[20000];
    Int             ifid, len;
    UInt            lstr;
    Obj             str;
    Int             ilim;
    UInt            csize;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    ifid = INT_INTOBJ(fid);

    while ( ! IS_INTOBJ(limit) ) {
      limit = ErrorReturnObj(
			     "<limit> must be a small integer (not a %s)",
			     (Int)TNAM_OBJ(limit), 0L,
			     "you can replace limit via 'return <limit>;'" );
    }
    ilim = INT_INTOBJ(limit);

    /* read <fid> until we see  eof or we've read at least
       one byte and more are not immediately available */
    str = NEW_STRING(0);
    len = 0;
    lstr = 0;


    if (syBuf[ifid].bufno >= 0)
      {
	UInt bufno = syBuf[ifid].bufno;

	/* first drain the buffer */
	lstr = syBuffers[bufno].buflen - syBuffers[bufno].bufstart;
	if (ilim != -1)
	  {
	    if (lstr > ilim)
	      lstr = ilim;
	    ilim -= lstr;
	  }
	GROW_STRING(str, lstr);
	memcpy(CHARS_STRING(str), syBuffers[bufno].buf + syBuffers[bufno].bufstart, lstr);
	len = lstr;
	SET_LEN_STRING(str, len);
	syBuffers[bufno].bufstart += lstr;
      }
#if SYS_IS_CYGWIN32
 getmore:
#endif
    while (ilim == -1 || len < ilim ) {
      if ( len > 0 && !HasAvailableBytes(ifid))
	break;
      if (syBuf[ifid].isTTY)
	{
	  if (ilim == -1)
	    {
	      Pr("#W Warning -- reading to  end of input tty will never end\n",0,0);
	      csize = 20000;
	    }
	  else
	      csize = ((ilim- len) > 20000) ? 20000 : ilim - len;
	    
	  if (SyFgetsSemiBlock(buf, csize, ifid))
	    lstr = strlen(buf);
	  else  
	    lstr = 0;
	}
      else
	{
	  do {
	    csize = (ilim == -1 || (ilim- len) > 20000) ? 20000 : ilim - len;
	    lstr = read(syBuf[ifid].fp, buf, csize);
	  } while (lstr == -1 && errno == EAGAIN);
	}
      if (lstr <= 0)
	{
	  syBuf[ifid].ateof = 1;
	  break;
	}
      GROW_STRING( str, len+lstr );
      memcpy(CHARS_STRING(str)+len, buf, lstr);
      len += lstr;
      SET_LEN_STRING(str, len);
    }

    /* fix the length of <str>                                             */
    len = GET_LEN_STRING(str);
#if SYS_IS_CYGWIN32
    /* line end hackery */
    {
      UInt i = 0,j = 0;
      while ( i < len )
	{
	  if (CHARS_STRING(str)[i] == '\r')
	    {
	      if (i < len -1 && CHARS_STRING(str)[i+1] == '\n')
		{
		  i++;
		  continue;
		}
	      else
		CHARS_STRING(str)[i] = '\n';
	    }
	  CHARS_STRING(str)[j++] = CHARS_STRING(str)[i++];
	}
      len = j;
      SET_LEN_STRING(str, len);
      if (ilim != -1 && len < ilim)
	goto getmore;
      
    }
#endif
    ResizeBag( str, SIZEBAG_STRINGLEN(len) );

    /* and return                                                          */
    return len == 0 ? Fail : str;
}

/****************************************************************************
**
*F  FuncSEEK_POSITION_FILE( <self>, <fid>, <pos> )  . seek position of stream
*/
Obj FuncSEEK_POSITION_FILE (
    Obj             self,
    Obj             fid,
    Obj             pos )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    while ( ! IS_INTOBJ(pos) ) {
        pos = ErrorReturnObj(
            "<pos> must be an integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0L,
            "you can replace <pos> via 'return <pos>;'" );
    }
    
    if (syBuf[INT_INTOBJ(fid)].bufno >= 0)
    {
            syBuffers[syBuf[INT_INTOBJ(fid)].bufno].buflen = 0;
            syBuffers[syBuf[INT_INTOBJ(fid)].bufno].bufstart = 0;
    }
    ret = SyFseek( INT_INTOBJ(fid), INT_INTOBJ(pos) );
    return ret == -1 ? Fail : True;
}


/****************************************************************************
**
*F  FuncWRITE_BYTE_FILE( <self>, <fid>, <byte> )  . . . . . . .  write a byte
*/
Obj FuncWRITE_BYTE_FILE (
    Obj             self,
    Obj             fid,
    Obj             ch )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    while ( ! IS_INTOBJ(ch) ) {
        ch = ErrorReturnObj(
            "<ch> must be an integer (not a %s)",
            (Int)TNAM_OBJ(ch), 0L,
            "you can replace <ch> via 'return <ch>;'" );
    }
    
    /* call the system dependent function                                  */
    ret = SyEchoch( INT_INTOBJ(ch), INT_INTOBJ(fid) );
    return ret == -1 ? Fail : True;
}

/****************************************************************************
**
*F  FuncWRITE_STRING_FILE_NC( <self>, <fid>, <string> ) .write a whole string
*/
Obj FuncWRITE_STRING_FILE_NC (
    Obj             self,
    Obj             fid,
    Obj             str )
{
    Int             len = 0, l, ret;
    char            *ptr;

    /* don't check the argument                                            */
    
    len = GET_LEN_STRING(str);
    ptr = CSTR_STRING(str);
    while (len > 0) {
      l = (len > 1048576) ? 1048576 : len;
      ret = write( syBuf[INT_INTOBJ(fid)].echo, ptr, l);
      if (ret == -1) {
        SySetErrorNo();
        return Fail;
      }
      len -= ret;
      ptr += ret;
    }
    return True;
}

Obj FuncREAD_STRING_FILE (
    Obj             self,
    Obj             fid )
{
    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)TNAM_OBJ(fid), 0L,
            "you can replace <fid> via 'return <fid>;'" );
    }
    return SyReadStringFid(INT_INTOBJ(fid));
}

/****************************************************************************
**
*F  FuncFD_OF_FILE( <fid> )
*/
Obj FuncFD_OF_FILE(Obj self,Obj fid)
{
  Int fd;
  int fdi;
  while (fid == (Obj) 0 || !(IS_INTOBJ(fid))) {
    fid = ErrorReturnObj(
           "<fid> must be a small integer (not a %s)",
           (Int)TNAM_OBJ(fid),0L,
           "you can replace <fid> via 'return <fid>;'" );
  }

  fd = INT_INTOBJ(fid);
  fdi = syBuf[fd].fp;
  return INTOBJ_INT(fdi);
}

#if HAVE_SELECT
Obj FuncUNIXSelect(Obj self, Obj inlist, Obj outlist, Obj exclist, 
                   Obj timeoutsec, Obj timeoutusec)
{
  fd_set infds,outfds,excfds;
  struct timeval tv;
  int n,maxfd;
  Int i,j;
  Obj o;

  while (inlist == (Obj) 0 || !(IS_PLIST(inlist)))
    inlist = ErrorReturnObj(
           "<inlist> must be a list of small integers (not a %s)",
           (Int)TNAM_OBJ(inlist),0L,
           "you can replace <inlist> via 'return <inlist>;'" );
  while (outlist == (Obj) 0 || !(IS_PLIST(outlist)))
    outlist = ErrorReturnObj(
           "<outlist> must be a list of small integers (not a %s)",
           (Int)TNAM_OBJ(outlist),0L,
           "you can replace <outlist> via 'return <outlist>;'" );
  while (exclist == (Obj) 0 || !(IS_PLIST(exclist)))
    exclist = ErrorReturnObj(
           "<exclist> must be a list of small integers (not a %s)",
           (Int)TNAM_OBJ(exclist),0L,
           "you can replace <exclist> via 'return <exclist>;'" );

  FD_ZERO(&infds);
  FD_ZERO(&outfds);
  FD_ZERO(&excfds);
  maxfd = 0;
  /* Handle input file descriptors: */
  for (i = 1;i <= LEN_PLIST(inlist);i++) {
    o = ELM_PLIST(inlist,i);
    if (o != (Obj) 0 && IS_INTOBJ(o)) {
      j = INT_INTOBJ(o);  /* a UNIX file descriptor */
      FD_SET(j,&infds);
      if (j > maxfd) maxfd = j;
    }
  }
  /* Handle output file descriptors: */
  for (i = 1;i <= LEN_PLIST(outlist);i++) {
    o = ELM_PLIST(outlist,i);
    if (o != (Obj) 0 && IS_INTOBJ(o)) {
      j = INT_INTOBJ(o);  /* a UNIX file descriptor */
      FD_SET(j,&outfds);
      if (j > maxfd) maxfd = j;
    }
  }
  /* Handle exception file descriptors: */
  for (i = 1;i <= LEN_PLIST(exclist);i++) {
    o = ELM_PLIST(exclist,i);
    if (o != (Obj) 0 && IS_INTOBJ(o)) {
      j = INT_INTOBJ(o);  /* a UNIX file descriptor */
      FD_SET(j,&excfds);
      if (j > maxfd) maxfd = j;
    }
  }
  /* Handle the timeout: */
  if (timeoutsec != (Obj) 0 && IS_INTOBJ(timeoutsec) &&
      timeoutusec != (Obj) 0 && IS_INTOBJ(timeoutusec)) {
    tv.tv_sec = INT_INTOBJ(timeoutsec);
    tv.tv_usec = INT_INTOBJ(timeoutusec);
    n = select(maxfd+1,&infds,&outfds,&excfds,&tv);
  } else {
    n = select(maxfd+1,&infds,&outfds,&excfds,NULL);
  }
    
  if (n >= 0) {
    /* Now run through the lists and call functions if ready: */

    for (i = 1;i <= LEN_PLIST(inlist);i++) {
      o = ELM_PLIST(inlist,i);
      if (o != (Obj) 0 && IS_INTOBJ(o)) {
        j = INT_INTOBJ(o);  /* a UNIX file descriptor */
        if (!(FD_ISSET(j,&infds))) {
          SET_ELM_PLIST(inlist,i,Fail);
          CHANGED_BAG(inlist);
        }
      }
    }
    /* Handle output file descriptors: */
    for (i = 1;i <= LEN_PLIST(outlist);i++) {
      o = ELM_PLIST(outlist,i);
      if (o != (Obj) 0 && IS_INTOBJ(o)) {
        j = INT_INTOBJ(o);  /* a UNIX file descriptor */
        if (!(FD_ISSET(j,&outfds))) {
          SET_ELM_PLIST(outlist,i,Fail);
          CHANGED_BAG(outlist);
        }
      }
    }
    /* Handle exception file descriptors: */
    for (i = 1;i <= LEN_PLIST(exclist);i++) {
      o = ELM_PLIST(exclist,i);
      if (o != (Obj) 0 && IS_INTOBJ(o)) {
        j = INT_INTOBJ(o);  /* a UNIX file descriptor */
        if (!(FD_ISSET(j,&excfds))) {
          SET_ELM_PLIST(exclist,i,Fail);
          CHANGED_BAG(exclist);
        }
      }
    }
  }
  return INTOBJ_INT(n);
}
#endif

/****************************************************************************
**

*F * * * * * * * * * * * * * execution functions  * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FuncExecuteProcess( <self>, <dir>, <prg>, <in>, <out>, <args> )   process
*/
static Obj    ExecArgs  [ 1024 ];
static Char * ExecCArgs [ 1024 ];

Obj FuncExecuteProcess (
    Obj                 self,
    Obj                 dir,
    Obj                 prg,
    Obj                 in,
    Obj                 out,
    Obj                 args )
{
    Obj                 tmp;
    Int                 res;
    Int                 i;

    /* check the argument                                                  */
    while ( ! IsStringConv(dir) ) {
        dir = ErrorReturnObj(
            "<dir> must be a string (not a %s)",
            (Int)TNAM_OBJ(dir), 0L,
            "you can replace <dir> via 'return <dir>;'" );
    }
    while ( ! IsStringConv(prg) ) {
        prg = ErrorReturnObj(
            "<prg> must be a string (not a %s)",
            (Int)TNAM_OBJ(prg), 0L,
            "you can replace <prg> via 'return <prg>;'" );
    }
    while ( ! IS_INTOBJ(in) ) {
        in = ErrorReturnObj(
            "<in> must be an integer (not a %s)",
            (Int)TNAM_OBJ(in), 0L,
            "you can replace <in> via 'return <in>;'" );
    }
    while ( ! IS_INTOBJ(out) ) {
        out = ErrorReturnObj(
            "<out> must be an integer (not a %s)",
            (Int)TNAM_OBJ(out), 0L,
            "you can replace <out> via 'return <out>;'" );
    }
    while ( ! IS_SMALL_LIST(args) ) {
        args = ErrorReturnObj(
            "<args> must be a small list (not a %s)",
            (Int)TNAM_OBJ(args), 0L,
            "you can replace <args> via 'return <args>;'" );
    }

    /* create an argument array                                            */
    for ( i = 1;  i <= LEN_LIST(args);  i++ ) {
        if ( i == 1023 )
            break;
        tmp = ELM_LIST( args, i );
        while ( ! IsStringConv(tmp) ) {
            tmp = ErrorReturnObj(
                "<tmp> must be a string (not a %s)",
                (Int)TNAM_OBJ(tmp), 0L,
                "you can replace <tmp> via 'return <tmp>;'" );
        }
        ExecArgs[i] = tmp;
    }
    ExecCArgs[0]   = CSTR_STRING(prg);
    ExecCArgs[i] = 0;
    for ( i--;  0 < i;  i-- ) {
        ExecCArgs[i] = CSTR_STRING(ExecArgs[i]);
    }
    if (SyWindow && out == INTOBJ_INT(1)) /* standard output */
      syWinPut( INT_INTOBJ(out), "@z","");

    /* execute the process                                                 */
    res = SyExecuteProcess( CSTR_STRING(dir),
                            CSTR_STRING(prg),
                            INT_INTOBJ(in),
                            INT_INTOBJ(out),
                            ExecCArgs );

    if (SyWindow && out == INTOBJ_INT(1)) /* standard output */
      syWinPut( INT_INTOBJ(out), "@mAgIc","");
    return res == 255 ? Fail : INTOBJ_INT(res);
}


/****************************************************************************
**


*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "READ", 1L, "filename",
      FuncREAD, "src/streams.c:READ" },

    { "READ_NORECOVERY", 1L, "filename",
      FuncREAD_NORECOVERY, "src/streams.c:READ_NORECOVERY" },

    { "READ_COMMAND_REAL", 2L, "stream, echo",
      FuncREAD_COMMAND_REAL, "src/streams.c:READ_COMMAND_REAL" },

    { "READ_COMMAND", 2L, "stream, echo", 
      FuncREAD_COMMAND, "src/streams.c:READ_COMMAND" },

    { "READ_STREAM", 1L, "stream",
      FuncREAD_STREAM, "src/streams.c:READ_STREAM" },

    { "READ_STREAM_LOOP", 2L, "stream, catchstderrout",
      FuncREAD_STREAM_LOOP, "src/streams.c:READ_STREAM_LOOP" },

    { "READ_AS_FUNC", 1L, "filename",
      FuncREAD_AS_FUNC, "src/streams.c:READ_AS_FUNC" },

    { "READ_AS_FUNC_STREAM", 1L, "stream", 
      FuncREAD_AS_FUNC_STREAM, "src/streams.c:READ_AS_FUNC_STREAM" },

    { "READ_GAP_ROOT", 1L, "filename",
      FuncREAD_GAP_ROOT, "src/streams.c:READ_GAP_ROOT" },

    { "LOG_TO", 1L, "filename", 
      FuncLOG_TO, "src/streams.c:LOG_TO" },

    { "LOG_TO_STREAM", 1L, "filename", 
      FuncLOG_TO_STREAM, "src/streams.c:LOG_TO_STREAM" },

    { "CLOSE_LOG_TO", 0L, "", 
      FuncCLOSE_LOG_TO, "src/streams.c:CLOSE_LOG_TO" },

    { "INPUT_LOG_TO", 1L, "filename", 
      FuncINPUT_LOG_TO, "src/streams.c:INPUT_LOG_TO" },

    { "INPUT_LOG_TO_STREAM", 1L, "filename", 
      FuncINPUT_LOG_TO_STREAM, "src/streams.c:INPUT_LOG_TO_STREAM" },

    { "CLOSE_INPUT_LOG_TO", 0L, "", 
      FuncCLOSE_INPUT_LOG_TO, "src/streams.c:CLOSE_INPUT_LOG_TO" },

    { "OUTPUT_LOG_TO", 1L, "filename", 
      FuncOUTPUT_LOG_TO, "src/streams.c:OUTPUT_LOG_TO" },

    { "OUTPUT_LOG_TO_STREAM", 1L, "filename", 
      FuncOUTPUT_LOG_TO_STREAM, "src/streams.c:OUTPUT_LOG_TO_STREAM" },

    { "CLOSE_OUTPUT_LOG_TO", 0L, "", 
      FuncCLOSE_OUTPUT_LOG_TO, "src/streams.c:CLOSE_OUTPUT_LOG_TO" },

    { "Print", -1L, "args",
      FuncPrint, "src/streams.c:Print" },

    { "PRINT_TO", -1L, "args",
      FuncPRINT_TO, "src/streams.c:PRINT_TO" },

    { "PRINT_TO_STREAM", -1L, "args",
      FuncPRINT_TO_STREAM, "src/streams.c:PRINT_TO_STREAM" },

    { "APPEND_TO", -1L, "args",
      FuncAPPEND_TO, "src/streams.c:APPEND_TO" },

    { "APPEND_TO_STREAM", -1L, "args",
      FuncAPPEND_TO_STREAM, "src/streams.c:APPEND_TO_STREAM" },

    { "SET_OUTPUT", 2, "file, app",
      FuncSET_OUTPUT, "src/streams.c:SET_OUTPUT" },

    { "SET_PREVIOUS_OUTPUT", 0, "",
      FuncSET_PREVIOUS_OUTPUT, "src/streams.c:SET_PREVIOUS_OUTPUT" },

    { "TmpName", 0L, "",
      FuncTmpName, "src/streams.c:TmpName" },

    { "TmpDirectory", 0L, "",
      FuncTmpDirectory, "src/streams.c:TmpDirectory" },

    { "RemoveFile", 1L, "filename",
      FuncRemoveFile, "src/streams.c:RemoveFile" },

    { "CreateDir", 1L, "filename",
      FuncCreateDir, "src/streams.c:CreateDir" },

    { "RemoveDir", 1L, "filename",
      FuncRemoveDir, "src/streams.c:RemoveDir" },

    { "IsDir", 1L, "filename",
      FuncIsDir, "src/streams.c:IsDir" },

    { "LastSystemError", 0L, "", 
      FuncLastSystemError, "src/streams.c:LastSystemError" },

    { "IsExistingFile", 1L, "filename", 
      FuncIsExistingFile, "src/streams.c:IsExistingFile" },

    { "IsReadableFile", 1L, "filename",
      FuncIsReadableFile, "src/streams.c:IsReadableFile" },

    { "IsWritableFile", 1L, "filename",
      FuncIsWritableFile, "src/streams.c:IsWritableFile" },

    { "IsExecutableFile", 1L, "filename",
      FuncIsExecutableFile, "src/streams.c:IsExecutableFile" },

    { "IsDirectoryPathString", 1L, "filename",
      FuncIsDirectoryPathString, "src/streams.c:IsDirectoryPath" },

    { "STRING_LIST_DIR", 1L, "dirname",
      FuncSTRING_LIST_DIR, "src/streams.c:STRING_LIST_DIR"},

    { "CLOSE_FILE", 1L, "fid",
      FuncCLOSE_FILE, "src/streams.c:CLOSE_FILE" },

    { "INPUT_TEXT_FILE", 1L, "filename",
      FuncINPUT_TEXT_FILE, "src/streams.c:INPUT_TEXT_FILE" },

    { "OUTPUT_TEXT_FILE", 2L, "filename, append",
      FuncOUTPUT_TEXT_FILE, "src/streams.c:OUTPUT_TEXT_FILE" },

    { "IS_END_OF_FILE", 1L, "fid",
      FuncIS_END_OF_FILE, "src/streams.c:IS_END_OF_FILE" },

    { "POSITION_FILE", 1L, "fid",
      FuncPOSITION_FILE, "src/streams.c:POSITION_FILE" },

    { "READ_BYTE_FILE", 1L, "fid",
      FuncREAD_BYTE_FILE, "src/streams.c:READ_BYTE_FILE" },

    { "READ_LINE_FILE", 1L, "fid",
      FuncREAD_LINE_FILE, "src/streams.c:READ_LINE_FILE" },

    { "READ_ALL_FILE", 2L, "fid, limit",
      FuncREAD_ALL_FILE, "src/streams.c:READ_ALL_FILE" },

    { "SEEK_POSITION_FILE", 2L, "fid, pos",
      FuncSEEK_POSITION_FILE, "src/streams.c:SEEK_POSITION_FILE" },

    { "WRITE_BYTE_FILE", 2L, "fid, byte",
      FuncWRITE_BYTE_FILE, "src/streams.c:WRITE_BYTE_FILE" },

    { "WRITE_STRING_FILE_NC", 2L, "fid, string",
      FuncWRITE_STRING_FILE_NC, "src/streams.c:WRITE_STRING_FILE_NC" },

    { "READ_STRING_FILE", 1L, "fid",
      FuncREAD_STRING_FILE, "src/streams.c:READ_STRING_FILE" },

    { "FD_OF_FILE", 1L, "fid",
      FuncFD_OF_FILE, "src/streams.c:FD_OF_FILE" },

#ifdef HAVE_SELECT
    { "UNIXSelect", 5L, "inlist, outlist, exclist, timeoutsec, timeoutusec",
      FuncUNIXSelect, "src/streams.c:UNIXSelect" },
#endif

    { "ExecuteProcess", 5L, "dir, prg, in, out, args",
      FuncExecuteProcess, "src/streams.c:ExecuteProcess" },

    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

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
    /* file access test functions                                          */
    ErrorNumberRNam  = RNamName("number");
    ErrorMessageRNam = RNamName("message");

    /* pick up the number of this global */
    LastReadValueGVar = GVarName("LastReadValue");

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


    /* return success                                                      */
    return PostRestore( module );
}


/****************************************************************************
**
*F  InitInfoStreams() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "streams" ,                         /* name                           */
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

StructInitInfo * InitInfoStreams ( void )
{
    return &module;
}


/****************************************************************************
**

*E  streams.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
