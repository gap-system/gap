/****************************************************************************
**
*W  xgap.h                      XGAP Source                      Frank Celler
**
*H  @(#)$Id: xgap.h,v 1.3 1997/12/05 17:31:14 frank Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
*/
#ifndef _xgap_h
#define _xgap_h


/****************************************************************************
**

*T  TypeMenuItem  . . . . . . . . . . . . . . . . . . . . .  menu description
*/
#define S_ALWAYS          0
#define S_INPUT_ONLY	  1
#define S_ERROR_ONLY      2
#define S_NORMAL_ONLY     3
#define S_RUNNING_ONLY    4
#define S_HELP_ONLY       5

typedef struct _menu_item
{
  char 	  * label;
  void      (*click)();
  int       sensitive;
  Widget    entry;
}
TypeMenuItem;


/****************************************************************************
**

*F  * * * * * * * * * * * * * * global variables  * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  AppContext	. . . . . . . . . . . . . . . . . . . . .  aplication context
*/
extern XtAppContext AppContext;


/****************************************************************************
**
*V  GapDisplay  . . . . . . . . . . . . . . . . . . . . . . . current display
*/
extern Display * GapDisplay;


/****************************************************************************
**
*V  GapScreen . . . . . . . . . . . . . . . . . . . . . . . .  current screen
*/
extern long GapScreen;


/****************************************************************************
**
*V  GapTalk . . . . . . . . . . . . . . . . . . . . . . . . . gap text window
*/
extern Widget GapTalk;


/****************************************************************************
**
*V  GapState  . . . . . . . . . . . . . . . . . . . . . . . . . status of gap
*/
#define GAP_NOGAP       0
#define	GAP_RUNNING	1
#define GAP_INPUT       2
#define GAP_ERROR       3
#define GAP_HELP        4

extern Int GapState;


/****************************************************************************
**
*V  MyRootWindow  . . . . . . . . . . . . . . . . . . . . current root window
*/
extern Drawable MyRootWindow;


/****************************************************************************
**
*V  SpyMode . . . . . . . . . . . . . . . . . . . . copy GAP output to stderr
*/
extern Boolean SpyMode;


/****************************************************************************
**
*V  WmDeleteWindowAtom  . . . . . . .  window manager "delete window" request
*/
extern Atom WmDeleteWindowAtom;


/****************************************************************************
**
*V  XGap  . . . . . . . . . . . . . . . . . . . . . . . . . .  toplevel shell
*/
extern Widget XGap;


/****************************************************************************
**

*F  * * * * * * * * * * * * * * various symbols * * * * * * * * * * * * * * *
*/



/****************************************************************************
**

*V  CheckMarkSymbol . . . . . . . . . . . . . symbol for checked menu entries
*/
extern Pixmap CheckMarkSymbol;


/****************************************************************************
**
*V  CursorTL  . . . . . . . . . . . . . . . . . . . . . . . .  top left arrow
*/
extern Cursor CursorTL;


/****************************************************************************
**
*V  EmptyMarkSymbol . . . . . . . . . . . . symbol for unchecked menu entries
*/
extern Pixmap EmptyMarkSymbol;


/****************************************************************************
**
*V  MenuSymbol	. . . . . . . . . . . . . . . . .  symbol for drop down menus
*/
extern Pixmap MenuSymbol;


/****************************************************************************
**
*V  ExMarkSymbol  . . . . . . . . . . . . . . . . . . . . .  exclamation mark
*/
extern Pixmap ExMarkSymbol;


/****************************************************************************
**

*P  Prototypes  . . . . . . . . . . . prototypes of public gap text functions
*/
extern void SimulateInput( String );
extern void UpdateMenus( Int );
extern void UpdateMemoryInfo( Int, Int );

#endif


/****************************************************************************
**

*E  xgap.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
