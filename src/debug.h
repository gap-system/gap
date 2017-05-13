/****************************************************************************
**
*W  debug.h                     GAP source               Chris Jefferson
**
**
*Y  Copyright (C)  2017, University of St Andrews, Scotland
**
**  This file declares kernel debugging functionality.
**
*/

#ifndef GAP_DEBUG_H
#define GAP_DEBUG_H

#include <src/system.h> /* system dependent part */
#include <assert.h>     /* for assert            */

/* GAP_ASSERT is a version of 'assert' which is enabled by the
** configure option --enable-debug
*/

#ifdef GAP_KERNEL_DEBUG
#define GAP_ASSERT(x) assert(x)
#else
#define GAP_ASSERT(x)
#endif

#endif
