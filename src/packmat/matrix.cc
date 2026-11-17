/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Entry access and whole-object operations. Kind-specific work goes
**  through the kernel table; word passes that the invariants make
**  kind-independent are done here.
*/

#include "kernels.h"

#include <string.h>

using namespace packmat;

static const Kernels * const KERNEL_TABLE[PACKMAT_NUM_KINDS] = {
    &gf2_kernels,
    &m64_kernels,
};

static inline const Kernels & kernels(const packmat_field * f)
{
    PACKMAT_ASSERT(f->kind < PACKMAT_NUM_KINDS);
    return *KERNEL_TABLE[f->kind];
}

static inline size_t
num_words(const packmat_field * f, uint32_t nrows, uint32_t ncols)
{
    return (size_t)layout_words(f->cpw, nrows, ncols);
}

// MurmurHash64A multiplier, MurmurHash3 finaliser constants, and a fixed
// seed (the 64-bit golden ratio)
static const uint64_t HASH_M = 0xc6a4a7935bd1e995ull;
static const uint64_t HASH_F1 = 0xff51afd7ed558ccdull;
static const uint64_t HASH_F2 = 0xc4ceb9fe1a85ec53ull;
static const uint64_t HASH_SEED = 0x9e3779b97f4a7c15ull;

extern "C" {

uint64_t packmat_mat_get(const packmat_field * f,
                         const uint64_t *      m,
                         uint32_t              ncols,
                         uint32_t              i,
                         uint32_t              j)
{
    return kernels(f).mat_get(f, m, ncols, i, j);
}

void packmat_mat_set(const packmat_field * f,
                     uint64_t *            m,
                     uint32_t              ncols,
                     uint32_t              i,
                     uint32_t              j,
                     uint64_t              x)
{
    kernels(f).mat_set(f, m, ncols, i, j, x);
}

uint64_t
packmat_vec_get(const packmat_field * f, const uint64_t * v, uint32_t i)
{
    return kernels(f).vec_get(f, v, i);
}

void packmat_vec_set(const packmat_field * f,
                     uint64_t *            v,
                     uint32_t              i,
                     uint64_t              x)
{
    kernels(f).vec_set(f, v, i, x);
}

void packmat_zero(const packmat_field * f,
                  uint64_t *            m,
                  uint32_t              nrows,
                  uint32_t              ncols)
{
    const size_t words = num_words(f, nrows, ncols);
    if (words)
        memset(m, 0, words * sizeof(uint64_t));
}

void packmat_identity(const packmat_field * f,
                      uint64_t *            m,
                      uint32_t              nrows,
                      uint32_t              ncols)
{
    kernels(f).identity(f, m, nrows, ncols);
}

void packmat_copy(const packmat_field * f,
                  uint64_t *            dst,
                  const uint64_t *      src,
                  uint32_t              nrows,
                  uint32_t              ncols)
{
    const size_t words = num_words(f, nrows, ncols);
    if (words && dst != src)
        memcpy(dst, src, words * sizeof(uint64_t));
}

int packmat_equal(const packmat_field * f,
                  const uint64_t *      a,
                  const uint64_t *      b,
                  uint32_t              nrows,
                  uint32_t              ncols)
{
    const size_t words = num_words(f, nrows, ncols);
    for (size_t k = 0; k < words; k++) {
        if (a[k] != b[k])
            return 0;
    }
    return 1;
}

int packmat_compare(const packmat_field * f,
                    const uint64_t *      a,
                    const uint64_t *      b,
                    uint32_t              nrows,
                    uint32_t              ncols)
{
    return kernels(f).compare(f, a, b, num_words(f, nrows, ncols));
}

// h = SEED ^ (D * M) with D = nrows * 2^32 + ncols; for each word w:
//   k = w * M; k ^= k >> 47; k *= M; h ^= k; h *= M    (MurmurHash64A)
// then h ^= h >> 33; h *= F1; h ^= h >> 33; h *= F2; h ^= h >> 33
// (MurmurHash3 fmix64). All arithmetic is on 64-bit word values, so the
// result depends neither on the word size nor on the byte order.
uint64_t packmat_hash(const packmat_field * f,
                      const uint64_t *      m,
                      uint32_t              nrows,
                      uint32_t              ncols)
{
    const size_t   words = num_words(f, nrows, ncols);
    const uint64_t dims = ((uint64_t)nrows << 32) | ncols;
    uint64_t       h = HASH_SEED ^ (dims * HASH_M);
    for (size_t k = 0; k < words; k++) {
        uint64_t w = m[k] * HASH_M;
        w ^= w >> 47;
        w *= HASH_M;
        h ^= w;
        h *= HASH_M;
    }
    h ^= h >> 33;
    h *= HASH_F1;
    h ^= h >> 33;
    h *= HASH_F2;
    h ^= h >> 33;
    return h;
}

int packmat_is_zero(const packmat_field * f,
                    const uint64_t *      m,
                    uint32_t              nrows,
                    uint32_t              ncols)
{
    const size_t words = num_words(f, nrows, ncols);
    for (size_t k = 0; k < words; k++) {
        if (m[k])
            return 0;
    }
    return 1;
}

int packmat_is_one(const packmat_field * f,
                   const uint64_t *      m,
                   uint32_t              nrows,
                   uint32_t              ncols)
{
    return kernels(f).is_one(f, m, nrows, ncols);
}

int packmat_check_invariants(const packmat_field * f,
                             const uint64_t *      m,
                             uint32_t              nrows,
                             uint32_t              ncols)
{
    return kernels(f).check(f, m, nrows, ncols);
}

}    // extern "C"
