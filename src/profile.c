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

#include        "tls.h"

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

#include        "thread.h"

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

struct ProfileState
{
  UInt Active;
  FILE* Stream;
  Int OutputRepeats;
  Int ColouringOutput;
} profileState;

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
  HashLock(&profileState);
  if(!profileState.Active) {
    EvalBoolFuncs[pos] = expr;
  }
  HashUnlock(&profileState);
}

void InstallEvalExprFunc( Int pos, Obj(*expr)(Expr)) {
  RealEvalExprFuncs[pos] = expr;
  HashLock(&profileState);
  if(!profileState.Active) {
    EvalExprFuncs[pos] = expr;
  }
  HashUnlock(&profileState);
}
  
void InstallExecStatFunc( Int pos, UInt(*stat)(Stat)) {
  RealExecStatFuncs[pos] = stat;
  HashLock(&profileState);
  if(!profileState.Active) {
    ExecStatFuncs[pos] = stat;
  }
  HashUnlock(&profileState);
}

void InstallPrintStatFunc(Int pos, void(*stat)(Stat)) {
  RealPrintStatFuncs[pos] = stat;
  HashLock(&profileState);
  if(!profileState.ColouringOutput) {
    PrintStatFuncs[pos] = stat;
  }
  HashUnlock(&profileState);
}

void InstallPrintExprFunc(Int pos, void(*expr)(Expr)) {
  RealPrintExprFuncs[pos] = expr;
  HashLock(&profileState);
  if(!profileState.ColouringOutput) {
    PrintExprFuncs[pos] = expr;
  }
  HashUnlock(&profileState);
}

/****************************************************************************
**
** These functions are only used when profiling is enabled. They output
** as approriate, and then pass through to the true function
*/

UInt ProfileStatPassthrough(Stat stat)
{
  HashLock(&profileState);
  if(profileState.OutputRepeats || !(VISITED_STAT(stat))) {
    ADDR_STAT(stat)[-1] |= (Stat)1 << 63;
    fprintf(profileState.Stream, "rec(exec:=true,file:=\"%s\",line:=%d)\n",
              CSTR_STRING(FILENAME_STAT(stat)), (int)LINE_STAT(stat));
  }
  HashUnlock(&profileState);
  return RealExecStatFuncs[TNUM_STAT(stat)](stat);
}

Obj ProfileEvalExprPassthrough(Expr stat)
{
  HashLock(&profileState);
  if(profileState.OutputRepeats || !(VISITED_STAT(stat))) {
    ADDR_STAT(stat)[-1] |= (Stat)1 << 63;
    fprintf(profileState.Stream, "rec(exec:=true,file:=\"%s\",line:=%d)\n",
              CSTR_STRING(FILENAME_STAT(stat)), (int)LINE_STAT(stat));
  }
  HashUnlock(&profileState);
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
  HashLock(&profileState);
  if(profileState.OutputRepeats || !(VISITED_STAT(stat))) {
    ADDR_STAT(stat)[-1] |= (Stat)1 << 63;
    fprintf(profileState.Stream, "rec(exec:=true,file:=\"%s\",line:=%d)\n",
             CSTR_STRING(FILENAME_STAT(stat)), (int)LINE_STAT(stat));
  }
  HashUnlock(&profileState);
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
    
    profileState.Stream = fopen(filename, "w");
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

    HashLock(&profileState);
        
    if(fulldump == True) {
      profileState.OutputRepeats = 1;
    }
    else {
      profileState.OutputRepeats = 0;
    }
    
    profileState.Stream = fopen(CSTR_STRING(filename), CSTR_STRING(mode));
    
    if(profileState.Stream == 0)
    {
      HashUnlock(&profileState);
      return Fail;
    }
    
    for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
      ExecStatFuncs[i] = ProfileStatPassthrough;
      EvalExprFuncs[i] = ProfileEvalExprPassthrough;      
      EvalBoolFuncs[i] = ProfileEvalBoolPassthrough;
    }
    
    profileState.Active = 1;
    
    HashUnlock(&profileState);
    
    return True;
}
        
Obj FuncDEACTIVATE_PROFILING (
    Obj                 self)
{
  int i;
  
  HashLock(&profileState);
  
  if(!profileState.Active) {
    HashUnlock(&profileState);
    return Fail; 
  }
  
  fclose(profileState.Stream);
  profileState.Stream = 0;
  
  for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
    ExecStatFuncs[i] = RealExecStatFuncs[i];
    EvalExprFuncs[i] = RealEvalExprFuncs[i];
    EvalBoolFuncs[i] = RealEvalBoolFuncs[i];
  }

  profileState.Active = 0;
  
  HashUnlock(&profileState);
  
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
    
    HashLock(&profileState);
    
    if(profileState.ColouringOutput) {
      HashUnlock(&profileState);
      return Fail;
    }

    for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
      PrintStatFuncs[i] = ProfilePrintStatPassthrough;
      PrintExprFuncs[i] = ProfilePrintExprPassthrough;
    }
    
    profileState.ColouringOutput = 1;
    CurrentColour = 0;
    setColour();
    
    HashUnlock(&profileState);
    
    return True;
}
        
Obj deactivate_colored_output_from_profile(void)
{
  int i;
  
  HashLock(&profileState);
  
  if(!profileState.ColouringOutput) {
    HashUnlock(&profileState);
    return Fail; 
  }
  
  for( i = 0; i < sizeof(ExecStatFuncs)/sizeof(ExecStatFuncs[0]); i++) {
    PrintStatFuncs[i] = RealPrintStatFuncs[i];
    PrintExprFuncs[i] = RealPrintExprFuncs[i];
  }

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
** This function exists to help with code coverage -- this outputs which
** lines have statements on expressions on them, so later we can
** check we executed something on those lines!
**/

void RegisterStatWithProfiling(Stat stat)
{
    HashLock(&profileState);
    if(profileState.Active) {
        fprintf(profileState.Stream, "rec(exec:=false,file:=\"%s\",line:=%d)\n",
                  CSTR_STRING(FILENAME_STAT(stat)), (int)LINE_STAT(stat));
    }
    HashUnlock(&profileState);
    
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
