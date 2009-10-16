/* File csetstab.c.  Contains function setStabilizer, the main function for a
   program that may be used to compute the stabilizer in a permutation group
   of a subset of the set of points.  Also contains functions as follows:

      setStabRefnInitialize:  Initialize set stabilizer refinement functions.
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

CHECK( csetst)

extern GroupOptions options;

static RefinementMapping setStabRefine;
static ReducChkFn isSetStabReducible;
static void initializeSetStabRefn(void);

static PointSet *knownIrreducible[10]  /* Null terminated 0-base list of */
                = {NULL};              /*  point sets Lambda for which top */
                                       /*  partition on UpsilonStack is */
                                       /*  known to be SSS_Lambda irred. */


/*-------------------------- setStabilizer --------------------------------*/

/* Function setStabilizer.  Returns a new permutation group representing the
   stabilizer in a permutation group G of a subset Lambda of the point set
   Omega.  The algorithm is based on Figure 9 in the paper "Permutation
   group algorithms based on partitions" by the author.  */

#define familyParm familyParm_L

PermGroup *setStabilizer(
   PermGroup *const G,            /* The containing permutation group. */
   const PointSet *const Lambda,  /* The point set to be stabilized. */
   PermGroup *const L)            /* A (possibly trivial) known subgroup of the
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

   SSS_Lambda.refine = setStabRefine;
   SSS_Lambda.familyParm[0].ptrParm = (void *) Lambda;

   refnFamList[0] = &OOO_G;
   refnFamList[1] = &SSS_Lambda;
   refnFamList[2] = NULL;

   reducChkList[0] = isOrbReducible;
   reducChkList[1] = isSetStabReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[0]->refnType = 'O';
   specialRefinement[0]->leftGroup = G;
   specialRefinement[0]->rightGroup = G;

   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   extra[0] = NULL;

   initializeOrbRefine( G);
   initializeSetStabRefn();

   return  computeSubgroup( G, NULL, refnFamList, reducChkList,
                            specialRefinement, extra, L);
}
#undef familyParm


/*-------------------------- setImage -------------------------------------*/

/* Function setImage.  Returns a new permutation in a specified group G mapping
   a specified point set Lambda to a specified point set Xi.  The algorithm is
   based on Figure 9 in the paper "Permutation group algorithms based on
   partitions" by the author. */

Permutation *setImage(
   PermGroup *const G,            /* The containing permutation group. */
   const PointSet *const Lambda,  /* One of the point sets. */
   const PointSet *const Xi,      /* The other point set. */
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

   SSS_Lambda_Xi.refine = setStabRefine;
   SSS_Lambda_Xi.familyParm_L[0].ptrParm = (void *) Lambda;
   SSS_Lambda_Xi.familyParm_R[0].ptrParm = (void *) Xi;

   refnFamList[0] = &OOO_G;
   refnFamList[1] = &SSS_Lambda_Xi;
   refnFamList[2] = NULL;

   reducChkList[0] = isOrbReducible;
   reducChkList[1] = isSetStabReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[0]->refnType = 'O';
   specialRefinement[0]->leftGroup = G;
   specialRefinement[0]->rightGroup = G;

   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   extra[0] = NULL;

   initializeOrbRefine( G);
   initializeSetStabRefn();

   return  computeCosetRep( G, NULL, refnFamList, reducChkList,
                            specialRefinement, extra, L_L, L_R);
}


/*-------------------------- initializeSetStabRefn ------------------------*/

static void initializeSetStabRefn( void)
{
   knownIrreducible[0] = NULL;
}

/*-------------------------- setStabRefine --------------------------------*/

/* The function implements the refinement family setStabRefine (denoted
   SSS_Lambda in the reference).  This family consists of the elementary
   refinements ssS_{Lambda,i}, where Lambda fixed.  (It is the set to be
   stabilized) and where 1 <= i <= degree.  Application of sSS_{Lambda,i} to
   UpsilonStack splits off from UpsilonTop the intersection of Lambda and the
   i'th cell of UpsilonTop from cell i of the top partition of UpsilonStack and
   pushes the resulting partition onto UpsilonStack, unless sSS_{Lambda,i} acts
   trivially on UpsilonTop, in which case UpsilonStack remains unchanged.

   The family parameter is:
         familyParm[0].ptrParm:  Lambda
   The refinement parameters are:
         refnParm[0].intParm:    i.

   In the expectation that this refinement will be applied only a small number
   of times, no attempt has been made to optimize this procedure. */


static SplitSize setStabRefine(
   const RefinementParm familyParm[],      /* Family parm: Lambda. */
   const RefinementParm refnParm[],        /* Refinement parm: i. */
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
{
   PointSet *Lambda = familyParm[0].ptrParm;
   Unsigned  cellToSplit = refnParm[0].intParm;
   Unsigned  m, last, i, j, temp,
             inLambdaCount = 0,
             outLambdaCount = 0;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const invPointList = UpsilonStack->invPointList,
              *const cellNumber = UpsilonStack->cellNumber,
              *const parent = UpsilonStack->parent,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   char *inSet = Lambda->inSet;
   SplitSize  split;

   /* First check if the refinement acts nontrivially on UpsilonTop. If not
      return immediately. */
   for ( m = startCell[cellToSplit] , last = m + cellSize[cellToSplit] ;
         m < last && (inLambdaCount == 0 || outLambdaCount == 0) ; ++m )
      if ( inSet[pointList[m]] )
         ++inLambdaCount;
      else
         ++outLambdaCount;
   if ( inLambdaCount == 0 || outLambdaCount == 0 ) {
      split.oldCellSize = cellSize[cellToSplit];
      split.newCellSize = 0;
      return split;
   }

   /* Now split cell cellToSplit of UpsilonTop.  A variation of the splitting
      algorithm used in quicksort is applied. */
   i = startCell[cellToSplit]-1;
   j = last;
   while ( i < j ) {
      while ( !inSet[pointList[++i]] );
      while (  inSet[pointList[--j]] );
      if ( i < j ) {
         EXCHANGE( pointList[i], pointList[j], temp)
         EXCHANGE( invPointList[pointList[i]], invPointList[pointList[j]], temp)
      }
   }
   ++UpsilonStack->height;
   for ( m = i ; m < last ; ++m )
      cellNumber[pointList[m]] = UpsilonStack->height;
   startCell[UpsilonStack->height] = i;
   parent[UpsilonStack->height] = cellToSplit;
   cellSize[UpsilonStack->height] = last - i;
   cellSize[cellToSplit] -= (last - i);
   split.oldCellSize = cellSize[cellToSplit];
   split.newCellSize = cellSize[UpsilonStack->height];
   return split;
}


/*-------------------------- isSetStabReducible ---------------------------*/

/* The function isSetStabReducible checks whether the top partition on a given
   partition stack is SSS_Lambda-reducible, where Lambda is a fixed set. If
   so, it returns a pair consisting of a refinement acting nontrivially on
   the top partition and a priority.  Otherwise it returns a structure of
   type RefinementPriorityPair in which the priority field is IRREDUCIBLE.  Assuming
   that a reducing refinement is found, the (reverse) priority is set very
   low (1).  Note that, once this function returns negative in the priority
   field once, it will do so on all subsequent calls.  (The static variable
   knownIrreducible is set to true in this situation.)  Again, no attempt
   at efficiency has been made.  */

static RefinementPriorityPair isSetStabReducible(
   const RefinementFamily *family,
   const PartitionStack *const UpsilonStack)
{
   PointSet *Lambda = family->familyParm_L[0].ptrParm;
   Unsigned    i, cellNo, position;
   BOOLEAN ptsInLambda, ptsNotInLambda;
   RefinementPriorityPair reducingRefn;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   char *inSet = Lambda->inSet;

   /* Check that the refinement mapping really is setStabRefn, as required. */
   if ( family->refine != setStabRefine )
      ERROR( "isSetStabReducible", "Error: incorrect refinement mapping");

   /* If the top partition has previously been found to be SSS-irreducible, we
      return immediately. */
   for ( i = 0 ; knownIrreducible[i] && knownIrreducible[i] != Lambda ; ++i )
      ;
   if ( knownIrreducible[i] ) {
      reducingRefn.priority = IRREDUCIBLE;
      return reducingRefn;
   }

   /* If we reach here, the top partition has not been previously found to be
      SSS-irreducible.  We check each cell in turn to see if it intersects both
      Lambda and Omega - Lambda.  If such a cell is found, we return
      immediately. */
   for ( cellNo = 1 ; cellNo <= UpsilonStack->height ; ++cellNo ) {
      ptsInLambda = ptsNotInLambda = FALSE;
      for ( position = startCell[cellNo] ; position < startCell[cellNo] +
                                           cellSize[cellNo] ; ++position ) {
         if ( inSet[pointList[position]] )
            ptsInLambda = TRUE;
         else
            ptsNotInLambda = TRUE;
         if ( ptsInLambda && ptsNotInLambda ) {
            reducingRefn.refn.family = family;
            reducingRefn.refn.refnParm[0].intParm = cellNo;
            reducingRefn.priority = 1;
            return reducingRefn;
         }
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
      ERROR( "isSetStabReducible", "Number of point sets exceeded max of 9.")

   reducingRefn.priority = IRREDUCIBLE;
   return reducingRefn;
}
