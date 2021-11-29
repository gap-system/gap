/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains functions responsible for input and output processing.
**
**  These provide the concept of  a current input  and output file.   In the
**  main   module   they are opened  and   closed  with the  'OpenInput'  and
**  'CloseInput' respectively  'OpenOutput' and 'CloseOutput' calls.  All the
**  other modules just read from the  current input  and write to the current
**  output file.
**
**  This module relies on the functions  provided  by  the  operating  system
**  dependent module 'system.c' for the low level input/output.
*/

#include "io.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "error.h"
#include "gapstate.h"
#include "gaputils.h"
#include "gvars.h"
#include "listfunc.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "read.h"
#include "scanner.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "sysopt.h"
#include "sysstr.h"
#include "trycatch.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#endif

#include <limits.h>


static Char GetLine(TypInputFile * input);
static void PutLine2(TypOutputFile * output, const Char * line, UInt len);

static Obj ReadLineFunc;
static Obj WriteAllFunc;
static Obj IsInputStringStream;
static Obj IsOutputStringStream;
static Obj PositionStream;
static Obj SeekPositionStream;

static Obj PrintPromptHook = 0;
Obj EndLineHook = 0;
static Obj PrintFormattingStatus;
static Obj SetPrintFormattingStatus;

/****************************************************************************
**
*V  FilenameCache . . . . . . . . . . . . . . . . . . list of filenames
**
**  'FilenameCache' is a list of previously opened filenames.
*/
static Obj FilenameCache;

static ModuleStateOffset IOStateOffset = -1;

enum {
    MAX_OPEN_FILES = 16,
};

struct IOModuleState {

    // A pointer to the current input file
    TypInputFile * Input;

    // A pointer to the current output file. It points to the top of the
    // stack 'OutputFiles'.
    TypOutputFile * Output;

    //
    TypOutputFile * IgnoreStdoutErrout;


    // The file identifier of the current input logfile. If it is not 0 the
    // scanner echoes all input from the files '*stdin*' and '*errin*' to
    // this file.
    TypOutputFile * InputLog;

    // The file identifier of the current output logfile. If it is not 0 the
    // scanner echoes all output to the files '*stdout*' and '*errout*' to
    // this file.
    TypOutputFile * OutputLog;

    TypOutputFile InputLogFileOrStream;
    TypOutputFile OutputLogFileOrStream;

    TypOutputFile DefaultOutput;

#ifdef HPCGAP
    Obj DefaultOutputStream;
    Obj DefaultInputStream;
#endif

    Int NoSplitLine;

    BOOL PrintFormattingForStdout;
    BOOL PrintFormattingForErrout;
};

// for debugging from GDB / lldb, we mark this as extern inline
extern inline struct IOModuleState * IO(void)
{
    return (struct IOModuleState *)StateSlotsAtOffset(IOStateOffset);
}

void LockCurrentOutput(BOOL lock)
{
    IO()->IgnoreStdoutErrout = lock ? IO()->Output : NULL;
}

TypInputFile * GetCurrentInput(void)
{
    return IO()->Input;
}

/****************************************************************************
**
*F  GetNextChar() . . . . . . . . . . . . . . . get the next character, local
**
**  'GetNextChar' returns the next character from  the current input file.
*/
Char GetNextChar(TypInputFile * input)
{
    input->ptr++;

    // handle line continuation, i.e., backslash followed by new line; and
    // also the case when we run out of buffered data
    while (*input->ptr == '\\' || *input->ptr == 0) {

        // if we run out of data, get more, and try again
        if (*input->ptr == 0) {
            GetLine(input);
            continue;
        }

        // we have seen a backslash; so check now if it starts a
        // line continuation, i.e., whether it is followed by a line terminator
        if (input->ptr[1] == '\n') {
            // LF is the line terminator used in Unix and its relatives
            input->ptr += 2;
        }
        else if (input->ptr[1] == '\r' && input->ptr[2] == '\n') {
            // CR+LF is the line terminator used by Windows
            input->ptr += 3;
        }
        else {
            // if we see a backlash without a line terminator after it, stop
            break;
        }

        // if we get here, we saw a line continuation; change the prompt to a
        // partial prompt from now on
        SetPrompt("> ");
    }

    return *input->ptr;
}

// GET_NEXT_CHAR_NO_LC is like GetNextChar, but does not handle
// line continuations. This is used when skipping to the end of the
// current line, when handling comment lines.
Char GET_NEXT_CHAR_NO_LC(TypInputFile * input)
{
    char c = *(++input->ptr);
    return c ? c : GetLine(input);
}

Char PEEK_NEXT_CHAR(TypInputFile * input)
{
    // store the current character
    char c = *input->ptr;

    // read next character; this will increment input->ptr and then
    // possibly read in new line data, and so even might end up reseting
    // input->ptr to point at the start of the line buffer, which is
    // equal to Input->line+1
    char next = GetNextChar(input);

    // push back the previous character: first, return input->ptr to the
    // previous position; then, if we detect that GetNextChar read a new
    // line, also restore the previous character by placing it in the "push
    // back buffer"
    GAP_ASSERT(input->ptr > input->line);
    input->ptr--;
    if (input->ptr == input->line)
        *input->ptr = c;

    // return the next character
    return next;
}

Char PEEK_CURR_CHAR(TypInputFile * input)
{
    Char c = *input->ptr;

    // if no character is available then get one
    if (c == '\0') {
        GAP_ASSERT(input->ptr > input->line);
        input->ptr--;
        c = GetNextChar(input);
    }

    return c;
}

void SKIP_TO_END_OF_LINE(TypInputFile * input)
{
    Char c = *input->ptr;
    while (c != '\n' && c != '\r' && c != '\377')
        c = GET_NEXT_CHAR_NO_LC(input);
}


const Char * GetInputFilename(TypInputFile * input)
{
    GAP_ASSERT(input);
    return input->name;
}

Int GetInputLineNumber(TypInputFile * input)
{
    GAP_ASSERT(input);
    return input->number;
}

const Char * GetInputLineBuffer(TypInputFile * input)
{
    GAP_ASSERT(input);
    // first byte of Input->line is reserved for the pushback buffer, so add 1
    return input->line + 1;
}

Int GetInputLinePosition(TypInputFile * input)
{
    GAP_ASSERT(input);
    return input->ptr - GetInputLineBuffer(input);
}

UInt GetInputFilenameID(TypInputFile * input)
{
    GAP_ASSERT(input);
    UInt gapnameid = input->gapnameid;
    if (gapnameid == 0) {
        Obj filename = MakeImmString(GetInputFilename(input));
#ifdef HPCGAP
        // TODO/FIXME: adjust this code to work more like the corresponding
        // code below for GAP?!?
        gapnameid = AddAList(FilenameCache, filename);
#else
        Obj pos = POS_LIST(FilenameCache, filename, INTOBJ_INT(1));
        if (pos == Fail) {
            gapnameid = PushPlist(FilenameCache, filename);
        }
        else {
            gapnameid = INT_INTOBJ(pos);
        }
#endif
        input->gapnameid = gapnameid;
    }
    return gapnameid;
}

Obj GetCachedFilename(UInt id)
{
    return ELM_LIST(FilenameCache, id);
}


/****************************************************************************
**
*F * * * * * * * * * * * open input/output functions  * * * * * * * * * * * *
*/

#ifdef HPCGAP
static GVarDescriptor DEFAULT_INPUT_STREAM;
static GVarDescriptor DEFAULT_OUTPUT_STREAM;

static UInt OpenDefaultInput(TypInputFile * input)
{
  Obj func, stream;
  stream = IO()->DefaultInputStream;
  if (stream)
      return OpenInputStream(input, stream, FALSE);
  func = GVarOptFunction(&DEFAULT_INPUT_STREAM);
  if (!func)
    return OpenInput(input, "*stdin*");
  stream = CALL_0ARGS(func);
  if (!stream)
    ErrorQuit("DEFAULT_INPUT_STREAM() did not return a stream", 0, 0);
  if (IsStringConv(stream))
    return OpenInput(input, CONST_CSTR_STRING(stream));
  IO()->DefaultInputStream = stream;
  return OpenInputStream(input, stream, FALSE);
}

static UInt OpenDefaultOutput(TypOutputFile * output)
{
  Obj func, stream;
  stream = IO()->DefaultOutputStream;
  if (stream)
    return OpenOutputStream(output, stream);
  func = GVarOptFunction(&DEFAULT_OUTPUT_STREAM);
  if (!func)
    return OpenOutput(output, "*stdout*", FALSE);
  stream = CALL_0ARGS(func);
  if (!stream)
    ErrorQuit("DEFAULT_OUTPUT_STREAM() did not return a stream", 0, 0);
  if (IsStringConv(stream))
    return OpenOutput(output, CONST_CSTR_STRING(stream), FALSE);
  IO()->DefaultOutputStream = stream;
  return OpenOutputStream(output, stream);
}
#endif


/****************************************************************************
**
*F  OpenInput( <filename> ) . . . . . . . . . .  open a file as current input
**
**  'OpenInput' opens  the file with  the name <filename>  as  current input.
**  All  subsequent input will  be taken from that  file, until it is  closed
**  again  with 'CloseInput'  or  another file  is opened  with  'OpenInput'.
**  'OpenInput'  will not  close the  current  file, i.e., if  <filename>  is
**  closed again, input will again be taken from the current input file.
**
**  'OpenInput'  returns 1 if  it   could  successfully open  <filename>  for
**  reading and 0  to indicate  failure.   'OpenInput' will fail if  the file
**  does not exist or if you do not have permissions to read it.  'OpenInput'
**  may  also fail if  you have too  many files open at once.   It  is system
**  dependent how many are  too many, but  16  files should  work everywhere.
**
**  You can open  '*stdin*' to  read  from the standard  input file, which is
**  usually the terminal, or '*errin*' to  read from the standard error file,
**  which  is  the  terminal  even if '*stdin*'  is  redirected from  a file.
**  'OpenInput' passes those  file names  to  'SyFopen' like any other  name,
**  they are  just  a  convention between the  main  and the system  package.
**  'SyFopen' and thus 'OpenInput' will  fail to open  '*errin*' if the  file
**  'stderr'  (Unix file  descriptor  2)  is  not a  terminal,  because  of a
**  redirection say, to avoid that break loops take their input from a file.
**
**  It is not necessary to open the initial input  file, 'InitScanner' opens
**  '*stdin*' for  that purpose.  This  file on   the other   hand  cannot be
**  closed by 'CloseInput'.
*/
UInt OpenInput(TypInputFile * input, const Char * filename)
{
    GAP_ASSERT(input);

    Int file;

#ifdef HPCGAP
    /* Handle *defin*; redirect *errin* to *defin* if the default
     * channel is already open. */
    if (streq(filename, "*defin*") ||
        (streq(filename, "*errin*") && IO()->DefaultInputStream))
        return OpenDefaultInput(input);
#endif

    /* try to open the input file                                          */
    file = SyFopen(filename, "r", TRUE);
    if ( file == -1 )
        return 0;

    /* enter the file identifier and the file name                         */
    memset(input, 0, sizeof(TypInputFile));
    input->prev = IO()->Input;
    input->stream = 0;
    input->file = file;

    // enable echo for stdin and errin
    if (streq("*errin*", filename) || streq("*stdin*", filename))
        input->echo = TRUE;
    else
        input->echo = FALSE;

    gap_strlcpy(input->name, filename, sizeof(input->name));
    input->gapnameid = 0;

    // start with an empty line
    input->line[0] = '\0';    // init the pushback buffer
    input->line[1] = '\0';    // empty line buffer
    input->ptr = input->line + 1;
    input->number = 1;

    IO()->Input = input;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenInputStream( <stream>, <echo> ) . . .  open a stream as current input
**
**  The same as 'OpenInput' but for streams.
*/
UInt OpenInputStream(TypInputFile * input, Obj stream, BOOL echo)
{
    GAP_ASSERT(input);

    /* enter the file identifier and the file name                         */
    memset(input, 0, sizeof(TypInputFile));
    input->prev = IO()->Input;
    input->stream = stream;
    input->file = -1;
    input->isstringstream = (CALL_1ARGS(IsInputStringStream, stream) == True);
    if (input->isstringstream) {
        input->sline = CONST_ADDR_OBJ(stream)[2];
        input->spos = INT_INTOBJ(CONST_ADDR_OBJ(stream)[1]);
    }
    else {
        input->sline = 0;
    }
    input->echo = echo;
    gap_strlcpy(input->name, "stream", sizeof(input->name));
    input->gapnameid = 0;

    // start with an empty line
    input->line[0] = '\0';    // init the pushback buffer
    input->line[1] = '\0';    // empty line buffer
    input->ptr = input->line + 1;
    input->number = 1;

    IO()->Input = input;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  CloseInput()  . . . . . . . . . . . . . . . . .  close current input file
**
**  'CloseInput'  will close the  current input file.   Subsequent input will
**  again be taken from the previous input file.   'CloseInput' will return 1
**  to indicate success.
**
**  'CloseInput' will not close the initial input file '*stdin*', and returns
**  0  if such  an  attempt is made.   This is  used in  'Error'  which calls
**  'CloseInput' until it returns 0, thereby closing all open input files.
**
**  Calling 'CloseInput' if the  corresponding  'OpenInput' call failed  will
**  close the current output file, which will lead to very strange behaviour.
*/
UInt CloseInput(TypInputFile * input)
{
    GAP_ASSERT(input);
    GAP_ASSERT(input == IO()->Input);

    // revert to previous input
    IO()->Input = input->prev;

    if (input->stream) {
        // if the input stream supports seeking, update its position to
        // reflect the actual state of things: we may have read and buffered
        // more bytes than we actually processed
        int offset = strlen(input->ptr);
        // check for EOF
        if (input->ptr[0] == '\377' && input->ptr[1] == '\0')
            offset = 0;
        if (offset) {
            Obj pos = CALL_1ARGS(PositionStream, input->stream);
            C_DIFF_FIA(pos, pos, INTOBJ_INT(offset));
            CALL_2ARGS(SeekPositionStream, input->stream, pos);
        }
    } else {
        // close the input file
        SyFclose(input->file);
    }

    // don't keep GAP objects alive unnecessarily
    input->stream = 0;
    input->sline = 0;

    return 1;
}

/****************************************************************************
**
*F  FlushRestOfInputLine()  . . . . . . . . . . . . discard remainder of line
*/

void FlushRestOfInputLine(TypInputFile * input)
{
    input->ptr[0] = input->ptr[1] = '\0';
}

/****************************************************************************
**
*F  OpenLog( <filename> ) . . . . . . . . . . . . . log interaction to a file
**
**  'OpenLog'  instructs  the scanner to   echo  all  input   from  the files
**  '*stdin*' and  '*errin*'  and  all  output to  the  files '*stdout*'  and
**  '*errout*' to the file with  name <filename>.  The  file is truncated  to
**  size 0 if it existed, otherwise it is created.
**
**  'OpenLog' returns 1 if it could  successfully open <filename> for writing
**  and 0  to indicate failure.   'OpenLog' will  fail if  you do  not   have
**  permissions  to create the file or   write to  it.  'OpenOutput' may also
**  fail if you have too many files open at once.  It is system dependent how
**  many   are too   many, but  16   files should  work everywhere.   Finally
**  'OpenLog' will fail if there is already a current logfile.
*/
UInt OpenLog (
    const Char *        filename )
{

    /* refuse to open a logfile if we already log to one                   */
    if (IO()->InputLog != 0 || IO()->OutputLog != 0)
        return 0;

    /* try to open the file                                                */
    IO()->OutputLogFileOrStream.file = SyFopen(filename, "w", FALSE);
    IO()->OutputLogFileOrStream.stream = 0;
    if (IO()->OutputLogFileOrStream.file == -1)
        return 0;

    IO()->InputLog = &IO()->OutputLogFileOrStream;
    IO()->OutputLog = &IO()->OutputLogFileOrStream;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  OpenLogStream( <stream> ) . . . . . . . . . . log interaction to a stream
**
**  The same as 'OpenLog' but for streams.
*/
UInt OpenLogStream (
    Obj             stream )
{

    /* refuse to open a logfile if we already log to one                   */
    if (IO()->InputLog != 0 || IO()->OutputLog != 0)
        return 0;

    /* try to open the file                                                */
    IO()->OutputLogFileOrStream.stream = stream;
    IO()->OutputLogFileOrStream.file = -1;

    IO()->InputLog = &IO()->OutputLogFileOrStream;
    IO()->OutputLog = &IO()->OutputLogFileOrStream;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  CloseLog()  . . . . . . . . . . . . . . . . . . close the current logfile
**
**  'CloseLog' closes the current logfile again, so that input from '*stdin*'
**  and '*errin*' and output to '*stdout*' and '*errout*' will no  longer  be
**  echoed to a file.  'CloseLog' will return 1 to indicate success.
**
**  'CloseLog' will fail if there is no logfile active and will return  0  in
**  this case.
*/
UInt CloseLog ( void )
{
    /* refuse to close a non existent logfile                              */
    if (IO()->InputLog == 0 || IO()->OutputLog == 0 ||
        IO()->InputLog != IO()->OutputLog)
        return 0;

    /* close the logfile                                                   */
    if (!IO()->InputLog->stream) {
        SyFclose(IO()->InputLog->file);
    }
    IO()->InputLog = 0;
    IO()->OutputLog = 0;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenInputLog( <filename> )  . . . . . . . . . . . . . log input to a file
**
**  'OpenInputLog'  instructs the  scanner  to echo  all input from the files
**  '*stdin*' and  '*errin*' to the file  with  name <filename>.  The file is
**  truncated to size 0 if it existed, otherwise it is created.
**
**  'OpenInputLog' returns 1  if it  could successfully open  <filename>  for
**  writing  and  0 to indicate failure.  'OpenInputLog' will fail  if you do
**  not have  permissions to create the file  or write to it.  'OpenInputLog'
**  may also fail  if you  have  too many  files open  at once.  It is system
**  dependent  how many are too many,  but 16 files  should work  everywhere.
**  Finally 'OpenInputLog' will fail if there is already a current logfile.
*/
UInt OpenInputLog (
    const Char *        filename )
{

    /* refuse to open a logfile if we already log to one                   */
    if (IO()->InputLog != 0)
        return 0;

    /* try to open the file                                                */
    IO()->InputLogFileOrStream.file = SyFopen(filename, "w", FALSE);
    IO()->InputLogFileOrStream.stream = 0;
    if (IO()->InputLogFileOrStream.file == -1)
        return 0;

    IO()->InputLog = &IO()->InputLogFileOrStream;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  OpenInputLogStream( <stream> )  . . . . . . . . . . log input to a stream
**
**  The same as 'OpenInputLog' but for streams.
*/
UInt OpenInputLogStream (
    Obj                 stream )
{

    /* refuse to open a logfile if we already log to one                   */
    if (IO()->InputLog != 0)
        return 0;

    /* try to open the file                                                */
    IO()->InputLogFileOrStream.stream = stream;
    IO()->InputLogFileOrStream.file = -1;

    IO()->InputLog = &IO()->InputLogFileOrStream;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  CloseInputLog() . . . . . . . . . . . . . . . . close the current logfile
**
**  'CloseInputLog'  closes  the current  logfile again,  so  that input from
**  '*stdin*'  and   '*errin*'  will  no  longer   be  echoed   to  a   file.
**  'CloseInputLog' will return 1 to indicate success.
**
**  'CloseInputLog' will fail if there is no logfile active and will return 0
**  in this case.
*/
UInt CloseInputLog ( void )
{
    /* refuse to close a non existent logfile                              */
    if (IO()->InputLog == 0)
        return 0;

    /* refuse to close a log opened with LogTo */
    if (IO()->InputLog == IO()->OutputLog)
        return 0;

    /* close the logfile                                                   */
    if (!IO()->InputLog->stream) {
        SyFclose(IO()->InputLog->file);
    }

    IO()->InputLog = 0;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenOutputLog( <filename> )  . . . . . . . . . . .  log output to a file
**
**  'OpenInputLog'  instructs the  scanner to echo   all output to  the files
**  '*stdout*' and '*errout*' to the file with name  <filename>.  The file is
**  truncated to size 0 if it existed, otherwise it is created.
**
**  'OpenOutputLog'  returns 1 if it  could  successfully open <filename> for
**  writing and 0 to  indicate failure.  'OpenOutputLog'  will fail if you do
**  not have permissions to create the file  or write to it.  'OpenOutputLog'
**  may also  fail if you have  too many  files  open at  once.  It is system
**  dependent how many are  too many,  but  16 files should  work everywhere.
**  Finally 'OpenOutputLog' will fail if there is already a current logfile.
*/
UInt OpenOutputLog (
    const Char *        filename )
{

    /* refuse to open a logfile if we already log to one                   */
    if (IO()->OutputLog != 0)
        return 0;

    /* try to open the file                                                */
    memset(&IO()->OutputLogFileOrStream, 0, sizeof(TypOutputFile));
    IO()->OutputLogFileOrStream.stream = 0;
    IO()->OutputLogFileOrStream.file = SyFopen(filename, "w", FALSE);
    if (IO()->OutputLogFileOrStream.file == -1)
        return 0;

    IO()->OutputLog = &IO()->OutputLogFileOrStream;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  OpenOutputLogStream( <stream> )  . . . . . . . .  log output to a stream
**
**  The same as 'OpenOutputLog' but for streams.
*/
UInt OpenOutputLogStream (
    Obj                 stream )
{

    /* refuse to open a logfile if we already log to one                   */
    if (IO()->OutputLog != 0)
        return 0;

    /* try to open the file                                                */
    memset(&IO()->OutputLogFileOrStream, 0, sizeof(TypOutputFile));
    IO()->OutputLogFileOrStream.stream = stream;
    IO()->OutputLogFileOrStream.file = -1;

    IO()->OutputLog = &IO()->OutputLogFileOrStream;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  CloseOutputLog()  . . . . . . . . . . . . . . . close the current logfile
**
**  'CloseInputLog' closes   the current logfile   again, so  that output  to
**  '*stdout*'  and    '*errout*'  will no   longer  be   echoed to  a  file.
**  'CloseOutputLog' will return 1 to indicate success.
**
**  'CloseOutputLog' will fail if there is  no logfile active and will return
**  0 in this case.
*/
UInt CloseOutputLog ( void )
{
    /* refuse to close a non existent logfile                              */
    if (IO()->OutputLog == 0)
        return 0;

    /* refuse to close a log opened with LogTo */
    if (IO()->OutputLog == IO()->InputLog)
        return 0;

    /* close the logfile                                                   */
    if (!IO()->OutputLog->stream) {
        SyFclose(IO()->OutputLog->file);
    }

    IO()->OutputLog = 0;

    /* indicate success                                                    */
    return 1;
}

/****************************************************************************
**
*F  OpenOutput( <filename> )  . . . . . . . . . open a file as current output
**
**  'OpenOutput' opens the file  with the name  <filename> as current output.
**  All subsequent output will go  to that file, until either   it is  closed
**  again  with 'CloseOutput' or  another  file is  opened with 'OpenOutput'.
**  The file is truncated to size 0 if it existed, otherwise it  is  created.
**  'OpenOutput' does not  close  the  current file, i.e., if  <filename>  is
**  closed again, output will go again to the current output file.
**
**  'OpenOutput'  returns  1 if it  could  successfully  open  <filename> for
**  writing and 0 to indicate failure.  'OpenOutput' will fail if  you do not
**  have  permissions to create the  file or write   to it.  'OpenOutput' may
**  also   fail if you   have  too many files   open  at once.   It is system
**  dependent how many are too many, but 16 files should work everywhere.
**
**  You can open '*stdout*'  to write  to the standard output  file, which is
**  usually the terminal, or '*errout*' to write  to the standard error file,
**  which is the terminal  even   if '*stdout*'  is  redirected to   a  file.
**  'OpenOutput' passes  those  file names to 'SyFopen'  like any other name,
**  they are just a convention between the main and the system package.
**
**  The function does nothing and returns success for '*stdout*' and
**  '*errout*' when 'LockCurrentOutput(1)' is in effect (used for testing
**  purposes).
**
**  It is not necessary to open the initial output file; '*stdout'* is
**  opened for that purpose during startup. This file on the other hand  can
**  not be closed by 'CloseOutput'.
**
**  If <append> is set to true, then 'OpenOutput' does not truncate the file
**  to size 0 if it exists.
*/
UInt OpenOutput(TypOutputFile * output, const Char * filename, BOOL append)
{
    GAP_ASSERT(output);

    // do nothing for stdout and errout if caught
    if (IO()->Output != NULL && IO()->IgnoreStdoutErrout == IO()->Output &&
        (streq(filename, "*errout*") || streq(filename, "*stdout*"))) {
        return 1;
    }

#ifdef HPCGAP
    /* Handle *defout* specially; also, redirect *errout* if we already
     * have a default channel open. */
    if (streq(filename, "*defout*") ||
        (streq(filename, "*errout*") && TLS(threadID) != 0))
        return OpenDefaultOutput(output);
#endif

    /* try to open the file                                                */
    Int file = SyFopen(filename, append ? "a" : "w", FALSE);
    if ( file == -1 )
        return 0;

    /* put the file on the stack, start at position 0 on an empty line     */
    output->prev = IO()->Output;
    IO()->Output = output;
    output->stream = 0;
    output->file = file;
    output->line[0] = '\0';
    output->pos = 0;
    if (streq(filename, "*stdout*"))
        output->format = IO()->PrintFormattingForStdout;
    else if (streq(filename, "*errout*"))
        output->format = IO()->PrintFormattingForErrout;
    else
        output->format = TRUE;
    output->indent = 0;

    /* variables related to line splitting, very bad place to split        */
    output->hints[0] = -1;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenOutputStream( <stream> )  . . . . . . open a stream as current output
**
**  The same as 'OpenOutput' (and also 'OpenAppend') but for streams.
*/


UInt OpenOutputStream(TypOutputFile * output, Obj stream)
{
    GAP_ASSERT(output);

    /* put the file on the stack, start at position 0 on an empty line     */
    output->prev = IO()->Output;
    IO()->Output = output;
    output->isstringstream = (CALL_1ARGS(IsOutputStringStream, stream) == True);
    output->stream = stream;
    output->file = -1;
    output->line[0] = '\0';
    output->pos = 0;
    output->format = (CALL_1ARGS(PrintFormattingStatus, stream) == True);
    output->indent = 0;

    /* variables related to line splitting, very bad place to split        */
    output->hints[0] = -1;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  CloseOutput() . . . . . . . . . . . . . . . . . close current output file
**
**  'CloseOutput' will  first flush all   pending output and  then  close the
**  current  output  file.   Subsequent output will  again go to the previous
**  output file.  'CloseOutput' returns 1 to indicate success.
**
**  'CloseOutput' will  not  close the  initial output file   '*stdout*', and
**  returns 0 if such attempt is made.  This  is  used in 'Error' which calls
**  'CloseOutput' until it returns 0, thereby closing all open output files.
**
**  Calling 'CloseOutput' if the corresponding 'OpenOutput' call failed  will
**  close the current output file, which will lead to very strange behaviour.
**  On the other  hand if you  forget  to call  'CloseOutput' at the end of a
**  'PrintTo' call or an error will not yield much better results.
*/
UInt CloseOutput(TypOutputFile * output)
{
    GAP_ASSERT(output);

    // silently refuse to close the test output file; this is probably an
    // attempt to close *errout* which is silently not opened, so let's
    // silently not close it
    if (IO()->IgnoreStdoutErrout == IO()->Output)
        return 1;

    GAP_ASSERT(output == IO()->Output);

    /* refuse to close the initial output file '*stdout*'                  */
#ifdef HPCGAP
    if (output->prev == 0 && output->stream &&
        IO()->DefaultOutputStream == output->stream)
        return 0;
#else
    if (output->prev == 0)
        return 0;
#endif

    /* flush output and close the file                                     */
    Pr("%c", (Int)'\03', 0);
    if (!output->stream) {
        SyFclose(output->file);
    }

    /* revert to previous output file and indicate success                 */
    IO()->Output = output->prev;

    // don't keep GAP objects alive unnecessarily
    output->stream = 0;

    return 1;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * input functions  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  SetPrompt( <prompt> ) . . . . . . . . . . . . . set the user input prompt
*/
void SetPrompt(const char * prompt)
{
    if (SyQuiet)
        prompt = "";
    gap_strlcpy(STATE(Prompt), prompt, sizeof(STATE(Prompt)));
}


/****************************************************************************
**
*F  GetLine2( <input>, <buffer>, <length> ) . . . . . . . . get a line, local
*/
static Int GetLine2(TypInputFile * input)
{
    Char * buffer = input->line + 1;
    UInt   length = sizeof(input->line) - 1;

    if ( input->stream ) {
        if (input->sline == 0 ||
            (IS_STRING_REP(input->sline) &&
             GET_LEN_STRING(input->sline) <= input->spos)) {
            input->sline = CALL_1ARGS( ReadLineFunc, input->stream );
            input->spos  = 0;
        }
        if ( input->sline == Fail || ! IS_STRING(input->sline) ) {
            return 0;
        }

        ConvString(input->sline);
        /* we now allow that input->sline actually contains several lines,
           e.g., it can be a  string from a string stream  */

        /* start position in buffer */
        Char *bptr = buffer;
        while (*bptr)
            bptr++;

        /* copy piece of input->sline into buffer and adjust counters */
        const Char *ptr = CONST_CSTR_STRING(input->sline) + input->spos;
        const Char * const end = CONST_CSTR_STRING(input->sline) + GET_LEN_STRING(input->sline);
        const Char * const bend = buffer + length - 2;
        while (bptr < bend && ptr < end) {
            Char c = *ptr++;

            // ignore CR, so that a Window CR+LF line terminator looks
            // to us the same as a Unix LF line terminator
            if (c == '\r')
                continue;

            *bptr++ = c;

            // check for line end
            if (c == '\n')
                break;
        }
        *bptr = '\0';
        input->spos = ptr - CONST_CSTR_STRING(input->sline);

        /* if input->stream is a string stream, we have to adjust the
           position counter in the stream object as well */
        if (input->isstringstream) {
            ADDR_OBJ(input->stream)[1] = INTOBJ_INT(input->spos);
        }
    }
    else {
        if ( ! SyFgets( buffer, length, input->file ) ) {
            return 0;
        }
    }
    return 1;
}


/****************************************************************************
**
*F  GetLine( <input> ) . . . . . . . . . . . . . . . . . .  get a line, local
**
**  'GetLine'  fetches another  line from  the  input 'Input' into the buffer
**  'Input->line', sets the pointer 'Input->ptr' to the beginning of this
**  buffer and returns the first character from the line.
**
**  If   the input file is  '*stdin*'   or '*errin*' 'GetLine'  first  prints
**  'Prompt', unless it is '*stdin*' and GAP was called with option '-q'.
**
**  If there is an  input logfile in use  and the input  file is '*stdin*' or
**  '*errin*' 'GetLine' echoes the new line to the logfile.
*/
static Char GetLine(TypInputFile * input)
{
    GAP_ASSERT(input);

    /* if file is '*stdin*' or '*errin*' print the prompt and flush it     */
    /* if the GAP function `PrintPromptHook' is defined then it is called  */
    /* for printing the prompt, see also `EndLineHook'                     */
    if (!input->stream) {
        if (input->file == 0 && SyQuiet) {
            Pr("%c", (Int)'\03', 0);
        }
        else if (input->file == 0 || input->file == 2) {
            if (IO()->Output->pos > 0)
                Pr("\n", 0, 0);
            if ( PrintPromptHook )
                 Call0ArgsInNewReader( PrintPromptHook );
            else
                 Pr( "%s%c", (Int)STATE(Prompt), (Int)'\03' );
        }
    }

    /* bump the line number                                                */
    if (input->ptr > input->line && input->ptr[-1] == '\n') {
        input->number++;
    }

    // initialize 'input->ptr', no errors on this line so far
    input->line[0] = '\0';    // init the pushback buffer
    input->line[1] = '\0';    // empty line buffer
    input->ptr = input->line + 1;
    input->lastErrorLine = 0;

    /* try to read a line                                              */
    if (!GetLine2(input)) {
        input->ptr[0] = '\377';
        input->ptr[1] = '\0';
    }

    /* if necessary echo the line to the logfile                      */
    if (IO()->InputLog != 0 && input->echo == 1)
        if (!(input->ptr[0] == '\377' && input->ptr[1] == '\0'))
            PutLine2(IO()->InputLog, input->ptr, strlen(input->ptr));

    /* return the current character                                        */
    return *input->ptr;
}


/****************************************************************************
**
*F * * * * * * * * * * * * *  output functions  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  PutLine2( <output>, <line>, <len> )  . . . . . . . . .print a line, local
**
**  Introduced <len> argument. Actually in all cases where this is called one
**  knows the length of <line>, so it is not necessary to compute it again
**  with the inefficient C- strlen.  (FL)
*/
static void PutLine2(TypOutputFile * output, const Char * line, UInt len)
{
    Obj str;

    if (output->isstringstream) {
        // special handling of string streams, where we can copy directly
        str = CONST_ADDR_OBJ(output->stream)[1];
        ConvString(str);
        AppendCStr(str, line, len);
    }
    else if (output->stream) {
        // delegate to library level
        str = MakeImmStringWithLen(line, len);
        CALL_2ARGS(WriteAllFunc, output->stream, str);
    }
    else {
        SyFputs(line, output->file);
    }
}


/****************************************************************************
**
*F  PutLineTo ( stream, len ) . . . . . . . . . . . . . . print a line, local
**
**  'PutLineTo'  prints the first len characters of the current output
**  line   'stream->line' to <stream>
**  It  is  called from 'PutChrTo'.
**
**  'PutLineTo' also echoes the output line to the logfile 'OutputLog' if
**  'OutputLog' is not 0 and the output file is '*stdout*' or '*errout*'.
**
*/
static void PutLineTo(TypOutputFile * stream, UInt len)
{
  PutLine2( stream, stream->line, len );

  /* if necessary echo it to the logfile                                */
  if (IO()->OutputLog != 0 && !stream->stream) {
      if (stream->file == 1 || stream->file == 3) {
          PutLine2(IO()->OutputLog, stream->line, len);
      }
  }
}


/****************************************************************************
**
*F  PutChrTo( <stream>, <ch> )  . . . . . . . . . print character <ch>, local
**
**  'PutChrTo' prints the single character <ch> to the stream <stream>
**
**  'PutChrTo' buffers the output characters until either <ch> is <newline>,
**  <ch> is '\03' (<flush>) or the buffer fills up.
**
**  In the later case 'PutChrTo' has to decide where to split the output
**  line. It takes the point at which $linelength - pos + 8 * indent$ is
**  minimal.
*/

/* helper function to add a hint about a possible line break;
   a triple (pos, value, indent), such that the minimal (value-pos) wins */
static void
addLineBreakHint(TypOutputFile * stream, Int pos, Int val, Int indentdiff)
{
  Int nr, i;
  /* find next free slot */
  for (nr = 0; nr < MAXHINTS && stream->hints[3*nr] != -1; nr++);
  if (nr == MAXHINTS) {
    /* forget the first stored hint */
    for (i = 0; i < 3*MAXHINTS - 3; i++)
       stream->hints[i] =  stream->hints[i+3];
    nr--;
  }
  /* if pos is same as before only relevant if new entry has higher
     priority */
  if ( nr > 0 && stream->hints[3*(nr-1)] == pos )
    nr--;

  if ( stream->indent < pos &&
       (stream->hints[3*nr] == -1 || val < stream->hints[3*(nr)+1]) ) {
    stream->hints[3*nr] = pos;
    stream->hints[3*nr+1] = val;
    stream->hints[3*nr+2] = stream->indent;
    stream->hints[3*nr+3] = -1;
  }
  stream->indent += indentdiff;
}
/* helper function to find line break position,
   returns position nr in stream[hints] or -1 if none found */
static Int nrLineBreak(TypOutputFile * stream)
{
  Int nr=-1, min, i;
  for (i = 0, min = INT_MAX; stream->hints[3*i] != -1; i++)
  {
    if (stream->hints[3*i] > 0 &&
        stream->hints[3*i+1] - stream->hints[3*i] <= min)
    {
      nr = i;
      min = stream->hints[3*i+1] - stream->hints[3*i];
    }
  }
  if (min < INT_MAX)
    return nr;
  else
    return -1;
}


static void PutChrTo(TypOutputFile * stream, Char ch)
{
  Int                 i, hint, spos;
  Char                str [MAXLENOUTPUTLINE];


  /* '\01', increment indentation level                                  */
  if ( ch == '\01' ) {

    if (!stream->format)
      return;

    /* add hint to break line  */
    addLineBreakHint(stream, stream->pos, 16*stream->indent, 1);
  }

  /* '\02', decrement indentation level                                  */
  else if ( ch == '\02' ) {

    if (!stream->format)
      return;

    /* if this is a better place to split the line remember it         */
    addLineBreakHint(stream, stream->pos, 16*stream->indent, -1);
  }

  /* '\03', print line                                                   */
  else if ( ch == '\03' ) {

    /* print the line                                                  */
    if (stream->pos != 0)
      {
        stream->line[ stream->pos ] = '\0';
        PutLineTo(stream, stream->pos );

        /* start the next line                                         */
        stream->pos      = 0;
      }
    /* reset line break hints                                          */
    stream->hints[0] = -1;

  }

  /* <newline> or <return>, print line, indent next                      */
  else if ( ch == '\n' || ch == '\r' ) {

    /* put the character on the line and terminate it                  */
    stream->line[ stream->pos++ ] = ch;
    stream->line[ stream->pos   ] = '\0';

    /* print the line                                                  */
    PutLineTo( stream, stream->pos );

    /* and dump it from the buffer */
    stream->pos = 0;
    if (stream->format)
      {
        /* indent for next line                                         */
        for ( i = 0;  i < stream->indent; i++ )
          stream->line[ stream->pos++ ] = ' ';
      }
    /* reset line break hints                                       */
    stream->hints[0] = -1;

  }

  /* normal character, room on the current line                          */
#ifdef HPCGAP
  /* TODO: For threads other than the main thread, reserve some extra
     space for the thread id indicator. See issue #136. */
  else if (stream->pos <
           SyNrCols - 2 - 6 * (TLS(threadID) != 0) - IO()->NoSplitLine) {
#else
  else if (stream->pos < SyNrCols - 2 - IO()->NoSplitLine) {
#endif

    /* put the character on this line                                  */
    stream->line[ stream->pos++ ] = ch;

  }

  else
    {
      /* position to split                                              */
      if ( (hint = nrLineBreak(stream)) != -1 )
        spos = stream->hints[3*hint];
      else
        spos = 0;

      /* if we are going to split at the end of the line, and we are
         formatting discard blanks */
      if ( stream->format && spos == stream->pos && ch == ' ' ) {
        ;
      }

      /* full line, acceptable split position                              */
      else if ( stream->format && spos != 0 ) {

        /* add character to the line, terminate it                         */
        stream->line[ stream->pos++ ] = ch;
        stream->line[ stream->pos++ ] = '\0';

        /* copy the rest after the best split position to a safe place     */
        for ( i = spos; i < stream->pos; i++ )
          str[ i-spos ] = stream->line[ i ];
        str[ i-spos] = '\0';

        /* print line up to the best split position                        */
        stream->line[ spos++ ] = '\n';
        stream->line[ spos   ] = '\0';
        PutLineTo( stream, spos );
        spos--;

        /* indent for the rest                                             */
        stream->pos = 0;
        for ( i = 0; i < stream->hints[3*hint+2]; i++ )
          stream->line[ stream->pos++ ] = ' ';
        spos -= stream->hints[3*hint+2];

        /* copy the rest onto the next line                                */
        for ( i = 0; str[ i ] != '\0'; i++ )
          stream->line[ stream->pos++ ] = str[ i ];
        /* recover line break hints for copied rest                      */
        for ( i = hint+1; stream->hints[3*i] != -1; i++ )
        {
          stream->hints[3*(i-hint-1)] = stream->hints[3*i]-spos;
          stream->hints[3*(i-hint-1)+1] = stream->hints[3*i+1];
          stream->hints[3*(i-hint-1)+2] = stream->hints[3*i+2];
        }
        stream->hints[3*(i-hint-1)] = -1;
      }

      /* full line, no split position                                       */
      else {

        if (stream->format)
          {
            /* append a '\',*/
            stream->line[ stream->pos++ ] = '\\';
            stream->line[ stream->pos++ ] = '\n';
          }
        /* and print the line                                */
        stream->line[ stream->pos   ] = '\0';
        PutLineTo( stream, stream->pos );

        /* add the character to the next line                              */
        stream->pos = 0;
        stream->line[ stream->pos++ ] = ch;

        if (stream->format)
          stream->hints[0] = -1;
      }

    }
}

/****************************************************************************
**
*F  FuncToggleEcho( )
**
*/
static Obj FuncToggleEcho(Obj self)
{
    IO()->Input->echo = !IO()->Input->echo;
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncCPROMPT( )
**
**  returns the current `Prompt' as GAP string.
*/
static Obj FuncCPROMPT(Obj self)
{
  Obj p;
  p = MakeString(STATE(Prompt));
  return p;
}

/****************************************************************************
**
*F  FuncPRINT_CPROMPT( <prompt> )
**
**  prints current `Prompt' if argument <prompt> is not in StringRep, otherwise
**  uses the content of <prompt> as `Prompt' (at most 80 characters).
**  (important is the flush character without resetting the cursor column)
*/
static Obj FuncPRINT_CPROMPT(Obj self, Obj prompt)
{
  if (IS_STRING_REP(prompt)) {
    /* by assigning to Prompt we also tell readline (if used) what the
       current prompt is  */
    SetPrompt(CONST_CSTR_STRING(prompt));
  }
  Pr("%s%c", (Int)STATE(Prompt), (Int)'\03' );
  return (Obj) 0;
}

void ResetOutputIndent(void)
{
    GAP_ASSERT(IO()->Output);
    IO()->Output->indent = 0;
}



/****************************************************************************
**
*V  AllKeywords
**
*/
static const char * AllKeywords[] = {
    "and",     "atomic",   "break",         "continue", "do",     "elif",
    "else",    "end",      "false",         "fi",       "for",    "function",
    "if",      "in",       "local",         "mod",      "not",    "od",
    "or",      "readonly", "readwrite",     "rec",      "repeat", "return",
    "then",    "true",     "until",         "while",    "quit",   "QUIT",
    "IsBound", "Unbind",   "TryNextMethod", "Info",     "Assert",
};


/****************************************************************************
**
*F  IsKeyword( )
**
*/
static BOOL IsKeyword(const char * str)
{
    for (UInt i = 0; i < ARRAY_SIZE(AllKeywords); i++) {
        if (streq(str, AllKeywords[i])) {
            return TRUE;
        }
    }
    return FALSE;
}


/****************************************************************************
**
*F  FuncALL_KEYWORDS( )
**
*/
static Obj FuncALL_KEYWORDS(Obj self)
{
    Obj l = NewEmptyPlist();
    for (UInt i = 0; i < ARRAY_SIZE(AllKeywords); i++) {
        Obj s = MakeImmString(AllKeywords[i]);
        ASS_LIST(l, i+1, s);
    }
    SortDensePlist(l);
    SET_FILT_LIST(l, FN_IS_HOMOG);
    SET_FILT_LIST(l, FN_IS_SSORT);
    MakeImmutable(l);
    return l;
}


/****************************************************************************
**
*F  Pr( <format>, <arg1>, <arg2> )  . . . . . . . . .  print formatted output
*F  PrTo( <stream>, <format>, <arg1>, <arg2> )  . . .  print formatted output
**
**  'Pr' is the output function. The first argument is a 'printf' like format
**  string containing   up   to 2  '%'  format   fields,  specifying  how the
**  corresponding arguments are to be  printed.  The two arguments are passed
**  as  'Int'   integers.   This  is possible  since every  C object  ('int',
**  'char', pointers) except 'float' or 'double', which are not used  in GAP,
**  can be converted to a 'Int' without loss of information.
**
**  The function 'Pr' currently support the following '%' format  fields:
**  '%c'    the corresponding argument represents a character,  usually it is
**          its ASCII or EBCDIC code, and this character is printed.
**  '%s'    the corresponding argument is the address of  a  null  terminated
**          character string which is printed.
**  '%S'    the corresponding argument is the address of  a  null  terminated
**          character string which is printed with escapes.
**  '%g'    the corresponding argument is the address of an Obj which points
**          to a string in STRING_REP format which is printed in '%s' format
**  '%G'    the corresponding argument is the address of an Obj which points
**          to a string in STRING_REP format which is printed in '%S' format
**  '%C'    the corresponding argument is the address of an Obj which points
**          to a string in STRING_REP format which is printed with C escapes
**  '%d'    the corresponding argument is a signed integer, which is printed.
**          Between the '%' and the 'd' an integer might be used  to  specify
**          the width of a field in which the integer is right justified.  If
**          the first character is '0' 'Pr' pads with '0' instead of <space>.
**  '%i'    is a synonym of %d, in line with recent C library developments
**  '%I'    print an identifier, given as a null terminated character string.
**  '%H'    print an identifier, given as GAP string in STRING_REP
**  '%>'    increment the indentation level.
**  '%<'    decrement the indentation level.
**  '%%'    can be used to print a single '%' character. No argument is used.
**
**  You must always  cast the arguments to  '(Int)'  to avoid  problems  with
**  those compilers with a default integer size of 16 instead of 32 bit.  You
**  must pass 0 if you don't make use of an argument to please lint.
*/
static inline void FormatOutput(
    void (*put_a_char)(void *state, Char c),
    void *state, const Char *format, Int arg1, Int arg2 )
{
  const Char *        p;
  Obj                 arg1obj;
  Int                 prec,  n;
  Char                fill;

  /* loop over the characters of the <format> string                     */
  for ( p = format; *p != '\0'; p++ ) {

    /* not a '%' character, simply print it                            */
    if ( *p != '%' ) {
      put_a_char(state, *p);
      continue;
    }

    /* if the character is '%' do something special                    */

    /* first look for a precision field                            */
    p++;
    prec = 0;
    fill = (*p == '0' ? '0' : ' ');
    while ( IsDigit(*p) ) {
      prec = 10 * prec + *p - '0';
      p++;
    }

    /* handle the case of a missing argument                     */
    if (arg1 == 0 && (*p == 's' || *p == 'S' || *p == 'C' || *p == 'I')) {
      put_a_char(state, '<');
      put_a_char(state, 'n');
      put_a_char(state, 'u');
      put_a_char(state, 'l');
      put_a_char(state, 'l');
      put_a_char(state, '>');

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%d' print an integer                                       */
    else if ( *p == 'd'|| *p == 'i' ) {
      int is_neg = (arg1 < 0);
      if ( is_neg ) {
        arg1 = -arg1;
        prec--; // we loose one digit of output precision for the minus sign
      }

      /* compute how many characters this number requires    */
      for ( n = 1; n <= arg1/10; n*=10 ) {
        prec--;
      }
      while ( --prec > 0 )  put_a_char(state, fill);

      if ( is_neg ) {
        put_a_char(state, '-');
      }

      for ( ; n > 0; n /= 10 )
        put_a_char(state, (Char)(((arg1/n)%10) + '0') );

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%s' or '%g' print a string                               */
    else if ( *p == 's' || *p == 'g') {

      // If arg is a GAP obj, get out the contained string, and
      // set arg1obj so we can re-evaluate after any possible GC
      // which occurs in put_a_char
      if (*p == 'g') {
        arg1obj = (Obj)arg1;
        arg1 = (Int)CONST_CSTR_STRING(arg1obj);
      }
      else {
        arg1obj = 0;
      }

      /* compute how many characters this identifier requires    */
      for ( const Char * q = (const Char *)arg1; *q != '\0' && prec > 0; q++ ) {
        prec--;
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 )  put_a_char(state, ' ');

      if (arg1obj) {
          arg1 = (Int)CONST_CSTR_STRING(arg1obj);
      }

      /* print the string                                        */
      /* must be careful that line breaks don't go inside
         escaped sequences \n or \123 or similar */
      for ( Int i = 0; ((const Char *)arg1)[i] != '\0'; i++ ) {
          const Char* q = ((const Char *)arg1) + i;
          if (*q == '\\' && IO()->NoSplitLine == 0) {
              if (*(q + 1) < '8' && *(q + 1) >= '0')
                  IO()->NoSplitLine = 3;
              else
                  IO()->NoSplitLine = 1;
        }
        else if (IO()->NoSplitLine > 0)
            IO()->NoSplitLine--;
        put_a_char(state, *q);

        if (arg1obj) {
          arg1 = (Int)CONST_CSTR_STRING(arg1obj);
        }
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%S' or '%G' print a string with the necessary escapes    */
    else if ( *p == 'S' || *p == 'G' ) {

      // If arg is a GAP obj, get out the contained string, and
      // set arg1obj so we can re-evaluate after any possible GC
      // which occurs in put_a_char
      if (*p == 'G') {
        arg1obj = (Obj)arg1;
        arg1 = (Int)CONST_CSTR_STRING(arg1obj);
      }
      else {
        arg1obj = 0;
      }


      /* compute how many characters this identifier requires    */
      for ( const Char * q = (const Char *)arg1; *q != '\0' && prec > 0; q++ ) {
        if      ( *q == '\n'  ) { prec -= 2; }
        else if ( *q == '\t'  ) { prec -= 2; }
        else if ( *q == '\r'  ) { prec -= 2; }
        else if ( *q == '\b'  ) { prec -= 2; }
        else if ( *q == '\01' ) { prec -= 2; }
        else if ( *q == '\02' ) { prec -= 2; }
        else if ( *q == '\03' ) { prec -= 2; }
        else if ( *q == '"'   ) { prec -= 2; }
        else if ( *q == '\\'  ) { prec -= 2; }
        else                    { prec -= 1; }
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 )  put_a_char(state, ' ');

      if (arg1obj) {
          arg1 = (Int)CONST_CSTR_STRING(arg1obj);
      }

      /* print the string                                        */
      for ( Int i = 0; ((const Char *)arg1)[i] != '\0'; i++ ) {
        const Char* q = ((const Char *)arg1) + i;
        if      ( *q == '\n'  ) { put_a_char(state, '\\'); put_a_char(state, 'n');  }
        else if ( *q == '\t'  ) { put_a_char(state, '\\'); put_a_char(state, 't');  }
        else if ( *q == '\r'  ) { put_a_char(state, '\\'); put_a_char(state, 'r');  }
        else if ( *q == '\b'  ) { put_a_char(state, '\\'); put_a_char(state, 'b');  }
        else if ( *q == '\01' ) { put_a_char(state, '\\'); put_a_char(state, '>');  }
        else if ( *q == '\02' ) { put_a_char(state, '\\'); put_a_char(state, '<');  }
        else if ( *q == '\03' ) { put_a_char(state, '\\'); put_a_char(state, 'c');  }
        else if ( *q == '"'   ) { put_a_char(state, '\\'); put_a_char(state, '"');  }
        else if ( *q == '\\'  ) { put_a_char(state, '\\'); put_a_char(state, '\\'); }
        else                    { put_a_char(state, *q);               }

        if (arg1obj) {
          arg1 = (Int)CONST_CSTR_STRING(arg1obj);
        }
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%C' print a string with the necessary C escapes            */
    else if ( *p == 'C' ) {

      arg1obj = (Obj)arg1;
      arg1 = (Int)CONST_CSTR_STRING(arg1obj);

      /* compute how many characters this identifier requires    */
      for ( const Char * q = (const Char *)arg1; *q != '\0' && prec > 0; q++ ) {
        if      ( *q == '\n'  ) { prec -= 2; }
        else if ( *q == '\t'  ) { prec -= 2; }
        else if ( *q == '\r'  ) { prec -= 2; }
        else if ( *q == '\b'  ) { prec -= 2; }
        else if ( *q == '\01' ) { prec -= 3; }
        else if ( *q == '\02' ) { prec -= 3; }
        else if ( *q == '\03' ) { prec -= 3; }
        else if ( *q == '"'   ) { prec -= 2; }
        else if ( *q == '\\'  ) { prec -= 2; }
        else                    { prec -= 1; }
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 )  put_a_char(state, ' ');

      /* print the string                                        */
      Int i = 0;
      while (1) {
        const Char* q = CONST_CSTR_STRING(arg1obj) + i++;
        if (*q == 0)
            break;

        if      ( *q == '\n'  ) { put_a_char(state, '\\'); put_a_char(state, 'n');  }
        else if ( *q == '\t'  ) { put_a_char(state, '\\'); put_a_char(state, 't');  }
        else if ( *q == '\r'  ) { put_a_char(state, '\\'); put_a_char(state, 'r');  }
        else if ( *q == '\b'  ) { put_a_char(state, '\\'); put_a_char(state, 'b');  }
        else if ( *q == '\01' ) { put_a_char(state, '\\'); put_a_char(state, '0');
                                  put_a_char(state, '1');                }
        else if ( *q == '\02' ) { put_a_char(state, '\\'); put_a_char(state, '0');
                                  put_a_char(state, '2');                }
        else if ( *q == '\03' ) { put_a_char(state, '\\'); put_a_char(state, '0');
                                  put_a_char(state, '3');                }
        else if ( *q == '"'   ) { put_a_char(state, '\\'); put_a_char(state, '"');  }
        else if ( *q == '\\'  ) { put_a_char(state, '\\'); put_a_char(state, '\\'); }
        else                    { put_a_char(state, *q);               }
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%I' print an identifier                                    */
    else if ( *p == 'I' || *p =='H' ) {
      int found_keyword = 0;

      // If arg is a GAP obj, get out the contained string, and
      // set arg1obj so we can re-evaluate after any possible GC
      // which occurs in put_a_char
      if (*p == 'H') {
        arg1obj = (Obj)arg1;
        arg1 = (Int)CONST_CSTR_STRING(arg1obj);
      }
      else {
        arg1obj = 0;
      }

      /* check if q matches a keyword    */
      found_keyword = IsKeyword((const Char *)arg1);

      /* compute how many characters this identifier requires    */
      if (found_keyword) {
        prec--;
      }
      for ( const Char * q = (const Char *)arg1; *q != '\0'; q++ ) {
        if ( !IsIdent(*q) ) {
          prec--;
        }
        prec--;
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 ) { put_a_char(state, ' '); }

      /* print the identifier                                    */
      if ( found_keyword ) {
        put_a_char(state, '\\');
      }

      for ( Int i = 0; ((const Char *)arg1)[i] != '\0'; i++ ) {
        Char c = ((const Char *)arg1)[i];

        if ( !IsIdent(c) ) {
          put_a_char(state, '\\');
        }
        put_a_char(state, c);
        if (arg1obj) {
          arg1 = (Int)CONST_CSTR_STRING(arg1obj);
        }
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%c' print a character                                      */
    else if ( *p == 'c' ) {
      put_a_char(state, (Char)arg1);
      arg1 = arg2;
    }

    /* '%%' print a '%' character                                  */
    else if ( *p == '%' ) {
      put_a_char(state, '%');
    }

    /* '%>' increment the indentation level                        */
    else if ( *p == '>' ) {
      put_a_char(state, '\01');
      while ( --prec > 0 )
        put_a_char(state, '\01');
    }

    /* '%<' decrement the indentation level                        */
    else if ( *p == '<' ) {
      put_a_char(state, '\02');
      while ( --prec > 0 )
        put_a_char(state, '\02');
    }

    /* else raise an error                                         */
    else {
      for ( p = "%format error"; *p != '\0'; p++ )
        put_a_char(state, *p);
    }

  }

}


static void putToTheStream(void *state, Char c) {
    PutChrTo((TypOutputFile *)state, c);
}

static void
PrTo(TypOutputFile * stream, const Char * format, Int arg1, Int arg2)
{
  FormatOutput( putToTheStream, stream, format, arg1, arg2);
}

void Pr (
         const Char *      format,
         Int                 arg1,
         Int                 arg2 )
{
#ifdef HPCGAP
    if (!IO()->Output) {
        OpenDefaultOutput(&IO()->DefaultOutput);
    }
#endif
    PrTo(IO()->Output, format, arg1, arg2);
}

typedef struct {
    Char * TheBuffer;
    UInt   TheCount;
    UInt   TheLimit;
} BufferState;

static void putToTheBuffer(void *state, Char c)
{
  BufferState *buf = (BufferState *)state;
  if (buf->TheCount < buf->TheLimit)
    buf->TheBuffer[buf->TheCount++] = c;
}

void SPrTo(Char *buffer, UInt maxlen, const Char *format, Int arg1, Int arg2)
{
  BufferState buf = { buffer, 0, maxlen };
  FormatOutput(putToTheBuffer, &buf, format, arg1, arg2);
  putToTheBuffer(&buf, '\0');
}


static Obj FuncINPUT_FILENAME(Obj self)
{
    if (IO()->Input == 0)
        return MakeImmString("*defin*");

    UInt gapnameid = GetInputFilenameID(GetCurrentInput());
    return GetCachedFilename(gapnameid);
}

static Obj FuncINPUT_LINENUMBER(Obj self)
{
    return INTOBJ_INT(IO()->Input ? IO()->Input->number : 0);
}

static Obj FuncSET_PRINT_FORMATTING_STDOUT(Obj self, Obj val)
{
    BOOL format = (val != False);
    TypOutputFile * output = IO()->Output;
    while (output) {
        if (!output->stream && output->file == 1)
            output->format = format;
        output = output->prev;
    }
    IO()->PrintFormattingForStdout = format;
    return 0;
}

static Obj FuncPRINT_FORMATTING_STDOUT(Obj self)
{
    return IO()->PrintFormattingForStdout ? True : False;
}

static Obj FuncSET_PRINT_FORMATTING_ERROUT(Obj self, Obj val)
{
    BOOL format = (val != False);
    TypOutputFile * output = IO()->Output;
    while (output) {
        if (!output->stream && output->file == 3)
            output->format = format;
        output = output->prev;
    }
    IO()->PrintFormattingForErrout = format;
    return 0;
}

static Obj FuncPRINT_FORMATTING_ERROUT(Obj self)
{
    return IO()->PrintFormattingForErrout ? True : False;
}

/****************************************************************************
**
*F  FuncCALL_WITH_FORMATTING_STATUS( <status>, <func>, <args> )
**
**  Temporarily set the formatting status of the active output stream to
**  <status>, then call the function <func> with the arguments in <args>.
*/
static Obj FuncCALL_WITH_FORMATTING_STATUS(Obj self, Obj status, Obj func, Obj args)
{
    RequireTrueOrFalse(SELF_NAME, status);
    RequireSmallList(SELF_NAME, args);

    TypOutputFile * output = IO()->Output;
    if (!output)
        ErrorMayQuit("CALL_WITH_FORMATTING_STATUS called while no output is open", 0, 0);

    BOOL old = output->format;
    output->format = (status != False);

    Obj result;
    GAP_TRY
    {
        result = CallFuncList(func, args);
    }
    GAP_CATCH
    {
        output->format = old;
        GAP_THROW();
    }

    output->format = old;
    return result;
}

static Obj FuncIS_INPUT_TTY(Obj self)
{
    GAP_ASSERT(IO()->Input);
    if (IO()->Input->stream)
        return False;
    return SyBufIsTTY(IO()->Input->file) ? True : False;
}

static Obj FuncIS_OUTPUT_TTY(Obj self)
{
    GAP_ASSERT(IO()->Output);
    if (IO()->Output->stream)
        return False;
    return SyBufIsTTY(IO()->Output->file) ? True : False;
}

static Obj FuncGET_FILENAME_CACHE(Obj self)
{
  return CopyObj(FilenameCache, 1);
}

static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_0ARGS(ToggleEcho),
    GVAR_FUNC_0ARGS(CPROMPT),
    GVAR_FUNC_1ARGS(PRINT_CPROMPT, prompt),
    GVAR_FUNC_0ARGS(ALL_KEYWORDS),
    GVAR_FUNC_0ARGS(INPUT_FILENAME),
    GVAR_FUNC_0ARGS(INPUT_LINENUMBER),
    GVAR_FUNC_1ARGS(SET_PRINT_FORMATTING_STDOUT, format),
    GVAR_FUNC_0ARGS(PRINT_FORMATTING_STDOUT),
    GVAR_FUNC_1ARGS(SET_PRINT_FORMATTING_ERROUT, format),
    GVAR_FUNC_0ARGS(PRINT_FORMATTING_ERROUT),
    GVAR_FUNC_3ARGS(CALL_WITH_FORMATTING_STATUS, status, func, args),
    GVAR_FUNC_0ARGS(IS_INPUT_TTY),
    GVAR_FUNC_0ARGS(IS_OUTPUT_TTY),
    GVAR_FUNC_0ARGS(GET_FILENAME_CACHE),
    { 0, 0, 0, 0, 0 }

};

/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
#ifdef HPCGAP
    FilenameCache = NewAtomicList(T_ALIST, 0);
#else
    FilenameCache = NEW_PLIST(T_PLIST, 0);
#endif

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}

static Int InitKernel (
    StructInitInfo *    module )
{
    IO()->Input = 0;
    IO()->Output = 0;
    IO()->InputLog = 0;
    IO()->OutputLog = 0;
    IO()->PrintFormattingForStdout = TRUE;
    IO()->PrintFormattingForErrout = TRUE;

    OpenOutput(&IO()->DefaultOutput, "*stdout*", FALSE);

    InitGlobalBag( &FilenameCache, "FilenameCache" );

#ifdef HPCGAP
    /* Initialize default stream functions */
    DeclareGVar(&DEFAULT_INPUT_STREAM, "DEFAULT_INPUT_STREAM");
    DeclareGVar(&DEFAULT_OUTPUT_STREAM, "DEFAULT_OUTPUT_STREAM");

#else
    /* tell GASMAN about the global bags                                   */
    InitGlobalBag(&(IO()->InputLogFileOrStream.stream),
                  "src/io.c:InputLogFileOrStream");
    InitGlobalBag(&(IO()->OutputLogFileOrStream.stream),
                  "src/io.c:OutputLogFileOrStream");
#endif

    /* import functions from the library                                   */
    ImportFuncFromLibrary( "ReadLine", &ReadLineFunc );
    ImportFuncFromLibrary( "WriteAll", &WriteAllFunc );
    ImportFuncFromLibrary( "IsInputTextStringRep", &IsInputStringStream );
    ImportFuncFromLibrary( "IsOutputTextStringRep", &IsOutputStringStream );
    ImportFuncFromLibrary( "PositionStream", &PositionStream );
    ImportFuncFromLibrary( "SeekPositionStream", &SeekPositionStream );
    InitCopyGVar( "PrintPromptHook", &PrintPromptHook );
    InitCopyGVar( "EndLineHook", &EndLineHook );
    InitFopyGVar( "PrintFormattingStatus", &PrintFormattingStatus);
    InitFopyGVar( "SetPrintFormattingStatus", &SetPrintFormattingStatus);

    InitHdlrFuncsFromTable( GVarFuncs );
    return 0;
}

/****************************************************************************
**
*F  InitInfoIO() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "io",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,

    .moduleStateSize = sizeof(struct IOModuleState),
    .moduleStateOffsetPtr = &IOStateOffset,
};

StructInitInfo * InitInfoIO ( void )
{
    return &module;
}
