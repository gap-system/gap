/****************************************************************************
**
*W  streams.c                   GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the various read-eval-print loops and  related  stuff.
*/
char * Revision_streams_c =
   "@(#)$Id$";


#include        <stdio.h>

#include        "system.h"              /* Ints, UInts                     */
extern char * In;
#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* InitGVars                       */

#include        "calls.h"               /* InitCalls                       */
#include        "opers.h"               /* InitOpers                       */

#include        "ariths.h"              /* InitAriths                      */
#include        "records.h"             /* InitRecords                     */
#include        "lists.h"               /* InitLists                       */

#include        "bool.h"                /* InitBool                        */

#include        "integer.h"             /* InitInt                         */
#include        "rational.h"            /* InitRat                         */
#include        "cyclotom.h"            /* InitCyc                         */

#include        "finfield.h"            /* InitFinfield                    */
#include        "permutat.h"            /* InitPermutat                    */

#include        "precord.h"             /* InitPRecord                     */

#include        "listoper.h"            /* InitListOper                    */
#include        "listfunc.h"            /* InitListFunc                    */

#include        "plist.h"               /* InitPlist                       */
#include        "set.h"                 /* InitSet                         */
#include        "vector.h"              /* InitVector                      */

#include        "blister.h"             /* InitBlist                       */
#include        "range.h"               /* InitRange                       */
#include        "string.h"              /* InitString                      */

#include        "objfgelm.h"            /* InitFreeGroupElements           */
#include        "objscoll.h"            /* InitSingleCollector             */
#include        "objpcgel.h"            /* InitPcElements                  */
#include        "objcftl.h"             /* Init polycyclic collector       */

#include        "sctable.h"             /* InitSCTable                     */
#include        "costab.h"              /* InitCosetTable                  */

#include        "code.h"                /* InitCode                        */

#include        "vars.h"                /* InitVars                        */
#include        "exprs.h"               /* InitExprs                       */
#include        "stats.h"               /* InitStats                       */
#include        "funcs.h"               /* InitFuncs                       */

#include        "dt.h"                  /* InitDeepThought                 */
#include        "dteval.h"              /* InitDTEvaluation                */

#include        "intrprtr.h"            /* InitInterpreter                 */

#include        "compiler.h"            /* InitCompiler                    */

#include        "read.h"                /* ReadEvalCommand, ReadEvalResult */

#include        "compstat.h"            /* statically linked modules       */

#include        "gap.h"                 

#define INCLUDE_DECLARATION_PART
#include        "streams.h"             /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART


/****************************************************************************
**

*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/


/****************************************************************************
**

*F  READ_AS_FUNC( <filename> )  . . . . . . . . . . . . . . . . . read a file
*/
Obj READ_AS_FUNC (
    Char *              filename )
{
    Obj                 func;
    UInt                type;

    /* try to open the file                                                */
    if ( ! OpenInput( filename ) ) {
        return Fail;
    }
    NrError = 0;

    /* now do the reading                                                  */
    type = ReadEvalFile();

    /* get the function                                                    */
    if ( type == 0 ) {
        func = ReadEvalResult;
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
    NrError = 0;

    /* return the function                                                 */
    return func;
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
    Char                result[256];
    Int                 res;
    UInt                type;
    StructCompInitInfo* info;
    Obj                 func;
    UInt4               crc;
    Char *              file;

    /* try to find the file                                                */
    file = SyFindGapRootFile(filename);
    if ( file ) {
	crc = SyGAPCRC(file);
    }
    else {
	crc = 0;
    }
    res = SyFindOrLinkGapRootFile( filename, crc, result, 256 );

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
        info = *(StructCompInitInfo**)result;
        (info->link)();
        func = (Obj)(info->function1)();
        CALL_0ARGS(func);
        return 1;
    }

    /* statically linked                                                   */
    else if ( res == 2 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' statically\n",
                (Int)filename, 0L );
        }
        info = *(StructCompInitInfo**)result;
        (info->link)();
        func = (Obj)(info->function1)();
        CALL_0ARGS(func);
        return 1;
    }

    /* ordinary gap file                                                   */
    else if ( res == 3 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' as GAP file\n",
                (Int)filename, 0L );
        }
        if ( OpenInput(result) ) {
            NrError = 0;
            while ( 1 ) {
                type = ReadEvalCommand();
                if ( type == 1 || type == 2 ) {
                    Pr( "'return' must not be used in file", 0L, 0L );
                }
                else if ( type == 8 || type == 16 ) {
                    break;
                }
            }
            CloseInput();
            NrError = 0;
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
}


/****************************************************************************
**

*F  FuncLogTo( <filename> ) . . . . . . . . . . . . internal function 'LogTo'
**
**  'FunLogTo' implements the internal function 'LogTo'.
**
**  'LogTo( <filename> )' \\
**  'LogTo()'
**
**  'LogTo' instructs GAP to echo all input from the  standard  input  files,
**  '*stdin*' and '*errin*' and all output  to  the  standard  output  files,
**  '*stdout*'  and  '*errout*',  to  the  file  with  the  name  <filename>.
**  The file is created if it does not  exist,  otherwise  it  is  truncated.
**
**  'LogTo' called with no argument closes the current logfile again, so that
**  input   from  '*stdin*'  and  '*errin*'  and  output  to  '*stdout*'  and
**  '*errout*' will no longer be echoed to a file.
*/
Obj FuncLogTo (
    Obj                 self,
    Obj                 args )
{
    Obj                 filename;

    /* 'LogTo()'                                                           */
    if ( LEN_LIST(args) == 0 ) {
        if ( ! CloseLog() ) {
            ErrorQuit("LogTo: can not close the logfile",0L,0L);
            return 0;
        }
    }

    /* 'LogTo( <filename> )'                                               */
    else if ( LEN_LIST(args) == 1 ) {
        filename = ELM_LIST(args,1);
        while ( ! IsStringConv(filename) ) {
            filename = ErrorReturnObj(
                "LogTo: <filename> must be a string (not a %s)",
                (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
                "you can return a string for <filename>" );
        }
        if ( ! OpenLog( CSTR_STRING(filename) ) ) {
            ErrorReturnVoid(
                "LogTo: cannot log to %s",
                (Int)CSTR_STRING(filename), 0L,
                "you can return" );
            return 0;
        }
    }

    return 0;
}


/****************************************************************************
**
*F  FuncPrint( <self>, <args> ) . . . . . . . . . . . . . . . .  print <args>
*/
Obj FuncPrint (
    Obj                 self,
    Obj                 args )
{
    Obj                 arg;
    UInt                i;

    /* print all the arguments, take care of strings and functions         */
    for ( i = 1; i <= LEN_PLIST(args); i++ ) {
        arg = ELM_LIST(args,i);
        if ( IsStringConv(arg) && MUTABLE_TYPE(TYPE_OBJ(arg))==T_STRING ) {
            PrintString1(arg);
        }
        else if ( TYPE_OBJ( arg ) == T_FUNCTION ) {
            PrintObjFull = 1;
            PrintFunction( arg );
            PrintObjFull = 0;
        }
        else {
            PrintObj( arg );
        }
    }

    return 0;
}


/****************************************************************************
**
*F  FuncREAD( <self>, <filename> )  . . . . . . . . . . . . . . . read a file
*/
Obj FuncREAD (
    Obj                 self,
    Obj                 filename )
{
    UInt                type;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ: <filename> must be a string (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        return False;
    }
    NrError = 0;

    /* now do the reading                                                  */
    while ( 1 ) {
        type = ReadEvalCommand();

        /* handle return-value or return-void command                      */
        if ( type == 1 || type == 2 ) {
            Pr(
                "'return' must not be used in file read-eval loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( type == 8 || type == 16 ) {
            break;
        }

    }

    /* close the input file again, and return 'true'                       */
    if ( ! CloseInput() ) {
        ErrorQuit(
            "Panic: READ cannot close input, this should not happen",
            0L, 0L );
    }
    NrError = 0;
    return True;
}


/****************************************************************************
**
*F  FuncREAD_STREAM( <self>, <stream> )   . . . . . . . . . . . read a stream
*/
Obj FuncREAD_STREAM (
    Obj                 self,
    Obj                 stream )
{
    UInt                type;

    /* try to open the file                                                */
    if ( ! OpenInputStream(stream) ) {
        return False;
    }
    NrError = 0;

    /* now do the reading                                                  */
    while ( 1 ) {
        type = ReadEvalCommand();

        /* handle return-value or return-void command                      */
        if ( type == 1 || type == 2 ) {
            Pr(
                "'return' must not be used in file read-eval loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( type == 8 || type == 16 ) {
            break;
        }

    }

    /* close the input file again, and return 'true'                       */
    if ( ! CloseInput() ) {
        ErrorQuit(
            "Panic: READ cannot close input, this should not happen",
            0L, 0L );
    }
    NrError = 0;
    return True;
}


/****************************************************************************
**
*F  FuncREAD_TEST( <self>, <filename> ) . . . . . . . . . .  read a test file
*/
Obj FuncREAD_TEST (
    Obj                 self,
    Obj                 filename )
{
    UInt                type;
    UInt                time;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "ReadTest: <filename> must be a string (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file                                                */
    if ( ! OpenTest( CSTR_STRING(filename) ) ) {
        return False;
    }
    NrError = 0;

    /* get the starting time                                               */
    time = SyTime();

    /* now do the reading                                                  */
    while ( 1 ) {

        /* read and evaluate the command                                   */
        type = ReadEvalCommand();

        /* stop the stopwatch                                              */
        AssGVar( Time, INTOBJ_INT( SyTime() - time ) );

        /* handle ordinary command                                         */
        if ( type == 0 && ReadEvalResult != 0 ) {

            /* print the result                                            */
            if ( *In != ';' ) {
                IsStringConv( ReadEvalResult );
                PrintObj( ReadEvalResult );
                Pr( "\n", 0L, 0L );
            }
            else {
                Match( S_SEMICOLON, ";", 0UL );
            }

        }

        /* handle return-value or return-void command                      */
        else if ( type == 1 || type == 2 ) {
            Pr(
                "'return' must not be used in file read-eval loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( type == 8 || type == 16 ) {
            break;
        }

    }

    /* close the input file again, and return 'true'                       */
    if ( ! CloseTest() ) {
        ErrorQuit(
            "Panic: ReadTest cannot close input, this should not happen",
            0L, 0L );
    }
    NrError = 0;
    return True;
}


/****************************************************************************
**
*F  FuncREAD_TEST_STREAM( <self>, <stream> )  . . . . . .  read a test stream
*/
Obj FuncREAD_TEST_STREAM (
    Obj                 self,
    Obj                 stream )
{
    UInt                type;
    UInt                time;

    /* try to open the file                                                */
    if ( ! OpenTestStream(stream) ) {
        return False;
    }
    NrError = 0;

    /* get the starting time                                               */
    time = SyTime();

    /* now do the reading                                                  */
    while ( 1 ) {

        /* read and evaluate the command                                   */
        type = ReadEvalCommand();

        /* stop the stopwatch                                              */
        AssGVar( Time, INTOBJ_INT( SyTime() - time ) );

        /* handle ordinary command                                         */
        if ( type == 0 && ReadEvalResult != 0 ) {

            /* print the result                                            */
            if ( *In != ';' ) {
                IsStringConv( ReadEvalResult );
                PrintObj( ReadEvalResult );
                Pr( "\n", 0L, 0L );
            }
            else {
                Match( S_SEMICOLON, ";", 0UL );
            }

        }

        /* handle return-value or return-void command                      */
        else if ( type == 1 || type == 2 ) {
            Pr(
                "'return' must not be used in file read-eval loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( type == 8 || type == 16 ) {
            break;
        }

    }

    /* close the input file again, and return 'true'                       */
    if ( ! CloseTest() ) {
        ErrorQuit(
            "Panic: ReadTest cannot close input, this should not happen",
            0L, 0L );
    }
    NrError = 0;
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
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }

    /* read the function                                                   */
    return READ_AS_FUNC( CSTR_STRING(filename) );
}


/****************************************************************************
**
*F  FuncREAD_GAP_ROOT( <filename> ) . . . . . . . . . . . . . . . read a file
*/
Obj FuncREAD_GAP_ROOT (
    Obj                 self,
    Obj                 filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "READ: <filename> must be a string (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }

    /* try to open the file                                                */
    if ( READ_GAP_ROOT( CSTR_STRING(filename) ) ) {
        return True;
    }
    else {
        return False;
    }
}


/****************************************************************************
**

*F * * * * * * * * * * * file access test functions * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FuncIsExistingFile( <self>, <name> )  . . . . . . does file <name> exists
*/
Obj FuncIsExistingFile (
    Obj             self,
    Obj             filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    return SyIsExistingFile( CSTR_STRING(filename) ) ? True : False;
}


/****************************************************************************
**
*F  FuncIsReadableFile( <self>, <name> )  . . . . . . is file <name> readable
*/
Obj FuncIsReadableFile (
    Obj             self,
    Obj             filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    return SyIsReadableFile( CSTR_STRING(filename) ) ? True : False;
}


/****************************************************************************
**
*F  FuncIsWritableFile( <self>, <name> )  . . . . . . is file <name> writable
*/
Obj FuncIsWritableFile (
    Obj             self,
    Obj             filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    return SyIsWritableFile( CSTR_STRING(filename) ) ? True : False;
}


/****************************************************************************
**
*F  FuncIsExecutableFile( <self>, <name> )  . . . . is file <name> executable
*/
Obj FuncIsExecutableFile (
    Obj             self,
    Obj             filename )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    return SyIsExecutableFile( CSTR_STRING(filename) ) ? True : False;
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
    Obj		    self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(fid)].name), 0L,
            "you can return an integer for <fid>" );
    }
    
    /* call the system dependent function                                  */
    ret = SyFclose( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : True;
}


/****************************************************************************
**
*F  FuncINPUT_TEXT_FILE( <self>, <name>  )  . . . . . . . . . . open a stream
*/
Obj FuncINPUT_TEXT_FILE (
    Obj		    self,
    Obj             filename )
{
    Int             fid;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(filename)].name), 0L,
            "you can return a string for <filename>" );
    }
    
    /* call the system dependent function                                  */
    fid = SyFopen( CSTR_STRING(filename), "r" );
    return fid == -1 ? Fail : INTOBJ_INT(fid);
}


/****************************************************************************
**
*F  FuncIS_END_OF_FILE( <self>, <fid> ) . . . . . . . . . . .  is end of file
*/
Obj FuncIS_END_OF_FILE (
    Obj		    self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(fid)].name), 0L,
            "you can return an integer for <fid>" );
    }
    
    ret = SyIsEndOfFile( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : ( ret == 0 ? False : True );
}


/****************************************************************************
**
*F  FuncPOSITION_FILE( <self>, <fid> )	. . . . . . . . .  position of stream
*/
Obj FuncPOSITION_FILE (
    Obj		    self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(fid)].name), 0L,
            "you can return an integer for <fid>" );
    }
    
    ret = SyFtell( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : INTOBJ_INT(ret);
}


/****************************************************************************
**
*F  FuncREAD_BYTE_FILE( <self>, <fid> ) . . . . . . . . . . . . . read a byte
*/
Obj FuncREAD_BYTE_FILE (
    Obj		    self,
    Obj             fid )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(fid)].name), 0L,
            "you can return an integer for <fid>" );
    }
    
    /* call the system dependent function                                  */
    ret = SyGetch( INT_INTOBJ(fid) );
    return ret == -1 ? Fail : INTOBJ_INT(ret);
}


/****************************************************************************
**
*F  FuncREAD_LINE_FILE( <self>, <fid> ) . . . . . . . . . . . . . read a line
*/
Obj FuncREAD_LINE_FILE (
    Obj		    self,
    Obj             fid )
{
    Char            buf[256];
    Char *          cstr;
    Int             len;
    Obj             str;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(fid)].name), 0L,
            "you can return an integer for <fid>" );
    }
    
    /* read <fid> until we see a newline or eof                            */
    str = NEW_STRING(0);
    len = 0;
    while (1) {
        ResizeBag( str, 1+len );
        if ( SyFgets( buf, 256, INT_INTOBJ(fid) ) == 0 )
	    break;
	cstr = CSTR_STRING(str);
	SyStrncat( cstr, buf, 255 );
	if ( buf[SyStrlen(buf)-1] == '\n' )
	    break;
	len += 255;
    }

    /* fix the length of <str>                                             */
    len = SyStrlen( CSTR_STRING(str) );
    ResizeBag( str, len+1 );

    /* and return                                                          */
    return len == 0 ? Fail : str;
}


/****************************************************************************
**
*F  FuncSEEK_POSITION_FILE( <self>, <fid>, <pos> )  . seek position of stream
*/
Obj FuncSEEK_POSITION_FILE (
    Obj		    self,
    Obj             fid,
    Obj             pos )
{
    Int             ret;

    /* check the argument                                                  */
    while ( ! IS_INTOBJ(fid) ) {
        fid = ErrorReturnObj(
            "<fid> must be an integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(fid)].name), 0L,
            "you can return an integer for <fid>" );
    }
    while ( ! IS_INTOBJ(pos) ) {
        pos = ErrorReturnObj(
            "<pos> must be an integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(pos)].name), 0L,
            "you can return an integer for <pos>" );
    }
    
    ret = SyFseek( INT_INTOBJ(fid), INT_INTOBJ(pos) );
    return ret == -1 ? Fail : True;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitStreams() . . . . . . . . . . . . . . . . . . . . . intialize streams
*/
void InitStreams ()
{
    /* import functions from the library                                   */
    ImportGVarFromLibrary( "ReadLine", &ReadLineFunc );

    /* streams and files related functions                                 */
    InitHandlerFunc( FuncREAD, "READ" );
    AssGVar( GVarName( "READ" ),
         NewFunctionC( "READ", 1L, "filename",
                    FuncREAD ) );

    InitHandlerFunc( FuncREAD_STREAM, "READ_STREAM" );
    AssGVar( GVarName( "READ_STREAM" ),
         NewFunctionC( "READ_STREAM", 1L, "stream",
                    FuncREAD_STREAM ) );

    InitHandlerFunc( FuncREAD_TEST, "READ_TEST" );
    AssGVar( GVarName( "READ_TEST" ),
         NewFunctionC( "READ_TEST", 1L, "filename",
                    FuncREAD_TEST ) );

    InitHandlerFunc( FuncREAD_TEST_STREAM, "READ_TEST_STREAM" );
    AssGVar( GVarName( "READ_TEST_STREAM" ),
         NewFunctionC( "READ_TEST_STREAM", 1L, "filename",
                    FuncREAD_TEST_STREAM ) );

    InitHandlerFunc( FuncREAD_AS_FUNC, "READ_AS_FUNC" );
    AssGVar( GVarName( "READ_AS_FUNC" ),
         NewFunctionC( "READ_AS_FUNC", 1L, "filename",
                    FuncREAD_AS_FUNC ) );

    InitHandlerFunc( FuncREAD_GAP_ROOT, "READ_GAP_ROOT" );
    AssGVar( GVarName( "READ_GAP_ROOT" ),
         NewFunctionC( "READ_GAP_ROOT", 1L, "filename",
                    FuncREAD_GAP_ROOT ) );

    InitHandlerFunc( FuncLogTo, "LogTo" );
    AssGVar( GVarName( "LogTo" ),
         NewFunctionC( "LogTo", -1L, "args",
                    FuncLogTo ) );

    /* file access test functions                                          */
    InitHandlerFunc( FuncIsExistingFile, "IsExistingFile" );
    AssGVar( GVarName( "IsExistingFile" ),
         NewFunctionC( "IsExistingFile", 1L, "filename",
                    FuncIsExistingFile ) );

    InitHandlerFunc( FuncIsReadableFile, "IsReadableFile" );
    AssGVar( GVarName( "IsReadableFile" ),
         NewFunctionC( "IsReadableFile", 1L, "filename",
                    FuncIsReadableFile ) );

    InitHandlerFunc( FuncIsWritableFile, "IsWritableFile" );
    AssGVar( GVarName( "IsWritableFile" ),
         NewFunctionC( "IsWritableFile", 1L, "filename",
                    FuncIsWritableFile ) );

    InitHandlerFunc( FuncIsExecutableFile, "IsExecutableFile" );
    AssGVar( GVarName( "IsExecutableFile" ),
         NewFunctionC( "IsExecutableFile", 1L, "filename",
                    FuncIsExecutableFile ) );


    /* stream functions                                                    */
    InitHandlerFunc( FuncCLOSE_FILE, "CLOSE_FILE" );
    AssGVar( GVarName( "CLOSE_FILE" ),
         NewFunctionC( "CLOSE_FILE", 1L, "fid",
                    FuncCLOSE_FILE ) );

    InitHandlerFunc( FuncINPUT_TEXT_FILE, "INPUT_TEXT_FILE" );
    AssGVar( GVarName( "INPUT_TEXT_FILE" ),
         NewFunctionC( "INPUT_TEXT_FILE", 1L, "filename",
                    FuncINPUT_TEXT_FILE ) );

    InitHandlerFunc( FuncIS_END_OF_FILE, "IS_END_OF_FILE" );
    AssGVar( GVarName( "IS_END_OF_FILE" ),
         NewFunctionC( "IS_END_OF_FILE", 1L, "fid",
                    FuncIS_END_OF_FILE ) );

    InitHandlerFunc( FuncPOSITION_FILE, "POSITION_FILE" );
    AssGVar( GVarName( "POSITION_FILE" ),
         NewFunctionC( "POSITION_FILE", 1L, "fid",
                    FuncPOSITION_FILE ) );

    InitHandlerFunc( FuncREAD_BYTE_FILE, "READ_BYTE_FILE" );
    AssGVar( GVarName( "READ_BYTE_FILE" ),
         NewFunctionC( "READ_BYTE_FILE", 1L, "fid",
                    FuncREAD_BYTE_FILE ) );

    InitHandlerFunc( FuncREAD_LINE_FILE, "READ_LINE_FILE" );
    AssGVar( GVarName( "READ_LINE_FILE" ),
         NewFunctionC( "READ_LINE_FILE", 1L, "fid",
                    FuncREAD_LINE_FILE ) );

    InitHandlerFunc( FuncSEEK_POSITION_FILE, "SEEK_POSITION_FILE" );
    AssGVar( GVarName( "SEEK_POSITION_FILE" ),
         NewFunctionC( "SEEK_POSITION_FILE", 2L, "fid, pos",
                    FuncSEEK_POSITION_FILE ) );
}


/****************************************************************************
**

*E  streams.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
