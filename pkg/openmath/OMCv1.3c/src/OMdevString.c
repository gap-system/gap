/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/* input */
static OMstatus OMreallocString(OMdev dev, int len);
static OMstatus OMIOStringFlush(OMdev dev);
static OMstatus OMIOStringPutChar(OMdev dev, char c);
static OMstatus OMIOStringPrint(OMdev dev, char *s);
static OMstatus OMIOStringWrite(OMdev dev, char *buff, int len);
/* input */
static int OMIOStringGetChar(OMdev dev);
static int OMIOStringLookAhead(OMdev dev);
static OMstatus OMIOStringRead(OMdev dev, char *buff, int len);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */


#define STATE(Dev)  ((OMStringIOPrivate)(Dev->io->private))
#define S(Dev)      (STATE(Dev)->s)
#define SIZE(Dev)   (STATE(Dev)->size)
#define LEN(Dev)    (OUTPOS(Dev))
#define INPOS(Dev)  (STATE(Dev)->inPos)
#define OUTPOS(Dev) (STATE(Dev)->outPos)
#define ROOM(Dev)   (SIZE(Dev)-OUTPOS(Dev))

/* the private structure for the FILE IO */
typedef struct OMStringIOPrivateStruct {
  char **s;
  int len;			/* lenght of real string *s */
  int size;			/* size of memory chunck pointed by *s */
  int inPos;			/* next position in *s to read */
  int outPos;			/* next position in *s to put */
} OMStringIOPrivateStruct;

typedef struct OMStringIOPrivateStruct *OMStringIOPrivate;

/* input */

Module OMstatus
OMreallocString(OMdev dev, int len)
{
  int nSize;
  char *ns;

  OMassert(dev);
  OMassert(len >= 0);

  nSize = SIZE(dev) + Max(len, (SIZE(dev) / 4) + 16);
  ns = OMreallocWarn(*(S(dev)), nSize, "Cannot allocate private IO buffer for string device.");
  if (ns) {
    *(S(dev)) = ns;
    SIZE(dev) = nSize;
    return OMsuccess;
  }
  else {
    return OMnoMem;
  }
}

Module OMstatus
OMIOStringFlush(OMdev dev)
{
  return OMsuccess;
}

Module OMstatus
OMIOStringPutChar(OMdev dev, char c)
{
  OMassert(dev);

  if (1 > ROOM(dev))
    OMcheckStatus(OMreallocString(dev, 1));
  (*(S(dev)))[OUTPOS(dev)] = c;
  OUTPOS(dev) += 1;
  return OMsuccess;
}


Module OMstatus
OMIOStringPrint(OMdev dev, char *s)
{
  OMassert(dev);
  OMassert(s);

  return OMIOStringWrite(dev, s, strlen(s));
}

Module OMstatus
OMIOStringWrite(OMdev dev, char *buff, int len)
{
  OMassert(dev);
  OMassert(buff);
  OMassert(len > 0);

  if (len > ROOM(dev))
    OMcheckStatus(OMreallocString(dev, len));
  memcpy((*(S(dev))) + OUTPOS(dev), buff, len);
  OUTPOS(dev) += len;
  return OMsuccess;
}


/* input */

Module int
OMIOStringGetChar(OMdev dev)
{
  OMassert(dev);

  if (INPOS(dev) >= LEN(dev)) {
    dev->error = OMemptyIO;
    return EOF;
  }
  return (*S(dev))[INPOS(dev)++];
}

Module int
OMIOStringLookAhead(OMdev dev)
{
  OMassert(dev);

  if (INPOS(dev) >= LEN(dev)) {
    dev->error = OMemptyIO;
    return EOF;
  }
  return (*S(dev))[INPOS(dev)];
}

Module OMstatus
OMIOStringRead(OMdev dev, char *buff, int len)
{
  OMassert(dev);
  OMassert(buff);
  OMassert(len >= 0);

  if (INPOS(dev) + len >= LEN(dev)) {
    dev->error = OMemptyIO;
    return OMemptyIO;
  }
  memcpy(buff, (*S(dev)) + INPOS(dev), len);
  INPOS(dev) += len;
  return OMsuccess;
}

Lib void
OMfreeIOString(OMIOStruct * io)
{
  OMassert(io->type == OMIOString);

  OMfreeInternal(io->private);
  OMfreeInternal(io);
}

/* OMmakeIOString
 *   Create a low level IO object from a string (NUL terminator is not needed).
 *   (May be used for copy/paste for instance.)
 * s: pointer to string to use into the OpenMath IO object.
 *    - In case of input device the string must be NUL terminated.
 *    - In case of output device string may be reallocated
 *      to fit size of outcoming objects.
 * return: a newly allocated IO object.
 */
World OMIO
OMmakeIOString(char **s)
{
  OMIO res;
  OMStringIOPrivate priv;

  OMassert(s);

  res = OMmallocWarn(sizeof(OMIOStruct), "Cannot allocate IO structure.");
  res->type = OMIOString;

  priv = res->private = OMmallocWarn(sizeof(OMStringIOPrivateStruct), "Cannot allocate private IO structure.");
  priv->s = s;
  if (*s) {
    priv->outPos = strlen(*s);
    priv->size = priv->outPos + 1;
  }
  else {
    priv->outPos = 0;
    priv->size = 0;
  }
  priv->inPos = 0;

  res->flush = OMIOStringFlush;
  res->putChar = OMIOStringPutChar;
  res->write = OMIOStringWrite;
  res->print = OMIOStringPrint;
  res->getChar = OMIOStringGetChar;
  res->lookAhead = OMIOStringLookAhead;
  res->read = OMIOStringRead;

  return res;
}
