#include <src/system.h>
#include <src/gasman.h>
#include <src/objects.h>
#include <src/scanner.h>
#include <src/code.h>
#include <src/hpc/tls.h>
#include <src/hpc/thread.h>

#include <string.h>

#define MAX_TLS_HANDLERS (TLS_NUM_EXTRA * 2)

static TLSHandler TLSHandlers[MAX_TLS_HANDLERS];
static Int TLSHandlerCount = 0;

GAPState *MainThreadTLS;

#ifdef HAVE_NATIVE_TLS

__thread GAPState TLSInstance;

#endif

void InitializeTLS()
{
  memset((void *)(realTLS), 0, sizeof(GAPState));
}

void InstallTLSHandler(
	void (*constructor)(),
	void (*destructor)() )
{
  TLSHandler *handler;
  if (!constructor && !destructor)
    return;
  if (TLSHandlerCount >= MAX_TLS_HANDLERS)
    abort();
  handler = TLSHandlers + TLSHandlerCount++;
  handler->constructor = constructor;
  handler->destructor = destructor;
}

void RunTLSConstructors()
{
  Int i;
  for (i = 0; i < TLSHandlerCount; i++) {
    TLSHandler *handler = TLSHandlers + i;
    if (handler->constructor)
      handler->constructor();
  }
}

void RunTLSDestructors()
{
  Int i;
  for (i = 0; i < TLSHandlerCount; i++) {
    TLSHandler *handler = TLSHandlers + i;
    if (handler->destructor)
      handler->destructor();
  }
}

static Int ExtraTLSSlot = 0;

Int AllocateExtraTLSSlot() {
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

void InitTLS()
{
  void InitScannerTLS();
  void InitStatTLS();
  void InitExprTLS();
  void InitCoderTLS();
  void InitThreadAPITLS();
  void InitOpersTLS();
  void InitAObjectsTLS();
  InitScannerTLS();
  InitStatTLS();
  InitExprTLS();
  InitCoderTLS();
  InitThreadAPITLS();
  InitOpersTLS();
  InitAObjectsTLS();
  RunTLSConstructors();
  TLS(CountActive) = 1;
}

void DestroyTLS()
{
  void DestroyScannerTLS();
  void DestroyStatTLS();
  void DestroyExprTLS();
  void DestroyCoderTLS();
  void DestroyThreadAPITLS();
  void DestroyOpersTLS();
  void DestroyAObjectsTLS();
  DestroyScannerTLS();
  DestroyStatTLS();
  DestroyExprTLS();
  DestroyCoderTLS();
  DestroyThreadAPITLS();
  DestroyOpersTLS();
  DestroyAObjectsTLS();
  RunTLSDestructors();
}
