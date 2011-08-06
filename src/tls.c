#include 	"system.h"
#include 	"gasman.h"
#include 	"objects.h"
#include	"scanner.h"
#include	"code.h"
#include 	"tls.h"

static TLSHandler *firstHandler, *lastHandler;

ThreadLocalStorage *MainThreadTLS;

#ifdef HAVE_NATIVE_TLS

__thread ThreadLocalStorage TLSInstance;

#endif

void InitializeTLS()
{
  ThreadLocalStorage empty = { };
  *TLS = empty;
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
  void InitCoderTLS();
  void InitThreadAPITLS();
  void InitOpersTLS();
  void InitAObjectsTLS();
  InitScannerTLS();
  InitCoderTLS();
  InitThreadAPITLS();
  InitOpersTLS();
  InitAObjectsTLS();
}

void DestroyTLS()
{
  void DestroyScannerTLS();
  void DestroyCoderTLS();
  void DestroyThreadAPITLS();
  void DestroyOpersTLS();
  void DestroyAObjectsTLS();
  DestroyScannerTLS();
  DestroyCoderTLS();
  DestroyThreadAPITLS();
  DestroyOpersTLS();
  DestroyAObjectsTLS();
}

void WriteGuardError(Obj o)
{
  ImpliedReadGuard(o);
  ErrorMayQuit("Attempt to write object %i of type %s without having write access", (Int)o, (Int)TNAM_OBJ(o));
}

void ReadGuardError(Obj o)
{
  ImpliedReadGuard(o);
  ErrorMayQuit("Attempt to read object %i of type %s without having read access", (Int)o, (Int)TNAM_OBJ(o));
}
