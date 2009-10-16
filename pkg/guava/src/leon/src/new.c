/* File new.c.  Contains functions to create new objects and delete objects
   so created.  Actual allocation of memory is handled by invoking functions
   from storage.c.  The functions included here are:

                                               */
#include <stddef.h>
#include <stdlib.h>

#include "group.h"

#include "errmesg.h"
#include "partn.h"
#include "storage.h"

CHECK( new)


/*-------------------------- deletePartition ------------------------------*/

void deletePartition(
   Partition *partn)
{
   freeIntArrayDegree( partn->pointList);
   freeIntArrayDegree( partn->invPointList);
   freeIntArrayDegree( partn->cellNumber);
   freeIntArrayDegree( partn->startCell);
   freePartition( partn);
}


/*-------------------------- newPartitionStack ----------------------------*/

/* This function creates a new partition stack of specified degree and
   initializes it to a stack of height 1 in which the top (and only)
   partition is trivial.  It returns a pointer to the new partition stack. */

PartitionStack *newPartitionStack(
   const Unsigned degree)             /* The degree for the partition stack. */
{
   PartitionStack *newStack = allocPartitionStack();
   Unsigned i;

   newStack->degree = degree;
   newStack->height = 1;

   newStack->pointList = allocIntArrayDegree();
   newStack->invPointList = allocIntArrayDegree();
   for ( i = 1 ; i <= degree ; ++i )
      newStack->pointList[i] = newStack->invPointList[i] = i;
   newStack->pointList[degree+1] = newStack->invPointList[degree+1] = 0;

   newStack->cellNumber = allocIntArrayDegree();
   for ( i = 1 ; i <= degree ; ++i )
      newStack->cellNumber[i] = 1;

   newStack->parent = allocIntArrayDegree();

   newStack->startCell = allocIntArrayDegree();
   newStack->startCell[1] = 1;

   newStack->cellSize = allocIntArrayDegree();
   newStack->cellSize[1] = degree;

   return newStack;
}


/*-------------------------- deletePartitionStack -------------------------*/

void deletePartitionStack(
   PartitionStack *partnStack)
{
   freeIntArrayDegree( partnStack->pointList);
   freeIntArrayDegree( partnStack->invPointList);
   freeIntArrayDegree( partnStack->cellNumber);
   freeIntArrayDegree( partnStack->parent);
   freeIntArrayDegree( partnStack->startCell);
   freeIntArrayDegree( partnStack->cellSize);
   freePartitionStack( partnStack);
}


/*-------------------------- newCellPartitionStack ------------------------*/

/* This function creates a new cell partition stack of based on a specified
   partition and initializes it to a stack of height 1 in which each cell is
   in its own cell group.  It returns a pointer to the new partition stack. */

CellPartitionStack *newCellPartitionStack(
   Partition *basePartn)             /* The base partition. */
{
   CellPartitionStack *newCellStack = (CellPartitionStack *) malloc(
                                         sizeof(CellPartitionStack) );
   Unsigned i, cellCount;

   newCellStack->basePartn = basePartn;
   newCellStack->height = 1;
   newCellStack->cellCount = cellCount = numberOfCells( basePartn);

   newCellStack->cellList = malloc( (cellCount+2)*sizeof(UnsignedS) );
   newCellStack->invCellList = malloc( (cellCount+2)*sizeof(UnsignedS) );
   for ( i = 1 ; i <= cellCount ; ++i )
      newCellStack->cellList[i] = newCellStack->invCellList[i] = i;
   newCellStack->cellList[cellCount+1] = 0;
   newCellStack->invCellList[cellCount+1] = 0;

   newCellStack->cellGroupNumber = malloc( (cellCount+2)*sizeof(UnsignedS) );
   for ( i = 1 ; i <= cellCount ; ++i )
      newCellStack->cellGroupNumber[i] = 1;

   newCellStack->parentGroup = malloc( (cellCount+2)*sizeof(UnsignedS) );
   newCellStack->parentGroup[1] = 0;

   newCellStack->startCellGroup = malloc( (cellCount+2)*sizeof(UnsignedS) );
   newCellStack->startCellGroup[1] = 1;

   newCellStack->cellGroupSize = malloc( (cellCount+2)*sizeof(UnsignedS) );
   newCellStack->cellGroupSize[1] = cellCount;
   
   newCellStack->totalGroupSize = malloc( (cellCount+2)*sizeof(UnsignedS) );
   newCellStack->totalGroupSize[1] = basePartn->degree;

   return newCellStack;
}


/*-------------------------- newIdentityPerm ------------------------------*/

/* This function creates a new permutation of a specified degree and
   initializes it to the identity.  The name is set to a null string.  The
   returns a pointer to the permutation. */

Permutation *newIdentityPerm(
   Unsigned degree)                    /* The degree for the new permutation. */
{
   Permutation *newPerm = allocPermutation();
   Unsigned pt;

   newPerm->name[0] = '\0';
   newPerm->degree = degree;
   newPerm->invImage = newPerm->image = allocIntArrayDegree();
   for ( pt = 1 ; pt <= degree ; ++pt )
      newPerm->image[pt] = pt;
   newPerm->image[degree+1] = 0;
   newPerm->word = NULL;

   return newPerm;
}


/*-------------------------- newUndefinedPerm -----------------------------*/

/*  This function creates a new permutation of specified degree.  Space is
    allocated for the image array (It remains uninitialized), but not for the
    inverse image array. The function returns a pointer to the new
    permutation. */

Permutation *newUndefinedPerm(
   const Unsigned degree)             /* The degree for the new permutation. */
{
   Permutation *newPerm = allocPermutation();

   newPerm->degree = degree;
   newPerm->image = allocIntArrayDegree();
   newPerm->image[degree+1] = 0;
   newPerm->invImage = NULL;
   newPerm->word = NULL;

   return newPerm;
}


/*-------------------------- deletePermutation ----------------------------*/

/*  This function deletes a permutation created with one of the functions
    above. */

void deletePermutation(
   Permutation *oldPerm)         /* The permutation to be deleted. */
{
   if ( oldPerm->image ) {
      freeIntArrayDegree( oldPerm->image);
      if ( oldPerm->invImage != NULL &&
           oldPerm->invImage != oldPerm->image )
         freeIntArrayDegree( oldPerm->invImage);
   }
   freePermutation( oldPerm);
}


/*-------------------------- newTrivialPermGroup --------------------------*/

/* This function creates a new permutation group of specified degree and sets
   it to the group of order 1.  It returns a pointer to the new group. */

PermGroup *newTrivialPermGroup(
   Unsigned degree)                    /* The degree for the new group. */
{
   PermGroup *newGroup = allocPermGroup();

   newGroup->name[0] = '\0';
   newGroup->degree = degree;
   newGroup->baseSize = 0;
   newGroup->order = allocFactoredInt();
   newGroup->order->noOfFactors = 0;
   newGroup->base = allocIntArrayBaseSize();
   newGroup->base[1] = 0;
   newGroup->basicOrbLen = allocIntArrayBaseSize();
   newGroup->basicOrbit = (UnsignedS **) allocPtrArrayBaseSize();
   newGroup->schreierVec = (Permutation ***) allocPtrArrayBaseSize();
   newGroup->generator = NULL;
   newGroup->omega = NULL;

   return newGroup;
}


/*-------------------------- deletePermGroup ------------------------------*/

/* This function deletes a permutation group.  All memory occupied by
   components of the group, including all generating permutations, is freed. */

void deletePermGroup(
   PermGroup *G)                  /* The permutation group to delete. */
{
   Unsigned i;
   Permutation *gen, *genNext;

   if ( G->order )
      freeFactoredInt( G->order);
   if ( G->base ) {
      freeIntArrayBaseSize( G->base);
      if ( G->basicOrbLen )
         freeIntArrayBaseSize( G->basicOrbLen );
      if ( G->basicOrbit ) {
         for ( i = 1 ; i <= G->baseSize ; ++i )
            if ( G->basicOrbit[i] )
               freeIntArrayDegree( G->basicOrbit[i]);
         freePtrArrayBaseSize( G->basicOrbit );
      }
      if ( G->schreierVec ) {
         for ( i = 1 ; i <= G->baseSize ; ++i )
            if ( G->schreierVec[i] )
               freePtrArrayDegree( G->schreierVec[i]);
         freePtrArrayBaseSize( G->schreierVec );
      }
      if ( G->completeOrbit ) {
         for ( i = 1 ; i <= G->baseSize+1 ; ++i )
            if ( G->completeOrbit[i] )
               freeIntArrayDegree( G->completeOrbit[i]);
         freePtrArrayBaseSize( G->completeOrbit );
      }
      if ( G->orbNumberOfPt ) {
         for ( i = 1 ; i <= G->baseSize+1 ; ++i )
            if ( G->orbNumberOfPt[i] )
               freeIntArrayDegree( G->orbNumberOfPt[i]);
         freePtrArrayBaseSize( G->orbNumberOfPt );
      }
      if ( G->startOfOrbitNo ) {
         for ( i = 1 ; i <= G->baseSize ; ++i )
            if ( G->startOfOrbitNo[i] )
               freeIntArrayDegree( G->startOfOrbitNo[i]);
         freePtrArrayBaseSize( G->startOfOrbitNo );
      }
   }
   for ( gen = G->generator ; gen ; gen = genNext ) {
      genNext = gen->next;
      deletePermutation( gen);
   }
   if ( G->omega )
      freeIntArrayDegree( G->invOmega);
   if ( G->invOmega )
      freeIntArrayDegree( G->invOmega);
}


/*-------------------------- newRBase -------------------------------------*/

/* Note invOmega field is not allocated here. */

RBase *newRBase(
   const Unsigned degree)
{
   RBase *newBase = allocRBase();

   newBase->k = 0;
   newBase->ell = 0;
   newBase->degree = degree;
   newBase->PsiStack = newPartitionStack( degree);
   newBase->aAA = allocRefinementArrayDegree();
   newBase->n_ = allocIntArrayBaseSize();
   newBase->p_ = allocIntArrayBaseSize();
   newBase->alphaHat = allocIntArrayBaseSize();
   newBase->a_ = allocIntArrayDegree();
   newBase->b_ = allocIntArrayDegree();
   newBase->omega = allocIntArrayDegree();
   newBase->invOmega = allocIntArrayDegree();

   return newBase;
}


/*-------------------------- deleteRbase ----------------------------------*/

void deleteRBase(
   RBase *oldBase)
{
   if ( oldBase->PsiStack )
      deletePartitionStack( oldBase->PsiStack);
   freeRefinementArrayDegree( oldBase->aAA);
   freeIntArrayBaseSize( oldBase->n_);
   freeIntArrayBaseSize( oldBase->p_);
   freeIntArrayDegree( oldBase->alphaHat);
   freeIntArrayDegree( oldBase->a_);
   freeIntArrayDegree( oldBase->b_);

   freeRBase( oldBase);
}


/*-------------------------- newRPriorityQueue-----------------------------*/

/* This function creates a new, initially-empty R-Priority queue. */

RPriorityQueue *newRPriorityQueue(
   const Unsigned degree,
   const Unsigned maxSize)
{
   RPriorityQueue *newRPriorityQueue = allocRPriorityQueue();

   newRPriorityQueue->size = 0;
   newRPriorityQueue->degree = degree;
   newRPriorityQueue->maxSize = maxSize;
   if ( maxSize > degree / 2 )
      newRPriorityQueue->pointList = allocIntArrayDegree();
   else {
      newRPriorityQueue->pointList = malloc( (maxSize+2) * sizeof(Unsigned) );
      if ( !newRPriorityQueue->pointList )
         ERROR( "newRPriorityQueue", "Out of memory.")
   }

   return newRPriorityQueue;
}


/*-------------------------- deleteRPriorityQueue -------------------------*/

void deleteRPriorityQueue(
   RPriorityQueue *oldRPriorityQueue)
{
   if ( oldRPriorityQueue->pointList )
   if ( oldRPriorityQueue->maxSize > oldRPriorityQueue->degree / 2 )
      freeIntArrayDegree( oldRPriorityQueue->pointList);
   else
      free( oldRPriorityQueue->pointList );
   freeRPriorityQueue( oldRPriorityQueue);
}


/*-------------------------- newTrivialWord -------------------------------*/

Word *newTrivialWord( void)
{
   ERROR( "newTrivialWord", "Procedure not yet implemented.");
}


/*-------------------------- newZeroMatrix --------------------------------*/

Matrix_01 *newZeroMatrix(
   const Unsigned setSize,
   const Unsigned numberOfRows,
   const Unsigned numberOfCols)
{
   Matrix_01 *M;
   Unsigned i, j;

   M = (Matrix_01 *) malloc( sizeof(Matrix_01) );
   if ( !M )
      ERROR( "newZeroMatrix", "Out of memory.")

   M->unused = NULL;
   M->field = NULL;
   M->entry = (char **) malloc( sizeof(char *) * (numberOfRows+2) );
   if ( !M->entry )
      ERROR( "newZeroMatrix", "Out of memory.")
   M->setSize = setSize;
   M->numberOfRows = numberOfRows;
   M->numberOfCols = numberOfCols;
   for ( i = 1 ; i <= numberOfRows ; ++i ) {
      M->entry[i] = (char *) malloc( numberOfCols+1);
      if ( !M->entry[i] )
         ERROR( "newZeroMatrix", "Out of memory.")
      for ( j = 1 ; j <= numberOfCols ; ++j )
         M->entry[i][j] = 0;
   }

   return M;
}


/*-------------------------- newRelatorFromWord ---------------------------*/

/* The function newRelatorFromWord( w, fbRelFlag, doubleFlag) returns a new 
   relator created from a word w.  The length and rel fields are filled in.  
   If fbRelFlag is true, the fRel and bRel fields are also filled in.  If
   doubleFlag is true, the rel, fRel (if present), and bRel (if present)
   fields contain two copies of the relator.  (The length counts one copy
   only.)  Note the rel, fRel, and bRel arrays start at 1.  Relators are
   reduced by removing consecutive entries that are inverses; the word w
   is similarly reduced.  NOTE INVERSE PERMUTATIONS MUST BE PRESENT.  

   The function returns null if the relator reduces to a trivial word, or
   if it could not be allocated. */

Relator *newRelatorFromWord(
   Word *const w,
   const Unsigned fbRelFlag,
   const Unsigned doubleFlag)
{
   Relator *r;
   Unsigned i, j;

   /* First we reduce w.  If it attains length 0, return NULL. */
   i = 1;
   while ( i < w->length-1 ) 
      if ( w->position[i+1] == w->position[i]->invPermutation ) {
         for ( j = i ; j <= w->length-2 ; ++j )
            w->position[j] = w->position[j+2];
         w->length -= 2;
         if ( i > 1 )
            --i;
      }
      else 
         ++i;
   if ( w->length == 0 )
      return NULL;
   
   /* Now we allocate and fill in fields of r. */
   r = allocRelator();
   r->length = w->length;
   r->level = UNKNOWN;
   r->rel = (Permutation **) malloc( (2+r->length+doubleFlag*r->length) *
                                     sizeof(Permutation *) );
   if ( !r->rel )
      ERROR( "newRelatorFromWord", "Out of memory.")
   for ( i = 1 ; i <= w->length ; ++i )
      r->rel[i] = w->position[i];
   if ( doubleFlag )
      for ( i = w->length+1 ; i <= 2*w->length ; ++i )
         r->rel[i] = w->position[i-w->length];
   r->rel[i] = NULL;
   if ( fbRelFlag ) {
      r->fRel = (Unsigned **) malloc( (2+r->length+doubleFlag*r->length) *
                                     sizeof(Unsigned *) );
      if ( !r->fRel )
         ERROR( "newRelatorFromWord", "Out of memory.")
      r->bRel = (Unsigned **) malloc( (2+r->length+doubleFlag*r->length) *
                                     sizeof(Unsigned *) );
      if ( !r->bRel )
         ERROR( "newRelatorFromWord", "Out of memory.")
      for ( i = 1 ; i <= (1+doubleFlag)*w->length ; ++i ) {
         r->fRel[i] = r->rel[i]->image;
         r->bRel[i] = r->rel[i]->invImage;
      }
      r->fRel[i] = NULL;
      r->bRel[i] = NULL;
   }

   return r;
}
