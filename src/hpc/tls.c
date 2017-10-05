#include <src/system.h>
#include <src/gasman.h>
#include <src/objects.h>
#include <src/scanner.h>
#include <src/code.h>
#include <src/hpc/tls.h>
#include <src/hpc/thread.h>
#include <src/hpc/threadapi.h>
#include <src/hpc/aobjects.h>

#include <string.h>

ThreadLocalStorage * MainThreadTLS;

#ifdef HAVE_NATIVE_TLS

__thread ThreadLocalStorage TLSInstance;

#endif

void InitializeTLS(void)
{
    memset((void *)(realTLS), 0, sizeof(ThreadLocalStorage));
}

void InitTLS(void)
{
    InitGAPState(&TLS(state));
    TLS(CountActive) = 1;
}

void DestroyTLS(void)
{
    DestroyGAPState(&TLS(state));
}
