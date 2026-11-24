/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Internal to the packed matrix core: word helpers and inline residue
**  arithmetic mod n < 2^64.
**
**  PACKMAT_PORTABLE selects the portable code paths: 64x64->128 products
**  from 32-bit halves and bit scans without compiler builtins. They are
**  used anyway where unsigned __int128 or the builtins are missing.
*/

#ifndef PACKMAT_ARITH_H
#define PACKMAT_ARITH_H

#include "packmat.h"

#if defined(PACKMAT_DEBUG) || defined(GAP_KERNEL_DEBUG)
#include <assert.h>
#define PACKMAT_ASSERT(x) assert(x)
#else
#define PACKMAT_ASSERT(x) ((void)sizeof(x))    // uses x, no evaluation
#endif

#if !defined(PACKMAT_PORTABLE) && defined(__SIZEOF_INT128__)
#define PACKMAT_HAVE_INT128
#endif

#if !defined(PACKMAT_PORTABLE) && defined(__GNUC__)
#define PACKMAT_HAVE_BUILTINS
#endif

namespace packmat {

/****************************************************************************
**
**  Words
*/

// Number of trailing zero bits; x != 0.
inline unsigned ctz64(uint64_t x)
{
    PACKMAT_ASSERT(x != 0);
#ifdef PACKMAT_HAVE_BUILTINS
    return __builtin_ctzll(x);
#else
    unsigned n = 0;
    if ((x & 0xffffffff) == 0) {
        n += 32;
        x >>= 32;
    }
    if ((x & 0xffff) == 0) {
        n += 16;
        x >>= 16;
    }
    if ((x & 0xff) == 0) {
        n += 8;
        x >>= 8;
    }
    if ((x & 0xf) == 0) {
        n += 4;
        x >>= 4;
    }
    if ((x & 0x3) == 0) {
        n += 2;
        x >>= 2;
    }
    return n + ((x & 1) ^ 1);
#endif
}

// Number of leading zero bits; x != 0.
inline unsigned clz64(uint64_t x)
{
    PACKMAT_ASSERT(x != 0);
#ifdef PACKMAT_HAVE_BUILTINS
    return __builtin_clzll(x);
#else
    unsigned n = 0;
    if ((x >> 32) == 0) {
        n += 32;
        x <<= 32;
    }
    if ((x >> 48) == 0) {
        n += 16;
        x <<= 16;
    }
    if ((x >> 56) == 0) {
        n += 8;
        x <<= 8;
    }
    if ((x >> 60) == 0) {
        n += 4;
        x <<= 4;
    }
    if ((x >> 62) == 0) {
        n += 2;
        x <<= 2;
    }
    return n + (unsigned)((x >> 63) ^ 1);
#endif
}

// Number of set bits
inline unsigned popcount64(uint64_t x)
{
#ifdef PACKMAT_HAVE_BUILTINS
    return __builtin_popcountll(x);
#else
    x -= (x >> 1) & 0x5555555555555555ull;
    x = (x & 0x3333333333333333ull) + ((x >> 2) & 0x3333333333333333ull);
    x = (x + (x >> 4)) & 0x0f0f0f0f0f0f0f0full;
    return (unsigned)((x * 0x0101010101010101ull) >> 56);
#endif
}

// (*hi, *lo) = a * b
inline void mul_wide(uint64_t a, uint64_t b, uint64_t * hi, uint64_t * lo)
{
#ifdef PACKMAT_HAVE_INT128
    __extension__ typedef unsigned __int128 u128;
    u128 p = (u128)a * b;
    *hi = (uint64_t)(p >> 64);
    *lo = (uint64_t)p;
#else
    // 32x32->64 products of the halves, so 32-bit targets use single muls
    const uint32_t a0 = (uint32_t)a, a1 = (uint32_t)(a >> 32);
    const uint32_t b0 = (uint32_t)b, b1 = (uint32_t)(b >> 32);
    const uint64_t p00 = (uint64_t)a0 * b0;
    const uint64_t p01 = (uint64_t)a0 * b1;
    const uint64_t p10 = (uint64_t)a1 * b0;
    const uint64_t p11 = (uint64_t)a1 * b1;
    const uint64_t mid = (p00 >> 32) + (uint32_t)p01 + (uint32_t)p10;
    *lo = (mid << 32) | (uint32_t)p00;
    *hi = p11 + (p01 >> 32) + (p10 >> 32) + (mid >> 32);
#endif
}

inline uint64_t mulhi(uint64_t a, uint64_t b)
{
    uint64_t hi, lo;
    mul_wide(a, b, &hi, &lo);
    return hi;
}

/****************************************************************************
**
**  Division by a normalised invariant d (top bit set), after N. Moeller
**  and T. Granlund, "Improved division by invariant integers", IEEE
**  Trans. Computers 60 (2011), Algorithm 4.
*/

// v = floor((2^128 - 1) / d) - 2^64, i.e. (~d * 2^64 + ~0) / d. Bitwise
// long division: it runs once per context.
inline uint64_t preinvert(uint64_t d)
{
    PACKMAT_ASSERT(d >> 63);
    uint64_t r = ~d, q = 0;
    for (int i = 0; i < 64; i++) {
        const uint64_t carry = r >> 63;
        r = (r << 1) | 1;
        q <<= 1;
        if (carry || r >= d) {
            r -= d;
            q |= 1;
        }
    }
    return q;
}

// Quotient of (u1 * 2^64 + u0) / d, remainder in *r; needs u1 < d.
inline uint64_t
divrem_preinv(uint64_t u1, uint64_t u0, uint64_t d, uint64_t v, uint64_t * r)
{
    PACKMAT_ASSERT(u1 < d);
    uint64_t q1, q0;
    mul_wide(v, u1, &q1, &q0);
    q0 += u0;
    q1 += u1 + (q0 < u0);
    q1 += 1;
    uint64_t rr = u0 - q1 * d;
    if (rr > q0) {
        q1 -= 1;
        rr += d;
    }
    if (rr >= d) {
        q1 += 1;
        rr -= d;
    }
    *r = rr;
    return q1;
}

/****************************************************************************
**
**  Residues mod f.n. Arguments are below n unless stated otherwise.
*/

// (hi * 2^64 + lo) mod n; needs hi < n.
inline uint64_t mod_reduce2(const packmat_field & f, uint64_t hi, uint64_t lo)
{
    PACKMAT_ASSERT(hi < f.n);
    const unsigned s = f.norm;
    const uint64_t u1 = s ? (hi << s) | (lo >> (64 - s)) : hi;
    uint64_t       r;
    divrem_preinv(u1, lo << s, f.n << s, f.ninv, &r);
    return r >> s;
}

inline uint64_t mod_reduce(const packmat_field & f, uint64_t a)
{
    return mod_reduce2(f, 0, a);
}

// The comparison against n - b avoids overflow for n close to 2^64.
inline uint64_t mod_add(const packmat_field & f, uint64_t a, uint64_t b)
{
    PACKMAT_ASSERT(a < f.n && b < f.n);
    const uint64_t t = f.n - b;
    return a >= t ? a - t : a + b;
}

inline uint64_t mod_sub(const packmat_field & f, uint64_t a, uint64_t b)
{
    PACKMAT_ASSERT(a < f.n && b < f.n);
    return a >= b ? a - b : a - b + f.n;
}

inline uint64_t mod_neg(const packmat_field & f, uint64_t a)
{
    PACKMAT_ASSERT(a < f.n);
    return a == 0 ? 0 : f.n - a;
}

inline uint64_t mod_mul(const packmat_field & f, uint64_t a, uint64_t b)
{
    PACKMAT_ASSERT(a < f.n && b < f.n);
    uint64_t hi, lo;
    mul_wide(a, b, &hi, &lo);
    return mod_reduce2(f, hi, lo);
}

// floor(s * 2^64 / n); needs n < 2^63, so that mod_mul_shoup stays in
// 64 bits.
inline uint64_t mod_shoup(const packmat_field & f, uint64_t s)
{
    PACKMAT_ASSERT(f.n >> 63 == 0 && s < f.n);
    uint64_t r;
    return divrem_preinv(s << f.norm, 0, f.n << f.norm, f.ninv, &r);
}

// a * s mod n for any a; sp = mod_shoup(f, s). The quotient estimate
// mulhi(a, sp) is at most one too small, so r < 2n before the correction.
inline uint64_t
mod_mul_shoup(const packmat_field & f, uint64_t a, uint64_t s, uint64_t sp)
{
    PACKMAT_ASSERT(f.n >> 63 == 0 && s < f.n);
    const uint64_t q = mulhi(a, sp);
    const uint64_t r = a * s - q * f.n;
    return r >= f.n ? r - f.n : r;
}

// Sum of products of residues, reduced once at the end: products below
// 2^128 go into lo + 2^64 hi, carries into top. Exact for up to 2^64
// products.
struct DotAcc {
    uint64_t lo, hi, top;

    DotAcc() : lo(0), hi(0), top(0)
    {
    }

    // The high word of a product is at most 2^64 - 2, so ph + carry fits
    void add(uint64_t a, uint64_t b)
    {
        uint64_t ph, pl;
        mul_wide(a, b, &ph, &pl);
        lo += pl;
        ph += lo < pl;
        hi += ph;
        top += hi < ph;
    }

    uint64_t reduce(const packmat_field & f) const
    {
        const uint64_t t = mod_reduce(f, top);
        return mod_reduce2(f, mod_reduce2(f, t, hi), lo);
    }
};

// Extended Euclid on (n, a). Only magnitudes of the Bezout coefficients
// are kept; their signs alternate, and they stay at most n.
inline int mod_inv(const packmat_field & f, uint64_t a, uint64_t * inv)
{
    PACKMAT_ASSERT(a < f.n);
    uint64_t r0 = f.n, r1 = a;
    uint64_t t0 = 0, t1 = 1;
    unsigned steps = 0;
    while (r1 != 0) {
        const uint64_t q = r0 / r1;
        const uint64_t r2 = r0 - q * r1;
        const uint64_t t2 = t0 + q * t1;
        r0 = r1;
        r1 = r2;
        t0 = t1;
        t1 = t2;
        steps++;
    }
    // r0 = gcd(n, a) = (-1)^(steps+1) * t0 * a mod n
    if (r0 != 1)
        return PACKMAT_NOT_UNIT;
    *inv = (steps & 1) ? t0 : f.n - t0;
    return PACKMAT_OK;
}

}    // namespace packmat

#endif    // PACKMAT_ARITH_H
