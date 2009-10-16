#ifndef STCS
#define STCS

extern WordImagePair computeSchreierGen(
   const PermGroup *const G,
   const Unsigned level,
   const Unsigned point,
   const Permutation *const gen);

BOOLEAN reduce(
   const PermGroup *const G,
   const Unsigned level,
   Unsigned *const jPtr,
   WordImagePair *const whPtr);

void informNewRelator(
   const Relator *const newRel,
   Unsigned numberAdded);

void informSTCSSummary(
   const PermGroup *const G,
   const unsigned long numberOfRelators,
   const unsigned long totalRelatorLength,
   const Unsigned maxRelatorLength,
   const unsigned long numberSelected,
   const unsigned long totalSelectedLength);

void expandGenerators(
   PermGroup *const G,
   Unsigned maxExtraCosets);

unsigned long prodOrderBounded(
   const Permutation *const perm1,
   const Permutation *const perm2,
   const Unsigned bound);


void schreierToddCoxeterSims(
   PermGroup *const G,
   const UnsignedS *const knownBase)       /* Null-terminated list, or null. */
;

extern WordImagePair computeSchreierGen(
   const PermGroup *const G,
   const Unsigned level,
   const Unsigned point,
   const Permutation *const gen)
;

extern WordImagePair xComputeSchreierGen(
   const PermGroup *const G,
   const Unsigned level,
   const Unsigned point,
   const Permutation *const gen)
;

extern BOOLEAN reduce(
   const PermGroup *const G,
   const Unsigned level,
   Unsigned *const jPtr,
   WordImagePair *const whPtr)
;

extern BOOLEAN xReduce(
   const PermGroup *const G,
   const Unsigned level,
   Unsigned *const jPtr,
   WordImagePair *const whPtr)
;

extern void addStrongGeneratorNR(
   PermGroup *G,              /* Group to which strong gen is adjoined. */
   Permutation *newGen)       /* The new strong generator. It must move
                                 a base point (not checked). */
;

extern void expandGenerators(
   PermGroup *const G,
   Unsigned extraCosets)
;

extern unsigned long prodOrderBounded(
   const Permutation *const perm1,
   const Permutation *const perm2,
   const Unsigned bound)
;

extern void informNewRelator(
   const Relator *const newRel,
   Unsigned numberAdded)
;

extern void informSTCSSummary(
   const PermGroup *const G,
   const unsigned long numberOfRelators,
   const unsigned long totalRelatorLength,
   const Unsigned maxRelatorLength,
   const unsigned long numberSelected,
   const unsigned long totalSelectedLength)
;

#endif
