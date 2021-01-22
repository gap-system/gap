/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "vecgf2.h"

#include "ariths.h"
#include "bits_intern.h"
#include "blister.h"
#include "bool.h"
#include "error.h"
#include "finfield.h"
#include "gvars.h"
#include "integer.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "precord.h"
#include "range.h"
#include "records.h"
#include "stats.h"
#include "vec8bit.h"

#include <gmp.h>


/****************************************************************************
**
*F * * * * * * * * * * * imported library variables * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  TYPE_LIST_GF2VEC  . . . . . . . . . . . . . . type of a GF2 vector object
*/
Obj TYPE_LIST_GF2VEC;


/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_LOCKED. . . .  type of a mutable GF2 vector object
**                                          with locked representation
*/
Obj TYPE_LIST_GF2VEC_LOCKED;


/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_IMM  . . . . . .  type of an immutable GF2 vector object
*/
Obj TYPE_LIST_GF2VEC_IMM;

/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_IMM_LOCKED . . .  type of an immutable GF2 vector object
**                                          with locked representation
*/
Obj TYPE_LIST_GF2VEC_IMM_LOCKED;


/****************************************************************************
**
*V  TYPE_LIST_GF2MAT  . . . . . . . . . . . . . . type of a GF2 matrix object
*/
Obj TYPE_LIST_GF2MAT;


/****************************************************************************
**
*V  TYPE_LIST_GF2MAT_IMM  . . . . . .  type of an immutable GF2 matrix object
*/
Obj TYPE_LIST_GF2MAT_IMM;


/****************************************************************************
**
*V  IsGF2VectorRep  . . . . . . . . . . . . . . . . . . . . . . . . .  filter
*/
Obj IsGF2VectorRep;


/****************************************************************************
**
*V  GF2One  . . . . . . . . . . . . . . . . . . . . . . . . . . .  one of GF2
*/
static Obj GF2One;


/****************************************************************************
**
*V  GF2Zero . . . . . . . . . . . . . . . . . . . . . . . . . . . zero of GF2
*/
static Obj GF2Zero;


/****************************************************************************
**
*F * * * * * * * * * * * * arithmetic operations  * * * * * * * * * * * * * *
*/

static inline void AddGF2VecToGF2Vec(UInt * ptS, const UInt * ptV, UInt len)
{
    register UInt ct;
    ct = (len + BIPEB - 1) / BIPEB;
    while (ct--) {
        *ptS++ ^= *ptV++;
    }
}

/****************************************************************************
**
*F  AddCoeffsGF2VecGF2Vec( <sum>, <vec> ) . . . . . . . .  add <vec> to <sum>
**
**  `AddCoeffsGF2VecGF2Vec' adds  the   entries of <vec>  to <sum>.    If the
**  length  are not equal the  missing entries are  assumed  to be zero.  The
**  position of the rightmost Z(2) is returned.
*/

static UInt RightMostOneGF2Vec(Obj vec)
{
    UInt len;

    len = LEN_GF2VEC(vec);
    while (0 < len) {
        if (CONST_BLOCK_ELM_GF2VEC(vec, len) == 0)
            len = BIPEB * ((len - 1) / BIPEB);
        else if (BLOCK_ELM_GF2VEC(vec, len) & MASK_POS_GF2VEC(len))
            break;
        else
            len--;
    }
    return len;
}


static Obj AddCoeffsGF2VecGF2Vec(Obj sum, Obj vec)
{
    UInt *       ptS;
    const UInt * ptV;
    UInt         len;

    // get the length
    len = LEN_GF2VEC(vec);

    // grow <sum> is necessary
    if (LEN_GF2VEC(sum) < len) {
        ResizeWordSizedBag(sum, SIZE_PLEN_GF2VEC(len));
        SET_LEN_GF2VEC(sum, len);
    }

    // add <vec> to <sum>
    ptS = BLOCKS_GF2VEC(sum);
    ptV = CONST_BLOCKS_GF2VEC(vec);
    AddGF2VecToGF2Vec(ptS, ptV, len);
    return INTOBJ_INT(RightMostOneGF2Vec(sum));
}


static inline void
CopySection_GF2Vecs(Obj src, Obj dest, UInt smin, UInt dmin, UInt nelts)
{
    UInt         soff;
    UInt         doff;
    const UInt * sptr;
    UInt *       dptr;

    // switch to zero-based indices and find the first blocks and so on
    soff = (smin - 1) % BIPEB;
    doff = (dmin - 1) % BIPEB;
    sptr = CONST_BLOCKS_GF2VEC(src) + (smin - 1) / BIPEB;
    dptr = BLOCKS_GF2VEC(dest) + (dmin - 1) / BIPEB;

    CopyBits(sptr, soff, dptr, doff, nelts);
    return;
}

/****************************************************************************
**
*F  AddPartialGF2VecGF2Vec( <sum>, <vl>, <vr>, <n> )  . . . . . . partial sum
**
**  'AddPartialGF2VecGF2Vec' adds the entries  of <vl> and <vr> starting from
**  that block which is corresponding to the entry with number <n> and stores
**  the result in <sum>.
**
**  Note: The other entries are set to be zero. So use a higher value for <n>
**        only for vectors, which both have leading zero-entries.
**
**  You  can use  the parameter  <n> for  example for  an  gauss-algorithm on
**  gf2-matrices  can be  improved,  because when  using the gauss-algorithm,
**  you  know that  the leading entries of two vectors to be  added are equal
**  zero. If <n> = 1 all entries are added.
**
**  Note that the caller has to ensure, that <sum> is a gf2-vector with the
**  correct size.
*/
static Obj AddPartialGF2VecGF2Vec(Obj sum, Obj vl, Obj vr, UInt n)
{
    const UInt * ptL;       // bit field of <vl>
    const UInt * ptR;       // bit field of <vr>
    UInt *       ptS;       // bit field of <sum>
    UInt *       end;       // end marker
    UInt         len;       // length of the list
    UInt         offset;    // number of block to start adding
    UInt         x;


    // both operands lie in the same field
    len = LEN_GF2VEC(vl);
    if (len != LEN_GF2VEC(vr)) {
        ErrorMayQuit("Vector +: vectors must have the same length", 0, 0);
    }


    // calculate the offset for adding
    if (n == 1) {
        ptL = CONST_BLOCKS_GF2VEC(vl);
        ptR = CONST_BLOCKS_GF2VEC(vr);
        ptS = BLOCKS_GF2VEC(sum);
        end = ptS + ((len + BIPEB - 1) / BIPEB);
    }
    else {
        offset = (n - 1) / BIPEB;
        ptL = CONST_BLOCKS_GF2VEC(vl) + offset;
        ptR = CONST_BLOCKS_GF2VEC(vr) + offset;
        ptS = BLOCKS_GF2VEC(sum) + offset;
        end = ptS + ((len + BIPEB - 1) / BIPEB) - offset;
    }

    // loop over the entries and add
    if (vl == sum)
        while (ptS < end) {
            // maybe remove this condition
            if ((x = *ptR) != 0)
                *ptS = *ptL ^ x;
            ptL++;
            ptS++;
            ptR++;
        }
    else if (vr == sum)
        while (ptS < end) {
            // maybe remove this condition
            if ((x = *ptL) != 0)
                *ptS = *ptR ^ x;
            ptL++;
            ptS++;
            ptR++;
        }
    else
        while (ptS < end)
            *ptS++ = *ptL++ ^ *ptR++;

    return sum;
}


/****************************************************************************
**
*F  ProdGF2VecGF2Vec( <vl>, <vr> )  . . . . . . .  product of two GF2 vectors
**
**  'ProdVecGF2VecGF2' returns  the product of  the two GF2 vectors <vl> and
**  <vr>.   The product is  the folded sum of   the corresponding entries of
**  <vl> and <vr>.
**
**  'ProdVecGF2VecGF2' is an improved  version of the general multiplication,
**  which  does not  call 'PROD'  but uses bit  operations instead.   It will
**  always return either 'GF2One' or 'GF2Zero'.
*/
#ifdef SYS_IS_64_BIT

#define PARITY_BLOCK(m)                                                      \
    do {                                                                     \
        m = m ^ (m >> 32);                                                   \
        m = m ^ (m >> 16);                                                   \
        m = m ^ (m >> 8);                                                    \
        m = m ^ (m >> 4);                                                    \
        m = m ^ (m >> 2);                                                    \
        m = m ^ (m >> 1);                                                    \
    } while (0)

#else

#define PARITY_BLOCK(m)                                                      \
    do {                                                                     \
        m = m ^ (m >> 16);                                                   \
        m = m ^ (m >> 8);                                                    \
        m = m ^ (m >> 4);                                                    \
        m = m ^ (m >> 2);                                                    \
        m = m ^ (m >> 1);                                                    \
    } while (0)

#endif

static Obj ProdGF2VecGF2Vec(Obj vl, Obj vr)
{
    const UInt * ptL;     // bit field of <vl>
    const UInt * ptR;     // bit field of <vr>
    UInt         lenL;    // length of the list
    UInt         lenR;    // length of the list
    UInt         len;     // minimum of the lengths
    UInt         nrb;     // number of whole blocks to use
    UInt         m;       // number of bits in a block
    UInt         n;       // number of bits in blist
    UInt         i;       // loop variable
    UInt         mask;    // bit selecting mask

    // both operands lie in the same field
    lenL = LEN_GF2VEC(vl);
    lenR = LEN_GF2VEC(vr);
    len = (lenL < lenR) ? lenL : lenR;

    if (len == 0) {
        ErrorMayQuit("Vector *: both vectors must have at least one entry",
                     (Int)0, (Int)0);
    }

    // loop over the entries and multiply
    ptL = CONST_BLOCKS_GF2VEC(vl);
    ptR = CONST_BLOCKS_GF2VEC(vr);
    nrb = len / BIPEB;
    n = 0;
    for (i = nrb; i > 0; i--) {
        m = (*ptL++) & (*ptR++);
        PARITY_BLOCK(m);
        n ^= m;
    }
    // now process the remaining bits

    mask = 1;
    for (i = 0; i < len % BIPEB; i++) {
        n ^= (mask & *ptL & *ptR) >> i;
        mask <<= 1;
    }

    return (n & 1) ? GF2One : GF2Zero;
}


/****************************************************************************
**
*F  ProdGF2VecGF2Mat( <vl>, <vr> )  . .  product of GF2 vector and GF2 matrix
**
**  'ProdGF2VecGF2Mat'  returns the product  of the  GF2 vector <vl>  and the
**  GF2 matrix  <vr>.   The product is   the sum of  the  rows of <vr>,  each
**  multiplied by the corresponding entry of <vl>.  Note that the  caller has
**  to ensure, that <vl> is a gf2-vector and <vr> is a gf2-matrix.
*/
static Obj ProdGF2VecGF2Mat(Obj vl, Obj vr)
{
    UInt         len;    // length of the list
    UInt         stop;
    UInt         col;     // length of the rows
    UInt         i;       // loop variables
    Obj          prod;    // product, result
    Obj          row1;    // top row of matrix
    UInt *       start;
    const UInt * ptL;
    UInt         mask;

    // both operands lie in the same field
    len = LEN_GF2VEC(vl);
    if (len > LEN_GF2MAT(vr))
        len = LEN_GF2MAT(vr);

    // make the result vector
    row1 = ELM_GF2MAT(vr, 1);
    col = LEN_GF2VEC(row1);
    NEW_GF2VEC(prod,
               (IS_MUTABLE_OBJ(vl) || IS_MUTABLE_OBJ(row1))
                   ? TYPE_LIST_GF2VEC
                   : TYPE_LIST_GF2VEC_IMM,
               col);

    // get the start and end block
    start = BLOCKS_GF2VEC(prod);
    ptL = CONST_BLOCKS_GF2VEC(vl);

    // loop over the vector
    for (i = 1; i <= len; ptL++) {

        // if the whole block is zero, get the next entry
        if (*ptL == 0) {
            i += BIPEB;
            continue;
        }

        // run through the block
        stop = i + BIPEB - 1;
        if (len < stop)
            stop = len;
        for (mask = 1; i <= stop; i++, mask <<= 1) {

            // if there is entry add the row to the result
            if ((*ptL & mask) != 0) {
                const UInt * ptRR = CONST_BLOCKS_GF2VEC(ELM_GF2MAT(vr, i));
                AddGF2VecToGF2Vec(start, ptRR, col);
            }
        }
    }

    return prod;
}


/****************************************************************************
**
*F  ProdGF2MatGF2Vec( <ml>, <vr> )  . .  product of GF2 matrix and GF2 vector
**
**  'ProdGF2MatGF2Vec'  returns the product  of the  GF2 matrix <ml>  and the
**  GF2 vector  <vr>.   The ith entry of the
**  product is the inner product of  the  ith row of <ml> with <vr>.
**  Note that the  caller has
**  to ensure, that <ml> is a GF2 matrix and <vr> is a GF2 vector.
*/
static Obj ProdGF2MatGF2Vec(Obj ml, Obj vr)
{
    UInt         len;     // length of the vector
    UInt         ln1;     // length of the rows of the mx
    UInt         ln2;     // length of the matrix
    const UInt * ptL;     // bit field of <ml>[j]
    const UInt * ptR;     // bit field of <vr>
    UInt         nrb;     // number of blocks in blist
    UInt         m;       // number of bits in a block
    UInt         n;       // number of bits in blist
    UInt         i;       // loop variable
    UInt         j;       // loop variable
    Obj          prod;    // result
    UInt         mask;    // a one bit mask

    // both operands lie in the same field
    len = LEN_GF2VEC(vr);
    ln2 = LEN_GF2MAT(ml);
    if (0 == ln2) {
        ErrorMayQuit("PROD: empty GF2 matrix * GF2 vector not allowed", 0, 0);
    }

    ln1 = LEN_GF2VEC(ELM_GF2MAT(ml, 1));
    if (len > ln1) {
        len = ln1;
    }

    // make the result vector
    NEW_GF2VEC(prod,
               (IS_MUTABLE_OBJ(ELM_GF2MAT(ml, 1)) || IS_MUTABLE_OBJ(vr))
                   ? TYPE_LIST_GF2VEC
                   : TYPE_LIST_GF2VEC_IMM,
               ln2);

    // loop over the entries and multiply
    nrb = len / BIPEB;
    for (j = 1; j <= ln2; j++) {
        ptL = CONST_BLOCKS_GF2VEC(ELM_GF2MAT(ml, j));
        ptR = CONST_BLOCKS_GF2VEC(vr);
        n = 0;
        for (i = 1; i <= nrb; i++) {
            m = (*ptL++) & (*ptR++);
            PARITY_BLOCK(m);
            n ^= m;
        }

        mask = 1;
        for (i = 0; i < len % BIPEB; i++) {
            n ^= (mask & *ptL & *ptR) >> i;
            mask <<= 1;
        }


        if (n & 1)
            BLOCK_ELM_GF2VEC(prod, j) |= MASK_POS_GF2VEC(j);
    }

    return prod;
}

/****************************************************************************
**
*F  ProdGF2MatGF2MatSimple( <ml>, <mr> ) . . . .  product of two GF2 matrices
*F  ProdGF2MatGF2MatAdvanced( <ml>, <mr>, <greaselevel>, <blocksize> )
**                                     . .  product of twp GF2 matrices
**
**  'ProdGF2MatGF2MatSimple' returns the product of the GF2 matrix <ml> and
**  the GF2 matrix <mr>. This simply calls ProdGF2VecGF2Mat once on each row.
**
**  ProdGF2MatGF2MatAdvanced uses the specified grease and blocking to
**  accelerate larger matrix multiplies. In this case, the matrix dimensions
**  must be compatible.
*/

static Obj ProdGF2MatGF2MatSimple(Obj ml, Obj mr)
{
    Obj  prod;
    UInt i;
    UInt len;
    Obj  row;
    Obj  rtype;
    len = LEN_GF2MAT(ml);
    prod = NewBag(T_POSOBJ, SIZE_PLEN_GF2MAT(len));
    SET_LEN_GF2MAT(prod, len);
    if (IS_MUTABLE_OBJ(ml) || IS_MUTABLE_OBJ(mr)) {
        SET_TYPE_POSOBJ(prod, TYPE_LIST_GF2MAT);
        if (IS_MUTABLE_OBJ(ELM_GF2MAT(ml, 1)) ||
            IS_MUTABLE_OBJ(ELM_GF2MAT(mr, 1)))
            rtype = TYPE_LIST_GF2VEC_LOCKED;
        else
            rtype = TYPE_LIST_GF2VEC_IMM_LOCKED;
    }
    else {
        SET_TYPE_POSOBJ(prod, TYPE_LIST_GF2MAT_IMM);
        rtype = TYPE_LIST_GF2VEC_IMM_LOCKED;
    }
    for (i = 1; i <= len; i++) {
        row = ProdGF2VecGF2Mat(ELM_GF2MAT(ml, i), mr);

        // Since I'm going to put this vector into a matrix, I must lock its
        // representation, so that it doesn't get rewritten over GF(2^k)
        SetTypeDatObj(row, rtype);
        SET_ELM_GF2MAT(prod, i, row);
        CHANGED_BAG(prod);
        TakeInterrupt();
    }
    return prod;
}


// Utility functions for the advanced matrix multiply code below


// extract nbits bits starting from position from in vector vptr
// return them as the nbits least significant bits in a UInt.
// Bits are always numbered least-significant first

static inline UInt getbits(const UInt * vptr, UInt from, UInt nbits)
{
    UInt wno = (from - 1) / BIPEB;
    UInt word1 = vptr[wno];
    UInt shift1 = (from - 1) % BIPEB;
    UInt lbit = shift1 + nbits;
    UInt word2;
    if (lbit <= BIPEB) {
        // range is all in one word
        word1 <<= BIPEB - lbit;
        word1 >>= BIPEB - nbits;
    }
    else {
        // range is split across two words
        word1 >>= shift1;
        lbit -= BIPEB;
        word2 = vptr[wno + 1];
        word2 <<= BIPEB - lbit;
        word2 >>= shift1 - lbit;
        word1 |= word2;
    }
    return word1;
}

// To avoid having a lot of arguments to the recursive getgreasedata function,
// we put the things that don't change in the recursive call into this
// structure

struct greaseinfo {
    UInt *        pgtags;
    UInt *        pgbuf;
    UInt          nblocks;
    UInt *        pgrules;
    const UInt ** prrows;
};


// Make if necessary the grease row for bits controlled by the data in g.
// Recursive so can't be inlined
static const UInt * getgreasedata(struct greaseinfo * g, UInt bits)
{
    UInt         x, y;
    const UInt * ps;
    UInt *       pd;
    const UInt * ps2;
    UInt         i;
    UInt *       pd1;
    switch (g->pgtags[bits]) {
    case 0:
        // Need to make the row
        x = g->pgrules[bits];
        y = bits ^ (1 << x);
        // make it by adding row x to grease vector indexed y
        ps = g->prrows[x];
        ps2 = getgreasedata(g, y);
        pd1 = g->pgbuf + (bits - 3) * g->nblocks;
        pd = pd1;
        // time critical inner loop
        for (i = g->nblocks; i > 0; i--)
            *pd++ = *ps++ ^ *ps2++;
        // record that we made it
        g->pgtags[bits] = 1;
        return pd1;

    case 1:
        // we've made this one already, so just return it
        return g->pgbuf + (bits - 3) * g->nblocks;

    case 2:
        // This one does not need making, bits actually
        // has just a single 1 bit in it
        return g->prrows[g->pgrules[bits]];
    }
    return (UInt *)0;    // can't actually get here; include the return to
                         // pacify compiler
}


static Obj
ProdGF2MatGF2MatAdvanced(Obj ml, Obj mr, UInt greasesize, UInt blocksize)
{
    Obj          prod;          // Product Matrix
    UInt         i, j, k, b;    // Loop counters
    UInt         gs;            // Actual level of grease for current block
    const UInt * rptr;          // Pointer to current row of ml
    UInt bits;    // current chunk of current row, for lookup in grease tables
    const UInt * v;          // pointer to computed grease vector
    UInt len, rlen, ilen;    // len = length of ml, ilen = row length of ml =
                             // length of mr, rlen = row length of mr
    Obj    row;    // current row of ml, or row of prod when it is being built
    Obj    rtype;              // type of rows of prod
    Obj    gbuf = (Obj)0;      // grease buffer
    Obj    gtags = (Obj)0;     // grease tags (whether that row is known yet
    Obj    grules = (Obj)0;    // rules for making new grease vectors
    UInt * pgrules;            // pointer to contents of grules
    UInt * pgtags = (UInt *)0;     // pointer to contents of gtags
    UInt * pgbuf = (UInt *)0;      // pointer to grease buffer
    UInt   nwords;                 // number of words in a row of mr
    UInt   glen;                   // 1 << greasesize
    UInt   bs;                     // actual size of current block
    UInt * pprow;                  // pointer into current row of prod
    Obj    lrowptrs;               // cache of direct pointers to rows of ml
    const UInt **     plrows;      // and a direct pointer to that cache
    Obj               rrowptrs;    // and for mr
    const UInt **     prrows;
    Obj               prowptrs;    // and for prod
    UInt **           pprows;
    struct greaseinfo g;

    len = LEN_GF2MAT(ml);
    row = ELM_GF2MAT(mr, 1);
    rlen = LEN_GF2VEC(row);
    ilen = LEN_GF2MAT(mr);
    nwords = NUMBER_BLOCKS_GF2VEC(row);

    // Make a zero product matrix
    prod = NewBag(T_POSOBJ, SIZE_PLEN_GF2MAT(len));
    SET_LEN_GF2MAT(prod, len);
    if (IS_MUTABLE_OBJ(ml) || IS_MUTABLE_OBJ(mr)) {
        SET_TYPE_POSOBJ(prod, TYPE_LIST_GF2MAT);
        if (IS_MUTABLE_OBJ(ELM_GF2MAT(ml, 1)) ||
            IS_MUTABLE_OBJ(ELM_GF2MAT(mr, 1)))
            rtype = TYPE_LIST_GF2VEC_LOCKED;
        else
            rtype = TYPE_LIST_GF2VEC_IMM_LOCKED;
    }
    else {
        SET_TYPE_POSOBJ(prod, TYPE_LIST_GF2MAT_IMM);
        rtype = TYPE_LIST_GF2VEC_IMM_LOCKED;
    }


    for (i = 1; i <= len; i++) {
        NEW_GF2VEC(row, rtype, rlen);
        SET_ELM_GF2MAT(prod, i, row);
        CHANGED_BAG(prod);
    }

    // Cap greasesize and blocksize by the actual length
    if (ilen < greasesize)
        greasesize = ilen;
    if (ilen < greasesize * blocksize)
        blocksize = (ilen + greasesize - 1) / greasesize;


    // calculate glen
    glen = 1 << greasesize;

    // Allocate memory

    lrowptrs = NewBag(T_DATOBJ, sizeof(UInt *) * len);
    rrowptrs = NewBag(T_DATOBJ, sizeof(UInt *) * ilen);
    prowptrs = NewBag(T_DATOBJ, sizeof(UInt *) * len);

    if (greasesize >= 2) {
        gbuf =
            NewBag(T_DATOBJ, sizeof(UInt) * nwords * (glen - 3) * blocksize);
        gtags = NewBag(T_DATOBJ, sizeof(UInt) * glen * blocksize);
        grules = NewBag(T_DATOBJ, sizeof(Int) * glen);


        // From here no garbage collections

        pgtags = (UInt *)ADDR_OBJ(gtags);
        pgrules = (UInt *)ADDR_OBJ(grules);
        pgbuf = (UInt *)ADDR_OBJ(gbuf);


        // Calculate the greasing rules
        for (j = 3; j < glen; j++)
            for (i = 0; i < greasesize; i++)
                if ((j & (1 << i)) != 0) {
                    pgrules[j] = i;
                    break;
                }
        for (j = 0; j < greasesize; j++)
            pgrules[1 << j] = j;

        // fill in some more bits of g
        g.pgrules = pgrules;
        g.nblocks = nwords;
    }

    // Take direct pointers to all the parts of all the matrices to avoid
    // multiple indirection overheads
    plrows = (const UInt **)ADDR_OBJ(lrowptrs);
    prrows = (const UInt **)ADDR_OBJ(rrowptrs);
    pprows = (UInt **)ADDR_OBJ(prowptrs);

    for (i = 0; i < len; i++) {
        plrows[i] = CONST_BLOCKS_GF2VEC(ELM_GF2MAT(ml, i + 1));
        pprows[i] = BLOCKS_GF2VEC(ELM_GF2MAT(prod, i + 1));
    }
    for (i = 0; i < ilen; i++)
        prrows[i] = CONST_BLOCKS_GF2VEC(ELM_GF2MAT(mr, i + 1));


    // OK, finally ready to start work
    // loop over blocks
    for (b = 1; b <= ilen; b += blocksize * greasesize) {
        // last block may be a small one
        bs = blocksize;
        if ((b + bs * greasesize) > ilen)
            bs = (ilen - b + greasesize) / greasesize;

        // If we're greasing, start afresh
        if (greasesize > 1) {
            for (k = 0; k < bs; k++) {
                for (j = 0; j < 1 << greasesize; j++)
                    pgtags[k * glen + j] = 0;
                // powers of 2 correspond to rows of mr
                for (j = 0; j < greasesize; j++)
                    pgtags[k * glen + (1 << j)] = 2;
            }
        }

        // For each block, we run through rows of ml & prod
        for (j = 1; j <= len; j++) {
            // get pointers
            rptr = plrows[j - 1];
            pprow = pprows[j - 1];

            // Now within the block, we have multiple grease-units, run
            // through them
            for (i = 0; i < bs; i++) {
                // start of current grease unit
                k = b + i * greasesize;

                // last unit of last block may be short
                gs = greasesize;
                if (k + gs > ilen)
                    gs = ilen - k + 1;

                // find the appropriate parts of grease tags
                // grease buffer and mr. Store in g

                if (gs > 1) {
                    g.pgtags = pgtags + glen * i;
                    g.pgbuf = pgbuf + (glen - 3) * nwords * i;
                    g.prrows = prrows + k - 1;
                }

                // get a chunk from a row of ml
                bits = getbits(rptr, k, gs);

                // 0 means nothing to do
                if (bits == 0)
                    continue;
                else if (bits == 1)    // handle this one specially to speed
                                       // up the greaselevel 1 case
                    v = prrows[k - 1];    // -1 is because k is 1-based index
                else
                    v = getgreasedata(
                        &g, bits);    // The main case
                                      // This function should be inlined
                AddGF2VecToGF2Vec(pprow, v, rlen);
            }
        }

        // Allow GAP to respond to Ctrl-C
        if (TakeInterrupt()) {
            // Might have been a garbage collection, reload everything
            if (greasesize >= 2) {
                pgtags = (UInt *)ADDR_OBJ(gtags);
                pgrules = (UInt *)ADDR_OBJ(grules);
                pgbuf = (UInt *)ADDR_OBJ(gbuf);
                // fill in some more bits of g
                g.pgrules = pgrules;
                g.nblocks = nwords;
            }
            plrows = (const UInt **)ADDR_OBJ(lrowptrs);
            prrows = (const UInt **)ADDR_OBJ(rrowptrs);
            pprows = (UInt **)ADDR_OBJ(prowptrs);
            for (i = 0; i < len; i++) {
                plrows[i] = CONST_BLOCKS_GF2VEC(ELM_GF2MAT(ml, i + 1));
                pprows[i] = BLOCKS_GF2VEC(ELM_GF2MAT(prod, i + 1));
            }
            for (i = 0; i < ilen; i++)
                prrows[i] = CONST_BLOCKS_GF2VEC(ELM_GF2MAT(mr, i + 1));
        }
    }
    return prod;
}

/****************************************************************************
**
*F  FuncPROD_GF2VEC_ANYMAT( <self>, <v>, <m>)
**
**  method to handle vector*plain list of GF2Vectors reasonably efficiently.
*/
static Obj FuncPROD_GF2VEC_ANYMAT(Obj self, Obj vec, Obj mat)
{
    Obj  res;
    UInt len;
    UInt len1;
    Obj  row1;
    UInt i;
    UInt block = 0;

    len = LEN_GF2VEC(vec);
    if (len > LEN_PLIST(mat))
        len = LEN_PLIST(mat);

    // Get the first row, to establish the size of the result
    row1 = ELM_PLIST(mat, 1);
    if (!IS_GF2VEC_REP(row1))
        return TRY_NEXT_METHOD;
    len1 = LEN_GF2VEC(row1);

    // create the result space
    NEW_GF2VEC(res,
               (IS_MUTABLE_OBJ(vec) || IS_MUTABLE_OBJ(row1))
                   ? TYPE_LIST_GF2VEC
                   : TYPE_LIST_GF2VEC_IMM,
               len1);

    // Finally, we start work
    for (i = 1; i <= len; i++) {
        if (i % BIPEB == 1)
            block = CONST_BLOCK_ELM_GF2VEC(vec, i);
        if (block & MASK_POS_GF2VEC(i)) {
            row1 = ELM_PLIST(mat, i);
            if (!IS_GF2VEC_REP(row1))
                return TRY_NEXT_METHOD;
            AddPartialGF2VecGF2Vec(res, res, row1, 1);
        }
    }
    return res;
}

/****************************************************************************
**
*F  InversePlistGF2VecsDesstructive( <list> )
**
**  This is intended to form the core of a method for InverseOp.
**  by this point it should be checked that list is a plain list of GF2
**  vectors of equal lengths.
*/
static Obj InversePlistGF2VecsDesstructive(Obj list)
{
    UInt         len;     // dimension
    Obj          inv;     // result
    Obj          row;     // row vector
    Obj          old;     // row from <mat>
    Obj          tmp;     // temporary
    UInt *       ptQ;     // data block of <row>
    const UInt * ptP;     // data block of source row
    const UInt * end;     // end marker
    const UInt * end2;    // end marker
    UInt         i;       // loop variable
    UInt         k;       // loop variable

    len = LEN_PLIST(list);

    // create the identity matrix
    tmp = NEW_PLIST(T_PLIST, len);
    for (i = len; 0 < i; i--) {
        NEW_GF2VEC(row, TYPE_LIST_GF2VEC, len);
        BLOCK_ELM_GF2VEC(row, i) |= MASK_POS_GF2VEC(i);
        SET_ELM_PLIST(tmp, i, row);
        CHANGED_BAG(tmp);
    }
    SET_LEN_PLIST(tmp, len);
    inv = tmp;

    // now start with ( id | mat ) towards ( inv | id )
    for (k = 1; k <= len; k++) {

        // find a nonzero entry in column <k>
        for (i = k; i <= len; i++) {
            row = ELM_PLIST(list, i);
            if (CONST_BLOCK_ELM_GF2VEC(row, k) & MASK_POS_GF2VEC(k))
                break;
        }
        if (i > len) {
            return Fail;
        }
        if (i != k) {
            row = ELM_PLIST(list, i);
            SET_ELM_PLIST(list, i, ELM_PLIST(list, k));
            SET_ELM_PLIST(list, k, row);
            row = ELM_PLIST(inv, i);
            SET_ELM_PLIST(inv, i, ELM_PLIST(inv, k));
            SET_ELM_PLIST(inv, k, row);
        }

        // clear entries
        old = ELM_PLIST(list, k);
        end = CONST_BLOCKS_GF2VEC(old) + ((len + BIPEB - 1) / BIPEB);
        for (i = 1; i <= len; i++) {
            if (i == k)
                continue;
            row = ELM_PLIST(list, i);
            if (CONST_BLOCK_ELM_GF2VEC(row, k) & MASK_POS_GF2VEC(k)) {

                // clear <mat>
                ptQ = &(BLOCK_ELM_GF2VEC(row, k));
                ptP = &(CONST_BLOCK_ELM_GF2VEC(old, k));
                while (ptP < end) {
                    *ptQ++ ^= *ptP++;
                }

                // modify <inv>
                row = ELM_PLIST(inv, i);
                ptQ = BLOCKS_GF2VEC(row);
                row = ELM_PLIST(inv, k);
                ptP = CONST_BLOCKS_GF2VEC(row);
                end2 = ptP + ((len + BIPEB - 1) / BIPEB);
                while (ptP < end2) {
                    *ptQ++ ^= *ptP++;
                }
            }
        }
        TakeInterrupt();
    }
    return inv;
}


/****************************************************************************
**
*F  InverseGF2Mat( <mat> )  . . . . . . . . . . . . . . inverse of GF2 matrix
**
**  This should be improved to work with mutable GF2 matrices
**
*/

static Obj InverseGF2Mat(Obj mat, UInt mut)
{
    UInt         len;    // dimension
    Obj          inv;    // result
    Obj          row;    // row vector
    Obj          tmp;    // temporary
    UInt         i;      // loop variable
    Obj          old;    // row from <mat>
    const UInt * ptQ;    // data block of <row>
    UInt *       ptP;    // data block of source row
    UInt *       end;    // end marker
    Obj          rtype;

    // make a structural copy of <mat> as list of GF2 vectors
    len = LEN_GF2MAT(mat);

    // special routes for very small matrices
    if (len == 0) {
        return CopyObj(mat, 1);
    }
    if (len == 1) {
        row = ELM_GF2MAT(mat, 1);
        if (CONST_BLOCKS_GF2VEC(row)[0] & 1) {
            return CopyObj(mat, 1);
        }
        else
            return Fail;
    }

    tmp = NEW_PLIST(T_PLIST, len);
    for (i = len; 0 < i; i--) {
        old = ELM_GF2MAT(mat, i);
        NEW_GF2VEC(row, TYPE_LIST_GF2VEC_IMM, len);
        ptQ = CONST_BLOCKS_GF2VEC(old);
        ptP = BLOCKS_GF2VEC(row);
        end = ptP + ((len + BIPEB - 1) / BIPEB);
        while (ptP < end)
            *ptP++ = *ptQ++;
        SET_ELM_PLIST(tmp, i, row);
        CHANGED_BAG(tmp);
    }
    SET_LEN_PLIST(tmp, len);
    inv = InversePlistGF2VecsDesstructive(tmp);
    if (inv == Fail)
        return inv;

    // convert list <inv> into a matrix
    ResizeBag(inv, SIZE_PLEN_GF2MAT(len));
    if (mut == 2 || (mut == 1 && IS_MUTABLE_OBJ(mat) &&
                     IS_MUTABLE_OBJ(ELM_GF2MAT(mat, 1))))
        rtype = TYPE_LIST_GF2VEC_LOCKED;
    else
        rtype = TYPE_LIST_GF2VEC_IMM_LOCKED;
    for (i = len; 0 < i; i--) {
        row = ELM_PLIST(inv, i);
        SET_TYPE_POSOBJ(row, rtype);
        SET_ELM_GF2MAT(inv, i, row);
    }
    SET_LEN_GF2MAT(inv, len);
    RetypeBag(inv, T_POSOBJ);
    SET_TYPE_POSOBJ(inv, (mut == 2 || (mut == 1 && IS_MUTABLE_OBJ(mat)))
                             ? TYPE_LIST_GF2MAT
                             : TYPE_LIST_GF2MAT_IMM);
    return inv;
}

/****************************************************************************
**
*F  ShallowCopyVecGF2( <vec> )
**
*/

Obj ShallowCopyVecGF2(Obj vec)
{
    Obj          copy;
    UInt         len;
    const UInt * ptrS;
    UInt *       ptrD;
    len = LEN_GF2VEC(vec);
    NEW_GF2VEC(copy, TYPE_LIST_GF2VEC, len);
    ptrS = CONST_BLOCKS_GF2VEC(vec);
    ptrD = BLOCKS_GF2VEC(copy);
    memcpy(ptrD, ptrS, NUMBER_BLOCKS_GF2VEC(vec) * sizeof(UInt));
    return copy;
}

/****************************************************************************
**
*F  SemiEchelonPlistGF2Vecs( <mat>, <transformations-needed> )
**
**  The matrix needs to have mutable rows, so it can't be a GF2 mat
**
**  This has changed. There should now be a method for mutable GF2mats as
**  well.
**
**  This function DOES NOT CHECK that the rows are all GF2 vectors
**
**  Does not copy the matrix, may destroy it, may include some
**  of the rows among the returned vectors
*/


static UInt RNheads, RNvectors, RNcoeffs, RNrelns;


static Obj SemiEchelonListGF2Vecs(Obj mat, UInt TransformationsNeeded)
{
    UInt  nrows, ncols;
    UInt  i, j, h;
    Obj   heads, vectors, coeffs = 0, relns = 0;
    UInt  nvecs, nrels = 0;
    Obj   coeffrow = 0;
    Obj   row;
    UInt *rowp, *coeffrowp = 0;
    Obj   res;
    nrows = LEN_PLIST(mat);
    ncols = LEN_GF2VEC(ELM_PLIST(mat, 1));
    heads = NEW_PLIST(T_PLIST_CYC, ncols);
    SET_LEN_PLIST(heads, ncols);
    vectors = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
    nvecs = 0;
    if (TransformationsNeeded) {
        coeffs = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
        relns = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
        nrels = 0;
    }
    for (i = 1; i <= ncols; i++)
        SET_ELM_PLIST(heads, i, INTOBJ_INT(0));
    for (i = 1; i <= nrows; i++) {
        row = ELM_PLIST(mat, i);
        if (TransformationsNeeded) {
            NEW_GF2VEC(coeffrow, TYPE_LIST_GF2VEC, nrows);
            BLOCK_ELM_GF2VEC(coeffrow, i) |= MASK_POS_GF2VEC(i);
        }

        // No garbage collection risk from here
        rowp = BLOCKS_GF2VEC(row);
        if (TransformationsNeeded)
            coeffrowp = BLOCKS_GF2VEC(coeffrow);
        for (j = 1; j <= ncols; j++) {
            h = INT_INTOBJ(ELM_PLIST(heads, j));
            if (h != 0) {
                if (rowp[(j - 1) / BIPEB] & MASK_POS_GF2VEC(j)) {
                    AddGF2VecToGF2Vec(
                        rowp, CONST_BLOCKS_GF2VEC(ELM_PLIST(vectors, h)),
                        ncols);
                    if (TransformationsNeeded)
                        AddGF2VecToGF2Vec(
                            coeffrowp,
                            CONST_BLOCKS_GF2VEC(ELM_PLIST(coeffs, h)), nrows);
                }
            }
        }
        j = 1;
        while (j <= ncols && !*rowp) {
            j += BIPEB;
            rowp++;
        }
        while (j <= ncols && !(*rowp & MASK_POS_GF2VEC(j)))
            j++;

        // garbage collection OK again after here
        if (j <= ncols) {
            SET_ELM_PLIST(vectors, ++nvecs, row);
            CHANGED_BAG(vectors);    // Could be an old bag by now. Max.
            SET_LEN_PLIST(vectors, nvecs);
            SET_ELM_PLIST(heads, j, INTOBJ_INT(nvecs));
            if (TransformationsNeeded) {
                SET_ELM_PLIST(coeffs, nvecs, coeffrow);
                CHANGED_BAG(coeffs);    // Could be an old bag by now. Max.
                SET_LEN_PLIST(coeffs, nvecs);
            }
        }
        else if (TransformationsNeeded) {
            SET_ELM_PLIST(relns, ++nrels, coeffrow);
            CHANGED_BAG(relns);    // Could be an old bag by now. Max.
            SET_LEN_PLIST(relns, nrels);
        }
        TakeInterrupt();
    }
    if (RNheads == 0) {
        RNheads = RNamName("heads");
        RNvectors = RNamName("vectors");
    }
    res = NEW_PREC(TransformationsNeeded ? 4 : 2);
    AssPRec(res, RNheads, heads);
    AssPRec(res, RNvectors, vectors);
    if (LEN_PLIST(vectors) == 0)
        RetypeBag(vectors, T_PLIST_EMPTY);
    if (TransformationsNeeded) {
        if (RNcoeffs == 0) {
            RNcoeffs = RNamName("coeffs");
            RNrelns = RNamName("relations");
        }
        AssPRec(res, RNcoeffs, coeffs);
        if (LEN_PLIST(coeffs) == 0)
            RetypeBag(coeffs, T_PLIST_EMPTY);
        AssPRec(res, RNrelns, relns);
        if (LEN_PLIST(relns) == 0)
            RetypeBag(relns, T_PLIST_EMPTY);
    }
    SortPRecRNam(res, 0);
    return res;
}

/****************************************************************************
**
*F  UInt TriangulizeListGF2Vecs( <mat>, <clearup> ) -- returns the rank
**
**  Again should add a method to work with mutable GF2 matrices
**
*/

static UInt TriangulizeListGF2Vecs(Obj mat, UInt clearup)
{
    UInt         nrows;
    UInt         ncols;
    UInt         workcol;
    UInt         workrow;
    UInt         rank;
    Obj          row, row2;
    const UInt * rowp;
    UInt *       row2p;
    UInt         block;
    UInt         mask;
    UInt         j;
    nrows = LEN_PLIST(mat);
    ncols = LEN_GF2VEC(ELM_PLIST(mat, 1));
    rank = 0;

    // Nothing here can cause a garbage collection

    for (workcol = 1; workcol <= ncols; workcol++) {
        block = (workcol - 1) / BIPEB;
        mask = MASK_POS_GF2VEC(workcol);
        for (workrow = rank + 1;
             workrow <= nrows &&
             !(CONST_BLOCKS_GF2VEC(ELM_PLIST(mat, workrow))[block] & mask);
             workrow++)
            ;
        if (workrow <= nrows) {
            rank++;
            row = ELM_PLIST(mat, workrow);
            if (workrow != rank) {
                SET_ELM_PLIST(mat, workrow, ELM_PLIST(mat, rank));
                SET_ELM_PLIST(mat, rank, row);
            }
            rowp = CONST_BLOCKS_GF2VEC(row);
            if (clearup)
                for (j = 1; j < rank; j++) {
                    row2 = ELM_PLIST(mat, j);
                    row2p = BLOCKS_GF2VEC(row2);
                    if (row2p[block] & mask)
                        AddGF2VecToGF2Vec(row2p, rowp, ncols);
                }
            for (j = workrow + 1; j <= nrows; j++) {
                row2 = ELM_PLIST(mat, j);
                row2p = BLOCKS_GF2VEC(row2);
                if (row2p[block] & mask)
                    AddGF2VecToGF2Vec(row2p, rowp, ncols);
            }
        }
        TakeInterrupt();
    }
    return rank;
}

/****************************************************************************
**
*F * * * * * * * * * * * *  conversion functions  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  PlainGF2Vec( <list> ) . . .  . convert a GF2 vector into an ordinary list
**
**  'PlainGF2Vec' converts the GF2 vector <list> to a plain list.
*/
static Obj IsLockedRepresentationVector;


static void PlainGF2Vec(Obj list)
{
    Int  len;          // length of <list>
    UInt i;            // loop variable
    Obj  first = 0;    // first entry

    // check for representation lock
    if (True == DoFilter(IsLockedRepresentationVector, list))
        ErrorMayQuit("Cannot convert a locked GF2 vector into a plain list",
                     0, 0);

    // resize the list and retype it, in this order
    len = LEN_GF2VEC(list);

    RetypeBagSM(list, (len == 0) ? T_PLIST_EMPTY : T_PLIST_FFE);

    GROW_PLIST(list, (UInt)len);
    SET_LEN_PLIST(list, len);

    // keep the first entry because setting the second destroys the first
    if (len == 0)
        SET_ELM_PLIST(list, 1, 0);
    else
        first = ELM_GF2VEC(list, 1);

    // wipe out the first entry of the GF2 vector (which becomes the  second
    // entry of the plain list, in case the list has length 1.
    if (len == 1)
        SET_ELM_PLIST(list, 2, 0);

    // replace the bits by 'GF2One' or 'GF2Zero' as the case may be
    // this must of course be done from the end of the list backwards
    for (i = len; 1 < i; i--)
        SET_ELM_PLIST(list, i, ELM_GF2VEC(list, i));
    if (len != 0)
        SET_ELM_PLIST(list, 1, first);

    CHANGED_BAG(list);
}


/****************************************************************************
**
*F  PlainGF2Mat( <list> ) . . .  . convert a GF2 matrix into an ordinary list
**
**  'PlainGF2Mat' converts the GF2 matrix <list> to a plain list.
*/
static void PlainGF2Mat(Obj list)
{
    Int  len;    // length of <list>
    UInt i;      // loop variable

    // resize the list and retype it, in this order
    len = LEN_GF2MAT(list);
    RetypeBagSM(list, T_PLIST);
    SET_LEN_PLIST(list, len);

    // shift the entries to the left
    for (i = 1; i <= len; i++) {
        SET_ELM_PLIST(list, i, ELM_GF2MAT(list, i));
    }
    SHRINK_PLIST(list, len);
    CHANGED_BAG(list);
}


/****************************************************************************
**
*F  ConvGF2Vec( <list> )  . . . . . . convert a list into a GF2 vector object
*/
static void ConvGF2Vec(Obj list)
{
    Int  len;      // logical length of the vector
    Int  i;        // loop variable
    UInt block;    // one block of the boolean list
    UInt bit;      // one bit of a block
    Obj  x;

    // already in the correct representation
    if (IS_GF2VEC_REP(list)) {
        return;
    }

    // Otherwise make it a plain list so that we will know where it keeps
    // its data -- could do much better in the case of GF(2^n) vectors that
    // actually lie over GF(2)

    if (IS_VEC8BIT_REP(list))
        PlainVec8Bit(list);
    else
        PLAIN_LIST(list);

    // change its representation
    len = LEN_PLIST(list);

    // We may have to resize the bag now because a length 1
    // plain list is shorter than a length 1 GF2VEC
    if (SIZE_PLEN_GF2VEC(len) > SIZE_OBJ(list))
        ResizeBag(list, SIZE_PLEN_GF2VEC(len));

    // now do the work
    block = 0;
    bit = 1;
    for (i = 1; i <= len; i++) {
        x = ELM_PLIST(list, i);
        if (x == GF2One)
            block |= bit;
        else if (x != GF2Zero) {
            // might be GF(2) elt written over bigger field
            if (EQ(x, GF2One))
                block |= bit;
            else if (!EQ(x, GF2Zero))
                ErrorMayQuit(
                    "COPY_GF2VEC: argument must be a list of GF2 elements",
                    0, 0);
        }

        bit = bit << 1;
        if (bit == 0 || i == len) {
            BLOCK_ELM_GF2VEC(list, i) = block;
            block = 0;
            bit = 1;
        }
    }

    // retype and resize bag
    ResizeWordSizedBag(list, SIZE_PLEN_GF2VEC(len));
    SET_LEN_GF2VEC(list, len);
    if (IS_PLIST_MUTABLE(list)) {
        SetTypeDatObj(list, TYPE_LIST_GF2VEC);
    }
    else {
        SetTypeDatObj(list, TYPE_LIST_GF2VEC_IMM);
    }
    RetypeBag(list, T_DATOBJ);
}


/****************************************************************************
**
*F  FuncCONV_GF2VEC( <self>, <list> ) . . . . . convert into a GF2 vector rep
*/
static Obj FuncCONV_GF2VEC(Obj self, Obj list)
{
    ConvGF2Vec(list);
    return 0;
}


/****************************************************************************
**
*F  NewGF2Vec( <list> )  . . . . . . convert a list into a GF2 vector object
**
**  This is a non-destructive counterpart of ConvGF2Vec
*/
static Obj NewGF2Vec(Obj list)
{
    Int  len;      // logical length of the vector
    Int  i;        // loop variable
    UInt block;    // one block of the boolean list
    UInt bit;      // one bit of a block
    Obj  x;
    Obj  res;    // resulting GF2 vector object

    // already in the correct representation
    if (IS_GF2VEC_REP(list)) {
        res = ShallowCopyVecGF2(list);
        if (!IS_MUTABLE_OBJ(list))
            SetTypeDatObj(res, TYPE_LIST_GF2VEC_IMM);
        return res;
    }

    if (!IS_LIST(list)) {
        ErrorMayQuit("COPY_GF2VEC: argument must be a list of GF2 elements",
                     0, 0);
    }
    if (!IS_PLIST(list)) {
        list = SHALLOW_COPY_OBJ(list);
        // TODO: if list is in 8bit rep, we could do better
        if (IS_VEC8BIT_REP(list))
            PlainVec8Bit(list);
        else
            PLAIN_LIST(list);
    }

    len = LEN_PLIST(list);
    NEW_GF2VEC(res, TYPE_LIST_GF2VEC, len);

    // now do the work
    block = 0;
    bit = 1;
    for (i = 1; i <= len; i++) {
        x = ELM_PLIST(list, i);
        if (x == GF2One)
            block |= bit;
        else if (x != GF2Zero) {
            // might be GF(2) elt written over bigger field
            if (EQ(x, GF2One))
                block |= bit;
            else if (!EQ(x, GF2Zero))
                ErrorMayQuit(
                    "COPY_GF2VEC: argument must be a list of GF2 elements",
                    0, 0);
        }

        bit = bit << 1;
        if (bit == 0 || i == len) {
            BLOCK_ELM_GF2VEC(res, i) = block;    // only changed list to res
            block = 0;
            bit = 1;
        }
    }

    // mutability should be inherited from the argument
    if (IS_PLIST_MUTABLE(list))
        SetTypeDatObj(res, TYPE_LIST_GF2VEC);
    else
        SetTypeDatObj(res, TYPE_LIST_GF2VEC_IMM);

    return res;
}


/****************************************************************************
**
*F  FuncCOPY_GF2VEC( <self>, <list> ) . . . . . convert into a GF2 vector rep
**
**  This is a non-destructive counterpart of FuncCONV_GF2VEC
*/
static Obj FuncCOPY_GF2VEC(Obj self, Obj list)
{
    list = NewGF2Vec(list);
    return list;
}

/****************************************************************************
**
*F FuncCONV_GF2MAT (<self>, <list> ) . . . convert into a GF2 matrix rep
**
** <list> should be a list of compressed GF2 vectors
**
*/
static Obj FuncCONV_GF2MAT(Obj self, Obj list)
{
    UInt len, i;
    Obj  tmp;
    UInt mut;
    len = LEN_LIST(list);
    if (len == 0)
        return (Obj)0;

    PLAIN_LIST(list);
    GROW_PLIST(list, len + 1);
    for (i = len; i > 0; i--) {
        tmp = ELM_PLIST(list, i);
        if (!IS_GF2VEC_REP(tmp)) {
            int j;
            for (j = i + 1; j <= len; j++) {
                tmp = ELM_PLIST(list, j + 1);
                SET_ELM_PLIST(list, j, tmp);
            }
            ErrorMayQuit("CONV_GF2MAT: argument must be a list of compressed "
                         "GF2 vectors",
                         0, 0);
        }
        SetTypeDatObj(tmp, IS_MUTABLE_OBJ(tmp) ? TYPE_LIST_GF2VEC_LOCKED
                                               : TYPE_LIST_GF2VEC_IMM_LOCKED);
        SET_ELM_PLIST(list, i + 1, tmp);
    }
    SET_ELM_PLIST(list, 1, INTOBJ_INT(len));
    mut = IS_PLIST_MUTABLE(list);
    RetypeBag(list, T_POSOBJ);
    SET_TYPE_POSOBJ(list, mut ? TYPE_LIST_GF2MAT : TYPE_LIST_GF2MAT_IMM);
    return (Obj)0;
}


/****************************************************************************
**
*F  FuncPLAIN_GF2VEC( <self>, <list> ) . . .  convert back into ordinary list
*/
static Obj FuncPLAIN_GF2VEC(Obj self, Obj list)
{
    if (!IS_GF2VEC_REP(list)) {
        RequireArgument(SELF_NAME, list, "must be a GF2 vector");
    }
    PlainGF2Vec(list);
    return 0;
}


/****************************************************************************
**
*F  revertbits -- utility function to reverse bit orders
*/


//   A list of flip values for bytes (i.e. ..xyz -> zyx..)

static const UInt1 revertlist[] = {
    0,  128, 64, 192, 32, 160, 96,  224, 16, 144, 80, 208, 48, 176, 112, 240,
    8,  136, 72, 200, 40, 168, 104, 232, 24, 152, 88, 216, 56, 184, 120, 248,
    4,  132, 68, 196, 36, 164, 100, 228, 20, 148, 84, 212, 52, 180, 116, 244,
    12, 140, 76, 204, 44, 172, 108, 236, 28, 156, 92, 220, 60, 188, 124, 252,
    2,  130, 66, 194, 34, 162, 98,  226, 18, 146, 82, 210, 50, 178, 114, 242,
    10, 138, 74, 202, 42, 170, 106, 234, 26, 154, 90, 218, 58, 186, 122, 250,
    6,  134, 70, 198, 38, 166, 102, 230, 22, 150, 86, 214, 54, 182, 118, 246,
    14, 142, 78, 206, 46, 174, 110, 238, 30, 158, 94, 222, 62, 190, 126, 254,
    1,  129, 65, 193, 33, 161, 97,  225, 17, 145, 81, 209, 49, 177, 113, 241,
    9,  137, 73, 201, 41, 169, 105, 233, 25, 153, 89, 217, 57, 185, 121, 249,
    5,  133, 69, 197, 37, 165, 101, 229, 21, 149, 85, 213, 53, 181, 117, 245,
    13, 141, 77, 205, 45, 173, 109, 237, 29, 157, 93, 221, 61, 189, 125, 253,
    3,  131, 67, 195, 35, 163, 99,  227, 19, 147, 83, 211, 51, 179, 115, 243,
    11, 139, 75, 203, 43, 171, 107, 235, 27, 155, 91, 219, 59, 187, 123, 251,
    7,  135, 71, 199, 39, 167, 103, 231, 23, 151, 87, 215, 55, 183, 119, 247,
    15, 143, 79, 207, 47, 175, 111, 239, 31, 159, 95, 223, 63, 191, 127, 255
};

// Takes an UInt a on n bits and returns the Uint obtained by reverting the
// bits
static UInt revertbits(UInt a, Int n)
{
    UInt b, c;
    b = 0;
    while (n > 8) {
        c = a & 0xff;    // last byte
        a = a >> 8;
        b = b << 8;
        b += (UInt)revertlist[(UInt1)c];    // add flipped
        n -= 8;
    }
    // cope with the last n bits
    a &= 0xff;
    b = b << n;
    c = (UInt)revertlist[(UInt1)a];
    c = c >> (8 - n);
    b += c;
    return b;
}

/****************************************************************************
**
*F  Cmp_GF2Vecs( <vl>, <vr> )   compare GF2 vectors -- internal
**                                    returns -1, 0 or 1
*/
static Int Cmp_GF2VEC_GF2VEC(Obj vl, Obj vr)
{
    UInt         i;                  // loop variable
    const UInt * bl;                 // block of <vl>
    const UInt * br;                 // block of <vr>
    UInt         len, lenl, lenr;    // length of the list
    UInt         a, b, nb;

    // get and check the length
    lenl = LEN_GF2VEC(vl);
    lenr = LEN_GF2VEC(vr);
    nb = NUMBER_BLOCKS_GF2VEC(vl);
    a = NUMBER_BLOCKS_GF2VEC(vr);
    if (a < nb) {
        nb = a;
    }

    // check all blocks
    bl = CONST_BLOCKS_GF2VEC(vl);
    br = CONST_BLOCKS_GF2VEC(vr);
    for (i = nb; 1 < i; i--, bl++, br++) {
        // comparison is numeric of the reverted lists
        if (*bl != *br) {
            a = revertbits(*bl, BIPEB);
            b = revertbits(*br, BIPEB);
            if (a < b)
                return -1;
            else
                return 1;
        }
    }


    // The last block remains
    len = lenl;
    if (len > lenr) {
        len = lenr;
    }

    // are both vectors length 0?
    if (len == 0)
        return 0;

    // is there still a full block in common?
    len = len % BIPEB;
    if (len == 0) {
        a = revertbits(*bl, BIPEB);
        b = revertbits(*br, BIPEB);
    }
    else {
        a = revertbits(*bl, len);
        b = revertbits(*br, len);
    }

    if (a < b)
        return -1;
    if (a > b)
        return 1;

    // blocks still the same --left length must be smaller to be true
    if (lenr > lenl)
        return -1;
    if (lenl > lenr)
        return 1;

    return 0;
}


/****************************************************************************
**
*F  FuncEQ_GF2VEC_GF2VEC( <self>, <vl>, <vr> )   test equality of GF2 vectors
*/
static Obj FuncEQ_GF2VEC_GF2VEC(Obj self, Obj vl, Obj vr)
{
    // we can do this case MUCH faster if we just want equality
    if (LEN_GF2VEC(vl) != LEN_GF2VEC(vr))
        return False;
    return (Cmp_GF2VEC_GF2VEC(vl, vr) == 0) ? True : False;
}


/****************************************************************************
**
*F  FuncLEN_GF2VEC( <self>, <list> )  . . . . . . . .  length of a GF2 vector
*/
static Obj FuncLEN_GF2VEC(Obj self, Obj list)
{
    return INTOBJ_INT(LEN_GF2VEC(list));
}


/****************************************************************************
**
*F  FuncELM0_GF2VEC( <self>, <list>, <pos> )  . select an elm of a GF2 vector
**
**  'ELM0_GF2VEC'  returns the element at the  position  <pos> of the boolean
**  list <list>, or `Fail' if <list> has no assigned  object at <pos>.  It is
**  the  responsibility of  the caller to   ensure  that <pos> is  a positive
**  integer.
*/
static Obj FuncELM0_GF2VEC(Obj self, Obj list, Obj pos)
{
    UInt p = GetSmallInt("ELM0_GF2VEC", pos);
    if (LEN_GF2VEC(list) < p) {
        return Fail;
    }
    else {
        return ELM_GF2VEC(list, p);
    }
}


/****************************************************************************
**
*F  FuncELM_GF2VEC( <self>, <list>, <pos> ) . . select an elm of a GF2 vector
**
**  'ELM_GF2VEC' returns the element at the position <pos>  of the GF2 vector
**  <list>.   An  error  is signalled  if  <pos>  is  not bound.    It is the
**  responsibility of the caller to ensure that <pos> is a positive integer.
*/
static Obj FuncELM_GF2VEC(Obj self, Obj list, Obj pos)
{
    UInt p = GetSmallInt("ELM_GF2VEC", pos);
    if (LEN_GF2VEC(list) < p) {
        ErrorMayQuit("List Element: <list>[%d] must have an assigned value",
                     p, 0);
    }
    else {
        return ELM_GF2VEC(list, p);
    }
}


/****************************************************************************
**
*F  FuncELMS_GF2VEC( <self>, <list>, <poss> ) . . . sublist from a GF2 vector
**
**  'ELMS_GF2VEC' returns a new list containing  the elements at the position
**  given in    the   list  <poss> from  the   vector   <list>.   It  is  the
**  responsibility of the caller to ensure that <poss>  is dense and contains
**  only positive integers.  An error is signalled if an element of <poss> is
**  larger than the length of <list>.
*/
static Obj FuncELMS_GF2VEC(Obj self, Obj list, Obj poss)
{
    Obj elms;       // selected sublist, result
    Int lenList;    // length of <list>
    Int lenPoss;    // length of positions
    Int pos;        // position as integer
    Int inc;        // increment in a range
    Int i;          // loop variable
    Obj apos;

    // get the length of <list>
    lenList = LEN_GF2VEC(list);

    // general code for arbritrary lists, which are ranges
    if (!IS_RANGE(poss)) {

        // get the length of <positions>
        lenPoss = LEN_LIST(poss);

        // make the result vector
        NEW_GF2VEC(elms, TYPE_LIST_GF2VEC, lenPoss);

        // loop over the entries of <positions> and select
        for (i = 1; i <= lenPoss; i++) {

            // get next position

            apos = ELM0_LIST(poss, i);
            if (!apos || !IS_INTOBJ(apos))
                ErrorMayQuit("ELMS_GF2VEC: error at position %d in positions "
                             "list, entry must be bound to a small integer",
                             i, 0);
            pos = INT_INTOBJ(apos);
            if (lenList < pos) {
                ErrorMayQuit("List Elements: <list>[%d] must have a value",
                             pos, 0);
            }

            // assign the element into <elms>
            if (ELM_GF2VEC(list, pos) == GF2One) {
                BLOCK_ELM_GF2VEC(elms, i) |= MASK_POS_GF2VEC(i);
            }
        }
    }

    // special code for ranges
    else {

        // get the length of <positions>, the first elements, and the inc.
        lenPoss = GET_LEN_RANGE(poss);
        pos = GET_LOW_RANGE(poss);
        inc = GET_INC_RANGE(poss);

        // check that no <position> is larger than <lenList>
        if (lenList < pos) {
            ErrorMayQuit("List Elements: <list>[%d] must have a value", pos,
                         0);
        }
        if (lenList < pos + (lenPoss - 1) * inc) {
            ErrorMayQuit("List Elements: <list>[%d] must have a value",
                         pos + (lenPoss - 1) * inc, 0);
        }

        // make the result vector
        NEW_GF2VEC(elms, TYPE_LIST_GF2VEC, lenPoss);

        // increment 1 ranges is a block copy
        if (inc == 1)
            CopySection_GF2Vecs(list, elms, pos, 1, lenPoss);

        // loop over the entries of <positions> and select
        else {
            for (i = 1; i <= lenPoss; i++, pos += inc) {
                if (ELM_GF2VEC(list, pos) == GF2One) {
                    BLOCK_ELM_GF2VEC(elms, i) |= MASK_POS_GF2VEC(i);
                }
            }
        }
    }

    return elms;
}


/****************************************************************************
**
*F  FuncASS_GF2VEC( <self>, <list>, <pos>, <elm> ) set an elm of a GF2 vector
**
**  'ASS_GF2VEC' assigns the element  <elm> at the position  <pos> to the GF2
**  vector <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive,
**  and that <elm> is not 0.
*/

static Obj FuncASS_GF2VEC(Obj self, Obj list, Obj pos, Obj elm)
{
    // check that <list> is mutable
    RequireMutable("List Assignment", list, "list");

    // get the position
    UInt p = GetSmallInt("ASS_GF2VEC", pos);

    // if <elm> is Z(2) or 0*Z(2) and the position is OK, keep rep
    if (p <= LEN_GF2VEC(list) + 1) {
        if (LEN_GF2VEC(list) + 1 == p) {
            if (DoFilter(IsLockedRepresentationVector, list) == True)
                ErrorMayQuit("Assignment forbidden beyond the end of locked "
                             "GF2 vector",
                             0, 0);
            ResizeWordSizedBag(list, SIZE_PLEN_GF2VEC(p));
            SET_LEN_GF2VEC(list, p);
        }
        if (EQ(GF2One, elm)) {
            BLOCK_ELM_GF2VEC(list, p) |= MASK_POS_GF2VEC(p);
        }
        else if (EQ(GF2Zero, elm)) {
            BLOCK_ELM_GF2VEC(list, p) &= ~MASK_POS_GF2VEC(p);
        }
        else if (IS_FFE(elm) && CHAR_FF(FLD_FFE(elm)) == 2 &&
                 DEGR_FF(FLD_FFE(elm)) <= 8) {
            RewriteGF2Vec(list, SIZE_FF(FLD_FFE(elm)));
            ASS_VEC8BIT(list, pos, elm);
        }
        else {
            PlainGF2Vec(list);
            ASS_LIST(list, p, elm);
        }
    }
    else {
        PlainGF2Vec(list);
        ASS_LIST(list, p, elm);
    }
    return 0;
}

/****************************************************************************
**
*F  FuncPLAIN_GF2MAT( <self>, <list> ) . . .  convert back into ordinary list
*/
static Obj FuncPLAIN_GF2MAT(Obj self, Obj list)
{
    PlainGF2Mat(list);
    return 0;
}


/****************************************************************************
**
*F  FuncASS_GF2MAT( <self>, <list>, <pos>, <elm> ) set an elm of a GF2 matrix
**
**  'ASS_GF2MAT' assigns the element  <elm> at the position  <pos> to the GF2
**  matrix <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive,
**  and that <elm> is not 0.
*/
static Obj FuncASS_GF2MAT(Obj self, Obj list, Obj pos, Obj elm)
{
    // check that <list> is mutable
    RequireMutable("List Assignment", list, "list");

    // get the position
    UInt p = GetSmallInt("ASS_GF2MAT", pos);

    // if <elm> is a GF2 vector and the length is OK, keep the rep
    if (!IS_GF2VEC_REP(elm)) {
        PlainGF2Mat(list);
        ASS_LIST(list, p, elm);
    }
    else if (p == 1 && 1 >= LEN_GF2MAT(list)) {
        ResizeBag(list, SIZE_PLEN_GF2MAT(p));
        SetTypeDatObj(elm, IS_MUTABLE_OBJ(elm) ? TYPE_LIST_GF2VEC_LOCKED
                                               : TYPE_LIST_GF2VEC_IMM_LOCKED);
        SET_ELM_GF2MAT(list, p, elm);
        CHANGED_BAG(list);
    }
    else if (p > LEN_GF2MAT(list) + 1) {
        PlainGF2Mat(list);
        ASS_LIST(list, p, elm);
    }
    else if (LEN_GF2VEC(elm) == LEN_GF2VEC(ELM_GF2MAT(list, 1))) {
        if (LEN_GF2MAT(list) + 1 == p) {
            ResizeBag(list, SIZE_PLEN_GF2MAT(p));
            SET_LEN_GF2MAT(list, p);
        }
        SetTypeDatObj(elm, IS_MUTABLE_OBJ(elm) ? TYPE_LIST_GF2VEC_LOCKED
                                               : TYPE_LIST_GF2VEC_IMM_LOCKED);
        SET_ELM_GF2MAT(list, p, elm);
        CHANGED_BAG(list);
    }
    else {
        PlainGF2Mat(list);
        ASS_LIST(list, p, elm);
    }
    return 0;
}


/****************************************************************************
**
*F  FuncELM_GF2MAT( <self>, <mat>, <row> ) . . . select a row of a GF2 matrix
**
*/
static Obj FuncELM_GF2MAT(Obj self, Obj mat, Obj row)
{
    UInt r = GetSmallInt("ELM_GF2MAT", row);
    if (LEN_GF2MAT(mat) < r) {
        ErrorMayQuit("row index %d exceeds %d, the number of rows", r,
                     LEN_GF2MAT(mat));
    }
    return ELM_GF2MAT(mat, r);
}


/****************************************************************************
**
*F  FuncUNB_GF2VEC( <self>, <list>, <pos> ) . unbind position of a GF2 vector
**
**  'UNB_GF2VEC' unbind  the element at  the position  <pos> in  a GF2 vector
**  <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive.
*/
static Obj FuncUNB_GF2VEC(Obj self, Obj list, Obj pos)
{
    // check that <list> is mutable
    RequireMutable("List Unbind", list, "vector");

    if (DoFilter(IsLockedRepresentationVector, list) == True) {
        ErrorMayQuit("Unbind forbidden on locked GF2 vector", 0, 0);
    }

    // get the position
    UInt p = GetSmallInt("UNB_GF2VEC", pos);

    // if we unbind the last position keep the representation
    if (LEN_GF2VEC(list) < p) {
        ;
    }
    else if (LEN_GF2VEC(list) == p) {
        ResizeWordSizedBag(list, SIZE_PLEN_GF2VEC(p - 1));
        SET_LEN_GF2VEC(list, p - 1);
    }
    else {
        PlainGF2Vec(list);
        UNB_LIST(list, p);
    }
    return 0;
}


/****************************************************************************
**
*F  FuncUNB_GF2MAT( <self>, <list>, <pos> ) . unbind position of a GF2 matrix
**
**  'UNB_GF2VEC' unbind  the element at  the position  <pos> in  a GF2 matrix
**  <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive.
*/
static Obj FuncUNB_GF2MAT(Obj self, Obj list, Obj pos)
{
    // check that <list> is mutable
    RequireMutable("List Unbind", list, "matrix");

    // get the position
    UInt p = GetSmallInt("UNB_GF2MAT", pos);

    // if we unbind the last position keep the representation
    if (p > 1 && LEN_GF2MAT(list) < p) {
        ;
    }
    else if (LEN_GF2MAT(list) == p) {
        ResizeBag(list, SIZE_PLEN_GF2MAT(p - 1));
        SET_LEN_GF2MAT(list, p - 1);
    }
    else {
        PlainGF2Mat(list);
        UNB_LIST(list, p);
    }
    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * arithmetic operations  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncZERO_GF2VEC( <self>, <mat> )  . . . . . . . . . . . . zero GF2 vector
**
**  return the zero vector over GF2 of the same length as <mat>.
*/
static Obj FuncZERO_GF2VEC(Obj self, Obj mat)
{
    Obj  zero;
    UInt len;

    // create a new GF2 vector
    len = LEN_GF2VEC(mat);
    NEW_GF2VEC(zero, TYPE_LIST_GF2VEC, len);
    return zero;
}

/****************************************************************************
**
*F  FuncZERO_GF2VEC_2( <self>, <len>) . . . . . . . . . zero GF2 vector
**
**  return the zero vector over GF2 of length <len>
*/
static Obj FuncZERO_GF2VEC_2(Obj self, Obj len)
{
    Obj zero;
    RequireNonnegativeSmallInt(SELF_NAME, len);
    NEW_GF2VEC(zero, TYPE_LIST_GF2VEC, INT_INTOBJ(len));
    return zero;
}


/****************************************************************************
**
*F  FuncINV_GF2MAT_MUTABLE( <self>, <mat> ) . .. . . . .  inverse GF2 matrix
**
** This might now be redundant, a library method using
**  INVERSE_PLIST_GF2VECS_DESTRUCTIVE
** might do just as good a job
*/
static Obj FuncINV_GF2MAT_MUTABLE(Obj self, Obj mat)
{
    UInt len;

    len = LEN_GF2MAT(mat);
    if (len != 0) {
        if (len != LEN_GF2VEC(ELM_GF2MAT(mat, 1))) {
            ErrorMayQuit("<matrix> must be square", 0, 0);
        }
    }
    return InverseGF2Mat(mat, 2);
}

/****************************************************************************
**
*F  FuncINV_GF2MAT_SAME_MUTABILITY( <self>, <mat> ) . ...  inverse GF2 matrix
**
** This might now be redundant, a library method using
**  INVERSE_PLIST_GF2VECS_DESTRUCTIVE
** might do just as good a job
*/
static Obj FuncINV_GF2MAT_SAME_MUTABILITY(Obj self, Obj mat)
{
    UInt len;

    len = LEN_GF2MAT(mat);
    if (len != 0) {
        if (len != LEN_GF2VEC(ELM_GF2MAT(mat, 1))) {
            ErrorMayQuit("<matrix> must be square", 0, 0);
        }
    }
    return InverseGF2Mat(mat, 1);
}

/****************************************************************************
**
*F  FuncINV_GF2MAT_IMMUTABLE( <self>, <mat> ) . .. . . .  inverse GF2 matrix
**
** This might now be redundant, a library method using
**  INVERSE_PLIST_GF2VECS_DESTRUCTIVE
** might do just as good a job
*/
static Obj FuncINV_GF2MAT_IMMUTABLE(Obj self, Obj mat)
{
    UInt len;

    len = LEN_GF2MAT(mat);
    if (len != 0) {
        if (len != LEN_GF2VEC(ELM_GF2MAT(mat, 1))) {
            ErrorMayQuit("<matrix> must be square", 0, 0);
        }
    }
    return InverseGF2Mat(mat, 0);
}


/****************************************************************************
**
*F  FuncINV_PLIST_GF2VECS_DESTRUCTIVE( <self>, <list> )
**
**  invert possible GF2 matrix
*/
static Obj FuncINV_PLIST_GF2VECS_DESTRUCTIVE(Obj self, Obj list)
{
    UInt len, i;
    Obj  row;
    len = LEN_PLIST(list);
    for (i = 1; i <= len; i++) {
        row = ELM_PLIST(list, i);
        if (!IS_GF2VEC_REP(row) || LEN_GF2VEC(row) != len)
            return TRY_NEXT_METHOD;
    }
    if (len == 0) {
        return CopyObj(list, 1);
    }
    if (len == 1) {
        row = ELM_PLIST(list, 1);
        if (CONST_BLOCKS_GF2VEC(row)[0] & 1) {
            return CopyObj(list, 1);
        }
        else
            return Fail;
    }
    return InversePlistGF2VecsDesstructive(list);
}


/****************************************************************************
**
*F  FuncSUM_GF2VEC_GF2VEC( <self>, <vl>, <vr> ) . . . . .  sum of GF2 vectors
**
**  'FuncSUM_GF2VEC_GF2VEC' returns the sum  of the two gf2-vectors <vl>  and
**  <vr>.  The sum is a new gf2-vector, where each element is  the sum of the
**  corresponding entries of <vl>  and <vr>.  The  major work is done  in the
**  routine   'AddPartialGF2VecGF2Vec'     which     is         called   from
**  'FuncSUM_GF2VEC_GF2VEC'.
**
**  'FuncSUM_GF2VEC_GF2VEC'  is  an improved  version of 'SumListList', which
**  does not call 'SUM' but uses bit operations instead.
*/
static Obj FuncSUM_GF2VEC_GF2VEC(Obj self, Obj vl, Obj vr)
{
    Obj  sum;    // sum, result
    UInt ll, lr;

    ll = LEN_GF2VEC(vl);
    lr = LEN_GF2VEC(vr);


    if (ll < lr) {
        sum = ShallowCopyVecGF2(vr);
        AddGF2VecToGF2Vec(BLOCKS_GF2VEC(sum), CONST_BLOCKS_GF2VEC(vl), ll);
    }
    else {
        sum = ShallowCopyVecGF2(vl);
        AddGF2VecToGF2Vec(BLOCKS_GF2VEC(sum), CONST_BLOCKS_GF2VEC(vr), lr);
    }

    if (!IS_MUTABLE_OBJ(vl) && !IS_MUTABLE_OBJ(vr))
        SET_TYPE_POSOBJ(sum, TYPE_LIST_GF2VEC_IMM);

    return sum;
}

/****************************************************************************
**
*F  FuncMULT_VECTOR_GF2VECS_2( <self>, <vl>, <mul> )
**                                      . . . . .  sum of GF2 vectors
**
*/
static Obj FuncMULT_VECTOR_GF2VECS_2(Obj self, Obj vl, Obj mul)
{
    if (EQ(mul, GF2One))
        return (Obj)0;
    else if (EQ(mul, GF2Zero)) {
        AddCoeffsGF2VecGF2Vec(vl, vl);
        return (Obj)0;
    }
    else
        return TRY_NEXT_METHOD;
}


/****************************************************************************
**
*F  FuncPROD_GF2VEC_GF2VEC( <self>, <vl>, <vr> )  . .  product of GF2 vectors
**
**  'FuncPROD_GF2VEC_GF2VEC' returns the product of  the two GF2 vectors <vl>
**  and <vr>.  The product is either `GF2One' or `GF2Zero'.
*/
static Obj FuncPROD_GF2VEC_GF2VEC(Obj self, Obj vl, Obj vr)
{
    return ProdGF2VecGF2Vec(vl, vr);
}


/****************************************************************************
**
*F  FuncPROD_GF2VEC_GF2MAT( <self>, <vl>, <vr> ) product of GF2 vector/matrix
**
**  'FuncPROD_GF2VEC_GF2MAT' returns  the product of the GF2 vectors <vl> and
**  the GF2 matrix <vr>.
**
**  The  product is  again a  GF2 vector.  It  is  the  responsibility of the
**  caller to ensure that <vl> is a  GF2 vector, <vr>  a GF2 matrix.
*/
static Obj FuncPROD_GF2VEC_GF2MAT(Obj self, Obj vl, Obj vr)
{
    return ProdGF2VecGF2Mat(vl, vr);
}

/****************************************************************************
**
*F  FuncPROD_GF2MAT_GF2MAT( <self>, <ml>, <mr> ) product of GF2 vector/matrix
**
**  'FuncPROD_GF2MAT_GF2MAT' returns the product of the GF2 matricess <ml>
**  and <mr>.
**
**  The  product is  again a  GF2 matrix.  It  is  the  responsibility of the
**  caller to ensure that <ml> and <mr> are  GF2 matrices
*/
static Obj FuncPROD_GF2MAT_GF2MAT(Obj self, Obj ml, Obj mr)
{
    UInt lenl = LEN_GF2MAT(ml);
    UInt lenm;
    if (lenl >= 128) {
        lenm = LEN_GF2VEC(ELM_GF2MAT(ml, 1));
        if (lenm >= 128 && lenm == LEN_GF2MAT(mr) &&
            LEN_GF2VEC(ELM_GF2MAT(mr, 1)) >= 128) {
            return ProdGF2MatGF2MatAdvanced(ml, mr, 8, (lenm + 255) / 256);
        }
    }
    return ProdGF2MatGF2MatSimple(ml, mr);
}

/****************************************************************************
**
*F  FuncPROD_GF2MAT_GF2MAT_SIMPLE( <self>, <ml>, <mr> )
**
**  'FuncPROD_GF2MAT_GF2MAT' returns  the product of the GF2 matricess <ml>
**  and <mr>. It never uses grease or blocking.
**
**  The  product is  again a  GF2 matrix.  It  is  the  responsibility of the
**  caller to ensure that <ml> and <mr> are  GF2 matrices
*/
static Obj FuncPROD_GF2MAT_GF2MAT_SIMPLE(Obj self, Obj ml, Obj mr)
{
    return ProdGF2MatGF2MatSimple(ml, mr);
}


/****************************************************************************
**
*F  FuncPROD_GF2MAT_GF2MAT_ADVANCED( <self>, <ml>, <mr>, <greaselevel>,
**                                                              <blocksize> )
**
**  'FuncPROD_GF2MAT_GF2MAT_ADVANCED' returns the product of the GF2 matrices
**  <ml> and <mr> using grease level <greaselevel> and block size <blocksize>
**
**  The  product is  again a  GF2 matrix.  It  is  the  responsibility of the
**  caller to ensure that <ml> and <mr> are  GF2 matrices
*/
static Obj FuncPROD_GF2MAT_GF2MAT_ADVANCED(
    Obj self, Obj ml, Obj mr, Obj greaselevel, Obj blocksize)
{
    return ProdGF2MatGF2MatAdvanced(ml, mr, INT_INTOBJ(greaselevel),
                                    INT_INTOBJ(blocksize));
}


/****************************************************************************
**
*F  FuncPROD_GF2MAT_GF2VEC( <self>, <vl>, <vr> ) product of GF2 matrix/vector
**
**  'FuncPROD_GF2VEC_GF2MAT' returns  the product of the GF2 matrix  <vl> and
**  the GF2 vector <vr>.
**
**  The  product is  again a  GF2 vector.  It  is  the  responsibility of the
**  caller to ensure that <vr> is a  GF2 vector, <vl>  a GF2 matrix.
*/
static Obj FuncPROD_GF2MAT_GF2VEC(Obj self, Obj vl, Obj vr)
{
    return ProdGF2MatGF2Vec(vl, vr);
}


/****************************************************************************
**
*F  FuncADDCOEFFS_GF2VEC_GF2VEC_MULT( <self>, <vl>, <vr>, <mul> ) GF2 vectors
*/
static Obj FuncADDCOEFFS_GF2VEC_GF2VEC_MULT(Obj self, Obj vl, Obj vr, Obj mul)
{
    // do nothing if <mul> is zero
    if (EQ(mul, GF2Zero)) {
        return INTOBJ_INT(RightMostOneGF2Vec(vl));
    }

    // add if <mul> is one
    if (EQ(mul, GF2One)) {
        return AddCoeffsGF2VecGF2Vec(vl, vr);
    }

    // try next method
    return TRY_NEXT_METHOD;
}

/****************************************************************************
**
*F  FuncADDCOEFFS_GF2VEC_GF2VEC( <self>, <vl>, <vr> ) . . . . . . GF2 vectors
*/
static Obj FuncADDCOEFFS_GF2VEC_GF2VEC(Obj self, Obj vl, Obj vr)
{
    return AddCoeffsGF2VecGF2Vec(vl, vr);
}


/****************************************************************************
**
*F  FuncSHRINKCOEFFS_GF2VEC( <self>, <vec> )  . . . . . remove trailing zeros
*/
static Obj FuncSHRINKCOEFFS_GF2VEC(Obj self, Obj vec)
{
    UInt   len;
    UInt   nbb;
    UInt   onbb;
    UInt * ptr;
    UInt   off;

    // get length and number of blocks
    len = LEN_GF2VEC(vec);
    if (len == 0) {
        return INTOBJ_INT(0);
    }

    nbb = (len + BIPEB - 1) / BIPEB;
    onbb = nbb;
    ptr = BLOCKS_GF2VEC(vec) + (nbb - 1);

    // number of insignificant bit positions in last word
    off = BIPEB - ((len - 1) % BIPEB + 1);

    // mask out the last bits
    *ptr &= ALL_BITS_UINT >> off;

    // find last non-trivial block
    while (0 < nbb && !*ptr) {
        nbb--;
        ptr--;
    }
    // did the block number change?
    if (nbb < onbb) {
        len = nbb * BIPEB;
    }

    // find position inside this block
    // we are guaranteed not to cross a block boundary !
    while (0 < len && !(*ptr & MASK_POS_GF2VEC(len))) {
        len--;
    }
    ResizeWordSizedBag(vec, SIZE_PLEN_GF2VEC(len));
    SET_LEN_GF2VEC(vec, len);
    return INTOBJ_INT(len);
}

/****************************************************************************
**
*F  FuncPOSITION_NONZERO_GF2VEC( <self>, <vec>, <zero>) ..find first non-zero
**
**  The pointless zero argument is because this is a method for PositionNot
**  It is *not* used in the code and can be replaced by a dummy argument.
*/

static UInt PositionNonZeroGF2Vec(Obj vec, UInt from)
{
    UInt         len;
    UInt         nbb;
    UInt         nb;
    const UInt * ptr;
    UInt         pos;

    // get length and number of blocks
    len = LEN_GF2VEC(vec);
    if (len == 0) {
        return 1;
    }


    nbb = from / BIPEB;
    pos = from % BIPEB;
    ptr = CONST_BLOCKS_GF2VEC(vec) + nbb;
    if (pos)    // partial block to check
    {
        pos = from + 1;
        while ((pos - 1) % BIPEB && pos <= len) {
            if ((*ptr) & MASK_POS_GF2VEC(pos))
                return (pos);
            pos++;
        }
        if (pos > len)
            return len + 1;
        nbb++;
        ptr++;
    }
    // find first non-trivial block
    nb = NUMBER_BLOCKS_GF2VEC(vec);
    while (nbb < nb && !*ptr) {
        nbb++;
        ptr++;
    }

    // find position inside this block
    pos = nbb * BIPEB + 1;
    while (pos <= len && !(*ptr & MASK_POS_GF2VEC(pos))) {
        pos++;
    }
    // as the code is intended to run over, trailing 1's are innocent
    if (pos <= len)
        return pos;
    else
        return len + 1;
}


static Obj FuncPOSITION_NONZERO_GF2VEC(Obj self, Obj vec, Obj zero)
{
    return INTOBJ_INT(PositionNonZeroGF2Vec(vec, 0));
}

static Obj FuncPOSITION_NONZERO_GF2VEC3(Obj self, Obj vec, Obj zero, Obj from)
{
    return INTOBJ_INT(PositionNonZeroGF2Vec(vec, INT_INTOBJ(from)));
}


static Obj FuncCOPY_SECTION_GF2VECS(
    Obj self, Obj src, Obj dest, Obj from, Obj to, Obj howmany)
{
    Int ifrom = GetPositiveSmallInt("COPY_SECTION_GF2VECS", from);
    Int ito = GetPositiveSmallInt("COPY_SECTION_GF2VECS", to);
    Int ihowmany = GetSmallInt("COPY_SECTION_GF2VECS", howmany);

    if (!IS_GF2VEC_REP(src)) {
        RequireArgument(SELF_NAME, src, "must be a GF2 vector");
    }
    if (!IS_GF2VEC_REP(dest)) {
        RequireArgument(SELF_NAME, dest, "must be a GF2 vector");
    }

    UInt lens = LEN_GF2VEC(src);
    UInt lend = LEN_GF2VEC(dest);
    if (ihowmany < 0 ||
        ifrom + ihowmany - 1 > lens || ito + ihowmany - 1 > lend)
        ErrorMayQuit("Bad argument values", 0, 0);
    RequireMutable(SELF_NAME, dest, "vector");

    CopySection_GF2Vecs(src, dest, (UInt)ifrom, (UInt)ito, (UInt)ihowmany);
    return (Obj)0;
}


/****************************************************************************
**
*F  FuncAPPEND_GF2VEC( <self>, <vecl>, <vecr> )
**
*/

static Obj FuncAPPEND_GF2VEC(Obj self, Obj vecl, Obj vecr)
{
    UInt lenl, lenr;
    lenl = LEN_GF2VEC(vecl);
    lenr = LEN_GF2VEC(vecr);
    if (True == DoFilter(IsLockedRepresentationVector, vecl) && lenr > 0) {
        ErrorMayQuit("Append to locked compressed vector is forbidden", 0, 0);
    }
    ResizeWordSizedBag(vecl, SIZE_PLEN_GF2VEC(lenl + lenr));
    CopySection_GF2Vecs(vecr, vecl, 1, lenl + 1, lenr);
    SET_LEN_GF2VEC(vecl, lenl + lenr);
    return (Obj)0;
}


/****************************************************************************
**
*F  FuncSHALLOWCOPY_GF2VEC( <self>, <vec> )
**
*/

static Obj FuncSHALLOWCOPY_GF2VEC(Obj self, Obj vec)
{
    return ShallowCopyVecGF2(vec);
}

/****************************************************************************
**
*F  FuncSUM_GF2MAT_GF2MAT( <self>, <matl>, <matr> )
**
*/


static Obj FuncSUM_GF2MAT_GF2MAT(Obj self, Obj matl, Obj matr)
{
    UInt ll, lr, ls, lm, wl, wr, ws, wm;
    Obj  sum;
    Obj  vl, vr, sv;
    UInt i;
    Obj  rtype;
    ll = LEN_GF2MAT(matl);
    lr = LEN_GF2MAT(matr);
    if (ll > lr) {
        ls = ll;
        lm = lr;
    }
    else {
        ls = lr;
        lm = ll;
    }
    wl = LEN_GF2VEC(ELM_GF2MAT(matl, 1));
    wr = LEN_GF2VEC(ELM_GF2MAT(matr, 1));
    if (wl > wr) {
        ws = wl;
        wm = wr;
    }
    else {
        ws = wr;
        wm = wl;
    }

    // In this case, the result is not rectangular

    if ((ll > lr && wr > wl) || (ll < lr && wr < wl))
        return TRY_NEXT_METHOD;


    sum = NewBag(T_POSOBJ, SIZE_PLEN_GF2MAT(ls));
    if (IS_MUTABLE_OBJ(matl) || IS_MUTABLE_OBJ(matr)) {
        SET_TYPE_POSOBJ(sum, TYPE_LIST_GF2MAT);
        if (IS_MUTABLE_OBJ(ELM_GF2MAT(matl, 1)) ||
            IS_MUTABLE_OBJ(ELM_GF2MAT(matr, 1)))
            rtype = TYPE_LIST_GF2VEC_LOCKED;
        else
            rtype = TYPE_LIST_GF2VEC_IMM_LOCKED;
    }
    else {
        SET_TYPE_POSOBJ(sum, TYPE_LIST_GF2MAT_IMM);
        rtype = TYPE_LIST_GF2VEC_IMM_LOCKED;
    }

    SET_LEN_GF2MAT(sum, ls);
    for (i = 1; i <= lm; i++) {

        // copy the longer vector and add the shorter
        if (wl == ws) {
            sv = ShallowCopyVecGF2(ELM_GF2MAT(matl, i));
            vr = ELM_GF2MAT(matr, i);
            AddGF2VecToGF2Vec(BLOCKS_GF2VEC(sv), CONST_BLOCKS_GF2VEC(vr), wm);
        }
        else {
            sv = ShallowCopyVecGF2(ELM_GF2MAT(matr, i));
            vl = ELM_GF2MAT(matl, i);
            AddGF2VecToGF2Vec(BLOCKS_GF2VEC(sv), CONST_BLOCKS_GF2VEC(vl), wm);
        }

        SetTypeDatObj(sv, rtype);
        SET_ELM_GF2MAT(sum, i, sv);
        CHANGED_BAG(sum);
    }
    for (; i <= ls; i++) {
        if (ll > lr)
            sv = ELM_GF2MAT(matl, i);
        else
            sv = ELM_GF2MAT(matr, i);

        if (rtype == TYPE_LIST_GF2VEC_LOCKED)
            sv = ShallowCopyVecGF2(sv);

        SetTypeDatObj(sv, rtype);
        SET_ELM_GF2MAT(sum, i, sv);
        CHANGED_BAG(sum);
    }
    return sum;
}


/****************************************************************************
**
*F  FuncTRANSPOSED_GF2MAT( <self>, <mat>)
**
*/
static Obj FuncTRANSPOSED_GF2MAT(Obj self, Obj mat)
{
    UInt l, w;
    Obj  tra, row;
    Obj  typ, r1;
    UInt vals[BIPEB];
    UInt mask, val, bit;
    UInt imod, nrb, nstart;
    UInt i, j, k, n;

    if (TNUM_OBJ(mat) != T_POSOBJ) {
        ErrorMayQuit("TRANSPOSED_GF2MAT: Need compressed matrix over GF(2)",
                     0, 0);
    }
    // type for mat
    typ = TYPE_LIST_GF2MAT;


    // we assume here that there is a first row
    r1 = ELM_GF2MAT(mat, 1);

    l = LEN_GF2MAT(mat);
    w = LEN_GF2VEC(r1);
    nrb = NUMBER_BLOCKS_GF2VEC(r1);

    tra = NewBag(T_POSOBJ, SIZE_PLEN_GF2MAT(w));
    SET_TYPE_POSOBJ(tra, typ);

    // type for rows
    typ = TYPE_LIST_GF2VEC_LOCKED;

    SET_LEN_GF2MAT(tra, w);
    // create new matrix
    for (i = 1; i <= w; i++) {
        NEW_GF2VEC(row, typ, l);
        SET_ELM_GF2MAT(tra, i, row);
        CHANGED_BAG(tra);
    }
    // set entries
    // run over BIPEB row chunks of the original matrix
    for (i = 1; i <= l; i = i + BIPEB) {
        imod = (i - 1) / BIPEB;
        // run through these rows in block chunks
        for (n = 0; n < nrb; n++) {
            for (j = 0; j < BIPEB; j++) {
                if ((i + j) > l) {
                    vals[j] = 0;    // outside matrix
                }
                else {
                    const UInt * ptr =
                        CONST_BLOCKS_GF2VEC(ELM_GF2MAT(mat, i + j)) + n;
                    vals[j] = *ptr;
                }
            }
            // write transposed values in new matrix
            mask = 1;
            nstart = n * BIPEB + 1;
            for (j = 0; j < BIPEB; j++) {    // bit number = Row in transpose
                if ((nstart + j) <= w) {
                    // still within matrix
                    val = 0;
                    bit = 1;
                    for (k = 0; k < BIPEB; k++) {
                        if (mask == (vals[k] & mask)) {
                            val |= bit;    // set bit
                        }
                        bit = bit << 1;
                    }
                    // set entry
                    UInt * ptr =
                        BLOCKS_GF2VEC(ELM_GF2MAT(tra, nstart + j)) + imod;
                    *ptr = val;
                    // next bit
                    mask = mask << 1;
                }
            }
        }
    }
    return tra;
}


/****************************************************************************
**
*F  FuncNUMBER_GF2VEC( <self>, <vect> )
**
*/
static Obj FuncNUMBER_GF2VEC(Obj self, Obj vec)
{
    UInt        len, nd, i;
    UInt        head, a;
    UInt        off, off2;    // 0 based
    Obj         zahl;         // the long number
    UInt *      num2;
    mp_limb_t * vp;
    len = LEN_GF2VEC(vec);
    if (len == 0)
        return INTOBJ_INT(1);
    num2 = BLOCKS_GF2VEC(vec) + (len - 1) / BIPEB;
    off = (len - 1) % BIPEB + 1;    // number of significant bits in last word
    off2 = BIPEB - off;    // number of insignificant bits in last word

    // mask out the last bits
    *num2 &= ALL_BITS_UINT >> off2;

    if (len <= NR_SMALL_INT_BITS)
        // it still fits into a small integer
        return INTOBJ_INT(revertbits(*num2, len));
    else {
        // we might have to build a long integer

        // the number of words (limbs) we need.
        nd = ((len - 1) / GMP_LIMB_BITS) + 1;

        zahl = NewBag(T_INTPOS, nd * sizeof(UInt));
        //    zahl = NewBag( T_INTPOS, (((nd+1)>>1)<<1)*sizeof(UInt) );
        // +1)>>1)<<1: round up to next even number

        // garbage collection might lose pointer
        const UInt * num = CONST_BLOCKS_GF2VEC(vec) + (len - 1) / BIPEB;

        vp = (mp_limb_t *)ADDR_OBJ(zahl);    // the place we write to
        i = 1;

        if (off != BIPEB) {
            head = revertbits(*num, off);    // the last 'off' bits, reverted
            while (i < nd) {
                // next word
                num--;
                *vp = head;    // the bits left from last word
                a = revertbits(*num, BIPEB);    // the full word reverted
                head = a >> off2;    // next head: trailing `off' bits
                a = a << off;        // the rest of the word
                *vp |= a;
                vp++;
                i++;
            }
            *vp = head;    // last head bits
            vp++;
        }
        else {
            while (i <= nd) {
                *vp = revertbits(*num--, BIPEB);
                vp++;
                i++;
            }
        }


        zahl = GMP_NORMALIZE(zahl);
        zahl = GMP_REDUCE(zahl);

        return zahl;
    }
}

/****************************************************************************
**
*F  FuncLT_GF2VEC_GF2VEC( <self>, <vl>, <vr> )   compare GF2 vectors
*/
static Obj FuncLT_GF2VEC_GF2VEC(Obj self, Obj vl, Obj vr)
{
    return (Cmp_GF2VEC_GF2VEC(vl, vr) < 0) ? True : False;
}

/****************************************************************************
**
*F  Cmp_GF2MAT_GF2MAT( <ml>, <mr> )   compare GF2 matrices
*/

static Int Cmp_GF2MAT_GF2MAT(Obj ml, Obj mr)
{
    UInt l1, l2, l, i;
    Int  c;
    l1 = INT_INTOBJ(ELM_PLIST(ml, 1));
    l2 = INT_INTOBJ(ELM_PLIST(mr, 1));
    l = (l1 < l2) ? l1 : l2;
    for (i = 2; i <= l + 1; i++) {
        c = Cmp_GF2VEC_GF2VEC(ELM_PLIST(ml, i), ELM_PLIST(mr, i));
        if (c != 0)
            return c;
    }
    if (l1 < l2)
        return -1;
    if (l1 > l2)
        return 1;
    return 0;
}

/****************************************************************************
**
*F  FuncEQ_GF2MAT_GF2MAT( <ml>, <mr> )   compare GF2 matrices
*/

static Obj FuncEQ_GF2MAT_GF2MAT(Obj self, Obj ml, Obj mr)
{
    if (ELM_PLIST(ml, 1) != ELM_PLIST(mr, 1))
        return False;
    return (0 == Cmp_GF2MAT_GF2MAT(ml, mr)) ? True : False;
}

/****************************************************************************
**
*F  FuncLT_GF2MAT_GF2MAT( <ml>, <mr> )   compare GF2 matrices
*/

static Obj FuncLT_GF2MAT_GF2MAT(Obj self, Obj ml, Obj mr)
{
    return (Cmp_GF2MAT_GF2MAT(ml, mr) < 0) ? True : False;
}

/****************************************************************************
**
*F  DistGF2Vecs( <ptL>, <ptR>, <len> )
**
**  computes the GF2-vector distance of two blocks in memory, pointed to by
**  ptL and ptR for a GF(2) vector of <len> entries.
**
*/
static UInt DistGF2Vecs(const UInt * ptL, const UInt * ptR, UInt len)
{
    UInt         sum, m;
    const UInt * end;    // end marker

    /*T this  function will not work if the vectors have more than 2^28
     * entries */

    end = ptL + ((len + BIPEB - 1) / BIPEB);
    sum = 0;
    // loop over the entries
    // T possibly unroll this loop
    while (ptL < end) {
        m = *ptL++ ^ *ptR++;    // xor of bits, nr bits therein is difference
        sum += COUNT_TRUES_BLOCK(m);
    }
    return sum;
}

/****************************************************************************
**
*F  FuncDIST_GF2VEC_GF2VEC( <self>, <vl>, <vr> )
**
**  'FuncDIST_GF2VEC_GF2VEC' returns the number of position in which two
**  gf2-vectors <vl>  and  <vr> differ.
*/
static Obj FuncDIST_GF2VEC_GF2VEC(Obj self, Obj vl, Obj vr)
{
    UInt   len;    // length of the list
    UInt   off;    // bit offset at the end to clean out
    UInt * ptL;    // bit field of <vl>
    UInt * ptR;    // bit field of <vr>
    UInt * end;    // pointer used to zero out end bit
    // get and check the length
    len = LEN_GF2VEC(vl);

    if (len != LEN_GF2VEC(vr)) {
        ErrorMayQuit("DIST_GF2VEC_GF2VEC: vectors must have the same length",
                     0, 0);
    }

    // calculate the offsets
    ptL = BLOCKS_GF2VEC(vl);
    ptR = BLOCKS_GF2VEC(vr);

    // mask out the last bits
    off = (len - 1) % BIPEB + 1;    // number of significant bits in last word
    off = BIPEB - off;    // number of insignificant bits in last word
    end = ptL + ((len - 1) / BIPEB);
    *end &= ALL_BITS_UINT >> off;
    end = ptR + ((len - 1) / BIPEB);
    *end &= ALL_BITS_UINT >> off;

    return INTOBJ_INT(DistGF2Vecs(ptL, ptR, len));
}


static void DistVecClosVec(
    Obj  veclis,    // pointers to matrix vectors and their multiples
    Obj  ovec,      // vector we compute distance to
    Obj  d,         // distances list
    Obj  osum,      // position of the sum vector
    UInt pos,       // recursion depth
    UInt l,         // length of basis
    UInt len)       // length of the involved vectors
{
    UInt         i;
    UInt         di;
    Obj          cnt;
    Obj          vp;
    const UInt * vec;
    Obj          one;
    Obj          tmp;

    vec = CONST_BLOCKS_GF2VEC(ovec);
    vp = ELM_PLIST(veclis, pos);
    one = INTOBJ_INT(1);

    for (i = 0; i <= 1; i++) {
        if (pos < l) {
            DistVecClosVec(veclis, ovec, d, osum, pos + 1, l, len);
        }
        else {
            di = DistGF2Vecs(CONST_BLOCKS_GF2VEC(osum), vec, len);

            cnt = ELM_PLIST(d, di + 1);
            if (IS_INTOBJ(cnt) && SUM_INTOBJS(tmp, cnt, one)) {
                cnt = tmp;
                SET_ELM_PLIST(d, di + 1, cnt);
            }
            else {
                cnt = SumInt(cnt, one);
                vec = CONST_BLOCKS_GF2VEC(ovec);
                SET_ELM_PLIST(d, di + 1, cnt);
                CHANGED_BAG(d);
            }
        }
        AddGF2VecToGF2Vec(BLOCKS_GF2VEC(osum),
                          CONST_BLOCKS_GF2VEC(ELM_PLIST(vp, i + 1)), len);
    }
}

static Obj FuncDIST_VEC_CLOS_VEC(
    Obj self,
    Obj veclis,    // pointers to matrix vectors and their multiples
    Obj vec,       // vector we compute distance to
    Obj d)         // distances list

{
    Obj  sum;    // sum vector
    UInt len;

    len = LEN_GF2VEC(vec);

    // get space for sum vector
    NEW_GF2VEC(sum, TYPE_LIST_GF2VEC, len);

    // do the recursive work
    DistVecClosVec(veclis, vec, d, sum, 1, LEN_PLIST(veclis), len);

    return (Obj)0;
}

static UInt
AClosVec(Obj  veclis,    // pointers to matrix vectors and their multiples
         Obj  ovec,      // vector we compute distance to
         Obj  osum,      // position of the sum vector
         UInt pos,       // recursion depth
         UInt l,         // length of basis
         UInt len,       // length of the involved vectors
         UInt cnt,       // numbr of vectors used
         UInt stop,      // stop value
         UInt bd,        // best distance so far
         Obj  obv,       // best vector so far
         Obj  coords,    // coefficients to get current vector
         Obj  bcoords    // coefficients to get best vector
)
{
    UInt         di;
    Obj          vp;
    UInt *       sum;
    UInt *       bv;
    const UInt * vec;
    const UInt * end;
    const UInt * w;


    // maybe we don't add this basis vector -- if this leaves us enough
    // possibilitiies
    if (pos + cnt < l) {
        bd = AClosVec(veclis, ovec, osum, pos + 1, l, len, cnt, stop, bd, obv,
                      coords, bcoords);
        if (bd <= stop) {
            return bd;
        }
    }


    // Otherwise we do

    vec = CONST_BLOCKS_GF2VEC(ovec);
    sum = BLOCKS_GF2VEC(osum);
    vp = ELM_PLIST(veclis, pos);
    w = CONST_BLOCKS_GF2VEC(ELM_PLIST(vp, 1));
    AddGF2VecToGF2Vec(sum, w, len);

    if (coords != (Obj)0) {
        SET_ELM_PLIST(coords, pos, INTOBJ_INT(1));
    }


    if (cnt == 0)    // this is a candidate
    {
        di = DistGF2Vecs(sum, vec, len);
        if (di < bd) {

            // store new result
            bd = di;
            bv = BLOCKS_GF2VEC(obv);
            end = bv + ((len + BIPEB - 1) / BIPEB);
            while (bv < end)
                *bv++ = *sum++;
            sum = BLOCKS_GF2VEC(osum);
            if (coords != (Obj)0) {
                UInt i;
                for (i = 1; i <= l; i++) {
                    Obj x;
                    x = ELM_PLIST(coords, i);
                    SET_ELM_PLIST(bcoords, i, x);
                }
            }
        }
    }
    else    // need to add in some more
    {
        bd = AClosVec(veclis, ovec, osum, pos + 1, l, len, cnt - 1, stop, bd,
                      obv, coords, bcoords);
        if (bd <= stop) {
            return bd;
        }
    }

    // reset component
    AddGF2VecToGF2Vec(sum, w, len);
    if (coords != (Obj)0) {
        SET_ELM_PLIST(coords, pos, INTOBJ_INT(0));
    }

    TakeInterrupt();
    return bd;
}


static Obj FuncA_CLOS_VEC(
    Obj self,
    Obj veclis,    // pointers to matrix vectors and their multiples
    Obj vec,       // vector we compute distance to
    Obj cnt,       // distances list
    Obj stop)      // distances list

{
    Obj  sum;     // sum vector
    Obj  best;    // best vector
    UInt len;

    len = LEN_GF2VEC(vec);

    RequireNonnegativeSmallInt(SELF_NAME, cnt);
    RequireNonnegativeSmallInt(SELF_NAME, stop);

    // get space for sum vector and zero out
    NEW_GF2VEC(sum, TYPE_LIST_GF2VEC, len);
    NEW_GF2VEC(best, TYPE_LIST_GF2VEC, len);

    // do the recursive work
    AClosVec(veclis, vec, sum, 1, LEN_PLIST(veclis), len, INT_INTOBJ(cnt),
             INT_INTOBJ(stop), len + 1,    // maximal value +1
             best, (Obj)0, (Obj)0);

    return best;
}

static Obj FuncA_CLOS_VEC_COORDS(
    Obj self,
    Obj veclis,    // pointers to matrix vectors and their multiples
    Obj vec,       // vector we compute distance to
    Obj cnt,       // distances list
    Obj stop)      // distances list

{
    Obj  sum;        // sum vector
    Obj  best;       // best vector
    Obj  coords;     // coefficients of mat to get current
    Obj  bcoords;    // coefficients of mat to get best
    Obj  res;        // length 2 plist for results
    UInt len, len2, i;

    len = LEN_GF2VEC(vec);
    len2 = LEN_PLIST(veclis);

    RequireNonnegativeSmallInt(SELF_NAME, cnt);
    RequireNonnegativeSmallInt(SELF_NAME, stop);

    // get space for sum vector and zero out
    NEW_GF2VEC(sum, TYPE_LIST_GF2VEC, len);
    NEW_GF2VEC(best, TYPE_LIST_GF2VEC, len);

    coords = NEW_PLIST(T_PLIST_CYC, len2);
    SET_LEN_PLIST(coords, len2);

    bcoords = NEW_PLIST(T_PLIST_CYC, len2);
    SET_LEN_PLIST(bcoords, len2);

    for (i = 1; i <= len2; i++) {
        SET_ELM_PLIST(coords, i, INTOBJ_INT(0));
        SET_ELM_PLIST(bcoords, i, INTOBJ_INT(0));
    }

    // do the recursive work
    AClosVec(veclis, vec, sum, 1, len2, len, INT_INTOBJ(cnt),
             INT_INTOBJ(stop), len + 1,    // maximal value +1
             best, coords, bcoords);

    res = NEW_PLIST(T_PLIST_DENSE_NHOM, 2);
    SET_LEN_PLIST(res, 2);
    SET_ELM_PLIST(res, 1, best);
    SET_ELM_PLIST(res, 2, bcoords);
    CHANGED_BAG(res);
    return res;
}

/****************************************************************************
**
*F  FuncCOSET_LEADERS_INNER_GF2(<self>,<veclis>,<weight>,<tofind>,<leaders>)
**
** Search for new coset leaders of weight <weight>
*/

static UInt CosetLeadersInnerGF2(
    Obj veclis, Obj v, Obj w, UInt weight, UInt pos, Obj leaders, UInt tofind)
{
    UInt found = 0;
    UInt len = LEN_GF2VEC(v);
    UInt lenw = LEN_GF2VEC(w);
    UInt sy;
    UInt u0;
    Obj  vc;
    UInt i;

    // We know that the length of w does not exceed BIPEB -4 here
    // (or there would not be room in a PLIST for all the coset leaders).
    // We use this to do a lot of GF2 vector operations for w "in-place"
    //
    // Even more in this direction could be done, but this no longer
    // the rate-determining step for any feasible application

    if (weight == 1) {
        for (i = pos; i <= len; i++) {
            u0 = CONST_BLOCKS_GF2VEC(ELM_PLIST(ELM_PLIST(veclis, i), 1))[0];
            BLOCKS_GF2VEC(w)[0] ^= u0;
            BLOCK_ELM_GF2VEC(v, i) |= MASK_POS_GF2VEC(i);

            sy = revertbits(CONST_BLOCKS_GF2VEC(w)[0], lenw);
            if ((Obj)0 == ELM_PLIST(leaders, sy + 1)) {
                NEW_GF2VEC(vc, TYPE_LIST_GF2VEC_IMM, len);
                memcpy(BLOCKS_GF2VEC(vc), CONST_BLOCKS_GF2VEC(v),
                       NUMBER_BLOCKS_GF2VEC(v) * sizeof(UInt));
                SET_ELM_PLIST(leaders, sy + 1, vc);
                CHANGED_BAG(leaders);
                if (++found == tofind)
                    return found;
            }
            BLOCKS_GF2VEC(w)[0] ^= u0;
            BLOCK_ELM_GF2VEC(v, i) &= ~MASK_POS_GF2VEC(i);
        }
    }
    else {
        if (pos + weight <= len) {
            found += CosetLeadersInnerGF2(veclis, v, w, weight, pos + 1,
                                          leaders, tofind);
            if (found == tofind)
                return found;
        }
        u0 = CONST_BLOCKS_GF2VEC(ELM_PLIST(ELM_PLIST(veclis, pos), 1))[0];
        BLOCKS_GF2VEC(w)[0] ^= u0;
        BLOCK_ELM_GF2VEC(v, pos) |= MASK_POS_GF2VEC(pos);
        found += CosetLeadersInnerGF2(veclis, v, w, weight - 1, pos + 1,
                                      leaders, tofind - found);
        if (found == tofind)
            return found;
        BLOCKS_GF2VEC(w)[0] ^= u0;
        BLOCK_ELM_GF2VEC(v, pos) &= ~MASK_POS_GF2VEC(pos);
    }
    TakeInterrupt();
    return found;
}


static Obj FuncCOSET_LEADERS_INNER_GF2(
    Obj self, Obj veclis, Obj weight, Obj tofind, Obj leaders)
{
    Obj  v, w;
    UInt lenv, lenw;

    RequireSmallInt(SELF_NAME, weight);
    RequireSmallInt(SELF_NAME, tofind);

    lenv = LEN_PLIST(veclis);
    NEW_GF2VEC(v, TYPE_LIST_GF2VEC, lenv);
    lenw = LEN_GF2VEC(ELM_PLIST(ELM_PLIST(veclis, 1), 1));
    NEW_GF2VEC(w, TYPE_LIST_GF2VEC, lenw);
    if (lenw > BIPEB - 4)
        ErrorMayQuit("COSET_LEADERS_INNER_GF2: too many cosets to return the "
                     "leaders in a plain list",
                     0, 0);
    return INTOBJ_INT(CosetLeadersInnerGF2(veclis, v, w, INT_INTOBJ(weight),
                                           1, leaders, INT_INTOBJ(tofind)));
}

/****************************************************************************
**
*F  Polynomial Arithmetic Support
*/


/****************************************************************************
**
*F  FuncRIGHTMOST_NONZERO_GF2VEC (<self>, <vec> )
**
*/

static Obj FuncRIGHTMOST_NONZERO_GF2VEC(Obj self, Obj vec)
{
    return INTOBJ_INT(RightMostOneGF2Vec(vec));
}

/****************************************************************************
**
*F  ResizeGF2Vec( <vec>, <newlen>, <clean> )
**
*/

static void ResizeGF2Vec(Obj vec, UInt newlen)
{
    UInt   len;
    UInt * ptr;
    UInt * nptr;
    UInt   off;
    len = LEN_GF2VEC(vec);
    if (len == newlen)
        return;
    if (True == DoFilter(IsLockedRepresentationVector, vec)) {
        ErrorMayQuit("Resize of locked compressed vector is forbidden", 0, 0);
    }


    if (newlen > len) {
        ResizeWordSizedBag(vec, SIZE_PLEN_GF2VEC(newlen));

        // now clean remainder of last block
        if (len == 0)
            ptr = BLOCKS_GF2VEC(vec);
        else {
            ptr = BLOCKS_GF2VEC(vec) + (len - 1) / BIPEB;
            off = BIPEB - ((len - 1) % BIPEB +
                           1);    // number of insignificant bits in last word
            *ptr &= ALL_BITS_UINT >> off;
            ptr++;
        }

        // and clean new blocks -- shouldn't need to do this, but
        // it's very cheap

        // newlen can't be zero here, since it is bigger than len
        nptr = BLOCKS_GF2VEC(vec) + (newlen - 1) / BIPEB;
        while (ptr <= nptr)
            *ptr++ = 0;

        SET_LEN_GF2VEC(vec, newlen);
        return;
    }
    else {
        // clean remainder of new last block, if any
        if (newlen % BIPEB) {
            ptr = BLOCKS_GF2VEC(vec) + (newlen - 1) / BIPEB;
            off = BIPEB - ((newlen - 1) % BIPEB + 1);
            *ptr &= ALL_BITS_UINT >> off;
        }
        SET_LEN_GF2VEC(vec, newlen);
        ResizeWordSizedBag(vec, SIZE_PLEN_GF2VEC(newlen));
        return;
    }
}

/****************************************************************************
**
*F  FuncRESIZE_GF2VEC( <self>, <vec>, <newlen> )
**
*/

static Obj FuncRESIZE_GF2VEC(Obj self, Obj vec, Obj newlen)
{
    RequireMutable(SELF_NAME, vec, "vector");
    RequireNonnegativeSmallInt(SELF_NAME, newlen);
    ResizeGF2Vec(vec, INT_INTOBJ(newlen));
    return (Obj)0;
}


/****************************************************************************
**
*F  ShiftLeftGF2Vec( <vec>, <amount> )
**
*/

static void ShiftLeftGF2Vec(Obj vec, UInt amount)
{
    UInt  len;
    UInt *ptr1, *ptr2;
    UInt  i;
    UInt  block;
    UInt  off;
    if (amount == 0)
        return;
    len = LEN_GF2VEC(vec);
    if (amount >= len) {
        ResizeGF2Vec(vec, 0);
        return;
    }
    if (amount % BIPEB == 0) {
        ptr1 = BLOCKS_GF2VEC(vec);
        ptr2 = ptr1 + amount / BIPEB;
        for (i = 0; i < (len - amount + BIPEB - 1) / BIPEB; i++)
            *ptr1++ = *ptr2++;
    }
    else {
        ptr1 = BLOCKS_GF2VEC(vec);
        ptr2 = ptr1 + amount / BIPEB;
        off = amount % BIPEB;
        for (i = 0; i < (len - amount + BIPEB - 1) / BIPEB - 1; i++) {
            block = (*ptr2++) >> off;
            block |= (*ptr2) << (BIPEB - off);
            *ptr1++ = block;
        }
        // Handle last block separately to avoid reading off end of Bag
        block = (*ptr2++) >> off;
        if (ptr2 < BLOCKS_GF2VEC(vec) + NUMBER_BLOCKS_GF2VEC(vec))
            block |= (*ptr2) << (BIPEB - off);
        *ptr1 = block;
    }
    ResizeGF2Vec(vec, len - amount);
}

/****************************************************************************
**
*F  FuncSHIFT_LEFT_GF2VEC(<self>, <vec>, <amount> )
**
*/

static Obj FuncSHIFT_LEFT_GF2VEC(Obj self, Obj vec, Obj amount)
{
    RequireMutable(SELF_NAME, vec, "vector");
    RequireNonnegativeSmallInt(SELF_NAME, amount);
    ShiftLeftGF2Vec(vec, INT_INTOBJ(amount));
    return (Obj)0;
}

/****************************************************************************
**
*F  ShiftRightGF2Vec( <vec>, <amount> )
**
*/

static void ShiftRightGF2Vec(Obj vec, UInt amount)
{
    UInt  len;
    UInt *ptr1, *ptr2, *ptr0;
    UInt  i;
    UInt  block;
    UInt  off;
    if (amount == 0)
        return;
    len = LEN_GF2VEC(vec);
    ResizeGF2Vec(vec, len + amount);
    if (amount % BIPEB == 0) {
        // move the blocks
        ptr1 = BLOCKS_GF2VEC(vec) + (len - 1 + amount) / BIPEB;
        ptr2 = ptr1 - amount / BIPEB;
        for (i = 0; i < (len + BIPEB - 1) / BIPEB; i++)
            *ptr1-- = *ptr2--;

        // and fill with zeroes
        ptr2 = BLOCKS_GF2VEC(vec);
        while (ptr1 >= ptr2)
            *ptr1-- = 0;
    }
    else {
        ptr1 = BLOCKS_GF2VEC(vec) + (len - 1 + amount) / BIPEB;
        ptr2 = ptr1 - amount / BIPEB;    // this can sometimes be the block
                                         // AFTER the old last block, but this
                                         // must be OK
        off = amount % BIPEB;
        ptr0 = BLOCKS_GF2VEC(vec);
        while (1) {
            block = (*ptr2--) << off;
            if (ptr2 < ptr0)
                break;
            block |= (*ptr2) >> (BIPEB - off);
            *ptr1-- = block;
        }
        *ptr1-- = block;
        while (ptr1 >= ptr0)
            *ptr1-- = 0;
    }
}

/****************************************************************************
**
*F  FuncSHIFT_RIGHT_GF2VEC(<self>, <vec>, <amount>, <zero> )
**
*/

static Obj FuncSHIFT_RIGHT_GF2VEC(Obj self, Obj vec, Obj amount, Obj zero)
{
    RequireMutable(SELF_NAME, vec, "vector");
    RequireNonnegativeSmallInt(SELF_NAME, amount);
    ShiftRightGF2Vec(vec, INT_INTOBJ(amount));
    return (Obj)0;
}

// ReduceCoeffs

/****************************************************************************
**
*F  AddShiftedVecGF2VecGF2( <vec1>, <vec2>, <len2>, <off> )
**
*/

static void AddShiftedVecGF2VecGF2(Obj vec1, Obj vec2, UInt len2, UInt off)
{
    UInt *       ptr1;
    const UInt * ptr2;
    UInt         i;
    UInt         block;
    UInt         shift1, shift2;
    if (off % BIPEB == 0) {
        ptr1 = BLOCKS_GF2VEC(vec1) + off / BIPEB;
        ptr2 = CONST_BLOCKS_GF2VEC(vec2);
        for (i = 0; i < (len2 - 1) / BIPEB; i++)
            *ptr1++ ^= *ptr2++;
        block = *ptr2;
        block &= (ALL_BITS_UINT >> (BIPEB - (len2 - 1) % BIPEB - 1));
        *ptr1 ^= block;
    }
    else {
        ptr1 = BLOCKS_GF2VEC(vec1) + off / BIPEB;
        ptr2 = CONST_BLOCKS_GF2VEC(vec2);
        shift1 = off % BIPEB;
        shift2 = BIPEB - off % BIPEB;
        for (i = 0; i < len2 / BIPEB; i++) {
            *ptr1++ ^= *ptr2 << shift1;
            *ptr1 ^= *ptr2++ >> shift2;
        }

        if (len2 % BIPEB) {
            block = *ptr2;
            block &= ALL_BITS_UINT >> (BIPEB - (len2 - 1) % BIPEB - 1);
            *ptr1++ ^= block << shift1;
            if (len2 % BIPEB + off % BIPEB > BIPEB) {
                assert(ptr1 < BLOCKS_GF2VEC(vec1) +
                                  (LEN_GF2VEC(vec1) + BIPEB - 1) / BIPEB);
                *ptr1 ^= block >> shift2;
            }
        }
    }
}

/****************************************************************************
**
*F FuncADD_GF2VEC_GF2VEC_SHIFTED( <self>, <vec1>, <vec2>, <len2>, <off> )
**
*/

static Obj
FuncADD_GF2VEC_GF2VEC_SHIFTED(Obj self, Obj vec1, Obj vec2, Obj len2, Obj off)
{
    RequireNonnegativeSmallInt(SELF_NAME, off);
    RequireNonnegativeSmallInt(SELF_NAME, len2);
    Int off1 = INT_INTOBJ(off);
    Int len2a = INT_INTOBJ(len2);
    if (len2a >= LEN_GF2VEC(vec2)) {
        ErrorMayQuit(
            "ADD_GF2VEC_GF2VEC_SHIFTED: <len2> must be a non-negative "
            "integer less than the actual length of the vector",
            0, 0);
    }
    if (len2a + off1 > LEN_GF2VEC(vec1))
        ResizeGF2Vec(vec1, len2a + off1);
    AddShiftedVecGF2VecGF2(vec1, vec2, len2a, off1);
    return (Obj)0;
}

/****************************************************************************
**
*F  ProductCoeffsGF2Vec( <vec1>, <len1>, <vec2>, <len2> )
**
*/

static Obj ProductCoeffsGF2Vec(Obj vec1, UInt len1, Obj vec2, UInt len2)
{
    Obj          prod;
    UInt         i, e;
    const UInt * ptr;
    UInt         block = 0;
    UInt         len;
    if (len1 == 0 && len2 == 0)
        len = 0;
    else
        len = len1 + len2 - 1;
    NEW_GF2VEC(prod, TYPE_LIST_GF2VEC, len);

    // better to do the longer loop on the inside
    if (len2 < len1) {
        UInt tmp;
        Obj  tmpv;
        tmp = len1;
        len1 = len2;
        len2 = tmp;
        tmpv = vec1;
        vec1 = vec2;
        vec2 = tmpv;
    }

    ptr = CONST_BLOCKS_GF2VEC(vec1);
    e = BIPEB;
    for (i = 0; i < len1; i++) {
        if (e == BIPEB) {
            block = *ptr++;
            e = 0;
        }
        if (block & ((UInt)1 << e++))
            AddShiftedVecGF2VecGF2(prod, vec2, len2, i);
    }
    return prod;
}

/****************************************************************************
**
*F  FuncPROD_COEFFS_GF2VEC( <self>, <vec1>, <len1>, <vec2>, <len2> )
**
*/

static Obj
FuncPROD_COEFFS_GF2VEC(Obj self, Obj vec1, Obj len1, Obj vec2, Obj len2)
{
    UInt len1a, len2a;
    Obj  prod;
    UInt last;

    RequireSmallInt(SELF_NAME, len1);
    RequireSmallInt(SELF_NAME, len2);
    len2a = INT_INTOBJ(len2);
    if (len2a > LEN_GF2VEC(vec2))
        ErrorMayQuit("PROD_COEFFS_GF2VEC: <len2> must not be more than the "
                     "actual\nlength of the vector",
                     0, 0);
    len1a = INT_INTOBJ(len1);
    if (len1a > LEN_GF2VEC(vec1))
        ErrorMayQuit("PROD_COEFFS_GF2VEC: <len1> must be not more than the "
                     "actual\nlength of the vector",
                     0, 0);
    prod = ProductCoeffsGF2Vec(vec1, len1a, vec2, len2a);
    last = RightMostOneGF2Vec(prod);
    if (last < LEN_GF2VEC(prod))
        ResizeGF2Vec(prod, last);
    return prod;
}

/****************************************************************************
**
*F  ReduceCoeffsGF2Vec(<vec1>, <vec2>, <len2>, <quotient> )
**
*/

static void ReduceCoeffsGF2Vec(Obj vec1, Obj vec2, UInt len2, Obj quotient)
{
    UInt         len1 = LEN_GF2VEC(vec1);
    UInt         i, j, e;
    const UInt * ptr;
    UInt *       qptr = (UInt *)0;
    if (len2 > len1)
        return;
    i = len1 - 1;
    e = (i % BIPEB);
    ptr = CONST_BLOCKS_GF2VEC(vec1) + (i / BIPEB);
    if (quotient != (Obj)0)
        qptr = BLOCKS_GF2VEC(quotient);
    j = len1 - len2 + 1;
    while (i + 1 >= len2) {
        if (*ptr & ((UInt)1 << e)) {
            AddShiftedVecGF2VecGF2(vec1, vec2, len2, i - len2 + 1);
            if (qptr)
                qptr[(j - 1) / BIPEB] |= MASK_POS_GF2VEC(j);
        }
        assert(!(*ptr & ((UInt)1 << e)));
        if (e == 0) {
            e = BIPEB - 1;
            ptr--;
        }
        else
            e--;
        i--;
        j--;
    }
}

/****************************************************************************
**
*F  FuncREDUCE_COEFFS_GF2VEC( <self>, <vec1>, <len1>, <vec2>, <len2> )
**
*/
static Obj
FuncREDUCE_COEFFS_GF2VEC(Obj self, Obj vec1, Obj len1, Obj vec2, Obj len2)
{
    UInt last;
    Int  len2a;
    RequireNonnegativeSmallInt(SELF_NAME, len1);
    RequireNonnegativeSmallInt(SELF_NAME, len2);
    if (INT_INTOBJ(len1) > LEN_GF2VEC(vec1))
        ErrorMayQuit("ReduceCoeffs: given length <len1> of left argt "
                     "(%d)\nis longer than the argt (%d)",
                     INT_INTOBJ(len1), LEN_GF2VEC(vec1));
    len2a = INT_INTOBJ(len2);
    if (len2a > LEN_GF2VEC(vec2))
        ErrorMayQuit("ReduceCoeffs: given length <len2> of right argt "
                     "(%d)\nis longer than the argt (%d)",
                     len2a, LEN_GF2VEC(vec2));
    ResizeGF2Vec(vec1, INT_INTOBJ(len1));

    while (0 < len2a) {
        if (CONST_BLOCK_ELM_GF2VEC(vec2, len2a) == 0)
            len2a = BIPEB * ((len2a - 1) / BIPEB);
        else if (CONST_BLOCK_ELM_GF2VEC(vec2, len2a) & MASK_POS_GF2VEC(len2a))
            break;
        else
            len2a--;
    }

    if (len2a == 0) {
        ErrorReturnVoid("ReduceCoeffs: second argument must not be zero", 0,
                        0, "you may 'return;' to skip the reduction");
        return 0;
    }

    ReduceCoeffsGF2Vec(vec1, vec2, len2a, (Obj)0);
    last = RightMostOneGF2Vec(vec1);
    ResizeGF2Vec(vec1, last);
    return INTOBJ_INT(last);
}

/****************************************************************************
**
*F  FuncQUOTREM_COEFFS_GF2VEC( <self>, <vec1>, <len1>, <vec2>, <len2> )
**
*/
static Obj
FuncQUOTREM_COEFFS_GF2VEC(Obj self, Obj vec1, Obj len1, Obj vec2, Obj len2)
{
    Int len2a;
    Int len1a = INT_INTOBJ(len1);
    Obj quotv, remv, ret;
    RequireNonnegativeSmallInt(SELF_NAME, len1);
    RequireNonnegativeSmallInt(SELF_NAME, len2);
    if (INT_INTOBJ(len1) > LEN_GF2VEC(vec1))
        ErrorMayQuit("QuotremCoeffs: given length <len1> of left argt "
                     "(%d)\nis longer than the argt (%d)",
                     INT_INTOBJ(len1), LEN_GF2VEC(vec1));
    len2a = INT_INTOBJ(len2);
    if (len2a > LEN_GF2VEC(vec2))
        ErrorMayQuit("QuotremCoeffs: given length <len2> of right argt "
                     "(%d)\nis longer than the argt (%d)",
                     len2a, LEN_GF2VEC(vec2));

    while (0 < len2a) {
        if (CONST_BLOCK_ELM_GF2VEC(vec2, len2a) == 0)
            len2a = BIPEB * ((len2a - 1) / BIPEB);
        else if (CONST_BLOCK_ELM_GF2VEC(vec2, len2a) & MASK_POS_GF2VEC(len2a))
            break;
        else
            len2a--;
    }
    if (len2a == 0) {
        ErrorReturnVoid("QuotremCoeffs: second argument must not be zero", 0,
                        0, "you may 'return;' to skip the reduction");
        return 0;
    }

    NEW_GF2VEC(remv, TYPE_LIST_GF2VEC, len1a);
    memcpy(BLOCKS_GF2VEC(remv), CONST_BLOCKS_GF2VEC(vec1),
           ((len1a + BIPEB - 1) / BIPEB) * sizeof(UInt));

    NEW_GF2VEC(quotv, TYPE_LIST_GF2VEC, len1a - len2a + 1);
    ReduceCoeffsGF2Vec(remv, vec2, len2a, quotv);

    ret = NEW_PLIST(T_PLIST_TAB, 2);
    SET_LEN_PLIST(ret, 2);

    SET_ELM_PLIST(ret, 1, quotv);
    SET_ELM_PLIST(ret, 2, remv);

    CHANGED_BAG(ret);

    return ret;
}


/****************************************************************************
**
*F  FuncSEMIECHELON_LIST_GF2VECS( <self>, <mat> )
**
**  Method for SemiEchelonMat for plain lists of GF2 vectors
**
**  Method selection can guarantee us a plain list of characteristic 2
**  vectors
*/

static Obj FuncSEMIECHELON_LIST_GF2VECS(Obj self, Obj mat)
{
    UInt i, len;
    UInt width;
    Obj  row;
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row))
        return TRY_NEXT_METHOD;
    width = LEN_GF2VEC(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row) ||
            LEN_GF2VEC(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    return SemiEchelonListGF2Vecs(mat, 0);
}

/****************************************************************************
**
*F  FuncSEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS( <self>, <mat> )
**
**  Method for SemiEchelonMatTransformations for plain lists of GF2 vectors
**
**  Method selection can guarantee us a plain list of characteristic 2
**  vectors
*/

static Obj FuncSEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS(Obj self, Obj mat)
{
    UInt i, len;
    UInt width;
    Obj  row;
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row))
        return TRY_NEXT_METHOD;
    width = LEN_GF2VEC(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row) ||
            LEN_GF2VEC(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    return SemiEchelonListGF2Vecs(mat, 1);
}

/****************************************************************************
**
*F  FuncTRIANGULIZE_LIST_GF2VECS( <self>, <mat> )
**
*/

static Obj FuncTRIANGULIZE_LIST_GF2VECS(Obj self, Obj mat)
{
    UInt i, len;
    UInt width;
    Obj  row;
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row))
        return TRY_NEXT_METHOD;
    width = LEN_GF2VEC(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row) ||
            LEN_GF2VEC(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    TriangulizeListGF2Vecs(mat, 1);
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncRANK_LIST_GF2VECS( <self>, <mat> )
**
*/

static Obj FuncRANK_LIST_GF2VECS(Obj self, Obj mat)
{
    UInt i, len;
    UInt width;
    Obj  row;
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row))
        return TRY_NEXT_METHOD;
    width = LEN_GF2VEC(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row) ||
            LEN_GF2VEC(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    return INTOBJ_INT(TriangulizeListGF2Vecs(mat, 0));
}

/****************************************************************************
**
*F  FuncDETERMINANT_LIST_GF2VECS( <self>, <mat> )
**
*/

static Obj FuncDETERMINANT_LIST_GF2VECS(Obj self, Obj mat)
{
    UInt i, len;
    UInt width;
    Obj  row;
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row))
        return TRY_NEXT_METHOD;
    width = LEN_GF2VEC(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_MUTABLE_OBJ(row) || !IS_GF2VEC_REP(row) ||
            LEN_GF2VEC(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    return (len == TriangulizeListGF2Vecs(mat, 0)) ? GF2One : GF2Zero;
}

/****************************************************************************
**
*F  FuncKRONECKERPRODUCT_GF2MAT_GF2MAT( <self>, <matl>, <matr>)
**
*/

static Obj FuncKRONECKERPRODUCT_GF2MAT_GF2MAT(Obj self, Obj matl, Obj matr)
{
    UInt nrowl, nrowr, nrowp, ncoll, ncolr, ncolp, ncol, i, j, k, l, mutable;
    Obj  mat, type, row, shift[BIPEB];
    UInt *       data;
    const UInt * datar;

    nrowl = LEN_GF2MAT(matl);
    nrowr = LEN_GF2MAT(matr);
    nrowp = nrowl * nrowr;
    ncoll = LEN_GF2VEC(ELM_GF2MAT(matl, 1));
    ncolr = LEN_GF2VEC(ELM_GF2MAT(matr, 1));
    ncolp = ncoll * ncolr;

    mutable = IS_MUTABLE_OBJ(matl) || IS_MUTABLE_OBJ(matr);

    // create a matrix
    mat = NewBag(T_POSOBJ, SIZE_PLEN_GF2MAT(nrowp));
    SET_LEN_GF2MAT(mat, nrowp);
    if (mutable) {
        SET_TYPE_POSOBJ(mat, TYPE_LIST_GF2MAT);
        type = TYPE_LIST_GF2VEC_LOCKED;
    }
    else {
        SET_TYPE_POSOBJ(mat, TYPE_LIST_GF2MAT_IMM);
        type = TYPE_LIST_GF2VEC_IMM_LOCKED;
    }

    // allocate 0 matrix

    for (i = 1; i <= nrowp; i++) {
        NEW_GF2VEC(row, type, ncolp);
        SET_ELM_GF2MAT(mat, i, row);
        CHANGED_BAG(mat);
    }

    // allocate data for shifts of rows of matr
    for (i = 0; i < BIPEB; i++) {
        shift[i] = NewBag(T_DATOBJ, SIZE_PLEN_GF2VEC(ncolr + 2 * BIPEB));
    }

    // fill in matrix
    for (j = 1; j <= nrowr; j++) {
        // create shifts of rows of matr
        data = (UInt *)ADDR_OBJ(shift[0]);
        datar = CONST_BLOCKS_GF2VEC(ELM_GF2MAT(matr, j));
        for (k = 0; k < (ncolr + BIPEB - 1) / BIPEB; k++)
            data[k] = datar[k];
        data[k] = 0;

        for (i = 1; i < BIPEB; i++) {    // now shifts in [1..BIPEB-1]
            data = (UInt *)ADDR_OBJ(shift[i]);
            datar = CONST_BLOCKS_GF2VEC(ELM_GF2MAT(matr, j));
            data[0] = datar[0] << i;
            for (k = 1; k < (ncolr + BIPEB - 1) / BIPEB; k++)
                data[k] = (datar[k] << i) | (datar[k - 1] >> (BIPEB - i));
            data[k] = datar[k - 1] >> (BIPEB - i);
        }
        for (i = 1; i <= nrowl; i++) {
            data = BLOCKS_GF2VEC(ELM_GF2MAT(mat, (i - 1) * nrowr + j));
            ncol = 0;
            for (k = 1; k <= ncoll; k++) {
                l = 0;
                if (CONST_BLOCK_ELM_GF2VEC(ELM_GF2MAT(matl, i), k) &
                    MASK_POS_GF2VEC(k)) {
                    // append shift[ncol%BIPEB] to data
                    datar = (const UInt *)CONST_ADDR_OBJ(shift[ncol % BIPEB]);
                    if (ncol % BIPEB) {
                        data[-1] ^= *datar++;
                        l = BIPEB - ncol % BIPEB;
                    }
                    for (; l < ncolr; l += BIPEB)
                        *data++ = *datar++;
                }
                else {
                    if (ncol % BIPEB)
                        l = BIPEB - ncol % BIPEB;
                    data += (ncolr + BIPEB - 1 - l) / BIPEB;
                }
                ncol += ncolr;
            }
        }
    }

    return mat;
}


/****************************************************************************
**
*F  FuncMAT_ELM_GF2MAT( <self>, <mat>, <row>, <col> )
**
*/
static Obj FuncMAT_ELM_GF2MAT(Obj self, Obj mat, Obj row, Obj col)
{
    UInt r = GetPositiveSmallInt("MAT_ELM_GF2MAT", row);
    UInt c = GetPositiveSmallInt("MAT_ELM_GF2MAT", col);

    if (LEN_GF2MAT(mat) < r) {
        ErrorMayQuit("row index %d exceeds %d, the number of rows", r,
                     LEN_GF2MAT(mat));
    }

    Obj vec = ELM_GF2MAT(mat, r);

    if (LEN_GF2VEC(vec) < c) {
        ErrorMayQuit("column index %d exceeds %d, the number of columns", c,
                     LEN_GF2VEC(vec));
    }

    return ELM_GF2VEC(vec, c);
}


/****************************************************************************
**
*F  FuncSET_MAT_ELM_GF2MAT( <self>, <mat>, <row>, <col>, <elm> )
**
*/
static Obj
FuncSET_MAT_ELM_GF2MAT(Obj self, Obj mat, Obj row, Obj col, Obj elm)
{
    UInt r = GetPositiveSmallInt("SET_MAT_ELM_GF2MAT", row);
    UInt c = GetPositiveSmallInt("SET_MAT_ELM_GF2MAT", col);

    if (LEN_GF2MAT(mat) < r) {
        ErrorMayQuit("row index %d exceeds %d, the number of rows", r,
                     LEN_GF2MAT(mat));
    }

    Obj vec = ELM_GF2MAT(mat, r);
    if (!IS_MUTABLE_OBJ(vec)) {
        ErrorMayQuit("row %d is immutable", r, 0);
    }

    if (LEN_GF2VEC(vec) < c) {
        ErrorMayQuit("column index %d exceeds %d, the number of columns", c,
                     LEN_GF2VEC(vec));
    }

    if (EQ(GF2One, elm)) {
        BLOCK_ELM_GF2VEC(vec, c) |= MASK_POS_GF2VEC(c);
    }
    else if (EQ(GF2Zero, elm)) {
        BLOCK_ELM_GF2VEC(vec, c) &= ~MASK_POS_GF2VEC(c);
    }
    else {
        RequireArgumentEx(SELF_NAME, elm, 0,
                          "assigned element must be a GF(2) element");
    }

    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_1ARGS(CONV_GF2VEC, list),
    GVAR_FUNC_1ARGS(COPY_GF2VEC, list),
    GVAR_FUNC_1ARGS(PLAIN_GF2VEC, gf2vec),
    GVAR_FUNC_1ARGS(PLAIN_GF2MAT, gf2mat),
    GVAR_FUNC_2ARGS(EQ_GF2VEC_GF2VEC, gf2vec, gf2vec),
    GVAR_FUNC_2ARGS(LT_GF2VEC_GF2VEC, gf2vec, gf2vec),
    GVAR_FUNC_2ARGS(EQ_GF2MAT_GF2MAT, gf2mat, gf2mat),
    GVAR_FUNC_2ARGS(LT_GF2MAT_GF2MAT, gf2mat, gf2mat),
    GVAR_FUNC_1ARGS(LEN_GF2VEC, gf2vec),
    GVAR_FUNC_2ARGS(ELM0_GF2VEC, gf2vec, pos),
    GVAR_FUNC_2ARGS(ELM_GF2VEC, gf2vec, pos),
    GVAR_FUNC_2ARGS(ELMS_GF2VEC, gf2vec, poss),
    GVAR_FUNC_3ARGS(ASS_GF2VEC, gf2vec, pos, elm),
    GVAR_FUNC_2ARGS(ELM_GF2MAT, gf2mat, pos),
    GVAR_FUNC_3ARGS(ASS_GF2MAT, gf2mat, pos, elm),
    GVAR_FUNC_2ARGS(UNB_GF2VEC, gf2vec, pos),
    GVAR_FUNC_2ARGS(UNB_GF2MAT, gf2mat, pos),
    GVAR_FUNC_1ARGS(ZERO_GF2VEC, gf2vec),
    GVAR_FUNC_1ARGS(ZERO_GF2VEC_2, len),
    GVAR_FUNC_1ARGS(INV_GF2MAT_MUTABLE, gf2mat),
    GVAR_FUNC_1ARGS(INV_GF2MAT_SAME_MUTABILITY, gf2mat),
    GVAR_FUNC_1ARGS(INV_GF2MAT_IMMUTABLE, gf2mat),
    GVAR_FUNC_1ARGS(INV_PLIST_GF2VECS_DESTRUCTIVE, list),
    GVAR_FUNC_2ARGS(SUM_GF2VEC_GF2VEC, gf2vec, gf2vec),
    GVAR_FUNC_2ARGS(PROD_GF2VEC_GF2VEC, gf2vec, gf2vec),
    GVAR_FUNC_2ARGS(PROD_GF2VEC_GF2MAT, gf2vec, gf2mat),
    GVAR_FUNC_2ARGS(PROD_GF2MAT_GF2VEC, gf2mat, gf2vec),
    GVAR_FUNC_2ARGS(PROD_GF2MAT_GF2MAT, gf2matl, gf2matr),
    GVAR_FUNC_2ARGS(PROD_GF2MAT_GF2MAT_SIMPLE, gf2matl, gf2matr),
    GVAR_FUNC_4ARGS(PROD_GF2MAT_GF2MAT_ADVANCED,
                    gf2matl,
                    gf2matr,
                    greaselevel,
                    blocklevel),
    GVAR_FUNC_3ARGS(ADDCOEFFS_GF2VEC_GF2VEC_MULT, gf2vec, gf2vec, mul),
    GVAR_FUNC_2ARGS(ADDCOEFFS_GF2VEC_GF2VEC, gf2vec, gf2vec),
    GVAR_FUNC_1ARGS(SHRINKCOEFFS_GF2VEC, gf2vec),
    GVAR_FUNC_2ARGS(POSITION_NONZERO_GF2VEC, gf2vec, zero),
    GVAR_FUNC_3ARGS(POSITION_NONZERO_GF2VEC3, gf2vec, zero, from),
    GVAR_FUNC_2ARGS(MULT_VECTOR_GF2VECS_2, gf2vecl, mul),
    GVAR_FUNC_2ARGS(APPEND_GF2VEC, gf2vecl, gf2vecr),
    GVAR_FUNC_1ARGS(SHALLOWCOPY_GF2VEC, gf2vec),
    GVAR_FUNC_1ARGS(NUMBER_GF2VEC, gf2vec),
    GVAR_FUNC_1ARGS(TRANSPOSED_GF2MAT, gf2mat),
    GVAR_FUNC_2ARGS(DIST_GF2VEC_GF2VEC, gf2vec, gf2vec),
    GVAR_FUNC_3ARGS(DIST_VEC_CLOS_VEC, list, gf2vec, list),
    GVAR_FUNC_2ARGS(SUM_GF2MAT_GF2MAT, matl, matr),
    GVAR_FUNC_4ARGS(A_CLOS_VEC, list, gf2vec, int, int),
    GVAR_FUNC_4ARGS(A_CLOS_VEC_COORDS, list, gf2vec, int, int),
    GVAR_FUNC_4ARGS(COSET_LEADERS_INNER_GF2, veclis, weight, tofind, leaders),
    GVAR_FUNC_1ARGS(CONV_GF2MAT, list),
    GVAR_FUNC_2ARGS(PROD_GF2VEC_ANYMAT, vec, mat),
    GVAR_FUNC_1ARGS(RIGHTMOST_NONZERO_GF2VEC, vec),
    GVAR_FUNC_2ARGS(RESIZE_GF2VEC, vec, newlen),
    GVAR_FUNC_2ARGS(SHIFT_LEFT_GF2VEC, vec, amount),
    GVAR_FUNC_3ARGS(SHIFT_RIGHT_GF2VEC, vec, amount, zero),
    GVAR_FUNC_4ARGS(ADD_GF2VEC_GF2VEC_SHIFTED, vec1, vec2, len2, off),
    GVAR_FUNC_4ARGS(PROD_COEFFS_GF2VEC, vec1, len1, vec2, len2),
    GVAR_FUNC_4ARGS(REDUCE_COEFFS_GF2VEC, vec1, len1, vec2, len2),
    GVAR_FUNC_4ARGS(QUOTREM_COEFFS_GF2VEC, vec1, len1, vec2, len2),
    GVAR_FUNC_1ARGS(SEMIECHELON_LIST_GF2VECS, mat),
    GVAR_FUNC_1ARGS(SEMIECHELON_LIST_GF2VECS_TRANSFORMATIONS, mat),
    GVAR_FUNC_1ARGS(TRIANGULIZE_LIST_GF2VECS, mat),
    GVAR_FUNC_1ARGS(DETERMINANT_LIST_GF2VECS, mat),
    GVAR_FUNC_1ARGS(RANK_LIST_GF2VECS, mat),
    GVAR_FUNC_2ARGS(KRONECKERPRODUCT_GF2MAT_GF2MAT, mat, mat),
    GVAR_FUNC_5ARGS(COPY_SECTION_GF2VECS, src, dest, from, to, howmany),
    GVAR_FUNC_3ARGS(MAT_ELM_GF2MAT, mat, row, col),
    GVAR_FUNC_4ARGS(SET_MAT_ELM_GF2MAT, mat, row, col, elm),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    RNheads = 0;
    RNvectors = 0;
    RNcoeffs = 0;
    RNrelns = 0;

    // import type functions
    InitCopyGVar("TYPE_LIST_GF2VEC", &TYPE_LIST_GF2VEC);
    InitCopyGVar("TYPE_LIST_GF2VEC_IMM", &TYPE_LIST_GF2VEC_IMM);
    InitCopyGVar("TYPE_LIST_GF2VEC_IMM_LOCKED",
                          &TYPE_LIST_GF2VEC_IMM_LOCKED);
    InitCopyGVar("TYPE_LIST_GF2VEC_LOCKED",
                          &TYPE_LIST_GF2VEC_LOCKED);
    ImportFuncFromLibrary("IsGF2VectorRep", &IsGF2VectorRep);
    InitCopyGVar("TYPE_LIST_GF2MAT", &TYPE_LIST_GF2MAT);
    InitCopyGVar("TYPE_LIST_GF2MAT_IMM", &TYPE_LIST_GF2MAT_IMM);

    // initialize one and zero of GF2
    ImportGVarFromLibrary("GF2One", &GF2One);
    ImportGVarFromLibrary("GF2Zero", &GF2Zero);

    // init filters and functions
    InitHdlrFuncsFromTable(GVarFuncs);

    InitFopyGVar("IsLockedRepresentationVector",
                 &IsLockedRepresentationVector);

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
*F  InitInfoGF2Vec()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "vecgf2",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoGF2Vec(void)
{
    return &module;
}
