#include "tls.h"

#ifdef HAVE_NATIVE_TLS

__thread ThreadLocalStorage TLSInstance;

#endif

void InitializeTLS()
{
  ThreadLocalStorage empty = { };
  *TLS = empty;
}
