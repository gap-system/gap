#ifndef ADDSGEN
#define ADDSGEN

extern void addStrongGenerator(
   PermGroup *G,              /* Group to which strong gen is adjoined. */
   Permutation *newGen,       /* The new strong generator. It must move
                                 a base point (not checked). */
   BOOLEAN essentialAtOne)    /* Should the new generator be marked as essential
                                 at level 1. */
;

#endif
