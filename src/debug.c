/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

// Request that common.h use 'extern inline' (see common.h for details)
#define DEBUG_FORCE_EXTERN_INLINE 1

#include "common.h"

#include "calls.h"
#include "fibhash.h"
#include "gap_all.h"
#include "hookintrprtr.h"
#include "sysstr.h"
#include "vec8bit.h"

#ifdef HPCGAP
#include "hpc/guards.h"
#include "hpc/region.h"
#endif

#include "config.h"

#if defined(HAVE_BACKTRACE) && defined(GAP_PRINT_BACKTRACE)
#include <execinfo.h>
#include <signal.h>
#include <stdio.h>      // for fprintf, fileno
#include <stdlib.h>     // for exit

static void BacktraceHandler(int sig) NORETURN;

static void BacktraceHandler(int sig)
{
    void *       trace[32];
    size_t       size;
    const char * sigtext = "Unknown signal";
    size = backtrace(trace, 32);
    switch (sig) {
    case SIGSEGV:
        sigtext = "Segmentation fault";
        break;
    case SIGBUS:
        sigtext = "Bus error";
        break;
    case SIGINT:
        sigtext = "Interrupt";
        break;
    case SIGABRT:
        sigtext = "Abort";
        break;
    case SIGFPE:
        sigtext = "Floating point exception";
        break;
    case SIGTERM:
        sigtext = "Program terminated";
        break;
    }
    fprintf(stderr, "%s\n", sigtext);
    backtrace_symbols_fd(trace, size, fileno(stderr));
    exit(1);
}

void InstallBacktraceHandlers(void)
{
    signal(SIGSEGV, BacktraceHandler);
    signal(SIGBUS, BacktraceHandler);
    signal(SIGABRT, BacktraceHandler);
    signal(SIGFPE, BacktraceHandler);
}

#else

void InstallBacktraceHandlers(void)
{
}

#endif
