/****************************************************************************
**
*W  gap.c                       GAP source                       Frank Celler
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the various read-eval-print loops and  related  stuff.
*/
#include        <stdio.h>
#include        <setjmp.h>              /* jmp_buf, setjmp, longjmp        */

#include        "system.h"              /* system dependent part           */

SYS_CONST char * Revision_gap_c =
   "@(#)$Id$";

extern char * In;

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
#include        "permutat.h"            /* permutations                    */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "listoper.h"            /* operations for generic lists    */
#include        "listfunc.h"            /* functions for generic lists     */
#include        "plist.h"               /* plain lists                     */
#include        "set.h"                 /* plain sets                      */
#include        "vector.h"              /* functions for plain vectors     */
#include        "blister.h"             /* boolean lists                   */
#include        "range.h"               /* ranges                          */
#include        "string.h"              /* strings                         */

#include        "objfgelm.h"            /* objects of free groups          */
#include        "objpcgel.h"            /* objects of polycyclic groups    */
#include        "objscoll.h"            /* single collector                */
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
*V  BreakOnError  . . . . . . . . . . . . . . . . . . . . . . enter breakloop
*/
UInt BreakOnError = 1;


/****************************************************************************
**

*F  ViewObjHandler  . . . . . . . . . handler to view object and catch errors
*/
UInt ViewObjGVar;

void ViewObjHandler ( Obj obj )
{
    volatile Obj        func;
    jmp_buf             readJmpError;

    /* get the function                                                    */
    func = ValAutoGVar(ViewObjGVar);

    /* if non-zero use this function, otherwise use `PrintObj'             */
    memcpy( readJmpError, ReadJmpError, sizeof(jmp_buf) );
    if ( ! READ_ERROR() ) {
        if ( func == 0 || TNUM_OBJ(func) != T_FUNCTION ) {
            PrintObj(obj);
        }
        else {
            CALL_1ARGS( func, obj );
        }
        Pr( "\n", 0L, 0L );
        memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
    }
    else {
        memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
    }
}


/****************************************************************************
**
*F  main( <argc>, <argv> )  . . . . . . .  main program, read-eval-print loop
*/
Obj AtExitFunctions;

int main (
    int                 argc,
    char *              argv [] )
{
    UInt                type;                   /* type of command         */
    UInt                time;                   /* start time              */
    Obj                 func;                   /* function (compiler)     */
    Int4                crc;                    /* crc of file to compile  */
    volatile UInt       i;                      /* loop variable           */

    /* initialize everything                                               */
    InitializeGap( &argc, argv );

    /* maybe compile                                                       */
    if ( SyCompilePlease ) {
        if ( ! OpenInput(SyCompileInput) ) {
            SyExit(1);
        }
        func = READ_AS_FUNC();
        crc  = SyGAPCRC(SyCompileInput);
        type = CompileFunc( SyCompileOutput,
                            func,
                            SyCompileName,
                            crc,
                            SyCompileMagic1 );
        if ( type == 0 )
            SyExit( 1 );
        SyExit( 0 );
    }

    /* read-eval-print loop                                                */
    while ( 1 ) {

        /* start the stopwatch                                             */
        time = SyTime();

        /* read and evaluate one command                                   */
        Prompt = "gap> ";
        ClearError();
        type = ReadEvalCommand();

        /* stop the stopwatch                                              */
        AssGVar( Time, INTOBJ_INT( SyTime() - time ) );

        /* handle ordinary command                                         */
        if ( type == 0 && ReadEvalResult != 0 ) {

            /* remember the value in 'last' and the time in 'time'         */
            AssGVar( Last3, VAL_GVAR( Last2 ) );
            AssGVar( Last2, VAL_GVAR( Last  ) );
            AssGVar( Last,  ReadEvalResult   );

            /* print the result                                            */
            if ( ! DualSemicolon ) {
                ViewObjHandler( ReadEvalResult );
            }
        }

        /* handle return-value or return-void command                      */
        else if ( type == 1 || type == 2 ) {
            Pr( "'return' must not be used in main read-eval-print loop",
                0L, 0L );
        }

        /* handle quit command or <end-of-file>                            */
        else if ( type == 8 || type == 16 ) {
            break;
        }

    }

    /* call the exit functions                                             */
    BreakOnError = 0;
    for ( i = 1;  i <= LEN_PLIST(AtExitFunctions);  i++ ) {
        if ( setjmp(ReadJmpError) == 0 ) {
            func = ELM_PLIST( AtExitFunctions, i );
            CALL_0ARGS(func);
        }
    }

    /* exit to the operating system, the return is there to please lint    */
    SyExit(0);
    return 0;
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
    while ( ! IS_LIST(args) || 1 < LEN_LIST(args) ) {
        args = ErrorReturnObj(
            "Function: number of arguments must be 0 or 1 (not %d)",
            LEN_LIST(args), 0L,
            "you can return a list of arguments" );
    }

    /* get the arguments                                                   */
    if ( LEN_LIST(args) == 0 ) {
        size = NEW_PLIST( T_PLIST, 0 );
        SET_LEN_PLIST( size, 0 );
    }

    /* otherwise check the argument                                        */
    else {
        size = ELM_LIST( args, 1 );
        while ( ! IS_LIST(size) || 2 < LEN_LIST(size) ) {
            size = ErrorReturnObj(
                "SizeScreen: <size> must be a list of length 2",
                0L, 0L,
                "you can return a new list for <size>" );
        }
    }

    /* extract the length                                                  */
    if ( LEN_LIST(size) < 1 || ELM0_LIST(size,1) == 0 ) {
        len = SyNrCols;
    }
    else {
        elm = ELMW_LIST(size,1);
        while ( TNUM_OBJ(elm) != T_INT ) {
            elm = ErrorReturnObj(
                "SizeScreen: <x> must be an integer",
                0L, 0L,
                "you can return a new integer for <x>" );
        }
        len = INT_INTOBJ( elm );
        if ( len < 20  )  len = 20;
        if ( 256 < len )  len = 256;
    }

    /* extract the number                                                  */
    if ( LEN_LIST(size) < 2 || ELM0_LIST(size,2) == 0 ) {
        nr = SyNrRows;
    }
    else {
        elm = ELMW_LIST(size,2);
        while ( TNUM_OBJ(elm) != T_INT ) {
            elm = ErrorReturnObj(
                "SizeScreen: <y> must be an integer",
                0L, 0L,
                "you can return a new integer for <y>" );
        }
        nr = INT_INTOBJ( elm );
        if ( nr < 10 )  nr = 10;
    }

    /* set length and number                                               */
    SyNrCols = len;
    SyNrRows = nr;

    /* make and return the size of the screen                              */
    size = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( size, 2 );
    SET_ELM_PLIST( size, 1, INTOBJ_INT(len) );
    SET_ELM_PLIST( size, 2, INTOBJ_INT(nr)  );
    return size;

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
Obj  ErrorLVars;
Int  ErrorLLevel;

extern Obj BottomLVars;


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
    if ( ErrorLVars == 0 ) {
        Pr( "not in any function\n", 0L, 0L );
        return 0;
    }

    /* if we really want to go up                                          */
    if ( depth < 0 && -ErrorLLevel <= -depth ) {
        depth = 0;
        ErrorLVars = ErrorLVars0;
        ErrorLLevel = 0;
    }
    else if ( depth < 0 ) {
        depth = -ErrorLLevel + depth;
        ErrorLVars = ErrorLVars0;
        ErrorLLevel = 0;
    }

    /* now go down                                                         */
    while ( 0 < depth
         && ErrorLVars != BottomLVars
         && PTR_BAG(ErrorLVars)[2] != BottomLVars ) {
        ErrorLVars = PTR_BAG(ErrorLVars)[2];
        ErrorLLevel--;
        depth--;
    }

    /* return nothing                                                      */
    return 0;
}


/****************************************************************************
**
*F  FuncWhere( <self>, <depth> )  . . . . . . . . . . . .  print stack frames
*/
Obj FuncWhere (
    Obj                 self,
    Obj                 args )
{
    Obj                 currLVars;
    Int                 depth;
    Expr                call;

#ifndef NO_BRK_CALLS

    /* evaluate the argument                                               */
    if ( LEN_LIST(args) == 0 ) {
        depth = 10;
    }
    else if ( LEN_LIST(args) == 1 && IS_INTOBJ( ELM_PLIST(args,1) ) ) {
        depth = INT_INTOBJ( ELM_PLIST( args, 1 ) );
    }
    else {
        ErrorQuit( "usage: Where( [ <depth> ] )", 0L, 0L );
        return 0;
    }

    currLVars = CurrLVars;

    if ( ErrorLVars != 0 ) {
        SWITCH_TO_OLD_LVARS( ErrorLVars );
        SWITCH_TO_OLD_LVARS( BRK_CALL_FROM() );
        while ( CurrLVars != BottomLVars && 0 < depth ) {
            call = BRK_CALL_TO();
            if ( call == 0 ) {
                Pr( "<corrupted call value> ", 0L, 0L );
            }
#if T_PROCCALL_0ARGS
            else if ( T_PROCCALL_0ARGS <= TNUM_STAT(call)
                   && TNUM_STAT(call)  <= T_PROCCALL_XARGS ) {
#else
            else if ( TNUM_STAT(call)  <= T_PROCCALL_XARGS ) {
#endif
                PrintStat( call );
            }
            else if ( T_FUNCCALL_0ARGS <= TNUM_EXPR(call)
                   && TNUM_EXPR(call)  <= T_FUNCCALL_XARGS ) {
                PrintExpr( call );
            }
            Pr( " called from\n", 0L, 0L );
            SWITCH_TO_OLD_LVARS( BRK_CALL_FROM() );
            depth--;
        }
        if ( 0 < depth ) {
            Pr( "<function>( <arguments> ) called from read-eval-loop\n",
                0L, 0L );
        }
        else {
            Pr( "...\n", 0L, 0L );
        }
    }
    else {
        Pr( "not in any function\n", 0L, 0L );
    }

    SWITCH_TO_OLD_LVARS( currLVars );

#endif

    return 0;
}


/****************************************************************************
**
*F  ErrorMode( <msg>, <arg1>, <arg2>, <args>, <msg2>, <mode> )
*/
Obj ErrorMode (
    SYS_CONST Char *    msg,
    Int                 arg1,
    Int                 arg2,
    Obj                 args,
    SYS_CONST Char *    msg2,
    Char                mode )
{
    Obj                 errorLVars0;
    Obj                 errorLVars;
    UInt                errorLLevel;
    UInt                type;
    char                prompt [16];

    /* ignore all errors when testing or quitting                          */
    if ( ( TestInput != 0 && TestOutput == Output ) || ! BreakOnError ) {
        if ( msg != (Char*)0 ) {
            Pr( msg, arg1, arg2 );
        }
        else if ( args != (Obj)0 ) {
            Pr( "Error ", 0L, 0L );
            FuncPrint( (Obj)0, args );
        }
        Pr( "\n", 0L, 0L );
        ReadEvalError();
    }

    /* open the standard error output file                                 */
    OpenOutput( "*errout*" );
    ErrorLevel += 1;
    errorLVars0 = ErrorLVars0;
    ErrorLVars0 = CurrLVars;
    errorLVars  = ErrorLVars;
    ErrorLVars  = CurrLVars;
    errorLLevel = ErrorLLevel;
    ErrorLLevel = 0;

    /* print the error message                                             */
    if ( msg != (Char*)0 ) {
        Pr( msg, arg1, arg2 );
    }
    else if ( args != (Obj)0 ) {
        Pr( "Error ", 0L, 0L );
        FuncPrint( (Obj)0, args );
    }

    /* print the location                                                  */
    if ( CurrStat != 0 ) {
        Pr( " at\n", 0L, 0L );
        PrintStat( CurrStat );
        Pr( "\n", 0L, 0L );
    }
    else {
        Pr( "\n", 0L, 0L );
    }

    /* try to open input for a break loop                                  */
    if ( mode == 'q' || ! OpenInput( "*errin*") ) {
        ErrorLevel -= 1;
        ErrorLVars0 = errorLVars0;
        ErrorLVars = errorLVars;
        ErrorLLevel = errorLLevel;
        CloseOutput();
        ReadEvalError();
    }
    ClearError();

    /* print the sencond message                                           */
    Pr( "Entering break read-eval-print loop, ", 0L, 0L );
    Pr( "you can 'quit;' to quit to outer loop,\n", 0L, 0L );
    Pr( "or %s to continue\n", (Int)msg2, 0L );

    /* read-eval-print loop                                                */
    while ( 1 ) {

        /* read and evaluate one command                                   */
        if ( ErrorLevel == 1 ) {
            Prompt = "brk> ";
        }
        else {
            prompt[0] = 'b';
            prompt[1] = 'r';
            prompt[2] = 'k';
            prompt[3] = '_';
            prompt[4] = ErrorLevel / 10 + '0';
            prompt[5] = ErrorLevel % 10 + '0';
            prompt[6] = '>';
            prompt[7] = ' ';
            prompt[8] = '\0';
            Prompt = prompt;
        }

        /* read and evaluate one command                                   */
        ClearError();
        DualSemicolon = 0;
        type = ReadEvalCommand();

        /* handle ordinary command                                         */
        if ( type == 0 && ReadEvalResult != 0 ) {

            /* remember the value in 'last'                                */
            AssGVar( Last,  ReadEvalResult   );

            /* print the result                                            */
            if ( ! DualSemicolon ) {
                ViewObjHandler( ReadEvalResult );
            }

        }

        /* handle return-value                                             */
        else if ( type == 1 ) {
            if ( mode == 'v' ) {
                ErrorLevel -= 1;
                ErrorLVars0 = errorLVars0;
                ErrorLVars = errorLVars;
                ErrorLLevel = errorLLevel;
                CloseInput();
                ClearError();
                CloseOutput();
                return ReadEvalResult;
            }
            else {
                Pr( "'return <value>;' cannot be used in this break-loop\n",
                    0L, 0L );
            }
        }

        /* handle return-value                                             */
        else if ( type == 2 ) {
            if ( mode == 'x' ) {
                ErrorLevel -= 1;
                ErrorLVars0 = errorLVars0;
                ErrorLVars = errorLVars;
                ErrorLLevel = errorLLevel;
                CloseInput();
                ClearError();
                CloseOutput();
                return (Obj)0;
            }
            else {
                Pr( "'return;' cannot be used in this break-loop\n",
                    0L, 0L );
            }
        }

        /* handle quit command or <end-of-file>                            */
        else if ( type == 8 || type == 16 ) {
            break;
        }

    }

    /* return to the outer read-eval-print loop                            */
    ErrorLevel -= 1;
    ErrorLVars0 = errorLVars0;
    ErrorLVars = errorLVars;
    ErrorLLevel = errorLLevel;
    CloseInput();
    ClearError();
    CloseOutput();
    ReadEvalError();

    /* this is just to please GNU cc, 'ReadEvalError' never returns        */
    return 0;
}


/****************************************************************************
**
*F  ErrorQuit( <msg>, <arg1>, <arg2> )  . . . . . . . . . . .  print and quit
*/
void ErrorQuit (
    SYS_CONST Char *    msg,
    Int                 arg1,
    Int                 arg2 )
{
    ErrorMode( msg, arg1, arg2, (Obj)0, (Char*)0, 'q' );
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
*F  ErrorReturnObj( <msg>, <arg1>, <arg2>, <msg2> ) . .  print and return obj
*/
Obj ErrorReturnObj (
    SYS_CONST Char *    msg,
    Int                 arg1,
    Int                 arg2,
    SYS_CONST Char *    msg2 )
{
    return ErrorMode( msg, arg1, arg2, (Obj)0, msg2, 'v' );
}


/****************************************************************************
**
*F  ErrorReturnVoid( <msg>, <arg1>, <arg2>, <msg2> )  . . .  print and return
*/
void ErrorReturnVoid (
    SYS_CONST Char *    msg,
    Int                 arg1,
    Int                 arg2,
    SYS_CONST Char *    msg2 )
{
    ErrorMode( msg, arg1, arg2, (Obj)0, msg2, 'x' );
}


/****************************************************************************
**
*F  FuncError( <self>, <args> ) . . . . . . . . . . . . . . . signal an error
**
*/
Obj FuncError (
    Obj                 self,
    Obj                 args )
{
    return ErrorMode( (Char*)0, 0L, 0L, args, "you can return", 'x' );
}


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
                "Error, crc value of \"%s\" does not match completion file",
                (Int)CSTR_STRING(filename), 0L );
            return;
        }
    }

    /* try to open the file                                                */
    if ( ! OpenInput( CSTR_STRING(filename) ) ) {
        return;
    }
    ClearError();

    /* we are now completing                                               */
    if ( SyDebugLoading ) {
        Pr( "#I  completing '%s'\n", (Int)CSTR_STRING(filename), 0L );
    }
    CompNowFuncs = list;
    CompNowCount = COMP_THEN_OFFSET;

    /* now do the reading                                                  */
    while ( 1 ) {
        type = ReadEvalCommand();
        if ( type == 1 || type == 2 ) {
            Pr( "'return' must not be used in file read-eval loop",
                0L, 0L );
        }
        else if ( type == 8 || type == 16 ) {
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
    if ( HDLR_FUNC( self, 0 ) == DoComplete0args ) {
        ErrorQuit(
            "panic: completion did not define function",
            0L, 0L );
        return 0;
    }
    return CALL_0ARGS( self );
}

Obj DoComplete1args (
    Obj                 self,
    Obj                 arg1 )
{
    COMPLETE_FUNC( self );
    if ( HDLR_FUNC( self, 1 ) == DoComplete1args ) {
        ErrorQuit(
            "panic: completion did not define function",
            0L, 0L );
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
    if ( HDLR_FUNC( self, 2 ) == DoComplete2args ) {
        ErrorQuit(
            "panic: completion did not define function",
            0L, 0L );
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
    if ( HDLR_FUNC( self, 3 ) == DoComplete3args ) {
        ErrorQuit(
            "panic: completion did not define function",
            0L, 0L );
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
    if ( HDLR_FUNC( self, 4 ) == DoComplete4args ) {
        ErrorQuit(
            "panic: completion did not define function",
            0L, 0L );
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
    if ( HDLR_FUNC( self, 5 ) == DoComplete5args ) {
        ErrorQuit(
            "panic: completion did not define function",
            0L, 0L );
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
    if ( HDLR_FUNC( self, 6 ) == DoComplete6args ) {
        ErrorQuit(
            "panic: completion did not define function",
            0L, 0L );
        return 0;
    }
    return CALL_6ARGS( self, arg1, arg2, arg3, arg4, arg5, arg6 );
}

Obj DoCompleteXargs (
    Obj                 self,
    Obj                 args )
{
    COMPLETE_FUNC( self );
    if ( HDLR_FUNC( self, 7 ) == DoCompleteXargs ) {
        ErrorQuit(
            "panic: completion did not define function",
            0L, 0L );
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
    StructCompInitInfo* info;
    Int4                crc1;
    Int4                crc2;
    Char                result[256];
    Int                 res;
    Obj                 func;


    /* check the argument                                                  */
    while ( ! IsStringConv(filename) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    while ( ! IS_INTOBJ(crc) ) {
        crc = ErrorReturnObj(
            "<crc> must be a small integer (not a %s)",
            (Int)TNAM_OBJ(crc), 0L,
            "you can return an integer for <crc>" );
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
        info = *(StructCompInitInfo**)result;
        (info->link)();
        func = (Obj)(info->function1)();
        CALL_0ARGS(func);
        return INTOBJ_INT(1);
    }

    /* statically linked                                                   */
    else if ( res == 2 ) {
        if ( SyDebugLoading ) {
            Pr( "#I  READ_GAP_ROOT: loading '%s' statically\n",
                (Int)CSTR_STRING(filename), 0L );
        }
        info = *(StructCompInitInfo**)result;
        (info->link)();
        func = (Obj)(info->function1)();
        CALL_0ARGS(func);
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
        filename = NEW_STRING( SyStrlen(result) );
        SyStrncat( CSTR_STRING(filename), result, SyStrlen(result) );

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
        func = NewFunctionCT( T_FUNCTION, SIZE_FUNC, "", -1, "uncompleted",
                              0L );
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
*/
#define MAKE_INIT_GET_SYMBOL                    \
    do {                                        \
        symbol = Symbol;                        \
        value[0] = '\0';                        \
        SyStrncat( value, Value, 1023 );        \
        if ( Symbol != S_EOF )  GetSymbol();    \
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

        memcpy( readJmpError, ReadJmpError, sizeof(jmp_buf) );
        if ( READ_ERROR() ) {
            memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );
            CloseInput();
            CloseOutput();
            ReadEvalError();
        }
        memcpy( ReadJmpError, readJmpError, sizeof(jmp_buf) );

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
        else if ( symbol == S_IDENT && Symbol == S_MAPTO ) {
            Pr( "COM_FUN(%d)", funcNum++, 0L );
            symbol = Symbol;  if ( Symbol != S_EOF )  GetSymbol();
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
            case S_DOTDOT:   Pr( "..",      0L, 0L );  break;

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
            "you can return a string for <filename>" );
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
    CompInitFunc        init;
    StructCompInitInfo* info;
    Obj                 crc1;
    Obj                 func;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    while ( ! IS_INTOBJ(crc) && crc!=False ) {
        crc = ErrorReturnObj(
            "<crc> must be a small integer or 'false' (not a %s)",
            (Int)TNAM_OBJ(crc), 0L,
            "you can return a small integer or 'false' for <crc>" );
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
        crc1 = INTOBJ_INT( info->magic1 );
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
    (info->link)();
    func = (Obj)(info->function1)();
    CALL_0ARGS(func);

    RecordLoadedModule(filename, INT_INTOBJ(crc));  
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
    StructCompInitInfo* info;
    Obj                 crc1;
    Int                 k;
    Obj                 func;

    /* check the argument                                                  */
    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can return a string for <filename>" );
    }
    while ( !IS_INTOBJ(crc) && crc!=False ) {
        crc = ErrorReturnObj(
            "<crc> must be a small integer or 'false' (not a %s)",
            (Int)TNAM_OBJ(crc), 0L,
            "you can return a small integer or 'false' for <crc>" );
    }

    /* try to find the module                                              */
    for ( k = 0;  CompInitFuncs[k];  k++ ) {
        info = (*(CompInitFuncs[k]))();
        if ( info == 0 ) {
            continue;
        }
        if ( ! SyStrcmp( CSTR_STRING(filename), info->magic2 ) ) {
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
        crc1 = INTOBJ_INT( info->magic1 );
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
    (info->link)();
    func = (Obj)(info->function1)();
    CALL_0ARGS(func);

    RecordLoadedModule(filename, INT_INTOBJ(crc));  

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
    Obj                 crc1;
    Obj                 name;
    StructCompInitInfo* info;
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
        name = NEW_STRING( SyStrlen(info->magic2) );
        SyStrncat( CSTR_STRING(name), info->magic2, SyStrlen(info->magic2) );
        SET_ELM_PLIST( modules, im, name );

        /* compute the crc value                                           */
        crc1 = INTOBJ_INT( info->magic1 );
        SET_ELM_PLIST( modules, im+1, crc1 );
        im += 2;
    }

    return modules;
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
    while ( ! IS_LIST(args) || LEN_LIST(args) == 0 ) {
        args = ErrorReturnObj(
            "usage: GASMAN( \"display\"|\"clear\"|\"collect\"|\"message\" )",
            0L, 0L,
            "you can return a list of arguments" );
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
               "you can return a string for <cmd>" );
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
                "you can return a new string for <cmd>" );
            goto again;
        }
    }

    /* return nothing, this function is a procedure                        */
    return 0;
}


/****************************************************************************
**
*F  FuncSHALLOW_SIZE( <self>, <obj> ) . . . .  expert function 'SHALLOW_SIZE'
*/
Obj FuncSHALLOW_SIZE (
    Obj                 self,
    Obj                 obj )
{
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
    SYS_CONST Char *    cst;

    res = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( res, 2 );

    /* set the type                                                        */
    SET_ELM_PLIST( res, 1, INTOBJ_INT( TNUM_OBJ(obj) ) );
    cst = TNAM_OBJ(obj);
    str = NEW_STRING( SyStrlen(cst) );
    SyStrncat( CSTR_STRING(str), cst, SyStrlen(cst) );
    SET_ELM_PLIST( res, 2, str );

    /* and return                                                          */
    return res;
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
    UInt                xtype;
    SYS_CONST Char *    cst;

    res = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( res, 2 );

    /* set the type                                                        */
    xtype = XTNum(obj);
    SET_ELM_PLIST( res, 1, INTOBJ_INT(xtype) );
    if ( xtype == T_OBJECT ) {
        cst = "virtual object";
    }
    else if ( xtype == T_MAT_CYC ) {
        cst = "virtual mat cyc";
    }
    else if ( xtype == T_MAT_FFE ) {
        cst = "virtual mat ffe";
    }
    else {
        cst = InfoBags[xtype].name;
    }
    str = NEW_STRING( SyStrlen(cst) );
    SyStrncat( CSTR_STRING(str), cst, SyStrlen(cst) );
    SET_ELM_PLIST( res, 2, str );

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

*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/
static UInt   ImportedGVars [1024];
static Obj *  ImportedGVarAddrs [1024];
static UInt   NrImportedGVars = 0;


void ImportGVarFromLibrary(
    SYS_CONST Char *    name,
    Obj *               address )
{
    if ( NrImportedGVars == 1024 ) {
        if ( ! SyQuiet ) {
            Pr( "#W  warning: too many imported GVars\n", 0L, 0L );
        }
        if ( address != 0 ) {
            InitCopyGVar( (Char *)name, address );
        }
    }
    else {
        ImportedGVars[NrImportedGVars]     = GVarName(name);
        ImportedGVarAddrs[NrImportedGVars] = address;
        if ( address != 0 ) {
            InitCopyGVar( (Char *)name, address );
        }
        NrImportedGVars++;
    }
}


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/
static UInt   ImportedFuncs [1024];
static Obj *  ImportedFuncAddrs [1024];
static UInt   NrImportedFuncs = 0;


void ImportFuncFromLibrary(
    SYS_CONST Char *    name,
    Obj *               address )
{
    if ( NrImportedFuncs == 1024 ) {
        if ( ! SyQuiet ) {
            Pr( "#W  warning: too many imported Funcs\n", 0L, 0L );
        }
        if ( address != 0 ) {
            InitFopyGVar( (Char *)name, address );
        }
    }
    else {
        ImportedFuncs[NrImportedFuncs]     = GVarName(name);
        ImportedFuncAddrs[NrImportedFuncs] = address;
        if ( address != 0 ) {
            InitFopyGVar( (Char *)name, address );
        }
        NrImportedFuncs++;
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

    for ( i = 0;  i < NrImportedGVars;  i++ ) {
        if (  ImportedGVarAddrs[i] == 0 ) {
            val = ValAutoGVar(ImportedGVars[i]);
            if ( val == 0 ) {
                errs++;
                if ( ! SyQuiet ) {
                    Pr( "#W  global variable '%s' has not been defined\n",
                        (Int)NameGVar(ImportedFuncs[i]), 0L );
                }
            }
        }
        else if ( *ImportedGVarAddrs[i] == 0 ) {
            errs++;
            if ( ! SyQuiet ) {
                Pr( "#W  global variable '%s' has not been defined\n",
                    (Int)NameGVar(ImportedGVars[i]), 0L );
            }
        }
        else {
            MakeReadOnlyGVar(ImportedGVars[i]);
        }
    }
    
    for ( i = 0;  i < NrImportedFuncs;  i++ ) {
        if (  ImportedFuncAddrs[i] == 0 ) {
            val = ValAutoGVar(ImportedFuncs[i]);
            if ( val == 0 || TNUM_OBJ(val) != T_FUNCTION ) {
                errs++;
                if ( ! SyQuiet ) {
                    Pr( "#W  global function '%s' has not been defined\n",
                        (Int)NameGVar(ImportedFuncs[i]), 0L );
                }
            }
        }
        else if ( *ImportedFuncAddrs[i] == ErrorMustEvalToFuncFunc
          || *ImportedFuncAddrs[i] == ErrorMustHaveAssObjFunc )
        {
            errs++;
            if ( ! SyQuiet ) {
                Pr( "#W  global function '%s' has not been defined\n",
                    (Int)NameGVar(ImportedFuncs[i]), 0L );
            }
        }
        else {
            MakeReadOnlyGVar(ImportedFuncs[i]);
        }
    }
    
    return errs == 0 ? True : False;
}


/****************************************************************************
**
*V  Revisions . . . . . . . . . . . . . . . . . .  record of revision numbers
*/
Obj Revisions;


/****************************************************************************
**
*F  SetupGap()  . . . . . . . . . . . . . . . . . . . . setup internal tables
**
**  - setup any tables like gasman marking functions, gasman bag names,  list
**    dispatchers, list filter maps, etc.
**
**  - do not create *any* new bag, global variable, fopies or copies, rnams.
**
**  After the setup the basic stuff of each package  should work, for example
**  it  should be possible  to create  and  handle  plain lists  and records.
**  However, functions like  "type of  list" will  not yet  work because they
**  need to interact with library, `OnePerm' will not work because it needs a
**  global `()' permutation.
*/
void SetupGap ( void )
{
    UInt                i;

    /* global variables                                                    */
    SetupGVars();

    /* objects                                                             */
    SetupObjects();

    /* scanner, reader, interpreter, coder, caller, compiler               */
    SetupScanner();
    SetupRead();
    SetupCalls();
    SetupExprs();
    SetupStats();
    SetupCode();
    SetupVars(); /* must come after InitExpr and InitStats */
    SetupFuncs();
    SetupOpers();
    SetupIntrprtr();
    SetupCompiler();

    /* arithmetic operations                                               */
    SetupAriths();
    SetupInt();
    SetupRat();
    SetupCyc();
    SetupFinfield();
    SetupPermutat();
    SetupBool();

    /* record packages                                                     */
    SetupRecords();
    SetupPRecord();

    /* list packages                                                       */
    SetupLists();
    SetupListOper();
    SetupListFunc();
    SetupPlist();
    SetupSet();
    SetupVector();
    SetupBlist();
    SetupRange();
    SetupString();

    /* free and presented groups                                           */
    SetupFreeGroupElements();
    SetupCosetTable();
    SetupTietze();
    SetupPcElements();
    SetupSingleCollector();
    SetupPcc();
    SetupDeepThought();
    SetupDTEvaluation();

    /* algebras                                                            */
    SetupSCTable();

    /* input and output                                                    */
    SetupStreams();

    /* save and load workspace, weak pointers                              */
    SetupWeakPtr();
    SetupSaveLoad();


    /* you should set 'COUNT_BAGS' as well                                 */
#ifdef DEBUG_RESTORE
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
#endif
}


/****************************************************************************
**
*F  InitGap() . . . . . . . . . . . . . . . . . . . . initialise the packages
**
**  - create any global bags needed,
**  - export handlers, setup GAP functions, import library functions,
**  - initialise fopies and copies,
**  - assign global variables,
**  - precompute record names
**
**  This  step   is allowed  to  create new  bags.  If   we are restoring the
**  creating part will be skipped.
*/
void InitGap ( void )
{
    Char *              version = "v4r0p0 1996/06/06";
    Obj                 string;
    UInt                i;
    UInt                var;

    /* global variables                                                    */
    InitGVars();

    /* objects                                                             */
    InitObjects();

    /* scanner, reader, interpreter, coder, caller, compiler               */
    InitScanner();
    InitRead();
    InitCalls();
    InitExprs();
    InitStats();
    InitCode();
    InitVars(); /* must come after InitExpr and InitStats */
    InitFuncs();
    InitOpers();
    InitIntrprtr();
    InitCompiler();

    /* arithmetic operations                                               */
    InitAriths();
    InitInt();
    InitRat();
    InitCyc();
    InitFinfield();
    InitPermutat();
    InitBool();


    /* record packages                                                     */
    InitRecords();
    InitPRecord();

    /* list packages                                                       */
    InitLists();
    InitListOper();
    InitListFunc();
    InitPlist();
    InitSet();
    InitVector();
    InitBlist();
    InitRange();
    InitString();

    /* free and presented groups                                           */
    InitFreeGroupElements();
    InitCosetTable();
    InitTietze();
    InitPcElements();
    InitSingleCollector();
    InitPcc();
    InitDeepThought();
    InitDTEvaluation();

    /* algebras                                                            */
    InitSCTable();

    /* input and output                                                    */
    InitStreams();

    /* save and load workspace, weak pointers                              */
    InitSaveLoad();
    InitWeakPtr();
    InitSysFiles();

    /* init the completion function                                        */
    InitGlobalBag( &CompNowFuncs,  "src/gap.c:CompNowFuncs"  );
    InitGlobalBag( &CompThenFuncs, "src/gap.c:CompThenFuncs" );
    InitGlobalBag( &CompLists,     "src/gap.c:CompLists"     );
    if ( ! SyRestoring ) {
        CompLists = NEW_PLIST( T_PLIST, 0 );
        SET_LEN_PLIST( CompLists, 0 );
    }


    /* construct the `ViewObj' variable                                    */
    ViewObjGVar = GVarName( "ViewObj" );
    ImportFuncFromLibrary(  "ViewObj", 0L ); 

    /* construct the last and time variables                               */
    Last  = GVarName( "last"  );
    Last2 = GVarName( "last2" );
    Last3 = GVarName( "last3" );
    Time  = GVarName( "time"  );


    /* version info                                                        */
    if ( ! SyRestoring ) {
        string = NEW_STRING( SyStrlen(version) );
        SyStrncat( CSTR_STRING(string), version, SyStrlen(version) );
        var = GVarName( "VERSRC" );
        AssGVar( var, string );
        MakeReadOnlyGVar(var);
        string = NEW_STRING( SyStrlen(SyFlags) );
        SyStrncat( CSTR_STRING(string), SyFlags, SyStrlen(SyFlags) );
        var = GVarName( "VERSYS" );
        AssGVar( var, string );
        MakeReadOnlyGVar(var);
    }


    /* library name and other stuff                                        */
    if ( ! SyRestoring ) {
        var = GVarName( "QUIET" );
        AssGVar( var, (SyQuiet  ? True : False) );
        MakeReadOnlyGVar(var);

        var = GVarName( "BANNER" );
        AssGVar( var, (SyBanner ? True : False) );
        MakeReadOnlyGVar(var);

        var = GVarName( "DEBUG_LOADING" );
        AssGVar( var, (SyDebugLoading ? True : False) );
        MakeReadOnlyGVar(var);

        var = GVarName( "CHECK_FOR_COMP_FILES" );
        AssGVar( var, (SyCheckForCompletion ? True : False) );
        MakeReadOnlyGVar(var);
    }


    /* list of exit functions                                              */
    InitGlobalBag( &AtExitFunctions, "src/gap.c:AtExitFunctions" );
    if ( ! SyRestoring ) {
        AtExitFunctions = NEW_PLIST( T_PLIST, 0 );
        SET_LEN_PLIST( AtExitFunctions, 0 );
        var = GVarName( "AT_EXIT_FUNCS" );
        AssGVar( var, AtExitFunctions );
        MakeReadOnlyGVar(var);
    }


    /* init handlers                                                       */
    InitHandlerFunc( DoComplete0args, "src/gap.c:DoComplete0args" );
    InitHandlerFunc( DoComplete1args, "src/gap.c:DoComplete1args" );
    InitHandlerFunc( DoComplete2args, "src/gap.c:DoComplete2args" );
    InitHandlerFunc( DoComplete3args, "src/gap.c:DoComplete3args" );
    InitHandlerFunc( DoComplete4args, "src/gap.c:DoComplete4args" );
    InitHandlerFunc( DoComplete5args, "src/gap.c:DoComplete5args" );
    InitHandlerFunc( DoComplete6args, "src/gap.c:DoComplete6args" );
    InitHandlerFunc( DoCompleteXargs, "src/gap.c:DoCompleteXargs" );


    /* install the internal functions                                      */
    C_NEW_GVAR_FUNC( "Runtime", 0L, "",
                  FuncRuntime,
           "src/gap.c:Runtime" );

    C_NEW_GVAR_FUNC( "SizeScreen", -1L, "args",
                  FuncSizeScreen,
           "src/gap.c:SizeScreen" );

    C_NEW_GVAR_FUNC( "ID_FUNC", 1L, "object",
                  FuncID_FUNC,
           "src/gap.c:ID_FUNC" );

    C_NEW_GVAR_FUNC( "ExportToKernelFinished", 0L, "",
                  FuncExportToKernelFinished,
           "src/gap.c:ExportToKernelFinished" );


    /* install the error functions                                         */
    C_NEW_GVAR_FUNC( "DownEnv", -1L, "args",
                  FuncDownEnv,
           "src/gap.c:DownEnv" );

    C_NEW_GVAR_FUNC( "Where", -1L, "args",
                  FuncWhere,
           "src/gap.c:Where" );

    C_NEW_GVAR_FUNC( "Error", -1L, "args",
                  FuncError,
           "src/gap.c:Error" );


    /* install the functions for creating the init file                    */
    C_NEW_GVAR_FUNC( "COM_FILE", 2L, "filename, crc",
                  FuncCOM_FILE,
           "src/gap.c:COM_FILE" );

    C_NEW_GVAR_FUNC( "COM_FUN", 1L, "number",
                    FuncCOM_FUN,
           "src/gap.c:COM_FUN" );

    C_NEW_GVAR_FUNC( "MAKE_INIT", 2L, "output, input",
                  FuncMAKE_INIT,
           "src/gap.c:MAKE_INIT" );


    /* install functions for dynamically/statically loadable modules       */
    C_NEW_GVAR_FUNC( "GAP_CRC", 1L, "filename",
                  FuncGAP_CRC,
           "src/gap.c:GAP_CRC" );

    C_NEW_GVAR_FUNC( "LOAD_DYN", 2L, "filename, crc",
                  FuncLOAD_DYN,
           "src/gap.c:LOAD_DYN" );

    C_NEW_GVAR_FUNC( "LOAD_STAT", 2L, "filename, crc",
                  FuncLOAD_STAT,
           "src/gap.c:LOAD_STAT" );

    C_NEW_GVAR_FUNC( "SHOW_STAT", 0L, "",
                  FuncSHOW_STAT,
           "src/gap.c:SHOW_STAT" );


    /* debugging functions                                                 */
    C_NEW_GVAR_FUNC( "GASMAN", -1L, "args",
                  FuncGASMAN,
           "src/gap.c:GASMAN" );

    C_NEW_GVAR_FUNC( "SHALLOW_SIZE", 1L, "object",
                  FuncSHALLOW_SIZE,
           "src/gap.c:SHALLOW_SIZE" );

    C_NEW_GVAR_FUNC( "TNUM_OBJ", 1L, "object",
                  FuncTNUM_OBJ,
           "src/gap.c:TNUM_OBJ" );

    C_NEW_GVAR_FUNC( "XTNUM_OBJ", 1L, "object",
                  FuncXTNUM_OBJ,
           "src/gap.c:XTNUM_OBJ" );

    C_NEW_GVAR_FUNC( "OBJ_HANDLE", 1L, "object",
                  FuncOBJ_HANDLE,
           "src/gap.c:OBJ_HANDLE" );

    C_NEW_GVAR_FUNC( "HANDLE_OBJ", 1L, "object",
                  FuncHANDLE_OBJ,
           "src/gap.c:HANDLE_OBJ" );

    C_NEW_GVAR_FUNC( "SWAP_MPTR", 2L, "obj1, obj2",
                  FuncSWAP_MPTR,
           "src/gap.c:SWAP_MPTR" );


    /* you should set 'COUNT_BAGS' as well                                 */
#ifdef DEBUG_RESTORE
    if ( SyRestoring ) {
        Pr( "#W  after init\n", 0L, 0L );
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
#endif
}


/****************************************************************************
**
*F  CheckGap()  . . . . . . . . . .  check the initialisation of the packages
**
**  Do any sanity checks.  For example, the  generic list package might check
**  that all  tables are filled, while the  arithmitic package  might want to
**  check that special packages didn't mess up the arithmitic tables.
**
**  This step  is optional.  It should not  fix errors without warnings, that
**  is to say,  if no warning or error  messages are produced then this  step
**  can be skipped.
*/
void CheckGap ( void )
{
    SET_REVISION( "gap_c",      Revision_gap_c    );
    SET_REVISION( "gap_h",      Revision_gap_h    );

    /* global variables                                                    */
    CheckGVars();

    /* scanner, reader, interpreter, coder, caller, compiler               */
    CheckScanner();
    CheckRead();
    CheckExprs();
    CheckStats();
    CheckCode();
    CheckCalls();
    CheckVars();
    CheckFuncs();
    CheckOpers();
    CheckIntrprtr();
    CheckCompiler();

    /* objects                                                             */
    CheckObjects();

    /* arithmetic operations                                               */
    CheckAriths();
    CheckInt();
    CheckRat();
    CheckCyc();
    CheckFinfield();
    CheckPermutat();
    CheckBool();

    /* record packages                                                     */
    CheckRecords();
    CheckPRecord();

    /* list packages                                                       */
    CheckLists();
    CheckListOper();
    CheckListFunc();
    CheckPlist();
    CheckSet();
    CheckVector();
    CheckBlist();
    CheckRange();
    CheckString();

    /* free and presented groups                                           */
    CheckFreeGroupElements();
    CheckCosetTable();
    CheckTietze();
    CheckPcElements();
    CheckSingleCollector();
    CheckPcc();
    CheckDeepThought();
    CheckDTEvaluation();

    /* algebras                                                            */
    CheckSCTable();

    /* input and output                                                    */
    CheckStreams();

    /* save and load workspace, weak pointers                              */
    CheckWeakPtr();
    CheckSaveLoad();

    /* check function handlers                                             */
#ifdef DEBUG_HANDLER_REGISTRATION
    CheckAllHandlers();
#endif
}


/****************************************************************************
**
*F  InitializeGap() . . . . . . . . . . . . . . . . . . . . . . intialize GAP
*/
extern TNumMarkFuncBags TabMarkFuncBags [ 256 ];

void InitializeGap (
    int *               pargc,
    char *              argv [] )
{
    UInt                type;
    UInt                i;
    UInt                var;


    /* initialize the basic system and gasman                              */
    InitSystem( *pargc, argv );

    InitBags( SyAllocBags, SyStorMin,
              0, (Bag*)pargc, SyStackAlign,
              SyCacheSize, 0, SyAbortBags );
    InitMsgsFuncBags( SyMsgsBags );


    /* setup internal tables                                               */
    SetupGap();


    /* and now for a special hack                                          */
    for ( i = LAST_CONSTANT_TNUM+1; i <= LAST_REAL_TNUM; i++ ) {
        TabMarkFuncBags[ i+COPYING ] = TabMarkFuncBags[ i ];
    }


    /* initialize packages                                                 */
    InitGap();


    /* check the initialisation of the packages                            */
    Revisions = NEW_PREC(0);
    var = GVarName( "Revision" );
    AssGVar( var, Revisions );
    MakeReadOnlyGVar(var);

    CheckGap();


    SET_REVISION( "system_c",   Revision_system_c );
    SET_REVISION( "system_h",   Revision_system_h );
    SET_REVISION( "gasman_c",   Revision_gasman_c );
    SET_REVISION( "gasman_h",   Revision_gasman_h );


    /* read the init files                                                 */
    if ( SySystemInitFile[0] ) {
        if ( READ_GAP_ROOT(SySystemInitFile) == 0 ) {
            if ( ! SyQuiet ) {
                Pr( "gap: hmm, I cannot find '%s' maybe",
                    (Int)SySystemInitFile, 0L );
                Pr( " use option '-l <gaproot>'?\n", 0L, 0L );
            }
        }
    }
    for ( i = 0; i < sizeof(SyInitfiles)/sizeof(SyInitfiles[0]); i++ ) {
        if ( SyInitfiles[i][0] != '\0' ) {
            if ( OpenInput( SyInitfiles[i] ) ) {
                ClearError();
                while ( 1 ) {
                    type = ReadEvalCommand();
                    if ( type == 1 || type == 2 ) {
                        Pr("'return' must not be used in file",0L,0L);
                    }
                    else if ( type == 8 || type == 16 ) {
                        break;
                    }
                }
                CloseInput();
                ClearError();
            }
            else {
                Pr( "Error, file \"%s\" must exist and be readable\n",
                    (Int)SyInitfiles[i], 0L );
            }
        }
    }
}


/****************************************************************************
**

*E  gap.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/






