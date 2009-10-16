#ifndef COMPCREP
#define COMPCREP

extern Permutation *computeCosetRep(
   PermGroup *const G,        /* The permutation group, as above.  A base/sgs
                                 must be known (unless name is "symmetric"). */
   Property *const pP,        /* The subgroup-type property, as above.  A value
                                 of NULL may be used to suppress checking pP.*/
   RefinementFamily           /* (Ptr to) null-terminated list of refinement */
           *const RRR[],      /*    family pointers (List starts rrR[1].) */
   ReducChkFn *const          /* (Ptr to) null-terminated list of pointers */
           isReducible[],     /*    to functions checking rRR-reducibility. */
   SpecialRefinementDescriptor
       *const
       specialRefinement[],   /*   (Ptr to) list of permutation pointers, */
                              /*   some possibly null.  For nonnull pointers, */
                              /*   computeCosetRep will keep track of perm t. */
   ExtraDomain *extra[],
   PermGroup *const L_L,      /* A known (possibly trivial) subgroup of G_pP_L.
                                 (Null pointer signifies a trivial group.) */
   PermGroup *const L_R)       /* A known (possibly trivial) subgroup of G_pP_R.
                                 (Null pointer signifies a trivial group.) */
;

#endif
