/* This sample code uses the (lexical level) C library to 
 * parse and reprint OpenMath objects.
 * Thus it may be used as a pipe or as a translator.
 * It also checks for correct syntax of OpenMath obbjects.
 * (eg: an application must be followed by a symbol)
 * It is a test and a demonstration of the OpenMath C API.
 */

#ifndef __CEXTRACT__
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#endif /* __CEXTRACT__ */

#include "OM.h"

#define EQSTRING(s1, s2) (strcmp(s1, s2) == 0)

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/* usage
 *   Prints some kind of usage message.
 */
static void usage(char *message);
static void fatalError(OMstatus status, char *msg);
/* checkStatus
 *   Checks for errors reported in status.
 *   If status is not OMsuccess 
 *   then prints corresponding error message and exit;
 * status: status to check
 */
static void checkStatus(OMstatus status);
static OMstatus pipeSymb(OMdev inDev, OMdev outDev);
static OMstatus pipeVar(OMdev inDev, OMdev outDev);
static OMstatus pipeAttrVar(OMdev inDev, OMdev outDev);
static OMstatus pipeApp(OMdev inDev, OMdev outDev);
static OMstatus pipeAttr(OMdev inDev, OMdev outDev);
static OMstatus pipeBind(OMdev inDev, OMdev outDev);
static OMstatus pipeError(OMdev inDev, OMdev outDev);
/* pipeComments
 *   Pipes/skips comments (if any).
 */
static OMstatus pipeComments(OMdev inDev, OMdev outDev);
/* pipeObj
 *   Reads an OpenMath object from <inDev> and copy it to <outDev>.
 *   Syntax is checked to detect poorly structured obhects.
 *   It is able to dup an incomplete object.
 *   (ie: that lacks the bounding <OMOBJ> </OMOBJ>
 * inDev: source device
 * outDev: destibation device
 * return: 0 or some error status
 */
static OMstatus pipeObj(OMdev inDev, OMdev outDev);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */



/* usage
 *   Prints some kind of usage message.
 */
static void
usage(char *message)
{
  char *info;

  if (message) {
    fprintf(stderr, "Error: %s\n", message);
  }
  fprintf(stderr, "Tests for OpenMath lib version %s (%s)\n", OMlibVersion, OMlibInfo);
  info = OMlibDynamicInfo();
  fprintf(stderr, "%s\n", info);
  free(info);
  fprintf(stderr, "tpipe -[ubx][bx] inFile outFile\n");
  fprintf(stderr, "   Pipe OpenMath inFile into OpenMath outFile\n");
#ifndef WIN32
  fprintf(stderr, "   in/outFile may be replaced by - for stdin/out.\n");
#endif
  fprintf(stderr, "   Used mainly for tests or sample purpose\n");
  fprintf(stderr, "   May also be used as a conversion tool,\n");
  fprintf(stderr, "   or as a basic pretty printer for XML OpenMath files.\n");
  fprintf(stderr, "   u/b/x means unknown/binary/xml encoding.\n");
  fprintf(stderr, "   u: creates an input device that will try to autodetect its encoding type.\n");
  fprintf(stderr, "   eg: tpipe -bx A B\n");
  fprintf(stderr, "         Converts binary file A into XML text file B.\n");
  fprintf(stderr, "         (pretty printing it by the way).\n");
  fprintf(stderr, "       tpipe -ub A B\n");
  fprintf(stderr, "         Converts an unknown encoding type OpenMath file A into a binary file B.\n");
  exit(1);
}


static void
fatalError(OMstatus status, char *msg)
{
  fprintf(stderr, "Fatal error: %s\n", msg);
  exit(status);
}


/* checkStatus
 *   Checks for errors reported in status.
 *   If status is not OMsuccess 
 *   then prints corresponding error message and exit;
 * status: status to check
 */
static void
checkStatus(OMstatus status)
{
  char tmp[1024];

  if (status != OMsuccess) {
    sprintf(tmp, "last call to OMlib returned error status %d (%s)", status, OMstatusToString(status));
    fatalError(status, tmp);
  }
}


static OMstatus
pipeSymb(OMdev inDev, OMdev outDev)
{
  char cd[1024], name[1024];
  int cl, nl;

  pipeComments(inDev, outDev);
  /* a sample for getN/putN functions */
  checkStatus(OMgetSymbolLength(inDev, &cl, &nl));
  checkStatus(OMgetSymbolN(inDev, cd, cl, name, nl));
  checkStatus(OMputSymbolN(outDev, cd, cl, name, nl));
  return OMsuccess;
}


static OMstatus
pipeVar(OMdev inDev, OMdev outDev)
{
  char *name;

  pipeComments(inDev, outDev);
  checkStatus(OMgetVar(inDev, &name));
  checkStatus(OMputVar(outDev, name));
  return OMsuccess;
}

static OMstatus
pipeAttrVar(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;

  pipeComments(inDev, outDev);
  checkStatus(OMgetType(inDev, &ttype));
  if (ttype == OMtokenAttr)
    return pipeAttr(inDev, outDev);
  else
    return pipeVar(inDev, outDev);
}


static OMstatus
pipeApp(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;

  /* begin tag */
  checkStatus(OMgetApp(inDev));
  checkStatus(OMputApp(outDev));

  /* applied symbol */
  checkStatus(pipeSymb(inDev, outDev));

  /* arguments */
  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndApp)
      break;
    checkStatus(pipeObj(inDev, outDev));
  }

  /* end tag */
  checkStatus(OMgetEndApp(inDev));
  checkStatus(OMputEndApp(outDev));

  return OMsuccess;
}


static OMstatus
pipeAttr(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;

  /* begin attr tag */
  checkStatus(OMgetAttr(inDev));
  checkStatus(OMputAttr(outDev));

  /* begin atp tag */
  checkStatus(OMgetAtp(inDev));
  checkStatus(OMputAtp(outDev));

  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndAtp)
      break;
    /* pairs of attributes */
    checkStatus(pipeSymb(inDev, outDev));
    checkStatus(pipeObj(inDev, outDev));
  }

  /* end atp tag */
  checkStatus(OMgetEndAtp(inDev));
  checkStatus(OMputEndAtp(outDev));

  /* attributed element */
  checkStatus(pipeObj(inDev, outDev));

  /* end attr tag */
  checkStatus(OMgetEndAttr(inDev));
  checkStatus(OMputEndAttr(outDev));

  return OMsuccess;
}


static OMstatus
pipeBind(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;

  /* begin bind tag */
  checkStatus(OMgetBind(inDev));
  checkStatus(OMputBind(outDev));

  /* binder */
  checkStatus(pipeObj(inDev, outDev));

  /* begin bvar tag */
  checkStatus(OMgetBVar(inDev));
  checkStatus(OMputBVar(outDev));

  /* bound variables */
  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndBVar)
      break;
    checkStatus(pipeAttrVar(inDev, outDev));
  }

  /* end bvar tag */
  checkStatus(OMgetEndBVar(inDev));
  checkStatus(OMputEndBVar(outDev));

  /* bound object */
  checkStatus(pipeObj(inDev, outDev));

  /* end bind tag */
  checkStatus(OMgetEndBind(inDev));
  checkStatus(OMputEndBind(outDev));

  return OMsuccess;
}


static OMstatus
pipeError(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;

  /* begin error tag */
  checkStatus(OMgetError(inDev));
  checkStatus(OMputError(outDev));

  /* symbol */
  pipeSymb(inDev, outDev);

  /* error objects */
  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndError)
      break;
    checkStatus(pipeObj(inDev, outDev));
  }

  /* end error tag */
  checkStatus(OMgetEndError(inDev));
  checkStatus(OMputEndError(outDev));

  return OMsuccess;
}

/* pipeComments
 *   Pipes/skips comments (if any).
 */
static OMstatus
pipeComments(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;
  OMstatus status;
  char *buf;

  while (1) {
    if (status = OMgetType(inDev, &ttype)) {
      if (status == OMnoMoreToken)
	return status;		/* OK that may be a normal exit condition */
      checkStatus(status);	/* there is something realy wrong */
    }

    if (ttype == OMtokenComment) {
      /* this is a comment
       * (they can be put everywhere)
       * thus skip/process it and continue 
       * (fakes it wasn't here) 
       */
      checkStatus(OMgetComment(inDev, &buf));
      checkStatus(OMputComment(outDev, buf));
      free(buf);
    }
    else {
      /* this is a plain element thus process it 
       * (do real grammar check) */
      break;
    }
  }
  return OMsuccess;
}

/* pipeObj
 *   Reads an OpenMath object from <inDev> and copy it to <outDev>.
 *   Syntax is checked to detect poorly structured obhects.
 *   It is able to dup an incomplete object.
 *   (ie: that lacks the bounding <OMOBJ> </OMOBJ>
 * inDev: source device
 * outDev: destibation device
 * return: 0 or some error status
 */
static OMstatus
pipeObj(OMdev inDev, OMdev outDev)
{
  OMtokenType ttype;
  OMstatus status;
  char *buf;
  OMUCS2 *wcbuf;
  double d;
  int i, l, sign;
  OMbigIntType format;

  /* pipe/skip comments (if any) */
  pipeComments(inDev, outDev);

  /* check for end of parse */
  if (status = OMgetType(inDev, &ttype)) {
    if (status == OMnoMoreToken)
      return status;		/* OK that may be a normal exit condition */
    checkStatus(status);	/* there is something realy wrong */
  }

  /* pipe the token depending on its type */
  switch (ttype) {
  case OMtokenInt32:
    checkStatus(OMgetInt32(inDev, &i));
    checkStatus(OMputInt32(outDev, i));
    break;
  case OMtokenFloat64:
    checkStatus(OMgetFloat64(inDev, &d));
    checkStatus(OMputFloat64(outDev, &d));
    break;
  case OMtokenByteArray:
    checkStatus(OMgetByteArray(inDev, &buf, &l));
    checkStatus(OMputByteArray(outDev, buf, l));
    free(buf);
    break;
  case OMtokenBigInt:
    checkStatus(OMgetBigInt(inDev, &buf, &l, &sign, &format));
    checkStatus(OMputBigInt(outDev, buf, l, sign, format));
    free(buf);
    break;
  case OMtokenSymbol:
    checkStatus(pipeSymb(inDev, outDev));
    break;
  case OMtokenVar:
    checkStatus(pipeVar(inDev, outDev));
    break;
  case OMtokenString:
    checkStatus(OMgetString(inDev, &buf));
    checkStatus(OMputString(outDev, buf));
    free(buf);
    break;
  case OMtokenWCString:
    /* some application may assume that they only use 
     * plain 8bits strings... (this is probably not a 
     * good idea but it may be ok if speed considerations
     * are in balance)
     * tpipe is suposed to work on all inputs thus it
     * must deal with wide char strings (16bits chars)
     */
    checkStatus(OMgetWCString(inDev, &wcbuf));
    checkStatus(OMputWCString(outDev, wcbuf));
    free(wcbuf);
    break;
  case OMtokenApp:
    checkStatus(pipeApp(inDev, outDev));
    break;
  case OMtokenEndApp:
    fatalError(1, "syntax error: </OMA> found out of <OMA> scope.");
    break;
  case OMtokenAttr:
    checkStatus(pipeAttr(inDev, outDev));
    break;
  case OMtokenEndAttr:
    fatalError(1, "syntax error: </OMATTR> found out of <OMATTR> scope.");
    break;
  case OMtokenAtp:
    fatalError(1, "syntax error: <OMATP> found out of <OMATTR> scope.");
    break;
  case OMtokenEndAtp:
    fatalError(1, "syntax error: </OMATP> found out of <OMATTR> scope.");
    break;
  case OMtokenBind:
    checkStatus(pipeBind(inDev, outDev));
    break;
  case OMtokenEndBind:
    fatalError(1, "syntax error: </OMBIND> found out of <OMBIND> scope.");
    break;
  case OMtokenBVar:
    fatalError(1, "syntax error: <OMBVAR> found out of <OMBIND> scope.");
    break;
  case OMtokenEndBVar:
    fatalError(1, "syntax error: </OMBVAR> found out of <OMBIND> scope.");
    break;
  case OMtokenError:
    pipeError(inDev, outDev);
    break;
  case OMtokenEndError:
    fatalError(1, "syntax error: </OME> found out of <OME> scope.");
    break;
  case OMtokenObject:
    /* this object is explicitly enclosed in <OMOBJ> ... </OMOBJ> */
    checkStatus(OMgetObject(inDev));
    checkStatus(OMputObject(outDev));
    /* parse embeded elements */
    checkStatus(pipeObj(inDev, outDev));
    /* end object tag */
    checkStatus(OMgetEndObject(inDev));
    checkStatus(OMputEndObject(outDev));
    break;
  case OMtokenEndObject:
    fprintf(stderr, "warning: empty <OMOBJ></OMOBJ>!\n");
    break;
  default:{
      char tmp[1024];
      sprintf(tmp, "Not yet implemented or unknown token type (%d).\n", ttype);
      fatalError(1, tmp);
    }
  }

  /* pipe/skip comments (if any) */
  pipeComments(inDev, outDev);

  return OMsuccess;
}


int
main(int argc, char *argv[])
{
#ifndef WIN32
  FILE *inFile, *outFile;
#else
  HANDLE inFile, outFile;
#endif
  OMdev inDev, outDev;
  OMstatus status;

  /* Check and parse arguments */
  if ((argc == 2) && EQSTRING(argv[1], "-h")) {
    usage(NULL);
  }
  if (argc != 4) {
    usage("Three arguments please...");
  }

#ifdef WIN32
  inFile = CreateFile(argv[2], GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  outFile = CreateFile(argv[3], GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
#else
  if (EQSTRING(argv[2], "-")) {
    inFile = stdin;
  }
  else {
    inFile = fopen(argv[2], "r");
  }
  if (EQSTRING(argv[3], "-")) {
    outFile = stdout;
  }
  else {
    outFile = fopen(argv[3], "w");
  }
#endif

  if (!inFile) {
    usage("Unable to open input file.");
  }
  if (!outFile) {
    usage("Unable to open output file.");
  }

  if (strlen(argv[1]) != 3) {
    usage("Bad first argument.");
  }

  switch (argv[1][1]) {
#ifdef WIN32
  case 't':
    inDev = OMmakeDevice(OMencodingXML, OMmakeIOHandle(inFile));
    break;
  case 'x':
    inDev = OMmakeDevice(OMencodingXML, OMmakeIOHandle(inFile));
    break;
  case 'b':
    inDev = OMmakeDevice(OMencodingBinary, OMmakeIOHandle(inFile));
    break;
  case 'u':
    inDev = OMmakeDevice(OMencodingUnknown, OMmakeIOHandle(inFile));
    break;
#else /* UNICES */
  case 't':
    inDev = OMmakeDevice(OMencodingXML, OMmakeIOFile(inFile));
    break;
  case 'x':
    inDev = OMmakeDevice(OMencodingXML, OMmakeIOFile(inFile));
    break;
  case 'b':
    inDev = OMmakeDevice(OMencodingBinary, OMmakeIOFile(inFile));
    break;
  case 'u':
    inDev = OMmakeDevice(OMencodingUnknown, OMmakeIOFile(inFile));
    break;
#endif
  default:
    usage("Bad second argument");
  }


  switch (argv[1][2]) {
#ifdef WIN32
  case 't':
    outDev = OMmakeDevice(OMencodingXML, OMmakeIOHandle(outFile));
    break;
  case 'x':
    outDev = OMmakeDevice(OMencodingXML, OMmakeIOHandle(outFile));
    break;
  case 'b':
    outDev = OMmakeDevice(OMencodingBinary, OMmakeIOHandle(outFile));
    break;
#else /* UNICES */
  case 't':
    outDev = OMmakeDevice(OMencodingXML, OMmakeIOFile(outFile));
    break;
  case 'x':
    outDev = OMmakeDevice(OMencodingXML, OMmakeIOFile(outFile));
    break;
  case 'b':
    outDev = OMmakeDevice(OMencodingBinary, OMmakeIOFile(outFile));
    break;
#endif

  default:
    usage("Bad third argument.");
  }

  /* Consider comments as plain tokens (thus pipe them). */
  OMignoreComment(inDev, OMfalse);

  /* Endless pipe of OpenMath objects */
  while (1) {
    checkStatus(OMbeginObject(outDev));
    if (status = pipeObj(inDev, outDev)) {
      if (status == OMnoMoreToken)
	break;			/* OK that's a normal exit condition */
      checkStatus(status);	/* there is something realy wrong */
    }
    checkStatus(OMendObject(outDev));
  }

  OMcloseDevice(inDev);
  OMcloseDevice(outDev);

  return 0;
}
