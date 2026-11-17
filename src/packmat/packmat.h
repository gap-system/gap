/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  C API of the packed matrix core: dense matrices and vectors over GF(2)
**  and Z/nZ (2 <= n < 2^64) in caller-owned word buffers. The core
**  includes no GAP headers, allocates no memory and keeps no global state.
**
**  Conventions:
**  - A word is a uint64_t on every platform. A cell holds one entry; bits
**    per cell and cells per word (cpw) depend on the kind of the field.
**    Cell j of a word occupies bits [j*bits, (j+1)*bits).
**  - Matrices are row-major, and a row never straddles words. If
**    0 < ncols <= cpw/2, r = floor(cpw/ncols) rows share a word: row i
**    starts at cell (i mod r)*ncols of word i/r. Otherwise row i starts at
**    word i*stride, with stride = ceil(ncols/cpw).
**  - A vector of length len is laid out as a 1 x len matrix; pass
**    nrows = 1, ncols = len to the whole-object functions.
**  - Unused cells and bits are zero, and every cell holds a residue in
**    0..n-1. Functions expect and preserve this.
**  - Dimensions are uint32_t; the caller checks that sizes fit in memory.
**  - Scratch memory: a routine that needs it takes `void *scratch`, sized
**    in bytes by `size_t packmat_<op>_scratch(...)`. The core never calls
**    malloc. No routine needs scratch yet.
**  - Preconditions are asserted if PACKMAT_DEBUG or GAP_KERNEL_DEBUG is
**    defined.
*/

#ifndef PACKMAT_PACKMAT_H
#define PACKMAT_PACKMAT_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Kinds: the storage and arithmetic variants. GF2: n = 2, 1 bit per cell.
// M64: one residue mod n per word, any 2 <= n < 2^64.
enum {
    PACKMAT_NO_KIND = -1,
    PACKMAT_GF2 = 0,
    PACKMAT_M64 = 1,
    PACKMAT_NUM_KINDS
};

// Status codes
enum {
    PACKMAT_OK = 0,
    PACKMAT_NOT_UNIT = 1,    // the argument has no inverse mod n
    PACKMAT_INVALID = 2,     // kind, modulus or options do not fit
};

// Field context: plain data, so that it can live in a GAP bag and survive
// workspaces. Per-kind code is found through `kind`. If `ranked` is 1, a
// rank table of n uint16_t follows the struct (see packmat_field_rank).
typedef struct packmat_field {
    uint32_t kind;      // PACKMAT_GF2, PACKMAT_M64
    uint32_t degree;    // 1 (prime fields and Z/nZ)
    uint32_t bits;      // bits per cell
    uint32_t cpw;       // cells per word
    uint64_t n;         // modulus
    uint64_t ninv;      // Moeller-Granlund preinverse of n << norm
    uint32_t norm;      // leading zero bits of n
    uint32_t ranked;    // 1 if a rank table follows
} packmat_field;

/****************************************************************************
**
**  Field contexts
*/

// Kind for Z/nZ (degree 1) or GF(n^degree), or PACKMAT_NO_KIND.
int packmat_choose_kind(uint64_t n, uint32_t degree);

// Bytes needed for a context, including the rank table if `ranked`;
// 0 if the combination is invalid. Rank tables need n <= 2^16.
size_t packmat_field_size(int kind, uint64_t n, int ranked);

// Initialise a context in packmat_field_size bytes at f (8-byte aligned).
// The rank table, if any, starts as the identity. Returns PACKMAT_OK or
// PACKMAT_INVALID.
int packmat_field_init(packmat_field * f, int kind, uint64_t n, int ranked);

// Rank table: rank[x] orders residue x for packmat_compare; NULL if none.
// The caller may overwrite it with any permutation of 0..n-1.
uint16_t * packmat_field_rank(packmat_field * f);

// 1 if f is a consistent context (constants, rank table a permutation).
int packmat_field_check(const packmat_field * f);

/****************************************************************************
**
**  Layout
*/

// Rows per word: floor(cpw/ncols) if 0 < ncols <= cpw/2, else 1.
uint32_t packmat_rows_per_word(const packmat_field * f, uint32_t ncols);

// Words per row: ceil(ncols/cpw) if rows_per_word is 1, else 0.
uint32_t packmat_stride(const packmat_field * f, uint32_t ncols);

// Words of an nrows x ncols matrix, and of a vector of length len.
uint64_t packmat_matrix_words(const packmat_field * f,
                              uint32_t              nrows,
                              uint32_t              ncols);
uint64_t packmat_vector_words(const packmat_field * f, uint32_t len);

/****************************************************************************
**
**  Entries
**
**  Residues go in and out as uint64_t; i < nrows, j < ncols, x < n.
*/

uint64_t packmat_mat_get(const packmat_field * f,
                         const uint64_t *      m,
                         uint32_t              ncols,
                         uint32_t              i,
                         uint32_t              j);
void     packmat_mat_set(const packmat_field * f,
                         uint64_t *            m,
                         uint32_t              ncols,
                         uint32_t              i,
                         uint32_t              j,
                         uint64_t              x);
uint64_t packmat_vec_get(const packmat_field * f,
                         const uint64_t *      v,
                         uint32_t              i);
void     packmat_vec_set(const packmat_field * f,
                         uint64_t *            v,
                         uint32_t              i,
                         uint64_t              x);

/****************************************************************************
**
**  Whole objects
**
**  Two-operand functions require equal dimensions; buffers do not overlap.
*/

// Fill with zeros.
void packmat_zero(const packmat_field * f,
                  uint64_t *            m,
                  uint32_t              nrows,
                  uint32_t              ncols);

// Fill with ones on the diagonal, zeros elsewhere; any shape.
void packmat_identity(const packmat_field * f,
                      uint64_t *            m,
                      uint32_t              nrows,
                      uint32_t              ncols);

void packmat_copy(const packmat_field * f,
                  uint64_t *            dst,
                  const uint64_t *      src,
                  uint32_t              nrows,
                  uint32_t              ncols);

// 1 if equal, else 0.
int packmat_equal(const packmat_field * f,
                  const uint64_t *      a,
                  const uint64_t *      b,
                  uint32_t              nrows,
                  uint32_t              ncols);

// -1, 0 or 1: a against b, lexicographically in row-major entry order,
// entries ordered by the rank table, or as residues without one.
int packmat_compare(const packmat_field * f,
                    const uint64_t *      a,
                    const uint64_t *      b,
                    uint32_t              nrows,
                    uint32_t              ncols);

// 64-bit hash of (nrows, ncols, words), the same on every platform; the
// formula is in matrix.cc.
uint64_t packmat_hash(const packmat_field * f,
                      const uint64_t *      m,
                      uint32_t              nrows,
                      uint32_t              ncols);

int packmat_is_zero(const packmat_field * f,
                    const uint64_t *      m,
                    uint32_t              nrows,
                    uint32_t              ncols);

// 1 if square with ones on the diagonal and zeros elsewhere (also 0 x 0).
int packmat_is_one(const packmat_field * f,
                   const uint64_t *      m,
                   uint32_t              nrows,
                   uint32_t              ncols);

// 1 if unused cells and bits are zero and all cells are below n. For
// debugging and tests.
int packmat_check_invariants(const packmat_field * f,
                             const uint64_t *      m,
                             uint32_t              nrows,
                             uint32_t              ncols);

/****************************************************************************
**
**  Residue arithmetic mod n, for any context
**
**  Arguments are residues below n unless stated otherwise.
*/

// a mod n, any a.
uint64_t packmat_mod_reduce(const packmat_field * f, uint64_t a);

// (hi*2^64 + lo) mod n; needs hi < n.
uint64_t
packmat_mod_reduce2(const packmat_field * f, uint64_t hi, uint64_t lo);

uint64_t packmat_mod_add(const packmat_field * f, uint64_t a, uint64_t b);
uint64_t packmat_mod_sub(const packmat_field * f, uint64_t a, uint64_t b);
uint64_t packmat_mod_neg(const packmat_field * f, uint64_t a);

// a*b mod n through the preinverse.
uint64_t packmat_mod_mul(const packmat_field * f, uint64_t a, uint64_t b);

// Shoup constant floor(s*2^64/n) for a fixed factor s; needs n < 2^63.
uint64_t packmat_mod_shoup(const packmat_field * f, uint64_t s);

// a*s mod n for any a, with sp = packmat_mod_shoup(f, s); needs n < 2^63.
uint64_t packmat_mod_mul_shoup(const packmat_field * f,
                               uint64_t              a,
                               uint64_t              s,
                               uint64_t              sp);

// Inverse of a mod n into *inv: PACKMAT_OK, or PACKMAT_NOT_UNIT if
// gcd(a, n) > 1 (*inv untouched).
int packmat_mod_inv(const packmat_field * f, uint64_t a, uint64_t * inv);

#ifdef __cplusplus
}
#endif

#endif    // PACKMAT_PACKMAT_H
