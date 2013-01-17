/****************************************************************************
**
*W  system.h                    GAP source                   Martin Schönert
*W                                                         & Dave Bayer (MAC)
*W                                                  & Harald Boegeholz (OS/2)
*W                                                      & Frank Celler (MACH)
*W                                                         & Paul Doyle (VMS)
*W                                                  & Burkhard Höfling (MAC)
*W                                                    & Steve Linton (MS/DOS)
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  The  file 'system.c'  declares  all operating system  dependent functions
**  except file/stream handling which is done in "sysfiles.h".
*/

#ifndef GAP_SYSTEM_H
#define GAP_SYSTEM_H

#include        <setjmp.h>              /* jmp_buf, setjmp, longjmp        */

/****************************************************************************
**

*V  autoconf  . . . . . . . . . . . . . . . . . . . . . . . .  use "config.h"
*/
#ifdef CONFIG_H

#include "config.h"

/* define stack align for gasman (from "config.h")                         */
#define SYS_STACK_ALIGN         C_STACK_ALIGN

/* assume all prototypes are there                                         */
#define SYS_HAS_CALLOC_PROTO
#define SYS_HAS_EXEC_PROTO
#define SYS_HAS_IOCTL_PROTO
#define SYS_HAS_MALLOC_PROTO
#define SYS_HAS_MEMSET_PROTO
#define SYS_HAS_MISC_PROTO
#define SYS_HAS_READ_PROTO
#define SYS_HAS_SIGNAL_PROTO
#define SYS_HAS_STDIO_PROTO
#define SYS_HAS_STRING_PROTO
#define SYS_HAS_TIME_PROTO
#define SYS_HAS_WAIT_PROTO
#define SYS_HAS_WAIT_PROTO

/* check if we are on a 64 bit machine                                     */
#if SIZEOF_VOID_P == 8
# define SYS_IS_64_BIT          1
#endif

/* some compiles define symbols beginning with an underscore               */
/* but Mac OSX's dlopen adds one in for free!                              */
#if C_UNDERSCORE_SYMBOLS
#if defined(SYS_IS_DARWIN) && SYS_IS_DARWIN
# define SYS_INIT_DYNAMIC       "Init__Dynamic"
#else
#if defined(SYS_IS_CYGWIN32) && SYS_IS_CYGWIN32
# define SYS_INIT_DYNAMIC       "Init__Dynamic"
#else
# define SYS_INIT_DYNAMIC       "_Init__Dynamic"
#endif
#endif
#else
# define SYS_INIT_DYNAMIC       "Init__Dynamic"
#endif

/* "config.h" will redefine `vfork' to `fork' if necessary                 */
#define SYS_MY_FORK             vfork

#define SYS_HAS_SIG_T           RETSIGTYPE

/* prefer `vm_allocate' over `sbrk'                                        */
#if HAVE_VM_ALLOCATE
# undef  HAVE_SBRK
# define HAVE_SBRK              0
#endif

/* prefer "termio.h" over "sgtty.h"                                        */
#if HAVE_TERMIO_H
# undef  HAVE_SGTTY_H
# define HAVE_SGTTY_H           0
#endif

/* prefer `getrusage' over `times'                                         */
#if HAVE_GETRUSAGE
# undef  HAVE_TIMES
# define HAVE_TIMES             0
#endif

/* defualt HZ value                                                        */
/*  on IRIX we need this include to get the system value                   */

#if HAVE_SYS_SYSMACROS_H
#include <sys/sysmacros.h>
#endif

#ifndef  HZ
# define HZ                     50
#endif

/* prefer `waitpid' over `wait4'                                           */
#if HAVE_WAITPID
# undef  HAVE_WAIT4
# define HAVE_WAIT4             0
#endif

#endif


/****************************************************************************
**
*V  no autoconf . . . . . . . . . . . . . . . . . . . . do not use "config.h"
*/
#ifndef CONFIG_H

#ifdef  SYS_HAS_STACK_ALIGN
#define SYS_STACK_ALIGN         SYS_HAS_STACK_ALIGN
#endif

#ifndef SYS_ARCH
# define SYS_ARCH "unknown"
#endif

#ifndef SY_STOR_MIN
# if SYS_TOS_GCC2
#  define SY_STOR_MIN   0
# else
#  define SY_STOR_MIN   24 * 1024 
# endif
#endif

#ifndef SYS_HAS_STACK_ALIGN
#define SYS_STACK_ALIGN         sizeof(UInt *)
#endif

#ifdef SYS_HAS_SIGNALS
# define HAVE_SIGNAL            1
#else
# define HAVE_SIGNAL            0
#endif

#define HAVE_ACCESS             0
#define HAVE_STAT               0
#define HAVE_UNLINK             0
#define HAVE_MKDIR              0
#define HAVE_GETRUSAGE          0
#define HAVE_DOTGAPRC           0
#define HAVE_GAPRC              0

#ifdef SYS_IS_BSD
# undef  HAVE_ACCESS
# define HAVE_ACCESS            1
# undef  HAVE_STAT
# define HAVE_STAT              1
# undef  HAVE_UNLINK
# define HAVE_UNLINK            1
# undef  HAVE_MKDIR
# define HAVE_MKDIR             1
# undef  HAVE_GETRUSAGE
# define HAVE_GETRUSAGE         1
# undef  HAVE_DOTGAPRC
# define HAVE_DOTGAPRC          1
#endif

#ifdef SYS_IS_MACH
# undef  HAVE_ACCESS
# define HAVE_ACCESS            1
# undef  HAVE_STAT
# define HAVE_STAT              1
# undef  HAVE_UNLINK
# define HAVE_UNLINK            1
# undef  HAVE_MKDIR
# define HAVE_MKDIR             1
# undef  HAVE_GETRUSAGE
# define HAVE_GETRUSAGE         1
# undef  HAVE_DOTGAPRC
# define HAVE_DOTGAPRC          1
#endif

#ifdef SYS_IS_USG
# undef  HAVE_ACCESS
# define HAVE_ACCESS            1
# undef  HAVE_STAT
# define HAVE_STAT              1
# undef  HAVE_UNLINK
# define HAVE_UNLINK            1
# undef  HAVE_MKDIR
# define HAVE_MKDIR             1
# undef  HAVE_DOTGAPRC
# define HAVE_DOTGAPRC          1
#endif

#ifdef SYS_IS_OS2_EMX
# undef  HAVE_ACCESS
# define HAVE_ACCESS            1
# undef  HAVE_STAT
# define HAVE_STAT              1
# undef  HAVE_UNLINK
# define HAVE_UNLINK            1
# undef  HAVE_MKDIR
# define HAVE_MKDIR             1
# undef  HAVE_GAPRC
# define HAVE_GAPRC             1
#endif

#ifdef SYS_HAS_NO_GETRUSAGE
# undef  HAVE_GETRUSAGE
# define HAVE_GETRUSAGE         0
#endif

#endif

/****************************************************************************
**
*V  Includes  . . . . . . . . . . . . . . . . . . . . .  include system files
*/
#ifdef CONFIG_H
#endif

/* Cygwin claims to have GETRUSAGE but child times are not given properly */
#if SYS_IS_CYGWIN32
#undef  HAVE_GETRUSAGE
#define HAVE_GETRUSAGE          0
#endif


/****************************************************************************
**

*V  Revision_system_h . . . . . . . . . . . . . . . . . . . . revision number
*/
#ifdef  INCLUDE_DECLARATION_PART
#endif


/****************************************************************************
**

*V  SYS_ANSI  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ANSI C
*/
#ifdef SYS_HAS_ANSI
# define SYS_ANSI       SYS_HAS_ANSI
#else
# ifdef __STDC__
#  define SYS_ANSI      1
# else
#  define SYS_ANSI      0
# endif
#endif


/****************************************************************************
**
*V  SYS_BSD . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . BSD
*/
#ifdef SYS_IS_BSD
# define SYS_BSD        1
#else
# define SYS_BSD        0
#endif


/****************************************************************************
**
*V  SYS_MACH  . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  MACH
*/
#ifdef SYS_IS_MACH
# define SYS_MACH       1
#else
# define SYS_MACH       0
#endif


/****************************************************************************
**
*V  SYS_USG . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . USG
*/
#ifdef SYS_IS_USG
# define SYS_USG        1
#else
# define SYS_USG        0
#endif


/****************************************************************************
**
*V  SYS_OS2_EMX . . . . . . . . . . . . . . . . . . . . . . OS2 using GCC/EMX
*/
#ifdef SYS_IS_OS2_EMX
# define SYS_OS2_EMX    1
#else
# define SYS_OS2_EMX    0
#endif


/****************************************************************************
**
*V  SYS_MSDOS_DJGPP . . . . . . . . . . . . . . . . . . . . . MSDOS using GCC
*/
#ifdef SYS_IS_MSDOS_DJGPP
# define SYS_MSDOS_DJGPP 1
#else
# define SYS_MSDOS_DJGPP 0
#endif


/****************************************************************************
**
*V  SYS_VMS . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . VMS
*/
#ifdef SYS_IS_VMS
# define SYS_VMS        1
#else
# define SYS_VMS        0
#endif


/****************************************************************************
**
*V  SYS_DARWIN . . . . . . . . . . . . . . .  DARWIN (BSD underlying MacOS X)
*/
#ifdef SYS_IS_DARWIN
# define SYS_DARWIN    1
#else
# define SYS_DARWIN    0
#endif

#define FPUTS_TO_STDERR(str) fputs (str, stderr)

/****************************************************************************
**
*T  Char, Int1, Int2, Int4, Int, UChar, UInt1, UInt2, UInt4, UInt .  integers
**
**  'Char',  'Int1',  'Int2',  'Int4',  'Int',   'UChar',   'UInt1', 'UInt2',
**  'UInt4', 'UInt'  and possibly 'Int8' and 'UInt8' are the integer types.
**
**  Note that to get this to work, all files must be compiled with or without
**  '-DSYS_IS_64_BIT', not just "system.c".
**
**  '(U)Int<n>' should be exactly <n> bytes long
**  '(U)Int' should be the same length as a bag identifier
*/

/* 64 bit machines -- well alphas anyway                                   */
#ifdef SYS_IS_64_BIT
typedef char                    Char;
typedef signed char                    Int1;
typedef short int               Int2;
typedef int                     Int4;
typedef long int                Int8;
typedef long int                Int;
typedef unsigned char           UChar;
typedef unsigned char           UInt1;
typedef unsigned short int      UInt2;
typedef unsigned int            UInt4;
typedef unsigned long int       UInt8;
typedef unsigned long int       UInt;

/* 32bit machines                                                          */
#else
typedef char                    Char;
typedef signed char                    Int1;
typedef short int               Int2;
typedef long int                Int4;
typedef long int                Int;
typedef long long int           Int8;
typedef unsigned char           UChar;
typedef unsigned char           UInt1;
typedef unsigned short int      UInt2;
typedef unsigned long int       UInt4;
typedef unsigned long int       UInt;
typedef unsigned long long int  UInt8;

#endif


/****************************************************************************
**
*F  Macros to allow detection of dangerous assignments
**
**  NL makes its argument not a valid lvalue, but has no effect at runtime
*/

#ifdef __GNUC__ 
static inline Char IDENT_Char(Char x)
{
     return x;
}
#define NL_Char(x) (IDENT_Char((x)))
#else
#define NL_Char(x) (x)
#endif

#ifdef __GNUC__ 
static inline Int IDENT_Int(Int x)
{
     return x;
}
#define NL_Int(x) (IDENT_Int((x)))
#else
#define NL_Int(x) (x)
#endif

#ifdef __GNUC__ 
static inline UInt IDENT_UInt(UInt x)
{
     return x;
}
#define NL_UInt(x) (IDENT_UInt((x)))
#else
#define NL_UInt(x) (x)
#endif


/****************************************************************************
**
*T  Bag . . . . . . . . . . . . . . . . . . . type of the identifier of a bag
*/
typedef UInt * *        Bag;

/****************************************************************************
**
*T  BagW  . . . . . . . . . . . . . . . . . . . . type of a write-guarded bag
*/

typedef struct { UInt MemW; } * * BagW;

/****************************************************************************
**
*T  BagR  . . . . . . . . . . . . . . . . . . . .  type of a read-guarded bag
*/

typedef struct { UInt MemR; } * * BagR;


/****************************************************************************
**
*T  Obj . . . . . . . . . . . . . . . . . . . . . . . . . . . type of objects
*T  ObjW  . . . . . . . . . . . . . . . . . . . type of write-guarded objects
*T  ObjR  . . . . . . . . . . . . . . . . . . .  type of read-guarded objects
**
**  'Obj' is the type of objects.
*/
#define Obj             Bag
#define ObjW		BagW
#define ObjR		BagR


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
extern UInt SyStackAlign;


/****************************************************************************
**
*V  SyArchitecture  . . . . . . . . . . . . . . . .  name of the architecture
*/
extern const Char * SyArchitecture;

/****************************************************************************
**
*V  SyKernelVersion  . . . . . . . . . . . . . . . .  kernel version number
*/
extern const Char * SyKernelVersion;

/****************************************************************************
**
*V  SyAutoloadPackages  . . . . . . . . . .  automatically load packages
**
**  0: no 
**  1: yes
*/
extern UInt SyAutoloadPackages;

/****************************************************************************
**
*V  SyBreakSuppress  . . . . . . . . never enter a break loop
**
**  0: no 
**  1: yes
*/
extern UInt SyBreakSuppress;


/****************************************************************************
**
*V  SyBanner  . . . . . . . . . . . . . . . . . . . . . . . . surpress banner
**
**  'SyBanner' determines whether GAP should print the banner.
**
**  Per default it  is true,  i.e.,  GAP prints the  nice  banner.  It can be
**  changed by the '-b' option to have GAP surpress the banner.
**
**  Put in this package because the command line processing takes place here.
*/
extern UInt SyBanner;


/****************************************************************************
**
*V  SyCTRD  . . . . . . . . . . . . . . . . . . .  true if '<ctr>-D' is <eof>
*/
extern UInt SyCTRD;


/****************************************************************************
**
*V  SyCacheSize . . . . . . . . . . . . . . . . . . . . . . size of the cache
**
**  'SyCacheSize' is the size of the data cache, in kilobytes
**
**  This is per  default 0, which means that  there is no usuable data cache.
**  It is usually changed with the '-c' option in the script that starts GAP.
**
**  This value is passed to 'InitBags'.
**
**  Put in this package because the command line processing takes place here.
*/
extern UInt SyCacheSize;


/****************************************************************************
 **
 *V  SyCheckCRCCompiledModule  . . .  check crc while loading compiled modules
 */
extern Int SyCheckCRCCompiledModule;


/****************************************************************************
**
*V  SyCompileInput  . . . . . . . . . . . . . . . . . .  from this input file
*/
extern Char SyCompileInput [256];


/****************************************************************************
**
*V  SyCompileMagic1 . . . . . . . . . . . . . . . . . . and this magic number
*/
extern Char * SyCompileMagic1;


/****************************************************************************
**
*V  SyCompileName . . . . . . . . . . . . . . . . . . . . . .  with this name
*/
extern Char SyCompileName [256];


/****************************************************************************
**
*V  SyCompileOutput . . . . . . . . . . . . . . . . . . into this output file
*/
extern Char SyCompileOutput [256];

/****************************************************************************
**
*V  SyCompileOptions . . . . . . . . . . . . . . . . . with these options
*/
extern Char SyCompileOptions [256];


/****************************************************************************
**
*V  SyCompilePlease . . . . . . . . . . . . . . .  tell GAP to compile a file
*/
extern Int SyCompilePlease;

/****************************************************************************
**
*V  SyDebugLoading  . . . . . . . . .  output messages about loading of files
*/
extern Int SyDebugLoading;

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
*/
#define MAX_GAP_DIRS 128

extern Char SyGapRootPaths [MAX_GAP_DIRS] [512];

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
extern Char SyInitfiles [32] [512];

/****************************************************************************
**
*V  SyPkgnames[] . . . . . . . . . . .  list of package names
**
**  'SyPkgnames' is a list of names of entries of the `pkg' directory. It is
**  used for autoloading.
*/
#define SY_MAX_PKGNR 100
extern Char SyPkgnames [SY_MAX_PKGNR][16];

/****************************************************************************
**
*V  SyGapRCFilename . . . . . . . . . . . . . . . filename of the gaprc file
*/
extern Char SyGapRCFilename [512];

/****************************************************************************
**
*V  SyHasUserHome . . . . . . . . . .  true if user has HOME in environment
*V  SyUserHome . . . . . . . . . . . . .  path of users home (it is exists)
*/
extern Int SyHasUserHome;
extern Char SyUserHome [256];


/****************************************************************************
**
*V  SyLineEdit  . . . . . . . . . . . . . . . . . . . .  support line editing
**
**  0: no line editing
**  1: line editing if terminal
**  2: always line editing (EMACS)
*/
extern UInt SyLineEdit;


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
extern UInt SyMsgsFlagBags;


extern Int SyGasmanNumbers[2][9];

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
extern UInt SyNrCols;
extern UInt SyNrColsLocked;

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
extern UInt SyNrRows;
extern UInt SyNrRowsLocked;


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
**
**  Put in this package because the command line processing takes place here.
*/
extern UInt SyQuiet;


/****************************************************************************
**
*V  SyRestoring . . . . . . . . . . . . . . . . . . . . restoring a workspace
**
**  `SyRestoring' determines whether GAP is restoring a workspace or not.  If
**  it is zero no restoring should take place otherwise it holds the filename
**  of a workspace to restore.
**
*/
extern Char * SyRestoring;

/****************************************************************************
**
*V  SyInitializing                               set to 1 during library init
**
**  `SyInitializing' is set to 1 during the library intialization phase of
**  startup. It supresses some behaviours that may not be possible so early
**  such as homogeneity tests in the plist code.
*/

extern UInt SyInitializing;

extern Char **SyOriginalArgv;
extern UInt SyOriginalArgc;

/****************************************************************************
**
*V  SyStorMax . . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorMax' is the maximal size of the workspace allocated by Gasman.
**    this is now in kilobytes.
**
**  This is per default 256 MByte,  which is often a  reasonable value.  It is
**  usually changed with the '-o' option in the script that starts GAP.
**
**  This is used in the function 'SyAllocBags'below.
**
**  Put in this package because the command line processing takes place here.
*/
extern Int SyStorMax;
extern Int SyStorOverrun;

/****************************************************************************
**
*V  SyStorKill . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorKill' is really the maximal size of the workspace allocated by 
**  Gasman. GAP exists before trying to allocate more than this amount
**  of memory in kilobytes
**
**  This is per default disabled (i.e. = 0).
**  Can be changed with the '-K' option in the script that starts GAP.
**
**  This is used in the function 'SyAllocBags'below.
**
**  Put in this package because the command line processing takes place here.
*/
extern Int SyStorKill;

/****************************************************************************
**
*V  SyStorMin . . . . . . . . . . . . . .  default size for initial workspace
**
**  'SyStorMin' is the size of the initial workspace allocated by Gasman.
**  in kilobytes
**
**  This is per default  24 Megabyte,  which  is  often  a  reasonable  value.
**  It is usually changed with the '-m' option in the script that starts GAP.
**
**  This value is used in the function 'SyAllocBags' below.
**
**  Put in this package because the command line processing takes place here.
*/
extern Int SyStorMin;


/****************************************************************************
**
*V  SySystemInitFile  . . . . . . . . . . .  name of the system "init.g" file
*/
extern Char SySystemInitFile [256];


/****************************************************************************
**
*V  SyUseModule . . . . . check for dynamic/static modules in 'READ_GAP_ROOT'
*/
extern int SyUseModule;


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
extern UInt SyWindow;


/****************************************************************************
**

*F * * * * * * * * * * * * * time related functions * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  SyStartTime . . . . . . . . . . . . . . . . . . time when GAP was started
*/
extern UInt SyStartTime;


/****************************************************************************
**
*F  SyTime()  . . . . . . . . . . . . . . . return time spent in milliseconds
**
**  'SyTime' returns the number of milliseconds spent by GAP so far.
**
**  Should be as accurate as possible,  because it  is  used  for  profiling.
*/
extern UInt SyTime ( void );

#if HAVE_GETRUSAGE
extern UInt SyTimeSys ( void );
extern UInt SyTimeChildren ( void );
extern UInt SyTimeChildrenSys ( void );
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
*/
#include <ctype.h>
#define IsAlpha(ch)     (isalpha((unsigned int)ch))


/****************************************************************************
**
*F  IsDigit( <ch> ) . . . . . . . . . . . . . . . . .  is a character a digit
**
**  'IsDigit' returns 1 if its character argument is a digit from  the  range
**  '0..9' and 0 otherwise.
*/
#define IsDigit(ch)     (isdigit((unsigned int)ch))

/****************************************************************************
**
*F  IsSpace( <ch> ) . . . . . . . . . . . . . . . .is a character whitespace
**
**  'IsDigit' returns 1 if its character argument is whitespace: ' ', tab,
**  carriage return, linefeed or vertical tab
*/
#define IsSpace(ch)     (isspace((unsigned int)ch))


/****************************************************************************
**
*F  SyStrlen( <str> ) . . . . . . . . . . . . . . . . . .  length of a string
**
**  'SyStrlen' returns the length of the string <str>, i.e.,  the  number  of
**  characters in <str> that precede the terminating null character.
*/
extern UInt SyStrlen (
            const Char *     str );


/****************************************************************************
**
*F  SyStrcmp( <str1>, <str2> )  . . . . . . . . . . . . . compare two strings
**
**  'SyStrcmp' returns an integer greater than, equal to, or less  than  zero
**  according to whether <str1> is greater  than,  equal  to,  or  less  than
**  <str2> lexicographically.
*/
extern Int SyStrcmp (
            const Char *    str1,
            const Char *    str2 );


/****************************************************************************
**
*F  SyStrncmp( <str1>, <str2>, <len> )  . . . . . . . . . compare two strings
**
**  'SyStrncmp' returns an integer greater than, equal to,  or less than zero
**  according  to whether  <str1>  is greater than,  equal  to,  or less than
**  <str2> lexicographically.  'SyStrncmp' compares at most <len> characters.
*/
extern Int SyStrncmp (
            const Char *    str1,
            const Char *    str2,
            UInt                len );

/****************************************************************************
**
*F  SyIntString( <string> ) . . . . . . . . extract a C integer from a string
**
*/

extern Int SyIntString( const Char *string );



/****************************************************************************
**
*F  SyStrncat( <dst>, <src>, <len> )  . . . . .  append one string to another
**
**  'SyStrncat'  appends characters from the  <src>  to <dst>  until either a
**  null character  is  encoutered  or  <len>  characters have   been copied.
**  <dst> becomes the concatenation of <dst> and <src>.  The resulting string
**  is always null terminated.  'SyStrncat' returns a pointer to <dst>.
*/
extern Char * SyStrncat (
            Char *              dst,
            const Char *    src,
            UInt                len );


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
extern void SyMsgsBags (
            UInt                full,
            UInt                phase,
            Int                 nr );


/****************************************************************************
**
*F  SyAllocBags( <size>, <need> ) . . . allocate memory block of <size> bytes
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
extern UInt * * * SyAllocBags (
            Int                 size,
            UInt                need );


/****************************************************************************
**
*F  SyAbortBags(<msg>)  . . . . . . . . . . abort GAP in case of an emergency
**
**  'SyAbortBags' is the function called by Gasman in case of an emergency.
*/
extern void SyAbortBags (
            const Char *        msg );


/****************************************************************************
**

*F * * * * * * * * * * * * * loading of modules * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  MODULE_BUILTIN  . . . . . . . . . . . . . . . . . . . . .  builtin module
*/
#define MODULE_BUILTIN          1


/****************************************************************************
**
*F  MODULE_STATIC . . . . . . . . . . . . . statically loaded compiled module
*/
#define MODULE_STATIC           2


/****************************************************************************
**
*F  MODULE_DYNAMIC  . . . . . . . . . . .  dynamically loaded compiled module
*/
#define MODULE_DYNAMIC          3



/****************************************************************************
**
*T  StructInitInfo  . . . . . . . . . . . . . . . . . module init information
*/
typedef struct init_info {

    /* type of the module: MODULE_BUILTIN, MODULE_STATIC, MODULE_DYNAMIC   */
    UInt                type;               

    /* name of the module: filename with ".c" or library filename          */
    const Char *    name;

    /* revision entry of c file for MODULE_BUILTIN                         */
    const Char *    revision_c;

    /* revision entry of h file for MODULE_BUILTIN                         */
    const Char *    revision_h;

    /* version number for MODULE_BUILTIN                                   */
    UInt                version;

    /* CRC value for MODULE_STATIC or MODULE_DYNAMIC                       */
    Int                 crc;

    /* initialise kernel data structures                                   */
    Int              (* initKernel)(struct init_info *);

    /* initialise library data structures                                  */
    Int              (* initLibrary)(struct init_info *);

    /* sanity check                                                        */
    Int              (* checkInit)(struct init_info *);

    /* function to call before saving workspace                            */
    Int              (* preSave)(struct init_info *);

    /* function to call after saving workspace                             */
    Int              (* postSave)(struct init_info *);

    /* function to call after restoring workspace                          */
    Int              (* postRestore)(struct init_info *);

    /* filename relative to GAP_ROOT or absolut                            */
    Char *            filename;

    /* true if the filename is GAP_ROOT relative                           */
    Int                 isGapRootRelative;

} StructInitInfo;

typedef StructInitInfo* (*InitInfoFunc)(void);


/****************************************************************************
**
*T  StructBagNames  . . . . . . . . . . . . . . . . . . . . . tnums and names
*/
typedef struct {
    Int                 tnum;
    const Char *    name;
} StructBagNames;


/****************************************************************************
**
*T  StructGVarFilt  . . . . . . . . . . . . . . . . . . . . . exported filter
*/
typedef struct {
    const Char *    name;
    const Char *    argument;
    Obj *               filter;
    Obj              (* handler)(/*arguments*/);
    const Char *    cookie;
} StructGVarFilt;


/****************************************************************************
**
*T  StructGVarAttr  . . . . . . . . . . . . . . . . . . .  exported attribute
*/
typedef struct {
    const Char *    name;
    const Char *    argument;
    Obj *               attribute;
    Obj              (* handler)(/*arguments*/);
    const Char *    cookie;
} StructGVarAttr;


/****************************************************************************
**
*T  StructGVarProp  . . . . . . . . . . . . . . . . . . . . exported property
*/
typedef struct {
    const Char *    name;
    const Char *    argument;
    Obj *               property;
    Obj              (* handler)(/*arguments*/);
    const Char *    cookie;
} StructGVarProp;


/****************************************************************************
**
*T  StructGVarOper  . . . . . . . . . . . . . . . . . . .  exported operation
*/
typedef struct {
    const Char *    name;
    Int                 nargs;
    const Char *    args;
    Obj *               operation;
    Obj              (* handler)(/*arguments*/);
    const Char *    cookie;
} StructGVarOper;


/****************************************************************************
**
*T  StructGVarFunc  . . . . . . . . . . . . . . . . . . . . exported function
*/
typedef struct {
    const Char *    name;
    Int                 nargs;
    const Char *    args;
    Obj              (* handler)(/*arguments*/);
    const Char *    cookie;
} StructGVarFunc;


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
extern void SyExit (
    UInt                ret );

/****************************************************************************
**
*F  SySleep( <secs> ) . . . . . . . . . . . . Try to sleep for <secs> seconds
**
**  The OS may wake us earlier, for example on receipt of a signal
*/

extern void SySleep( UInt secs );

/****************************************************************************
**
*F  getOptionCount ( <key> ) . number of times a command line option was used
*F  getOptionArg ( <key>, <which> ) get arguments used on <which>'th occurence
*F                             of <key> as a command line option NULL if none
**
*/

extern Int getOptionCount (Char key);
extern Char *getOptionArg(Char key, UInt which);

/****************************************************************************
**
*F  MergeSort() . . . . . . . . . . . . . . . sort an array using mergesort.
**
**  MergeSort() sorts an array of 'count' elements of individual size 'width'
**  with ordering determined by the parameter 'lessThan'. The 'lessThan'
**  function is to return a non-zero value if the first argument is less
**  than the second argument, zero otherwise.
*/

extern void MergeSort(void *data, unsigned count, unsigned width,
  int (*lessThan)(const void *a, const void *));

/****************************************************************************
 **
 *F    sySetjmp( <jump buffer> )
 *F    syLongjmp( <jump buffer>, <value>)
 ** 
 **   macros, defining our selected longjump mechanism
 */

#if HAVE_SIGSETJMP
#define sySetjmp( buff ) (sigsetjmp( (buff), 0))
#define syLongjmp siglongjmp
#define syJmp_buf sigjmp_buf
#else
#if HAVE__SETJMP
#define sySetjmp _setjmp
#define syLongjmp _longjmp
#define syJmp_buf jmp_buf
#else
#define sySetjmp setjmp
#define syLongjmp longjmp
#define syJmp_buf jmp_buf
#endif
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
extern void InitSystem (
            Int                 argc,
            Char *              argv [] );


#endif // GAP_SYSTEM_H

/****************************************************************************
**

*E  system.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
