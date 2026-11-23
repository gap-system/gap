/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Field contexts and layout.
*/

#include "kernels.h"

using namespace packmat;

// Bits per cell, by kind
static const uint32_t KIND_BITS[PACKMAT_NUM_KINDS] = { 1, 64 };

// Rank entries are uint16_t
static const uint64_t MAX_RANKED_N = (uint64_t)1 << 16;

static int valid(int kind, uint64_t n, int ranked)
{
    if (kind != PACKMAT_GF2 && kind != PACKMAT_M64)
        return 0;
    if (n < 2 || (kind == PACKMAT_GF2 && n != 2))
        return 0;
    return !ranked || n <= MAX_RANKED_N;
}

extern "C" {

int packmat_choose_kind(uint64_t n, uint32_t degree)
{
    if (degree != 1 || n < 2)
        return PACKMAT_NO_KIND;
    return n == 2 ? PACKMAT_GF2 : PACKMAT_M64;
}

size_t packmat_field_size(int kind, uint64_t n, int ranked)
{
    if (!valid(kind, n, ranked))
        return 0;
    size_t bytes = sizeof(packmat_field);
    if (ranked)
        bytes += ((size_t)n * sizeof(uint16_t) + 7) & ~(size_t)7;
    return bytes;
}

int packmat_field_init(packmat_field * f, int kind, uint64_t n, int ranked)
{
    if (!valid(kind, n, ranked))
        return PACKMAT_INVALID;
    f->kind = (uint32_t)kind;
    f->degree = 1;
    f->bits = KIND_BITS[kind];
    f->cpw = 64 / f->bits;
    f->n = n;
    f->norm = clz64(n);
    f->ninv = preinvert(n << f->norm);
    f->ranked = ranked ? 1 : 0;
    uint16_t * rank = packmat_field_rank(f);
    for (uint64_t x = 0; rank && x < n; x++)
        rank[x] = (uint16_t)x;
    return PACKMAT_OK;
}

uint16_t * packmat_field_rank(packmat_field * f)
{
    return f->ranked ? reinterpret_cast<uint16_t *>(f + 1) : 0;
}

int packmat_field_check(const packmat_field * f)
{
    if (f->kind >= PACKMAT_NUM_KINDS || f->ranked > 1 ||
        !valid((int)f->kind, f->n, (int)f->ranked))
        return 0;
    if (f->degree != 1 || f->bits != KIND_BITS[f->kind] ||
        f->cpw != 64 / f->bits)
        return 0;
    if (f->norm != clz64(f->n) || f->ninv != preinvert(f->n << f->norm))
        return 0;
    const uint16_t * rank = rank_table(f);
    if (!rank)
        return 1;
    if (rank[0] != 0)
        return 0;

    // permutation test with a bitmap of MAX_RANKED_N bits (8 KiB)
    uint64_t seen[MAX_RANKED_N / 64] = { 0 };
    for (uint64_t x = 0; x < f->n; x++) {
        const uint16_t y = rank[x];
        if (y >= f->n || ((seen[y / 64] >> (y % 64)) & 1))
            return 0;
        seen[y / 64] |= (uint64_t)1 << (y % 64);
    }
    return 1;
}

uint32_t packmat_rows_per_word(const packmat_field * f, uint32_t ncols)
{
    return layout_rpw(f->cpw, ncols);
}

uint32_t packmat_stride(const packmat_field * f, uint32_t ncols)
{
    return layout_stride(f->cpw, ncols);
}

uint64_t
packmat_matrix_words(const packmat_field * f, uint32_t nrows, uint32_t ncols)
{
    return layout_words(f->cpw, nrows, ncols);
}

uint64_t packmat_vector_words(const packmat_field * f, uint32_t len)
{
    return layout_words(f->cpw, 1, len);
}

}    // extern "C"
