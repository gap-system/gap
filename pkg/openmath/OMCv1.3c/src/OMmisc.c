/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"

const char *OMlibVersion = OM_LIB_VERSION;
const char *OMlibInfo = OM_LIB_INFO;

/* these pointers allow you to redefine memory managments functions used in lib */
void *(*OMmalloc) (size_t size) = malloc;
void *(*OMrealloc) (void *ptr, size_t size) = realloc;
void (*OMfree) (void *ptr) = free;

typedef void (*OMfatalFuncType) (OMstatus);
/* If set this function will be called by OMfatal thus you may use it for error handling (by default it is set to exit()) */
void (*OMfatal) (OMstatus status) = (OMfatalFuncType) exit;


/* some OM functions need to know if architecure is little or big endian
 * we intentionaly forgot PDP weird byte ordering
 */
int OMlittleEndianMode = 1;


/* static?... undocumented feature that may become useful ;) */
double OMdoubleInf, OMdoubleNegInf, OMdoubleNaN, OMdoubleLocalNaN;


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */


/************************************************************ End Prototypes */
/* end of automaticaly updated part */


/* used to store current verbosity level */
static int OMverbosity = 1;
static FILE *OMverboseLog = NULL;
static FILE *OMerrorLog = NULL;



/* dbgStopHere
 *   Convenience func. To stop under debugger put a break on it
 */
Lib int
dbgStopHere(void)
{
  return 1;
}

/*
 */
Lib void
OMreturnToDebugger(int val)
{
  OMprintf(0, "(trying to call debugger)\n");
  dbgStopHere();
}

/* OMstatusToString
 *   Convert a status to a human readable string that explain its meaning
 * status: status to explain
 * return: corresponding string
 */
World char *
OMstatusToString(OMstatus status)
{
  switch (status) {
  case OMsuccess:
    return "Last call was successful.";
  case OMfailed:
    return "Last call failed for some undetermined reason.";
  case OMnoMem:
    return "Last call failed for memory reasons.";
  case OMerrorSys:
    return "Last call failed during some system call.";
  case OMemptyIO:
    return "Last call to some OMget* function failed due to an unexpected EOF on input IO.";
  case OMnoMoreToken:
    return "Last call to some OMget* function failed because there is no more token on device.";
  case OMtimeoutedRead:
    return "Last call to some OMget* function timeouted.";
  case OMmalformedInput:
    return "Last call to some OMget* function failed due to malformed input. (this error covers all low level lexical or syntactic problems).";
  case OMaddrInUse:
    return "Last call to OMbindTCP failed because address is already in use (EADDRINUSE).";
  case OMconnectFailed:
    return "Last call to OMconnTCP failed to set connection.";
  case OMnotImplemented:
    return "Last call trigered some not (yet) implemented code in this lib.";
  case OMinternalError:
    return "Last call caused some internal trouble.";
  default:
    return "(Unknown status, internal trouble?)";
  }
}

/* OMtokenTypeToString
 *   Convert a tokenType to a human readable string
 * ttype: type to convert
 * return: corresponding string
 */
World char *
OMtokenTypeToString(OMtokenType ttype)
{
  switch (ttype) {
  case OMtokenUnknown:
    return "unknown";
  case OMtokenInt32:
    return "int32";
  case OMtokenBigInt:
    return "bigInt";
  case OMtokenFloat64:
    return "float64";
  case OMtokenByteArray:
    return "byteArray";
  case OMtokenSymbol:
    return "symbol";
  case OMtokenVar:
    return "var";
  case OMtokenString:
    return "string";
  case OMtokenWCString:
    return "wideCharString";
  case OMtokenApp:
    return "app";
  case OMtokenEndApp:
    return "endApp";
  case OMtokenAttr:
    return "attr";
  case OMtokenEndAttr:
    return "endAttr";
  case OMtokenAtp:
    return "atp";
  case OMtokenEndAtp:
    return "endAtp";
  case OMtokenError:
    return "error";
  case OMtokenEndError:
    return "endError";
  case OMtokenObject:
    return "object";
  case OMtokenEndObject:
    return "endObject";
  case OMtokenComment:
    return "comment";
  case OMtokenBind:
    return "bind";
  case OMtokenEndBind:
    return "endBind";
  case OMtokenBVar:
    return "bvar";
  case OMtokenEndBVar:
    return "endBvar";
  default:
    return "(Nothing known about this token type! Internal trouble?)";
  }
}

/* OMfatal
 *   Print a message to OMerrorLog
 *   (see OMsetVerbosityLevel and OMsetVerbosityOutput
 *   then call OMfatalFunc (if not NULL) with status
 *   (if compiled in OM_DEBUG mode, try to return to debuger).
 *   and finaly exit 
 * status: used as exit status
 * format,...: arguments passed to printf for OMerrorLog output
 * return: void
 */
Lib void
OMfatalInternal(OMstatus status, char *format,...)
{
  va_list args;

  OMassert(format);

  va_start(args, format);
  fprintf(OMerrorLog, "fatal error:\n  ");
  vfprintf(OMerrorLog, format, args);
  fflush(OMerrorLog);
#if OM_DEBUG
  OMreturnToDebugger(status);
#endif
  if (OMfatal) {
    (*OMfatal) (status);
  }
  va_end(args);
}

/* OMsetVerbosityLevel
 *   When using API some infos may be loged.
 *   This set the required verbosity level.
 * level: level of verbosity.
 *        0 means nothing is nether printed
 *        1 everything is printed (default)
 *        2,... less verbose
 * return: last verbosity level
 */
World int
OMsetVerbosityLevel(int level)
{
  int old;

  old = OMverbosity;
  OMverbosity = level;
  return old;
}

/* OMsetVerbosityOutput
 *   When using API some infos may be loged.
 *   This set the destination for logs.
 * logFile: where to output logs (default is stderr)
 * return: last output
 */
World FILE *
OMsetVerbosityOutput(FILE * logFile)
{
  FILE *old;

  OMassert(logFile);

  old = OMverboseLog;
  OMverboseLog = logFile;
  return old;
}

/* OMprintf
 *   Print a message on current verbose file (OMverboseLog)
 *   depending on current verbosity level (OMverbosity)
 * status: >0 print if status >= current verbosity level
 *          0 always print
 * format,...: arguments passed to printf if print enabled
 * return: void
 */
Lib void
OMprintf(int level, char *format,...)
{
  va_list args;

  OMassert(format);

  va_start(args, format);
  if ((!level) || (OMverbosity && (OMverbosity <= Abs(level)))) {
    vfprintf(OMverboseLog, format, args);
    fflush(OMverboseLog);
  }
  va_end(args);
}



/* OMmalloc
 *   Like std malloc but checks for allocation errors
 * size: size of chunck to allocate (in bytes)
 * return: pointer to allocated chunk
 */
Lib void *
OMmallocInternal(int size)
{
  void *mem;

  OMassert(size >= 0);

  if (!(mem = (*OMmalloc) (size))) {
    OMfatalInternal(OMnoMem, "Not enough memory to allocate %d bytes.\n", size);
  }
  return mem;
}

Lib void *
OMmallocWarn(int size, char *format,...)
{
  void *mem;
  va_list args;

  OMassert(size >= 0);

  if (!(mem = (*OMmalloc) (size))) {
    va_start(args, format);
    if (format) {
      vfprintf(OMerrorLog, format, args);
    }
    va_end(args);
    OMfatalInternal(OMnoMem, "Not enough memory to allocate %d bytes.\n", size);
  }
  return mem;
}

/* OMrealloc
 *   Like std realloc but checks for allocation error
 * old: pointer to old memory chunck (or NULL for a simple alloc)
 * size: size of (new) chunck to reallocate (in bytes)
 * return: pointer to reallocated chunk
 */
Lib void *
OMreallocInternal(void *old, int size)
{
  void *mem;

  OMassert(size >= 0);

  if (old) {
    mem = (*OMrealloc) (old, size);
    if (!mem)
      OMfatalInternal(OMnoMem, "Not enough memory to (re)allocate %d bytes.\n", size);
  }
  else
    mem = OMmallocInternal(size);

  return mem;
}

/* OMreallocWarn
 *   Like std realloc but checks for allocation error
 * old: pointer to old memory chunck (or NULL for a simple alloc)
 * size: size of (new) chunck to reallocate (in bytes)
 * format,...: arguments passed to printf if print enabled
 *
 * return: pointer to reallocated chunk
 */
Lib void *
OMreallocWarn(void *old, int size, char *format,...)
{
  void *mem;
  va_list args;

  OMassert(size >= 0);
  OMassert(format);

  if (old)
    mem = (*OMrealloc) (old, size);
  else
    mem = (*OMmalloc) (size);
  if (!mem) {
    va_start(args, format);
    if (format) {
      vfprintf(OMerrorLog, format, args);
    }
    va_end(args);
    OMfatalInternal(OMnoMem, "Not enough memory to (re)allocate %d bytes.\n", size);
  }
  return mem;
}


/* OMfree
 *   Like std free but checks for NULL pointers
 * p: pointer to free
 * return: void
 */
Lib void
OMfreeInternal(void *p)
{
  if (p)
    (*OMfree) (p);
}



/* OMdup
 *   Duplicates a memory chunck.
 * p: pointer to memory chunck.
 * len: size of memory chunck.
 * return: the newly allocated copy of p.
 */
Lib void *
OMdup(void *p, int len)
{
  void *new;
  if ((new = OMmallocInternal(len)))
    memcpy(new, p, len);
  return new;
}

Lib void
OMinitFd(void)
{
  static int initDone = 0;

  if (initDone)
    return;

  initDone = 1;
  OMverboseLog = stdout;
  OMerrorLog = stderr;

}

Lib void
OMinitMathCst(void)
{
  static int initDone = 0;

  union {
    double d;
    unsigned int i[2];
  } dtemp;
  unsigned int expo;

  if (initDone)
    return;

  initDone = 1;

  expo = 2047U << 20;

  dtemp.i[0] = 0;
  dtemp.i[1] = expo;
  OMdoubleInf = dtemp.d;

  dtemp.i[1] = expo | (1U << 31);
  OMdoubleNegInf = dtemp.d;

  dtemp.i[1] = expo | (1U << 19);
  OMdoubleNaN = dtemp.d;

#ifdef NAN
  OMdoubleLocalNaN = NAN;
#else
  OMdoubleLocalNaN = OMdoubleNaN;
#endif
  dtemp.d = OMdoubleNaN;

  /*  printf("nan : %x %x %lf\n", dtemp.i[0], dtemp.i[1], dtemp.d);
     dtemp.d = OMdoubleLocalNaN;
     printf("lnan: %x %x %lf\n", dtemp.i[0], dtemp.i[1], dtemp.d);
   */
}

Lib int
OMlittleEndianess(void)
{
  union {
    long l;
    char c[sizeof(long)];
  } u;
  u.l = 1;
  return (u.c[sizeof(long) - 1] == 0);
}

Lib double
OMdoubleLEBESwitch(double toConvert)
{
  double d;
  unsigned char *db = (unsigned char *) &d;
  unsigned char *tcb = (unsigned char *) &toConvert;

  db[0] = tcb[7];
  db[1] = tcb[6];
  db[2] = tcb[5];
  db[3] = tcb[4];
  db[4] = tcb[3];
  db[5] = tcb[2];
  db[6] = tcb[1];
  db[7] = tcb[0];

  return d;
}

/*
 * Convert memory chunck into a string reflecting its bit pattern
 */
Lib char *
OMbitString(char *p, int l)
{
  unsigned long mask = 1;
  char *rep;
  char *pt, c;
  int len, pak, i, j;
  len = l * 8;

  len += l - 1;
  rep = (char *) malloc(len + 1);
  rep[len] = '\0';
  pt = rep + len;
  pak = 0;
  for (i = 0; i < len; i++) {
    mask = 1;
    for (j = 0; j < 8; j++) {
      c = (p[i] & mask) ? '1' : '0';
      mask = mask << 1;
      *pt = c;
      pt--;
      pak++;
      if (pak == 8) {
	*pt = ' ';
	pt--;
	pak = 0;
      }
    }
  }
  while (pt >= rep) {
    *pt = ' ';
    pt--;
  }
  return rep;
}



/* OMlibDynamicInfo
 *   Gather some informations about lib that can't be statically determined.
 *   Complete them with some relevant static infornation too.
 * return: a newly allocated string
 */
World char *
OMlibDynamicInfo(void)
{
  char tmp[2048];

  sprintf(tmp, "OpenMath library\n   C version\n   From INRIA, CAFE Team\n   (for support email to Olivier.Arsac@sophia.inria.fr)\n   %s (%s)\n   %s endian mode\n", OMlibVersion, OMlibInfo, OMlittleEndianess()? "little" : "big");
  return strdup(tmp);
}
