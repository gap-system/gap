#ifndef __CEXTRACT__
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#endif /* __CEXTRACT__ */

#include "OM.h"

#define TEST_STRING    (1<<0)
#define TEST_WCSTRING  (1<<1)
#define TEST_BYTEARRAY (1<<2)
#define TEST_DOUBLE    (1<<3)

#define TMPFILE "./todel.tenc"
#define MAX_SEQ_STR   256
#define MAX_SEQ_WCSTR 256
#define MAX_SEQ_BA    256
#define MAX_SEQ_DB    3330

#define EQSTRING(s1, s2) (strcmp(s1, s2) == 0)

/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/************************************************************ End Prototypes */
/* end of automaticaly updated part */
static void usage(char *message);
static void fatalError(OMstatus status, char *msg);
/* checkStatus
 *   Check for error reported in status.
 *   If status is not OMsuccess 
 *   then print corresponding error message then exit;
 * status: status to check
 */
static void checkStatus(OMstatus status);
static int wcstrlen(const OMUCS2 * wcstr);
static int wcstrcmp(const OMUCS2 * wcstr1, const OMUCS2 * wcstr2);
static int mixstrcmp(const OMUCS2 * wcstr, char *str);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */


static void
usage(char *message)
{
  char *info;

  if (message) {
    fprintf(stderr, "error: %s\n", message);
  }
  fprintf(stderr, "Tests for OpenMath lib version %s (%s)\n", OMlibVersion, OMlibInfo);
  info = OMlibDynamicInfo();
  fprintf(stderr, "%s", info);
  free(info);
  fprintf(stderr, "tenc -[bt] -[swad]\n");
  fprintf(stderr, "   Test some encode/decode functions,\n");
  fprintf(stderr, "   in binary or text mode depending on option switch -b or -t).\n");
  fprintf(stderr, "   -s for string utf7 encoding.\n");
  fprintf(stderr, "   -w for wide char string utf7 encoding.\n");
  fprintf(stderr, "   -a for byte arrays encoding.\n");
  fprintf(stderr, "   -d for portable double encoding.\n");
  fprintf(stderr, "   Exit status is 0 if test has run smoothly, 1 otherwise.\n");
  exit(1);
}


static void
fatalError(OMstatus status, char *msg)
{
  fprintf(stderr, "Fatal error: %s\n", msg);
  exit(status);
}


/* checkStatus
 *   Check for error reported in status.
 *   If status is not OMsuccess 
 *   then print corresponding error message then exit;
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

static int
wcstrlen(const OMUCS2 * wcstr)
{
  int l = 0;

  while (*wcstr++) {
    l++;
  }
  return l;
}

static int
wcstrcmp(const OMUCS2 * wcstr1, const OMUCS2 * wcstr2)
{
  while ((*wcstr1) == (*wcstr2)) {
    if (!*wcstr1) {
      /* end of string */
      return 0;
    }
    wcstr1++;
    wcstr2++;
  }
  return (*wcstr1) - (*wcstr2);
}

static int
mixstrcmp(const OMUCS2 * wcstr, char *str)
{
  while ((*wcstr) == (OMUCS2) (*str)) {
    if (!*wcstr) {
      /* end of string */
      return 0;
    }
    wcstr++;
    str++;
  }
  return (*wcstr) - (OMUCS2) (*str);
}


OMdev
makeDevIn(OMencodingType encoding)
{
  FILE *f;
  OMdev dev;

  f = fopen(TMPFILE, "r");
  if (f == (FILE *) 0) {
    usage("Unable to open " TMPFILE " file for read...");
  }
  dev = OMmakeDevice(encoding, OMmakeIOFile(f));
  return dev;
}

OMdev
makeDevOut(OMencodingType encoding)
{
  FILE *f;
  OMdev dev;

  f = fopen(TMPFILE, "w");
  if (f == (FILE *) 0) {
    usage("Unable to open " TMPFILE " file for write...");
  }
  dev = OMmakeDevice(encoding, OMmakeIOFile(f));
  return dev;
}


/*
 *                     Test UTf7 encoding for strings
 */

int
OMgenTestSequencesSTR(char **seq)
{
  int i, j, l;

  for (i = 0; i < MAX_SEQ_STR; i++) {
    l = (i + 1) * 7;
    seq[i] = (char *) malloc(l + 1);
    for (j = 0; j < l; j++) {
      seq[i][j] = (char) ((rand() % ('~' - ' ')) + ' ');
    }
    seq[i][j] = '\0';
  }
  return i;
}


void
OMtestSTR(OMencodingType encoding)
{
  OMdev devin, devout;
  char *seq[MAX_SEQ_STR], *rseq[MAX_SEQ_STR];
  OMUCS2 *wcrseq[MAX_SEQ_STR];
  int i, nbSeq;

  /* write a bunch of strings */
  devout = makeDevOut(encoding);
  nbSeq = OMgenTestSequencesSTR(seq);
  checkStatus(OMbeginObject(devout));
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMputString(devout, seq[i]));
  }
  checkStatus(OMendObject(devout));
  OMcloseDevice(devout);

  /* read them back as plain or wide char strings */
  devin = makeDevIn(encoding);
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMgetString(devin, &rseq[i]));
  }
  OMcloseDevice(devin);
  devin = makeDevIn(encoding);
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMgetWCString(devin, &wcrseq[i]));
  }
  OMcloseDevice(devin);

  /* and compare */
  for (i = 0; i < nbSeq; i++) {
    if ((strlen(seq[i]) != strlen(rseq[i]))
	|| strcmp(seq[i], rseq[i])
	|| (strlen(seq[i]) != wcstrlen(wcrseq[i]))
	|| mixstrcmp(wcrseq[i], seq[i])
      ) {
      fprintf(stderr, "Error on sequence %d!\n", i);
      exit(1);
    }
  }

  for (i = 0; i < nbSeq; i++) {
    free(seq[i]);
    free(rseq[i]);
    free(wcrseq[i]);
  }
}


int
OMgenTestSequencesWCSTR(char **seq, OMUCS2 ** wcseq)
{
  int i, j, l;
  OMUCS2 wc;

  for (i = 0; i < MAX_SEQ_WCSTR; i++) {
    l = ((i + 2) * 5) % 600 + 1;
    seq[i] = (char *) malloc((l + 1));
    wcseq[i] = (OMUCS2 *) malloc(2 * (l + 1));
    for (j = 0; j < l; j++) {
      wc = (i << 8) | ((j + 64) & 0xff);
      if (!(char) wc)
	/* avoid null in 8bits strings 
	 * casted from wide ones */
	wc |= 1;
      wcseq[i][j] = wc;
      seq[i][j] = (char) wc;
    }
    wcseq[i][j] = 0;		/* null end 0x0000 */
    seq[i][j] = 0;		/* null end 0x0000 */
  }
  return i;
}

void
OMtestWCSTR(OMencodingType encoding)
{
  OMdev devin, devout;
  OMUCS2 *wcseq[MAX_SEQ_WCSTR], *wcrseq[MAX_SEQ_WCSTR];
  char *seq[MAX_SEQ_WCSTR], *rseq[MAX_SEQ_WCSTR];
  int i, nbSeq;

  /* write a bunch of wide char strings */
  devout = makeDevOut(encoding);
  nbSeq = OMgenTestSequencesWCSTR(seq, wcseq);
  checkStatus(OMbeginObject(devout));
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMputWCString(devout, wcseq[i]));
  }
  checkStatus(OMendObject(devout));
  OMcloseDevice(devout);

  /* read them back as 8bits or 16 bits to check if equals */
  devin = makeDevIn(encoding);
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMgetWCString(devin, &wcrseq[i]));
  }
  OMcloseDevice(devin);
  devin = makeDevIn(encoding);
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMgetString(devin, &rseq[i]));
  }
  OMcloseDevice(devin);

  /* compare put and read versions */
  for (i = 0; i < nbSeq; i++) {
    if ((wcstrlen(wcseq[i]) != wcstrlen(wcrseq[i]))
	|| wcstrcmp(wcrseq[i], wcseq[i])
	|| (strlen(seq[i]) != strlen(rseq[i]))
	|| strcmp(rseq[i], seq[i])) {
      fprintf(stderr, "Error on sequence %d!\n", i);
      exit(1);
    }
  }

  for (i = 0; i < nbSeq; i++) {
    free(seq[i]);
    free(rseq[i]);
    free(wcseq[i]);
    free(wcrseq[i]);
  }
}



/*
 *                   Test UTF7 encoding for byte arrays
 */

int
OMgenTestSequencesBA(char **seq, int *len)
{
  int i = 0, j;

  /* some easy to check arrays */
  for (; i < 4; i++) {
    len[i] = (i + 1) * 5;
    seq[i] = (char *) malloc(len[i]);
    for (j = 0; j < len[i]; j++) {
      seq[i][j] = (char) (j % 256);
    }
  }

  /* more long/random arrays */
  for (; i < MAX_SEQ_BA; i++) {
    len[i] = (i + 1) * 7;
    seq[i] = (char *) malloc(len[i]);
    for (j = 0; j < len[i]; j++) {
      seq[i][j] = (char) ((j + (rand() % 3)) % 256);
    }
  }
  return i;
}


void
OMtestBA(OMencodingType encoding)
{
  OMdev devin, devout;
  char *seq[MAX_SEQ_BA], *rseq[MAX_SEQ_BA];
  int seqLen[MAX_SEQ_BA], rseqLen[MAX_SEQ_BA];
  int i, nbSeq;

  /* write a bunch of byte arrays */
  devout = makeDevOut(encoding);
  nbSeq = OMgenTestSequencesBA(seq, seqLen);
  checkStatus(OMbeginObject(devout));
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMputByteArray(devout, seq[i], seqLen[i]));
  }
  checkStatus(OMendObject(devout));
  OMcloseDevice(devout);


  /* read them back to check if equals */
  devin = makeDevIn(encoding);
  for (i = 0; i < nbSeq; i++) {
    rseqLen[i] = 0;
    checkStatus(OMgetByteArray(devin, &rseq[i], &rseqLen[i]));
    if ((rseqLen[i] != seqLen[i]) ||
	strncmp(rseq[i], seq[i], seqLen[i])) {
      fprintf(stderr, "Error on sequence %d!\n", i);
      exit(1);
    }
  }
  OMcloseDevice(devin);

  for (i = 0; i < nbSeq; i++) {
    free(seq[i]);
    free(rseq[i]);
  }
}



/*
 *              Test machine independant encoding of doubles
 */

int
OMgenTestSequencesDB(double *seq)
{
  int i;
  double d;

  d = 1.2736817264876245683746583465e-307;
  for (i = 0; i < MAX_SEQ_DB; i++) {
    d *= -1.52979828379812739871231131;
    seq[i] = d;
  }
  return i;
}


void
OMtestDB(OMencodingType encoding)
{
  OMdev devin, devout;
  double seq[MAX_SEQ_DB], rseq[MAX_SEQ_DB];
  int i, nbSeq;

  /* write a bunch of doubles */
  devout = makeDevOut(encoding);
  nbSeq = OMgenTestSequencesDB(seq);
  checkStatus(OMbeginObject(devout));
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMputFloat64(devout, &seq[i]));
  }
  checkStatus(OMendObject(devout));
  OMcloseDevice(devout);

  /* read them back to check if equals */
  devin = makeDevIn(encoding);
  for (i = 0; i < nbSeq; i++) {
    checkStatus(OMgetFloat64(devin, &rseq[i]));
    if ((rseq[i] != seq[i])) {
      fprintf(stderr, "Error on sequence %d!\n", i);
      exit(1);
    }
  }
  OMcloseDevice(devin);
}



int
main(int argc, char *argv[])
{
  OMencodingType encoding;
  int test = 0;

  if ((argc == 2) && EQSTRING(argv[1], "-h")) {
    usage(NULL);
  }

  if (argc != 3) {
    usage("Two arguments please...");
  }

  if (argv[1][0] != '-') {
    usage("Need one option -b or -t...");
  }
  switch (argv[1][1]) {
  case 'b':
    encoding = OMencodingBinary;
    break;
    case
  't':
    encoding = OMencodingXML;
    break;
  default:
    usage("Need one of these options: -b or -t ...");
  }

  if (argv[2][0] != '-') {
    usage("Need one type option -s -a -d ...");
  }
  switch (argv[2][1]) {
  case 's':
    test |= TEST_STRING;
    break;
  case 'w':
    test |= TEST_WCSTRING;
    break;
  case 'a':
    test |= TEST_BYTEARRAY;
    break;
  case 'd':
    test |= TEST_DOUBLE;
    break;
  default:
    usage("Need one type option -s -a -d ...");
  }

  if (test & TEST_STRING) {
    OMtestSTR(encoding);
  }
  if (test & TEST_WCSTRING) {
    OMtestWCSTR(encoding);
  }
  if (test & TEST_BYTEARRAY) {
    OMtestBA(encoding);
  }
  if (test & TEST_DOUBLE) {
    OMtestDB(encoding);
  }

  return 0;
}
