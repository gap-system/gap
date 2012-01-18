/****************************************************************************
**
*W  gpipe.c               OpenMath for GAP source     Andrew Solomon
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This sample code uses the (lexical level) INRIA C library to 
**  parse OpenMath objects and write them out as a stream of bytes.
**  Each byte represents a token (the value of each token is given 
**  in the file ../include/gap_tokens.h) unless the 
**  token is followed by a value, in which case each part of the
**  value is a string followed by the byte representing token
**  gapOMtokenDelimiter (which corresponds to no token in the INRIA
**  C library.
**
**  Much of this code is canibalised from the example program
**  tpipe which comes with the INRIA C library.
**  
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
#include <errno.h>
#include <math.h>

#define EQSTRING(s1, s2) (strcmp(s1, s2) == 0)

/* These are the tokens returned on the stream to GAP */
#include "gap_tokens.h"



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
static void checkWriteStatus(int status);
static OMstatus pipeSymb(OMdev inDev, FILE *outFile);
static OMstatus pipeVar(OMdev inDev, FILE *outFile);
static OMstatus pipeAttrVar(OMdev inDev, FILE *outFile);
static OMstatus pipeApp(OMdev inDev, FILE *outFile);
static OMstatus pipeAttr(OMdev inDev, FILE *outFile);
static OMstatus pipeBind(OMdev inDev, FILE *outFile);
static OMstatus pipeError(OMdev inDev, FILE *outFile);
/* pipeObj
 *   Reads an OpenMath object from <inDev> and copy it to <outDev>.
 *   Syntax is checked to detect poorly structured objects.
 *   It is able to dup an incomplete object.
 *   (ie: that lacks the bounding <OMOBJ> </OMOBJ>
 * inDev: source device
 * outDev: destination device
 * return: 0 or some error status
 */
static OMstatus pipeObj(OMdev inDev, FILE *outFile);

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
  fprintf(stderr, "OpenMath to GAP input stream lib version %s (%s)\n", OMlibVersion, OMlibInfo);
  info = OMlibDynamicInfo();
  fprintf(stderr, "%s\n", info);
  free(info);
  fprintf(stderr, "gpipe -[ubx] inFile outFile\n");
  fprintf(stderr, "   Pipe OpenMath inFile into GAP-stream outFile\n");
  fprintf(stderr, "   in/outFile may be replaced by - for stdin/out.\n");
  fprintf(stderr, "   Used mainly for tests or sample purpose\n");
  fprintf(stderr, "   May also be used as a conversion tool,\n");
  fprintf(stderr, "   or as a basic pretty printer for XML OpenMath files.\n");
  fprintf(stderr, "   u/b/x means unknown/binary/xml encoding.\n");
  fprintf(stderr, "   u: creates an input device that will try to autodetect its encoding type.\n");
  fprintf(stderr, "   eg: tpipe -b A B\n");
  fprintf(stderr, "         Converts binary file A into GAP input file B.\n");
  fprintf(stderr, "       tpipe -u A B\n");
  fprintf(stderr, "         Converts an unknown encoding type OpenMath file A into a GAP input file B.\n");
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
    perror(tmp);
  }
}

static void
checkWriteStatus(int  status)
{
  char tmp[1024];

  if (status == -1) {
    sprintf(tmp, "last write to file returned error %d (%s)", 
			errno, strerror(errno));
    fatalError(status, tmp);
  }
}


static void OMfwriteByte(unsigned char b, FILE *outFile)
{
	char tmp[1];

	tmp[0]=b;

	checkWriteStatus(fwrite(tmp, 1, 1, outFile));
}

static void  OMfwriteString(char *outs, int len, FILE *outFile)
{
	checkWriteStatus(fwrite (outs, 1, len, outFile));
	OMfwriteByte(gapOMtokenDelimiter, outFile);
}

static OMstatus
pipeSymb(OMdev inDev, FILE *outFile)
{
  char cd[1024], name[1024];
  int cl, nl;

  /* a sample for getN/putN functions */
  checkStatus(OMgetSymbolLength(inDev, &cl, &nl));
  checkStatus(OMgetSymbolN(inDev, cd, cl, name, nl));
	OMfwriteByte(gapOMtokenSymbol, outFile);
	OMfwriteString(cd, cl, outFile);
	OMfwriteString(name, nl, outFile);
  return OMsuccess;
}


static OMstatus
pipeVar(OMdev inDev,  FILE *outFile)
{
  char *name;

  checkStatus(OMgetVar(inDev, &name));
  OMfwriteByte(gapOMtokenVar, outFile);
  OMfwriteString(name, strlen(name), outFile);
  return OMsuccess;
}


static OMstatus
pipeAttrVar(OMdev inDev, FILE *outFile)
{
  OMtokenType ttype;

  checkStatus(OMgetType(inDev, &ttype));
  if (ttype == OMtokenAttr)
    return pipeAttr(inDev, outFile);
  else
    return pipeVar(inDev, outFile);
}


static OMstatus
pipeApp(OMdev inDev,  FILE *outFile)
{
  OMtokenType ttype;

  /* begin tag */
  checkStatus(OMgetApp(inDev));
	OMfwriteByte(gapOMtokenApp, outFile);


  /* applied symbol */
/* but OpenMath 2.0 allows it to be any object, not necessarily a symbol */
/*  checkStatus(pipeSymb(inDev, outFile)); */

  /* arguments */
  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndApp)
      break;
    checkStatus(pipeObj(inDev, outFile));
  }

  /* end tag */
  checkStatus(OMgetEndApp(inDev));
  OMfwriteByte(gapOMtokenEndApp, outFile);

  return OMsuccess;
}


static OMstatus
pipeAttr(OMdev inDev,   FILE *outFile)
{
  OMtokenType ttype;

  /* begin attr tag */
  checkStatus(OMgetAttr(inDev));
  OMfwriteByte(gapOMtokenAttr, outFile);


  /* begin atp tag */
  checkStatus(OMgetAtp(inDev));
  OMfwriteByte(gapOMtokenAtp, outFile);

  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndAtp)
      break;
    /* pairs of attributes */
    checkStatus(pipeSymb(inDev, outFile));
    checkStatus(pipeObj(inDev, outFile));
  }

  /* end atp tag */
  checkStatus(OMgetEndAtp(inDev));
  OMfwriteByte(gapOMtokenEndAtp, outFile);

  /* attributed element */
  checkStatus(pipeObj(inDev, outFile));

  /* end attr tag */
  checkStatus(OMgetEndAttr(inDev));
  OMfwriteByte(gapOMtokenEndAttr, outFile);

  return OMsuccess;
}



static OMstatus
pipeBind(OMdev inDev,    FILE *outFile)
{
  OMtokenType ttype;

  /* begin bind tag */
  checkStatus(OMgetBind(inDev));
  OMfwriteByte(gapOMtokenBind, outFile);

  /* binder */
  checkStatus(pipeObj(inDev, outFile));

  /* begin bvar tag */
  checkStatus(OMgetBVar(inDev));
	OMfwriteByte(gapOMtokenBVar, outFile);

  /* bound variables */
  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndBVar)
      break;
    checkStatus(pipeAttrVar(inDev, outFile));
  }

  /* end bvar tag */
  checkStatus(OMgetEndBVar(inDev));
	OMfwriteByte(gapOMtokenEndBVar, outFile);

  /* bound object */
  checkStatus(pipeObj(inDev, outFile));

  /* end bind tag */
  checkStatus(OMgetEndBind(inDev));
	OMfwriteByte(gapOMtokenEndBind, outFile);

  return OMsuccess;
}

static OMstatus
pipeBigInt(OMdev inDev,  FILE *outFile)
{
	char *tmpstr;
	char *buf;
	int i,l,sign;
	OMbigIntType format;

	checkStatus(OMgetBigInt(inDev, &buf, &l, &sign, &format));
	/* returns a string in buf of length l. We just need to put
	the sign in front and an x if it is hexadecimal and a trailing \0. */

	tmpstr = (char *) malloc((l + 3)*sizeof(char));
	i = 0;

	if (sign < 0) 
	{
		*(tmpstr+i) = '-';
		i++;
	}

	if (format == OMbigIntBase16)
	{
		*(tmpstr+i) = 'x';
		i++;
	}

	sprintf(tmpstr +i, "%s", buf);
	OMfwriteByte(gapOMtokenInteger, outFile);
	OMfwriteString(tmpstr, l + i, outFile);
	free(buf);
	free(tmpstr);
  return OMsuccess;
}

static OMstatus
pipeError(OMdev inDev,     FILE *outFile)
{
  OMtokenType ttype;

  /* begin error tag */
  checkStatus(OMgetError(inDev));
	OMfwriteByte(gapOMtokenError, outFile);

  /* symbol */
  pipeSymb(inDev, outFile);

  /* error objects */
  while (1) {
    checkStatus(OMgetType(inDev, &ttype));
    if (ttype == OMtokenEndError)
      break;
    checkStatus(pipeObj(inDev, outFile));
  }

  /* end error tag */
  checkStatus(OMgetEndError(inDev));
	OMfwriteByte(gapOMtokenEndError, outFile);

  return OMsuccess;
}

/* AS up to here 15:37 7/9/99 */

/* pipeObj
 *   Reads an OpenMath object from <inDev> and copy it to <outFile>.
 *   Syntax is checked to detect poorly structured objects.
 *   It is able to dup an incomplete object.
 *   (ie: that lacks the bounding <OMOBJ> </OMOBJ>
 * inDev: source device
 * outDev: destibation device
 * return: 0 or some error status
 */
static OMstatus
pipeObj(OMdev inDev,    FILE *outFile)
{
  OMtokenType ttype;
  OMstatus status;
  char *buf;
  int i;
	double tmplog;


  /* check for end of parse */
  if ((status = OMgetType(inDev, &ttype))) 
	{
    if (status == OMnoMoreToken)
      return status;		/* OK that may be a normal exit condition */
    checkStatus(status);	/* there is something realy wrong */
  }

  /* pipe the token depending on its type */
  switch (ttype) {
  case OMtokenInt32:
    checkStatus(OMgetInt32(inDev, &i));

		/* There are at most log_10(i) + 1 characters in the string for abs(i),
    Add 1 inside the log10 in case abs(i) = 0 */
		tmplog = (double) log10((double) abs(i)+1) + 2;

		/* Add 1 for the null, 1 for the '-' */
		buf = (char *) malloc(sizeof(char)*( ceil(tmplog) + 2)); 

    sprintf(buf, "%d",i);
		OMfwriteByte(gapOMtokenInteger, outFile);
		OMfwriteString(buf, strlen(buf), outFile);
    free(buf);
    break;
  case OMtokenBigInt:
    checkStatus(pipeBigInt(inDev, outFile));
    break;
  case OMtokenSymbol:
    checkStatus(pipeSymb(inDev, outFile));
    break;
  case OMtokenVar:
    checkStatus(pipeVar(inDev, outFile));
    break;
  case OMtokenString:
    checkStatus(OMgetString(inDev, &buf));
		OMfwriteByte(gapOMtokenString, outFile);
		OMfwriteString(buf, strlen(buf), outFile);
    free(buf);
    break;
  case OMtokenApp:
    checkStatus(pipeApp(inDev, outFile));
    break;
  case OMtokenEndApp:
    fatalError(1, "syntax error: </OMA> found out of <OMA> scope.");
    break;
  case OMtokenAttr:
    checkStatus(pipeAttr(inDev, outFile));
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
    checkStatus(pipeBind(inDev, outFile));
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
    pipeError(inDev, outFile);
    break;
  case OMtokenEndError:
    fatalError(1, "syntax error: </OME> found out of <OME> scope.");
    break;
  case OMtokenObject:
    /* this object is explicitly enclosed in <OMOBJ> ... </OMOBJ> */
    checkStatus(OMgetObject(inDev));
		OMfwriteByte(gapOMtokenObject, outFile);
    /* parse embeded elements */
    checkStatus(pipeObj(inDev, outFile));
    /* end object tag */
    checkStatus(OMgetEndObject(inDev));
		OMfwriteByte(gapOMtokenEndObject, outFile);
    break;
  case OMtokenEndObject:
    fprintf(stderr, "warning: empty <OMOBJ></OMOBJ>!\n");
    break;
  case OMtokenByteArray:
  case OMtokenWCString:
  case OMtokenFloat64:
  default:
		{
      char tmp[1024];
      sprintf(tmp, "Not yet implemented or unknown token type (%d).\n", ttype);
      fatalError(1, tmp);
    }
  }


  return OMsuccess;
}


int
main(int argc, char *argv[])
{
  FILE *inFile, *outFile;
  OMdev inDev = (OMdev)NULL;
  OMstatus status;

  /* Check and parse arguments */
  if ((argc == 2) && EQSTRING(argv[1], "-h")) {
    usage(NULL);
  }
  if (argc != 4) {
    usage("Three arguments please...");
  }

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

  if (!inFile) {
    usage("Unable to open input file.");
  }
  if (!outFile) {
    usage("Unable to open output file.");
  }

  if (strlen(argv[1]) != 2) {
    usage("Bad first argument.");
  }

  switch (argv[1][1]) {
  case 'x':
    inDev = OMmakeDevice(OMencodingXML, OMmakeIOFile(inFile));
    break;
  case 'b':
    inDev = OMmakeDevice(OMencodingBinary, OMmakeIOFile(inFile));
    break;
  case 'u':
    inDev = OMmakeDevice(OMencodingUnknown, OMmakeIOFile(inFile));
    break;
  default:
    usage("Bad second argument");
  }



  /* Ignore comments */
  OMignoreComment(inDev, OMtrue);

  /* Endless pipe of OpenMath objects */
  while (1) 
	{
    if ((status = pipeObj(inDev, outFile))) 
		{
      if (status == OMnoMoreToken)
				break;			/* OK that's a normal exit condition */
      checkStatus(status);	/* there is something realy wrong */
    }
		fflush(outFile);
  }

  OMcloseDevice(inDev);

  return 0;
}
