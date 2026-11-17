/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Naive reference implementation for the packmat unit tests: residues by
**  bitwise methods (no preinverse, no 128-bit type), matrices as plain
**  arrays of residues, and packing by appending bits to a word stream.
*/

#ifndef PACKMAT_TEST_REF_H
#define PACKMAT_TEST_REF_H

#include <stdint.h>
#include <vector>

namespace ref {

/****************************************************************************
**
**  Residues mod n
*/

inline uint64_t add(uint64_t n, uint64_t a, uint64_t b)
{
    const uint64_t s = a + b;
    return (s < a || s >= n) ? s - n : s;
}

inline uint64_t sub(uint64_t n, uint64_t a, uint64_t b)
{
    return b == 0 ? a : add(n, a, n - b);
}

inline uint64_t neg(uint64_t n, uint64_t a)
{
    return sub(n, 0, a);
}

// double and add, from the top bit of b
inline uint64_t mul(uint64_t n, uint64_t a, uint64_t b)
{
    uint64_t r = 0;
    for (int i = 63; i >= 0; i--) {
        r = add(n, r, r);
        if ((b >> i) & 1)
            r = add(n, r, a);
    }
    return r;
}

// Quotient of (hi * 2^64 + lo) / n by long division, remainder in *rem;
// needs hi < n.
inline uint64_t div2(uint64_t n, uint64_t hi, uint64_t lo, uint64_t * rem)
{
    uint64_t r = hi, q = 0;
    for (int i = 63; i >= 0; i--) {
        const bool carry = r >> 63;
        r = (r << 1) | ((lo >> i) & 1);
        q <<= 1;
        if (carry || r >= n) {
            r -= n;
            q |= 1;
        }
    }
    *rem = r;
    return q;
}

inline uint64_t gcd(uint64_t a, uint64_t b)
{
    while (b) {
        const uint64_t t = a % b;
        a = b;
        b = t;
    }
    return a;
}

/****************************************************************************
**
**  Matrices
*/

struct Mat {
    uint32_t              nrows, ncols;
    std::vector<uint64_t> e;    // row-major

    Mat(uint32_t r, uint32_t c) : nrows(r), ncols(c), e((size_t)r * c, 0)
    {
    }
    uint64_t & at(uint32_t i, uint32_t j)
    {
        return e[(size_t)i * ncols + j];
    }
    uint64_t at(uint32_t i, uint32_t j) const
    {
        return e[(size_t)i * ncols + j];
    }
};

inline Mat identity(uint32_t nrows, uint32_t ncols)
{
    Mat m(nrows, ncols);
    for (uint32_t i = 0; i < nrows && i < ncols; i++)
        m.at(i, i) = 1;
    return m;
}

inline bool is_one(const Mat & m)
{
    if (m.nrows != m.ncols)
        return false;
    for (uint32_t i = 0; i < m.nrows; i++)
        for (uint32_t j = 0; j < m.ncols; j++)
            if (m.at(i, j) != (i == j))
                return false;
    return true;
}

// Lexicographic in row-major order, entries ordered by rank if given
inline int compare(const Mat & a, const Mat & b, const uint16_t * rank)
{
    for (size_t k = 0; k < a.e.size(); k++) {
        uint64_t x = a.e[k], y = b.e[k];
        if (rank) {
            x = rank[x];
            y = rank[y];
        }
        if (x != y)
            return x < y ? -1 : 1;
    }
    return 0;
}

// Appends cells of `bits` bits to a word stream; a cell that does not fit
// and every flush start a new word.
struct BitWriter {
    std::vector<uint64_t> words;
    unsigned              used;

    BitWriter() : used(64)
    {
    }
    void flush()
    {
        used = 64;
    }
    void put(uint64_t x, unsigned bits)
    {
        if (used + bits > 64) {
            words.push_back(0);
            used = 0;
        }
        words.back() |= x << used;
        used += bits;
    }
};

// Words of m in the layout of packmat.h. Rows go into the stream one
// after the other; a new word starts with every row, or with every r-th
// row if r = cpw/ncols >= 2 rows fit in one word.
inline std::vector<uint64_t> pack(const Mat & m, unsigned bits)
{
    const uint32_t cpw = 64 / bits;
    const uint32_t r =
        (m.ncols > 0 && 2 * m.ncols <= cpw) ? cpw / m.ncols : 1;
    BitWriter      out;
    for (uint32_t i = 0; i < m.nrows; i++) {
        if (i % r == 0)
            out.flush();
        for (uint32_t j = 0; j < m.ncols; j++)
            out.put(m.at(i, j), bits);
    }
    return out.words;
}

}    // namespace ref

#endif    // PACKMAT_TEST_REF_H
