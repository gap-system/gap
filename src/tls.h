#ifndef _TLS_H
#define _TLS_H

#include <stdint.h>

#include "tlsconfig.h"

typedef struct
{
  int threadID;
} ThreadLocalStorage;

#ifdef HAVE_NATIVE_TLS

extern __thread ThreadLocalStorage TLSInstance;

#define TLS (&TLSInstance)

#else

static inline ThreadLocalStorage *GetTLS()
{
  void *stack;
#ifdef __GNUC__
  stack = __builtin_frame_address(0);
#else
  int dummy[0];
  stack = dummy;
#endif
  return (ThreadLocalStorage *) (((uintptr_t) stack) & TLS_MASK);
}

#define TLS (GetTLS())

#endif /* HAVE_NATIVE_TLS */

void InitializeTLS();

#endif /* _TLS_H */
