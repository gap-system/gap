/* File oldcopy.c.  Contains functions that copy an object to an already-
   existing object of the same type. */

#include <stddef.h>
#include <string.h>

#include "group.h"
#include "storage.h"

CHECK( oldcop)


/*-------------------------- copyPermutation ------------------------------*/

/* This function copies one permutation to another.  The destination permutation
   must already exist; its invImage field may be allocated or freed, depending
   on whether the source permutation has an invImage field.  The level and
   essential fields are not copied. */

void copyPermutation(
   const Permutation *const fromPerm,
   Permutation *const toPerm)
{
   Unsigned pt;

   strcpy ( toPerm->name, fromPerm->name);
   toPerm->degree = fromPerm->degree;
   for ( pt = 1 ; pt <= fromPerm->degree ; ++pt )
      toPerm->image[pt] = fromPerm->image[pt];
   if ( fromPerm->invImage ) {
      if ( fromPerm->invImage == fromPerm->image ) {
         if ( toPerm->invImage && toPerm->invImage != toPerm->image )
            freeIntArrayDegree( toPerm->invImage);
         toPerm->invImage = toPerm->image;
      }
      else {
         if ( !toPerm->invImage || toPerm->invImage == toPerm->image )
            toPerm->invImage = allocIntArrayDegree();
         for ( pt = 1 ; pt <= fromPerm->degree ; ++pt )
            toPerm->invImage[pt] = fromPerm->invImage[pt];
      }
   }
   else if ( toPerm->invImage ) {
      freeIntArrayDegree( toPerm->invImage);
      toPerm->invImage = NULL;
   }
}
