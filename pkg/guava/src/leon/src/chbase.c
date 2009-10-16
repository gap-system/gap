/* File chbase.c.  Contains functions performing base changes in permutation
   groups, as follows:

      insertBasePoint:   Insert a new point at specified level into the
                         base for a permutation group.

      changeBase:        Change the base for a permutation group. */

#include <stddef.h>

#include "group.h"

#include "addsgen.h"
#include "cstborb.h"
#include "errmesg.h"
#include "essentia.h"
#include "factor.h"
#include "new.h"
#include "permgrp.h"
#include "permut.h"
#include "randgrp.h"
#include "storage.h"

#include "repinimg.h"
#include "settoinv.h"

extern GroupOptions options;

CHECK( chbase)

#define MAX_CONJ_LEVEL 4


/*-------------------------- insertBasePoint ------------------------------*/

/* The function insertBasePoint may be used to insert a new point into the
   base for a permutation group at a specified level.  Base points at a
   lower level are unchanged.  At a higher level, the new base points are
   arbitrary; redundant base points at a higher level are removed.  It is
   assumed that the base point to be inserted differs from all base points
   at a higher level.  A random Schreier approach is used.  Currently all
   words are multiplied out at generated.

   Note: insertBasePoint does not work for groups that have been compressed
         nor on groups for which inverse permutations exist. */


void insertBasePoint(
   PermGroup *G,           /* The permutation group (base and sgs known). */
   Unsigned newLevel,      /* If newLevel = i and newBasePoint = b, the   */
   Unsigned newBasePoint)  /*   base for G is changed from (b[1],...,     */
                           /*   b(i-1),...) to (b[1],...,b[i-1],b,...).   */
{
    Unsigned level, pt, image, i, uTemp1, uTemp2, uTemp3;
    UnsignedS *conjugateMap, *conjugateMapInv, *tempImg;
    UnsignedS *temp1, *temp2, *temp3, *temp4;
    FactoredInt oldOrder, oldLen;
    Permutation *gen, *tempGen, *randGen;
    Permutation **svec, **tempSVec, **temp5;
    UnsignedS *oldBasicOrbLen = allocIntArrayBaseSize();
    UnsignedS **oldBasicOrbit = (UnsignedS **) allocPtrArrayBaseSize();
    Permutation ***oldSchreierVec = (Permutation ***) allocPtrArrayBaseSize();
    char *isGenAtLevel = allocBooleanArrayBaseSize();
    unsigned loopCount = 0;   /* For bug fix wrt random number generator. */

    /* First we handle the trivial case in which newLevel == G->baseSize+1
       (The largest value it should ever have).  Here we just extend
       the base. */
    if ( newLevel == G->baseSize+1 ) {
       G->base[++G->baseSize] = newBasePoint;
       G->basicOrbLen[G->baseSize] = 1;
       G->basicOrbit[G->baseSize] = allocIntArrayDegree();
       G->basicOrbit[G->baseSize][1] = G->base[G->baseSize];
       G->schreierVec[G->baseSize] = allocPtrArrayDegree();
       for ( i = 1 ; i <= G->degree ; ++i )
          G->schreierVec[G->baseSize][i] = NULL;
       G->schreierVec[G->baseSize][G->base[G->baseSize]] = FIRST_IN_ORBIT;
       freeIntArrayBaseSize( oldBasicOrbLen);
       freePtrArrayBaseSize( oldBasicOrbit);
       freePtrArrayBaseSize( oldSchreierVec);
       freeBooleanArrayBaseSize( isGenAtLevel);
       return;
    }

   /* If the base point is already present at the correct level, there is
      nothing to do, so return. */
   if ( G->base[newLevel] == newBasePoint ) {
      freeIntArrayBaseSize( oldBasicOrbLen);
      freePtrArrayBaseSize( oldBasicOrbit);
      freePtrArrayBaseSize( oldSchreierVec);
      freeBooleanArrayBaseSize( isGenAtLevel);
      return;
   }

   /* If the new base point is conjugate in G^(newLevel) to the old, and if
      newLevel <= MAX_CONJ_LEVEL, we merely conjugate the old base and
      return. */
   if ( newLevel <= MAX_CONJ_LEVEL && G->schreierVec[newLevel][newBasePoint] ) {
      conjugateMapInv = allocIntArrayDegree();
      conjugateMap = allocIntArrayDegree();
      tempSVec = allocPtrArrayDegree();
      for ( pt = 1 ; pt <= G->degree ; ++pt )
         conjugateMapInv[pt] =
                  G->schreierVec[newLevel][newBasePoint]->invImage[pt];
      image = conjugateMapInv[newBasePoint];
      while ( image != G->base[newLevel] ) {
         REPLACE_BY_INV_IMAGE( conjugateMapInv, G->schreierVec[newLevel][image],
            G->degree, temp1, temp2, temp3, temp4)
         image = conjugateMapInv[newBasePoint];
      }
      SET_TO_INVERSE( conjugateMapInv, conjugateMap, G->degree,
                      temp1, temp2, uTemp1, uTemp2, uTemp3)
      for ( level = 1 ; level <= G->baseSize ; ++level ) {
         G->base[level] = conjugateMap[G->base[level]];
         for ( i = 1 ; i <= G->basicOrbLen[level] ; ++i )
            G->basicOrbit[level][i] = conjugateMap[G->basicOrbit[level][i]];
         for ( pt = 1 ; pt <= G->degree ; ++pt )
            tempSVec[conjugateMap[pt]] = G->schreierVec[level][pt];
         EXCHANGE( G->schreierVec[level], tempSVec, temp5)
      }
      tempImg = conjugateMapInv;
      for ( gen = G->generator ; gen ; gen = gen->next ) {
         for ( pt = 1 ; pt <= G->degree ; ++pt )
            tempImg[conjugateMap[pt]] = conjugateMap[gen->image[pt]];
         EXCHANGE( gen->image, tempImg, temp4);
         if ( gen->invImage == tempImg )
            gen->invImage = gen->image;
         else {
            SET_TO_INVERSE( gen->image, gen->invImage, G->degree,
                            temp1, temp2, uTemp1, uTemp2, uTemp3)
         }
      }
      freeIntArrayDegree( conjugateMap);
      freeIntArrayDegree( tempImg);
      freePtrArrayDegree( tempSVec);
      freeIntArrayBaseSize( oldBasicOrbLen);
      freePtrArrayBaseSize( oldBasicOrbit);
      freePtrArrayBaseSize( oldSchreierVec);
      freeBooleanArrayBaseSize( isGenAtLevel);
      return;
   }

   /* ??????????  probably not needed
      If the new base point is present at a higher level, we record that level
      in variable oldLevel.  Otherwise set oldLevel to G->baseSize+1.
      for ( oldLevel = newLevel+1 ; oldLevel <= G->baseSize &&
            G->base[oldLevel] != newBasePoint ; ++oldLevel )
         ;
   */

   /* Now we insert the new base point into the base for G.  Note the base point
      may be duplicated at a higher level.  This shouldn't cause a problem, and
      later it will be deleted as redundant.  At this point, we don't allocate
      another basic orbit vector or Schreier vector. */
   randGen = newIdentityPerm(G->degree);
   ++G->baseSize;
   if ( G->baseSize > options.maxBaseSize )
      ERROR1i( "insertBasePoint", "Base size exceeded maximum of ",
                options.maxBaseSize, ".  Rerun with -mb option.");
   for ( level = G->baseSize ; level > newLevel ; --level )
      G->base[level] = G->base[level-1];
   G->base[newLevel] = newBasePoint;

   /* Here we allocate new basic-orbit vectors and Schreier vectors for G
      at levels newLevel and higher.  (The old basic-orbit vectors and
      Schreier vectors at these levels must preserved at this point; this will
      be done in arrays oldBasicOrbit and oldSchreierVec, and the old
      basic orbit lengths at levels newLevel and higher will be preserved in
      oldBasicOrbLen.) */
   for ( level = newLevel ; level <= G->baseSize ; ++level ) {
      oldBasicOrbLen[level] = G->basicOrbLen[level];
      oldBasicOrbit[level] = G->basicOrbit[level];
      oldSchreierVec[level] = G->schreierVec[level];
      G->basicOrbit[level] = allocIntArrayDegree();
      G->schreierVec[level] = allocPtrArrayDegree();
   }

   /* Here we record the order of G, and then modify it to remove the
      contribution of the basic orbits at levels newLevel and above.  We
      also set these basic orbit lengths to 1. */
   oldOrder = *G->order;
   for ( level = newLevel ; level < G->baseSize ; ++level ) {
      oldLen = factorize( oldBasicOrbLen[level]);
      factDivide( G->order, &oldLen);
      G->basicOrbLen[level] = 1;
   }
   G->basicOrbLen[G->baseSize] = 1;

   /* Here we adjust the levels of the generators of G.  Generators not
      essential at some level less than newLevel are flagged for later
      removal by setting their level to 0.  These generators cannot be
      deleted now because their invImage fields are still needed below.
      However, the image field will be deleted now unless it is the
      invImage field of another generator (i.e., unless the
      inversePermutation field is nonnull.  (Note that temporarily
      we have an invalid data structure for permutations.)  We also flag
      those integers i with i >= newLevel for which there remains a
      generator at level i. */
   for ( level = newLevel ; level <= G->baseSize ; ++level )
      isGenAtLevel[level] = FALSE;
   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( ESSENTIAL_BELOW_LEVEL(gen,newLevel) ) {
         if ( gen->level >= newLevel ) {
            gen->level = (gen->image[newBasePoint] != newBasePoint ) ?
                         newLevel : (gen->level + 1);
            isGenAtLevel[gen->level] = TRUE;
         }
      }
      else {
         gen->level = 0;
         if ( gen->image != gen->invImage ) {
            freeIntArrayDegree( gen->image);
            gen->image = NULL;
         }
         MAKE_NOT_ESSENTIAL_ALL( gen);
      }

   /* Now we construct the initial basic orbits at levels newLevel and
      higher, using any old generators retained because they were
      essential at a higher level. Note constructBasicOrbit must
      must flag essential generators.  We also adjust the order of G*/
   for ( level = newLevel ; level <= G->baseSize ; ++level )
      if ( isGenAtLevel[level] )
         constructBasicOrbit( G, level, "FindEssential");
      else {
         G->basicOrbit[level][1] = G->base[level];
         for ( pt = 1 ; pt <= G->degree ; ++pt )
            G->schreierVec[level][pt] = NULL;
         G->schreierVec[level][G->base[level]] = FIRST_IN_ORBIT;
      }

   /* Now we repeatedly construct and test random elements of G^(newLevel)
      until the product of the basic orbit lengths is large enough, i.e.,
      until newOrder = oldOrder. */
   while ( !factEqual( &oldOrder, G->order) ) {

      /* Set randGen to a random permutation of G^(newLevel). */
      for ( i = 1 ; i <= G->degree ; ++i )
         randGen->image[i] = i;
      for ( level = newLevel ; level < G->baseSize ; ++level ) {
         ++loopCount;                       /* These four lines shouldn't */
         if ( loopCount % 37 == 0  ||       /* be needed.  They overcome */
              loopCount % 181 == 0 )        /* a deficiency in the random */
            randInteger(1,2);               /* number generator. */
         pt = oldBasicOrbit[level][ randInteger(1,oldBasicOrbLen[level]) ];
         svec = oldSchreierVec[level];
         while ( svec[pt] != FIRST_IN_ORBIT ) {
            REPLACE_BY_INV_IMAGE( randGen->image, svec[pt], G->degree,
                                  temp1, temp2, temp3, temp4)
            pt = svec[pt]->invImage[pt];
         }
      }

      /* Attempt to factor randGen in terms of the new base.  The loop
         terminates normally with level == G->baseSize+1 if g can be factored,
         and it terminates via the exit statement with level <= G->baseSize
         otherwise. */
      for ( level = newLevel ; level <= G->baseSize ; ++level ) {
         if ( G->schreierVec[level][randGen->image[G->base[level]]] == NULL )
            break;
         while ( randGen->image[G->base[level]] != G->base[level] ) {
            REPLACE_BY_INV_IMAGE( randGen->image,
                           G->schreierVec[level][randGen->image[G->base[level]]],
                           G->degree, temp1, temp2, temp3, temp4)
         }
      }

      /* If randGen could not be factored, we adjoin it (as modified above)
         as a strong generator relative to the new base.  Note that the level of
         randGen is the current value of the variable level.  If randperm is
         added, we reallocate it. */
      if ( level <= G->baseSize ) {
         if ( isInvolution( randGen) ) {
            if ( randGen->image != randGen->invImage )
               freeIntArrayDegree( randGen->invImage);
            randGen->invImage = randGen->image;
         }
         else {
            if ( randGen->image == randGen->invImage )
               randGen->invImage = allocIntArrayDegree();
            SET_TO_INVERSE( randGen->image, randGen->invImage, G->degree,
                            temp1, temp2, uTemp1, uTemp2, uTemp3)
         }
         addStrongGenerator( G, randGen, newLevel==1);
         randGen = newIdentityPerm( G->degree);
      }
   }

   /* Now we free the old basic orbit vectors and Schreier vectors, as well as
      the permutation randGen. */
   for ( level = newLevel ; level < G->baseSize ; ++level ) {
      freeIntArrayDegree( oldBasicOrbit[level]);
      freePtrArrayDegree( oldSchreierVec[level]);
   }
   deletePermutation( randGen);

   /* Now we remove generators flagged for removal above.  Note we cannot
      employ deletePermutation because we do not have a valid permutation
      data structure, as noted above.  */
   gen = G->generator;
   while ( gen )
      if ( gen->level == 0 ) {
         if ( gen->last )
            gen->last->next = gen->next;
         else
            G->generator = gen->next;
         if ( gen->next )
            gen->next->last = gen->last;
         tempGen = gen;
         gen = gen->next;
         freeIntArrayDegree( tempGen->invImage);
         freePermutation( tempGen);
      }
      else
         gen = gen->next;

   /* Finally we remove redundant base points at level newLevel+1 or greater. */
   for ( level = newLevel+1 ; level <= G->baseSize ; ++level )
      if ( G->basicOrbLen[level] == 1 ) {
         --G->baseSize;
         freeIntArrayDegree( G->basicOrbit[level]);
         freePtrArrayDegree( G->schreierVec[level]);
         for ( i = level ; i <= G->baseSize ; ++i ) {
            G->base[i] = G->base[i+1];
            G->basicOrbLen[i] = G->basicOrbLen[i+1];
            G->basicOrbit[i] = G->basicOrbit[i+1];
            G->schreierVec[i] = G->schreierVec[i+1];
         }
         for ( gen = G->generator ; gen ; gen = gen->next )
            if ( gen->level > level ) {
               --gen->level;
               for ( i = level ; i <= G->baseSize ; ++i )
                  if ( ESSENTIAL_AT_LEVEL(gen,i+1) )
                     MAKE_ESSENTIAL_AT_LEVEL(gen,i);
                  else
                     MAKE_NOT_ESSENTIAL_AT_LEVEL(gen,i);
               MAKE_NOT_ESSENTIAL_AT_LEVEL(gen,G->baseSize+1);
            }
         --level;
      }

   freeIntArrayBaseSize( oldBasicOrbLen);
   freePtrArrayBaseSize( oldBasicOrbit);
   freePtrArrayBaseSize( oldSchreierVec);
   freeBooleanArrayBaseSize( isGenAtLevel);
}


/*-------------------------- changeBase -----------------------------------*/

/* The function changeBase changes the base (and updates the strong
   generating set) for a permutation group with known base and strong
   generating set. */

void changeBase(
   PermGroup *G,        /* The permutation group. */
   UnsignedS *newBase)  /* An origin-1 null-terminated sequence of points. */
                        /*   The new base will consist of newBase, followed */
                        /*   by arbitrary extra points as needed.  Redundant */
                        /*   base points will not be deleted from newBase,  */
                        /*   but no redundant points will be adjoined.      */
{
   Unsigned level;

   for ( level = 1 ; newBase[level] ; ++level )
      if ( level > G->baseSize || G->base[level] != newBase[level] )
         insertBasePoint( G, level, newBase[level]);
}


/*-------------------------- constructCandidateList -----------------------*/

/* This static function constructCandidateList( G, level) is called only by
   function removeRedunSGens.  It constructs and returns an xNext-linked list
   of all generators of G at level level or above, ordered so that presumably
   "desirable" generators occur first.  The ordering is as follows:
      0)  Generators essential at levels level-1 or higher come first.
      1)  A single generator at level level, if not present in (1) above, comes
          next.
      2)  Generators essential at levels level+1,..,G->baseSize come next.
      3)  Any remaining generators at level level come next.
      4)  Finally, any remaining generators at levels level+1,...,G->baseSize
          come last.
   At a given level, involutory generators precede noninvolutory ones.
   Note the xLast field is used as a flag here; a null value signifies that
   the generator is not to be considered for addition to the list, either
   because it has level below level or it is already on the list. */

#define ADD_TO_LIST(i)    \
      (gen->xLast = NULL , gen->image == gen->invImage) ?    \
         ( gen->xNext = listHeader[2*i] , listHeader[2*i] = gen ) :   \
         ( gen->xNext = listHeader[2*i+1]   , listHeader[2*i+1]   = gen )


static Permutation *constructCandidateList(
   PermGroup *G,
   const Unsigned level)
{
   Unsigned m;
   Permutation *listHeader[10] = {NULL}, *combinedList, *endPreviousList, *gen;
   BOOLEAN     genAtLevelAdded = FALSE;

   /* Initializer xLast, as above. */
   for ( gen = G->generator ; gen ; gen = gen->next )
      gen->xLast =  ( gen->level >= level ) ? (Permutation *) TRUE : NULL;

   /* First we add any generators in class (0) above. */
   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( gen->xLast && ESSENTIAL_BELOW_LEVEL(gen,level) ) {
         ADD_TO_LIST(0);
         if ( gen->level == level )
            genAtLevelAdded = TRUE;
      }

   /* Next we add a possible generator in class (1) above. */
   if ( !genAtLevelAdded )
      for ( gen = G->generator ; gen ; gen = gen->next )
         if ( gen->xLast && gen->level == level ) {
            ADD_TO_LIST(1);
            break;
         }

   /* Next we add any generators in class (2) above. */
      for ( gen = G->generator ; gen ; gen = gen->next )
         if ( gen->xLast && ESSENTIAL_ABOVE_LEVEL(gen,level) )
            ADD_TO_LIST(2);

   /* Next we add any generators in class (3) above. */
      for ( gen = G->generator ; gen ; gen = gen->next )
         if ( gen->xLast && gen->level == level )
            ADD_TO_LIST(3);

   /* Finally we add any generators in class (4) above. */
      for ( gen = G->generator ; gen ; gen = gen->next )
         if ( gen->xLast )
            ADD_TO_LIST(4);

   /* Finally we concatenate the lists. */
   combinedList = NULL;
   endPreviousList = NULL;
   for ( m = 0 ; m <= 9 ; ++ m )
      if ( listHeader[m] ) {
         if ( endPreviousList )
            endPreviousList->xNext = listHeader[m];
         else
            combinedList = listHeader[m];
         for ( endPreviousList = listHeader[m] ;
               endPreviousList->xNext ;
               endPreviousList = endPreviousList->xNext )
            ;
         endPreviousList->xNext = NULL;
      }

   /* Return a pointer to the list. */
   return combinedList;
}


/*-------------------------- removeRedunSGens -----------------------------*/

/* The function removeRedunSGens( G, startLevel) removes redundant strong
   generators from the group G at levels startLevel,startLevel+1,..,G->baseSize.
   The essential fields at levels 1,...,startLevel-1 must be set; the function
   sets those at other levels.  Inverse permutations must not yet have been
   added.  The function returns the number of generators removed. */

Unsigned removeRedunSGens(
   PermGroup *G,
   Unsigned startLevel)
{
   Unsigned level, correctOrbLen, pt;
   Unsigned removalCount = 0;
   Permutation *gen, *firstGen, *newGen, *tempGen;
   FactoredInt factoredOrbLen;

   /* Flag all generators as nonessential at levels startLevel,startLevel+1,...,
      G->baseSize. */
   for ( gen = G->generator ; gen ; gen = gen->next )
      MAKE_NOT_ESSENTIAL_ATABOV_LEVEL( gen, startLevel);

   /* Reconstruct basic orbits and Schreier vectors at levels G->baseSize,...,
      startLevel until each orbit has correct length. */
   for ( level = G->baseSize ; level >= startLevel ; --level ) {
      correctOrbLen = G->basicOrbLen[level];
      firstGen = constructCandidateList( G, level);
      factoredOrbLen = factorize( G->basicOrbLen[level]);
      factDivide( G->order, &factoredOrbLen);
      G->basicOrbLen[level] = 1;
      G->basicOrbit[level][1] = G->base[level];
      for ( pt = 1 ; pt <= G->degree ; ++pt )
         G->schreierVec[level][pt] = NULL;
      G->schreierVec[level][G->base[1]] = FIRST_IN_ORBIT;
      while ( G->basicOrbLen[level] < correctOrbLen ) {
         newGen = genExpandingBasicOrbit( &firstGen, G->basicOrbLen[level],
                                G->basicOrbit[level], G->schreierVec[level]);
         MAKE_ESSENTIAL_AT_LEVEL(newGen,level);
         constructBasicOrbit( G, level, "KnownEssential" );
      }
   }

   /* Free generators that are not essential at any level. */
   gen = G->generator;
   while ( gen )
      if ( ! ESSENTIAL_BELOW_LEVEL(gen,G->baseSize+1 ) ) {
         if ( gen->last )
            gen->last->next = gen->next;
         else
            G->generator = gen->next;
         if ( gen->next )
            gen->next->last = gen->last;
         tempGen = gen;
         gen = gen->next;
         deletePermutation( tempGen);
         ++removalCount;
      }
      else
         gen = gen->next;

   /* Return to caller. */
   return removalCount;
}


/*-------------------------- restrictBasePoints ---------------------------*/

/* The function restrictBasePoints( G, acceptablePoint) attempts to change
   the base for G so that all base points lie in the 1-based null-terminated
   list acceptablePoint of points.  It produces a base of the form        
   a[1],...,a[m],a[m+1],...,a[k], where a[1],...,a[m] lie in the list of
   acceptable points and where any permutation in G^(m+1) fixes any point in 
   the list.  It returns m. */

Unsigned restrictBasePoints(
   PermGroup *const G,
   Unsigned *acceptablePoint)
{
   Unsigned level, i, pt;
   char *isAcceptable;

   isAcceptable = allocBooleanArrayDegree();
   for ( i = 1 ; i <= G->degree ; ++i )
      isAcceptable[i] = FALSE;
   for ( i = 1 ; acceptablePoint[i] != 0 ; ++i )
      isAcceptable[acceptablePoint[i]] = TRUE;
      
   for ( level = 1 ; level <= G->baseSize ; ++level ) 
      if ( !isAcceptable[G->base[level]] )  {
         for ( i = 1 ; (pt = acceptablePoint[i]) != 0 ; ++i ) 
            if ( !isFixedPointOf( G, level, pt) ) {
               insertBasePoint( G, level, pt);
               break;
            }
         if ( pt == 0 ) {
            freeBooleanArrayDegree( isAcceptable);
            return level-1;
         }
      }

   freeBooleanArrayDegree( isAcceptable);
   return G->baseSize;
}
