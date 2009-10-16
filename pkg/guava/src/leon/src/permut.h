#ifndef PERMUT
#define PERMUT

extern BOOLEAN isIdentity(
   const Permutation *const s)
;

extern BOOLEAN isInvolution(
   const Permutation *const s)
;

extern Unsigned pointMovedBy(
   const Permutation *const perm)
;

extern void adjoinInvImage(
   Permutation *s)        /* The permutation group (base and sgs known). */
;

extern void leftMultiply(
   Permutation *const s,
   const Permutation *const t)
;

extern void rightMultiply(
   Permutation *const s,
   const Permutation *const t)
;

extern void rightMultiplyInv(
   Permutation *s,
   Permutation *t)
;

extern unsigned long permOrder(
   const Permutation *const perm )
;

extern void raisePermToPower(
   Permutation *const perm,      /* The permutation to be replaced. */
   const long power)             /* Upon return, perm has been replaced by
                                    perm^power. */
;

extern Permutation *permMapping(
   const Unsigned degree,     /* The degree of the new permutation.*/
   const UnsignedS seq1[],    /* The first sequence (must have len = degree). */
   const UnsignedS seq2[])    /* The second sequence (must have len = degree. */
;

extern BOOLEAN checkConjugacy(
   const Permutation *const e,
   const Permutation *const f,
   const Permutation *const conjPerm)
;

extern BOOLEAN isValidPermutation(
   const Permutation *const perm,
   const Unsigned degree,
   const Unsigned xCos,
   const Unsigned *const equivPt)
;

#endif
