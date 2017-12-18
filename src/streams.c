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

#include <src/streams.h>

#include <src/bool.h>
#include <src/funcs.h>
#include <src/gap.h>
#include <src/gapstate.h>
#include <src/gvars.h>
#include <src/lists.h>
#include <src/io.h>
#include <src/plist.h>
#include <src/precord.h>
#include <src/read.h>
#include <src/records.h>
#include <src/stats.h>
#include <src/stringobj.h>
#include <src/sysfiles.h>
#include <src/vars.h>

#include <dirent.h>
#include <errno.h>
#include <time.h>
#include <unistd.h>

#ifdef HAVE_SELECT
// For FuncUNIXSelect
#include <sys/time.h>
#endif



/****************************************************************************
**
*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/

static Int READ_COMMAND(Obj *evalResult)
{
    ExecStatus    status;

    ClearError();
    status = ReadEvalCommand(STATE(BottomLVars), evalResult, 0);
    if( status == STATUS_EOF )
        return 0;

    if ( STATE(UserHasQuit) || STATE(UserHasQUIT) )
        return 0;
    
    /* handle return-value or return-void command                          */
    if ( status & (STATUS_RETURN_VAL | STATUS_RETURN_VOID) ) {
        Pr( "'return' must not be used in file read-eval loop", 0L, 0L );
    }

    /* handle quit command                                 */
    else if (status == STATUS_QUIT) {
        SetRecursionDepth(0);
        STATE(UserHasQuit) = 1;
    }
    else if (status == STATUS_QQUIT) {
        STATE(UserHasQUIT) = 1;
    }
    ClearError();

    return 1;
}


/*
 * This function reads all code from the stream and returns either `fail` if the stream
 * cannot be opened, or a list of lists of length at most two, where the first entry is
 * either `true` or `false` depending on whether the statement was successfuly executed
 * and the second entry is the result of the statement if there was one.
 *
 * This function is curently used in interactive tools such as the GAP Jupyter kernel to
 * execute cells and is likely to be replaced by a function that can read a single command
 * from a stream without losing the rest of its content.
 */
Obj FuncREAD_ALL_COMMANDS( Obj self, Obj stream, Obj echo )
{
    ExecStatus status;
    Int resultCount, resultCapacity;
    Obj result, resultList;
    Obj evalResult;

    /* try to open the stream */
    if (!OpenInputStream(stream, echo == True)) {
        return Fail;
    }

    resultCount = 0;
    resultCapacity = 16;
    resultList = NEW_PLIST( T_PLIST, resultCapacity );
    SET_LEN_PLIST(resultList, resultCount);

    do {
        ClearError();
        status = ReadEvalCommand(STATE(BottomLVars), &evalResult, 0);

        if(!(status & (STATUS_EOF | STATUS_QUIT | STATUS_QQUIT))) {
            resultCount++;
            if (resultCount > resultCapacity) {
                resultCapacity += 16;
                GROW_PLIST(resultList, resultCapacity);
            }
            result = NEW_PLIST( T_PLIST, 2 );
            SET_LEN_PLIST(result, 1);
            SET_ELM_PLIST(result, 1, False);
            SET_ELM_PLIST(resultList, resultCount, result );
            SET_LEN_PLIST(resultList, resultCount );

            if(!(status & STATUS_ERROR)) {
                SET_ELM_PLIST(result, 1, True);
                if (evalResult) {
                    SET_LEN_PLIST(result, 2);
                    SET_ELM_PLIST(result, 2, evalResult);
                }
            }
        }
    } while(!(status & (STATUS_EOF | STATUS_QUIT | STATUS_QQUIT)));
    CloseInput();
    ClearError();

    return resultList;
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
    Obj evalResult;

    result = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST(result, 1);
    SET_ELM_PLIST(result, 1, False);

    /* try to open the file                                                */
    if (!OpenInputStream(stream, echo == True)) {
        return result;
    }

    status = READ_COMMAND(&evalResult);
    
    CloseInput();

    if( status == 0 ) return result;

    if (STATE(UserHasQUIT)) {
      STATE(UserHasQUIT) = 0;
      return result;
    }

    if (STATE(UserHasQuit)) {
      STATE(UserHasQuit) = 0;
    }
    
    SET_ELM_PLIST(result, 1, True);
    if (evalResult) {
        SET_LEN_PLIST(result, 2);
        SET_ELM_PLIST(result, 2, evalResult);
    }
    return result;
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
    if (STATE(UserHasQuit))
      {
        Pr("Warning: Entering READ with UserHasQuit set, this should never happen, resetting",0,0);
        STATE(UserHasQuit) = 0;
      }
    if (STATE(UserHasQUIT))
      {
        Pr("Warning: Entering READ with UserHasQUIT set, this should never happen, resetting",0,0);
        STATE(UserHasQUIT) = 0;
      }
    MakeReadWriteGVar(LastReadValueGVar);
    AssGVar( LastReadValueGVar, 0);
    MakeReadOnlyGVar(LastReadValueGVar);
    /* now do the reading                                                  */
    while ( 1 ) {
        ClearError();
        Obj evalResult;
        ExecStatus status = ReadEvalCommand(STATE(BottomLVars), &evalResult, 0);
	if (STATE(UserHasQuit) || STATE(UserHasQUIT))
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
          SetRecursionDepth(0);
          STATE(UserHasQuit) = 1;
          break;
        }
        else if (status == STATUS_QQUIT) {
          STATE(UserHasQUIT) = 1;
          break;
        }
        if (evalResult)
          {
            MakeReadWriteGVar(LastReadValueGVar);
            AssGVar( LastReadValueGVar, evalResult);
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

    if (!UseUHQ && STATE(UserHasQuit)) {
      STATE(UserHasQuit) = 0; /* stop recovery here */
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
    /* now do the reading                                                  */
    ClearError();
    Obj evalResult;
    UInt type = ReadEvalFile(&evalResult);

    /* get the function                                                    */
    Obj func = (type == 0) ? evalResult : Fail;

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
        Obj evalResult;
        type = ReadEvalCommand(STATE(BottomLVars), &evalResult, &dualSemicolon);

        /* stop the stopwatch                                              */
        AssGVar( Time, INTOBJ_INT( SyTime() - oldtime ) );

        /* handle ordinary command                                         */
        if ( type == 0 && evalResult != 0 ) {

            /* remember the value in 'last' and the time in 'time'         */
            AssGVar( Last3, ValGVarTL( Last2 ) );
            AssGVar( Last2, ValGVarTL( Last  ) );
            AssGVar( Last, evalResult );

            /* print the result                                            */
            if ( ! dualSemicolon ) {
                Bag currLVars = STATE(CurrLVars); /* in case view runs into error */
                ViewObjHandler( evalResult );
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


Int READ_GAP_ROOT ( const Char * filename )
{
    TypGRF_Data         result;
    Int                 res;
    UInt                type;
    StructInitInfo *    info;

    /* try to find the file                                                */
    res = SyFindOrLinkGapRootFile( filename, &result );

    /* not found                                                           */
    if ( res == 0 ) {
        return 0;
    }

    /* dynamically or statically linked                                    */
    else if ( res == 1 || res == 2 ) {
        // This code section covers loading of GAC compiled code; in contrast
        // to FuncLOAD_STAT and FuncLOAD_DYN, which are typically used by
        // kernel extensions to load C/C++ code.
        if ( SyDebugLoading ) {
            const char *s = (res == 1) ? "dynamically" : "statically";
            Pr( "#I  READ_GAP_ROOT: loading '%s' %s\n", (Int)filename, (Int)s );
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
        RecordLoadedModule(info, 1, filename);
        return 1;
    }

    /* special handling for the other cases, if we are trying to load compiled
       modules needed for a saved workspace ErrorQuit is not available */
    else if (SyRestoring) {
        if ( res == 3 ) {
            Pr("Can't find compiled module '%s' needed by saved workspace\n",
               (Int) filename, 0L);
            return 0;
        }
        Pr("unknown result code %d from 'SyFindGapRoot'", res, 0L );
        SyExit(1);
    }
    
    /* ordinary gap file                                                   */
    else if ( res == 3 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' as GAP file\n",
                (Int)filename, 0L );
        }
        if ( OpenInput(result.pathname) ) {
          SySetBuffering(STATE(Input)->file);
            while ( 1 ) {
                ClearError();
                Obj evalResult;
                type = ReadEvalCommand(STATE(BottomLVars), &evalResult, 0);
                if (STATE(UserHasQuit) || STATE(UserHasQUIT))
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
            memcpy( readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf) );

            /* if an error occurs stop printing                            */
            TRY_READ {
                PrintObj( arg );
            }
            CATCH_READ_ERROR {
                memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
                ReadEvalError();
            }
            memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
        }
    }

    return 0;
}

static Obj PRINT_OR_APPEND_TO(Obj args, int append)
{
    const char * volatile funcname = append ? "AppendTo" : "PrintTo";
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
            PrintFunction( arg );
        }
        else {
            memcpy( readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf) );

            /* if an error occurs stop printing                            */
            TRY_READ {
                PrintObj( arg );
            }
            CATCH_READ_ERROR {
                CloseOutput();
                memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
                ReadEvalError();
            }
            memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
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
    const char * volatile funcname = append ? "AppendTo" : "PrintTo";
    volatile Obj        arg;
    volatile Obj        stream;
    volatile UInt       i;
    syJmp_buf           readJmpError;

    /* first entry is the stream                                           */
    stream = ELM_LIST(args,1);

    /* try to open the file for output                                     */
    i = OpenOutputStream(stream);
    if ( ! i ) {
        ErrorQuit( "%s: cannot open stream for output", (Int)funcname, 0L );
        return 0;
    }

    /* print all the arguments, take care of strings and functions         */
    for ( i = 2;  i <= LEN_PLIST(args);  i++ ) {
        arg = ELM_LIST(args,i);

        /* if an error occurs stop printing                                */
        memcpy( readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf) );
        TRY_READ {
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
                PrintObj( arg );
            }
        }
        CATCH_READ_ERROR {
            CloseOutput();
            memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
            ReadEvalError();
        }
        memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
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
    /* Note that FuncPRINT_TO_STREAM and FuncAPPEND_TO_STREAM do exactly the
       same, they only differ in the function name they print as part
       of their error messages. */
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
    /* Note that FuncPRINT_TO_STREAM and FuncAPPEND_TO_STREAM do exactly the
       same, they only differ in the function name they print as part
       of their error messages. */
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
        if ( ! OpenOutputStream( file ) ) {
          if ( append != False ) {
             ErrorQuit( "SET_OUTPUT: cannot open stream for appending", 0L, 0L );
          } else {
             ErrorQuit( "SET_OUTPUT: cannot open stream for output", 0L, 0L );
          }
        } else {
          return 0;
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

Obj FuncIS_INPUT_TTY(Obj self)
{
    GAP_ASSERT(STATE(Input));
    if (STATE(Input)->isstream)
        return False;
    return syBuf[STATE(Input)->file].isTTY ? True : False;
}

Obj FuncIS_OUTPUT_TTY(Obj self)
{
    GAP_ASSERT(STATE(Output));
    if (STATE(Output)->isstream)
        return False;
    return syBuf[STATE(Output)->file].isTTY ? True : False;
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

    SySetBuffering(STATE(Input)->file);
   
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

    SySetBuffering(STATE(Input)->file);
   
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
    if (!OpenInputStream(stream, 0)) {
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
    if (!OpenInputStream(stream, 0)) {
        return False;
    }

    /* read the test file                                                  */
    LockCurrentOutput(catcherrstdout == True);
    READ_LOOP();
    LockCurrentOutput(0);
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

    SySetBuffering(STATE(Input)->file);
    
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
    if (!OpenInputStream(stream, 0)) {
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
    Char filenamecpy[GAP_PATH_MAX];

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ: <filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }

    /* Copy to avoid garbage collection moving string                      */
    strlcpy(filenamecpy, CSTR_STRING(filename), GAP_PATH_MAX);
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
    name = MakeString(tmp);
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
    name = MakeString(tmp);
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
        msg = MakeString(SyLastErrorMessage);
        ASS_REC( err, ErrorMessageRNam, msg );
    }

    /* no error has occured                                                */
    else {
        ASS_REC( err, ErrorNumberRNam, INTOBJ_INT(0) );
        msg = MakeString("no error");
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
    return res == -1 ? False : True;
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
#ifdef SYS_IS_CYGWIN32
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
#ifdef SYS_IS_CYGWIN32
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

#ifdef HPCGAP
Obj FuncRAW_MODE_FILE(Obj self, Obj fid, Obj onoff)
{
  Int fd;
  int fdi;
  while (fid == (Obj) 0 || !(IS_INTOBJ(fid)))
  {
    fid = ErrorReturnObj(
           "<fid> must be a small integer (not a %s)",
           (Int)TNAM_OBJ(fid),0L,
           "you can replace <fid> via 'return <fid>;'" );
  }
  fd = INT_INTOBJ(fid);
  fdi = syBuf[fd].fp;
  if (onoff == False || onoff == Fail)
    return syStopraw(fdi), False;
  else
    return syStartraw(fdi) ? True : False;
}
#endif

#ifdef HAVE_SELECT
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
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(READ, 1, "filename"),
    GVAR_FUNC(READ_NORECOVERY, 1, "filename"),
    GVAR_FUNC(READ_ALL_COMMANDS, 2, "stream, echo"),
    GVAR_FUNC(READ_COMMAND_REAL, 2, "stream, echo"),
    GVAR_FUNC(READ_STREAM, 1, "stream"),
    GVAR_FUNC(READ_STREAM_LOOP, 2, "stream, catchstderrout"),
    GVAR_FUNC(READ_AS_FUNC, 1, "filename"),
    GVAR_FUNC(READ_AS_FUNC_STREAM, 1, "stream"),
    GVAR_FUNC(READ_GAP_ROOT, 1, "filename"),
    GVAR_FUNC(LOG_TO, 1, "filename"),
    GVAR_FUNC(LOG_TO_STREAM, 1, "filename"),
    GVAR_FUNC(CLOSE_LOG_TO, 0, ""),
    GVAR_FUNC(INPUT_LOG_TO, 1, "filename"),
    GVAR_FUNC(INPUT_LOG_TO_STREAM, 1, "filename"),
    GVAR_FUNC(CLOSE_INPUT_LOG_TO, 0, ""),
    GVAR_FUNC(OUTPUT_LOG_TO, 1, "filename"),
    GVAR_FUNC(OUTPUT_LOG_TO_STREAM, 1, "filename"),
    GVAR_FUNC(CLOSE_OUTPUT_LOG_TO, 0, ""),
    GVAR_FUNC(Print, -1, "args"),
    GVAR_FUNC(PRINT_TO, -1, "args"),
    GVAR_FUNC(PRINT_TO_STREAM, -1, "args"),
    GVAR_FUNC(APPEND_TO, -1, "args"),
    GVAR_FUNC(APPEND_TO_STREAM, -1, "args"),
    GVAR_FUNC(SET_OUTPUT, 2, "file, app"),
    GVAR_FUNC(SET_PREVIOUS_OUTPUT, 0, ""),

    GVAR_FUNC(IS_INPUT_TTY, 0, ""),
    GVAR_FUNC(IS_OUTPUT_TTY, 0, ""),

    GVAR_FUNC(TmpName, 0, ""),
    GVAR_FUNC(TmpDirectory, 0, ""),
    GVAR_FUNC(RemoveFile, 1, "filename"),
    GVAR_FUNC(CreateDir, 1, "filename"),
    GVAR_FUNC(RemoveDir, 1, "filename"),
    GVAR_FUNC(IsDir, 1, "filename"),
    GVAR_FUNC(LastSystemError, 0, ""),
    GVAR_FUNC(IsExistingFile, 1, "filename"),
    GVAR_FUNC(IsReadableFile, 1, "filename"),
    GVAR_FUNC(IsWritableFile, 1, "filename"),
    GVAR_FUNC(IsExecutableFile, 1, "filename"),
    GVAR_FUNC(IsDirectoryPathString, 1, "filename"),
    GVAR_FUNC(STRING_LIST_DIR, 1, "dirname"),
    GVAR_FUNC(CLOSE_FILE, 1, "fid"),
    GVAR_FUNC(INPUT_TEXT_FILE, 1, "filename"),
    GVAR_FUNC(OUTPUT_TEXT_FILE, 2, "filename, append"),
    GVAR_FUNC(IS_END_OF_FILE, 1, "fid"),
    GVAR_FUNC(POSITION_FILE, 1, "fid"),
    GVAR_FUNC(READ_BYTE_FILE, 1, "fid"),
    GVAR_FUNC(READ_LINE_FILE, 1, "fid"),
    GVAR_FUNC(READ_ALL_FILE, 2, "fid, limit"),
    GVAR_FUNC(SEEK_POSITION_FILE, 2, "fid, pos"),
    GVAR_FUNC(WRITE_BYTE_FILE, 2, "fid, byte"),
    GVAR_FUNC(WRITE_STRING_FILE_NC, 2, "fid, string"),
    GVAR_FUNC(READ_STRING_FILE, 1, "fid"),
    GVAR_FUNC(FD_OF_FILE, 1, "fid"),
#ifdef HPCGAP
    GVAR_FUNC(RAW_MODE_FILE, 2, "fid, bool"),
#endif
#ifdef HAVE_SELECT
    GVAR_FUNC(UNIXSelect, 5, "inlist, outlist, exclist, timeoutsec, timeoutusec"),
#endif
    GVAR_FUNC(ExecuteProcess, 5, "dir, prg, in, out, args"),
    { 0, 0, 0, 0, 0 }

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
