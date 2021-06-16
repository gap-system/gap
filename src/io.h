/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares functions responsible for input and output processing.
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

#ifndef GAP_IO_H
#define GAP_IO_H

#include "common.h"


/****************************************************************************
**
*T  TypInputFile  . . . . . . . . . .  structure of an open input file, local
**
**  'TypInputFile' describes the information stored for open input files.
*/
struct TypInputFile {
    // pointer to the previously active input
    struct TypInputFile * prev;

    // non-zero if input come from a string stream
    BOOL isstringstream;

    // if input comes from a stream, this points to a GAP IsInputStream object
    Obj stream;

    // holds the file identifier received from 'SyFopen' and which is passed
    // to 'SyFgets' and 'SyFclose' to identify this file
    Int file;

    // the name of the file; this is only used in error messages
    char name[256];

    //
    UInt gapnameid;

    // a buffer that holds the current input line; always terminated
    // by the character '\0'. Because 'line' holds only part of the line for
    // very long lines the last character need not be a <newline>.
    // The actual line data starts in line[1]; the first byte line[0]
    // is reserved for the "pushback buffer" used by PEEK_NEXT_CHAR.
    char line[32768];

    // the next line from the stream as GAP string
    Obj sline;

    //
    Int spos;

    //
    BOOL echo;

    // pointer to the current character within the current line
    char * ptr;

    // the number of the current line; used in error messages
    UInt number;

    // 'lastErrorLine' is an integer whose value is the number of the last
    // line on which an error was found. It is set by 'SyntaxError'.
    //
    // If 'lastErrorLine' is equal to the current line number 'SyntaxError'
    // will not print an error message. This is used to prevent the printing
    // of multiple error messages for one line, since they usually just
    // reflect the fact that the parser has not resynchronized yet.
    UInt lastErrorLine;
};


/****************************************************************************
**
*/
enum {
    // the maximal number of used line break hints
    MAXHINTS = 100,

    // the widest allowed screen width
    MAXLENOUTPUTLINE = 4096,
};


/****************************************************************************
**
*T  TypOutputFile . . . . . . . . . . structure of an open output file, local
**
**  'TypOutputFile' describes the information stored for open  output  files:
**  'file' holds the file identifier which is  received  from  'SyFopen'  and
**  which is passed to  'SyFputs'  and  'SyFclose'  to  identify  this  file.
**  'line' is a buffer that holds the current output line.
**  'pos' is the position of the current character on that line.
*/
struct TypOutputFile {
    // pointer to the previously active output
    struct TypOutputFile * prev;

    BOOL isstringstream;
    Obj  stream;
    Int  file;

    char line[MAXLENOUTPUTLINE];
    Int  pos;
    BOOL format;
    Int  indent;

    /* each hint is a triple (position, value, indent) */
    Int hints[3 * MAXHINTS + 1];
};


/****************************************************************************
**
*F * * * * * * * * * * * open input/output functions  * * * * * * * * * * * *
*/


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
**  Directly after the 'OpenInput' call the variable  'Symbol' has the value
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
**  It is not necessary to open the initial input  file, 'InitScanner' opens
**  '*stdin*' for  that purpose.  This  file on   the other   hand  cannot be
**  closed by 'CloseInput'.
*/
UInt OpenInput(TypInputFile * input, const Char * filename);


/****************************************************************************
**
*F  OpenInputStream( <stream>, <echo> ) . . .  open a stream as current input
**
**  The same as 'OpenInput' but for streams.
*/
UInt OpenInputStream(TypInputFile * input, Obj stream, BOOL echo);


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
UInt CloseInput(TypInputFile * input);


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
UInt OpenLog(const Char * filename);


/****************************************************************************
**
*F  OpenLogStream( <stream> ) . . . . . . . . . . log interaction to a stream
**
**  The same as 'OpenLog' but for streams.
*/
UInt OpenLogStream(Obj stream);


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
UInt CloseLog(void);


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
UInt OpenInputLog(const Char * filename);


/****************************************************************************
**
*F  OpenInputLogStream( <stream> )  . . . . . . . . . . log input to a stream
**
**  The same as 'OpenInputLog' but for streams.
*/
UInt OpenInputLogStream(Obj stream);


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
UInt CloseInputLog(void);

/****************************************************************************
 **
 *V  Prompt  . . . . . . . . . . . . . . . . . . . . . . prompt to be printed
 **
 **  'Prompt' holds the string that is to be printed if a  new  line  is read
 **  from the interactive files '*stdin*' or '*errin*'.
 **
 **  It is set to 'gap> ' or 'brk> ' in the read-eval-print loops and changed
 **  to the partial prompt '> ' in 'Read' after the first symbol is read.
 */
/* TL: extern  const Char *    Prompt; */

/****************************************************************************
**
*F  SetPrompt( <prompt> ) . . . . . . . . . . . . . set the user input prompt
*/
void SetPrompt(const char * prompt);

/****************************************************************************
 **
 *V  PrintPromptHook . . . . . . . . . . . . . . function for printing prompt
 *V  EndLineHook . . . . . . . . . . . function called at end of command line
 **  
 **  These functions can be set on GAP-level. If they are not bound  the 
 **  default is: Instead of 'PrintPromptHook' the 'Prompt' is printed and
 **  instead of 'EndLineHook' nothing is done.
 */
/* TL: extern Obj  PrintPromptHook; */
extern Obj  EndLineHook;

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
UInt OpenOutputLog(const Char * filename);


/****************************************************************************
**
*F  OpenOutputLogStream( <stream> )  . . . . . . . .  log output to a stream
**
**  The same as 'OpenOutputLog' but for streams.
*/
UInt OpenOutputLogStream(Obj stream);


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
UInt CloseOutputLog(void);


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
UInt OpenOutput(TypOutputFile * output, const Char * filename, BOOL append);


/****************************************************************************
**
*F  OpenOutputStream( <stream> )  . . . . . . open a stream as current output
**
**  The same as 'OpenOutput' but for streams.
*/
UInt OpenOutputStream(TypOutputFile * output, Obj stream);


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
UInt CloseOutput(TypOutputFile * output);


TypInputFile * GetCurrentInput(void);

Char GetNextChar(TypInputFile * input);
Char GET_NEXT_CHAR_NO_LC(TypInputFile * input);
Char PEEK_NEXT_CHAR(TypInputFile * input);
Char PEEK_CURR_CHAR(TypInputFile * input);

// skip the rest of the current line, ignoring line continuations
// (used to handle comments)
void SKIP_TO_END_OF_LINE(TypInputFile * input);

// get the filename of the current input
const Char * GetInputFilename(TypInputFile * input);

// get the number of the current line in the current thread's input
Int GetInputLineNumber(TypInputFile * input);

//
const Char * GetInputLineBuffer(TypInputFile * input);

//
Int GetInputLinePosition(TypInputFile * input);

// get the filenameid (if any) of the current input
UInt GetInputFilenameID(TypInputFile * input);

// get the filename (as GAP string object) with the given id
Obj GetCachedFilename(UInt id);


// Reset the indentation level of the current output to zero. The indentation
// level can be modified via the '%>' and '%<' formats of 'Pr' resp. 'PrTo'.
void ResetOutputIndent(void);

// If 'lock' is non-zero, then "lock" the current output, i.e., prevent calls
// to 'OpenOutput' or 'CloseOutput' from changing it. If 'lock' is zero, then
// release this lock again.
//
// This is used to allow the 'Test' function of the GAP library to
// consistently capture all output during testing, see 'FuncREAD_STREAM_LOOP'.
void LockCurrentOutput(BOOL lock);

/****************************************************************************
**
*F  Pr( <format>, <arg1>, <arg2> )  . . . . . . . . .  print formatted output
**
**  'Pr' is the output function. The first argument is a 'printf' like format
**  string containing   up   to 2  '%'  format   fields,  specifying  how the
**  corresponding arguments are to be  printed.  The two arguments are passed
**  as  'long'  integers.   This  is possible  since every  C object  ('int',
**  'char', pointers) except 'float' or 'double', which are not used  in GAP,
**  can be converted to a 'long' without loss of information.
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
**  You must always  cast the arguments to  '(long)' to avoid  problems  with
**  those compilers with a default integer size of 16 instead of 32 bit.  You
**  must pass 0 if you don't make use of an argument to please lint.
*/

void Pr(const Char * format, Int arg1, Int arg2);

void SPrTo(
    Char * buffer, UInt maxlen, const Char * format, Int arg1, Int arg2);


/****************************************************************************
**
*F  FlushRestOfInputLine()  . . . . . . . . . . . . discard remainder of line
*/

void FlushRestOfInputLine(TypInputFile * input);


StructInitInfo * InitInfoIO(void);

#endif // GAP_IO_H

