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

static inline size_t num_words(packmat_mat m)
{
    return (size_t)layout_words(m.f->cpw, m.nrows, m.ncols);
}

// Two operands need the same context and equal dimensions
static inline void assert_same_shape(packmat_mat a, packmat_mat b)
{
    PACKMAT_ASSERT(a.f == b.f && a.nrows == b.nrows && a.ncols == b.ncols);
}

// MurmurHash64A multiplier, MurmurHash3 finaliser constants, and a fixed
// seed (the 64-bit golden ratio)
static const uint64_t HASH_M = 0xc6a4a7935bd1e995ull;
static const uint64_t HASH_F1 = 0xff51afd7ed558ccdull;
static const uint64_t HASH_F2 = 0xc4ceb9fe1a85ec53ull;
static const uint64_t HASH_SEED = 0x9e3779b97f4a7c15ull;

extern "C" {

uint64_t packmat_mat_get(packmat_mat m, uint32_t i, uint32_t j)
{
    PACKMAT_ASSERT(i < m.nrows && j < m.ncols);
    return kernels(m.f).mat_get(m.f, m.w, m.ncols, i, j);
}

void packmat_mat_set(packmat_mat m, uint32_t i, uint32_t j, uint64_t x)
{
    PACKMAT_ASSERT(i < m.nrows && j < m.ncols);
    kernels(m.f).mat_set(m.f, m.w, m.ncols, i, j, x);
}

uint64_t packmat_vec_get(packmat_mat v, uint32_t i)
{
    PACKMAT_ASSERT(v.nrows == 1 && i < v.ncols);
    return kernels(v.f).vec_get(v.f, v.w, i);
}

void packmat_vec_set(packmat_mat v, uint32_t i, uint64_t x)
{
    PACKMAT_ASSERT(v.nrows == 1 && i < v.ncols);
    kernels(v.f).vec_set(v.f, v.w, i, x);
}

void packmat_zero(packmat_mat m)
{
    const size_t words = num_words(m);
    if (words)
        memset(m.w, 0, words * sizeof(uint64_t));
}

void packmat_identity(packmat_mat m)
{
    kernels(m.f).identity(m.f, m.w, m.nrows, m.ncols);
}

void packmat_copy(packmat_mat dst, packmat_mat src)
{
    assert_same_shape(dst, src);
    const size_t words = num_words(src);
    if (words && dst.w != src.w)
        memcpy(dst.w, src.w, words * sizeof(uint64_t));
}

int packmat_equal(packmat_mat a, packmat_mat b)
{
    assert_same_shape(a, b);
    const size_t words = num_words(a);
    for (size_t k = 0; k < words; k++) {
        if (a.w[k] != b.w[k])
            return 0;
    }
    return 1;
}

int packmat_compare(packmat_mat a, packmat_mat b)
{
    assert_same_shape(a, b);
    return kernels(a.f).compare(a.f, a.w, b.w, num_words(a));
}

// h = SEED ^ (D * M) with D = nrows * 2^32 + ncols; for each word w:
//   k = w * M; k ^= k >> 47; k *= M; h ^= k; h *= M    (MurmurHash64A)
// then h ^= h >> 33; h *= F1; h ^= h >> 33; h *= F2; h ^= h >> 33
// (MurmurHash3 fmix64). All arithmetic is on 64-bit word values, so the
// result depends neither on the word size nor on the byte order.
uint64_t packmat_hash(packmat_mat m)
{
    const size_t   words = num_words(m);
    const uint64_t dims = ((uint64_t)m.nrows << 32) | m.ncols;
    uint64_t       h = HASH_SEED ^ (dims * HASH_M);
    for (size_t k = 0; k < words; k++) {
        uint64_t w = m.w[k] * HASH_M;
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

int packmat_is_zero(packmat_mat m)
{
    const size_t words = num_words(m);
    for (size_t k = 0; k < words; k++) {
        if (m.w[k])
            return 0;
    }
    return 1;
}

int packmat_is_one(packmat_mat m)
{
    return kernels(m.f).is_one(m.f, m.w, m.nrows, m.ncols);
}

int packmat_check_invariants(packmat_mat m)
{
    return kernels(m.f).check(m.f, m.w, m.nrows, m.ncols);
}

}    // extern "C"
