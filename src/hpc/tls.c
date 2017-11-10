#include <src/gapstate.h>

ThreadLocalStorage * MainThreadTLS;

#ifdef HAVE_NATIVE_TLS

__thread GAPState TLSGAPtate;
__thread ThreadLocalStorage *TLSInstance;

#endif

void InitializeTLS(void)
{
#ifdef HAVE_NATIVE_TLS
    // FIXME: is this the right place to do this?
    TLSInstance = &(TLSGAPtate.tls);
#endif
    memset(ActiveGAPState(), 0, sizeof(GAPState));
}
