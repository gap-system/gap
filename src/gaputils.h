/****************************************************************************
**
**  Copyright (C) 2017 The GAP Group
**
*/

#ifndef GAP_UTILS_H
#define GAP_UTILS_H

/****************************************************************************
**
** Compute the number of elements of a given C array.
**/
#define ARRAY_SIZE(arr)     ( sizeof(arr) / sizeof((arr)[0]) )


static inline Int AlwaysYes(Obj obj) { return 1; }
static inline Int AlwaysNo(Obj obj) { return 0; }

#endif // GAP_UTILS_H
