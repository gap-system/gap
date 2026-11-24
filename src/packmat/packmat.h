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
**  and Z/nZ (2 <= n < 2^64). The core includes no GAP headers, allocates
**  no memory and keeps no global state. test/example.c shows its use in C.
**
**  Contexts. A packmat_field describes the base ring: kind, n and
**  precomputed constants. The caller provides packmat_field_size() bytes
**  and fills them with packmat_field_init(); every other function takes
**  the context as its first argument f.
**
**  Objects. The entries of a matrix live in packmat_matrix_words(f, nrows,
**  ncols) words of uint64_t that the caller allocates (in GAP: the data
**  part of a bag). Functions see them through a view, a packmat_mat of
**  context, words and dimensions, passed by value. Build views right
**  before a call, since GAP bags move. A vector of length len is a 1 x len
**  view, made by packmat_vec_view.
**
**      // a 3 x 4 matrix over Z/7Z, with malloc in place of GAP bags
**      packmat_field * f = malloc(packmat_field_size(PACKMAT_M64, 7, 0));
**      packmat_field_init(f, PACKMAT_M64, 7, 0);
**      uint64_t * w =
**          malloc(packmat_matrix_words(f, 3, 4) * sizeof(uint64_t));
**      packmat_mat m = packmat_mat_view(f, w, 3, 4);
**      packmat_zero(m);
**      packmat_mat_set(m, 1, 2, 5);              // m[1,2] := 5
**      uint64_t x = packmat_mat_get(m, 1, 2);    // 5
**
**  Contract:
**  - Contexts, word buffers and scratch are 8-byte aligned. On 32-bit
**    builds GAP bag data is only 4-byte aligned, which i386 tolerates and
**    other 32-bit targets may not.
**  - Functions trust f: f->kind indexes a table, checked only in debug
**    builds. Validate a context of unknown origin, such as one from a
**    workspace, with packmat_field_check().
**  - The caller checks every index: i < nrows, j < ncols, x < n. Only
**    debug builds assert them; otherwise a row beyond nrows in a shared
**    word silently sets unused bits.
**  - Two-operand functions need views with the same context and equal
**    dimensions, asserted in debug builds; their words do not overlap
**    unless the function allows it ("dst may be a": dst.w == a.w).
**  - Dimensions are uint32_t; the caller checks that sizes fit in memory.
**  - A routine that needs scratch memory takes `void *scratch`, sized in
**    bytes by `size_t packmat_<op>_scratch(...)`. No routine needs it yet.
**  - Debug builds (PACKMAT_DEBUG or GAP_KERNEL_DEBUG defined) assert the
**    preconditions they can check.
**
**  Layout:
**  - A word is a uint64_t on every platform. A cell holds one entry; bits
**    per cell and cells per word (cpw) depend on the kind of the field.
**    Cell j of a word occupies bits [j*bits, (j+1)*bits).
**  - Matrices are row-major, and a row never straddles words. If
**    0 < ncols <= cpw/2, r = floor(cpw/ncols) rows share a word: row i
**    starts at cell (i mod r)*ncols of word i/r. Otherwise row i starts at
**    word i*stride, with stride = ceil(ncols/cpw). A vector of length len
**    has the layout of both a 1 x len and a len x 1 matrix.
**  - Unused cells and bits are zero, and every cell holds a residue in
**    0..n-1. Functions expect and preserve this.
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
    PACKMAT_NOT_UNIT = 1,       // the argument has no inverse mod n
    PACKMAT_INVALID = 2,        // kind, modulus or options do not fit
    PACKMAT_ZERO = 3,           // the vector is zero
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

// Initialise a context in packmat_field_size bytes at f. Returns
// PACKMAT_OK or PACKMAT_INVALID. A rank table starts as the identity, so
// packmat_compare uses residue order until the caller fills it.
int packmat_field_init(packmat_field * f, int kind, uint64_t n, int ranked);

// Rank table: rank[x] orders residue x for packmat_compare; NULL if none.
// The caller may overwrite it with any permutation of 0..n-1 that keeps
// rank[0] = 0, i.e. zero sorts first.
uint16_t * packmat_field_rank(packmat_field * f);

// 1 if f is a consistent context: constants, and a rank table as above.
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
**  Views
*/

// A matrix as functions see it. The words belong to the caller.
typedef struct packmat_mat {
    const packmat_field * f;
    uint64_t *            w;    // word 0 of the entries
    uint32_t              nrows;
    uint32_t              ncols;
} packmat_mat;

static inline packmat_mat packmat_mat_view(const packmat_field * f,
                                           uint64_t *            w,
                                           uint32_t              nrows,
                                           uint32_t              ncols)
{
    packmat_mat m;
    m.f = f;
    m.w = w;
    m.nrows = nrows;
    m.ncols = ncols;
    return m;
}

// A vector of length len, as a 1 x len view
static inline packmat_mat
packmat_vec_view(const packmat_field * f, uint64_t * w, uint32_t len)
{
    return packmat_mat_view(f, w, 1, len);
}

/****************************************************************************
**
**  Entries, as residues 0..n-1
*/

// Entry (i, j) of m.
uint64_t packmat_mat_get(packmat_mat m, uint32_t i, uint32_t j);

// Set entry (i, j) of m to x.
void packmat_mat_set(packmat_mat m, uint32_t i, uint32_t j, uint64_t x);

// Entry i of the vector view v (nrows = 1).
uint64_t packmat_vec_get(packmat_mat v, uint32_t i);

// Set entry i of the vector view v to x.
void packmat_vec_set(packmat_mat v, uint32_t i, uint64_t x);

/****************************************************************************
**
**  Whole objects
*/

// Fill with zeros.
void packmat_zero(packmat_mat m);

// Fill with ones on the diagonal, zeros elsewhere; any shape.
void packmat_identity(packmat_mat m);

// Copy the entries of src to dst.
void packmat_copy(packmat_mat dst, packmat_mat src);

// 1 if equal, else 0.
int packmat_equal(packmat_mat a, packmat_mat b);

// -1, 0 or 1: a against b, lexicographically in row-major entry order,
// entries ordered by the rank table, or as residues without one. For
// vectors of different lengths compare views of the shorter length: a
// nonzero result is the answer, and 0 means the shorter one sorts first.
int packmat_compare(packmat_mat a, packmat_mat b);

// 64-bit hash of (nrows, ncols, words), the same on every platform; the
// formula is in matrix.cc.
uint64_t packmat_hash(packmat_mat m);

// 1 if every entry is zero.
int packmat_is_zero(packmat_mat m);

// 1 if square with ones on the diagonal and zeros elsewhere (also 0 x 0).
int packmat_is_identity(packmat_mat m);

// 1 if unused cells and bits are zero and all cells are below n. For
// debugging and tests.
int packmat_check_invariants(packmat_mat m);

/****************************************************************************
**
**  Arithmetic, rows, columns and copies
**
**  Scalars s are residues below n. Ranges of entries are half-open: from
**  <= i < to; an empty range (from >= to) does nothing, and otherwise
**  to <= length. Debug builds assert dimensions, indices and scalars.
*/

// A list of len row or column indices: idx[0..len), or first, first + 1,
// ..., first + len - 1 if idx is NULL. Copies between column ranges, or
// index lists of consecutive columns, are word copies; others go by cell.
typedef struct packmat_index {
    const uint32_t * idx;
    uint32_t         first;
    uint32_t         len;
} packmat_index;

static inline packmat_index packmat_range(uint32_t first, uint32_t len)
{
    packmat_index r;
    r.idx = 0;
    r.first = first;
    r.len = len;
    return r;
}

static inline packmat_index packmat_indices(const uint32_t * idx,
                                            uint32_t         len)
{
    packmat_index r;
    r.idx = idx;
    r.first = 0;
    r.len = len;
    return r;
}

// Whole objects of equal dimensions: dst = a + b, a - b, -a and s*a;
// dst may be a or b.
void packmat_add(packmat_mat dst, packmat_mat a, packmat_mat b);
void packmat_sub(packmat_mat dst, packmat_mat a, packmat_mat b);
void packmat_neg(packmat_mat dst, packmat_mat a);
void packmat_scale(packmat_mat dst, packmat_mat a, uint64_t s);

// dst += s*a; dst may be a.
void packmat_addmul(packmat_mat dst, packmat_mat a, uint64_t s);

// Number of nonzero entries of m, and of entries in which a and b differ.
uint64_t packmat_weight(packmat_mat m);
uint64_t packmat_distance(packmat_mat a, packmat_mat b);

// Vectors. dst[i] += s*src[i] for i in [from, to), and no other entry;
// dst may be src.
void packmat_vec_addmul(
    packmat_mat dst, packmat_mat src, uint64_t s, uint32_t from, uint32_t to);

// v[i] *= s for i in [from, to), and no other entry.
void packmat_vec_scale(packmat_mat v, uint64_t s, uint32_t from, uint32_t to);

// Sum of a[i]*b[i], for vectors of equal length.
uint64_t packmat_vec_dot(packmat_mat a, packmat_mat b);

// Index of the first nonzero entry at or after from, or the length if
// there is none.
uint32_t packmat_vec_position_nonzero(packmat_mat v, uint32_t from);

// 1 + the index of the last nonzero entry; 0 if v is zero.
uint32_t packmat_vec_position_last_nonzero(packmat_mat v);

// Scale v so that its first nonzero entry becomes 1: PACKMAT_OK. If v is
// zero, PACKMAT_ZERO; if that entry is not a unit, PACKMAT_NOT_UNIT; in
// both cases v is unchanged.
int packmat_vec_normalize(packmat_mat v);

// Swap rows i and j of m; i may be j.
void packmat_swap_rows(packmat_mat m, uint32_t i, uint32_t j);

// Row i *= s.
void packmat_mult_row(packmat_mat m, uint32_t i, uint64_t s);

// Row i += s * row j; i may be j.
void packmat_add_rows(packmat_mat m, uint32_t i, uint32_t j, uint64_t s);

// Column of the first nonzero entry of row i at or after column from, or
// ncols if there is none.
uint32_t
packmat_position_nonzero_in_row(packmat_mat m, uint32_t i, uint32_t from);

// Columns, cell by cell: swap columns i and j of m; i may be j.
void packmat_swap_cols(packmat_mat m, uint32_t i, uint32_t j);

// Column i *= s.
void packmat_mult_col(packmat_mat m, uint32_t i, uint64_t s);

// Column i += s * column j; i may be j.
void packmat_add_cols(packmat_mat m, uint32_t i, uint32_t j, uint64_t s);

// v = row i of m; v has length m.ncols.
void packmat_copy_row_to_vector(packmat_mat v, packmat_mat m, uint32_t i);

// Row i of m = v; v has length m.ncols.
void packmat_copy_vector_to_row(packmat_mat m, uint32_t i, packmat_mat v);

// dst = src{rows}{cols}, of dimensions rows.len x cols.len; dst need not
// be initialised. Applied to vectors with rows = packmat_range(0, 1), it
// extracts a sub-vector.
void packmat_extract_submatrix(packmat_mat   dst,
                               packmat_mat   src,
                               packmat_index rows,
                               packmat_index cols);

// dst{drows}{dcols} = src{srows}{scols}, with drows.len = srows.len and
// dcols.len = scols.len; other entries of dst are unchanged. Indices may
// repeat: the last write wins.
void packmat_copy_submatrix(packmat_mat   dst,
                            packmat_mat   src,
                            packmat_index drows,
                            packmat_index srows,
                            packmat_index dcols,
                            packmat_index scols);

// dst{dcols} = src{scols}, for vectors.
void packmat_copy_subvector(packmat_mat   dst,
                            packmat_mat   src,
                            packmat_index dcols,
                            packmat_index scols);

// dst = the transpose of src, of dimensions src.ncols x src.nrows.
void packmat_transpose(packmat_mat dst, packmat_mat src);

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

// a + b, a - b and -a mod n.
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
