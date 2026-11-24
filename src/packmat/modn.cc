/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Kernels of the residue kind M64, and the C API of residue arithmetic.
*/

#include "ops.h"

namespace packmat {

const Kernels m64_kernels = cell_kernels<64>();

// Word arithmetic for ops.h: a word is one residue. A scalar multiplies by
// Shoup's method if n < 2^63, else through the preinverse.
struct M64 {
    static const unsigned B = 64;

    struct Scalar {
        uint64_t s, sp;
        bool     shoup;
    };

    static Scalar scalar(const packmat_field & f, uint64_t s)
    {
        Scalar c;
        c.s = s;
        c.shoup = f.n >> 63 == 0;
        c.sp = c.shoup ? mod_shoup(f, s) : 0;
        return c;
    }

    static uint64_t add(const packmat_field & f, uint64_t x, uint64_t y)
    {
        return mod_add(f, x, y);
    }

    static uint64_t sub(const packmat_field & f, uint64_t x, uint64_t y)
    {
        return mod_sub(f, x, y);
    }

    static uint64_t neg(const packmat_field & f, uint64_t x)
    {
        return mod_neg(f, x);
    }

    static uint64_t mul(const packmat_field & f, uint64_t x, const Scalar & c)
    {
        return c.shoup ? mod_mul_shoup(f, x, c.s, c.sp) : mod_mul(f, x, c.s);
    }

    static uint64_t
    addmul(const packmat_field & f, uint64_t y, uint64_t x, const Scalar & c)
    {
        return mod_add(f, y, mul(f, x, c));
    }

    static int inverse(const packmat_field & f, uint64_t x, uint64_t * inv)
    {
        return mod_inv(f, x, inv);
    }

    static uint64_t dot(packmat_mat a, packmat_mat b)
    {
        DotAcc acc;
        for (uint32_t k = 0; k < a.ncols; k++)
            acc.add(a.w[k], b.w[k]);
        return acc.reduce(*a.f);
    }

    // One reduction per output entry; b is read by columns
    static int product(packmat_mat  d,
                       packmat_mat  a,
                       packmat_mat  b,
                       packmat_poll poll,
                       void *       data)
    {
        Generic<M64>::zero(d);
        const packmat_field f = *d.f;
        const uint32_t      m = a.nrows, k = a.ncols, n = b.ncols;
        Poll                p(poll, data);
        for (uint32_t i = 0; i < m; i++) {
            const uint64_t * ar = a.w + (size_t)i * k;
            uint64_t *       dr = d.w + (size_t)i * n;
            for (uint32_t j = 0; j < n; j++) {
                DotAcc           acc;
                const uint64_t * bc = b.w + j;
                for (uint32_t t = 0; t < k; t++)
                    acc.add(ar[t], bc[(size_t)t * n]);
                dr[j] = acc.reduce(f);
                if (p.tick(1 + (uint64_t)k))
                    return PACKMAT_INTERRUPTED;
            }
        }
        return PACKMAT_OK;
    }

    static int mat_mul_vec(packmat_mat  d,
                           packmat_mat  m,
                           packmat_mat  v,
                           packmat_poll poll,
                           void *       data)
    {
        return Generic<M64>::mat_mul_vec_by_product(d, m, v, poll, data);
    }
};

const Ops m64_ops = make_ops<M64>();

}    // namespace packmat

using namespace packmat;

extern "C" {

uint64_t packmat_mod_reduce(const packmat_field * f, uint64_t a)
{
    return mod_reduce(*f, a);
}

uint64_t
packmat_mod_reduce2(const packmat_field * f, uint64_t hi, uint64_t lo)
{
    return mod_reduce2(*f, hi, lo);
}

uint64_t packmat_mod_add(const packmat_field * f, uint64_t a, uint64_t b)
{
    return mod_add(*f, a, b);
}

uint64_t packmat_mod_sub(const packmat_field * f, uint64_t a, uint64_t b)
{
    return mod_sub(*f, a, b);
}

uint64_t packmat_mod_neg(const packmat_field * f, uint64_t a)
{
    return mod_neg(*f, a);
}

uint64_t packmat_mod_mul(const packmat_field * f, uint64_t a, uint64_t b)
{
    return mod_mul(*f, a, b);
}

uint64_t packmat_mod_shoup(const packmat_field * f, uint64_t s)
{
    return mod_shoup(*f, s);
}

uint64_t packmat_mod_mul_shoup(const packmat_field * f,
                               uint64_t              a,
                               uint64_t              s,
                               uint64_t              sp)
{
    return mod_mul_shoup(*f, a, s, sp);
}

int packmat_mod_inv(const packmat_field * f, uint64_t a, uint64_t * inv)
{
    return mod_inv(*f, a, inv);
}

}    // extern "C"
