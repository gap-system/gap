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

#include "system.h"

#if !defined(HPCGAP)
#error This header is only meant to be used with HPC-GAP
#endif


#ifndef HAVE_NATIVE_TLS

#ifdef SYS_IS_64_BIT
#define TLS_SIZE (1L << 20)
#else
#define TLS_SIZE (1L << 18)
#endif
#define TLS_MASK (~(TLS_SIZE - 1L))

#if TLS_SIZE & ~TLS_MASK
#error TLS_SIZE must be a power of 2
#endif

#endif // HAVE_NATIVE_TLS

#endif // GAP_TLSCONFIG_H
