/****************************************************************************
**
*W  profile.c                     GAP source              Chris Jefferson
**
**
*Y  Copyright (C) 2014 The GAP Group
**
**  This file contains profile related functionality.
**
*/
#include <src/system.h>                 /* system dependent part */


#include <src/sysfiles.h>               /* file input/output */

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/bool.h>                   /* booleans */

#include <src/code.h>                   /* coder */
#include <src/vars.h>                   /* variables */
#include <src/exprs.h>                  /* expressions */

#include <src/intrprtr.h>               /* interpreter */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/stats.h>                  /* statements */

#include <assert.h>

#include <src/profile.h>
#include <src/hookintrprtr.h>

#include <src/hpc/thread.h>

#include <src/calls.h>                  /* function filename, line number */

/****************************************************************************
**
** Overview of GAP profiling
**
** The basic idea behind profiling comes in two parts:
**
** 1) In each stat and expr, we store at creation time a filenameid and a
**    line number. This is always done (as it isn't very expensive)
**
** 2) When we want to profile, we wrap each of
**      - ExecStatFuncs
**      - ExecExprFuncs
**      - EvalBoolFuncs
**    and output the line number of filename we stored in the stat or expr.
**    We also use 1 bit to mark that we have executed this statement, so
**    we can (if we want to) only output each executed statement once.
**
**    We use this information in a few ways:
**
**  1) Output a straight list of every executed statement
**  2) Provide coloured printing (by wrapping PrintStatFuncs and PrintExprFuncs)
**     which show which parts of an expression have been executed
**
**  There are not that many tricky cases here. We have to be careful that
**  some Expr are integers or local variables, and not touch those.
**
**  Limitations (and how we overcome them):
**
**  There are three main limitations to this approach (2 of which we handle)
**
**  1) From our initial trace, we don't know if a line has a statement on
**     it to be executed! Therefore we also provide the ability to store the
**     line of each created statement, so we can chck which lines have code
**     on them.
**
**  2) If we wait until the user can run HookedLine, they have missed
**     the reading and execution of lots of the standard library. Therefore
**     we provide -P (profiling) and -c (code coverage) options to the GAP
**     executable so the user can start before code loading starts
**
**  3) Operating at just a line basis can sometimes be too course. We can
**     see this when we use ActivateProfileColour. However, without some
**     serious additional overheads, I can't see how to provide this
**     functionality in output (basically we would have to store
**     line and character positions for the start and end of every expression).
**
**
**  Achieving 100% code coverage is a little tricky. Here is a list of
**  the special cases which had to be considered (so far)
**
**  GAP special cases for-loops of the form 'for i in [a..b]', by digging
**  into the range to extract 'a' and 'b'. Therefore nothing on the line is
**  ever evaluated and it appears to never be executed. We special case this
**  if ForRange, by marking the range as evaluated.
**
**  We purposesfully ignore T_TRUE_EXPR and T_FALSE_EXPR, which represent the
**  constants 'true' and 'false', as they are often read but not 'executed'.
**  We already ignored all integer and float constants anyway.
**  However, the main reason this was added is that GAP represents 'else'
**  as 'elif true then', and this was leading to 'else' statements being
**  never marked as executed.
*/


/****************************************************************************
**
** Store the current state of the profiler
*/

#include <sys/time.h>                   /* for gettimeofday */

#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>               /* definition of 'struct rusage' */
#endif

Obj OutputtedFilenameList;

struct StatementLocation
{
    int fileID;
    int line;
};

struct ProfileState
{
  // C steam we are writing to
  FILE* Stream;
  // Did we use 'popen' to open the stream (matters when closing)
  int StreamWasPopened;
  // Are we currently outputting repeats (false=code coverage)
  Int OutputRepeats;
  // Are we colouring output (not related to profiling directly)
  Int ColouringOutput;

  // Used to generate 'X' statements, to make sure we correctly
  // attach each function call to the line it was executed on
  struct StatementLocation lastNotOutputted;


  // Record last executed statement, to avoid repeats
  struct StatementLocation lastOutputted;
  int lastOutputtedExec;

  Int8 lastOutputtedTime;

  int useGetTimeOfDay;

  int minimumProfileTick;
#ifdef HPCGAP
  int profiledThread;
#endif

  /* Have we previously profiled this execution of GAP? We need this because
  ** code coverage doesn't work more than once, as we use a bit in each Stat
  ** to mark if we previously executed this statement, which we can't
  ** clear */
  UInt profiledPreviously;

} profileState;

/* We keep this seperate as it is exported for use in other files */
UInt profileState_Active;



void HookedLineOutput(Obj func, char type)
{
  HashLock(&profileState);
  if(profileState_Active && profileState.OutputRepeats)
  {
    int startline_i = 0, endline_i = 0;
    Obj startline = FuncSTARTLINE_FUNC(0, func);
    Obj endline = FuncENDLINE_FUNC(0, func);
    if(IS_INTOBJ(startline)) {
      startline_i = INT_INTOBJ(startline);
    }
    if(IS_INTOBJ(endline)) {
      endline_i = INT_INTOBJ(endline);
    }

    Obj name = NAME_FUNC(func);
    Char *name_c = ((UInt)name) ? (Char *)CHARS_STRING(name) : (Char *)"nameless";

    Obj filename = FuncFILENAME_FUNC(0, func);
    Char *filename_c = (Char*)"<missing filename>";
    if(filename != Fail && filename != NULL)
      filename_c = (Char *)CHARS_STRING(filename);

    if(type == 'I' && profileState.lastNotOutputted.line != -1)
    {
      fprintf(profileState.Stream, "{\"Type\":\"X\",\"Line\":%d,\"FileId\":%d}\n",
              (int)profileState.lastNotOutputted.line,
              (int)profileState.lastNotOutputted.fileID);
    }

    fprintf(profileState.Stream,
            "{\"Type\":\"%c\",\"Fun\":\"%s\",\"Line\":%d,\"EndLine\":%d,\"File\":\"%s\"}\n",
            type, name_c, startline_i, endline_i, filename_c);
  }
  HashUnlock(&profileState);
}

void enterFunction(Obj func)
{ HookedLineOutput(func, 'I'); }

void leaveFunction(Obj func)
{ HookedLineOutput(func, 'O'); }

/****************************************************************************
**
** Functionality to store streams compressed.
** If we could rely on the existence of the IO package, we would use that here.
** however, we want to be able to start compressing files right at the start
** of GAP's execution, before anything else is done.
*/

#ifdef HAVE_POPEN
static int endsWithgz(char* s)
{
  s = strrchr(s, '.');
  if(s)
    return strcmp(s, ".gz") == 0;
  else
    return 0;
}
#endif

static void fopenMaybeCompressed(char* name, struct ProfileState* ps)
{
#ifdef HAVE_POPEN
  char popen_buf[4096];
  if(endsWithgz(name) && strlen(name) < 3000)
  {
    strcpy(popen_buf, "gzip > ");
    strcat(popen_buf, name);
    ps->Stream = popen(popen_buf, "w");
    ps->StreamWasPopened = 1;
    return;
  }
#endif

  ps->Stream = fopen(name, "w");
  ps->StreamWasPopened = 0;
}

static void fcloseMaybeCompressed(struct ProfileState* ps)
{
#ifdef HAVE_POPEN
  if(ps->StreamWasPopened)
  {
    pclose(ps->Stream);
    ps->Stream = 0;
    return;
  }
#endif
  fclose(ps->Stream);
  ps->Stream = 0;
}


/****************************************************************************
**
** These functions are only used when profiling is enabled. They output
** as approriate, and then pass through to the true function
*/

// This function checks if we have ever printed out the id of stat
static inline UInt getFilenameId(Stat stat)
{
  UInt id = FILENAMEID_STAT(stat);
  if (id == 0) {
    return 0;
  }
  if (LEN_PLIST(OutputtedFilenameList) < id ||
      ELM_PLIST(OutputtedFilenameList, id) != True) {
    AssPlist(OutputtedFilenameList, id, True);
    fprintf(profileState.Stream, "{\"Type\":\"S\",\"File\":\"%s\",\"FileId\":%d}\n",
                                  CSTR_STRING(FILENAME_STAT(stat)), (int)id);
  }
  return id;
}

static inline Int8 CPUmicroseconds(void)
{
#ifdef HAVE_GETRUSAGE
  struct rusage buf;

  getrusage( RUSAGE_SELF, &buf );

  return (Int8)buf.ru_utime.tv_sec * 1000000 + (Int8)buf.ru_utime.tv_usec;
#else
  // Should never get here!
  abort();
#endif
}

// exec : are we executing this statement
// visit: Was this statement previously visited (that is, executed)
static inline void outputStat(Stat stat, int exec, int visited)
{
  UInt line;
  int nameid;

  Int8 ticks = 0, newticks = 0;

  // Explicitly skip these two cases, as they are often specially handled
  // and also aren't really interesting statements (something else will
  // be executed whenever they are).
  if(TNUM_STAT(stat) == T_TRUE_EXPR || TNUM_STAT(stat) == T_FALSE_EXPR) {
    return;
  }

  // Catch the case we arrive here and profiling is already disabled
  if(!profileState_Active) {
    return;
  }

  nameid = getFilenameId(stat);

  // Statement not attached to a file
  if(nameid == 0)
  {
    return;
  }

  line = LINE_STAT(stat);
  if(profileState.lastOutputted.line != line ||
     profileState.lastOutputted.fileID != nameid ||
     profileState.lastOutputtedExec != exec)
  {

    if(profileState.OutputRepeats) {
      if(profileState.useGetTimeOfDay) {
        newticks = SyNanosecondsSinceEpoch() / 1000;
      }
      else {
        newticks = CPUmicroseconds();
      }

      ticks = newticks - profileState.lastOutputtedTime;

      // Basic sanity check
      if(ticks < 0)
        ticks = 0;
      if((profileState.minimumProfileTick == 0)
         || (ticks > profileState.minimumProfileTick)
         || (!visited)) {
        int ticksDone;
        if(profileState.minimumProfileTick == 0) {
          ticksDone = ticks;
        } else {
          ticksDone = (ticks/profileState.minimumProfileTick) * profileState.minimumProfileTick;
        }
        ticks -= ticksDone;
        fprintf(profileState.Stream, "{\"Type\":\"%c\",\"Ticks\":%d,\"Line\":%d,\"FileId\":%d}\n",
                exec ? 'E' : 'R', ticksDone, (int)line, (int)nameid);
        profileState.lastOutputtedTime = newticks;
        profileState.lastNotOutputted.line = -1;
        profileState.lastOutputted.line = line;
        profileState.lastOutputted.fileID = nameid;
        profileState.lastOutputtedExec = exec;
      }
      else {
        profileState.lastNotOutputted.line = line;
        profileState.lastNotOutputted.fileID = nameid;
      }
    }
    else {
      fprintf(profileState.Stream, "{\"Type\":\"%c\",\"Line\":%d,\"FileId\":%d}\n",
              exec ? 'E' : 'R', (int)line, (int)nameid);
      profileState.lastOutputted.line = line;
      profileState.lastOutputted.fileID = nameid;
      profileState.lastOutputtedExec = exec;
      profileState.lastNotOutputted.line = -1;
    }
  }
}

void visitStat(Stat stat)
{
#ifdef HPCGAP
  if (profileState.profiledThread != TLS(threadID))
    return;
#endif

  int visited = VISITED_STAT(stat);

  if (!visited) {
    STAT_HEADER(stat)->visited = 1;
  }

  if (profileState.OutputRepeats || !visited) {
    HashLock(&profileState);
    outputStat(stat, 1, visited);
    HashUnlock(&profileState);
  }
}

/****************************************************************************
**
** Activating and deacivating profiling, either at startup or by user request
*/

void outputVersionInfo(void)
{
    fprintf(profileState.Stream, 
            "{ \"Type\": \"_\", \"Version\":1, \"IsCover\": %s, "
            "  \"TimeType\": \"%s\"}\n", 
            profileState.OutputRepeats?"false":"true",
            profileState.useGetTimeOfDay?"Wall":"CPU");
  
}

/****************************************************************************
**
** This function exists to help with code coverage -- this outputs which
** lines have statements on expressions on them, so later we can
** check we executed something on those lines!
**/

void registerStat(Stat stat)
{
    int active;
    HashLock(&profileState);
    active = profileState_Active;
    if (active) {
      outputStat(stat, 0, 0);
    }
    HashUnlock(&profileState);
}


struct InterpreterHooks profileHooks = {
  visitStat, enterFunction, leaveFunction, registerStat,
 "line-by-line profiling"};


void enableAtStartup(char* filename, Int repeats)
{
    if(profileState_Active) {
        fprintf(stderr, "-P or -C can only be passed once\n");
        exit(1);
    }
    
    profileState.OutputRepeats = repeats;

    fopenMaybeCompressed(filename, &profileState);
    if(!profileState.Stream) {
        fprintf(stderr, "Failed to open '%s' for profiling output.\n", filename);
        fprintf(stderr, "Abandoning starting GAP.\n");
        exit(1);
    }

    ActivateHooks(&profileHooks);

    profileState_Active = 1;
    profileState.profiledPreviously = 1;
#ifdef HPCGAP
    profileState.profiledThread = TLS(threadID);
#endif
    profileState.lastNotOutputted.line = -1;
#ifdef HAVE_GETTIMEOFDAY
    profileState.useGetTimeOfDay = 1;
    profileState.lastOutputtedTime = SyNanosecondsSinceEpoch() / 1000;
#else
#ifdef HAVE_GETRUSAGE
    profileState.useGetTimeOfDay = 0;
    profileState.lastOutputtedTime = CPUmicroseconds();
#endif
#endif

    outputVersionInfo();
}

// This function is for when GAP is started with -c, and
// enables profiling at startup. If anything goes wrong,
// we quit straight away.
Int enableCodeCoverageAtStartup( Char **argv, void * dummy)
{
    enableAtStartup(argv[0], 0);
    return 1;
}

// This function is for when GAP is started with -P, and
// enables profiling at startup. If anything goes wrong,
// we quit straight away.
Int enableProfilingAtStartup( Char **argv, void * dummy)
{
    enableAtStartup(argv[0], 1);
    return 1;
}

Obj FuncACTIVATE_PROFILING (
    Obj                 self,
    Obj                 filename, /* filename to write to */
    Obj                 coverage,
    Obj                 wallTime,
    Obj                 resolution)
{
    if(profileState_Active) {
      return Fail;
    }

    if(profileState.profiledPreviously &&
       coverage == True) {
        ErrorMayQuit("Code coverage can only be started once per"
                     " GAP session. Please exit GAP and restart. Sorry.",0,0);
        return Fail;
    }

    OutputtedFilenameList = NEW_PLIST(T_PLIST, 0);

    if ( ! IsStringConv( filename ) ) {
        ErrorMayQuit("<filename> must be a string",0,0);
    }

    if(coverage != True && coverage != False) {
      ErrorMayQuit("<coverage> must be a boolean",0,0);
    }

    if(wallTime != True && wallTime != False) {
      ErrorMayQuit("<wallTime> must be a boolean",0,0);
    }

#ifndef HAVE_GETTIMEOFDAY
    if(wallTime == True) {
        ErrorMayQuit("This OS does not support wall-clock based timing",0,0);
    }
#endif
#ifndef HAVE_GETRUSAGE
    if(wallTime == False) {
        ErrorMayQuit("This OS does not support CPU based timing",0,0);
    }
#endif

    profileState.useGetTimeOfDay = (wallTime == True);

    if( ! IS_INTOBJ(resolution) ) {
      ErrorMayQuit("<resolution> must be an integer",0,0);
    }

    HashLock(&profileState);

    // Recheck inside lock
    if(profileState_Active) {
      HashUnlock(&profileState);
      return Fail;
    }
    int tick = INT_INTOBJ(resolution);
    if(tick < 0) {
        ErrorMayQuit("<resolution> must be a non-negative integer",0,0);
    }
    profileState.minimumProfileTick = tick;


    if(coverage == True) {
      profileState.OutputRepeats = 0;
    }
    else {
      profileState.OutputRepeats = 1;
    }

    fopenMaybeCompressed(CSTR_STRING(filename), &profileState);

    if(profileState.Stream == 0) {
      HashUnlock(&profileState);
      return Fail;
    }

    profileState_Active = 1;
    profileState.profiledPreviously = 1;
#ifdef HPCGAP
    profileState.profiledThread = TLS(threadID);
#endif
    profileState.lastNotOutputted.line = -1;

    if(wallTime == True) {
        profileState.lastOutputtedTime = SyNanosecondsSinceEpoch() / 1000;
    }
    else {
        profileState.lastOutputtedTime = CPUmicroseconds();
    }

    outputVersionInfo();
    HashUnlock(&profileState);

    // This must be after the hash unlock, as it also takes a lock
    ActivateHooks(&profileHooks);

    return True;
}

Obj FuncDEACTIVATE_PROFILING (
    Obj                 self)
{
  HashLock(&profileState);

  if(!profileState_Active) {
    HashUnlock(&profileState);
    return Fail;
  }

  fcloseMaybeCompressed(&profileState);
  profileState_Active = 0;
  HashUnlock(&profileState);

  // This must be after the hash unlock, as it also takes a lock
  DeactivateHooks(&profileHooks);

  return True;
}

Obj FuncIsLineByLineProfileActive (
    Obj self)
{
  if(profileState_Active) {
    return True;
  } else {
    return False;
  }
}

/****************************************************************************
**
** We are now into the functions which deal with colouring printing output.
** This code basically wraps all the existing print functions and will colour
** their output either green or red depending on if statements are marked
** as being executed.
*/

Int CurrentColour = 0;

static void setColour(void)
{
  if(CurrentColour == 0) {
    Pr("\x1b[0m",0L,0L);
  }
  else if(CurrentColour == 1) {
    Pr("\x1b[32m",0L,0L);
  }
  else if(CurrentColour == 2) {
    Pr("\x1b[31m",0L,0L);
  }
}

void ProfilePrintStatPassthrough(Stat stat)
{
  Int SavedColour = CurrentColour;
  if(VISITED_STAT(stat)) {
    CurrentColour = 1;
  }
  else {
    CurrentColour = 2;
  }
  setColour();
  OriginalPrintStatFuncsForHook[TNUM_STAT(stat)](stat);
  CurrentColour = SavedColour;
  setColour();
}

void ProfilePrintExprPassthrough(Expr stat)
{
  Int SavedColour = -1;
  /* There are two cases we must pass through without touching */
  /* From TNUM_EXPR */
  if(IS_REFLVAR(stat)) {
    OriginalPrintExprFuncsForHook[T_REFLVAR](stat);
  } else if(IS_INTEXPR(stat)) {
    OriginalPrintExprFuncsForHook[T_INTEXPR](stat);
  } else {
    SavedColour = CurrentColour;
    if(VISITED_STAT(stat)) {
      CurrentColour = 1;
    }
    else {
      CurrentColour = 2;
    }
    setColour();
    OriginalPrintExprFuncsForHook[TNUM_STAT(stat)](stat);
    CurrentColour = SavedColour;
    setColour();
  }
}

struct PrintHooks profilePrintHooks =
  {ProfilePrintStatPassthrough, ProfilePrintExprPassthrough};

Obj activate_colored_output_from_profile(void)
{
    HashLock(&profileState);

    if(profileState.ColouringOutput) {
      HashUnlock(&profileState);
      return Fail;
    }

    ActivatePrintHooks(&profilePrintHooks);

    profileState.ColouringOutput = 1;
    CurrentColour = 0;
    setColour();

    HashUnlock(&profileState);

    return True;
}

Obj deactivate_colored_output_from_profile(void)
{
  HashLock(&profileState);

  if(!profileState.ColouringOutput) {
    HashUnlock(&profileState);
    return Fail;
  }

  DeactivatePrintHooks(&profilePrintHooks);

  profileState.ColouringOutput = 0;
  CurrentColour = 0;
  setColour();

  HashUnlock(&profileState);

  return True;
}

Obj FuncACTIVATE_COLOR_PROFILING(Obj self, Obj arg)
{
  if(arg == True)
  {
    return activate_colored_output_from_profile();
  }
  else if(arg == False)
  {
    return deactivate_colored_output_from_profile();
  }
  else
    return Fail;
}




/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(ACTIVATE_PROFILING, 4, "string,boolean,boolean,integer"),
    GVAR_FUNC(DEACTIVATE_PROFILING, 0, ""),
    GVAR_FUNC(IsLineByLineProfileActive, 0, ""),
    GVAR_FUNC(ACTIVATE_COLOR_PROFILING, 1, "bool"),
    { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    OutputtedFilenameList = NEW_PLIST(T_PLIST, 0);
    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    InitHdlrFuncsFromTable( GVarFuncs );
    InitGlobalBag(&OutputtedFilenameList, "src/profile.c:OutputtedFileList");
    return 0;
}

static Int PostRestore ( StructInitInfo * module )
{
    /* When we restore a workspace, we start a new profile.
     * 'OutputtedFilenameList' is the only part of the profile which is
     * stored in the GAP memory space, so we need to clear it in case
     * it still has a value from a previous profile.
     */
    OutputtedFilenameList = NEW_PLIST(T_PLIST, 0);
    return 0;
}

/****************************************************************************
**
*F  InitInfoStats() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "stats",                            /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    PostRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoProfile ( void )
{
    return &module;
}
