/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Arithmetic, rows, columns, copies and products: the C API of ops.h,
**  with the preconditions that debug builds assert.
*/

#include "ops.h"

using namespace packmat;

static const Ops * const OPS_TABLE[PACKMAT_NUM_KINDS] = {
    &gf2_ops,
    &m64_ops,
};

static inline const Ops & ops(const packmat_field * f)
{
    PACKMAT_ASSERT(f->kind < PACKMAT_NUM_KINDS);
    return *OPS_TABLE[f->kind];
}

static inline void assert_range(packmat_mat v, uint32_t from, uint32_t to)
{
    PACKMAT_ASSERT(v.nrows == 1 && (from >= to || to <= v.ncols));
}

static inline void assert_product(packmat_mat d, packmat_mat a, packmat_mat b)
{
    PACKMAT_ASSERT(d.f == a.f && d.f == b.f);
    PACKMAT_ASSERT(disjoint(d, a) && disjoint(d, b));
}

extern "C" {

void packmat_add(packmat_mat dst, packmat_mat a, packmat_mat b)
{
    PACKMAT_ASSERT(same_shape(dst, a) && same_shape(dst, b));
    PACKMAT_ASSERT(same_or_disjoint(dst, a) && same_or_disjoint(dst, b));
    ops(dst.f).add(dst, a, b);
}

void packmat_sub(packmat_mat dst, packmat_mat a, packmat_mat b)
{
    PACKMAT_ASSERT(same_shape(dst, a) && same_shape(dst, b));
    PACKMAT_ASSERT(same_or_disjoint(dst, a) && same_or_disjoint(dst, b));
    ops(dst.f).sub(dst, a, b);
}

void packmat_neg(packmat_mat dst, packmat_mat a)
{
    PACKMAT_ASSERT(same_shape(dst, a) && same_or_disjoint(dst, a));
    ops(dst.f).neg(dst, a);
}

void packmat_scale(packmat_mat dst, packmat_mat a, uint64_t s)
{
    PACKMAT_ASSERT(same_shape(dst, a) && same_or_disjoint(dst, a));
    PACKMAT_ASSERT(s < dst.f->n);
    ops(dst.f).scale(dst, a, s);
}

void packmat_addmul(packmat_mat dst, packmat_mat a, uint64_t s)
{
    PACKMAT_ASSERT(same_shape(dst, a) && same_or_disjoint(dst, a));
    PACKMAT_ASSERT(s < dst.f->n);
    ops(dst.f).addmul(dst, a, s);
}

uint64_t packmat_weight(packmat_mat m)
{
    return ops(m.f).weight(m);
}

uint64_t packmat_distance(packmat_mat a, packmat_mat b)
{
    PACKMAT_ASSERT(same_shape(a, b));
    return ops(a.f).distance(a, b);
}

void packmat_vec_addmul(
    packmat_mat dst, packmat_mat src, uint64_t s, uint32_t from, uint32_t to)
{
    PACKMAT_ASSERT(same_shape(dst, src) && same_or_disjoint(dst, src));
    PACKMAT_ASSERT(s < dst.f->n);
    assert_range(dst, from, to);
    ops(dst.f).addmul_row(dst, 0, src, 0, s, from, to);
}

void packmat_vec_scale(packmat_mat v, uint64_t s, uint32_t from, uint32_t to)
{
    PACKMAT_ASSERT(s < v.f->n);
    assert_range(v, from, to);
    ops(v.f).scale_row(v, 0, s, from, to);
}

uint64_t packmat_vec_dot(packmat_mat a, packmat_mat b)
{
    PACKMAT_ASSERT(same_shape(a, b) && a.nrows == 1);
    return ops(a.f).dot(a, b);
}

uint32_t packmat_vec_position_nonzero(packmat_mat v, uint32_t from)
{
    PACKMAT_ASSERT(v.nrows == 1);
    return ops(v.f).position_nonzero_in_row(v, 0, from);
}

uint32_t packmat_vec_position_last_nonzero(packmat_mat v)
{
    PACKMAT_ASSERT(v.nrows == 1);
    return ops(v.f).position_last_nonzero_in_row(v, 0);
}

int packmat_vec_normalize(packmat_mat v)
{
    PACKMAT_ASSERT(v.nrows == 1);
    return ops(v.f).normalize(v);
}

void packmat_swap_rows(packmat_mat m, uint32_t i, uint32_t j)
{
    PACKMAT_ASSERT(i < m.nrows && j < m.nrows);
    ops(m.f).swap_rows(m, i, j);
}

void packmat_mult_row(packmat_mat m, uint32_t i, uint64_t s)
{
    PACKMAT_ASSERT(i < m.nrows && s < m.f->n);
    ops(m.f).scale_row(m, i, s, 0, m.ncols);
}

void packmat_add_rows(packmat_mat m, uint32_t i, uint32_t j, uint64_t s)
{
    PACKMAT_ASSERT(i < m.nrows && j < m.nrows && s < m.f->n);
    ops(m.f).addmul_row(m, i, m, j, s, 0, m.ncols);
}

uint32_t
packmat_position_nonzero_in_row(packmat_mat m, uint32_t i, uint32_t from)
{
    PACKMAT_ASSERT(i < m.nrows);
    return ops(m.f).position_nonzero_in_row(m, i, from);
}

void packmat_swap_cols(packmat_mat m, uint32_t i, uint32_t j)
{
    PACKMAT_ASSERT(i < m.ncols && j < m.ncols);
    ops(m.f).swap_cols(m, i, j);
}

void packmat_mult_col(packmat_mat m, uint32_t i, uint64_t s)
{
    PACKMAT_ASSERT(i < m.ncols && s < m.f->n);
    ops(m.f).mult_col(m, i, s);
}

void packmat_add_cols(packmat_mat m, uint32_t i, uint32_t j, uint64_t s)
{
    PACKMAT_ASSERT(i < m.ncols && j < m.ncols && s < m.f->n);
    ops(m.f).add_cols(m, i, j, s);
}

void packmat_copy_row_to_vector(packmat_mat v, packmat_mat m, uint32_t i)
{
    PACKMAT_ASSERT(v.f == m.f && v.nrows == 1 && v.ncols == m.ncols);
    PACKMAT_ASSERT(i < m.nrows && disjoint(v, m));
    packmat_zero(v);
    ops(m.f).copy_row(v, 0, m, i);
}

void packmat_copy_vector_to_row(packmat_mat m, uint32_t i, packmat_mat v)
{
    PACKMAT_ASSERT(v.f == m.f && v.nrows == 1 && v.ncols == m.ncols);
    PACKMAT_ASSERT(i < m.nrows && (v.w == m.w ? i > 0 : disjoint(v, m)));
    ops(m.f).copy_row(m, i, v, 0);
}

void packmat_extract_submatrix(packmat_mat   dst,
                               packmat_mat   src,
                               packmat_index rows,
                               packmat_index cols)
{
    PACKMAT_ASSERT(dst.f == src.f && disjoint(dst, src));
    PACKMAT_ASSERT(dst.nrows == rows.len && dst.ncols == cols.len);
    PACKMAT_ASSERT(indices_below(rows, src.nrows));
    PACKMAT_ASSERT(indices_below(cols, src.ncols));
    packmat_zero(dst);
    ops(dst.f).copy_submatrix(dst, src, packmat_range(0, rows.len), rows,
                              packmat_range(0, cols.len), cols);
}

void packmat_copy_submatrix(packmat_mat   dst,
                            packmat_mat   src,
                            packmat_index drows,
                            packmat_index srows,
                            packmat_index dcols,
                            packmat_index scols)
{
    PACKMAT_ASSERT(dst.f == src.f);
    PACKMAT_ASSERT(dst.w == src.w ? same_shape(dst, src) &&
                                        (indices_disjoint(drows, srows) ||
                                         indices_disjoint(dcols, scols))
                                  : disjoint(dst, src));
    PACKMAT_ASSERT(drows.len == srows.len && dcols.len == scols.len);
    PACKMAT_ASSERT(indices_below(drows, dst.nrows));
    PACKMAT_ASSERT(indices_below(srows, src.nrows));
    PACKMAT_ASSERT(indices_below(dcols, dst.ncols));
    PACKMAT_ASSERT(indices_below(scols, src.ncols));
    ops(dst.f).copy_submatrix(dst, src, drows, srows, dcols, scols);
}

void packmat_copy_subvector(packmat_mat   dst,
                            packmat_mat   src,
                            packmat_index dcols,
                            packmat_index scols)
{
    PACKMAT_ASSERT(dst.nrows == 1 && src.nrows == 1);
    packmat_copy_submatrix(dst, src, packmat_range(0, 1), packmat_range(0, 1),
                           dcols, scols);
}

void packmat_transpose(packmat_mat dst, packmat_mat src)
{
    PACKMAT_ASSERT(dst.f == src.f && disjoint(dst, src));
    PACKMAT_ASSERT(dst.nrows == src.ncols && dst.ncols == src.nrows);
    ops(dst.f).transpose(dst, src);
}

int packmat_mul(packmat_mat  dst,
                packmat_mat  a,
                packmat_mat  b,
                packmat_poll poll,
                void *       data)
{
    assert_product(dst, a, b);
    PACKMAT_ASSERT(a.ncols == b.nrows);
    PACKMAT_ASSERT(dst.nrows == a.nrows && dst.ncols == b.ncols);
    return ops(dst.f).mul(dst, a, b, poll, data);
}

// v is the only row of a 1 x m.nrows matrix
int packmat_vec_mul_mat(packmat_mat  dst,
                        packmat_mat  v,
                        packmat_mat  m,
                        packmat_poll poll,
                        void *       data)
{
    assert_product(dst, v, m);
    PACKMAT_ASSERT(v.nrows == 1 && v.ncols == m.nrows);
    PACKMAT_ASSERT(dst.nrows == 1 && dst.ncols == m.ncols);
    return ops(dst.f).mul(dst, v, m, poll, data);
}

int packmat_mat_mul_vec(packmat_mat  dst,
                        packmat_mat  m,
                        packmat_mat  v,
                        packmat_poll poll,
                        void *       data)
{
    assert_product(dst, m, v);
    PACKMAT_ASSERT(v.nrows == 1 && v.ncols == m.ncols);
    PACKMAT_ASSERT(dst.nrows == 1 && dst.ncols == m.nrows);
    return ops(dst.f).mat_mul_vec(dst, m, v, poll, data);
}

int packmat_kronecker(packmat_mat  dst,
                      packmat_mat  a,
                      packmat_mat  b,
                      packmat_poll poll,
                      void *       data)
{
    assert_product(dst, a, b);
    PACKMAT_ASSERT((uint64_t)a.nrows * b.nrows == dst.nrows);
    PACKMAT_ASSERT((uint64_t)a.ncols * b.ncols == dst.ncols);
    return ops(dst.f).kronecker(dst, a, b, poll, data);
}

}    // extern "C"
