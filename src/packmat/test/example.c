/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  How the packmat C API is used, in plain C99. `make check-packmat` runs
**  it; each CHECK states what a call returns. malloc stands in for the GAP
**  bags of the binding.
*/

#include "../packmat.h"

#include <stdio.h>
#include <stdlib.h>

#define CHECK(cond)                                                          \
    do {                                                                     \
        if (!(cond)) {                                                       \
            fprintf(stderr, "%s:%d: CHECK(%s) failed\n", __FILE__, __LINE__, \
                    #cond);                                                  \
            exit(1);                                                         \
        }                                                                    \
    } while (0)

// A context for Z/nZ, or GF(2) for n = 2. With `ranked`, room for a rank
// table follows the struct.
static packmat_field * new_field(uint64_t n, int ranked)
{
    const int       kind = packmat_choose_kind(n, 1);
    packmat_field * f = malloc(packmat_field_size(kind, n, ranked));
    CHECK(f != NULL);
    CHECK(packmat_field_init(f, kind, n, ranked) == PACKMAT_OK);
    return f;
}

// Words for a zero matrix, and a view of them. The words are the matrix;
// the view adds context and dimensions for the calls.
static packmat_mat new_matrix(const packmat_field * f,
                              uint32_t              nrows,
                              uint32_t              ncols)
{
    uint64_t * w =
        malloc(packmat_matrix_words(f, nrows, ncols) * sizeof(uint64_t));
    CHECK(w != NULL);
    const packmat_mat m = packmat_mat_view(f, w, nrows, ncols);
    packmat_zero(m);
    return m;
}

// GF(2): one bit per entry. A row of 5 entries takes 5 bits, so
// floor(64/5) = 12 rows share a word, and a 3 x 5 matrix is one word with
// row i in bits 5i..5i+4.
static void gf2_matrix(void)
{
    packmat_field * f = new_field(2, 0);
    CHECK(f->kind == PACKMAT_GF2 && f->bits == 1 && f->cpw == 64);
    CHECK(packmat_rows_per_word(f, 5) == 12);
    CHECK(packmat_matrix_words(f, 3, 5) == 1);

    const packmat_mat m = new_matrix(f, 3, 5);
    packmat_mat_set(m, 0, 0, 1);    // bit 0
    packmat_mat_set(m, 1, 2, 1);    // bit 5 + 2
    packmat_mat_set(m, 2, 4, 1);    // bit 10 + 4
    CHECK(m.w[0] == (1u << 0 | 1u << 7 | 1u << 14));
    CHECK(packmat_mat_get(m, 1, 2) == 1);
    CHECK(packmat_mat_get(m, 1, 3) == 0);
    CHECK(!packmat_is_zero(m));
    CHECK(packmat_check_invariants(m));

    // 100 entries need two words per row
    CHECK(packmat_rows_per_word(f, 100) == 1);
    CHECK(packmat_stride(f, 100) == 2);
    CHECK(packmat_matrix_words(f, 3, 100) == 6);

    free(m.w);
    free(f);
}

// Z/7Z: one residue per word, row-major
static void zmod7_matrices(void)
{
    packmat_field * f = new_field(7, 0);
    CHECK(f->kind == PACKMAT_M64 && f->cpw == 1);

    const packmat_mat a = new_matrix(f, 2, 2);
    const packmat_mat b = new_matrix(f, 2, 2);
    packmat_identity(a);
    CHECK(a.w[0] == 1 && a.w[1] == 0 && a.w[2] == 0 && a.w[3] == 1);
    CHECK(packmat_is_identity(a));

    packmat_copy(b, a);
    CHECK(packmat_equal(a, b));
    CHECK(packmat_hash(a) == packmat_hash(b));

    packmat_mat_set(b, 0, 1, 3);    // b = [[1, 3], [0, 1]]
    CHECK(!packmat_equal(a, b));
    CHECK(!packmat_is_identity(b));
    CHECK(packmat_compare(a, b) == -1);    // a[0,1] = 0 < 3

    free(a.w);
    free(b.w);
    free(f);
}

// GAP orders GF(7) by discrete logarithm: 0, then 3^0 = 1, 3^1 = 3,
// 3^2 = 2, ... A rank table makes packmat_compare follow that order.
static void gf7_order(void)
{
    packmat_field * f = new_field(7, 1);
    uint16_t *      rank = packmat_field_rank(f);
    uint64_t        z = 1;
    rank[0] = 0;
    for (int k = 0; k < 6; k++) {
        rank[z] = (uint16_t)(k + 1);
        z = z * 3 % 7;
    }
    CHECK(packmat_field_check(f));

    uint64_t two = 2, three = 3;
    CHECK(packmat_compare(packmat_vec_view(f, &two, 1),
                          packmat_vec_view(f, &three, 1)) == 1);

    free(f);
}

// A vector of length len is a 1 x len view. Over GF(2), entry i is bit
// i mod 64 of word i / 64.
static void gf2_vector(void)
{
    packmat_field * f = new_field(2, 0);
    CHECK(packmat_vector_words(f, 70) == 2);

    uint64_t          w[2];
    const packmat_mat v = packmat_vec_view(f, w, 70);
    packmat_zero(v);
    packmat_vec_set(v, 65, 1);
    CHECK(w[0] == 0 && w[1] == 2);
    CHECK(packmat_vec_get(v, 65) == 1);
    CHECK(!packmat_is_zero(v));

    free(f);
}

// Residue arithmetic works for any modulus below 2^64
static void residues(void)
{
    const uint64_t  n = ((uint64_t)1 << 61) - 1;
    packmat_field * f = new_field(n, 0);
    uint64_t        inv;
    CHECK(packmat_mod_add(f, n - 1, 2) == 1);
    CHECK(packmat_mod_mul(f, n - 1, n - 1) == 1);    // (-1)^2
    CHECK(packmat_mod_inv(f, 2, &inv) == PACKMAT_OK);
    CHECK(packmat_mod_mul(f, 2, inv) == 1);

    // For a fixed factor, precompute its Shoup constant once
    const uint64_t s = 3, sp = packmat_mod_shoup(f, s);
    CHECK(packmat_mod_mul_shoup(f, n - 1, s, sp) == n - 3);
    free(f);

    packmat_field * g = new_field(6, 0);
    CHECK(packmat_mod_inv(g, 2, &inv) == PACKMAT_NOT_UNIT);
    free(g);
}

// The binding's poll callback tests GAP's interrupt flag; here a flag
// that is never set
static int poll_flag(void * data)
{
    return *(const int *)data;
}

// Row operations, sub-matrices and products over Z/7Z
static void zmod7_rows(void)
{
    packmat_field *   f = new_field(7, 0);
    const packmat_mat m = new_matrix(f, 2, 3);
    packmat_mat_set(m, 0, 0, 1);    // m = [[1, 2, 0], [3, 4, 5]]
    packmat_mat_set(m, 0, 1, 2);
    packmat_mat_set(m, 1, 0, 3);
    packmat_mat_set(m, 1, 1, 4);
    packmat_mat_set(m, 1, 2, 5);

    packmat_add_rows(m, 1, 0, 4);    // row 1 += 4 * row 0: [0, 5, 5]
    CHECK(packmat_mat_get(m, 1, 0) == 0 && packmat_mat_get(m, 1, 1) == 5);
    CHECK(packmat_position_nonzero_in_row(m, 1, 0) == 1);
    CHECK(packmat_position_nonzero_in_row(m, 0, 2) == 3);    // none

    // column 2 as a 2 x 1 matrix: index lists or ranges select entries
    const uint32_t    cols[] = { 2 };
    const packmat_mat c = new_matrix(f, 2, 1);
    packmat_extract_submatrix(c, m, packmat_range(0, 2),
                              packmat_indices(cols, 1));
    CHECK(packmat_mat_get(c, 0, 0) == 0 && packmat_mat_get(c, 1, 0) == 5);

    // m times its transpose: [[5, 10], [10, 50]] mod 7
    const packmat_mat t = new_matrix(f, 3, 2);
    const packmat_mat p = new_matrix(f, 2, 2);
    int               stop = 0;
    packmat_transpose(t, m);
    CHECK(packmat_mul(p, m, t, poll_flag, &stop) == PACKMAT_OK);
    CHECK(packmat_mat_get(p, 0, 0) == 5 && packmat_mat_get(p, 0, 1) == 3);
    CHECK(packmat_mat_get(p, 1, 0) == 3 && packmat_mat_get(p, 1, 1) == 1);

    // scale a vector so that its first nonzero entry is 1: times 1/3 = 5
    uint64_t          w[3] = { 0, 3, 6 };
    const packmat_mat v = packmat_vec_view(f, w, 3);
    CHECK(packmat_vec_normalize(v) == PACKMAT_OK);
    CHECK(w[1] == 1 && w[2] == 2);

    free(m.w);
    free(c.w);
    free(t.w);
    free(p.w);
    free(f);

    // over Z/6Z, 2 has no inverse
    packmat_field * g = new_field(6, 0);
    uint64_t        u[2] = { 2, 1 };
    CHECK(packmat_vec_normalize(packmat_vec_view(g, u, 2)) ==
          PACKMAT_NOT_UNIT);
    free(g);
}

int main(void)
{
    gf2_matrix();
    zmod7_matrices();
    gf7_order();
    gf2_vector();
    residues();
    zmod7_rows();
    printf("packmat example: ok\n");
    return 0;
}
