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
**  have identical data. The field bag is a kernel buffer: a stamp at offset
**  8, the core's packmat_field at offset 16, then, if the field is ranked,
**  the inverse of its rank table. The stamp says the bag was checked in
**  this session; bags start unchecked, and every workspace load starts a
**  new session, so a bag is checked once before its first use.
**
**  The type of the field bag has as data the immutable list of the four
**  types, [ matrix, immutable matrix, vector, immutable vector ], made after
**  them (HPC-GAP makes type data read-only), so that C finds the type of any
**  result.
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
#include "gapstate.h"
#include "integer.h"
#include "lists.h"
#include "modules.h"
#include "objects.h"
#include "opers.h"
#include "plist.h"
#include "range.h"
#include "stats.h"
#include "vec8bit.h"
#include "vecgf2.h"

#include "packmat/packmat.h"

#include <string.h>


// Byte offsets in a packed object and in a field bag
enum {
    DIMS_OFFSET = 8,
    CELLS_OFFSET = 16,
    STAMP_OFFSET = 8,
    FIELD_OFFSET = 16,
};

// Positions in the type data
enum {
    TDATA_BASEDOMAIN = 1,
    TDATA_FIELD = 2,
    TDATA_ONE = 3,
    TDATA_ZERO = 4,
    TDATA_LEN = 4,
};

// Positions in the data of the field bag's type
enum {
    SIB_MAT = 1,
    SIB_IMM_MAT = 2,
    SIB_VEC = 3,
    SIB_IMM_VEC = 4,
    SIB_LEN = 4,
};

// Dimensions are uint32_t in the core
static const UInt MAX_DIM = 0xFFFFFFFFu;

// Largest bag: below GASMAN's 48-bit size field, and far enough below
// 2^32 on 32-bit that adding the bag header cannot wrap
static const UInt MAX_BAG_SIZE = (UInt)1 << (sizeof(UInt) == 8 ? 47 : 31);

// Stamp of a field bag checked in this session: STAMP_MAGIC ^ the number
// of the session, which PostRestore increases. GenerationObj is saved in
// workspaces.
static const uint64_t STAMP_MAGIC = 0x7061636b6d617421ull;
static uint64_t       Stamp;
static Obj            GenerationObj;

static Obj IsKernelDataObjectRepFilt;
static Obj IsMutableFilt;

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

static inline uint64_t * STAMP_OF_BAG(Obj bag)
{
    return (uint64_t *)((char *)ADDR_OBJ(bag) + STAMP_OFFSET);
}

// Inverse of the rank table: FFE value -> residue
static inline uint16_t * INVERSE(packmat_field * f)
{
    return (uint16_t *)((char *)f + packmat_field_size(f->kind, f->n, 1));
}

static size_t InverseSize(uint64_t n, int ranked)
{
    return ranked ? ((size_t)n * sizeof(uint16_t) + 7) & ~(size_t)7 : 0;
}

static void CheckField(Obj tdata);

// The field context of a type's data, checked once per session
static inline packmat_field * FIELD(Obj tdata)
{
    Obj bag = ELM_PLIST(tdata, TDATA_FIELD);
    if (*STAMP_OF_BAG(bag) != Stamp)
        CheckField(tdata);
    return FIELD_OF_BAG(bag);
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

// TRUE for a packed matrix, FALSE for a packed vector, else an error
static BOOL
RequirePackedObj(const char * funcname, Obj obj, const char * argname)
{
    if (IS_PACKED_MAT(obj))
        return TRUE;
    if (!IS_PACKED_VEC(obj))
        RequireArgumentEx(funcname, obj, argname,
                          "must be a packed matrix or vector");
    return FALSE;
}

static inline packmat_mat VIEW(Obj obj, BOOL mat)
{
    return mat ? MAT_VIEW(obj) : VEC_VIEW(obj);
}

static void RequireSameContext(const char * funcname, Obj a, Obj b)
{
    if (TDATA(a) != TDATA(b))
        ErrorMayQuit("%s: the arguments must have the same base domain",
                     (Int)funcname, 0);
}

// a and b are both packed matrices or both packed vectors, with the same
// base domain and dimensions; returns TRUE for matrices
static BOOL RequireCompatible(const char * funcname, Obj a, Obj b)
{
    const BOOL mat = RequirePackedObj(funcname, a, "<a>");
    if (RequirePackedObj(funcname, b, "<b>") != mat)
        ErrorMayQuit("%s: <a> and <b> must both be matrices or both vectors",
                     (Int)funcname, 0);
    RequireSameContext(funcname, a, b);
    const uint32_t * da = CONST_DIMS(a);
    const uint32_t * db = CONST_DIMS(b);
    if (da[0] != db[0] || da[1] != db[1])
        ErrorMayQuit(mat ? "%s: <a> and <b> must have the same dimensions"
                         : "%s: <a> and <b> must have the same length",
                     (Int)funcname, 0);
    return mat;
}

// 1 if tdata has the shape of packed type data; CheckField does the rest
static BOOL IsTypeData(Obj tdata)
{
    if (!IS_PLIST(tdata) || LEN_PLIST(tdata) != TDATA_LEN)
        return FALSE;
    Obj bag = ELM_PLIST(tdata, TDATA_FIELD);
    Obj one = ELM_PLIST(tdata, TDATA_ONE);
    return bag && TNUM_OBJ(bag) == T_DATOBJ &&
           DoFilter(IsKernelDataObjectRepFilt, bag) == True &&
           SIZE_OBJ(bag) >= FIELD_OFFSET + sizeof(packmat_field) && one &&
           (IS_FFE(one) || TNUM_OBJ(one) == T_POSOBJ) &&
           ELM_PLIST(tdata, TDATA_BASEDOMAIN) && ELM_PLIST(tdata, TDATA_ZERO);
}

// Type data of a packed type whose objects lie in <filt>
static Obj RequirePackedType(const char * funcname, Obj type, Obj filt)
{
    if (TNUM_OBJ(type) != T_POSOBJ ||
        SIZE_OBJ(type) <= POS_DATA_TYPE * sizeof(Obj) ||
        !IS_SUBSET_FLAGS(FLAGS_TYPE(type), FLAGS_FILT(filt)) ||
        !IsTypeData(DATA_TYPE(type)))
        RequireArgumentEx(funcname, type, "<type>", "must be a packed type");
    return DATA_TYPE(type);
}

// A dimension: a small nonnegative integer below 2^32
static UInt GetDim(const char * funcname, Obj n, const char * argname)
{
    if (!IS_NONNEG_INTOBJ(n) || (UInt)INT_INTOBJ(n) > MAX_DIM)
        RequireArgumentEx(funcname, n, argname,
                          "must be a small nonnegative integer below 2^32");
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
    if (words > (MAX_BAG_SIZE - CELLS_OFFSET) / sizeof(uint64_t))
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

// Type number k (SIB_MAT, ...) of the context of tdata
static Obj SiblingType(Obj tdata, Int k)
{
    FIELD(tdata);    // checks the sibling types once per session
    Obj bag = ELM_PLIST(tdata, TDATA_FIELD);
    Obj type = ELM_PLIST(DATA_TYPE(TYPE_DATOBJ(bag)), k);
    // forged type data may share a checked field bag
    if (DATA_TYPE(type) != tdata)
        ErrorMayQuit("packed matrix: invalid field context", 0, 0);
    return type;
}

static Obj ResultType(Obj tdata, BOOL mat, BOOL mut)
{
    return SiblingType(tdata, mat ? (mut ? SIB_MAT : SIB_IMM_MAT)
                                  : (mut ? SIB_VEC : SIB_IMM_VEC));
}

// New zero object of type <type> with the dimensions of obj
static Obj NewLike(Obj obj, Obj type)
{
    Obj res = NewBag(T_DATOBJ, SIZE_OBJ(obj));
    SetTypeDatObj(res, type);
    memcpy(DIMS(res), CONST_DIMS(obj), 2 * sizeof(uint32_t));
    return res;
}

// Copy of obj with type <type>, which must have the data of obj's type
static Obj CopyAs(Obj obj, Obj type)
{
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
#ifdef HPCGAP
    // as Objectify does for IsReadOnlyPositionalObjectRep
    MakeBagReadOnly(x);
#endif
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

// Residue of the scalar s in *r: an integer, taken mod n, or an element of
// the base domain; FALSE for anything else. May run GAP code.
static BOOL ScalarResidueOrFail(Obj tdata, Obj s, uint64_t * r)
{
    const uint64_t n = FIELD(tdata)->n;
    if (IS_INTOBJ(s)) {
        const Int x = INT_INTOBJ(s);
        *r = x >= 0 ? (uint64_t)x % n : n - 1 - (uint64_t)(-(x + 1)) % n;
        return TRUE;
    }
    if (IS_LARGEINT(s)) {
        *r = UInt8_ObjInt(ModInt(s, ObjInt_UInt8(n)));
        return TRUE;
    }

    Obj one = ELM_PLIST(tdata, TDATA_ONE);
    if (IS_FFE(one)
            ? IS_FFE(s) && FLD_FFE(s) == FLD_FFE(one)
            : TNUM_OBJ(s) == T_POSOBJ && TYPE_POSOBJ(s) == TYPE_POSOBJ(one)) {
        *r = EntryResidue(tdata, s);
        return TRUE;
    }
    Obj x = CALL_2ARGS(PackmatEntryResidueFunc,
                       ELM_PLIST(tdata, TDATA_BASEDOMAIN), s);
    if (x == Fail)
        return FALSE;
    *r = ResidueOfInt(tdata, x);
    return TRUE;
}

static uint64_t ScalarResidue(const char * funcname, Obj tdata, Obj s)
{
    uint64_t r;
    if (!ScalarResidueOrFail(tdata, s, &r))
        ErrorMayQuit("%s: <s> must be an integer or lie in the base domain",
                     (Int)funcname, 0);
    return r;
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
    Obj bag = NewKernelBuffer(FIELD_OFFSET + fsize + InverseSize(nn, ranked));

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
    return bag;
}

// 1 if the sibling types in the data of type <type> are made from tdata,
// with the kind and mutability of their position
static BOOL SiblingTypesOK(Obj tdata, Obj type)
{
    if (TNUM_OBJ(type) != T_POSOBJ ||
        SIZE_OBJ(type) <= POS_DATA_TYPE * sizeof(Obj))
        return FALSE;
    Obj sib = DATA_TYPE(type);
    if (!sib || !IS_PLIST(sib) || LEN_PLIST(sib) != SIB_LEN)
        return FALSE;
    for (Int k = 1; k <= SIB_LEN; k++) {
        Obj t = ELM_PLIST(sib, k);
        Obj filt =
            k <= SIB_IMM_MAT ? IsPackedMatrixRepFilt : IsPackedVectorRepFilt;
        const BOOL mut = k == SIB_MAT || k == SIB_VEC;
        if (!t || TNUM_OBJ(t) != T_POSOBJ ||
            SIZE_OBJ(t) <= POS_DATA_TYPE * sizeof(Obj) ||
            DATA_TYPE(t) != tdata ||
            !IS_SUBSET_FLAGS(FLAGS_TYPE(t), FLAGS_FILT(filt)) ||
            IS_SUBSET_FLAGS(FLAGS_TYPE(t), FLAGS_FILT(IsMutableFilt)) != mut)
            return FALSE;
    }
    return TRUE;
}

static BOOL SiblingsOK(Obj tdata)
{
    return SiblingTypesOK(tdata, TYPE_DATOBJ(ELM_PLIST(tdata, TDATA_FIELD)));
}

/****************************************************************************
**
*F  FuncPACKMAT_SET_SIBLINGS( <self>, <type> )
**
**  Give the field bag of the four types in the data of <type> that type;
**  once per field bag, right after making the types.
*/
static Obj FuncPACKMAT_SET_SIBLINGS(Obj self, Obj type)
{
    if (TNUM_OBJ(type) != T_POSOBJ ||
        SIZE_OBJ(type) <= POS_DATA_TYPE * sizeof(Obj) ||
        !IS_PLIST(DATA_TYPE(type)) || LEN_PLIST(DATA_TYPE(type)) != SIB_LEN)
        RequireArgumentEx(SELF_NAME, type, "<type>",
                          "must be a type with four packed types as data");
    Obj t = ELM_PLIST(DATA_TYPE(type), SIB_MAT);
    if (!t || TNUM_OBJ(t) != T_POSOBJ ||
        SIZE_OBJ(t) <= POS_DATA_TYPE * sizeof(Obj) ||
        !IsTypeData(DATA_TYPE(t)) ||
        !IS_SUBSET_FLAGS(FLAGS_TYPE(type),
                         FLAGS_FILT(IsKernelDataObjectRepFilt)))
        RequireArgumentEx(SELF_NAME, type, "<type>",
                          "must be a type with four packed types as data");
    Obj tdata = DATA_TYPE(t);
    Obj bag = ELM_PLIST(tdata, TDATA_FIELD);
    if (SiblingsOK(tdata))
        ErrorMayQuit("PACKMAT_SET_SIBLINGS: the types are set already", 0, 0);
    if (!SiblingTypesOK(tdata, type))
        RequireArgumentEx(SELF_NAME, type, "<type>",
                          "must be a type with four packed types as data");
    SetTypeDatObj(bag, type);
    return 0;
}

/****************************************************************************
**
*F  CheckField( <tdata> )
**
**  Check the field bag of <tdata> against the core's rules and against
**  One( base domain ), then stamp it; an error if it fails. Allocates
**  nothing, so callers may hold views.
*/
static void CheckField(Obj tdata)
{
    Obj             bag = ELM_PLIST(tdata, TDATA_FIELD);
    Obj             one = ELM_PLIST(tdata, TDATA_ONE);
    packmat_field * f = FIELD_OF_BAG(bag);

    // the size first, so that the checks below stay inside the bag
    const size_t fsize =
        f->ranked > 1 ? 0 : packmat_field_size((int)f->kind, f->n, f->ranked);
    if (fsize == 0 ||
        SIZE_OBJ(bag) !=
            FIELD_OFFSET + fsize + InverseSize(f->n, f->ranked) ||
        !packmat_field_check(f))
        goto bad;

    if (IS_FFE(one)) {
        const FF ff = FLD_FFE(one);
        if (CHAR_FF(ff) != f->n || DEGR_FF(ff) != 1 ||
            f->ranked != (f->kind != PACKMAT_GF2))
            goto bad;
        if (f->ranked) {
            const uint16_t * rank = packmat_field_rank(f);
            const uint16_t * inv = INVERSE(f);
            const FFV *      succ = SUCC_FF(ff);
            FFV              v = 0;
            for (uint64_t r = 0; r < f->n; r++) {
                if (rank[r] != v || inv[v] != r)
                    goto bad;
                v = SUM_FFV(v, 1, succ);
            }
        }
    }
    else if (f->ranked) {
        goto bad;
    }
    if (!SiblingsOK(tdata))
        goto bad;
    *STAMP_OF_BAG(bag) = Stamp;
    return;

bad:
    ErrorMayQuit("packed matrix: invalid field context", 0, 0);
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

static Obj FuncPACKMAT_MUTABLE_COPY(Obj self, Obj obj)
{
    const BOOL mat = RequirePackedObj(SELF_NAME, obj, "<obj>");
    return CopyAs(obj, ResultType(TDATA(obj), mat, TRUE));
}


/****************************************************************************
**
*F * * * * * * * * * * * * *  positions and ranges * * * * * * * * * * * * *
*/

static void RequireVec(const char * funcname, Obj obj, const char * argname)
{
    if (!IS_PACKED_VEC(obj))
        RequireArgumentEx(funcname, obj, argname, "must be a packed vector");
}

static void RequireMat(const char * funcname, Obj obj, const char * argname)
{
    if (!IS_PACKED_MAT(obj))
        RequireArgumentEx(funcname, obj, argname, "must be a packed matrix");
}

// The integer <from> of a search after position from, clamped to [0..max]
static UInt GetFrom(const char * funcname, Obj from, UInt max)
{
    if (IS_INTOBJ(from)) {
        const Int x = INT_INTOBJ(from);
        return x < 0 ? 0 : (UInt)x > max ? max : (UInt)x;
    }
    if (!IS_LARGEINT(from))
        RequireArgumentEx(funcname, from, "<from>", "must be an integer");
    return TNUM_OBJ(from) == T_INTNEG ? 0 : max;
}

// [<from>..<to>] as the half-open 0-based range [*lo, *hi); empty if
// from > to, else inside [1..len]
static void GetRange(const char * funcname,
                     Obj          from,
                     Obj          to,
                     UInt         len,
                     uint32_t *   lo,
                     uint32_t *   hi)
{
    if (!IS_INTOBJ(from))
        RequireArgumentEx(funcname, from, "<from>",
                          "must be a small integer");
    if (!IS_INTOBJ(to))
        RequireArgumentEx(funcname, to, "<to>", "must be a small integer");
    const Int f = INT_INTOBJ(from);
    const Int t = INT_INTOBJ(to);
    if (f > t) {
        *lo = *hi = 0;
        return;
    }
    if (f < 1 || (UInt)t > len)
        ErrorMayQuit("%s: [<from>..<to>] must lie in [1..Length(<v>)]",
                     (Int)funcname, 0);
    *lo = (uint32_t)(f - 1);
    *hi = (uint32_t)t;
}

// The positions of a list in [1..max], for the core: a range with step 1,
// or the 0-based positions in a kernel buffer, made before any view (D5)
typedef struct {
    Obj  buf;      // 0 for a range
    UInt first;    // 0-based start of a range
    UInt len;
} IndexList;

static inline uint32_t * INDICES(Obj buf)
{
    return (uint32_t *)(ADDR_OBJ(buf) + 1);
}

static const char ROWS_LIST_MSG[] = "must be a list of positions of rows";
static const char COLS_LIST_MSG[] = "must be a list of positions of columns";
static const char POSS_LIST_MSG[] =
    "must be a list of positions in [1..Length]";

static IndexList GetIndexList(const char * funcname,
                              Obj          list,
                              const char * argname,
                              UInt         max,
                              const char * msg)
{
    IndexList il = { 0, 0, 0 };
    if (IS_RANGE(list) &&
        (GET_LEN_RANGE(list) <= 1 || GET_INC_RANGE(list) == 1)) {
        const Int len = GET_LEN_RANGE(list);
        const Int low = GET_LOW_RANGE(list);
        if (len > 0 && (low < 1 || (UInt)(low - 1 + len) > max))
            RequireArgumentEx(funcname, list, argname, msg);
        il.first = len > 0 ? low - 1 : 0;
        il.len = len;
        return il;
    }
    if (!IS_LIST(list))
        RequireArgumentEx(funcname, list, argname, msg);
    const UInt len = LEN_LIST(list);
    if (len > MAX_DIM)
        RequireArgumentEx(funcname, list, argname, msg);
    il.buf = NewKernelBuffer(sizeof(Obj) + len * sizeof(uint32_t));
    il.len = len;
    // ELM0_LIST may run GAP code; INDICES is fetched for every entry
    for (UInt k = 0; k < len; k++) {
        Obj p =
            IS_PLIST(list) ? ELM_PLIST(list, k + 1) : ELM0_LIST(list, k + 1);
        if (!p || !IS_POS_INTOBJ(p) || (UInt)INT_INTOBJ(p) > max)
            RequireArgumentEx(funcname, list, argname, msg);
        INDICES(il.buf)[k] = (uint32_t)(INT_INTOBJ(p) - 1);
    }
    return il;
}

static inline packmat_index IndexView(IndexList il)
{
    if (!il.buf)
        return packmat_range((uint32_t)il.first, (uint32_t)il.len);
    return packmat_indices(INDICES(il.buf), (uint32_t)il.len);
}

// 0 if a and b have no index in common; exact for two ranges
static BOOL MayOverlap(IndexList a, IndexList b)
{
    if (a.len == 0 || b.len == 0)
        return FALSE;
    if (a.buf || b.buf)
        return TRUE;
    return a.first < b.first + b.len && b.first < a.first + a.len;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * *  arithmetic  * * * * * * * * * * * * * * * *
**
**  Results are immutable iff all operands are (R3 (a)); scalars count as
**  immutable.
*/

enum { RES_IMM, RES_MUT, RES_SAME };

static Obj SumDiff(const char * funcname, Obj a, Obj b, BOOL diff)
{
    const BOOL mat = RequireCompatible(funcname, a, b);
    Obj        res = NewLike(
        a, ResultType(TDATA(a), mat, IS_MUTABLE_OBJ(a) || IS_MUTABLE_OBJ(b)));
    if (diff)
        packmat_sub(VIEW(res, mat), VIEW(a, mat), VIEW(b, mat));
    else
        packmat_add(VIEW(res, mat), VIEW(a, mat), VIEW(b, mat));
    return res;
}

static Obj FuncPACKMAT_SUM(Obj self, Obj a, Obj b)
{
    return SumDiff("+", a, b, FALSE);
}

static Obj FuncPACKMAT_DIFF(Obj self, Obj a, Obj b)
{
    return SumDiff("-", a, b, TRUE);
}

// -obj, or zero if neg is FALSE, with mutability RES_*
static Obj NegOrZero(const char * funcname, Obj obj, int res, BOOL neg)
{
    const BOOL mat = RequirePackedObj(funcname, obj, "<obj>");
    const BOOL mut = res == RES_SAME ? IS_MUTABLE_OBJ(obj) : res == RES_MUT;
    Obj        r = NewLike(obj, ResultType(TDATA(obj), mat, mut));
    if (neg)
        packmat_neg(VIEW(r, mat), VIEW(obj, mat));
    return r;
}

static Obj FuncPACKMAT_AINV_MUT(Obj self, Obj obj)
{
    return NegOrZero("AdditiveInverseMutable", obj, RES_MUT, TRUE);
}

static Obj FuncPACKMAT_AINV_IMM(Obj self, Obj obj)
{
    return NegOrZero("AdditiveInverseImmutable", obj, RES_IMM, TRUE);
}

static Obj FuncPACKMAT_AINV_SAMEMUT(Obj self, Obj obj)
{
    return NegOrZero("AdditiveInverseSameMutability", obj, RES_SAME, TRUE);
}

static Obj FuncPACKMAT_ZERO_MUT(Obj self, Obj obj)
{
    return NegOrZero("ZeroMutable", obj, RES_MUT, FALSE);
}

static Obj FuncPACKMAT_ZERO_IMM(Obj self, Obj obj)
{
    return NegOrZero("ZeroImmutable", obj, RES_IMM, FALSE);
}

static Obj FuncPACKMAT_ZERO_SAMEMUT(Obj self, Obj obj)
{
    return NegOrZero("ZeroSameMutability", obj, RES_SAME, FALSE);
}

// s * obj = obj * s: the base domains are commutative. Other factors, such
// as list matrices, which are scalars too, go to the next method.
static Obj ProdScalar(Obj obj, Obj s)
{
    const BOOL mat = RequirePackedObj("*", obj, "<obj>");
    uint64_t   r;
    if (!ScalarResidueOrFail(TDATA(obj), s, &r))
        return TRY_NEXT_METHOD;
    Obj res = NewLike(obj, ResultType(TDATA(obj), mat, IS_MUTABLE_OBJ(obj)));
    packmat_scale(VIEW(res, mat), VIEW(obj, mat), r);
    return res;
}

static Obj FuncPACKMAT_PROD_SCALAR(Obj self, Obj obj, Obj s)
{
    return ProdScalar(obj, s);
}

static Obj FuncPACKMAT_PROD_SCALAR_LEFT(Obj self, Obj s, Obj obj)
{
    return ProdScalar(obj, s);
}

// AddMatrix( dst, src[, s] ), dst += s * src; s is Fail for 1
static void AddMatrix(Obj dst, Obj src, Obj s)
{
    RequireMat("AddMatrix", dst, "<dst>");
    RequireMutable("AddMatrix", dst, "matrix");
    RequireCompatible("AddMatrix", dst, src);
    const uint64_t r =
        s == Fail ? 1 : ScalarResidue("AddMatrix", TDATA(dst), s);
    if (r == 1)
        packmat_add(MAT_VIEW(dst), MAT_VIEW(dst), MAT_VIEW(src));
    else
        packmat_addmul(MAT_VIEW(dst), MAT_VIEW(src), r);
}

static Obj FuncPACKMAT_ADD_MATRIX(Obj self, Obj dst, Obj src)
{
    AddMatrix(dst, src, Fail);
    return 0;
}

static Obj FuncPACKMAT_ADD_MATRIX_MUL(Obj self, Obj dst, Obj src, Obj s)
{
    AddMatrix(dst, src, s);
    return 0;
}

// MultMatrixLeft( M, s ) and MultMatrixRight( M, s )
static Obj FuncPACKMAT_MULT_MATRIX(Obj self, Obj M, Obj s)
{
    RequireMat("MultMatrix", M, "<M>");
    RequireMutable("MultMatrix", M, "matrix");
    const uint64_t r = ScalarResidue("MultMatrix", TDATA(M), s);
    packmat_scale(MAT_VIEW(M), MAT_VIEW(M), r);
    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * *  vectors * * * * * * * * * * * * * * * * *
*/

// AddVector( dst, src[, s[, from, to]] ): dst += s * src; s is Fail for
// 1, from is 0 for the whole vector
static void AddVectorFull(Obj dst, Obj src, Obj s, Obj from, Obj to)
{
    const char * name = "AddVector";
    RequireVec(name, dst, "<dst>");
    RequireMutable(name, dst, "vector");
    RequireVec(name, src, "<src>");
    RequireSameContext(name, dst, src);
    const UInt len = CONST_DIMS(dst)[0];
    if (CONST_DIMS(src)[0] != len)
        ErrorMayQuit("AddVector: <dst> and <src> must have the same length",
                     0, 0);
    uint32_t lo = 0, hi = (uint32_t)len;
    if (from)
        GetRange(name, from, to, len, &lo, &hi);
    const uint64_t r = s == Fail ? 1 : ScalarResidue(name, TDATA(dst), s);
    if (lo == 0 && hi == len) {
        if (r == 1)
            packmat_add(VEC_VIEW(dst), VEC_VIEW(dst), VEC_VIEW(src));
        else
            packmat_addmul(VEC_VIEW(dst), VEC_VIEW(src), r);
        return;
    }
    packmat_vec_addmul(VEC_VIEW(dst), VEC_VIEW(src), r, lo, hi);
}

static Obj FuncPACKMAT_ADD_VECTOR(Obj self, Obj dst, Obj src)
{
    AddVectorFull(dst, src, Fail, 0, 0);
    return 0;
}

static Obj FuncPACKMAT_ADD_VECTOR_MUL(Obj self, Obj dst, Obj src, Obj s)
{
    AddVectorFull(dst, src, s, 0, 0);
    return 0;
}

static Obj FuncPACKMAT_ADD_VECTOR_MUL_LEFT(Obj self, Obj dst, Obj s, Obj src)
{
    AddVectorFull(dst, src, s, 0, 0);
    return 0;
}

static Obj FuncPACKMAT_ADD_VECTOR_RANGE(
    Obj self, Obj dst, Obj src, Obj s, Obj from, Obj to)
{
    AddVectorFull(dst, src, s, from, to);
    return 0;
}

static Obj FuncPACKMAT_ADD_VECTOR_RANGE_LEFT(
    Obj self, Obj dst, Obj s, Obj src, Obj from, Obj to)
{
    AddVectorFull(dst, src, s, from, to);
    return 0;
}

// MultVectorLeft/Right( v, s[, from, to] ); from is 0 for all of v
static void MultVectorFull(Obj v, Obj s, Obj from, Obj to)
{
    const char * name = "MultVector";
    RequireVec(name, v, "<v>");
    RequireMutable(name, v, "vector");
    const UInt len = CONST_DIMS(v)[0];
    uint32_t   lo = 0, hi = (uint32_t)len;
    if (from)
        GetRange(name, from, to, len, &lo, &hi);
    const uint64_t r = ScalarResidue(name, TDATA(v), s);
    if (lo == 0 && hi == len)
        packmat_scale(VEC_VIEW(v), VEC_VIEW(v), r);
    else
        packmat_vec_scale(VEC_VIEW(v), r, lo, hi);
}

static Obj FuncPACKMAT_MULT_VECTOR(Obj self, Obj v, Obj s)
{
    MultVectorFull(v, s, 0, 0);
    return 0;
}

static Obj
FuncPACKMAT_MULT_VECTOR_RANGE(Obj self, Obj v, Obj s, Obj from, Obj to)
{
    MultVectorFull(v, s, from, to);
    return 0;
}

static Obj FuncPACKMAT_SCALAR_PRODUCT(Obj self, Obj a, Obj b)
{
    RequireVec("ScalarProduct", a, "<a>");
    RequireCompatible("ScalarProduct", a, b);
    return EntryObj(TDATA(a), packmat_vec_dot(VEC_VIEW(a), VEC_VIEW(b)));
}

static Obj FuncPACKMAT_POSITION_NONZERO(Obj self, Obj v)
{
    RequirePackedVec(SELF_NAME, v);
    return ObjInt_UInt(packmat_vec_position_nonzero(VEC_VIEW(v), 0) + 1);
}

// the first nonzero entry after position <from>
static Obj FuncPACKMAT_POSITION_NONZERO_FROM(Obj self, Obj v, Obj from)
{
    RequirePackedVec(SELF_NAME, v);
    const UInt len = CONST_DIMS(v)[0];
    const UInt f = GetFrom("PositionNonZero", from, len);
    return ObjInt_UInt(
        packmat_vec_position_nonzero(VEC_VIEW(v), (uint32_t)f) + 1);
}

static Obj FuncPACKMAT_POSITION_LAST_NONZERO(Obj self, Obj v)
{
    RequirePackedVec(SELF_NAME, v);
    return ObjInt_UInt(packmat_vec_position_last_nonzero(VEC_VIEW(v)));
}

static Obj FuncPACKMAT_WEIGHT(Obj self, Obj v)
{
    RequirePackedVec(SELF_NAME, v);
    return ObjInt_UInt8(packmat_weight(VEC_VIEW(v)));
}

static Obj FuncPACKMAT_DISTANCE(Obj self, Obj a, Obj b)
{
    RequireVec("DistanceOfVectors", a, "<a>");
    RequireCompatible("DistanceOfVectors", a, b);
    return ObjInt_UInt8(packmat_distance(VEC_VIEW(a), VEC_VIEW(b)));
}

// v{l}: a new mutable vector
static Obj FuncPACKMAT_EXTRACT_SUB_VECTOR(Obj self, Obj v, Obj l)
{
    const char * name = "ExtractSubVector";
    RequireVec(name, v, "<v>");
    IndexList cols =
        GetIndexList(name, l, "<l>", CONST_DIMS(v)[0], POSS_LIST_MSG);
    Obj res = NewPackedVec(ResultType(TDATA(v), FALSE, TRUE), cols.len);
    packmat_extract_submatrix(VEC_VIEW(res), VEC_VIEW(v), packmat_range(0, 1),
                              IndexView(cols));
    return res;
}

// CopySubVector( src, dst, scols, dcols ): dst{dcols} := src{scols}
static Obj
FuncPACKMAT_COPY_SUB_VECTOR(Obj self, Obj src, Obj dst, Obj scols, Obj dcols)
{
    const char * name = "CopySubVector";
    RequireVec(name, src, "<src>");
    RequireVec(name, dst, "<dst>");
    RequireMutable(name, dst, "vector");
    if (TDATA(src) != TDATA(dst))
        ErrorMayQuit("CopySubVector: <src> and <dst> must have the same base "
                     "domain",
                     0, 0);
    IndexList sc = GetIndexList(name, scols, "<scols>", CONST_DIMS(src)[0],
                                POSS_LIST_MSG);
    IndexList dc = GetIndexList(name, dcols, "<dcols>", CONST_DIMS(dst)[0],
                                POSS_LIST_MSG);
    if (sc.len != dc.len)
        ErrorMayQuit(
            "CopySubVector: <scols> and <dcols> must have the same length", 0,
            0);
    if (src == dst && MayOverlap(sc, dc))
        src = CopyAs(src, TYPE_DATOBJ(src));
    packmat_copy_subvector(VEC_VIEW(dst), VEC_VIEW(src), IndexView(dc),
                           IndexView(sc));
    return 0;
}

// NormedRowVector( v ): v scaled so that its first nonzero entry is one
static Obj FuncPACKMAT_NORMED_VECTOR(Obj self, Obj v)
{
    RequirePackedVec(SELF_NAME, v);
    Obj res = CopyAs(v, ResultType(TDATA(v), FALSE, IS_MUTABLE_OBJ(v)));
    if (packmat_vec_normalize(VEC_VIEW(res)) == PACKMAT_NOT_UNIT)
        ErrorMayQuit("NormedRowVector: the first nonzero entry of <v> must "
                     "be invertible",
                     0, 0);
    return res;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * *  rows and columns  * * * * * * * * * * * * * *
*/

// Swaps; cols selects columns
static void Swap(const char * name, Obj M, Obj i, Obj j, BOOL cols)
{
    RequireMat(name, M, "<M>");
    RequireMutable(name, M, "matrix");
    const UInt   max = CONST_DIMS(M)[cols ? 1 : 0];
    const char * msg = cols ? COL_RANGE : ROW_RANGE;
    const UInt   a = GetIndex(name, i, "<i>", max, msg);
    const UInt   b = GetIndex(name, j, "<j>", max, msg);
    if (cols)
        packmat_swap_cols(MAT_VIEW(M), (uint32_t)a, (uint32_t)b);
    else
        packmat_swap_rows(MAT_VIEW(M), (uint32_t)a, (uint32_t)b);
}

static Obj FuncPACKMAT_SWAP_ROWS(Obj self, Obj M, Obj i, Obj j)
{
    Swap("SwapMatrixRows", M, i, j, FALSE);
    return 0;
}

static Obj FuncPACKMAT_SWAP_COLS(Obj self, Obj M, Obj i, Obj j)
{
    Swap("SwapMatrixColumns", M, i, j, TRUE);
    return 0;
}

// Row or column i *= s, or, with j, row or column i += s * row or column j
static void RowColOp(const char * name, Obj M, Obj i, Obj j, Obj s, BOOL cols)
{
    RequireMat(name, M, "<M>");
    RequireMutable(name, M, "matrix");
    const UInt     max = CONST_DIMS(M)[cols ? 1 : 0];
    const char *   msg = cols ? COL_RANGE : ROW_RANGE;
    const UInt     a = GetIndex(name, i, "<i>", max, msg);
    const UInt     b = j ? GetIndex(name, j, "<j>", max, msg) : 0;
    const uint64_t r = ScalarResidue(name, TDATA(M), s);
    if (!j && cols)
        packmat_mult_col(MAT_VIEW(M), (uint32_t)a, r);
    else if (!j)
        packmat_mult_row(MAT_VIEW(M), (uint32_t)a, r);
    else if (cols)
        packmat_add_cols(MAT_VIEW(M), (uint32_t)a, (uint32_t)b, r);
    else
        packmat_add_rows(MAT_VIEW(M), (uint32_t)a, (uint32_t)b, r);
}

static Obj FuncPACKMAT_MULT_ROW(Obj self, Obj M, Obj i, Obj s)
{
    RowColOp("MultMatrixRow", M, i, 0, s, FALSE);
    return 0;
}

static Obj FuncPACKMAT_MULT_COL(Obj self, Obj M, Obj i, Obj s)
{
    RowColOp("MultMatrixColumn", M, i, 0, s, TRUE);
    return 0;
}

static Obj FuncPACKMAT_ADD_ROWS(Obj self, Obj M, Obj i, Obj j, Obj s)
{
    RowColOp("AddMatrixRows", M, i, j, s, FALSE);
    return 0;
}

static Obj FuncPACKMAT_ADD_COLS(Obj self, Obj M, Obj i, Obj j, Obj s)
{
    RowColOp("AddMatrixColumns", M, i, j, s, TRUE);
    return 0;
}

// PositionNonZeroInRow( M, i[, from] ); from is 0 if not given
static Obj PositionNonZeroInRow(Obj M, Obj i, Obj from)
{
    const char * name = "PositionNonZeroInRow";
    RequireMat(name, M, "<M>");
    const uint32_t * d = CONST_DIMS(M);
    const UInt       a = GetIndex(name, i, "<i>", d[0], ROW_RANGE);
    const UInt       f = from ? GetFrom(name, from, d[1]) : 0;
    return ObjInt_UInt(packmat_position_nonzero_in_row(
                           MAT_VIEW(M), (uint32_t)a, (uint32_t)f) +
                       1);
}

static Obj FuncPACKMAT_POSITION_NONZERO_IN_ROW(Obj self, Obj M, Obj i)
{
    return PositionNonZeroInRow(M, i, 0);
}

static Obj
FuncPACKMAT_POSITION_NONZERO_IN_ROW_FROM(Obj self, Obj M, Obj i, Obj from)
{
    return PositionNonZeroInRow(M, i, from);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * sub-matrices, rows * * * * * * * * * * * * * *
*/

// M{rows}{cols}: a new mutable matrix
static Obj FuncPACKMAT_EXTRACT_SUB_MATRIX(Obj self, Obj M, Obj rows, Obj cols)
{
    const char * name = "ExtractSubMatrix";
    RequireMat(name, M, "<M>");
    IndexList r =
        GetIndexList(name, rows, "<rows>", CONST_DIMS(M)[0], ROWS_LIST_MSG);
    IndexList c =
        GetIndexList(name, cols, "<cols>", CONST_DIMS(M)[1], COLS_LIST_MSG);
    Obj res = NewPackedMat(ResultType(TDATA(M), TRUE, TRUE), r.len, c.len);
    packmat_extract_submatrix(MAT_VIEW(res), MAT_VIEW(M), IndexView(r),
                              IndexView(c));
    return res;
}

// CopySubMatrix( src, dst, srows, drows, scols, dcols )
static Obj FuncPACKMAT_COPY_SUB_MATRIX(
    Obj self, Obj src, Obj dst, Obj srows, Obj drows, Obj scols, Obj dcols)
{
    const char * name = "CopySubMatrix";
    RequireMat(name, src, "<src>");
    RequireMat(name, dst, "<dst>");
    RequireMutable(name, dst, "matrix");
    if (TDATA(src) != TDATA(dst))
        ErrorMayQuit("CopySubMatrix: <src> and <dst> must have the same base "
                     "domain",
                     0, 0);
    IndexList sr = GetIndexList(name, srows, "<srows>", CONST_DIMS(src)[0],
                                ROWS_LIST_MSG);
    IndexList dr = GetIndexList(name, drows, "<drows>", CONST_DIMS(dst)[0],
                                ROWS_LIST_MSG);
    IndexList sc = GetIndexList(name, scols, "<scols>", CONST_DIMS(src)[1],
                                COLS_LIST_MSG);
    IndexList dc = GetIndexList(name, dcols, "<dcols>", CONST_DIMS(dst)[1],
                                COLS_LIST_MSG);
    if (sr.len != dr.len)
        ErrorMayQuit("source and destination row lists must be of equal "
                     "length",
                     0, 0);
    if (sc.len != dc.len)
        ErrorMayQuit("source and destination column lists must be of equal "
                     "length",
                     0, 0);
    if (src == dst && MayOverlap(sr, dr) && MayOverlap(sc, dc))
        src = CopyAs(src, TYPE_DATOBJ(src));
    packmat_copy_submatrix(MAT_VIEW(dst), MAT_VIEW(src), IndexView(dr),
                           IndexView(sr), IndexView(dc), IndexView(sc));
    return 0;
}

// Row i of M as a new vector of type <type>
static Obj RowAsVector(Obj M, UInt i, Obj type)
{
    Obj v = NewPackedVec(type, CONST_DIMS(M)[1]);
    packmat_copy_row_to_vector(VEC_VIEW(v), MAT_VIEW(M), (uint32_t)i);
    return v;
}

// RowsOfMatrix( M ): an immutable list of immutable vectors
static Obj FuncPACKMAT_ROWS(Obj self, Obj M)
{
    RequirePackedMat(SELF_NAME, M);
    Obj        type = ResultType(TDATA(M), FALSE, FALSE);
    const UInt nr = CONST_DIMS(M)[0];
    Obj        list = NEW_PLIST_IMM(nr ? T_PLIST_DENSE : T_PLIST_EMPTY, nr);
    for (UInt i = 0; i < nr; i++) {
        Obj v = RowAsVector(M, i, type);
        SET_ELM_PLIST(list, i + 1, v);
        SET_LEN_PLIST(list, i + 1);
        CHANGED_BAG(list);
    }
    return list;
}

// RowOfMatrix( M, i ): row i of M as a new mutable vector (P1 (b))
static Obj FuncPACKMAT_ROW(Obj self, Obj M, Obj i)
{
    RequireMat("RowOfMatrix", M, "<M>");
    const UInt a =
        GetIndex("RowOfMatrix", i, "<i>", CONST_DIMS(M)[0], ROW_RANGE);
    return RowAsVector(M, a, ResultType(TDATA(M), FALSE, TRUE));
}

static Obj Transposed(Obj M, BOOL mut)
{
    RequirePackedMat("TransposedMat", M);
    const uint32_t * d = CONST_DIMS(M);
    Obj res = NewPackedMat(ResultType(TDATA(M), TRUE, mut), d[1], d[0]);
    packmat_transpose(MAT_VIEW(res), MAT_VIEW(M));
    return res;
}

static Obj FuncPACKMAT_TRANSPOSED_MUT(Obj self, Obj M)
{
    return Transposed(M, TRUE);
}

static Obj FuncPACKMAT_TRANSPOSED_IMM(Obj self, Obj M)
{
    return Transposed(M, FALSE);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * *  products  * * * * * * * * * * * * * * * *
**
**  The core polls for interrupts without clearing them: an interrupt is
**  pending while the statement executor is switched to IntrExecStatFuncs.
**  An interrupted product is discarded. TakeInterrupt then runs the break
**  loop; if the user returns from it, the product starts again. If no user
**  interrupt is pending (the memory limit, say), the product runs without
**  polls, and the interrupt fires at the next statement.
*/

static int PollInterrupt(void * data)
{
    return STATE(CurrExecStatFuncs) == IntrExecStatFuncs;
}

typedef int (*ProductFunc)(
    packmat_mat dst, packmat_mat a, packmat_mat b, packmat_poll, void *);

// res = a*b, with fn and the kinds of all three; dims of res as for NewPacked
static Obj Product(ProductFunc fn,
                   Obj         type,
                   BOOL        resmat,
                   UInt        d0,
                   UInt        d1,
                   Obj         a,
                   BOOL        amat,
                   Obj         b,
                   BOOL        bmat)
{
    packmat_poll poll = PollInterrupt;
    for (;;) {
        Obj res =
            resmat ? NewPackedMat(type, d0, d1) : NewPackedVec(type, d0);
        if (fn(VIEW(res, resmat), VIEW(a, amat), VIEW(b, bmat), poll, 0) !=
            PACKMAT_INTERRUPTED)
            return res;
        if (!TakeInterrupt())
            poll = 0;
    }
}

static BOOL MutableResult(Obj a, Obj b)
{
    return IS_MUTABLE_OBJ(a) || IS_MUTABLE_OBJ(b);
}

static Obj FuncPACKMAT_MAT_MUL(Obj self, Obj a, Obj b)
{
    RequireMat("*", a, "<a>");
    RequireMat("*", b, "<b>");
    RequireSameContext("*", a, b);
    const uint32_t * da = CONST_DIMS(a);
    const uint32_t * db = CONST_DIMS(b);
    if (da[1] != db[0])
        ErrorMayQuit("*: <a> must have as many columns as <b> has rows", 0,
                     0);
    return Product(packmat_mul,
                   ResultType(TDATA(a), TRUE, MutableResult(a, b)), TRUE,
                   da[0], db[1], a, TRUE, b, TRUE);
}

static Obj FuncPACKMAT_VEC_MUL_MAT(Obj self, Obj v, Obj M)
{
    RequireVec("*", v, "<v>");
    RequireMat("*", M, "<M>");
    RequireSameContext("*", v, M);
    if (CONST_DIMS(v)[0] != CONST_DIMS(M)[0])
        ErrorMayQuit("*: the length of <v> must be the number of rows of <M>",
                     0, 0);
    return Product(packmat_vec_mul_mat,
                   ResultType(TDATA(v), FALSE, MutableResult(v, M)), FALSE,
                   CONST_DIMS(M)[1], 0, v, FALSE, M, TRUE);
}

static Obj FuncPACKMAT_MAT_MUL_VEC(Obj self, Obj M, Obj v)
{
    RequireMat("*", M, "<M>");
    RequireVec("*", v, "<v>");
    RequireSameContext("*", M, v);
    if (CONST_DIMS(v)[0] != CONST_DIMS(M)[1])
        ErrorMayQuit(
            "*: the length of <v> must be the number of columns of <M>", 0,
            0);
    return Product(packmat_mat_mul_vec,
                   ResultType(TDATA(v), FALSE, MutableResult(M, v)), FALSE,
                   CONST_DIMS(M)[0], 0, M, TRUE, v, FALSE);
}

static Obj FuncPACKMAT_KRONECKER(Obj self, Obj a, Obj b)
{
    const char * name = "KroneckerProduct";
    RequireMat(name, a, "<a>");
    RequireMat(name, b, "<b>");
    RequireSameContext(name, a, b);
    const uint64_t nr = (uint64_t)CONST_DIMS(a)[0] * CONST_DIMS(b)[0];
    const uint64_t nc = (uint64_t)CONST_DIMS(a)[1] * CONST_DIMS(b)[1];
    if (nr > MAX_DIM || nc > MAX_DIM)
        ErrorMayQuit(
            "KroneckerProduct: the result has more than 2^32 - 1 rows "
            "or columns",
            0, 0);
    return Product(packmat_kronecker,
                   ResultType(TDATA(a), TRUE, MutableResult(a, b)), TRUE,
                   (UInt)nr, (UInt)nc, a, TRUE, b, TRUE);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * * Randomize  * * * * * * * * * * * * * * * *
**
**  The cells take k residues at a time from one random integer in
**  [0..n^k-1], its base-n digits; n^k < 2^28, so that the integers are small
**  on every platform, or k = 1.
*/

static const uint64_t RANDOM_BOUND = (uint64_t)1 << 28;

static UInt NrCells(Obj obj, BOOL mat)
{
    const uint32_t * d = CONST_DIMS(obj);
    return mat ? (UInt)d[0] * d[1] : d[0];
}

// [ k, n^k, number of integers needed ]
static Obj FuncPACKMAT_RANDOM_RANGE(Obj self, Obj obj)
{
    const BOOL     mat = RequirePackedObj(SELF_NAME, obj, "<obj>");
    const uint64_t n = FIELD(TDATA(obj))->n;
    UInt           k = 1;
    uint64_t       m = n;
    while (m <= (RANDOM_BOUND - 1) / n) {
        m *= n;
        k++;
    }
    const UInt cells = NrCells(obj, mat);
    Obj        res = NEW_PLIST(T_PLIST_CYC, 3);
    SET_LEN_PLIST(res, 3);
    SET_ELM_PLIST(res, 1, INTOBJ_INT(k));
    Obj mm = ObjInt_UInt8(m);
    SET_ELM_PLIST(res, 2, mm);
    SET_ELM_PLIST(res, 3, INTOBJ_INT((cells + k - 1) / k));
    CHANGED_BAG(res);
    return res;
}

// Set the cells of obj, row by row, to the base-n digits of the integers in
// list, k digits each, lowest first
static Obj FuncPACKMAT_SET_RANDOM(Obj self, Obj obj, Obj list, Obj k)
{
    const BOOL mat = RequirePackedObj(SELF_NAME, obj, "<obj>");
    RequireMutable(SELF_NAME, obj, "matrix or vector");
    RequirePlainList(SELF_NAME, list);
    const uint64_t n = FIELD(TDATA(obj))->n;
    const UInt     cells = NrCells(obj, mat);
    if (!IS_POS_INTOBJ(k) || (UInt)INT_INTOBJ(k) > 64)
        RequireArgumentEx(SELF_NAME, k, "<k>", "must be a positive integer");
    const UInt kk = INT_INTOBJ(k);
    uint64_t   m = 1;
    for (UInt t = 0; t < kk; t++) {
        if (m > UINT64_MAX / n)
            ErrorMayQuit("PACKMAT_SET_RANDOM: n^<k> must be below 2^64", 0,
                         0);
        m *= n;
    }
    if (LEN_PLIST(list) != (cells + kk - 1) / kk)
        ErrorMayQuit("PACKMAT_SET_RANDOM: <list> has the wrong length", 0, 0);

    // the views hold across the loop: nothing allocates
    const packmat_mat view = VIEW(obj, mat);
    const uint32_t    nc = mat ? view.ncols : 1;
    UInt              c = 0;
    for (UInt t = 1; t <= LEN_PLIST(list); t++) {
        Obj      x = ELM_PLIST(list, t);
        uint64_t r;
        if (x && IS_NONNEG_INTOBJ(x))
            r = INT_INTOBJ(x);
        else if (x && TNUM_OBJ(x) == T_INTPOS &&
                 SIZE_INT(x) * sizeof(UInt) <= sizeof(uint64_t))
            r = UInt8_ObjInt(x);
        else
            r = m;
        if (r >= m)
            ErrorMayQuit("PACKMAT_SET_RANDOM: <list> must contain integers "
                         "in [0..n^<k>-1]",
                         0, 0);
        for (UInt u = 0; u < kk && c < cells; u++, c++) {
            if (mat)
                packmat_mat_set(view, (uint32_t)(c / nc), (uint32_t)(c % nc),
                                r % n);
            else
                packmat_vec_set(view, (uint32_t)c, r % n);
            r /= n;
        }
    }
    return 0;
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
    GVAR_FUNC_1ARGS(PACKMAT_SET_SIBLINGS, type),
    GVAR_FUNC_1ARGS(PACKMAT_MUTABLE_COPY, obj),
    GVAR_FUNC_2ARGS(PACKMAT_SUM, a, b),
    GVAR_FUNC_2ARGS(PACKMAT_DIFF, a, b),
    GVAR_FUNC_1ARGS(PACKMAT_AINV_MUT, obj),
    GVAR_FUNC_1ARGS(PACKMAT_AINV_IMM, obj),
    GVAR_FUNC_1ARGS(PACKMAT_AINV_SAMEMUT, obj),
    GVAR_FUNC_1ARGS(PACKMAT_ZERO_MUT, obj),
    GVAR_FUNC_1ARGS(PACKMAT_ZERO_IMM, obj),
    GVAR_FUNC_1ARGS(PACKMAT_ZERO_SAMEMUT, obj),
    GVAR_FUNC_2ARGS(PACKMAT_PROD_SCALAR, obj, s),
    GVAR_FUNC_2ARGS(PACKMAT_PROD_SCALAR_LEFT, s, obj),
    GVAR_FUNC_2ARGS(PACKMAT_ADD_MATRIX, dst, src),
    GVAR_FUNC_3ARGS(PACKMAT_ADD_MATRIX_MUL, dst, src, s),
    GVAR_FUNC_2ARGS(PACKMAT_MULT_MATRIX, M, s),
    GVAR_FUNC_2ARGS(PACKMAT_ADD_VECTOR, dst, src),
    GVAR_FUNC_3ARGS(PACKMAT_ADD_VECTOR_MUL, dst, src, s),
    GVAR_FUNC_3ARGS(PACKMAT_ADD_VECTOR_MUL_LEFT, dst, s, src),
    GVAR_FUNC_5ARGS(PACKMAT_ADD_VECTOR_RANGE, dst, src, s, from, to),
    GVAR_FUNC_5ARGS(PACKMAT_ADD_VECTOR_RANGE_LEFT, dst, s, src, from, to),
    GVAR_FUNC_2ARGS(PACKMAT_MULT_VECTOR, v, s),
    GVAR_FUNC_4ARGS(PACKMAT_MULT_VECTOR_RANGE, v, s, from, to),
    GVAR_FUNC_2ARGS(PACKMAT_SCALAR_PRODUCT, a, b),
    GVAR_FUNC_1ARGS(PACKMAT_POSITION_NONZERO, v),
    GVAR_FUNC_2ARGS(PACKMAT_POSITION_NONZERO_FROM, v, from),
    GVAR_FUNC_1ARGS(PACKMAT_POSITION_LAST_NONZERO, v),
    GVAR_FUNC_1ARGS(PACKMAT_WEIGHT, v),
    GVAR_FUNC_2ARGS(PACKMAT_DISTANCE, a, b),
    GVAR_FUNC_2ARGS(PACKMAT_EXTRACT_SUB_VECTOR, v, l),
    GVAR_FUNC_4ARGS(PACKMAT_COPY_SUB_VECTOR, src, dst, scols, dcols),
    GVAR_FUNC_1ARGS(PACKMAT_NORMED_VECTOR, v),
    GVAR_FUNC_3ARGS(PACKMAT_SWAP_ROWS, M, i, j),
    GVAR_FUNC_3ARGS(PACKMAT_SWAP_COLS, M, i, j),
    GVAR_FUNC_3ARGS(PACKMAT_MULT_ROW, M, i, s),
    GVAR_FUNC_3ARGS(PACKMAT_MULT_COL, M, i, s),
    GVAR_FUNC_4ARGS(PACKMAT_ADD_ROWS, M, i, j, s),
    GVAR_FUNC_4ARGS(PACKMAT_ADD_COLS, M, i, j, s),
    GVAR_FUNC_2ARGS(PACKMAT_POSITION_NONZERO_IN_ROW, M, i),
    GVAR_FUNC_3ARGS(PACKMAT_POSITION_NONZERO_IN_ROW_FROM, M, i, from),
    GVAR_FUNC_3ARGS(PACKMAT_EXTRACT_SUB_MATRIX, M, rows, cols),
    GVAR_FUNC_6ARGS(
        PACKMAT_COPY_SUB_MATRIX, src, dst, srows, drows, scols, dcols),
    GVAR_FUNC_1ARGS(PACKMAT_ROWS, M),
    GVAR_FUNC_2ARGS(PACKMAT_ROW, M, i),
    GVAR_FUNC_1ARGS(PACKMAT_TRANSPOSED_MUT, M),
    GVAR_FUNC_1ARGS(PACKMAT_TRANSPOSED_IMM, M),
    GVAR_FUNC_2ARGS(PACKMAT_MAT_MUL, a, b),
    GVAR_FUNC_2ARGS(PACKMAT_VEC_MUL_MAT, v, M),
    GVAR_FUNC_2ARGS(PACKMAT_MAT_MUL_VEC, M, v),
    GVAR_FUNC_2ARGS(PACKMAT_KRONECKER, a, b),
    GVAR_FUNC_1ARGS(PACKMAT_RANDOM_RANGE, obj),
    GVAR_FUNC_3ARGS(PACKMAT_SET_RANDOM, obj, list, k),
    { 0, 0, 0, 0, 0 }

};

static Int InitKernel(StructInitInfo * module)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    ImportFuncFromLibrary("IsPackedMatrixRep", &IsPackedMatrixRepFilt);
    ImportFuncFromLibrary("IsPackedVectorRep", &IsPackedVectorRepFilt);
    ImportFuncFromLibrary("PACKMAT_EntryResidue", &PackmatEntryResidueFunc);
    ImportFuncFromLibrary("IsKernelDataObjectRep",
                          &IsKernelDataObjectRepFilt);
    ImportFuncFromLibrary("IsMutable", &IsMutableFilt);
    InitGlobalBag(&GenerationObj, "src/packmat.c:GenerationObj");
    return 0;
}

static Int InitLibrary(StructInitInfo * module)
{
    InitGVarFuncsFromTable(GVarFuncs);
    GenerationObj = INTOBJ_INT(1);
    Stamp = STAMP_MAGIC ^ 1;
    return 0;
}

// Field bags from the workspace carry the stamp of an older session
static Int PostRestore(StructInitInfo * module)
{
    const Int g =
        IS_INTOBJ(GenerationObj) ? INT_INTOBJ(GenerationObj) + 1 : 2;
    GenerationObj = INTOBJ_INT(g);
    Stamp = STAMP_MAGIC ^ (uint64_t)g;
    return 0;
}

static StructInitInfo module = {
    .type = MODULE_BUILTIN,
    .name = "packmat",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore,
};

StructInitInfo * InitInfoPackmat(void)
{
    return &module;
}
