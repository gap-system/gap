/* File stcs.c. */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "group.h"
#include "groupio.h"
#include "enum.h"
#include "repimg.h"

#include "addsgen.h"
#include "cstborb.h"
#include "errmesg.h"
#include "essentia.h"
#include "factor.h"
#include "new.h"
#include "oldcopy.h"
#include "permgrp.h"
#include "permut.h"
#include "randschr.h"
#include "relator.h"
#include "storage.h"
#include "token.h"

CHECK( stcs)

extern Unsigned primeList[];

static BOOLEAN checkStabilizer(
   PermGroup *const G,
   const UnsignedS *const knownBase,       /* Null-terminated list, or null. */
   const Unsigned level,
   Unsigned *jPtr,
   Permutation **hPtr,
   Word **wPtr);

static BOOLEAN xCheckStabilizer(
   PermGroup *const G,
   const UnsignedS *const knownBase,       /* Null-terminated list, or null. */
   const Unsigned level,
   Unsigned *jPtr,
   Permutation **hPtr,
   Word **wPtr);

static void addStrongGeneratorNR(
   PermGroup *G,              /* Group to which strong gen is adjoined. */
   Permutation *newGen);      /* The new strong generator. It must move */

WordImagePair computeSchreierGen(
   const PermGroup *const G,
   const Unsigned level,
   const Unsigned point,
   const Permutation *const gen);

BOOLEAN reduce(
   const PermGroup *const G,
   const Unsigned level,
   Unsigned *const jPtr,
   WordImagePair *const whPtr);

void informNewRelator(
   const Relator *const newRel,
   Unsigned numberAdded);

void informSTCSSummary(
   const PermGroup *const G,
   const unsigned long numberOfRelators,
   const unsigned long totalRelatorLength,
   const Unsigned maxRelatorLength,
   const unsigned long numberSelected,
   const unsigned long totalSelectedLength);

void expandGenerators(
   PermGroup *const G,
   Unsigned maxExtraCosets);

unsigned long prodOrderBounded(
   const Permutation *const perm1,
   const Permutation *const perm2,
   const Unsigned bound);

extern GroupOptions options;
extern STCSOptions sOptions;
extern Unsigned relatorSelection[5];

Unsigned *nextCos, *prevCos, *ff, *bb, *equivCoset;
Unsigned freeCosHeader, firstCos;

Unsigned extraCosetsAtLevel;
Unsigned currentExtraCosets;

static unsigned long tableEntriesFilled;
static unsigned long totalTableEntries;

static unsigned long numberOfRelators = 0, totalRelatorLength = 0,
                numberSelected = 0, totalSelectedLength = 0;
static Unsigned maxRelatorLength = 0;



/*-------------------------- schreierToddCoxeterSims ----------------------*/

/* Main function for the Schreier-Todd-Coxeter-Sim function for constructing
   a base, strong generating set, and strong presentation for a permutation
   group.

   Note:  If G has relators initially, they will be assumed to be correct,
          and will be used.  However, in this case, it should already
          have inverse permutations. */

void schreierToddCoxeterSims(
   PermGroup *const G,
   const UnsignedS *const knownBase)       /* Null-terminated list, or null. */
{
   Unsigned level, i, j, k, pOrder, numberAdded;
   Unsigned degree = G->degree;
   Permutation *gen, *gen1;
   Permutation *h;
   Relator *r, *rel;
   char *svecOK = allocBooleanArrayBaseSize();
   Word *w;
   Relator *newRel;
   Word tempWord;

  /* If initialization is requested, perform initializations. */
  if ( sOptions.initialize ) {

     /* Allocate fields within G. */
     if ( G->base || G->basicOrbLen || G->basicOrbit || G->schreierVec )
        ERROR( "schreierToddCoxeterSims",
               "A group field that must be null initially was nonnull.")
     G->base = allocIntArrayBaseSize();
     G->basicOrbLen = allocIntArrayBaseSize();
     G->basicOrbit = (UnsignedS **) allocPtrArrayBaseSize();
     G->schreierVec = (Permutation ***) allocPtrArrayBaseSize();

      /* Allocate G->order and set G->order to 1.  */
      if ( !G->order ) {
         G->order = allocFactoredInt();
         G->order->noOfFactors = 0;
      }

      /* Delete identity generators from G if present.  Return immediately if
         G is the identity group. */
      removeIdentityGens( G);
      if ( !G->generator ) {     /* Should we allocate G->base, etc??? */
         G->baseSize = 0;
         return;
      }

      /* Adjoin an inverse image array to each permutation if absent. */
      adjoinGenInverses( G);

      /* Choose an initial segment of the base so that each generator moves
         some base point. */
      initializeBase( G);

      /* Fill in the level of each generator, and make each generator essential
         at its level and above. */
      for ( gen = G->generator ; gen ; gen = gen->next ) {
         gen->level = levelIn( G, gen);
         MAKE_NOT_ESSENTIAL_ALL( gen);
         for ( level = 1 ; level <= gen->level ; ++level )
            MAKE_ESSENTIAL_AT_LEVEL( gen, level);
      }

      /* Allocate the orbit length, basic orbit, and Schreier vector arrays.
         Set G->order (previously allocated) to the product of the basic orbit
         lengths. */
      G->order->noOfFactors = 0;
      for ( level = 1 ; level <= G->baseSize ; ++level ) {
         G->basicOrbLen[level] = 1;
         G->basicOrbit[level] = allocIntArrayDegree();
         G->schreierVec[level] = allocPtrArrayDegree();
      }
   }

   /* Expand the generator arrays if extra cosets are specified. */
   if ( sOptions.maxExtraCosets > 0 )
      expandGenerators( G, sOptions.maxExtraCosets);

   /* Adjoin inverse permutations, and construct (or reconstruct) the
      Schreier vectors, using all generators at each level. */
   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( !gen->invPermutation )
         adjoinInverseGen( G, gen);
   for ( level = 1 ; level <= G->baseSize ; ++level ) {
      constructBasicOrbit( G, level, "AllGensAtLevel" );
      svecOK[level] = TRUE;
   }

   /* Find max size for deduction queue, if not specified. */
   if ( sOptions.maxDeducQueueSize == UNKNOWN )
      sOptions.maxDeducQueueSize = 2 * degree + options.maxBaseSize + 
                                   sOptions.maxExtraCosets;

   /* Add generator order and product order relators to relator list. */
   tempWord.position = allocPtrArrayWordSize();
   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( gen->name[0] != '*' ) {
         pOrder = permOrder( gen);
         if ( pOrder > 2 && pOrder <= sOptions.genOrderLimit ) {
            tempWord.length = pOrder;
            for ( j = 1 ; j <= pOrder ; ++j )
               tempWord.position[j] = gen;
            newRel = addRelatorSortedFromWord( G, &tempWord, TRUE, TRUE);
            ++numberOfRelators;
            totalRelatorLength += newRel->length;
            ++numberSelected;
            totalSelectedLength += newRel->length;
            maxRelatorLength = MAX ( maxRelatorLength, newRel->length);
         }
      }
   if ( sOptions.prodOrderLimit >= 2 )   
      for ( gen = G->generator ; gen ; gen = gen->next )
         if ( gen->name[0] != '*' ) 
            for ( gen1 = gen->next ; gen1 ; gen1 = gen1->next )
               if ( (pOrder = prodOrderBounded( gen, gen1, 
                                              sOptions.prodOrderLimit)) > 0 ) {
                  tempWord.length = 2 * pOrder;
                  for ( j = 1 ; j <= pOrder ; ++j ) {
                     tempWord.position[2*j-1] = gen;
                     tempWord.position[2*j] = gen1;
                  }
                  newRel = addRelatorSortedFromWord( G, &tempWord, TRUE, TRUE);
                  ++numberOfRelators;
                  totalRelatorLength += newRel->length;
                  ++numberSelected;
                  totalSelectedLength += newRel->length;
                  maxRelatorLength = MAX ( maxRelatorLength, newRel->length);
               }
   freePtrArrayDegree( tempWord.position);

   /* If G has any relators, construct the appropriate occurencesOfGen
      lists. */
   for ( rel = G->relator ; rel ; rel = rel->next ) {
      numberAdded = addOccurencesForRelator( rel, MAX_INT);
      informNewRelator( rel, numberAdded);
   }

   /* If extra cosets are specified, construct the data structures required
      for extra cosets. */
   if ( sOptions.maxExtraCosets ) {
      nextCos = (Unsigned *) malloc( sizeof(Unsigned) *
                                     (sOptions.maxExtraCosets+2) );
      if ( !nextCos )
         ERROR( "schreierToddCoxeterSims", "Out of memory.")
      nextCos -= degree;
      prevCos = (Unsigned *) malloc( sizeof(Unsigned) *
                                     (sOptions.maxExtraCosets+2) );
      if ( !prevCos )
         ERROR( "schreierToddCoxeterSims", "Out of memory.")
      prevCos -= degree;
      ff = (Unsigned *) malloc( sizeof(Unsigned) *
                                     (sOptions.maxExtraCosets+2) );
      if ( !ff )
         ERROR( "schreierToddCoxeterSims", "Out of memory.")
      ff -= degree;
      bb = (Unsigned *) malloc( sizeof(Unsigned) *
                                     (sOptions.maxExtraCosets+2) );
      if ( !bb )
         ERROR( "schreierToddCoxeterSims", "Out of memory.")
      bb -= degree;
      equivCoset = (Unsigned *) malloc( sizeof(Unsigned) *
                                     (degree+sOptions.maxExtraCosets+2) );
      if ( !equivCoset )
         ERROR( "schreierToddCoxeterSims", "Out of memory.")

   }


   /* Now we repeatedly check whether
                 G^(level)_{alpha_level} = G(level+1)   (*)
      holds for level = G->baseSize,...,2,1.  However, (*) fails, we add a
      new strong generator, possibly a new base point, and adjust level.
      Note the procedure checkStabilizer returns TRUE if and only if (*)
      holds.  If (*) fails, it sets j, h, and w as follows:
          L denotes level,
          s is a Schreier generator of H^(L+1),
          h = s u_{L+1}(d_{L+1})^-1 u_{j-1}(d_{j-1})^-1 fixes a_1,...,a_{j-1},
          If j <= G->baseSize, a_j^h not in Delta_j.
          If j = G->baseSize+1, h != identity.
          w is h in word form. */
   level = G->baseSize;
   while ( level > 0 ) {
      if ( !svecOK[level] || sOptions.alwaysRebuildSvec )  {
         constructBasicOrbit( G, level, "AllGensAtLevel" );
         svecOK[level] = TRUE;
      }
      if ( (sOptions.maxExtraCosets == 0 &&
            checkStabilizer( G, knownBase, level, &j, &h, &w)) ||
            (sOptions.maxExtraCosets > 0 &&
            xCheckStabilizer( G, knownBase, level, &j, &h, &w)) )
         --level;
      else {
         if ( j == G->baseSize+1 ) {
            G->base[++G->baseSize] = pointMovedBy( h);
            G->basicOrbLen[G->baseSize] = 1;
            G->basicOrbit[G->baseSize] = allocIntArrayDegree();
            G->schreierVec[G->baseSize] = allocPtrArrayDegree();
         }
         assignGenName( G, h);
         addStrongGeneratorNR( G, h);
         adjoinInverseGen( G, h);
         w->position[++w->length] = h->invPermutation;
         newRel = addRelatorSortedFromWord( G, w, TRUE, TRUE);
         ++numberOfRelators;
         totalRelatorLength += newRel->length;
         ++numberSelected;
         totalSelectedLength += newRel->length;
         maxRelatorLength = MAX ( maxRelatorLength, newRel->length);
         numberAdded = addOccurencesForRelator( newRel, MAX_INT);
         informNewRelator( newRel, numberAdded);
         for ( k = level + 1 ; k <= j; ++k )
            svecOK[k] = FALSE;
         level = j;
      }
   }

   informSTCSSummary( G, numberOfRelators, totalRelatorLength,
                      maxRelatorLength, numberSelected, totalSelectedLength);

   /* Free pseudo-stack storage. */
   freeBooleanArrayBaseSize( svecOK);

}


/*-------------------------- checkStabilizer ------------------------------*/

/* This function checkStabilizer( G, knownBase, level, j, h, w) checks whether
          G^(level)_{alpha_level} = G(level+1).   (*)
   It returns true if (*) holds and false otherwise.  If (*) fails, it also
   sets j and returns a new permutation h and a new word w as follows.
          L denotes level,
          s is a Schreier generator of H^(L+1),
          h = s u_{L+1}(d_{L+1})^-1 u_{j-1}(d_{j-1})^-1 fixes a_1,...,a_{j-1},
          If j <= G->baseSize, a_j^h not in Delta_j.
          If j = G->baseSize+1, h != identity.
          w is h in word form.

  NOTE: INVERSE PERMUTATIONS MUST EXIST. */

static BOOLEAN checkStabilizer(
   PermGroup *const G,
   const UnsignedS *const knownBase,       /* Null-terminated list, or null. */
   const Unsigned level,
   Unsigned *jPtr,
   Permutation **hPtr,
   Word **wPtr)
{
   Unsigned i, j, pt, prevPt, curPointIndex, curPoint, img, numberAdded;
   Permutation *genHeader, *gen, *curGen;
   Unsigned basicOrbLen = G->basicOrbLen[level];
   UnsignedS *basicOrbit = G->basicOrbit[level];
   Permutation **schreierVec = G->schreierVec[level];
   static DeductionQueue *deductionQueue = NULL;
   WordImagePair wh;
   Deduction newDeduc, deduc;
   Relator *newRel;
   Unsigned selectionPriority = relatorSelection[2], relatorPriority;

   /* First time, allocate the deduction queue. */
   if ( !deductionQueue ) {
      deductionQueue = (DeductionQueue *) malloc( sizeof(DeductionQueue) );
      if ( !deductionQueue )
         ERROR( "checkStabilizer", "Out of memory.")
      deductionQueue->deduc = (Deduction *) malloc(
                             sOptions.maxDeducQueueSize * sizeof(Deduction));
      if ( !deductionQueue->deduc )
         ERROR( "checkStabilizer", "Out of memory.")
   }

   totalTableEntries = tableEntriesFilled = 0;
   wh.image = allocIntArrayDegree();

   /* Link the generators at specified level, using xNext. */
   genHeader = linkGensAtLevel( G, level);

   /* Flag all table entries at this level.  Also empty the deduction
      queue. */
   MAKE_EMPTY( deductionQueue);
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      for ( i = 1 ; i <= basicOrbLen ; ++i ) {
         pt = basicOrbit[i];
         gen->image[pt] |= HB;
         ++totalTableEntries;
      }

   /* Now put the subgroup generator entries for H^(level+1) in the table,
      and enqueue them. */
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      if ( gen->level > level ) {
         gen->image[basicOrbit[1]] = basicOrbit[1];
         ++tableEntriesFilled;
         newDeduc.pnt = newDeduc.img = basicOrbit[1];  newDeduc.gn = gen;
         ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
      }

   /* Now make those definitions corresponding to the Schreier vector. */
   for ( i = 2 ; i <= basicOrbLen ; ++i ) {
      pt = basicOrbit[i];
      gen = schreierVec[pt];
      prevPt = gen->invImage[pt] & NHB;
      gen->image[prevPt] = pt;
      ++tableEntriesFilled;
      newDeduc.pnt = prevPt;  newDeduc.img = pt;  newDeduc.gn = gen;
      ATTEMPT_ENQUEUE( deductionQueue, newDeduc);
      if ( gen->invImage[pt] & HB ) {
         gen->invImage[pt] = prevPt;
         ++tableEntriesFilled;
         newDeduc.pnt = pt;  newDeduc.img = prevPt;
         newDeduc.gn = gen->invPermutation;
         ATTEMPT_ENQUEUE( deductionQueue, newDeduc);
      }
   }

   /* Perform initial enumerations till deduction queue is empty. */
   while ( NOT_EMPTY(deductionQueue) ) {
      DEQUEUE( deductionQueue , deduc);
      findConsequences( deductionQueue, level, &deduc);
   }

   /* Now traverse the table, looking for negative entries. */
   curPointIndex = 1;
   curGen = genHeader;
   for ( curPointIndex = 1 ; curPointIndex <= basicOrbLen &&
         tableEntriesFilled < totalTableEntries ; ++curPointIndex ) {
      curPoint = basicOrbit[curPointIndex];
      for ( curGen = G->generator ; curGen &&
            tableEntriesFilled < totalTableEntries; curGen = curGen->xNext )
         if ( curGen->image[curPoint] & HB ) {
            curGen->image[curPoint] &= NHB;
            ++tableEntriesFilled;
            img = curGen->image[curPoint];
            wh = computeSchreierGen( G, level, curPoint, curGen);
            if ( !reduce( G, level, &j, &wh) ) {
               *jPtr = j;
               *hPtr = allocPermutation();
               (*hPtr)->degree = G->degree;
               (*hPtr)->image = wh.image;
               adjoinInvImage( *hPtr);
               *wPtr = allocWord();
               **wPtr = wh.word;
               resetTable( genHeader, basicOrbLen, basicOrbit);
               return FALSE;
            }
            freeIntArrayDegree( wh.image);
            newDeduc.pnt = curPoint;  newDeduc.img = img;  newDeduc.gn = curGen;
            ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
            if ( curGen->invPermutation != curGen || img != curPoint ) {
               curGen->invImage[img] &= NHB;
               ++tableEntriesFilled;
               newDeduc.pnt = img;  newDeduc.img = curPoint;
               newDeduc.gn = curGen->invPermutation;
               ATTEMPT_ENQUEUE( deductionQueue, newDeduc);
            }
            relatorPriority = relatorSelection[0] - relatorSelection[1] *
                       (wh.word.length + symmetricWordLength(&wh.word));
            if ( relatorPriority > selectionPriority ) {
               newRel = addRelatorSortedFromWord( G, &wh.word, TRUE, TRUE);
               selectionPriority += relatorSelection[4];
               ++numberSelected;
               totalSelectedLength += newRel->length;
               numberAdded = addOccurencesForRelator( newRel,
                                     relatorPriority - selectionPriority);
               informNewRelator( newRel, numberAdded);
               traceNewRelator( G, level, deductionQueue, newRel);
            }
            else
               selectionPriority -= relatorSelection[5];
            ++numberOfRelators;
            totalRelatorLength += wh.word.length;
            maxRelatorLength = MAX ( maxRelatorLength, wh.word.length);
            freePtrArrayWordSize( wh.word.position);
            while ( NOT_EMPTY(deductionQueue) ) {
               DEQUEUE( deductionQueue , deduc);
               findConsequences( deductionQueue, level, &deduc);
            }
         }
   }

   freeIntArrayDegree( wh.image);
   return TRUE;

}



/*-------------------------- xCheckStabilizer ------------------------------*/

/* This function xCheckStabilizer( G, knownBase, level, j, h, w) checks whether
          G^(level)_{alpha_level} = G(level+1).   (*)
   It returns true if (*) holds and false otherwise.  If (*) fails, it also
   sets j and returns a new permutation h and a new word w as follows.
          L denotes level,
          s is a Schreier generator of H^(L+1),
          h = s u_{L+1}(d_{L+1})^-1 u_{j-1}(d_{j-1})^-1 fixes a_1,...,a_{j-1},
          If j <= G->baseSize, a_j^h not in Delta_j.
          If j = G->baseSize+1, h != identity.
          w is h in word form.

  NOTE: INVERSE PERMUTATIONS MUST EXIST. */

static BOOLEAN xCheckStabilizer(
   PermGroup *const G,
   const UnsignedS *const knownBase,       /* Null-terminated list, or null. */
   const Unsigned level,
   Unsigned *jPtr,
   Permutation **hPtr,
   Word **wPtr)
{
   Unsigned i, j, pt, prevPt, curPointIndex, curPoint, img, numberAdded,
            newTableEntries;
   Unsigned degree = G->degree;
   Permutation *genHeader, *gen, *curGen;
   Unsigned basicOrbLen = G->basicOrbLen[level];
   UnsignedS *basicOrbit = G->basicOrbit[level];
   Permutation **schreierVec = G->schreierVec[level];
   static DeductionQueue *deductionQueue = NULL;
   static DefinitionList *defnList = NULL;
   Deduction newDeduc, deduc;
   Relator *newRel;
   Unsigned selectionPriority = relatorSelection[2], relatorPriority;

   /* First time, allocate the deduction queue and definition list. */
   if ( !deductionQueue ) {
      deductionQueue = (DeductionQueue *) malloc( sizeof(DeductionQueue) );
      if ( !deductionQueue )
         ERROR( "xCheckStabilizer", "Out of memory.")
      deductionQueue->deduc = (Deduction *) malloc(
                             sOptions.maxDeducQueueSize * sizeof(Deduction));
      if ( !deductionQueue->deduc )
         ERROR( "checkStabilizer", "Out of memory.")
      defnList = (DefinitionList *) malloc( sizeof(DefinitionList) );
      if ( !defnList )
         ERROR( "xCheckStabilizer", "Out of memory.")
      defnList->coset = (Unsigned *) malloc(
                             sOptions.maxExtraCosets * sizeof(Unsigned) );
      if ( !defnList->coset )
         ERROR( "xCheckStabilizer", "Out of memory.")
      defnList->image = (Unsigned *) malloc(
                             sOptions.maxExtraCosets * sizeof(Unsigned) );
      if ( !defnList->image )
         ERROR( "xCheckStabilizer", "Out of memory.")
      defnList->gen = (Permutation **) malloc(
                             sOptions.maxExtraCosets * sizeof(Permutation *) );
      if ( !defnList->gen )
         ERROR( "xCheckStabilizer", "Out of memory.")
   }

   totalTableEntries = tableEntriesFilled = 0;

   /* Compute number of extra cosets at this level. */
   extraCosetsAtLevel = (Unsigned) MIN( 
        (unsigned long) sOptions.maxExtraCosets,
        sOptions.percentExtraCosets * ((unsigned long) basicOrbLen + 99) / 100 );
   currentExtraCosets = 0;

   /* Link the generators at specified level, using xNext. */
   genHeader = linkGensAtLevel( G, level);

   /* Initialize data structures for extra cosets. */
   firstCos = 0;
   freeCosHeader = degree + 1;
   for ( i = 1 ; i <= degree ; ++i )
      equivCoset[i] = i;
   for ( i = degree + 1 ; i < degree + extraCosetsAtLevel ; ++i )
      nextCos[i] = i + 1;
   nextCos[degree+extraCosetsAtLevel] = 0;
   for ( i = degree + 1 ; i <= degree + extraCosetsAtLevel ; ++i )
      bb[i] = i;
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      for ( i = degree + 1 ; i <= degree + extraCosetsAtLevel ; ++i )
         gen->image[i] = HB;
   defnList->head = defnList->tail = defnList->size = 0;

   /* Flag all table entries at this level.  Also empty the deduction
      queue. */
   MAKE_EMPTY( deductionQueue);
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      for ( i = 1 ; i <= basicOrbLen ; ++i ) {
         pt = basicOrbit[i];
         gen->image[pt] |= HB;
         ++totalTableEntries;
      }

   /* Now put the subgroup generator entries for H^(level+1) in the table,
      and enqueue them. */
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      if ( gen->level > level ) {
         gen->image[basicOrbit[1]] = basicOrbit[1];
         ++tableEntriesFilled;
         newDeduc.pnt = newDeduc.img = basicOrbit[1];  newDeduc.gn = gen;
         ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
      }

   /* Now make those definitions corresponding to the Schreier vector. */
   for ( i = 2 ; i <= basicOrbLen ; ++i ) {
      pt = basicOrbit[i];
      gen = schreierVec[pt];
      prevPt = gen->invImage[pt] & NHB;
      gen->image[prevPt] = pt;
      ++tableEntriesFilled;
      newDeduc.pnt = prevPt;  newDeduc.img = pt;  newDeduc.gn = gen;
      ATTEMPT_ENQUEUE( deductionQueue, newDeduc);
      if ( gen->invImage[pt] & HB ) {
         gen->invImage[pt] = prevPt;
         ++tableEntriesFilled;
         newDeduc.pnt = pt;  newDeduc.img = prevPt;
         newDeduc.gn = gen->invPermutation;
         ATTEMPT_ENQUEUE( deductionQueue, newDeduc);
      }
   }

   /* Perform initial enumerations till deduction queue is empty. */
   while ( NOT_EMPTY(deductionQueue) ) {
      DEQUEUE( deductionQueue , deduc);
      xFindConsequences( G, deductionQueue, level, &deduc, genHeader);
   }

   /* Now traverse the table, looking for entries with high bit set. */
   curPointIndex = 1;
   curGen = genHeader;
   for ( curPointIndex = 1 ; curPointIndex <= basicOrbLen &&
         tableEntriesFilled < totalTableEntries ; ++curPointIndex ) {
      curPoint = basicOrbit[curPointIndex];
      for ( curGen = G->generator ; curGen &&
            tableEntriesFilled < totalTableEntries; curGen = curGen->xNext )
         if ( curGen->image[curPoint] & HB ) {
            if ( currentExtraCosets >= extraCosetsAtLevel ) {
               newTableEntries = forceCollapse( G, level, genHeader,
                                    deductionQueue, defnList, jPtr, hPtr, wPtr);
               if ( newTableEntries == UNKNOWN )
                  return FALSE;
               tableEntriesFilled += newTableEntries;
               relatorPriority = relatorSelection[0] - relatorSelection[1] *
                              ((*wPtr)->length + symmetricWordLength(*wPtr));
               if ( relatorPriority > selectionPriority ) {
                  newRel = addRelatorSortedFromWord( G, *wPtr, TRUE, TRUE);
                  selectionPriority += relatorSelection[4];
                  ++numberSelected;
                  totalSelectedLength += newRel->length;
                  numberAdded = addOccurencesForRelator( newRel,
                                        relatorPriority - selectionPriority);
                  informNewRelator( newRel, numberAdded);
                  traceNewRelator( G, level, deductionQueue, newRel);
               }
               else
                  selectionPriority -= relatorSelection[5];
               ++numberOfRelators;
               totalRelatorLength += (*wPtr)->length;
               maxRelatorLength = MAX ( maxRelatorLength, (*wPtr)->length);
               freePtrArrayWordSize( (*wPtr)->position);
               while ( NOT_EMPTY(deductionQueue) ) {
                  DEQUEUE( deductionQueue , deduc);
                  xFindConsequences( G, deductionQueue, level, &deduc, 
                                     genHeader);
               }
            }
            if ( !(curGen->image[curPoint] & HB) )
               continue;
            makeDefinition( curPoint, curGen, deductionQueue, defnList, 
                            genHeader);
            ++tableEntriesFilled;
            while ( NOT_EMPTY(deductionQueue) ) {
               DEQUEUE( deductionQueue , deduc);
               xFindConsequences( G, deductionQueue, level, &deduc, genHeader);
            }
         }
   }

   /* DEBUGGING -- REQUIRES FIXING, SINCE THERE SHOULD BE NO EXTRA COSETS HERE. */
   for ( j = firstCos ; j ; j = nextCos[j] )
      for ( gen = genHeader ; gen ; gen = gen->xNext )
         if ( gen->image[j] < degree )
            gen->invImage[gen->image[j]] = equivCoset[j];

   return TRUE;
}


/*-------------------------- computeSchreierGen ---------------------------*/

/* The function computeSchreierGen( G, level, point, gen) computes the
   Schreier generator  u_level(point) * gen * bar(u_level(point^gen))^-1
   for G^(level+1).  Here point must lie in Delta_level and gen must be
   a generator in G^(level).  The function returns a word (with newly
   allocated position field), representing the Schreier generator, and a new
   image array, representing the image of 1,2,...,n under the word.

   NOTE this function takes account of the fact that generating permutations
   may have the leftmost bit set as a flag. */

WordImagePair computeSchreierGen(
   const PermGroup *const G,
   const Unsigned level,
   const Unsigned point,
   const Permutation *const gen)
{
   WordImagePair sGen;
   Permutation **schreierVec = G->schreierVec[level];
   Unsigned basePt = G->base[level];
   Unsigned degree = G->degree;
   Unsigned i, j, pt;
   Unsigned *image;
   Permutation *temp;

   sGen.image = allocIntArrayDegree();
   sGen.word.position = allocPtrArrayWordSize();
   sGen.word.length = 0;

   for ( pt = point ; pt != basePt ; pt = schreierVec[pt]->invImage[pt] & NHB)
      sGen.word.position[++sGen.word.length] = schreierVec[pt];
   for ( i = 1 , j = sGen.word.length ; i < j ; ++i , --j )
      EXCHANGE( sGen.word.position[i], sGen.word.position[j] , temp);

   sGen.word.position[++sGen.word.length] = gen;

   for ( pt = gen->image[point] & NHB ; pt != basePt ;
                                  pt = schreierVec[pt]->invImage[pt] & NHB )
      sGen.word.position[++sGen.word.length] =
                        schreierVec[pt]->invPermutation;

   if ( sGen.word.length == 0 )
      for ( pt = 1 ; pt <= degree ; ++pt )
         sGen.image[pt] = pt;
   else {
      for ( pt = 1 ; pt <= degree ; ++pt )
         sGen.image[pt] = sGen.word.position[1]->image[pt] & NHB;
      /* SUBSTITUTE A MODIFIED VERSION OF REPLACE_BY-IMAGE HERE. */
      for ( i = 2 ; i <= sGen.word.length ; ++i ) {
         image = sGen.word.position[i]->image;
         for ( pt = 1 ; pt <= degree ; ++pt )
            sGen.image[pt] = image[sGen.image[pt]] & NHB;
      }
   }

   return sGen;
}


/*-------------------------- xComputeSchreierGen --------------------------*/

/* The function xComputeSchreierGen( G, level, point, gen) is identical to
   computeSchreierGen( G, level, point, gen) except that it takes account
   of the possibility of temporary cosets ( > degree) in the table. */

WordImagePair xComputeSchreierGen(
   const PermGroup *const G,
   const Unsigned level,
   const Unsigned point,
   const Permutation *const gen)
{
   WordImagePair sGen;
   Permutation **schreierVec = G->schreierVec[level];
   Unsigned basePt = G->base[level];
   Unsigned degree = G->degree;
   Unsigned i, j, pt;
   Unsigned *image;
   Permutation *temp;

   sGen.image = allocIntArrayDegree();
   sGen.word.position = allocPtrArrayWordSize();
   sGen.word.length = 0;

   for ( pt = point ; pt != basePt ; pt = equivCoset[schreierVec[pt]->invImage[pt] & NHB] )
      sGen.word.position[++sGen.word.length] = schreierVec[pt];
   for ( i = 1 , j = sGen.word.length ; i < j ; ++i , --j )
      EXCHANGE( sGen.word.position[i], sGen.word.position[j] , temp);

   sGen.word.position[++sGen.word.length] = gen;

   for ( pt = equivCoset[gen->image[point] & NHB] ; pt != basePt ;
                  pt = equivCoset[schreierVec[pt]->invImage[pt] & NHB] )
      sGen.word.position[++sGen.word.length] =
                        schreierVec[pt]->invPermutation;

   if ( sGen.word.length == 0 )
      for ( pt = 1 ; pt <= degree ; ++pt )
         sGen.image[pt] = pt;
   else {
      for ( pt = 1 ; pt <= degree ; ++pt )
         sGen.image[pt] = equivCoset[sGen.word.position[1]->image[pt] & NHB];
      /* SUBSTITUTE A MODIFIED VERSION OF REPLACE_BY-IMAGE HERE. */
      for ( i = 2 ; i <= sGen.word.length ; ++i ) {
         image = sGen.word.position[i]->image;
         for ( pt = 1 ; pt <= degree ; ++pt )
            sGen.image[pt] = equivCoset[image[sGen.image[pt]] & NHB];
      }
   }

   return sGen;
}


/*-------------------------- reduce ---------------------------------------*/

/* The function reduce( G, level, j, wh) takes a word-image pair representing
   an element of G^(level) and it modifies it by right-multiplying by
   u_{level+1}^-1(d_{level+1} ... u_{j-1}^-1(d_{level+1}) so that it fixes
   a_{level+1},...,a_{j-1} and either
        i)  j <= G->baseSize, and a_j^wh not in Delta_j.
       ii)  j == G->baseSize+1, and wh != 1.
      iii)  j == G->baseSize+1, and wh == 1.
   It returns false in cases (i) and (ii) and true in case (iii). */

BOOLEAN reduce(
   const PermGroup *const G,
   const Unsigned level,
   Unsigned *const jPtr,
   WordImagePair *const whPtr)
{
   Unsigned i, j, pt;
   register Unsigned *temp1, *temp2;
   Unsigned *temp3, *temp4, *image;

   for ( j = level+1 ; j <= G->baseSize ; ++j ) {
      pt = whPtr->image[G->base[j]];
      if ( !G->schreierVec[j][pt] ) {
         *jPtr = j;
         return FALSE;
      }
      for ( ; pt != G->base[j] ;
              pt = G->schreierVec[j][pt]->invImage[pt] & NHB) {
         whPtr->word.position[++whPtr->word.length] =
                            G->schreierVec[j][pt]->invPermutation;
         image = whPtr->word.position[whPtr->word.length]->image;
         for ( i = 1 ; i <= G->degree ; ++i )
            whPtr->image[i] = image[whPtr->image[i]] & NHB;
      }
   }

   *jPtr = G->baseSize + 1;
   for ( pt = 1 ; pt <= G->degree ; ++pt )
      if ( whPtr->image[pt] != pt )
         return FALSE;

   return TRUE;
}



/*-------------------------- xReduce --------------------------------------*/

/* The function xReduce( G, level, j, wh) is identical to 
   Reduce( G, level, j, wh) except that it takes account of the possibility
   of temporary cosets ( > degree) in the table.  */

BOOLEAN xReduce(
   const PermGroup *const G,
   const Unsigned level,
   Unsigned *const jPtr,
   WordImagePair *const whPtr)
{
   Unsigned i, j, pt;
   Unsigned *image;

   for ( j = level+1 ; j <= G->baseSize ; ++j ) {
      pt = whPtr->image[G->base[j]];
      if ( !G->schreierVec[j][pt] ) {
         *jPtr = j;
         return FALSE;
      }
      for ( ; pt != G->base[j] ;
              pt = equivCoset[G->schreierVec[j][pt]->invImage[pt] & NHB] ) {
         whPtr->word.position[++whPtr->word.length] =
                            G->schreierVec[j][pt]->invPermutation;
         image = whPtr->word.position[whPtr->word.length]->image;
         for ( i = 1 ; i <= G->degree ; ++i )
            whPtr->image[i] = equivCoset[image[whPtr->image[i]] & NHB];
      }
   }

   *jPtr = G->baseSize + 1;
   for ( pt = 1 ; pt <= G->degree ; ++pt )
      if ( whPtr->image[pt] != pt )
         return FALSE;

   return TRUE;
}


/*-------------------------- addStrongGeneratorNR -------------------------*/

/* This function may be used to adjoin a new strong generator to a
   permutation group WITHOUT reconstructing basic orbits.  Also, the
   essential fields are not modified in any way. */

void addStrongGeneratorNR(
   PermGroup *G,              /* Group to which strong gen is adjoined. */
   Permutation *newGen)       /* The new strong generator. It must move
                                 a base point (not checked). */
{
   Unsigned i;

   /* Append inverse image of new strong generator, if absent. */
   if ( !newGen->invImage )
      adjoinInvImage( newGen);

   /* Find level of new strong generator. */
   newGen->level = levelIn( G, newGen);

   /* Add the generator. */
   if ( G->generator )
      G->generator->last = newGen;
   newGen->last = NULL;
   newGen->next = G->generator;
   G->generator = newGen;

}



/*-------------------------- expandGenerators -----------------------------*/

void expandGenerators(
   PermGroup *const G,
   Unsigned extraCosets)
{
   Unsigned i;
   Unsigned *oldImage, *oldInvImage;
   Permutation *gen;

   for ( gen = G->generator ; gen ; gen = gen->next )
      gen->image[0] = gen->invImage[0] = 0;
   for ( gen = G->generator ; gen ; gen = gen->next ) {
      if ( gen->image[0] == 0 ) {
         oldImage = gen->image;
         gen->image = malloc( (G->degree+extraCosets+2) * sizeof(Unsigned));
         if ( !gen->image )
            ERROR( "expandGenerators", "Out of memory.")
         for ( i = 1 ; i <= G->degree ; ++i )
            gen->image[i] = oldImage[i];
         gen->image[0] = 1;
         if ( gen->invPermutation )
            gen->invPermutation->invImage = gen->image;
         freeIntArrayDegree( oldImage);
         oldInvImage = gen->invImage;
         if ( oldImage == oldInvImage )
           gen->invImage = gen->image;
         else {
            gen->invImage = malloc( 
                              (G->degree+extraCosets+2) * sizeof(Unsigned) );
            if ( !gen->invImage )
               ERROR( "expandGenerators", "Out of memory.")
            for ( i = 1 ; i <= G->degree ; ++i )
               gen->invImage[i] = oldInvImage[i];
            gen->invImage[0] = 1;
            freeIntArrayDegree( oldInvImage);
         }
         if ( gen->invPermutation )
            gen->invPermutation->image = gen->invImage;
      }
   }
}


/*-------------------------- prodOrderBounded -----------------------------*/

/* The function prodOrderBounded( perm1, perm2, bound) returns the order of 
   the product of permutations perm1 and perm2, provided this order is less 
   than or equal to bound, and returns 0 otherwise. */

unsigned long prodOrderBounded(
   const Permutation *const perm1,
   const Permutation *const perm2,
   const Unsigned bound)
{
   unsigned long  orbLen, multiplier, order;
   Unsigned   pt, basePt, imagePt;
   char  *found = allocBooleanArrayDegree();

   for (pt = 1; pt <= perm1->degree; ++pt)
      found[pt] = FALSE;

   for ( basePt = 1, order = 1; basePt <= perm1->degree; ++basePt )
      if ( ! found[basePt] )  {
         orbLen = 0;
         imagePt = basePt;
         do {
            ++orbLen;
            imagePt = perm2->image[perm1->image[imagePt]];
            found[imagePt] = TRUE;
         } while ( imagePt != basePt );
         if (order % orbLen != 0)
            if ( order <= ULONG_MAX / (multiplier = orbLen / gcd(order,orbLen)) ) {
               order *= multiplier;
               if ( order > bound ) {
                  freeBooleanArrayDegree( found);
                  return 0;
               }
            }
            else {
               freeBooleanArrayDegree( found);
               return 0;
            }
      }

   freeBooleanArrayDegree( found);
   return order;
}


/*-------------------------- informNewRelator -----------------------------*/

void informNewRelator(
   const Relator *const newRel,
   Unsigned numberAdded)
{
   Unsigned i, symLength;
   static BOOLEAN firstCall = TRUE;

   if ( firstCall ) {
      printf("\n");
      firstCall = FALSE;
   }
   printf( "New relator (level %u) (%u):  ", newRel->level, numberAdded);
   symLength = symmetricLength( newRel);
   if ( symLength == 1 )
      if ( newRel->rel[1]->name[0] == '*' )
         printf( "%s^%u", newRel->rel[1]->invPermutation->name, newRel->length);
      else
         printf( "%s^%u", newRel->rel[1]->name, newRel->length);
   else {
      if ( symLength < newRel->length )
         printf( "(" );
      for ( i = 1 ; i <= symLength ; ++i ) {
         if ( newRel->rel[i]->name[0] != '*' )
            printf( "%s", newRel->rel[i]->name);
         else
            printf( "%s%s", newRel->rel[i]->invPermutation->name, "^-1");
         if ( i < symLength )
            printf( "*");
      }
      if ( symLength < newRel->length )
         printf( ")^%u", newRel->length/symLength );
   }
   printf( "\n");
}


/*-------------------------- informSTCSSummary -----------------------------*/

void informSTCSSummary(
   const PermGroup *const G,
   const unsigned long numberOfRelators,
   const unsigned long totalRelatorLength,
   const Unsigned maxRelatorLength,
   const unsigned long numberSelected,
   const unsigned long totalSelectedLength)
{
   Unsigned i, intQuotient, decQuotient, numberOfGens, involGenCount;

   /* Print the group order. */
   printf( "\n\nSchreier-Todd-Coxeter-Sims procedure complete.");
   printf( "\nGroup %s has order ", G->name);
   if ( G->order->noOfFactors == 0 )
      printf( "%d", 1);
   else
      for ( i = 0 ; i < G->order->noOfFactors ; ++i ) {
         if ( i > 0 )
            printf( " * ");
         printf( "%u", G->order->prime[i]);
         if ( G->order->exponent[i] > 1 )
            printf( "^%u", G->order->exponent[i]);
      }
   printf( "\n");

   /* Print the number of generators. */
   numberOfGens = genCount( G, &involGenCount);
   printf( "\nNumber of generators: %u\n", numberOfGens);
   printf(   "Number involutory:    %u\n", involGenCount);

   /* Print the number of relators and total, maximum, and average relator
      length. */
   printf( "\nNumber of relators:   %lu\n", numberOfRelators);
   printf(   "Total relator length: %lu\n", totalRelatorLength);
   printf(   "Max relator length:   %u\n", maxRelatorLength);
   intQuotient  = (Unsigned)(totalRelatorLength / numberOfRelators);
   decQuotient = 10 * (totalRelatorLength - intQuotient * numberOfRelators);
   printf(   "Mean relator length:  %u.%1u\n", intQuotient,
             (unsigned)(decQuotient / numberOfRelators) );
   printf( "\nNumber selected:      %lu\n", numberSelected);
   printf(   "Total select length:  %lu\n", totalSelectedLength);
   intQuotient  = (Unsigned)(totalSelectedLength / numberSelected);
   decQuotient = 10 * (totalSelectedLength - intQuotient * numberSelected);
   printf(   "Mean select length:   %u.%1u\n", intQuotient,
             (unsigned)(decQuotient / numberSelected) );
}

