/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares kernel debugging functionality.
**
*/

#ifndef GAP_DEBUG_H
#define GAP_DEBUG_H

/* GAP_ASSERT is a version of 'assert' which is enabled by the
** configure option --enable-debug
*/

#ifdef GAP_KERNEL_DEBUG
#define GAP_ASSERT(x) assert(x)

// Enable various GAP debugging features
#define COUNT_BAGS
#else
#define GAP_ASSERT(x)
#endif

// Portable compile time assertion.
#if defined(static_assert)
// If available, use _Static_assert resp. static_assert from C11.
#define GAP_STATIC_ASSERT(cond, msg)    static_assert(cond, msg)
#else
// If the compiler does not support _Static_assert resp. static_assert,
// fall back to a hack (the error message is a bit ugly in that case).
#define _intern_CONCAT_(X, Y)  X ## Y
#define _intern_CONCAT(X, Y)  _intern_CONCAT_(X,Y)
#define GAP_STATIC_ASSERT(cond, msg) \
    typedef char _intern_CONCAT(static_assertion_, __LINE__)[(cond)? 1 : -1]
#endif


void InstallBacktraceHandlers(void);

#endif
