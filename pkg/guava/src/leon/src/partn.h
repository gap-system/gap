#ifndef PARTN
#define PARTN

extern void popToHeight(
   PartitionStack *piStack,     /* The partition stack to pop. */
   Unsigned newHeight)          /* The new height for the stack. */
;

extern void xPopToLevel(
   CellPartitionStack *xPiStack,   /* The cell partition stack to pop. */
   UnsignedS *applyAfterLevel,
   Unsigned newHeight)             /* The new height for the stack. */
;

extern void *constructOrbitPartition(
   PermGroup *G,                /* The permutation group. */
   Unsigned level,              /* The orbits of G^(level) will be found. */
   UnsignedS *orbitNumberOf,    /* Set so that orbitNumberOf[pt] is the number
                                   of the orbit containing pt. */
   UnsignedS *sizeOfOrbit)      /* Set so that sizeOfOrbit[i] is the size of
                                   the i'th orbit. */
;

extern Unsigned cellNumberAtDepth(
   const PartitionStack *const UpsilonStack,
   const Unsigned depth,
   const Unsigned alpha)
;

extern Unsigned numberOfCells(
   const Partition *const Pi)
;

#endif
