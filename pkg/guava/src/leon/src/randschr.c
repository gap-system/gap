/* File randschr.c. */

#include <stddef.h>
#include <stdio.h>
#include <string.h>

#include "group.h"
#include "groupio.h"

#include "addsgen.h"
#include "cstborb.h"
#include "errmesg.h"
#include "essentia.h"
#include "factor.h"
#include "new.h"
#include "oldcopy.h"
#include "permgrp.h"
#include "permut.h"
#include "randgrp.h"
#include "storage.h"
#include "token.h"

extern GroupOptions options;

CHECK( randsc)

extern Unsigned primeList[];

/*-------------------------- removeIdentityGens ---------------------------*/

/* This function removes any identity generators for a group G.  It is
   assumed that the group does not have a base and strong generating set; in
   particular, Schreier vectors are not modified.  (Presumably they are not
   present.) */

void removeIdentityGens(
   PermGroup *const G)              /* The group G mentioned above. */
{
   Permutation *gen, *tempGen;

   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( isIdentity( gen) ) {
         tempGen = gen;
         if ( tempGen->last ) {
            tempGen->last->next = tempGen->next;
            gen = tempGen->last;
         }
         else {
            G->generator = tempGen->next;
            gen = G->generator;
         }
      if ( tempGen->next )
         tempGen->next->last = tempGen->last;
      deletePermutation( tempGen);
   }
}


/*-------------------------- adjoinGenInverses ----------------------------*/

/* This function adjoins to each generator in a permutation group G (not
   having a base and strong generating set) the array of inverse images,
   provided it is not already present.  For involutory generators, G->image
   and G->invImage point to the same array. */

void adjoinGenInverses(
   PermGroup *const G)              /* The group mentioned above. */
{
   Permutation *gen;
   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( !gen->invImage )
         adjoinInvImage( gen);
}


/*-------------------------- initializeBase -------------------------------*/

/* This function constructs an initial segment of the base for a permutation
   group G.  When called, the base must not exist (G->base==NULL).  The
   initial base points are selected so that, upon return, each generator
   moves some base point.  The function attempts to choose base points so
   that as many generators as possible (but not all) fix an initial segment
   of the base.  The only field in the group G that is allocated is the base
   field. */

void initializeBase(
   PermGroup *const G)              /* The group G mentioned above. */
{
   Unsigned pt, count, maxCount, newBasePt;
   BOOLEAN ok;
   Permutation *gensFixingBase, *perm, *lastPerm;

   G->baseSize = 0;

   /* The xNext field of the generators will be used to maintain a singly-
      linked list of those generators fixing the initial segment of the base
      chosen so far.  Here the list is initialized to all generators. */
   gensFixingBase = G->generator;
   for ( perm = G->generator ; perm ; perm = perm->next )
      perm->xNext = perm->next;

   /* As long as some generator fixes the initial base segment, we find a
      new base point fixed by a maximal number (but not all) such generators.
      A noninvolutory generator is counted twice. */
   while ( gensFixingBase ) {
      maxCount = UNKNOWN;
      for ( pt = 1 ; pt <= G->degree ; ++pt ) {
         for ( count = 0 , ok = FALSE , perm = gensFixingBase ; perm ;
               perm = perm ->xNext )
            if ( perm->image[pt] == pt )
               count += (perm->image == perm->invImage) ? 1 : 2;
            else
               ok = TRUE;
         if ( (maxCount == UNKNOWN || count > maxCount) && ok ) {
            newBasePt = pt;
            maxCount = count;
         }
      }
      if ( G->baseSize < options.maxBaseSize )
         G->base[++G->baseSize] = newBasePt;
      else
         ERROR1i( "initializeBase", "Base size exceeded maximum of ",
                  options.maxBaseSize, ".  Rerun with -mb option.")

      /* Here we reconstruct the list of generators fixing the initial base
         segment. */
      for ( perm = gensFixingBase , gensFixingBase = NULL ; perm ;
            perm = perm->xNext )
         if ( perm->image[newBasePt] == newBasePt ) {
            if ( gensFixingBase )
               lastPerm->xNext = perm;
            else
               gensFixingBase = perm;
            lastPerm = perm;
         }
      if ( gensFixingBase )
         lastPerm->xNext = NULL;
   }
}


/*-------------------------- randomizeGen ---------------------------------*/

/* This function produces a (hopefully) quasi-random element of a group G by
   taking a previously-computed quasi-random element (randGen) any multiplying
   it on the right by a random word of length in a specified range
   (count1,count1+1,...,count2) in a list (genList) of permutations (which
   should generate the group G).  The length of the word is pseudo-random
   in the range given above. */

static void randomizeGen(
   const Unsigned genListLength,        /* The length of the list genList. */
   const Permutation *const genList[],  /* The list of (generating) perms. */
   const Unsigned count1,               /* The minimum word length, as above. */
   const Unsigned count2,               /* The maximum word length, as above. */
   Permutation *const randGen)          /* The old and new quasi-random elt. */
{
   Unsigned i,
       wordLength = count1 +
                    ( (count2 > count1) ? randInteger( 0, count2-count1) : 0);
   for ( i = 1 ; i <= wordLength ; ++i )
      rightMultiply( randGen, genList[ randInteger(1,genListLength) ]);
}


/*-------------------------- factorGroupElt -------------------------------*/

/* This function writes an element (perm) of a permutation group G as
              perm = u_1' u_2' ... u_{j-1}' h
   where u_1',...,u_{j-1}' are inverses of coset representatives
   (u_p' in G^(p)) and h is an element of G^(j-1)  (i.e., h has level j)
   such that one of the following holds:
      1)  j <= G->baseSize and h maps G->base[j] outside the j'th basic orbit.
      2)  j == G->baseSize+1 and h != 1.
      3)  j == G->baseSize+1 and h = 1.
   It returns TRUE in case (3) above and FALSE otherwise.  It also replaces
   perm by h and returns the value of j as finalLevel. */

static BOOLEAN factorGroupElt(
   const PermGroup *const G,     /* The permutation group, as above. */
   Permutation *const perm,      /* The permutation to factor, as above. */
   Permutation *const h,         /* Set to the permutation h, as above.  Must
                                    be preallocated of correct degree. */
   Unsigned *const finalLevel)        /* The value of j, as above. */
{
   Unsigned level, img;
   copyPermutation( perm, h);
   for ( level = 1 ; level <= G->baseSize ; ++level ) {
      img = h->image[G->base[level]];
      if ( G->schreierVec[level][img] )
         while ( G->schreierVec[level][img] != FIRST_IN_ORBIT ) {
            rightMultiplyInv( h, G->schreierVec[level][img]);
            img = h->image[G->base[level]];
         }
      else
         break;
   }
   *finalLevel = level;
   if ( *finalLevel == G->baseSize+1 )
      return isIdentity( h);
   else
      return FALSE;
}


/*-------------------------- replaceByPower -------------------------------*/

void replaceByPower(
   const PermGroup *const G,
   const Unsigned level,
   Permutation *const h)
{
   unsigned long hOrder;
   Unsigned i, img, hCycleLen;
   UnsignedS *hCycle = allocIntArrayDegree();

   if ( level <= G->baseSize ) {
      /* Replace h by h^d, where d is maximal subject to d dividing |h| and
         h^d mapping G->base[level] outside the level'th basic orbit. */
      img = G->base[level];
      hCycleLen = 0;
      do {
         hCycle[hCycleLen++] = img;
         img = h->image[img];
      } while ( img != G->base[level] );
      for ( i = 2 ; i <= hCycleLen/2 ; ++i )
         if ( hCycleLen % i == 0  &&
              G->schreierVec[level][hCycle[hCycleLen/i]] == NULL ) {
            raisePermToPower( h, hCycleLen / i);
            break;
         }
   }
   else {
      /* Replace h by h^d, where d is maximal subject to d dividing |h| and
         d < |h|. */
      hOrder = permOrder( h);
      for ( i = 0 ; primeList[i] != 0 ; ++i ) {
         if ( hOrder % primeList[i] == 0 )
            raisePermToPower( h, hOrder / primeList[i]);
            break;
      }
   }

   freeIntArrayDegree( hCycle);
}


/*-------------------------- randSchreier ---------------------------------*/
/*

   The valid options are:
      StopAfter: n               (n a positive integer, default 40)
      MinWordLengthIncrement: w  (w a positive integer, default 7)
      MaxWordLengthIncrement: x  (x a positive integer, default 23)
      ReduceGenOrder: r          (r = 'y' or 'n', default 'y')
      RejectNonInvols: p         (p a nonnegative integer, default 0)
      RejectHighOrder: q         (q a nonnegative integer, default 0)
      OnlyEssentialInitGens: i   (i = 'y' or 'n', default 'n')
      OnlyEssentialAddedGens: a  (a = 'y' or 'n', default 'y') */


BOOLEAN randomSchreier(
   PermGroup *const G,
   RandomSchreierOptions rOptions)
{
   Unsigned  noOfOriginalGens, successCount, level, finalLevel,
        nonInvolRejectCount, levelLowestOrder;
   unsigned long curOrder, lowestOrder;
   Permutation  **originalGen;
   FactoredInt  trueGroupOrder, factoredOrbLen;
   Permutation  *gen;
   Permutation  *randGen = newIdentityPerm( G->degree),
                *h = newUndefinedPerm( G->degree),
                *lowestOrderH = newUndefinedPerm( G->degree),
                *tempPerm;

   /* Set defaults for options. */
   if ( rOptions.initialSeed == 0 )
      rOptions.initialSeed = 47;
   if ( rOptions.minWordLengthIncrement == UNKNOWN )
      rOptions.minWordLengthIncrement = 7;
   if ( rOptions.maxWordLengthIncrement == UNKNOWN )
      rOptions.maxWordLengthIncrement = 23;
   if ( rOptions.stopAfter == UNKNOWN )
      if ( G->order )
         rOptions.stopAfter = 10000;
      else
         rOptions.stopAfter = 40;
   if ( rOptions.reduceGenOrder == UNKNOWN )
      rOptions.reduceGenOrder = TRUE;
   if ( rOptions.rejectNonInvols == UNKNOWN )
      rOptions.rejectNonInvols = 0;
   if ( rOptions.rejectHighOrder == UNKNOWN )
      rOptions.rejectHighOrder = 0;
   if ( rOptions.onlyEssentialInitGens == UNKNOWN )
      rOptions.onlyEssentialInitGens = FALSE;
   if ( rOptions.onlyEssentialAddedGens == UNKNOWN )
      rOptions.onlyEssentialAddedGens = TRUE;

   /* Initialize seed. */
   initializeSeed( rOptions.initialSeed);

  /* Check that fields of G that must be null initially actually are.  Then
     allocate these fields.  */
  if ( G->base || G->basicOrbLen || G->basicOrbit || G->schreierVec )
     ERROR( "randschr", "A group field that must be null initially was "
                        "nonnull.")
  G->base = allocIntArrayBaseSize();
  G->basicOrbLen = allocIntArrayBaseSize();
  G->basicOrbit = (UnsignedS **) allocPtrArrayBaseSize();
  G->schreierVec = (Permutation ***) allocPtrArrayBaseSize();

   /* If the true group order is known, set trueGroupOrder to it.  Otherwise
      allocate G->order and mark trueGroupOrder as undefined (i.e.,
      noOfFactors == UNKNOWN).  Then set G->order to 1.  */
      if ( G->order )
         trueGroupOrder = *G->order;
      else {
         G->order = allocFactoredInt();
         trueGroupOrder.noOfFactors = UNKNOWN;
      }
      G->order->noOfFactors = 0;

   /* Delete identity generators from G if present.  Return immediately if
      G is the identity group. */
   removeIdentityGens( G);
   if ( !G->generator) {     /* Should we allocate G->base, etc??? */
      G->baseSize = 0;
      return TRUE;
   }

   /* Adjoin an inverse image array to each permutation if absent. */
   adjoinGenInverses( G);

   /* Choose an initial segment of the base so that each generator moves
      some base point. */
   initializeBase( G);

   /* Here we allocate and construct an array of pointers to the original
      generators. */
   noOfOriginalGens = 0;
   originalGen = allocPtrArrayDegree();
   for ( gen = G->generator ; gen ; gen = gen->next )
      originalGen[++noOfOriginalGens] = gen;

   /* Fill in the level of each generator, and make each generator essential
      at its level and above. (????) */
   for ( gen = G->generator ; gen ; gen = gen->next ) {
      gen->level = levelIn( G, gen);
      MAKE_NOT_ESSENTIAL_ALL( gen);
      for ( level = 1 ; level <= gen->level ; ++level )
         MAKE_ESSENTIAL_AT_LEVEL( gen, level);
   }

   /* Construct the orbit length, basic orbit, and Schreier vector arrays.  Set
      G->order (previously allocated) to the product of the basic orbit
      lengths. */
   G->order->noOfFactors = 0;
   for ( level = 1 ; level <= G->baseSize ; ++level ) {
      G->basicOrbLen[level] = 1;
      G->basicOrbit[level] = allocIntArrayDegree();
      G->schreierVec[level] = allocPtrArrayDegree();
      if ( rOptions.onlyEssentialInitGens )
         constructBasicOrbit( G, level, "FindEssential");
      else
         constructBasicOrbit( G, level, "AllGensAtLevel" );
   }

   /* The variable successCount will count the number of consecutive times
      the quasi-random group element can be factored successfully. */
   successCount = 0;
   nonInvolRejectCount = 0;

   while ( successCount < rOptions.stopAfter &&
                  (trueGroupOrder.noOfFactors == UNKNOWN ||
                   !factEqual( G->order, &trueGroupOrder)) ) {

      randomizeGen( noOfOriginalGens, originalGen,
                    rOptions.minWordLengthIncrement,
                    rOptions.maxWordLengthIncrement, randGen);
      if ( factorGroupElt( G, randGen, h, &finalLevel) )
         ++successCount;
      else {
         successCount = 0;
         if ( rOptions.reduceGenOrder )
            replaceByPower( G, finalLevel, h);
         if ( nonInvolRejectCount >= rOptions.rejectNonInvols ||
                                                 isInvolution( h) ) {
            if ( nonInvolRejectCount > 0 &&
                 (lowestOrder < (curOrder = permOrder(h)) ||
                  lowestOrder == curOrder && levelLowestOrder > finalLevel) ) {
               tempPerm = h;  h = lowestOrderH;  lowestOrderH = tempPerm;
               finalLevel = levelLowestOrder;
            }
            if ( finalLevel == G->baseSize+1 ) {
               if ( G->baseSize >= options.maxBaseSize )
                  ERROR1i( "initializeBase",
                           "Base size exceeded maximum of ",
                            options.maxBaseSize, ".  Rerun with -mb option.")
               G->base[++G->baseSize] = pointMovedBy( h);
               G->basicOrbLen[G->baseSize] = 1;
               G->basicOrbit[G->baseSize] = allocIntArrayDegree();
               G->schreierVec[G->baseSize] = allocPtrArrayDegree();
            }
            assignGenName( G, h);
            addStrongGenerator( G, h, FALSE);
            h = newUndefinedPerm( G->degree);
            nonInvolRejectCount = 0;
         }
         else {
            curOrder = permOrder( h);
            if ( curOrder == 0 )
               curOrder = ULONG_MAX;
            if ( nonInvolRejectCount == 0 || curOrder < lowestOrder ||
                 (curOrder == lowestOrder && finalLevel > levelLowestOrder) ) {
               copyPermutation( h, lowestOrderH);
               lowestOrder = curOrder;
               levelLowestOrder = finalLevel;
            }
            ++nonInvolRejectCount;
         }
      }
   }

   freePtrArrayDegree( originalGen);
   deletePermutation( randGen);
   deletePermutation( h);
   deletePermutation( lowestOrderH);
   return  trueGroupOrder.noOfFactors != UNKNOWN &&
           factEqual( G->order, &trueGroupOrder);
}
