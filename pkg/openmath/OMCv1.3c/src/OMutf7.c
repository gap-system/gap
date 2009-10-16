/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/*
 */
static void OMtabInit(void);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */

#define PRINT(Dev,S)       (*(Dev->io->print))(Dev, S)
#define WRITE(Dev,S,N)     (*(Dev->io->write))(Dev, S, N)
#define READ(Dev,Buf,N)    (*(Dev->io->read))(Dev, Buf, N)
#define LOOKAHEAD(Dev)     (*(Dev->io->lookAhead))(Dev)
#define GETCHAR(Dev)       (*(Dev->io->getChar))(Dev)
#define PUTCHAR(Dev,C)     (*(Dev->io->putChar))(Dev,C)
#define STATE(Dev)         ((OMXmlState)Dev->translation->state)
#define CURRENTTYPE(Dev)   (STATE(Dev)->currentType)
#define BUF(Dev)           (STATE(Dev)->buf)
#define BUFUSED(Dev)       (STATE(Dev)->bufUsed)
#define BUFSIZE(Dev)       (STATE(Dev)->bufSize)
#define BUFAUX(Dev)        (STATE(Dev)->bufAux)
#define BUFAUXUSED(Dev)    (STATE(Dev)->bufAuxUsed)
#define BUFAUXSIZE(Dev)    (STATE(Dev)->bufAuxSize)
#if OM_DEBUG
#define LINE(Dev)          (STATE(Dev)->line)
#endif

#define SHIFT_IN '+'
#define SHIFT_OUT '-'
#define DECLARE_BIT_BUFFER unsigned long _bitBuffer = 0, _bufferTmp = 0; int _bufferBits = 0
#define BITS_IN_BUFFER _bufferBits
#define WRITE_N_BITS(B, N) \
((_bitBuffer = (_bitBuffer << (N)) | (B)), \
_bufferBits += (N) )
#define READ_N_BITS(N) \
((_bufferTmp = (_bitBuffer >> (_bufferBits - (N)))), \
(_bitBuffer = _bitBuffer ^ _bufferTmp << (_bufferBits - (N))), \
(_bufferBits -= (N)), _bufferTmp)

#define CHECK_BUF(Dev,I,Buf,Len) \
   if ((I<<1) >= Len) { \
     OMcheckStatus(OMSEreallocBuf(STATE(Dev))); \
     Buf = (OMUCS2*) BUF(Dev); \
     Len = BUFSIZE(Dev) - 1; \
   }


static char OMbase64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static short OMinvBase64[128];

static char OMdirect[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'(),./:?!\"#$%&*;=@[]^_`{|}";
static char OMspaces[] = " \011\015\012";	/* space, tab, return, line feed */
static char OMmustShift[128];

static OMbool OMneedTables = OMtrue;



/*
 */
Module void
OMtabInit(void)
{
  int i, limit;

  for (i = 0; i < 128; ++i) {
    OMmustShift[i] = 1;
    OMinvBase64[i] = -1;
  }
  limit = strlen(OMdirect);
  for (i = 0; i < limit; ++i)
    OMmustShift[(int) OMdirect[i]] = 0;
  limit = strlen(OMspaces);
  for (i = 0; i < limit; ++i)
    OMmustShift[(int) OMspaces[i]] = 0;
  limit = strlen(OMbase64);
  for (i = 0; i < limit; ++i)
    OMinvBase64[(int) OMbase64[i]] = i;

  OMneedTables = OMfalse;
}



Lib OMstatus
OMputUCS2AsUTF7(OMdev dev, OMUCS2 * source, int len)
{
  DECLARE_BIT_BUFFER;
  OMstatus result = OMsuccess;
  OMUCS2 *sourceEnd = source + len;
  OMUCS2 r;
  int shifted = 0, needShift = 0, done = 0;

  if (OMneedTables)
    OMtabInit();

  do {
    if (!(done = (source >= sourceEnd)))
      r = *source++;
    needShift = (!done && ((r > 0x7f) || (OMmustShift[(int) r])));

    if (needShift && !shifted) {
      OMcheckStatus(PUTCHAR(dev, SHIFT_IN));
      /* Special case handling of the SHIFT_IN character */
      if (r == SHIFT_IN) {
	OMcheckStatus(PUTCHAR(dev, SHIFT_OUT));
      }
      else {
	shifted = 1;
      }
    }

    if (shifted) {
      /* Either write the character to the bit buffer, or pad
       * the bit buffer out to a full base64 character.
       */
      if (needShift)
	WRITE_N_BITS(r, 16);
      else
	WRITE_N_BITS(0, (6 - (BITS_IN_BUFFER % 6)) % 6);

      /* Flush out as many full base64 characters as possible
       * from the bit buffer.
       */
      while (BITS_IN_BUFFER >= 6) {
	OMcheckStatus(PUTCHAR(dev, OMbase64[READ_N_BITS(6)]));
      }

      if (!needShift) {
	/* Write the explicit shift out character if
	 */
	if (((!done) && OMinvBase64[(int) r] >= 0)) {
	  OMcheckStatus(PUTCHAR(dev, SHIFT_OUT));
	}
	shifted = 0;
      }
    }

    /* The character can be directly encoded as ASCII. */
    if (!needShift && !done) {
      OMcheckStatus(PUTCHAR(dev, (char) r));
    }

  }
  while (!done);

  return result;
}

Lib OMstatus
OMputCharAsUTF7(OMdev dev, char *source, int len)
{
  DECLARE_BIT_BUFFER;
  char *sourceEnd = source + len;
  unsigned char r, c;
  int shifted = 0, needShift = 0, done = 0;

  if (OMneedTables)
    OMtabInit();

  do {
    if (!(done = (source >= sourceEnd)))
      r = *source++;
    needShift = (!done && ((r > 0x7f) || (OMmustShift[(int) r])));

    if (needShift && !shifted) {
      OMcheckStatus(PUTCHAR(dev, SHIFT_IN));
      /* Special case handling of the SHIFT_IN character */
      if (r == SHIFT_IN) {
	OMcheckStatus(PUTCHAR(dev, SHIFT_OUT));
      }
      else {
	shifted = 1;
      }
    }

    if (shifted) {
      /* Either write the character to the bit buffer, or pad
       * the bit buffer out to a full base64 character.
       */
      if (needShift)
	WRITE_N_BITS((OMUCS2) r, 16);
      else
	WRITE_N_BITS(0, (6 - (BITS_IN_BUFFER % 6)) % 6);

      /* Flush out as many full base64 characters as possible
       * from the bit buffer.
       */
      while (BITS_IN_BUFFER >= 6) {
	c = (unsigned char) READ_N_BITS(6);
	OMcheckStatus(PUTCHAR(dev, OMbase64[c]));
      }

      if (!needShift) {
	/* Write the explicit shift out character if
	 * the directly encoded character is in the
	 * base64 set.
	 */
	if (((!done) && OMinvBase64[(int) r] >= 0)) {
	  OMcheckStatus(PUTCHAR(dev, SHIFT_OUT));
	}
	shifted = 0;
      }
    }

    /* The character can be directly encoded as ASCII. */
    if (!needShift && !done) {
      OMcheckStatus(PUTCHAR(dev, r));
    }
  }
  while (!done);

  return OMsuccess;
}


Lib OMstatus
OMparseUCS2FromUTF7(OMdev dev)
{
  DECLARE_BIT_BUFFER;
  OMstatus result = OMsuccess;
  OMbool done = OMfalse;
  int shifted = 0, first = 0, wroteone = 0, base64EOF, base64value;
  int inByteNb = 0, outWCNb = 0, len;
  unsigned int c, prevc;
  unsigned long junk;
  OMUCS2 *buf;

  if (OMneedTables)
    OMtabInit();

  buf = (OMUCS2 *) BUF(dev);
  len = BUFSIZE(dev) - 1;

  while (!done) {
    /* read an ASCII character c */
    c = LOOKAHEAD(dev);
    if (c == '<') {
      done = OMtrue;
    }
    else {
      c = GETCHAR(dev);
      inByteNb++;
    }

    if (shifted) {
      /* We're done with a base64 string if we hit EOF, it's not a valid
       * ASCII character, or it's not in the base64 set.
       */
      base64EOF = done || (c > 0x7f) || ((base64value = OMinvBase64[c]) < 0);
      if (base64EOF) {
	shifted = 0;
	/* If the character causing us to drop out was SHIFT_IN or
	 * SHIFT_OUT, it may be a special escape for SHIFT_IN. The
	 * test for SHIFT_IN is not necessary, but allows an alternate
	 * form of UTF-7 where SHIFT_IN is escaped by SHIFT_IN. This
	 * only works for some values of SHIFT_IN.
	 */
	if (!done && (c == SHIFT_IN || c == SHIFT_OUT)) {
	  /* get another character c */
	  prevc = c;
	  c = LOOKAHEAD(dev);
	  if (c == '<') {
	    done = OMtrue;
	  }
	  else {
	    c = GETCHAR(dev);
	    inByteNb++;
	  }

	  /* If no base64 characters were encountered, and the
	   * character terminating the shift sequence was
	   * SHIFT_OUT, then it's a special escape for SHIFT_IN.
	   */
	  if (first && prevc == SHIFT_OUT) {
	    /* write SHIFT_IN unicode */
	    CHECK_BUF(dev, outWCNb, buf, len);
	    buf[outWCNb] = (OMUCS2) SHIFT_IN;
	    outWCNb++;
	  }
	  else if (!wroteone) {
	    result = OMmalformedInput;
#if OM_DEBUG
	    OMprintf(OMwarnLevel, "utf7: Found empty sequence near byte %d in input.\n", inByteNb);
#endif
	  }
	}
	else if (!wroteone) {
	  result = OMmalformedInput;
#if OM_DEBUG
	  OMprintf(OMwarnLevel, "utf7: Found empty sequence near byte %d in input.\n", inByteNb);
#endif
	}
      }
      else {
	/* Add another 6 bits of base64 to the bit buffer. */
	WRITE_N_BITS(base64value, 6);
	first = 0;
      }

      /* Extract as many full 16 bit characters as possible from the
         bit buffer.
       */
      while (BITS_IN_BUFFER >= 16) {
	/* write a unicode */
	CHECK_BUF(dev, outWCNb, buf, len);
	buf[outWCNb] = (OMUCS2) READ_N_BITS(16);
	outWCNb++;
	wroteone = 1;
      }

      if (base64EOF) {
	junk = READ_N_BITS(BITS_IN_BUFFER);
	if (junk) {
	  result = OMmalformedInput;
#if OM_DEBUG
	  OMprintf(OMwarnLevel, "utf7: Found non-zero pad bits near byte %d in input.\n", inByteNb);
#endif
	}
      }
    }

    if (!shifted && !done) {
      if (c == SHIFT_IN) {
	shifted = 1;
	first = 1;
	wroteone = 0;
      }
      else {
	/* It must be a directly encoded character. */
	if (c > 0x7f) {
	  result = OMmalformedInput;
#if OM_DEBUG
	  OMprintf(OMwarnLevel, "utf7: Found non-ASCII character near byte %d in input.\n", inByteNb);
#endif
	}
	/* write a unicode */
	CHECK_BUF(dev, outWCNb, buf, len);
	buf[outWCNb] = c;
	outWCNb++;
      }
    }
  }
  CHECK_BUF(dev, outWCNb + 1, buf, len);
  /* put the trailing unicode null 0000 */
  buf[outWCNb] = 0;
  BUFUSED(dev) = outWCNb * 2;

  return result;
}
