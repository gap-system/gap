/* File rprique.c  Contains functions to manipulate an R-priority queue.
   An R-priority queue is a  priority queue that, after initialization,
   permits only removal operations.   The functions provided are:

      initFromPartnStack:  Initialize an R-priority queue to contain the
                           points in a specified cell of the top partition
                           on a specified partition stack.

      removeMin:           Removes the minimum point from an R-priority
                           queue.  Returns the point removed.

      makeEmpty:           Purges all points from an R-priority queue.

   Note that the header file group.h defines the type RPriorityQueue and
   provides a macro RPQ_SIZE returning the size of an R-priority queue
   and a macro RPQ_CLEAR making an R-priority queue empty.

   Internally, the points of the R-priority queue are sorted in
   descending order. */

#include <assert.h>

#include "group.h"
#include "storage.h"

CHECK( rpriqu)

#define qSortCutOff   10
#define RPQ_PUSH(a,b)  \
      {qSortStack[qSortTop][0] = a;  qSortStack[qSortTop++][1] = b;}
#define RPQ_POP(a,b)   \
      {a = qSortStack[--qSortTop][0];  b = qSortStack[qSortTop][1];}


/*-------------------------- initFromPartnStack ---------------------------*/

/* The function initFromPartnStack initializes an existing R-priority queue
   to the points in a given cell of the top partition on a given partition
   stack. */

void initFromPartnStack(
   RPriorityQueue *rpq,        /* R-priority queue to initialize. */
   PartitionStack *PiStack,    /* The partition stack. */
   Unsigned cellNumber,        /* The R-priority queue is initialized to cell
                                  cellNumber of top partition on bfPiStack */
   const RBase *const AAA)     /* Only omega and invOmega are needed. */
{
   Unsigned  i, j, p, a, b, k, m, t, left, right, mid, splitKey, bound, tRank,
             splitKeyRank, final;
   UnsignedS qSortStack[20][2];
   Unsigned  qSortTop = 0;
   UnsignedS *const omega = AAA->omega, *const invOmega = AAA->invOmega;
   char *temp;

  /* Check that r-priority queue has required size (for debugging). */
  /* assert( PiStack->cellSize[cellNumber] == rpq->maxSize);  */

   /* Copy the appropriate cell of the partition stack to the R-priority
      queue. */
   i = 0;
   for ( j = PiStack->startCell[cellNumber] , bound = j +
             PiStack->cellSize[cellNumber] ; j < bound ; ++j )
      rpq->pointList[++i] = PiStack->pointList[j];
   rpq->size = i;

   /* Sort the R-priority queue in descending order.  The following
      strategy is used:  If the size is <= 10, straight insertion sort
      is used.  Otherwise, if the size is >= degree/10, an array of flags
      is used.  Otherwise, quicksort is used, with sublists of size <= 10
      being handled by straight insertion sort. */

   /* If the size is <= 10, sort directly by straight insertion sort and
      return. */
   if ( rpq->size <= 10 ) {
      rpq->pointList[0] = 0;
      invOmega[0] = rpq->degree+1;
      for ( m = 2 ; m <= rpq->size ; ++m) {
         t = rpq->pointList[m];
         tRank = invOmega[t];
         k = m - 1;
         while ( invOmega[rpq->pointList[k]] < tRank ) {
            rpq->pointList[k+1] = rpq->pointList[k];
            --k;
         }
         rpq->pointList[k+1] = t;
      }
      return;
   }

   /* Otherwise, if the size is at least 1/10 the degree, we sort using an
      index into a Boolean array. */
   if ( rpq->size >= rpq->degree / 10 ) {
      temp = allocBooleanArrayDegree();
      for ( m = 1 ; m <= rpq->degree ; ++m )
         temp[m] = FALSE;
      for ( m = 1 ; m <= rpq->size ; ++m )
         temp[invOmega[rpq->pointList[m]]] = TRUE;
      p = 1;
      for ( m = rpq->degree ; m >= 1 ; --m )
         if ( temp[m] )
            rpq->pointList[p++] = omega[m];
      freeBooleanArrayDegree( temp);
      return;
   }

   /* In the remaining case, we partially sort using quicksort.  Sublists
      of size <= qSortCutOff are left unsorted.  A final pass with straight
      insertion sort completes the sort. */
   rpq->pointList[0] = 0;
   invOmega[0] = rpq->degree+1;
   if ( rpq->size > qSortCutOff ) {
      rpq->pointList[rpq->size+1] = rpq->degree + 1;
      invOmega[rpq->degree+1] = 0;
      RPQ_PUSH( 1, rpq->size);
   }
   while ( qSortTop >= 1 ) {
      RPQ_POP( a, b);
      while ( b - a >= qSortCutOff ) {
         left = a;  right = b + 1;  mid = (a + b) / 2;
         splitKey = rpq->pointList[mid];
         splitKeyRank = invOmega[splitKey];
         EXCHANGE( rpq->pointList[left], rpq->pointList[mid], t)
         do {
            while ( invOmega[rpq->pointList[++left]] > splitKeyRank )
               ;
            while ( invOmega[rpq->pointList[--right]] < splitKeyRank )
               ;
            if ( left < right )
               EXCHANGE( rpq->pointList[left], rpq->pointList[right], t)
         } while ( left < right );
         final = right;
         EXCHANGE( rpq->pointList[a], rpq->pointList[final], t)
         if ( final - a >= b - final )
            if ( b - final >= qSortCutOff ) {
               RPQ_PUSH( a, final-1);
               a = final + 1;
            }
            else
               b = final - 1;
         else
            if ( final - a >= qSortCutOff ) {
               RPQ_PUSH( final+1, b);
               b = final - 1;
            }
            else
               a = final + 1;
      }
   }

   /* Now finish with straight insertion sort. */
   for ( m = 2 ; m <= rpq->size ; ++m) {
      t = rpq->pointList[m];
      tRank = invOmega[t];
      k = m - 1;
      while ( invOmega[rpq->pointList[k]] < tRank ) {
         rpq->pointList[k+1] = rpq->pointList[k];
         --k;
      }
      rpq->pointList[k+1] = t;
   }
}


/*-------------------------- removeMin ------------------------------------*/

/* The function removeMin removes the minimum point from a given R-priority
   queue.  The function value returned is the point removed. */

Unsigned removeMin(
   RPriorityQueue *rpq)         /* R-priority queue for remove operation. */
{
   return rpq->pointList[ rpq->size-- ];
}


/*-------------------------- makeEmpty-------------------------------------*/

/* This function removes all points from an R-priority queue. */

void makeEmpty(
   RPriorityQueue *rpq)     /* The priority queue to make empty. */
{
   rpq->size = 0;
}
