#ifndef GAP_TLSCONFIG_H
#define GAP_TLSCONFIG_H

#include "system.h"

#if !defined(HPCGAP)
#error This header is only meant to be used with HPC-GAP
#endif


#ifndef HAVE_NATIVE_TLS

#if SIZEOF_VOID_P == 8
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
