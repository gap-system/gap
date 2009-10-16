#ifndef PTSTBREF
#define PTSTBREF

extern SplitSize pointStabRefine(
   const RefinementParm familyParm[],       /* No family parms.  */
   const RefinementParm refnParm[],         /* parm[0] = alpha, parm[1] = i. */
   PartitionStack *const UpsilonStack)      /* The partition stack, as above. */
;

extern RefinementPriorityPair isPointStabReducible(
   const RefinementFamily *family,             /* The refinement family (mapping
                                                  must be pointStabRefn; there
                                                  are no genuine parms. */
   const PartitionStack *const UpsilonStack,   /* The partition stack above. */
   PermGroup *G,                               /* For optimization. */
   RBase     *AAA,                             /* For optimization. */
   Unsigned  level)                            /* For optimization. */
;

#endif
