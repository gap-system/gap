/****************************************************************************
**
*W  system.c                    GAP source                       Frank Celler
*W                                                         & Martin Schönert
*W                                                         & Dave Bayer (MAC)
*W                                                  & Harald Boegeholz (OS/2)
*W                                                         & Paul Doyle (VMS)
*W                                                  & Burkhard Höfling (MAC)
*W                                                    & Steve Linton (MS/DOS)
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
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


#include        "sysfiles.h"            /* file input/output               */
#include        "gasman.h"            
#include        <fcntl.h>


#ifndef SYS_STDIO_H                     /* standard input/output functions */
# include <stdio.h>
# define SYS_STDIO_H
#endif

#include <dirent.h>

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

#if HAVE_LIBREADLINE
#include        <readline/readline.h>   /* readline for interactive input  */
#endif

#ifndef SYS_HAS_STDIO_PROTO             /* ANSI/TRAD decl. from H&S 15     */
extern FILE * fopen ( const char *, const char * );
extern int    fclose ( FILE * );
extern void   setbuf ( FILE *, char * );
extern char * fgets ( char *, int, FILE * );
extern int    fputs ( const char *, FILE * );
#endif


#if SYS_DARWIN
#define task_self mach_task_self
#endif

/****************************************************************************
**
*V  SyKernelVersion  . . . . . . . . . . . . . . . .  name of the architecture
*/
const Char * SyKernelVersion = "4.5";

/****************************************************************************
*V  SyWindowsPath  . . . . . . . . . . . . . . . . . default path for Windows
*/
const Char * SyWindowsPath = "/cygdrive/c/gap4r5";

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
*V  SyCTRD  . . . . . . . . . . . . . . . . . . .  true if '<ctr>-D' is <eof>
*/
UInt SyCTRD;


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
UInt SyCacheSize;


/****************************************************************************
**
*V  SyCheckCRCCompiledModule  . . .  check crc while loading compiled modules
*/
Int SyCheckCRCCompiledModule;


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
Int SyCompilePlease;


/****************************************************************************
**
*V  SyDebugLoading  . . . . . . . . .  output messages about loading of files
*/
Int SyDebugLoading;


/****************************************************************************
**
*V  SyGapRootPaths  . . . . . . . . . . . . . . . . . . . array of root paths
**
**  'SyGapRootPaths' contains the  names   of the directories where   the GAP
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
*V  IgnoreGapRC . . . . . . . . . . . . . . . . . . . -r option for kernel
*V  DotGapPath  . . . . . . . . . . . . . . . . . . . path of ~/.gap 
**
*/
Int IgnoreGapRC;
Char DotGapPath[512];

/****************************************************************************
**
*V  SyHasUserHome . . . . . . . . . .  true if user has HOME in environment
*V  SyUserHome . . . . . . . . . . . . .  path of users home (it is exists)
*/
Int SyHasUserHome;
Char SyUserHome [256];

/****************************************************************************
**
*V  SyLineEdit  . . . . . . . . . . . . . . . . . . . .  support line editing
**
**  0: no line editing
**  1: line editing if terminal
**  2: always line editing (EMACS)
*/
UInt SyLineEdit;

/****************************************************************************
**
*V  ThreadUI  . . . . . . . . . . . . . . . . . . . .  support UI for threads
**
*/
UInt ThreadUI = 1;

/****************************************************************************
**
*V  SyNumProcessors  . . . . . . . . . . . . . . . . . number of logical CPUs
**
*/
#ifdef NUM_CPUS
UInt SyNumProcessors = NUM_CPUS;
#else
UInt SyNumProcessors = 4;
#endif



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
UInt SyMsgsFlagBags;


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
UInt SyNrCols;
UInt SyNrColsLocked;

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
UInt SyNrRows;
UInt SyNrRowsLocked;

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
UInt SyQuiet;


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

UInt SyInitializing;


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
Int SyStorMax;
Int SyStorOverrun;

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
Int SyStorKill;


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
Int SyStorMin;


/****************************************************************************
**
*V  SySystemInitFile  . . . . . . . . . . .  name of the system "init.g" file
*/
Char SySystemInitFile [256];


/****************************************************************************
**
*V  SyUseModule . . . . . check for dynamic/static modules in 'READ_GAP_ROOT'
*/
int SyUseModule;


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
UInt SyWindow;


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
int _stksize;
static UInt syStackSpace;
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
    return buf.ru_utime.tv_sec*1000 + buf.ru_utime.tv_usec/1000;
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
*F  SyIntString( <string> ) . . . . . . . . extract a C integer from a string
**
*/




#if HAVE_ATOL
Int SyIntString( const Char *string) {
  return atol (string);
}
#else
Int SyIntString( const Char *string) {
  Int x = 0;
  Int sign = 1;
  while (IsSpace(*string))
    string++;
  if (*string == '-')
    {
      sign = -1;
      string++;
    }
  else if (*string == '+')
    {
      string++;
    }
  while (IsDigit(*string)) {
    x *= 10;
    x += (*string - '0');
    string++;
  }
  return sign*x;
}


#endif



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

Int SyGasmanNumbers[2][9];

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
    static UInt         tstart = 0;

    /* remember the numbers */
    if (phase > 0)
      {
        SyGasmanNumbers[full][phase] = nr;
        
        /* in a full GC clear the partial numbers */
        if (full)
          SyGasmanNumbers[0][phase] = 0;
      }
    else
      {
        SyGasmanNumbers[full][0]++;
        tstart = SyTime();
      }
    if (phase == 6) 
      {
        UInt x = SyTime() - tstart;
        SyGasmanNumbers[full][7] = x;
        SyGasmanNumbers[full][8] += x;
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

static UInt SyAllocPool;

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

UInt * * * syWorkspace = NULL;
UInt       syWorksize = 0;

void *     POOL = NULL;

UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret;
    UInt adjust = 0;

    if (SyAllocPool > 0) {
      if (POOL == NULL) {
         POOL = malloc(SyAllocPool+8);
         if (POOL == NULL) {
           fputs("gap: cannot allocate initial memory, bye.\n", stderr);
           SyExit( 2 );
         }
         /* ensure alignment of start address */
         if ((UInt)POOL % 8 == 0) 
           syWorkspace = (UInt***)POOL;
         else
           syWorkspace = (UInt***)((Char *)POOL + (8-(UInt)POOL % 8));
      }
      /* get the storage, but only if we stay within the bounds              */
      /* if ( (0 < size && syWorksize + size <= SyStorMax) */
      /* first check if we would get above SyStorKill, if yes exit! */
      if ( need < 2 && SyStorKill != 0 && 0 < size 
                    && SyStorKill < syWorksize + size ) {
          fputs("gap: will not extend workspace above -K limit, bye!\n",stderr);
          SyExit( 2 );
      }
      if (size > 0) {
        if ((syWorksize+size)*1024 <= SyAllocPool) {
          ret = (UInt***)((char*)syWorkspace + syWorksize*1024);
        }
        else
          ret = (UInt***)-1;
      }
      else if  (size < 0 && (need >= 2 || SyStorMin <= syWorksize + size))  {
        ret = (UInt***)((char*)syWorkspace + syWorksize*1024);
      }
      else {
        ret = (UInt***)-1;
      }
    }
    else {



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
        if ( need < 2 && SyStorKill != 0 && 0 < size && SyStorKill < syWorksize + size ) {
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
                memset((void *)((char *)syWorkspace + syWorksize*1024), 0, 1024*1024*1024);
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
            if (ret != (UInt ***)-1)
              memset((void *)((char *)syWorkspace + syWorksize*1024), 0, 1024*size);
            
          }
        else if  (size < 0 && (need >= 2 || SyStorMin <= syWorksize + size))  {
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
        fputs("gap: cannot extend the workspace any more!\n",stderr);
        SyExit( 1 );
    }
    /* if we de-allocated the whole workspace then remember this */
    if (syWorksize == 0)
      syWorkspace = (UInt ***)0;

    /* otherwise return the result (which could be 0 to indicate failure)  */
    if ( ret == (UInt***)-1 )
        return 0;
    else
      {
        return (UInt***)(((Char *)ret) - 1024*1024*1024*adjust);
      }

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

vm_address_t syBase;
UInt         sySize = 0;
UInt * * *   syWorkspace = NULL;
void *       POOL = NULL;
 
UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret = (UInt***)-1;
    vm_address_t        adr;    

    if (SyAllocPool > 0) {
      if (POOL == NULL) {
         POOL = malloc(SyAllocPool+8);
         if (POOL == NULL) {
           fputs("gap: cannot allocate initial memory, bye.\n", stderr);
           SyExit( 2 );
         }
         /* ensure alignment of start address */
         if ((UInt)POOL % 8 == 0) 
           syWorkspace = (UInt***)POOL;
         else
           syWorkspace = (UInt***)((Char *)POOL + (8-(UInt)POOL % 8));
      }
      /* get the storage, but only if we stay within the bounds              */
      /* if ( (0 < size && sySize + size <= SyStorMax) */
      /* first check if we would get above SyStorKill, if yes exit! */
      if ( need < 2 && SyStorKill != 0 && 0 < size 
                    && SyStorKill < sySize + size ) {
          fputs("gap: will not extend workspace above -K limit, bye!\n",stderr);
          SyExit( 2 );
      }
      if (size > 0) {
        if ((sySize+size)*1024 <= SyAllocPool) {
          ret = (UInt***)((char*)syWorkspace + sySize*1024);
          sySize += size;
        }
        else
          ret = (UInt***)-1;
      }
      else if  (size < 0 && (need >= 2 || SyStorMin <= sySize + size))  {
        ret = (UInt***)((char*)syWorkspace + sySize*1024);
        sySize += size;
      }
      else {
        ret = (UInt***)-1;
      }
    }
    else {
        if ( SyStorKill != 0 && 0 < size && SyStorKill < 1024*(sySize + size) ) {
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
            fputs("gap: cannot extend the workspace any more!!\n",stderr);
            SyExit(1);
        }
    }

    /* otherwise return the result (which could be 0 to indicate failure)  */
    if ( ret == (UInt***)-1 ){
        if (need) { 
            fputs("gap: cannot extend the workspace any more!!!\n",stderr);
            SyExit( 1 );
        }
        return (UInt***) 0;
    } 
    else {
        if (sySize  > SyStorMax)  {
            SyStorOverrun = -1;
            SyStorMax=sySize*2; /* new maximum */
            InterruptExecStat(); /* interrupt at the next possible point */
       }
     }
    return ret;
}

#endif


/****************************************************************************
**
*F  SyAbortBags( <msg> )  . . . . . . . . . abort GAP in case of an emergency
**
**  'SyAbortBags' is the function called by Gasman in case of an emergency.
*/
void SyAbortBags (
    const Char *        msg )
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
void SySleep ( UInt secs )
{
  sleep( (unsigned int) secs );
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

void SyExit (
    UInt                ret )
{
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
#if SYS_BSD || SYS_MACH || SYS_USG || SYS_OS2_EMX || HAVE_SLASH_SEPARATOR 

void SySetGapRootPath( const Char * string )
{
    const Char *          p;
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


typedef struct { Char symbol; UInt value; } sizeMultiplier;

sizeMultiplier memoryUnits[]= {
  {'k', 1024},
  {'K', 1024},
  {'m', 1024*1024},
  {'M', 1024*1024},
  {'g', 1024*1024*1024},
  {'G', 1024*1024*1024},
#ifdef SYS_IS_64_BIT
  {'t', 1024UL*1024*1024*1024},
  {'T', 1024UL*1024*1024*1024},
  {'p', 1024UL*1024*1024*1024*1024}, /* you never know */
  {'P', 1024UL*1024*1024*1024*1024},
#endif
};

static UInt ParseMemory( Char * s)
{
  UInt size  = atoi(s);
  Char symbol =  s[SyStrlen(s)-1];
  UInt i;
  UInt maxmem;
#ifdef SYS_IS_64_BIT
  maxmem = 15000000000000000000UL;
#else
  maxmem = 4000000000UL;
#endif
  
  for (i = 0; i < sizeof(memoryUnits)/sizeof(memoryUnits[0]); i++) {
    if (symbol == memoryUnits[i].symbol) {
      UInt value = memoryUnits[i].value;
      if (size > maxmem/value)
        size = maxmem;
      else
        size *= value;
      return size;
    }      
  }
  if (!IsDigit(symbol))
    FPUTS_TO_STDERR("Unrecognised memory unit ignored");
  return size;
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

static Int storePosInteger( Char **argv, void *Where )
{
  UInt *where = (UInt *)Where;
  UInt n;
  Char *p = argv[0];
  n = 0;
  while (isdigit(*p)) {
    n = n * 10 + (*p-'0');
    p++;
  }
  if (p == argv[0] || *p || n == 0)
    FPUTS_TO_STDERR("Argument not a positive integer");
  *where = n;
  return 1;
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

static Int setGapRootPath( Char **argv, void *Dummy)
{
  SySetGapRootPath( argv[0] );
  return 1;
}


static Int preAllocAmount;

/* These are just the options that need kernel processing. Additional options will be 
   recognised and handled in the library */

struct optInfo options[] = {
  { 'B',  storeString, &SyArchitecture, 1}, /* default architecture needs to be passed from kernel 
                                               to library. Might be needed for autoload of compiled files */
  { 'C',  processCompilerArgs, 0, 4}, /* must handle in kernel */
  { 'D',  toggle, &SyDebugLoading, 0}, /* must handle in kernel */
  { 'K',  storeMemory2, &SyStorKill, 1}, /* could handle from library with new interface */
  { 'L',  storeString, &SyRestoring, 1}, /* must be handled in kernel  */
  { 'M',  toggle, &SyUseModule, 0}, /* must be handled in kernel */
  { 'X',  toggle, &SyCheckCRCCompiledModule, 0}, /* must be handled in kernel */
  { 'R',  unsetString, &SyRestoring, 0}, /* kernel */
  { 'U',  storeString, SyCompileOptions, 1}, /* kernel */
  { 'a',  storeMemory, &preAllocAmount, 1 }, /* kernel -- is this still useful */
  { 'c',  storeMemory, &SyCacheSize, 1 }, /* kernel, unless we provided a hook to set it from library, 
                                           never seems to be useful */
  { 'e',  toggle, &SyCTRD, 0 }, /* kernel */
  { 'f',  forceLineEditing, (void *)2, 0 }, /* probably library now */
  { 'i',  storeString, SySystemInitFile, 1}, /* kernel */
  { 'l',  setGapRootPath, 0, 1}, /* kernel */
  { 'm',  storeMemory2, &SyStorMin, 1 }, /* kernel */
  { 'r',  toggle, &IgnoreGapRC, 0 }, /* kernel */
  { 's',  storeMemory, &SyAllocPool, 1 }, /* kernel */
  { 'n',  forceLineEditing, 0, 0}, /* prob library */
  { 'o',  storeMemory2, &SyStorMax, 1 }, /* library with new interface */
  { 'p',  toggle, &SyWindow, 0 }, /* ?? */
  { 'q',  toggle, &SyQuiet, 0 }, /* ?? */
  { 'S',  toggle, &ThreadUI, 0 }, /* Thread UI */
  { 'P',  storePosInteger, &SyNumProcessors, 1 }, /* Thread UI */
#if SYS_MSDOS_DJGPP || SYS_TOS_GCC2 
  { 'z',  storeInteger, &syIsIntrFreq, 0},
#endif
  { '\0',0,0}};


Char ** SyOriginalArgv;
UInt SyOriginalArgc;

 

void InitSystem (
    Int                 argc,
    Char *              argv [] )
{
    Char *              *ptrlist;
    UInt                i;             /* loop variable                   */
    Int res;                       /* return from option processing function */

    /* Initialize global and static variables. Do it here rather than
       with initializers to allow for restart */
    /* SyBanner = 1; */
    SyCTRD = 1;             
    SyCacheSize = 0;
    SyCheckCRCCompiledModule = 0;
    SyCompilePlease = 0;
    SyDebugLoading = 0;
    SyHasUserHome = 0;
    SyLineEdit = 1;
    /* SyAutoloadPackages = 1; */
    /*  SyBreakSuppress = 0; */
    SyMsgsFlagBags = 0;
    SyNrCols = 0;
    SyNrColsLocked = 0;
    SyNrRows = 0;
    SyNrRowsLocked = 0;
    SyQuiet = 0;
    SyInitializing = 0;
    SyStorMax = 512*1024L;
    SyAllocPool = 0;
    SyStorOverrun = 0;
    SyStorKill = 0;
    SyStorMin = SY_STOR_MIN;
    SyUseModule = 1;
    SyWindow = 0;
#if SYS_TOS_GCC2
# define __NO_INLINE__
    _stksize = 64 * 1024;   /* GNU C, amount of stack space    */
    syStackSpace = 64 * 1024;
#endif

    for (i = 0; i < 2; i++) {
      UInt j;
      for (j = 0; j < 7; j++) {
        SyGasmanNumbers[i][j] = 0;
      }
    }

#if SYS_BSD||SYS_USG||SYS_OS2_EMX||SYS_MSDOS_DJGPP||SYS_TOS_GCC2||SYS_VMS||HAVE_SBRK
    syWorkspace = (UInt ***)0;
#endif
#if SYS_MACH || HAVE_VM_ALLOCATE
    syBase = 0;
    sySize = 0;
#endif
    /*  nopts = 0;
    noptvals = 0;
    lenoptvalsbuff = 0;
    gaprc = 1; */

    preAllocAmount = 4*1024*1024;
    
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

    for (i = 4; i < sizeof(syBuf)/sizeof(syBuf[0]); i++)
      syBuf[i].fp = -1;
    
    for (i = 0; i < sizeof(syBuffers)/sizeof(syBuffers[0]); i++)
          syBuffers[i].inuse = 0;

#if HAVE_LIBREADLINE
    rl_initialize ();
#endif
    
    SyInstallAnswerIntr();

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

    /* save the original command line for export to GAP */
    SyOriginalArgc = argc;
    SyOriginalArgv = argv;

    /* scan the command line for options that we have to process in the kernel */
    /* we just scan the whole command line looking for the keys for the options we recognise */
    /* anything else will presumably be dealt with in the library */
    while ( argc > 1 )
      {
        if (argv[1][0] == '-' ) {

          if ( SyStrlen(argv[1]) != 2 ) {
            FPUTS_TO_STDERR("gap: sorry, options must not be grouped '");
            FPUTS_TO_STDERR(argv[1]);  FPUTS_TO_STDERR("'.\n");
            goto usage;
          }


          for (i = 0; options[i].key != argv[1][1] && options[i].key; i++)
            ;

        


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
          if (options[i].handler) {
            res = (*options[i].handler)(argv+2, options[i].otherArg);
            
            switch (res)
              {
              case -1: goto usage;
                /*            case -2: goto fullusage; */
              default: ;     /* fall through and continue */
              }
          }
          else
            res = options[i].minargs;
          /*    recordOption(argv[1][1], res,  argv+2); */
          argv += 1 + res;
          argc -= 1 + res;
          
        }
        else {
          argv++;
          argc--;
        }
          
      }


    /* now that the user has had a chance to give -x and -y,
       we determine the size of the screen ourselves */
    getwindowsize();

    /* fix max if it is lower than min                                     */
    if ( SyStorMax != 0 && SyStorMax < SyStorMin ) {
        SyStorMax = SyStorMin;
    }

    /* when running in package mode set ctrl-d and line editing            */
    if ( SyWindow ) {
      /*         SyLineEdit   = 1;
                 SyCTRD       = 1; */
        syBuf[2].fp = fileno(stdin);  syBuf[2].echo = fileno(stdout);
        syBuf[3].fp = fileno(stdout);
        syWinPut( 0, "@p", "1." );
    }
   

    if (SyAllocPool == 0) {
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
    }

    /* try to find 'LIBNAME/init.g' to read it upon initialization         */
    if ( SyCompilePlease || SyRestoring ) {
        SySystemInitFile[0] = 0;
    }

    /* the compiler will *not* read in the .gaprc file                     
    if ( gaprc && ! ( SyCompilePlease || SyRestoring ) ) {
        sySetGapRCFile();
    }
    */

#if HAVE_DOTGAPRC || HAVE_GAPRC
    /* the users home directory                                            */
    if ( getenv("HOME") != 0 ) {
        SyUserHome[0] = '\0';
        SyStrncat(SyUserHome, getenv("HOME"), sizeof(SyUserHome)-1);
        SyHasUserHome = 1;
        if (!IgnoreGapRC) {
# if SYS_IS_DARWIN
            DotGapPath[0] = '\0';
            SyStrncat(DotGapPath, getenv("HOME"), sizeof(DotGapPath)-26);
            SyStrncat(DotGapPath+SyStrlen(DotGapPath), "/Library/Preferences/GAP;", 26);
            SySetGapRootPath(DotGapPath);
# endif
            DotGapPath[0] = '\0';
          SyStrncat(DotGapPath, getenv("HOME"), sizeof(DotGapPath)-6);
          SyStrncat(DotGapPath+SyStrlen(DotGapPath), "/.gap;", 6);
          SySetGapRootPath(DotGapPath);
        }
        /* and in this case we can also expand paths which start
           with a tilde ~ */
        for (i = 0; i < MAX_GAP_DIRS && SyGapRootPaths[i][0]; i++) {
          if (SyGapRootPaths[i][0] == '~' && 
              SyStrlen(SyUserHome)+SyStrlen(SyGapRootPaths[i]) < 512) {
            memmove(SyGapRootPaths[i]+SyStrlen(SyUserHome),
                    /* don't copy the ~ but the trailing '\0' */
                    SyGapRootPaths[i]+1, SyStrlen(SyGapRootPaths[i]));
            memcpy(SyGapRootPaths[i], SyUserHome, SyStrlen(SyUserHome));
          }
        }
    }
#endif


#if !HAVE_GETRUSAGE
    /* start the clock                                                     */
    SyStartTime = SyTime();
#endif



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
}

static void Merge(char *to, char *from1, unsigned size1, char *from2,
  unsigned size2, unsigned width, int (*lessThan)(const void *a, const void *b))
{
  while (size1 && size2) {
    if (lessThan(from1, from2)) {
      memcpy(to, from1, width);
      from1 += width;
      size1--;
    } else {
      memcpy(to, from2, width);
      from2 += width;
      size2--;
    }
    to += width;
  }
  if (size1)
    memcpy(to, from1, size1*width);
  else
    memcpy(to, from2, size2*width);
}

static void MergeSortRecurse(char *data, char *aux, unsigned count, unsigned width,
  int (*lessThan)(const void *a, const void *))
{
  unsigned nleft, nright;
  /* assert(count > 1); */
  if (count == 2) {
    if (!lessThan(data, data+width))
    {
      memcpy(aux, data, width);
      memcpy(data, data+width, width);
      memcpy(data+width, aux, width);
    }
    return;
  }
  nleft = count/2;
  nright = count-nleft;
  if (nleft > 1)
    MergeSortRecurse(data, aux, nleft, width, lessThan);
  if (nright > 1)
    MergeSortRecurse(data+nleft*width, aux+nleft*width, nright, width, lessThan);
  memcpy(aux, data, count*width);
  Merge(data, aux, nleft, aux+nleft*width, nright, width, lessThan);
}

/****************************************************************************
**
*F  MergeSort() . . . . . . . . . . . . . . . sort an array using mergesort.
**
**  MergeSort() sorts an array of 'count' elements of individual size 'width'
**  with ordering determined by the parameter 'lessThan'. The 'lessThan'
**  function is to return a non-zero value if the first argument is less
**  than the second argument, zero otherwise.
*/

void MergeSort(void *data, unsigned count, unsigned width,
  int (*lessThan)(const void *a, const void *))
{
  char *aux = alloca(count * width);
  if (count > 1)
    MergeSortRecurse(data, aux, count, width, lessThan);
}


/****************************************************************************
**
*E  system.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/

