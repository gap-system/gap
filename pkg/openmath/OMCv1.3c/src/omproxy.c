#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#ifndef WIN32
#include <unistd.h>
#include <string.h>
#include <netdb.h>
#include <strings.h>
#endif /* WIN32 */

#include "OM.h"
#include "OMconn.h"
#include "parseopt.h"

/*
   Some samples:

   real proxy is the 2nd one. the two others are faking client server apps
   omproxy -l 7007 -e xml -o todel.end &
   omproxy -l 7008 -e mimic -d todel.dup -p 7007 &
   omproxy -i test1.omb -p 7008 

   faking client/server
   omproxy -l 7008 -e mimic -o todel.end &
   omproxy -i test1.omb -p 7008 

 */

/* This program has been made to test OMconn
 * but it may be used to trace communications between 
 * two OpenMath applications.
 * just put it inbetween the two apps
 * eg: if you run a server on host at port 1000
 *     start omproxy as a client fir this server
 *     omproxy -h host -p 1000 -l 1001
 *     then connect your client to omproxy port 1001 
 *     (rather than on server)
 *     omproxy will act like a pipe for between your two apps
 *     but this pipe can be a tee or a tracer!
 */

/* to learn how to use OMlib read the doc then take a look at tpipe.c
 * this code is perhaps a bit too intricated to be a good starting point */


#define streq(S1,S2) (!strcmp(S1,S2))

/* see initArguments for comments */
typedef struct Arguments {
  char *inEncoding;
  char *inFile;
  int inPort;
  char *outEncoding;
  char *outFile;
  char *outHost;
  int outPort;
  char *dupFile;
  char *logFile;
  int verbosity;
} Arguments;

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/* Theses are kind of Linux specific. */
/*
 */
static void proxyVersion(FILE * out);
/*
 */
static void fatalError(OMstatus status, char *msg);
/*
 */
static void checkStatus(OMstatus status);
/* this funxtion pipe a token without syntactic check
 */
static OMstatus pipeToken(OMdev inDev, OMdev outDev, OMdev dupDev, FILE * logFile, int verbosity);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */


/*
 */
static void
proxyVersion(FILE * out)
{
  char *info;

  fprintf(out, "Proxy for OpenMath lib version %s (%s)\n", OMlibVersion, OMlibInfo);
  info = OMlibDynamicInfo();
  fprintf(out, "%s", info);
  free(info);
}


/* set parsing options
 */
void
setOptions(Options * options, Arguments * args)
{
  char host[128];

#ifdef WIN32
  sprintf(host, "localhost");
#else
  gethostname(host, sizeof(host));
#endif

  memset(args, 0, sizeof(Arguments));
  initOptions(options, proxyVersion,
	      "omproxy \n"
	      "   OpenMath proxy.\n"
	      "   Repeats an incoming stream.\n"
	      "   (stream may be socket or file).\n"
	      "   when going through, OpenMath objects may be traced.\n"
	      "\n"
	      "   eg: omproxy -o received.om\n"
	      "   eg: omproxy -i tosend.om -h server.com -p 8000\n"
	      "   eg: omproxy -l 8000 -d routed.om -h server.com -p 8000\n"
	      "   eg: omproxy -i in.om -o out.om -v3\n"

    );

  setOption(options, 'l', "inport", "port to listen to for connection to proxy.", OTint, "7007", &(args->inPort));
  setOption(options, 'p', "outport", "port to use for host connection.", OTint, "7007", &(args->outPort));
  setOption(options, 'h', "host", "host to connect to.", OTstring, strdup(host), &(args->outHost));
  setOption(options, 'i', "infile", "file to read from (instead of socket).", OTstring, NULL, &(args->inFile));
  setOption(options, 'o', "outfile", "file to write to (instead of socket).", OTstring, NULL, &(args->outFile));
  setOption(options, 'd', "dupfile", "duplicate output into this file.", OTstring, NULL, &(args->dupFile));
  setOption(options, 'e', "encoding", "encoding used for output. (mimic, binary or xml)", OTstring, "mimic", &(args->outEncoding));
  setOption(options, '\0', "tracefile", "file to write log to (default is stdout).", OTstring, NULL, &(args->logFile));
  setOption(options, 'v', "verbosity", "verbosity level (0 nothing, 1 only tokens, 2 tokens+time, 3 2+values).", OTint, "0", &(args->verbosity));
}


/*
 */
static void
fatalError(OMstatus status, char *msg)
{
  fprintf(stderr, "Fatal error: %s\n", msg);
  exit(status);
}


/*
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


/* this funxtion pipe a token without syntactic check
 */
static OMstatus
pipeToken(OMdev inDev, OMdev outDev, OMdev dupDev, FILE * logFile, int verbosity)
{
  OMstatus status;
  OMtokenType ttype;
  OMbigIntType format;
  char *buf, *vname;
  OMUCS2 *wcbuf;
  char cd[1025], name[1025];
  double d;
  int i, l, sign, inTokenNb;

  if ((status = OMgetType(inDev, &ttype)) == OMnoMoreToken) {
    /* no more token on this device */
    return status;
  }

  /* mimic input device encoding:
   * set out(dup) device encoding when first token is coming on input device.
   * (thus we are sure input device encoding is not OMencodingUnknown)
   * if outDev has already a real encoding let it be.
   */
  OMtokenCount(inDev, &inTokenNb, NULL);
  if ((inTokenNb == 0) && (OMgetDeviceEncoding(outDev) == OMencodingUnknown)) {
    OMsetDeviceEncoding(outDev, OMgetDeviceEncoding(inDev));
    if (dupDev)
      OMsetDeviceEncoding(dupDev, OMgetDeviceEncoding(inDev));
  }

  /* time trace */
  if (verbosity >= 2) {
    char ft[128];
    struct tm *brokt;
    time_t t;
    t = time(NULL);
    brokt = localtime(&t);
    strftime(ft, sizeof(ft), "%Y/%m/%d %H:%M:%S ", brokt);
    fprintf(logFile, "%s", ft);
  }

  /* error check */
  checkStatus(status);

  /* token type trace */
  if (verbosity >= 1) {
    fprintf(logFile, "%s", OMtokenTypeToString(ttype));
  }

  /* token pipe and trace */
  switch (ttype) {
  case OMtokenInt32:
    checkStatus(OMgetInt32(inDev, &i));
    if (verbosity >= 3)
      fprintf(logFile, ": %d", i);
    checkStatus(OMputInt32(outDev, i));
    if (dupDev)
      checkStatus(OMputInt32(dupDev, i));
    break;
  case OMtokenFloat64:
    checkStatus(OMgetFloat64(inDev, &d));
    if (verbosity >= 3)
      fprintf(logFile, ": %g", d);
    checkStatus(OMputFloat64(outDev, &d));
    if (dupDev)
      checkStatus(OMputFloat64(dupDev, &d));
    break;
  case OMtokenByteArray:
    checkStatus(OMgetByteArray(inDev, &buf, &l));
    if (verbosity >= 3)
      fprintf(logFile, ": len %d", l);
    checkStatus(OMputByteArray(outDev, buf, l));
    if (dupDev)
      checkStatus(OMputByteArray(dupDev, buf, l));
    free(buf);
    break;
  case OMtokenBigInt:
    checkStatus(OMgetBigInt(inDev, &buf, &l, &sign, &format));
    if (verbosity >= 3)
      fprintf(logFile, ": %s%s", (sign < 0) ? "-" : "", buf);

    checkStatus(OMputBigInt(outDev, buf, l, sign, format));
    if (dupDev)
      checkStatus(OMputBigInt(dupDev, buf, l, sign, format));
    free(buf);
    break;
  case OMtokenSymbol:
    checkStatus(OMgetSymbolN(inDev, cd, sizeof(cd), name, sizeof(name)));
    if (verbosity >= 3)
      fprintf(logFile, ": cd=\"%s\" name=\"%s\"", cd, name);
    checkStatus(OMputSymbol(outDev, cd, name));
    if (dupDev)
      checkStatus(OMputSymbol(dupDev, cd, name));
    break;
  case OMtokenVar:
    checkStatus(OMgetVar(inDev, &vname));
    if (verbosity >= 3)
      fprintf(logFile, ": \"%s\"", vname);
    checkStatus(OMputVar(outDev, vname));
    if (dupDev)
      checkStatus(OMputVar(dupDev, vname));
    free(vname);
    break;
  case OMtokenString:
    OMgetString(inDev, &buf);
    if (verbosity >= 3)
      fprintf(logFile, ": \"%s\"", buf);
    OMputString(outDev, buf);
    if (dupDev)
      OMputString(dupDev, buf);
    free(buf);
    break;
  case OMtokenWCString:
    OMgetWCString(inDev, &wcbuf);
    if (verbosity >= 3) {
      OMUCS2 *ptr, wc;
      fprintf(logFile, ": \"");
      while (*ptr) {
	wc = *(ptr++);
	if (wc < 256)
	  fprintf(logFile, "%c", (char) (wc));
	else
	  fprintf(logFile, "(%.2x:%.2x)", wc >> 8, (char) (wc));
      }
      fprintf(logFile, "\"");
    }
    OMputWCString(outDev, wcbuf);
    if (dupDev)
      OMputWCString(dupDev, wcbuf);
    free(wcbuf);
    break;
  case OMtokenComment:
    OMgetComment(inDev, &buf);
    if (verbosity >= 3)
      fprintf(logFile, ": \"%s\"", buf);
    OMputComment(outDev, buf);
    if (dupDev)
      OMputComment(dupDev, buf);
    free(buf);
    break;
  case OMtokenApp:
    checkStatus(OMgetApp(inDev));
    checkStatus(OMputApp(outDev));
    if (dupDev)
      checkStatus(OMputApp(dupDev));
    break;
  case OMtokenEndApp:
    checkStatus(OMgetEndApp(inDev));
    checkStatus(OMputEndApp(outDev));
    if (dupDev)
      checkStatus(OMputEndApp(dupDev));
    break;
  case OMtokenAttr:
    checkStatus(OMgetAttr(inDev));
    checkStatus(OMputAttr(outDev));
    if (dupDev)
      checkStatus(OMputAttr(dupDev));
    break;
  case OMtokenEndAttr:
    checkStatus(OMgetEndAttr(inDev));
    checkStatus(OMputEndAttr(outDev));
    if (dupDev)
      checkStatus(OMputEndAttr(dupDev));
    break;
  case OMtokenAtp:
    checkStatus(OMgetAtp(inDev));
    checkStatus(OMputAtp(outDev));
    if (dupDev)
      checkStatus(OMputAtp(dupDev));
    break;
  case OMtokenEndAtp:
    checkStatus(OMgetEndAtp(inDev));
    checkStatus(OMputEndAtp(outDev));
    if (dupDev)
      checkStatus(OMputEndAtp(dupDev));
    break;
  case OMtokenBind:
    checkStatus(OMgetBind(inDev));
    checkStatus(OMputBind(outDev));
    if (dupDev)
      checkStatus(OMputBind(dupDev));
    break;
  case OMtokenEndBind:
    checkStatus(OMgetEndBind(inDev));
    checkStatus(OMputEndBind(outDev));
    if (dupDev)
      checkStatus(OMputEndBind(dupDev));
    break;
  case OMtokenBVar:
    checkStatus(OMgetBVar(inDev));
    checkStatus(OMputBVar(outDev));
    if (dupDev)
      checkStatus(OMputBVar(dupDev));
    break;
  case OMtokenEndBVar:
    checkStatus(OMgetEndBVar(inDev));
    checkStatus(OMputEndBVar(outDev));
    if (dupDev)
      checkStatus(OMputEndBVar(dupDev));
    break;
  case OMtokenError:
    checkStatus(OMgetError(inDev));
    checkStatus(OMputError(outDev));
    if (dupDev)
      checkStatus(OMputError(dupDev));
    break;
  case OMtokenEndError:
    checkStatus(OMgetEndError(inDev));
    checkStatus(OMputEndError(outDev));
    if (dupDev)
      checkStatus(OMputEndError(dupDev));
    break;
  case OMtokenObject:
    checkStatus(OMgetObject(inDev));
    checkStatus(OMbeginObject(outDev));
    if (dupDev)
      checkStatus(OMbeginObject(dupDev));
    checkStatus(OMputObject(outDev));
    if (dupDev)
      checkStatus(OMputObject(dupDev));
    break;
  case OMtokenEndObject:
    checkStatus(OMgetEndObject(inDev));
    checkStatus(OMputEndObject(outDev));
    if (dupDev)
      checkStatus(OMputEndObject(dupDev));
    checkStatus(OMendObject(outDev));
    if (dupDev)
      checkStatus(OMendObject(dupDev));
    break;
  default:{
      char tmp[1024];
      sprintf(tmp, "Not yet implemented or unknown token type %d.\n", ttype);
      fatalError(1, tmp);
    }
  }

  if (verbosity >= 1) {
    fprintf(logFile, "\n");
  }

  return OMsuccess;
}


int
main(int argc, char **argv)
{
  Arguments args;
  Options options;
  char **unparsed;
  int unparsedNb;
  FILE *inFile, *outFile, *dupFile = NULL, *logFile = stdout;
  OMdev inDev, outDev, dupDev = NULL;
  OMIO inIO, outIO, dupIO;
  OMconn inConn, outConn;
  OMencodingType outEncoding;

  setOptions(&options, &args);
  if (parseOptions(&options, argc, argv, &unparsedNb, &unparsed)) {
    exit(1);
  }
  if (unparsedNb) {
    usageOptions(&options, "garbage in command line. last %d arguments are left unparsed.\n", unparsedNb);
    exit(1);
  }


  if (streq((args.outEncoding), "mimic")) {
    /* in pipeToken this encoding will be replaced by the one of input device */
    outEncoding = OMencodingUnknown;
  }
  else if (streq((args.outEncoding), "binary")) {
    /* enforce encoding, thus proxy may do encoding translations */
    outEncoding = OMencodingBinary;
  }
  else if (streq((args.outEncoding), "xml")) {
    /* enforce encoding, thus proxy may do encoding translations */
    outEncoding = OMencodingXML;
  }


  if (args.inFile) {
    inFile = fopen(args.inFile, "r");
    if (inFile) {
      inIO = OMmakeIOFile(inFile);
      /* let the lib detect encoding type */
      inDev = OMmakeDevice(OMencodingUnknown, inIO);
    }
    else {
      usageOptions(&options, "can't open file %s for read.\n", args.inFile);
      exit(1);
    }
  }
  else {
    inConn = OMmakeConn(1000);
    checkStatus(OMbindTCP(inConn, args.inPort));
    inDev = OMconnIn(inConn);
    /* let the lib detect encoding type */
    OMsetDeviceEncoding(inDev, OMencodingUnknown);
  }


  if (args.outFile) {
    outFile = fopen(args.outFile, "w");
    if (outFile) {
      outIO = OMmakeIOFile(outFile);
      outDev = OMmakeDevice(outEncoding, outIO);
    }
    else {
      usageOptions(&options, "can't open file %s for write.\n", args.outFile);
      exit(1);
    }
  }
  else {
    /* wait 10s for server awake or fail */
    outConn = OMmakeConn(10000);
    checkStatus(OMconnTCP(outConn, args.outHost, args.outPort));
    outDev = OMconnOut(outConn);
    OMsetDeviceEncoding(outDev, outEncoding);
  }

  if (args.dupFile) {
    dupFile = fopen(args.dupFile, "w");
    if (dupFile) {
      dupIO = OMmakeIOFile(dupFile);
      /* dupDev will use same encoding as outDev */
      dupDev = OMmakeDevice(outEncoding, dupIO);
    }
    else {
      usageOptions(&options, "can't open file %s for write.\n", args.dupFile);
      exit(1);
    }
  }

  /* may log to file instead of stdout */
  if (args.logFile) {
    logFile = fopen(args.logFile, "w");
    if (!logFile) {
      usageOptions(&options, "can't open file %s for write.\n", args.logFile);
      exit(1);
    }
  }


  /* consider comments as legal tokens */
  if (inDev)
    OMignoreComment(inDev, OMfalse);
  if (outDev)
    OMignoreComment(outDev, OMfalse);
  if (dupDev)
    OMignoreComment(dupDev, OMfalse);


  /* loop 'till no more token on device */
  while (pipeToken(inDev, outDev, dupDev, logFile, args.verbosity) == OMsuccess);

  return 0;
}
