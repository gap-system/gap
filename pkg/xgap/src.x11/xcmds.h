/****************************************************************************
**
*W  xcmds.h                     XGAP Source                      Frank Celler
**
*H  @(#)$Id: xcmds.h,v 1.2 1997/12/05 17:31:11 frank Exp $
**
*Y  Copyright 1995-1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
*/
#ifndef _xcmds_h
#define _xcmds_h

#include "utils.h"


/****************************************************************************
**

*T  TypeGapWindow . . . . . . . . . . . . . . . . description of a gap window
*/
typedef struct _gap_window
{
    Widget              top;
    Widget              box;
    Widget              viewport;
    Widget              draw;
    Widget              text;
    Boolean             used;
    TypeList            menus;
    Int                 height;
    Int                 width;
    Int                 line_width;
    Int                 color;
    Boolean             fast_update;
}
TypeGapWindow;


/****************************************************************************
**
*T  TypeTextSelector  . . . . . . . . . . . .  description of a text selector
*/
typedef struct _text_selector
{
    Widget              top;
    Widget              list;
    String            * text;
    TypeList            buttons;
}
TypeTextSelector;


/****************************************************************************
**
*T  TypeArg . . . . . . . . . . . . . . . . . . . . . . . . . . . . arguments
*/
#define MAX_ARG		10

typedef struct _arg
{
    TypeGapWindow     * win;
    TypeTextSelector  * sel;
    XFontStruct       * font;
    Int                 iargs[MAX_ARG];
    String              sargs[MAX_ARG];
    String              opts;
}
TypeArg;


/****************************************************************************
**
*T  TypeWindowCommand . . . . . . . . . . . . . . . . description of commands
*/
typedef struct _window_command
{
    String	name;
    String      args;
    Boolean     (*func)( TypeArg* );
}
TypeWindowCommand;


/****************************************************************************
**
*T  TypeMenu  . . . . . . . . . . . . . . . . . . . . . . description of menu
*/
typedef struct _menu
{
    Widget      button;
    Widget      shell;
    TypeList	entries;
    String      name;
    String      string;
}
TypeMenu;


/****************************************************************************
**
*T  TypeMenuData  . . . . . . . . . . . . . . . . . . . . . . . .  menu entry
*/
typedef struct _menu_data
{
    Widget      shell;
    Int         window;
    Int         popup;
    Int         pane;
}
TypeMenuData;


/****************************************************************************
**
*T  TypePaneData  . . . . . . . . . . . . . . . . . . . . .  popup menu entry
*/
typedef struct _pane_data
{
    Widget      shell;
    Int         popup;
    Int         pane;
}
TypePaneData;


/****************************************************************************
**

*P  Prototypes	. . . . . . . . . . . . . . . . . . . . . function prototypes
*/
extern void     InitXCMDS( void );
extern void     ExitXMCDS( void );
extern void     UpdateXCMDS( Int );
extern Boolean  GapWindowCmd( String, Int );

#endif


/****************************************************************************
**

*E  xcmds.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
