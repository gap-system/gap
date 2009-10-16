/* File cparstab.c.  Contains function partnStabilizer, the main function for a
   program that may be used to compute the stabilizer in a permutation group
   of an ordered partition.  Also contains functions as follows:

      parStabRefnInitialize:  Initialize set stabilizer refinement functions.
      setStabRefine:          A refinement family based on the set stabilizer
                              property.
      isSetStabReducible:     A function to check SSS-reducibility. */

#include <stddef.h>
#include <stdlib.h>

#include "group.h"

#include "compcrep.h"
#include "compsg.h"
#include "errmesg.h"
#include "orbrefn.h"

CHECK( cparst)

RefinementMapping partnStabRefine;
ReducChkFn isPartnStabReducible;
 void initializePartnStabRefn(void);

static Partition *knownIrreducible[10]  /* Null terminated 0-base list of */
                = {NULL};               /*  point sets Lambda for which top */
                                        /*  partition on UpsilonStack is */
                                        /*  known to be SSS_Lambda irred. */


/*-------------------------- partnStabilizer ------------------------------*/

/* Function partnStabilizer.  Returns a new permutation group representing the
   stabilizer in a permutation group G of an ordered partition Lambda of the
   point set Omega.  The algorithm is based on Figure 9 in the paper
   "Permutation group algorithms based on partitions" by the author.  */

#define familyParm familyParm_L

PermGroup *partnStabilizer(
   PermGroup *const G,             /* The containing permutation group. */
   const Partition *const Lambda,  /* The point set to be stabilized. */
   PermGroup *const L)             /* A (possibly trivial) known subgroup of the
                                      stabilizer in G of Lambda.  (A null pointer
                                      designates a trivial group.) */
{
   RefinementFamily OOO_G, SSS_Lambda;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];
   ExtraDomain *extra[1];

   OOO_G.refine = orbRefine;
   OOO_G.familyParm[0].ptrParm = G;

   SSS_Lambda.refine = partnStabRefine;
   SSS_Lambda.familyParm[0].ptrParm = (void *) Lambda;

   refnFamList[0] = &OOO_G;
   refnFamList[1] = &SSS_Lambda;
   refnFamList[2] = NULL;

   reducChkList[0] = isOrbReducible;
   reducChkList[1] = isPartnStabReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[0]->refnType = 'O';
   specialRefinement[0]->leftGroup = G;
   specialRefinement[0]->rightGroup = G;

   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   extra[0] = NULL;

   initializeOrbRefine( G);
   initializePartnStabRefn();

   return  computeSubgroup( G, NULL, refnFamList, reducChkList,
                            specialRefinement, extra, L);
}
#undef familyParm


/*-------------------------- partnImage -----------------------------------*/

/* Function partnImage.  Returns a new permutation in a specified group G mapping
   a specified partition Lambda to a specified partition Xi.  The algorithm is
   based on Figure 9 in the paper "Permutation group algorithms based on
   partitions" by the author. */

Permutation *partnImage(
   PermGroup *const G,            /* The containing permutation group. */
   const Partition *const Lambda,  /* One of the partitions. */
   const Partition *const Xi,      /* The other partition. */
   PermGroup *const L_L,          /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Lambda.  (A null pointer
                                     designates a trivial group.) */
   PermGroup *const L_R)          /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Xi.  (A null pointer
                                     designates a trivial group.) */
{
   RefinementFamily OOO_G, SSS_Lambda_Xi;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];
   ExtraDomain *extra[1];

   OOO_G.refine = orbRefine;
   OOO_G.familyParm_L[0].ptrParm = G;
   OOO_G.familyParm_R[0].ptrParm = G;

   SSS_Lambda_Xi.refine = partnStabRefine;
   SSS_Lambda_Xi.familyParm_L[0].ptrParm = (void *) Lambda;
   SSS_Lambda_Xi.familyParm_R[0].ptrParm = (void *) Xi;

   refnFamList[0] = &OOO_G;
   refnFamList[1] = &SSS_Lambda_Xi;
   refnFamList[2] = NULL;

   reducChkList[0] = isOrbReducible;
   reducChkList[1] = isPartnStabReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[0]->refnType = 'O';
   specialRefinement[0]->leftGroup = G;
   specialRefinement[0]->rightGroup = G;

   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   extra[0] = NULL;

   initializeOrbRefine( G);
   initializePartnStabRefn();

   return  computeCosetRep( G, NULL, refnFamList, reducChkList,
                            specialRefinement, extra, L_L, L_R);
}


/*-------------------------- initializePartnStabRefn ----------------------*/

void initializePartnStabRefn( void)
{
   knownIrreducible[0] = NULL;
}


/*-------------------------- partnStabRefine ------------------------------*/

/* The function implements the refinement family partnStabRefine (denoted
   SSS_Lambda in the reference).  This family consists of the elementary
   refinements ssS_{Lambda,i,j}, where Lambda fixed.  (It is the partition to
   be stabilized) and where 1 <= i, j <= degree.  Application of
   sSS_{Lambda,i,j} to UpsilonStack splits off from UpsilonTop the intersection
   of the j'th cell of Lambda and the i'th cell of UpsilonTop from cell i of
   the top partition of UpsilonStack and pushes the resulting partition onto
   UpsilonStack, unless sSS_{Lambda,i,j} acts trivially on UpsilonTop, in
   which case UpsilonStack remains unchanged.

   The family parameter is:
         familyParm[0].ptrParm:  Lambda
   The refinement parameters are:
         refnParm[0].intParm:    i,
         refnParm[1].intParm:    j.

   In the expectation that this refinement will be applied only a small number
   of times, no attempt has been made to optimize this procedure. */


SplitSize partnStabRefine(
   const RefinementParm familyParm[],      /* Family parm: Lambda. */
   const RefinementParm refnParm[],        /* Refinement parm: i. */
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
{
   Partition *Lambda = familyParm[0].ptrParm;
   Unsigned  cellToSplit = refnParm[0].intParm,
             LambdaCellToUse = refnParm[1].intParm;
   Unsigned  m, last, i, j, temp;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const invPointList = UpsilonStack->invPointList,
              *const parent = UpsilonStack->parent,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   SplitSize  split;
   BOOLEAN cellSplits;

   /* First check if the refinement acts nontrivially on UpsilonTop. If not
      return immediately. */
   cellSplits = FALSE;
   for ( m = startCell[cellToSplit]+1 , last = m -1 + cellSize[cellToSplit] ;
         m < last ; ++m )
      if ( (Lambda->cellNumber[pointList[m]] == LambdaCellToUse) !=
           (Lambda->cellNumber[pointList[m-1]] == LambdaCellToUse) ) {
         cellSplits = TRUE;
         break;
      }
   if ( !cellSplits ) {
      split.oldCellSize = cellSize[cellToSplit];
      split.newCellSize = 0;
      return split;
   }

   /* Now split cell cellToSplit of UpsilonTop.  A variation of the splitting
      algorithm used in quicksort is applied. */
   i = startCell[cellToSplit]-1;
   j = last;
   while ( i < j ) {
      while ( Lambda->cellNumber[pointList[++i]] != LambdaCellToUse ) ;
      while ( Lambda->cellNumber[pointList[--j]] == LambdaCellToUse ) ;
      if ( i < j ) {
         EXCHANGE( pointList[i], pointList[j], temp)
         EXCHANGE( invPointList[pointList[i]], invPointList[pointList[j]], temp)
      }
   }
   ++UpsilonStack->height;
   for ( m = i ; m < last ; ++m )
      UpsilonStack->cellNumber[pointList[m]] = UpsilonStack->height;
   startCell[UpsilonStack->height] = i;
   parent[UpsilonStack->height] = cellToSplit;
   cellSize[UpsilonStack->height] = last - i;
   cellSize[cellToSplit] -= (last - i);
   split.oldCellSize = cellSize[cellToSplit];
   split.newCellSize = cellSize[UpsilonStack->height];
   return split;
}


/*-------------------------- isPartnStabReducible -------------------------*/

/* The function isPartnStabReducible checks whether the top partition on a
   given partition stack is SSS_Lambda-reducible, where Lambda is a fixed
   ordered partition.   If so, it returns a pair consisting of a refinement
   acting nontrivially on the top partition and a priority.  Otherwise it
   returns a structure of type RefinementPriorityPair in which the priority
   field is IRREDUCIBLE.  Assuming
   that a reducing refinement is found, the (reverse) priority is set very
   low (1).  Note that, once this function returns negative in the priority
   field once, it will do so on all subsequent calls.  (The static variable
   knownIrreducible is set to true in this situation.)  Again, no attempt
   at efficiency has been made.  */

RefinementPriorityPair isPartnStabReducible(
   const RefinementFamily *family,
   const PartitionStack *const UpsilonStack)
{
   Partition *Lambda = family->familyParm_L[0].ptrParm;
   Unsigned    i, cellNo, position;
   RefinementPriorityPair reducingRefn;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;

   /* Check that the refinement mapping really is partnStabRefn, as required. */
   if ( family->refine != partnStabRefine )
      ERROR( "isPartnStabReducible", "Error: incorrect refinement mapping");

   /* If the top partition has previously been found to be SSS-irreducible, we
      return immediately. */
   for ( i = 0 ; knownIrreducible[i] && knownIrreducible[i] != Lambda ; ++i )
      ;
   if ( knownIrreducible[i] ) {
      reducingRefn.priority = IRREDUCIBLE;
      return reducingRefn;
   }

   /* If we reach here, the top partition has not been previously found to be
      SSS-irreducible.  We check each cell in turn to see if it intersects at
      least two cells of Lambda.  If such a cell is found, we return
      immediately. */
   for ( cellNo = 1 ; cellNo <= UpsilonStack->height ; ++cellNo ) {
      for ( position = startCell[cellNo]+1 ; position < startCell[cellNo] +
                                           cellSize[cellNo] ; ++position )
         if ( Lambda->cellNumber[pointList[position]] !=
              Lambda->cellNumber[pointList[position-1]] ) {
            reducingRefn.refn.family = family;
            reducingRefn.refn.refnParm[0].intParm = cellNo;
            reducingRefn.refn.refnParm[1].intParm =
                                     Lambda->cellNumber[pointList[position]];
            reducingRefn.priority = 1;
            return reducingRefn;
         }

   }

   /* If we reach here, we have found the top partition to be SSS_Lambda
      irreducible, so we add Lambda to the list knownIrreducible and return. */
   for ( i = 0 ; knownIrreducible[i] ; ++i )
      ;
   if ( i < 9 ) {
      knownIrreducible[i] = Lambda;
      knownIrreducible[i+1] = NULL;
   }
   else
      ERROR( "isPartnStabReducible", "Number of point sets exceeded max of 9.")

   reducingRefn.priority = IRREDUCIBLE;
   return reducingRefn;
}
