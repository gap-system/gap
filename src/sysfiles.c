/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file implements operating system dependent functions dealing with
**  file and stream operations.
*/

// ensure we can access large files
#define _FILE_OFFSET_BITS 64

#include "sysfiles.h"

#include "bool.h"
#include "calls.h"
#include "error.h"
#include "gapstate.h"
#include "gaputils.h"
#include "gvars.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "precord.h"
#include "read.h"
#include "records.h"
#include "stats.h"
#include "stringobj.h"
#include "sysenv.h"
#include "sysopt.h"
#include "sysstr.h"
#include "system.h"

#include "hpc/thread.h"

#include "config.h"

#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/types.h>
#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#ifdef HAVE_SELECT
/* Only for the Hook handler calls: */
#include <sys/time.h>
#endif

#ifdef HAVE_SIGNAL_H                       /* signal handling functions       */
#include <signal.h>
typedef void sig_handler_t ( int );
#endif

#ifdef HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>                  /* for TIOCGWINSZ */
#endif

#ifdef SYS_IS_CYGWIN32
#include <process.h>
#endif

#ifdef HAVE_LIBREADLINE
// the following two definitions silence some compiler warnings in the
// readline headers; the first one suppresses the definition of a few
// deprecated (!) and unused typedefs; the second indicates that stdarg.h is
// available (since compiling GAP requires C99, this is guaranteed)
#define _FUNCTION_DEF
#define HAVE_STDARG_H
#include <readline/readline.h>
#endif

#include <zlib.h>

#include <sys/utsname.h>


/****************************************************************************
**
*V  syBuf . . . . . . . . . . . . . .  buffer and other info for files, local
**
**  'syBuf' is an array used as  buffers for  file I/O to   prevent the C I/O
**  routines  from   allocating their  buffers  using  'malloc',  which would
**  otherwise confuse Gasman.
**
**
**  Actually these days SyBuf just stores various file info. SyBuffers
**  stores buffers for the relatively few files that need them.
*/

// The type of file stored in a 'SYS_SY_BUF'
typedef enum {
    unused_socket,    // Socket is free
    raw_socket,       // Plain UNIX socket stored in 'fp'
    gzip_socket       // A gzFile handled by zlib stored in 'gzfp'
} GAPSocketType;

GAP_STATIC_ASSERT(unused_socket == 0, "unused_socket must be zero");

typedef struct {
    // gzfp is used if type == gzip_socket
    gzFile gzfp;

    // file descriptor for this file (only used if type == raw_socket)
    int fp;

    // file descriptor for the echo (only used if type == raw_socket)
    int echo;

    // file is either a plain descriptor, pipe or gzipped
    GAPSocketType type;

    // set to 1 by any read operation that hits eof; reset to 0 by a
    // subsequent successful read
    BOOL ateof;

    // records that last character read was \r for cygwin and other systems
    // that need end-of-line hackery
    BOOL crlast;

    // if non-negative then this file has a buffer in syBuffers[bufno]; if
    // negative, this file may not be buffered
    int bufno;

    // set when this fid is a *stdin* or *errin* and really is a tty
    BOOL isTTY;
} SYS_SY_BUF;

#define SYS_FILE_BUF_SIZE 20000

typedef struct {
    Char buf[SYS_FILE_BUF_SIZE];
    BOOL inuse;
    UInt bufstart;
    UInt buflen;
} SYS_SY_BUFFER;

static SYS_SY_BUF syBuf[256];

static SYS_SY_BUFFER syBuffers[32];


/* utility to check return value of 'write'  */
static ssize_t echoandcheck(int fid, const char *buf, size_t count)
{
  int ret;
  if (syBuf[fid].type == gzip_socket) {
      ret = gzwrite(syBuf[fid].gzfp, buf, count);
      if (ret < 0) {
          ErrorQuit(
              "Could not write to compressed file, see 'LastSystemError();'\n",
              0, 0);
      }
  }
  else {
      ret = write(syBuf[fid].echo, buf, count);
      if (ret < 0) {
          if (syBuf[fid].echo == fileno(stdout)) {
              Panic("Could not write to stdout: %s (errno %d, fid %d)",
                    strerror(errno), errno, fid);
          }
          else if (syBuf[fid].echo == fileno(stderr)) {
              Panic("Could not write to stderr: %s (errno %d, fid %d)",
                    strerror(errno), errno, fid);
          }
          else {
              ErrorQuit("Could not write to file descriptor %d (fid %d), see "
                        "'LastSystemError();'\n",
                        syBuf[fid].echo, fid);
          }
      }
  }
  return ret;
}


/****************************************************************************
**
*F  SyGAPCRC( <name> )  . . . . . . . . . . . . . . . . . . crc of a GAP file
**
**  This function should  be clever and handle  white spaces and comments but
**  one has to make certain that such characters are not ignored in strings.
**
**  This function *never* returns a 0 unless an error occurred.
*/
static const UInt4 syCcitt32[ 256 ] =
{
0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L, 0xe0d5e91eL,
0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L, 0x90bf1d91L, 0x1db71064L,
0x6ab020f2L, 0xf3b97148L, 0x84be41deL, 0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L,
0x83d385c7L, 0x136c9856L, 0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL,
0x63066cd9L, 0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL, 0x35b5a8faL,
0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L, 0x45df5c75L, 0xdcd60dcfL,
0xabd13d59L, 0x26d930acL, 0x51de003aL, 0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L,
0x56b3c423L, 0xcfba9599L, 0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L,
0xb10be924L, 0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL, 0x9fbfe4a5L,
0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL, 0xe10e9818L, 0x7f6a0dbbL,
0x086d3d2dL, 0x91646c97L, 0xe6635c01L, 0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L,
0xf262004eL, 0x6c0695edL, 0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L,
0x12b7e950L, 0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L, 0x4adfa541L,
0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL, 0x346ed9fcL, 0xad678846L,
0xda60b8d0L, 0x44042d73L, 0x33031de5L, 0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL,
0x270241aaL, 0xbe0b1010L, 0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L,
0xce61e49fL, 0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L, 0x03b6e20cL,
0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L, 0x73dc1683L, 0xe3630b12L,
0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L, 0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L,
0x7d079eb1L, 0xf00f9344L, 0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL,
0x806567cbL, 0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L, 0xd6d6a3e8L,
0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L, 0xa6bc5767L, 0x3fb506ddL,
0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL, 0x36034af6L, 0x41047a60L, 0xdf60efc3L,
0xa867df55L, 0x316e8eefL, 0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L,
0x5268e236L, 0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L, 0x2cd99e8bL,
0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL, 0x026d930aL, 0x9c0906a9L,
0xeb0e363fL, 0x72076785L, 0x05005713L, 0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL,
0x0cb61b38L, 0x92d28e9bL, 0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L,
0xf1d4e242L, 0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL, 0x8f659effL,
0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L, 0xd70dd2eeL, 0x4e048354L,
0x3903b3c2L, 0xa7672661L, 0xd06016f7L, 0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL,
0xd9d65adcL, 0x40df0b66L, 0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL,
0x30b5ffe9L, 0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L, 0x5d681b02L,
0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL, 0x2d02ef8dL
};

Int4 SyGAPCRC( const Char * name )
{
    UInt4       crc;
    UInt4       old;
    UInt4       new;
    Int4        ch;
    Int         fid;
    Int         seen_nl;

    /* the CRC of a non existing file is 0                                 */
    fid = SyFopen(name, "r", TRUE);
    if ( fid == -1 ) {
        return 0;
    }

    /* read in the file byte by byte and compute the CRC                   */
    crc = 0x12345678L;
    seen_nl = 0;

    while ( (ch = SyGetch(fid) )!= EOF ) {
        if ( ch == '\377' || ch == '\n' || ch == '\r' )
            ch = '\n';
        if ( ch == '\n' ) {
            if ( seen_nl )
                continue;
            else
                seen_nl = 1;
        }
        else
            seen_nl = 0;
        old = (crc >> 8) & 0x00FFFFFFL;
        new = syCcitt32[ ( (UInt4)( crc ^ ch ) ) & 0xff ];
        crc = old ^ new;
    }
    if ( crc == 0 ) {
        crc = 1;
    }

    /* and close it again                                                  */
    SyFclose( fid );
    /* Emulate a signed shift: */
    if (crc & 0x80000000L)
        return (Int4) ((crc >> 4) | 0xF0000000L);
    else
        return (Int4) (crc >> 4);
}


/*
<#GAPDoc Label="CrcString">
<ManSection>
<Func Name="CrcString" Arg='str'/>
<Returns>an integer</Returns>

<Description>
This function computes a cyclic redundancy check number from a string
<A>str</A>. See also <Ref Func="CrcFile"/>.
<Example>
gap> CrcString("GAP example string");
-50451670
</Example>
</Description>
</ManSection>

<#/GAPDoc>
*/

/* And here we include a variant working on a GAP string */
static Obj FuncCrcString(Obj self, Obj str)
{
    UInt4       crc;
    UInt4       old;
    UInt4       new;
    UInt4       i, len;
    const Char  *ptr;
    Int4        ch;
    Int         seen_nl;

    RequireStringRep(SELF_NAME, str);

    ptr = CONST_CSTR_STRING(str);
    len = GET_LEN_STRING(str);
    crc = 0x12345678L;
    seen_nl = 0;
    for (i = 0; i < len; i++) {
        ch = (Int4)(ptr[i]);
        if ( ch == '\377' || ch == '\n' || ch == '\r' )
            ch = '\n';
        if ( ch == '\n' ) {
            if ( seen_nl )
                continue;
            else
                seen_nl = 1;
        }
        else
            seen_nl = 0;
        old = (crc >> 8) & 0x00FFFFFFL;
        new = syCcitt32[ ( (UInt4)( crc ^ ch ) ) & 0xff ];
        crc = old ^ new;
    }
    if ( crc == 0 ) {
        crc = 1;
    }
    return INTOBJ_INT(((Int4) crc) >> 4);
}

// Get OS Kernel version. Used to discover if GAP is running inside
// 'Windows Subystem for Linux'
Obj SyGetOsRelease(void)
{
    Obj            r = NEW_PREC(0);
    struct utsname buf;
    if (!uname(&buf)) {
        AssPRec(r, RNamName("sysname"), MakeImmString(buf.sysname));
        AssPRec(r, RNamName("nodename"), MakeImmString(buf.nodename));
        AssPRec(r, RNamName("release"), MakeImmString(buf.release));
        AssPRec(r, RNamName("version"), MakeImmString(buf.version));
        AssPRec(r, RNamName("machine"), MakeImmString(buf.machine));
    }

    return r;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * * * window handler * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  IS_SEP( <C> ) . . . . . . . . . . . . . . . . . . . .  is <C> a separator
*/
#define IS_SEP(C)       (!IsAlpha(C) && !IsDigit(C) && (C)!='_')


/****************************************************************************
**
*F  CTR( <V> )  . . . . . . . . . . . . . . . .  convert <V> into control-<V>
*/
#define CTR(C)          ((C) & 0x1F)    /* <ctr> character                 */


/****************************************************************************
**
*F  Esc( <V> )  . . . . . . . . . . . . . . . . . convert <V> into escape-<V>
*/
#define Esc(C)          ((C) | 0x100)   /* <esc> character                 */


/****************************************************************************
**
*F  CTV( <V> )  . . . . . . . . . . . . . . . . .  convert <V> into quote <V>
*/
#define CTV(C)          ((C) | 0x200)   /* <ctr>V quotes characters        */


/****************************************************************************
**
*F  syWinPut( <fid>, <cmd>, <str> ) . . . . send a line to the window handler
**
**  'syWinPut'  send the command   <cmd> and the  string  <str> to the window
**  handler associated with the  file identifier <fid>.   In the string <str>
**  '@'  characters are duplicated, and   control characters are converted to
**  '@<chr>', e.g., <newline> is converted to '@J'.
*/
void syWinPut (
    Int                 fid,
    const Char *        cmd,
    const Char *        str )
{
    Char                tmp [130];      /* temporary buffer                */
    const Char *        s;              /* pointer into the string         */
    Char *              t;              /* pointer into the temporary      */

    /* if not running under a window handler, don't do anything            */
    if (!SyWindow || 4 <= fid || syBuf[fid].type == gzip_socket)
        return;

    /* print the cmd                                                       */
    echoandcheck( fid, cmd, strlen(cmd) );

    /* print the output line, duplicate '@' and handle <ctr>-<chr>         */
    s = str;  t = tmp;
    while ( *s != '\0' ) {
        if ( *s == '@' ) {
            *t++ = '@';  *t++ = *s++;
        }
        else if ( CTR('A') <= *s && *s <= CTR('Z') ) {
            *t++ = '@';  *t++ = *s++ - CTR('A') + 'A';
        }
        else {
            *t++ = *s++;
        }
        if ( 128 <= t-tmp ) {
            echoandcheck( fid, tmp, t-tmp );
            t = tmp;
        }
    }
    if ( 0 < t-tmp ) {
        echoandcheck( fid, tmp, t-tmp );
    }
}


/****************************************************************************
**
*F  SyWinCmd( <str>, <len> )  . . . . . . . . . . . . .  execute a window cmd
**
**  'SyWinCmd' send   the  command <str> to  the   window  handler (<len>  is
**  ignored).  In the string <str> '@' characters are duplicated, and control
**  characters  are converted to  '@<chr>', e.g.,  <newline> is converted  to
**  '@J'.  Then  'SyWinCmd' waits for  the window handlers answer and returns
**  that string.
*/
static Char WinCmdBuffer[8000];

const Char * SyWinCmd (
    const Char *        str,
    UInt                len )
{
    Char                buf [130];      /* temporary buffer                */
    const Char *        s;              /* pointer into the string         */
    const Char *        bb;             /* pointer into the temporary      */
    Char *              b;              /* pointer into the temporary      */
    UInt                i;              /* loop variable                   */
#ifdef SYS_IS_CYGWIN32
    UInt                len1;           /* temporary storage for len       */
#endif

    /* if not running under a window handler, don't do nothing             */
    if ( ! SyWindow )
        return "I1+S52+No Window Handler Present";

    /* compute the length of the (expanded) string (and ignore argument)   */
    len = 0;
    for ( s = str; *s != '\0'; s++ )
        len += 1 + (*s == '@' || (CTR('A') <= *s && *s <= CTR('Z')));

    /* send the length to the window handler                               */
    b = buf;
    for ( ; 0 < len;  len /= 10 ) {
        *b++ = (len % 10) + '0';
    }
    *b++ = '+';
    *b++ = '\0';
    syWinPut( 1, "@w", buf );

    /* send the string to the window handler                               */
    syWinPut( 1, "", str );

    /* read the length of the answer                                       */
    b = WinCmdBuffer;
    i = 3;
    while ( 0 < i ) {
        len = read( 0, b, i );
        i  -= len;
        b  += len;
    }
    if ( WinCmdBuffer[0] != '@' || WinCmdBuffer[1] != 'a' )
        return "I1+S41+Illegal Answer";
    b = WinCmdBuffer+2;
    for ( i=1,len=0; '0' <= *b && *b <= '9';  i *= 10 ) {
        len += (*b-'0')*i;
        while ( read( 0, b, 1 ) != 1 )  ;
    }

    /* read the arguments of the answer                                    */
    b = WinCmdBuffer;
    i = len;
#ifdef SYS_IS_CYGWIN32
    len1 = len;
    while ( 0 < i ) {
        len = read( 0, b, i );
        b += len;
        i  -= len;
        s  += len;
    }
    len = len1;
#else
    while ( 0 < i ) {
        len = read( 0, b, i );
        i  -= len;
        s  += len;
    }
#endif

    /* shrink '@@' into '@'                                                */
    for ( bb = b = WinCmdBuffer;  0 < len;  len-- ) {
        if ( *bb == '@' ) {
            bb++;
            if ( *bb == '@' )
                *b++ = '@';
            else if ( 'A' <= *bb && *bb <= 'Z' )
                *b++ = CTR(*bb);
            bb++;
        }
        else {
            *b++ = *bb++;
        }
    }
    *b = 0;

    /* return the string                                                   */
    return WinCmdBuffer;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * * open/close * * * * * * * * * * * * * * * *
*/


// Mark a member of syBuf as unused
static void SyBufMarkUnused(Int i)
{
    GAP_ASSERT(i >= 0 && i < ARRAY_SIZE(syBuf));
    memset(&(syBuf[i]), 0, sizeof(syBuf[i]));
    syBuf[i].type = unused_socket;
}

// There is no explicit method to mark syBufs as used,
// they are marked as used when created.

// Check if a member of syBuf is in use
static Int SyBufInUse(Int i)
{
    if (i >= 0 && i < ARRAY_SIZE(syBuf))
        return syBuf[i].type != unused_socket;
    return 0;
}

void SyRedirectStderrToStdOut(void)
{
    syBuf[2].fp = syBuf[0].fp;
    syBuf[2].echo = syBuf[0].echo;
    syBuf[2].isTTY = syBuf[0].isTTY;
    syBuf[3].fp = syBuf[1].fp;
    syBuf[3].echo = syBuf[1].echo;
}

/****************************************************************************
**
*F  SyBufFileno( <fid> ) . . . . . . . . . . . .  get operating system fileno
**
**  Given a 'syBuf' buffer id, return the associated file descriptor, if any.
**  For gzipped files, -1 is returned.
*/
int SyBufFileno(Int fid)
{
    if (fid == -1)
        return -1;
    GAP_ASSERT(0 <= fid && fid < ARRAY_SIZE(syBuf));

    // fp is only valid in the raw case
    return (syBuf[fid].type == raw_socket) ? syBuf[fid].fp : -1;
}

BOOL SyBufIsTTY(Int fid)
{
    GAP_ASSERT(0 <= fid && fid < ARRAY_SIZE(syBuf));
    return syBuf[fid].isTTY;
}

void SyBufSetEOF(Int fid)
{
    GAP_ASSERT(0 <= fid && fid < ARRAY_SIZE(syBuf));
    syBuf[fid].ateof = TRUE;
}


/****************************************************************************
**
*F  SyFopen( <name>, <mode>, <transparent_compress> )
*F                                             open the file with name <name>
**
**  The function 'SyFopen'  is called to open the file with the name  <name>.
**  If <mode> is "r" it is opened for reading, in this case  it  must  exist.
**  If <mode> is "w" it is opened for writing, it is created  if  necessary.
**  If <mode> is "a" it is opened for appending, i.e., it is  not  truncated.
**
**  'SyFopen' returns an integer used by the scanner to  identify  the  file.
**  'SyFopen' returns -1 if it cannot open the file.
**
**  The following standard files names and file identifiers  are  guaranteed:
**  'SyFopen( "*stdin*", "r", ..)' returns 0, the standard input file.
**  'SyFopen( "*stdout*","w", ..)' returns 1, the standard outpt file.
**  'SyFopen( "*errin*", "r", ..)' returns 2, the brk loop input file.
**  'SyFopen( "*errout*","w", ..)' returns 3, the error messages file.
**
**  If it is necessary  to adjust the filename  this should be done here, the
**  filename convention used in GAP is that '/' is the directory separator.
**
**  Right now GAP does not read nonascii files, but if this changes sometimes
**  'SyFopen' must adjust the mode argument to open the file in binary mode.
**
**  If <transparent_compress> is TRUE, files with names ending '.gz' will be
**  automatically compressed/decompressed using gzip.
*/

Int SyFopen(const Char * name, const Char * mode, BOOL transparent_compress)
{
    Int                 fid;
    Char                namegz [1024];
    int                 flags = 0;

    Char * terminator = strrchr(name, '.');
    BOOL   endsgz = terminator && (streq(terminator, ".gz"));

    /* handle standard files                                               */
    if (streq(name, "*stdin*")) {
        return streq(mode, "r") ? 0 : -1;
    }
    else if (streq(name, "*stdout*")) {
        return streq(mode, "w") || streq(mode, "a") ? 1 : -1;
    }
    else if (streq(name, "*errin*")) {
        return (streq(mode, "r") && SyBufInUse(2)) ? 2 : -1;
    }
    else if (streq(name, "*errout*")) {
        return streq(mode, "w") || streq(mode, "a") ? 3 : -1;
    }

    HashLock(&syBuf);
    /* try to find an unused file identifier                               */
    for ( fid = 4; fid < ARRAY_SIZE(syBuf); ++fid )
        if ( !SyBufInUse(fid) )
          break;

    if ( fid == ARRAY_SIZE(syBuf) ) {
        HashUnlock(&syBuf);
        return (Int)-1;
    }

    // set up <namegz>
    gap_strlcpy(namegz, name, sizeof(namegz));
    if (gap_strlcat(namegz, ".gz", sizeof(namegz)) >= sizeof(namegz)) {
        // buffer was not big enough, give up
        namegz[0] = '\0';
    }
    if (*mode == 'r')
        flags = O_RDONLY;
    else if (*mode == 'w')
        flags = O_WRONLY | O_CREAT | O_TRUNC;
    else if (*mode == 'a')
        flags = O_WRONLY | O_APPEND | O_CREAT;
    else {
        Panic("Unknown mode %s", mode);
    }

#ifdef SYS_IS_CYGWIN32
    if (strlen(mode) >= 2 && mode[1] == 'b')
        flags |= O_BINARY;
#endif

    /* try to open the file                                                */
    if (endsgz && transparent_compress &&
        (syBuf[fid].gzfp = gzopen(name, mode))) {
        syBuf[fid].type = gzip_socket;
        syBuf[fid].fp = -1;
        syBuf[fid].bufno = -1;
    }
    else if (0 <= (syBuf[fid].fp = open(name, flags, 0644))) {
        syBuf[fid].type = raw_socket;
        syBuf[fid].echo = syBuf[fid].fp;
        syBuf[fid].bufno = -1;
    }
    else if (*mode == 'r' && transparent_compress &&
             SyIsReadableFile(namegz) == 0 &&
             (syBuf[fid].gzfp = gzopen(namegz, mode))) {
        syBuf[fid].type = gzip_socket;
        syBuf[fid].fp = -1;
        syBuf[fid].bufno = -1;
    }
    else {
        HashUnlock(&syBuf);
        return (Int)-1;
    }

    HashUnlock(&syBuf);

    if (*mode == 'r')
        SySetBuffering(fid);

    /* return file identifier                                              */
    return fid;
}

// Lock on SyBuf for both SyBuf and SyBuffers

UInt SySetBuffering( UInt fid )
{
  UInt bufno;

  if (!SyBufInUse(fid))
    ErrorQuit("Can't set buffering for a closed stream", 0, 0);
  if (syBuf[fid].bufno >= 0)
    return 1;

  bufno = 0;
  HashLock(&syBuf);
  while (bufno < ARRAY_SIZE(syBuffers) && syBuffers[bufno].inuse)
    bufno++;
  if (bufno >= ARRAY_SIZE(syBuffers)) {
      HashUnlock(&syBuf);
      return 0;
  }
  syBuf[fid].bufno = bufno;
  syBuffers[bufno].inuse = TRUE;
  syBuffers[bufno].bufstart = 0;
  syBuffers[bufno].buflen = 0;
  HashUnlock(&syBuf);
  return 1;
}

/****************************************************************************
**
*F  SyFclose( <fid> ) . . . . . . . . . . . . . . . . .  close the file <fid>
**
**  'SyFclose' closes the file with the identifier <fid>  which  is  obtained
**  from 'SyFopen'.
*/
Int SyFclose (
    Int                 fid )
{
    /* check file identifier                                               */
    if ( ARRAY_SIZE(syBuf) <= fid || fid < 0 ) {
        fputs("gap: panic 'SyFclose' asked to close illegal fid!\n",stderr);
        return -1;
    }
    if ( !SyBufInUse(fid) ) {
        fputs("gap: panic 'SyFclose' asked to close closed file!\n",stderr);
        return -1;
    }

    /* refuse to close the standard files                                  */
    if ( fid == 0 || fid == 1 || fid == 2 || fid == 3 ) {
        return -1;
    }
    HashLock(&syBuf);
    /* try to close the file                                               */
    if (syBuf[fid].type == raw_socket && close(syBuf[fid].fp) == EOF) {
        fputs("gap: 'SyFclose' cannot close file, ",stderr);
        fputs("maybe your file system is full?\n",stderr);
        SyBufMarkUnused(fid);
        HashUnlock(&syBuf);
        return -1;
    }

    if (syBuf[fid].type == gzip_socket) {
        if (gzclose(syBuf[fid].gzfp) < 0) {
            fputs("gap: 'SyFclose' cannot close compressed file", stderr);
        }
    }

    /* mark the buffer as unused                                           */
    if (syBuf[fid].bufno >= 0)
      syBuffers[syBuf[fid].bufno].inuse = FALSE;
    SyBufMarkUnused(fid);
    HashUnlock(&syBuf);
    return 0;
}


/****************************************************************************
**
*F  SyIsEndOfFile( <fid> )  . . . . . . . . . . . . . . . end of file reached
*/
Int SyIsEndOfFile (
    Int                 fid )
{
    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return -1;
    }

    /* *stdin* and *errin* are never at end of file                        */
    if ( fid < 4 )
        return 0;

    /* How to detect end of file ?? */

    return syBuf[fid].ateof;
    /* return feof(syBuf[fid].fp);*/
}


/****************************************************************************
**
*F  syStartraw( <fid> ) . . . . . . start raw mode on input file <fid>, local
**
**  The  following four  functions are  the  actual system  dependent part of
**  'SyFgets'.
**
**  'syStartraw' tries to put the file with the file  identifier  <fid>  into
**  raw mode.  I.e.,  disabling  echo  and  any  buffering.  It also finds  a
**  place to put the echoing  for  'syEchoch'.  If  'syStartraw'  succedes it
**  returns 1, otherwise, e.g., if the <fid> is not a terminal, it returns 0.
**
**  'syStopraw' stops the raw mode for the file  <fid>  again,  switching  it
**  back into whatever mode the terminal had before 'syStartraw'.
**
**  'syGetch' reads one character from the file <fid>, which must  have  been
**  turned into raw mode before, and returns it.
**
**  'syEchoch' puts the character <ch> to the file opened by 'syStartraw' for
**  echoing.  Note that if the user redirected 'stdout' but not 'stdin',  the
**  echo for 'stdin' must go to 'ttyname(fileno(stdin))' instead of 'stdout'.
*/

/****************************************************************************
**  For UNIX System V, input/output redirection and typeahead are  supported.
**  We  turn off input buffering  and canonical input editing and  also echo.
**  Because we leave the signals enabled  we  have  to disable the characters
**  for interrupt and quit, which are usually set to '<ctr>-C' and '<ctr>-B'.
**  We   also turn off the  xon/xoff  start  and  stop  characters, which are
**  usually set to  '<ctr>-S'  and '<ctr>-Q' so we  can get those characters.
**  We do  not turn of  signals  'ISIG' because  we want   to catch  stop and
**  continue signals if this particular version  of UNIX supports them, so we
**  can turn the terminal line back to cooked mode before stopping GAP.
*/
static struct termios   syOld, syNew;           /* old and new terminal state      */

#ifdef SIGTSTP

static Int syFid;

static void syAnswerCont(int signr)
{
    syStartraw( syFid );
    signal( SIGCONT, SIG_DFL );
    kill( getpid(), SIGCONT );
}

static void syAnswerTstp(int signr)
{
    syStopraw( syFid );
    signal( SIGCONT, syAnswerCont );
    kill( getpid(), SIGTSTP );
}

#endif

UInt syStartraw ( Int fid )
{
    /* if running under a window handler, tell it that we want to read     */
    if ( SyWindow ) {
        if      ( fid == 0 ) { syWinPut( fid, "@i", "" );  return 1; }
        else if ( fid == 2 ) { syWinPut( fid, "@e", "" );  return 1; }
        else {                                             return 0; }
    }

    /* try to get the terminal attributes, will fail if not terminal       */
    const int fd = SyBufFileno(fid);
    GAP_ASSERT(fd >= 0);
    if ( tcgetattr( fd, &syOld) == -1 )
        return 0;

    /* disable interrupt, quit, start and stop output characters           */
    syNew = syOld;
    syNew.c_cc[VINTR] = 0377;
    syNew.c_cc[VQUIT] = 0377;
    /*C 27-Nov-90 martin changing '<ctr>S' and '<ctr>Q' does not work      */
    /*C syNew.c_iflag    &= ~(IXON|INLCR|ICRNL);                           */
    syNew.c_iflag    &= ~(INLCR|ICRNL);

    /* disable input buffering, line editing and echo                      */
    syNew.c_cc[VMIN]  = 1;
    syNew.c_cc[VTIME] = 0;
    syNew.c_lflag    &= ~(ECHO|ICANON);

    if ( tcsetattr( fd, TCSANOW, &syNew) == -1 )
        return 0;

#ifdef SIGTSTP
    /* install signal handler for stop                                     */
    syFid = fid;
    signal( SIGTSTP, syAnswerTstp );
#endif

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  syStopraw( <fid> )  . . . . . .  stop raw mode on input file <fid>, local
*/

void syStopraw (
    Int                 fid )
{
    /* if running under a window handler, don't do nothing                 */
    if ( SyWindow )
        return;

#ifdef SIGTSTP
    /* remove signal handler for stop                                      */
    signal( SIGTSTP, SIG_DFL );
#endif

    /* enable input buffering, line editing and echo again                 */
    const int fd = SyBufFileno(fid);
    GAP_ASSERT(fd >= 0);
    if (tcsetattr(fd, TCSANOW, &syOld) == -1)
        fputs("gap: 'tcsetattr' could not turn off raw mode!\n",stderr);
}


/****************************************************************************
**
*F  SyIsIntr() . . . . . . . . . . . . . . . . check whether user hit <ctr>-C
**
**  'SyIsIntr' is called from the evaluator at  regular  intervals  to  check
**  whether the user hit '<ctr>-C' to interrupt a computation.
**
**  'SyIsIntr' returns 1 if the user typed '<ctr>-C' and 0 otherwise.
*/


/****************************************************************************
**
*f  SyIsIntr()
**
**  For  UNIX  we  install 'syAnswerIntr' to  answer interrupt 'SIGINT'. If
**  two interrupts  occur within 1 second 'syAnswerIntr' exits GAP.
*/
#ifdef HAVE_SIGNAL


static UInt syLastIntr; /* time of the last interrupt      */


#ifdef HAVE_LIBREADLINE
static Int doingReadline;
#endif

static void syAnswerIntr(int signr)
{
    UInt                nowIntr;

#ifdef HAVE_LIBREADLINE
    /* ignore during readline */
    if (doingReadline) return;
#endif

    /* get the current wall clock time                                     */
    nowIntr = time(0);

    /* if the last '<ctr>-C' was less than a second ago, exit GAP          */
    if ( syLastIntr && nowIntr-syLastIntr < 1 ) {
        fputs("gap: you hit '<ctr>-C' twice in a second, goodbye.\n",stderr);
        SyExit( 1 );
    }

    /* remember time of this interrupt                                     */
    syLastIntr = nowIntr;

#ifdef HAVE_SIGNAL
    /* interrupt the executor                                              */
    InterruptExecStat();
#endif
}


void SyInstallAnswerIntr ( void )
{
    struct sigaction sa;

    sa.sa_handler = syAnswerIntr;
    sigemptyset(&(sa.sa_mask));
    sa.sa_flags = SA_RESTART;
    sigaction( SIGINT, &sa, NULL );
}


UInt SyIsIntr ( void )
{
    UInt                isIntr;

    isIntr = (syLastIntr != 0);
#ifdef HPCGAP
    /* The following write has to be conditional to avoid serious
     * performance degradation on shared memory (especially NUMA)
     * architectures when multiple threads all try to write to the same
     * location at the same time. Branch prediction can be expected to
     * be near perfect.
     */
    if (isIntr) syLastIntr = 0;
#else
    syLastIntr = 0;
#endif
    return isIntr;
}

#endif


/****************************************************************************
 **
 *F  getwindowsize() . . . . . . . get screen size from termcap or TIOCGWINSZ
 **
 **  For UNIX  we  install 'syWindowChangeIntr' to answer 'SIGWINCH'.
 */

#ifdef TIOCGWINSZ
/* signal routine: window size changed */
void syWindowChangeIntr ( int signr )
{
    struct winsize win;
    if(ioctl(0, TIOCGWINSZ, (char *) &win) >= 0) {
        if(!SyNrRowsLocked && win.ws_row > 0)
            SyNrRows = win.ws_row;
        if(!SyNrColsLocked && win.ws_col > 0)
          SyNrCols = win.ws_col - 1;        /* never trust last column */
        if (SyNrCols < 20) SyNrCols = 20;
        if (SyNrCols > MAXLENOUTPUTLINE) SyNrCols = MAXLENOUTPUTLINE;
    }
}

#endif /* TIOCGWINSZ */

void getwindowsize( void )
{
/* it might be that SyNrRows, SyNrCols have been set by the user with -x, -y */
/* otherwise they are zero */

/* first strategy: try to ask the operating system */
#ifdef TIOCGWINSZ
    if (SyNrRows <= 0 || SyNrCols <= 0) {
        struct winsize win;

        if(ioctl(0, TIOCGWINSZ, (char *) &win) >= 0) {
            if (SyNrRows <= 0)
                SyNrRows = win.ws_row;
            if (SyNrCols <= 0)
                SyNrCols = win.ws_col;
        }
        (void) signal(SIGWINCH, syWindowChangeIntr);
    }
#endif /* TIOCGWINSZ */

#ifdef USE_TERMCAP
/* note that if we define TERMCAP, this has to be linked with -ltermcap */
/* maybe that is -ltermlib on some SYSV machines */
    if (SyNrRows <= 0 || SyNrCols <= 0) {
              /* this failed - next attempt: try to find info in TERMCAP */
        char *sp;
        char bp[1024];

        if ((sp = getenv("TERM")) != NULL && tgetent(bp,sp) == 1) {
            if(SyNrRows <= 0)
                SyNrRows = tgetnum("li");
            if(SyNrCols <= 0)
                SyNrCols = tgetnum("co");
        }
    }
#endif

    /* if nothing worked, use 80x24 */
    if (SyNrCols <= 0)
        SyNrCols = 80;
    if (SyNrRows <= 0)
        SyNrRows = 24;

    /* reset SyNrCols if value is strange */
    if (SyNrCols < 20) SyNrCols = 20;
    if (SyNrCols > MAXLENOUTPUTLINE) SyNrCols = MAXLENOUTPUTLINE;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * * * output * * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  syEchoch( <ch>, <fid> ) . . . . . . . . . . . echo a char to <fid>, local
*/


/****************************************************************************
**
*f  syEchoch( <ch>, <fid> )
*/
static void syEchoch(Int ch, Int fid)
{
    Char                ch2;

    /* write the character to the associate echo output device             */
    ch2 = ch;
    echoandcheck( fid, (char*)&ch2, 1 );

    /* if running under a window handler, duplicate '@'                    */
    if ( SyWindow && ch == '@' ) {
        ch2 = ch;
        echoandcheck( fid, (char*)&ch2, 1 );
    }
}

/****************************************************************************
**
*F  SyEchoch( <ch>, <fid> ) . . . . . . . . . . . . .  echo a char from <fid>
*/
Int SyEchoch (
    Int                 ch,
    Int                 fid )
{
    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return -1;
    }
    syEchoch(ch,fid);
    return 0;
}



/****************************************************************************
**
*F  syEchos( <ch>, <fid> )  . . . . . . . . . . . echo a char to <fid>, local
*/


/****************************************************************************
**
*f  syEchos( <ch>, <fid> )
*/
static void syEchos(const Char * str, Int fid)
{
    /* if running under a window handler, send the line to it              */
    if ( SyWindow && fid < 4 )
        syWinPut( fid, (fid == 1 ? "@n" : "@f"), str );

    /* otherwise, write it to the associate echo output device             */
    else
        echoandcheck(fid, str, strlen(str) );
}


/****************************************************************************
**
*F  SyFputs( <line>, <fid> )  . . . . . . . .  write a line to the file <fid>
**
**  'SyFputs' is called to put the  <line>  to the file identified  by <fid>.
*/
static UInt syNrchar;                   /* nr of chars already on the line */
static Char syPrompt[MAXLENOUTPUTLINE]; /* characters already on the line  */


/****************************************************************************
**
*f  SyFputs( <line>, <fid> )
*/
void SyFputs (
    const Char *        line,
    Int                 fid )
{
    UInt                i;

    /* if outputing to the terminal compute the cursor position and length */
    if ( fid == 1 || fid == 3 ) {
        syNrchar = 0;
        for ( i = 0; line[i] != '\0'; i++ ) {
            if ( line[i] == '\n' )  syNrchar = 0;
            else                    syPrompt[syNrchar++] = line[i];
        }
        syPrompt[syNrchar] = '\0';
    }

    /* otherwise compute only the length                                   */
    else {
        i = strlen(line);
    }

    /* if running under a window handler, send the line to it              */
    if ( SyWindow && fid < 4 )
        syWinPut( fid, (fid == 1 ? "@n" : "@f"), line );

    /* otherwise, write it to the output file                              */
    else
        echoandcheck(fid, line, i);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * * * input  * * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  SyFtell( <fid> )  . . . . . . . . . . . . . . . . . .  position of stream
*/
Int SyFtell (
    Int                 fid )
{
    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return -1;
    }

    Int ret;

    switch (syBuf[fid].type) {
    case raw_socket:
        ret = (Int)lseek(syBuf[fid].fp, 0, SEEK_CUR);
        break;
    case gzip_socket:
        ret = (Int)gzseek(syBuf[fid].gzfp, 0, SEEK_CUR);
        break;
    case unused_socket:
    default:
        return -1;
    }

    // Need to account for characters in buffer
    if (syBuf[fid].bufno >= 0) {
        UInt bufno = syBuf[fid].bufno;
        ret -= syBuffers[bufno].buflen - syBuffers[bufno].bufstart;
    }
    return ret;
}


/****************************************************************************
**
*F  SyFseek( <fid>, <pos> )   . . . . . . . . . . . seek a position of stream
*/
Int SyFseek (
    Int                 fid,
    Int                 pos )
{
    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return -1;
    }

    if (syBuf[fid].bufno >= 0) {
        UInt bufno = syBuf[fid].bufno;
        syBuffers[bufno].buflen = 0;
        syBuffers[bufno].bufstart = 0;
    }

    switch (syBuf[fid].type) {
    case raw_socket:
        return (Int)lseek(syBuf[fid].fp, pos, SEEK_SET);
    case gzip_socket:
        return (Int)gzseek(syBuf[fid].gzfp, pos, SEEK_SET);
    case unused_socket:
    default:
        return -1;
    }
}


/****************************************************************************
**
*F  syGetchTerm( <fid> )  . . . . . . . . . . . . . . . . . get a char from <fid>
**
**  'SyGetchTerm' reads a character from <fid>, which is already switched
**  to raw mode if it is *stdin* or *errin*.

*/



/****************************************************************************
**
*f  syGetchTerm( <fid> )  . . . . . . . . . . . . . . . . . . . . . UNIX
**
**  This version should be called if the input is stdin and command-line editing
**  etc. is switched on. It handles possible messages from xgap and systems
**  that return odd things rather than waiting for a key
**
*/


/* In the cygwin environment it is not predictable if text files get the
 * '\r' in their line ends filtered out *before* GAP sees them. This leads
 * to problem with continuation of strings or integers over several lines in
 * GAP input. Therefore we introduce a hack which removes such '\r's
 * before '\n's on such a system. Add here if there are other systems with
 * a similar problem.
 */

#ifdef SYS_IS_CYGWIN32
#  define LINE_END_HACK 1
#endif

Int SyRead(Int fid, void * ptr, size_t len)
{
    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return -1;
    }

    if (syBuf[fid].type == gzip_socket) {
        return gzread(syBuf[fid].gzfp, ptr, len);
    }
    else {
        return read(syBuf[fid].fp, ptr, len);
    }
}

Int SyReadWithBuffer(Int fid, void * ptr, size_t len)
{
    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return -1;
    }

    // first drain the buffer
    if (syBuf[fid].bufno >= 0) {
        UInt   bufno = syBuf[fid].bufno;
        size_t avail = syBuffers[bufno].buflen - syBuffers[bufno].bufstart;
        if (avail > 0) {
            if (avail > len)
                avail = len;
            memcpy(ptr, syBuffers[bufno].buf + syBuffers[bufno].bufstart,
                   avail);
            syBuffers[bufno].bufstart += avail;
            return avail;
        }
    }

    return SyRead(fid, ptr, len);
}


Int SyWrite(Int fid, const void * ptr, size_t len)
{
    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return -1;
    }

    if (syBuf[fid].type == gzip_socket) {
        return gzwrite(syBuf[fid].gzfp, ptr, len);
    }
    else {
        return write(syBuf[fid].echo, ptr, len);
    }
}

static Int syGetchTerm(Int fid)
{
    UChar                ch;
    Char                str[2];
    Int ret;

    /* retry on errors or end-of-file. Ignore 0 bytes */

#ifdef LINE_END_HACK
 tryagain:
#endif
    while ( (ret = SyRead( fid, &ch, 1 )) == -1 && errno == EAGAIN )
        ;
    if (ret <= 0) return EOF;

    /* if running under a window handler, handle special characters        */
    if ( SyWindow && ch == '@' ) {
        do {
            while ( (ret = SyRead(fid, &ch, 1)) == -1 &&
                    errno == EAGAIN ) ;
            if (ret <= 0) return EOF;
        } while ( ch < '@' || 'z' < ch );
        if ( ch == 'y' ) {
            do {
                while ( (ret = SyRead(fid, &ch, 1)) == -1 &&
                        errno == EAGAIN );
                if (ret <= 0) return EOF;
            } while ( ch < '@' || 'z' < ch );
            str[0] = ch;
            str[1] = 0;
            syWinPut( syBuf[fid].echo, "@s", str );
            ch = syGetchTerm(fid);
        }
        else if ( 'A' <= ch && ch <= 'Z' )
            ch = CTR(ch);
    }

#ifdef LINE_END_HACK
    /* A hack for non ANSI-C confirming systems which deliver \r or \r\n
     * line ends. These are translated to \n here.
     */
    if (ch == '\n') {
        if (syBuf[fid].crlast) {
            syBuf[fid].crlast = FALSE;
            goto tryagain;
        } else
            return (UChar)'\n';
    }
    if (ch == '\r') {
        syBuf[fid].crlast = TRUE;
        return (Int)'\n';
    }
    // We saw a '\r' without a '\n'
    syBuf[fid].crlast = FALSE;
#endif  /* line end hack */

    /* return the character                                                */
    return (Int)ch;
}

static Int syGetchNonTerm(Int fid)
{
    UChar               ch = 0;
    UInt                bufno;
    int                 ret;


    /* we jump back here if the byte we just read was the \n of \r\n, in which
       case it doesn't count */

#ifdef LINE_END_HACK
 tryagain:
#endif
    if (syBuf[fid].bufno < 0)
        while ((ret = SyRead(fid, &ch, 1)) == -1 && errno == EAGAIN)
            ;
    else {
        bufno = syBuf[fid].bufno;
        if (syBuffers[bufno].bufstart < syBuffers[bufno].buflen) {
            ch = syBuffers[bufno].buf[syBuffers[bufno].bufstart++];
            ret = 1;
        } else {
            while ((ret = SyRead(fid, syBuffers[bufno].buf,
                                 SYS_FILE_BUF_SIZE)) == -1 &&
                   errno == EAGAIN)
                ;
            if (ret > 0) {
                ch = syBuffers[bufno].buf[0];
                syBuffers[bufno].bufstart = 1;
                syBuffers[bufno].buflen = ret;
            }
        }
    }

    if (ret < 1) {
        syBuf[fid].ateof = TRUE;
        return EOF;
    }

#ifdef LINE_END_HACK
    /* A hack for non ANSI-C confirming systems which deliver \r or \r\n
     * line ends. These are translated to \n here.
     */
    if (ch == '\n') {
        if (syBuf[fid].crlast) {
            syBuf[fid].crlast = FALSE;
            goto tryagain;
        } else
            return (UChar)'\n';
    }
    if (ch == '\r') {
        syBuf[fid].crlast = TRUE;
        return (Int)'\n';
    }
    // We saw a '\r' without a '\n'
    syBuf[fid].crlast = FALSE;
#endif  /* line end hack */

    /* return the character                                                */
    return (Int)ch;
}



/****************************************************************************
**
*f  syGetch( <fid> )
*/

static Int syGetch(Int fid)
{
    if (syBuf[fid].isTTY)
      return syGetchTerm(fid);
    else
      return syGetchNonTerm(fid);
}


/****************************************************************************
**
*F  SyGetch( <fid> )  . . . . . . . . . . . . . . . . . get a char from <fid>
**
**  'SyGetch' reads a character from <fid>, which is switch to raw mode if it
**  is *stdin* or *errin*.
*/
Int SyGetch (
    Int                 fid )
{
    Int                 ch;

    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return -1;
    }

    /* if we are reading stdin or errin use raw mode                       */
    if ( fid == 0 || fid == 2 ) {
        syStartraw(fid);
    }
    ch = syGetch(fid);
    if ( fid == 0 || fid == 2 ) {
        syStopraw(fid);
    }
    return ch;
}


/****************************************************************************
**
*F  SyFgets( <line>, <length>, <fid> )  . . . . .  get a line from file <fid>
**
**  'SyFgets' is called to read a line from the file  with  identifier <fid>.
**  'SyFgets' (like 'fgets') reads characters until either  <length>-1  chars
**  have been read or until a <newline> or an  <eof> character is encoutered.
**  It retains the '\n' (unlike 'gets'), if any, and appends '\0' to  <line>.
**  'SyFgets' returns <line> if any char has been read, otherwise '(char*)0'.
**
**  'SyFgets'  allows to edit  the input line if the  file  <fid> refers to a
**  terminal with the following commands:
**
**      <ctr>-A move the cursor to the beginning of the line.
**      <esc>-B move the cursor to the beginning of the previous word.
**      <ctr>-B move the cursor backward one character.
**      <ctr>-F move the cursor forward  one character.
**      <esc>-F move the cursor to the end of the next word.
**      <ctr>-E move the cursor to the end of the line.
**
**      <ctr>-H, <del> delete the character left of the cursor.
**      <ctr>-D delete the character under the cursor.
**      <ctr>-K delete up to the end of the line.
**      <esc>-D delete forward to the end of the next word.
**      <esc>-<del> delete backward to the beginning of the last word.
**      <ctr>-X delete entire input line, and discard all pending input.
**      <ctr>-Y insert (yank) a just killed text.
**
**      <ctr>-T exchange (twiddle) current and previous character.
**      <esc>-U uppercase next word.
**      <esc>-L lowercase next word.
**      <esc>-C capitalize next word.
**
**      <tab>   complete the identifier before the cursor.
**      <ctr>-L insert last input line before current character.
**      <ctr>-P redisplay the last input line, another <ctr>-P will redisplay
**              the line before that, etc.  If the cursor is not in the first
**              column only the lines starting with the string to the left of
**              the cursor are taken. The history is limitied to ~8000 chars.
**      <ctr>-N Like <ctr>-P but goes the other way round through the history
**      <esc>-< goes to the beginning of the history.
**      <esc>-> goes to the end of the history.
**      <ctr>-O accept this line and perform a <ctr>-N.
**
**      <ctr>-V enter next character literally.
**      <ctr>-U execute the next command 4 times.
**      <esc>-<num> execute the next command <num> times.
**      <esc>-<ctr>-L repaint input line.
**
**  Not yet implemented commands:
**
**      <ctr>-S search interactive for a string forward.
**      <ctr>-R search interactive for a string backward.
**      <esc>-Y replace yanked string with previously killed text.
**      <ctr>-_ undo a command.
**      <esc>-T exchange two words.
*/

static UInt syCTRO; /* number of '<ctr>-O' pending     */
static UInt syESCN; /* number of '<Esc>-N' pending     */

static UInt FreezeStdin;    // When true, ignore if any new input from stdin
                            // This is used to stop HPC-GAP from reading stdin
                            // while forked subprocesses are running.


#ifdef HAVE_SELECT

static Obj OnCharReadHookActive = 0;  /* if bound the hook is active */
static Obj OnCharReadHookInFds = 0;   /* a list of UNIX file descriptors for reading */
static Obj OnCharReadHookInFuncs = 0; /* a list of GAP functions with 0 args */
static Obj OnCharReadHookOutFds = 0;  /* a list of UNIX file descriptors for writing */
static Obj OnCharReadHookOutFuncs = 0;/* a list of GAP functions with 0 args */
static Obj OnCharReadHookExcFds = 0;  /* a list of UNIX file descriptors */
static Obj OnCharReadHookExcFuncs = 0;/* a list of GAP functions with 0 args */

static Int OnCharReadHookActiveCheck(void)
{
    return OnCharReadHookActive != 0 || FreezeStdin != 0;
}


static void HandleCharReadHook(int stdinfd)
/* This is called directly before a character is read from stdin in the case
 * of an interactive session with command line editing. We have to return
 * as soon as stdin is ready to read! We just use `select' and care for
 * handlers for streams. */
{
  fd_set infds,outfds,excfds;
  int n,maxfd;
  Int i,j;
  Obj o;
  static int WeAreAlreadyInHere = 0;

  /* Just to make sure: */
  if (WeAreAlreadyInHere) return;
  WeAreAlreadyInHere = 1;

  while (1) {  /* breaks when fd becomes ready */
    FD_ZERO(&infds);
    FD_ZERO(&outfds);
    FD_ZERO(&excfds);
    FD_SET(stdinfd,&infds);
    maxfd = stdinfd;
    /* Handle input file descriptors: */
    if (OnCharReadHookInFds != (Obj) 0 &&
        IS_PLIST(OnCharReadHookInFds) &&
        OnCharReadHookInFuncs != (Obj) 0 &&
        IS_PLIST(OnCharReadHookInFuncs)) {
      for (i = 1;i <= LEN_PLIST(OnCharReadHookInFds);i++) {
        o = ELM_PLIST(OnCharReadHookInFds,i);
        if (o != (Obj) 0 && IS_INTOBJ(o)) {
          j = INT_INTOBJ(o);  /* a UNIX file descriptor */
          FD_SET(j,&infds);
          if (j > maxfd) maxfd = j;
        }
      }
    }
    /* Handle output file descriptors: */
    if (OnCharReadHookOutFds != (Obj) 0 &&
        IS_PLIST(OnCharReadHookOutFds) &&
        OnCharReadHookOutFuncs != (Obj) 0 &&
        IS_PLIST(OnCharReadHookOutFuncs)) {
      for (i = 1;i <= LEN_PLIST(OnCharReadHookOutFds);i++) {
        o = ELM_PLIST(OnCharReadHookOutFds,i);
        if (o != (Obj) 0 && IS_INTOBJ(o)) {
          j = INT_INTOBJ(o);  /* a UNIX file descriptor */
          FD_SET(j,&outfds);
          if (j > maxfd) maxfd = j;
        }
      }
    }
    /* Handle exception file descriptors: */
    if (OnCharReadHookExcFds != (Obj) 0 &&
        IS_PLIST(OnCharReadHookExcFds) &&
        OnCharReadHookExcFuncs != (Obj) 0 &&
        IS_PLIST(OnCharReadHookExcFuncs)) {
      for (i = 1;i <= LEN_PLIST(OnCharReadHookExcFds);i++) {
        o = ELM_PLIST(OnCharReadHookExcFds,i);
        if (o != (Obj) 0 && IS_INTOBJ(o)) {
          j = INT_INTOBJ(o);  /* a UNIX file descriptor */
          FD_SET(j,&excfds);
          if (j > maxfd) maxfd = j;
        }
      }
    }

    n = select(maxfd+1,&infds,&outfds,&excfds,NULL);
    if (n >= 0) {
      /* Now run through the lists and call functions if ready: */

      if (OnCharReadHookInFds != (Obj) 0 &&
          IS_PLIST(OnCharReadHookInFds) &&
          OnCharReadHookInFuncs != (Obj) 0 &&
          IS_PLIST(OnCharReadHookInFuncs)) {
        for (i = 1;i <= LEN_PLIST(OnCharReadHookInFds);i++) {
          o = ELM_PLIST(OnCharReadHookInFds,i);
          if (o != (Obj) 0 && IS_INTOBJ(o)) {
            j = INT_INTOBJ(o);  /* a UNIX file descriptor */
            if (FD_ISSET(j,&infds)) {
              o = ELM_PLIST(OnCharReadHookInFuncs,i);
              if (o != (Obj) 0 && IS_FUNC(o))
                Call1ArgsInNewReader(o,INTOBJ_INT(i));
            }
          }
        }
      }
      /* Handle output file descriptors: */
      if (OnCharReadHookOutFds != (Obj) 0 &&
          IS_PLIST(OnCharReadHookOutFds) &&
          OnCharReadHookOutFuncs != (Obj) 0 &&
          IS_PLIST(OnCharReadHookOutFuncs)) {
        for (i = 1;i <= LEN_PLIST(OnCharReadHookOutFds);i++) {
          o = ELM_PLIST(OnCharReadHookOutFds,i);
          if (o != (Obj) 0 && IS_INTOBJ(o)) {
            j = INT_INTOBJ(o);  /* a UNIX file descriptor */
            if (FD_ISSET(j,&outfds)) {
              o = ELM_PLIST(OnCharReadHookOutFuncs,i);
              if (o != (Obj) 0 && IS_FUNC(o))
                Call1ArgsInNewReader(o,INTOBJ_INT(i));
            }
          }
        }
      }
      /* Handle exception file descriptors: */
      if (OnCharReadHookExcFds != (Obj) 0 &&
          IS_PLIST(OnCharReadHookExcFds) &&
          OnCharReadHookExcFuncs != (Obj) 0 &&
          IS_PLIST(OnCharReadHookExcFuncs)) {
        for (i = 1;i <= LEN_PLIST(OnCharReadHookExcFds);i++) {
          o = ELM_PLIST(OnCharReadHookExcFds,i);
          if (o != (Obj) 0 && IS_INTOBJ(o)) {
            j = INT_INTOBJ(o);  /* a UNIX file descriptor */
            if (FD_ISSET(j,&excfds)) {
              o = ELM_PLIST(OnCharReadHookExcFuncs,i);
              if (o != (Obj) 0 && IS_FUNC(o))
                Call1ArgsInNewReader(o,INTOBJ_INT(i));
            }
          }
        }
      }

      // Return if there is input to read from stdin,
      // and FreezeStdin is false.
      if (FD_ISSET(stdinfd, &infds) && !FreezeStdin) {
          WeAreAlreadyInHere = 0;
          break;
      }
    } else
      break;
  } /* while (1) */
}
#endif   /* HAVE_SELECT */



/***************************************************************************
**
*F HasAvailableBytes( <fid> ) returns positive if  a subsequent read to <fid>
**                            will read at least one byte without blocking
**
*/

Int HasAvailableBytes( UInt fid )
{
  UInt bufno;
  if (!SyBufInUse(fid))
    return -1;

  if (syBuf[fid].bufno >= 0)
    {
      bufno = syBuf[fid].bufno;
      if (syBuffers[bufno].bufstart < syBuffers[bufno].buflen)
        return 1;
    }

#ifdef HAVE_SELECT
  // All sockets other than raw sockets are always ready
  if (syBuf[fid].type == raw_socket) {
    fd_set set;
    struct timeval tv;
    FD_ZERO( &set);
    FD_SET( syBuf[fid].fp, &set );
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    return select( syBuf[fid].fp + 1, &set, NULL, NULL, &tv);
  }
#endif
  /* best guess */
  Int ret = SyIsEndOfFile(fid);
  return (ret != -1 && ret != 1);
}


static Char * syFgetsNoEdit(Char * line, UInt length, Int fid, UInt block)
{
  UInt x = 0;
  int ret = 0;

  /* if stream is buffered, and the buffer has a full line,
   * grab it -- we could make more use of the buffer, but
   * this covers the majority of cases simply. */
#ifndef LINE_END_HACK
  UInt bufno;
  Char* newlinepos;
  Char* bufstart;
  int buflen;
  if(!syBuf[fid].isTTY && syBuf[fid].bufno >= 0) {
    bufno = syBuf[fid].bufno;
    if (syBuffers[bufno].bufstart < syBuffers[bufno].buflen) {
      bufstart = syBuffers[bufno].buf + syBuffers[bufno].bufstart;
      buflen = syBuffers[bufno].buflen - syBuffers[bufno].bufstart;
      newlinepos = memchr(bufstart, '\n', buflen);
      if(newlinepos && (newlinepos - bufstart) < length - 2) {
          newlinepos++;
          memcpy(line, bufstart, newlinepos - bufstart);
          line[newlinepos - bufstart] = '\0';
          syBuffers[bufno].bufstart += (newlinepos - bufstart);
          return line;
      }
    }
  }
#endif

  while (x < length -1) {
    if (!block && x && !HasAvailableBytes( fid ))
      {
        break;
      }
    ret = syGetch(fid);
    if (ret == EOF)
      break;
    if ((line[x++] = ret) == '\n')
      break;
  }
  line[x] = '\0';
  syBuf[fid].ateof = (ret == EOF);
  if (x)
    return line;
  else
    return NULL;
}

/* will be imported from library, first is generic function which does some
   checks before returning result to kernel, the second is the list of handler
   functions which do the actual work. */
static Obj LineEditKeyHandler;
static Obj LineEditKeyHandlers;
static Obj GAPInfo;

#ifdef HAVE_LIBREADLINE

/* we import GAP level functions from GAPInfo components */
static Obj CLEFuncs;
static Obj KeyHandler;

static int GAPMacroNumber = 0;

static int GAP_set_macro(int count, int key)
{
 GAPMacroNumber = count;
 return 0;
}
/* a generic rl_command_func_t that delegates to GAP level */
static int GAP_rl_func(int count, int key)
{
   Obj   rldata, linestr, okey, res, obj, data, beginchange, endchange, m;
   Int   len, n, hook, dlen, max, i;

   /* we shift indices 0-based on C-level and 1-based on GAP level */
   linestr = MakeString(rl_line_buffer);
   okey = INTOBJ_INT(key + 1000*GAPMacroNumber);
   GAPMacroNumber = 0;
   rldata = NEW_PLIST(T_PLIST, 6);
   if (GAP_rl_func == rl_last_func) {
     SET_LEN_PLIST(rldata, 6);
     SET_ELM_PLIST(rldata, 6, True);
   }
   else
     SET_LEN_PLIST(rldata, 5);
   SET_ELM_PLIST(rldata, 1, INTOBJ_INT(count));
   SET_ELM_PLIST(rldata, 2, okey);
   SET_ELM_PLIST(rldata, 3, linestr);
   SET_ELM_PLIST(rldata, 4, INTOBJ_INT(rl_point+1));
   SET_ELM_PLIST(rldata, 5, INTOBJ_INT(rl_mark+1));
   res = Call1ArgsInNewReader(KeyHandler, rldata);
   if (!res) return 0;
   if (!IS_LIST(res)) return 0;
   len = LEN_LIST(res);
   if (len == 0) return 0;
   obj = ELM_LIST(res, 1);
   if (IsStringConv(obj)) {
      /* insert txt */
      rl_insert_text(CONST_CSTR_STRING(obj));
      n = 1;
   } else if ((obj == True || obj == False) && len > 2) {
      /* kill or delete text */
      beginchange = ELM_LIST(res, 2);
      if (!IS_INTOBJ(beginchange)) return 0;
      endchange = ELM_LIST(res, 3);
      if (!IS_INTOBJ(endchange)) return 0;
      if (obj == True)
         rl_kill_text(INT_INTOBJ(beginchange)-1, INT_INTOBJ(endchange)-1);
      else
         rl_delete_text(INT_INTOBJ(beginchange)-1, INT_INTOBJ(endchange)-1);
      n = 3;
   }  else if (IS_INTOBJ(obj) && len > 2) {
      /* delete some text and insert */
      beginchange = obj;
      endchange = ELM_LIST(res, 2);
      if (!IS_INTOBJ(endchange)) return 0;
      obj = ELM_LIST(res, 3);
      if (!IsStringConv(obj)) return 0;
      rl_begin_undo_group();
      rl_delete_text(INT_INTOBJ(beginchange)-1, INT_INTOBJ(endchange)-1);
      rl_point = INT_INTOBJ(beginchange)-1;
      rl_insert_text(CONST_CSTR_STRING(obj));
      rl_end_undo_group();
      n = 3;
   } else if (IS_INTOBJ(obj) && len == 2) {
      /* several hooks to particular rl_ functions with data */
      hook = INT_INTOBJ(obj);
      data = ELM_LIST(res, 2);
      if (hook == 1) {
         /* display matches */
         if (!IS_LIST(data)) return 0;
         /* -1, because first is word to be completed */
         dlen = LEN_LIST(data)-1;
         /* +2, must be in 'argv' format, terminated by 0 */
         char **strs = (char**)calloc(dlen+2, sizeof(char*));
         max = 0;
         for (i=0; i <= dlen; i++) {
            if (!IsStringConv(ELM_LIST(data, i+1))) {
               free(strs);
               return 0;
            }
            strs[i] = CSTR_STRING(ELM_LIST(data, i+1));
            if (max < strlen(strs[i])) max = strlen(strs[i]);
         }
         rl_display_match_list(strs, dlen, max);
         free(strs);
         rl_on_new_line();
      }
      else if (hook == 2) {
         /* put these characters into sequence of input keys */
         if (!IsStringConv(data)) return 0;
         dlen = strlen(CSTR_STRING(data));
         for (i=0; i < dlen; i++)
             rl_stuff_char(CSTR_STRING(data)[i]);
      }
      n = 2;
   } else if (IS_INTOBJ(obj) && len == 1) {
      /* several hooks to particular rl_ functions with no data */
      hook = INT_INTOBJ(obj);
      /* ring bell */
      if (hook == 100) rl_ding();
      /* return line (execute Ctrl-m) */
      else if (hook == 101) rl_execute_next(13);
      n = 1;
   } else
      n = 0;

   /* optionally we can return the new point, or new point and mark */
   if (len > n) {
      n++;
      m = ELM_LIST(res, n);
      if (IS_INTOBJ(m))
          rl_point = INT_INTOBJ(m) - 1;
   }
   if (len > n) {
      n++;
      m = ELM_LIST(res, n);
      if (IS_INTOBJ(m))
          rl_mark = INT_INTOBJ(m) - 1;
   }
   return 0;
}

static Obj FuncBINDKEYSTOGAPHANDLER(Obj self, Obj keys)
{
  Char*  seq;

  if (!IsStringConv(keys)) return False;
  seq = CSTR_STRING(keys);
  rl_bind_keyseq(seq, GAP_rl_func);

  return True;
}

static Obj FuncBINDKEYSTOMACRO(Obj self, Obj keys, Obj macro)
{
  Char   *seq, *macr;

  if (!IsStringConv(keys)) return False;
  if (!IsStringConv(macro)) return False;
  seq = CSTR_STRING(keys);
  macr = CSTR_STRING(macro);
  rl_generic_bind(ISMACR, seq, macr, rl_get_keymap());
  return True;
}

static Obj FuncREADLINEINITLINE(Obj self, Obj line)
{
  Char   *cline;

  if (!IsStringConv(line)) return False;
  cline = CSTR_STRING(line);
  rl_parse_and_bind(cline);
  return True;
}

/* init is needed once */
static Int ISINITREADLINE = 0;
/* a hook function called regularly while waiting on input */
static Int current_rl_fid;
static int charreadhook_rl(void)
{
#ifdef HAVE_SELECT
    if (OnCharReadHookActiveCheck())
        HandleCharReadHook(syBuf[current_rl_fid].fp);
#endif
  return 0;
}

static void initreadline(void)
{

  /* allows users to configure GAP specific settings in their ~/.inputrc like:
       $if GAP
          ....
       $endif                                                             */
  rl_readline_name = "GAP";
  /* this should pipe signals through to GAP  */
  rl_already_prompted = 1 ;

  rl_catch_signals = 0;
  rl_catch_sigwinch = 1;
  /* hook to read from other channels */
  rl_event_hook = 0;
  /* give GAP_rl_func a name that can be used in .inputrc */
  rl_add_defun( "handled-by-GAP", GAP_rl_func, -1 );

  rl_bind_keyseq("\\C-x\\C-g", GAP_set_macro);

  // disable bracketed paste mode by default: it interferes with our handling
  // of pastes of data involving REPL prompts "gap>"
  rl_variable_bind("enable-bracketed-paste", "off");

  CLEFuncs = ELM_REC(GAPInfo, RNamName("CommandLineEditFunctions"));
  KeyHandler = ELM_REC(CLEFuncs, RNamName("KeyHandler"));
  ISINITREADLINE = 1;
}

static Char * readlineFgets(Char * line, UInt length, Int fid, UInt block)
{
  char *                 rlres = (char*)NULL;

  current_rl_fid = fid;
  if (!ISINITREADLINE) initreadline();

  /* read at most as much as we can buffer */
  rl_num_chars_to_read = length-2;
#ifdef HAVE_SELECT
  /* hook to read from other channels */
  rl_event_hook = (OnCharReadHookActiveCheck()) ? charreadhook_rl : 0;
#endif
  /* now do the real work */
  doingReadline = 1;
  rlres = readline(STATE(Prompt));
  doingReadline = 0;
  /* we get a NULL pointer on EOF, say by pressing Ctr-d  */
  if (!rlres) {
    if (!SyCTRD) {
      while (!rlres)
        rlres = readline(STATE(Prompt));
    }
    else {
      printf("\n");fflush(stdout);
      line[0] = '\0';
      return (Char*)0;
    }
  }
  /* maybe add to history, we use key 0 for this function */
  GAP_rl_func(0, 0);
  gap_strlcpy(line, rlres, length);
  // FIXME: handle the case where rlres contains more than length
  // characters better?
  free(rlres);
  gap_strlcat(line, "\n", length);

  /* send the whole line (unclipped) to the window handler               */
  syWinPut( fid, (*line != '\0' ? "@r" : "@x"), line );

  return line;
}

#endif

#ifdef HPCGAP

static GVarDescriptor GVarBeginEdit, GVarEndEdit;

static Int syBeginEdit(Int fid)
{
  Obj func = GVarFunction(&GVarBeginEdit);
  Obj result;
  if (!func)
    return syStartraw(fid);
  result = CALL_1ARGS(func, INTOBJ_INT(fid));
  return result != False && result != Fail && result != INTOBJ_INT(0);
}

static Int syEndEdit(Int fid)
{
  Obj func = GVarFunction(&GVarEndEdit);
  Obj result;
  if (!func) {
    syStopraw(fid);
    return 1;
  }
  result = CALL_1ARGS(func, INTOBJ_INT(fid));
  return result != False && result != Fail && result != INTOBJ_INT(0);
}

#else

#define syBeginEdit(fid)    syStartraw(fid)
#define syEndEdit(fid)      syStopraw(fid)

#endif

static Char * syFgets(Char * line, UInt length, Int fid, UInt block)
{
    Int                 ch,  ch2,  ch3, last;
    Char                * p,  * q,  * r,  * s,  * t;
    static Char         yank [32768];
    Char                old [512],  new [512];
    Int                 oldc,  newc;
    Int                 rep, len;
    Char                buffer [512];
    Int                 rn;
    Int                 rubdel;
    Obj                 linestr, yankstr, args, res;

    /* check file identifier                                               */
    if ( !SyBufInUse(fid) ) {
        return (Char*)0;
    }

    /* no line editing if the file is not '*stdin*' or '*errin*'           */
    if ( fid != 0 && fid != 2 ) {
      p = syFgetsNoEdit(line, length, fid, block);

        return p;
    }

    /* no line editing if the user disabled it
       or we can't make it into raw mode */
    if ( SyLineEdit == 0 || ! syBeginEdit(fid) ) {
        p = syFgetsNoEdit(line, length, fid, block );
        return p;
    }

#ifdef HAVE_LIBREADLINE
    if (SyUseReadline) {
      /* switch back to cooked mode                                          */
      if ( SyLineEdit )
          syEndEdit(fid);

      p = readlineFgets(line, length, fid, block);

      if ( EndLineHook ) Call0ArgsInNewReader( EndLineHook );
      if (!p)
        return p;
      else
        return line;
    }
#endif

    /* In line editing mode 'length' is not allowed bigger than the
      yank buffer (= length of line buffer for input files).*/
    if (length > 32768)
       ErrorQuit("Cannot handle lines with more than 32768 characters in line edit mode.",0,0);

    /* the line starts out blank                                           */
    line[0] = '\0';  p = line;
    for ( q = old; q < old+sizeof(old); ++q )  *q = ' ';
    oldc = 0;
    last = 0;
    ch = 0;
    rubdel=0; /* do we want to east a `del' character? */

    while ( 1 ) {

        /* get a character, handle <ctr>V<chr>, <esc><num> and <ctr>U<num> */
        rep = 1; ch2 = 0;
        do {
            if ( syESCN > 0 ) { if (ch == Esc('N')) {ch = '\n'; syESCN--; }
                                else {ch = Esc('N'); } }
            else if ( syCTRO % 2 == 1 ) { ch = CTR('N'); syCTRO = syCTRO - 1; }
            else if ( syCTRO != 0 ) { ch = CTR('O'); rep = syCTRO / 2; }
            else {
#ifdef HAVE_SELECT
                if (OnCharReadHookActiveCheck())
                    HandleCharReadHook(syBuf[fid].fp);
#endif
              ch = syGetch(fid);
            }
            if ( ch2==0        && ch==CTR('V') ) {             ch2=ch; ch=0;}
            if ( ch2==0        && ch==CTR('[') ) {             ch2=ch; ch=0;}
            if ( ch2==0        && ch==CTR('U') ) {             ch2=ch; ch=0;}
            if ( ch2==CTR('[') && ch==CTR('V') ) { ch2=Esc(CTR('V'));  ch=0;}
            if ( ch2==CTR('[') && IsDigit(ch)  ) { rep=ch-'0'; ch2=ch; ch=0;}
            if ( ch2==CTR('[') && ch=='['      ) {             ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('V') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('[') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('U') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && IsDigit(ch)  ) { rep=ch-'0'; ch2=ch; ch=0;}
            if ( IsDigit(ch2)  && ch==CTR('V') ) {             ch2=ch; ch=0;}
            if ( IsDigit(ch2)  && ch==CTR('[') ) {             ch2=ch; ch=0;}
            if ( IsDigit(ch2)  && ch==CTR('U') ) {             ch2=ch; ch=0;}
            if ( IsDigit(ch2)  && IsDigit(ch)  ) { rep=10*rep+ch-'0';  ch=0;}
            /* get rid of tilde in windows commands */
            if (rubdel==1) {
              if ( ch==126 ) {ch2=0;ch=0;};
              rubdel=0;
            }
        } while ( ch == 0 );
        if ( ch2==CTR('V') )       ch  = CTV(ch);
        if ( ch2==Esc(CTR('V')) )  ch  = CTV(ch | 0x80);
        if ( ch2==CTR('[') )       ch  = Esc(ch);
        if ( ch2==CTR('U') )       rep = 4*rep;
        /* windows keys */
        if ( ch2=='[' && ch=='A')  ch  = CTR('P');
        if ( ch2=='[' && ch=='B')  ch  = CTR('N');
        if ( ch2=='[' && ch=='C')  ch  = CTR('F');
        if ( ch2=='[' && ch=='D')  ch  = CTR('B');
        if ( ch2=='[' && ch=='1') { ch  = CTR('A');rubdel=1;} /* home */
        if ( ch2=='[' && ch=='3') { ch  = CTR('D');rubdel=1;} /* del */
        if ( ch2=='[' && ch=='4') { ch  = CTR('E');rubdel=1;} /* end */
        if ( ch2=='[' && ch=='5') { ch  = CTR('P');rubdel=1;} /* pgup */
        if ( ch2=='[' && ch=='6') { ch  = CTR('N');rubdel=1;} /* pgdwn */

        /* now perform the requested action <rep> times in the input line  */
        while ( rep-- > 0 ) {
          /* check for key handler on GAP level */
          Int runLineEditKeyHandler = 0;
          if (ch >= 0) {
#ifdef HPCGAP
            RegionReadLock(REGION(LineEditKeyHandlers));
#endif
            runLineEditKeyHandler =
                  ch < LEN_PLIST(LineEditKeyHandlers) &&
                  ELM_PLIST(LineEditKeyHandlers, ch + 1) != 0;
#ifdef HPCGAP
            RegionUnlock(REGION(LineEditKeyHandlers));
#endif
          }
          if (runLineEditKeyHandler) {
            /* prepare data for GAP handler:
                   [linestr, ch, ppos, length, yankstr]
               GAP handler must return new
                   [linestr, ppos, yankstr]
               or an integer, interpreted as number of Esc('N')
               calls for the next lines.                                  */
            linestr = MakeString(line);
            yankstr = MakeString(yank);
            args = NEW_PLIST(T_PLIST, 5);
            SET_LEN_PLIST(args, 5);
            SET_ELM_PLIST(args,1,linestr);
            SET_ELM_PLIST(args,2,INTOBJ_INT(ch));
            SET_ELM_PLIST(args,3,INTOBJ_INT((p-line)+1));
            SET_ELM_PLIST(args,4,INTOBJ_INT(length));
            SET_ELM_PLIST(args,5,yankstr);
            res = Call1ArgsInNewReader(LineEditKeyHandler, args);
            if (IS_INTOBJ(res)){
               syESCN = INT_INTOBJ(res);
               ch = Esc('N');
               SET_ELM_PLIST(args,2,INTOBJ_INT(ch));
               res = Call1ArgsInNewReader(LineEditKeyHandler, args);
            }
            if (IS_BAG_REF(res) && IS_LIST(res) && LEN_LIST(res) == 3) {
              linestr = ELM_LIST(res,1);
              len = GET_LEN_STRING(linestr);
              memcpy(line,CONST_CHARS_STRING(linestr),len);
              line[len] = '\0';
              p = line + (INT_INTOBJ(ELM_LIST(res,2)) - 1);
              yankstr = ELM_LIST(res,3);
              len = GET_LEN_STRING(yankstr);
              memcpy(yank,CONST_CHARS_STRING(yankstr),len);
              yank[len] = '\0';
            }
          }
          else {
            switch ( ch ) {

            case CTR('A'): /* move cursor to the start of the line         */
                while ( p > line )  --p;
                break;

            case Esc('B'): /* move cursor one word to the left             */
            case Esc('b'):
                if ( p > line ) do {
                    --p;
                } while ( p>line && (!IS_SEP(*(p-1)) || IS_SEP(*p)));
                break;

            case CTR('B'): /* move cursor one character to the left        */
                if ( p > line )  --p;
                break;

            case CTR('F'): /* move cursor one character to the right       */
                if ( *p != '\0' )  ++p;
                break;

            case Esc('F'): /* move cursor one word to the right            */
            case Esc('f'):
                if ( *p != '\0' ) do {
                    ++p;
                } while ( *p!='\0' && (IS_SEP(*(p-1)) || !IS_SEP(*p)));
                break;

            case CTR('E'): /* move cursor to the end of the line           */
                while ( *p != '\0' )  ++p;
                break;

            case CTR('H'): /* delete the character left of the cursor      */
            case 127:
                if ( p == line ) break;
                --p;
                /* let '<ctr>-D' do the work                               */

            case CTR('D'): /* delete the character at the cursor           */
                           /* on an empty line '<ctr>-D' is <eof>          */
                if ( p == line && *p == '\0' && SyCTRD && !rubdel ) {
                    ch = EOF; rep = 0; break;
                }
                if ( *p != '\0' ) {
                    for ( q = p; *(q+1) != '\0'; ++q )
                        *q = *(q+1);
                    *q = '\0';
                }
                break;

            case CTR('X'): /* delete the line                              */
                p = line;
                /* let '<ctr>-K' do the work                               */

            case CTR('K'): /* delete to end of line                        */
                if ( last!=CTR('X') && last!=CTR('K') && last!=Esc(127)
                  && last!=Esc('D') && last!=Esc('d') )  yank[0] = '\0';
                for ( r = yank; *r != '\0'; ++r ) ;
                for ( s = p; *s != '\0'; ++s )  r[s-p] = *s;
                r[s-p] = '\0';
                *p = '\0';
                break;

            case Esc(127): /* delete the word left of the cursor           */
                q = p;
                if ( p > line ) do {
                    --p;
                } while ( p>line && (!IS_SEP(*(p-1)) || IS_SEP(*p)));
                if ( last!=CTR('X') && last!=CTR('K') && last!=Esc(127)
                  && last!=Esc('D') && last!=Esc('d') )  yank[0] = '\0';
                for ( r = yank; *r != '\0'; ++r ) ;
                for ( ; yank <= r; --r )  r[q-p] = *r;
                for ( s = p; s < q; ++s )  yank[s-p] = *s;
                for ( r = p; *q != '\0'; ++q, ++r )
                    *r = *q;
                *r = '\0';
                break;

            case Esc('D'): /* delete the word right of the cursor          */
            case Esc('d'):
                q = p;
                if ( *q != '\0' ) do {
                    ++q;
                } while ( *q!='\0' && (IS_SEP(*(q-1)) || !IS_SEP(*q)));
                if ( last!=CTR('X') && last!=CTR('K') && last!=Esc(127)
                  && last!=Esc('D') && last!=Esc('d') )  yank[0] = '\0';
                for ( r = yank; *r != '\0'; ++r ) ;
                for ( s = p; s < q; ++s )  r[s-p] = *s;
                r[s-p] = '\0';
                for ( r = p; *q != '\0'; ++q, ++r )
                    *r = *q;
                *r = '\0';
                break;

            case CTR('T'): /* twiddle characters                           */
                if ( p == line )  break;
                if ( *p == '\0' )  --p;
                if ( p == line )  break;
                ch2 = *(p-1);  *(p-1) = *p;  *p = ch2;
                ++p;
                break;

            case CTR('Y'): /* insert (yank) deleted text                   */
                if (strlen(yank) + strlen(line) - 2 > length) {
                    syEchoch(CTR('G'), fid);
                    break;
                }
                for ( r = yank; *r != '\0' && *r != '\n'; ++r ) {
                    ch2 = *r;
                    for ( q = p; ch2; ++q ) {
                        ch3 = *q; *q = ch2; ch2 = ch3;
                    }
                    *q = '\0'; ++p;
                }
                break;

            case Esc('U'): /* uppercase word                               */
            case Esc('u'):
                if ( *p != '\0' ) do {
                    if ('a' <= *p && *p <= 'z')  *p = *p + 'A' - 'a';
                    ++p;
                } while ( *p!='\0' && (IS_SEP(*(p-1)) || !IS_SEP(*p)));
                break;

            case Esc('C'): /* capitalize word                              */
            case Esc('c'):
                while ( *p!='\0' && IS_SEP(*p) )  ++p;
                if ( 'a' <= *p && *p <= 'z' )  *p = *p + 'A'-'a';
                if ( *p != '\0' ) ++p;
                /* lowercase rest of the word                              */

            case Esc('L'): /* lowercase word                               */
            case Esc('l'):
                if ( *p != '\0' ) do {
                    if ('A' <= *p && *p <= 'Z')  *p = *p + 'a' - 'A';
                    ++p;
                } while ( *p!='\0' && (IS_SEP(*(p-1)) || !IS_SEP(*p)));
                break;

            case Esc(CTR('L')): /* repaint input line                      */
                syEchoch('\n',fid);
                for ( q = syPrompt; q < syPrompt+syNrchar; ++q )
                    syEchoch( *q, fid );
                for ( q = old; q < old+sizeof(old); ++q )  *q = ' ';
                oldc = 0;
                break;

            case EOF:     /* end of file on input                          */
                break;

            case CTR('M'): /* (same as '\r', '\n') append \n and exit      */
            case CTR('J'):
                while ( *p != '\0' )  ++p;
                *p++ = '\n'; *p = '\0';
                rep = 0;
                break;

            case CTR('O'): /* accept line, perform '<ctr>-N' next time     */
                while ( *p != '\0' )  ++p;
                *p++ = '\n'; *p = '\0';
                syCTRO = 2 * rep + 1;
                rep = 0;
                break;

            case CTR('I'): /* try to complete the identifier before dot    */
                if ( p == line || IS_SEP(p[-1]) ) {
                  /* If we don't have an identifier to complete, insert a tab */
                    ch2 = ch & 0xff;
                    for ( q = p; ch2; ++q ) {
                        ch3 = *q; *q = ch2; ch2 = ch3;
                    }
                    *q = '\0'; ++p;
                }
                else {
  /* Here is actually a bug, because it is not checked if the results
     leaves 'line' shorter than 'length'. But we ignore this problem
     assuming that interactive input lines are much shorter than
     32768 characters.                                                       */

                  /* Locate in q the current identifier */
                    if ( (q = p) > line ) do {
                        --q;
                    } while ( q>line && (!IS_SEP(*(q-1)) || IS_SEP(*q)));

                    /* determine if the thing immediately before the
                       current identifier is a . */
                    rn = (line < q && *(q-1) == '.'
                                   && (line == q-1 || *(q-2) != '.'));

                    /* Copy the current identifier into buffer */
                    r = buffer;  s = q;
                    while ( s < p )  *r++ = *s++;
                    *r = '\0';

                    if ( (rn ? iscomplete_rnam( buffer, p-q )
                          : iscomplete_gvar( buffer, p-q )) ) {
                      /* Complete already, just beep for single tab */
                      if ( last != CTR('I') )
                        syEchoch( CTR('G'), fid );
                      else {

                        /* Double tab after a complete identifier
                           print list of completions */
                        syWinPut( fid, "@c", "" );
                        syEchos( "\n    ", fid );
                        syEchos( buffer, fid );
                        while ( (rn ? completion_rnam( buffer, p-q )
                                 : completion_gvar( buffer, p-q )) ) {
                          syEchos( "\n    ", fid );
                          syEchos( buffer, fid );
                        }
                        syEchos( "\n", fid );

                        /* Reprint the prompt and input line so far */
                        for ( q=syPrompt; q<syPrompt+syNrchar; ++q )
                          syEchoch( *q, fid );
                        for ( q = old; q < old+sizeof(old); ++q )
                          *q = ' ';
                        oldc = 0;
                        syWinPut( fid, (fid == 0 ? "@i" : "@e"), "" );
                      }
                    }
                    else if ( (rn ? ! completion_rnam( buffer, p-q )
                                  : ! completion_gvar( buffer, p-q )) ) {

                      /* Not complete, and there are no completions */
                        if ( last != CTR('I') )

                          /* beep after 1 tab */
                            syEchoch( CTR('G'), fid );
                        else {

                          /* print a message otherwise */
                          syWinPut( fid, "@c", "" );
                          syEchos("\n    identifier has no completions\n",
                                  fid);
                          for ( q=syPrompt; q<syPrompt+syNrchar; ++q )
                            syEchoch( *q, fid );
                          for ( q = old; q < old+sizeof(old); ++q )
                            *q = ' ';
                          oldc = 0;
                          syWinPut( fid, (fid == 0 ? "@i" : "@e"), "" );
                        }
                    }
                    else {

                      /*not complete and we have a completion. Now we have to
                        find the longest common prefix of all the completions*/

                        t = p;

                      /* Insert the necessary part of the current completion */
                        for ( s = buffer+(p-q); *s != '\0'; s++ ) {

                      /* Insert character from buffer into the line, I think */
                            ch2 = *s;
                            for ( r = p; ch2; r++ ) {
                                ch3 = *r; *r = ch2; ch2 = ch3;
                            }
                            *r = '\0'; p++;
                        }

                        /* Now we work through the alternative
                           completions reducing p, each time to point
                           just after the longest common stem t
                           meanwhile still points to the place where
                           we started this batch of completion, so if
                           p gets down to t, we have nothing
                           unambiguous to add */

                        while ( t < p
                             && (rn ? completion_rnam( buffer, t-q )
                                    : completion_gvar( buffer, t-q )) ) {

                          /* check the length of common prefix */
                            r = t;  s = buffer+(t-q);
                            while ( r < p && *r == *s ) {
                                r++; s++;
                            }
                            s = p;  p = r;

                            /* Now close up over the part of the
                               completion which turned out to be
                               ambiguous */
                            while ( *s != '\0' )  *r++ = *s++;
                            *r = '\0';
                        }

                        /* OK, now we have done the largest possible completion.
                           If it was nothing then we can't complete. Deal appropriately */
                        if ( t == p ) {
                            if ( last != CTR('I') )
                                syEchoch( CTR('G'), fid );
                            else {
                                syWinPut( fid, "@c", "" );
                                buffer[t-q] = '\0';
                                while (
                                  (rn ? completion_rnam( buffer, t-q )
                                      : completion_gvar( buffer, t-q )) ) {
                                    syEchos( "\n    ", fid );
                                    syEchos( buffer, fid );
                                }
                                syEchos( "\n", fid );
                                for ( q=syPrompt; q<syPrompt+syNrchar; ++q )
                                    syEchoch( *q, fid );
                                for ( q = old; q < old+sizeof(old); ++q )
                                    *q = ' ';
                                oldc = 0;
                                syWinPut( fid, (fid == 0 ? "@i" : "@e"), "");
                            }
                        }

                      /* If we managed to do some completion then we're happy */
                    }
                }
                break;

            default:      /* default, insert normal character              */
                ch2 = ch & 0xff;
                for ( q = p; ch2; ++q ) {
                    ch3 = *q; *q = ch2; ch2 = ch3;
                }
                *q = '\0'; ++p;
                break;

            } /* switch ( ch ) */
          } /* key handler hook */
          last = ch;
        }

        if ( ch==EOF || ch=='\n' || ch=='\r' || ch==CTR('O') ) {
            /* if there is a hook for line ends, call it before echoing */
            if ( EndLineHook ) Call0ArgsInNewReader( EndLineHook );
            syEchoch('\r',fid);  syEchoch('\n',fid);  break;
        }

        /* now update the screen line according to the differences         */
        for ( q = line, r = new, newc = 0; *q != '\0'; ++q ) {
            if ( q == p )  newc = r-new;
            if ( *q==CTR('I') )  { do *r++=' '; while ((r-new+syNrchar)%8); }
            else if ( *q==0x7F ) { *r++ = '^'; *r++ = '?'; }
            else if ( /* '\0'<=*q  && */*q<' '  ) { *r++ = '^'; *r++ = *q+'@'; }
            else if ( ' ' <=*q && *q<0x7F ) { *r++ = *q; }
            else {
                *r++ = '\\';                 *r++ = '0'+*(UChar*)q/64%4;
                *r++ = '0'+*(UChar*)q/8 %8;  *r++ = '0'+*(UChar*)q   %8;
            }
            if ( r >= new+SyNrCols-syNrchar-2 ) {
                if ( q >= p ) { q++; break; }
                new[0] = '$';   new[1] = r[-5]; new[2] = r[-4];
                new[3] = r[-3]; new[4] = r[-2]; new[5] = r[-1];
                r = new+6;
            }
        }
        if ( q == p )  newc = r-new;
        for (      ; r < new+sizeof(new); ++r )  *r = ' ';
        if ( q[0] != '\0' && q[1] != '\0' )
            new[SyNrCols-syNrchar-2] = '$';
        else if ( q[1] == '\0' && ' ' <= *q && *q < 0x7F )
            new[SyNrCols-syNrchar-2] = *q;
        else if ( q[1] == '\0' && q[0] != '\0' )
            new[SyNrCols-syNrchar-2] = '$';
        for ( q = old, r = new; r < new+sizeof(new); ++r, ++q ) {
            if ( *q == *r )  continue;
            while (oldc<(q-old)) { syEchoch(old[oldc],fid);  ++oldc; }
            while (oldc>(q-old)) { syEchoch('\b',fid);       --oldc; }
            *q = *r;  syEchoch( *q, fid ); ++oldc;
        }
        while ( oldc < newc ) { syEchoch(old[oldc],fid);  ++oldc; }
        while ( oldc > newc ) { syEchoch('\b',fid);       --oldc; }


    }

    if (line[1] != '\0') {
      /* Now we put the new string into the history,
         we use key handler with key 0 to update the command line history */
      linestr = MakeString(line);
      args = NEW_PLIST(T_PLIST, 5);
      SET_LEN_PLIST(args, 5);
      SET_ELM_PLIST(args, 1, linestr);
      SET_ELM_PLIST(args, 2, INTOBJ_INT(0));
      SET_ELM_PLIST(args, 3, INTOBJ_INT(1));
      SET_ELM_PLIST(args, 4, INTOBJ_INT(length));
      SET_ELM_PLIST(args, 5, linestr);
      Call1ArgsInNewReader(LineEditKeyHandler, args);
    }

    /* send the whole line (unclipped) to the window handler               */
    syWinPut( fid, (*line != '\0' ? "@r" : "@x"), line );

    /* switch back to cooked mode                                          */
    if ( SyLineEdit == 1 )
        syEndEdit(fid);

    /* return the line (or '0' at end-of-file)                             */
    if ( *line == '\0' )
        return (Char*)0;
    return line;
}

Char * SyFgets (
    Char *              line,
    UInt                length,
    Int                 fid)
{
  return syFgets( line, length, fid, 1);
}


Char *SyFgetsSemiBlock (
    Char *              line,
    UInt                length,
    Int                 fid)
{
  return syFgets( line, length, fid, 0);
}


/****************************************************************************
**
*F * * * * * * * * * * * * system error messages  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  SyLastErrorNo . . . . . . . . . . . . . . . . . . . . . last error number
*/
Int SyLastErrorNo;


/****************************************************************************
**
*V  SyLastErrorMessage  . . . . . . . . . . . . . . . . .  last error message
*/
Char SyLastErrorMessage [ 1024 ];


/****************************************************************************
**
*F  SyClearErrorNo()  . . . . . . . . . . . . . . . . .  clear error messages
*/

void SyClearErrorNo ( void )
{
    errno = 0;
    SyLastErrorNo = 0;
    strxcpy( SyLastErrorMessage, "no error", sizeof(SyLastErrorMessage) );
}


/****************************************************************************
**
*F  SySetErrorNo()  . . . . . . . . . . . . . . . . . . . . set error message
*/

void SySetErrorNo ( void )
{
    const Char *        err;

    if ( errno != 0 ) {
        SyLastErrorNo = errno;
        err = strerror(errno);
        strxcpy( SyLastErrorMessage, err, sizeof(SyLastErrorMessage) );
    }
    else {
        SyClearErrorNo();
    }
}

/****************************************************************************
**
*F * * * * * * * * * * * * * file and execution * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  SyExecuteProcess( <dir>, <prg>, <in>, <out>, <args> ) . . . . new process
**
**  Start  <prg> in  directory <dir>  with  standard input connected to <in>,
**  standard  output  connected to <out>   and arguments.  No  path search is
**  performed, the return  value of the process  is returned if the operation
**  system supports such a concept.
*/


/****************************************************************************
**
*f  SyExecuteProcess( <dir>, <prg>, <in>, <out>, <args> )
*/
#if defined(HAVE_FORK) || defined(HAVE_VFORK)

#ifndef WEXITSTATUS
# define WEXITSTATUS(stat_val) ((unsigned)(stat_val) >> 8)
#endif
#ifndef WIFEXITED
# define WIFEXITED(stat_val) (((stat_val) & 255) == 0)
#endif

#ifdef SYS_IS_CYGWIN32

UInt SyExecuteProcess (
    Char *                  dir,
    Char *                  prg,
    Int                     in,
    Int                     out,
    Char *                  args[] )
{
    int savestdin, savestdout;
    Int tin, tout;
    int res;

    /* change the working directory                                    */
    if ( chdir(dir) == -1 ) return -1;

    /* if <in> is -1 open "/dev/null"                                  */
    if ( in == -1 )
        tin = open( "/dev/null", O_RDONLY );
    else
        tin = SyBufFileno(in);
    if ( tin == -1 )
        return -1;

    /* if <out> is -1 open "/dev/null"                                 */
    if ( out == -1 )
        tout = open( "/dev/null", O_WRONLY );
    else
        tout = SyBufFileno(out);
    if ( tout == -1 ) {
        if (in == -1) close(tin);
        return -1;
    }

    /* set standard input to <in>, standard output to <out>            */
    savestdin = -1;   /* Just to please the compiler */
    if ( tin != 0 ) {
        savestdin = dup(0);
        if (savestdin == -1 || dup2(tin,0) == -1) {
            if (out == -1) close(tout);
            if (in == -1) close(tin);
            return -1;
        }
        fcntl( 0, F_SETFD, 0 );
    }

    if ( tout != 1 ) {
        savestdout = dup(1);
        if (savestdout == -1 || dup2( tout, 1 ) == -1) {
            if (tin != 0) {
                close(0);
                dup2(savestdin,0);
                close(savestdin);
            }
            if (out == -1) close(tout);
            if (in == -1) close(tin);
            return -1;
        }
        fcntl( 1, F_SETFD, 0 );
    }

    FreezeStdin = 1;
    /* now try to execute the program                                  */
    res = spawnve( _P_WAIT, prg, (const char * const *) args,
                                 (const char * const *) environ );

    /* Now repair the open file descriptors: */
    if (tout != 1) {
        close(1);
        dup2(savestdout,1);
        close(savestdout);
    }
    if (tin != 0) {
        close(0);
        dup2(savestdin,0);
        close(savestdin);
    }
    if (out == -1) close(tout);
    if (in == -1) close(tin);

    FreezeStdin = 0;

    /* Report result: */
    if (res < 0) return -1;
    return WEXITSTATUS(res);
}

#else

static void NullSignalHandler(int scratch)
{
}

UInt SyExecuteProcess (
    Char *                  dir,
    Char *                  prg,
    Int                     in,
    Int                     out,
    Char *                  args[] )
{
    pid_t                   pid;                    /* process id          */
    pid_t                   wait_pid;
    int                     status;                 /* do not use `Int'    */
    Int                     tin;                    /* temp in             */
    Int                     tout;                   /* temp out            */
    sig_handler_t           * volatile func2;


    /* turn off the SIGCHLD handling, so that we can be sure to collect this child
       `After that, we call the old signal handler, in case any other children have died in the
       meantime. This resets the handler */

    func2 = signal( SIGCHLD, SIG_DFL );

    /* This may return SIG_DFL (0x0) or SIG_IGN (0x1) if the previous handler
     * was set to the default or 'ignore'. In these cases (or if SIG_ERR is
     * returned), just use a null signal hander - the default on most systems
     * is to do nothing */
    if (func2 == SIG_ERR || func2 == SIG_DFL || func2 == SIG_IGN)
      func2 = &NullSignalHandler;

    /* clone the process                                                   */
    pid = fork();
    if ( pid == -1 ) {
        return -1;
    }

    /* we are the parent                                                   */
    if ( pid != 0 ) {
        // Stop trying to read input
        FreezeStdin = 1;

        /* ignore a CTRL-C                                                 */
        struct sigaction sa;
        struct sigaction oldsa;

        sa.sa_handler = SIG_IGN;
        sigemptyset(&(sa.sa_mask));
        sa.sa_flags = 0;
        sigaction(SIGINT, &sa, &oldsa);

        /* wait for some action                                            */
        wait_pid = waitpid( pid, &status, 0 );
        FreezeStdin = 0;
        sigaction(SIGINT, &oldsa, NULL);
        (*func2)(SIGCHLD);
        if ( wait_pid == -1 ) {
            return -1;
        }
        if ( WIFSIGNALED(status) ) {
            return -1;
        }
        return WEXITSTATUS(status);
    }

    /* we are the child                                                    */
    else {

        /* change the working directory                                    */
        if ( chdir(dir) == -1 ) {
            _exit(-1);
        }

        /* if <in> is -1 open "/dev/null"                                  */
        if ( in == -1 ) {
            tin = open( "/dev/null", O_RDONLY );
        }
        else {
            tin = SyBufFileno(in);
        }
        if ( tin == -1 ) {
            _exit(-1);
        }

        /* if <out> is -1 open "/dev/null"                                 */
        if ( out == -1 ) {
            tout = open( "/dev/null", O_WRONLY );
        }
        else {
            tout = SyBufFileno(out);
        }
        if ( tout == -1 ) {
            _exit(-1);
        }

        /* set standard input to <in>, standard output to <out>            */
        if ( tin != 0 ) {
            if ( dup2( tin, 0 ) == -1 ) {
                _exit(-1);
            }
        }
        fcntl( 0, F_SETFD, 0 );

        if ( tout != 1 ) {
            if ( dup2( tout, 1 ) == -1 ) {
                _exit(-1);
            }
        }
        fcntl( 1, F_SETFD, 0 );

        /* now try to execute the program                                  */
        execve( prg, args, environ );
        _exit(-1);
    }

    /* this should not happen                                              */
    return -1;
}
#endif

#endif


/****************************************************************************
**
*F  SyIsExistingFile( <name> )  . . . . . . . . . . . does file <name> exists
**
**  'SyIsExistingFile' returns 1 if the  file <name> exists and 0  otherwise.
**  It does not check if the file is readable, writable or excuteable. <name>
**  is a system dependent description of the file.
*/
Int SyIsExistingFile ( const Char * name )
{
    Int         res;

    SyClearErrorNo();
    res = access( name, F_OK );
    if ( res == -1 ) {
        SySetErrorNo();
    }
    return res;
}

/****************************************************************************
**
*F  SyIsReadableFile( <name> )  . . . . . . . . . . . is file <name> readable
**
**  'SyIsReadableFile'   returns 0  if the   file  <name> is   readable and
**  -1 otherwise. <name> is a system dependent description of the file.
*/
Int SyIsReadableFile ( const Char * name )
{
    Int         res;
    Char        xname[1024];

    SyClearErrorNo();
    res = access( name, R_OK );
    if ( res == -1 ) {
      /* we might be able to read the file via zlib */

      /* beware of buffer overflows */
      if ( gap_strlcpy(xname, name, sizeof(xname)) < sizeof(xname) &&
            gap_strlcat(xname, ".gz", sizeof(xname))  < sizeof(xname) ) {
        res = access(xname, R_OK);
      }

      if (res == -1)
        SySetErrorNo();
    }
    return res;
}


/****************************************************************************
**
*F  SyIsWritableFile( <name> )  . . . . . . . . . is the file <name> writable
**
**  'SyIsWritableFile'   returns  1  if  the  file  <name> is  writable and 0
**  otherwise. <name> is a system dependent description of the file.
*/
Int SyIsWritableFile ( const Char * name )
{
    Int         res;

    SyClearErrorNo();
    res = access( name, W_OK );
    if ( res == -1 ) {
        SySetErrorNo();
    }
    return res;
}


/****************************************************************************
**
*F  SyIsExecutableFile( <name> )  . . . . . . . . . is file <name> executable
**
**  'SyIsExecutableFile' returns 1 if the  file <name>  is  executable and  0
**  otherwise. <name> is a system dependent description of the file.
*/
Int SyIsExecutableFile ( const Char * name )
{
    Int         res;

    SyClearErrorNo();
    res = access( name, X_OK );
    if ( res == -1 ) {
        SySetErrorNo();
    }
    return res;
}


/****************************************************************************
**
*F  SyIsDirectoryPath( <name> ) . . . . . . . . .  is file <name> a directory
**
**  'SyIsDirectoryPath' returns 1 if the  file <name>  is a directory  and  0
**  otherwise. <name> is a system dependent description of the file.
*/
Int SyIsDirectoryPath ( const Char * name )
{
    struct stat     buf;                /* buffer for `stat'               */

    SyClearErrorNo();
    if ( stat( name, &buf ) == -1 ) {
        SySetErrorNo();
        return -1;
    }
    return S_ISDIR(buf.st_mode) ? 0 : -1;
}


/****************************************************************************
**
*F  SyRemoveFile( <name> )  . . . . . . . . . . . . . . .  remove file <name>
*/
Int SyRemoveFile ( const Char * name )
{
    Int res;
    SyClearErrorNo();
    res = unlink(name);
    if (res == -1)
       SySetErrorNo();
    return res;
}

/****************************************************************************
**
*f  SyMkdir( <name> )  . . . . . . . . . . . . . . . . create directory
**  with users umask permissions.
*/
Int SyMkdir ( const Char * name )
{
    Int res;
    SyClearErrorNo();
    res = mkdir(name, 0777);
    if (res == -1)
       SySetErrorNo();
    return res;
}

/****************************************************************************
**
*f  SyRemoveDir( <name> )  . . . . . . . . . . . . . . . . .  using `rmdir'
*/
Int SyRmdir ( const Char * name )
{
    Int res;
    SyClearErrorNo();
    res = rmdir(name);
    if (res == -1)
       SySetErrorNo();
    return res;
}

/****************************************************************************
**
*F  SyIsDir( <name> )  . . . . . . . . . . . . .  test if something is a dir
**
**  Returns 'F' for a regular file, 'L' for a symbolic link and 'D'
**  for a real directory, 'C' for a character device, 'B' for a block
**  device 'P' for a FIFO (named pipe) and 'S' for a socket.
*/
Obj SyIsDir ( const Char * name )
{
  Int res;
  struct stat ourlstatbuf;

  res = lstat(name,&ourlstatbuf);
  if (res < 0) {
    SySetErrorNo();
    return Fail;
  }
  if      (S_ISREG(ourlstatbuf.st_mode)) return ObjsChar['F'];
  else if (S_ISDIR(ourlstatbuf.st_mode)) return ObjsChar['D'];
  else if (S_ISLNK(ourlstatbuf.st_mode)) return ObjsChar['L'];
#ifdef S_ISCHR
  else if (S_ISCHR(ourlstatbuf.st_mode)) return ObjsChar['C'];
#endif
#ifdef S_ISBLK
  else if (S_ISBLK(ourlstatbuf.st_mode)) return ObjsChar['B'];
#endif
#ifdef S_ISFIFO
  else if (S_ISFIFO(ourlstatbuf.st_mode)) return ObjsChar['P'];
#endif
#ifdef S_ISSOCK
  else if (S_ISSOCK(ourlstatbuf.st_mode)) return ObjsChar['S'];
#endif
  else return ObjsChar['?'];
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * directories  * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  SyReadStringFile( <fid> ) . . . . . . . . read file content into a string
**
*/
static Obj SyReadStringFile(Int fid)
{
    Char            buf[32769];
    Int             ret, len;
    UInt            lstr;
    Obj             str;

    /* read <fid> until we see  eof   (in 32kB pieces)                     */
    str = NEW_STRING(0);
    len = 0;
    do {
        ret = SyRead(fid, buf, 32768);
        if (ret < 0) {
            SySetErrorNo();
            return Fail;
        }
        len += ret;
        GROW_STRING( str, len );
        lstr = GET_LEN_STRING(str);
        memcpy( CHARS_STRING(str)+lstr, buf, ret );
        *(CHARS_STRING(str)+lstr+ret) = '\0';
        SET_LEN_STRING(str, lstr+ret);
    } while(ret > 0);

    /* fix the length of <str>                                             */
    len = GET_LEN_STRING(str);
    ResizeBag( str, SIZEBAG_STRINGLEN(len) );

    syBuf[fid].ateof = TRUE;
    return str;
}

#if !defined(SYS_IS_CYGWIN32)
/* fstat seems completely broken under CYGWIN */
/* first try to get the whole file as one chunk, this avoids garbage
   collections because of the GROW_STRING calls below    */
static Obj SyReadStringFileStat(Int fid)
{
    Int             ret, len;
    Obj             str;
    Int             l;
    char            *ptr;
    struct stat     fstatbuf;

    GAP_ASSERT(syBuf[fid].type != gzip_socket);

    if( fstat( syBuf[fid].fp, &fstatbuf) == 0 ) {
        if((off_t)(Int)fstatbuf.st_size != fstatbuf.st_size) {
            ErrorMayQuit(
                "The file is too big to fit the current workspace",
                (Int)0, (Int)0);
        }
        len = (Int) fstatbuf.st_size;
        str = NEW_STRING( len );
        CHARS_STRING(str)[len] = '\0';
        SET_LEN_STRING(str, len);
        ptr = CSTR_STRING(str);
        while (len > 0) {
            l = (len > 1048576) ? 1048576 : len;
            ret = SyRead(fid, ptr, l);
            if (ret == -1) {
                SySetErrorNo();
                return Fail;
            }
            len -= ret;
            ptr += ret;
        }
        syBuf[fid].ateof = TRUE;
        return str;
    } else {
        SySetErrorNo();
        return Fail;
    }
}
#endif

Obj SyReadStringFid(Int fid)
{
#if !defined(SYS_IS_CYGWIN32)
    if (syBuf[fid].type == raw_socket) {
        return SyReadStringFileStat(fid);
    }
#endif
    return SyReadStringFile(fid);
}


#ifdef USE_CUSTOM_MEMMOVE
// The memmove in glibc on 32-bit SSE2 systems, contained in
// __memmove_sse2_unaligned, is buggy in at least versions
// 2.21 - 2.26 when crossing the 2GB boundary, so GAP must
// include its own simple memmove implementation.
void * SyMemmove(void * dst, const void * src, UInt size)
{
    char *       d = dst;
    const char * s = src;

    if ((d == s) || (size == 0))
        return dst;

    if (d + size < s || d > s + size) {
        memcpy(dst, src, size);
    }
    else if (d > s) {
        d = d + (size - 1);
        s = s + (size - 1);

        // This is about 4x slower than glibc, but
        // is simple and also complicated enough that
        // gcc or clang seem unable to "optimise" it back
        // into a call to memmove.

        // Do size 4 jumps
        while (size > 4) {
            *d = *s;
            *(d - 1) = *(s - 1);
            *(d - 2) = *(s - 2);
            *(d - 3) = *(s - 3);
            d -= 4;
            s -= 4;
            size -= 4;
        }
        // Finish
        while (size > 0) {
            *d-- = *s--;
            size--;
        }
    }
    else {
        while (size > 4) {
            *d = *s;
            *(d + 1) = *(s + 1);
            *(d + 2) = *(s + 2);
            *(d + 3) = *(s + 3);
            d += 4;
            s += 4;
            size -= 4;
        }
        // Finish
        while (size > 0) {
            *d++ = *s++;
            size--;
        }
    }
    return dst;
}
#endif


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(CrcString, string),
#ifdef HAVE_LIBREADLINE
    GVAR_FUNC_1ARGS(BINDKEYSTOGAPHANDLER, keyseq),
    GVAR_FUNC_2ARGS(BINDKEYSTOMACRO, keyseq, macro),
    GVAR_FUNC_1ARGS(READLINEINITLINE, line),
#endif

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

// This function is called by 'InitSystem', before the usual module
// initialization.
void InitSysFiles(void)
{
    memset(syBuffers, 0, sizeof(syBuf));

    memset(syBuf, 0, sizeof(syBuf));

    // open the standard files
    struct stat stat_in, stat_out, stat_err;
    fstat(fileno(stdin), &stat_in);
    fstat(fileno(stdout), &stat_out);
    fstat(fileno(stderr), &stat_err);

    // set up stdin
    syBuf[0].type = raw_socket;
    syBuf[0].fp = fileno(stdin);
    syBuf[0].echo = fileno(stdout);
    syBuf[0].bufno = -1;
    syBuf[0].isTTY = isatty(fileno(stdin));
    if (syBuf[0].isTTY) {
        // if stdin is on a terminal, make sure stdout in on the same terminal
        if (stat_in.st_dev != stat_out.st_dev ||
            stat_in.st_ino != stat_out.st_ino)
            syBuf[0].echo = open(ttyname(fileno(stdin)), O_WRONLY);
    }

    // set up stdout
    syBuf[1].type = raw_socket;
    syBuf[1].echo = syBuf[1].fp = fileno(stdout);
    syBuf[1].bufno = -1;
    syBuf[1].isTTY = isatty(fileno(stdout));

    // set up errin (defaults to stdin, unless stderr is on a terminal)
    syBuf[2].type = raw_socket;
    syBuf[2].fp = fileno(stdin);
    syBuf[2].echo = fileno(stderr);
    syBuf[2].bufno = -1;
    syBuf[2].isTTY = isatty(fileno(stderr));
    if (syBuf[2].isTTY) {
        // if stderr is on a terminal, make sure errin in on the same terminal
        if (stat_in.st_dev != stat_err.st_dev ||
            stat_in.st_ino != stat_err.st_ino)
            syBuf[2].fp = open(ttyname(fileno(stderr)), O_RDONLY);
    }

    // set up errout
    syBuf[3].type = raw_socket;
    syBuf[3].echo = syBuf[3].fp = fileno(stderr);
    syBuf[3].bufno = -1;

    // turn off buffering
    setbuf(stdin, (char *)0);
    setbuf(stdout, (char *)0);
    setbuf(stderr, (char *)0);

#ifdef HAVE_LIBREADLINE
    if (SyUseReadline) {
        rl_readline_name = "GAP";
        rl_initialize();
    }
#endif
}

/* TODO: Should probably do some checks preSave for open files etc and refuse to save
   if any are found */

/****************************************************************************
**
*F  InitKernel( <module> ) . . . . . . .  initialise kernel data structures
*/

static Int InitKernel(
      StructInitInfo * module )
{
  /* init filters and functions                                          */
  InitHdlrFuncsFromTable( GVarFuncs );

  /* line edit key handler from library                                  */
  ImportGVarFromLibrary("GAPInfo", &GAPInfo);
  ImportFuncFromLibrary("LineEditKeyHandler", &LineEditKeyHandler);
  ImportGVarFromLibrary("LineEditKeyHandlers", &LineEditKeyHandlers);

#ifdef HPCGAP
  /* GAP hooks to allow library to override how we start/stop raw mode   */
  DeclareGVar(&GVarBeginEdit, "TERMINAL_BEGIN_EDIT");
  DeclareGVar(&GVarEndEdit, "TERMINAL_END_EDIT");
#endif

#ifdef HAVE_SELECT
    InitCopyGVar("OnCharReadHookActive",&OnCharReadHookActive);
    InitCopyGVar("OnCharReadHookInFds",&OnCharReadHookInFds);
    InitCopyGVar("OnCharReadHookInFuncs",&OnCharReadHookInFuncs);
    InitCopyGVar("OnCharReadHookOutFds",&OnCharReadHookOutFds);
    InitCopyGVar("OnCharReadHookOutFuncs",&OnCharReadHookOutFuncs);
    InitCopyGVar("OnCharReadHookExcFds",&OnCharReadHookExcFds);
    InitCopyGVar("OnCharReadHookExcFuncs",&OnCharReadHookExcFuncs);
#endif


  return 0;

}

/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/

static Int InitLibrary(
      StructInitInfo * module )
{
  /* init filters and functions                                          */
  InitGVarFuncsFromTable( GVarFuncs );

  return 0;
}

/****************************************************************************
**
*F  InitInfoSysFiles()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "sysfiles",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoSysFiles ( void )
{
    return &module;
}
