#ifndef CSTRBAS
#define CSTRBAS

extern RBase *constructRBase(
   PermGroup *const G,
   RefinementFamily *const RRR[],
   ReducChkFn *const isReducible[],
   SpecialRefinementDescriptor *const specialRefinement[],
   UnsignedS basicCellSize[],
   ExtraDomain *extra[] )
;

#endif
