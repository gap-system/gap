#ifndef INFORM
#define INFORM

extern void informStatistics(
   Unsigned ell,
   unsigned long nodesVisited[],
   unsigned long nodesPruned[],
   unsigned long nodesEssential[])
;

extern void informOptions(void)
;

extern void informGroup(
   const PermGroup *const G)
;

extern void informRBase(
   const PermGroup *const G,
   const RBase *const AAA,
   const UnsignedS basicCellSize[])
;

extern void informSubgroup(
   const PermGroup *const G_pP)
;

extern void informCosetRep(
   Permutation *y)
;

extern void informNewGenerator(
   const PermGroup *const G_pP,
   const Unsigned newLevel)
;

extern void informTime(
   clock_t startTime,
   clock_t RBaseTime,
   clock_t optGroupTime,
   clock_t backtrackTime)
;

#endif
