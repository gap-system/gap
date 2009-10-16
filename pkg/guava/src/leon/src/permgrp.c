/* File permgrp.c.  Contains miscellaneous short functions for computing with
   permutation groups, as follows:

      isNontrivialGroup: Returns true if a permutation group has order at
                         least 2.  A base/sgs are not needed.

      levelIn:           Returns the level of a permutation relative to the
                         base of a given permutation group.

      isIdentityElt:     Returns true is an element of a group with known base
                         is an involution (fast test).

      isInvolutoryElt:   Returns true is an element of a group with known base
                         is an involution (fast test).  */

#include <stddef.h>
#include <ctype.h>
#include <string.h>

#include "group.h"

#include "copy.h"
#include "errmesg.h"
#include "essentia.h"
#include "new.h"
#include "permut.h"
#include "storage.h"

extern GroupOptions options;

CHECK( permgr)


/*-------------------------- genCount -------------------------------------*/

/* This function may be used to determine the total number of generators, and
   the number of known involutory generators, in a permutation group.  The
   function returns the total number of generators and sets the second
   parameter to the number of involutory generators.  Note the function assumes
   inverse generators are present as permutations on the linked list of
   generators, unless involCount == NULL. */

Unsigned genCount(
   const PermGroup *const G,           /* The permutation group. */
   Unsigned *involCount)              /* If nonnull, set to number of
                                          involutory generators. */
{
   Unsigned totalCount = 0, tempInvolCount = 0;
   Permutation *gen;

   for ( gen = G->generator ; gen ; gen = gen->next ) {
      ++totalCount;
      if ( isInvolution( gen) )
         ++tempInvolCount;
   }

   if ( involCount )
      *involCount = tempInvolCount;

   return tempInvolCount + (totalCount - tempInvolCount) / 2;
}


/*-------------------------- isFixedPointOf -------------------------------*/

/* The function isFixedPointOf( G, level, point) returns true if the point
   point is a fixed point of G^(level), and it returns false otherwise. */

BOOLEAN isFixedPointOf(
   const PermGroup *const G,   /* A group with known base and sgs. */
   const Unsigned level,       /* The level mentioned above. */
   const Unsigned point)       /* Check if this point is a fixed point. */
{
   Permutation *gen;

   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( gen->level >= level && gen->image[point] != point )
         return FALSE;

   return TRUE;
}


/*-------------------------- isNontrivialGroup ----------------------------*/

/* This function returns true if a permutation group has order at least 2 and
   false if it has order 1.  A base/sgs are not needed. */

BOOLEAN isNontrivialGroup(
   PermGroup *G)              /* The permutation group to test. */
{
   Permutation *gen;
   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( !isIdentity( gen) )
         return TRUE;
   return FALSE;
}


/*-------------------------- levelIn --------------------------------------*/

/* This function returns the level of a permutation relative to the
   sequence of points in the array base of a permutation group.  (The array
   need not actually be a base.)  If the permutation fixes the "base", the
   value returned is 1+baseSize. */

Unsigned levelIn(
   PermGroup *G,           /* The perm group (base and baseSize filled in). */
   Permutation *perm)      /* The permutation whose level is returned. */
{
   Unsigned level;
   for ( level = 1 ; level <= G->baseSize && perm->image[G->base[level]] ==
         G->base[level] ; ++level )
      ;
   return level;
}


/*-------------------------- isIdentityElt --------------------------------*/

/* This function returns true if a given permutation known to lie in a group
   with known base is the identity, and false otherwise.  The function is
   fast, as the permutation need be applied only to the base. */

BOOLEAN isIdentityElt(
   PermGroup *G,           /* The permutation group (base known). */
   Permutation *perm)      /* The permutation known to lie in G. */
{
   Unsigned i;

   if ( !IS_SYMMETRIC(G) ) {
      for ( i = 1 ; i <= G->baseSize && perm->image[G->base[i]] ==
                                        G->base[i] ; ++i )
         ;
      return i > G->baseSize;
   }
   else {
      for ( i = 1 ; i <= G->degree && perm->image[i] == i ; ++i )
         ;
      return i > G->degree;
   }
}


/*-------------------------- isInvolutoryElt ------------------------------*/

/* This function returns true if a given permutation known to lie in a group
   with known base is an involution, and false otherwise.  The function is
   fast, as the permutation need be applied only to the base. */

BOOLEAN isInvolutoryElt(
   PermGroup *G,           /* The permutation group (base known). */
   Permutation *perm)      /* The permutation known to lie in G. */
{
   Unsigned i;
   for ( i = 1 ; i <= G->baseSize && perm->image[perm->image[G->base[i]]] ==
         G->base[i] ; ++i )
      ;
   return i > G->baseSize;
}


/*-------------------------- fixesBasicOrbit ------------------------------*/

/* The function fixesBasicOrbit( G, level, perm) returns true if permutation
   perm fixes (setwise) the level'th basic orbit or permutation group G and
   returns false otherwise.  Note:  The basic orbit need not be correct. */

BOOLEAN fixesBasicOrbit(
   const PermGroup *const G,
   const Unsigned level,
   const Permutation *const perm)
{
   Unsigned i;
   UnsignedS *basicOrbit = G->basicOrbit[level];
   Permutation **svec = G->schreierVec[level];

   for ( i = 1 ; i <= G->basicOrbLen[level] ; ++i )
      if ( ! svec[ perm->image[basicOrbit[i]] ] )
         return FALSE;
   return TRUE;
}


/*-------------------------- linkEssentialGens ----------------------------*/

/* This function constructs a singly linked list of all the generators of a
   permutation group essential at a specified level, using the xNext field
   of the generating permutations.  It returns a pointer to the head
   permutation on the list.  The field essential of each generator must be
   filled in. */

Permutation *linkEssentialGens(
   PermGroup *G,                   /* The permutation group. */
   Unsigned level)                 /* Generators essential at this level are
                                      linked. */
{
   Permutation *listHeader = NULL, *previousGen = NULL, *gen;

   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( ESSENTIAL_AT_LEVEL(gen,level) ) {
         if ( previousGen )
            previousGen->xNext = gen;
         else
            listHeader = gen;
         gen->xNext = NULL;
         previousGen = gen;
      }

   return listHeader;
}


/*-------------------------- assignGenName -------------------------------*/

/* This function assigns a name to a generator for a permutation group.  The
   name chosen is <options.genNamePrefix>zz, where zz is the 2-digit ASCII 
   representation of the smallest  positive integer not currently in use for
   a generator name.  However, if <options.genNamePrefix> is *, then the name
   will be a single letter, the first not currently in use, or two identical
   letters, if all single letters are in use.  The function terminates with
   an error message if all possible names are already in use. */

void assignGenName(
   PermGroup *const G,
   Permutation *const gen)
{
   char inUse[256];
   char *letter = "abcdefghijklmnopqrstuvwxyz";
   Unsigned i, prefixLen;
   char let1, let2;
   Permutation *oldGen;

   if ( strcmp(options.genNamePrefix,"*") == 0 ) {
      for ( i = 0 ; i < 26 ; ++i ) {
         inUse[letter[i]] = FALSE;
         inUse[letter[i]-64] = FALSE;      /* OK for ASCII and EBCDIC. */
      }
      for ( oldGen = G->generator ; oldGen ; oldGen = oldGen->next ) {
         let1 = tolower( oldGen->name[0]);
         let2 = tolower( oldGen->name[1]);
         if ( strlen(oldGen->name) == 1 )
            inUse[let1] = TRUE;
         else if ( strlen(oldGen->name) == 2 && let1 == let2 & let1 >= 64 )
            inUse[let1-64] = TRUE;
      }
      for ( i = 0 ; i < 26 ; ++i )
         if ( !inUse[letter[i]] ) {
            gen->name[0] = letter[i];
            gen->name[1] = '\0';
            return ;
         }
      for ( i = 0 ; i < 26 ; ++i )
         if ( !inUse[letter[i]-64] ) {
            gen->name[0] = letter[i];
            gen->name[1] = letter[i];
            gen->name[2] = '\0';
            return ;
         }
      ERROR( "assignGenName", "No more generator names are available.")
   }
            
   else{
      for ( i = 1 ; i <= 99 ; ++i )
         inUse[i] = 0;
      prefixLen = strlen( options.genNamePrefix);
      for ( oldGen = G->generator ; oldGen ; oldGen = oldGen->next ) 
         if ( strncmp( oldGen->name, options.genNamePrefix, prefixLen) == 0 &&
              oldGen->name[prefixLen] == i / 10 + '0' &&
              oldGen->name[prefixLen+1] == i % 10 + '0' )
            inUse[i] = TRUE;
      for ( i = 1 ; i <= 99 ; ++i )
         if ( !inUse[i] ) {
            strcpy( gen->name, options.genNamePrefix);
            gen->name[prefixLen] = i / 10 + '0';
            gen->name[prefixLen+1] = i % 10 + '0';
            gen->name[prefixLen+2] = '\0';
            return;
         }
      ERROR( "assignGenName", "No more generator names are available.")
   }
}   



/*-------------------------- adjoinInverseGen ----------------------------*/

void adjoinInverseGen(
   PermGroup *const G,
   Permutation *gen)    /* Must be a generator of G, and must have invImage. */
{
   Permutation *invGen;

   if ( !gen->invPermutation )
      if ( gen->image == gen->invImage )
         gen->invPermutation = gen;
      else {
         invGen = allocPermutation();
         gen->invPermutation = invGen;
         invGen->invPermutation = gen;
         strcpy( invGen->name, "*");
         invGen->degree = gen->degree;
         invGen->level = gen->level;
         MAKE_NOT_ESSENTIAL_ALL( invGen);
         invGen->image = gen->invImage;
         invGen->invImage = gen->image;
         invGen->last = NULL;
         invGen->next = G->generator;
         G->generator->last = invGen;
         G->generator = invGen;
      }
}


/*-------------------------- depthGreaterThan ----------------------------*/

/* This function tests rather the "depth" of a group G exceeds a specified
   integral value comparisonDepth.  Here the depth of G is defined to be
   log(|G|) / log(degree(G)).  The function returns true if the depth of
   G exceeds comparisonDepth and false otherwise.  Overflow should occur
   only if (degree(G))^comparisonDepth is out of bounds.  If the NOFLOAT
   option is given, the computation is approximate. */


BOOLEAN depthGreaterThan(
   const PermGroup *const G,
   const Unsigned comparisonDepth)
{
   int i, j;

#ifndef NOFLOAT
   double ratio = 1.0;

   /* Handle symmetric group.  (Always return true -- tecnically wrong.) */
   if ( IS_SYMMETRIC(G) )
      return TRUE;

   for ( i = 1 ; i <= comparisonDepth ; ++i )
      ratio /= (double) G->degree;

   for ( i = 0 ; i < G->order->noOfFactors ; ++i )
      for ( j = 1 ; j <= G->order->exponent[i] ; ++j ) {
         ratio *= (double) G->order->prime[i];
         if ( ratio > 1.0 )
            return TRUE;
      }
#endif

#ifdef NOFLOAT
   int cDepth = comparisonDepth;
   unsigned long product = 1;

   /* Handle symmetric group.  (Always return true -- tecnically wrong.) */
   if ( IS_SYMMETRIC(G) )
      return TRUE;

   for ( i = 0 ; i < G->order->noOfFactors ; ++i )
      for ( j = 1 ; j <= G->order->exponent[i] ; ++j ) {
         product *= G->order->prime[i];
         if ( product >= G->degree ) {
            product = (product + G->degree / 2) / G->degree;
            --cDepth;
            if ( cDepth <= 0 )
               return TRUE;
         }
      }
#endif

   return FALSE;
}


/*-------------------------- isDoublyTransitive --------------------------*/

/* This function tests whether a group G is doubly transitive.  A base and
   strong generating set for G must be available (not checked). */


BOOLEAN isDoublyTransitive(
   const PermGroup *const G)
{
   return  G->baseSize >= 2 && G->basicOrbLen[2] == G->degree - 1;
}


/*-------------------------- conjugatePermByPerm -------------------------*/

/* This function may be used to conjugate one permutation by another.  The
   permutation perm is replaced by conjPerm^-1 * perm * conjPerm.  It is
   assumed that both permutations have the same degree. */

void conjugatePermByPerm(
   Permutation *const perm,
   const Permutation *const conjPerm)
{
   Unsigned pt;
   Unsigned *tempPerm = allocIntArrayDegree();

   for ( pt = 1 ; pt <= perm->degree ; ++pt )
      tempPerm[pt] = perm->image[pt];
   for ( pt = 1 ; pt <= perm->degree ; ++pt )
      perm->image[conjPerm->image[pt]] = conjPerm->image[tempPerm[pt]];
   if ( perm->invImage )
      for ( pt = 1 ; pt <= perm->degree ; ++pt )
         perm->invImage[perm->image[pt]] = pt;
   freeIntArrayDegree( tempPerm);
}


/*-------------------------- conjugateGroupByPerm ------------------------*/

/* This function may be used to conjugate a permutation group by a permutation.
   The permutation group G is replaced by conjPerm^-1 * G * conjPerm.  It is
   assumed that the group and the permutation have the same degree.  The
   complete   The completeOrbit, orbNumberOfPt, and startOfOrbitNo fields are
   not currently handled, nor are omega and invOmega. */

void conjugateGroupByPerm(
   PermGroup *const G,
   const Permutation *const conjPerm)
{
   Unsigned level, i, pt;
   Permutation *gen;
   Permutation **tempSVec, **temp;

   /* Conjugate the base, basic orbits, and Schreier vectors. */
   if ( G->base ) {
      tempSVec = (Permutation **) allocPtrArrayDegree();
      for ( level = 1 ; level <= G->baseSize ; ++level ) {
         G->base[level] = conjPerm->image[G->base[level]];
         for ( i = 1 ; i <= G->basicOrbLen[level] ; ++i )
             G->basicOrbit[level][i] = conjPerm->image[G->basicOrbit[level][i]];
         for ( pt = 1 ; pt <= G->degree ; ++pt )
            tempSVec[conjPerm->image[pt]] = G->schreierVec[level][pt];
         EXCHANGE( G->schreierVec[level], tempSVec, temp);
      }
      freePtrArrayDegree( tempSVec);
   }

   /* Conjugate generators. */
   for ( gen = G->generator ; gen ; gen = gen->next )
      conjugatePermByPerm( gen, conjPerm);
}


/*-------------------------- checkConjugacyInGroup  ------------------------------*/

/* The function checkConjugacyInGroup( G, e, f, conjPerm) returns true if
   permutation  conjPerm in G conjugates permutation e in group G to permutation
   f in G, that is, if  e ^ conjPerm = f, or equivalently,
   e * conjPerm = conjPerm * f.  It is assumed G has a base and strong
   generating set. */

BOOLEAN checkConjugacyInGroup(
   const PermGroup *const G,
   const Permutation *const e,
   const Permutation *const f,
   const Permutation *const conjPerm)
{
   int i;

   for ( i = 1 ; i <= G->baseSize ; ++i )
      if ( conjPerm->image[e->image[G->base[i]]] !=
                 f->image[conjPerm->image[G->base[i]]] )
         return FALSE;
   return TRUE;
}


/*-------------------------- isElementOf -----------------------------------------*/

/* The function isElementOf( perm, group) returns true is the permutation
   perm lies in the group G and false otherwise.  The group must already
   have a base and strong generating set.  This procedure is not particularly
   efficient:  It does a great deal of unnecessary multiplications
   if containment turns out not to hold. */

BOOLEAN isElementOf(
   const Permutation *const perm,
   const PermGroup *const group)
{
   Permutation *gen, *perm1;
   Unsigned level, gamma;
   BOOLEAN returnValue;

   /* Check that the group has a base.  If not, give error message. */
   if ( group->base == NULL)
      ERROR1s( "isElementOf", "Group ", group->name, " must have a base.")

   /* Make a copy of permutation perm. */
   perm1 = copyOfPermutation( perm);

   /* Now attempt to factor perm1.  If process breaks down because the
      appropriate point is not in the required basic orbit, return false
      immediately. */
   for ( level = 1 ; level <= group->baseSize ; ++level) {
      gamma = perm1->image[group->base[level]];
      while ( (gen = group->schreierVec[level][gamma]) != NULL &&
               gen != FIRST_IN_ORBIT ) {
         rightMultiplyInv( perm1, gen);
         gamma = gen->invImage[gamma];
      }
      if ( gen == NULL ) {
         deletePermutation( perm1);
         return FALSE;
      }
   }

   /* If all the appropriate points lie in the correct basic orbits, return
      true if and only if the remaining permutation is the identity. */
   returnValue = isIdentity( perm1);
   deletePermutation( perm1);
   return returnValue;
}



/*-------------------------- isSubgroupOf ----------------------------------------*/

/* The function isSubgroupOf( subGroup, group) returns true if subGroup
   is a subgroup of group and returns false otherwise.  The degrees of the
   groups must be equal.  It is not too efficient because it checks all
   (possibly strong) generators of subGroup.  Note group must have a
   base and strong generating set, but subGroup need not. */

BOOLEAN isSubgroupOf(
   const PermGroup *const subGroup,
   const PermGroup *const group)
{
   Permutation *gen;

   /* Check that the group has a base.  If not, give error message. */
   if ( group->base == NULL)
      ERROR1s( "isElementOf", "Group ", group->name, " must have a base.")

   /* Now check each generator of subGroup for containment in group. */
   for ( gen = subGroup->generator ; gen ; gen = gen->next )
      if ( !isElementOf(gen,group) )
         return FALSE;
   return TRUE;
}


/*-------------------------- isNormalizedBy --------------------------------------*/

/* The function isNormalizedBy( group, nGroup) returns true if group
   is normalized by nGroup and returns false otherwise.  The degrees of the
   groups must be equal.  It is inefficient because it checks all
   (possibly strong) generators of group conjugated by all (possibly strong)
   generators of nGroup and, more importantly, it does NOT take advantage of 
   any prior knowledge that group is a subgroup of nGroup.  Note group must 
   have a base and strong generating set, but nGroup need not. */

BOOLEAN isNormalizedBy(
   const PermGroup *const group,
   const PermGroup *const nGroup)
{
   Permutation *gen, *nGen, *perm = newIdentityPerm( group->degree);
   BOOLEAN involFlag;
   Unsigned pt;

   /* Check that the group has a base.  If not, give error message. */
   if ( group->base == NULL)
      ERROR1s( "isElementOf", "Group ", group->name, " must have a base.")

   /* Now check each conjugage of each generator of group for containment in 
      nGroup. */
   for ( gen = group->generator ; gen ; gen = gen->next ) {
      involFlag = isInvolution( gen);
      if ( involFlag && perm->invImage != perm->image ) {
         freeIntArrayDegree( perm->invImage);
         perm->invImage = perm->image;
      }
      else if ( !involFlag && perm->invImage == perm->image )
         perm->invImage = allocIntArrayDegree();
      for ( nGen = nGroup->generator ; nGen ; nGen = nGen->next ) {
         for ( pt = 1 ; pt <= group->degree ; ++pt )
            perm->image[nGen->image[pt]] = nGen->image[gen->image[pt]];
         if ( !involFlag )
            for ( pt = 1 ; pt <= group->degree ; ++pt )
               perm->invImage[perm->image[pt]] = pt;
         if ( !isElementOf(perm,group) ) {
            freePermutation( perm);
            return FALSE;
         }
      }
   }

   freePermutation( perm);
   return TRUE;
}


/*-------------------------- isCentralizedBy --------------------------------*/

/* The function isCentralizedBy( group, cGroup) returns true if group
   is centralized by cGroup and returns false otherwise.  The degrees of the
   groups must be equal.  It is inefficient because it checks all pairs of
   (possibly strong) generators from the two groups and, more importantly, it 
   does NOT take advantage of any prior knowledge of the bases of the two 
   groups (as would be possible when one is contained in the other). */

BOOLEAN isCentralizedBy(
   const PermGroup *const group,
   const PermGroup *const cGroup)
{
   Permutation *gen, *cGen;
   Unsigned pt;

   /* Check equality of degrees. */
   if ( group->degree != cGroup->degree )
      ERROR( "isCentralizedBy", "Groups do not have same degree.")

   /* Check each generator of group commutes with each generator of cGroup. */
   for ( gen = group->generator ; gen ; gen = gen->next ) 
      for ( cGen = cGroup->generator ; cGen ; cGen = cGen->next ) 
         for ( pt = 1 ; pt <= group->degree ; ++pt )
            if ( cGen->image[gen->image[pt]] != gen->image[cGen->image[pt]] )
               return FALSE;

   return TRUE;
}


/*-------------------------- isBaseImage -----------------------------------------*/

/* The function isBaseImage( G, image), where G is a permutation group having
   a base and strong generating set and where image is an array of points of
   length G->baseSize, returns true if there exists a permutation in G mapping
   the base to the sequence image, and returns false otherwise. */

BOOLEAN isBaseImage(
   const PermGroup *const G,
   const Unsigned image[])
{
   Unsigned level, i, t;
   UnsignedS *img = allocIntArrayBaseSize();

   for ( level = 1 ; level <= G->baseSize ; ++level )
      img[level] = image[level];

   for ( level = 1 ; level <= G->baseSize ; ++level ) {
      if ( G->schreierVec[level][img[level]] == NULL ) {
         freeIntArrayBaseSize( img);
         return FALSE;
      }
      while ( img[level] != G->base[level] ) {
         t = img[level];
         for ( i = level ; i <= G->baseSize ; ++i )
            img[i] = G->schreierVec[level][t]->invImage[img[i]];
      }
   }

   freeIntArrayBaseSize( img);
   return TRUE;
}


/*-------------------------- reduceWrtGroup --------------------------------*/

/* The function reduceWrtGroup( G, h, reductionLevel), where G is a
   permutation group with base and strong generating set and where h is a
   permutation (with inverse image) replaces h by
                   h u_1[d_1]^-1 u_2[d_2]^-1 u_j-1[d_j-1]^-1,
   where the new h fixes the first j-1 base points of G, and where the
   new h maps the j'th base point outside the j'th basic orbit, or where
   j = G->baseSize+1.  Unless reductionLevel = NULL, it sets *reductionLevel
   to j. */

void reduceWrtGroup(
   const PermGroup *const G,
   Permutation *const h,
   Unsigned *reductionLevel)
{
   int level;

   for ( level = 1 ; level <= G->baseSize &&
          G->schreierVec[level][h->image[G->base[level]]] != NULL ; ++level )
      while ( h->image[G->base[level]] != G->base[level] )
         rightMultiplyInv( h, G->schreierVec[level][h->image[G->base[level]]]);

   if ( reductionLevel )
      *reductionLevel = level;
}
