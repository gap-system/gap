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
**  SYS_HAS_BROKEN_STRNCAT
**      Use  this if   your 'strncat'  is   broken.  At least  in  SCO ODT2.0
**      (SVR3.2) 'strncat' has problems if the len is a multiple of 4.
**
**  SYS_HAS_BROKEN_TMPNAM
**      Use this if your 'tmpnam' generates only  a small number of temporary
**      file names.  At least NEXTSTEP 3.3 has such a problem.
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
**  SYS_HAS_SIG_T=<sig_t>
**      Use this to define the type of the value returned by signal handlers.
**      This should be either 'void' (default, ANSI C) or 'int' (older UNIX).
**
**  SYS_HAS_STDIO_PROTO
**      Use this to undefine the prototypes for 'fopen', 'fclose',  'setbuf',
**      'fgets', and 'fputs'.
**
**  SYS_HAS_READ_PROTO
**      Use this to undefine the prototypes for 'read' and 'write'.
**
**  SYS_HAS_STRING_PROTO
**      Use this to undefine the  prototypes  for  'strncat',  'strcmp',  and
**      'strlen'.
**
**  SYS_HAS_IOCTL_PROTO
**      Use this to undefine the prototype for 'ioctl'.
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
**      'sbrk', 'getenv', 'atoi', 'isatty', and 'ttyname'.
*/
char * Revision_system_c =
   "@(#)$Id$";


#define INCLUDE_DECLARATION_PART
#include        "system.h"              /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "sysfiles.h"            /* file input/output               */


#ifndef SYS_HAS_STDIO_PROTO             /* ANSI/TRAD decl. from H&S 15     */
extern FILE * fopen ( SYS_CONST char *, SYS_CONST char * );
extern int    fclose ( FILE * );
extern void   setbuf ( FILE *, char * );
extern char * fgets ( char *, int, FILE * );
extern int    fputs ( SYS_CONST char *, FILE * );
#endif

#ifdef __MWERKS__
# define SYS_IS_MAC_MPW             1
# define SYS_HAS_CALLOC_PROTO       1
#endif



/****************************************************************************
**

*T  Char, Int1, Int2, Int4, Int, UChar, UInt1, UInt2, UInt4, UInt .  integers
**
**  'Char',  'Int1',  'Int2',  'Int4',  'Int',   'UChar',   'UInt1', 'UInt2',
**  'UInt4', 'UInt' are the integer types.
**
**  Note that to get this to work, all files must be compiled with or without
**  '-DSYS_IS_64_BIT', not just "system.c".
**
**  '(U)Int<n>' should be exactly <n> bytes long
**  '(U)Int' should be the same length as a bag identifier
**
**  'Char',   'Int1', 'Int2',   'Int4',  'Int',  'UChar',   'UInt1', 'UInt2',
**  'UInt4', 'UInt' are defined  in the declaration  part of this package  as
**  follows.
**
#ifdef SYS_IS_64_BIT
typedef char                    Char;
typedef char                    Int1;
typedef short int               Int2;
typedef int                     Int4;
typedef long int                Int;
typedef unsigned char           UChar;
typedef unsigned char           UInt1;
typedef unsigned short int      UInt2;
typedef unsigned int            UInt4;
typedef unsigned long int       UInt;
#else                                   
typedef char                    Char;
typedef char                    Int1;
typedef short int               Int2;
typedef long int                Int4;
typedef long int                Int;
typedef unsigned char           UChar;
typedef unsigned char           UInt1;
typedef unsigned short int      UInt2;
typedef unsigned long int       UInt4;
typedef unsigned long int       UInt;
#endif
*/


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
Char            SyFlags [] = {

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

*F  SyStackAlign  . . . . . . . . . . . . . . . . . .  alignment of the stack
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
Char * SyArchitecture = "unknown";
#else
Char * SyArchitecture = SYS_ARCH;
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
*V  SyStorMax . . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorMax' is the maximal size of the workspace allocated by Gasman.
**
**  This is per default 64 MByte,  which is often a  reasonable value.  It is
**  usually changed with the '-t' option in the script that starts GAP.
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
Int SyStorMin = 4 * 1024 * 1024;
#endif

#if SYS_MSDOS_DJGPP
Int SyStorMin = 4 * 1024 * 1024;
#endif

#if SYS_TOS_GCC2
Int SyStorMin = 0;
#endif

#if SYS_VMS
Int SyStorMin = 4 * 1024 * 1024;
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

*F  IsAlpha( <ch> ) . . . . . . . . . . . . .  is a character a normal letter
**
**  'IsAlpha' returns 1 if its character argument is a normal character  from
**  the range 'a..zA..Z' and 0 otherwise.
**
**  'IsAlpha' and 'IsDigit' are implemented in the declaration part  of  this
**  package as follows:
**
#include        <ctype.h>
#define IsAlpha(ch)     (isalpha(ch))
#define IsDigit(ch)     (isdigit(ch))
*/


/****************************************************************************
**
*F  IsDigit( <ch> ) . . . . . . . . . . . . . . . . .  is a character a digit
**
**  'IsDigit' returns 1 if its character argument is a digit from  the  range
**  '0..9' and 0 otherwise.
**
**  'IsAlpha' and 'IsDigit' are implemented in the declaration part  of  this
**  package as follows:
**
#include        <ctype.h>
#define IsAlpha(ch)     (isalpha(ch))
#define IsDigit(ch)     (isdigit(ch))
*/


/****************************************************************************
**
*F  SyStrlen( <str> ) . . . . . . . . . . . . . . . . . .  length of a string
**
**  'SyStrlen' returns the length of the string <str>, i.e.,  the  number  of
**  characters in <str> that precede the terminating null character.
*/
#ifndef SYS_STRING_H                    /* string functions                */
# include      <string.h>
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
    Char *              str )
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
    Char *              str1,
    Char *              str2 )
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
    Char *              str1,
    Char *              str2,
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
    Char *              src,
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
    Char *              src,
    UInt                len )
{
    return strncat( dst, src, len );
}

#endif


/****************************************************************************
**

*F  syStartraw( <fid> ) . . . . . . start raw mode on input file <fid>, local
**
**  The  following four  functions are  the  actual system  dependent part of
**  'SyFgets'.
**
**  'syStartraw' tries to put the file with the file  identifier  <fid>  into
**  raw mode.  I.e.,  disabling  echo  and  any  buffering.  It also finds  a
**  place to put the echoing  for  'syEchoch'.  If  'syStartraw'  succedes it
**  returns 1, otherwise, e.g., if the <fid> is not a terminal, it returns 0.
**
**  'syStopraw' stops the raw mode for the file  <fid>  again,  switching  it
**  back into whatever mode the terminal had before 'syStartraw'.
**
**  'syGetch' reads one character from the file <fid>, which must  have  been
**  turned into raw mode before, and returns it.
**
**  'syEchoch' puts the character <ch> to the file opened by 'syStartraw' for
**  echoing.  Note that if the user redirected 'stdout' but not 'stdin',  the
**  echo for 'stdin' must go to 'ttyname(fileno(stdin))' instead of 'stdout'.
*/
extern UInt syStartraw (
            Int                 fid );

extern void syStopraw (
            Int                 fid );


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . .  BSD/MACH
**
**  For Berkeley UNIX, input/output redirection and typeahead are  supported.
**  We switch the terminal line into 'CBREAK' mode and also disable the echo.
**  We do not switch to 'RAW'  mode because  this would flush  all typeahead.
**  Because 'CBREAK' leaves signals enabled we have to disable the characters
**  for interrupt and quit, which are usually set to '<ctr>-C' and '<ctr>-B'.
**  We also turn  off  the  xon/xoff  start and  stop characters,  which  are
**  usually set  to '<ctr>-S' and '<ctr>-Q' so  we can get  those characters.
**  We  do not  change the  suspend  character, which  is usually  '<ctr>-Z',
**  instead we catch the signal, so that we  can turn  the terminal line back
**  to cooked mode before stopping GAP and back to raw mode when continueing.
*/
#if SYS_BSD || SYS_MACH

#ifndef SYS_SGTTY_H                     /* terminal control functions      */
# include       <sgtty.h>
# define SYS_SGTTY_H
#endif

#ifndef SYS_HAS_IOCTL_PROTO             /* UNIX decl. from 'man'           */
extern  int             ioctl ( int, unsigned long, char * );
#endif

struct sgttyb   syOld, syNew;           /* old and new terminal state      */
struct tchars   syOldT, syNewT;         /* old and new special characters  */

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

#ifndef SYS_HAS_READ_PROTO              /* UNIX decl. from 'man'           */
extern  int             read ( int, char *, int );
extern  int             write ( int, char *, int );
#endif

#ifdef SIGTSTP

Int syFid;

SYS_SIG_T syAnswerCont (
    int                 signr )
{
    syStartraw( syFid );
    signal( SIGCONT, SIG_DFL );
    kill( getpid(), SIGCONT );
#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}

SYS_SIG_T syAnswerTstp (
    int                 signr )
{
    syStopraw( syFid );
    signal( SIGCONT, syAnswerCont );
    kill( getpid(), SIGTSTP );
#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}

#endif

UInt syStartraw (
    Int                 fid )
{
    /* if running under a window handler, tell it that we want to read     */
    if ( SyWindow ) {
        if      ( fid == 0 ) { syWinPut( fid, "@i", "" );  return 1; }
        else if ( fid == 2 ) { syWinPut( fid, "@e", "" );  return 1; }
        else {                                             return 0; }
    }

    /* try to get the terminal attributes, will fail if not terminal       */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCGETP, (char*)&syOld ) == -1 )
        return 0;

    /* disable interrupt, quit, start and stop output characters           */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCGETC, (char*)&syOldT ) == -1 )
        return 0;
    syNewT = syOldT;
    syNewT.t_intrc  = -1;
    syNewT.t_quitc  = -1;
    /*C 27-Nov-90 martin changing '<ctr>S' and '<ctr>Q' does not work      */
    /*C syNewT.t_startc = -1;                                              */
    /*C syNewT.t_stopc  = -1;                                              */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCSETC, (char*)&syNewT ) == -1 )
        return 0;

    /* disable input buffering, line editing and echo                      */
    syNew = syOld;
    syNew.sg_flags |= CBREAK;
    syNew.sg_flags &= ~ECHO;
    if ( ioctl( fileno(syBuf[fid].fp), TIOCSETN, (char*)&syNew ) == -1 )
        return 0;

#ifdef SIGTSTP
    /* install signal handler for stop                                     */
    syFid = fid;
    signal( SIGTSTP, syAnswerTstp );
#endif

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . . . USG
**
**  For UNIX System V, input/output redirection and typeahead are  supported.
**  We  turn off input buffering  and canonical input editing and  also echo.
**  Because we leave the signals enabled  we  have  to disable the characters
**  for interrupt and quit, which are usually set to '<ctr>-C' and '<ctr>-B'.
**  We   also turn off the  xon/xoff  start  and  stop  characters, which are
**  usually set to  '<ctr>-S'  and '<ctr>-Q' so we  can get those characters.
**  We do  not turn of  signals  'ISIG' because  we want   to catch  stop and
**  continue signals if this particular version  of UNIX supports them, so we
**  can turn the terminal line back to cooked mode before stopping GAP.
*/
#if SYS_USG

#ifndef SYS_TERMIO_H                    /* terminal control functions      */
# include       <termio.h>
# define SYS_TERMIO_H
#endif

#ifndef SYS_HAS_IOCTL_PROTO             /* UNIX decl. from 'man'           */
extern  int             ioctl ( int, int, struct termio * );
#endif

struct termio   syOld, syNew;           /* old and new terminal state      */

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

#ifndef SYS_HAS_READ_PROTO              /* UNIX decl. from 'man'           */
extern  int             read ( int, char *, int );
extern  int             write ( int, char *, int );
#endif

#ifdef SIGTSTP

Int syFid;

SYS_SIG_T syAnswerCont (
    int                 signr )
{
    syStartraw( syFid );
    signal( SIGCONT, SIG_DFL );
    kill( getpid(), SIGCONT );
#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}

SYS_SIG_T syAnswerTstp (
    int                 signr )
{
    syStopraw( syFid );
    signal( SIGCONT, syAnswerCont );
    kill( getpid(), SIGTSTP );
#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}

#endif

UInt syStartraw (
    Int                 fid )
{
    /* if running under a window handler, tell it that we want to read     */
    if ( SyWindow ) {
        if      ( fid == 0 ) { syWinPut( fid, "@i", "" );  return 1; }
        else if ( fid == 2 ) { syWinPut( fid, "@e", "" );  return 1; }
        else {                                             return 0; }
    }

    /* try to get the terminal attributes, will fail if not terminal       */
    if ( ioctl( fileno(syBuf[fid].fp), TCGETA, &syOld ) == -1 )   return 0;

    /* disable interrupt, quit, start and stop output characters           */
    syNew = syOld;
    syNew.c_cc[VINTR] = 0377;
    syNew.c_cc[VQUIT] = 0377;
    /*C 27-Nov-90 martin changing '<ctr>S' and '<ctr>Q' does not work      */
    /*C syNew.c_iflag    &= ~(IXON|INLCR|ICRNL);                           */
    syNew.c_iflag    &= ~(INLCR|ICRNL);

    /* disable input buffering, line editing and echo                      */
    syNew.c_cc[VMIN]  = 1;
    syNew.c_cc[VTIME] = 0;
    syNew.c_lflag    &= ~(ECHO|ICANON);
    if ( ioctl( fileno(syBuf[fid].fp), TCSETAW, &syNew ) == -1 )  return 0;

#ifdef SIGTSTP
    /* install signal handler for stop                                     */
    syFid = fid;
    signal( SIGTSTP, syAnswerTstp );
#endif

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . OS2 EMX
**
**  OS/2 is almost the same as UNIX System V, except for function keys.
*/
#if SYS_OS2_EMX

#ifndef SYS_TERMIO_H                    /* terminal control functions      */
# include       <termio.h>
# define SYS_TERMIO_H
#endif
#ifndef SYS_HAS_IOCTL_PROTO             /* UNIX decl. from 'man'           */
extern  int             ioctl ( int, int, struct termio * );
#endif

struct termio   syOld, syNew;           /* old and new terminal state      */

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

#ifndef SYS_HAS_READ_PROTO              /* UNIX decl. from 'man'           */
extern  int             read ( int, char *, int );
extern  int             write ( int, char *, int );
#endif

#ifdef SIGTSTP

Int             syFid;

SYS_SIG_T syAnswerCont (
    int                 signr )
{
    syStartraw( syFid );
    signal( SIGCONT, SIG_DFL );
    kill( getpid(), SIGCONT );
#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}

SYS_SIG_T syAnswerTstp (
    int                 signr )
{
    syStopraw( syFid );
    signal( SIGCONT, syAnswerCont );
    kill( getpid(), SIGTSTP );
#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}

#endif

UInt syStartraw (
    Int                 fid )
{
    /* if running under a window handler, tell it that we want to read     */
    if ( SyWindow ) {
        if      ( fid == 0 ) { syWinPut( fid, "@i", "" );  return 1; }
        else if ( fid == 2 ) { syWinPut( fid, "@e", "" );  return 1; }
        else {                                             return 0; }
    }

    /* try to get the terminal attributes, will fail if not terminal       */
    if ( ioctl( fileno(syBuf[fid].fp), TCGETA, &syOld ) == -1 )   return 0;

    /* disable interrupt, quit, start and stop output characters           */
    syNew = syOld;
    syNew.c_cc[VINTR] = 0377;
    syNew.c_cc[VQUIT] = 0377;
    /*C 27-Nov-90 martin changing '<ctr>S' and '<ctr>Q' does not work      */
    /*C syNew.c_iflag    &= ~(IXON|INLCR|ICRNL);                           */
    syNew.c_iflag    &= ~(INLCR|ICRNL);

    /* disable input buffering, line editing and echo                      */
    syNew.c_cc[VMIN]  = 1;
    syNew.c_cc[VTIME] = 0;
    syNew.c_lflag    &= ~(ECHO|ICANON|IDEFAULT);
    if ( ioctl( fileno(syBuf[fid].fp), TCSETAW, &syNew ) == -1 )  return 0;

#ifdef SIGTSTP
    /* install signal handler for stop                                     */
    syFid = fid;
    signal( SIGTSTP, syAnswerTstp );
#endif

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . .  MS-DOS
**
**  For MS-DOS we read  directly  from the  keyboard.   Note that the  window
**  handler is not currently supported.
*/
#if SYS_MSDOS_DJGPP

#ifndef SYS_KBD_H                       /* keyboard functions              */
# include       <pc.h>
# define GETKEY()       getkey()
# define PUTCHAR(C)     putchar(C)
# define KBHIT()        kbhit()
# define SYS_KBD_H
#endif

UInt            syStopout;              /* output is stopped by <ctr>-'S'  */

Char            syTypeahead [256];      /* characters read by 'SyIsIntr'   */

Char            syAltMap [35] = "QWERTYUIOP    ASDFGHJKL     ZXCVBNM";

UInt syStartraw (
    Int                 fid )
{
    /* check if the file is a terminal                                     */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return 0;

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . . . TOS
**
**  For TOS we read directly from the keyboard.  Note that the window handler
**  is not currently supported.
*/
#if SYS_TOS_GCC2

#ifndef SYS_KBD_H                       /* keyboard functions              */
# include       <unixlib.h>             /* declaration of 'isatty'         */
# include       <osbind.h>              /* operating system binding        */
# define GETKEY()       Bconin( 2 )
# define PUTCHAR(C)     do{if(C=='\n')Bconout(2,'\r');Bconout(2,C);}while(0)
# define KBHIT()        Bconstat( 2 )
# define SYS_KBD_H
#endif

UInt            syStopout;              /* output is stopped by <ctr>-'S'  */

Char            syTypeahead [256];      /* characters read by 'SyIsIntr'   */

Int syStartraw (
    Int                 fid )
{
    /* check if the file is a terminal                                     */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return 0;

    /* indicate success                                                    */
    return 1;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . . . VMS
**
**  For VMS we use a virtual keyboard to read and  write from the unique tty.
**  We do not support the window handler.
*/
#if SYS_VMS

#ifndef SYS_HAS_MISC_PROTO              /* UNIX decl. from 'man'           */
extern  int             isatty ( int );
#endif

UInt            syVirKbd;       /* virtual (raw) keyboard          */

UInt syStartraw (
    Int                 fid )
{
    /* test whether the file is connected to a terminal                    */
    return isatty( fileno(syBuf[fid].fp) );
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . MAC MPW
**
**  For the MAC with MPW we do not really know how to do this.
*/
#if SYS_MAC_MPW

Int syStartraw (
    Int                 fid )
{
    /* clear away pending <command>-'.'                                    */
    SyIsIntr();

    return 0;
}

#endif


/****************************************************************************
**
*f  syStartraw( <fid> ) . . . . . . . . . . . . . . . . . . . . . . . MAC SYC
**
**  For the MAC with Symantec C we use the  console input/output package.  We
**  must  set the console to  raw mode and  back to echo   mode.  In raw mode
**  there is no cursor, so we reverse the current character.
*/
#if SYS_MAC_SYC

#ifndef SYS_UNIX_H                      /* unix stuff:                     */
# include       <unix.h>                /* 'isatty'                        */
# define SYS_UNIX_H
#endif

#ifndef SYS_CONSOLE_H                   /* console stuff:                  */
# include       <Console.h>             /* 'csetmode'                      */
# define SYS_CONSOLE_H
#endif

#ifndef SYS_OSUTILS_H                   /* system utils:                   */
# include       <OSUtils.h>             /* 'SysBeep'                       */
# define SYS_OSUTILS_H
#endif

UInt syStartraw (
    Int                 fid )
{

    /* cannot switch ordinary files to raw mode                            */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return 0;

    /* turn terminal to raw mode                                           */
    csetmode( C_RAW, syBuf[fid].fp );
    return 1;
}

#endif


/****************************************************************************
**
*F  syStopraw( <fid> )  . . . . . .  stop raw mode on input file <fid>, local
*/


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . .  BSD/MACH
*/
#if SYS_BSD || SYS_MACH

void syStopraw (
    Int                 fid )
{
    /* if running under a window handler, don't do nothing                 */
    if ( SyWindow )
        return;

#ifdef SIGTSTP
    /* remove signal handler for stop                                      */
    signal( SIGTSTP, SIG_DFL );
#endif

    /* enable input buffering, line editing and echo again                 */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCSETN, (char*)&syOld ) == -1 )
        fputs("gap: 'ioctl' could not turn off raw mode!\n",stderr);

    /* enable interrupt, quit, start and stop output characters again      */
    if ( ioctl( fileno(syBuf[fid].fp), TIOCSETC, (char*)&syOldT ) == -1 )
        fputs("gap: 'ioctl' could not turn off raw mode!\n",stderr);
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . USG
*/
#if SYS_USG

void syStopraw (
    Int                 fid )
{
    /* if running under a window handler, don't do nothing                 */
    if ( SyWindow )
        return;

#ifdef SIGTSTP
    /* remove signal handler for stop                                      */
    signal( SIGTSTP, SIG_DFL );
#endif

    /* enable input buffering, line editing and echo again                 */
    if ( ioctl( fileno(syBuf[fid].fp), TCSETAW, &syOld ) == -1 )
        fputs("gap: 'ioctl' could not turn off raw mode!\n",stderr);
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . OS2 EMX
*/
#if SYS_OS2_EMX

void syStopraw (
    Int                 fid )
{
    /* if running under a window handler, don't do nothing                 */
    if ( SyWindow )
        return;

#ifdef SIGTSTP
    /* remove signal handler for stop                                      */
    signal( SIGTSTP, SIG_DFL );
#endif

    /* enable input buffering, line editing and echo again                 */
    if ( ioctl( fileno(syBuf[fid].fp), TCSETAW, &syOld ) == -1 )
        fputs("gap: 'ioctl' could not turn off raw mode!\n",stderr);
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . .  MS-DOS
*/
#if SYS_MSDOS_DJGPP

void syStopraw (
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . TOS
*/
#if SYS_TOS_GCC2

void syStopraw (
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . VMS
*/
#if SYS_VMS

void syStopraw (
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . MAC MPW
*/
#if SYS_MAC_MPW

void syStopraw (
    Int                 fid )
{
}

#endif


/****************************************************************************
**
*f  syStopraw( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . MAC SYC
*/
#if SYS_MAC_SYC

void syStopraw (
    Int                 fid )
{
    /* probably only paranoid                                              */
    if ( isatty( fileno(syBuf[fid].fp) ) )
        return;

    /* turn terminal back to echo mode                                     */
    csetmode( C_ECHO, syBuf[fid].fp );
}

#endif


/****************************************************************************
**
*F  SyIsIntr()  . . . . . . . . . . . . . . . . check wether user hit <ctr>-C
**
**  'SyIsIntr' is called from the evaluator at  regular  intervals  to  check
**  wether the user hit '<ctr>-C' to interrupt a computation.
**
**  'SyIsIntr' returns 1 if the user typed '<ctr>-C' and 0 otherwise.
*/


/****************************************************************************
**
*f  SyIsIntr()  . . . . . . . . . . . . . . . . . .  BSD/MACH/USG/OS2 EMX/VMS
**
**  For  UNIX, OS/2  and VMS  we  install 'syAnswerIntr' to  answer interrupt
**  'SIGINT'.   If two interrupts  occur within 1 second 'syAnswerIntr' exits
**  GAP.
*/
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_OS2_EMX || SYS_VMS

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

#ifndef SYS_TIME_H                      /* time functions                  */
# if SYS_VMS
#  include      <types.h>               /* declaration of type 'time_t'    */
# endif
# include       <time.h>
# define SYS_TIME_H
#endif

#ifndef SYS_HAS_TIME_PROTO              /* ANSI/TRAD decl. from H&S 18.1    */
# if SYS_ANSI
extern  time_t          time ( time_t * buf );
# else
extern  long            time ( long * buf );
# endif
#endif

UInt            syLastIntr;             /* time of the last interrupt      */

extern void     InterruptExecStat ( void );


SYS_SIG_T syAnswerIntr (
    int                 signr )
{
    UInt                nowIntr;

    /* get the current wall clock time                                     */
    nowIntr = time(0);

    /* if the last '<ctr>-C' was less than a second ago, exit GAP          */
    if ( syLastIntr && nowIntr-syLastIntr < 1 ) {
        fputs("gap: you hit '<ctr>-C' twice in a second, goodbye.\n",stderr);
        SyExit( 1 );
    }

    /* reinstall 'syAnswerIntr' as signal handler                          */
#if ! SYS_OS2_EMX
    signal( SIGINT, syAnswerIntr );
#else
    signal( signr, SIG_ACK );
#endif

    /* remember time of this interrupt                                     */
    syLastIntr = nowIntr;

#ifdef SYS_HAS_SIGNALS
    /* interrupt the executor                                              */
    InterruptExecStat();
#endif

#ifdef SYS_HAS_SIG_T
    return 0;                           /* is ignored                      */
#endif
}


UInt SyIsIntr ( void )
{
    UInt                isIntr;

    isIntr = (syLastIntr != 0);
    syLastIntr = 0;
    return isIntr;
}

#endif


/****************************************************************************
**
*f  SyIsIntr()  . . . . . . . . . . . . . . . . . . . . . . . . .  MS-DOS/TOS
**
**  In DOS we check the input queue to look for <ctr>-'C', chars read are put
**  on the 'osTNumahead' buffer. The buffer is flushed if <ctr>-'C' is found.
**  Actually with the current DOS extender we cannot trap  <ctr>-'C', because
**  the DOS extender does so already, so be use <ctr>-'Z' and <alt>-'C'.
**
**  In TOS we check the input queue to look for <ctr>-'C', chars read are put
**  on the 'osTNumahead' buffer. The buffer is flushed if <ctr>-'C' is found.
**  There is however a problem, if 2 or  more characters are pending (that is
**  waiting to be read by either 'SyIsIntr' or 'SyGetch') and the second is a
**  <ctr>-'C', GAP will be killed when 'SyIsIntr' or  'syGetch' tries to read
**  the first character.  Thus  if you typed ahead  and want to interrupt the
**  computation, wait some time to make sure that  the typed ahead characters
**  have been read by 'SyIsIntr' befor you hit <ctr>-'C'.
*/
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2

UInt            syIsIntrFreq = 20;

UInt            syIsIntrCount = 0;

UInt SyIsIntr ( void )
{
    Int                 ch;
    UInt                i;

    /* don't check for interrupts every time 'SyIsIntr' is called          */
    if ( 0 < --syIsIntrCount )
        return 0;
    syIsIntrCount = syIsIntrFreq;

    /* check for interrupts stuff the rest in typeahead buffer             */
    if ( SyLineEdit && KBHIT() ) {
        while ( KBHIT() ) {
            ch = GETKEY();
            if ( ch == CTR('C') || ch == CTR('Z') || ch == 0x12E ) {
                PUTCHAR('^'); PUTCHAR('C');
                syTypeahead[0] = '\0';
                syStopout = 0;
                return 1L;
            }
            else if ( ch == CTR('X') ) {
                PUTCHAR('^'); PUTCHAR('X');
                syTypeahead[0] = '\0';
                syStopout = 0;
            }
            else if ( ch == CTR('S') ) {
                syStopout = 1;
            }
            else if ( syStopout ) {
                syStopout = 0;
            }
            else {
                for ( i = 0; i < sizeof(syTypeahead)-1; ++i ) {
                    if ( syTypeahead[i] == '\0' ) {
                        PUTCHAR(ch);
                        syTypeahead[i] = ch;
                        syTypeahead[i+1] = '\0';
                        break;
                    }
                }
            }
        }
        return 0L;
    }
    return 0L;
}

#endif


/****************************************************************************
**
*f  SyIsIntr()  . . . . . . . . . . . . . . . . . . . . . . . . . . . MAC MPW
**
**  For a  MPW Tool, we install 'syAnswerIntr'  to answer interrupt 'SIGINT'.
**  However, the interrupt is  only delivered when  the system has a control,
**  namely  when  we call the  toolbox   function 'SpinCursor' in 'SyIsIntr'.
**  Thus the mechanism is effectively polling.
**
**  For a MPW SIOW, we search the event queue for a <cmd>-'.' or a <cnt>-'C'.
**  If one is found, all keyboard events are flushed.
**
*/
#if SYS_MAC_MPW

#ifdef  SYS_HAS_TOOL

#ifndef SYS_SIGNAL_H                    /* signal handling functions       */
# include       <Signal.h>
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
#endif

#ifndef SYS_CURSORCTL_H                 /* cursor control functions:       */
# include       <CursorCtl.h>           /* 'Show_Cursor', 'SpinCursor'     */
# define SYS_CURSORCTL_H
#endif

UInt            syNrIntr;               /* number of interrupts            */

UInt            syLastIntr;             /* time of the last interrupt      */

UInt            syIsIntrFreq = 100;     /* frequency to test interrupts    */

UInt            syIsIntrCount =  0;     /* countdown to test interrupts    */


void syAnswerIntr (
    int                 signr )
{
    /* reinstall the signal handler                                        */
    signal( SIGINT, &syAnswerIntr );

    /* exit if two interrupts happen within one second                     */
    /*N 1993/05/28 martin this doesn't work, because interrupts are only   */
    /*N                   delivered when we call 'SpinCursor' below        */
    if ( syNrIntr && SyTime()-syLastIntr <= 1000 )
        SyExit( 1 );

    /* got one more interrupt                                              */
    syNrIntr   = syNrIntr + 1;
    syLastIntr = SyTime();
}


UInt SyIsIntr ( void )
{
    UInt                syIsIntr;

    /* don't check for interrupts every time 'SyIsIntr' is called          */
    if ( 0 < --syIsIntrCount )
        return 0;
    syIsIntrCount = syIsIntrFreq;

    /* spin the beachball                                                  */
    Show_Cursor( HIDDEN_CURSOR );
    SpinCursor( 8 );

    /* check for interrupts                                                */
    syIsIntr = (syNrIntr != 0);

    /* every interrupt leaves a <eof>, which we want to remove             */
    while ( syNrIntr ) {
        while ( getchar() != EOF ) ;
        clearerr( stdin );
        syNrIntr = syNrIntr - 1;
    }

    /* return whether an interrupt has happened                            */
    return syIsIntr;
}

#else

#ifndef SYS_TNUMS_H                     /* various types                   */
# include       <TNums.h>
# define SYS_TNUMS_H
#endif

#ifndef SYS_OSUTILS_H                   /* system utils:                   */
# include       <OSUtils.h>             /* 'QHdr'                          */
# define SYS_OSUTILS_H
#endif

#ifndef SYS_OSEVENTS_H                  /* system events, low level:       */
# include       <OSEvents.h>            /* 'EvQEl', 'GetEvQHdr',           */
                                        /* 'FlushEvents'                   */
# define SYS_OSEVENTS_H
#endif

#ifndef SYS_EVENTS_H                    /* system events, high level:      */
# include       <Events.h>              /* 'EventRecord', 'GetNextEvent'   */
# define SYS_EVENTS_H
#endif

UInt            syNrIntr;               /* number of interrupts            */

UInt            syLastIntr;             /* time of the last interrupt      */

UInt            syIsIntrFreq = 100;     /* frequency to test interrupts    */

UInt            syIsIntrCount =  0;     /* countdown to test interrupts    */


UInt SyIsIntr ( void )
{
    UInt                syIsIntr;
    struct QHdr *       queue;
    struct EvQEl *      qentry;

    /* don't check for interrupts every time 'SyIsIntr' is called          */
    if ( 0 < --syIsIntrCount )
        return 0;
    syIsIntrCount = syIsIntrFreq;

    /* look through the event queue for <command>-'.' or <control>-'C'     */
    queue = GetEvQHdr();
    qentry = (struct EvQEl *)(queue->qHead);
    while ( qentry ) {
        if ( qentry->evtQWhat == keyDown
            &&   ( ((qentry->evtQModifiers & controlKey) != 0)
                && ((qentry->evtQMessage & charCodeMask) ==   3))
              || ( ((qentry->evtQModifiers & cmdKey    ) != 0)
                && ((qentry->evtQMessage & charCodeMask) == '.')) ) {
            syNrIntr++;
        }
        qentry = (struct EvQEl *)(qentry->qLink);
    }

    /* check for interrupts                                                */
    syIsIntr = (syNrIntr != 0);

    /* flush away all keyboard events after an interrupt                   */
    if ( syNrIntr ) {
        FlushEvents( keyDownMask, 0 );
        syNrIntr = 0;
    }

    /* return whether an interrupt has happened                            */
    return syIsIntr;
}

#endif

#endif


/****************************************************************************
**
*f  SyIsIntr()  . . . . . . . . . . . . . . . . . . . . . . . . . . . MAC SYC
**
**  For Symantec C, we search the event queue for a <cmd>-'.' or a <cnt>-'C'.
**  If one is found, all keyboard events are flushed, and 'true' is returned.
**  We also  check for signals  just to  be safe.   Because signals are  only
**  delivered when the system is in control, e.g., when we call 'SystemTask',
**  there is no point to test for two interrupts within a second.
*/
#if SYS_MAC_SYC

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
#endif

#ifndef SYS_TNUMS_H                     /* various types                   */
# include       <TNums.h>
# define SYS_TNUMS_H
#endif

#ifndef SYS_LOWMEM_H                    /* variables in low memory:        */
# include       <LowMem.h>              /* 'LMGetTicks'                    */
# define SYS_LOWMEM_H
#endif

#ifndef SYS_OSUTILS_H                   /* system utils:                   */
# include       <OSUtils.h>             /* 'QHdr'                          */
# define SYS_OSUTILS_H
#endif

#ifndef SYS_OSEVENTS_H                  /* system events, low level:       */
# include       <OSEvents.h>            /* 'EvQEl', 'GetEvQHdr',           */
                                        /* 'FlushEvents'                   */
# define SYS_OSEVENTS_H
#endif

#ifndef SYS_EVENTS_H                    /* system events, high level:      */
# include       <Events.h>              /* 'EventRecord', 'GetNextEvent'   */
# define SYS_EVENTS_H
#endif

#ifndef SYS_LOMEM_H                     /* variables in low memory         */
# include       <LoMem.h>               /* 'SEvtEnb'                       */
# define SYS_LOMEM_H
#endif

#ifndef SYS_DESK_H
# include       <Desk.h>                /* 'SystemTask'                    */
# define SYS_DESK_H
#endif

UInt            syNrIntr;               /* number of interrupts            */

UInt            syIsIntrFreq  =  60;    /* frequency to test interrupts    */

UInt            syIsIntrCount =   0;    /* countdown to test interrupts    */

UInt            syIsBackFreq  = 600;    /* frequence background switching  */

UInt            syIsBackCount =   0;    /* countdown background switching  */


void syAnswerIntr (
    int                 signr )
{
    /* reinstall the signal handler                                        */
    signal( SIGINT, &syAnswerIntr );

    /* got one more interrupt                                              */
    syNrIntr = syNrIntr + 1;
}


UInt SyIsIntr ( void )
{
    UInt                syIsIntr;
    struct QHdr *       queue;
    struct EvQEl *      qentry;
    EventRecord         theEvent;

    /* don't check for interrupts every time 'SyIsIntr' is called          */
    if ( (*(unsigned long*)0x016A) <= syIsIntrCount )
        return 0;
    syIsIntrCount = (*(unsigned long*)0x016A) + syIsIntrFreq;

    /* allow for system activities                                         */
    if ( syIsBackCount < (*(unsigned long*)0x016A) ) {
        syIsBackCount = (*(unsigned long*)0x016A) + syIsBackFreq;
        SystemTask();
        SEvtEnb = false;
        GetNextEvent( activMask, &theEvent );
    }

    /* check for caught interrupts                                         */
    syIsIntr = (syNrIntr != 0);

    /* every caught interrupt leaves a <eof>, which we want to remove      */
    while ( syNrIntr ) {
        while ( getchar() != EOF ) ;
        clearerr( stdin );
        syNrIntr = syNrIntr - 1;
    }

    /* look through the event queue for <command>-'.' or <control>-'C'     */
    queue = GetEvQHdr();
    qentry = (struct EvQEl *)(queue->qHead);
    while ( qentry ) {
        if ( qentry->evtQWhat == keyDown
            &&   ( ((qentry->evtQModifiers & controlKey) != 0)
                && ((qentry->evtQMessage & charCodeMask) ==   3))
              || ( ((qentry->evtQModifiers & cmdKey    ) != 0)
                && ((qentry->evtQMessage & charCodeMask) == '.')) ) {
            syNrIntr++;
        }
        qentry = (struct EvQEl *)(qentry->qLink);
    }

    /* check for interrupts                                                */
    syIsIntr = syIsIntr || (syNrIntr != 0);

    /* flush away all keyboard events after an interrupt                   */
    if ( syNrIntr ) {
        FlushEvents( keyDownMask, 0 );
        syNrIntr = 0;
    }

    /* return whether an interrupt has happened                            */
    return syIsIntr;
}

#endif


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
#if ! (SYS_MAC_MPW || SYS_MAC_SYC)

void            syWinPut (
    Int                 fid,
    Char *              cmd,
    Char *              str )
{
    Int                 fd;             /* file descriptor                 */
    Char                tmp [130];      /* temporary buffer                */
    Char *              s;              /* pointer into the string         */
    Char *              t;              /* pointer into the temporary      */

    /* if not running under a window handler, don't do anything            */
    if ( ! SyWindow || 4 <= fid )
        return;

    /* get the file descriptor                                             */
    if ( fid == 0 || fid == 2 )  fd = fileno(syBuf[fid].echo);
    else                         fd = fileno(syBuf[fid].fp);

    /* print the cmd                                                       */
    write( fd, cmd, SyStrlen(cmd) );

    /* print the output line, duplicate '@' and handle <ctr>-<chr>         */
    s = str;  t = tmp;
    while ( *s != '\0' ) {
        if ( *s == '@' ) {
            *t++ = '@';  *t++ = *s++;
        }
        else if ( CTR('A') <= *s && *s <= CTR('Z') ) {
            *t++ = '@';  *t++ = *s++ - CTR('A') + 'A';
        }
        else {
            *t++ = *s++;
        }
        if ( 128 <= t-tmp ) {
            write( fd, tmp, t-tmp );
            t = tmp;
        }
    }
    if ( 0 < t-tmp ) {
        write( fd, tmp, t-tmp );
    }
}

#endif

#if SYS_MAC_MPW || SYS_MAC_SYC

void            syWinPut (
    Int                 fid,
    Char *              cmd,
    Char *              str )
{
}

#endif


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
#if ! (SYS_MAC_MPW || SYS_MAC_SYC)

Char            WinCmdBuffer [8000];

Char *          SyWinCmd (
    Char *              str,
    UInt                len )
{
    Char                buf [130];      /* temporary buffer                */
    Char *              s;              /* pointer into the string         */
    Char *              b;              /* pointer into the temporary      */
    UInt                i;              /* loop variable                   */

    /* if not running under a window handler, don't do nothing             */
    if ( ! SyWindow )
        return "I1+S52000000No Window Handler Present";

    /* compute the length of the (expanded) string (and ignore argument)   */
    len = 0;
    for ( s = str; *s != '\0'; s++ )
        len += 1 + (*s == '@' || (CTR('A') <= *s && *s <= CTR('Z')));

    /* send the length to the window handler                               */
    b = buf;
    for ( i = 0; i < 8; i++ ) {
        *b++ = (len % 10) + '0';
        len /= 10;
    }
    *b = '\0';
    syWinPut( 1, "@w", buf );

    /* send the string to the window handler                               */
    syWinPut( 1, "", str );

    /* read the length of the answer                                       */
    s = WinCmdBuffer;
    i = 10;
    do {
        while ( 0 < i ) {
            len = read( 0, s, i );
            i  -= len;
            s  += len;
        }
        if ( WinCmdBuffer[0] == '@' && WinCmdBuffer[1] == 'y' ) {
            for ( i = 2;  i < 10;  i++ )
                WinCmdBuffer[i-2] = WinCmdBuffer[i];
            s -= 2;
            i  = 2;
        }
    } while ( 0 < i );
    if ( WinCmdBuffer[0] != '@' || WinCmdBuffer[1] != 'a' )
        return "I1+S41000000Illegal Answer";
    for ( len = 0, i = 9;  1 < i;  i-- )
        len = len*10 + (WinCmdBuffer[i]-'0');

    /* read the arguments of the answer                                    */
    s = WinCmdBuffer;
    i = len;
    while ( 0 < i ) {
        len = read( 0, s, i );
        i  -= len;
        s  += len;
    }

    /* shrink '@@' into '@'                                                */
    for ( b = s = WinCmdBuffer;  0 < len;  len-- ) {
        if ( *s == '@' ) {
            s++;
            if ( *s == '@' )
                *b++ = '@';
            else if ( 'A' <= *s && *s <= 'Z' )
                *b++ = CTR(*s);
            s++;
        }
        else {
            *b++ = *s++;
        }
    }
    *b = 0;

    /* return the string                                                   */
    return WinCmdBuffer;
}

#endif

#if SYS_MAC_MPW || SYS_MAC_SYC

Char *          SyWinCmd (
    Char *              str,
    UInt                len )
{
    return 0;
}

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * * dynamic loading  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyFindOrLinkGapRootFile( <filename>, <crc>, <res>, <len> )   load or link
**
**  'SyFindOrLinkGapRootFile'  tries to find a GAP  file in the root area and
**  check  if   there is a corresponding    statically  or dynamically linked
**  module.  If the CRC matches this module  is loaded otherwise the filename
**  is returned.
*/


/****************************************************************************
**
*f  SyFindOrLinkGapRootFile( <filename>, <crc>, <res>, <len> )   BSD/Mach/USG
*/
#if SYS_BSD || SYS_MACH || SYS_USG

#include "compstat.h"

Int SyFindOrLinkGapRootFile (
    Char *              filename,
    UInt4               crc_gap,
    Char *              result, 
    Int                 len )
{
    UInt4               crc_dyn;
    UInt4               crc_sta;
    Int                 found_gap = 0;
    Int                 found_dyn = 0;
    Int                 found_sta = 0;
    Char *              tmp;
    Char                module [256];
    StructCompInitInfo* info_dyn;
    StructCompInitInfo* info_sta;
    Int                 k;

#if defined(SYS_HAS_DL_LIBRARY) || defined(SYS_HAS_RLD_LIBRARY)
    Char *              p;
    Char *              dot;
    Int                 pos;
    Int                 pot;
    CompInitFunc        init;
#endif

    /* find the GAP file                                                   */
    result[0] = '\0';
    tmp = SyFindGapRootFile(filename);
    if ( tmp ) {
        SyStrncat( result, tmp, len );
    }
    if ( result[0] ) {
        if ( SyIsReadableFile(result) ) {
            found_gap = 1;
        }
        else {
            result[0] = '\0';
        }
    }
    if ( ! SyUseModule ) {
        return ( found_gap ? 3 : 0 );
    }

    /* try to find any statically link module                              */
    module[0] = '\0';
    SyStrncat( module, "GAPROOT/", 8 );
    SyStrncat( module, filename, SyStrlen(filename) );
    for ( k = 0;  CompInitFuncs[k];  k++ ) {
        info_sta = (*(CompInitFuncs[k]))();
        if ( info_sta == 0 ) {
            continue;
        }
        if ( ! SyStrcmp( module, info_sta->magic2 ) ) {
            crc_sta   = info_sta->magic1;
            found_sta = 1;
            break;
        }
    }
    

    /* try to find any dynamically loadable module for filename            */
#if defined(SYS_HAS_DL_LIBRARY) || defined(SYS_HAS_RLD_LIBRARY)
    pos = SyStrlen(filename);
    p   = filename + pos;
    dot = 0;
    while ( filename <= p && *p != '/' ) {
        if ( *p == '.' ) {
            dot = p;
            pot = pos;
        }
        p--;
        pos--;
    }
    if ( dot ) {
        module[0] = '\0';
        SyStrncat( module, "bin/", 4 );
        SyStrncat( module, SyArchitecture, SyStrlen(SyArchitecture) );
        SyStrncat( module, "/compiled/", 10 );
        if ( p < filename ) {
            SyStrncat( module, dot+1, SyStrlen(dot+1) );
            SyStrncat( module, "/", 1 );
            SyStrncat( module, filename, pot );
            SyStrncat( module, ".so", 3 );
        }
        else {
            SyStrncat( module, filename, pos );
            SyStrncat( module, "/", 1 );
            SyStrncat( module, dot+1, SyStrlen(dot+1) );
            SyStrncat( module, filename+pos, pot-pos );
            SyStrncat( module, ".so", 3 );
        }
    }
    else {
        module[0] = '\0';
        SyStrncat( module, "bin/", 4 );
        SyStrncat( module, SyArchitecture, SyStrlen(SyArchitecture) );
        SyStrncat( module, "/compiled/", 1 );
        SyStrncat( module, filename, SyStrlen(filename) );
        SyStrncat( module, ".so", 3 );
    }
    tmp = SyFindGapRootFile(module);
    if ( tmp ) {
        init = SyLoadModule(tmp);
        if ( ( (Int)init & 1 ) == 0 ) {
            info_dyn  = (*init)();
            crc_dyn   = info_dyn->magic1;
            found_dyn = 1;
        }
    }
#endif

    /* now decide what to do                                               */
    if ( found_gap && found_dyn && crc_gap != crc_dyn ) {
        found_dyn = 0;
    }
    if ( found_gap && found_sta && crc_gap != crc_sta ) {
        found_sta = 0;
    }
    if ( found_gap && found_sta ) {
        *(StructCompInitInfo**)result = info_sta;
        return 2;
    }
    if ( found_gap && found_dyn ) {
        *(StructCompInitInfo**)result = info_dyn;
        return 1;
    }
    if ( found_gap ) {
        return 3;
    }
    if ( found_sta ) {
        *(StructCompInitInfo**)result = info_sta;
        return 2;
    }
    if ( found_dyn ) {
        *(StructCompInitInfo**)result = info_dyn;
        return 1;
    }
    return 0;
}

#endif


/****************************************************************************
**
*F  SyGAPCRC( <name> )  . . . . . . . . . . . . . . . . . . crc of a GAP file
**
**  This function should  be clever and handle  white spaces and comments but
**  one has to certain that such characters are not ignored in strings.
*/
static UInt4 syCcitt32[ 256 ] = 
{
0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L, 0xe0d5e91eL,
0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L, 0x90bf1d91L, 0x1db71064L,
0x6ab020f2L, 0xf3b97148L, 0x84be41deL, 0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L,
0x83d385c7L, 0x136c9856L, 0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL,
0x63066cd9L, 0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL, 0x35b5a8faL,
0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L, 0x45df5c75L, 0xdcd60dcfL,
0xabd13d59L, 0x26d930acL, 0x51de003aL, 0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L,
0x56b3c423L, 0xcfba9599L, 0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L,
0xb10be924L, 0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL, 0x9fbfe4a5L,
0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL, 0xe10e9818L, 0x7f6a0dbbL,
0x086d3d2dL, 0x91646c97L, 0xe6635c01L, 0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L,
0xf262004eL, 0x6c0695edL, 0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L,
0x12b7e950L, 0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L, 0x4adfa541L,
0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL, 0x346ed9fcL, 0xad678846L,
0xda60b8d0L, 0x44042d73L, 0x33031de5L, 0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL,
0x270241aaL, 0xbe0b1010L, 0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L,
0xce61e49fL, 0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L, 0x03b6e20cL,
0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L, 0x73dc1683L, 0xe3630b12L,
0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L, 0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L,
0x7d079eb1L, 0xf00f9344L, 0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL,
0x806567cbL, 0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L, 0xd6d6a3e8L,
0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L, 0xa6bc5767L, 0x3fb506ddL,
0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL, 0x36034af6L, 0x41047a60L, 0xdf60efc3L,
0xa867df55L, 0x316e8eefL, 0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L,
0x5268e236L, 0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L, 0x2cd99e8bL,
0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL, 0x026d930aL, 0x9c0906a9L,
0xeb0e363fL, 0x72076785L, 0x05005713L, 0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL,
0x0cb61b38L, 0x92d28e9bL, 0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L,
0xf1d4e242L, 0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL, 0x8f659effL,
0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L, 0xd70dd2eeL, 0x4e048354L,
0x3903b3c2L, 0xa7672661L, 0xd06016f7L, 0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL,
0xd9d65adcL, 0x40df0b66L, 0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL,
0x30b5ffe9L, 0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L, 0x5d681b02L,
0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL, 0x2d02ef8dL
};

UInt4 SyGAPCRC( Char * name )
{
    UInt4       crc;
    UInt4       old;
    UInt4       new;
    Int4        ch;
    Int         fid;
    Int         seen_nl;

    /* the CRC of a non existing file is 0                                 */
    fid = SyFopen( name, "r" );
    if ( fid == -1 ) {
        return 0;
    }

    /* read in the file byte by byte and compute the CRC                   */
    crc = 0x12345678L;
    while ( ( ch = fgetc(syBuf[fid].fp) ) != EOF ) {
        if ( ch == '\377' || ch == '\n' || ch == '\r' )
            ch = '\n';
        if ( ch == '\n' ) {
            if ( seen_nl )
                continue;
            else
                seen_nl = 1;
        }
        else
            seen_nl = 0;
        old = (crc >> 8) & 0x00FFFFFFL;
        new = syCcitt32[ ( (UInt4)( crc ^ ch ) ) & 0xff ];
        crc = old ^ new;
    }

    /* and close it again                                                  */
    SyFclose( fid );
    return crc;
}


/****************************************************************************
**
*F  SyLoadModule( <name> )  . . . . . . . . . . . . link a module dynamically
*/
#ifndef SYS_INIT_DYNAMIC
#define SYS_INIT_DYNAMIC        "_Init__Dynamic"
#endif


/****************************************************************************
**
*f  SyLoadModule( <name> )  . . . . . . . . . . . . . . . . . . . . .  dlopen
*/
#ifdef SYS_HAS_DL_LIBRARY

#include        <dlfcn.h>

#ifndef RTLD_LAZY
#define RTLD_LAZY               1
#endif

void * SyLoadModule ( Char * name )
{
    void *          init;
    void *          handle;

    handle = dlopen( name, RTLD_LAZY );
    if ( handle == 0 )  return (void*) 1;

    init = dlsym( handle, SYS_INIT_DYNAMIC );
    if ( init == 0 )  return (void*) 3;

    return init;
}

#endif


/****************************************************************************
**
*f  SyLoadModule( <name> )  . . . . . . . . . . . . . . . . . . . .  rld_load
*/
#ifdef SYS_HAS_RLD_LIBRARY

#include        <mach-o/rld.h>

void * SyLoadModule ( Char * name )
{
    Char *          names[2];
    unsigned long   init;

    names[0] = name;
    names[1] = 0;
    if ( rld_load( 0, 0,  names, 0 ) == 0 ) {
        return (void*) 1;
    }
    if ( rld_lookup( 0, SYS_INIT_DYNAMIC, &init ) == 0 ) {
        return (void*) 3;
    }
    if ( rld_forget_symbol( 0, SYS_INIT_DYNAMIC ) == 0 ) {
        return (void*) 5;
    }
    return (void*)init;
}

#endif


/****************************************************************************
**
*f  SyLoadModule( <name> )  . . . . . . . . . . . . . . . . . . .  no support
*/
#if !defined(SYS_HAS_RLD_LIBRARY) && !defined(SYS_HAS_DL_LIBRARY)

void * SyLoadModule ( Char * name )
{
    return (void*) 7;
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
        syWorkspace = (UInt***)sbrk( 4 - (int)sbrk(0) % 4 );
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
#ifndef SYS_STDLIB_H                    /* ANSI standard functions         */
# if SYS_ANSI
#  include      <stdlib.h>
# endif
# define SYS_STDLIB_H
#endif

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

        if ( ! SyIsReadableFile(SyInitfiles[i]) ) {
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
#ifndef SYS_STDLIB_H                    /* ANSI standard functions         */
# if SYS_ANSI
#  include      <stdlib.h>
# endif
# define SYS_STDLIB_H
#endif

#ifndef SYS_HAS_MISC_PROTO              /* ANSI/TRAD decl. from H&S 20, 13 */
extern char *  getenv ( SYS_CONST char * );
extern int     atoi ( SYS_CONST char * );
#endif

#ifndef SYS_HAS_MISC_PROTO              /* UNIX decl. from 'man'           */
extern int     isatty ( int );
extern char *  ttyname ( int );
#endif

#ifndef SYS_STDLIB_H                    /* ANSI standard functions         */
# if SYS_ANSI
#  include      <stdlib.h>
# endif
# define SYS_STDLIB_H
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

void            InitSystem (
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
    syBuf[1].fp = stdout;  setbuf( stdout, (char*)0 );
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
    syBuf[1].fp = stdout;  setbuf( stdout, (char*)0 );
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
    syBuf[1].fp = stdout;  setbuf( stdout, (char*)0 );
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
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_OS2_EMX || SYS_VMS
    if ( signal( SIGINT, SIG_IGN ) != SIG_IGN )
        signal( SIGINT, syAnswerIntr );
#endif
#if SYS_OS2_EMX
    /* under OS/2, pressing <ctr>-Break sometimes generates SIGBREAK       */
    signal( SIGBREAK, syAnswerIntr );
#endif
#if SYS_MAC_MPW
# ifdef SYS_HAS_TOOL
    signal( SIGINT, &syAnswerIntr );
# endif
#endif
#if SYS_MAC_SYC
    signal( SIGINT, &syAnswerIntr );
#endif

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


        /* '-b', supress the banner                                        */
        case 'b':
            SyBanner = ! SyBanner;
            break;


        /* '-g', Gasman should be verbose                                  */
        case 'g':
            SyMsgsFlagBags = (SyMsgsFlagBags + 1) % 3;
            break;


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


        /* '-B', name of the directory containing execs within root/bin    */
        case 'B':
            if ( argc < 3 ) {
                fputs("gap: option '-B' must have an argument.\n",stderr);
                goto usage;
            }
            SyArchitecture = argv[2];
            ++argv;  --argc;
            break;
        

        /* '-N', check for completion files in "init.g"                    */
        case 'N':
            SyCheckForCompletion = ! SyCheckForCompletion;
            break;


        /* '-D', debug loading of files                                    */
        case 'D':
            SyDebugLoading = ! SyDebugLoading;
            break;


        /* '-M', no dynamic/static modules                                 */
        case 'M':
            SyUseModule = ! SyUseModule;
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


        /* '-o <memory>', change the value of 'SyStorMin'                  */
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


        /* '-n', disable command line editing                              */
        case 'n':
            SyLineEdit = 0;
            break;


        /* '-f', force line editing                                        */
        case 'f':
            SyLineEdit = 2;
            break;


        /* '-q', GAP should be quiet                                       */
        case 'q':
            SyQuiet = ! SyQuiet;
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


        /* '-e', do not quit GAP on '<ctr>-D'                              */
        case 'e':
            SyCTRD = ! SyCTRD;
            break;


        /* '-p', start GAP package mode for output                         */
#if SYS_BSD || SYS_MACH || SYS_USG
        case 'p':
            SyWindow = ! SyWindow;
            break;
#endif


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


        /* '-E', running under Emacs under OS/2                            */
#if SYS_OS2_EMX
        case 'E':
            SyLineEdit = 2;
            syBuf[2].fp = stdin;
            syBuf[2].echo = stderr;
            break;
#endif


        /* '-r', don't read the '.gaprc' file                              */
        case 'r':
            gaprc = ! gaprc;
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
    if ( SyCompilePlease ) {
        SySystemInitFile[0] = 0;
    }

    /* the compiler will *not* read in the .gaprc file                     */
    if ( gaprc && ! SyCompilePlease ) {
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
    fputs("usage: gap [-l <libname>] [-h <hlpname>] [-m <memory>]\n",stderr);
    fputs("           [-g] [-n] [-q] [-b] [-x <nr>]  [-y <nr>]\n",stderr);
    fputs("           <file>...\n",stderr);
    fputs("  run the Groups, Algorithms and Programming system.\n",stderr);
    SyExit( 1 );
}


/****************************************************************************
**

*E  system.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
