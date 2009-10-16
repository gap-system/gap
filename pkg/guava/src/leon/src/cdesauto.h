#ifndef CDESAUTO
#define CDESAUTO

extern PermGroup *designAutoGroup(
   Matrix_01 *const D,            /* The matrix whose group is to be found. */
   PermGroup *const L,            /* A (possibly trivial) known subgroup of the
                                     automorphism group of D.  (A null pointer
                                     designates a trivial group.) */
   Code *const C)                 /* If nonnull, the auto grp of the code C is
                                     computed, assuming its group is contained
                                     in that of the design. */
;

extern Permutation *designIsomorphism(
   Matrix_01 *const D_L,          /* The first design. */
   Matrix_01 *const D_R,          /* The second design. */
   PermGroup *const L_L,          /* A known subgroup of Aut(D_L), or NULL. */
   PermGroup *const L_R,          /* A known subgroup of Aut(D_R), or NULL. */
   Code *const C_L,               /* If nonnull, C_R must also be nonull, and */
   Code *const C_R,               /*   any isomorphism of C_L to C_R must map */
                                  /*   D_L to D_R.  A code isomorphism is     */
                                  /*   computed.  */
   const BOOLEAN colInformFlag)
;

#endif
