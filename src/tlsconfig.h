#ifndef _TLSCONFIG_H
#define _TLSCONFIG_H

#undef HAVE_NATIVE_TLS

#ifndef HAVE_NATIVE_TLS

#define TLS_SIZE (1 << 16)
#define TLS_MASK ~(TLS_SIZE - 1)

#if TLS_SIZE & ~TLS_MASK
#error TLS_SIZE must be a power of 2
#endif

#endif

#endif
