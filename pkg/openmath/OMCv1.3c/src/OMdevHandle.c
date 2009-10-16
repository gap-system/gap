/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#ifdef WIN32

#define STATE(Dev) ((OMHandleIOPrivate)(Dev->io->private))
#define F(Dev)     (STATE(Dev)->hfile)
#define C(Dev)     (STATE(Dev)->c)
#define LA(Dev)    (STATE(Dev)->lookAheadDone)

/* the private structure for the HANDLE IO */
typedef struct OMHandleIOPrivateStruct {
  HANDLE hfile;
  OMbool lookAheadDone;
  int c;			/* lookahead buffer */
} OMHandleIOPrivateStruct;

typedef struct OMHandleIOPrivateStruct *OMHandleIOPrivate;

Module OMstatus
OMIOHandleFlush(OMdev dev)
{
  OMassert(dev);
  FlushFileBuffers(F(dev));

  return OMsuccess;
}

Module OMstatus
OMIOHandlePutChar(OMdev dev, char c)
{
  DWORD lenWrite;
  BOOL result;
  OMassert(dev);

  result = WriteFile(F(dev), &c, 1, &lenWrite, NULL);
  if ((!result) || (lenWrite != 1)) {
    dev->error = OMerrorSys;
    dev->omErrno = GetLastError();
    return OMerrorSys;
  }
  else
    return OMsuccess;
}


Module OMstatus
OMIOHandlePrint(OMdev dev, char *s)
{
  DWORD lenWrite;
  BOOL result;
  OMassert(dev);
  OMassert(s);

  result = WriteFile(F(dev), s, strlen(s), &lenWrite, NULL);
  if ((!result) || (lenWrite != strlen(s))) {
    dev->error = OMerrorSys;
    dev->omErrno = GetLastError();
    return OMerrorSys;
  }
  else
    return OMsuccess;
}

Module OMstatus
OMIOHandleWrite(OMdev dev, char *buff, int len)
{
  DWORD lenWrite;
  OMbool result;
  OMassert(dev);
  OMassert(buff);
  OMassert(len >= 0);

  if (len) {
    result = WriteFile(F(dev), buff, len, &lenWrite, NULL);
    if ((!result) || (lenWrite != len)) {
      dev->error = OMerrorSys;
      dev->omErrno = GetLastError();
      return OMerrorSys;
    }
  }
  return OMsuccess;
}

Module int
OMIOHandleGetChar(OMdev dev)
{
  DWORD lenRead;
  BOOL result;
  int c = 0;

  OMassert(dev);

  if (LA(dev)) {
    LA(dev) = OMfalse;
    return C(dev);
  }
  result = ReadFile(F(dev), &c, 1, &lenRead, NULL);

  if ((!result) || (lenRead != 1)) {
    if (GetLastError() != ERROR_HANDLE_EOF) {
      dev->error = OMerrorSys;
      dev->omErrno = GetLastError();
    }
    else {
      dev->error = OMemptyIO;
      dev->omErrno = 0;
    }
    return EOF;
  }
  return c;
}

Module int
OMIOHandleLookAhead(OMdev dev)
{
  int c;

  OMassert(dev);

  c = OMIOHandleGetChar(dev);
  LA(dev) = OMtrue;
  C(dev) = c;
  return c;
}

Module OMstatus
OMIOHandleRead(OMdev dev, char *buff, int len)
{
  DWORD lenRead;
  BOOL result;

  OMassert(dev);
  OMassert(buff);
  OMassert(len > 0);

  if (LA(dev)) {
    result = ReadFile(F(dev), buff + 1, len - 1, &lenRead, NULL);
    lenRead++;
    buff[0] = C(dev);
    LA(dev) = OMfalse;
  }
  else
    result = ReadFile(F(dev), buff, len, &lenRead, NULL);

  if ((!result) || (lenRead != len)) {
    if (GetLastError() != ERROR_HANDLE_EOF) {
      dev->error = OMerrorSys;
      dev->omErrno = GetLastError();
      return OMerrorSys;
    }
    else {
      dev->error = OMemptyIO;
      dev->omErrno = 0;
      return OMemptyIO;
    }
    return OMfailed;
  }
  return OMsuccess;
}


Lib void
OMfreeIOHandle(OMIOStruct * io)
{
  OMassert(io);
  OMassert(io->type == OMIOHandle);

  CloseHandle(((OMHandleIOPrivate) io->private)->hfile);
  OMfreeInternal(io->private);
  OMfreeInternal(io);
}

/* OMmakeIOHandle
 *   Create a low level IO object from a widows handle.
 * handle: windows handle to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
World OMIO
OMmakeIOHandle(HANDLE handle)
{
  OMIO res;
  OMHandleIOPrivate priv;

  OMassert(handle);

  res = OMmallocWarn(sizeof(OMIOStruct), "Cannot allocate IO structure.");
  res->type = OMIOHandle;
  priv = res->private = OMmallocWarn(sizeof(OMHandleIOPrivateStruct), "Cannot allocate private IO structure.");

  priv->hfile = handle;
  priv->lookAheadDone = OMfalse;
  priv->c = 0;

  res->flush = OMIOHandleFlush;
  res->putChar = OMIOHandlePutChar;
  res->write = OMIOHandleWrite;
  res->print = OMIOHandlePrint;
  res->getChar = OMIOHandleGetChar;
  res->lookAhead = OMIOHandleLookAhead;
  res->read = OMIOHandleRead;

  return res;
}
#endif
