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

// A matrix is just its words; the caller keeps the dimensions.
static uint64_t * new_matrix(const packmat_field * f,
                             uint32_t              nrows,
                             uint32_t              ncols)
{
    uint64_t * m =
        malloc(packmat_matrix_words(f, nrows, ncols) * sizeof(uint64_t));
    CHECK(m != NULL);
    packmat_zero(f, m, nrows, ncols);
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

    uint64_t * m = new_matrix(f, 3, 5);
    packmat_mat_set(f, m, 5, 0, 0, 1);    // bit 0
    packmat_mat_set(f, m, 5, 1, 2, 1);    // bit 5 + 2
    packmat_mat_set(f, m, 5, 2, 4, 1);    // bit 10 + 4
    CHECK(m[0] == (1u << 0 | 1u << 7 | 1u << 14));
    CHECK(packmat_mat_get(f, m, 5, 1, 2) == 1);
    CHECK(packmat_mat_get(f, m, 5, 1, 3) == 0);
    CHECK(!packmat_is_zero(f, m, 3, 5));
    CHECK(packmat_check_invariants(f, m, 3, 5));

    // 100 entries need two words per row
    CHECK(packmat_rows_per_word(f, 100) == 1);
    CHECK(packmat_stride(f, 100) == 2);
    CHECK(packmat_matrix_words(f, 3, 100) == 6);

    free(m);
    free(f);
}

// Z/7Z: one residue per word, row-major
static void zmod7_matrices(void)
{
    packmat_field * f = new_field(7, 0);
    CHECK(f->kind == PACKMAT_M64 && f->cpw == 1);

    uint64_t * a = new_matrix(f, 2, 2);
    uint64_t * b = new_matrix(f, 2, 2);
    packmat_identity(f, a, 2, 2);
    CHECK(a[0] == 1 && a[1] == 0 && a[2] == 0 && a[3] == 1);
    CHECK(packmat_is_one(f, a, 2, 2));

    packmat_copy(f, b, a, 2, 2);
    CHECK(packmat_equal(f, a, b, 2, 2));
    CHECK(packmat_hash(f, a, 2, 2) == packmat_hash(f, b, 2, 2));

    packmat_mat_set(f, b, 2, 0, 1, 3);    // b = [[1, 3], [0, 1]]
    CHECK(!packmat_equal(f, a, b, 2, 2));
    CHECK(!packmat_is_one(f, b, 2, 2));
    CHECK(packmat_compare(f, a, b, 2, 2) == -1);    // a[0,1] = 0 < 3

    free(a);
    free(b);
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

    const uint64_t two[1] = { 2 }, three[1] = { 3 };    // 1 x 1 matrices
    CHECK(packmat_compare(f, two, three, 1, 1) == 1);

    free(f);
}

// A vector of length len is a 1 x len matrix. Over GF(2), entry i is bit
// i mod 64 of word i / 64.
static void gf2_vector(void)
{
    packmat_field * f = new_field(2, 0);
    CHECK(packmat_vector_words(f, 70) == 2);

    uint64_t * v = new_matrix(f, 1, 70);
    packmat_vec_set(f, v, 65, 1);
    CHECK(v[0] == 0 && v[1] == 2);
    CHECK(packmat_vec_get(f, v, 65) == 1);
    CHECK(!packmat_is_zero(f, v, 1, 70));

    free(v);
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

int main(void)
{
    gf2_matrix();
    zmod7_matrices();
    gf7_order();
    gf2_vector();
    residues();
    printf("packmat example: ok\n");
    return 0;
}
