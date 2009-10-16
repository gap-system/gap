#ifndef PERMGRP
#define PERMGRP

extern Unsigned genCount(
   const PermGroup *const G,           /* The permutation group. */
   Unsigned *involCount)              /* If nonnull, set to number of
                                          involutory generators. */
;

extern BOOLEAN isFixedPointOf(
   const PermGroup *const G,   /* A group with known base and sgs. */
   const Unsigned level,       /* The level mentioned above. */
   const Unsigned point)       /* Check if this point is a fixed point. */
;

extern BOOLEAN isNontrivialGroup(
   PermGroup *G)              /* The permutation group to test. */
;

extern Unsigned levelIn(
   PermGroup *G,           /* The perm group (base and baseSize filled in). */
   Permutation *perm)      /* The permutation whose level is returned. */
;

extern BOOLEAN isIdentityElt(
   PermGroup *G,           /* The permutation group (base known). */
   Permutation *perm)      /* The permutation known to lie in G. */
;

extern BOOLEAN isInvolutoryElt(
   PermGroup *G,           /* The permutation group (base known). */
   Permutation *perm)      /* The permutation known to lie in G. */
;

extern BOOLEAN fixesBasicOrbit(
   const PermGroup *const G,
   const Unsigned level,
   const Permutation *const perm)
;

extern Permutation *linkEssentialGens(
   PermGroup *G,                   /* The permutation group. */
   Unsigned level)                 /* Generators essential at this level are
                                      linked. */
;

extern void assignGenName(
   PermGroup *const G,
   Permutation *const gen)
;

extern void adjoinInverseGen(
   PermGroup *const G,
   Permutation *gen)    /* Must be a generator of G, and must have invImage. */
;

extern BOOLEAN depthGreaterThan(
   const PermGroup *const G,
   const Unsigned comparisonDepth)
;

extern BOOLEAN isDoublyTransitive(
   const PermGroup *const G)
;

extern void conjugatePermByPerm(
   Permutation *const perm,
   const Permutation *const conjPerm)
;

extern void conjugateGroupByPerm(
   PermGroup *const G,
   const Permutation *const conjPerm)
;

extern BOOLEAN checkConjugacyInGroup(
   const PermGroup *const G,
   const Permutation *const e,
   const Permutation *const f,
   const Permutation *const conjPerm)
;

extern BOOLEAN isElementOf(
   const Permutation *const perm,
   const PermGroup *const group)
;

extern BOOLEAN isSubgroupOf(
   const PermGroup *const subGroup,
   const PermGroup *const group)
;

extern BOOLEAN isNormalizedBy(
   const PermGroup *const group,
   const PermGroup *const nGroup)
;

extern BOOLEAN isCentralizedBy(
   const PermGroup *const group,
   const PermGroup *const cGroup)
;

extern BOOLEAN isBaseImage(
   const PermGroup *const G,
   const Unsigned image[])
;

extern void reduceWrtGroup(
   const PermGroup *const G,
   Permutation *const h,
   Unsigned *reductionLevel)
;

#endif
