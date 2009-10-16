/* File optsvec.c. */

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include "group.h"

#include "cstborb.h"
#include "essentia.h"
#include "new.h"
#include "permut.h"
#include "permgrp.h"
#include "storage.h"

CHECK( optsve)

extern GroupOptions options;

/* Bug fix for Waterloo C (IBM 370). */
#if defined(IBM_CMS_WATERLOOC) && !defined(SIGNED) && !defined(EXTRA_LARGE)
#define FIXUP1 short
#define FIXUP2 (short)
#else
#define FIXUP1 Unsigned
#define FIXUP2
#endif


/*-------------------------- meanCosetRepLen ------------------------------*/

void meanCosetRepLen(
   const PermGroup *const G)
{
   Unsigned  level, pt, i, totalCount, involCount;
   unsigned long  totalLen;
   UnsignedS  *cosetRepLen = allocIntArrayDegree();
#ifdef NOFLOAT
   unsigned long intQuot, decQuot;
#endif

   /* Do nothing for symmetric group. */
   if ( IS_SYMMETRIC(G) )
      return;

   totalCount = genCount( G, &involCount);
   printf( "%u generators (%u involutory).\n", totalCount, involCount),
   printf( "Mean node depth Schreier tree:");
   for ( level = 1 ; level <= G->baseSize ; ++level ) {
      for ( i = 1 ; i <= G->basicOrbLen[level] ; ++i )
         cosetRepLen[G->basicOrbit[level][i]] = 0;
      totalLen = 0;
      for ( i = 2 ; i <= G->basicOrbLen[level] ; ++i ) {
         pt = G->basicOrbit[level][i];
         cosetRepLen[pt] = 1 + cosetRepLen[
                           G->schreierVec[level][pt]->invImage[pt] ];
         totalLen += cosetRepLen[pt];
      }
#ifndef NOFLOAT
      printf( " %4.2lf", (double) totalLen / G->basicOrbLen[level] );
#endif
#ifdef NOFLOAT
      intQuot = (unsigned long) totalLen / G->basicOrbLen[level];
      decQuot = (totalLen - G->basicOrbLen[level] * intQuot) * 100;
      decQuot /= G->basicOrbLen[level];
      printf( " %2lu.%02lu", intQuot, decQuot );
#endif
   }
   printf( "\n");
   freeIntArrayDegree( cosetRepLen);
}


/*-------------------------- reconstructBasicOrbit ------------------------*/

FIXUP1 reconstructBasicOrbit(  /* Returns word length of longest coset rep. */
   PermGroup *const G,
   const Unsigned level)
{
   Unsigned found = 1,
            processed = 0,
            pt, img, i,
            maxCosetRepLen = 0;
   Permutation *gen, *firstGenAtLevel;
   Permutation **svec = G->schreierVec[level];
   UnsignedS *basicOrbit = G->basicOrbit[level];

   for ( i = 2 ; i <= G->basicOrbLen[level] ; ++i )
      svec[basicOrbit[i]] = NULL;
   firstGenAtLevel = linkGensAtLevel( G, level);
   while ( found < G->basicOrbLen[level] ) {
      pt = basicOrbit[++processed];
      for ( gen = firstGenAtLevel ; gen ; gen = gen->xNext ) {
         img = gen->image[pt];
         if ( !svec[img] ) {
            basicOrbit[++found] = img;
            svec[img] = gen;
         }
      }
   }

   for ( gen = G->generator ; gen ; gen = gen->next )
      for ( i = gen->level ; i >= 1 ; --i )
         MAKE_ESSENTIAL_AT_LEVEL( gen, i);

   for ( pt = basicOrbit[G->basicOrbLen[level]] ; pt != basicOrbit[1] ;
                                                  pt = svec[pt]->invImage[pt] )
      ++maxCosetRepLen;

   return FIXUP2 maxCosetRepLen;
}


/*-------------------------- expandSGS -----------------------------------*/

/* This function adds new strong generators to a strong generating set in
   order to reduce the maximum length of the coset representatives. */

void expandSGS(
   PermGroup *G,
   UnsignedS longRepLen[],
   UnsignedS basicCellSize[],
   Unsigned ell)
{
   Unsigned  r, i, pt, orbLen, involCount, m1, m2, m3, passes, easy,
             numberOfGens = genCount(G, &involCount);
   unsigned long basicCellSizeSum = 0;
   UnsignedS *goal = allocIntArrayBaseSize();
   Permutation *newGen;

   for ( i = 2 ; i <= ell ; ++i )
      basicCellSizeSum += basicCellSize[i];
   easy = (options.maxBaseChangeLevel == 0 ) &&
          G->degree < 10000 &&
          !depthGreaterThan( G, 4) &&
          ell <= 7 &&
          basicCellSizeSum <= G->degree / 10;

   m1 = (options.maxBaseChangeLevel > 1 ) ? 4 :
        (options.maxBaseChangeLevel > 0 ) ? 3 : 2;
   passes = (options.maxBaseChangeLevel > 0 ) ? 2 : 1;
   if ( numberOfGens + 20 >= options.maxStrongGens )
      ++passes;
   for ( r = 1 ; r <= G->baseSize ; ++r ) {
      m2 = ( r == 1 ) ? 4 :
           ( r == 2 ) ? 8 :
           ( r == 3 ) ? 4 :
           ( r == 4 ) ? 2 :
                        1 ;
      orbLen = G->basicOrbLen[r];
      goal[r] = 2 + (orbLen > 8 * m1 * m2) + (orbLen > 512 * m1 * m2) +
                (orbLen > 16383 * m1 );
   }

   for ( m3 = passes ; m3 >= 1 ; --m3 ) {
      for ( r = G->baseSize ; r >= 1 ; --r )
         while ( (longRepLen[r] > 0 ? longRepLen[r] :
                  (longRepLen[r] = reconstructBasicOrbit(G,r))) >
                                                goal[r]+m3-1+easy ) {
            if ( numberOfGens >= options.maxStrongGens )
               break;
            pt = G->basicOrbit[r][G->basicOrbLen[r]];
            newGen = newIdentityPerm( G->degree);
            while ( G->schreierVec[r][pt] != FIRST_IN_ORBIT ) {
               leftMultiply( newGen, G->schreierVec[r][pt] );
               pt = G->schreierVec[r][pt]->invImage[pt];
            }
            newGen->level = r;
            MAKE_NOT_ESSENTIAL_ALL( newGen);
            for ( i = 1 ; i <= r ; ++i ) {
               MAKE_ESSENTIAL_AT_LEVEL(newGen,i);
               longRepLen[i] = 0;
            }
            newGen->next = G->generator;
            G->generator = newGen;
            adjoinInverseGen( G, newGen);
           ++numberOfGens;
         }
      if ( numberOfGens >= options.maxStrongGens )
         break;
   }

   freeIntArrayBaseSize( goal);
}


/*-------------------------- compressGroup --------------------------------*/

/* This function compresses a permutation group for which the complete orbit
   structure.  After compression, the group must remain essentially constant,
   and it may not be freed with deletePermGroup.  During compression,
       1)   G->startOfOrbitNo[i] is reduced to its exact size, whenever its
            exact size is <= half the degree.
       2)   G->basicOrbit[i] is made to point to a location in completeOrbit[i],
            and the contents of G->basicOrbit[i] is transferred to the
            appropriate locations in completeOrbit[i]. */

void compressGroup(
   PermGroup *const G)        /* The group to be compressed. */
{
   Unsigned  d, i, orbitCountPlus1;
   UnsignedS *oldStartOfOrbit, *oldBasicOrbit;

   /* Can't compress symmetric group. */
   if ( IS_SYMMETRIC(G) )
      return;

   /* Here we compress the startOfOrbitNo fields. */
   for ( d = 1 ; d <= G->baseSize ; ++d ) {
      oldStartOfOrbit = G->startOfOrbitNo[d];
      for ( orbitCountPlus1 = 1 ; oldStartOfOrbit[orbitCountPlus1] <=
                                  G->degree ; ++orbitCountPlus1 )
         ;
      G->startOfOrbitNo[d] =
              (UnsignedS *) malloc( (orbitCountPlus1+1) * sizeof(UnsignedS) );
      for ( i = 1 ; i <= orbitCountPlus1 ; ++i )
         G->startOfOrbitNo[d][i] = oldStartOfOrbit[i];
   }

   /* Here we compress the basic orbit fields. */
   for ( d = 1 ; d <= G->baseSize ; ++d ) {
      oldBasicOrbit = G->basicOrbit[d];
      G->basicOrbit[d] = G->completeOrbit[d] +
                 G->startOfOrbitNo[d][ G->orbNumberOfPt[d][G->base[d]] ] - 1;
      for ( i = 1 ; i <= G->basicOrbLen[d] ; ++i )
         G->basicOrbit[d][i] = oldBasicOrbit[i];
      freeIntArrayDegree( oldBasicOrbit);
   }
}


/*-------------------------- compressAtLevel ------------------------------*/

/* This function acts like compressGroup, except that compression occurs only
   at one specified level). */

void compressAtLevel(
   PermGroup *const G,        /* The group to be compressed. */
   const Unsigned level)      /* The level at which compression occurs. */
{
   Unsigned  i, orbitCountPlus1;
   UnsignedS *oldStartOfOrbit, *oldBasicOrbit;

   /* Here we compress the startOfOrbitNo fields. */
   oldStartOfOrbit = G->startOfOrbitNo[level];
   for ( orbitCountPlus1 = 1 ; oldStartOfOrbit[orbitCountPlus1] <=
                               G->degree ; ++orbitCountPlus1 )
      ;
   G->startOfOrbitNo[level] =
           (UnsignedS *) malloc( (orbitCountPlus1+1) * sizeof(UnsignedS) );
   for ( i = 1 ; i <= orbitCountPlus1 ; ++i )
      G->startOfOrbitNo[level][i] = oldStartOfOrbit[i];

   /* Here we compress the basic orbit fields. */
   oldBasicOrbit = G->basicOrbit[level];
   G->basicOrbit[level] = G->completeOrbit[level] +
        G->startOfOrbitNo[level][ G->orbNumberOfPt[level][G->base[level]] ] - 1;
   for ( i = 1 ; i <= G->basicOrbLen[level] ; ++i )
      G->basicOrbit[level][i] = oldBasicOrbit[i];
   freeIntArrayDegree( oldBasicOrbit);
}

#ifdef XXX
/*-------------------------- sortGensByLevel ------------------------------*/

/* This function sorts the strong generators for a group in descending order
   according to the "level" field.  Within a fixed level, involutory
   generators are placed before noninvolutory ones. */

void sortGensByLevel(
   PermGroup *const G)
{
   Unsigned i;
   Permutation  gen, previousGen,
                *involGen[MAX_BASE_SIZE+2] = {NULL},
                *nonInvolGen[MAX_BASE_SIZE+2] = {NULL};

   /* Here the generators are placed on separate forward-linked lists, two for
      each level (one for involutions, the other for non-involutions. */
   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( isInvolutoryElt(gen) ) {
         gen->next = involGen[gen->level];
         involGen[gen->level] = gen;
      }
      else {
         gen->next = nonInvolGen[gen->level];
         nonInvolGen[gen->level] = gen;
      }
   G->generator = NULL;

   /* Now we reform a singly-linked list of the generators in sorted order. */
   for ( i = 1 ; i <= G->baseSize ; ++i ) {
      if ( nonInvolGen[i] ) {
         oldListHeader = G->generator;
         G->generator = involGen[i];
         for ( gen = G->generator ; gen->next ; gen = gen->next )
            ;
         gen->next = oldListHeader;
      }
      if ( involGen[i] ) {
         oldListHeader = G->generator;
         G->generator = involGen[i];
         for ( gen = G->generator ; gen->next ; gen = gen->next )
            ;
         gen->next = oldListHeader;
      }
   }

   /* Finally we reconstruct the backward links. */
   previousGen = NULL;
   for ( gen = G->generator ; gen ; gen = gen->next ) {
      gen->last = previousGen;
      previousGen = gen;
   }
}
#endif
