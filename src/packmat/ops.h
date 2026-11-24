/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Internal to the packed matrix core: the arithmetic, row, column, copy
**  and product kernels, generic over the kind, and their table.
**
**  A kind K supplies its cell width K::B and word arithmetic: add, sub,
**  neg, and mul and addmul by a scalar that K::scalar prepares. Each acts
**  on every cell of a word and maps zero cells to zero, so applied to a
**  masked word it changes only the cells the mask keeps. K also supplies
**  inverse, dot, product and mat_mul_vec.
**
**  Rows are bit strings: row i of an nrows x ncols matrix is the ncols*B
**  bits from row_bit(ncols, i) on, in one word if rows share words, else
**  from the start of its first word. A vector is row 0 of a 1 x len view.
*/

#ifndef PACKMAT_OPS_H
#define PACKMAT_OPS_H

#include "kernels.h"

#include <string.h>

namespace packmat {

/****************************************************************************
**
**  Kernel table, indexed by kind, for the functions of packmat.h from
**  packmat_add on. Entries take views; ops.cc checks the preconditions.
**  Row ranges are cells [from, to) of a row; vector functions call them
**  for row 0.
*/

struct Ops {
    // dst = a + b, a - b, -a, s*a, over all words
    void (*add)(packmat_mat dst, packmat_mat a, packmat_mat b);
    void (*sub)(packmat_mat dst, packmat_mat a, packmat_mat b);
    void (*neg)(packmat_mat dst, packmat_mat a);
    void (*scale)(packmat_mat dst, packmat_mat a, uint64_t s);

    // dst += s*a
    void (*addmul)(packmat_mat dst, packmat_mat a, uint64_t s);

    // Nonzero entries of m; entries where a and b differ
    uint64_t (*weight)(packmat_mat m);
    uint64_t (*distance)(packmat_mat a, packmat_mat b);

    // Scalar product of two vectors
    uint64_t (*dot)(packmat_mat a, packmat_mat b);

    // packmat_vec_normalize
    int (*normalize)(packmat_mat v);

    // Cells [from, to) of row i of m *= s
    void (*scale_row)(
        packmat_mat m, uint32_t i, uint64_t s, uint32_t from, uint32_t to);

    // Cells [from, to) of row i of dst += s * those of row j of src
    void (*addmul_row)(packmat_mat dst,
                       uint32_t    i,
                       packmat_mat src,
                       uint32_t    j,
                       uint64_t    s,
                       uint32_t    from,
                       uint32_t    to);

    // First column >= from with a nonzero entry in row i, or ncols
    uint32_t (*position_nonzero_in_row)(packmat_mat m,
                                        uint32_t    i,
                                        uint32_t    from);

    // 1 + the last column with a nonzero entry in row i, or 0
    uint32_t (*position_last_nonzero_in_row)(packmat_mat m, uint32_t i);

    void (*swap_rows)(packmat_mat m, uint32_t i, uint32_t j);

    // Column operations
    void (*swap_cols)(packmat_mat m, uint32_t i, uint32_t j);
    void (*mult_col)(packmat_mat m, uint32_t i, uint64_t s);
    void (*add_cols)(packmat_mat m, uint32_t i, uint32_t j, uint64_t s);

    // Row i of dst = row j of src, for equal ncols
    void (*copy_row)(packmat_mat dst,
                     uint32_t    i,
                     packmat_mat src,
                     uint32_t    j);

    // packmat_copy_submatrix
    void (*copy_submatrix)(packmat_mat   dst,
                           packmat_mat   src,
                           packmat_index drows,
                           packmat_index srows,
                           packmat_index dcols,
                           packmat_index scols);

    void (*transpose)(packmat_mat dst, packmat_mat src);

    // packmat_mul, packmat_mat_mul_vec, packmat_kronecker
    int (*mul)(packmat_mat  dst,
               packmat_mat  a,
               packmat_mat  b,
               packmat_poll poll,
               void *       data);
    int (*mat_mul_vec)(packmat_mat  dst,
                       packmat_mat  m,
                       packmat_mat  v,
                       packmat_poll poll,
                       void *       data);
    int (*kronecker)(packmat_mat  dst,
                     packmat_mat  a,
                     packmat_mat  b,
                     packmat_poll poll,
                     void *       data);
};

extern const Ops gf2_ops;
extern const Ops m64_ops;

/****************************************************************************
**
**  Views
*/

inline size_t num_words(packmat_mat m)
{
    return (size_t)layout_words(m.f->cpw, m.nrows, m.ncols);
}

inline bool same_shape(packmat_mat a, packmat_mat b)
{
    return a.f == b.f && a.nrows == b.nrows && a.ncols == b.ncols;
}

// The words of a and b do not overlap
inline bool disjoint(packmat_mat a, packmat_mat b)
{
    const uintptr_t pa = (uintptr_t)a.w, pb = (uintptr_t)b.w;
    return pa + num_words(a) * sizeof(uint64_t) <= pb ||
           pb + num_words(b) * sizeof(uint64_t) <= pa;
}

inline bool same_or_disjoint(packmat_mat a, packmat_mat b)
{
    return a.w == b.w || disjoint(a, b);
}

// Every index of x is below bound
inline bool indices_below(packmat_index x, uint32_t bound)
{
    if (!x.idx)
        return x.len == 0 || (uint64_t)x.first + x.len <= bound;
    for (uint32_t k = 0; k < x.len; k++) {
        if (x.idx[k] >= bound)
            return false;
    }
    return true;
}

/****************************************************************************
**
**  Bits
*/

// Bits [lo, hi) of a word; lo < hi <= 64
inline uint64_t bit_range(unsigned lo, unsigned hi)
{
    return (~(uint64_t)0 << lo) & (~(uint64_t)0 >> (64 - hi));
}

// Calls fn(k, mask) for each word k that bits [lo, hi) of a buffer
// touch, with the mask of those bits in word k; lo < hi. The inner words
// get the constant mask ~0, which folds away after inlining.
template <class Fn>
inline void for_words(uint64_t lo, uint64_t hi, Fn fn)
{
    const size_t   a = (size_t)(lo / 64), b = (size_t)((hi - 1) / 64);
    const uint64_t ma = ~(uint64_t)0 << (lo % 64);
    const uint64_t mb = ~(uint64_t)0 >> (63 - (hi - 1) % 64);
    if (a == b) {
        fn(a, ma & mb);
        return;
    }
    fn(a, ma);
    for (size_t k = a + 1; k < b; k++)
        fn(k, ~(uint64_t)0);
    fn(b, mb);
}

// Calls fn(t) for each set bit lo + t of w in [lo, hi)
template <class Fn>
inline void for_set_bits(const uint64_t * w, uint64_t lo, uint64_t hi, Fn fn)
{
    if (lo >= hi)
        return;
    for_words(lo, hi, [&](size_t k, uint64_t m) {
        uint64_t x = w[k] & m;
        while (x) {
            fn((uint64_t)k * 64 + ctz64(x) - lo);
            x &= x - 1;
        }
    });
}

// Position of the first set bit of w in [lo, hi), or hi
inline uint64_t first_bit(const uint64_t * w, uint64_t lo, uint64_t hi)
{
    if (lo >= hi)
        return hi;
    size_t       k = (size_t)(lo / 64);
    const size_t b = (size_t)((hi - 1) / 64);
    uint64_t     x = w[k] & (~(uint64_t)0 << (lo % 64));
    for (;;) {
        if (k == b)
            x &= ~(uint64_t)0 >> (63 - (hi - 1) % 64);
        if (x)
            return (uint64_t)k * 64 + ctz64(x);
        if (k == b)
            return hi;
        x = w[++k];
    }
}

// 1 + the position of the last set bit of w in [lo, hi), or lo
inline uint64_t last_bit_end(const uint64_t * w, uint64_t lo, uint64_t hi)
{
    if (lo >= hi)
        return lo;
    size_t       k = (size_t)((hi - 1) / 64);
    const size_t a = (size_t)(lo / 64);
    uint64_t     x = w[k] & (~(uint64_t)0 >> (63 - (hi - 1) % 64));
    for (;;) {
        if (k == a)
            x &= ~(uint64_t)0 << (lo % 64);
        if (x)
            return (uint64_t)k * 64 + 64 - clz64(x);
        if (k == a)
            return lo;
        x = w[--k];
    }
}

// Copy bits [s0, s0 + n) of s to bits [d0, d0 + n) of d, keeping the
// other bits of d; the two ranges do not overlap. Each destination word
// takes one funnel shift of two source words.
inline void copy_bits(
    uint64_t * d, uint64_t d0, const uint64_t * s, uint64_t s0, uint64_t n)
{
    if (n == 0)
        return;
    d += d0 / 64;
    s += s0 / 64;
    unsigned ds = (unsigned)(d0 % 64), ss = (unsigned)(s0 % 64);
    while (n > 0) {
        const unsigned take = n < 64 - ds ? (unsigned)n : 64 - ds;
        uint64_t       x = s[0] >> ss;
        if (ss + take > 64)
            x |= s[1] << (64 - ss);
        const uint64_t m = bit_range(ds, ds + take);
        *d = (*d & ~m) | ((x << ds) & m);
        n -= take;
        d++;
        ds = 0;
        ss += take;
        s += ss / 64;
        ss %= 64;
    }
}

/****************************************************************************
**
**  Cells of width B
*/

template <unsigned B>
struct Cells {
    static const uint32_t CPW = 64 / B;
    static const uint64_t MASK = ~(uint64_t)0 >> (64 - B);

    // First bit of row i of a matrix with ncols columns
    static uint64_t row_bit(uint32_t ncols, uint32_t i)
    {
        const uint32_t r = layout_rpw(CPW, ncols);
        if (r > 1)
            return (uint64_t)(i / r) * 64 + (i % r) * ncols * B;
        return (uint64_t)i * layout_stride(CPW, ncols) * 64;
    }

    static uint64_t get(const uint64_t * w, uint64_t bit)
    {
        return (w[bit / 64] >> (bit % 64)) & MASK;
    }

    static void put(uint64_t * w, uint64_t bit, uint64_t x)
    {
        uint64_t &     d = w[bit / 64];
        const unsigned s = (unsigned)(bit % 64);
        d = (d & ~(MASK << s)) | (x << s);
    }

    // Number of nonzero cells in x: fold each cell into its low bit
    static unsigned nonzero_cells(uint64_t x)
    {
        if (B == 64)
            return x != 0;
        for (unsigned s = 1; s < B; s *= 2)
            x |= x >> s;
        return popcount64(x & (~(uint64_t)0 / MASK));
    }
};

template <unsigned B>
const uint32_t Cells<B>::CPW;
template <unsigned B>
const uint64_t Cells<B>::MASK;

// Rows i, i + 1, ... of a matrix, by first bit, without divisions
template <unsigned B>
struct RowWalk {
    uint64_t bit;     // first bit of the current row
    uint64_t step;    // to the next row in the same word, or to the next row
    uint32_t r, c;    // rows per word; index of the row in its word

    RowWalk(uint32_t ncols, uint32_t i)
        : bit(Cells<B>::row_bit(ncols, i)),
          r(layout_rpw(Cells<B>::CPW, ncols)),
          c(i % layout_rpw(Cells<B>::CPW, ncols))
    {
        step = r > 1 ? (uint64_t)ncols * B
                     : (uint64_t)layout_stride(Cells<B>::CPW, ncols) * 64;
    }

    void next()
    {
        if (r == 1)
            bit += step;
        else if (++c < r)
            bit += step;
        else {
            c = 0;
            bit = (bit / 64 + 1) * 64;
        }
    }
};

/****************************************************************************
**
**  Polling in the long kernels
*/

// Word operations between two polls
static const uint64_t POLL_WORK = (uint64_t)1 << 16;

struct Poll {
    packmat_poll poll;
    void *       data;
    uint64_t     work;

    Poll(packmat_poll p, void * d) : poll(p), data(d), work(0)
    {
    }

    // Count `w` word operations; true if the caller must stop
    bool tick(uint64_t w)
    {
        work += w;
        if (work < POLL_WORK)
            return false;
        work = 0;
        return poll && poll(data) != 0;
    }
};

/****************************************************************************
**
**  Kernels for a kind K
*/

template <class K>
struct Generic {
    typedef Cells<K::B>        C;
    typedef typename K::Scalar Scalar;

    static const unsigned B = K::B;
    static const uint32_t CPW = C::CPW;

    static void zero(packmat_mat m)
    {
        const size_t words = num_words(m);
        if (words)
            memset(m.w, 0, words * sizeof(uint64_t));
    }

    // Bits [lo, hi) of w *= s
    static void scale_bits(const packmat_field & f,
                           uint64_t *            w,
                           uint64_t              lo,
                           uint64_t              hi,
                           const Scalar &        c)
    {
        if (lo >= hi)
            return;
        for_words(lo, hi, [&](size_t k, uint64_t m) {
            w[k] = (w[k] & ~m) | K::mul(f, w[k] & m, c);
        });
    }

    // Bits [lo, hi) of d += s * the same bits of a
    static void addmul_bits(const packmat_field & f,
                            uint64_t *            d,
                            const uint64_t *      a,
                            uint64_t              lo,
                            uint64_t              hi,
                            const Scalar &        c)
    {
        if (lo >= hi)
            return;
        for_words(lo, hi, [&](size_t k, uint64_t m) {
            d[k] = K::addmul(f, d[k], a[k] & m, c);
        });
    }

    /************************************************************************
    **
    **  Whole objects: word passes
    */

    static void add(packmat_mat d, packmat_mat a, packmat_mat b)
    {
        const packmat_field f = *d.f;
        const size_t        words = num_words(d);
        for (size_t k = 0; k < words; k++)
            d.w[k] = K::add(f, a.w[k], b.w[k]);
    }

    static void sub(packmat_mat d, packmat_mat a, packmat_mat b)
    {
        const packmat_field f = *d.f;
        const size_t        words = num_words(d);
        for (size_t k = 0; k < words; k++)
            d.w[k] = K::sub(f, a.w[k], b.w[k]);
    }

    static void neg(packmat_mat d, packmat_mat a)
    {
        const packmat_field f = *d.f;
        const size_t        words = num_words(d);
        for (size_t k = 0; k < words; k++)
            d.w[k] = K::neg(f, a.w[k]);
    }

    static void scale(packmat_mat d, packmat_mat a, uint64_t s)
    {
        if (s == 0) {
            zero(d);
            return;
        }
        const packmat_field f = *d.f;
        const Scalar        c = K::scalar(f, s);
        const size_t        words = num_words(d);
        for (size_t k = 0; k < words; k++)
            d.w[k] = K::mul(f, a.w[k], c);
    }

    static void addmul(packmat_mat d, packmat_mat a, uint64_t s)
    {
        if (s == 0)
            return;
        const packmat_field f = *d.f;
        const Scalar        c = K::scalar(f, s);
        const size_t        words = num_words(d);
        for (size_t k = 0; k < words; k++)
            d.w[k] = K::addmul(f, d.w[k], a.w[k], c);
    }

    // Unused cells are zero
    static uint64_t weight(packmat_mat m)
    {
        const size_t words = num_words(m);
        uint64_t     n = 0;
        for (size_t k = 0; k < words; k++)
            n += C::nonzero_cells(m.w[k]);
        return n;
    }

    // Cells are canonical, so a and b differ in a cell iff a ^ b is
    // nonzero there
    static uint64_t distance(packmat_mat a, packmat_mat b)
    {
        const size_t words = num_words(a);
        uint64_t     n = 0;
        for (size_t k = 0; k < words; k++)
            n += C::nonzero_cells(a.w[k] ^ b.w[k]);
        return n;
    }

    static int normalize(packmat_mat v)
    {
        const uint64_t end = (uint64_t)v.ncols * B;
        const uint64_t bit = first_bit(v.w, 0, end);
        if (bit == end)
            return PACKMAT_ZERO;
        const uint64_t      p = bit / B * B;
        const packmat_field f = *v.f;
        uint64_t            inv;
        if (K::inverse(f, C::get(v.w, p), &inv) != PACKMAT_OK)
            return PACKMAT_NOT_UNIT;
        if (inv != 1)
            scale_bits(f, v.w, p, end, K::scalar(f, inv));
        return PACKMAT_OK;
    }

    /************************************************************************
    **
    **  Rows: word passes; a single word each if rows share words
    */

    static void scale_row(
        packmat_mat m, uint32_t i, uint64_t s, uint32_t from, uint32_t to)
    {
        if (from >= to || s == 1)
            return;
        const packmat_field f = *m.f;
        const uint64_t      base = C::row_bit(m.ncols, i);
        scale_bits(f, m.w, base + (uint64_t)from * B, base + (uint64_t)to * B,
                   K::scalar(f, s));
    }

    // Rows i and j may share a word, at different shifts: then the cells
    // of row j are shifted into place first.
    static void addmul_row(packmat_mat d,
                           uint32_t    i,
                           packmat_mat a,
                           uint32_t    j,
                           uint64_t    s,
                           uint32_t    from,
                           uint32_t    to)
    {
        if (from >= to || s == 0)
            return;
        const packmat_field f = *d.f;
        const Scalar        c = K::scalar(f, s);
        const uint32_t      ncols = d.ncols;
        if (layout_rpw(CPW, ncols) > 1) {
            const uint64_t db = C::row_bit(ncols, i);
            const uint64_t ab = C::row_bit(ncols, j);
            const uint64_t m = bit_range(from * B, to * B);
            const uint64_t x = ((a.w[ab / 64] >> (ab % 64)) & m) << (db % 64);
            uint64_t &     w = d.w[db / 64];
            w = K::addmul(f, w, x, c);
            return;
        }
        const size_t stride = layout_stride(CPW, ncols);
        addmul_bits(f, d.w + i * stride, a.w + j * stride, (uint64_t)from * B,
                    (uint64_t)to * B, c);
    }

    static uint32_t
    position_nonzero_in_row(packmat_mat m, uint32_t i, uint32_t from)
    {
        if (from >= m.ncols)
            return m.ncols;
        const uint64_t base = C::row_bit(m.ncols, i);
        const uint64_t bit = first_bit(m.w, base + (uint64_t)from * B,
                                       base + (uint64_t)m.ncols * B);
        return (uint32_t)((bit - base) / B);
    }

    static uint32_t position_last_nonzero_in_row(packmat_mat m, uint32_t i)
    {
        const uint64_t base = C::row_bit(m.ncols, i);
        const uint64_t end =
            last_bit_end(m.w, base, base + (uint64_t)m.ncols * B);
        return end == base ? 0 : (uint32_t)((end - 1 - base) / B + 1);
    }

    static void swap_rows(packmat_mat m, uint32_t i, uint32_t j)
    {
        if (i == j || m.ncols == 0)
            return;
        if (layout_rpw(CPW, m.ncols) > 1) {
            const uint64_t bi = C::row_bit(m.ncols, i);
            const uint64_t bj = C::row_bit(m.ncols, j);
            const unsigned si = (unsigned)(bi % 64), sj = (unsigned)(bj % 64);
            uint64_t &     wi = m.w[bi / 64];
            uint64_t &     wj = m.w[bj / 64];
            // also right if wi and wj are the same word
            const uint64_t x =
                ((wi >> si) ^ (wj >> sj)) & bit_range(0, m.ncols * B);
            wi ^= x << si;
            wj ^= x << sj;
            return;
        }
        const size_t stride = layout_stride(CPW, m.ncols);
        uint64_t *   ri = m.w + i * stride;
        uint64_t *   rj = m.w + j * stride;
        for (size_t k = 0; k < stride; k++) {
            const uint64_t t = ri[k];
            ri[k] = rj[k];
            rj[k] = t;
        }
    }

    /************************************************************************
    **
    **  Columns: cell by cell in each row
    */

    static void swap_cols(packmat_mat m, uint32_t i, uint32_t j)
    {
        if (i == j)
            return;
        RowWalk<B> r(m.ncols, 0);
        for (uint32_t row = 0; row < m.nrows; row++, r.next()) {
            const uint64_t pi = r.bit + (uint64_t)i * B;
            const uint64_t pj = r.bit + (uint64_t)j * B;
            const uint64_t xi = C::get(m.w, pi);
            C::put(m.w, pi, C::get(m.w, pj));
            C::put(m.w, pj, xi);
        }
    }

    static void mult_col(packmat_mat m, uint32_t i, uint64_t s)
    {
        if (s == 1)
            return;
        const packmat_field f = *m.f;
        const Scalar        c = K::scalar(f, s);
        RowWalk<B>          r(m.ncols, 0);
        for (uint32_t row = 0; row < m.nrows; row++, r.next()) {
            const uint64_t p = r.bit + (uint64_t)i * B;
            C::put(m.w, p, K::mul(f, C::get(m.w, p), c));
        }
    }

    static void add_cols(packmat_mat m, uint32_t i, uint32_t j, uint64_t s)
    {
        if (s == 0)
            return;
        const packmat_field f = *m.f;
        const Scalar        c = K::scalar(f, s);
        RowWalk<B>          r(m.ncols, 0);
        for (uint32_t row = 0; row < m.nrows; row++, r.next()) {
            const uint64_t pi = r.bit + (uint64_t)i * B;
            const uint64_t pj = r.bit + (uint64_t)j * B;
            C::put(m.w, pi,
                   K::addmul(f, C::get(m.w, pi), C::get(m.w, pj), c));
        }
    }

    /************************************************************************
    **
    **  Copies
    */

    static void copy_row(packmat_mat d, uint32_t i, packmat_mat a, uint32_t j)
    {
        copy_bits(d.w, C::row_bit(d.ncols, i), a.w, C::row_bit(a.ncols, j),
                  (uint64_t)a.ncols * B);
    }

    static uint32_t index(const packmat_index & x, uint32_t k)
    {
        return x.idx ? x.idx[k] : x.first + k;
    }

    // A range, or an index list of consecutive values; len > 0
    static bool is_run(const packmat_index & x)
    {
        if (!x.idx)
            return true;
        for (uint32_t k = 1; k < x.len; k++) {
            if (x.idx[k] != x.idx[0] + k)
                return false;
        }
        return true;
    }

    static void copy_submatrix(packmat_mat   d,
                               packmat_mat   a,
                               packmat_index drows,
                               packmat_index srows,
                               packmat_index dcols,
                               packmat_index scols)
    {
        const uint32_t ncols = dcols.len;
        if (ncols == 0)
            return;
        const bool     run = is_run(dcols) && is_run(scols);
        const uint64_t dc = (uint64_t)index(dcols, 0) * B;
        const uint64_t sc = (uint64_t)index(scols, 0) * B;
        for (uint32_t k = 0; k < drows.len; k++) {
            const uint64_t db = C::row_bit(d.ncols, index(drows, k));
            const uint64_t sb = C::row_bit(a.ncols, index(srows, k));
            if (run) {
                copy_bits(d.w, db + dc, a.w, sb + sc, (uint64_t)ncols * B);
                continue;
            }
            for (uint32_t t = 0; t < ncols; t++)
                C::put(d.w, db + (uint64_t)index(dcols, t) * B,
                       C::get(a.w, sb + (uint64_t)index(scols, t) * B));
        }
    }

    static void transpose(packmat_mat d, packmat_mat a)
    {
        zero(d);
        for (uint32_t j = 0; j < a.ncols; j++) {
            const uint64_t db = C::row_bit(d.ncols, j);
            RowWalk<B>     r(a.ncols, 0);
            for (uint32_t i = 0; i < a.nrows; i++, r.next()) {
                const uint64_t x = C::get(a.w, r.bit + (uint64_t)j * B);
                const uint64_t p = db + (uint64_t)i * B;
                d.w[p / 64] |= x << (p % 64);
            }
        }
    }

    /************************************************************************
    **
    **  Products
    */

    // A vector of length len is also a len x 1 matrix
    static int mat_mul_vec_by_product(packmat_mat  d,
                                      packmat_mat  m,
                                      packmat_mat  v,
                                      packmat_poll poll,
                                      void *       data)
    {
        return K::product(packmat_mat_view(d.f, d.w, d.ncols, 1), m,
                          packmat_mat_view(v.f, v.w, v.ncols, 1), poll, data);
    }

    // Each block of b.ncols cells: a copy of a row of b, then scaled
    static int kronecker(packmat_mat  d,
                         packmat_mat  a,
                         packmat_mat  b,
                         packmat_poll poll,
                         void *       data)
    {
        zero(d);
        const packmat_field f = *d.f;
        const uint64_t      len = (uint64_t)b.ncols * B;
        Poll                p(poll, data);
        RowWalk<B>          ra(a.ncols, 0);
        for (uint32_t i = 0; i < a.nrows; i++, ra.next()) {
            for (uint32_t j = 0; j < a.ncols; j++) {
                const uint64_t x = C::get(a.w, ra.bit + (uint64_t)j * B);
                if (x == 0)
                    continue;
                const Scalar c = K::scalar(f, x);
                RowWalk<B>   rd(d.ncols, i * b.nrows);
                RowWalk<B>   rb(b.ncols, 0);
                for (uint32_t k = 0; k < b.nrows; k++, rd.next(), rb.next()) {
                    const uint64_t db = rd.bit + j * len;
                    copy_bits(d.w, db, b.w, rb.bit, len);
                    if (x != 1)
                        scale_bits(f, d.w, db, db + len, c);
                    if (p.tick(1 + len / 64))
                        return PACKMAT_INTERRUPTED;
                }
            }
        }
        return PACKMAT_OK;
    }
};

template <class K>
const unsigned Generic<K>::B;
template <class K>
const uint32_t Generic<K>::CPW;

// The table for kind K
template <class K>
constexpr Ops make_ops()
{
    return Ops{ &Generic<K>::add,
                &Generic<K>::sub,
                &Generic<K>::neg,
                &Generic<K>::scale,
                &Generic<K>::addmul,
                &Generic<K>::weight,
                &Generic<K>::distance,
                &K::dot,
                &Generic<K>::normalize,
                &Generic<K>::scale_row,
                &Generic<K>::addmul_row,
                &Generic<K>::position_nonzero_in_row,
                &Generic<K>::position_last_nonzero_in_row,
                &Generic<K>::swap_rows,
                &Generic<K>::swap_cols,
                &Generic<K>::mult_col,
                &Generic<K>::add_cols,
                &Generic<K>::copy_row,
                &Generic<K>::copy_submatrix,
                &Generic<K>::transpose,
                &K::product,
                &K::mat_mul_vec,
                &Generic<K>::kronecker };
}

}    // namespace packmat

#endif    // PACKMAT_OPS_H
