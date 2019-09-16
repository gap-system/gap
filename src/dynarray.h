/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  WARNING: This file should NOT be directly included. It is designed
**  to instantiate a generic dynamic array type based on #defines that
**  have to be set before including the file, and the file can be included
**  repeatedly with different parameters.
*/

// Parameters:
//
// #define ELEM_TYPE type of elements
// #define COMPARE comparison function for elements (optional)
// #define ALLOC allocation function (optional)
// #define DEALLOC deallocation function (optional)

#define Array JOIN(ELEM_TYPE, Array)

#define FN(sym) JOIN(Array, sym)

#define JOIN(s1, s2) JOIN2(s1, s2)
#define JOIN2(s1, s2) s1##s2

#ifndef ALLOC
#define ALLOC(T, n) ((T *)malloc(sizeof(T) * (n)))
#endif

#ifndef DEALLOC
#define DEALLOC(p) (free(p))
#endif

typedef struct {
    Int         len, cap;
    ELEM_TYPE * items;
} Array;

static inline Array * FN(Make)(Int cap)
{
    Array * arr;
    GAP_ASSERT(cap >= 0);
    if (cap == 0)
        cap = 1;
    arr = ALLOC(Array, 1);
    arr->cap = cap;
    arr->len = 0;
    arr->items = ALLOC(ELEM_TYPE, cap);
    return arr;
}

static inline void FN(Delete)(Array * arr)
{
    DEALLOC(arr->items);
    DEALLOC(arr);
}

static inline void FN(ExpandTo)(Array * arr, Int minlen)
{
    Int cap = arr->cap;
    GAP_ASSERT(minlen >= 0);
    if (minlen <= arr->cap)
        return;
    if (cap == 0)
        cap = 1;
    while (cap < minlen)
        cap *= 2;
    ELEM_TYPE * items = ALLOC(ELEM_TYPE, cap);
    memcpy(items, arr->items, sizeof(ELEM_TYPE) * arr->len);
    DEALLOC(arr->items);
    arr->items = items;
    arr->cap = cap;
}

static inline void FN(Shrink)(Array * arr)
{
    if (arr->cap > arr->len) {
        ELEM_TYPE * items = ALLOC(ELEM_TYPE, arr->len);
        memcpy(items, arr->items, sizeof(ELEM_TYPE) * arr->len);
        DEALLOC(arr->items);
        arr->items = items;
        arr->cap = arr->len;
    }
}

static inline Array * FN(Clone)(Array * arr)
{
    Array * clone = FN(Make)(arr->len);
    clone->len = arr->len;
    memcpy(clone->items, arr->items, sizeof(ELEM_TYPE) * arr->len);
    return clone;
}

static inline void FN(SetLen)(Array * arr, Int len)
{
    GAP_ASSERT(len <= arr->len);
    if (len < arr->len)
        arr->len = len;
}

static inline Int FN(Len)(Array * arr)
{
    return arr->len;
}

static inline ELEM_TYPE FN(Get)(Array * arr, Int i)
{
    GAP_ASSERT(i >= 0 && i < arr->len);
    return arr->items[i];
}

static inline void FN(Put)(Array * arr, Int i, ELEM_TYPE item)
{
    GAP_ASSERT(i >= 0 && i < arr->len);
    arr->items[i] = item;
}

static inline void FN(Add)(Array * arr, ELEM_TYPE item)
{
    FN(ExpandTo)(arr, arr->len + 1);
    arr->items[arr->len++] = item;
}

#ifdef COMPARE
static inline void FN(Sort)(Array * arr)
{
    Int len = arr->len;
    if (len <= 1)
        return;
    ELEM_TYPE * in = ALLOC(ELEM_TYPE, len);
    ELEM_TYPE * out = ALLOC(ELEM_TYPE, len);
    memcpy(in, arr->items, sizeof(ELEM_TYPE) * len);
    Int step = 1;
    while (step < len) {
        for (Int i = 0; i < len; i += step * 2) {
            Int p = i, l = i, r = i + step, lmax = l + step, rmax = r + step;
            if (rmax > len)
                rmax = len;
            if (lmax > len)
                lmax = len;
            while (l < lmax && r < rmax) {
                int c = COMPARE(in[l], in[r]);
                if (c < 0) {
                    out[p++] = in[l++];
                }
                else {
                    out[p++] = in[r++];
                }
            }
            while (l < lmax) {
                out[p++] = in[l++];
            }
            while (r < rmax) {
                out[p++] = in[r++];
            }
        }
        ELEM_TYPE * tmp = in;
        in = out;
        out = tmp;
        step += step;
    }
    DEALLOC(arr->items);
    DEALLOC(out);
    arr->items = in;
    arr->cap = len;    // we allocated only len items for 'in'.
}
#endif

#undef Array

#undef FN

#undef JOIN
#undef JOIN2

#undef ELEM_TYPE
#undef COMPARE
#undef ALLOC
#undef DEALLOC
