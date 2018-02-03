/****************************************************************************
**
**  Copyright (C) 2017 The GAP Group
**
*/

#ifndef GAP_UTILS_H
#define GAP_UTILS_H

#include <src/system.h>

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
** Compute the number of elements of a given C array.
**/
#define ARRAY_SIZE(arr)     ( sizeof(arr) / sizeof((arr)[0]) )


static inline BOOL AlwaysYes(Obj obj)
{
    return 1;
}

static inline BOOL AlwaysNo(Obj obj)
{
    return 0;
}

#endif // GAP_UTILS_H
