/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"
#ifdef WIN32
#include "io.h"
#endif

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/* fill the buffer from the file descriptor. The buffer should always been
   "EXHAUSTED" prior to calling that. */
static OMbool OMfdReadIntern(OMdev dev);
/* to read exactly n characters from the file descriptor in the buffer */
static OMbool OMfdReadInternN(OMdev dev, char *buff, int len);
static OMstatus OMIOfdFlush(OMdev dev);
static OMstatus OMIOfdPutChar(OMdev dev, char c);
static OMstatus OMIOfdWrite(OMdev dev, char *buff, int len);
static OMstatus OMIOfdPrint(OMdev dev, char *s);
static int OMIOfdGetChar(OMdev dev);
static int OMIOfdLookAhead(OMdev dev);
static OMstatus OMIOfdRead(OMdev dev, char *buff, int len);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */


#define FDBUFSIZE 4096

/* the private structure for the "file descriptor" I/O */
typedef struct OMfdIOPrivateStruct {
  char buf[FDBUFSIZE];
  int current;			/* current position in "buf" (next to be read) */
  int last;			/* last valid position in "buf" */
  int fd;			/* the associated file descriptor */
  int size;
} OMfdIOPrivateStruct;

typedef struct OMfdIOPrivateStruct *OMfdIOPrivate;


#define PRIV(Dev)      ((OMfdIOPrivateStruct *)(Dev->io->private))
/* some macros to deal with the buffering mechanism... */
#define FD(Dev)        (PRIV(Dev)->fd)
/* the buffer... */
#define BUFF(Dev)      (PRIV(Dev)->buf)
/* last valid position in the buffer, -1 if buffer is empty */
#define LAST(Dev)      (PRIV(Dev)->last)
/* the current (to be read, to be written) position as an index in "buf" */
#define CURR(Dev)      (PRIV(Dev)->current)
/* the current character */
#define CURRCHAR(Dev)  ((BUFF(Dev))[CURR(Dev)])
/* if buffer is full */
#define FULL(Dev)      (CURR(Dev) == FDBUFSIZE - 1)
/* If we can write n more characters in the buffer */
#define FIT(Dev, n)    (CURR(Dev) + n <= FDBUFSIZE)
#define EXHAUSTED(Dev) (CURR(Dev) > LAST(Dev))
/* how many characters are available from the buffer */
#define AVAILABLE(Dev) (LAST(Dev) - CURR(Dev) + 1)

#define POSITION(Dev)  (PRIV(Dev)->buf + CURR(Dev))
#define ADVANCE(Dev, l) (CURR(Dev) += l)
#define MEMPUT(Dev, s, l) {memcpy(POSITION(Dev), s, l); ADVANCE(Dev, l);}
#define PUTCHAR(Dev, c) ((PRIV(Dev)->buf)[CURR(Dev)++] = c)
#define MEMGET(Dev, b, l) {memcpy(b, POSITION(Dev), l); ADVANCE(Dev, l);}



/* fill the buffer from the file descriptor. The buffer should always been
   "EXHAUSTED" prior to calling that. */
Module OMbool
OMfdReadIntern(OMdev dev)
{
  int nread;

  OMassert(dev);

#ifndef WIN32
  if ((nread = read(FD(dev), BUFF(dev), (size_t) FDBUFSIZE)) < 0)
#else
  if ((nread = _read(FD(dev), BUFF(dev), (size_t) FDBUFSIZE)) < 0)
#endif
    return OMfalse;
  else
    CURR(dev) = 0;
  LAST(dev) = nread - 1;
  return OMtrue;
}

/* to read exactly n characters from the file descriptor in the buffer */
Module OMbool
OMfdReadInternN(OMdev dev, char *buff, int len)
{
  int remaining = len;
  int nread;
  char *pos = buff;

  OMassert(dev);
  OMassert(buff);
  OMassert(len > 0);

  while (remaining > 0) {
    if ((nread = read(FD(dev), pos, (size_t) len)) < 0)
      return OMfalse;
    remaining -= nread;
    pos += nread;
  }
  return OMtrue;
}

Module OMstatus
OMIOfdFlush(OMdev dev)
{
  OMassert(dev);

  if (CURR(dev) == 0)
    return OMsuccess;
#ifndef WIN32
  if (write(FD(dev), BUFF(dev), CURR(dev)) < 0) {
#else
  if (_write(FD(dev), BUFF(dev), CURR(dev)) < 0) {
#endif
    dev->error = OMerrorSys;
    return OMerrorSys;
  }
  else {
    CURR(dev) = 0;
    LAST(dev) = -1;
    return OMsuccess;
  }
}

Module OMstatus
OMIOfdPutChar(OMdev dev, char c)
{
  OMassert(dev);

  if (FULL(dev)) {
    if (OMIOfdFlush(dev) == OMfailed)
      return OMfailed;
  }
  PUTCHAR(dev, c);
  return OMsuccess;
}

Module OMstatus
OMIOfdWrite(OMdev dev, char *buff, int len)
{
  OMassert(dev);
  OMassert(buff);
  OMassert(len > 0);

  if (!FIT(dev, len)) {
    OMIOfdFlush(dev);
  }
  if (!FIT(dev, len)) {
    /* we cannot write the whole data in the buffer, write it directly */
    if (write(FD(dev), buff, len) < 0) {
      dev->error = OMerrorSys;
      return OMerrorSys;
    }
    else
      return OMsuccess;
  }
  else {
    MEMPUT(dev, buff, len);
    return OMsuccess;
  }
}

Module OMstatus
OMIOfdPrint(OMdev dev, char *s)
{
  int len;

  OMassert(dev);
  OMassert(s);

  len = strlen(s);
  return OMIOfdWrite(dev, s, len);
}

Module int
OMIOfdGetChar(OMdev dev)
{
  int c;

  OMassert(dev);

  if (EXHAUSTED(dev)) {
    if (OMfdReadIntern(dev) == OMfalse) {
      dev->error = OMerrorSys;
      return 0;
    }
  }
  c = CURRCHAR(dev);
  ADVANCE(dev, 1);
  return c;
}

Module int
OMIOfdLookAhead(OMdev dev)
{
  OMassert(dev);

  if (EXHAUSTED(dev)) {
    if (OMfdReadIntern(dev) == OMfalse) {
      dev->error = OMerrorSys;
      return 0;
    }
  }
  return CURRCHAR(dev);
}

Module OMstatus
OMIOfdRead(OMdev dev, char *buff, int len)
{
  int avail = AVAILABLE(dev);
  int remaining;

  OMassert(dev);
  OMassert(buff);
  OMassert(len > 0);

  if (avail >= len) {		/* everything is already in the buffer */
    MEMGET(dev, buff, len);
    ADVANCE(dev, len);
    return OMsuccess;
  }
  else {
    remaining = len - avail;
    /* get what we have in core */
    MEMGET(dev, buff, avail);
    ADVANCE(dev, avail);
    /* now, the buffer is empty */
    /* directly read in the user supplied buffer */
    if (OMfdReadInternN(dev, buff + avail, remaining) == OMfalse) {
      dev->error = OMerrorSys;
      return OMerrorSys;
    }
    else
      return OMsuccess;

  }
}

Lib void
OMfreeIOFd(OMIOStruct * io)
{
  OMassert(io->type == OMIOFd);

#ifndef WIN32
  close(((OMfdIOPrivate) io->private)->fd);
#else
  _close(((OMfdIOPrivate) io->private)->fd);
#endif

  OMfreeInternal(io->private);
  OMfreeInternal(io);
}


/* OMmakeIOFd
 *   Create a low level IO object from a file descriptor.
 *   (May be used on socket for instance.)
 * fd: file descriptor to wrap into the OpenMath IO object.
 * return: a newly allocated IO object.
 */
World OMIO
OMmakeIOFd(int fd)
{
  OMIO res;
  OMfdIOPrivate priv;

  OMassert(fd >= 0);

  {
    FILE *f;
    if (((f = fdopen(fd, "r+"))) || ((f = fdopen(fd, "w"))) || ((f = fdopen(fd, "r")))) {
      return OMmakeIOFile(f);
    }
    else {
      OMprintf(OMwarnLevel, "fdopen failed.\n");
      return NULL;
    }
  }

  res = OMmallocWarn(sizeof(OMIOStruct), "Cannot allocate IO structure.");
  res->type = OMIOFd;

  priv = res->private = OMmallocWarn(sizeof(OMfdIOPrivateStruct), "Cannot allocate private IO structure.");

  priv->last = -1;
  priv->current = 0;
  priv->fd = fd;

  res->flush = OMIOfdFlush;
  res->putChar = OMIOfdPutChar;
  res->write = OMIOfdWrite;
  res->print = OMIOfdPrint;
  res->getChar = OMIOfdGetChar;
  res->lookAhead = OMIOfdLookAhead;
  res->read = OMIOfdRead;

  return res;
}
