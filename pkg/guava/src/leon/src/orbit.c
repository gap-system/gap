/* File orbit.c.  Contains miscellaneous functions for orbit computations. */

#include "group.h"

#include "cstborb.h"

CHECK( orbit)

/* Bug fix for Waterloo C (IBM 370). */
#if defined(IBM_CMS_WATERLOOC) && !defined(SIGNED) && !defined(EXTRA_LARGE)
#define FIXUP1 short
#define FIXUP2 (short)
#else
#define FIXUP1 Unsigned
#define FIXUP2
#endif
FIXUP1 minimalPointOfOrbit(
   PermGroup *G,
   Unsigned level,
   Unsigned point,
   UnsignedS *minPointOfOrbit,
   UnsignedS *minPointKnown,
   UnsignedS *minPointKnownCount,
   UnsignedS *invOmega)
{
   Unsigned i, found, processed, pt, img, smallestSoFar;
   Permutation *gen, *firstGen;

   if ( minPointOfOrbit[point] != 0 )
      return FIXUP2 minPointOfOrbit[point];
   else {

      /* Construct the orbit of point. */
      firstGen = linkEssentialGensAtLevel( G, level);
      found = processed = *minPointKnownCount;
      minPointKnown[++found] = point;
      minPointOfOrbit[point] = UNKNOWN;
      smallestSoFar = point;
      while ( processed < found ) {
         pt = minPointKnown[++processed];
         for ( gen = firstGen ; gen ; gen = gen->xNext ) {
            img = gen->image[pt];
            if ( !minPointOfOrbit[img] ) {
               minPointOfOrbit[img] = UNKNOWN;
               minPointKnown[++found] = img;
               if ( invOmega[img] < invOmega[smallestSoFar] )
                  smallestSoFar = img;
            }
         }
      }

      /* Mark minimum for each element in orbit of point. */
      for ( i = *minPointKnownCount+1 ; i <= found ; ++i )
         minPointOfOrbit[minPointKnown[i]] = smallestSoFar;
      *minPointKnownCount = found;

      return  FIXUP2 smallestSoFar;
   }
}
