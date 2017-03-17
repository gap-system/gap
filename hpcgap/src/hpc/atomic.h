#ifndef GAP_ATOMIC_H
#define GAP_ATOMIC_H

#if !defined(HPCGAP)

/*
 * HPC-GAP stubs.
 */

#define MEMBAR_READ() ((void) 0)
#define MEMBAR_WRITE() ((void) 0)

#else

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

#endif // HPCGAP

#endif // GAP_ATOMIC_H
