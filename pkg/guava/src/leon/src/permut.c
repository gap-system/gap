/* File permut.c.  Contains miscellaneous functions performing simple
   computations with permutations, as follows:

      isIdentity:       Returns true if a permutation is the identity and
                        false otherwise.  Requires on the degree and image
                        fields of the permutation to be filled in.

      adjoinInvImage:   Adjoins the array invImage of inverse images to
                        a permutation.  The array image of images must
                        already be present.  For the identity or for an
                        involution, a separate array is not allocated.

      leftMultiply:     Multiplies a given permutation s on the left by a
                        permutation t (i.e., s is replaced by ts, and t
                        remains unchanged). */

#include <stdio.h>

#include "group.h"
#include "factor.h"
#include "errmesg.h"
#include "factor.h"
#include "new.h"
#include "storage.h"

#include "repimg.h"
#include "repinimg.h"
#include "settoinv.h"

CHECK( permut)


/*-------------------------- isIdentity -----------------------------------*/

/* This function may be used to test if a permutation is the identity.  It
   returns true if the permutation is the identity and false otherwise.  Only
   the degree and image fields of the permutation are required.  If the
   permutation lies in a group with known base, the faster function
   isIdentityElt should be used instead. */

BOOLEAN isIdentity(
   const Permutation *const s)
{
   Unsigned pt;
   for ( pt = 1 ; pt <= s->degree ; ++pt)
      if ( s->image[pt] != pt )
         return FALSE;
   return TRUE;
}


/*-------------------------- isInvolution ---------------------------------*/

/* This function may be used to test if a permutation is an involution or is
   the identity.  It returns true if so and false otherwise.  Only
   the degree and image fields of the permutation are required.  If the
   permutation lies in a group with known base, the faster function
   isInvolutoryElt should be used instead. */

BOOLEAN isInvolution(
   const Permutation *const s)
{
   Unsigned pt;
   for ( pt = 1 ; pt <= s->degree ; ++pt)
      if ( s->image[s->image[pt]] != pt )
         return FALSE;
   return TRUE;
}


/*-------------------------- pointMovedBy ---------------------------------*/

/* The function pointMovedBy( perm) returns a point moved by the permutation
   perm.  If perm is the identity, the program is terminated with an error
   message. */

Unsigned pointMovedBy(
   const Permutation *const perm)
{
   Unsigned pt;
   for ( pt = 1 ; pt <= perm->degree ; ++pt )
      if ( perm->image[pt] != pt )
         return pt;
   ERROR( "pointMovedBy", "Attempt to find a point moved by identity "
          "permutation");
}


/*-------------------------- adjoinInvImage -------------------------------*/

/* The function adjoinInvImage may be used to adjoin an array of inverse
   images (invImage) to a permutation.  The array image of images must
   already be present.  If the array invImage is already present, the
   function does nothing.  For any involutory permutation, the function
   merely sets the pointer invImage to point to the existing array image. */

void adjoinInvImage(
   Permutation *s)        /* The permutation group (base and sgs known). */
{
   Unsigned degree = s->degree;
   Unsigned pt;

   /* Check if inverse image array already exists?  If so, do nothing. */
   if ( ! s->invImage ) {

      /* Allocate and construct the array of inverse images. */
      s->invImage = allocIntArrayDegree();
      for ( pt = 1 ; pt <= degree ; ++pt )
         s->invImage[s->image[pt]] = pt;
      s->invImage[degree+1] = 0;

      /* Check if the permutation is an involution, adjust if so. */
      for ( pt = 1 ; pt <= degree && s->image[pt] == s->invImage[pt] ; ++pt )
         ;
      if ( pt > degree ) {
         freeIntArrayDegree( s->invImage);
         s->invImage = s->image;
      }
   }
}


/*-------------------------- leftMultiply ---------------------------------*/

/* The function leftMultiply( s, t) multiplies the permutation s on the left
   by the permutation t. */

void leftMultiply(
   Permutation *const s,
   const Permutation *const t)
{
   UnsignedS *oldImage = allocIntArrayDegree();
   Unsigned pt;

   for ( pt = 1 ; pt <= s->degree ; ++pt )
      oldImage[pt] = s->image[pt];
   for ( pt = 1 ; pt <= s->degree ; ++pt)
      s->image[pt] = oldImage[t->image[pt]];
   freeIntArrayDegree( oldImage);

   if ( s->invImage )
      if ( isInvolution( s) )
         if ( s->invImage != s->image ) {
            freeIntArrayDegree( s->invImage);
            s->invImage = s->image;
         }
         else
            ;
      else {
         if ( s->invImage == s->image )
            s->invImage = allocIntArrayDegree();
         for ( pt = 1 ; pt <= s->degree ; ++pt )
            s->invImage[s->image[pt]] = pt;
      }
}


/*-------------------------- rightMultiply ---------------------------------*/

/* The function rightMultiply( s, t) multiplies the permutation s on the right
   by the permutation t.  If s contains inverse images initially, they will
   be updated.  Note that t need not have inverse images. */

void rightMultiply(
   Permutation *const s,
   const Permutation *const t)
{
   Unsigned  uTemp1, uTemp2, uTemp3;
   UnsignedS *temp1, *temp2, *temp3, *temp4;

   REPLACE_BY_IMAGE( s->image, t, s->degree, temp1, temp2, temp3, temp4)
   if ( s->invImage )
      if ( isInvolution( s) )
         if ( s->invImage != s->image ) {
            freeIntArrayDegree( s->invImage);
            s->invImage = s->image;
         }
         else
            ;
      else {
         if ( s->invImage == s->image )
            s->invImage = allocIntArrayDegree();
         SET_TO_INVERSE( s->image, s->invImage, s->degree,
                         temp1, temp2, uTemp1, uTemp2, uTemp3)
      }
}


/*-------------------------- rightMultiplyInv ------------------------------*/

/* The function rightMultiplyInv( s, t) multiplies the permutation s on the
   right by the inverse of the permutation t.  If s contains inverse images
   initially, they will be updated.  Note t must have inverse images. */

void rightMultiplyInv(
   Permutation *s,
   Permutation *t)
{
   Unsigned  uTemp1, uTemp2, uTemp3;
   UnsignedS *temp1, *temp2, *temp3, *temp4;

   if ( !t->invImage )
      ERROR( "rightMultiplyInv", "Inverse image array for permutation not "
                                 "available.");

   REPLACE_BY_INV_IMAGE( s->image, t, s->degree, temp1, temp2, temp3, temp4)
   if ( s->invImage )
      if ( isInvolution( s) )
         if ( s->invImage != s->image ) {
            freeIntArrayDegree( s->invImage);
            s->invImage = s->image;
         }
         else
            ;
      else {
         if ( s->invImage == s->image )
            s->invImage = allocIntArrayDegree();
         SET_TO_INVERSE( s->image, s->invImage, s->degree,
                         temp1, temp2, uTemp1, uTemp2, uTemp3)
      }
}


/*-------------------------- permOrder ------------------------------------*/

/* The function permOrder( perm) returns the order of permutation perm.  The
   order is returned as a long integer.  The function returns 0 if the order
   exceeds ULONG_MAX. */

unsigned long permOrder(
   const Permutation *const perm )
{
   unsigned long  orbLen, multiplier, order;
   Unsigned   pt, basePt, imagePt;
   char  *found = allocBooleanArrayDegree();

   for (pt = 1; pt <= perm->degree; ++pt)
      found[pt] = FALSE;

   for ( basePt = 1, order = 1; basePt <= perm->degree; ++basePt )
      if ( ! found[basePt] )  {
         orbLen = 0;
         imagePt = basePt;
         do {
            ++orbLen;
            imagePt = perm->image[imagePt];
            found[imagePt] = TRUE;
         } while ( imagePt != basePt );
         if (order % orbLen != 0)
            if ( order <= ULONG_MAX / (multiplier = orbLen / gcd(order,orbLen)) )
               order *= multiplier;
            else {
               freeBooleanArrayDegree( found);
               return 0;
            }
      }

   freeBooleanArrayDegree( found);
   return order;
}


/*-------------------------- raisePermToPower -----------------------------*/

/* The function raisePermToPower replaces a given permutation by a designated
   power of that permutation.  INVERSE PERMUTATIONS ARE NOT HANDLED. */

void raisePermToPower(
   Permutation *const perm,      /* The permutation to be replaced. */
   const long power)             /* Upon return, perm has been replaced by
                                    perm^power. */
{
   Unsigned  i, pt, img, imgIndex, cycleLen;
   UnsignedS  *cycle = allocIntArrayDegree();
   char  *found = allocBooleanArrayDegree();

   /* Initialize found[pt] to false for all points pt.  When the cycle of pt has
      been constructed, found[pt] will be set to true. */
   for ( pt = 1 ; pt <= perm->degree ; ++pt )
      found[pt] = FALSE;

   for ( pt = 1 ; pt <= perm->degree ; ++pt )
      if ( !found[pt] ) {

         /* Construct the cycle of point pt. */
         cycleLen = 0;
         img = pt;
         do {
            cycle[cycleLen++] = img;
            found[img] = TRUE;
            img = perm->image[img];
         } while( img != pt );

         /* Replace perm by perm^power on cycle just constructed. */
         for ( i = 0 ; i < cycleLen ; ++i ) {
            imgIndex = (i + power) % cycleLen;
            perm->image[cycle[i]] = cycle[imgIndex];
            if ( perm->invImage )
               perm->invImage[cycle[imgIndex]] = cycle[i];
         }
      }

   /* Check if the power is an involution. */
   if ( isInvolution(perm) && perm->invImage != perm->image ) {
      freeIntArrayDegree( perm->invImage);
      perm->invImage = perm->image;
   }
      
   /* Free temporary storage. */
   freeIntArrayDegree( cycle);
   freeBooleanArrayDegree( found);

}


/*-------------------------- permMapping ----------------------------------*/

/* This function returns a new permutation mapping given sequence of
   integers to another. */

Permutation *permMapping(
   const Unsigned degree,     /* The degree of the new permutation.*/
   const UnsignedS seq1[],    /* The first sequence (must have len = degree). */
   const UnsignedS seq2[])    /* The second sequence (must have len = degree. */
{
   Unsigned i;
   Permutation *newPerm = newUndefinedPerm( degree);

   for ( i = 1 ; i <= degree ; ++i )
      newPerm->image[seq1[i]] = seq2[i];
   adjoinInvImage( newPerm);

   return newPerm;
}


/*-------------------------- checkConjugacy --------------------------------------*/

/* The function checkConjugacy( e, f, conjPerm) returns true if permutation 
   conjPerm conjugates permutation e to permutation f, that is, if  
   e ^ conjPerm = f, or equivalently,  e * conjPerm = conjPerm * f. */

BOOLEAN checkConjugacy(
   const Permutation *const e,
   const Permutation *const f,
   const Permutation *const conjPerm)
{
   int pt;

   for ( pt = 1 ; pt <= e->degree ; ++pt ) 
      if ( conjPerm->image[e->image[pt]] != f->image[conjPerm->image[pt]] )
         return FALSE;
   return TRUE;
} 



/*-------------------------- isValidPermutation ----------------------------------*/

#include "enum.h"

BOOLEAN isValidPermutation(
   const Permutation *const perm,
   const Unsigned degree,
   const Unsigned xCos,
   const Unsigned *const equivPt)
{
   Unsigned pt;

   if ( perm->degree != degree ) {
      printf( "\n*** Permutation %s has incorrect degree %u.", perm->name,
              perm->degree);
      return FALSE;
   }

   for ( pt = 1 ; pt <= degree ; ++pt )
      if ( perm->image[pt] < 1 || (perm->image[pt] & NHB) > degree+xCos || 
           equivPt[perm->invImage[equivPt[perm->image[pt] & NHB]] & NHB] != pt ) {
         printf( "\n*** Permutation %s has invalid image/invImage field at %u.",
                 perm->name, pt);
         return FALSE;
      }

   return TRUE;
}
      
