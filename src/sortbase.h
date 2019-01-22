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
**  to build all of the sort variants which GAP uses.
**
**
** This file provides a framework for expressing sort functions in a generic
** way, covering various options (provide comparator, optimised for Plists,
** and do SortParallel
**
** The following macros are used:
** SORT_FUNC_NAME        : Name of function
** SORT_FUNC_ARGS        : Arguments of function for use in prototypes
** SORT_ARGS             : Arguments of function for passing
** SORT_CREATE_LOCAL(t)   : Create a temp variable named t that can store
**                         an element of the list
** SORT_LEN_LIST         : Get the length of the list to be sorted
** SORT_ASS_LIST_TO_LOCAL(t,i) : Copy list element 'i' to temporary 't'
** SORT_ASS_LOCAL_TO_LIST(i,t) : Copy temporary 't' to list element 'i'
** SORT_COMP(v,w)             : Compare temporaries v and w
** SORT_FILTER_CHECKS         : Arbitary code to be called at end of function,
**                              to fix filters effected by the sorting.
**
**
** Design choices:
** Only temporaries can be compared, not list elements directly. This just
** reduces the number of functions we must define, and we trust the compiler
** to optimise away pointer copies.
**
** This implements a slightly simplified version of pattern defeating quicksort
** ( https://github.com/orlp/pdqsort ), which is an extension of introsort.
**
** A broad overview of the algorithm is:
** * Start with a quicksort which chooses pivot using median of 3
** * Sort any range of size < 24 with insertion sort.
** * If the depth of the quicksort is > log2(len), then we seem to be
**   hitting a bad O(n^2) case. In that case, switch to shellsort (but only
**   for the bad cell).
**
** * The 'cleverness' of pdqsort, which if the partitioning phase doesn't
**   move anything, then try insertion sorting, with a limit to the number
**   of swaps we will perform. This quickly detects and sub-ranges in
**   increasing order, and sub-ranges in decreasing order will get reversed
**   by pivoting, and then detected next pass
**
*/

#include <assert.h>

#include "integer.h"

/* This lets us join together two macro names to make
 * one identifier. The two levels (JOIN,JOIN2) is to force
 * the compiler to evaluate macros, so:
 * PREFIXNAME(Insert), where SORT_FUNC_NAME is
 * Sort, comes out as SortInsert, rather than
 * SORT_FUNC_NAMEInsert
 */

#define PREFIXNAME(x) JOIN(SORT_FUNC_NAME, x)
#define JOIN(x, y) JOIN2(x, y)
#define JOIN2(x, y) x##y


// Compare a and b, first checking if a and b are equal objects,
// and if so returning false straight away. We do this because
// some comparators do not work when comparing equal objects.
// This can occur either because the original list had identical
// objects, or when comparing against the pivot in quicksort.
#define SORT_COMP_CHECK_EQ PREFIXNAME(SortCompCheckEqObj)
static Int SORT_COMP_CHECK_EQ(SORT_FUNC_ARGS, Obj a, Obj b) {
    if(a==b)
        return 0;
    else
        return SORT_COMP(a, b);
}

static void PREFIXNAME(Shell)(SORT_FUNC_ARGS, Int start, Int end)
{
  UInt len; /* length of the list              */
  UInt h;   /* gap width in the shellsort      */
  SORT_CREATE_LOCAL(v);
  SORT_CREATE_LOCAL(w);
  UInt i, k; /* loop variables                  */

  /* sort the list with a shellsort                                      */
  len = end - start + 1;
  h = 1;
  while (9 * h + 4 < len) {
    h = 3 * h + 1;
  }
  while (0 < h) {
    for (i = h + start; i <= end; i++) {
      SORT_ASS_LIST_TO_LOCAL(v, i);
      k = i;
      SORT_ASS_LIST_TO_LOCAL(w, k - h);
      while (h + (start - 1) < k && SORT_COMP_CHECK_EQ(SORT_ARGS, v, w)) {
        SORT_ASS_LOCAL_TO_LIST(k, w);
        k -= h;
        if (h + (start - 1) < k) {
          SORT_ASS_LIST_TO_LOCAL(w, k - h);
        }
      }
      SORT_ASS_LOCAL_TO_LIST(k, v);
    }
    h = h / 3;
  }
  SORT_FILTER_CHECKS();
}

/* Swap values at indices a and b */
#define SWAP_INDICES PREFIXNAME(Swap)
static inline void PREFIXNAME(Swap)(SORT_FUNC_ARGS, Int a, Int b) {
  SORT_CREATE_LOCAL(t);
  SORT_CREATE_LOCAL(u);
  SORT_ASS_LIST_TO_LOCAL(t, a);
  SORT_ASS_LIST_TO_LOCAL(u, b);
  SORT_ASS_LOCAL_TO_LIST(b, t);
  SORT_ASS_LOCAL_TO_LIST(a, u);
}

/* Compare values at indices a and b */
#define COMP_INDICES PREFIXNAME(CompIndices)
static inline int COMP_INDICES(SORT_FUNC_ARGS, Int a, Int b) {
  SORT_CREATE_LOCAL(t);
  SORT_CREATE_LOCAL(u);
  SORT_ASS_LIST_TO_LOCAL(t, a);
  SORT_ASS_LIST_TO_LOCAL(u, b);
  return SORT_COMP_CHECK_EQ(SORT_ARGS, t, u);
}

/* Sort 3 indices */
static inline void PREFIXNAME(Sort3)(SORT_FUNC_ARGS, Int a, Int b, Int c) {
  if (!(COMP_INDICES(SORT_ARGS, b, a))) {
    if (!(COMP_INDICES(SORT_ARGS, c, b)))
      return;

    SWAP_INDICES(SORT_ARGS, b, c);
    if (COMP_INDICES(SORT_ARGS, b, a)) {
      SWAP_INDICES(SORT_ARGS, a, b);
    }
    return;
  }

  if (COMP_INDICES(SORT_ARGS, c, b)) {
    SWAP_INDICES(SORT_ARGS, a, c);
    return;
  }

  SWAP_INDICES(SORT_ARGS, a, b);
  if (COMP_INDICES(SORT_ARGS, c, b)) {
    SWAP_INDICES(SORT_ARGS, b, c);
  }
}

/* Partition a list, from indices start to end. Return if any values had
 * to be moved, and store the partition_point in the argument
 * partition_point
 */
static inline Int PREFIXNAME(Partition)(SORT_FUNC_ARGS, Int start, Int end,
                                        Int *partition_point) {
  Int left = start;
  Int right = end;
  Int first_pass = 1;
  SORT_CREATE_LOCAL(pivot);

  PREFIXNAME(Sort3)(SORT_ARGS, start, start / 2 + end / 2, end);
  SORT_ASS_LIST_TO_LOCAL(pivot, start / 2 + end / 2);

  left++;

  while (1) {
    while (left < right) {
      SORT_CREATE_LOCAL(listcpy);
      SORT_ASS_LIST_TO_LOCAL(listcpy, left);
      if (SORT_COMP_CHECK_EQ(SORT_ARGS, pivot, listcpy))
        break;
      left++;
    }

    right--;
    while (left < right) {
      SORT_CREATE_LOCAL(listcpy);
      SORT_ASS_LIST_TO_LOCAL(listcpy, right);
      if (!(SORT_COMP_CHECK_EQ(SORT_ARGS, pivot, listcpy)))
        break;
      right--;
    }

    if (left >= right) {
      *partition_point = left;
      return first_pass;
    }
    first_pass = 0;

    SWAP_INDICES(SORT_ARGS, left, right);
    left++;
  }
}

static void PREFIXNAME(Insertion)(SORT_FUNC_ARGS, Int start, Int end)
{
  SORT_CREATE_LOCAL(v);
  SORT_CREATE_LOCAL(w);
  UInt i, k; /* loop variables                  */

  /* sort the list with insertion sort */
  for (i = start + 1; i <= end; i++) {
    SORT_ASS_LIST_TO_LOCAL(v, i);
    k = i;
    SORT_ASS_LIST_TO_LOCAL(w, k - 1);
    while (start < k && SORT_COMP_CHECK_EQ(SORT_ARGS, v, w)) {
      SORT_ASS_LOCAL_TO_LIST(k, w);
      k -= 1;
      if (start < k) {
        SORT_ASS_LIST_TO_LOCAL(w, k - 1);
      }
    }
    SORT_ASS_LOCAL_TO_LIST(k, v);
  }
}

/* This function performs an insertion sort with a limit to the number
 * of swaps performed -- if we pass that limit we abandon the sort */
static Obj PREFIXNAME(LimitedInsertion)(SORT_FUNC_ARGS, Int start, Int end)
{
  SORT_CREATE_LOCAL(v);
  SORT_CREATE_LOCAL(w);
  UInt i, k;     /* loop variables                        */
  Int limit = 8; /* how long do we try to insertion sort? */
                 /* sort the list with insertion sort */
  for (i = start + 1; i <= end; i++) {
    SORT_ASS_LIST_TO_LOCAL(v, i);
    k = i;
    SORT_ASS_LIST_TO_LOCAL(w, k - 1);
    while (start < k && SORT_COMP_CHECK_EQ(SORT_ARGS, v, w)) {
      limit--;
      if (limit == 0) {
        SORT_ASS_LOCAL_TO_LIST(k, v);
        return False;
      }

      SORT_ASS_LOCAL_TO_LIST(k, w);
      k -= 1;
      if (start < k) {
        SORT_ASS_LIST_TO_LOCAL(w, k - 1);
      }
    }
    SORT_ASS_LOCAL_TO_LIST(k, v);
  }
  return True;
}

/* This function assumes it doesn't get called for ranges which are very small
 */
static void PREFIXNAME(CheckBadPivot)(SORT_FUNC_ARGS, Int start, Int end, Int pivot)
{
  Int length = end - start;
  if (pivot - start < length / 8) {
    SWAP_INDICES(SORT_ARGS, pivot, pivot + length / 4);
    SWAP_INDICES(SORT_ARGS, end, end - length / 4);
  }
  if (pivot - start > 7 * (length / 8)) {
    SWAP_INDICES(SORT_ARGS, start, start + length / 4);
    SWAP_INDICES(SORT_ARGS, pivot - 1, pivot - 1 - length / 4);
  }
}

static void PREFIXNAME(QuickSort)(SORT_FUNC_ARGS, Int start, Int end, Int depth)
{
  Int pivot, first_pass;

  if (end - start < 24) {
    PREFIXNAME(Insertion)(SORT_ARGS, start, end);
    return;
  }

  /* If quicksort seems to be degrading into O(n^2), escape to shellsort */
  if (depth <= 0) {
    PREFIXNAME(Shell)(SORT_ARGS, start, end);
    return;
  }

  first_pass = PREFIXNAME(Partition)(SORT_ARGS, start, end, &pivot);
  PREFIXNAME(CheckBadPivot)(SORT_ARGS, start, end, pivot);
  if (!first_pass ||
      !(PREFIXNAME(LimitedInsertion)(SORT_ARGS, start, pivot - 1) == True)) {
    PREFIXNAME(QuickSort)(SORT_ARGS, start, pivot - 1, depth - 1);
  }

  if (!first_pass ||
      !(PREFIXNAME(LimitedInsertion)(SORT_ARGS, pivot, end) == True)) {
    PREFIXNAME(QuickSort)(SORT_ARGS, pivot, end, depth - 1);
  }
}

void SORT_FUNC_NAME(SORT_FUNC_ARGS) {
  Int len = SORT_LEN_LIST();
  SORT_FILTER_CHECKS();
  PREFIXNAME(QuickSort)(SORT_ARGS, 1, len, CLog2Int(len) * 2 + 2);
}

// Merge the consecutive ranges [b1..e1] and [e1+1..e2] in place,
// Using the temporary buffer 'tempbuf'.
static void PREFIXNAME(MergeRanges)(SORT_FUNC_ARGS, Int b1, Int e1, Int e2,
                                    Obj tempbuf)
{
  Int pos1 = b1;
  Int pos2 = e1 + 1;
  Int resultpos = 1;
  Int i;

  while (pos1 <= e1 && pos2 <= e2) {
    if (PREFIXNAME(CompIndices)(SORT_ARGS, pos2, pos1)) {
      SORT_CREATE_LOCAL(t);
      SORT_ASS_LIST_TO_LOCAL(t, pos2);
      SORT_ASS_LOCAL_TO_BUF(tempbuf, resultpos, t);
      pos2++;
      resultpos++;
    } else {
      SORT_CREATE_LOCAL(t);
      SORT_ASS_LIST_TO_LOCAL(t, pos1);
      SORT_ASS_LOCAL_TO_BUF(tempbuf, resultpos, t);
      pos1++;
      resultpos++;
    }
  }

  while (pos1 <= e1) {
    SORT_CREATE_LOCAL(t);
    SORT_ASS_LIST_TO_LOCAL(t, pos1);
    SORT_ASS_LOCAL_TO_BUF(tempbuf, resultpos, t);
    pos1++;
    resultpos++;
  }

  while (pos2 <= e2) {
    SORT_CREATE_LOCAL(t);
    SORT_ASS_LIST_TO_LOCAL(t, pos2);
    SORT_ASS_LOCAL_TO_BUF(tempbuf, resultpos, t);
    pos2++;
    resultpos++;
  }

  for (i = 1; i < resultpos; ++i) {
    SORT_CREATE_LOCAL(t);
    SORT_ASS_BUF_TO_LOCAL(tempbuf, t, i);
    SORT_ASS_LOCAL_TO_LIST(b1 + i - 1, t);
  }
}

void PREFIXNAME(Merge)(SORT_FUNC_ARGS) {
  Int len = SORT_LEN_LIST();
  Obj buf = SORT_CREATE_TEMP_BUFFER(len);
  SORT_FILTER_CHECKS();
  Int stepsize = 24;
  Int i;
  /* begin with splitting into small steps we insertion sort */
  for (i = 1; i + stepsize <= len; i += stepsize) {
    PREFIXNAME(Insertion)(SORT_ARGS, i, i + stepsize - 1);
  }
  if (i < len) {
    PREFIXNAME(Insertion)(SORT_ARGS, i, len);
  }

  while (stepsize < len) {
    for (i = 1; i + stepsize * 2 <= len; i += stepsize * 2) {
      PREFIXNAME(MergeRanges)(SORT_ARGS, i, i+stepsize-1, i+stepsize*2-1, buf);
    }
    if (i + stepsize <= len) {
      PREFIXNAME(MergeRanges)(SORT_ARGS, i, i + stepsize - 1, len, buf);
    }
    stepsize *= 2;
  }
}

#undef PREFIXNAME
#undef COMP_INDICES
#undef SORT_FUNC_NAME
#undef SORT_FUNC_ARGS
#undef SORT_ARGS
#undef SORT_CREATE_LOCAL
#undef SORT_LEN_LIST
#undef SORT_ASS_LIST_TO_LOCAL
#undef SORT_ASS_LOCAL_TO_LIST
#undef SORT_COMP
#undef SORT_FILTER_CHECKS
