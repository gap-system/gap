/* File partn.h.  Contains miscellaneous short functions for computing with
   partitions associated with permutation groups:

      constructOrbitPartition:  This function constructs the  partition of
                                the set of points corresponding to the orbits
                                of the stabilizer of an initial segment of the
                                base in a permutation group.

      popToHeight:              This function pops partitions from a partition
                                stack until the stack height reaches a
                                designated value.

      cellNumberAtDepth         For a given point alpha, his functions returns
                                the number of the cell of the partition at a
                                given depth that contains alpha.  (Note that,
                                for the top partition, it is not necessary to
                                invoke this function. */


#include "group.h"
#include "storage.h"
#include "permgrp.h"

CHECK( partn)


/*-------------------------- popToHeight -----------------------------------*/

/* This function pops partitions from a partition stack until the height
   reaches a specified value. */

void popToHeight(
   PartitionStack *piStack,     /* The partition stack to pop. */
   Unsigned newHeight)          /* The new height for the stack. */
{
   Unsigned ht, parent, i, lastPlus1;
   while ( (ht = piStack->height) > newHeight ) {
      --piStack->height;
      parent = piStack->parent[ht];
      for ( i = piStack->startCell[ht] , lastPlus1 = i +
            piStack->cellSize[ht] ; i < lastPlus1 ; ++i )
         piStack->cellNumber[piStack->pointList[i]] = parent;
      piStack->cellSize[parent] += piStack->cellSize[ht];
   }
}


/*-------------------------- xPopToLevel -----------------------------------*/

/* This function pops cell partitions from a cell partition stack until the 
    application level reaches a specified value. */

void xPopToLevel(
   CellPartitionStack *xPiStack,   /* The cell partition stack to pop. */
   UnsignedS *applyAfterLevel,
   Unsigned newHeight)             /* The new height for the stack. */
{
   Unsigned ht, parentGroup, i, lastPlus1;
   while ( applyAfterLevel[ht = xPiStack->height] > newHeight ) {
      --xPiStack->height;
      parentGroup = xPiStack->parentGroup[ht];
      for ( i = xPiStack->startCellGroup[ht] , lastPlus1 = i +
                    xPiStack->cellGroupSize[ht] ; i < lastPlus1 ; ++i )
         xPiStack->cellGroupNumber[xPiStack->cellList[i]] = parentGroup;
      xPiStack->cellGroupSize[parentGroup] += xPiStack->cellGroupSize[ht];
      xPiStack->totalGroupSize[parentGroup] += xPiStack->totalGroupSize[ht];
   }
}



/*-------------------------- constructOrbitPartition ----------------------*/

/* This function fills in two arrays (which must be allocated prior to the
   function call:  orbitNumberOf and sizeOfOrbit.  The array orbitNumberOf is
   set such that orbitNumberOf[pt] = i exactly when pt lies in the i'th orbit
   of the stabilizer of a given initial segment of the base in a given
   permutation group, and the array sizeOfOrbit is set so that sizeOfOrbit[j]
   is the length of the j'th orbit.  Note orbit i is taken to preceed orbit j
   when the first point of orbit i is less than the first point of orbit j.
   A base for the group must be known, and the field essential of each
   generator must be filled in.  (There is no harm beyond loss of efficienct
   in marking all generators essential.)  */

void *constructOrbitPartition(
   PermGroup *G,                /* The permutation group. */
   Unsigned level,              /* The orbits of G^(level) will be found. */
   UnsignedS *orbitNumberOf,    /* Set so that orbitNumberOf[pt] is the number
                                   of the orbit containing pt. */
   UnsignedS *sizeOfOrbit)      /* Set so that sizeOfOrbit[i] is the size of
                                   the i'th orbit. */
{
   Unsigned orbitCount = 0, found = 0, processed = 0, oldFound = 0, orbitRep,
       pt, img;
   UnsignedS *queue = allocIntArrayDegree();
   Permutation *genHeader, *gen;

   for ( pt = 1 ; pt <= G->degree ; ++pt )
      orbitNumberOf[pt] = 0;
   genHeader = linkEssentialGens( G, level);

   for ( orbitRep = 1 ; found <= G->degree ; ++orbitRep )
      if ( orbitNumberOf[orbitRep] == 0 ) {
         ++orbitCount;
         queue[++found] = orbitRep;
         while ( processed <= found ) {
            pt = queue[++processed];
            for ( gen = genHeader ; gen ; gen = gen->next )
               if ( orbitNumberOf[ img = gen->image[pt] ] == 0 ) {
                  queue[++found] = img;
                  orbitNumberOf[img] = orbitCount;
               }
         }
         sizeOfOrbit[orbitCount] = found - oldFound;
         oldFound = found;
      }

   freeIntArrayDegree( queue);
   return orbitNumberOf;
}


/*-------------------------- cellNumberAtDepth ----------------------------*/

/* Given a point alpha, a partition stack UpsilonStack, and a depth (depth),
   this function returns an integer i such that alpha lies in the i'th cell
   of the partition at depth depth in UpsilonStack.  It is assumed that depth
   does not exceed the height of UpsilonStack. */

Unsigned cellNumberAtDepth(
   const PartitionStack *const UpsilonStack,
   const Unsigned depth,
   const Unsigned alpha)
{
   Unsigned m;
   for ( m = UpsilonStack->cellNumber[alpha] ; m > depth ;
         m = UpsilonStack->parent[m] )
      ;
    return m;
}


/*-------------------------- numberOfCells --------------------------------*/

/* This function returns the number of cells is a partition.  It works by
   scanning cellNumber (inefficient, but doesn't require other fields to
   be filled in). */

Unsigned numberOfCells(
   const Partition *const Pi)
{
   UnsignedS i, maxCellNumber = 1;

   for ( i = 1 ; i <= Pi->degree ; ++i )
      if ( Pi->cellNumber[i] > maxCellNumber )
         maxCellNumber = Pi->cellNumber[i];

   return maxCellNumber;
}
