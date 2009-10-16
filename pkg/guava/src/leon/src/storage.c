
/* File storage.c.  Contains functions to allocate and free memory.
   For certain commonly used sizes, memory is never actually freed; rather
   a linked list of allocated but currently unused segments of those sizes
   are maintained, and new allocations are taken from these linked lists
   when possible.  Prior to any allocations, the procedure
   InitializeStorageManager must be invoked; this merely informs the
   routines of the degree of the group.  The memory allocation functions
   are as follows; for each, there is a corresponding function to free
   memory.  All allocation functions return a pointer to the memory
   allocated; an allocation failure terminates the program.

        Function                Struct size or            Array size
                              array component size

      allocIntArrayBaseSize      sizeof(Int)              options.maxBaseSize
      allocIntArrayDegree        sizeof(Int)              degree+2
      allocBooleanArrayDegree    sizeof(char)             degree+2
      allocPtrArrayWordSize      sizeof(Permutation *)    options.maxWordLength
      allocPtrArrayBaseSize      sizeof(Permutation *)    options.maxBaseSize
      allocPtrArrayDegree        sizeof(Permutation *)    degree+2
      allocPermutation           sizeof(Permutation)
      allocPermGroup             sizeof(PermGroup)
      allocPartitionStack        sizeof(PartitionStack)
      allocPointSet              sizeof(PointSet)
      allocWord                  sizeof(Word) */

#include <stddef.h>
#include <stdlib.h>
#include "group.h"
#include "errmesg.h"

extern GroupOptions options;

CHECK( storag)

 static Unsigned degree;
 static UnsignedS *headerIntArrayDegree = NULL;
 static char *headerBooleanArrayDegree = NULL;
 static char *headerBooleanArrayBaseSize = NULL;
 static UnsignedS *headerPtrArrayDegree = NULL;
 static UnsignedS *headerPtrArrayBaseSize = NULL;
 static UnsignedS *headerPtrArrayWordSize = NULL;
 static UnsignedS *headerIntArrayBaseSize = NULL;
 static unsigned long *headerLongArrayBaseSize = NULL;
 static Permutation *headerPermutation = NULL;
 static PermGroup *headerPermGroup = NULL;
 static Partition *headerPartition = NULL;
 static PartitionStack *headerPartitionStack = NULL;
 static RBase *headerRBase = NULL;
 static RPriorityQueue *headerRPriorityQueue = NULL;
 static PointSet *headerPointSet = NULL;
 static FactoredInt * headerFactoredInt = NULL;
 static Word *headerWord = NULL;
 static Relator *headerRelator = NULL;
 static OccurenceOfGen *headerOccurenceOfGen = NULL;
 static Refinement *headerRefinementArrayDegree = NULL;
 static Field *headerField = NULL;

typedef enum {
   intArrayDegree,
   booleanArrayDegree,
   booleanArrayBaseSize,
   ptrArrayDegree,
   intArrayBaseSize,
   longArrayBaseSize,
   ptrArrayBaseSize,
   ptrArrayWordSize,
   permutation,
   permGroup,
   partition,
   partitionStack,
   rBase,
   rPriorityQueue,
   pointSet,
   factoredInt,
   word,
   relator,
   occurenceOfGen,
   field
} allocType;
unsigned long allocCount[25] = {0};


/*-------------------------- initializeStorageManager ---------------------*/

void initializeStorageManager( Unsigned degreeOfGroup)
{
   degree = degreeOfGroup;
}


/*-------------------------- allocIntArrayDegree --------------------------*/

UnsignedS *allocIntArrayDegree( void)
{
   UnsignedS *address;
   if ( headerIntArrayDegree ) {
      address = headerIntArrayDegree;
      headerIntArrayDegree = *( (UnsignedS **) headerIntArrayDegree );
   }
   else {
#ifdef HIGH_MEM_OPTION
      address = (UnsignedS *) highMemMalloc( (degree+2) * sizeof(UnsignedS) );
#else
      address = (UnsignedS *) malloc( (degree+2) * sizeof(UnsignedS) );
#endif
      if ( address == NULL )
         ERROR( "allocIntArrayDegree", "Out of memory");
   }
   ++allocCount[intArrayDegree];
   return address;
}


/*-------------------------- freeIntArrayDegree ---------------------------*/

void freeIntArrayDegree( UnsignedS *address)
{
   *( (UnsignedS **) address ) = headerIntArrayDegree;
   headerIntArrayDegree = address;
   --allocCount[intArrayDegree];
}


/*-------------------------- allocBooleanArrayDegree ----------------------*/

char *allocBooleanArrayDegree( void)
{
   char *address;
   if ( headerBooleanArrayDegree ) {
      address = headerBooleanArrayDegree;
      headerBooleanArrayDegree = *( (char **) headerBooleanArrayDegree );
   }
   else {
      address = (char *) malloc( (degree+2) * sizeof(char) );
      if ( address == NULL )
         ERROR( "allocBooleanArrayDegree", "Out of memory");
   }
   ++allocCount[booleanArrayDegree];
   return address;
}


/*-------------------------- freeBooleanArrayDegree -----------------------*/

void freeBooleanArrayDegree( char *address)
{
   *( (char **) address ) = headerBooleanArrayDegree;
   headerBooleanArrayDegree = address;
   --allocCount[booleanArrayDegree];
}


/*-------------------------- allocBooleanArrayBaseSize ----------------------*/

char *allocBooleanArrayBaseSize( void)
{
   char *address;
   if ( headerBooleanArrayBaseSize ) {
      address = headerBooleanArrayBaseSize;
      headerBooleanArrayBaseSize = *( (char **) headerBooleanArrayBaseSize );
   }
   else {
      address = (char *) malloc( (options.maxBaseSize+2) * sizeof(char) );
      if ( address == NULL )
         ERROR( "allocBooleanArrayBaseSize", "Out of memory");
   }
   ++allocCount[booleanArrayBaseSize];
   return address;
}


/*-------------------------- freeBooleanArrayBaseSize -----------------------*/

void freeBooleanArrayBaseSize( char *address)
{
   *( (char **) address ) = headerBooleanArrayBaseSize;
   headerBooleanArrayBaseSize = address;
   --allocCount[booleanArrayBaseSize];
}


/*-------------------------- allocPtrArrayDegree --------------------------*/

void *allocPtrArrayDegree( void)
{
   void *address;
   if ( headerPtrArrayDegree ) {
      address = headerPtrArrayDegree;
      headerPtrArrayDegree = *( (void **) headerPtrArrayDegree );
   }
   else {
#ifdef HIGH_MEM_OPTION
      address = highMemMalloc( (degree+2) * sizeof (void *) );
#else
      address = malloc( (degree+2) * sizeof (void *) );
#endif
      if ( address == NULL )
         ERROR( "allocPtrArrayDegree", "Out of memory");
   }
   ++allocCount[ptrArrayDegree];
   return address;
}


/*-------------------------- freePtrArrayDegree ---------------------------*/

void freePtrArrayDegree( void *address)
{
   *( (void **) address ) = headerPtrArrayDegree;
   headerPtrArrayDegree = address;
   --allocCount[ptrArrayDegree];
}


/*-------------------------- allocPtrArrayWordSize ------------------------*/

void *allocPtrArrayWordSize( void)
{
   void *address;
   if ( headerPtrArrayWordSize ) {
      address = headerPtrArrayWordSize;
      headerPtrArrayWordSize = *( (void **) headerPtrArrayWordSize );
   }
   else {
      address = malloc( (options.maxWordLength+2) * sizeof (void *) );
      if ( address == NULL )
         ERROR( "allocPtrArrayWordSize", "Out of memory");
   }
   ++allocCount[ptrArrayWordSize];
   return address;
}


/*-------------------------- freePtrArrayWordSize -------------------------*/

void freePtrArrayWordSize( void *address)
{
   *( (void **) address ) = headerPtrArrayWordSize;
   headerPtrArrayWordSize = address;
   --allocCount[ptrArrayWordSize];
}


/*-------------------------- allocPtrArrayBaseSize ------------------------*/

void *allocPtrArrayBaseSize( void)
{
   void *address;
   if ( headerPtrArrayBaseSize ) {
      address = headerPtrArrayBaseSize;
      headerPtrArrayBaseSize = *( (void **) headerPtrArrayBaseSize );
   }
   else {
      address = malloc( (options.maxBaseSize+2) * sizeof (void *) );
      if ( address == NULL )
         ERROR( "allocPtrArrayBaseSize", "Out of memory");
   }
   ++allocCount[ptrArrayBaseSize];
   return address;
}


/*-------------------------- freePtrArrayBaseSize -------------------------*/

void freePtrArrayBaseSize( void *address)
{
   *( (void **) address ) = headerPtrArrayBaseSize;
   headerPtrArrayBaseSize = address;
   --allocCount[ptrArrayBaseSize];
}


/*-------------------------- allocIntArrayBaseSize ------------------------*/

UnsignedS *allocIntArrayBaseSize( void)
{
   UnsignedS *address;
   if ( headerIntArrayBaseSize ) {
      address = headerIntArrayBaseSize;
      headerIntArrayBaseSize = *( (UnsignedS **) headerIntArrayBaseSize );
   }
   else {
      address = (UnsignedS *) malloc( (options.maxBaseSize+2) * sizeof(UnsignedS) );
      if ( address == NULL )
         ERROR( "allocIntArrayBaseSize", "Out of memory");
   }
   ++allocCount[intArrayBaseSize];
   return address;
}


/*-------------------------- freeIntArrayBaseSize -------------------------*/

void freeIntArrayBaseSize( UnsignedS *address)
{
   *( (UnsignedS **) address ) = headerIntArrayBaseSize;
   headerIntArrayBaseSize = address;
   --allocCount[intArrayBaseSize];
}


/*-------------------------- allocLongArrayBaseSize ------------------------*/

unsigned long *allocLongArrayBaseSize( void)
{
   unsigned long *address;
   if ( headerLongArrayBaseSize ) {
      address = headerLongArrayBaseSize;
      headerLongArrayBaseSize = *( (unsigned long **) headerLongArrayBaseSize );
   }
   else {
      address = (unsigned long *) malloc( (options.maxBaseSize+2) * sizeof(unsigned long) );
      if ( address == NULL )
         ERROR( "allocLongArrayBaseSize", "Out of memory");
   }
   ++allocCount[longArrayBaseSize];
   return address;
}


/*-------------------------- freeLongArrayBaseSize -------------------------*/

void freeLongArrayBaseSize( unsigned long *address)
{
   *( (unsigned long **) address ) = headerLongArrayBaseSize;
   headerLongArrayBaseSize = address;
   --allocCount[longArrayBaseSize];
}


/*-------------------------- allocPermutation -----------------------------*/

Permutation *allocPermutation( void)
{
   Permutation *address;
   Unsigned essentialArraySize;
   if ( headerPermutation ) {
      address = headerPermutation;
      headerPermutation = headerPermutation->next;
   }
   else {
      address = (Permutation *) malloc( sizeof(Permutation) );
      if ( address == NULL )
         ERROR( "allocPermutation", "Out of memory");
   }
   address->name[0] = '\0';
   address->image = NULL;
   address->invImage = NULL;
   address->invPermutation = NULL;
   address->word = NULL;
   address->occurHeader = NULL;
   essentialArraySize = (options.maxBaseSize+1) / 32 + 1;
   address->essential = (unsigned long *) 
                        malloc( essentialArraySize * sizeof(unsigned long) );
   if ( address->essential == NULL )
      ERROR( "allocPermutation", "Out of memory");
   ++allocCount[permutation];
   return address;
}

/*-------------------------- freePermutation ------------------------------*/

void freePermutation( Permutation *address)
{
   address->next = headerPermutation;
   headerPermutation = address;
   --allocCount[permutation];
}


/*-------------------------- allocPermGroup -------------------------------*/

PermGroup *allocPermGroup( void)
{
   PermGroup *address;
   if ( headerPermGroup ) {
      address = headerPermGroup;
      headerPermGroup = *( (PermGroup **) headerPermGroup );
   }
   else {
      address = (PermGroup *) malloc( sizeof(PermGroup) );
      if ( address == NULL )
         ERROR( "allocPermGroup", "Out of memory");
   }
   address->order = NULL;
   address->base = NULL;
   address->basicOrbLen = NULL;
   address->basicOrbit = NULL;
   address->completeOrbit = NULL;
   address->orbNumberOfPt = NULL;
   address->startOfOrbitNo = NULL;
   address->schreierVec = NULL;
   address->generator = NULL;
   address->omega = NULL;
   address->invOmega = NULL;
   address->relator = NULL;
   ++allocCount[permGroup];
   return address;
}


/*-------------------------- freePermGroup --------------------------------*/

void freePermGroup( PermGroup *address)
{
   *( (PermGroup **) address) = headerPermGroup;
   headerPermGroup = address;
   --allocCount[permGroup];
}


/*-------------------------- allocPartition -------------------------------*/

Partition *allocPartition( void)
{
   Partition *address;
   if ( headerPartition ) {
      address = headerPartition;
      headerPartition = *( (Partition **) headerPartition );
   }
   else {
      address = (Partition *) malloc( sizeof(Partition) );
      if ( address == NULL )
         ERROR( "allocPartition", "Out of memory");
   }
   return address;
}


/*-------------------------- freePartition ---------------------------*/

void freePartition( Partition *address)
{
   *( (Partition **) address) = headerPartition;
   headerPartition = address;
}


/*-------------------------- allocPartitionStack --------------------------*/

PartitionStack *allocPartitionStack( void)
{
   PartitionStack *address;
   if ( headerPartitionStack ) {
      address = headerPartitionStack;
      headerPartitionStack = *( (PartitionStack **) headerPartitionStack );
   }
   else {
      address = (PartitionStack *) malloc( sizeof(PartitionStack) );
      if ( address == NULL )
         ERROR( "allocPartitionStack", "Out of memory");
   }
   return address;
}


/*-------------------------- freePartitionStack ---------------------------*/

void freePartitionStack( PartitionStack *address)
{
   *( (PartitionStack **) address) = headerPartitionStack;
   headerPartitionStack = address;
}


/*-------------------------- allocRBase -----------------------------------*/

RBase *allocRBase( void)
{
   RBase *address;
   if ( headerRBase ) {
      address = headerRBase;
      headerRBase = *( (RBase **) headerRBase );
   }
   else {
      address = (RBase *) malloc( sizeof(RBase) );
      if ( address == NULL )
         ERROR( "allocRBase", "Out of memory");
   }
   return address;
}


/*-------------------------- freeRBase ------------------------------------*/

void freeRBase( RBase *address)
{
   *( (RBase **) address) = headerRBase;
   headerRBase = address;
}


/*-------------------------- allocRPriorityQueue --------------------------*/

RPriorityQueue *allocRPriorityQueue( void)
{
   RPriorityQueue *address;
   if ( headerRPriorityQueue ) {
      address = headerRPriorityQueue;
      headerRPriorityQueue = *( (RPriorityQueue **) headerRPriorityQueue );
   }
   else {
      address = (RPriorityQueue *) malloc( sizeof(RPriorityQueue) );
      if ( address == NULL )
         ERROR( "allocRPriorityQueue", "Out of memory");
   }
   return address;
}


/*-------------------------- freeRPriorityQueue ---------------------------*/

void freeRPriorityQueue( RPriorityQueue *address)
{
   *( (RPriorityQueue **) address) = headerRPriorityQueue;
   headerRPriorityQueue = address;
}


/*-------------------------- allocPointSet ------------------------------------*/

PointSet *allocPointSet( void)
{
   PointSet *address;
   if ( headerPointSet ) {
      address = headerPointSet;
      headerPointSet = *( (PointSet **) headerPointSet );
   }
   else {
      address = (PointSet *) malloc( sizeof(PointSet) );
      if ( address == NULL )
         ERROR( "allocPointSet", "Out of memory");
   }
   return address;
}


/*-------------------------- freePointSet --------------------------------------*/

void freePointSet( PointSet *address)
{
   *( (PointSet **) address) = headerPointSet;
   headerPointSet = address;
}


/*-------------------------- allocFactoredInt ---------------------------------*/

FactoredInt *allocFactoredInt( void)
{
   FactoredInt *address;
   if ( headerFactoredInt ) {
      address = headerFactoredInt;
      headerFactoredInt = *( (FactoredInt **)  headerFactoredInt);
   }
   else {
      address = (FactoredInt *) malloc( sizeof(FactoredInt) );
      if ( address == NULL )
         ERROR( "allocFactoredInt", "Out of memory");
   }
   ++allocCount[factoredInt];
   return address;
}


/*-------------------------- freeFactoredInt -----------------------------------*/

void freeFactoredInt( FactoredInt *address)
{
   *( (FactoredInt **) address) = headerFactoredInt;
   headerFactoredInt = address;
   --allocCount[factoredInt];
}


/*-------------------------- allocWord ------------------------------------*/

Word *allocWord( void)
{
   Word *address;
   if ( headerWord ) {
      address = headerWord;
      headerWord = *( (Word **) headerWord );
   }
   else {
      address = (Word *) malloc( sizeof(Word) );
      if ( address == NULL )
         ERROR( "allocWord", "Out of memory");
   }
   ++allocCount[word];
   return address;
}


/*-------------------------- freeWord -------------------------------------*/

void freeWord( Word *address)
{
   *( (Word **) address) = headerWord;
   headerWord = address;
   --allocCount[word];
}


/*-------------------------- allocRefinementArrayDegree -------------------*/

Refinement *allocRefinementArrayDegree( void)
{
   Refinement *address;
   if ( headerRefinementArrayDegree ) {
      address = headerRefinementArrayDegree;
      headerRefinementArrayDegree =
                        *( (Refinement **) headerRefinementArrayDegree );
   }
   else {
      address = (Refinement *) malloc( (degree+2) * sizeof(Refinement) );
      if ( address == NULL )
         ERROR( "allocRefinementArrayDegree", "Out of memory");
   }
   return address;
}


/*-------------------------- freeRefinementArrayDegree --------------------------------*/

void freeRefinementArrayDegree( Refinement *address)
{
   *( (Refinement **) address) = headerRefinementArrayDegree;
   headerRefinementArrayDegree = address;
}

/*-------------------------- allocRelator ---------------------------------*/

Relator *allocRelator( void)
{
   Relator *address;
   if ( headerRelator ) {
      address = headerRelator;
      headerRelator = headerRelator->next;
   }
   else {
      address = (Relator *) malloc( sizeof(Relator) );
      if ( address == NULL )
         ERROR( "allocRelator", "Out of memory");
   }
   address->length = 0;
   address->rel = NULL;
   address->fRel = NULL;
   address->bRel = NULL;
   ++allocCount[relator];
   return address;
}

/*-------------------------- freeRelator ----------------------------------*/

void freeRelator( Relator *address)
{
   address->next = headerRelator;
   headerRelator = address;
   --allocCount[relator];
}


/*-------------------------- allocOccurenceOfGen --------------------------*/

OccurenceOfGen *allocOccurenceOfGen( void)
{
   OccurenceOfGen *address;
   if ( headerOccurenceOfGen ) {
      address = headerOccurenceOfGen;
      headerOccurenceOfGen = headerOccurenceOfGen->next;
   }
   else {
      address = (OccurenceOfGen *) malloc( sizeof(OccurenceOfGen) );
      if ( address == NULL )
         ERROR( "allocOccurenceOfGen", "Out of memory");
   }
   ++allocCount[occurenceOfGen];
   return address;
}

/*-------------------------- freeOccurenceOfGen ---------------------------*/

void freeOccurenceOfGen( OccurenceOfGen *address)
{
   address->next = headerOccurenceOfGen;
   headerOccurenceOfGen = address;
   --allocCount[occurenceOfGen];
}

      
/*-------------------------- allocField -------------------------------*/

Field *allocField( void)
{
   Field *address;
   if ( headerField ) {
      address = headerField;
      headerField = *( (Field **) headerField );
   }
   else {
      address = (Field *) malloc( sizeof(Field) );
      if ( address == NULL )
         ERROR( "allocField", "Out of memory");
   }
   address->sum = NULL;
   address->dif = NULL;
   address->prod = NULL;
   address->inv = NULL;
   return address;
}


/*-------------------------- freeField ---------------------------*/

void freeField( Field *address)
{
   *( (Field **) address) = headerField;
   headerField = address;
}
