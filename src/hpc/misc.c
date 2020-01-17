/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "hpc/misc.h"

#include <stdlib.h>
#include <string.h>

/****************************************************************************
**
*V  ThreadUI  . . . . . . . . . . . . . . . . . . . .  support UI for threads
**
*/
UInt ThreadUI = 1;

/****************************************************************************
**
*V  DeadlockCheck  . . . . . . . . . . . . . . . . . .  check for deadlocks
**
*/
UInt DeadlockCheck = 1;

/****************************************************************************
**
*V  SyNumProcessors  . . . . . . . . . . . . . . . . . number of logical CPUs
**
*/
#ifdef NUM_CPUS
UInt SyNumProcessors = NUM_CPUS;
#else
UInt SyNumProcessors = 4;
#endif

/****************************************************************************
**
*V  SyNumGCThreads  . . . . . . . . . . . . . . . number of GC worker threads
**
*/
UInt SyNumGCThreads = 0;

/****************************************************************************
**
*V  SingleThreadStartup . . . . . . . . .  start HPC-GAP with just one thread
**
*/
UInt SingleThreadStartup = 0;

/****************************************************************************
**
*F  MergeSort helpers
**
*/

static void Merge(char * to,
                  char * from1,
                  UInt   size1,
                  char * from2,
                  UInt   size2,
                  UInt   width,
                  int (*lessThan)(const void * a, const void * b))
{
    while (size1 && size2) {
        if (lessThan(from1, from2)) {
            memcpy(to, from1, width);
            from1 += width;
            size1--;
        }
        else {
            memcpy(to, from2, width);
            from2 += width;
            size2--;
        }
        to += width;
    }
    if (size1)
        memcpy(to, from1, size1 * width);
    else
        memcpy(to, from2, size2 * width);
}

static void MergeSortRecurse(char * data,
                             char * aux,
                             UInt   count,
                             UInt   width,
                             int (*lessThan)(const void * a, const void *))
{
    UInt nleft, nright;
    /* assert(count > 1); */
    if (count == 2) {
        if (!lessThan(data, data + width)) {
            memcpy(aux, data, width);
            memcpy(data, data + width, width);
            memcpy(data + width, aux, width);
        }
        return;
    }
    nleft = count / 2;
    nright = count - nleft;
    if (nleft > 1)
        MergeSortRecurse(data, aux, nleft, width, lessThan);
    if (nright > 1)
        MergeSortRecurse(data + nleft * width, aux + nleft * width, nright,
                         width, lessThan);
    memcpy(aux, data, count * width);
    Merge(data, aux, nleft, aux + nleft * width, nright, width, lessThan);
}

/****************************************************************************
**
*F  MergeSort() . . . . . . . . . . . . . . . sort an array using mergesort.
**
**  MergeSort() sorts an array of 'count' elements of individual size 'width'
**  with ordering determined by the parameter 'lessThan'. The 'lessThan'
**  function is to return a non-zero value if the first argument is less
**  than the second argument, zero otherwise.
*/

void MergeSort(void * data,
               UInt   count,
               UInt   width,
               int (*lessThan)(const void * a, const void *))
{
    char * aux = alloca(count * width);
    if (count > 1)
        MergeSortRecurse(data, aux, count, width, lessThan);
}
