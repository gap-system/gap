/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "sha256.h"

#include "bool.h"
#include "error.h"
#include "integer.h"
#include "modules.h"
#include "objects.h"
#include "plist.h"
#include "stringobj.h"

#include "config.h"

#include <string.h>

static Obj GAP_SHA256_State_Type;

// Implements the SHA256 hash function as per the description in
// https://web.archive.org/web/20130526224224/http://csrc.nist.gov/groups/STM/cavp/documents/shs/sha256-384-512.pdf
//


// For the moment we assume the input is a string, we should probably have a
// list of bytes, or words or something

static inline UInt4 RotateRight(UInt4 x, const UInt4 n)
{
    return (x >> n) | (x << (32 - n));
}

static inline UInt4 Ch(UInt4 x, UInt4 y, UInt4 z)
{
    return (x & y) ^ (~x & z);
}

static inline UInt4 Maj(UInt4 x, UInt4 y, UInt4 z)
{
    return (x & y) ^ (x & z) ^ (y & z);
}

static inline UInt4 Sigma0(UInt4 x)
{
    return RotateRight(x, 2) ^ RotateRight(x, 13) ^ RotateRight(x, 22);
}

static inline UInt4 Sigma1(UInt4 x)
{
    return RotateRight(x, 6) ^ RotateRight(x, 11) ^ RotateRight(x, 25);
}

static inline UInt4 sigma0(UInt4 x)
{
    return RotateRight(x, 7) ^ RotateRight(x, 18) ^ (x >> 3);
}

static inline UInt4 sigma1(UInt4 x)
{
    return RotateRight(x, 17) ^ RotateRight(x, 19) ^ (x >> 10);
}

static const UInt4 k[] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

static const UInt4 rinit[] = {
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
};

#ifdef WORDS_BIGENDIAN
#define be32decode(dst, src, len) memcpy(dst, src, len)
#define be32encode(dst, src, len) memcpy(dst, src, len)
#define store64be(dst, x) *dst = x
#else
static void be32decode(UInt4 * dst, const UInt1 * src, UInt len)
{
    UInt i;
    for (i = 0; i < (len >> 2); i++) {
        dst[i] = (src[i * 4] << 24) | (src[i * 4 + 1] << 16) |
                 (src[i * 4 + 2] << 8) | (src[i * 4 + 3]);
    }
}

static void be32encode(UInt1 * dst, const UInt4 * src, UInt len)
{
    UInt i;
    for (i = 0; i < (len >> 2); i++) {
        dst[4 * i + 0] = (src[i] & 0xff000000) >> 24;
        dst[4 * i + 1] = (src[i] & 0xff0000) >> 16;
        dst[4 * i + 2] = (src[i] & 0xff00) >> 8;
        dst[4 * i + 3] = (src[i] & 0xff);
    }
}

static void store64be(UInt8 * dst, UInt8 x)
{
    *dst = (((x >> 56) | ((x >> 40) & 0xff00) | ((x >> 24) & 0xff0000) |
             ((x >> 8) & 0xff000000) | ((x << 8) & ((UInt8)0xff << 32)) |
             ((x << 24) & ((UInt8)0xff << 40)) |
             ((x << 40) & ((UInt8)0xff << 48)) | ((x << 56))));
}
#endif

typedef struct sha256_state_t {
    UInt4 r[8];       // Current hash value register
    UInt  count;      // Nr of bits already hashed
    UInt1 buf[64];    // One chunk, 512 bits
} sha256_state_t;

static int sha256_init(sha256_state_t * state)
{
    memcpy(state->r, rinit, sizeof(rinit));
    state->count = 0UL;
    memset(state->buf, 0, 64);

    return 0;
}

static void sha256_transform(UInt4       state[8],
                             const UInt1 block[64],
                             UInt4       w[64],
                             UInt4       r[8])
{
    UInt  i;
    UInt4 temp1, temp2;

    memcpy(r, state, 32);
    be32decode(w, block, 64);
    for (i = 16; i < 64; i++) {
        w[i] = sigma1(w[i - 2]) + w[i - 7] + sigma0(w[i - 15]) + w[i - 16];
    }

    // A block is 512bit = 64bytes
    for (i = 0; i < 64; i++) {
        temp1 = r[7] + Sigma1(r[4]) + Ch(r[4], r[5], r[6]) + k[i] + w[i];
        temp2 = Sigma0(r[0]) + Maj(r[0], r[1], r[2]);
        r[7] = r[6];
        r[6] = r[5];
        r[5] = r[4];
        r[4] = r[3] + temp1;
        r[3] = r[2];
        r[2] = r[1];
        r[1] = r[0];
        r[0] = temp1 + temp2;
    }
    for (i = 0; i < 8; i++) {
        state[i] += r[i];
    }
}

static int sha256_update(sha256_state_t * state, const UChar * buf, UInt8 len)
{
    UInt4 i, rem;
    UInt4 w[64];
    UInt4 r[8];

    // If there is buffered stuff in state, fill block
    rem = (state->count >> 3) & 0x3f;
    // Number of bits already hashed. Needed for continuation, and for
    // padding
    state->count += len << 3;

    // Not enough to hash full block, just buffer
    if (len < 64 - rem) {
        for (i = 0; i < len; i++) {
            state->buf[rem + i] = buf[i];
        }
        return 0;
    }
    for (i = 0; i < 64 - rem; i++) {
        state->buf[rem + i] = buf[i];
    }
    // Filled a block, do the SHA256 transform
    sha256_transform(state->r, state->buf, w, r);
    buf += (UInt4)64 - rem;
    len -= (UInt4)64 - rem;

    // Hash full blocks
    while (len >= 64) {
        sha256_transform(state->r, (const UInt1 *)buf, w, r);
        buf += 64;
        len -= 64;
    }

    // Store remainder in buffer
    for (i = 0; i < len; i++) {
        state->buf[i] = buf[i];
    }
    memset(w, 0x0, sizeof(w));
    memset(r, 0x0, sizeof(r));

    return 0;
}

static int sha256_final(sha256_state_t * state)
{
    UInt8 rem;
    UInt8 i;
    UInt4 w[64];
    UInt4 r[8];

    rem = (state->count >> 3) & 0x3f;
    state->buf[rem] = 0x80;
    if (rem < 56) {
        for (i = 1; i < 56 - rem; i++) {
            state->buf[rem + i] = 0x00;
        }
    }
    else {
        for (i = 1; i < (UInt4)64 - rem; i++) {
            state->buf[rem + i] = 0x00;
        }
        sha256_transform(state->r, state->buf, w, r);
        memset(state->buf, 0, 56);
    }
    store64be((UInt8 *)(&state->buf[56]), state->count);

    sha256_transform(state->r, state->buf, w, r);

    return 0;
}

Obj FuncGAP_SHA256_INIT(Obj self)
{
    Obj              result;
    sha256_state_t * sptr;

    result = NewBag(T_DATOBJ, sizeof(UInt4) + sizeof(sha256_state_t));
    SET_TYPE_OBJ(result, GAP_SHA256_State_Type);

    sptr = (sha256_state_t *)(&ADDR_OBJ(result)[1]);
    sha256_init(sptr);

    return result;
}

Obj FuncGAP_SHA256_UPDATE(Obj self, Obj state, Obj bytes)
{
    sha256_state_t * sptr;

    RequireArgumentCondition(SELF_NAME, state,
                             IS_DATOBJ(state) &&
                                 TYPE_OBJ(state) == GAP_SHA256_State_Type,
                             "must be a SHA256 state");
    RequireStringRep(SELF_NAME, bytes);

    sptr = (sha256_state_t *)(&ADDR_OBJ(state)[1]);
    sha256_update(sptr, CHARS_STRING(bytes), GET_LEN_STRING(bytes));
    CHANGED_BAG(state);

    return 0;
}

Obj FuncGAP_SHA256_FINAL(Obj self, Obj state)
{
    Obj              result;
    sha256_state_t * sptr;
    int              i;

    RequireArgumentCondition(SELF_NAME, state,
                             IS_DATOBJ(state) &&
                                 TYPE_OBJ(state) == GAP_SHA256_State_Type,
                             "must be a SHA256 state");

    result = NEW_PLIST(T_PLIST, 8);
    SET_LEN_PLIST(result, 8);

    sptr = (sha256_state_t *)(&ADDR_OBJ(state)[1]);
    sha256_final(sptr);
    CHANGED_BAG(state);

    for (i = 0; i < 8; i++) {
        SET_ELM_PLIST(result, i + 1, ObjInt_UInt(sptr->r[i]));
        CHANGED_BAG(result);
    }
    return result;
}

Obj FuncGAP_SHA256_HMAC(Obj self, Obj key, Obj text)
{
    UInt           i, klen;
    UInt1          k_ipad[64], k_opad[64];
    UInt1          digest[32];
    sha256_state_t st;
    Obj            result;

    RequireStringRep(SELF_NAME, key);
    RequireStringRep(SELF_NAME, text);

    memset(k_ipad, 0x36, sizeof(k_ipad));
    memset(k_opad, 0x5c, sizeof(k_opad));

    klen = GET_LEN_STRING(key);
    if (GET_LEN_STRING(key) > 64) {
        sha256_init(&st);
        sha256_update(&st, CHARS_STRING(key), klen);
        sha256_final(&st);

        be32encode(digest, st.r, sizeof(digest));
        klen = 32;

        for (i = 0; i < klen; i++) {
            k_ipad[i] ^= digest[i];
            k_opad[i] ^= digest[i];
        }
    }
    else {
        for (i = 0; i < klen; i++) {
            k_ipad[i] ^= CHARS_STRING(key)[i];
            k_opad[i] ^= CHARS_STRING(key)[i];
        }
    }

    sha256_init(&st);
    sha256_update(&st, k_ipad, 64);
    sha256_update(&st, CHARS_STRING(text), GET_LEN_STRING(text));
    sha256_final(&st);

    be32encode(digest, st.r, sizeof(digest));
    sha256_init(&st);
    sha256_update(&st, k_opad, 64);
    sha256_update(&st, digest, 32);
    sha256_final(&st);

    result = NEW_PLIST(T_PLIST, 8);
    SET_LEN_PLIST(result, 8);
    for (i = 0; i < 8; i++) {
        SET_ELM_PLIST(result, i + 1, ObjInt_UInt(st.r[i]));
        CHANGED_BAG(result);
    }
    return result;
}

// Table of functions to export
static StructGVarFunc GVarFuncs[] = {
    GVAR_FUNC_0ARGS(GAP_SHA256_INIT),
    GVAR_FUNC_2ARGS(GAP_SHA256_UPDATE, state, bytes),
    GVAR_FUNC_1ARGS(GAP_SHA256_FINAL, state),
    GVAR_FUNC_2ARGS(GAP_SHA256_HMAC, key, text),

    { 0 }    // Finish with an empty entry
};

/****************************************************************************
**
*F  InitKernel( <module> ) . . . . . . .  initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    ImportGVarFromLibrary("GAP_SHA256_State_Type", &GAP_SHA256_State_Type);

    // init filters and functions
    InitHdlrFuncsFromTable(GVarFuncs);

    // return success
    return 0;
}

/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    // init filters and functions
    InitGVarFuncsFromTable(GVarFuncs);

    return 0;
}

/****************************************************************************
**
*F  InitSHA256() . . . . . . . . . . . . . . . . . .  table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "crypting",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitSHA256(void)
{
    return &module;
}
