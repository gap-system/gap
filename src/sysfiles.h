/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares operating system dependent functions dealing with file
**  and stream operations.
*/

#ifndef GAP_SYSFILES_H
#define GAP_SYSFILES_H

#include "system.h"

#include <stddef.h>


/****************************************************************************
**
*F  SyGAPCRC( <name> )  . . . . . . . . . . . . . . . . . . crc of a GAP file
**
**  This function should  be clever and handle  white spaces and comments but
**  one has to certain that such characters are not ignored in strings.
*/
Int4 SyGAPCRC(const Char * name);

/****************************************************************************
**
*F  SyGetOsRelease( )  . . . . . . . . . . . . . . . . . . . . get name of OS
**
**  Get the release of the operating system kernel.
*/
Obj SyGetOsRelease(void);

/****************************************************************************
**

*F * * * * * * * * * * * * * * * window handler * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  syWinPut( <fid>, <cmd>, <str> ) . . . . send a line to the window handler
**
**  'syWinPut'  send the command   <cmd> and the  string  <str> to the window
**  handler associated with the  file identifier <fid>.   In the string <str>
**  '@'  characters are duplicated, and   control characters are converted to
**  '@<chr>', e.g., <newline> is converted to '@J'.
*/
void syWinPut(Int fid, const Char * cmd, const Char * str);


/****************************************************************************
**
*F  SyWinCmd( <str>, <len> )  . . . . . . . . . . . .  . execute a window cmd
**
**  'SyWinCmd' send   the  command <str> to  the   window  handler (<len>  is
**  ignored).  In the string <str> '@' characters are duplicated, and control
**  characters  are converted to  '@<chr>', e.g.,  <newline> is converted  to
**  '@J'.  Then  'SyWinCmd' waits for  the window handlers answer and returns
**  that string.
*/
const Char * SyWinCmd(const Char * str, UInt len);


/****************************************************************************
**
*F * * * * * * * * * * * * * * * * open/close * * * * * * * * * * * * * * * *
*/


UInt SySetBuffering(UInt fid);

void SyRedirectStderrToStdOut(void);

/****************************************************************************
**
*F  SyBufFileno( <fid> ) . . . . . . . . . . . .  get operating system fileno
**
**  Given a 'syBuf' buffer id, return the associated file descriptor, if any.
*/
int SyBufFileno(Int fid);

/****************************************************************************
**
*F  SyBufIsTTY( <fid> ) . . . . . . . . . . . . determine if handle for a tty
**
**  Given a 'syBuf' buffer id, return 1 if it references a TTY, else 0
*/
BOOL SyBufIsTTY(Int fid);


// HACK: set 'ateof' to true for the given 'syBuf' entry
void SyBufSetEOF(Int fid);


/****************************************************************************
**
*F  SyFopen( <name>, <mode>, <transparent_compress> )
*F                                             open the file with name <name>
**
**  The function 'SyFopen'  is called to open the file with the name  <name>.
**  If <mode> is "r" it is opened for reading, in this case  it  must  exist.
**  If <mode> is "w" it is opened for writing, it is created  if  necessary.
**  If <mode> is "a" it is opened for appending, i.e., it is  not  truncated.
**
**  'SyFopen' returns an integer used by the scanner to  identify  the  file.
**  'SyFopen' returns -1 if it cannot open the file.
**
**  The following standard files names and file identifiers  are  guaranteed:
**  'SyFopen( "*stdin*", "r", ..)' returns 0, the standard input file.
**  'SyFopen( "*stdout*","w", ..)' returns 1, the standard outpt file.
**  'SyFopen( "*errin*", "r", ..)' returns 2, the brk loop input file.
**  'SyFopen( "*errout*","w", ..)' returns 3, the error messages file.
**
**  If it is necessary  to adjust the filename  this should be done here, the
**  filename convention used in GAP is that '/' is the directory separator.
**
**  Right now GAP does not read nonascii files, but if this changes sometimes
**  'SyFopen' must adjust the mode argument to open the file in binary mode.
**
**  If <transparent_compress> is TRUE, files with names ending '.gz' will be
**  automatically compressed/decompressed using gzip.
*/
Int SyFopen(const Char * name, const Char * mode, BOOL transparent_compress);


/****************************************************************************
**
*F  SyFclose( <fid> ) . . . . . . . . . . . . . . . . .  close the file <fid>
**
**  'SyFclose' closes the file with the identifier <fid>  which  is  obtained
**  from 'SyFopen'.
*/
Int SyFclose(Int fid);


/****************************************************************************
**
*F  SyIsEndOfFile( <fid> )  . . . . . . . . . . . . . . . end of file reached
*/
Int SyIsEndOfFile(Int fid);

/****************************************************************************
**
*F  syStartraw( <fid> ) . . . . . . start raw mode on input file <fid>, local
**
**  'syStartraw' tries to put the file with the file  identifier  <fid>  into
**  raw mode.  I.e.,  disabling  echo  and  any  buffering.  It also finds  a
**  place to put the echoing  for  'syEchoch'.  If  'syStartraw'  succedes it
**  returns 1, otherwise, e.g., if the <fid> is not a terminal, it returns 0.
**
**  'syStopraw' stops the raw mode for the file  <fid>  again,  switching  it
**  back into whatever mode the terminal had before 'syStartraw'.
**
*/

UInt syStartraw(Int fid);

void syStopraw(Int fid);


/****************************************************************************
**
*F  SyFgets( <line>, <lenght>, <fid> )  . . . . .  get a line from file <fid>
**
**  'SyFgets' is called to read a line from the file  with  identifier <fid>.
**  'SyFgets' (like 'fgets') reads characters until either  <length>-1  chars
**  have been read or until a <newline> or an  <eof> character is encoutered.
**  It retains the '\n' (unlike 'gets'), if any, and appends '\0' to  <line>.
**  'SyFgets' returns <line> if any char has been read, otherwise '(char*)0'.
**
**  'SyFgets'  allows to edit  the input line if the  file  <fid> refers to a
**  terminal with the following commands:
**
**      <ctr>-A move the cursor to the beginning of the line.
**      <esc>-B move the cursor to the beginning of the previous word.
**      <ctr>-B move the cursor backward one character.
**      <ctr>-F move the cursor forward  one character.
**      <esc>-F move the cursor to the end of the next word.
**      <ctr>-E move the cursor to the end of the line.
**
**      <ctr>-H, <del> delete the character left of the cursor.
**      <ctr>-D delete the character under the cursor.
**      <ctr>-K delete up to the end of the line.
**      <esc>-D delete forward to the end of the next word.
**      <esc>-<del> delete backward to the beginning of the last word.
**      <ctr>-X delete entire input line, and discard all pending input.
**      <ctr>-Y insert (yank) a just killed text.
**
**      <ctr>-T exchange (twiddle) current and previous character.
**      <esc>-U uppercase next word.
**      <esc>-L lowercase next word.
**      <esc>-C capitalize next word.
**
**      <tab>   complete the identifier before the cursor.
**      <ctr>-L insert last input line before current character.
**      <ctr>-P redisplay the last input line, another <ctr>-P will redisplay
**              the line before that, etc.  If the cursor is not in the first
**              column only the lines starting with the string to the left of
**              the cursor are taken. The history is limitied to ~8000 chars.
**      <ctr>-N Like <ctr>-P but goes the other way round through the history
**      <esc>-< goes to the beginning of the history.
**      <esc>-> goes to the end of the history.
**      <ctr>-O accept this line and perform a <ctr>-N.
**
**      <ctr>-V enter next character literally.
**      <ctr>-U execute the next command 4 times.
**      <esc>-<num> execute the next command <num> times.
**      <esc>-<ctr>-L repaint input line.
**
**  Not yet implemented commands:
**
**      <ctr>-S search interactive for a string forward.
**      <ctr>-R search interactive for a string backward.
**      <esc>-Y replace yanked string with previously killed text.
**      <ctr>-_ undo a command.
**      <esc>-T exchange two words.
*/
Char * SyFgets(Char * line, UInt length, Int fid);


/****************************************************************************
**
*F  SyFputs( <line>, <fid> )  . . . . . . . .  write a line to the file <fid>
**
**  'SyFputs' is called to put the  <line>  to the file identified  by <fid>.
*/
void SyFputs(const Char * line, Int fid);


Int SyRead(Int fid, void * ptr, size_t len);
Int SyWrite(Int fid, const void * ptr, size_t len);

Int SyReadWithBuffer(Int fid, void * ptr, size_t len);

/****************************************************************************
**
*F  SyIsIntr() . . . . . . . . . . . . . . . . check whether user hit <ctr>-C
**
**  'SyIsIntr' is called from the evaluator at  regular  intervals  to  check
**  whether the user hit '<ctr>-C' to interrupt a computation.
**
**  'SyIsIntr' returns 1 if the user typed '<ctr>-C' and 0 otherwise.
*/

void SyInstallAnswerIntr(void);

UInt SyIsIntr(void);


/****************************************************************************
**
*F * * * * * * * * * * * * * * * * * output * * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  SyEchoch( <ch>, <fid> ) . . . . . . . . . . . echo a char to <fid>, local
*/
Int SyEchoch(Int ch, Int fid);


/****************************************************************************
**
*F * * * * * * * * * * * * * * * * * input  * * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  SyFtell( <fid> )  . . . . . . . . . . . . . . . . . .  position of stream
*/
Int SyFtell(Int fid);


/****************************************************************************
**
*F  SyFseek( <fid>, <pos> )   . . . . . . . . . . . seek a position of stream
*/
Int SyFseek(Int fid, Int pos);


/****************************************************************************
**
*F  SyGetch( <fid> )  . . . . . . . . . . . . . . . . . get a char from <fid>
**
**  'SyGetch' reads a character from <fid>, which is switch to raw mode if it
**  is *stdin* or *errin*.
*/
Int SyGetch(Int fid);


/****************************************************************************
**
*F * * * * * * * * * * * * system error messages  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  SyLastErrorNo . . . . . . . . . . . . . . . . . . . . . last error number
*/
extern Int SyLastErrorNo;


/****************************************************************************
**
*V  SyLastErrorMessage  . . . . . . . . . . . . . . . . .  last error message
*/
extern Char SyLastErrorMessage [ 1024 ];


/****************************************************************************
**
*F  SyClearErrorNo()  . . . . . . . . . . . . . . . . .  clear error messages
*/
void SyClearErrorNo(void);


/****************************************************************************
**
*F  SySetErrorNo()  . . . . . . . . . . . . . . . . . . . . set error message
*/
void SySetErrorNo(void);


/****************************************************************************
**
*F * * * * * * * * * * * * * file and execution * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  SyExecuteProcess( <dir>, <prg>, <in>, <out>, <args> ) . . . . new process
**
**  Start  <prg> in  directory <dir>  with  standard input connected to <in>,
**  standard  output  connected to <out>   and arguments.  No  path search is
**  performed, the return  value of the process  is returned if the operation
**  system supports such a concept.
*/
UInt SyExecuteProcess(Char * dir, Char * prg, Int in, Int out, Char * args[]);


/****************************************************************************
**
*F  SyIsExistingFile( <name> )  . . . . . . . . . . . does file <name> exists
**
**  'SyIsExistingFile' returns 1 if the  file <name> exists and 0  otherwise.
**  It does not check if the file is readable, writable or excuteable. <name>
**  is a system dependent description of the file.
*/
Int SyIsExistingFile(const Char * name);


/****************************************************************************
**
*F  SyIsReadableFile( <name> )  . . . . . . . . . . . is file <name> readable
**
**  'SyIsReadableFile'   returns 0  if the   file  <name> is   readable and
**  -1 otherwise. <name> is a system dependent description of the file.
*/
Int SyIsReadableFile(const Char * name);


/****************************************************************************
**
*F  SyIsWritable( <name> )  . . . . . . . . . . . is the file <name> writable
**
**  'SyIsWriteableFile'   returns 1  if the  file  <name>  is  writable and 0
**  otherwise. <name> is a system dependent description of the file.
*/
Int SyIsWritableFile(const Char * name);


/****************************************************************************
**
*F  SyIsExecutableFile( <name> )  . . . . . . . . . is file <name> executable
**
**  'SyIsExecutableFile' returns 1 if the  file <name>  is  executable and  0
**  otherwise. <name> is a system dependent description of the file.
*/
Int SyIsExecutableFile(const Char * name);


/****************************************************************************
**
*F  SyIsDirectoryPath( <name> ) . . . . . . . . .  is file <name> a directory
**
**  'SyIsDirectoryPath' returns 1 if the  file <name>  is a directory  and  0
**  otherwise. <name> is a system dependent description of the file.
*/
Int SyIsDirectoryPath(const Char * name);


/****************************************************************************
**
*F  SyRemoveFile( <name> )  . . . . . . . . . . . . . . .  remove file <name>
*/
Int SyRemoveFile(const Char * name);

/****************************************************************************
**
*F  SyMkDir( <name> )  . . . . . . . . . . . . . . .  remove file <name>
*/
Int SyMkdir(const Char * name);

/****************************************************************************
**
*F  SyRmdir( <name> )  . . . . . . . . . . . . . . .  remove directory <name>
*/
Int SyRmdir(const Char * name);

/****************************************************************************
**
*F  SyIsDir( <name> )  . . . . . . . . . . . . .  test if something is a dir
**
**  Returns 'F' for a regular file, 'L' for a symbolic link and 'D'
**  for a real directory, 'C' for a character device, 'B' for a block
**  device 'P' for a FIFO (named pipe) and 'S' for a socket.
*/
Obj SyIsDir(const Char * name);


/****************************************************************************
**
*F * * * * * * * * * * * * * * * directories  * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  void getwindowsize( void )  . probe the OS for the window size and
**                               set SyNrRows and SyNrCols accordingly
*/

void getwindowsize(void);

/***************************************************************************
**
*F HasAvailableBytes( <fid> ) returns positive if  a subsequent read to <fid>
**                            will read at least one byte without blocking
*/
Int HasAvailableBytes(UInt fid);

Char * SyFgetsSemiBlock(Char * line, UInt length, Int fid);

/***************************************************************************
 **
 *F SyReadStringFid( <fid> )
 **   - read file given by <fid> into a string
 */

Obj SyReadStringFid(Int fid);


// A bug in memmove() provided by glibc 2.21 to 2.27 on 32-bit systems can lead
// to data corruption. We use our own memmove on affected systems. For details,
// see <https://sourceware.org/bugzilla/show_bug.cgi?id=22644> and also
// <https://www.cvedetails.com/cve/CVE-2017-18269/>.
#if defined(__GLIBC__) && __WORDSIZE == 32
  #if __GLIBC_PREREQ(2,21) && !__GLIBC_PREREQ(2,28)
  #define USE_CUSTOM_MEMMOVE 1
  #endif
#endif

#ifdef USE_CUSTOM_MEMMOVE
void * SyMemmove(void * dst, const void * src, size_t size);
#else
#define SyMemmove memmove
#endif

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

// This function is called by 'InitSystem', before the usual module
// initialization.
void InitSysFiles(void);

/****************************************************************************
**
*F  InitInfoSysFiles()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoSysFiles ( void );


#endif // GAP_SYSFILES_H
