/* File relator.c.  Contains miscellaneous functions for manipulating sets of
   relators. */

#include <stdlib.h>
#include <stdio.h>

#include "group.h"
#include "enum.h"

#include "errmesg.h"
#include "new.h"
#include "permut.h"
#include "stcs.h"
#include "storage.h"

CHECK( relato)

extern GroupOptions options;
extern STCSOptions sOptions;
extern Unsigned shiftSelection[11];
extern Unsigned shiftPriority[11];

extern Unsigned *nextCos, *prevCos, *ff, *bb, *equivCoset;
extern Unsigned freeCosHeader, firstCos;

extern Unsigned extraCosetsAtLevel;
extern Unsigned currentExtraCosets;

BOOLEAN verifyCosetList(
   Unsigned degree);
BOOLEAN onFreeList(
   Unsigned coset);
static callCount = 0;   /*DEBUG*/


/*-------------------------- relatorLevel ---------------------------------*/

/* The function relatorLevel( r) returns the level in G of the relator r.
   This level is defined to be the minimum level of any of the generators
   of G appearing in r.  Naturally the level fields of the generators of G
   must be filled in. */

UnsignedS relatorLevel(
   const Relator *const r)
{
   Unsigned i, minLevel = options.maxBaseSize + 1;

   for ( i = 1 ; i <= r->length ; ++i )
      if ( r->rel[i]->level < minLevel )
         minLevel = r->rel[i]->level;

   return minLevel;
}


/*-------------------------- symmetricLength ------------------------------*/

/* The function symmetricLength( r) returns the "symmetric length" of the
   relator r.  The symmetric length of r is defined to be the smallest
   positive integer i such that an i-position cyclic shift of r leaves r
   unchanged.  The relator must have been created with doubleFlag set. */

Unsigned symmetricLength(
   const Relator *const r)
{
   Permutation **rel = r->rel;
   Unsigned i, j, length = r->length;

   for ( i = 1 ; i <= length / 2 ; ++i )
      if ( length % i == 0 ) {
         for ( j = 1 ; j <= length && rel[j+i] == rel[j] ; ++j )
            ;
         if ( j > length )
            return i;
      }

   return length;
}


/*-------------------------- symmetricWordLength --------------------------*/

/* The function symmetricWordLength( w) is identical to symmetricLength
   (above) except that it uses a word, rather than a relator, as its input. */

Unsigned symmetricWordLength(
   const Word *const w)
{
   Permutation **rel = w->position;
   Unsigned i, j, length = w->length;

   for ( i = 1 ; i <= length / 2 ; ++i )
      if ( length % i == 0 ) {
         for ( j = 1 ; j <= length && rel[(j-1+i)%length + 1] == rel[j] ; ++j )
            ;
         if ( j > length )
            return i;
      }

   return length;
}


/*-------------------------- addRelatorSortedFromWord ---------------------*/

/* The function addRelatorSortedFromWord( G, w, fbRelFlag, doubleFlag) adds
   a new relator, represented by a word w, to a permutation group G.  The
   new relator is positioned so that the relators remain sorted by level
   (highest to lowest) and so that the new relator is last among relators
   of its level.  Note both the new relator and the word w will be reduced
   by cancelling adjacent entries of form a * a^-1 or a^-1 * a.  If fbRelFlag
   is set, the fRel and bRel entries of the new relator will be constructed.
   If doubleFlag is set, the each relator will be concatenated to itself (the
   length field will still give the original length).

   The function returns a pointer to the relator added, or NULL if it could
   not be added. */

Relator *addRelatorSortedFromWord(
   PermGroup *const G,
   Word *const w,
   BOOLEAN fbRelFlag,
   BOOLEAN doubleFlag)
{
   Relator *newRel, *r, *rPrev;
   Unsigned newLevel;

   newRel = newRelatorFromWord( w, fbRelFlag, doubleFlag);
   if ( !newRel )
      return NULL;
   newLevel = relatorLevel( newRel);
   newRel->level = newLevel;
   rPrev = NULL;
   for ( r = G->relator ; r && r->level >= newLevel ; rPrev = r , r = r->next )
      ;
   newRel->next = r;
   newRel->last = rPrev;
   if ( rPrev )
      rPrev->next = newRel;
   else
      G->relator = newRel;
   if ( r )
      r->last = newRel;

   return newRel;
}


/*-------------------------- addOccurencesForRelator ---------------------*/

/* The function addOccurencesForRelator( r, priority) adds an occurenceOfGen record
   for each significantly different occurence of each generator in r.
   If shiftSelection[0] != UNKNOWN, only those specified shift selections
   for which priority >= shiftPriority are added.  It returns the number
   of occurences added. */

Unsigned addOccurencesForRelator(
   const Relator *const r,
   Unsigned priority)
{
   Unsigned i, j, addCount = 0, symLength = symmetricLength(r);
   OccurenceOfGen *p, *q, *prevQ;
   Permutation *gen;

   if ( symLength <= 4 || shiftSelection[0] == UNKNOWN )
      for ( i = 1 ; i <= symLength ; ++i ) {
         ++addCount;
         p = allocOccurenceOfGen();
         p->r = r;
         p->relLength = r->length;
         p->level = r->level;
         p->fRelStart = r->fRel + i;
         p->bRelFinish = r->bRel + (i + r->length - 1);
         gen = r->rel[i];
         for ( prevQ = NULL , q = gen->occurHeader ; q && q->level >= p->level ;
               prevQ = q , q = q->next )
            ;
         p->next = q;
         if ( prevQ )
            prevQ->next = p;
         else
            gen->occurHeader = p;
      }
   else
      for ( j = 0 ; shiftSelection[j] != UNKNOWN ; ++j ) {
         i = shiftSelection[j] + 1;
         if ( i < r->length && priority >= shiftPriority[j] ) {
            ++addCount;
            p = allocOccurenceOfGen();
            p->r = r;
            p->relLength = r->length;
            p->level = r->level;
            p->fRelStart = r->fRel + i;
            p->bRelFinish = r->bRel + (i + r->length - 1);
            gen = r->rel[i];
            for ( prevQ = NULL , q = gen->occurHeader ; q && q->level >= p->level ;
                  prevQ = q , q = q->next )
               ;
            p->next = q;
            if ( prevQ )
               prevQ->next = p;
            else
               gen->occurHeader = p;
         }
      }

   return addCount;
}


/*-------------------------- resetTable -----------------------------------*/

void resetTable(
   Permutation *genHeader,
   Unsigned basicOrbLen,
   Unsigned *basicOrbit)
{
   Permutation *gen;
   Unsigned i;

   for ( gen = genHeader ; gen ; gen = gen->xNext )
      for ( i = 1 ; i <= basicOrbLen ; ++i )
         gen->image[basicOrbit[i]] &= NHB;
}


/*-------------------------- findConsequences -----------------------------*/

/* The function findConsequences( deductionQueuelevel, deduc) finds all direct
   consequences of a given  definition or deduction and its inverse by tracing
   that definition/deduction at all significantly difference occurences of the
   generators in all relators at the specified level or above.  New deductions
   are enqueued on deductionQueue but not processed.

   This function returns the number of additional table entries filled in
   as consequences.  */

Unsigned findConsequences(
   DeductionQueue *deductionQueue,
   const Unsigned level,
   const Deduction *const deduc)
{
   OccurenceOfGen *occurence;
   Unsigned count, fCos, bCos, newEntryCount = 0;
   Unsigned **fPtr, **bPtr;
   Deduction newDeduc;
   Permutation *gen;

   for ( occurence = deduc->gn->occurHeader ; occurence &&
         occurence->level >= level; occurence = occurence->next ) {
      count = occurence->relLength - 1;
      for ( fCos = deduc->img , fPtr = occurence->fRelStart+1 ;
            count && !((*fPtr)[fCos] & HB) ; ++fPtr , --count )
         fCos = (*fPtr)[fCos];
      for ( bCos = deduc->pnt , bPtr = occurence->bRelFinish ;
            count && !((*bPtr)[bCos] & HB) ; --bPtr , --count )
         bCos = (*bPtr)[bCos];
      if ( count == 1 ) {
         (*fPtr)[fCos] = bCos;
         ++newEntryCount;
         gen = occurence->r->rel[fPtr - occurence->r->fRel];
         newDeduc.pnt = fCos;  newDeduc.img = bCos;  newDeduc.gn = gen;
         ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
         if ( fCos != bCos || gen != gen->invPermutation ) {
            (*bPtr)[bCos] = fCos;
            ++newEntryCount;
            newDeduc.img = fCos;  newDeduc.pnt = bCos;  newDeduc.gn =
                                                        gen->invPermutation;
            ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
         }
      }
   }

   return newEntryCount;
}


/*-------------------------- traceNewRelator ------------------------------*/

/* The function traceNewRelator( G, level, deductionQueue, newRel) processes
   a new relator newRel at level level for a group G.  It traces all cyclic
   shifts of newRel from each coset.  Deductions found are enqueued on
   deductionQueue but not otherwise processed.

   This function returns the number of additional table entries filled in
   due to tracing the new relator.  */

Unsigned traceNewRelator(
   const PermGroup *const G,
   const Unsigned level,
   DeductionQueue *deductionQueue,
   const Relator *const newRel)
{
   Unsigned i, pt, startingPos, count, fCos, bCos, newEntryCount = 0;
   Unsigned **fPtr, **bPtr;
   Deduction newDeduc;
   Permutation *gen;

   for ( i = 1 ; i <= G->basicOrbLen[level] ; ++i ) {
      pt = G->basicOrbit[level][i];
      for ( startingPos = 1 ; startingPos <= newRel->length ; ++startingPos ) {
         count = newRel->length;
         for ( fCos = pt , fPtr = newRel->fRel+startingPos ;
               count && !((*fPtr)[fCos] & HB) ; ++fPtr , --count )
            fCos = (*fPtr)[fCos];
         for ( bCos = pt , bPtr = newRel->bRel+startingPos+newRel->length-1 ;
               count && !((*bPtr)[bCos] & HB) ; --bPtr , --count )
            bCos = (*bPtr)[bCos];
         if ( count == 1 ) {
            (*fPtr)[fCos] = bCos;
            ++newEntryCount;
            gen = newRel->rel[fPtr - newRel->fRel];
            newDeduc.pnt = fCos;  newDeduc.img = bCos;  newDeduc.gn = gen;
            ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
            if ( fCos != bCos || gen != gen->invPermutation) {
               (*bPtr)[bCos] = fCos;
               ++newEntryCount;
               newDeduc.img = fCos;  newDeduc.pnt = bCos;  newDeduc.gn =
                                                           gen->invPermutation;
               ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
            }
         }
      }
   }
   return newEntryCount;
}


/*-------------------------- processCoincidence ---------------------------*/

/* The function processCoincidence( G, genHeader, coset1, coset2)
   processes a coincidence between coset1 and coset2 in a special STCS
   coset enumeration.  Here genHeader is a header for the xNext-linked
   list of generators at the appropriate level.  It returns the extra
   number of table positions filled (points <= degree). */

Unsigned processCoincidence(
   const PermGroup *const G,
   DeductionQueue *deductionQueue,
   const Permutation *const genHeader,
   const Unsigned coset1,
   const Unsigned coset2)
{
   Unsigned degree = G->degree;
   Unsigned retainCoset, deleteCoset, ffHead, ffTail, lambda, lambdaStar,
            tau, tauStar, eta, etaStar, kappa, kappaStar, tsi1, tsi2;
   Unsigned newTableEntries = 0;
   Permutation *gen;
   Deduction newDeduc;


   /* DEBUG 
   ++callCount;
   if ( onFreeList(coset1) || onFreeList(coset2) )
      tsi1 = tsi1;
   if ( !verifyCosetList(G->degree) )
      tsi1 = tsi1;
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      if ( !isValidPermutation(gen,G->degree,extraCosetsAtLevel,equivCoset) )
         tsi1 = tsi1;  */
   /* Alg 3.4, line 1. */

   if ( coset1 == coset2 )
      return 0;

   /* Alg 3.4, line 2. */
   retainCoset = MIN( coset1, coset2);
   deleteCoset = MAX( coset1, coset2);
   ffTail = deleteCoset;
   ff[deleteCoset] = 0;
   bb[deleteCoset] = retainCoset;

   /* Alg 3.4, lines 3, 5. */
   for ( lambda = deleteCoset ; lambda ; lambda = ff[lambda] ) {

      /* Alg 3.4, line 4. */
      lambdaStar = bb[lambda];
      while ( lambdaStar > degree && bb[lambdaStar] != lambdaStar )
         lambdaStar = bb[lambdaStar];

      /* Alg 3.4, line 5. */
      for ( gen = genHeader ; gen ; gen = gen->xNext )
         if ( !(gen->image[lambda] & HB) ) {
            tau = gen->image[lambda];
            tauStar = tau;
            while ( tauStar > degree && bb[tauStar] != tauStar )
               tauStar = bb[tauStar];
            gen->image[lambda] |= HB;
            gen->invImage[tau] |= HB;
            if ( tau <= degree )
               --newTableEntries;
            kappa = gen->image[lambdaStar];
            if ( !(kappa & HB) ) {
               kappaStar = kappa;
               while ( kappaStar > degree && bb[kappaStar] != kappaStar )
                  kappaStar = bb[kappaStar];
               if ( kappaStar != tauStar ) {
                  tsi1 = MIN( tauStar, kappaStar);
                  tsi2 = MAX( tauStar, kappaStar);
                  ff[ffTail] = tsi2;
                  ff[tsi2] = 0;
                  ffTail = tsi2;
                  bb[tsi2] = tsi1;
                  if ( lambdaStar == tsi2 )
                     lambdaStar = tsi1;
               }
            }
            else {
               eta = gen->invImage[tauStar];
               if ( !(eta & HB) ) {
                  etaStar = eta;
                  while ( etaStar > degree && bb[etaStar] != etaStar )
                     etaStar = bb[etaStar];
                  if ( etaStar != lambdaStar ) {
                     tsi1 = MIN( lambdaStar, etaStar);
                     tsi2 = MAX( lambdaStar, etaStar);
                     ff[ffTail] = tsi2;
                     ff[tsi2] = 0;
                     ffTail = tsi2;
                     bb[tsi2] = tsi1;
                     lambdaStar = tsi1;
                  }
               }
               else {
                  if ( lambdaStar <= degree && (gen->image[lambdaStar] & HB) )
                     ++newTableEntries;
                  gen->image[lambdaStar] = tauStar;
                  newDeduc.pnt = lambdaStar;  newDeduc.img = tauStar;
                  newDeduc.gn = gen;
                  ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
                  if ( lambdaStar != tauStar || gen != gen->invPermutation ) {
                     if ( tauStar <= degree && (gen->invImage[tauStar] & HB) )
                        ++newTableEntries;
                     gen->invImage[tauStar] = lambdaStar;
                     newDeduc.pnt = tauStar;  newDeduc.img = lambdaStar;
                     newDeduc.gn = gen->invPermutation;
                     ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
                  }
               }
            }
         }
      /*DEBUG
      if ( onFreeList(lambda) )
         tsi1 = tsi1;   */
      if ( lambda == firstCos )
         firstCos = nextCos[lambda];
      else
         nextCos[prevCos[lambda]] = nextCos[lambda];
      if ( nextCos[lambda] != 0 )
         prevCos[nextCos[lambda]] = prevCos[lambda];
      nextCos[lambda] = freeCosHeader;
      freeCosHeader = lambda;
      --currentExtraCosets;
      /*DEBUG
      if ( !verifyCosetList(G->degree) )
         tsi1 = tsi1;*/
   }

   /* DEBUG 
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      if ( !isValidPermutation(gen,G->degree,extraCosetsAtLevel,equivCoset) )
         tsi1 = tsi1;*/

   return newTableEntries;
}

/*-------------------------- xFindConsequences ----------------------------*/

/* The function xFindConsequences( deductionQueuelevel, deduc) finds all direct
   consequences of a given  definition or deduction and its inverse by tracing
   that definition/deduction at all significantly difference occurences of the
   generators in all relators at the specified level or above.  New deductions
   are enqueued on deductionQueue but not processed.

   This function returns the number of additional table entries filled in
   as consequences.  */

Unsigned xFindConsequences(
   const PermGroup *const G,
   DeductionQueue *deductionQueue,
   const Unsigned level,
   const Deduction *const deduc,
   const Permutation *const genHeader)
{
   OccurenceOfGen *occurence;
   Unsigned count, fCos, bCos, newEntryCount = 0, degree = G->degree;
   Unsigned **fPtr, **bPtr;
   Deduction newDeduc;
   Permutation *gen;

   /* DEBUG 
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      if ( !isValidPermutation(gen,G->degree,extraCosetsAtLevel,equivCoset) )
         fCos = fCos; */

   if ( (deduc->pnt > degree && bb[deduc->pnt] != deduc->pnt) ||
        (deduc->img > degree && bb[deduc->img] != deduc->img) )
      return 0;

   for ( occurence = deduc->gn->occurHeader ; occurence &&
         occurence->level >= level; occurence = occurence->next ) {
      count = occurence->relLength - 1;
      for ( fCos = deduc->img , fPtr = occurence->fRelStart+1 ;
            count && !((*fPtr)[fCos] & HB) ; ++fPtr , --count )
         fCos = (*fPtr)[fCos];
      if ( count == 0 ) {
         if ( fCos != deduc->pnt ) {
            newEntryCount += processCoincidence( G, deductionQueue, genHeader,
                                                 deduc->pnt, fCos);
            if ( (deduc->pnt > degree && bb[deduc->pnt] != deduc->pnt) ||
                 (deduc->img > degree && bb[deduc->img] != deduc->img) )
                return 0;
            }
         continue;
      }
      for ( bCos = deduc->pnt , bPtr = occurence->bRelFinish ;
            count && !((*bPtr)[bCos] & HB) ; --bPtr , --count )
         bCos = (*bPtr)[bCos];
      if ( count == 1 ) {
         (*fPtr)[fCos] = bCos;
         if ( fCos <= G->degree )
            ++newEntryCount;
         gen = occurence->r->rel[fPtr - occurence->r->fRel];
         newDeduc.pnt = fCos;  newDeduc.img = bCos;  newDeduc.gn = gen;
         ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
         if ( fCos != bCos || gen != gen->invPermutation) {
            (*bPtr)[bCos] = fCos;
            if ( bCos <= G->degree )
               ++newEntryCount;
            newDeduc.img = fCos;  newDeduc.pnt = bCos;  newDeduc.gn =
                                                        gen->invPermutation;
            ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
         }
      }
   }

   /* DEBUG 
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      if ( !isValidPermutation(gen,G->degree,extraCosetsAtLevel,equivCoset) )
         fCos = fCos; */
   return newEntryCount;
}


/*-------------------------- xTraceNewRelator ------------------------------*/

/* The function xTraceNewRelator( G, level, deductionQueue, newRel) processes
   a new relator newRel at level level for a group G.  It traces all cyclic
   shifts of newRel from each coset.  Deductions found are enqueued on
   deductionQueue but not otherwise processed.

   This function returns the number of additional table entries filled in
   due to tracing the new relator.  */

Unsigned xTraceNewRelator(
   const PermGroup *const G,
   const Unsigned level,
   DeductionQueue *deductionQueue,
   const Relator *const newRel,
   const Permutation *const genHeader)
{
   Unsigned i, pt, startingPos, count, fCos, bCos, newEntryCount = 0;
   Unsigned **fPtr, **bPtr;
   Deduction newDeduc;
   Permutation *gen;

   /* DEBUG 
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      if ( !isValidPermutation(gen,G->degree,extraCosetsAtLevel,equivCoset) )
         fCos = fCos; */

   for ( i = 1 ; i <= G->basicOrbLen[level] ; ++i ) {
      pt = G->basicOrbit[level][i];
      for ( startingPos = 1 ; startingPos <= newRel->length ; ++startingPos ) {
         count = newRel->length;
         for ( fCos = pt , fPtr = newRel->fRel+startingPos ;
               count && !((*fPtr)[fCos] & HB) ; ++fPtr , --count )
            fCos = (*fPtr)[fCos];
      if ( count == 0 ) {
         if ( fCos != pt )
            newEntryCount += processCoincidence( G, deductionQueue, genHeader,
                                                 pt, fCos);
         continue;
      }
         for ( bCos = pt , bPtr = newRel->bRel+startingPos+newRel->length-1 ;
               count && !((*bPtr)[bCos] & HB) ; --bPtr , --count )
            bCos = (*bPtr)[bCos];
         if ( count == 1 ) {
            (*fPtr)[fCos] = bCos;
            if ( fCos <= G->degree )
               ++newEntryCount;
            gen = newRel->rel[fPtr - newRel->fRel];
            newDeduc.pnt = fCos;  newDeduc.img = bCos;  newDeduc.gn = gen;
            ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
            if ( fCos != bCos || gen != gen->invPermutation) {
               (*bPtr)[bCos] = fCos;
               if ( bCos <= G->degree )
                  ++newEntryCount;
               newDeduc.img = fCos;  newDeduc.pnt = bCos;  newDeduc.gn =
                                                           gen->invPermutation;
               ATTEMPT_ENQUEUE( deductionQueue, newDeduc)
            }
         }
      }
   }

   /* DEBUG 
   for ( gen = genHeader ; gen ; gen = gen->xNext )
      if ( !isValidPermutation(gen,G->degree,extraCosetsAtLevel,equivCoset) )
         fCos = fCos; */

   return newEntryCount;
}


/*-------------------------- makeDefinition --------------------------------*/

void makeDefinition(
   const Unsigned coset,
   Permutation *const gen,
   DeductionQueue *const deducQueue,
   DefinitionList *const defnList,
   Permutation *const genHeader)
{
   Unsigned newCoset, trueCoset;
   Deduction newDeduc;
   Permutation *gen1;

   /* DEBUG 
   if ( !verifyCosetList(255) )
      trueCoset = trueCoset;
   for ( gen1 = genHeader ; gen1 ; gen1 = gen1->xNext )
      if ( !isValidPermutation(gen1,255,extraCosetsAtLevel,equivCoset) )
         trueCoset = trueCoset; */

   defnList->coset[defnList->tail] = coset;
   defnList->gen[defnList->tail] = gen;
   defnList->image[defnList->tail] = trueCoset = gen->image[coset] & NHB;
   ++defnList->size;
   ++defnList->tail;
   defnList->tail %= extraCosetsAtLevel;

   newCoset = freeCosHeader;
   freeCosHeader = nextCos[freeCosHeader];
   if ( firstCos != 0 )
      prevCos[firstCos] = newCoset;
   nextCos[newCoset] = firstCos;
   firstCos = newCoset;
   prevCos[newCoset] = 0;
   equivCoset[newCoset] = trueCoset;
   bb[newCoset] = newCoset;
   for ( gen1 = genHeader ; gen1 ; gen1 = gen1->xNext )
      gen1->image[newCoset] = HB;
   gen->image[coset] = newCoset;
   gen->invImage[newCoset] = coset;
   ++currentExtraCosets;
   newDeduc.pnt = coset;  newDeduc.img = newCoset;  newDeduc.gn = gen;
   ATTEMPT_ENQUEUE( deducQueue, newDeduc)
   newDeduc.pnt = newCoset;  newDeduc.img = coset;
   newDeduc.gn = gen->invPermutation;
   ATTEMPT_ENQUEUE( deducQueue, newDeduc)

   /* DEBUG 
   if ( !verifyCosetList(255) )
      trueCoset = trueCoset;
   for ( gen1 = genHeader ; gen1 ; gen1 = gen1->xNext )
      if ( !isValidPermutation(gen1,255,extraCosetsAtLevel,equivCoset) )
         trueCoset = trueCoset; */
}


/*-------------------------- forceCollapse ---------------------------------*/

Unsigned forceCollapse(
   const PermGroup *const G,
   const Unsigned level,
   Permutation *genHeader,
   DeductionQueue *const deductionQueue,
   DefinitionList *const defnList,
   Unsigned *jPtr,
   Permutation **hPtr,
   Word **wPtr)
{
   Unsigned coset, image, oldImage, j, newTableEntries;
   Permutation *gen, *gen1;
   WordImagePair wh;
   Unsigned basicOrbLen = G->basicOrbLen[level];
   UnsignedS *basicOrbit = G->basicOrbit[level];
   Deduction *newDeduc;

   /* ???????????????????
   coset = defnList->coset[defnList->head];
   gen = defnList->gen[defnList->head];
   image = defnList->image[defnList->head];
   ++defnList->size;
   ++defnList->head;
   defnList->head %= extraCosetsAtLevel; ?????????????*/

   for ( j = 1 ; j <= G->basicOrbLen[level] ; ++j ) {
      coset = G->basicOrbit[level][j];
      for ( gen = genHeader ; gen ; gen = gen->xNext )
         if ( !(gen->image[coset] & HB) && gen->image[coset] > G->degree ) {
            j = G->basicOrbLen[level] + 2;
            break;
         }
   } 
   image = equivCoset[gen->image[coset]];      


   /* DEBUG 
   for ( gen1 = genHeader ; gen1 ; gen1 = gen1->xNext )
      if ( !isValidPermutation(gen1,G->degree,extraCosetsAtLevel,equivCoset) )
         j = j; */
   wh = xComputeSchreierGen( G, level, coset, gen);
   /* DEBUG 
   for ( gen1 = genHeader ; gen1 ; gen1 = gen1->xNext )
      if ( !isValidPermutation(gen1,G->degree,extraCosetsAtLevel,equivCoset) )
         j = j;  */
   if ( !xReduce( G, level, &j, &wh) ) {
      *jPtr = j;
      *hPtr = allocPermutation();
      (*hPtr)->degree = G->degree;
      (*hPtr)->image = wh.image;
      adjoinInvImage( *hPtr);
      *wPtr = allocWord();
      **wPtr = wh.word;
      resetTable( genHeader, basicOrbLen, basicOrbit);
      return UNKNOWN;
   }
   /* DEBUG 
   for ( gen1 = genHeader ; gen1 ; gen1 = gen1->xNext )
      if ( !isValidPermutation(gen1,G->degree,extraCosetsAtLevel,equivCoset) )
         j = j;  */
   freeIntArrayDegree( wh.image);
   *wPtr = allocWord();
   **wPtr = wh.word;
   newTableEntries = processCoincidence( G, deductionQueue, genHeader,
                                         image, gen->image[coset]);

   return newTableEntries;
}



/*-------------------------- verifyCosetList--------------------------------*/

BOOLEAN verifyCosetList(
   Unsigned degree)
{
   Unsigned inUseCount = 0, freeCount = 0, i, coset;
   char *found = (char *) malloc( extraCosetsAtLevel+2) - degree;

   for ( i = degree+1 ; i <= degree + extraCosetsAtLevel ; ++i )
      found[i] = FALSE;
   for ( coset = firstCos ; coset != 0 ; coset = nextCos[coset] ) {
      if ( coset <= degree || coset > degree+extraCosetsAtLevel ) {
         printf( "\n*** Invalid coset %u on in use list.", coset);
         return FALSE;
      }
      if ( found[coset] ) {
         printf ( "\n*** Coset %u appears twice on in use list.", coset);
         return FALSE;
      }
      found[coset] = 1;
      ++inUseCount;
   }
   for ( coset = freeCosHeader ; coset != 0 ; coset = nextCos[coset] ) {
      if ( coset <= degree || coset > degree+extraCosetsAtLevel ) {
         printf( "\n*** Invalid coset %u on free list.", coset);
         return FALSE;
      }
      if ( found[coset] == 1 ) {
         printf ( "\n*** Coset %u appears on both lists.", coset);
         return FALSE;
      }
      else if ( found[coset] == 2 ) {
         printf ( "\n*** Coset %u appears twice on free list.", coset);
         return FALSE;
      }
      found[coset] = 2;
      ++freeCount;
   }
   
   if ( inUseCount + freeCount != extraCosetsAtLevel ) {
      printf( "\n*** Invalid coset counts: %u + %u != %u", inUseCount,
              freeCount, extraCosetsAtLevel);
      return FALSE;
   }

   if ( firstCos != 0 && prevCos[firstCos] != 0 ) {
      printf( "\n*** firstCos = %u, prevCos[%u] = %u.", firstCos, firstCos,
              prevCos[firstCos]);
      return FALSE;
   }

   for ( coset = firstCos ; coset != 0 ; coset = nextCos[coset] ) 
      if ( (coset != firstCos && nextCos[prevCos[coset]] != coset) ||
           (nextCos[coset] != 0 && prevCos[nextCos[coset]] != coset) ) {
         printf( "\n*** Invalid linked list at %u.", coset);
         return FALSE;
      }

   free(found);
   return TRUE;
}
      




/*-------------------------- verifyCosetList--------------------------------*/

BOOLEAN onFreeList(
   Unsigned coset)
{
   Unsigned i;

   for ( i = freeCosHeader ; i != 0 ; i = nextCos[i] )
      if ( i == coset )
         return TRUE;

   return FALSE;
}
