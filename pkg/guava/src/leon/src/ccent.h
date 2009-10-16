#ifndef CCENT
#define CCENT

extern PermGroup *centralizer(
   PermGroup *const G,            /* The containing permutation group. */
   const Permutation *const e,    /* The point set to be stabilized. */
   PermGroup *const L,            /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Lambda.  (A null pointer
                                     designates a trivial group.) */
   const BOOLEAN noPartn,         /* If true, suppresses use of ordered
                                     partition based on cycle size. */
   const BOOLEAN longCycleOption, /* Always choose next base point in longest
                                     cycle; however, at present, all cycles
                                     of length 5 or greater are treated as
                                     having the same length. */
   const BOOLEAN stdRBaseOption)  /* Use std base selection algorithm, ignoring
                                     cycle lengths. */
;

extern Permutation *conjugatingElement(
   PermGroup *const G,            /* The containing permutation group. */
   const Permutation *const e,    /* One of the elements. */
   const Permutation *const f,    /* The other element. */
   PermGroup *const L_L,          /* A (possibly trivial) known subgroup of the
                                     centralizer in G of e.  (A null pointer
                                     designates a trivial group.) */
   PermGroup *const L_R,          /* A (possibly trivial) known subgroup of the
                                     centralizer in G of f.  (A null pointer
                                     designates a trivial group.) */
   const BOOLEAN noPartn,         /* If true, suppresses use of ordered
                                     partition based on cycle size. */
   const BOOLEAN longCycleOption, /* Always choose next base point in longest
                                     cycle; however, at present, all cycles
                                     of length 5 or greater are treated as
                                     having the same length. */
   const BOOLEAN stdRBaseOption)  /* Use std base selection algorithm, ignoring
                                     cycle lengths. */
;

extern PermGroup *groupCentralizer(
   PermGroup *const G,            /* The containing permutation group. */
   const PermGroup *const E,      /* The point set to be stabilized. */
   PermGroup *const L,            /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Lambda.  (A null pointer
                                     designates a trivial group.) */
   const Unsigned centPartnCount,
   const Unsigned centGenCount)
;

extern Partition *cycleLengthPartn(
   const Permutation *const e,
   UnsignedS *const cycleLen,
   UnsignedS *const cycleStructure)
;

extern Partition *multipleCycleLengthPartn(
   const Permutation *const ex[])
;

#endif
