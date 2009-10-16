/* File code.c.  Contains miscellaneous functions for computations with
   binary codes. */

#include <stdlib.h>

#include "group.h"

#include "errmesg.h"
#include "storage.h"

CHECK( code)


/*-------------------------- reduceBasis ----------------------------------*/

/* The function reduceBasis allocates an infoSet for a code (unless one is
   already allocated -- if so, it must have the right size) and then performs
   elementary row operations on the generator matrix in order to make
   entry infoSet[j],i equal to delta(i,j). */

void reduceBasis(
   Code *const C)
{
   Unsigned row, col, i, j, mu;

   if ( !C->infoSet )
      C->infoSet = malloc( (C->dimension+2) * sizeof(Unsigned) );
   for ( row = 1 ; row <= C->dimension ; ++row ) {
      for ( col = 1 ; col <= C->length && C->basis[row][col] == 0; ++col )
         ;
      if ( col > C->length )
         ERROR( "reduceBasis", "Basis vectors not independent.")
      C->infoSet[row] = col;
      if ( C->fieldSize == 2 )
         for ( i = 1 ; i <= C->dimension ; ++i )
            if ( i != row && C->basis[i][col] != 0 )
               for ( j = 1 ; j <= C->length ; ++j )
                  C->basis[i][j] ^= C->basis[row][j];
            else
               ;
      else {
         mu = C->field->inv[C->basis[row][col]];
         for ( j = 1 ; j <= C->length ; ++j )
            C->basis[row][j] = C->field->prod[mu][C->basis[row][j]];
         for ( i = 1 ; i <= C->dimension ; ++i )
            if ( i != row && C->basis[i][col] != 0 ) {
               mu = C->basis[i][col];
               for ( j = 1 ; j <= C->length ; ++j )
                  C->basis[i][j] = C->field->dif[C->basis[i][j]]
                                     [C->field->prod[mu][C->basis[row][j]]];
            }
      }
   }
}


/*-------------------------- codeContainsVector ----------------------------*/

/* The function codeContainsVector( C, v) returns true is the vector v is
   contained in the code C and false otherwise.  The vector v is destroyed.
   Here a vector is simply an array of characters.  If C does not have a
   canonical basis, one is constructed. */

BOOLEAN codeContainsVector(
   Code *const C,
   char *const v)
{
   Unsigned i, j, col, mu;

   /* If a canonical basis is not available for C, construct one. */
   if ( !C->infoSet )
      reduceBasis( C);

   /* Try to reduce v. */
   for ( i = 1 ; i <= C->dimension ; ++i ) {
      col = C->infoSet[i];
      if ( C->fieldSize == 2 ) {
         if ( v[col] != 0 )
            for ( j = 1 ; j <= C->length ; ++j )
               v[j] ^= C->basis[i][j];
      }
      else
         if ( v[col] != 0 ) {
            mu = C->basis[i][col];
            for ( j = 1 ; j <= C->length ; ++j )
               v[j] = C->field->dif[v[j]][C->field->prod[mu][C->basis[i][j]]];
         }
   }

   /* Check if reduction gave the zero vector. */
   for ( j = 1 ; j <= C->length ; ++j )
      if ( v[j] != 0 )
         return FALSE;

   return TRUE;
}


/*-------------------------- isCodeIsomorphism ----------------------------*/

/* The function isCodeIsomorphism( C1, C2, s) returns TRUE if permutation s
   is an isomorphism of code C1 to code C2 and returns false otherwise. */

BOOLEAN isCodeIsomorphism(
   Code *const C1,
   Code *const C2,
   const Permutation *const s)
{
   char *tempVec = allocBooleanArrayDegree();
   Unsigned i, j, temp, mu, lambda; 
   Unsigned collapsedDegree;

   if ( C1->length != C2->length || C1->dimension != C2->dimension ||
        C1->length > s->degree )
      ERROR( "isCodeIsomorphism", "Lengths or degrees not compatible.")


   /* If the field size exceeds 2, check that s satisfies monomial property. */
   if ( C1->fieldSize > 2 ) {
      collapsedDegree = C1->length / (C1->fieldSize-1);      
      for ( i = 1 ; i <= collapsedDegree ; ++i ) {
         /* Find mu,j such that s(1*i) = mu*j. */
         temp = s->image[(C1->fieldSize-1)*(i-1)+1];
         j = (temp-1) / (C1->fieldSize-1) + 1;
         mu = (temp-1) % (C1->fieldSize-1) + 1;
         for ( lambda = 2 ; lambda < C1->fieldSize ; ++lambda )
            if ( s->image[(C1->fieldSize-1)*(i-1)+lambda] !=
                 (C1->fieldSize-1)*(j-1) + C1->field->prod[lambda][mu] ) {
               freeBooleanArrayDegree( tempVec);
               return FALSE;
            }
      }
   }

   /* Now check that each basis vector of C1 lies in C2. */
   for ( i = 1 ; i <= C1->dimension ; ++i ) {
      for ( j = 1 ; j <= C1->length ; ++j )
         tempVec[s->image[j]] = C1->basis[i][j];
      if ( !codeContainsVector(C2,tempVec) ) {
         freeBooleanArrayDegree( tempVec);
         return FALSE;
      }
   }

   freeBooleanArrayDegree( tempVec);
   return TRUE;
}

