/* File orbrefn.c.  Contains functions to apply refinements OOO_G (orbit
   refinements) and to check OOO_G-reducibility, as follows:

      orbRefine:          A refinement family based on orbit structure (OOO).

      isOrbReducible:     A function to check OOO-reducibility. */

#include <assert.h>
#include <stddef.h>

#include <stdlib.h>

#include "group.h"
#include "errmesg.h"
#include "partn.h"
#include "storage.h"

CHECK( orbref)

#define  SIZE_OF_ORBIT( j)  ( startOfOrbitNo[j+1] - startOfOrbitNo[j] )


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


/*-------------------------- initializeOrbRefine --------------------------*/

void initializeOrbRefine( PermGroup *G)
{
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
}


/*-------------------------- orbRefine ------------------------------------*/

/* The function implements the refinement family orbRefine (denoted
   OOO_G in the reference).  This family OOO_G consists of the elementary
   refinements OOO_{G,Psi,i,j}, where G is a permutation group, Psi is an
   ordered partition (which we always assume belongs to PsiStack), and i and
   j will be integers.  Application of OOO_{G,Psi,i,j} to the top partition
   UpsilonTop of UpsilonStack splits off from UpsilonTop_i those points in
   (Psi_j)^t, where t is in G and t maps fix(PsiTop) to fix(UpsilonTop).

   The family parameters are :          The last two parms below are not really
        familyParm[0].ptrParm: G        family parms; they must be filled in
        familyParm[1].intParm: level    in before each call. Note G^(level) =
        familyParm[3].ptrParm: tWord    G_fix(Psi_h).
   The refinement parameters are:
        refnParm[0].intParm:   i
        refnParm[1].intParm:   j

   Note that, instead of passing Psi explicity, we pass G as a family parm
   and level and t as (not true) family parms. */

SplitSize orbRefine(
   const RefinementParm familyParm[],
   const RefinementParm refnParm[],
   PartitionStack *const UpsilonStack)
{
   Unsigned        level = familyParm[1].intParm;
   THatWordType    *tWord = familyParm[2].ptrParm;
   PermGroup       *G = (PermGroup *) familyParm[0].ptrParm;
   Unsigned  i =  refnParm[0].intParm,
             j =  refnParm[1].intParm;
   Unsigned  left, right, currentPos, m, tWordLen, savePointLeft,
             savePointRight;
   register Unsigned  pt;
   register UnsignedS *tw0, *tw1, *tw2;
   UnsignedS *tw3, *tw4, *tw5, *tw6, *tw7;
   UnsignedS **p;
   SplitSize split;
   Unsigned  *const pointList = UpsilonStack->pointList,
             *const invPointList = UpsilonStack->invPointList,
             *const cellNumber = UpsilonStack->cellNumber,
             *const parent = UpsilonStack->parent,
             *const startCell = UpsilonStack->startCell,
             *const cellSize = UpsilonStack->cellSize;
   Unsigned  startNextCell = startCell[i] + cellSize[i];
   UnsignedS  *completeOrbit = G->completeOrbit[level],
              *orbNumberOfPt = G->orbNumberOfPt[level],
              *startOfOrbitNo = G->startOfOrbitNo[level];

   /* Compute the length of the word. */
   for ( tWordLen = 0 ; tWord->invWord[tWordLen] != NULL ; ++tWordLen )
      ;

   /* Here we start to split cell i of UpsilonTop. */
   if ( cellSize[i] <= SIZE_OF_ORBIT(j) ) {

      /* If cell i of UpsilonTop is smaller than cell j of G_{fix(Psi_h)},
         we traverse the points of cell i of UpsilonTop. */
      tw0 = tWord->invWord[0];
      tw1 = tWord->invWord[1];
      tw2 = tWord->invWord[2];
      tw3 = tWord->invWord[3];
      tw4 = tWord->invWord[4];
      tw5 = tWord->invWord[5];
      tw6 = tWord->invWord[6];
      tw7 = tWord->invWord[7];
      left = startCell[i]-1;
      right = startNextCell;
      savePointLeft = pointList[left];
      savePointRight = pointList[right];
      pointList[left] = 0;
      pointList[right] = G->degree + 1;
      orbNumberOfPt[0] = 0;
      orbNumberOfPt[G->degree+1] = j;
      switch( tWordLen ) {
         case 0:
            for( ; ; ) {
               do {
                  pt = pointList[++left];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = pointList[--right];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         case 1:
            for( ; ; ) {
               do {
                  pt = tw0[pointList[++left]];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw0[pointList[--right]];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         case 2:
            for( ; ; ) {
               do {
                  pt = tw1[tw0[pointList[++left]]];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw1[tw0[pointList[--right]]];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         case 3:
            for( ; ; ) {
               do {
                  pt = tw2[tw1[tw0[pointList[++left]]]];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw2[tw1[tw0[pointList[--right]]]];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         case 4:
            for( ; ; ) {
               do {
                  pt = tw2[tw1[tw0[pointList[++left]]]];
                  pt = tw3[pt];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw2[tw1[tw0[pointList[--right]]]];
                  pt = tw3[pt];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         case 5:
            for( ; ; ) {
               do {
                  pt = tw2[tw1[tw0[pointList[++left]]]];
                  pt = tw4[tw3[pt]];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw2[tw1[tw0[pointList[--right]]]];
                  pt = tw4[tw3[pt]];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         case 6:
            for( ; ; ) {
               do {
                  pt = tw2[tw1[tw0[pointList[++left]]]];
                  pt = tw5[tw4[tw3[pt]]];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw2[tw1[tw0[pointList[--right]]]];
                  pt = tw5[tw4[tw3[pt]]];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         case 7:
            for( ; ; ) {
               do {
                  pt = tw2[tw1[tw0[pointList[++left]]]];
                  pt = tw6[tw5[tw4[tw3[pt]]]];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw2[tw1[tw0[pointList[--right]]]];
                  pt = tw6[tw5[tw4[tw3[pt]]]];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         case 8:
            for( ; ; ) {
               do {
                  pt = tw2[tw1[tw0[pointList[++left]]]];
                  pt = tw6[tw5[tw4[tw3[pt]]]];
                  pt = tw7[pt];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw2[tw1[tw0[pointList[--right]]]];
                  pt = tw6[tw5[tw4[tw3[pt]]]];
                  pt = tw7[pt];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
         default:
            for( ; ; ) {
               do {
                  pt = tw2[tw1[tw0[pointList[++left]]]];
                  pt = tw6[tw5[tw4[tw3[pt]]]];
                  pt = tw7[pt];
                  for ( p = tWord->invWord+8 ; *p ; ++p )
                     pt = (*p)[pt];
               } while ( orbNumberOfPt[pt] != j );
               do {
                  pt = tw2[tw1[tw0[pointList[--right]]]];
                  pt = tw6[tw5[tw4[tw3[pt]]]];
                  pt = tw7[pt];
                  for ( p = tWord->invWord+8 ; *p ; ++p )
                     pt = (*p)[pt];
               } while ( orbNumberOfPt[pt] == j );
               if ( left < right ) {
                  pt = pointList[right];
                  pointList[right] = pointList[left];
                  pointList[left] = pt;
                  invPointList[pointList[right]] = right;
                  invPointList[pt] = left;
               }
               else
                  break;
            }
            ++right;
            break;
      }
      pointList[startCell[i]-1] = savePointLeft;
      pointList[startNextCell] = savePointRight;
   }
   else {

      /* If cell j of G_{fix(Psi_h)} is smaller, we traverse the points of
         G_{fix(Psi_h) = G^(level)}. */
      tw0 = tWord->revWord[0];
      tw1 = tWord->revWord[1];
      tw2 = tWord->revWord[2];
      tw3 = tWord->revWord[3];
      tw4 = tWord->revWord[4];
      tw5 = tWord->revWord[5];
      tw6 = tWord->revWord[6];
      tw7 = tWord->revWord[7];
      switch( tWordLen ) {
         case 0:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = completeOrbit[m];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         case 1:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw0[completeOrbit[m]];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         case 2:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw1[tw0[completeOrbit[m]]];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         case 3:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw2[tw1[tw0[completeOrbit[m]]]];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         case 4:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw2[tw1[tw0[completeOrbit[m]]]];
               pt = tw3[pt];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         case 5:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw2[tw1[tw0[completeOrbit[m]]]];
               pt = tw4[tw3[pt]];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         case 6:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw2[tw1[tw0[completeOrbit[m]]]];
               pt = tw5[tw4[tw3[pt]]];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         case 7:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw2[tw1[tw0[completeOrbit[m]]]];
               pt = tw6[tw5[tw4[tw3[pt]]]];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         case 8:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw2[tw1[tw0[completeOrbit[m]]]];
               pt = tw6[tw5[tw4[tw3[pt]]]];
               pt = tw7[pt];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
         default:
            for ( m = startOfOrbitNo[j] , right = startNextCell ;
                  m < startOfOrbitNo[j+1] ; ++m ) {
               pt = tw2[tw1[tw0[completeOrbit[m]]]];
               pt = tw6[tw5[tw4[tw3[pt]]]];
               pt = tw7[pt];
               for ( p = tWord->revWord+8 ; *p ; ++p )
                  pt = (*p)[pt];
               if ( cellNumber[pt] == i ) {
                  currentPos = invPointList[pt];
                  pointList[currentPos] = pointList[--right];
                  pointList[right] = pt;
                  invPointList[pt] = right;
                  invPointList[pointList[currentPos]] = currentPos;
               }
            }
            break;
      }
   }

   if ( right == startNextCell ) {

      /* If the refinement failed to split UpsilonTop_i, set return value and
         return to caller.  Note that, in this case, the changes made to
         UpsilonStack above are harmless. */
      split.oldCellSize = cellSize[i];
      split.newCellSize = 0;
      return split;
   }
   else {

      /* If the refinement did split UpsilonTop_i, we push the new refinement
         onto UpsilonStack before returning. */
      ++UpsilonStack->height;
      for ( m = right ; m < startNextCell ; ++m )
         cellNumber[pointList[m]] = UpsilonStack->height;
      startCell[UpsilonStack->height] = right;
      parent[UpsilonStack->height] = i;
      cellSize[UpsilonStack->height] = startNextCell - right;
      cellSize[i] -= cellSize[UpsilonStack->height];
      split.oldCellSize = cellSize[i];
      split.newCellSize = cellSize[UpsilonStack->height];
      return split;
   }
}

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


/*-------------------------- isOrbReducible -------------------------------*/

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
            j = orbNumberOfPt[pointList[m]];
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
