#ifndef OPTSVEC
#define OPTSVEC

extern void meanCosetRepLen(
   const PermGroup *const G)
;

extern FIXUP1 reconstructBasicOrbit(  /* Returns word length of longest coset rep. */
   PermGroup *const G,
   const Unsigned level)
;

extern void expandSGS(
   PermGroup *G,
   UnsignedS longRepLen[],
   UnsignedS basicCellSize[],
   Unsigned ell)
;

extern void compressGroup(
   PermGroup *const G)        /* The group to be compressed. */
;

extern void compressAtLevel(
   PermGroup *const G,        /* The group to be compressed. */
   const Unsigned level)      /* The level at which compression occurs. */
;

extern void sortGensByLevel(
   PermGroup *const G)
;

#endif
