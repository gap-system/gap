/****************************************************************************
**
*W  system.c                    GAP source                       Frank Celler
*W                                                         & Martin Schoenert
*W                                                         & Dave Bayer (MAC)
*W                                                  & Harald Boegeholz (OS/2)
*W                                                         & Paul Doyle (VMS)
*W                                                  & Burkhard Hoefling (MAC)
*W                                                    & Steve Linton (MS/DOS)
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  The  files   "system.c" and  "sysfiles.c"  contains all  operating system
**  dependent  functions.  This file contains  all system dependent functions
**  except file and stream operations, which are implemented in "sysfiles.c".
**  The following labels determine which operating system is actually used.
**
**  SYS_IS_BSD
**      For  Berkeley UNIX systems, such as  4.2 BSD,  4.3 BSD,  free 386BSD,
**      and DEC's Ultrix.
**
**  SYS_IS_MAC_MPW
**      For Apple's Macintosh with the Mac Programmers Workshop compiler.
**
**  SYS_IS_MAC_SYC
**      For  Apple's  Macintosh  with the  Symantec C++ 7.0 (or  Think C 6.0)
**      compiler.
**
**  SYS_IS_MACH
**      For Mach derived systems, such as NeXT's NextStep.
**
**  SYS_IS_USG
**      For System V UNIX systems, such as SUN's SunOS 4.0, Hewlett Packard's
**      HP-UX, Masscomp's RTU, free Linux, and MIPS Risc/OS.
**
**  SYS_IS_OS2_EMX
**      For OS/2 2.x and DOS with the EMX port of the GNU C compiler.
**
**  SYS_IS_MSDOS_DJGPP
**      For MS-DOS with Delories port of the GNU C compiler.
**
**  SYS_IS_TOS_GCC2
**      For Atari's TOS with the port of the GNU C compiler.
**
**  SYS_IS_VMS
**      For DEC's VMS 5.0 or later with the VAX C compiler 3.0 or later.
**
**  The following must be set on 64 bit systems:
**
**  SYS_IS_64_BIT
**      For systems having 64 bit pointers.
**
**  The following labels determine if and how dynamic loading is supported.
**
**  SYS_HAS_DL_LIBRARY
**      For systems supporting 'dlopen' and 'dlsym'.
**
**  Some system functions are broken, use the following to fix this:
**
**  SYS_HAS_BROKEN_STRNCAT
**      Use  this if   your 'strncat'  is   broken.  At least  in  SCO ODT2.0
**      (SVR3.2) 'strncat' has problems if the len is a multiple of 4.
**
**  Not all operating system support the following concepts:
**
**  SYS_HAS_SIGNALS
**      Use this if your system supports signal.   If not set the system will
**      using polling to check for <ctrl>-C.
**
**  SYS_HAS_DL_LIBRARY
**      Use this if your system supports dynamic loading via 'dlopen'.
**
**  SYS_HAS_RLD_LIBRARY
**      Use this if your system supports dynamic loading via 'rld_load'.
**
**  Not all operating system have "the" standard include files:
**
**  SYS_TERMIO_H
**      Use this if your system has no include file "termio.h".
**
**  SYS_SGTTY_H
**      Use this if your system has no include file "sgtty.h".
**
**  SYS_SIGNAL_H
**      Use this if your system has no include file "signal.h".
**
**  SYS_STDIO_H
**      Use this if your system has no include file "stdio.h".
**
**  SYS_STDLIB_H
**      Use this if your system has no include file "stdlib.h".
**
**  SYS_UNISTD_H
**      Use this if your system has no include file "unistd.h".
**
**  Also the file contains prototypes for all the system calls and/or library
**  function used as defined in  ``Harbison & Steele, A C Reference Manual''.
**
**  If there is  a prototype in an  include file and it  does not  agree with
**  this one, then the compiler will signal an  error or warning, and you can
**  manually check whether the incompatibility is critical or quite harmless.
**  If there is a prototype in  an include file and it  agrees with this one,
**  then the compiler will be silent.  If there is no prototype in an include
**  file, the compiler cannot check, but then the prototype does no harm.
**
**  Unfortunately  there can be some incompatibilities with the prototypes in
**  the  include files.  To overcome this  difficulties  it  is  possible  to
**  change  or undefine  the prototypes  with  the  following  symbols.  They
**  should be added to the 'Makefile' if neccessary.
**
**  SYS_HAS_ANSI=<ansi>
**      Some functions have different prototypes in  ANSI and  traditional C.
**      For compilers that are  ANSI  the default uses the  ANSI  prototypes,
**      and you use the  traditional prototypes by defining 'SYS_HAS_ANSI=0'.
**      For  non ANSI compilers the default uses the  traditional prototypes,
**      and you can use the ANSI prototypes by defining 'SYS_HAS_ANSI=1'.
**
**  SYS_HAS_CALLOC_PROTO
**      Use this to undefine the prototype for 'calloc'.
**
**  SYS_HAS_CONST=<const_q>
**      Some  functions do  not modifiy  some of  their  arguments,  and have
**      thus  'const' qualifiers  for those  arguments  in their  prototypes.
**      For compilers that are  ANSI the default uses the  const  qualifiers,
**      and you can remove the const qualifiers by defining 'SYS_HAS_CONST='.
**      For compilers that are  not ANSI  the default does not use the  const
**      qualifiers and you can use them by defining 'SYS_HAS_CONST=const'.
**
**  SYS_HAS_STDIO_PROTO
**      Use this to undefine the prototypes for 'fopen', 'fclose',  'setbuf',
**      'fgets', and 'fputs'.
**
**  SYS_HAS_READ_PROTO
**      Use this to undefine the prototypes for 'read' and 'write'.
**
**  SYS_HAS_EXEC_PROTO
**      Use this to undefine the prototypes for 'execve'.
**
**  SYS_HAS_STRING_PROTO
**      Use this to undefine the  prototypes  for  'strncat',  'strcmp',  and
**      'strlen'.
**
**  SYS_HAS_IOCTL_PROTO
**      Use this to undefine the prototype for 'ioctl'.
**
**  SYS_HAS_SIG_T=<sig_t>
**      Use this to define the type of the value returned by signal handlers.
**      This should be either 'void' (default, ANSI C) or 'int' (older UNIX).
**
**  SYS_HAS_SIGNAL_PROTO
**      Use this to undefine  the  prototypes  for  'signal',  'getpid',  and
**      'kill'.
**
**  SYS_HAS_TIME_PROTO
**      Use this to undefine the prototypes for 'time', 'times', and
**      'getrusage'.
**
**  SYS_HAS_MALLOC_PROTO
**      Use this to undefine the prototypes for 'malloc' and 'free'.
**
**  SYS_HAS_MISC_PROTO
**      Use this to undefine the prototypes for 'exit',  'system',  'tmpnam',
**      'sbrk', 'getenv', 'atoi', 'isatty', and 'ttyname'.  */
#define INCLUDE_DECLARATION_PART
#include        "system.h"              /* system dependent part           */
#undef  INCLUDE_DECLARATION_PART

SYS_CONST char * Revision_system_c =
   "@(#)$Id$";

#include        "sysfiles.h"            /* file input/output               */


#ifndef SYS_STDIO_H                     /* standard input/output functions */
# include <stdio.h>
# define SYS_STDIO_H
#endif


#ifndef SYS_UNISTD_H                    /* definition of 'R_OK'            */
# include <unistd.h>
# define SYS_UNISTD_H
#endif


#ifndef SYS_STDLIB_H                    /* ANSI standard functions         */
# if SYS_ANSI
#  include      <stdlib.h>
# endif
# define SYS_STDLIB_H
#endif


#ifndef SYS_HAS_STDIO_PROTO             /* ANSI/TRAD decl. from H&S 15     */
extern FILE * fopen ( SYS_CONST char *, SYS_CONST char * );
extern int    fclose ( FILE * );
extern void   setbuf ( FILE *, char * );
extern char * fgets ( char *, int, FILE * );
extern int    fputs ( SYS_CONST char *, FILE * );
#endif


#ifndef SYS_SIGNAL_H                    /* signal handling functions       */
# include       <signal.h>
# ifdef SYS_HAS_SIG_T
#  define SYS_SIG_T     SYS_HAS_SIG_T
# else
#  define SYS_SIG_T     void
# endif
# define SYS_SIGNAL_H
typedef SYS_SIG_T       sig_handler_t ( int );
#endif


#ifndef SYS_HAS_SIGNAL_PROTO            /* ANSI/TRAD decl. from H&S 19.6   */
extern  sig_handler_t * signal ( int, sig_handler_t * );
extern  int             getpid ( void );
extern  int             kill ( int, int );
#endif


#ifdef __MWERKS__
# define SYS_IS_MAC_MPW             1
# define SYS_HAS_CALLOC_PROTO       1
#endif


/****************************************************************************
**

*V  SyFlags . . . . . . . . . . . . . . . . . . . . flags used when compiling
**
**  'SyFlags' is the name of the target for which GAP was compiled.
**
**  It is
**
**      [bsd|mach|usg|os2|msdos|tos|vms|mac] [gcc|emx|djgpp|mpw|syc] [ansi]
**
**  It is used in 'InitGap' for the 'VERSYS' variable.
*/
SYS_CONST Char SyFlags [] = {

#ifdef SYS_IS_BSD
    'b', 's', 'd',
#endif

#ifdef SYS_IS_MACH
    'm', 'a', 'c', 'h',
#endif

#ifdef SYS_IS_USG
    'u', 's', 'g',
#endif

#ifdef SYS_IS_OS2_EMX
    'o', 's', '2', ' ', 'e', 'm', 'x',
#endif

#ifdef SYS_IS_MSDOS_DJGPP
    'm', 's', 'd', 'o', 's', ' ', 'd', 'j', 'g', 'p', 'p',
#endif

#ifdef SYS_IS_TOS_GCC2
    't', 'o', 's', ' ', 'g', 'c', 'c', '2',
#endif

#ifdef SYS_IS_VMS
    'v', 'm', 's',
#endif

#ifdef SYS_IS_MAC_MPW
    'm', 'a', 'c', ' ', 'm', 'p', 'w',
#endif

#ifdef SYS_IS_MAC_SYC
    'm', 'a', 'c', ' ', 's', 'y', 'c',
#endif

#if __GNUC__
    ' ', 'g', 'c', 'c',
#endif
#if SYS_ANSI
    ' ', 'a', 'n', 's', 'i',
#endif

#ifdef SYS_HAS_BROKEN_STRNCAT
    ' ', 's', 't', 'r', 'n', 'c', 'a', 't',
#endif

    '\0' };


/****************************************************************************
**

*F * * * * * * * * * * * command line settable options  * * * * * * * * * * *
*/

/****************************************************************************
**

*V  SyStackAlign  . . . . . . . . . . . . . . . . . .  alignment of the stack
**
**  'SyStackAlign' is  the  alignment  of items on the stack.   It  must be a
**  divisor of  'sizof(Bag)'.  The  addresses of all identifiers on the stack
**  must be  divisable by 'SyStackAlign'.  So if it  is 1, identifiers may be
**  anywhere on the stack, and if it is  'sizeof(Bag)',  identifiers may only
**  be  at addresses  divisible by  'sizeof(Bag)'.  This value is initialized
**  from a macro passed from the makefile, because it is machine dependent.
**
**  This value is passed to 'InitBags'.
*/
#ifdef  SYS_HAS_STACK_ALIGN
#define SYS_STACK_ALIGN         SYS_HAS_STACK_ALIGN
#endif

#ifndef SYS_HAS_STACK_ALIGN
#define SYS_STACK_ALIGN         sizeof(UInt *)
#endif

UInt SyStackAlign = SYS_STACK_ALIGN;


/****************************************************************************
**
*V  SyArchitecture  . . . . . . . . . . . . . . . .  name of the architecture
*/
#ifndef SYS_ARCH
  SYS_CONST Char * SyArchitecture = "unknown";
#else
  SYS_CONST Char * SyArchitecture = SYS_ARCH;
#endif


/****************************************************************************
**
*V  SyBanner  . . . . . . . . . . . . . . . . . . . . . . . . surpress banner
**
**  'SyBanner' determines whether GAP should print the banner.
**
**  Per default it  is true,  i.e.,  GAP prints the  nice  banner.  It can be
**  changed by the '-b' option to have GAP surpress the banner.
**
**  It is copied into the GAP variable 'BANNER', which  is used  in 'init.g'.
**
**  Put in this package because the command line processing takes place here.
*/
UInt SyBanner = 1;


/****************************************************************************
**
*V  SyCTRD  . . . . . . . . . . . . . . . . . . .  true if '<ctr>-D' is <eof>
*/
UInt SyCTRD = 1;             


/****************************************************************************
**
*V  SyCacheSize . . . . . . . . . . . . . . . . . . . . . . size of the cache
**
**  'SyCacheSize' is the size of the data cache.
**
**  This is per  default 0, which means that  there is no usuable data cache.
**  It is usually changed with the '-c' option in the script that starts GAP.
**
**  This value is passed to 'InitBags'.
**
**  Put in this package because the command line processing takes place here.
*/
UInt SyCacheSize = 0;


/****************************************************************************
**
*V  SyCheckForCompletion  . . . . . . . . . . . .  check for completion files
*/
Int SyCheckForCompletion = 1;


/****************************************************************************
**
*V  SyCheckCompletionCrcComp  . . .  check crc while reading completion files
*/
Int SyCheckCompletionCrcComp = 0;


/****************************************************************************
**
*V  SyCheckCompletionCrcRead  . . . . . . .  check crc while completing files
*/
Int SyCheckCompletionCrcRead = 1;


/****************************************************************************
**
*V  SyCompileInput  . . . . . . . . . . . . . . . . . .  from this input file
*/
Char SyCompileInput [256];


/****************************************************************************
**
*V  SyCompileMagic1 . . . . . . . . . . . . . . . . . . and this magic string
*/
Char * SyCompileMagic1;


/****************************************************************************
**
*V  SyCompileName . . . . . . . . . . . . . . . . . . . . . .  with this name
*/
Char SyCompileName [256];


/****************************************************************************
**
*V  SyCompileOutput . . . . . . . . . . . . . . . . . . into this output file
*/
Char SyCompileOutput [256];


/****************************************************************************
**
*V  SyCompilePlease . . . . . . . . . . . . . . .  tell GAP to compile a file
*/
Int SyCompilePlease = 0;


/****************************************************************************
**
*V  SyDebugLoading  . . . . . . . . .  output messages about loading of files
*/
Int SyDebugLoading = 0;


/****************************************************************************
**
*V  SyGapRootPath . . . . . . . . . . . . . . . . . . . . . . . . . root path
**
**  'SyGapRootPath' conatins the names of the directories where the GAP files
**  are located.
**
**  This is  per default the current  directory.  It  is usually changed with
**  the '-l' option in the script that starts GAP.
**
**  Is copied    into  the  GAP   variable  called    'GAPROOT' and  used  by
**  'ReadGapRoot'.  This  is also  used in  'GAPROOT/lib/init.g' to find  the
**  group and table library directories.
**
**  It must end with the pathname seperator, eg. if 'init.g' is the name of a
**  library   file 'strcat( SyGapRootPath,  "lib/init.g" );'  must be a valid
**  filename.  Further neccessary transformation of  the filename are done in
**  'SyOpen'.
**
**  Put in this package because the command line processing takes place here.
*/
Char SyGapRootPath [MAX_GAP_DIRS*256];


/****************************************************************************
**
*V  SyGapRootPaths  . . . . . . . . . . . . . . . . . . . array of root paths
**
**  'SyGapRootPaths' conatins the  names   of the directories where   the GAP
**  files are located, it is derived from 'SyGapRootPath'.
**
**  Put in this package because the command line processing takes place here.
*/
Char SyGapRootPaths [MAX_GAP_DIRS] [256];


/****************************************************************************
**
*V  SyInitfiles[] . . . . . . . . . . .  list of filenames to be read in init
**
**  'SyInitfiles' is a list of file to read upon startup of GAP.
**
**  It contains the 'init.g' file and a user specific init file if it exists.
**  It also contains all names all the files specified on the  command  line.
**
**  This is used in 'InitGap' which tries to read those files  upon  startup.
**
**  Put in this package because the command line processing takes place here.
**
**  For UNIX this list contains 'LIBNAME/init.g' and '$HOME/.gaprc'.
*/
Char SyInitfiles [16] [256];


/****************************************************************************
**
*V  SyLineEdit  . . . . . . . . . . . . . . . . . . . .  support line editing
**
**  0: no line editing
**  1: line editing if terminal
**  2: always line editing (EMACS)
*/
UInt SyLineEdit = 1;


/****************************************************************************
**
*V  SyMsgsFlagBags  . . . . . . . . . . . . . . . . .  enable gasman messages
**
**  'SyMsgsFlagBags' determines whether garabage collections are reported  or
**  not.
**
**  Per default it is false, i.e. Gasman is silent about garbage collections.
**  It can be changed by using the  '-g'  option  on the  GAP  command  line.
**
**  This is used in the function 'SyMsgsBags' below.
**
**  Put in this package because the command line processing takes place here.
*/
UInt SyMsgsFlagBags = 0;


/****************************************************************************
**
*V  SyNrCols  . . . . . . . . . . . . . . . . . .  length of the output lines
**
**  'SyNrCols' is the length of the lines on the standard output  device.
**
**  Per default this is 80 characters which is the usual width of  terminals.
**  It can be changed by the '-x' options for larger terminals  or  printers.
**
**  'Pr' uses this to decide where to insert a <newline> on the output lines.
**  'SyRead' uses it to decide when to start scrolling the echoed input line.
**
**  Put in this package because the command line processing takes place here.
*/
UInt SyNrCols = 80;


/****************************************************************************
**
*V  SyNrRows  . . . . . . . . . . . . . . . . . number of lines on the screen
**
**  'SyNrRows' is the number of lines on the standard output device.
**
**  Per default this is 24, which is the  usual  size  of  terminal  screens.
**  It can be changed with the '-y' option for larger terminals or  printers.
**
**  'SyHelp' uses this to decide where to stop with '-- <space> for more --'.
*/
UInt SyNrRows = 24;


/****************************************************************************
**
*V  SyQuiet . . . . . . . . . . . . . . . . . . . . . . . . . surpress prompt
**
**  'SyQuit' determines whether GAP should print the prompt and  the  banner.
**
**  Per default its false, i.e. GAP prints the prompt and  the  nice  banner.
**  It can be changed by the '-q' option to have GAP operate in silent  mode.
**
**  It is used by the functions in 'gap.c' to surpress printing the  prompts.
**  Is also copied into the GAP variable 'QUIET' which is used  in  'init.g'.
**
**  Put in this package because the command line processing takes place here.
*/
UInt SyQuiet = 0;


/****************************************************************************
**
*V  SyRestoring . . . . . . . . . . . . . . . . . . . . restoring a workspace
**
**  `SyRestoring' determines whether GAP is restoring a workspace or not.  If
**  it is zero no restoring should take place otherwise it holds the filename
**  of a workspace to restore.
**
*/
Char * SyRestoring;


/****************************************************************************
**
*V  SyStorMax . . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorMax' is the maximal size of the workspace allocated by Gasman.
**
**  This is per default 64 MByte,  which is often a  reasonable value.  It is
**  usually changed with the '-o' option in the script that starts GAP.
**
**  This is used in the function 'SyAllocBags'below.
**
**  Put in this package because the command line processing takes place here.
*/
Int SyStorMax = 64 * 1024 * 1024L;


/****************************************************************************
**
*V  SyStorMin . . . . . . . . . . . . . .  default size for initial workspace
**
**  'SyStorMin' is the size of the initial workspace allocated by Gasman.
**
**  This is per default  4 Megabyte,  which  is  often  a  reasonable  value.
**  It is usually changed with the '-m' option in the script that starts GAP.
**
**  This value is used in the function 'SyAllocBags' below.
**
**  Put in this package because the command line processing takes place here.
*/
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_OS2_EMX
Int SyStorMin = 8 * 1024 * 1024;
#endif

#if SYS_MSDOS_DJGPP
Int SyStorMin = 8 * 1024 * 1024;
#endif

#if SYS_TOS_GCC2
Int SyStorMin = 0;
#endif

#if SYS_VMS
Int SyStorMin = 8 * 1024 * 1024;
#endif

#if SYS_MAC_MPW || SYS_MAC_SYC
Int SyStorMin = 0;
#endif


/****************************************************************************
**
*V  SySystemInitFile  . . . . . . . . . . .  name of the system "init.g" file
*/
Char SySystemInitFile [256];


/****************************************************************************
**
*V  SyUseModule . . . . . check for dynamic/static modules in 'READ_GAP_ROOT'
*/
int SyUseModule = 1;


/****************************************************************************
**
*V  SyWindow  . . . . . . . . . . . . . . . .  running under a window handler
**
**  'SyWindow' is 1 if GAP  is running under  a window handler front end such
**  as 'xgap', and 0 otherwise.
**
**  If running under  a window handler front  end, GAP adds various  commands
**  starting with '@' to the output to let 'xgap' know what is going on.
*/
UInt SyWindow = 0;


/****************************************************************************
**
*V  syStackSpace  . . . . . . . . . . . . . . . . . . . amount of stack space
**
**  'syStackSpace' is the amount of stackspace that GAP gets.
**
**  Under TOS and on the  Mac special actions must  be  taken to ensure  that
**  enough space is available.
*/
#if SYS_TOS_GCC2
# define __NO_INLINE__
int _stksize = 64 * 1024;   /* GNU C, amount of stack space    */
static UInt syStackSpace = 64 * 1024;
#endif

#if SYS_MAC_MPW || SYS_MAC_SYC
static UInt syStackSpace = 64 * 1024;
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * time related functions * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  SyStartTime . . . . . . . . . . . . . . . . . . time when GAP was started
*/
UInt SyStartTime;


/****************************************************************************
**
*V  SyStopTime  . . . . . . . . . . . . . . . . . . time when reading started
*/
UInt SyStopTime;


/****************************************************************************
**
*F  SyTime()  . . . . . . . . . . . . . . . return time spent in milliseconds
**
**  'SyTime' returns the number of milliseconds spent by GAP so far.
**
**  Should be as accurate as possible,  because it  is  used  for  profiling.
*/


/****************************************************************************
**
*f  SyTime()  . . . . . . . . . . . . . . . . . . . . . . . .  BSD/Mach/DJGPP
**
**  For Berkeley UNIX the clock ticks in 1/60.  On some (all?) BSD systems we
**  can use 'getrusage', which gives us a much better resolution.
*/
#if SYS_BSD || SYS_MACH || SYS_MSDOS_DJGPP

#ifndef SYS_HAS_NO_GETRUSAGE

#ifndef SYS_RESOURCE_H                  /* definition of 'struct rusage'   */
# include       <sys/time.h>            /* definition of 'struct timeval'  */
# include       <sys/resource.h>
# define SYS_RESOURCE_H
#endif

#ifndef SYS_HAS_TIME_PROTO              /* UNIX decl. from 'man'           */
extern int getrusage ( int, struct rusage * );
#endif

UInt SyTime ( void )
{
    struct rusage       buf;

    if ( getrusage( RUSAGE_SELF, &buf ) ) {
        fputs("gap: panic 'SyTime' cannot get time!\n",stderr);
        SyExit( 1 );
    }
    return buf.ru_utime.tv_sec*1000 + buf.ru_utime.tv_usec/1000 -SyStartTime;
}

#endif

#ifdef SYS_HAS_NO_GETRUSAGE

#ifndef SYS_TIMES_H                     /* time functions                  */
# include       <sys/types.h>
# include       <sys/times.h>
# define SYS_TIMES_H
#endif
#ifndef SYS_HAS_TIME_PROTO              /* UNIX decl. from 'man'           */
extern int times ( struct tms * );
#endif

UInt SyTime ( void )
{
    struct tms          tbuf;

    if ( times( &tbuf ) == -1 ) {
        fputs("gap: panic 'SyTime' cannot get time!\n",stderr);
        SyExit( 1 );
    }
    return 100 * tbuf.tms_utime / (60/10) - SyStartTime;
}

#endif

#endif


/****************************************************************************
**
*f  SyTime()  . . . . . . . . . . . . . . . . . . . . . . . . . . . . USG/OS2
**
**  For UNIX System V and OS/2 the clock ticks in 1/HZ,  this is usually 1/60
**  or 1/100.
*/
#if SYS_USG || SYS_OS2_EMX

#ifndef SYS_TIMES_H                     /* time functions                  */
# include       <sys/param.h>           /* definition of 'HZ'              */
# include       <sys/types.h>
# include       <sys/times.h>
# define SYS_TIMES_H
#endif
#ifndef SYS_HAS_TIME_PROTO              /* UNIX decl. from 'man'           */
extern int times ( struct tms * );
#endif

UInt SyTime ( void )
{
    struct tms          tbuf;

    if ( times( &tbuf ) == -1 ) {
        fputs("gap: panic 'SyTime' cannot get time!\n",stderr);
        SyExit( 1 );
    }
    return 100 * tbuf.tms_utime / (HZ / 10) - SyStartTime;
}

#endif


/****************************************************************************
**
*f  SyTime()  . . . . . . . . . . . . . . . . . . . . . . . . . . . . TOS/VMS
**
**  For TOS and VMS we use the function 'clock' and allow to stop the clock.
*/
#if SYS_TOS_GCC2 || SYS_VMS

#ifndef SYS_TIME_H                      /* time functions                  */
# include       <time.h>
# define SYS_TIME_H
#endif
#ifndef SYS_HAS_TIME_PROTO              /* ANSI/TRAD decl. from H&S 18.2    */
# if SYS_ANSI
extern  clock_t         clock ( void );
# define SYS_CLOCKS     CLOCKS_PER_SEC
# else
extern  long            clock ( void );
#  if SYS_TOS_GCC2
#   define SYS_CLOCKS   200
#  else
#   define SYS_CLOCKS   100
#  endif
# endif
#endif

UInt SyTime ( void )
{
    return 100 * (UInt)clock() / (SYS_CLOCKS/10) - SyStartTime;
}

#endif


/****************************************************************************
**
*f  SyTime()  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . MAC
**
**  For  MAC with MPW we  use the 'TickCount' function  and allow to stop the
**  clock.
*/
#if SYS_MAC_MPW || SYS_MAC_SYC

#ifndef SYS_TYPES_H                     /* various types                   */
# include       <Types.h>
# define SYS_TYPES_H
#endif

#ifndef SYS_EVENTS_H                    /* system events, high level:      */
# include       <Events.h>              /* 'TickCount'                     */
# define SYS_EVENTS_H
#endif

UInt SyTime ( void )
{
    return 100 * (UInt)TickCount() / (60/10) - SyStartTime;
}

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * * * string functions * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyStrlen( <str> ) . . . . . . . . . . . . . . . . . .  length of a string
**
**  'SyStrlen' returns the length of the string <str>, i.e.,  the  number  of
**  characters in <str> that precede the terminating null character.
*/
#ifndef SYS_STRING_H                    /* string functions                */
# include <string.h>
# define SYS_STRING_H
#endif

#ifndef SYS_HAS_STRING_PROTO            /* ANSI/TRAD decl. from H&S 13     */
# if SYS_ANSI
extern  char *          strncat ( char *, SYS_CONST char *, size_t );
extern  int             strcmp ( SYS_CONST char *, SYS_CONST char * );
extern  int             strncmp ( SYS_CONST char*, SYS_CONST char*, size_t );
extern  size_t          strlen ( SYS_CONST char * );
# else
extern  char *          strncat ( char *, SYS_CONST char *, int );
extern  int             strcmp ( SYS_CONST char *, SYS_CONST char * );
extern  int             strncmp ( SYS_CONST char *, SYS_CONST char *, int );
extern  int             strlen ( SYS_CONST char * );
# endif
#endif

UInt SyStrlen (
    SYS_CONST Char *     str )
{
    return strlen( str );
}


/****************************************************************************
**
*F  SyStrcmp( <str1>, <str2> )  . . . . . . . . . . . . . compare two strings
**
**  'SyStrcmp' returns an integer greater than, equal to, or less  than  zero
**  according to whether <str1> is greater  than,  equal  to,  or  less  than
**  <str2> lexicographically.
*/
Int SyStrcmp (
    SYS_CONST Char *    str1,
    SYS_CONST Char *    str2 )
{
    return strcmp( str1, str2 );
}

/****************************************************************************
**
*F  SyStrncmp( <str1>, <str2>, <len> )  . . . . . . . . . compare two strings
**
**  'SyStrncmp' returns an integer greater than, equal to,  or less than zero
**  according  to whether  <str1>  is greater than,  equal  to,  or less than
**  <str2> lexicographically.  'SyStrncmp' compares at most <len> characters.
*/
Int SyStrncmp (
    SYS_CONST Char *    str1,
    SYS_CONST Char *    str2,
    UInt                len )
{
    return strncmp( str1, str2, len );
}



/****************************************************************************
**
*F  SyStrncat( <dst>, <src>, <len> )  . . . . .  append one string to another
**
**  'SyStrncat'  appends characters from the  <src>  to <dst>  until either a
**  null character  is  encoutered  or  <len>  characters have   been copied.
**  <dst> becomes the concatenation of <dst> and <src>.  The resulting string
**  is always null terminated.  'SyStrncat' returns a pointer to <dst>.
*/
#ifdef SYS_HAS_BROKEN_STRNCAT


Char * SyStrncat (
    Char *              dst,
    SYS_CONST Char *    src,
    UInt                len )
{
    Char *              d;
    Char *              s;

    for ( d = dst; *d != '\0'; d++ )
        ;
    for ( s = src; *s != '\0' && 0 < len; len-- )
        *d++ = *s++;
    *d = 0;
    return dst;
}


#else
Char * SyStrncat (
    Char *              dst,
    SYS_CONST Char *    src,
    UInt                len )
{
    return strncat( dst, src, len );
}


#endif



/****************************************************************************
**

*F * * * * * * * * * * * * * * gasman interface * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyMsgsBags( <full>, <phase>, <nr> ) . . . . . . . display Gasman messages
**
**  'SyMsgsBags' is the function that is used by Gasman to  display  messages
**  during garbage collections.
*/
void SyMsgsBags (
    UInt                full,
    UInt                phase,
    Int                 nr )
{
    Char                cmd [3];        /* command string buffer           */
    Char                str [32];       /* string buffer                   */
    Char                ch;             /* leading character               */
    UInt                i;              /* loop variable                   */

    /* convert <nr> into a string with leading blanks                      */
    ch = '0';  str[7] = '\0';
    for ( i = 7; i != 0; i-- ) {
        if      ( 0 < nr ) { str[i-1] = '0' + ( nr) % 10;  ch = ' '; }
        else if ( nr < 0 ) { str[i-1] = '0' + (-nr) % 10;  ch = '-'; }
        else               { str[i-1] = ch;                ch = ' '; }
        nr = nr / 10;
    }

    /* ordinary full garbage collection messages                           */
    if ( 1 <= SyMsgsFlagBags && full ) {
        if ( phase == 0 ) { SyFputs( "#G  FULL ", 3 );                     }
        if ( phase == 1 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 2 ) { SyFputs( str, 3 );  SyFputs( "kb live  ", 3 ); }
        if ( phase == 3 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 4 ) { SyFputs( str, 3 );  SyFputs( "kb dead  ", 3 ); }
        if ( phase == 5 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 6 ) { SyFputs( str, 3 );  SyFputs( "kb free\n", 3 ); }
    }

    /* ordinary partial garbage collection messages                        */
    if ( 2 <= SyMsgsFlagBags && ! full ) {
        if ( phase == 0 ) { SyFputs( "#G  PART ", 3 );                     }
        if ( phase == 1 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 2 ) { SyFputs( str, 3 );  SyFputs( "kb+live  ", 3 ); }
        if ( phase == 3 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 4 ) { SyFputs( str, 3 );  SyFputs( "kb+dead  ", 3 ); }
        if ( phase == 5 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 6 ) { SyFputs( str, 3 );  SyFputs( "kb free\n", 3 ); }
    }

    /* package (window) mode full garbage collection messages              */
    if ( full && phase != 0 ) {
        if ( 3 <= phase ) nr *= 1024;
        cmd[0] = '@';
        cmd[1] = '0' + phase;
        cmd[2] = '\0';
        i = 0;
        for ( ; 0 < nr; nr /=10 )
            str[i++] = '0' + (nr % 10);
        str[i++] = '+';
        str[i++] = '\0';
        syWinPut( 1, cmd, str );
    }

}


/****************************************************************************
**
*F  SyAllocBags( <size>, <need> ) . . . allocate memory block of <size> bytes
**
**  'SyAllocBags' is called from Gasman to get new storage from the operating
**  system.  <size> is the needed amount in bytes (it is always a multiple of
**  512 KByte),  and <need> tells 'SyAllocBags' whether  Gasman  really needs
**  the storage or only wants it to have a reasonable amount of free storage.
**
**  Currently  Gasman  expects this function to return  immediately  adjacent
**  areas on subsequent calls.  So 'sbrk' will  work  on  most  systems,  but
**  'malloc' will not.
**
**  If <need> is 0, 'SyAllocBags' must return 0 if it cannot or does not want
**  to extend the workspace,  and a pointer to the allocated area to indicate
**  success.   If <need> is 1  and 'SyAllocBags' cannot extend the workspace,
**  'SyAllocBags' must abort,  because GAP assumes that  'NewBag'  will never
**  fail.
**
**  <size> may also be negative in which case 'SyAllocBags' should return the
**  storage to the operating system.  In this case  <need>  will always be 0.
**  'SyAllocBags' can either accept this reduction and  return 1  and  return
**  the storage to the operating system or refuse the reduction and return 0.
**
**  If the operating system does not support dynamic memory managment, simply
**  give 'SyAllocBags' a static buffer, from where it returns the blocks.
*/


/****************************************************************************
**
*f  SyAllocBags( <size>, <need> ) . . . . . . . BSD/USG/OS2 EMX/MSDOS/TOS/VMS
**
**  For UNIX,  OS/2, MS-DOS, TOS,  and VMS, 'SyAllocBags' calls 'sbrk', which
**  will work on most systems.
**
**  Note that   it may  happen that  another   function   has  called  'sbrk'
**  between  two calls to  'SyAllocBags',  so that the  next  allocation will
**  not be immediately adjacent to the last one.   In this case 'SyAllocBags'
**  returns the area to the operating system,  and either returns 0 if <need>
**  was 0 or aborts GAP if <need> was 1.  'SyAllocBags' will refuse to extend
**  the workspace beyond 'SyStorMax' or to reduce it below 'SyStorMin'.
*/
#if SYS_BSD||SYS_USG||SYS_OS2_EMX||SYS_MSDOS_DJGPP||SYS_TOS_GCC2||SYS_VMS

#ifndef SYS_HAS_MISC_PROTO              /* UNIX decl. from 'man'           */
extern  char * sbrk ( int );
#endif

UInt * * * syWorkspace;
UInt       syWorksize;


UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret;

    /* force alignment on first call                                       */
    if ( syWorkspace == (UInt***)0 ) {
#ifdef SYS_IS_64_BIT
        syWorkspace = (UInt***)sbrk( 8 - (Int)sbrk(0) % 8 );
#else
        syWorkspace = (UInt***)sbrk( 4 - (int)sbrk(0) % 4 );
#endif
        syWorkspace = (UInt***)sbrk( 0 );
    }

    /* get the storage, but only if we stay within the bounds              */
    if ( (0 < size && syWorksize + size <= SyStorMax)
      || (size < 0 && SyStorMin <= syWorksize + size) ) {
        ret = (UInt***)sbrk( (int)size );
    }
    else {
        ret = (UInt***)-1;
    }

    /* the allocation failed if the new area was not adjacent to the old   */
    if ( ret != (UInt***)-1
      && ret != (UInt***)((char*)syWorkspace + syWorksize) ) {
        sbrk( (int)-size );
        ret = (UInt***)-1;
    }

    /* update the size info                                                */
    if ( ret == (UInt***)((char*)syWorkspace + syWorksize) ) {
        syWorksize += size;
    }

    /* test if the allocation failed                                       */
    if ( ret == (UInt***)-1 && need ) {
        fputs("gap: cannot extend the workspace any more\n",stderr);
        SyExit( 1 );
    }

    /* otherwise return the result (which could be 0 to indicate failure)  */
    if ( ret == (UInt***)-1 )
        return 0;
    else
        return ret;

}

#endif


/****************************************************************************
**
*f  SyAllocBags( <size>, <need> ) . . . . . . . . . . . . . . . . . . .  MACH
**
**  Under MACH virtual memory managment functions are used instead of 'sbrk'.
*/
#if SYS_MACH

#include <mach/mach.h>

vm_address_t syBase  = 0;
Int          sySize  = 0;

UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret;
    vm_address_t        adr;

    /* check that <size> is divisible by <vm_page_size>                    */
    if ( size % vm_page_size != 0 ) {
        fputs( "gap: memory block size is not a multiple of vm_page_size",
               stderr );
        SyExit(1);
    }

    /* check that we stay within our bounds                                */
    if ( 0 < size && SyStorMax < sySize + size )
        ret = (UInt***) -1;
    else if ( size < 0 && sySize + size < SyStorMin )
        ret = (UInt***) -1;

    /* check that we don't try to shrink uninialized memory                */
    else if ( size <= 0 && syBase == 0 ) {
        fputs( "gap: trying to shrink uninialized vm memory\n", stderr );
        SyExit(1);
    }

    /* allocate memory anywhere on first call                              */
    else if ( 0 < size && syBase == 0 ) {
        if ( vm_allocate(task_self(),&syBase,size,TRUE) == KERN_SUCCESS ) {
            sySize = size;
            ret = (UInt***) syBase;
        }
        else
            ret = (UInt***) -1;
    }

    /* don't shrink memory but mark it as deactivated                      */
    else if ( size < 0 ) {
        adr = (vm_address_t)( (char*) syBase + (sySize+size) );
        if ( vm_deallocate(task_self(),adr,-size) == KERN_SUCCESS ) {
            ret = (UInt***)( (char*) syBase + sySize );
            sySize += size;
        }
        else
            ret = (UInt***) -1;
    }

    /* get more memory from system                                         */
    else {
        adr = (vm_address_t)( (char*) syBase + sySize );
        if ( vm_allocate(task_self(),&adr,size,FALSE) == KERN_SUCCESS ) {
            ret = (UInt***) ( (char*) syBase + sySize );
            sySize += size;
        }
        else
            ret = (UInt***) -1;
    }

    /* test if the allocation failed                                       */
    if ( ret == (UInt***)-1 && need ) {
        fputs("gap: cannot extend the workspace any more\n",stderr);
        SyExit(1);
    }

    /* otherwise return the result (which could be 0 to indicate failure)  */
    if ( ret == (UInt***)-1 )
        return 0;
    else
        return ret;

}

#endif


/****************************************************************************
**
*f  SyAllocBags( <size>, <need> ) . . . . . . . . . . . . . . . . . . MAC MPW
**
**  For the MAC under MPW we currently use 'calloc'.  This  does not allow to
**  extend the arena, but this is a problem of the memory manager anyhow.
*/
#if SYS_MAC_MPW

#ifndef SYS_HAS_CALLOC_PROTO
extern  char *          calloc ( int, int );
#endif

char * syWorkspace;


char * SyGetmem ( size )
    long                size;
{
    /* get the memory                                                      */
    /*N 1993/05/29 martin try to make it possible to extend the arena      */
    if ( syWorkspace == 0 ) {
        syWorkspace = calloc( (int)size/4, 4 );
        syWorkspace = (char*)(((long)syWorkspace + 3) & ~3);
        return syWorkspace;
    }
    else {
        return (char*)-1;
    }
}

#endif


/****************************************************************************
**
*f  SyAllocBags( <size>, <need> ) . . . . . . . . . . . . . . . . . . MAC SYS
**
**  For Mac under Think C we use 'NewPtr'.  This does not allow to extend the
**  area, but this is a problem of the memory manager anyhow.
*/
#if SYS_MAC_SYC

#ifndef SYS_STRING_H                    /* string functions:               */
# include      <string.h>               /* 'memset'                        */
# define SYS_STRING_H
#endif

#ifndef SYS_HAS_MEMSET_PROTO            /* ANSI/TRAD decl. from H&S ?.?    */
extern  void *          memset ( void * mem, int chr, size_t size );
#endif

UInt * * * syWorkspace;
UInt       syWorksize;

UInt * * *      SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret;

    /* get the storage, but only on first call                             */
    if ( syWorkspace == (UInt ***)0 ) {
      || (size < 0 && SyStorMin <= syWorksize + size) ) {
        syWorkspace = (UInt ***)NewPtr( size + 3 );
        syWorkspace = (char *)(((long)syWorkspace + 3) & ~3);
        memset( syWorkspace, 0, size );
        ret = syWorkspace;
    }

    /* otherwise signal an error                                           */
    else {
        ret = (UInt ***)-1;
    }

    /* return the result                                                   */
    return ret;
}

#endif


/****************************************************************************
**
*F  SyAbortBags(<msg>)  . . . . . . . . . . abort GAP in case of an emergency
**
**  'SyAbortBags' is the function called by Gasman in case of an emergency.
*/
void            SyAbortBags (
    Char *              msg )
{
    SyFputs( msg, 3 );
    SyExit( 2 );
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyExit( <ret> ) . . . . . . . . . . . . . exit GAP with return code <ret>
**
**  'SyExit' is the offical  way  to  exit GAP, bus errors are the inoffical.
**  The function 'SyExit' must perform all the neccessary cleanup operations.
**  If ret is 0 'SyExit' should signal to a calling proccess that all is  ok.
**  If ret is 1 'SyExit' should signal a  failure  to  the  calling proccess.
*/
#ifndef SYS_HAS_MISC_PROTO              /* ANSI/TRAD decl. from H&S 19.3   */
extern  void            exit ( int );
#endif

#if SYS_MAC_SYC
#ifndef SYS_CONSOLE_H                   /* console stuff                   */
# include       <Console.h>             /* 'console_options'               */
# define SYS_CONSOLE_H
#endif
#endif

void SyExit (
    UInt                ret )
{
#if SYS_MAC_MPW
# ifndef SYS_HAS_TOOL
    fputs("gap: please use <option>-'Q' to close the window.\n",stdout);
# endif
#endif

#if SYS_MAC_SYC
    /* if something went wrong, then give the user a change to see it      */
    if ( ret != 0 )
        console_options.pause_atexit = 1;

    /* if GAP will pause before exiting, tell the user                     */
    if ( console_options.pause_atexit == 1 )
        printf( "gap: enter <return> to exit");
#endif

    exit( (int)ret );
}


/****************************************************************************
**
*F  SySetGapRootPath( <string> )  . . . . . . . . .  set the root directories
**
**  'SySetGapRootPath' takes a  string and create  a list of root directories
**  in 'SyGapRootPaths'.
*/


/****************************************************************************
**
*f  SySetGapRootPath( <string> )  . . . . . . . . . . . . . . .  BSG/Mach/USG
*/
#if SYS_BSD || SYS_MACH || SYS_USG

void SySetGapRootPath( Char * string )
{
    Char *          p;
    Char *          q;
    Int             n;

    /* set string to a default value if unset                              */
    if ( string == 0 ) {
        string = "./";
    }

    /* store the string in 'SyGapRootPath'                                 */
    SyGapRootPath[0] = '\0';
    SyStrncat( SyGapRootPath, string, sizeof(SyGapRootPath)-2 );

    /* unpack the argument                                                 */
    p = SyGapRootPath;
    n = 0;
    while ( *p ) {
        q = SyGapRootPaths[n];
        while ( *p && *p != ';' ) {
            *q++ = *p++;
        }
        if ( q == SyGapRootPaths[n] ) {
            SyGapRootPaths[n][0] = '\0';
            SyStrncat( SyGapRootPaths[n], "./", 2 );
        }
        else if ( q[-1] != '/' ) {
            *q++ = '/';
            *q   = '\0';
        }
        else {
            *q   = '\0';
        }
        if ( *p ) {
            p++;  n++;
        }
    }
}

#endif

/****************************************************************************
**
*F  sySetGapRCFile()  . . . . . . . . . . . . .  add .gaprc to the init files
*/
void sySetGapRCFile ( void )
{
    Int             i;

    /* find a free slot                                                    */
    for ( i = 0;  i < sizeof(SyInitfiles)/sizeof(SyInitfiles[0]);  i++ ) {
        if ( SyInitfiles[i][0] == '\0' )
            break;
    }
    if ( i == sizeof(SyInitfiles)/sizeof(SyInitfiles[0]) )
        return;

#if SYS_BSD || SYS_MACH || SYS_USG
    if ( getenv("HOME") != 0 ) {
        SyInitfiles[i][0] = '\0';
        SyStrncat(SyInitfiles[i],getenv("HOME"),sizeof(SyInitfiles[0])-1);
        SyStrncat( SyInitfiles[i], "/.gaprc",
            (UInt)(sizeof(SyInitfiles[0])-1-SyStrlen(SyInitfiles[i])));
#endif

#if SYS_OS2_EMX || SYS_MSDOS_DJGPP || SYS_TOS_GCC2
    if ( getenv("HOME") != 0 ) {
        SyInitfiles[i][0] = '\0';
        SyStrncat(SyInitfiles[i],getenv("HOME"),sizeof(SyInitfiles[0])-1);
        SyStrncat( SyInitfiles[i], "/gap.rc",
            (UInt)(sizeof(SyInitfiles[0])-1-SyStrlen(SyInitfiles[i])));
#endif

#if SYS_VMS
    if ( getenv("GAP_INI") != 0 ) {
        SyStrncat(SyInitfiles[i],getenv("GAP_INI"),sizeof(SyInitfiles[0])-1);
#endif


#if SYS_MAC_MPW || SYS_MAC_SYC
    if ( 1 ) {
        SyInitfiles[i][0] = '\0';
        SyStrncat( SyInitfiles[i], "gap.rc",
            (UInt)(sizeof(SyInitfiles[0])-1-SyStrlen(SyInitfiles[i])));
#endif

        if ( SyIsReadableFile(SyInitfiles[i]) != 0 ) {
            SyInitfiles[i][0] = '\0';
        }
    }
}



/****************************************************************************
**
*F  InitSystem( <argc>, <argv> )  . . . . . . . . . initialize system package
**
**  'InitSystem' is called very early during the initialization from  'main'.
**  It is passed the command line array  <argc>, <argv>  to look for options.
**
**  For UNIX it initializes the default files 'stdin', 'stdout' and 'stderr',
**  installs the handler 'syAnsIntr' to answer the user interrupts '<ctr>-C',
**  scans the command line for options, tries to  find  'LIBNAME/init.g'  and
**  '$HOME/.gaprc' and copies the remaining arguments into 'SyInitfiles'.
*/
#ifndef SYS_HAS_MISC_PROTO              /* ANSI/TRAD decl. from H&S 20, 13 */
extern char *  getenv ( SYS_CONST char * );
extern int     atoi ( SYS_CONST char * );
#endif


#ifndef SYS_HAS_MISC_PROTO              /* UNIX decl. from 'man'           */
extern int     isatty ( int );
extern char *  ttyname ( int );
#endif


#ifndef SYS_HAS_MALLOC_PROTO
# if SYS_ANSI                           /* ANSI decl. from H&S 16.1, 16.2  */
extern void * malloc ( size_t );
extern void   free ( void * );
# else                                  /* TRAD decl. from H&S 16.1, 16.2  */
extern char * malloc ( unsigned );
extern void   free ( char * );
# endif
#endif


#if SYS_TOS_GCC2
# ifndef SYS_BASEPAGE_H                 /* definition of basepage          */
#  include      <basepage.h>
#  define SYS_BASEPAGE_H
# endif
#endif


#if SYS_MAC_SYC
#ifndef SYS_CONSOLE_H                   /* console stuff:                  */
# include       <Console.h>             /* 'console_options', 'cinverse'   */
# define SYS_CONSOLE_H
#endif
#endif


#if SYS_MAC_MPW || SYS_MAC_SYC
# ifndef SYS_HAS_TOOL
#  ifndef SYS_MEMORY_H                  /* Memory stuff:                   */
#   include     <Memory.h>              /* 'GetApplLimit', 'SetApplLimit', */
#   define SYS_MEMORY_H                 /* 'MaxApplZone', 'StackSpace',    */
#  endif                                /* 'MaxMem'                        */
# endif
#endif


#if SYS_MAC_MPW || SYS_MAC_SYC
# ifndef SYS_HAS_TOOL
Char * syArgv [128];
Char   syArgl [1024];
# endif
#endif


#if SYS_MAC_SYC
long * dedgen;
long * dedcos;
long   dedSize = 40960;
#endif


void InitSystem (
    Int                 argc,
    Char *              argv [] )
{
    Int                 pre = 63*1024;  /* amount to pre'malloc'ate        */
    UInt                gaprc = 1;      /* read the .gaprc file            */
    Char *              ptr;            /* pointer to the pre'malloc'ated  */
    Char *              ptr1;           /* more pre'malloc'ated  */
    Char *              gapRoot = 0;    /* gap root directory              */
    UInt                i;              /* loop variable                   */

#if SYS_MAC_MPW || SYS_MAC_SYC
# ifndef SYS_HAS_TOOL
    /* Increase the amount of stack space available to GAP.                */
    /* Following "Inside Macintosh - Memory" 1992, pages 1-42.             */
    /* For use with MPW 'SIOW.o' *after* changing instruction word         */
    /* at 3F94 from 'A063' (call to '_MaxApplZone') to '4E71' (NOP).       */
    /* 'fix_SIOW.c' is the source for an MPW tool, which does this safely. */
    /* Otherwise bungee-jumping the stack will lead to fatal head injuries.*/
    /*                                              Dave Bayer, 1994/07/14 */
    SetApplLimit( GetApplLimit() - (syStackSpace - StackSpace() + 1024) );
    MaxApplZone();
    if ( StackSpace() < syStackSpace ) {
        fputs("gap: cannot get enough stack space.\n",stderr);
        SyExit( 1 );
    }
# endif
#endif

    /* open the standard files                                             */
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_VMS
    syBuf[0].fp = stdin;   setbuf( stdin, syBuf[0].buf );
    if ( isatty( fileno(stdin) ) ) {
        if ( isatty( fileno(stdout) )
          && ! SyStrcmp( ttyname(fileno(stdin)), ttyname(fileno(stdout)) ) )
            syBuf[0].echo = stdout;
        else
            syBuf[0].echo = fopen( ttyname(fileno(stdin)), "w" );
        if ( syBuf[0].echo != (FILE*)0 && syBuf[0].echo != stdout )
            setbuf( syBuf[0].echo, (char*)0 );
    }
    else {
        syBuf[0].echo = stdout;
    }
    syBuf[1].echo = syBuf[1].fp = stdout;  setbuf( stdout, (char*)0 );
    if ( isatty( fileno(stderr) ) ) {
        if ( isatty( fileno(stdin) )
          && ! SyStrcmp( ttyname(fileno(stdin)), ttyname(fileno(stderr)) ) )
            syBuf[2].fp = stdin;
        else
            syBuf[2].fp = fopen( ttyname(fileno(stderr)), "r" );
        if ( syBuf[2].fp != (FILE*)0 && syBuf[2].fp != stdin )
            setbuf( syBuf[2].fp, syBuf[2].buf );
        syBuf[2].echo = stderr;
    }
    syBuf[3].fp = stderr;  setbuf( stderr, (char*)0 );
#endif
#if SYS_OS2_EMX
    syBuf[0].fp = stdin;   setbuf( stdin, syBuf[0].buf );
    if ( isatty( fileno(stdin) ) ) {
        if ( isatty( fileno(stdout) ) )
            syBuf[0].echo = stdout;
        else
            syBuf[0].echo = fopen( "CON", "w" );
        if ( syBuf[0].echo != (FILE*)0 && syBuf[0].echo != stdout )
            setbuf( syBuf[0].echo, (char*)0 );
    }
    else {
        syBuf[0].echo = stdout;
    }
    syBuf[1].echo = syBuf[1].fp = stdout;  setbuf( stdout, (char*)0 );
    if ( isatty( fileno(stderr) ) ) {
        if ( isatty( fileno(stdin) ) )
            syBuf[2].fp = stdin;
        else
            syBuf[2].fp = fopen( "CON", "r" );
        if ( syBuf[2].fp != (FILE*)0 && syBuf[2].fp != stdin )
            setbuf( syBuf[2].fp, syBuf[2].buf );
        syBuf[2].echo = stderr;
    }
    syBuf[3].fp = stderr;  setbuf( stderr, (char*)0 );
#endif
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2
    syBuf[0].fp = stdin;   setbuf( stdin, syBuf[0].buf );
    syBuf[1].echo = syBuf[1].fp = stdout;  setbuf( stdout, (char*)0 );
    syBuf[3].fp = stderr;  setbuf( stderr, (char*)0 );
    if ( isatty( fileno(stderr) ) )
        syBuf[2].fp = stderr;
#endif
#if SYS_MAC_MPW || SYS_MAC_SYC
    syBuf[0].fp = stdin;
    syBuf[1].fp = stdout;
    syBuf[2].fp = stdin;
    syBuf[3].fp = stderr;
#endif

    /* install the signal handler for '<ctr>-C'                            */
    SyInstallAnswerIntr();

#if SYS_MAC_MPW || SYS_MAC_SYC
# ifndef SYS_HAS_TOOL
    /* the Macintosh doesn't support command line options, read from file  */
    if ( (fid = SyFopen( "gap.options", "r" )) != -1 ) {
        argc = 0;
        argv = syArgv;
        argv[argc++] = "gap";
        ptr = syArgl;
        while ( SyFgets( ptr, (sizeof(syArgl)-1) - (ptr-syArgl), fid )
          && (ptr-syArgl) < (sizeof(syArgl)-1) ) {
            while ( *ptr != '#' && *ptr != '\0' )
                ptr++;
        }
        ptr = syArgl;
        while ( *ptr==' ' || *ptr=='\t' || *ptr=='\n' )  *ptr++ = '\0';
        while ( *ptr != '\0' ) {
            argv[argc++] = ptr;
            while ( *ptr!=' ' && *ptr!='\t' && *ptr!='\n' && *ptr!='\0' ) {
                if ( *ptr=='\\' )
                    for ( k = 0; ptr[k+1] != '\0'; k++ )
                        ptr[k] = ptr[k+1];
                ptr++;
            }
            while ( *ptr==' ' || *ptr=='\t' || *ptr=='\n' )  *ptr++ = '\0';
        }
        SyFclose( fid );
    }
# endif
#endif


    SySystemInitFile[0] = '\0';
    SyStrncat( SySystemInitFile, "lib/init.g", 10 );

    /* scan the command line for options                                   */
    while ( argc > 1 && argv[1][0] == '-' ) {

        if ( SyStrlen(argv[1]) != 2 ) {
            fputs("gap: sorry, options must not be grouped '",stderr);
            fputs(argv[1],stderr);  fputs("'.\n",stderr);
            goto usage;
        }

        switch ( argv[1][1] ) {


        /* '-B', name of the directory containing execs within root/bin    */
        case 'B':
            if ( argc < 3 ) {
                fputs("gap: option '-B' must have an argument.\n",stderr);
                goto usage;
            }
            SyArchitecture = argv[2];
            ++argv;  --argc;
            break;
        

        /* -C <output> <input> <name> <magic1>                             */
        case 'C':
            if ( argc < 6 ) {
                fputs("gap: option '-C' must have 4 arguments.\n",stderr);
                goto usage;
            }
            SyCompilePlease = 1;
            SyStrncat( SyCompileOutput, argv[2], sizeof(SyCompileOutput)-2 );
            ++argv; --argc;
            SyStrncat( SyCompileInput, argv[2], sizeof(SyCompileInput)-2 );
            ++argv; --argc;
            SyStrncat( SyCompileName, argv[2], sizeof(SyCompileName)-2 );
            ++argv; --argc;
            SyCompileMagic1 = argv[2];
            ++argv; --argc;
            break;


        /* '-D', debug loading of files                                    */
        case 'D':
            SyDebugLoading = ! SyDebugLoading;
            break;


        /* '-E', running under Emacs under OS/2                            */
#if SYS_OS2_EMX
        case 'E':
            SyLineEdit = 2;
            syBuf[2].fp = stdin;
            syBuf[2].echo = stderr;
            break;
#endif


        /* '-L', restore a saved workspace                                 */
        case 'L':
            if ( argc < 3 ) {
                fputs("gap: option '-L' must have an argument.\n",stderr);
                goto usage;
            }
            SyRestoring = argv[2];
            ++argv;  --argc;
            break;

        /* '-M', no dynamic/static modules                                 */
        case 'M':
            SyUseModule = ! SyUseModule;
            break;


        /* '-N', check for completion files in "init.g"                    */
        case 'N':
            SyCheckForCompletion = ! SyCheckForCompletion;
            break;


        /* '-X' check crc value while reading completion files             */
        case 'X':
            SyCheckCompletionCrcComp = ! SyCheckCompletionCrcComp;
            break;

        /* '-Y' check crc value while reading completion files             */
        case 'Y':
            SyCheckCompletionCrcRead = ! SyCheckCompletionCrcRead;
            break;

        /* '-Z', specify background check frequency                        */
#if SYS_MAC_SYC
        case 'Z':
            if ( argc < 3 ) {
                fputs("gap: option '-Z' must have an argument.\n",stderr);
                goto usage;
            }
            syIsBackFreq = atoi(argv[2]);
            ++argv; --argc;
            break;
#endif


        /* '-a <memory>', set amount to pre'm*a*lloc'ate                   */
        case 'a':
            if ( argc < 3 ) {
                fputs("gap: option '-a' must have an argument.\n",stderr);
                goto usage;
            }
            pre = atoi(argv[2]);
            if ( argv[2][SyStrlen(argv[2])-1] == 'k'
              || argv[2][SyStrlen(argv[2])-1] == 'K' )
                pre = pre * 1024;
            if ( argv[2][SyStrlen(argv[2])-1] == 'm'
              || argv[2][SyStrlen(argv[2])-1] == 'M' )
                pre = pre * 1024 * 1024;
            ++argv; --argc;
            break;


        /* '-b', supress the banner                                        */
        case 'b':
            SyBanner = ! SyBanner;
            break;


        /* '-c', change the value of 'SyCacheSize'                         */
        case 'c':
            if ( argc < 3 ) {
                fputs("gap: option '-c' must have an argument.\n",stderr);
                goto usage;
            }
            SyCacheSize = atoi(argv[2]);
            if ( argv[2][SyStrlen(argv[2])-1] == 'k'
              || argv[2][SyStrlen(argv[2])-1] == 'K' )
                SyCacheSize = SyCacheSize * 1024;
            if ( argv[2][SyStrlen(argv[2])-1] == 'm'
              || argv[2][SyStrlen(argv[2])-1] == 'M' )
                SyCacheSize = SyCacheSize * 1024 * 1024;
            ++argv; --argc;
            break;


        /* '-e', do not quit GAP on '<ctr>-D'                              */
        case 'e':
            SyCTRD = ! SyCTRD;
            break;


        /* '-f', force line editing                                        */
        case 'f':
            SyLineEdit = 2;
            break;


        /* '-g', Gasman should be verbose                                  */
        case 'g':
            SyMsgsFlagBags = (SyMsgsFlagBags + 1) % 3;
            break;


        /* '-h', print a usage help                                        */
        case 'h':
            goto usage;

        /* '-i' <initname>, changes the name of the init file              */
        case 'i':
            if ( argc < 3 ) {
                fputs("gap: option '-i' must have an argument.\n",stderr);
                goto usage;
            }
            SySystemInitFile[0] = '\0';
            SyStrncat( SySystemInitFile, argv[2], 255 );
            ++argv; --argc;
            break;
            

        /* '-l <root1>;<root2>;...', changes the value of 'GAPROOT'        */
        case 'l':
            if ( argc < 3 ) {
                fputs("gap: option '-l' must have an argument.\n",stderr);
                goto usage;
            }
            gapRoot = argv[2];
            ++argv; --argc;
            break;


        /* '-m <memory>', change the value of 'SyStorMin'                  */
        case 'm':
            if ( argc < 3 ) {
                fputs("gap: option '-m' must have an argument.\n",stderr);
                goto usage;
            }
            SyStorMin = atoi(argv[2]);
            if ( argv[2][SyStrlen(argv[2])-1] == 'k'
              || argv[2][SyStrlen(argv[2])-1] == 'K' )
                SyStorMin = SyStorMin * 1024;
            if ( argv[2][SyStrlen(argv[2])-1] == 'm'
              || argv[2][SyStrlen(argv[2])-1] == 'M' )
                SyStorMin = SyStorMin * 1024 * 1024;
            ++argv; --argc;
            break;


        /* '-n', disable command line editing                              */
        case 'n':
            SyLineEdit = 0;
            break;


        /* '-o <memory>', change the value of 'SyStorMax'                  */
        case 'o':
            if ( argc < 3 ) {
                fputs("gap: option '-o' must have an argument.\n",stderr);
                goto usage;
            }
            SyStorMax = atoi(argv[2]);
            if ( argv[2][SyStrlen(argv[2])-1] == 'k'
              || argv[2][SyStrlen(argv[2])-1] == 'K' )
                SyStorMax = SyStorMax * 1024;
            if ( argv[2][SyStrlen(argv[2])-1] == 'm'
              || argv[2][SyStrlen(argv[2])-1] == 'M' )
                SyStorMax = SyStorMax * 1024 * 1024;
            ++argv; --argc;
            break;


        /* '-p', start GAP package mode for output                         */
#if SYS_BSD || SYS_MACH || SYS_USG
        case 'p':
            SyWindow = ! SyWindow;
            break;
#endif


        /* '-q', GAP should be quiet                                       */
        case 'q':
            SyQuiet = ! SyQuiet;
            break;


        /* '-r', don't read the '.gaprc' file                              */
        case 'r':
            gaprc = ! gaprc;
            break;


        /* '-x', specify the length of a line                              */
        case 'x':
            if ( argc < 3 ) {
                fputs("gap: option '-x' must have an argument.\n",stderr);
                goto usage;
            }
            SyNrCols = atoi(argv[2]);
            ++argv; --argc;
            break;


        /* '-y', specify the number of lines                               */
        case 'y':
            if ( argc < 3 ) {
                fputs("gap: option '-y' must have an argument.\n",stderr);
                goto usage;
            }
            SyNrRows = atoi(argv[2]);
            ++argv; --argc;
            break;


        /* '-z', specify interrupt check frequency                         */
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2 || SYS_MAC_MPW || SYS_MAC_SYC
        case 'z':
            if ( argc < 3 ) {
                fputs("gap: option '-z' must have an argument.\n",stderr);
                goto usage;
            }
            syIsIntrFreq = atoi(argv[2]);
            ++argv; --argc;
            break;
#endif


        /* default, no such option                                         */
        default:
            fputs("gap: '",stderr);  fputs(argv[1],stderr);
            fputs("' option is unknown.\n",stderr);
            goto usage;

        }

        ++argv; --argc;

    }

    /* fix max if it is lower than min                                     */
    if ( SyStorMax < SyStorMin ) {
        SyStorMax = SyStorMin;
    }

    /* only check once                                                     */
    if ( SyCheckCompletionCrcComp ) {
        SyCheckCompletionCrcRead = 0;
    }

    /* set the library path                                                */
    SySetGapRootPath(gapRoot);

    /* when running in package mode set ctrl-d and line editing            */
    if ( SyWindow ) {
        SyLineEdit   = 1;
        SyCTRD       = 1;
        syWinPut( 0, "@p", "" );
        syBuf[2].fp = stdin;  syBuf[2].echo = stdout;
        syBuf[3].fp = stdout;
    }
   
#if SYS_MAC_SYC
    /* set up the console window options                                   */
    console_options.title = "\pGAP 4.0";
    console_options.nrows = SyNrRows;
    console_options.ncols = SyNrCols;
    console_options.pause_atexit = 0;
    cinverse( 1, stdin );
#endif

#if SYS_MAC_SYC
    /* allocate 'dedgen' und 'dedcos'                                      */
    dedgen = (long*)NewPtr( dedSize * sizeof(long) );
    dedcos = (long*)NewPtr( dedSize * sizeof(long) );
#endif

    /* premalloc stuff                                                     */
    ptr = malloc( pre );
    ptr1 = malloc(4);
    if ( ptr != 0 )  free( ptr );

    /* try to find 'LIBNAME/init.g' to read it upon initialization         */
    if ( SyCompilePlease || SyRestoring ) {
        SySystemInitFile[0] = 0;
    }

    /* the compiler will *not* read in the .gaprc file                     */
    if ( gaprc && ! ( SyCompilePlease || SyRestoring ) ) {
        sySetGapRCFile();
    }

    /* use the files from the command line                                 */
    for ( i = 0;  i < sizeof(SyInitfiles)/sizeof(SyInitfiles[0]);  i++ ) {
        if ( SyInitfiles[i][0] == '\0' )
            break;
    }
    while ( argc > 1 ) {
        if ( i >= sizeof(SyInitfiles)/sizeof(SyInitfiles[0]) ) {
            fputs("gap: sorry, cannot handle so many init files.\n",stderr);
            goto usage;
        }
        SyInitfiles[i][0] = '\0';
        SyStrncat( SyInitfiles[i], argv[1], sizeof(SyInitfiles[0])-1 );
        ++i;
        ++argv;
        --argc;
    }

#if SYS_TOS_GCC2
    /* for TOS we compute the amount of allocatable memory                 */
    if ( SyStorMin <= 0 ) {
        SyStorMin = (UInt)_base->p_hitpa - (UInt)_base->p_lowtpa
                   - _base->p_tlen - _base->p_dlen - _base->p_blen
                   - _stksize - pre - 8192 + SyStorMin;
    }
#endif

#if SYS_VMS
    /* for VMS we need to create the virtual keyboards for raw reading     */
    smg$create_virtual_keyboard( &syVirKbd );
#endif

#if SYS_MAC_MPW || SYS_MAC_SYC
# ifndef SYS_HAS_TOOL
    /* find out how much memory we can now allocate in the zone            */
    if ( SyStorMin <= 0 ) {
        SyStorMin = MaxMem( &i ) - SyStorMin - 384*1024;
        if ( SyStorMin < 1024*1024 ) {
            fputs(
        "gap: please use the 'Get Info' command in the Finder 'Desk' menu\n",
                  stderr );
            fputs(
        "     to set the minimum amount of memory to at least 2560 KByte,\n",
                  stderr );
            fputs(
        "     and the preferred amount of memory to 5632 KByte or more.\n",
                  stderr );
            SyExit( 1 );
        }
    }
# endif
#endif

    /* start the clock                                                     */
    SyStartTime = SyTime();

    /* now we start                                                        */
    return;

    /* print a usage message                                               */
usage:
 fputs("usage: gap [OPTIONS] [FILES]\n",stderr);
 fputs("       run the Groups, Algorithms and Programming system.\n",stderr);
 fputs("\n",stderr);

 fputs("  -b          toggle banner supression\n",stderr);
 fputs("  -q          toggle quiet mode\n",stderr);
 fputs("  -e          toggle quitting on <ctr>-D\n",stderr);
 fputs("  -f          force line editing\n",stderr);
 fputs("  -n          disable line editing\n",stderr);
 fputs("  -x <num>    set line width\n",stderr);
 fputs("  -y <num>    set number of lines\n",stderr);
#if SYS_OS2_EMX
 fputs("  -E          running under Emacs under OS/2\n",stderr);
#endif

 fputs("\n",stderr);
 fputs("  -g          toggle GASMAN messages\n",stderr);
 fputs("  -m <mem>    set the initial workspace size\n",stderr);
 fputs("  -o <mem>    set the maximal workspace size\n",stderr);
 fputs("  -c <mem>    set the cache size value\n",stderr);
 fputs("  -a <mem>    set amount to pre-malloc-ate\n",stderr);
 fputs("              postfix 'k' = *1024, 'm' = *1024*1024\n",stderr);

 fputs("\n",stderr);
 fputs("  -l <paths>  set the GAP root paths\n",stderr);
 fputs("  -r          toggle reading of the '.gaprc' file \n",stderr);
 fputs("  -D          toggle debuging the loading of library files\n",stderr);
 fputs("  -B <name>   current architecture\n",stderr);
 fputs("  -M          toggle loading of compiled modules\n",stderr);
 fputs("  -N          toggle check for completion files\n",stderr);
 fputs("  -X          toggle CRC for comp. files while reading\n",stderr);
 fputs("  -Y          toggle CRC for comp. files while completing\n",stderr);
 fputs("  -i <file>   change the name of the init file\n",stderr);

 fputs("\n",stderr);
 fputs("  -L <file>   restore a saved workspace\n",stderr);

 fputs("\n",stderr);
#if SYS_MAC_SYC
 fputs("  -Z <freq>   set background check frequency\n",stderr);
#endif
#if SYS_BSD || SYS_MACH || SYS_USG
 fputs("  -p          toggle package output mode\n",stderr);
#endif
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2 || SYS_MAC_MPW || SYS_MAC_SYC
 fputs("  -z <freq>   set interrupt check frequency\n",stderr);
#endif

 fputs("\n",stderr);
 SyExit( 1 );
}


/****************************************************************************
**

*E  system.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
