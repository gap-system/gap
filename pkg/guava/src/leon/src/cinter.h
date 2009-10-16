#ifndef CINTER
#define CINTER

extern PermGroup *intersection(
   PermGroup *const G,            /* The first permutation group. */
   PermGroup *const E,            /* The second permutation group. */
   PermGroup *const L)            /* A (possibly trivial) known subgroup of the
                                     intersection of G and E.  (A null pointer
                                     designates a trivial group.) */
;

#endif
