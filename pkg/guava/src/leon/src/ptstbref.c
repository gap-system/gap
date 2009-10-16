/* File ptstbref.c.  Contains functions relating to refinements based on the
   point stabilizer property (the refinements SSS_{alpha,i} in the reference),
   as follows:

      pointStabRefine:       A refinement family based on the point stabilizer
                             property.
      isPointStabReducible:  A function to checks whether the top partition
                             on a partition stack is SSS-reducible and
                             returns a refinement acting nontrivially on the
                             top partition if so. */


#include "group.h"

#include "partn.h"
#include "cstrbas.h"
#include "errmesg.h"

CHECK( ptstbr)

extern GroupOptions options;

extern UnsignedS (*chooseNextBasePoint)(
   const PermGroup *const G,
   const PartitionStack *const UpsilonStack);



/*-------------------------- pointStabRefine ------------------------------*/

/* The function implements the refinement family pointStabRefine (denoted
   SSS_alpha in the reference).  This family consists of the elementary
   refinements ssS_{alpha,i}, where alpha is in Omega and where 1 <= i <=
   degree.  Application of sSS_{alpha,i} to UpsilonStack splits off point alpha
   from cell i of the top partition of UpsilonStack and pushes the resulting
   partition onto UpsilonStack, unless sSS_{alpha,i} acts trivially on the top
   partition, in which case UpsilonStack remains unchanged.

   The refinement parameters are as follows:
      refnParm[0].intParm:  alpha,
      refnParm[1].intParm:  i.
   There are no refinement family parameters.    */

SplitSize pointStabRefine(
   const RefinementParm familyParm[],       /* No family parms.  */
   const RefinementParm refnParm[],         /* parm[0] = alpha, parm[1] = i. */
   PartitionStack *const UpsilonStack)      /* The partition stack, as above. */
{
   const Unsigned  alpha = refnParm[0].intParm,
                   cellToSplit = refnParm[1].intParm;
   Unsigned  oldAlphaPosition, newAlphaPosition, temp;
   Unsigned  height = UpsilonStack->height;
   UnsignedS     *const pointList = UpsilonStack->pointList,
                 *const invPointList = UpsilonStack->invPointList,
                 *const cellNumber = UpsilonStack->cellNumber,
                 *const parent = UpsilonStack->parent,
                 *const startCell = UpsilonStack->startCell,
                 *const cellSize = UpsilonStack->cellSize;
   SplitSize  split;

   /* First check if the refinement acts nontrivially on UpsilonTop. If not
      return immediately. */
   if ( cellNumber[alpha] != cellToSplit || cellSize[cellToSplit] == 1 ) {
      split.oldCellSize = cellSize[cellToSplit];
      split.newCellSize = 0;
      return split;
   }

   /* Now split cell cellToSplit of UpsilonTop. */
   oldAlphaPosition = invPointList[alpha];
   newAlphaPosition = startCell[cellToSplit] + cellSize[cellToSplit] - 1;
   EXCHANGE( pointList[oldAlphaPosition], pointList[newAlphaPosition], temp)
   EXCHANGE( invPointList[pointList[oldAlphaPosition]],
             invPointList[pointList[newAlphaPosition]], temp)
   ++height; ++UpsilonStack->height;
   cellNumber[alpha] = height;
   startCell[height] = newAlphaPosition;
   parent[height] = cellToSplit;
   cellSize[height] = 1;
   --cellSize[cellToSplit];

   /* Set the return value and return to caller. */
   split.oldCellSize = cellSize[cellToSplit];
   split.newCellSize = 1;
   return split;
}


/*-------------------------- isPointStabReducible -------------------------*/

/* The function isPointStabReducible checks whether the top partition UpsilonTop
   on given partition stack UpsilonStack is SSS_alpha-reducible.  (In
   applications, it will be.)  Assuming so, it returns a refinement-priority
   pair consisting of a refinement acting nontrivially on UpsilonTop and a
   priority.  The priority (included for consistency, but not normally used)
   will be very high.  The refinement will be sSS_{alpha,i}, where i is such
   that cell i of UpsilonTop containing alpha, and where alpha is chosen to
   minimize the expression

            (size of cell in UpsilonTop of alpha) /
               (orbit length in G^(level) of alpha) ^ 3 /
                  1.2 ^ (number of i < level with alpha in same cell of Pi_{i-1}
                  as base[i]),

   subject to alpha lying in a cell of size at least 2 in UpsilonTop.
   If UpsilonTop is SSS-irreducible, the priority in the
   return value is set to IRREDUCIBLE, and the refinement is undefined.

   This function must be called only from function constructRBase during R-base
   construction. */

RefinementPriorityPair isPointStabReducible(
   const RefinementFamily *family,             /* The refinement family (mapping
                                                  must be pointStabRefn; there
                                                  are no genuine parms. */
   const PartitionStack *const UpsilonStack,   /* The partition stack above. */
   PermGroup *G,                               /* For optimization. */
   RBase     *AAA,                             /* For optimization. */
   Unsigned  level)                            /* For optimization. */
{
   Unsigned    pt, orbitNo, i, alpha;
#ifndef NOFLOAT
   float  priority, minPriority, orbitLen;
#endif
#ifdef NOFLOAT
   unsigned long  priority, minPriority, orbitLen, cubeRoot;
#endif
   RefinementPriorityPair reducingRefn;
   const Unsigned    degree = UpsilonStack->degree;
   const UnsignedS   *const cellNumber = UpsilonStack->cellNumber,
                     *const cellSize = UpsilonStack->cellSize;

   /* Check that the refinement mapping really is pointStabRefn, as required. */
   if ( family->refine != pointStabRefine )
      ERROR( "isPointStabReducible", "Error: incorrect refinement mapping");

   /* Here we compute an internal priority for each possible value of alpha
      and find which alpha minimizes the priority.  Note the internal priority
      is not the priority in the return value. */
   alpha = 0;
   if ( options.alphaHat1 >= 1 && options.alphaHat1 <= degree &&
                        cellSize[cellNumber[options.alphaHat1]] > 1 )
      alpha = options.alphaHat1;
   else if ( chooseNextBasePoint )
      alpha = chooseNextBasePoint( G, UpsilonStack);
   else if ( !IS_SYMMETRIC(G) )
      for ( pt = 1 ; pt <= degree ; ++pt ) {
         if ( cellSize[cellNumber[pt]] > 1 ) {
#ifndef NOFLOAT
            priority = ( cellSize[cellNumber[pt]] >= options.idealBasicCellSize ) ?
                            (float) cellSize[cellNumber[pt]] :
                            (float) (2 * options.idealBasicCellSize -
                                         cellSize[cellNumber[pt]]);
            orbitNo = G->orbNumberOfPt[level][pt];
            orbitLen = (float) (G->startOfOrbitNo[level][orbitNo+1] -
                       G->startOfOrbitNo[level][orbitNo]);
            priority *= priority * priority;
            priority /= orbitLen;
            for ( i = 1 ; i < level ; ++i)
               if ( cellNumberAtDepth( AAA->PsiStack, i, pt) == AAA->p_[i] )
                  priority /= 1.2;
#endif
#ifdef NOFLOAT
            priority = ( cellSize[cellNumber[pt]] >= options.idealBasicCellSize ) ?
                            (unsigned long) cellSize[cellNumber[pt]] :
                            (unsigned long) (2 * options.idealBasicCellSize -
                                         cellSize[cellNumber[pt]]);
            orbitNo = G->orbNumberOfPt[level][pt];
            orbitLen = G->startOfOrbitNo[level][orbitNo+1] -
                       G->startOfOrbitNo[level][orbitNo];
            for ( cubeRoot = 1 ; cubeRoot * cubeRoot * cubeRoot <= orbitLen ;
                                 ++cubeRoot )
               ;
            priority /= cubeRoot - 1;
            for ( i = 1 ; i < level ; ++i)
               if ( cellNumberAtDepth( AAA->PsiStack, i, pt) == AAA->p_[i] ) {
                  priority *= 11;
                  priority /= 12;
               }
#endif
            if ( alpha == 0 || priority < minPriority ) {
               minPriority = priority;
               alpha = pt;
            }
         }
      }
   else
      for ( pt = 1 ; pt <= degree ; ++pt )
         if ( cellSize[cellNumber[pt]] > 1 ) {
            priority = cellSize[cellNumber[pt]];
            if ( alpha == 0 || priority < minPriority ) {
               minPriority = priority;
               alpha = pt;
            }
         }

   /* Set return value and return to caller. */
   if ( alpha == 0 )
      reducingRefn.priority = IRREDUCIBLE;
   else {
      reducingRefn.refn.family = (RefinementFamily *) family;
      reducingRefn.refn.refnParm[0].intParm = alpha;
      reducingRefn.refn.refnParm[1].intParm = cellNumber[alpha];
      reducingRefn.priority = 30000;
   }
   return reducingRefn;
}
