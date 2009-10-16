#ifndef RELATOR
#define RELATOR

extern BOOLEAN verifyCosetList(
   Unsigned degree);
BOOLEAN onFreeList(
   Unsigned coset);

UnsignedS relatorLevel(
   const Relator *const r)
;

extern Unsigned symmetricLength(
   const Relator *const r)
;

extern Unsigned symmetricWordLength(
   const Word *const w)
;

extern Relator *addRelatorSortedFromWord(
   PermGroup *const G,
   Word *const w,
   BOOLEAN fbRelFlag,
   BOOLEAN doubleFlag)
;

extern Unsigned addOccurencesForRelator(
   const Relator *const r,
   Unsigned priority)
;

extern void resetTable(
   Permutation *genHeader,
   Unsigned basicOrbLen,
   Unsigned *basicOrbit)
;

extern Unsigned findConsequences(
   DeductionQueue *deductionQueue,
   const Unsigned level,
   const Deduction *const deduc)
;

extern Unsigned traceNewRelator(
   const PermGroup *const G,
   const Unsigned level,
   DeductionQueue *deductionQueue,
   const Relator *const newRel)
;

extern Unsigned processCoincidence(
   const PermGroup *const G,
   DeductionQueue *deductionQueue,
   const Permutation *const genHeader,
   const Unsigned coset1,
   const Unsigned coset2)
;

extern Unsigned xFindConsequences(
   const PermGroup *const G,
   DeductionQueue *deductionQueue,
   const Unsigned level,
   const Deduction *const deduc,
   const Permutation *const genHeader)
;

extern Unsigned xTraceNewRelator(
   const PermGroup *const G,
   const Unsigned level,
   DeductionQueue *deductionQueue,
   const Relator *const newRel,
   const Permutation *const genHeader)
;

extern void makeDefinition(
   const Unsigned coset,
   Permutation *const gen,
   DeductionQueue *const deducQueue,
   DefinitionList *const defnList,
   Permutation *const genHeader)
;

extern Unsigned forceCollapse(
   const PermGroup *const G,
   const Unsigned level,
   Permutation *genHeader,
   DeductionQueue *const deductionQueue,
   DefinitionList *const defnList,
   Unsigned *jPtr,
   Permutation **hPtr,
   Word **wPtr)
;

extern BOOLEAN verifyCosetList(
   Unsigned degree)
;

extern BOOLEAN onFreeList(
   Unsigned coset)
;

#endif
