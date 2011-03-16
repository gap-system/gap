#ifndef _TLSCONFIG_H
#define _TLSCONFIG_H

#undef HAVE_NATIVE_TLS

#ifndef HAVE_NATIVE_TLS

#if SIZEOF_VOID_P == 8
#define TLS_SIZE (1L << 20)
#else
#define TLS_SIZE (1L << 18)
#endif
#define TLS_MASK ~(TLS_SIZE - 1L)

#if TLS_SIZE & ~TLS_MASK
#error TLS_SIZE must be a power of 2
#endif

#endif

#endif
