
#define HB 0x8000
#define NHB 0x7fff

typedef struct {
   Word word;
   Unsigned *image;
} WordImagePair;

typedef struct {
   Unsigned pnt;
   Unsigned img;
   Permutation *gn;
} Deduction;

typedef struct {
   Unsigned curSize;
   Unsigned head;
   Unsigned tail;
   Deduction *deduc;
} DeductionQueue;

typedef struct {
   Unsigned size;
   Unsigned head;
   Unsigned tail;
   Unsigned *coset;
   Unsigned *image;
   Permutation **gen;
} DefinitionList;

typedef struct {
   BOOLEAN initialize;
   Unsigned maxDeducQueueSize;
   Unsigned genOrderLimit;
   Unsigned prodOrderLimit;
   BOOLEAN alwaysRebuildSvec;
   Unsigned maxExtraCosets;
   Unsigned percentExtraCosets;
} STCSOptions;


#define MAKE_EMPTY( queue)  {queue->head = queue->tail = queue->curSize = 0;}

#define ATTEMPT_ENQUEUE( queue, newDeduc)                  \
   {if ( queue->curSize < sOptions.maxDeducQueueSize ) {   \
       queue->deduc[queue->tail++] = newDeduc;             \
       if ( queue->tail == sOptions.maxDeducQueueSize )    \
          queue->tail = 0;                                 \
       ++queue->curSize;                                   \
    }}

#define DEQUEUE( queue, deduc)             \
   {deduc = queue->deduc[queue->head++];   \
    if ( queue->head == sOptions.maxDeducQueueSize )     \
       queue->head = 0;                                  \
    --queue->curSize;}

#define NOT_EMPTY( queue)  (queue->curSize != 0)


