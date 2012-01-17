#include 	"system.h"
#include 	"gasman.h"
#include 	"objects.h"
#include	"scanner.h"
#include	"code.h"
#include 	"tls.h"

#include	<string.h>

static TLSHandler *firstHandler, *lastHandler;

ThreadLocalStorage *MainThreadTLS;

#ifdef HAVE_NATIVE_TLS

__thread ThreadLocalStorage TLSInstance;

#endif

void InitializeTLS()
{
  memset((void *)(TLS), 0, sizeof(ThreadLocalStorage));
}

void InstallTLSHandler(
	TLSHandler *handler,
	void (*constructor)(),
	void (*destructor)() )
{
  if (!constructor && !destructor)
    return;
  handler->constructor = constructor;
  handler->destructor = destructor;
  handler->nextHandler = 0;
  if (!firstHandler)
    firstHandler = lastHandler = handler;
  else
  {
    lastHandler->nextHandler = handler;
    lastHandler = handler;
  }
}

void RunTLSConstructors()
{
   TLSHandler *handler;
   for (handler = firstHandler; handler; handler = handler->nextHandler)
     handler->constructor();
}

void RunTLSDestructors()
{
   TLSHandler *handler;
   for (handler = firstHandler; handler; handler = handler->nextHandler)
     handler->destructor();
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
}
