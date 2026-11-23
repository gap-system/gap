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

#include "kernels.h"

namespace packmat {

const Kernels m64_kernels = cell_kernels<64>();

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
