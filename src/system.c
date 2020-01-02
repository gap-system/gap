/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  The  files   "system.c" and  "sysfiles.c"  contains all  operating system
**  dependent  functions.  This file contains  all system dependent functions
**  except file and stream operations, which are implemented in "sysfiles.c".
**  The following labels determine which operating system is actually used.
*/

#include "system.h"

#include "gaputils.h"
#ifdef GAP_MEM_CHECK
#include "gasman_intern.h"
#endif
#include "profile.h"
#include "sysfiles.h"
#include "sysmem.h"
#include "sysopt.h"
#include "sysroots.h"
#include "sysstr.h"

#ifdef HPCGAP
#include "hpc/misc.h"
#endif

#ifdef USE_JULIA_GC
#include "julia.h"
#endif

#include <assert.h>
#include <fcntl.h>
#include <stdarg.h>
#include <time.h>
#include <unistd.h>

#include <sys/stat.h>

#ifdef SYS_IS_DARWIN
#include <mach-o/dyld.h>
#endif

#ifdef HAVE_LIBREADLINE
#include <readline/readline.h>
#endif


/****************************************************************************
**
*V  SyKernelVersion  . . . . . . . . . . . . . . . hard coded kernel version
** do not edit the following line. Occurrences of `4.dev' and `today'
** will be replaced by string matching by distribution wrapping scripts.
*/
const Char * SyKernelVersion = "4.dev";

/****************************************************************************
**
*F * * * * * * * * * * * command line settable options  * * * * * * * * * * *
*/

/****************************************************************************
**
*V  SyArchitecture  . . . . . . . . . . . . . . . .  name of the architecture
*/
const Char * SyArchitecture = GAPARCH;


/****************************************************************************
**
*V  SyCTRD  . . . . . . . . . . . . . . . . . . .  true if '<ctr>-D' is <eof>
*/
UInt SyCTRD;


/****************************************************************************
**
*V  SyCompilePlease . . . . . . . . . . . . . . .  tell GAP to compile a file
*V  SyCompileOutput . . . . . . . . . . . . . . . . . . into this output file
*V  SyCompileInput  . . . . . . . . . . . . . . . . . .  from this input file
*V  SyCompileName . . . . . . . . . . . . . . . . . . . . . .  with this name
*V  SyCompileMagic1 . . . . . . . . . . . . . . . . . . and this magic string
*/
Int SyCompilePlease;
Char * SyCompileOutput;
Char * SyCompileInput;
Char * SyCompileName;
Char * SyCompileMagic1;


/****************************************************************************
**
*V  SyDebugLoading  . . . . . . . . .  output messages about loading of files
*/
Int SyDebugLoading;


/****************************************************************************
**
*V  DotGapPath
**
**  The path to the user's ~/.gap directory, if available.
*/
static Char DotGapPath[GAP_PATH_MAX];


/****************************************************************************
**
*V  IgnoreGapRC . . . . . . . . . . . . . . . . . . . -r option for kernel
**
*/
static Int IgnoreGapRC;

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
**  'SyMsgsFlagBags' determines whether garbage collections are reported  or
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
**  `SyInitializing' is set to 1 during the library initialization phase of
**  startup. It suppresses some behaviours that may not be possible so early
**  such as homogeneity tests in the plist code.
*/

UInt SyInitializing;


/****************************************************************************
**
*V  SyLoadSystemInitFile  . . . . . . should GAP load 'lib/init.g' at startup
*/
Int SyLoadSystemInitFile = 1;


/****************************************************************************
**
*V  SyUseModule . . . . . . . . . check for static modules in 'READ_GAP_ROOT'
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
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  SyExit( <ret> ) . . . . . . . . . . . . . exit GAP with return code <ret>
**
**  'SyExit' is the official way  to exit GAP, bus errors are the unofficial.
**  The function 'SyExit' must perform all the necessary cleanup operations.
**  If ret is 0 'SyExit' should signal to a calling process that all is  ok.
**  If ret is 1 'SyExit' should signal a  failure  to  the  calling process.
**
**  If the user calls 'QUIT_GAP' with a value, then the global variable
**  'UserHasQUIT' will be set, and their requested return value will be
**  in 'SystemErrorCode'. If the return value would be 0, we check
**  this value and use it instead.
*/
void SyExit (
    UInt                ret )
{
#ifdef USE_JULIA_GC
    jl_atexit_hook(ret);
#endif
    exit( (int)ret );
}


/****************************************************************************
**
*F  Panic( <msg> )
*/
void Panic_(const char * file, int line, const char * fmt, ...)
{
    fprintf(stderr, "Panic in %s:%d: ", file, line);
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end (args);
    fputs("\n", stderr);
    SyExit(1);
}


/****************************************************************************
**
*F * * * * * * * * * * finding location of executable * * * * * * * * * * * *
*/

/****************************************************************************
** The function 'find_yourself' is based on code (C) 2015 Mark Whitis, under
** the MIT License : https://stackoverflow.com/a/34271901/928031
*/

static void
find_yourself(const char * argv0, char * result, size_t resultsize)
{
    GAP_ASSERT(resultsize >= GAP_PATH_MAX);

    char tmpbuf[GAP_PATH_MAX];

    // absolute path, like '/usr/bin/gap'
    if (argv0[0] == '/') {
        if (realpath(argv0, result) && !access(result, F_OK)) {
            return;    // success
        }
    }
    // relative path, like 'bin/gap.sh'
    else if (strchr(argv0, '/')) {
        if (!getcwd(tmpbuf, sizeof(tmpbuf)))
            return;
        strlcat(tmpbuf, "/", sizeof(tmpbuf));
        strlcat(tmpbuf, argv0, sizeof(tmpbuf));
        if (realpath(tmpbuf, result) && !access(result, F_OK)) {
            return;    // success
        }
    }
    // executable name, like 'gap'
    else {
        char pathenv[GAP_PATH_MAX], *saveptr, *pathitem;
        strlcpy(pathenv, getenv("PATH"), sizeof(pathenv));
        pathitem = strtok_r(pathenv, ":", &saveptr);
        for (; pathitem; pathitem = strtok_r(NULL, ":", &saveptr)) {
            strlcpy(tmpbuf, pathitem, sizeof(tmpbuf));
            strlcat(tmpbuf, "/", sizeof(tmpbuf));
            strlcat(tmpbuf, argv0, sizeof(tmpbuf));
            if (realpath(tmpbuf, result) && !access(result, F_OK)) {
                return;    // success
            }
        }
    }

    *result = 0;    // reset buffer after error
}


static char GAPExecLocation[GAP_PATH_MAX] = "";

static void SetupGAPLocation(const char * argv0)
{
    // In the code below, we keep reseting locBuf, as some of the methods we
    // try do not promise to leave the buffer empty on a failed return.
    char locBuf[GAP_PATH_MAX] = "";
    Int4 length = 0;

#ifdef SYS_IS_DARWIN
    uint32_t len = sizeof(locBuf);
    if (_NSGetExecutablePath(locBuf, &len) != 0) {
        *locBuf = 0;    // reset buffer after error
    }
#endif

    // try Linux procfs
    if (!*locBuf) {
        ssize_t ret = readlink("/proc/self/exe", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
    }

    // try FreeBSD / DragonFly BSD procfs
    if (!*locBuf) {
        ssize_t ret = readlink("/proc/curproc/file", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
    }

    // try NetBSD procfs
    if (!*locBuf) {
        ssize_t ret = readlink("/proc/curproc/exe", locBuf, sizeof(locBuf));
        if (ret < 0)
            *locBuf = 0;    // reset buffer after error
    }

    // if we are still failing, go and search the path
    if (!*locBuf) {
        find_yourself(argv0, locBuf, GAP_PATH_MAX);
    }

    // resolve symlinks (if present)
    if (!realpath(locBuf, GAPExecLocation))
        *GAPExecLocation = 0;    // reset buffer after error

    // now strip the executable name off
    length = strlen(GAPExecLocation);
    while (length > 0 && GAPExecLocation[length] != '/') {
        GAPExecLocation[length] = 0;
        length--;
    }
}


/****************************************************************************
**
*F  SyDotGapPath()
*/
const Char * SyDotGapPath(void)
{
    return DotGapPath;
}


/****************************************************************************
**
*F  SySetInitialGapRootPaths( <string> )  . . . . .  set the root directories
**
**  Set up GAP's initial root paths, based on the location of the
**  GAP executable.
*/
static void SySetInitialGapRootPaths(void)
{
    if (GAPExecLocation[0] != 0) {
        // GAPExecLocation might be a subdirectory of GAP root,
        // so we will go and search for the true GAP root.
        // We try stepping back up to two levels.
        char pathbuf[GAP_PATH_MAX];
        char initgbuf[GAP_PATH_MAX];
        strxcpy(pathbuf, GAPExecLocation, sizeof(pathbuf));
        for (Int i = 0; i < 3; ++i) {
            strxcpy(initgbuf, pathbuf, sizeof(initgbuf));
            strxcat(initgbuf, "lib/init.g", sizeof(initgbuf));

            if (SyIsReadableFile(initgbuf) == 0) {
                SySetGapRootPath(pathbuf);
                // escape from loop
                return;
            }
            // try up a directory level
            strxcat(pathbuf, "../", sizeof(pathbuf));
        }
    }

    // Set GAP root path to current directory, if we have no other
    // idea, and for backwards compatibility.
    // Note that GAPExecLocation must always end with a slash.
    SySetGapRootPath("./");
}


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

typedef struct { Char symbol; UInt value; } sizeMultiplier;

static sizeMultiplier memoryUnits[]= {
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
  double size = atof(s);
  Char symbol =  s[strlen(s)-1];
  UInt i;
  UInt maxmem;
#ifdef SYS_IS_64_BIT
  maxmem = 15000000000000000000UL;
#else
  maxmem = 4000000000UL;
#endif
  
  for (i = 0; i < ARRAY_SIZE(memoryUnits); i++) {
    if (symbol == memoryUnits[i].symbol) {
      UInt value = memoryUnits[i].value;
      if (size > maxmem/value)
        return maxmem;
      else
        return size * value;
    }      
  }
  if (!IsDigit(symbol))
    fputs("Unrecognised memory unit ignored", stderr);
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

#ifdef HPCGAP
static Int storePosInteger( Char **argv, void *Where )
{
  UInt *where = (UInt *)Where;
  UInt n;
  Char *p = argv[0];
  n = 0;
  while (IsDigit(*p)) {
    n = n * 10 + (*p-'0');
    p++;
  }
  if (p == argv[0] || *p || n == 0)
    fputs("Argument not a positive integer", stderr);
  *where = n;
  return 1;
}
#endif

static Int storeString( Char **argv, void *Where )
{
  Char **where = (Char **)Where;
  *where = argv[0];
  return 1;
}

#ifdef USE_GASMAN
static Int storeMemory( Char **argv, void *Where )
{
  UInt *where = (UInt *)Where;
  *where = ParseMemory(argv[0]);
  return 1;
}
#endif

static Int storeMemory2( Char **argv, void *Where )
{
  UInt *where = (UInt *)Where;
  *where = ParseMemory(argv[0])/1024;
  return 1;
}

static Int processCompilerArgs( Char **argv, void * dummy)
{
    SyCompilePlease = 1;
    SyCompileOutput = argv[0];
    SyCompileInput = argv[1];
    SyCompileName = argv[2];
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


#ifndef GAP_MEM_CHECK
// Provide stub with helpful error message

static Int enableMemCheck(Char ** argv, void * dummy)
{
    SyFputs( "# Error: --enableMemCheck not supported by this copy of GAP\n", 3);
    SyFputs( "  pass --enable-memory-checking to ./configure\n", 3 );
    SyExit(2);
}
#endif


/* These are just the options that need kernel processing. Additional options will be 
   recognised and handled in the library */

/* These options must be kept in sync with those in system.g, so the help output
   is correct */
static const struct optInfo options[] = {
  { 'B',  "architecture", storeString, &SyArchitecture, 1}, /* default architecture needs to be passed from kernel 
                                                                  to library. Might be needed for autoload of compiled files */
  { 'C',  "", processCompilerArgs, 0, 4}, /* must handle in kernel */
  { 'D',  "debug-loading", toggle, &SyDebugLoading, 0}, /* must handle in kernel */
  { 'K',  "maximal-workspace", storeMemory2, &SyStorKill, 1}, /* could handle from library with new interface */
  { 'L', "", storeString, &SyRestoring, 1}, /* must be handled in kernel  */
  { 'M', "", toggle, &SyUseModule, 0}, /* must be handled in kernel */
  { 'R', "", unsetString, &SyRestoring, 0}, /* kernel */
  { 'e', "", toggle, &SyCTRD, 0 }, /* kernel */
  { 'f', "", forceLineEditing, (void *)2, 0 }, /* probably library now */
  { 'E', "", toggle, &SyUseReadline, 0 }, /* kernel */
  { 'l', "roots", setGapRootPath, 0, 1}, /* kernel */
  { 'm', "", storeMemory2, &SyStorMin, 1 }, /* kernel */
  { 'r', "", toggle, &IgnoreGapRC, 0 }, /* kernel */
#ifdef USE_GASMAN
  { 's', "", storeMemory, &SyAllocPool, 1 }, /* kernel */
#endif
  { 'n', "", forceLineEditing, 0, 0}, /* prob library */
#ifdef USE_GASMAN
  { 'o', "", storeMemory2, &SyStorMax, 1 }, /* library with new interface */
#endif
  { 'p', "", toggle, &SyWindow, 0 }, /* ?? */
  { 'q', "", toggle, &SyQuiet, 0 }, /* ?? */
#ifdef HPCGAP
  { 'S', "", toggle, &ThreadUI, 0 }, /* Thread UI */
  { 'Z', "", toggle, &DeadlockCheck, 0 }, /* Deadlock prevention */
  { 'P', "", storePosInteger, &SyNumProcessors, 1 }, /* number of CPUs */
  { 'G', "", storePosInteger, &SyNumGCThreads, 1 }, /* number of GC threads */
  { 0  , "single-thread", toggle, &SingleThreadStartup, 0 }, /* startup with one thread only */
#endif
  /* The following options must be handled in the kernel so they are set up before loading the library */
  { 0  , "prof", enableProfilingAtStartup, 0, 1},    /* enable profiling at startup */
  { 0  , "memprof", enableMemoryProfilingAtStartup, 0, 1 }, /* enable memory profiling at startup */
  { 0  , "cover", enableCodeCoverageAtStartup, 0, 1}, /* enable code coverage at startup */
  { 0  , "quitonbreak", toggle, &SyQuitOnBreak, 0}, /* Quit GAP if we enter the break loop */
  { 0  , "enableMemCheck", enableMemCheck, 0, 0 },
  { 0, "", 0, 0, 0}};


Char ** SyOriginalArgv;
UInt SyOriginalArgc;

 

void InitSystem (
    Int                 argc,
    Char *              argv [],
    UInt                handleSignals )
{
    UInt                i;             /* loop variable                   */
    Int res;                       /* return from option processing function */

    /* Initialize global and static variables */
    SyCTRD = 1;             
    SyCompilePlease = 0;
    SyDebugLoading = 0;
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

    SyStorMin = 16 * sizeof(Obj) * 1024;    // in kB
    SyStorMax = 256 * sizeof(Obj) * 1024;   // in kB
#ifdef SYS_IS_64_BIT
  #if defined(HAVE_SYSCONF) && defined(_SC_PAGESIZE) && defined(_SC_PHYS_PAGES)
    // Set to 3/4 of memory size (in kB), if this is larger
    Int SyStorMaxFromMem =
        (sysconf(_SC_PAGESIZE) * sysconf(_SC_PHYS_PAGES) * 3) / 4 / 1024;
    SyStorMax = SyStorMaxFromMem > SyStorMax ? SyStorMaxFromMem : SyStorMax;
  #endif
#endif // defined(SYS_IS_64_BIT)

#ifdef USE_GASMAN
#ifdef SYS_IS_64_BIT
    SyAllocPool = 4096L*1024*1024;   /* Note this is in bytes! */
#else
    SyAllocPool = 1536L*1024*1024;   /* Note this is in bytes! */
#endif // defined(SYS_IS_64_BIT)
    SyStorOverrun = 0;
    SyStorKill = 0;
#endif // defined(USE_GASMAN)
    SyUseModule = 1;
    SyWindow = 0;

    for (i = 0; i < 2; i++) {
      UInt j;
      for (j = 0; j < 7; j++) {
        SyGasmanNumbers[i][j] = 0;
      }
    }

    InitSysFiles();

#ifdef HAVE_LIBREADLINE
    rl_readline_name = "GAP";
    rl_initialize ();
#endif
    
    if (handleSignals) {
        SyInstallAnswerIntr();
    }

#if defined(SYS_DEFAULT_PATHS)
    SySetGapRootPath( SYS_DEFAULT_PATHS );
#else
    SetupGAPLocation(argv[0]);
    SySetInitialGapRootPaths();
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
            fputs("gap: sorry, options must not be grouped '", stderr);
            fputs(argv[1], stderr);
            fputs("'.\n", stderr);
            goto usage;
          }


          for (i = 0;  options[i].shortkey != argv[1][1] &&
                       (argv[1][1] != '-' || argv[1][2] == 0 || strcmp(options[i].longkey, argv[1] + 2)) &&
                       (options[i].shortkey != 0 || options[i].longkey[0] != 0); i++)
            ;

        


          if (argc < 2 + options[i].minargs)
            {
              Char buf[2];
              fputs("gap: option ", stderr);
              fputs(argv[1], stderr);
              fputs(" requires at least ", stderr);
              buf[0] = options[i].minargs + '0';
              buf[1] = '\0';
              fputs(buf, stderr);
              fputs(" arguments\n", stderr);
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
#if !defined(HAVE_LIBREADLINE)
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

#ifdef USE_GASMAN
    /* fix pool size if larger than SyStorKill */
    if ( SyStorKill != 0 && SyAllocPool != 0 &&
                            SyAllocPool > 1024 * SyStorKill ) {
        SyAllocPool = SyStorKill * 1024;
    }
#endif

    /* when running in package mode set ctrl-d and line editing            */
    if ( SyWindow ) {
        SyRedirectStderrToStdOut();
        syWinPut( 0, "@p", "1." );
    }

    /* should GAP load 'init/lib.g' on initialization */
    if ( SyCompilePlease || SyRestoring ) {
        SyLoadSystemInitFile = 0;
    }

    /* the users home directory                                            */
    if ( getenv("HOME") != 0 ) {
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
    }


    /* now we start                                                        */
    return;

    /* print a usage message                                               */
usage:
 fputs("usage: gap [OPTIONS] [FILES]\n", stderr);
 fputs("       run the Groups, Algorithms and Programming system, Version ", stderr);
 fputs(SyBuildVersion, stderr);
 fputs("\n", stderr);
 fputs("       use '-h' option to get help.\n", stderr);
 fputs("\n", stderr);
 SyExit( 1 );
}
