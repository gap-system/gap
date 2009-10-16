#ifndef MATRIX
#define MATRIX

extern BOOLEAN isMatrix01Isomorphism(
   const Matrix_01 *const M1,
   const Matrix_01 *const M2,
   const Permutation *const s,
   const Unsigned monomialFlag)         /* If TRUE, check that iso */
                                        /* is monomial. */
;

extern Matrix_01 *augmentedMatrix(
   const Matrix_01 *const M)
;

#endif
