/****************************************************************************
**
*W  utils.h                     XGAP Source                      Frank Celler
**
*H  @(#)$Id: utils.h,v 1.4 1999/07/09 00:02:41 gap Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
**
**  This  file contains the  utility  functions  and  macros  used in   XGAP,
**  basically  the list functions  ('ELM', 'LEN',  'AddList', and 'List') and
**  the  debug  macro ('DEBUG').  This  file also  includes all the necessary
**  system and X11 include files and defines the following data types:
**
**      Boolean         "True" or "False" (defined by X11)
**      Char            a "Char" will be able to hold one character
**      Int             a 32-bit signed integer
**      Long            an integer able to hold a pointer
**      Pointer         a generic pointer
**      Short           a 16-bit signed integer
**      String          an array of chars
**      UChar           unsigned version of "Char"
**      UInt            a 32-bit unsigned integer
**      ULong           unsigned version of "Long"
**      UShort          a 16-bit unsigned integer
**
**  List( <len> )
**  -------------
**  'List' creates a new list able to hold <len> pointers of type 'Pointer'.
**
**  AddList( <lst>, <elm> )
**  -----------------------
**  'AddList' appends  the  new  element  <elm> of type  'Pointer'  to <lst>,
**  enlarging the list if necessary.
**
**  ELM( <lst>, <i> )
**  -----------------
**  'ELM' returns the <i>.th element of <lst>.
**
**  LEN( <lst> )
**  ------------
**  'LEN' returns the length of <lst>.
**
**  DEBUG( <type>, ( <debug-text>, ... ) )
**  --------------------------------------
**  'DEBUG' uses 'printf' to print the  <debug-text> in case that  'Debug' &&
**  <type> is true.  The text  is preceded by the line number  and the source
**  file name.  The following types are available:  D_LIST, D_XCMD, D_COMM.
*/
#ifndef _utils_h
#define _utils_h


/****************************************************************************
**
*F  Include . . . . . . . . . . . . . . . . . . . . . .  system include files
*/
#include <config.h>

#if HAVE_TERMIO_H
#undef  HAVE_SGTTY_H
#define HAVE_SGTTY_H	0
#endif

#include    <stdio.h>                   /* standard C i/o library          */

#if STDC_HEADERS
# include   <stdlib.h>                  /* standard C library              */
# include   <stdarg.h>                  /* variable argument list          */
#endif

#if HAVE_LIBC_H
# include   <libc.h>                    /* standard NeXT C library         */
#endif

#if HAVE_UNISTD_H
# include   <unistd.h>                  /* another standard C library      */
#endif

#include    <pwd.h>

#if TIME_WITH_SYS_TIME
# include   <sys/time.h>
# include   <time.h>
#else
# if HAVE_SYS_TIME_H
#  include  <sys/time.h>
# else
#  include  <time.h>
# endif
#endif

#if HAVE_FCNTL_H
#include    <fcntl.h>
#endif

#include    <sys/errno.h>
#include    <sys/stat.h>
#include    <sys/types.h>
#include    <sys/resource.h>

#if HAVE_SYS_WAIT_H
# include   <sys/wait.h>
#endif

#include    <sys/param.h>

#if HAVE_TERMIOS_H
# include   <termios.h>
#else
#if HAVE_TERMIO_H
# include   <termio.h>
#else
# include   <sgtty.h>
#endif
#endif

#if HAVE_SIGNAL_H
# include   <signal.h>
#endif

#if HAVE_SYS_SELECT_H
# include   <sys/select.h>
#endif


/****************************************************************************
**
*F  Include . . . . . . . . . . . . . . . . . . . . . . . . X11 include files
*/
#include    <X11/X.h>                   /* X11 basic definition            */
#include    <X11/Xos.h>
#include    <X11/Xatom.h>
#include    <X11/Xlib.h>
#include    <X11/StringDefs.h>
#include    <X11/keysym.h>

#include    <X11/Intrinsic.h>           /* X Intrinsic                     */
#include    <X11/IntrinsicP.h>
#include    <X11/CoreP.h>
#include    <X11/Composite.h>
#include    <X11/Shell.h>

#include    <X11/cursorfont.h>          /* cursor font                     */

#include    <X11/Xaw/AsciiText.h>       /* Athena widgets                  */
#include    <X11/Xaw/Box.h>
#include    <X11/Xaw/Cardinals.h>
#include    <X11/Xaw/Command.h>
#include    <X11/Xaw/Dialog.h>
#include    <X11/Xaw/Form.h>
#include    <X11/Xaw/Label.h>
#include    <X11/Xaw/List.h>
#include    <X11/Xaw/MenuButton.h>
#include    <X11/Xaw/Paned.h>
#include    <X11/Xaw/Scrollbar.h>
#include    <X11/Xaw/SimpleMenu.h>
#include    <X11/Xaw/SmeBSB.h>
#include    <X11/Xaw/SmeLine.h>
#include    <X11/Xaw/Text.h>
#include    <X11/Xaw/TextP.h>
#include    <X11/Xaw/TextSink.h>
#include    <X11/Xaw/TextSrc.h>
#include    <X11/Xaw/TextSrcP.h>
#include    <X11/Xaw/Viewport.h>
#include    <X11/Xaw/ViewportP.h>
#include    <X11/Xaw/XawInit.h>


/****************************************************************************
**
*F  Prototypes  . . . . . . . . . . . . . . . . . . . . . . system prototypes
*/
#if ! HAVE_UNISTD_H && ! HAVE_LIBC_H
extern int write();
#endif

extern pid_t wait3();
extern int   select();

/* IRIX System V.4 running IRIX Release 5.3 already defines ioctl and  */
/* therefore doesn't like the declaration of ioctl                     */

/* extern int ioctl(); */


/****************************************************************************
**

*T  Char  . . . . . . . . . . . . . . . . . . . . . . . . . . . . a character
*/
typedef char Char;


/****************************************************************************
**
*T  Int . . . . . . . . . . . . . . . . . . . . . . . . . . . a signed 32-bit
*/
typedef int Int;


/****************************************************************************
**
*T  Long  . . . . . . . . . . . . . . a signed integer able to hold a pointer
*/
typedef long Long;


/****************************************************************************
**
*T  Pointer . . . . . . . . . . . . . . . . . . . . . . . . a generic pointer
*/
typedef void * Pointer;


/****************************************************************************
**
*T  Short . . . . . . . . . . . . . . . . . . . . . . . . . . a signed 16-bit
*/
typedef short Short;


/****************************************************************************
**
*T  UChar . . . . . . . . . . . . . . . . . . . . . . . an unsigned character
*/
typedef unsigned char UChar;


/****************************************************************************
**
*T  UInt  . . . . . . . . . . . . . . . . . . . . . . . .  an unsigned 32-bit
*/
typedef unsigned int UInt;


/****************************************************************************
**
*T  ULong . . . . . . . . . . . .  an unsigned integer able to hold a pointer
*/
typedef unsigned long ULong;


/****************************************************************************
**
*T  UShort  . . . . . . . . . . . . . . . . . . . . . . .  an unsigned 16-bit
*/
typedef unsigned short UShort;


/****************************************************************************
**

*F  DEBUG(( <str> ))  . . . . . . . . . . . . . . . print <str> as debug info
*/
extern Int Debug;

#define D_LIST		1
#define D_XCMD          2
#define D_COMM          4

#define DEBUG(a,b) {                                       \
            if ( Debug & a ) {                             \
                printf( "%04d:%s: ", __LINE__, __FILE__ ); \
                printf b;                                  \
            }                                              \
        } while(0)


/****************************************************************************
**
*F  MAX( <a>, <b> ) . . . . . . . . . . . . . . . . .  maximum of <a> and <b>
*/
#undef  MAX
#define MAX(a,b)        (((a) < (b)) ? (b) : (a))


/****************************************************************************
**
*F  MIN( <a>, <b> ) . . . . . . . . . . . . . . . . .  minimum of <a> and <b>
*/
#undef  MIN
#define MIN(a,b)        (((a) < (b)) ? (a) : (b))


/****************************************************************************
**

*T  TypeList  . . . . . . . . . . . . . . . . . . . . . . . .  list structure
*/
typedef struct _list
{
    UInt        size;
    UInt        len;
    Pointer   * ptr;
}
* TypeList;


/****************************************************************************
**
*F  ELM( <lst>, <i> ) . . . . . . . . . . . . . . . . <i>th element of a list
*/
#define ELM(lst,i)      (lst->ptr[i])


/****************************************************************************
**
*F  LEN( <lst> )  . . . . . . . . . . . . . . . . . . . . .  length of a list
*/
#define LEN(lst)        (lst->len)


/****************************************************************************
**
*F  AddList( <lst>, <elm> ) . . . . . . . .  add list element <elm> to <list>
*/
#ifdef DEBUG_ON
    extern void 	ADD_LIST( String, Int, TypeList, Pointer );
#   define AddList(a,b)	ADD_LIST( __FILE__, __LINE__, a, b )
#else
    extern void 	AddList( TypeList, Pointer );
#endif


/****************************************************************************
**
*F  List( <len> )   . . . . . . . . . . . . . . . . . . .   create a new list
*/
#ifdef DEBUG_ON
    extern TypeList 	LIST( String, Int, UInt );
#   define List(a) 	LIST( __FILE__, __LINE__, a )
#else
    extern TypeList 	List( UInt );
#endif

#endif


/****************************************************************************
**

*E  utils.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
