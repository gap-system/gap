/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_BOEHM_GC_H
#define GAP_BOEHM_GC_H

#include "common.h"

#ifndef USE_BOEHM_GC
#error This file can only be used when the Boehm GC collector is enabled
#endif

#ifdef HPCGAP
#define GC_THREADS
#endif

#define LARGE_GC_SIZE (8192 * sizeof(UInt))
#define TL_GC_SIZE (256 * sizeof(UInt))

#ifndef DISABLE_GC
#include <gc/gc.h>
#include <gc/gc_inline.h>
#include <gc/gc_typed.h>
#include <gc/gc_mark.h>
#endif

extern Int SyStorKill;

#endif
