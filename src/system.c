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
*/

#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>

#include <src/gap.h>                    /* get UserHasQUIT */

#include <src/sysfiles.h>               /* file input/output */
#include <src/gasman.h>            
#include <fcntl.h>


#include <stdio.h>                      /* standard input/output functions */
#include <stdlib.h>                     /* ANSI standard functions */
#include <string.h>                     /* string functions */

#include <assert.h>
#include <dirent.h>
#include <time.h>

#include <unistd.h>                     /* definition of 'R_OK' */


#if HAVE_LIBREADLINE
#include <readline/readline.h>          /* readline for interactive input */
#endif

#include <sys/types.h>

#include <sys/time.h>                   /* definition of 'struct timeval' */

#if HAVE_SYS_RESOURCE_H
#include <sys/resource.h>               /* definition of 'struct rusage' */
#endif

#if HAVE_MADVISE
#include <sys/mman.h>
#endif

#if SYS_IS_DARWIN
#include <mach/mach_time.h>
#endif

/****************************************************************************
**  The following function is from profile.c. We put a prototype here
**  Rather than #include <src/profile.h> to avoid pulling in large chunks
**  of the GAP type system
*/    
Int enableProfilingAtStartup( Char **argv, void * dummy);
Int enableCodeCoverageAtStartup( Char **argv, void * dummy);

/****************************************************************************
**
*V  SyKernelVersion  . . . . . . . . . . . . . . . hard coded kernel version
** do not edit the following line. Occurences of `4.dev' and `today'
** will be replaced by string matching by distribution wrapping scripts.
*/
const Char * SyKernelVersion = "4.dev";

/****************************************************************************
*V  SyWindowsPath  . . . . . . . . . . . . . . . . . default path for Windows
** do not edit the following line. Occurences of `gap4dev'
** will be replaced by string matching by distribution wrapping scripts.
*/
const Char * SyWindowsPath = "/cygdrive/c/gap4dev";

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
*V  SyCheckCRCCompiledModule  . . .  check crc while loading compiled modules
*/
Int SyCheckCRCCompiledModule;


/****************************************************************************
**
*V  SyCompileInput  . . . . . . . . . . . . . . . . . .  from this input file
*/
Char SyCompileInput[GAP_PATH_MAX];


/****************************************************************************
**
*V  SyCompileMagic1 . . . . . . . . . . . . . . . . . . and this magic string
*/
Char * SyCompileMagic1;


/****************************************************************************
**
*V  SyCompileName . . . . . . . . . . . . . . . . . . . . . .  with this name
*/
Char SyCompileName[256];


/****************************************************************************
**
*V  SyCompileOutput . . . . . . . . . . . . . . . . . . into this output file
*/
Char SyCompileOutput[GAP_PATH_MAX];

/****************************************************************************
**
*V  SyCompileOutput . . . . . . . . . . . . . . . . . . into this output file
*/
Char SyCompileOptions[256] = {'\0'};


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
**  In addition we store the path to the users ~/.gap directory, if available,
**  in 'DotGapPath'.
**  
**  Put in this package because the command line processing takes place here.
**
#define MAX_GAP_DIRS 128
*/
Char SyGapRootPaths[MAX_GAP_DIRS][GAP_PATH_MAX];
#if HAVE_DOTGAPRC
Char DotGapPath[GAP_PATH_MAX];
#endif

/****************************************************************************
**
*V  IgnoreGapRC . . . . . . . . . . . . . . . . . . . -r option for kernel
**
*/
Int IgnoreGapRC;

/****************************************************************************
**
*V  SyHasUserHome . . . . . . . . . .  true if user has HOME in environment
*V  SyUserHome . . . . . . . . . . . . .  path of users home (it is exists)
*/
Int SyHasUserHome;
Char SyUserHome[GAP_PATH_MAX];

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
*V  SyUseReadline   . . . . . . . . . . . . . . . . . .  support line editing
**
**  Switch for not using readline although GAP is compiled with libreadline
*/
UInt SyUseReadline;

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
*V  SyQuitOnBreak . . . . . . . . . . exit GAP instead of entering break loop
*/
UInt SyQuitOnBreak;

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
**  This is per default 1G in 32-bit mode and 2G in 64-bit mode, which
**  is often a reasonable value. It is usually changed with the '-o'
**  option in the script that starts GAP.
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
**  Gasman in kB. GAP exits before trying to allocate more than this amount
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
Char SySystemInitFile[GAP_PATH_MAX];


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

*F * * * * * * * * * * * * * time related functions * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  SyTime()  . . . . . . . . . . . . . . . return time spent in milliseconds
**
**  'SyTime' returns the number of milliseconds spent by GAP so far.
**
**  Should be as accurate as possible,  because it  is  used  for  profiling.
*/
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


/****************************************************************************
**

*F * * * * * * * * * * * * * * * string functions * * * * * * * * * * * * * *
*/


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


#ifndef HAVE_STRLCPY

size_t strlcpy (
    char *dst,
    const char *src,
    size_t len)
{
    /* Keep a copy of the original src. */
    const char * const orig_src = src;

    /* If a non-empty len was specified, we can actually copy some data. */
    if (len > 0) {
        /* Copy up to len-1 bytes (reserve one for the terminating zero). */
        while (--len > 0) {
            /* Copy from src to dst; if we reach the string end, we are
               done and can simply return the total source string length */
            if ((*dst++ = *src++) == 0) {
                /* return length of source string without the zero byte */
                return src - orig_src - 1;
            }
        }
        
        /* If we got here, then we used up the whole buffer and len is zero.
           We must make sure to terminate the destination string. */
        *dst = 0;
    }

    /* in the end, we must return the length of the source string, no
       matter whether we completely copied or not; so advance src
       till its terminator is reached */
    while (*src++)
        ;

    /* return length of source string without the zero byte */
    return src - orig_src - 1;
}

#endif /* !HAVE_STRLCPY */


#ifndef HAVE_STRLCAT

size_t strlcat (
    char *dst,
    const char *src,
    size_t len)
{
    /* Keep a copy of the original dst. */
    const char * const orig_dst = dst;

    /* Find the end of the dst string, so that we can append after it. */
    while (*dst != 0 && len > 0) {
        dst++;
        len--;
    }

    /* We can only append anything if there is free space left in the
       destination buffer. */
    if (len > 0) {
        /* One byte goes away for the terminating zero. */
        len--;

        /* Do the actual work and append from src to dst, until we either
           appended everything, or reached the dst buffer's end. */
        while (*src != 0 && len > 0) {
            *dst++ = *src++;
            len--;
        }

        /* Terminate, terminate, terminate! */
        *dst = 0;
    }

    /* Compute the final result. */
    return (dst - orig_dst) + strlen(src);
}

#endif /* !HAVE_STRLCAT */

size_t strlncat (
    char *dst,
    const char *src,
    size_t len,
    size_t n)
{
    /* Keep a copy of the original dst. */
    const char * const orig_dst = dst;

    /* Find the end of the dst string, so that we can append after it. */
    while (*dst != 0 && len > 0) {
        dst++;
        len--;
    }

    /* We can only append anything if there is free space left in the
       destination buffer. */
    if (len > 0) {
        /* One byte goes away for the terminating zero. */
        len--;

        /* Do the actual work and append from src to dst, until we either
           appended everything, or reached the dst buffer's end. */
        while (*src != 0 && len > 0 && n > 0) {
            *dst++ = *src++;
            len--;
            n--;
        }

        /* Terminate, terminate, terminate! */
        *dst = 0;
    }

    /* Compute the final result. */
    len = strlen(src);
    if (n < len)
        len = n;
    return (dst - orig_dst) + len;
}

size_t strxcpy (
    char *dst,
    const char *src,
    size_t len)
{
    size_t res = strlcpy(dst, src, len);
    assert(res < len);
    return res;
}

size_t strxcat (
    char *dst,
    const char *src,
    size_t len)
{
    size_t res = strlcat(dst, src, len);
    assert(res < len);
    return res;
}

size_t strxncat (
    char *dst,
    const char *src,
    size_t len,
    size_t n)
{
    size_t res = strlncat(dst, src, len, n);
    assert(res < len);
    return res;
}

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
*f  SyAllocBags( <size>, <need> )
**
**  For UNIX, 'SyAllocBags' calls 'sbrk', which will work on most systems.
**
**  Note that   it may  happen that  another   function   has  called  'sbrk'
**  between  two calls to  'SyAllocBags',  so that the  next  allocation will
**  not be immediately adjacent to the last one.   In this case 'SyAllocBags'
**  returns the area to the operating system,  and either returns 0 if <need>
**  was 0 or aborts GAP if <need> was 1.  'SyAllocBags' will refuse to extend
**  the workspace beyond 'SyStorMax' or to reduce it below 'SyStorMin'.
*/

static UInt pagesize = 4096;   /* Will be initialised if SyAllocPool > 0 */

static inline UInt SyRoundUpToPagesize(UInt x)
{
    UInt r;
    r = x % pagesize;
    return r == 0 ? x : x - r + pagesize;
}

void *     POOL = NULL;
UInt * * * syWorkspace = NULL;
UInt       syWorksize = 0;


#if HAVE_MADVISE
#ifndef MAP_ANONYMOUS
#define MAP_ANONYMOUS MAP_ANON
#endif

static void *SyMMapStart = NULL;   /* Start of mmap'ed region for POOL */
static void *SyMMapEnd;            /* End of mmap'ed region for POOL */
static void *SyMMapAdvised;        /* We have already advised about non-usage
                                      up to here. */

void SyMAdviseFree() {
    size_t size;
    void *from;
    if (!SyMMapStart) 
        return;
    from = (char *) syWorkspace + syWorksize * 1024;
    from = (void *)SyRoundUpToPagesize((UInt) from);
    if (from > SyMMapAdvised) {
        SyMMapAdvised = from;
        return;
    }
    if (from < SyMMapStart || from >= SyMMapEnd || from >= SyMMapAdvised)
        return;
    size = (char *)SyMMapAdvised - (char *)from;
#if defined(MADV_FREE)
    madvise(from, size, MADV_FREE);
#elif defined(MADV_DONTNEED)
    madvise(from, size, MADV_DONTNEED);
#endif
    SyMMapAdvised = from;
    /* On Darwin, MADV_FREE and MADV_DONTNEED will not actually update
     * a process's resident memory until those pages are explicitly
     * unmapped or needed elsewhere.
     *
     * The following code accomplishes this, but is not portable and
     * potentially not safe, since the POSIX standard does not make
     * any sufficiently strong promises with regard to the use of
     * MAP_FIXED.
     *
     * We probably don't want to do this and just live with pages
     * remaining with a process until reused even if that appears to
     * inflate the resident set size.
     *
     * Maybe we do want to do this until it breaks to avoid questions
     * by users...
     */
#ifndef NO_DIRTY_OSX_MMAP_TRICK
#if SYS_IS_DARWIN
    if (mmap(from, size, PROT_NONE,
            MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED, -1, 0) != from) {
        fputs("gap: OS X trick to free pages did not work, bye!\n", stderr);
        SyExit( 2 );
    }
    if (mmap(from, size, PROT_READ|PROT_WRITE,
            MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED, -1, 0) != from) {
        fputs("gap: OS X trick to free pages did not work, bye!\n", stderr);
        SyExit( 2 );
    }
#endif
#endif
}

void *SyAnonMMap(size_t size) {
    void *result;
    size = SyRoundUpToPagesize(size);
#ifdef SYS_IS_64_BIT
    /* The following is at 16 Terabyte: */
    result = mmap((void *) (16L*1024*1024*1024*1024), size, 
                  PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
    if (result == MAP_FAILED) {
        result = mmap(NULL, size, PROT_READ|PROT_WRITE,
            MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
    }
#else
    result = mmap(NULL, size, PROT_READ|PROT_WRITE,
        MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
#endif
    if (result == MAP_FAILED)
        result = NULL;
    SyMMapStart = result;
    SyMMapEnd = (char *)result + size;
    SyMMapAdvised = (char *)result + size;
    return result;
}

int SyTryToIncreasePool(void)
/* This tries to increase the pool size by a factor of 3/2, if this
 * worked, then 0 is returned, otherwise -1. */
{
    void *result;
    size_t size;
    size_t newchunk;

    size = (Int) SyMMapEnd - (Int) SyMMapStart;
    newchunk = SyRoundUpToPagesize(size/2);
    result = mmap(SyMMapEnd, newchunk, PROT_READ|PROT_WRITE,
                  MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
    if (result == MAP_FAILED) return -1;
    if (result != SyMMapEnd) {
        munmap(result,newchunk);
        return -1;
    }
    /* We actually got an extension! */
    SyMMapEnd = (void *)((char *)SyMMapEnd + newchunk);
    SyAllocPool += newchunk;
    return 0;
}

#else

void SyMAdviseFree(void) {
    /* do nothing */
}

int SyTryToIncreasePool(void)
{
    return -1;   /* Refuse */
}

#endif

int halvingsdone = 0;

void SyInitialAllocPool( void )
{
#if HAVE_SYSCONF
#ifdef _SC_PAGESIZE
   pagesize = sysconf(_SC_PAGESIZE);
#endif
#endif
   /* Otherwise we take the default of 4k as pagesize. */

   do {
       /* Always round up to pagesize: */
       SyAllocPool = SyRoundUpToPagesize(SyAllocPool);
#if HAVE_MADVISE
       POOL = SyAnonMMap(SyAllocPool+pagesize);   /* For alignment */
#else
       POOL = calloc(SyAllocPool+pagesize,1);   /* For alignment */
#endif
       if (POOL != NULL) {
           /* fprintf(stderr,"Pool size is %lx.\n",SyAllocPool); */
           break;
       }
       SyAllocPool = SyAllocPool / 2;
       halvingsdone++;
       if (SyDebugLoading) fputs("gap: halving pool size.\n", stderr);
       if (SyAllocPool < 16*1024*1024) {
         fputs("gap: cannot allocate initial memory, bye.\n", stderr);
         SyExit( 2 );
       }
   } while (1);   /* Is left by break */

   /* ensure alignment of start address */
   syWorkspace = (UInt***)(SyRoundUpToPagesize((UInt) POOL));
   /* Now both syWorkspace and SyAllocPool are aligned to pagesize */
}

UInt ***SyAllocBagsFromPool(Int size, UInt need)
{
  /* get the storage, but only if we stay within the bounds              */
  /* if ( (0 < size && syWorksize + size <= SyStorMax) */
  /* first check if we would get above SyStorKill, if yes exit! */
  if ( need < 2 && SyStorKill != 0 && 0 < size 
                && SyStorKill < syWorksize + size ) {
      fputs("gap: will not extend workspace above -K limit, bye!\n",stderr);
      SyExit( 2 );
  }
  if (size > 0) {
    while ((syWorksize+size)*1024 > SyAllocPool) {
        if (SyTryToIncreasePool()) return (UInt***)-1;
    }
    return (UInt***)((char*)syWorkspace + syWorksize*1024);
  }
  else if  (size < 0 && (need >= 2 || SyStorMin <= syWorksize + size))
    return (UInt***)((char*)syWorkspace + syWorksize*1024);
  else
    return (UInt***)-1;
}

#if HAVE_SBRK && ! HAVE_VM_ALLOCATE /* prefer `vm_allocate' over `sbrk' */

UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret;
    UInt adjust = 0;

    if (SyAllocPool > 0) {
      if (POOL == NULL) SyInitialAllocPool();
      /* Note that this does abort GAP if it does not succeed! */
      
      ret = SyAllocBagsFromPool(size,need);
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
        if ( need < 2 && SyStorKill != 0 && 0 < size && 
             SyStorKill < syWorksize + size ) {
            fputs("gap: will not extend workspace above -K limit, bye!\n",
                  stderr);
            SyExit( 2 );
        }
        if (0 < size )
          {
#ifndef SYS_IS_64_BIT
            while (size > 1024*1024)
              {
                ret = (UInt ***)sbrk(1024*1024*1024);
                if (ret != (UInt ***)-1  && 
                    ret != (UInt***)((char*)syWorkspace + syWorksize*1024))
                  {
                    sbrk(-1024*1024*1024);
                    ret = (UInt ***)-1;
                  }
                if (ret == (UInt ***)-1)
                  break;
                memset((void *)((char *)syWorkspace + syWorksize*1024), 0, 
                       1024*1024*1024);
                size -= 1024*1024;
                syWorksize += 1024*1024;
                adjust++;
              }
#endif
            ret = (UInt ***)sbrk(size*1024);
            if (ret != (UInt ***)-1  && 
                ret != (UInt***)((char*)syWorkspace + syWorksize*1024))
              {
                sbrk(-size*1024);
                ret = (UInt ***)-1;
              }
            if (ret != (UInt ***)-1)
              memset((void *)((char *)syWorkspace + syWorksize*1024), 0, 
                     1024*size);
            
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
*f  SyAllocBags( <size>, <need> )
**
**  Under MACH virtual memory managment functions are used instead of 'sbrk'.
*/
#if HAVE_VM_ALLOCATE

#include <mach/mach.h>

#if (defined(SYS_IS_DARWIN) && SYS_IS_DARWIN) || defined(__gnu_hurd__)
#define task_self mach_task_self
#endif

vm_address_t syBase;
 
UInt * * * SyAllocBags (
    Int                 size,
    UInt                need )
{
    UInt * * *          ret = (UInt***)-1;
    vm_address_t        adr;    

    if (SyAllocPool > 0) {
      if (POOL == NULL) SyInitialAllocPool();
      /* Note that this does abort GAP if it does not succeed! */
 
      ret = SyAllocBagsFromPool(size,need);
      if (ret != (UInt ***)-1)
          syWorksize += size;

    }
    else {
        if ( SyStorKill != 0 && 0 < size && SyStorKill < 1024*(syWorksize + size) ) {
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
                syWorksize = size;
                ret = (UInt***) syBase;
            }
        }

        /* don't shrink memory but mark it as deactivated                      */
        else if ( size < 0 && syWorksize + size > SyStorMin) {
            adr = (vm_address_t)( (char*) syBase + (syWorksize+size)*1024 );
            if ( vm_deallocate(task_self(),adr,-size*1024) == KERN_SUCCESS ) {
                ret = (UInt***)( (char*) syBase + syWorksize*1024 );
                syWorksize += size;
            }
        }

        /* get more memory from system                                         */
        else {
            adr = (vm_address_t)( (char*) syBase + syWorksize*1024 );
            if ( vm_allocate(task_self(),&adr,size*1024,FALSE) == KERN_SUCCESS ) {
                ret = (UInt***) ( (char*) syBase + syWorksize*1024 );
                syWorksize += size;
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
        if (syWorksize  > SyStorMax)  {
            SyStorOverrun = -1;
            SyStorMax=syWorksize*2; /* new maximum */
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
**
**  If the user calls 'QUIT_GAP' with a value, then the global variable
**  'UserHasQUIT' will be set, and their requested return value will be
**  in 'SystemErrorCode'. If the return value would be 0, we check
**  this calue and use it instead.
*/
void SyExit (
    UInt                ret )
{
        exit( (int)ret );
}

/****************************************************************************
**
*F  SyNanosecondsSinceEpoch()
**
**  'SyNanosecondsSinceEpoch' returns a 64-bit integer which represents the
**  number of nanoseconds since some unspecified starting point. This means
**  that the number returned by this function is not in itself meaningful,
**  but the difference between the values returned by two consecutive calls
**  can be used to measure wallclock time.
**
**  The accuracy of this is system dependent. For systems that implement
**  clock_getres, we could get the promised accuracy.
**
**  Note that gettimeofday has been marked obsolete in the POSIX standard.
**  We are using it because it is implemented in most systems still.
**
**  If we are using gettimeofday we cannot guarantee the values that
**  are returned by SyNanosecondsSinceEpoch to be monotonic.
**
**  Returns -1 to represent failure
**
*/
Int8 SyNanosecondsSinceEpoch()
{
  Int8 res;

#if defined(SYS_IS_DARWIN)
  static mach_timebase_info_data_t timeinfo;
  if ( timeinfo.denom == 0 ) {
    (void) mach_timebase_info(&timeinfo);
  }
  res = mach_absolute_time();

  res *= timeinfo.numer;
  res /= timeinfo.denom;
#elif defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
  struct timespec ts;

  if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0) {
    res = ts.tv_sec;
    res *= 1000000000L;
    res += ts.tv_nsec;
  } else {
    res = -1;
  }
#elif defined(HAVE_GETTIMEOFDAY)
  struct timeval tv;

  if (gettimeofday(&tv, NULL) == 0) {
    res = tv.tv_sec;
    res *= 1000000L;
    res += tv.tv_usec;
    res *= 1000;
  } else {
    res = -1;
  };
#else
  res = -1;
#endif

  return res;
}


/****************************************************************************
**
*V  SyNanosecondsSinceEpochMethod
*V  SyNanosecondsSinceEpochMonotonic
**  
**  These constants give information about the method used to obtain
**  NanosecondsSinceEpoch, and whether the values returned are guaranteed
**  to be monotonic.
*/
#if defined(SYS_IS_DARWIN)
  const char * const SyNanosecondsSinceEpochMethod = "mach_absolute_time";
  const Int SyNanosecondsSinceEpochMonotonic = 1;
#elif defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
  const char * const SyNanosecondsSinceEpochMethod = "clock_gettime";
  const Int SyNanosecondsSinceEpochMonotonic = 1;
#elif defined(HAVE_GETTIMEOFDAY)
  const char * const SyNanosecondsSinceEpochMethod = "gettimeofday";
  const Int SyNanosecondsSinceEpochMonotonic = 0;
#else
  const char * const SyNanosecondsSinceEpochMethod = "unsupported";
  const Int SyNanosecondsSinceEpochMonotonic = 0;
#endif


/****************************************************************************
**
*F  SyNanosecondsSinceEpochResolution()
**
**  'SyNanosecondsSinceEpochResolution' returns a 64-bit integer which
**  represents the resolution in nanoseconds of the timer used for
**  SyNanosecondsSinceEpoch. 
**
**  If the return value is positive then the value has been returned
**  by the operating system can can probably be relied on. If the 
**  return value is negative it is just an estimate (as in the case
**  of gettimeofday we have no way to get the exact resolution so we
**  just pretend that the resolution is 1000 nanoseconds).
**
**  A result of 0 signifies inability to obtain any sensible value.
*/
Int8 SyNanosecondsSinceEpochResolution()
{
  Int8 res;

#if defined(SYS_IS_DARWIN)
  static mach_timebase_info_data_t timeinfo;
  if ( timeinfo.denom == 0 ) {
    (void) mach_timebase_info(&timeinfo);
  }
  res = timeinfo.numer;
  res /= timeinfo.denom;
#elif defined(HAVE_CLOCK_GETTIME) && defined(CLOCK_MONOTONIC)
  struct timespec ts;

  if (clock_getres(CLOCK_MONOTONIC, &ts) == 0) {
    res = ts.tv_sec;
    res *= 1000000000L;
    res += ts.tv_nsec;
  } else {
    res = 0;
  }
#elif defined(HAVE_GETTIMEOFDAY)
  res = -1000;
#else
  res = 0;
#endif

  return res;
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
*f  SySetGapRootPath( <string> )
**
** This function assumes that the system uses '/' as path separator.
** Currently, we support nothing else. For Windows (or rather: Cygwin), we
** rely on a small hack which converts the path separator '\' used there
** on '/' on the fly. Put differently: Systems that use completely different
**  path separators, or none at all, are currently not supported.
*/

static void SySetGapRootPath( const Char * string )
{
    const Char *          p;
    Char *          q;
    Int             i;
    Int             n;

    /* set string to a default value if unset                              */
    if ( string == 0 || *string == 0 ) {
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
    else if( string[ strlen(string) - 1 ] == ';' ) {
        /* Count the number of directories in 'string'.                    */
        n = 0; p = string; while( *p ) if( *p++ == ';' ) n++;

        /* Find last root path.                                            */
        for( i = 0; i < MAX_GAP_DIRS; i++ ) 
            if( SyGapRootPaths[i][0] == '\0' ) break;
        i--;

#ifdef HPCGAP
        n *= 2; // for each root <ROOT> we also add <ROOT/hpcgap> as a root
#endif

        /* Move existing root paths to the back                            */
        if( i + n >= MAX_GAP_DIRS ) return;
        while( i >= 0 ) {
            memcpy( SyGapRootPaths[i+n], SyGapRootPaths[i], sizeof(SyGapRootPaths[i+n]) );
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

#if SYS_IS_CYGWIN32
            /* fix up for DOS */
            if (*q == '\\')
              *q = '/';
#endif
            
            q++;
        }
        if ( q == SyGapRootPaths[n] ) {
            strxcpy( SyGapRootPaths[n], "./", sizeof(SyGapRootPaths[n]) );
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
#ifdef HPCGAP
        // or each root <ROOT> we also add <ROOT/hpcgap> as a root (and first)
        if( n < MAX_GAP_DIRS ) {
            strlcpy( SyGapRootPaths[n+1], SyGapRootPaths[n], sizeof(SyGapRootPaths[n]) );
        }
        strxcat( SyGapRootPaths[n], "hpcgap/", sizeof(SyGapRootPaths[n]) );
        n++;
#endif
    }
    return; 
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
  UInt size  = atol(s);
  Char symbol =  s[strlen(s)-1];
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
  Char shortkey;
  Char longkey[50];
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
  strxcat( SyCompileOutput, argv[0], sizeof(SyCompileOutput) );
  strxcat( SyCompileInput, argv[1], sizeof(SyCompileInput) );
  strxcat( SyCompileName, argv[2], sizeof(SyCompileName) );
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

/* These options must be kept in sync with those in system.g, so the help output
   is correct */
struct optInfo options[] = {
  { 'B',  "architecture", storeString, &SyArchitecture, 1}, /* default architecture needs to be passed from kernel 
                                                                  to library. Might be needed for autoload of compiled files */
  { 'C',  "", processCompilerArgs, 0, 4}, /* must handle in kernel */
  { 'D',  "debug-loading", toggle, &SyDebugLoading, 0}, /* must handle in kernel */
  { 'K',  "maximal-workspace", storeMemory2, &SyStorKill, 1}, /* could handle from library with new interface */
  { 'L', "", storeString, &SyRestoring, 1}, /* must be handled in kernel  */
  { 'M', "", toggle, &SyUseModule, 0}, /* must be handled in kernel */
  { 'X', "", toggle, &SyCheckCRCCompiledModule, 0}, /* must be handled in kernel */
  { 'R', "", unsetString, &SyRestoring, 0}, /* kernel */
  { 'U', "", storeString, SyCompileOptions, 1}, /* kernel */
  { 'a', "", storeMemory, &preAllocAmount, 1 }, /* kernel -- is this still useful */
  { 'e', "", toggle, &SyCTRD, 0 }, /* kernel */
  { 'f', "", forceLineEditing, (void *)2, 0 }, /* probably library now */
  { 'E', "", toggle, &SyUseReadline, 0 }, /* kernel */
  { 'i', "", storeString, SySystemInitFile, 1}, /* kernel */
  { 'l', "roots", setGapRootPath, 0, 1}, /* kernel */
  { 'm', "", storeMemory2, &SyStorMin, 1 }, /* kernel */
  { 'r', "", toggle, &IgnoreGapRC, 0 }, /* kernel */
  { 's', "", storeMemory, &SyAllocPool, 1 }, /* kernel */
  { 'n', "", forceLineEditing, 0, 0}, /* prob library */
  { 'o', "", storeMemory2, &SyStorMax, 1 }, /* library with new interface */
  { 'p', "", toggle, &SyWindow, 0 }, /* ?? */
  { 'q', "", toggle, &SyQuiet, 0 }, /* ?? */
#ifdef HPCGAP
  { 'S', "", toggle, &ThreadUI, 0 }, /* Thread UI */
  { 'Z', "", toggle, &DeadlockCheck, 0 }, /* Thread UI */
  { 'P', "", storePosInteger, &SyNumProcessors, 1 }, /* Thread UI */
  { 'G', "", storePosInteger, &SyNumGCThreads, 1 }, /* Thread UI */
#endif
  /* The following three options must be handled in the kernel so they happen early enough */
  { 0  , "prof", enableProfilingAtStartup, 0, 1},    /* enable profiling at startup */
  { 0  , "cover", enableCodeCoverageAtStartup, 0, 1}, /* enable code coverage at startup */
  { 0  , "quitonbreak", toggle, &SyQuitOnBreak, 0}, /* Quit GAP if we enter the break loop */
  { 0, "",0,0}};


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
    SyCTRD = 1;             
    SyCheckCRCCompiledModule = 0;
    SyCompilePlease = 0;
    SyDebugLoading = 0;
    SyHasUserHome = 0;
    SyLineEdit = 1;
#ifdef HPCGAP
    SyUseReadline = 0;
#else
    SyUseReadline = 1;
#endif
    SyMsgsFlagBags = 0;
    SyNrCols = 0;
    SyNrColsLocked = 0;
    SyNrRows = 0;
    SyNrRowsLocked = 0;
    SyQuiet = 0;
    SyInitializing = 0;
#ifdef SYS_IS_64_BIT
    SyStorMax = 2048*1024L;          /* This is in kB! */
    SyAllocPool = 4096L*1024*1024;   /* Note this is in bytes! */
#else
    SyStorMax = 1024*1024L;          /* This is in kB! */
#if SYS_IS_CYGWIN32
    SyAllocPool = 0;                 /* works better on cygwin */
#else
    SyAllocPool = 1536L*1024*1024;   /* Note this is in bytes! */
#endif
#endif
    SyStorOverrun = 0;
    SyStorKill = 0;
    SyStorMin = SY_STOR_MIN;         /* see system.h */
    SyUseModule = 1;
    SyWindow = 0;

    for (i = 0; i < 2; i++) {
      UInt j;
      for (j = 0; j < 7; j++) {
        SyGasmanNumbers[i][j] = 0;
      }
    }

#if HAVE_VM_ALLOCATE
    syBase = 0;
    syWorksize = 0;
#elif HAVE_SBRK
    syWorkspace = (UInt ***)0;
#endif
    /*  nopts = 0;
    noptvals = 0;
    lenoptvalsbuff = 0;
    gaprc = 1; */

    preAllocAmount = 4*1024*1024;
    
    /* open the standard files                                             */
#if HAVE_TTYNAME
    syBuf[0].fp = fileno(stdin);
    syBuf[0].bufno = -1;
    if ( isatty( fileno(stdin) ) && ttyname(fileno(stdin)) != NULL ) {
        if ( isatty( fileno(stdout) ) && ttyname(fileno(stdout)) != NULL
          && ! strcmp( ttyname(fileno(stdin)), ttyname(fileno(stdout)) ) )
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
    if ( isatty( fileno(stderr) ) && ttyname(fileno(stderr)) != NULL ) {
        if ( isatty( fileno(stdin) ) && ttyname(fileno(stdin)) != NULL
          && ! strcmp( ttyname(fileno(stdin)), ttyname(fileno(stderr)) ) )
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

    for (i = 4; i < sizeof(syBuf)/sizeof(syBuf[0]); i++)
      syBuf[i].fp = -1;
    
    for (i = 0; i < sizeof(syBuffers)/sizeof(syBuffers[0]); i++)
          syBuffers[i].inuse = 0;

#if HAVE_LIBREADLINE
    rl_initialize ();
#endif
    
    SyInstallAnswerIntr();

    SySystemInitFile[0] = '\0';
    strxcpy( SySystemInitFile, "lib/init.g", sizeof(SySystemInitFile) );
#if SYS_IS_CYGWIN32
    SySetGapRootPath( SyWindowsPath );
#elif defined(SYS_DEFAULT_PATHS)
    SySetGapRootPath( SYS_DEFAULT_PATHS );
#else
    SySetGapRootPath( "./" );
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

          if ( strlen(argv[1]) != 2 && argv[1][1] != '-') {
            FPUTS_TO_STDERR("gap: sorry, options must not be grouped '");
            FPUTS_TO_STDERR(argv[1]);  FPUTS_TO_STDERR("'.\n");
            goto usage;
          }


          for (i = 0;  options[i].shortkey != argv[1][1] &&
                       (argv[1][1] != '-' || argv[1][2] == 0 || strcmp(options[i].longkey, argv[1] + 2)) &&
                       (options[i].shortkey != 0 || options[i].longkey[0] != 0); i++)
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
    /* adjust SyUseReadline if no readline support available or for XGAP  */
#if !HAVE_LIBREADLINE
    SyUseReadline = 0;
#endif
    if (SyWindow) SyUseReadline = 0;

    /* now that the user has had a chance to give -x and -y,
       we determine the size of the screen ourselves */
    getwindowsize();

    /* fix max if it is lower than min                                     */
    if ( SyStorMax != 0 && SyStorMax < SyStorMin ) {
        SyStorMax = SyStorMin;
    }

    /* fix pool size if larger than SyStorKill */
    if ( SyStorKill != 0 && SyAllocPool != 0 &&
                            SyAllocPool > 1024 * SyStorKill ) {
        SyAllocPool = SyStorKill * 1024;
    }
    /* fix pool size if it is given and lower than SyStorMax */
    if ( SyAllocPool != 0 && SyAllocPool < SyStorMax * 1024) {
        SyAllocPool = SyStorMax * 1024;
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

#if HAVE_DOTGAPRC
    /* the users home directory                                            */
    if ( getenv("HOME") != 0 ) {
        strxcpy(SyUserHome, getenv("HOME"), sizeof(SyUserHome));
        SyHasUserHome = 1;

        strxcpy(DotGapPath, getenv("HOME"), sizeof(DotGapPath));
# if defined(SYS_IS_DARWIN) && SYS_IS_DARWIN
        /* On Darwin, add .gap to the sys roots, but leave */
        /* DotGapPath at $HOME/Library/Preferences/GAP     */
        strxcat(DotGapPath, "/.gap;", sizeof(DotGapPath));
        if (!IgnoreGapRC) {
          SySetGapRootPath(DotGapPath);
        }
		
        strxcpy(DotGapPath, getenv("HOME"), sizeof(DotGapPath));
        strxcat(DotGapPath, "/Library/Preferences/GAP;", sizeof(DotGapPath));
# elif defined(__CYGWIN__)
        strxcat(DotGapPath, "/_gap;", sizeof(DotGapPath));
# else
        strxcat(DotGapPath, "/.gap;", sizeof(DotGapPath));
# endif

        if (!IgnoreGapRC) {
          SySetGapRootPath(DotGapPath);
        }
        DotGapPath[strlen(DotGapPath)-1] = '\0';
        
        /* and in this case we can also expand paths which start
           with a tilde ~ */
        for (i = 0; i < MAX_GAP_DIRS && SyGapRootPaths[i][0]; i++) {
          if (SyGapRootPaths[i][0] == '~' && 
              strlen(SyUserHome)+strlen(SyGapRootPaths[i]) < sizeof(SyGapRootPaths[i])) {
            memmove(SyGapRootPaths[i]+strlen(SyUserHome),
                    /* don't copy the ~ but the trailing '\0' */
                    SyGapRootPaths[i]+1, strlen(SyGapRootPaths[i]));
            memcpy(SyGapRootPaths[i], SyUserHome, strlen(SyUserHome));
          }
        }
    }
#endif


    /* now we start                                                        */
    return;

    /* print a usage message                                               */
usage:
 FPUTS_TO_STDERR("usage: gap [OPTIONS] [FILES]\n");
 FPUTS_TO_STDERR("       run the Groups, Algorithms and Programming system, Version ");
 FPUTS_TO_STDERR(SyBuildVersion);
 FPUTS_TO_STDERR("\n");
 FPUTS_TO_STDERR("       use '-h' option to get help.\n");
 FPUTS_TO_STDERR("\n");
 SyExit( 1 );
}


/****************************************************************************
**
*E  system.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
