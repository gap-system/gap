/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/* the private structure for the FILE IO */
static OMstatus OMIOFileFlush(OMdev dev);
static OMstatus OMIOFilePutChar(OMdev dev, char c);
static OMstatus OMIOFilePrint(OMdev dev, char *s);
static OMstatus OMIOFileWrite(OMdev dev, char *buff, int len);
static int OMIOFileGetChar(OMdev dev);
static int OMIOFileLookAhead(OMdev dev);
static OMstatus OMIOFileRead(OMdev dev, char *buff, int len);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */



#ifdef WIN32
#define SetOMErrno dev->omErrno = GetLastError()
#else
#define SetOMErrno dev->omErrno = errno
#endif

#define STATE(Dev) ((OMFileIOPrivate)(Dev->io->private))
#define F(Dev)     (STATE(Dev)->file)

/* the private structure for the FILE IO */
typedef struct OMFileIOPrivateStruct {
  FILE *file;
} OMFileIOPrivateStruct;

typedef struct OMFileIOPrivateStruct *OMFileIOPrivate;

Module OMstatus
OMIOFileFlush(OMdev dev)
{
  OMassert(dev);

  fflush(F(dev));
  return OMsuccess;
}

Module OMstatus
OMIOFilePutChar(OMdev dev, char c)
{
  OMassert(dev);

  if (putc(c, F(dev)) == EOF) {
    dev->error = OMerrorSys;
    SetOMErrno;
    return OMerrorSys;
  }
  else
    return OMsuccess;
}


Module OMstatus
OMIOFilePrint(OMdev dev, char *s)
{
  OMassert(dev);
  OMassert(s);

  if (fputs(s, F(dev)) == EOF) {
    dev->error = OMerrorSys;
    return OMerrorSys;
  }
  else
    return OMsuccess;
}

Module OMstatus
OMIOFileWrite(OMdev dev, char *buff, int len)
{
  OMassert(dev);
  OMassert(buff);
  OMassert(len >= 0);

  if (len) {
    if (fwrite(buff, sizeof(char), len, F(dev)) != len) {
      dev->error = OMerrorSys;
      if (ferror(F(dev))) {
	SetOMErrno;
	return OMerrorSys;
      }
      return OMfailed;
    }
  }
  return OMsuccess;
}

Module int
OMIOFileGetChar(OMdev dev)
{
  int c;

  OMassert(dev);

  if ((c = getc(F(dev))) == EOF) {
    if (ferror(F(dev))) {
      dev->error = OMerrorSys;
      SetOMErrno;
    }
    else if (feof(F(dev))) {
      dev->error = OMemptyIO;
      dev->omErrno = 0;
    }
    return EOF;
  }
  return c;
}

Module int
OMIOFileLookAhead(OMdev dev)
{
  int c;

  OMassert(dev);

  c = OMIOFileGetChar(dev);
  if (ungetc(c, F(dev)) == EOF) {
    if (ferror(F(dev))) {
      dev->error = OMerrorSys;
      SetOMErrno;
    }
    else {
      dev->error = OMemptyIO;
      dev->omErrno = 0;
    }
    return EOF;
  }
  return c;
}

Module OMstatus
OMIOFileRead(OMdev dev, char *buff, int len)
{
  OMassert(dev);
  OMassert(buff);
  OMassert(len > 0);

  if (fread(buff, sizeof(char), len, F(dev)) != len) {
    if (ferror(F(dev))) {
      dev->error = OMerrorSys;
      SetOMErrno;
      return OMerrorSys;
    }
    else if (feof(F(dev))) {
      dev->error = OMemptyIO;
      dev->omErrno = 0;
      return OMemptyIO;
    }
    return OMfailed;
  }
  return OMsuccess;
}

Lib void
OMfreeIOFile(OMIOStruct * io)
{
  OMassert(io);
  OMassert(io->type == OMIOFile);

  fclose(((OMFileIOPrivate) io->private)->file);
  OMfreeInternal(io->private);
  OMfreeInternal(io);
}

/* OMmakeIOFile
 *   Create a low level IO object from a FILE*.
 *   (May be used on stdin for instance.)
 * fd: FILE* to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
World OMIO
OMmakeIOFile(FILE * f)
{
  OMIO res;
  OMFileIOPrivate priv;

  OMassert(f);

  res = OMmallocWarn(sizeof(OMIOStruct), "Cannot allocate IO structure.");
  res->type = OMIOFile;
  priv = res->private = OMmallocWarn(sizeof(OMFileIOPrivateStruct), "Cannot allocate private IO structure.");
  priv->file = f;

  res->flush = OMIOFileFlush;
  res->putChar = OMIOFilePutChar;
  res->write = OMIOFileWrite;
  res->print = OMIOFilePrint;
  res->getChar = OMIOFileGetChar;
  res->lookAhead = OMIOFileLookAhead;
  res->read = OMIOFileRead;

  return res;
}
