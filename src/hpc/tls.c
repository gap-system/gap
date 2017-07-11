#include <src/system.h>
#include <src/gapstate.h>
#include <src/gasman.h>
#include <src/objects.h>
#include <src/scanner.h>
#include <src/code.h>
#include <src/hpc/tls.h>
#include <src/hpc/thread.h>
#include <src/hpc/threadapi.h>
#include <src/hpc/aobjects.h>

#include <string.h>

#define MAX_TLS_HANDLERS (TLS_NUM_EXTRA * 2)

static TLSHandler TLSHandlers[MAX_TLS_HANDLERS];
static Int        TLSHandlerCount = 0;

ThreadLocalStorage * MainThreadTLS;

#ifdef HAVE_NATIVE_TLS

__thread ThreadLocalStorage TLSInstance;

#endif

void InitializeTLS(void)
{
    memset((void *)(realTLS), 0, sizeof(ThreadLocalStorage));
}

void InstallTLSHandler(void (*constructor)(void), void (*destructor)(void))
{
    TLSHandler * handler;
    if (!constructor && !destructor)
        return;
    if (TLSHandlerCount >= MAX_TLS_HANDLERS)
        abort();
    handler = TLSHandlers + TLSHandlerCount++;
    handler->constructor = constructor;
    handler->destructor = destructor;
}

void RunTLSConstructors(void)
{
    Int i;
    for (i = 0; i < TLSHandlerCount; i++) {
        TLSHandler * handler = TLSHandlers + i;
        if (handler->constructor)
            handler->constructor();
    }
}

void RunTLSDestructors(void)
{
    Int i;
    for (i = 0; i < TLSHandlerCount; i++) {
        TLSHandler * handler = TLSHandlers + i;
        if (handler->destructor)
            handler->destructor();
    }
}

static Int ExtraTLSSlot = 0;

Int AllocateExtraTLSSlot(void)
{
    Int result;
    HashLock(0);
    result = ExtraTLSSlot;
    if (result < TLS_NUM_EXTRA) {
        ExtraTLSSlot++;
    }
    HashUnlock(0);
    if (result < ExtraTLSSlot)
        return result;
    else
        return -1;
}

void InitTLS(void)
{
    InitGAPState(&TLS(state));
    InitThreadAPIState();
    InitAObjectsState();
    RunTLSConstructors();

    TLS(CountActive) = 1;
}

void DestroyTLS(void)
{
    DestroyGAPState(&TLS(state));
    DestroyThreadAPIState();
    DestroyAObjectsState();
    RunTLSDestructors();
}
