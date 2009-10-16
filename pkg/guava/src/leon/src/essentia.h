#ifndef ESSENTIA
#define ESSENTIA

extern BOOLEAN essentialAtLevel(
   const Permutation *const perm,
   const Unsigned level)
;

extern BOOLEAN essentialBelowLevel(
   const Permutation *const perm,
   const Unsigned level)
;

extern BOOLEAN essentialAboveLevel(
   const Permutation *const perm,
   const Unsigned level)
;

extern void makeEssentialAtLevel(
   Permutation *const perm,
   const Unsigned level)
;

extern void makeNotEssentialAtLevel(
   Permutation *const perm,
   const Unsigned level)
;

extern void makeNotEssentialAtAboveLevel(
   Permutation *const perm,
   const Unsigned level)
;

extern void makeNotEssentialAll(
   Permutation *const perm)
;

extern void makeUnknownEssential(
   Permutation *const perm)
;

extern void copyEssential(
   Permutation *const newPerm,
   const Permutation *const oldPerm)
;

#endif
