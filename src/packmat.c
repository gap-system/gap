/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  GAP binding of the packed matrix core (src/packmat/): the kernel side of
**  IsPackedMatrixRep and IsPackedVectorRep (lib/matobjpacked.gi). Indices,
**  dimensions, base domains and mutability are checked here, since the
**  core trusts its arguments.
**
**  A packed matrix or vector is a T_DATOBJ bag:
**
**      offset  0   type
**      offset  8   nrows, ncols as uint32_t; a vector stores len, 0
**      offset 16   cells: packmat_matrix_words(f, nrows, ncols) or
**                  packmat_vector_words(f, len) words
**
**  On 32-bit, 4 bytes of padding follow the type, so that the offsets, and
**  the cells' 8-byte alignment relative to the bag, are the same.
**
**  The four types of a base domain (mutable and immutable, matrix and
**  vector) share their data, the immutable plain list
**
**      [ base domain, field bag, One( base domain ), Zero( base domain ) ]
**
**  so that two objects have the same base domain object iff their types
**  have identical data. The field bag is a kernel buffer holding the core's
**  packmat_field at offset 8, then, if the field is ranked, the inverse of
**  its rank table.
**
**  Entries are internal FFEs if One( base domain ) is one; then the rank
**  table maps residues to FFE values (VAL_FFE), and the inverse table maps
**  FFE values back, so that GAP's order of FFEs is the core's rank order.
**  GF(2) needs no tables. Otherwise entries are ZmodnZObj: positional
**  objects [ residue ] with the type of One( base domain ).
**
**  Every pointer into a bag, including the packmat_field, is fetched again
**  after anything that may allocate or run GAP code.
*/

#include "packmat.h"

#include "bool.h"
#include "calls.h"
#include "error.h"
#include "finfield.h"
#include "integer.h"
#include "lists.h"
#include "modules.h"
#include "objects.h"
#include "opers.h"
#include "plist.h"
#include "vec8bit.h"
#include "vecgf2.h"

#include "packmat/packmat.h"

#include <string.h>


// Byte offsets in a packed object and in a field bag
enum {
    DIMS_OFFSET = 8,
    CELLS_OFFSET = 16,
    FIELD_OFFSET = 8,
};

// Positions in the type data
enum {
    TDATA_BASEDOMAIN = 1,
    TDATA_FIELD = 2,
    TDATA_ONE = 3,
    TDATA_ZERO = 4,
};

// Dimensions are uint32_t in the core
static const UInt MAX_DIM = 0xFFFFFFFFu;

static Obj IsPackedMatrixRepFilt;
static Obj IsPackedVectorRepFilt;

// PACKMAT_EntryResidue( R, x ): residue of x in R, or fail
static Obj PackmatEntryResidueFunc;


/****************************************************************************
**
*F * * * * * * * * * * * * * * object access * * * * * * * * * * * * * * * *
*/

static inline const uint32_t * CONST_DIMS(Obj obj)
{
    return (const uint32_t *)((const char *)CONST_ADDR_OBJ(obj) +
                              DIMS_OFFSET);
}

static inline uint32_t * DIMS(Obj obj)
{
    return (uint32_t *)((char *)ADDR_OBJ(obj) + DIMS_OFFSET);
}

static inline uint64_t * CELLS(Obj obj)
{
    return (uint64_t *)((char *)ADDR_OBJ(obj) + CELLS_OFFSET);
}

static inline Obj TDATA(Obj obj)
{
    return DATA_TYPE(TYPE_DATOBJ(obj));
}

static inline packmat_field * FIELD_OF_BAG(Obj bag)
{
    return (packmat_field *)((char *)ADDR_OBJ(bag) + FIELD_OFFSET);
}

static inline packmat_field * FIELD(Obj tdata)
{
    return FIELD_OF_BAG(ELM_PLIST(tdata, TDATA_FIELD));
}

// Inverse of the rank table: FFE value -> residue
static inline uint16_t * INVERSE(packmat_field * f)
{
    return (uint16_t *)((char *)f + packmat_field_size(f->kind, f->n, 1));
}

static inline packmat_mat MAT_VIEW(Obj M)
{
    const uint32_t * d = CONST_DIMS(M);
    return packmat_mat_view(FIELD(TDATA(M)), CELLS(M), d[0], d[1]);
}

static inline packmat_mat VEC_VIEW(Obj v)
{
    return packmat_vec_view(FIELD(TDATA(v)), CELLS(v), CONST_DIMS(v)[0]);
}

static inline BOOL IS_PACKED_MAT(Obj obj)
{
    return TNUM_OBJ(obj) == T_DATOBJ &&
           DoFilter(IsPackedMatrixRepFilt, obj) == True;
}

static inline BOOL IS_PACKED_VEC(Obj obj)
{
    return TNUM_OBJ(obj) == T_DATOBJ &&
           DoFilter(IsPackedVectorRepFilt, obj) == True;
}

static void RequirePackedMat(const char * funcname, Obj M)
{
    if (!IS_PACKED_MAT(M))
        RequireArgumentEx(funcname, M, "<M>", "must be a packed matrix");
}

static void RequirePackedVec(const char * funcname, Obj v)
{
    if (!IS_PACKED_VEC(v))
        RequireArgumentEx(funcname, v, "<v>", "must be a packed vector");
}

// View of a packed matrix or vector
static packmat_mat RequirePackedView(const char * funcname, Obj obj)
{
    if (IS_PACKED_MAT(obj))
        return MAT_VIEW(obj);
    if (IS_PACKED_VEC(obj))
        return VEC_VIEW(obj);
    RequireArgumentEx(funcname, obj, "<obj>",
                      "must be a packed matrix or vector");
}

// Type data of a packed type whose objects lie in <filt>
static Obj RequirePackedType(const char * funcname, Obj type, Obj filt)
{
    if (TNUM_OBJ(type) != T_POSOBJ ||
        SIZE_OBJ(type) <= POS_DATA_TYPE * sizeof(Obj) ||
        !IS_SUBSET_FLAGS(FLAGS_TYPE(type), FLAGS_FILT(filt)))
        RequireArgumentEx(funcname, type, "<type>", "must be a packed type");
    return DATA_TYPE(type);
}

// A dimension: an integer in [0..2^32-1]
static UInt GetDim(const char * funcname, Obj n, const char * argname)
{
    if (!IS_NONNEG_INTOBJ(n) || (UInt)INT_INTOBJ(n) > MAX_DIM)
        RequireArgumentEx(funcname, n, argname,
                          "must be an integer in [0..2^32-1]");
    return INT_INTOBJ(n);
}

// A 1-based index in [1..max], returned 0-based; msg names the range
static UInt GetIndex(const char * funcname,
                     Obj          i,
                     const char * argname,
                     UInt         max,
                     const char * msg)
{
    if (!IS_POS_INTOBJ(i) || (UInt)INT_INTOBJ(i) > max)
        RequireArgumentEx(funcname, i, argname, msg);
    return INT_INTOBJ(i) - 1;
}

static const char ROW_RANGE[] = "must be in [1..NrRows(<M>)]";
static const char COL_RANGE[] = "must be in [1..NrCols(<M>)]";
static const char POS_RANGE[] = "must be in [1..Length(<v>)]";

// New object of type <type>; NewBag zeroes the cells
static Obj NewPacked(Obj type, UInt d0, UInt d1, uint64_t words)
{
    if (words > (((UInt)-1) - CELLS_OFFSET) / sizeof(uint64_t))
        ErrorMayQuit("packed matrix or vector too large", 0, 0);
    Obj obj = NewBag(T_DATOBJ, CELLS_OFFSET + (UInt)words * sizeof(uint64_t));
    SetTypeDatObj(obj, type);
    uint32_t * d = DIMS(obj);
    d[0] = (uint32_t)d0;
    d[1] = (uint32_t)d1;
    return obj;
}

static Obj NewPackedMat(Obj type, UInt nrows, UInt ncols)
{
    const packmat_field * f = FIELD(DATA_TYPE(type));
    return NewPacked(type, nrows, ncols,
                     packmat_matrix_words(f, nrows, ncols));
}

static Obj NewPackedVec(Obj type, UInt len)
{
    const packmat_field * f = FIELD(DATA_TYPE(type));
    return NewPacked(type, len, 0, packmat_vector_words(f, len));
}


/****************************************************************************
**
*F * * * * * * * * * * * * *  entries and residues  * * * * * * * * * * * * *
*/

// GAP object for residue r; may allocate
static Obj EntryObj(Obj tdata, uint64_t r)
{
    Obj one = ELM_PLIST(tdata, TDATA_ONE);
    if (IS_FFE(one)) {
        packmat_field *  f = FIELD(tdata);
        const uint16_t * rank = packmat_field_rank(f);
        return NEW_FFE(FLD_FFE(one), rank ? rank[r] : (FFV)r);
    }
    Obj res = ObjInt_UInt8(r);
    Obj x = NewBag(T_POSOBJ, 2 * sizeof(Obj));
    SET_TYPE_POSOBJ(x, TYPE_POSOBJ(one));
    ADDR_OBJ(x)[1] = res;
    CHANGED_BAG(x);
    return x;
}

// Residue of the integer r, which must lie in [0..n-1]
static uint64_t ResidueOfInt(Obj tdata, Obj r)
{
    const uint64_t n = FIELD(tdata)->n;
    if (IS_NONNEG_INTOBJ(r) && (UInt)INT_INTOBJ(r) < n)
        return INT_INTOBJ(r);
    if (TNUM_OBJ(r) == T_INTPOS &&
        SIZE_INT(r) * sizeof(UInt) <= sizeof(uint64_t)) {
        const uint64_t x = UInt8_ObjInt(r);
        if (x < n)
            return x;
    }
    ErrorMayQuit("packed matrix: invalid residue", 0, 0);
}

// Residue of x, which must lie in the base domain. Fast paths for FFEs of
// the base field and ZmodnZObj of its type; anything else goes through
// PACKMAT_EntryResidue, which may run any GAP code.
static uint64_t EntryResidue(Obj tdata, Obj x)
{
    Obj one = ELM_PLIST(tdata, TDATA_ONE);
    if (IS_FFE(one)) {
        if (IS_FFE(x) && FLD_FFE(x) == FLD_FFE(one)) {
            packmat_field * f = FIELD(tdata);
            const FFV       v = VAL_FFE(x);
            return f->ranked ? INVERSE(f)[v] : v;
        }
    }
    else if (TNUM_OBJ(x) == T_POSOBJ && TYPE_POSOBJ(x) == TYPE_POSOBJ(one)) {
        return ResidueOfInt(tdata, CONST_ADDR_OBJ(x)[1]);
    }
    Obj r = CALL_2ARGS(PackmatEntryResidueFunc,
                       ELM_PLIST(tdata, TDATA_BASEDOMAIN), x);
    if (r == Fail)
        ErrorMayQuit("<x> must lie in the base domain", 0, 0);
    return ResidueOfInt(tdata, r);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * *  field contexts  * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncPACKMAT_FIELD_BAG( <self>, <n>, <one> )
**
**  Field bag for GF(n) if <one> is an FFE, else for Integers mod n with
**  elements of the type of <one>; fail if no kind covers n.
*/
static Obj FuncPACKMAT_FIELD_BAG(Obj self, Obj n, Obj one)
{
    uint64_t nn;
    if (IS_INTOBJ(n) && INT_INTOBJ(n) >= 2)
        nn = INT_INTOBJ(n);
    else if (TNUM_OBJ(n) == T_INTPOS &&
             SIZE_INT(n) * sizeof(UInt) <= sizeof(uint64_t))
        nn = UInt8_ObjInt(n);
    else
        return Fail;

    const int kind = packmat_choose_kind(nn, 1);
    if (kind == PACKMAT_NO_KIND)
        return Fail;

    // ranked: GF(p), p > 2, with internal FFEs
    int ranked = 0;
    FF  ff = 0;
    if (IS_FFE(one)) {
        ff = FLD_FFE(one);
        if (CHAR_FF(ff) != nn || DEGR_FF(ff) != 1)
            ErrorMayQuit("PACKMAT_FIELD_BAG: <one> must lie in GF(<n>)", 0,
                         0);
        ranked = kind != PACKMAT_GF2;
    }
    else if (TNUM_OBJ(one) != T_POSOBJ) {
        RequireArgumentEx(SELF_NAME, one, "<one>",
                          "must be an FFE or a ZmodnZObj");
    }

    const size_t fsize = packmat_field_size(kind, nn, ranked);
    const size_t isize =
        ranked ? ((size_t)nn * sizeof(uint16_t) + 7) & ~(size_t)7 : 0;
    Obj bag = NewKernelBuffer(FIELD_OFFSET + fsize + isize);

    packmat_field * f = FIELD_OF_BAG(bag);
    packmat_field_init(f, kind, nn, ranked);
    if (ranked) {
        // residue r + 1 has FFE value SUM_FFV(value of r, 1)
        uint16_t *  rank = packmat_field_rank(f);
        uint16_t *  inv = INVERSE(f);
        const FFV * succ = SUCC_FF(ff);
        FFV         v = 0;
        for (uint64_t r = 0; r < nn; r++) {
            rank[r] = (uint16_t)v;
            inv[v] = (uint16_t)r;
            v = SUM_FFV(v, 1, succ);
        }
    }
    GAP_ASSERT(packmat_field_check(f));
    return bag;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * constructors * * * * * * * * * * * * * * * *
*/

static Obj FuncPACKMAT_ZERO_MATRIX(Obj self, Obj type, Obj nrows, Obj ncols)
{
    RequirePackedType(SELF_NAME, type, IsPackedMatrixRepFilt);
    return NewPackedMat(type, GetDim(SELF_NAME, nrows, "<nrows>"),
                        GetDim(SELF_NAME, ncols, "<ncols>"));
}

static Obj FuncPACKMAT_IDENTITY_MATRIX(Obj self, Obj type, Obj n)
{
    RequirePackedType(SELF_NAME, type, IsPackedMatrixRepFilt);
    const UInt d = GetDim(SELF_NAME, n, "<n>");
    Obj        M = NewPackedMat(type, d, d);
    packmat_identity(MAT_VIEW(M));
    return M;
}

static Obj FuncPACKMAT_ZERO_VECTOR(Obj self, Obj type, Obj len)
{
    RequirePackedType(SELF_NAME, type, IsPackedVectorRepFilt);
    return NewPackedVec(type, GetDim(SELF_NAME, len, "<len>"));
}

// Word k of the bits of a GF(2) vector
static uint64_t GF2VecWord(Obj vec, UInt k)
{
    const UInt * blocks = CONST_BLOCKS_GF2VEC(vec);
#ifdef SYS_IS_64_BIT
    return blocks[k];
#else
    const UInt     nb = NUMBER_BLOCKS_GF2VEC(vec);
    const uint64_t hi = 2 * k + 1 < nb ? blocks[2 * k + 1] : 0;
    return blocks[2 * k] | (hi << 32);
#endif
}

// Word k of the cells of a packed vector
static uint64_t PackedVecWord(Obj vec, UInt k)
{
    return CELLS(vec)[k];
}

// Store the first m.ncols bits that word() reads from src as row i of the
// GF(2) matrix m, whose row i is still zero
static void
SetGF2Row(packmat_mat m, uint32_t i, Obj src, uint64_t (*word)(Obj, UInt))
{
    const uint32_t nc = m.ncols;
    const uint32_t r = packmat_rows_per_word(m.f, nc);
    if (r > 1) {
        // nc <= 32 cells of one bit each
        const uint64_t w = word(src, 0) & (((uint64_t)1 << nc) - 1);
        m.w[i / r] |= w << ((i % r) * nc);
        return;
    }
    const uint32_t stride = packmat_stride(m.f, nc);
    uint64_t *     dst = m.w + (size_t)i * stride;
    for (uint32_t k = 0; k < stride; k++)
        dst[k] = word(src, k);
    if (nc % 64)
        dst[stride - 1] &= ((uint64_t)1 << (nc % 64)) - 1;
}

static void RequireRowLength(UInt len, uint32_t nc)
{
    if (len != nc)
        ErrorMayQuit("the entries of <list> must have length <ncols>", 0, 0);
}

// Set row i of the packed matrix (or, with i = 0, the packed vector) dst,
// which is still zero, from the list or vector object row. view() gives
// the view of dst. Compressed rows, and packed rows with the same base
// domain, are copied without entry objects.
static void SetRowFrom(
    Obj dst, packmat_mat (*view)(Obj), uint32_t i, Obj row, uint32_t nc)
{
    Obj            tdata = TDATA(dst);
    const uint64_t n = FIELD(tdata)->n;
    const int      gf2 = FIELD(tdata)->kind == PACKMAT_GF2;

    if (IS_PACKED_VEC(row) && TDATA(row) == tdata) {
        RequireRowLength(CONST_DIMS(row)[0], nc);
        packmat_mat m = view(dst);
        if (gf2) {
            SetGF2Row(m, i, row, PackedVecWord);
            return;
        }
        packmat_mat v = VEC_VIEW(row);
        for (uint32_t j = 0; j < nc; j++)
            packmat_mat_set(m, i, j, packmat_vec_get(v, j));
        return;
    }

    if (gf2 && IS_GF2VEC_REP(row)) {
        RequireRowLength(LEN_GF2VEC(row), nc);
        SetGF2Row(view(dst), i, row, GF2VecWord);
        return;
    }

    // over GF(p) with FFE entries, decode the bytes into FFE values, then
    // residues; the field info exists, since row does
    if (IS_FFE(ELM_PLIST(tdata, TDATA_ONE)) && IS_VEC8BIT_REP(row) &&
        FIELD_VEC8BIT(row) == n) {
        RequireRowLength(LEN_VEC8BIT(row), nc);
        Obj              info = GetFieldInfo8Bit(n);
        const UInt       e = ELS_BYTE_FIELDINFO_8BIT(info);
        const UInt1 *    getelt = GETELT_FIELDINFO_8BIT(info);
        const Obj *      felt = CONST_FFE_FELT_FIELDINFO_8BIT(info);
        const UInt1 *    bytes = CONST_BYTES_VEC8BIT(row);
        packmat_mat      m = view(dst);
        const uint16_t * inv = INVERSE((packmat_field *)m.f);
        for (uint32_t j = 0; j < nc; j++) {
            const UInt1 x = getelt[256 * (j % e) + bytes[j / e]];
            packmat_mat_set(m, i, j, inv[VAL_FFE(felt[x])]);
        }
        return;
    }

    // anything else, entry by entry; ELM_LIST and EntryResidue may run GAP
    // code, so the view is made again for every entry
    RequireRowLength(LEN_LIST(row), nc);
    for (uint32_t j = 0; j < nc; j++) {
        const uint64_t r = EntryResidue(tdata, ELM_LIST(row, j + 1));
        packmat_mat_set(view(dst), i, j, r);
    }
}

/****************************************************************************
**
*F  FuncPACKMAT_MATRIX( <self>, <type>, <ncols>, <src> )
**
**  A new matrix of type <type> with <ncols> columns from <src>: a list of
**  rows (plain lists, compressed or packed vectors, any vector objects), or
**  a packed matrix.
*/
static Obj FuncPACKMAT_MATRIX(Obj self, Obj type, Obj ncols, Obj src)
{
    Obj tdata = RequirePackedType(SELF_NAME, type, IsPackedMatrixRepFilt);
    const UInt nc = GetDim(SELF_NAME, ncols, "<ncols>");

    if (IS_PACKED_MAT(src)) {
        const UInt nr = CONST_DIMS(src)[0];
        if (CONST_DIMS(src)[1] != nc)
            ErrorMayQuit("PACKMAT_MATRIX: <src> must have <ncols> columns", 0,
                         0);
        Obj M = NewPackedMat(type, nr, nc);
        if (TDATA(src) == tdata) {
            packmat_copy(MAT_VIEW(M), MAT_VIEW(src));
            return M;
        }
        Obj stdata = TDATA(src);
        for (UInt i = 0; i < nr; i++) {
            for (UInt j = 0; j < nc; j++) {
                Obj x =
                    EntryObj(stdata, packmat_mat_get(MAT_VIEW(src), i, j));
                const uint64_t r = EntryResidue(tdata, x);
                packmat_mat_set(MAT_VIEW(M), i, j, r);
            }
        }
        return M;
    }

    if (!IS_LIST(src))
        RequireArgumentEx(SELF_NAME, src, "<src>",
                          "must be a list or a packed matrix");
    const UInt nr = LEN_LIST(src);
    if (nr > MAX_DIM)
        ErrorMayQuit("PACKMAT_MATRIX: too many rows", 0, 0);
    Obj M = NewPackedMat(type, nr, nc);
    for (UInt i = 0; i < nr; i++)
        SetRowFrom(M, MAT_VIEW, i, ELM_LIST(src, i + 1), nc);
    return M;
}

/****************************************************************************
**
*F  FuncPACKMAT_VECTOR( <self>, <type>, <src> )
**
**  A new vector of type <type> from <src>: a list, or any vector object.
*/
static Obj FuncPACKMAT_VECTOR(Obj self, Obj type, Obj src)
{
    RequirePackedType(SELF_NAME, type, IsPackedVectorRepFilt);
    const UInt len = IS_PACKED_VEC(src) ? CONST_DIMS(src)[0] : LEN_LIST(src);
    if (len > MAX_DIM)
        ErrorMayQuit("PACKMAT_VECTOR: <src> is too long", 0, 0);
    Obj v = NewPackedVec(type, len);
    SetRowFrom(v, VEC_VIEW, 0, src, len);
    return v;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * *  attributes  * * * * * * * * * * * * * * * *
*/

static Obj FuncPACKMAT_NROWS(Obj self, Obj M)
{
    RequirePackedMat(SELF_NAME, M);
    return ObjInt_UInt(CONST_DIMS(M)[0]);
}

static Obj FuncPACKMAT_NCOLS(Obj self, Obj M)
{
    RequirePackedMat(SELF_NAME, M);
    return ObjInt_UInt(CONST_DIMS(M)[1]);
}

static Obj FuncPACKMAT_LENGTH(Obj self, Obj v)
{
    RequirePackedVec(SELF_NAME, v);
    return ObjInt_UInt(CONST_DIMS(v)[0]);
}

static Obj FuncPACKMAT_BASE_DOMAIN(Obj self, Obj obj)
{
    RequirePackedView(SELF_NAME, obj);
    return ELM_PLIST(TDATA(obj), TDATA_BASEDOMAIN);
}

static Obj FuncPACKMAT_ONE_OF_BASE_DOMAIN(Obj self, Obj obj)
{
    RequirePackedView(SELF_NAME, obj);
    return ELM_PLIST(TDATA(obj), TDATA_ONE);
}

static Obj FuncPACKMAT_ZERO_OF_BASE_DOMAIN(Obj self, Obj obj)
{
    RequirePackedView(SELF_NAME, obj);
    return ELM_PLIST(TDATA(obj), TDATA_ZERO);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * *  entries * * * * * * * * * * * * * * * * *
*/

static Obj FuncPACKMAT_MAT_ELM(Obj self, Obj M, Obj row, Obj col)
{
    RequirePackedMat("Matrix Element", M);
    const uint32_t * d = CONST_DIMS(M);
    const UInt i = GetIndex("Matrix Element", row, "<row>", d[0], ROW_RANGE);
    const UInt j = GetIndex("Matrix Element", col, "<col>", d[1], COL_RANGE);
    Obj        tdata = TDATA(M);
    return EntryObj(tdata, packmat_mat_get(MAT_VIEW(M), i, j));
}

static Obj FuncPACKMAT_SET_MAT_ELM(Obj self, Obj M, Obj row, Obj col, Obj x)
{
    RequirePackedMat("Matrix Assignment", M);
    RequireMutable("Matrix Assignment", M, "matrix");
    const uint32_t * d = CONST_DIMS(M);
    const UInt       i =
        GetIndex("Matrix Assignment", row, "<row>", d[0], ROW_RANGE);
    const UInt j =
        GetIndex("Matrix Assignment", col, "<col>", d[1], COL_RANGE);
    const uint64_t r = EntryResidue(TDATA(M), x);
    packmat_mat_set(MAT_VIEW(M), i, j, r);
    return 0;
}

static Obj FuncPACKMAT_VEC_ELM(Obj self, Obj v, Obj pos)
{
    RequirePackedVec("Vector Element", v);
    const UInt i =
        GetIndex("Vector Element", pos, "<pos>", CONST_DIMS(v)[0], POS_RANGE);
    return EntryObj(TDATA(v), packmat_vec_get(VEC_VIEW(v), i));
}

static Obj FuncPACKMAT_SET_VEC_ELM(Obj self, Obj v, Obj pos, Obj x)
{
    RequirePackedVec("Vector Assignment", v);
    RequireMutable("Vector Assignment", v, "vector");
    const UInt     i = GetIndex("Vector Assignment", pos, "<pos>",
                                CONST_DIMS(v)[0], POS_RANGE);
    const uint64_t r = EntryResidue(TDATA(v), x);
    packmat_vec_set(VEC_VIEW(v), i, r);
    return 0;
}

// List of the entries of row i of a matrix (or, with i = 0, of a vector)
static Obj UnpackRow(Obj obj, packmat_mat (*view)(Obj), uint32_t i)
{
    Obj            tdata = TDATA(obj);
    const uint32_t nc = view(obj).ncols;
    Obj            list = NEW_PLIST(T_PLIST, nc);
    for (uint32_t j = 0; j < nc; j++) {
        Obj x = EntryObj(tdata, packmat_mat_get(view(obj), i, j));
        SET_ELM_PLIST(list, j + 1, x);
        SET_LEN_PLIST(list, j + 1);
        CHANGED_BAG(list);
    }
    return list;
}

static Obj FuncPACKMAT_UNPACK(Obj self, Obj obj)
{
    if (IS_PACKED_VEC(obj))
        return UnpackRow(obj, VEC_VIEW, 0);
    RequirePackedMat(SELF_NAME, obj);
    const uint32_t nr = CONST_DIMS(obj)[0];
    Obj            list = NEW_PLIST(T_PLIST, nr);
    for (uint32_t i = 0; i < nr; i++) {
        Obj row = UnpackRow(obj, MAT_VIEW, i);
        SET_ELM_PLIST(list, i + 1, row);
        SET_LEN_PLIST(list, i + 1);
        CHANGED_BAG(list);
    }
    return list;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * *  whole objects * * * * * * * * * * * * * * * *
*/

static Obj FuncPACKMAT_EQ_MAT(Obj self, Obj a, Obj b)
{
    RequirePackedMat(SELF_NAME, a);
    RequirePackedMat(SELF_NAME, b);
    const uint32_t * da = CONST_DIMS(a);
    const uint32_t * db = CONST_DIMS(b);
    if (TDATA(a) != TDATA(b) || da[0] != db[0] || da[1] != db[1])
        return False;
    return packmat_equal(MAT_VIEW(a), MAT_VIEW(b)) ? True : False;
}

static Obj FuncPACKMAT_EQ_VEC(Obj self, Obj a, Obj b)
{
    RequirePackedVec(SELF_NAME, a);
    RequirePackedVec(SELF_NAME, b);
    if (TDATA(a) != TDATA(b) || CONST_DIMS(a)[0] != CONST_DIMS(b)[0])
        return False;
    return packmat_equal(VEC_VIEW(a), VEC_VIEW(b)) ? True : False;
}

// Compare two vector views of lengths la, lb as GAP lists: the shorter one
// sorts first if it is a prefix. Views of the shorter length see beyond it
// in the longer vector, but there the shorter has zero cells and zero
// ranks lowest, so a difference found there means the longer is larger.
static int CompareVecs(packmat_mat a, packmat_mat b)
{
    const uint32_t la = a.ncols;
    const uint32_t lb = b.ncols;
    a.ncols = b.ncols = la < lb ? la : lb;
    const int c = packmat_compare(a, b);
    if (c != 0 || la == lb)
        return c;
    return la < lb ? -1 : 1;
}

// Row 0 of m as a vector view; if rows share a word, w receives row 0
// alone
static packmat_mat Row0(packmat_mat m, uint64_t * w)
{
    if (packmat_rows_per_word(m.f, m.ncols) == 1)
        return packmat_vec_view(m.f, m.w, m.ncols);
    *w = m.w[0] & (((uint64_t)1 << (m.ncols * m.f->bits)) - 1);
    return packmat_vec_view(m.f, w, m.ncols);
}

// Unpack( a ) < Unpack( b ): rows compare as lists, and the matrix with
// fewer rows sorts first if its rows are a prefix. With different numbers
// of columns, the first rows always differ.
static Obj FuncPACKMAT_LT_MAT(Obj self, Obj a, Obj b)
{
    RequirePackedMat(SELF_NAME, a);
    RequirePackedMat(SELF_NAME, b);
    if (TDATA(a) != TDATA(b))
        ErrorMayQuit("\\<: <a> and <b> must have the same base domain", 0, 0);
    packmat_mat ma = MAT_VIEW(a);
    packmat_mat mb = MAT_VIEW(b);
    if (ma.nrows == 0 || mb.nrows == 0)
        return ma.nrows < mb.nrows ? True : False;
    if (ma.ncols != mb.ncols) {
        uint64_t wa, wb;
        return CompareVecs(Row0(ma, &wa), Row0(mb, &wb)) < 0 ? True : False;
    }
    const uint32_t ra = ma.nrows;
    const uint32_t rb = mb.nrows;
    ma.nrows = mb.nrows = ra < rb ? ra : rb;
    const int c = packmat_compare(ma, mb);
    if (c != 0)
        return c < 0 ? True : False;
    return ra < rb ? True : False;
}

static Obj FuncPACKMAT_LT_VEC(Obj self, Obj a, Obj b)
{
    RequirePackedVec(SELF_NAME, a);
    RequirePackedVec(SELF_NAME, b);
    if (TDATA(a) != TDATA(b))
        ErrorMayQuit("\\<: <a> and <b> must have the same base domain", 0, 0);
    return CompareVecs(VEC_VIEW(a), VEC_VIEW(b)) < 0 ? True : False;
}

// The core's 64-bit hash, cut to its top bits so that it is a nonnegative
// small integer
static Obj FuncPACKMAT_HASH(Obj self, Obj obj)
{
    const uint64_t h = packmat_hash(RequirePackedView(SELF_NAME, obj));
    return INTOBJ_INT((Int)(h >> (64 - NR_SMALL_INT_BITS)));
}

static Obj FuncPACKMAT_IS_ZERO(Obj self, Obj obj)
{
    return packmat_is_zero(RequirePackedView(SELF_NAME, obj)) ? True : False;
}

static Obj FuncPACKMAT_IS_ONE(Obj self, Obj M)
{
    RequirePackedMat(SELF_NAME, M);
    return packmat_is_identity(MAT_VIEW(M)) ? True : False;
}

/****************************************************************************
**
*F  FuncPACKMAT_COPY( <self>, <obj>, <type> )
**
**  A copy of the packed matrix or vector <obj> with type <type>, which must
**  have the same base domain and kind of object.
*/
static Obj FuncPACKMAT_COPY(Obj self, Obj obj, Obj type)
{
    Obj filt =
        IS_PACKED_MAT(obj) ? IsPackedMatrixRepFilt : IsPackedVectorRepFilt;
    RequirePackedView(SELF_NAME, obj);
    if (RequirePackedType(SELF_NAME, type, filt) != TDATA(obj))
        ErrorMayQuit(
            "PACKMAT_COPY: <type> must have the base domain of <obj>", 0, 0);
    const UInt size = SIZE_OBJ(obj);
    Obj        copy = NewBag(T_DATOBJ, size);
    SetTypeDatObj(copy, type);
    memcpy((char *)ADDR_OBJ(copy) + DIMS_OFFSET,
           (const char *)CONST_ADDR_OBJ(obj) + DIMS_OFFSET,
           size - DIMS_OFFSET);
    return copy;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_2ARGS(PACKMAT_FIELD_BAG, n, one),
    GVAR_FUNC_3ARGS(PACKMAT_ZERO_MATRIX, type, nrows, ncols),
    GVAR_FUNC_2ARGS(PACKMAT_IDENTITY_MATRIX, type, n),
    GVAR_FUNC_2ARGS(PACKMAT_ZERO_VECTOR, type, len),
    GVAR_FUNC_3ARGS(PACKMAT_MATRIX, type, ncols, src),
    GVAR_FUNC_2ARGS(PACKMAT_VECTOR, type, src),
    GVAR_FUNC_1ARGS(PACKMAT_NROWS, M),
    GVAR_FUNC_1ARGS(PACKMAT_NCOLS, M),
    GVAR_FUNC_1ARGS(PACKMAT_LENGTH, v),
    GVAR_FUNC_1ARGS(PACKMAT_BASE_DOMAIN, obj),
    GVAR_FUNC_1ARGS(PACKMAT_ONE_OF_BASE_DOMAIN, obj),
    GVAR_FUNC_1ARGS(PACKMAT_ZERO_OF_BASE_DOMAIN, obj),
    GVAR_FUNC_3ARGS(PACKMAT_MAT_ELM, M, row, col),
    GVAR_FUNC_4ARGS(PACKMAT_SET_MAT_ELM, M, row, col, x),
    GVAR_FUNC_2ARGS(PACKMAT_VEC_ELM, v, pos),
    GVAR_FUNC_3ARGS(PACKMAT_SET_VEC_ELM, v, pos, x),
    GVAR_FUNC_1ARGS(PACKMAT_UNPACK, obj),
    GVAR_FUNC_2ARGS(PACKMAT_EQ_MAT, a, b),
    GVAR_FUNC_2ARGS(PACKMAT_EQ_VEC, a, b),
    GVAR_FUNC_2ARGS(PACKMAT_LT_MAT, a, b),
    GVAR_FUNC_2ARGS(PACKMAT_LT_VEC, a, b),
    GVAR_FUNC_1ARGS(PACKMAT_HASH, obj),
    GVAR_FUNC_1ARGS(PACKMAT_IS_ZERO, obj),
    GVAR_FUNC_1ARGS(PACKMAT_IS_ONE, M),
    GVAR_FUNC_2ARGS(PACKMAT_COPY, obj, type),
    { 0, 0, 0, 0, 0 }

};

static Int InitKernel(StructInitInfo * module)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    ImportFuncFromLibrary("IsPackedMatrixRep", &IsPackedMatrixRepFilt);
    ImportFuncFromLibrary("IsPackedVectorRep", &IsPackedVectorRepFilt);
    ImportFuncFromLibrary("PACKMAT_EntryResidue", &PackmatEntryResidueFunc);
    return 0;
}

static Int InitLibrary(StructInitInfo * module)
{
    InitGVarFuncsFromTable(GVarFuncs);
    return 0;
}

static StructInitInfo module = {
    .type = MODULE_BUILTIN,
    .name = "packmat",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoPackmat(void)
{
    return &module;
}
