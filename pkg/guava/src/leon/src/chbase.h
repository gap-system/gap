#ifndef CHBASE
#define CHBASE

extern void insertBasePoint(
   PermGroup *G,           /* The permutation group (base and sgs known). */
   Unsigned newLevel,      /* If newLevel = i and newBasePoint = b, the   */
   Unsigned newBasePoint)  /*   base for G is changed from (b[1],...,     */
                           /*   b(i-1),...) to (b[1],...,b[i-1],b,...).   */
;

extern void changeBase(
   PermGroup *G,        /* The permutation group. */
   UnsignedS *newBase)  /* An origin-1 null-terminated sequence of points. */
                        /*   The new base will consist of newBase, followed */
                        /*   by arbitrary extra points as needed.  Redundant */
                        /*   base points will not be deleted from newBase,  */
                        /*   but no redundant points will be adjoined.      */
;

extern Unsigned removeRedunSGens(
   PermGroup *G,
   Unsigned startLevel)
;

extern Unsigned restrictBasePoints(
   PermGroup *const G,
   Unsigned *acceptablePoint)
;

#endif
