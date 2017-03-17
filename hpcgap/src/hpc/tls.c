#include 	"system.h"
#include 	"gasman.h"
#include 	"objects.h"
#include	"scanner.h"
#include	"code.h"
#include 	"hpc/tls.h"
#include    "hpc/thread.h"

#include	<string.h>

#define MAX_TLS_HANDLERS (TLS_NUM_EXTRA * 2)

static TLSHandler TLSHandlers[MAX_TLS_HANDLERS];
static Int TLSHandlerCount = 0;

ThreadLocalStorage *MainThreadTLS;

#ifdef HAVE_NATIVE_TLS

__thread ThreadLocalStorage TLSInstance;

#endif

void InitializeTLS()
{
  memset((void *)(realTLS), 0, sizeof(ThreadLocalStorage));
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
