#ifndef ORBREFN
#define ORBREFN

extern void initializeOrbRefine( PermGroup *G)
;

extern SplitSize orbRefine(
   const RefinementParm familyParm[],
   const RefinementParm refnParm[],
   PartitionStack *const UpsilonStack)
;

extern RefinementPriorityPair isOrbReducible(
   const RefinementFamily *family,        /* The refinement family mapping
                                             must be orbRefine; family parm[0]
                                             is the group. */
   const PartitionStack *const UpsilonStack)
;

#endif
