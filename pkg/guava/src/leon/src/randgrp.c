/* File randgrp.c.  Contains functions generating random numbers and random
   group elements, as follows:

      initializeSeed:   Initializes the seed for the random number generator.

      randInteger:      Returns a pseudo-random integer in a specified range.

      randGroupWord:    Returns a pseudo-random group element, represented as
                        a word, in a group with known base and strong
                        generating set.

      randGroupPerm:    Returns a pseudo-random group element, represented as
                        a permutation, in a group with known base and strong
                        generating set. */

#include <stddef.h>

#include "group.h"

#include "new.h"
#include "permut.h"

CHECK( randgr)

static unsigned long        seed = 47;
static const unsigned long  multiplier = 65539;             /* 2^16 + 3 */


/*-------------------------- initializeSeed -------------------------------*/

/* The function initializeSeed may be used to set the seed for the random
   integer generator to a specific value.  From then on, the sequence of
   random integers will be determined by the seed.  The seed should be an
   odd positive integer, since the modulus is a power of 2. */

void initializeSeed(
   unsigned long newSeed)      /* The new value for the seed. */
{
   seed = newSeed;
}


/*-------------------------- randInteger ----------------------------------*/

/* The function randInteger returns a pseudo-random integer in a given range.
   The technique is adapted from the book "Assembler Language for Fortran,
   Cobol, and PL/1 Programmers" by Shan S. Kuo, pages 106-107.  It is designed
   for speed of computation rather than degree of randomness.  It assumes
   type long is 32 bits and that, in multiplying unsigned long integers,
   excess bits on the left are discarded. */

Unsigned randInteger(
   Unsigned lowerBound,           /* Lower bound for range of random integer. */
   Unsigned upperBound)           /* Upper bound for range of random integer. */
{
   seed = (seed * multiplier) & 0x7fffffff;
   return  lowerBound + (seed >> 7) % (upperBound - lowerBound + 1);
}


/*-------------------------- randGroupWord ---------------------------------*/

/* The function randGroupWord returns newly allocated word in the strong
   generators of a group, representing a pseudo-random element of the
   stabilizer in the group of a designated number of base points. */

Word *randGroupWord(
   PermGroup *G,
   Unsigned atLevel)
{
   Word *w = newTrivialWord();
   Unsigned  level, pt;
   Permutation **svec;

   for ( level = atLevel ; level <= G->baseSize ; ++level ) {
      pt = G->basicOrbit[level][ randInteger(1,G->basicOrbLen[level]) ];
      svec = G->schreierVec[level];
      while ( svec[pt] != FIRST_IN_ORBIT ) {
         w->position[++w->length] = svec[pt];
         pt = svec[pt]->invImage[pt];
      }
   }
   w->position[++w->length] = NULL;
   return w;
}


/*-------------------------- randGroupPerm ---------------------------------*/

/* The function randGroupPerm returns a newly allocated pseudo-random 
   permutation in the stabilizer of an initial segment of the base in a 
   permutation group.  The inverse image field of the permutation is filled 
   in. */

Permutation *randGroupPerm(
   PermGroup *G,
   Unsigned atLevel)
{
   Permutation *randPerm = newIdentityPerm( G->degree);
   Unsigned  level, pt, i;
   Permutation **svec;

   for ( level = atLevel ; level <= G->baseSize ; ++level ) {
      pt = G->basicOrbit[level][ randInteger(1,G->basicOrbLen[level]) ];
      svec = G->schreierVec[level];
      while ( svec[pt] != FIRST_IN_ORBIT ) {
         for ( i = 1 ; i <= G->degree ; ++i )
            randPerm->image[i] = svec[pt]->invImage[ randPerm->image[i] ];
         pt = svec[pt]->invImage[pt];
      }
   }
   randPerm->invImage = NULL;
   adjoinInvImage( randPerm);

   return randPerm;
}

