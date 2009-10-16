#ifndef RANDSCHR
#define RANDSCHR

extern void removeIdentityGens(
   PermGroup *const G)              /* The group G mentioned above. */
;

extern void adjoinGenInverses(
   PermGroup *const G)              /* The group mentioned above. */
;

extern void initializeBase(
   PermGroup *const G)              /* The group G mentioned above. */
;

extern void replaceByPower(
   const PermGroup *const G,
   const Unsigned level,
   Permutation *const h)
;

extern BOOLEAN randomSchreier(
   PermGroup *const G,
   RandomSchreierOptions rOptions)
;

#endif
