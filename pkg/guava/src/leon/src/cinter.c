/* File cinter.c.  Contains function intersection, the main function for a
   program that may be used to compute the intersection of two permutation
   groups. */

#include <stddef.h>
#include <stdlib.h>

#include "group.h"

#include "compcrep.h"
#include "compsg.h"
#include "errmesg.h"
#include "orbrefn.h"

CHECK( cinter)

extern GroupOptions options;


/*-------------------------- intersection ---------------------------------*/

/* Function intersection.  Returns a new permutation group representing the
   intersection of two permutation groups G and E on Omega. The algorithm is
   based on Figure 9 in the paper "Permutation group algorithms based on
   partitions" by the author.  */

#define familyParm familyParm_L

PermGroup *intersection(
   PermGroup *const G,            /* The first permutation group. */
   PermGroup *const E,            /* The second permutation group. */
   PermGroup *const L)            /* A (possibly trivial) known subgroup of the
                                     intersection of G and E.  (A null pointer
                                     designates a trivial group.) */
{
   RefinementFamily OOO_G, OOO_E;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];
   ExtraDomain *extra[1];

   OOO_G.refine = orbRefine;
   OOO_G.familyParm[0].ptrParm = G;

   OOO_E.refine = orbRefine;
   OOO_E.familyParm[0].ptrParm = E;

   refnFamList[0] = &OOO_G;
   refnFamList[1] = &OOO_E;
   refnFamList[2] = NULL;

   reducChkList[0] = isOrbReducible;
   reducChkList[1] = isOrbReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[0]->refnType = 'O';
   specialRefinement[0]->leftGroup = G;
   specialRefinement[0]->rightGroup = G;

   specialRefinement[1] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[1]->refnType = 'O';
   specialRefinement[1]->leftGroup = E;
   specialRefinement[1]->rightGroup = E;

   specialRefinement[2] = NULL;

   extra[0] = NULL;

   initializeOrbRefine( G);
   initializeOrbRefine( E);

   return  computeSubgroup( G, NULL, refnFamList, reducChkList,
                            specialRefinement, extra, L);
}
#undef familyParm


