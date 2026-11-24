/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Unit tests of the arithmetic, row, column, copy and product functions
**  of packmat.h (from packmat_add on) against ref.h. Destinations start as
**  guard-word garbage wherever the functions do not read them.
*/

#include "common.h"

using std::vector;

static size_t words(const packmat_field * f, uint32_t nrows, uint32_t ncols)
{
    return (size_t)packmat_matrix_words(f, nrows, ncols);
}

static packmat_mat load(const packmat_field * f, Buf & b, const ref::Mat & m)
{
    fill(f, b, m);
    return b.view(f, m.nrows, m.ncols);
}

// b holds exactly m, its guard words are intact, and invariants hold
static bool holds(const packmat_field * f, Buf & b, const ref::Mat & m)
{
    return b.same(ref::pack(m, f->bits)) && b.guards_ok() &&
           packmat_check_invariants(b.view(f, m.nrows, m.ncols));
}

// Rows often zero, at most two nonzero entries otherwise
static ref::Mat sparse_mat(uint64_t n, uint32_t nrows, uint32_t ncols)
{
    ref::Mat m(nrows, ncols);
    for (uint32_t i = 0; i < nrows && ncols > 0; i++) {
        const unsigned k = (unsigned)(rnd() % 3);
        for (unsigned t = 0; t < k; t++)
            m.at(i, (uint32_t)(rnd() % ncols)) = 1 + rnd() % (n - 1);
    }
    return m;
}

// 0, 1, n - 1, a random residue, and non-units: small prime factors of
// n, and one with a larger common factor if a random search finds it
static vector<uint64_t> scalars(uint64_t n)
{
    vector<uint64_t> v;
    v.push_back(0);
    v.push_back(1);
    if (n == 2)
        return v;
    v.push_back(n - 1);
    v.push_back(2 + rnd() % (n - 2));
    const uint64_t small[] = { 2, 3, 5 };
    for (size_t k = 0; k < 3; k++)
        if (small[k] < n && n % small[k] == 0)
            v.push_back(small[k]);
    for (int t = 0; t < 32; t++) {
        const uint64_t s = 2 + rnd() % (n - 2);
        if (ref::gcd(n, s) > 5) {
            v.push_back(s);
            break;
        }
    }
    return v;
}

/****************************************************************************
**
**  Index lists
*/

struct Indices {
    vector<uint32_t> v;
    bool             range;

    packmat_index ix() const
    {
        const uint32_t len = (uint32_t)v.size();
        if (range)
            return packmat_range(len ? v[0] : 0, len);
        return packmat_indices(len ? &v[0] : 0, len);
    }
};

// len indices below bound. kind 0: a range; 1: a list of consecutive
// indices; 2: a random list, with repeats. Starts near word boundaries
// are preferred. Needs len <= bound for kinds 0 and 1, bound > 0 for 2.
static Indices choose(uint32_t bound, uint32_t len, int kind)
{
    Indices r;
    r.range = kind == 0;
    if (kind == 2) {
        for (uint32_t k = 0; k < len; k++)
            r.v.push_back((uint32_t)(rnd() % bound));
        return r;
    }
    const uint32_t room = bound - len;
    const uint32_t starts[] = { 0, 1, 31, 32, 33, 63, 64, 65, room };
    uint32_t       start = starts[rnd() % 9];
    if (start > room)
        start = (uint32_t)(rnd() % (room + 1));
    for (uint32_t k = 0; k < len; k++)
        r.v.push_back(start + k);
    return r;
}

static bool can_choose(uint32_t bound, uint32_t len, int kind)
{
    return kind == 2 ? (bound > 0 || len == 0) : len <= bound;
}

/****************************************************************************
**
**  Whole objects
*/

static void
test_whole(const packmat_field * f, uint32_t nrows, uint32_t ncols)
{
    const uint64_t    n = f->n;
    const ref::Mat    A = random_mat(n, nrows, ncols);
    const ref::Mat    B = random_mat(n, nrows, ncols);
    const ref::Mat    Z(nrows, ncols);
    const size_t      w = words(f, nrows, ncols);
    Buf               a(w), b(w), d(w);
    const packmat_mat va = load(f, a, A), vb = load(f, b, B);
    const packmat_mat vd = d.view(f, nrows, ncols);

    packmat_add(vd, va, vb);
    CHECK(holds(f, d, ref::sum(n, A, B)));
    packmat_sub(vd, va, vb);
    CHECK(holds(f, d, ref::difference(n, A, B)));
    packmat_neg(vd, va);
    CHECK(holds(f, d, ref::difference(n, Z, A)));
    CHECK(holds(f, a, A) && holds(f, b, B));

    // dst is an operand
    load(f, d, A);
    packmat_add(vd, vd, vb);
    CHECK(holds(f, d, ref::sum(n, A, B)));
    load(f, d, B);
    packmat_sub(vd, va, vd);
    CHECK(holds(f, d, ref::difference(n, A, B)));
    load(f, d, A);
    packmat_sub(vd, vd, vd);
    CHECK(holds(f, d, Z));
    load(f, d, A);
    packmat_neg(vd, vd);
    CHECK(holds(f, d, ref::difference(n, Z, A)));

    const vector<uint64_t> sc = scalars(n);
    for (size_t k = 0; k < sc.size(); k++) {
        const uint64_t s = sc[k];
        packmat_scale(vd, va, s);
        CHECK(holds(f, d, ref::scaled(n, A, s)));
        load(f, d, A);
        packmat_scale(vd, vd, s);
        CHECK(holds(f, d, ref::scaled(n, A, s)));
        load(f, d, A);
        packmat_addmul(vd, vb, s);
        CHECK(holds(f, d, ref::sum(n, A, ref::scaled(n, B, s))));
        load(f, d, A);
        packmat_addmul(vd, vd, s);
        CHECK(holds(f, d, ref::sum(n, A, ref::scaled(n, A, s))));
    }

    CHECK(packmat_weight(va) == ref::weight(A));
    CHECK(packmat_distance(va, vb) == ref::distance(A, B));
    CHECK(packmat_distance(va, va) == 0);
    const ref::Mat S = sparse_mat(n, nrows, ncols);
    load(f, d, S);
    CHECK(packmat_weight(vd) == ref::weight(S));
    CHECK(packmat_distance(vd, va) == ref::distance(S, A));
}

/****************************************************************************
**
**  Rows and columns
*/

static void test_rows(const packmat_field * f, uint32_t nrows, uint32_t ncols)
{
    if (nrows == 0)
        return;
    const uint64_t    n = f->n;
    const ref::Mat    A = random_mat(n, nrows, ncols);
    Buf               d(words(f, nrows, ncols));
    const packmat_mat vd = d.view(f, nrows, ncols);
    const uint32_t    r = packmat_rows_per_word(f, ncols);

    const vector<uint64_t> sc = scalars(n);
    for (int t = 0; t < 6; t++) {
        const uint32_t i = (uint32_t)(rnd() % nrows);
        uint32_t       j;
        switch (t) {
        case 0:    // the same row
            j = i;
            break;
        case 1:    // in the same word if rows share words
            j = i / r * r + (uint32_t)(rnd() % r);
            break;
        case 2:    // in the next word
            j = (i + r) % nrows;
            break;
        default:
            j = (uint32_t)(rnd() % nrows);
        }
        if (j >= nrows)
            j = i;
        snprintf(where, sizeof(where),
                 "rows: kind %u, n = %llu, %u x %u, %u, %u", f->kind,
                 (unsigned long long)n, nrows, ncols, i, j);

        ref::Mat R = A;
        ref::swap_rows(R, i, j);
        load(f, d, A);
        packmat_swap_rows(vd, i, j);
        CHECK(holds(f, d, R));

        for (size_t k = 0; k < sc.size(); k++) {
            const uint64_t s = sc[k];
            R = A;
            for (uint32_t c = 0; c < ncols; c++)
                R.at(i, c) = ref::mul(n, s, A.at(i, c));
            load(f, d, A);
            packmat_mult_row(vd, i, s);
            CHECK(holds(f, d, R));

            R = A;
            for (uint32_t c = 0; c < ncols; c++)
                R.at(i, c) =
                    ref::add(n, A.at(i, c), ref::mul(n, s, A.at(j, c)));
            load(f, d, A);
            packmat_add_rows(vd, i, j, s);
            CHECK(holds(f, d, R));
        }
    }

    // pivot search, on a matrix with many zero rows
    snprintf(where, sizeof(where), "pivots: kind %u, n = %llu, %u x %u",
             f->kind, (unsigned long long)n, nrows, ncols);
    const ref::Mat S = sparse_mat(n, nrows, ncols);
    load(f, d, S);
    const uint32_t froms[] = { 0,     1,         2,  ncols / 2, ncols - 1,
                               ncols, ncols + 1, 63, 64,        ~0u };
    for (uint32_t i = 0; i < nrows; i++) {
        for (size_t k = 0; k < sizeof(froms) / sizeof(froms[0]); k++)
            CHECK(packmat_position_nonzero_in_row(vd, i, froms[k]) ==
                  ref::position_nonzero(S, i, froms[k]));
    }
}

static void test_cols(const packmat_field * f, uint32_t nrows, uint32_t ncols)
{
    if (ncols == 0)
        return;
    const uint64_t    n = f->n;
    const ref::Mat    A = random_mat(n, nrows, ncols);
    Buf               d(words(f, nrows, ncols));
    const packmat_mat vd = d.view(f, nrows, ncols);

    const vector<uint64_t> sc = scalars(n);
    for (int t = 0; t < 4; t++) {
        const uint32_t i = (uint32_t)(rnd() % ncols);
        const uint32_t j = t == 0   ? i
                           : t == 1 ? (i + 1) % ncols
                                    : (uint32_t)(rnd() % ncols);
        snprintf(where, sizeof(where),
                 "cols: kind %u, n = %llu, %u x %u, %u, %u", f->kind,
                 (unsigned long long)n, nrows, ncols, i, j);

        ref::Mat R = A;
        ref::swap_cols(R, i, j);
        load(f, d, A);
        packmat_swap_cols(vd, i, j);
        CHECK(holds(f, d, R));

        for (size_t k = 0; k < sc.size(); k++) {
            const uint64_t s = sc[k];
            R = A;
            for (uint32_t c = 0; c < nrows; c++)
                R.at(c, i) = ref::mul(n, s, A.at(c, i));
            load(f, d, A);
            packmat_mult_col(vd, i, s);
            CHECK(holds(f, d, R));

            R = A;
            for (uint32_t c = 0; c < nrows; c++)
                R.at(c, i) =
                    ref::add(n, A.at(c, i), ref::mul(n, s, A.at(c, j)));
            load(f, d, A);
            packmat_add_cols(vd, i, j, s);
            CHECK(holds(f, d, R));
        }
    }
}

/****************************************************************************
**
**  Copies and transposition
*/

static ref::Mat row_of(const ref::Mat & a, uint32_t i)
{
    ref::Mat r(1, a.ncols);
    for (uint32_t j = 0; j < a.ncols; j++)
        r.at(0, j) = a.at(i, j);
    return r;
}

static void
test_copies(const packmat_field * f, uint32_t nrows, uint32_t ncols)
{
    snprintf(where, sizeof(where), "copies: kind %u, n = %llu, %u x %u",
             f->kind, (unsigned long long)f->n, nrows, ncols);
    const uint64_t    n = f->n;
    const ref::Mat    A = random_mat(n, nrows, ncols);
    Buf               a(words(f, nrows, ncols)), d(words(f, nrows, ncols));
    const packmat_mat va = load(f, a, A);
    const packmat_mat vd = d.view(f, nrows, ncols);

    // rows to vectors and back
    const size_t vw = (size_t)packmat_vector_words(f, ncols);
    for (int t = 0; t < 3 && nrows > 0; t++) {
        const uint32_t i = t == 0   ? 0
                           : t == 1 ? nrows - 1
                                    : (uint32_t)(rnd() % nrows);
        Buf            v(vw);
        packmat_copy_row_to_vector(v.view(f, 1, ncols), va, i);
        CHECK(holds(f, v, row_of(A, i)));

        const ref::Mat V = random_mat(n, 1, ncols);
        ref::Mat       R = A;
        for (uint32_t j = 0; j < ncols; j++)
            R.at(i, j) = V.at(0, j);
        load(f, d, A);
        packmat_copy_vector_to_row(vd, i, load(f, v, V));
        CHECK(holds(f, d, R) && holds(f, v, V));
    }

    // sub-matrices: columns by every kind of index list, and lengths
    // around word boundaries
    const uint32_t lens[] = {
        0, 1, 2, 33, 64, 65, ncols / 2, ncols - 1, ncols
    };
    for (int kind = 0; kind < 3; kind++) {
        for (size_t l = 0; l < sizeof(lens) / sizeof(lens[0]); l++) {
            if (!can_choose(ncols, lens[l], kind))
                continue;
            const Indices  cols = choose(ncols, lens[l], kind);
            const int      rkind = (int)(rnd() % 3);
            const uint32_t rlen = rkind == 2
                                      ? (uint32_t)(rnd() % 5)
                                      : (uint32_t)(rnd() % (nrows + 1));
            if (!can_choose(nrows, rlen, rkind))
                continue;
            const Indices  rows = choose(nrows, rlen, rkind);
            const uint32_t er = rlen, ec = lens[l];

            Buf e(words(f, er, ec));
            packmat_extract_submatrix(e.view(f, er, ec), va, rows.ix(),
                                      cols.ix());
            CHECK(holds(f, e, ref::submatrix(A, rows.v, cols.v)));

            // into a matrix of other dimensions, maybe another layout
            const uint32_t dr = nrows + (uint32_t)(rnd() % 3);
            const uint32_t dc = ncols + (rnd() % 2 ? 0 : 37);
            const int      dkind = (int)(rnd() % 3);
            if (!can_choose(dr, er, rkind) || !can_choose(dc, ec, dkind))
                continue;
            const Indices  drows = choose(dr, er, rkind);
            const Indices  dcols = choose(dc, ec, dkind);
            const ref::Mat D = random_mat(n, dr, dc);
            ref::Mat       R = D;
            for (uint32_t i = 0; i < er; i++)
                for (uint32_t j = 0; j < ec; j++)
                    R.at(drows.v[i], dcols.v[j]) = A.at(rows.v[i], cols.v[j]);
            Buf g(words(f, dr, dc));
            packmat_copy_submatrix(load(f, g, D), va, drows.ix(), rows.ix(),
                                   dcols.ix(), cols.ix());
            CHECK(holds(f, g, R));
        }
    }

    Buf t(words(f, ncols, nrows));
    packmat_transpose(t.view(f, ncols, nrows), va);
    CHECK(holds(f, t, ref::transpose(A)));
    CHECK(holds(f, a, A));
}

/****************************************************************************
**
**  Vectors
*/

static void test_vectors(const packmat_field * f, uint32_t len)
{
    snprintf(where, sizeof(where), "vectors: kind %u, n = %llu, length %u",
             f->kind, (unsigned long long)f->n, len);
    const uint64_t    n = f->n;
    const ref::Mat    U = random_mat(n, 1, len), V = random_mat(n, 1, len);
    const size_t      vw = (size_t)packmat_vector_words(f, len);
    Buf               u(vw), v(vw), d(vw);
    const packmat_mat vu = load(f, u, U), vv = load(f, v, V);
    const packmat_mat vd = d.view(f, 1, len);

    // ranges [from, to), including empty ones and from > len
    const uint32_t edges[] = { 0,  1,  2,       31,      32,  33,     63,
                               64, 65, len / 2, len - 1, len, len + 1 };
    const size_t   ne = sizeof(edges) / sizeof(edges[0]);
    const vector<uint64_t> sc = scalars(n);
    for (size_t x = 0; x < ne; x++) {
        const uint32_t from = edges[x];
        if (from > len + 1)
            continue;
        for (size_t y = 0; y < ne; y++) {
            const uint32_t to = edges[y];
            if (to > len)
                continue;
            for (size_t k = 0; k < sc.size(); k++) {
                const uint64_t s = sc[k];
                ref::Mat       R = U, Q = U, P = U;
                for (uint32_t i = from; i < to; i++) {
                    R.at(0, i) =
                        ref::add(n, U.at(0, i), ref::mul(n, s, V.at(0, i)));
                    Q.at(0, i) =
                        ref::add(n, U.at(0, i), ref::mul(n, s, U.at(0, i)));
                    P.at(0, i) = ref::mul(n, s, U.at(0, i));
                }
                load(f, d, U);
                packmat_vec_addmul(vd, vv, s, from, to);
                CHECK(holds(f, d, R));
                load(f, d, U);
                packmat_vec_addmul(vd, vd, s, from, to);
                CHECK(holds(f, d, Q));
                load(f, d, U);
                packmat_vec_scale(vd, s, from, to);
                CHECK(holds(f, d, P));
            }
        }
    }

    // scalar products; all entries n - 1 give len mod n with 2^128-sized
    // products, so the carries of the accumulator take part
    uint64_t dot = 0, sq = 0;
    for (uint32_t i = 0; i < len; i++) {
        dot = ref::add(n, dot, ref::mul(n, U.at(0, i), V.at(0, i)));
        sq = ref::add(n, sq, ref::mul(n, U.at(0, i), U.at(0, i)));
    }
    CHECK(packmat_vec_dot(vu, vv) == dot);
    CHECK(packmat_vec_dot(vu, vu) == sq);
    ref::Mat M(1, len);
    for (uint32_t i = 0; i < len; i++)
        M.at(0, i) = n - 1;
    Buf               m2(vw);
    const packmat_mat vm = load(f, m2, M);
    load(f, d, M);
    CHECK(packmat_vec_dot(vm, vd) == len % n);

    // positions, also beyond the length
    const ref::Mat S = sparse_mat(n, 1, len);
    const ref::Mat Ms[3] = { S, U, ref::Mat(1, len) };
    for (int t = 0; t < 3; t++) {
        const packmat_mat vs = load(f, d, Ms[t]);
        for (size_t x = 0; x < ne; x++)
            CHECK(packmat_vec_position_nonzero(vs, edges[x]) ==
                  ref::position_nonzero(Ms[t], 0, edges[x]));
        CHECK(packmat_vec_position_nonzero(vs, ~0u) == len);
        CHECK(packmat_vec_position_last_nonzero(vs) ==
              ref::position_last_nonzero(Ms[t], 0));
    }

    // normalize: zero, a random vector, and one led by a non-unit
    ref::Mat L = S;
    for (uint32_t i = 0; i < len / 2; i++)
        L.at(0, i) = 0;
    if (len > 0)
        L.at(0, len / 2) = sc.back();
    const ref::Mat Ns[4] = { ref::Mat(1, len), U, S, L };
    for (int t = 0; t < 4; t++) {
        const ref::Mat & X = Ns[t];
        const uint32_t   p = ref::position_nonzero(X, 0, 0);
        const int        st = packmat_vec_normalize(load(f, d, X));
        if (p == len) {
            CHECK(st == PACKMAT_ZERO && holds(f, d, X));
            continue;
        }
        if (ref::gcd(n, X.at(0, p)) != 1) {
            CHECK(st == PACKMAT_NOT_UNIT && holds(f, d, X));
            continue;
        }
        // d = X / X[p]: d[p] = 1, and d[i] * X[p] = X[i]
        CHECK(st == PACKMAT_OK);
        CHECK(packmat_check_invariants(vd) && d.guards_ok());
        CHECK(packmat_vec_get(vd, p) == 1);
        bool ok = true;
        for (uint32_t i = 0; i < len; i++)
            ok &=
                ref::mul(n, packmat_vec_get(vd, i), X.at(0, p)) == X.at(0, i);
        CHECK(ok);
    }

    // sub-vectors, into a vector of another length
    for (int kind = 0; kind < 3; kind++) {
        const uint32_t k = len ? (uint32_t)(rnd() % (len + 1)) : 0;
        const uint32_t dlen = len + (rnd() % 2 ? 0 : 37);
        const int      dkind = (int)(rnd() % 3);
        if (!can_choose(len, k, kind) || !can_choose(dlen, k, dkind))
            continue;
        const Indices  scols = choose(len, k, kind);
        const Indices  dcols = choose(dlen, k, dkind);
        const ref::Mat D = random_mat(n, 1, dlen);
        ref::Mat       R = D;
        for (uint32_t j = 0; j < k; j++)
            R.at(0, dcols.v[j]) = U.at(0, scols.v[j]);
        Buf g((size_t)packmat_vector_words(f, dlen));
        packmat_copy_subvector(load(f, g, D), vu, dcols.ix(), scols.ix());
        CHECK(holds(f, g, R));

        Buf e((size_t)packmat_vector_words(f, k));
        packmat_extract_submatrix(e.view(f, 1, k), vu, packmat_range(0, 1),
                                  scols.ix());
        vector<uint32_t> zero(1, 0);
        CHECK(holds(f, e, ref::submatrix(U, zero, scols.v)));
    }
}

/****************************************************************************
**
**  Products
*/

// Counts calls; asks to stop from call number `stop` on (0: never)
struct Poller {
    unsigned calls, stop;
};

static int count_poll(void * data)
{
    Poller * p = static_cast<Poller *>(data);
    p->calls++;
    return p->stop && p->calls >= p->stop;
}

static ref::Mat column(const ref::Mat & v)
{
    return ref::transpose(v);
}

static void
test_product(const packmat_field * f, uint32_t m, uint32_t k, uint32_t nc)
{
    snprintf(where, sizeof(where), "product: kind %u, n = %llu, %u x %u x %u",
             f->kind, (unsigned long long)f->n, m, k, nc);
    const uint64_t    n = f->n;
    const ref::Mat    A = random_mat(n, m, k), B = random_mat(n, k, nc);
    Buf               a(words(f, m, k)), b(words(f, k, nc));
    const packmat_mat va = load(f, a, A), vb = load(f, b, B);

    const ref::Mat AB = ref::product(n, A, B);
    Buf            d(words(f, m, nc));
    CHECK(packmat_mul(d.view(f, m, nc), va, vb, 0, 0) == PACKMAT_OK);
    CHECK(holds(f, d, AB));
    Poller p = { 0, 0 };
    Buf    e(words(f, m, nc));
    CHECK(packmat_mul(e.view(f, m, nc), va, vb, count_poll, &p) ==
          PACKMAT_OK);
    CHECK(holds(f, e, AB));
    if (m == k && k == nc) {
        Buf s(words(f, m, m));
        CHECK(packmat_mul(s.view(f, m, m), va, va, 0, 0) == PACKMAT_OK);
        CHECK(holds(f, s, ref::product(n, A, A)));
    }
    CHECK(holds(f, a, A) && holds(f, b, B));

    // v*B for v of length k, and A*w for w of length k
    const ref::Mat    V = random_mat(n, 1, k);
    Buf               v((size_t)packmat_vector_words(f, k));
    const packmat_mat vv = load(f, v, V);
    Buf               x((size_t)packmat_vector_words(f, nc));
    CHECK(packmat_vec_mul_mat(x.view(f, 1, nc), vv, vb, 0, 0) == PACKMAT_OK);
    CHECK(holds(f, x, ref::product(n, V, B)));
    Buf y((size_t)packmat_vector_words(f, m));
    CHECK(packmat_mat_mul_vec(y.view(f, 1, m), va, vv, 0, 0) == PACKMAT_OK);
    CHECK(holds(f, y, ref::transpose(ref::product(n, A, column(V)))));
}

static void test_kronecker(const packmat_field * f,
                           uint32_t              ar,
                           uint32_t              ac,
                           uint32_t              br,
                           uint32_t              bc)
{
    snprintf(where, sizeof(where),
             "kronecker: kind %u, n = %llu, %u x %u by %u x %u", f->kind,
             (unsigned long long)f->n, ar, ac, br, bc);
    const uint64_t    n = f->n;
    const ref::Mat    A = random_mat(n, ar, ac), B = random_mat(n, br, bc);
    Buf               a(words(f, ar, ac)), b(words(f, br, bc));
    const packmat_mat va = load(f, a, A), vb = load(f, b, B);
    Buf               d(words(f, ar * br, ac * bc));
    CHECK(packmat_kronecker(d.view(f, ar * br, ac * bc), va, vb, 0, 0) ==
          PACKMAT_OK);
    CHECK(holds(f, d, ref::kronecker(n, A, B)));
    if (ar == br && ac == bc) {
        Buf s(words(f, ar * ar, ac * ac));
        CHECK(packmat_kronecker(s.view(f, ar * ar, ac * ac), va, va, 0, 0) ==
              PACKMAT_OK);
        CHECK(holds(f, s, ref::kronecker(n, A, A)));
    }
}

/****************************************************************************
**
**  Interruption: each product big enough for several polls; stopping at
**  the first and the second leaves a valid object, never stopping the
**  right one.
*/

enum { MUL, VEC_MUL_MAT, MAT_MUL_VEC, KRONECKER };

static void test_interrupt(const packmat_field * f,
                           int                   op,
                           uint32_t              ar,
                           uint32_t              ac,
                           uint32_t              br,
                           uint32_t              bc)
{
    snprintf(where, sizeof(where),
             "interrupt: kind %u, n = %llu, op %d, %u x %u, %u x %u", f->kind,
             (unsigned long long)f->n, op, ar, ac, br, bc);
    const uint64_t    n = f->n;
    const ref::Mat    A = random_mat(n, ar, ac), B = random_mat(n, br, bc);
    Buf               a(words(f, ar, ac)), b(words(f, br, bc));
    const packmat_mat va = load(f, a, A), vb = load(f, b, B);

    ref::Mat want(0, 0);
    switch (op) {
    case MUL:
    case VEC_MUL_MAT:
        want = ref::product(n, A, B);
        break;
    case MAT_MUL_VEC:
        want = ref::transpose(ref::product(n, A, column(B)));
        break;
    default:
        want = ref::kronecker(n, A, B);
    }
    const uint32_t dr = want.nrows, dc = want.ncols;

    for (unsigned stop = 0; stop < 3; stop++) {
        Buf               d(words(f, dr, dc));
        const packmat_mat vd = d.view(f, dr, dc);
        Poller            p = { 0, stop };
        int               st;
        switch (op) {
        case MUL:
            st = packmat_mul(vd, va, vb, count_poll, &p);
            break;
        case VEC_MUL_MAT:
            st = packmat_vec_mul_mat(vd, va, vb, count_poll, &p);
            break;
        case MAT_MUL_VEC:
            st = packmat_mat_mul_vec(vd, va, vb, count_poll, &p);
            break;
        default:
            st = packmat_kronecker(vd, va, vb, count_poll, &p);
        }
        if (stop == 0) {
            CHECK(st == PACKMAT_OK && p.calls >= 2);
            CHECK(holds(f, d, want));
        }
        else {
            CHECK(st == PACKMAT_INTERRUPTED && p.calls == stop);
            CHECK(packmat_check_invariants(vd) && d.guards_ok());
        }
    }
}

static void test_interrupts()
{
    Field G(PACKMAT_GF2, 2, 0), M(PACKMAT_M64, (1ull << 61) - 1, 0);
    test_interrupt(G.f, MUL, 300, 300, 300, 300);
    test_interrupt(G.f, MUL, 2000, 200, 200, 20);    // rows share words
    test_interrupt(G.f, VEC_MUL_MAT, 1, 5000, 5000, 5000);
    test_interrupt(G.f, MAT_MUL_VEC, 100000, 64, 1, 64);
    test_interrupt(G.f, KRONECKER, 64, 64, 100, 1);
    test_interrupt(M.f, MUL, 64, 64, 64, 64);
    test_interrupt(M.f, VEC_MUL_MAT, 1, 600, 600, 600);
    test_interrupt(M.f, MAT_MUL_VEC, 1000, 200, 1, 200);
    test_interrupt(M.f, KRONECKER, 10, 10, 64, 64);
}

/****************************************************************************
**
**  Driver
*/

void test_ops()
{
    // GF2: rows per word change at ncols 21/22 and 32/33
    const uint32_t gf2_rows[] = { 0, 1, 2, 3, 4, 63, 64, 65, 129 };
    const uint32_t gf2_cols[] = { 0,  1,  2,  3,  21,  22,  31, 32,
                                  33, 63, 64, 65, 127, 128, 129 };
    const size_t   nr = sizeof(gf2_rows) / sizeof(gf2_rows[0]);
    const size_t   nc = sizeof(gf2_cols) / sizeof(gf2_cols[0]);
    Field          G(PACKMAT_GF2, 2, 0);
    for (size_t r = 0; r < nr; r++)
        for (size_t c = 0; c < nc; c++) {
            snprintf(where, sizeof(where), "whole: GF2, %u x %u", gf2_rows[r],
                     gf2_cols[c]);
            test_whole(G.f, gf2_rows[r], gf2_cols[c]);
            test_rows(G.f, gf2_rows[r], gf2_cols[c]);
            test_cols(G.f, gf2_rows[r], gf2_cols[c]);
            test_copies(G.f, gf2_rows[r], gf2_cols[c]);
        }
    for (size_t c = 0; c < nc; c++)
        test_vectors(G.f, gf2_cols[c]);
    test_vectors(G.f, 200);

    const uint32_t gf2_m[] = { 0, 1, 2, 5, 65 };
    const uint32_t gf2_k[] = { 0, 1, 21, 33, 64, 65, 129 };
    for (size_t x = 0; x < sizeof(gf2_m) / sizeof(gf2_m[0]); x++)
        for (size_t y = 0; y < sizeof(gf2_k) / sizeof(gf2_k[0]); y++)
            for (size_t c = 0; c < nc; c++)
                test_product(G.f, gf2_m[x], gf2_k[y], gf2_cols[c]);
    test_product(G.f, 64, 64, 64);
    const uint32_t ka[] = { 0, 1, 2, 3 };
    const uint32_t kb[] = { 0, 1, 2, 5, 21, 22, 33, 65 };
    for (size_t w = 0; w < 4; w++)
        for (size_t x = 0; x < 4; x++)
            for (size_t y = 0; y < 8; y++)
                for (size_t z = 0; z < 8; z++)
                    test_kronecker(G.f, ka[w], ka[x], kb[y], kb[z]);

    // M64
    const uint32_t m64_dims[] = { 0, 1, 2, 3, 5 };
    const size_t   nd = sizeof(m64_dims) / sizeof(m64_dims[0]);
    const uint32_t m64_lens[] = { 0, 1, 2, 3, 5, 17, 70 };
    for (size_t k = 0; k < NUM_MODULI; k++) {
        Field F(PACKMAT_M64, MODULI[k], 0);
        for (size_t r = 0; r < nd; r++)
            for (size_t c = 0; c < nd; c++) {
                snprintf(where, sizeof(where), "whole: n = %llu, %u x %u",
                         (unsigned long long)MODULI[k], m64_dims[r],
                         m64_dims[c]);
                test_whole(F.f, m64_dims[r], m64_dims[c]);
                test_rows(F.f, m64_dims[r], m64_dims[c]);
                test_cols(F.f, m64_dims[r], m64_dims[c]);
                test_copies(F.f, m64_dims[r], m64_dims[c]);
            }
        for (size_t l = 0; l < sizeof(m64_lens) / sizeof(m64_lens[0]); l++)
            test_vectors(F.f, m64_lens[l]);
        for (size_t x = 0; x < nd; x++)
            for (size_t y = 0; y < nd; y++)
                for (size_t z = 0; z < nd; z++)
                    test_product(F.f, m64_dims[x], m64_dims[y], m64_dims[z]);
        for (size_t w = 0; w < 4; w++)
            for (size_t x = 0; x < 4; x++)
                for (size_t y = 0; y < 4; y++)
                    for (size_t z = 0; z < 4; z++)
                        test_kronecker(F.f, ka[w], ka[x], ka[y], ka[z]);
    }

    test_interrupts();
}
