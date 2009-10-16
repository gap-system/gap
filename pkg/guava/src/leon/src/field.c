/* File field.c.  Contains miscellaneous functions for computations with
   fields.  At present, only field whose order is a prime number or 4 are
   implemented. */

#include <stdlib.h>

#include "group.h"

#include "errmesg.h"
#include "new.h"
#include "primes.h"
#include "storage.h"

CHECK( field)


/*-------------------------- newFieldTable --------------------------------*/

static FieldElement **newFieldTable(
   const Unsigned size)
{
   Unsigned i;
   FieldElement **T;

   T = (FieldElement **) malloc( size * sizeof(FieldElement *) );
   if ( !T )
      ERROR( "newFieldTable", "Out of memory.");
   for ( i = 0 ; i < size ; ++i ) {
      T[i] = (FieldElement *) malloc ( size * sizeof(FieldElement) );
      if ( !T[i] )
         ERROR( "newFieldTable", "Out of memory.");
   }

   return T;
}


/*-------------------------- buildField -----------------------------------*/

Field *buildField(
   Unsigned size)
{
   FieldElement lambda, mu;
   const FieldElement gf4Sum[4][4] =  {0,1,2,3,
                          1,0,3,2,
                          2,3,0,1,
                          3,2,1,0};
   const FieldElement gf4Prod[4][4] = {0,0,0,0,
                          0,1,2,3,
                          0,2,3,1,
                          0,3,1,2};
   Field *F;

   /* Check for valid field size. */
   if ( size > 255 )
      ERROR( "buildField", "Field sizes are restricted to 255.")
   if ( size != 4 && !isPrime(size) )
      ERROR( "buildField", "At present, field sizes must be prime or 4.")

   /* Allocate field and fill in field size, characteristic, and exponent. */  
   F = allocField();
   F->size = size;
   if ( size != 4 ) {
      F->characteristic = size;
      F->exponent = 1;
   }
   else {
      F->characteristic = 2;
      F->exponent = 2;
   }

   /* Allocate the arithmetic table arrays. */
   F->sum = newFieldTable( size);
   F->dif = newFieldTable( size);
   F->prod = newFieldTable( size);
   F->inv = malloc( size * sizeof(FieldElement) );
   if ( !F->inv )
      ERROR( "buildField", "Out of memory.");

   /* Construct the field tables. */
   for ( lambda = 0 ; lambda < size ; ++lambda)
      for ( mu = 0 ; mu < size ; ++mu) {
         if ( F->exponent == 1 ) {
            F->sum[lambda][mu] =  ( lambda + mu) % size;
            F->dif[lambda][mu] =  ( lambda - mu + size) % size;
            F->prod[lambda][mu] = ( lambda * mu) % size;
         }
         else {
            F->sum[lambda][mu] =  gf4Sum[lambda][mu];
            F->dif[lambda][mu] =  gf4Sum[lambda][mu];
            F->prod[lambda][mu] = gf4Prod[lambda][mu];
         }
         if ( F->prod[lambda][mu] == 1 )
            F->inv[lambda] = mu;
      }

   return F;
}
