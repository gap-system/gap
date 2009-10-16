/* File ccent.c.  Contains functions centralizer and conjugatingElement, that
   may be used to compute centralizer and conjugacy of elements in permutation
   groups.  */

#include <stddef.h>
#include <stdlib.h>
#include <time.h>

#include "group.h"

#include "compcrep.h"
#include "compsg.h"
#include "cparstab.h"
#include "errmesg.h"
#include "inform.h"
#include "new.h"
#include "orbrefn.h"
#include "permut.h"
#include "randgrp.h"
#include "storage.h"

CHECK( ccent)

extern GroupOptions options;

/* Forward declarations of functions. */
static RefinementMapping centRefine;
static ReducChkFn isCentReducible;
static void initializeCentRefine( Permutation *e);
static Partition *cycleLengthPartn(
   const Permutation *const e,
   UnsignedS *const cycleLen,
   UnsignedS *const cycleStructure);
static Partition *multipleCycleLengthPartn(
   const Permutation *const ex[]);


/* The following functions are used to check the centralizer or conjugacy
   property.  Pointers to them are passed to computeSubgroup or 
   computeCosetRep. */

static const Permutation *ee, *ff;
static const PermGroup *EE;
static BOOLEAN longCycleFlag;
static UnsignedS *cycleLen, *cycleStructure;

static BOOLEAN centralizesE(
   const Permutation *const s)
{
   return checkConjugacy( ee, ee, s);
}

static BOOLEAN conjugatesEToF(
   const Permutation *const s)
{
   return checkConjugacy( ee, ff, s);
}

static BOOLEAN centralizesGroupE(
   const Permutation *const s)
{
   Permutation *gen;
   for ( gen = EE->generator ; gen ; gen = gen->next )
      if ( !checkConjugacy( gen, gen, s) )
         return FALSE;
   return TRUE;
}

   
extern UnsignedS (*chooseNextBasePoint)(
   const PermGroup *const G,
   const PartitionStack *const UpsilonStack);


static UnsignedS nextBasePointEltCent(
   const PermGroup *const G,
   const PartitionStack *const UpsilonStack)
{
   const Unsigned    degree = UpsilonStack->degree;
   const UnsignedS   *const cellNumber = UpsilonStack->cellNumber,
                     *const cellSize = UpsilonStack->cellSize;
   Unsigned alpha, pt, cSize, shortPriority;
   unsigned long priority, minPriority;

   alpha = 0;
   for ( pt = 1 ; pt <= degree ; ++pt )
      if ( (cSize = cellSize[cellNumber[pt]]) > 1 ) {
         if ( longCycleFlag )
            priority = 2000000000ul - (unsigned long) MIN(cycleLen[pt],1000) << 20 
                       + cSize;
         else
            if ( cycleLen[pt] == 1 ) 
               priority = cSize;
            else {
               shortPriority = 2;
               cSize >>= 1;
               while ( (cSize >>= 2) > 0 ) 
                  shortPriority <<= 1;
               shortPriority /= (cycleLen[pt] - 1);
               priority = (unsigned long) shortPriority + 1;
            }
         if ( alpha == 0 || priority < minPriority ) {
            alpha = pt;
            minPriority = priority;
         }
      }
   return alpha;
}                                                   



/*-------------------------- centralizer ----------------------------------*/

/* Function centralizer.  Returns a new permutation group representing the
   centralizer in a permutation group G of an element e. The algorithm is 
   based on Figure 9 in the paper "Permutation group algorithms based on 
   partitions" by the author.  */

#define familyParm familyParm_L

PermGroup *centralizer(
   PermGroup *const G,            /* The containing permutation group. */
   const Permutation *const e,    /* The point set to be stabilized. */
   PermGroup *const L,            /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Lambda.  (A null pointer
                                     designates a trivial group.) */
   const BOOLEAN noPartn,         /* If true, suppresses use of ordered 
                                     partition based on cycle size. */
   const BOOLEAN longCycleOption, /* Always choose next base point in longest
                                     cycle; however, at present, all cycles
                                     of length 5 or greater are treated as
                                     having the same length. */
   const BOOLEAN stdRBaseOption)  /* Use std base selection algorithm, ignoring
                                     cycle lengths. */
{
   RefinementFamily OOO_G, CCC_e, SSS_eCycle;
   RefinementFamily  *refnFamList[4];
   ReducChkFn  *reducChkList[4];
   SpecialRefinementDescriptor *specialRefinement[4];
   ExtraDomain *extra[1];
   Partition *eCyclePartn = NULL;
   Unsigned refnCount = 0;

   /* Orbit refinement (unless G is symmetric). */
   if ( ! IS_SYMMETRIC(G) ) {
      OOO_G.refine = orbRefine;
      OOO_G.familyParm[0].ptrParm = G;
      refnFamList[refnCount] = &OOO_G;
      reducChkList[refnCount] = isOrbReducible;
      specialRefinement[refnCount] = malloc( sizeof(SpecialRefinementDescriptor) );
      specialRefinement[refnCount]->refnType = 'O';
      specialRefinement[refnCount]->leftGroup = G;
      specialRefinement[refnCount]->rightGroup = G;
      initializeOrbRefine( G);
      ++refnCount;
   }

   /* Centralizer refinement. */
   CCC_e.refine = centRefine;
   CCC_e.familyParm[0].ptrParm = e;
   refnFamList[refnCount] = &CCC_e;
   reducChkList[refnCount] = isCentReducible;
   specialRefinement[refnCount] = NULL;
   initializeCentRefine( e);
   ee = e;
   ++refnCount;

   /* Cycle length partition refinement. */
   cycleLen = allocIntArrayDegree();
   cycleStructure = allocIntArrayDegree();
   eCyclePartn = cycleLengthPartn( e, cycleLen, cycleStructure);
   
   if ( !noPartn && eCyclePartn ) {
      SSS_eCycle.refine = partnStabRefine;
      SSS_eCycle.familyParm[0].ptrParm = (void *) eCyclePartn;
      refnFamList[refnCount] = &SSS_eCycle;
      reducChkList[refnCount] = isPartnStabReducible;
      specialRefinement[refnCount] = NULL;
      initializePartnStabRefn();
      ++refnCount;
   }

   /* Terminators. */
   refnFamList[refnCount] = NULL;
   reducChkList[refnCount] = NULL;
   specialRefinement[refnCount] = NULL;

   extra[0] = NULL;

   chooseNextBasePoint = ( stdRBaseOption ) ? NULL : nextBasePointEltCent;
   longCycleFlag = longCycleOption;

   return  computeSubgroup( G, centralizesE, refnFamList, reducChkList,
                            specialRefinement, extra, L);
}
#undef familyParm


/*-------------------------- conjugatingElement ---------------------------*/

/* Function conjugatingElement.  Returns a permutation in a given group G
   mapping a given permutation e (not necessarily in G) to another given
   permutation f, or returns NULL if e and f are not conjugate in G.  The 
   algorithm is based on Figure 9 in the paper "Permutation group algorithms 
   based on partitions" by the author. */

Permutation *conjugatingElement(
   PermGroup *const G,            /* The containing permutation group. */
   const Permutation *const e,    /* One of the elements. */
   const Permutation *const f,    /* The other element. */
   PermGroup *const L_L,          /* A (possibly trivial) known subgroup of the
                                     centralizer in G of e.  (A null pointer
                                     designates a trivial group.) */
   PermGroup *const L_R,          /* A (possibly trivial) known subgroup of the
                                     centralizer in G of f.  (A null pointer
                                     designates a trivial group.) */
   const BOOLEAN noPartn,         /* If true, suppresses use of ordered 
                                     partition based on cycle size. */
   const BOOLEAN longCycleOption, /* Always choose next base point in longest
                                     cycle; however, at present, all cycles
                                     of length 5 or greater are treated as
                                     having the same length. */
   const BOOLEAN stdRBaseOption)  /* Use std base selection algorithm, ignoring
                                     cycle lengths. */
{
   RefinementFamily OOO_G, CCC_ef, SSS_efCycle;
   RefinementFamily  *refnFamList[4];
   ReducChkFn  *reducChkList[4];
   SpecialRefinementDescriptor *specialRefinement[4];
   ExtraDomain *extra[1];
   Partition *eCyclePartn = NULL, *fCyclePartn = NULL;
   Unsigned refnCount = 0, i;
   UnsignedS *cycleLen1, *cycleStructure1;
   Permutation *y;

   /* Handle symmetric group using trivial algorithm.  Note this does not
      necessarily produce the lexicographically first conjugating 
      permutation. */
   if ( IS_SYMMETRIC(G) ) {
      cycleLen = allocIntArrayDegree();
      cycleStructure = allocIntArrayDegree();
      cycleLen1 = allocIntArrayDegree();
      cycleStructure1 = allocIntArrayDegree();
      eCyclePartn = cycleLengthPartn( e, cycleLen, cycleStructure);
      fCyclePartn = cycleLengthPartn( f, cycleLen1, cycleStructure1);
      y = newUndefinedPerm( G->degree);
      for ( i = 1 ; i <= G->degree && y ; ++i ) 
         if ( cycleLen[cycleStructure[i]] == cycleLen1[cycleStructure1[i]] )
            y->image[cycleStructure[i]] = cycleStructure1[i];
         else
            y = NULL;
      freeIntArrayDegree( cycleLen);
      freeIntArrayDegree( cycleStructure);
      freeIntArrayDegree( cycleLen1);
      freeIntArrayDegree( cycleStructure1);
      if ( eCyclePartn )
         deletePartition( eCyclePartn);
      if ( fCyclePartn )
         deletePartition( fCyclePartn);
      if ( y ) 
         adjoinInvImage( y);
      if ( options.inform )
         informCosetRep( y);
      return y;
   }
      
   /* Orbit refinement. */
   OOO_G.refine = orbRefine;
   OOO_G.familyParm_L[0].ptrParm = G;
   OOO_G.familyParm_R[0].ptrParm = G;
   refnFamList[refnCount] = &OOO_G;
   reducChkList[refnCount] = isOrbReducible;
   specialRefinement[refnCount] = malloc( sizeof(SpecialRefinementDescriptor) );
   specialRefinement[refnCount]->refnType = 'O';
   specialRefinement[refnCount]->leftGroup = G;
   specialRefinement[refnCount]->rightGroup = G;
   initializeOrbRefine( G);
   ++refnCount;

   /* Centralizer refinement. */
   CCC_ef.refine = centRefine;
   CCC_ef.familyParm_L[0].ptrParm = e;
   CCC_ef.familyParm_R[0].ptrParm = f;
   refnFamList[refnCount] = &CCC_ef;
   reducChkList[refnCount] = isCentReducible;
   specialRefinement[refnCount] = NULL;
   initializeCentRefine( e);
   ee = e;
   ff = f;
   ++refnCount;

   /* Cycle length partition refinement. */
   cycleLen = allocIntArrayDegree();
   cycleStructure = allocIntArrayDegree();
   cycleLen1 = allocIntArrayDegree();
   cycleStructure1 = allocIntArrayDegree();
   eCyclePartn = cycleLengthPartn( e, cycleLen, cycleStructure);
   fCyclePartn = cycleLengthPartn( f, cycleLen1, cycleStructure1);

   /* If cycle structure is not the same, elements are not conjugate, so
      return immediately. */
   for ( i = 1 ; i <= G->degree ; ++i )
      if ( cycleLen[cycleStructure[i]] != cycleLen1[cycleStructure1[i]] ) {
         freeIntArrayDegree( cycleLen);
         freeIntArrayDegree( cycleStructure);
         freeIntArrayDegree( cycleLen1);
         freeIntArrayDegree( cycleStructure1);
         if ( eCyclePartn )
            deletePartition( eCyclePartn);
         if ( fCyclePartn )
            deletePartition( fCyclePartn);
         if ( options.inform )
            informCosetRep( NULL);
         return NULL;
      }
   /* Continue with cycle length partition refinement. */         
   if ( !noPartn && eCyclePartn ) {
      SSS_efCycle.refine = partnStabRefine;
      SSS_efCycle.familyParm_L[0].ptrParm = (void *) eCyclePartn;
      SSS_efCycle.familyParm_R[0].ptrParm = (void *) fCyclePartn;
      refnFamList[refnCount] = &SSS_efCycle;
      reducChkList[refnCount] = isPartnStabReducible;
      specialRefinement[refnCount] = NULL;
      initializePartnStabRefn();
      ++refnCount;
   }

   /* Terminators. */
   refnFamList[refnCount] = NULL;
   reducChkList[refnCount] = NULL;
   specialRefinement[refnCount] = NULL;

   extra[0] = NULL;

   chooseNextBasePoint = ( stdRBaseOption ) ? NULL : nextBasePointEltCent;
   longCycleFlag = longCycleOption;

   return  computeCosetRep( G, conjugatesEToF, refnFamList, reducChkList,
                            specialRefinement, extra, L_L, L_R);
}


/*-------------------------- groupCentralizer -----------------------------*/

/* Function groupCentralizer.   Returns a new permutation group representing 
   the centralizer in a permutation group G of another permutation group E.
   The algorithm is based on Figure 9 in the paper "Permutation group algorithms 
   based on partitions" by the author.  */

#define familyParm familyParm_L

PermGroup *groupCentralizer(
   PermGroup *const G,            /* The containing permutation group. */
   const PermGroup *const E,      /* The point set to be stabilized. */
   PermGroup *const L,            /* A (possibly trivial) known subgroup of the
                                     stabilizer in G of Lambda.  (A null pointer
                                     designates a trivial group.) */
   const Unsigned centPartnCount,  
   const Unsigned centGenCount)
{
   RefinementFamily OOO_G, CCC_e[17], SSS_eCycle;
   RefinementFamily  *refnFamList[20];
   ReducChkFn  *reducChkList[20];
   SpecialRefinementDescriptor *specialRefinement[20];
   ExtraDomain *extra[1];
   Partition *eCyclePartn = NULL;
   Unsigned i;
   unsigned long seed = 47;
   Permutation *e, *ex[20];
   Unsigned refnCount = 0;

   /* Orbit refinement (unless G is symmetric). */
   if ( ! IS_SYMMETRIC(G) ) {
      OOO_G.refine = orbRefine;
      OOO_G.familyParm[0].ptrParm = G;
      refnFamList[refnCount] = &OOO_G;
      reducChkList[refnCount] = isOrbReducible;
      specialRefinement[refnCount] = malloc( sizeof(SpecialRefinementDescriptor) );
      specialRefinement[refnCount]->refnType = 'O';
      specialRefinement[refnCount]->leftGroup = G;
      specialRefinement[refnCount]->rightGroup = G;
      initializeOrbRefine( G);
      ++refnCount;
   }

   initializeSeed( seed);
   for ( i = 1 ; i <= MAX(centGenCount,centPartnCount) ; ++i ) {
      e = randGroupPerm( E, 1);
      if ( i <= centGenCount ) {
         CCC_e[refnCount].refine = centRefine;
         CCC_e[refnCount].familyParm[0].ptrParm = e;
         refnFamList[refnCount] = &CCC_e[refnCount];
         reducChkList[refnCount] = isCentReducible;
         specialRefinement[refnCount] = NULL;
         initializeCentRefine( e);
         ++refnCount;
      }
      if ( i <= centPartnCount )
         ex[i] = e;
   }

   eCyclePartn = NULL;
   if ( centPartnCount > 0 ) {
      ex[centPartnCount+1] = NULL;
      eCyclePartn = multipleCycleLengthPartn( ex);
   }
   else
      eCyclePartn = NULL;

   if ( eCyclePartn ) {
      SSS_eCycle.refine = partnStabRefine;
      SSS_eCycle.familyParm[0].ptrParm = (void *) eCyclePartn;
      refnFamList[refnCount] = &SSS_eCycle;
      reducChkList[refnCount] = isPartnStabReducible;
      specialRefinement[refnCount] = NULL;
      initializePartnStabRefn();
      ++refnCount;
   }

   /* Terminators. */
   refnFamList[refnCount] = NULL;
   reducChkList[refnCount] = NULL;
   specialRefinement[refnCount] = NULL;

   extra[0] = NULL;

   EE = E;

   return  computeSubgroup( G, centralizesGroupE, refnFamList, reducChkList,
                            specialRefinement, extra, L);
}
#undef familyParm



/*------------------------------------------------------------------------*/

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
   Unsigned elementCount;
   Permutation *element[17];
   RefnListEntry **hashTable[17];
   RefnListEntry *refnList[17];
   RefnListEntry *freeListHeader[17];
   RefnListEntry *inUseListHeader[17];
} refnData = {0};

static Unsigned trueElementCount, hashTableSize;
static RefnListEntry **hashTable, *freeListHeader, *inUseListHeader;

static UnsignedS *pt = NULL, *freq = NULL;



/*-------------------------- initializeCentRefine -------------------------*/

static void initializeCentRefine( Permutation *e)
{
   int i;

   /* Compute hash table size. */
   if ( refnData.elementCount == 0 ) {
      hashTableSize = e->degree;
      while ( hashTableSize > 11 &&
              (hashTableSize % 2 == 0 || hashTableSize % 3 == 0 ||
              hashTableSize % 5 == 0 || hashTableSize % 7 == 0) )
         --hashTableSize;
   }

   if ( refnData.elementCount < 9) {
      refnData.element[refnData.elementCount] = e;
      refnData.hashTable[refnData.elementCount] = allocPtrArrayDegree();
      refnData.refnList[refnData.elementCount] =
                    malloc( e->degree * (sizeof(RefnListEntry)+2) );
      if ( !refnData.refnList[refnData.elementCount] )
         ERROR( "initializeCentRefine", "Memory allocation error.")
      ++refnData.elementCount;
      trueElementCount = refnData.elementCount;
   }
   else
      ERROR( "initializeCentRefine", "Centralizer refinement limited to ten elements.")

   /* Alloc (outer level) freq and pt, and nitialize array freq. */
   pt = allocIntArrayDegree();
   freq = allocIntArrayDegree();
   for ( i = 1 ; i <= e->degree ; ++i )
      freq[i] = 0;
}


/*-------------------------- centRefine -----------------------------------*/

/* This function implements the refinement family CCC_e.  This family consists 
   of the elementary refinements ccC_{e,i,j}, where e fixed.  (It is the 
   element to be stabilized) and where 1 <= i, j <= degree.  Application of 
   ccC_sSS_{e,i,j} to UpsilonStack splits off from UpsilonTop the intersection 
   of the i'th cell of UpsilonTop and the j'th cell of UpsilonTop^e and pushes 
   the resulting partition onto UpsilonStack, unless sSS_{e,i,j} acts
   trivially on UpsilonTop, in which case UpsilonStack remains unchanged.

   The family parameter is:
         familyParm[0].ptrParm:  e      
   The refinement parameters are:
         refnParm[0].intParm:    i
         refnParm[1].intParm:    j.
*/


static SplitSize centRefine(
   const RefinementParm familyParm[],      /* Family parm: e. */
   const RefinementParm refnParm[],        /* Refinement parms: i, j. */
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
{
   const Permutation *const e = familyParm[0].ptrParm;
   const Unsigned cellToSplit = refnParm[0].intParm,
                  otherCell = refnParm[1].intParm;
   Unsigned  m, last, i, j, temp, startNewCell,
             inNewCellCount = 0,
             outNewCellCount = 0;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const invPointList = UpsilonStack->invPointList,
              *const cellNumber = UpsilonStack->cellNumber,
              *const parent = UpsilonStack->parent,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   SplitSize  split;

   /* First check if the refinement acts nontrivially on UpsilonTop. If not
      return immediately. */
   for ( m = startCell[cellToSplit] , last = m + cellSize[cellToSplit] ;
         m < last && (inNewCellCount == 0 || outNewCellCount == 0) ; ++m )
      if ( cellNumber[e->invImage[pointList[m]]] == otherCell )
         ++inNewCellCount;
      else
         ++outNewCellCount;
   if ( inNewCellCount == 0 || outNewCellCount == 0 ) {
      split.oldCellSize = cellSize[cellToSplit];
      split.newCellSize = 0;
      return split;
   }

   /* Now split cell cellToSplit of UpsilonTop.  A variation of the splitting
      algorithm used in quicksort is applied. */
   if ( cellSize[cellToSplit] <= cellSize[otherCell] ) {
      i = startCell[cellToSplit]-1;
      j = last;
      while ( i < j ) {
         while ( cellNumber[e->invImage[pointList[++i]]] != otherCell )
            ;
         while ( cellNumber[e->invImage[pointList[--j]]] == otherCell )
            ;
         if ( i < j ) {
            EXCHANGE( pointList[i], pointList[j], temp)
            EXCHANGE( invPointList[pointList[i]], invPointList[pointList[j]], 
                      temp)
         }
      }
      startNewCell = i;
   }
   else {
      startNewCell = startCell[cellToSplit] + cellSize[cellToSplit];
      for ( i = startCell[otherCell] , last = i + cellSize[otherCell] ;
            i < last ; ++i )
         if ( cellNumber[e->image[pointList[i]]] == cellToSplit ) {
            --startNewCell;
            m = invPointList[e->image[pointList[i]]];
            EXCHANGE( pointList[m], pointList[startNewCell], temp);
            EXCHANGE( invPointList[pointList[m]], invPointList[pointList[startNewCell]],
                      temp);
         }
   }
         
   ++UpsilonStack->height;
   for ( m = startNewCell , last = startCell[cellToSplit] + 
         cellSize[cellToSplit] ; m < last ; ++m )
      cellNumber[pointList[m]] = UpsilonStack->height;
   startCell[UpsilonStack->height] = startNewCell;
   parent[UpsilonStack->height] = cellToSplit;
   cellSize[UpsilonStack->height] = last - startNewCell;
   cellSize[cellToSplit] -= (last - startNewCell);
   split.oldCellSize = cellSize[cellToSplit];
   split.newCellSize = cellSize[UpsilonStack->height];
   return split;
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


/*-------------------------- isCentReducible ------------------------------*/

static RefinementPriorityPair isCentReducible(
   const RefinementFamily *family,        /* The refinement family mapping
                                             must be centRefine; family parm[0]
                                             is the centralizing element. */
   const PartitionStack *const UpsilonStack)
{
   BOOLEAN cellWillSplit;
   Unsigned  i, j, m, elementNumber, hashPosition, newCellNumber, oldCellNumber,
             count, splittingCell, cSize, temp, previousJ;
   unsigned long minPriority, thisPriority;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const cellNumber = UpsilonStack->cellNumber,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   Permutation *e = family->familyParm_L[0].ptrParm;
   RefinementPriorityPair reducingRefn;
   RefnListEntry *refnList;
   RefnListEntry *p, *oldP, *position, *minPosition;

   /* Check that the refinement mapping really is centRefine, as required,
      and that the element is one for which initializeCentRefine has been
      called. */
   if ( family->refine != centRefine )
      ERROR( "isCentReducible", "Error: incorrect refinement mapping");
   for ( elementNumber = 0 ; elementNumber < refnData.elementCount &&
                           refnData.element[elementNumber] != e ;
                           ++elementNumber )
      ;
   if ( elementNumber >= refnData.elementCount )
      ERROR( "isCentReducible", "Routine not initialized for element.")
   hashTable = refnData.hashTable[elementNumber];
   refnList = refnData.refnList[elementNumber];

   /* If this is the first call (UpsilonStack has height 1), we create a new
      empty refinement list. */
   if ( UpsilonStack->height == 1) {
      for ( i = 0 ; i < hashTableSize ; ++i )
         hashTable[i] = NULL;
      freeListHeader = &refnList[0];
      inUseListHeader = NULL;
      for ( i = 0 ; i < e->degree ; ++i)
         refnList[i].next = &refnList[i+1];
      refnList[e->degree].next = NULL;
   }

   /* If this is not a new level, we merely fix up the old list.  The entries
      for the new cell must be created and those for its parent must be
      adjusted. */
   else {
      freeListHeader = refnData.freeListHeader[elementNumber];
      inUseListHeader = refnData.inUseListHeader[elementNumber];
      newCellNumber = UpsilonStack->height;
      oldCellNumber = UpsilonStack->parent[UpsilonStack->height];
      
      /* First we make adjustments corresponding to splitting the new
         partition using the old. */
      for ( m = startCell[newCellNumber] , cellWillSplit = FALSE , previousJ = 0 ;
            m < startCell[newCellNumber] + cellSize[newCellNumber] ; ++m ) {
         j = cellNumber[e->invImage[pointList[m]]];
         if ( j == newCellNumber )
            j = oldCellNumber;
         if ( previousJ != 0 && previousJ != j )
            cellWillSplit = TRUE;
         previousJ = j;
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
         for ( m = startCell[newCellNumber] ; m < startCell[newCellNumber] + 
               cellSize[newCellNumber] ; ++m ) {
            j = cellNumber[e->invImage[pointList[m]]];
            if ( j == newCellNumber )
               j = oldCellNumber;
            hashPosition = HASH( newCellNumber, j);
            p = hashTable[hashPosition];
            while ( p && (p->i != newCellNumber || p->j != j) )
               p = p->hashLink;
            if ( p )
               ++p->newCellSize;
            else {
               if ( !freeListHeader )
                  ERROR( "isCentReducible",
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

      /* Now we make adjustments corresponding to changing the second partition
         from the old to the new. */
      cSize = 0;
      for ( m = startCell[newCellNumber] ; m < startCell[newCellNumber] + 
            cellSize[newCellNumber] ; ++m ) {
         pt[++cSize] = temp = e->image[pointList[m]];
         ++freq[cellNumber[temp]];   /* MUST BE ZERO INITIALLY. */
      }
      for ( m = 1 ; m <= cSize ; ++m ) {
         splittingCell = cellNumber[pt[m]];
         if ( freq[splittingCell] > 0 && freq[splittingCell] < 
              cellSize[splittingCell] ) {             /* i.e, cell splits */
            /* Add entry that cell newCellNumber splits cell splittingCell. */
            hashPosition = HASH( splittingCell, newCellNumber);
            p = hashTable[hashPosition];
            oldP = NULL;
            while ( p && (p->i != splittingCell || p->j != newCellNumber) ) {
               oldP = p;
               p = p->hashLink;
            }
            if ( !freeListHeader )
               ERROR( "isCentReducible",
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
            p->i = splittingCell;
            p->j = newCellNumber;
            p->newCellSize = freq[splittingCell];
            /* Check if cell oldCellNumber split cell splittingCell.  If so,
               adjust its count, and eliminate its entry if count reaches 0.
               If not, then it now must, so add it. */
            hashPosition = HASH( splittingCell, oldCellNumber);
            p = hashTable[hashPosition];
            oldP = NULL;
            while ( p && (p->i != splittingCell || p->j != oldCellNumber) ) {
               oldP = p;
               p = p->hashLink;
            }
            if ( p ) {
               p->newCellSize -= freq[splittingCell];
               if ( p->newCellSize == 0 )
                  deleteRefnListEntry( p, hashPosition, oldP);
            }
            else {
               if ( !freeListHeader )
                  ERROR( "isCentReducible",
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
               p->i = splittingCell;
               p->j = oldCellNumber;
               p->newCellSize = cellSize[splittingCell] - freq[splittingCell];
            }
         }
         freq[splittingCell] = 0;
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
           MIN( cellSize[position->i], cellSize[position->j] )) <
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

   /* If this is the last call to isOrbReducible for this element (UpsilonStack
      has height degree-1), free memory and reinitialize. */
   if ( UpsilonStack->height == e->degree - 1 ) {
      freePtrArrayDegree( refnData.hashTable[elementNumber]);
      free( refnData.refnList[elementNumber]);
      refnData.element[elementNumber] = NULL;
      --trueElementCount;
      if ( trueElementCount == 0 )
         refnData.elementCount = 0;
   }

   refnData.freeListHeader[elementNumber] = freeListHeader;
   refnData.inUseListHeader[elementNumber] =inUseListHeader;
   return reducingRefn;
}


/*-------------------------- cycleLengthPartn -----------------------------*/

/* This function returns a new partition in which each cell represents the
   points lying in cycles of a fixed size of a permutation e.  However,
   if the partition would have just one cell, no partition is created, and
   a null pointer is returned instead.  It also fills in an array
   cycleLen so as to make cycleLen[pt] the length of the cycle containing
   point, as well as an array cycleStructure which consists of the list of
   points sorted by cycle length, such that all points a fixed cycle appear
   together, in order that they appear in a cycle.  At the end, pointList 
   is such that the points appear in increasing cycle length. */

Partition *cycleLengthPartn(
   const Permutation *const e,
   UnsignedS *const cycleLen,
   UnsignedS *const cycleStructure)
{
   Unsigned i, j, pt, img, len, cellCount;
   const Unsigned degree = e->degree;
   UnsignedS *const sortedCycleLen = allocIntArrayDegree();
   UnsignedS *const freq = allocIntArrayDegree();
   UnsignedS *const pointList = allocIntArrayDegree();
   Partition *cPartn;
   char *found;

   /* For each point pt, set cycleLen[pt] to the length of the e-cycle
      containing pt. */
   for ( pt = 1 ; pt <= degree ; ++pt)
      cycleLen[pt] = 0;
   for ( pt = 1 ; pt <= degree ; ++pt )
      if ( cycleLen[pt] == 0 ) {
         for ( len = 1 , img = e->image[pt] ; img != pt ; 
                                              img = e->image[img] , ++len )
            ;
         for ( img = e->image[pt] ; img != pt ; img = e->image[img] )
            cycleLen[img] = len;
         cycleLen[pt] = len;
      }
   
   /* Now set pointList to a list of points sorted by cycle length. */
   for ( i = 0 ; i <= degree ; ++i )
      freq[i] = 0;
   for ( pt = 1 ; pt <= degree ; ++pt )
      ++freq[cycleLen[pt]];
   freq[0] = 0;
   for ( i = 1 ; i <= degree ; ++i )
      freq[i] += freq[i-1];
   for ( i = 1 ; i <= degree ; ++i ) {
      pointList[++freq[cycleLen[i]-1]] = i;   
      sortedCycleLen[freq[cycleLen[i]-1]] = cycleLen[i];
   }

   /* Now construct cycleStructure. */
   found = allocBooleanArrayDegree();
   for ( pt = 1 ; pt <= degree ; ++pt)
      found[pt] = FALSE;
   j = 0;
   for ( i = 1 ; i <= degree ; ++i )
      if ( !found[ pt=pointList[i] ] )  {
         img = pt;
         do {
            found[img] = TRUE;
            cycleStructure[++j] = img;
            img = e->image[img];
         } while ( img != pt );
      }
   freeBooleanArrayDegree( found);

   /* If there is only one cycle, free heap storage and return NULL> */
   if ( cycleLen[pointList[1]] == cycleLen[pointList[degree]] ) {
      freeIntArrayDegree( sortedCycleLen);
      freeIntArrayDegree( freq);
      freeIntArrayDegree( pointList);
      return NULL;
   }

   /* Otherwise construct the partition and return it. */
   else {
      cellCount = 0;
      cPartn = allocPartition();
      cPartn->degree = degree;
      cPartn->pointList = pointList;
      cPartn->invPointList = freq;       /* Just to reuse storage. */
      cPartn->cellNumber = cycleLen;     /* Just to reuse storage. */
      cPartn->startCell = allocIntArrayDegree();
      for ( i = 1 ; i <= degree ; ++i ) {
         cPartn->invPointList[cPartn->pointList[i]] = i;
         if ( i == 1 || sortedCycleLen[i] != sortedCycleLen[i-1] )
            cPartn->startCell[++cellCount] = i;
         cPartn->cellNumber[cPartn->pointList[i]] = cellCount;
      }
      cPartn->startCell[cellCount+1] = degree+1;
      freeIntArrayDegree( sortedCycleLen);
      return cPartn;
   }
}





/*-------------------------- multipleCycleLengthPartn ----------------------*/

/* This function returns a new partition in which each cell represents the
   points lying in cycles of a fixed size of each partition ex[1], ex[2], ...
   (list null-terminated).  However, if the partition would have just one cell, 
   no partition is created, and a null pointer is returned instead. */

Partition *multipleCycleLengthPartn(
   const Permutation *const ex[])
{
   Unsigned i, pt, img, len, cellCount, permNumber, OldNumberPreviousCell;
   const Unsigned degree = ex[1]->degree;
   UnsignedS *const cycleLen = allocIntArrayDegree();
   UnsignedS *const freq = allocIntArrayDegree();
   UnsignedS *pointList = allocIntArrayDegree();
   UnsignedS *newPointList = allocIntArrayDegree();
   UnsignedS *const cellNumber = allocIntArrayDegree();
   UnsignedS *temp;
   Partition *cPartn;

   for ( i = 1 ; i <= degree ; ++i ) {
      pointList[i] = i;
      cellNumber[i] = 1;
   }

   for ( permNumber = 1 ; ex[permNumber] ; ++permNumber ) {

      /* For each point pt, set cycleLen[pt] to the length of the ex[i]-cycle
         containing pt. */
      for ( pt = 1 ; pt <= degree ; ++pt)
         cycleLen[pt] = 0;
      for ( pt = 1 ; pt <= degree ; ++pt )
         if ( cycleLen[pt] == 0 ) {
            for ( len = 1 , img = ex[permNumber]->image[pt] ; img != pt ; 
                                     img = ex[permNumber]->image[img] , ++len )
               ;
            for ( img = ex[permNumber]->image[pt] ; img != pt ; 
                               img = ex[permNumber]->image[img] )
               cycleLen[img] = len;
            cycleLen[pt] = len;
         }
   
      /* Now we sort the points by cycle length, using a stable sort. */
      for ( i = 0 ; i <= degree ; ++i )
         freq[i] = 0;
      for ( pt = 1 ; pt <= degree ; ++pt )
         ++freq[cycleLen[pt]];
      freq[0] = 0;
      for ( i = 1 ; i <= degree ; ++i )
         freq[i] += freq[i-1];
      for ( i = 1 ; i <= degree ; ++i ) 
         newPointList[++freq[cycleLen[pointList[i]]-1]] = pointList[i];
      EXCHANGE( pointList, newPointList, temp);   

      /* Now compute cellNumber for the new partition. */
      OldNumberPreviousCell = cellNumber[pointList[1]];
      cellNumber[pointList[1]] = 1;
      for ( i = 2 ; i <= degree ; ++i ) {
         if ( cellNumber[pointList[i]] != OldNumberPreviousCell ||
                     cycleLen[pointList[i]] != cycleLen[pointList[i-1]] ) {
             OldNumberPreviousCell = cellNumber[pointList[i]];
             cellNumber[pointList[i]] = 1 + cellNumber[pointList[i-1]];
         }
         else {
             OldNumberPreviousCell = cellNumber[pointList[i]];
             cellNumber[pointList[i]] = cellNumber[pointList[i-1]];
         }
      }
   }

   /* If there is only one cycle, free heap storage and return NULL> */
   if ( cellNumber[pointList[degree]] == 1 ) {
      freeIntArrayDegree( cycleLen);
      freeIntArrayDegree( freq);
      freeIntArrayDegree( pointList);
      freeIntArrayDegree( newPointList);
      freeIntArrayDegree( cellNumber);
      return NULL;
   }

   /* Otherwise construct the partition and return it. */
   else {
      cellCount = 0;
      cPartn = allocPartition();
      cPartn->degree = degree;
      cPartn->pointList = pointList;
      cPartn->cellNumber = cellNumber;
      cPartn->invPointList = freq;       /* Just to reuse storage. */
      cPartn->startCell = newPointList;  /* Just to reuse space. */
      for ( i = 1 ; i <= degree ; ++i ) {
         cPartn->invPointList[cPartn->pointList[i]] = i;
         if ( i == 1 || cellNumber[pointList[i]] != cellNumber[pointList[i-1]] )
            cPartn->startCell[++cellCount] = i;
      }
      cPartn->startCell[cellCount+1] = degree+1;
      freeIntArrayDegree( cycleLen);
      return cPartn;
   }
}
