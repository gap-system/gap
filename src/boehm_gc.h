/****************************************************************************
**
**/

#ifndef GAP_BOEHM_GC_H
#define GAP_BOEHM_GC_H

#include "system.h"

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


#endif
