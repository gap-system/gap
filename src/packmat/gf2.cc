/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Kernels of the kind GF2: one bit per cell, 64 cells per word.
*/

#include "ops.h"

namespace packmat {

const Kernels gf2_kernels = cell_kernels<1>();

// Word arithmetic for ops.h: + is XOR, a scalar 0 or 1 is a mask
struct Gf2 {
    static const unsigned B = 1;
    typedef Cells<1>      C;

    struct Scalar {
        uint64_t mask;
    };

    static Scalar scalar(const packmat_field &, uint64_t s)
    {
        Scalar c = { 0 - s };
        return c;
    }

    static uint64_t add(const packmat_field &, uint64_t x, uint64_t y)
    {
        return x ^ y;
    }

    static uint64_t sub(const packmat_field &, uint64_t x, uint64_t y)
    {
        return x ^ y;
    }

    static uint64_t neg(const packmat_field &, uint64_t x)
    {
        return x;
    }

    static uint64_t mul(const packmat_field &, uint64_t x, const Scalar & c)
    {
        return x & c.mask;
    }

    static uint64_t
    addmul(const packmat_field &, uint64_t y, uint64_t x, const Scalar & c)
    {
        return y ^ (x & c.mask);
    }

    // x is 1
    static int inverse(const packmat_field &, uint64_t, uint64_t * inv)
    {
        *inv = 1;
        return PACKMAT_OK;
    }

    // Parity of the common set bits
    static uint64_t dot(packmat_mat a, packmat_mat b)
    {
        const size_t words = num_words(a);
        uint64_t     x = 0;
        for (size_t k = 0; k < words; k++)
            x ^= a.w[k] & b.w[k];
        return popcount64(x) & 1;
    }

    // Row i of d is the XOR of the rows k of b with a[i,k] = 1. If rows
    // of b share words, they are at most 32 bits and add up in a register.
    static int product(packmat_mat  d,
                       packmat_mat  a,
                       packmat_mat  b,
                       packmat_poll poll,
                       void *       data)
    {
        Generic<Gf2>::zero(d);
        Poll p(poll, data);
        if (p.tick(num_words(d)))
            return PACKMAT_INTERRUPTED;
        const uint32_t n = b.ncols;
        const uint32_t r = layout_rpw(64, n);
        const size_t   stride = layout_stride(64, n);
        const uint64_t mask = r > 1 ? bit_range(0, n) : 0;
        const uint64_t scan = 1 + (uint64_t)a.ncols / 64;
        bool           stop = false;
        for (uint32_t i = 0; i < a.nrows && !stop; i++) {
            const uint64_t lo = C::row_bit(a.ncols, i);
            if (r > 1) {
                uint64_t acc = 0, bits = 0;
                for_nonzero_cells<1>(a.w, lo, a.ncols, [&](uint64_t k) {
                    acc ^= (b.w[k / r] >> ((k % r) * n)) & mask;
                    bits++;
                });
                d.w[i / r] |= acc << ((i % r) * n);
                stop = p.tick(scan + bits);
                continue;
            }
            uint64_t * dr = d.w + i * stride;
            for_nonzero_cells<1>(a.w, lo, a.ncols, [&](uint64_t k) {
                if (stop)
                    return;
                const uint64_t * br = b.w + k * stride;
                for (size_t t = 0; t < stride; t++)
                    dr[t] ^= br[t];
                stop = p.tick(stride);
            });
            stop = stop || p.tick(scan);
        }
        return stop ? PACKMAT_INTERRUPTED : PACKMAT_OK;
    }

    // Entry i of d is the parity of row i of m AND v
    static int mat_mul_vec(packmat_mat  d,
                           packmat_mat  m,
                           packmat_mat  v,
                           packmat_poll poll,
                           void *       data)
    {
        Generic<Gf2>::zero(d);
        Poll p(poll, data);
        if (p.tick(num_words(d)))
            return PACKMAT_INTERRUPTED;
        const uint32_t n = m.ncols;
        const uint32_t r = layout_rpw(64, n);
        const size_t   stride = layout_stride(64, n);
        for (uint32_t i = 0; i < m.nrows; i++) {
            uint64_t x = 0;
            if (r > 1)
                x = (m.w[i / r] >> ((i % r) * n)) & v.w[0];
            else {
                const uint64_t * row = m.w + i * stride;
                for (size_t t = 0; t < stride; t++)
                    x ^= row[t] & v.w[t];
            }
            d.w[i / 64] |= (uint64_t)(popcount64(x) & 1) << (i % 64);
            if (p.tick(1 + stride))
                return PACKMAT_INTERRUPTED;
        }
        return PACKMAT_OK;
    }
};

const Ops gf2_ops = make_ops<Gf2>();

}    // namespace packmat
