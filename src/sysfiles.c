/****************************************************************************
**
*W  sysfiles.c                  GAP source                       Frank Celler
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  The  files  "system.c" and  "sysfiles.c"   contain  all operating  system
**  dependent functions.  File and  stream operations are implemented in this
**  files, all the other system dependent functions in "system.c".  There are
**  various  labels determine which operating  system is  actually used, they
**  are described in "system.c".
*/
char * Revision_sysfiles_c =
   "@(#)$Id$";


#include        "system.h"               /* system dependent stuff          */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TNUM_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#define INCLUDE_DECLARATION_PART
#include        "sysfiles.h"             /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "lists.h"               /* LEN_LIST, ELM_LIST, ShallowCopy */

#include        "plist.h"               /* LEN_PLIST, SET_LEN_PLIST,   ... */
#include        "string.h"              /* IsString                        */


#ifndef SYS_HAS_STDIO_PROTO             /* ANSI/TRAD decl. from H&S 15     */
extern FILE * fopen ( SYS_CONST char *, SYS_CONST char * );
extern int    fclose ( FILE * );
extern void   setbuf ( FILE *, char * );
extern char * fgets ( char *, int, FILE * );
extern int    fputs ( SYS_CONST char *, FILE * );
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * * * * input/output * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  IS_SPEC( <C> )  . . . . . . . . . . . . . . . . . . .  is <C> a separator
**
**  'IS_SPEC' is defined as follows
**
#define IS_SEP(C)       (!IsAlpha(C) && !IsDigit(C) && (C)!='_')
*/


/****************************************************************************
**
*V  syBuf . . . . . . . . . . . . . .  buffer and other info for files, local
**
**  'syBuf' is  a array used as  buffers for  file I/O to   prevent the C I/O
**  routines  from   allocating their  buffers  using  'malloc',  which would
**  otherwise confuse Gasman.
*/
SYS_SY_BUF syBuf [256];


/****************************************************************************
**
*F  SyFopen( <name>, <mode> ) . . . . . . . .  open the file with name <name>
**
**  The function 'SyFopen'  is called to open the file with the name  <name>.
**  If <mode> is "r" it is opened for reading, in this case  it  must  exist.
**  If <mode> is "w" it is opened for writing, it is created  if  neccessary.
**  If <mode> is "a" it is opened for appending, i.e., it is  not  truncated.
**
**  'SyFopen' returns an integer used by the scanner to  identify  the  file.
**  'SyFopen' returns -1 if it cannot open the file.
**
**  The following standard files names and file identifiers  are  guaranteed:
**  'SyFopen( "*stdin*", "r")' returns 0 identifying the standard input file.
**  'SyFopen( "*stdout*","w")' returns 1 identifying the standard outpt file.
**  'SyFopen( "*errin*", "r")' returns 2 identifying the brk loop input file.
**  'SyFopen( "*errout*","w")' returns 3 identifying the error messages file.
**
**  If it is necessary  to adjust the filename  this should be done here, the
**  filename convention used in GAP is that '/' is the directory separator.
**
**  Right now GAP does not read nonascii files, but if this changes sometimes
**  'SyFopen' must adjust the mode argument to open the file in binary mode.
*/
Int SyFopen (
    Char *              name,
    Char *              mode )
{
    Int                 fid;
    Char                namegz [1024];
    Char                cmd [1024];

    /* handle standard files                                               */
    if ( SyStrcmp( name, "*stdin*" ) == 0 ) {
        if ( SyStrcmp( mode, "r" ) != 0 )
          return -1;
        else
          return 0;
    }
    else if ( SyStrcmp( name, "*stdout*" ) == 0 ) {
        if ( SyStrcmp( mode, "w" ) != 0 )
          return -1;
        else
          return 1;
    }
    else if ( SyStrcmp( name, "*errin*" ) == 0 ) {
        if ( SyStrcmp( mode, "r" ) != 0 )
          return -1;
        else if ( syBuf[2].fp == (FILE*)0 )
          return -1;
        else
          return 2;
    }
    else if ( SyStrcmp( name, "*errout*" ) == 0 ) {
        if ( SyStrcmp( mode, "w" ) != 0 )
          return -1;
        else
          return 3;
    }

    /* try to find an unused file identifier                               */
    for ( fid = 4; fid < sizeof(syBuf)/sizeof(syBuf[0]); ++fid )
        if ( syBuf[fid].fp == (FILE*)0 )
          break;
    if ( fid == sizeof(syBuf)/sizeof(syBuf[0]) )
        return (Int)-1;

    /* set up <namegz> and <cmd> for pipe command                          */
    namegz[0] = '\0';
    SyStrncat( namegz, name, sizeof(namegz)-5 );
    SyStrncat( namegz, ".gz", 4 );
    cmd[0] = '\0';
    SyStrncat( cmd, "gunzip <", 9 );
    SyStrncat( cmd, namegz, sizeof(cmd)-10 );

    /* try to open the file                                                */
    if ( (syBuf[fid].fp = fopen(name,mode)) ) {
        syBuf[fid].pipe = 0;
    }
    else if ( SyStrcmp(mode,"r") == 0
           && SyIsReadableFile(namegz)
           && (syBuf[fid].fp = popen(cmd,mode)) ) {
        syBuf[fid].pipe = 1;
    }
    else {
        return (Int)-1;
    }

    /* allocate the buffer                                                 */
    setbuf( syBuf[fid].fp, syBuf[fid].buf );

    /* return file identifier                                              */
    return fid;
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
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        fputs("gap: panic 'SyFclose' asked to close illegal fid!\n",stderr);
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        fputs("gap: panic 'SyFclose' asked to close closed file!\n",stderr);
        return -1;
    }

    /* refuse to close the standard files                                  */
    if ( fid == 0 || fid == 1 || fid == 2 || fid == 3 ) {
        return -1;
    }

    /* try to close the file                                               */
    if ( (syBuf[fid].pipe == 0 && fclose( syBuf[fid].fp ) == EOF)
      || (syBuf[fid].pipe == 1 && pclose( syBuf[fid].fp ) == -1) )
    {
        fputs("gap: 'SyFclose' cannot close file, ",stderr);
        fputs("maybe your file system is full?\n",stderr);
        syBuf[fid].fp = (FILE*)0;
        return -1;
    }

    /* mark the buffer as unused                                           */
    syBuf[fid].fp = (FILE*)0;
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
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return -1;
    }

    /* *stdin* and *errin* are never at end of file                        */
    if ( fid < 4 )
        return 0;

    return feof(syBuf[fid].fp);
}


/****************************************************************************
**
*F  SyFtell( <fid> )  . . . . . . . . . . . . . . . . . .  position of stream
*/
Int SyFtell (
    Int                 fid )
{
    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return -1;
    }

    /* cannot seek in a pipe                                               */
    if ( syBuf[fid].pipe ) {
        return -1;
    }

    /* get the position                                                    */
    return (Int) ftell(syBuf[fid].fp);
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
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return -1;
    }

    /* cannot seek in a pipe                                               */
    if ( syBuf[fid].pipe ) {
        return -1;
    }

    /* get the position                                                    */
    fseek( syBuf[fid].fp, pos, SEEK_SET );
    return 0;
}


/****************************************************************************
**
*F  syGetch( <fid> )  . . . . . . . . . . . . . . . . . get a char from <fid>
**
**  'SyGetch' reads a character from <fid>, which is switch to raw mode if it
**  is *stdin* or *errin*.
*/



/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . .  BSD/MACH
*/
#if SYS_BSD || SYS_MACH

Int syGetch (
    Int                 fid )
{
    Char                ch;

    /* read a character                                                    */
    while ( read( fileno(syBuf[fid].fp), &ch, 1 ) != 1 || ch == '\0' )
        ;

    /* if running under a window handler, handle special characters        */
    if ( SyWindow && ch == '@' ) {
        do {
            while ( read(fileno(syBuf[fid].fp), &ch, 1) != 1 || ch == '\0' )
                ;
        } while ( ch < '@' || 'z' < ch );
        if ( ch == 'y' ) {
            syWinPut( fileno(syBuf[fid].echo), "@s", "" );
            ch = syGetch(fid);
        }
        else if ( 'A' <= ch && ch <= 'Z' )
            ch = CTR(ch);
    }

    /* return the character                                                */
    return (UChar)ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . . USG
*/
#if SYS_USG

Int syGetch (
    Int                 fid )
{
    Char                ch;

    /* read a character                                                    */
    while ( read( fileno(syBuf[fid].fp), &ch, 1 ) != 1 || ch == '\0' )
        ;

    /* if running under a window handler, handle special characters        */
    if ( SyWindow && ch == '@' ) {
        do {
            while ( read(fileno(syBuf[fid].fp), &ch, 1) != 1 || ch == '\0' )
                ;
        } while ( ch < '@' || 'z' < ch );
        if ( ch == 'y' ) {
            syWinPut( fileno(syBuf[fid].echo), "@s", "" );
            ch = syGetch(fid);
        }
        else if ( 'A' <= ch && ch <= 'Z' )
            ch = CTR(ch);
    }

    /* return the character                                                */
    return (UChar)ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . OS2 EMX
*/
#if SYS_OS2_EMX

#ifndef SYS_KBD_H                       /* keyboard scan codes             */
# include       <sys/kbdscan.h>
# define SYS_KBD_H
#endif

Int syGetch (
    Int                 fid )
{
    UChar               ch;
    Int                 ch2;

syGetchAgain:
    /* read a character                                                    */
    while ( read( fileno(syBuf[fid].fp), &ch, 1 ) != 1 )
        ;

    /* if running under a window handler, handle special characters        */
    if ( SyWindow && ch == '@' ) {
        do {
            while ( read(fileno(syBuf[fid].fp), &ch, 1) != 1 )
                ;
        } while ( ch < '@' || 'z' < ch );
        if ( ch == 'y' ) {
            syWinPut( fileno(syBuf[fid].echo), "@s", "" );
            ch = syGetch(fid);
        }
        else if ( 'A' <= ch && ch <= 'Z' )
            ch = CTR(ch);
    }

    ch2 = ch;

    /* handle function keys                                                */
    if ( ch == '\0' ) {
        while ( read( fileno(syBuf[fid].fp), &ch, 1 ) != 1 )
            ;
        switch ( ch ) {
        case K_LEFT:            ch2 = CTR('B');  break;
        case K_RIGHT:           ch2 = CTR('F');  break;
        case K_UP:
        case K_PAGEUP:          ch2 = CTR('P');  break;
        case K_DOWN:
        case K_PAGEDOWN:        ch2 = CTR('N');  break;
        case K_DEL:             ch2 = CTR('D');  break;
        case K_HOME:            ch2 = CTR('A');  break;
        case K_END:             ch2 = CTR('E');  break;
        case K_CTRL_END:        ch2 = CTR('K');  break;
        case K_CTRL_LEFT:
        case K_ALT_B:           ch2 = ESC('B');  break;
        case K_CTRL_RIGHT:
        case K_ALT_F:           ch2 = ESC('F');  break;
        case K_ALT_D:           ch2 = ESC('D');  break;
        case K_ALT_DEL:
        case K_ALT_BACKSPACE:   ch2 = ESC(127);  break;
        case K_ALT_U:           ch2 = ESC('U');  break;
        case K_ALT_L:           ch2 = ESC('L');  break;
        case K_ALT_C:           ch2 = ESC('C');  break;
        case K_CTRL_PAGEUP:     ch2 = ESC('<');  break;
        case K_CTRL_PAGEDOWN:   ch2 = ESC('>');  break;
        default:                goto syGetchAgain;
        }
    }

    /* return the character                                                */
    return (UChar)ch2;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . .  MS-DOS
*/
#if SYS_MSDOS_DJGPP

Int syGetch (
    Int                 fid )
{
    Int                 ch;

    /* if chars have been typed ahead and read by 'SyIsIntr' read them     */
    if ( syTypeahead[0] != '\0' ) {
        ch = syTypeahead[0];
        strcpy( syTypeahead, syTypeahead+1 );
    }

    /* otherwise read from the keyboard                                    */
    else {
        ch = GETKEY();
    }

    /* postprocess the character                                           */
    if ( 0x110 <= ch && ch <= 0x132 )   ch = ESC( syAltMap[ch-0x110] );
    else if ( ch == 0x147 )             ch = CTR('A');
    else if ( ch == 0x14f )             ch = CTR('E');
    else if ( ch == 0x148 )             ch = CTR('P');
    else if ( ch == 0x14b )             ch = CTR('B');
    else if ( ch == 0x14d )             ch = CTR('F');
    else if ( ch == 0x150 )             ch = CTR('N');
    else if ( ch == 0x153 )             ch = CTR('D');
    else                                ch &= 0xFF;

    /* return the character                                                */
    return ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . . TOS
*/
#if SYS_TOS_GCC2

Int syGetch (
    Int                 fid )
{
    Int                 ch;

    /* if chars have been typed ahead and read by 'SyIsIntr' read them     */
    if ( syTypeahead[0] != '\0' ) {
        ch = syTypeahead[0];
        strcpy( syTypeahead, syTypeahead+1 );
    }

    /* otherwise read from the keyboard                                    */
    else {
        ch = GETKEY();
    }

    /* postprocess the character                                           */
    if (      ch == 0x00480000 )        ch = CTR('P');
    else if ( ch == 0x004B0000 )        ch = CTR('B');
    else if ( ch == 0x004D0000 )        ch = CTR('F');
    else if ( ch == 0x00500000 )        ch = CTR('N');
    else if ( ch == 0x00730000 )        ch = CTR('Y');
    else if ( ch == 0x00740000 )        ch = CTR('Z');
    else                                ch = ch & 0xFF;

    /* return the character                                                */
    return ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . . . VMS
*/
#if SYS_VMS

Int syGetch (
    Int                 fid )
{
    Char                ch;

    /* read a character                                                    */
    smg$read_keystroke( &syVirKbd, &ch );

    /* return the character                                                */
    return (UChar)ch;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . MAC MPW
*/
#if SYS_MAC_MPW

int syGetch (
    Int                 fid )
{
    return 0;
}

#endif


/****************************************************************************
**
*f  syGetch( <fid> )  . . . . . . . . . . . . . . . . . . . . . . . . MAC SYC
*/
#if SYS_MAC_SYC

Int syGetch2 (
    Int                 fid,
    Int                 cur )
{
    Int                 ch;

    /* probably only paranoid                                              */
    if ( ! isatty( fileno(syBuf[fid].fp) ) )
        return EOF;

    /* make the current character reverse to simulate a cursor             */
    syEchoch( (cur != '\0' ? cur : ' ') | 0x80, fid );
    syEchoch( '\b', fid );

    /* get a character, ignore EOF and chars beyond 0x7F (reverse video)   */
    while ( ((ch = getchar()) == EOF) || (0x7F < ch) )
        ;

    /* handle special characters                                           */
    if (      ch == 28 )  ch = CTR('B');
    else if ( ch == 29 )  ch = CTR('F');
    else if ( ch == 30 )  ch = CTR('P');
    else if ( ch == 31 )  ch = CTR('N');

    /* make the current character normal again                             */
    syEchoch( (cur != '\0' ? cur : ' '), fid );
    syEchoch( '\b', fid );

    /* return the character                                                */
    return ch;
}

Int syGetch (
    Int                 fid )
{
    /* return character                                                    */
    return syGetch2( fid, '\0' );
}

#endif


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
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return -1;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
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
*F  SyFgets( <line>, <lenght>, <fid> )  . . . . .  get a line from file <fid>
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
UInt   syNrchar;               /* nr of chars already on the line */
Char   syPrompt [256];         /* characters alread on the line   */

Char   syHistory [8192];       /* history of command lines        */
Char * syHi = syHistory;       /* actual position in history      */
UInt   syCTRO;                 /* number of '<ctr>-O' pending     */


Char * SyFgets (
    Char *              line,
    UInt                length,
    Int                 fid )
{
    Int                 ch,  ch2,  ch3, last;
    Char                * p,  * q,  * r,  * s,  * t;
    Char                * h;
    static Char         yank [512];
    Char                old [512],  new [512];
    Int                 oldc,  newc;
    Int                 rep;
    Char                buffer [512];
    Int                 rn;

    /* check file identifier                                               */
    if ( sizeof(syBuf)/sizeof(syBuf[0]) <= fid || fid < 0 ) {
        return (Char*)0;
    }
    if ( syBuf[fid].fp == (FILE*)0 ) {
        return (Char*)0;
    }

    /* no line editing if the file is not '*stdin*' or '*errin*'           */
    if ( fid != 0 && fid != 2 ) {
        p = fgets( line, (int)length, syBuf[fid].fp );
        return p;
    }

    /* no line editing if the user disabled it                             */
    if ( SyLineEdit == 0 ) {
        SyStopTime = SyTime();
        p = fgets( line, (int)length, syBuf[fid].fp );
        SyStartTime += SyTime() - SyStopTime;
        return p;
    }

    /* no line editing if the file cannot be turned to raw mode            */
    if ( SyLineEdit == 1 && ! syStartraw(fid) ) {
        SyStopTime = SyTime();
        p = fgets( line, (int)length, syBuf[fid].fp );
        SyStartTime += SyTime() - SyStopTime;
        return p;
    }

    /* stop the clock, reading should take no time                         */
    SyStopTime = SyTime();

    /* the line starts out blank                                           */
    line[0] = '\0';  p = line;  h = syHistory;
    for ( q = old; q < old+sizeof(old); ++q )  *q = ' ';
    oldc = 0;
    last = 0;

    while ( 1 ) {

        /* get a character, handle <ctr>V<chr>, <esc><num> and <ctr>U<num> */
        rep = 1;  ch2 = 0;
        do {
            if ( syCTRO % 2 == 1  )  { ch = CTR('N'); syCTRO = syCTRO - 1; }
            else if ( syCTRO != 0 )  { ch = CTR('O'); rep = syCTRO / 2; }
#if ! SYS_MAC_SYC
            else ch = syGetch(fid);
#endif
#if SYS_MAC_SYC
            else ch = syGetch2(fid,*p);
#endif
            if ( ch2==0        && ch==CTR('V') ) {             ch2=ch; ch=0;}
            if ( ch2==0        && ch==CTR('[') ) {             ch2=ch; ch=0;}
            if ( ch2==0        && ch==CTR('U') ) {             ch2=ch; ch=0;}
            if ( ch2==CTR('[') && ch==CTR('V') ) { ch2=ESC(CTR('V'));  ch=0;}
            if ( ch2==CTR('[') && isdigit(ch)  ) { rep=ch-'0'; ch2=ch; ch=0;}
            if ( ch2==CTR('[') && ch=='['      ) {             ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('V') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('[') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && ch==CTR('U') ) { rep=4*rep;  ch2=ch; ch=0;}
            if ( ch2==CTR('U') && isdigit(ch)  ) { rep=ch-'0'; ch2=ch; ch=0;}
            if ( isdigit(ch2)  && ch==CTR('V') ) {             ch2=ch; ch=0;}
            if ( isdigit(ch2)  && ch==CTR('[') ) {             ch2=ch; ch=0;}
            if ( isdigit(ch2)  && ch==CTR('U') ) {             ch2=ch; ch=0;}
            if ( isdigit(ch2)  && isdigit(ch)  ) { rep=10*rep+ch-'0';  ch=0;}
        } while ( ch == 0 );
        if ( ch2==CTR('V') )       ch  = CTV(ch);
        if ( ch2==ESC(CTR('V')) )  ch  = CTV(ch | 0x80);
        if ( ch2==CTR('[') )       ch  = ESC(ch);
        if ( ch2==CTR('U') )       rep = 4*rep;
        if ( ch2=='[' && ch=='A')  ch  = CTR('P');
        if ( ch2=='[' && ch=='B')  ch  = CTR('N');
        if ( ch2=='[' && ch=='C')  ch  = CTR('F');
        if ( ch2=='[' && ch=='D')  ch  = CTR('B');

        /* now perform the requested action <rep> times in the input line  */
        while ( rep-- > 0 ) {
            switch ( ch ) {

            case CTR('A'): /* move cursor to the start of the line         */
                while ( p > line )  --p;
                break;

            case ESC('B'): /* move cursor one word to the left             */
            case ESC('b'):
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

            case ESC('F'): /* move cursor one word to the right            */
            case ESC('f'):
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
                if ( p == line && *p == '\0' && SyCTRD ) {
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
                if ( last!=CTR('X') && last!=CTR('K') && last!=ESC(127)
                  && last!=ESC('D') && last!=ESC('d') )  yank[0] = '\0';
                for ( r = yank; *r != '\0'; ++r ) ;
                for ( s = p; *s != '\0'; ++s )  r[s-p] = *s;
                r[s-p] = '\0';
                *p = '\0';
                break;

            case ESC(127): /* delete the word left of the cursor           */
                q = p;
                if ( p > line ) do {
                    --p;
                } while ( p>line && (!IS_SEP(*(p-1)) || IS_SEP(*p)));
                if ( last!=CTR('X') && last!=CTR('K') && last!=ESC(127)
                  && last!=ESC('D') && last!=ESC('d') )  yank[0] = '\0';
                for ( r = yank; *r != '\0'; ++r ) ;
                for ( ; yank <= r; --r )  r[q-p] = *r;
                for ( s = p; s < q; ++s )  yank[s-p] = *s;
                for ( r = p; *q != '\0'; ++q, ++r )
                    *r = *q;
                *r = '\0';
                break;

            case ESC('D'): /* delete the word right of the cursor          */
            case ESC('d'):
                q = p;
                if ( *q != '\0' ) do {
                    ++q;
                } while ( *q!='\0' && (IS_SEP(*(q-1)) || !IS_SEP(*q)));
                if ( last!=CTR('X') && last!=CTR('K') && last!=ESC(127)
                  && last!=ESC('D') && last!=ESC('d') )  yank[0] = '\0';
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

            case CTR('L'): /* insert last input line                       */
                for ( r = syHistory; *r != '\0' && *r != '\n'; ++r ) {
                    ch2 = *r;
                    for ( q = p; ch2; ++q ) {
                        ch3 = *q; *q = ch2; ch2 = ch3;
                    }
                    *q = '\0'; ++p;
                }
                break;

            case CTR('Y'): /* insert (yank) deleted text                   */
                for ( r = yank; *r != '\0' && *r != '\n'; ++r ) {
                    ch2 = *r;
                    for ( q = p; ch2; ++q ) {
                        ch3 = *q; *q = ch2; ch2 = ch3;
                    }
                    *q = '\0'; ++p;
                }
                break;

            case CTR('P'): /* fetch old input line                         */
                while ( *h != '\0' ) {
                    for ( q = line; q < p; ++q )
                        if ( *q != h[q-line] )  break;
                    if ( q == p )  break;
                    while ( *h != '\n' && *h != '\0' )  ++h;
                    if ( *h == '\n' ) ++h;
                }
                q = p;
                while ( *h!='\0' && h[q-line]!='\n' && h[q-line]!='\0' ) {
                    *q = h[q-line];  ++q;
                }
                *q = '\0';
                while ( *h != '\0' && *h != '\n' )  ++h;
                if ( *h == '\n' ) ++h;  else h = syHistory;
                syHi = h;
                break;

            case CTR('N'): /* fetch next input line                        */
                h = syHi;
                if ( h > syHistory ) {
                    do {--h;} while (h>syHistory && *(h-1)!='\n');
                    if ( h==syHistory )  while ( *h != '\0' ) ++h;
                }
                while ( *h != '\0' ) {
                    if ( h==syHistory )  while ( *h != '\0' ) ++h;
                    do {--h;} while (h>syHistory && *(h-1)!='\n');
                    for ( q = line; q < p; ++q )
                        if ( *q != h[q-line] )  break;
                    if ( q == p )  break;
                    if ( h==syHistory )  while ( *h != '\0' ) ++h;
                }
                q = p;
                while ( *h!='\0' && h[q-line]!='\n' && h[q-line]!='\0' ) {
                    *q = h[q-line];  ++q;
                }
                *q = '\0';
                while ( *h != '\0' && *h != '\n' )  ++h;
                if ( *h == '\n' ) ++h;  else h = syHistory;
                syHi = h;
                break;

            case ESC('<'): /* goto beginning of the history                */
                while ( *h != '\0' ) ++h;
                do {--h;} while (h>syHistory && *(h-1)!='\n');
                q = p = line;
                while ( *h!='\0' && h[q-line]!='\n' && h[q-line]!='\0' ) {
                    *q = h[q-line];  ++q;
                }
                *q = '\0';
                while ( *h != '\0' && *h != '\n' )  ++h;
                if ( *h == '\n' ) ++h;  else h = syHistory;
                syHi = h;
                break;

            case ESC('>'): /* goto end of the history                      */
                h = syHistory;
                p = line;
                *p = '\0';
                syHi = h;
                break;

            case CTR('S'): /* search for a line forward                    */
                /* search for a line forward, not fully implemented !!!    */
                if ( *p != '\0' ) {
                    ch2 = syGetch(fid);
                    q = p+1;
                    while ( *q != '\0' && *q != ch2 )  ++q;
                    if ( *q == ch2 )  p = q;
                }
                break;

            case CTR('R'): /* search for a line backward                   */
                /* search for a line backward, not fully implemented !!!   */
                if ( p > line ) {
                    ch2 = syGetch(fid);
                    q = p-1;
                    while ( q > line && *q != ch2 )  --q;
                    if ( *q == ch2 )  p = q;
                }
                break;

            case ESC('U'): /* uppercase word                               */
            case ESC('u'):
                if ( *p != '\0' ) do {
                    if ('a' <= *p && *p <= 'z')  *p = *p + 'A' - 'a';
                    ++p;
                } while ( *p!='\0' && (IS_SEP(*(p-1)) || !IS_SEP(*p)));
                break;

            case ESC('C'): /* capitalize word                              */
            case ESC('c'):
                while ( *p!='\0' && IS_SEP(*p) )  ++p;
                if ( 'a' <= *p && *p <= 'z' )  *p = *p + 'A'-'a';
                if ( *p != '\0' ) ++p;
                /* lowercase rest of the word                              */

            case ESC('L'): /* lowercase word                               */
            case ESC('l'):
                if ( *p != '\0' ) do {
                    if ('A' <= *p && *p <= 'Z')  *p = *p + 'a' - 'A';
                    ++p;
                } while ( *p!='\0' && (IS_SEP(*(p-1)) || !IS_SEP(*p)));
                break;

            case ESC(CTR('L')): /* repaint input line                      */
                syEchoch('\n',fid);
                for ( q = syPrompt; q < syPrompt+syNrchar; ++q )
                    syEchoch( *q, fid );
                for ( q = old; q < old+sizeof(old); ++q )  *q = ' ';
                oldc = 0;
                break;

            case EOF:     /* end of file on input                          */
                break;

            case CTR('M'): /* append \n and exit                           */
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
                    ch2 = ch & 0xff;
                    for ( q = p; ch2; ++q ) {
                        ch3 = *q; *q = ch2; ch2 = ch3;
                    }
                    *q = '\0'; ++p;
                }
                else {
                    if ( (q = p) > line ) do {
                        --q;
                    } while ( q>line && (!IS_SEP(*(q-1)) || IS_SEP(*q)));
                    rn = (line < q && *(q-1) == '.');
                    r = buffer;  s = q;
                    while ( s < p )  *r++ = *s++;
                    *r = '\0';
                    if ( (rn ? iscomplete_rnam( buffer, p-q )
                             : iscomplete_gvar( buffer, p-q )) ) {
                           if ( last != CTR('I') )
                            syEchoch( CTR('G'), fid );
                        else {
                            syWinPut( fid, "@c", "" );
                            syEchos( "\n    ", fid );
                            syEchos( buffer, fid );
                            while ( (rn ? completion_rnam( buffer, p-q )
                                        : completion_gvar( buffer, p-q )) ) {
                                syEchos( "\n    ", fid );
                                syEchos( buffer, fid );
                            }
                            syEchos( "\n", fid );
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
                        if ( last != CTR('I') )
                            syEchoch( CTR('G'), fid );
                        else {
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
                        t = p;
                        for ( s = buffer+(p-q); *s != '\0'; s++ ) {
                            ch2 = *s;
                            for ( r = p; ch2; r++ ) {
                                ch3 = *r; *r = ch2; ch2 = ch3;
                            }
                            *r = '\0'; p++;
                        }
                        while ( t < p
                             && (rn ? completion_rnam( buffer, t-q )
                                    : completion_gvar( buffer, t-q )) ) {
                            r = t;  s = buffer+(t-q);
                            while ( r < p && *r == *s ) {
                                r++; s++;
                            }
                            s = p;  p = r;
                            while ( *s != '\0' )  *r++ = *s++;
                            *r = '\0';
                        }
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

            last = ch;

        }

        if ( ch==EOF || ch=='\n' || ch=='\r' || ch==CTR('O') ) {
            syEchoch('\r',fid);  syEchoch('\n',fid);  break;
        }

        /* now update the screen line according to the differences         */
        for ( q = line, r = new, newc = 0; *q != '\0'; ++q ) {
            if ( q == p )  newc = r-new;
            if ( *q==CTR('I') )  { do *r++=' '; while ((r-new+syNrchar)%8); }
            else if ( *q==0x7F ) { *r++ = '^'; *r++ = '?'; }
            else if ( '\0'<=*q && *q<' '  ) { *r++ = '^'; *r++ = *q+'@'; }
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

    /* Now we put the new string into the history,  first all old strings  */
    /* are moved backwards,  then we enter the new string in syHistory[].  */
    for ( q = syHistory+sizeof(syHistory)-3; q >= syHistory+(p-line); --q )
        *q = *(q-(p-line));
    for ( p = line, q = syHistory; *p != '\0'; ++p, ++q )
        *q = *p;
    syHistory[sizeof(syHistory)-3] = '\n';
    if ( syHi != syHistory )
        syHi = syHi + (p-line);
    if ( syHi > syHistory+sizeof(syHistory)-2 )
        syHi = syHistory+sizeof(syHistory)-2;

    /* send the whole line (unclipped) to the window handler               */
    syWinPut( fid, (*line != '\0' ? "@r" : "@x"), line );

    /* strip away prompts (usefull for pasting old stuff)                  */
    if (line[0]=='g'&&line[1]=='a'&&line[2]=='p'&&line[3]=='>'&&line[4]==' ')
        for ( p = line, q = line+5; q[-1] != '\0'; p++, q++ )  *p = *q;
    if (line[0]=='b'&&line[1]=='r'&&line[2]=='k'&&line[3]=='>'&&line[4]==' ')
        for ( p = line, q = line+5; q[-1] != '\0'; p++, q++ )  *p = *q;
    if (line[0]=='>'&&line[1]==' ')
        for ( p = line, q = line+2; q[-1] != '\0'; p++, q++ )  *p = *q;

    /* switch back to cooked mode                                          */
    if ( SyLineEdit == 1 )
        syStopraw(fid);

    /* start the clock again                                               */
    SyStartTime += SyTime() - SyStopTime;

    /* return the line (or '0' at end-of-file)                             */
    if ( *line == '\0' )
        return (Char*)0;
    return line;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * file and execution * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SyIsExistingFile( <name> )  . . . . . . . . . . . does file <name> exists
**
**  'SyIsExistingFile' returns 1 if the  file <name> exists and 0  otherwise.
**  It does not check if the file is readable, writable or excuteable. <name>
**  is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsExistingFile( <name> )  . . . . . . . . . . . . . . . .  BSD/Mach/USG
*/
#if SYS_BSD || SYS_MACH || SYS_USG

Int SyIsExistingFile ( Char * name )
{
    if ( access( name, F_OK ) == 0 ) {
        return 1;
    }
    else {
        return 0;
    }
}

#endif


/****************************************************************************
**
*F  SyIsReadableFile( <name> )  . . . . . . . . . . . is file <name> readable
**
**  'SyIsReadableFile'   returns 1  if the   file  <name> is   readable and 0
**  otherwise. <name> is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsReadableFile( <name> )  . . . . . . . . . . . . . . . .  BSD/Mach/USG
*/
#if SYS_BSD || SYS_MACH || SYS_USG

Int SyIsReadableFile ( Char * name )
{
    if ( access( name, R_OK ) == 0 ) {
        return 1;
    }
    else {
        return 0;
    }
}

#endif


/****************************************************************************
**
*F  SyIsWritable( <name> )  . . . . . . . . . . . is the file <name> writable
**
**  'SyIsWriteableFile'   returns 1  if  the  file  <name> is  writable and 0
**  otherwise. <name> is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsWritable( <name> )  . . . . . . . . . . . . . . . . . .  BSD/Mach/USG
*/
#if SYS_BSD || SYS_MACH || SYS_USG

Int SyIsWritableFile ( Char * name )
{
    if ( access( name, W_OK ) == 0 ) {
        return 1;
    }
    else {
        return 0;
    }
}

#endif


/****************************************************************************
**
*F  SyIsExecutableFile( <name> )  . . . . . . . . . is file <name> executable
**
**  'SyIsExecutableFile' returns 1 if the  file <name>  is  executable and  0
**  otherwise. <name> is a system dependent description of the file.
*/


/****************************************************************************
**
*f  SyIsExecutableFile( <name> )  . . . . . . . . . . . . . . .  BSD/Mach/USG
*/
#if SYS_BSD || SYS_MACH || SYS_USG

Int SyIsExecutableFile ( Char * name )
{
    if ( access( name, X_OK ) == 0 ) {
        return 1;
    }
    else {
        return 0;
    }
}

#endif


/****************************************************************************
**
*F  SyFindGapRootFile( <filename> ) . . . . . . . .  find file in system area
*/
Char * SyFindGapRootFile ( Char * filename )
{
    static Char     result [256];
    Int             k;

    for ( k=0;  k<sizeof(SyGapRootPaths)/sizeof(SyGapRootPaths[0]);  k++ ) {
        if ( SyGapRootPaths[k][0] ) {
            result[0] = '\0';
            SyStrncat( result, SyGapRootPaths[k], sizeof(result) );
            if ( sizeof(result) <= SyStrlen(filename)+SyStrlen(result)-1 )
                continue;
            SyStrncat( result, filename, SyStrlen(filename) );
            if ( SyIsReadableFile(result) ) {
                return result;
            }
        }
    }
    return 0;
}


/****************************************************************************
**
*F  SyExec( <cmd> ) . . . . . . . . . . . execute command in operating system
**
**  'SyExec' executes the command <cmd> (a string) in the operating system.
**
**  'SyExec'  should call a command  interpreter  to execute the command,  so
**  that file name expansion and other common  actions take place.  If the OS
**  does not support this 'SyExec' should print a message and return.
**
**  For UNIX we can use 'system', which does exactly what we want.
*/
#ifndef SYS_STDLIB_H                    /* ANSI standard functions         */
# if SYS_ANSI
#  include      <stdlib.h>
# endif
# define SYS_STDLIB_H
#endif
#ifndef SYS_HAS_MISC_PROTO              /* ANSI/TRAD decl. from H&S 19.2   */
extern  int             system ( SYS_CONST char * );
#endif

#if ! (SYS_MAC_MPW || SYS_MAC_SYC)

void            SyExec (
    Char *              cmd )
{
    Int                 ignore;

    syWinPut( 0, "@z", "" );
    ignore = system( cmd );
    syWinPut( 0, "@mAgIc", "" );
}

#endif

#if SYS_MAC_MPW || SYS_MAC_SYC

void            SyExec (
    Char *              cmd;
{
}

#endif


/****************************************************************************
**
*F  SyTmpname() . . . . . . . . . . . . . . . . . return a temporary filename
**
**  'SyTmpname' creates and returns a new temporary name.
*/
#ifndef SYS_STDIO_H                     /* standard input/output functions */
# include       <stdio.h>
# define SYS_STDIO_H
#endif

#ifndef SYS_HAS_MISC_PROTO              /* ANSI/TRAD decl. from H&S 15.16  */
extern  char * tmpnam ( char * );
#endif

#ifdef SYS_HAS_BROKEN_TMPNAM

Char * SyTmpname ()
{
    static Char   * base = 0;
    static Char     name[1024];
    static Int      count = 0;
    Char            cnt[4];

    count++;
    if ( base == 0 ) {
        base = tmpnam( (char*)0 );
    }
    if ( base == 0 ) {
        return 0;
    }
    name[0] = 0;
    SyStrncat( name, base, SyStrlen(base) );
    SyStrncat( name, ".", 1 );
    cnt[0] = (count/100) % 10 + '0';
    cnt[1] = (count/ 10) % 10 + '0';
    cnt[2] = (count/  1) % 10 + '0';
    cnt[3] = 0;
    SyStrncat( name, cnt, 4 );
    return name;
}

#else

Char * SyTmpname ( void )
{
    return tmpnam( (char*)0 );
}

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitSysFiles()  . . . . . . . . . . . . . . . . . initialize the packages
*/
void InitSysFiles( void )
{
    Obj             list;
    Obj             tmp;
    UInt            gvar;
    Int             len;
    Int             i;
    Int             j;

    /* GAP_ARCHITECTURE                                                    */
    tmp = NEW_STRING(SyStrlen(SyArchitecture));
    SyStrncat( CSTR_STRING(tmp), SyArchitecture, SyStrlen(SyArchitecture) );
    gvar = GVarName("GAP_ARCHITECTURE");
    AssGVar( gvar, tmp );
    MakeReadOnlyGVar(gvar);


    /* GAP_ROOT_PATH                                                       */
    list = NEW_PLIST( T_PLIST, MAX_GAP_DIRS );
    for ( i = 0, j = 1;  i < MAX_GAP_DIRS;  i++ ) {
        if ( SyGapRootPaths[i][0] ) {
            len = SyStrlen(SyGapRootPaths[i]);
            tmp = NEW_STRING(len);
            SyStrncat( CSTR_STRING(tmp), SyGapRootPaths[i], len );
            SET_ELM_PLIST( list, j, tmp );
            j++;
        }
    }
    SET_LEN_PLIST( list, j-1 );
    gvar = GVarName("GAP_ROOT_PATHS");
    AssGVar( gvar, list );
    MakeReadOnlyGVar(gvar);
}


/****************************************************************************
**

*E  sysfiles.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
