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

#include <src/system.h>
#include <assert.h>

/* GAP_ASSERT is a version of 'assert' which is enabled by the
** configure option --enable-debug
*/

#ifdef GAP_KERNEL_DEBUG
#define GAP_ASSERT(x) assert(x)
#else
#define GAP_ASSERT(x)
#endif

// Portable compile time assertion.
#if defined(static_assert) && !defined(WARD_ENABLED)
// If available, use _Static_assert resp. static_assert from C11.
// However, ward currently cannot deal with it.
#define GAP_STATIC_ASSERT(cond, msg)    static_assert(cond, msg)
#else
// If the compiler does not support _Static_assert resp. static_assert,
// fall back to a hack (the error message is a bit ugly in that case).
#define GAP_STATIC_ASSERT(cond, msg) \
    typedef char static_assertion_##__LINE__[(cond)? 1 : -1]
#endif


#if defined(HAVE_BACKTRACE) && defined(PRINT_BACKTRACE)
extern void InstallBacktraceHandlers(void);
#endif

#endif
