/* File cuprstab.c.  Contains function uPartnStabilizer, the main function for a
   program that may be used to compute the stabilizer in a permutation group
   of an unordered partition.  Also contains functions as follows:

      uParStabRefnInitialize:  Initialize set stabilizer refinement functions.
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

CHECK( cuprst)

extern GroupOptions options;

static RefinementMapping uPartnStabRefine;
static ReducChkFn isUPartnStabReducible;
static void initializeUPartnStabRefn( Unsigned xDegree);

static Partition *knownIrreducible[10]  /* Null terminated 0-base list of */
                = {NULL};               /*  point sets Lambda for which top */
                                        /*  partition on UpsilonStack is */
                                        /*  known to be SSS_Lambda irred. */

/* COPIED FROM ORBREFN */
#define HASH( i, j)  ( (7L * i + j) % hashTableSize )

typedef struct RefnListEntry {
   Unsigned i;                     /* Cell number in UpsilonTop to split. */
   Unsigned j;                     /* Orbit number of G^(level) in split. */
   Unsigned newCellSize;           /* Size of new cell created by split. */
   struct RefnListEntry *hashLink; /* List of refns with same hash value. */
   struct RefnListEntry *next;     /* Next refn on list of all refinements. */
   struct RefnListEntry *last;     /* Last refn on list of all refinements. */
} RefnListEntry;

static struct {
   Unsigned groupCount;
   PermGroup *group[10];
   RefnListEntry **hashTable[10];
   RefnListEntry *refnList[10];
   Unsigned oldLevel[10];
   RefnListEntry *freeListHeader[10];
   RefnListEntry *inUseListHeader[10];
} refnData = {0};

static Unsigned trueGroupCount, hashTableSize;
static RefnListEntry **hashTable, *freeListHeader, *inUseListHeader;
/* END COPIED CODE. */

static Unsigned currentZDepth[10];

static Unsigned *totalSize;


/*-------------------------- uPartnStabilizer ------------------------------*/

/* Function uPartnStabilizer.  Returns a new permutation group representing the
   stabilizer in a permutation group G of an unordered partition Lambda of the
   point set Omega.  The algorithm is based on Figure 9 in the paper
   "Permutation group algorithms based on partitions" by the author.  */

#define familyParm familyParm_L

PermGroup *uPartnStabilizer(
   PermGroup *const G,             /* The containing permutation group. */
   const Partition *const Lambda,  /* The point set to be stabilized. */
   PermGroup *const L)             /* A (possibly trivial) known subgroup of the
                                      stabilizer in G of Lambda.  (A null pointer
                                      designates a trivial group.) */
{
#ifdef xxxx
   RefinementFamily OOO_G, SSS_Lambda;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];
   ExtraDomain* extra[2];

   OOO_G.refine = orbRefine;
   OOO_G.familyParm[0].ptrParm = G;

   SSS_Lambda.refine = uPartnStabRefine;
   SSS_Lambda.familyParm[0].ptrParm = (void *) Lambda;

   refnFamList[0] = &OOO_G;
   refnFamList[1] = &SSS_Lambda;
   refnFamList[2] = NULL;

   reducChkList[0] = isOrbReducible;
   reducChkList[1] = isUPartnStabReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[0]->refnType = 'O';
   specialRefinement[0]->leftGroup = G;
   specialRefinement[0]->rightGroup = G;

   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   initializeOrbRefine( G);
   initializeUPartnStabRefn();

   ex = extra[0] = allocExtraDomain();
   xDegree = extra->xDegree[0] = numberOfCells( Lambda);
   ex->xPsiStack = newCellPartitionStack( xDegree);
   ex->xUpsilonStack = newCellPartitionStack( xDegree);
   ex->xRRR = (Refinement *) malloc( (xDegree+2) * sizeof(Refinement) );
   ex->applyAfter =
         (UnsignedS *) malloc( (xDegree+2) * sizeof(UnsignedS) );
   ex->xA_ =
         (UnsignedS *) malloc( (xDegree+2) * sizeof(UnsignedS) );
   ex->xB_ =
         (UnsignedS *) malloc( (xDegree+2) * sizeof(UnsignedS) );
   extra[1] = NULL;

   return  computeSubgroup( G, NULL, refnFamList, reducChkList,
                            specialRefinement, extra, L);
#endif
}
#undef familyParm


/*-------------------------- uPartnImage -----------------------------------*/

/* Function uPartnImage.  Returns a new permutation in a specified group G mapping
   a specified unordered partition Lambda to a specified unordered partition
   Xi.  The algorithm is based on Figure 9 in the paper "Permutation group algorithms
   based on partitions" by the author. */

Permutation *uPartnImage(
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
#ifdef XXXXXX
   RefinementFamily OOO_G, SSS_Lambda_Xi;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];

   OOO_G.refine = orbRefine;
   OOO_G.familyParm_L[0].ptrParm = G;
   OOO_G.familyParm_R[0].ptrParm = G;

   SSS_Lambda_Xi.refine = uPartnStabRefine;
   SSS_Lambda_Xi.familyParm_L[0].ptrParm = (void *) Lambda;
   SSS_Lambda_Xi.familyParm_R[0].ptrParm = (void *) Xi;

   refnFamList[0] = &OOO_G;
   refnFamList[1] = &SSS_Lambda_Xi;
   refnFamList[2] = NULL;

   reducChkList[0] = isOrbReducible;
   reducChkList[1] = isUPartnStabReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[0]->refnType = 'O';
   specialRefinement[0]->leftGroup = G;
   specialRefinement[0]->rightGroup = G;

   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   initializeOrbRefine( G);
   initializeUPartnStabRefn();

   return  computeCosetRep( G, NULL, refnFamList, reducChkList,
                            specialRefinement, L_L, L_R);
#endif
}


/*-------------------------- initializePartnStabRefn ----------------------*/

static void initializePartnStabRefn(
   Unsigned xDegree)
{
   knownIrreducible[0] = NULL;
   currentZDepth[0] = 0;
   totalSize = (UnsignedS *) malloc( xDegree * sizeof(UnsignedS) );
   totalSize[1] = xDegree;
}


/*-------------------------- uPartnStabRefine ------------------------------*/

/* The function implements the refinement family uPartnStabRefine.   Here
   ssS_{Lambda,i,j,p} acting on Pi (the top partition of UpsilonStack) splits
   from cell i of Pi those points lying in the union of the j'th cell group of
   Pi^(p) (the top partition on extra[p]->xUpsilonStack) on Omega^(p).  Note
   Lambda is the base partition for extra[p]->xUpsilonStack

   The family parameter is:
         familyParm[0].ptrParm:  extra[p]->xUpsilonStack
   The refinement parameters are:
         refnParm[0].intParm:    i,
         refnParm[1].intParm:    j.
*/

static SplitSize uPartnStabRefine(
   const RefinementParm familyParm[],
   const RefinementParm refnParm[],
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
{
#ifdef xxxx
   CellPartitionStack *xUpsilonStack = familyParm[0].ptrParm;
   Partition *Lambda = xUpsilonStack->basePartn;
   Unsigned  i = refnParm[0].intParm,
             j = refnParm[1].intParm;
   Unsigned  m, k, r, last, left, right, temp, startNewCell, pt, t;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const invPointList = UpsilonStack->invPointList,
              *const parent = UpsilonStack->parent,
              *const startCell = UpsilonStack->startCell,
              *const cellNumber = UpsilonStack->cellNumber,
              *const cellSize = UpsilonStack->cellSize,
              *const xCellList = xUpsilonStack->cellList,
              *const xCellGroupNumber = xUpsilonStack->cellGroupNumber,
              *const xStartCellGroup = xUpsilonStack->startCellGroup,
              *const xCellGroupSize = xUpsilonStack->cellGroupSize,
              *const LambdaCellNumber = Lambda->cellNumber;
   SplitSize  split;
   BOOLEAN cellSplits;

   /* First check if the refinement acts nontrivially on UpsilonTop. If not
      return immediately. */
   cellSplits = FALSE;
   for ( m = startCell[cellToSplit]+1 , last = m -1 + cellSize[cellToSplit] ;
         m < last ; ++m )
      if ( (xCellGroupNumber[LambdaCellNumber[pointList[m]]] == j) !=
           (xCellGroupNumber[LambdaCelllNumber[pointList[m-1]]] == j) ) {
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
   if ( cellSize[i] <= xUpsilonStack->totalGroupSize[j] ) {
      left = startCell[i] - 1;
      right = startCell[i] + cellSize[i];
      while ( left < right ) {
         while ( xCellGroupNumber[LambdaCellNumber[pointList[++left]]] != j )
            ;
         while ( xCellGroupNumber[LambdaCellNumber[pointList[--right]]] == j )
            ;
         if ( left < right ) {
            EXCHANGE( pointList[left], pointList[right], temp)
            EXCHANGE( invPointList[pointList[left]], invPointList[pointList[right]], temp)
         }
      }
      startNewCell = left;
   }
   else {
      startNewCell = startCell[i] + cellSize[i];
      for ( k = xStartCellGroup[j] ; k < xStartCellGroup[j] +
                                     xCellGroupSize[j] ; ++k ) {
         t = xCellList[k];
         for ( r = Lambda->startCell[t] ;
               LambdaCellNumber[Lambda->pointList[r]] == t ; ++r) {
            pt = Lambda->pointList[r];
            if ( cellNumber[pt] == i ) {
               --startNewCell;
               m = invPointList[pt];
               EXCHANGE( pointList[m], pointList[startNewCell], temp);
               EXCHANGE( invPointList[pointList[m]], invPointList[pointList[startNewCell]],
                         temp);
            }
         }
      }
   }

   ++UpsilonStack->height;
   for ( m = startNewCell ; m < last ; ++m )
      cellNumber[pointList[m]] = UpsilonStack->height;
   startCell[UpsilonStack->height] = startNewCell;
   parent[UpsilonStack->height] = i;
   cellSize[UpsilonStack->height] = last - startNewCell;
   cellSize[cellToSplit] -= cellSize[UpsilonStack->height];
   split.oldCellSize = cellSize[i];
   split.newCellSize = cellSize[UpsilonStack->height];
   return split;
#endif
}


/*-------------------------- initializeUPartnStabRefine --------------------------*/

void initializeUPartnStabRefine( PermGroup *G)
{
#ifdef xxxx
   /* Compute hash table size. */
   if ( refnData.groupCount == 0 ) {
      hashTableSize = G->degree;
      while ( hashTableSize > 11 &&
              (hashTableSize % 2 == 0 || hashTableSize % 3 == 0 ||
              hashTableSize % 5 == 0 || hashTableSize % 7 == 0) )
         --hashTableSize;
   }

   if ( refnData.groupCount < 9) {
      refnData.group[refnData.groupCount] = G;
      refnData.hashTable[refnData.groupCount] = allocPtrArrayDegree();
      refnData.refnList[refnData.groupCount] =
                    malloc( G->degree * (sizeof(RefnListEntry)+2) );
      if ( !refnData.refnList[refnData.groupCount] )
         ERROR( "initializeOrbRefine", "Memory allocation error.")
      refnData.oldLevel[refnData.groupCount] = UNKNOWN;
      ++refnData.groupCount;
      trueGroupCount = refnData.groupCount;
   }
   else
      ERROR( "initializeOrbRefine", "Orbit refinement limited to ten groups.")
#endif
}


/*-------------------------- xPartnStabRefine ------------------------------*/

#define RESTORE_ZERO for ( r = 1 ; r <= nonZeroCount ; ++r )  \
                       zeroArray[nonZeroPosition[r]] = 0; \
                       nonZeroCount = 0;

/* The function implements the refinement family xPartnStabRefine.   Here
   xssS_{Pi,i,j,m,p} acting on Pi^(p) (the top partition of PiStack^(p))
   splits from cell group i of Pi^(p) those cells intersecting cell j of Pi
   in exactly m points. /

   The family parameter is:
         familyParm[0].ptrParm:  extra[p]->xUpsilonStack
   The refinement parameters are:
         refnParm[0].intParm:    i,
         refnParm[1].intParm:    j.
         refnParm[2].intParm:    m.
*/

static SplitSize partnStabRefine(
   const RefinementParm familyParm[],
   const RefinementParm refnParm[],
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
{
#ifdef xxxx
   static Unsigned zeroArrayDegree = 0;
   static Unsigned nonZeroCount;
   static UnsignedS *zeroArray = NULL;
   static UnsignedS *nonZeroPosition = NULL;
   PartitionStack *xUpsilonStack = familyParm[1].ptrParm;
   Partition *Lambda = xUpsilonStack->basePartn;
   Unsigned  i = refnParm[0].intParm,
             j = refnParm[1].intParm,
             m = refnParm[2].intParm;
   Unsigned  t, last, k, r, temp, left, right, xStartNewCellGroup;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const invPointList = UpsilonStack->invPointList,
              *const parent = UpsilonStack->parent,
              *const startCell = UpsilonStack->startCell,
              *const cellNumber = UpsilonStack->cellNumber,
              *const cellSize = UpsilonStack->cellSize,
              *const xCellList = xUpsilonStack->cellList,
              *const xCellGroupNumber = xUpsilonStack->cellGroupNumber,
              *const xStartCellGroup = xUpsilonStack->startCellGroup,
              *const xCellGroupSize = xUpsilonStack->cellGroupSize,
              *const LambdaCellNumber = Lambda->cellNumber;
   SplitSize  split;
   BOOLEAN splitFlag, noSplitFlag;

   if ( zeroArrayDegree != Lambda->cellCount ) {
      if ( zeroArrayDegree != 0 ) {
         free( zeroArray );
         free( nonZeroPosition);
      }
      zeroArrayDegree = Lambda->cellCount;
      zeroArray = malloc( (zeroArrayDegree+2)*sizeof(UnsignedS) );
      for ( r = 1 ; r <= zeroArrayDegree ; ++r )
         zeroArrayDegree[r] = 0;
      nonZeroPositionCount = 0;
      nonZeroPosition = malloc( (zeroArrayDegree+2)*sizeof(UnsignedS) );
   }

   /* Here we set zeroArray[j] to the cardinality of
      (cell j of UpsilonTop) intersect (cell k of Lambda) for each k in
      cell group i of xUpsilonTop. */
   if ( xUpsilonStack->totalGroupSize[i] <= cellSize[j] )
      for ( k = xStartCellGroup[i] ; k < xStartCellGroup[i] +
                                         xCellGroupSize[i] ; ++k ) {
         for ( r = Lambda->startCell[k] ; r <= Lambda->startCell[k] +
                                            Lambda->cellSize[k] ; ++ r ) {
         if ( cellNumber[Lambda->pointList[r]] == j ) {
            if ( zeroArray[k] == 0 )
               nonZeroPosition[++nonZeroCount] = k;
            ++zeroArray[k];
         }
      }
   else
      for ( r = startCell[j] ; r < startCell[j]+cellSize[j] ; ++j ) {
         t = LambdaCellNumber[pointList[r]] );
         if ( xCellGroupNumber[t] == i ) {
            if ( zeroArray[t] == 0 )
               nonZeroPosition[++nonZeroCount] = t;
            ++zeroArray[t];
         }
      }

   /* Now reset zeroArray and return immediately if the cell group does not
      split. */
   splitFlag = nonSplitFlag = FALSE;
   if ( xUpsilonStack->cellCount > nonZeroCount )
      if ( m == 0 )
         splitFlag = TRUE;
      else
         nonSplitFlag = TRUE;
   for ( r = 1 ; r <= nonZeroCount && !splitFlag ; ++r )
      if ( zeroArray[nonZeroPosition[r]] == m )
         splitFlag = TRUE;
   for ( r = 1 ; r <= nonZeroCount && !nonSplitFlag ; ++r )
      if ( zeroArray[nonZeroPosition[r]] != m )
         nonSplitFlag = TRUE;
   if ( !splitFlag || !nonSplitFlag ) {
      RESTORE_ZERO
      split.oldCellSize = cellSize[cellToSplit];
      split.newCellSize = 0;
      return split;
   }

   /* Now split cell group i of xUpsilonTop.  A variation of the splitting
      algorithm used in quicksort is applied. */
   last = xStartCellGroup[i] + xCellGroupSize[i];
   if ( xUpsilonStack->cellGroupSize[i] <= cellSize[j] ) {
      left = xStartCellGroup[i] - 1;
      right = xStartCellGroup[i] + xCellGroupSize[i];
      while ( left < right ) {
         while ( zeroArray[++left]) != m )
            ;
         while ( zeroArray[--right]) == m )
            ;
         if ( left < right ) {
            EXCHANGE( xCellList[left], xCellList[right], temp)
            EXCHANGE( xInvCellList[xCellList[left]],
                      xInvCellList[xCellList[right]], temp)
         }
      xStartNewCellGroup = left;
      }
   }
   else {
      xStartNewCellGroup = last;
      for ( r = startCell[j] ; r < startCell[j] + cellSize[j] ; ++r ) {
         t = LambdaCellNumber[pointList[r]];
         if ( zeroArray[t] == m ) {
            zeroArray[t] = UNDEFINED;
            --xStartNewCellGroup;
            EXCHANGE( xCellList[t], xCellList[xStartNewCellGroup], temp)
            EXCHANGE( xInvCellList[xCellList[t]],
                      xInvCellList[xCellList[xStartNewCellGroup]], temp)
         }
      }
   }

   ++xUpsilonStack->height;
   xUpsilonStack->totalGroupSize[xUpsilonStack->height] = 0;
   for ( r = xStartNewCellGroup ; r < last ; ++m ) {
      xCellGroupNumber[xCellList[r]] = xUpsilonStack->height;
      xUpsilonStack->totalGroupSize[xUpsilonStack->height] +=
         Lambda->cellSize[xCellList[r]];
   xStartCellGroup[xUpsilonStack->height] = xStartNewCellGroup;
   xUpsilonStack->parent[xUpsilonStack->height] = i;
   xCellGroupSize[xUpsilonStack->height] = last - xStartNewCellGroup;
   xCellGroupSize[i] -= (last - xStartNewCellGroup);
   xUpsilonStack->totalGroupSize[i] -=
      xUpsilonStack->totalGroupSize[xUpsilonStack->height]
   RESTORE_ZERO;
   split.oldCellSize = cellSize[cellToSplit];
   split.newCellSize = cellSize[UpsilonStack->height];
   return split;
#endif
}

#ifdef xxxxxx
/*-------------------------- deleteRefnListEntry --------------------------*/

static void deleteRefnListEntry(
   RefnListEntry *entryToDelete,
   Unsigned hashPosition,             /* hashTableSize+1 indicates unknown */
   RefnListEntry *prevHashListEntry)
{
   if ( hashPosition > hashTableSize ) {
      hashPosition = HASH( entryToDelete->i, entryToDelete->j);
      if ( hashTable[hashPosition] == entryToDelete )
         prevHashListEntry = NULL;
      else {
         prevHashListEntry = hashTable[hashPosition];
         while ( prevHashListEntry->hashLink != entryToDelete )
             prevHashListEntry = prevHashListEntry->hashLink;
      }
   }
   if ( prevHashListEntry )
      prevHashListEntry->hashLink = entryToDelete->hashLink;
   else
      hashTable[hashPosition] = entryToDelete->hashLink;
   if ( entryToDelete->last )
      entryToDelete->last->next = entryToDelete->next;
   else
      inUseListHeader = entryToDelete->next;
   if ( entryToDelete->next )
      entryToDelete->next->last = entryToDelete->last;
   entryToDelete->next = freeListHeader;
   freeListHeader = entryToDelete;
}


/*-------------------------- isUPartnStabReducible ------------------------*/

RefinementPriorityPair isOrbReducible(
   const RefinementFamily *family,        /* The refinement family mapping
                                             must be orbRefine; family parm[0]
                                             is the group. */
   const PartitionStack *const UpsilonStack)
{
   BOOLEAN cellWillSplit;
   Unsigned  i, j, m, groupNumber, hashPosition, newCellNumber, oldCellNumber,
             count;
   unsigned long minPriority, thisPriority;
   UnsignedS  *oldLevelAddr;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   PermGroup *G = family->familyParm_L[0].ptrParm;
   Unsigned   level = family->familyParm_L[1].intParm;
   UnsignedS  *orbNumberOfPt = G->orbNumberOfPt[level];
   UnsignedS  *const startOfOrbitNo = G->startOfOrbitNo[level];
   RefinementPriorityPair reducingRefn;
   RefnListEntry *refnList;
   RefnListEntry *p, *oldP, *position, *minPosition;

   /* Check that the refinement mapping really is pointStabRefn, as required,
      and that the group is one for which initializeOrbRefine has been
      called. */
   if ( family->refine != orbRefine )
      ERROR( "isOrbReducible", "Error: incorrect refinement mapping");
   for ( groupNumber = 0 ; groupNumber < refnData.groupCount &&
                           refnData.group[groupNumber] != G ;
                           ++groupNumber )
      ;
   if ( groupNumber >= refnData.groupCount )
      ERROR( "isOrbReducible", "Routine not initialized for group.")
   hashTable = refnData.hashTable[groupNumber];
   refnList = refnData.refnList[groupNumber];
   oldLevelAddr = &refnData.oldLevel[groupNumber];

   /* If this is a new level, we reconstruct the list of potential refinements
      from scratch.  */
   if ( level != *oldLevelAddr ) {

      /* Initialize data structures. */
      *oldLevelAddr = level;
      for ( i = 0 ; i < hashTableSize ; ++i )
         hashTable[i] = NULL;
      freeListHeader = &refnList[0];
      inUseListHeader = NULL;
      for ( i = 0 ; i < G->degree ; ++i)
         refnList[i].next = &refnList[i+1];
      refnList[G->degree].next = NULL;

   /* Process the i'th cell of the top partition for i = 1,2,...., finding all
      possible refinements. */
      for ( i = 1 ; i <= UpsilonStack->height ; ++i ) {

         /* First check if the i'th cell will split.  If not, proceed directly
            to the next cell. */
         for ( m = startCell[i]+1 , cellWillSplit = FALSE ;
               m < startCell[i] + cellSize[i] && !cellWillSplit ; ++m )
            if ( orbNumberOfPt[ pointList[m] ] !=
                 orbNumberOfPt[ pointList[m-1] ] )
               cellWillSplit = TRUE;
         if ( !cellWillSplit )
            continue;

         /* Now find all splittings of the i'th cell and insert them into the
            list in sorted order. */
         for ( m = startCell[i] ; m < startCell[i]+cellSize[i] ; ++m ) {
            j = orbNumberOfPt[pointList[m]];
            hashPosition = HASH( i, j);
            p = hashTable[hashPosition];
            while ( p && (p->i != i || p->j != j) )
               p = p->hashLink;
            if ( p )
               ++p->newCellSize;
            else {
               if ( !freeListHeader )
                  ERROR( "isOrbReducible",
                         "Refinement list exceeded bound (should not occur).")
               p = freeListHeader;
               freeListHeader = freeListHeader->next;
               p->next = inUseListHeader;
               if ( inUseListHeader )
                  inUseListHeader->last = p;
               p->last = NULL;
               inUseListHeader = p;
               p->hashLink = hashTable[hashPosition];
               hashTable[hashPosition] = p;
               p->i = i;
               p->j = j;
               p->newCellSize = 1;
            }
         }
      }
   }

   /* If this is not a new level, we merely fix up the old list.  The entries
      for the new cell must be created and those for its parent must be
      adjusted. */
   else {
      freeListHeader = refnData.freeListHeader[groupNumber];
      inUseListHeader = refnData.inUseListHeader[groupNumber];
      newCellNumber = UpsilonStack->height;
      oldCellNumber = UpsilonStack->parent[UpsilonStack->height];
      for ( m = startCell[newCellNumber] , cellWillSplit = FALSE ;
            m < startCell[newCellNumber] + cellSize[newCellNumber] ; ++m ) {
         if ( m > startCell[newCellNumber] &&
              orbNumberOfPt[pointList[m]] != orbNumberOfPt[pointList[m-1]] )
            cellWillSplit = TRUE;
         j = orbNumberOfPt[pointList[m]];
         hashPosition = HASH( oldCellNumber, j);
         p = hashTable[hashPosition];
         oldP = NULL;
         while ( p && (p->i != oldCellNumber || p->j != j) ) {
            oldP = p;
            p = p->hashLink;
         }
         if ( p ) {
            --p->newCellSize;
            if ( p->newCellSize == 0 )
               deleteRefnListEntry( p, hashPosition, oldP);
         }
      }
      if ( cellWillSplit )
         for ( m = startCell[newCellNumber] , cellWillSplit = FALSE ;
               m < startCell[newCellNumber] + cellSize[newCellNumber] ; ++m ) {
            hashPosition = HASH( newCellNumber, j);
            p = hashTable[hashPosition];
            while ( p && (p->i != newCellNumber || p->j != j) )
               p = p->hashLink;
            if ( p )
               ++p->newCellSize;
            else {
               if ( !freeListHeader )
                  ERROR( "isOrbReducible",
                         "Refinement list exceeded bound (should not occur).")
               p = freeListHeader;
               freeListHeader = freeListHeader->next;
               p->next = inUseListHeader;
               if ( inUseListHeader )
                  inUseListHeader->last = p;
               p->last = NULL;
               inUseListHeader = p;
               p->hashLink = hashTable[hashPosition];
               hashTable[hashPosition] = p;
               p->i = newCellNumber;
               p->j = j;
               p->newCellSize = 1;
            }
         }
   }

   /* Now we return a refinement of minimal priority.  While searching the
      list, we also check for refinements invalidated by previous splittings. */
   minPosition = inUseListHeader;
   minPriority = ULONG_MAX;
   count = 1;
   for ( position = inUseListHeader ; position && count < 100 ;
         position = position->next , ++count ) {
      while ( position && position->newCellSize == cellSize[position->i] ) {
         p = position;
         position = position->next;
         deleteRefnListEntry( p, hashTableSize+1, NULL);
      }
      if ( !position )
         break;
      if ( (thisPriority = (unsigned long) position->newCellSize +
           MIN( cellSize[position->i], SIZE_OF_ORBIT(position->j) )) <
           minPriority ) {
         minPriority = thisPriority;
         minPosition = position;
      }
   }
   if ( minPriority == ULONG_MAX )
      reducingRefn.priority = IRREDUCIBLE;
   else {
      reducingRefn.refn.family = family;
      reducingRefn.refn.refnParm[0].intParm = minPosition->i;
      reducingRefn.refn.refnParm[1].intParm = minPosition->j;
      reducingRefn.priority = thisPriority;
   }

   /* If this is the last call to isOrbReducible for this group (UpsilonStack
      has height degree-1), free memory and reinitialize. */
   if ( UpsilonStack->height == G->degree - 1 ) {
      freePtrArrayDegree( refnData.hashTable[groupNumber]);
      free( refnData.refnList[groupNumber]);
      refnData.group[groupNumber] = NULL;
      --trueGroupCount;
      if ( trueGroupCount == 0 )
         refnData.groupCount = 0;
   }

   refnData.freeListHeader[groupNumber] = freeListHeader;
   refnData.inUseListHeader[groupNumber] =inUseListHeader;
   return reducingRefn;
}


cstExtraRBase()
#endif
