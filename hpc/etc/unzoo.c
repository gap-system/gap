/****************************************************************************
**
*A  unzoo.c                     Tools                        Martin Schoenert
**
*H  @(#)$Id: unzoo.c,v 4.9 2006/01/02 10:08:53 gap Exp $
**
*Y  This file is in the Public Domain.
**
**  SYNTAX
**
**  'unzoo'
**  'unzoo [-l] [-v] <archive>[.zoo] [<file>..]'
**  'unzoo -x [-abnpo] <archive>[.zoo] [<file>..]'
**
**  DESCRIPTION
**
**  'unzoo' is  a zoo  archive extractor.   A zoo archive   is  a  file  that
**  contains several files, called its members, usually in compressed form to
**  save space.  'unzoo' can list all or  selected members or  extract all or
**  selected members, i.e.,  uncompress them and write   them  to files.   It
**  cannot add new members or  delete  members.  For this   you need the  zoo
**  archiver, called 'zoo', written by Rahul Dhesi.
**
**  If you call 'unzoo'  with no arguments, it will  first print a summary of
**  the commands and  then prompt for  command lines interactively, until you
**  enter an empty line.  This is useful  on systems  that do not support the
**  notion of command line arguments such as the Macintosh.
**
**  If you call  'unzoo' with the  '-l' option,  it lists the  members in the
**  archive <archive>.   For each member 'unzoo'   prints  the size  that the
**  extracted file  would  have, the  compression factor,  the  size that the
**  member occupies in the archive (not  counting  the  space needed to store
**  the attributes such as the path name of the file), the date and time when
**  the files were last modified, and finally  the path name itself.  Finally
**  'unzoo' prints a grand total for the  file sizes, the compression factor,
**  and the member sizes.
**
**  The '-v' suboption causes 'unzoo' to append to each path name,  separated
**  by a ';', the generation number of the member,  where higher numbers mean
**  later generations.  Members for which generations are disabled are listed
**  with  ';0'.  Also 'unzoo'   will print the  comments associated  with the
**  archive itself or the members, preceeded by the string '# '.
**
**  If you call 'unzoo' with the '-x' option,  it extracts the  members  from
**  the archive <archive>.  Members are  stored with a  full path name in the
**  archive and if the operating system supports this, they will be extracted
**  into   appropriate subdirectories,   which will   be  created on  demand.
**  The members are usually  extracted as binary files,  with no translation.
**  However, if a member has a  comment that starts with the string '!TEXT!',
**  it is  extracted as a  text file, i.e.,  it will be  translated from  the
**  universal text file format (with <lf> as line separator as under UNIX) to
**  the local text file format (e.g., with <cr>/<lf> as separator under DOS).
**  If the archive  itself has a  comment that starts with  '!TEXT!' then all
**  members will be extracted as text files, even those that have no comment.
**  For each member the name is printed followed by  '-- extracted as binary'
**  or '-- extracted as text' when the member has been completely extracted.
**
**  The '-a' suboption causes  'unzoo' to extract all members  as text files,
**  even if they have no comment starting with  '!TEXT!'.
**
**  The '-b' suboption causes 'unzoo' to extract all members as binary files,
**  even if they have a comment starting with  '!TEXT!'.
**
**  The '-n' suboption causes 'unzoo' to suppress writing the files.  You use
**  this suboption  to test the integrity  of the archive  without extracting
**  the members.  For each member the name is printed followed by '-- tested'
**  if the member is intact or by '-- error, CRC failed' if it is not.
**
**  The '-p' suboption causes 'unzoo' to print the files to stdout instead of
**  writing them to files.
**
**  The '-o'  suboption causes 'unzoo'   to overwrite existing  files without
**  asking  you for confirmation.   The  default is  to ask for  confirmation
**  '<file> exists, overwrite it? (Yes/No/All/Ren)'.   To this you can answer
**  with 'y' to overwrite the  file, 'n' to skip  extraction of the file, 'a'
**  to overwrite this and all following files, or 'r' to enter a new name for
**  the file.  'unzoo' will never overwrite existing read-only files.
**
**  The '-j <prefix>' suboption causes 'unzoo' to prepend the string <prefix>
**  to  all path names for  the members  before  they  are extracted.  So for
**  example if an archive contains absolute  path names under  UNIX,  '-j ./'
**  can be used to convert them to relative pathnames.   This option  is also
**  useful  on  the Macintosh where   you start 'unzoo' by clicking,  because
**  then the current directory will be the one where 'unzoo' is,  not the one
**  where the  archive is.   Note  that the  directory  <prefix> must  exist,
**  'unzoo' will not create it on demand.
**
**  If no  <files>  argument is given all members  are  listed or  extracted.
**  If  one or  more <files>  arguments are given,  only members whose  names
**  match at least one of  the  <files> patterns  are  listed  or  extracted.
**  <files> can  contain the wildcard   '?', which  matches any character  in
**  names, and '*', which  matches any number  of characters  in names.  When
**  you pass the <files> arguments on the command  line you will usually have
**  to quote them to keep the shell from trying to expand them.
**
**  Usually 'unzoo' will  only list or extract the  latest generation of each
**  member.  But if you append ';<nr>' to a path  name pattern the generation
**  with the number <nr> is listed or extracted.  <nr> itself can contain the
**  wildcard characters '?' and '*', so appending ';*' to a path name pattern
**  causes all generations to be listed or extracted.
**
**
**  COMPATIBILITY
**
**  'unzoo'  is based heavily on the 'booz' archive extractor by Rahul Dhesi.
**  I basically stuffed everything in one file (so  no 'Makefile' is needed),
**  cleaned it up (so that it is now more portable and  a little bit faster),
**  and added the  support for  long file names,  directories,  and comments.
**
**  'unzoo' differs in some details from  'booz' and the zoo archiver  'zoo'.
**
**  'unzoo' can  only list  and extract members   from archives, like 'booz'.
**  'zoo' can also add members, delete members, etc.
**
**  'unzoo' can extract members as text files, converting from universal text
**  format to the local text format,  if the '-a' option is given or the '-b'
**  option is not given and the  member has a comment starting with '!TEXT!'.
**  So in the absence of the '-a' option and comments starting with '!TEXT!',
**  'unzoo' behaves like  'zoo' and 'booz',  which always extract as  binary.
**  But  'unzoo' can  correctly extract  text files from  archives that  were
**  created under UNIX (or other systems using the universal text format) and
**  extended with '!TEXT!' comments on systems such as DOS, VMS, Macintosh.
**
**  'unzoo' can handle  long names, which it converts  in  a system dependent
**  manner to local  names, like  'zoo'  (this may not   be available on  all
**  systems).  'booz' always uses the short DOS format names.
**
**  'unzoo' extracts  members  into  subdirectories, which  it  automatically
**  creates, like 'zoo' (this  may not be available on  all systems).  'booz'
**  always extracts all members into the current directory.
**
**  'unzoo'  can handle comments and generations in the  archive, like 'zoo'.
**  'booz' ignores all comments and generations.
**
**  'unzoo' cannot handle  members compressed with  the old method, only with
**  the new  high method or  not compressed  at all.   'zoo' and  'booz' also
**  handle members compress with the old method.  This shall be fixed soon.
**
**  'unzoo' can handle archives in  binary format under  VMS, i.e., it is not
**  necessary to convert  them to stream linefeed  format  with 'bilf' first.
**  'zoo' and 'booz' require this conversion.
**
**  'unzoo' is somewhat faster than 'zoo' and 'booz'.
**
**  'unzoo' should be much easier to port than both 'zoo' and 'booz'.
**
**  COMPILATION
**
**  Under  UNIX  with the  standard  C compiler,  compile  'unzoo' as follows
**      cc  -o unzoo  -DSYS_IS_UNIX   -O  unzoo.c
**  If your UNIX has the 'mkdir' system call,  you may add  '-DSYS_HAS_MKDIR'
**  for a slightly faster executable.   BSD has it,  else try  'man 2 mkdir'.
**
**  Under  DOS  with the  DJGPP  GNU C compiler,  compile  'unzoo' as follows
**      gcc  -o unzoo.out  -DSYS_IS_DOS_DJGPP  -O2  unzoo.c
**      copy /b \djgpp\bin\go32.exe+unzoo.out unzoo.exe
**
**  Under  Windows with the cygwin GNU C compiler,  compile  'unzoo' as follows
**      gcc -mno-cygwin -DSYS_IS_WINDOWS -O3 unzoo.c -o unzoo.exe
**
**  Under TOS with the GNU compiler and unixmode, compile  'unzoo' as follows
**      gcc  -o unzoo.ttp  -DSYS_IS_TOS_GCC  -O2  unzoo.c
**
**  Under OS/2 2 with the emx development system, compile  'unzoo' as follows
**      gcc  -o unzoo.exe  -DSYS_IS_OS2_EMX  -Zomf -Zsys  -O2  unzoo.c
**  To create an executable that runs under OS/2 and DOS,  but which requires
**  the emx runtime, compile without the '-Zomf' and '-Zsys' options.
**
**  On a VAX running VMS with the DEC C compiler, compile  'unzoo' as follows
**      cc   unzoo/define=SYS_IS_VMS
**      link unzoo
**  Then perform the following global symbolic assignment
**      unzoo :== $<dev>:[<dir>]unzoo.exe
**  where  <dir> is the    name of the   directory  where you  have installed
**  'unzoo' and  <dev> is the device on which this directory is,  for example
**      unzoo :== $dia1:[progs.archivers]unzoo
**  You may want to put this symbolic assignment into your  'login.com' file.
**
**  On a  Macintosh  with  the  MPW C  compiler,  compile  'unzoo' as follows
**      C    -model far  -d SYS_IS_MAC_MPW  -opt on  unzoo.c
**      Link -model far -d -c '????' -t APPL unzoo.c.o -o unzoo   <continued>
**          "{CLibraries}"StdClib.o "{Libraries}"SIOW.o           <continued>
**          "{Libraries}"Runtime.o  "{Libraries}"Interface.o
**      Rez  -a "{RIncludes}"SIOW.r  -o unzoo
**  Afterwards choose the  'Get Info' command in the  finder 'File' menu  and
**  increase the  amount of memory  'unzoo' gets upon startup to  256 KBytes.
**  To  create a MPW  tool instead of a  standalone, link with creator 'MPS '
**  instead of '????', with type 'MPST' instead  of 'APPL' and with 'Stubs.o'
**  instead of 'SIOW.o'.  The  'Rez' command  is  not required for the  tool.
**  Alternatively choose the 'Create Build Commands...'  command from the MPW
**  'Build' menu to create a  makefile.  Edit it  and add '-d SYS_IS_MAC_MPW'
**  to the  compile command.  Choose the  'Build...' command from the 'Build'
**  menu to build 'unzoo'.
**
**  On  other systems with a C compiler,  try to  compile  'unzoo' as follows
**      cc  -o unzoo -DSYS_IS_GENERIC  -O  unzoo.c
**
**  PORTING
**
**  If this  does not work,  you must supply new   definitions for the macros
**  'OPEN_READ_ARCH',   'OPEN_READ_TEXT' and  'OPEN_WRIT_TEXT'.  If you  want
**  'unzoo' to keep long file  names, you must   supply a definition for  the
**  macro 'CONV_NAME'.  If  you want 'unzoo'  to extract into subdirectories,
**  you   must supply a  definition for  the macro 'CONV_DIRE'.   If you want
**  'unzoo' to automatically create directories, you must supply a definition
**  for the macro 'MAKE_DIR'.  If you want  'unzoo' to set the permissions of
**  extracted  members to those  recorded in the archive,  you must  supply a
**  definition for the macro 'SETF_PERM'.  Finally if you want 'unzoo' to set
**  the times of the extracted members to  the times recorded in the archive,
**  you must supply a definition for the  macro 'SETF_TIME'.  Everything else
**  should be system independent.
**
**  ACKNOWLEDGMENTS
**
**  Rahul Dhesi  wrote the  'zoo' archiver and the  'booz' archive extractor.
**  Haruhiko Okumura  wrote the  LZH code (originally for his 'ar' archiver).
**  David Schwaderer provided the CRC-16 calculation in PC Tech Journal 4/85.
**  Jeff Damens  wrote the name match code in 'booz' (originally for Kermit).
**  Harald Boegeholz  ported 'unzoo' to OS/2 with the emx development system.
**  Dave Bayer ported 'unzoo' to the Macintosh,  including Macbinary support.
**
**  HISTORY
*H  $Log: unzoo.c,v $
*H  Revision 4.9  2006/01/02 10:08:53  gap
*H  added more efficient BlockWriteText for Mac version. BH
*H
*H  Revision 4.8  2005/10/03 08:07:28  alexk
*H  Added fseek support in Windows version. AK
*H
*H  Revision 4.7  2005/09/26 14:10:32  gap
*H  enabled forward seeks, fixed a potential bug. BH.
*H
*H  Revision 4.6  2003/08/27 11:15:38  gap
*H  Added drag and drop support. Replaced some functions in the Mac part by versons supported by recent Mac OS.
*H
*H  Revision 4.5  2001/11/09 01:30:53  gap
*H  Added `SYS_IS_WINDOWS' target for cygwin/naive windows compilation.
*H
*H  Revision 4.4  2000/05/29 08:56:57  sal
*H  Remove all the \ continuation lines -- who needs the hassle.	SL
*H
*H  Revision 4.3  1999/10/27 08:51:11  sal
*H  Fix date problem on alphas (I hope)	SL
*H
*H  Revision 4.2  1999/05/26 09:27:03  gap
*H  burkhard: use fseek to access file comments; Mac version: several minor fixes
*H
*H  Revision 1.5  1994/01/21  13:32:32  mschoene
*H  added Mac support from Dave Bayer
*H
*H  Revision 1.4  1994/01/20  20:45:46  mschoene
*H  cleaned up determination of write mode
*H
*H  Revision 1.3  1993/12/02  12:43:12  mschoene
*H  added OS/2 support from Harald Boegeholz
*H
*H  Revision 1.2  1993/12/02  12:33:39  mschoene
*H  fixed several typos, renamed MS-DOS to DOS
*H
*H  Revision 1.1  1993/11/09  07:17:50  mschoene
*H  Initial revision
*H
*/
#include        <stdio.h>


/****************************************************************************
**
*F  OPEN_READ_ARCH(<patl>)  . . . . . . . . . . . open an archive for reading
*F  CLOS_READ_ARCH()  . . . . . . . . . . . . . . . . . . .  close an archive
*F  BLCK_READ_ARCH(<blk>,<len>) . . . . . . . .  read a block from an archive
*F  RWND_READ_ARCH()  . . . . . . . . . . . reset file read position to start 
*F  SEEK_READ_ARCH(pos) . . . . . . . . . . . . . . move read position to pos
**
**  'OPEN_READ_ARCH' returns 1 if the archive file with  the path name <patl>
**  (as specified   by the user  on the  command line)   could  be opened for
**  reading and   0  otherwise.  Because   archive  files are   binary files,
**  'OPEN_READ_ARCH' must open the file in binary mode.
**
**  'CLOS_READ_ARCH'  closes   the archive  file  opened  by 'OPEN_READ_ARCH'
**  again.
**
**  'BLCK_READ_ARCH' reads up  to  <len>  characters  from the   archive file
**  opened with 'OPEN_READ_ARCH'  into  the  blkfer  <blk>, and  returns  the
**  actual number of characters read.
**
**  This operation is  operating system  dependent  because the archive  file
**  must be opened in binary mode, so that for example no  <cr>/<lf> <-> <lf>
**  translation happens.  You must supply a definition for each new port.
*/
#ifdef  SYS_IS_UNIX
FILE *          ReadArch;
#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "r" )) != 0)
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, 0 ) == 0)
#define SEEK_READ_ARCH(pos)		(fseek( ReadArch, pos, SEEK_SET) == 0)
#endif
#ifdef  SYS_IS_DOS_DJGPP
FILE *          ReadArch;
#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "rb" )) != 0)
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, 0 ) == 0)
#endif
#ifdef  SYS_IS_WINDOWS
FILE *          ReadArch;
#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "rb" )) != 0)
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, 0 ) == 0)
#define SEEK_READ_ARCH(pos)		(fseek( ReadArch, pos, SEEK_SET) == 0)
#endif
#ifdef  SYS_IS_OS2_EMX
FILE *          ReadArch;
#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "rb" )) != 0)
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, 0 ) == 0)
#endif
#ifdef  SYS_IS_TOS_GCC
FILE *          ReadArch;
#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "rb" )) != 0)
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, 0 ) == 0)
#endif
#ifdef  SYS_IS_VMS
FILE *          ReadArch;
#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "r" )) != 0)
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, 0 ) == 0)
#endif
#ifdef  SYS_IS_MAC_MPW
FILE *          ReadArch;
#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "r") ) != 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, 0 ) == 0)
#define SYS_IS_MAC_BOTH
#endif
#ifdef  SYS_IS_MAC_MWC
#include <SIOUX.h>
FILE *          ReadArch;
int 			IsActive = 0;
int 			DragAndDropEnabled;

#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "rb") ) != 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, SEEK_SET ) == 0)
#define SEEK_READ_ARCH(pos)		(fseek( ReadArch, pos, SEEK_SET) == 0)
#define SYS_IS_MAC_BOTH
#endif
#ifdef  SYS_IS_GENERIC
FILE *          ReadArch;
#define OPEN_READ_ARCH(patl)    ((ReadArch = fopen( (patl), "r" )) != 0)
#define CLOS_READ_ARCH()        (fclose( ReadArch ) == 0)
#define BLCK_READ_ARCH(blk,len) fread( (blk), 1L, (len), ReadArch )
#define RWND_READ_ARCH()        (fseek( ReadArch, 0, 0 ) == 0)
#define SEEK_READ_ARCH(pos)		(fseek( ReadArch, pos, SEEK_SET) == 0)
#endif
#ifndef OPEN_READ_ARCH
#include        "You_must_specify_the_system.h"
#endif


/****************************************************************************
**
*F  OPEN_READ_TEXT(<patl>)  . . . . . . . . . . . . . open a file for reading
*F  CLOS_READ_TEXT()  . . . . . . . . . . . . . . . . . . . . .  close a file
*F  BLCK_READ_TEXT(<blk>,<len>) . . . . . . . . . .  read a block from a file
**
**  'OPEN_READ_TEXT' returns 1  if  the file with  the  path name  <patl> (as
**  specified by  the user on the command  line) could be opened  for reading
**  and 0 otherwise.   'OPEN_READ_TEXT' is  used  only for text files,  so it
**  should open the file in text mode.
**
**  'CLOS_READ_TEXT' closes the file opened by 'OPEN_READ_TEXT' again.
**
**  'BLCK_READ_TEXT' reads up  to <len> characters from  the file opened with
**  'OPEN_READ_TEXT' into the blkfer <blk>, and  returns the actual number of
**  characters read.
**
**  In 'unzoo' these functions are only used to test if a file exists.
**
**  This operation is operating system dependent because it may be neccessary
**  to translate between the local text format and the UNIX style text format
**  usually used in archives.   The default is to  use 'fopen', 'fread',  and
**  'fclose', which  should work everywhere  according  to the ANSI standard.
**  You may want to use 'open', 'read', and 'close' for better performance.
*/
#ifndef OPEN_READ_TEXT
FILE *          ReadText;
#define OPEN_READ_TEXT(patl)    ((ReadText = fopen( (patl), "r" )) != 0)
#define CLOS_READ_TEXT()        (fclose( ReadText ) == 0)
#define BLCK_READ_TEXT(blk,len) fread( (blk), 1L, (len), ReadText )
#endif


/****************************************************************************
**
*F  OPEN_WRIT_TEXT(<patl>)  . . . . . . . . . . . . . open a file for writing
*F  CLOS_WRIT_TEXT()  . . . . . . . . . . . . . . . . . . . . .  close a file
*F  BLCK_WRIT_TEXT(<blk>,<len>) . . . . . . . . . . . write a block to a file
**
**  'OPEN_WRIT_TEXT'   returns 1 if the  file  with the path  name <patl> (as
**  specified by the  user on the command  line) could be  opened for writing
**  and  0 otherwise.  'OPEN_WRIT_TEXT'  is used only for  text  files, so it
**  must open the file in text mode.
**
**  'CLOS_WRIT_TEXT' closes the file opened by 'OPEN_WRIT_TEXT' again.
**
**  'BLCK_WRIT_TEXT' writes up  to <len> characters  from <blk> into the file
**  opened with 'OPEN_WRIT_TEXT', and returns the actual number of characters
**  written.
**
**  This operation is operating system dependent because it may be neccessary
**  to translate between the UNIX style text format  usually used in archives
**  and the local text format.  The default is to  use 'fopen', 'fwrite', and
**  'fclose', which should work   everywhere according to the  ANSI standard.
**  You may want to use 'open', 'write', and 'close' for better performance.
*/
#ifdef  SYS_IS_MAC_MPW
FILE *          WritText;
#define OPEN_WRIT_TEXT(patl)    MacOpenWritText( (patl) )
#define CLOS_WRIT_TEXT()        MacClosWritText()
#define BLCK_WRIT_TEXT(blk,len) MacBlckWritText( (blk), (len) )
#endif
#ifdef  SYS_IS_MAC_MWC
FILE *          WritText;
#define OPEN_WRIT_TEXT(patl)    MacOpenWritText( (patl) )
#define CLOS_WRIT_TEXT()        (fclose( WritText ) == 0)
#define BLCK_WRIT_TEXT(blk,len) fwrite( (blk), 1L, (len), WritText )
#endif
#ifndef OPEN_WRIT_TEXT
FILE *          WritText;
#define OPEN_WRIT_TEXT(patl)    ((WritText = fopen( (patl), "w" )) != 0)
#define CLOS_WRIT_TEXT()        (fclose( WritText ) == 0)
#define BLCK_WRIT_TEXT(blk,len) fwrite( (blk), 1L, (len), WritText )
#endif


/****************************************************************************
**
*F  OPEN_READ_BINR(<patl>)  . . . . . . . . . . . . . open a file for reading
*F  CLOS_READ_BINR()  . . . . . . . . . . . . . . . . . . . . .  close a file
*F  BLCK_READ_BINR(<blk>,<len>) . . . . . . . . . .  read a block from a file
**
**  'OPEN_READ_BINR'  returns 1 if   the file with  the  path name <patl> (as
**  specified by  the user on the  command line) could  be opened for reading
**  and 0  otherwise.  'OPEN_READ_BINR' is used only  for binary files, so it
**  should open the file in binary mode.
**
**  'CLOS_READ_BINR' closes the file opened by 'OPEN_READ_BINR' again.
**
**  'BLCK_READ_BINR' reads up  to <len> characters from  the file opened with
**  'OPEN_READ_BINR' into the blkfer <blk>, and  returns the actual number of
**  characters read.
**
**  In 'unzoo' these functions are currently not used at all.
**
**  This operation is  operating system dependent   because the file  must be
**  opened  in binary mode,  so  that   for  example  no <cr>/<lf>  <->  <lf>
**  translation happens.  The default   is to use  'fopen'  with  mode  'rb',
**  'fwrite', and 'fclose', with should work on most systems.
*/
#ifndef OPEN_READ_BINR
FILE *          ReadBinr;
#define OPEN_READ_BINR(patl)    ((ReadBinr = fopen( (patl), "rb" )) != 0)
#define CLOS_READ_BINR()        (fclose( ReadBinr ) == 0)
#define BLCK_READ_BINR(blk,len) fread( (blk), 1L, (len), ReadBinr )
#endif


/****************************************************************************
**
*F  OPEN_WRIT_BINR(<patl>)  . . . . . . . . . . . . . open a file for writing
*F  CLOS_WRIT_BINR()  . . . . . . . . . . . . . . . . . . . . .  close a file
*F  BLCK_WRIT_BINR(<blk>,<len>) . . . . . . . . . . . write a block to a file
**
**  'OPEN_WRIT_BINR' returns 1   if the file  with the  path name <patl>  (as
**  specified  by the user  on the command line) could  be opened for writing
**  and 0 otherwise.   'OPEN_WRIT_BINR' is used  only for binary files, so it
**  must open the file in binary mode.
**
**  'CLOS_WRIT_BINR' closes the file opened by 'OPEN_WRIT_BINR' again.
**
**  'BLCK_WRIT_BINR' writes up  to <len> characters  from <blk> into the file
**  opened with 'OPEN_WRIT_BINR', and returns the actual number of characters
**  written.
**
**  This  operation is operating  system dependent  because the  file must be
**  opened  in   binary mode, so  that  for  example no   <cr>/<lf>  <-> <lf>
**  translation happens.   The default is   to use 'fopen'  with  mode  'wb',
**  'fwrite', and  'fclose', with should   work  on most systems.  You   must
**  supply a definition is this does not work and you want 'unzoo' to extract
**  binary files.
*/
#ifdef  SYS_IS_VMS
#include        <file.h>
long            WritBinr;
#define OPEN_WRIT_BINR(patl)    ((WritBinr = creat( (patl), 0, "rfm=fix", "mrs=512" )) != -1)
#define BLCK_WRIT_BINR(blk,len) VmsBlckWritBinr( WritBinr, (blk), (len) )
#define CLOS_WRIT_BINR()        (close( WritBinr ) == 0)
#endif
#ifdef  SYS_IS_MAC_MWC
FILE *          WritBinr;
#define OPEN_WRIT_BINR(patl)    MacOpenWritBinr (patl)
#define BLCK_WRIT_BINR(blk,len) fwrite( (blk), 1L, (len), WritBinr )
#define CLOS_WRIT_BINR()        (fclose( WritBinr ) == 0)
#endif
#ifndef OPEN_WRIT_BINR
FILE *          WritBinr;
#define OPEN_WRIT_BINR(patl)    ((WritBinr = fopen( (patl), "wb" )) != 0)
#define BLCK_WRIT_BINR(blk,len) fwrite( (blk), 1L, (len), WritBinr )
#define CLOS_WRIT_BINR()        (fclose( WritBinr ) == 0)
#endif


/****************************************************************************
**
*F  CONV_NAME(<naml>,<namu>)  . . . . . . . . . . . . . . convert a file name
**
**  'CONV_NAME'  returns in <naml> the  universal file name <namu>  converted
**  to the local format.  <namu>  may contain  uppercase, lowercase,  and all
**  special characters, and may be up to 255 characters long.
**
**  You must define this for a new port if you want  'unzoo' to keep the long
**  names instead of using the default local format for the file names, which
**  contains up to eight lowercase  characters before an optional dot  ('.'),
**  up to three characters after the dot, and no special characters.  You may
**  want to use the universal conversion function 'ConvName'.
*/
#ifdef  SYS_IS_UNIX
#define CONV_NAME(naml,namu)    strcpy( (naml), (namu) )
#endif
#ifdef  SYS_IS_WINDOWS
#define CONV_NAME(naml,namu)    strcpy( (naml), (namu) )
#endif
#ifdef  SYS_IS_DOS_DJGPP
#define CONV_NAME(naml,namu)    ConvName( (naml), (namu), 8L, 3L, '_' )
#endif
#ifdef  SYS_IS_OS2_EMX
#define CONV_NAME(naml,namu)    strcpy( (naml), (namu) )
#endif
#ifdef  SYS_IS_TOS_GCC
#define CONV_NAME(naml,namu)    strcpy( (naml), (namu) )
#endif
#ifdef  SYS_IS_VMS
#define CONV_NAME(naml,namu)    ConvName( (naml), (namu), 39L, 39L, '_' )
#endif
#ifdef  SYS_IS_MAC_MPW
#define CONV_NAME(naml,namu)    strncpy( (naml), (namu), 31 ); naml[32] = '\0'
#endif
#ifdef  SYS_IS_MAC_MWC
#define CONV_NAME(naml,namu)    strncpy( (naml), (namu), 31 ); naml[32] = '\0'
#endif
#ifndef CONV_NAME
#define CONV_NAME(naml,namu)    ConvName( (naml), (namu), 8L, 3L, 'x' )
#endif


/****************************************************************************
**
*F  CONV_DIRE(<dirl>,<diru>)  . . . . . . . . . . .  convert a directory name
**
**  'CONV_DIRE'  returns  in  <dirl>  the  universal  directory  name  <diru>
**  converted to the  local format.  <diru> contains an  arbitrary number  of
**  components separated by  slashes ('/'),  where each component may contain
**  uppercase,  lowercase,  and all special characters,  and may be up to 255
**  characters long.
**
**  You  must  define this  for a new   port if you  want  'unzoo' to extract
**  members into subdirectories, instead of  extracting  them to the  current
**  directory.    You may  want  to   use the  universal conversion  function
**  'ConvDire'.
*/
#ifdef  SYS_IS_UNIX
#define CONV_DIRE(dirl,diru)    ConvDire((dirl),(diru),"/","/","","/","/")
#endif
#ifdef  SYS_IS_DOS_DJGPP
#define CONV_DIRE(dirl,diru)    ConvDire((dirl),(diru),"\\","\\","","\\","\\")
#endif
#ifdef  SYS_IS_WINDOWS
#define CONV_DIRE(dirl,diru)    ConvDire((dirl),(diru),"\\","\\","","\\","\\")
#endif
#ifdef  SYS_IS_OS2_EMX
#define CONV_DIRE(dirl,diru)    ConvDire((dirl),(diru),"/","/","","/","/")
#endif
#ifdef  SYS_IS_TOS_GCC
#define CONV_DIRE(dirl,diru)    ConvDire((dirl),(diru),"\\","\\","","\\","\\")
#endif
#ifdef  SYS_IS_VMS
#define CONV_DIRE(dirl,diru)    ConvDire((dirl),(diru),"[]","[","[.",".","]")
#endif
#ifdef  SYS_IS_MAC_MPW
#define CONV_DIRE(dirl,diru)    ConvDire((dirl),(diru),"","",":",":",":")
#endif
#ifdef  SYS_IS_MAC_MWC
#define CONV_DIRE(dirl,diru)    if (*diru) \
                                     ConvDire((dirl),(diru),"","",":",":",":"); \
                                else \
                                   strcpy ((dirl), ":")
#endif
#ifndef CONV_DIRE
#define CONV_DIRE(dirl,diru)    ((dirl)[0]='\0',1)
#endif


/****************************************************************************
**
*F  MAKE_DIRE(<patl>) . . . . . . . . . . . . . . . . . . .  make a directory
**
**  'MAKE_DIRE' makes  the directory  with the local   path name  <patl>  (as
**  converted by 'CONV_NAME' and 'CONV_DIRE' with the prefix of 'MakeDirs').
**
**  You must define this for a new port  if you want 'unzoo' to automatically
**  create directories instead of requiring the user to create them.
*/
#ifdef  SYS_IS_UNIX
#ifdef  SYS_HAS_MKDIR
#define MAKE_DIRE(patl)         mkdir( (patl), 0777L )
#else
char            Cmd [256];
#define MAKE_DIRE(patl)    (sprintf(Cmd,"/bin/mkdir %s",(patl)),!system(Cmd))
#endif
#endif
#ifdef  SYS_IS_DOS_DJGPP
#define MAKE_DIRE(patl)         mkdir( (patl), 0777L )
#endif
#ifdef  SYS_IS_WINDOWS
#define MAKE_DIRE(patl)         mkdir( (patl), 0777L )
#endif
#ifdef  SYS_IS_OS2_EMX
#include        <stdlib.h>
#define MAKE_DIRE(patl)         mkdir( (patl), 0777L )
#endif
#ifdef  SYS_IS_TOS_GCC
#define MAKE_DIRE(patl)         mkdir( (patl), 0777L )
#endif
#ifdef  SYS_IS_VMS
#define MAKE_DIRE(patl)         VmsMakeDire( (patl) )
#endif
#ifdef  SYS_IS_MAC_MPW
#define MAKE_DIRE(patl)         MacMakeDire( (patl) )
#endif
#ifdef  SYS_IS_MAC_MWC
#define MAKE_DIRE(patl)         MacMakeDire( (patl) )
#endif


/****************************************************************************
**
*F  SETF_TIME(<patl>,<secs>)  . . . . . . . . . . . change the time of a file
**
**  'SETF_TIME' changes the time of the file with  the local path name <patl>
**  (as converted  by 'CONV_NAME' and  'CONV_DIRE')  to <secs>, which  is the
**  number of seconds since 1970/01/01 00:00:00.
**
**  You  must define  this for  a new  port  if you  want 'unzoo'  to extract
**  members with the correct time as stored in the archive.
*/
#ifdef  SYS_IS_UNIX
unsigned int   Secs [2];
#define SETF_TIME(patl,secs)    (Secs[0]=Secs[1]=(secs),!utime((patl),Secs))
#endif
#ifdef  SYS_IS_DOS_DJGPP
unsigned long   Secs [2];
#define SETF_TIME(patl,secs)    (Secs[0]=Secs[1]=(secs),!utime((patl),Secs))
#endif
#ifdef  SYS_IS_WINDOWS
unsigned long   Secs [2];
#define SETF_TIME(patl,secs)    (Secs[0]=Secs[1]=(secs),!utime((patl),Secs))
#endif
#ifdef  SYS_IS_OS2_EMX
#include        <sys/utime.h>
struct  utimbuf Secs;
#define SETF_TIME(patl,secs)    (Secs.actime=Secs.modtime=(secs),!utime((patl),&Secs))
#endif
#ifdef  SYS_IS_TOS_GCC
unsigned long   Secs [2];
#define SETF_TIME(patl,secs)    (Secs[0]=Secs[1]=(secs),!utime((patl),Secs))
#endif
#ifndef SETF_TIME
#define SETF_TIME(patl,secs)    (1)
#endif


/****************************************************************************
**
*F  SETF_PERM(<patl>,<mode>)  . . . . . . .  change the permissions of a file
**
**  'SETF_PERM' changes the permissions of the file with the  local path name
**  <patl> (as converted by 'CONV_NAME' and 'CONV_DIRE') to <mode>,  which is
**  a UNIX style mode word.
**
**  You  must define this  for a  new  port if  you want  'unzoo'  to extract
**  members with the permissions stored in the archive.
*/
#ifdef  SYS_IS_UNIX
#define SETF_PERM(patl,mode)    (!chmod((patl),(int)(mode)))
#endif
#ifdef  SYS_IS_DOS_DJGPP
#define SETF_PERM(patl,mode)    (!chmod((patl),(int)(mode)))
#endif
#ifdef  SYS_IS_WINDOWS
#define SETF_PERM(patl,mode)    (!chmod((patl),(int)(mode)))
#endif
#ifdef  SYS_IS_OS2_EMX
#include        <io.h>
#define SETF_PERM(patl,mode)    (!chmod((patl),(int)(mode)))
#endif
#ifdef  SYS_IS_TOS_GCC
#define SETF_PERM(patl,mode)    (!chmod((patl),(int)(mode)))
#endif
#ifndef SETF_PERM
#define SETF_PERM(patl,mode)    (1)
#endif


/****************************************************************************
**
*F  ConvName(...) . . . . . . . . . . . . convert a file name to local format
**
**  'ConvName( <naml>, <namu>, <pre>,<pst>,<rpl> )'
**
**  'ConvName' returns in <naml> the  universal file name <namu> converted to
**  the local format described by <pre>, <pst>, and <rpl>.
**
**  <pre> is the maximum number of characters  before the optional dot, <pst>
**  is the maximum number of characters after the optional  dot, and <rpl> is
**  the character that replaces special characters.
*/
int             ConvName ( naml, namu, pre, pst, rpl )
    char *              naml;
    char *              namu;
    unsigned long       pre;
    unsigned long       pst;
    char                rpl;
{
    char *              dotu;           /* position of last dot in <namu>  */
    char *              l;              /* loop variable                   */
    char *              u;              /* loop variable                   */

    /* find the final dot                                                  */
    dotu = 0;
    for ( u = namu; *u != '\0'; u++ )
        if ( *u == '.' )
            dotu = u;
    if ( dotu == 0 )  dotu = u;

    /* copy the first part                                                 */
    l = naml;
    for ( u = namu; u < dotu && u < namu+pre; u++ ) {
        if      ( 'a' <= *u && *u <= 'z' )  *l++ = *u;
        else if ( 'A' <= *u && *u <= 'Z' )  *l++ = *u - 'A' + 'a';
        else if ( '0' <= *u && *u <= '9' )  *l++ = *u;
        else                                *l++ = rpl;
    }

    /* the part before the dot may not be empty                            */
    if ( l == naml )
        *l++ = rpl;

    /* if the universal file name had no dot, thats it                     */
    if ( *dotu == '\0' || pst == 0 ) {
        *l = '\0';
        return 1;
    }

    /* copy the dot                                                        */
    *l++ = '.';

    /* copy the remaining part                                             */
    for ( u = dotu+1; *u && u < dotu+1+pst; u++ ) {
        if      ( 'a' <= *u && *u <= 'z' )  *l++ = *u;
        else if ( 'A' <= *u && *u <= 'Z' )  *l++ = *u - 'A' + 'a';
        else if ( '0' <= *u && *u <= '9' )  *l++ = *u;
        else                                *l++ = rpl;
    }

    /* terminate the local name and indicate success                       */
    *l = '\0';
    return 1;
}


/****************************************************************************
**
*F  ConvDire(...) . . . . . . . . .  convert a directory name to local format
**
**  'ConvDire( <dirl>, <diru>, <root>,<abs>,<rel>,<sep>,<end> )'
**
**  'ConvDire'  returns  in  <dirl>  the  universal  directory  name   <diru>
**  converted to the  local format.  <diru> contains an  arbitrary number  of
**  components separated by  slashes ('/'),  where each component may contain
**  uppercase,  lowercase,  and all special characters,  and may be up to 255
**  characters long.
**
**  <root> is the string that is used for the root directory in local format.
**  <abs> is the string that starts absolute directory names in local format,
**  <rel> starts relative names, directory components are separated by <sep>,
**  and <end> separates the directory part and a proper file name.
**
**  If <diru> is the empty string, then 'ConvDire' returns in <dirl> also the
**  empty string, instead of '<rel><end>'.
*/
int             ConvDire ( dirl, diru, root, abs, rel, sep, end )
    char *              dirl;
    char *              diru;
    char *              root;
    char *              abs;
    char *              rel;
    char *              sep;
    char *              end;
{
    char                namu [256];     /* file name part, univ.           */
    char                naml [256];     /* file name part, local           */
    char *              d;              /* loop variable                   */
    char *              s;              /* loop variable                   */

    /* special case for the root directory                                 */
    if ( *diru == '/' && diru[1] == '\0' ) {
        for ( s = root; *s != '\0'; s++ )  *dirl++ = *s;
        *dirl = '\0';
        return 1;
    }

    /* start the file name with <abs> or <rel>                             */
    d = diru;
    if ( *diru == '/' )
        for ( d++, s = abs; *s != '\0'; s++ )  *dirl++ = *s;
    else if ( *diru != '\0' )
        for (      s = rel; *s != '\0'; s++ )  *dirl++ = *s;

    /* add the components of the directory part separated by <sep>         */
    while ( *d != '\0' ) {
        s = namu;
        while ( *d != '\0' && *d != '/' )  *s++ = *d++;
        *s = '\0';
        CONV_NAME( naml, namu );
        for ( s = naml; *s != '\0'; s++ )  *dirl++ = *s;
        if ( *d == '/' )
            for ( d++, s = sep; *s != '\0'; s++ )  *dirl++ = *s;
    }

    /* add the divisor <end>                                               */
    if ( *diru != '\0' )
        for ( s = end; *s != '\0'; s++ )  *dirl++ = *s;

    /* terminate the file name and indicate success                        */
    *dirl = '\0';
    return 1;
}


/****************************************************************************
**
*F  VmsBlckWritBinr(<blk>,<len>)  .  write a block to a binary file under VMS
*F  VmsMakeDire(<patl>) . . . . . . . . . . . .  create a directory under VMS
**
**  'VmsBlckWritBinr' writes  the block  <blk> of  length  <len> to  the file
**  opened with 'OPEN_WRIT_BINR'.
**
**  'VmsMakeDire' creates a directory  under VMS.  It has  to change the path
**  name from '[<components>]<dirl>' to '[<components>.<dirl>]'.
*/
#ifdef  SYS_IS_VMS

unsigned long   VmsBlckWritBinr ( blk, len )
    unsigned char *     blk;
    unsigned long       len;
{
    unsigned char       buf [512];      /* local buffer (padded with 0)    */
    long                i,  k,  l;      /* loop variables                  */

    /* write the full 512 byte blocks                                      */
    for ( i = 0; i+512 < len; i += 512 ) {
        if ( (l = write( WritBinr, blk+i, 512 )) != 512 )
            return i + l;
    }

    /* write an incomplete last block padded with 0                        */
    for ( k = 0; k < 512; k++ )
        buf[k] = (i+k < len ? blk[i+k] : 0);
    if ( (l = write( WritBinr, buf, 512 )) != 512 )
        return i + l;

    /* indicate success                                                    */
    return len;
}

int             VmsMakeDire ( patl )
    char *              patl;
{
    char *              p;

    /* replace the separator with a dot                                    */
    for ( p = patl; *p != '\0' && *p != ']'; p++ )  ;
    if ( *p == ']' )  *p = '.';

    /* append another separator                                            */
    for ( ; *p != '\0'; p++ ) ;
    *p++ = ']';
    *p = '\0';

    /* make the directory and indicate success                             */
    return mkdir( patl, 0 );
}

#endif


/****************************************************************************
**
*F  MacOpenWritText(<patl>) . . . . .  open a text file for writing under MPW
*F  MacClosWritText() . . . . . . . . . . . . . . close a text file under MPW
*F  MacBlckWritText(<blk>,<len>)  . .  write a block to a text file under MPW
*F  OPEN_WRIT_MACB(<patl>)  . . . open a MacBinary file for writing under MPW
*F  CLOS_WRIT_MACB()  . . . . . . . . . . .  close a MacBinary file under MPW
*F  BLCK_WRIT_MACB(<blk>,<len>) . write a block to a MacBinary file under MPW
*F  MacMakeDire(<patl>) . . . . . . . . . . . .  create a directory under MPW
**
**  'MacBlckWritText' writes the block <blk> of length <len> to the text file
**  opened   with 'OPEN_WRIT_TEXT'.  It    converts <lf> ('\012') characters,
**  which represent <newline>  in universal text  format, to '\n' characters,
**  which represent <newline> in the system defined text format.
**
**  'MacMakeDire' creates  the directory  with local  path  name <patl>.  The
**  code comes from the Macintosh 'tar' port by Gail Zacharias.
*/

#ifdef SYS_IS_MAC_MWC

#include        <Devices.h>
#include        <Files.h>
#include        <URLAccess.h>

extern Boolean gURLAvailable;

int             MacOpenWritText ( patl )
    char *              patl;
{
    FileParam               fndrInfo;
    char            	    patp [256];     /* <patl> as a Pascal string       */
    int                		len;            /* length of <patp>                */
    OSErr                   err;
    
    /* open the file                                                       */
    if ( ! (WritText = fopen( (patl), "w" )) )
        return 0;

    /* convert <patl> from a C string to a Pascal string                   */
    len = strlen( patl );
    len = len < 256 ? len : 255;
    patp[0] = len;
    strncpy( patp+1, patl, len );
    
    /* set the file type to 'TEXT' and the creator to TeachText            */
    fndrInfo.ioNamePtr   = (unsigned char*)patp;
    fndrInfo.ioVRefNum   = 0;
    fndrInfo.ioFVersNum  = 0;
    fndrInfo.ioFDirIndex = 0;
    if ( PBGetFInfoSync( (ParmBlkPtr)&fndrInfo) ) {
        return 0;
    }
#if TARGET_CPU_PPC
    if (!gURLAvailable || 
    	(err = URLGetFileInfo ((unsigned char*)patp, 
    	    &fndrInfo.ioFlFndrInfo.fdType,
    	    &fndrInfo.ioFlFndrInfo.fdCreator)) != noErr) {
    	fndrInfo.ioFlFndrInfo.fdCreator = 'ttxt'; /* default type */
    } 
#else
    fndrInfo.ioFlFndrInfo.fdCreator = 'ttxt'; /* default type */
#endif
	fndrInfo.ioFlFndrInfo.fdType    = 'TEXT'; /* make this a text file anyway */
	
     if ( PBSetFInfoSync( (ParmBlkPtr)&fndrInfo) ) {
        return 0;
    }
   /* indicate success                                                    */
    return 1;
}

int             MacOpenWritBinr ( patl )
    char *              patl;
{
    FileParam               fndrInfo;
    char            	    patp [256];     /* <patl> as a Pascal string       */
    int                		len;            /* length of <patp>                */
	OSErr                   err;
	
    /* open the file                                                       */
    if ( ! (WritBinr = fopen( (patl), "wb" )) )
        return 0;


    /* convert <patl> from a C string to a Pascal string                   */
    len = strlen( patl );
    len = len < 256 ? len : 255;
    patp[0] = len;
    strncpy( patp+1, patl, len );
    
    /* set the file type and creator            */
    fndrInfo.ioNamePtr   = (unsigned char*)patp;
    fndrInfo.ioVRefNum   = 0;
    fndrInfo.ioFVersNum  = 0;
    fndrInfo.ioFDirIndex = 0;
    if ( PBGetFInfoSync( (ParmBlkPtr)&fndrInfo) ) {
        return 0;
    }
#if TARGET_CPU_PPC
    if (!gURLAvailable || 
    	(err = URLGetFileInfo ((unsigned char*)patp, 
    	    &fndrInfo.ioFlFndrInfo.fdType,
    	    &fndrInfo.ioFlFndrInfo.fdCreator)) != noErr) {
        fndrInfo.ioFlFndrInfo.fdType    = 'BINA';
	    fndrInfo.ioFlFndrInfo.fdCreator = '????';
    } 
#else
    fndrInfo.ioFlFndrInfo.fdType    = 'BINA';
	fndrInfo.ioFlFndrInfo.fdCreator = '????';
#endif
     if ( PBSetFInfoSync( (ParmBlkPtr)&fndrInfo) ) {
        return 0;
    }
   /* indicate success                                                    */
    return 1;
}

#endif

#ifdef  SYS_IS_MAC_MPW

#include        <Devices.h>
#include        <Files.h>

int             MacOpenWritText ( patl )
    char *              patl;
{
    FInfo               fndrInfo;

    /* open the file                                                       */
    if ( ! (WritText = fopen( (patl), "w" )) )
        return 0;

    /* set the file type to 'TEXT' and the creator to TeachText            */
    getfinfo( patl, 0, &fndrInfo );
    if ( fndrInfo.fdType == 0 )
        fndrInfo.fdType    = 'TEXT';
    if ( fndrInfo.fdCreator == 0 )
        fndrInfo.fdCreator = 'ttxt';
    setfinfo( patl, 0, &fndrInfo );
    /* indicate success                                                    */
    return 1;
}
#endif

#ifdef  SYS_IS_MAC_BOTH

int             MacClosWritText ()
{
    return (fclose( WritText ) == 0);
}

unsigned long   MacBlckWritTextOld ( blk, len )
    unsigned char *     blk;
    unsigned long       len;
{
    unsigned long       i;              /* loop variable                   */

    for ( i = 0; i < len; i++ ) {
        if (fputc( (blk[i] != '\012' ? blk[i] : '\n'), WritText ) == EOF)
            return i;
    }
    return len;
}

unsigned char MacWriteBuf[4096];

unsigned long   MacBlckWritText ( blk, len )
    unsigned char *     blk;
    unsigned long       len;
{
    unsigned long       i;              /* loop variable                   */
	unsigned char *     src;
	unsigned char *     dst;
	unsigned long       count;	
	src = blk;
	dst = MacWriteBuf;
	count = 0;
    for ( i = 0; i < len; i++ ) {
        if (count == sizeof (MacWriteBuf)) {
        	count = fwrite (&MacWriteBuf, 1L, sizeof (MacWriteBuf), WritText );
        	if (count < sizeof (MacWriteBuf))
        		return i - sizeof(MacWriteBuf) + count;
        	count = 0;
			dst = MacWriteBuf;
        }
        if ((*dst = *src) == '\n') 
			*dst = '\r';
		src++;
		dst++;
		count++;        
    }
    return len;
}


char            WritName [256];         /* name of the file                */
FSSpec          WritFSSpec;             /* fsspec of the file              */
short           WritRef;                /* file reference number           */
FileParam       WritFIPB;               /* Finder Info parameter block     */
unsigned long   WritPart;               /* current part of MacBinary file  */
unsigned long   WritType;               /* type of file, e.g. 'TEXT'       */
unsigned long   WritCrtr;               /* creator of file, e.g. 'ttxt'    */
unsigned long   WritFlgs;               /* finder flags                    */
unsigned long   WritCDat;               /* creation date of file           */
unsigned long   WritMDat;               /* last modification date of file  */
unsigned long   WritLDat;               /* nr. of bytes left in data fork  */
unsigned long   WritLRsc;               /* nr. of bytes left in resource   */

int             OPEN_WRIT_MACB ( patl )
    char *              patl;
{
    unsigned long       i;              /* loop variable                   */

    /* find the last semicolon                                             */
    for ( i = strlen(patl); 0 < i && patl[i] != ':'; i-- )
        ;

    /* copy the directory part to 'WritName'                               */
    WritName[0] = (0 < i ? i+1 : 0);
    for ( i = 1; i <= WritName[0]; i++ )
        WritName[i] = patl[i-1];

    /* indicate success                                                    */
    WritPart = 0;
    return 1;
}

int             CLOS_WRIT_MACB ()
{

    /* first get the current settings                                      */
#ifdef SYS_IS_MAC_MWC
    WritFIPB.ioNamePtr   = (StringPtr)WritName;
#else
    WritFIPB.ioNamePtr   = WritName;
#endif
    WritFIPB.ioVRefNum   = 0;
    WritFIPB.ioFVersNum  = 0;
    WritFIPB.ioFDirIndex = 0;
    if ( PBGetFInfoSync( (ParmBlkPtr)&WritFIPB) ) {
        return 0;
    }

    /* now set some fields to the values found in the MacBinary header     */
    WritFIPB.ioFlFndrInfo.fdType    = WritType;
    WritFIPB.ioFlFndrInfo.fdCreator = WritCrtr;
    WritFIPB.ioFlFndrInfo.fdFlags   = WritFlgs;
    WritFIPB.ioFlCrDat              = WritCDat;
    WritFIPB.ioFlMdDat              = WritMDat;
    if ( PBSetFInfoSync( (ParmBlkPtr)&WritFIPB) ) {
        return 0;
    }

    /* indicate success                                                    */
    return 1;
}

unsigned long   BLCK_WRIT_MACB ( blk, len )
    unsigned char *     blk;
    unsigned long       len;
{
    unsigned long       cnt;            /* number of bytes written         */
    unsigned long       i;              /* loop variable                   */
    long 				count; 
    long 				need;
	OSErr err;
	
    /* first comes the header (128 bytes long)                             */
    cnt = 0;
    if ( WritPart == 0 ) {
        for ( i = 1; i <= blk[1]; i++ )
            WritName[WritName[0]+i] = blk[i+1];
        WritName[0] += blk[1];

        WritType = (blk[65]<<24) + (blk[66]<<16) + (blk[67]<< 8) + (blk[68]);
        WritCrtr = (blk[69]<<24) + (blk[70]<<16) + (blk[71]<< 8) + (blk[72]);
        WritFlgs = (blk[73]<< 8) + 0;
        WritLDat = (blk[83]<<24) + (blk[84]<<16) + (blk[85]<< 8) + (blk[86]);
        WritLRsc = (blk[87]<<24) + (blk[88]<<16) + (blk[89]<< 8) + (blk[90]);
        WritCDat = (blk[91]<<24) + (blk[92]<<16) + (blk[93]<< 8) + (blk[94]);
        WritMDat = (blk[95]<<24) + (blk[96]<<16) + (blk[97]<< 8) + (blk[98]);

        
        err = FSMakeFSSpec (0,0, (unsigned char *)WritName, &WritFSSpec);
       	if (err == fnfErr) 	
       		err = FSpCreate(&WritFSSpec, WritCrtr, WritType, -1);
		if (err)
			return 0;

        cnt += 128;
        WritPart = 1;
    }

    /* open the data fork                                                  */
    if ( WritPart == 1 && cnt < len ) {
 			
        if ( err = FSpOpenDF(&WritFSSpec, fsWrPerm, &WritRef) ) {
            return cnt;
        }
        WritPart = 2;
    }

    /* next comes the data fork (padded to a multiple of 128 bytes)        */
    if ( WritPart == 2 ) {
        while ( WritLDat != 0 && cnt < len ) {
        	need = (128 <= WritLDat ? 128 : WritLDat);
        	count = need;
        	err = FSWrite (WritRef, &count, (Ptr) (blk + cnt));
            if (err || count < need ) {
               err = FSClose (WritRef);
                return cnt;
            }
            cnt += 128;
            WritLDat -= count;
        }
        if ( WritLDat == 0 )  WritPart = 3;
    }

    /* close the data fork                                                 */
    if ( WritPart == 3 ) {
        err = FSClose (WritRef);
        WritPart = 4;
    }

    /* open the resource fork                                              */
    if ( WritPart == 4 && cnt < len ) {
        if ( err = FSpOpenRF(&WritFSSpec, fsWrPerm, &WritRef) ) {
            return cnt;
        }
        WritPart = 5;
    }
        
    /* and finally comes the resource fork                                 */
    if ( WritPart == 5 ) {
        while ( WritLRsc != 0 && cnt < len ) {
        	need = (128 <= WritLRsc ? 128 : WritLRsc);
        	count = need;
        	err = FSWrite (WritRef, &count, (Ptr) (blk + cnt));
            if (err || count < need ) {
               err = FSClose (WritRef);
                return cnt;
            }
            cnt += 128;
            WritLRsc -= count;
        }
        if ( WritLRsc == 0 )  WritPart = 6;
    }

    /* close the resource fork                                             */
    if ( WritPart == 6 ) {
        err = FSClose (WritRef);
        WritPart = 7;
    }

    /* indicate success                                                    */
    return cnt;
}

int             MacMakeDire ( patl )
    char *              patl;
{
    HFileParam          request;        /* structure describing request    */
    char                patp [256];     /* <patl> as a Pascal string       */
    int                 len;            /* length of <patp>                */

    /* convert <patl> from a C string to a Pascal string                   */
    len = strlen( patl );
    len = len < 256 ? len : 255;
    patp[0] = len;
    strncpy( patp+1, patl, len );

    /* set up the request                                                  */
    request.ioNamePtr = (unsigned char*)patp;
    request.ioVRefNum = 0;
    request.ioDirID   = 0;
    if (noErr == PBDirCreateSync( (HParmBlkPtr)&request))
    /* return result                                                       */
	    return (request.ioResult == 0);
	else
		return 0;
}

#endif

/****************************************************************************
**
*F  MacConvDire(...) . . . . . . . . convert a directory name to local format
**
**  'MacConvDire( <dirl>, <diru>, <root>,<abs>,<rel>,<sep>,<end> )'
**
**  similr to 'ConvDire'  returns  in  <dirl>  the  universal  directory  name   <diru>
**  converted to the  local format.  <diru> contains an  arbitrary number  of
**  components separated by  slashes ('/'),  where each component may contain
**  uppercase,  lowercase,  and all special characters,  and may be up to 255
**  characters long.
**
**  <root> is the string that is used for the root directory in local format.
**  <abs> is the string that starts absolute directory names in local format,
**  <rel> starts relative names, directory components are separated by <sep>,
**  and <end> separates the directory part and a proper file name.
**
**  If <diru> is the empty string, then 'ConvDire' returns in <dirl> also the
**  empty string, instead of '<rel><end>'.
*/
int             MacConvDire ( dirl, diru, root, abs, rel, sep, end )
    char *              dirl;
    char *              diru;
    char *              root;
    char *              abs;
    char *              rel;
    char *              sep;
    char *              end;
{
    char                namu [256];     /* file name part, univ.           */
    char                naml [256];     /* file name part, local           */
    char *              d;              /* loop variable                   */
    char *              s;              /* loop variable                   */

    /* special case for the root directory                                 */
    if ( *diru == '/' && diru[1] == '\0' ) {
        for ( s = root; *s != '\0'; s++ )  *dirl++ = *s;
        *dirl = '\0';
        return 1;
    }

    /* start the file name with <abs> or <rel>                             */
    d = diru;
    if ( *diru == '/' )
        for ( d++, s = abs; *s != '\0'; s++ )  *dirl++ = *s;
    else if ( *diru != '\0' )
        for (      s = rel; *s != '\0'; s++ )  *dirl++ = *s;

    /* add the components of the directory part separated by <sep>         */
    while ( *d != '\0' ) {
        s = namu;
        while ( *d != '\0' && *d != '/' )  *s++ = *d++;
        *s = '\0';
        CONV_NAME( naml, namu );
        for ( s = naml; *s != '\0'; s++ )  *dirl++ = *s;
        if ( *d == '/' )
            for ( d++, s = sep; *s != '\0'; s++ )  *dirl++ = *s;
    }

    /* add the divisor <end>                                               */
    if ( *diru != '\0' )
        for ( s = end; *s != '\0'; s++ )  *dirl++ = *s;

    /* terminate the file name and indicate success                        */
    *dirl = '\0';
    return 1;
}



/****************************************************************************
**
*F  MakeDirs(<pre>,<patu>)  . . . . . . . . . . . . . .  make all directories
**
**  'MakeDirs' tries  to  make all the directories   along the universal path
**  name <patu> (i.e., with components separated by '/').   <pre> is a prefix
**  that is prepended to all path names.
*/
#ifdef  MAKE_DIRE

int             MakeDirs ( pre, patu )
    char *              pre;
    char *              patu;
{
    char                patl [1024];    /* path name, local                */
    char                diru [256];     /* directory part of <patu>, univ. */
    char                dirl [256];     /* directory part of <patl>, local */
    char                namu [256];     /* file name part of <patu>, univ. */
    char                naml [256];     /* file name part of <patl>, local */
    char                * d,  * n;      /* loop variables                  */

    /* if <patu> is an absolute path, copy the slash '/'                   */
    d = diru;
    if ( *patu == '/' )  *d++ = *patu++;

    while ( *patu != '\0' ) {

        /* copy the file name part of <patu> into <namu>                   */
        for ( n = namu; *patu != '\0' && *patu != '/'; ) *n++ = *patu++;
        if ( *patu != '\0' )  patu++;

        /* convert the name into local format and make the directory       */
        *d = '\0';  *n = '\0';
        CONV_DIRE( dirl, diru );
        CONV_NAME( naml, namu );
        strcpy( patl, pre  );
        strcat( patl, dirl );
        strcat( patl, naml );
        /*N 1993/11/03 martin what should I do with the return code?       */
        /*N 1993/11/03 martin it could be 0 if the directory exists!       */
        MAKE_DIRE( patl );

        /* append the file name part to the directory part                 */
        if ( d != diru && d[-1] != '/' )  *d++ = '/';
        for ( n = namu; *n != '\0'; ) *d++ = *n++;

    }

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*F  IsMatchName(<pat>,<str>)  . . test if a string matches a wildcard pattern
**
**  'IsMatchName' return 1 if the pattern <pat>  matches the string <str> and
**  0 otherwise.  A   '?' in <pat>  matches any  character  in <str>,  a  '*'
**  matches any string  in <str>, other characters in   <pat> match the  same
**  character in <str>.  Characters for which 'IsSpec[<ch>]' is true will not
**  be matched by '?' and '*'.
**
**  Jeff Damens  wrote the name match code in 'booz' (originally for Kermit).
*/
int             IsSpec [256];           /* nonzero for special characters  */

int             IsMatchName ( pat, str )
    char *              pat;            /* pattern to match against        */
    char *              str;            /* string  to match                */
{
    char *              pos = 0;        /* pos. after last '*' in pattern  */
    char *              tmp = 0;        /* corresponding match in string   */

    /* try to match the name part                                          */
    while ( *pat != '\0' || *str != '\0' ) {
        if      ( *pat==*str                  ) { pat++;       str++;       }
        else if ( *pat=='?' && ! IsSpec[*str] ) { pat++;       str++;       }
        else if ( *pat=='?' && *str != '\0'   ) { pat++;       str++;       }
        else if ( *pat=='*'                   ) { pos = ++pat; tmp =   str; }
        else if ( tmp != 0  && ! IsSpec[*tmp] ) { pat =   pos; str = ++tmp; }
        else                                    break;
    }
    return *pat == '\0' && *str == '\0';
}


/****************************************************************************
**
*F  OpenReadArch(<patl>)  . . . . . . . . . . . . . . try to open the archive
*F  ClosReadArch()  . . . . . . . . . . . . . . . . . . . . close the archive
*F  GotoReadArch(<pos>) . . . . . .  goto an absolute position in the archive
*F  ByteReadArch()  . . . . . . . . . read a  8 bit unsigned from the archive
*F  HalfReadArch()  . . . . . . . . . read a 16 bit unsigned from the archive
*F  TripReadArch()  . . . . . . . . . read a 24 bit unsigned from the archive
*F  WordReadArch()  . . . . . . . . . read a 32 bit unsigned from the archive
*F  BlckReadArch(<blk>,<len>) . . . .  read a block of bytes from the archive
*V  Descript  . . . . . . . . . . . . . . . . . . . . header from the archive
*F  DescReadArch()  . . . . . . . . . . . .  read the header from the archive
*V  Entry . . . . . . . . . . . . . . . . header of a member from the archive
*F  EntrReadArch()  . . . . . .  read the header of a member from the archive
**
**  'OpenReadArch' tries to open the archive with  local path name <patl> (as
**  specified by the user on the command  line) for reading  and returns 1 to
**  indicate success or 0 to indicate that the file cannot be opened.
**
**  'ClosReadArch' closes the archive again.
**
**  'GotoReadArch'  positions the  archive  at the  position <pos>, i.e., the
**  next call to 'ByteReadArch' will return the byte at position <pos>.  Note
**  that 'GotoReadArch' does not use 'fseek', because 'fseek' is unreliable.
**
**  'ByteReadArch' returns the next   byte  unsigned  8 bit from the archive.
**  'HalfReadArch' returns the next 2 bytes unsigned 16 bit from the archive.
**  'TripReadArch' returns the next 3 bytes unsigned 24 bit from the archive.
**  'WordReadArch' returns the next 4 bytes unsigned 32 bit from the archive.
**  'BlckReadArch' reads <len> bytes into the buffer <blk>.
**
**  'Descript' is the description of the archive.
**
**  'DescReadArch' reads the description  of the archive  that starts at  the
**  current position into the structure 'Descript'.  It should of course only
**  be called at the start of the archive file.
**
**  'Entry' is the directory entry of the current member from the archive.
**
**  'EntrReadArch'  reads the directory entry of  a member that starts at the
**  current position into the structure 'Entry'.
*/
unsigned char   BufArch [64+4096];      /* buffer for the archive          */

unsigned char * PtrArch;                /* pointer to the next byte        */

unsigned char * EndArch;                /* pointer to the last byte        */

unsigned char * BegArch;                /* pointer to the first valid byte        */

unsigned long   PosArch;                /* position of 'BufArch[0]'        */

int             OpenReadArch ( patl )
    char *              patl;
{
    PtrArch = BegArch = EndArch = (BufArch+64);
    PosArch = 0;
    return OPEN_READ_ARCH( patl );
}

int     ClosReadArch ()
{
    return CLOS_READ_ARCH();
}

int             FillReadArch ()
{
    unsigned char *     s;              /* loop variable                   */
    unsigned char *     d;              /* loop variable                   */

    /* copy the last characters to the beginning (for short backward seeks)*/
    d = BufArch;
    for ( s = EndArch-64; s < EndArch; s++ )
        *d++ = *s;
    PosArch += EndArch - (BufArch+64);

	if (EndArch - BegArch < 64L)
		BegArch = BufArch + 64 - (EndArch - BegArch);
	else
		BegArch = BufArch;
		
    /* read a block                                                        */
    PtrArch = BufArch+64;
    EndArch = PtrArch + BLCK_READ_ARCH( PtrArch, 4096 );

    /* return the first character                                          */
    return (PtrArch < EndArch ? *PtrArch++ : EOF);
}

int             GotoReadArch ( pos )
    unsigned long       pos;
{
    /* for long backward seeks goto the beginning of the file              */
    if ( pos+64 - (BegArch - BufArch) < PosArch ) {
#ifdef SEEK_READ_ARCH
		if (!SEEK_READ_ARCH(pos))
			return 0;
        PtrArch = BegArch = EndArch = BufArch+64;
        PosArch = pos;
#else
        if ( ! RWND_READ_ARCH() )
            return 0;
        PtrArch = BegArch = EndArch = BufArch+64;
        PosArch = 0;
#endif
    }

#ifdef SEEK_READ_ARCH
    if ( PosArch + (EndArch - (BufArch+64)) +4096 <= pos ) {
		if (!SEEK_READ_ARCH(pos))
			return 0;
        PtrArch = BegArch = EndArch = BufArch+64;
        PosArch = pos;
    }
#endif

    /* jump forward bufferwise                                             */
    while ( PosArch + (EndArch - (BufArch+64)) <= pos ) {
        if ( FillReadArch() == EOF )
            return 0;
    }

    /* and goto the position (which is now in the buffer)                  */
    PtrArch = (BufArch+64) + (pos - PosArch);

    /* indicate success                                                    */
    return 1;
}

#define ByteReadArch()          (PtrArch<EndArch?*PtrArch++:FillReadArch())

unsigned long   HalfReadArch ()
{
    unsigned long       result;
    result  = ((unsigned long)ByteReadArch());
    result += ((unsigned long)ByteReadArch()) << 8;
    return result;
}

unsigned long   FlahReadArch ()
{
    unsigned long       result;
    result  = ((unsigned long)ByteReadArch()) << 8;
    result += ((unsigned long)ByteReadArch());
    return result;
}

unsigned long   TripReadArch ()
{
    unsigned long       result;
    result  = ((unsigned long)ByteReadArch());
    result += ((unsigned long)ByteReadArch()) << 8;
    result += ((unsigned long)ByteReadArch()) << 16;
    return result;
}

unsigned long   WordReadArch ()
{
    unsigned long       result;
    result  = ((unsigned long)ByteReadArch());
    result += ((unsigned long)ByteReadArch()) << 8;
    result += ((unsigned long)ByteReadArch()) << 16;
    result += ((unsigned long)ByteReadArch()) << 24;
    return result;
}

unsigned long   BlckReadArch ( blk, len )
    char *              blk;
    unsigned long       len;
{
    int                 ch;             /* character read                  */
    unsigned long       i;              /* loop variable                   */
    for ( i = 0; i < len; i++ ) {
        if ( (ch = ByteReadArch()) == EOF )
            return i;
        else
            *blk++ = ch;
    }
    return len;
}

struct {
    char                text[20];       /* "ZOO 2.10 Archive.<ctr>Z"       */
    unsigned long       magic;          /* magic word 0xfdc4a7dc           */
    unsigned long       posent;         /* position of first directory ent.*/
    unsigned long       klhvmh;         /* two's complement of posent      */
    unsigned char       majver;         /* major version needed to extract */
    unsigned char       minver;         /* minor version needed to extract */
    unsigned char       type;           /* type of current member (0,1)    */
    unsigned long       poscmt;         /* position of comment, 0 if none  */
    unsigned short      sizcmt;         /* length   of comment, 0 if none  */
    unsigned char       modgen;         /* gens. on, gen. limit            */
    /* the following are not in the archive file and are computed          */
    unsigned long       sizorg;         /* uncompressed size of members    */
    unsigned long       siznow;         /*   compressed size of members    */
    unsigned long       number;         /* number of members               */

}               Descript;

int             DescReadArch ()
{
    /* read the text at the beginning                                      */
    BlckReadArch(Descript.text,20L);  Descript.text[20] = '\0';

    /* try to read the magic words                                         */
    if ( (Descript.magic = WordReadArch()) != (unsigned long)0xfdc4a7dcL )
        return 0;

    /* read the old part of the description                                */
    Descript.posent = WordReadArch();
    Descript.klhvmh = WordReadArch();
    Descript.majver = ByteReadArch();
    Descript.minver = ByteReadArch();

    /* read the new part of the description if present                     */
    Descript.type   = (34 < Descript.posent ? ByteReadArch() : 0);
    Descript.poscmt = (34 < Descript.posent ? WordReadArch() : 0);
    Descript.sizcmt = (34 < Descript.posent ? HalfReadArch() : 0);
    Descript.modgen = (34 < Descript.posent ? ByteReadArch() : 0);

    /* initialize the fake entries                                         */
    Descript.sizorg = 0;
    Descript.siznow = 0;
    Descript.number = 0;

    /* indicate success                                                    */
    return 1;
}

struct {
    unsigned long       magic;          /* magic word 0xfdc4a7dc           */
    unsigned char       type;           /* type of current member (1)      */
    unsigned char       method;         /* packing method of member (0..2) */
    unsigned long       posnxt;         /* position of next member         */
    unsigned long       posdat;         /* position of data                */
    unsigned short      datdos;         /* date (in DOS format)            */
    unsigned short      timdos;         /* time (in DOS format)            */
    unsigned short      crcdat;         /* crc value of member             */
    unsigned long       sizorg;         /* uncompressed size of member     */
    unsigned long       siznow;         /*   compressed size of member     */
    unsigned char       majver;         /* major version needed to extract */
    unsigned char       minver;         /* minor version needed to extract */
    unsigned char       delete;         /* 1 if member is deleted, 0 else  */
    unsigned char       spared;         /* spare entry to pad entry        */
    unsigned long       poscmt;         /* position of comment, 0 if none  */
    unsigned short      sizcmt;         /* length   of comment, 0 if none  */
    char                nams [14];      /* short name of member or archive */
    unsigned short      lvar;           /* length of variable part         */
    unsigned char       timzon;         /* time zone                       */
    unsigned short      crcent;         /* crc value of entry              */
    unsigned char       lnamu;          /* length of long name             */
    unsigned char       ldiru;          /* length of directory             */
    char                namu [256];     /* univ. name of member of archive */
    char                diru [256];     /* univ. name of directory         */
    unsigned short      system;         /* system identifier               */
    unsigned long       permis;         /* file permissions                */
    unsigned char       modgen;         /* gens. on, last gen., gen. limit */
    unsigned short      ver;            /* version number of member        */
    /* the following are not in the archive file and are computed          */
    char                naml [256];     /* local name of member of archive */
    char                dirl [256];     /* local name of directory         */
    char                patl [512];     /* local path name of member       */
    char                patv [512];     /* ditto but with version number   */
    char *              patw;           /* name used by '-l'               */
    unsigned long       year;           /* years since 1900                */
    unsigned long       month;          /* month since January             */
    unsigned long       day;            /* day of month                    */
    unsigned long       hour;           /* hours since midnight            */
    unsigned long       min;            /* minutes after the hour          */
    unsigned long       sec;            /* seconds after the minutes       */
}               Entry;

int             EntrReadArch ()
{
    unsigned long       l;              /* 'Entry.lnamu+Entry.ldiru'       */
    char *              p;              /* loop variable                   */

    /* try to read the magic words                                         */
    if ( (Entry.magic = WordReadArch()) != (unsigned long)0xfdc4a7dcL )
        return 0;

    /* read the fixed part of the directory entry                          */
    Entry.type   = ByteReadArch();
    Entry.method = ByteReadArch();
    Entry.posnxt = WordReadArch();
    Entry.posdat = WordReadArch();
    Entry.datdos = HalfReadArch();
    Entry.timdos = HalfReadArch();
    Entry.crcdat = HalfReadArch();
    Entry.sizorg = WordReadArch();
    Entry.siznow = WordReadArch();
    Entry.majver = ByteReadArch();
    Entry.minver = ByteReadArch();
    Entry.delete = ByteReadArch();
    Entry.spared = ByteReadArch();
    Entry.poscmt = WordReadArch();
    Entry.sizcmt = HalfReadArch();
    BlckReadArch(Entry.nams,13L);  Entry.nams[13] = '\0';

    /* handle the long name and the directory in the variable part         */
    Entry.lvar   = (Entry.type == 2  ? HalfReadArch() : 0);
    Entry.timzon = (Entry.type == 2  ? ByteReadArch() : 127);
    Entry.crcent = (Entry.type == 2  ? HalfReadArch() : 0);
    Entry.lnamu  = (0 < Entry.lvar   ? ByteReadArch() : 0);
    Entry.ldiru  = (1 < Entry.lvar   ? ByteReadArch() : 0);
    BlckReadArch(Entry.namu,(unsigned long)Entry.lnamu);
    Entry.namu[Entry.lnamu] = '\0';
    BlckReadArch(Entry.diru,(unsigned long)Entry.ldiru);
    Entry.diru[Entry.ldiru] = '\0';
    l = Entry.lnamu + Entry.ldiru;
    Entry.system = (l+2 < Entry.lvar ? HalfReadArch() : 0);
    Entry.permis = (l+4 < Entry.lvar ? TripReadArch() : 0);
    Entry.modgen = (l+7 < Entry.lvar ? ByteReadArch() : 0);
    Entry.ver    = (l+7 < Entry.lvar ? HalfReadArch() : 0);

    /* convert the names to local format                                   */
    if ( Entry.system == 0 || Entry.system == 2 ) {
        CONV_DIRE( Entry.dirl, Entry.diru );
        CONV_NAME( Entry.naml, (Entry.lnamu ? Entry.namu : Entry.nams) );
    }
    else {
        strcpy( Entry.dirl, Entry.diru );
        strcpy( Entry.naml, (Entry.lnamu ? Entry.namu : Entry.nams) );
    }
    strcpy( Entry.patl, Entry.dirl );
    strcat( Entry.patl, Entry.naml );

    /* create the name with the version appended                           */
    strcpy( Entry.patv, Entry.patl );
    p = Entry.patv;  while ( *p != '\0' )  p++;
    *p++ = ';';
    for ( l = 10000; 0 < l; l /= 10 )
        if ( l == 1 || l <= Entry.ver )
            *p++ = (Entry.ver / l) % 10 + '0';
    *p = '\0';
    Entry.patw = ((Entry.modgen&0xc0)!=0x80 ? Entry.patl : Entry.patv);

    /* convert the time                                                    */
    Entry.year  = ((Entry.datdos >>  9) & 0x7f) + 80;
    Entry.month = ((Entry.datdos >>  5) & 0x0f) - 1;
    Entry.day   = ((Entry.datdos      ) & 0x1f);
    Entry.hour  = ((Entry.timdos >> 11) & 0x1f);
    Entry.min   = ((Entry.timdos >>  5) & 0x3f);
    Entry.sec   = ((Entry.timdos      ) & 0x1f) * 2;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenReadFile(<patl>,<bin>)  . . . . . . . . . . . open a file for reading
*F  ClosReadFile()  . . . . . . . . . . . . . . . . . . .  close a file again
*F  BlckReadFile(<blk>,<len>) . . . . . . .  write a block of bytes to a file
*F  BufFile[] . . . . . . . . . . . . . . . . . . . . . . buffer for the file
**
**  'OpenReadFile' tries to open the archive  with local path name <patl> (as
**  converted by 'CONV_NAME'  and 'CONV_DIRE') for reading  and returns 1  to
**  indicate success  and 0 to  indicate that the file cannot  be opened.  If
**  <bin> is  0, the file is opened   as a text file,   otherwise the file is
**  opened as a binary file.
**
**  'ClosReadFile' closes the file again.
**
**  'BlckReadFile' reads <len>  bytes from the  file to the buffer  <blk> and
**  returns the  number    of bytes actually   read.   If  no file    is open
**  'BlckReadFile' only returns 0.
**
**  'BufFile'  is  a buffer for  the  file (which is not   used  by the above
**  functions).
*/
unsigned long   IsOpenReadFile;

int             OpenReadFile ( patl, bin )
    char *              patl;
    unsigned long       bin;
{
    if      ( bin == 0 && OPEN_READ_TEXT(patl) ) {
        IsOpenReadFile = 1;
        return 1;
    }
    else if ( bin == 1 && OPEN_READ_BINR(patl) ) {
        IsOpenReadFile = 2;
        return 1;
    }
    else {
        return 0;
    }
}

int             ClosReadFile ()
{
    if      ( IsOpenReadFile == 1 ) {
        IsOpenReadFile = 0;
        return CLOS_READ_TEXT();
    }
    else if ( IsOpenReadFile == 2 ) {
        IsOpenReadFile = 0;
        return CLOS_READ_BINR();
    }
    else {
        return 0;
    }
}

unsigned long   BlckReadFile ( blk, len )
    char *              blk;
    unsigned long       len;
{
    if      ( IsOpenReadFile == 1 ) {
        return BLCK_READ_TEXT( blk, len );
    }
    else if ( IsOpenReadFile == 2 ) {
        return BLCK_READ_BINR( blk, len );
    }
    else {
        return 0;
    }
}

char            BufFile [8192];         /* at least MAX_OFF                */


/****************************************************************************
**
*F  OpenWritFile(<patl>,<bin>)  . . . . . . . . . . . open a file for writing
*F  ClosWritFile()  . . . . . . . . . . . . . . . . . . .  close a file again
*F  BlckWritFile(<blk>,<len>) . . . . . . .  write a block of bytes to a file
**
**  'OpenWritFile' tries to open the archive  with local path name <patl> (as
**  converted by 'CONV_NAME'  and 'CONV_DIRE') for writing  and returns  1 to
**  indicate success  and 0 to indicate  that the file cannot  be opened.  If
**  <bin> is  0, the file  is opened as a text   file, otherwise the  file is
**  opened as a binary file.
**
**  'ClosWritFile' closes the file again.
**
**  'BlckWritFile' writes <len>  bytes from the  buffer <blk> to the file and
**  returns the number  of bytes actually written,  which is less than  <len>
**  only when a write error happened.  If no file is open 'BlckWritFile' only
**  returns <len>.
*/
unsigned long   IsOpenWritFile;

int             OpenWritFile ( patl, bin )
    char *              patl;
    unsigned long       bin;
{
    if ( patl == 0 ) {
        IsOpenWritFile = 1;
        return 1;
    }
    else if ( bin == 1 && OPEN_WRIT_TEXT(patl) ) {
        IsOpenWritFile = 2;
        return 1;
    }
    else if ( bin == 2 && OPEN_WRIT_BINR(patl) ) {
        IsOpenWritFile = 3;
        return 1;
    }
#ifdef  SYS_IS_MAC_BOTH
    else if ( bin == 3 && OPEN_WRIT_MACB(patl) ) {
        IsOpenWritFile = 4;
        return 1;
    }
#endif
    else {
        return 0;
    }
}

int             ClosWritFile ()
{
    if      ( IsOpenWritFile == 1 ) {
        return 1;
    }
    else if ( IsOpenWritFile == 2 ) {
        IsOpenWritFile = 0;
        return CLOS_WRIT_TEXT();
    }
    else if ( IsOpenWritFile == 3 ) {
        IsOpenWritFile = 0;
        return CLOS_WRIT_BINR();
    }
#ifdef  SYS_IS_MAC_BOTH
    else if ( IsOpenWritFile == 4 ) {
        IsOpenWritFile = 0;
        return CLOS_WRIT_MACB();
    }
#endif
    else {
        return 0;
    }
}

unsigned long   BlckWritFile ( blk, len )
    char *              blk;
    unsigned long       len;
{
    unsigned long       i;              /* loop variable                   */
    if      ( IsOpenWritFile == 1 ) {
        for ( i = 0; i < len; i++ )
            putchar( blk[i] );
        return len;
    }
    else if ( IsOpenWritFile == 2 ) {
        return BLCK_WRIT_TEXT( blk, len );
    }
    else if ( IsOpenWritFile == 3 ) {
        return BLCK_WRIT_BINR( blk, len );
    }
#ifdef  SYS_IS_MAC_BOTH
    else if ( IsOpenWritFile == 4 ) {
#ifdef SYS_IS_MAC_MWC
        return BLCK_WRIT_MACB( (StringPtr)blk, len );
#else
        return BLCK_WRIT_MACB( blk, len );
#endif
    }
#endif
    else {
        return len;
    }
}


/****************************************************************************
**
*V  Crc . . . . . . . . . . . . . . . . current cyclic redundancy check value
*F  CRC_BYTE(<crc>,<byte>)  . . . . . cyclic redundancy check value of a byte
*F  InitCrc() . . . . . . . . . . . . initialize cylic redundancy check table
**
**  'Crc'  is used by  the  decoding  functions to  communicate  the computed
**  CRC-16 value to the calling function.
**
**  'CRC_BYTE' returns the new value that one gets by updating the old CRC-16
**  value <crc> with the additional byte  <byte>.  It is  used to compute the
**  ANSI CRC-16 value for  each member of the archive.   They idea is that if
**  not  too many bits  of a member have corrupted,  then  the CRC-16 will be
**  different, and so the corruption can be detected.
**
**  'InitCrc' initialize the table that 'CRC_BYTE' uses.   You must call this
**  before using 'CRC_BYTE'.
**
**  The  ANSI CRC-16  value  for a sequence of    bits of lenght  <length> is
**  computed by shifting the bits through the following shift register (where
**  'O' are the latches and '+' denotes logical xor)
**
**                  bit          bit            ...  bit   bit   bit   -->-
**                     <length>     <length>-1          3     2     1     |
**                                                                        V
**      -<-------<---------------------------------------------------<----+
**      |       |                                                   |     ^
**      V       V                                                   V     |
**      ->O-->O-+>O-->O-->O-->O-->O-->O-->O-->O-->O-->O-->O-->O-->O-+>O-->-
**       MSB                                                         LSB
**
**  Mathematically we compute in the polynomial ring $GF(2)[x]$ the remainder
**
**      $$\sum_{i=1}^{i=length}{bit_i x^{length+16-i}} mod crcpol$$
**
**  where  $crcpol = x^{16}  + x^{15}  +  x^2 +  1$.  Then  the  CRC-16 value
**  consists  of the  coefficients   of  the remainder,  with    the constant
**  coefficient being  the most significant bit (MSB)  and the coefficient of
**  $x^{15}$ the least significant bit (LSB).
**
**  Changing  a  single bit will  always cause  the  CRC-16  value to change,
**  because $x^{i} mod crcpol$ is never zero.
**
**  Changing two  bits  will cause the CRC-16   value to change,  unless  the
**  distance between the bits is a multiple  of 32767, which  is the order of
**  $x$ modulo $crcpol = (x+1)(x^{15} + x + 1)$ ($x^{15}+x+1$ is primitive).
**
**  Changing  16 adjacent  bits will always  cause the  CRC value  to change,
**  because $x^{16}$ and $crcpol$ are relatively prime.
**
**  David Schwaderer provided the CRC-16 calculation in PC Tech Journal 4/85.
*/
unsigned long   Crc;

unsigned long   CrcTab [256];

#define CRC_BYTE(crc,byte)      (((crc)>>8) ^ CrcTab[ ((crc)^(byte))&0xff ])

int             InitCrc ()
{
    unsigned long       i, k;           /* loop variables                  */
    for ( i = 0; i < 256; i++ ) {
        CrcTab[i] = i;
        for ( k = 0; k < 8; k++ )
            CrcTab[i] = (CrcTab[i]>>1) ^ ((CrcTab[i] & 1) ? 0xa001 : 0);
    }
    return 1;
}


/****************************************************************************
**
*V  ErrMsg  . . . . . . . . . . . . . . . . . . . . . . . . . . error message
**
**  'ErrMsg' is used by the  decode functions to communicate  the cause of an
**  error to the calling function.
*/
char *          ErrMsg;


/****************************************************************************
**
*F  DecodeCopy(<size>). . . . . . . . . . . .  extract an uncompressed member
**
**  'DecodeCopy' simply  copies <size> bytes  from the  archive to the output
**  file.
*/
int             DecodeCopy ( size )
    unsigned long       size;
{
    unsigned long       siz;            /* size of current block           */
    unsigned long       crc;            /* CRC-16 value                    */
    unsigned long       i;              /* loop variable                   */

    /* initialize the crc value                                            */
    crc = 0;

    /* loop until everything has been copied                               */
    while ( 0 < size ) {

        /* read as many bytes as possible in one go                        */
        siz = (sizeof(BufFile) < size ? sizeof(BufFile) : size);
        if ( BlckReadArch( BufFile, siz ) != siz ) {
            ErrMsg = "unexpected <eof> in the archive";
            return 0;
        }

        /* write them                                                      */
        if ( BlckWritFile( BufFile, siz ) != siz ) {
            ErrMsg = "cannot write output file";
            return 0;
        }

        /* compute the crc                                                 */
        for ( i = 0; i < siz; i++ )
            crc = CRC_BYTE( crc, BufFile[i] );

        /* on to the next block                                            */
        size -= siz;
    }

    /* store the crc and indicate success                                  */
    Crc = crc;
    return 1;
}


/****************************************************************************
**
*F  DecodeLzd() . . . . . . . . . . . . . . .  extract a LZ compressed member
**
*N  1993/10/21 martin add LZD.
*/
int             DecodeLzd ()
{
    ErrMsg = "LZD not yet implemented";
    return 0;
}


/****************************************************************************
**
*F  DecodeLzh() . . . . . . . . . . . . . . . extract a LZH compressed member
**
**  'DecodeLzh'  decodes  a LZH  (Lempel-Ziv 77  with dynamic Huffman coding)
**  encoded member from the archive to the output file.
**
**  Each member is encoded as a  series of blocks.  Each  block starts with a
**  16  bit field that contains the  number of codes  in this block <number>.
**  The member is terminated by a block with 0 codes.
**
**  Next each block contains the  description of three Huffman codes,  called
**  pre code, literal/length code, and log code.  The purpose of the pre code
**  is to encode the description of  the literal/length code.  The purpose of
**  the literal/length code and the  log code is   to encode the  appropriate
**  fields in the LZ code.   I am too stupid to  understand the format of the
**  description.
**
**  Then   each block contains  <number>  codewords.  There  are two kinds of
**  codewords, *literals* and *copy instructions*.
**
**  A literal represents a certain byte.  For  the moment imaging the literal
**  as having 9 bits.   The first bit  is zero, the other  8 bits contain the
**  byte.
**
**      +--+----------------+
**      | 0|     <byte>     |
**      +--+----------------+
**
**  When a  literal is  encountered, the byte  <byte> that  it represents  is
**  appended to the output.
**
**  A copy  instruction represents a certain  sequence of bytes that appeared
**  already  earlier in the output.  The  copy instruction  consists of three
**  parts, the length, the offset logarithm, and the offset mantissa.
**
**      +--+----------------+--------+--------------------+
**      | 1|   <length>-3   |  <log> |     <mantissa>     |
**      +--+----------------+--------+--------------------+
**
**  <length>  is  the  length  of the sequence   which  this copy instruction
**  represents.  We store '<length>-3', because <length> is never 0, 1, or 2;
**  such sequences are better represented by 0, 1, or  2 literals.  <log> and
**  <mantissa>  together represent the offset at  which the sequence of bytes
**  already  appeared.  '<log>-1'  is  the number of   bits in the <mantissa>
**  field, and the offset is $2^{<log>-1} + <mantissa>$.  For example
**
**      +--+----------------+--------+----------+
**      | 1|        9       |    6   | 0 1 1 0 1|
**      +--+----------------+--------+----------+
**
**  represents the sequence of 12 bytes that appeared $2^5 + 8 + 4  + 1 = 45$
**  bytes earlier in the output (so those 18 bits of input represent 12 bytes
**  of output).
**
**  When a copy instruction  is encountered, the  sequence of  <length> bytes
**  that appeared   <offset> bytes earlier  in the  output  is again appended
**  (copied) to   the output.   For this  purpose  the last  <max>  bytes are
**  remembered,  where  <max>  is the   maximal  used offset.   In 'zoo' this
**  maximal offset is $2^{13} =  8192$.  The buffer in  which those bytes are
**  remembered is  called   a sliding  window for   reasons  that  should  be
**  obvious.
**
**  To save even  more space the first 9  bits of each code, which  represent
**  the type of code and either the literal value or  the length, are encoded
**  using  a Huffman code  called the literal/length  code.   Also the next 4
**  bits in  copy instructions, which represent  the logarithm of the offset,
**  are encoded using a second Huffman code called the log code.
**
**  Those  codes  are fixed, i.e.,  not  adaptive, but  may  vary between the
**  blocks, i.e., in each block  literals/lengths and logs  may be encoded by
**  different codes.  The codes are described at the beginning of each block.
**
**  Haruhiko Okumura  wrote the  LZH code (originally for his 'ar' archiver).
*/
#define MAX_LIT                 255     /* maximal literal code            */
#define MIN_LEN                 3       /* minimal length of match         */
#define MAX_LEN                 256     /* maximal length of match         */
#define MAX_CODE                (MAX_LIT+1 + MAX_LEN+1 - MIN_LEN)
#define BITS_CODE               9       /* 2^BITS_CODE > MAX_CODE (+1?)    */
#define MAX_OFF                 8192    /* 13 bit sliding directory        */
#define MAX_LOG                 13      /* maximal log_2 of offset         */
#define BITS_LOG                4       /* 2^BITS_LOG > MAX_LOG (+1?)      */
#define MAX_PRE                 18      /* maximal pre code                */
#define BITS_PRE                5       /* 2^BITS_PRE > MAX_PRE (+1?)      */

unsigned short  TreeLeft [2*MAX_CODE+1];/* tree for codes   (upper half)   */
unsigned short  TreeRight[2*MAX_CODE+1];/* and  for offsets (lower half)   */
unsigned short  TabCode  [4096];        /* table for fast lookup of codes  */
unsigned char   LenCode  [MAX_CODE+1];  /* number of bits used for code    */
unsigned short  TabLog   [256];         /* table for fast lookup of logs   */
unsigned char   LenLog   [MAX_LOG+1];   /* number of bits used for logs    */
unsigned short  TabPre   [256];         /* table for fast lookup of pres   */
unsigned char   LenPre   [MAX_PRE+1];   /* number of bits used for pres    */

int             MakeTablLzh ( nchar, bitlen, tablebits, table )
    int                 nchar;
    unsigned char       bitlen[];
    int                 tablebits;
    unsigned short      table[];
{
    unsigned short      count[17], weight[17], start[18], *p;
    unsigned int        i, k, len, ch, jutbits, avail, mask;

    for (i = 1; i <= 16; i++) count[i] = 0;
    for (i = 0; i < nchar; i++) count[bitlen[i]]++;

    start[1] = 0;
    for (i = 1; i <= 16; i++)
        start[i + 1] = start[i] + (count[i] << (16 - i));
    if (start[17] != (unsigned short)((unsigned) 1 << 16))
        return 0;

    jutbits = 16 - tablebits;
    for (i = 1; i <= tablebits; i++) {
        start[i] >>= jutbits;
        weight[i] = (unsigned) 1 << (tablebits - i);
    }
    while (i <= 16) {
        weight[i] = (unsigned) 1 << (16 - i);
        i++;
    }

    i = start[tablebits + 1] >> jutbits;
    if (i != (unsigned short)((unsigned) 1 << 16)) {
        k = 1 << tablebits;
        while (i != k) table[i++] = 0;
    }

    avail = nchar;
    mask = (unsigned) 1 << (15 - tablebits);
    for (ch = 0; ch < nchar; ch++) {
        if ((len = bitlen[ch]) == 0) continue;
        if (len <= tablebits) {
            for ( i = 0; i < weight[len]; i++ )  table[i+start[len]] = ch;
        }
        else {
            k = start[len];
            p = &table[k >> jutbits];
            i = len - tablebits;
            while (i != 0) {
                if (*p == 0) {
                    TreeRight[avail] = TreeLeft[avail] = 0;
                    *p = avail++;
                }
                if (k & mask) p = &TreeRight[*p];
                else          p = &TreeLeft[*p];
                k <<= 1;  i--;
            }
            *p = ch;
        }
        start[len] += weight[len];
    }

    /* indicate success                                                    */
    return 1;
}

int             DecodeLzh ()
{
    unsigned long       cnt;            /* number of codes in block        */
    unsigned long       cnt2;           /* number of stuff in pre code     */
    unsigned long       code;           /* code from the Archive           */
    unsigned long       len;            /* length of match                 */
    unsigned long       log;            /* log_2 of offset of match        */
    unsigned long       off;            /* offset of match                 */
    unsigned long       pre;            /* pre code                        */
    char *              cur;            /* current position in BufFile     */
    char *              pos;            /* position of match               */
    char *              end;            /* pointer to the end of BufFile   */
    char *              stp;            /* stop pointer during copy        */
    unsigned long       crc;            /* cyclic redundancy check value   */
    unsigned long       i;              /* loop variable                   */
    unsigned long       bits;           /* the bits we are looking at      */
    unsigned long       bitc;           /* number of bits that are valid   */

#define PEEK_BITS(N)            ((bits >> (bitc-(N))) & ((1L<<(N))-1))
#define FLSH_BITS(N)            if ( (bitc -= (N)) < 16 ) { bits  = (bits<<16) + FlahReadArch(); bitc += 16; }

    /* initialize bit source, output pointer, and crc                      */
    bits = 0;  bitc = 0;  FLSH_BITS(0);
    cur = BufFile;  end = BufFile + MAX_OFF;
    crc = 0;

    /* loop until all blocks have been read                                */
    cnt = PEEK_BITS( 16 );  FLSH_BITS( 16 );
    while ( cnt != 0 ) {

        /* read the pre code                                               */
        cnt2 = PEEK_BITS( BITS_PRE );  FLSH_BITS( BITS_PRE );
        if ( cnt2 == 0 ) {
            pre = PEEK_BITS( BITS_PRE );  FLSH_BITS( BITS_PRE );
            for ( i = 0; i <      256; i++ )  TabPre[i] = pre;
            for ( i = 0; i <= MAX_PRE; i++ )  LenPre[i] = 0;
        }
        else {
            i = 0;
            while ( i < cnt2 ) {
                len = PEEK_BITS( 3 );  FLSH_BITS( 3 );
                if ( len == 7 ) {
                    while ( PEEK_BITS( 1 ) ) { len++; FLSH_BITS( 1 ); }
                    FLSH_BITS( 1 );
                }
                LenPre[i++] = len;
                if ( i == 3 ) {
                    len = PEEK_BITS( 2 );  FLSH_BITS( 2 );
                    while ( 0 < len-- )  LenPre[i++] = 0;
                }
            }
            while ( i <= MAX_PRE )  LenPre[i++] = 0;
            if ( ! MakeTablLzh( MAX_PRE+1, LenPre, 8, TabPre ) ) {
                ErrMsg = "pre code description corrupted";
                return 0;
            }
        }

        /* read the code (using the pre code)                              */
        cnt2 = PEEK_BITS( BITS_CODE );  FLSH_BITS( BITS_CODE );
        if ( cnt2 == 0 ) {
            code = PEEK_BITS( BITS_CODE );  FLSH_BITS( BITS_CODE );
            for ( i = 0; i <      4096; i++ )  TabCode[i] = code;
            for ( i = 0; i <= MAX_CODE; i++ )  LenCode[i] = 0;
        }
        else {
            i = 0;
            while ( i < cnt2 ) {
                len = TabPre[ PEEK_BITS( 8 ) ];
                if ( len <= MAX_PRE ) {
                    FLSH_BITS( LenPre[len] );
                }
                else {
                    FLSH_BITS( 8 );
                    do {
                        if ( PEEK_BITS( 1 ) )  len = TreeRight[len];
                        else                   len = TreeLeft [len];
                        FLSH_BITS( 1 );
                    } while ( MAX_PRE < len );
                }
                if ( len <= 2 ) {
                    if      ( len == 0 ) {
                        len = 1;
                    }
                    else if ( len == 1 ) {
                        len = PEEK_BITS(4)+3;  FLSH_BITS(4);
                    }
                    else {
                        len = PEEK_BITS(BITS_CODE)+20; FLSH_BITS(BITS_CODE);
                    }
                    while ( 0 < len-- )  LenCode[i++] = 0;
                }
                else {
                    LenCode[i++] = len - 2;
                }
            }
            while ( i <= MAX_CODE )  LenCode[i++] = 0;
            if ( ! MakeTablLzh( MAX_CODE+1, LenCode, 12, TabCode ) ) {
                ErrMsg = "literal/length code description corrupted";
                return 0;
            }
        }

        /* read the log_2 of offsets                                       */
        cnt2 = PEEK_BITS( BITS_LOG );  FLSH_BITS( BITS_LOG );
        if ( cnt2 == 0 ) {
            log = PEEK_BITS( BITS_LOG );  FLSH_BITS( BITS_LOG );
            for ( i = 0; i <      256; i++ )  TabLog[i] = log;
            for ( i = 0; i <= MAX_LOG; i++ )  LenLog[i] = 0;
        }
        else {
            i = 0;
            while ( i < cnt2 ) {
                len = PEEK_BITS( 3 );  FLSH_BITS( 3 );
                if ( len == 7 ) {
                    while ( PEEK_BITS( 1 ) ) { len++; FLSH_BITS( 1 ); }
                    FLSH_BITS( 1 );
                }
                LenLog[i++] = len;
            }
            while ( i <= MAX_LOG )  LenLog[i++] = 0;
            if ( ! MakeTablLzh( MAX_LOG+1, LenLog, 8, TabLog ) ) {
                ErrMsg = "log code description corrupted";
                return 0;
            }
        }

        /* read the codes                                                  */
        while ( 0 < cnt-- ) {

            /* try to decode the code the fast way                         */
            code = TabCode[ PEEK_BITS( 12 ) ];

            /* if this code needs more than 12 bits look it up in the tree */
            if ( code <= MAX_CODE ) {
                FLSH_BITS( LenCode[code] );
            }
            else {
                FLSH_BITS( 12 );
                do {
                    if ( PEEK_BITS( 1 ) )  code = TreeRight[code];
                    else                   code = TreeLeft [code];
                    FLSH_BITS( 1 );
                } while ( MAX_CODE < code );
            }

            /* if the code is a literal, stuff it into the buffer          */
            if ( code <= MAX_LIT ) {
                *cur++ = code;
                crc = CRC_BYTE( crc, code );
                if ( cur == end ) {
                    if ( BlckWritFile(BufFile,cur-BufFile) != cur-BufFile ) {
                        ErrMsg = "cannot write output file";
                        return 0;
                    }
                    cur = BufFile;
                }
            }

            /* otherwise compute match length and offset and copy          */
            else {
                len = code - (MAX_LIT+1) + MIN_LEN;

                /* try to decodes the log_2 of the offset the fast way     */
                log = TabLog[ PEEK_BITS( 8 ) ];
                /* if this log_2 needs more than 8 bits look in the tree   */
                if ( log <= MAX_LOG ) {
                    FLSH_BITS( LenLog[log] );
                }
                else {
                    FLSH_BITS( 8 );
                    do {
                        if ( PEEK_BITS( 1 ) )  log = TreeRight[log];
                        else                   log = TreeLeft [log];
                        FLSH_BITS( 1 );
                    } while ( MAX_LOG < log );
                }

                /* compute the offset                                      */
                if ( log == 0 ) {
                    off = 0;
                }
                else {
                    off = ((unsigned)1 << (log-1)) + PEEK_BITS( log-1 );
                    FLSH_BITS( log-1 );
                }

                /* copy the match (this accounts for ~ 50% of the time)    */
                pos = BufFile + (((cur-BufFile) - off - 1) & (MAX_OFF - 1));
                if ( cur < end-len && pos < end-len ) {
                    stp = cur + len;
                    do {
                        code = *pos++;
                        crc = CRC_BYTE( crc, code );
                        *cur++ = code;
                    } while ( cur < stp );
                }
                else {
                    while ( 0 < len-- ) {
                        code = *pos++;
                        crc = CRC_BYTE( crc, code );
                        *cur++ = code;
                        if ( pos == end ) {
                            pos = BufFile;
                        }
                        if ( cur == end ) {
                            if ( BlckWritFile(BufFile,cur-BufFile)
                                 != cur-BufFile ) {
                                ErrMsg = "cannot write output file";
                                return 0;
                            }
                            cur = BufFile;
                        }
                    }
                }

            }

        }

        cnt = PEEK_BITS( 16 );  FLSH_BITS( 16 );
    }

    /* write out the rest of the buffer                                    */
    if ( BlckWritFile(BufFile,cur-BufFile) != cur-BufFile ) {
        ErrMsg = "cannot write output file";
        return 0;
    }

    /* indicate success                                                    */
    Crc = crc;
    return 1;
}


/****************************************************************************
**
*F  ListArch(<ver>,<arc>,<filec>,<files>) . . list the members of the archive
**
**  'ListArch'  lists the members  of the  archive with  the name  <arc> that
**  match one  of the file name  patterns '<files>[0] .. <files>[<filec>-1]'.
**  If <ver> is 1, comments are also printed.
*/
unsigned long   BeginMonth [12] = {
   0,    31,   59,   90,  120,  151,  181,  212,  243,  273,  304,  334
};

char            NameMonth [12] [4] = {
"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"
};

int             ListArch ( ver, arc, filec, files )
    unsigned long       ver;
    char *              arc;
    unsigned long       filec;
    char *              files [];
{
    char                arczoo [256];   /* <arc> with '.zoo' tacked on     */
    int                 chr;            /* character from comment          */
    unsigned long       i;              /* loop variable                   */

    /* try to open the archive under various names                         */
    strcpy(arczoo,arc);  strcat(arczoo,".zoo");
    if ( OpenReadArch(arc) ) {
        if ( ! DescReadArch() ) {
            ClosReadArch();
            if ( ! OpenReadArch(arczoo) || ! DescReadArch() ) {
                printf("unzoo: found bad description in archive '%s'\n",arc);
                return 0;
            }
        }
    }
    else if ( OpenReadArch(arczoo) ) {
        if ( ! DescReadArch() ) {
            printf("unzoo: found bad description in archive '%s'\n",arczoo);
            return 0;
        }
    }
    else {
        printf("unzoo: could not open archive '%s'\n",arc);
        return 0;
    }

    /* if present, print the archive comment                               */
    if ( ver && Descript.sizcmt != 0 ) {
        if ( ! GotoReadArch( Descript.poscmt ) ) {
            printf("unzoo: cannot find comment in archive '%s'\n",arc);
            return 0;
        }
        chr = '\n';
        for ( i = 0; i < Descript.sizcmt; i++ ) {
            if ( chr == '\n' )  printf("# ");
            chr = ByteReadArch();
            if ( chr == '\012' )  chr = '\n';
            printf("%c",chr);
        }
        if ( chr != '\n' )  printf("\n");
        fflush( stdout );
    }

    /* print the header                                                    */
    printf("Length    CF  Size Now  Date      Time    \n");
    printf("--------  --- --------  --------- --------\n");
    fflush( stdout );

    /* loop over the members of the archive                                */
    Entry.posnxt = Descript.posent;
    while ( 1 ) {

        /* read the directory entry for the next member                    */
        if ( ! GotoReadArch( Entry.posnxt ) || ! EntrReadArch() ) {
            printf("unzoo: found bad directory entry in archive '%s'\n",arc);
            return 0;
        }
        if ( ! Entry.posnxt )  break;

        /* skip members we don't care about                                */
        if ( Entry.delete == 1 )
            continue;
        if ( filec == 0 && ! IsMatchName( "*", Entry.patw ) )
            continue;
        for ( i = 0; i < filec; i++ )
            if ( IsMatchName( files[i], Entry.patv )
              || IsMatchName( files[i], Entry.patw ) )
                break;
        if ( filec != 0 && i == filec )
            continue;

        /* print the information about the member                          */
        printf("%8lu %3lu%% %8lu  %2lu %3s %02lu %02lu:%02lu:%02lu   %s\n",
               Entry.sizorg,
               (100*(Entry.sizorg-Entry.siznow)+Entry.sizorg/2)
               / (Entry.sizorg != 0 ? Entry.sizorg : 1),
               Entry.siznow,
               Entry.day, NameMonth[Entry.month], Entry.year % 100,
               Entry.hour, Entry.min, Entry.sec,
               (ver ? Entry.patv : Entry.patw) );
        fflush( stdout );

        /* update the counts for the whole archive                         */
        Descript.sizorg += Entry.sizorg;
        Descript.siznow += Entry.siznow;
        Descript.number += 1;

        /* if present print the file comment                               */
        if ( ver && Entry.sizcmt != 0 ) {
            if ( ! GotoReadArch( Entry.poscmt ) ) {
                printf("unzoo: cannot find comment in archive '%s'\n",arc);
                return 0;
            }
            chr = '\n';
            for ( i = 0; i < Entry.sizcmt; i++ ) {
                if ( chr == '\n' )  printf("# ");
                chr = ByteReadArch();
                if ( chr == '\012' )  chr = '\n';
                printf("%c",chr);
            }
            if ( chr != '\n' )  printf("\n");
        }
        fflush( stdout );

    }

    /* print the footer                                                    */
    printf("--------  --- --------  --------- --------\n");
    printf("%8lu %3lu%% %8lu  %4lu files\n",
           Descript.sizorg,
           (100*(Descript.sizorg-Descript.siznow)+Descript.sizorg/2)
           / (Descript.sizorg != 0 ? Descript.sizorg : 1),
           Descript.siznow,
           Descript.number );
    fflush( stdout );

    /* close the archive file                                              */
    if ( ! ClosReadArch() ) {
        printf("unzoo: could not close archive '%s'\n",arc);
        return 0;
    }

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  ExtrArch(<bim>,<out>,<ovr>,<pre>,<arc>,<filec>,<files>) . extract members
**
**  'ExtrArch' extracts the members  of the archive with  the name <arc> that
**  match one  of the file name  patterns '<files>[0] .. <files>[<filec>-1]'.
**  If <bim> is 0, members with comments starting with '!TEXT!' are extracted
**  as text files and the other members are extracted as  binary files; if it
**  is 1,  all members are extracted  as text files; if  it is 2, all members
**  are  extracted as binary  files. If <out>  is 0, no members are extracted
**  and only tested  for integrity; if it  is 1, the  members are printed  to
**  stdout, i.e., to the screen.  and if it  is 2, the members are extracted.
**  If <ovr> is 0, members will not overwrite  existing files; otherwise they
**  will.  <pre> is a prefix that is prepended to all path names.
*/
int             ExtrArch ( bim, out, ovr, pre, arc, filec, files )
    unsigned long       bim;
    unsigned long       out;
    unsigned long       ovr;
    char *              pre;
    char *              arc;
    unsigned long       filec;
    char *              files [];
{
    char                arczoo [256];   /* <arc> with '.zoo' tacked on     */
    char                ans [256];      /* to read the answer              */
    char                patl [1024];    /* local name with prefix          */
    unsigned long       bin;            /* extraction mode text/binary     */
    unsigned long       res;            /* status of decoding              */
    unsigned long       secs;           /* seconds since 70/01/01 00:00:00 */
    unsigned long       i;              /* loop variable                   */

    /* try to open the archive under various names                         */
    strcpy(arczoo,arc);  strcat(arczoo,".zoo");
    if ( OpenReadArch(arc) ) {
        if ( ! DescReadArch() ) {
            ClosReadArch();
            if ( ! OpenReadArch(arczoo) || ! DescReadArch() ) {
                printf("unzoo: found bad description in archive '%s'\n",arc);
                return 0;
            }
        }
    }
    else if ( OpenReadArch(arczoo) ) {
        if ( ! DescReadArch() ) {
            printf("unzoo: found bad description in archive '%s'\n",arczoo);
            return 0;
        }
    }
    else {
        printf("unzoo: could not open archive '%s'\n",arc);
        return 0;
    }

    /* test if the archive has a comment starting with '!TEXT!'            */
    if ( bim == 0
      && 6 <= Descript.sizcmt  && GotoReadArch( Descript.poscmt )
      && ByteReadArch() == '!' && ByteReadArch() == 'T'
      && ByteReadArch() == 'E' && ByteReadArch() == 'X'
      && ByteReadArch() == 'T' && ByteReadArch() == '!' )
        bim = 1;

    /* test if the archive has a comment starting with '!MACBINARY!'       */
#ifdef  SYS_IS_MAC_BOTH
    else if ( bim == 0
      && 11 <= Descript.sizcmt && GotoReadArch( Descript.poscmt )
      && ByteReadArch() == '!' && ByteReadArch() == 'M'
      && ByteReadArch() == 'A' && ByteReadArch() == 'C'
      && ByteReadArch() == 'B' && ByteReadArch() == 'I'
      && ByteReadArch() == 'N' && ByteReadArch() == 'A'
      && ByteReadArch() == 'R' && ByteReadArch() == 'Y'
      && ByteReadArch() == '!' )
        bim = 3;
#endif

    /* loop over the members of the archive                                */
    Entry.posnxt = Descript.posent;
    while ( 1 ) {

        /* read the directory entry for the next member                    */
        if ( ! GotoReadArch( Entry.posnxt ) || ! EntrReadArch() ) {
            printf("unzoo: found bad directory entry in archive '%s'\n",arc);
            return 0;
        }
        if ( ! Entry.posnxt )  break;

        /* skip members we don't care about                                */
        if ( Entry.delete == 1 )
            continue;
        if ( filec == 0 && ! IsMatchName( "*", Entry.patw ) )
            continue;
        for ( i = 0; i < filec; i++ )
            if ( IsMatchName( files[i], Entry.patv )
              || IsMatchName( files[i], Entry.patw ) )
                break;
        if ( filec != 0 && i == filec )
            continue;

        /* check that we can decode this file                              */
        if ( (2 < Entry.method) || (2 < Entry.majver)
          || (2 == Entry.majver && 1 < Entry.minver) ) {
            printf("unzoo: unknown method, you need a later version\n");
            continue;
        }

        /* check that such a file does not already exist                   */
        strcpy( patl, pre );  strcat( patl, Entry.patl );
        if ( out == 2 && ovr == 0 && OpenReadFile(patl,0L) ) {
            ClosReadFile();
            do {
                printf("'%s' exists, overwrite it? (Yes/No/All/Ren): ",patl);
                fflush( stdout );
                if ( fgets( ans, sizeof(ans), stdin ) == (char*)0 )
                    return 0;
            } while ( *ans!='y' && *ans!='n' && *ans!='a' && *ans!='r'
                   && *ans!='Y' && *ans!='N' && *ans!='A' && *ans!='R' );
            if      ( *ans == 'n' || *ans == 'N' ) {
                continue;
            }
            else if ( *ans == 'a' || *ans == 'A' ) {
                ovr = 1;
            }
            else if ( *ans == 'r' || *ans == 'R' ) {
                do {
                    printf("enter a new local path name: ");
                    fflush( stdout );
                    if ( fgets( patl, sizeof(patl), stdin ) == (char*)0 )
                        return 0;
                    for ( i = 0; patl[i] != '\0' && patl[i] != '\n'; i++ ) ;
                    patl[i] = '\0';
                } while ( OpenReadFile(patl,0L) && ClosReadFile() );
            }
        }

        /* decide whether or not we want to open the file binary           */
        if ( bim == 0
          && 6 <= Entry.sizcmt     && GotoReadArch( Entry.poscmt )
          && ByteReadArch() == '!' && ByteReadArch() == 'T'
          && ByteReadArch() == 'E' && ByteReadArch() == 'X'
          && ByteReadArch() == 'T' && ByteReadArch() == '!' )
            bin = 1;
#ifdef  SYS_IS_MAC_BOTH
        else if ( bim == 0
          && 11 <= Entry.sizcmt    && GotoReadArch( Entry.poscmt )
          && ByteReadArch() == '!' && ByteReadArch() == 'M'
          && ByteReadArch() == 'A' && ByteReadArch() == 'C'
          && ByteReadArch() == 'B' && ByteReadArch() == 'I'
          && ByteReadArch() == 'N' && ByteReadArch() == 'A'
          && ByteReadArch() == 'R' && ByteReadArch() == 'Y'
          && ByteReadArch() == '!' )
            bin = 3;
#endif
        else if ( bim == 0 )
            bin = 2;
        else
            bin = bim;

        /* open the file for creation                                      */
        if ( out == 2 && ! OpenWritFile(patl,bin)
#ifdef  MAKE_DIRE
          && (! MakeDirs(pre,Entry.diru) || ! OpenWritFile(patl,bin))
#endif
            ) {
            printf("unzoo: '%s' cannot be created, ",patl);
#ifndef MAKE_DIRE
            if ( Entry.dirl[0] != '\0' )
                printf("check that the directory '%s' exists\n",Entry.dirl);
            else
                printf("check the permissions\n");
#else
            printf("check the permissions\n");
#endif
            continue;
        }

        /* or ``open'' stdout for printing                                 */
        if ( out == 1 )
            OpenWritFile( (char*)0, 0L );

        /* decode the file                                                 */
        if ( ! GotoReadArch( Entry.posdat ) ) {
            printf("unzoo: cannot find data in archive '%s'\n",arc);
            return 0;
        }
        res = 0;
        ErrMsg = "this should not happen";
        if ( out == 0 || out == 2 )
            printf("%s \t-- ",Entry.patl);
        else
            printf("********\n%s\n********\n",Entry.patl);
        fflush( stdout );
        if ( Entry.method == 0 )  res = DecodeCopy( Entry.siznow );
        if ( Entry.method == 1 )  res = DecodeLzd();
        if ( Entry.method == 2 )  res = DecodeLzh();

        /* check that everything went ok                                   */
        if      ( res == 0             )  printf("error, %s\n",ErrMsg);
        else if ( Crc != Entry.crcdat  )  printf("error, CRC failed\n");
        else if ( out == 2 && bin == 1 )  printf("extracted as text\n");
        else if ( out == 2 && bin == 2 )  printf("extracted as binary\n");
#ifdef  SYS_IS_MAC_BOTH
        else if ( out == 2 && bin == 3 )  printf("extracted as MacBinary\n");
#endif
        else if ( out == 0             )  printf("tested\n");
        fflush( stdout );

        /* close the file after extraction                                 */
        if ( out == 1 || out == 2 )
            ClosWritFile();

        /* set the file time, evt. correct for timezone of packing system  */
        secs = 24*60*60L*(365*(Entry.year - 70)
                         + BeginMonth[Entry.month]
                         + Entry.day - 1
                         + (Entry.year -  69) / 4
                         + (Entry.year %   4 ==   0 && 1 < Entry.month)
                         - (Entry.year + 299) / 400
                         - (Entry.year % 400 == 100 && 1 < Entry.month))
                 +60*60L*Entry.hour + 60L*Entry.min + Entry.sec;
        if      ( Entry.timzon < 127 )  secs += 15*60*(Entry.timzon      );
        else if ( 127 < Entry.timzon )  secs += 15*60*(Entry.timzon - 256);
        if ( out == 2 ) {
            if ( ! SETF_TIME( patl, secs ) )
                printf("unzoo: '%s' could not set the times\n",patl);
        }

        /* set the file permissions                                        */
        if ( out == 2 && (Entry.permis >> 22) == 1 ) {
            if ( ! SETF_PERM( patl, Entry.permis ) )
                printf("unzoo: '%s' could not set the permissions\n",patl);
        }

    }

    /* close the archive file                                              */
    if ( ! ClosReadArch() ) {
        printf("unzoo: could not close the archive '%s'\n",arc);
        return 0;
    }

    /* indicate success                                                    */
    return 1;
}

/****************************************************************************
**
*F  Banner()  . . . . . . . . . . . . . . . . . . . . . . . . .  print banner
**
**  'Banner' prints version information
*/
int			Banner ()
{
    printf("unzoo -- a zoo archive extractor by Martin Schoenert\n");
#ifndef SYS_IS_MAC_MWC
    printf("  ($Id: unzoo.c,v 4.9 2006/01/02 10:08:53 gap Exp $)\n");
#endif
    printf("  based on 'booz' version 2.0 by Rahul Dhesi\n");
#ifdef SYS_IS_MAC_MWC
    printf("  Macintosh version "MACUNZOOSHORTVERS" by Burkhard Hofling.\n");
#endif
}


/****************************************************************************
**
*F  HelpArch()  . . . . . . . . . . . . . . . . . . . . . . . print some help
**
**  'HelpArch' prints some help about 'unzoo'.
*/
int             HelpArch ()
{
    printf("\n");
 #ifdef SYS_IS_MAC_MWC
	printf("Command line syntax: \n");
#else
    printf("unzoo ");
#endif
    printf("[-l] [-v] <archive>[.zoo] [<file>..]\n");
    printf("  list the members of the archive\n");
    printf("  -v:  list also the generation numbers and the comments\n");
    printf("  <file>: list only files matching at least one pattern,\n");
    printf("          '?' matches any char, '*' matches any string.\n");
    printf("\n");
#ifdef SYS_IS_MAC_MWC
	printf("or: \n");
#else
    printf("unzoo ");
#endif
    printf("-x [-abnpo] [-j <prefix>] <archive>[.zoo] [<file>..]\n");
    printf("  extract the members of the archive\n");
    printf("  -a:  extract all members as text files ");
    printf("(not only those with !TEXT! comments)\n");
    printf("  -b:  extract all members as binary files ");
    printf("(even those with !TEXT! comments)\n");
    printf("  -n:  extract no members, only test the integrity\n");
    printf("  -p:  extract to stdout\n");
    printf("  -o:  extract over existing files\n");
    printf("  -j:  extract to '<prefix><membername>'\n");
    printf("  <file>: extract only files matching at least one pattern,\n");
    printf("          '?' matches any char, '*' matches any string.\n");
    return 1;
}


/****************************************************************************
**
*F  main(<argc>,<argv>) . . . . . . . . . . . . . . . . . . . .  main program
**
**  'main' is the main program, it decodes the arguments  and then  calls the
**  appropriate function.
*/
int             main ( argc, argv )
    int                 argc;
    char *              argv [];
{
    unsigned long       res;            /* result of command               */
    unsigned long       cmd;            /* command help/list/extract       */
    unsigned long       ver;            /* list verbose option             */
    unsigned long       bim;            /* extraction mode option          */
    unsigned long       out;            /* output destination option       */
    unsigned long       ovr;            /* overwrite file option           */
    char *              pre;            /* prefix to prepend to path names */
    char                argl [256];     /* interactive command line        */
    int                 argd;           /* interactive command count       */
    char *              argw [256];     /* interactive command vector      */
    char *              p;              /* loop variable                   */
    char                match1;         /* for interactive command line 
                                                                   parsing */
    char                match2;         /* for interactive command line 
                                                                   parsing */


#ifdef SYS_IS_MAC_MWC
    InitMacUnzoo ();
	res = Banner ();
#endif
	
	
    /* repeat until the user enters an empty line                          */
    InitCrc();
    IsSpec['\0'] = 1;  IsSpec[';'] = 1;
    argd = 1;
    do {

        /* scan the command line arguments                                 */
        cmd = 1;  ver = 0;  bim = 0;  out = 2;  ovr = 0;
        pre = "";
        while ( 1 < argc && argv[1][0] == '-' ) {
            if ( argv[1][2] != '\0' )  cmd = 0;
            switch ( argv[1][1] ) {
            case 'l': case 'L': if ( cmd != 0 )  cmd = 1;            break;
            case 'v': case 'V': if ( cmd != 1 )  cmd = 0;  ver = 1;  break;
            case 'x': case 'X': if ( cmd != 0 )  cmd = 2;            break;
            case 'a': case 'A': if ( cmd != 2 )  cmd = 0;  bim = 1;  break;
            case 'b': case 'B': if ( cmd != 2 )  cmd = 0;  bim = 2;  break;
            case 'n': case 'N': if ( cmd != 2 )  cmd = 0;  out = 0;  break;
            case 'p': case 'P': if ( cmd != 2 )  cmd = 0;  out = 1;  break;
            case 'o': case 'O': if ( cmd != 2 )  cmd = 0;  ovr = 1;  break;
            case 'j': case 'J': if ( argc == 2 ) { cmd = 0;  break; }
                                pre = argv[2];  argc--;  argv++;
                                break;
            default:            cmd = 0;  break;
            }
            argc--;  argv++;
        }

        /* execute the command or print help                               */
#ifdef SYS_IS_MAC_MWC
        IsActive = 1;
#endif
        
        if      ( cmd == 1 && 1 < argc )
            res = ListArch( ver, argv[1],
                            (unsigned long)argc-2, argv+2 );
        else if ( cmd == 2 && 1 < argc )
            res = ExtrArch( bim, out, ovr, pre, argv[1],
                            (unsigned long)argc-2, argv+2 );
        else {
#ifdef SYS_IS_MAC_MWC
			if (argd > 1 || DragAndDropEnabled == 0)
				res = HelpArch();
#else
			res = Banner();
            res = HelpArch();
#endif
		}
		
#ifdef SYS_IS_MAC_MWC
        IsActive = 0;
#endif
        /* in interactive mode read another line                           */
        if ( 1 < argd || argc <= 1 ) {

            /* read a command line                                         */
#ifdef SYS_IS_MAC_MWC
			if (DragAndDropEnabled) {
            	printf("\nDrop the zoo file onto the unzoo application icon to uncompress it,\n");
            	printf("or enter a command line (-h for help). An empty line quits unzoo.\n\n");
            } else {
            	printf("\nEnter a command line (-h for help).  An empty line quits unzoo.\n\n");
            }
#else
            printf("\nEnter a command line or an empty line to quit:\n");
#endif
            fflush( stdout );
            if ( fgets( argl, sizeof(argl), stdin ) == (char*)0 )  break;

#ifdef SYS_IS_MAC_MWC
			if ( *argl == '\n' && argl[1]=='\0') break;
#endif 

           /* parse the command line into argc                            */
            argd = 1;
            p = argl;
            while ( *p==' ' || *p=='\t' || *p=='\n' )  *p++ = '\0';
            	
            while ( *p != '\0' ) {
            	if (*p == '\'' || *p == '\"') {
            		match1 = *p++;
            		match2 = match1;
            	} else {
            		match1 = ' ';
            		match2 = '\t';
            	}
                argw[argd++] = p;
                while ( *p!=match1 && *p!=match2 && *p!='\n' && *p!='\0' )  p++;
                if (*p==match1 || *p==match2)  *p++ = '\0';
                while ( *p==' ' || *p=='\t' || *p=='\n' )  *p++ = '\0';
            }
            argc = argd;  argv = argw;

        }

    } while ( 1 < argd );

    /* just to please lint                                                 */
    return ! res;
}



