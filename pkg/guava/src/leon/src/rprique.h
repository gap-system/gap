#ifndef RPRIQUE
#define RPRIQUE

extern void initFromPartnStack(
   RPriorityQueue *rpq,        /* R-priority queue to initialize. */
   PartitionStack *PiStack,    /* The partition stack. */
   Unsigned cellNumber,        /* The R-priority queue is initialized to cell
                                  cellNumber of top partition on bfPiStack */
   const RBase *const AAA)     /* Only omega and invOmega are needed. */
;

extern Unsigned removeMin(
   RPriorityQueue *rpq)         /* R-priority queue for remove operation. */
;

extern void makeEmpty(
   RPriorityQueue *rpq)     /* The priority queue to make empty. */
;

#endif
