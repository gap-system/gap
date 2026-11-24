/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Unit tests of the packed matrix core against the reference in ref.h,
**  on fixed-seed random data and edge dimensions, with the helpers of
**  common.h. Exit status 0 on success. For how the API is used, read
**  example.c.
*/

#include "common.h"

using std::vector;

unsigned long checks, failures;
char          where[200];
uint64_t      rng_state = 0x5eed;

/****************************************************************************
**
**  Residue arithmetic
*/

static vector<uint64_t> sample_residues(uint64_t n, size_t random)
{
    vector<uint64_t> v;
    const uint64_t   edges[] = { 0, 1, 2, 3, n / 2, n / 2 + 1, n - 2, n - 1 };
    for (size_t k = 0; k < sizeof(edges) / sizeof(edges[0]); k++)
        if (edges[k] < n)
            v.push_back(edges[k]);
    for (size_t k = 0; k < random; k++)
        v.push_back(rnd() % n);
    return v;
}

static void test_mod(uint64_t n)
{
    snprintf(where, sizeof(where), "mod %llu", (unsigned long long)n);
    Field                 F(PACKMAT_M64, n, 0);
    const packmat_field * f = F.f;
    CHECK(packmat_field_check(f));

    // reduce, any argument
    const uint64_t wide[] = { 0, n - 1, n, n + 1, 2 * n, ~0ull, ~0ull - 1 };
    for (size_t k = 0; k < sizeof(wide) / sizeof(wide[0]); k++)
        CHECK(packmat_mod_reduce(f, wide[k]) == wide[k] % n);
    for (int k = 0; k < 1000; k++) {
        const uint64_t a = rnd();
        CHECK(packmat_mod_reduce(f, a) == a % n);
        const uint64_t hi = rnd() % n;
        uint64_t       r;
        ref::div2(n, hi, a, &r);
        CHECK(packmat_mod_reduce2(f, hi, a) == r);
    }
    uint64_t r;
    ref::div2(n, n - 1, ~0ull, &r);
    CHECK(packmat_mod_reduce2(f, n - 1, ~0ull) == r);

    // add, sub, neg, mul on all pairs of a sample
    const vector<uint64_t> v = sample_residues(n, 40);
    for (size_t x = 0; x < v.size(); x++) {
        const uint64_t a = v[x];
        CHECK(packmat_mod_neg(f, a) == ref::neg(n, a));
        for (size_t y = 0; y < v.size(); y++) {
            const uint64_t b = v[y];
            CHECK(packmat_mod_add(f, a, b) == ref::add(n, a, b));
            CHECK(packmat_mod_sub(f, a, b) == ref::sub(n, a, b));
            CHECK(packmat_mod_mul(f, a, b) == ref::mul(n, a, b));
        }
    }

    // Shoup: fixed factor s, any a
    if (n < TWO63) {
        for (size_t x = 0; x < v.size(); x++) {
            const uint64_t s = v[x];
            const uint64_t sp = packmat_mod_shoup(f, s);
            uint64_t       rem;
            CHECK(sp == ref::div2(n, s, 0, &rem));
            for (int k = 0; k < 30; k++) {
                const uint64_t a = k == 0 ? ~0ull : k == 1 ? n - 1 : rnd();
                CHECK(packmat_mod_mul_shoup(f, a, s, sp) ==
                      ref::mul(n, a % n, s));
            }
        }
    }

    // inverse: units and non-units
    for (size_t x = 0; x < v.size(); x++) {
        const uint64_t a = v[x];
        uint64_t       inv = 12345;
        const int      st = packmat_mod_inv(f, a, &inv);
        if (ref::gcd(n, a) == 1) {
            CHECK(st == PACKMAT_OK);
            CHECK(inv < n && ref::mul(n, a, inv) == 1 % n);
        }
        else {
            CHECK(st == PACKMAT_NOT_UNIT);
            CHECK(inv == 12345);
        }
    }
}

/****************************************************************************
**
**  Contexts
*/

static void test_contexts()
{
    snprintf(where, sizeof(where), "contexts");
    CHECK(packmat_choose_kind(2, 1) == PACKMAT_GF2);
    CHECK(packmat_choose_kind(3, 1) == PACKMAT_M64);
    CHECK(packmat_choose_kind(6, 1) == PACKMAT_M64);
    CHECK(packmat_choose_kind(~0ull, 1) == PACKMAT_M64);
    CHECK(packmat_choose_kind(1, 1) == PACKMAT_NO_KIND);
    CHECK(packmat_choose_kind(0, 1) == PACKMAT_NO_KIND);
    CHECK(packmat_choose_kind(2, 2) == PACKMAT_NO_KIND);

    CHECK(packmat_field_size(PACKMAT_GF2, 2, 0) == sizeof(packmat_field));
    CHECK(packmat_field_size(PACKMAT_GF2, 3, 0) == 0);
    CHECK(packmat_field_size(PACKMAT_M64, 1, 0) == 0);
    CHECK(packmat_field_size(PACKMAT_M64, 2, 0) == sizeof(packmat_field));
    CHECK(packmat_field_size(PACKMAT_NUM_KINDS, 5, 0) == 0);
    CHECK(packmat_field_size(PACKMAT_NO_KIND, 5, 0) == 0);
    CHECK(packmat_field_size(PACKMAT_M64, 3, 1) == sizeof(packmat_field) + 8);
    CHECK(packmat_field_size(PACKMAT_M64, 65536, 1) ==
          sizeof(packmat_field) + 2 * 65536);
    CHECK(packmat_field_size(PACKMAT_M64, 65537, 1) == 0);
    CHECK(sizeof(packmat_field) % 8 == 0);

    packmat_field g;
    CHECK(packmat_field_init(&g, PACKMAT_GF2, 3, 0) == PACKMAT_INVALID);
    CHECK(packmat_field_init(&g, PACKMAT_GF2, 2, 0) == PACKMAT_OK);
    CHECK(g.kind == PACKMAT_GF2 && g.n == 2 && g.bits == 1 && g.cpw == 64);
    CHECK(g.degree == 1 && g.ranked == 0 && g.norm == 62);
    CHECK(packmat_field_rank(&g) == 0);
    CHECK(packmat_field_check(&g));

    Field          F(PACKMAT_M64, 7, 1);
    packmat_field * f = F.f;
    CHECK(f->kind == PACKMAT_M64 && f->bits == 64 && f->cpw == 1);
    CHECK(f->n == 7 && f->norm == 61 && f->ranked == 1);
    uint16_t * rank = packmat_field_rank(f);
    CHECK(rank != 0);
    for (int x = 0; x < 7; x++)
        CHECK(rank[x] == x);
    CHECK(packmat_field_check(f));
    rank[3] = 2;    // not a permutation
    CHECK(!packmat_field_check(f));
    rank[3] = 7;    // out of range
    CHECK(!packmat_field_check(f));
    rank[3] = 3;
    rank[0] = 1;    // zero must rank first
    rank[1] = 0;
    CHECK(!packmat_field_check(f));
    rank[0] = 0;
    rank[1] = 1;
    CHECK(packmat_field_check(f));

    // one corrupt member at a time, in copies of unranked contexts
    packmat_field m;
    packmat_field_init(&m, PACKMAT_M64, 70000, 0);
    const packmat_field good[2] = { g, m };
    for (int t = 0; t < 2; t++) {
        for (int c = 0; c < 11; c++) {
            snprintf(where, sizeof(where), "context %d, corruption %d", t, c);
            packmat_field h = good[t];
            switch (c) {
            case 0: h.kind = PACKMAT_NUM_KINDS; break;
            case 1: h.kind = 1 - h.kind; break;
            case 2: h.degree = 2; break;
            case 3: h.bits += 1; break;
            case 4: h.cpw += 1; break;
            case 5: h.n = 1; break;
            case 6: h.n += 1; break;
            case 7: h.ninv ^= 1; break;
            case 8: h.norm += 1; break;
            case 9: h.ranked = 2; break;
            case 10:    // a table needs n <= 2^16, checked before any read
                if (h.n <= 65536)
                    continue;
                h.ranked = 1;
                break;
            }
            CHECK(!packmat_field_check(&h));
        }
    }
}

/****************************************************************************
**
**  Layout and whole objects
*/

// Random permutation of 0..n-1 that fixes 0
static vector<uint16_t> random_rank(uint64_t n)
{
    vector<uint16_t> r(n);
    for (uint64_t x = 0; x < n; x++)
        r[x] = (uint16_t)x;
    for (uint64_t x = n - 1; x > 1; x--) {
        const uint64_t y = 1 + rnd() % x;
        const uint16_t t = r[x];
        r[x] = r[y];
        r[y] = t;
    }
    return r;
}


// Compare a and b under each rank table, the given one first
static void check_compare(packmat_field *  f,
                          Buf &            a,
                          Buf &            b,
                          const ref::Mat & ra,
                          const ref::Mat & rb)
{
    const packmat_mat va = a.view(f, ra.nrows, ra.ncols);
    const packmat_mat vb = b.view(f, rb.nrows, rb.ncols);
    uint16_t *        rank = packmat_field_rank(f);
    const int         want = ref::compare(ra, rb, rank);
    CHECK(packmat_compare(va, vb) == want);
    CHECK(packmat_compare(vb, va) == -want);
    CHECK(packmat_compare(va, va) == 0);
    CHECK(packmat_equal(va, vb) == (want == 0));
    if (!rank)
        return;
    const vector<uint16_t> saved(rank, rank + f->n);
    for (int t = 0; t < 2; t++) {
        const vector<uint16_t> r = random_rank(f->n);
        memcpy(rank, &r[0], f->n * sizeof(uint16_t));
        CHECK(packmat_field_check(f));
        const int w = ref::compare(ra, rb, rank);
        CHECK(packmat_compare(va, vb) == w);
        CHECK(packmat_compare(vb, va) == -w);
    }
    memcpy(rank, &saved[0], f->n * sizeof(uint16_t));
}

static void test_shape(packmat_field * f, uint32_t nrows, uint32_t ncols)
{
    snprintf(where, sizeof(where), "kind %u, n = %llu, %u x %u", f->kind,
             (unsigned long long)f->n, nrows, ncols);
    const uint64_t n = f->n;

    // layout against the packed reference
    const ref::Mat         A = random_mat(n, nrows, ncols);
    const vector<uint64_t> packed = ref::pack(A, f->bits);
    const size_t           words = packed.size();
    CHECK(packmat_matrix_words(f, nrows, ncols) == words);
    const uint32_t cpw = f->cpw;
    const uint32_t rpw = packmat_rows_per_word(f, ncols);
    const uint32_t stride = packmat_stride(f, ncols);
    if (ncols > 0 && 2 * ncols <= cpw)
        CHECK(rpw == cpw / ncols && rpw >= 2 && stride == 0);
    else
        CHECK(rpw == 1 && stride == (ncols + cpw - 1) / cpw);
    if (nrows == 1)
        CHECK(packmat_vector_words(f, ncols) == words);

    // zero, over garbage
    Buf               a(words);
    const packmat_mat va = a.view(f, nrows, ncols);
    packmat_zero(va);
    CHECK(a.same(vector<uint64_t>(words, 0)) && a.guards_ok());
    CHECK(packmat_is_zero(va));
    CHECK(packmat_check_invariants(va));

    // set from a second matrix, then overwrite with A in shuffled order
    const ref::Mat B = random_mat(n, nrows, ncols);
    fill(f, a, B);
    vector<size_t> order(A.e.size());
    for (size_t k = 0; k < order.size(); k++)
        order[k] = k;
    for (size_t k = order.size(); k > 1; k--) {
        const size_t t = rnd() % k, s = order[k - 1];
        order[k - 1] = order[t];
        order[t] = s;
    }
    for (size_t k = 0; k < order.size(); k++) {
        const uint32_t i = (uint32_t)(order[k] / ncols);
        const uint32_t j = (uint32_t)(order[k] % ncols);
        packmat_mat_set(va, i, j, A.at(i, j));
    }
    CHECK(a.same(packed) && a.guards_ok());
    CHECK(packmat_check_invariants(va));
    bool all_get = true;
    for (uint32_t i = 0; i < nrows; i++)
        for (uint32_t j = 0; j < ncols; j++)
            all_get &= packmat_mat_get(va, i, j) == A.at(i, j);
    CHECK(all_get);
    bool a_zero = true;
    for (size_t k = 0; k < A.e.size(); k++)
        a_zero &= A.e[k] == 0;
    CHECK(packmat_is_zero(va) == a_zero);
    CHECK(packmat_is_identity(va) == ref::is_identity(A));

    // vectors: a 1 x len view
    if (nrows == 1) {
        Buf               v(words);
        const packmat_mat vv = packmat_vec_view(f, v.data(), ncols);
        packmat_zero(vv);
        for (uint32_t j = 0; j < ncols; j++)
            packmat_vec_set(vv, j, B.at(0, j));
        for (uint32_t j = 0; j < ncols; j++)
            packmat_vec_set(vv, j, A.at(0, j));
        CHECK(v.same(packed) && v.guards_ok());
        bool vec_get = true;
        for (uint32_t j = 0; j < ncols; j++)
            vec_get &= packmat_vec_get(vv, j) == A.at(0, j);
        CHECK(vec_get);
    }

    // identity, over garbage
    Buf               id(words);
    const packmat_mat vid = id.view(f, nrows, ncols);
    packmat_identity(vid);
    CHECK(id.same(ref::pack(ref::identity(nrows, ncols), f->bits)));
    CHECK(id.guards_ok());
    CHECK(packmat_check_invariants(vid));
    CHECK(packmat_is_identity(vid) == (nrows == ncols));
    CHECK(packmat_is_zero(vid) == (nrows == 0 || ncols == 0));

    // identity with one entry changed
    if (nrows == ncols && nrows > 0) {
        const uint32_t i = (uint32_t)(rnd() % nrows);
        const uint32_t j = (uint32_t)(rnd() % ncols);
        const uint64_t x = packmat_mat_get(vid, i, j);
        packmat_mat_set(vid, i, j, x == 0 ? 1 : 0);
        CHECK(!packmat_is_identity(vid));
    }

    // copy, equal, hash
    Buf               c(words);
    const packmat_mat vc = c.view(f, nrows, ncols);
    packmat_copy(vc, va);
    CHECK(c.same(packed) && c.guards_ok());
    CHECK(packmat_equal(va, vc));
    CHECK(packmat_compare(va, vc) == 0);
    CHECK(packmat_hash(va) == packmat_hash(vc));

    // compare: first difference at a random entry, random entries after
    const size_t entries = A.e.size();
    for (int t = 0; t < 4 && entries > 0; t++) {
        ref::Mat     D = A;
        const size_t p = t == 0 ? 0 : t == 1 ? entries - 1 : rnd() % entries;
        D.e[p] = ref::add(n, A.e[p], 1 + rnd() % (n - 1));
        for (size_t k = p + 1; k < entries; k++)
            D.e[k] = rnd_residue(n);
        Buf d(words);
        fill(f, d, D);
        CHECK(d.same(ref::pack(D, f->bits)));
        check_compare(f, a, d, A, D);
        CHECK(packmat_hash(va) != packmat_hash(d.view(f, nrows, ncols)));
    }

    // invariant violations: a stray bit in unused space; a cell >= n
    ref::Mat full(nrows, ncols);
    for (size_t k = 0; k < full.e.size(); k++)
        full.e[k] = (f->bits == 64) ? ~0ull : (1ull << f->bits) - 1;
    const vector<uint64_t> used = ref::pack(full, f->bits);
    for (size_t k = 0; k < words; k++) {
        const uint64_t spare = ~used[k];
        if (spare == 0)
            continue;
        CHECK(spare >> 63);    // unused bits are the top ones
        const uint64_t stray[2] = { spare & (0 - spare), 1ull << 63 };
        for (int t = 0; t < 2; t++) {
            Buf               e(words);
            const packmat_mat ve = e.view(f, nrows, ncols);
            packmat_copy(ve, va);
            e.data()[k] |= stray[t];
            CHECK(!packmat_check_invariants(ve));
        }
    }
    if (f->bits == 64 && words > 0) {
        Buf               e(words);
        const packmat_mat ve = e.view(f, nrows, ncols);
        packmat_copy(ve, va);
        e.data()[rnd() % words] = n + (rnd() % (~0ull - n + 1));
        CHECK(!packmat_check_invariants(ve));
    }
}

/****************************************************************************
**
**  Dimensions near 2^32: word counts must not wrap
*/

static void test_huge()
{
    snprintf(where, sizeof(where), "huge dimensions");
    packmat_field g;
    packmat_field_init(&g, PACKMAT_GF2, 2, 0);
    Field           F(PACKMAT_M64, 7, 0);
    const uint32_t  big[] = { 0xffffffbf, 0xffffffc0, 0xffffffc1, 0xfffffffe,
                              0xffffffff };
    const uint64_t  maxrows = 0xffffffff;
    for (size_t k = 0; k < sizeof(big) / sizeof(big[0]); k++) {
        const uint64_t len = big[k];
        CHECK(packmat_stride(&g, big[k]) == (len + 63) / 64);
        CHECK(packmat_vector_words(&g, big[k]) == (len + 63) / 64);
        CHECK(packmat_matrix_words(&g, 0xffffffff, big[k]) ==
              maxrows * ((len + 63) / 64));
        CHECK(packmat_stride(F.f, big[k]) == len);
        CHECK(packmat_matrix_words(F.f, 0xffffffff, big[k]) == maxrows * len);
    }
    CHECK(packmat_matrix_words(&g, 0xffffffff, 1) == (maxrows + 63) / 64);
}

/****************************************************************************
**
**  Orders and hashes with known answers
*/

// GAP's order of GF(p): 0 first, then z^0, z^1, ... for the primitive
// root z, i.e. rank[z^k] = k + 1
static void log_rank(uint16_t * rank, uint64_t p, uint64_t z)
{
    rank[0] = 0;
    uint64_t x = 1;
    for (uint64_t k = 0; k + 1 < p; k++) {
        rank[x] = (uint16_t)(k + 1);
        x = x * z % p;
    }
}

static void test_orders()
{
    snprintf(where, sizeof(where), "GF(7) order");
    Field           F(PACKMAT_M64, 7, 1);
    packmat_field * f = F.f;
    log_rank(packmat_field_rank(f), 7, 3);
    CHECK(packmat_field_check(f));

    // GAP sorts GF(7) as 0, 1, 3, 2, 6, 4, 5
    const uint64_t sorted[] = { 0, 1, 3, 2, 6, 4, 5 };
    for (int x = 0; x < 7; x++)
        for (int y = 0; y < 7; y++) {
            uint64_t  a = sorted[x], b = sorted[y];
            const int want = x < y ? -1 : x > y ? 1 : 0;
            CHECK(packmat_compare(packmat_vec_view(f, &a, 1),
                                  packmat_vec_view(f, &b, 1)) == want);
        }

    snprintf(where, sizeof(where), "GF(65521) order");
    Field           G(PACKMAT_M64, 65521, 1);
    packmat_field * g = G.f;
    log_rank(packmat_field_rank(g), 65521, 17);    // 17 is primitive
    CHECK(packmat_field_check(g));
    // 17 = z^1 sorts before 2 = z^41608; residue order says otherwise
    uint64_t a[2] = { 5, 2 }, b[2] = { 5, 17 };
    CHECK(packmat_compare(packmat_vec_view(g, a, 2),
                          packmat_vec_view(g, b, 2)) == 1);
    Field P(PACKMAT_M64, 65521, 0);
    CHECK(packmat_compare(packmat_vec_view(P.f, a, 2),
                          packmat_vec_view(P.f, b, 2)) == -1);

    // Vectors of different lengths, as packmat.h says: compare views of
    // the shorter length, then break ties by length. Over GF(2) both share
    // a word, so cell 2 of the longer one takes part.
    snprintf(where, sizeof(where), "GF(2) prefix order");
    packmat_field h;
    packmat_field_init(&h, PACKMAT_GF2, 2, 0);
    // u = [0, 1], w = [0, 1, 1], x = [0, 1, 0]
    uint64_t          u = 0x2, w = 0x6, x = 0x2;
    const packmat_mat vu = packmat_vec_view(&h, &u, 2);
    const packmat_mat vw = packmat_vec_view(&h, &w, 2);
    const packmat_mat vx = packmat_vec_view(&h, &x, 2);
    CHECK(packmat_compare(vu, vw) == -1);
    CHECK(packmat_compare(vw, vu) == 1);
    CHECK(packmat_compare(vu, vx) == 0);    // tie: shorter first
}

// Known answers for packmat_hash, computed from the formula in matrix.cc
// by an independent script; any change of layout or hash shows here,
// as does any difference between platforms.
static void test_hash_values()
{
    snprintf(where, sizeof(where), "hash values");
    packmat_field g;
    packmat_field_init(&g, PACKMAT_GF2, 2, 0);
    Field           F(PACKMAT_M64, (1ull << 61) - 1, 0);
    packmat_field * f = F.f;

    uint64_t none = 0;
    CHECK(packmat_hash(packmat_mat_view(&g, &none, 0, 0)) ==
          0x9ca066f1a4ab2eeaull);
    CHECK(packmat_hash(packmat_mat_view(&g, &none, 3, 0)) ==
          0xbff027065cb11f97ull);
    CHECK(packmat_hash(packmat_mat_view(&g, &none, 0, 3)) ==
          0xb47229bfc36a0ee2ull);

    // 8 x 8 identity over GF(2): 8 rows in one word, (i, i) at bit 9i
    uint64_t          id8;
    const packmat_mat v8 = packmat_mat_view(&g, &id8, 8, 8);
    packmat_identity(v8);
    CHECK(id8 == 0x8040201008040201ull);
    CHECK(packmat_hash(v8) == 0x3eb1d94890a28ff2ull);

    // 20 x 20 over GF(2), entry (i, j) = i(j + 1) mod 2: 3 rows per word
    uint64_t          m20[7];
    const packmat_mat v20 = packmat_mat_view(&g, m20, 20, 20);
    packmat_zero(v20);
    for (uint32_t i = 0; i < 20; i++)
        for (uint32_t j = 0; j < 20; j++)
            packmat_mat_set(v20, i, j, (i * j + i) % 2);
    CHECK(packmat_matrix_words(&g, 20, 20) == 7);
    CHECK(m20[0] == 0x5555500000ull && m20[1] == 0x0555550000055555ull);
    CHECK(packmat_hash(v20) == 0x6c7df6836a68dfe3ull);

    // 3 x 3 over Z/(2^61 - 1), entries 1..9
    uint64_t          m3[9];
    const packmat_mat v3 = packmat_mat_view(f, m3, 3, 3);
    packmat_zero(v3);
    for (uint32_t i = 0; i < 3; i++)
        for (uint32_t j = 0; j < 3; j++)
            packmat_mat_set(v3, i, j, 3 * i + j + 1);
    CHECK(m3[0] == 1 && m3[8] == 9);
    CHECK(packmat_hash(v3) == 0xc76841a332add821ull);
}

/****************************************************************************
**
**  Driver
*/

int main()
{
    test_contexts();

    const uint64_t * moduli = MODULI;
    const size_t     nmod = NUM_MODULI;
    for (size_t k = 0; k < nmod; k++)
        test_mod(moduli[k]);

    // GF2: cpw = 64; rows per word change at ncols 21/22 and 32/33
    const uint32_t gf2_rows[] = { 0, 1, 2, 3, 4, 63, 64, 65, 129 };
    const uint32_t gf2_cols[] = { 0,  1,  2,  3,  21,  22,  31, 32,
                                  33, 63, 64, 65, 127, 128, 129 };
    {
        Field G(PACKMAT_GF2, 2, 0), H(PACKMAT_GF2, 2, 1);
        for (size_t r = 0; r < sizeof(gf2_rows) / sizeof(gf2_rows[0]); r++)
            for (size_t c = 0; c < sizeof(gf2_cols) / sizeof(gf2_cols[0]);
                 c++) {
                test_shape(G.f, gf2_rows[r], gf2_cols[c]);
                test_shape(H.f, gf2_rows[r], gf2_cols[c]);
            }
    }

    // M64: cpw = 1
    const uint32_t m64_dims[] = { 0, 1, 2, 3, 5 };
    const size_t   ndims = sizeof(m64_dims) / sizeof(m64_dims[0]);
    for (size_t k = 0; k < nmod; k++) {
        const int ranked = moduli[k] <= 65536;
        Field     F(PACKMAT_M64, moduli[k], ranked);
        for (size_t r = 0; r < ndims; r++)
            for (size_t c = 0; c < ndims; c++)
                test_shape(F.f, m64_dims[r], m64_dims[c]);
    }

    test_huge();
    test_orders();
    test_hash_values();

    printf("packmat: %lu checks, %lu failures\n", checks, failures);
    return failures ? 1 : 0;
}
