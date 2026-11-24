/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Internal to the packed matrix core: the layout formulas, the per-kind
**  kernel table, and kernels generic over the cell width.
*/

#ifndef PACKMAT_KERNELS_H
#define PACKMAT_KERNELS_H

#include "arith.h"

namespace packmat {

/****************************************************************************
**
**  Layout (see packmat.h); cpw is a template constant in the kernels.
*/

inline uint32_t layout_rpw(uint32_t cpw, uint32_t ncols)
{
    return (ncols > 0 && ncols <= cpw / 2) ? cpw / ncols : 1;
}

// ceil(ncols / cpw) without the wrap of ncols + cpw - 1 near 2^32
inline uint32_t layout_stride(uint32_t cpw, uint32_t ncols)
{
    if (ncols > 0 && ncols <= cpw / 2)
        return 0;
    return ncols / cpw + (ncols % cpw != 0);
}

inline uint64_t layout_words(uint32_t cpw, uint32_t nrows, uint32_t ncols)
{
    const uint32_t r = layout_rpw(cpw, ncols);
    if (r > 1)
        return ((uint64_t)nrows + (r - 1)) / r;
    return (uint64_t)nrows * layout_stride(cpw, ncols);
}

inline const uint16_t * rank_table(const packmat_field * f)
{
    return f->ranked ? reinterpret_cast<const uint16_t *>(f + 1) : 0;
}

/****************************************************************************
**
**  Kernel table, indexed by kind: the operations that depend on the cell
**  layout. Word passes that the invariants make kind-independent (zero,
**  copy, equal, hash, is_zero) live in matrix.cc. Every entry takes the
**  context first, so that later kinds can read run-time parameters from
**  it. The functions in matrix.cc unpack the views of packmat.h into the
**  words and the dimensions an entry needs.
*/

struct Kernels {
    // Entry (i, j) of matrix m with ncols columns
    uint64_t (*mat_get)(const packmat_field *,
                        const uint64_t * m,
                        uint32_t         ncols,
                        uint32_t         i,
                        uint32_t         j);

    // Set entry (i, j) of m to x < n; other cells stay unchanged
    void (*mat_set)(const packmat_field *,
                    uint64_t * m,
                    uint32_t   ncols,
                    uint32_t   i,
                    uint32_t   j,
                    uint64_t   x);

    // Entry i of vector v
    uint64_t (*vec_get)(const packmat_field *,
                        const uint64_t * v,
                        uint32_t         i);

    // Set entry i of v to x < n
    void (*vec_set)(const packmat_field *,
                    uint64_t * v,
                    uint32_t   i,
                    uint64_t   x);

    // Overwrite m with ones on the diagonal and zeros elsewhere
    void (*identity)(const packmat_field *,
                     uint64_t * m,
                     uint32_t   nrows,
                     uint32_t   ncols);

    // 1 if m is square and the identity, else 0
    int (*is_identity)(const packmat_field *,
                       const uint64_t * m,
                       uint32_t         nrows,
                       uint32_t         ncols);

    // -1, 0 or 1: a against b, both `words` long. The word count suffices,
    // since the first differing word holds the first differing entry.
    int (*compare)(const packmat_field *,
                   const uint64_t * a,
                   const uint64_t * b,
                   size_t           words);

    // 1 if unused bits of m are zero and all cells are below n
    int (*check)(const packmat_field *,
                 const uint64_t * m,
                 uint32_t         nrows,
                 uint32_t         ncols);
};

extern const Kernels gf2_kernels;
extern const Kernels m64_kernels;

/****************************************************************************
**
**  Cells of B bits, CPW = 64/B per word, for any B that divides 64. A row
**  of a matrix is a bit string: row i is the ncols*B bits from
**  row_bit(ncols, i) on, in one word if rows share words, else from the
**  start of its first word.
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

    // The low bit of each nonzero cell of x, folded from its bits
    static uint64_t nonzero_marks(uint64_t x)
    {
        if (B == 64)
            return x != 0;
        for (unsigned s = 1; s < B; s *= 2)
            x |= x >> s;
        return x & (~(uint64_t)0 / MASK);
    }

    static unsigned nonzero_cells(uint64_t x)
    {
        return popcount64(nonzero_marks(x));
    }
};

template <unsigned B>
const uint32_t Cells<B>::CPW;
template <unsigned B>
const uint64_t Cells<B>::MASK;

/****************************************************************************
**
**  Kernels for B-bit cells; kinds may replace entries with faster ones.
*/

template <unsigned B>
struct CellKernels {
    typedef Cells<B> C;

    static const uint32_t CPW = C::CPW;
    static const uint64_t MASK = C::MASK;

    static uint64_t mat_get(const packmat_field *,
                            const uint64_t * m,
                            uint32_t         ncols,
                            uint32_t         i,
                            uint32_t         j)
    {
        PACKMAT_ASSERT(j < ncols);
        return C::get(m, C::row_bit(ncols, i) + (uint64_t)j * B);
    }

    static void mat_set(const packmat_field * f,
                        uint64_t *            m,
                        uint32_t              ncols,
                        uint32_t              i,
                        uint32_t              j,
                        uint64_t              x)
    {
        PACKMAT_ASSERT(j < ncols && x < f->n);
        C::put(m, C::row_bit(ncols, i) + (uint64_t)j * B, x);
    }

    static uint64_t
    vec_get(const packmat_field *, const uint64_t * v, uint32_t i)
    {
        return C::get(v, (uint64_t)i * B);
    }

    static void
    vec_set(const packmat_field * f, uint64_t * v, uint32_t i, uint64_t x)
    {
        PACKMAT_ASSERT(x < f->n);
        C::put(v, (uint64_t)i * B, x);
    }

    // Expected word k of the n x n identity when r > 1 rows share a word
    static uint64_t identity_word(uint32_t n, uint32_t r, size_t k)
    {
        uint64_t       w = 0;
        const uint64_t first = (uint64_t)k * r;
        for (uint64_t i = first; i < first + r && i < n; i++)
            w |= (uint64_t)1 << (((i - first) * n + i) * B);
        return w;
    }

    static void identity(const packmat_field * f,
                         uint64_t *            m,
                         uint32_t              nrows,
                         uint32_t              ncols)
    {
        const size_t words = (size_t)layout_words(CPW, nrows, ncols);
        for (size_t k = 0; k < words; k++)
            m[k] = 0;
        const uint32_t d = nrows < ncols ? nrows : ncols;
        for (uint32_t i = 0; i < d; i++)
            mat_set(f, m, ncols, i, i, 1);
    }

    static int is_identity(const packmat_field *,
                           const uint64_t * m,
                           uint32_t         nrows,
                           uint32_t         ncols)
    {
        if (nrows != ncols)
            return 0;
        const uint32_t n = nrows;
        const uint32_t r = layout_rpw(CPW, n);
        if (r > 1) {
            const size_t words = (size_t)layout_words(CPW, n, n);
            for (size_t k = 0; k < words; k++) {
                if (m[k] != identity_word(n, r, k))
                    return 0;
            }
            return 1;
        }
        const uint32_t stride = layout_stride(CPW, n);
        for (uint32_t i = 0; i < n; i++) {
            const uint64_t * row = m + (size_t)i * stride;
            for (uint32_t t = 0; t < stride; t++) {
                const uint64_t want =
                    t == i / CPW ? (uint64_t)1 << ((i % CPW) * B) : 0;
                if (row[t] != want)
                    return 0;
            }
        }
        return 1;
    }

    // The first differing word holds the first differing entry, at its
    // lowest differing cell.
    static int compare(const packmat_field * f,
                       const uint64_t *      a,
                       const uint64_t *      b,
                       size_t                words)
    {
        for (size_t k = 0; k < words; k++) {
            const uint64_t x = a[k] ^ b[k];
            if (x == 0)
                continue;
            const unsigned s = (ctz64(x) / B) * B;
            uint64_t       ca = (a[k] >> s) & MASK;
            uint64_t       cb = (b[k] >> s) & MASK;
            const uint16_t * rank = rank_table(f);
            if (rank) {
                ca = rank[ca];
                cb = rank[cb];
            }
            return ca < cb ? -1 : 1;
        }
        return 0;
    }

    // Mask of the low `cells` cells of a word
    static uint64_t cell_mask(uint32_t cells)
    {
        return cells >= CPW ? ~(uint64_t)0
                            : ((uint64_t)1 << (cells * B)) - 1;
    }

    static int
    check_cells(const packmat_field * f, uint64_t w, uint32_t cells)
    {
        if (MASK < f->n)
            return 1;
        for (uint32_t c = 0; c < cells; c++) {
            if (((w >> (c * B)) & MASK) >= f->n)
                return 0;
        }
        return 1;
    }

    static int check(const packmat_field * f,
                     const uint64_t *      m,
                     uint32_t              nrows,
                     uint32_t              ncols)
    {
        if (nrows == 0 || ncols == 0)
            return 1;
        const uint32_t r = layout_rpw(CPW, ncols);
        if (r > 1) {
            const size_t words = (size_t)layout_words(CPW, nrows, ncols);
            for (size_t k = 0; k < words; k++) {
                const uint64_t left = nrows - (uint64_t)k * r;
                const uint32_t rows = left < r ? (uint32_t)left : r;
                const uint32_t cells = rows * ncols;
                if ((m[k] & ~cell_mask(cells)) != 0 ||
                    !check_cells(f, m[k], cells))
                    return 0;
            }
            return 1;
        }
        const uint32_t stride = layout_stride(CPW, ncols);
        for (uint32_t i = 0; i < nrows; i++) {
            const uint64_t * row = m + (size_t)i * stride;
            for (uint32_t t = 0; t < stride; t++) {
                const uint32_t left = ncols - t * CPW;
                const uint32_t cells = left < CPW ? left : CPW;
                if ((row[t] & ~cell_mask(cells)) != 0 ||
                    !check_cells(f, row[t], cells))
                    return 0;
            }
        }
        return 1;
    }
};

template <unsigned B>
const uint32_t CellKernels<B>::CPW;
template <unsigned B>
const uint64_t CellKernels<B>::MASK;

// Kernel table entries from CellKernels<B>; constexpr, so that the tables
// are initialised statically
template <unsigned B>
constexpr Kernels cell_kernels()
{
    return Kernels{ &CellKernels<B>::mat_get,  &CellKernels<B>::mat_set,
                    &CellKernels<B>::vec_get,  &CellKernels<B>::vec_set,
                    &CellKernels<B>::identity, &CellKernels<B>::is_identity,
                    &CellKernels<B>::compare,  &CellKernels<B>::check };
}

}    // namespace packmat

#endif    // PACKMAT_KERNELS_H
