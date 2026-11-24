/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Helpers of the packmat unit tests: CHECK, a fixed-seed PRNG, Buf, a
**  word buffer with guard words, Field, storage for a context, and random
**  reference matrices.
*/

#ifndef PACKMAT_TEST_COMMON_H
#define PACKMAT_TEST_COMMON_H

#include "../packmat.h"
#include "ref.h"

#include <stdio.h>
#include <string.h>

#include <vector>

// Defined in test.cc
extern unsigned long checks, failures;
extern char          where[200];    // current test case, for messages

#define CHECK(cond)                                                          \
    do {                                                                     \
        checks++;                                                            \
        if (!(cond)) {                                                       \
            if (++failures <= 50)                                            \
                fprintf(stderr, "%s:%d: %s: CHECK(%s) failed\n", __FILE__,   \
                        __LINE__, where, #cond);                             \
        }                                                                    \
    } while (0)

// splitmix64, fixed seed
extern uint64_t rng_state;

inline uint64_t rnd()
{
    uint64_t z = (rng_state += 0x9e3779b97f4a7c15ull);
    z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ull;
    z = (z ^ (z >> 27)) * 0x94d049bb133111ebull;
    return z ^ (z >> 31);
}

// Random residue, biased towards 0, 1 and n-1
inline uint64_t rnd_residue(uint64_t n)
{
    switch (rnd() % 8) {
    case 0:
        return 0;
    case 1:
        return 1;
    case 2:
        return n - 1;
    default:
        return rnd() % n;
    }
}

static const uint64_t TWO63 = 1ull << 63;

// Moduli of the tests
// clang-format off
static const uint64_t MODULI[] = {
    ~0ull - 58,          // 2^64 - 59, prime
    ~0ull,               // 2^64 - 1, composite
    TWO63 + 29,          // >= 2^63: no Shoup
    TWO63,               // norm 0, composite
    TWO63 - 25,          // largest prime below 2^63
    (1ull << 61) - 1,    // Mersenne prime
    (1ull << 32) + 15,
    65521, 3, 4, 5, 6, 2
};
// clang-format on
static const size_t NUM_MODULI = sizeof(MODULI) / sizeof(MODULI[0]);

/****************************************************************************
**
**  Buffers with guard words on both sides
*/

#ifdef PACKMAT_TEST_SANITIZE
static const size_t GUARD = 0;    // exact allocations, so ASan sees overruns
#else
static const size_t GUARD = 2;
#endif
static const uint64_t SENTINEL = 0xdeadbeefcafef00dull;

struct Buf {
    size_t     words;
    uint64_t * mem;

    explicit Buf(size_t w) : words(w), mem(new uint64_t[w + 2 * GUARD])
    {
        for (size_t k = 0; k < w + 2 * GUARD; k++)
            mem[k] = SENTINEL;
    }
    ~Buf()
    {
        delete[] mem;
    }
    uint64_t * data()
    {
        return mem + GUARD;
    }
    packmat_mat view(const packmat_field * f, uint32_t nrows, uint32_t ncols)
    {
        return packmat_mat_view(f, data(), nrows, ncols);
    }
    bool guards_ok() const
    {
        for (size_t k = 0; k < GUARD; k++)
            if (mem[k] != SENTINEL || mem[GUARD + words + k] != SENTINEL)
                return false;
        return true;
    }
    bool same(const std::vector<uint64_t> & w) const
    {
        return w.size() == words &&
               (words == 0 ||
                memcmp(mem + GUARD, &w[0], words * sizeof(uint64_t)) == 0);
    }

  private:
    Buf(const Buf &);
    Buf & operator=(const Buf &);
};

/****************************************************************************
**
**  Contexts
*/

struct Field {
    std::vector<uint64_t> mem;    // 8-byte aligned storage of the context
    packmat_field *       f;

    Field(int kind, uint64_t n, int ranked)
        : mem((packmat_field_size(kind, n, ranked) + 7) / 8 + 1)
    {
        f = reinterpret_cast<packmat_field *>(&mem[0]);
        if (packmat_field_init(f, kind, n, ranked) != PACKMAT_OK) {
            fprintf(stderr, "cannot initialise kind %d, n = %llu\n", kind,
                    (unsigned long long)n);
            failures++;
        }
    }
};

/****************************************************************************
**
**  Reference matrices
*/

inline ref::Mat random_mat(uint64_t n, uint32_t nrows, uint32_t ncols)
{
    ref::Mat m(nrows, ncols);
    for (size_t k = 0; k < m.e.size(); k++)
        m.e[k] = rnd_residue(n);
    return m;
}

inline void fill(const packmat_field * f, Buf & b, const ref::Mat & m)
{
    const packmat_mat v = b.view(f, m.nrows, m.ncols);
    packmat_zero(v);
    for (uint32_t i = 0; i < m.nrows; i++)
        for (uint32_t j = 0; j < m.ncols; j++)
            packmat_mat_set(v, i, j, m.at(i, j));
}

#endif    // PACKMAT_TEST_COMMON_H
