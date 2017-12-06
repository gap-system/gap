#ifndef GAP_ATOMIC_H
#define GAP_ATOMIC_H

#include <src/system.h>

#ifndef HPCGAP
#error This header is only meant to be used with HPC-GAP
#endif

#ifndef WARD_ENABLED

// disable -Wundef temporarily, to avoid warnings about AO_AO_TS_T
// inside of libatomic_ops' header files.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundef"
#include <atomic_ops.h>
#pragma GCC diagnostic pop

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
