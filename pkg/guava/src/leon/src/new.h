#ifndef NEW
#define NEW

extern void deletePartition(
   Partition *partn)
;

extern PartitionStack *newPartitionStack(
   const Unsigned degree)             /* The degree for the partition stack. */
;

extern void deletePartitionStack(
   PartitionStack *partnStack)
;

extern CellPartitionStack *newCellPartitionStack(
   Partition *basePartn)             /* The base partition. */
;

extern Permutation *newIdentityPerm(
   Unsigned degree)                    /* The degree for the new permutation. */
;

extern Permutation *newUndefinedPerm(
   const Unsigned degree)             /* The degree for the new permutation. */
;

extern void deletePermutation(
   Permutation *oldPerm)         /* The permutation to be deleted. */
;

extern PermGroup *newTrivialPermGroup(
   Unsigned degree)                    /* The degree for the new group. */
;

extern void deletePermGroup(
   PermGroup *G)                  /* The permutation group to delete. */
;

extern RBase *newRBase(
   const Unsigned degree)
;

extern void deleteRBase(
   RBase *oldBase)
;

extern RPriorityQueue *newRPriorityQueue(
   const Unsigned degree,
   const Unsigned maxSize)
;

extern void deleteRPriorityQueue(
   RPriorityQueue *oldRPriorityQueue)
;

extern Word *newTrivialWord( void)
;

extern Matrix_01 *newZeroMatrix(
   const Unsigned setSize,
   const Unsigned numberOfRows,
   const Unsigned numberOfCols)
;

extern Relator *newRelatorFromWord(
   Word *const w,
   const Unsigned fbRelFlag,
   const Unsigned doubleFlag)
;

#endif
