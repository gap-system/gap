/* File essentia.c.  Contains functions for testing and setting the
   essential[] field of permutations. */

#include <stddef.h>

#include "group.h"

extern GroupOptions options;

CHECK( essent)


BOOLEAN essentialAtLevel(
   const Permutation *const perm,
   const Unsigned level)
{
   if ( level <= 31 )
      return  (perm->essential[0] & bitSetAt[level]) != 0ul;
   else
      return  (perm->essential[level>>5] & bitSetAt[level&31]) != 0ul;
}


BOOLEAN essentialBelowLevel(
   const Permutation *const perm,
   const Unsigned level)
{
   Unsigned i;
   unsigned long t;
   if ( level <= 31 )
      return  (perm->essential[0] & bitSetBelow[level] & 0xFFFFFFFE) != 0;
   else {
      t = perm->essential[0] & 0xFFFFFFFE;
      for ( i = 1 ; i < level>>5 ; ++i )
         t |= perm->essential[i];
      t |= perm->essential[level>>5] & bitSetBelow[level&31];
      return  t != 0;
   }
}


BOOLEAN essentialAboveLevel(
   const Permutation *const perm,
   const Unsigned level)
{
   Unsigned i;
   unsigned long t;
   t = perm->essential[level>>5] &
                   ~(bitSetAt[level&31] | bitSetBelow[level&31]);
   for ( i = (level>>5)+1 ; i <= (options.maxBaseSize+1)/32 ; ++i )
      t |= perm->essential[i];
   return  t != 0;
}


void makeEssentialAtLevel(
   Permutation *const perm,
   const Unsigned level)
{
   perm->essential[level>>5] |= bitSetAt[level&31];
}


void makeNotEssentialAtLevel(
   Permutation *const perm,
   const Unsigned level)
{
   perm->essential[level>>5] &= ~bitSetAt[level&31];
}


void makeNotEssentialAtAboveLevel(
   Permutation *const perm,
   const Unsigned level)
{
   Unsigned i;
   perm->essential[level>>5] &= bitSetBelow[level&31];
   for ( i = (level>>5)+1 ; i <= (options.maxBaseSize+1)/32 ; ++i )
      perm->essential[i] = 0;
}


void makeNotEssentialAll(
   Permutation *const perm)
{
   Unsigned i;
   for ( i = 0 ; i <= (options.maxBaseSize+1)/32 ; ++i )
      perm->essential[i] = 0;
}


void makeUnknownEssential(
   Permutation *const perm)
{
   Unsigned i;
   perm->essential[0] = 0xFFFFFFFE;
   for ( i = 1 ; i <= (options.maxBaseSize+1)/32 ; ++i )
      perm->essential[i] = 0xFFFFFFFF;
}


void copyEssential(
   Permutation *const newPerm,
   const Permutation *const oldPerm)
{
   Unsigned i;
   for ( i = 0 ; i <= (options.maxBaseSize+1)/32 ; ++i )
      newPerm->essential[i] = oldPerm->essential[i];
}
