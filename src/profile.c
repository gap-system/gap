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
#include        "system.h"              /* system dependent part           */


#include        "sysfiles.h"            /* file input/output               */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "bool.h"                /* booleans                        */

#include        "code.h"                /* coder                           */
#include        "vars.h"                /* variables                       */
#include        "exprs.h"               /* expressions                     */

#include        "intrprtr.h"            /* interpreter                     */

#include        "ariths.h"              /* basic arithmetic                */

#include        "stats.h"               /* statements                      */

#include        <assert.h>

#include        "profile.h"

#include        "calls.h"               /* function filename, line number  */

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
**  sum Expr are integers or local variables, and not touch those.
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
**  2) If we wait until the user can run ProfileLineByLine, they have missed
**     the reading and execution of lots of the standard library. Therefore
**     we provide -P (profiling) and -c (code coverage) options to the GAP
**     executable so the user can start before code loading starts
**
**  3) Operating at just a line basis can sometimes be too course. We can
**     see this when we use ActivateProfileColour. However, without some
**     serious additional overheads, I can't see how to provide this
**     functionality in output (basically we would have to store
**     line and character positions for the start and end of every expression).
*/


/****************************************************************************
**
** Store the current state of the profiler
*/

#ifdef HAVE_GETRUSAGE
#if HAVE_SYS_TIME_H
# include       <sys/time.h>            /* definition of 'struct timeval'  */
#endif
#if HAVE_SYS_RESOURCE_H
# include       <sys/resource.h>        /* definition of 'struct rusage'   */
#endif
#endif
#ifdef HAVE_GETTIMEOFDAY
# include       <sys/time.h>            /* for gettimeofday                */
#endif

Obj OutputtedFilenameList;

struct ProfileState
{
  UInt Active;
  FILE* Stream;
  int StreamWasPopened;
  Int OutputRepeats;
  Int ColouringOutput;

  int lastOutputtedFileID;
  int lastOutputtedLine;
  int lastOutputtedExec;  

#if defined(HAVE_GETRUSAGE) || defined(HAVE_GETTIMEOFDAY)
  struct timeval lastOutputtedTime;
#endif
  
  int minimumProfileTick;
} profileState;

void ProfileLineByLineOutput(Obj func, char type)
{ 
  if(profileState.Active && profileState.OutputRepeats)
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
    
    fprintf(profileState.Stream,
            "{\"Type\":\"%c\",\"Fun\":\"%s\",\"Line\":%d,\"EndLine\":%d,\"File\":\"%s\"}\n",
            type, name_c, startline_i, endline_i, filename_c);
  }
}

void ProfileLineByLineIntoFunction(Obj func)
{ ProfileLineByLineOutput(func, 'I'); }

          
void ProfileLineByLineOutFunction(Obj func)
{ ProfileLineByLineOutput(func, 'O'); }

/****************************************************************************
**
** Functionality to store streams compressed.
** If we could rely on the existence of the IO package, we would use that here.
** however, we want to be able to start compressing files right at the start
** of GAP's execution, before anything else is done.
*/

static int endsWithgz(char* s)
{
  s = strrchr(s, '.');
  if(s)
    return strcmp(s, ".gz") == 0;
  else
    return 0;
}

static void fopenMaybeCompressed(char* name, char* mode, struct ProfileState* ps)
{
  char popen_buf[4096];
#if HAVE_POPEN
  if(endsWithgz(name) && strlen(name) < 3000)
  {
    if(mode[0] == 'r')
      strcpy(popen_buf, "gunzip < ");
    else if(mode[0] == 'w')
      strcpy(popen_buf, "gzip > ");
    else if(mode[0] == 'a')
      strcpy(popen_buf, "gzip >> ");
    else
    {
      return;
    }
    strcat(popen_buf, name);
    ps->Stream = popen(popen_buf, mode);
    ps->StreamWasPopened = 1;
    return;
  }
#endif
  
  ps->Stream = fopen(name, mode);
  ps->StreamWasPopened = 0;
}

static void fcloseMaybeCompressed(struct ProfileState* ps)
{
#if HAVE_POPEN
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
** Store the true values of each function we wrap for profiling. These always
** store the correct values and are never changed. 
*/


UInt (* RealExecStatFuncs[256]) ( Stat stat );

Obj  (* RealEvalExprFuncs[256]) ( Expr expr );
Obj  (* RealEvalBoolFuncs[256]) ( Expr expr );

void (* RealPrintStatFuncs[256]) ( Stat stat );
void (* RealPrintExprFuncs[256]) ( Expr expr );

/****************************************************************************
**
** These functions are here because the library may want to install
** functions once profiling has started. 
*/

void InstallEvalBoolFunc( Int pos, Obj(*expr)(Expr)) {
  RealEvalBoolFuncs[pos] = expr;
  if(!profileState.Active) {
    EvalBoolFuncs[pos] = expr;
  }
}

void InstallEvalExprFunc( Int pos, Obj(*expr)(Expr)) {
  RealEvalExprFuncs[pos] = expr;
  if(!profileState.Active) {
    EvalExprFuncs[pos] = expr;
  }
}
  
void InstallExecStatFunc( Int pos, UInt(*stat)(Stat)) {
  RealExecStatFuncs[pos] = stat;
  if(!profileState.Active) {
    ExecStatFuncs[pos] = stat;
  }
}
void InstallPrintStatFunc(Int pos, void(*stat)(Stat)) {
  RealPrintStatFuncs[pos] = stat;
  if(!profileState.ColouringOutput) {
    PrintStatFuncs[pos] = stat;
  }
}

void InstallPrintExprFunc(Int pos, void(*expr)(Expr)) {
  RealPrintExprFuncs[pos] = expr;
  if(!profileState.ColouringOutput) {
    PrintExprFuncs[pos] = expr;
  }
}

/****************************************************************************
**
** These functions are only used when profiling is enabled. They output
** as approriate, and then pass through to the true function
*/

// This function checks if we have ever printed out the id of stat
static inline UInt getFilenameId(stat)
{
  UInt id = FILENAMEID_STAT(stat);
  if(LEN_PLIST(OutputtedFilenameList) < id || !ELM_PLIST(OutputtedFilenameList,id))
  {
    GROW_PLIST(OutputtedFilenameList, id);
    SET_LEN_PLIST(OutputtedFilenameList, id);
    SET_ELM_PLIST(OutputtedFilenameList, id, True);
    fprintf(profileState.Stream, "{\"Type\":\"S\",\"File\":\"%s\",\"FileId\":%d}\n",
                                  CSTR_STRING(FILENAME_STAT(stat)), (int)id);
  }
  return id;
}

// exec : are we executing this statement
// visit: Was this statement previously visited (that is, executed)
static inline void outputStat(Stat stat, int exec, int visited)
{
  UInt line;
  int nameid;
  
  int ticks = 0;
#if defined(HAVE_GETTIMEOFDAY)
  struct timeval timebuf;
#else
#if defined(HAVE_GETRUSAGE)
  struct timeval timebuf;
  struct rusage buf;
#endif
#endif
    
  nameid = getFilenameId(stat);
  line = LINE_STAT(stat);
  if(profileState.lastOutputtedLine != line ||
     profileState.lastOutputtedFileID != nameid || 
     profileState.lastOutputtedExec != exec)
  {

    if(profileState.OutputRepeats) {
#if defined(HAVE_GETTIMEOFDAY)
      gettimeofday(&timebuf, 0);
#else
#if defined(HAVE_GETRUSAGE)
      getrusage( RUSAGE_SELF, &buf );
      timebuf = buf.ru_utime;
#endif
#endif
#if defined(HAVE_GETTIMEOFDAY) || defined(HAVE_GETRUSAGE)
      ticks = (timebuf.tv_sec - profileState.lastOutputtedTime.tv_sec) * 1000000 +
              (timebuf.tv_usec - profileState.lastOutputtedTime.tv_usec);
#endif
      // Basic sanity check
      if(ticks < 0)
        ticks = 0;
      if((profileState.minimumProfileTick == 0) || (ticks > profileState.minimumProfileTick)
         || (!visited)) {
        fprintf(profileState.Stream, "{\"Type\":\"%c\",\"Ticks\":%d,\"Line\":%d,\"FileId\":%d}\n",
                exec ? 'E' : 'R', ticks, (int)line, (int)nameid);
#if defined(HAVE_GETRUSAGE) || defined(HAVE_GETTIMEOFDAY)
        profileState.lastOutputtedTime = timebuf;
#endif
      }
    }
    else {
      fprintf(profileState.Stream, "{\"Type\":\"%c\",\"Line\":%d,\"FileId\":%d}\n",
              exec ? 'E' : 'R', (int)line, (int)nameid);
    }
    profileState.lastOutputtedLine = line;
    profileState.lastOutputtedFileID = nameid;
    profileState.lastOutputtedExec = exec;

  }
}

static inline void visitStat(Stat stat)
{
  int visited = VISITED_STAT(stat);
 
  if(!visited) {
    ADDR_STAT(stat)[-1] |= (Stat)1 << 63;
  }
  
  if(profileState.OutputRepeats || !visited) {
    outputStat(stat, 1, visited);
  }
}

UInt ProfileStatPassthrough(Stat stat)
{
  visitStat(stat);
  return RealExecStatFuncs[TNUM_STAT(stat)](stat);
}

Obj ProfileEvalExprPassthrough(Expr stat)
{
  visitStat(stat);
  return RealEvalExprFuncs[TNUM_STAT(stat)](stat);
}

Obj ProfileEvalBoolPassthrough(Expr stat)
{
  /* There are two cases we must pass through without touching */
  /* From TNUM_EXPR */
  if(IS_REFLVAR(stat)) {
    return RealEvalBoolFuncs[T_REFLVAR](stat);
  }
  if(IS_INTEXPR(stat)) {
    return RealEvalBoolFuncs[T_INTEXPR](stat);
  }
  visitStat(stat);
  return RealEvalBoolFuncs[TNUM_STAT(stat)](stat);
}

/****************************************************************************
**
** Activating and deacivating profiling, either at startup or by user request
*/

void enableAtStartup(char* filename, Int repeats)
{
    Int i;
    
    if(profileState.Active) {
        fprintf(stderr, "-P or -C can only be passed once\n");
        exit(1);
    }
    
    profileState.OutputRepeats = repeats;
    
    fopenMaybeCompressed(filename, "w", &profileState);
    if(!profileState.Stream) {
        fprintf(stderr, "Failed to open '%s' for profiling output.\n", filename);
        fprintf(stderr, "Abandoning starting GAP.\n");
        exit(1);
    }
    
    for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
      ExecStatFuncs[i] = ProfileStatPassthrough;
      EvalExprFuncs[i] = ProfileEvalExprPassthrough;      
      EvalBoolFuncs[i] = ProfileEvalBoolPassthrough;
    }
    
    profileState.Active = 1;
#ifdef HAVE_GETTIMEOFDAY
    gettimeofday(&(profileState.lastOutputtedTime), 0);
#else
#ifdef HAVE_GETRUSAGE
    struct rusage buf;
    getrusage( RUSAGE_SELF, &buf );
    profileState.lastOutputtedTime = buf.ru_utime;
#endif
#endif
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
    Obj                 filename,
    Obj                 mode,
    Obj                 fulldump)
{
    Int i;
    
    if(profileState.Active) {
      return Fail;
    }
    
    OutputtedFilenameList = NEW_PLIST(T_PLIST, 0);

    while ( ! IsStringConv( filename ) ) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <filename> via 'return <filename>;'" );
    }
    
    while ( ! IsStringConv(mode ) ) {
        mode = ErrorReturnObj(
            "<mode> must be a string (not a %s)",
            (Int)TNAM_OBJ(filename), 0L,
            "you can replace <mode> via 'return <mode>;'" );
    }
    
    while(fulldump != True && fulldump != False) {
      fulldump = ErrorReturnObj(
          "<fulldump> must be a boolean (not a %s)",
          (Int)TNAM_OBJ(filename), 0L,
          "you can replace <fulldump> via 'return <fulldump>;'" );
    }
    
    
    if(fulldump == True) {
      profileState.OutputRepeats = 1;
    }
    else {
      profileState.OutputRepeats = 0;
    }
  
    fopenMaybeCompressed(CSTR_STRING(filename), CSTR_STRING(mode), &profileState);
    
    if(profileState.Stream == 0)
      return Fail;
    
    for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
      ExecStatFuncs[i] = ProfileStatPassthrough;
      EvalExprFuncs[i] = ProfileEvalExprPassthrough;      
      EvalBoolFuncs[i] = ProfileEvalBoolPassthrough;
    }
    
    profileState.Active = 1;
    
#ifdef HAVE_GETTIMEOFDAY
    gettimeofday(&(profileState.lastOutputtedTime), 0);
#else
#ifdef HAVE_GETRUSAGE
    struct rusage buf;
    getrusage( RUSAGE_SELF, &buf );
    profileState.lastOutputtedTime = buf.ru_utime;
#endif
#endif
    
    return True;
}
        
Obj FuncDEACTIVATE_PROFILING (
    Obj                 self)
{
  int i;
  
  if(!profileState.Active) {
    return Fail; 
  }
  
  fcloseMaybeCompressed(&profileState);
  
  for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
    ExecStatFuncs[i] = RealExecStatFuncs[i];
    EvalExprFuncs[i] = RealEvalExprFuncs[i];
    EvalBoolFuncs[i] = RealEvalBoolFuncs[i];
  }

  profileState.Active = 0;
  return True;
}

Obj FuncMINIMUM_PROFILE_TICK(
  Obj self,
  Obj ticksize)
{
  (void)self;
  int tick;
  if(!IS_INTOBJ(ticksize)) {
    return Fail;
  }
  tick = INT_INTOBJ(ticksize);
  if(tick < 0) {
    return Fail;
  }
  profileState.minimumProfileTick = tick;
  return True; 
}


/****************************************************************************
**
** We are now into the functions which deal with colouring printing output.
** This code basically wraps all the existing print functions and will colour
** their output either green or red depending on if statements are marked
** as being executed.
*/



Int CurrentColour = 0;

static void setColour()
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
  RealPrintStatFuncs[TNUM_STAT(stat)](stat);
  CurrentColour = SavedColour;
  setColour();
}

void ProfilePrintExprPassthrough(Expr stat)
{
  Int SavedColour = -1;
  /* There are two cases we must pass through without touching */
  /* From TNUM_EXPR */
  if(IS_REFLVAR(stat)) {
    RealPrintExprFuncs[T_REFLVAR](stat);
  } else if(IS_INTEXPR(stat)) {
    RealPrintExprFuncs[T_INTEXPR](stat);
  } else {
    SavedColour = CurrentColour;
    if(VISITED_STAT(stat)) {
      CurrentColour = 1;
    }
    else {
      CurrentColour = 2;
    }
    setColour();
    RealPrintExprFuncs[TNUM_STAT(stat)](stat);
    CurrentColour = SavedColour;
    setColour();
  }
}

Obj activate_colored_output_from_profile(void)
{
    int i;
    if(profileState.ColouringOutput) {
      return Fail;
    }

    for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
      PrintStatFuncs[i] = ProfilePrintStatPassthrough;
      PrintExprFuncs[i] = ProfilePrintExprPassthrough;
    }
    
    profileState.ColouringOutput = 1;
    CurrentColour = 0;
    setColour();
    return True;
}
        
Obj deactivate_colored_output_from_profile(void)
{
  int i;
  
  if(!profileState.ColouringOutput) {
    return Fail; 
  }
  
  for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
    PrintStatFuncs[i] = RealPrintStatFuncs[i];
    PrintExprFuncs[i] = RealPrintExprFuncs[i];
  }

  profileState.ColouringOutput = 0;
  CurrentColour = 0;
  setColour();
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
** This function exists to help with code coverage -- this outputs which
** lines have statements on expressions on them, so later we can
** check we executed something on those lines!
**/

void RegisterStatWithProfiling(Stat stat)
{
    if(profileState.Active) {
      outputStat(stat, 0, 0);
    }
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

    { "ACTIVATE_PROFILING", 3, "string,string,boolean",
      FuncACTIVATE_PROFILING, "src/profile.c:ACTIVATE_PROFILING" },
    { "DEACTIVATE_PROFILING", 0, "",
      FuncDEACTIVATE_PROFILING, "src/profile.c:DEACTIVATE_PROFILING" },
    { "ACTIVATE_COLOR_PROFILING", 1, "bool",
        FuncACTIVATE_COLOR_PROFILING, "src/profile.c:ACTIVATE_COLOR_PROFILING" },
    { "MINIMUM_PROFILE_TICK", 1, "int",
        FuncMINIMUM_PROFILE_TICK, "src/profile.c:FuncMINIMUM_PROFILE_TICK" },
    { 0 }
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
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoProfile ( void )
{
    return &module;
}


/****************************************************************************
**

*E  stats.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
