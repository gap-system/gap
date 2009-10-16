#ifndef CUPRSTAB
#define CUPRSTAB

extern PermGroup *uPartnStabilizer(
   PermGroup *const G,             /* The containing permutation group. */
   const Partition *const Lambda,  /* The point set to be stabilized. */
   PermGroup *const L)             /* A (possibly trivial) known subgroup of the
                                      stabilizer in G of Lambda.  (A null pointer
                                      designates a trivial group.) */
;

extern Permutation *uPartnImage(
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

extern void initializeUPartnStabRefine( PermGroup *G)
;

extern RefinementPriorityPair isOrbReducible(
   const RefinementFamily *family,        /* The refinement family mapping
                                             must be orbRefine; family parm[0]
                                             is the group. */
   const PartitionStack *const UpsilonStack)
;

#endif
