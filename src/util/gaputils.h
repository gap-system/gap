/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_UTILS_H
#define GAP_UTILS_H

#include "system.h"

//
// Swap the content of two variables <a> and <b> of type <T>.
//
// Example:
// int a, b;
// ...
// SWAP(int, a, b);
//
#define SWAP(T, a, b)          do { T SWAP_TMP = a; a = b; b = SWAP_TMP; } while (0)

/****************************************************************************
**
**  Compute the number of elements of a given C array.
**/
#define ARRAY_SIZE(arr)     ( sizeof(arr) / sizeof((arr)[0]) )


EXPORT_INLINE Int AlwaysYes(Obj obj) { return 1; }
EXPORT_INLINE Int AlwaysNo(Obj obj) { return 0; }

#endif // GAP_UTILS_H
