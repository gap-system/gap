/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_TLSCONFIG_H
#define GAP_TLSCONFIG_H

#include "common.h"

#if !defined(HPCGAP)
#error This header is only meant to be used with HPC-GAP
#endif


#ifndef USE_NATIVE_TLS

enum {
    TLS_SIZE = (sizeof(UInt) == 8) ? (1 << 20) : (1 << 18),
};
#define TLS_MASK (~(TLS_SIZE - 1))

GAP_STATIC_ASSERT((TLS_SIZE & (TLS_SIZE - 1)) == 0,
                  "TLS_SIZE must be a power of 2");

#endif // USE_NATIVE_TLS

#endif // GAP_TLSCONFIG_H
