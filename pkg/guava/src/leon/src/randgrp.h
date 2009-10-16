#ifndef RANDGRP
#define RANDGRP

extern void initializeSeed(
   unsigned long newSeed)      /* The new value for the seed. */
;

extern Unsigned randInteger(
   Unsigned lowerBound,           /* Lower bound for range of random integer. */
   Unsigned upperBound)           /* Upper bound for range of random integer. */
;

extern Word *randGroupWord(
   PermGroup *G,
   Unsigned atLevel)
;

extern Permutation *randGroupPerm(
   PermGroup *G,
   Unsigned atLevel)
;

#endif
