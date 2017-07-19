#ifndef GAP_HPC_MISC_H
#define GAP_HPC_MISC_H

#include "system.h"

#ifndef HPCGAP
#error This header is only meant to be used with HPC-GAP
#endif

/****************************************************************************
**
*V  ThreadUI  . . . . . . . . . . . . . . . . . . . .  support UI for threads
**
*/
extern UInt ThreadUI;

/****************************************************************************
**
*V  DeadlockCheck  . . . . . . . . . . . . . . . . . .  check for deadlocks
**
*/
extern UInt DeadlockCheck;

/****************************************************************************
**
*V  SyNumProcessors  . . . . . . . . . . . . . . . . . number of logical CPUs
**
*/
extern UInt SyNumProcessors;

/****************************************************************************
**
*V  SyNumGCThreads  . . . . . . . . . . . . . . . number of GC worker threads
**
*/
extern UInt SyNumGCThreads;

/****************************************************************************
**
*F  MergeSort() . . . . . . . . . . . . . . . sort an array using mergesort.
**
**  MergeSort() sorts an array of 'count' elements of individual size 'width'
**  with ordering determined by the parameter 'lessThan'. The 'lessThan'
**  function is to return a non-zero value if the first argument is less
**  than the second argument, zero otherwise.
**
*/

extern void MergeSort(void *data, UInt count, UInt width,
  int (*lessThan)(const void *a, const void *));


#endif
