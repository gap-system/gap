/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_HPC_MISC_H
#define GAP_HPC_MISC_H

#include "common.h"

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
*V  SingleThreadStartup . . . . . . . . .  start HPC-GAP with just one thread
**
*/
extern UInt SingleThreadStartup;

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

void MergeSort(void * data,
               UInt   count,
               UInt   width,
               int (*lessThan)(const void * a, const void *));

#endif  // GAP_HPC_MISC_H
