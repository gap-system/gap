#ifndef CMATAUTO
#define CMATAUTO

extern PermGroup *matrixAutoGroup(
   Matrix_01 *const M,            /* The matrix whose group is to be found. */
   PermGroup *const L,            /* A (possibly trivial) known subgroup of the
                                     automorphism group of D.  (A null pointer
                                     designates a trivial group.) */
   Code *const C,                 /* If nonnull, the auto grp of the code C is */
   const BOOLEAN monomialFlag)    /* computed, assuming its group is contained
                                     in that of the design. */
;

extern Permutation *matrixIsomorphism(
   Matrix_01 *const M_L,          /* The first design. */
   Matrix_01 *const M_R,          /* The second design. */
   PermGroup *const L_L,          /* A known subgroup of Aut(M_L), or NULL. */
   PermGroup *const L_R,          /* A known subgroup of Aut(M_R), or NULL. */
   Code *const C_L,               /* If nonnull, C_R must also be nonull, and */
   Code *const C_R,               /*   any isomorphism of C_L to C_R must map */
   const BOOLEAN monomialFlag,    /*   M_L to M_R.  A code isomorphism is     */
                                  /*   computed.  */
   const BOOLEAN colInformFlag)   /* Print iso on columns to std output. */
;

#endif
