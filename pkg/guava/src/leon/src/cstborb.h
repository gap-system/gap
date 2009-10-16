#ifndef CSTBORB
#define CSTBORB

extern Permutation *linkGensAtLevel(
   PermGroup *G,                      /* The permutation group. */
   Unsigned level)                    /* Permutations at or above this level
                                         will be included. */
;

extern Permutation *linkEssentialGensAtLevel(
   PermGroup *G,                      /* The permutation group. */
   Unsigned level)                    /* Permutations at or above this level
                                         will be included if they are essential
                                         at this level. */
;

extern Permutation *genExpandingBasicOrbit(
   Permutation **firstGen,
   const Unsigned orbitLen,
   UnsignedS *orbit,
   Permutation **svec)
;

extern void constructBasicOrbit(
   PermGroup *const G,       /* The permutation group. */
   const Unsigned level,     /* The level of the basic orbit to build. */
   char *option)             /* One of the three options above. */
;

extern Unsigned extendBasicOrbit(
   PermGroup *G,            /* The permutation group. */
   Unsigned level,          /* The level of the basic orbit to extend. */
   Permutation *newGen)     /* The new generator not previously included
                               the Schreier vector. */
;

extern void constructAllOrbitInfo(
   PermGroup *const G,
   const Unsigned level)
;

#endif
