#ifndef CCOMMUT
#define CCOMMUT

extern PermGroup *commutatorGroup(
   const PermGroup *const G,
   const PermGroup *const H)
;

extern PermGroup *normalClosure(
   const PermGroup *const G,
   const PermGroup *const H)
;

#endif
