/* Program to send a string to an X-Window as if it was keypresses 
 * This is used by the xdvi help viewer to flip pages. 
 * First, very rudimentary version that does only recognize a few keys.
 * The neat XWindows event code is due to Shane Smit (ssmit@caldera.com), 
 * the atrocious wraper loop running over a string is by A.Hulpke (who 
 * still cannot code proper C...) 27-Nov-00 */

#include <X11/Xlib.h> 
#include <X11/keysym.h>


int main( int iArgc, char *asArgv[] )
{
  char *cmd;
  Display *pDisplay;
  KeyCode A_KeyCode;
  KeySym kasy;
  XKeyPressedEvent KeyPressEvent;
  XKeyReleasedEvent KeyReleaseEvent;
  Window Target;
  int iDummy,i;

  if( iArgc != 3 )
  {
	  printf( "Usage: %s <winid> <string>\n", asArgv[ 0 ] );
	  return 0;
  }

  Target = (Window)atoi(asArgv[1]);
  cmd = asArgv[2];
  pDisplay = XOpenDisplay( NULL );

  /* printf( "Target: %x \n", Target ); */

  /* this is an awful case distinction -- is there any better way ? */
  while (*cmd != '\0') {
    switch (*cmd) {
      case '0': kasy=XK_0;break;
      case '1': kasy=XK_1;break;
      case '2': kasy=XK_2;break;
      case '3': kasy=XK_3;break;
      case '4': kasy=XK_4;break;
      case '5': kasy=XK_5;break;
      case '6': kasy=XK_6;break;
      case '7': kasy=XK_7;break;
      case '8': kasy=XK_8;break;
      case '9': kasy=XK_9;break;
      case 'a': kasy=XK_a;break;
      case 'g': kasy=XK_g;break;

    }
    A_KeyCode = XKeysymToKeycode( pDisplay, kasy );

    KeyPressEvent.type = KeyPress;          /* KeyPress or KeyRelease */
    KeyPressEvent.display = pDisplay;       /* Display the event was read from */
    KeyPressEvent.window = Target;          /* "event" window it is reported relative to */
    KeyPressEvent.subwindow = None;         /* child window */
    KeyPressEvent.state = NULL;             /* key or button mask */
    KeyPressEvent.keycode = A_KeyCode;      /* detail */
    KeyPressEvent.same_screen = True;       /* same screen flag */

    KeyReleaseEvent.type = KeyRelease;      /* KeyPress or KeyRelease */
    KeyReleaseEvent.display = pDisplay;     /* Display the event was read from */
    KeyReleaseEvent.window = Target;        /* "event" window it is reported relative to */
    KeyReleaseEvent.subwindow = None;       /* child window */
    KeyReleaseEvent.state = NULL;           /* key or button mask */
    KeyReleaseEvent.keycode = A_KeyCode;    /* detail */
    KeyReleaseEvent.same_screen = True;     /* same screen flag */

    XSendEvent( pDisplay, Target, False, NULL, &KeyPressEvent );
    XSendEvent( pDisplay, Target, False, NULL, &KeyReleaseEvent );
    XFlush( pDisplay );
    cmd++;
  } 
  return 1;
}
