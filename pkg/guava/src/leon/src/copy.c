/* File copy.c.  Contains functions to create copies of objects.  Each
   function allocates storage for a new object, which is totally disjoint
   from the object being copies (i.e., the existing object and the new
   copy do not contain direct or indirect pointers to common objects, and
   it returns a pointer to the new object.  The functions are:

      copyOfPermGroup:  create a new copy of a permutation group. */

#include <stddef.h>
#include <string.h>

#include "group.h"

#include "essentia.h"
#include "storage.h"

CHECK( copy)

/*-------------------------- copyOfPermutation ----------------------------*/

/* This function creates a new copy of an existing permutation, and it
   returns a pointer to the new permutation.  The link fields of the new
   permutation are not copied, or otherwise initialized, and currently the
   word field is not supported. */

Permutation *copyOfPermutation(
   Permutation *oldPerm)         /* The permutation to be copied. */
{
   Unsigned pt;
   Permutation *newPerm = allocPermutation();

   strcpy( newPerm->name, oldPerm->name);
   newPerm->degree = oldPerm->degree;

   if ( oldPerm->image ) {
      newPerm->image = allocIntArrayDegree();
      for ( pt = 1 ; pt <= oldPerm->degree+1 ; ++pt )
         newPerm->image[pt] = oldPerm->image[pt];
   }
   else
      newPerm->image = NULL;

   if ( oldPerm->invImage ) {
      if ( oldPerm->invImage == oldPerm->image )
         newPerm->invImage = newPerm->image;
      else {
         newPerm->invImage = allocIntArrayDegree();
         for ( pt = 1 ; pt <= oldPerm->degree+1 ; ++pt )
            newPerm->invImage[pt] = oldPerm->invImage[pt];
      }
   }
   newPerm->level = oldPerm->level;
   COPY_ESSENTIAL( newPerm, oldPerm);

   return newPerm;
}


/*-------------------------- copyOfPermGroup ------------------------------*/

/* This function creates a new copy of an existing permutation group, and it
   returns a pointer to the new group.  Note the word field of the
   generating permutations is not currently supported.  The xNext field
   of the generators of the old group is modified. */

PermGroup *copyOfPermGroup(
   PermGroup *oldGroup)          /* The group being copied. */
{
   Unsigned i, level, pt;
   Permutation *oldGen, *newGen, *previousGen, *temp;
   PermGroup *newGroup = allocPermGroup();

   /* Copy name, degree, base size, base, and basic orbit lengths. */
   strcpy( newGroup->name, oldGroup->name);
   newGroup->degree = oldGroup->degree;

   /* Copy the base size, base, and basic orbit lengths, if present in the
      old group. */
   if ( oldGroup->base ) {
      newGroup->baseSize = oldGroup->baseSize;
      newGroup->base = allocIntArrayBaseSize();
      for ( i = 1 ; i <= oldGroup->baseSize+1 ; ++i )
         newGroup->base[i] = oldGroup->base[i];
      newGroup->basicOrbLen = allocIntArrayBaseSize();
      for ( i = 1 ; i <= oldGroup->baseSize ; ++i )
         newGroup->basicOrbLen[i] = oldGroup->basicOrbLen[i];
   }

   /* Copy the order, if present. */
   if ( oldGroup->order ) {
      newGroup->order = allocFactoredInt();
      newGroup->order->noOfFactors = oldGroup->order->noOfFactors;
      for ( i = 0 ; i < oldGroup->order->noOfFactors ; ++i ) {
         newGroup->order->prime[i] = oldGroup->order->prime[i];
         newGroup->order->exponent[i] = oldGroup->order->exponent[i];
      }
   }

   /* Copy basic orbits. */
   if ( oldGroup->base && oldGroup->basicOrbit ) {
      newGroup->basicOrbit = (UnsignedS **) allocPtrArrayBaseSize();
      for ( level = 1 ; level <= oldGroup->baseSize ; ++level ) {
         newGroup->basicOrbit[level] = allocIntArrayDegree();
         for ( i = 1 ; i <= oldGroup->basicOrbLen[level]+1 ; ++i )
            newGroup->basicOrbit[level][i] = oldGroup->basicOrbit[level][i];
      }
   }

   /* Copy generators.  The xNext field of each old generator is set to
      point to the corresponding new generator (for use in Schreier vector
      construction. */
   newGroup->generator = previousGen = NULL;
   for ( oldGen = oldGroup->generator ; oldGen ; oldGen = oldGen->next ) {
      newGen = copyOfPermutation( oldGen);
      if ( previousGen ) {
         previousGen->next = newGen;
         newGen->last = previousGen;
      }
      else {
         newGroup->generator = newGen;
         newGen->last = NULL;
      }
      newGen->next = NULL;
      oldGen->xNext = newGen;
      previousGen = newGen;
   }

   /* Copy the Schreier vectors. */
   if ( oldGroup->base && oldGroup->schreierVec ) {
      newGroup->schreierVec = (Permutation ***) allocPtrArrayBaseSize();
      for ( level = 1 ; level <= oldGroup->baseSize ; ++level ) {
         newGroup->schreierVec[level] = (Permutation **) allocPtrArrayDegree();
         for ( i = 1 ; i <= oldGroup->degree ; ++i )
            if ( (temp = oldGroup->schreierVec[level][i]) == NULL ||
                 temp == FIRST_IN_ORBIT )
               newGroup->schreierVec[level][i] = temp;
            else
               newGroup->schreierVec[level][i]  =temp->xNext;
      }
   }

   /* Copy the list of points. */
   if ( oldGroup->omega ) {
      newGroup->omega = allocIntArrayDegree();
      for ( pt =1 ; pt <= oldGroup->degree ; ++pt )
         newGroup->omega[pt] = oldGroup->omega[pt];
   }
   else
      newGroup->omega = NULL;

   if ( oldGroup->invOmega ) {
      newGroup->invOmega = allocIntArrayDegree();
      for ( pt =1 ; pt <= oldGroup->degree ; ++pt )
         newGroup->invOmega[pt] = oldGroup->invOmega[pt];
   }
   else
      newGroup->invOmega = NULL;

   return newGroup;
}









