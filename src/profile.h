/****************************************************************************
**
*W  profile.h                     GAP source              Chris Jefferson
**
**
*Y  Copyright (C) 2014 The GAP Group
**
**  This file contains profile related functionality.
**
*/

#ifndef GAP_PROFILE_H
#define GAP_PROFILE_H

#include <src/exprs.h>

/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoStats() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoProfile ( void );

void RegisterStatWithProfiling(Stat);
void RegisterProfilingLineOverflowOccured();
void RegisterProfilingFileOverflowOccured();

void InstallEvalBoolFunc( Int, Obj(*)(Expr));
void InstallEvalExprFunc( Int, Obj(*)(Expr));
void InstallExecStatFunc( Int, UInt(*)(Stat));
void InstallPrintStatFunc(Int, void(*)(Stat));
void InstallPrintExprFunc(Int, void(*)(Expr));

/****************************************************************************
**
** We need this to be in the header, so it can be inlined away. The only
** functionality here which should be publicly used is 'VisitStatIfProfiling',
** 'ProfileLineByLineIntoFunction' and 'ProfileLineByLineOutFunction'.
*/

extern UInt profileState_Active;

void visitStat(Stat stat);

static inline void VisitStatIfProfiling(Stat stat)
{
  if(profileState_Active)
    visitStat(stat);
}

void ProfileLineByLineOutput(Obj func, char type);

static inline void ProfileLineByLineIntoFunction(Obj func)
{
  if(profileState_Active)
    ProfileLineByLineOutput(func, 'I');
}


static inline void ProfileLineByLineOutFunction(Obj func)
{
  if(profileState_Active)
    ProfileLineByLineOutput(func, 'O');
}


#endif // GAP_STATS_H

/****************************************************************************
**

*E  stats.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
