#ifndef CSETSTAB
#define CSETSTAB

extern PermGroup *setStabilizer(
   PermGroup *const G,            /* The containing permutation group. */
   const PointSet *const Lambda,  /* The point set to be stabilized. */
   PermGroup *const L)            /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Lambda.  (A null pointer
                                     designates a trivial group.) */
;

extern Permutation *setImage(
   PermGroup *const G,            /* The containing permutation group. */
   const PointSet *const Lambda,  /* One of the point sets. */
   const PointSet *const Xi,      /* The other point set. */
   PermGroup *const L_L,          /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Lambda.  (A null pointer
                                     designates a trivial group.) */
   PermGroup *const L_R)          /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Xi.  (A null pointer
                                     designates a trivial group.) */
;

#endif
