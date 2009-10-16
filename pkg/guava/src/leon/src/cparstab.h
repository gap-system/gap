#ifndef CPARSTAB
#define CPARSTAB

extern PermGroup *partnStabilizer(
   PermGroup *const G,             /* The containing permutation group. */
   const Partition *const Lambda,  /* The point set to be stabilized. */
   PermGroup *const L)             /* A (possibly trivial) known subgroup of the
                                      stabilizer in G of Lambda.  (A null pointer
                                      designates a trivial group.) */
;

extern Permutation *partnImage(
   PermGroup *const G,            /* The containing permutation group. */
   const Partition *const Lambda,  /* One of the partitions. */
   const Partition *const Xi,      /* The other partition. */
   PermGroup *const L_L,          /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Lambda.  (A null pointer
                                     designates a trivial group.) */
   PermGroup *const L_R)          /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Xi.  (A null pointer
                                     designates a trivial group.) */
;

extern void initializePartnStabRefn( void)
;

extern SplitSize partnStabRefine(
   const RefinementParm familyParm[],      /* Family parm: Lambda. */
   const RefinementParm refnParm[],        /* Refinement parm: i. */
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
;

extern RefinementPriorityPair isPartnStabReducible(
   const RefinementFamily *family,
   const PartitionStack *const UpsilonStack)
;

#endif
