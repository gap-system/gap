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
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  The  files   "system.c" and  "sysfiles.c"  contains all  operating system
**  dependent  functions.  This file contains  all system dependent functions
**  except file and stream operations, which are implemented in "sysfiles.c".
**  The following labels determine which operating system is actually used.
**
**  Under UNIX autoconf  is used to check  various features of  the operating
**  system and the compiler.  Should you have problem compiling GAP check the
**  file "bin/CPU-VENDOR-OS/config.h" after you have done a
**
**     ./configure ; make config
**
**  in the root directory.  And then do a
**
**     make compile
**
**  to compile and link GAP.
*/
#define INCLUDE_DECLARATION_PART
#include        "system.h"              /* system dependent part           */
#undef  INCLUDE_DECLARATION_PART

const char * Revision_system_c =
   "@(#)$Id$";

#include        "sysfiles.h"            /* file input/output               */
#include        <fcntl.h>


#ifndef SYS_STDIO_H                     /* standard input/output functions */
# include <stdio.h>
# define SYS_STDIO_H
#endif

#if !SYS_MAC_MWC
#include <dirent.h>
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
extern FILE * fopen ( const char *, const char * );
extern int    fclose ( FILE * );
extern void   setbuf ( FILE *, char * );
extern char * fgets ( char *, int, FILE * );
extern int    fputs ( const char *, FILE * );
#endif


#ifdef __MWERKS__
# if !SYS_MAC_MWC /* BH:__MWERKS__ is also true for  SYS_MAC_MWC */
#  define SYS_IS_MAC_MPW             1
#  define SYS_HAS_CALLOC_PROTO       1
# endif
#endif

#if SYS_MAC_MWC
# include "macdefs.h"
# include "macpaths.h"
# include "macte.h"
# include "macedit.h"
# include "maccon.h"
# include "macpaths.h"
# include "macintr.h"
#endif

#if SYS_DARWIN
#define task_self mach_task_self
#endif

/****************************************************************************
**
*V  SyKernelVersion  . . . . . . . . . . . . . . . .  name of the architecture
*/
const Char * SyKernelVersion = "4.4.9";

/****************************************************************************
*V  SyWindowsPath  . . . . . . . . . . . . . . . . . default path for Windows
*/
const Char * SyWindowsPath = "C:/gap4r4/";

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
UInt SyStackAlign = SYS_STACK_ALIGN;


/****************************************************************************
**
*V  SyArchitecture  . . . . . . . . . . . . . . . .  name of the architecture
*/
const Char * SyArchitecture = SYS_ARCH;


/****************************************************************************
**
*V  SyBanner  . . . . . . . . . . . . . . . . . . . . . . . . suppress banner
**
**  'SyBanner' determines whether GAP should print the banner.
**
**  Per default it  is true,  i.e.,  GAP prints the  nice  banner.  It can be
**  changed by the '-b' option to have GAP suppress the banner.
**
**  Put in this package because the command line processing takes place here.
*/
UInt SyBanner = 1;

/****************************************************************************
**
*V  SyCTRD  . . . . . . . . . . . . . . . . . . .  true if '<ctr>-D' is <eof>
*/
#if SYS_MAC_MWC
UInt SyCTRD = 0; /* doesn't make too much sense on a Mac */            
#else
UInt SyCTRD = 1;             
#endif

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
*V  SyCompileOutput . . . . . . . . . . . . . . . . . . into this output file
*/
Char SyCompileOptions [256] = {'\0'};


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
*V  SyGapRootPaths  . . . . . . . . . . . . . . . . . . . array of root paths
**
**  'SyGapRootPaths' conatins the  names   of the directories where   the GAP
**  files are located.
**
**  It is modified by the command line option -l.
**
**  It  is copied into the GAP  variable  called 'GAP_ROOT_PATHS' and used by
**  'SyFindGapRootFile'.
**
**  Each entry must end  with the pathname seperator, eg.  if 'init.g' is the
**  name of a library file 'strcat( SyGapRootPaths[i], "lib/init.g" );'  must
**  be a valid filename.
**
**  Put in this package because the command line processing takes place here.
**
#define MAX_GAP_DIRS 128
*/
Char SyGapRootPaths [MAX_GAP_DIRS] [512];


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
Char SyInitfiles [32] [512];

/****************************************************************************
**
*V  SyGapRCFilename . . . . . . . . . . . . . . . filename of the gaprc file
*/
Char SyGapRCFilename [512];

/****************************************************************************
**
*V  SyHasUserHome . . . . . . . . . .  true if user has HOME in environment
*V  SyUserHome . . . . . . . . . . . . .  path of users home (it is exists)
*/
Int SyHasUserHome = 0;
Char SyUserHome [256];

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
*V  SyAutoloadPackages  . . . . . . . . . . . . . automatically load packages
**
**  0: no 
**  1: yes
*/
UInt SyAutoloadPackages = 1;

/****************************************************************************
**
*V  SyBreakSuppress  . . . . . . . . never enter a break loop
**
**  0: no 
**  1: yes
*/
UInt SyBreakSuppress = 0;

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
**  See also getwindowsize() below.
**
**  Put in this package because the command line processing takes place here.
*/
UInt SyNrCols = 0;
UInt SyNrColsLocked = 0;

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
**
**  See also getwindowsize() below.
*/
UInt SyNrRows = 0;
UInt SyNrRowsLocked = 0;

/****************************************************************************
**
*V  SyQuiet . . . . . . . . . . . . . . . . . . . . . . . . . suppress prompt
**
**  'SyQuiet' determines whether GAP should print the prompt and the  banner.
**
**  Per default its false, i.e. GAP prints the prompt and  the  nice  banner.
**  It can be changed by the '-q' option to have GAP operate in silent  mode.
**
**  It is used by the functions in 'gap.c' to suppress printing the  prompts.
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
*V  SyInitializing                               set to 1 during library init
**
**  `SyInitializing' is set to 1 during the library intialization phase of
**  startup. It supresses some ebhaviours that may not be possible so early
**  such as homogeneity tests in the plist code.
*/

UInt SyInitializing = 0;


/****************************************************************************
**
*V  SyStorMax . . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorMax' is the maximal size of the workspace allocated by Gasman.
**  in kilobytes
**
**  This is per default 256 MByte,  which is often a  reasonable value.  It is
**  usually changed with the '-o' option in the script that starts GAP.
**
**  This is used in the function 'SyAllocBags'below.
**
**  Put in this package because the command line processing takes place here.
*/
Int SyStorMax = 256 * 1024L;
Int SyStorOverrun = 0;

/****************************************************************************
**
*V  SyStorKill . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorKill' is really the maximal size of the workspace allocated by 
**  Gasman. GAP exists before trying to allocate more than this amount
**  of memory.
**
**  This is per default disabled (i.e. = 0).
**  Can be changed with the '-K' option in the script that starts GAP.
**
**  This is used in the function 'SyAllocBags'below.
**
**  Put in this package because the command line processing takes place here.
*/
Int SyStorKill = 0L;


/****************************************************************************
**
*V  SyStorMin . . . . . . . . . . . . . .  default size for initial workspace
**
**  'SyStorMin' is the size of the initial workspace allocated by Gasman.
**
**  This is per default  24 Megabyte,  which  is  often  a  reasonable  value.
**  It is usually changed with the '-m' option in the script that starts GAP.
**
**  This value is used in the function 'SyAllocBags' below.
**
**  Put in this package because the command line processing takes place here.
*/
Int SyStorMin = SY_STOR_MIN;


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

#if SYS_MAC_MPW || SYS_MAC_MWC 
static UInt syStackSpace = 2L * 1024L * 1024L;
#endif

#if SYS_MAC_MWC	
char * SyMinStack = (char*) -1L;
#endif


/****************************************************************************
**
*V  SyFalseEqFail . . . . .. .compatibility option, identifies false and fail
**
** In GAP 3 there was no fail, and false was often used. This flag causes
** false and fail to be the same value
*/

UInt SyFalseEqFail = 0;


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
*f  SyTime()  . . . . . . . . . . . . . . . . . . . . . . . using `getrusage'
**
**  Use use   'getrusage'  if possible,  because  it gives  us  a much better
**  resolution. 
*/
#if ! SYS_IS_CYGWIN32
#if HAVE_GETRUSAGE

#ifndef SYS_RESOURCE_H
# include       <sys/time.h>            /* definition of 'struct timeval'  */
# include       <sys/resource.h>        /* definition of 'struct rusage'   */
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
UInt SyTimeSys ( void )
{
    struct rusage       buf;

    if ( getrusage( RUSAGE_SELF, &buf ) ) {
        fputs("gap: panic 'SyTimeSys' cannot get time!\n",stderr);
        SyExit( 1 );
    }
    return buf.ru_stime.tv_sec*1000 + buf.ru_stime.tv_usec/1000;
}
UInt SyTimeChildren ( void )
{
    struct rusage       buf;

    if ( getrusage( RUSAGE_CHILDREN, &buf ) ) {
        fputs("gap: panic 'SyTimeChildren' cannot get time!\n",stderr);
        SyExit( 1 );
    }
    return buf.ru_utime.tv_sec*1000 + buf.ru_utime.tv_usec/1000;
}
UInt SyTimeChildrenSys ( void )
{
    struct rusage       buf;

    if ( getrusage( RUSAGE_CHILDREN, &buf ) ) {
        fputs("gap: panic 'SyTimeChildrenSys' cannot get time!\n",stderr);
        SyExit( 1 );
    }
    return buf.ru_stime.tv_sec*1000 + buf.ru_stime.tv_usec/1000;
}

#endif
#endif


/****************************************************************************
**
*f  SyTime()  . . . . . . . . . . . . . . . . . . . . . . . .  BSD/Mach/DJGPP
**
**  For Berkeley UNIX the clock ticks in 1/60.  On some (all?) BSD systems we
**  can use 'getrusage', which gives us a much better resolution.
*/
#if ! HAVE_GETRUSAGE
#if SYS_BSD || SYS_MACH || SYS_MSDOS_DJGPP || HAVE_TIMES

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
*f  SyTime()  . . . . . . . . . . . . . . . . . . . . . . . .  CYGWIN
**
**  though the configuration claims that `getrusage' works, it does not. We
**  must use `times' and the factor is different than under BSD &c.
*/
#if SYS_IS_CYGWIN32

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
    return tbuf.tms_utime  - SyStartTime;
}

UInt SyTimeSys ( void )
{
  return 0;
}

UInt SyTimeChildren ( void )
{
  return 0;
}

UInt SyTimeChildrenSys ( void )
{
  return 0;
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
#if SYS_MAC_MPW

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
*f  SyTime()  . . . . . . . . . . . . . . . . . . . . . . . . . . . . MAC MWC
**
**  For  MAC with Metrowerks C we  use the 'Microseconds' function  and allow 
**  to stop the clock.
*/
#if SYS_MAC_MWC

# include       <Timer.h>  /* Microseconds */

UInt SyTime ( void )
{
	UnsignedWide w;
	unsigned long div, res;
	
	Microseconds (&w);
    
    div = ((w.hi % 1000) << 16) | (w.lo >> 16);
     
    res = (div / 1000) << 16;
 
    div = ((div % 1000) << 16) | (w.lo & ((1L<<16) - 1 ));
     
    res |= div/1000;
    
    return res - SyStartTime;
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
extern  char *          strncat ( char *, const char *, size_t );
extern  int             strcmp ( const char *, const char * );
extern  int             strncmp ( const char*, const char*, size_t );
extern  size_t          strlen ( const char * );
# else
extern  char *          strncat ( char *, const char *, int );
extern  int             strcmp ( const char *, const char * );
extern  int             strncmp ( const char *, const char *, int );
extern  int             strlen ( const char * );
# endif
#endif

UInt SyStrlen (
    const Char *         str )
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
    const Char *        str1,
    const Char *        str2 )
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
    const Char *        str1,
    const Char *        str2,
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
    const Char *        src,
    UInt                len )
{
    Char *              d;
    const Char *        s;  /*BH: CodeWarrior needs const */

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
    const Char *        src,
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
#if SYS_MAC_MWC
UInt syLastFreeWorkspace = 0;  
	/* amout of free workspace during last collection */
#endif

Int SyGasmanNumbers[2][7] = {{0,0,0,0,0,0,0},{0,0,0,0,0,0,0}};



void SyMsgsBags (
    UInt                full,
    UInt                phase,
    Int                 nr )
{
    Char                cmd [3];        /* command string buffer           */
    Char                str [32];       /* string buffer                   */
    Char                ch;             /* leading character               */
    UInt                i;              /* loop variable                   */
    Int                 copynr;         /* copy of <nr>                    */
    UInt                shifted;        /* non-zero if nr > 10^6 and so
					   has to be shifted down          */

    /* remember the numbers */
    if (phase > 0)
      {
	SyGasmanNumbers[full][phase] = nr;
	
	/* in a full GC clear the partial numbers */
	if (full)
	  SyGasmanNumbers[0][phase] = 0;
      }
    /* convert <nr> into a string with leading blanks                      */
    copynr = nr;
    ch = '0';  str[7] = '\0';
    shifted = (nr >= ((phase % 2) ? 10000000 : 1000000)) ? 1 : 0;
    if (shifted)
      {
	nr /= 1024;
      }
    if ((phase % 2) == 1 && shifted && nr > 1000000)
      {
	shifted++;
	nr /= 1024;
      }
      
    for ( i = ((phase % 2) == 1 && shifted) ? 6 : 7 ;
	  i != 0; i-- ) {
        if      ( 0 < nr ) { str[i-1] = '0' + ( nr) % 10;  ch = ' '; }
        else if ( nr < 0 ) { str[i-1] = '0' + (-nr) % 10;  ch = '-'; }
        else               { str[i-1] = ch;                ch = ' '; }
        nr = nr / 10;
    }
    nr = copynr;

    if ((phase % 2) == 1 && shifted == 1)
      str[6] = 'K';
    if ((phase % 2) == 1 && shifted == 2)
      str[6] = 'M';

    
#if SYS_MAC_MWC
 	if (phase == 5)
 		syLastFreeWorkspace = nr; /* save for status message in about box */
#endif

    /* ordinary full garbage collection messages                           */
    if ( 1 <= SyMsgsFlagBags && full ) {
        if ( phase == 0 ) { SyFputs( "#G  FULL ", 3 );                     }
        if ( phase == 1 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 2 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb live  " : "kb live  ", 3 ); }
        if ( phase == 3 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 4 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb dead  " : "kb dead  ", 3 ); }
        if ( phase == 5 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 6 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb free\n" : "kb free\n", 3 ); }
    }

    /* ordinary partial garbage collection messages                        */
    if ( 2 <= SyMsgsFlagBags && ! full ) {
        if ( phase == 0 ) { SyFputs( "#G  PART ", 3 );                     }
        if ( phase == 1 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 2 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb+live  ":"kb+live  ", 3 ); }
        if ( phase == 3 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 4 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb+dead  ":"kb+dead  ", 3 ); }
        if ( phase == 5 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 6 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb free\n":"kb free\n", 3 ); }
    }
#if !SYS_MAC_MWC
    /* package (window) mode full garbage collection messages              */
    if ( phase != 0 ) {
      shifted =   3 <= phase && nr >= (1 << 21);
      if (shifted)
	nr *= 1024;
      cmd[0] = '@';
      cmd[1] = ( full ? '0' : ' ' ) + phase;
      cmd[2] = '\0';
      i = 0;
      for ( ; 0 < nr; nr /=10 )
	str[i++] = '0' + (nr % 10);
      str[i++] = '+';
      str[i++] = '\0';
      if (shifted)
	str[i++] = 'k';
      syWinPut( 1, cmd, str );
    }
#endif
}



/****************************************************************************
**
*F  SyAllocBags( <size>, <need> ) . . . allocate memory block of <size> kilobytes
**
**  'SyAllocBags' is called from Gasman to get new storage from the operating
**  system.  <size> is the needed amount in kilobytes (it is always a multiple of
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
#if SYS_BSD||SYS_USG||SYS_OS2_EMX||SYS_MSDOS_DJGPP||SYS_TOS_GCC2||SYS_VMS||HAVE_SBRK

#ifndef SYS_HAS_MISC_PROTO              /* UNIX decl. from 'man'           */
extern  char * sbrk ( int );
#endif

UInt * * * syWorkspace = 0;
UInt       syWorksize;


UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret;
    UInt adjust = 0;

    /* force alignment on first call                                       */
    if ( syWorkspace == (UInt***)0 ) {
#ifdef SYS_IS_64_BIT
        syWorkspace = (UInt***)sbrk( 8 - (UInt)sbrk(0) % 8 );
#else
        syWorkspace = (UInt***)sbrk( 4 - (UInt)sbrk(0) % 4 );
#endif
        syWorkspace = (UInt***)sbrk( 0 );
    }

    /* get the storage, but only if we stay within the bounds              */
    /* if ( (0 < size && syWorksize + size <= SyStorMax) */
    /* first check if we would get above SyStorKill, if yes exit! */
    if ( SyStorKill != 0 && 0 < size && SyStorKill < syWorksize + size ) {
        fputs("gap: will not extend workspace above -K limit, bye!\n",stderr);
        SyExit( 2 );
    }
    if (0 < size )
      {
#ifndef SYS_IS_64_BIT
	while (size > 1024*1024)
	  {
	    ret = (UInt ***)sbrk(1024*1024*1024);
	    if (ret != (UInt ***)-1  && ret != (UInt***)((char*)syWorkspace + syWorksize*1024))
	      {
		sbrk(-1024*1024*1024);
		ret = (UInt ***)-1;
	      }
	    if (ret == (UInt ***)-1)
	      break;
	    size -= 1024*1024;
	    syWorksize += 1024*1024;
	    adjust++;
	  }
#endif
	ret = (UInt ***)sbrk(size*1024);
	if (ret != (UInt ***)-1  && ret != (UInt***)((char*)syWorkspace + syWorksize*1024))
	  {
	    sbrk(-size*1024);
	    ret = (UInt ***)-1;
	  }
	
      }
    else if  (size < 0 && SyStorMin <= syWorksize + size)  {
#ifndef SYS_IS_64_BIT
      while (size < -1024*1024)
	{
	  ret = (UInt ***)sbrk(-1024*1024*1024);
	  if (ret == (UInt ***)-1)
	    break;
	  size += 1024*1024;
	  syWorksize -= 1024*1024;
	}
#endif
	ret = (UInt ***)sbrk(size*1024);
    }
    else {
      ret = (UInt***)-1;
    }
    


    /* update the size info                                                */
    if ( ret != (UInt***)-1 ) {
        syWorksize += size;
       /* set the overrun flag if we became larger than SyStorMax */
       if ( SyStorMax != 0 && syWorksize  > SyStorMax)  {
	 SyStorOverrun = -1;
	 SyStorMax=syWorksize*2; /* new maximum */
	 InterruptExecStat(); /* interrupt at the next possible point */
       }
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
        return (UInt***)(((Char *)ret) - 1024*1024*1024*adjust);

}

#endif


/****************************************************************************
**
*f  SyAllocBags( <size>, <need> ) . . . . . . . . . . . . . . . . . . .  MACH
**
**  Under MACH virtual memory managment functions are used instead of 'sbrk'.
*/
#if SYS_MACH || HAVE_VM_ALLOCATE

#include <mach/mach.h>

vm_address_t syBase  = 0;
Int         sySize  = 0;

UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret = (UInt***)-1;
    vm_address_t        adr;	    
	    
    if ( SyStorKill != 0 && 0 < size && SyStorKill < sySize + size ) {
    	if (need) {
	        fputs("gap: will not extend workspace above -K limit, bye!\n",stderr);
    	    SyExit( 2 );
    	}  
    }
    /* check that <size> is divisible by <vm_page_size>                    */
    else if ( size*1024 % vm_page_size != 0 ) {
        fputs( "gap: memory block size is not a multiple of vm_page_size",
               stderr );
        SyExit(1);
    }

    /* check that we don't try to shrink uninialized memory                */
    else if ( size <= 0 && syBase == 0 ) {
        fputs( "gap: trying to shrink uninialized vm memory\n", stderr );
        SyExit(1);
    }

    /* allocate memory anywhere on first call                              */
    else if ( 0 < size && syBase == 0 ) {
        if ( vm_allocate(task_self(),&syBase,size*1024,TRUE) == KERN_SUCCESS ) {
            sySize = size;
            ret = (UInt***) syBase;
        }
    }

    /* don't shrink memory but mark it as deactivated                      */
    else if ( size < 0 && sySize + size > SyStorMin) {
        adr = (vm_address_t)( (char*) syBase + (sySize+size)*1024 );
        if ( vm_deallocate(task_self(),adr,-size*1024) == KERN_SUCCESS ) {
            ret = (UInt***)( (char*) syBase + sySize*1024 );
            sySize += size;
        }
    }

    /* get more memory from system                                         */
    else {
        adr = (vm_address_t)( (char*) syBase + sySize*1024 );
        if ( vm_allocate(task_self(),&adr,size*1024,FALSE) == KERN_SUCCESS ) {
            ret = (UInt***) ( (char*) syBase + sySize*1024 );
            sySize += size;
        }
    }

    /* test if the allocation failed                                       */
    if ( ret == (UInt***)-1 && need ) {
        fputs("gap: cannot extend the workspace any more\n",stderr);
        SyExit(1);
    }

    /* otherwise return the result (which could be 0 to indicate failure)  */
    if ( ret == (UInt***)-1 )
        return (UInt***) 0;
    else {
      	if ( sySize  > SyStorMax)  {
	 		SyStorOverrun = -1;
	 		SyStorMax=sySize*2; /* new maximum */
	 		InterruptExecStat(); /* interrupt at the next possible point */
       }
        return ret;
	}
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
  size = size*1024;
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
*f  SyAllocBags( <size>, <need> ) . . . . . . . . . . . . . . . . . . MAC MWC
**
**  For Mac under CodeWarrior, we use 'NewPtr to allocate as much memory
**  as possible at startup, then hand it on to GAP as required.
*/
#if SYS_MAC_MWC

UInt * * * 		syWorkspace;
long       		syWorksize = 0;  /* currently allocated amount in KB*/
long			SyStorLimit;     /* maximum allocable amount in KB*/
long            SyStorReserve = 512L; /* reserve memory if all other storage is gone */

UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
	UInt*** ret;
	long *p;
	unsigned long count;
	
    if ( (0 < size && (syWorksize + size <= SyStorMax || 
    				   (need && syWorksize + size <= SyStorLimit)))
      || (size < 0 && SyStorMin <= syWorksize + size) ) {
      
		ret = (UInt***)((char*)syWorkspace + (syWorksize << 10L) );
        syWorksize += size;
		syLastFreeWorkspace += size;
		
       /* set the overrun flag if we became larger than SyStorMax */
       if ( syWorksize > SyStorMax && size > 0)  {
			SyStorMax=syWorksize*2; /* new maximum */
	        if (SyStorMax > SyStorLimit - SyStorReserve) {
		        SyStorMax = SyStorLimit - SyStorReserve;
		        SyStorOverrun = -2;
            } else 
            	SyStorOverrun = -1;
	        InterruptExecStat(); /* interrupt at the next possible point */
       }
		/* clear memory, 256 bytes at a time */
 		p = (long *) ret;
		if (size > 0) {
			count = size * (1024UL / sizeof(*p) / 64);
			while (count--) {
				*p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; 
				*p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; 
				*p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0;
				*p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0;
				*p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0;
				*p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0;
				*p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; 
				*p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 0;
			}
		}
        return ret;
    }
    else 
 	   if ( need ) {
	        syEchos("gap: cannot extend the workspace any more\n",3);
	        SyExit( 1 );
	    } 
	return (UInt***) 0;
}
#endif


/****************************************************************************
**
*F  SyAbortBags( <msg> )  . . . . . . . . . abort GAP in case of an emergency
**
**  'SyAbortBags' is the function called by Gasman in case of an emergency.
*/
void SyAbortBags (
    Char *              msg )
{
    SyFputs( msg, 3 );
    SyExit( 2 );
}

/****************************************************************************
**
*F  SySleep( <secs> ) . . . . . . . . . . . . . .sleep GAP for <secs> seconds
**
**  NB Various OS events (like signals) might wake us up
**
*/
#if SYS_MAC_MWC

void SySleep ( UInt secs )
{
	Boolean oldGapIsIdle;
	long t;
	
	oldGapIsIdle = gGAPIsIdle;
	gGAPIsIdle = false;
	t = TickCount();
	
	while (TickCount() - t < 60*secs)
		ProcessEvent();
		
	gGAPIsIdle = oldGapIsIdle;
}

#else

void SySleep ( UInt secs )
{
  sleep( (unsigned int) secs );
}

#endif
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

#if !SYS_MAC_MWC
void SyExit (
    UInt                ret )
{
#if SYS_MAC_MPW
# ifndef SYS_HAS_TOOL
    fputs("gap: please use <option>-'Q' to close the window.\n",stdout);
# endif
#endif

#if SYS_IS_CYGWIN32
  if (ret!=0) {
    Int c;
    fputs("gap: Press <Enter> to end program\n",stderr);
    do {
	    c=SyGetch(1);   /* wait for the user to type <return> */
    } while (c!='\n' && c!=' ');
  }

#endif

    exit( (int)ret );
}
#endif

#if SYS_MAC_MWC
extern short syTmpVref; /* volume ref num for temp directory */
extern long syTmpDirId;  /* dir id for temp directory */

void            SyExit ( ret )
    UInt                ret;
{
	Int c;
	OSErr err;
	
	if (ret) {		 /* make sure the user can see the last error message(s) */
		OpenLogWindow ();
		SyFputs ("\nA fatal error has occurred. \n", 3);
		SyFputs ("GAP will quit now. Press the <return> key.\n", 3);
		FlushLog ();   /* discard pending input */
		do {
			SyIsInterrupted = false;
			c = SyGetch (2);   /* wait for the user to type <return> */
		} while (c != '\n' && c != 3);
	} 

	if (!gUserWantsToQuitGAP)
		DoQuit (false);
	
	/* delete temp files */
	if ((err = DeleteFolderAndContents (syTmpVref, syTmpDirId)) != noErr) 
		doDiagnosticMessage (23, err);
		
	ExitToShell ();
}
#endif

/****************************************************************************
**
*F  SySetGapRootPath( <string> )  . . . . . . . . .  set the root directories
**
**  'SySetGapRootPath' takes a string and modifies a list of root directories
**  in 'SyGapRootPaths'.
**
**  A  leading semicolon in  <string> means  that the list  of directories in
**  <string> is  appended  to the  existing list  of  root paths.  A trailing
**  semicolon means they are prepended.   If there is  no leading or trailing
**  semicolon, then the root paths are overwritten.
*/


/****************************************************************************
**
*f  SySetGapRootPath( <string> )  . . . . . . . . . . . . . . .  BSG/Mach/USG
*/
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_OS2_EMX || HAVE_SLASH_SEPARATOR \
    || SYS_MAC_MWC

void SySetGapRootPath( Char * string )
{
    Char *          p;
    Char *          q;
    Int             i;
    Int             n;

    /* set string to a default value if unset                              */
    if ( string == 0 ) {
        string = "./";
    }
 
    /* 
    ** check if we append, prepend or overwrite. 
    */ 
    if( string[0] == ';' ) {
        /* Count the number of root directories already present.           */
         n = 0; while( SyGapRootPaths[n][0] != '\0' ) n++;

         /* Skip leading semicolon.                                        */
         string++;

    }
    else if( string[ SyStrlen(string) - 1 ] == ';' ) {
        /* Count the number of directories in 'string'.                    */
        n = 0; p = string; while( *p ) if( *p++ == ';' ) n++;

        /* Find last root path.                                            */
        for( i = 0; i < MAX_GAP_DIRS; i++ ) 
            if( SyGapRootPaths[i][0] == '\0' ) break;
        i--;

        /* Move existing root paths to the back                            */
        if( i + n >= MAX_GAP_DIRS ) return;
        while( i >= 0 ) {
            SyGapRootPaths[i+n][0] = '\0';
            SyStrncat( SyGapRootPaths[i+n], SyGapRootPaths[i], 254 );
            i--;
        }

        n = 0;

    }
    else {
        /* Make sure to wipe out all possibly existing root paths          */
        for( i = 0; i < MAX_GAP_DIRS; i++ ) SyGapRootPaths[i][0] = '\0';
        n = 0;
    }

    /* unpack the argument                                                 */
    p = string;
    while ( *p ) {
        if( n >= MAX_GAP_DIRS ) return;

        q = SyGapRootPaths[n];
        while ( *p && *p != ';' ) {
            *q = *p++;

#if  SYS_IS_CYGWIN32
	    /* fix up for DOS */
	    if (*q == '\\')
	      *q = '/';
#endif
	    
	    q++;
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
    return; 
}

#endif

/****************************************************************************
**
*F  sySetGapRCFile()  . . . . . . . . . . . . .  set gaprc file name variable
*/
void sySetGapRCFile ( void )
{

    SyGapRCFilename[0] ='\0';
#if HAVE_DOTGAPRC
    if ( getenv("HOME") != 0 ) {
        SyStrncat(SyGapRCFilename,getenv("HOME"),sizeof(SyGapRCFilename)-1);
        SyStrncat( SyGapRCFilename, "/.gaprc",
            (UInt)(sizeof(SyGapRCFilename)-1-SyStrlen(SyGapRCFilename)));
    }
#endif

#if HAVE_GAPRC
    if ( getenv("HOME") != 0 ) {
        SyStrncat(SyGapRCFilename,getenv("HOME"),sizeof(SyGapRCFilename)-1);
        SyStrncat( SyGapRCFilename, "/gap.rc",
            (UInt)(sizeof(SyGapRCFilename)-1-SyStrlen(SyGapRCFilename)));
    }
#endif

#if SYS_VMS
    if ( getenv("GAP_INI") != 0 ) {
        SyStrncat(SyGapRCFilename,getenv("GAP_INI"),sizeof(SyGapRCFilename)-1);
    }
#endif


#if SYS_MAC_MPW || SYS_MAC_MWC
    if ( 1 ) {
        SyStrncat( SyGapRCFilename, "gap.rc",
            (UInt)(sizeof(SyGapRCFilename)-1-SyStrlen(SyGapRCFilename)));
    }
#endif

/* cygwin needs special treatment as the configure process recognizes as Unix */
#if SYS_IS_CYGWIN32
    if ( 1 ) {
        *SyGapRCFilename=(char)0;
        SyStrncat(SyGapRCFilename,"gap.rc",sizeof(SyGapRCFilename)-1);
    }
#endif

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
extern char *  getenv ( const char * );
extern int     atoi ( const char * );
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


#if SYS_MAC_MPW || SYS_MAC_MWC
# ifndef SYS_HAS_TOOL
#  ifndef SYS_MEMORY_H                  /* Memory stuff:                   */
#   include     <Memory.h>              /* 'GetApplLimit', 'SetApplLimit', */
#   define SYS_MEMORY_H                 /* 'MaxApplZone', 'StackSpace',    */
#  endif                                /* 'MaxMem'                        */
# endif
#endif


#if SYS_MAC_MPW || SYS_MAC_MWC
# ifndef SYS_HAS_TOOL
Char * syArgv [128];
Char   syArgl [1024];
# endif
#endif

#if SYS_MAC_MWC
# include <gestalt.h>
# include <folders.h>
#endif


static UInt ParseMemory( Char * s)
{
  UInt size;
  size = atoi(s);
  if ( s[SyStrlen(s)-1] == 'k'
       || s[SyStrlen(s)-1] == 'K' )
    size = size * 1024;
  if ( s[SyStrlen(s)-1] == 'm'
       || s[SyStrlen(s)-1] == 'M' )
    size = size * 1024 * 1024;
  if ( s[SyStrlen(s)-1] == 'g'
       || s[SyStrlen(s)-1] == 'G' )
    size = size * 1024* 1024 * 1024;
  return size;
}


#define MAX_OPTS 200
struct optval {
  Char *value;
  Int next;
};

struct optrec {
  Char key;
  Int vals;
};

static struct optrec opts[MAX_OPTS];
static  struct optval optvals[MAX_OPTS];
static UInt nopts = 0;
static UInt noptvals = 0;
static Char optvalsbuff[MAX_OPTS*256];
static UInt lenoptvalsbuff = 0;

static void recordOption( Char key, UInt nargs, Char **argv )
{
  UInt i,j,len;
  Int link,lastlink;
  for (i = 0; i < nopts && opts[i].key != key; i++)
    ;
  if (i == nopts)
    {
      opts[i].key = key;
      opts[i].vals = -1;
      nopts++;
    }
  link = opts[i].vals;
  lastlink = -1;
  while (link != -1)
    {
      lastlink = link;
      link = optvals[link].next;
    }
  if (lastlink == -1)
    opts[i].vals = noptvals;
  else
    optvals[lastlink].next = noptvals;
  optvals[noptvals].next = -1;
  if (nargs == 0)
    optvals[noptvals].value = NULL;
  else
    {
      optvals[noptvals].value = optvalsbuff + lenoptvalsbuff;
      optvalsbuff[lenoptvalsbuff] = '\0';
      for (j = 0; j < nargs; j++)
	{
	  len = SyStrlen(argv[j]);
	  SyStrncat(optvalsbuff + lenoptvalsbuff, argv[j], len);
	  optvalsbuff[lenoptvalsbuff + len]  = ' ';
	  lenoptvalsbuff += len + 1;
	  optvalsbuff[lenoptvalsbuff-1] = '\0';
	}
    }
  noptvals++;
  return;
}

Int getOptionCount( Char key)
{
  UInt i;
  Int link;
  UInt count;
  for (i = 0; i < nopts && opts[i].key != key; i++)
    ;
  if (i == nopts)
    return 0;
  link = opts[i].vals;
  count = 0;
  while (link != -1)
    {
      count++;
      link = optvals[link].next;
    }
  return count;
}

Char *getOptionArg( Char key, UInt which )
{
  UInt i;
  Int link;
  UInt count;
  for (i = 0; i < nopts && opts[i].key != key; i++)
    ;
  if (i == nopts)
    return NULL;
  link = opts[i].vals;
  count = 0;
  while (link != -1 && count < which)
    {
      count++;
      link = optvals[link].next;
    }
  if (count < which)
    return NULL;
  return optvals[link].value;
}
  
struct optInfo {
  Char key;
  Int (*handler)(Char **, void *);
  void *otherArg;
  UInt minargs;
};


static Int toggle( Char ** argv, void *Variable )
{
  UInt * variable = (UInt *) Variable;
  *variable = !*variable;
  return 0;
}

static Int storeString( Char **argv, void *Where )
{
  Char **where = (Char **)Where;
  *where = argv[0];
  return 1;
}

static Int storeMemory( Char **argv, void *Where )
{
  UInt *where = (UInt *)Where;
  *where = ParseMemory(argv[0]);
  return 1;
}

static Int storeMemory2( Char **argv, void *Where )
{
  UInt *where = (UInt *)Where;
  *where = ParseMemory(argv[0])/1024;
  return 1;
}

static Int processCompilerArgs( Char **argv, void * dummy)
{
  SyCompilePlease = 1;
  SyStrncat( SyCompileOutput, argv[0], sizeof(SyCompileOutput)-2 );
  SyStrncat( SyCompileInput, argv[1], sizeof(SyCompileInput)-2 );
  SyStrncat( SyCompileName, argv[2], sizeof(SyCompileName)-2 );
  SyCompileMagic1 = argv[3];
  return 4;
}

static Int unsetString( Char **argv, void *Where)
{
  *(Char **)Where = (Char *)0;
  return 0;
}

static Int forceLineEditing( Char **argv,void *Level)
{
  UInt level = (UInt)Level;
  SyLineEdit = level;
  return 0;
}

static Int rotateGasManVerbosity( Char **argv, void *dummy)
{
  SyMsgsFlagBags = (SyMsgsFlagBags + 1) % 3;
  return 0;
}

static Int returnVal ( Char **argv, void * Value)
{
  UInt value = (UInt) Value;
  return value;
}

static Int setScreenWidth( Char **argv, void * dummy)
{
            SyNrCols = atoi(argv[0]);
	    if (SyNrCols > 256) 
	      SyNrCols = 256;
	    SyNrColsLocked = 1;
#if SYS_MAC_MWC
	    SetLogWindowSize (-1, SyNrCols);
#endif
	    return 1;
}

static Int setScreenDepth( Char **argv, void * dummy)
{
            SyNrRows = atoi(argv[0]);
	    SyNrRowsLocked = 1;
#if SYS_MAC_MWC
	    SetLogWindowSize (SyNrRows,-1);
#endif
	    return 1;
}

#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2 || SYS_MAC_MPW || SYS_MAC_MWC
static Int storeInteger ( Char **argv, void *Where)
{
  Int *where = (Int *)Where;
  *where = atoi(argv[0]);
  return 1;
}
#endif

static Int setGapRootPath( Char **argv, void *Dummy)
{
  SySetGapRootPath( argv[0] );
  return 1;
}


static Int preAllocAmount;
static    UInt                gaprc = 1;      /* read the .gaprc file            */

struct optInfo options[] = {
  { 'A',  toggle, &SyAutoloadPackages, 0},
  { 'B',  storeString, &SyArchitecture, 1},
  { 'C',  processCompilerArgs, 0, 4},
  { 'D',  toggle, &SyDebugLoading, 0},
  { 'K',  storeMemory2, &SyStorKill, 1},
  { 'L',  storeString, &SyRestoring, 1},
  { 'M',  toggle, &SyUseModule, 0},
  { 'N',  toggle, &SyCheckForCompletion, 0},
  { 'O',  toggle, &SyFalseEqFail, 0},
#if SYS_MAC_MWC
  { 'P',  storeMemory, &gPrintBufferSize, 1},
#endif
  { 'R',  unsetString, &SyRestoring, 0},
  { 'T',  toggle, &SyBreakSuppress, 0},
  { 'U',  storeString, SyCompileOptions, 1},
#if SYS_MAC_MWC
  { 'W',  storeMemory, &gMaxLogSize, 1},
#endif
  { 'X',  toggle, &SyCheckCompletionCrcComp, 0 },
  { 'Y',  toggle, &SyCheckCompletionCrcRead, 0 },
  { 'a',  storeMemory, &preAllocAmount, 1 },
  { 'b',  toggle, &SyBanner, 0},
  { 'c',  storeMemory, &SyCacheSize, 1 },
  { 'e',  toggle, &SyCTRD, 0 },
  { 'f',  forceLineEditing, (void *)2, 0 },
  { 'g',  rotateGasManVerbosity, 0, 0 },
  { 'h',  returnVal, (void *) -2, 0},
  { 'i',  storeString, SySystemInitFile, 1},
  { 'l',  setGapRootPath, 0, 1},
  { 'm',  storeMemory2, &SyStorMin, 1 },
  { 'n',  forceLineEditing, 0, 0},
  { 'o',  storeMemory2, &SyStorMax, 1 },
  { 'p',  toggle, &SyWindow, 0 },
  { 'q',  toggle, &SyQuiet, 0 },
  { 'r',  toggle, &gaprc, 0 },
  { 'x',  setScreenWidth, 0, 1 },
  { 'y',  setScreenDepth, 0, 1 },
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2 || SYS_MAC_MPW || SYS_MAC_MWC
  { 'z',  storeInteger, &syIsIntrFreq, 0},
#endif
  { '\0',0,0}};


 

void InitSystem (
    Int                 argc,
    Char *              argv [] )
{
   /* Char *              ptr;  */     /* pointer to the pre'malloc'ated  */
   /* Char *              ptr1; */     /* more pre'malloc'ated  */
    Char *              *ptrlist;
    UInt                i;             /* loop variable                   */
    Int res;                       /* return from option processing function */
#if SYS_MAC_MWC
	KeyMap				theKeys;
	long				k;
	short 				s;
	Size				mem;
	Int					fid;
	Char 				syOptionsPath [1024] = "gap.options";
	char				match;
	OSErr 				err;
	FSSpec 				tmpFSSpec;
	char				first, last;  /* dummy for checking stack ptr */
	char *				ptr;
#endif

#if SYS_MAC_MPW
	preAllocAmount = 0;
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
        FPUTS_TO_STDERR("gap: cannot get enough stack space.\n");
        SyExit( 1 );
    }
# endif
#endif

    preAllocAmount = 100*1024;
    
#if SYS_MAC_MWC	
# if !TARGET_API_MAC_CARBON && !powerc 
	SyMinStack = GetApplLimit() - (syStackSpace - StackSpace()) + 1024;
    SetApplLimit( GetApplLimit() - (syStackSpace - StackSpace() + 1024) );
    /* compute the least possible value for the stack pointer */
    SyMinStack = (&last < &first ? &last : &first) - StackSpace () + 8192;
# else /* we need more reserve stack for the PPC, apparently */
    SyMinStack = (&last < &first ? &last : &first) - StackSpace () + 65536;
# endif
    MaxApplZone();
    
    /* look for a GAP options file in the GAP directory */
    err = FSMakeFSSpec (0, 0, "\pGAP options", &gGapOptionsFSSpec);
	
	/* if there is none for the local copy of GAP, try in the system preferences */
	if (err != noErr) {
		err = FindFolder (kOnSystemDisk, kPreferencesFolderType, kCreateFolder, &s, &k);
		if (err == noErr)
			err = FSMakeFSSpec (s, k, "\pGAP options", &gGapOptionsFSSpec);
		else
			err = dirNFErr; /* make sure it is not fnfErr */
	}
	
	/* get path to a GAP options file, create file if necessary */
	
	if (err == noErr || err == fnfErr)
		err = FSSpecToPath (&gGapOptionsFSSpec, (char*)&syOptionsPath, sizeof (syOptionsPath), 
			true, err == fnfErr);
	if (err != noErr && err != fnfErr)
		syOptionsPath[0] = '\0';
			
	InitEditor ();   /* initialize the editor */
    if ( StackSpace() < syStackSpace ) {
        SyFputs ("gap: cannot get enough stack space.\n",3);
        SyExit( 1 );
    }
	
	syIsIntrTime = TickCount();

    for (i = 0; i < 4; i++) {
    	syBuf[i].fp = -1;   /* must not be used !!!, hope for a bus error*/
    	syBuf[i].fromDoc = (char*)&LOGDOCUMENT;
    	syBuf[i].binary = false;
		syBuf[i].isTTY = 1;
		syBuf[i].bufno = -1;
	}    
	SyInFid = 0;  /* no input redirection */
    SyOutFid = 1; /* no output redirection */
	SyCanExec = (Gestalt (gestaltAppleEventsAttr, &k) == noErr
						&& (k & (1 << gestaltAppleEventsPresent)));
    if (Gestalt (gestaltCFMAttr,&k) == noErr) /* knows about dynamic libraries */
	    SyCanLoadDynamicModules = (k & (1<<gestaltCFMPresent));
	else
		SyCanLoadDynamicModules = false;
	if ((err = FindFolder (kOnSystemDisk, kTemporaryFolderType, kCreateFolder, &syTmpVref, &syTmpDirId))
			 == noErr)
		if ((err = SyFSMakeNewFSSpec (syTmpVref, syTmpDirId, "\pGAP temp", &tmpFSSpec)) == noErr)
			err = FSpDirCreate (&tmpFSSpec, 0, &syTmpDirId);
	if (err) {
        SyFputs ("#Warning: cannot create temporary folder.\n",3);
	}
#endif

    /* open the standard files                                             */
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_VMS || HAVE_TTYNAME
    syBuf[0].fp = fileno(stdin);
    syBuf[0].bufno = -1;
    if ( isatty( fileno(stdin) ) ) {
        if ( isatty( fileno(stdout) )
          && ! SyStrcmp( ttyname(fileno(stdin)), ttyname(fileno(stdout)) ) )
            syBuf[0].echo = fileno(stdout);
        else
            syBuf[0].echo = open( ttyname(fileno(stdin)), O_WRONLY );
	syBuf[0].isTTY = 1;
    }
    else {
        syBuf[0].echo = fileno(stdout);
	syBuf[0].isTTY = 0;
    }
    syBuf[1].echo = syBuf[1].fp = fileno(stdout); 
    syBuf[1].bufno = -1;
    if ( isatty( fileno(stderr) ) ) {
        if ( isatty( fileno(stdin) )
          && ! SyStrcmp( ttyname(fileno(stdin)), ttyname(fileno(stderr)) ) )
            syBuf[2].fp = fileno(stdin);
        else
            syBuf[2].fp = open( ttyname(fileno(stderr)), O_RDONLY );
        syBuf[2].echo = fileno(stderr);
	syBuf[2].isTTY = 1;
    }
    else
      syBuf[2].isTTY = 0;
    syBuf[2].bufno = -1;
    syBuf[3].fp = fileno(stderr);
    syBuf[3].bufno = -1;
    setbuf(stdin, (char *)0);
    setbuf(stdout, (char *)0);
    setbuf(stderr, (char *)0);
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
#if SYS_MAC_MPW
    syBuf[0].fp = stdin;
    syBuf[1].fp = stdout;
    syBuf[2].fp = stdin;
    syBuf[3].fp = stderr;
#endif

    for (i = 4; i < sizeof(syBuf)/sizeof(syBuf[0]); i++)
      syBuf[i].fp = -1;
    
    for (i = 0; i < sizeof(syBuffers)/sizeof(syBuffers[0]); i++)
	  syBuffers[i].inuse = 0;

#if !SYS_MAC_MWC    /* install the signal handler for '<ctr>-C'                            */
    SyInstallAnswerIntr();
#endif

#if SYS_MAC_MPW || SYS_MAC_MWC
# ifndef SYS_HAS_TOOL
    /* the Macintosh doesn't support command line options, read from file  */

    
#if SYS_MAC_MPW
    if ( (fid = SyFopen( "gap.options", "r" )) != -1 ) 
#else
    if ( (fid = SyFopen( syOptionsPath, "r" )) != -1 ) 
#endif
	{
	    ptr = syArgl;
        while ( SyFgets( ptr, (sizeof(syArgl)-1) - (ptr-syArgl), fid )
          && (ptr-syArgl) < (sizeof(syArgl)-1) ) {
            while ( *ptr != '#' && *ptr != '\0' )
                ptr++;
        }
        SyFclose( fid );
    } else
    	*syArgl = '\0';
    	        
    /* see whether the user wants to change preferences, i.e., whether 
       shift, cmd, ctrl, space, apple key pressed */
	GetKeys (theKeys);
	if (theKeys[1] & (1 | 4 | 8 | 512 | 32768L)) { 
		ModifyOptions (syArgl);
	}

    argc = 0;
    argv = syArgv;
    argv[argc++] = "gap";
    ptr = syArgl;
        
    while ( *ptr==' ' || *ptr=='\t' || *ptr=='\n' )  
    	*ptr++ = '\0';
    	
    while ( *ptr != '\0' ) {
         if (*ptr == '\"' || *ptr == '\'')
        	match = *ptr++;
        else 
        	match = ' ';
        argv[argc++] = ptr; 
        while ( *ptr!=match && *ptr!='\t' && *ptr!='\n' && *ptr!='\0' ) {
            if ( *ptr=='\\' )
                for ( k = 0; ptr[k+1] != '\0'; k++ )
                    ptr[k] = ptr[k+1];
            ptr++;
        }
        if (*ptr == match)
         	*ptr++ = '\0';
        else if (match != ' ')
        	SyFputs ("Error in command line argument: no matching quote found\n",3);
        while ( *ptr==' ' || *ptr=='\t' || *ptr=='\n' )  *ptr++ = '\0';
    }
# endif
#endif


    SySystemInitFile[0] = '\0';
    SyStrncat( SySystemInitFile, "lib/init.g", 10 );
#if SYS_IS_CYGWIN32
    SySetGapRootPath( SyWindowsPath );
#else

#ifdef SYS_DEFAULT_PATHS
    SySetGapRootPath( SYS_DEFAULT_PATHS );
#else
    SySetGapRootPath( "./" );
#endif

#endif

    /* scan the command line for options                                   */
    while ( argc > 1 && argv[1][0] == '-' ) {

        if ( SyStrlen(argv[1]) != 2 ) {
            FPUTS_TO_STDERR("gap: sorry, options must not be grouped '");
            FPUTS_TO_STDERR(argv[1]);  FPUTS_TO_STDERR("'.\n");
            goto usage;
        }


	for (i = 0; options[i].key != argv[1][1] && options[i].key; i++)
	  ;

	if (!options[i].key)
	  {
            FPUTS_TO_STDERR("gap: '");  FPUTS_TO_STDERR(argv[1]);
            FPUTS_TO_STDERR("' option is unknown.\n");
            goto usage;
	  }

	


	if (argc < 2 + options[i].minargs)
	  {
	    Char buf[2];
	    FPUTS_TO_STDERR("gap: option "); FPUTS_TO_STDERR(argv[1]);
	    FPUTS_TO_STDERR(" requires at least ");
	    buf[0] = options[i].minargs + '0';
	    buf[1] = '\0';
	    FPUTS_TO_STDERR(buf); FPUTS_TO_STDERR(" arguments\n");
	    goto usage;
	  }
	res = (*options[i].handler)(argv+2, options[i].otherArg);

	switch (res)
	  {
	  case -1: goto usage;
	  case -2: goto fullusage;
	  default: ;     /* fall through and continue */
	  }
	recordOption(argv[1][1], res,  argv+2);
	argv += 1 + res;
	argc -= 1 + res;

    }


    /* now that the user has had a chance to give -x and -y,
       we determine the size of the screen ourselves */
#if SYS_MAC_MWC
	GetLogWindowSize ();
#else
    getwindowsize();
#endif	

    /* fix max if it is lower than min                                     */
    if ( SyStorMax != 0 && SyStorMax < SyStorMin ) {
        SyStorMax = SyStorMin;
    }

    /* only check once                                                     */
    if ( SyCheckCompletionCrcComp ) {
        SyCheckCompletionCrcRead = 0;
    }

    /* when running in package mode set ctrl-d and line editing            */
    if ( SyWindow ) {
        SyLineEdit   = 1;
        SyCTRD       = 1;
#if !SYS_MAC_MWC
        syBuf[2].fp = fileno(stdin);  syBuf[2].echo = fileno(stdout);
        syBuf[3].fp = fileno(stdout);
#endif
        syWinPut( 0, "@p", "1." );
    }
   

#if SYS_MAC_MWC

    /* find out how much memory we can now allocate in the zone            */
	if (gPrintBufferSize < 32L*1024L)
		gEditorScratch = 32L*1024L;
	else 
		gEditorScratch = gPrintBufferSize;
			
	SyStorLimit = MaxMem( &mem );
	SyStorLimit -= gEditorScratch + gMaxLogSize;  

	/* make SyStorLimit divisible by the minimum allocatable unit */
#if GAPVER == 4
	SyStorLimit /= 1024L;
	SyStorLimit -= SyStorLimit % 512L;
#elif GAPVER == 3
	SyStorLimit -= SyStorLimit % 1024;
#endif

	/* try to set SyStorMax so that the user gets a warning before memory is too low */
	if (SyStorMax > SyStorLimit)
		SyStorMax = SyStorLimit - SyStorReserve;
;

    if ( SyStorMin <= 0 ) 
   	     SyStorMin = SyStorMax;

	syWorkspace = (UInt***) NewPtr (SyStorLimit*1024L);  /* allocate all we can get */
	
#if 0 /* sorry, no real options dialog box yet... */

    if ( SyStorMax >= SyStorMin && syWorkspace ) {   /* otherwise GAP won't run at all */
    /* see whether the user wants to change preferences */
		GetKeys (theKeys);
		if (theKeys[1] & 0x00008004) { /* is the command key down?*/
			if (SyStorMin > SyStorMax)
				SyStorMin = SyStorMax;
			GetOptions (true);   /* get options interactively */
			gaprc = SyGaprc;
		}
	}
#endif

    if ( SyStorMax < SyStorMin || !syWorkspace) {
            SyFputs(
        "gap: please use the 'Get Info' command in the Finder 'File' menu\n",  3 );  
            SyFputs(
        "     to increase the minimum amount of memory and the preferred amount of memory\n", 3);
            SyFputs (
        "     as described in the documentation of GAP for MacOS.\n", 3 );
            SyExit( 1 );
    }
	if (SyBanner && !SyCompilePlease) {
		if (SyRestoring)
			SyFputs ("Loading GAP workspace. Please be patient, this may take a while.\n\n", 1);
		OpenAboutBox (5);   /* show GAP's About ... box for 5 seconds*/
	}

#else
    /* premalloc stuff                                                     */
    /* allocate in small chunks, and write something to them
     * (the GNU clib uses mmap for large chunks and give it back to the
     * system after free'ing; also it seems that memory is only really 
     * allocated (pagewise) when it is first used)                     */
    ptrlist = (Char **)malloc((1+preAllocAmount/1000)*sizeof(Char*));
    for (i = 1; i*1000 < preAllocAmount; i++) {
      ptrlist[i-1] = (Char *)malloc( 1000 );
      if (ptrlist[i-1] != NULL) ptrlist[i-1][900] = 13;
    }
    for (i = 1; (i+1)*1000 < preAllocAmount; i++) 
      if (ptrlist[i-1] != NULL) free(ptrlist[i-1]);
    free(ptrlist);
       
   /* ptr = (Char *)malloc( preAllocAmount );
    ptr1 = (Char *)malloc(4);
    if ( ptr != 0 )  free( ptr ); */
#endif

    /* try to find 'LIBNAME/init.g' to read it upon initialization         */
    if ( SyCompilePlease || SyRestoring ) {
        SySystemInitFile[0] = 0;
    }

    /* the compiler will *not* read in the .gaprc file                     */
    if ( gaprc && ! ( SyCompilePlease || SyRestoring ) ) {
        sySetGapRCFile();
    }

#if HAVE_DOTGAPRC || HAVE_GAPRC
    /* the users home directory                                            */
    if ( getenv("HOME") != 0 ) {
        SyStrncat(SyUserHome, getenv("HOME"), sizeof(SyUserHome)-1);
        SyHasUserHome = 1;
    }
#endif

    /* use the files from the command line                                 */
    for ( i = 0;  i < sizeof(SyInitfiles)/sizeof(SyInitfiles[0]);  i++ ) {
        if ( SyInitfiles[i][0] == '\0' )
            break;
    }
    while ( argc > 1 ) {
        if ( i >= sizeof(SyInitfiles)/sizeof(SyInitfiles[0]) ) {
            FPUTS_TO_STDERR("gap: sorry, cannot handle so many init files.\n");
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

#if SYS_MAC_MPW
# ifndef SYS_HAS_TOOL
    /* find out how much memory we can now allocate in the zone            */
    if ( SyStorMin <= 0 ) {
        SyStorMin = MaxMem( &i ) - SyStorMin - 384*1024;
        if ( SyStorMin < 1024*1024 ) {
            FPUTS_TO_STDERR(
        "gap: please use the 'Get Info' command in the Finder 'Desk' menu\n",
                  stderr );
            FPUTS_TO_STDERR(
        "     to set the minimum amount of memory to at least 2560 KByte,\n",
                  stderr );
            FPUTS_TO_STDERR(
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
 FPUTS_TO_STDERR("usage: gap [OPTIONS] [FILES]\n");
 FPUTS_TO_STDERR("       run the Groups, Algorithms and Programming system, Version ");
 FPUTS_TO_STDERR(SyKernelVersion);
 FPUTS_TO_STDERR("\n");
 FPUTS_TO_STDERR("       use '-h' option to get help.\n");
 FPUTS_TO_STDERR("\n");
 SyExit( 1 );
  
fullusage:
 FPUTS_TO_STDERR("usage: gap [OPTIONS] [FILES]\n");
 FPUTS_TO_STDERR("       run the Groups, Algorithms and Programming system, Version ");
 FPUTS_TO_STDERR(SyKernelVersion);
 FPUTS_TO_STDERR("\n");
 FPUTS_TO_STDERR("\n");

 FPUTS_TO_STDERR("  -h          print this help and exit\n");
 FPUTS_TO_STDERR("  -b          disable/enable the banner\n");
 FPUTS_TO_STDERR("  -q          enable/disable quiet mode\n");
 FPUTS_TO_STDERR("  -e          disable/enable quitting on <ctr>-D\n");
 FPUTS_TO_STDERR("  -f          force line editing\n");
 FPUTS_TO_STDERR("  -n          prevent line editing\n");
 FPUTS_TO_STDERR("  -x <num>    set line width\n");
 FPUTS_TO_STDERR("  -y <num>    set number of lines\n");
#if SYS_OS2_EMX
 /* This flag does not exist? */
 FPUTS_TO_STDERR("  -E          running under Emacs under OS/2\n");
#endif

 FPUTS_TO_STDERR("\n");
 FPUTS_TO_STDERR("  -g          show GASMAN messages (full garbage collections)\n");
 FPUTS_TO_STDERR("  -g -g       show GASMAN messages (all garbage collections)\n");
 FPUTS_TO_STDERR("  -m <mem>    set the initial workspace size\n");
 FPUTS_TO_STDERR("  -o <mem>    set hint for maximal workspace size (GAP may allocate more)\n");
 FPUTS_TO_STDERR("  -K <mem>    set maximal workspace size (GAP never allocates more)\n");
 FPUTS_TO_STDERR("  -c <mem>    set the cache size value\n");
 FPUTS_TO_STDERR("  -a <mem>    set amount to pre-malloc-ate\n");
 FPUTS_TO_STDERR("              postfix 'k' = *1024, 'm' = *1024*1024, 'g' = *1024*1024*1024\n");

 FPUTS_TO_STDERR("\n");
 FPUTS_TO_STDERR("  -l <paths>  set the GAP root paths\n");
 FPUTS_TO_STDERR("  -r          disable/enable reading of the '.gaprc' file \n");
 FPUTS_TO_STDERR("  -A          disable/enable autoloading of GAP packages\n");
 FPUTS_TO_STDERR("  -B <name>   current architecture\n");
 FPUTS_TO_STDERR("  -D          enable/disable debugging the loading of library files\n");
 FPUTS_TO_STDERR("  -M          disable/enable loading of compiled modules\n");
 FPUTS_TO_STDERR("  -N          disable/enable check for completion files\n");
#if SYS_MAC_MWC
 FPUTS_TO_STDERR("  -P <mem>    set amount of memory reserved for printing\n");
#endif
 FPUTS_TO_STDERR("  -T          disable/enable break loop\n");
#if SYS_MAC_MWC
 FPUTS_TO_STDERR("  -W <mem>    set amount of memory available for GAP log window\n");
#endif
 FPUTS_TO_STDERR("  -X          enable/disable CRC for comp. files while reading\n");
 FPUTS_TO_STDERR("  -Y          enable/disable CRC for comp. files while completing\n");
 FPUTS_TO_STDERR("  -i <file>   change the name of the init file\n");

 FPUTS_TO_STDERR("\n");
 FPUTS_TO_STDERR("  -L <file>   restore a saved workspace\n");
 FPUTS_TO_STDERR("  -R          prevent restoring of workspace (ignoring -L)\n");

 FPUTS_TO_STDERR("\n");
#if SYS_BSD || SYS_MACH || SYS_USG
/* This flag is available on all systems, but only advertised for some? */
 FPUTS_TO_STDERR("  -p          enable/disable package output mode\n");
#endif
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2 || SYS_MAC_MPW || SYS_MAC_MWC
 FPUTS_TO_STDERR("  -z <freq>   set interrupt check frequency\n");
#endif
/* -C -U undocumented options to the compiler. 
   Also unadvertisted compatibility flag:
 FPUTS_TO_STDERR("  -O          enable/disable old behavior, fail := false\n");
*/

 FPUTS_TO_STDERR("  Boolean options (b,q,e,r,A,D,M,N,T,X,Y) toggle the current value\n");
 FPUTS_TO_STDERR("  each time they are called. Default actions are indicated first.\n");

 FPUTS_TO_STDERR("\n");
 SyExit( 1 );
}


/****************************************************************************
**
*E  system.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/

