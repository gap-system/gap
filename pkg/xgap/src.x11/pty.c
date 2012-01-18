/****************************************************************************
**
*W  pty.c                       XGAP source                      Frank Celler
**
*H  @(#)$Id: pty.c,v 1.14 2011/11/24 11:44:23 gap Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
**
**  This file contains all the code for handling pseudo ttys.  'GetMasterPty'
**  is based on code from 'xterm'.
**
**  GAP is started in a special mode that will mask special characters.  The
**  following '@' sequences produced by GAP are recoginzed:
**
**    'pX.'          		package mode version X
**    '@'			a single '@'
**    'A'..'Z'			a control character
**    '1','2','3','4','5','6'	full garbage collection information
**    '!','"','#','$','%','&'   partial garbage collection information
**    'e'              		gap is waiting for error input
**    'c'              		completion started
**    'f'              		error output
**    'h'              		help started
**    'i'              		gap is waiting for input
**    'm'             		end of 'Exec'
**    'n'              		normal output
**    'r'              		the current input line follows
**    'sN'             		ACK for '@yN'
**    'w'              		a window command follows
**    'x'              		the current input line is empty
**    'z' 			start of 'Exec'
*/
#include    "utils.h"

#include    "gaptext.h"
#include    "xcmds.h"
#include    "xgap.h"

#include    "pty.h"


/****************************************************************************
**

*F * * * * * * * * * * * * * * local variables * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  GapPID  . . . . . . . . . . . . . . . . . . . . . . . . gap subprocess id
*/
static int GapPID = -1;


/****************************************************************************
**
*V  FromGap . . . . . . . . . . . . . . . . . . . . . . for messages from gap
*/
static int FromGap;


/****************************************************************************
**
*V  ToGap . . . . . . . . . . . . . . . . . . . . . . . . for messages to gap
*/
static int ToGap;


/* * * * * * * * * * * * * *  global variables * * * * * * * * * * * * * * */


/****************************************************************************
**

*V  QuitGapCtrlD  . . . . . . . . . . . . . . . . . . . . . . . quit on CTR-D
*/
Boolean QuitGapCtrlD = FALSE;


/****************************************************************************
**
*V  ScreenSizeBuffer  . . . . . . . . . . . . . .  screen size change command
*/
char ScreenSizeBuffer[128] = { 0 };


/****************************************************************************
**
*V  ExecRunning . . . . . . . . . . . . . . . . . .  external program running
*/
Boolean ExecRunning = False;


/****************************************************************************
**

*F * * * * * * * * * * * *  communication with GAP * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  ReadGap( <line>, <len> )  . . . . . . . . . . . . . . . . read gap output
*/
#ifdef DEBUG_ON

Int READ_GAP ( file, where, line, len )
    String	file;
    Int         where;
    String      line;
    Int         len;
{
    Int         n;
    Int         old;

    if ( Debug & D_COMM )
    {
	printf( "%04d:%s: ReadGap( buf, %d ) = ", where, file, len );
	fflush( stdout );
    }
    if ( len < 0 )
    {
        len = read( FromGap, line, -len );
	if ( Debug & D_COMM )
	{
	    if ( len == -1 )
		fprintf( stdout, "-1: no input\n" );
	    else
	    {
		fprintf( stdout, "%d: '", len );
		fwrite( line, 1, len, stdout );
		fprintf( stdout, "'\n" );
	    }
	    fflush( stdout );
	}
	return len;
    }
    else
    {
        old = len;
        while ( 0 < len )
        {
            while ( ( n = read( FromGap, line, len ) ) < 0 )
		;
            line = line + n;
            len  = len - n;
        }
	if ( Debug & D_COMM )
	{
	    fprintf( stdout, "%d: '", old );
	    fwrite( line-old, 1, old, stdout );
	    fprintf( stdout, "'\n" );
	    fflush( stdout );
	}
        return old;
    }
}

#else

Int ReadGap ( line, len )
    String	line;
    Int         len;
{
    Int         n;
    Int         old;

    if ( len < 0 )
        return read( FromGap, line, -len );
    else
    {
        old = len;
        while ( 0 < len )
        {
            while ( ( n = read( FromGap, line, len ) ) < 0 )
		;
            line = line + n;
            len  = len - n;
        }
        return old;
    }
}

#endif


/****************************************************************************
**
*F  WriteGap( <line>, <len> ) . . . . . . . . . . . . . . . . write gap input
*/
extern int errno;

#ifdef DEBUG_ON

void WRITE_GAP ( file, where, line, len )
    String	file;
    Int		where;
    String	line;
    Int		len;
{
    Int         res;

    if ( Debug & D_COMM )
    {
	printf( "%04d:%s: WriteGap( %d ) = '", where, file, len );
	fwrite( line, 1, len, stdout );
	fprintf( stdout, "'\n" );
	fflush( stdout );
    }
    while ( 0 < len )
    {
        res = write( ToGap, line, len );
        if ( res < 0 )
        {
	    if ( errno == EAGAIN )
		continue;
            perror( "WriteGap" );
            KillGap();
            exit(1);
        }
        len  -= res;
        line += res;
    }
}

#else

void WriteGap ( line, len )
    String	line;
    Int         len;
{
    Int         res;

    while ( 0 < len )
    {
        res = write( ToGap, line, len );
        if ( res < 0 )
        {
	    if ( errno == EAGAIN )
		continue;
            perror( "WriteGap" );
            KillGap();
            exit(1);
        }
        len  -= res;
        line += res;
    }
}

#endif


/****************************************************************************
**

*V  InBuffer  . . . . . . . . . . . . . . . . . . . . .  buffer of gap output
*/
#define SIZE_BUFFER	16000

static struct _in_buf
{
    char    buffer[SIZE_BUFFER];
    Int     pos;
    Int     len;
}
InBuffer;


/****************************************************************************
**
*V  GapBuffer . . . . . . . . . . . . . . . . temporary buffer for 'ReadLine'
*/
static char GapBuffer[SIZE_BUFFER];


/****************************************************************************
**
*V  LastLine  . . . . . . . . . . . . . . . . . . . .  beginning of last line
*/
static Int LastLine;


/****************************************************************************
**

*D  CURRENT( <buf> )  . . . . . . . . . . . . . . . . . . . .  current symbol
*/
#define	CURRENT(buf)	    ((buf).buffer[(buf).pos])


/****************************************************************************
**
*D  READ_CURRENT( <buf> ) . . . . . . . . . . . . . .  consume current symbol
*/
#define	READ_CURRENT(buf)   ((buf).buffer[(buf).pos++])


/****************************************************************************
**
*D  HAS_INPUT( <buf> )  . . . . . . . . . . . . . . . . . . . check for input
*/
#define	HAS_INPUT(buf)	( ((buf).len <= (buf).pos) ? (buf).pos = 0, \
 			  ((buf).len=ReadGap((buf).buffer,-SIZE_BUFFER))>0 :\
			  1 )


/****************************************************************************
**
*D  HAS_BUFFERED( <buf> ) . . . . . . . . . . . . .  check for buffered input
*/
#define HAS_BUFFERED(buf)   ( (buf).pos < (buf).len )


/****************************************************************************
**
*D  LOOK_AHEAD( <buf> )	. . . look ahead if there is enough input, dont check
*/
#define LOOK_AHEAD(buf)	( ((buf).pos+1 < (buf).len ) ? \
			  ((buf).buffer)[(buf).pos+1] : '\0' )


/****************************************************************************
**

*F  WaitInput( <buf> )  . . . . . . . . . . . . . . .  wait for one character
*/
void WaitInput ( buf )
    struct _in_buf    * buf;
{
    Int                 len;

    if ( buf->len <= buf->pos )
    {
	buf->pos = 0;
	ReadGap( buf->buffer, 1 );
	len = ReadGap( buf->buffer+1, -(SIZE_BUFFER-1) );
	buf->len = (len < 0) ? 1 : len+1;
    }
}


/****************************************************************************
**
*F  WaitInput2( <buf> ) . . . . . . . . . . . . . . . wait for two characters
*/
void WaitInput2 ( buf )
    struct _in_buf    * buf;
{
    Int                 len;

    if ( buf->len <= 1 + buf->pos )
    {
	if ( buf->pos+1 == buf->len )
	{
	    *buf->buffer = buf->buffer[buf->pos];
	    buf->pos = 0;
	    ReadGap( buf->buffer+1, 1 );
	    len = ReadGap( buf->buffer+2, -(SIZE_BUFFER-2) );
	    buf->len = (len < 0) ? 2 : len+2;
	}
	else
	{
	    buf->pos = 0;
	    ReadGap( buf->buffer, 2 );
	    len = ReadGap( buf->buffer+2, -(SIZE_BUFFER-2) );
	    buf->len = (len < 0) ? 2 : len+2;
	}
    }
}

/****************************************************************************
**
*F  ReadLine( <buf> ) . . . . . . . . . . . . . . . . . . . . . . read a line
*/
void ReadLine ( buf )
    struct _in_buf    * buf;
{
    String              ptr = GapBuffer;

    do
    {
	WaitInput(buf);
	if ( CURRENT(*buf) == '\n' )
	{
	    *ptr++ = READ_CURRENT(*buf);
	    *ptr   = 0;
	    return;
	}
	else if ( CURRENT(*buf) == '\r' )
	    (void) READ_CURRENT(*buf);
	else if ( CURRENT(*buf) == '@' )
	{
	    (void) READ_CURRENT(*buf);
	    WaitInput(buf);
	    if ( CURRENT(*buf) == 'J' )
	    {
		*ptr++ = '\n';
		*ptr   = 0;
		(void) READ_CURRENT(*buf);
		return;
	    }
	    else if ( CURRENT(*buf) != '@' )
		*ptr++ = '^';
	    *ptr++ = READ_CURRENT(*buf);
	}
	else
	    *ptr++ = READ_CURRENT(*buf);
    } while ( 1 );
}


/****************************************************************************
**

*F  StoreInput( <str>, <len> )	. . . . . . . . . store input for later usage
*/
static struct _storage
{
    String      buffer;
    Int         size;
    Int         len;
}
Storage = { 0, 0, 0 };

void StoreInput ( str, len )
    String      str;
    Int         len;
{
    if ( Storage.buffer == 0 )
    {
	Storage.buffer = XtMalloc(4096);
	Storage.size   = 4096;
    }
    if ( Storage.size <= Storage.len + len )
    {
	Storage.size  += ((len/4096+1) * 4096);
	Storage.buffer = XtRealloc( Storage.buffer, Storage.size );
    }
    memcpy( Storage.buffer+Storage.len, str, len );
    Storage.len += len;
}


/****************************************************************************
**
*F  ProcessStoredInput( <state> ) . . . . . . . . .  feed stored input to gap
*/
static Char InputCookie = 'A';

void ProcessStoredInput ( state )
    Int             state;
{
    String          ptr;
    String          free;
    Char            ch;
    Int             len;
    static Boolean  inProgress = False;

    /* if we are already processing input do not start again */
    if ( inProgress || state != 0 )
	return;

    /* if gap is not accepting input return */
    if ( GapState != GAP_INPUT && GapState != GAP_ERROR )
	return;

    /* if no input is waiting return */
    if ( Storage.len == 0 && ScreenSizeBuffer == 0 )
	return;

    /* otherwise make sure that gap does not want to tell use something */
again:
    if ( HAS_INPUT(InBuffer) )
	GapOutput( 0, 0, 0 );
    if ( GapState != GAP_INPUT && GapState != GAP_ERROR )
	return;

    /* send '@yN' and wait for ACK '@sN' */
    if ( InputCookie++ == 'Z' )  InputCookie = 'A';
    WriteGap( "@y", 2 );
    WriteGap( &InputCookie, 1 );
    WaitInput(&InBuffer);
    if ( CURRENT(InBuffer) != '@' )
	goto again;
    WaitInput2(&InBuffer);
    if ( LOOK_AHEAD(InBuffer) != 's' )
	goto again;
    (void)READ_CURRENT(InBuffer);
    (void)READ_CURRENT(InBuffer);
    WaitInput(&InBuffer);
    if ( READ_CURRENT(InBuffer) != InputCookie )
	goto again;

    /* if the screen was resized,  process resize command first */
    if ( *ScreenSizeBuffer != 0 )
    {
	WriteGap( ScreenSizeBuffer, strlen(ScreenSizeBuffer) );
	*ScreenSizeBuffer = 0;
	return;
    }

    /* start processing input,  check reaction of gap */
    inProgress = True;
    len = Storage.len;
    free = ptr = Storage.buffer;
    while ( 0 < len )
    {
	WriteGap( ptr, 1 );  len--;  ptr++;
	if (    ptr[-1] == '\n'
	     || ptr[-1] == '\r'
	     || (free<ptr-1 && ptr[-2]=='@' && ptr[-1]=='M')
	     || (free<ptr-1 && ptr[-2]=='@' && ptr[-1]=='J')
	    )
	    break;
	if (    ! QuitGapCtrlD && GapState == GAP_INPUT 
	     && ptr[-1] == '@' && ptr[0] == 'D' )
	{
	    WriteGap( "F@H", 3 );
	    len--;
	    ptr++;
	}
    }

    /* create new buffer,  store remaining input, and free old */
    inProgress = False;
    if ( len <= Storage.size )
    {
	Storage.len = len;
	for ( ;  0 < len;  len-- )
	    *free++ = *ptr++;
    }
    else
    {
	Storage.size   = ( 4096 < len ) ? len : 4096;
	Storage.buffer = XtMalloc(Storage.size);
	memcpy( Storage.buffer, ptr, len );
	Storage.len = len;
	XtFree(free);
    }
    if ( GapState == GAP_HELP )
	ProcessStoredInput(0);
}


/****************************************************************************
**
*F  SimulateInput( <str> )  . . . . . . . . . .  enter a line as command line
*/
void SimulateInput ( str )
    String  str;
{
    Int     pos;

    /* if <GAP> is not accepting input,  discard line */
    if ( GapState != GAP_INPUT && GapState != GAP_ERROR )
	return;

    /* ok, do it.  get current cursor position */
    pos = GTPosition(GapTalk) - LastLine;
    StoreInput( "@A@K", 4 );
    StoreInput( str, strlen(str) );
    StoreInput( "@Y@A", 4 );
    while ( 0 < pos-- )
	StoreInput( "@F", 2 );
    ProcessStoredInput(0);
}


/****************************************************************************
**
*F  KeyboardInput( <str>, <len> ) . . . . . . . . . .  process keyboard input
*/
Boolean PlayingBack = False;
FILE * Playback = 0;

int PlaybackFile ( str )
    String      str;
{
    if ( Playback != 0 ) {
	fclose(Playback);
    }
    Playback = fopen( str, "r" );
    if ( Playback != 0 ) {
	PlayingBack = True;
    }
    else {
	PlayingBack = False;
    }
    return PlayingBack;
}

int ResumePlayback ( void )
{
    if ( PlayingBack || Playback == 0 )
	return False;
    PlayingBack = True;
    return True;
}

void KeyboardInput ( str, len )
    String      str;
    Int     	len;
{
    char        buf[1025];

#ifndef	EXIT_ON_DOUBLE_CTR_C
    static Int	ltime = 0;
    Int         ntime;  
#endif

    /* read playback file */
    if ( PlayingBack && GapState == GAP_INPUT ) {
	if ( *str == 'q' || *str == 'Q' ) {
	    fclose(Playback);
	    PlayingBack = False;
	    Playback = 0;
	    StoreInput( "\"Playback STOPPED\";;\n", 21 );
	}
	else if ( *str=='z' || *str=='Z' || *str=='y' || *str=='Y' ) {
	    PlayingBack = False;
	    StoreInput( "\"Playback SUPENDED\";;\n", 22 );
	}
	else {
	    if ( fgets( buf, 1024, Playback ) == 0 ) {
		fclose(Playback);
		PlayingBack = False;
		Playback = 0;
	    }
	    else {
		StoreInput( buf, strlen(buf) );
		if ( feof(Playback) ) {
		    fclose(Playback);
		    PlayingBack = False;
		    Playback = 0;
		}
	    }
	    if ( ! PlayingBack )
		StoreInput( "\"Playback ENDED\";;\n", 19 );
	}
    }

    /* handle help mode directly */
    else if ( GapState == GAP_HELP )
    {
	if ( HAS_INPUT(InBuffer) || HAS_INPUT(InBuffer) )
	    GapOutput( 0, 0, 0 );
	if ( GapState != GAP_HELP )
	{
	    KeyboardInput( str, len );
	    return;
	}

	/* send '@yN' and wait for ACK '@sN' */
	if ( InputCookie++ == 'Z' )  InputCookie = 'A';
	WriteGap( "@y", 2 );
	WriteGap( &InputCookie, 1 );
	WaitInput(&InBuffer);
	if ( CURRENT(InBuffer) != '@' )
	{
	    GapOutput( 0, 0, 0 );
	    KeyboardInput( str, len );
	    return;
	}
	WaitInput2(&InBuffer);
	if ( LOOK_AHEAD(InBuffer) != 's' )
	{
	    GapOutput( 0, 0, 0 );
	    KeyboardInput( str, len );
	    return;
	}
	(void)READ_CURRENT(InBuffer);
	(void)READ_CURRENT(InBuffer);
	if ( READ_CURRENT(InBuffer) != InputCookie ) {
	    GapOutput( 0, 0, 0 );
	    KeyboardInput( str, len );
	    return;
	}

	/* write a character and start again */
	WriteGap( str, 1 );
	if ( *str == '@' && 1 < len )
	{
	    WriteGap( str+1, 1 );
	    str++;
	    len--;
	}
	str++;
	len--;
	if ( 0 < len )
	    KeyboardInput( str, len );
	return;
    }

    /* consume input */
    else if ( PlayingBack && GapState == GAP_RUNNING ) {
	;
    }
    else {
    while ( 0 < len )
    {

	/* handle <CTR-C> */
	if ( 2 <= len && *str == '@' && str[1] == 'C' )
	{
#           ifndef EXIT_ON_DOUBLE_CTR_C
	        while ( 2 <= len && *str == '@' && str[1] == 'C' )
		{
		    str += 2;
		    len -= 2;
		}
		ntime = (int) time(0);
		if ( 2 < ntime - ltime )
		    InterruptGap();
		ltime = ntime;
#           else
		InterruptGap();
		str += 2;
		len -= 2;
#           endif
	}

	/* otherwise store it */
	else
	{
	    StoreInput( str, 1 );
	    len--;
	    str++;
	}
    }
    }

    /* try to process input */
    ProcessStoredInput(0);
}


/****************************************************************************
**
*F  CheckCaretPos( <new>, <old> ) . . . . . . . . . . .  check caret movement
*/
Int CheckCaretPos ( new, old )
    Int     new;
    Int     old;
{
    /* if <LastLine> is -1,  then gap is running,  ignore move */
    if ( LastLine < 0 )
	return 0;

    /* if the new position is before the last line,  ignore move */
    else if ( new < LastLine )
	return 0;

    /* otherwise move in the correct direction */
    else if ( new < old )
    {
	while ( new++ < old )
	    WriteGap( "@B", 2 );
	return 0;
    }
    else if ( old < new )
    {
	while ( old++ < new )
	    WriteGap( "@F", 2 );
	return 0;
    }
    else
	return 0;
}


/****************************************************************************
**
*F  ParseInt( <buf>, <val> )  . . . . . . . . . . . . . . .  get a long value
*/
static Boolean ParseInt (
    struct _in_buf    * buf,
    Int               * val )
{
    Int                 mult;

    *val = 0;
    mult = 1;
    do
    {
	WaitInput(buf);
	if ( CURRENT(*buf) == '+' )
	{
	    (void) READ_CURRENT(*buf);
	    return True;
	}
	else if ( CURRENT(*buf) == '-' )
	{
	    (void) READ_CURRENT(*buf);
	    *val = -*val;
	    return True;
	}
	else if ( '0' <= CURRENT(*buf) && CURRENT(*buf) <= '9' )
	    *val += mult * (READ_CURRENT(*buf)-'0');
	else
	    return False;
	mult = mult * 10;
    } while (1);
}


/****************************************************************************
**
*F  GapOutput( <cld>, <fid>, <id> ) . . . . . . . . . . . . handle gap output
*/
#undef  CTR
#define CTR(a)	( a & 0x1f )

static char TBuf[SIZE_BUFFER];

void GapOutput ( cld, fid, id )
    XtPointer       cld;
    int           * fid;
    XtInputId       id;
{
    char            ch;
    Int             special;
    Int             len;

    /* wait a while for input */
    HAS_INPUT(InBuffer);
    HAS_INPUT(InBuffer);
    HAS_INPUT(InBuffer);

    /* special code for 'Exec' */
    if ( ExecRunning )
    {
	DEBUG( D_COMM, ("GapOutput: exec still active\n") );
	len = 0;
	while ( HAS_BUFFERED(InBuffer) && len < SIZE_BUFFER-3 )
	{
	    /* '@' is special */
	    if ( CURRENT(InBuffer) == '@' )
	    {
		(void) READ_CURRENT(InBuffer);
		WaitInput(&InBuffer);
		if ( CURRENT(InBuffer) == 'm' )
		{

		    /* get ride of any output left over */
		    if ( 0 < len )
		    {
			TBuf[len] = 0;
			GTReplaceText( GapTalk, TBuf, len );
			if ( SpyMode )
			    fwrite( TBuf, 1, len, stderr );
		    }

		    /* collect ouptut 'TBuf' in case it is not "mAgIc" */
		    len = 0;
		    TBuf[len++] = '@';
		    TBuf[len++] = 'm';
		    (void)READ_CURRENT(InBuffer);
		    WaitInput(&InBuffer);
		    if ( CURRENT(InBuffer) != 'A' )  continue;
		    (void)READ_CURRENT(InBuffer);
		    TBuf[len++] = 'A';
		    WaitInput(&InBuffer);
		    if ( CURRENT(InBuffer) != 'g' )  continue;
		    (void)READ_CURRENT(InBuffer);
		    TBuf[len++] = 'g';
		    WaitInput(&InBuffer);
		    if ( CURRENT(InBuffer) != 'I' )  continue;
		    (void)READ_CURRENT(InBuffer);
		    TBuf[len++] = 'I';
		    WaitInput(&InBuffer);
		    if ( CURRENT(InBuffer) != 'c' )  continue;
		    (void)READ_CURRENT(InBuffer);
		    len = 0;
		    ExecRunning = False;
		    DEBUG( D_COMM, ("GapOutput: %s: '%s'\n",
                           "leaving exec loop, input remaining",
		           InBuffer.buffer+InBuffer.pos) );
		    goto end_exec_loop;

		}
		else
		{
		    TBuf[len++] = '@';
		    continue;
		}
	    }
	    
	    /* store input */
	    else
		TBuf[len++] = READ_CURRENT(InBuffer);
	}
	TBuf[len] = 0;
	GTReplaceText( GapTalk, TBuf, len );
        if ( SpyMode )
	    fwrite( TBuf, 1, len, stderr );
	return;
    }
end_exec_loop:
	
    /* process gap output */
    while ( HAS_BUFFERED(InBuffer) )
    {
	/* '@' is special */
	if ( CURRENT(InBuffer) == '@' )
	{
	    (void) READ_CURRENT(InBuffer);
	    WaitInput(&InBuffer);
	    if ( 'A' <= CURRENT(InBuffer) && CURRENT(InBuffer) <= 'Z' )
	    {
		special = 0;
		ch = READ_CURRENT(InBuffer);
		ch = CTR(ch);
	    }
	    else if ( CURRENT(InBuffer) == '@' )
	    {
		special = 0;
		ch = READ_CURRENT(InBuffer);
	    }
	    else if ( CURRENT(InBuffer) == 'z' )
	    {
		(void)READ_CURRENT(InBuffer);
		ExecRunning = True;
		DEBUG( D_COMM, ("GapOutput: entering exec loop\n") );
		GapOutput( cld, fid, id );
		return;
	    }
		
	    else
	    {
		special = 1;
		ch = READ_CURRENT(InBuffer);
	    }
	}
	else
	{
	    special = 0;
	    ch = READ_CURRENT(InBuffer);
	}

	/* process window commands */
	if ( special )
	{

	    /* '1' to '6' are garbage */
	    if ( '1' <= ch && ch <= '6' )
	    {
		Int	size;
		ParseInt( &InBuffer, &size );
		UpdateMemoryInfo( (int) (ch-'0'), size );
	    }

	    /* '!','"','#','$','%','&' are garbage */
	    else if ( '!' <= ch && ch <= '&' ) {
		Int	size;
		ParseInt( &InBuffer, &size );
	    }

	    /* 'i' means gap is waiting for input */
	    else if ( ch == 'i' )
	    {
		LastLine = GTPosition(GapTalk);
		GapState = GAP_INPUT;
		UpdateMenus(GapState);
		UpdateXCMDS(True);
		ProcessStoredInput(0);
	    }

	    /* 'e' means gap is waiting for error input */
	    else if ( ch == 'e' )
	    {
		LastLine = GTPosition(GapTalk);
		GapState = GAP_ERROR;
		UpdateMenus(GapState);
		UpdateXCMDS(True);
		ProcessStoredInput(0);
	    }

	    /* 'r' is the current input line */
	    else if ( ch == 'r' )
	    {
		ReadLine(&InBuffer);
		GTSetPosition( GapTalk, LastLine );
		GTReplaceText( GapTalk, GapBuffer, strlen(GapBuffer) );
		if ( SpyMode )
		{
		    fwrite( GapBuffer, 1, strlen(GapBuffer), stderr );
		}
		GapState = GAP_RUNNING;
		UpdateMenus(GapState);
		UpdateXCMDS(False);
		ProcessStoredInput(1);
		LastLine = -1;
	    }
	    
	    /* 'x' no text at current line */
	    else if ( ch == 'x' )
	    {
		GTSetPosition( GapTalk, LastLine );
		GTReplaceText( GapTalk, "", 0 );
		GapState = GAP_RUNNING;
		UpdateMenus(GapState);
		UpdateXCMDS(True);
		LastLine = -1;
	    }
	    
	    /* 'c' completion output started */
	    else if ( ch == 'c' )
	    {
		GapState = GAP_RUNNING;
		UpdateMenus(GapState);
		UpdateXCMDS(True);
		LastLine = -1;
	    }
	    
	    /* 'h' help output started */
	    else if ( ch == 'h' )
	    {
		GapState = GAP_HELP;
		UpdateMenus(GapState);
		UpdateXCMDS(False);
		LastLine = -1;
	    }
	    
	    /* 'w' is a window command */
	    else if ( ch == 'w' )
	    {
		long	i;
		long    m;
		char  * ptr;
		char  * cmd;

		len = 0;
		WaitInput(&InBuffer);
		ch = READ_CURRENT(InBuffer);
		for ( len = 0, m = 1;  '0' <= ch && ch <= '9';  m *= 10 ) {
		    len += (ch-'0') * m;
		    WaitInput(&InBuffer);
		    ch = READ_CURRENT(InBuffer);
		}
		ptr = cmd = XtMalloc(len+1);
		i   = len;
	        while ( 0 < i )
		{
		    WaitInput(&InBuffer);
		    while ( HAS_INPUT(InBuffer) && 0 < i )
		    {
			*ptr++ = READ_CURRENT(InBuffer);
			i--;
		    }
		}
		*ptr++ = 0;
		GapWindowCmd( cmd, len );
		XtFree(cmd);
	    }

	    /* ignore 'n' for the moment */
	    else if ( ch == 'n' )
		ch = 'n';

	    /* ignore 'f' for the moment */
	    else if ( ch == 'f' )
		ch = 'f';

	    /* ignore 's',  see 'SimulateInput' */
	    else if ( ch == 's' ) {
		WaitInput(&InBuffer);
		(void)READ_CURRENT(InBuffer);
		continue;
	    }
	}

	/* collect normal characters and display them */
	else if ( ' ' <= ch && ch < 127 && GapState == GAP_RUNNING )
	{
	    TBuf[0] = ch;
	    for ( len = 1;  len<SIZE_BUFFER && HAS_BUFFERED(InBuffer); )
		if ( CURRENT(InBuffer) == '@' )
		{
		    if ( LOOK_AHEAD(InBuffer) == 'n' )
		    {
			(void)READ_CURRENT(InBuffer);
			/* WaitInput(&InBuffer); */
			(void)READ_CURRENT(InBuffer);
		    }
		    else if ( LOOK_AHEAD(InBuffer) == 'f' )
		    {
			(void)READ_CURRENT(InBuffer);
			/* WaitInput(&InBuffer); */
			(void)READ_CURRENT(InBuffer);
		    }
		    else if ( LOOK_AHEAD(InBuffer) == 'J' )
		    {
			(void)READ_CURRENT(InBuffer);
			/* WaitInput(&InBuffer); */
			(void)READ_CURRENT(InBuffer);
			TBuf[len++] = '\n';
		    }
		    else
			break;
		}
		else if ( ' '<=CURRENT(InBuffer) && CURRENT(InBuffer)<127 )
		    TBuf[len++] = READ_CURRENT(InBuffer);
	        else
		    break;
	    GTReplaceText( GapTalk, TBuf, len );
	}

	/* collect normal characters and display them */
	else if ( ' ' <= ch && ch < 127 && GapState != GAP_RUNNING )
	{
	    TBuf[0] = ch;
	    for ( len = 1;  len<SIZE_BUFFER && HAS_INPUT(InBuffer);  len++ )
		if ( CURRENT(InBuffer) == '@' )
		    break;
		else if ( ' '<=CURRENT(InBuffer) && CURRENT(InBuffer)<127 )
		    TBuf[len] = READ_CURRENT(InBuffer);
	        else
		    break;
	    GTReplaceText( GapTalk, TBuf, len );
	}

	/* carriage return */
	else if ( ch == '\n' )
	{
	    if ( GapState != GAP_INPUT && GapState != GAP_ERROR )
		GTReplaceText( GapTalk, &ch, 1 );
	}

	/* <CTR-G> rings a bell */
	else if ( ch == CTR('G') )
	    GTBell(GapTalk);

	/* <CTR-H> moves to the left */
	else if ( ch == CTR('H') )
	    GTMoveCaret( GapTalk, -1 );

	/* ignore anything else */
	else 
	    ch = ch;
    }
}


/****************************************************************************
**

*F * * * * * * * * * * * * starting/stopping gap + * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  KillGap() . . . . . . . . . . . . . . . . . . . . .  kill the running gap
*/
void KillGap ()
{
    if ( GapPID != -1 )
    {
	close(ToGap);
        kill( GapPID, SIGKILL );
    }
}


/****************************************************************************
**
*F  InterruptGap()  . . . . . . . . . . . . . . . .  interupt the running gap
*/
void InterruptGap ()
{
    if ( GapPID != -1 )
        kill( GapPID, SIGINT );
}


/****************************************************************************
**
*F  GetMasterPty( <fid> ) . . . . . . . . .  open a master pty (from "xterm")
*/
static String ptydev = 0;
static String ttydev = 0;

#ifndef SYS_PTYDEV
#  ifdef hpux
#    define SYS_PTYDEV          "/dev/ptym/ptyxx"
#  else
#    define SYS_PTYDEV          "/dev/ptyxx"
#  endif
#endif

#ifndef SYS_TTYDEV
#  ifdef hpux
#    define SYS_TTYDEV          "/dev/pty/ttyxx"
#  else
#    define SYS_TTYDEV          "/dev/ttyxx"
#  endif
#endif

#ifndef SYS_PTYCHAR1
#  ifdef hpux
#    define SYS_PTYCHAR1        "zyxwvutsrqp"
#  else
#    define SYS_PTYCHAR1        "pqrstuvwxyz"
#  endif
#endif

#ifndef SYS_PTYCHAR2
#  ifdef hpux
#    define SYS_PTYCHAR2        "fedcba9876543210"
#  else
#    define SYS_PTYCHAR2        "0123456789abcdef"
#  endif
#endif


static Boolean GetMasterPty ( pty )
    int   * pty;
{
#if HAVE_GETPT && HAVE_PTSNAME_R
  if ((*pty = getpt()) > 0 )
    {
      if (grantpt(*pty) || unlockpt(*pty))
        return True;
      ptsname_r(*pty, ttydev, 80); 
      return False;
    }
  return True;
#else
#   ifdef att
        if ( (*pty = open( "/dev/ptmx", O_RDWR )) < 0 )
            return True;
        return False;

#   else
#   ifdef __CYGWIN__
        static int  slave    = 0;

        sprintf(ptydev, "/dev/ptmx");
        if ( (*pty = open( ptydev, O_RDWR )) >= 0 ) {   
            /* O_NONBLOCK | O_NOCTTY */
            strcpy(ttydev, ptsname(*pty));
            revoke(ttydev);     /* ???? NECESSARY ???? */
            return False;
        }
        errno = ENOENT; /* out of ptys */
        perror(" Failed on open CYGWIN pty");
        return True;
#   else
#   if HAVE_GETPSEUDOTTY
        return (*pty = getpseudotty( &ttydev, &ptydev )) >= 0 ? False : True;

#   else
#   if HAVE__GETPTY
    char  * line;

	line = _getpty(pty, O_RDWR|O_NDELAY, 0600, 0) ;
        if (0 == line)
            return True;
	strcpy( ttydev, line );
	return False;

#   else
#   if defined(sgi) || (defined(umips) && defined(USG))
        struct stat fstat_buf;

        *pty = open( "/dev/ptc", O_RDWR );
        if ( *pty < 0 || (fstat (*pty, &fstat_buf)) < 0 )
            return True;
        sprintf( ttydev, "/dev/ttyq%d", minor(fstat_buf.st_rdev) );
#       if !defined(sgi)
            sprintf( ptydev, "/dev/ptyq%d", minor(fstat_buf.st_rdev) );
            if ( (*tty = open (ttydev, O_RDWR)) < 0 ) 
            {
                close (*pty);
                return True;
            }
#       endif
        return False;

#   else
        static int  devindex = 0;
        static int  letter   = 0;
        static int  slave    = 0;

        while ( SYS_PTYCHAR1[letter] )
        {
            ttydev[strlen(ttydev)-2] = SYS_PTYCHAR1[letter];
            ptydev[strlen(ptydev)-2] = SYS_PTYCHAR1[letter];

            while ( SYS_PTYCHAR2[devindex] )
            {
                ttydev[strlen(ttydev)-1] = SYS_PTYCHAR2[devindex];
                ptydev[strlen(ptydev)-1] = SYS_PTYCHAR2[devindex];
                        
                if ( (*pty = open( ptydev, O_RDWR )) >= 0 )
                    if ( (slave = open( ttydev, O_RDWR, 0 )) >= 0 )
                    {
                        close(slave);
                        (void) devindex++;
                        return False;
                    }
                devindex++;
            }
            devindex = 0;
            (void) letter++;
        }
        return True;
#   endif
#   endif
#   endif
#   endif
#   endif
#endif
}


/****************************************************************************
**
*F  StartGapProcess( <name>, <argv> ) . . . start a gap subprocess using ptys
*/
static void GapStatusHasChanged ()
{
#   ifdef SYS_HAS_UNION_WAIT
        union wait	w;
#   else
        int             w;
#   endif

    /* if the child was stopped return */
    if ( wait3( &w, WNOHANG | WUNTRACED, 0 ) != GapPID || WIFSTOPPED(w) )
	return;
#   ifdef DEBUG_ON
        fputs( "gap status has changed, leaving xgap\n", stderr );
        fprintf( stderr,"Signal: %d\n",WTERMSIG(w));
#   endif
    exit(1);
}

int StartGapProcess ( name, argv )
    String          name;
    String          argv[];
{
    Int             j;       /* loop variables                  */
    char            c[8];    /* buffer for communication        */
    int             master;  /* pipe to GAP                     */
    int             n;       /* return value of 'select'        */
    int             slave;   /* pipe from GAP                   */
    /* struct */ fd_set   fds;     /* for 'select'                    */
    struct timeval  timeout; /* time to wait for aknowledgement */

#   if HAVE_TERMIOS_H
        struct termios  tst; /* old and new terminal state      */
#   else
#     if HAVE_TERMIO_H
        struct termio   tst; /* old and new terminal state      */
#     else
        struct sgttyb   tst; /* old and new terminal state      */
#     endif
#   endif

    /* construct the name of the pseudo terminal */
    /* was:
      ttydev = XtMalloc(strlen(SYS_TTYDEV)+1);  strcpy( ttydev, SYS_TTYDEV );
      ptydev = XtMalloc(strlen(SYS_PTYDEV)+1);  strcpy( ptydev, SYS_PTYDEV );
      changed by Max 2.5.2004 because this might be too short! */
    ttydev = XtMalloc(81);  strcpy( ttydev, SYS_TTYDEV );
    ptydev = XtMalloc(81);  strcpy( ptydev, SYS_PTYDEV );

    /* open pseudo terminal for communication with gap */
    if ( GetMasterPty(&master) )
    {
        fputs( "open master failed\n", stderr );
        exit(1);
    }
    if ( (slave  = open( ttydev, O_RDWR, 0 )) < 0 )
    {
        fputs( "open slave failed\n", stderr );
        exit(1);
    }
#   if defined(DEBUG_ON) && !defined(att)
        DEBUG( D_COMM, ("StartGapProcess: master='%s', slave='%s'\n",
		ptydev ? ptydev : "unknown",
		ttydev ? ttydev : "unkown") );
#   endif
#   if HAVE_TERMIOS_H
        if ( tcgetattr( slave, &tst ) == -1 )
        {
            fputs( "tcgetattr on slave pty failed\n", stderr );
            exit(1);
        }
        tst.c_cc[VINTR] = 0377;
        tst.c_cc[VQUIT] = 0377;
        tst.c_iflag    &= ~(INLCR|ICRNL);
        tst.c_cc[VMIN]  = 1;
        tst.c_cc[VTIME] = 0;
        tst.c_lflag    &= ~(ECHO|ICANON);
        if ( tcsetattr( slave, TCSANOW, &tst ) == -1 )
        {
            fputs( "tcsetattr on slave pty failed\n", stderr );
            exit(1);
        }
#   else
#     if HAVE_TERMIO_H
        if ( ioctl( slave, TCGETA, &tst ) == -1 )
	{
	    fputs( "ioctl TCGETA on slave pty failed\n", stderr );
	    exit(1);
	}
        tst.c_cc[VINTR] = 0377;
        tst.c_cc[VQUIT] = 0377;
        tst.c_iflag    &= ~(INLCR|ICRNL);
        tst.c_cc[VMIN]  = 1;
        tst.c_cc[VTIME] = 0;   
        /* Note that this is at least on Linux dangerous! 
           Therefore, we now have the HAVE_TERMIOS_H section for POSIX
           Terminal control. */
        tst.c_lflag    &= ~(ECHO|ICANON);
        if ( ioctl( slave, TCSETAW, &tst ) == -1 )
        {
	    fputs( "ioctl TCSETAW on slave pty failed\n", stderr );
	    exit(1);
	}
#     else
        if ( ioctl( slave, TIOCGETP, (char*)&tst ) == -1 )
        {
	    if ( ttydev )
	      fprintf( stderr, "ioctl TIOCGETP on slave pty failed (%s)\n",
		       ttydev );
	    else
	      fputs( "ioctl TIOCGETP on slave pty failed\n", stderr );
	    exit(1);
        }
        tst.sg_flags |= RAW;
        tst.sg_flags &= ~ECHO;
        if ( ioctl( slave, TIOCSETN, (char*)&tst ) == -1 )
        {
            fputs( "ioctl on TIOCSETN slave pty failed\n", stderr );
	    exit(1);
	}
#endif
#endif

    /* set input to non blocking operation */
    if ( fcntl( master, F_SETFL, O_NDELAY ) < 0 )
    {
        fputs( "Panic: cannot set non blocking operation.\n", stderr );
        exit(1);
    }

    /* fork to gap, dup pipe to stdin and stdout */
    GapPID = fork();
    if ( GapPID == 0 )
    {
        dup2( slave, 0 );
        dup2( slave, 1 );
        /* The following is necessary because otherwise the GAP process
           will ignore the SIGINT signal: */
        signal( SIGINT, SIG_DFL );
#       ifdef SYS_HAS_EXECV_CCHARPP
            execv( name, (const char**) argv );
#       else
            execv( name, (void*) argv );
#       endif
        write( 1, "@-", 4 );
        close(slave);
        _exit(1);
    }
    ToGap   = master;
    FromGap = master;

    /* check if the fork was successful */
    if ( GapPID == -1 )
    {
        fputs( "Panic: cannot fork to subprocess.\n", stderr );
        exit(1);
    }

    /* wait at least 60 sec before giving up */
    timeout.tv_sec  = 60;
    timeout.tv_usec = 0;

    /* wait for an aknowledgement (@p) from the gap subprocess */
    j = 0;
    while ( j < 10 && c[j-1] != '.' )
    {

        /* set <FromGap> port for listen */
#       ifdef FD_SET
	    FD_ZERO(&fds);
	    FD_SET( FromGap, &fds );
#       else
        {
	    Int     i;

            for ( i = FromGap/sizeof(fds.fds_bits); 0 <= i; i-- )
                fds.fds_bits[i] = 0;
            fds.fds_bits[FromGap/sizeof(fds.fds_bits)] =
                                   ( 1 << (FromGap % sizeof(fds.fds_bits)) );
        }
#       endif

        /* use 'select' to check port */
        if ( (n = select(FromGap+1, &fds, 0, 0, &timeout)) == -1 )
        {
            kill( GapPID, SIGKILL );
            perror("select failed");
            exit(1);
        }
        else if ( n == 0 )
        {
            kill( GapPID, SIGKILL );
            fputs("Panic: cannot establish communication with gap.", stderr);
            exit(1);
        }
        else
            ReadGap( &(c[j++]), 1 );
    }

    /* check if we got "@p" */
    if ( c[j-1] != '.' || strncmp( c, "@p", 2 ) )
    {
        if ( ! strncmp( c, "@-", 2 ) )
        {
            fputs( "Panic: cannot start subprocess ", stderr );
            fputs( name, stderr );
            fputs( ".\n", stderr );
        }
        else
        {
            strcpy( c+3, "'\n" );
            fputs( "Panic: cannot talk with gap, got '", stderr );
            fputs( c, stderr );
            kill( GapPID, SIGKILL );
        }
        exit(1);
    }

    /* if the gap dies,  stop program */
    signal( SIGCHLD, GapStatusHasChanged );
    InBuffer.pos = InBuffer.len = 0;
    return FromGap;
}


/****************************************************************************
**

*E  pty.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
