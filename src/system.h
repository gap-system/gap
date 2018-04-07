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

/****************************************************************************
**
*V  autoconf  . . . . . . . . . . . . . . . . . . . . . . . .  use "config.h"
*/
#include <gen/config.h>

#include <ctype.h>
#include <limits.h>
#include <setjmp.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>


/****************************************************************************
**
*D  user edit-able defines
*/

/* initial amount of memory if '-m' is not given in KB                     */ 
/* The following tests whether we are in 64-bit mode, note that
 * SYS_IS_64_BIT is only defined later in this file! */
#if SIZEOF_VOID_P == 8
#define SY_STOR_MIN		(128L * 1024)
#else
#define SY_STOR_MIN		(64L * 1024)
#endif


/****************************************************************************
**
*D  debug flags (user edit-able)
*/


/* * * * * * * * * * * * * debugging GASMAN  * * * * * * * * * * * * * * * */

/* define to create functions PTR_BAG, etc instead of macros               */
/* #undef DEBUG_FUNCTIONS_BAGS */


/* define to debug masterpointers errors                                   */
/* #undef DEBUG_MASTERPOINTERS */

/* check if we are on a 64 bit machine                                     */
#if SIZEOF_VOID_P == 8
# define SYS_IS_64_BIT          1
#elif !defined(SIZEOF_VOID_P)
# error Something is wrong with this GAP installation: SIZEOF_VOID_P not defined
#endif


#ifndef HAVE_DOTGAPRC
/* define as 1 if the user resource file is ".gaprc" */
#define HAVE_DOTGAPRC           1
#endif


/****************************************************************************
**
*S  GAP_PATH_MAX . . . . . . . . . . . .  size for buffers storing file paths
**
**  'GAP_PATH_MAX' is the default buffer size GAP uses internally to store
**  most paths. If any longer paths are encountered, they will be either
**  truncated, or GAP aborts.
**
**  Note that no fixed buffer size is sufficient to store arbitrary paths
**  on contemporary operation systems, as paths can have arbitrary length.
**  This also means that the POSIX constant PATH_MAX does not really do the
**  job its name would suggest (nor do MAXPATHLEN, MAX_PATH etc.).
**
**  Writing POSIX compliant code without a hard coded buffer size is rather
**  challenging, as often there is no way to find out in advance how large a
**  buffer may need to be. So you have to start with some buffer size, then
**  check for errors; if 'errno' equals 'ERANGE', double the buffer size and
**  repeated, until you succeed or run out of memory.
**
**  Instead of going down this road, we use a fixed buffer size after all.
**  This way, at least our code stays simple. Also, this is what most (?)
**  code out there does, too, so if somebody actually uses such long paths,
**  at least GAP won't be the only program to run into problems.
*/
enum {
#ifdef PATH_MAX
    GAP_PATH_MAX = 4096 > PATH_MAX ? 4096 : PATH_MAX,
#else
    GAP_PATH_MAX = 4096,
#endif
};


#define FPUTS_TO_STDERR(str) fputs (str, stderr)

/****************************************************************************
**
*T  Wrappers for various compiler attributes
**
*/
#ifdef HAVE_FUNC_ATTRIBUTE_ALWAYS_INLINE
#define ALWAYS_INLINE __attribute__((always_inline)) inline
#else
#define ALWAYS_INLINE inline
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_NOINLINE
#define NOINLINE __attribute__((noinline))
#else
#define NOINLINE
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_NORETURN
#define NORETURN __attribute__((noreturn))
#else
#define NORETURN
#endif

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


typedef char              Char;

typedef int8_t   Int1;
typedef int16_t  Int2;
typedef int32_t  Int4;
typedef int64_t  Int8;

typedef uint8_t  UChar;
typedef uint8_t  UInt1;
typedef uint16_t UInt2;
typedef uint32_t UInt4;
typedef uint64_t UInt8;

#ifdef SYS_IS_64_BIT
typedef Int8     Int;
typedef UInt8    UInt;
#else
typedef Int4     Int;
typedef UInt4    UInt;
#endif

/****************************************************************************
**
**  'START_ENUM_RANGE' and 'END_ENUM_RANGE' simplify creating "ranges" of
**  enum variables.
**
**  Usage example:
**    enum {
**      START_ENUM_RANGE(FIRST),
**        FOO,
**        BAR,
**      END_ENUM_RANGE(LAST)
**    };
**  is essentially equivalent to
**    enum {
**      FIRST,
**        FOO = FIRST,
**        BAR,
**      LAST = BAR
**    };
**  Note that if we add a value into the range after 'BAR', we must adjust
**  the definition of 'LAST', which is easy to forget. Also, reordering enum
**  values may require extra work. With the range macros, all of this is
**  taken care of automatically.
*/
#define START_ENUM_RANGE(id)            id, _##id##_post = id - 1
#define START_ENUM_RANGE_INIT(id,init)  id = init, _##id##_post = id - 1
#define END_ENUM_RANGE(id)              _##id##_pre, id = _##id##_pre - 1


/****************************************************************************
**
*t  Bag . . . . . . . . . . . . . . . . . . . type of the identifier of a bag
**
**  (The documentation of 'Bag' is contained in 'gasman.h'.)
*/
typedef UInt * *        Bag;


/****************************************************************************
**
*T  Obj . . . . . . . . . . . . . . . . . . . . . . . . . . . type of objects
**
**  'Obj' is the type of objects.
*/
typedef Bag Obj;


/****************************************************************************
**
*T  ObjFunc . . . . . . . . . . . . . . . . type of function returning object
**
**  'ObjFunc' is the type of a function returning an object.
*/
typedef Obj (* ObjFunc) (/*arguments*/);


/****************************************************************************
**
*T  Stat  . . . . . . . . . . . . . . . . . . . . . . . .  type of statements
**
**  'Stat' is the type of statements.
**
**  If 'Stat' is different  from 'Expr', then  a lot of things will  probably
**  break.
*/
typedef UInt Stat;


/****************************************************************************
**
*T  Expr  . . . . . . . . . . . . . . . . . . . . . . . . type of expressions
**
**  'Expr' is the type of expressions.
**
**  If 'Expr' is different  from 'Stat', then  a lot of things will  probably
**  break.
*/
typedef Stat Expr;


/****************************************************************************
**
*V  BIPEB . . . . . . . . . . . . . . . . . . . . . . . . . .  bits per block
**
**  'BIPEB' is the  number of bits  per  block, where a  block  fills a UInt,
**  which must be the same size as a bag identifier.
**  'LBIPEB' is the log to the base 2 of BIPEB
**
*/
enum { BIPEB = sizeof(UInt) * 8L, LBIPEB = (BIPEB == 64) ? 6L : 5L };


/****************************************************************************
**
*F * * * * * * * * * * * command line settable options  * * * * * * * * * * *
*/


/****************************************************************************
**
*V  SyArchitecture  . . . . . . . . . . . . . . . .  name of the architecture
*/
extern const Char * SyArchitecture;

/****************************************************************************
**
*V  SyKernelVersion  . . . . . . . . . . . . . . . .  kernel version number
*V  SyBuildVersion . . . . . . . . . . . . . . . . .  kernel version number
*V  SyBuildDateTime  . . . . . . . . . . . . . . . .  kernel build time
**
**  'SyBuildVersion' will replace 'SyKernelVersion'.
*/
extern const Char * SyKernelVersion;
extern const Char * SyBuildVersion;
extern const Char * SyBuildDateTime;

/****************************************************************************
**
*V  SyCTRD  . . . . . . . . . . . . . . . . . . .  true if '<ctr>-D' is <eof>
*/
extern UInt SyCTRD;


/****************************************************************************
**
*V  SyCompileInput  . . . . . . . . . . . . . . . . . .  from this input file
*/
extern Char SyCompileInput[GAP_PATH_MAX];


/****************************************************************************
**
*V  SyCompileMagic1 . . . . . . . . . . . . . . . . . . and this magic number
*/
extern Char * SyCompileMagic1;


/****************************************************************************
**
*V  SyCompileName . . . . . . . . . . . . . . . . . . . . . .  with this name
*/
extern Char SyCompileName[256];


/****************************************************************************
**
*V  SyCompileOutput . . . . . . . . . . . . . . . . . . into this output file
*/
extern Char SyCompileOutput[GAP_PATH_MAX];


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
**  In addition we store the path to the users ~/.gap directory, if available,
**  in 'DotGapPath'.
**  
**  Put in this package because the command line processing takes place here.
*/
enum {
    MAX_GAP_DIRS = 16
};
extern Char SyGapRootPaths[MAX_GAP_DIRS][GAP_PATH_MAX];
#ifdef HAVE_DOTGAPRC
extern Char DotGapPath[GAP_PATH_MAX];
#endif

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
*V  SyUseReadline   . . . . . . . . . . . . . . . . . .  support line editing
**
**  Switch for not using readline although GAP is compiled with libreadline
*/
extern UInt SyUseReadline;

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
*V  SyQuitOnBreak . . . . . . . . . . exit GAP instead of entering break loop
**
**  'SyQuitOnBreak' determines whether GAP should quit (with non-zero return
**  value) instead of entering the break loop.
**
**  False by default, can be changed with the '--quitonbreak' option.
**
**  Put in this package because the command line processing takes place here.
*/
extern UInt SyQuitOnBreak;

/****************************************************************************
**
*V  SyRestoring . . . . . . . . . . . . . . . . . . . . restoring a workspace
**
**  'SyRestoring' determines whether GAP is restoring a workspace or not.  If
**  it is zero no restoring should take place otherwise it holds the filename
**  of a workspace to restore.
**
*/
extern Char * SyRestoring;

/****************************************************************************
**
*V  SyInitializing                               set to 1 during library init
**
**  'SyInitializing' is set to 1 during the library intialization phase of
**  startup. It supresses some behaviours that may not be possible so early
**  such as homogeneity tests in the plist code.
*/

extern UInt SyInitializing;

extern Char **SyOriginalArgv;
extern UInt SyOriginalArgc;

/****************************************************************************
**
*V  SyLoadSystemInitFile  . . . . . . should GAP load 'lib/init.g' at startup
*/
extern Int SyLoadSystemInitFile;


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
*F  SyTime()  . . . . . . . . . . . . . . . return time spent in milliseconds
**
**  'SyTime' returns the number of milliseconds spent by GAP so far.
**
**  Should be as accurate as possible,  because it  is  used  for  profiling.
*/
extern UInt SyTime ( void );

/* TODO: Properly document the following three calls */
extern UInt SyTimeSys ( void );
extern UInt SyTimeChildren ( void );
extern UInt SyTimeChildrenSys ( void );

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
*F  IsHexDigit( <ch> ) . . . . . . . . . . . . . . .  is a character a digit
**
**  'IsDigit' returns 1 if its character argument is a digit from the ranges
**  '0..9', 'A..F', or 'a..f' and 0 otherwise.
*/
#define IsHexDigit(ch)     (isxdigit((unsigned int)ch))

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
*F  strlcpy( <dst>, <src>, <len> )
**
**  Copy <src> to buffer <dst> of size <len>. At most <len>-1 characters will
**  be copied. Afterwards, <dst> is always 'NUL' terminated
**  (unless <len> == 0).
**
**  Returns 'strlen( <src> )'; hence if the return value is greater or equal
**  than <len>, truncation occurred.
**
**  This function is provided by some systems (e.g. OpenBSD, Mac OS X),
**  but not by all, so we provide a fallback implementation for those
**  systems that lack it.
*/
#ifndef HAVE_STRLCPY
size_t strlcpy (
    char *dst,
    const char *src,
    size_t len);
#endif

/****************************************************************************
**
*F  strlcat( <dst>, <src>, <len> )
**
**  Appends <src> to buffer <dst> of size <len> (unlike 'strncat', <len> is
**  the full size of <dst>, not space left).
**  At most <len>-1 characters will be copied.
**  Afterwards, <dst> is always 'NUL' terminated (unless <len> == 0).
**
**  Returns initial length of <dst> plus 'strlen(<src>)'; hence if the return
**  value is greater or equal than <len>, truncation occurred.
**
**  This function is provided by some systems (e.g. OpenBSD, Mac OS X),
**  but not by all, so we provide a fallback implementation for those
**  systems that lack it.
*/
#ifndef HAVE_STRLCAT
size_t strlcat (
    char *dst,
    const char *src,
    size_t len);
#endif

/****************************************************************************
**
*F  strlncat( <dst>, <src>, <len>, <n> )
**
**  Append at most <n> characters from <src> to buffer <dst> of size <len>.
**  At most <len>-1 characters will be copied.
**  Afterwards, <dst> is always 'NUL' terminated (unless <len> == 0).
**
**  Returns initial length of <dst> plus the minimum of <n> and
**  'strlen(<src>)'; hence if the return value is greater or equal than
**  <len>, truncation occurred.
*/
size_t strlncat (
    char *dst,
    const char *src,
    size_t len,
    size_t n);

/****************************************************************************
**
*F  strxcpy( <dst>, <src>, <len> )
**
**  Copy <src> to buffer <dst> of size <len>.
**  If an overflow would occur, trigger an assertion.
**
**  This should be used with caution; in general, proper error handling is
**  preferable.
**/
size_t strxcpy (
    char *dst,
    const char *src,
    size_t len);

/****************************************************************************
**
*F  strxcat( <dst>, <src>, <len> )
**
**  Append <src> to buffer <dst> of size <len>.
**  If an overflow would occur, trigger an assertion.
**
**  This should be used with caution; in general, proper error handling is
**  preferable.
**/
size_t strxcat (
    char *dst,
    const char *src,
    size_t len);

/****************************************************************************
**
*F  strxncat( <dst>, <src>, <len>, <n> )
**
**  Append not more than <n> characters from <src> to buffer <dst> of size
**  <len>.
**  If an overflow would occur, trigger an assertion.
**
**  This should be used with caution; in general, proper error handling is
**  preferable.
**/
size_t strxncat (
    char *dst,
    const char *src,
    size_t len,
    size_t n);


typedef struct init_info StructInitInfo;
typedef StructInitInfo* (*InitInfoFunc)(void);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
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
extern void SyExit(UInt ret) NORETURN;


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
extern Int8 SyNanosecondsSinceEpoch();
extern Int8 SyNanosecondsSinceEpochResolution();

extern const char * const SyNanosecondsSinceEpochMethod;
extern const Int SyNanosecondsSinceEpochMonotonic;

/****************************************************************************
**
*F  SySleep( <secs> ) . . . . . . . . . . . . Try to sleep for <secs> seconds
**
**  The OS may wake us earlier, for example on receipt of a signal
*/

extern void SySleep( UInt secs );

/****************************************************************************
**
*F  SyUSleep( <msecs> ) . . . . . . . . .Try to sleep for <msecs> microseconds
**
**  The OS may wake us earlier, for example on receipt of a signal
*/

extern void SyUSleep( UInt msecs );

/****************************************************************************
**
*F  sySetjmp( <jump buffer> )
*F  syLongjmp( <jump buffer>, <value> )
** 
**  macros and functions, defining our selected longjump mechanism
*/

#if defined(HAVE_SIGSETJMP)
#define sySetjmp( buff ) (sigsetjmp( (buff), 0))
#define syLongjmpInternal siglongjmp
#define syJmp_buf sigjmp_buf
#elif defined(HAVE__SETJMP)
#define sySetjmp _setjmp
#define syLongjmpInternal _longjmp
#define syJmp_buf jmp_buf
#else
#define sySetjmp setjmp
#define syLongjmpInternal longjmp
#define syJmp_buf jmp_buf
#endif

void syLongjmp(syJmp_buf* buf, int val) NORETURN;

/****************************************************************************
**
*F  RegisterSyLongjmpObserver( <func> )
**
**  register a function to be called before longjmp is called.
*/

typedef void (*voidfunc)(void);

Int RegisterSyLongjmpObserver(voidfunc);


/****************************************************************************
**
*F  InitSystem( <argc>, <argv> )  . . . . . . . . . initialize system package
**
**  'InitSystem' is called very early during the initialization from  'main'.
**  It is passed the command line array  <argc>, <argv>  to look for options.
**
**  For UNIX it initializes the default files 'stdin', 'stdout' and 'stderr',
**  installs the handler 'syAnswerIntr' to answer the user interrupts
**  '<ctr>-C', scans the command line for options, sets up the GAP root paths,
**  locates the '.gaprc' file (if any), and more.
*/
extern void InitSystem (
            Int                 argc,
            Char *              argv [] );

#endif // GAP_SYSTEM_H
