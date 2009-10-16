#ifndef STORAGE
#define STORAGE

extern void initializeStorageManager( Unsigned degreeOfGroup)
;

extern UnsignedS *allocIntArrayDegree( void)
;

extern void freeIntArrayDegree( UnsignedS *address)
;

extern char *allocBooleanArrayDegree( void)
;

extern void freeBooleanArrayDegree( char *address)
;

extern char *allocBooleanArrayBaseSize( void)
;

extern void freeBooleanArrayBaseSize( char *address)
;

extern void *allocPtrArrayDegree( void)
;

extern void freePtrArrayDegree( void *address)
;

extern void *allocPtrArrayWordSize( void)
;

extern void freePtrArrayWordSize( void *address)
;

extern void *allocPtrArrayBaseSize( void)
;

extern void freePtrArrayBaseSize( void *address)
;

extern UnsignedS *allocIntArrayBaseSize( void)
;

extern void freeIntArrayBaseSize( UnsignedS *address)
;

extern unsigned long *allocLongArrayBaseSize( void)
;

extern void freeLongArrayBaseSize( unsigned long *address)
;

extern Permutation *allocPermutation( void)
;

extern void freePermutation( Permutation *address)
;

extern PermGroup *allocPermGroup( void)
;

extern void freePermGroup( PermGroup *address)
;

extern Partition *allocPartition( void)
;

extern void freePartition( Partition *address)
;

extern PartitionStack *allocPartitionStack( void)
;

extern void freePartitionStack( PartitionStack *address)
;

extern RBase *allocRBase( void)
;

extern void freeRBase( RBase *address)
;

extern RPriorityQueue *allocRPriorityQueue( void)
;

extern void freeRPriorityQueue( RPriorityQueue *address)
;

extern PointSet *allocPointSet( void)
;

extern void freePointSet( PointSet *address)
;

extern FactoredInt *allocFactoredInt( void)
;

extern void freeFactoredInt( FactoredInt *address)
;

extern Word *allocWord( void)
;

extern void freeWord( Word *address)
;

extern Refinement *allocRefinementArrayDegree( void)
;

extern void freeRefinementArrayDegree( Refinement *address)
;

extern Relator *allocRelator( void)
;

extern void freeRelator( Relator *address)
;

extern OccurenceOfGen *allocOccurenceOfGen( void)
;

extern void freeOccurenceOfGen( OccurenceOfGen *address)
;

extern Field *allocField( void)
;

extern void freeField( Field *address)
;

#endif
