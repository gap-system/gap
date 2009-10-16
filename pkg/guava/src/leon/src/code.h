#ifndef CODE
#define CODE

extern void reduceBasis(
   Code *const C)
;

extern BOOLEAN codeContainsVector(
   Code *const C,
   char *const v)
;

extern BOOLEAN isCodeIsomorphism(
   Code *const C1,
   Code *const C2,
   const Permutation *const s)
;

#endif
