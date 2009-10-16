/* File matrix.c.  Contains miscellaneous functions for computations with
   (0,1) matrices. */

#include <stdlib.h>
#include <string.h>

#include "group.h"

#include "errmesg.h"
#include "new.h"
#include "storage.h"

CHECK( matrix)


      
/*-------------------------- isMatrix01Isomorphism ------------------------*/

/* The function isMatrix01Isomorphism( M1, M2, s) returns TRUE if permutation s
   is an isomorphism of the (0,1) matrix M1 to the (0,1) matrix M2 and returns 
   returns true otherwise. */

BOOLEAN isMatrix01Isomorphism(
   const Matrix_01 *const M1,
   const Matrix_01 *const M2,
   const Permutation *const s,
   const Unsigned monomialFlag)         /* If TRUE, check that iso */
                                        /* is monomial. */
{                                               
   Unsigned i, j, temp, mu, lambda, nRows = M1->numberOfRows; 
   UnsignedS *image = s->image;
   Unsigned collapsedDegree;

   if ( M1->numberOfRows != M2->numberOfRows || M1->numberOfCols != 
        M2->numberOfCols || M1->numberOfRows+M1->numberOfCols != s->degree )
      ERROR( "isMatrix01Isomorphism", "Sizes or degrees not compatible.")

   /* If requested, check that s satisfies the monomial property. */
   if ( monomialFlag ) {
      collapsedDegree = (M1->numberOfRows+M1->numberOfCols) / 
                              (M1->setSize-1);      
      for ( i = 1 ; i <= collapsedDegree ; ++i ) {
         /* Find mu,j such that s(1*i) = mu*j. */
         temp = s->image[(M1->setSize-1)*(i-1)+1];
         j = (temp-1) / (M1->setSize-1) + 1;
         mu = (temp-1) % (M1->setSize-1) + 1;
         for ( lambda = 2 ; lambda < M1->setSize ; ++lambda )
            if ( s->image[(M1->setSize-1)*(i-1)+lambda] !=
                 (M1->setSize-1)*(j-1) + M1->field->prod[lambda][mu] )
               return FALSE;
      }
   }

   /* Now check that each M1^s = M2. */
   for ( i = 1 ; i <= M1->numberOfRows ; ++i ) 
      for ( j = 1 ; j <= M1->numberOfCols ; ++j )
         if ( M1->entry[i][j] != 
              M2->entry[image[i]][image[j+nRows]-nRows] )
            return FALSE;

   return TRUE;
}


/*-------------------------- augmentedMatrix ------------------------------*/

Matrix_01 *augmentedMatrix(
   const Matrix_01 *const M)
{
   const Unsigned setSize = M->setSize;
   const Unsigned nRows = M->numberOfRows;
   const Unsigned nCols = M->numberOfCols;
   FieldElement **prod = M->field->prod;
   FieldElement *inv = M->field->inv;
   Unsigned i, j;
   char lambda, mu;
   Matrix_01 *MM;

   MM = newZeroMatrix( M->setSize, (setSize-1)*nRows, (setSize-1)*nCols);
   MM->field = M->field;
   strcpy( MM->name, M->name);
   for ( i = 1 ; i <= nRows ; ++i )
      for ( j = 1 ; j <= nCols ; ++j )
         for ( lambda = 1 ; lambda < setSize ; ++lambda )
            for ( mu = 1 ; mu < setSize ; ++mu )
/* Test: change matrix elts to inverses.   
               MM->entry[(setSize-1)*(i-1)+lambda][(setSize-1)*(j-1)+mu] =
                        prod[prod[lambda][mu]][M->entry[i][j]];
*/
               MM->entry[(setSize-1)*(i-1)+lambda][(setSize-1)*(j-1)+mu] =
                        prod[inv[prod[lambda][mu]]][M->entry[i][j]];

   return MM;
}
