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
};

const Ops gf2_ops = make_ops<Gf2>();

}    // namespace packmat
