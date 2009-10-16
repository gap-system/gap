#ifndef COMPSG
#define COMPSG

extern PermGroup *computeSubgroup(
   PermGroup *const G,        /* The permutation group, as above.  A base/sgs
                                 must be known (unless name is "symmetric"). */
   Property *const pP,        /* The subgroup-type property, as above.  A value
                                 of NULL may be used to suppress checking pP.*/
   RefinementFamily           /* (Ptr to) null-terminated list of refinement */
       *const RRR[],          /*    family pointers (List starts rrR[1].) */
   ReducChkFn *const          /* (Ptr to) null-terminated list of pointers */
       isReducible[],         /*    to functions checking rRR-reducibility. */
   SpecialRefinementDescriptor
       *const
       specialRefinement[],   /*   (Ptr to) list of permutation ptrs, some */
                              /*   possibly null.  For nonnull pointers, */
                              /*   computeSubgroup will keep track of perm t. */
   ExtraDomain *extra[],      /* extra[1], extra[2], ... are extra domains.
                                 pointer terminates list. */
   PermGroup *const L)        /* A known (possibly trivial) subgroup of G_pP.
                                 (Null pointer signifies a trivial group.) */

;

#endif
