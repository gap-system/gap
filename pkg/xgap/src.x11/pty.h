/****************************************************************************
**
*W  pty.h                       XGAP source                      Frank Celler
**
*H  @(#)$Id: pty.h,v 1.2 1997/12/05 17:31:04 frank Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
*/
#ifndef _pty_h
#define _pty_h


/****************************************************************************
**

*V  QuitGapCtrlD  . . . . . . . . . . . . . . . . . . . . . . . quit on CTR-D
*/
extern Boolean QuitGapCtrlD;


/****************************************************************************
**
*V  ScreenSizeBuffer  . . . . . . . . . . . . . .  screen size change command
*/
extern char ScreenSizeBuffer[];


/****************************************************************************
**
*V  ExecRunning . . . . . . . . . . . . . . . . . .  external program running
*/
extern Boolean ExecRunning;


/****************************************************************************
**

*P  Prototypes  . . . . . . . . . . . . . . . . . . . . . function prototypes
*/
extern Int  CheckCaretPos( Int, Int );
extern int  StartGapProcess( String, String argv[] );
extern void GapOutput( XtPointer, Int*,  XtInputId );
extern void InterruptGap( void );
extern void KeyboardInput( String, Int );
extern void KillGap( void );
extern void StoreInput( String, Int );
extern void ProcessStoredInput( Int );


/****************************************************************************
**

*D  ReadGap( <buf>, <len> ) . . . . . . . . . . . . . . . read bytes from gap
*D  WriteGap( <buf>, <len> )  . . . . . . . . . . . . . .  write bytes to gap
*/
#ifdef DEBUG_ON
    extern Int              READ_GAP ( String, Int, String, Int );
    extern void             WRITE_GAP( String, Int, String, Int );
#   define ReadGap(a,b)	    READ_GAP ( __FILE__, __LINE__, a, b )
#   define WriteGap(a,b)    WRITE_GAP( __FILE__, __LINE__, a, b )
#else
    extern Int              ReadGap ( String, Int );
    extern void             WriteGap( String, Int );
#endif

#endif


/****************************************************************************
**

*E  pty.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
