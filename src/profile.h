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

#include "exprs.h"

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




void InstallEvalBoolFunc( Int, Obj(*)(Expr));
void InstallEvalExprFunc( Int, Obj(*)(Expr));
void InstallExecStatFunc( Int, UInt(*)(Stat));
void InstallPrintStatFunc(Int, void(*)(Stat));
void InstallPrintExprFunc(Int, void(*)(Expr)); 

#define PROFILE_EVERYTHING
#ifdef PROFILE_EVERYTHING
void ProfileLineByLineIntoFunction(Obj o);
void ProfileLineByLineOutFunction(Obj o);
#define PROF_IN_FUNCTION(x) ProfileLineByLineIntoFunction(x)
#define PROF_OUT_FUNCTION(x) ProfileLineByLineOutFunction(x)
#else
#define PROF_IN_FUNCTION(x)
#define PROF_OUT_FUNCTION(x)
#endif

/****************************************************************************
**
** We need this to be in the header, so it can be inlined away. The only
** functionality here which should be publicly used is 'VisitStatIfProfiling'
*/

extern UInt profileState_Active;

void visitStat(Stat stat);

static inline void VisitStatIfProfiling(Stat stat)
{
  if(profileState_Active)
    visitStat(stat);
}


#endif // GAP_STATS_H

/****************************************************************************
**

*E  stats.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
