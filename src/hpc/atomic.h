/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_ATOMIC_H
#define GAP_ATOMIC_H

#include "common.h"

#ifndef HPCGAP
#error This header is only meant to be used with HPC-GAP
#endif

#ifndef WARD_ENABLED
#include <atomic_ops.h>
#else
typedef size_t AO_t;
#endif

#define MEMBAR_READ() (AO_nop_read())
#define MEMBAR_WRITE() (AO_nop_write())
#define MEMBAR_FULL() (AO_nop_full())
#define COMPARE_AND_SWAP(a,b,c) (AO_compare_and_swap_full((a), (b), (c)))
#define ATOMIC_INC(x) (AO_fetch_and_add1((x)))
#define ATOMIC_DEC(x) (AO_fetch_and_sub1((x)))

typedef AO_t AtomicUInt;

#endif // GAP_ATOMIC_H
