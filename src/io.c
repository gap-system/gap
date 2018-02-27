/****************************************************************************
**
*W  io.c
**
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

#include <src/io.h>

#include <src/bool.h>
#include <src/calls.h>
#include <src/gap.h>
#include <src/gapstate.h>
#include <src/gaputils.h>
#include <src/gvars.h>
#include <src/read.h>
#include <src/scanner.h>
#include <src/stringobj.h>
#include <src/sysfiles.h>


/****************************************************************************
**
*T  TypInputFile  . . . . . . . . . .  structure of an open input file, local
**
**  'TypInputFile' describes the  information stored  for  open input  files:
**
**  'isstream' is 'true' if input come from a stream.
**
**  'file'  holds the  file identifier  which  is received from 'SyFopen' and
**  which is passed to 'SyFgets' and 'SyFclose' to identify this file.
**
**  'name' is the name of the file, this is only used in error messages.
**
**  'line' is a  buffer that holds the  current input  line.  This is  always
**  terminated by the character '\0'.  Because 'line' holds  only part of the
**  line for very long lines the last character need not be a <newline>.
**
**  'ptr' points to the current character within that line.  This is not used
**  for the current input file, where 'In' points to the  current  character.
**
**  'number' is the number of the current line, is used in error messages.
**
**  'stream' is none zero if the input points to a stream.
**
**  'sline' contains the next line from the stream as GAP string.
**
*/
typedef struct {
    UInt   isstream;
    Int    file;
    Char   name[256];
    UInt   gapnameid;
    Char   line[32768];
    Char * ptr;
    UInt   symbol;
    Int    number;
    Obj    stream;
    UInt   isstringstream;
    Obj    sline;
    Int    spos;
    UInt   echo;
} TypInputFile;


/****************************************************************************
**
*T  TypOutputFiles  . . . . . . . . . structure of an open output file, local
**
**  'TypOutputFile' describes the information stored for open  output  files:
**  'file' holds the file identifier which is  received  from  'SyFopen'  and
**  which is passed to  'SyFputs'  and  'SyFclose'  to  identify  this  file.
**  'line' is a buffer that holds the current output line.
**  'pos' is the position of the current character on that line.
*/
/* the maximal number of used line break hints */
#define MAXHINTS 100
typedef struct {
    UInt isstream;
    UInt isstringstream;
    Int  file;
    Char line[MAXLENOUTPUTLINE];
    Int  pos;
    Int  format;
    Int  indent;

    /* each hint is a tripel (position, value, indent) */
    Int hints[3 * MAXHINTS + 1];
    Obj stream;
} TypOutputFile;


static Char GetLine(void);
static void PutLine2(TypOutputFile * output, const Char * line, UInt len);

static Obj ReadLineFunc;
static Obj WriteAllFunc;
static Obj IsStringStream;
static Obj PrintPromptHook = 0;
Obj EndLineHook = 0;
static Obj PrintFormattingStatus;

/* TODO: Eliminate race condition in HPC-GAP */
static Char promptBuf[81];

static ModuleStateOffset IOStateOffset = -1;

struct IOModuleState {

    // The stack of the open input files
    TypInputFile * InputStack[MAX_OPEN_FILES];
    int            InputStackPointer;

    // The stack of open output files
    TypOutputFile * OutputStack[MAX_OPEN_FILES];
    int             OutputStackPointer;

    // A pointer to the current input file. It points to the top of the stack
    // 'InputFiles'.
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

    Int NoSplitLine;

    Char   Pushback;
    Char * RealIn;
};

static inline struct IOModuleState * IO(void)
{
    return (struct IOModuleState *)StateSlotsAtOffset(IOStateOffset);
}

// for debugging from GDB / lldb, provide non-inline access to
// the IO state
struct IOModuleState * GetIO(void)
{
    return IO();
}

void LockCurrentOutput(Int lock)
{
    IO()->IgnoreStdoutErrout = lock ? IO()->Output : NULL;
}


/****************************************************************************
**
*F  GET_NEXT_CHAR()  . . . . . . . . . . . . .  get the next character, local
**
**  'GET_NEXT_CHAR' returns the next character from  the current input file.
**  This character is afterwards also available as '*In'.
*/


static inline Int IS_CHAR_PUSHBACK_EMPTY(void)
{
    return STATE(In) != &IO()->Pushback;
}

Char GET_NEXT_CHAR(void)
{
    if (STATE(In) == &IO()->Pushback) {
        STATE(In) = IO()->RealIn;
    }
    else
        STATE(In)++;
    if (!*STATE(In))
        GetLine();
    return *STATE(In);
}

Char PEEK_NEXT_CHAR(void)
{
    assert(IS_CHAR_PUSHBACK_EMPTY());
    // store the current character
    IO()->Pushback = *STATE(In);

    // read next character
    GET_NEXT_CHAR();

    // fake insert the previous character
    IO()->RealIn = STATE(In);
    STATE(In) = &IO()->Pushback;
    return *IO()->RealIn;
}

Char PEEK_CURR_CHAR(void)
{
    return *STATE(In);
}

const Char * GetInputFilename(void)
{
    GAP_ASSERT(IO()->Input);
    return IO()->Input->name;
}

Int GetInputLineNumber(void)
{
    GAP_ASSERT(IO()->Input);
    return IO()->Input->number;
}

const Char * GetInputLineBuffer(void)
{
    GAP_ASSERT(IO()->Input);
    return IO()->Input->line;
}

// Get current line position. In the case where we pushed back the last
// character on the previous line we return the first character of the
// current line, as we cannot retrieve the previous line.
Int GetInputLinePosition(void)
{
    if (STATE(In) == &IO()->Pushback) {
        // Subtract 2 as a value was pushed back
        Int pos = IO()->RealIn - IO()->Input->line - 2;
        if (pos < 0)
            pos = 0;
        return pos;
    }
    else {
        return STATE(In) - IO()->Input->line - 1;
    }
}

UInt GetInputFilenameID(void)
{
    GAP_ASSERT(IO()->Input);
    return IO()->Input->gapnameid;
}

void SetInputFilenameID(UInt id)
{
    GAP_ASSERT(IO()->Input);
    IO()->Input->gapnameid = id;
}


/****************************************************************************
**
*F * * * * * * * * * * * open input/output functions  * * * * * * * * * * * *
*/

#if !defined(HPCGAP)
static TypInputFile  InputFiles[MAX_OPEN_FILES];
static TypOutputFile OutputFiles[MAX_OPEN_FILES];
#endif

static TypInputFile * PushNewInput(void)
{
    GAP_ASSERT(IO()->InputStackPointer < MAX_OPEN_FILES);
    const int sp = IO()->InputStackPointer++;
#ifdef HPCGAP
    if (!IO()->InputStack[sp]) {
        IO()->InputStack[sp] = AllocateMemoryBlock(sizeof(TypInputFile));
    }
#endif
    GAP_ASSERT(IO()->InputStack[sp]);
    return IO()->InputStack[sp];
}

static TypOutputFile * PushNewOutput(void)
{
    GAP_ASSERT(IO()->OutputStackPointer < MAX_OPEN_FILES);
    const int sp = IO()->OutputStackPointer++;
#ifdef HPCGAP
    if (!IO()->OutputStack[sp]) {
        IO()->OutputStack[sp] = AllocateMemoryBlock(sizeof(TypOutputFile));
    }
#endif
    GAP_ASSERT(IO()->OutputStack[sp]);
    return IO()->OutputStack[sp];
}

#ifdef HPCGAP
GVarDescriptor DEFAULT_INPUT_STREAM;
GVarDescriptor DEFAULT_OUTPUT_STREAM;

UInt OpenDefaultInput( void )
{
  Obj func, stream;
  stream = TLS(DefaultInput);
  if (stream)
      return OpenInputStream(stream, 0);
  func = GVarOptFunction(&DEFAULT_INPUT_STREAM);
  if (!func)
    return OpenInput("*stdin*");
  stream = CALL_0ARGS(func);
  if (!stream)
    ErrorQuit("DEFAULT_INPUT_STREAM() did not return a stream", 0L, 0L);
  if (IsStringConv(stream))
    return OpenInput(CSTR_STRING(stream));
  TLS(DefaultInput) = stream;
  return OpenInputStream(stream, 0);
}

UInt OpenDefaultOutput( void )
{
  Obj func, stream;
  stream = TLS(DefaultOutput);
  if (stream)
    return OpenOutputStream(stream);
  func = GVarOptFunction(&DEFAULT_OUTPUT_STREAM);
  if (!func)
    return OpenOutput("*stdout*");
  stream = CALL_0ARGS(func);
  if (!stream)
    ErrorQuit("DEFAULT_OUTPUT_STREAM() did not return a stream", 0L, 0L);
  if (IsStringConv(stream))
    return OpenOutput(CSTR_STRING(stream));
  TLS(DefaultOutput) = stream;
  return OpenOutputStream(stream);
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
**  Directely after the 'OpenInput' call the variable  'Symbol' has the value
**  'S_ILLEGAL' to indicate that no symbol has yet been  read from this file.
**  The first symbol is read by 'Read' in the first call to 'Match' call.
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
**  It is not neccessary to open the initial input  file, 'InitScanner' opens
**  '*stdin*' for  that purpose.  This  file on   the other   hand  cannot be
**  closed by 'CloseInput'.
*/
UInt OpenInput (
    const Char *        filename )
{
    Int                 file;

    /* fail if we can not handle another open input file                   */
    if (IO()->InputStackPointer == MAX_OPEN_FILES)
        return 0;

#ifdef HPCGAP
    /* Handle *defin*; redirect *errin* to *defin* if the default
     * channel is already open. */
    if (! strcmp(filename, "*defin*") ||
        (! strcmp(filename, "*errin*") && TLS(DefaultInput)) )
        return OpenDefaultInput();
#endif

    /* try to open the input file                                          */
    file = SyFopen( filename, "r" );
    if ( file == -1 )
        return 0;

    /* remember the current position in the current file                   */
    if (IO()->InputStackPointer > 0) {
        GAP_ASSERT(IS_CHAR_PUSHBACK_EMPTY());
        IO()->Input->ptr = STATE(In);
        IO()->Input->symbol = STATE(Symbol);
    }

    /* enter the file identifier and the file name                         */
    IO()->Input = PushNewInput();
    IO()->Input->isstream = 0;
    IO()->Input->file = file;
    IO()->Input->name[0] = '\0';

    // enable echo for stdin and errin
    if (!strcmp("*errin*", filename) || !strcmp("*stdin*", filename))
        IO()->Input->echo = 1;
    else
        IO()->Input->echo = 0;

    strlcpy(IO()->Input->name, filename, sizeof(IO()->Input->name));
    IO()->Input->gapnameid = 0;

    /* start with an empty line and no symbol                              */
    STATE(In) = IO()->Input->line;
    STATE(In)[0] = STATE(In)[1] = '\0';
    STATE(Symbol) = S_ILLEGAL;
    IO()->Input->number = 1;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenInputStream( <stream>, <echo> ) . . .  open a stream as current input
**
**  The same as 'OpenInput' but for streams.
*/
UInt OpenInputStream(Obj stream, UInt echo)
{
    /* fail if we can not handle another open input file                   */
    if (IO()->InputStackPointer == MAX_OPEN_FILES)
        return 0;

    /* remember the current position in the current file                   */
    if (IO()->InputStackPointer > 0) {
        GAP_ASSERT(IS_CHAR_PUSHBACK_EMPTY());
        IO()->Input->ptr = STATE(In);
        IO()->Input->symbol = STATE(Symbol);
    }

    /* enter the file identifier and the file name                         */
    IO()->Input = PushNewInput();
    IO()->Input->isstream = 1;
    IO()->Input->stream = stream;
    IO()->Input->isstringstream =
        (CALL_1ARGS(IsStringStream, stream) == True);
    if (IO()->Input->isstringstream) {
        IO()->Input->sline = CONST_ADDR_OBJ(stream)[2];
        IO()->Input->spos = INT_INTOBJ(CONST_ADDR_OBJ(stream)[1]);
    }
    else {
        IO()->Input->sline = 0;
    }
    IO()->Input->file = -1;
    IO()->Input->echo = echo;
    strlcpy(IO()->Input->name, "stream", sizeof(IO()->Input->name));
    IO()->Input->gapnameid = 0;

    /* start with an empty line and no symbol                              */
    STATE(In) = IO()->Input->line;
    STATE(In)[0] = STATE(In)[1] = '\0';
    STATE(Symbol) = S_ILLEGAL;
    IO()->Input->number = 1;

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
**  'CloseInput' until it returns 0, therebye closing all open input files.
**
**  Calling 'CloseInput' if the  corresponding  'OpenInput' call failed  will
**  close the current output file, which will lead to very strange behaviour.
*/
UInt CloseInput ( void )
{
    /* refuse to close the initial input file                              */
    if (IO()->InputStackPointer <= 1)
        return 0;

    /* close the input file                                                */
    if (!IO()->Input->isstream) {
        SyFclose(IO()->Input->file);
    }

    /* don't keep GAP objects alive unnecessarily */
    memset(IO()->Input, 0, sizeof(TypInputFile));

    /* revert to last file                                                 */
    const int sp = --IO()->InputStackPointer;
    IO()->Input = IO()->InputStack[sp - 1];
    STATE(In) = IO()->Input->ptr;
    STATE(Symbol) = IO()->Input->symbol;

    /* indicate success                                                    */
    return 1;
}

/****************************************************************************
**
*F  FlushRestOfInputLine()  . . . . . . . . . . . . discard remainder of line
*/

void FlushRestOfInputLine( void )
{
  STATE(In)[0] = STATE(In)[1] = '\0';
  /* IO()->Input->number = 1; */
  STATE(Symbol) = S_ILLEGAL;
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
    IO()->OutputLogFileOrStream.file = SyFopen(filename, "w");
    IO()->OutputLogFileOrStream.isstream = 0;
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
    IO()->OutputLogFileOrStream.isstream = 1;
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
    if (!IO()->InputLog->isstream) {
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
    IO()->InputLogFileOrStream.file = SyFopen(filename, "w");
    IO()->InputLogFileOrStream.isstream = 0;
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
    IO()->InputLogFileOrStream.isstream = 1;
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
    if (!IO()->InputLog->isstream) {
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
    IO()->OutputLogFileOrStream.isstream = 0;
    IO()->OutputLogFileOrStream.file = SyFopen(filename, "w");
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
    IO()->OutputLogFileOrStream.isstream = 1;
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
    if (!IO()->OutputLog->isstream) {
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
**  It is not neccessary to open the initial output file, 'InitScanner' opens
**  '*stdout*' for that purpose.  This  file  on the other hand   can not  be
**  closed by 'CloseOutput'.
*/
UInt OpenOutput (
    const Char *        filename )
{
    Int                 file;

    // do nothing for stdout and errout if caught
    if (IO()->Output != NULL && IO()->IgnoreStdoutErrout == IO()->Output &&
        (strcmp(filename, "*errout*") == 0 ||
         strcmp(filename, "*stdout*") == 0)) {
        return 1;
    }

    /* fail if we can not handle another open output file                  */
    if (IO()->OutputStackPointer == MAX_OPEN_FILES)
        return 0;

#ifdef HPCGAP
    /* Handle *defout* specially; also, redirect *errout* if we already
     * have a default channel open. */
    if ( ! strcmp( filename, "*defout*" ) ||
         (! strcmp( filename, "*errout*" ) && TLS(threadID) != 0) )
        return OpenDefaultOutput();
#endif

    /* try to open the file                                                */
    file = SyFopen( filename, "w" );
    if ( file == -1 )
        return 0;

    /* put the file on the stack, start at position 0 on an empty line     */
    IO()->Output = PushNewOutput();
    IO()->Output->file = file;
    IO()->Output->line[0] = '\0';
    IO()->Output->pos = 0;
    IO()->Output->indent = 0;
    IO()->Output->isstream = 0;
    IO()->Output->format = 1;

    /* variables related to line splitting, very bad place to split        */
    IO()->Output->hints[0] = -1;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenOutputStream( <stream> )  . . . . . . open a stream as current output
**
**  The same as 'OpenOutput' (and also 'OpenAppend') but for streams.
*/


UInt OpenOutputStream (
    Obj                 stream )
{
    /* fail if we can not handle another open output file                  */
    if (IO()->OutputStackPointer == MAX_OPEN_FILES)
        return 0;

    /* put the file on the stack, start at position 0 on an empty line     */
    IO()->Output = PushNewOutput();
    IO()->Output->stream = stream;
    IO()->Output->isstringstream =
        (CALL_1ARGS(IsStringStream, stream) == True);
    IO()->Output->format =
        (CALL_1ARGS(PrintFormattingStatus, stream) == True);
    IO()->Output->line[0] = '\0';
    IO()->Output->pos = 0;
    IO()->Output->indent = 0;
    IO()->Output->isstream = 1;

    /* variables related to line splitting, very bad place to split        */
    IO()->Output->hints[0] = -1;

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
UInt CloseOutput ( void )
{
    // silently refuse to close the test output file; this is probably an
    // attempt to close *errout* which is silently not opened, so let's
    // silently not close it
    if (IO()->IgnoreStdoutErrout == IO()->Output)
        return 1;

    /* refuse to close the initial output file '*stdout*'                  */
#ifdef HPCGAP
    if (IO()->OutputStackPointer <= 1 && IO()->Output->isstream &&
        TLS(DefaultOutput) == IO()->Output->stream)
        return 0;
#else
    if (IO()->OutputStackPointer <= 1)
        return 0;
#endif

    /* flush output and close the file                                     */
    Pr( "%c", (Int)'\03', 0L );
    if (!IO()->Output->isstream) {
        SyFclose(IO()->Output->file);
    }

    /* revert to previous output file and indicate success                 */
    const int sp = --IO()->OutputStackPointer;
    IO()->Output = sp ? IO()->OutputStack[sp - 1] : 0;

    return 1;
}


/****************************************************************************
**
*F  OpenAppend( <filename> )  . . open a file as current output for appending
**
**  'OpenAppend' opens the file  with the name  <filename> as current output.
**  All subsequent output will go  to that file, until either   it is  closed
**  again  with 'CloseOutput' or  another  file is  opened with 'OpenOutput'.
**  Unlike 'OpenOutput' 'OpenAppend' does not truncate the file to size 0  if
**  it exists.  Appart from that 'OpenAppend' is equal to 'OpenOutput' so its
**  description applies to 'OpenAppend' too.
*/
UInt OpenAppend (
    const Char *        filename )
{
    Int                 file;

    /* fail if we can not handle another open output file                  */
    if (IO()->OutputStackPointer == MAX_OPEN_FILES)
        return 0;

#ifdef HPCGAP
    if ( ! strcmp( filename, "*defout*") )
        return OpenDefaultOutput();
#endif

    /* try to open the file                                                */
    file = SyFopen( filename, "a" );
    if ( file == -1 )
        return 0;

    /* put the file on the stack, start at position 0 on an empty line     */
    IO()->Output = PushNewOutput();
    IO()->Output->file = file;
    IO()->Output->line[0] = '\0';
    IO()->Output->pos = 0;
    IO()->Output->indent = 0;
    IO()->Output->isstream = 0;

    /* variables related to line splitting, very bad place to split        */
    IO()->Output->hints[0] = -1;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * input functions  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  GetLine2( <input>, <buffer>, <length> ) . . . . . . . . get a line, local
*/
static Int GetLine2 (
    TypInputFile *          input,
    Char *                  buffer,
    UInt                    length )
{
#ifdef HPCGAP
    if ( ! input ) {
        input = IO()->Input;
        if (!input)
            OpenDefaultInput();
        input = IO()->Input;
    }
#endif

    if ( input->isstream ) {
        if (input->sline == 0 ||
            (IS_STRING(input->sline) &&
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
        UInt count = input->spos;
        Char *ptr = (Char *)CHARS_STRING(input->sline) + count;
        UInt len = GET_LEN_STRING(input->sline);
        Char *bend = buffer + length - 2;
        while (bptr < bend && count < len && *ptr != '\n' && *ptr != '\r') {
            *bptr++ = *ptr++;
            count++;
        }
        /* we also copy an end of line if there is one */
        if (*ptr == '\n' || *ptr == '\r') {
            *bptr++ = *ptr++;
            count++;
        }
        *bptr = '\0';
        input->spos = count;

        /* if input->stream is a string stream, we have to adjust the
           position counter in the stream object as well */
        if (input->isstringstream) {
            ADDR_OBJ(input->stream)[1] = INTOBJ_INT(count);
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
*F  GetLine() . . . . . . . . . . . . . . . . . . . . . . . get a line, local
**
**  'GetLine'  fetches another  line from  the  input 'Input' into the buffer
**  'Input->line', sets the pointer 'In' to  the beginning of this buffer and
**  returns the first character from the line.
**
**  If   the input file is  '*stdin*'   or '*errin*' 'GetLine'  first  prints
**  'Prompt', unless it is '*stdin*' and GAP was called with option '-q'.
**
**  If there is an  input logfile in use  and the input  file is '*stdin*' or
**  '*errin*' 'GetLine' echoes the new line to the logfile.
*/
Char GetLine ( void )
{
    /* if file is '*stdin*' or '*errin*' print the prompt and flush it     */
    /* if the GAP function `PrintPromptHook' is defined then it is called  */
    /* for printing the prompt, see also `EndLineHook'                     */
    if (!IO()->Input->isstream) {
        if (IO()->Input->file == 0) {
            if ( ! SyQuiet ) {
                if (IO()->Output->pos > 0)
                    Pr("\n", 0L, 0L);
                if ( PrintPromptHook )
                     Call0ArgsInNewReader( PrintPromptHook );
                else
                     Pr( "%s%c", (Int)STATE(Prompt), (Int)'\03' );
            } else
                Pr( "%c", (Int)'\03', 0L );
        }
        else if (IO()->Input->file == 2) {
            if (IO()->Output->pos > 0)
                Pr("\n", 0L, 0L);
            if ( PrintPromptHook )
                 Call0ArgsInNewReader( PrintPromptHook );
            else
                 Pr( "%s%c", (Int)STATE(Prompt), (Int)'\03' );
        }
    }

    /* bump the line number                                                */
    if (IO()->Input->line < STATE(In) &&
        (*(STATE(In) - 1) == '\n' || *(STATE(In) - 1) == '\r')) {
        IO()->Input->number++;
    }

    /* initialize 'STATE(In)', no errors on this line so far                      */
    STATE(In) = IO()->Input->line;
    STATE(In)[0] = '\0';
    STATE(NrErrLine) = 0;

    /* try to read a line                                              */
    if (!GetLine2(IO()->Input, IO()->Input->line,
                  sizeof(IO()->Input->line))) {
        STATE(In)[0] = '\377';  STATE(In)[1] = '\0';
    }

    /* if necessary echo the line to the logfile                      */
    if (IO()->InputLog != 0 && IO()->Input->echo == 1)
        if ( !(STATE(In)[0] == '\377' && STATE(In)[1] == '\0') )
            PutLine2(IO()->InputLog, STATE(In), strlen(STATE(In)));

    /* return the current character                                        */
    return *STATE(In);
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

void PutLine2(
        TypOutputFile *         output,
        const Char *            line,
        UInt                    len )
{
  Obj                     str;
  UInt                    lstr;
  if ( output->isstream ) {
    /* special handling of string streams, where we can copy directly */
    if (output->isstringstream) {
      str = CONST_ADDR_OBJ(output->stream)[1];
      lstr = GET_LEN_STRING(str);
      GROW_STRING(str, lstr+len);
      memcpy(CHARS_STRING(str) + lstr, line, len);
      SET_LEN_STRING(str, lstr + len);
      *(CHARS_STRING(str) + lstr + len) = '\0';
      CHANGED_BAG(str);
      return;
    }

    /* Space for the null is allowed for in GAP strings */
    C_NEW_STRING( str, len, line );

    /* now delegate to library level */
    CALL_2ARGS( WriteAllFunc, output->stream, str );
  }
  else {
    SyFputs( line, output->file );
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
void PutLineTo(TypOutputFile * stream, UInt len)
{
  PutLine2( stream, stream->line, len );

  /* if neccessary echo it to the logfile                                */
  if (IO()->OutputLog != 0 && !stream->isstream) {
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
void addLineBreakHint(TypOutputFile * stream,
                      Int             pos,
                      Int             val,
                      Int             indentdiff)
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
Int nrLineBreak(TypOutputFile * stream)
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


void PutChrTo(TypOutputFile * stream, Char ch)
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

Obj FuncToggleEcho( Obj self)
{
    IO()->Input->echo = 1 - IO()->Input->echo;
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncCPROMPT( )
**
**  returns the current `Prompt' as GAP string.
*/
Obj FuncCPROMPT( Obj self)
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

Obj FuncPRINT_CPROMPT( Obj self, Obj prompt )
{
  if (IS_STRING_REP(prompt)) {
    /* by assigning to Prompt we also tell readline (if used) what the
       current prompt is  */
    strlcpy(promptBuf, CSTR_STRING(prompt), sizeof(promptBuf));
    STATE(Prompt) = promptBuf;
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
*F  Pr( <format>, <arg1>, <arg2> )  . . . . . . . . .  print formatted output
*F  PrTo( <stream>, <format>, <arg1>, <arg2> )  . . .  print formatted output
**
**  'Pr' is the output function. The first argument is a 'printf' like format
**  string containing   up   to 2  '%'  format   fields,   specifing  how the
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
**  '%C'    the corresponding argument is the address of  a  null  terminated
**          character string which is printed with C escapes.
**  '%d'    the corresponding argument is a signed integer, which is printed.
**          Between the '%' and the 'd' an integer might be used  to  specify
**          the width of a field in which the integer is right justified.  If
**          the first character is '0' 'Pr' pads with '0' instead of <space>.
**  '%i'    is a synonym of %d, in line with recent C library developements
**  '%I'    print an identifier
**  '%>'    increment the indentation level.
**  '%<'    decrement the indentation level.
**  '%%'    can be used to print a single '%' character. No argument is used.
**
**  You must always  cast the arguments to  '(Int)'  to avoid  problems  with
**  those compilers with a default integer size of 16 instead of 32 bit.  You
**  must pass 0L if you don't make use of an argument to please lint.
*/
static inline void FormatOutput(
    void (*put_a_char)(void *state, Char c),
    void *state, const Char *format, Int arg1, Int arg2 )
{
  const Char *        p;
  Char *              q;
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

    /* '%s' print a string                                         */
    else if ( *p == 's' ) {

      /* compute how many characters this identifier requires    */
      for ( q = (Char*)arg1; *q != '\0' && prec > 0; q++ ) {
        prec--;
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 )  put_a_char(state, ' ');

      /* print the string                                        */
      /* must be careful that line breaks don't go inside
         escaped sequences \n or \123 or similar */
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
          if (*q == '\\' && IO()->NoSplitLine == 0) {
              if (*(q + 1) < '8' && *(q + 1) >= '0')
                  IO()->NoSplitLine = 3;
              else
                  IO()->NoSplitLine = 1;
        }
        else if (IO()->NoSplitLine > 0)
            IO()->NoSplitLine--;
        put_a_char(state, *q);
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%S' print a string with the necessary escapes              */
    else if ( *p == 'S' ) {

      /* compute how many characters this identifier requires    */
      for ( q = (Char*)arg1; *q != '\0' && prec > 0; q++ ) {
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

      /* print the string                                        */
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
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
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%C' print a string with the necessary C escapes            */
    else if ( *p == 'C' ) {

      /* compute how many characters this identifier requires    */
      for ( q = (Char*)arg1; *q != '\0' && prec > 0; q++ ) {
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
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
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
    else if ( *p == 'I' ) {
      int found_keyword = 0;

      /* check if q matches a keyword    */
      q = (Char*)arg1;
      found_keyword = IsKeyword(q);

      /* compute how many characters this identifier requires    */
      if (found_keyword) {
        prec--;
      }
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
        if ( !IsIdent(*q) && !IsDigit(*q) ) {
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
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
        if ( !IsIdent(*q) && !IsDigit(*q) ) {
          put_a_char(state, '\\');
        }
        put_a_char(state, *q);
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
        OpenDefaultOutput();
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


Obj FuncINPUT_FILENAME( Obj self) {
  Obj s;
  if (IO()->Input) {
      s = MakeString(IO()->Input->name);
  } else {
      s = MakeString("*defin*");
  }
  return s;
}

Obj FuncINPUT_LINENUMBER( Obj self) {
    return INTOBJ_INT(IO()->Input ? IO()->Input->number : 0);
}

Obj FuncSET_PRINT_FORMATTING_STDOUT(Obj self, Obj val) {
    IO()->OutputStack[1]->format = (val != False);
    return val;
}

Obj FuncIS_INPUT_TTY(Obj self)
{
    GAP_ASSERT(IO()->Input);
    if (IO()->Input->isstream)
        return False;
    return syBuf[IO()->Input->file].isTTY ? True : False;
}

Obj FuncIS_OUTPUT_TTY(Obj self)
{
    GAP_ASSERT(IO()->Output);
    if (IO()->Output->isstream)
        return False;
    return syBuf[IO()->Output->file].isTTY ? True : False;
}

static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(ToggleEcho, 0, ""),
    GVAR_FUNC(CPROMPT, 0, ""),
    GVAR_FUNC(PRINT_CPROMPT, 1, "prompt"),
    GVAR_FUNC(INPUT_FILENAME, 0, ""),
    GVAR_FUNC(INPUT_LINENUMBER, 0, ""),
    GVAR_FUNC(SET_PRINT_FORMATTING_STDOUT, 1, "format"),
    GVAR_FUNC(IS_INPUT_TTY, 0, ""),
    GVAR_FUNC(IS_OUTPUT_TTY, 0, ""),
    { 0, 0, 0, 0, 0 }

};

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
    return 0;
}

#if !defined(HPCGAP)
static Char OutputFilesStreamCookie[MAX_OPEN_FILES][9];
static Char InputFilesStreamCookie[MAX_OPEN_FILES][9];
static Char InputFilesSlineCookie[MAX_OPEN_FILES][9];
#endif

static Int InitKernel (
    StructInitInfo *    module )
{
    IO()->Input = 0;
    IO()->Output = 0;
    IO()->InputLog = 0;
    IO()->OutputLog = 0;

#if !defined(HPCGAP)
    for (Int i = 0; i < MAX_OPEN_FILES; i++) {
        IO()->InputStack[i] = &InputFiles[i];
        IO()->OutputStack[i] = &OutputFiles[i];
    }
#endif

    OpenInput("*stdin*");
    OpenOutput("*stdout*");

#ifdef HPCGAP
    /* Initialize default stream functions */
    DeclareGVar(&DEFAULT_INPUT_STREAM, "DEFAULT_INPUT_STREAM");
    DeclareGVar(&DEFAULT_OUTPUT_STREAM, "DEFAULT_OUTPUT_STREAM");

#else
    // Initialize cookies for streams. Also initialize the cookies for the
    // GAP strings which hold the latest lines read from the streams  and the
    // name of the current input file. For HPC-GAP we don't need the cookies
    // anymore, since the data got moved to thread-local storage.
    for (Int i = 0; i < MAX_OPEN_FILES; i++) {
        strxcpy(OutputFilesStreamCookie[i], "ostream0", sizeof(OutputFilesStreamCookie[i]));
        OutputFilesStreamCookie[i][7] = '0' + i;
        InitGlobalBag(&(OutputFiles[i].stream), &(OutputFilesStreamCookie[i][0]));

        strxcpy(InputFilesStreamCookie[i], "istream0", sizeof(InputFilesStreamCookie[i]));
        InputFilesStreamCookie[i][7] = '0' + i;
        InitGlobalBag(&(InputFiles[i].stream), &(InputFilesStreamCookie[i][0]));

        strxcpy(InputFilesSlineCookie[i], "isline 0", sizeof(InputFilesSlineCookie[i]));
        InputFilesSlineCookie[i][7] = '0' + i;
        InitGlobalBag(&(InputFiles[i].sline), &(InputFilesSlineCookie[i][0]));
    }

    /* tell GASMAN about the global bags                                   */
    InitGlobalBag(&(IO()->InputLogFileOrStream.stream),
                  "src/scanner.c:InputLogFileOrStream");
    InitGlobalBag(&(IO()->OutputLogFileOrStream.stream),
                  "src/scanner.c:OutputLogFileOrStream");
#endif

    /* import functions from the library                                   */
    ImportFuncFromLibrary( "ReadLine", &ReadLineFunc );
    ImportFuncFromLibrary( "WriteAll", &WriteAllFunc );
    ImportFuncFromLibrary( "IsInputTextStringRep", &IsStringStream );
    InitCopyGVar( "PrintPromptHook", &PrintPromptHook );
    InitCopyGVar( "EndLineHook", &EndLineHook );
    InitFopyGVar( "PrintFormattingStatus", &PrintFormattingStatus);

    InitHdlrFuncsFromTable( GVarFuncs );
    /* return success                                                      */
    return 0;
}

static void InitModuleState(ModuleStateOffset offset)
{
}

/****************************************************************************
**
*F  InitInfoIO() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "scanner",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoIO ( void )
{
    IOStateOffset =
        RegisterModuleState(sizeof(struct IOModuleState), InitModuleState, 0);
    return &module;
}
