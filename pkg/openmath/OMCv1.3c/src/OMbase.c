/***********************************************************************/
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  Automatique.  Distributed only by permission.                      */
/***********************************************************************/

#include "OMP.h"


/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

static char OMbasis64Digit(int c);
/*
 */
static void OMoutput64chunk(int c1, int c2, int c3, int pads, char *buffer);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */


/* convert a decimal 0-15 into an ascii char used as a base 16 digit */
static const char OMbasis16[] = "0123456789abcdef";



/* convert a decimal 0-63 into an ascii char used as a base 64 digit (eg: for bytearrays encoding) */
static const char OMbasis64Digits[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/* reverse conversion. */
static const char OMindex64[128] =
{
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62 /* 43 + */ , -1, -1, -1, 63 /* 47 / */ ,
  52 /* 48 0 */ , 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, 0 /* 61 = */ , -1, -1,
  -1, /* 65 A */ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
  -1, /* 97 a */ 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51 /* 90 */ , -1, -1, -1, -1, -1
};

#define OMchar64(C)  (((C) < '+' || (C) > 'z') ? -1 : OMindex64[(C)])

Lib int
OMIsB64Char(char c)
{
  return (OMchar64(c) >= 0) ? 1 : 0;
}

Module char
OMbasis64Digit(int c)
{
  OMassert(c >= 0 && c < 64);
  return OMbasis64Digits[c];
}

/*
 */
Module void
OMoutput64chunk(int c1, int c2, int c3, int pads, char *buffer)
{
  OMassert(buffer);

  *(buffer++) = OMbasis64Digit(c1 >> 2);
  *(buffer++) = OMbasis64Digit(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4));
  if (pads == 2) {
    *(buffer++) = '=';
    *(buffer++) = '=';
  }
  else if (pads) {
    *(buffer++) = OMbasis64Digit(((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6));
    *(buffer++) = '=';
  }
  else {
    *(buffer++) = OMbasis64Digit(((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6));
    *(buffer++) = OMbasis64Digit(c3 & 0x3F);
  }
}


/*
 */
Lib int
OMto64(unsigned char *data, int len, char *buffer)
{
  int in = 0;
  char *out = buffer;

  OMassert(data);
  OMassert(buffer);
  OMassert(len >= 0);

  /* put all well formed 3-byte chuncks */
  while (in < len - 2) {
    OMoutput64chunk(data[in], data[in + 1], data[in + 2], 0, out);
    out += 4;
    in += 3;
  }
  /* put tail (1 or 2 remaining bytes) */
  switch (len - in) {
  case 0:
    break;
  case 1:
    OMoutput64chunk(data[in], 0, 0, 2, out);
    out += 4;
    break;
  case 2:
    OMoutput64chunk(data[in], data[in + 1], 0, 1, out);
    out += 4;
    break;
  }
  *out = '\0';
  return out - buffer;
}


/*
 */
Lib OMstatus
OMfrom64(char *data, int len, unsigned char *buffer, int *bufLen)
{
  int c1, c2, c3, c4;

  OMassert(data);
  OMassert(buffer);
  OMassert(len >= 0);
  OMassert(bufLen);

  *bufLen = 0;
  while (len > 0) {
    c1 = data[0];
    if ((c1 == '\n') || (c1 == ' ') || (c1 == '\t')) {
      data++;
      len--;
      continue;
    }
    c2 = data[1];
    c3 = data[2];
    c4 = data[3];
    len -= 4;
    data += 4;
    if ((c1 == '=') || (c2 == '=')) {
      break;
    }

#if OM_DEBUG
    if (OMchar64(c1) == -1) {
      OMprintf(OMwarnLevel, "Found illegal character '%c' in base 64 encoding.\n", c1);
      return OMmalformedInput;
    }
    if (OMchar64(c2) == -1) {
      OMprintf(OMwarnLevel, "Found illegal character '%c' in base 64 encoding.\n", c2);
      return OMmalformedInput;
    }
    if (OMchar64(c3) == -1) {
      OMprintf(OMwarnLevel, "Found illegal character '%c' in base 64 encoding.\n", c3);
      return OMmalformedInput;
    }
#endif

    c1 = OMchar64(c1);
    c2 = OMchar64(c2);
    buffer[(*bufLen)++] = (c1 << 2) | ((c2 & 0x30) >> 4);
    if (c3 == '=') {
      break;
    }
    c3 = OMchar64(c3);
    buffer[(*bufLen)++] = ((c2 & 0XF) << 4) | ((c3 & 0x3C) >> 2);
    if (c4 == '=') {
      break;
    }
    c4 = OMchar64(c4);
    buffer[(*bufLen)++] = ((c3 & 0x03) << 6) | c4;
  }
  return OMsuccess;
}


/*
 */
Lib void
OMto16(char *data, int len, char *buffer)
{
  int i;
  char *out = buffer;

  OMassert(data);
  OMassert(buffer);
  OMassert(len >= 0);

  for (i = 0; i < len; i++) {
    *out = OMbasis16[(data[i] & 0xF0) >> 4];
    out++;
    *out = OMbasis16[(data[i] & 0x0F)];
    out++;
  }
}


/*
 */
Lib OMstatus
OMfrom16(char *data, int len, char *buffer)
{
  int i;
  char *out = buffer, c;
  OMbool low = OMfalse;

  OMassert(data);
  OMassert(buffer);
  OMassert(len >= 0);
  OMassert(((len >> 1) << 1) == len);	/* check if len is even */

  for (i = 0; i < len; i++) {
    c = tolower(data[i]);

#if OM_DEBUG
    if (!(((c >= '0') && (c <= '9')) ||
	  ((c >= 'a') && (c <= 'f')))) {
      OMprintf(OMwarnLevel, "Found illegal character '%c'(%d) in base 16 encoding.\n", data[i], data[i]);
      return OMmalformedInput;
    }
#endif

    /* assume c is a base 16 char */
    if (c <= '9') {
      c -= '0';
    }
    else {
      c = c - ('a' - 10);
    }

    /* is this digit a low or a high nibble for byte *out? */
    if (low) {
      *out += c;
      out++;
      low = OMfalse;
    }
    else {
      *out = c << 4;
      low = OMtrue;
    }
  }
  return OMsuccess;
}
